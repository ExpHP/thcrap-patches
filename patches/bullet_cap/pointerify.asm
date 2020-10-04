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

%define BULLET_MANAGER_BASE 0xf54e90
%define BULLET_ARRAY_PTR    (BULLET_MANAGER_BASE + 0x1a880)
%define LASER_ARRAY_PTR     (BULLET_MANAGER_BASE + 0x660938)
%define BULLET_MANAGER_NUM_DWORDS 0x1ae95e

%define BULLET_SIZE 0x10b8
%define BULLET_STATE 0xdb8
%define LASER_SIZE 0x59c

%define FUNC_ITEM_CONSTRUCTOR 0x440050
%define ITEM_ARRAY_PTR 0x1653648
%define ITEM_SIZE 0x2e4

%define FUNC_INITIALIZE_VECTOR 0x406850
%define FUNC_MALLOC 0x4a43d4

new_bullet_cap_bigendian:  ; DELETE
new_laser_cap_bigendian:  ; DELETE
new_cancel_cap_bigendian:  ; DELETE

; ==========================================

; 0x42f43c  (6800f54200)  (in BulletManager::constructor (life before main))
pointerify_bullets_constructor:  ; HEADER: AUTO
    ; Allocate space for the bullets.
    ;
    ; This is not what the original code did (which called default value initializers on a
    ; static bullet array).  And we don't need to worry about calling those initializers
    ; because the bullets are about to be memset to 0 anyways.
    mov  eax, [new_bullet_cap_bigendian]  ; REWRITE: <codecave:bullet-cap>
    bswap eax
    inc  eax  ; plus dummy bullet
    imul eax, BULLET_SIZE
    push eax
    mov  eax, FUNC_MALLOC
    call eax
    add  esp, 0x4  ; caller cleans stack
    mov  [BULLET_ARRAY_PTR], eax

    ; oh and uhhh lasers too cause they're on the same struct
    mov  eax, [new_laser_cap_bigendian]  ; REWRITE: <codecave:laser-cap>
    bswap eax
    imul eax, LASER_SIZE
    push eax
    mov  eax, FUNC_MALLOC
    call eax
    add  esp, 0x4  ; caller cleans stack
    mov  [LASER_ARRAY_PTR], eax
    abs_jmp_hack 0x42f478

