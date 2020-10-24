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

; AUTO_PREFIX: ExpHP.bullet-cap.

%include "util.asm"
%include "common.asm"

; ==========================================
; There aren't many places that are guaranteed to run exactly once,
; so to avoid contention with other patches we choose an innocuous place
; in code that runs while starting a new game, and simply make our
; changes idempotent.

; Early games:  Do it right before the call to BulletManager::initialize.

; 0x43b414  (e8875dffff)
install_08:  ; HEADER: AUTO
    call initialize  ; REWRITE: [codecave:AUTO]

    ; original code
    mov   eax, 0x4311a0
    call  eax
    abs_jmp_hack 0x43b419

; MoF onwards:  Do it right before spawning the game thread

; TH10:  0x420ec8  (e883b20200)
; TH11:  0x420328  (e8d3a10000)
; TH12:  0x422758  (e8a3dd0000)
; TH125: 0x41d9a3  (e8f8c70000)
; TH128: 0x426970  (e83be30000)
; TH13:  0x42c4f0  (e88bed0000)
; TH14:  0x4365c5  (e836f50000)
; TH143: 0x432f6a  (e8611b0100)
; TH15:  0x43cbef  (e8fc0b0100)
; TH16:  0x42d76e  (e83dee0000)
; TH165: 0x429719  (e892000100)
; TH17:  0x4312ff  (e87c0f0100)
install_125:  ; HEADER: AUTO
    push ecx  ; save; might be an arg to the original function
    call initialize  ; REWRITE: [codecave:AUTO]
    pop  ecx

    ; original code
    call_eax 0x44c150  ; TH10
    call_eax 0x42a500  ; TH11
    call_eax 0x430500  ; TH12
    call_eax 0x42a1a0  ; TH125
    call_eax 0x434cb0  ; TH128
    call_eax 0x43b280  ; TH13
    call_eax 0x445b00  ; TH14
    call_eax 0x444ad0  ; TH143
    call_eax 0x44d7f0  ; TH15
    call_eax 0x43c5b0  ; TH16
    call_eax 0x4397b0  ; TH165
    call_eax 0x442280  ; TH17
    ; (can't use call-codecave and ret because it'd mess with stack args to the above call)
    abs_jmp_hack 0x420ecd  ; TH10
    abs_jmp_hack 0x42032d  ; TH11
    abs_jmp_hack 0x42275d  ; TH12
    abs_jmp_hack 0x41d9a8  ; TH125
    abs_jmp_hack 0x426975  ; TH128
    abs_jmp_hack 0x42c4f5  ; TH13
    abs_jmp_hack 0x4365ca  ; TH14
    abs_jmp_hack 0x432f6f  ; TH143
    abs_jmp_hack 0x43cbf4  ; TH15
    abs_jmp_hack 0x42d773  ; TH16
    abs_jmp_hack 0x42971e  ; TH165
    abs_jmp_hack 0x431304  ; TH17


; ==========================================
; Patch for where games without cancel item freelists increment the next index.
;
; Due to the compiler optimizing this check into a bitwise operation,
; we can't use the same value-substituting machinery we use for everything else.

; 0x41bdf9  (4281e2ff070080)
fix_next_cancel_10:  ; HEADER: AUTO
    push edx
    call next_cancel_index  ; REWRITE: [codecave:AUTO]
    mov  edx, eax
    abs_jmp_hack 0x41be0a

; 0x42454d  (4181e1ff070080)
fix_next_cancel_11:  ; HEADER: AUTO
    push ecx
    call next_cancel_index  ; REWRITE: [codecave:AUTO]
    mov  ecx, eax
    abs_jmp_hack 0x42455e

; 0x427859  (4281e2ff070080)
fix_next_cancel_12:  ; HEADER: AUTO
    push edx
    call next_cancel_index  ; REWRITE: [codecave:AUTO]
    mov  edx, eax
    abs_jmp_hack 0x42786a

; ==========================================
; Fixes the huge lag spikes that causes the game to appear to freeze when
; canceling >10000 bullets.

; TH10: 0x4491cd  (8b82d4da7200)
; TH11: 0x4561ed  (8b822c567b00)
; TH13: 0x46fbae  (8b820882f400)
perf_hack_10_11:
    push edx  ; save
    push ecx  ; save
    push ecx  ; argument
    call less_spikey_find_world_vm  ; REWRITE: [codecave:AUTO]
    pop  ecx
    pop  edx

    test eax, eax
    jz   .continue

.success:
    pop  ebp  ; !!! TH13 only
    ret  0x4  ; exit early from this function

.continue:
    ; go to part that checks UI list
    push esi  ; stack operation in code we're skipping over
    abs_jmp_hack 0x4491e5 ; TH10
    abs_jmp_hack 0x456205 ; TH11
    abs_jmp_hack 0x46fbd1 ; TH13

; ==========================================
; defined in global.yaml  ; DELETE
initialize:  ; DELETE
next_cancel_index:  ; DELETE
less_spikey_find_world_vm:  ; DELETE
