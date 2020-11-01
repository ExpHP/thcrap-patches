
%include "util.asm"
%include "common.asm"

; AUTO_PREFIX: ExpHP.debug-counters.

; the drawf function that is only used by FpsCounter and DebugSprtView
%define DRAWF_DEBUG       0x401600

color_data:  ; HEADER: AUTO

; __stdcall void DrawfDebugInt(AsciiManager*, Float3*, char*, int current)
drawf_debug_int:  ; HEADER: AUTO
    prologue_sd
    push ebx
    ; MoF-TD have a weird calling convention
    push dword [ebp+0x14] ; arg
    push dword [ebp+0x10] ; template
    mov  ebx, [ebp+0x0c] ; pos
    mov  ecx, [ebp+0x08] ; AsciiManager
    mov  eax, DRAWF_DEBUG
    call eax
    add  esp, 0x8  ; caller cleans stack for varargs
    pop  ebx
    epilogue_sd
    ret 0x10

# TH11

