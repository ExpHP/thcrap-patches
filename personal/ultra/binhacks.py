import binhack_helper

def main():
    game = binhack_helper.default_arg_parser(require_game=True).parse_args().game
    thc = binhack_helper.ThcrapGen('ExpHP.ultra.')
    add_hacks(game, thc)
    thc.print()

def add_hacks(game, thc):
    if 'th07' <= game <= 'th08':
        count1_offset, count2_offset, exflags_offset, player_base = {
            'th07': (0xbc, 0xbe, 0xc4, 0x4bdad8),
            'th08': (0x1f4, 0x1f6, 0x1fc, 0x17d5ef8),
        }[game]
        thc.binhack('ultra-increase', {
            'expected': thc.asm(f'   mov ecx, {player_base:#x}   '),
            'call-codecave': thc.asm(f'''
                mov  eax, [ebp+0x8]
                shl  word ptr [eax+{count1_offset:#x}], 0x2
                shl  word ptr [eax+{count2_offset:#x}], 0x2
                mov  ecx, {player_base:#x}
                ret
            '''),
        }).at({'th07': 0x424d5d, 'th08': 0x430e6c}[game])

        thc.binhack('ultra-decrease', {
            'expected': thc.asm(f'   mov ecx, [eax+{exflags_offset:#x}]   '),
            'call-codecave': thc.asm(f'''
                shr  word ptr [eax+{count1_offset:#x}], 0x2
                shr  word ptr [eax+{count2_offset:#x}], 0x2
                mov  ecx, [eax+{exflags_offset:#x}]
                ret
            '''),
        }).at({'th07': 0x424dd1, 'th08': 0x430ee0}[game])

    if 'th14' <= game <= 'th17':
        thc.binhack('ultra-increase', {
            'expected': thc.asm(f'   movss dword ptr [esp+0x10], xmm0   '),
            'call-codecave': thc.asm(f'''
                add  esp, 0x4  # use esp from original code
                movss dword ptr [esp+0x10], xmm0
                shl  word ptr [edi+{0x364:#x}], 0x2
                shl  word ptr [edi+{0x366:#x}], 0x2
                sub  esp, 0x4
                ret
            '''),
        }).at({
            'th14': 0x41922c, 'th15': 0x41c646, 'th16': 0x414e26,
            'th165': 0x412b16, 'th17': 0x418356,
        }[game])

        thc.binhack('ultra-decrease', {
            'expected': thc.asm(f'   test byte ptr [edi+{0x36c:#x}], 0x20   '),
            'call-codecave': thc.asm(f'''
                shr  word ptr [edi+{0x364:#x}], 0x2
                shr  word ptr [edi+{0x366:#x}], 0x2
                test byte ptr [edi+{0x36c:#x}], 0x20
                ret
            '''),
        }).at({
            'th14': 0x419293, 'th15': 0x41c6b3, 'th16': 0x414e93,
            'th165': 0x412b83, 'th17': 0x4183c3,
        }[game])


if __name__ == '__main__':
    main()
