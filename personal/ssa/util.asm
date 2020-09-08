%define SCREEN_WIDTH_SUBPIXELS     0xC000
%define GAP_SIZE_SUBPIXELS          0xC00
%define ORIGIN_TO_ORIGIN_SUBPIXELS SCREEN_WIDTH_SUBPIXELS + GAP_SIZE_SUBPIXELS

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




