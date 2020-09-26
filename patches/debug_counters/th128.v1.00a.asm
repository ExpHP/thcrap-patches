
%include "util.asm"
%include "common.asm"

; AUTO_PREFIX: ExpHP.debug-counters.

%define ASCII_MANAGER_PTR 0x4b8920
%define ASCIIMGR_COLOR    0x1c84c
; the drawf function that is only used by FpsCounter and DebugSprtView
%define DRAWF_DEBUG       0x401900
%define COLOR_WHITE       0xffffffff

; __stdcall void DrawfDebugInt(Float3*, int limit, char*, int current)
drawf_debug_int:  ; HEADER: AUTO
    prologue_sd
    push dword [ebp+0x0c] ; limit
    push dword [ebp+0x14] ; current
    call get_color  ; REWRITE: [codecave:AUTO]
    mov  ecx, [ASCII_MANAGER_PTR]
    mov  [ecx+ASCIIMGR_COLOR], eax

    ; MoF-GFW have a weird calling convention
    sub  esp, 0x4
    mov  edi, esp  ; unknown output pointer added in DS
    mov  esi, [ASCII_MANAGER_PTR]
    push dword [ebp+0x14] ; arg
    push dword [ebp+0x10] ; template
    push dword [ebp+0x08] ; pos
    mov  eax, DRAWF_DEBUG
    call eax
    add  esp, 0xc  ; caller cleans stack for varargs
    add  esp, 0x4  ; cleanup edi

    mov  ecx, [ASCII_MANAGER_PTR]
    mov  dword [ecx+ASCIIMGR_COLOR], COLOR_WHITE
    epilogue_sd
    ret 0x10

bullet_data:  ; HEADER: AUTO
    dd KIND_ARRAY
istruc ArraySpec
    at ArraySpec.struct_ptr, dd 0x4b8930
    at ArraySpec.length_is_addr, dd 1
    at ArraySpec.length_correction, dd 0
    at ArraySpec.array_length, dd 0x408d95 - 4
    at ArraySpec.array_offset, dd 0x64
    at ArraySpec.field_offset, dd 0xa2a
    at ArraySpec.stride, dd 0x11b8
iend

normal_item_data:  ; HEADER: AUTO
    dd KIND_ARRAY
istruc ArraySpec
    at ArraySpec.struct_ptr, dd 0x4b8a5c
    at ArraySpec.length_is_addr, dd 0
    at ArraySpec.length_correction, dd 0
    at ArraySpec.array_length, dd 600
    at ArraySpec.array_offset, dd 0x14
    at ArraySpec.field_offset, dd 0xa18
    at ArraySpec.stride, dd 0xa40
iend

cancel_item_data:  ; HEADER: AUTO
    dd KIND_ARRAY
istruc ArraySpec
    at ArraySpec.struct_ptr, dd 0x4b8a5c
    at ArraySpec.length_is_addr, dd 1
    at ArraySpec.length_correction, dd -600-16  ; the extra 16 is left over from UFO
    at ArraySpec.array_length, dd 0x428550 - 4
    at ArraySpec.array_offset, dd 0x18aa14
    at ArraySpec.field_offset, dd 0xa18
    at ArraySpec.stride, dd 0xa40
iend

laser_data:  ; HEADER: AUTO
    dd KIND_LASER
istruc LaserSpec
    at LaserSpec.struct_ptr, dd 0x4b8a60
    at LaserSpec.count_offset, dd 0x5d4
    at LaserSpec.limit_addr, dd 0x42a411 - 4
iend

anmid_data:  ; HEADER: AUTO
    dd KIND_ANMID
istruc AnmidSpec
    at AnmidSpec.struct_ptr, dd 0x4d2e50
    at AnmidSpec.world_head_ptr_offset, dd 0x8b9704
    at AnmidSpec.ui_head_ptr_offset, dd 0x8b9708
    at AnmidSpec.num_fast_vms, dd 0x1000
iend

get_color:  ; DELETE
