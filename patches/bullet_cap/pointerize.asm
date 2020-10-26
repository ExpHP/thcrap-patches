; THIS IS NOT A SOURCE FILE
;
; Changing anything in this file will NOT have any effect on the patch.
; This file is where I write the initial asm for many binhacks. Use
;
;     scripts/list-asm <path_to_file>
;
; and copy the parts you need to the places they belong in the yaml.

; AUTO_PREFIX: ExpHP.bullet-cap.

%include "util.asm"
%include "common.asm"

%define BULLET_STATE 

new_bullet_cap_bigendian:  ; DELETE
new_laser_cap_bigendian:  ; DELETE
new_cancel_cap_bigendian:  ; DELETE


pointerize_data_07:  ; HEADER: AUTO
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
    at PointerizeData.func_malloc, dd 0x47d441
iend

pointerize_data_08:  ; HEADER: AUTO
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
; The main, meaty binhacks:
;
; These make pointer allocations for the arrays, and make sure that memsets of the structs
; take these new pointers into account.

; TH07: 0x423388  (8b4de883e901)  (in BulletManager::constructor (life before main))
; TH08: 0x42f43c  (6800f54200)    (in BulletManager::constructor (life before main))
pointerize_bullets_constructor:  ; HEADER: AUTO
    call allocate_pointerized_bmgr_arrays  ; REWRITE: [codecave:AUTO]
    ; skip to after lasers are finished initializing
    abs_jmp_hack 0x4233e5  ; TH07
    abs_jmp_hack 0x42f478  ; TH08

; TH07: 0x43264d (8b4df883e901)
; TH08: 0x440017 (6850004400)
pointerize_items_constructor:  ; HEADER: AUTO
    call allocate_pointerized_imgr_arrays  ; REWRITE: [codecave:AUTO]
    abs_jmp_hack 0x43266f  ; TH07
    abs_jmp_hack 0x44002f  ; TH08

; TH07: 0x4232e8  (b959e80d00)  (in BulletManager::reset)
; TH08: 0x42f36a  (b95ee91a00)  (in BulletManager::reset)
pointerize_bullets_keep_the_pointers:  ; HEADER: AUTO
    call clear_pointerized_bullet_mgr  ; REWRITE: [codecave:AUTO]
    ; Skip to immediately after the rep stosd.
    abs_jmp_hack 0x4232f4  ; TH07
    abs_jmp_hack 0x42f376  ; TH08

; TH07: 0x4275f1  (b95fb90200)
; TH08: 0x4337ff  (8b7dfcf3ab)
pointerize_items_keep_the_pointer:  ; HEADER: AUTO
    call clear_pointerized_item_mgr  ; REWRITE: [codecave:AUTO]
    ; after the rep stosd
    abs_jmp_hack 0x4275ff  ; TH07
    abs_jmp_hack 0x433804  ; TH08

;-------------------
; binhacks to replace 'mov dword [ebp-0xXX], BULLET_ARRAY'

; TH07: 0x417c3d  (c745f8 18b26300)  (in a funcSet/funcCall func)
; TH07: 0x418ee0  (c745f8 18b26300)  (in a funcSet/funcCall func)
; TH07: 0x4194ec  (c745f8 18b26300)  (in a funcSet/funcCall func)
; TH07: 0x41961c  (c745f8 18b26300)  (in a funcSet/funcCall func)
; TH07: 0x419897  (c745f8 18b26300)  (in a funcSet/funcCall func)
; TH07: 0x4199cc  (c745f8 18b26300)  (in a funcSet/funcCall func)
; TH07: 0x4277a9  (c745f8 18b26300)  (in an unknown func)
; TH08: 0x424a2c  (c745f8 10f7f600)  (in a funcSet/funcCall func)
; TH08: 0x424c4c  (c745f8 10f7f600)  (in a funcSet/funcCall func)
; TH08: 0x424e5c  (c745f8 10f7f600)  (in a funcSet/funcCall func)
; TH08: 0x4250dc  (c745f8 10f7f600)  (in a funcSet/funcCall func)
; TH08: 0x4251e6  (c745f8 10f7f600)  (in a funcSet/funcCall func)
; TH08: 0042f3a0  (c745f8 10f7f600)  (in BulletManager::reset_bullet_array)
pointerize_bullets_static_08:  ; HEADER: AUTO
    call get_pointerized_bullet_array_eax  ; REWRITE: [codecave:AUTO]
    mov  dword [ebp-0x08], eax
    ret

