{
    "COMMENT": "This file is autogenerated.  Please do not edit it directly.  See the convert-yaml.py script.",
    "codecaves": {
        "ExpHP.bullet-cap.address-range": "00104000 // D57A4900",
        "ExpHP.bullet-cap.bullet-replacements": "D0070000 // F8090000 // D0070000 // 00000000 // FFFFFFFF // 10EC4100 // 63484600 // 08854700 // 00000000 // D1070000 // 00000000 // FFFFFFFF00000000 // 16E74D00 // 01000000 // FFFFFFFF00000000 // DCEB4D00 // 01000000 // FFFFFFFF00000000 // E0EB4D00 // 01000000 // FFFFFFFF00000000 // 78EB4D00 // 01000000 // FFFFFFFF00000000 // 00000000",
        "ExpHP.bullet-cap.laser-replacements": "00010000 // 00000000 // 00010000 // 00000000 // 01000000 // 5D844200 // 48BC4100 // 60A14200 // 62A74200 // C2B64200 // 03BD4200 // 00000000 // 00000000",
        "ExpHP.bullet-cap.cancel-replacements": "00080000 // D8090000 // 680A0000 // 00000000 // FFFFFFFF // 269B4200 // 005A4300 // 00000000 // D46F6600 // 01000000 // FFFFFFFF00000000 // D86F6600 // 01000000 // FFFFFFFF00000000 // DC6F6600 // 01000000 // FFFFFFFF00000000 // E06F6600 // 01000000 // FFFFFFFF00000000 // E46F6600 // 01000000 // FFFFFFFF00000000 // C06F6600 // 01000000 // FFFFFFFF00000000 // 00000000",
        "ExpHP.bullet-cap.perf-fix-data": "00000000",
        "ExpHP.bullet-cap.iat-funcs": "E4804900 // 00000000 // 74814900 // 70814900",
        "bullet-cap": "00007d00",
        "laser-cap": "00001000",
        "cancel-cap": "00008000",
        "bullet-cap-config.mof-sa-lag-spike-size": "00002000",
        "of(ExpHP.bullet-cap.install)": "E8[codecave:ExpHP.bullet-cap.initialize] // BED8F04C00 // E800000000 // C7042423054300 // C3",
        "of(ExpHP.bullet-cap.fix-next-cancel)": "52 // E8[codecave:ExpHP.bullet-cap.next-cancel-index] // 89C2 // E800000000 // C704246A784200 // C3"
    },
    "binhacks": {
        "ExpHP.bullet-cap.install": {
            "addr": "0x43051e",
            "expected": "bed8f04c00",
            "code": "E9 [codecave:of(ExpHP.bullet-cap.install)]"
        },
        "ExpHP.bullet-cap.fix-next-cancel": {
            "addr": "0x427859",
            "expected": "4281e2ff070080",
            "code": "E9 [codecave:of(ExpHP.bullet-cap.fix-next-cancel)] // CCCC"
        },
        "ExpHP.bullet-cap.fix-ufo-item-bugs": {
            "addr": [
                "0x427243",
                "0x427b5d"
            ],
            "expected": "580a0000",
            "code": "680a0000"
        }
    }
}
