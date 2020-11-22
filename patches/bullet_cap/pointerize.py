#!/usr/bin/env python3

import sys
try:
    import binhack_helper
except ImportError:
    print('To run this script, you must add scripts/ to PYTHONPATH!', file=sys.stderr)
    sys.exit(1)

def main():
    game = binhack_helper.default_arg_parser(require_game=True).parse_args().game
    thc = binhack_helper.ThcrapGen('ExpHP.bullet-cap.')
    defs = binhack_helper.NasmDefs.from_file_rel('common.asm')

    add_main_binhacks(game, thc, defs)
    add_access_binhacks(game, thc, defs)

    thc.print()

def add_main_binhacks(game, thc, defs):
    # ===============================================
    # Binhacks that allocate the pointerized arrays.
    # These run in life before main.

    binhack_addr, jmp_addr, expected = {
        # start before bullets are initialized, and end after lasers are initialized
        'th06': (0x413496, 0x41353b, "c745d8c4050000"),
        'th07': (0x423388, 0x4233e5, "8b4de883e901"),
        'th08': (0x42f43c, 0x42f478, "6800f54200"),
    }[game]
    thc.binhack('pointerize-bullets-constructor', {
        'addr': binhack_addr,
        'expected': expected,
        'codecave': thc.asm(lambda c: f'''
            call {c.rel_auto('allocate-pointerized-bmgr-arrays')}
            {c.jmp(jmp_addr)}
        '''),
    })

    binhack_addr, jmp_addr, expected = {
        'th06': (0x41f240, 0x41f283, "c745e444010000"),
        'th07': (0x43264d, 0x43266f, "8b4df883e901"),
        'th08': (0x440017, 0x44002f, "6850004400"),
    }[game]
    thc.binhack('pointerize-items-constructor', {
        'addr': binhack_addr,
        'expected': expected,
        'codecave': thc.asm(lambda c: f'''
            call {c.rel_auto('allocate-pointerized-imgr-arrays')}
            {c.jmp(jmp_addr)}
        '''),
    })

    # ===============================================
    # Binhacks for where the structs get memset, so that we can save the pointers
    # and memset the arrays.

    binhack_addr, expected = {
        # replace the last two instructions of the memset (mov edi, ___; rep stosd)
        'th06': (0x41343f, "8b7dfc f3ab"),
        'th07': (0x4232ef, "8b7dfc f3ab"),
        'th08': (0x42f371, "8b7df4 f3ab"),
    }[game]
    thc.binhack('pointerize-bullets-memset', {
        'addr': binhack_addr,
        'expected': expected,
        'call-codecave': thc.asm(lambda c: f'''
            call {c.rel_auto('clear-pointerized-bullet-mgr')}
            ret
        '''),
    })

    binhack_addr, expected = {
        'th06': (0x41725a, "bf68e26900 f3ab"),
        'th07': (0x4275f8, "bf705c5700 f3ab"),
        'th08': (0x4337ff, "8b7dfc f3ab"),
    }[game]
    thc.binhack('pointerize-items-memset', {
        'addr': binhack_addr,
        'expected': expected,
        'call-codecave': thc.asm(lambda c: f'''
            call {c.rel_auto('clear-pointerized-item-mgr')}
            ret
        '''),
    })

    # nop out the call to BulletManager::reset in life before main.
    # It's hardly necessary, and will crash PCB/IN for small bullet caps because
    # we haven't done our search and replace hacks yet.
    thc.binhack('pointerize-bullets-nop', {
        'addr': { 'th06': 0x413552, 'th07': 0x423410, 'th08': 0x42f489 }[game],
        'code': '9090909090',
    })

