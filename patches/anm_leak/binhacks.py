#!/usr/bin/env python3

import sys
try:
    import binhack_helper
except ImportError:
    print('To run this script, you must add scripts/ to PYTHONPATH!', file=sys.stderr)
    sys.exit(1)

def main():
    game = binhack_helper.default_arg_parser(require_game=True).parse_args().game
    thc = binhack_helper.ThcrapGen('ExpHP.anm-buffers.')

    add_binhacks(game, thc)

    thc.print()


def add_binhacks(game, thc: binhack_helper.ThcrapGen):
    def GameData(vm_size, id_offset, func_malloc):
        return thc.data([vm_size, id_offset, func_malloc])

    thc.codecave('game-data', {
        'th15':  GameData(vm_size=0x608, id_offset=0x544, func_malloc=0x49039f),
        'th16':  GameData(vm_size=0x5fc, id_offset=0x538, func_malloc=0x4749ac),
        'th165':  GameData(vm_size=0x5fc, id_offset=0x538, func_malloc=0x47a78d),
        'th17':   GameData(vm_size=0x600, id_offset=0x538, func_malloc=0x47b250),
        'th18tr': GameData(vm_size=0x60c, id_offset=0x550, func_malloc=0x484851),
        'th18':   GameData(vm_size=0x60c, id_offset=0x550, func_malloc=0x48dc71),
    }[game])

    # ===================================

    # Replaces the instruction that allocates a new VM in the 'slow' case of AnmManager::allocate_vm.
    def hook_alloc(binhack_addr, jmp_addr, expected):
        thc.binhack('alloc', {
            'addr': binhack_addr,
            'expected': expected,
            'codecave': thc.asm(lambda c: f'''
                call {c.rel_auto('new-alloc-vm')}
                {c.jmp(jmp_addr)}
            '''),
        })
    # replace the "push, call, stack cleanup" sequence
    if game=='th15':   hook_alloc(0x48954f, jmp_addr=0x48955c, expected='6808060000')
    if game=='th16':   hook_alloc(0x46f6ef, jmp_addr=0x46f6fc, expected='68fc050000')
    if game=='th165':  hook_alloc(0x475a1f, jmp_addr=0x475a2c, expected='68fc050000')
    # these games defer the stack cleanup so only replace the call
    if game=='th17':   hook_alloc(0x476b54, jmp_addr=0x476b59, expected='e8f7460000')
    if game=='th18tr': hook_alloc(0x47fbd4, jmp_addr=0x47fbd9, expected='e8784c0000')
    if game=='th18':   hook_alloc(0x41939c, jmp_addr=0x4193a1, expected='e8d0480700')

    def hook_dealloc(binhack_addr, vm_reg, expected):
        thc.binhack('dealloc', {
            'addr': binhack_addr,
            'expected': expected,
            'call-codecave': thc.asm(lambda c: f'''
                # since we called this codecave, ignore the stuff already pushed and push the vm again
                push {vm_reg}
                call {c.rel_auto('new-dealloc-vm')}
                # the code that we return to already contains an `add esp, ___` to clean up the stuff we ignored
                ret
            '''),
        })
    # Replace the call to the C++ stdlib 'operator delete'
    if game == 'th15':   hook_dealloc(0x44c97c, vm_reg='esi', expected='e86f3a0400')
    if game == 'th16':   hook_dealloc(0x43b941, vm_reg='esi', expected='e899900300')
    if game == 'th165':  hook_dealloc(0x438bfe, vm_reg='esi', expected='e85c570400')
    if game == 'th17':   hook_dealloc(0x476083, vm_reg='esi', expected='e8f8510000')
    if game == 'th18tr': hook_dealloc(0x47f0c3, vm_reg='esi', expected='e8b9570000')
    if game == 'th18':   hook_dealloc(0x488753, vm_reg='esi', expected='e849550000')

    # ===================================

    def hook_search(binhack_addr, id_reg, jmp_addr, expected):
        thc.binhack('search', {
            'addr': binhack_addr,
            'expected': expected,
            'codecave': thc.asm(lambda c: f'''
                push {id_reg}
                call {c.rel_auto('new-search')}
                {c.jmp(jmp_addr)}
            '''),
        })
    # Hook the line that reads world_list_head.
    # Jump to function cleanup.
    if game == 'th15':   hook_search(0x488534, id_reg='eax', jmp_addr=0x488573, expected='8b96dc000000')
    if game == 'th16':   hook_search(0x46efc4, id_reg='eax', jmp_addr=0x46f003, expected='8b96dc000000')
    if game == 'th165':  hook_search(0x47530d, id_reg='eax', jmp_addr=0x47535a, expected='8b96dc000000')
    if game == 'th17':   hook_search(0x47648d, id_reg='eax', jmp_addr=0x4764da, expected='8b8edc060000')
    if game == 'th18tr': hook_search(0x47f49d, id_reg='eax', jmp_addr=0x47f4ea, expected='8b8ef0060000')
    if game == 'th18':   hook_search(0x488b5d, id_reg='eax', jmp_addr=0x488baa, expected='8b8ef0060000')

    # This binhack disables the 'fast' case of AnmManager::allocate_vm so that ALL VMs use our code.
    #
    # I think it was to help stress test our changes...
    def disable_fast_array(binhack_addr, jmp_addr):
        thc.binhack('no-fast-alloc', {
            'addr': binhack_addr,
            'code': thc.asm(lambda c: c.jmp(jmp_addr)),
        })
    if game == 'th15': disable_fast_array(0x489479, 0x48954f)
    if game == 'th16': disable_fast_array(0x46f619, 0x46f6ef)
    if game == 'th165': disable_fast_array(0x475949, 0x475a1f)


if __name__ == '__main__':
    main()
