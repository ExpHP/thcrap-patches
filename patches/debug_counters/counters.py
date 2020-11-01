#!/usr/bin/env python3

import sys
try:
    import binhack_helper
except ImportError:
    print('To run this script, you must add scripts/ to PYTHONPATH!', file=sys.stderr)
    sys.exit(1)

def main():
    game = binhack_helper.default_arg_parser(require_game=True).parse_args().game
    thc = binhack_helper.ThcrapGen('ExpHP.debug-counters.')
    defs = binhack_helper.NasmDefs.from_file_rel('common.asm')

    main_binhack(game, thc, defs)
    aux_stuff(game, thc, defs)
    define_counters(game, thc, defs)
    add_line_info(game, thc, defs)

    thc.print()

def main_binhack(game, thc, defs):
    # Main binhack:  We put this immediately after the call to AsciiManager::drawf_debug in FpsCounter::on_draw.
    binhack = lambda addr, original, jmp_dest: {
        'addr': addr,
        'expected': thc.asm(original),
        'codecave': thc.asm(lambda c: f'''
            call {c.rel_auto('show-debug-data')}
            {original}
            {c.jmp(jmp_dest)}
        '''),
    }
    thc.binhack('draw', {
        # just find the first instruction after 
        'th06': binhack(0x4240e4, original='mov  ecx, 0x47b900', jmp_dest=0x4240e9),
        'th07': binhack(0x439391, original="mov  eax, [0x62f648]", jmp_dest=0x439396),
        'th08': binhack(0x447225, original="mov  eax, [0x164d0b4]", jmp_dest=0x44722a),
        'th10': binhack(0x413653, original="mov  eax, [0x4776e0]", jmp_dest=0x413658),
        'th11': binhack(0x419f2b, original="mov  ecx, [0x4a8d58]", jmp_dest=0x419f31),
        'th12': binhack(0x41cd20, original="mov  ecx, [0x4b43b8]", jmp_dest=0x41cd26),
        'th125': binhack(0x41af25, original="mov  edx, [0x4b6770]", jmp_dest=0x41af2b),
        'th128': binhack(0x41fb30, original="mov  edx, [0x4b8920]", jmp_dest=0x41fb36),
        'th13': binhack(0x424b2c, original="mov  ecx, [0x4c2160]", jmp_dest=0x424b32),
        'th14': binhack(0x42e653, original="mov  eax, [0x4db520]", jmp_dest=0x42e658),
        'th143': binhack(0x42bf53, original="mov  eax, [0x4e69f8]", jmp_dest=0x42bf58),
        'th15': binhack(0x433773, original="mov  eax, [0x4e9a58]", jmp_dest=0x433778),
        'th16': binhack(0x426473, original="mov  eax, [0x4a6d98]", jmp_dest=0x426478),
        'th165': binhack(0x424267, original="mov  eax, [0x4b54f8]", jmp_dest=0x42426c),
        'th17': binhack(0x429fc3, original="mov  eax, [0x4b7678]", jmp_dest=0x429fc8),
    }[game])

