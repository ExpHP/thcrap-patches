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

cave_start_client: ; 0x41624d  ; HEADER: cave-start-client
    call start_stage_client  ; REWRITE: [codecave:ExpHP.ddc-gap.start-stage-client]
    ; original code
    mov     edi, dword [0x4db530]
    abs_jmp_hack 0x416253

corefuncs:  ; HEADER: ExpHP.ddc-gap.corefuncs
; These are pointers to IAT entries, but during initialization we'll replace
; them with pointers to the actual functions.
.GetLastError: dd 0x4b1094
.GetModuleHandleW: dd 0x4b1138
.GetProcAddress: dd 0x4b10f8
.WaitForSingleObject: dd 0x4b10a0

start_stage_client:
