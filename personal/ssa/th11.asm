; THIS IS NOT A SOURCE FILE
;
; Changing anything in this file will NOT have any effect on the patch.
; This file is where I write the initial asm for many binhacks. Use
;
;     scripts/list-asm source/x.asm
;
; to generate the assembly, copy it into thXX.YAML, and postprocess it with
; some manual fixes like inserting [codecave:yadda-yadda-yadda] and deleting
; dummy labels.

%include "util.asm"

cave_start_server: ; 0x408558  ; HEADER: cave-start-server
    call server_start_stage  ; REWRITE: [codecave:ExpHP.ddc-gap.server-start-stage]
    ; original code
    mov     edi, dword [0x4a8d68]
    abs_jmp_hack 0x40855e

cave_send_input: ; 0x457a0b  ; HEADER: cave-send-input
    call server_send_input  ; REWRITE: [codecave:ExpHP.ddc-gap.server-send-input]
    ; original code
    mov  ecx, 0x4c92a8
    mov  eax, 0x459b50
    call eax
    abs_jmp_hack 0x457a10

corefuncs:  ; HEADER: ExpHP.ddc-gap.corefuncs
; These are pointers to IAT entries, but during initialization we'll replace
; them with pointers to the actual functions.
.GetLastError: dd 0x48b1b8
.GetModuleHandleW: dd 0x48b174
.GetProcAddress: dd 0x48b170
.WaitForSingleObject: dd 0x48b0f0

gamedata:  ; HEADER: ExpHP.ddc-gap.gamedata
.HARDWARE_INPUT: dd 0x4c92a8

server_start_stage:
server_send_input:
