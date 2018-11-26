# Copyright (c) Mathias Kaerlev 2013-2017.
#
# This file is part of cuwo.
#
# cuwo is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# cuwo is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with cuwo.  If not, see <http://www.gnu.org/licenses/>.

"""
World manager
"""

from cuwo.tgen_wrap import WrapEntityData, get_mask
from cuwo import static
from cuwo.common import (get_item_hp, get_max_xp, get_chunk,
                         iterate_packet_list)
from cuwo.types import IDPool
from cuwo import constants
from cuwo import strings
from cuwo.vector import vec3
from cuwo import tgen
from cuwo.static import StaticEntityHeader
from cuwo.bytes import ByteWriter

import os
from queue import Queue
import asyncio
import math
import threading

class Entity(WrapEntityData):
    old_hostile_type = None

    def init(self, world, creature, entity_id, static_id, is_tgen=False):
        self.is_tgen = is_tgen
        self.creature = creature
        self.entity_id = entity_id
        self.static_id = static_id
        world.entities[entity_id] = self
        self.world = world

    def update(self):
        return

    def reset(self):
        self.set_hp()

    def set_hp(self, value=None):
        self.hp = value or self.get_max_hp()

    def set_position(self, pos):
        self.pos = pos

    def set_velocity(self, vel):
        self.velocity = vel

    def get_type(self):
        return strings.ENTITY_NAMES[self.entity_type]

    def set_type(self, name):
        if name is None:
            self.entity_type = 0xFFFFFFFF
        else:
            self.entity_type = strings.ENTITY_IDS[name]

    def get_ray_hit(self):
        return self.pos + self.ray_hit * constants.BLOCK_SCALE

    def get_look_dir(self):
        yaw = math.radians(self.body_yaw + 90)
        pitch = math.radians(self.body_pitch)
        x = math.cos(yaw) * math.cos(pitch)
        y = math.sin(yaw) * math.cos(pitch)
        z = math.sin(pitch)
        return vec3(x, y, z)

    def get_max_hp(self):
        hp = self.get_base_hp()
        hp += get_item_hp(self.equipment[6])
        hp += get_item_hp(self.equipment[7])
        hp += get_item_hp(self.equipment[2])
        hp += get_item_hp(self.equipment[3])
        hp += get_item_hp(self.equipment[4])
        hp += get_item_hp(self.equipment[5])
        return hp

    def get_max_xp(self):
        return get_max_xp(self.level)

    def get_base_hp(self):
        level_health = 2 ** ((1 - (1 / (0.05 * (self.level - 1) + 1))) * 3)

        if self.hostile_type == 0:
            health = level_health * 2 * self.max_hp_multiplier
        else:
            power_health = 2 ** (self.power_base * 0.25)
            health = level_health * power_health * self.max_hp_multiplier

        if self.class_type == 1:
            health *= 1.30
            if self.specialization == 1:
                health *= 1.25

        elif self.class_type == 2:
            health *= 1.10

        elif self.class_type == 4:
            health *= 1.20

        return health

    def unlink(self):
        del self.world.entities[self.entity_id]
        if not self.static_id:
            self.world.entity_ids.put_back(self.entity_id)
        self.world = None
        self.creature = None

    def destroy(self):
        if self.is_tgen:
            raise NotImplementedError('cannot remove tgen entities')
        self.make_standalone_copy()
        tgen.remove_creature(self.creature)
        self.unlink()

