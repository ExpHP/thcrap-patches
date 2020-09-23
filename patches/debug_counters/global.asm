
%include "util.asm"
%include "common.asm"

; AUTO_PREFIX: ExpHP.debug-counters.

anmid_data:  ; DELETE
laser_data:  ; DELETE
bullet_data: ; DELETE
normal_item_data: ; DELETE
cancel_item_data: ; DELETE

drawf_debug_int: ; DELETE

data:  ; HEADER: AUTO
strings:
.enemy_msg: db "%7d enemy", 0
.normal_item_msg: db "%7d itemN", 0
.cancel_item_msg: db "%7d itemC", 0
.bullet_msg: db "%7d etama", 0
.laser_msg: db "%7d laser", 0,
.anmid_msg: db "%7d anmid", 0
.drawcall_msg: db "%7d draws", 0

show_debug_data:  ; HEADER: AUTO
    %push
    enter 0x14, 0
    %define %$pos_z ebp-0x04
    %define %$pos_y ebp-0x08
    %define %$pos_x ebp-0x0c
    %define %$delta_y ebp-0x10
    %define %$limit   ebp-0x14
    mov dword [%$pos_x], __float32__(548.0)
    mov dword [%$pos_y], __float32__(470.0)
    mov dword [%$pos_z], __float32__(0.0)
    mov dword [%$delta_y], __float32__(10.0)

    %macro next_y 0
        movss xmm0, [%$pos_y]
        subss xmm0, [%$delta_y]
        movss [%$pos_y], xmm0
    %endmacro

    next_y

    mov  eax, data  ; REWRITE: <codecave:AUTO>
    lea  eax, [eax + strings.anmid_msg - data]
    push eax
    push anmid_data  ; REWRITE: <codecave:AUTO>
    lea  eax, [%$pos_x]
    push eax
    call drawf_spec  ; REWRITE: [codecave:AUTO]

    next_y

    mov  eax, data  ; REWRITE: <codecave:AUTO>
    lea  eax, [eax + strings.bullet_msg - data]
    push eax
    push bullet_data  ; REWRITE: <codecave:AUTO>
    lea  eax, [%$pos_x]
    push eax
    call drawf_spec  ; REWRITE: [codecave:AUTO]

    next_y

    mov  eax, data  ; REWRITE: <codecave:AUTO>
    lea  eax, [eax + strings.laser_msg - data]
    push eax
    push laser_data  ; REWRITE: <codecave:AUTO>
    lea  eax, [%$pos_x]
    push eax
    call drawf_spec  ; REWRITE: [codecave:AUTO]

    next_y

    mov  eax, data  ; REWRITE: <codecave:AUTO>
    lea  eax, [eax + strings.cancel_item_msg - data]
    push eax
    push cancel_item_data  ; REWRITE: <codecave:AUTO>
    lea  eax, [%$pos_x]
    push eax
    call drawf_spec  ; REWRITE: [codecave:AUTO]

    next_y

    mov  eax, data  ; REWRITE: <codecave:AUTO>
    lea  eax, [eax + strings.normal_item_msg - data]
    push eax
    push normal_item_data  ; REWRITE: <codecave:AUTO>
    lea  eax, [%$pos_x]
    push eax
    call drawf_spec  ; REWRITE: [codecave:AUTO]

    next_y


.nobullets:

    next_y
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

    cmp  eax, KIND_LASER
    jz near drawf_laser_spec  ; REWRITE: [codecave:AUTO]

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
    call drawf_debug_int  ; REWRITE: [codecave:AUTO]

.nostruct:
    leave
    ret 0xc
    %pop

; __stdcall void DrawfLaserSpec(Float3*, LaserSpec*, char* fmt)
drawf_laser_spec:  ; HEADER: AUTO
    %push
    %define %$pos_ptr  ebp+0x08
    %define %$spec_ptr ebp+0x0c
    %define %$fmt      ebp+0x10
    enter 0x00, 0
    push edi
    push esi

    mov esi, [%$spec_ptr]
    mov eax, [esi + LaserSpec.struct_ptr]
    mov edi, [eax]  ; LaserManager pointer
    test edi, edi
    jz .nostruct

    mov  eax, [esi + LaserSpec.count_offset]
    push dword [edi+eax] ; count
    push dword [%$fmt]
    mov  eax, [esi + LaserSpec.limit_addr]
    push dword [eax]
    push dword [%$pos_ptr]
    call drawf_debug_int  ; REWRITE: [codecave:AUTO]

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
    call drawf_debug_int  ; REWRITE: [codecave:AUTO]

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
