; AUTO_PREFIX: ExpHP.bullet-cap.

%include "util.asm"
%include "common.asm"

; Address range spanned by .text
address_range:  ; HEADER: AUTO
    dd 0x401000
    dd 0x4ac7ca

bullet_replacements:  ; HEADER: AUTO
istruc CapGameData
    at CapGameData.old_cap, dd 0x7d0
    at CapGameData.elem_size, dd 0xfa0
iend
    dd 0x7d0
    dd SCALE_1
    dd WHITELIST_BEGIN
    dd 0x423a64  ; BulletManager::destroy_all
    dd 0x423c94  ; BulletManager::operator new
    dd 0x4294c9  ; BulletManager::cancel_bullets_in_rectangle_as_bomb
    dd 0x4297b0  ; BulletManager::cancel_all
    dd WHITELIST_END

    dd 0x7d1
    dd SCALE_1
    dd WHITELIST_BEGIN
    dd 0x423b33  ; BulletManager::operator new
    dd 0x423b5e  ; BulletManager::operator new
    dd 0x423dc0  ; BulletManager::operator delete
    dd WHITELIST_END

    dd 0x7a21a0  ; size of bullet array (including dummy)
    dd SCALE_SIZE
    dd WHITELIST_BEGIN
    dd 0x42399f  ; BulletManager::destroy_all
    dd WHITELIST_END

    dd 0x1f40  ; size of anmid array
    dd SCALE_FIXED(4)
    dd WHITELIST_BEGIN
    dd 0x4239ba  ; BulletManager::destroy_all
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
    dd 0x448935 - 4  ; LaserManager::allocate_new_laser
    ; The rest are inlined calls to the above function.
    ; Found via crossrefs to LaserLine::constructor
    dd 0x4274b2 - 4  ; Bullet::run_ex
    dd 0x44b4e9 - 4  ; LaserLine::cancel_as_bomb_rectangle
    dd 0x44c370 - 4  ; LaserLine::cancel_as_bomb_circle
    dd 0x44d90b - 4  ; LaserInfinite::cancel_as_bomb_rectangle
    dd 0x44e753 - 4  ; LaserInfinite::cancel_as_bomb_circle
    ; This list was double checked by searching for the count offset (0x798)
    ; and filtering for instructions that contain 0x200. (same 6 results)
    dd WHITELIST_END
    dd LIST_END

cancel_replacements:  ; HEADER: AUTO
istruc CapGameData
    at CapGameData.old_cap, dd 0x1000
    at CapGameData.elem_size, dd 0xc94
iend
    dd 0x1000  ; num cancel items
    dd SCALE_1
    dd WHITELIST_BEGIN
    dd 0x42aae3 - 4 ; ItemManager::destroy_all
    dd WHITELIST_END

    dd 0x1258  ; array length (includes non-cancel items)
    dd SCALE_1
    dd WHITELIST_BEGIN
    dd 0x445864  ; ItemManager::operator new
    dd 0x445a3b  ; ItemManager::operator delete
    dd 0x4467fd  ; ItemManager::on_tick__body
    dd 0x446d98  ; ItemManager::on_draw_21__body
    dd WHITELIST_END

    dd 0xe6bae0  ; array size
    dd SCALE_SIZE
    dd WHITELIST_BEGIN
    dd 0x42aa36  ; ItemManager::destroy_all
    dd WHITELIST_END

    dd LIST_END

bullet_mgr_layout:  ; HEADER: AUTO
istruc LayoutHeader
    at LayoutHeader.offset_to_replacements, dd bullet_mgr_layout.replacements - bullet_mgr_layout
iend
    dd REGION_NORMAL(0)
    dd REGION_ARRAY(0xec, CAPID_BULLET, SCALE_SIZE)
    dd REGION_ARRAY(0x7a228c, CAPID_BULLET, SCALE_FIXED(4))
    dd REGION_NORMAL(0x7a41d0)
    dd REGION_END(0x7a41f8)
