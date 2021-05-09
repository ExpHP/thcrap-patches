%define BATCH_LEN   0x1800
; %define BATCH_LEN   0x100

; %define BATCH_LEN   0x4  ; for testing

struc BatchVmPrefix
    .batch: resd 1  ; pointer back to VM's batch
    .in_use: resd 1  ; is this VM in use
    .vm: resb 0
endstruc

struc AnmBatches
    .free_count: resd 1  ; num free across all batches
    .active_batch: resd 1  ; pointer to the first batch in the list, which is the one we are currently allocating from
    .last_batch: resd 1  ; pointer to last batch for quickly appending to the tail
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
    .next_index: resd 1  ; next index to begin searching from in this page (helps speed up searches)
    .free_count: resd 1  ; num free in batch
    .next_batch: resd 1
    ; More cache-friendly array of ids in an inactive batch.
    ; Each element corresponds to the matching item in the vms array.
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
