{
    "COMMENT": "This file is autogenerated.  Please do not edit it directly.  See the convert-yaml.py script.",
    "binhacks": {
        "ExpHP.ddc-gap.no-demoplay": {
            "addr": "0x4399c8",
            "expected": "01355c574a00",
            "code": "909090909090"
        },
        "ExpHP.ddc-gap.start-server": {
            "addr": "0x408558",
            "expected": "8B3D688D4A00",
            "code": "E9 [codecave:of(ExpHP.ddc-gap.start-server)] // CC"
        },
        "ExpHP.ddc-gap.send-input": {
            "addr": "0x457a0b",
            "expected": "e840210000",
            "code": "E9 [codecave:of(ExpHP.ddc-gap.send-input)]"
        }
    },
    "codecaves": {
        "ExpHP.ddc-gap.corefuncs": "B8B14800 // 74B14800 // 70B14800 // F0B04800",
        "ExpHP.ddc-gap.gamedata": "A8924C00",
        "protection": 64,
        "ExpHP.ddc-gap.data": "52656C6561736553656D6170686F726500 // 43726561746553656D6170686F72654100 // 43726561746546696C654D617070696E674100 // 4D6170566965774F6646696C6500 // 45787048502D7373612D73742D7332632E73656D00 // 45787048502D7373612D73742D6332732E73656D00 // 45787048502D7373612D66722D7332632E73656D00 // 45787048502D7373612E73686D656D00 // 7500730065007200330032000000 // 4B00650072006E0065006C00330032000000 // 00000000 // 00000000 // 00000000 // 00000000 // 00000000 // 00000000 // 00000000 // 00000000 // 00000000 // 00000000",
        "ExpHP.ddc-gap.server-start-stage": "55 89E5 56 57 // E8[codecave:ExpHP.ddc-gap.initialize] // BF<codecave:ExpHP.ddc-gap.data> // 6A00 // 6A01 // 8B87C6000000 // 50 // FF97B6000000 // 6AFF // 8B87CA000000 // 50 // B8<codecave:ExpHP.ddc-gap.corefuncs> // FF500C // 5F 5E 89EC 5D // C3",
        "ExpHP.ddc-gap.client-start-stage": "55 89E5 56 57 // E8[codecave:ExpHP.ddc-gap.initialize] // BF<codecave:ExpHP.ddc-gap.data> // 6AFF // 8B87C6000000 // 50 // B8<codecave:ExpHP.ddc-gap.corefuncs> // FF500C // 6A00 // 6A01 // 8B87CA000000 // 50 // FF97B6000000 // 5F 5E 89EC 5D // C3",
        "ExpHP.ddc-gap.server-send-input": "55 89E5 56 57 // E8[codecave:ExpHP.ddc-gap.initialize] // BF<codecave:ExpHP.ddc-gap.gamedata> // 8B07 // 8B00 // BF<codecave:ExpHP.ddc-gap.data> // 8B8FD6000000 // 8901 // 5F 5E 89EC 5D // C3",
        "ExpHP.ddc-gap.client-recv-input": "55 89E5 56 57 // E8[codecave:ExpHP.ddc-gap.initialize] // BF<codecave:ExpHP.ddc-gap.data> // 8B87D6000000 // 8B00 // BF<codecave:ExpHP.ddc-gap.gamedata> // 8B0F // 8901 // 5F 5E 89EC 5D // C3",
        "ExpHP.ddc-gap.initialize-corefuncs": "BA<codecave:ExpHP.ddc-gap.corefuncs> // B904000000 // 8B02 // 8B00 // 8902 // 83C204 // 49 // 75F4 // C3",
        "ExpHP.ddc-gap.initialize": "55 89E5 56 57 // 53 // BF<codecave:ExpHP.ddc-gap.data> // 8B87B2000000 // 85C0 // 0F85C1000000 // E8[codecave:ExpHP.ddc-gap.initialize-corefuncs] // 8D87A0000000 // 50 // B8<codecave:ExpHP.ddc-gap.corefuncs> // FF5004 // 89C6 // BB<codecave:ExpHP.ddc-gap.corefuncs> // 8B5B08 // 8D07 // 50 // 56 // FFD3 // 8987B6000000 // 8D4722 // 50 // 56 // FFD3 // 8987BE000000 // 8D4711 // 50 // 56 // FFD3 // 8987BA000000 // 8D4735 // 50 // 56 // FFD3 // 8987C2000000 // BB<codecave:ExpHP.ddc-gap.create-semaphore> // 8D4743 // 50 // FFD3 // 8987C6000000 // 8D4758 // 50 // FFD3 // 8987CA000000 // 8D476D // 50 // FFD3 // 8987CE000000 // 8D8782000000 // 50 // 6A04 // 6A00 // 6A04 // 6A00 // 6AFF // FF97BE000000 // 85C0 // 7433 // 8987D2000000 // 6A00 // 6A00 // 6A00 // 681F000F00 // 50 // FF97C2000000 // 85C0 // 7417 // 8987D6000000 // C787B200000001000000 // 5B // 5F 5E 89EC 5D // C3 // B8<codecave:ExpHP.ddc-gap.corefuncs> // FF10 // CD03",
        "ExpHP.ddc-gap.create-semaphore": "55 89E5 56 57 // BF<codecave:ExpHP.ddc-gap.data> // 8B4508 // 50 // 6A01 // 6A00 // 6A00 // FF97BA000000 // 85C0 // 7509 // B8<codecave:ExpHP.ddc-gap.corefuncs> // FF10 // CD03 // 5F 5E 89EC 5D // C20400",
        "of(ExpHP.ddc-gap.start-server)": "E8[codecave:ExpHP.ddc-gap.server-start-stage] // 8B3D688D4A00 // E800000000 // C704245E854000 // C3",
        "of(ExpHP.ddc-gap.send-input)": "E8[codecave:ExpHP.ddc-gap.server-send-input] // B9A8924C00 // B8509B4500 // FFD0 // E800000000 // C70424107A4500 // C3"
    }
}