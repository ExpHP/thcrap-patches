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

%define CURRENT_LIVES     0x4b0c98
%define CURRENT_LIFE_FRAGMENTS  0x4b0c9c
%define CURRENT_BOMBS     0x4b0ca0
%define CURRENT_BOMB_FRAGMENTS  0x4b0ca4
%define POWER_PER_LEVEL   0x4b0cd4
%define CURRENT_SCORE     0x4b0c44
%define CURRENT_POWER     0x4b0c48
%define CURRENT_STAGE     0x4b0cb0
%define MAXIMUM_POWER     0x4b0cd0
%define CONTINUES_USED    0x4b0cc4

%define FUNC_GUI_UPDATE_LIVES  0x41ce60
%define FUNC_GUI_UPDATE_BOMBS  0x41cf40
%define FUNC_DO_UNPAUSE        0x432960
%define FUNC_PLAYER_REGEN_OPTIONS  0x4385b0
%define FUNC_MODIFY_BGM         0x454960
%define FUNC_COLLECT_BIG_POWER  0x422d70

%define PLAYER_PTR   0x4b4514
%define GUI_PTR      0x4b43e4
%define SOUND_MANAGER_START    0x4cf4e8
%define GLOBALS_START          0x4b0c40

%define CSTR_BGM_PAUSE 0x4a1044

%define pmenu_state  0x4

bgm_pause_cave: ; 0x4337f4
    call pause_bgm ; FIXUP
    abs_jmp_hack 0x43382c

continue_cave: ; 0x4347e5
    cmp    dword [CURRENT_STAGE], 0x7
    je     .retry
    jmp    .continue

.retry:
    ; original code
    xor     eax, eax
    cmp     dword [ebp+0x1f4], eax
    abs_jmp_hack 0x4347ed

.continue:
    push   ebp ; PauseMenu*
    call   do_continue ; FIXUP
    ; original code, skipping stuff related to restarting stage
    pop    edi
    pop    esi
    pop    ebx
    pop    ebp
    abs_jmp_hack 0x434800

; void __stdcall DoContinue(PauseMenu*)
do_continue:
    prologue_sd

    mov    dword [CURRENT_LIVES], 2
    mov    dword [CURRENT_BOMBS], 2
    mov    dword [CURRENT_LIFE_FRAGMENTS], 0
    mov    dword [CURRENT_BOMB_FRAGMENTS], 0

    push   dword [CURRENT_LIFE_FRAGMENTS]
    push   dword [CURRENT_LIVES]
    push   dword [GUI_PTR]
    mov    eax, FUNC_GUI_UPDATE_LIVES
    call   eax

    push   dword [CURRENT_BOMB_FRAGMENTS]
    push   dword [CURRENT_BOMBS]
    push   dword [GUI_PTR]
    mov    eax, FUNC_GUI_UPDATE_BOMBS
    call   eax

    mov    dword [CURRENT_SCORE], 0x0
    mov    dword [CURRENT_POWER], 0x0

    mov    ebx, dword [MAXIMUM_POWER]
    mov    eax, GLOBALS_START
    mov    ecx, FUNC_COLLECT_BIG_POWER
    call   ecx
    
    push   dword [PLAYER_PTR]
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
