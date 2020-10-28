; THIS IS NOT A SOURCE FILE
;
; Changing anything in this file will NOT have any effect on the patch.
; This file is where I write the initial asm for many binhacks. Use
;
;     scripts/list-asm source/x.asm

; AUTO_PREFIX: ExpHP.ultra.

%include "util.asm"

; TH07: 0x424d5d  (b9d8da4b00)
; TH08: 0x430e6c  (b9f85e7d01)
th08_1:  ; HEADER: AUTO
    mov  eax, dword [ebp+0x8]
    shl  word [eax+0xbe], 0x2  ; TH07
    shl  word [eax+0xbc], 0x2  ; TH07
    shl  word [eax+0x1f6], 0x2  ; TH08
    shl  word [eax+0x1f4], 0x2  ; TH08
    ; original code
    mov  ecx, 0x4bdad8  ; TH07
    mov  ecx, 0x17d5ef8  ; TH08
    ret

; TH07: 0x424dce  (8b45088b88c4000000)
; TH08: 0x430edd  (8b45088b88fc010000)
th08_2:  ; HEADER: AUTO
    mov  eax, dword [ebp+0x8]
    shr  word [eax+0xbe], 0x2  ; TH07
    shr  word [eax+0xbc], 0x2  ; TH07
    shr  word [eax+0x1f6], 0x2  ; TH08
    shr  word [eax+0x1f4], 0x2  ; TH08
    ; original code
    mov  eax, dword [ebp+0x8]
    mov  ecx, dword [eax+0xc4]  ; TH07
    mov  ecx, dword [eax+0x1fc]  ; TH08
    ret


; TH14:  0x41922c  (f30f11442410)
; TH15:  0x41c646  (f30f11442410)
; TH16:  0x414e26  (f30f11442410)
; TH165: 0x412b16  (f30f11442410)
; TH17:  0x418356  (f30f11442410)
th15_01:  ; HEADER: AUTO
    movss dword [esp+0x10], xmm0
    shl  word [edi+0x364], 0x2
    shl  word [edi+0x366], 0x2
    ret

; TH14:  0x419293  (f6876c03000020)
; TH15:  0x41c6b3  (f6876c03000020)
; TH16:  0x414e93  (f6876c03000020)
; TH165: 0x412b83  (f6876c03000020)
; TH17:  0x4183c3  (f6876c03000020)
th15_02:  ; HEADER: AUTO
    shr  word [edi+0x364], 0x2
    shr  word [edi+0x366], 0x2
    test byte [edi+0x36c], 0x20
    ret
