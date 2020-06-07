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

%define NUMGUIDE_SCRIPT_ID    0x2d
%define NUMGUIDE_LAYER        0x11

%define FUNC_ANM_ALLOC_VM     0x4621c0
%define FUNC_ANM_LOAD_SCRIPT  0x454d10
%define FUNC_ANM_APPEND_TO_WORLD_LIST  0x461250
%define FUNC_TIMER_INCREMENT  0x464a80

%define anmvm_layer  0x020
%define anmvm_pos    0x430
%define anmld_counter  0x130
%define bmgr_bullet_anm  0x4debdc
%define emgr_timer  0x50
%define timer_current  0x04

%define BULLET_MGR_PTR   0x4b43c8

%define PTR_DOUBLE_32  0x4a3d70
%define PTR_DOUBLE_192 0x4a3d28
%define PTR_DOUBLE_16  0x4a3d68

%define FLOAT_X0  0xc2c00000
%define FLOAT_X1  0x00000000
%define FLOAT_X2  0x42c00000

%define FLOAT_Y0  0x43500000
%define FLOAT_Y1  0x43980000
%define FLOAT_Y2  0x43c80000

%macro prologue_sd 0
    push ebp
    mov  ebp, esp
    push esi
    push edi
%endmacro

%macro epilogue_sd 0
    pop  edi
    pop  esi
    mov  esp, ebp
    pop  ebp
%endmacro

; workaround for [Rx] being broken  (side-effect-free absolute jump)
%macro  abs_jmp_hack 1
        call %%next
    %%next:
        mov dword [esp], %1
        ret
%endmacro

numguide_anm_cave: ; 0x4131e1
    cmp     dword [esi+timer_current], 0x8
    jne     .nocall
    call    make_all_numguide_anms ; FIXUP

.nocall:
    ; original code
    mov     eax, FUNC_TIMER_INCREMENT
    call    eax
    abs_jmp_hack 0x4131ed

# void __stdcall MakeAllNumguideAnms()
make_all_numguide_anms:
    prologue_sd

    push    FLOAT_X0
    call    make_all_numguide_anms_at_x ; FIXUP
    push    FLOAT_X1
    call    make_all_numguide_anms_at_x ; FIXUP
    push    FLOAT_X2
    call    make_all_numguide_anms_at_x ; FIXUP

    epilogue_sd
    ret

# void __stdcall MakeAllNumguideAnmsAtX(float)
make_all_numguide_anms_at_x:
    prologue_sd

    push   FLOAT_Y0
    push   dword [ebp+0x8]
    call   make_numguide_anm ; FIXUP
    push   FLOAT_Y1
    push   dword [ebp+0x8]
    call   make_numguide_anm ; FIXUP
    push   FLOAT_Y2
    push   dword [ebp+0x8]
    call   make_numguide_anm ; FIXUP

    epilogue_sd
    ret    0x4

; void __stdcall MakeNumguideAnm(float, float)
make_numguide_anm:
    prologue_sd

    mov    eax, dword [BULLET_MGR_PTR]
    mov    esi, dword [eax+bmgr_bullet_anm]
    inc    dword [esi+anmld_counter]

    mov    eax, FUNC_ANM_ALLOC_VM
    call   eax
    mov    edi, eax

    ; (adjust the position to account for the game world origin before writing)
    fld    dword [ebp+0x08]
    fadd   qword [PTR_DOUBLE_32]
    fadd   qword [PTR_DOUBLE_192]
    fstp   dword [edi+anmvm_pos+0x0]
    fld    dword [ebp+0x0c]
    fadd   qword [PTR_DOUBLE_16]
    fstp   dword [edi+anmvm_pos+0x4]
    xor    eax, eax
    mov    dword [edi+anmvm_pos+0x8], eax
    mov    dword [edi+anmvm_layer], NUMGUIDE_LAYER

    push   NUMGUIDE_SCRIPT_ID
    push   edi
    mov    ecx, esi
    mov    eax, FUNC_ANM_LOAD_SCRIPT
    call   eax

    ; args to this are:
    ;   - vm in ebx,
    ;   - output pointer for anm id in eax
    sub    esp, 0x4
    lea    eax, [esp]
    mov    ebx, edi
    mov    edi, FUNC_ANM_APPEND_TO_WORLD_LIST
    call   edi

    ; Don't bother saving the id anywhere; when BulletManager is destroyed, it
    ; signals the death of all anm VMs using bullet.anm, so "leaking" them is fine.

    epilogue_sd
    ret    0x8
