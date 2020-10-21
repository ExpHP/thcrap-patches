; (for once, this .asm file actually IS a source file.
;  Its "compilation" hinges on a number of terrifyingly fragile string transformations
;  stacked like a house of cards on top of nasm's output, and requires delicate placement
;  of tons of cryptic meta-comments like "; DELETE".  But it *is* fully automated by make.)

; AUTO_PREFIX: ExpHP.bullet-cap.

%include "util.asm"
%include "common.asm"

%define MB_OK 0
%define PAGE_EXECUTE_READWRITE 0x40

; A macro like  `dest = *src++`
;
; Args:  dest:  r/m32
;        src:   reg32
;        clobber: reg32
%macro  read_advance_dword 3.nolist
    mov %3, [%2]
    mov %1, %3
    lea %2, [%2 + 0x4]
%endmacro

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
bullet_mgr_layout:  ; DELETE
item_mgr_layout:  ; DELETE
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

;=========================================
; Funcs used by binhacks

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

    push CAPID_BULLET
    call do_replacement_list  ; REWRITE: [codecave:AUTO]
    push CAPID_LASER
    call do_replacement_list  ; REWRITE: [codecave:AUTO]
    push CAPID_CANCEL
    call do_replacement_list  ; REWRITE: [codecave:AUTO]

    push STRUCT_BULLET_MGR
    call do_offset_replacement_list  ; REWRITE: [codecave:AUTO]
    push STRUCT_ITEM_MGR
    call do_offset_replacement_list  ; REWRITE: [codecave:AUTO]

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

;=========================================
; Main implementation

; __stdcall DoReplacementList(capid)
do_replacement_list:  ; HEADER: AUTO
    %push

    %define %$capid       ebp+0x08
    enter 0x18, 0
    %define %$list        ebp-0x04
    %define %$old_value   ebp-0x08
    %define %$new_value   ebp-0x0c
    %define %$scale_const ebp-0x10
    %define %$range_start ebp-0x14
    %define %$range_end   ebp-0x18

    push dword [%$capid]
    call get_cap_data  ; REWRITE: [codecave:AUTO]
    lea  eax, [eax + ListHeader.list]
    mov  [%$list], eax

.iter:
    ; No more entries?
    mov  ecx, [%$list]
    mov  eax, [ecx]
    cmp  eax, LIST_END
    je   .end

    cmp  eax, DWORD_RANGE_TOKEN
    je   .dword_range

.single_value:
    ; Read entry
    read_advance_dword [%$old_value], ecx, eax
    read_advance_dword [%$scale_const], ecx, eax
    mov  [%$list], ecx  ; now points to blacklist/whitelist

    push dword [%$old_value]
    push dword [%$capid]
    push dword [%$scale_const]
    call adjust_value_for_cap  ; REWRITE: [codecave:AUTO]
    mov  [%$new_value], eax

    push dword [%$list]
    push dword [%$new_value]
    push dword [%$old_value]
    call perform_single_replacement  ; REWRITE: [codecave:AUTO]
    ; return value is pointer to after blacklist
    mov  [%$list], eax
    jmp  .iter

.dword_range:
    int 3  ; can only replace ranges of offsets, not of values
.end:
    leave
    ret  0x4
    %pop

; __stdcall DoOffsetReplacementList(structid)
do_offset_replacement_list:  ; HEADER: AUTO
    %push

    %define %$structid    ebp+0x08
    enter 0x14, 0
    %define %$list        ebp-0x04
    %define %$old_value   ebp-0x08
    %define %$new_value   ebp-0x0c
    %define %$range_start ebp-0x10
    %define %$range_end   ebp-0x14

    push dword [%$structid]
    call get_struct_data  ; REWRITE: [codecave:AUTO]
    add  eax, [eax + LayoutHeader.offset_to_replacements]
    mov  [%$list], eax

.iter:
    ; No more entries?
    mov  ecx, [%$list]
    mov  eax, [ecx]
    cmp  eax, LIST_END
    je   .end

    cmp  eax, DWORD_RANGE_TOKEN
    je   .dword_range

