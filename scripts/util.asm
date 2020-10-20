%macro prologue_sd 0.nolist
    push ebp
    mov  ebp, esp
    push esi
    push edi
%endmacro

%macro prologue_sd 1.nolist
    push ebp
    mov  ebp, esp
    sub  esp, %1
    push esi
    push edi
%endmacro

%macro epilogue_sd 0.nolist
    pop  edi
    pop  esi
    mov  esp, ebp
    pop  ebp
%endmacro

; side-effect-free absolute jump
%macro  abs_jmp_hack 1.nolist
    call %%next
%%next:
    mov dword [esp], %1
    ret
%endmacro

; absolute call, clobbering eax
;
; eax is almost universally a good choice since it's used for return values,
; but some functions from the ugly ABI era pass an argument in eax.
;
; (if this were x86-64, we could use the red zone, but it doesn't exist in x86)
%macro  call_eax 1.nolist
    mov eax, %1
    call eax
%endmacro

%macro  die 0.nolist
    push __LINE__
    int 3
%endmacro

%define SIGN_MASK 0x80000000
