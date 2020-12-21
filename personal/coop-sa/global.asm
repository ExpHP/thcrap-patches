; AUTO_PREFIX: ExpHP.coop-sa.

%include "util.asm"
%define IAT_GetKeyboardState  0x48b244
%define MAX_PLAYERS 4
%define KEYS_PER_PLAYER 5

data:  ; HEADER: AUTO
    .keyboard:
        ; 256 bytes
        dq 0, 0, 0, 0, 0, 0, 0, 0
        dq 0, 0, 0, 0, 0, 0, 0, 0
        dq 0, 0, 0, 0, 0, 0, 0, 0
        dq 0, 0, 0, 0, 0, 0, 0, 0
    .target_vec2s: dq 0, 0, 0, 0  ; (4+4) * 4 bytes
    .angles: dd 0, 0, 0, 0
    .is_shooting: dd 0, 0, 0, 0
    .player_keys:
        db 'W', 'A', 'S', 'D', 'X'
        db '4', 'E', 'R', 'T', 'F'
        db 'Y', 'G', 'H', 'J', 'N'
        db '8', 'U', 'I', 'O', 'K'

strings:  ; HEADER: AUTO
    .user32: dw 'u', 's', 'e', 'r', '3', '2', 0
    .GetKeyboardState: db "GetKeyboardState", 0

update_keyboard:  ; HEADER: AUTO
    func_begin
    func_local %$player, %$const_1f
    func_prologue edi, esi, ebx
    %define %$reg_keyboard edi
    %define %$reg_keys esi
    %define %$reg_vec2 ebx

    mov  %$reg_keyboard, data  ; REWRITE: <codecave:AUTO>
    add  %$reg_keyboard, data.keyboard - data
    push %$reg_keyboard
    call [IAT_GetKeyboardState]

    mov  dword [%$const_1f], __float32__(1.0)

    mov  %$reg_vec2, data  ; REWRITE: <codecave:AUTO>
    add  %$reg_vec2, data.target_vec2s - data
    mov  %$reg_keys, data  ; REWRITE: <codecave:AUTO>
    add  %$reg_keys, data.player_keys - data
    mov  dword [%$player], 0
.loop:
    cmp  dword [%$player], MAX_PLAYERS
    jge  .done

    xorps xmm0, xmm0
    xorps xmm1, xmm1

    movzx eax, byte [%$reg_keys+0x0]
    movzx eax, byte [%$reg_keyboard + eax]
    and   eax, 0x80
    jz .noup
    subss xmm1, dword [%$const_1f]
.noup:

    movzx eax, byte [%$reg_keys+0x1]
    movzx eax, byte [%$reg_keyboard + eax]
    and   eax, 0x80
    jz .noleft
    subss xmm0, dword [%$const_1f]
.noleft:

    movzx eax, byte [%$reg_keys+0x2]
    movzx eax, byte [%$reg_keyboard + eax]
    and   eax, 0x80
    jz .nodown
    addss xmm1, dword [%$const_1f]
.nodown:

    movzx eax, byte [%$reg_keys+0x3]
    movzx eax, byte [%$reg_keyboard + eax]
    and   eax, 0x80
    jz .noright
    addss xmm0, dword [%$const_1f]
.noright:

    ; movzx eax, byte [%$reg_keys+0x4]
    ; movzx eax, byte [%$reg_keyboard + eax]
    ; shr   eax, 7
    ; mov   ecx, data  ; REWRITE: <codecave:AUTO>
    ; add   ecx, data.is_shooting - data
    ; mov   edx, [%$player]
    ; mov   [ecx + 4*edx], eax

    movss dword [%$reg_vec2+0x0], xmm0
    movss dword [%$reg_vec2+0x4], xmm1

    add  %$reg_keys, KEYS_PER_PLAYER
    add  %$reg_vec2, 8
    inc  dword [%$player]
    jmp  .loop
.done:

    func_epilogue
    func_ret
    func_end

# int GetOptionPlayerNumber(int option)
get_option_player_number:  ; HEADER: AUTO
    func_begin
    func_arg  %$option
    func_prologue

    ; assign options to extra players round-robin
    mov  eax, [%$option]
    xor  edx, edx
    mov  ecx, 0  ; REWRITE: <option:coop-sa.num-extra-players>
    idiv ecx
    mov  eax, edx

    func_epilogue
    func_ret
    func_end

# float* GetOptionAnglePtr(int option)
get_option_angle_ptr:  ; HEADER: AUTO
    func_begin
    func_arg  %$option
    func_prologue

    push dword [%$option]
    call get_option_player_number  ; REWRITE: [codecave:AUTO]
    mov  ecx, data  ; REWRITE: <codecave:AUTO>
    add  ecx, data.angles - data
    lea  eax, [ecx + 4*eax]

    func_epilogue
    func_ret
    func_end

# int GetOptionAnmScript(int option)
get_option_anm:  ; HEADER: AUTO
    func_begin
    func_arg  %$option
    func_prologue

    push dword [%$option]
    call get_option_player_number  ; REWRITE: [codecave:AUTO]
    mov  edx, eax
    mov  eax, 25
    sub  eax, edx

    func_epilogue
    func_ret
    func_end

# void GetOptionAttemptedMotion(int option, float* out)
get_option_attempted_motion:  ; HEADER: AUTO
    func_begin
    func_arg  %$option, %$out
    func_prologue edi, esi

    push dword [%$option]
    call get_option_player_number  ; REWRITE: [codecave:AUTO]

    mov  esi, data  ; REWRITE: <codecave:AUTO>
    add  esi, data.target_vec2s - data
    lea  esi, [esi + 8*eax]
    mov  edi, [%$out]

    mov  eax, dword [esi+0x0]
    mov  dword [edi+0x0], eax
    mov  eax, dword [esi+0x4]
    mov  dword [edi+0x4], eax

    func_epilogue
    func_ret
    func_end