.single_value:
    ; Read entry
    read_advance_dword [%$old_value], ecx, eax
    mov  [%$list], ecx  ; now points to blacklist/whitelist

    ; Find the new offset
    push dword [%$old_value]  ; old value
    push dword [%$structid]
    push 0  ; struct_base.  0 because we're mapping an offset.
    call get_modified_address  ; REWRITE: [codecave:AUTO]
    mov  [%$new_value], eax

    push dword [%$list]
    push dword [%$new_value]
    push dword [%$old_value]
    call perform_single_replacement  ; REWRITE: [codecave:AUTO]
    ; return value is pointer to after blacklist
    mov  [%$list], eax
    jmp  .iter

.dword_range:
    lea  ecx, [ecx+0x4]  ; scan past the DWORD_RANGE_TOKEN
    read_advance_dword [%$range_start], ecx, eax
    read_advance_dword [%$range_end], ecx, eax

    push ecx  ; blacklist/whitelist
    push dword [%$range_end]
    push dword [%$range_start]
    push dword [%$structid]
    call perform_dword_range_replacement  ; REWRITE: [codecave:AUTO]
    mov  [%$list], eax
    jmp  .iter
.end:
    leave
    ret  0x4
    %pop

;=========================================
; Lookup of things

; __stdcall LayoutHeader* GetStructData(structid)
get_struct_data:  ; HEADER: AUTO
    prologue_sd
    cmp  dword [ebp+0x8], STRUCT_BULLET_MGR
    je   .bulletmgr
    cmp  dword [ebp+0x8], STRUCT_ITEM_MGR
    je   .itemmgr
    die  ; probably read type from wrong address
.bulletmgr:
    mov  eax, bullet_mgr_layout  ; REWRITE: <codecave:AUTO>
    jmp  .done
.itemmgr:
    mov  eax, item_mgr_layout  ; REWRITE: <codecave:AUTO>
    jmp  .done
.done:
    epilogue_sd
    ret 0x4

; __stdcall ListHeader* GetCapData(arrayid)
get_cap_data:  ; HEADER: AUTO
    prologue_sd
    cmp  dword [ebp+0x8], CAPID_BULLET
    je   .bullet
    cmp  dword [ebp+0x8], CAPID_CANCEL
    je   .cancel
    cmp  dword [ebp+0x8], CAPID_LASER
    je   .laser
    die  ; probably read type from wrong address
.bullet:
    mov  eax, bullet_replacements  ; REWRITE: <codecave:AUTO>
    jmp  .done
.cancel:
    mov  eax, cancel_replacements  ; REWRITE: <codecave:AUTO>
    jmp  .done
.laser:
    mov  eax, laser_replacements  ; REWRITE: <codecave:AUTO>
    jmp  .done
.done:
    epilogue_sd
    ret 0x4

; __stdcall ListHeader* GetNewCap(arrayid)
get_new_cap:  ; HEADER: AUTO
    prologue_sd
    cmp  dword [ebp+0x8], CAPID_BULLET
    je   .bullet
    cmp  dword [ebp+0x8], CAPID_CANCEL
    je   .cancel
    cmp  dword [ebp+0x8], CAPID_LASER
    je   .laser
    die  ; probably read type from wrong address
.bullet:
    mov  eax, 0  ; REWRITE: <codecave:bullet-cap>
    jmp  .done
.cancel:
    mov  eax, 0  ; REWRITE: <codecave:cancel-cap>
    jmp  .done
.laser:
    mov  eax, 0  ; REWRITE: <codecave:laser-cap>
    jmp  .done
.done:
    mov  eax, [eax]  ; read codecave
    bswap eax  ; big endian to little endian
    epilogue_sd
    ret 0x4

;=========================================

;     push dword [%$structid]
;     call get_struct_data  ; REWRITE: [codecave:AUTO]
;     mov  ecx, eax

;     ; Locate the struct
;     mov  eax, [ecx+LayoutHeader.address]
;     test dword [ecx+LayoutHeader.is_pointer], -1
;     jz   .notpointer
;     mov  eax, [eax]
; .notpointer:
;     mov  [%$struct_base], eax

;=========================================
; Transforming values