class StaticEntity:
    open_time = None

    def __init__(self, entity_id, header, chunk):
        header = header.cast(StaticEntityHeader)
        self.header = header
        self.world = chunk.world

        try:
            name = header.get_type()
        except KeyError:
            print('Unknown static entity encountered, please report this '
                  'to the developers: ', entity_id, self.world.seed, chunk.pos,
                  header.pos, header.entity_type)
            name = None

        if name in static.SIT_ENTITIES:
            self.interact = self.interact_sit
        elif name in static.OPEN_ENTITIES:
            self.interact = self.interact_open
            header.closed = True

    def interact(self, player):
        pass

    def interact_open(self, player):
        offset = 1.0 - self.get_time_offset()
        self.open_time = self.world.loop.time() - offset
        self.header.closed = not self.header.closed
        self.update()

    def interact_sit(self, player):
        self.header.user_id = player.entity_id
        player.mount(self)
        self.update()

    def on_unmount(self, player):
        self.header.user_id = 0
        self.update()

    def get_time_offset(self):
        if self.open_time is None:
            return 1.0
        t = self.world.loop.time() - self.open_time
        return min(1.0, t)

    def update(self):
        self.header.time_offset = int(self.get_time_offset() * 1e3)


class Region:
    def __init__(self, world, pos):
        self.pos = pos
        self.world = world
        self.chunks = set()
        self.ref_count = 0
        self.has_data = False

    def add_ref_count(self, count):
        self.ref_count += count
        if self.ref_count <= 0:
            self.world.gen_queue.put(('destroy_region', self.pos))
            del self.world.regions[self.pos]
            self.world = None

    def update_data(self):
        self.has_data = True

    def add(self, data):
        self.chunks.add(data)

    def remove(self, data):
        self.chunks.remove(data)

def spawn_to_entity(spawn, entity):
    entity.reset()
    entity.pos = spawn.pos
    entity.spawn_pos = spawn.pos
    entity.hostile_type = spawn.hostile_type
    entity.entity_type = spawn.entity_type
    entity.class_type = spawn.class_type
    entity.specialization = spawn.specialization
    entity.level = spawn.level

    if spawn.flags_bit_3:
        entity.flags |= 1 << 3
    else:
        entity.flags &= ~(1 << 3)

    entity.body_yaw = spawn.yaw
    entity.power_base = spawn.power_base
    entity.not_used19 = spawn.not_used19
    entity.not_used20 = spawn.not_used20

    entity.appearance = spawn.appearance
    entity.equipment = spawn.equipment
    entity.max_hp_multiplier = spawn.max_hp_multiplier
    entity.shoot_speed = spawn.shoot_speed
    entity.damage_multiplier = spawn.damage_multiplier
    entity.armor_multiplier = spawn.armor_multiplier
    entity.resi_multiplier = spawn.resi_multiplier
    entity.unknown_or_not_used4

    entity.name = spawn.name

    if spawn.appearance.flags & 0x200:
        entity.appearance.scale *= 2.0

    off_z = entity.appearance.scale.z * 0.5 + 0.1
    entity.pos.z += off_z * constants.BLOCK_SCALE


