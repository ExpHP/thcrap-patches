
%define COLOR_WHITE       0xffffffff
%define COLOR_NOMINAL     0xffffffff
%define COLOR_WARN        0xfff5782f
%define COLOR_MAX         0xffff3429
%define KIND_ARRAY        1
%define KIND_ANMID        2
%define KIND_FIELD        3
%define KIND_ZERO         4
%define KIND_EMBEDDED     5
%define POSITIONING_MOF   1
%define POSITIONING_TD    2
%define POSITIONING_DDC   3
%define POSITIONING_IN    4

struc ColorData  ; DELETE
    .ascii_manager_ptr: resd 1  ; DELETE
    .color_offset: resd 1  ; DELETE
    .positioning: resd 1  ; DELETE
endstruc  ; DELETE

struc LineInfoEntry  ; DELETE
    .data_ptr: resd 1  ; DELETE
    .fmt_string: resd 3  ; DELETE
endstruc  ; DELETE

struc ArraySpec  ; DELETE
    .struct_ptr: resd 1 ; address of (possibly null) pointer to struct that holds the array  ; DELETE
    .length_is_addr: resd 1  ; boolean.  If 1, the array_length field is an address where length can be found (to support bullet_cap patch)  ; DELETE
    .length_correction: resd 1  ; when length_is_addr = 1, a correction can be added to the length after it is read from the address  ; DELETE
    .array_length: resd 1  ; number of items in the array  ; DELETE
    .array_offset: resd 1  ; offset of array in struct  ; DELETE
    .field_offset: resd 1  ; offset of a byte in an array item that is nonzero if and only if the item is in use  ; DELETE
    .stride: resd 1  ; size of each item in the array  ; DELETE
endstruc  ; DELETE

struc FieldSpec  ; DELETE
    .struct_ptr: resd 1  ; DELETE
    ; Find these in the function that allocates a laser.
    ; (in the LASER_MANAGER crossrefs, about two down from LaserManager::operator new)
    .count_offset: resd 1  ;  DELETE
    .limit_addr: resd 1  ; DELETE
endstruc  ; DELETE

struc AnmidSpec  ; DELETE
    .struct_ptr: resd 1  ; DELETE
    ; For these, check AnmManager's on_ticks.
    .world_head_ptr_offset: resd 1  ; DELETE
    .ui_head_ptr_offset: resd 1  ; DELETE
    ; Check AnmManager::initialize for the first array it initializes
    .num_fast_vms: resd 1  ; size of the "fast VM" array.  Technically the number of VMs can surpass this. DELETE
endstruc  ; DELETE

; Counter that's always zero
struc ZeroSpec  ; DELETE
    .struct_ptr: resd 1  ; Display the counter whenever this pointer is non-null.  ; DELETE
endstruc  ; DELETE

; Spec that adapts one of the other spec types to a struct that is directly embedded in static memory
; rather than living behind a pointer, for early games.
struc EmbeddedSpec  ; DELETE
    .show_when_nonzero: resd 1  ; display only when this address contains nonzero  ; DELETE
    .struct_base: resd 1  ; base address of struct  ; DELETE
    .spec_kind: resd 1  ; kind constant of .spec field  ; DELETE
    .spec_size: resd 1  ; length of .spec in bytes  ; DELETE
    .spec: ; a spec to delegate to (placed inline), whose first field (.struct_ptr) will be ignored  ; DELETE
endstruc  ; DELETE
