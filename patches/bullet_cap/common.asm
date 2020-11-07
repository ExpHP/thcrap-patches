; IDs for global structs that can be affected by this mod.
%define STRUCT_BULLET_MGR  0x100
%define STRUCT_ITEM_MGR    0x101
%define __STRUCT_TEST      0x200

; IDs for the modifiable caps.
%define CAPID_BULLET   0x300
%define CAPID_LASER    0x301
%define CAPID_CANCEL   0x302
%define __CAPID_TEST_1 0x400
%define __CAPID_TEST_2 0x401

; =============================
;        CAP SPECS
; =============================
%define NOT_APPLICABLE  -0x50506060

struc GlobalCapEntry
    .capid: resd 1  ; The capid for this cap
    .game_data_cave: resd 1  ; Pointer to cave containing ListHeader
    .game_data_offset: resd 1  ; Offset to ListHeader within cave
    .new_cap_bigendian_codecave: resd 1  ; Pointer to old, bigendian config cave, or NOT_APPLICABLE
    .new_cap_test_value: resd 1  ; A fixed value for a test cap, or NOT_APPLICABLE
endstruc

struc ListHeader
    ; "old cap" should be whatever the maximum amount is of something in the vanilla game,
    ; regardless of the length of the underlying array. (e.g. in TH10 the bullet array
    ; has 0x2001 bullets but it can only spawn 0x2000, so you would write 0x2000).
    .old_cap: resd 1  ; old cap
    .elem_size: resd 1  ; size in bytes of each array item.  If they don't live in an array this will never be needed and you can put 0.
    .list:  ; list of replacements
endstruc

; =============================
;        CAP CHANGES
; =============================
; Each cap changed by the patch includes a list of values to change.


; Each entry in the list of replacements contains:
; - A value to change.
; - A scale constant (documented below) describing how the value should change in relation to the cap.
; - A whitelist or blacklist.

; ================================
;        STRUCT LAYOUT
; ================================
; Each struct modified by the patch has a layout described how the patch modifies it.
; This layout uses the following types:

struc LayoutHeader
    .offset_to_replacements: resd 1
    .regions: resd 0  ; Array of RegionEntries, followed by _REGION_TOKEN_END.
endstruc

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
%define REGION_ARRAY_POINTERIZED(start, capid, scale)   start, capid, _REGION_FLAG_POINTERIZED, scale, SCALE_FIXED(0)
; Marks the struct size as the final offset.
%define REGION_END(end)                                 REGION_NORMAL(end), _REGION_TOKEN_END

; Sentinel used after final offset.
%define _REGION_TOKEN_END   0xabcdefed
; Indicates that a region of the struct has been pointerized
%define _REGION_FLAG_POINTERIZED  0x1

; After that is a list of offsets into the vanilla struct that should be searched
; for and replaced wherever they appear in the code. Each entry consists of:
;
; - A specification of the offset(s) to be replaced, using a REP_* macro.
; - A blacklist or whitelist.
;
; One might wonder, why have lists under structs in addition to lists for each cap?
; The reason is because struct offsets could be affected by more than one array.
; (e.g. if we had a normal item cap and cancel item cap). To handle this properly,
; these lists defer to the struct's layout when replacing values, rather than using
; scale constants.

; Value to be replaced is the given offset.
%define REP_OFFSET(offset)                      REP_OFFSET_BETWEEN(0, offset)
; Value to be replaced is the offset between the fields originally at 'from' and 'to'.
%define REP_OFFSET_BETWEEN(from, to)            _REP_OFFSET_TOKEN, from, to, 1
; Value to be replaced is the number of dwords between the fields originally at 'from' and 'to'.
%define REP_NUM_DWORDS_BETWEEN(from, to)        _REP_OFFSET_TOKEN, from, to, 4
; Replaces all values in the half-open range from start to end, instead of a single value.
; Its purpose is to consolidate whitelists. (it does not even support blacklists!)
%define REP_OFFSET_RANGE(start, end)            _REP_OFFSET_RANGE_TOKEN, start, end
; Useful if the range ends in an array and you want to remap that too I guess.
%define REP_OFFSET_RANGE_INCLUSIVE(start, end)  REP_OFFSET_RANGE(start, end+1)

%define _REP_OFFSET_TOKEN 0x6090
%define _REP_OFFSET_RANGE_TOKEN 0x6091
struc RepOffset
    ; Offset into struct that the offset in question is measured from.  Typically zero,
    ; but e.g. TH15 contains a value '-0x1f44'  that is the offset of the bullet anm id
    ; array measured relative to the snapshot id array.
    .from: resd 1
    .to: resd 1  ; Offset into struct in vanilla game.
    .divisor: resd 1  ; Value to divide by. E.g. 4 for number of dwords
endstruc
struc RepOffsetRange
    .start: resd 1
    .end: resd 1
endstruc

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
;       SCALE_FIXED(b) :  Maps value as `value -> value + (new_cap - old_cap) * b`.
;                         e.g. LoLK has an array of dwords the same length as the bullet array,
;                         so one would use `SCALE_FIXED(4)` to handle this array.
;
;
; IMPORTANT:  The mappings shown above are for positive original values.  Negative original values are mapped in such a way
;             that smaller caps produce final values closer to zero, so you should still write positive scales.

; Stored as 3 bytes of a dword.
struc ScaleConst
    .size_mult: resb 1
    .one_mult: resb 1
    .divisor: resb 1
    .padding: resb 1
endstruc
%define SCALE_GENERAL(size_mult, one_mult, divisor)  size_mult + one_mult * 0x100 + divisor * 0x10000
%define SCALE_1               SCALE_GENERAL(0, 1, 1)
%define SCALE_SIZE            SCALE_GENERAL(1, 0, 1)
%define SCALE_SIZE_DIV(n)     SCALE_GENERAL(1, 0, n)
%define SCALE_1_DIV(n)        SCALE_GENERAL(0, 1, n)
%define SCALE_FIXED(b)        SCALE_GENERAL(0, b, 1)

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

; ================================
; SPECIALIZED STUFF FOR SOME GAMES
; ================================

struc PointerizeData
    .bullet_mgr_base: resd 1
    .bullet_array_ptr: resd 1
    .laser_array_ptr: resd 1
    .item_mgr_base: resd 1
    .item_array_ptr: resd 1
    .bullet_size: resd 1
    .laser_size: resd 1
    .item_size: resd 1
    .bullet_state_dummy_value: resd 1
    .bullet_state_offset: resd 1
    .bullet_mgr_size: resd 1
    .item_mgr_size: resd 1
endstruc

struc PerfFixData
    .anm_manager_ptr: resd 1
    .world_list_head_offset: resd 1
    .anm_id_offset: resd 1
endstruc

struc ZunList
    .entry: resd 1
    .next: resd 1
    .prev: resd 1
endstruc
