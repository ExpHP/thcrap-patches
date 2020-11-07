; AUTO_PREFIX: ExpHP.bullet-cap.

%include "util.asm"
%include "common.asm"
%include "layout-test.asm"

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

;=========================================
; Caves defined per-game

pointerize_data:  ; HEADER: AUTO
    dd 0  ; default definition, overriden per-game

iat_funcs:  ; DELETE
.GetLastError: dd 0  ; DELETE
.GetModuleHandleA: dd 0  ; DELETE
.GetModuleHandleW: dd 0  ; DELETE
.GetProcAddress: dd 0  ; DELETE
.MessageBoxA: dd 0  ; DELETE

corefuncs:
.malloc: dd 0  ; DELETE

address_range:  ; DELETE
.start: dd 0  ; DELETE
.end: dd 0  ; DELETE

game_data:  ; DELETE
bullet_replacements:  ; DELETE
fairy_bullet_replacements:  ; DELETE
rival_bullet_replacements:  ; DELETE
cancel_replacements:  ; DELETE
laser_replacements:  ; DELETE
bullet_mgr_layout:  ; DELETE
item_mgr_layout:  ; DELETE
perf_fix_data:  ; DELETE

new_bullet_cap_bigendian:  ; DELETE
new_laser_cap_bigendian:  ; DELETE
new_cancel_cap_bigendian:  ; DELETE
config_lag_spike_cutoff_bigendian:  ; DELETE

;=========================================
; Data caves

data:  ; HEADER: ExpHP.bullet-cap.data
wstrings:
.kernel32: dw 'K', 'e', 'r', 'n', 'e', 'l', '3', '2', 0
strings:
.kernel32: db "Kernel32", 0
.VirtualProtect: db "VirtualProtect", 0
.error_title: db "bullet_cap mod error", 0
.divisibility_error: db "Sorry, due to technical limitations, the bullet cap in Ten Desires must be divisible by 5, and the cancel cap must be divisible by 4.", 0

cap_definitions:  ; HEADER: AUTO
istruc GlobalCapEntry
    at GlobalCapEntry.capid, dd CAPID_BULLET
    at GlobalCapEntry.game_data_cave, dd bullet_replacements  ; REWRITE: <codecave:AUTO>
    at GlobalCapEntry.game_data_offset, dd 0
    at GlobalCapEntry.new_cap_bigendian_codecave, dd 0  ; REWRITE: <codecave:bullet-cap>
    at GlobalCapEntry.new_cap_test_value, dd NOT_APPLICABLE
iend
istruc GlobalCapEntry
    at GlobalCapEntry.capid, dd CAPID_LASER
    at GlobalCapEntry.game_data_cave, dd laser_replacements  ; REWRITE: <codecave:AUTO>
    at GlobalCapEntry.game_data_offset, dd 0
    at GlobalCapEntry.new_cap_bigendian_codecave, dd 0  ; REWRITE: <codecave:laser-cap>
    at GlobalCapEntry.new_cap_test_value, dd NOT_APPLICABLE
iend
istruc GlobalCapEntry
    at GlobalCapEntry.capid, dd CAPID_CANCEL
    at GlobalCapEntry.game_data_cave, dd cancel_replacements  ; REWRITE: <codecave:AUTO>
    at GlobalCapEntry.game_data_offset, dd 0
    at GlobalCapEntry.new_cap_bigendian_codecave, dd 0  ; REWRITE: <codecave:cancel-cap>
    at GlobalCapEntry.new_cap_test_value, dd NOT_APPLICABLE
iend
istruc GlobalCapEntry
    at GlobalCapEntry.capid, dd __CAPID_TEST_1
    at GlobalCapEntry.game_data_cave, dd the_worlds_saddest_unit_test  ; REWRITE: <codecave:AUTO>
    at GlobalCapEntry.game_data_offset, dd the_worlds_saddest_unit_test.capdata_1 - the_worlds_saddest_unit_test
    at GlobalCapEntry.new_cap_bigendian_codecave, dd NOT_APPLICABLE
    at GlobalCapEntry.new_cap_test_value, dd TEST_NEW_CAP_1
iend
istruc GlobalCapEntry
    at GlobalCapEntry.capid, dd __CAPID_TEST_2
    at GlobalCapEntry.game_data_cave, dd the_worlds_saddest_unit_test  ; REWRITE: <codecave:AUTO>
    at GlobalCapEntry.game_data_offset, dd the_worlds_saddest_unit_test.capdata_2 - the_worlds_saddest_unit_test
    at GlobalCapEntry.new_cap_bigendian_codecave, dd NOT_APPLICABLE
    at GlobalCapEntry.new_cap_test_value, dd TEST_NEW_CAP_2
