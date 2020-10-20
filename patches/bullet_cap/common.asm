; IDs for global structs that can be affected by this mod.
%define STRUCT_BULLET_MGR  1
%define STRUCT_ITEM_MGR    2

; IDs for the modifiable caps.
%define CAPID_BULLET 0x40
%define CAPID_LASER  0x41
%define CAPID_CANCEL 0x42

; ================================
;        STRUCT LAYOUT
; ================================
; Each struct modified by the patch has a layout described how the patch modifies it.
; This layout uses the following types:

struc LayoutHeader
    .location: resd 1  ; A LOCATION_ constant.
    .is_pointer: resd 1
    .offset_to_replacements: resd 1
    .regions: resd 0  ; Array of RegionEntries, followed by _REGION_TOKEN_END.
endstruc

; Used if struct is located behind a pointer in static memory.
%define LOCATION_PTR(addr)             addr, 1
; Used if struct is directly embedded in static memory.
%define LOCATION_STATIC(addr)          addr, 0

struc RegionData
    .start: resd 1  ; starting offset of this region.
    .capid: resd 1  ; for arrays we resize, the capid that affects its length.
    .flags: resd 1  ; flags that determine how we modify the region.
    .scale_inside: resd 1  ; a scale constant (explained below) to modify offsets with if they are within the region
    .scale_outside: resd 1  ; a scale constant to modify offsets if they are beyond the region
endstruc

; RegionEntry is constructed by one of the following macros:
;
; Indicates a range of fields we don't modify starting at a given offset.
%define REGION_NORMAL(start)                            start, 0, 0, 0, 0
; Indicates an array that we resize starting at a given offset.
%define REGION_ARRAY(start, capid, scale)               start, capid, 0, scale, scale
; Indicates an array that we move behind a pointer and resize, starting at a given offset.
%define REGION_ARRAY_POINTERIFIED(start, capid, scale)  start, capid, _REGION_FLAG_POINTERIFIED, scale, 0
; Marks the struct size as the final offset.
%define REGION_END(end)                                 REGION_NORMAL(end), _REGION_TOKEN_END

; Sentinel used after final offset.
%define _REGION_TOKEN_END   0xabcdefed
; Indicates that a region of the struct has been pointerized
%define _REGION_FLAG_POINTERIFIED  0x1

; After that is a list of offsets to change.  Each entry consists of:

; - An offset to change, or the DWORD_RANGE() macro.
; - A blacklist or whitelist.

; Replaces values in the half-open range from start to end, instead of a single value.
%define DWORD_RANGE(start, end)  DWORD_RANGE_TOKEN, start, end
; Useful if the range ends in an array and you want to remap that too I guess.
%define DWORD_RANGE_INCLUSIVE(start, end)  DWORD_RANGE(start, end+1)
%define DWORD_RANGE_TOKEN -47


; =============================
;        CAP CHANGES
; =============================
; Each cap changed by the patch includes a list of values to change.

struc ListHeader
    ; "old cap" should be whatever the maximum amount is of something in the vanilla game,
    ; regardless of the length of the underlying array. (e.g. in TH10 the bullet array
    ; has 0x2001 bullets but it can only spawn 0x2000, so you would write 0x2000).
    .old_cap: resd 1  ; old cap
    .elem_size: resd 1  ; size in bytes of each array item.  If they don't live in an array this will never be needed and you can put 0.
    .new_cap_bigendian_codecave: resd 1
    .list:  ; list of replacements
endstruc

; Each entry in the list of replacements contains:
; - A value to change.
; - A scale constant describing how the value should change in relation to the cap.
; - A whitelist or blacklist.

