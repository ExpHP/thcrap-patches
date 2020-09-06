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

cave_start_server: ; 0x408558  ; HEADER: cave-start-client
    call start_stage_server  ; REWRITE: [codecave:ExpHP.ddc-gap.start-stage-server]
    ; original code
    mov     edi, dword [0x4a8d68]
    abs_jmp_hack 0x40855e

corefuncs:  ; HEADER: ExpHP.ddc-gap.corefuncs
; These are pointers to IAT entries, but during initialization we'll replace
; them with pointers to the actual functions.
.GetLastError: dd 0x48b1b8
.GetModuleHandleW: dd 0x48b174
.GetProcAddress: dd 0x48b170
.WaitForSingleObject: dd 0x48b0f0

start_stage_server:
