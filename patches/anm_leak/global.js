{
    "COMMENT": "This file is autogenerated.  Please do not edit it directly.  See the convert-yaml.py script.",
    "codecaves": {
        "ExpHP.anm-buffers.game-data": "00000000",
        "ExpHP.anm-buffers.layer-data": "00000000",
        "ExpHP.anm-buffers.state": "00000000",
        "ExpHP.anm-buffers.get-batches": "B8<codecave:ExpHP.anm-buffers.state> // 8B00 // 85C0 // 7552 // 6A24 // B8<codecave:ExpHP.anm-buffers.game-data> // FF5008 // 83C404 // B9<codecave:ExpHP.anm-buffers.state> // 8901 // 6A00 // E8[codecave:ExpHP.anm-buffers.allocate-new-batch] // B9<codecave:ExpHP.anm-buffers.state> // 8B09 // 894108 // 89410C // 894110 // 894114 // C70101000000 // C7410400180000 // C74118EFBEADDE // C7411CEFBEADDE // C74120EFBEADDE // 89C8 // C3",
        "ExpHP.anm-buffers.new-alloc-vm": "5589E55657 // E8[codecave:ExpHP.anm-buffers.get-batches] // 89C6 // 8B4604 // 85C0 // 750C // 56 // E8[codecave:ExpHP.anm-buffers.deactivate-active-batch] // 56 // E8[codecave:ExpHP.anm-buffers.prepend-new-batch] // FF4E04 // 56 // E8[codecave:ExpHP.anm-buffers.scroll-to-free-batch] // FF7608 // E8[codecave:ExpHP.anm-buffers.take-free-vm-from-batch] // 5F5E89EC5D // C3",
        "ExpHP.anm-buffers.prepend-new-batch": "5589E583EC005657 // 8B7508 // FF36 // E8[codecave:ExpHP.anm-buffers.allocate-new-batch] // FF06 // 81460400180000 // 89C1 // 8B4608 // 89410C // 894E08 // 8B4614 // 894810 // 894E14 // 89C8 // 5F5E89EC5D // C20400",
        "ExpHP.anm-buffers.allocate-new-batch": "5589E583EC045657 // BF<codecave:ExpHP.anm-buffers.game-data> // 8B07 // 83C010 // 69C000180000 // 0514200100 // 50 // FF5708 // 83C404 // 89C6 // 8B4508 // 8906 // C7460800180000 // C7460C00000000 // C7461000000000 // C7460400000000 // 8D8614200100 // B900000000 // 81F900180000 // 731B // C7400800000000 // C7400C00000000 // 894804 // 8930 // 0307 // 83C010 // 41 // EBDD // 89F0 // 5F5E89EC5D // C20400",
        "ExpHP.anm-buffers.scroll-to-free-batch": "C8000000 // 8B4D08 // 8B4108 // 8B4008 // 85C0 // 7508 // 51 // E8[codecave:ExpHP.anm-buffers.deactivate-active-batch] // EBEB // C9 // C20400",
        "ExpHP.anm-buffers.deactivate-active-batch": "5589E55657 // 53 // 8B7508 // 8B4E08 // 8B560C // 894A0C // 89CA // 8B490C // C7420C00000000 // 894E08 // 89560C // 5B // 5F5E89EC5D // C20400",
        "ExpHP.anm-buffers.take-free-vm-from-batch": "5589E583EC005657 // 8B7508 // FF4E08 // 7907 // 68DB000000CD03 // 56 // E8[codecave:ExpHP.anm-buffers.locate-free-vm-in-batch] // 89C7 // 8B06 // 69C000180000 // 034704 // 894708 // C1E81B // 83E00F // 7407 // 68F0000000CD03 // FF470C // 83670C0F // 7503 // FF470C // 8B470C // C1E01B // 094708 // 2500000080 // 7407 // 6802010000CD03 // 8D4710 // 5F5E89EC5D // C20400",
        "ExpHP.anm-buffers.locate-free-vm-in-batch": "5589E583EC005657 // BF<codecave:ExpHP.anm-buffers.game-data> // 8B7508 // 8B0F // 83C110 // 0FAF4E04 // 8D8C0E14200100 // FF4604 // 817E0400180000 // 7207 // C7460400000000 // 8B4108 // 85C0 // 75D6 // 89C8 // 5F5E89EC5D // C20400",
        "ExpHP.anm-buffers.new-dealloc-vm": "5589E583EC00 // FF7508 // E8[codecave:ExpHP.anm-buffers.read-id-field] // 50 // E8[codecave:ExpHP.anm-buffers.is-snapshot-id] // 85C0 // 7410 // FF7508 // B8<codecave:ExpHP.anm-buffers.game-data> // FF500C // 83C404 // EB1A // E8[codecave:ExpHP.anm-buffers.get-batches] // FF4004 // 8B4508 // 8D40F0 // C7400800000000 // 8B10 // FF4208 // 89EC5D // C20400",
        "ExpHP.anm-buffers.assign-our-id": "5589E583EC005657 // 8B4508 // 8D70F0 // BA<codecave:ExpHP.anm-buffers.game-data> // 8B4D08 // 034A04 // 8B4608 // 8901 // 5F5E89EC5D // C20400",
        "ExpHP.anm-buffers.read-id-field": "5589E583EC00 // BA<codecave:ExpHP.anm-buffers.game-data> // 8B4D08 // 034A04 // 8B01 // 89EC5D // C20400",
        "ExpHP.anm-buffers.is-snapshot-id": "5589E583EC00 // 8B4508 // 2500000080 // 7405 // B801000000 // 89EC5D // C20400",
        "ExpHP.anm-buffers.new-search": "5589E583EC085657 // FF7508 // E8[codecave:ExpHP.anm-buffers.is-snapshot-id] // 85C0 // 7552 // 837D0800 // 744C // 31D2 // 8B4508 // 25FFFFFF87 // B900180000 // F7F1 // 8945F8 // 8955FC // E8[codecave:ExpHP.anm-buffers.get-batches] // 8B4010 // 8B4DF8 // 49 // 7805 // 8B4010 // EBF8 // BF<codecave:ExpHP.anm-buffers.game-data> // 8B17 // 83C210 // 0FAF55FC // 8D841014200100 // 8B5008 // 3B5508 // 7505 // 8D4010 // EB02 // 31C0 // 5F5E89EC5D // C20400",
        "ExpHP.anm-buffers.rebuild-layer-array": "5589E583EC08565753 // BE<codecave:ExpHP.anm-buffers.layer-data> // E8[codecave:ExpHP.anm-buffers.get-batches] // 8945F8 // FF75F8 // E8[codecave:ExpHP.anm-buffers.ensure-enough-batches-for-draw-array] // FF75F8 // E8[codecave:ExpHP.anm-buffers.clear-draw-array] // 8B4508 // 034604 // FF30 // 6A00 // FF75F8 // E8[codecave:ExpHP.anm-buffers.add-list-to-draw-array] // 8B4508 // 034608 // FF30 // 6A01 // FF75F8 // E8[codecave:ExpHP.anm-buffers.add-list-to-draw-array] // 5B5F5E89EC5D // C20400",
        "ExpHP.anm-buffers.ensure-enough-batches-for-draw-array": "5589E583EC04565753 // 8B7508 // B9<codecave:ExpHP.anm-buffers.game-data> // 8B4910 // 85C9 // 741A // B801000000 // D3E0 // 8945FC // 8B4604 // 3B45FC // 7308 // 56 // E8[codecave:ExpHP.anm-buffers.prepend-new-batch] // EBF0 // 5B5F5E89EC5D // C20400",
        "ExpHP.anm-buffers.clear-draw-array": "5589E583EC00 // 8B4D08 // 8B4108 // 894118 // C7411C00000000 // C7412000000000 // 89EC5D // C20400",
        "ExpHP.anm-buffers.add-list-to-draw-array": "5589E583EC00565753 // BE<codecave:ExpHP.anm-buffers.layer-data> // 8B5D10 // 83FB00 // 741E // 8B03 // 8B4E10 // 8B0C08 // 854E14 // 750C // 50 // FF750C // FF7508 // E8[codecave:ExpHP.anm-buffers.add-vm-to-draw-array] // 8B5B04 // EBDD // 5B5F5E89EC5D // C20C00",
        "ExpHP.anm-buffers.add-vm-to-draw-array": "5589E583EC045657 // BE<codecave:ExpHP.anm-buffers.layer-data> // 8B4510 // 8B4E0C // 8B0408 // 50 // FF750C // E8[codecave:ExpHP.anm-buffers.effective-layer] // 8945FC // 8B4D08 // FF4120 // 81791C00180000 // 7510 // 8B4118 // 8B400C // 894118 // C7411C00000000 // 8B511C // 6BD208 // 81C214600000 // 035118 // 8B4510 // 894204 // 8B45FC // 8902 // FF411C // 5F5E89EC5D // C20C00",
        "ExpHP.anm-buffers.effective-layer": "5589E583EC0456 // BE<codecave:ExpHP.anm-buffers.layer-data> // 8B4618 // 2B4620 // 8945FC // 837D0800 // 7513 // 8B550C // 2B5618 // 3B561C // 732B // 8B450C // 2B45FC // EB26 // 8B550C // 2B5620 // 3B561C // 7308 // 8B450C // 0345FC // EB13 // 8B550C // 2B5618 // 3B561C // 7205 // 8B4624 // EB03 // 8B450C // 5E89EC5D // C20800",
        "ExpHP.anm-buffers.debug-effective-layer": "5589E583EC00565753 // 81EC00030000 // 89E7 // B900030000 // 31C0 // F3AA // 8D842400010000 // 6A00 // 50 // E8[codecave:ExpHP.anm-buffers.debug-effective-layer-loop] // 8D842400020000 // 6A01 // 50 // E8[codecave:ExpHP.anm-buffers.debug-effective-layer-loop] // CD03 // 81C400030000 // 5B5F5E89EC5D // C20000",
        "ExpHP.anm-buffers.debug-effective-layer-loop": "5589E583EC04565753 // BE00000000 // 56 // FF750C // E8[codecave:ExpHP.anm-buffers.effective-layer] // 8B4D08 // 8901 // 83450804 // 46 // 83FE32 // 7CE8 // 5B5F5E89EC5D // C20800",
        "ExpHP.anm-buffers.fast-draw-layer": "5589E583EC14575653 // BE<codecave:ExpHP.anm-buffers.layer-data> // E8[codecave:ExpHP.anm-buffers.get-batches] // 8945FC // 8B4008 // 8945F4 // C745F000000000 // 8D8014600000 // 8945EC // 8B45FC // 8B4020 // 8945F8 // 837DF800 // 7446 // 817DF000180000 // 7519 // 8B45F4 // 8B400C // 8945F4 // C745F000000000 // 8D8014600000 // 8945EC // 8B45EC // 8B00 // 39450C // 750E // 8B45EC // 8B4004 // 50 // 8B4D08 // 8B06 // FFD0 // FF4DF8 // FF45F0 // 8345EC08 // EBB4 // 5B5E5F89EC5D // C20800"
    }
}
