; AUTO_PREFIX: ExpHP.sprite-death-fix.

%define ANM_MANAGER_PTR_10 0x491c10
%define FLUSH_SPRITES_10  0x442f50
%define BUFFER_OFFSET_10 0x3adacc
%define CURSOR_OFFSET_10 0x72dacc

%define ANM_MANAGER_PTR_11 0x4c3268
%define FLUSH_SPRITES_11  0x44fd10
%define BUFFER_OFFSET_11 0x435624
%define CURSOR_OFFSET_11 0x7b5624

%define ANM_MANAGER_PTR_12 0x4ce8cc
%define FLUSH_SPRITES_12 0x45a3c0
%define BUFFER_OFFSET_12 0x4b56a4
%define CURSOR_OFFSET_12 0x8356a4

%define ANM_MANAGER_PTR_125 0x4d0cb4
%define FLUSH_SPRITES_125 0x458ed0
%define BUFFER_OFFSET_125 0x4bd6ac
%define CURSOR_OFFSET_125 0x83d6ac

%define ANM_MANAGER_PTR_128 0x4d2e50
%define FLUSH_SPRITES_128 0x45ef60
%define BUFFER_OFFSET_128 0x4e96f0
%define CURSOR_OFFSET_128 0x8696f0

; side-effect-free absolute jump
%macro  abs_jmp_hack 1
        call %%next
    %%next:
        mov dword [esp], %1
        ret
%endmacro

;======================================================================
;              TH10 - TH128 (games without a bounds check)
;
; Astonishingly, the two functions involved (AnmManager::write_sprite
; and AnmManager::flush_sprites) have the exact same ABI in all five of
; these games, which almost never happens.
;
; That said, each of these are still largely ABI-dependent code, which I
; don't factor out because that would be false factoring, so this part
; might feel like a bit of copy pasta.
;=======================================================================

; 0x442fe4
fix_10:  ; HEADER: AUTO
    ; Games prior to DDC are missing this bounds check
    push edx  ; save (it's an argument to the current function)
    mov  esi, [ANM_MANAGER_PTR_10]
    lea  edi, [eax+CURSOR_OFFSET_10]  ; write ptr
    mov  eax, [edi]
    add  eax, 0xa8
    cmp  eax, edi
    jl   .noreset

    ; requires ANM_MANAGER in esi
    mov  eax, FLUSH_SPRITES_10
    call eax
    lea  eax, [esi+BUFFER_OFFSET_10]
    mov  [esi+CURSOR_OFFSET_10+0x0], eax  ; write cursor
    mov  [esi+CURSOR_OFFSET_10+0x4], eax  ; read cursor

.noreset:
    pop  edx
    ; original code
    mov  eax, [ANM_MANAGER_PTR_10]
    mov  edi, dword [eax+CURSOR_OFFSET_10]

    abs_jmp_hack 0x442fea

; 0x44fda4  (8bb824567b00)
fix_11:  ; HEADER: AUTO
    ; Games prior to DDC are missing this bounds check
    push edx  ; save (it's an argument to the current function)
    mov  esi, [ANM_MANAGER_PTR_11]
    lea  edi, [eax+CURSOR_OFFSET_11]  ; write ptr
    mov  eax, [edi]
    add  eax, 0xa8
    cmp  eax, edi
    jl   .noreset

    ; requires ANM_MANAGER in esi
    mov  eax, FLUSH_SPRITES_11
    call eax
    lea  eax, [esi+BUFFER_OFFSET_11]
    mov  [esi+CURSOR_OFFSET_11+0x0], eax  ; write cursor
    mov  [esi+CURSOR_OFFSET_11+0x4], eax  ; read cursor

.noreset:
    pop  edx
    ; original code
    mov  eax, [ANM_MANAGER_PTR_11]
    mov  edi, dword [eax+CURSOR_OFFSET_11]

    abs_jmp_hack 0x44fdaa

; 0x45a4a4  (8bb8a4568300)
fix_12:  ; HEADER: AUTO
    ; Games prior to DDC are missing this bounds check
    push edx  ; save (it's an argument to the current function)
    mov  esi, [ANM_MANAGER_PTR_12]
    lea  edi, [eax+CURSOR_OFFSET_12]  ; write ptr
    mov  eax, [edi]
    add  eax, 0xa8
    cmp  eax, edi
    jl   .noreset

    ; requires ANM_MANAGER in esi
    mov  eax, FLUSH_SPRITES_12
    call eax
    lea  eax, [esi+BUFFER_OFFSET_12]
    mov  [esi+CURSOR_OFFSET_12+0x0], eax  ; write cursor
    mov  [esi+CURSOR_OFFSET_12+0x4], eax  ; read cursor

.noreset:
    pop  edx
    ; original code
    mov  eax, [ANM_MANAGER_PTR_12]
    mov  edi, dword [eax+CURSOR_OFFSET_12]

    abs_jmp_hack 0x45a4aa

; 0x458fb4  (8bb8acd68300)
fix_125:  ; HEADER: AUTO
    ; Games prior to DDC are missing this bounds check
    push edx  ; save (it's an argument to the current function)
    mov  esi, [ANM_MANAGER_PTR_125]
    lea  edi, [eax+CURSOR_OFFSET_125]  ; write ptr
    mov  eax, [edi]
    add  eax, 0xa8
    cmp  eax, edi
    jl   .noreset

    ; requires ANM_MANAGER in esi
    mov  eax, FLUSH_SPRITES_125
    call eax
    lea  eax, [esi+BUFFER_OFFSET_125]
    mov  [esi+CURSOR_OFFSET_125+0x0], eax  ; write cursor
    mov  [esi+CURSOR_OFFSET_125+0x4], eax  ; read cursor

.noreset:
    pop  edx
    ; original code
    mov  eax, [ANM_MANAGER_PTR_125]
    mov  edi, dword [eax+CURSOR_OFFSET_125]

    abs_jmp_hack 0x458fba

; 0x45f043  (8bb8f0968600)
fix_128:  ; HEADER: AUTO
    ; Games prior to DDC are missing this bounds check
    push edx  ; save (it's an argument to the current function)
    mov  esi, [ANM_MANAGER_PTR_128]
    lea  edi, [eax+CURSOR_OFFSET_128]  ; write ptr
    mov  eax, [edi]
    add  eax, 0xa8
    cmp  eax, edi
    jl   .noreset

    ; requires ANM_MANAGER in esi
    mov  eax, FLUSH_SPRITES_128
    call eax
    lea  eax, [esi+BUFFER_OFFSET_128]
    mov  [esi+CURSOR_OFFSET_128+0x0], eax  ; write cursor
    mov  [esi+CURSOR_OFFSET_128+0x4], eax  ; read cursor

.noreset:
    pop  edx
    ; original code
    mov  eax, [ANM_MANAGER_PTR_128]
    mov  edi, dword [eax+CURSOR_OFFSET_128]

    abs_jmp_hack 0x45f049
