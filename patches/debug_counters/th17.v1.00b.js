{
    "COMMENT": "This file is autogenerated.  Please do not edit it directly.  See the convert-yaml.py script.",
    "codecaves": {
        "ExpHP.debug-counters.color-data": "78764B00 // 14920100 // 03000000",
        "ExpHP.debug-counters.drawf-debug-int": "55 89E5 56 57 // FF7514 // FF7510 // FF750C // FF7508 // B830854000 // FFD0 // 83C410 // 5F 5E 89EC 5D // C21000",
        "ExpHP.debug-counters.bullet-data": "01000000 // 8C764B00 // 01000000 // FFFFFFFF // 03484100 // EC000000 // 500E0000 // 880E0000",
        "ExpHP.debug-counters.normal-item-data": "01000000 // B8764B00 // 00000000 // 00000000 // 58020000 // 14000000 // 580C0000 // 780C0000",
        "ExpHP.debug-counters.cancel-item-data": "01000000 // B8764B00 // 01000000 // A8FDFFFF // F4314300 // 54391D00 // 580C0000 // 780C0000",
        "ExpHP.debug-counters.laser-data": "03000000 // BC764B00 // E4050000 // D1554300",
        "ExpHP.debug-counters.anmid-data": "02000000 // 209A5000 // DC060000 // E4060000 // FF3F0000",
        "ExpHP.debug-counters.line-info": "<codecave:ExpHP.debug-counters.anmid-data> // 25376420616E6D6964000000 // <codecave:ExpHP.debug-counters.bullet-data> // 253764206574616D61000000 // <codecave:ExpHP.debug-counters.laser-data> // 253764206C61736572000000 // <codecave:ExpHP.debug-counters.normal-item-data> // 253764206974656D4E000000 // <codecave:ExpHP.debug-counters.cancel-item-data> // 253764206974656D43000000 // 00000000",
        "of(ExpHP.debug-counters.draw)": "E8[codecave:ExpHP.debug-counters.show-debug-data] // A178764B00 // E800000000C70424 c89f4200 C3"
    },
    "binhacks": {
        "ExpHP.debug-counters.draw": {
            "addr": "0x429fc3",
            "expected": "a178764b00",
            "code": "E9 [codecave:of(ExpHP.debug-counters.draw)]"
        }
    }
}