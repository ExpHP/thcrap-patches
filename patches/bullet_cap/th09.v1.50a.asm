; AUTO_PREFIX: ExpHP.bullet-cap.

%include "util.asm"
%include "common.asm"

; Address range spanned by .text
address_range:  ; HEADER: AUTO
    dd 0x401000
    dd 0x48dada

bullet_replacements:  ; HEADER: AUTO
    ; options:bullet-cap is unused in PoFV in favor of more specific options
istruc CapGameData
    at CapGameData.old_cap, dd 0
    at CapGameData.elem_size, dd 0
iend
    dd LIST_END

fairy_bullet_replacements:  ; HEADER: AUTO
istruc CapGameData
    at CapGameData.old_cap, dd 175
    at CapGameData.elem_size, dd 0x10c4
iend
    dd 175
    dd SCALE_1
    dd WHITELIST_BEGIN
    dd 0x41240a  ; BulletManager::reset
    dd 0x412a29  ; BulletManager::shoot_one_bullet
    dd 0x412a4d  ; BulletManager::shoot_one_bullet
    dd 0x414792  ; BulletManager::on_tick
    dd 0x44b621  ; sub_44b500
    dd WHITELIST_END

    dd 176
    dd SCALE_1
    dd WHITELIST_BEGIN
    dd 0x41506b  ; BulletManager::constructor
    dd WHITELIST_END

    dd 0x2e1b0  ; num dwords in array
    dd SCALE_SIZE_DIV(4)
    dd WHITELIST_BEGIN
    dd 0x412486 ; BulletManager::reset_412470
    dd WHITELIST_END

    dd LIST_END

rival_bullet_replacements:  ; HEADER: AUTO
istruc CapGameData
    at CapGameData.old_cap, dd 360
    at CapGameData.elem_size, dd 0x10c4
iend
    dd 360
    dd SCALE_1
    dd WHITELIST_BEGIN
    dd 0x412440  ; BulletManager::reset
    dd 0x412b39  ; BulletManager::shoot_one_bullet
    dd 0x412b62  ; BulletManager::shoot_one_bullet
    dd 0x44b75f  ; sub_44b500
    dd WHITELIST_END

    dd 361
    dd SCALE_1
    dd WHITELIST_BEGIN
    dd 0x415086  ; BulletManager::constructor
    dd WHITELIST_END

    dd 0x5e919  ; num dwords in array
    dd SCALE_SIZE_DIV(4)
    dd WHITELIST_BEGIN
    dd 0x41248f  ; BulletManager::reset_412470
    dd WHITELIST_END

    dd LIST_END

laser_replacements:  ; HEADER: AUTO
istruc CapGameData
    at CapGameData.old_cap, dd 0x30
    at CapGameData.elem_size, dd 0x59c
iend
    dd 0x30
    dd SCALE_1
    dd WHITELIST_BEGIN
    ; BulletManager::shoot_laser has a byte, not a dword
    dd 0x413c15 - 4  ; BulletManager::on_draw
    dd 0x414b5a - 4  ; BulletManager::on_tick
    ; BulletManager::constructor has a byte, not a dword
    dd WHITELIST_END

    dd LIST_END

cancel_replacements:  ; HEADER: AUTO
istruc CapGameData
    at CapGameData.old_cap, dd 0
    at CapGameData.elem_size, dd 0
iend
    dd LIST_END

bullet_mgr_layout:  ; HEADER: AUTO
istruc LayoutHeader
    at LayoutHeader.offset_to_replacements, dd bullet_mgr_layout.replacements - bullet_mgr_layout
iend
    dd REGION_NORMAL(0)
    dd REGION_ARRAY(0x1a900, CAPID_FAIRY_BULLET, SCALE_SIZE)
    dd REGION_ARRAY(0xd2fc0, CAPID_RIVAL_BULLET, SCALE_SIZE)
    dd REGION_ARRAY(0x24d424, CAPID_LASER, SCALE_SIZE)
    dd REGION_NORMAL(0x25e164)
    dd REGION_END(0x25e1c0)
