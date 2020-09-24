
%include "util.asm"
%include "common.asm"

; AUTO_PREFIX: ExpHP.debug-counters.

%define ASCII_MANAGER_PTR 0x4b43b8
%define ASCIIMGR_COLOR    0x18f80
; the drawf function that is only used by FpsCounter and DebugSprtView
%define DRAWF_DEBUG       0x401720
%define COLOR_WHITE       0xffffffff

; __stdcall void DrawfDebugInt(Float3*, int limit, char*, int current)
drawf_debug_int:  ; HEADER: AUTO
    prologue_sd
    push dword [ebp+0x0c] ; limit
    push dword [ebp+0x14] ; current
    call get_color  ; REWRITE: [codecave:AUTO]
    mov  ecx, [ASCII_MANAGER_PTR]
    mov  [ecx+ASCIIMGR_COLOR], eax

    ; UFO has a weird calling convention
    mov  esi, [ASCII_MANAGER_PTR]
    mov  ebx, [ebp+0x08] ; pos
    push dword [ebp+0x14] ; arg
    push dword [ebp+0x10] ; template
    mov  eax, DRAWF_DEBUG
    call eax
    add  esp, 0x8  ; caller cleans stack for varargs

    mov  ecx, [ASCII_MANAGER_PTR]
    mov  dword [ecx+ASCIIMGR_COLOR], COLOR_WHITE
    epilogue_sd
    ret 0x10

bullet_data:  ; HEADER: AUTO
    dd KIND_ARRAY
istruc ArraySpec
    at ArraySpec.struct_ptr, dd 0x4b43c8
    at ArraySpec.length_is_addr, dd 1
    at ArraySpec.length_correction, dd 0
    at ArraySpec.array_length, dd 0x40a061
    at ArraySpec.array_offset, dd 0x64
    at ArraySpec.field_offset, dd 0x532
    at ArraySpec.stride, dd 0x9f8
iend

normal_item_data:  ; HEADER: AUTO
    dd KIND_ARRAY
istruc ArraySpec
    at ArraySpec.struct_ptr, dd 0x4b44f0
    at ArraySpec.length_is_addr, dd 0
    at ArraySpec.length_correction, dd 0
    at ArraySpec.array_length, dd 600
    at ArraySpec.array_offset, dd 0x14
    at ArraySpec.field_offset, dd 0x9b0
    at ArraySpec.stride, dd 0x9d8
iend

cancel_item_data:  ; HEADER: AUTO
    dd KIND_ARRAY
istruc ArraySpec
    at ArraySpec.struct_ptr, dd 0x4b44f0
    at ArraySpec.length_is_addr, dd 1
    at ArraySpec.length_correction, dd -600-16  ; the extra 16 is UFO items
    at ArraySpec.array_length, dd 0x425b60 - 4
    at ArraySpec.array_offset, dd 0x17afd4
    at ArraySpec.field_offset, dd 0x9b0
    at ArraySpec.stride, dd 0x9d8
iend

laser_data:  ; HEADER: AUTO
    dd KIND_LASER
istruc LaserSpec
    at LaserSpec.struct_ptr, dd 0x4b44f4
    at LaserSpec.count_offset, dd 0x468
    at LaserSpec.limit_addr, dd 0x42845d
iend

anmid_data:  ; HEADER: AUTO
    dd KIND_ANMID
istruc AnmidSpec
    at AnmidSpec.struct_ptr, dd 0x4ce8cc
    at AnmidSpec.world_head_ptr_offset, dd 0x8856b8
    at AnmidSpec.ui_head_ptr_offset, dd 0x8856c0
    at AnmidSpec.num_fast_vms, dd 0x1000
iend

get_color:  ; DELETE
