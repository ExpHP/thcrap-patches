; (for once, this .asm file actually IS a source file.
;  Its "compilation" hinges on a number of terrifyingly fragile string transformations
;  stacked like a house of cards on top of nasm's output, and requires delicate placement
;  of tons of cryptic meta-comments like "; DELETE".  But it *is* fully automated by make.)

%include "util.asm"

%define PAGE_EXECUTE_READWRITE 0x40

iat_funcs:  ; DELETE
.GetLastError: dd 0  ; DELETE
.GetModuleHandleA: dd 0  ; DELETE
.GetModuleHandleW: dd 0  ; DELETE
.GetProcAddress: dd 0  ; DELETE

address_range:  ; DELETE
.start: dd 0  ; DELETE
.end: dd 0  ; DELETE

bullet_data:  ; DELETE
.old_count: dd 0  ; DELETE
.bullet_size: dd 0  ; DELETE

counts_to_replace:  ; DELETE
offsets_to_replace:  ; DELETE

new_bullet_cap_bigendian:  ; HEADER: bullet-cap
    ; db 0x00, 0x04, 0x86, 0xa0  ; huge
    db 0x00, 0x00, 0x0f, 0xa0  ; release
    ; db 0x00, 0x00, 0x07, 0xd0  ; game default
    ; db 0x00, 0x00, 0x00, 0x0a  ; debug

; __stdcall Initialize()
initialize:  ; HEADER: ExpHP.bullet-cap.initialize
    %push

    enter 0x14, 0
    %define %$value_ptr   ebp-0x04
    %define %$blacklist   ebp-0x08
    %define %$old_value   ebp-0x0c
    %define %$scale       ebp-0x10
    %define %$scale_divisor ebp-0x14

    ; Find and replace integers like 2000 and 2001.
    mov  dword [%$value_ptr], counts_to_replace  ; REWRITE: <codecave:ExpHP.bullet-cap.counts-to-replace>

.countiter:
    mov  ecx, [%$value_ptr]
    mov  eax, [ecx]
    test eax, eax
    jz   .countend  ; list ends with a zero
    mov  [%$old_value], eax
    add  ecx, 0x4
    mov  [%$blacklist], ecx

    push dword [%$blacklist]
    push 1  ; scale
    push dword [%$old_value]
    call adjust_integer_for_bullet_count  ; REWRITE: [codecave:ExpHP.bullet-cap.adjust-integer-for-bullet-count]
    ; return value is pointer to after blacklist
    mov  [%$value_ptr], eax
    jmp  .countiter
.countend:

    ; Find and replace offsets into BulletManager that depend on bullet count.
    ; These values are scaled by bullet size. (possibly divided by something)
    mov  dword [%$value_ptr], offsets_to_replace ; REWRITE: <codecave:ExpHP.bullet-cap.offsets-to-replace>

.offsetiter:
    mov  ecx, [%$value_ptr]
    mov  eax, [ecx]
    test eax, eax
    jz   .offsetend  ; list ends with a zero
    mov  [%$old_value], eax
    add  ecx, 0x4
    mov  eax, [ecx]
    mov  [%$scale_divisor], eax
    add  ecx, 0x4
    mov  [%$blacklist], ecx

    mov  eax, bullet_data  ; REWRITE:  <codecave:ExpHP.bullet-cap.bullet-data>
    mov  eax, [eax + bullet_data.bullet_size - bullet_data]
    xor  edx, edx
    div  dword [%$scale_divisor]
    mov  [%$scale], eax

    push dword [%$blacklist]
    push dword [%$scale]
    push dword [%$old_value]
    call adjust_integer_for_bullet_count  ; REWRITE: [codecave:ExpHP.bullet-cap.adjust-integer-for-bullet-count]
    ; return value is pointer to after blacklist
    mov  [%$value_ptr], eax
    jmp  .offsetiter
.offsetend:
    leave
    ret
    %pop

