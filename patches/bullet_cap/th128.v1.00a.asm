; AUTO_PREFIX: ExpHP.bullet-cap.

%include "util.asm"
%include "common.asm"

; Address range spanned by .text
address_range:  ; HEADER: AUTO
    dd 0x401000
    dd 0x499c15

bullet_replacements:  ; HEADER: AUTO
istruc ListHeader
    at ListHeader.old_cap, dd 0x7d0
    at ListHeader.elem_size, dd 0x11b8
iend
    dd 0x7d0
    dd SCALE_1
    dd BLACKLIST_BEGIN
    dd 0x40f856 - 4  ; in ChargeAttack::on_tick, seems related to freeze percentages
    dd 0x40f94a - 4  ; in ChargeAttack::on_tick
    dd 0x4103f3 - 4  ; ChargeAttack related
    dd 0x41e76f - 4  ; field offset

    dd 0x422284 - 4  ; in Gui::on_tick

    dd 0x43a4c3 - 4  ; in Player::constructor, seems to be # of bomb damage sources
    dd 0x43ba08 - 4  ; in Player::on_tick, length of that array
    dd 0x43dfb1 - 4  ; in a Player method
    dd 0x43dfde - 4  ; same Player method
    dd 0x43fd47 - 4  ; also that Player array
    dd 0x43ff4f - 4  ; seriously
    dd 0x43ff59 - 4  ; omg stahp

    dd 0x45e790 - 4  ; coincidental appearance in call offset, WHY ARE ALL THESE COINCIDENCES IN GFW
    dd 0x46a876 - 4  ; weird, possibly unused function
    dd BLACKLIST_END

    dd 0x7d1
    dd SCALE_1
    dd REPLACE_ALL

    dd 0x8a7f38  ; size of bullet array
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
    dd 0x42a411 - 4
    ; The rest are inlined calls to the above function.
    ; Find them via crossrefs to the Laser subclass constructors, as well as crossrefs to
    ; the subclass vtables in case a constructor was inlined.
    dd 0x42b418 - 4
    dd 0x42b558 - 4
    dd 0x42b691 - 4
    dd 0x42b7e6 - 4
    dd 0x42c7dd - 4
    dd 0x42d262 - 4
    dd 0x42e183 - 4
    dd 0x42eb4c - 4
    dd 0x431726 - 4
    dd WHITELIST_END
    dd LIST_END

cancel_replacements:  ; HEADER: AUTO
istruc ListHeader
    at ListHeader.old_cap, dd 100
    at ListHeader.elem_size, dd 0xa40
iend
    dd 0x2cc  ; array length (includes non-cancel items)
    dd SCALE_1
    dd WHITELIST_BEGIN
    ; 0x2cc is a common offset so searched for the stride 0xa40 instead
    dd 0x4282bf - 4
    dd 0x4284df - 4
    dd 0x428550 - 4
    dd 0x4290dd - 4
    dd 0x429227 - 4  ; actually contains 0x2bc due to UFO bug but we fix that in a binhack
    dd WHITELIST_END

    dd 100  ; number of cancel items
    dd SCALE_1
    dd WHITELIST_BEGIN
    dd 0x429531 - 4  ; ItemManager::spawn item (integer modulus)
    dd WHITELIST_END

    dd 0x1cab00  ; array size
    dd SCALE_SIZE
    dd REPLACE_ALL

    dd LIST_END

bullet_mgr_layout:  ; HEADER: AUTO
istruc LayoutHeader
    at LayoutHeader.offset_to_replacements, dd bullet_mgr_layout.replacements - bullet_mgr_layout
iend
    dd REGION_NORMAL(0)
    dd REGION_ARRAY(0x64, CAPID_BULLET, SCALE_SIZE)
    dd REGION_NORMAL(0x8a7f9c)
    dd REGION_END(0x8a7fa0)
.replacements:
    dd REP_OFFSET(0x8a780e), REPLACE_ALL  ; offset of dummy bullet state
    dd REP_OFFSET(0x8a7f9c), REPLACE_ALL  ; offset of bullet.anm
    dd REP_OFFSET(0x8a7fa0), REPLACE_ALL  ; size of bullet manager
    dd LIST_END

item_mgr_layout:  ; HEADER: AUTO
istruc LayoutHeader
    at LayoutHeader.offset_to_replacements, dd item_mgr_layout.replacements - item_mgr_layout
iend
    dd REGION_NORMAL(0)
    dd REGION_ARRAY(0x14, CAPID_CANCEL, SCALE_SIZE)
    dd REGION_NORMAL(0x1cab14)
    dd REGION_END(0x1cab24)
.replacements:
    dd REP_OFFSET(0x1cab14), REPLACE_ALL  ; num items alive
    dd REP_OFFSET(0x1cab18), REPLACE_ALL  ; next cancel item index
    dd REP_OFFSET(0x1cab1c), REPLACE_ALL  ; num cancel items spawned this frame
    dd REP_OFFSET(0x1cab20), REPLACE_ALL  ; num ufos spawned during this stage (unused but still zeroed out)
    dd REP_OFFSET(0x1cab24), REPLACE_ALL  ; ItemManager size
    dd LIST_END

perf_fix_data:  ; HEADER: AUTO
    dd 0  ; unused

iat_funcs:  ; HEADER: AUTO
.GetLastError: dd 0x49a1c8
.GetModuleHandleA: dd 0
.GetModuleHandleW: dd 0x49a168
.GetProcAddress: dd 0x49a0ec
.MessageBoxA: dd 0x49a240

corefuncs:  ; HEADER: AUTO
.malloc: dd 0x47296c
