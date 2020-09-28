; AUTO_PREFIX: ExpHP.bullet-cap.

%include "util.asm"
%include "common.asm"

; Address range spanned by .text
address_range:  ; HEADER: AUTO
    dd 0x401000
    dd 0x48ae15

bullet_replacements:  ; HEADER: AUTO
istruc ListHeader
    at ListHeader.old_cap, dd 0x7d0
    at ListHeader.elem_size, dd 0x910
iend
    dd 0x7d0
    dd SCALE_1
    dd BLACKLIST_BEGIN
    dd 0x41c394 - 4
    dd 0x459057 - 4
    dd 0x46b806 + 2  ; coincidental appearance in a jump
    dd BLACKLIST_END

    dd 0x7d1
    dd SCALE_1
    dd REPLACE_ALL

    dd 0x46d216  ; offset of dummy bullet state
    dd SCALE_SIZE
    dd REPLACE_ALL

    dd 0x46d674  ; offset of bullet.anm
    dd SCALE_SIZE
    dd REPLACE_ALL

    dd 0x46d678  ; size of bullet manager
    dd SCALE_SIZE
    dd REPLACE_ALL

    dd 0x46d610  ; size of bullet array
    dd SCALE_SIZE
    dd REPLACE_ALL

    dd LIST_END

laser_replacements:  ; HEADER: AUTO
istruc ListHeader
    at ListHeader.old_cap, dd 0x100
    at ListHeader.elem_size, dd 0
iend
    dd 0x100
    dd SCALE_1
    dd WHITELIST_BEGIN
    ; This sucker got inlined but we can just look at the crossrefs
    ; of LaserLine::constructor and LaserInfinite::constructor.
    dd 0x424e01 - 4
    dd 0x426721 - 4
    dd 0x426d4a - 4
    dd 0x427b82 - 4
    dd 0x4281d5 - 4
    dd WHITELIST_END
    dd LIST_END

cancel_replacements:  ; HEADER: AUTO
istruc ListHeader
    at ListHeader.old_cap, dd 0x800
    at ListHeader.elem_size, dd 0x478
iend
    dd 0x896  ; array size (includes non-cancel items)
    dd SCALE_1
    dd REPLACE_ALL

    ; offsets of fields after array
    dd 0x265e64  ; num items alive
    dd SCALE_SIZE
    dd REPLACE_ALL
    dd 0x265e68  ; next cancel item index
    dd SCALE_SIZE
    dd REPLACE_ALL
    dd 0x265e6c  ; num cancel items spawned this frame
    dd SCALE_SIZE
    dd REPLACE_ALL
    dd 0x265e70  ; ItemManager size
    dd SCALE_SIZE
    dd REPLACE_ALL

    dd 0x265e50  ; array size
    dd SCALE_SIZE
    dd REPLACE_ALL

    dd LIST_END

perf_fix_data:  ; HEADER: AUTO
istruc PerfFixData
    at PerfFixData.anm_manager_ptr, dd 0x4c3268
    at PerfFixData.world_list_head_offset, dd 0x7b562c
    at PerfFixData.anm_id_offset, dd 0
iend

iat_funcs:  ; HEADER: AUTO
.GetLastError: dd 0x48b1b8
.GetModuleHandleA: dd 0
.GetModuleHandleW: dd 0x48b174
.GetProcAddress: dd 0x48b170
.MessageBoxA: dd 0x48b24c
