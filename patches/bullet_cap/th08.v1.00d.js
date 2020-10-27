{
    "COMMENT": "This file is autogenerated.  Please do not edit it directly.  See the convert-yaml.py script.",
    "codecaves": {
        "base-exphp.adjust-bullet-array": "8B442404 // 8B00 // C3",
        "base-exphp.adjust-laser-array": "8B442404 // 8B00 // C3",
        "base-exphp.adjust-cancel-array": "8B442404 // 8B00 // C3",
        "ExpHP.bullet-cap.address-range": "00104000 // 783B4B00",
        "ExpHP.bullet-cap.bullet-replacements": "00060000 // B8100000 // 00060000 // 00010100 // 01000000 // 9C3A4200 // 5C3E4200 // 1C424200 // 544A4200 // 744C4200 // 8C4E4200 // 0C514200 // 0E524200 // D3524200 // C8F34200 // 23F64200 // 65F64200 // 62084300 // E60A4300 // 730D4300 // 3E0E4300 // AA124300 // 00000000 // 01060000 // 00010100 // 01000000 // 42F44200 // 00000000 // 00506400 // 01000100 // 01000000 // 5A1B4300 // 00000000 // FF050000 // 00010100 // 01000000 // 511B4300 // 00000000 // 00000000",
        "ExpHP.bullet-cap.laser-replacements": "00010000 // 9C050000 // 00010000 // 00010100 // 01000000 // 60F44200 // 73094300 // FC0B4300 // 790F4300 // AE1B4300 // AE2B4300 // 00000000 // 00000000",
        "ExpHP.bullet-cap.cancel-replacements": "30080000 // E4020000 // 30080000 // 00010100 // 01000000 // 4D014400 // 83014400 // C8014400 // 47044400 // 00000000 // 31080000 // 00010100 // 01000000 // 1D004400 // 00000000 // 00000000",
        "ExpHP.bullet-cap.bullet-mgr-layout": "904EF50000000000 // 74000000 // 0000000000000000000000000000000000000000 // 80A8010040000000010000000100010000000000 // 3809660041000000010000000100010000000000 // 38A56B0000000000000000000000000000000000 // 78A56B0000000000000000000000000000000000EDEFCDAB // 00000000",
        "ExpHP.bullet-cap.item-mgr-layout": "4836650100000000 // 4C000000 // 0000000042000000010000000100010000000000 // C0AA170000000000000000000000000000000000 // 94B0170000000000000000000000000000000000EDEFCDAB // 00000000",
        "ExpHP.bullet-cap.perf-fix-data": "00000000",
        "ExpHP.bullet-cap.pointerize-data": "904EF500 // 10F7F600 // C8575B01 // 48366501 // 48366501 // B8100000 // 9C050000 // E4020000 // 06000000 // B80D0000 // 78A56B00 // 94B01700 // D4434A00",
        "ExpHP.bullet-cap.iat-funcs": "74404B00 // E0404B00 // 00000000 // D8404B00 // E8414B00",
        "bullet-cap": "00006000",
        "laser-cap": "00001000",
        "cancel-cap": "00008300",
        "bullet-cap-config.anm-search-lag-spike-size": "00002000",
        "bullet-cap-config.mof-sa-lag-spike-size": "ffffffff",
        "of(ExpHP.bullet-cap.install)": "E8[codecave:ExpHP.bullet-cap.initialize] // B8A0114300 // FFD0 // E800000000C7042419B44300C3",
        "of(ExpHP.bullet-cap.pointerize-bullets-reg(eax))": "a110f7f600c3",
        "of(ExpHP.bullet-cap.pointerize-bullets-reg(ecx))": "8b0d10f7f600c3",
        "of(ExpHP.bullet-cap.pointerize-bullets-reg(edx))": "8b1510f7f600c3",
        "of(ExpHP.bullet-cap.pointerize-bullets-stack(12))": "a110f7f6008945f4c3",
        "of(ExpHP.bullet-cap.pointerize-bullets-stack(20))": "a110f7f6008945ecc3",
        "of(ExpHP.bullet-cap.pointerize-bullets-stack(24))": "a110f7f6008945e8c3",
        "of(ExpHP.bullet-cap.pointerize-bullets-stack(28))": "a110f7f6008945e4c3",
        "of(ExpHP.bullet-cap.pointerize-bullets-stack(8))": "a110f7f6008945f8c3",
        "of(ExpHP.bullet-cap.pointerize-items-spawn(12))": "8b55f48b1201cac3",
        "of(ExpHP.bullet-cap.pointerize-items-spawn-wrap(ecx, 12))": "8b4df48b09894df8c3",
        "of(ExpHP.bullet-cap.pointerize-lasers-reg(eax))": "a1c8575b01c3",
        "of(ExpHP.bullet-cap.pointerize-lasers-reg(ecx))": "8b0dc8575b01c3",
        "of(ExpHP.bullet-cap.pointerize-lasers-reg(edx))": "8b15c8575b01c3",
        "of(pointerize-bullets-constructor)": "e8[codecave:ExpHP.bullet-cap.allocate-pointerized-bmgr-arrays]e800000000c7042478f44200c3",
        "of(pointerize-bullets-memset)": "e8[codecave:ExpHP.bullet-cap.clear-pointerized-bullet-mgr]c3",
        "of(pointerize-items-constructor)": "e8[codecave:ExpHP.bullet-cap.allocate-pointerized-imgr-arrays]e800000000c704242f004400c3",
        "of(pointerize-items-memset)": "e8[codecave:ExpHP.bullet-cap.clear-pointerized-item-mgr]c3"
    },
    "binhacks": {
        "ExpHP.bullet-cap.install": {
            "addr": "0x43b414",
            "expected": "e8875dffff",
            "code": "E9 [codecave:of(ExpHP.bullet-cap.install)]"
        },
        "ExpHP.bullet-cap.pointerize-bullets-reg(eax)": {
            "addr": [
                "0x42f379",
                "0x431254"
            ],
            "expected": "0580a80100",
            "code": "E8 [codecave:of(ExpHP.bullet-cap.pointerize-bullets-reg(eax))]"
        },
        "ExpHP.bullet-cap.pointerize-bullets-reg(ecx)": {
            "addr": [
                "0x42f44e"
            ],
            "expected": "81c180a80100",
            "code": "E8 [codecave:of(ExpHP.bullet-cap.pointerize-bullets-reg(ecx))] // 90"
        },
        "ExpHP.bullet-cap.pointerize-bullets-reg(edx)": {
            "addr": [
                "0x42f657",
                "0x42fe23"
            ],
            "expected": "81c280a80100",
            "code": "E8 [codecave:of(ExpHP.bullet-cap.pointerize-bullets-reg(edx))] // 90"
        },
        "ExpHP.bullet-cap.pointerize-bullets-stack(12)": {
            "addr": [
                "0x423a6c",
                "0x423e2c",
                "0x4241ec",
                "0x42529c"
            ],
            "expected": "c745f410f7f600",
            "code": "E8 [codecave:of(ExpHP.bullet-cap.pointerize-bullets-stack(12))] // 9090"
        },
        "ExpHP.bullet-cap.pointerize-bullets-stack(20)": {
            "addr": [
                "0x430d3a"
            ],
            "expected": "c745ec10f7f600",
            "code": "E8 [codecave:of(ExpHP.bullet-cap.pointerize-bullets-stack(20))] // 9090"
        },
        "ExpHP.bullet-cap.pointerize-bullets-stack(24)": {
            "addr": [
                "0x430abe"
            ],
            "expected": "c745e810f7f600",
            "code": "E8 [codecave:of(ExpHP.bullet-cap.pointerize-bullets-stack(24))] // 9090"
        },
        "ExpHP.bullet-cap.pointerize-bullets-stack(28)": {
            "addr": [
                "0x43083a"
            ],
            "expected": "c745e410f7f600",
            "code": "E8 [codecave:of(ExpHP.bullet-cap.pointerize-bullets-stack(28))] // 9090"
        },
        "ExpHP.bullet-cap.pointerize-bullets-stack(8)": {
            "addr": [
                "0x424a2c",
                "0x424c4c",
                "0x424e5c",
                "0x4250dc",
                "0x4251e6",
                "0x42f3a0"
            ],
            "expected": "c745f810f7f600",
            "code": "E8 [codecave:of(ExpHP.bullet-cap.pointerize-bullets-stack(8))] // 9090"
        },
        "ExpHP.bullet-cap.pointerize-items-spawn(12)": {
            "addr": [
                "0x4400b8"
            ],
            "expected": "8b55f403d1",
            "code": "E8 [codecave:of(ExpHP.bullet-cap.pointerize-items-spawn(12))]"
        },
        "ExpHP.bullet-cap.pointerize-items-spawn-wrap(ecx, 12)": {
            "addr": [
                "0x440196"
            ],
            "expected": "8b4df4894df8",
            "code": "E8 [codecave:of(ExpHP.bullet-cap.pointerize-items-spawn-wrap(ecx, 12))] // 90"
        },
        "ExpHP.bullet-cap.pointerize-lasers-reg(eax)": {
            "addr": [
                "0x430bcb",
                "0x430f2c",
                "0x431b75"
            ],
            "expected": "0538096600",
            "code": "E8 [codecave:of(ExpHP.bullet-cap.pointerize-lasers-reg(eax))]"
        },
        "ExpHP.bullet-cap.pointerize-lasers-reg(ecx)": {
            "addr": [
                "0x432b7b"
            ],
            "expected": "81c138096600",
            "code": "E8 [codecave:of(ExpHP.bullet-cap.pointerize-lasers-reg(ecx))] // 90"
        },
        "ExpHP.bullet-cap.pointerize-lasers-reg(edx)": {
            "addr": [
                "0x42f46c",
                "0x430941"
            ],
            "expected": "81c238096600",
            "code": "E8 [codecave:of(ExpHP.bullet-cap.pointerize-lasers-reg(edx))] // 90"
        },
        "pointerize-bullets-constructor": {
            "addr": "0x42f43c",
            "expected": "6800f54200",
            "code": "E9 [codecave:of(pointerize-bullets-constructor)]"
        },
        "pointerize-bullets-memset": {
            "addr": "0x42f371",
            "expected": "8b7df4 f3ab",
            "code": "E8 [codecave:of(pointerize-bullets-memset)]"
        },
        "pointerize-bullets-nop": {
            "addr": "0x42f489",
            "code": "9090909090"
        },
        "pointerize-items-constructor": {
            "addr": "0x440017",
            "expected": "6850004400",
            "code": "E9 [codecave:of(pointerize-items-constructor)]"
        },
        "pointerize-items-memset": {
            "addr": "0x4337ff",
            "expected": "8b7dfc f3ab",
            "code": "E8 [codecave:of(pointerize-items-memset)]"
        }
    }
}
