; AUTO_PREFIX: ExpHP.bullet-cap.

%include "util.asm"
%include "common.asm"

; Address range spanned by .text
address_range:  ; HEADER: AUTO
    dd 0x401000
    dd 0x48acda

bullet_replacements:  ; HEADER: AUTO
istruc ListHeader
    at ListHeader.old_cap, dd 0x7d0
    at ListHeader.elem_size, dd 0x1478
iend
    dd 0x7d0
    dd SCALE_1
    dd WHITELIST_BEGIN
    dd 0x411b43  ; BulletManager::initialize
    dd 0x411c54  ; BulletManager::destroy_all
    dd 0x416e3c  ; BulletManager::cancel_bullets_in_rectangle_as_bomb
    dd 0x416f4e  ; BulletManager::clear_all
    dd WHITELIST_END

    dd 0x7d1
    dd SCALE_1
    dd WHITELIST_BEGIN
    dd 0x4118b5  ; BulletManager::constructor
    dd 0x4118d5  ; BulletManager::constructor
    dd 0x4118fa  ; BulletManager::constructor
    dd 0x41190d  ; BulletManager::constructor
    dd 0x411d79  ; BulletManager::destructor
    dd 0x411d9e  ; BulletManager::destructor
    dd 0x48a506  ; BulletManager::sub_48a500_destructor_related
    dd WHITELIST_END

    ; offset of dummy bullet state
    dd 0x9ff68e
    dd SCALE_SIZE
    dd WHITELIST_BEGIN
    dd 0x411a7a  ; BulletManager::initialize
    dd 0x411bb1  ; BulletManager::destroy_all
    dd WHITELIST_END

    ; LoLK snapshot bullet array
    dd 0x9ffe94
    dd SCALE_SIZE
    dd WHITELIST_BEGIN
    dd 0x4118e0  ; BulletManager::constructor
    dd 0x411d84  ; BulletManager::destructor
    dd WHITELIST_END

    ; anm id array
    dd 0x13ffc8c
    dd SCALE_AN_PLUS_B(2, 0)  ; two bullet arrays
    dd WHITELIST_BEGIN
    dd 0x4118f5  ; BulletManager::constructor
    dd 0x411bb7  ; BulletManager::destroy_all
    dd 0x4168f0  ; Bullet::cancel
    dd 0x417023  ; BulletManager::clear_all
    dd WHITELIST_END

    ; LoLK snapshot anm id array
    dd 0x1401bd0
    dd SCALE_AN_PLUS_B(2, 4)  ; two bullet arrays and an int array
    dd WHITELIST_BEGIN
    dd 0x411908  ; BulletManager::constructor
    dd WHITELIST_END

    ; Related to cancels
    dd 0x1403b14  ; offset of bullet.anm
    dd SCALE_AN_PLUS_B(2, 8)  ; two bullet arrays, two int arrays
    dd WHITELIST_BEGIN
    dd 0x411c88  ; BulletManager::destroy_all
    dd 0x416a78  ; BulletManager::gen_items_from_cancel
    dd 0x416a7e  ; BulletManager::gen_items_from_cancel
    dd WHITELIST_END

    ; offsets of "current" and "next" pointers used during bullet iteration.
    dd 0x1403b1c
    dd SCALE_AN_PLUS_B(2, 8)
    dd REPLACE_ALL  ; 12 usages
    dd 0x1403b20
    dd SCALE_AN_PLUS_B(2, 8)
    dd REPLACE_ALL  ; 12 usages

    dd 0x1403b24  ; bullet.anm
    dd SCALE_AN_PLUS_B(2, 8)
    dd REPLACE_ALL  ; 31 usages

    dd 0x1403b28  ; size of BulletManager
    dd SCALE_AN_PLUS_B(2, 8)
    dd WHITELIST_BEGIN
    dd 0x411901  ; BulletManager::constructor
    dd 0x411df5  ; BulletManager::operator
    dd 0x411e32  ; BulletManager::operator
    dd 0x42d45e  ; GameThread::destructor
    dd 0x48a561  ; BulletManager::sub_48a560_destruction_related
    dd WHITELIST_END

    dd 0x9ffdf8  ; size of bullet array
    dd SCALE_SIZE
    dd WHITELIST_BEGIN
    dd 0x411b8f
    dd WHITELIST_END

    dd 0x1f40  ; size of anmid array
    dd SCALE_AN_PLUS_B(0, 4)
    dd WHITELIST_BEGIN
    dd 0x411baa  ; BulletManager::destroy_all
    dd WHITELIST_END

    dd LIST_END

