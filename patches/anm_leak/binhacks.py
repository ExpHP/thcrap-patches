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
    defs = binhack_helper.NasmDefs.from_file_rel('common.asm')

    if game == 'th17':  # FIXME:  migrate other games to new binhacks
        add_main_binhacks(game, thc, defs)
        add_th18_perf_fixes(game, thc, defs)

    thc.print()


def add_main_binhacks(game, thc: binhack_helper.ThcrapGen, defs):
    game_data = {
        'th15':  defs.GameData(vm_size=0x608, id_offset=0x544, func_malloc=0x49039f),
        'th16':  defs.GameData(vm_size=0x5fc, id_offset=0x538, func_malloc=0x4749ac),
        'th165':  defs.GameData(vm_size=0x5fc, id_offset=0x538, func_malloc=0x47a78d),
        'th17':   defs.GameData(vm_size=0x600, id_offset=0x538, func_malloc=0x47b250),
        'th18.v0.02a': defs.GameData(vm_size=0x60c, id_offset=0x544, func_malloc=0x484851),
        'th18':   defs.GameData(vm_size=0x60c, id_offset=0x544, func_malloc=0x48dc71),
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
    if game=='th16':   hook_alloc(0x46f6ef, jmp_addr=0x46f6fc, expected='68fc050000')
    if game=='th165':  hook_alloc(0x475a1f, jmp_addr=0x475a2c, expected='68fc050000')
    # these games defer the stack cleanup so only replace the call
    if game=='th17':   hook_alloc(0x476b54, jmp_addr=0x476b59, expected='e8f7460000')
    # if game=='th18.v0.02a': hook_alloc(0x47fbd4, jmp_addr=0x47fbd9, expected='e8784c0000')
    if game=='th18':   hook_alloc(0x489414, jmp_addr=0x489419, expected='e858480000')

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
    # if game == 'th18.v0.02a': hook_dealloc(0x47f0c3, vm_reg='esi', expected='e8b9570000')
    if game == 'th18':   hook_dealloc(0x488753, vm_reg='esi', expected='e849550000')

    # ===================================

    def hook_search(binhack_addr):
        thc.binhack('search', {
            'addr': binhack_addr,
            'code': thc.asm(lambda c: f''' jmp {c.rel_auto('new-search')} '''),
        })
    # Hook the line that reads world_list_head.
    # Jump to function cleanup.
    # if game == 'th15':   hook_search(0x488534, id_reg='eax', jmp_addr=0x488573, expected='8b96dc000000')
    # if game == 'th16':   hook_search(0x46efc4, id_reg='eax', jmp_addr=0x46f003, expected='8b96dc000000')
    # if game == 'th165':  hook_search(0x47530d, id_reg='eax', jmp_addr=0x47535a, expected='8b96dc000000')
    if game == 'th17':   hook_search(0x476470)
    # if game == 'th18.v0.02a': hook_search(0x47f49d, id_reg='eax', jmp_addr=0x47f4ea, expected='8b8ef0060000')
    # if game == 'th18':   hook_search(0x488b5d, id_reg='eax', jmp_addr=0x488baa, expected='8b8ef0060000')

    # This binhack disables the 'fast' case of AnmManager::allocate_vm so that ALL VMs use our code.
    #
    # I think it was to help stress test our changes...
    def disable_fast_array(binhack_addr, jmp_addr):
        thc.binhack('no-fast-alloc', {
            'addr': binhack_addr,
            'code': thc.asm(lambda c: c.jmp(jmp_addr)),
        })
    if game == 'th15': disable_fast_array(0x489479, 0x48954f)
    elif game == 'th16': disable_fast_array(0x46f619, 0x46f6ef)
    elif game == 'th165': disable_fast_array(0x475949, 0x475a1f)
    elif game == 'th17': disable_fast_array(0x476a79, 0x476b4f)
    # These games REQUIRE it because they use our layer-drawing optimizations and we need to make sure
    # the number of existing batches is adequate for the layer array.
    elif game == 'th18': disable_fast_array(0x489339, 0x48940f)
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
    if game == 'th17':
        hack_id.at(0x475d18, vm_reg='edi', id_reg='ecx')
        hack_id.at(0x475da9, vm_reg='edx', id_reg='ecx')
        hack_id.at(0x475e58, vm_reg='edi', id_reg='ecx')
        hack_id.at(0x475ee9, vm_reg='edx', id_reg='ecx')
    else:
        assert False, game


def add_th18_perf_fixes(game, thc: binhack_helper.ThcrapGen, defs):
    thc.codecave('layer-data', thc.data({
        'th15': 0, 'th16': 0, 'th165': 0,
        'th18.v0.02a': 0,
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
    if game == 'th18': build_layer_array(0x401449, jmp_addr=0x40144f, anm_manager=0x51f65c, expected='8b4840 53 33db')

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
    if game == 'th18': optimize_draw_layer(0x488282, layer='ebp+0x8', anm_mgr_reg='esi', jmp_addr=0x488328, expected="8b86f0060000")

    # ---------
    # One last little hack:
    #
    # Because we were forced to disable the vanilla fast path for VMs, we actually deoptimized AnmManager::get_vm_with_id.
    # A LOT.  Which is bad because EffectManager::on_tick calls it. A LOT.  Enough to slow us down to 20FPS.
    #
    # But here's the funny thing:
    #
    # As far as I can tell, these calls in EffectManager::on_tick currently serve NO PURPOSE.
    # The array and these calls were added in LoLK.  To my understanding, having reversed the relevant parts of TH15 and TH16,
    # all it's doing is keeping track of which effects are still alive, so that those VMs can be duplicated when a PointDevice
    # snapshot is created.  Which will obviously never happen in TH18.
    #
    # So... we'll just make it unconditionally believe that all effect VMs are dead, and it shouldn't be a problem.
    def no_effect_manager(binhack_addr, expected):
        thc.binhack('forgetful-effect-manager', {
            'addr': binhack_addr,
            'expected': expected,
            'code': thc.asm(lambda c: f'''
                pop eax  # balance the stack
                xor eax, eax
                nop; nop
            '''),
        })
    if game == 'th18': no_effect_manager(0x42af45, expected="e8f6db0500")

if __name__ == '__main__':
    main()
