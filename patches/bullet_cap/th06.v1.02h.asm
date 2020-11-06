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
    dd 0x469a5f

bullet_replacements:  ; HEADER: AUTO
istruc ListHeader
    at ListHeader.old_cap, dd 0x280
    at ListHeader.elem_size, dd 0x5c4
iend
    dd 0x280
    dd SCALE_1
    dd WHITELIST_BEGIN
    dd 0x40b931  ; Enemy::hardcoded_func_00
    dd 0x40c1f5  ; Enemy::hardcoded_func_04
    dd 0x40c3df  ; Enemy::hardcoded_func_04
    dd 0x40d442  ; Enemy::hardcoded_func_08
    dd 0x40d59d  ; Enemy::hardcoded_func_09
    dd 0x40d7dd  ; Enemy::hardcoded_func_11
    dd 0x40de45  ; Enemy::hardcoded_func_15
    dd 0x40df24  ; Enemy::hardcoded_func_15
    dd 0x413492  ; BulletManager::constructor
    dd 0x4135f6  ; BulletManager::shoot_one
    dd 0x41361a  ; BulletManager::shoot_one
    dd 0x413665  ; BulletManager::shoot_one
    dd 0x414192  ; BulletManager::sub_414160_cancels
    dd 0x4143a6  ; BulletManager::sub_414360_cancels
    dd 0x414a32  ; BulletManager::on_tick_0b
    dd 0x4167ae  ; BulletManager::on_draw
    dd 0x416810  ; BulletManager::on_draw
    dd 0x416896  ; BulletManager::on_draw
    dd 0x41691c  ; BulletManager::on_draw
    dd 0x416984  ; BulletManager::on_draw
    dd 0x4169e6  ; BulletManager::on_draw
    dd 0x416a6b  ; BulletManager::on_draw
    dd 0x416af0  ; BulletManager::on_draw
    dd WHITELIST_END

    ; No need to adjust field offsets because we use binhacks to replace the
    ; embedded array with a pointer.

    dd LIST_END

laser_replacements:  ; HEADER: AUTO
istruc ListHeader
    at ListHeader.old_cap, dd 0x40
    at ListHeader.elem_size, dd 0x270
iend
    dd 0x40
    dd SCALE_1
    dd WHITELIST_BEGIN
    ; This is the only place where the cap appears as a dword sized value.
    ; Everywhere else, it appears byte-sized and requires binhacks.
    dd 0x4134e5 - 4  ; BulletManager::constructor
    dd WHITELIST_END
    dd LIST_END

cancel_replacements:  ; HEADER: AUTO
istruc ListHeader
    at ListHeader.old_cap, dd 0x200
    at ListHeader.elem_size, dd 0x144
iend
    dd 0x200
    dd SCALE_1
    dd WHITELIST_BEGIN
    dd 0x41f330 - 4  ; ItemManager::spawn_item
    dd 0x41f2ff - 4  ; ItemManager::spawn_item
    dd 0x41f52e - 4  ; ItemManager::on_tick
    dd 0x420164 - 4  ; ItemManager::sub_420130
    dd 0x4201c4 - 4  ; ItemManager::on_draw
    dd WHITELIST_END

    dd 0x201
    dd SCALE_1
    dd WHITELIST_BEGIN
    dd 0x41f240 - 4  ; ItemManager::constructor
    dd WHITELIST_END

    dd LIST_END

bullet_mgr_layout:  ; HEADER: AUTO
istruc LayoutHeader
    at LayoutHeader.offset_to_replacements, dd bullet_mgr_layout.replacements - bullet_mgr_layout
iend
    dd REGION_NORMAL(0)
    dd REGION_ARRAY_POINTERIZED(0x5600, CAPID_BULLET, SCALE_SIZE)
    dd REGION_ARRAY_POINTERIZED(0xec000, CAPID_LASER, SCALE_SIZE)
    dd REGION_NORMAL(0xf5c00)
    dd REGION_END(0xf5c18)
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
    dd REGION_NORMAL(0x28800)  ; offset of dummy item
    dd REGION_END(0x2894c)
.replacements:
    ; We pointerized everything so no fields were moved.
    dd LIST_END

perf_fix_data:  ; HEADER: AUTO
    dd 0  ; irrelevant, this game has no VM lists

pointerize_data:  ; HEADER: AUTO
istruc PointerizeData
    at PointerizeData.bullet_mgr_base, dd 0x5a5ff8
    at PointerizeData.bullet_array_ptr, dd 0x5a5ff8 + 0x5600
    at PointerizeData.laser_array_ptr, dd 0x5a5ff8 + 0xec000
    at PointerizeData.item_mgr_base, dd 0x69e268
    at PointerizeData.item_array_ptr, dd 0x69e268 + 0x0
    at PointerizeData.bullet_size, dd 0x5c4
    at PointerizeData.laser_size, dd 0x270
    at PointerizeData.item_size, dd 0x144
    at PointerizeData.bullet_state_dummy_value, dd -1
    at PointerizeData.bullet_state_offset, dd -1
    at PointerizeData.bullet_mgr_size, dd 0xf5c18
    at PointerizeData.item_mgr_size, dd 0x2894c
iend

iat_funcs:  ; HEADER: AUTO
.GetLastError: dd 0x46a074
.GetModuleHandleA: dd 0x46a0d0
.GetModuleHandleW: dd 0
.GetProcAddress: dd 0x46a06c
.MessageBoxA: dd 0x46a1f4

corefuncs:  ; HEADER: AUTO
.malloc: dd 0x45bf24
