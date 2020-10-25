; AUTO_PREFIX: ExpHP.anm-buffers.

%include "common.asm"
%include "util.asm"

game_data:  ; HEADER: AUTO
    dd 0  ; default definition, overriden per-game

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

    call allocate_new_batch  ; REWRITE: [codecave:AUTO]
    mov  ecx, state  ; REWRITE: <codecave:AUTO>
    mov  ecx, [ecx+State.batches_ptr]
    mov  dword [ecx+AnmBatches.active_batch], eax
    mov  dword [ecx+AnmBatches.last_batch], eax
    mov  dword [ecx+AnmBatches.free_count], BATCH_LEN
    mov  eax, ecx
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

    ; deactivate this full batch now, because the new one we insert will be active.
    ; (scroll_to_free_batch doesn't handle this because it will see the new active one at front)
    push esi
    call deactivate_active_batch  ; REWRITE: [codecave:AUTO]
    ; prepend a new batch
    call allocate_new_batch  ; REWRITE: [codecave:AUTO]
    mov  ecx, eax
    mov  eax, [esi+AnmBatches.active_batch]
    mov  [ecx+AnmBatchHeader.next_batch], eax
    mov  [esi+AnmBatches.active_batch], ecx
    add  dword [esi+AnmBatches.free_count], BATCH_LEN
.noalloc:
    dec  dword [esi+AnmBatches.free_count]

    push esi
    call scroll_to_free_batch  ; REWRITE: [codecave:AUTO]

    push dword [esi+AnmBatches.active_batch]
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
    add  eax, BatchVmPrefix.vm
    jmp  .iter
.done:
    mov  eax, esi
    epilogue_sd
    ret

; Precondition: There exists at least one batch with at least one free VM.
; Postcondition: The first batch in the list has at least one free VM.
;                This is accomplished by moving any fully occupied batches to the back.
;
; __stdcall void ScrollToFreeBatch(AnmBatches*)
scroll_to_free_batch:  ; HEADER: AUTO
    enter 0x00, 0
.iter:
    mov  ecx, [ebp+0x08]
    mov  eax, [ecx+AnmBatches.active_batch]
    mov  eax, [eax+AnmBatchHeader.free_count]
    test eax, eax
    jnz  .done
    push ecx
    call deactivate_active_batch  ; REWRITE: [codecave:AUTO]
    jmp  .iter
.done:
    leave
    ret 0x4

; __stdcall void DeactivateActiveBatch(AnmBatches*)
deactivate_active_batch:  ; HEADER: AUTO
    prologue_sd
    push ebx
    mov  esi, [ebp+0x08]

    ; Move it to the end of the list...
    mov  ecx, [esi+AnmBatches.active_batch]
    mov  edx, [esi+AnmBatches.last_batch]
    mov  [edx+AnmBatchHeader.next_batch], ecx
    mov  edx, ecx
    mov  ecx, [ecx+AnmBatchHeader.next_batch]
    mov  dword [edx+AnmBatchHeader.next_batch], 0
    mov  [esi+AnmBatches.active_batch], ecx
    mov  [esi+AnmBatches.last_batch], edx

    ; ...and gather its anm ids.  (it's now in edx)
    lea  edi, [edx+AnmBatchHeader.ids]
    lea  esi, [edx+AnmBatchHeader.vms]
    lea  esi, [esi+BatchVmPrefix.vm]  ; point to first vm

    mov  edx, game_data  ; REWRITE: <codecave:AUTO>
    add  esi, [edx+GameData.id_offset]  ; point to first id field

    ; stride in edx, count in ecx
    mov  edx, [edx+GameData.vm_size]
    add  edx, BatchVmPrefix_size
    mov  ecx, BATCH_LEN
.iter:
    dec  ecx
    js   .done
    mov  ebx, [esi]
    mov  [edi], ebx
    add  esi, edx
    add  edi, 0x4
    jmp  .iter
.done:
    pop ebx
    epilogue_sd
    ret 0x4

; Given a batch with at least one free VM, select a VM to use from this batch
; and update any bookkeeping on the batch object and VM.
;
; __stdcall AnmBatchHeader* ScrollToFreeBatch(AnmBatchHeader*)
take_free_vm_from_batch:  ; HEADER: AUTO
    prologue_sd
    mov  esi, [ebp+0x08]
    mov  edx, game_data  ; REWRITE: <codecave:AUTO>

    dec  dword [esi+AnmBatchHeader.free_count]
    jns  .no_ded
    int 3  ; no free in this batch
.no_ded:

.iter:
    ; get vm at index
    mov  ecx, [edx+GameData.vm_size]
    add  ecx, BatchVmPrefix.vm
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
    ret 0x4

; An experimental optimized search-by-id function.
; After some more thorough playtesting with ultra patches I should have a better idea of whether
; this is worth the extra trouble. (that said, if you're killing 5000 enemies, this makes
; the difference between several seconds and several minutes!)
;
; (if only we could just throw a std::unordered_map at it and call it a day...)
;
; __stdcall AnmVm* NewSearch(int id)
new_search:  ; HEADER: AUTO
    prologue_sd
    mov  edi, search_batch_for_id  ; REWRITE: <codecave:AUTO>

    call get_batches  ; REWRITE: [codecave:AUTO]
    mov  esi, [eax+AnmBatches.active_batch]
.iter:
    test esi, esi
    jz   .fail

    push dword [ebp+0x08]
    push esi
    call edi
    test eax, eax
    jnz  .succeed

    ; batches after the first can use this much faster function
    mov  edi, search_inactive_batch_for_id  ; REWRITE: <codecave:AUTO>
    mov  esi, [esi+AnmBatchHeader.next_batch]
    jmp  .iter
.fail:
    xor  eax, eax
.succeed:
    epilogue_sd
    ret  0x4

; __stdcall AnmVm* SearchBatchForId(AnmBatchHeader*, int id)
search_batch_for_id:  ; HEADER: AUTO
    prologue_sd
    mov  edx, [ebp+0x08]  ; batch

    lea  esi, [edx+AnmBatchHeader.vms]
    lea  esi, [esi+BatchVmPrefix.vm]  ; point to first vm
    mov  edx, game_data  ; REWRITE: <codecave:AUTO>
    add  esi, [edx+GameData.id_offset]  ; point to first id field

    ; stride in edx, count in ecx, target in eax
    mov  edx, [edx+GameData.vm_size]
    add  edx, BatchVmPrefix_size
    mov  ecx, BATCH_LEN
    mov  eax, [ebp+0x0c]

.iter:
    dec  ecx
    js   .fail
    cmp  [esi], eax
    je   .succeed
    add  esi, edx
    jmp  .iter
.succeed:
    mov  eax, esi
    mov  edx, game_data  ; REWRITE: <codecave:AUTO>
    sub  eax, [edx+GameData.id_offset]
    jmp  .done
.fail:
    xor  eax, eax
.done:
    epilogue_sd
    ret  0x8

; Searches an inactive batch for an ID.  Inactive batches have saved arrays of IDs,
; leading to far better cache locality and thereby performance.
;
; __stdcall AnmVm* SearchInactiveBatchForId(AnmBatchHeader*, int id)
search_inactive_batch_for_id:  ; HEADER: AUTO
    %push
    prologue_sd
    %define %$batch  ebp+0x08
    %define %$id     ebp+0x0c
    mov  edx, [%$batch]

    ; Fast path for empty batches.
    mov  eax, [edx+AnmBatchHeader.free_count]
    cmp  eax, BATCH_LEN
    je   .fail

    ; We search the array of ids, and just track the VM pointer for convenience.
    lea  edi, [edx+AnmBatchHeader.ids]
    lea  esi, [edx+AnmBatchHeader.vms]
    lea  esi, [esi+BatchVmPrefix.vm]  ; point to first vm

    ; stride in edx, count in ecx, target in eax
    mov  edx, game_data  ; REWRITE: <codecave:AUTO>
    mov  edx, [edx+GameData.vm_size]
    add  edx, BatchVmPrefix.vm
    mov  ecx, BATCH_LEN
    mov  eax, [%$id]

.iter:
    dec  ecx
    js   .fail
    cmp  [edi], eax
    je   .succeed
    add  edi, 0x4
    add  esi, edx
    jmp  .iter
.succeed:
    ; One last thing!  Verify that the VM is still alive.
    ; It would have cleared its id field on death.
    mov  eax, esi
    mov  edx, game_data  ; REWRITE: <codecave:AUTO>
    add  eax, [edx+GameData.id_offset]
    mov  eax, [eax]
    cmp  eax, [%$id]
    jnz  .fail
    ; True success!
    mov  eax, esi
    jmp  .done
.fail:
    xor  eax, eax
.done:
    epilogue_sd
    ret  0x8
