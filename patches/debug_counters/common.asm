
%define COLOR_WHITE       0xffffffff
%define COLOR_NOMINAL     0xffffffff
%define COLOR_WARN        0xfff5782f
%define COLOR_MAX         0xffff3429
%define KIND_ARRAY        1
%define KIND_ANMID        2
%define KIND_FIELD        3
%define KIND_ZERO         4
%define KIND_EMBEDDED     5
%define KIND_LIST         7

; funcs from base-exphp
adjust_bullet_array:  ; DELETE
adjust_laser_array:  ; DELETE
adjust_cancel_array:  ; DELETE

struc ColorData
    .ascii_manager_ptr: resd 1
    .color_offset: resd 1
endstruc

; ================================================
; Stuff for line info

%define LINE_INFO_DONE        0x501
%define LINE_INFO_POSITIONING 0x502
%define LINE_INFO_ENTRY       0x503

struc LineInfoPositioning
    .pos: resd 3       ; Float3 position of first line
    .delta_y: resd 1   ; delta y between lines
endstruc

struc LineInfoEntry
    .data_ptr: resd 1  ; pointer to a counter spec
    .fmt_string: resb 12  ; sprintf string for counter
endstruc

; ================================================
; Stuff for counter definitions

; Special value for ArraySpec .field_offset which means to simply read a dword-sized field at zero offset.
%define FIELD_IS_DWORD -67

struc ArraySpec  ; DELETE
    .struct_ptr: resd 1 ; address of (possibly null) pointer to struct that holds the array  ; DELETE
    .limit: resd 2  ; for coloring ; DELETE
    .array_offset: resd 1  ; offset of array in struct  ; DELETE
    .field_offset: resd 1  ; offset of a byte in an array item that is nonzero if and only if the item is in use  ; DELETE
    .stride: resd 1  ; size of each item in the array  ; DELETE
    .adjust_array_func: resd 1  ; func from `base_exphp` that may dereference a pointerified array (0 if none)  ; DELETE
endstruc  ; DELETE

struc FieldSpec  ; DELETE
    .struct_ptr: resd 1  ; DELETE
    .limit: resd 2  ; DELETE
    ; Find these in the function that allocates a laser.
    ; (in the LASER_MANAGER crossrefs, about two down from LaserManager::operator new)
    .count_offset: resd 1  ;  DELETE
endstruc  ; DELETE

struc AnmidSpec  ; DELETE
    .struct_ptr: resd 1  ; DELETE
    .limit: resd 2  ; size of the "fast VM" array.  Technically the number of VMs can surpass this. DELETE
    ; For these, check AnmManager's on_ticks.
    .world_head_ptr_offset: resd 1  ; DELETE
    .ui_head_ptr_offset: resd 1  ; DELETE
    ; Check AnmManager::initialize for the first array it initializes
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

struc ListSpec  ; DELETE
    .struct_ptr: resd 1  ; DELETE
    .limit: resd 2  ; DELETE
    .head_ptr_offset: resd 1  ; DELETE
endstruc  ; DELETE
