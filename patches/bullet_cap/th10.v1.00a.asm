; AUTO_PREFIX: ExpHP.bullet-cap.

%include "util.asm"
%include "common.asm"

; Address range spanned by .text
address_range:  ; HEADER: AUTO
    dd 0x401000
    dd 0x465a81

bullet_replacements:  ; HEADER: AUTO
istruc ListHeader
    at ListHeader.old_cap, dd 0x7d0
    at ListHeader.elem_size, dd 0x7f0
iend
    dd 0x7d0
    dd SCALE_1
    dd BLACKLIST_BEGIN
    dd 0x41560d - 4
    dd 0x44bd82 - 4
    dd BLACKLIST_END

    dd 0x7d1
    dd SCALE_1
    dd REPLACE_ALL

    dd 0xf82d5  ; num dwords in bullet manager
    dd SCALE_SIZE_DIV(4)
    dd REPLACE_ALL

    dd 0xf82bc  ; num dwords in bullet array
    dd SCALE_SIZE_DIV(4)
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
    dd 0x41c51a - 4
    dd WHITELIST_END

    dd LIST_END

cancel_replacements:  ; HEADER: AUTO
istruc ListHeader
    at ListHeader.old_cap, dd 0x800
    at ListHeader.elem_size, dd 0x3f0
iend
    dd 0x896  ; array length (includes non-cancel items)
    dd SCALE_1
    dd REPLACE_ALL

    dd 0x873a8   ; array size in dwords
    dd SCALE_SIZE_DIV(4)
    dd REPLACE_ALL

    ; FIXME: This should technically be under item_mgr_layout.replacements but we
    ;        don't have scale constants there to do the division...
    dd 0x873b0   ; ItemManager size in dwords
    dd SCALE_SIZE_DIV(4)
    dd REPLACE_ALL

    dd LIST_END

bullet_mgr_layout:  ; HEADER: AUTO
istruc LayoutHeader
    at LayoutHeader.offset_to_replacements, dd bullet_mgr_layout.replacements - bullet_mgr_layout
iend
    dd REGION_NORMAL(0)
    dd REGION_ARRAY(0x60, CAPID_BULLET, SCALE_SIZE)
    dd REGION_NORMAL(0x3e0b50)
    dd REGION_END(0x3e0b54)
.replacements:
    dd REP_OFFSET(0x3e07a6), REPLACE_ALL  ; offset of dummy bullet state
    dd REP_OFFSET(0x3e0b50), REPLACE_ALL  ; offset of bullet.anm
    dd REP_OFFSET(0x3e0b54), REPLACE_ALL  ; size of bullet manager
    dd LIST_END

item_mgr_layout:  ; HEADER: AUTO
istruc LayoutHeader
    at LayoutHeader.offset_to_replacements, dd item_mgr_layout.replacements - item_mgr_layout
iend
    dd REGION_NORMAL(0)
    dd REGION_ARRAY(0x24eb4, CAPID_CANCEL, SCALE_SIZE)
    dd REGION_NORMAL(0x21ceb4)
    dd REGION_END(0x21cec0)
.replacements:
    dd REP_OFFSET(0x21ceb4), REPLACE_ALL  ; num items alive
    dd REP_OFFSET(0x21ceb8), REPLACE_ALL  ; next cancel item index
    dd REP_OFFSET(0x21cebc), REPLACE_ALL  ; num cancel items spawned this frame
    dd REP_OFFSET(0x21cec0), REPLACE_ALL  ; ItemManager size
    dd LIST_END

perf_fix_data:  ; HEADER: AUTO
istruc PerfFixData
    at PerfFixData.anm_manager_ptr, dd 0x491c10
    at PerfFixData.world_list_head_offset, dd 0x72dad4
    at PerfFixData.anm_id_offset, dd 0
iend

iat_funcs:  ; HEADER: AUTO
.GetLastError: dd 0x45fadc
.GetModuleHandleA: dd 0x466198
.GetModuleHandleW: dd 0
.GetProcAddress: dd 0x466158
.MessageBoxA: dd 0x466234

corefuncs:  ; HEADER: AUTO
.malloc: dd 0x452493
