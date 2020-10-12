; AUTO_PREFIX: ExpHP.auto-release.

%include "util.asm"

%define HARDWARE_INPUT_16 0x4a50b0
%define HARDWARE_INPUT_PREV_16 0x4a50b4
%define BULLET_MANAGER_PTR_16 0x4a6dac
%define ENEMY_MANAGER_PTR_16 0x4a6dc0
%define LASER_MANAGER_PTR_16 0x4a6ee0
%define PAUSE_MENU_PTR_16 0x4a6ef4
%define PLAYER_PTR_16 0x4a6ef8
%define GUI_PTR_16 0x4a6dcc

%define PAUSE_IS_PAUSED_16 0x1ec
%define PLAYER_POS 0x610
%define PLAYER_IFRAMES 0x610 + 0x1602c
%define BULLET_POS 0xc20
%define EFULL_POS 0x120c + 0x44
%define EFULL_HURTBOX 0x120c + 0x110
%define GUI_IS_DIALOGUE 0x1c8

%define BMGR_TICK_LIST_HEAD_16 0x70
%define LMGR_TICK_LIST_HEAD_16 0x10
%define EMGR_TICK_LIST_HEAD_16 0x180

%define LIST_ENTRY 0x0
%define LIST_NEXT 0x4

; 0x402118  (e863340000)
binhack:  ; HEADER: AUTO
    call autorelease  ; REWRITE: [codecave:AUTO]

    ; original code
    mov  ecx, 0x4a50b0
    mov  eax, 0x405580
    call eax
    abs_jmp_hack 0x40211d

autorelease:  ; HEADER: AUTO
    call is_game_running  ; REWRITE: [codecave:AUTO]
    test eax, eax
    jz   .end
    ; flip ctrl state
    ; mov  eax, [HARDWARE_INPUT_PREV_16]
    ; and  eax, 0x200
    ; xor  eax, 0x200
    ; or   dword [HARDWARE_INPUT_16], eax
    ; or   dword [HARDWARE_INPUT_16], 0x1

    call is_player_in_danger  ; REWRITE: [codecave:AUTO]
    test eax, eax
    jnz  .mash_release
    call is_dialogue  ; REWRITE: [codecave:AUTO]
    test eax, eax
    jnz  .hold_release
    jmp  .norelease
.mash_release:
    mov  eax, [HARDWARE_INPUT_PREV_16]
    and  eax, 0xa00
    xor  eax, 0xa00
    or   dword [HARDWARE_INPUT_16], eax
    jmp  .end
.hold_release:  ; skipping dialogue only works when held for at least several frames
    or   dword [HARDWARE_INPUT_16], 0xa00
.norelease:
.end:
    ret

is_game_running:  ; HEADER: AUTO
    mov  eax, [PAUSE_MENU_PTR_16]
    test eax, eax
    jz   .notrunning

    mov  eax, [eax + PAUSE_IS_PAUSED_16]
    test eax, eax
    jnz  .notrunning

    mov  eax, [PLAYER_PTR_16]
    test eax, eax
    jz   .notrunning
.running:
    mov  eax, 1
    ret
.notrunning:
    xor  eax, eax
    ret

is_dialogue:  ; HEADER: AUTO
    mov  eax, [GUI_PTR_16]
    test eax, eax
    jz   .nope
    mov  eax, [eax + GUI_IS_DIALOGUE]
    test eax, eax
    jz   .nope
.yep:
    mov  eax, 1
    ret
.nope:
    xor  eax, eax
    ret

is_player_in_danger:  ; HEADER: AUTO
    %push
    prologue_sd 0x08
    %define %$player_pos ebp-0x08
    mov  ecx, [PLAYER_PTR_16]
    test ecx, ecx
    jz   .nodanger

    mov  eax, [ecx + PLAYER_IFRAMES]
    cmp  eax, 2
    jg   .nodanger

    mov  eax, [ecx + PLAYER_POS + 0x0]
    mov  [%$player_pos + 0x0], eax
    mov  eax, [ecx + PLAYER_POS + 0x4]
    mov  [%$player_pos + 0x4], eax

    push dword [%$player_pos + 0x04]
    push dword [%$player_pos + 0x00]
    call is_bullet_near_pos  ; REWRITE: [codecave:AUTO]
    jmp .done

