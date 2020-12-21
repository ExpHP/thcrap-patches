import binhack_helper

def main():
    game = binhack_helper.default_arg_parser(require_game=True).parse_args().game
    thc = binhack_helper.ThcrapGen('ExpHP.coop-sa.')
    add_hacks(game, thc)
    thc.print()

def add_hacks(game, thc):
    assert game == 'th11'

    thc.binhack('read-keyboard', {
        'addr': 0x4308d3,
        'expected': thc.asm('mov  eax, dword ptr [0x4a5710]'),
        'call-codecave': thc.asm(lambda c: f'''
            call {c.rel_auto('update-keyboard')}
            mov  eax, dword ptr [0x4a5710]
            ret
        '''),
    })

    # In the Reimu C Option callback, skip over the jumps that check option_id == 1 and player focus.
    thc.binhack('always-update-options', {
        'addr': 0x4337c7,
        'expected': '0f8549010000',
        'codecave': thc.asm(lambda c: c.jmp(0x4337da)),
    })

    thc.binhack('read-attempted-motion', {
        'addr': 0x43381a,
        'expected': thc.asm(f'''
            fld  dword ptr [esi+0x8b0]
            fld  dword ptr [esi+0x8ac]
        '''),
        'call-codecave': thc.asm(lambda c: f'''
            sub  esp, 0x8
            push esp
            push dword ptr [edi+0xd0]
            call {c.rel_auto('get-option-attempted-motion')}
            fld  dword ptr [esp+0x4]
            fld  dword ptr [esp+0x0]
            add  esp, 0x8
            ret
        '''),
    })

    thc.binhack('read-attempted-x', {
        'addr': 0x4337da,
        'expected': thc.asm(f'''
            fld  dword ptr [esi+0x8a0]
        '''),
        'call-codecave': thc.asm(lambda c: f'''
            sub  esp, 0x8
            push esp
            push dword ptr [edi+0xd0]
            call {c.rel_auto('get-option-attempted-motion')}
            fld  dword ptr [esp+0x0]  // x part
            add  esp, 0x8
            ret
        '''),
    })
    thc.binhack('read-attempted-y', {
        'addr': 0x4337fb,
        'expected': thc.asm(f'''
            fld  dword ptr [esi+0x8a4]
        '''),
        'call-codecave': thc.asm(lambda c: f'''
            sub  esp, 0x8
            push esp
            push dword ptr [edi+0xd0]
            call {c.rel_auto('get-option-attempted-motion')}
            fld  dword ptr [esp+0x4]  // y part
            add  esp, 0x8
            ret
        '''),
    })

    thc.binhack('reimu-c-angle-fld', {
        'addr': [0x43383a, 0x433879],
        'expected': thc.asm('fld  dword ptr [esi+0x8c14]'),
        'call-codecave': thc.asm(lambda c: f'''
            push dword ptr [edi+0xd0]
            call {c.rel_auto('get-option-angle-ptr')}
            fld  dword ptr [eax]
            ret
        ''')
    })
    thc.binhack('reimu-c-angle-fstp', {
        'addr': [0x433910],
        'expected': thc.asm('fstp dword ptr [esi+0x8c14]'),
        'call-codecave': thc.asm(lambda c: f'''
            push dword ptr [edi+0xd0]
            call {c.rel_auto('get-option-angle-ptr')}
            fstp dword ptr [eax]
            ret
        ''')
    })
    thc.binhack('reimu-c-angle-fadd', {
        'addr': [0x4338f9, 0x4338d3, 0x433921],
        'expected': thc.asm('fadd dword ptr [esi+0x8c14]'),
        'call-codecave': thc.asm(lambda c: f'''
            push dword ptr [edi+0xd0]
            call {c.rel_auto('get-option-angle-ptr')}
            fadd dword ptr [eax]
            ret
        ''')
    })

    CURRENT_POWER = 0x4a56e8
    POWER_PER_LEVEL = 0x4a574c
    thc.binhack('power-at-least-2', {
        'addr': 0x432cd9,
        'expected': thc.asm(f'''
            mov  ecx, dword ptr [{CURRENT_POWER:#x}]
        '''),
        'call-codecave': thc.asm(lambda c: f'''
            mov  ecx, dword ptr [{CURRENT_POWER:#x}]
            cmp  ecx, {40:#x}
            jge   enoughpower
            mov  dword ptr [{CURRENT_POWER:#x}], {40:#x}
        enoughpower:
            mov  ecx, dword ptr [{CURRENT_POWER:#x}]
            ret
        '''),
    })

    thc.binhack('bomb-requires-power-3', {
        'addr': 0x4311d3,
        'expected': thc.asm(f'''
            idiv dword ptr [{POWER_PER_LEVEL:#x}]
            test eax, eax
        '''),
        'call-codecave': thc.asm(lambda c: f'''
            idiv dword ptr [{POWER_PER_LEVEL:#x}]
            cmp  eax, 0x2
            setg al
            test eax, eax
            ret
        '''),
    })

    # assign script numbers X and X-1 to turret players 1 and 2
    colorize = thc.binhack_collection('different-color-options', lambda option_id_offset, stackout, last_script, jmp_addr: {
        'expected': thc.asm(f'''
            push 0xb
            push {last_script:#x}
            lea  esi, [esp+{stackout:#x}]
        '''),
        'codecave': thc.asm(lambda c: f'''
            push edx  // save (used by existing code after binhack)
            push [edi+{option_id_offset:#x}]
            call {c.rel_auto('get-option-player-number')}
            pop  edx  // restore

            mov  ecx, {last_script:#x}
            sub  ecx, eax
            push 0xb
            push ecx
            lea  esi, [esp+{stackout:#x}]
            {c.jmp(jmp_addr)}
        '''),
    })
    # NOTE: option_id_offset comes from the fact that the compiler uses offset pointers for iterating options.
    # It is  (offset of options in player) + (offset of option id in option) - (initial offset of iterator)
    #   e.g.  0x7570 + 0xd0 - 0x7624 = 0x1c
    colorize.at(0x432de3, jmp_addr=0x432deb, option_id_offset=0x1c, stackout=0x28, last_script=25)
    colorize.at(0x4331d0, jmp_addr=0x4331d8, option_id_offset=0x68, stackout=0x40, last_script=22)

if __name__ == '__main__':
    main()
