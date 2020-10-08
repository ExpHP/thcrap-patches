#!/usr/bin/env python3

import re
import sys

META_CHAR = '/'

"""
  This script provides the following features that help simplify the development of thcrap binhack json files:

=== AUTOMATIC CODECAVES ===

  Under the binhacks: mapping, you may use the field 'codecave:' instead of 'code:'.  When 'codecave:' is used, a codecave will be automatically generated in addition to the binhack, and the binhack will become a jump to that codecave.  This can be used to replace any piece of code (5 bytes or longer) with longer code that wouldn't normally fit.

  You may also use 'call-codecave:'.  In this case, the binhack becomes a call instead of a jump.  The rest of the original code (as determined from the length of the 'expected:' field) is nopped out.  Its primary purpose is to help compress many binhacks with identical bodies (by putting a list of addresses in 'addr:', a vanilla thcrap feature), which is not typically possible in a regular cave that jumps at the end.  If you are not writing such a binhack then usage of 'call-codecave:' is discouraged; despite the apparent convenience of replacing a jump with a ret, 'call-codecave' brings with it the unavoidable cost that it changes the stack pointer, which is easy to forget when overused (and can come back to bite you when copying instructions from the original code).

  You can explicitly specify the 'code:' as well.  Use '[CAVE]' or '<CAVE>' to refer to the autogenerated codecave.

=== CONDITIONAL CODE ===

  There are some special directives that enable conditional code. This is used to allow a single .yaml file to be used in the production of many game-specific .js files, in cases where this may reduce the burden of maintenence.  There are:

Conditional sequence items:

    - 1
    - /item-if(foo): 2
    - 3

  The above is equivalent to [1, 2, 3] when --cfg foo is supplied, and [1, 3] otherwise.

Conditional submappings:

    foo: 1
    /fields-if(foo):
      bar: 2
      baz: 3

  The above is equivalent to {foo: 1, bar: 2, baz: 3} when --cfg foo is supplied, and {foo: 1} otherwise.

Value switches:

    thing:
      /value-if(foo): 1
      /value-if(bar): 2

  The above is equivalent to {thing: 1} if --cfg foo is supplied, {thing: 2} if --cfg bar is supplied, and produces an error if both or neither is supplied.

Logical expressions:

  All of the conditional code directives simple logical expressions with 'any', 'all', and 'not' operators:

    - /item-if(all(foo, not(bar)))

  Because --cfg is pretty much exclusively used with game strings at this point, there is a Touhou-specific syntax extension that '..' can be used to indicate a doubly-inclusive range.  That is, th09..th10 is equivalent to any(th09, th095, th10).  The game format must follow the naming convention that is used by all exe and dat files since th08.
"""

def main():
    import argparse
    import json
    from ruamel.yaml import YAML
    from functools import reduce
    yaml = YAML(typ='safe')

    parser = argparse.ArgumentParser(description='Merge and format yaml files into thcrap JSON files for easy, breezy, beautiful binhacks')
    parser.add_argument('INPUT', nargs='+', help='yaml files')
    parser.add_argument('--cfg', action='append', default=[], help='supply a conditional code filter. Syntax is documented in the script')
    args = parser.parse_args()

    def load_file(fname):
        with open(fname) as f:
            return yaml.load(f)

    y = reduce(merge_json, [load_file(fname) for fname in args.INPUT])

    y = resolve_conditional_code(y, args.cfg)

    process_local_caves(y)
    if 'binhacks' in y:
        for name, binhack in y['binhacks'].items():
            if 'address' in binhack:
                die(f'binhack {repr(name)} should have "addr", not "address"!')
            if 'code' in binhack:
                binhack['code'] = concat_code_sequences(binhack['code'])
            if 'expected' in binhack:
                binhack['expected'] = concat_code_sequences(binhack['expected'])
    if 'codecaves' in y:
        for cave_key in y['codecaves']:
            if cave_key != 'protection':
                y['codecaves'][cave_key] = concat_code_sequences(y['codecaves'][cave_key])

    # take advantage of python 3.7's insertion-order dicts to put this comment at the top
    out = {'COMMENT': 'This file is autogenerated.  Please do not edit it directly.  See the convert-yaml.py script.'}
    out.update(y)

    json.dump(out, sys.stdout, indent=4)
    print() # ensure trailing newline

def merge_json(a, b, path=None):
    if path is None:
        path = []

    if isinstance(a, dict) or isinstance(b, dict):
        out = {}
        if not (isinstance(a, dict) and isinstance(b, dict)):
            die(f'at key {repr(path)}: cannot merge object with non-object')
        for key in a:
            if key in b:
                out[key] = merge_json(a[key], b[key])
            else:
                out[key] = a[key]

        for key in b:
            if key not in a:
                out[key] = b[key]

        return out
    else:
        return b

