{
    "COMMENT": "This file is autogenerated.  Please do not edit it directly.  See the convert-yaml.py script.",
    "binhacks": {
        "ExpHP.sprite-death-fix.hack": {
            "addr": "0x465b60",
            "expected": "8d87a8000000",
            "code": "E9 [codecave:of(ExpHP.sprite-death-fix.hack)] // CC"
        }
    },
    "codecaves": {
        "ExpHP.sprite-death-fix.data": "480F4C00 // <codecave:ExpHP.sprite-death-fix.wrapper-thiscall> // 805A4600 // 1CFC8401 // 1CFCBC01",
        "ExpHP.sprite-death-fix.wrapper-thiscall": "55 89E5 56 57 // 8B4D0C // FF5508 // 5F 5E 89EC 5D // C20800",
        "ExpHP.sprite-death-fix.wrapper-esi": "55 89E5 56 57 // 8B750C // FF5508 // 5F 5E 89EC 5D // C20800",
        "ExpHP.sprite-death-fix.fix": "55 89E5 56 57 // BF<codecave:ExpHP.sprite-death-fix.data> // 8B37 // 8B36 // 8B4710 // 8D0C06 // 8B01 // 8D80A8000000 // 39C8 // 7C17 // 56 // FF7708 // FF5704 // 8B470C // 8D0406 // 8B4F10 // 89040E // 89440E04 // 5F 5E 89EC 5D // C3",
        "of(ExpHP.sprite-death-fix.hack)": "E8[codecave:ExpHP.sprite-death-fix.fix] // E800000000C70424765B4600C3"
    }
}
