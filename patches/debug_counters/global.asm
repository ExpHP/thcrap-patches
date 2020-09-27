
%include "util.asm"
%include "common.asm"

; AUTO_PREFIX: ExpHP.debug-counters.

line_info: ; DELETE
color_data: ; DELETE

; Each game.asm implements this to provide a stdcall wrapper around AsciiManager::drawf_debug
; for a format string that takes a single DWORD integer:
;
; __stdcall DrawfDebugInt(AnmManager*, Float3*, char*, int)
drawf_debug_int: ; DELETE


show_debug_data:  ; HEADER: AUTO
    %push
    enter 0x14, 0
    %define %$pos_z ebp-0x04
    %define %$pos_y ebp-0x08
    %define %$pos_x ebp-0x0c
    %define %$delta_y ebp-0x10
    %define %$limit   ebp-0x14
    push edi

    mov dword [%$pos_x], __float32__(548.0)
    mov dword [%$pos_y], __float32__(470.0)
    mov dword [%$pos_z], __float32__(0.0)
    mov dword [%$delta_y], __float32__(10.0)

    mov  edi, line_info  ; REWRITE: <codecave:AUTO>

.iter:
    mov  eax, [edi + LineInfoEntry.data_ptr]
    test eax, eax
    jz   .end

    ; move up to next display position
    movss xmm0, [%$pos_y]
    subss xmm0, [%$delta_y]
    movss [%$pos_y], xmm0

    lea  eax, [edi + LineInfoEntry.fmt_string]
    push eax
    push dword [edi + LineInfoEntry.data_ptr]
    lea  eax, [%$pos_x]
    push eax
    call drawf_spec  ; REWRITE: [codecave:AUTO]

    add  edi, LineInfoEntry_size
    jmp .iter
.end:

    pop  edi
    leave
    ret
    %pop

; __stdcall void DrawfSpec(Float3*, Spec*, char* fmt)
drawf_spec:  ; HEADER: AUTO
    ; read the first field (discriminant) of the spec and then advance it to point after
    mov  eax, [esp+0x8]
    mov  eax, [eax]
    add  dword [esp+0x8], 0x4

    test eax, eax
    jnz  .nonzero
    ret  0xc  ; for zero write nothing; this lets lines be disabled for debugging and gradual implementation

.nonzero:

    ; 'near' forces a 4 byte operand
    cmp  eax, KIND_ARRAY
    jz near drawf_array_spec  ; REWRITE: [codecave:AUTO]

    cmp  eax, KIND_ANMID
    jz near drawf_anmid_spec  ; REWRITE: [codecave:AUTO]

    cmp  eax, KIND_FIELD
    jz near drawf_field_spec  ; REWRITE: [codecave:AUTO]

    cmp  eax, KIND_ZERO
    jz near drawf_zero_spec  ; REWRITE: [codecave:AUTO]

    int 3

; __stdcall void DrawfArraySpec(Float3*, ArraySpec*, char* fmt)
drawf_array_spec:  ; HEADER: AUTO
    %push
    %define %$pos_ptr  ebp+0x08
    %define %$spec_ptr ebp+0x0c
    %define %$fmt      ebp+0x10
    enter 0x08, 0
    %define %$spec     ebp-0x04
    %define %$limit    ebp-0x08

    mov eax, [%$spec_ptr]
    mov eax, [eax + ArraySpec.struct_ptr]
    mov eax, [eax]
    test eax, eax
    jz .nostruct

    lea  eax, [%$limit]
    push eax ; out pointer
    push dword [%$spec_ptr]
    call count_array_items_with_nonzero_byte  ; REWRITE: [codecave:AUTO]
    push eax
    push dword [%$fmt]
    push dword [%$limit]
    push dword [%$pos_ptr]
    call drawf_debug_int_colorval  ; REWRITE: [codecave:AUTO]

.nostruct:
    leave
    ret 0xc
    %pop

; __stdcall void DrawfFieldSpec(Float3*, FieldSpec*, char* fmt)
drawf_field_spec:  ; HEADER: AUTO
    %push
    %define %$pos_ptr  ebp+0x08
    %define %$spec_ptr ebp+0x0c
    %define %$fmt      ebp+0x10
    enter 0x00, 0
    push edi
    push esi

    mov esi, [%$spec_ptr]
    mov eax, [esi + FieldSpec.struct_ptr]
    mov edi, [eax]
    test edi, edi
    jz .nostruct

    mov  eax, [esi + FieldSpec.count_offset]
    push dword [edi+eax] ; count
    push dword [%$fmt]
    mov  eax, [esi + FieldSpec.limit_addr]
    push dword [eax]
    push dword [%$pos_ptr]
    call drawf_debug_int_colorval  ; REWRITE: [codecave:AUTO]

.nostruct:
    pop esi
    pop edi
    leave
    ret 0xc
    %pop

; __stdcall void DrawfAnmidSpec(Float3*, AnmidSpec*, char* fmt)
drawf_anmid_spec:  ; HEADER: AUTO
    %push
    %define %$pos_ptr  ebp+0x08
    %define %$spec_ptr ebp+0x0c
    %define %$fmt      ebp+0x10
    enter 0x04, 0
    %define %$total    ebp-0x04
    push edi
    push esi

    mov esi, [%$spec_ptr]
    mov eax, [esi + AnmidSpec.struct_ptr]
    mov edi, [eax]  ; AnmManager pointer
    test edi, edi
    jz .nostruct

    mov  dword [%$total], 0

    mov  eax, [esi + AnmidSpec.world_head_ptr_offset]
    push dword [edi+eax]
    call count_linked_list  ; REWRITE: [codecave:AUTO]
    add  eax, dword [%$total]
    mov  dword [%$total], eax

    mov  eax, [esi + AnmidSpec.ui_head_ptr_offset]
    push dword [edi+eax]
    call count_linked_list  ; REWRITE: [codecave:AUTO]
    add  eax, dword [%$total]
    mov  dword [%$total], eax

    push dword [%$total]
    push dword [%$fmt]
    push dword [esi + AnmidSpec.num_fast_vms]
    push dword [%$pos_ptr]
    call drawf_debug_int_colorval  ; REWRITE: [codecave:AUTO]

