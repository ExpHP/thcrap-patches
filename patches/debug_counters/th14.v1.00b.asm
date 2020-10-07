
%include "util.asm"
%include "common.asm"

; AUTO_PREFIX: ExpHP.debug-counters.

; the drawf function that is only used by FpsCounter and DebugSprtView
%define DRAWF_DEBUG       0x40bdc0

color_data:  ; HEADER: AUTO
istruc ColorData
    at ColorData.ascii_manager_ptr, dd 0x4db520
    at ColorData.color_offset, dd 0x191b0
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
    at ArraySpec.struct_ptr, dd 0x4db530
    at ArraySpec.limit, dd LIMIT_ADDR_CORRECTED(0x416560-4, -1)
    at ArraySpec.array_offset, dd 0x8c
    at ArraySpec.field_offset, dd 0xc0e
    at ArraySpec.stride, dd 0x13f4
iend

normal_item_data:  ; HEADER: AUTO
    dd KIND_ARRAY
istruc ArraySpec
    at ArraySpec.struct_ptr, dd 0x4db660
    at ArraySpec.limit, dd LIMIT_VALUE(600)
    at ArraySpec.array_offset, dd 0x14
    at ArraySpec.field_offset, dd 0xbf0
    at ArraySpec.stride, dd 0xc18
iend

cancel_item_data:  ; HEADER: AUTO
    dd KIND_ARRAY
istruc ArraySpec
    at ArraySpec.struct_ptr, dd 0x4db660
    at ArraySpec.limit, dd LIMIT_ADDR_CORRECTED(0x438481-4, -600)
    at ArraySpec.array_offset, dd 0x1c5854
    at ArraySpec.field_offset, dd 0xbf0
    at ArraySpec.stride, dd 0xc18
iend

laser_data:  ; HEADER: AUTO
    dd KIND_FIELD
istruc FieldSpec
    at FieldSpec.struct_ptr, dd 0x4db664
    at FieldSpec.limit, dd LIMIT_ADDR(0x43a765-4)
    at FieldSpec.count_offset, dd 0x5d4
iend

anmid_data:  ; HEADER: AUTO
    dd KIND_ANMID
istruc AnmidSpec
    at AnmidSpec.struct_ptr, dd 0x4f56cc
    at AnmidSpec.limit, dd LIMIT_VALUE(0x1fff)
    at AnmidSpec.world_head_ptr_offset, dd 0xfe8208
    at AnmidSpec.ui_head_ptr_offset, dd 0xfe8210
iend

enemy_data:  ; HEADER: AUTO
    dd KIND_FIELD
istruc FieldSpec
    at FieldSpec.struct_ptr, dd 0x4db544
    at FieldSpec.limit, dd LIMIT_NONE
    at FieldSpec.count_offset, dd 0xd8
iend

get_color:  ; DELETE
