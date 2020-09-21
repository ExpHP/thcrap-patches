; THIS IS NOT A SOURCE FILE
;
; Changing anything in this file will NOT have any effect on the patch.
; This file is where I write the initial asm for many binhacks. Use
;
;     scripts/list-asm source/x.asm
;
; to generate the assembly, copy it into thXX.YAML, and postprocess it with
; some manual fixes like inserting [codecave:yadda-yadda-yadda] and deleting
; dummy labels.

%include "util.asm"

cave:  ; 0x42a51e
    call initialize  ; REWRITE: [codecave:ExpHP.bullet-cap.initialize]

    ; original code
    mov   esi, 0x4c3a70
    abs_jmp_hack 0x42a523

; Address range spanned by .text
address_range:  ; HEADER: ExpHP.bullet-cap.address-range
    dd 0x401000
    dd 0x48ae15

bullet_data:  ; HEADER: ExpHP.bullet-cap.bullet-data
    dd 0x7d0  ; old bullet count (not counting pre-TD dummy bullet)
    dd 0x910  ; size of bullet

; Here we have a list of numbers related to bullet count, each followed by a blacklist.
; (i.e. addresses where this dword only appears incidentally and should not be replaced).
; Each one will be substituted as  value -> value + new_count - old_count.
counts_to_replace:  ; HEADER: ExpHP.bullet-cap.counts-to-replace
    dd 0x7d0
    dd 0x41c390
    dd 0x459053
    dd 0x46b808
    dd 0 ; blacklist end

    dd 0x7d1
    dd 0

    dd 0 ; END

; Similar to counts_to_replace, but for BulletManager offsets that depend on the final bullet's offset.
; These will be substituted as  value -> value + bullet_size * (new_count - old_count)
offsets_to_replace:  ; HEADER: ExpHP.bullet-cap.offsets-to-replace
    dd 0x46d216  ; offset of dummy bullet state
    dd 0
    dd 0x46d674  ; offset of bullet.anm
    dd 0
    dd 0x46d678  ; size of bullet manager
    dd 0
    dd 0x46d610  ; size of bullet array
    dd 0

    dd 0 ; END

iat_funcs:  ; HEADER: ExpHP.bullet-cap.iat-funcs
.GetLastError: dd 0x48b1b8
.GetModuleHandleW: dd 0x48b174
.GetProcAddress: dd 0x48b170

; defined in global.yaml
initialize:
