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
    call client_start_stage  ; REWRITE: [codecave:ExpHP.ddc-gap.client-start-stage]
    ; original code
    mov     edi, dword [0x4db530]
    abs_jmp_hack 0x416253

cave_get_input: ; 0x402092  ; HEADER: cave-get-input
    call client_recv_input  ; REWRITE: [codecave:ExpHP.ddc-gap.client-recv-input]
    ; original code
    mov  ecx, 0x4d6878
    mov  eax, 0x407540
    call eax
    abs_jmp_hack 0x402097

cave_send_player_pos: ; 0x44d805  ; HEADER: cave-send-player-pos
    lea  eax, [edi+0x5ec]
    push eax
    call client_communicate_player_pos  ; REWRITE: [codecave:ExpHP.ddc-gap.client-communicate-player-pos]

    movd xmm0, dword [edi+0x5ec]
    abs_jmp_hack 0x44d80d

corefuncs:  ; HEADER: ExpHP.ddc-gap.corefuncs
; These are pointers to IAT entries, but during initialization we'll replace
; them with pointers to the actual functions.
.GetLastError: dd 0x4b1094
.GetModuleHandleW: dd 0x4b1138
.GetProcAddress: dd 0x4b10f8
.WaitForSingleObject: dd 0x4b10a0

gamedata:  ; HEADER: ExpHP.ddc-gap.gamedata
.HARDWARE_INPUT: dd 0x4d6878
.player_int_pos_offset: dd 0x5ec

client_start_stage:
client_recv_input:
client_communicate_player_pos:

