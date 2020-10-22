; AUTO_PREFIX: ExpHP.bullet-cap.

%include "util.asm"
%include "common.asm"

; Address range spanned by .text
address_range:  ; HEADER: AUTO
    dd 0x401000
    dd 0x4bd92c

bullet_replacements:  ; HEADER: AUTO
istruc ListHeader
    at ListHeader.old_cap, dd 0x7d0
    at ListHeader.elem_size, dd 0x1494
iend
    dd 0x7d0
    dd SCALE_1
    dd WHITELIST_BEGIN
    dd 0x4128b2  ; BulletManager::write_autosave_data
    dd 0x4129cd  ; BulletManager::write_autosave_data
    dd 0x418f13  ; BulletManager::initialize
    dd 0x419024  ; BulletManager::destroy_all
    dd 0x41e871  ; BulletManager::sub_41e850_cancels_bullets
    dd 0x41ec00  ; BulletManager::sub_41ebf0_cancels_bullets
    dd 0x41eebd  ; BulletManager::sub_41ee80
    ; NOT dd 0x4366fc  ; Gui::on_tick   checking enemy life
    dd 0x43b7ff  ; BulletManager::store_snapshot
    dd 0x43b8fc  ; BulletManager::restore_snapshot
    dd 0x43b9a1  ; BulletManager::restore_snapshot
    ; NOT dd 0x44045f  ; sub_440420  adding score
    dd WHITELIST_END

    dd 0x7d1
    dd SCALE_1
    dd WHITELIST_BEGIN
    dd 0x418c95  ; BulletManager::constructor
    dd 0x418cb5  ; BulletManager::constructor
    dd 0x418cda  ; BulletManager::constructor
    dd 0x418ced  ; BulletManager::constructor
    dd 0x419175  ; BulletManager::destructor
    dd 0x41919a  ; BulletManager::destructor
    dd 0x4bcfd6  ; sub_4bcfd0_destructor_related
    dd 0x4bd016  ; sub_4bd010_destructor_related
    dd WHITELIST_END

    ; Size of anm id array
    dd 0x1f44
    dd SCALE_FIXED(4)
    dd WHITELIST_BEGIN
    dd 0x412c90  ; BulletManager::read_autosave_data
    dd 0x43b9a7  ; BulletManager::restore_snapshot
    dd WHITELIST_END

    ; Offset of anm id array relative to snapshot id array (= negative size of id arary)
    dd -0x1f44
    dd SCALE_FIXED(4)
    dd WHITELIST_BEGIN
    dd 0x43b822   ; BulletManager::store_snapshot
    dd WHITELIST_END

    dd 0xa0d8d4  ; size of bullet array
    dd SCALE_SIZE
    dd WHITELIST_BEGIN
    dd 0x418f5f  ; BulletManager::destroy_all
    dd 0x43b7de  ; BulletManager::store_snapshot
    dd 0x43b885  ; BulletManager::restore_snapshot
    dd WHITELIST_END

    dd 0x1f40  ; size of anmid array (without dummy)
    dd SCALE_FIXED(4)
    dd WHITELIST_BEGIN
    dd 0x418f7a  ; BulletManager::destroy_all
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
    dd 0x4419e5 - 4  ; LaserManager::allocate_new_laser
    ; The rest are inlined calls to the above function.
    ; Found via crossrefs to LaserLine::constructor
    dd 0x41c462 - 4
    dd 0x444233 - 4
    dd 0x445094 - 4
    dd 0x44661d - 4
    dd 0x447443 - 4
    ; Found via crossrefs to LaserInfinite::constructor
    dd 0x41c2bf - 4
    ; Found via crossrefs to LaserCurve::constructor
    dd 0x44a800 - 4
    ; This list was double checked by searching for the count offset (0x5e4)
    ; and filtering for instructions that contain 0x200. (same 12 results)
    dd WHITELIST_END
    dd LIST_END

cancel_replacements:  ; HEADER: AUTO
istruc ListHeader
    at ListHeader.old_cap, dd 0x1000
    at ListHeader.elem_size, dd 0xc88
iend
    dd 0x1000  ; num cancel items
    dd SCALE_1
    dd WHITELIST_BEGIN
    dd 0x4212e1 - 4  ; ItemManager::destroy_all
    dd 0x43bb55 - 4  ; ItemManager::restore_snapshot
    dd 0x412fb2 - 4  ; ItemManager::write_autosave_data
    dd WHITELIST_END

    dd 0x1258  ; array length (includes non-cancel items)
    dd SCALE_1
    dd WHITELIST_BEGIN
    dd 0x43f454  ; ItemManager::constructor
    dd 0x43f471  ; ItemManager::constructor
    dd 0x43f4cc  ; ItemManager::sub_43f4c0
    dd 0x43f4f6  ; ItemManager::sub_43f4f0
    dd 0x43f6e4  ; ItemManager::destructor
    dd 0x43f709  ; ItemManager::destructor
    dd 0x440157  ; ItemManager::on_tick__body
    dd 0x440766  ; ItemManager::on_draw__body
    dd 0x440d8e  ; ItemManager::sub_440d80
    dd WHITELIST_END

    dd 0xe5dec0  ; array size
    dd SCALE_SIZE
    dd WHITELIST_BEGIN
    dd 0x421236  ; ItemManager::destroy_all
    dd WHITELIST_END

    dd LIST_END

