{
    "COMMENT": "This file is autogenerated.  Please do not edit it directly.  See the convert-yaml.py script.",
    "codecaves": {
        "ExpHP.anm-buffers.state": "00000000",
        "ExpHP.anm-buffers.get-batches": "B8<codecave:ExpHP.anm-buffers.state> // 8B00 // 85C0 // 752E // 6A0C // B8<codecave:ExpHP.anm-buffers.game-data> // FF5008 // 83C404 // B9<codecave:ExpHP.anm-buffers.state> // 8901 // E8[codecave:ExpHP.anm-buffers.allocate-new-batch] // B9<codecave:ExpHP.anm-buffers.state> // 8B09 // 894104 // 894108 // C70100180000 // 89C8 // C3",
        "ExpHP.anm-buffers.new-alloc-vm": "5589E55657 // E8[codecave:ExpHP.anm-buffers.get-batches] // 89C6 // 8B06 // 85C0 // 751C // 56 // E8[codecave:ExpHP.anm-buffers.deactivate-active-batch] // E8[codecave:ExpHP.anm-buffers.allocate-new-batch] // 89C1 // 8B4604 // 894108 // 894E04 // 810600180000 // FF0E // 56 // E8[codecave:ExpHP.anm-buffers.scroll-to-free-batch] // FF7604 // E8[codecave:ExpHP.anm-buffers.take-free-vm-from-batch] // 5F5E89EC5D // C3",
        "ExpHP.anm-buffers.allocate-new-batch": "5589E55657 // BF<codecave:ExpHP.anm-buffers.game-data> // 8B07 // 83C008 // 69C000180000 // 050C600000 // 50 // FF5708 // 83C404 // 89C6 // C7460400180000 // C7460800000000 // C70600000000 // 8D860C600000 // B900180000 // 49 // 7810 // C7400400000000 // 8930 // 0307 // 83C008 // EBED // 89F0 // 5F5E89EC5D // C3",
        "ExpHP.anm-buffers.scroll-to-free-batch": "C8000000 // 8B4D08 // 8B4104 // 8B4004 // 85C0 // 7508 // 51 // E8[codecave:ExpHP.anm-buffers.deactivate-active-batch] // EBEB // C9 // C20400",
        "ExpHP.anm-buffers.deactivate-active-batch": "5589E55657 // 53 // 8B7508 // 8B4E04 // 8B5608 // 894A08 // 89CA // 8B4908 // C7420800000000 // 894E04 // 895608 // 8D7A0C // 8DB20C600000 // 8D7608 // BA<codecave:ExpHP.anm-buffers.game-data> // 037204 // 8B12 // 83C208 // B900180000 // 49 // 780B // 8B1E // 891F // 01D6 // 83C704 // EBF2 // 5B // 5F5E89EC5D // C20400",
        "ExpHP.anm-buffers.take-free-vm-from-batch": "5589E55657 // 8B7508 // BA<codecave:ExpHP.anm-buffers.game-data> // FF4E04 // 7902 // CD03 // 8B0A // 83C108 // 0FAF0E // 8D8C0E0C600000 // FF06 // 813E00180000 // 7C06 // C70600000000 // 8B4104 // 85C0 // 75DA // C7410401000000 // 8D4108 // 5F5E89EC5D // C20400",
        "ExpHP.anm-buffers.new-dealloc-vm": "8B442404 // 8D40F8 // C7400400000000 // 8B08 // FF4104 // E8[codecave:ExpHP.anm-buffers.get-batches] // FF00 // C20400",
        "ExpHP.anm-buffers.new-search": "5589E55657 // BF<codecave:ExpHP.anm-buffers.search-batch-for-id> // E8[codecave:ExpHP.anm-buffers.get-batches] // 8B7004 // 85F6 // 7414 // FF7508 // 56 // FFD7 // 85C0 // 750C // BF<codecave:ExpHP.anm-buffers.search-inactive-batch-for-id> // 8B7608 // EBE8 // 31C0 // 5F5E89EC5D // C20400",
        "ExpHP.anm-buffers.search-batch-for-id": "5589E55657 // 8B5508 // 8DB20C600000 // 8D7608 // BA<codecave:ExpHP.anm-buffers.game-data> // 037204 // 8B12 // 83C208 // B900180000 // 8B450C // 49 // 7814 // 3906 // 7404 // 01D6 // EBF5 // 89F0 // BA<codecave:ExpHP.anm-buffers.game-data> // 2B4204 // EB02 // 31C0 // 5F5E89EC5D // C20800",
        "ExpHP.anm-buffers.search-inactive-batch-for-id": "5589E55657 // 8B5508 // 8B4204 // 3D00180000 // 7441 // 8D7A0C // 8DB20C600000 // 8D7608 // BA<codecave:ExpHP.anm-buffers.game-data> // 8B12 // 83C208 // B900180000 // 8B450C // 49 // 7820 // 3907 // 7407 // 83C704 // 01D6 // EBF2 // 89F0 // BA<codecave:ExpHP.anm-buffers.game-data> // 034204 // 8B00 // 3B450C // 7504 // 89F0 // EB02 // 31C0 // 5F5E89EC5D // C20800"
    }
}