{
    "COMMENT": "This file is autogenerated.  Please do not edit it directly.  See the convert-yaml.py script.",
    "codecaves": {
        "ExpHP.debug-counters.color-data": "E0764700 // 74890000 // 01000000",
        "ExpHP.debug-counters.drawf-debug-int": "55 89E5 56 57 // 53 // FF7514 // FF7510 // 8B5D0C // 8B7508 // B890164000 // FFD0 // 83C408 // 5B // 5F 5E 89EC 5D // C21000",
        "ExpHP.debug-counters.bullet-data": "01000000 // F0764700 // 01000000 // 00000000 // 52584200 // 60000000 // 46040000 // F0070000",
        "ExpHP.debug-counters.normal-item-data": "01000000 // 18784700 // 00000000 // 00000000 // 96000000 // 14000000 // DC030000 // F0030000",
        "ExpHP.debug-counters.cancel-item-data": "01000000 // 18784700 // 01000000 // 6AFFFFFF // 12AF4100 // B44E0200 // DC030000 // F0030000",
        "ExpHP.debug-counters.laser-data": "03000000 // 1C784700 // 38040000 // 16C54100",
        "ExpHP.debug-counters.anmid-data": "02000000 // 101C4900 // D4DA7200 // DCDA7200 // 00100000",
        "ExpHP.debug-counters.line-info": "<codecave:ExpHP.debug-counters.anmid-data> // 25376420616E6D6964000000 // <codecave:ExpHP.debug-counters.bullet-data> // 253764206574616D61000000 // <codecave:ExpHP.debug-counters.laser-data> // 253764206C61736572000000 // <codecave:ExpHP.debug-counters.normal-item-data> // 253764206974656D4E000000 // <codecave:ExpHP.debug-counters.cancel-item-data> // 253764206974656D43000000 // 00000000",
        "of(ExpHP.debug-counters.draw)": "E8[codecave:ExpHP.debug-counters.show-debug-data] // A1E0764700 // E800000000C70424 58364100 C3"
    },
    "binhacks": {
        "ExpHP.debug-counters.draw": {
            "addr": "0x413653",
            "expected": "a1e0764700",
            "code": "E9 [codecave:of(ExpHP.debug-counters.draw)]"
        }
    }
}
