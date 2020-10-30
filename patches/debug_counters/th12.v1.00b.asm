
%include "util.asm"
%include "common.asm"

; AUTO_PREFIX: ExpHP.debug-counters.

; the drawf function that is only used by FpsCounter and DebugSprtView
%define DRAWF_DEBUG       0x401720

color_data:  ; HEADER: AUTO
istruc ColorData
    at ColorData.ascii_manager_ptr, dd 0x4b43b8
    at ColorData.color_offset, dd 0x18f80
    at ColorData.positioning, dd POSITIONING_TD
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
    pop  ebx
    epilogue_sd
    ret 0x10

bullet_data:  ; HEADER: AUTO
    dd KIND_ARRAY
istruc ArraySpec
    at ArraySpec.struct_ptr, dd 0x4b43c8
    at ArraySpec.limit, dd LIMIT_ADDR(0x40a061)
    at ArraySpec.array_offset, dd 0x64
    at ArraySpec.field_offset, dd 0x532
    at ArraySpec.stride, dd 0x9f8
iend

normal_item_data:  ; HEADER: AUTO
    dd KIND_ARRAY
istruc ArraySpec
    at ArraySpec.struct_ptr, dd 0x4b44f0
    at ArraySpec.limit, dd LIMIT_VALUE(600)
    at ArraySpec.array_offset, dd 0x14
    at ArraySpec.field_offset, dd 0x9b0
    at ArraySpec.stride, dd 0x9d8
iend

cancel_item_data:  ; HEADER: AUTO
    dd KIND_ARRAY
istruc ArraySpec
    at ArraySpec.struct_ptr, dd 0x4b44f0
    at ArraySpec.limit, dd LIMIT_ADDR_CORRECTED(0x425b60-4, -600-16)  ; the extra 16 is UFO items
    at ArraySpec.array_offset, dd 0x17afd4
    at ArraySpec.field_offset, dd 0x9b0
    at ArraySpec.stride, dd 0x9d8
iend

laser_data:  ; HEADER: AUTO
    dd KIND_FIELD
istruc FieldSpec
    at FieldSpec.struct_ptr, dd 0x4b44f4
    at FieldSpec.limit, dd LIMIT_ADDR(0x42845d)
    at FieldSpec.count_offset, dd 0x468
iend

anmid_data:  ; HEADER: AUTO
    dd KIND_ANMID
istruc AnmidSpec
    at AnmidSpec.struct_ptr, dd 0x4ce8cc
    at AnmidSpec.limit, dd LIMIT_VALUE(0x1000)
    at AnmidSpec.world_head_ptr_offset, dd 0x8856b8
    at AnmidSpec.ui_head_ptr_offset, dd 0x8856c0
iend

enemy_data:  ; HEADER: AUTO
    dd KIND_FIELD
istruc FieldSpec
    at FieldSpec.struct_ptr, dd 0x4b43dc
    at FieldSpec.limit, dd LIMIT_NONE
    at FieldSpec.count_offset, dd 0x70
iend
