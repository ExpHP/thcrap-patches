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
    at ListHeader.old_cap, dd 0x200
    at ListHeader.elem_size, dd 0
iend
    dd 0x200
    dd SCALE_1
    dd WHITELIST_BEGIN
    dd 0x431775 - 4  ; LaserManager::allocate_new_laser
    ; The rest are inlined calls to the above function.
    ; Found via crossrefs to LaserLine::constructor
    dd 0x414b81 - 4
    dd 0x432777 - 4
    dd 0x4328c3 - 4
    dd 0x432a29 - 4
    dd 0x432b86 - 4
    dd 0x433f69 - 4
    dd 0x434c1e - 4
    dd 0x435f73 - 4
    dd 0x436bc4 - 4
    ; Found via crossrefs to LaserInfinite::constructor
    dd 0x4149a8 - 4
    dd 0x439c51 - 4
    ; This list was double checked by searching for the count offset (0x5e4)
    ; and filtering for instructions that contain 0x200. (same 12 results)
    dd WHITELIST_END
    dd LIST_END

cancel_replacements:  ; HEADER: AUTO
istruc ListHeader
    at ListHeader.old_cap, dd 0x1000
    at ListHeader.elem_size, dd 0xc78
iend
    dd 0x1000  ; num cancel items
    dd SCALE_1
    dd WHITELIST_BEGIN
    dd 0x418553 - 4 ; ItemManager::destroy_all
    dd WHITELIST_END

    dd 0x1258  ; array size (includes non-cancel items)
    dd SCALE_1
    dd WHITELIST_BEGIN
    dd 0x42f0e6  ; ItemManager::constructor
    dd 0x42f106  ; ItemManager::constructor
    dd 0x42f178  ; sub_42f150
    dd 0x42f3eb  ; ItemManager::destructor
    dd 0x42f40d  ; ItemManager::destructor
    dd 0x43007f  ; ItemManager::on_tick_1d
    dd 0x4307b0  ; ItemManager::on_draw
    dd WHITELIST_END

    dd 0xe4b940  ; array size
    dd SCALE_SIZE
    dd WHITELIST_BEGIN
    dd 0x4184a6  ; ItemManager::destroy_all
    dd WHITELIST_END

    dd 0x1c972ec  ; struct size
    dd SCALE_AN_PLUS_B(2, 0)
    dd WHITELIST_BEGIN
    dd 0x42d47d  ; GameThread::destructor
    dd 0x42f126  ; ItemManager::constructor
    dd 0x42f465  ; ItemManager::operator new
    dd 0x42f4a2  ; ItemManager::operator new
    dd 0x48a821  ; sub_48a820
    dd WHITELIST_END

    ; freelist head nodes, lolk slowdown factor, snapshot item array
    dd DWORD_RANGE_INCLUSIVE(0x14+0xe4b940, 0xe4b978)
    dd SCALE_SIZE
    dd WHITELIST_BEGIN
    dd 0x4184cb   ; ItemManager::destroy_all  (normal item freelist)
    dd 0x4309b9   ; ItemManager::spawn_item  (normal item freelist)
    dd 0x418539   ; ItemManager::destroy_all  (cancel item freelist)
    dd 0x430b02   ; ItemManager::spawn_item  (cancel item freelist)
    dd 0x418599   ; ItemManager::destroy_all  (lolk slowdown factor)
    dd 0x42fa48   ; ItemManager::on_tick__body  (lolk slowdown factor)
    dd 0x42faa7   ; ItemManager::on_tick__body  (lolk slowdown factor)
    dd 0x42facc   ; ItemManager::on_tick__body  (lolk slowdown factor)
    dd 0x43008d   ; ItemManager::on_tick__body  (lolk slowdown factor)
    dd 0x4300af   ; ItemManager::on_tick__body  (lolk slowdown factor)
    dd 0x42f10c   ; ItemManager::constructor  (snapshot item array)
    dd 0x42f3f6   ; ItemManager::destructor  (snapshot item array)
    dd WHITELIST_END

    ; in TH16, the snapshot versions of the freelist and slowdown still exist but are never referenced
    
    ; fields at end of struct
    dd DWORD_RANGE_INCLUSIVE(0x1c972dc, 0x1c972ec)
    dd SCALE_AN_PLUS_B(2, 0)
    dd WHITELIST_BEGIN
    dd 0x42f529  ; ItemManager::on_tick__body  (num items onscreen)
    dd 0x43004e  ; ItemManager::on_tick__body  (num items onscreen)
    dd 0x4184b1  ; ItemManager::destroy_all   (total items created)
    dd 0x43096e  ; ItemManager::spawn_item   (total items created)
    dd 0x430b29  ; ItemManager::spawn_item   (total items created)
    dd 0x430b47  ; ItemManager::spawn_item   (total items created)
    dd 0x430b63  ; ItemManager::spawn_item   (total items created)
    dd 0x42f51f  ; ItemManager::on_tick__body   (num cancel items this frame)
    dd 0x430b1c  ; ItemManager::spawn_item   (num cancel items this frame)
    dd 0x4184bc  ; ItemManager::destroy_all   (???)
    dd 0x430b10  ; ItemManager::spawn_item   (???)
    dd WHITELIST_END
    dd LIST_END

perf_fix_data:  ; HEADER: AUTO
    dd 0

iat_funcs:  ; HEADER: AUTO
.GetLastError: dd 0x48b08c
.GetModuleHandleA: dd 0
.GetModuleHandleW: dd 0x48b184
.GetProcAddress: dd 0x48b0d4
.MessageBoxA: dd 0x48b1fc
