; AUTO_PREFIX: ExpHP.bullet-cap.

%include "util.asm"
%include "common.asm"

; Address range spanned by .text
address_range:  ; HEADER: AUTO
    dd 0x401000
    dd 0x497ad5

bullet_replacements:  ; HEADER: AUTO
istruc ListHeader
    at ListHeader.old_cap, dd 0x7d0
    at ListHeader.elem_size, dd 0x9f8
iend
    dd 0x7d0
    dd SCALE_1
    dd BLACKLIST_BEGIN
    dd 0x41ec14 - 4  ; in Gui::on_tick
    dd 0x464867 - 4  ; weird, possibly unused function
    dd 0x478506 + 2  ; coincidental appearance in a jump
    dd BLACKLIST_END

    dd 0x7d1
    dd SCALE_1
    dd REPLACE_ALL

    dd 0x4de716  ; offset of dummy bullet state
    dd SCALE_SIZE
    dd REPLACE_ALL

    dd 0x4debdc  ; offset of bullet.anm
    dd SCALE_SIZE
    dd REPLACE_ALL

    dd 0x4debe0  ; size of bullet manager
    dd SCALE_SIZE
    dd REPLACE_ALL

    dd 0x4deb78  ; size of bullet array
    dd SCALE_SIZE
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
    ; This sucker got inlined but we can just look at the crossrefs of LaserLine::constructor.
    dd 0x428461 - 4
    dd 0x41bc4c - 4
    dd 0x42a164 - 4
    dd 0x42a766 - 4
    dd 0x42b6c6 - 4
    dd 0x42bd07 - 4
    dd WHITELIST_END
    dd LIST_END

cancel_replacements:  ; HEADER: AUTO
istruc ListHeader
    at ListHeader.old_cap, dd 0x800
    at ListHeader.elem_size, dd 0x9d8
iend
    dd 0xa68  ; array size (includes non-cancel items)
    dd SCALE_1
    dd BLACKLIST_BEGIN
    dd 0x429b2a - 4  ; reading a field from a laser
    dd 0x435a04 - 4  ; Player::constructor
    dd BLACKLIST_END

    ; offsets of fields after array
    dd 0x666fd4  ; num items alive
    dd SCALE_SIZE
    dd REPLACE_ALL
    dd 0x666fd8  ; next cancel item index
    dd SCALE_SIZE
    dd REPLACE_ALL
    dd 0x666fdc  ; num cancel items spawned this frame
    dd SCALE_SIZE
    dd REPLACE_ALL
    dd 0x666fe0  ; num ufos spawned during this stage
    dd SCALE_SIZE
    dd REPLACE_ALL
    dd 0x666fe4  ; ItemManager size
    dd SCALE_SIZE
    dd REPLACE_ALL

    dd 0x666fc0  ; array size
    dd SCALE_SIZE
    dd REPLACE_ALL

    dd LIST_END

perf_fix_data:  ; HEADER: AUTO
    dd 0  ; unused

iat_funcs:  ; HEADER: AUTO
.GetLastError: dd 0x4980e4
.GetModuleHandleA: dd 0
.GetModuleHandleW: dd 0x498174
.GetProcAddress: dd 0x498170
.MessageBoxA: dd 0x49824c
