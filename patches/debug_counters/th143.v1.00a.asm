
%include "util.asm"
%include "common.asm"

; AUTO_PREFIX: ExpHP.debug-counters.

; the drawf function that is only used by FpsCounter and DebugSprtView
%define DRAWF_DEBUG       0x40ba50

color_data:  ; HEADER: AUTO
istruc ColorData
    at ColorData.ascii_manager_ptr, dd 0x4e69f8
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
    at ArraySpec.struct_ptr, dd 0x4e6a08
    at ArraySpec.length_is_addr, dd 1
    at ArraySpec.length_correction, dd -1
    at ArraySpec.array_length, dd 0x4128d0 - 4
    at ArraySpec.array_offset, dd 0x8c
    at ArraySpec.field_offset, dd 0xc0e
    at ArraySpec.stride, dd 0x13f4
iend

normal_item_data:  ; HEADER: AUTO
    dd KIND_ARRAY
istruc ArraySpec
    at ArraySpec.struct_ptr, dd 0x4e6b64
    at ArraySpec.length_is_addr, dd 0
    at ArraySpec.length_correction, dd 0
    at ArraySpec.array_length, dd 600
    at ArraySpec.array_offset, dd 0x14
    at ArraySpec.field_offset, dd 0xbf4
    at ArraySpec.stride, dd 0xc1c
iend

cancel_item_data:  ; HEADER: AUTO
    dd KIND_ARRAY
istruc ArraySpec
    at ArraySpec.struct_ptr, dd 0x4e6b64
    at ArraySpec.length_is_addr, dd 1
    at ArraySpec.length_correction, dd -600
    at ArraySpec.array_length, dd 0x435011 - 4
    at ArraySpec.array_offset, dd 0x1c61b4
    at ArraySpec.field_offset, dd 0xbf4
    at ArraySpec.stride, dd 0xc1c
iend

laser_data:  ; HEADER: AUTO
    dd KIND_FIELD
istruc FieldSpec
    at FieldSpec.struct_ptr, dd 0x4e6b6c
    at FieldSpec.count_offset, dd 0x5d4
    at FieldSpec.limit_addr, dd 0x439075 - 4
iend

anmid_data:  ; HEADER: AUTO
    dd KIND_ANMID
istruc AnmidSpec
    at AnmidSpec.struct_ptr, dd 0x538de8
    at AnmidSpec.world_head_ptr_offset, dd 0xfe8218
    at AnmidSpec.ui_head_ptr_offset, dd 0xfe8220
    at AnmidSpec.num_fast_vms, dd 0x1fff
iend

get_color:  ; DELETE