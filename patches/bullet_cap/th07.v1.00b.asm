; AUTO_PREFIX: ExpHP.bullet-cap.

%include "util.asm"
%include "common.asm"

; ===============================

; Override functions from base_exphp.
; REMINDER: These functions must additionally preserve ecx and edx.

adjust_bullet_array:  ; HEADER: base-exphp.adjust-bullet-array
    mov  eax, [esp+0x4]
    mov  eax, [eax]  ; deref pointer
    ret
adjust_laser_array:  ; HEADER: base-exphp.adjust-laser-array
    mov  eax, [esp+0x4]
    mov  eax, [eax]  ; deref pointer
    ret
adjust_cancel_array:  ; HEADER: base-exphp.adjust-cancel-array
    mov  eax, [esp+0x4]
    mov  eax, [eax]  ; deref pointer
    ret

; ===============================

; Address range spanned by .text
address_range:  ; HEADER: AUTO
    dd 0x401000
    dd 0x48cd38

bullet_replacements:  ; HEADER: AUTO
istruc ListHeader
    at ListHeader.old_cap, dd 0x400
    at ListHeader.elem_size, dd 0xd68
iend
    dd 0x400
    dd SCALE_1
    dd WHITELIST_BEGIN

    dd 0x417c92  ; Enemy::hardcoded_func_01_s2_call
    dd 0x417f45  ; Enemy::hardcoded_func_02_s2_call
    dd 0x4181a8  ; Enemy::hardcoded_func_04_s378_set
    dd 0x418339  ; Enemy::hardcoded_func_06_s3_call
    dd 0x418992  ; Enemy::hardcoded_func_07_s4_set
    dd 0x418c6c  ; Enemy::hardcoded_func_08_s4_set
    dd 0x418f08  ; Enemy::hardcoded_func_10_s5678_call
    dd 0x419003  ; Enemy::hardcoded_func_11_s5678_call
    dd 0x4191cc  ; Enemy::hardcoded_func_12_s5_call
    dd 0x419514  ; Enemy::hardcoded_func_13_s5_set
    dd 0x41965c  ; Enemy::hardcoded_func_14_s5_call
    dd 0x41976d  ; Enemy::hardcoded_func_16_s6_call
    dd 0x4198f4  ; Enemy::hardcoded_func_17_s6_call
    dd 0x419a01  ; Enemy::hardcoded_func_18_s6_call
    dd 0x419af9  ; Enemy::hardcoded_func_21_s5_call_hl
    dd 0x419e58  ; Enemy::hardcoded_func_22_s7_set
    dd 0x41a084  ; Enemy::hardcoded_func_23_s8_set

    dd 0x42376c  ; BulletManager::shoot_one
    dd 0x4237b1  ; BulletManager::shoot_one
    dd 0x424772  ; BulletManager::sub_424740_cancels_bullets
    dd 0x4249e6  ; BulletManager::sub_4249a0_cancels_bullets
    dd 0x424c3b  ; BulletManager::sub_424c00_cancels_bullets
    dd 0x424d2f  ; BulletManager::shoot_bullets

    dd 0x425b18  ; BulletManager::on_tick_0c
    dd 0x4277d1  ; BulletManager::sub_4277a0
    dd WHITELIST_END

    dd 0x401
    dd SCALE_1
    dd WHITELIST_BEGIN
    dd 0x423372  ; BulletManager::constructor
    dd WHITELIST_END

    ; something wierd in BulletManager::on_tick where it needs to wrap, idfk why
    dd 0x35a000  ; offset of dummy bullet from beginning of bullet array
    dd SCALE_SIZE
    dd WHITELIST_BEGIN
    dd 0x4263a9  ; BulletManager::on_tick
    dd WHITELIST_END

    dd 0x3ff  ; index of last bullet in bullet array
    dd SCALE_1
    dd WHITELIST_BEGIN
    dd 0x4263a0  ; BulletManager::on_tick
    dd WHITELIST_END

    ; No need to adjust field offsets because we use binhacks to replace the
    ; embedded array with a pointer.

    dd LIST_END

laser_replacements:  ; HEADER: AUTO
istruc ListHeader
    at ListHeader.old_cap, dd 0x40
    at ListHeader.elem_size, dd 0x4ec
