; AUTO_PREFIX: ExpHP.anm-buffers.

%include "common.asm"
%include "util.asm"

game_data:  ; HEADER: AUTO
    dd 0  ; default definition, overriden per-game

layer_data:  ; HEADER: AUTO
    dd 0  ; default definition, overriden per-game

state:  ; HEADER: AUTO
istruc State  ; DELETE
    at State.batches_ptr, dd 0
iend  ; DELETE

; Get the AnmBatches singleton, allocating it if it doesn't exist.
;
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
    mov  dword [ecx+AnmBatches.draw_write_batch], 0xdeadbeef
    mov  dword [ecx+AnmBatches.draw_write_index], 0xdeadbeef
    mov  dword [ecx+AnmBatches.num_to_draw], 0xdeadbeef
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

; ==============================================================================

; An experimental optimized search-by-id function.
;
; Performance characteristics compared to vanilla:
;
; - Is SIGNIFICANTLY FASTER than vanilla for large numbers of VMs.  This is thanks to the drastic reduction
;   in number of cache misses that occur while searching batches beyond the first batch.
;
; - Can be SIGNIFICANTLY SLOWER than vanilla for large numbers of calls per frame, in games where the
;   patch must disable the game's own built-in "fast path".  This is because it is particularly slow
;   to search through the batch that's currently being modified.
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

; A slow search through the active batch.
;
; Why must this be so slow, you ask?  Well, unlike inactive batches, the active batch does not
; have a cached array of IDs because we'd have to keep updating it.
;
; (why not simply update it in sync with the VMs as they are allocated? Because it'd require too
;  many binhacks; the game doesn't assign an ID until LONG after it has allocated a VM, and there
;  are several functions where it does this)
;
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
    func_begin
    func_arg %$batch, %$id
    func_prologue edi, esi
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
    func_epilogue
    func_ret
    func_end

; ==============================================================================
; TH18 PERF FIXES

