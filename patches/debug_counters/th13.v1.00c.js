{
    "COMMENT": "This file is autogenerated.  Please do not edit it directly.  See the convert-yaml.py script.",
    "codecaves": {
        "ExpHP.debug-counters.color-data": "60214C00 // 60910100 // 02000000",
        "ExpHP.debug-counters.drawf-debug-int": "55 89E5 56 57 // 53 // 83EC04 // 89E7 // FF7514 // FF7510 // 8B5D0C // 8B7508 // B8E0404000 // FFD0 // 83C408 // 83C404 // 5B // 5F 5E 89EC 5D // C21000",
        "ExpHP.debug-counters.bullet-data": "01000000 // 74214C00 // 01000000 // FFFFFFFF // 6CD94000 // 90000000 // BE0B0000 // 5C130000",
        "ExpHP.debug-counters.normal-item-data": "01000000 // 9C224C00 // 00000000 // 00000000 // 58020000 // 14000000 // A00B0000 // C80B0000",
        "ExpHP.debug-counters.cancel-item-data": "01000000 // 9C224C00 // 01000000 // A8FDFFFF // BCE24200 // D49C1B00 // A00B0000 // C80B0000",
        "ExpHP.debug-counters.laser-data": "03000000 // A0224C00 // D4050000 // DDFE4200",
        "ExpHP.debug-counters.anmid-data": "02000000 // 88C64D00 // 0882F400 // 1082F400 // FF1F0000",
        "ExpHP.debug-counters.spirit-data": "03000000 // A4224C00 // 14880000 // 74864300",
        "ExpHP.debug-counters.line-info": "<codecave:ExpHP.debug-counters.anmid-data> // 25376420616E6D6964000000 // <codecave:ExpHP.debug-counters.bullet-data> // 253764206574616D61000000 // <codecave:ExpHP.debug-counters.laser-data> // 253764206C61736572000000 // <codecave:ExpHP.debug-counters.normal-item-data> // 253764206974656D4E000000 // <codecave:ExpHP.debug-counters.cancel-item-data> // 253764206974656D43000000 // <codecave:ExpHP.debug-counters.spirit-data> // 253764206C676F6473000000 // 00000000",
        "of(ExpHP.debug-counters.draw)": "E8[codecave:ExpHP.debug-counters.show-debug-data] // 8B0D60214C00 // E800000000C70424 324b4200 C3"
    },
    "binhacks": {
        "ExpHP.debug-counters.draw": {
            "addr": "0x424b2c",
            "expected": "8b0d60214c00",
            "code": "E9 [codecave:of(ExpHP.debug-counters.draw)] // CC"
        }
    }
}