def aux_stuff(game, thc, defs):
    # Workaround for games where AsciiManager is static, so that ColorData can still
    # contain a pointer to a pointer to AsciiManager.
    if 'th06' <= game <= 'th08':
        thc.codecave('ascii-manager-ptr', thc.data({
            'th06': 0x47b900,
            'th07': 0x134ce18,
            'th08': 0x4cce20,
        }[game]))

    thc.codecave('color-data', thc.data(lambda d: {
        'th06': defs.ColorData(ascii_manager_ptr=d.abs_auto('ascii-manager-ptr'), color_offset=0x6224, positioning=defs.POSITIONING_EOSD),
        'th07': defs.ColorData(ascii_manager_ptr=d.abs_auto('ascii-manager-ptr'), color_offset=0x74c0, positioning=defs.POSITIONING_IN),
        'th08': defs.ColorData(ascii_manager_ptr=d.abs_auto('ascii-manager-ptr'), color_offset=0x8268, positioning=defs.POSITIONING_IN),
        'th10': defs.ColorData(ascii_manager_ptr=0x4776e0, color_offset=0x8974, positioning=defs.POSITIONING_MOF),
        'th11': defs.ColorData(ascii_manager_ptr=0x4a8d58, color_offset=0x18480, positioning=defs.POSITIONING_TD),
        'th12': defs.ColorData(ascii_manager_ptr=0x4b43b8, color_offset=0x18f80, positioning=defs.POSITIONING_TD),
        'th13': defs.ColorData(ascii_manager_ptr=0x4c2160, color_offset=0x19160, positioning=defs.POSITIONING_TD),
        'th14': defs.ColorData(ascii_manager_ptr=0x4db520, color_offset=0x191b0, positioning=defs.POSITIONING_DDC),
        'th15': defs.ColorData(ascii_manager_ptr=0x4e9a58, color_offset=0x19224, positioning=defs.POSITIONING_DDC),
        'th16': defs.ColorData(ascii_manager_ptr=0x4a6d98, color_offset=0x1920c, positioning=defs.POSITIONING_DDC),
        'th17': defs.ColorData(ascii_manager_ptr=0x4b7678, color_offset=0x19214, positioning=defs.POSITIONING_DDC),
        'th125': defs.ColorData(ascii_manager_ptr=0x4b6770, color_offset=0x1c7f4, positioning=defs.POSITIONING_TD),
        'th128': defs.ColorData(ascii_manager_ptr=0x4b8920, color_offset=0x1c84c, positioning=defs.POSITIONING_TD),
        'th143': defs.ColorData(ascii_manager_ptr=0x4e69f8, color_offset=0x191b0, positioning=defs.POSITIONING_DDC),
        'th165': defs.ColorData(ascii_manager_ptr=0x4b54f8, color_offset=0x1c90c, positioning=defs.POSITIONING_DDC),
    }[game]))

    DRAWF_DEBUG = {
        # Early games: Any function that looks like it could be AsciiManager::drawf.
        'th06': 0x401650,
        'th07': 0x402060,
        'th08': 0x402a30,
        # TH10+: The function used by the FpsCounter to drawf.
        'th10': 0x401690,
        'th12': 0x401720,
        'th11': 0x401600,
        'th13': 0x4040e0,
        'th125': 0x401830,
        'th143': 0x40ba50,
        'th128': 0x401900,
        'th16': 0x4084f0,
        'th14': 0x40bdc0,
        'th15': 0x40c800,
        'th165': 0x408310,
        'th17': 0x408530,
    }[game]

    # Now wrap DRAWF_DEBUG to have the following ABI:
    # void __stdcall DrawfDebugInt(AsciiManager*, Float3*, char*, int current)
    if 'th06' <= game <= 'th08' or 'th14' <= game <= 'th17' and game != 'th165':
        # In these games drawf_debug WOULD be perfect except we that want callee-cleans-stack.
        drawf_debug_int = thc.asm(f'''
            enter 0x00, 0
            push [ebp+0x14]  # arg
            push [ebp+0x10]  # template
            push [ebp+0x0c]  # pos
            push [ebp+0x08]  # AsciiManager
            mov  eax, {DRAWF_DEBUG:#x}
            call eax
            add  esp, 0x10  # caller cleans stack for varargs
            leave
            ret 0x10
        ''')

    elif game == 'th165':
        # In TH165 ONLY, the output pointer arg from TH125 returns. Strange.
        drawf_debug_int = thc.asm(f'''
            enter 0x00, 0
            sub  esp, 0x4
            mov  ecx, esp
            push [ebp+0x14]  # arg
            push [ebp+0x10]  # template
            push [ebp+0x0c]  # pos
            push ecx  # the pesky output pointer from 128 is back
            push [ebp+0x08]  # AsciiManager
            mov  eax, {DRAWF_DEBUG:#x}
            call eax
            add  esp, 0x14  # caller cleans stack for varargs
            add  esp, 0x4
            leave
            ret 0x10
        ''')

    elif 'th10' <= game <= 'th12':
        # Beginning of the bizarre-ABI era.
        # The first three games only differ in the 'this' register.
        get_codecave = lambda this_reg: thc.asm(lambda c: f'''
            enter 0x00, 0
            {c.multipush('ebx', 'esi', 'edi')}
            push [ebp+0x14]  # arg
            push [ebp+0x10]  # template
            mov  ebx, [ebp+0x0c]  # pos
            mov  {this_reg}, [ebp+0x08]  # AsciiManager
            mov  eax, {DRAWF_DEBUG:#x}
            call eax
            add  esp, 0x8  # caller cleans stack for varargs
            {c.multipop('ebx', 'esi', 'edi')}
            leave
            ret 0x10
        ''')
        drawf_debug_int = {
            'th10': get_codecave(this_reg='esi'),
            'th11': get_codecave(this_reg='ecx'),
            'th12': get_codecave(this_reg='esi'),
        }[game]

    elif 'th125' <= game <= 'th128':
        # pos is now on the stack, and some kind of output pointer arg was added.
        get_codecave = lambda this_reg: thc.asm(lambda c: f'''
            enter 0x00, 0
            {c.multipush('ebx', 'esi', 'edi')}
            sub  esp, 0x4
            mov  edi, esp  # unknown output pointer added in DS
            push [ebp+0x14]  # arg
            push [ebp+0x10]  # template
            push [ebp+0x0c]  # pos
            mov  {this_reg}, [ebp+0x08]  # AsciiManager
            mov  eax, {DRAWF_DEBUG:#x}
            call eax
            add  esp, 0xc  # caller cleans stack for varargs
            add  esp, 0x4  # cleanup edi
            {c.multipop('ebx', 'esi', 'edi')}
            leave
            ret 0x10
        ''')
        drawf_debug_int = {
            'th125': get_codecave(this_reg='esi'),
            'th128': get_codecave(this_reg='esi'),
        }[game]

    elif game == 'th13':
        # pos is back in ebx
        get_codecave = lambda this_reg: thc.asm(lambda c: f'''
            enter 0x00, 0
            {c.multipush('ebx', 'esi', 'edi')}
            sub  esp, 0x4
            mov  edi, esp  # unknown output pointer added in DS
            push [ebp+0x14]  # arg
            push [ebp+0x10]  # template
            mov  ebx, [ebp+0x0c]  # pos
            mov  {this_reg}, [ebp+0x08]  # AsciiManager
            mov  eax, {DRAWF_DEBUG:#x}
            call eax
            add  esp, 0x8  # caller cleans stack for varargs
            add  esp, 0x4  # cleanup edi
            {c.multipop('ebx', 'esi', 'edi')}
            leave
            ret 0x10
        ''')
        drawf_debug_int = {
            'th13': get_codecave(this_reg='esi'),
        }[game]
    else:
        assert False, game

    thc.codecave('drawf-debug-int', drawf_debug_int)

