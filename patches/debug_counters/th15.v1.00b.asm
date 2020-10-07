
%include "util.asm"
%include "common.asm"

; AUTO_PREFIX: ExpHP.debug-counters.

; the drawf function that is only used by FpsCounter and DebugSprtView
%define DRAWF_DEBUG       0x40c800

color_data:  ; HEADER: AUTO
istruc ColorData
    at ColorData.ascii_manager_ptr, dd 0x4e9a58
    at ColorData.color_offset, dd 0x19224
    at ColorData.positioning, dd POSITIONING_DDC
iend

; __stdcall void DrawfDebugInt(AsciiManager*, Float3*, char*, int current)
drawf_debug_int:  ; HEADER: AUTO
    prologue_sd
    push dword [ebp+0x14] ; arg
    push dword [ebp+0x10] ; template
    push dword [ebp+0x0c] ; pos
    push dword [ebp+0x08] ; AsciiManager
    mov  eax, DRAWF_DEBUG
    call eax
    add  esp, 0x10  ; caller cleans stack for varargs
    epilogue_sd
    ret 0x10

bullet_data:  ; HEADER: AUTO
    dd KIND_ARRAY
istruc ArraySpec
    at ArraySpec.struct_ptr, dd 0x4e9a6c
    at ArraySpec.limit, dd LIMIT_ADDR_CORRECTED(0x418c99-4, -1)
    at ArraySpec.array_offset, dd 0x98
    at ArraySpec.field_offset, dd 0xc8a
    at ArraySpec.stride, dd 0x1494
iend

normal_item_data:  ; HEADER: AUTO
    dd KIND_ARRAY
istruc ArraySpec
    at ArraySpec.struct_ptr, dd 0x4e9a9c
    at ArraySpec.limit, dd LIMIT_VALUE(600)
    at ArraySpec.array_offset, dd 0x10
    at ArraySpec.field_offset, dd 0xc64
    at ArraySpec.stride, dd 0xc88
iend

cancel_item_data:  ; HEADER: AUTO
    dd KIND_ARRAY
istruc ArraySpec
    at ArraySpec.struct_ptr, dd 0x4e9a9c
    at ArraySpec.limit, dd LIMIT_ADDR_CORRECTED(0x43f458-4, -600)
    at ArraySpec.array_offset, dd 0x1d5ed0
    at ArraySpec.field_offset, dd 0xc64
    at ArraySpec.stride, dd 0xc88
iend

laser_data:  ; HEADER: AUTO
    dd KIND_FIELD
istruc FieldSpec
    at FieldSpec.struct_ptr, dd 0x4e9ba0
    at FieldSpec.limit, dd LIMIT_ADDR(0x4419e5-4)
    at FieldSpec.count_offset, dd 0x5e4
iend

anmid_data:  ; HEADER: AUTO
    dd KIND_ANMID
istruc AnmidSpec
    at AnmidSpec.struct_ptr, dd 0x503c18
    at AnmidSpec.limit, dd LIMIT_VALUE(0x1fff)
    at AnmidSpec.world_head_ptr_offset, dd 0xdc
    at AnmidSpec.ui_head_ptr_offset, dd 0xe4
iend

enemy_data:  ; HEADER: AUTO
    dd KIND_FIELD
istruc FieldSpec
    at FieldSpec.struct_ptr, dd 0x4e9a80
    at FieldSpec.limit, dd LIMIT_NONE
    at FieldSpec.count_offset, dd 0x18c
iend

get_color:  ; DELETE