.nostruct:
    pop esi
    pop edi
    leave
    ret 0xc
    %pop

; __stdcall int CountLinkedList(LikedListNode* head)
count_linked_list:  ; HEADER: AUTO
    prologue_sd
    mov  ecx, [ebp+0x08]
    xor  eax, eax
.loop:
    test ecx, ecx
    jz   .end
    inc  eax
    mov  ecx, [ecx+0x04]
    jmp  .loop
.end:
    epilogue_sd
    ret  0x4

; Common implementation for counting used items in an array that lives on some struct.
; (Specifically, searches for items where a specific byte is nonzero.)
; __stdcall int CountArrayItemsWithNonzeroByte(ArraySpec* spec, out int* limit)
count_array_items_with_nonzero_byte:  ; HEADER: AUTO
    %push
    prologue_sd
    push ebx
    %define %$data_ptr      ebp+0x8
    %define %$limit_out_ptr ebp+0xc
    %define %$data         edx
    %define %$bullet_mgr   esi
    %define %$state_iter   edi
    %define %$remaining    ecx
    %define %$used_count   ebx

    mov  %$data, [%$data_ptr]

    mov  eax, [%$data + ArraySpec.length_is_addr]
    test eax, eax
    mov  %$remaining, [%$data + ArraySpec.array_length]
    jz   .notaddr
    mov  %$remaining, [%$remaining]
    add  %$remaining, [%$data + ArraySpec.length_correction]
.notaddr:

    mov  eax, [%$limit_out_ptr]
    mov  [eax], %$remaining ; write max bullets for coloring purposes

    mov  eax, [%$data + ArraySpec.struct_ptr]
    mov  %$bullet_mgr, [eax]
    xor  %$used_count, %$used_count
    test %$bullet_mgr, %$bullet_mgr
    jz  .end

    mov  eax, %$bullet_mgr
    add  eax, [%$data + ArraySpec.array_offset]
    add  eax, [%$data + ArraySpec.field_offset]
    mov  %$state_iter, eax
.iter:
    dec  %$remaining
    js   .end

    xor  eax, eax
    cmp  byte [%$state_iter], 0x0
    setne al
    add  %$used_count, eax

    add  %$state_iter, [%$data + ArraySpec.stride]
    jmp  .iter
.end:
    mov  eax, %$used_count
    pop  ebx
    epilogue_sd
    ret  0x8
    %pop

; __stdcall void DrawfZeroSpec(Float3*, ZeroSpec*, char* fmt)
drawf_zero_spec:  ; HEADER: AUTO
    %push
    %define %$pos_ptr  ebp+0x08
    %define %$spec_ptr ebp+0x0c
    %define %$fmt      ebp+0x10
    prologue_sd

    mov esi, [%$spec_ptr]
    mov eax, [esi + AnmidSpec.struct_ptr]
    mov edi, [eax]  ; AnmManager pointer
    test edi, edi
    jz .nostruct

    push 0
    push dword [%$fmt]
    push 10
    push dword [%$pos_ptr]
    call drawf_debug_int_colorval  ; REWRITE: [codecave:AUTO]

.nostruct:
    epilogue_sd
    ret 0xc
    %pop

; D3DCOLOR GetColor(int amount, int limit)
get_color:  ; HEADER: AUTO
    %push
    prologue_sd
    %define %$value ebp+0x08
    %define %$limit ebp+0x0c
    mov  esi, COLOR_NOMINAL

    ; Warning color at 75% capacity
    mov  eax, [%$value]
    mov  ecx, [%$limit]
    imul ecx, 0x3
    shr  ecx, 0x2
    cmp  eax, ecx
    mov  edi, COLOR_WARN
    cmovge esi, edi

    mov  eax, [%$value]
    cmp  eax, [%$limit]
    mov  edi, COLOR_MAX
    cmovge esi, edi

    mov  eax, esi
    epilogue_sd
    ret  0x8
    %pop

; Wrapper around DrawfDebugInt that sets color based on value.
;
; DrawfDebugIntColorval(Float3*, int limit, char* fmt, int amount)
drawf_debug_int_colorval:  ; HEADER: AUTO
    prologue_sd
    ; get ptr to AsciiManager color field
    mov  edi, color_data  ; REWRITE: <codecave:AUTO>
    mov  esi, [edi + ColorData.ascii_manager_ptr]
    mov  esi, [esi]
    add  esi, [edi + ColorData.color_offset]

    push dword [ebp+0x0c] ; limit
    push dword [ebp+0x14] ; current
    call get_color  ; REWRITE: [codecave:AUTO]
    mov  [esi], eax

    push dword [ebp+0x14] ; arg
    push dword [ebp+0x10] ; template
    push dword [ebp+0x08] ; pos
    mov  eax, [edi + ColorData.ascii_manager_ptr]
    push dword [eax]
    call drawf_debug_int  ; REWRITE: [codecave:AUTO]

    mov  dword [esi], COLOR_WHITE
    epilogue_sd
    ret 0x10
