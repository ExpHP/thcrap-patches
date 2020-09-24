; AUTO_PREFIX: ExpHP.bullet-cap.

%include "util.asm"
%include "common.asm"

; Address range spanned by .text
address_range:  ; HEADER: AUTO
    dd 0x401000
    dd 0x48ae15

bullet_replacements:  ; HEADER: AUTO
istruc ListHeader
    at ListHeader.old_cap, dd 0x7d0
    at ListHeader.elem_size, dd 0x910
iend
    dd 0x7d0
    dd SCALE_1
    dd BLACKLIST_BEGIN
    dd 0x41c394 - 4
    dd 0x459057 - 4
    dd 0x46b806 + 2  ; coincidental appearance in a jump
    dd BLACKLIST_END

    dd 0x7d1
    dd SCALE_1
    dd REPLACE_ALL

    dd 0x46d216  ; offset of dummy bullet state
    dd SCALE_SIZE
    dd REPLACE_ALL

    dd 0x46d674  ; offset of bullet.anm
    dd SCALE_SIZE
    dd REPLACE_ALL

    dd 0x46d678  ; size of bullet manager
    dd SCALE_SIZE
    dd REPLACE_ALL

    dd 0x46d610  ; size of bullet array
    dd SCALE_SIZE
    dd REPLACE_ALL

    dd LIST_END

laser_replacements:  ; HEADER: AUTO
istruc ListHeader
    at ListHeader.old_cap, dd 0
    at ListHeader.elem_size, dd 0
iend
    dd LIST_END

cancel_replacements:  ; HEADER: AUTO
istruc ListHeader
    at ListHeader.old_cap, dd 0
    at ListHeader.elem_size, dd 0
iend
    dd LIST_END

iat_funcs:  ; HEADER: ExpHP.bullet-cap.iat-funcs
.GetLastError: dd 0x48b1b8
.GetModuleHandleA: dd 0
.GetModuleHandleW: dd 0x48b174
.GetProcAddress: dd 0x48b170

; defined in global.yaml
initialize:
