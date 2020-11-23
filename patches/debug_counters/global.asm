
%include "util.asm"
%include "common.asm"

; AUTO_PREFIX: ExpHP.debug-counters.

line_info: ; DELETE
color_data: ; DELETE
bullet_cap_status:  ; DELETE
adjust_field_ptr:  ; DELETE

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
    mov  edi, line_info  ; REWRITE: <codecave:AUTO>

.iter:
    mov  eax, [edi]  ; read discriminant
    add  edi, 0x4  ; advance to data
    cmp  eax, LINE_INFO_DONE
    je   .end
    cmp  eax, LINE_INFO_POSITIONING
    je   .positioning
    cmp  eax, LINE_INFO_ENTRY
    je   .entry
    die  ; bad discriminant

.positioning:
    mov  eax, [edi+LineInfoPositioning.pos+0x00]
    mov  [%$pos_x], eax
    mov  eax, [edi+LineInfoPositioning.pos+0x04]
    mov  [%$pos_y], eax
    mov  eax, [edi+LineInfoPositioning.pos+0x08]
    mov  [%$pos_z], eax
    mov  eax, [edi+LineInfoPositioning.pos+0x0c]
    mov  [%$delta_y], eax

    add  edi, LineInfoPositioning_size
    jmp .iter

.entry:
    lea  eax, [edi + LineInfoEntry.fmt_string]
    push eax
    push dword [edi + LineInfoEntry.data_ptr]
    lea  eax, [%$pos_x]
    push eax
    call drawf_spec  ; REWRITE: [codecave:AUTO]

    ; move up to next display position
    movss xmm0, [%$pos_y]
    addss xmm0, [%$delta_y]
    movss [%$pos_y], xmm0

    add  edi, LineInfoEntry_size
    jmp .iter

.end:
    pop  edi
    leave
    ret
    %pop

; =============================================================================

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
    ; 'near' forces a 4 byte operand so we can rewrite it
    cmp  eax, KIND_ARRAY
    jz near drawf_array_spec  ; REWRITE: [codecave:AUTO]

    cmp  eax, KIND_ANMID
    jz near drawf_anmid_spec  ; REWRITE: [codecave:AUTO]

    cmp  eax, KIND_FIELD
    jz near drawf_field_spec  ; REWRITE: [codecave:AUTO]

    cmp  eax, KIND_ZERO
    jz near drawf_zero_spec  ; REWRITE: [codecave:AUTO]

    cmp  eax, KIND_EMBEDDED
    jz near drawf_embedded_spec  ; REWRITE: [codecave:AUTO]

    cmp  eax, KIND_LIST
    jz near drawf_list_spec  ; REWRITE: [codecave:AUTO]

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
    push esi

    mov esi, [%$spec_ptr]
    mov eax, [esi + ArraySpec.struct_ptr]
    mov eax, [eax]
    test eax, eax
    jz .nostruct

    lea  eax, [esi + ArraySpec.limit]
    push eax
    call parse_limit  ; REWRITE: [codecave:AUTO]
    mov  [%$limit], eax

    push dword [%$limit]
    push dword [%$spec_ptr]
    call count_array_items_with_nonzero_byte  ; REWRITE: [codecave:AUTO]
    push eax
    push dword [%$fmt]
    push dword [%$limit]
    push dword [%$pos_ptr]
    call drawf_debug_int_colorval  ; REWRITE: [codecave:AUTO]

.nostruct:
    pop esi
    leave
    ret 0xc
    %pop

; __stdcall void DrawfFieldSpec(Float3*, FieldSpec*, char* fmt)
drawf_field_spec:  ; HEADER: AUTO
    %push
    %define %$pos_ptr  ebp+0x08
    %define %$spec_ptr ebp+0x0c
    %define %$fmt      ebp+0x10
    enter 0x04, 0
    %define %$limit    ebp-0x04
    push edi
    push esi

    mov esi, [%$spec_ptr]
    mov eax, [esi + FieldSpec.struct_ptr]
    mov edi, [eax]
    test edi, edi
    jz .nostruct

    lea  eax, [esi + FieldSpec.limit]
    push eax
    call parse_limit  ; REWRITE: [codecave:AUTO]
    mov  [%$limit], eax

    mov  eax, [esi + FieldSpec.count_offset]
    push dword [edi+eax] ; count
    push dword [%$fmt]
    push dword [%$limit]
    push dword [%$pos_ptr]
    call drawf_debug_int_colorval  ; REWRITE: [codecave:AUTO]

.nostruct:
    pop esi
    pop edi
    leave
    ret 0xc
    %pop

; __stdcall void DrawfListSpec(Float3*, ListSpec*, char* fmt)
drawf_list_spec:  ; HEADER: AUTO
    %push
    %define %$pos_ptr  ebp+0x08
    %define %$spec_ptr ebp+0x0c
    %define %$fmt      ebp+0x10
    enter 0x04, 0
    %define %$limit    ebp-0x04
    push edi
    push esi

    mov esi, [%$spec_ptr]
    mov eax, [esi + ListSpec.struct_ptr]
    mov edi, [eax]  ; struct pointer
    test edi, edi
    jz .nostruct

    lea  eax, [esi + ListSpec.limit]
    push eax
    call parse_limit  ; REWRITE: [codecave:AUTO]
    mov  [%$limit], eax

    mov  eax, [esi + ListSpec.head_ptr_offset]
    push dword [edi+eax]
    call count_linked_list  ; REWRITE: [codecave:AUTO]

    push dword eax
    push dword [%$fmt]
    push dword [%$limit]
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
    enter 0x08, 0
    %define %$total    ebp-0x04
    %define %$limit    ebp-0x08
    push edi
    push esi

    mov esi, [%$spec_ptr]
    mov eax, [esi + AnmidSpec.struct_ptr]
    mov edi, [eax]  ; AnmManager pointer
    test edi, edi
    jz .nostruct

    lea  eax, [esi + AnmidSpec.limit]
    push eax
    call parse_limit  ; REWRITE: [codecave:AUTO]
    mov  [%$limit], eax

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
    push dword [%$limit]
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
; __stdcall void CountArrayItemsWithNonzeroByte(ArraySpec* spec, int length)
count_array_items_with_nonzero_byte:  ; HEADER: AUTO
    %push
    %define %$data_ptr      ebp+0x8
    %define %$length        ebp+0xc
    prologue_sd 0x10
    %define %$remaining     ebp-0x04
    %define %$used_count    ebp-0x08
    %define %$is_dword      ebp-0x0c
    %define %$stride        ebp-0x10
    ; using a register saves some verbosity
    %define %$reg_state_iter  edi

    ; call this before using any variables so we don't have to think about which ones are in volatile registers.
    push dword [%$data_ptr]
    call get_array_from_spec  ; REWRITE: [codecave:AUTO]
    mov  %$reg_state_iter, eax  ; now points to array

    ; Parse field_offset
    mov  dword [%$is_dword], 0x0
    mov  edx, [%$data_ptr]
    mov  eax, [edx + ArraySpec.stride]
    mov  [%$stride], eax
    cmp  dword [edx + ArraySpec.field_offset], 0
    jge  .isbyte
    cmp  dword [edx + ArraySpec.field_offset], FIELD_IS_DWORD
    je   .isdword
    int 3

.isdword:
    ; FIELD_IS_DWORD:  size is dword, offset is zero
    or   dword [%$is_dword], 0x1
    jmp  .doneoffset
.isbyte:
    ; other values:  size is byte, offset is given
    add  %$reg_state_iter, [edx + ArraySpec.field_offset]

.doneoffset:
    ; start countin'!
    mov  dword [%$used_count], 0
    xor  eax, eax
    cmp  dword [%$is_dword], 1
    je   .dworditer
.byteiter:
    dec  dword [%$length]
    js   .end

    cmp  byte [%$reg_state_iter], 0x0
    setne al
    add  [%$used_count], eax

    add  %$reg_state_iter, [%$stride]
    jmp  .byteiter
