{
    "COMMENT": "This file is autogenerated.  Please do not edit it directly.  See the convert-yaml.py script.",
    "codecaves": {
        "ExpHP.bullet-cap.address-range": "00104000 // 815A4600",
        "ExpHP.bullet-cap.bullet-replacements": "D0070000 // F0070000 // D0070000 // 00010100 // FFFFFFFF // 09564100 // 7EBD4400 // 00000000 // D1070000 // 00010100 // FFFFFFFF00000000 // BC820F00 // 01000400 // FFFFFFFF00000000 // 00000000",
        "ExpHP.bullet-cap.laser-replacements": "00010000 // 00000000 // 00010000 // 00010100 // 01000000 // 16C54100 // 00000000 // 00000000",
        "ExpHP.bullet-cap.cancel-replacements": "00080000 // F0030000 // 96080000 // 00010100 // FFFFFFFF00000000 // A8730800 // 01000400 // FFFFFFFF00000000 // 00000000",
        "ExpHP.bullet-cap.bullet-mgr-layout": "58000000 // 0000000000000000000000000000000000000000 // 6000000000030000000000000100010001000100 // 500B3E0000000000000000000000000000000000 // 540B3E0000000000000000000000000000000000EDEFCDAB // 90600000A6073E0001000000FFFFFFFF00000000 // 90600000500B3E0001000000FFFFFFFF00000000 // 90600000540B3E0001000000FFFFFFFF00000000 // 90600000540B3E0004000000 // 01000000 // E15C4000 // B5604000 // 00000000 // 00000000",
        "ExpHP.bullet-cap.item-mgr-layout": "58000000 // 0000000000000000000000000000000000000000 // B44E020002030000000000000100010001000100 // B4CE210000000000000000000000000000000000 // C0CE210000000000000000000000000000000000EDEFCDAB // 90600000B4CE210001000000FFFFFFFF00000000 // 90600000B8CE210001000000FFFFFFFF00000000 // 90600000BCCE210001000000FFFFFFFF00000000 // 90600000C0CE210001000000FFFFFFFF00000000 // 90600000C0CE210004000000 // 01000000 // D1AC4100 // 27AF4100 // 00000000 // 00000000",
        "ExpHP.bullet-cap.perf-fix-data": "101C4900 // D4DA7200 // 00000000",
        "ExpHP.bullet-cap.iat-funcs": "DCFA4500 // 98614600 // 00000000 // 58614600 // 34624600",
        "ExpHP.bullet-cap.corefuncs": "93244500",
        "bullet-cap": "00007d00",
        "laser-cap": "00001000",
        "cancel-cap": "00008000",
        "bullet-cap-config.anm-search-lag-spike-size": "00002000",
        "bullet-cap-config.mof-sa-lag-spike-size": "ffffffff",
        "of(ExpHP.bullet-cap.install)": "51 // E8[codecave:ExpHP.bullet-cap.initialize] // 59 // B850C14400FFD0 // E800000000C70424CD0E4200C3",
        "of(ExpHP.bullet-cap.fix-next-cancel)": "52 // E8[codecave:ExpHP.bullet-cap.next-cancel-index] // 89C2 // E800000000C70424 0abe4100 C3",
        "of(ExpHP.bullet-cap.cancel-perf-fix)": "52 // 51 // 51 // E8[codecave:ExpHP.bullet-cap.less-spikey-find-world-vm] // 59 // 5A // 85C0 // 7404 // 90 // C20400 // 56 // E800000000C70424 e5914400 C3"
    },
    "binhacks": {
        "ExpHP.bullet-cap.install": {
            "addr": "0x420ec8",
            "expected": "e883b20200",
            "code": "E9 [codecave:of(ExpHP.bullet-cap.install)]"
        },
        "ExpHP.bullet-cap.fix-next-cancel": {
            "addr": "0x41bdf9",
            "expected": "4281e2ff070080",
            "code": "E9 [codecave:of(ExpHP.bullet-cap.fix-next-cancel)] // CCCC"
        },
        "ExpHP.bullet-cap.cancel-perf-fix": {
            "addr": "0x4491cd",
            "expected": "8b82d4da7200",
            "code": "E9 [codecave:of(ExpHP.bullet-cap.cancel-perf-fix)] // CC"
        }
    }
}
