; AUTO_PREFIX: ExpHP.sprite-death-fix.

%define ANM_MANAGER_PTR_10 0x491c10
%define FLUSH_SPRITES_10  0x442f50
%define BUFFER_OFFSET_10 0x3adacc
%define CURSOR_OFFSET_10 0x72dacc

; 0x443079
cave_10:  ; HEADER: AUTO
    push esi
    mov  esi, [ANM_MANAGER_PTR_10]
    mov  eax, FLUSH_SPRITES_10
    call eax
    lea  eax, [esi+BUFFER_OFFSET_10]
    mov  [esi+CURSOR_OFFSET_10+0x0], eax  ; write cursor
    mov  [esi+CURSOR_OFFSET_10+0x4], eax  ; read cursor
    pop  esi

    ; original code
    pop  ebx
    retn

; ; 0x442fe4
; cave_10:  ; HEADER: AUTO
;     ; Later games have this check but TH10 doesn't
;     mov  esi, [ANM_MANAGER_PTR_10]
;     lea  edi, [eax+CURSOR_OFFSET_10]  ; write ptr
;     mov  eax, [edi]
;     add  eax, 0xa8
;     cmp  eax, edi
;     jl   .noreset

;     ; requires ANM_MANAGER in esi
;     call FLUSH_SPRITES_10
;     mov  []

; .noreset:
;     ; original code
;     mov  eax, [ANM_MANAGER_PTR_10]
;     mov  edi, dword [eax+CURSOR_OFFSET_10]

;     abs_jmp_hack 0x442fea