iend
    dd LIST_END

; Used as a datacave to avoid running multiple times
runonce:  ; HEADER: AUTO
    dd 0

;=========================================
; Funcs that override methods from exphp-base

override__adjust_field_ptr:  ; HEADER: base-exphp.adjust-field-ptr
    func_begin
    func_arg %$structid, %$field_ptr, %$struct_base
    func_prologue ecx, edx

    push dword [%$field_ptr]
    push dword [%$structid]
    push dword [%$struct_base]
    call get_modified_address  ; REWRITE: [codecave:AUTO]

    func_epilogue
    func_ret
    func_end

;=========================================
; Funcs used by binhacks

; __stdcall Initialize()
initialize:  ; HEADER: AUTO
    mov  eax, [runonce]  ; REWRITE: <codecave:AUTO>
    test eax, eax
    jnz  .norun

    mov  eax, the_worlds_saddest_unit_test  ; REWRITE: <codecave:AUTO>
    add  eax, the_worlds_saddest_unit_test.code - the_worlds_saddest_unit_test
    call eax

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
    func_begin
    func_arg  %$capid
    func_local  %$list
    func_local  %$old_value
    func_local  %$new_value
    func_local  %$scale_const
    func_local  %$range_start
    func_local  %$range_end
    func_prologue  esi, edi

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

.end:
    func_epilogue
    func_ret
    func_end

; __stdcall DoOffsetReplacementList(structid)
do_offset_replacement_list:  ; HEADER: AUTO
    func_begin
    func_arg  %$structid
    func_local  %$old_value
    func_local  %$new_value
    func_prologue  esi, edi
    %define %$list_reg esi

    push dword [%$structid]
    call get_struct_data  ; REWRITE: [codecave:AUTO]
    add  eax, [eax + LayoutHeader.offset_to_replacements]
    mov  %$list_reg, eax

.iter:
    ; Dword token indicating what's coming next.
    mov  eax, [%$list_reg]
    add  %$list_reg, 0x4
    cmp  eax, LIST_END
    je   .end
    cmp  eax, _REP_OFFSET_TOKEN
    je   .single_offset
    cmp  eax, _REP_OFFSET_RANGE_TOKEN
    je   .offset_range
    die  ; bad token, probably forgot to use a REP_ macro

.single_offset:
    ; Find the new offset.
    push dword [%$list_reg + RepOffset.to]  ; old value
    push dword [%$structid]
    push 0  ; struct_base.  0 because we're mapping an offset.
    call get_modified_address  ; REWRITE: [codecave:AUTO]
    mov  [%$new_value], eax

    ; This is generalized to be between two fields, so also find the new offset
    ; of the place we're measuring from and subtract that.
    push dword [%$list_reg + RepOffset.from]
    push dword [%$structid]
    push 0
    call get_modified_address  ; REWRITE: [codecave:AUTO]
    sub  [%$new_value], eax

    ; Here's the value we should expect to find in the code (just the difference).
    mov  eax, [%$list_reg + RepOffset.to]
    sub  eax, [%$list_reg + RepOffset.from]
    mov  [%$old_value], eax

    %macro do_division 1.nolist
        mov  eax, %1
        cdq
        idiv dword [%$list_reg + RepOffset.divisor]
        test edx, edx
        jnz  .notdivisible
        mov  %1, eax
    %endmacro
    do_division [%$new_value]
    do_division [%$old_value]

    add  %$list_reg, RepOffset_size
    push %$list_reg  ; blacklist/whitelist
    push dword [%$new_value]
    push dword [%$old_value]
    call perform_single_replacement  ; REWRITE: [codecave:AUTO]
    mov  %$list_reg, eax  ; return value points after blacklist
    jmp  .iter

.notdivisible:
    die

.offset_range:
    mov  ecx, %$list_reg
    add  %$list_reg, RepOffsetRange_size
    push %$list_reg  ; blacklist/whitelist
    push dword [ecx+RepOffsetRange.end]
    push dword [ecx+RepOffsetRange.start]
    push dword [%$structid]
    call perform_dword_range_replacement  ; REWRITE: [codecave:AUTO]
    mov  %$list_reg, eax  ; return value points after blacklist
    jmp  .iter
.end:
    func_epilogue
    func_ret
    func_end

;=========================================
; Lookup of things