def add_line_info(game, thc, defs):
    def counter(label, datacave):
        assert isinstance(label, bytes)
        assert len(label) < 12
        label += b'\0' * (12 - len(label))
        return thc.data(lambda d: defs.LineInfoEntry(data_ptr=d.abs_auto(datacave), fmt_string=label))

    counters = []
    if 'th06' <= game <= 'th08':
        counters.append(counter(b'%7d eff.I', 'effect-indexed-data'))
        counters.append(counter(b'%7d eff.G', 'effect-general-data'))
        counters.append(counter(b'%7d etama', 'bullet-data'))
        counters.append(counter(b'%7d laser', 'laser-data'))
        counters.append(counter(b'%7d item ', 'normal-item-data'))
        counters.append(counter(b'%7d enemy', 'enemy-data'))
    elif 'th10' <= game <= 'th17':
        counters.append(counter(b'%7d anmid', 'anmid-data'))
        if 'th15' <= game <= 'th17':
            counters.append(counter(b'%7d eff  ', 'effect-data'))
        counters.append(counter(b'%7d etama', 'bullet-data'))
        counters.append(counter(b'%7d laser', 'laser-data'))
        counters.append(counter(b'%7d itemN', 'normal-item-data'))
        counters.append(counter(b'%7d itemC', 'cancel-item-data'))
        if game == 'th13':
            counters.append(counter(b'%7d lgods', 'spirit-data'))
        counters.append(counter(b'%7d enemy', 'enemy-data'))
    else: assert False, game

    counters.append(0)  # indicator of list end
    thc.codecave('line-info', thc.data(counters))

def with_defaults(kw, **defaults):
    for k in defaults:
        if k not in kw:
            kw[k] = defaults[k]
    return kw