; Transforms a value according to a change in a single cap,
; using the scale constant to determine how the cap relates to the value.
;
; __stdcall int AdjustValueForCap(scale_constant, capid, old_value)
adjust_value_for_cap:  ; HEADER: AUTO
    %push

    %define %$scale_const ebp+0x08
    %define %$capid       ebp+0x0c
    %define %$old_value   ebp+0x10
    enter 0x14, 0
    %define %$scale       ebp-0x04
    %define %$sign        ebp-0x08
    %define %$item_size   ebp-0x0c
    %define %$old_cap     ebp-0x10
    %define %$new_cap     ebp-0x14

    ; gather cap info
    push dword [%$capid]
    call get_cap_data  ; REWRITE: [codecave:AUTO]
    mov  ecx, eax
    mov  eax, [ecx+ListHeader.old_cap]
    mov  [%$old_cap], eax
    mov  eax, [ecx+ListHeader.elem_size]
    mov  [%$item_size], eax
    push dword [%$capid]
    call get_new_cap  ; REWRITE: [codecave:AUTO]
    mov  [%$new_cap], eax

    push dword [%$old_value]
    push dword [%$new_cap]
    push dword [%$old_cap]
    push dword [%$item_size]
    push dword [%$scale_const]
    call adjust_value_for_cap_impl  ; REWRITE: [codecave:AUTO]

    leave
    ret  0xc
    %pop

; Implementation of scale constants.  Has a slightly more general signature so
; that it can be used for more things.
;
; __stdcall int AdjustValueForCapImpl(scale_constant, item_size, old_cap, new_cap, old_value)
adjust_value_for_cap_impl:  ; HEADER: AUTO
    %push

    %define %$scale_const ebp+0x08
    %define %$item_size   ebp+0x0c
    %define %$old_cap     ebp+0x10
    %define %$new_cap     ebp+0x14
    %define %$old_value   ebp+0x18
    enter 0x08, 0
    %define %$scale       ebp-0x04
    %define %$sign        ebp-0x08

    mov  eax, [%$item_size]
    movzx ecx, byte [%$scale_const + ScaleConst.size_mult]
    imul eax, ecx
    movzx ecx, byte [%$scale_const + ScaleConst.one_mult]
    add  eax, ecx
    cmp  eax, 0
    jg   .goodscale
    int 3  ; negative or zero scale, probably an error
.goodscale:
    mov  [%$scale], eax

    mov  dword [%$sign], 1
    test dword [%$old_value], SIGN_MASK
    jns  .non_negative
    neg  dword [%$sign]
.non_negative:

    mov  eax, [%$new_cap]
    sub  eax, [%$old_cap]
    imul eax, [%$scale]
    cdq
    movzx ecx, byte [%$scale_const + ScaleConst.divisor]
    idiv ecx
    imul eax, dword [%$sign]
    add  eax, dword [%$old_value]

    ; keep eax for return value
    test edx, edx  ; check remainder
    jnz  .divisibility_error
    ; check new and old value have same sign
    mov  edx, eax
    and  edx, 0x80000000
    xor  edx, dword [%$old_value]
    and  edx, 0x80000000
    test edx, edx
    jns  .done

    mov  edx, [%$old_value]  ; for debugging
    int 3  ; sign changed.  Probably bad scale constant!

.done:
    leave
    ret  0x14

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
    %pop

; Decodes a scale constant into an integer describing the size of each
; item in an array.
;
; __stdcall int DetermineArrayElemSize(scale_constant, capid)
determine_array_elem_size:  ; HEADER: AUTO
    %push
    %define %$scale_const  ebp+0x08
    %define %$capid        ebp+0x0c
    prologue_sd

    push dword [%$capid]
    call get_cap_data  ; REWRITE: [codecave:AUTO]

    ; Delegate by pretending that we are have an array of zero elements and are
    ; resizing it to have one element.
    ;
    ; (one might rightly ask: Why is this function defined in terms of that one instead of the
    ;  other way around?  After all, "what is the value of this scale constant" certainly seems
    ;  like a simpler question to ask than "how does this scale constant transform values?"
    ;
    ;  The reason is because SCALE_1_DIV(n) simply cannot be represented as an integer;
    ;  it is a fraction of an integer.  There is no other reason.  So, blame TH13 and
    ;  its stupid unrolled loops.)
    push 0  ; old value
    push 1  ; new cap
    push 0  ; old cap
    push dword [eax+ListHeader.elem_size]
    push dword [%$scale_const]
    call adjust_value_for_cap_impl  ; REWRITE: [codecave:AUTO]

    %pop
    epilogue_sd
    ret  0x8

