{
    "COMMENT": "This file is autogenerated.  Please do not edit it directly.  See the convert-yaml.py script.",
    "codecaves": {
        "base-exphp.adjust-bullet-array": "8B442404 // 8B00 // C3",
        "base-exphp.adjust-laser-array": "8B442404 // 8B00 // C3",
        "base-exphp.adjust-cancel-array": "8B442404 // 8B00 // C3",
        "ExpHP.bullet-cap.address-range": "00104000 // 5F9A4600",
        "ExpHP.bullet-cap.bullet-replacements": "80020000 // C4050000 // 80020000 // 00010100 // 01000000 // 31B94000 // F5C14000 // DFC34000 // 42D44000 // 9DD54000 // DDD74000 // 45DE4000 // 24DF4000 // 92344100 // F6354100 // 1A364100 // 65364100 // 92414100 // A6434100 // 324A4100 // AE674100 // 10684100 // 96684100 // 1C694100 // 84694100 // E6694100 // 6B6A4100 // F06A4100 // 00000000 // 00000000",
        "ExpHP.bullet-cap.laser-replacements": "40000000 // 70020000 // 40000000 // 00010100 // 01000000 // E1344100 // 00000000 // 00000000",
        "ExpHP.bullet-cap.cancel-replacements": "00020000 // 44010000 // 00020000 // 00010100 // 01000000 // 2CF34100 // FBF24100 // 2AF54100 // 60014200 // C0014200 // 00000000 // 01020000 // 00010100 // 01000000 // 3CF24100 // 00000000 // 00000000",
        "ExpHP.bullet-cap.bullet-mgr-layout": "6C000000 // 0000000000000000000000000000000000000000 // 0056000000030000010000000100010000000100 // 00C00E0001030000010000000100010000000100 // 005C0F0000000000000000000000000000000000 // 185C0F0000000000000000000000000000000000EDEFCDAB // 00000000",
        "ExpHP.bullet-cap.item-mgr-layout": "44000000 // 0000000002030000010000000100010000000100 // 0088020000000000000000000000000000000000 // 4C89020000000000000000000000000000000000EDEFCDAB // 00000000",
        "ExpHP.bullet-cap.perf-fix-data": "00000000",
        "ExpHP.bullet-cap.pointerize-data": "F85F5A00 // F8B55A00 // F81F6900 // 68E26900 // 68E26900 // C4050000 // 70020000 // 44010000 // FFFFFFFF // FFFFFFFF // 185C0F00 // 4C890200",
        "ExpHP.bullet-cap.iat-funcs": "74A04600 // D0A04600 // 00000000 // 6CA04600 // F4A14600",
        "ExpHP.bullet-cap.corefuncs": "24BF4500",
        "bullet-cap": "ffff ffff",
        "laser-cap": "ffff ffff",
        "cancel-cap": "ffff ffff",
        "bullet-cap-config.anm-search-lag-spike-size": "ffff ffff",
        "bullet-cap-config.mof-sa-lag-spike-size": "ffff ffff",
        "of(ExpHP.bullet-cap.install)": "e8[codecave:ExpHP.bullet-cap.initialize]b8f0484100ffd0e800000000c704245fc04100c3",
        "of(ExpHP.bullet-cap.pointerize-bullets-constructor)": "e8[codecave:ExpHP.bullet-cap.allocate-pointerized-bmgr-arrays]e800000000c704243b354100c3",
        "of(ExpHP.bullet-cap.pointerize-items-constructor)": "e8[codecave:ExpHP.bullet-cap.allocate-pointerized-imgr-arrays]e800000000c7042483f24100c3",
        "of(ExpHP.bullet-cap.pointerize-bullets-memset)": "e8[codecave:ExpHP.bullet-cap.clear-pointerized-bullet-mgr]c3",
        "of(ExpHP.bullet-cap.pointerize-items-memset)": "e8[codecave:ExpHP.bullet-cap.clear-pointerized-item-mgr]c3",
        "of(ExpHP.bullet-cap.pointerize-bullets-shoot-top)": "a1f8b55a008d0408c3",
        "of(ExpHP.bullet-cap.pointerize-bullets-stack(8))": "a1f8b55a008945f8c3",
        "of(ExpHP.bullet-cap.pointerize-bullets-stack(20))": "a1f8b55a008945ecc3",
        "of(ExpHP.bullet-cap.pointerize-bullets-stack(100))": "a1f8b55a0089459cc3",
        "of(ExpHP.bullet-cap.pointerize-bullets-stack(96))": "a1f8b55a008945a0c3",
        "of(ExpHP.bullet-cap.pointerize-bullets-stack(112))": "a1f8b55a00894590c3",
        "of(ExpHP.bullet-cap.pointerize-bullets-stack(24))": "a1f8b55a008945e8c3",
        "of(ExpHP.bullet-cap.pointerize-bullets-reg(eax))": "a1f8b55a00c3",
        "of(ExpHP.bullet-cap.pointerize-bullets-reg(edx))": "8b15f8b55a00c3",
        "of(ExpHP.bullet-cap.pointerize-bullets-reg(ecx))": "8b0df8b55a00c3",
        "of(ExpHP.bullet-cap.pointerize-lasers-reg(ecx))": "8b0df81f6900c3",
        "of(ExpHP.bullet-cap.pointerize-lasers-reg(edx))": "8b15f81f6900c3",
        "of(ExpHP.bullet-cap.pointerize-lasers-reg(eax))": "a1f81f6900c3",
        "of(ExpHP.bullet-cap.fix-laser-cap(16, 4276776, 4277035))": "6801030000e8[codecave:ExpHP.bullet-cap.get-new-cap]3945f07c0de800000000c704242b434100c3e800000000c7042428424100c3",
        "of(ExpHP.bullet-cap.fix-laser-cap(16, 4277367, 4277651))": "6801030000e8[codecave:ExpHP.bullet-cap.get-new-cap]3945f07c0de800000000c7042493454100c3e800000000c7042477444100c3",
        "of(ExpHP.bullet-cap.fix-laser-cap(4, 4277932, 4278498))": "6801030000e8[codecave:ExpHP.bullet-cap.get-new-cap]3945fc7c0de800000000c70424e2484100c3e800000000c70424ac464100c3",
        "of(ExpHP.bullet-cap.fix-laser-cap(8, 4283943, 4285593))": "6801030000e8[codecave:ExpHP.bullet-cap.get-new-cap]3945f87c0de800000000c7042499644100c3e800000000c70424275e4100c3",
        "of(ExpHP.bullet-cap.fix-laser-cap(4, 4285777, 4286313))": "6801030000e8[codecave:ExpHP.bullet-cap.get-new-cap]3945fc7c0de800000000c7042469674100c3e800000000c7042451654100c3",
        "of(ExpHP.bullet-cap.pointerize-items-spawn(24))": "8b55e88b1201cac3",
        "of(ExpHP.bullet-cap.pointerize-items-spawn-wrap(24, edx))": "8b55e88b128955f8c3",
        "of(ExpHP.bullet-cap.pointerize-item-tick(204, 20))": "8b8534ffffff8b008945ecc3",
        "of(ExpHP.bullet-cap.pointerize-item-other(eax, 8, 12))": "8b008945f4c745f800000000c3",
        "of(ExpHP.bullet-cap.pointerize-item-other(eax, 4, 8))": "8b008945f8c745fc00000000c3"
    },
    "options": {
        "bullet-cap.bullet-cap": {
            "type": "i32",
            "val": 10240
        },
        "bullet-cap.laser-cap": {
            "type": "i32",
            "val": 1024
        },
        "bullet-cap.cancel-cap": {
            "type": "i32",
            "val": 8192
        },
        "bullet-cap.fairy-bullet-cap": {
            "type": "i32",
            "val": -1
        },
        "bullet-cap.rival-bullet-cap": {
            "type": "i32",
            "val": -1
        },
        "bullet-cap.anm-search-lag-spike-size": {
            "type": "i32",
            "val": 8192
        }
    },
    "binhacks": {
        "ExpHP.bullet-cap.install": {
            "addr": "0x41c05a",
            "expected": "e89188ffff",
            "code": "E9 [codecave:of(ExpHP.bullet-cap.install)]"
        },
        "ExpHP.bullet-cap.pointerize-bullets-constructor": {
            "addr": "0x413496",
            "expected": "c745d8c4050000",
            "code": "E9 [codecave:of(ExpHP.bullet-cap.pointerize-bullets-constructor)] // CCCC"
        },
        "ExpHP.bullet-cap.pointerize-items-constructor": {
            "addr": "0x41f240",
            "expected": "c745e444010000",
            "code": "E9 [codecave:of(ExpHP.bullet-cap.pointerize-items-constructor)] // CCCC"
        },
        "ExpHP.bullet-cap.pointerize-bullets-memset": {
            "addr": "0x41343f",
            "expected": "8b7dfc f3ab",
            "code": "E8 [codecave:of(ExpHP.bullet-cap.pointerize-bullets-memset)]"
        },
        "ExpHP.bullet-cap.pointerize-items-memset": {
            "addr": "0x41725a",
            "expected": "bf68e26900 f3ab",
            "code": "E8 [codecave:of(ExpHP.bullet-cap.pointerize-items-memset)] // 9090"
        },
        "ExpHP.bullet-cap.pointerize-bullets-nop": {
            "addr": "0x413552",
            "code": "9090909090"
        },
        "ExpHP.bullet-cap.pointerize-bullets-shoot-top": {
            "addr": "0x4135d7",
            "expected": "8d840a00560000",
            "code": "E8 [codecave:of(ExpHP.bullet-cap.pointerize-bullets-shoot-top)] // 9090"
        },
        "ExpHP.bullet-cap.pointerize-bullets-stack(8)": {
            "expected": "c745f8f8b55a00",
            "addr": [
                "0x40b8e6"
            ],
            "code": "E8 [codecave:of(ExpHP.bullet-cap.pointerize-bullets-stack(8))] // 9090"
        },
        "ExpHP.bullet-cap.pointerize-bullets-stack(20)": {
            "expected": "c745ecf8b55a00",
            "addr": [
                "0x40c1c0"
            ],
            "code": "E8 [codecave:of(ExpHP.bullet-cap.pointerize-bullets-stack(20))] // 9090"
        },
        "ExpHP.bullet-cap.pointerize-bullets-stack(100)": {
            "expected": "c7459cf8b55a00",
            "addr": [
                "0x40d40e",
                "0x40d537",
                "0x40df04"
            ],
            "code": "E8 [codecave:of(ExpHP.bullet-cap.pointerize-bullets-stack(100))] // 9090"
        },
        "ExpHP.bullet-cap.pointerize-bullets-stack(96)": {
            "expected": "c745a0f8b55a00",
            "addr": [
                "0x40d777"
            ],
            "code": "E8 [codecave:of(ExpHP.bullet-cap.pointerize-bullets-stack(96))] // 9090"
        },
        "ExpHP.bullet-cap.pointerize-bullets-stack(112)": {
            "expected": "c74590f8b55a00",
            "addr": [
                "0x40de11"
            ],
            "code": "E8 [codecave:of(ExpHP.bullet-cap.pointerize-bullets-stack(112))] // 9090"
        },
        "ExpHP.bullet-cap.pointerize-bullets-stack(24)": {
            "expected": "c745e8f8b55a00",
            "addr": [
                "0x41416a",
                "0x41437e"
            ],
            "code": "E8 [codecave:of(ExpHP.bullet-cap.pointerize-bullets-stack(24))] // 9090"
        },
        "ExpHP.bullet-cap.pointerize-bullets-reg(eax)": {
            "expected": "0500560000",
            "addr": [
                "0x4134a0",
                "0x4149dd",
                "0x4167e7",
                "0x41686d",
                "0x4168f3"
            ],
            "code": "E8 [codecave:of(ExpHP.bullet-cap.pointerize-bullets-reg(eax))]"
        },
        "ExpHP.bullet-cap.pointerize-bullets-reg(edx)": {
            "expected": "81c200560000",
            "addr": [
                "0x413657",
                "0x41695a"
            ],
            "code": "E8 [codecave:of(ExpHP.bullet-cap.pointerize-bullets-reg(edx))] // 90"
        },
        "ExpHP.bullet-cap.pointerize-bullets-reg(ecx)": {
            "expected": "81c100560000",
            "addr": [
                "0x416785",
                "0x4169bd",
                "0x416a42",
                "0x416ac7"
            ],
            "code": "E8 [codecave:of(ExpHP.bullet-cap.pointerize-bullets-reg(ecx))] // 90"
        },
        "ExpHP.bullet-cap.pointerize-lasers-reg(ecx)": {
            "expected": "81c100c00e00",
            "addr": [
                "0x4134ef"
            ],
            "code": "E8 [codecave:of(ExpHP.bullet-cap.pointerize-lasers-reg(ecx))] // 90"
        },
        "ExpHP.bullet-cap.pointerize-lasers-reg(edx)": {
            "expected": "81c200c00e00",
            "addr": [
                "0x4141f7"
            ],
            "code": "E8 [codecave:of(ExpHP.bullet-cap.pointerize-lasers-reg(edx))] // 90"
        },
        "ExpHP.bullet-cap.pointerize-lasers-reg(eax)": {
            "expected": "0500c00e00",
            "addr": [
                "0x414447",
                "0x41467c",
                "0x415df7",
                "0x416521"
            ],
            "code": "E8 [codecave:of(ExpHP.bullet-cap.pointerize-lasers-reg(eax))]"
        },
        "ExpHP.bullet-cap.fix-laser-cap(16, 4276776, 4277035)": {
            "expected": "837df040 // 0f8d",
            "addr": [
                "0x41421e"
            ],
            "code": "E9 [codecave:of(ExpHP.bullet-cap.fix-laser-cap(16, 4276776, 4277035))] // CC"
        },
        "ExpHP.bullet-cap.fix-laser-cap(16, 4277367, 4277651)": {
            "expected": "837df040 // 0f8d",
            "addr": [
                "0x41446d"
            ],
            "code": "E9 [codecave:of(ExpHP.bullet-cap.fix-laser-cap(16, 4277367, 4277651))] // CC"
        },
        "ExpHP.bullet-cap.fix-laser-cap(4, 4277932, 4278498)": {
            "expected": "837dfc40 // 0f8d",
            "addr": [
                "0x4146a2"
            ],
            "code": "E9 [codecave:of(ExpHP.bullet-cap.fix-laser-cap(4, 4277932, 4278498))] // CC"
        },
        "ExpHP.bullet-cap.fix-laser-cap(8, 4283943, 4285593)": {
            "expected": "837df840 // 0f8d",
            "addr": [
                "0x415e1d"
            ],
            "code": "E9 [codecave:of(ExpHP.bullet-cap.fix-laser-cap(8, 4283943, 4285593))] // CC"
        },
        "ExpHP.bullet-cap.fix-laser-cap(4, 4285777, 4286313)": {
            "expected": "837dfc40 // 0f8d",
            "addr": [
                "0x416547"
            ],
            "code": "E9 [codecave:of(ExpHP.bullet-cap.fix-laser-cap(4, 4285777, 4286313))] // CC"
        },
        "ExpHP.bullet-cap.pointerize-items-spawn(24)": {
            "expected": "8b55e8 // 03d1",
            "addr": [
                "0x41f2a8"
            ],
            "code": "E8 [codecave:of(ExpHP.bullet-cap.pointerize-items-spawn(24))]"
        },
        "ExpHP.bullet-cap.pointerize-items-spawn-wrap(24, edx)": {
            "expected": "8b55e88955f8",
            "addr": [
                "0x41f30e"
            ],
            "code": "E8 [codecave:of(ExpHP.bullet-cap.pointerize-items-spawn-wrap(24, edx))] // 90"
        },
        "ExpHP.bullet-cap.pointerize-item-tick(204, 20)": {
            "expected": "8b8534ffffff8945ec",
            "addr": [
                "0x41f4af"
            ],
            "code": "E8 [codecave:of(ExpHP.bullet-cap.pointerize-item-tick(204, 20))] // 90909090"
        },
        "ExpHP.bullet-cap.pointerize-item-other(eax, 8, 12)": {
            "expected": "8945f4c745f800000000",
            "addr": [
                "0x42019c"
            ],
            "code": "E8 [codecave:of(ExpHP.bullet-cap.pointerize-item-other(eax, 8, 12))] // 9090909090"
        },
        "ExpHP.bullet-cap.pointerize-item-other(eax, 4, 8)": {
            "expected": "8945f8c745fc00000000",
            "addr": [
                "0x42013c"
            ],
            "code": "E8 [codecave:of(ExpHP.bullet-cap.pointerize-item-other(eax, 4, 8))] // 9090909090"
        }
    }
}
