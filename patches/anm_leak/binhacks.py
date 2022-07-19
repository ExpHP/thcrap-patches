#!/usr/bin/env python3

import sys
import binhack_helper

def main():
    game = binhack_helper.default_arg_parser(require_game=True).parse_args().game
    thc = binhack_helper.ThcrapGen('ExpHP.anm-buffers.')
    defs = binhack_helper.NasmDefs.from_file_rel('common.asm')

    game_data = add_main_binhacks(game, thc, defs)
    if game <= 'th17':
        use_optimized_id_system(game, thc, defs, game_data)
    if 'th17' <= game <= 'th18':
        add_th17_perf_fixes(game, thc, defs)

    thc.print()


def add_main_binhacks(game, thc: binhack_helper.ThcrapGen, defs):
    game_data = {
        'th15':  defs.GameData(vm_size=0x608, id_offset=0x544, func_malloc=0x49039f, fast_array_bits=0, func_free_unsized=0x4903f0),
        'th16':  defs.GameData(vm_size=0x5fc, id_offset=0x538, func_malloc=0x4749ac, fast_array_bits=0, func_free_unsized=0xDEADBEEF),
        'th165': defs.GameData(vm_size=0x5fc, id_offset=0x538, func_malloc=0x47a78d, fast_array_bits=0, func_free_unsized=0xDEADBEEF),
        'th17':  defs.GameData(vm_size=0x600, id_offset=0x538, func_malloc=0x47b250, fast_array_bits=0, func_free_unsized=0xDEADBEEF),
        # FIXME: This entry is at present unused, we still don't have proper support for multiple versions of a game
        'th18.v0.02a': defs.GameData(vm_size=0x60c, id_offset=0x544, func_malloc=0x484851, fast_array_bits=0, func_free_unsized=0xDEADBEEF),
        'th18': defs.GameData(vm_size=0x60c, id_offset=0x544, func_malloc=0x48dc71, fast_array_bits=15, func_free_unsized=0xDEADBEEF),
    }[game]

    thc.codecave('game-data', thc.data(game_data))

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
    elif game=='th16':   hook_alloc(0x46f6ef, jmp_addr=0x46f6fc, expected='68fc050000')
    elif game=='th165':  hook_alloc(0x475a1f, jmp_addr=0x475a2c, expected='68fc050000')
    # these games defer the stack cleanup so only replace the call
    elif game=='th17':   hook_alloc(0x476b54, jmp_addr=0x476b59, expected='e8f7460000')
    # elif game=='th18.v0.02a': hook_alloc(0x47fbd4, jmp_addr=0x47fbd9, expected='e8784c0000')
    elif game=='th18.v1.00a':   hook_alloc(0x489414, jmp_addr=0x489419, expected='e858480000')
    else:
        assert False, game

    # We need to do some cleanup and mark a VM as unused when it would normally be deallocated.
    #
    # Thankfully, the game's check for when to deallocate is based on comparing the address of the VM
    # to the beginning and end addresses of the fast array, so as long as we hack the right conditional
    # branch, this will work regardless of whether we force the game to use our ID system.
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
    elif game == 'th16':   hook_dealloc(0x43b941, vm_reg='esi', expected='e899900300')
    elif game == 'th165':  hook_dealloc(0x438c31, vm_reg='esi', expected='e8871b0400')
    elif game == 'th17':   hook_dealloc(0x476083, vm_reg='esi', expected='e8f8510000')
    # elif game == 'th18.v0.02a': hook_dealloc(0x47f0c3, vm_reg='esi', expected='e8b9570000')
    elif game == 'th18.v1.00a':   hook_dealloc(0x488753, vm_reg='esi', expected='e849550000')
    else:
        assert False, game

    # The game zeros out the ID before it calls 'free'.
    # In TH15 this is a nuisance because we need that ID to tell if it's a snapshot VM.
    if game == 'th15':
        expected = 'c7864405000000000000'
        assert len(expected) % 2 == 0
        thc.binhack('dealloc-no-stupid-zero', {
            'addr': 0x44c96b,
            'expected': expected,
            'code': '90' * (len(expected) // 2),
        })

    return game_data

def use_optimized_id_system(game, thc: binhack_helper.ThcrapGen, defs, game_data):
    def hook_search(binhack_addr):
        thc.binhack('search', {
            'addr': binhack_addr,
            'code': thc.asm(lambda c: f''' jmp {c.rel_auto('new-search')} '''),
        })
    # Replace the whole function.
    if game == 'th15':    hook_search(0x488510)
    elif game == 'th16':  hook_search(0x46efa0)
    elif game == 'th165': hook_search(0x4752f0)
    elif game == 'th17':  hook_search(0x476470)
    # XXX: This hack would have to be updated to be aware of the fast array to work in UM.
    #      (even then, we won't be able to optimize the inlined callsites, but thankfully not all were inlined)
    # elif game == 'th18.v1.00a':  hook_search(0x488b40)
    else:
        assert False, game

    # This binhack disables the 'fast' case of AnmManager::allocate_vm so that ALL VMs use our code.
    #
    # Our new search requires this.
    def disable_fast_array(binhack_addr, jmp_addr):
        thc.binhack('no-fast-alloc', {
            'addr': binhack_addr,
            'code': thc.asm(lambda c: c.jmp(jmp_addr)),
        })
    if game == 'th15': disable_fast_array(0x489479, 0x48954f)
    elif game == 'th16': disable_fast_array(0x46f619, 0x46f6ef)
    elif game == 'th165': disable_fast_array(0x475949, 0x475a1f)
    elif game == 'th17': disable_fast_array(0x476a79, 0x476b4f)
    # NOTE: As of th18.v1.00a the code that uses the fast array is now inlined in a ton of places.
    #       Disabling it is no longer an option.
    # elif game == 'th18.v1.00a': disable_fast_array(0x489339, 0x48940f)
    else:
        assert False, game

    hack_id = thc.binhack_collection('set-id', lambda vm_reg, id_reg: {
        'expected': thc.asm(f'mov dword ptr [{vm_reg} + {game_data.id_offset:#x}], {id_reg}'),
        'call-codecave': thc.asm(lambda c: f'''
            push eax
            push ecx
            push edx  # save

            push {vm_reg}
            call {c.rel_auto('assign-our-id')}

            pop  edx  # restore
            pop  ecx
            mov  {id_reg}, eax
            pop  eax
            ret
        '''),
    })
    if game == 'th15':
        hack_id.at(0x487c72, vm_reg='edi', id_reg='ecx')
        hack_id.at(0x487d2c, vm_reg='edi', id_reg='ecx')
        hack_id.at(0x487de2, vm_reg='edi', id_reg='ecx')
        hack_id.at(0x487e9c, vm_reg='edi', id_reg='ecx')
    elif game == 'th16':
        hack_id.at(0x46e872, vm_reg='edi', id_reg='ecx')
        hack_id.at(0x46e92c, vm_reg='edi', id_reg='ecx')
        hack_id.at(0x46e9e2, vm_reg='edi', id_reg='ecx')
        hack_id.at(0x46ea9c, vm_reg='edi', id_reg='ecx')
    elif game == 'th165':
        hack_id.at(0x474a7d, vm_reg='edi', id_reg='ecx')
        hack_id.at(0x474b0e, vm_reg='edx', id_reg='ecx')
        hack_id.at(0x474bbd, vm_reg='edi', id_reg='ecx')
        hack_id.at(0x474c4e, vm_reg='edx', id_reg='ecx')
    elif game == 'th17':
        hack_id.at(0x475d18, vm_reg='edi', id_reg='ecx')
        hack_id.at(0x475da9, vm_reg='edx', id_reg='ecx')
        hack_id.at(0x475e58, vm_reg='edi', id_reg='ecx')
        hack_id.at(0x475ee9, vm_reg='edx', id_reg='ecx')
    # XXX: This hack would have to be updated to be aware of the fast array to work in UM.
    # elif game == 'th18':
    #     hack_id.at(0x4883e8, vm_reg='edi', id_reg='ecx')
    #     hack_id.at(0x488479, vm_reg='edx', id_reg='ecx')
    #     hack_id.at(0x488528, vm_reg='edi', id_reg='ecx')
    #     hack_id.at(0x4885b9, vm_reg='edx', id_reg='ecx')
    else:
        assert False, game


def add_th17_perf_fixes(game, thc: binhack_helper.ThcrapGen, defs):
    thc.codecave('layer-data', thc.data({
        'th17': defs.GameLayerData(
            func_draw_vm=0x46f8c0,
            world_list_offset=0x6dc,
            layer_offset=0x18,
            ui_list_offset=0x6e4,
            flags_hi_offset=0x534,
            flags_hi_hide=0x60,
            ui_layer_start=36,
            ui_layer_count=7,  # note: WBaWC has a bug at 0x475c27 where it maps 8 layers into UI layers. We won't reproduce that
            world_ui_layer_start=24,
            ui_layer_default=38,
        ),
        'th18': defs.GameLayerData(
            func_draw_vm=0x481210,
            world_list_offset=0x6f0,
            layer_offset=0x18,
            ui_list_offset=0x6f8,
            flags_hi_offset=0x538,
            flags_hi_hide=0x180,
            ui_layer_start=37,
            ui_layer_count=9,
            world_ui_layer_start=24,
            ui_layer_default=39,
        ),
    }[game]))

    def build_layer_array(binhack_addr, jmp_addr, anm_manager, expected):
        thc.binhack('build-layer-list', {
            'addr': binhack_addr,
            'expected': expected,
            'codecave': thc.asm(lambda c: f'''
                push eax  # save

                push dword ptr [{anm_manager:#x}]
                call {c.rel_auto('rebuild-layer-array')}

                pop  eax  # recover
                # original code
                mov  ecx, dword ptr [eax+0x40]
                push ebx
                xor  ebx, ebx
                {c.jmp(jmp_addr)}
            '''),
        })
    # Finding a good place for this was tricky.  Oddly enough the on_draw that draws layer 0 does not always run,
    # so I chose a spot inside UpdateFuncRegistry::run_all_on_draw.
    # (AFTER aquiring the critical section)
    if game == 'th17': build_layer_array(0x401409, jmp_addr=0x40140f, anm_manager=0x509a20, expected='8b4840 53 33db')
    elif game == 'th18': build_layer_array(0x401449, jmp_addr=0x40144f, anm_manager=0x51f65c, expected='8b4840 53 33db')
    else:
        assert False, game

    def optimize_draw_layer(binhack_addr, layer, anm_mgr_reg, jmp_addr, expected):
        thc.binhack('optimized-draw-layer', {
            'addr': binhack_addr,
            'expected': expected,
            'codecave': thc.asm(lambda c: f'''
                push dword ptr [{layer}]
                push {anm_mgr_reg}
                call {c.rel_auto('fast-draw-layer')}
                {c.jmp(jmp_addr)}
            '''),
        })
    # Replace the entire part of the function inside the critical section.
    if game == 'th17': optimize_draw_layer(0x475bc2, layer='ebp+0x8', anm_mgr_reg='esi', jmp_addr=0x475c58, expected="8b86dc060000")
    elif game == 'th18': optimize_draw_layer(0x488282, layer='ebp+0x8', anm_mgr_reg='esi', jmp_addr=0x488328, expected="8b86f0060000")
    else:
        assert False, game


if __name__ == '__main__':
    main()
