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

    dd 0x974b0e  ; offset of dummy bullet state
    dd SCALE_SIZE
    dd REPLACE_ALL

    ; offsets of "current" and "next" pointers used by a pair of frequently-inlined
    ; and clearly-not-reentrant methods for iterating over bullets.
    dd 0x9752ac
    dd SCALE_SIZE
    dd REPLACE_ALL
    dd 0x9752b0
    dd SCALE_SIZE
    dd REPLACE_ALL

    dd 0x9752b4  ; offset of bullet.anm
    dd SCALE_SIZE
    dd REPLACE_ALL

    dd 0x9752b8  ; size of bullet manager
    dd SCALE_SIZE
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
    dd 0xa58  ; array size (includes non-cancel items)
    dd SCALE_1
    dd BLACKLIST_BEGIN
    dd BLACKLIST_END

    ; offsets of fields after array
    dd 0x79dcd4, SCALE_SIZE, REPLACE_ALL  ; freelist head .entry
    dd 0x79dcd8, SCALE_SIZE, REPLACE_ALL  ; freelist head .next
    dd 0x79dcdc, SCALE_SIZE, REPLACE_ALL  ; freelist head .prev
    dd 0x79dce0, SCALE_SIZE, REPLACE_ALL  ; freelist head .unused
    dd 0x79dce4, SCALE_SIZE, REPLACE_ALL  ; tick list head .entry
    dd 0x79dce8, SCALE_SIZE, REPLACE_ALL  ; tick list head .next
    dd 0x79dcec, SCALE_SIZE, REPLACE_ALL  ; tick list head .prev
    dd 0x79dcf0, SCALE_SIZE, REPLACE_ALL  ; tick list head .unused
    dd 0x79dcf4, SCALE_SIZE, REPLACE_ALL  ; num items alive
    dd 0x79dcf8, SCALE_SIZE, REPLACE_ALL  ; next cancel item index  (always zero now)
    dd 0x79dcfc, SCALE_SIZE, REPLACE_ALL  ; num cancel items spawned this frame  (always zero now)
    dd 0x79dd00, SCALE_SIZE, REPLACE_ALL  ; num ufos spawned during this stage  (always zero now)
    dd 0x79dd04, SCALE_SIZE, REPLACE_ALL  ; ItemManager size

    dd 0x79dcc0  ; array size
    dd SCALE_SIZE
    dd REPLACE_ALL

    dd 0x200  ; highly-questionable unrolled loops in TD
    dd SCALE_1_DIV(4)
    dd WHITELIST_BEGIN
    dd 0x414033 - 4  ; building freelist in ItemManager::destroy_all
    dd WHITELIST_END

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
