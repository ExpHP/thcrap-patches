
%include "util.asm"
%include "common.asm"

; AUTO_PREFIX: ExpHP.debug-counters.

; the drawf function that is only used by FpsCounter and DebugSprtView
%define DRAWF_DEBUG       0x401900

color_data:  ; HEADER: AUTO
istruc ColorData
    at ColorData.ascii_manager_ptr, dd 0x4b8920
    at ColorData.color_offset, dd 0x1c84c
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
    at ArraySpec.struct_ptr, dd 0x4b8930
    at ArraySpec.limit, dd LIMIT_ADDR(0x408d95-4)
    at ArraySpec.array_offset, dd 0x64
    at ArraySpec.field_offset, dd 0xa2a
    at ArraySpec.stride, dd 0x11b8
iend

normal_item_data:  ; HEADER: AUTO
    dd KIND_ARRAY
istruc ArraySpec
    at ArraySpec.struct_ptr, dd 0x4b8a5c
    at ArraySpec.limit, dd LIMIT_VALUE(600)
    at ArraySpec.array_offset, dd 0x14
    at ArraySpec.field_offset, dd 0xa18
    at ArraySpec.stride, dd 0xa40
iend

cancel_item_data:  ; HEADER: AUTO
    dd KIND_ARRAY
istruc ArraySpec
    at ArraySpec.struct_ptr, dd 0x4b8a5c
    at ArraySpec.limit, dd LIMIT_ADDR_CORRECTED(0x428550-4, -600-16)  ; the extra 16 is left over from UFO
    at ArraySpec.array_offset, dd 0x18aa14
    at ArraySpec.field_offset, dd 0xa18
    at ArraySpec.stride, dd 0xa40
iend

laser_data:  ; HEADER: AUTO
    dd KIND_FIELD
istruc FieldSpec
    at FieldSpec.struct_ptr, dd 0x4b8a60
    at FieldSpec.limit, dd LIMIT_ADDR(0x42a411-4)
    at FieldSpec.count_offset, dd 0x5d4
iend

anmid_data:  ; HEADER: AUTO
    dd KIND_ANMID
istruc AnmidSpec
    at AnmidSpec.struct_ptr, dd 0x4d2e50
    at AnmidSpec.limit, dd LIMIT_VALUE(0x1000)
    at AnmidSpec.world_head_ptr_offset, dd 0x8b9704
    at AnmidSpec.ui_head_ptr_offset, dd 0x8b9708
iend

enemy_data:  ; HEADER: AUTO
    dd KIND_FIELD
istruc FieldSpec
    at FieldSpec.struct_ptr, dd 0x4b8948
    at FieldSpec.limit, dd LIMIT_NONE
    at FieldSpec.count_offset, dd 0xc0
iend
