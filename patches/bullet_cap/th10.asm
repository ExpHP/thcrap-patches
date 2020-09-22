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

; An innocuous place in the function that starts the game thread.
cave:  ; 0x420ec8
    call initialize  ; REWRITE: [codecave:ExpHP.bullet-cap.initialize]

    ; original code
    mov   eax, 0x44c150
    call  eax
    abs_jmp_hack 0x420ecd

; Address range spanned by .text
address_range:  ; HEADER: ExpHP.bullet-cap.address-range
    dd 0x401000
    dd 0x465a81

bullet_data:  ; HEADER: ExpHP.bullet-cap.bullet-data
    dd 0x7d0  ; old bullet count (not counting pre-TD dummy bullet)
    dd 0x7f0  ; size of bullet

; Here we have a list of numbers related to bullet count, each followed by a blacklist.
; (i.e. addresses where this dword only appears incidentally and should not be replaced).
; Each one will be substituted as  value -> value + new_count - old_count.
counts_to_replace:  ; HEADER: ExpHP.bullet-cap.counts-to-replace
    dd 0x7d0
    dd 0x415609
    dd 0x44bd7e
    dd 0 ; blacklist end

    dd 0x7d1
    dd 0

    dd 0 ; END

; Similar to counts_to_replace, but for BulletManager offsets that depend on the final bullet's offset.
; These will be substituted as  value -> value + bullet_size * (new_count - old_count)
;
; Also sometimes the games do stuff like `rep stosd` and we have to divide size by 4 or something like that.
offsets_to_replace:  ; HEADER: ExpHP.bullet-cap.offsets-to-replace
    dd 0x3e07a6  ; offset of dummy bullet state
    dd 1 ; use size as is
    dd 0
    dd 0x3e0b50  ; offset of bullet.anm
    dd 1 ; use size as is
    dd 0
    dd 0x3e0b54  ; size of bullet manager
    dd 1 ; use size as is
    dd 0
    dd 0xf82d5  ; num dwords in bullet manager
    dd 4 ; use size / 4
    dd 0
    dd 0xf82bc  ; num dwords in bullet array
    dd 4 ; use size / 4
    dd 0

    dd 0 ; END

iat_funcs:  ; HEADER: ExpHP.bullet-cap.iat-funcs
.GetLastError: dd 0x45fadc
.GetModuleHandleA: dd 0x466198
.GetModuleHandleW: dd 0
.GetProcAddress: dd 0x466158

; defined in global.yaml
initialize:
