#!/usr/bin/env python3

# Implements the final steps of list-asm, which are too tough to do in shell scripting.
# 
# Originally written to merge instances of the following to work around nasm's limited gutter width:
#
#    - "C705704C4700020000" # mov    dword [CURRENT_LIVES], 2
#    - "00                " #
#
# into the following:
#
#    - "C705704C470002000000" # mov    dword [CURRENT_LIVES], 2
#
# Over time, some special comment directives were added to help fully automate the conversion of codecaves,
# making it more straightforward to paste the output into yaml files (and even allowing some files to be
# fully Makefile-automated if they only contain codecaves):
#
# A line with DELETE in the comment is eliminated from the output.
#
# A line with REWRITE: in the comment replaces the last 4 bytes of a command with a string
# (and there is REWRITE-n to replace earlier bytes):
#
#    - "001122334455"  # blah blah  REWRITE: <blah>
#    - "001122334455"  # blah blah  REWRITE-1: [bloo]
#
# becomes:
#
#    - "0011<blah>"  # blah blah
#    - "00[bloo]55"  # blah blah
#
# lines with HEADER: in the comment are dedented and turned into a block-style yaml key with the text that
# follows, generally used on the function name of a codecave.
#
#      # get_stuff:  ; HEADER: foobar
#      - "001122334455"
#
# becomes:
#
#    foobar:
#      - "001122334455"
#
# There are also AUTO and AUTO_PREFIX to help automate my naming convention.
# AUTO_PREFIX defines a prefix for all codecave names in the file.
# The string 'AUTO', when it appears as a whole word inside HEADER or REPLACE, will be replaced with
# a kebab-case form of the last identifier in the assembly line, prefixed by the AUTO_PREFIX.
#
#      # AUTO_PREFIX: ExpHP.bullet-cap.
#      # some_function:  ; HEADER: auto
#      - "001122334455"  # mov eax, chucky_cheez  ; REWRITE: <codecave:AUTO>
#
# becomes:
#
#    ExpHP.bullet-cap.some-function:
#      - "0011<codecave:ExpHP.bullet-cap.chucky-cheez>"  # mov eax, chucky_cheez
#

import sys
import re

ASSEMBLY_LINE_RE = re.compile(r'^\s+- "[0-9a-fA-F ]+"')
REWRITE_RE = re.compile(r'\bREWRITE(-[0-9]+)?:(.+)$')
HEADER_RE = re.compile(r'\bHEADER:(.+)$')
AUTO_PREFIX_RE = re.compile(r'\bAUTO_PREFIX:(.+)$')
IDENTIFIER_RE = re.compile(r'\b[a-zA-Z_][a-zA-Z0-9_]*\b')
AUTO_RE = re.compile(r'\bAUTO\b')

def main():
    import argparse
    argparse.ArgumentParser(description=
        "Used by list-asm to work around nasm's limited gutter width and more. "
        "Uses STDIN/STDOUT."
    ).parse_args()

    lines = list(join_long_lines(sys.stdin))
    if any('codecave:auto' in line for line in lines):
        print('!! Warning: codecave:auto (lower) is probably a typo!', file=sys.stderr)
    rept_lines = [line for line in lines if '<rept>' in line]
    if rept_lines:
        print('!! Warning: found <rept>, probably left behind by incomplete istruc', file=sys.stderr)
        print(f'!! Line: {repr(line)}', file=sys.stderr)
    auto_prefix = find_auto_prefix(lines)
    lines = list(handle_rewrites(lines, auto_prefix))
    lines = list(handle_headers(lines, auto_prefix))
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

def handle_rewrites(lines, auto_prefix):
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
        rewrite_text = possibly_substitute_auto(rewrite_text, line, auto_prefix)
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

def handle_headers(lines, auto_prefix):
    for line in lines:
        pre_comment, comment = split_asm_comment(line)
        if not comment:
            yield line
            continue

        match = HEADER_RE.search(comment)
        if not match:
            yield line
            continue

        header_text = match.group(1)
        header_text = possibly_substitute_auto(header_text, line, auto_prefix)
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

def find_auto_prefix(lines):
    comments = [line.split('#')[1] for line in lines if '#' in line]
    matches = [AUTO_PREFIX_RE.search(comment) for comment in comments]
    matches = [match for match in matches if match]
    if len(matches) == 0:
        return ''
    if len(matches) == 1:
        return matches[0].group(1).strip()
    raise RuntimeError('multiple AUTO_PREFIX: found')

def possibly_substitute_auto(text, full_line, auto_prefix):
    match = AUTO_RE.search(text)
    if not match:
        return text
    return text[:match.start()] + get_auto_string(full_line, auto_prefix) + text[match.end():]

def get_auto_string(line, auto_prefix):
    """
    Get substitution text for AUTO when it appears in a directive.

    This is the contents of AUTO_PREFIX followed by the last identifier in the asm line converted to kebab case.
    E.g. with AUTO_PREFIX of 'ExpHP.bullet-cap.' and an identifier of 'get_stuff', this would return 'ExpHP.bullet-cap.get-stuff'.
    """
    if '#' not in line:
        raise RuntimeError("can't find asm line")
    pre_asm_comment, _ = split_asm_comment(line)
    _, asm_line = pre_asm_comment.split('#', 1)
    identifiers = IDENTIFIER_RE.findall(asm_line)
    if not identifiers:
        raise RuntimeError("can't find identifier for AUTO")
    return auto_prefix + identifiers[-1].replace('_', '-')

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
