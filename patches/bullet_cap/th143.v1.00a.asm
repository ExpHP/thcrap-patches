; AUTO_PREFIX: ExpHP.bullet-cap.

%include "util.asm"
%include "common.asm"

; Address range spanned by .text
address_range:  ; HEADER: AUTO
    dd 0x401000
    dd 0x4b798c

bullet_replacements:  ; HEADER: AUTO
istruc ListHeader
    at ListHeader.old_cap, dd 0x7d0
    at ListHeader.elem_size, dd 0x13f4
iend
    dd 0x7d0
    dd SCALE_1
    dd WHITELIST_BEGIN
    dd 0x41252a  ; BulletManager::initialize
    dd 0x41264a  ; BulletManager::destroy_all
    dd 0x417678  ; BulletManager::sub_417650
    dd 0x417a43  ; BulletManager::sub_417a30
    dd 0x417cda  ; BulletManager::sub_417ca0
    dd WHITELIST_END

    dd 0x7d1
    dd SCALE_1
    dd WHITELIST_BEGIN
    dd 0x4123be  ; BulletManager::constructor
    dd 0x41285a  ; BulletManager::destructor
    dd 0x4128cc  ; BulletManager::operator new
    dd WHITELIST_END

    dd 0x9bf634  ; size of bullet array
    dd SCALE_SIZE
    dd WHITELIST_BEGIN
    dd 0x412616  ; BulletManager::destroy_all
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
    dd 0x439075 - 4  ; LaserManager::allocate_new_laser
    ; The rest are inlined calls to the above function.
    ; Find them via crossrefs to the Laser subclass constructors, as well as crossrefs to
    ; the subclass vtables in case a constructor was inlined.
    dd 0x43b7e3 - 4
    dd 0x43c534 - 4
    dd 0x43da2a - 4
    dd 0x43e75f - 4
    dd WHITELIST_END
    dd LIST_END

cancel_replacements:  ; HEADER: AUTO
istruc ListHeader
    at ListHeader.old_cap, dd 0x1000
    at ListHeader.elem_size, dd 0xc1c
iend
    dd 0x1258  ; array length (includes non-cancel items)
    dd SCALE_1
    dd WHITELIST_BEGIN
    dd 0x434dfe  ; ItemManager::constructor 
    dd 0x434f99  ; ItemManager::destructor 
    dd 0x43500d  ; ItemManager::operator new
    dd 0x4359e9  ; ItemManager::on_tick__body 
    dd 0x435ec6  ; ItemManager::on_draw__body 
    dd 0x43644e  ; ItemManager::sub_436440 
    dd WHITELIST_END

    dd 0xde21a0  ; array size
    dd SCALE_SIZE
    dd WHITELIST_BEGIN
    dd 0x419906  ; ItemManager::destroy_all
    dd WHITELIST_END

    dd 0x1000  ; cancel array length
    dd SCALE_1
    dd WHITELIST_BEGIN
    dd 0x4199bc - 4  ; ItemManager::destroy_all
    dd WHITELIST_END

    dd LIST_END

bullet_mgr_layout:  ; HEADER: AUTO
istruc LayoutHeader
    at LayoutHeader.location, dd LOCATION_PTR(0x4e6a08)
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
    at LayoutHeader.location, dd LOCATION_PTR(0x4e6b64)
    at LayoutHeader.offset_to_replacements, dd item_mgr_layout.replacements - item_mgr_layout
iend
    dd REGION_NORMAL(0)
    dd REGION_ARRAY(0x1c5854, CAPID_CANCEL, SCALE_SIZE)
    dd REGION_NORMAL(0xde21b4)
    dd REGION_END(0xde21e8)
.replacements:
    dd DWORD_RANGE_INCLUSIVE(0xde21b4, 0xde21e8)
    dd WHITELIST_BEGIN
    dd 0x419935  ; ItemManager::destroy_all  (normal item freelist)
    dd 0x4199a2  ; ItemManager::destroy_all  (cancel item freelist)
    dd 0x436042  ; ItemManager::sub_436030  (cancel item freelist.next)
    dd 0x435119  ; ItemManager::on_tick__body  (num items alive)
    dd 0x4359c0  ; ItemManager::on_tick__body  (num items alive)
    dd 0x417385  ; sub_4172e0  (some cancel counter)
    dd 0x4173be  ; sub_4172e0  (some cancel counter)
    dd 0x4173e8  ; sub_4172e0  (some cancel counter)
    dd 0x417405  ; sub_4172e0  (some cancel counter)
    dd 0x419911  ; ItemManager::destroy_all  (some cancel counter)
    dd 0x41d704  ; sub_41d6f0  (some cancel counter)
    dd 0x41d820  ; sub_41d740  (some cancel counter)
    dd 0x4217a6  ; sub_4215f0  (some cancel counter)
    dd 0x436075  ; ItemManager::sub_436030  (some cancel counter)
    dd 0x436093  ; ItemManager::sub_436030  (some cancel counter)
    dd 0x4360af  ; ItemManager::sub_436030  (some cancel counter)
    dd 0x44f73b  ; sub_44f6f0  (some cancel counter)
    dd 0x43510f  ; ItemManager::on_tick__body  (cancel items this frame)
    dd 0x436068  ; ItemManager::sub_436030  (cancel items this frame)
    dd 0x4362a4  ; ItemManager::sub_436030  (cancel items this frame)
    dd 0x41991c  ; ItemManager::destroy_all  (always zero, copied to cancels)
    dd 0x43605c  ; ItemManager::sub_436030  (always zero, copied to cancels)
    dd 0x4361d7  ; ItemManager::sub_436030  (always zero, copied to cancels)
    dd 0x419926  ; ItemManager::destroy_all  (leftover ufos field?)
    dd 0x434e11  ; ItemManager::constructor  (ItemManager size)
    dd 0x434fe6  ; ItemManager::operator new  (ItemManager size)
    dd 0x435020  ; ItemManager::operator new  (ItemManager size)
    dd WHITELIST_END
    dd LIST_END

perf_fix_data:  ; HEADER: AUTO
    dd 0

iat_funcs:  ; HEADER: AUTO
.GetLastError: dd 0x4b8094
.GetModuleHandleA: dd 0
.GetModuleHandleW: dd 0x4b812c
.GetProcAddress: dd 0x4b80f8
.MessageBoxA: dd 0x4b8248

corefuncs:  ; HEADER: AUTO
.malloc: dd 0x48a697
