# Copyright (c) Mathias Kaerlev 2013-2014.
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
Entity data read/write

NOTE: This file is automatically generated. Do not modify.
"""

cimport cython
from libc.stdint cimport int64_t, uint64_t
from cuwo.bytes cimport ByteReader, ByteWriter
from cuwo.vector import Vector3, qvec3, vec3, ivec3
from cuwo import strings


cdef class ItemUpgrade:
    cdef public:
        char x
        char y
        char z
        char material
        int level

    cpdef read(self, ByteReader reader):
        self.x = reader.read_int8()
        self.y = reader.read_int8()
        self.z = reader.read_int8()
        self.material = reader.read_int8()
        self.level = reader.read_int32()

    cpdef write(self, ByteWriter writer):
        writer.write_int8(self.x)
        writer.write_int8(self.y)
        writer.write_int8(self.z)
        writer.write_int8(self.material)
        writer.write_int32(self.level)


cdef class ItemData:
    cdef public:
        unsigned char type
        unsigned char sub_type
        unsigned int modifier
        unsigned int minus_modifier
        unsigned char rarity
        unsigned char material
        unsigned char flags
        short level
        list items
        unsigned int upgrade_count

    def __cinit__(self):
        self.items = []
        for _ in range(32):
            self.items.append(ItemUpgrade.__new__(ItemUpgrade))
        self.level = 1

    cpdef read(self, ByteReader reader):
        self.type = reader.read_uint8()
        self.sub_type = reader.read_uint8()
        reader.skip(2)
        self.modifier = reader.read_uint32()
        self.minus_modifier = reader.read_uint32()
        self.rarity = reader.read_uint8()
        self.material = reader.read_uint8()
        self.flags = reader.read_uint8()
        reader.skip(1)
        self.level = reader.read_int16()
        reader.skip(2)
        for i in range(32):
            (<ItemUpgrade>self.items[i]).read(reader)
        self.upgrade_count = reader.read_uint32()

    cpdef write(self, ByteWriter writer):
        writer.write_uint8(self.type)
        writer.write_uint8(self.sub_type)
        writer.pad(2)
        writer.write_uint32(self.modifier)
        writer.write_uint32(self.minus_modifier)
        writer.write_uint8(self.rarity)
        writer.write_uint8(self.material)
        writer.write_uint8(self.flags)
        writer.pad(1)
        writer.write_int16(self.level)
        writer.pad(2)
        for item in self.items:
            item.write(writer)
        writer.write_uint32(self.upgrade_count)


cdef class AppearanceData:
    cdef public:
        unsigned char not_used_1
        unsigned char not_used_2
        unsigned char hair_red
        unsigned char hair_green
        unsigned char hair_blue
        unsigned short flags
        object scale
        short head_model
        short hair_model
        short hand_model
        short foot_model
        short body_model
        short tail_model
        short shoulder2_model
        short wing_model
        double head_scale
        double body_scale
        double hand_scale
        double foot_scale
        double shoulder2_scale
        double weapon_scale
        double tail_scale
        double shoulder_scale
        double wing_scale
        double body_pitch
        double arm_pitch
        double arm_roll
        double arm_yaw
        double feet_pitch
        double wing_pitch
        double back_pitch
        object body_offset
        object head_offset
        object hand_offset
        object foot_offset
        object tail_offset
        object wing_offset

    def __cinit__(self):
        self.scale = vec3()
        self.body_offset = vec3()
        self.head_offset = vec3()
        self.hand_offset = vec3()
        self.foot_offset = vec3()
        self.tail_offset = vec3()
        self.wing_offset = vec3()
        self.hair_red = 255
        self.hair_green = 255
        self.hair_blue = 255
        self.head_model = -1
        self.hair_model = -1
        self.hand_model = -1
        self.foot_model = -1
        self.body_model = -1
        self.tail_model = -1
        self.shoulder2_model = -1
        self.wing_model = -1

    cpdef read(self, ByteReader reader):
        self.not_used_1 = reader.read_uint8()
        self.not_used_2 = reader.read_uint8()
        self.hair_red = reader.read_uint8()
        self.hair_green = reader.read_uint8()
        self.hair_blue = reader.read_uint8()
        reader.skip(1)
        self.flags = reader.read_uint16()
        self.scale = reader.read_vec3()
        self.head_model = reader.read_int16()
        self.hair_model = reader.read_int16()
        self.hand_model = reader.read_int16()
        self.foot_model = reader.read_int16()
        self.body_model = reader.read_int16()
        self.tail_model = reader.read_int16()
        self.shoulder2_model = reader.read_int16()
        self.wing_model = reader.read_int16()
        self.head_scale = reader.read_float()
        self.body_scale = reader.read_float()
        self.hand_scale = reader.read_float()
        self.foot_scale = reader.read_float()
        self.shoulder2_scale = reader.read_float()
        self.weapon_scale = reader.read_float()
        self.tail_scale = reader.read_float()
        self.shoulder_scale = reader.read_float()
        self.wing_scale = reader.read_float()
        self.body_pitch = reader.read_float()
        self.arm_pitch = reader.read_float()
        self.arm_roll = reader.read_float()
        self.arm_yaw = reader.read_float()
        self.feet_pitch = reader.read_float()
        self.wing_pitch = reader.read_float()
        self.back_pitch = reader.read_float()
        self.body_offset = reader.read_vec3()
        self.head_offset = reader.read_vec3()
        self.hand_offset = reader.read_vec3()
        self.foot_offset = reader.read_vec3()
        self.tail_offset = reader.read_vec3()
        self.wing_offset = reader.read_vec3()

    cpdef write(self, ByteWriter writer):
        writer.write_uint8(self.not_used_1)
        writer.write_uint8(self.not_used_2)
        writer.write_uint8(self.hair_red)
        writer.write_uint8(self.hair_green)
        writer.write_uint8(self.hair_blue)
        writer.pad(1)
        writer.write_uint16(self.flags)
        writer.write_vec3(self.scale)
        writer.write_int16(self.head_model)
        writer.write_int16(self.hair_model)
        writer.write_int16(self.hand_model)
        writer.write_int16(self.foot_model)
        writer.write_int16(self.body_model)
        writer.write_int16(self.tail_model)
        writer.write_int16(self.shoulder2_model)
        writer.write_int16(self.wing_model)
        writer.write_float(self.head_scale)
        writer.write_float(self.body_scale)
        writer.write_float(self.hand_scale)
        writer.write_float(self.foot_scale)
        writer.write_float(self.shoulder2_scale)
        writer.write_float(self.weapon_scale)
        writer.write_float(self.tail_scale)
        writer.write_float(self.shoulder_scale)
        writer.write_float(self.wing_scale)
        writer.write_float(self.body_pitch)
        writer.write_float(self.arm_pitch)
        writer.write_float(self.arm_roll)
        writer.write_float(self.arm_yaw)
        writer.write_float(self.feet_pitch)
        writer.write_float(self.wing_pitch)
        writer.write_float(self.back_pitch)
        writer.write_vec3(self.body_offset)
        writer.write_vec3(self.head_offset)
        writer.write_vec3(self.hand_offset)
        writer.write_vec3(self.foot_offset)
        writer.write_vec3(self.tail_offset)
        writer.write_vec3(self.wing_offset)

    def get_head(self):
        return strings.MODEL_NAMES[self.head_model]

    def set_head(self, name):
        self.head_model = strings.MODEL_IDS[name]

    def get_hair(self):
        return strings.MODEL_NAMES[self.hair_model]

    def set_hair(self, name):
        self.hair_model = strings.MODEL_IDS[name]

    def get_hand(self):
        return strings.MODEL_NAMES[self.hand_model]

    def set_hand(self, name):
        self.hand_model = strings.MODEL_IDS[name]

    def get_foot(self):
        return strings.MODEL_NAMES[self.foot_model]

    def set_foot(self, name):
        self.foot_model = strings.MODEL_IDS[name]

    def get_body(self):
        return strings.MODEL_NAMES[self.body_model]

    def set_body(self, name):
        self.body_model = strings.MODEL_IDS[name]

    def get_tail(self):
        return strings.MODEL_NAMES[self.tail_model]

    def set_tail(self, name):
        self.tail_model = strings.MODEL_IDS[name]

    def get_shoulder2(self):
        return strings.MODEL_NAMES[self.shoulder2_model]

    def set_shoulder2(self, name):
        self.shoulder2_model = strings.MODEL_IDS[name]

    def get_wing(self):
        return strings.MODEL_NAMES[self.wing_model]

    def set_wing(self, name):
        self.wing_model = strings.MODEL_IDS[name]


POS_BIT = 0
POS_FLAG = 0x1
ORIENT_BIT = 1
ORIENT_FLAG = 0x2
VEL_BIT = 2
VEL_FLAG = 0x4
ACCEL_BIT = 3
ACCEL_FLAG = 0x8
EXTRA_VEL_BIT = 4
EXTRA_VEL_FLAG = 0x10
LOOK_PITCH_BIT = 5
LOOK_PITCH_FLAG = 0x20
PHYSICS_BIT = 6
PHYSICS_FLAG = 0x40
HOSTILE_BIT = 7
HOSTILE_FLAG = 0x80
TYPE_BIT = 8
TYPE_FLAG = 0x100
MODE_BIT = 9
MODE_FLAG = 0x200
MODE_TIME_BIT = 10
MODE_TIME_FLAG = 0x400
HIT_COUNTER_BIT = 11
HIT_COUNTER_FLAG = 0x800
LAST_HIT_BIT = 12
LAST_HIT_FLAG = 0x1000
APPEARANCE_BIT = 13
APPEARANCE_FLAG = 0x2000
FLAGS_BIT = 14
FLAGS_FLAG = 0x4000
ROLL_BIT = 15
ROLL_FLAG = 0x8000
STUN_BIT = 16
STUN_FLAG = 0x10000
SLOWED_BIT = 17
SLOWED_FLAG = 0x20000
MAKE_BLUE_BIT = 18
MAKE_BLUE_FLAG = 0x40000
SPEED_UP_BIT = 19
SPEED_UP_FLAG = 0x80000
SHOW_PATCH_BIT = 20
SHOW_PATCH_FLAG = 0x100000
CLASS_BIT = 21
CLASS_FLAG = 0x200000
SPECIALIZATION_BIT = 22
SPECIALIZATION_FLAG = 0x400000
CHARGED_MP_BIT = 23
CHARGED_MP_FLAG = 0x800000
RAY_BIT = 26
RAY_FLAG = 0x4000000
HP_BIT = 27
HP_FLAG = 0x8000000
MP_BIT = 28
MP_FLAG = 0x10000000
BLOCK_POWER_BIT = 29
BLOCK_POWER_FLAG = 0x20000000
MULTIPLIER_BIT = 30
MULTIPLIER_FLAG = 0x40000000
LEVEL_BIT = 33
LEVEL_FLAG = 0x200000000
XP_BIT = 34
XP_FLAG = 0x400000000
OWNER_BIT = 35
OWNER_FLAG = 0x800000000
POWER_BASE_BIT = 37
POWER_BASE_FLAG = 0x2000000000
START_CHUNK_BIT = 39
START_CHUNK_FLAG = 0x8000000000
SPAWN_BIT = 40
SPAWN_FLAG = 0x10000000000
CONSUMABLE_BIT = 43
CONSUMABLE_FLAG = 0x80000000000
EQUIPMENT_BIT = 44
EQUIPMENT_FLAG = 0x100000000000
NAME_BIT = 45
NAME_FLAG = 0x200000000000
SKILL_BIT = 46
SKILL_FLAG = 0x400000000000
MANA_CUBES_BIT = 47
MANA_CUBES_FLAG = 0x800000000000


cdef class EntityData:
    cdef public:
        object pos
        double body_roll
        double body_pitch
        double body_yaw
        object velocity
        object accel
        object extra_vel
        double look_pitch
        unsigned int physics_flags
        unsigned char hostile_type
        unsigned int entity_type
        unsigned char current_mode
        unsigned int mode_start_time
        unsigned int hit_counter
        unsigned int last_hit_time
        AppearanceData appearance
        unsigned short flags
        unsigned int roll_time
        int stun_time
        unsigned int slowed_time
        unsigned int make_blue_time
        unsigned int speed_up_time
        double show_patch_time
        unsigned char class_type
        unsigned char specialization
        double charged_mp
        unsigned int not_used_1
        unsigned int not_used_2
        unsigned int not_used_3
        unsigned int not_used_4
        unsigned int not_used_5
        unsigned int not_used_6
        object ray_hit
        double hp
        double mp
        double block_power
        double max_hp_multiplier
        double shoot_speed
        double damage_multiplier
        double armor_multiplier
        double resi_multiplier
        unsigned char not_used7
        unsigned char not_used8
        int level
        int current_xp
        uint64_t parent_owner
        unsigned int unknown_or_not_used1
        unsigned int unknown_or_not_used2
        unsigned char power_base
        int unknown_or_not_used4
        object start_chunk
        unsigned int super_weird
        object spawn_pos
        unsigned char not_used19
        object not_used20
        ItemData consumable
        list equipment
        list skills
        unsigned int mana_cubes
        str name
        uint64_t mask

    def __cinit__(self):
        self.mask = 0
        self.equipment = []
        for _ in range(13):
            self.equipment.append(ItemData.__new__(ItemData))
        self.skills = []
        for _ in range(11):
            self.skills.append(0)
        self.pos = qvec3()
        self.velocity = vec3()
        self.accel = vec3()
        self.extra_vel = vec3()
        self.appearance = AppearanceData.__new__(AppearanceData)
        self.ray_hit = vec3()
        self.spawn_pos = qvec3()
        self.consumable = ItemData.__new__(ItemData)
        self.hostile_type = 3
        self.stun_time = -3000
        self.hp = 500
        self.max_hp_multiplier = 100
        self.damage_multiplier = 1
        self.armor_multiplier = 1
        self.resi_multiplier = 1
        self.unknown_or_not_used4 = -1
        self.start_chunk = (-1, -1, 0)
        self.not_used20 = (-1, -1, 0)
        self.name = ''

    cpdef read(self, ByteReader reader):
        self.pos = reader.read_qvec3()
        self.body_roll = reader.read_float()
        self.body_pitch = reader.read_float()
        self.body_yaw = reader.read_float()
        self.velocity = reader.read_vec3()
        self.accel = reader.read_vec3()
        self.extra_vel = reader.read_vec3()
        self.look_pitch = reader.read_float()
        self.physics_flags = reader.read_uint32()
        self.hostile_type = reader.read_uint8()
        reader.skip(3)
        self.entity_type = reader.read_uint32()
        self.current_mode = reader.read_uint8()
        reader.skip(3)
        self.mode_start_time = reader.read_uint32()
        self.hit_counter = reader.read_uint32()
        self.last_hit_time = reader.read_uint32()
        self.appearance.read(reader)
        self.flags = reader.read_uint16()
        reader.skip(2)
        self.roll_time = reader.read_uint32()
        self.stun_time = reader.read_int32()
        self.slowed_time = reader.read_uint32()
        self.make_blue_time = reader.read_uint32()
        self.speed_up_time = reader.read_uint32()
        self.show_patch_time = reader.read_float()
        self.class_type = reader.read_uint8()
        self.specialization = reader.read_uint8()
        reader.skip(2)
        self.charged_mp = reader.read_float()
        self.not_used_1 = reader.read_uint32()
        self.not_used_2 = reader.read_uint32()
        self.not_used_3 = reader.read_uint32()
        self.not_used_4 = reader.read_uint32()
        self.not_used_5 = reader.read_uint32()
        self.not_used_6 = reader.read_uint32()
        self.ray_hit = reader.read_vec3()
        self.hp = reader.read_float()
        self.mp = reader.read_float()
        self.block_power = reader.read_float()
        self.max_hp_multiplier = reader.read_float()
        self.shoot_speed = reader.read_float()
        self.damage_multiplier = reader.read_float()
        self.armor_multiplier = reader.read_float()
        self.resi_multiplier = reader.read_float()
        self.not_used7 = reader.read_uint8()
        self.not_used8 = reader.read_uint8()
        reader.skip(2)
        self.level = reader.read_int32()
        self.current_xp = reader.read_int32()
        self.parent_owner = reader.read_uint64()
        self.unknown_or_not_used1 = reader.read_uint32()
        self.unknown_or_not_used2 = reader.read_uint32()
        self.power_base = reader.read_uint8()
        reader.skip(3)
        self.unknown_or_not_used4 = reader.read_int32()
        self.start_chunk = reader.read_ivec3()
        self.super_weird = reader.read_uint32()
        self.spawn_pos = reader.read_qvec3()
        self.not_used19 = reader.read_uint8()
        reader.skip(3)
        self.not_used20 = reader.read_ivec3()
        self.consumable.read(reader)
        for i in range(13):
            (<ItemData>self.equipment[i]).read(reader)
        for i in range(11):
            self.skills[i] = reader.read_uint32()
        self.mana_cubes = reader.read_uint32()
        self.name = reader.read_ascii(16)

    cpdef write(self, ByteWriter writer):
        writer.write_qvec3(self.pos)
        writer.write_float(self.body_roll)
        writer.write_float(self.body_pitch)
        writer.write_float(self.body_yaw)
        writer.write_vec3(self.velocity)
        writer.write_vec3(self.accel)
        writer.write_vec3(self.extra_vel)
        writer.write_float(self.look_pitch)
        writer.write_uint32(self.physics_flags)
        writer.write_uint8(self.hostile_type)
        writer.pad(3)
        writer.write_uint32(self.entity_type)
        writer.write_uint8(self.current_mode)
        writer.pad(3)
        writer.write_uint32(self.mode_start_time)
        writer.write_uint32(self.hit_counter)
        writer.write_uint32(self.last_hit_time)
        self.appearance.write(writer)
        writer.write_uint16(self.flags)
        writer.pad(2)
        writer.write_uint32(self.roll_time)
        writer.write_int32(self.stun_time)
        writer.write_uint32(self.slowed_time)
        writer.write_uint32(self.make_blue_time)
        writer.write_uint32(self.speed_up_time)
        writer.write_float(self.show_patch_time)
        writer.write_uint8(self.class_type)
        writer.write_uint8(self.specialization)
        writer.pad(2)
        writer.write_float(self.charged_mp)
        writer.write_uint32(self.not_used_1)
        writer.write_uint32(self.not_used_2)
        writer.write_uint32(self.not_used_3)
        writer.write_uint32(self.not_used_4)
        writer.write_uint32(self.not_used_5)
        writer.write_uint32(self.not_used_6)
        writer.write_vec3(self.ray_hit)
        writer.write_float(self.hp)
        writer.write_float(self.mp)
        writer.write_float(self.block_power)
        writer.write_float(self.max_hp_multiplier)
        writer.write_float(self.shoot_speed)
        writer.write_float(self.damage_multiplier)
        writer.write_float(self.armor_multiplier)
        writer.write_float(self.resi_multiplier)
        writer.write_uint8(self.not_used7)
        writer.write_uint8(self.not_used8)
        writer.pad(2)
        writer.write_int32(self.level)
        writer.write_int32(self.current_xp)
        writer.write_uint64(self.parent_owner)
        writer.write_uint32(self.unknown_or_not_used1)
        writer.write_uint32(self.unknown_or_not_used2)
        writer.write_uint8(self.power_base)
        writer.pad(3)
        writer.write_int32(self.unknown_or_not_used4)
        writer.write_ivec3(self.start_chunk)
        writer.write_uint32(self.super_weird)
        writer.write_qvec3(self.spawn_pos)
        writer.write_uint8(self.not_used19)
        writer.pad(3)
        writer.write_ivec3(self.not_used20)
        self.consumable.write(writer)
        for item in self.equipment:
            item.write(writer)
        for item in self.skills:
            writer.write_uint32(item)
        writer.write_uint32(self.mana_cubes)
        writer.write_ascii(self.name, 16)


cpdef inline bint is_pos_set(uint64_t mask):
    return mask & (<uint64_t>1 << 0) != 0


cpdef inline bint is_orient_set(uint64_t mask):
    return mask & (<uint64_t>1 << 1) != 0


cpdef inline bint is_vel_set(uint64_t mask):
    return mask & (<uint64_t>1 << 2) != 0


cpdef inline bint is_accel_set(uint64_t mask):
    return mask & (<uint64_t>1 << 3) != 0


cpdef inline bint is_extra_vel_set(uint64_t mask):
    return mask & (<uint64_t>1 << 4) != 0


cpdef inline bint is_look_pitch_set(uint64_t mask):
    return mask & (<uint64_t>1 << 5) != 0


cpdef inline bint is_physics_set(uint64_t mask):
    return mask & (<uint64_t>1 << 6) != 0


cpdef inline bint is_hostile_set(uint64_t mask):
    return mask & (<uint64_t>1 << 7) != 0


cpdef inline bint is_type_set(uint64_t mask):
    return mask & (<uint64_t>1 << 8) != 0


cpdef inline bint is_mode_set(uint64_t mask):
    return mask & (<uint64_t>1 << 9) != 0


cpdef inline bint is_mode_time_set(uint64_t mask):
    return mask & (<uint64_t>1 << 10) != 0


cpdef inline bint is_hit_counter_set(uint64_t mask):
    return mask & (<uint64_t>1 << 11) != 0


cpdef inline bint is_last_hit_set(uint64_t mask):
    return mask & (<uint64_t>1 << 12) != 0


cpdef inline bint is_appearance_set(uint64_t mask):
    return mask & (<uint64_t>1 << 13) != 0


cpdef inline bint is_flags_set(uint64_t mask):
    return mask & (<uint64_t>1 << 14) != 0


cpdef inline bint is_roll_set(uint64_t mask):
    return mask & (<uint64_t>1 << 15) != 0


cpdef inline bint is_stun_set(uint64_t mask):
    return mask & (<uint64_t>1 << 16) != 0


cpdef inline bint is_slowed_set(uint64_t mask):
    return mask & (<uint64_t>1 << 17) != 0


cpdef inline bint is_make_blue_set(uint64_t mask):
    return mask & (<uint64_t>1 << 18) != 0


cpdef inline bint is_speed_up_set(uint64_t mask):
    return mask & (<uint64_t>1 << 19) != 0


cpdef inline bint is_show_patch_set(uint64_t mask):
    return mask & (<uint64_t>1 << 20) != 0


cpdef inline bint is_class_set(uint64_t mask):
    return mask & (<uint64_t>1 << 21) != 0


cpdef inline bint is_specialization_set(uint64_t mask):
    return mask & (<uint64_t>1 << 22) != 0


cpdef inline bint is_charged_mp_set(uint64_t mask):
    return mask & (<uint64_t>1 << 23) != 0


cpdef inline bint is_ray_set(uint64_t mask):
    return mask & (<uint64_t>1 << 26) != 0


cpdef inline bint is_hp_set(uint64_t mask):
    return mask & (<uint64_t>1 << 27) != 0


cpdef inline bint is_mp_set(uint64_t mask):
    return mask & (<uint64_t>1 << 28) != 0


cpdef inline bint is_block_power_set(uint64_t mask):
    return mask & (<uint64_t>1 << 29) != 0


cpdef inline bint is_multiplier_set(uint64_t mask):
    return mask & (<uint64_t>1 << 30) != 0


cpdef inline bint is_level_set(uint64_t mask):
    return mask & (<uint64_t>1 << 33) != 0


cpdef inline bint is_xp_set(uint64_t mask):
    return mask & (<uint64_t>1 << 34) != 0


cpdef inline bint is_owner_set(uint64_t mask):
    return mask & (<uint64_t>1 << 35) != 0


cpdef inline bint is_power_base_set(uint64_t mask):
    return mask & (<uint64_t>1 << 37) != 0


cpdef inline bint is_start_chunk_set(uint64_t mask):
    return mask & (<uint64_t>1 << 39) != 0


cpdef inline bint is_spawn_set(uint64_t mask):
    return mask & (<uint64_t>1 << 40) != 0


cpdef inline bint is_consumable_set(uint64_t mask):
    return mask & (<uint64_t>1 << 43) != 0


cpdef inline bint is_equipment_set(uint64_t mask):
    return mask & (<uint64_t>1 << 44) != 0


cpdef inline bint is_name_set(uint64_t mask):
    return mask & (<uint64_t>1 << 45) != 0


cpdef inline bint is_skill_set(uint64_t mask):
    return mask & (<uint64_t>1 << 46) != 0


cpdef inline bint is_mana_cubes_set(uint64_t mask):
    return mask & (<uint64_t>1 << 47) != 0


cpdef uint64_t read_masked_data(EntityData entity, ByteReader reader):
    cdef uint64_t mask = reader.read_uint64()
    if mask & (<uint64_t>1 << 0) != 0:
        entity.pos = reader.read_qvec3()
    if mask & (<uint64_t>1 << 1) != 0:
        entity.body_roll = reader.read_float()
        entity.body_pitch = reader.read_float()
        entity.body_yaw = reader.read_float()
    if mask & (<uint64_t>1 << 2) != 0:
        entity.velocity = reader.read_vec3()
    if mask & (<uint64_t>1 << 3) != 0:
        entity.accel = reader.read_vec3()
    if mask & (<uint64_t>1 << 4) != 0:
        entity.extra_vel = reader.read_vec3()
    if mask & (<uint64_t>1 << 5) != 0:
        entity.look_pitch = reader.read_float()
    if mask & (<uint64_t>1 << 6) != 0:
        entity.physics_flags = reader.read_uint32()
    if mask & (<uint64_t>1 << 7) != 0:
        entity.hostile_type = reader.read_uint8()
    if mask & (<uint64_t>1 << 8) != 0:
        entity.entity_type = reader.read_uint32()
    if mask & (<uint64_t>1 << 9) != 0:
        entity.current_mode = reader.read_uint8()
    if mask & (<uint64_t>1 << 10) != 0:
        entity.mode_start_time = reader.read_uint32()
    if mask & (<uint64_t>1 << 11) != 0:
        entity.hit_counter = reader.read_uint32()
    if mask & (<uint64_t>1 << 12) != 0:
        entity.last_hit_time = reader.read_uint32()
    if mask & (<uint64_t>1 << 13) != 0:
        entity.appearance.read(reader)
    if mask & (<uint64_t>1 << 14) != 0:
        entity.flags = reader.read_uint16()
    if mask & (<uint64_t>1 << 15) != 0:
        entity.roll_time = reader.read_uint32()
    if mask & (<uint64_t>1 << 16) != 0:
        entity.stun_time = reader.read_int32()
    if mask & (<uint64_t>1 << 17) != 0:
        entity.slowed_time = reader.read_uint32()
    if mask & (<uint64_t>1 << 18) != 0:
        entity.make_blue_time = reader.read_uint32()
    if mask & (<uint64_t>1 << 19) != 0:
        entity.speed_up_time = reader.read_uint32()
    if mask & (<uint64_t>1 << 20) != 0:
        entity.show_patch_time = reader.read_float()
    if mask & (<uint64_t>1 << 21) != 0:
        entity.class_type = reader.read_uint8()
    if mask & (<uint64_t>1 << 22) != 0:
        entity.specialization = reader.read_uint8()
    if mask & (<uint64_t>1 << 23) != 0:
        entity.charged_mp = reader.read_float()
    if mask & (<uint64_t>1 << 24) != 0:
        entity.not_used_1 = reader.read_uint32()
        entity.not_used_2 = reader.read_uint32()
        entity.not_used_3 = reader.read_uint32()
    if mask & (<uint64_t>1 << 25) != 0:
        entity.not_used_4 = reader.read_uint32()
        entity.not_used_5 = reader.read_uint32()
        entity.not_used_6 = reader.read_uint32()
    if mask & (<uint64_t>1 << 26) != 0:
        entity.ray_hit = reader.read_vec3()
    if mask & (<uint64_t>1 << 27) != 0:
        entity.hp = reader.read_float()
    if mask & (<uint64_t>1 << 28) != 0:
        entity.mp = reader.read_float()
    if mask & (<uint64_t>1 << 29) != 0:
        entity.block_power = reader.read_float()
    if mask & (<uint64_t>1 << 30) != 0:
        entity.max_hp_multiplier = reader.read_float()
        entity.shoot_speed = reader.read_float()
        entity.damage_multiplier = reader.read_float()
        entity.armor_multiplier = reader.read_float()
        entity.resi_multiplier = reader.read_float()
    if mask & (<uint64_t>1 << 31) != 0:
        entity.not_used7 = reader.read_uint8()
    if mask & (<uint64_t>1 << 32) != 0:
        entity.not_used8 = reader.read_uint8()
    if mask & (<uint64_t>1 << 33) != 0:
        entity.level = reader.read_int32()
    if mask & (<uint64_t>1 << 34) != 0:
        entity.current_xp = reader.read_int32()
    if mask & (<uint64_t>1 << 35) != 0:
        entity.parent_owner = reader.read_uint64()
    if mask & (<uint64_t>1 << 36) != 0:
        entity.unknown_or_not_used1 = reader.read_uint32()
        entity.unknown_or_not_used2 = reader.read_uint32()
    if mask & (<uint64_t>1 << 37) != 0:
        entity.power_base = reader.read_uint8()
    if mask & (<uint64_t>1 << 38) != 0:
        entity.unknown_or_not_used4 = reader.read_int32()
    if mask & (<uint64_t>1 << 39) != 0:
        entity.start_chunk = reader.read_ivec3()
    if mask & (<uint64_t>1 << 40) != 0:
        entity.spawn_pos = reader.read_qvec3()
    if mask & (<uint64_t>1 << 41) != 0:
        entity.not_used20 = reader.read_ivec3()
    if mask & (<uint64_t>1 << 42) != 0:
        entity.not_used19 = reader.read_uint8()
    if mask & (<uint64_t>1 << 43) != 0:
        entity.consumable.read(reader)
    if mask & (<uint64_t>1 << 44) != 0:
        for item in entity.equipment:
            (<ItemData>item).read(reader)
    if mask & (<uint64_t>1 << 45) != 0:
        entity.name = reader.read_ascii(16)
    if mask & (<uint64_t>1 << 46) != 0:
        entity.skills = []
        for _ in xrange(11):
            entity.skills.append(reader.read_uint32())
    if mask & (<uint64_t>1 << 47) != 0:
        entity.mana_cubes = reader.read_uint32()

    return mask


cpdef unsigned int get_masked_size(uint64_t mask):
    cdef unsigned int size = 0
    if mask & (<uint64_t>1 << 0) != 0:
        size += 24
    if mask & (<uint64_t>1 << 1) != 0:
        size += 12
    if mask & (<uint64_t>1 << 2) != 0:
        size += 12
    if mask & (<uint64_t>1 << 3) != 0:
        size += 12
    if mask & (<uint64_t>1 << 4) != 0:
        size += 12
    if mask & (<uint64_t>1 << 5) != 0:
        size += 4
    if mask & (<uint64_t>1 << 6) != 0:
        size += 4
    if mask & (<uint64_t>1 << 7) != 0:
        size += 1
    if mask & (<uint64_t>1 << 8) != 0:
        size += 4
    if mask & (<uint64_t>1 << 9) != 0:
        size += 1
    if mask & (<uint64_t>1 << 10) != 0:
        size += 4
    if mask & (<uint64_t>1 << 11) != 0:
        size += 4
    if mask & (<uint64_t>1 << 12) != 0:
        size += 4
    if mask & (<uint64_t>1 << 13) != 0:
        size += 172
    if mask & (<uint64_t>1 << 14) != 0:
        size += 2
    if mask & (<uint64_t>1 << 15) != 0:
        size += 4
    if mask & (<uint64_t>1 << 16) != 0:
        size += 4
    if mask & (<uint64_t>1 << 17) != 0:
        size += 4
    if mask & (<uint64_t>1 << 18) != 0:
        size += 4
    if mask & (<uint64_t>1 << 19) != 0:
        size += 4
    if mask & (<uint64_t>1 << 20) != 0:
        size += 4
    if mask & (<uint64_t>1 << 21) != 0:
        size += 1
    if mask & (<uint64_t>1 << 22) != 0:
        size += 1
    if mask & (<uint64_t>1 << 23) != 0:
        size += 4
    if mask & (<uint64_t>1 << 24) != 0:
        size += 12
    if mask & (<uint64_t>1 << 25) != 0:
        size += 12
    if mask & (<uint64_t>1 << 26) != 0:
        size += 12
    if mask & (<uint64_t>1 << 27) != 0:
        size += 4
    if mask & (<uint64_t>1 << 28) != 0:
        size += 4
    if mask & (<uint64_t>1 << 29) != 0:
        size += 4
    if mask & (<uint64_t>1 << 30) != 0:
        size += 20
    if mask & (<uint64_t>1 << 31) != 0:
        size += 1
    if mask & (<uint64_t>1 << 32) != 0:
        size += 1
    if mask & (<uint64_t>1 << 33) != 0:
        size += 4
    if mask & (<uint64_t>1 << 34) != 0:
        size += 4
    if mask & (<uint64_t>1 << 35) != 0:
        size += 8
    if mask & (<uint64_t>1 << 36) != 0:
        size += 8
    if mask & (<uint64_t>1 << 37) != 0:
        size += 1
    if mask & (<uint64_t>1 << 38) != 0:
        size += 4
    if mask & (<uint64_t>1 << 39) != 0:
        size += 12
    if mask & (<uint64_t>1 << 40) != 0:
        size += 24
    if mask & (<uint64_t>1 << 41) != 0:
        size += 12
    if mask & (<uint64_t>1 << 42) != 0:
        size += 1
    if mask & (<uint64_t>1 << 43) != 0:
        size += 280
    if mask & (<uint64_t>1 << 44) != 0:
        size += 3640
    if mask & (<uint64_t>1 << 45) != 0:
        size += 16
    if mask & (<uint64_t>1 << 46) != 0:
        size += 44
    if mask & (<uint64_t>1 << 47) != 0:
        size += 4
    return size


cpdef write_masked_data(EntityData entity, ByteWriter writer, uint64_t mask):
    writer.write_uint64(mask)
    if mask & (<uint64_t>1 << 0) != 0:
        writer.write_qvec3(entity.pos)
    if mask & (<uint64_t>1 << 1) != 0:
        writer.write_float(entity.body_roll)
        writer.write_float(entity.body_pitch)
        writer.write_float(entity.body_yaw)
    if mask & (<uint64_t>1 << 2) != 0:
        writer.write_vec3(entity.velocity)
    if mask & (<uint64_t>1 << 3) != 0:
        writer.write_vec3(entity.accel)
    if mask & (<uint64_t>1 << 4) != 0:
        writer.write_vec3(entity.extra_vel)
    if mask & (<uint64_t>1 << 5) != 0:
        writer.write_float(entity.look_pitch)
    if mask & (<uint64_t>1 << 6) != 0:
        writer.write_uint32(entity.physics_flags)
    if mask & (<uint64_t>1 << 7) != 0:
        writer.write_uint8(entity.hostile_type)
    if mask & (<uint64_t>1 << 8) != 0:
        writer.write_uint32(entity.entity_type)
    if mask & (<uint64_t>1 << 9) != 0:
        writer.write_uint8(entity.current_mode)
    if mask & (<uint64_t>1 << 10) != 0:
        writer.write_uint32(entity.mode_start_time)
    if mask & (<uint64_t>1 << 11) != 0:
        writer.write_uint32(entity.hit_counter)
    if mask & (<uint64_t>1 << 12) != 0:
        writer.write_uint32(entity.last_hit_time)
    if mask & (<uint64_t>1 << 13) != 0:
        entity.appearance.write(writer)
    if mask & (<uint64_t>1 << 14) != 0:
        writer.write_uint16(entity.flags)
    if mask & (<uint64_t>1 << 15) != 0:
        writer.write_uint32(entity.roll_time)
    if mask & (<uint64_t>1 << 16) != 0:
        writer.write_int32(entity.stun_time)
    if mask & (<uint64_t>1 << 17) != 0:
        writer.write_uint32(entity.slowed_time)
    if mask & (<uint64_t>1 << 18) != 0:
        writer.write_uint32(entity.make_blue_time)
    if mask & (<uint64_t>1 << 19) != 0:
        writer.write_uint32(entity.speed_up_time)
    if mask & (<uint64_t>1 << 20) != 0:
        writer.write_float(entity.show_patch_time)
    if mask & (<uint64_t>1 << 21) != 0:
        writer.write_uint8(entity.class_type)
    if mask & (<uint64_t>1 << 22) != 0:
        writer.write_uint8(entity.specialization)
    if mask & (<uint64_t>1 << 23) != 0:
        writer.write_float(entity.charged_mp)
    if mask & (<uint64_t>1 << 24) != 0:
        writer.write_uint32(entity.not_used_1)
        writer.write_uint32(entity.not_used_2)
        writer.write_uint32(entity.not_used_3)
    if mask & (<uint64_t>1 << 25) != 0:
        writer.write_uint32(entity.not_used_4)
        writer.write_uint32(entity.not_used_5)
        writer.write_uint32(entity.not_used_6)
    if mask & (<uint64_t>1 << 26) != 0:
        writer.write_vec3(entity.ray_hit)
    if mask & (<uint64_t>1 << 27) != 0:
        writer.write_float(entity.hp)
    if mask & (<uint64_t>1 << 28) != 0:
        writer.write_float(entity.mp)
    if mask & (<uint64_t>1 << 29) != 0:
        writer.write_float(entity.block_power)
    if mask & (<uint64_t>1 << 30) != 0:
        writer.write_float(entity.max_hp_multiplier)
        writer.write_float(entity.shoot_speed)
        writer.write_float(entity.damage_multiplier)
        writer.write_float(entity.armor_multiplier)
        writer.write_float(entity.resi_multiplier)
    if mask & (<uint64_t>1 << 31) != 0:
        writer.write_uint8(entity.not_used7)
    if mask & (<uint64_t>1 << 32) != 0:
        writer.write_uint8(entity.not_used8)
    if mask & (<uint64_t>1 << 33) != 0:
        writer.write_int32(entity.level)
    if mask & (<uint64_t>1 << 34) != 0:
        writer.write_int32(entity.current_xp)
    if mask & (<uint64_t>1 << 35) != 0:
        writer.write_uint64(entity.parent_owner)
    if mask & (<uint64_t>1 << 36) != 0:
        writer.write_uint32(entity.unknown_or_not_used1)
        writer.write_uint32(entity.unknown_or_not_used2)
    if mask & (<uint64_t>1 << 37) != 0:
        writer.write_uint8(entity.power_base)
    if mask & (<uint64_t>1 << 38) != 0:
        writer.write_int32(entity.unknown_or_not_used4)
    if mask & (<uint64_t>1 << 39) != 0:
        writer.write_ivec3(entity.start_chunk)
    if mask & (<uint64_t>1 << 40) != 0:
        writer.write_qvec3(entity.spawn_pos)
    if mask & (<uint64_t>1 << 41) != 0:
        writer.write_ivec3(entity.not_used20)
    if mask & (<uint64_t>1 << 42) != 0:
        writer.write_uint8(entity.not_used19)
    if mask & (<uint64_t>1 << 43) != 0:
        entity.consumable.write(writer)
    if mask & (<uint64_t>1 << 44) != 0:
        for item in entity.equipment:
            (<ItemData>item).write(writer)
    if mask & (<uint64_t>1 << 45) != 0:
        writer.write_ascii(entity.name, 16)
    if mask & (<uint64_t>1 << 46) != 0:
        for item in entity.skills:
            writer.write_uint32(item)
    if mask & (<uint64_t>1 << 47) != 0:
        writer.write_uint32(entity.mana_cubes)
