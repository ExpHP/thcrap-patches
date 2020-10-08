
%include "util.asm"
%include "common.asm"

; AUTO_PREFIX: ExpHP.debug-counters.

; the drawf function that is only used by FpsCounter and DebugSprtView
%define DRAWF_DEBUG       0x408310

color_data:  ; HEADER: AUTO
istruc ColorData
    at ColorData.ascii_manager_ptr, dd 0x4b54f8
    at ColorData.color_offset, dd 0x1c90c
    at ColorData.positioning, dd POSITIONING_DDC
iend

; __stdcall void DrawfDebugInt(AsciiManager*, Float3*, char*, int current)
drawf_debug_int:  ; HEADER: AUTO
    prologue_sd
    sub  esp, 0x4
    mov  ecx, esp
    push dword [ebp+0x14] ; arg
    push dword [ebp+0x10] ; template
    push dword [ebp+0x0c] ; pos
    push ecx  ; the pesky output pointer from 128 is back
    push dword [ebp+0x08] ; AsciiManager
    mov  eax, DRAWF_DEBUG
    call eax
    add  esp, 0x14  ; caller cleans stack for varargs
    add  esp, 0x4
    epilogue_sd
    ret 0x10

bullet_data:  ; HEADER: AUTO
    dd KIND_ARRAY
istruc ArraySpec
    at ArraySpec.struct_ptr, dd 0x4b550c
    at ArraySpec.limit, dd LIMIT_ADDR_CORRECTED(0x40ebc7-4, -1)
    at ArraySpec.array_offset, dd 0x9c
    at ArraySpec.field_offset, dd 0xe54
    at ArraySpec.stride, dd 0xe8c
iend

normal_item_data:  ; HEADER: AUTO
    dd KIND_ZERO
istruc ZeroSpec
    at ZeroSpec.struct_ptr, dd 0x4b5634
iend

cancel_item_data:  ; HEADER: AUTO
    dd KIND_ARRAY
istruc ArraySpec
    at ArraySpec.struct_ptr, dd 0x4b5634
    at ArraySpec.limit, dd LIMIT_ADDR(0x42bb46-4)  ; it's the whole array in this game
    at ArraySpec.array_offset, dd 0x10
    at ArraySpec.field_offset, dd 0x630
    at ArraySpec.stride, dd 0x634
iend

laser_data:  ; HEADER: AUTO
    dd KIND_FIELD
istruc FieldSpec
    at FieldSpec.struct_ptr, dd 0x4b5638
    at FieldSpec.limit, dd LIMIT_ADDR(0x42cb65-4)
    at FieldSpec.count_offset, dd 0x5e4
iend

anmid_data:  ; HEADER: AUTO
    dd KIND_ANMID
istruc AnmidSpec
    at AnmidSpec.struct_ptr, dd 0x4ed88c
    at AnmidSpec.limit, dd LIMIT_VALUE(0x1fff)
    at AnmidSpec.world_head_ptr_offset, dd 0xdc
    at AnmidSpec.ui_head_ptr_offset, dd 0xe4
iend

enemy_data:  ; HEADER: AUTO
    dd KIND_FIELD
istruc FieldSpec
    at FieldSpec.struct_ptr, dd 0x4b551c
    at FieldSpec.limit, dd LIMIT_NONE
    at FieldSpec.count_offset, dd 0x1b4
iend

effect_data:  ; HEADER: AUTO
    dd KIND_ARRAY
istruc ArraySpec
    at ArraySpec.struct_ptr, dd 0x4b5518
    at ArraySpec.limit, dd LIMIT_ADDR(0x415ef1-4)
    at ArraySpec.array_offset, dd 0x1c
    at ArraySpec.field_offset, dd FIELD_IS_DWORD
    at ArraySpec.stride, dd 0x4
iend

get_color:  ; DELETE
