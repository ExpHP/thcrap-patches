; AUTO_PREFIX: ExpHP.bullet-cap.

%include "util.asm"
%include "common.asm"

; Address range spanned by .text
address_range:  ; HEADER: AUTO
    dd 0x401000
    dd 0x48acda

bullet_replacements:  ; HEADER: AUTO
istruc CapGameData
    at CapGameData.old_cap, dd 0x7d0
    at CapGameData.elem_size, dd 0x1478
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

    dd 0x9ffdf8  ; size of bullet array (including dummy)
    dd SCALE_SIZE
    dd WHITELIST_BEGIN
    dd 0x411b8f
    dd WHITELIST_END

    dd 0x1f40  ; size of anmid array
    dd SCALE_FIXED(4)
    dd WHITELIST_BEGIN
    dd 0x411baa  ; BulletManager::destroy_all
    dd WHITELIST_END

    dd LIST_END

laser_replacements:  ; HEADER: AUTO
istruc CapGameData
    at CapGameData.old_cap, dd 0x200
    at CapGameData.elem_size, dd 0
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
istruc CapGameData
    at CapGameData.old_cap, dd 0x1000
    at CapGameData.elem_size, dd 0xc78
iend
    dd 0x1000  ; num cancel items
    dd SCALE_1
    dd WHITELIST_BEGIN
    dd 0x418553 - 4 ; ItemManager::destroy_all
    dd WHITELIST_END

    dd 0x1258  ; array length (includes non-cancel items)
    dd SCALE_1
    dd WHITELIST_BEGIN
    dd 0x42f0e6  ; ItemManager::constructor
    dd 0x42f106  ; ItemManager::constructor
    dd 0x42f178  ; ItemManager::destruct_item_array_impl
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

    dd LIST_END

bullet_mgr_layout:  ; HEADER: AUTO
istruc LayoutHeader
    at LayoutHeader.offset_to_replacements, dd bullet_mgr_layout.replacements - bullet_mgr_layout
iend
    dd REGION_NORMAL(0)
    dd REGION_ARRAY(0x9c, CAPID_BULLET, SCALE_SIZE)
    dd REGION_ARRAY(0x9ffe94, CAPID_BULLET, SCALE_SIZE)
    dd REGION_ARRAY(0x13ffc8c, CAPID_BULLET, SCALE_FIXED(4))
    dd REGION_ARRAY(0x1401bd0, CAPID_BULLET, SCALE_FIXED(4))
    dd REGION_NORMAL(0x1403b14)
    dd REGION_END(0x1403b28)
.replacements:
    dd REP_OFFSET(0x9ff68e)  ; offset of dummy bullet state
    dd WHITELIST_BEGIN
    dd 0x411a7a  ; BulletManager::initialize
    dd 0x411bb1  ; BulletManager::destroy_all
    dd WHITELIST_END

    dd REP_OFFSET(0x9ffe94)  ; LoLK snapshot bullet array
    dd WHITELIST_BEGIN
    dd 0x4118e0  ; BulletManager::constructor
    dd 0x411d84  ; BulletManager::destructor
    dd WHITELIST_END

    dd REP_OFFSET(0x13ffc8c)  ; anm id array
    dd WHITELIST_BEGIN
    dd 0x4118f5  ; BulletManager::constructor
    dd 0x411bb7  ; BulletManager::destroy_all
    dd 0x4168f0  ; Bullet::cancel
    dd 0x417023  ; BulletManager::clear_all
    dd WHITELIST_END

    dd REP_OFFSET(0x1401bd0)  ; LoLK snapshot anm id array
    dd WHITELIST_BEGIN
    dd 0x411908  ; BulletManager::constructor
    dd WHITELIST_END

    dd REP_OFFSET(0x1403b14)  ; Something related to cancels
    dd WHITELIST_BEGIN
    dd 0x411c88  ; BulletManager::destroy_all
    dd 0x416a78  ; BulletManager::gen_items_from_cancel
    dd 0x416a7e  ; BulletManager::gen_items_from_cancel
    dd WHITELIST_END

    dd REP_OFFSET(0x1403b1c)  ; "current" pointer for iteration
    dd REPLACE_ALL  ; 12 usages
    dd REP_OFFSET(0x1403b20)  ; "next" pointer for iteration
    dd REPLACE_ALL  ; 12 usages

    dd REP_OFFSET(0x1403b24)  ; bullet.anm
    dd REPLACE_ALL  ; 31 usages

    dd REP_OFFSET(0x1403b28)  ; size of BulletManager
    dd WHITELIST_BEGIN
    dd 0x411901  ; BulletManager::constructor
    dd 0x411df5  ; BulletManager::operator
    dd 0x411e32  ; BulletManager::operator
    dd 0x42d45e  ; GameThread::destructor
    dd 0x48a561  ; BulletManager::sub_48a560_destruction_related
    dd WHITELIST_END

    dd LIST_END

item_mgr_layout:  ; HEADER: AUTO
istruc LayoutHeader
    at LayoutHeader.offset_to_replacements, dd item_mgr_layout.replacements - item_mgr_layout
iend
    %push
    %define %$FIRST_INNER   0x14
    %define %$SECOND_INNER  0xe4b978
    %define %$INNER_CANCEL_BEGIN  0x1d3940
    %define %$INNER_CANCEL_END    0xe4b940
    %define %$INNER_SIZE          0xe4b964
    %define %$SIZE          0x1c972ec
    dd REGION_NORMAL(0)
    dd REGION_ARRAY(%$FIRST_INNER + %$INNER_CANCEL_BEGIN, CAPID_CANCEL, SCALE_SIZE)
    dd REGION_NORMAL(%$FIRST_INNER + %$INNER_CANCEL_END)
    dd REGION_ARRAY(%$SECOND_INNER + %$INNER_CANCEL_BEGIN, CAPID_CANCEL, SCALE_SIZE)
    dd REGION_NORMAL(%$SECOND_INNER + %$INNER_CANCEL_END)
    dd REGION_END(%$SIZE)
.replacements:
    ; freelist head nodes, lolk slowdown factor, snapshot item array
    dd REP_OFFSET_RANGE_INCLUSIVE(%$FIRST_INNER + %$INNER_CANCEL_END, %$SECOND_INNER)
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
    dd REP_OFFSET_RANGE(%$SECOND_INNER + %$INNER_SIZE, %$SIZE)
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

    dd REP_OFFSET(%$SIZE)  ; struct size
    dd WHITELIST_BEGIN
    dd 0x42d47d  ; GameThread::destructor
    dd 0x42f126  ; ItemManager::constructor
    dd 0x42f465  ; ItemManager::operator new
    dd 0x42f4a2  ; ItemManager::operator new
    dd 0x48a821  ; sub_48a820
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

corefuncs:  ; HEADER: AUTO
.malloc: dd 0x4749ac
