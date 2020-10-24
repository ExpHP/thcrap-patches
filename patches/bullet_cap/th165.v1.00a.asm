; AUTO_PREFIX: ExpHP.bullet-cap.

%include "util.asm"
%include "common.asm"

; Address range spanned by .text
address_range:  ; HEADER: AUTO
    dd 0x401000
    dd 0x4953fa

bullet_replacements:  ; HEADER: AUTO
istruc ListHeader
    at ListHeader.old_cap, dd 0x7d0
    at ListHeader.elem_size, dd 0xe8c
iend
    dd 0x7d0
    dd SCALE_1
    dd WHITELIST_BEGIN
    dd 0x40eb34  ; BulletManager::sub_40ea50 if (edi s< 0x7d0) then 32 @ 0x40ead0 else 56 @ 0x40eb3a
    dd 0x40ed53  ; BulletManager::operator new if (edi s< 0x7d0) then 120 @ 0x40ecf0 else 144 @ 0x40ed59
    dd 0x414596  ; BulletManager::sub_414570 [esp + 0x24 {var_1c}].d = 0x7d0
    dd 0x4148ec  ; BulletManager::sub_4148d0 edi = 0x7d0
    dd 0x414a09  ; BulletManager::sub_4149f0 edi = 0x7d0
    ; dd 0x426fc6  ; sub_4266a0 goto 378 @ 0x42779a
    ; dd 0x43c621  ; Trophy::sub_43c530
    ; dd 0x447593  ; sub_446f60 [edi + 0x130].d = 0x7d0
    dd 0x44985b  ; sub_449660 [esp + 0x10 {var_f0}].d = 0x7d0
    dd WHITELIST_END

    dd 0x7d1
    dd SCALE_1
    dd WHITELIST_BEGIN
    dd 0x40ebc3  ; BulletManager::operator new
    dd 0x40ebea  ; BulletManager::operator new
    dd 0x40ec0c  ; BulletManager::operator new
    dd 0x40ec1f  ; BulletManager::operator new
    dd 0x40ee70  ; BulletManager::operator free
    dd 0x40ee95  ; BulletManager::operator free
    ; dd 0x464050 sub_463fe0
    dd 0x494d78  ; BulletManager::sub_494d72_destruction_related
    dd WHITELIST_END

    dd 0x71b44c  ; size of bullet array
    dd SCALE_SIZE
    dd WHITELIST_BEGIN
    dd 0x40ea6f  ; BulletManager::destroy_all
    dd WHITELIST_END

    dd 0x1f40  ; size of anmid array
    dd SCALE_FIXED(4)
    dd WHITELIST_BEGIN
    dd 0x40ea8a  ; BulletManager::destroy_all
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
    dd 0x42cb65 - 4  ; LaserManager::allocate_new_laser
    ; The rest are inlined calls to the above function.
    ; Found via crossrefs to LaserLine::constructor
    dd 0x42f663 - 4
    dd 0x430580 - 4
    dd 0x431d16 - 4
    dd 0x433098 - 4
    ; Found via crossrefs to VTABLE_LASER_CURVE
    dd 0x436a35 - 4
    ; This list was double checked by searching for the count offset (0x5e4)
    ; and filtering for instructions that contain 0x200. (same 6 results)
    dd WHITELIST_END
    dd LIST_END

cancel_replacements:  ; HEADER: AUTO
istruc ListHeader
    at ListHeader.old_cap, dd 200
    at ListHeader.elem_size, dd 0x634
iend
    dd 200  ; num cancel items
    dd SCALE_1
    dd WHITELIST_BEGIN
    ; The initial part of spawn_item got inlined everywhere leading to a ton of references.
    ; To find these I had to search for the stride, 0x634.
    dd 0x40f046 - 4  ; Bullet::on_tick
    dd 0x40f0e5 - 4  ; Bullet::on_tick
    dd 0x40f194 - 4  ; Bullet::on_tick
    dd 0x40f254 - 4  ; Bullet::on_tick
    ; (ignore several results where 0x634 is used as an offset into Bullet)
    dd 0x41681b - 4  ; EnemyDrop::eject_all_drops
    dd 0x419c5a - 4  ; sub_419b70
    dd 0x42bb46 - 4  ; ItemManager::operator new
    dd 0x42bcc9 - 4  ; ItemManager::operator free
    dd 0x42bd6f - 4  ; ItemManager::on_tick__body
    dd 0x42c12b - 4  ; ItemManager::on_draw
    dd 0x42c209 - 4  ; ItemManager::spawn_item
    dd 0x42c224 - 4  ; ItemManager::spawn_item
    dd 0x42f1ae - 4  ; sub_42eea0
    dd 0x4300f4 - 4  ; sub_42ff40
    dd 0x4308c4 - 4  ; sub_430630
    dd 0x43179c - 4  ; sub_4314d0
    dd 0x43196b - 4  ; sub_4314d0
    dd 0x432c2b - 4  ; sub_432a80
    dd 0x433418 - 4  ; sub_433130
    dd 0x436771 - 4  ; sub_436560
    dd 0x4372e6 - 4  ; sub_4371d0
    dd WHITELIST_END

    dd 0x4d8a0  ; array size
    dd SCALE_SIZE
    dd WHITELIST_BEGIN
    dd 0x415b9c  ; ItemManager::destroy_all
    dd WHITELIST_END

    dd LIST_END

