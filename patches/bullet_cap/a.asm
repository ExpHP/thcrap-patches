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

%define SECTION_TEXT_BEGIN  0x401000
%define SECTION_TEXT_END    0x48ae15

%define PAGE_EXECUTE_READWRITE 0x40
%define BULLET_STRUCT_SIZE    0x910
; not counting dummy bullet at end
%define ORIGINAL_BULLET_COUNT 0x7d0

; cave:  ; 0x465d3a
;     call initialize  ; REWRITE: [codecave:ExpHP.bullet-cap.initialize]

;     ; original code
;     mov  eax, 0x465c68
;     call eax
;     abs_jmp_hack 0x465d3f

iat_funcs:
.GetLastError: dd 0
.GetModuleHandleW: dd 0
.GetProcAddress: dd 0

cave:  ; 0x42a51e
    call initialize  ; REWRITE: [codecave:ExpHP.bullet-cap.initialize]

    ; original code
    mov   esi, 0x4c3a70
    abs_jmp_hack 0x42a523

; List of places where a little-endian dword 0x7d0 appears (=2000) that is *not*
; representing the bullet count.  There are actually very few.
bullet_count_blacklist:  ; HEADER: ExpHP.bullet-cap.bullet-count-blacklist
    dd 0x41c390
    dd 0x459053
    dd 0x46b808
    dd 0  ; blacklist end

; List of places where a little-endian dword 0x7d1 appears (=2001) that is unrelated to bullet count.
bullet_count_plusone_blacklist:  ; HEADER: ExpHP.bullet-cap.bullet-count-plusone-blacklist
    dd 0  ; blacklist end

offsets_to_adjust:  ; HEADER: ExpHP.bullet-cap.offsets-to-adjust
    dd 0x46d216  ; offset of dummy bullet state
    dd 0  ; blacklist end
    dd 0x46d674  ; offset of bullet.anm
    dd 0  ; blacklist end
    dd 0x46d678  ; size of bullet manager
    dd 0  ; blacklist end
    dd 0x46d610  ; size of bullet array
    dd 0  ; blacklist end
    dd 0  ; end

new_bullet_count:  ; HEADER: ExpHP.bullet-cap.new-bullet-count
    dd 10

; __stdcall Initialize()
initialize:  ; HEADER: ExpHP.bullet-cap.initialize
    %push
    prologue_sd

    sub  esp, 0x18
    %define %$new_count   ebp-0x04
    %define %$old_count   ebp-0x08
    %define %$offset_ptr  ebp-0x0c
    %define %$blacklist   ebp-0x10
    %define %$new_value   ebp-0x14
    %define %$old_value   ebp-0x18

    mov  eax, [new_bullet_count]  ; REWRITE: <codecave:ExpHP.bullet-cap.new-bullet-count>
    mov  dword [%$new_count], eax
    mov  dword [%$old_count], ORIGINAL_BULLET_COUNT

    ; Replace the integer 2000.
    push bullet_count_blacklist  ; REWRITE: <codecave:ExpHP.bullet-cap.bullet-count-blacklist>
    push 0x4  ; pattern_len
    lea  eax, [%$new_count]
    push eax  ; replacement
    lea  eax, [%$old_count]
    push eax  ; original
    push SECTION_TEXT_END
    push SECTION_TEXT_BEGIN
    call search_n_replace  ; REWRITE: [codecave:ExpHP.bullet-cap.search-n-replace]

    ; Replace the integer 2001.
    mov  eax, [%$new_count]
    mov  [%$new_value], eax
    mov  eax, [%$old_count]
    mov  [%$old_value], eax
    inc  dword [%$new_value]
    inc  dword [%$old_value]
    push bullet_count_plusone_blacklist  ; REWRITE: <codecave:ExpHP.bullet-cap.bullet-count-plusone-blacklist>
    push 0x4  ; pattern_len
    lea  eax, [%$new_value]
    push eax  ; replacement
    lea  eax, [%$old_value]
    push eax  ; original
    push SECTION_TEXT_END
    push SECTION_TEXT_BEGIN
    call search_n_replace  ; REWRITE: [codecave:ExpHP.bullet-cap.search-n-replace]

    ; Replace offsets into BulletManager that depend on bullet count.
    mov  eax, offsets_to_adjust  ; REWRITE: <codecave:ExpHP.bullet-cap.offsets-to-adjust>
    mov  [%$offset_ptr], eax
    add  eax, 4
    mov  [%$blacklist], eax

