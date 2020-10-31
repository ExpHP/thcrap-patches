
; AUTO_PREFIX: base-exphp.

; Bullet* __stdcall AdjustBulletArray(Bullet* original_array)
adjust_bullet_array:  ; HEADER: AUTO
    mov  eax, [esp+0x4]
    ret

; Item* __stdcall AdjustCancelArray(Item* original_array)
adjust_cancel_array:  ; HEADER: AUTO
    mov  eax, [esp+0x4]
    ret

; Laser* __stdcall AdjustLaserArray(Laser* original_array)
adjust_laser_array:  ; HEADER: AUTO
    mov  eax, [esp+0x4]
    ret

; void* __stdcall AdjustFieldPtr(StructId what, void* field_ptr, void* struct_base)
adjust_field_ptr: ; HEADER: AUTO
    mov  eax, [esp+0x8]
    ret
