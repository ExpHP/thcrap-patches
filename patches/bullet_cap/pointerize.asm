; THIS IS NOT A SOURCE FILE
;
; Changing anything in this file will NOT have any effect on the patch.
; This file is where I write the initial asm for many binhacks. Use
;
;     scripts/list-asm source/x.asm
;
; and copy the parts you need to the places they belong in the yaml.

; AUTO_PREFIX: ExpHP.bullet-cap.

%include "util.asm"
%include "common.asm"

%define BULLET_STATE 

new_bullet_cap_bigendian:  ; DELETE
new_laser_cap_bigendian:  ; DELETE
new_cancel_cap_bigendian:  ; DELETE

pointerize_data:  ; HEADER: AUTO
istruc PointerizeData
    at PointerizeData.bullet_mgr_base, dd 0xf54e90
    at PointerizeData.bullet_array_ptr, dd 0xf54e90 + 0x1a880
    at PointerizeData.laser_array_ptr, dd 0xf54e90 + 0x660938
    at PointerizeData.item_mgr_base, dd 0x1653648
    at PointerizeData.item_array_ptr, dd 0x1653648 + 0x0
    at PointerizeData.bullet_size, dd 0x10b8
    at PointerizeData.laser_size, dd 0x59c
    at PointerizeData.item_size, dd 0x2e4
    at PointerizeData.bullet_state_dummy_value, dd 6
    at PointerizeData.bullet_state_offset, dd 0xdb8
    at PointerizeData.bullet_mgr_size, dd 0x6ba578
    at PointerizeData.item_mgr_size, dd 0x17b094
    at PointerizeData.func_malloc, dd 0x4a43d4
iend

; ==========================================

; TH08: 0x42f43c  (6800f54200)  (in BulletManager::constructor (life before main))
pointerize_bullets_constructor:  ; HEADER: AUTO
    call allocate_pointerized_bmgr_arrays  ; REWRITE: [codecave:AUTO]
    abs_jmp_hack 0x42f478

; TH08: 0x42f36a  (b95ee91a00)  (in BulletManager::reset)
pointerize_bullets_keep_the_pointers:  ; HEADER: AUTO
    call clear_pointerized_bullet_mgr  ; REWRITE: [codecave:AUTO]
    abs_jmp_hack 0x42f376

; TH08: 0x423a6c  (c745f410f7f600)  (in a funcSet/funcCall func)
; TH08: 0x423e2c  (c745f410f7f600)  (in a funcSet/funcCall func)
; TH08: 0x4241ec  (c745f410f7f600)  (in a funcSet/funcCall func)
; TH08: 0x42529c  (c745f410f7f600)  (in a funcSet/funcCall func)
pointerize_bullets_static_0c:  ; HEADER: AUTO
    call get_pointerized_bullet_array_eax  ; REWRITE: [codecave:AUTO]
    mov  dword [ebp-0x0c], eax
    ret

; TH08: 0x424a2c  (c745f810f7f600)  (in a funcSet/funcCall func)
; TH08: 0x424c4c  (c745f810f7f600)  (in a funcSet/funcCall func)
; TH08: 0x424e5c  (c745f810f7f600)  (in a funcSet/funcCall func)
; TH08: 0x4250dc  (c745f810f7f600)  (in a funcSet/funcCall func)
; TH08: 0x4251e6  (c745f810f7f600)  (in a funcSet/funcCall func)
; TH08: 0042f3a0  (c745f810f7f600)  (in BulletManager::reset_bullet_array)
pointerize_bullets_static_08:  ; HEADER: AUTO
    call get_pointerized_bullet_array_eax  ; REWRITE: [codecave:AUTO]
    mov  dword [ebp-0x08], eax
    ret

; TH08: 0x43083a  (c745e410f7f600) (in some cancel func)
pointerize_bullets_static_1c:  ; HEADER: AUTO
    call get_pointerized_bullet_array_eax  ; REWRITE: [codecave:AUTO]
    mov  dword [ebp-0x1c], eax
    ret

