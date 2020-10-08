; AUTO_PREFIX: ExpHP.anm-buffers.

%include "common.asm"
%include "util.asm"

data_16:  ; HEADER: AUTO
istruc GameData  ; DELETE
    at GameData.vm_size, dd 0x5fc
    at GameData.func_malloc, dd 0x4749ac
iend  ; DELETE

; 0x46f6ef  (68fc050000)
alloc_16:  ; HEADER: AUTO
    call new_alloc_vm  ; REWRITE: [codecave:AUTO]
    abs_jmp_hack 0x46f6fc

; 0x46ec48  (50e864930000)
dealloc_16:  ; HEADER: AUTO
    call new_dealloc_vm  ; REWRITE: [codecave:AUTO]
    abs_jmp_hack 0x46ec51

new_alloc_vm:  ; DELETE
new_dealloc_vm:  ; DELETE
