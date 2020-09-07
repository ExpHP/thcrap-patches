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
#
# Also looks for REWRITE comments which replace the last 4 bytes of a command
# (or REWRITE-n which replace earlier bytes):
#
#    - "001122334455"  # blah blah  REWRITE: <blah>
#    - "001122334455"  # blah blah  REWRITE-1: [bloo]
#
# becomes:
#
#    - "0011<blah>"  # blah blah
#    - "00[bloo]55"  # blah blah

import sys
import re

ASSEMBLY_LINE_RE = re.compile(r'^\s+- "[0-9a-fA-F ]+"')
REWRITE_RE = re.compile(r'\bREWRITE(-[0-9]+)?:(.+)$')
HEADER_RE = re.compile(r'\bHEADER:(.+)$')

def main():
    import argparse
    argparse.ArgumentParser(description=
        "Used by list-asm to work around nasm's limited gutter width and more. "
        "Uses STDIN/STDOUT."
    ).parse_args()

    lines = list(join_long_lines(sys.stdin))
    lines = list(handle_rewrites(lines))
    lines = list(handle_headers(lines))
    lines = list(handle_deletes(lines))
    for line in lines:
        print(line, end='')

def join_long_lines(lines):
    prev_line = None
    for line in lines:
        if ASSEMBLY_LINE_RE.match(line):
            if line.strip().endswith('#'):
                extra_bytes = line.split('"')[1].strip()
                before_end_quote = '"'.join(prev_line.split('"')[:2])
                after_end_quote  = '"'.join(prev_line.split('"')[2:])
                prev_line = before_end_quote + extra_bytes + '"' + after_end_quote
            else:
                if prev_line is not None:
                    yield prev_line
                prev_line = line
        else:
            if prev_line is not None:
                yield prev_line
                prev_line = None
            yield line
    if prev_line is not None:
        yield prev_line

def handle_rewrites(lines):
    for line in lines:
        pre_comment, comment = split_asm_comment(line)
        if not comment:
            yield line
            continue

        match = REWRITE_RE.search(comment)
        if not match:
            yield line
            continue

        offset_from_end = match.group(1) or 0
        rewrite_text = match.group(2).strip()
        # remove from comment
        comment = comment[:match.start()].rstrip()

        # Find the bytes to replace
        if '"' not in pre_comment:
            # no assembly; line was probably commented out of the original
            yield line
            continue

        before_str, in_str, after_str = pre_comment.split('"', 2)
        in_str = in_str.replace(' ', '') # spaces make it harder to find the right chars
        in_str = in_str.replace('[', '').replace(']', '') # nasm puts brackets sometimes
        assert all(c in '0123456789abcdefABCDEF' for c in in_str), in_str
        assert len(in_str) % 2 == 0
        n_bytes = len(in_str) // 2
        if offset_from_end > n_bytes:
            print("!! error: bad rewrite offset", file=sys.stderr)
            print("!! offending line:", file=sys.stderr)
            print("   " + line, end='', file=sys.stderr)
            sys.exit(1)

        remove_from = len(in_str) - 2*offset_from_end - 8
        remove_to   = remove_from + 8
        in_str = in_str[:remove_from] + rewrite_text + in_str[remove_to:]

        pre_comment = '"'.join([before_str, in_str, after_str])
        yield rejoin_asm_comment(pre_comment, comment) + '\n'

def handle_headers(lines):
    for line in lines:
        pre_comment, comment = split_asm_comment(line)
        if not comment:
            yield line
            continue

        match = HEADER_RE.search(comment)
        import sys
        if not match:
            yield line
            continue

        header_text = match.group(1)
        # remove from comment
        comment = comment[:match.start()].rstrip()

        # dedent
        indent = len(pre_comment) - len(pre_comment.lstrip(' '))
        assert indent >= 2
        indent -= 2

        # replace line content with given header as mapping key
        line = ' ' * indent + header_text.strip() + ':'
        if comment.strip():
            # (sep='#' because we destroyed the original hash and therefore need a new one)
            line = rejoin_asm_comment(line, comment, sep='#')

        yield line + '\n'

def handle_deletes(lines):
    for line in lines:
        if line.rstrip().endswith(' DELETE'):
            continue

        yield line

def split_asm_comment(line):
    """
    Given one of the yaml lines, split out the comment from the ASM (removing the newline).

    Essentially, this splits at the first ';' after the first '#'.
    If this cannot be found, the second element returned is None.
    """
    if '#' not in line:
        return line, None

    pre_comment, comment = line.split('#', 1)
    if ';' not in comment:
        return line, None

    mnemonic, comment = comment.split(';', 1)
    pre_comment += '#' + mnemonic
    return pre_comment, comment

def rejoin_asm_comment(pre_comment, comment, sep=';'):
    """
    Inverse of split_asm_comment, which also leaves behind no trailing ';'.
    
    Does NOT add back the newline.
    """
    if comment is None:
        return pre_comment
    if pre_comment.strip() and comment.strip() and not pre_comment.endswith(' '):
        pre_comment += ' '
    return (pre_comment + sep + comment).rstrip().rstrip(';').rstrip()

if __name__ == '__main__':
    main()
