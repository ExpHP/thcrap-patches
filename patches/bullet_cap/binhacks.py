#!/usr/bin/env python3

import sys
import binhack_helper

def main():
    game = binhack_helper.default_arg_parser(require_game=True).parse_args().game
    thc = binhack_helper.ThcrapGen('ExpHP.bullet-cap.')
    defs = binhack_helper.NasmDefs.from_file_rel('common.asm')

    # Uncomment this to give yourself a chance to attach CE if you need to debug a crash in life before main.
    # if 'th07' <= game <= 'th08':
    #     thc.binhack('loop', {
    #         'addr': {
    #             'th07': 0x47ea7d,
    #             'th08': 0x4a619e,
    #         }[game],
    #         'expected': thc.asm(f'push 0x60'),
    #         'code': thc.asm('loop: jmp loop'),
    #     })

    add_initializing_binhack(game, thc, defs)
    add_other_binhacks(game, thc, defs)

    thc.print()

def add_initializing_binhack(game, thc, defs):
    # Here we add the binhack which does all of the dword search-and-replace stuff.

    # There aren't many places that are guaranteed to run exactly once,
    # so to avoid contention with other patches we choose an innocuous place
    # in code that runs while starting a new game, and simply make our
    # implementation idempotent.
    if 'th06' <= game <= 'th08':
        # Early games:  GameThread global doesn't exist yet,
        # so do it right before the call to BulletManager::initialize instead.
        start_addr, end_addr, orig_call_addr, expected = {
            'th06': (0x41c05a, 0x41c05f, 0x4148f0, "e89188ffff"),
            'th07': (0x42f0db, 0x42f0e0, 0x4276a0, "e8c085ffff"),
            'th08': (0x43b414, 0x43b419, 0x4311a0, "e8875dffff"),
        }[game]
        thc.binhack('install', {
            'addr': start_addr,
            'expected': expected,
            'codecave': thc.asm(lambda c: f'''
                call {c.rel_auto('initialize')}

                # Original code
                mov  eax, {orig_call_addr:#x}
                call eax
                {c.jmp(end_addr)}
            '''),
        })

    elif game == 'th09':
        # Similar place to above but before the loop over the two sets of per-player globals
        thc.binhack('install', {
            'addr': 0x41b209,
            'expected': 'bec47d4a00',
            'codecave': thc.asm(lambda c: f'''
                call {c.rel_auto('initialize')}

                # Original code
                mov  esi, 0x4a7dc4
                {c.jmp(0x41b20e)}
            '''),
        })

    elif 'th10' <= game:
        # MoF onwards:  Do it right before spawning the game thread
        start_addr, end_addr, orig_call_addr, expected = {
            'th10':  (0x420ec8, 0x420ecd, 0x44c150, 'e883b20200'),
            'th11':  (0x420328, 0x42032d, 0x42a500, 'e8d3a10000'),
            'th12':  (0x422758, 0x42275d, 0x430500, 'e8a3dd0000'),
            'th125': (0x41d9a3, 0x41d9a8, 0x42a1a0, 'e8f8c70000'),
            'th128': (0x426970, 0x426975, 0x434cb0, 'e83be30000'),
            'th13':  (0x42c4f0, 0x42c4f5, 0x43b280, 'e88bed0000'),
            'th14':  (0x4365c5, 0x4365ca, 0x445b00, 'e836f50000'),
            'th143': (0x432f6a, 0x432f6f, 0x444ad0, 'e8611b0100'),
            'th15':  (0x43cbef, 0x43cbf4, 0x44d7f0, 'e8fc0b0100'),
            'th16':  (0x42d76e, 0x42d773, 0x43c5b0, 'e83dee0000'),
            'th165': (0x429719, 0x42971e, 0x4397b0, 'e892000100'),
            'th17':  (0x4312ff, 0x431304, 0x442280, 'e87c0f0100'),
            'th18':  (0x443814, 0x443819, 0x454860, 'e847100100'),
        }[game]
        thc.binhack('install', {
            'addr': start_addr,
            'expected': expected,
            'codecave': thc.asm(lambda c: f'''
                push ecx  # save; might be an arg to the original function
                call {c.rel_auto('initialize')}
                pop  ecx

                # original code
                mov  eax, {orig_call_addr:#x}
                call eax
                # (can't use call-codecave and ret because it'd mess with stack args to the above call)
                {c.jmp(end_addr)}
            '''),
        })

    else:
        assert False, game