; TH07: 0x418fcc  (c745f4 18b26300)  (in a funcSet/funcCall func)
; TH08: 0x423a6c  (c745f4 10f7f600)  (in a funcSet/funcCall func)
; TH08: 0x423e2c  (c745f4 10f7f600)  (in a funcSet/funcCall func)
; TH08: 0x4241ec  (c745f4 10f7f600)  (in a funcSet/funcCall func)
; TH08: 0x42529c  (c745f4 10f7f600)  (in a funcSet/funcCall func)
pointerize_bullets_static_0c:  ; HEADER: AUTO
    call get_pointerized_bullet_array_eax  ; REWRITE: [codecave:AUTO]
    mov  dword [ebp-0x0c], eax
    ret

; TH07: 0x424c0a  (c745ec 18b26300) (in a cancel func)
; TH08: 0x430d3a  (c745ec 10f7f600) (in a cancel func)
pointerize_bullets_static_14:  ; HEADER: AUTO
    call get_pointerized_bullet_array_eax  ; REWRITE: [codecave:AUTO]
    mov  dword [ebp-0x14], eax
    ret

; TH07: 0x42474a  (c745e8 18b26300) (in a cancel func)
; TH07: 0x4249be  (c745e8 18b26300) (in a cancel func)
; TH08: 0x430abe  (c745e8 10f7f600) (in a cancel func)
pointerize_bullets_static_18:  ; HEADER: AUTO
    call get_pointerized_bullet_array_eax  ; REWRITE: [codecave:AUTO]
    mov  dword [ebp-0x18], eax
    ret

; TH07: 0x41896a  (c745e4 18b26300) (in a funcSet/funcCall func)
; TH08: 0x43083a  (c745e4 10f7f600) (in a cancel func)
pointerize_bullets_static_1c:  ; HEADER: AUTO
    call get_pointerized_bullet_array_eax  ; REWRITE: [codecave:AUTO]
    mov  dword [ebp-0x1c], eax
    ret

; TH07: 0x418c45  (c745e0 18b26300) (in a funcSet/funcCall func)
pointerize_bullets_static_20:  ; HEADER: AUTO
    call get_pointerized_bullet_array_eax  ; REWRITE: [codecave:AUTO]
    mov  dword [ebp-0x20], eax
    ret

; TH07: 0x418136  (c78520ffffff 18b26300) (in a funcSet/funcCall func)
; TH07: 0x4182e6  (c78520ffffff 18b26300) (in a funcSet/funcCall func)
pointerize_bullets_static_e0:  ; HEADER: AUTO
    call get_pointerized_bullet_array_eax  ; REWRITE: [codecave:AUTO]
    mov  dword [ebp-0xe0], eax
    ret

; TH07: 0x419106  (c7851cffffff 18b26300) (in a funcSet/funcCall func)
; TH07: 0x419726  (c7851cffffff 18b26300) (in a funcSet/funcCall func)
pointerize_bullets_static_e4:  ; HEADER: AUTO
    call get_pointerized_bullet_array_eax  ; REWRITE: [codecave:AUTO]
    mov  dword [ebp-0xe4], eax
    ret

; TH07: 0x417e66  (c78518ffffff 18b26300) (in a funcSet/funcCall func)
; TH07: 0x419a66  (c78518ffffff 18b26300) (in a funcSet/funcCall func)
; TH07: 0x419dd6  (c78518ffffff 18b26300) (in a funcSet/funcCall func)
; TH07: 0x41a006  (c78518ffffff 18b26300) (in a funcSet/funcCall func)
pointerize_bullets_static_e8:  ; HEADER: AUTO
    call get_pointerized_bullet_array_eax  ; REWRITE: [codecave:AUTO]
    mov  dword [ebp-0xe8], eax
    ret

;-------------------
; binhacks to replace 'add reg, BULLET_ARRAY_OFFSET'

; TH07: 0x4232f7  (05 c0b80000) (in BulletManager::reset)
; TH07: 0x425a6c  (05 c0b80000) (in BulletManager::on_tick)
; TH07: 0x423380  (05 c0b80000) (in BulletManager::constructor)
; TH08: 0x42f379  (05 80a80100) (in BulletManager::reset_bullet_array)
; TH08: 0x431254  (05 80a80100) (in BulletManager::on_tick)
pointerize_bullets_offset_eax:  ; HEADER: AUTO
    call get_pointerized_bullet_array_eax  ; REWRITE: [codecave:AUTO]
    ret

; TH07: 0x42423e  (81c1 c0b80000) (in BulletManager::shoot_one)
; TH08: 0x42f44e  (81c1 80a80100) (in BulletManager::constructor)
pointerize_bullets_offset_ecx:  ; HEADER: AUTO
    push eax
    call get_pointerized_bullet_array_eax  ; REWRITE: [codecave:AUTO]
    mov  ecx, eax
    pop  eax
    ret

; TH07: 0x4237a3  (81c2 c0b80000) (in BulletManager::shoot_one)
; TH08: 0x42f657  (81c2 80a80100) (in BulletManager::shoot_one)
; TH08: 0x42fe23  (81c2 80a80100) (in BulletManager::shoot_one)
pointerize_bullets_offset_edx:  ; HEADER: AUTO
    push eax
    call get_pointerized_bullet_array_eax  ; REWRITE: [codecave:AUTO]
    mov  edx, eax
    pop  eax
    ret

;-------------------
; binhacks to replace 'add reg, LASER_ARRAY_OFFSET'

; TH07: 0x4233bb  (05 28663600) (in BulletManager::constructor)
; TH07: 0x42480a  (05 28663600) (in a cancel func)
; TH07: 0x424e0c  (05 28663600) (in BulletManager::shoot_laser)
; TH07: 0x426c4c  (05 28663600) (in BulletManager::on_draw)
; TH08: 0x430bcb  (05 38096600) (in a cancel func)
; TH08: 0x430f2c  (05 38096600) (in BulletManager::shoot_laser)
; TH08: 0x431b75  (05 38096600) (in BulletManager::on_tick)
pointerize_lasers_offset_eax:  ; HEADER: AUTO
    call get_pointerized_laser_array_eax  ; REWRITE: [codecave:AUTO]
    ret

; TH07: 0x4263c6  (81c1 28663600) (in BulletManager::on_tick)
; TH08: 0x432b7b  (81c1 38096600) (in BulletManager::on_draw)
pointerize_lasers_offset_ecx:  ; HEADER: AUTO
    push eax
    call get_pointerized_laser_array_eax  ; REWRITE: [codecave:AUTO]
    mov  ecx, eax
    pop  eax
    ret

; TH07: 0x424a8a  (81c2 28663600) (in a cancel func)
; TH08: 0x42f46c  (81c2 38096600) (in BulletManager::constructor)
; TH08: 0x430941  (81c2 38096600) (in a cancel func)
pointerize_lasers_offset_edx:  ; HEADER: AUTO
    push eax
    call get_pointerized_laser_array_eax  ; REWRITE: [codecave:AUTO]
    mov  edx, eax
    pop  eax
    ret

; ==============================================
; Fix places that assume the item manager and array share the same address.

; Fix the line near the top where it gets the item at the next unused index.
; TH07: 0x432708  (8b55e803d1)
pointerize_items_spawn_07:  ; HEADER: AUTO
    mov  edx, [ebp-0x18]
    mov  edx, [edx]  ; follow pointer
    add  edx, ecx
    abs_jmp_hack 0x43270d
; TH08: 0x4400b8  (8b55f403d1)
pointerize_items_spawn_08:  ; HEADER: AUTO
    mov  edx, [ebp-0xc]
    mov  edx, [edx]  ; follow pointer
    add  edx, ecx
    abs_jmp_hack 0x4400bd

; Fix the bit where the index wraps around and it sets it back to the first item.
; TH07: 0x432795  (8b45e88945f8)
pointerize_items_spawn_wrap_07:  ; HEADER: AUTO
    mov  eax, [ebp-0x18]
    mov  eax, [eax]   ; added instruction
    mov  [ebp-0x8], eax
    abs_jmp_hack 0x4327a9  ; next basic block
; TH08: 0x440196  (8b4df4894df8)
pointerize_items_spawn_wrap_08:  ; HEADER: AUTO
    mov  ecx, [ebp-0xc]
    mov  ecx, [ecx]   ; added instruction
    mov  [ebp-0x8], ecx
    abs_jmp_hack 0x4401aa  ; next basic block

; In TH07, on_tick doesn't use the list (it *builds* the list).
; TH07: 0x4329a0  (8b8534ffffff)
pointerize_items_on_tick_07:  ; HEADER: AUTO
    mov  eax, dword [ebp-0xcc]
    mov  eax, [eax]   ; added instruction
    mov  dword [ebp-0x24], eax
    abs_jmp_hack 0x4329a9

; TH07 has some additional places that iterate over the array (in TH08 they use the list).
;
; Fortuitously, all three functions contain the exact instructions
;      mov     dword [ebp-0x8], eax  ; where eax should have the item array
;      mov     dword [ebp-0x4], 0x0
; so we can write a single binhack.
;
; TH07: 0x433a9c  (8945f8c745fc00000000)
; TH07: 0x433b2c  (8945f8c745fc00000000)
; TH07: 0x433c4c  (8945f8c745fc00000000)
pointerize_items_other_funcs_07:  ; HEADER: AUTO
    mov  eax, [eax]
    mov  dword [ebp-0x8], eax
    mov  dword [ebp-0x4], 0x0
    ret

; ==============================================

allocate_pointerized_bmgr_arrays:  ; DELETE
allocate_pointerized_imgr_arrays:  ; DELETE
clear_pointerized_bullet_mgr:  ; DELETE
clear_pointerized_item_mgr:  ; DELETE
get_pointerized_bullet_array_eax:  ; DELETE
get_pointerized_laser_array_eax:  ; DELETE