class Chunk:
    data = None
    region = None
    last_visit = 0
    destroyed = False

    def __init__(self, world, pos):
        self.world = world
        self.pos = pos
        self.items = []
        self.static_entities = {}

        if not world.use_tgen:
            return

        for reg_pos in self.get_neighborhood_regions():
            try:
                reg = self.world.regions[reg_pos]
            except KeyError:
                reg = Region(self.world, reg_pos)
                self.world.regions[reg_pos] = reg
            reg.add_ref_count(1)

        self.gen_f = world.get_data(pos)
        self.gen_f.add_done_callback(self.on_chunk)

    def get_region_pos(self):
        x, y = self.pos
        return (x // 64, y // 64)

    def get_neighborhood_regions(self):
        reg_x, reg_y = self.get_region_pos()
        # CW generates region in 3x3 neighborhood
        for off_x in range(-1, 2):
            for off_y in range(-1, 2):
                new_reg_x = reg_x + off_x
                new_reg_y = reg_y + off_y
                if (new_reg_x < 0 or new_reg_y < 0 or
                        new_reg_x >= 1024 or new_reg_y >= 1024):
                    continue
                yield (new_reg_x, new_reg_y)

    def on_chunk(self, f):
        if self.destroyed:
            return
        self.data = f.result()

        for reg_pos in self.get_neighborhood_regions():
            self.world.regions[reg_pos].update_data()

        self.region = self.world.regions[self.get_region_pos()]
        self.region.add(self)

        chunk_items = self.data.items
        self.items.extend([item.copy() for item in chunk_items])
        chunk_items.clear()

        for entity_id, data in enumerate(self.data.static_entities):
            header = data.header
            new_entity = self.world.static_entity_class(entity_id, header,
                                                        self)
            self.static_entities[entity_id] = new_entity

        self.update()

    def add_item(self, item):
        self.items.append(item)
        self.update()

    def remove_item(self, index):
        ret = self.items.pop(index).item_data
        self.update()
        return ret

    def get_entity(self, entity_id):
        return self.static_entities[entity_id]

    def on_post_update(self):
        for item in self.items:
            item.drop_time = 0

    def update(self):
        pass

    def destroy(self):
        self.destroyed = True
        self.world.gen_queue.put(('destroy_chunk', self.pos))
        for reg_pos in self.get_neighborhood_regions():
            self.world.regions[reg_pos].add_ref_count(-1)
        self.items = None
        self.region = None
        self.data = None
        self.static_entities = None
        del self.world.chunks[self.pos]

class World:
    data_path = './data/'
    chunk_class = Chunk
    static_entity_class = StaticEntity
    entity_class = Entity
    tgen_init = False
    debug_fp = None
    generating = True
    step_index = 0

    def __init__(self, loop, seed, use_tgen=True, use_entities=True,
                 chunk_retire_time=None):
        if use_tgen:
            for name in ('data1.db', 'data4.db', 'Server.exe'):
                path = os.path.join(self.data_path, name)
                if os.path.isfile(path):
                    continue
                path = os.path.abspath(path)
                raise FileNotFoundError('Missing asset file %r' % path)

        self.loop = loop
        self.use_tgen = use_tgen
        self.use_entities = use_entities
        self.chunks = {}
        self.regions = {}
        self.entities = {}
        self.entity_ids = IDPool(1)
        self.seed = seed
        self.chunk_retire_time = chunk_retire_time

        if not self.use_tgen:
            return

        # tgen incoming packets
        self.hits = []
        self.passives = []
        self.generating = set()

        self.chunk_lock = threading.Lock()
        self.gen_queue = Queue()
        loop.run_in_executor(None, self.run_gen, seed)

    def write_debug(self):
        if self.debug_fp is None:
            return
        writer = ByteWriter()
        writer.write_uint32(len(self.entities))
        for entity in self.entities.values():
            writer.write_uint8(int(entity.is_tgen))
            entity.write(writer)

        self.debug_fp.write(writer.get())

    def set_debug(self, fp):
        self.debug_fp = fp

    def create_entity(self, entity_id=None):
        if entity_id is None:
            entity_id = self.entity_ids.pop()
            static_id = False
        else:
            static_id = True
        creature = tgen.add_creature(entity_id)
        ret = creature.entity_data.cast(self.entity_class)
        ret.init(self, creature, entity_id, static_id)
        return ret

    def add_hit(self, packet):
        self.hits.append(packet)

    def add_passive(self, packet):
        self.passives.append(packet)

    def retire_chunks(self):
        retire_time = self.chunk_retire_time
        if retire_time is None:
            return

        chunks = list(self.chunks.values())
        for chunk in chunks:
            chunk.last_visit += self.dt

        for entity in self.entities.values():
            if entity.is_tgen:
                continue
            chunk_pos = get_chunk(entity.pos)
            if not chunk_pos in self.chunks:
                continue
            self.get_chunk(chunk_pos).last_visit = 0

        for chunk in chunks:
            if chunk.last_visit < retire_time:
                continue
            chunk.destroy()

    def update(self, dt):
        if not self.tgen_init:
            return None

        self.step_index += 1
        self.dt = dt
        self.retire_chunks()

        tgen.set_in_packets(self.hits, self.passives)
        self.hits = []
        self.passives = []

        # we need to save and restore the hostile type so tgen does not
        # deallocate our entities
        for entity in self.entities.values():
            if entity.is_tgen:
                continue
            entity.old_hostile_type = entity.hostile_type
            entity.hostile_type = constants.FRIENDLY_PLAYER_TYPE

        self.write_debug()
        self.chunk_lock.acquire()
        tgen.step(int(dt * 1000.0))
        self.chunk_lock.release()

        creatures = tgen.get_creatures()
        for entity_id, creature in creatures.items():
            ent = self.entities.get(entity_id, None)
            if ent is not None:
                if creature.entity_data.get_addr() == ent.get_addr():
                    continue
                ent.creature.set_ptr(creature)
                ent.set_ptr(creature.entity_data)
                continue
            ret = creature.entity_data.cast(self.entity_class)
            ret.init(self, creature, entity_id, True, True)

        deleted = []
        for entity_id, entity in self.entities.items():
            if entity_id in creatures:
                continue
            if not entity.is_tgen:
                continue
            deleted.append(entity)

        for entity in deleted:
            entity.unlink()
            entity.make_standalone_reset()

        for entity in self.entities.values():
            if entity.is_tgen:
                if entity.hostile_type == 0:
                    raise NotImplementedError(self.step_index)
                continue
            entity.hostile_type = entity.old_hostile_type

        out_packets = tgen.get_out_packets()
        for chunk_items in iterate_packet_list(out_packets.chunk_items):
            chunk_pos = (chunk_items.chunk_x, chunk_items.chunk_y)
            chunk = self.chunks.get(chunk_pos, None)
            if chunk is None:
                continue
            for item_data in iterate_packet_list(chunk_items.data):
                chunk.add_item(item_data.data.copy())

        return out_packets

    def stop(self):
        with self.gen_queue.mutex:
            self.gen_queue.queue.clear()
        self.gen_queue.put(None)

    def get_chunk(self, pos):
        try:
            return self.chunks[pos]
        except KeyError:
            pass
        chunk = self.chunk_class(self, pos)
        self.chunks[pos] = chunk
        return chunk

    def get_data(self, pos):
        self.generating.add(pos)
        f = asyncio.Future()
        f.add_done_callback(lambda x: self.generating.remove(pos))
        self.gen_queue.put(('gen', pos, f), False)
        return f

    def get_height(self, pos):
        chunk_pos = get_chunk(pos)
        try:
            chunk = self.chunks[chunk_pos]
        except KeyError:
            return None
        if chunk.data is None:
            return None
        pos -= chunk_pos * constants.CHUNK_SCALE
        pos //= constants.BLOCK_SCALE
        return chunk.data.get_height(pos.x, pos.y) * constants.BLOCK_SCALE

    def run_gen(self, seed):
        tgen.initialize(seed, self.data_path)
        self.tgen_init = True
        while True:
            data = self.gen_queue.get()
            if data is None:
                break
            cmd = data[0]
            args = data[1:]
            if cmd == 'gen':
                pos, f = args
                # print('gen:', pos)
                res = tgen.generate(*pos)
                def set_result():
                    try:
                        f.set_result(res)
                    except asyncio.InvalidStateError:
                        return
                self.loop.call_soon_threadsafe(set_result)
            elif cmd == 'destroy_chunk':
                pos = args[0]
                # print('destroy chunk:', pos)
                self.chunk_lock.acquire()
                tgen.destroy_chunk(*pos)
                self.chunk_lock.release()
            elif cmd == 'destroy_region':
                pos = args[0]
                # print('destroy region:', pos)
                self.chunk_lock.acquire()
                tgen.destroy_region_seed(*pos)
                tgen.destroy_region_data(*pos)
                self.chunk_lock.release()
            else:
                raise NotImplementedError()