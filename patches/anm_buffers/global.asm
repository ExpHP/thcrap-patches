; AUTO_PREFIX: ExpHP.anm-buffers.

%include "common.asm"
%include "util.asm"
%define BATCH_LEN   0x800

game_data:  ; DELETE

state:  ; HEADER: AUTO
istruc State  ; DELETE
    at State.batches_ptr, dd 0
iend  ; DELETE

; __stdcall AnmBatches* GetAnmBatches()
get_batches:  ; HEADER: AUTO
    mov  eax, state  ; REWRITE: <codecave:AUTO>
    mov  eax, [eax+State.batches_ptr]
    test eax, eax
    jnz  .done

    push AnmBatches_size
    mov  eax, game_data  ; REWRITE: <codecave:AUTO>
    call [eax+GameData.func_malloc]
    add  esp, 0x4

    mov  ecx, state  ; REWRITE: <codecave:AUTO>
    mov  [ecx+State.batches_ptr], eax   ; (requires writable codecaves)
.done:
    ret

; Replacement for the "malloc" that normally allocates a VM.  The returned VM is uninitialized,
; and is expected to have its fast_id set to -1 afterwards.
;
; __stdcall AnmVm* AllocVm()
new_alloc_vm:  ; HEADER: AUTO
    prologue_sd
    call get_batches  ; REWRITE: [codecave:AUTO]
    mov  esi, eax

    ; if absolutely everything is used up, allocate a new batch
    mov  eax, [esi+AnmBatches.free_count]
    test eax, eax
    jnz  .noalloc

    call allocate_new_batch  ; REWRITE: [codecave:AUTO]
    ; prepend it
    mov  ecx, eax
    mov  eax, [esi+AnmBatches.first_batch]
    mov  [ecx+AnmBatchHeader.next_batch], eax
    mov  [esi+AnmBatches.first_batch], ecx
    add  dword [esi+AnmBatches.free_count], BATCH_LEN
.noalloc:
    dec  dword [esi+AnmBatches.free_count]

    push esi
    call scroll_to_free_batch  ; REWRITE: [codecave:AUTO]

    push dword [esi+AnmBatches.first_batch]
    call take_free_vm_from_batch  ; REWRITE: [codecave:AUTO]

    epilogue_sd
    ret

; __stdcall AnmBatchHeader* AllocateNewBatch()
allocate_new_batch:  ; HEADER: AUTO
    prologue_sd
    ; compute size of allocation
    mov  edi, game_data  ; REWRITE: <codecave:AUTO>
    mov  eax, [edi+GameData.vm_size]  ; vms...
    add  eax, BatchVmPrefix_size      ; each with metadata...
    imul eax, BATCH_LEN               ; in an array...
    add  eax, AnmBatchHeader_size     ; ...at the end of a larger struct.
    push eax
    call [edi+GameData.func_malloc]
    add  esp, 0x4
    mov  esi, eax

    mov  dword [esi+AnmBatchHeader.free_count], BATCH_LEN
    mov  dword [esi+AnmBatchHeader.next_batch], 0
    mov  dword [esi+AnmBatchHeader.next_index], 0

    ; initialize metadata for all array VMs.  (don't need to do anything for the VMs,
    ; the game will do that as each one is used)
    lea  eax, [esi+AnmBatchHeader.vms]
    mov  ecx, BATCH_LEN
.iter:
    dec  ecx
    js   .done
    mov  dword [eax+BatchVmPrefix.in_use], 0
    mov  dword [eax+BatchVmPrefix.batch], esi
    add  eax, [edi+GameData.vm_size]
    add  eax, BatchVmPrefix_size
    jmp  .iter
.done:
    mov  eax, esi
    epilogue_sd
    ret

; Precondition: There exists at least one batch with at least one free VM.
; Postcondition: The first batch in the list has at least one free VM.
;                This is accomplished by moving any fully occupied batches to the back.
;
; __stdcall AnmBatchHeader* ScrollToFreeBatch(AnmBatches*)
scroll_to_free_batch:  ; HEADER: AUTO
    mov  ecx, [esp+0x4]
    mov  edx, [ecx+AnmBatches.last_batch]  ; invariant: always points to new tail
    mov  ecx, [ecx+AnmBatches.first_batch]  ; invariant: always points to new head
.iter:
    mov  eax, [ecx+AnmBatchHeader.free_count]
    test eax, eax
    jnz  .done
    mov  [edx+AnmBatchHeader.next_batch], ecx
    mov  edx, ecx
    mov  ecx, [ecx+AnmBatchHeader.next_batch]
    mov  dword [edx+AnmBatchHeader.next_batch], 0
    jmp  .iter
.done:
    mov  eax, [esp+0x4]
    mov  [eax+AnmBatches.last_batch], edx
    mov  [eax+AnmBatches.first_batch], ecx
    ret 0x4

; Given a batch with at least one free VM, select a VM to use from this batch
; and update any bookkeeping on the batch object and VM.
;
; __stdcall AnmBatchHeader* ScrollToFreeBatch(AnmBatchHeader*)
take_free_vm_from_batch:  ; HEADER: AUTO
    prologue_sd
    mov  esi, [ebp+0x08]
    mov  edx, game_data  ; REWRITE: <codecave:AUTO>

.iter:
    ; get vm at index
    mov  ecx, [edx+GameData.vm_size]
    add  ecx, BatchVmPrefix_size
    imul ecx, [esi+AnmBatchHeader.next_index]
    lea  ecx, [esi+AnmBatchHeader.vms + ecx]
    ; update next index
    inc  dword [esi+AnmBatchHeader.next_index]
    cmp  dword [esi+AnmBatchHeader.next_index], BATCH_LEN
    jl   .nowrap
    mov  dword [esi+AnmBatchHeader.next_index], 0
.nowrap:
    ; check if free
    mov  eax, [ecx+BatchVmPrefix.in_use]
    test eax, eax
    jnz  .iter
.done:
    mov  dword [ecx+BatchVmPrefix.in_use], 1
    lea  eax, [ecx+BatchVmPrefix.vm]
    epilogue_sd
    ret 0x4

; Replacement for the call to `free` that normally occurs when destroying a VM whose fast_id is -1.
;
; __stdcall void DeallocVm(AnmVm*)
new_dealloc_vm:  ; HEADER: AUTO
    ; If this function is being called, the VM must be part of a batch, so let's access the metadata.
    mov  eax, [esp+0x04]
    lea  eax, [eax-BatchVmPrefix.vm]  ; metadata before the vm

    mov  dword [eax+BatchVmPrefix.in_use], 0
    mov  ecx, [eax+BatchVmPrefix.batch]
    inc  dword [ecx+AnmBatchHeader.free_count]

    call get_batches  ; REWRITE: [codecave:AUTO]
    inc  dword [eax+AnmBatches.free_count]
    ret
