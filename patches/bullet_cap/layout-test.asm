%define TEST_OLD_CAP_1 0x3
%define TEST_NEW_CAP_1 0x4
%define TEST_OLD_CAP_2 0x5
%define TEST_NEW_CAP_2 0x3
%define TEST_SIZE_1 0x8
%define TEST_SIZE_2 0x4
%define TEST_SIZE_2_ALT 0xc  ; for an array that uses SCALE_FIXED

; The layout code is pretty complicated, and, at present, underutilized.
; There's 
;
; ...unfortunately, it is difficult to factor out the reliance of some of this
; patches' code on global lookup functions (see e.g. `get_cap_data`), so we take
; the cop-out strategy of adding our test data to these functions.
;
; In other words, these tests are very much the opposite of being self-contained
; and modular, but *by golly* were they necessary.

struc OldStruct
    ; have a variety of inline arrays and pointerized arrays
    .start: resb 0x44
    .second_region: resb 0x20
    .array_1: resb TEST_SIZE_1 * TEST_OLD_CAP_1
    .array_2: resb TEST_SIZE_2_ALT * TEST_OLD_CAP_2
    .after_arrays: resb 0x4
    .pointerized: resb TEST_SIZE_1 * TEST_OLD_CAP_1
    .after_pointerized: resb 0x20
endstruc

struc NewStruct
    .start: resb 0x44
    .second_region: resb 0x20
    .array_1: resb TEST_SIZE_1 * TEST_NEW_CAP_1
    .array_2: resb TEST_SIZE_2_ALT * TEST_NEW_CAP_2
    .after_arrays: resb 0x4
    .pointerized: resb TEST_SIZE_1 * TEST_OLD_CAP_1  ; old cap because pointerized
    .after_pointerized: resb 0x20
endstruc

the_worlds_saddest_unit_test:  ; HEADER: AUTO

; Returned by get_struct_data for structid = __STRUCT_TEST
.layout:
istruc LayoutHeader
    at LayoutHeader.location, dd LOCATION_STATIC(0)  ; unused
    at LayoutHeader.offset_to_replacements, dd 0  ; unused
iend
    dd REGION_NORMAL(OldStruct.start)
    dd REGION_NORMAL(OldStruct.second_region)
    dd REGION_ARRAY(OldStruct.array_1, __CAPID_TEST_1, SCALE_SIZE)
    dd REGION_ARRAY(OldStruct.array_2, __CAPID_TEST_2, SCALE_FIXED(TEST_SIZE_2_ALT))
    dd REGION_NORMAL(OldStruct.after_arrays)
    dd REGION_ARRAY_POINTERIZED(OldStruct.pointerized, __CAPID_TEST_1, SCALE_SIZE)
    dd REGION_NORMAL(OldStruct.after_pointerized)
    dd REGION_END(OldStruct_size)

; Returned by get_cap_data for capid = __CAPID_TEST_1
.capdata_1:
istruc ListHeader
    at ListHeader.old_cap, dd TEST_OLD_CAP_1
    at ListHeader.elem_size, dd TEST_SIZE_1
iend
    dd TEST_NEW_CAP_1

; Returned by get_cap_data for capid = __CAPID_TEST_2
.capdata_2:
istruc ListHeader
    at ListHeader.old_cap, dd TEST_OLD_CAP_2
    at ListHeader.elem_size, dd TEST_SIZE_2
iend
    dd TEST_NEW_CAP_2

; Test runner
.code:
    func_begin
    func_prologue ebx, esi, edi
    %define %$reg_corefuncs edi
    %define %$reg_struct esi
    %define %$reg_pointerized_array ebx
    mov  %$reg_corefuncs, corefuncs  ; REWRITE: <codecave:AUTO>

    ; Create the struct based on the new caps
    push NewStruct_size
    call_eax [%$reg_corefuncs + corefuncs.malloc - corefuncs]
    mov  %$reg_struct, eax
    add  esp, 0x4  ; caller cleans stack

    push TEST_SIZE_1 * TEST_NEW_CAP_1
    call_eax [%$reg_corefuncs + corefuncs.malloc - corefuncs]
    mov  %$reg_pointerized_array, eax
    add  esp, 0x4  ; caller cleans stack

    ; Set pointers
    mov  [%$reg_struct + NewStruct.pointerized], %$reg_pointerized_array

