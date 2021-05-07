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

data_17:  ; HEADER: AUTO
istruc GameData  ; DELETE
    at GameData.vm_size, dd 0x600
    at GameData.id_offset, dd 0x538
    at GameData.func_malloc, dd 0x47b250
iend  ; DELETE

data_18tr:  ; HEADER: AUTO
istruc GameData  ; DELETE
    at GameData.vm_size, dd 0x618
    at GameData.id_offset, dd 0x550
    at GameData.func_malloc, dd 0x484851
iend  ; DELETE

; TH15:  0x489479
; TH16:  0x46f619
; TH165: 0x475949
testing:  ; HEADER: AUTO
    abs_jmp_hack 0x48954f  ; TH15
    abs_jmp_hack 0x46f6ef  ; TH16
    abs_jmp_hack 0x475a1f  ; TH165

; replace the "push-call-stack cleanup" sequence
; TH15:  0x48954f  (6808060000)
; TH16:  0x46f6ef  (68fc050000)
; TH165: 0x475a1f  (68fc050000)
;
; th17 defers the stack cleanup so only replace the call
; TH17:  0x476b54  (e8f7460000)
; TH18tr:0x47fbd4  (e8784c0000)
alloc:  ; HEADER: AUTO
    call new_alloc_vm  ; REWRITE: [codecave:AUTO]
    ; to after the malloc and its stack cleanup
    abs_jmp_hack 0x48955c  ; TH15
    abs_jmp_hack 0x46f6fc  ; TH16
    abs_jmp_hack 0x475a2c  ; TH165
    ; to immediately after the call
    abs_jmp_hack 0x476b59  ; TH17
    abs_jmp_hack 0x47fbd9  ; TH18tr

; TH15:  0x44c97c  (e86f3a0400)
; TH16:  0x43b941  (e899900300)
; TH165: 0x438bfe  (e85c570400)
; TH17:  0x476083  (e8f8510000)
; TH18tr:0x47f0c3  (e8b9570000)
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
; TH17:  0x47648d  (8b8edc060000)
; TH18tr:0x47f49d  (8b8ef0060000)
search:  ; HEADER: AUTO
    push eax  ; id
    call new_search  ; REWRITE: [codecave:AUTO]
    ; to function cleanup
    abs_jmp_hack 0x488573  ; TH15
    abs_jmp_hack 0x46f003  ; TH16
    abs_jmp_hack 0x47535a  ; TH165
    abs_jmp_hack 0x4764da  ; TH17
    abs_jmp_hack 0x47f4ea  ; TH18tr

new_alloc_vm:  ; DELETE
new_dealloc_vm:  ; DELETE
new_search:  ; DELETE
