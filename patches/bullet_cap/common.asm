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
;              SCALE_1 :  The value should be adjusted as  `value -> value + (new_cap - old_cap)`.
;                         Used on array sizes and iteration counts.
;
;           SCALE_SIZE :  The value should be adjusted as  `value -> value + (new_cap - old_cap) * elem_size`.
;                         Typically used for byte offsets of things after the array.
;
;    SCALE_SIZE_DIV(n) :  The value should be adjusted as  `value -> value + (new_cap - old_cap) * elem_size / n`.
;                         Needed to handle things like `rep stosd`.

%define SCALE_1           0
%define SCALE_SIZE        1
%define SCALE_SIZE_DIV(n) n

; After that is either a whitelist of addresses to replace, or a blacklist of addresses to NOT replace.

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