def add_other_binhacks(game, thc: binhack_helper.ThcrapGen, defs):
    # UFO (and GFW) actually has a bug in some of its loops over items where it misses the
    # last 16 cancel items because ZUN forgot to include UFOs in the iteration count.
    #
    # Fix these with direct binhacks so that they get picked up by our search and replace.
    def fix_ufo_item_bugs(true_item_count, binhack_addrs):
        thc.binhack('fix-ufo-item-bugs', {
            'addr': binhack_addrs,
            'expected': thc.data(true_item_count - 16),
            'code': thc.data(true_item_count),
        })
    if game == 'th12':
        fix_ufo_item_bugs(true_item_count=0xa68, binhack_addrs=[
            0x427243,  # ItemManager::on_draw
            0x427b5d,  # involves PLAYER, seems to be dead code though
        ])
    elif game == 'th128':
        fix_ufo_item_bugs(true_item_count=0x2cc, binhack_addrs=[
            0x429223,  # ItemManager::on_draw
        ])

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
                jge  taken
                {c.jmp(br_not_taken)}
            taken:
                {c.jmp(br_taken)}
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

    # TH09 also has a small laser cap, but the optimized lines are so different
    # from TH06/TH07 that we handle it separately.
    if game == 'th09':
        old_laser_cap = 0x30
        laser_size = 0x59c

        thc.binhack('fix-laser-cmp', {
            'addr': 0x4132d1,
            'expected': [
                thc.asm(f'cmp  eax, {old_laser_cap:#x}'),
                '7cea'  # a jl imm8
            ],
            'codecave': thc.asm(lambda c: f'''
                push eax  # save
                push {defs.CAPID_LASER:#x}
                call {c.rel_auto('get-new-cap')}
                mov  ecx, eax
                pop  eax

                cmp  eax, ecx
                jl   taken
                {c.jmp(0x4132d6)}
            taken:
                {c.jmp(0x4132c0)}
            '''),
        })

        thc.binhack('fix-laser-push', {
            'addr': 0x4150a0,
            'expected': thc.asm(f'''
                push {old_laser_cap:#x}
                push {laser_size:#x}
            '''),
            'codecave': thc.asm(lambda c: f'''
                push {defs.CAPID_LASER:#x}
                call {c.rel_auto('get-new-cap')}
                push eax
                push {laser_size:#x}
                {c.jmp(0x4150a7)}
            '''),
        })

    # Patch for where games without cancel item freelists increment the next index.
    #
    # Due to the compiler optimizing this check into a bitwise operation,
    # we can't use the same value-substituting machinery we use for everything else.
    def cancel_index_hack(binhack_addr, reg, jmp_addr):
        thc.binhack('fix-next-cancel', {
            'addr': binhack_addr,
            'expected': thc.asm(f'''
                inc  {reg}
                and  {reg}, 0x800007ff
            '''),
            'codecave': thc.asm(lambda c: f'''
                push {reg}
                call {c.rel_auto('next-cancel-index')}
                mov  {reg}, eax
                {c.jmp(jmp_addr)}
            '''),
        })
    # jmp_addr should skip past the stuff that deals with negative values
    if game == 'th10': cancel_index_hack(0x41bdf9, 'edx', jmp_addr=0x41be0a)
    if game == 'th11': cancel_index_hack(0x42454d, 'ecx', jmp_addr=0x42455e)
    if game == 'th12': cancel_index_hack(0x427859, 'edx', jmp_addr=0x42786a)

    # Fixes the huge lag spikes that causes the game to appear to freeze when
    # canceling >10000 bullets.
    def perf_hack(binhack_addr, jmp_addr, expected, extra_cleanup=''):
        thc.binhack('cancel-perf-fix', {
            'addr': binhack_addr,
            'expected': expected,
            'codecave': thc.asm(lambda c: f'''
                push edx  # save
                push ecx  # save
                push ecx  # argument
                call {c.rel_auto('less-spikey-find-world-vm')}
                pop  ecx
                pop  edx

                test eax, eax
                jz   continue

            success:
                # exit early from this function
                {extra_cleanup}
                ret  0x4

            continue:
                # go to part that checks UI list
                push esi  # stack operation in code we're skipping over
                {c.jmp(jmp_addr)}
            '''),
        })
    # jmp_addr should point to the part that checks the UI list
    if game == 'th10': perf_hack(0x4491cd, jmp_addr=0x4491e5, expected='8b82d4da7200')
    if game == 'th11': perf_hack(0x4561ed, jmp_addr=0x456205, expected='8b822c567b00')
    if game == 'th13': perf_hack(0x46fbae, jmp_addr=0x46fbd1, expected='8b820882f400', extra_cleanup='pop ebp')

    # Leak and reuse Bullet Manager in TH15-TH165.
    #
    # Fixes crashes on starting a new game after a previous one in these games.
    # The crashes are due to difficulty finding contiguous memory regions for reallocating bullet manager,
    # especially when using the anm_leak patch to fix midgame crashes.
    if 'th15' <= game <= 'th165':
        bullet_mgr, item_mgr, malloc = {
            'th15': (0x4e9a6c, 0x4e9a9c, 0x49039f),
            'th16': (0x4a6dac, 0x4a6ddc, 0x4749ac),
            'th165': (0x4b550c, 0x4b5634, 0x47a78d),
        }[game]

        # nops out a 'call free'
        keep_manager = thc.binhack('leak-mgrs', {'code': '90 90909090'}).at

        _no_zero_manager = thc.binhack_collection('no-zero-mgr', lambda mgr: {
            'expected': thc.asm(f'mov dword ptr [{mgr:#x}], 0x0'),
            'code': '9090 90909090 90909090',
        })
        no_zero_manager = lambda binhack_addr, mgr: _no_zero_manager(mgr=mgr).at(binhack_addr)

        _reuse_manager = thc.binhack_collection('reuse-mgr', lambda mgr, expected, jmp_addr: {
            'expected': expected,
            'codecave': thc.asm(lambda c: f'''
                mov  eax, dword ptr [{mgr:#x}]
                test eax, eax
                jnz  noalloc
                mov  eax, {malloc:#x}
                call eax
            noalloc:
                {c.jmp(jmp_addr)}
            ''')
        })
        reuse_manager = lambda binhack_addr, mgr, expected: _reuse_manager(mgr=mgr, expected=expected, jmp_addr=binhack_addr+5).at(binhack_addr)

        # Apply reuse_bullet_manager at the 'call malloc' in BulletManager::operator new.
        # Apply keep_bullet_manager at every 'call free' after a call to the BulletManager destructor.
        if game == 'th15':
            reuse_manager(0x4191f9, mgr=bullet_mgr, expected='e8 a1710700')
            reuse_manager(0x43f76a, mgr=item_mgr, expected='e8 300c0500')
            no_zero_manager(0x419184, mgr=bullet_mgr)
            no_zero_manager(0x43f6ee, mgr=item_mgr)
            keep_manager([0x41923a, 0x419279, 0x4192a3, 0x421739, 0x43c8dd])  # bullet_mgr
            keep_manager([0x421799, 0x43c8f7, 0x43f7f9, 0x43f823])  # item_mgr
        elif game == 'th16':
            reuse_manager(0x411df9, mgr=bullet_mgr, expected='e8 ae2b0600')
            reuse_manager(0x42f469, mgr=item_mgr, expected='e8 3e550400')
            no_zero_manager(0x411d88, mgr=bullet_mgr)
            no_zero_manager(0x42f3db, mgr=item_mgr)
            keep_manager([0x411e37, 0x42d463])  # bullet_mgr
            keep_manager([0x42d482, 0x42f4a7])  # item_mgr
        elif game == 'th165':
            reuse_manager(0x40ebab, mgr=bullet_mgr, expected='e8 ddbb0600'),
            reuse_manager(0x42bb2a, mgr=item_mgr, expected='e8 5eec0400'),
            no_zero_manager(0x40ee7f, mgr=bullet_mgr)
            no_zero_manager(0x42bcd1, mgr=item_mgr)
            keep_manager([0x40eeb0])  # bullet_mgr
            keep_manager([0x42bce7])  # item_mgr
        else: assert False, game

if __name__ == '__main__':
    main()
