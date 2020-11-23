{
    "COMMENT": "This file is autogenerated.  Please do not edit it directly.  See the convert-yaml.py script.",
    "codecaves": {
        "ExpHP.bullet-cap.address-range": "00104000 // DAAC4800",
        "ExpHP.bullet-cap.bullet-replacements": "D0070000 // 78140000 // D0070000 // 00010100 // 01000000 // 431B4100 // 541C4100 // 3C6E4100 // 4E6F4100 // 00000000 // D1070000 // 00010100 // 01000000 // B5184100 // D5184100 // FA184100 // 0D194100 // 791D4100 // 9E1D4100 // 06A54800 // 00000000 // F8FD9F00 // 01000100 // 01000000 // 8F1B4100 // 00000000 // 401F0000 // 00040100 // 01000000 // AA1B4100 // 00000000 // 00000000",
        "ExpHP.bullet-cap.laser-replacements": "00020000 // 00000000 // 00020000 // 00010100 // 01000000 // 71174300 // 7D4B4100 // 73274300 // BF284300 // 252A4300 // 822B4300 // 653F4300 // 1A4C4300 // 6F5F4300 // C06B4300 // A4494100 // 4D9C4300 // 00000000 // 00000000",
        "ExpHP.bullet-cap.cancel-replacements": "00100000 // 780C0000 // 00100000 // 00010100 // 01000000 // 4F854100 // 00000000 // 58120000 // 00010100 // 01000000 // E6F04200 // 06F14200 // 78F14200 // EBF34200 // 0DF44200 // 7F004300 // B0074300 // 00000000 // 40B9E400 // 01000100 // 01000000 // A6844100 // 00000000 // 00000000",
        "ExpHP.bullet-cap.bullet-mgr-layout": "94000000 // 0000000000000000000000000000000000000000 // 9C00000000030000000000000100010001000100 // 94FE9F0000030000000000000100010001000100 // 8CFC3F0100030000000000000004010000040100 // D01B400100030000000000000004010000040100 // 143B400100000000000000000000000000000000 // 283B400100000000000000000000000000000000EDEFCDAB // 90600000000000008EF69F0001000000 // 01000000 // 7A1A4100 // B11B4100 // 00000000 // 906000000000000094FE9F0001000000 // 01000000 // E0184100 // 841D4100 // 00000000 // 90600000000000008CFC3F0101000000 // 01000000 // F5184100 // B71B4100 // F0684100 // 23704100 // 00000000 // 9060000000000000D01B400101000000 // 01000000 // 08194100 // 00000000 // 9060000000000000143B400101000000 // 01000000 // 881C4100 // 786A4100 // 7E6A4100 // 00000000 // 90600000000000001C3B400101000000 // FFFFFFFF00000000 // 9060000000000000203B400101000000 // FFFFFFFF00000000 // 9060000000000000243B400101000000 // FFFFFFFF00000000 // 9060000000000000283B400101000000 // 01000000 // 01194100 // F51D4100 // 321E4100 // 5ED44200 // 61A54800 // 00000000 // 00000000",
        "ExpHP.bullet-cap.item-mgr-layout": "80000000 // 0000000000000000000000000000000000000000 // 54391D0002030000000000000100010001000100 // 54B9E40000000000000000000000000000000000 // B8F2010102030000000000000100010001000100 // B872C90100000000000000000000000000000000 // EC72C90100000000000000000000000000000000EDEFCDAB // 9160000054B9E40079B9E400 // 01000000 // CB844100 // B9094300 // 39854100 // 020B4300 // 99854100 // 48FA4200 // A7FA4200 // CCFA4200 // 8D004300 // AF004300 // 0CF14200 // F6F34200 // 00000000 // 91600000DC72C901EC72C901 // 01000000 // 29F54200 // 4E004300 // B1844100 // 6E094300 // 290B4300 // 470B4300 // 630B4300 // 1FF54200 // 1C0B4300 // BC844100 // 100B4300 // 00000000 // 9060000000000000EC72C90101000000 // 01000000 // 7DD44200 // 26F14200 // 65F44200 // A2F44200 // 21A84800 // 00000000 // 00000000",
        "ExpHP.bullet-cap.perf-fix-data": "00000000",
        "ExpHP.bullet-cap.iat-funcs": "8CB04800 // 00000000 // 84B14800 // D4B04800 // FCB14800",
        "ExpHP.bullet-cap.corefuncs": "AC494700",
        "bullet-cap": "ffff ffff",
        "laser-cap": "ffff ffff",
        "cancel-cap": "ffff ffff",
        "bullet-cap-config.anm-search-lag-spike-size": "ffff ffff",
        "bullet-cap-config.mof-sa-lag-spike-size": "ffff ffff",
        "of(ExpHP.bullet-cap.install)": "51e8[codecave:ExpHP.bullet-cap.initialize]59b8b0c54300ffd0e800000000c7042473d74200c3"
    },
    "options": {
        "bullet-cap.bullet-cap": {
            "type": "i32",
            "val": 32000
        },
        "bullet-cap.laser-cap": {
            "type": "i32",
            "val": 8192
        },
        "bullet-cap.cancel-cap": {
            "type": "i32",
            "val": 65536
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
            "addr": "0x42d76e",
            "expected": "e83dee0000",
            "code": "E9 [codecave:of(ExpHP.bullet-cap.install)]"
        }
    }
}
