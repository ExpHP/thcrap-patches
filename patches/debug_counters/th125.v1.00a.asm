
%include "util.asm"
%include "common.asm"

; AUTO_PREFIX: ExpHP.debug-counters.

; the drawf function that is only used by FpsCounter and DebugSprtView
%define DRAWF_DEBUG       0x401830

color_data:  ; HEADER: AUTO
istruc ColorData
    at ColorData.ascii_manager_ptr, dd 0x4b6770
    at ColorData.color_offset, dd 0x1c7f4
    at ColorData.positioning, dd POSITIONING_TD
iend

; __stdcall void DrawfDebugInt(AsciiManager*, Float3*, char*, int current)
drawf_debug_int:  ; HEADER: AUTO
    prologue_sd
    ; MoF-TD have a weird calling convention
    sub  esp, 0x4
    mov  edi, esp  ; unknown output pointer added in DS
    push dword [ebp+0x14] ; arg
    push dword [ebp+0x10] ; template
    push dword [ebp+0x0c] ; pos
    mov  esi, [ebp+0x08] ; AsciiManager
    mov  eax, DRAWF_DEBUG
    call eax
    add  esp, 0xc  ; caller cleans stack for varargs
    add  esp, 0x4  ; cleanup edi
    epilogue_sd
    ret 0x10

bullet_data:  ; HEADER: AUTO
    dd KIND_ARRAY
istruc ArraySpec
    at ArraySpec.struct_ptr, dd 0x4b677c
    at ArraySpec.limit, dd LIMIT_ADDR(0x408785-4)
    at ArraySpec.array_offset, dd 0x64
    at ArraySpec.field_offset, dd 0x512
    at ArraySpec.stride, dd 0xa34
iend

normal_item_data:  ; HEADER: AUTO
    dd KIND_ZERO
istruc ZeroSpec
    at ZeroSpec.struct_ptr, dd 0x4b68a0
iend

cancel_item_data:  ; HEADER: AUTO
    dd KIND_ARRAY
istruc ArraySpec
    at ArraySpec.struct_ptr, dd 0x4b68a0
    at ArraySpec.limit, dd LIMIT_ADDR(0x41f320-4)  ; it's the whole array in this game
    at ArraySpec.array_offset, dd 0x14
    at ArraySpec.field_offset, dd 0x4f0
    at ArraySpec.stride, dd 0x4f4
iend

laser_data:  ; HEADER: AUTO
    dd KIND_FIELD
istruc FieldSpec
    at FieldSpec.struct_ptr, dd 0x4b68a4
    at FieldSpec.limit, dd LIMIT_ADDR(0x420411-4)
    at FieldSpec.count_offset, dd 0x468
iend

anmid_data:  ; HEADER: AUTO
    dd KIND_ANMID
istruc AnmidSpec
    at AnmidSpec.struct_ptr, dd 0x4d0cb4
    at AnmidSpec.limit, dd LIMIT_VALUE(0x1000)
    at AnmidSpec.world_head_ptr_offset, dd 0x88d6c0
    at AnmidSpec.ui_head_ptr_offset, dd 0x88d6c8
iend

enemy_data:  ; HEADER: AUTO
    dd KIND_FIELD
istruc FieldSpec
    at FieldSpec.struct_ptr, dd 0x4b678c
    at FieldSpec.limit, dd LIMIT_NONE
    at FieldSpec.count_offset, dd 0xa8
iend