iend
    dd 0x40
    dd SCALE_1
    dd WHITELIST_BEGIN
    ; This is the only place where the cap appears as a dword sized value.
    ; Everywhere else, it appears byte-sized and requires binhacks.
    dd 0x4233b1 - 4  ; BulletManager::constructor
    dd WHITELIST_END
    dd LIST_END

cancel_replacements:  ; HEADER: AUTO
istruc ListHeader
    at ListHeader.old_cap, dd 0x44c
    at ListHeader.elem_size, dd 0x288
iend
    dd 0x44c
    dd SCALE_1
    dd WHITELIST_BEGIN
    dd 0x43274c  ; ItemManager::spawn_item
    dd 0x432782  ; ItemManager::spawn_item
    dd 0x4327b4  ; ItemManager::spawn_item
    dd 0x432961  ; ItemManager::spawn_item
    dd 0x432a32  ; ItemManager::on_tick
    dd 0x433ac0  ; ItemManager::sub_433a90 (autocollect related?)
    dd 0x433b50  ; ItemManager::sub_433b20 (autocollect related?)
    dd 0x433c70  ; ItemManager::sub_433c40 (autocollect related?)
    dd WHITELIST_END

    dd 0x44d
    dd SCALE_1
    dd WHITELIST_BEGIN
    dd 0x43263c  ; ItemManager::constructor
    dd WHITELIST_END

    dd LIST_END

bullet_mgr_layout:  ; HEADER: AUTO
istruc LayoutHeader
    at LayoutHeader.offset_to_replacements, dd bullet_mgr_layout.replacements - bullet_mgr_layout
iend
    dd REGION_NORMAL(0)
    dd REGION_ARRAY_POINTERIZED(0xb8c0, CAPID_BULLET, SCALE_SIZE)
    dd REGION_ARRAY_POINTERIZED(0x366628, CAPID_LASER, SCALE_SIZE)
    dd REGION_NORMAL(0x37a128)
    dd REGION_END(0x37a164)
.replacements:
    ; We pointerized everything so no fields were moved.
    dd LIST_END

item_mgr_layout:  ; HEADER: AUTO
istruc LayoutHeader
    at LayoutHeader.offset_to_replacements, dd item_mgr_layout.replacements - item_mgr_layout
iend
    ; NOTE: To reduce binhacks, the last item in the array is not included in the pointerization; this is a dummy item
    ; whose only purpose is to be returned by ItemManager::spawn_item when it fails to create an item.
    ; (this is in contrast to bullets, where the dummy bullet is a sentinel for wraparound and must be pointerized)
    dd REGION_ARRAY_POINTERIZED(0, CAPID_CANCEL, SCALE_SIZE)
    dd REGION_NORMAL(0xae060)  ; offset of dummy item
    dd REGION_END(0xae57c)
.replacements:
    ; We pointerized everything so no fields were moved.
    dd LIST_END

perf_fix_data:  ; HEADER: AUTO
    dd 0  ; irrelevant, this game has no VM lists

pointerize_data:  ; HEADER: AUTO
istruc PointerizeData
    at PointerizeData.bullet_mgr_base, dd 0x62f958
    at PointerizeData.bullet_array_ptr, dd 0x62f958 + 0xb8c0
    at PointerizeData.laser_array_ptr, dd 0x62f958 + 0x366628
    at PointerizeData.item_mgr_base, dd 0x575c70
    at PointerizeData.item_array_ptr, dd 0x575c70 + 0x0
    at PointerizeData.bullet_size, dd 0xd68
    at PointerizeData.laser_size, dd 0x4ec
    at PointerizeData.item_size, dd 0x288
    at PointerizeData.bullet_state_dummy_value, dd 6
    at PointerizeData.bullet_state_offset, dd 0xbfc
    at PointerizeData.bullet_mgr_size, dd 0x37a164
    at PointerizeData.item_mgr_size, dd 0xae57c
iend

iat_funcs:  ; HEADER: AUTO
.GetLastError: dd 0x48d07c
.GetModuleHandleA: dd 0x48d188
.GetModuleHandleW: dd 0
.GetProcAddress: dd 0x48d05c
.MessageBoxA: dd 0x48d1e4

corefuncs:  ; HEADER: AUTO
.malloc: dd 0x47d441
