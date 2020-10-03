{
    "COMMENT": "This file is autogenerated.  Please do not edit it directly.  See the convert-yaml.py script.",
    "codecaves": {
        "ExpHP.bullet-cap.address-range": "00104000 // 783B4B00",
        "ExpHP.bullet-cap.bullet-replacements": "00060000 // B8100000 // 00060000 // FFFFFFFF // 01000000 // 9C3A4200 // 5C3E4200 // 1C424200 // 544A4200 // 744C4200 // 8C4E4200 // 0C514200 // 0E524200 // D3524200 // C8F34200 // 23F64200 // 65F64200 // 62084300 // E60A4300 // 730D4300 // 3E0E4300 // AA124300 // 00000000 // 01060000 // FFFFFFFF // 01000000 // 42F44200 // 00000000 // 00506400 // 01000000 // 01000000 // 5A1B4300 // 00000000 // FF050000 // FFFFFFFF // 01000000 // 511B4300 // 00000000 // 00000000",
        "ExpHP.bullet-cap.laser-replacements": "00010000 // 9C050000 // 00010000 // FFFFFFFF // 01000000 // 73094300 // FC0B4300 // 790F4300 // AE1B4300 // AE2B4300 // 00000000 // 00000000",
        "ExpHP.bullet-cap.cancel-replacements": "30080000 // E4020000 // 30080000 // FFFFFFFF // 01000000 // 4D014400 // 83014400 // C8014400 // 47044400 // 00000000 // 31080000 // FFFFFFFF // 01000000 // 1D004400 // 00000000 // C0AA1700 // 01000000 // FFFFFFFF00000000 // 00000000",
        "ExpHP.bullet-cap.perf-fix-data": "00000000",
        "ExpHP.bullet-cap.iat-funcs": "74404B00 // E0404B00 // 00000000 // D8404B00 // E8414B00",
        "bullet-cap": "00006000",
        "laser-cap": "00001000",
        "cancel-cap": "00008300",
        "bullet-cap-config.anm-search-lag-spike-size": "00002000",
        "bullet-cap-config.mof-sa-lag-spike-size": "ffffffff",
        "of(ExpHP.bullet-cap.install)": "E8[codecave:ExpHP.bullet-cap.initialize] // B8A0114300 // FFD0 // E800000000C70424 19b44300 C3",
        "of(ExpHP.bullet-cap.pointerify-bullets-constructor)": "A1<codecave:bullet-cap> // 0FC8 // 40 // 69C0B8100000 // 50 // B8D4434A00 // FFD0 // 83C404 // A310F7F600 // A1<codecave:laser-cap> // 0FC8 // 69C09C050000 // 50 // B8D4434A00 // FFD0 // 83C404 // A3B0CD4C01 // E800000000C70424 78f44200 C3",
        "of(ExpHP.bullet-cap.pointerify-keep-the-pointers)": "56 // FF3510F7F600 // FF35B0CD4C01 // B95EE91A00 // 31C0 // 8B7DF4 // F3AB // 8F05B0CD4C01 // 8F0510F7F600 // 8B35<codecave:bullet-cap> // 0FCE // 46 // 69F6B8100000 // 89F1 // 8B3D10F7F600 // F3AA // 8B0D<codecave:laser-cap> // 0FC9 // 69C99C050000 // 8B3DB0CD4C01 // F3AA // 8B3D10F7F600 // 66C7843700FDFFFF0600 // 5E // E800000000C70424 76f34200 C3",
        "of(ExpHP.bullet-cap.pointerify-bullets-static-0c)": "A110F7F600 // 8945F4 // C3",
        "of(ExpHP.bullet-cap.pointerify-bullets-static-08)": "A110F7F600 // 8945F8 // C3",
        "of(ExpHP.bullet-cap.pointerify-bullets-static-1c)": "A110F7F600 // 8945E4 // C3",
        "of(ExpHP.bullet-cap.pointerify-bullets-static-18)": "A110F7F600 // 8945E8 // C3",
        "of(ExpHP.bullet-cap.pointerify-bullets-static-14)": "A110F7F600 // 8945EC // C3",
        "of(ExpHP.bullet-cap.pointerify-bullets-offset-eax)": "A110F7F600 // C3",
        "of(ExpHP.bullet-cap.pointerify-bullets-offset-edx)": "8B1510F7F600 // C3",
        "of(ExpHP.bullet-cap.pointerify-lasers-offset-edx)": "8B15B0CD4C01 // C3",
        "of(ExpHP.bullet-cap.pointerify-lasers-offset-eax)": "A1B0CD4C01 // C3",
        "of(ExpHP.bullet-cap.pointerify-lasers-offset-ecx)": "8B0DB0CD4C01 // C3",
        "of(ExpHP.bullet-cap.pointerify-items-constructor)": "83C404 // A1<codecave:bullet-cap> // 0FC8 // 40 // 50 // 69C0E4020000 // 50 // B8D4434A00 // FFD0 // 83C404 // A348366501 // 58 // 6850004400 // 50 // 68E4020000 // FF3548366501 // B850684000 // FFD0 // E800000000C70424 2f004400 C3",
        "of(ExpHP.bullet-cap.pointerify-items-keep-the-pointer)": "FF3548366501 // 8B7DFC // F3AB // 8F0548366501 // E800000000C70424 04384300 C3",
        "of(ExpHP.bullet-cap.pointerify-items-spawn)": "8B55F4 // 8B12 // 01CA // E800000000C70424 bd004400 C3",
        "of(ExpHP.bullet-cap.pointerify-items-spawn-2-eax)": "A1<codecave:cancel-cap> // 0FC8 // 69C0E4020000 // 030548366501 // C3",
        "of(ExpHP.bullet-cap.pointerify-items-spawn-2-edx)": "8B15<codecave:cancel-cap> // 0FCA // 69D2E4020000 // 031548366501 // C3",
        "of(ExpHP.bullet-cap.pointerify-items-spawn-wrap)": "8B4DF4 // 8B09 // 894DF8 // E800000000C70424 aa014400 C3"
    },
    "binhacks": {
        "ExpHP.bullet-cap.install": {
            "addr": "0x43b414",
            "expected": "e8875dffff",
            "code": "E9 [codecave:of(ExpHP.bullet-cap.install)]"
        },
        "ExpHP.bullet-cap.dont-reset-before-main": {
            "addr": "0x42f489",
            "code": "9090909090"
        },
        "ExpHP.bullet-cap.pointerify-bullets-constructor": {
            "addr": "0x42f43c",
            "expected": "6800f54200",
            "code": "E9 [codecave:of(ExpHP.bullet-cap.pointerify-bullets-constructor)]"
        },
        "ExpHP.bullet-cap.pointerify-keep-the-pointers": {
            "addr": "0x42f36a",
            "expected": "b95ee91a00",
            "code": "E9 [codecave:of(ExpHP.bullet-cap.pointerify-keep-the-pointers)]"
        },
        "ExpHP.bullet-cap.pointerify-bullets-static-0c": {
            "addr": [
                "0x423a6c",
                "0x423e2c",
                "0x4241ec",
                "0x42529c"
            ],
            "expected": "c745f410f7f600",
            "code": "E8 [codecave:of(ExpHP.bullet-cap.pointerify-bullets-static-0c)] // 9090"
        },
        "ExpHP.bullet-cap.pointerify-bullets-static-08": {
            "addr": [
                "0x424a2c",
                "0x424c4c",
                "0x424e5c",
                "0x4250dc",
                "0x4251e6",
                "0x42f3a0"
            ],
            "expected": "c745f810f7f600",
            "code": "E8 [codecave:of(ExpHP.bullet-cap.pointerify-bullets-static-08)] // 9090"
        },
        "ExpHP.bullet-cap.pointerify-bullets-static-1c": {
            "addr": "0x43083a",
            "expected": "c745e410f7f600",
            "code": "E8 [codecave:of(ExpHP.bullet-cap.pointerify-bullets-static-1c)] // 9090"
        },
        "ExpHP.bullet-cap.pointerify-bullets-static-18": {
            "addr": "0x430abe",
            "expected": "c745e810f7f600",
            "code": "E8 [codecave:of(ExpHP.bullet-cap.pointerify-bullets-static-18)] // 9090"
        },
        "ExpHP.bullet-cap.pointerify-bullets-static-14": {
            "addr": "0x430d3a",
            "expected": "c745ec10f7f600",
            "code": "E8 [codecave:of(ExpHP.bullet-cap.pointerify-bullets-static-14)] // 9090"
        },
        "ExpHP.bullet-cap.pointerify-bullets-offset-eax": {
            "addr": [
                "0x42f379",
                "0x431254"
            ],
            "expected": "0580a80100",
            "code": "E8 [codecave:of(ExpHP.bullet-cap.pointerify-bullets-offset-eax)]"
        },
        "ExpHP.bullet-cap.pointerify-bullets-offset-edx": {
            "addr": [
                "0x42f657",
                "0x42fe23"
            ],
            "expected": "81c280a80100",
            "code": "E8 [codecave:of(ExpHP.bullet-cap.pointerify-bullets-offset-edx)] // 90"
        },
        "ExpHP.bullet-cap.pointerify-lasers-offset-edx": {
            "addr": [
                "0x42f46c",
                "0x430941"
            ],
            "expected": "81c238096600",
            "code": "E8 [codecave:of(ExpHP.bullet-cap.pointerify-lasers-offset-edx)] // 90"
        },
        "ExpHP.bullet-cap.pointerify-lasers-offset-eax": {
            "addr": [
                "0x430bcb",
                "0x430f2c",
                "0x431b75"
            ],
            "expected": "0538096600",
            "code": "E8 [codecave:of(ExpHP.bullet-cap.pointerify-lasers-offset-eax)]"
        },
        "ExpHP.bullet-cap.pointerify-lasers-offset-ecx": {
            "addr": "0x432b7b",
            "expected": "81c138096600",
            "code": "E8 [codecave:of(ExpHP.bullet-cap.pointerify-lasers-offset-ecx)] // 90"
        },
        "ExpHP.bullet-cap.pointerify-items-constructor": {
            "addr": "0x440021",
            "expected": "68e4020000",
            "code": "E9 [codecave:of(ExpHP.bullet-cap.pointerify-items-constructor)]"
        },
        "ExpHP.bullet-cap.pointerify-items-keep-the-pointer": {
            "addr": "0x4337ff",
            "expected": "8b7dfcf3ab",
            "code": "E9 [codecave:of(ExpHP.bullet-cap.pointerify-items-keep-the-pointer)]"
        },
        "ExpHP.bullet-cap.pointerify-items-spawn": {
            "addr": "0x4400b8",
            "expected": "8b55f403d1",
            "code": "E9 [codecave:of(ExpHP.bullet-cap.pointerify-items-spawn)]"
        },
        "ExpHP.bullet-cap.pointerify-items-spawn-2-eax": {
            "addr": [
                "0x4400e4",
                "0x4401b0"
            ],
            "expected": "8b45f4 // 05c0aa1700",
            "code": "E8 [codecave:of(ExpHP.bullet-cap.pointerify-items-spawn-2-eax)] // 909090"
        },
        "ExpHP.bullet-cap.pointerify-items-spawn-2-edx": {
            "addr": [
                "0x440455"
            ],
            "expected": "8b55f4 // 81c2c0aa1700",
            "code": "E8 [codecave:of(ExpHP.bullet-cap.pointerify-items-spawn-2-edx)] // 90909090"
        },
        "ExpHP.bullet-cap.pointerify-items-spawn-wrap": {
            "addr": "0x440196",
            "expected": "8b4df4894df8",
            "code": "E9 [codecave:of(ExpHP.bullet-cap.pointerify-items-spawn-wrap)] // CC"
        }
    }
}