; 0x42f36a  (b95ee91a00)  (in BulletManager::reset)
pointerify_bullets_keep_the_pointers:  ; HEADER: AUTO
    push esi  ; save
    ; Keep the pointer when the struct is memset to 0.
    push dword [BULLET_ARRAY_PTR]
    push dword [LASER_ARRAY_PTR]

    ; memset the entire struct (this is the original code)
    mov  ecx, BULLET_MANAGER_NUM_DWORDS
    xor  eax, eax
    mov  edi, dword [ebp-0xc]
    rep stosd

    pop  dword [LASER_ARRAY_PTR]
    pop  dword [BULLET_ARRAY_PTR]

    ; we also have to memset our arrays now, too
    mov  esi, [new_bullet_cap_bigendian]  ; REWRITE: <codecave:bullet-cap>
    bswap esi
    inc  esi  ; plus dummy bullet
    imul esi, BULLET_SIZE
    mov  ecx, esi
    mov  edi, [BULLET_ARRAY_PTR]
    rep stosb

    ; NOTE: keeping the bullet array size in esi
    mov  ecx, [new_laser_cap_bigendian]  ; REWRITE: <codecave:laser-cap>
    bswap ecx
    imul ecx, LASER_SIZE
    mov  edi, [LASER_ARRAY_PTR]
    rep stosb

    ; set the sentinel state on the dummy bullet (our other binhacks aren't enough to make this happen).
    mov  edi, [BULLET_ARRAY_PTR]
    mov  word [edi + esi - BULLET_SIZE + BULLET_STATE], 6

    pop  esi
    abs_jmp_hack 0x42f376

; 0x423a6c  (c745f410f7f600)  (in a funcSet/funcCall func)
; 0x423e2c  (c745f410f7f600)  (in a funcSet/funcCall func)
; 0x4241ec  (c745f410f7f600)  (in a funcSet/funcCall func)
; 0x42529c  (c745f410f7f600)  (in a funcSet/funcCall func)
pointerify_bullets_static_0c:  ; HEADER: AUTO
    mov  eax, [BULLET_ARRAY_PTR]
    mov  dword [ebp-0x0c], eax
    ret

; 0x424a2c  (c745f810f7f600)  (in a funcSet/funcCall func)
; 0x424c4c  (c745f810f7f600)  (in a funcSet/funcCall func)
; 0x424e5c  (c745f810f7f600)  (in a funcSet/funcCall func)
; 0x4250dc  (c745f810f7f600)  (in a funcSet/funcCall func)
; 0x4251e6  (c745f810f7f600)  (in a funcSet/funcCall func)
; 0042f3a0  (c745f810f7f600) (in BulletManager::reset_bullet_array)
pointerify_bullets_static_08:  ; HEADER: AUTO
    mov  eax, [BULLET_ARRAY_PTR]
    mov  dword [ebp-0x08], eax
    ret

; 0x43083a  (c745e410f7f600) (in some cancel func)
pointerify_bullets_static_1c:  ; HEADER: AUTO
    mov  eax, [BULLET_ARRAY_PTR]
    mov  dword [ebp-0x1c], eax
    ret

; 0x430abe  (c745e810f7f600) (in another cancel func)
pointerify_bullets_static_18:  ; HEADER: AUTO
    mov  eax, [BULLET_ARRAY_PTR]
    mov  dword [ebp-0x18], eax
    ret

; 0x430d3a  (c745ec10f7f600) (in yet another cancel func)
pointerify_bullets_static_14:  ; HEADER: AUTO
    mov  eax, [BULLET_ARRAY_PTR]
    mov  dword [ebp-0x14], eax
    ret

; 0x42f379  (0580a80100) (in BulletManager::reset_bullet_array)
; 0x431254  (0580a80100) (in BulletManager::on_tick)
pointerify_bullets_offset_eax:  ; HEADER: AUTO
    mov  eax, [BULLET_ARRAY_PTR]
    ret

; 0x42f657  (81c280a80100) (in BulletManager::shoot_one_bullet)
; 0x42fe23  (81c280a80100) (in BulletManager::shoot_one_bullet)
pointerify_bullets_offset_edx:  ; HEADER: AUTO
    mov  edx, [BULLET_ARRAY_PTR]
    ret

; 0x0042f46e  (81c238096600)  (in BulletManager::constructor)
; 0x00430943  (81c238096600)  (in a cancel func)
pointerify_lasers_offset_edx:  ; HEADER: AUTO
    mov  edx, [LASER_ARRAY_PTR]
    ret

; 0x00430bcc  (0538096600)  (in another cancel func)
; 0x00430f2d  (0538096600)  (in BulletManager::shoot_lasers)
; 0x00431b76  (0538096600)  (in BulletManager::on_tick)
pointerify_lasers_offset_eax:  ; HEADER: AUTO
    mov  eax, [LASER_ARRAY_PTR]
    ret

; 0x00432b7d  (81c138096600)  (in BulletManager::on_draw)
pointerify_lasers_offset_ecx:  ; HEADER: AUTO
    mov  ecx, [LASER_ARRAY_PTR]
    ret

; ==============================================

; 0x440021 (68e4020000)
pointerify_items_constructor:  ; HEADER: AUTO
    ; The line before this pushed the cancel cap + 1 (and we couldn't replace
    ; it because bullet_cap promises to preserve and replace such values).
    ;
    ; However we can't use it because this runs before our search and
    ; replace code, so just ignore it.
    add  esp, 0x4

    mov  eax, [new_cancel_cap_bigendian]  ; REWRITE: <codecave:cancel-cap>
    bswap eax
    inc  eax
    push eax  ; save a copy of array length for later

    imul eax, ITEM_SIZE
    push eax
    mov  eax, FUNC_MALLOC
    call eax
    add  esp, 0x4  ; caller cleans stack
    mov  [ITEM_ARRAY_PTR], eax

    pop  eax  ; saved copy of array length
    push FUNC_ITEM_CONSTRUCTOR
    push eax
    push ITEM_SIZE
    push dword [ITEM_ARRAY_PTR]
    mov  eax, FUNC_INITIALIZE_VECTOR
    call eax

    abs_jmp_hack 0x44002f

; 0x4337ff  (8b7dfcf3ab)
pointerify_items_keep_the_pointer:  ; HEADER: AUTO
    ; avoid zeroing out the pointer during this memcpy
    push dword [ITEM_ARRAY_PTR]
    mov  edi, [ebp-0x4]  ; original code
    rep stosd            ; original code
    pop  dword [ITEM_ARRAY_PTR]
    abs_jmp_hack 0x433804

; 0x4400b8  (8b55f403d1)
pointerify_items_spawn:  ; HEADER: AUTO
    mov  edx, [ebp-0xc]
    mov  edx, [edx]  ; follow pointer
    add  edx, ecx
    abs_jmp_hack 0x4400bd

; 0x4401b0  (8b45f405c0aa1700)
pointerify_items_spawn_2_eax:
    mov  eax, [new_cancel_cap_bigendian]  ; REWRITE: <codecave:cancel-cap>
    bswap eax
    imul eax, ITEM_SIZE
    add  eax, [ITEM_ARRAY_PTR]
    ret

pointerify_items_spawn_2_edx:
    mov  edx, [new_cancel_cap_bigendian]  ; REWRITE: <codecave:cancel-cap>
    bswap edx
    imul edx, ITEM_SIZE
    add  edx, [ITEM_ARRAY_PTR]
    ret

; 0x440196  (8b4df4894df8)
pointerify_items_spawn_wrap:
    mov  ecx, [ebp-0xc]
    mov  ecx, [ecx]   ; added instruction
    mov  [ebp-0x8], ecx
    abs_jmp_hack 0x4401aa
