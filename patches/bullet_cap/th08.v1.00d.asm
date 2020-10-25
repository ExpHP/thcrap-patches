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
    dd 0x4b3b78

bullet_replacements:  ; HEADER: AUTO
istruc ListHeader
    at ListHeader.old_cap, dd 0x600
    at ListHeader.elem_size, dd 0x10b8
iend
    dd 0x600
    dd SCALE_1
    dd WHITELIST_BEGIN
    dd 0x423a9c
    dd 0x423e5c
    dd 0x42421c
    dd 0x424a54
    dd 0x424c74
    dd 0x424e8c
    dd 0x42510c
    dd 0x42520e
    dd 0x4252d3
    dd 0x42f3c8
    dd 0x42f623
    dd 0x42f665
    dd 0x430862
    dd 0x430ae6
    dd 0x430d73
    dd 0x430e3e
    dd 0x4312aa
    dd WHITELIST_END

    dd 0x601
    dd SCALE_1
    dd WHITELIST_BEGIN
    dd 0x42f442
    dd WHITELIST_END

    ; something wierd in BulletManager::on_tick where it needs to wrap, idfk why
    dd 0x645000  ; offset of dummy bullet from beginning of bullet array
    dd SCALE_SIZE
    dd WHITELIST_BEGIN
    dd 0x431b5a
    dd WHITELIST_END

    dd 0x5ff  ; index of last bullet in bullet array
    dd SCALE_1
    dd WHITELIST_BEGIN
    dd 0x431b51
    dd WHITELIST_END

    ; No need to adjust field offsets because we use binhacks to replace the
    ; embedded array with a pointer.

    dd LIST_END

laser_replacements:  ; HEADER: AUTO
istruc ListHeader
    at ListHeader.old_cap, dd 0x100
    at ListHeader.elem_size, dd 0x59c
iend
    dd 0x100
    dd SCALE_1
    dd WHITELIST_BEGIN
    dd 0x42f464 - 4  ; in BulletManager::constructor
    ; To find these, search for the laser size then scour all of the functions you find.
    dd 0x430977 - 4  ; in some cancel func
    dd 0x430c00 - 4  ; in another cancel func
    dd 0x430f7d - 4  ; in BulletManager::shoot_lasers
    dd 0x431bb2 - 4  ; in BulletManager::on_tick
    dd 0x432bb2 - 4  ; in BulletManager::on_draw
    dd WHITELIST_END
    dd LIST_END

cancel_replacements:  ; HEADER: AUTO
istruc ListHeader
    at ListHeader.old_cap, dd 0x830
    at ListHeader.elem_size, dd 0x2e4
iend
    dd 0x830
    dd SCALE_1
    dd WHITELIST_BEGIN
    dd 0x44014d
    dd 0x440183
    dd 0x4401c8
    dd 0x440447
    dd WHITELIST_END

    dd 0x831
    dd SCALE_1
    dd WHITELIST_BEGIN
    dd 0x44001d
    dd WHITELIST_END

    dd 0x17aac0  ; offset of dummy item from beginning of item array
    dd SCALE_SIZE
    dd REPLACE_ALL
    dd LIST_END

bullet_mgr_layout:  ; HEADER: AUTO
istruc LayoutHeader
    at LayoutHeader.location, dd LOCATION_STATIC(0xf54e90)
    at LayoutHeader.offset_to_replacements, dd bullet_mgr_layout.replacements - bullet_mgr_layout
iend
    dd REGION_NORMAL(0)
    dd REGION_ARRAY_POINTERIZED(0x1a880, CAPID_BULLET, SCALE_SIZE)
    dd REGION_ARRAY_POINTERIZED(0x660938, CAPID_LASER, SCALE_SIZE)
    dd REGION_NORMAL(0x6ba538)
    dd REGION_END(0x6ba578)
.replacements:
    ; We pointerized everything so no fields were moved.
    dd LIST_END

item_mgr_layout:  ; HEADER: AUTO
istruc LayoutHeader
    at LayoutHeader.location, dd LOCATION_STATIC(0x1653648)
    at LayoutHeader.offset_to_replacements, dd item_mgr_layout.replacements - item_mgr_layout
iend
    ; NOTE: To reduce binhacks, the last item in the array is not included in the pointerization; this is a dummy item
    ; whose only purpose is to be returned by ItemManager::spawn_item when it fails to create an item.
    ; (this is in contrast to bullets, where the dummy bullet is a sentinel for wraparound and must be pointerized)
    dd REGION_ARRAY_POINTERIZED(0, CAPID_CANCEL, SCALE_SIZE)
    dd REGION_NORMAL(0x17aac0)  ; offset of dummy item
    dd REGION_END(0x17b094)
.replacements:
    ; We pointerized everything so no fields were moved.
    dd LIST_END

perf_fix_data:  ; HEADER: AUTO
    dd 0  ; irrelevant, this game has no VM lists

iat_funcs:  ; HEADER: AUTO
.GetLastError: dd 0x4b4074
.GetModuleHandleA: dd 0x4b40e0
.GetModuleHandleW: dd 0
.GetProcAddress: dd 0x4b40d8
.MessageBoxA: dd 0x4b41e8
