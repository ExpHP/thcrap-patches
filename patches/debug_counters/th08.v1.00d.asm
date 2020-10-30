
%include "util.asm"
%include "common.asm"

; AUTO_PREFIX: ExpHP.debug-counters.

%define FUNC_DRAWF       0x402a30

%define REPLAY_MANAGER_PTR  0x18b8a28
%define BULLET_MANAGER_BASE 0xf54e90
%define EFFECT_MANAGER_BASE 0x4ece60
%define ENEMY_MANAGER_BASE  0x577f20
%define ITEM_MANAGER_BASE   0x1653648
%define BULLET_ARRAY_OFFSET 0x1a880
%define LASER_ARRAY_OFFSET  0x660938
%define ITEM_ARRAY_OFFSET   0x0

color_data:  ; HEADER: AUTO
istruc ColorData
    at ColorData.ascii_manager_ptr, dd ascii_manager_ptr  ; REWRITE: <codecave:AUTO>
    at ColorData.color_offset, dd 0x8268
    at ColorData.positioning, dd POSITIONING_IN
iend

; Workaround for games where AsciiManager is static, so that ColorData can still
; contain a pointer to a pointer to AsciiManager.
ascii_manager_ptr:  ; HEADER: AUTO
    dd 0x4cce20

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
    at FieldSpec.limit, dd LIMIT_ADDR(0x4312ae-4)
    at FieldSpec.count_offset, dd 0x6ba538
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
    at FieldSpec.limit, dd LIMIT_ADDR(0x440187-4)
    at FieldSpec.count_offset, dd 0x17ada8
iend

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
        at ArraySpec.limit, dd LIMIT_ADDR(0x42f464-4)
        at ArraySpec.array_offset, dd LASER_ARRAY_OFFSET
        at ArraySpec.field_offset, dd 0x584
        at ArraySpec.stride, dd 0x59c
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
    at FieldSpec.count_offset, dd 0x9dcdc4
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
    at ArraySpec.limit, dd LIMIT_ADDR(0x425468-4)
    at ArraySpec.array_offset, dd 0x1c
    at ArraySpec.field_offset, dd 0x350
    at ArraySpec.stride, dd 0x360
iend

effect_familiar_data:  ; HEADER: AUTO
    dd KIND_EMBEDDED
istruc EmbeddedSpec
    at EmbeddedSpec.show_when_nonzero, dd REPLAY_MANAGER_PTR
    at EmbeddedSpec.struct_base, dd EFFECT_MANAGER_BASE
    at EmbeddedSpec.spec_kind, dd KIND_ARRAY
    at EmbeddedSpec.spec_size, dd ArraySpec_size
iend
istruc ArraySpec
    at ArraySpec.struct_ptr, dd 0xDEADBEEF ; unused
    at ArraySpec.limit, dd LIMIT_ADDR(0x425ba9-4)
    at ArraySpec.array_offset, dd 0x6c01c
    at ArraySpec.field_offset, dd 0x350
    at ArraySpec.stride, dd 0x360
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
    at ArraySpec.array_offset, dd 0x8701c
    at ArraySpec.field_offset, dd 0x350
    at ArraySpec.stride, dd 0x360
iend
