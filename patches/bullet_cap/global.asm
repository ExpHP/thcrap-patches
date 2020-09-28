; (for once, this .asm file actually IS a source file.
;  Its "compilation" hinges on a number of terrifyingly fragile string transformations
;  stacked like a house of cards on top of nasm's output, and requires delicate placement
;  of tons of cryptic meta-comments like "; DELETE".  But it *is* fully automated by make.)

; AUTO_PREFIX: ExpHP.bullet-cap.

%include "util.asm"
%include "common.asm"

%define MB_OK 0
%define PAGE_EXECUTE_READWRITE 0x40

iat_funcs:  ; DELETE
.GetLastError: dd 0  ; DELETE
.GetModuleHandleA: dd 0  ; DELETE
.GetModuleHandleW: dd 0  ; DELETE
.GetProcAddress: dd 0  ; DELETE
.MessageBoxA: dd 0  ; DELETE

address_range:  ; DELETE
.start: dd 0  ; DELETE
.end: dd 0  ; DELETE

game_data:  ; DELETE
bullet_replacements:  ; DELETE
cancel_replacements:  ; DELETE
laser_replacements:  ; DELETE
perf_fix_data:  ; DELETE

new_bullet_cap_bigendian:  ; DELETE
new_laser_cap_bigendian:  ; DELETE
new_cancel_cap_bigendian:  ; DELETE
config_lag_spike_cutoff_bigendian:  ; DELETE

data:  ; HEADER: ExpHP.bullet-cap.data
wstrings:
.kernel32: dw 'K', 'e', 'r', 'n', 'e', 'l', '3', '2', 0
strings:
.kernel32: db "Kernel32", 0
.VirtualProtect: db "VirtualProtect", 0
.error_title: db "bullet_cap mod error", 0
.divisibility_error: db "Sorry, due to technical limitations, the bullet cap in Ten Desires must be divisible by 5, and the cancel cap must be divisible by 4.", 0

; Used as a datacave to avoid running multiple times
runonce:  ; HEADER: AUTO
    dd 0

; __stdcall Initialize()
initialize:  ; HEADER: AUTO
    mov  eax, [runonce]  ; REWRITE: <codecave:AUTO>
    test eax, eax
    jnz  .norun

    ; set runonce to 1, regardless of codecave permissions
    push 1  ; put on stack so we can get pointer
    mov  ecx, esp
    mov  eax, runonce  ; REWRITE: <codecave:AUTO>
    push 4
    push ecx
    push eax
    call memcpy_or_bust  ; REWRITE: [codecave:AUTO]
    add  esp, 0x4  ; dealloc the '1'

    mov  eax, [new_bullet_cap_bigendian]  ; REWRITE: <codecave:bullet-cap>
    bswap eax
    push eax
    mov  eax, bullet_replacements  ; REWRITE: <codecave:AUTO>
    push eax
    call do_replacement_list  ; REWRITE: [codecave:AUTO]

    mov  eax, [new_laser_cap_bigendian]  ; REWRITE: <codecave:laser-cap>
    bswap eax
    push eax
    mov  eax, laser_replacements  ; REWRITE: <codecave:AUTO>
    push eax
    call do_replacement_list  ; REWRITE: [codecave:AUTO]

    mov  eax, [new_cancel_cap_bigendian]  ; REWRITE: <codecave:cancel-cap>
    bswap eax
    push eax
    mov  eax, cancel_replacements  ; REWRITE: <codecave:AUTO>
    push eax
    call do_replacement_list  ; REWRITE: [codecave:AUTO]

.norun:
    ret

; Increment the cancel item index in games without a freelist.
; (the cancel item array size is usually a power of two, so this operation in the original code
;  usually gets optimized to a bitwise operation, preventing us from doing simple value replacement)
;
; __stdcall int NextCancelIndex(int)
next_cancel_index:  ; HEADER: AUTO
    prologue_sd
    mov  eax, [ebp+0x08]
    inc  eax
    mov  edx, [new_cancel_cap_bigendian]  ; REWRITE: <codecave:cancel-cap>
    bswap edx
    cmp  eax, edx
    mov  edx, 0
    cmove eax, edx
    epilogue_sd
    ret  0x4

