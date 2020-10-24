; AUTO_PREFIX: ExpHP.bullet-cap.

%include "util.asm"
%include "common.asm"

; Address range spanned by .text
address_range:  ; HEADER: AUTO
    dd 0x401000
    dd 0x497ad5

bullet_replacements:  ; HEADER: AUTO
istruc ListHeader
    at ListHeader.old_cap, dd 0x7d0
    at ListHeader.elem_size, dd 0x135c
iend
    dd 0x7d0
    dd SCALE_1
    dd BLACKLIST_BEGIN
    dd 0x4275d3 - 4  ; in Gui::on_tick
    dd 0x473106 - 4  ; weird, possibly unused function
    dd BLACKLIST_END

    dd 0x7d1
    dd SCALE_1
    dd REPLACE_ALL

    dd 0x97521c  ; size of bullet array
    dd SCALE_SIZE
    dd REPLACE_ALL

    dd 400  ; highly-questionable unrolled loops in TD
    dd SCALE_1_DIV(5)
    dd WHITELIST_BEGIN
    dd 0x40d2f0 - 4  ; building freelist in BulletManager::initialize
    dd 0x40d55c - 4  ; building freelist in BulletManager::destroy_all
    dd WHITELIST_END

    dd LIST_END

laser_replacements:  ; HEADER: AUTO
istruc ListHeader
    at ListHeader.old_cap, dd 0x100
    at ListHeader.elem_size, dd 0
iend
    dd 0x100
    dd SCALE_1
    dd WHITELIST_BEGIN
    dd 0x42fee1 - 4  ; LaserManager::allocate_new_laser
    ; The rest are inlined calls to the above function.
    ; Find them via crossrefs to the Laser subclass constructors, as well as crossrefs to
    ; the subclass vtables in case a constructor was inlined.
    dd 0x430ed8 - 4
    dd 0x431018 - 4
    dd 0x431151 - 4
    dd 0x4312a6 - 4
    dd 0x43228a - 4
    dd 0x432d68 - 4
    dd 0x433e6a - 4
    dd 0x43487f - 4
    dd 0x43758c - 4
    dd WHITELIST_END
    dd LIST_END

cancel_replacements:  ; HEADER: AUTO
istruc ListHeader
    at ListHeader.old_cap, dd 0x800
    at ListHeader.elem_size, dd 0xbc8
iend
    dd 0xa58  ; array length (includes non-cancel items)
    dd SCALE_1
    dd BLACKLIST_BEGIN
    dd BLACKLIST_END

    dd 0x79dcc0  ; array size
    dd SCALE_SIZE
    dd REPLACE_ALL

    dd 0x200  ; highly-questionable unrolled loops in TD
    dd SCALE_1_DIV(4)
    dd WHITELIST_BEGIN
    dd 0x414033 - 4  ; building freelist in ItemManager::destroy_all
    dd WHITELIST_END

    dd LIST_END

bullet_mgr_layout:  ; HEADER: AUTO
istruc LayoutHeader
    at LayoutHeader.location, dd LOCATION_PTR(0x4b43c8)
    at LayoutHeader.offset_to_replacements, dd bullet_mgr_layout.replacements - bullet_mgr_layout
iend
    dd REGION_NORMAL(0)
    dd REGION_ARRAY(0x90, CAPID_BULLET, SCALE_SIZE)
    dd REGION_NORMAL(0x9752ac)
    dd REGION_END(0x9752b8)
.replacements:
    dd 0x974b0e, REPLACE_ALL  ; offset of dummy bullet state
    dd 0x9752ac, REPLACE_ALL  ; offset of current ptr for iteration
    dd 0x9752b0, REPLACE_ALL  ; offset of next ptr for iteration
    dd 0x9752b4, REPLACE_ALL  ; offset of bullet.anm
    dd 0x9752b8, REPLACE_ALL  ; size of bullet manager
    dd LIST_END

item_mgr_layout:  ; HEADER: AUTO
istruc LayoutHeader
    at LayoutHeader.location, dd LOCATION_PTR(0x4c229c)
    at LayoutHeader.offset_to_replacements, dd item_mgr_layout.replacements - item_mgr_layout
iend
    dd REGION_NORMAL(0)
    dd REGION_ARRAY(0x1b9cd4, CAPID_CANCEL, SCALE_SIZE)
    dd REGION_NORMAL(0x79dcd4)
    dd REGION_END(0x79dd04)
.replacements:
    dd 0x79dcd4, REPLACE_ALL  ; freelist head .entry
    dd 0x79dcd8, REPLACE_ALL  ; freelist head .next
    dd 0x79dcdc, REPLACE_ALL  ; freelist head .prev
    dd 0x79dce0, REPLACE_ALL  ; freelist head .unused
    dd 0x79dce4, REPLACE_ALL  ; tick list head .entry
    dd 0x79dce8, REPLACE_ALL  ; tick list head .next
    dd 0x79dcec, REPLACE_ALL  ; tick list head .prev
    dd 0x79dcf0, REPLACE_ALL  ; tick list head .unused
    dd 0x79dcf4, REPLACE_ALL  ; num items alive
    dd 0x79dcf8, REPLACE_ALL  ; next cancel item index  (always zero now)
    dd 0x79dcfc, REPLACE_ALL  ; num cancel items spawned this frame  (always zero now)
    dd 0x79dd00, REPLACE_ALL  ; num ufos spawned during this stage  (always zero now)
    dd 0x79dd04, REPLACE_ALL  ; ItemManager size
    dd LIST_END

perf_fix_data:  ; HEADER: AUTO
istruc PerfFixData
    at PerfFixData.anm_manager_ptr, dd 0x4dc688
    at PerfFixData.world_list_head_offset, dd 0xf48208
    at PerfFixData.anm_id_offset, dd 0x530
iend

iat_funcs:  ; HEADER: AUTO
.GetLastError: dd 0x4a20e4
.GetModuleHandleA: dd 0
.GetModuleHandleW: dd 0x4a2170
.GetProcAddress: dd 0x4a21c8
.MessageBoxA: dd 0x4a2240
