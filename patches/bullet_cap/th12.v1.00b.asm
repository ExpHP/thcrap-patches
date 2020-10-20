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
    at ListHeader.new_cap_bigendian_codecave, dd 0  ; REWRITE: <codecave:bullet-cap>
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

    dd LIST_END

laser_replacements:  ; HEADER: AUTO
istruc ListHeader
    at ListHeader.old_cap, dd 0x100
    at ListHeader.elem_size, dd 0
    at ListHeader.new_cap_bigendian_codecave, dd 0  ; REWRITE: <codecave:laser-cap>
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
    at ListHeader.new_cap_bigendian_codecave, dd 0  ; REWRITE: <codecave:cancel-cap>
iend
    dd 0xa68  ; array length (includes non-cancel items)
    dd SCALE_1
    dd BLACKLIST_BEGIN
    dd 0x429b2a - 4  ; reading a field from a laser
    dd 0x435a04 - 4  ; Player::constructor
    dd BLACKLIST_END

    dd 0x666fc0  ; array size
    dd SCALE_SIZE
    dd REPLACE_ALL

    dd LIST_END

bullet_mgr_layout:  ; HEADER: AUTO
istruc LayoutHeader
    at LayoutHeader.location, dd LOCATION_PTR(0x4b43c8)
    at LayoutHeader.offset_to_replacements, dd bullet_mgr_layout.replacements - bullet_mgr_layout
iend
    dd REGION_NORMAL(0)
    dd REGION_ARRAY(0x64, CAPID_BULLET, SCALE_SIZE)
    dd REGION_NORMAL(0x4debdc)
    dd REGION_END(0x4debe0)
.replacements:
    dd 0x4de716  ; offset of dummy bullet state
    dd REPLACE_ALL
    dd 0x4debdc  ; offset of bullet.anm
    dd REPLACE_ALL
    dd 0x4deb78  ; size of bullet array
    dd REPLACE_ALL
    dd 0x4debe0  ; size
    dd REPLACE_ALL
    dd LIST_END

item_mgr_layout:  ; HEADER: AUTO
istruc LayoutHeader
    at LayoutHeader.location, dd LOCATION_PTR(0x4b44f0)
    at LayoutHeader.offset_to_replacements, dd item_mgr_layout.replacements - item_mgr_layout
iend
    dd REGION_NORMAL(0)
    dd REGION_ARRAY(0x17afd4, CAPID_CANCEL, SCALE_SIZE)
    dd REGION_NORMAL(0x666fd4)
    dd REGION_END(0x666fe4)
.replacements:
    dd 0x666fd4  ; num items alive
    dd REPLACE_ALL
    dd 0x666fd8  ; next cancel item index
    dd REPLACE_ALL
    dd 0x666fdc  ; num cancel items spawned this frame
    dd REPLACE_ALL
    dd 0x666fe0  ; num ufos spawned during this stage
    dd REPLACE_ALL
    dd 0x666fe4  ; size
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
