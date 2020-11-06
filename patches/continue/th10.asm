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

%define CURRENT_LIVES     0x474c70
%define CURRENT_SCORE     0x474c44
%define CURRENT_POWER     0x474c48
%define CURRENT_STAGE     0x474c7c
%define CONTINUES_USED    0x474c90

%define FUNC_GUI_UPDATE_LIVES      0x413790
%define FUNC_DO_UNPAUSE            0x422c30
%define FUNC_PLAYER_REGEN_OPTIONS  0x426f70
%define FUNC_MODIFY_BGM            0x43e460
%define FUNC_INC_CONTINUES_USED    0x418a90

%define PLAYER_PTR   0x477834
%define GUI_PTR      0x47770c
%define SOUND_MANAGER_START    0x492590
%define GLOBALS_START          0x474c40

%define CSTR_BGM_PAUSE 0x46e0c0

%define pmenu_state  0x4

bgm_pause_cave: ; 0x4232f8
    ; a line of important ANM code embedded in the block we're skipping
    mov     dword [edi+0x1d4], eax

    call pause_bgm ; FIXUP

    ; cleanup that's awkwardly embedded in the block we're skipping
    pop    esi
    pop    ebp
    pop    ebx
    abs_jmp_hack 0x42333c

continue_cave: ; 0x424360
    cmp    dword [CURRENT_STAGE], 0x7
    je     .retry
    jmp    .continue

.retry:
    ; original code
    mov    edx, dword [ebp+0x1e4]
    abs_jmp_hack 0x424366

.continue:
    push   ebp ; PauseMenu*
    call   do_continue ; FIXUP
    abs_jmp_hack 0x424376

; void __stdcall DoContinue(PauseMenu*)
do_continue:
    prologue_sd

    mov    dword [CURRENT_LIVES], 2

    mov    ecx, dword [CURRENT_LIVES]
    mov    eax, dword [GUI_PTR]
    mov    edx, FUNC_GUI_UPDATE_LIVES
    call   edx

    mov    dword [CURRENT_SCORE], 0

    ; don't even bother messing with power in MoF since power is so
    ; easy to get back (and I'm, uh, not sure how to update the GUI...)

    push   dword [PLAYER_PTR]
    mov    eax, FUNC_PLAYER_REGEN_OPTIONS
    call   eax

    mov    eax, GLOBALS_START
    mov    ecx, FUNC_INC_CONTINUES_USED
    call   ecx

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
    mov     edx, CSTR_BGM_PAUSE  ; "Pause"
    mov     eax, SOUND_MANAGER_START
    mov     ecx, FUNC_MODIFY_BGM
    call    ecx

    epilogue_sd
    ret