; __stdcall LayoutHeader* GetStructData(structid)
get_struct_data:  ; HEADER: AUTO
    prologue_sd
    cmp  dword [ebp+0x8], STRUCT_BULLET_MGR
    je   .bulletmgr
    cmp  dword [ebp+0x8], STRUCT_ITEM_MGR
    je   .itemmgr
    cmp  dword [ebp+0x8], __STRUCT_TEST
    je   .test

    die  ; probably read type from wrong address
.bulletmgr:
    mov  eax, bullet_mgr_layout  ; REWRITE: <codecave:AUTO>
    jmp  .done
.itemmgr:
    mov  eax, item_mgr_layout  ; REWRITE: <codecave:AUTO>
    jmp  .done
.test:
    mov  eax, the_worlds_saddest_unit_test  ; REWRITE: <codecave:AUTO>
    add  eax, the_worlds_saddest_unit_test.layout - the_worlds_saddest_unit_test
    jmp  .done
.done:
    epilogue_sd
    ret 0x4

; __stdcall GlobalCapEntry* GetGlobalCapData(capid)
get_global_cap_data:  ; HEADER: AUTO
    func_begin
    func_arg %$capid
    func_prologue
    mov  ecx, cap_definitions  ; REWRITE: <codecave:AUTO>
.iter:
    cmp  dword [ecx], LIST_END
    je   .fail
    mov  eax, [ecx+GlobalCapEntry.capid]
    cmp  eax, [%$capid]
    je   .found
    add  ecx, GlobalCapEntry_size
    jmp  .iter
.fail:
    die  ; no cap exists with the given ID
.found:
    mov  eax, ecx
    func_epilogue
    func_ret
    func_end

; __stdcall ListHeader* GetCapData(capid)
get_cap_data:  ; HEADER: AUTO
    func_begin
    func_arg  %$capid
    func_prologue
    push dword [%$capid]
    call get_global_cap_data  ; REWRITE: [codecave:AUTO]
    mov  ecx, eax
    mov  eax, [ecx+GlobalCapEntry.game_data_cave]
    add  eax, [ecx+GlobalCapEntry.game_data_offset]
    func_epilogue
    func_ret
    func_end

; __stdcall ListHeader* GetNewCap(capid)
get_new_cap:  ; HEADER: AUTO
    func_begin
    func_arg  %$capid
    func_prologue
    push dword [%$capid]
    call get_global_cap_data  ; REWRITE: [codecave:AUTO]
    mov  ecx, eax
    mov  eax, [ecx+GlobalCapEntry.new_cap_bigendian_codecave]
    cmp  eax, NOT_APPLICABLE
    jne  .codecave
    mov  eax, [ecx+GlobalCapEntry.new_cap_test_value]
    cmp  eax, NOT_APPLICABLE
    jne  .done
    die  ; invalid GlobalCapEntry
.codecave:
    mov  eax, [eax]
    bswap eax
.done:
    func_epilogue
    func_ret
    func_end

;=========================================
; Transforming values

; Transforms a value according to a change in a single cap,
; using the scale constant to determine how the cap relates to the value.
;
; __stdcall int AdjustValueForCap(scale_constant, capid, old_value)
adjust_value_for_cap:  ; HEADER: AUTO
    func_begin
    func_arg  %$scale_const, %$capid, %$old_value
    func_local  %$scale
    func_local  %$sign
    func_local  %$item_size
    func_local  %$old_cap
    func_local  %$new_cap
    func_prologue  esi, edi

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

    func_epilogue
    func_ret
    func_end

; Implementation of scale constants.  Has a slightly more general signature so
; that it can be used for more things.
;
; __stdcall int AdjustValueForCapImpl(scale_constant, item_size, old_cap, new_cap, old_value)
adjust_value_for_cap_impl:  ; HEADER: AUTO
    func_begin
    func_arg  %$scale_const
    func_arg  %$item_size
    func_arg  %$old_cap
    func_arg  %$new_cap
    func_arg  %$old_value
    func_local  %$scale
    func_local  %$sign
    func_prologue  esi, edi

    mov  eax, [%$item_size]
    movzx ecx, byte [%$scale_const + ScaleConst.size_mult]
    imul eax, ecx
    movzx ecx, byte [%$scale_const + ScaleConst.one_mult]
    add  eax, ecx
    cmp  eax, 0
    jge  .goodscale
    die  ; negative scale, probably an error
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
    and  edx, SIGN_MASK
    xor  edx, dword [%$old_value]
    and  edx, SIGN_MASK
    test edx, edx
    jns  .done

    mov  edx, [%$old_value]  ; for debugging
    die  ; sign changed.  Probably bad scale constant!

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
    func_epilogue
    func_ret
    func_end

