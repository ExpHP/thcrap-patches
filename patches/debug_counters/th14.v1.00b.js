{
    "COMMENT": "This file is autogenerated.  Please do not edit it directly.  See the convert-yaml.py script.",
    "codecaves": {
        "ExpHP.debug-counters.color-data": "20B54D00 // B0910100",
        "ExpHP.debug-counters.drawf-debug-int": "55 89E5 56 57 // FF7514 // FF7510 // FF750C // FF7508 // B8C0BD4000 // FFD0 // 83C410 // 5F 5E 89EC 5D // C21000",
        "ExpHP.debug-counters.bullet-data": "01000000 // 30B54D00 // 01000000 // FFFFFFFF // 5C654100 // 8C000000 // 0E0C0000 // F4130000",
        "ExpHP.debug-counters.normal-item-data": "01000000 // 60B64D00 // 00000000 // 00000000 // 58020000 // 14000000 // F00B0000 // 180C0000",
        "ExpHP.debug-counters.cancel-item-data": "01000000 // 60B64D00 // 01000000 // A8FDFFFF // 7D844300 // 54581C00 // F00B0000 // 180C0000",
        "ExpHP.debug-counters.laser-data": "03000000 // 64B64D00 // D4050000 // 61A74300",
        "ExpHP.debug-counters.anmid-data": "02000000 // CC564F00 // 0882FE00 // 1082FE00 // FF1F0000",
        "ExpHP.debug-counters.line-info": "<codecave:ExpHP.debug-counters.anmid-data> // 25376420616E6D6964000000 // <codecave:ExpHP.debug-counters.bullet-data> // 253764206574616D61000000 // <codecave:ExpHP.debug-counters.laser-data> // 253764206C61736572000000 // <codecave:ExpHP.debug-counters.normal-item-data> // 253764206974656D4E000000 // <codecave:ExpHP.debug-counters.cancel-item-data> // 253764206974656D43000000 // 00000000",
        "of(ExpHP.debug-counters.draw)": "E8[codecave:ExpHP.debug-counters.show-debug-data] // A120B54D00 // E800000000C70424 58e64200 C3"
    },
    "binhacks": {
        "ExpHP.debug-counters.draw": {
            "addr": "0x42e653",
            "expected": "a120b54d00",
            "code": "E9 [codecave:of(ExpHP.debug-counters.draw)]"
        }
    }
}
