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

%define CURRENT_LIVES     0x4a5718
%define CURRENT_LIFE_FRAGMENTS  0x4a571c
%define POWER_PER_LEVEL   0x4a574c
%define CURRENT_SCORE     0x4a56e4
%define CURRENT_POWER     0x4a56e8
%define CURRENT_STAGE     0x4a5728
%define MAXIMUM_POWER     0x4a5748
%define CONTINUES_USED    0x4a573c

%define FUNC_GUI_UPDATE_LIVES  0x41a060
%define FUNC_DO_UNPAUSE        0x42c880
%define FUNC_PLAYER_REGEN_OPTIONS  0x432cc0
%define FUNC_MODIFY_BGM         0x44a9c0
%define FUNC_COLLECT_POWER      0x420a00

%define PLAYER_PTR   0x4a8eb4
%define GUI_PTR      0x4a8d84
%define SOUND_MANAGER_START    0x4c3e80
%define GLOBALS_START          0x4a56e0

%define CSTR_BGM_PAUSE 0x494260

%define pmenu_state  0x4

bgm_pause_cave: ; 0x42d630
    ; a line of important code embedded in the block we're skipping
    mov     dword [ebp+0x2dc], edx

    call pause_bgm ; FIXUP

    abs_jmp_hack 0x42d66e

continue_cave: ; 0x42e5a5
    cmp    dword [CURRENT_STAGE], 0x7
    je     .retry
    jmp    .continue

.retry:
    ; original code
    xor     edx, edx
    cmp     dword [ebp+0x1f4], eax
    abs_jmp_hack 0x42e5ad

.continue:
    push   ebp ; PauseMenu*
    call   do_continue ; FIXUP
    ; original code, skipping stuff related to restarting stage
    pop    edi
    pop    esi
    pop    ebx
    pop    ebp
    abs_jmp_hack 0x42e5c1

; void __stdcall DoContinue(PauseMenu*)
do_continue:
    prologue_sd

    mov    dword [CURRENT_LIVES], 2
    mov    dword [CURRENT_LIFE_FRAGMENTS], 0

    push   dword [CURRENT_LIFE_FRAGMENTS]
    mov    edx, dword [CURRENT_LIVES]
    mov    edi, dword [GUI_PTR]
    mov    eax, FUNC_GUI_UPDATE_LIVES
    call   eax

    mov    dword [CURRENT_SCORE], 0x0

    ; In SA you spawn so many power items on death (often including an F) that
    ; we won't even worry about power.

    mov    eax, dword [MAXIMUM_POWER]
    mov    ecx, FUNC_COLLECT_POWER
    call   ecx
    
    mov    ebx, dword [PLAYER_PTR]
    mov    eax, FUNC_PLAYER_REGEN_OPTIONS
    call   eax

    mov    ecx, dword [CONTINUES_USED]
    inc    ecx
    mov    edx, 0x9
    cmp    ecx, edx
    cmovg  ecx, edx
    mov    dword [CONTINUES_USED], ecx

    ; fix state so that Esc works
    mov    esi, dword [ebp+0x8]
    mov    dword [esi+pmenu_state], 0

    mov    esi, dword [ebp+0x8] ; PauseMenu*
    mov    eax, FUNC_DO_UNPAUSE
    call   eax

    epilogue_sd
    ret    0x4

; void __stdcall PauseBgm()
pause_bgm:
    prologue_sd

    push    0
    push    6
    mov     edi, CSTR_BGM_PAUSE  ; "Pause"
    mov     eax, SOUND_MANAGER_START
    mov     ecx, FUNC_MODIFY_BGM
    call    ecx

    epilogue_sd
    ret
