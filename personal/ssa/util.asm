%define SCREEN_MIN_X_SUBPIXELS      -0x6000
%define PLAYER_MIN_X_SUBPIXELS      -0x5C00
%define PLAYER_MAX_X_SUBPIXELS       0x5C00
%define SCREEN_MAX_X_SUBPIXELS       0x6000
; In SA, the gap halfwidth is 0x800 for the player, and 0x600 for options (causing them to stutter a
; bit as reimu crosses).  Doing the same thing here would be a lot more noticeable.  Thus we pick the
; smaller value for better memes.
%define GAP_HALFWIDTH_SUBPIXELS       0x600
%define GAP_MIN_X_SUBPIXELS         (SCREEN_MIN_X_SUBPIXELS - GAP_HALFWIDTH_SUBPIXELS)
%define GAP_MAX_X_SUBPIXELS         (SCREEN_MAX_X_SUBPIXELS + GAP_HALFWIDTH_SUBPIXELS)
%define NEXT_SCREEN_MIN_X_SUBPIXELS (GAP_MAX_X_SUBPIXELS + GAP_HALFWIDTH_SUBPIXELS)
%define ORIGIN_TO_ORIGIN_SUBPIXELS  (NEXT_SCREEN_MIN_X_SUBPIXELS - SCREEN_MIN_X_SUBPIXELS)

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




