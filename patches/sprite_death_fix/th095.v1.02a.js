{
    "COMMENT": "This file is autogenerated.  Please do not edit it directly.  See the convert-yaml.py script.",
    "binhacks": {
        "ExpHP.sprite-death-fix.hack": {
            "addr": "0x43f3c9",
            "expected": "8b75088b45fc",
            "code": "E8 [codecave:of(ExpHP.sprite-death-fix.hack)] // 90"
        }
    },
    "codecaves": {
        "ExpHP.sprite-death-fix.data": "B8A14C00 // <codecave:ExpHP.sprite-death-fix.wrapper-thiscall> // F0F24300 // C8170000 // C8173800",
        "ExpHP.sprite-death-fix.wrapper-thiscall": "55 89E5 56 57 // 8B4D0C // FF5508 // 5F 5E 89EC 5D // C20800",
        "ExpHP.sprite-death-fix.wrapper-esi": "55 89E5 56 57 // 8B750C // FF5508 // 5F 5E 89EC 5D // C20800",
        "ExpHP.sprite-death-fix.fix": "55 89E5 56 57 // BF<codecave:ExpHP.sprite-death-fix.data> // 8B37 // 8B36 // 8B4710 // 8D0C06 // 8B01 // 8D80A8000000 // 39C8 // 7C17 // 56 // FF7708 // FF5704 // 8B470C // 8D0406 // 8B4F10 // 89040E // 89440E04 // 5F 5E 89EC 5D // C3",
        "of(ExpHP.sprite-death-fix.hack)": "E8[codecave:ExpHP.sprite-death-fix.fix] // 8B7508 // 8B45FC // C3"
    }
}