; TH08: 0x430abe  (c745e810f7f600) (in another cancel func)
pointerize_bullets_static_18:  ; HEADER: AUTO
    call get_pointerized_bullet_array_eax  ; REWRITE: [codecave:AUTO]
    mov  dword [ebp-0x18], eax
    ret

; TH08: 0x430d3a  (c745ec10f7f600) (in yet another cancel func)
pointerize_bullets_static_14:  ; HEADER: AUTO
    call get_pointerized_bullet_array_eax  ; REWRITE: [codecave:AUTO]
    mov  dword [ebp-0x14], eax
    ret

; TH08: 0x42f379  (0580a80100) (in BulletManager::reset_bullet_array)
; TH08: 0x431254  (0580a80100) (in BulletManager::on_tick)
pointerize_bullets_offset_eax:  ; HEADER: AUTO
    call get_pointerized_bullet_array_eax  ; REWRITE: [codecave:AUTO]
    ret

; TH08: 0x42f657  (81c280a80100) (in BulletManager::shoot_one_bullet)
; TH08: 0x42fe23  (81c280a80100) (in BulletManager::shoot_one_bullet)
pointerize_bullets_offset_edx:  ; HEADER: AUTO
    push eax
    call get_pointerized_bullet_array_eax  ; REWRITE: [codecave:AUTO]
    mov  edx, eax
    pop  eax
    ret

; TH08: 0x00430bcc  (0538096600)  (in another cancel func)
; TH08: 0x00430f2d  (0538096600)  (in BulletManager::shoot_lasers)
; TH08: 0x00431b76  (0538096600)  (in BulletManager::on_tick)
pointerize_lasers_offset_eax:  ; HEADER: AUTO
    call get_pointerized_laser_array_eax  ; REWRITE: [codecave:AUTO]
    ret

; TH08: 0x0042f46e  (81c238096600)  (in BulletManager::constructor)
; TH08: 0x00430943  (81c238096600)  (in a cancel func)
pointerize_lasers_offset_edx:  ; HEADER: AUTO
    push eax
    call get_pointerized_laser_array_eax  ; REWRITE: [codecave:AUTO]
    mov  edx, eax
    pop  eax
    ret

; TH08: 0x00432b7d  (81c138096600)  (in BulletManager::on_draw)
pointerize_lasers_offset_ecx:  ; HEADER: AUTO
    push eax
    call get_pointerized_laser_array_eax  ; REWRITE: [codecave:AUTO]
    mov  ecx, eax
    pop  eax
    ret

; ==============================================

; TH08: 0x440021 (68e4020000)
pointerize_items_constructor:  ; HEADER: AUTO
    ; The line before this pushed the cancel cap + 1 (and we couldn't replace
    ; it because bullet_cap promises to preserve and replace such values).
    ;
    ; However we can't use it because this runs before our search and
    ; replace code, so just ignore it.
    add  esp, 0x4
    call allocate_pointerized_imgr_arrays  ; REWRITE: [codecave:AUTO]
    abs_jmp_hack 0x44002f

; TH08: 0x4337ff  (8b7dfcf3ab)
pointerize_items_keep_the_pointer:  ; HEADER: AUTO
    call clear_pointerized_item_mgr  ; REWRITE: [codecave:AUTO]
    ; after the rep stosd
    abs_jmp_hack 0x433804

; TH08: 0x4400b8  (8b55f403d1)
pointerize_items_spawn:  ; HEADER: AUTO
    mov  edx, [ebp-0xc]
    mov  edx, [edx]  ; follow pointer
    add  edx, ecx
    abs_jmp_hack 0x4400bd

; TH08: 0x440196  (8b4df4894df8)
pointerize_items_spawn_wrap:
    mov  ecx, [ebp-0xc]
    mov  ecx, [ecx]   ; added instruction
    mov  [ebp-0x8], ecx
    abs_jmp_hack 0x4401aa

; ==============================================

allocate_pointerized_bmgr_arrays:  ; DELETE
allocate_pointerized_imgr_arrays:  ; DELETE
clear_pointerized_bullet_mgr:  ; DELETE
clear_pointerized_item_mgr:  ; DELETE
get_pointerized_bullet_array_eax:  ; DELETE
get_pointerized_laser_array_eax:  ; DELETE