bullet_mgr_layout:  ; HEADER: AUTO
istruc LayoutHeader
    at LayoutHeader.location, dd LOCATION_PTR(0x4e9a6c)
    at LayoutHeader.offset_to_replacements, dd bullet_mgr_layout.replacements - bullet_mgr_layout
iend
    dd REGION_NORMAL(0)
    dd REGION_ARRAY(0x98, CAPID_BULLET, SCALE_SIZE)
    dd REGION_ARRAY(0xa0d96c, CAPID_BULLET, SCALE_SIZE)
    dd REGION_ARRAY(0x141b240, CAPID_BULLET, SCALE_FIXED(4))
    dd REGION_ARRAY(0x141d184, CAPID_BULLET, SCALE_FIXED(4))
    dd REGION_NORMAL(0x141f0c8)
    dd REGION_END(0x141f0dc)
.replacements:
    ; offset of dummy bullet state
    dd 0xa0d162
    dd WHITELIST_BEGIN
    dd 0x418e48  ; BulletManager::initialize
    dd 0x418f81  ; BulletManager::destroy_all
    dd WHITELIST_END

    ; LoLK snapshot bullet array
    dd 0xa0d96c
    dd WHITELIST_BEGIN
    dd 0x4128ba  ; BulletManager::write_autosave_data
    dd 0x412aa2  ; BulletManager::read_autosave_data
    dd 0x418cc0  ; BulletManager::constructor
    dd 0x419180  ; BulletManager::destructor
    dd 0x43b7eb  ; BulletManager::store_snapshot
    dd 0x43b88b  ; BulletManager::restore_snapshot
    dd WHITELIST_END

    ; anm id array
    dd 0x141b240
    dd WHITELIST_BEGIN
    dd 0x418cd5  ; BulletManager::constructor
    dd 0x418f87  ; BulletManager::destroy_all
    dd 0x41e3a9  ; Bullet::cancel
    dd 0x41ed6d  ; BulletManager::sub_41ebf0_cancels_bullets
    dd 0x43b99a  ; BulletManager::restore_snapshot
    dd WHITELIST_END

    ; snapshot anm id array
    dd 0x141d184
    dd WHITELIST_BEGIN
    dd 0x4129c5  ; BulletManager::write_autosave_data
    dd 0x412c9b  ; BulletManager::read_autosave_data
    dd 0x418ce8  ; BulletManager::constructor
    dd 0x43b817  ; BulletManager::store_snapshot
    dd WHITELIST_END

    dd 0x141f0c8  ; Something related to cancels
    dd WHITELIST_BEGIN
    dd 0x419058  ; BulletManager::destroy_all
    dd 0x41e524  ; gen_items_from_cancel
    dd 0x41e52a  ; gen_items_from_cancel
    dd 0x43b80b  ; BulletManager::store_snapshot
    dd 0x43b8bf  ; BulletManager::restore_snapshot
    dd WHITELIST_END

    dd 0x141f0cc  ; Something related to cancels - snapshot copy
    dd WHITELIST_BEGIN
    dd 0x4129b6  ; BulletManager::write_autosave_data
    dd 0x412caa  ; BulletManager::read_autosave_data
    dd 0x43b811  ; BulletManager::store_snapshot
    dd 0x43b8b9  ; BulletManager::restore_snapshot
    dd WHITELIST_END

    dd 0x141f0d0  ; "current" pointer for iteration
    dd REPLACE_ALL  ; 27 usages

    dd 0x141f0d4  ; "next" pointer for iteration
    dd REPLACE_ALL  ; 27 usages

    dd 0x141f0d8  ; bullet.anm
    dd REPLACE_ALL  ; 43 usages

    dd 0x141f0dc  ; size of BulletManager
    dd WHITELIST_BEGIN
    dd 0x418ce1   ; BulletManager::constructor
    dd 0x4191f5   ; BulletManager::operator
    dd WHITELIST_END

    dd LIST_END

item_mgr_layout:  ; HEADER: AUTO
istruc LayoutHeader
    at LayoutHeader.location, dd LOCATION_PTR(0x4e9a9c)
    at LayoutHeader.offset_to_replacements, dd item_mgr_layout.replacements - item_mgr_layout
