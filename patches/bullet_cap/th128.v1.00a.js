{
    "COMMENT": "This file is autogenerated.  Please do not edit it directly.  See the convert-yaml.py script.",
    "codecaves": {
        "ExpHP.bullet-cap.address-range": "00104000 // 159C4900",
        "ExpHP.bullet-cap.bullet-replacements": "D0070000 // B8110000 // D0070000 // 00010100 // FFFFFFFF // 52F84000 // 46F94000 // EF034100 // 6BE74100 // 80224200 // BFA44300 // 04BA4300 // ADDF4300 // DADF4300 // 43FD4300 // 4BFF4300 // 55FF4300 // 8CE74500 // 72A84600 // 00000000 // D1070000 // 00010100 // FFFFFFFF00000000 // 387F8A00 // 01000100 // FFFFFFFF00000000 // 00000000",
        "ExpHP.bullet-cap.laser-replacements": "00010000 // 00000000 // 00010000 // 00010100 // 01000000 // 0DA44200 // 14B44200 // 54B54200 // 8DB64200 // E2B74200 // D9C74200 // 5ED24200 // 7FE14200 // 48EB4200 // 22174300 // 00000000 // 00000000",
        "ExpHP.bullet-cap.cancel-replacements": "64000000 // 400A0000 // CC020000 // 00010100 // 01000000 // BB824200 // DB844200 // 4C854200 // D9904200 // 23924200 // 00000000 // 64000000 // 00010100 // 01000000 // 2D954200 // 00000000 // 00AB1C00 // 01000100 // FFFFFFFF00000000 // 00000000",
        "ExpHP.bullet-cap.bullet-mgr-layout": "58000000 // 0000000000000000000000000000000000000000 // 6400000000030000000000000100010001000100 // 9C7F8A0000000000000000000000000000000000 // A07F8A0000000000000000000000000000000000EDEFCDAB // 906000000E788A0001000000FFFFFFFF00000000 // 906000009C7F8A0001000000FFFFFFFF00000000 // 90600000A07F8A0001000000FFFFFFFF00000000 // 00000000",
        "ExpHP.bullet-cap.item-mgr-layout": "58000000 // 0000000000000000000000000000000000000000 // 1400000002030000000000000100010001000100 // 14AB1C0000000000000000000000000000000000 // 24AB1C0000000000000000000000000000000000EDEFCDAB // 9060000014AB1C0001000000FFFFFFFF00000000 // 9060000018AB1C0001000000FFFFFFFF00000000 // 906000001CAB1C0001000000FFFFFFFF00000000 // 9060000020AB1C0001000000FFFFFFFF00000000 // 9060000024AB1C0001000000FFFFFFFF00000000 // 00000000",
        "ExpHP.bullet-cap.perf-fix-data": "00000000",
        "ExpHP.bullet-cap.iat-funcs": "C8A14900 // 00000000 // 68A14900 // ECA04900 // 40A24900",
        "ExpHP.bullet-cap.corefuncs": "6C294700",
        "bullet-cap": "00007d00",
        "laser-cap": "00001000",
        "cancel-cap": "00000640",
        "bullet-cap-config.anm-search-lag-spike-size": "00002000",
        "bullet-cap-config.mof-sa-lag-spike-size": "ffffffff",
        "of(ExpHP.bullet-cap.install)": "51 // E8[codecave:ExpHP.bullet-cap.initialize] // 59 // B8B04C4300FFD0 // E800000000C7042475694200C3"
    },
    "binhacks": {
        "ExpHP.bullet-cap.install": {
            "addr": "0x426970",
            "expected": "e83be30000",
            "code": "E9 [codecave:of(ExpHP.bullet-cap.install)]"
        },
        "ExpHP.bullet-cap.fix-ufo-item-bugs": {
            "addr": "0x429223",
            "expected": "bc020000",
            "code": "cc020000"
        }
    }
}
