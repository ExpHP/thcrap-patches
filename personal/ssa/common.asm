; (for once, this .asm file actually IS a source file.
;  Its "compilation" hinges on a number of terrifyingly fragile string transformations
;  stacked like a house of cards on top of nasm's output, and requires delicate placement
;  of tons of cryptic meta-comments like "; DELETE".  But it *is* fully automated by make.)

%include "util.asm"

%define FILE_MAP_ALL_ACCESS 0xf001f
%define PAGE_READWRITE 0x4
%define INVALID_HANDLE_VALUE -1

data:  ; HEADER: ExpHP.ddc-gap.data
; Arrange in decreasing order of type alignment; future versions of thcrap may align codecaves
; so that this actually results in proper alignment.
state:
.has_init: dd 0
functions:
.ReleaseSemaphore: dd 0
.CreateSemaphoreA: dd 0
.CreateFileMappingA: dd 0
.MapViewOfFile: dd 0
pointers:
.semaphore_stage_s2c: dd 0
.semaphore_stage_c2s: dd 0
.semaphore_frame_s2c: dd 0
.shmem_file: dd 0
.shmem_view: dd 0
wstrings:
.user32: dw 'u', 's', 'e', 'r', '3', '2', 0
.kernel32: dw 'K', 'e', 'r', 'n', 'e', 'l', '3', '2', 0
strings:
.ReleaseSemaphore: db "ReleaseSemaphore", 0
.CreateSemaphoreA: db "CreateSemaphoreA", 0
.CreateFileMappingA: db "CreateFileMappingA", 0
.MapViewOfFile: db "MapViewOfFile", 0
.semaphore_stage_s2c_name: db "ExpHP-ssa-st-s2c.sem", 0
.semaphore_stage_c2s_name: db "ExpHP-ssa-st-c2s.sem", 0
.semaphore_frame_s2c_name: db "ExpHP-ssa-fr-s2c.sem", 0
.shmem_name: db "ExpHP-ssa.shmem", 0

struc Shmem  ; DELETE
    .raw_input: resd 1  ; DELETE
    .player_pos: resd 2  ; DELETE
endstruc  ; DELETE

; Thing declared in per-game files.  ; DELETE
corefuncs:  ; DELETE
.GetLastError: dd 0  ; DELETE
.GetModuleHandleW: dd 0  ; DELETE
.GetProcAddress: dd 0  ; DELETE
.WaitForSingleObject: dd 0  ; DELETE
%define NUM_COREFUNCS 4

gamedata:  ; DELETE
.HARDWARE_INPUT: dd 0  ; DELETE

server_start_stage:  ; HEADER: ExpHP.ddc-gap.server-start-stage
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

client_start_stage:  ; HEADER: ExpHP.ddc-gap.client-start-stage
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

server_send_input:  ; HEADER: ExpHP.ddc-gap.server-send-input
    prologue_sd
    call initialize  ; REWRITE: [codecave:ExpHP.ddc-gap.initialize]

    mov  edi, gamedata  ; REWRITE: <codecave:ExpHP.ddc-gap.gamedata>
    mov  eax, [edi + gamedata.HARDWARE_INPUT - gamedata]
    mov  eax, [eax]

    mov  edi, data  ; REWRITE: <codecave:ExpHP.ddc-gap.data>
    mov  ecx, [edi + pointers.shmem_view - data]
    mov  [ecx + Shmem.raw_input], eax

    epilogue_sd
    ret

client_recv_input:  ; HEADER: ExpHP.ddc-gap.client-recv-input
    prologue_sd
    call initialize  ; REWRITE: [codecave:ExpHP.ddc-gap.initialize]

    mov  edi, data  ; REWRITE: <codecave:ExpHP.ddc-gap.data>
    mov  eax, [edi + pointers.shmem_view - data]
    mov  eax, [eax + Shmem.raw_input]

    ; OR so that the client can be controlled on its own to navigate main menus.
    mov  edi, gamedata  ; REWRITE: <codecave:ExpHP.ddc-gap.gamedata>
    mov  ecx, [edi + gamedata.HARDWARE_INPUT - gamedata]
    or   [ecx], eax

    epilogue_sd
    ret

