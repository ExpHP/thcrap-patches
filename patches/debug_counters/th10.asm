
%include "util.asm"
%include "common.asm"

; AUTO_PREFIX: ExpHP.debug-counters.

%define ASCII_MANAGER_PTR 0x4776e0
%define ASCIIMGR_COLOR    0x8974
; the drawf function that is only used by FpsCounter and DebugSprtView
%define DRAWF_DEBUG       0x401690
%define COLOR_WHITE       0xffffffff

cave:  ; 0x413653
    call show_debug_data  ; REWRITE: [codecave:AUTO]

    mov  eax, [ASCII_MANAGER_PTR] ; original code
    abs_jmp_hack 0x413658

; __stdcall void DrawfDebugInt(Float3*, int limit, char*, int current)
drawf_debug_int:  ; HEADER: AUTO
    prologue_sd
    push dword [ebp+0x0c] ; limit
    push dword [ebp+0x14] ; current
    call get_color  ; REWRITE: [codecave:AUTO]
    mov  ecx, [ASCII_MANAGER_PTR]
    mov  [ecx+ASCIIMGR_COLOR], eax

    ; MoF has a weird calling convention
    mov  esi, [ASCII_MANAGER_PTR]
    mov  ebx, [ebp+0x08] ; pos
    push dword [ebp+0x14] ; arg
    push dword [ebp+0x10] ; template
    mov  eax, DRAWF_DEBUG
    call eax
    add  esp, 0x8  ; caller cleans stack for varargs

    mov  dword [esi+ASCIIMGR_COLOR], COLOR_WHITE
    epilogue_sd
    ret 0x10

bullet_data:  ; HEADER: AUTO
    dd KIND_ARRAY
istruc ArraySpec
    at ArraySpec.struct_ptr, dd 0x4776f0
    at ArraySpec.length_is_addr, dd 1
    at ArraySpec.array_length, dd 0x425852
    at ArraySpec.array_offset, dd 0x60
    at ArraySpec.field_offset, dd 0x446
    at ArraySpec.stride, dd 0x7f0
iend

normal_item_data:  ; HEADER: AUTO
    dd KIND_ARRAY
istruc ArraySpec
    at ArraySpec.struct_ptr, dd 0x477818
    at ArraySpec.length_is_addr, dd 0
    at ArraySpec.array_length, dd 0x96
    at ArraySpec.array_offset, dd 0x14
    at ArraySpec.field_offset, dd 0x3dc
    at ArraySpec.stride, dd 0x3f0
iend

cancel_item_data:  ; HEADER: AUTO
    dd KIND_ARRAY
istruc ArraySpec
    at ArraySpec.struct_ptr, dd 0x477818
    at ArraySpec.length_is_addr, dd 0  ; I don't think this length ever explicitly appears in the code
    at ArraySpec.array_length, dd 0x800
    at ArraySpec.array_offset, dd 0x24eb4
    at ArraySpec.field_offset, dd 0x3dc
    at ArraySpec.stride, dd 0x3f0
iend

enemy_data:  ; HEADER: AUTO
    dd KIND_LIST
istruc ListSpec
    at ListSpec.struct_ptr, dd 0x477704
    at ListSpec.head_ptr_offset, dd 0x58
iend

ui_vm_data:
    dd KIND_LIST
istruc ListSpec
    at ListSpec.struct_ptr, dd 0
    at ListSpec.head_ptr_offset, dd 0x72dadc
iend

show_debug_data:  ; DELETE
get_color:  ; DELETE
