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