bullet_mgr_layout:  ; HEADER: AUTO
istruc LayoutHeader
    at LayoutHeader.location, dd LOCATION_PTR(0x4b550c)
    at LayoutHeader.offset_to_replacements, dd bullet_mgr_layout.replacements - bullet_mgr_layout
iend
    dd REGION_NORMAL(0)
    dd REGION_ARRAY(0x9c, CAPID_BULLET, SCALE_SIZE)
    dd REGION_ARRAY(0x71b4e8, CAPID_BULLET, SCALE_SIZE)
    dd REGION_ARRAY(0xe36934, CAPID_BULLET, SCALE_FIXED(4))
    dd REGION_ARRAY(0xe38878, CAPID_BULLET, SCALE_FIXED(4))
    dd REGION_NORMAL(0xe3a7bc)
    dd REGION_END(0xe3a7d0)
.replacements:
    dd 0x71b4b0  ; offset of dummy bullet state
    dd WHITELIST_BEGIN
    dd 0x40ea91  ; BulletManager::destroy all
    dd 0x40ec8e  ; BulletManager::operator new
    dd WHITELIST_END

    dd 0x71b4e8  ; LoLK snapshot bullet array
    dd WHITELIST_BEGIN
    dd 0x40ebf5  ; BulletManager::operator new
    dd 0x40ee7b  ; BulletManager::operator free
    dd WHITELIST_END

    dd 0xe36934  ; anm id array
    dd WHITELIST_BEGIN
    dd 0x40ea97  ; BulletManager::destroy_all 
    dd 0x40ec07  ; BulletManager::operator new
    dd 0x41427c  ; sub_4141f0
    dd 0x414ab2  ; BulletManager::sub_4149f0
    dd WHITELIST_END

    dd 0xe38878  ; LoLK snapshot anm id array
    dd WHITELIST_BEGIN
    dd 0x40ec1a   ; BulletManager::operator new
    dd WHITELIST_END

    dd 0xe3a7bc  ; Related to cancels
    dd WHITELIST_BEGIN
    dd 0x40eb68  ; BulletManager::destroy_all
    dd WHITELIST_END

    dd 0xe3a7c4  ; "current" pointer for iteration
    dd REPLACE_ALL  ; 12 usages
    dd 0xe3a7c8  ; "next" pointer for iteration
    dd REPLACE_ALL  ; 18 usages

    dd 0xe3a7cc  ; bullet.anm
    dd REPLACE_ALL  ; 38 usages

    dd 0xe3a7d0  ; size of BulletManager
    dd WHITELIST_BEGIN
    dd 0x40eba7  ; BulletManager::operator new
    dd 0x40ec13  ; BulletManager::operator new
    dd 0x40eeab  ; BulletManager::operator free
    dd 0x494d61  ; BulletManager::sub_494d60_destruction_related
    dd WHITELIST_END

    dd LIST_END

item_mgr_layout:  ; HEADER: AUTO
istruc LayoutHeader
    at LayoutHeader.location, dd LOCATION_PTR(0x4b5634)
    at LayoutHeader.offset_to_replacements, dd item_mgr_layout.replacements - item_mgr_layout
iend
    dd REGION_NORMAL(0)
    dd REGION_ARRAY(0x10, CAPID_CANCEL, SCALE_SIZE)
    dd REGION_NORMAL(0x4d8b0)
    dd REGION_END(0x4d8c4)
.replacements:
    dd 0x4d8b0  ; next item index
    dd REPLACE_ALL  ; 19 instances

    dd 0x4d8b4  ; num items onscreen
    dd REPLACE_ALL  ; 19 instances

    dd 0x4d8b8  ; camera charge multiplier
    dd WHITELIST_BEGIN
    dd 0x415bc4  ; ItemManager::destroy_all
    dd 0x41f677  ; Enemy::ecl_run_over_300
    dd 0x42bbcb  ; ItemManager::operator new
    dd 0x42bf7b  ; ItemManager::on_tick__body
    dd 0x42bf8e  ; ItemManager::on_tick__body
    dd WHITELIST_END

    dd 0x4d8bc  ; on_tick, in a rather unusual location
    dd WHITELIST_BEGIN
    dd 0x429d41  ; GameThread::on_tick_0f
    dd 0x429f3d  ; GameThread::on_tick_0f
    dd 0x42bb9d  ; ItemManager::operator new
    dd 0x42bc25  ; ItemManager::operator free
    dd WHITELIST_END

    dd 0x4d8c0  ; on_draw, in a rather unusual location
    dd WHITELIST_BEGIN
    dd 0x429d4b  ; GameThread::on_tick_0f
    dd 0x429f47  ; GameThread::on_tick_0f
    dd 0x42bbb9  ; ItemManager::operator new
    dd 0x42bc75  ; ItemManager::operator free
    dd WHITELIST_END

    dd 0x4d8c4  ; struct size
    dd WHITELIST_BEGIN
    dd 0x42bb26  ; ItemManager::operator new
    dd 0x42bb5c  ; ItemManager::operator new
    dd 0x42bce2  ; ItemManager::operator free
    dd 0x494f51  ; ItemManager::sub_494f50_destruction_related
    dd WHITELIST_END

    dd LIST_END

perf_fix_data:  ; HEADER: AUTO
    dd 0

iat_funcs:  ; HEADER: AUTO
.GetLastError: dd 0x49608c
.GetModuleHandleA: dd 0
.GetModuleHandleW: dd 0x49618c
.GetProcAddress: dd 0x4960d4
.MessageBoxA: dd 0x496204
