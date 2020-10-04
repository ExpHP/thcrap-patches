
; AUTO_PREFIX: base-exphp.

; __stdcall Bullet* AdjustBulletArray(Bullet* original_array)
adjust_bullet_array:  ; HEADER: AUTO
    mov  eax, [esp+0x4]
    ret

; __stdcall Item* AdjustCancelArray(Item* original_array)
adjust_cancel_array:  ; HEADER: AUTO
    mov  eax, [esp+0x4]
    ret

; __stdcall Laser* AdjustLaserArray(Laser* original_array)
adjust_laser_array:  ; HEADER: AUTO
    mov  eax, [esp+0x4]
    ret
