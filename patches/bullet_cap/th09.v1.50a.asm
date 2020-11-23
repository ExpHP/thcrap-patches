; AUTO_PREFIX: ExpHP.bullet-cap.

%include "util.asm"
%include "common.asm"

; Address range spanned by .text
address_range:  ; HEADER: AUTO
    dd 0x401000
    dd 0x48dada

bullet_replacements:  ; HEADER: AUTO
    ; options:bullet-cap is unused in PoFV in favor of more specific options
istruc CapGameData
    at CapGameData.old_cap, dd 0
    at CapGameData.elem_size, dd 0
iend
    dd LIST_END

fairy_bullet_replacements:  ; HEADER: AUTO
istruc CapGameData
    at CapGameData.old_cap, dd 175
    at CapGameData.elem_size, dd 0x10c4
iend
    dd 175
    dd SCALE_1
    dd WHITELIST_BEGIN
    dd 0x41240a  ; BulletManager::reset
    dd 0x412a29  ; BulletManager::shoot_one_bullet
    dd 0x412a4d  ; BulletManager::shoot_one_bullet
    dd 0x414792  ; BulletManager::on_tick
    dd 0x44b621  ; sub_44b500
    dd WHITELIST_END

    dd 176
    dd SCALE_1
    dd WHITELIST_BEGIN
    dd 0x41506b  ; BulletManager::constructor
    dd WHITELIST_END

    dd 0x2e1b0  ; num dwords in array
    dd SCALE_SIZE_DIV(4)
    dd WHITELIST_BEGIN
    dd 0x412486 ; BulletManager::reset_412470
    dd WHITELIST_END

    dd LIST_END

rival_bullet_replacements:  ; HEADER: AUTO
istruc CapGameData
    at CapGameData.old_cap, dd 360
    at CapGameData.elem_size, dd 0x10c4
iend
    dd 360
    dd SCALE_1
    dd WHITELIST_BEGIN
    dd 0x412440  ; BulletManager::reset
    dd 0x412b39  ; BulletManager::shoot_one_bullet
    dd 0x412b62  ; BulletManager::shoot_one_bullet
    dd 0x44b75f  ; sub_44b500
    dd WHITELIST_END

    dd 361
    dd SCALE_1
    dd WHITELIST_BEGIN
    dd 0x415086  ; BulletManager::constructor
    dd WHITELIST_END

    dd 0x5e919  ; num dwords in array
    dd SCALE_SIZE_DIV(4)
    dd WHITELIST_BEGIN
    dd 0x41248f  ; BulletManager::reset_412470
    dd WHITELIST_END

    dd LIST_END

laser_replacements:  ; HEADER: AUTO
istruc CapGameData
    at CapGameData.old_cap, dd 0x30
    at CapGameData.elem_size, dd 0x59c
iend
    dd 0x30
    dd SCALE_1
    dd WHITELIST_BEGIN
    ; BulletManager::shoot_laser has a byte, not a dword
    dd 0x413c15 - 4  ; BulletManager::on_draw
    dd 0x414b5a - 4  ; BulletManager::on_tick
    ; BulletManager::constructor has a byte, not a dword
    dd WHITELIST_END

    dd LIST_END

cancel_replacements:  ; HEADER: AUTO
istruc CapGameData
    at CapGameData.old_cap, dd 0
    at CapGameData.elem_size, dd 0
iend
    dd LIST_END

bullet_mgr_layout:  ; HEADER: AUTO
istruc LayoutHeader
    at LayoutHeader.offset_to_replacements, dd bullet_mgr_layout.replacements - bullet_mgr_layout
iend
    dd REGION_NORMAL(0)
    dd REGION_ARRAY(0x1a900, CAPID_FAIRY_BULLET, SCALE_SIZE)
    dd REGION_ARRAY(0xd2fc0, CAPID_RIVAL_BULLET, SCALE_SIZE)
    dd REGION_ARRAY(0x24d424, CAPID_LASER, SCALE_SIZE)
    dd REGION_NORMAL(0x25e164)
    dd REGION_END(0x25e1c0)
.replacements:
    dd REP_OFFSET(0xd2fc0), REPLACE_ALL  ; rival bullet array
    dd REP_OFFSET(0x24d424), REPLACE_ALL  ; laser array

    dd REP_OFFSET_BETWEEN_DIV(0, 0x25e1c0, 4)  ; 0x97870  - size in dwords
    dd WHITELIST_BEGIN
    dd 0x4123c9  ; BulletManager::reset
    dd WHITELIST_END

    ; The number 536 == 175 + 1 + 360 == total length of bullet arrays put together,
    ; counting the dummy fairy bullet in the middle but not the dummy rival bullet at the end.
    ;
    ; (notice that dividing by the bullet size 0x10c4 gives us a length)
    dd REP_OFFSET_BETWEEN_DIV(0x1a900, 0x24d424 - 0x10c4, 0x10c4)
    dd WHITELIST_BEGIN
    dd 0x40c54d  ; sub_40c530
    dd 0x40c74d  ; sub_40c530
    dd 0x414b30  ; BulletManager::on_tick
    dd WHITELIST_END
    dd LIST_END

item_mgr_layout:  ; HEADER: AUTO
istruc LayoutHeader
    at LayoutHeader.offset_to_replacements, dd item_mgr_layout.replacements - item_mgr_layout
iend
    dd REGION_END(0x0)  ; it dun exist
.replacements:
    dd LIST_END

perf_fix_data:  ; HEADER: AUTO
    dd 0  ; unused

iat_funcs:  ; HEADER: AUTO
.GetLastError: dd 0x48e08c
.GetModuleHandleA: dd 0x48e0dc
.GetModuleHandleW: dd 0
.GetProcAddress: dd 0x48e0d8
.MessageBoxA: dd 0x48e210

corefuncs:  ; HEADER: AUTO
.malloc: dd 0x47b24e