.replacements:
    dd REP_OFFSET(0x7a2254)  ; offset of dummy bullet state
    dd WHITELIST_BEGIN
    dd 0x4239c1  ; BulletManager::destroy_all
    dd 0x423bcd  ; BulletManager::operator new
    dd WHITELIST_END

    dd REP_OFFSET(0x7a228c)  ; anm id array
    dd WHITELIST_BEGIN
    dd 0x4239c7  ; BulletManager::destroy_all
    dd 0x423b53  ; BulletManager::operator new
    dd 0x428fd7  ; Bullet::cancel
    dd 0x428fef  ; Bullet::cancel
    dd 0x4298ff  ; BulletManager::cancel_all
    dd 0x429917  ; BulletManager::cancel_all
    dd WHITELIST_END

    dd REP_OFFSET(0x7a41d0)  ; UM specific counter
    dd WHITELIST_BEGIN
    dd 0x423aa5  ; BulletManager::destroy_all
    dd 0x429158  ; gen_items_from_et_cancel
    dd 0x42915f  ; gen_items_from_et_cancel
    dd 0x4291e2  ; gen_items_from_et_cancel
    dd WHITELIST_END

    dd REP_OFFSET_RANGE(0x7a41d8, 0x7a41e8)
    dd WHITELIST_BEGIN
    dd 0x409950  ; BulletManager::sub_409940  ()
    dd 0x40e4ea  ; CardMiko::__on_tick_2  (iter_current)
    dd 0x41056c  ; CardSumireko::__on_tick_2  (iter_current)
    dd 0x410658  ; CardSumireko::__on_tick_2  (iter_current)
    dd 0x422af8  ; BombSakuya::on_tick  (iter_current)
    dd 0x422b1f  ; BombSakuya::on_tick  (iter_current)
    dd 0x422ba9  ; BombSakuya::on_tick  (iter_current)
    dd 0x422bcf  ; BombSakuya::on_tick  (iter_current)
    dd 0x424c86  ; BulletManager::on_tick__body  (iter_current)
    dd 0x424e36  ; BulletManager::on_tick__body  (iter_current)
    dd 0x429271  ; BulletManager::cancel_radius  (iter_current)
    dd 0x429319  ; BulletManager::cancel_radius  (iter_current)
    dd 0x429391  ; BulletManager::cancel_radius_as_bomb  (iter_current)
    dd 0x42944b  ; BulletManager::cancel_radius_as_bomb  (iter_current)
    dd 0x438dae  ; Enemy::ecl_func_set_1_6bs  (iter_current)
    dd 0x438fdd  ; Enemy::ecl_func_set_1_6bs  (iter_current)
    dd 0x439333  ; Enemy::ecl_func_set_4_ex  (iter_current)
    dd 0x43943a  ; Enemy::ecl_func_set_4_ex  (iter_current)
    dd 0x439375  ; Enemy::ecl_func_set_4_ex  (iter_current_2)
    dd 0x43940b  ; Enemy::ecl_func_set_4_ex  (iter_current_2)
    dd 0x40e4e4  ; CardMiko::__on_tick_2  ()
    dd 0x40e4f7  ; CardMiko::__on_tick_2  (iter_next)
    dd 0x40e505  ; CardMiko::__on_tick_2  (iter_next)
    dd 0x41057e  ; CardSumireko::__on_tick_2  (iter_next)
    dd 0x410652  ; CardSumireko::__on_tick_2  ()
    dd 0x410665  ; CardSumireko::__on_tick_2  (iter_next)
    dd 0x41067a  ; CardSumireko::__on_tick_2  (iter_next)
    dd 0x422b05  ; BombSakuya::on_tick  (iter_next)
    dd 0x422b19  ; BombSakuya::on_tick  ()
    dd 0x422b2c  ; BombSakuya::on_tick  (iter_next)
    dd 0x422b3a  ; BombSakuya::on_tick  (iter_next)
    dd 0x422bb6  ; BombSakuya::on_tick  (iter_next)
    dd 0x422bc9  ; BombSakuya::on_tick  ()
    dd 0x422bdc  ; BombSakuya::on_tick  (iter_next)
    dd 0x422bea  ; BombSakuya::on_tick  (iter_next)
    dd 0x424c7a  ; BulletManager::on_tick__body  ( )
    dd 0x429313  ; BulletManager::cancel_radius  ()
    dd 0x429326  ; BulletManager::cancel_radius  (iter_next)
    dd 0x429341  ; BulletManager::cancel_radius  (iter_next)
    dd 0x429356  ; BulletManager::cancel_radius  (iter_next)
    dd 0x4293a2  ; BulletManager::cancel_radius_as_bomb  (iter_next)
    dd 0x429445  ; BulletManager::cancel_radius_as_bomb  ()
    dd 0x429458  ; BulletManager::cancel_radius_as_bomb  (iter_next)
    dd 0x42947e  ; BulletManager::cancel_radius_as_bomb  (iter_next)
    dd 0x429493  ; BulletManager::cancel_radius_as_bomb  (iter_next)
    dd 0x438dbf  ; Enemy::ecl_func_set_1_6bs  (iter_next)
    dd 0x438fd7  ; Enemy::ecl_func_set_1_6bs  ()
    dd 0x438ff5  ; Enemy::ecl_func_set_1_6bs  (iter_next)
    dd 0x43900e  ; Enemy::ecl_func_set_1_6bs  (iter_next)
    dd 0x439344  ; Enemy::ecl_func_set_4_ex  (iter_next)
    dd 0x439434  ; Enemy::ecl_func_set_4_ex  ()
    dd 0x439447  ; Enemy::ecl_func_set_4_ex  (iter_next)
    dd 0x43945f  ; Enemy::ecl_func_set_4_ex  (iter_next)
    dd 0x43946d  ; Enemy::ecl_func_set_4_ex  (iter_next)
    dd 0x439386  ; Enemy::ecl_func_set_4_ex  (iter_next_2)
    dd 0x439405  ; Enemy::ecl_func_set_4_ex  ()
    dd 0x439418  ; Enemy::ecl_func_set_4_ex  (iter_next_2)
    dd 0x43942a  ; Enemy::ecl_func_set_4_ex  (iter_next_2)
    dd WHITELIST_END

    dd REP_OFFSET(0x7a41e8)  ; cancel-related counter
    dd WHITELIST_BEGIN
    dd 0x40eb27  ; CardTenshi::__on_tick_2
    dd 0x40eb58  ; CardTenshi::__on_tick_2
    dd 0x40eb6c  ; CardTenshi::__on_tick_2
    dd 0x429302  ; BulletManager::cancel_radius
    dd 0x42942f  ; BulletManager::cancel_radius_as_bomb
    dd 0x42976a  ; BulletManager::cancel_bullets_in_rectangle_as_bomb
    dd 0x44af8a  ; LaserLine::cancel_as_bomb_rectangle
    dd 0x44be90  ; LaserLine::cancel_as_bomb_circle
    dd 0x44d3da  ; LaserInfinite::cancel_as_bomb_rectangle
    dd 0x44e200  ; LaserInfinite::cancel_as_bomb_circle
    dd 0x45193f  ; LaserCurve::cancel_as_bomb_rectangle
    dd 0x45229b  ; LaserCurve::cancel_as_bomb_circle
    dd WHITELIST_END

    dd REP_OFFSET(0x7a41ec)  ; bullet.anm
    dd REPLACE_ALL  ; 48 usages

    dd REP_OFFSET(0x7a41f0)  ; UM specific: flag that enables a counter
    dd WHITELIST_BEGIN
    dd 0x40d5ab  ; ???
    dd 0x423acb  ; BulletManager::destroy_all
    dd 0x42498d  ; ???
    dd WHITELIST_END

    dd REP_OFFSET(0x7a41f4)  ; UM specific: counter enabled by a flag
    dd WHITELIST_BEGIN
    dd 0x423ad5  ; BulletManager::destroy_all
    dd 0x42499a  ; ???
    dd 0x4249a5  ; ???
    dd WHITELIST_END

    dd REP_OFFSET(0x7a41f8)  ; size of BulletManager
    dd WHITELIST_BEGIN
    dd 0x423b17  ; BulletManager::operator new
    dd 0x423b58  ; BulletManager::operator new
    dd 0x423de0  ; BulletManager::operator delete
    dd 0x4ac001  ; BulletManager::__destruction_related
    dd WHITELIST_END

    dd LIST_END