; Decodes a scale constant into an integer describing the size of each
; item in an array.
;
; __stdcall int DetermineArrayElemSize(scale_constant, capid)
determine_array_elem_size:  ; HEADER: AUTO
    func_begin
    func_arg  %$scale_const, %$capid
    func_prologue  esi, edi

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

    func_epilogue
    func_ret
    func_end

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
    func_begin
    func_arg  %$struct_base, %$structid, %$old_ptr
    func_local  %$data_entry
    func_local  %$new_ptr
    func_local  %$old_array_loc
    func_local  %$new_array_loc
    func_local  %$old_offset_into_array
    func_local  %$elem_size
    func_prologue  esi, edi
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
    add  eax, [%$struct_base]
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

    ; Was it pointerized?
    test dword [%$reg_region_data + RegionData.flags], _REGION_FLAG_POINTERIZED
    jz   .withinregion.notpointerized

.withinregion.pointerized:
    test dword [%$struct_base], -1
    jz   .cannotpointerize  ; we're working with offsets so we can't dereference

    mov  eax, [%$new_array_loc]
    mov  eax, [eax]  ; follow the pointer at this location
    mov  [%$new_array_loc], eax
    add  eax, [%$old_offset_into_array]
    mov  [%$new_ptr], eax

.withinregion.notpointerized:
    ; Are we within the first item?
    mov  eax, [%$old_ptr]
    sub  eax, [%$reg_region_data + RegionData.start]
    sub  eax, [%$struct_base]
    cmp  eax, [%$elem_size]
    jl   .done  ; inside first item; nothing more to do

    ; Are we within the last item?
    mov  eax, [%$reg_region_data + RegionData_size + RegionData.start]
    add  eax, [%$struct_base]
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
.cannotpointerize:
    die  ; requested a pointerized address when struct_base is null

.done:
    mov  eax, [%$new_ptr]
    func_epilogue
    func_ret
    func_end

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
    func_begin
    func_arg  %$old_value
    func_arg  %$new_value
    func_arg  %$list
    func_prologue  esi, edi

    mov  eax, [%$list]
    mov  eax, [eax]  ; read list type
    add  dword [%$list], 0x4  ; point to whitelist/blacklist contents

    cmp  eax, WHITELIST_BEGIN
    je   .has_whitelist
    cmp  eax, BLACKLIST_BEGIN
    je   .has_blacklist

    die  ; list has invalid format

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
    func_epilogue
    func_ret
    func_end

; Replaces all instances of a sequence of bytes in an address range.
; If the beginning of a match is in the blacklist, it is not replaced.
; (because it's easy to make mistakes in the blacklist, all addresses in it are
;  also verified to actually contain this integer)
;
; Returns a pointer pointing to after the end of the blacklist. (after the 0)
;
; SearchNReplace(start*, end*, pattern*, replacement*, pattern_len, blacklist*)
search_n_replace:  ; HEADER: AUTO
    func_begin
    func_arg  %$current
    func_arg  %$end
    func_arg  %$pattern
    func_arg  %$repl
    func_arg  %$length
    func_arg  %$blacklist
    func_prologue  esi, edi

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
    die
.goodblacklist:
    ; caller will want to know where blacklist ends because there's more data after it
    mov  eax, [%$blacklist]
    add  eax, 0x4
    func_epilogue
    func_ret
    func_end

; Replaces specified instances of a sequence of bytes.
;
; ReplaceWithWhitelist(pattern*, replacement*, pattern_len, whitelist*)
replace_with_whitelist:  ; HEADER: AUTO
    func_begin
    func_arg  %$pattern, %$repl, %$length, %$whitelist
    func_prologue esi, edi
    %define %$target esi
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

    func_epilogue
    func_ret
    func_end

; Replace instances in .text of a range of offsets into a struct.
; Returns a pointer to after the end of the blacklist or whitelist.
;
; __stdcall void* PerformDwordRangeReplacement(structid, range_start, range_end, bwlist**)
perform_dword_range_replacement:  ; HEADER: AUTO
    func_begin
    func_arg %$structid, %$range_start, %$range_end, %$whitelist
    func_local %$old_value, %$new_value
    func_prologue esi, edi
    %define %$target esi

    mov  eax, [%$whitelist]
    mov  eax, [eax]  ; read list type

    add  dword [%$whitelist], 0x4  ; point to whitelist contents

    cmp  eax, WHITELIST_BEGIN
    je   .has_whitelist

    die  ; blacklist not supported for dword range

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
    die

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
    func_epilogue
    func_ret
    func_end

