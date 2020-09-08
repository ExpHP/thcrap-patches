{
    "COMMENT": "This file is autogenerated.  Please do not edit it directly.  See the convert-yaml.py script.",
    "binhacks": {
        "ExpHP.ddc-gap.no-demoplay": {
            "addr": "0x45995c",
            "expected": "890dbc584f00",
            "code": "909090909090"
        },
        "ExpHP.ddc-gap.start-client": {
            "addr": "0x41624d",
            "expected": "8b3d30b54d00",
            "code": "E9 [codecave:of(ExpHP.ddc-gap.start-client)] // CC"
        },
        "ExpHP.ddc-gap.get-input": {
            "addr": "0x402092",
            "expected": "e8a9540000",
            "code": "E9 [codecave:of(ExpHP.ddc-gap.get-input)]"
        },
        "ExpHP.cave-send-player-pos": {
            "addr": "0x44d805",
            "expected": "660f6e87ec050000",
            "code": "E9 [codecave:of(ExpHP.cave-send-player-pos)] // CCCCCC"
        }
    },
    "codecaves": {
        "ExpHP.ddc-gap.corefuncs": "94104B00 // 38114B00 // F8104B00 // A0104B00",
        "ExpHP.ddc-gap.gamedata": "78684D00",
        "protection": 64,
        "ExpHP.ddc-gap.data": "00000000 // 00000000 // 00000000 // 00000000 // 00000000 // 00000000 // 00000000 // 00000000 // 00000000 // 00000000 // 7500730065007200330032000000 // 4B00650072006E0065006C00330032000000 // 52656C6561736553656D6170686F726500 // 43726561746553656D6170686F72654100 // 43726561746546696C654D617070696E674100 // 4D6170566965774F6646696C6500 // 45787048502D7373612D73742D7332632E73656D00 // 45787048502D7373612D73742D6332732E73656D00 // 45787048502D7373612D66722D7332632E73656D00 // 45787048502D7373612E73686D656D00",
        "ExpHP.ddc-gap.server-start-stage": "55 89E5 56 57 // E8[codecave:ExpHP.ddc-gap.initialize] // BF<codecave:ExpHP.ddc-gap.data> // 6A00 // 6A01 // 8B4714 // 50 // FF5704 // 6AFF // 8B4718 // 50 // B8<codecave:ExpHP.ddc-gap.corefuncs> // FF500C // 5F 5E 89EC 5D // C3",
        "ExpHP.ddc-gap.client-start-stage": "55 89E5 56 57 // E8[codecave:ExpHP.ddc-gap.initialize] // BF<codecave:ExpHP.ddc-gap.data> // 6AFF // 8B4714 // 50 // B8<codecave:ExpHP.ddc-gap.corefuncs> // FF500C // 6A00 // 6A01 // 8B4718 // 50 // FF5704 // 5F 5E 89EC 5D // C3",
        "ExpHP.ddc-gap.server-send-input": "55 89E5 56 57 // E8[codecave:ExpHP.ddc-gap.initialize] // BF<codecave:ExpHP.ddc-gap.gamedata> // 8B07 // 8B00 // BF<codecave:ExpHP.ddc-gap.data> // 8B4F24 // 8901 // 5F 5E 89EC 5D // C3",
        "ExpHP.ddc-gap.client-recv-input": "55 89E5 56 57 // E8[codecave:ExpHP.ddc-gap.initialize] // BF<codecave:ExpHP.ddc-gap.data> // 8B4724 // 8B00 // BF<codecave:ExpHP.ddc-gap.gamedata> // 8B0F // 0901 // 5F 5E 89EC 5D // C3",
        "ExpHP.ddc-gap.send-player-pos": "55 89E5 56 57 // 8B7508 // BF<codecave:ExpHP.ddc-gap.data> // 8B7F24 // 8D7F04 // F30F7E06 // 660FD607 // 5F 5E 89EC 5D // C20400",
        "ExpHP.ddc-gap.recv-player-pos": "55 89E5 56 57 // 8B7508 // BF<codecave:ExpHP.ddc-gap.data> // 8B7F24 // 8D7F04 // F30F7E07 // 660FD606 // 5F 5E 89EC 5D // C20400",
        "ExpHP.ddc-gap.initialize-corefuncs": "BA<codecave:ExpHP.ddc-gap.corefuncs> // B904000000 // 8B02 // 8B00 // 8902 // 83C204 // 49 // 75F4 // C3",
        "ExpHP.ddc-gap.initialize": "55 89E5 56 57 // 53 // BF<codecave:ExpHP.ddc-gap.data> // 8B07 // 85C0 // 0F85A3000000 // E8[codecave:ExpHP.ddc-gap.initialize-corefuncs] // 8D4736 // 50 // B8<codecave:ExpHP.ddc-gap.corefuncs> // FF5004 // 89C6 // BB<codecave:ExpHP.ddc-gap.corefuncs> // 8B5B08 // 8D4748 // 50 // 56 // FFD3 // 894704 // 8D476A // 50 // 56 // FFD3 // 89470C // 8D4759 // 50 // 56 // FFD3 // 894708 // 8D477D // 50 // 56 // FFD3 // 894710 // BB<codecave:ExpHP.ddc-gap.create-semaphore> // 8D878B000000 // 50 // FFD3 // 894714 // 8D87A0000000 // 50 // FFD3 // 894718 // 8D87B5000000 // 50 // FFD3 // 89471C // 8D87CA000000 // 50 // 6A0C // 6A00 // 6A04 // 6A00 // 6AFF // FF570C // 85C0 // 7426 // 894720 // 6A00 // 6A00 // 6A00 // 681F000F00 // 50 // FF5710 // 85C0 // 7410 // 894724 // C70701000000 // 5B // 5F 5E 89EC 5D // C3 // B8<codecave:ExpHP.ddc-gap.corefuncs> // FF10 // CD03",
        "ExpHP.ddc-gap.create-semaphore": "55 89E5 56 57 // BF<codecave:ExpHP.ddc-gap.data> // 8B4508 // 50 // 6A01 // 6A00 // 6A00 // FF5708 // 85C0 // 7509 // B8<codecave:ExpHP.ddc-gap.corefuncs> // FF10 // CD03 // 5F 5E 89EC 5D // C20400",
        "of(ExpHP.ddc-gap.start-client)": "E8[codecave:ExpHP.ddc-gap.client-start-stage] // 8B3D30B54D00 // E800000000 // C7042453624100 // C3",
        "of(ExpHP.ddc-gap.get-input)": "E8[codecave:ExpHP.ddc-gap.client-recv-input] // B978684D00 // B840754000 // FFD0 // E800000000 // C7042497204000 // C3",
        "of(ExpHP.cave-send-player-pos)": "8D87EC050000 // 50 // E8[codecave:ExpHP.ddc-gap.send-player-pos] // 660F6E87EC050000 // E800000000 // C704240DD84400 // C3"
    }
}