.replacements:
    dd REP_OFFSET(0xd2fc0), REPLACE_ALL  ; rival bullet array
    dd REP_OFFSET(0x24d424), REPLACE_ALL  ; laser array

    dd REP_OFFSET(0xd2cba)  ; sentinel state field in dummy fairy bullet
    dd WHITELIST_BEGIN
    dd 0x4123e9  ; BulletManager::reset
    dd 0x4124b8  ; BulletManager::reset_412470
    dd WHITELIST_END

    dd REP_OFFSET(0x24d11e)  ; sentinel state field in dummy rival bullet
    dd WHITELIST_BEGIN
    dd 0x4123f0  ; BulletManager::reset
    dd 0x4124bf  ; BulletManager::reset_412470
    dd WHITELIST_END

    ; SO MANY FIELDS AAAAAAAAAAAAAAAAAAAA
    dd REP_OFFSET_RANGE(0x25e164, 0x25e1c0)
    dd WHITELIST_BEGIN
    dd 0x41472f  ; BulletManager::on_tick [edi + 0x25e164 {zBulletManager::fairy_bullet_count}].d = ebx
    dd 0x4147a0  ; BulletManager::on_tick [edi + 0x25e164 {zBulletManager::fairy_bullet_count}].d = [edi + 0x25e164 {zBulletManager::fairy_bullet_count}].d + 1
    dd 0x414735  ; BulletManager::on_tick [edi + 0x25e168 {zBulletManager::rival_bullet_count}].d = ebx
    dd 0x4147a8  ; BulletManager::on_tick [edi + 0x25e168 {zBulletManager::rival_bullet_count}].d = [edi + 0x25e168 {zBulletManager::rival_bullet_count}].d + 1
    dd 0x414729  ; BulletManager::on_tick [edi + 0x25e16c {zBulletManager::bullet_count_total}].d = ebx
    dd 0x41478b  ; BulletManager::on_tick edx = [edi + 0x25e16c {zBulletManager::bullet_count_total}].d
    dd 0x414798  ; BulletManager::on_tick [edi + 0x25e16c {zBulletManager::bullet_count_total}].d = edx
    dd 0x41309e  ; BulletManager::shoot_one_bullet ecx = [eax + 0x25e170 {zBulletManager::__something_that_counts_down}].d
    dd 0x413298  ; BulletManager::shoot_laser eax = [ebx + 0x25e170 {zBulletManager::__something_that_counts_down}].d
    dd 0x414f55  ; BulletManager::on_tick eax = [esi + 0x25e170 {zBulletManager::__something_that_counts_down}].d
    dd 0x414f60  ; BulletManager::on_tick [esi + 0x25e170 {zBulletManager::__something_that_counts_down}].d = eax
    dd 0x414f68  ; BulletManager::on_tick ecx = esi + 0x25e174
    dd 0x4150b5  ; BulletManager::constructor ecx = esi + 0x25e174
    dd 0x414f73  ; BulletManager::on_tick [esi + 0x25e180 {zBulletManager::__total_tick_count_maybe}].d = [esi + 0x25e180 {zBulletManager::__total_tick_count_maybe}].d + 1
    dd 0x41419a  ; BulletManager::operator delete ecx = [esi + 0x25e184 {zBulletManager::on_tick}].d
    dd 0x41516d  ; BulletManager::operator new [esi + 0x25e184 {zBulletManager::on_tick}].d = eax
    dd 0x415176  ; BulletManager::operator new eax = [esi + 0x25e184 {zBulletManager::on_tick}].d
    dd 0x415186  ; BulletManager::operator new edx = [esi + 0x25e184 {zBulletManager::on_tick}].d
    dd 0x414189  ; BulletManager::operator delete eax = [esi + 0x25e188 {zBulletManager::on_draw}].d
    dd 0x4151bd  ; BulletManager::operator new [esi + 0x25e188 {zBulletManager::on_draw}].d = eax
    dd 0x4151c9  ; BulletManager::operator new eax = [esi + 0x25e188 {zBulletManager::on_draw}].d
    dd 0x413bec  ; BulletManager::on_draw eax = [esi + 0x25e18c {zBulletManager::side_num}].d
    dd 0x414713  ; BulletManager::on_tick eax = [edi + 0x25e18c {zBulletManager::side_num}].d
    dd 0x41515c  ; BulletManager::operator new [esi + 0x25e18c {zBulletManager::side_num}].d = edi
    dd 0x41e281  ; sub_41dff0 cx = [eax + 0x25e18c {zBulletManager::side_num.w}].w
    dd 0x413111  ; BulletManager::shoot_fairy_bullets_array ecx = [ecx + 0x25e190 {zBulletManager::side_ptr}].d
    dd 0x4131e1  ; BulletManager::shoot_rival_bullets_array ecx = [ecx + 0x25e190 {zBulletManager::side_ptr}].d
    dd 0x413389  ; BulletManager::shoot_laser eax = [ebx + 0x25e190 {zBulletManager::side_ptr}].d
    dd 0x413839  ; Bullet::step_ex_03 eax = [edx + 0x25e190 {zBulletManager::side_ptr}].d
    dd 0x413e20  ; BulletManager::on_draw ecx = [eax + 0x25e190 {zBulletManager::side_ptr}].d
    dd 0x41476c  ; BulletManager::on_tick edx = [edi + 0x25e190 {zBulletManager::side_ptr}].d
    dd 0x414a46  ; BulletManager::on_tick edx = [ecx + 0x25e190 {zBulletManager::side_ptr}].d
    dd 0x414a6b  ; BulletManager::on_tick ecx = [eax + 0x25e190 {zBulletManager::side_ptr}].d
    dd 0x414abf  ; BulletManager::on_tick eax = [edx + 0x25e190 {zBulletManager::side_ptr}].d
    dd 0x414b3f  ; BulletManager::on_tick edx = [edi + 0x25e190 {zBulletManager::side_ptr}].d
    dd 0x414d74  ; BulletManager::on_tick eax = [edx + 0x25e190 {zBulletManager::side_ptr}].d
    dd 0x414ddb  ; BulletManager::on_tick ecx = [eax + 0x25e190 {zBulletManager::side_ptr}].d
    dd 0x414ed3  ; BulletManager::on_tick edx = [ecx + 0x25e190 {zBulletManager::side_ptr}].d
    dd 0x41514a  ; BulletManager::operator new [esi + 0x25e190 {zBulletManager::side_ptr}].d = ecx
    dd 0x415162  ; BulletManager::operator new [esi + 0x25e194 {zBulletManager::__weird__offset_from_side_ptr_to_side_2}].d = edx
    dd 0x4123b2  ; BulletManager::zero_layer_list_heads [ecx + 0x25e198 {zBulletManager::layer_list_heads[0]}].d = eax
    dd 0x413df3  ; BulletManager::on_draw esi = esi + 0x25e198
    dd 0x414780  ; BulletManager::on_tick eax = edi + (eax << 2) + 0x25e198
    dd 0x414b14  ; BulletManager::on_tick eax = edx + (ecx << 2) + 0x25e198
    dd 0x4123ac  ; BulletManager::zero_layer_list_heads [ecx + 0x25e19c {zBulletManager::layer_list_heads[1]}].d = eax
    dd 0x4123a6  ; BulletManager::zero_layer_list_heads [ecx + 0x25e1a0 {zBulletManager::layer_list_heads[2]}].d = eax
    dd 0x4123a0  ; BulletManager::zero_layer_list_heads [ecx + 0x25e1a4 {zBulletManager::layer_list_heads[3]}].d = eax
    dd 0x41239a  ; BulletManager::zero_layer_list_heads [ecx + 0x25e1a8 {zBulletManager::layer_list_heads[4]}].d = eax
    dd 0x412394  ; BulletManager::zero_layer_list_heads [ecx + 0x25e1ac {zBulletManager::layer_list_heads[5]}].d = eax
    dd 0x4123e2  ; BulletManager::reset [edx + 0x25e1b0].d = eax
    dd 0x4124a5  ; BulletManager::reset_412470 [edx + 0x25e1b0 {zBulletManager::next_fairy_bullet}].d = esi
    dd 0x41297c  ; BulletManager::shoot_one_bullet ebx = [ecx + 0x25e1b0 {zBulletManager::next_fairy_bullet}].d
    dd 0x4123f6  ; BulletManager::reset [edx + 0x25e1b4].d = esi
    dd 0x4124b1  ; BulletManager::reset_412470 [edx + 0x25e1b4 {zBulletManager::next_rival_bullet}].d = ebx
    dd 0x412a62  ; BulletManager::shoot_one_bullet ebx = [ecx + 0x25e1b4 {zBulletManager::next_rival_bullet}].d
    dd 0x4123fc  ; BulletManager::reset [edx + 0x25e1b8].d = 5
    dd 0x4124c5  ; BulletManager::reset_412470 [edx + 0x25e1b8 {zBulletManager::__unused__cancel_item_type}].d = 5
    dd 0x40c594  ; Enemy::sub_40c530 ecx = [ecx + 0x25e1bc {zBulletManager::etama_anm}].d
    dd 0x40c67b  ; Enemy::sub_40c530 ecx = [ecx + 0x25e1bc {zBulletManager::etama_anm}].d
    dd 0x412529  ; BulletManger::sub_4124e0 ecx = [ecx + 0x25e1bc {zBulletManager::etama_anm}].d
    dd 0x412559  ; BulletManger::sub_4124e0 ecx = [ecx + 0x25e1bc {zBulletManager::etama_anm}].d
    dd 0x41256f  ; BulletManger::sub_4124e0 ecx = [ecx + 0x25e1bc {zBulletManager::etama_anm}].d
    dd 0x412ed2  ; BulletManager::shoot_one_bullet ecx = [eax + 0x25e1bc {zBulletManager::etama_anm}].d
    dd 0x412f4d  ; BulletManager::shoot_one_bullet ecx = [eax + 0x25e1bc {zBulletManager::etama_anm}].d
    dd 0x412f58  ; BulletManager::shoot_one_bullet ecx = [ecx + 0x25e1bc {zBulletManager::etama_anm}].d
    dd 0x4132e4  ; BulletManager::shoot_laser ecx = [ebx + 0x25e1bc {zBulletManager::etama_anm}].d
    dd 0x413302  ; BulletManager::shoot_laser ecx = [ebx + 0x25e1bc {zBulletManager::etama_anm}].d
    dd 0x413320  ; BulletManager::shoot_laser ecx = [ebx + 0x25e1bc {zBulletManager::etama_anm}].d
    dd 0x413e73  ; BulletManager::on_registration [ebx + 0x25e1bc {zBulletManager::etama_anm}].d = eax
    dd 0x413ea0  ; BulletManager::on_registration ecx = [ebx + 0x25e1bc {zBulletManager::etama_anm}].d
    dd 0x413eb1  ; BulletManager::on_registration ecx = [ebx + 0x25e1bc {zBulletManager::etama_anm}].d
    dd 0x413ecb  ; BulletManager::on_registration ecx = [ebx + 0x25e1bc {zBulletManager::etama_anm}].d
    dd 0x413edd  ; BulletManager::on_registration ecx = [ebx + 0x25e1bc {zBulletManager::etama_anm}].d
    dd 0x413ef7  ; BulletManager::on_registration ecx = [ebx + 0x25e1bc {zBulletManager::etama_anm}].d
    dd 0x414286  ; Bullet::run_ex ecx = [eax + 0x25e1bc].d
    dd 0x41dc0a  ; sub_41db90 ecx = [ecx + 0x25e1bc {zBulletManager::etama_anm}].d
    dd WHITELIST_END

    dd REP_OFFSET(0x25e1c0)  ; size
    dd WHITELIST_BEGIN
    dd 0x4150ec  ; BulletManager::operator new
    dd 0x415119  ; BulletManager::operator new
    dd WHITELIST_END

    dd REP_OFFSET_BETWEEN_DIV(0, 0x25e1c0, 4)  ; 0x97870  - size in dwords
    dd WHITELIST_BEGIN
    dd 0x4123c9  ; BulletManager::reset
    dd WHITELIST_END

    ; The number 536 == 175 + 1 + 360 == total length of bullet arrays put together,
    ; counting the dummy fairy bullet in the middle but not the dummy rival bullet at the end.
    ;
    ; (notice that dividing by the bullet size 0x10c4 gives us a length)
    dd REP_OFFSET_BETWEEN_DIV(0x1a900, 0x24d424 - 0x10c4, 0x10c4)
    dd WHITELIST_BEGIN
    dd 0x40c54d  ; Enemy::sub_40c530
    dd 0x40c74d  ; Enemy::sub_40c530
    dd 0x414b30  ; BulletManager::on_tick
    dd WHITELIST_END

    dd LIST_END

item_mgr_layout:  ; HEADER: AUTO
istruc LayoutHeader
    at LayoutHeader.offset_to_replacements, dd item_mgr_layout.replacements - item_mgr_layout
iend
    dd REGION_END(0x0)  ; it dun exist
.replacements:
    dd LIST_END

perf_fix_data:  ; HEADER: AUTO
    dd 0  ; unused

iat_funcs:  ; HEADER: AUTO
.GetLastError: dd 0x48e08c
.GetModuleHandleA: dd 0x48e0dc
.GetModuleHandleW: dd 0
.GetProcAddress: dd 0x48e0d8
.MessageBoxA: dd 0x48e210

corefuncs:  ; HEADER: AUTO
.malloc: dd 0x47b24e
