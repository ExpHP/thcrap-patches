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

; AUTO_PREFIX: ExpHP.bullet-cap.

%include "util.asm"
%include "common.asm"

; An innocuous place in the function that starts the game thread.
; 0x420ec8
cave:  ; HEADER: AUTO
    call initialize  ; REWRITE: [codecave:AUTO]

    ; original code
    mov   eax, 0x44c150
    call  eax
    abs_jmp_hack 0x420ecd

; 0x41bdf9
fix_next_cancel:  ; HEADER: AUTO
    push edx
    call next_cancel_index  ; REWRITE: [codecave:AUTO]
    mov  edx, eax
    abs_jmp_hack 0x41be0a

; Address range spanned by .text
address_range:  ; HEADER: AUTO
    dd 0x401000
    dd 0x465a81

bullet_replacements:  ; HEADER: AUTO
istruc ListHeader
    at ListHeader.old_cap, dd 0x7d0
    at ListHeader.elem_size, dd 0x7f0
iend
    dd 0x7d0
    dd SCALE_1
    dd BLACKLIST_BEGIN
    dd 0x41560d - 4
    dd 0x44bd82 - 4
    dd BLACKLIST_END

    dd 0x7d1
    dd SCALE_1
    dd REPLACE_ALL

    dd 0x3e07a6  ; offset of dummy bullet state
    dd SCALE_SIZE
    dd REPLACE_ALL

    dd 0x3e0b50  ; offset of bullet.anm
    dd SCALE_SIZE
    dd REPLACE_ALL

    dd 0x3e0b54  ; size of bullet manager
    dd SCALE_SIZE
    dd REPLACE_ALL

    dd 0xf82d5  ; num dwords in bullet manager
    dd SCALE_SIZE_DIV(4)
    dd REPLACE_ALL

    dd 0xf82bc  ; num dwords in bullet array
    dd SCALE_SIZE_DIV(4)
    dd REPLACE_ALL

    dd LIST_END

laser_replacements:  ; HEADER: AUTO
istruc ListHeader
    at ListHeader.old_cap, dd 0x100
    at ListHeader.elem_size, dd 0
iend
    dd 0x100
    dd SCALE_1
    dd WHITELIST_BEGIN
    dd 0x41c51a - 4
    dd WHITELIST_END

    dd LIST_END

cancel_replacements:  ; HEADER: AUTO
istruc ListHeader
    at ListHeader.old_cap, dd 0x800
    at ListHeader.elem_size, dd 0x3f0
iend
    dd 0x896  ; array size (includes non-cancel items)
    dd SCALE_1
    dd REPLACE_ALL

    dd 0x21cec0  ; ItemManager size
    dd SCALE_SIZE
    dd REPLACE_ALL

    dd 0x873a8   ; array size in dwords
    dd SCALE_SIZE_DIV(4)
    dd REPLACE_ALL

    dd 0x873b0   ; ItemManager size in dwords
    dd SCALE_SIZE_DIV(4)
    dd REPLACE_ALL

    ; offsets of fields after array
    dd 0x21ceb4  ; num items alive
    dd SCALE_SIZE
    dd REPLACE_ALL
    dd 0x21ceb8  ; next cancel item index
    dd SCALE_SIZE
    dd REPLACE_ALL
    dd 0x21cebc  ; num cancel items spawned this frame
    dd SCALE_SIZE
    dd REPLACE_ALL

    dd LIST_END

iat_funcs:  ; HEADER: ExpHP.bullet-cap.iat-funcs
.GetLastError: dd 0x45fadc
.GetModuleHandleA: dd 0x466198
.GetModuleHandleW: dd 0
.GetProcAddress: dd 0x466158

; defined in global.yaml
initialize:
next_cancel_index:
