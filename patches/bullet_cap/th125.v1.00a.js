{
    "COMMENT": "This file is autogenerated.  Please do not edit it directly.  See the convert-yaml.py script.",
    "codecaves": {
        "ExpHP.bullet-cap.address-range": "00104000 // 05634900",
        "ExpHP.bullet-cap.bullet-replacements": "D0070000 // 340A0000 // D0070000 // 00010100 // FFFFFFFF // F5984300 // A33C4600 // E0344700 // 00000000 // D1070000 // 00010100 // FFFFFFFF00000000 // 00000000",
        "ExpHP.bullet-cap.laser-replacements": "00010000 // 00000000 // 00010000 // 00010100 // 01000000 // 0D044200 // 62244200 // 2E2F4200 // BC404200 // 554B4200 // FA764200 // 00000000 // 00000000",
        "ExpHP.bullet-cap.cancel-replacements": "C8000000 // F4040000 // C8000000 // 00010100 // 01000000 // 4BF04100 // 3AFA4100 // 66FA4100 // 7EFA4100 // 7EF84100 // 06F44100 // 1CF34100 // 8AF24100 // 065B4900 // 00000000 // A0DE0300 // 01000100 // FFFFFFFF00000000 // 00000000",
        "ExpHP.bullet-cap.bullet-mgr-layout": "58000000 // 0000000000000000000000000000000000000000 // 6400000000030000000000000100010001000100 // D8C04F0000000000000000000000000000000000 // DCC04F0000000000000000000000000000000000EDEFCDAB // 90600000B6BB4F0001000000FFFFFFFF00000000 // 90600000D8C04F0001000000FFFFFFFF00000000 // 90600000DCC04F0001000000FFFFFFFF00000000 // 9060000074C04F0001000000FFFFFFFF00000000 // 00000000",
        "ExpHP.bullet-cap.item-mgr-layout": "58000000 // 0000000000000000000000000000000000000000 // 1400000002030000000000000100010001000100 // B4DE030000000000000000000000000000000000 // C8DE030000000000000000000000000000000000EDEFCDAB // 90600000B4DE030001000000FFFFFFFF00000000 // 90600000B8DE030001000000FFFFFFFF00000000 // 90600000BCDE030001000000FFFFFFFF00000000 // 90600000C0DE030001000000FFFFFFFF00000000 // 90600000C4DE030001000000FFFFFFFF00000000 // 90600000C8DE030001000000FFFFFFFF00000000 // 00000000",
        "ExpHP.bullet-cap.perf-fix-data": "00000000",
        "ExpHP.bullet-cap.iat-funcs": "C8714900 // 00000000 // 78714900 // EC704900 // 50724900",
        "ExpHP.bullet-cap.corefuncs": "3CB54600",
        "bullet-cap": "00007d00",
        "laser-cap": "00001000",
        "cancel-cap": "00000c80",
        "bullet-cap-config.anm-search-lag-spike-size": "00002000",
        "bullet-cap-config.mof-sa-lag-spike-size": "ffffffff",
        "of(ExpHP.bullet-cap.install)": "51 // E8[codecave:ExpHP.bullet-cap.initialize] // 59 // B8A0A14200FFD0 // E800000000C70424A8D94100C3"
    },
    "binhacks": {
        "ExpHP.bullet-cap.install": {
            "addr": "0x41d9a3",
            "expected": "e8f8c70000",
            "code": "E9 [codecave:of(ExpHP.bullet-cap.install)]"
        }
    }
}