;=========================================

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
    func_begin
    func_arg %$desired_id
    func_local %$manager
    func_local %$list_node
    func_local %$vm
    func_local %$tail_delay
    func_prologue

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
    func_epilogue
    func_ret
    func_end

;=========================================
; Stuff for TH06-TH08 pointerization

allocate_pointerized_bmgr_arrays:  ; HEADER: AUTO
    func_begin
    func_prologue ebx, edi
    mov  ebx, pointerize_data  ; REWRITE: <codecave:AUTO>
    mov  edi, corefuncs        ; REWRITE: <codecave:AUTO>

    ; Allocate space for the bullets.
    ;
    ; This is not what the original code did (which called default value initializers on a
    ; static bullet array).  And we don't need to worry about calling those initializers
    ; because the bullets are about to be memset to 0 anyways.
    mov  eax, [new_bullet_cap_bigendian]  ; REWRITE: <codecave:bullet-cap>
    bswap eax
    inc  eax  ; plus dummy bullet
    imul eax, [ebx+PointerizeData.bullet_size]
    push eax
    mov  eax, [edi + corefuncs.malloc - corefuncs]
    call eax
    add  esp, 0x4  ; caller cleans stack
    mov  ecx, [ebx+PointerizeData.bullet_array_ptr]
    mov  [ecx], eax

    ; oh and uhhh lasers too cause they're on the same struct
    mov  eax, [new_laser_cap_bigendian]  ; REWRITE: <codecave:laser-cap>
    bswap eax
    imul eax, [ebx+PointerizeData.laser_size]
    push eax
    mov  eax, [edi + corefuncs.malloc - corefuncs]
    call eax
    add  esp, 0x4  ; caller cleans stack
    mov  ecx, [ebx+PointerizeData.laser_array_ptr]
    mov  [ecx], eax
    func_epilogue
    func_ret
    func_end

allocate_pointerized_imgr_arrays:  ; HEADER: AUTO
    func_begin
    func_prologue ebx, edi
    mov  ebx, pointerize_data  ; REWRITE: <codecave:AUTO>
    mov  edi, corefuncs  ; REWRITE: <codecave:AUTO>

    mov  eax, [new_cancel_cap_bigendian]  ; REWRITE: <codecave:cancel-cap>
    bswap eax
    ; inc eax unnecessary because we don't pointerize the dummy item

    imul eax, [ebx+PointerizeData.item_size]
    push eax
    mov  eax, [edi + corefuncs.malloc - corefuncs]
    call eax
    add  esp, 0x4  ; caller cleans stack
    mov  ecx, [ebx+PointerizeData.item_array_ptr]
    mov  [ecx], eax

    ; Technically the original code also called constructors on the items, but there's
    ; no point because the game will memset the array before it ever gets used.

    func_epilogue
    func_ret
    func_end

