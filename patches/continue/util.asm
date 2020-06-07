%macro prologue_sd 0
    push ebp
    mov  ebp, esp
    push esi
    push edi
%endmacro

%macro epilogue_sd 0
    pop  edi
    pop  esi
    mov  esp, ebp
    pop  ebp
%endmacro

; side-effect-free absolute jump
%macro  abs_jmp_hack 1
        call %%next
    %%next:
        mov dword [esp], %1
        ret
%endmacro




