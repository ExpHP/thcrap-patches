{
    "COMMENT": "This file is autogenerated.  Please do not edit it directly.  See the convert-yaml.py script.",
    "codecaves": {
        "ExpHP.anm-buffers.state": "00000000",
        "ExpHP.anm-buffers.get-batches": "B8<codecave:ExpHP.anm-buffers.state> // 8B00 // 85C0 // 7514 // 6A0C // B8<codecave:ExpHP.anm-buffers.game-data> // FF5004 // 83C404 // B9<codecave:ExpHP.anm-buffers.state> // 8901 // C3",
        "ExpHP.anm-buffers.new-alloc-vm": "5589E55657 // E8[codecave:ExpHP.anm-buffers.get-batches] // 89C6 // 8B06 // 85C0 // 7516 // E8[codecave:ExpHP.anm-buffers.allocate-new-batch] // 89C1 // 8B4604 // 894108 // 894E04 // 810600080000 // FF0E // 56 // E8[codecave:ExpHP.anm-buffers.scroll-to-free-batch] // FF7604 // E8[codecave:ExpHP.anm-buffers.take-free-vm-from-batch] // 5F5E89EC5D // C3",
        "ExpHP.anm-buffers.allocate-new-batch": "5589E55657 // BF<codecave:ExpHP.anm-buffers.game-data> // 8B07 // 83C008 // 69C000080000 // 83C00C // 50 // FF5704 // 83C404 // 89C6 // C7460400080000 // C7460800000000 // C70600000000 // 8D460C // B900080000 // 49 // 7810 // C7400400000000 // 8930 // 0307 // 83C008 // EBED // 89F0 // 5F5E89EC5D // C3",
        "ExpHP.anm-buffers.scroll-to-free-batch": "8B4C2404 // 8B5108 // 8B4904 // 8B4104 // 85C0 // 7511 // 894A08 // 89CA // 8B4908 // C7420800000000 // EBE8 // 8B442404 // 895008 // 894804 // C20400",
        "ExpHP.anm-buffers.take-free-vm-from-batch": "5589E55657 // 8B7508 // BA<codecave:ExpHP.anm-buffers.game-data> // 8B0A // 83C108 // 0FAF0E // 8D4C0E0C // FF06 // 813E00080000 // 7C06 // C70600000000 // 8B4104 // 85C0 // 75DD // C7410401000000 // 8D4108 // 5F5E89EC5D // C20400",
        "ExpHP.anm-buffers.new-dealloc-vm": "8B442404 // 8D40F8 // C7400400000000 // 8B08 // FF4104 // E8[codecave:ExpHP.anm-buffers.get-batches] // FF00 // C3"
    }
}