; Search and replace all instances in .text of a dword whose value bears a linear relationship to bullet count.
; (i.e. the value is `a + scale * count` for some unknown `a`)
;
; Returns a pointer to after the end of the blacklist.
;
; __stdcall AdjustIntegerForBulletCount(old_value, scale, blacklist*)
adjust_integer_for_bullet_count:  ; HEADER: ExpHP.bullet-cap.adjust-integer-for-bullet-count
    %push

    %define %$old_value   ebp+0x08
    %define %$scale       ebp+0x0c
    %define %$blacklist   ebp+0x10
    enter 0x8, 0
    %define %$new_value   ebp-0x04
    %define %$old_count   ebp-0x08

    mov  eax, bullet_data  ; REWRITE: <codecave:ExpHP.bullet-cap.bullet-data>
    mov  eax, [eax + bullet_data.old_count - bullet_data]
    mov  [%$old_count], eax

    mov  eax, [new_bullet_cap_bigendian]  ; REWRITE: <codecave:bullet-cap>
    bswap eax  ; convert from big endian
    sub  eax, [%$old_count]
    imul eax, [%$scale]
    add  eax, [%$old_value]
    mov  [%$new_value], eax

    push dword [%$blacklist]
    push 0x4  ; pattern_len
    lea  eax, [%$new_value]
    push eax  ; replacement
    lea  eax, [%$old_value]
    push eax  ; original
    mov  eax, address_range  ; REWRITE: <codecave:ExpHP.bullet-cap.address-range>
    push dword [eax + address_range.end - address_range]
    push dword [eax + address_range.start - address_range]
    call search_n_replace  ; REWRITE: [codecave:ExpHP.bullet-cap.search-n-replace]

    ; keep eax for return value
    leave
    ret  0xc
    %pop

; Replaces all instances of a sequence of bytes in an address range.
; If the beginning of a match is in the blacklist, it is not replaced.
; (because it's easy to make mistakes in the blacklist, all addresses in it are
;  also verified to actually contain this integer)
;
; Returns a pointer pointing to after the end of the blacklist. (after the 0)
;
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
    ; caller will want to know where blacklist ends because there's more data after it
    mov  eax, [%$blacklist]
    add  eax, 0x4
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

    %define %$dest           ebp+0x08
    %define %$source         ebp+0x0c
    %define %$length         ebp+0x10
    enter 0x8, 0
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

    leave
    ret  0xc
    %pop

data:  ; HEADER: ExpHP.bullet-cap.data
wstrings:
.kernel32: dw 'K', 'e', 'r', 'n', 'e', 'l', '3', '2', 0
strings:
.kernel32: db "Kernel32", 0
.VirtualProtect: db "VirtualProtect", 0

get_VirtualProtect:  ; HEADER: ExpHP.bullet-cap.get-VirtualProtect
    prologue_sd

    ; TH10 only has GetModuleHandleA.  Some recent games only have GetModuleHandleW.  Use whatever we've got.
    mov  eax, iat_funcs  ; REWRITE: <codecave:ExpHP.bullet-cap.iat-funcs>
    mov  eax, [eax + iat_funcs.GetModuleHandleA - iat_funcs]
    test eax, eax
    jz   .use_wide

.use_ansi:
    mov  eax, data  ; REWRITE: <codecave:ExpHP.bullet-cap.data>
    lea  eax, [eax + strings.kernel32 - data]
    push eax
    mov  eax, iat_funcs  ; REWRITE: <codecave:ExpHP.bullet-cap.iat-funcs>
    mov  eax, [eax + iat_funcs.GetModuleHandleA - iat_funcs]
    call [eax]
    test eax, eax
    jz   .error
    jmp .get_proc

.use_wide:
    mov  eax, data  ; REWRITE: <codecave:ExpHP.bullet-cap.data>
    lea  eax, [eax + wstrings.kernel32 - data]
    push eax
    mov  eax, iat_funcs  ; REWRITE: <codecave:ExpHP.bullet-cap.iat-funcs>
    mov  eax, [eax + iat_funcs.GetModuleHandleW - iat_funcs]
    call [eax]
    test eax, eax
    jz   .error

.get_proc:
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