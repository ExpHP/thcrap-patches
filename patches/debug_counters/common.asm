
; the drawf function that is only used by FpsCounter and DebugSprtView
%define DRAWF_DEBUG       0x401690
%define COLOR_WHITE       0xffffffff
%define COLOR_NOMINAL     0xffffffff
%define COLOR_WARN        0xfff5782f
%define COLOR_MAX         0xffff3429
%define KIND_ARRAY        1
%define KIND_ANMID        2
%define KIND_LASER        3

struc ArraySpec  ; DELETE
    .struct_ptr: resd 1 ; address of (possibly null) pointer to struct that holds the array  ; DELETE
    .length_is_addr: resd 1  ; boolean.  If 1, the array_length field is an address where length can be found (to support bullet_cap patch)  ; DELETE
    .array_length: resd 1  ; number of items in the array  ; DELETE
    .array_offset: resd 1  ; offset of array in struct  ; DELETE
    .field_offset: resd 1  ; offset of a byte in an array item that is nonzero if and only if the item is in use  ; DELETE
    .stride: resd 1  ; size of each item in the array  ; DELETE
endstruc  ; DELETE

struc LaserSpec  ; DELETE
    .struct_ptr: resd 1  ; DELETE
    .count_offset: resd 1  ; DELETE
    .limit_addr: resd 1  ; DELETE
endstruc  ; DELETE

struc AnmidSpec  ; DELETE
    .struct_ptr: resd 1  ; DELETE
    .world_head_ptr_offset: resd 1  ; DELETE
    .ui_head_ptr_offset: resd 1  ; DELETE
    .num_fast_vms: resd 1  ; size of the "fast VM" array.  Technically the number of VMs can surpass this. DELETE
endstruc  ; DELETE