item_mgr_layout:  ; HEADER: AUTO
istruc LayoutHeader
    at LayoutHeader.offset_to_replacements, dd item_mgr_layout.replacements - item_mgr_layout
iend
    dd REGION_NORMAL(0)
    dd REGION_ARRAY(0x1d7af4, CAPID_CANCEL, SCALE_SIZE)
    dd REGION_NORMAL(0xe6baf4)
    dd REGION_END(0xe6bb28)
.replacements:
    ; freelist head nodes, lolk slowdown factor
    dd REP_OFFSET_RANGE(0xe6baf4, 0xe6bb28)
    dd WHITELIST_BEGIN
    dd 0x42aa5b  ; ItemManager::destroy_all
    dd 0x446f97  ; ItemManager::spawn_item
    dd 0x42aac9  ; ItemManager::destroy_all
    dd 0x44713c  ; ItemManager::spawn_item
    dd 0x42ab29  ; ItemManager::destroy_all
    dd 0x445c11  ; ItemManager::on_tick__body
    dd 0x445c71  ; ItemManager::on_tick__body
    dd 0x445c8e  ; ItemManager::on_tick__body
    dd 0x44680b  ; ItemManager::on_tick__body
    dd 0x446825  ; ItemManager::on_tick__body
    dd 0x445acf  ; ItemManager::on_tick__body
    dd 0x4467c6  ; ItemManager::on_tick__body
    dd 0x42aa41  ; ItemManager::destroy_all
    dd 0x446f5b  ; ItemManager::spawn_item
    dd 0x44715c  ; ItemManager::spawn_item
    dd 0x445ac5  ; ItemManager::on_tick__body
    dd 0x447156  ; ItemManager::spawn_item
    dd 0x42aa4c  ; ItemManager::destroy_all
    dd 0x44714a  ; ItemManager::spawn_item
    dd WHITELIST_END

    dd REP_OFFSET(0xe6bb28)  ; struct size
    dd WHITELIST_BEGIN
    dd 0x445848  ; ItemManager::operator new
    dd 0x445881  ; ItemManager::operator new
    dd 0x445a55  ; ItemManager::operator delete
    dd 0x4ac2d1  ; ItemManager::sub_499a60_destruction_related
    dd WHITELIST_END

    dd LIST_END

perf_fix_data:  ; HEADER: AUTO
    dd 0

iat_funcs:  ; HEADER: AUTO
.GetLastError: dd 0x4ad098
.GetModuleHandleA: dd 0
.GetModuleHandleW: dd 0x4ad1b4
.GetProcAddress: dd 0x4ad1b0
.MessageBoxA: dd 0x4ad218

corefuncs:  ; HEADER: AUTO
.malloc: dd 0x48dc71
