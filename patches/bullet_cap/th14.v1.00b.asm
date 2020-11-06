; AUTO_PREFIX: ExpHP.bullet-cap.

%include "util.asm"
%include "common.asm"

; Address range spanned by .text
address_range:  ; HEADER: AUTO
    dd 0x401000
    dd 0x4b0f3c

bullet_replacements:  ; HEADER: AUTO
istruc ListHeader
    at ListHeader.old_cap, dd 0x7d0
    at ListHeader.elem_size, dd 0x13f4
iend
    dd 0x7d0
    dd SCALE_1
    dd BLACKLIST_BEGIN
    dd 0x430e86  ; Gui::on_tick, checking enemy life
    dd 0x43933d  ; sub_439300, no clue
    dd BLACKLIST_END

    dd 0x7d1
    dd SCALE_1
    dd WHITELIST_BEGIN
    dd 0x0041603e  ; BulletManager::sub_416030
    dd 0x004164ea  ; BulletManager::destructor
    dd 0x0041655c  ; BulletManager::operator new
    dd WHITELIST_END

    dd 0x9bf634  ; size of bullet array
    dd SCALE_SIZE
    dd WHITELIST_BEGIN
    dd 0x416296
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
    dd 0x43a765 - 4  ; LaserManager::allocate_new_laser
    ; The rest are inlined calls to the above function.
    ; Find them via crossrefs to the Laser subclass constructors, as well as crossrefs to
    ; the subclass vtables in case a constructor was inlined.
    dd 0x43cbd6 - 4
    dd 0x43d944 - 4
    dd 0x43ebb2 - 4
    dd 0x43f839 - 4
    ; via LaserCurve::constructor
    dd 0x442e42 - 4
    dd WHITELIST_END
    dd LIST_END

cancel_replacements:  ; HEADER: AUTO
istruc ListHeader
    at ListHeader.old_cap, dd 0x1000
    at ListHeader.elem_size, dd 0xc18
iend
    dd 0x1258  ; array length (includes non-cancel items)
    dd SCALE_1
    dd WHITELIST_BEGIN
    dd 0x43826e  ; ItemManager::constructor
    dd 0x438409  ; ItemManager::destructor
    dd 0x43847d  ; ItemManager::operator new
    dd 0x438da3  ; ItemManager::on_tick__body
    dd 0x439646  ; ItemManager::on_draw__body
    dd 0x439bde  ; ItemManager::sub_439bd0
    dd WHITELIST_END

    dd 0xddd840  ; array size
    dd SCALE_SIZE
    dd WHITELIST_BEGIN
    dd 0x41d8c6  ; ItemManager::destroy_all
    dd WHITELIST_END

    dd 0x1000  ; cancel array length
    dd SCALE_1
    dd WHITELIST_BEGIN
    dd 0x41d97c - 4  ; ItemManager::destroy_all
    dd WHITELIST_END

    dd LIST_END

bullet_mgr_layout:  ; HEADER: AUTO
istruc LayoutHeader
    at LayoutHeader.offset_to_replacements, dd bullet_mgr_layout.replacements - bullet_mgr_layout
iend
    dd REGION_NORMAL(0)
    dd REGION_ARRAY(0x8c, CAPID_BULLET, SCALE_SIZE)
    dd REGION_NORMAL(0x9bf6c0)
    dd REGION_END(0x9bf6d0)
.replacements:
    dd 0x9beeda, REPLACE_ALL  ; offset of dummy bullet state
    dd 0x9bf6c0, REPLACE_ALL  ; offset of current ptr for iteration
    dd 0x9bf6c4, REPLACE_ALL  ; offset of next ptr for iteration
    dd 0x9bf6c8, REPLACE_ALL  ; offset of unknown cancel-related counter
    dd 0x9bf6cc, REPLACE_ALL  ; offset of bullet.anm
    dd 0x9bf6d0, REPLACE_ALL  ; size of bullet manager
    dd LIST_END

item_mgr_layout:  ; HEADER: AUTO
istruc LayoutHeader
    at LayoutHeader.offset_to_replacements, dd item_mgr_layout.replacements - item_mgr_layout
iend
    dd REGION_NORMAL(0)
    dd REGION_ARRAY(0x1c5854, CAPID_CANCEL, SCALE_SIZE)
    dd REGION_NORMAL(0xddd854)
    dd REGION_END(0xddd888)
.replacements:
    dd 0xddd854, REPLACE_ALL  ; freelist head .entry
    dd 0xddd858, REPLACE_ALL  ; freelist head .next
    dd 0xddd85c, REPLACE_ALL  ; freelist head .prev
    dd 0xddd860, REPLACE_ALL  ; freelist head .unused
    dd 0xddd864, REPLACE_ALL  ; tick list head .entry
    dd 0xddd868, REPLACE_ALL  ; tick list head .next
    dd 0xddd86c, REPLACE_ALL  ; tick list head .prev
    dd 0xddd870, REPLACE_ALL  ; tick list head .unused
    dd 0xddd874, REPLACE_ALL  ; num items alive
    dd 0xddd878, REPLACE_ALL  ; some cancel counter (different from earlier games)
    dd 0xddd87c, REPLACE_ALL  ; num cancel items spawned this frame  (always zero now)
    dd 0xddd880, REPLACE_ALL  ; dumb field that's always zero, copied onto piv items...
    dd 0xddd884, REPLACE_ALL  ; num ufos spawned during this stage  (always zero now)
    dd 0xddd888, REPLACE_ALL  ; ItemManager size
    dd LIST_END

perf_fix_data:  ; HEADER: AUTO
    dd 0

iat_funcs:  ; HEADER: AUTO
.GetLastError: dd 0x4b1094
.GetModuleHandleA: dd 0
.GetModuleHandleW: dd 0x4b1138
.GetProcAddress: dd 0x4b10f8
.MessageBoxA: dd 0x4b1250

corefuncs:  ; HEADER: AUTO
.malloc: dd 0x4854af