def process_local_caves(json):
    binhacks = json.get('binhacks', {})
    if 'codecaves' not in json:
        json['codecaves'] = {}
    codecaves = json['codecaves']

    for key, binhack in binhacks.items():
        if 'codecave' not in binhack and 'call-codecave' not in binhack:
            continue
        if 'codecave' in binhack and 'call-codecave' in binhack:
            die("cannot have both 'codecave' and 'call-codecave")
        is_call = 'call-codecave' in binhack

        # move to codecaves
        cave_asm = binhack.pop('codecave', None) or binhack.pop('call-codecave')
        cave_name = f'of({key})'
        codecaves[cave_name] = cave_asm

        if 'code' in binhack and isinstance(binhack['code'], str):
            binhack['code'] = [binhack['code']]
        elif 'code' not in binhack:
            # jmp [cave] followed by int3's,  or call [cave] followed by nops
            expected_len = get_code_len(binhack['expected'])
            if expected_len < 10:
                die(f'in {repr(key)}: expected code too short to insert jump')

            filler = '90' if is_call else 'CC'
            opcode = 'E8' if is_call else 'E9'
            binhack['code'] = [f'{opcode} [CAVE]']
            if expected_len > 10:
                binhack['code'].append(filler * (expected_len // 2 - 5))

        for i in range(len(binhack['code'])):
            binhack['code'][i] = binhack['code'][i].replace('[CAVE]', f'[codecave:{cave_name}]').replace('<CAVE>', f'<codecave:{cave_name}>')

    for key, binhack in binhacks.items():
        if 'expected' in binhack:
            if get_code_len(binhack['expected']) != get_code_len(binhack['code']):
                die(f'in {repr(key)}: expected/actual code length mismatch')

def get_code_len(code):
    """ Get number of hexadecimal units in code. (2x number of bytes) """
    code = concat_code_sequences(code)
    code = re.sub(r'\[[^\]]+\]', '00000000', code)
    code = re.sub(r'<[^>]+>', '00000000', code)
    code = ''.join([c for c in code if c in '0123456789abcdefABCDEF'])
    return len(code)

def concat_code_sequences(val):
    """ Post-process a code field into a string, allowing it to be initially
    written as a sequence of strings. (which provides room to write comments) """
    if isinstance(val, list):
        return ' // '.join(x.strip() for x in val)
    return val

#==============================================================================
# Conditional code.

def resolve_conditional_code(d, defs):
    # /item-if
    if isinstance(d, list):
        out = []
        for item in d:
            if isinstance(item, dict):
                for key in item:
                    cond_text = get_inner_for(key, f'{META_CHAR}item-if(', ')')
                    if cond_text is not None:
                        if len(item) != 1:
                            die(f'{META_CHAR}item-if can only be used in singleton mappings')
                        if check_conditional(cond_text, defs):
                            out.append(resolve_conditional_code(item[key], defs))
                        break
                else:
                    # no /item-if found
                    out.append(resolve_conditional_code(item, defs))
            else:
                out.append(resolve_conditional_code(item, defs))
        return out

    if isinstance(d, dict):
        # /value-if
        if any(get_inner_for(key, f'{META_CHAR}value-if(', ')') for key in d):
            if not all(get_inner_for(key, f'{META_CHAR}value-if(', ')') for key in d):
                die(f'cannot mix {META_CHAR}value-if and non-{META_CHAR}value-if in a mapping')

            applicable_entries = [
                d[key] for key in d if check_conditional(get_inner_for(key, f'{META_CHAR}value-if(', ')'), defs)
            ]
            if not applicable_entries:
                die(f'no applicable value for for {repr(d)}')
            if len(applicable_entries) > 1:
                die(f'multiple applicable values for {repr(d)}')
            return resolve_conditional_code(applicable_entries[0], defs)

        # /fields-if
        while any(get_inner_for(key, f'{META_CHAR}fields-if(', ')') is not None for key in d):
            new_d = {}
            for key in d:
                cond_text = get_inner_for(key, f'{META_CHAR}fields-if(', ')')
                if cond_text is not None:
                    if check_conditional(cond_text, defs):
                        for sub_key in d[key]:
                            if sub_key in new_d:
                                die(f'conflicting values for field {repr(sub_key)}')
                            new_d[sub_key] = d[key][sub_key]
                else:
                    new_d[key] = d[key]
            d = new_d

        return { k: resolve_conditional_code(v, defs) for (k, v) in d.items()}

    else:
        return d

IDENT_RE = re.compile(r'[_a-zA-Z][-_a-zA-Z0-9]*$')
TH_IDENT_RE = re.compile(r'th[012][0-9][1-9]?$')
def check_conditional(expr_string, defs):
    inner = get_inner_for(expr_string, 'any(', ')')
    if inner is not None:
        return any(check_conditional(part.strip(), defs) for part in inner.split(','))

    inner = get_inner_for(expr_string, 'all(', ')')
    if inner is not None:
        return all(check_conditional(part.strip(), defs) for part in inner.split(','))

    inner = get_inner_for(expr_string, 'not(', ')')
    if inner is not None:
        return not check_conditional(inner.strip(), defs)

    # !! Begin touhou-specific extension
    if '..' in expr_string:
        mingame, maxgame = expr_string.split('..', 1)
        if not TH_IDENT_RE.match(mingame): die(f'range syntax is only for game numbers, not {repr(mingame)}')
        if not TH_IDENT_RE.match(maxgame): die(f'range syntax is only for game numbers, not {repr(maxgame)}')

        # game numbers are lexically sorted so we can just do string comparisons
        return any(mingame <= x <= maxgame for x in defs if TH_IDENT_RE.match(x))
    # !! End touhou-specific extension

    # read an atom
    if not IDENT_RE.match(expr_string):
        die(f'malformed expression: {repr(expr_string)}')
    return expr_string in defs

def get_inner_for(expr_string, prefix, suffix):
    if expr_string.startswith(prefix):
        if not expr_string.endswith(suffix):
            die(f'malformed expression: {repr(expr_string)}')
        return expr_string[len(prefix):-len(suffix)]
    return None

#==============================================================================

def die(*args):
    print('FATAL:', *args, file=sys.stderr)
    sys.exit(1)

if __name__ == '__main__':
    main()
