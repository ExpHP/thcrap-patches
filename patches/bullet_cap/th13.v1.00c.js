{
    "COMMENT": "This file is autogenerated.  Please do not edit it directly.  See the convert-yaml.py script.",
    "codecaves": {
        "ExpHP.bullet-cap.address-range": "00104000 // D57A4900",
        "ExpHP.bullet-cap.bullet-replacements": "D0070000 // 5C130000 // D0070000 // 00010100 // FFFFFFFF // CF754200 // 02314700 // 00000000 // D1070000 // 00010100 // FFFFFFFF00000000 // 0E4B9700 // 01000100 // FFFFFFFF00000000 // AC529700 // 01000100 // FFFFFFFF00000000 // B0529700 // 01000100 // FFFFFFFF00000000 // B4529700 // 01000100 // FFFFFFFF00000000 // B8529700 // 01000100 // FFFFFFFF00000000 // 1C529700 // 01000100 // FFFFFFFF00000000 // 90010000 // 00010500 // 01000000 // ECD24000 // 58D54000 // 00000000 // 00000000",
        "ExpHP.bullet-cap.laser-replacements": "00010000 // 00000000 // 00010000 // 00010100 // 01000000 // DDFE4200 // D40E4300 // 14104300 // 4D114300 // A2124300 // 86224300 // 642D4300 // 663E4300 // 7B484300 // 88754300 // 00000000 // 00000000",
        "ExpHP.bullet-cap.cancel-replacements": "00080000 // C80B0000 // 580A0000 // 00010100 // FFFFFFFF // 00000000 // D4DC790001000100FFFFFFFF00000000 // D8DC790001000100FFFFFFFF00000000 // DCDC790001000100FFFFFFFF00000000 // E0DC790001000100FFFFFFFF00000000 // E4DC790001000100FFFFFFFF00000000 // E8DC790001000100FFFFFFFF00000000 // ECDC790001000100FFFFFFFF00000000 // F0DC790001000100FFFFFFFF00000000 // F4DC790001000100FFFFFFFF00000000 // F8DC790001000100FFFFFFFF00000000 // FCDC790001000100FFFFFFFF00000000 // 00DD790001000100FFFFFFFF00000000 // 04DD790001000100FFFFFFFF00000000 // C0DC7900 // 01000100 // FFFFFFFF00000000 // 00020000 // 00010400 // 01000000 // 2F404100 // 00000000 // 00000000",
        "ExpHP.bullet-cap.perf-fix-data": "88C64D00 // 0882F400 // 30050000",
        "ExpHP.bullet-cap.iat-funcs": "E4204A00 // 00000000 // 70214A00 // C8214A00 // 40224A00",
        "bullet-cap": "00007d00",
        "laser-cap": "00001000",
        "cancel-cap": "00008000",
        "bullet-cap-config.anm-search-lag-spike-size": "00002000",
        "bullet-cap-config.mof-sa-lag-spike-size": "ffffffff",
        "of(ExpHP.bullet-cap.install)": "51 // E8[codecave:ExpHP.bullet-cap.initialize] // 59 // B880B24300FFD0 // E800000000C70424F5C44200C3",
        "of(ExpHP.bullet-cap.cancel-perf-fix)": "52 // 51 // 51 // E8[codecave:ExpHP.bullet-cap.less-spikey-find-world-vm] // 59 // 5A // 85C0 // 7404 // 5D // C20400 // 56 // E800000000C70424 d1fb4600 C3"
    },
    "binhacks": {
        "ExpHP.bullet-cap.install": {
            "addr": "0x42c4f0",
            "expected": "e88bed0000",
            "code": "E9 [codecave:of(ExpHP.bullet-cap.install)]"
        },
        "ExpHP.bullet-cap.cancel-perf-fix": {
            "addr": "0x46fbae",
            "expected": "8b820882f400",
            "code": "E9 [codecave:of(ExpHP.bullet-cap.cancel-perf-fix)] // CC"
        }
    }
}
