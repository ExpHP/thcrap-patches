; AUTO_PREFIX: ExpHP.anm-buffers.

%include "common.asm"
%include "util.asm"

data_16:  ; HEADER: AUTO
istruc GameData  ; DELETE
    at GameData.vm_size, dd 0x5fc
    at GameData.id_offset, dd 0x538
    at GameData.func_malloc, dd 0x4749ac
iend  ; DELETE


; 0x46f619
testing_16:  ; HEADER: AUTO
    abs_jmp_hack 0x46f6ef

; 0x46f6ef  (68fc050000)
alloc_16:  ; HEADER: AUTO
    call new_alloc_vm  ; REWRITE: [codecave:AUTO]
    abs_jmp_hack 0x46f6fc

; 0x43b941  (e899900300)
dealloc_16:  ; HEADER: AUTO
    push esi
    call new_dealloc_vm  ; REWRITE: [codecave:AUTO]
    abs_jmp_hack 0x43b946

; 0x46efc4  (8b96dc000000)
search_16:  ; HEADER: AUTO
    push eax  ; id
    call new_search  ; REWRITE: [codecave:AUTO]
    abs_jmp_hack 0x46f003  ; to function cleanup

new_alloc_vm:  ; DELETE
new_dealloc_vm:  ; DELETE
new_search:  ; DELETE
