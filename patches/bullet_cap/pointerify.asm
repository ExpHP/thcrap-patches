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
%define BULLET_ARRAY_PTR    0xf6f710
%define BULLET_MANAGER_NUM_DWORDS 0x1ae95e

%define BULLET_SIZE 0x10b8
%define BULLET_STATE 0xdb8

%define FUNC_MALLOC 0x4a43d4

new_bullet_cap_bigendian:  ; DELETE
new_laser_cap_bigendian:  ; DELETE
new_cancel_cap_bigendian:  ; DELETE

; ==========================================
; OHGOD OHGOD OHGOD OHGOD OHGOD OHGOD OHGOD


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
    mov  [BULLET_ARRAY_PTR], eax
    abs_jmp_hack 0x42f45a

; 0x42f36a  (b95ee91a00)  (in BulletManager::reset)
pointerify_keep_the_pointer:  ; HEADER: AUTO
    push esi  ; save
    ; Keep the pointer when the struct is memset to 0.
    push dword [BULLET_ARRAY_PTR]

    ; memset the entire struct (this is the original code)
    mov  ecx, BULLET_MANAGER_NUM_DWORDS
    xor  eax, eax
    mov  edi, dword [ebp-0xc]
    rep stosd

    pop  dword [BULLET_ARRAY_PTR]

    ; we also have to memset our array now, too
    mov  esi, [new_bullet_cap_bigendian]  ; REWRITE: <codecave:bullet-cap>
    bswap esi
    inc  esi  ; plus dummy bullet
    imul esi, BULLET_SIZE
    mov  ecx, esi
    mov  edi, [BULLET_ARRAY_PTR]
    rep stosb

    ; set the sentinel state on the dummy bullet (our other binhacks aren't enough to make this happen)
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
    add  eax, 0x1a880
    mov  eax, [eax]
    ret

; 0x42f657  (81c280a80100) (in BulletManager::shoot_one_bullet)
; 0x42fe23  (81c280a80100) (in BulletManager::shoot_one_bullet)
pointerify_bullets_offset_edx:  ; HEADER: AUTO
    add  edx, 0x1a880
    mov  edx, [edx]
    ret