.nodanger:
    xor  eax, eax
.done:
    epilogue_sd
    ret
    %pop

is_bullet_near_pos:  ; HEADER: AUTO
    %push
    prologue_sd
    %define %$player_pos ebp+0x08
    mov  ecx, [BULLET_MANAGER_PTR_16]
    test ecx, ecx
    jz   .nodanger

    mov  ecx, [ecx + BMGR_TICK_LIST_HEAD_16]
.iter:
    test ecx, ecx
    jz   .nodanger
    mov  edx, [ecx]  ; bullet
    push __float32__(16.0)
    push dword [edx + BULLET_POS + 0x4]
    push dword [edx + BULLET_POS + 0x0]
    push dword [%$player_pos + 0x4]
    push dword [%$player_pos + 0x0]
    call are_points_within  ; REWRITE: [codecave:AUTO]
    test eax, eax
    jnz  .danger
    mov  ecx, [ecx + 0x4]
    jmp  .iter
.nodanger:
    xor  eax, eax
    jmp  .end
.danger:
    mov  eax, 0x1
.end:
    epilogue_sd
    ret  0x08
    %pop

are_points_within:  ; HEADER: AUTO
    movss xmm0, [esp+0x04]
    subss xmm0, [esp+0x0c]
    movss xmm1, [esp+0x08]
    subss xmm1, [esp+0x10]
    mulss xmm0, xmm0
    mulss xmm1, xmm1
    addss xmm0, xmm1
    movss xmm1, [esp+0x14]
    mulss xmm1, xmm1
    xor   eax, eax
    comiss xmm0, xmm1
    setb  al
    ret  0x14

;     local bmgr = readInteger(BULLET_MANAGER_16)
;     if bmgr == 0 then return false end
;     local emgr = readInteger(ENEMY_MANAGER_16)
;     if emgr == 0 then return false end
;     local player = readInteger(PLAYER_PTR_16)

;     local node = readInteger(bmgr + BMGR_TICK_LIST_HEAD_16)
;     while node ~= 0 do
;         local bullet, next = read_two_ints(node + LIST_ENTRY)
;         local bullet_pos = read_vec2(bullet + BULLET_POS)
;         if vec2_distance(player_pos, bullet_pos) < 16 then return true end
;         node = next
;     end

;     node = readInteger(emgr + EMGR_TICK_LIST_HEAD_16)
;     while node ~= 0 do
;         local efull, next = read_two_ints(node + LIST_ENTRY)
;         local efull_pos = read_vec2(efull + EFULL_POS)
;         local hurtbox = readFloat(efull + EFULL_HURTBOX)
;         if vec2_distance(player_pos, efull_pos) < 16 + hurtbox * 0.5 then return true end
;         node = next
;     end
;     return false
; end

; function vec2_distance(a, b)
;     local x = a[1] - b[1]
;     local y = a[2] - b[2]
;     return math.sqrt(x*x + y*y)
; end

; function read_vec2_1(address)
;     return {readFloat(address), readFloat(address+0x4)}
; end

; function read_vec2_2(address)
;     x1, x2, x3, x4, y1, y2, y3, y4 = readBytes(address, 8)
;     return {byteTableToFloat({x1, x2, x3, x4}), byteTableToFloat({y1, y2, y3, y4})}
; end

; function read_two_ints(address)
;     x1, x2, x3, x4, y1, y2, y3, y4 = readBytes(address, 8)
;     return byteTableToDword({x1, x2, x3, x4}), byteTableToDword({y1, y2, y3, y4})
; end

; read_vec2 = read_vec2_2
