
%include "util.asm"
%include "common.asm"

; AUTO_PREFIX: ExpHP.debug-counters.

%define ASCII_MANAGER_PTR 0x4776e0
%define ASCIIMGR_COLOR    0x8974
; the drawf function that is only used by FpsCounter and DebugSprtView
%define DRAWF_DEBUG       0x401690
%define COLOR_WHITE       0xffffffff

; __stdcall void DrawfDebugInt(Float3*, int limit, char*, int current)
drawf_debug_int:  ; HEADER: AUTO
    prologue_sd
    push dword [ebp+0x0c] ; limit
    push dword [ebp+0x14] ; current
    call get_color  ; REWRITE: [codecave:AUTO]
    mov  ecx, [ASCII_MANAGER_PTR]
    mov  [ecx+ASCIIMGR_COLOR], eax

    ; MoF-GFW have a weird calling convention
    mov  esi, [ASCII_MANAGER_PTR]
    mov  ebx, [ebp+0x08] ; pos
    push dword [ebp+0x14] ; arg
    push dword [ebp+0x10] ; template
    mov  eax, DRAWF_DEBUG
    call eax
    add  esp, 0x8  ; caller cleans stack for varargs

    mov  dword [esi+ASCIIMGR_COLOR], COLOR_WHITE
    epilogue_sd
    ret 0x10

bullet_data:  ; HEADER: AUTO
    dd KIND_ARRAY
istruc ArraySpec
    at ArraySpec.struct_ptr, dd 0x4776f0
    at ArraySpec.length_is_addr, dd 1
    at ArraySpec.length_correction, dd 0
    at ArraySpec.array_length, dd 0x425856 - 4
    at ArraySpec.array_offset, dd 0x60
    at ArraySpec.field_offset, dd 0x446
    at ArraySpec.stride, dd 0x7f0
iend

normal_item_data:  ; HEADER: AUTO
    dd KIND_ARRAY
istruc ArraySpec
    at ArraySpec.struct_ptr, dd 0x477818
    at ArraySpec.length_is_addr, dd 0
    at ArraySpec.length_correction, dd 0
    at ArraySpec.array_length, dd 150
    at ArraySpec.array_offset, dd 0x14
    at ArraySpec.field_offset, dd 0x3dc
    at ArraySpec.stride, dd 0x3f0
iend

cancel_item_data:  ; HEADER: AUTO
    dd KIND_ARRAY
istruc ArraySpec
    at ArraySpec.struct_ptr, dd 0x477818
    at ArraySpec.length_is_addr, dd 1
    at ArraySpec.length_correction, dd -150 ; true cancel item cap never appears in code
    at ArraySpec.array_length, dd 0x41af16 - 4
    at ArraySpec.array_offset, dd 0x24eb4
    at ArraySpec.field_offset, dd 0x3dc
    at ArraySpec.stride, dd 0x3f0
iend

laser_data:  ; HEADER: AUTO
    dd KIND_LASER
istruc LaserSpec
    at LaserSpec.struct_ptr, dd 0x47781c
    at LaserSpec.count_offset, dd 0x438
    at LaserSpec.limit_addr, dd 0x41c51a - 4
iend

anmid_data:  ; HEADER: AUTO
    dd KIND_ANMID
istruc AnmidSpec
    at AnmidSpec.struct_ptr, dd 0x491c10
    at AnmidSpec.world_head_ptr_offset, dd 0x72dad4
    at AnmidSpec.ui_head_ptr_offset, dd 0x72dadc
    at AnmidSpec.num_fast_vms, dd 0x1000
iend

get_color:  ; DELETE
