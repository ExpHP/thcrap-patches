; AUTO_PREFIX: ExpHP.bullet-cap.

%include "util.asm"
%include "common.asm"

; Address range spanned by .text
address_range:  ; HEADER: AUTO
    dd 0x401000
    dd 0x496305

bullet_replacements:  ; HEADER: AUTO
istruc CapGameData
    at CapGameData.old_cap, dd 0x7d0
    at CapGameData.elem_size, dd 0xa34
iend
    dd 0x7d0
    dd SCALE_1
    dd BLACKLIST_BEGIN
    dd 0x4398f9 - 4  ; unknown
    dd 0x463ca7 - 4  ; weird, possibly unused function
    dd 0x4734de + 2  ; coincidental appearance in a jump
    dd BLACKLIST_END

    dd 0x7d1
    dd SCALE_1
    dd REPLACE_ALL

    dd LIST_END

laser_replacements:  ; HEADER: AUTO
istruc CapGameData
    at CapGameData.old_cap, dd 0x100
    at CapGameData.elem_size, dd 0
iend
    dd 0x100
    dd SCALE_1
    dd WHITELIST_BEGIN
    dd 0x420411 - 4  ; LaserManager::allocate_new_laser
    ; The rest are inlined calls to the above function.
    ; Find them via crossrefs to the Laser subclass constructors, as well as crossrefs to
    ; the subclass vtables in case a constructor was inlined.
    dd 0x422466 - 4
    dd 0x422f32 - 4
    dd 0x4240c0 - 4
    dd 0x424b59 - 4
    dd 0x4276fe - 4
    dd WHITELIST_END
    dd LIST_END

cancel_replacements:  ; HEADER: AUTO
istruc CapGameData
    at CapGameData.old_cap, dd 0xc8
    at CapGameData.elem_size, dd 0x4f4
iend
    dd 0xc8
    dd SCALE_1
    dd WHITELIST_BEGIN
    ; (to find these I searched for 0x4f4 to find item loops...)
    dd 0x41f04f - 4
    dd 0x41fa3e - 4
    dd 0x41fa6a - 4
    dd 0x41fa82 - 4
    dd 0x41f882 - 4
    dd 0x41f40a - 4
    dd 0x41f320 - 4
    dd 0x41f28e - 4
    dd 0x495b0a - 4
    dd WHITELIST_END

    dd 0x3dea0  ; array size
    dd SCALE_SIZE
    dd REPLACE_ALL

    dd LIST_END

bullet_mgr_layout:  ; HEADER: AUTO
istruc LayoutHeader
    at LayoutHeader.offset_to_replacements, dd bullet_mgr_layout.replacements - bullet_mgr_layout
iend
    dd REGION_NORMAL(0)
    dd REGION_ARRAY(0x64, CAPID_BULLET, SCALE_SIZE)
    dd REGION_NORMAL(0x4fc0d8)
    dd REGION_END(0x4fc0dc)
.replacements:
    dd REP_OFFSET(0x4fbbb6), REPLACE_ALL  ; offset of dummy bullet state
    dd REP_OFFSET(0x4fc0d8), REPLACE_ALL  ; offset of bullet.anm
    dd REP_OFFSET(0x4fc0dc), REPLACE_ALL  ; size of bullet manager
    dd REP_OFFSET(0x4fc074), REPLACE_ALL  ; size of bullet array
    dd LIST_END

item_mgr_layout:  ; HEADER: AUTO
istruc LayoutHeader
    at LayoutHeader.offset_to_replacements, dd item_mgr_layout.replacements - item_mgr_layout
iend
    dd REGION_NORMAL(0)
    dd REGION_ARRAY(0x14, CAPID_CANCEL, SCALE_SIZE)
    dd REGION_NORMAL(0x3deb4)
    dd REGION_END(0x3dec8)
.replacements:
    dd REP_OFFSET(0x3deb4), REPLACE_ALL  ; next cancel item index
    dd REP_OFFSET(0x3deb8), REPLACE_ALL  ; num items alive
    dd REP_OFFSET(0x3debc), REPLACE_ALL  ; cancel camera charge multiplier
    dd REP_OFFSET(0x3dec0), REPLACE_ALL  ; on_tick  (why is it here in this game?
    dd REP_OFFSET(0x3dec4), REPLACE_ALL  ; on_draw  (why is it here in this game?)
    dd REP_OFFSET(0x3dec8), REPLACE_ALL  ; struct size
    dd LIST_END

perf_fix_data:  ; HEADER: AUTO
    dd 0  ; unused

iat_funcs:  ; HEADER: AUTO
.GetLastError: dd 0x4971c8
.GetModuleHandleA: dd 0
.GetModuleHandleW: dd 0x497178
.GetProcAddress: dd 0x4970ec
.MessageBoxA: dd 0x497250

corefuncs:  ; HEADER: AUTO
.malloc: dd 0x46b53c
