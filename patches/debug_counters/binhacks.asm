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

line_info_strings:  ; HEADER: AUTO
    ; The line info codecave is maintained in yaml where there are conditional flags.
    ; These are here just for the ASCII conversion.
    dd "%7d anmid"
    dd "%7d etama"
    dd "%7d laser"
    dd "%7d itemN"
    dd "%7d itemC"
    dd "%7d lgods"

show_debug_data:  ; DELETE