; After various profiling tests, the issue with performance in TH18 appears to be that the on_draw functions
; for drawing each layer are incurring tons of cache misses as they iterate through the entire on_tick lists.
; (While this doesn't come as much of a surprise, at this time it is not entirely understood why the same
; problem isn't witnessed to this extent in TH17...)
;
; In any case, we optimize this by performing a SINGLE scan across the linked list each tick to build
; a cache-friendly batched array of the data needed by the on_draws, and then we scan that array for each layer.
;
; In UM, this reduces the total number of linked list scans from 46 per tick (45 on_draws + 1 on_tick)
; to just 2 per tick (1 on_draw + 1 on_tick).
;
; NOTE: Using this currently REQUIRES that the vanilla "fast path" for VM allocation is disabled
;       to ensure that there is a sufficient number of batches to hold the array.

; __stdcall void BuildFastLayerArray(AnmManager*)
rebuild_layer_array:  ; HEADER: AUTO
    func_begin
    func_arg  %$anm_manager
    func_local %$game_data, %$layer_data, %$batches
    func_prologue esi, edi, ebx

    %define %$reg_layer_data esi
    mov  %$reg_layer_data, layer_data  ; REWRITE: <codecave:AUTO>

    call get_batches  ; REWRITE: [codecave:AUTO]
    mov  [%$batches], eax

    push dword [%$batches]
    call clear_draw_array  ; REWRITE: [codecave:AUTO]

    mov  eax, [%$anm_manager]
    add  eax, [%$reg_layer_data + GameLayerData.world_list_offset]
    push dword [eax]
    push dword 0  ; is_ui
    push dword [%$batches]
    call add_list_to_draw_array  ; REWRITE: [codecave:AUTO]

    mov  eax, [%$anm_manager]
    add  eax, [%$reg_layer_data + GameLayerData.ui_list_offset]
    push dword [eax]
    push dword 1  ; is_ui
    push dword [%$batches]
    call add_list_to_draw_array  ; REWRITE: [codecave:AUTO]

    func_epilogue
    func_ret
    func_end

; __stdcall void ClearDrawArray(AnmBatches*)
clear_draw_array:  ; HEADER: AUTO
    func_begin
    func_arg  %$batches
    func_prologue

    mov  ecx, [%$batches]
    mov  eax, [ecx + AnmBatches.active_batch]
    mov  dword [ecx + AnmBatches.draw_write_batch], eax
    mov  dword [ecx + AnmBatches.draw_write_index], 0
    mov  dword [ecx + AnmBatches.num_to_draw], 0

    func_epilogue
    func_ret
    func_end

; __stdcall void AddToDrawArray(AnmBatches*, int is_ui, AnmVmList*)
add_list_to_draw_array:  ; HEADER: AUTO
    func_begin
    func_arg  %$batches, %$is_ui, %$head
    func_prologue esi, edi, ebx
    %define %$reg_layer_data esi
    %define %$reg_list_node ebx
    mov  %$reg_layer_data, layer_data  ; REWRITE: <codecave:AUTO>
    mov  %$reg_list_node, [%$head]

.iter:
    cmp  %$reg_list_node, 0
    jz   .done

    ; AnmManager::render_layer will skip VMs that have certain flags enabled.  We'll check this ahead
    ; of time and simply leave those VMs out of the array, so that the array doesn't have to contain flags.
    mov  eax, [%$reg_list_node+0x0]  ; vm*
    mov  ecx, [%$reg_layer_data + GameLayerData.flags_hi_offset]
    mov  ecx, [eax+ecx]  ; flags_hi
    test ecx, [%$reg_layer_data + GameLayerData.flags_hi_hide]
    jnz  .skip

    push dword eax  ; vm
    push dword [%$is_ui]
    push dword [%$batches]
    call add_vm_to_draw_array  ; REWRITE: [codecave:AUTO]

.skip:
    mov  %$reg_list_node, [%$reg_list_node+0x4]
    jmp .iter
.done:
    func_epilogue
    func_ret
    func_end

; __stdcall void AddToDrawArray(AnmBatches*, int is_ui, AnmVm*)
add_vm_to_draw_array:  ; HEADER: AUTO
    func_begin
    func_arg  %$batches, %$is_ui, %$vm
    func_local  %$effective_layer
    func_prologue esi, edi
    %define %$reg_layer_data esi
    mov  %$reg_layer_data, layer_data  ; REWRITE: <codecave:AUTO>

    mov  eax, [%$vm]
    mov  ecx, [%$reg_layer_data + GameLayerData.layer_offset]
    mov  eax, [eax+ecx]

    ; The vanilla AnmManager::render_layer transforms each VM's layer number based on which list it is in.
    ; We do this ahead of time, because (a) that's dumb, and (b) this lets us avoid having to record which
    ; list each VM came from.
    push eax
    push dword [%$is_ui]
    call effective_layer  ; REWRITE: [codecave:AUTO]
    mov  [%$effective_layer], eax

    mov  ecx, [%$batches]
    inc  dword [ecx + AnmBatches.num_to_draw]
    cmp  dword [ecx + AnmBatches.draw_write_index], BATCH_LEN
    jne  .no_new_batch

    ; begin writing to a new batch
    mov  eax, [ecx + AnmBatches.draw_write_batch]
    mov  eax, [eax + AnmBatchHeader.next_batch]
    mov  dword [ecx + AnmBatches.draw_write_batch], eax
    mov  dword [ecx + AnmBatches.draw_write_index], 0

.no_new_batch:
    mov  edx, [ecx + AnmBatches.draw_write_index]
    imul edx, DrawArrayItem_size
    add  edx, AnmBatchHeader.draw_array
    add  edx, [ecx + AnmBatches.draw_write_batch]

    mov  eax, [%$vm]
    mov  dword [edx+DrawArrayItem.vm], eax
    mov  eax, [%$effective_layer]
    mov  dword [edx+DrawArrayItem.layer], eax

    inc  dword [ecx + AnmBatches.draw_write_index]

    func_epilogue
    func_ret
    func_end

; ----------------------------

; __stdcall void FastDrawLayer(int is_ui, int layer)
effective_layer:  ; HEADER: AUTO
    func_begin
    func_arg  %$is_ui, %$layer
    func_local %$delta
    func_prologue esi
    %define %$reg_layer_data esi
    mov  %$reg_layer_data, layer_data  ; REWRITE: <codecave:AUTO>

    mov  eax, [%$reg_layer_data + GameLayerData.ui_layer_start]
    sub  eax, [%$reg_layer_data + GameLayerData.world_ui_layer_start]
    mov  [%$delta], eax

    cmp  dword [%$is_ui], 0
    jne  .ui

.world:
    mov  edx, [%$layer]
    sub  edx, [%$reg_layer_data + GameLayerData.ui_layer_start]
    cmp  edx, [%$reg_layer_data + GameLayerData.ui_layer_count]
    jae  .keep_layer
.world_ui:
    mov  eax, [%$layer]
    sub  eax, [%$delta]
    jmp  .end

; UI VMs:
.ui:
    ; If it's an effective UI world layer, remap to the corresponding UI layer
    mov  edx, [%$layer]
    sub  edx, [%$reg_layer_data + GameLayerData.world_ui_layer_start]
    cmp  edx, [%$reg_layer_data + GameLayerData.ui_layer_count]
    jae  .ui_other
.ui_world:
    mov  eax, [%$layer]
    add  eax, [%$delta]
    jmp  .end
.ui_other:
    ; If it's any other non-UI layer, remap to the default UI layer
    mov  edx, [%$layer]
    sub  edx, [%$reg_layer_data + GameLayerData.ui_layer_start]
    cmp  edx, [%$reg_layer_data + GameLayerData.ui_layer_count]
    jb   .keep_layer
.ui_default:
    mov  eax, [%$reg_layer_data + GameLayerData.ui_layer_default]
    jmp  .end

.keep_layer:
    mov  eax, [%$layer]
.end:
    func_epilogue
    func_ret
    func_end

; Generates arrays of values from EffectiveLayer so you can check that it's working correctly.
;
; __stdcall void DebugEffectiveLayer()
debug_effective_layer:  ; HEADER: AUTO
    func_begin
    func_local
    func_prologue esi, edi, ebx

    sub  esp, 0x300
    mov  edi, esp
    mov  ecx, 0x300
    xor  eax, eax
    rep  stosb

    lea  eax, [esp+0x100]
    push dword 0  ; is_ui
    push eax  ; dest
    call debug_effective_layer_loop  ; REWRITE: [codecave:AUTO]

    lea  eax, [esp+0x200]
    push dword 1  ; is_ui
    push eax  ; dest
    call debug_effective_layer_loop  ; REWRITE: [codecave:AUTO]

    int 3  ;  Now go check esp+0x100 and 0x200

    add esp, 0x300
    func_epilogue
    func_ret
    func_end

; __stdcall void DebugEffectiveLayerLoop(int* dest, int is_ui)
debug_effective_layer_loop:  ; HEADER: AUTO
    func_begin
    func_arg  %$dest, %$is_ui
    func_local %$delta
    func_prologue esi, edi, ebx

    mov  esi, 0
.iter:
    push esi
    push dword [%$is_ui]
    call effective_layer  ; REWRITE: [codecave:AUTO]
    mov  ecx, [%$dest]
    mov  [ecx], eax
    add  dword [%$dest], 4

    inc  esi
    cmp  esi, 50
    jl   .iter
.end:
    func_epilogue
    func_ret
    func_end

; ----------------------------

; __stdcall void FastDrawLayer(AnmManager*, int layer)
fast_draw_layer:  ; HEADER: AUTO
    func_begin
    func_arg  %$anm_manager, %$layer
    func_local %$batches, %$remaining, %$cur_batch, %$index_in_batch, %$cur_entry
    func_prologue edi, esi, ebx
    %define %$reg_layer_data esi
    mov  %$reg_layer_data, layer_data  ; REWRITE: <codecave:AUTO>

    call get_batches  ; REWRITE: [codecave:AUTO]
    mov  [%$batches], eax

    mov  eax, [eax + AnmBatches.active_batch]
    mov  dword [%$cur_batch], eax
    mov  dword [%$index_in_batch], 0
    lea  eax, [eax + AnmBatchHeader.draw_array]
    mov  dword [%$cur_entry], eax

    ; call debug_effective_layer  ; REWRITE: [codecave:AUTO]

    mov  eax, [%$batches]
    mov  eax, [eax + AnmBatches.num_to_draw]
    mov  dword [%$remaining], eax
.iter:
    cmp  dword [%$remaining], 0
    je   .end

    cmp  dword [%$index_in_batch], BATCH_LEN
    jne  .not_next_batch
.next_batch:
    mov  eax, [%$cur_batch]
    mov  eax, [eax + AnmBatchHeader.next_batch]
    mov  dword [%$cur_batch], eax
    mov  dword [%$index_in_batch], 0
    lea  eax, [eax + AnmBatchHeader.draw_array]
    mov  dword [%$cur_entry], eax

.not_next_batch:
    ; Check if this VM should be drawn by us.
    ;
    ; In the vanilla game, the logic in the layer-rendering function is a bit more complicated;
    ; it checks some bitflags on the VM, and it also transforms the layer number of the VM based on which list
    ; it is in before it compares to the expected layer.
    ;
    ; In our case, both of these things are already handled; We filtered based on flags when building the
    ; array, and we already transformed the layer numbers.
    ;
    ; Therefore... simply compare the layer!
    mov  eax, [%$cur_entry]
    mov  eax, [eax + DrawArrayItem.layer]
    cmp  dword [%$layer], eax
    jnz  .nodraw
.draw:
    mov  eax, [%$cur_entry]
    mov  eax, [eax + DrawArrayItem.vm]
    push eax
    mov  ecx, [%$anm_manager]
    mov  eax, [%$reg_layer_data + GameLayerData.func_draw_vm]
    call eax

.nodraw:
    dec  dword [%$remaining]
    inc  dword [%$index_in_batch]
    add  dword [%$cur_entry], DrawArrayItem_size
    jmp  .iter

.end:
    func_epilogue
    func_ret
    func_end
