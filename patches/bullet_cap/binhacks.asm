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
; in the function that starts the game thread, and simply make our
; changes idempotent.

; 0x420ec8  (e883b20200)
install_10:  ; HEADER: AUTO
    call initialize  ; REWRITE: [codecave:AUTO]

    ; original code
    mov   eax, 0x44c150
    call  eax
    abs_jmp_hack 0x420ecd

; 0x42a51e  (be703a4c00)
install_11:  ; HEADER: AUTO
    call initialize  ; REWRITE: [codecave:AUTO]

    ; original code
    mov   esi, 0x4c3a70
    abs_jmp_hack 0x42a523

; 0x43051e  (bed8f04c00)
install_12:  ; HEADER: AUTO
    call initialize  ; REWRITE: [codecave:AUTO]

    ; original code
    mov   esi, 0x4cf0d8
    abs_jmp_hack 0x430523

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
    ret  0x4  ; exit early from this function

.continue:
    ; go to part that checks UI list
    push esi  ; stack operation in code we're skipping over
    abs_jmp_hack 0x4491e5 ; TH10
    abs_jmp_hack 0x456205 ; TH11

; ==========================================
; defined in global.yaml  ; DELETE
initialize:  ; DELETE
next_cancel_index:  ; DELETE
less_spikey_find_world_vm:  ; DELETE
