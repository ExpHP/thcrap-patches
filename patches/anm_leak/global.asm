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

    push 0
    call allocate_new_batch  ; REWRITE: [codecave:AUTO]
    mov  ecx, state  ; REWRITE: <codecave:AUTO>
    mov  ecx, [ecx+State.batches_ptr]
    mov  dword [ecx+AnmBatches.active_batch], eax
    mov  dword [ecx+AnmBatches.last_batch], eax
    mov  dword [ecx+AnmBatches.first_batch_created], eax
    mov  dword [ecx+AnmBatches.last_batch_created], eax
    mov  dword [ecx+AnmBatches.batch_count], 1
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
    jnz  .nonewbatch

.newbatch:
    ; deactivate this full batch now, because the new one we insert will be active.
    ; (scroll_to_free_batch doesn't handle this because it will see the new active one at front)
    push esi
    call deactivate_active_batch  ; REWRITE: [codecave:AUTO]

    push esi
    call prepend_new_batch  ; REWRITE: [codecave:AUTO]

.nonewbatch:
    dec  dword [esi+AnmBatches.free_count]

    push esi
    call scroll_to_free_batch  ; REWRITE: [codecave:AUTO]

    push dword [esi+AnmBatches.active_batch]
    call take_free_vm_from_batch  ; REWRITE: [codecave:AUTO]

    epilogue_sd
    ret

; __stdcall AnmBatchHeader* PrependNewBatch(AnmBatches*)
;
; Prepends a new batch and updates all bookkeeping on AnmBatches (but at least
; one batch must already exist).
prepend_new_batch:  ; HEADER: AUTO
    func_begin
    func_arg  %$batches
    func_prologue esi, edi
    %define %$reg_batches esi

    mov %$reg_batches, [%$batches]

    push dword [%$reg_batches + AnmBatches.batch_count]
    call allocate_new_batch  ; REWRITE: [codecave:AUTO]

    inc  dword [%$reg_batches + AnmBatches.batch_count]
    add  dword [%$reg_batches + AnmBatches.free_count], BATCH_LEN
    mov  ecx, eax

    ; prepend to the active list
    mov  eax, [%$reg_batches + AnmBatches.active_batch]
    mov  [ecx + AnmBatchHeader.next_batch], eax
    mov  [%$reg_batches + AnmBatches.active_batch], ecx
    ; append to the creation order list
    mov  eax, [%$reg_batches + AnmBatches.last_batch_created]
    mov  [eax+AnmBatchHeader.next_batch_created], ecx
    mov  [%$reg_batches + AnmBatches.last_batch_created], ecx

    mov  eax, ecx
    func_epilogue
    func_ret
    func_end

; __stdcall AnmBatchHeader* AllocateNewBatch(int creation_order_index)
allocate_new_batch:  ; HEADER: AUTO
    func_begin
    func_arg %$creation_order_index
    func_local %$index
    func_prologue esi, edi
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

    mov  eax, [%$creation_order_index]
    mov  dword [esi+AnmBatchHeader.creation_order_index], eax
    mov  dword [esi+AnmBatchHeader.free_count], BATCH_LEN
    mov  dword [esi+AnmBatchHeader.next_batch], 0
    mov  dword [esi+AnmBatchHeader.next_batch_created], 0
    mov  dword [esi+AnmBatchHeader.next_allocation_index], 0

    ; initialize metadata for all array VMs.  (don't need to do anything for the VMs,
    ; the game will do that as each one is used)
    lea  eax, [esi+AnmBatchHeader.vms]
    mov  ecx, 0
.iter:
    cmp  ecx, BATCH_LEN
    jae  .done
    mov  dword [eax+BatchVmPrefix.our_id], 0
    mov  dword [eax+BatchVmPrefix.last_discriminant], 0
    mov  dword [eax+BatchVmPrefix.index], ecx
    mov  dword [eax+BatchVmPrefix.batch], esi
    add  eax, [edi+GameData.vm_size]
    add  eax, BatchVmPrefix.vm
    inc  ecx
    jmp  .iter
.done:
    mov  eax, esi
    func_epilogue
    func_ret
    func_end

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

    pop ebx
    epilogue_sd
    ret 0x4

; Given a batch with at least one free VM, select a VM to use from this batch
; and update any bookkeeping on the batch object and VM.
;
; __stdcall AnmVm* ScrollToFreeBatch(AnmBatchHeader*)
take_free_vm_from_batch:  ; HEADER: AUTO
    func_begin
    func_arg %$batch
    func_prologue esi, edi
    %define %$reg_batch esi
    %define %$reg_vm_prefix edi

    mov  %$reg_batch, [%$batch]

    dec  dword [%$reg_batch + AnmBatchHeader.free_count]
    jns  .no_ded_1
    die  ; no free in this batch; calling us was a bug!
.no_ded_1:

    push %$reg_batch
    call locate_free_vm_in_batch  ; REWRITE: [codecave:AUTO]
    mov  %$reg_vm_prefix, eax

    ; Assign it an ID in our numbering scheme.  (note: in some games we end up not using this)
    ;
    ; For the most part, the ID is a flattened index into the concatenated array of all batches in creation order.
    mov  eax, [%$reg_batch + AnmBatchHeader.creation_order_index]
    imul eax, BATCH_LEN
    add  eax, [%$reg_vm_prefix + BatchVmPrefix.index]
    mov  [%$reg_vm_prefix + BatchVmPrefix.our_id], eax

    shr  eax, DISCRIMINANT_SHIFT
    and  eax, DISCRIMINANT_MOD_MASK
    jz   .no_ded_2
    ; if we're here, the "index" part of our ID ran into the discriminant.
    ; Perhaps we should have fewer discriminant bits!
    ; (it'd be nice to generate an alert box here, but...)
    die
.no_ded_2:

    ; Similar to the vanilla game, some of the highest bits are used as a discriminant so that dead VMs are not
    ; confused with new ones that have taken their place.
    inc  dword [%$reg_vm_prefix + BatchVmPrefix.last_discriminant]
    and  dword [%$reg_vm_prefix + BatchVmPrefix.last_discriminant], DISCRIMINANT_MOD_MASK
    ; Ensure discriminant is nonzero so that IDs are nonzero.
    jnz  .discriminant_is_nonzero
    inc  dword [%$reg_vm_prefix + BatchVmPrefix.last_discriminant]
.discriminant_is_nonzero:
    mov  eax, [%$reg_vm_prefix + BatchVmPrefix.last_discriminant]
    shl  eax, DISCRIMINANT_SHIFT
    or   [%$reg_vm_prefix + BatchVmPrefix.our_id], eax

    lea  eax, [%$reg_vm_prefix + BatchVmPrefix.vm]
    func_epilogue
    func_ret
    func_end


; Given a batch with at least one free VM, get a pointer to a free entry.
;
; __stdcall BatchVmPrefix* ScrollToFreeBatch(AnmBatchHeader*)
locate_free_vm_in_batch:  ; HEADER: AUTO
    func_begin
    func_arg %$batch
    func_prologue esi, edi
    %define %$reg_game_data edi
    %define %$reg_batch esi
    mov  %$reg_game_data, game_data  ; REWRITE: <codecave:AUTO>
    mov  %$reg_batch, [%$batch]

.iter:
    ; get vm at index
    mov  ecx, [%$reg_game_data + GameData.vm_size]
    add  ecx, BatchVmPrefix.vm
    imul ecx, [%$reg_batch + AnmBatchHeader.next_allocation_index]
    lea  ecx, [%$reg_batch + AnmBatchHeader.vms + ecx]
    ; update next index
    inc  dword [%$reg_batch + AnmBatchHeader.next_allocation_index]
    cmp  dword [%$reg_batch + AnmBatchHeader.next_allocation_index], BATCH_LEN
    jb   .nowrap
    mov  dword [%$reg_batch + AnmBatchHeader.next_allocation_index], 0
.nowrap:
    ; check if free
    mov  eax, [ecx+BatchVmPrefix.our_id]
    test eax, eax
    jnz  .iter
.done:
    mov  eax, ecx
    func_epilogue
    func_ret
    func_end

; ==============================================================================

; Replacement for the call to `free` that normally occurs when destroying a VM whose fast_id is -1.
;
; __stdcall void DeallocVm(AnmVm*)
new_dealloc_vm:  ; HEADER: AUTO
    call get_batches  ; REWRITE: [codecave:AUTO]
    inc  dword [eax+AnmBatches.free_count]

    ; If this function is being called, the VM must be part of a batch, so let's access the metadata.
    mov  eax, [esp+0x04]
    lea  eax, [eax-BatchVmPrefix.vm]  ; metadata before the vm

    mov  dword [eax+BatchVmPrefix.our_id], 0

    mov  edx, [eax+BatchVmPrefix.batch]
    inc  dword [edx+AnmBatchHeader.free_count]
    ret 0x4

; ==============================================================================

; Implementation of a binhack that tells the game to use our IDs instead of its own.
;
; VM must be inside one of our batches.  (can't be in game's own fast array)
;
; __stdcall AnmId AssignOurId(AnmVm*)
assign_our_id:  ; HEADER: AUTO
    func_begin
    func_arg %$vm
    func_prologue esi, edi
    %define %$reg_vm_prefix esi

    ; Get our metadata for the VM.
    mov  eax, [%$vm]
    lea  %$reg_vm_prefix, [eax-BatchVmPrefix.vm]

    mov  edx, game_data  ; REWRITE: <codecave:AUTO>

    mov  ecx, [%$vm]
    add  ecx, [edx + GameData.id_offset]
    mov  eax, [%$reg_vm_prefix + BatchVmPrefix.our_id]
    mov  [ecx], eax

    func_epilogue
    func_ret
    func_end

; ==============================================================================

; __stdcall AnmVm* NewSearch(int id)
new_search:  ; HEADER: AUTO
    func_begin
    func_arg  %$id
    func_local  %$index_in_batch, %$batch_num
    func_prologue esi, edi

    cmp  dword [%$id], 0
    je   .fail

    ; Part without the discriminant is `(batch * BATCH_LEN) + index_in_batch`
    xor  edx, edx
    mov  eax, [%$id]
    and  eax, ~(DISCRIMINANT_MOD_MASK << DISCRIMINANT_SHIFT)  ; zero out the discriminant
    mov  ecx, BATCH_LEN
    div  ecx
    mov  dword [%$batch_num], eax
    mov  dword [%$index_in_batch], edx

    call get_batches  ; REWRITE: [codecave:AUTO]
    mov  eax, [eax + AnmBatches.first_batch_created]
    mov  ecx, [%$batch_num]
.iter:
    dec  ecx
    js   .done
    mov  eax, [eax + AnmBatchHeader.next_batch_created]
    jmp  .iter
.done:

    mov  edi, game_data  ; REWRITE: <codecave:AUTO>
    mov  edx, [edi + GameData.vm_size]
    add  edx, BatchVmPrefix_size
    imul edx, [%$index_in_batch]
    lea  eax, [eax + AnmBatchHeader.vms + edx]

    ; now check to see if the VM is still allocated and the discriminator still matches
    mov  edx, [eax + BatchVmPrefix.our_id]
    cmp  edx, [%$id]
    jne  .fail
    lea  eax, [eax + BatchVmPrefix.vm]
    jmp  .succeed
.fail:
    xor  eax, eax
.succeed:
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
    func_local %$layer_data, %$batches
    func_prologue esi, edi, ebx

    %define %$reg_layer_data esi
    mov  %$reg_layer_data, layer_data  ; REWRITE: <codecave:AUTO>

    call get_batches  ; REWRITE: [codecave:AUTO]
    mov  [%$batches], eax

    push dword [%$batches]
    call ensure_enough_batches_for_draw_array  ; REWRITE: [codecave:AUTO]

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

; void EnsureEnoughBatchesForDrawArray(AnmBatches*)
ensure_enough_batches_for_draw_array:  ; HEADER: AUTO
    func_begin
    func_arg  %$batches
    func_local  %$fast_count
    func_prologue esi, edi, ebx
    %define %$reg_batches esi

    mov  %$reg_batches, [%$batches]

    mov  ecx, game_data  ; REWRITE: <codecave:AUTO>
    mov  ecx, [ecx+GameData.fast_array_bits]
    test ecx, ecx
    jz   .done  ; we're using our own IDs, so all VMs are in batches and therefore we must have enough batches

    ; If we're keeping vanilla IDs (and thus the fast array), then to have enough room in the layer array we'll
    ; need additional batches (enough to fit all batched VMs PLUS all fast VMs).
    mov  eax, 1
    shl  eax, cl
    mov  [%$fast_count], eax  ; actually a slight overestimate
.iter:
    ; basically, keep allocating batches until free_count >= length of the vanilla fast array
    mov  eax, [%$reg_batches + AnmBatches.free_count]
    cmp  eax, [%$fast_count]
    jae  .done

    push %$reg_batches
    call prepend_new_batch  ; REWRITE: [codecave:AUTO]
    jmp .iter

.done:
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
