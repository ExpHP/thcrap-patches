; (for once, this actually IS a source file)

%include "util.asm"

data:  ; HEADER: ExpHP.ddc-gap.data
strings:
; Avoid the W form of all synchapi functions because they actually validate 2-byte string alignment
; and we have little control over the placement of our codecave
.ReleaseSemaphore: db "ReleaseSemaphore", 0
.CreateSemaphoreA: db "CreateSemaphoreA", 0
.semaphore_stage_s2c_name: db "ExpHP-ssa-st-s2c.sem", 0
.semaphore_stage_c2s_name: db "ExpHP-ssa-st-c2s.sem", 0
wstrings:
.user32: dw 'u', 's', 'e', 'r', '3', '2', 0
.kernel32: dw 'K', 'e', 'r', 'n', 'e', 'l', '3', '2', 0
state:
.has_init: dd 0
functions:
.ReleaseSemaphore: dd 0
.CreateSemaphoreA: dd 0
pointers:
.semaphore_stage_s2c: dd 0
.semaphore_stage_c2s: dd 0

; Thing declared in per-game files.  ; DELETE
corefuncs:  ; DELETE
.GetLastError: dd 0  ; DELETE
.GetModuleHandleW: dd 0  ; DELETE
.GetProcAddress: dd 0  ; DELETE
.WaitForSingleObject: dd 0  ; DELETE
%define NUM_COREFUNCS 4

start_stage_server:  ; HEADER: ExpHP.ddc-gap.start-stage-server
    prologue_sd
    call initialize  ; REWRITE: [codecave:ExpHP.ddc-gap.initialize]

    mov  edi, data  ; REWRITE: <codecave:ExpHP.ddc-gap.data>

    push 0    ; lpPreviousCount
    push 1    ; lReleaseCount
    mov  eax, [edi + pointers.semaphore_stage_s2c - data]
    push eax  ; handle
    call dword [edi + functions.ReleaseSemaphore - data]

    push -1  ; dwMilliseconds
    mov  eax, [edi + pointers.semaphore_stage_c2s - data]
    push eax
    mov  eax, corefuncs  ; REWRITE: <codecave:ExpHP.ddc-gap.corefuncs>
    call dword [eax + corefuncs.WaitForSingleObject - corefuncs]

    epilogue_sd
    ret

start_stage_client:  ; HEADER: ExpHP.ddc-gap.start-stage-client
    prologue_sd
    call initialize  ; REWRITE: [codecave:ExpHP.ddc-gap.initialize]

    mov  edi, data  ; REWRITE: <codecave:ExpHP.ddc-gap.data>

    push -1  ; dwMilliseconds
    mov  eax, [edi + pointers.semaphore_stage_s2c - data]
    push eax
    mov  eax, corefuncs  ; REWRITE: <codecave:ExpHP.ddc-gap.corefuncs>
    call dword [eax + corefuncs.WaitForSingleObject - corefuncs]

    push 0    ; lpPreviousCount
    push 1    ; lReleaseCount
    mov  eax, [edi + pointers.semaphore_stage_c2s - data]
    push eax  ; handle
    call dword [edi + functions.ReleaseSemaphore - data]

    epilogue_sd
    ret

initialize_corefuncs:  ; HEADER: ExpHP.ddc-gap.initialize-corefuncs
    ; Replace IAT pointers with dereferenced counterparts

    mov  edx, corefuncs  ; REWRITE: <codecave:ExpHP.ddc-gap.corefuncs>
    mov  ecx, NUM_COREFUNCS
.loop:
    mov  eax, [edx]
    mov  eax, [eax]
    mov  [edx], eax
    add  edx, 4

    dec  ecx
    jnz  .loop
.end:
    ret

initialize:  ; HEADER: ExpHP.ddc-gap.initialize
    prologue_sd

    call initialize_corefuncs  ; REWRITE: [codecave:ExpHP.ddc-gap.initialize-corefuncs]

    mov  edi, data  ; REWRITE: <codecave:ExpHP.ddc-gap.data>

    mov  eax, [edi + state.has_init - data]
    test eax, eax
    jnz  .skip

    lea  eax, [edi + wstrings.kernel32 - data]
    push eax
    mov  eax, corefuncs  ; REWRITE: <codecave:ExpHP.ddc-gap.corefuncs>
    call dword [eax + corefuncs.GetModuleHandleW - corefuncs]
    mov  esi, eax

    lea  eax, [edi + strings.ReleaseSemaphore - data]
    push eax
    push esi
    mov  eax, corefuncs  ; REWRITE: <codecave:ExpHP.ddc-gap.corefuncs>
    call dword [eax + corefuncs.GetProcAddress - corefuncs]
    mov  [edi + functions.ReleaseSemaphore - data], eax

    lea  eax, [edi + strings.CreateSemaphoreA - data]
    push eax
    push esi
    mov  eax, corefuncs  ; REWRITE: <codecave:ExpHP.ddc-gap.corefuncs>
    call dword [eax + corefuncs.GetProcAddress - corefuncs]
    mov  [edi + functions.CreateSemaphoreA - data], eax

    lea  eax, [edi + strings.semaphore_stage_s2c_name - data]
    push eax
    call create_semaphore  ; REWRITE: [codecave:ExpHP.ddc-gap.create-semaphore]
    mov  [edi + pointers.semaphore_stage_s2c - data], eax

    lea  eax, [edi + strings.semaphore_stage_c2s_name - data]
    push eax
    call create_semaphore  ; REWRITE: [codecave:ExpHP.ddc-gap.create-semaphore]
    mov  [edi + pointers.semaphore_stage_c2s - data], eax

    mov  dword [edi + state.has_init - data], 1

.skip:
    epilogue_sd
    ret

create_semaphore:  ; HEADER: ExpHP.ddc-gap.create-semaphore
    prologue_sd
    mov  edi, data  ; REWRITE: <codecave:ExpHP.ddc-gap.data>
    mov  eax, [ebp+0x8]
    push eax ; lpName
    push 1   ; lMaximumCount
    push 0   ; lInitialCount
    push 0   ; lpSemaphoreAttributes
    call [edi + functions.CreateSemaphoreA - data]

    test eax, eax
    jnz  .dontdie
    mov  eax, corefuncs  ; REWRITE: <codecave:ExpHP.ddc-gap.corefuncs>
    call dword [eax + corefuncs.GetLastError - corefuncs]
    int  3
.dontdie:
    epilogue_sd
    ret  4
