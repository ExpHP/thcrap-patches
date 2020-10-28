
%include "util.asm"
%include "common.asm"

; AUTO_PREFIX: ExpHP.debug-counters.

%define FUNC_DRAWF       0x402060

%define REPLAY_MANAGER_PTR  0x4b9e48
%define BULLET_MANAGER_BASE 0x62f958
%define EFFECT_MANAGER_BASE 0x12fe250
%define ENEMY_MANAGER_BASE  0x9a9b00
%define ITEM_MANAGER_BASE   0x575c70
%define BULLET_ARRAY_OFFSET 0xb8c0
%define LASER_ARRAY_OFFSET  0x366628
%define ITEM_ARRAY_OFFSET   0x0

color_data:  ; HEADER: AUTO
istruc ColorData
    at ColorData.ascii_manager_ptr, dd ascii_manager_ptr  ; REWRITE: <codecave:AUTO>
    at ColorData.color_offset, dd 0x74c0
    at ColorData.positioning, dd POSITIONING_IN
iend

; Workaround for games where AsciiManager is static, so that ColorData can still
; contain a pointer to a pointer to AsciiManager.
ascii_manager_ptr:  ; HEADER: AUTO
    dd 0x134ce18

; __stdcall void DrawfDebugInt(AsciiManager*, Float3*, char*, int current)
drawf_debug_int:  ; HEADER: AUTO
    prologue_sd
    push ebx
    push dword [ebp+0x14] ; arg
    push dword [ebp+0x10] ; template
    push dword [ebp+0x0c] ; pos
    push dword [ebp+0x08] ; AsciiManager
    mov  eax, FUNC_DRAWF
    call eax
    add  esp, 0x10  ; caller cleans stack for varargs
    pop ebx
    epilogue_sd
    ret 0x10

bullet_data:  ; HEADER: AUTO
    dd KIND_EMBEDDED
istruc EmbeddedSpec
    at EmbeddedSpec.show_when_nonzero, dd REPLAY_MANAGER_PTR
    at EmbeddedSpec.struct_base, dd BULLET_MANAGER_BASE
    at EmbeddedSpec.spec_kind, dd KIND_FIELD
    at EmbeddedSpec.spec_size, dd FieldSpec_size
iend
    ; TH08 already tracks bullet count for us (for its cave slowdown feature), hooray!
    ; Use this field instead of the array for easier compability with bullet_cap.
istruc FieldSpec
    at FieldSpec.struct_ptr, dd 0xDEADBEEF ; unused
    at FieldSpec.limit, dd LIMIT_ADDR(0x423770-4)
    at FieldSpec.count_offset, dd 0x37a128
iend

normal_item_data:  ; HEADER: AUTO
    dd KIND_EMBEDDED
istruc EmbeddedSpec
    at EmbeddedSpec.show_when_nonzero, dd REPLAY_MANAGER_PTR
    at EmbeddedSpec.struct_base, dd ITEM_MANAGER_BASE
    at EmbeddedSpec.spec_kind, dd KIND_FIELD
    at EmbeddedSpec.spec_size, dd FieldSpec_size
iend
istruc FieldSpec
    at FieldSpec.struct_ptr, dd 0xDEADBEEF ; unused
    at FieldSpec.limit, dd LIMIT_ADDR(0x432750-4)
    at FieldSpec.count_offset, dd 0xae2ec
iend

cancel_item_data:  ; HEADER: AUTO
    dd 0

laser_data:  ; HEADER: AUTO
    dd KIND_EMBEDDED
istruc EmbeddedSpec
    at EmbeddedSpec.show_when_nonzero, dd REPLAY_MANAGER_PTR
    at EmbeddedSpec.struct_base, dd BULLET_MANAGER_BASE
    at EmbeddedSpec.spec_kind, dd KIND_ARRAY_V2
    at EmbeddedSpec.spec_size, dd ArraySpecV2_size
iend
istruc ArraySpecV2
    at ArraySpecV2.v1, istruc ArraySpec
        at ArraySpec.struct_ptr, dd 0xDEADBEEF ; unused
        at ArraySpec.limit, dd LIMIT_ADDR(0x4233b1-4)
        at ArraySpec.array_offset, dd LASER_ARRAY_OFFSET
        at ArraySpec.field_offset, dd 0x4d4
        at ArraySpec.stride, dd 0x4ec
    iend
    at ArraySpecV2.adjust_array_func, dd adjust_laser_array  ; REWRITE: <codecave:base-exphp.adjust-laser-array>
iend

enemy_data:  ; HEADER: AUTO
    dd KIND_EMBEDDED
istruc EmbeddedSpec
    at EmbeddedSpec.show_when_nonzero, dd REPLAY_MANAGER_PTR
    at EmbeddedSpec.struct_base, dd ENEMY_MANAGER_BASE
    at EmbeddedSpec.spec_kind, dd KIND_FIELD
    at EmbeddedSpec.spec_size, dd FieldSpec_size
iend
istruc FieldSpec
    at FieldSpec.struct_ptr, dd 0xDEADBEEF ; unused
    at FieldSpec.limit, dd LIMIT_NONE
    at FieldSpec.count_offset, dd 0x9545bc
iend

effect_general_data:  ; HEADER: AUTO
    dd KIND_EMBEDDED
istruc EmbeddedSpec
    at EmbeddedSpec.show_when_nonzero, dd REPLAY_MANAGER_PTR
    at EmbeddedSpec.struct_base, dd EFFECT_MANAGER_BASE
    at EmbeddedSpec.spec_kind, dd KIND_ARRAY
    at EmbeddedSpec.spec_size, dd ArraySpec_size
iend
istruc ArraySpec
    at ArraySpec.struct_ptr, dd 0xDEADBEEF ; unused
    at ArraySpec.limit, dd LIMIT_ADDR(0x41c1f7-4)
    at ArraySpec.array_offset, dd 0x1c
    at ArraySpec.field_offset, dd 0x2cc
    at ArraySpec.stride, dd 0x2d8
iend

effect_indexed_data:  ; HEADER: AUTO
    dd KIND_EMBEDDED
istruc EmbeddedSpec
    at EmbeddedSpec.show_when_nonzero, dd REPLAY_MANAGER_PTR
    at EmbeddedSpec.struct_base, dd EFFECT_MANAGER_BASE
    at EmbeddedSpec.spec_kind, dd KIND_ARRAY
    at EmbeddedSpec.spec_size, dd ArraySpec_size
iend
istruc ArraySpec
    at ArraySpec.struct_ptr, dd 0xDEADBEEF ; unused
    at ArraySpec.limit, dd LIMIT_VALUE(0xd)
    at ArraySpec.array_offset, dd 0x4719c
    at ArraySpec.field_offset, dd 0x2cc
    at ArraySpec.stride, dd 0x2d8
iend
get_color:  ; DELETE
