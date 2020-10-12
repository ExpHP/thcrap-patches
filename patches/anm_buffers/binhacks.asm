; AUTO_PREFIX: ExpHP.anm-buffers.

%include "common.asm"
%include "util.asm"

data_15:  ; HEADER: AUTO
istruc GameData  ; DELETE
    at GameData.vm_size, dd 0x608
    at GameData.id_offset, dd 0x544
    at GameData.func_malloc, dd 0x49039f
iend  ; DELETE

data_16:  ; HEADER: AUTO
istruc GameData  ; DELETE
    at GameData.vm_size, dd 0x5fc
    at GameData.id_offset, dd 0x538
    at GameData.func_malloc, dd 0x4749ac
iend  ; DELETE


; 0x489479  ; TH15
; 0x46f619  ; TH16
testing:  ; HEADER: AUTO
    abs_jmp_hack 0x48954f  ; TH15
    abs_jmp_hack 0x46f6ef  ; TH16

; 0x48954f  (6808060000)
; 0x46f6ef  (68fc050000)
alloc:  ; HEADER: AUTO
    call new_alloc_vm  ; REWRITE: [codecave:AUTO]
    ; to after the malloc and its stack cleanup
    abs_jmp_hack 0x48955c  ; TH15
    abs_jmp_hack 0x46f6fc  ; TH16

; 0x44c97c  (e86f3a0400)
; 0x43b941  (e899900300)
dealloc:  ; HEADER: AUTO
    push esi
    call new_dealloc_vm  ; REWRITE: [codecave:AUTO]
    ; jump to the stack cleanup for the free
    abs_jmp_hack 0x44c981  ; TH15
    abs_jmp_hack 0x43b946  ; TH16

; Line that reads world_list_head
; 0x488534  (8b96dc000000)
; 0x46efc4  (8b96dc000000)
search:  ; HEADER: AUTO
    push eax  ; id
    call new_search  ; REWRITE: [codecave:AUTO]
    ; to function cleanup
    abs_jmp_hack 0x488573  ; TH15
    abs_jmp_hack 0x46f003  ; TH16

new_alloc_vm:  ; DELETE
new_dealloc_vm:  ; DELETE
new_search:  ; DELETE
