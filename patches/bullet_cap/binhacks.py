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

    elif 'th10' <= game <= 'th17':
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

def add_other_binhacks(game, thc, defs):
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

if __name__ == '__main__':
    main()
