#!/usr/bin/env python3

# Used by list-asm to work around nasm's limited gutter width.
#
# Merges instances of the following:
#
#    - "C705704C4700020000" # mov    dword [CURRENT_LIVES], 2
#    - "00                " #
#
# into the following:
#
#    - "C705704C470002000000" # mov    dword [CURRENT_LIVES], 2

import sys
import re

ASSEMBLY_LINE_RE = re.compile(r'^\s+- "[0-9a-fA-F ]+"')

def main():
    import argparse
    argparse.ArgumentParser(description=
        "Used by list-asm to work around nasm's limited gutter width. "
        "Uses STDIN/STDOUT."
    ).parse_args()

    prev_line = None
    for line in sys.stdin:
        if ASSEMBLY_LINE_RE.match(line):
            if line.strip().endswith('#'):
                extra_bytes = line.split('"')[1].strip()
                before_end_quote = '"'.join(prev_line.split('"')[:2])
                after_end_quote  = '"'.join(prev_line.split('"')[2:])
                prev_line = before_end_quote + extra_bytes + '"' + after_end_quote
            else:
                if prev_line is not None:
                    print(prev_line, end='')
                prev_line = line
        else:
            if prev_line is not None:
                print(prev_line, end='')
                prev_line = None
            print(line, end='')

    if prev_line is not None:
        print(prev_line, end='')

if __name__ == '__main__':
    main()
