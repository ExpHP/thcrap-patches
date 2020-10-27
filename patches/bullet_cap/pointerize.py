#!/usr/bin/env python3

import sys
try:
    import binhack_helper
except ImportError:
    print('To run this script, you must add scripts/ to PYTHONPATH!', file=sys.stderr)
    sys.exit(1)

def main():
    args = binhack_helper.default_arg_parser(require_game=True).parse_args()
    game = args.game

    thc = binhack_helper.ThcrapGen('ExpHP.bullet-cap.')

    if 'th07' <= game <= 'th08':
        add_main_binhacks(game, thc)
        add_access_binhacks(game, thc)

    from ruamel.yaml import YAML
    yaml = YAML(typ='unsafe')
    yaml.dump(thc.cereal(), sys.stdout)

def add_main_binhacks(game, thc):
    # ===============================================
    # Binhacks that allocate the pointerized arrays.
    # These run in life before main.

    binhack_addr, jmp_addr, expected = {
        # start before bullets are initialized, and end after lasers are initialized
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
    # It's hardly necessary, and will crash for small bullet caps because
    # we haven't done our search and replace hacks yet.
    thc.binhack('pointerize-bullets-nop', {
        'addr': { 'th07': 0x423410, 'th08': 0x42f489 }[game],
        'code': '9090909090',
    })

# ===============================================
# Replacing all places that load the array.
def add_access_binhacks(game, thc):
    if game == 'th07':
        bullet_manager_base = 0x62f958
        bullet_array_offset = 0xb8c0
        laser_array_offset = 0x366628
        bullet_array_address = bullet_manager_base + bullet_array_offset
        laser_array_address = bullet_manager_base + laser_array_offset
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

    if game == 'th07':
        bullets_stack(0x08).at(0x417c3d)  # Enemy::hardcoded_func_01_s2_call
        bullets_stack(0xe8).at(0x417e66)  # Enemy::hardcoded_func_02_s2_call
        bullets_stack(0xe0).at(0x418136)  # Enemy::hardcoded_func_04_s378_set
        bullets_stack(0xe0).at(0x4182e6)  # Enemy::hardcoded_func_06_s3_call
        bullets_stack(0x1c).at(0x41896a)  # Enemy::hardcoded_func_07_s4_set
        bullets_stack(0x20).at(0x418c45)  # Enemy::hardcoded_func_08_s4_set
        bullets_stack(0x08).at(0x418ee0)  # Enemy::hardcoded_func_10_s5678_call
        bullets_stack(0x0c).at(0x418fcc)  # Enemy::hardcoded_func_11_s5678_call
        bullets_stack(0xe4).at(0x419106)  # Enemy::hardcoded_func_12_s5_call
        bullets_stack(0x08).at(0x4194ec)  # Enemy::hardcoded_func_13_s5_set
        bullets_stack(0x08).at(0x41961c)  # Enemy::hardcoded_func_14_s5_call
        bullets_stack(0xe4).at(0x419726)  # Enemy::hardcoded_func_16_s6_call
        bullets_stack(0x08).at(0x419897)  # Enemy::hardcoded_func_17_s6_call
        bullets_stack(0x08).at(0x4199cc)  # Enemy::hardcoded_func_18_s6_call
        bullets_stack(0xe8).at(0x419a66)  # Enemy::hardcoded_func_21_s5_call_hl
        bullets_stack(0xe8).at(0x419dd6)  # Enemy::hardcoded_func_22_s7_set
        bullets_stack(0xe8).at(0x41a006)  # Enemy::hardcoded_func_23_s8_set
        bullets_stack(0x18).at(0x42474a)  # BulletManager::sub_424740_cancels_bullets
        bullets_stack(0x18).at(0x4249be)  # BulletManager::sub_4249a0_cancels_bullets
        bullets_stack(0x14).at(0x424c0a)  # BulletManager::sub_424c00_cancels_bullets
        bullets_stack(0x08).at(0x4277a9)  # BulletManager::sub_4277a0

        bullets_reg('eax').at(0x4232f7)  # BulletManager::reset
        bullets_reg('eax').at(0x423380)  # BulletManager::constructor
        bullets_reg('edx').at(0x4237a3)  # BulletManager::shoot_one
        bullets_reg('ecx').at(0x42423e)  # BulletManager::shoot_one
        bullets_reg('eax').at(0x425a6c)  # BulletManager::on_tick_0c

        lasers_stack(0x20).at(0x41888e)  # Enemy::hardcoded_func_07_s4_set
        lasers_stack(0x28).at(0x418b4e)  # Enemy::hardcoded_func_08_s4_set

        lasers_reg('eax').at(0x4233bb)  # BulletManager::constructor
        lasers_reg('eax').at(0x42480a)  # BulletManager::sub_424740_cancels_bullets
        lasers_reg('edx').at(0x424a8a)  # BulletManager::sub_4249a0_cancels_bullets
        lasers_reg('eax').at(0x424e0c)  # BulletManager::shoot_laser
        lasers_reg('ecx').at(0x4263c6)  # BulletManager::on_tick_0c
        lasers_reg('eax').at(0x426c4c)  # BulletManager::on_draw_0a

    if game == 'th08':
        bullets_stack(0x0c).at(0x423a6c)  # Enemy::hardcoded_func_04_reimu
        bullets_stack(0x0c).at(0x423e2c)  # Enemy::hardcoded_func_21_reimu
        bullets_stack(0x0c).at(0x4241ec)  # Enemy::hardcoded_func_07_reimu
        bullets_stack(0x08).at(0x424a2c)  # Enemy::hardcoded_func_12_reisen
        bullets_stack(0x08).at(0x424c4c)  # Enemy::hardcoded_func_14_reisin
        bullets_stack(0x08).at(0x424e5c)  # Enemy::hardcoded_func_16_eirin
        bullets_stack(0x08).at(0x4250dc)  # Enemy::hardcoded_func_27_sakuya_lw
        bullets_stack(0x08).at(0x4251e6)  # Enemy::hardcoded_func_28_youmu_lw
        bullets_stack(0x0c).at(0x42529c)  # Enemy::hardcoded_func_29_youmu_lw
        bullets_stack(0x08).at(0x42f3a0)  # BulletManager::reset
        bullets_stack(0x1c).at(0x43083a)  # BulletManager::cancel_all
        bullets_stack(0x18).at(0x430abe)  # BulletManager::sub_430aa0
        bullets_stack(0x14).at(0x430d3a)  # BulletManager::ecl_161__cancel_radius?

        bullets_reg('eax').at(0x42f379)  # BulletManager::reset
        bullets_reg('ecx').at(0x42f44e)  # BulletManager::constructor
        bullets_reg('edx').at(0x42f657)  # BulletManager::shoot_one
        bullets_reg('edx').at(0x42fe23)  # BulletManager::shoot_one
        bullets_reg('eax').at(0x431254)  # BulletManager::on_tick

        lasers_reg('edx').at(0x42f46c)  # BulletManager::constructor
        lasers_reg('edx').at(0x430941)  # BulletManager::cancel_all
        lasers_reg('eax').at(0x430bcb)  # BulletManager::sub_430aa0
        lasers_reg('eax').at(0x430f2c)  # BulletManager::shoot_laser
        lasers_reg('eax').at(0x431b75)  # BulletManager::on_tick
        lasers_reg('ecx').at(0x432b7b)  # BulletManager::on_draw

    # ============================================
    # Tiny laser cap fixes

    # Normally bullet_cap uses its search-and-replace framework to substitute this sort of thing,
    # but the laser cap in th06 and th07 is so tiny that it sometimes gets optimized to a single byte.
    #
    # To make matters even worse, the 'cmp' intruction ends up being 4 bytes, too small to fit a call,
    # so we also have to replace the 'jge'!

    # FIXME: replace the 'jge'
    # if game == 'th07':
    #     laser_cap = thc.binhack_collection('fix-laser-cap', lambda offset: {
    #         'expected': thc.asm(f'''
    #             cmp  dword ptr [ebp-{offset}], 0x40
    #         '''),
    #         'call-codecave': thc.asm(lambda c: f'''
    #             mov  eax, {c.abs_global('bullet-cap')}
    #             mov  eax, [eax]
    #             bswap eax
    #             cmp  dword ptr [ebp-{offset}], eax
    #             ret
    #         '''),
    #     })
    #     laser_cap(0x24).at(0x4188b7)  # Enemy::hardcoded_func_07_s4_set
    #     laser_cap(0x2c).at(0x418b77)  # Enemy::hardcoded_func_08_s4_set
    #     laser_cap(0x10).at(0x424834)  # BulletManager::sub_424740_cancels_bullets
    #     laser_cap(0x10).at(0x424ab5)  # BulletManager::sub_4249a0_cancels_bullets
    #     laser_cap(0x04).at(0x424e5a)  # BulletManager::shoot_laser
    #     laser_cap(0x08).at(0x4263f0)  # BulletManager::on_tick_0c
    #     laser_cap(0x04).at(0x426c76)  # BulletManager::on_draw_0a

    # ============================================
    # ItemManager stuff.
    #
    # This is trickier to find because the item array is at offset zero into the struct.
    # These were largely found by searching for appearances of the item cap.

    # Place where ItemManager::spawn_item gets an item to start at.
    item_spawn_top = thc.binhack_collection('pointerize-items-spawn', lambda imgr_offset: {
        'expected': thc.asm(f'''
            mov  edx, [ebp-{imgr_offset:#x}]
        ''') + '03d1',  # alternate encoding of 'add edx, ecx'
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
        lambda clobber, imgr_offset: {
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

    if game == 'th07':
        item_spawn_top(0x18).at(0x432708)
        item_spawn_wrap('eax', 0x18).at(0x432795)
    if game == 'th08':
        item_spawn_top(0x0c).at(0x4400b8)
        item_spawn_wrap('ecx', 0x0c).at(0x440196)

    if game == 'th07':
        # In TH07, ItemManager::on_tick doesn't use the list (it BUILDS it!)
        thc.binhack('pointerize-item-tick', {
            'expected': thc.asm(f'''
                mov  eax, [ebp-0xcc]
                mov  [ebp-0x24], eax
            '''),
            'call-codecave': thc.asm(f'''
                mov  eax, [ebp-0xcc]
                mov  eax, [eax]
                mov  [ebp-0x24], eax
                ret
            '''),
        }).at(0x4329a0)

        # These places also don't use the list in this game.
        # I think they're related to PoC and un-attracting items on death.
        thc.binhack('pointerize-item-other', {
            'expected': thc.asm(f'''
                mov  dword ptr [ebp-0x8], eax
                mov  dword ptr [ebp-0x4], 0x0
            '''),
            'call-codecave': thc.asm(f'''
                mov  eax, [eax]
                mov  dword ptr [ebp-0x8], eax
                mov  dword ptr [ebp-0x4], 0x0
                ret
            '''),
        }).at([0x433a9c, 0x433b2c, 0x433c4c])

if __name__ == '__main__':
    main()