# ===============================================
# Replacing all places that load the array.
def add_access_binhacks(game, thc, defs):
    if game == 'th06':
        bullet_manager_base = 0x5a5ff8
        bullet_array_offset = 0x5600
        laser_array_offset = 0xec000
    elif game == 'th07':
        bullet_manager_base = 0x62f958
        bullet_array_offset = 0xb8c0
        laser_array_offset = 0x366628
    elif game == 'th08':
        bullet_manager_base = 0xf54e90
        bullet_array_offset = 0x1a880
        laser_array_offset = 0x660938
    bullet_array_address = bullet_manager_base + bullet_array_offset
    laser_array_address = bullet_manager_base + laser_array_offset

    # Searching the binaries for the address of these arrays exclusively yields results that
    # write this value onto the stack.
    bullets_stack = thc.binhack_collection('pointerize-bullets-stack', lambda offset: {
        'expected': thc.asm(f'   mov  dword ptr [ebp-{offset:#x}], {bullet_array_address:#x}   '),
        'call-codecave': thc.asm(f'''
            mov  eax, [{bullet_array_address:#x}]
            mov  dword ptr [ebp-{offset:#x}], eax
            ret
        '''),
    })
    lasers_stack = thc.binhack_collection('pointerize-lasers-stack', lambda offset: {
        'expected': thc.asm(f'   mov  dword ptr [ebp-{offset:#x}], {laser_array_address:#x}   '),
        'call-codecave': thc.asm(f'''
            mov  eax, [{laser_array_address:#x}]
            mov  dword ptr [ebp-{offset:#x}], eax
            ret
        '''),
    })

    # Searching the binaries for the offsets of these arrays into bullet manager exclusively
    # yields results that read the bullet manager ptr from the stack, then add the offset.
    #
    # We can just replace the instructions that add the offset.
    bullets_reg = thc.binhack_collection('pointerize-bullets-reg', lambda reg: {
        'expected': thc.asm(f'   add  {reg}, {bullet_array_offset:#x}   '),
        'call-codecave': thc.asm(f'''
            mov  {reg}, [{bullet_array_address:#x}]
            ret
        '''),
    })
    lasers_reg = thc.binhack_collection('pointerize-lasers-reg', lambda reg: {
        'expected': thc.asm(f'   add  {reg}, {laser_array_offset:#x}   '),
        'call-codecave': thc.asm(f'''
            mov  {reg}, [{laser_array_address:#x}]
            ret
        '''),
    })

    if game == 'th06':
        bullets_stack.at(0x40b8e6, 0x08)  # Enemy::hardcoded_func_00
        bullets_stack.at(0x40c1c0, 0x14)  # Enemy::hardcoded_func_04
        bullets_stack.at(0x40d40e, 0x64)  # Enemy::hardcoded_func_08
        bullets_stack.at(0x40d537, 0x64)  # Enemy::hardcoded_func_09
        bullets_stack.at(0x40d777, 0x60)  # Enemy::hardcoded_func_11
        bullets_stack.at(0x40de11, 0x70)  # Enemy::hardcoded_func_15
        bullets_stack.at(0x40df04, 0x64)  # Enemy::hardcoded_func_15
        bullets_stack.at(0x41416a, 0x18)  # BulletManager::sub_414160_cancels
        bullets_stack.at(0x41437e, 0x18)  # BulletManager::sub_414360_cancels

        bullets_reg.at(0x4134a0, 'eax')  # BulletManager::constructor
        bullets_reg.at(0x413657, 'edx')  # BulletManager::shoot_one
        bullets_reg.at(0x4149dd, 'eax')  # BulletManager::on_tick_0b
        bullets_reg.at(0x416785, 'ecx')  # BulletManager::on_draw
        bullets_reg.at(0x4167e7, 'eax')  # BulletManager::on_draw
        bullets_reg.at(0x41686d, 'eax')  # BulletManager::on_draw
        bullets_reg.at(0x4168f3, 'eax')  # BulletManager::on_draw
        bullets_reg.at(0x41695a, 'edx')  # BulletManager::on_draw
        bullets_reg.at(0x4169bd, 'ecx')  # BulletManager::on_draw
        bullets_reg.at(0x416a42, 'ecx')  # BulletManager::on_draw
        bullets_reg.at(0x416ac7, 'ecx')  # BulletManager::on_draw

        lasers_reg.at(0x4134ef, 'ecx')  # BulletManager::constructor
        lasers_reg.at(0x4141f7, 'edx')  # BulletManager::sub_414160_cancels
        lasers_reg.at(0x414447, 'eax')  # BulletManager::sub_414360_cancels
        lasers_reg.at(0x41467c, 'eax')  # BulletManager::sub_414670_does_smn_to_lasers
        lasers_reg.at(0x415df7, 'eax')  # BulletManager::on_tick_0b
        lasers_reg.at(0x416521, 'eax')  # BulletManager::on_draw

    if game == 'th07':
        bullets_stack.at(0x417c3d, 0x08)  # Enemy::hardcoded_func_01_s2_call
        bullets_stack.at(0x417e66, 0xe8)  # Enemy::hardcoded_func_02_s2_call
        bullets_stack.at(0x418136, 0xe0)  # Enemy::hardcoded_func_04_s378_set
        bullets_stack.at(0x4182e6, 0xe0)  # Enemy::hardcoded_func_06_s3_call
        bullets_stack.at(0x41896a, 0x1c)  # Enemy::hardcoded_func_07_s4_set
        bullets_stack.at(0x418c45, 0x20)  # Enemy::hardcoded_func_08_s4_set
        bullets_stack.at(0x418ee0, 0x08)  # Enemy::hardcoded_func_10_s5678_call
        bullets_stack.at(0x418fcc, 0x0c)  # Enemy::hardcoded_func_11_s5678_call
        bullets_stack.at(0x419106, 0xe4)  # Enemy::hardcoded_func_12_s5_call
        bullets_stack.at(0x4194ec, 0x08)  # Enemy::hardcoded_func_13_s5_set
        bullets_stack.at(0x41961c, 0x08)  # Enemy::hardcoded_func_14_s5_call
        bullets_stack.at(0x419726, 0xe4)  # Enemy::hardcoded_func_16_s6_call
        bullets_stack.at(0x419897, 0x08)  # Enemy::hardcoded_func_17_s6_call
        bullets_stack.at(0x4199cc, 0x08)  # Enemy::hardcoded_func_18_s6_call
        bullets_stack.at(0x419a66, 0xe8)  # Enemy::hardcoded_func_21_s5_call_hl
        bullets_stack.at(0x419dd6, 0xe8)  # Enemy::hardcoded_func_22_s7_set
        bullets_stack.at(0x41a006, 0xe8)  # Enemy::hardcoded_func_23_s8_set
        bullets_stack.at(0x42474a, 0x18)  # BulletManager::sub_424740_cancels_bullets
        bullets_stack.at(0x4249be, 0x18)  # BulletManager::sub_4249a0_cancels_bullets
        bullets_stack.at(0x424c0a, 0x14)  # BulletManager::sub_424c00_cancels_bullets
        bullets_stack.at(0x4277a9, 0x08)  # BulletManager::sub_4277a0

        bullets_reg.at(0x4232f7, 'eax')  # BulletManager::reset
        bullets_reg.at(0x423380, 'eax')  # BulletManager::constructor
        bullets_reg.at(0x4237a3, 'edx')  # BulletManager::shoot_one
        bullets_reg.at(0x42423e, 'ecx')  # BulletManager::shoot_one
        bullets_reg.at(0x425a6c, 'eax')  # BulletManager::on_tick_0c

        lasers_stack.at(0x41888e, 0x20)  # Enemy::hardcoded_func_07_s4_set
        lasers_stack.at(0x418b4e, 0x28)  # Enemy::hardcoded_func_08_s4_set

        lasers_reg.at(0x4233bb, 'eax')  # BulletManager::constructor
        lasers_reg.at(0x42480a, 'eax')  # BulletManager::sub_424740_cancels_bullets
        lasers_reg.at(0x424a8a, 'edx')  # BulletManager::sub_4249a0_cancels_bullets
        lasers_reg.at(0x424e0c, 'eax')  # BulletManager::shoot_laser
        lasers_reg.at(0x4263c6, 'ecx')  # BulletManager::on_tick_0c
        lasers_reg.at(0x426c4c, 'eax')  # BulletManager::on_draw_0a

    if game == 'th08':
        bullets_stack.at(0x423a6c, 0x0c)  # Enemy::hardcoded_func_04_reimu
        bullets_stack.at(0x423e2c, 0x0c)  # Enemy::hardcoded_func_21_reimu
        bullets_stack.at(0x4241ec, 0x0c)  # Enemy::hardcoded_func_07_reimu
        bullets_stack.at(0x424a2c, 0x08)  # Enemy::hardcoded_func_12_reisen
        bullets_stack.at(0x424c4c, 0x08)  # Enemy::hardcoded_func_14_reisin
        bullets_stack.at(0x424e5c, 0x08)  # Enemy::hardcoded_func_16_eirin
        bullets_stack.at(0x4250dc, 0x08)  # Enemy::hardcoded_func_27_sakuya_lw
        bullets_stack.at(0x4251e6, 0x08)  # Enemy::hardcoded_func_28_youmu_lw
        bullets_stack.at(0x42529c, 0x0c)  # Enemy::hardcoded_func_29_youmu_lw
        bullets_stack.at(0x42f3a0, 0x08)  # BulletManager::reset
        bullets_stack.at(0x43083a, 0x1c)  # BulletManager::cancel_all
        bullets_stack.at(0x430abe, 0x18)  # BulletManager::sub_430aa0
        bullets_stack.at(0x430d3a, 0x14)  # BulletManager::ecl_161__cancel_radius?

        bullets_reg.at(0x42f379, 'eax')  # BulletManager::reset
        bullets_reg.at(0x42f44e, 'ecx')  # BulletManager::constructor
        bullets_reg.at(0x42f657, 'edx')  # BulletManager::shoot_one
        bullets_reg.at(0x42fe23, 'edx')  # BulletManager::shoot_one
        bullets_reg.at(0x431254, 'eax')  # BulletManager::on_tick

        lasers_reg.at(0x42f46c, 'edx')  # BulletManager::constructor
        lasers_reg.at(0x430941, 'edx')  # BulletManager::cancel_all
        lasers_reg.at(0x430bcb, 'eax')  # BulletManager::sub_430aa0
        lasers_reg.at(0x430f2c, 'eax')  # BulletManager::shoot_laser
        lasers_reg.at(0x431b75, 'eax')  # BulletManager::on_tick
        lasers_reg.at(0x432b7b, 'ecx')  # BulletManager::on_draw

    if game == 'th06':
        # TH06 has an index instead of a pointer for the next bullet, so BulletManager::shoot_one
        # has this at the beginning
        thc.binhack('pointerize-bullets-shoot-top', {
            'addr': 0x4135d7,
            'expected': thc.asm(f'   lea eax, [edx+ecx+{bullet_array_offset:#x}]   '),
            'call-codecave': thc.asm(f'''
                mov  eax, [{bullet_array_address:#x}]
                lea  eax, [eax+ecx]
                ret
            '''),
        })

    if game == 'th07':
        # TH07 memsets the bullet manager during GameManager::on_cleanup, which is...
        # unnecessary? And it deletes our pointers.
        thc.binhack('pointerize-dont-clear-bmgr-on-reset', {
            'addr': 0x42778e,
            'expected': 'f3ab', # rep stosd
            'code': '9090',
        })

    # ============================================
    # Tiny laser cap fixes

    # Normally bullet_cap uses its search-and-replace framework to substitute this sort of thing,
    # but the laser cap in th06 and th07 is so tiny that it sometimes gets optimized to a single byte.
    #
    # To make matters even worse, the 'cmp' intruction ends up being 4 bytes, too small to fit a jump,
    # so we also have to replace the 'jge'!
    if 'th06' <= game <= 'th07':
        old_laser_cap = {'th06': 0x40, 'th07': 0x40}[game]
        laser_cap = thc.binhack_collection('fix-laser-cap', lambda offset, br_not_taken, br_taken: {
            'expected': [
                thc.asm(f'cmp  dword ptr [ebp-{offset:#x}], {old_laser_cap:#x}'),
                '0f8d'  # first bytes of the jge; we can't easily get the whole thing because it's a relative address
            ],
            'codecave': thc.asm(lambda c: f'''
                push {defs.CAPID_LASER:#x}
                call {c.rel_auto('get-new-cap')}
                cmp  dword ptr [ebp-{offset:#x}], eax
                jl   skip
                {c.jmp(br_taken)}
            skip:
                {c.jmp(br_not_taken)}
            '''),
        })
        def add_laser_cap_binhack(address, offset, br_taken):
            br_not_taken = address + 4 + 6  # after the cmp and jge
            laser_cap.at(address, offset, br_not_taken=br_not_taken, br_taken=br_taken)

        if game == 'th06':
            add_laser_cap_binhack(0x41421e, 0x10, br_taken=0x41432b)  # BulletManager::sub_414160_cancels
            add_laser_cap_binhack(0x41446d, 0x10, br_taken=0x414593)  # BulletManager::sub_414360_cancels
            add_laser_cap_binhack(0x4146a2, 0x04, br_taken=0x4148e2)  # BulletManager::sub_414670_does_smn_to_lasers
            add_laser_cap_binhack(0x415e1d, 0x08, br_taken=0x416499)  # BulletManager::on_tick_0b
            add_laser_cap_binhack(0x416547, 0x04, br_taken=0x416769)  # BulletManager::on_draw

        if game == 'th07':
            add_laser_cap_binhack(0x4188b3, 0x24, br_taken=0x418b39)  # Enemy::hardcoded_func_07_s4_set
            add_laser_cap_binhack(0x418b73, 0x2c, br_taken=0x418e6e)  # Enemy::hardcoded_func_08_s4_set
            add_laser_cap_binhack(0x424830, 0x10, br_taken=0x424984)  # BulletManager::sub_424740_cancels_bullets
            add_laser_cap_binhack(0x424ab1, 0x10, br_taken=0x424be2)  # BulletManager::sub_4249a0_cancels_bullets
            add_laser_cap_binhack(0x424e56, 0x04, br_taken=0x4250bf)  # BulletManager::shoot_laser
            add_laser_cap_binhack(0x4263ec, 0x08, br_taken=0x426a4e)  # BulletManager::on_tick_0c
            add_laser_cap_binhack(0x426c72, 0x04, br_taken=0x426f03)  # BulletManager::on_draw_0a

    # ============================================
    # ItemManager stuff.
    #
    # This is trickier to find because the item array is at offset zero into the struct.
    # These were largely found by searching for appearances of the item cap.

    # Place where ItemManager::spawn_item gets an item to start at.
    item_spawn_top = thc.binhack_collection('pointerize-items-spawn', lambda imgr_offset: {
        'expected': [
            thc.asm(f'mov  edx, [ebp-{imgr_offset:#x}]'),
            '03d1',  # alternate encoding of 'add edx, ecx'
        ],
        'call-codecave': thc.asm(f'''
            mov  edx, [ebp-{imgr_offset:#x}]
            mov  edx, [edx]
            add  edx, ecx
            ret
        '''),
    })
    # Place where ItemManager::spawn_item loops to index 0.
    item_spawn_wrap = thc.binhack_collection(
        'pointerize-items-spawn-wrap',
        lambda imgr_offset, clobber: {
            'expected': thc.asm(f'''
                mov  {clobber}, [ebp-{imgr_offset:#x}]
                mov  [ebp-0x8], {clobber}
            '''),
            'call-codecave': thc.asm(f'''
                mov  {clobber}, [ebp-{imgr_offset:#x}]
                mov  {clobber}, [{clobber}]
                mov  [ebp-0x8], {clobber}
                ret
            '''),
        },
    )
    # Games before TH08 use the array in on_tick.
    item_tick = thc.binhack_collection('pointerize-item-tick', lambda imgr_offset, item_offset: {
        'expected': thc.asm(f'''
            mov  eax, [ebp-{imgr_offset:#x}]
            mov  [ebp-{item_offset:#x}], eax
        '''),
        'call-codecave': thc.asm(f'''
            mov  eax, [ebp-{imgr_offset:#x}]
            mov  eax, [eax]
            mov  [ebp-{item_offset:#x}], eax
            ret
        '''),
    })
    # Other places that use the array instead of the list prior to TH08.
    item_other = thc.binhack_collection('pointerize-item-other', lambda reg, count_offset, item_offset: {
        'expected': thc.asm(f'''
            mov  dword ptr [ebp-{item_offset:#x}], {reg}
            mov  dword ptr [ebp-{count_offset:#x}], 0x0
        '''),
        'call-codecave': thc.asm(f'''
            mov  {reg}, [{reg}]
            mov  dword ptr [ebp-{item_offset:#x}], {reg}
            mov  dword ptr [ebp-{count_offset:#x}], 0x0
            ret
        '''),
    })

    if game == 'th06':
        item_spawn_top.at(0x41f2a8, 0x18)
        item_spawn_wrap.at(0x41f30e, 0x18, clobber='edx')
        item_tick.at(0x41f4af, 0xcc, 0x14)
        item_other.at(0x42019c, 'eax', count_offset=0x08, item_offset=0x0c)  # ItemManager::on_draw
        item_other.at(0x42013c, 'eax', count_offset=0x04, item_offset=0x08)  # ItemManager::sub_420130
    if game == 'th07':
        item_spawn_top.at(0x432708, 0x18)
        item_spawn_wrap.at(0x432795, 0x18, clobber='eax')
        item_tick.at(0x4329a0, 0xcc, 0x24)
        item_other.at(0x433a9c, 'eax', count_offset=0x04, item_offset=0x08)
        item_other.at(0x433b2c, 'eax', count_offset=0x04, item_offset=0x08)
        item_other.at(0x433c4c, 'eax', count_offset=0x04, item_offset=0x08)
    if game == 'th08':
        item_spawn_top.at(0x4400b8, 0x0c)
        item_spawn_wrap.at(0x440196, 0x0c, clobber='ecx')

if __name__ == '__main__':
    main()
