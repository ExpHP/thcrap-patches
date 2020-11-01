; AUTO_PREFIX: ExpHP.sprite-death-fix.

%include "util.asm"

; ============================================
; Game data codecave

struc Data
    .anm_manager_ptr: resd 1
    .flush_sprites_abi: resd 1
    .flush_sprites: resd 1
    .buffer_offset: resd 1
    .cursor_offset: resd 1
endstruc

data:  ; HEADER: AUTO
    dd 0 ; replace with conditionals for things below

; TH06 has no batching, making it the only game that doesn't require fixing.  Hooray!

data_07:  ; HEADER: AUTO
istruc Data  ; DELETE
    at Data.anm_manager_ptr, dd 0x4b9e44
    at Data.flush_sprites_abi, dd wrapper_thiscall  ; REWRITE: <codecave:AUTO>
    at Data.flush_sprites, dd  0x44f5c0
    at Data.buffer_offset, dd 0x2e534
    at Data.cursor_offset, dd 0x17e534
iend  ; DELETE

data_08:  ; HEADER: AUTO
istruc Data  ; DELETE
    at Data.anm_manager_ptr, dd 0x18bdc90
    at Data.flush_sprites_abi, dd wrapper_thiscall  ; REWRITE: <codecave:AUTO>
    at Data.flush_sprites, dd  0x462e40
    at Data.buffer_offset, dd 0x2524
    at Data.cursor_offset, dd 0x2a2524
iend  ; DELETE

data_09:  ; HEADER: AUTO
istruc Data  ; DELETE
    at Data.anm_manager_ptr, dd 0x4dc550
    at Data.flush_sprites_abi, dd wrapper_thiscall  ; REWRITE: <codecave:AUTO>
    at Data.flush_sprites, dd  0x4396a0
    at Data.buffer_offset, dd 0x128e8
    at Data.cursor_offset, dd 0x2b28e8
iend  ; DELETE

data_095:  ; HEADER: AUTO
istruc Data  ; DELETE
    at Data.anm_manager_ptr, dd 0x4ca1b8
    at Data.flush_sprites_abi, dd wrapper_thiscall  ; REWRITE: <codecave:AUTO>
    at Data.flush_sprites, dd  0x43f2f0
    at Data.buffer_offset, dd 0x17c8
    at Data.cursor_offset, dd 0x3817c8
iend  ; DELETE

data_10:  ; HEADER: AUTO
istruc Data  ; DELETE
    at Data.anm_manager_ptr, dd 0x491c10
    at Data.flush_sprites_abi, dd wrapper_esi  ; REWRITE: <codecave:AUTO>
    at Data.flush_sprites, dd 0x442f50
    at Data.buffer_offset, dd 0x3adacc
    at Data.cursor_offset, dd 0x72dacc
iend  ; DELETE

data_11:  ; HEADER: AUTO
istruc Data  ; DELETE
    at Data.anm_manager_ptr, dd 0x4c3268
    at Data.flush_sprites_abi, dd wrapper_esi  ; REWRITE: <codecave:AUTO>
    at Data.flush_sprites, dd  0x44fd10
    at Data.buffer_offset, dd 0x435624
    at Data.cursor_offset, dd 0x7b5624
iend  ; DELETE

data_12:  ; HEADER: AUTO
istruc Data  ; DELETE
    at Data.anm_manager_ptr, dd 0x4ce8cc
    at Data.flush_sprites_abi, dd wrapper_esi  ; REWRITE: <codecave:AUTO>
    at Data.flush_sprites, dd 0x45a3c0
    at Data.buffer_offset, dd 0x4b56a4
    at Data.cursor_offset, dd 0x8356a4
iend  ; DELETE

data_125:  ; HEADER: AUTO
istruc Data  ; DELETE
    at Data.anm_manager_ptr, dd 0x4d0cb4
    at Data.flush_sprites_abi, dd wrapper_esi  ; REWRITE: <codecave:AUTO>
    at Data.flush_sprites, dd 0x458ed0
    at Data.buffer_offset, dd 0x4bd6ac
    at Data.cursor_offset, dd 0x83d6ac
iend  ; DELETE