; ================================
;        SCALE CONSTANTS
; ================================
;
; Scale constants are used to represent how much a value should change in response to
; a cap being changed.  For instance, the length of an array of bullets would change by
; the bullet size for each difference of 1 in the cap (SCALE_SIZE), whereas a value like
; "the cap plus 1" would only change by 1 for each such difference (SCALE_1).
;
; There are some trickier examples to deal with stuff like 'rep stosd' and unrolled loops.


    ; dd REPL(0xa68, SCALE_1)  ; array size (includes non-cancel items)
    ; dd BLACKLIST_BEGIN
    ; dd 0x429b2a - 4  ; reading a field from a laser
    ; dd 0x435a04 - 4  ; Player::constructor
    ; dd BLACKLIST_END

    ; dd REPL(0x666fc0, SCALE_SIZE)  ; array size
    ; dd REPLACE_ALL

    ; ; offsets of fields after array
    ; dd REPL_OFFSET(0x666fd4)  ; num items alive


; The value to be replaced is followed by a "scale_constant", which is one of the following:
;
;              SCALE_1 :  Maps value as `value -> value + (new_cap - old_cap)`.
;                         Used on array sizes and iteration counts.
;
;           SCALE_SIZE :  Maps value as `value -> value + (new_cap - old_cap) * elem_size`.
;                         Typically used for byte offsets of things after the array.
;
;    SCALE_SIZE_DIV(n) :  Maps value as `value -> value + (new_cap - old_cap) * elem_size / n`.
;                         Needed to handle things like `rep stosd`.
;
;       SCALE_1_DIV(n) :  Maps value as  `value -> value + (new_cap - old_cap) / n`.
;                         Both `old_cap` and `new_cap` must be divisible by `n`. If `new_cap` isn't, a user-facing error is displayed.
;                         This is used to deal with some stupidly-unrolled loops in some games until I have
;                         the time and energy to write more binhacks to un-unroll them.
;
; SCALE_AN_PLUS_B(a,b) :  Maps value as `value -> value + (new_cap - old_cap) * (a * elem_size + b)`.
;                         Necessary because LoLK added more arrays to these structs.
;
;
; IMPORTANT:  The mappings shown above are for positive original values.  Negative original values are mapped in such a way
;             that smaller caps produce final values closer to zero, so you should still write positive scales.

; Stored as 3 bytes of a dword.
struc ScaleConst  ; DELETE
    .size_mult: resb 1  ; DELETE
    .one_mult: resb 1  ; DELETE
    .divisor: resb 1  ; DELETE
    .padding: resb 1  ; DELETE
endstruc  ; DELETE
%define SCALE_GENERAL(size_mult, one_mult, divisor)  size_mult + one_mult * 0x100 + divisor * 0x10000
%define SCALE_1               SCALE_GENERAL(0, 1, 1)
%define SCALE_SIZE            SCALE_GENERAL(1, 0, 1)
%define SCALE_SIZE_DIV(n)     SCALE_GENERAL(1, 0, n)
%define SCALE_1_DIV(n)        SCALE_GENERAL(0, 1, n)
%define SCALE_AN_PLUS_B(a,b)  SCALE_GENERAL(a, b, 1)

; -----------------------

; After the scale expression is either a whitelist of addresses to replace, or a blacklist of addresses to NOT replace.

%define WHITELIST_BEGIN 1
%define WHITELIST_END   0
%define BLACKLIST_BEGIN -1
%define BLACKLIST_END   0
; Synonym for an empty blacklist, since BLACKLIST_BEGIN BLACKLIST_END feels noisy and
; makes it harder to notice the size constant.
%define REPLACE_ALL -1, 0

; After the last entry is LIST_END.

%define LIST_END 0

; ===============================

struc PerfFixData  ; DELETE
    .anm_manager_ptr: resd 1  ; DELETE
    .world_list_head_offset: resd 1  ; DELETE
    .anm_id_offset: resd 1  ; DELETE
endstruc  ; DELETE

struc ZunList  ; DELETE
    .entry: resd 1  ; DELETE
    .next: resd 1  ; DELETE
    .prev: resd 1  ; DELETE
endstruc  ; DELETE
