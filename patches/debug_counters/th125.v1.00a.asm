
%include "util.asm"
%include "common.asm"

; AUTO_PREFIX: ExpHP.debug-counters.

%define ASCII_MANAGER_PTR 0x4b6770
%define ASCIIMGR_COLOR    0x1c7f4
; the drawf function that is only used by FpsCounter and DebugSprtView
%define DRAWF_DEBUG       0x401830
%define COLOR_WHITE       0xffffffff

; __stdcall void DrawfDebugInt(Float3*, int limit, char*, int current)
drawf_debug_int:  ; HEADER: AUTO
    prologue_sd
    push dword [ebp+0x0c] ; limit
    push dword [ebp+0x14] ; current
    call get_color  ; REWRITE: [codecave:AUTO]
    mov  ecx, [ASCII_MANAGER_PTR]
    mov  [ecx+ASCIIMGR_COLOR], eax

    ; DS has a weird calling convention
    sub  esp, 0x4
    mov  edi, esp  ; unknown output pointer added in DS
    mov  esi, [ASCII_MANAGER_PTR]
    push dword [ebp+0x14] ; arg
    push dword [ebp+0x10] ; template
    push dword [ebp+0x08] ; pos
    mov  eax, DRAWF_DEBUG
    call eax
    add  esp, 0xc  ; caller cleans stack for varargs
    add  esp, 0x4  ; cleanup edi

    mov  ecx, [ASCII_MANAGER_PTR]
    mov  dword [ecx+ASCIIMGR_COLOR], COLOR_WHITE
    epilogue_sd
    ret 0x10

bullet_data:  ; HEADER: AUTO
    dd KIND_ARRAY
istruc ArraySpec
    at ArraySpec.struct_ptr, dd 0x4b677c
    at ArraySpec.length_is_addr, dd 1
    at ArraySpec.length_correction, dd 0
    at ArraySpec.array_length, dd 0x408785 - 4
    at ArraySpec.array_offset, dd 0x64
    at ArraySpec.field_offset, dd 0x512
    at ArraySpec.stride, dd 0xa34
iend

normal_item_data:  ; HEADER: AUTO
    dd KIND_ZERO
istruc ZeroSpec
    at ZeroSpec.struct_ptr, dd 0x4b68a0
iend

cancel_item_data:  ; HEADER: AUTO
    dd KIND_ARRAY
istruc ArraySpec
    at ArraySpec.struct_ptr, dd 0x4b68a0
    at ArraySpec.length_is_addr, dd 1
    at ArraySpec.length_correction, dd 0  ; it's the whole array in this game
    at ArraySpec.array_length, dd 0x41f320 - 4
    at ArraySpec.array_offset, dd 0x14
    at ArraySpec.field_offset, dd 0x4f0
    at ArraySpec.stride, dd 0x4f4
iend

laser_data:  ; HEADER: AUTO
    dd KIND_LASER
istruc LaserSpec
    at LaserSpec.struct_ptr, dd 0x4b68a4
    at LaserSpec.count_offset, dd 0x468
    at LaserSpec.limit_addr, dd 0x420411 - 4
iend

anmid_data:  ; HEADER: AUTO
    dd KIND_ANMID
istruc AnmidSpec
    at AnmidSpec.struct_ptr, dd 0x4d0cb4
    at AnmidSpec.world_head_ptr_offset, dd 0x88d6c0
    at AnmidSpec.ui_head_ptr_offset, dd 0x88d6c8
    at AnmidSpec.num_fast_vms, dd 0x1000
iend

get_color:  ; DELETE