data_128:  ; HEADER: AUTO
istruc Data  ; DELETE
    at Data.anm_manager_ptr, dd 0x4d2e50
    at Data.flush_sprites_abi, dd wrapper_esi  ; REWRITE: <codecave:AUTO>
    at Data.flush_sprites, dd 0x45ef60
    at Data.buffer_offset, dd 0x4e96f0
    at Data.cursor_offset, dd 0x8696f0
iend  ; DELETE

data_13:  ; HEADER: AUTO
istruc Data  ; DELETE
    at Data.anm_manager_ptr, dd 0x4dc688
    at Data.flush_sprites_abi, dd wrapper_esi  ; REWRITE: <codecave:AUTO>
    at Data.flush_sprites, dd 0x4679a0
    at Data.buffer_offset, dd 0xb781f4
    at Data.cursor_offset, dd 0xef81f4
iend  ; DELETE

data_14:  ; HEADER: AUTO
istruc Data  ; DELETE
    at Data.anm_manager_ptr, dd 0x4f56cc
    at Data.flush_sprites_abi, dd wrapper_thiscall  ; REWRITE: <codecave:AUTO>
    at Data.flush_sprites, dd 0x475eb0
    at Data.buffer_offset, dd 0xbc81f4
    at Data.cursor_offset, dd 0xf481f4
iend  ; DELETE

data_143:  ; HEADER: AUTO
istruc Data  ; DELETE
    at Data.anm_manager_ptr, dd 0x538de8
    at Data.flush_sprites_abi, dd wrapper_thiscall  ; REWRITE: <codecave:AUTO>
    at Data.flush_sprites, dd 0x47a8c0
    at Data.buffer_offset, dd 0xbc8204
    at Data.cursor_offset, dd 0xf48204
iend  ; DELETE

data_15:  ; HEADER: AUTO
istruc Data  ; DELETE
    at Data.anm_manager_ptr, dd 0x503c18
    at Data.flush_sprites_abi, dd wrapper_thiscall  ; REWRITE: <codecave:AUTO>
    at Data.flush_sprites, dd 0x47e3f0
    at Data.buffer_offset, dd 0x187fc0c
    at Data.cursor_offset, dd 0x1bffc0c
iend  ; DELETE

data_16:  ; HEADER: AUTO
istruc Data  ; DELETE
    at Data.anm_manager_ptr, dd 0x4c0f48
    at Data.flush_sprites_abi, dd wrapper_thiscall  ; REWRITE: <codecave:AUTO>
    at Data.flush_sprites, dd 0x465a80
    at Data.buffer_offset, dd 0x184fc1c
    at Data.cursor_offset, dd 0x1bcfc1c
iend  ; DELETE

data_165:  ; HEADER: AUTO
istruc Data  ; DELETE
    at Data.anm_manager_ptr, dd 0x4ed88c
    at Data.flush_sprites_abi, dd wrapper_thiscall  ; REWRITE: <codecave:AUTO>
    at Data.flush_sprites, dd 0x46beb0
    at Data.buffer_offset, dd 0x184fc20
    at Data.cursor_offset, dd 0x1bcfc20
iend  ; DELETE

data_17:  ; HEADER: AUTO
istruc Data  ; DELETE
    at Data.anm_manager_ptr, dd 0x509a20
    at Data.flush_sprites_abi, dd wrapper_thiscall  ; REWRITE: <codecave:AUTO>
    at Data.flush_sprites, dd 0x46d0a0
    at Data.buffer_offset, dd 0x1860830
    at Data.cursor_offset, dd 0x1be0830
iend  ; DELETE

; ============================================
; Binhacks

; TH07:  0x44f699  (8b75088b45fc)
; TH08:  0x462f19  (8b75088b45fc)
; TH095: 0x43f3c9  (8b75088b45fc)
binhack_08:  ; HEADER: AUTO
    call fix  ; REWRITE: [codecave:AUTO]
    ; original code
    mov  esi, dword [ebp+0x8]
    mov  eax, dword [ebp-0x4]
    ret

