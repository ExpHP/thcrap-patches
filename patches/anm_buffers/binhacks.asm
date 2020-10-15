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

data_165:  ; HEADER: AUTO
istruc GameData  ; DELETE
    at GameData.vm_size, dd 0x5fc
    at GameData.id_offset, dd 0x538
    at GameData.func_malloc, dd 0x47a78d
iend  ; DELETE

; TH15:  0x489479
; TH16:  0x46f619
; TH165: 0x475949
testing:  ; HEADER: AUTO
    abs_jmp_hack 0x48954f  ; TH15
    abs_jmp_hack 0x46f6ef  ; TH16
    abs_jmp_hack 0x475a1f  ; TH165

; TH15:  0x48954f  (6808060000)
; TH16:  0x46f6ef  (68fc050000)
; TH165: 0x475a1f  (68fc050000)
alloc:  ; HEADER: AUTO
    call new_alloc_vm  ; REWRITE: [codecave:AUTO]
    ; to after the malloc and its stack cleanup
    abs_jmp_hack 0x48955c  ; TH15
    abs_jmp_hack 0x46f6fc  ; TH16
    abs_jmp_hack 0x475a2c  ; TH165

; TH15:  0x44c97c  (e86f3a0400)
; TH16:  0x43b941  (e899900300)
; TH165: 0x438bfe  (e85c570400)
dealloc:  ; HEADER: AUTO
    ; since we're in a call, ignore the stuff already pushed and push the vm again
    push esi
    call new_dealloc_vm  ; REWRITE: [codecave:AUTO]
    ; the code that we return to already contains an `add esp, ___` to clean up the stuff we ignored
    ret

; Line that reads world_list_head
; TH15:  0x488534  (8b96dc000000)
; TH16:  0x46efc4  (8b96dc000000)
; TH165: 0x47530d  (8b96dc000000)
search:  ; HEADER: AUTO
    push eax  ; id
    call new_search  ; REWRITE: [codecave:AUTO]
    ; to function cleanup
    abs_jmp_hack 0x488573  ; TH15
    abs_jmp_hack 0x46f003  ; TH16
    abs_jmp_hack 0x47535a  ; TH165

new_alloc_vm:  ; DELETE
new_dealloc_vm:  ; DELETE
new_search:  ; DELETE
