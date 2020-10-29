; (for once, this .asm file actually IS a source file.
;  Its "compilation" hinges on a number of terrifyingly fragile string transformations
;  stacked like a house of cards on top of nasm's output, and requires delicate placement
;  of tons of cryptic meta-comments like "; DELETE".  But it *is* fully automated by make.)

%include "util.asm"

%define SCREEN_MIN_X_SUBPIXELS      -0x6000
%define PLAYER_MIN_X_SUBPIXELS      -0x5C00
%define PLAYER_MAX_X_SUBPIXELS       0x5C00
%define SCREEN_MAX_X_SUBPIXELS       0x6000
; In SA, the gap halfwidth is 0x800 for the player, and 0x600 for options (causing them to stutter a
; bit as reimu crosses).  Doing the same thing here would be a lot more noticeable.  Thus we pick the
; smaller value for better memes.
%define GAP_HALFWIDTH_SUBPIXELS       0x600
%define GAP_MIN_X_SUBPIXELS         (SCREEN_MIN_X_SUBPIXELS - GAP_HALFWIDTH_SUBPIXELS)
%define GAP_MAX_X_SUBPIXELS         (SCREEN_MAX_X_SUBPIXELS + GAP_HALFWIDTH_SUBPIXELS)
%define NEXT_SCREEN_MIN_X_SUBPIXELS (GAP_MAX_X_SUBPIXELS + GAP_HALFWIDTH_SUBPIXELS)
%define ORIGIN_TO_ORIGIN_SUBPIXELS  (NEXT_SCREEN_MIN_X_SUBPIXELS - SCREEN_MIN_X_SUBPIXELS)

%define FILE_MAP_ALL_ACCESS 0xf001f
%define PAGE_READWRITE 0x4
%define INVALID_HANDLE_VALUE -1

; Not a codecave we ourselves use, but rather a special one that thcrap looks for.
thcrap_keyword_protection:  ; HEADER: protection
    db 0x64  ; READ_WRITE_EXECUTE

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
    .client_controls_player: resd 1  ; DELETE
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

; ClientCommunicatePlayerPos(zInt2*)
client_communicate_player_pos:  ; HEADER: ExpHP.ddc-gap.client-communicate-player-pos
    prologue_sd
    mov  esi, [ebp+0x8]

    call is_client_controlling_player  ; REWRITE: [codecave:ExpHP.ddc-gap.is-client-controlling-player]
    test eax, eax
    jnz  .client_control

.server_control:
    push dword [ebp+0x8]
    call recv_player_pos  ; REWRITE: [codecave:ExpHP.ddc-gap.recv-player-pos]
    sub  dword [esi+0x0], ORIGIN_TO_ORIGIN_SUBPIXELS
    jmp  .end

.client_control:
    push dword [ebp+0x8]
    add  dword [esi+0x0], ORIGIN_TO_ORIGIN_SUBPIXELS
    call send_player_pos  ; REWRITE: [codecave:ExpHP.ddc-gap.send-player-pos]
    sub  dword [esi+0x0], ORIGIN_TO_ORIGIN_SUBPIXELS

.end:
    epilogue_sd
    ret  4

; ServerCommunicatePlayerPos(zInt2*)
server_communicate_player_pos:  ; HEADER: ExpHP.ddc-gap.server-communicate-player-pos
    prologue_sd

    call is_client_controlling_player  ; REWRITE: [codecave:ExpHP.ddc-gap.is-client-controlling-player]
    test eax, eax
    jnz  .client_control

.server_control:
    push dword [ebp+0x8]
    call send_player_pos  ; REWRITE: [codecave:ExpHP.ddc-gap.send-player-pos]
    jmp  .end

.client_control:
    push dword [ebp+0x8]
    call recv_player_pos  ; REWRITE: [codecave:ExpHP.ddc-gap.recv-player-pos]

.end:
    epilogue_sd
    ret  4

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

; SetServerControlIfGapping(DWORD player_gap_state)
set_server_control_if_gapping:  ; HEADER: ExpHP.ddc-gap.set-server-control-if-gapping
    prologue_sd

    mov  edi, data  ; REWRITE: <codecave:ExpHP.ddc-gap.data>
    mov  edi, [edi + pointers.shmem_view - data]

    mov  eax, [ebp+0x8]
    cmp  eax, 99
    je   .server_control
    cmp  eax, 100
    je   .server_control

.client_control:
    mov  dword [edi + Shmem.client_controls_player], 1
    jmp  .end
.server_control:
    mov  dword [edi + Shmem.client_controls_player], 0
.end:
    epilogue_sd
    ret  4

is_client_controlling_player:  ;  HEADER: ExpHP.ddc-gap.is-client-controlling-player
    prologue_sd
    mov  edi, data  ; REWRITE: <codecave:ExpHP.ddc-gap.data>
    mov  edi, [edi + pointers.shmem_view - data]
    mov  eax, [edi + Shmem.client_controls_player]
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