laser_replacements:  ; HEADER: AUTO
istruc ListHeader
    at ListHeader.old_cap, dd 0x100
    at ListHeader.elem_size, dd 0
iend
    ; dd 0x100
    ; dd SCALE_1
    ; dd WHITELIST_BEGIN
    ; dd 0x42fee1 - 4  ; LaserManager::allocate_new_laser
    ; ; The rest are inlined calls to the above function.
    ; ; Find them via crossrefs to the Laser subclass constructors, as well as crossrefs to
    ; ; the subclass vtables in case a constructor was inlined.
    ; dd 0x430ed8 - 4
    ; dd 0x431018 - 4
    ; dd 0x431151 - 4
    ; dd 0x4312a6 - 4
    ; dd 0x43228a - 4
    ; dd 0x432d68 - 4
    ; dd 0x433e6a - 4
    ; dd 0x43487f - 4
    ; dd 0x43758c - 4
    ; dd WHITELIST_END
    dd LIST_END

cancel_replacements:  ; HEADER: AUTO
istruc ListHeader
    at ListHeader.old_cap, dd 0x800
    at ListHeader.elem_size, dd 0xbc8
iend
    ; dd 0xa58  ; array size (includes non-cancel items)
    ; dd SCALE_1
    ; dd BLACKLIST_BEGIN
    ; dd BLACKLIST_END

    ; ; offsets of fields after array
    ; dd 0x79dcd4, SCALE_SIZE, REPLACE_ALL  ; freelist head .entry
    ; dd 0x79dcd8, SCALE_SIZE, REPLACE_ALL  ; freelist head .next
    ; dd 0x79dcdc, SCALE_SIZE, REPLACE_ALL  ; freelist head .prev
    ; dd 0x79dce0, SCALE_SIZE, REPLACE_ALL  ; freelist head .unused
    ; dd 0x79dce4, SCALE_SIZE, REPLACE_ALL  ; tick list head .entry
    ; dd 0x79dce8, SCALE_SIZE, REPLACE_ALL  ; tick list head .next
    ; dd 0x79dcec, SCALE_SIZE, REPLACE_ALL  ; tick list head .prev
    ; dd 0x79dcf0, SCALE_SIZE, REPLACE_ALL  ; tick list head .unused
    ; dd 0x79dcf4, SCALE_SIZE, REPLACE_ALL  ; num items alive
    ; dd 0x79dcf8, SCALE_SIZE, REPLACE_ALL  ; next cancel item index  (always zero now)
    ; dd 0x79dcfc, SCALE_SIZE, REPLACE_ALL  ; num cancel items spawned this frame  (always zero now)
    ; dd 0x79dd00, SCALE_SIZE, REPLACE_ALL  ; num ufos spawned during this stage  (always zero now)
    ; dd 0x79dd04, SCALE_SIZE, REPLACE_ALL  ; ItemManager size

    ; dd 0x79dcc0  ; array size
    ; dd SCALE_SIZE
    ; dd REPLACE_ALL

    ; dd 0x200  ; highly-questionable unrolled loops in TD
    ; dd SCALE_1_DIV(4)
    ; dd WHITELIST_BEGIN
    ; dd 0x414033 - 4  ; building freelist in ItemManager::destroy_all
    ; dd WHITELIST_END

    dd LIST_END

perf_fix_data:  ; HEADER: AUTO
istruc PerfFixData
    at PerfFixData.anm_manager_ptr, dd 0x4dc688
    at PerfFixData.world_list_head_offset, dd 0xf48208
    at PerfFixData.anm_id_offset, dd 0x530
iend

iat_funcs:  ; HEADER: AUTO
.GetLastError: dd 0x48b08c
.GetModuleHandleA: dd 0
.GetModuleHandleW: dd 0x48b184
.GetProcAddress: dd 0x48b0d4
.MessageBoxA: dd 0x48b1fc