; __stdcall DoReplacementList(ListHeader*, new_cap)
do_replacement_list:  ; HEADER: AUTO
    %push

    %define %$list        ebp+0x08
    %define %$new_cap     ebp+0x0c
    enter 0x14, 0
    %define %$old_cap     ebp-0x04
    %define %$elem_size   ebp-0x08
    %define %$old_value   ebp-0x0c
    %define %$new_value   ebp-0x10
    %define %$scale_const ebp-0x14

    mov  ecx, [%$list]
    mov  eax, [ecx + ListHeader.old_cap]
    mov  [%$old_cap], eax
    mov  eax, [ecx + ListHeader.elem_size]
    mov  [%$elem_size], eax
    ; Advance to first entry.
    lea  eax, [ecx + ListHeader.list]
    mov  [%$list], eax

.iter:
    ; No more entries?
    mov  ecx, [%$list]
    mov  eax, [ecx]
    cmp  eax, LIST_END
    je   .end

    ; Read entry
    mov  [%$old_value], eax
    add  ecx, 0x4
    mov  eax, [ecx]
    mov  [%$scale_const], eax
    add  ecx, 0x4
    mov  [%$list], ecx  ; now points to blacklist/whitelist

    push dword [%$old_value]
    push dword [%$new_cap]
    push dword [%$old_cap]
    push dword [%$elem_size]
    push dword [%$scale_const]
    call determine_new_value  ; REWRITE: [codecave:AUTO]
    mov  [%$new_value], eax

    push dword [%$list]
    push dword [%$new_value]
    push dword [%$old_value]
    call perform_single_replacement  ; REWRITE: [codecave:AUTO]
    ; return value is pointer to after blacklist
    mov  [%$list], eax
    jmp  .iter
.end:
    leave
    ret  0x8
    %pop

; __stdcall int DetermineNewValue(scale_constant, item_size, old_cap, new_cap, old_value)
determine_new_value:  ; HEADER: AUTO
    %push

    %define %$scale_const ebp+0x08
    %define %$item_size   ebp+0x0c
    %define %$old_cap     ebp+0x10
    %define %$new_cap     ebp+0x14
    %define %$old_value   ebp+0x18
    enter 0x4, 0
    %define %$scale       ebp-0x04

    cmp  dword [%$scale_const], 0
    jg   .pos_scale
    jl   .neg_scale
    int  3  ; 0 is invalid

.pos_scale:  ; positive scale constant is SCALE_SIZE_DIV(n)
    mov  eax, [%$item_size]
    mov  [%$scale], eax
    jmp  .scale_done
.neg_scale:  ; negative scale constant is SCALE_1_DIV(n)
    mov  dword [%$scale], 1
    neg  dword [%$scale_const]  ;  abs(x)

.scale_done:
    mov  eax, [%$new_cap]
    sub  eax, [%$old_cap]
    imul eax, [%$scale]
    cdq
    idiv dword [%$scale_const]
    add  eax, dword [%$old_value]

    ; keep eax from division for return value
    test edx, edx  ; check remainder
    jz   .done

.divisibility_error:
    mov  ecx, data  ; REWRITE: <codecave:AUTO>
    push MB_OK  ; uType
    lea  eax, [ecx + strings.error_title - data]
    push eax  ; lpCaption
    lea  eax, [ecx + strings.divisibility_error - data]
    push eax  ; lpText
    push 0  ; hWnd
    mov  eax, iat_funcs  ; REWRITE: <codecave:AUTO>
    mov  eax, [eax + iat_funcs.MessageBoxA - iat_funcs]
    call [eax]
    int  3

.done:
    leave
    ret  0x14
    %pop

; Replace all instances in .text of a single dword value.  There may be a blacklist of addresses to not
; replace (in which case the entire address space is searched), or a whitelist of addresses to replace
; (in which case only those are replaced).
;
; Returns a pointer to after the end of the blacklist or whitelist.
;
; __stdcall PerformSingleReplacement(old_value, new_value, bwlist*)
perform_single_replacement:  ; HEADER: AUTO
    %push
    %define %$old_value   ebp+0x08
    %define %$new_value   ebp+0x0c
    %define %$list        ebp+0x10
    enter 0x00, 0

    mov  eax, [%$list]
    mov  eax, [eax]  ; read list type
    add  dword [%$list], 0x4  ; point to whitelist/blacklist contents

    cmp  eax, WHITELIST_BEGIN
    je   .has_whitelist
    cmp  eax, BLACKLIST_BEGIN
    je   .has_blacklist

    int 3  ; list has invalid format