.iter:
    mov  eax, [%$offset_ptr]
    mov  eax, [eax]
    test eax, eax
    jz   .end  ; offset list ends with a zero

    push dword [%$blacklist]
    push eax
    push dword [%$new_count]
    call adjust_bullet_mgr_offset  ; REWRITE: [codecave:ExpHP.bullet-cap.adjust-bullet-mgr-offset]

    ; scan through blacklist to find next offset
    mov  ecx, [%$blacklist]
.blacklist_iter:
    mov  eax, [ecx]
    test eax, eax
    jz   .blacklist_end

    add  ecx, 0x4
    jmp  .blacklist_iter
.blacklist_end:
    add  ecx, 0x4
    mov  [%$offset_ptr], ecx
    add  ecx, 0x4
    mov  [%$blacklist], ecx
    jmp  .iter
.end:

    epilogue_sd
    ret
    %pop


; Search and replace all instances in .text of a given offset into BulletManager.
;
; __stdcall AdjustBulletManagerOffset(new_bullet_count, offset, blacklist*)
adjust_bullet_mgr_offset:  ; HEADER: ExpHP.bullet-cap.adjust-bullet-mgr-offset
    %push
    prologue_sd

    %define %$new_count   ebp+0x08
    %define %$old_offset  ebp+0x0c
    %define %$blacklist   ebp+0x10
    sub  esp, 0x4
    %define %$new_offset  ebp-0x04

    mov  eax, [%$new_count]
    sub  eax, ORIGINAL_BULLET_COUNT
    imul eax, BULLET_STRUCT_SIZE
    add  eax, [%$old_offset]
    mov  [%$new_offset], eax

    push dword [%$blacklist]
    push 0x4  ; pattern_len
    lea  eax, [%$new_offset]
    push eax  ; replacement
    lea  eax, [%$old_offset]
    push eax  ; original
    push SECTION_TEXT_END
    push SECTION_TEXT_BEGIN
    call search_n_replace  ; REWRITE: [codecave:ExpHP.bullet-cap.search-n-replace]

    epilogue_sd
    ret  0xc
    %pop


; SearchNReplace(start*, end*, pattern*, replacement*, pattern_len, blacklist*)
search_n_replace:  ; HEADER: ExpHP.bullet-cap.search-n-replace
    %push
    prologue_sd

    %define %$current   ebp+0x08
    %define %$end       ebp+0x0c
    %define %$pattern   ebp+0x10
    %define %$repl      ebp+0x14
    %define %$length    ebp+0x18
    %define %$blacklist ebp+0x1c

.searchiter:
    mov  eax, [%$current]
    add  eax, [%$length]
    cmp  eax, [%$end]
    jge  .searchend

    push dword [%$length]
    push dword [%$pattern]
    push dword [%$current]
    call mem_compare  ; REWRITE: [codecave:ExpHP.bullet-cap.mem-compare]
    test eax, eax
    jnz  .searchnext

    ; match found
    mov  eax, [%$current]
    mov  ecx, [%$blacklist]
    cmp  eax, [ecx]
    je   .blacklisted

    ; not blacklisted
    push dword [%$length]
    push dword [%$repl]
    push dword [%$current]
    call memcpy_or_bust  ; REWRITE: [codecave:ExpHP.bullet-cap.memcpy-or-bust]
    jmp  .searchnext