iend
    %push
    %define %$FIRST_INNER   0x10
    %define %$SECOND_INNER  0xe5def4
    %define %$INNER_CANCEL_BEGIN  0x1d5ec0
    %define %$INNER_CANCEL_END    0xe5dec0
    %define %$INNER_SIZE          0xe5dee4
    %define %$SIZE          0x1cbbde8
    dd REGION_NORMAL(0)
    dd REGION_ARRAY(%$FIRST_INNER + %$INNER_CANCEL_BEGIN, CAPID_CANCEL, SCALE_SIZE)
    dd REGION_NORMAL(%$FIRST_INNER + %$INNER_CANCEL_END)
    dd REGION_ARRAY(%$SECOND_INNER + %$INNER_CANCEL_BEGIN, CAPID_CANCEL, SCALE_SIZE)
    dd REGION_NORMAL(%$SECOND_INNER + %$INNER_CANCEL_END)
    dd REGION_END(%$SIZE)
.replacements:
    dd %$SECOND_INNER  ; snapshot normal item array (or full item array)
    dd WHITELIST_BEGIN
    dd 0x412e91  ; ItemManager::write_autosave_data
    dd 0x413026  ; ItemManager::read_autosave_data
    dd 0x43ba85  ; ItemManager::store_item_array
    dd 0x43bab4  ; ItemManager::restore_snapshot
    dd 0x43de0c  ; Globals::do_pointdevice_snapshot_and_autosave
    dd 0x43f47c  ; ItemManager::constructor
    dd 0x43f6ea  ; ItemManager::destructor
    dd WHITELIST_END

    dd %$SECOND_INNER + %$INNER_CANCEL_BEGIN  ; snapshot cancel item array
    dd WHITELIST_BEGIN
    dd 0x412fb7  ; ItemManager::write_autosave_data
    dd 0x4131db  ; ItemManager::read_autosave_data
    dd WHITELIST_END

    ; Freelist head nodes, lolk slowdown factor.
    ; Also size of ItemManagerInner (happens to equal offset of cancel freelist next ptr)
    dd DWORD_RANGE(%$FIRST_INNER + %$INNER_CANCEL_END, %$FIRST_INNER + %$INNER_SIZE)
    dd WHITELIST_BEGIN
    dd 0x42125b  ; ItemManager::destroy_all
    dd 0x43bac4  ; ItemManager::restore_snapshot
    dd 0x44090d  ; ItemManager::spawn_item
    dd 0x4212c7  ; ItemManager::destroy_all
    dd 0x43bb3b  ; ItemManager::restore_snapshot
    dd 0x43ba7b  ; ItemManager::store_item_array
    dd 0x43baae  ; ItemManager::restore_snapshot
    dd 0x43de02  ; Globals::do_pointdevice_snapshot_and_autosave
    dd 0x440a67  ; ItemManager::spawn_item
    dd 0x418bc4  ; ItemManager::get_lolk_slowdown_factor
    dd 0x419d07  ; Bullet::sub_419a50
    dd 0x421325  ; ItemManager::destroy_all
    dd 0x43f97f  ; ItemManager::on_tick__body
    dd 0x43f9da  ; ItemManager::on_tick__body
    dd 0x43f9ff  ; ItemManager::on_tick__body
    dd 0x440165  ; ItemManager::on_tick__body
    dd 0x440187  ; ItemManager::on_tick__body
    dd 0x443836  ; LaserLine::method_34
    dd 0x445cd4  ; LaserInfinite::method_34
    dd 0x44888a  ; LaserCurve::method_34
    dd WHITELIST_END

    ; the snapshot versions of the freelists appear to be unused because they're reconstructed on snapshot load.
    ; the snapshot copy of the item slowdown is handled by a memcpy of ItemManagerInner.

    ; fields at end of struct, and struct size
    dd DWORD_RANGE(0x1cbbdd8, %$SIZE)
    dd WHITELIST_BEGIN
    dd 0x43f87c  ; ItemManager::on_tick__body
    dd 0x440126  ; ItemManager::on_tick__body
    dd 0x421241  ; ItemManager::destroy_all
    dd 0x4408de  ; ItemManager::spawn_item
    dd 0x440a8e  ; ItemManager::spawn_item
    dd 0x440aac  ; ItemManager::spawn_item
    dd 0x440ac8  ; ItemManager::spawn_item
    dd 0x43f872  ; ItemManager::on_tick__body
    dd 0x440a81  ; ItemManager::spawn_item
    dd 0x42124c  ; ItemManager::destroy_all
    dd 0x440a75  ; ItemManager::spawn_item
    dd WHITELIST_END

    dd %$SIZE  ; struct size
    dd WHITELIST_BEGIN
    dd 0x43f48e  ; ItemManager::constructor
    dd 0x43f766  ; ItemManager::operator new
    dd WHITELIST_END

    dd LIST_END
    %pop

perf_fix_data:  ; HEADER: AUTO
    dd 0

iat_funcs:  ; HEADER: AUTO
.GetLastError: dd 0x4be094
.GetModuleHandleA: dd 0
.GetModuleHandleW: dd 0x4be130
.GetProcAddress: dd 0x4be0f8
.MessageBoxA: dd 0x4be24c
