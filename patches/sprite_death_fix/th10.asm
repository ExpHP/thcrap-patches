; AUTO_PREFIX: ExpHP.sprite-death-fix.

%define ANM_MANAGER_PTR_10 0x491c10
%define FLUSH_SPRITES_10  0x442f50
%define BUFFER_OFFSET_10 0x3adacc
%define CURSOR_OFFSET_10 0x72dacc

%define ANM_MANAGER_PTR_11 0x4c3268
%define FLUSH_SPRITES_11  0x44fd10
%define BUFFER_OFFSET_11 0x435624
%define CURSOR_OFFSET_11 0x7b5624

; side-effect-free absolute jump
%macro  abs_jmp_hack 1
        call %%next
    %%next:
        mov dword [esp], %1
        ret
%endmacro

; 0x442fe4
cave_10:  ; HEADER: AUTO
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

; Basically identical to MoF
; 0x44fda4
cave_11:  ; HEADER: AUTO
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
