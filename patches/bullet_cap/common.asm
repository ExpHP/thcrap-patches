struc ListHeader  ; DELETE
    ; "old cap" should be whatever the maximum amount is of something in the vanilla game,
    ; regardless of the length of the underlying array. (e.g. in TH10 the bullet array
    ; has 0x2001 bullets but it can only spawn 0x2000, so you would write 0x2000).
    .old_cap: resd 1  ; old cap  ; DELETE
    .elem_size: resd 1  ; size in bytes of each array item.  If they don't live in an array you can just put 0.  ; DELETE
    .list:  ; list of replacements  ; DELETE
endstruc  ; DELETE

; Each entry in the list of replacements begins with a dword-sized value to replace,
; followed by one of the following:
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
endstruc
