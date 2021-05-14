%define BATCH_LEN   0x1800
; %define BATCH_LEN   0x10

; a very small nonzero discriminant is used in our numbering scheme used to identify when an ANM has died and a
; new one has taken its location in the array before an ID search.
%define DISCRIMINANT_BITS  5
; mask used to simulate a modulus when incrementing the discriminant
%define DISCRIMINANT_MOD_MASK  ((1 << DISCRIMINANT_BITS) - 1)
%define DISCRIMINANT_SHIFT     (32 - DISCRIMINANT_BITS)

; %define BATCH_LEN   0x4  ; for testing

struc BatchVmPrefix
    .batch: resd 1  ; pointer back to VM's batch
    .index: resd 1  ; index within this batch
    ; The ID of the VM currently here in OUR numbering scheme. Zero if not in use.
    ; In some games we will make the game use this as the VM's actual ID.
    .our_id: resd 1
    ; previously assigned discriminant, so we can assign them in increasing order.  (can be zero if this entry has never been used).
    ; This is tracked per array item instead of globally so that fewer bits will suffice. (a value will not be reused for a long time)
    .last_discriminant: resd 1
    .vm: resb 0
endstruc

struc AnmBatches
    .batch_count: resd 1
    .free_count: resd 1  ; num free across all batches
    ; head and tail for the "active list."
    ; In this list, the first batch is the one we're currently allocating from (the "active batch"),
    ; and the rest is just a queue of inactive branches to try using again once this one fills.
    .active_batch: resd 1
    .last_batch: resd 1
    ; head and tail for the "in creation order" list.
    ; In games where we force the game to use our own ID numbering scheme, we can use this list
    ; to optimize ID searches even further.
    .first_batch_created: resd 1
    .last_batch_created: resd 1
    ; stuff for the UM optimized draw loop
    .draw_write_batch: resd 1  ; pointer to batch whose draw_array is currently being populated
    .draw_write_index: resd 1  ; next index to write within a batch
    .num_to_draw: resd 1  ; total number of elements in draw_array
endstruc

struc DrawArrayItem
    .layer: resd 1  ; NOTE: we store effective layer (normally computed in AnmManager::render_layer)
    .vm: resd 1  ; pointer to VM
endstruc

struc AnmBatchHeader
    .creation_order_index: resd 1
    .next_allocation_index: resd 1  ; next index to begin searching from in this page (helps speed up VM allocation)
    .free_count: resd 1  ; num free in batch
    .next_batch: resd 1  ; next batch in the active list (used for allocating VMs)
    .next_batch_created: resd 1  ; next batch in order of creation
    ; More cache-friendly array of ids in an inactive batch.
    ; Each element corresponds to the matching item in the vms array.
    ;
    ; This is only used in games where we do not force the game to use our ID numbering system.
    .ids: resd BATCH_LEN
    ; An array used to optimize the draw loop for UM.
    ; There is actually *no correspondence* here with the items in the vms array.  The array is rewritten from scratch
    ; each tick to reflect the order of the on_tick lists, and the only reason it is stored here on the batches is
    ; to dodge concerns of how long it needs to be.
    .draw_array: resb DrawArrayItem_size * BATCH_LEN
    .vms: resb 0
endstruc

struc State 
    .batches_ptr: resd 1  ; pointer to AnmBatches
endstruc 

struc GameData
    .vm_size: resd 1
    .id_offset: resd 1
    .func_malloc: resd 1
endstruc

struc GameLayerData
    .func_draw_vm: resd 1
    .world_list_offset: resd 1
    .ui_list_offset: resd 1
    .layer_offset: resd 1
    ; AnmManager::draw_layer won't draw if some bitflags are activated
    .flags_hi_offset: resd 1
    .flags_hi_hide: resd 1  ; upper dword of VM flags
    .ui_layer_start: resd 1
    .ui_layer_count: resd 1
    .world_ui_layer_start: resd 1  ; beginning of "effective UI layers"
    .ui_layer_default: resd 1  ; default layer used by invalid UI layers
endstruc
