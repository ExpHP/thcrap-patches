
%include "util.asm"

%define ASCII_MANAGER_PTR 0x4776e0
%define ASCIIMGR_COLOR    0x8974
; the drawf function that is only used by FpsCounter and DebugSprtView
%define DRAWF_DEBUG       0x401690
%define COLOR_WHITE       0xffffffff
%define COLOR_NOMINAL     0xffffffff
%define COLOR_WARN        0xfff5782f
%define COLOR_MAX         0xffff3429

struc ArraySpec  ; DELETE
    .struct_ptr: resd 1 ; address of (possibly null) pointer to struct that holds the array  ; DELETE
    .length_is_addr: resd 1  ; boolean.  If 1, the array_length field is an address where length can be found (to support bullet_cap patch)  ; DELETE
    .array_length: resd 1  ; number of items in the array  ; DELETE
    .array_offset: resd 1  ; offset of array in struct  ; DELETE
    .field_offset: resd 1  ; offset of a byte in an array item that is nonzero if and only if the item is in use  ; DELETE
    .stride: resd 1  ; size of each item in the array  ; DELETE
endstruc  ; DELETE

struc ListSpec  ; DELETE
    .struct_ptr: resd 1 ; address of (possibly null) pointer to struct that holds the list head  ; DELETE
    .head_ptr_offset: resd 1  ; offset of field with the (possibly null) pointer to the first entry's LinkedListNode.  ; DELETE
endstruc  ; DELETE

bullet_data: ; DELETE
drawf_debug_int: ; DELETE

data:  ; HEADER: ExpHP.debug-counters.data
strings:
.enemy_msg: db "%7d enemy", 0
.itemmain_msg: db "%7d itemN", 0
.itempiv_msg: db "%7d itemC", 0
.bullet_msg: db "%7d etama", 0
.laser_msg: db "%7d laser", 0,
.anmid_msg: db "%7d anmid", 0
.drawcall_msg: db "%7d draws", 0

show_debug_data:  ; HEADER: ExpHP.debug-counters.show-debug-data
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

    mov eax, bullet_data  ; REWRITE: <codecave:ExpHP.debug-counters.bullet-data>
    mov eax, [eax + ArraySpec.struct_ptr]
    mov eax, [eax]
    test eax, eax
    jz .nobullets

    lea  eax, [%$limit]
    push eax ; out pointer
    push bullet_data  ; REWRITE: <codecave:ExpHP.debug-counters.bullet-data>
    call count_array_items_with_nonzero_byte  ; REWRITE: [codecave:ExpHP.debug-counters.count-array-items-with-nonzero-byte]
    push eax
    mov  eax, data  ; REWRITE: <codecave:ExpHP.debug-counters.data>
    lea  eax, [eax + strings.bullet_msg - data]
    push eax
    push dword [%$limit]
    lea  eax, [%$pos_x]
    push eax
    call drawf_debug_int  ; REWRITE: [codecave:ExpHP.debug-counters.drawf-debug-int]

.nobullets:

    next_y
    leave
    ret
    %pop


; Common implementation for counting used items in an array that lives on some struct.
; (Specifically, searches for items where a specific byte is nonzero.)
; __stdcall int CountArrayItemsWithNonzeroByte(ArraySpec* spec, out int* limit)
count_array_items_with_nonzero_byte:  ; HEADER: ExpHP.debug-counters.count-array-items-with-nonzero-byte
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
    ret  0x4
    %pop

; D3DCOLOR GetColor(int amount, int limit)
get_color:  ; HEADER: ExpHP.debug-counters.get-color
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