; Implementation of struct layouts.  Takes a pointer to where a member would
; normally be located on some global struct, and returns the pointer where
; that member has been relocated.
;
; The field must be located within the range from struct_base to struct_base + orig_size,
; where orig_size is the size of the struct in the vanilla game.  This range is
; doubly inclusive, so that you are allowed to look up a "past the end" pointer.
;
; If the field is located inside an element of a resized array, it must be inside
; either the first or last element.
;
; It is safe to set struct_base to 0 and supply an offset as the value of old_ptr;
; This allows the implementation to be used to compute offsets even when the struct
; may not yet exist.  In this case, the offset must not point into an array that gets
; pointerized.
;
; If any of the above requirements are violated, a breakpoint exception is generated.
;
; __stdcall void* GetModifiedAddress(void* struct_base, structid, void* old_ptr)
get_modified_address:  ; HEADER: AUTO
    %push
    %define %$struct_base ebp+0x08
    %define %$structid    ebp+0x0c
    %define %$old_ptr     ebp+0x10
    prologue_sd 0x18
    %define %$data_entry     ebp-0x04
    %define %$new_ptr        ebp-0x08
    %define %$old_array_loc  ebp-0x0c
    %define %$new_array_loc  ebp-0x10
    %define %$old_offset_into_array  ebp-0x14
    %define %$elem_size      ebp-0x18
    %define %$reg_region_data edi

    push dword [%$structid]
    call get_struct_data  ; REWRITE: [codecave:AUTO]
    lea  %$reg_region_data, [eax+LayoutHeader.regions]

    ; Start looping over memory regions
    mov  eax, [%$old_ptr]
    mov  [%$new_ptr], eax
.iter:
    ; (the start of the next region is the end of this region)
    mov  eax, [%$reg_region_data + RegionData_size+RegionData.start]
    cmp  eax, _REGION_TOKEN_END
    je   .beyondlastregion  ; we're past the end then...
    cmp  eax, [%$old_ptr]
    jle  .beyondregion
    jmp  .withinregion

.beyondregion:
    ; We are not in this region.
    ; If this is an array, adjust new_ptr to account for the change in this region's size.
    test dword [%$reg_region_data + RegionData.capid], -1
    jz   .next  ; not an array

    push dword [%$new_ptr]  ; old value
    push dword [%$reg_region_data + RegionData.capid]
    push dword [%$reg_region_data + RegionData.scale_outside]
    call adjust_value_for_cap  ; REWRITE: [codecave:AUTO]
    mov  [%$new_ptr], eax

.next:
    ; Go to the next region.
    add  %$reg_region_data, RegionData_size
    jmp  .iter

;--------------------
.withinregion:
    ; We are inside this region.  It's possible that no further change is necessary...
    ; Is it an array?
    test dword [%$reg_region_data + RegionData.capid], -1
    jz   .done  ; not an array, so nothing to do

    mov  eax, [%$struct_base]
    add  eax, [%$reg_region_data + RegionData.start]
    mov  [%$old_array_loc], eax

    mov  eax, [%$old_ptr]
    sub  eax, [%$old_array_loc]
    mov  [%$old_offset_into_array], eax

    ; Array should have shifted as much as our member pointer has
    mov  eax, [%$old_array_loc]
    add  eax, [%$new_ptr]
    sub  eax, [%$old_ptr]
    mov  [%$new_array_loc], eax

    push dword [%$reg_region_data + RegionData.capid]
    push dword [%$reg_region_data + RegionData.scale_inside]
    call determine_array_elem_size  ; REWRITE: [codecave:AUTO]
    mov  [%$elem_size], eax

    ; Was it pointerified?
    test dword [%$reg_region_data + RegionData.flags], _REGION_FLAG_POINTERIFIED
    jz   .withinregion.notpointerified

