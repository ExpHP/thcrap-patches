{
    "COMMENT": "This file is autogenerated.  Please do not edit it directly.  See the convert-yaml.py script.",
    "binhacks": {
        "ExpHP.anm-buffers.alloc": {
            "addr": "0x41939c",
            "expected": "e8d0480700",
            "code": "E9 [codecave:of(ExpHP.anm-buffers.alloc)]"
        },
        "ExpHP.anm-buffers.dealloc": {
            "addr": "0x488753",
            "expected": "e849550000",
            "code": "E8 [codecave:of(ExpHP.anm-buffers.dealloc)]"
        },
        "ExpHP.anm-buffers.search": {
            "addr": "0x488b5d",
            "expected": "8b8ef0060000",
            "code": "E9 [codecave:of(ExpHP.anm-buffers.search)] // CC"
        }
    },
    "codecaves": {
        "ExpHP.anm-buffers.game-data": "0c0600005005000071dc4800",
        "of(ExpHP.anm-buffers.alloc)": "e8[codecave:ExpHP.anm-buffers.new-alloc-vm]e800000000c70424a1934100c3",
        "of(ExpHP.anm-buffers.dealloc)": "56e8[codecave:ExpHP.anm-buffers.new-dealloc-vm]c3",
        "of(ExpHP.anm-buffers.search)": "50e8[codecave:ExpHP.anm-buffers.new-search]e800000000c70424aa8b4800c3"
    }
}
