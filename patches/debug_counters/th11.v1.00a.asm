
%include "util.asm"
%include "common.asm"

; AUTO_PREFIX: ExpHP.debug-counters.

%define ASCII_MANAGER_PTR 0x4a8d58
%define ASCIIMGR_COLOR    0x18480
; the drawf function that is only used by FpsCounter and DebugSprtView
%define DRAWF_DEBUG       0x401600
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
    mov  ecx, [ASCII_MANAGER_PTR]
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
    at ArraySpec.struct_ptr, dd 0x4a8d68
    at ArraySpec.length_is_addr, dd 1
    at ArraySpec.length_correction, dd 0
    at ArraySpec.array_length, dd 0x408d40 - 4
    at ArraySpec.array_offset, dd 0x64
    at ArraySpec.field_offset, dd 0x4b2
    at ArraySpec.stride, dd 0x910
iend

normal_item_data:  ; HEADER: AUTO
    dd KIND_ARRAY
istruc ArraySpec
    at ArraySpec.struct_ptr, dd 0x4a8e90
    at ArraySpec.length_is_addr, dd 0
    at ArraySpec.length_correction, dd 0
    at ArraySpec.array_length, dd 150
    at ArraySpec.array_offset, dd 0x14
    at ArraySpec.field_offset, dd 0x464
    at ArraySpec.stride, dd 0x478
iend

cancel_item_data:  ; HEADER: AUTO
    dd KIND_ARRAY
istruc ArraySpec
    at ArraySpec.struct_ptr, dd 0x4a8e90
    at ArraySpec.length_is_addr, dd 1
    at ArraySpec.length_correction, dd -150 ; true cancel item cap never appears in code
    at ArraySpec.array_length, dd 0x423490 - 4
    at ArraySpec.array_offset, dd 0x29e64
    at ArraySpec.field_offset, dd 0x464
    at ArraySpec.stride, dd 0x478
iend

laser_data:  ; HEADER: AUTO
    dd KIND_LASER
istruc LaserSpec
    at LaserSpec.struct_ptr, dd 0x4a8e94
    at LaserSpec.count_offset, dd 0x454
    at LaserSpec.limit_addr, dd 0x424e01 - 4
iend

anmid_data:  ; HEADER: AUTO
    dd KIND_ANMID
istruc AnmidSpec
    at AnmidSpec.struct_ptr, dd 0x4c3268
    at AnmidSpec.world_head_ptr_offset, dd 0x7b562c
    at AnmidSpec.ui_head_ptr_offset, dd 0x7b5634
    at AnmidSpec.num_fast_vms, dd 0x1000
iend

get_color:  ; DELETE