.has_whitelist:

    push dword [%$list]
    push 0x4  ; pattern_len
    lea  eax, [%$new_value]
    push eax  ; replacement
    lea  eax, [%$old_value]
    push eax  ; original
    call replace_with_whitelist  ; REWRITE: [codecave:AUTO]

    ; keep eax for return value
    jmp .end

.has_blacklist:

    push dword [%$list]
    push 0x4  ; pattern_len
    lea  eax, [%$new_value]
    push eax  ; replacement
    lea  eax, [%$old_value]
    push eax  ; original
    mov  eax, address_range  ; REWRITE: <codecave:AUTO>
    push dword [eax + address_range.end - address_range]
    push dword [eax + address_range.start - address_range]
    call search_n_replace  ; REWRITE: [codecave:AUTO]

.end:
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
search_n_replace:  ; HEADER: AUTO
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
    call mem_compare  ; REWRITE: [codecave:AUTO]
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
    call memcpy_or_bust  ; REWRITE: [codecave:AUTO]
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
    cmp  eax, BLACKLIST_END
    je   .goodblacklist  ; at end of list?
    int 3
.goodblacklist:
    ; caller will want to know where blacklist ends because there's more data after it
    mov  eax, [%$blacklist]
    add  eax, 0x4
    epilogue_sd
    ret 0x18
    %pop

; Replaces specified instances of a sequence of bytes.
;
; ReplaceWithWhitelist(pattern*, replacement*, pattern_len, whitelist*)
replace_with_whitelist:  ; HEADER: AUTO
    %push
    prologue_sd
    %define %$pattern   ebp+0x08
    %define %$repl      ebp+0x0c
    %define %$length    ebp+0x10
    %define %$whitelist ebp+0x14
    %define %$target    esi
.loop:
    mov  ecx, [%$whitelist]
    mov  %$target, [ecx]
    cmp  %$target, WHITELIST_END
    je .end

    ; Expect to find the old bytes there:
    push dword [%$length]
    push %$target
    push dword [%$pattern]
    call mem_compare  ; REWRITE: [codecave:AUTO]
    test eax, eax
    jz   .do_it

    int 3  ; Probably a typo in the whitelist

.do_it:
    push dword [%$length]
    push dword [%$repl]
    push %$target
    call memcpy_or_bust  ; REWRITE: [codecave:AUTO]

    add  dword [%$whitelist], 0x4

    jmp .loop
.end:
    mov  eax, [%$whitelist]
    add  eax, 0x4  ; return pointer to after list

    epilogue_sd
    ret 0x10
    %pop