; SendPlayerPos(zInt2*)
send_player_pos:  ; HEADER: ExpHP.ddc-gap.send-player-pos
    prologue_sd

    mov  esi, [ebp+0x8]
    mov  edi, data  ; REWRITE: <codecave:ExpHP.ddc-gap.data>
    mov  edi, [edi + pointers.shmem_view - data]
    lea  edi, [edi + Shmem.player_pos]

    movq xmm0, qword [esi+0x0]
    movq qword [edi+0x0], xmm0

    epilogue_sd
    ret  4

; RecvPlayerPos(zInt2*)
recv_player_pos:  ; HEADER: ExpHP.ddc-gap.recv-player-pos
    prologue_sd

    mov  esi, [ebp+0x8]
    mov  edi, data  ; REWRITE: <codecave:ExpHP.ddc-gap.data>
    mov  edi, [edi + pointers.shmem_view - data]
    lea  edi, [edi + Shmem.player_pos]

    movq xmm0, qword [edi+0x0]
    movq qword [esi+0x0], xmm0

    epilogue_sd
    ret  4

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
    push ebx

    mov  edi, data  ; REWRITE: <codecave:ExpHP.ddc-gap.data>

    mov  eax, [edi + state.has_init - data]
    test eax, eax
    jnz  .skip

    call initialize_corefuncs  ; REWRITE: [codecave:ExpHP.ddc-gap.initialize-corefuncs]

    lea  eax, [edi + wstrings.kernel32 - data]
    push eax
    mov  eax, corefuncs  ; REWRITE: <codecave:ExpHP.ddc-gap.corefuncs>
    call dword [eax + corefuncs.GetModuleHandleW - corefuncs]
    mov  esi, eax

    mov  ebx, corefuncs  ; REWRITE: <codecave:ExpHP.ddc-gap.corefuncs>
    mov  ebx, [ebx + corefuncs.GetProcAddress - corefuncs]
    %macro doGetProcAddress 1
        lea  eax, [edi + strings.%1 - data]
        push eax
        push esi
        call ebx
        mov  [edi + functions.%1 - data], eax
    %endmacro 

    doGetProcAddress ReleaseSemaphore
    doGetProcAddress CreateFileMappingA
    doGetProcAddress CreateSemaphoreA
    doGetProcAddress MapViewOfFile

    %unmacro doGetProcAddress 1

    mov  ebx, create_semaphore  ; REWRITE: <codecave:ExpHP.ddc-gap.create-semaphore>
    %macro createSemaphore 1
    lea  eax, [edi + strings.%{1}_name - data]
    push eax
    call ebx
    mov  [edi + pointers.%{1} - data], eax
    %endmacro

    createSemaphore semaphore_stage_s2c
    createSemaphore semaphore_stage_c2s
    createSemaphore semaphore_frame_s2c

    %unmacro createSemaphore 1

    lea  eax, [edi + strings.shmem_name - data]  ; lpName
    push eax
    push Shmem_size  ; dwMaximumSizeLow
    push 0  ; dwMaximumSizeHigh
    push PAGE_READWRITE  ; flProtect
    push 0  ; lpFileMappingAttributes
    push INVALID_HANDLE_VALUE  ; hFile
    call [edi + functions.CreateFileMappingA - data]
    test eax, eax
    jz   .dead
    mov  dword [edi + pointers.shmem_file - data], eax

    push 0  ; dwNumberOfBytesToMap
    push 0  ; dwFileOffsetLow
    push 0  ; dwFileOffsetHigh
    push FILE_MAP_ALL_ACCESS  ; dwDesiredAccess
    push eax  ; hFileMappingObject
    call [edi + functions.MapViewOfFile - data]
    test eax, eax
    jz   .dead
    mov  dword [edi + pointers.shmem_view - data], eax

    mov  dword [edi + state.has_init - data], 1
.skip:
    pop ebx
    epilogue_sd
    ret
.dead:
    mov  eax, corefuncs  ; REWRITE: <codecave:ExpHP.ddc-gap.corefuncs>
    call dword [eax + corefuncs.GetLastError - corefuncs]
    int  3

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
