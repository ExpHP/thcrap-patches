%define BATCH_LEN   0x1800

struc BatchVmPrefix  ; DELETE
    .batch: resd 1  ; pointer back to VM's batch  ; DELETE
    .in_use: resd 1  ; is this VM in use  ; DELETE
    .vm: resb 0  ; DELETE
endstruc  ; DELETE

struc AnmBatches  ; DELETE
    .free_count: resd 1  ; num free across all batches  ; DELETE
    .active_batch: resd 1  ; pointer to the first batch in the list, which is the one we are currently allocating from  ; DELETE
    .last_batch: resd 1  ; pointer to last batch for quickly appending to the tail  ; DELETE
endstruc  ; DELETE

struc AnmBatchHeader  ; DELETE
    .next_index: resd 1  ; next index to begin searching from in this page (helps speed up searches)  ; DELETE
    .free_count: resd 1  ; num free in batch  ; DELETE
    .next_batch: resd 1  ; DELETE
    .ids: resd BATCH_LEN  ; more cache-friendly array of ids in an inactive batch ; DELETE
    .vms:  resb 0  ; DELETE
endstruc  ; DELETE

struc State  ; DELETE
    .batches_ptr: resd 1  ; pointer to AnmBatches  ; DELETE
endstruc  ; DELETE

struc GameData  ; DELETE
    .vm_size: resd 1  ; DELETE
    .id_offset: resd 1  ; DELETE
    .func_malloc: resd 1  ; DELETE
endstruc  ; DELETE