; Returns 0 if data at `a` == data at `b`, nonzero otherwise.
; (sign of nonzero outputs is unspecified because I'm too lazy to verify whether it matches memcmp)
; __stdcall MemCompare(a*, b*, len)
mem_compare:  ; HEADER: AUTO
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

; __stdcall MemcpyOrBust(dest*, src*, len)
memcpy_or_bust:  ; HEADER: AUTO
    %push

    %define %$dest           ebp+0x08
    %define %$source         ebp+0x0c
    %define %$length         ebp+0x10
    enter 0x8, 0
    %define %$VirtualProtect ebp-0x04
    %define %$old_protect    ebp-0x08
    push esi
    push edi

    call get_VirtualProtect  ; REWRITE: [codecave:AUTO]
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

    pop edi
    pop esi
    leave
    ret  0xc
    %pop

; Replacement for the world list search in AnmManager::get_vm_by_id in TH10 and TH11 that
; makes the quadratic lag spikes become linear beyond a point.  Basically the problem is that
; the game keeps searching for VMs that it just inserted at the very end of the list, so this
; function checks that spot early after a number of iterations.
;
; (we don't just check the spot immediately because honestly the lag spikes are kinda hype as
; long as they're only several seconds long at most)
;
; __stdcall AnmVm* PerfFixFindVmAtTail(int id)
less_spikey_find_world_vm:  ; HEADER: AUTO
    %push
    %define %$desired_id ebp+0x08
    enter 0x10, 0
    %define %$manager    ebp-0x04
    %define %$list_node  ebp-0x08
    %define %$vm         ebp-0x0c
    %define %$tail_delay ebp-0x10

    ; deprecated name;  use if not negative
    mov  eax, dword [config_lag_spike_cutoff_bigendian]  ; REWRITE: <codecave:bullet-cap-config.mof-sa-lag-spike-size>
    bswap eax
    test eax, eax
    jns  .done_config

    mov  eax, dword [config_lag_spike_cutoff_bigendian]  ; REWRITE: <codecave:bullet-cap-config.anm-search-lag-spike-size>
    bswap eax
.done_config:
    inc  eax  ; this is so that we can check ZF after doing `dec`
    mov  [%$tail_delay], eax

    mov  edx, perf_fix_data  ; REWRITE: <codecave:AUTO>
    mov  eax, [edx + PerfFixData.anm_manager_ptr]
    mov  eax, [eax]
    test eax, eax
    jz   .fail
    mov  [%$manager], eax

    add  eax, [edx + PerfFixData.world_list_head_offset]
    mov  eax, [eax]
    mov  [%$list_node], eax

.iter:
    mov  eax, [%$list_node]
    test eax, eax
    jz   .fail  ; entire list searched

    ; on the 'tail_delay'th iteration, we check the tail before continuing
    dec  dword [%$tail_delay]
    jnz  .no_check_tail

    mov  eax, [%$manager]
    add  eax, [edx + PerfFixData.world_list_head_offset]
    add  eax, 0x4  ; tail is after head
    mov  eax, [eax]  ; read list node
    mov  eax, [eax]  ; read vm
    mov  [%$vm], eax

    add  eax, [edx + PerfFixData.anm_id_offset]
    mov  eax, [eax]  ; read id
    cmp  eax, [%$desired_id]
    je   .succeed

.no_check_tail:
    ; check current list entry
    mov  eax, [%$list_node]
    mov  eax, [eax]  ; read vm
    mov  [%$vm], eax

    add  eax, [edx + PerfFixData.anm_id_offset]
    mov  eax, [eax]  ; read id
    cmp  eax, [%$desired_id]
    je   .succeed

    ; follow 'next' pointer
    mov  eax, [%$list_node]
    mov  eax, [eax + ZunList.next]
    mov  [%$list_node], eax
    jmp  .iter

.fail:
    xor  eax, eax
    jmp  .end
.succeed:
    mov  eax, [%$vm]
.end:
    leave
    ret  0x4

get_VirtualProtect:  ; HEADER: AUTO
    prologue_sd

    ; TH10 only has GetModuleHandleA.  Some recent games only have GetModuleHandleW.  Use whatever we've got.
    mov  eax, iat_funcs  ; REWRITE: <codecave:AUTO>
    mov  eax, [eax + iat_funcs.GetModuleHandleA - iat_funcs]
    test eax, eax
    jz   .use_wide

.use_ansi:
    mov  eax, data  ; REWRITE: <codecave:AUTO>
    lea  eax, [eax + strings.kernel32 - data]
    push eax
    mov  eax, iat_funcs  ; REWRITE: <codecave:AUTO>
    mov  eax, [eax + iat_funcs.GetModuleHandleA - iat_funcs]
    call [eax]
    test eax, eax
    jz   .error
    jmp .get_proc

.use_wide:
    mov  eax, data  ; REWRITE: <codecave:AUTO>
    lea  eax, [eax + wstrings.kernel32 - data]
    push eax
    mov  eax, iat_funcs  ; REWRITE: <codecave:AUTO>
    mov  eax, [eax + iat_funcs.GetModuleHandleW - iat_funcs]
    call [eax]
    test eax, eax
    jz   .error

.get_proc:
    mov  ecx, eax
    mov  eax, data  ; REWRITE: <codecave:AUTO>
    lea  eax, [eax + strings.VirtualProtect - data]
    push eax
    push ecx
    mov  eax, iat_funcs  ; REWRITE: <codecave:AUTO>
    mov  eax, [eax + iat_funcs.GetProcAddress - iat_funcs]
    call [eax]
    test eax, eax
    jz   .error

    epilogue_sd
    ret

.error:
    mov  eax, iat_funcs  ; REWRITE: <codecave:AUTO>
    mov  eax, [eax + iat_funcs.GetLastError - iat_funcs]
    call [eax]
    int 3
