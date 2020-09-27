
%include "util.asm"
%include "common.asm"

; AUTO_PREFIX: ExpHP.debug-counters.

; the drawf function that is only used by FpsCounter and DebugSprtView
%define DRAWF_DEBUG       0x4040e0

color_data:  ; HEADER: AUTO
istruc ColorData
    at ColorData.ascii_manager_ptr, dd 0x4c2160
    at ColorData.color_offset, dd 0x19160
    at ColorData.positioning, dd POSITIONING_TD
iend

; __stdcall void DrawfDebugInt(AsciiManager*, Float3*, char*, int current)
drawf_debug_int:  ; HEADER: AUTO
    prologue_sd
    push ebx
    ; MoF-TD have a weird calling convention
    sub  esp, 0x4
    mov  edi, esp  ; unknown output pointer added in DS
    push dword [ebp+0x14] ; arg
    push dword [ebp+0x10] ; template
    mov  ebx, [ebp+0x0c] ; pos
    mov  esi, [ebp+0x08] ; AsciiManager
    mov  eax, DRAWF_DEBUG
    call eax
    add  esp, 0x8  ; caller cleans stack for varargs
    add  esp, 0x4  ; cleanup edi
    pop  ebx
    epilogue_sd
    ret 0x10

bullet_data:  ; HEADER: AUTO
    dd KIND_ARRAY
istruc ArraySpec
    at ArraySpec.struct_ptr, dd 0x4c2174
    at ArraySpec.length_is_addr, dd 1
    at ArraySpec.length_correction, dd -1
    at ArraySpec.array_length, dd 0x40d970 - 4
    at ArraySpec.array_offset, dd 0x90
    at ArraySpec.field_offset, dd 0xbbe
    at ArraySpec.stride, dd 0x135c
iend

normal_item_data:  ; HEADER: AUTO
    dd KIND_ARRAY
istruc ArraySpec
    at ArraySpec.struct_ptr, dd 0x4c229c
    at ArraySpec.length_is_addr, dd 0
    at ArraySpec.length_correction, dd 0
    at ArraySpec.array_length, dd 600
    at ArraySpec.array_offset, dd 0x14
    at ArraySpec.field_offset, dd 0xba0
    at ArraySpec.stride, dd 0xbc8
iend

cancel_item_data:  ; HEADER: AUTO
    dd KIND_ARRAY
istruc ArraySpec
    at ArraySpec.struct_ptr, dd 0x4c229c
    at ArraySpec.length_is_addr, dd 1
    at ArraySpec.length_correction, dd -600
    at ArraySpec.array_length, dd 0x42e2c0 - 4
    at ArraySpec.array_offset, dd 0x1b9cd4
    at ArraySpec.field_offset, dd 0xba0
    at ArraySpec.stride, dd 0xbc8
iend

laser_data:  ; HEADER: AUTO
    dd KIND_FIELD
istruc FieldSpec
    at FieldSpec.struct_ptr, dd 0x4c22a0
    at FieldSpec.count_offset, dd 0x5d4
    at FieldSpec.limit_addr, dd 0x42fee1 - 4
iend

anmid_data:  ; HEADER: AUTO
    dd KIND_ANMID
istruc AnmidSpec
    at AnmidSpec.struct_ptr, dd 0x4dc688
    at AnmidSpec.world_head_ptr_offset, dd 0xf48208
    at AnmidSpec.ui_head_ptr_offset, dd 0xf48210
    at AnmidSpec.num_fast_vms, dd 0x1fff
iend

spirit_data:  ; HEADER: AUTO
    dd KIND_FIELD
istruc FieldSpec
    at FieldSpec.struct_ptr, dd 0x4c22a4
    at FieldSpec.count_offset, dd 0x8814
    at FieldSpec.limit_addr, dd 0x438678 - 4
iend

get_color:  ; DELETE