.blacklisted:
    ; since blacklist is in sorted order, start checking against the next entry
    add  dword [%$blacklist], 0x4

.searchnext:
    inc  dword [%$current]
    jmp  .searchiter

.searchend:
    ; make sure all blacklist entries matched; typos are too easy
    mov  eax, [%$blacklist]
    mov  eax, [eax]
    test eax, eax
    jz   .goodblacklist  ; at end of list?
    int 3
.goodblacklist:
    epilogue_sd
    ret 0x18
    %pop


; Returns 0 if data at `a` == data at `b`, nonzero otherwise.
; (sign of nonzero outputs is unspecified because I'm too lazy to verify whether it matches memcmp)
; __stdcall MemCompare(a*, b*, len)
mem_compare:  ; HEADER: ExpHP.bullet-cap.mem-compare
    prologue_sd
    mov  edi, [ebp+0x08]
    mov  esi, [ebp+0x0c]
    mov  ecx, [ebp+0x10]
    xor  eax, eax
    dec  esi
    dec  edi
.iter:
    inc  esi
    inc  edi
    dec  ecx
    js   .ret 
    mov  al, [esi]
    sub  al, [edi]
    jz   .iter
.ret:
    epilogue_sd
    ret  0xc

memcpy_or_bust:  ; HEADER: ExpHP.bullet-cap.memcpy-or-bust
    %push
    prologue_sd

    %define %$dest           ebp+0x08
    %define %$source         ebp+0x0c
    %define %$length         ebp+0x10
    sub esp, 0x8
    %define %$VirtualProtect ebp-0x04
    %define %$old_protect    ebp-0x08

    call get_VirtualProtect  ; REWRITE: [codecave:ExpHP.bullet-cap.get-VirtualProtect]
    mov  [%$VirtualProtect], eax

    ; make sure we can write
    lea  eax, [%$old_protect]
    push eax
    push PAGE_EXECUTE_READWRITE
    push dword [%$length]
    push dword [%$dest]
    call [%$VirtualProtect]

    ; do the actual memcpy
    mov  ecx, [%$length]
    mov  esi, [%$source]
    mov  edi, [%$dest]
    rep movsb

    ; cleanup
    lea  eax, [%$old_protect]
    push eax
    push dword [%$old_protect]
    push dword [%$length]
    push dword [%$dest]
    call [%$VirtualProtect]

    epilogue_sd
    ret  0xc
    %pop

data:  ; HEADER: ExpHP.bullet-cap.data
wstrings:
.kernel32: dw 'K', 'e', 'r', 'n', 'e', 'l', '3', '2', 0
strings:
.VirtualProtect: db "VirtualProtect", 0

get_VirtualProtect:  ; HEADER: ExpHP.bullet-cap.get-VirtualProtect
    prologue_sd

    mov  eax, data  ; REWRITE: <codecave:ExpHP.bullet-cap.data>
    lea  eax, [eax + wstrings.kernel32 - data]
    push eax
    mov  eax, iat_funcs  ; REWRITE: <codecave:ExpHP.bullet-cap.iat-funcs>
    mov  eax, [eax + iat_funcs.GetModuleHandleW - iat_funcs]
    call [eax]
    test eax, eax
    jz   .error

    mov  ecx, eax
    mov  eax, data  ; REWRITE: <codecave:ExpHP.bullet-cap.data>
    lea  eax, [eax + strings.VirtualProtect - data]
    push eax
    push ecx
    mov  eax, iat_funcs  ; REWRITE: <codecave:ExpHP.bullet-cap.iat-funcs>
    mov  eax, [eax + iat_funcs.GetProcAddress - iat_funcs]
    call [eax]
    test eax, eax
    jz   .error

    epilogue_sd
    ret

.error:
    mov  eax, iat_funcs  ; REWRITE: <codecave:ExpHP.bullet-cap.iat-funcs>
    mov  eax, [eax + iat_funcs.GetLastError - iat_funcs]
    call [eax]
    int 3
