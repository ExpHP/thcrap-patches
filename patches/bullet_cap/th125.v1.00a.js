{
    "COMMENT": "This file is autogenerated.  Please do not edit it directly.  See the convert-yaml.py script.",
    "codecaves": {
        "ExpHP.bullet-cap.address-range": "00104000 // 05634900",
        "ExpHP.bullet-cap.bullet-replacements": "D0070000 // 340A0000 // D0070000 // FFFFFFFF // FFFFFFFF // F5984300 // A33C4600 // E0344700 // 00000000 // D1070000 // FFFFFFFF // FFFFFFFF00000000 // B6BB4F00 // 01000000 // FFFFFFFF00000000 // D8C04F00 // 01000000 // FFFFFFFF00000000 // DCC04F00 // 01000000 // FFFFFFFF00000000 // 74C04F00 // 01000000 // FFFFFFFF00000000 // 00000000",
        "ExpHP.bullet-cap.laser-replacements": "00010000 // 00000000 // 00010000 // FFFFFFFF // 01000000 // 0D044200 // 62244200 // 2E2F4200 // BC404200 // 554B4200 // FA764200 // 00000000 // 00000000",
        "ExpHP.bullet-cap.cancel-replacements": "C8000000 // F4040000 // C8000000 // FFFFFFFF // 01000000 // 4BF04100 // 3AFA4100 // 66FA4100 // 7EFA4100 // 7EF84100 // 06F44100 // 1CF34100 // 8AF24100 // 065B4900 // 00000000 // B4DE0300 // 01000000 // FFFFFFFF00000000 // B8DE0300 // 01000000 // FFFFFFFF00000000 // BCDE0300 // 01000000 // FFFFFFFF00000000 // C0DE0300 // 01000000 // FFFFFFFF00000000 // C4DE0300 // 01000000 // FFFFFFFF00000000 // C8DE0300 // 01000000 // FFFFFFFF00000000 // A0DE0300 // 01000000 // FFFFFFFF00000000 // 00000000",
        "ExpHP.bullet-cap.perf-fix-data": "00000000",
        "ExpHP.bullet-cap.iat-funcs": "C8714900 // 00000000 // 78714900 // EC704900 // 50724900",
        "bullet-cap": "00007d00",
        "laser-cap": "00001000",
        "cancel-cap": "00000c80",
        "bullet-cap-config.anm-search-lag-spike-size": "00002000",
        "bullet-cap-config.mof-sa-lag-spike-size": "ffffffff",
        "of(ExpHP.bullet-cap.install)": "E8[codecave:ExpHP.bullet-cap.initialize] // B8A0A14200 // FFD0 // E800000000C70424 a8d94100 C3"
    },
    "binhacks": {
        "ExpHP.bullet-cap.install": {
            "addr": "0x41d9a3",
            "expected": "e8f8c70000",
            "code": "E9 [codecave:of(ExpHP.bullet-cap.install)]"
        }
    }
}