; y u gotta be special, PoFV?
; TH09:  0x439733  (8b55088bc1)
binhack_09:  ; HEADER: AUTO
    push ecx  ; save
    call fix  ; REWRITE: [codecave:AUTO]
    pop  ecx  ; restore
    ; original code
    mov  edx, dword [ebp+0x8]
    mov  eax, ecx
    ret

; In DDC and beyond, we replace the line with the `lea` that checks how far the
; sprite will write, and jump to the successful branch at the end.
;
; TH14:  0x475f90 (8d87a8000000)
; TH143: 0x47a9a0 (8d87a8000000)
; TH15:  0x47e4d0 (8d87a8000000)
; TH16:  0x465b60 (8d87a8000000)
; TH165: 0x46bf90 (8d87a8000000)
; TH17:  0x46d180 (8d87a8000000)
binhack_modern:  ; HEADER: AUTO
    call fix  ; REWRITE: [codecave:AUTO]
    mov  edi, [esi]
    abs_jmp_hack 0x475fa6  ; TH14
    abs_jmp_hack 0x47a9b6  ; TH143
    abs_jmp_hack 0x47e4e6  ; TH15
    abs_jmp_hack 0x465b76  ; TH16
    abs_jmp_hack 0x46bfa6  ; TH165
    abs_jmp_hack 0x46d196  ; TH17

; Astonishingly, AnmManager::write_sprite has the exact same ABI in all
; six of the "bizarre ABI era" games, which almost never happens.
; We use this to write a single binhack for all six.
;
; It takes AnmManager in eax and an argument in edx.
; We replace an instruction that moves the write cursor into edi.
;
; TH10:  0x442fe4  (8bb8ccda7200)
; TH11:  0x44fda4  (8bb824567b00)
; TH12:  0x45a4a4  (8bb8a4568300)
; TH125: 0x458fb4  (8bb8acd68300)
; TH128: 0x45f043  (8bb8f0968600)
; TH13:  0x467a83  (8bb8f481ef00)
binhack_ugly_abi_games:  ; HEADER: AUTO
    push edx  ; save arg
    call fix  ; REWRITE: [codecave:AUTO]

    ; need anm manager in eax, write cursor in edi, arg in edx
    mov  edx, data  ; REWRITE: <codecave:AUTO>
    mov  eax, [edx+Data.anm_manager_ptr]
    mov  eax, [eax]
    mov  edi, dword [edx+Data.cursor_offset]
    mov  edi, [eax+edi]
    pop  edx
    ret

; ============================================
; Callable caves

; Calls a 1-arg function with 'thiscall' convention.
; __stdcall WrapperThiscall(func, arg)
wrapper_thiscall:  ; HEADER: AUTO
    prologue_sd
    mov  ecx, [ebp+0x0c]
    call [ebp+0x8]
    epilogue_sd
    ret 0x8

; Calls a function that takes an arg in esi.
; __stdcall WrapperEsi(func, arg)
wrapper_esi:  ; HEADER: AUTO
    prologue_sd
    mov  esi, [ebp+0x0c]
    call [ebp+0x8]
    epilogue_sd
    ret 0x8

; __stdcall Fix()
fix:  ; HEADER: AUTO
    prologue_sd
    mov  edi, data  ; REWRITE: <codecave:AUTO>
    mov  esi, [edi+Data.anm_manager_ptr]
    mov  esi, [esi]

    ; Check if there is enough room for one more sprite.
    mov  eax, [edi+Data.cursor_offset]
    lea  ecx, [esi+eax]  ; location of write ptr is also end of array
    mov  eax, [ecx]  ; write ptr
    lea  eax, [eax+0xa8]  ; amount of data written for one sprite
    cmp  eax, ecx  ; compare to end of array
    jl   .noreset

    ; Not enough room? Flush anything not yet drawn...
    push esi
    push dword [edi+Data.flush_sprites]
    call [edi+Data.flush_sprites_abi]

    ; ...and go back to the beginning of the buffer.
    mov  eax, [edi+Data.buffer_offset]
    lea  eax, [esi+eax]
    mov  ecx, [edi+Data.cursor_offset]
    mov  [esi+ecx+0x0], eax  ; write cursor
    mov  [esi+ecx+0x4], eax  ; read cursor

.noreset:
    epilogue_sd
    ret

