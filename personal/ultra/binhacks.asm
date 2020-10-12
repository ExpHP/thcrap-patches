; THIS IS NOT A SOURCE FILE
;
; Changing anything in this file will NOT have any effect on the patch.
; This file is where I write the initial asm for many binhacks. Use
;
;     scripts/list-asm source/x.asm

; AUTO_PREFIX: ExpHP.ultra.

%include "util.asm"

; 0x430e6c  (b9f85e7d01)
th08_1:  ; HEADER: AUTO
    mov  eax, dword [ebp+0x8]
    shl  word [eax+0x1f6], 0x2
    shl  word [eax+0x1f4], 0x2
    ; original code
    mov  ecx, 0x17d5ef8
    abs_jmp_hack 0x430e71

; 0x430edd  (8b45088b88fc010000)
th08_2:  ; HEADER: AUTO
    mov  eax, dword [ebp+0x8]
    shr  word [eax+0x1f6], 0x2
    shr  word [eax+0x1f4], 0x2
    ; original code
    mov  eax, dword [ebp+0x8]
    mov  ecx, dword [eax+0x1fc]
    abs_jmp_hack 0x430ee6


; 0x41c646  (f30f11442410)
th15_01:  ; HEADER: AUTO
    movss dword [esp+0x10], xmm0
    shl  word [edi+0x364], 0x2
    shl  word [edi+0x366], 0x2
    abs_jmp_hack 0x41c64c

; 0x41c6b3  (f6876c03000020)
th15_02:  ; HEADER: AUTO
    shr  word [edi+0x364], 0x2
    shr  word [edi+0x366], 0x2
    test byte [edi+0x36c], 0x20
    abs_jmp_hack 0x41c6ba

; 0x414e26  (f30f11442410)
th16_01:  ; HEADER: AUTO
    movss dword [esp+0x10], xmm0
    shl  word [edi+0x364], 0x3
    shl  word [edi+0x366], 0x3
    abs_jmp_hack 0x414e2c

; 0x414e93  (f6876c03000020)
th16_02:  ; HEADER: AUTO
    shr  word [edi+0x364], 0x3
    shr  word [edi+0x366], 0x3
    test byte [edi+0x36c], 0x20
    abs_jmp_hack 0x414e9a

