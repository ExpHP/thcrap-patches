
%define ANM_MANAGER_PTR 0x509a20
%define FAST_ARR_SIZE 0x3fff
%define am_compact_arr_ptr 0x1c90a40
%define am_world_compact_head 0x1c90a3c
%define vm_layer 0x18
%define vm_flags_hi 0x534
%define vm_id 0x538

; this resembles the ANM list nodes, but includes stuff
struc CompactEntry
    cpt_vm resd 1
    cpt_layer resd 1
    cpt_flags_hi resd 1
endstruc

binhack_head: ; 0x475bc2
    mov eax, [esi+am_world_compact_head]

binhack_testflag: ; 0x475bd5
    test byte [eax+cpt_flags_hi], 0x60

binhack_read_layer: ; 0x475bde
    mov edx, [eax+cpt_layer]

binhack_prepare_compact_arrays: ; 0x475924
    call   prepare_compact_anm_arrays ; FIXUP

    ; original code
    mov    ecx, dword [esp+0xd4]
    abs_jmp_hack 0x475924

binhack_use_compact_array_head: ; 0x475bc2
    call   get_compact_array ; FIXUP
    mov    ebx, dword [ebp+0x8] ; layer
    cmp    dword [eax], 0

binhack_use_compact_array_fields:
;8B3889C383C310F6400C60
;8b388b5804f6873405000060
    mov    edi, dword [eax+cpt_vm]
    mov    ebx, eax
    add    ebx, CompactEntry_size
    test   byte [eax+cpt_flags_hi], 0x60
    nop
    ; FIXME jne 0x475c00

binhack_next_in_compact_array:
    mov    eax, ebx
    mov    ebx, [ebx+cpt_vm]
    test   ebx, ebx
    jz     .nojmp
    abs_jmp_hack 0x475bd0
.nojmp:
    abs_jmp_hack 0x475c06


; Prepares a compact array of 
; void __stdcall PrepareLayerArray();
prepare_compact_anm_arrays:
    prologue_sd
    mov    esi, [ANM_MANAGER_PTR]
    mov    edi, esi

    ; Point to first world AnmVm's list node
    mov    edi, [esi+0x6dc]

    call   get_compact_array ; FIXUP
    mov    esi, eax

.loop:
    ; esi holds compact array entry, edi holds original node.
    test   edi, edi
    jz     .loopend

    ; Read data from the vm.
    mov    ecx, [edi]
    mov    [esi+cpt_vm], ecx
    mov    eax, [ecx+vm_layer]
    mov    [esi+cpt_layer], eax
    mov    eax, [ecx+vm_flags_hi]
    mov    [esi+cpt_flags_hi], eax

    ; Look at next entry.
    mov    edi, [edi+0x4]
    add    esi, CompactEntry_size
    jmp    .loop

.loopend:
    mov    dword [esi+cpt_vm], 0x0
    epilogue_sd
    ret

get_compact_array:
    prologue_sd
    ; Ensure compact array is allocated.
    ; We place it at the end of the layer list head array (unused as of TH17 1.00b).
    ; There's no need to deallocate it; the ANM manager lives forever.
    mov    ecx, [ANM_MANAGER_PTR]
    mov    eax, [ecx+am_compact_arr_ptr]
    test   eax, eax
    jnz    .noalloc

    ; Large enough to fit the max number of VMs the game can possibly create before
    ; it starts duplicating IDs. (yet still smaller than the AnmManager!)
    push   (0x44000) * CompactEntry_size
    mov    eax, MALLOC
    call   eax
    add    esp, 0x4
    mov    ecx, [ANM_MANAGER_PTR]
    mov    [ecx+am_compact_arr_ptr], eax

.noalloc:
    epilogue_sd
    ret    0x4