.dworditer:
    dec  dword [%$length]
    js   .end

    cmp  dword [%$reg_state_iter], 0x0
    setne al
    add  [%$used_count], eax

    add  %$reg_state_iter, [%$stride]
    jmp  .dworditer
.end:
    mov  eax, [%$used_count]
    epilogue_sd
    ret  0x8
    %pop

; __stdcall void* get_array_from_spec(ArraySpecV2* spec)
get_array_from_spec:  ; HEADER: AUTO
    %push
    prologue_sd
    mov  esi, [ebp+0x8]  ; spec

    ; If bullet_cap is installed, it might have moved the array behind a pointer.
    ; Support both games with and without bullet_cap by calling a func from base_exphp.
    test dword [esi + ArraySpec.struct_id], -1
    jz   .noremap
    mov  eax, [esi + ArraySpec.struct_ptr]
    push eax  ; struct base
    add  eax, [esi + ArraySpec.array_offset]
    push eax  ; array ptr
    push dword [esi + ArraySpec.struct_id]
    call adjust_field_ptr  ; REWRITE: [codecave:base-exphp.adjust-field-ptr]
.noremap:
    epilogue_sd
    ret 0x4
    %pop

; __stdcall void DrawfZeroSpec(Float3*, ZeroSpec*, char* fmt)
drawf_zero_spec:  ; HEADER: AUTO
    %push
    %define %$pos_ptr  ebp+0x08
    %define %$spec_ptr ebp+0x0c
    %define %$fmt      ebp+0x10
    prologue_sd

    mov esi, [%$spec_ptr]
    mov eax, [esi + ZeroSpec.struct_ptr]
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

; __stdcall void DrawfEmbeddedSpec(Float3*, EmbeddedSpec*, char* fmt)
drawf_embedded_spec:  ; HEADER: AUTO
    %push
    %define %$pos_ptr  ebp+0x08
    %define %$spec_ptr ebp+0x0c
    %define %$fmt      ebp+0x10
    prologue_sd

    mov esi, [%$spec_ptr]
    mov eax, [esi + EmbeddedSpec.show_when_nonzero]
    mov edi, [eax]
    test edi, edi
    jz .nostruct

    ; Construct a copy of the spec we're delegating to.
    sub  esp, [esi + EmbeddedSpec.spec_size]
    mov  edi, esp  ; edi points to our copy

    push esi  ; save
    push edi  ; save
    mov  ecx, [esi + EmbeddedSpec.spec_size]  ; len
    lea  esi, [esi + EmbeddedSpec.spec]
    rep movsb
    pop  edi  ; go back to beginning of our copy
    pop  esi  ; point to beginning of EmbeddedSpec again

    ; First field of the delegated spec is .struct_ptr; i.e. a pointer to pointer to struct.
    ; Since the EmbeddedSpec holds a pointer to the struct, we make a pointer to that pointer.
    lea  eax, [esi + EmbeddedSpec.struct_base]
    mov  [edi + ZeroSpec.struct_ptr], eax

    ; Write the kind at the address before the copied spec.
    push dword [esi + EmbeddedSpec.spec_kind]

    ; esp now points to a completed, functional copy of the data expected by drawf_spec
    mov  edi, esp
    push dword [%$fmt]
    push edi
    push dword [%$pos_ptr]
    call drawf_spec  ; REWRITE: [codecave:AUTO]

    add  esp, 0x4  ; cleanup spec kind
    add  esp, [esi + EmbeddedSpec.spec_size]  ; cleanup spec copy

.nostruct:
    epilogue_sd
    ret 0xc
    %pop

; =============================================================================

; int ParseLimit(int* limit_const)
parse_limit:  ; HEADER: AUTO
    %push
    enter 0x00, 0

    ; first dword:  zero = value, nonzero = address
    mov  ecx, [ebp+0x08]
    mov  eax, [ecx+0x00]
    test eax, eax
    jz   .is_value
    jg   .is_address
    int 3

.is_value:
    mov  eax, [ecx+0x04]
    jmp  .done
.is_address:
    mov  eax, [eax]       ; read address
    add  eax, [ecx+0x04]  ; add correction
.done:
    leave
    ret 0x4
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