.withinregion.pointerified:
    test dword [%$struct_base], -1
    jz   .cannotpointerify  ; we're working with offsets so we can't dereference

    mov  eax, [%$new_array_loc]
    mov  eax, [eax]  ; follow the pointer at this location
    mov  [%$new_array_loc], eax
    add  eax, [%$old_offset_into_array]
    mov  [%$new_ptr], eax

.withinregion.notpointerified:
    ; Are we within the first item?
    mov  eax, [%$old_ptr]
    sub  eax, [%$reg_region_data + RegionData.start]
    cmp  eax, [%$elem_size]
    jl   .done  ; inside first item; nothing more to do

    ; Are we within the last item?
    mov  eax, [%$reg_region_data + RegionData_size + RegionData.start]
    sub  eax, [%$elem_size]
    cmp  [%$old_ptr], eax
    jl   .middleofarray  ; not inside last item

    ; Inside last item; account for array resize
    push dword [%$new_ptr]  ; old value
    push dword [%$reg_region_data + RegionData.capid]
    push dword [%$reg_region_data + RegionData.scale_inside]
    call adjust_value_for_cap  ; REWRITE: [codecave:AUTO]
    mov  [%$new_ptr], eax
    jmp  .done

;--------------------
.beyondlastregion:
    ; One final possibility: We allow passing in a pointer to the very end of the struct.
    ; Is this what happened?
    mov  eax, [%$old_ptr]
    sub  eax, [%$struct_base]
    sub  eax, [%$reg_region_data + RegionData.start]
    jz   .done
    jmp  .outofbounds

.outofbounds:
    die  ; address is not inside the struct
.middleofarray:
    die  ; address is not in the first or last array item
.cannotpointerify:
    die  ; requested a pointerified address when struct_base is null

.done:
    mov  eax, [%$new_ptr]
    epilogue_sd
    ret  0x0c
    %pop

;=========================================
; Mass replacement of values

; Replace instances in .text of a single dword value.  There may be a blacklist of addresses to not
; replace (in which case the entire address space is searched), or a whitelist of addresses to replace
; (in which case only those are replaced).
;
; Returns a pointer to after the end of the blacklist or whitelist.
;
; __stdcall void* PerformSingleReplacement(old_value, new_value, bwlist**)
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

    die  ; Probably a typo in the whitelist

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

; Replace instances in .text of a range of offsets into a struct.
; Returns a pointer to after the end of the blacklist or whitelist.
;
; __stdcall void* PerformDwordRangeReplacement(structid, range_start, range_end, bwlist**)
perform_dword_range_replacement:  ; HEADER: AUTO
    %push
    %define %$structid     ebp+0x08
    %define %$range_start  ebp+0x0c
    %define %$range_end    ebp+0x10
    %define %$whitelist    ebp+0x14
    prologue_sd 0x08
    %define %$old_value    ebp-0x04
    %define %$new_value    ebp-0x08
    %define %$target    esi

    mov  eax, [%$whitelist]
    mov  eax, [eax]  ; read list type

    add  dword [%$whitelist], 0x4  ; point to whitelist contents

    cmp  eax, WHITELIST_BEGIN
    je   .has_whitelist

    int 3  ; blacklist not supported for dword range

.has_whitelist:
.iter:
    mov  eax, [%$whitelist]  ; address of whitelist
    mov  %$target, [eax]      ; address in list
    cmp  %$target, WHITELIST_END
    je   .end

    mov  edx, [%$target]
    mov  [%$old_value], edx
    cmp  edx, [%$range_start]
    jb   .unexpected_value
    cmp  edx, [%$range_end]
    jge  .unexpected_value
    jmp  .good_value

.unexpected_value:
    push "badv"
    int 3

.good_value:
    push dword [%$old_value]  ; old value
    push dword [%$structid]
    push 0  ; struct_base.  0 because we're mapping an offset.
    call get_modified_address  ; REWRITE: [codecave:AUTO]
    mov  [%$new_value], eax

    push 4
    lea  eax, [%$new_value]
    push eax  ; replacement
    push %$target
    call memcpy_or_bust  ; REWRITE: [codecave:AUTO]

    add  dword [%$whitelist], 0x4
    jmp .iter
.end:
    mov  eax, [%$whitelist]
    add  eax, 0x4  ; return pointer to after list
    epilogue_sd
    ret  0x18
    %pop

;=========================================
; Utils

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
