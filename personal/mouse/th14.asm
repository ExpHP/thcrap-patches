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

%define WINDOW             0x4f5a18
%define SUPERVISOR         0x4d8f60
%define SV_PRESENT_PARAMS  0xf4
%define D3DPP_HEIGHT       0x4

%define SUBPIXELS_PER_PIXEL 128
%define GAME_ORIGIN_X 192
%define GAME_ORIGIN_Y 0

%define PL_POS_SUBPIXEL 0x5ec

%define IAT_GetModuleHandleW  0x4b1138
%define IAT_GetProcAddress    0x4b10f8

struc ResData
    .scale: resd 1
    .rect: resd 4
endstruc

struc Rect
    .left: resd 1
    .top: resd 1
    .right: resd 1
    .bottom: resd 1
endstruc

struc Data
    .ScreenToClient: resd 1
    .GetCursorPos: resd 1
endstruc

data:  ; HEADER: ExpHP.mouse.data
    .ScreenToClient: dd 0  ; function pointer
    .GetCursorPos: dd 0  ; function pointer

strings:  ; HEADER: ExpHP.mouse.strings
    .user32: dw 'u', 's', 'e', 'r', '3', '2', 0
    .GetCursorPos: db "GetCursorPos", 0
    .ScreenToClient: db "ScreenToClient", 0

res_data:  ; HEADER: ExpHP.mouse.res-data
    dd 1.0, 32, 16, 384+32, 448+16
    dd 1.5, 48, 24, 576+48, 672+24
    dd 2.0, 64, 32, 768+64, 896+32

cave: ; 0x44d7a8
    push esi ; save

    lea  esi, [edi+PL_POS_SUBPIXEL]
    push esi
    call get_mouse_pos_subpixels ; REWRITE: [codecave:ExpHP.mouse.get-mouse-pos-subpixels]

    ; clipping code needs data in these registers
    mov  edx, [esi+0x0] ; new x
    mov  ecx, [esi+0x4] ; new y

    pop  esi ; restore

    ; original code
    cmp  edx, 0xffffa400
    abs_jmp_hack 0x44d7ae

; Gets the position of the mouse, in the integer-with-subpixel format that the
; game uses internally for player position.
;
; void GetMousePosSubpixels(POINT*);
get_mouse_pos_subpixels:  ; HEADER: ExpHP.mouse.get-mouse-pos-subpixels
    prologue_sd
    push ebx

    call initialize ; REWRITE: [codecave:ExpHP.mouse.initialize]
    mov  ebx, data ; REWRITE: <codecave:ExpHP.mouse.data>

    ; lookup screen resolution.
    ; (in existing games I don't think this can change after startup, but this is
    ;  pretty cheap to do so might as well do it every frame)
    mov  esi, res_data  ; REWRITE: <codecave:ExpHP.mouse.res-data>
    call get_resolution_index  ; REWRITE: [codecave:ExpHP.mouse.get-resolution-index]
    imul eax, ResData_size
    add  esi, eax

    ; screen coords
    mov  edi, [ebp+0x8]
    push edi
    call [ebx + data.GetCursorPos - data]

    ; ...to client coords (no titlebar, etc.)
    push edi
    push dword [WINDOW]
    call [ebx + data.ScreenToClient - data]

    ; ; clip to arcade region
    ; push edi
    ; lea  eax, [esi + ResData.rect]
    ; push eax
    ; call clip_rect ; FIXUP: [codecave:ExpHP.mouse.clip-rect]
    
    ; make 0,0 the top left of the arcade region
    mov  eax, [esi + ResData.rect + Rect.left]
    sub  [edi+0x0], eax
    mov  eax, [esi + ResData.rect + Rect.top]
    sub  [edi+0x4], eax

    ; unscale
    cvtsi2ss xmm0, [edi+0x0]
    cvtsi2ss xmm1, [edi+0x4]
    movss  xmm2, [esi + ResData.scale]
    divss  xmm0, xmm2
    divss  xmm1, xmm2

    ; minus origin
    mov   eax, GAME_ORIGIN_X
    cvtsi2ss xmm2, eax
    subss xmm0, xmm2
    mov   eax, GAME_ORIGIN_Y
    cvtsi2ss xmm2, eax
    subss xmm1, xmm2

    ; subpixels
    mov   eax, SUBPIXELS_PER_PIXEL
    cvtsi2ss xmm2, eax
    mulss xmm0, xmm2
    mulss xmm1, xmm2
    cvtss2si eax, xmm0
    mov   [edi+0x0], eax
    cvtss2si eax, xmm1
    mov   [edi+0x4], eax

    pop ebx
    epilogue_sd
    ret 0x4

initialize: ; HEADER: ExpHP.mouse.initialize
    prologue_sd
    push ebx

    mov  esi, strings  ; REWRITE: <codecave:ExpHP.mouse.strings>
    mov  edi, data  ; REWRITE: <codecave:ExpHP.mouse.data>

    cmp  dword [edi + data.GetCursorPos - data], 0x0
    jne  .alreadyinit

    ; good thing x86 16-bit operations don't care about alignment...
    lea  eax, [esi + strings.user32 - strings]
    push eax
    call [IAT_GetModuleHandleW]
    mov  ebx, eax

    lea  eax, [esi + strings.GetCursorPos - strings]
    push eax
    push ebx
    call [IAT_GetProcAddress]
    mov  [edi + data.GetCursorPos - data], eax

    lea  eax, [esi + strings.ScreenToClient - strings]
    push eax
    push ebx
    call [IAT_GetProcAddress]
    mov  [edi + data.ScreenToClient - data], eax

.alreadyinit:
    pop ebx
    epilogue_sd
    ret

; int GetResolutionIndex();
; Get the index into res_data for the current game resolution
get_resolution_index:  ; ; HEADER: ExpHP.mouse.get-resolution-index
    mov eax, [SUPERVISOR + SV_PRESENT_PARAMS + D3DPP_HEIGHT]

    cmp eax, 480
    je  .res_0
    cmp eax, 720
    je  .res_1
    cmp eax, 960
    je  .res_2

.res_0:
    mov eax, 0
    ret
.res_1:
    mov eax, 1
    ret
.res_2:
    mov eax, 2
    ret


; ; Clip(INT Value, INT Min, INT Max)
; clip_int:
;     prologue_sd
;     mov   eax, [ebp+0x08]

;     mov   ecx, [ebp+0x0c]
;     cmp   eax, ecx
;     cmovl eax, ecx

;     mov   ecx, [ebp+0x10]
;     cmp   eax, ecx
;     cmovg eax, ecx
;     epilogue_sd
;     ret 0xc

; ; ClipPoint(POINT*, RECT*)
; clip_point:
;     prologue_sd
;     mov edi, [ebp+0x08] ; point
;     mov esi, [ebp+0x0c] ; rect

;     push dword [edi+0x0]
;     push dword [esi+Rect.left]
;     push dword [esi+Rect.right]
;     sub  dword [esp], 1 ; exclusive max
;     call clip_int ; FIXUP: [codecave:ExpHP.mouse.clip-int]
;     mov  [edi+0x0], eax

;     push dword [edi+0x4]
;     push dword [esi+Rect.top]
;     push dword [esi+Rect.bottom]
;     sub  dword [esp], 1 ; exclusive max
;     mov  [edi+0x4], eax
;     call clip_int ; FIXUP: [codecave:ExpHP.mouse.clip-int]

;     epilogue_sd
;     ret 0x8
