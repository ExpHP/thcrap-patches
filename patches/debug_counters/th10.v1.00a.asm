
%include "util.asm"
%include "common.asm"

; AUTO_PREFIX: ExpHP.debug-counters.

; the drawf function that is only used by FpsCounter and DebugSprtView
%define DRAWF_DEBUG       0x401690

color_data:  ; HEADER: AUTO
istruc ColorData
    at ColorData.ascii_manager_ptr, dd 0x4776e0
    at ColorData.color_offset, dd 0x8974
iend

; __stdcall void DrawfDebugInt(AsciiManager*, Float3*, char*, int current)
drawf_debug_int:  ; HEADER: AUTO
    prologue_sd
    push ebx
    ; MoF-TD have a weird calling convention
    push dword [ebp+0x14] ; arg
    push dword [ebp+0x10] ; template
    mov  ebx, [ebp+0x0c] ; pos
    mov  esi, [ebp+0x08] ; AsciiManager
    mov  eax, DRAWF_DEBUG
    call eax
    add  esp, 0x8  ; caller cleans stack for varargs
    pop ebx
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
    dd KIND_FIELD
istruc FieldSpec
    at FieldSpec.struct_ptr, dd 0x47781c
    at FieldSpec.count_offset, dd 0x438
    at FieldSpec.limit_addr, dd 0x41c51a - 4
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
