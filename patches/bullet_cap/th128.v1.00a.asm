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

    dd 0x8a780e  ; offset of dummy bullet state
    dd SCALE_SIZE
    dd REPLACE_ALL

    dd 0x8a7f9c  ; offset of bullet.anm
    dd SCALE_SIZE
    dd REPLACE_ALL

    dd 0x8a7fa0  ; size of bullet manager
    dd SCALE_SIZE
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
    dd 0x2cc  ; array size (includes non-cancel items)
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

    ; offsets of fields after array
    dd 0x1cab14  ; num items alive
    dd SCALE_SIZE
    dd REPLACE_ALL
    dd 0x1cab18  ; next cancel item index
    dd SCALE_SIZE
    dd REPLACE_ALL
    dd 0x1cab1c  ; num cancel items spawned this frame
    dd SCALE_SIZE
    dd REPLACE_ALL
    dd 0x1cab20  ; num ufos spawned during this stage (unused but still zeroed out)
    dd SCALE_SIZE
    dd REPLACE_ALL
    dd 0x1cab24  ; ItemManager size
    dd SCALE_SIZE
    dd REPLACE_ALL

    dd 0x1cab00  ; array size
    dd SCALE_SIZE
    dd REPLACE_ALL

    dd LIST_END

perf_fix_data:  ; HEADER: AUTO
    dd 0  ; unused

iat_funcs:  ; HEADER: ExpHP.bullet-cap.iat-funcs
.GetLastError: dd 0x49a1c8
.GetModuleHandleA: dd 0
.GetModuleHandleW: dd 0x49a168
.GetProcAddress: dd 0x49a0ec
