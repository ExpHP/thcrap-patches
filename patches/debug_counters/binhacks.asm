; THIS IS NOT A SOURCE FILE
;
; Changing anything in this file will NOT have any effect on the patch.
; This file is where I write the initial asm for many binhacks. Use
;
;     scripts/list-asm source/x.asm
;
; to generate the assembly, copy it into thXX.YAML, and postprocess it with
; some manual fixes like inserting [codecave:yadda-yadda-yadda] and deleting
; dummy labels.

%include "util.asm"
%include "common.asm"

; AUTO_PREFIX: ExpHP.debug-counters.

;=================================
; Main binhack:  We put this immediately after the call to AsciiManager::drawf_debug in FpsCounter::on_draw.

; 0x439391 (a148f66200)
binhack_07:  ; HEADER: AUTO
    call show_debug_data  ; REWRITE: [codecave:AUTO]

    mov  eax, [0x62f648] ; original code
    abs_jmp_hack 0x439396

; 0x447225 (a1b4d06401)
binhack_08:  ; HEADER: AUTO
    call show_debug_data  ; REWRITE: [codecave:AUTO]

    mov  eax, [0x164d0b4] ; original code
    abs_jmp_hack 0x44722a

; 0x413653
binhack_10:  ; HEADER: AUTO
    call show_debug_data  ; REWRITE: [codecave:AUTO]

    mov  eax, [0x4776e0] ; original code
    abs_jmp_hack 0x413658

; 0x419f2b
binhack_11:  ; HEADER: AUTO
    call show_debug_data  ; REWRITE: [codecave:AUTO]

    mov  ecx, [0x4a8d58] ; original code
    abs_jmp_hack 0x419f31

; 0x41cd20
binhack_12:  ; HEADER: AUTO
    call show_debug_data  ; REWRITE: [codecave:AUTO]

    mov  ecx, [0x4b43b8] ; original code
    abs_jmp_hack 0x41cd26

; 0x41af25  (8b1570674b00)
binhack_125:  ; HEADER: AUTO
    call show_debug_data  ; REWRITE: [codecave:AUTO]

    mov  edx, [0x4b6770] ; original code
    abs_jmp_hack 0x41af2b

; 0x41fb30  (8b1520894b00)
binhack_128:  ; HEADER: AUTO
    call show_debug_data  ; REWRITE: [codecave:AUTO]

    mov  edx, dword [0x4b8920] ; original code
    abs_jmp_hack 0x41fb36

; 0x424b2c  (8b0d60214c00)
binhack_13:  ; HEADER: AUTO
    call show_debug_data  ; REWRITE: [codecave:AUTO]

    mov  ecx, dword [0x4c2160] ; original code
    abs_jmp_hack 0x424b32

; 0x42e653  (a120b54d00)
binhack_14:  ; HEADER: AUTO
    call show_debug_data  ; REWRITE: [codecave:AUTO]

    mov  eax, dword [0x4db520] ; original code
    abs_jmp_hack 0x42e658

; 0x42bf53  (a1f8694e00)
binhack_143:  ; HEADER: AUTO
    call show_debug_data  ; REWRITE: [codecave:AUTO]

    mov  eax, dword [0x4e69f8] ; original code
    abs_jmp_hack 0x42bf58

; 0x433773  (a1589a4e00)
binhack_15:  ; HEADER: AUTO
    call show_debug_data  ; REWRITE: [codecave:AUTO]

    mov  eax, dword [0x4e9a58] ; original code
    abs_jmp_hack 0x433778

; 0x426473  (a1986d4a00)
binhack_16:  ; HEADER: AUTO
    call show_debug_data  ; REWRITE: [codecave:AUTO]

    mov  eax, dword [0x4a6d98] ; original code
    abs_jmp_hack 0x426478

; 0x424267  (a1f8544b00)
binhack_165:  ; HEADER: AUTO
    call show_debug_data  ; REWRITE: [codecave:AUTO]

    mov  eax, dword [0x4b54f8] ; original code
    abs_jmp_hack 0x42426c

; 0x429fc3  (a178764b00)
binhack_17:  ; HEADER: AUTO
    call show_debug_data  ; REWRITE: [codecave:AUTO]

    mov  eax, dword [0x4b7678] ; original code
    abs_jmp_hack 0x429fc8

line_info_strings:  ; HEADER: AUTO
    ; The line info codecave is maintained in yaml where there are conditional flags.
    ; These are here just for the ASCII conversion.
    dd "%7d anmid"
    dd "%7d etama"
    dd "%7d laser"
    dd "%7d items"
    dd "%7d itemN"
    dd "%7d itemC"
    dd "%7d eff.I"
    dd "%7d eff.G"
    dd "%7d eff.F"
    dd "%7d lgods"
    dd "%7d enemy"
    dd "%7d enmyA"
    dd "%7d eff  "

show_debug_data:  ; DELETE