; __stdcall void ClearPointerizedBulletMgr()
clear_pointerized_bullet_mgr:  ; HEADER: AUTO
    func_begin
    func_local %$bullet_array_size
    func_prologue esi, edi, ebx
    mov  ebx, pointerize_data  ; REWRITE: <codecave:AUTO>

    ; Keep the pointers when the struct is memset to 0.
    mov  eax, [ebx+PointerizeData.bullet_array_ptr]
    push dword [eax]
    mov  eax, [ebx+PointerizeData.laser_array_ptr]
    push dword [eax]

    ; Memset the entire struct (this is the original code)
    mov  ecx, [ebx+PointerizeData.bullet_mgr_size]
    mov  edi, [ebx+PointerizeData.bullet_mgr_base]
    xor  eax, eax
    rep stosb

    mov  eax, [ebx+PointerizeData.laser_array_ptr]
    pop  dword [eax]
    mov  eax, [ebx+PointerizeData.bullet_array_ptr]
    pop  dword [eax]

    ; we also have to memset our arrays now, too
    mov  ecx, [new_bullet_cap_bigendian]  ; REWRITE: <codecave:bullet-cap>
    bswap ecx
    inc  ecx  ; plus dummy bullet
    imul ecx, [ebx+PointerizeData.bullet_size]
    mov  [%$bullet_array_size], ecx
    mov  edi, [ebx+PointerizeData.bullet_array_ptr]
    mov  edi, [edi]
    xor  eax, eax
    rep stosb

    mov  ecx, [new_laser_cap_bigendian]  ; REWRITE: <codecave:laser-cap>
    bswap ecx
    imul ecx, [ebx+PointerizeData.laser_size]
    mov  edi, [ebx+PointerizeData.laser_array_ptr]
    mov  edi, [edi]
    xor  eax, eax
    rep stosb

    ; set the sentinel state on the dummy bullet (our other binhacks aren't enough to make this happen).
    cmp  dword [ebx+PointerizeData.bullet_state_offset], 0
    jl   .nodummy  ; TH06 has no dummy bullet
    mov  edi, [ebx+PointerizeData.bullet_array_ptr]
    mov  edi, [edi]  ; pointer to array
    add  edi, [%$bullet_array_size]  ; pointer to AFTER dummy bullet
    sub  edi, [ebx+PointerizeData.bullet_size]  ; pointer to dummy bullet
    add  edi, [ebx+PointerizeData.bullet_state_offset]  ; pointer to dummy's state field
    mov  ax, word [ebx+PointerizeData.bullet_state_dummy_value]
    mov  word [edi], ax
.nodummy:

    func_epilogue
    func_ret
    func_end

clear_pointerized_item_mgr:  ; HEADER: AUTO
    func_begin
    func_prologue esi, edi, ebx
    mov  ebx, pointerize_data  ; REWRITE: <codecave:AUTO>

    ; Save the pointer before we zero it!
    mov  eax, [ebx+PointerizeData.item_array_ptr]
    push dword [eax]

    ; Zero the struct, like the original code
    mov  edi, [ebx+PointerizeData.item_mgr_base]
    mov  ecx, [ebx+PointerizeData.item_mgr_size]
    xor  eax, eax
    rep stosb

    mov  eax, [ebx+PointerizeData.item_array_ptr]
    pop  dword [eax]

    ; ...and zero our array
    push CAPID_CANCEL
    call get_new_cap  ; REWRITE: [codecave:AUTO]
    mov  ecx, eax
    imul ecx, [ebx+PointerizeData.item_size]
    mov  edi, [ebx+PointerizeData.item_array_ptr]
    mov  edi, [edi]
    xor  eax, eax
    rep stosb

    func_epilogue
    func_ret
    func_end

; ----------------
; Functions for getting the pointerized arrays, which guarantee that only eax is modified.
; For use in extremely simple codecaves.
;
; (they don't save very many lines in the binhacks themselves, but they're factored out
;  so that binhacks don't directly mention any specific offsets into PointerizeData,
;  which would require mass updates by hand whenever the struct's layout changes)

get_pointerized_bullet_array_eax:  ; HEADER: AUTO
    mov  eax, pointerize_data  ; REWRITE: <codecave:AUTO>
    mov  eax, [eax+PointerizeData.bullet_array_ptr]
    mov  eax, [eax]
    ret

get_pointerized_laser_array_eax:  ; HEADER: AUTO
    mov  eax, pointerize_data  ; REWRITE: <codecave:AUTO>
    mov  eax, [eax+PointerizeData.laser_array_ptr]
    mov  eax, [eax]
    ret

;=========================================

get_VirtualProtect:  ; HEADER: AUTO
    func_begin
    func_prologue

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
    jmp  .done

.error:
    mov  eax, iat_funcs  ; REWRITE: <codecave:AUTO>
    mov  eax, [eax + iat_funcs.GetLastError - iat_funcs]
    call [eax]
    die

.done:
    func_epilogue
    func_ret
    func_end

;=========================================
; Utils

; Returns 0 if data at `a` == data at `b`, nonzero otherwise.
; (sign of nonzero outputs is unspecified because I'm too lazy to verify whether it matches memcmp)
; __stdcall MemCompare(a*, b*, len)
mem_compare:  ; HEADER: AUTO
    func_begin
    func_arg %$str_a, %$str_b, %$length
    func_prologue esi, edi

    mov  edi, [%$str_a]
    mov  esi, [%$str_b]
    mov  ecx, [%$length]
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
    func_epilogue
    func_ret
    func_end

; __stdcall MemcpyOrBust(dest*, src*, len)
memcpy_or_bust:  ; HEADER: AUTO
    func_begin
    func_arg %$dest, %$source, %$length
    func_local %$VirtualProtect, %$old_protect
    func_prologue esi, edi

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

    func_epilogue
    func_ret
    func_end

;=========================================