def define_counters(game, thc, defs):
    def limit_value(value): return 0, value
    def limit_addr(addr, correction=0): return addr, correction
    limit_none = limit_value(0x7fff_ffff)

    # Wrappers around the spec types that automatically emit the tag constant.
    array_spec = lambda *args, **kw: (defs.KIND_ARRAY, defs.ArraySpec(*args, **with_defaults(kw, adjust_array_func=0)))
    zero_spec = lambda *args, **kw: (defs.KIND_ZERO, defs.ZeroSpec(*args, **kw))
    field_spec = lambda *args, **kw: (defs.KIND_FIELD, defs.FieldSpec(*args, **kw))
    anmid_spec = lambda *args, **kw: (defs.KIND_ANMID, defs.AnmidSpec(*args, **kw))
    list_spec = lambda *args, **kw: (defs.KIND_LIST, defs.ListSpec(*args, **kw))
    def embedded(inner_spec_func, struct_base, *args, **kw):
        replay_manager_ptr = {
            'th06': 0x6d3f18,
            'th07': 0x4b9e48,
            'th08': 0x18b8a28,
        }[game]
        # get dwords, but pull out tag because that will go into the EmbeddedSpec header
        inner_kind, *inner_spec = inner_spec_func(0xdeadbeef, *args, **kw)
        inner = thc.data(inner_spec)
        inner_size = binhack_helper.hex_code_len(inner)
        return defs.KIND_EMBEDDED, defs.EmbeddedSpec(
            show_when_nonzero=replay_manager_ptr, struct_base=struct_base,
            spec_kind=inner_kind, spec_size=inner_size, spec=inner,
        )
    def dword_array(addr, limit, array_offset):
        return array_spec(addr, limit, array_offset=array_offset, field_offset=defs.FIELD_IS_DWORD, stride=0x4)

    thc.codecave('bullet-data', thc.data({
        # Early games track the count for their CAVE slowdown emulation feature.  Hooray!
        'th06': lambda: embedded(field_spec, 0x5a5ff8, limit_addr(0x4135fa-4), count_offset=0xf5c04),
        'th07': lambda: embedded(field_spec, 0x62f958, limit_addr(0x423770-4), count_offset=0x37a128),
        'th08': lambda: embedded(field_spec, 0xf54e90, limit_addr(0x4312ae-4), count_offset=0x6ba538),
        # ...these games don't track it. Scan the array.
        'th10': lambda: array_spec(0x4776f0, limit_addr(0x425856-4), array_offset=0x60, field_offset=0x446, stride=0x7f0),
        'th11': lambda: array_spec(0x4a8d68, limit_addr(0x408d40-4), array_offset=0x64, field_offset=0x4b2, stride=0x910),
        'th12': lambda: array_spec(0x4b43c8, limit_addr(0x40a061), array_offset=0x64, field_offset=0x532, stride=0x9f8),
        'th125': lambda: array_spec(0x4b677c, limit_addr(0x408785-4), array_offset=0x64, field_offset=0x512, stride=0xa34),
        'th128': lambda: array_spec(0x4b8930, limit_addr(0x408d95-4), array_offset=0x64, field_offset=0xa2a, stride=0x11b8),
        'th13': lambda: array_spec(0x4c2174, limit_addr(0x40d970-4, -1), array_offset=0x90, field_offset=0xbbe, stride=0x135c),
        'th14': lambda: array_spec(0x4db530, limit_addr(0x416560-4, -1), array_offset=0x8c, field_offset=0xc0e, stride=0x13f4),
        'th143': lambda: array_spec(0x4e6a08, limit_addr(0x4128d0-4, -1), array_offset=0x8c, field_offset=0xc0e, stride=0x13f4),
        'th15': lambda: array_spec(0x4e9a6c, limit_addr(0x418c99-4, -1), array_offset=0x98, field_offset=0xc8a, stride=0x1494),
        'th16': lambda: array_spec(0x4a6dac, limit_addr(0x4118b9-4, -1), array_offset=0x9c, field_offset=0xc72, stride=0x1478),
        'th165': lambda: array_spec(0x4b550c, limit_addr(0x40ebc7-4, -1), array_offset=0x9c, field_offset=0xe54, stride=0xe8c),
        'th17': lambda: array_spec(0x4b768c, limit_addr(0x414807-4, -1), array_offset=0xec, field_offset=0xe50, stride=0xe88),
    }[game]()))

    thc.codecave('normal-item-data', thc.data({
        'th06': lambda: embedded(field_spec, 0x69e268, limit_addr(0x41f2ff-4), count_offset=0x28948),
        'th07': lambda: embedded(field_spec, 0x575c70, limit_addr(0x432750-4), count_offset=0xae2ec),
        'th08': lambda: embedded(field_spec, 0x1653648, limit_addr(0x440187-4), count_offset=0x17ada8),
        'th10': lambda: array_spec(0x477818, limit_value(150), array_offset=0x14, field_offset=0x3dc, stride=0x3f0),
        'th11': lambda: array_spec(0x4a8e90, limit_value(150), array_offset=0x14, field_offset=0x464, stride=0x478),
        'th12': lambda: array_spec(0x4b44f0, limit_value(600), array_offset=0x14, field_offset=0x9b0, stride=0x9d8),
        'th125': lambda: zero_spec(0x4b68a0),
        'th128': lambda: array_spec(0x4b8a5c, limit_value(600), array_offset=0x14, field_offset=0xa18, stride=0xa40),
        'th13': lambda: array_spec(0x4c229c, limit_value(600), array_offset=0x14, field_offset=0xba0, stride=0xbc8),
        'th14': lambda: array_spec(0x4db660, limit_value(600), array_offset=0x14, field_offset=0xbf0, stride=0xc18),
        'th143': lambda: array_spec(0x4e6b64, limit_value(600), array_offset=0x14, field_offset=0xbf4, stride=0xc1c),
        'th15': lambda: array_spec(0x4e9a9c, limit_value(600), array_offset=0x10, field_offset=0xc64, stride=0xc88),
        'th16': lambda: array_spec(0x4a6ddc, limit_value(600), array_offset=0x14, field_offset=0xc50, stride=0xc78),
        'th165': lambda: zero_spec(0x4b5634),
        'th17': lambda: array_spec(0x4b76b8, limit_value(600), array_offset=0x14, field_offset=0xc58, stride=0xc78),
    }[game]()))

    thc.codecave('cancel-item-data', thc.data({
        'th06': lambda: 0,  # unused
        'th07': lambda: 0,  # unused
        'th08': lambda: 0,  # unused
        'th10': lambda: array_spec(0x477818, limit_addr(0x41af16-4, -150), array_offset=0x24eb4, field_offset=0x3dc, stride=0x3f0),
        'th11': lambda: array_spec(0x4a8e90, limit_addr(0x423490-4, -150), array_offset=0x29e64, field_offset=0x464, stride=0x478),
        'th12': lambda: array_spec(0x4b44f0, limit_addr(0x425b60-4, -600-16), array_offset=0x17afd4, field_offset=0x9b0, stride=0x9d8),
        'th125': lambda: array_spec(0x4b68a0, limit_addr(0x41f320-4, -0), array_offset=0x14, field_offset=0x4f0, stride=0x4f4),
        'th128': lambda: array_spec(0x4b8a5c, limit_addr(0x428550-4, -600-16), array_offset=0x18aa14, field_offset=0xa18, stride=0xa40),
        'th13': lambda: array_spec(0x4c229c, limit_addr(0x42e2c0-4, -600), array_offset=0x1b9cd4, field_offset=0xba0, stride=0xbc8),
        'th14': lambda: array_spec(0x4db660, limit_addr(0x438481-4, -600), array_offset=0x1c5854, field_offset=0xbf0, stride=0xc18),
        'th143': lambda: array_spec(0x4e6b64, limit_addr(0x435011-4, -600), array_offset=0x1c61b4, field_offset=0xbf4, stride=0xc1c),
        'th15': lambda: array_spec(0x4e9a9c, limit_addr(0x43f458-4, -600), array_offset=0x1d5ed0, field_offset=0xc64, stride=0xc88),
        'th16': lambda: array_spec(0x4a6ddc, limit_addr(0x42f0ea-4, -600), array_offset=0x1d3954, field_offset=0xc50, stride=0xc78),
        'th165': lambda: array_spec(0x4b5634, limit_addr(0x42bb46-4, -0), array_offset=0x10, field_offset=0x630, stride=0x634),
        'th17': lambda: array_spec(0x4b76b8, limit_addr(0x4331f8-4, -600), array_offset=0x1d3954, field_offset=0xc58, stride=0xc78),
    }[game]()))

    thc.codecave('laser-data', thc.data({
        'th06': lambda: embedded(
            array_spec, 0x5a5ff8, limit_addr(0x4134e5-4), array_offset=0xec000, field_offset=0x258, stride=0x270,
            adjust_array_func='<codecave:base-exphp.adjust-laser-array>'
        ),
        'th07': lambda: embedded(
            array_spec, 0x62f958, limit_addr(0x4233b1-4), array_offset=0x366628, field_offset=0x4d4, stride=0x4ec,
            adjust_array_func='<codecave:base-exphp.adjust-laser-array>'
        ),
        'th08': lambda: embedded(
            array_spec, 0xf54e90, limit_addr(0x42f464-4), array_offset=0x660938, field_offset=0x584, stride=0x59c,
            adjust_array_func='<codecave:base-exphp.adjust-laser-array>'
        ),
        'th10': lambda: field_spec(0x47781c, limit_addr(0x41c51a-4), count_offset=0x438),
        'th11': lambda: field_spec(0x4a8e94, limit_addr(0x424e01-4), count_offset=0x454),
        'th12': lambda: field_spec(0x4b44f4, limit_addr(0x42845d), count_offset=0x468),
        'th125': lambda: field_spec(0x4b68a4, limit_addr(0x420411-4), count_offset=0x468),
        'th128': lambda: field_spec(0x4b8a60, limit_addr(0x42a411-4), count_offset=0x5d4),
        'th13': lambda: field_spec(0x4c22a0, limit_addr(0x42fee1-4), count_offset=0x5d4),
        'th14': lambda: field_spec(0x4db664, limit_addr(0x43a765-4), count_offset=0x5d4),
        'th143': lambda: field_spec(0x4e6b6c, limit_addr(0x439075-4), count_offset=0x5d4),
        'th15': lambda: field_spec(0x4e9ba0, limit_addr(0x4419e5-4), count_offset=0x5e4),
        'th16': lambda: field_spec(0x4a6ee0, limit_addr(0x431775-4), count_offset=0x5e4),
        'th165': lambda: field_spec(0x4b5638, limit_addr(0x42cb65-4), count_offset=0x5e4),
        'th17': lambda: field_spec(0x4b76bc, limit_addr(0x4355d5-4), count_offset=0x5e4),
    }[game]()))

    if 'th10' <= game:
        thc.codecave('anmid-data', thc.data({
            'th10': lambda: anmid_spec(0x491c10, limit_value(0x1000), world_head_ptr_offset=0x72dad4, ui_head_ptr_offset=0x72dadc),
            'th11': lambda: anmid_spec(0x4c3268, limit_value(0x1000), world_head_ptr_offset=0x7b562c, ui_head_ptr_offset=0x7b5634),
            'th12': lambda: anmid_spec(0x4ce8cc, limit_value(0x1000), world_head_ptr_offset=0x8856b8, ui_head_ptr_offset=0x8856c0),
            'th125': lambda: anmid_spec(0x4d0cb4, limit_value(0x1000), world_head_ptr_offset=0x88d6c0, ui_head_ptr_offset=0x88d6c8),
            'th128': lambda: anmid_spec(0x4d2e50, limit_value(0x1000), world_head_ptr_offset=0x8b9704, ui_head_ptr_offset=0x8b9708),
            'th13': lambda: anmid_spec(0x4dc688, limit_value(0x1fff), world_head_ptr_offset=0xf48208, ui_head_ptr_offset=0xf48210),
            'th14': lambda: anmid_spec(0x4f56cc, limit_value(0x1fff), world_head_ptr_offset=0xfe8208, ui_head_ptr_offset=0xfe8210),
            'th143': lambda: anmid_spec(0x538de8, limit_value(0x1fff), world_head_ptr_offset=0xfe8218, ui_head_ptr_offset=0xfe8220),
            'th15': lambda: anmid_spec(0x503c18, limit_value(0x1fff), world_head_ptr_offset=0xdc, ui_head_ptr_offset=0xe4),
            'th16': lambda: anmid_spec(0x4c0f48, limit_value(0x1fff), world_head_ptr_offset=0xdc, ui_head_ptr_offset=0xe4),
            'th165': lambda: anmid_spec(0x4ed88c, limit_value(0x1fff), world_head_ptr_offset=0xdc, ui_head_ptr_offset=0xe4),
            'th17': lambda: anmid_spec(0x509a20, limit_value(0x3fff), world_head_ptr_offset=0x6dc, ui_head_ptr_offset=0x6e4),
        }[game]()))
    if game == 'th13':
        thc.codecave('spirit-data', thc.data(field_spec(0x4c22a4, limit_addr(0x438678-4), count_offset=0x8814)))

    thc.codecave('enemy-data', thc.data({
        'th06': lambda: embedded(field_spec, 0x4b79c8, limit_none, count_offset=0xee5bc),
        'th07': lambda: embedded(field_spec, 0x9a9b00, limit_none, count_offset=0x9545bc),
        'th08': lambda: embedded(field_spec, 0x577f20, limit_none, count_offset=0x9dcdc4),
        'th10': lambda: list_spec(0x477704, limit_none, head_ptr_offset=0x58),
        'th11': lambda: field_spec(0x4a8d7c, limit_none, count_offset=0x70),
        'th12': lambda: field_spec(0x4b43dc, limit_none, count_offset=0x70),
        'th125': lambda: field_spec(0x4b678c, limit_none, count_offset=0xa8),
        'th128': lambda: field_spec(0x4b8948, limit_none, count_offset=0xc0),
        'th13': lambda: field_spec(0x4c2188, limit_none, count_offset=0xb8),
        'th14': lambda: field_spec(0x4db544, limit_none, count_offset=0xd8),
        'th143': lambda: field_spec(0x4e6a48, limit_none, count_offset=0xd8),
        'th15': lambda: field_spec(0x4e9a80, limit_none, count_offset=0x18c),
        'th16': lambda: field_spec(0x4a6dc0, limit_none, count_offset=0x18c),
        'th165': lambda: field_spec(0x4b551c, limit_none, count_offset=0x1b4),
        'th17': lambda: field_spec(0x4b76a0, limit_none, count_offset=0x18c),
    }[game]()))

    if 'th06' <= game <= 'th08':
        thc.codecave('effect-general-data', thc.data({
            'th06': embedded(array_spec, 0x487fe0, limit_addr(0x40f136-4), array_offset=0x8, field_offset=0x178, stride=0x17c),
            'th07': embedded(array_spec, 0x12fe250, limit_addr(0x41c1f7-4), array_offset=0x1c, field_offset=0x2cc, stride=0x2d8),
            'th08': embedded(array_spec, 0x4ece60, limit_addr(0x425468-4), array_offset=0x1c, field_offset=0x350, stride=0x360),
        }[game]))
        thc.codecave('effect-familiar-data', thc.data({
            'th06': 0,
            'th07': 0,
            'th08': embedded(array_spec, 0x4ece60, limit_addr(0x425ba9-4), array_offset=0x6c01c, field_offset=0x350, stride=0x360),
        }[game]))
        thc.codecave('effect-indexed-data', thc.data({
            'th06': 0,
            'th07': embedded(array_spec, 0x12fe250, limit_value(0x9), array_offset=0x4719c, field_offset=0x2cc, stride=0x2d8),
            'th08': embedded(array_spec, 0x4ece60, limit_value(0xd), array_offset=0x8701c, field_offset=0x350, stride=0x360),
        }[game]))

    if 'th15' <= game <= 'th17':
        thc.codecave('effect-data', thc.data({
            'th15': dword_array(0x4e9a78, limit_addr(0x4228d1-4), array_offset=0x1c),
            'th16': dword_array(0x4a6db8, limit_addr(0x418ac1-4), array_offset=0x1c),
            'th165': dword_array(0x4b5518, limit_addr(0x415ef1-4), array_offset=0x1c),
            'th17': dword_array(0x4b7698, limit_addr(0x41b7e1-4), array_offset=0x1c),
        }[game]))

if __name__ == '__main__':
    main()
