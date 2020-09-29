
%include "util.asm"
%include "common.asm"

; AUTO_PREFIX: ExpHP.debug-counters.

%define FUNC_SPRINTF          0x4a4857
%define FUNC_DRAW_ASCII       0x402920

%define REPLAY_MANAGER_PTR  0x18b8a28
%define BULLET_MANAGER_BASE 0xf54e90
%define EFFECT_MANAGER_BASE 0x4ece60
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
    sub  esp, 0x100
    lea  edi, [ebp-0x100]
    push dword [ebp+0x14] ; arg
    push dword [ebp+0x10] ; template
    push edi  ; buffer
    mov  eax, FUNC_SPRINTF
    call eax
    add  esp, 0x0c  ; caller cleans stack for varargs

    push edi  ; string
    push dword [ebp+0x0c] ; pos
    mov  ecx, [ebp+0x08] ; AsciiManager
    mov  eax, FUNC_DRAW_ASCII
    call eax
    add  esp, 0x100
    epilogue_sd
    ret 0x10

bullet_data:  ; HEADER: AUTO
    dd KIND_EMBEDDED
istruc EmbeddedSpec
    at EmbeddedSpec.show_when_nonzero, dd REPLAY_MANAGER_PTR
    at EmbeddedSpec.struct_base, dd BULLET_MANAGER_BASE
    at EmbeddedSpec.spec_kind, dd KIND_ARRAY
    at EmbeddedSpec.spec_size, dd ArraySpec_size
iend
istruc ArraySpec
    at ArraySpec.struct_ptr, dd 0xDEADBEEF ; unused
    at ArraySpec.length_is_addr, dd 1
    at ArraySpec.length_correction, dd -1
    at ArraySpec.array_length, dd 0x42f446 - 4
    at ArraySpec.array_offset, dd BULLET_ARRAY_OFFSET
    at ArraySpec.field_offset, dd 0xdb8
    at ArraySpec.stride, dd 0x10b8
iend

normal_item_data:  ; HEADER: AUTO
    dd KIND_EMBEDDED
istruc EmbeddedSpec
    at EmbeddedSpec.show_when_nonzero, dd REPLAY_MANAGER_PTR
    at EmbeddedSpec.struct_base, dd ITEM_MANAGER_BASE
    at EmbeddedSpec.spec_kind, dd KIND_ARRAY
    at EmbeddedSpec.spec_size, dd ArraySpec_size
iend
istruc ArraySpec
    at ArraySpec.struct_ptr, dd 0xDEADBEEF ; unused
    at ArraySpec.length_is_addr, dd 1
    at ArraySpec.length_correction, dd -1
    at ArraySpec.array_length, dd 0x440021 - 4
    at ArraySpec.array_offset, dd ITEM_ARRAY_OFFSET
    at ArraySpec.field_offset, dd 0x2d5
    at ArraySpec.stride, dd 0x2e4
iend

cancel_item_data:  ; HEADER: AUTO
    dd 0

laser_data:  ; HEADER: AUTO
    dd KIND_EMBEDDED
istruc EmbeddedSpec
    at EmbeddedSpec.show_when_nonzero, dd REPLAY_MANAGER_PTR
    at EmbeddedSpec.struct_base, dd BULLET_MANAGER_BASE
    at EmbeddedSpec.spec_kind, dd KIND_ARRAY
    at EmbeddedSpec.spec_size, dd ArraySpec_size
iend
istruc ArraySpec
    at ArraySpec.struct_ptr, dd 0xDEADBEEF ; unused
    at ArraySpec.length_is_addr, dd 1
    at ArraySpec.length_correction, dd 0
    at ArraySpec.array_length, dd 0x42f464 - 4
    at ArraySpec.array_offset, dd LASER_ARRAY_OFFSET
    at ArraySpec.field_offset, dd 0x584
    at ArraySpec.stride, dd 0x59c
iend

effect_1_data:  ; HEADER: AUTO
    dd KIND_EMBEDDED
istruc EmbeddedSpec
    at EmbeddedSpec.show_when_nonzero, dd REPLAY_MANAGER_PTR
    at EmbeddedSpec.struct_base, dd EFFECT_MANAGER_BASE
    at EmbeddedSpec.spec_kind, dd KIND_ARRAY
    at EmbeddedSpec.spec_size, dd ArraySpec_size
iend
istruc ArraySpec
    at ArraySpec.struct_ptr, dd 0xDEADBEEF ; unused
    at ArraySpec.length_is_addr, dd 1
    at ArraySpec.length_correction, dd 0
    at ArraySpec.array_length, dd 0x425468 - 4
    at ArraySpec.array_offset, dd 0x1c
    at ArraySpec.field_offset, dd 0x350
    at ArraySpec.stride, dd 0x360
iend

effect_2_data:  ; HEADER: AUTO
    dd KIND_EMBEDDED
istruc EmbeddedSpec
    at EmbeddedSpec.show_when_nonzero, dd REPLAY_MANAGER_PTR
    at EmbeddedSpec.struct_base, dd EFFECT_MANAGER_BASE
    at EmbeddedSpec.spec_kind, dd KIND_ARRAY
    at EmbeddedSpec.spec_size, dd ArraySpec_size
iend
istruc ArraySpec
    at ArraySpec.struct_ptr, dd 0xDEADBEEF ; unused
    at ArraySpec.length_is_addr, dd 1
    at ArraySpec.length_correction, dd 0
    at ArraySpec.array_length, dd 0x425ba9 - 4
    at ArraySpec.array_offset, dd 0x6c01c
    at ArraySpec.field_offset, dd 0x350
    at ArraySpec.stride, dd 0x360
iend

effect_3_data:  ; HEADER: AUTO
    dd KIND_EMBEDDED
istruc EmbeddedSpec
    at EmbeddedSpec.show_when_nonzero, dd REPLAY_MANAGER_PTR
    at EmbeddedSpec.struct_base, dd EFFECT_MANAGER_BASE
    at EmbeddedSpec.spec_kind, dd KIND_ARRAY
    at EmbeddedSpec.spec_size, dd ArraySpec_size
iend
istruc ArraySpec
    at ArraySpec.struct_ptr, dd 0xDEADBEEF ; unused
    at ArraySpec.length_is_addr, dd 0
    at ArraySpec.length_correction, dd 0
    at ArraySpec.array_length, dd 0xd
    at ArraySpec.array_offset, dd 0x8701c
    at ArraySpec.field_offset, dd 0x350
    at ArraySpec.stride, dd 0x360
iend
get_color:  ; DELETE
