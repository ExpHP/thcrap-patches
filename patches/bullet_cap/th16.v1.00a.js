{
    "COMMENT": "This file is autogenerated.  Please do not edit it directly.  See the convert-yaml.py script.",
    "codecaves": {
        "ExpHP.bullet-cap.address-range": "00104000 // DAAC4800",
        "ExpHP.bullet-cap.bullet-replacements": "D0070000 // 78140000 // D0070000 // 00010100 // 01000000 // 431B4100 // 541C4100 // 3C6E4100 // 4E6F4100 // 00000000 // D1070000 // 00010100 // 01000000 // B5184100 // D5184100 // FA184100 // 0D194100 // 791D4100 // 9E1D4100 // 06A54800 // 00000000 // 8EF69F00 // 01000100 // 01000000 // 7A1A4100 // B11B4100 // 00000000 // 94FE9F00 // 01000100 // 01000000 // E0184100 // 841D4100 // 00000000 // 8CFC3F01 // 02000100 // 01000000 // F5184100 // B71B4100 // F0684100 // 23704100 // 00000000 // D01B4001 // 02040100 // 01000000 // 08194100 // 00000000 // 143B4001 // 02080100 // 01000000 // 881C4100 // 786A4100 // 7E6A4100 // 00000000 // 1C3B4001 // 02080100 // FFFFFFFF00000000 // 203B4001 // 02080100 // FFFFFFFF00000000 // 243B4001 // 02080100 // FFFFFFFF00000000 // 283B4001 // 02080100 // 01000000 // 01194100 // F51D4100 // 321E4100 // 5ED44200 // 61A54800 // 00000000 // F8FD9F00 // 01000100 // 01000000 // 8F1B4100 // 00000000 // 401F0000 // 00040100 // 01000000 // AA1B4100 // 00000000 // 00000000",
        "ExpHP.bullet-cap.laser-replacements": "00010000 // 00000000 // 00000000",
        "ExpHP.bullet-cap.cancel-replacements": "00080000 // C80B0000 // 00000000",
        "ExpHP.bullet-cap.perf-fix-data": "88C64D00 // 0882F400 // 30050000",
        "ExpHP.bullet-cap.iat-funcs": "8CB04800 // 00000000 // 84B14800 // D4B04800 // FCB14800",
        "bullet-cap": "00007d00",
        "laser-cap": "00002000",
        "cancel-cap": "00001000",
        "bullet-cap-config.anm-search-lag-spike-size": "00002000",
        "bullet-cap-config.mof-sa-lag-spike-size": "ffffffff",
        "of(ExpHP.bullet-cap.install)": "E8[codecave:ExpHP.bullet-cap.initialize] // B8B0C54300 // FFD0 // E800000000C70424 73d74200 C3"
    },
    "binhacks": {
        "ExpHP.bullet-cap.install": {
            "addr": "0x42d76e",
            "expected": "e83dee0000",
            "code": "E9 [codecave:of(ExpHP.bullet-cap.install)]"
        }
    }
}