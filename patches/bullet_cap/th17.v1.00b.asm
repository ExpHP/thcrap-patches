; AUTO_PREFIX: ExpHP.bullet-cap.

%include "util.asm"
%include "common.asm"

; Address range spanned by .text
address_range:  ; HEADER: AUTO
    dd 0x401000
    dd 0x499eba

bullet_replacements:  ; HEADER: AUTO
istruc ListHeader
    at ListHeader.old_cap, dd 0x7d0
    at ListHeader.elem_size, dd 0xe88
iend
    dd 0x7d0
    dd SCALE_1
    dd WHITELIST_BEGIN
    dd 0x414744  ; BulletManager::destroy_all
    dd 0x414964  ; BulletManager::operator new
    dd 0x419f1d  ; BulletManager::cancel_bullets_in_rectangle_as_bomb
    dd 0x41a1ee  ; BulletManager::cancel_all
    dd WHITELIST_END

    dd 0x7d1
    dd SCALE_1
    dd WHITELIST_BEGIN
    dd 0x414803  ; BulletManager::operator new
    dd 0x41482e  ; BulletManager::operator new
    dd 0x414a90  ; BulletManager::operator delete
    dd WHITELIST_END

    ; offset of dummy bullet state
    dd 0x7195bc
    dd SCALE_SIZE
    dd WHITELIST_BEGIN
    dd 0x4146a1  ; BulletManager::destroy_all
    dd 0x41489d  ; BulletManager::operator new
    dd WHITELIST_END

    ; anm id array
    dd 0x7195f4
    dd SCALE_AN_PLUS_B(1, 0)
    dd WHITELIST_BEGIN
    dd 0x4146a7  ; BulletManager::destroy_all
    dd 0x414823  ; BulletManager::operator new
    dd 0x419b4d  ; Bullet::cancel
    dd 0x41a2a3  ; BulletManager::cancel_all
    dd WHITELIST_END

    ; Related to cancels
    dd 0x71b538
    dd SCALE_AN_PLUS_B(1, 4)  ; bullet array and int array
    dd WHITELIST_BEGIN
    dd 0x414785  ; BulletManager::destroy_all
    dd 0x419c98  ; gen_items_from_et_cancel
    dd 0x438dd2  ; LaserLine::cancel_as_bomb_circle
    dd 0x4396ec  ; LaserLine::cancel
    dd 0x43b48c  ; LaserInfinite::cancel_as_bomb_circle
    dd 0x43be54  ; LaserInfinite::cancel
    dd WHITELIST_END

    ; offsets of "current" and "next" pointers used during bullet iteration.
    dd 0x71b540
    dd SCALE_AN_PLUS_B(1, 4)
    dd WHITELIST_BEGIN
    dd 0x41579e  ; BulletManager::on_tick__body
    dd 0x415924  ; BulletManager::on_tick__body
    dd 0x419d0d  ; BulletManager::cancel_bullets_in_radius
    dd 0x419db3  ; BulletManager::cancel_bullets_in_radius
    dd 0x419e0d  ; BulletManager::cancel_bullets_in_radius_as_bomb
    dd 0x419eb9  ; BulletManager::cancel_bullets_in_radius_as_bomb
    dd 0x428f74  ; BulletManager::sub_428f60
    dd 0x4290cf  ; BulletManager::sub_428f60
    dd WHITELIST_END

    dd 0x71b544
    dd SCALE_AN_PLUS_B(1, 4)
    dd WHITELIST_BEGIN
    dd 0x4157b1  ; BulletManager::on_tick__body
    dd 0x41591e  ; BulletManager::on_tick__body
    dd 0x415937  ; BulletManager::on_tick__body
    dd 0x419d1e  ; BulletManager::cancel_bullets_in_radius
    dd 0x419dad  ; BulletManager::cancel_bullets_in_radius
    dd 0x419dc6  ; BulletManager::cancel_bullets_in_radius
    dd 0x419e1e  ; BulletManager::cancel_bullets_in_radius_as_bomb
    dd 0x419eb3  ; BulletManager::cancel_bullets_in_radius_as_bomb
    dd 0x419ecc  ; BulletManager::cancel_bullets_in_radius_as_bomb
    dd 0x428f8a  ; BulletManager::sub_428f60
    dd 0x4290c9  ; BulletManager::sub_428f60
    dd 0x4290e2  ; BulletManager::sub_428f60
    dd WHITELIST_END

    dd 0x71b548  ; bullet.anm
    dd SCALE_AN_PLUS_B(1, 4)
    dd REPLACE_ALL  ; 8 usages

    dd 0x71b54c  ; size of BulletManager
    dd SCALE_AN_PLUS_B(1, 4)
    dd WHITELIST_BEGIN
    dd 0x4147e7  ; BulletManager::operator new
    dd 0x414828  ; BulletManager::operator new
    dd 0x414ab0  ; BulletManager::operator delete
    dd 0x4997e1  ; BulletManager::sub_4997e0_destruction_related
    dd WHITELIST_END

    dd 0x719508  ; size of bullet array
    dd SCALE_SIZE
    dd WHITELIST_BEGIN
    dd 0x41467f  ; BulletManager::destroy_all
    dd WHITELIST_END

    dd 0x1f40  ; size of anmid array
    dd SCALE_AN_PLUS_B(0, 4)
    dd WHITELIST_BEGIN
    dd 0x41469a  ; BulletManager::destroy_all
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
    dd 0x4355d5 - 4  ; LaserManager::allocate_new_laser
    ; The rest are inlined calls to the above function.
    ; Found via crossrefs to LaserLine::constructor
    dd 0x417f7e - 4  ; Bullet::run_ex
    dd 0x436995 - 4  ; LaserLine::method_50
    dd 0x436af1 - 4  ; LaserLine::method_50
    dd 0x4383d5 - 4  ; LaserLine::cancel_as_bomb_rectangle
    dd 0x43931a - 4  ; LaserLine::cancel_as_bomb_circle
    dd 0x43ab65 - 4  ; LaserInfinite::cancel_as_bomb_rectangle
    dd 0x43b9ff - 4  ; LaserInfinite::cancel_as_bomb_circle
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
    dd 0x41b473 - 4 ; ItemManager::destroy_all
    dd WHITELIST_END

    dd 0x1258  ; array size (includes non-cancel items)
    dd SCALE_1
    dd WHITELIST_BEGIN
    dd 0x4331f4  ; ItemManager::operator new
    dd 0x4333cb  ; ItemManager::operator delete
    dd 0x43418c  ; ItemManager::on_tick__body
    dd 0x4345a8  ; ItemManager::on_draw_21__body
    dd WHITELIST_END

    dd 0xe4b940  ; array size
    dd SCALE_SIZE
    dd WHITELIST_BEGIN
    dd 0x0041b3c6  ; ItemManager::destroy_all
    dd WHITELIST_END

    dd 0xe4b988  ; struct size
    dd SCALE_SIZE
    dd WHITELIST_BEGIN
    dd 0x4331d8  ; ItemManager::operator new
    dd 0x433211  ; ItemManager::operator new
    dd 0x4333e5  ; ItemManager::operator delete
    dd 0x499a61  ; ItemManager::sub_499a60_destruction_related
    dd WHITELIST_END

    ; freelist head nodes, lolk slowdown factor, snapshot item array
    dd DWORD_RANGE(0xe4b954, 0xe4b988)
    dd SCALE_SIZE
    dd WHITELIST_BEGIN
    dd 0x41b3eb  ; ItemManager::destroy_all  (normal freelist head)
    dd 0x4348c3  ; ItemManager::spawn_item  (normal freelist head)
    dd 0x41b459  ; ItemManager::destroy_all  (cancel freelist head)
    dd 0x434a0d  ; ItemManager::spawn_item  (cancel freelist head.next)
    dd 0x44d918  ; sub_44d8a0  (cancel freelist head.next)
    dd 0x41b4b9  ; ItemManager::destroy_all  (lolk item slowdown factor)
    dd 0x4335d2  ; ItemManager::on_tick__body  (lolk item slowdown factor)
    dd 0x433645  ; ItemManager::on_tick__body  (lolk item slowdown factor)
    dd 0x433662  ; ItemManager::on_tick__body  (lolk item slowdown factor)
    dd 0x43419a  ; ItemManager::on_tick__body  (lolk item slowdown factor)
    dd 0x4341b4  ; ItemManager::on_tick__body  (lolk item slowdown factor)
    dd 0x43345d  ; ItemManager::on_tick__body  (num items onscreen)
    dd 0x434158  ; ItemManager::on_tick__body  (num items onscreen)
    dd 0x41b3d1  ; ItemManager::destroy_all  (total items created)
    dd 0x43474e  ; ItemManager::spawn_item  (total items created)
    dd 0x434a2d  ; ItemManager::spawn_item  (total items created)
    dd 0x44d912  ; sub_44d8a0  (total items created)
    dd 0x44d948  ; sub_44d8a0  (total items created)
    dd 0x433453  ; ItemManager::on_tick__body  (unused field? #1)
    dd 0x434a27  ; ItemManager::spawn_item  (unused field? #1)
    dd 0x44d942  ; sub_44d8a0  (unused field? #1)
    dd 0x41b3dc  ; ItemManager::destroy_all  (unused field? #2)
    dd 0x434a1b  ; ItemManager::spawn_item  (unused field? #2)
    dd 0x44d936  ; sub_44d8a0  (unused field? #2)
    dd WHITELIST_END

    dd LIST_END

perf_fix_data:  ; HEADER: AUTO
    dd 0

iat_funcs:  ; HEADER: AUTO
.GetLastError: dd 0x49a098
.GetModuleHandleA: dd 0
.GetModuleHandleW: dd 0x49a1b4
.GetProcAddress: dd 0x49a0e0
.MessageBoxA: dd 0x49a214