.unit_tests:
    %xdefine %$reg_line_no %$reg_corefuncs
    %undef %$reg_corefuncs
    %macro run_test_eax_ecx 0
        mov  %$reg_line_no, __LINE__
        call .do_test_eax_ecx
    %endmacro

    ; beginning of struct
    mov  eax, %$reg_struct
    mov  ecx, %$reg_struct
    run_test_eax_ecx

    ; offset into normal fields
    lea  eax, [%$reg_struct + 0x10]
    lea  ecx, [%$reg_struct + 0x10]
    run_test_eax_ecx

    ; region after first
    lea  eax, [%$reg_struct + OldStruct.second_region]
    lea  ecx, [%$reg_struct + NewStruct.second_region]
    run_test_eax_ecx

    ; offset into first item of array
    lea  eax, [%$reg_struct + OldStruct.array_1 + 0x4]
    lea  ecx, [%$reg_struct + NewStruct.array_1 + 0x4]
    run_test_eax_ecx

    ; offset into last item of array
    lea  eax, [%$reg_struct + OldStruct.array_2 - 0x4]
    lea  ecx, [%$reg_struct + NewStruct.array_2 - 0x4]
    run_test_eax_ecx

    ; first item of array with different cap and unusual item size
    lea  eax, [%$reg_struct + OldStruct.array_2]
    lea  ecx, [%$reg_struct + NewStruct.array_2]
    run_test_eax_ecx

    ; last item of array with different cap and unusual item size
    lea  eax, [%$reg_struct + OldStruct.after_arrays - 0x4]
    lea  ecx, [%$reg_struct + NewStruct.after_arrays - 0x4]
    run_test_eax_ecx

    ; fields after two arrays of different sizes
    lea  eax, [%$reg_struct + OldStruct.after_arrays]
    lea  ecx, [%$reg_struct + NewStruct.after_arrays]
    run_test_eax_ecx

    ; beginning of pointerized array
    lea  eax, [%$reg_struct + OldStruct.pointerized]
    lea  ecx, [%$reg_struct + NewStruct.pointerized]
    mov  ecx, [ecx]
    run_test_eax_ecx

    ; nonzero offset into first item of pointerized array; this is tricky!
    lea  eax, [%$reg_struct + OldStruct.pointerized + 0x4]
    lea  ecx, [%$reg_struct + NewStruct.pointerized]
    mov  ecx, [ecx]
    lea  ecx, [ecx + 0x4]
    run_test_eax_ecx

    ; last item of pointerized array (tests use of scale_inside)
    lea  eax, [%$reg_struct + OldStruct.after_pointerized - 0x4]
    lea  ecx, [%$reg_struct + NewStruct.pointerized]
    mov  ecx, [ecx]
    lea  ecx, [ecx + TEST_SIZE_1 * TEST_NEW_CAP_1 - 0x4]
    run_test_eax_ecx

    ; end of pointerized array: should not follow pointer!
    lea  eax, [%$reg_struct + OldStruct.after_pointerized]
    lea  ecx, [%$reg_struct + NewStruct.after_pointerized]
    run_test_eax_ecx

    ; end of struct
    lea  eax, [%$reg_struct + OldStruct_size]
    lea  ecx, [%$reg_struct + NewStruct_size]
    run_test_eax_ecx

    ; NOTE:  The allocations are leaked because (a) this only runs once
    ;        and (b) I don't wanna look up the address of `free` in 17 games
    func_epilogue
    func_ret

; eax = input,  ecx = expected
.do_test_eax_ecx:
    push ecx ; save

    push %$reg_struct
    push eax  ; old field ptr
    push __STRUCT_TEST
    call override__adjust_field_ptr  ; REWRITE: [codecave:base-exphp.adjust-field-ptr]
    pop  ecx ; restore
    cmp  eax, ecx
    je   .test_ok
    die  ; if you hit this, check edi for the test's line number
.test_ok:
    ret  ; not func_ret because this is an inner function

    func_end
