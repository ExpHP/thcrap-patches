{
    "COMMENT": "This file is autogenerated.  Please do not edit it directly.  See the convert-yaml.py script.",
    "codecaves": {
        "protection": "0x40",
        "ExpHP.anm-buffers.game-data": "08060000 // 44050000 // 9F034900",
        "of(ExpHP.anm-buffers.alloc)": "E8[codecave:ExpHP.anm-buffers.new-alloc-vm] // E800000000C704245C954800C3",
        "of(ExpHP.anm-buffers.dealloc)": "56 // E8[codecave:ExpHP.anm-buffers.new-dealloc-vm] // C3",
        "of(ExpHP.anm-buffers.search)": "50 // E8[codecave:ExpHP.anm-buffers.new-search] // E800000000C7042473854800C3"
    },
    "binhacks": {
        "ExpHP.anm-buffers.alloc": {
            "addr": "0x48954f",
            "expected": "6808060000",
            "code": "E9 [codecave:of(ExpHP.anm-buffers.alloc)]"
        },
        "ExpHP.anm-buffers.dealloc": {
            "addr": "0x44c97c",
            "expected": "e86f3a0400",
            "code": "E8 [codecave:of(ExpHP.anm-buffers.dealloc)]"
        },
        "ExpHP.anm-buffers.search": {
            "addr": "0x488534",
            "expected": "8b96dc000000",
            "code": "E9 [codecave:of(ExpHP.anm-buffers.search)] // CC"
        }
    }
}
