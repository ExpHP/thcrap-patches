#!/usr/bin/env python3

__doc__ = """
Helper library for "binhack scripts", which are automatible ways of making binhacks.
"""

import collections
import keystone
import inspect
import random
import sys
import re
import struct
import os.path
import typing as tp

# Debug flag. Set this to True to make the hex strings more similar to what they were
# prior to the introduction of python scripts.  This can assist in the use of
# 'git diff --word-diff-regex=.' to debug problems introduced in the python code.
#
# This should always be false in VCS.
MINIMIZE_HEX_DIFF = False

class LocatableSymbolResolver:
    """
    An ``OPT_SYM_RESOLVER`` for keystone designed to help identify the byte offset into the
    assembled output where a symbol appears (possibly relative to the instruction pointer).

    Basically, it can be used to generate a number of single-use symbols that should each
    appear *at most once* in the input assembly. Then, it locates these symbols by assembling
    an asm string multiple times while changing the symbol addresses.
    """
    def __init__(self):
        self._random_prefix = _random_symbol()
        self._next_suffix = 0
        self._values = {}

    def gen_symbol(self, init_value=0x12345678):
        """ Generate a new single-use symbol. """
        symbol = f'_{self._random_prefix}_{len(self._values)}'
        self._values[symbol] = init_value
        return symbol

    def symbols(self):
        """ Get all symbols generated by this object. """
        return [f'_{self._random_prefix}_{i}' for i in range(self._next_suffix)]

    def toggle_bits(self, symbol):
        self._values[symbol] = 0xffffffff - self._values[symbol]

    def assemble_and_locate_symbols(self, keystone, asm):
        """
        Assemble a string using the given ``keystone``, and also identify the byte offset of each symbol.
        Returns ``(bytes, {symbol: (start, stop)})``.  ``(start, stop)`` are semi-inclusive ranges.
        Symbols not present in the asm string will not be in the returned dict.

        The assembly and initial value of each symbol must be such that flipping the bits of each symbol
        modifies exactly four (4) contiguous bytes of the output. In the output bytes, the value of these
        four bytes will be arbitrary.

        Note: This has the side-effect of setting ``keystone.sym_resolver``.
        """
        keystone.sym_resolver = self
        original_output = keystone.asm(asm)[0]
        if original_output is None:
            raise RuntimeError(f"keystone 'successfully' returned None.  Typically this happens if you write 'dword' instead of 'dword ptr'.")

        locations = {}
        for symbol in self._values:
            self.toggle_bits(symbol)
            flipped_output = keystone.asm(asm)[0]
            loc = self.__locate_flipped_dword(flipped_output, original_output)
            if loc is not None:
                locations[symbol] = loc
            self.toggle_bits(symbol)

        return (original_output, locations)

    @staticmethod
    def __locate_flipped_dword(a, b):
        if len(a) != len(b):
            raise RuntimeError('output assembly length changed!')
        if a == b:
            return None  # symbol not used

        for start in range(len(a)):
            if a[start] != b[start]:
                break

        for stop in range(start + 1, len(a)):
            if a[stop] == b[stop]:
                break
        else: stop = len(a)

        if a[stop:] != b[stop:]:
            raise RuntimeError(f'more than one slice of bytes changed! (symbol may have been reused?)')

        return (start, stop)

    def __call__(self, symbol, output_ptr):
        symbol = symbol.decode('ascii')
        if symbol in self._values:
            output_ptr[0] = self._values[symbol]
            return True
        else:
            return False

class CodeHelper:
    """ A helper object for writing assembly strings.

    The methods on this type can be used to generate some common patterns in binhacks
    (like an absolute jump), and can be used to produce things like '[codecave:blah]'
    in the output string.

    **You are not intended to construct this type on your own.** Rather, you should
    give a 1-arg closure as an argument to ``ThcrapGen.asm``.  This is so that the
    insertion of the '[codecave:...]' strings may be done as a post-processing step.
    """
    def __init__(self, auto_prefix=''):
        self.auto_prefix = auto_prefix
        self.resolver = LocatableSymbolResolver()
        self.replacements = {}

    def rel_auto(self, name):
        """ Generate a single-use symbol that will become ``"[codecave:...]"`` (with the ``auto_prefix``)
        in the final output of ``ThcrapGen.asm``. """
        return self._gen_symbol(_thcrap_codecave_ref(self.auto_prefix + name, kind='rel'))
    def abs_auto(self, name):
        """ Generate a single-use symbol that will become ``"<codecave:...>"`` (with the ``auto_prefix``)
        in the final output of ``ThcrapGen.asm``. """
        return self._gen_symbol(_thcrap_codecave_ref(self.auto_prefix + name, kind='abs'))
    def rel_global(self, name):
        """ Generate a single-use symbol that will become ``"[codecave:...]"`` (WITHOUT the ``auto_prefix``)
        in the final output of ``ThcrapGen.asm``. """
        return self._gen_symbol(_thcrap_codecave_ref(name, kind='rel'))
    def abs_global(self, name):
        """ Generate a single-use symbol that will become ``"<codecave:...>"`` (WITHOUT the ``auto_prefix``)
        in the final output of ``ThcrapGen.asm``. """
        return self._gen_symbol(_thcrap_codecave_ref(name, kind='abs'))
    def jmp(self, addr):
        """ Generate asm text for an unconditional jump to an absolute address, without any side-effects. """
        symbol = _random_symbol()
        return '''
            call {}
        {}:
            mov dword ptr [esp], {:#x}
            ret
        '''.format(symbol, symbol, addr)  # NOTE: .format() as workaround for a bug in Github's highlighting of {:#x} in f strings
    def multipush(self, *exprs):
        """ Generate asm text for pushes of multiple dword-sized things. """
        return '; '.join(f'push {e}' for e in exprs)
    def multipop(self, *exprs):
        """ Generate asm text for pops of multiple dword-sized things, in reverse order. """
        return '; '.join(f'pop {e}' for e in exprs[::-1])

    def _gen_symbol(self, replacement):
        """ Generate a symbol whose affected bytes will be substituted with the given,
        arbitrary text in the final output of ``ThcrapGen.asm``. """
        symbol = self.resolver.gen_symbol()
        self.replacements[symbol] = replacement
        return symbol

    def _asm_to_thcrap_hex(self, asm):
        _check_asm_for_footguns(asm)
        ks = keystone.Ks(keystone.KS_ARCH_X86, keystone.KS_MODE_32)
        bits, locations = self.resolver.assemble_and_locate_symbols(ks, asm)

        prev_stop = 0
        hex_parts = []
        # iterate locations in reverse
        sorted_locations = sorted(locations.items(), key=lambda tup: tup[1][0])
        for symbol, (start, stop) in reversed(sorted_locations):
            replacement = self.replacements[symbol]
            if stop - start != 4:
                raise RuntimeError(f'symbol {symbol} ({replacement}) occupies bytes {start}:{stop} which is not a dword!')

            # add untouched hex chars
            hex_parts.append(bytes_to_hex(bits[prev_stop:start]))
            # add thcrap [] or <> ref
            hex_parts.append(replacement)
            prev_stop = stop
        # untouched hex chars after the final reference
        hex_parts.append(bytes_to_hex(bits[prev_stop:]))
        return ''.join(hex_parts)

def _random_symbol():
    return f'_{random.randrange(2**64):016x}'

def bytes_to_hex(bits):
    """ Convert bytes to a hex string. """
    if MINIMIZE_HEX_DIFF:
        return ''.join(f'{x:02X}' for x in bits)
    else:
        return ''.join(f'{x:02x}' for x in bits)

def hex_code_len(code):
    """ Get number of bytes in thcrap hex code. """
    if "<option:" in code:
        raise ValueError(f'cannot determine byte length of options')
    code = re.sub(r'\[[^\]]+\]', '00000000', code)
    code = re.sub(r'<[^>]+>', '00000000', code)
    code = ''.join([c for c in code if c in '0123456789abcdefABCDEF'])
    assert len(code) % 2 == 0
    return len(code) // 2

# Keystone fails in an unusual way ("successfully" returning None) without the ptr keyword.
# (Ironically, checking github, I've only found an issue reporting the OPPOSITE effect, where
#   it returns None if you DO include 'ptr'!)
SIZE_WITHOUT_PTR_REGEX = re.compile(r'\b(byte|(|d|q|xmm|ymm|zmm)word) +(?!ptr)', re.IGNORECASE)
# Keystone has 0-prefix octal.  Ugh.
OCTAL_REGEX = re.compile(r'\b0[0-9]+')
# Issue: https://github.com/keystone-engine/keystone/issues/481
# Basically, decimal numbers are dangerous due to a bug in keystone that arbitrarily
# changes the default radix to 16.  Always format numbers using '{:#x}'.
POSSIBLY_IMPLICIT_HEX_REGEX = re.compile(r'\b[1-9][0-9]+')
def _check_asm_for_footguns(asm):
    for line in asm.splitlines():
        if '#' in line:
            line = line[:line.index('#')]
        if SIZE_WITHOUT_PTR_REGEX.search(line):
            raise ValueError("detected size operand without 'ptr' keyword!")
        m = OCTAL_REGEX.search(line)
        if m:
            raise ValueError(f"detected integer with leading zero: {m.group(0)}")
        m = POSSIBLY_IMPLICIT_HEX_REGEX.search(line)
        if m:
            raise ValueError(f"detected decimal integer: {m.group(0)}  (see keystone issue #481)")

class DataHelper:
    """ A helper object for writing read-only datacaves.
    
    Similar to ``AsmContext``, you can get one of these by providing a 1-argument
    closure to ``ThcrapGen.data``.  You can also just create one of your own.
    """
    def __init__(self, auto_prefix=''):
        self.auto_prefix = auto_prefix

    def i64(self, x): return Int64(x)
    def i32(self, x): return Int32(x)
    def i16(self, x): return Int16(x)
    def i8(self, x): return Int8(x)
    def f64(self, x): return Float64(x)
    def f32(self, x): return Float32(x)
    i64.__doc__ = "Create an Int64. Provided for convenience."
    i32.__doc__ = "Create an Int32. Provided for convenience."
    i16.__doc__ = "Create an Int16. Provided for convenience."
    i8.__doc__ = "Create an Int8. Provided for convenience."
    f64.__doc__ = "Create a Float64. Provided for convenience."
    f32.__doc__ = "Create a Float32. Provided for convenience."

    def rel_auto(self, name):
        """ Generate the string ``"[codecave:...]"`` (with the ``auto_prefix``), which
        will be preserved in the final output of ``ThcrapGen.data``. """
        return _thcrap_codecave_ref(self.auto_prefix + name, kind='rel')
    def abs_auto(self, name):
        """ Generate the string ``"<codecave:...>"`` (with the ``auto_prefix``), which
        will be preserved in the final output of ``ThcrapGen.data``. """
        return _thcrap_codecave_ref(self.auto_prefix + name, kind='abs')
    def rel_global(self, name):
        """ Generate the string ``"[codecave:...]"`` (WITHOUT the ``auto_prefix``), which
        will be preserved in the final output of ``ThcrapGen.data``. """
        return _thcrap_codecave_ref(name, kind='rel')
    def abs_global(self, name):
        """ Generate the string ``"<codecave:...>"`` (WITHOUT the ``auto_prefix``), which
        will be preserved in the final output of ``ThcrapGen.data``. """
        return _thcrap_codecave_ref(name, kind='abs')

def _thcrap_codecave_ref(name, kind):
    if kind == 'abs':
        return f'<codecave:{name}>'
    elif kind == 'rel':
        return f'[codecave:{name}]'
    else:
        raise ValueError(f'bad kind: {repr(kind)}')

class Binhack(dict):
    """ dict for the yaml of a single binhack, with convenience methods. """
    def at(self, addr: tp.Union[int, tp.Iterable[int]]):
        """ Adds an address (or iterable of addresses) to 'addr'. """
        if isinstance(addr, collections.Iterable):
            for x in addr: self.at(x)
            return

        if 'addr' not in self:
            self['addr'] = []
        if isinstance(self['addr'], (str, int)):
            self['addr'] = [self['addr']]

        self['addr'].append(addr)

class BinhackCollection:
    def __init__(self, name, callback):
        self.callback = callback
        self.name = name
        self.binhacks = {}

    def _format_name(self, *args, **kw):
        # Get a tuple of the arguments as if they were all supplied positionally,
        # even if some were actually supplied via keyword.
        bound_args = inspect.signature(self.callback).bind(*args, **kw)
        bound_args.apply_defaults()
        args_as_positional = bound_args.args
        # Format the name like 'name(arg1, arg2)'
        argstr = ', '.join(map(str, args_as_positional))
        return f'{self.name}({argstr})'

    def at(self, addr, *args, **kw):
        """ Alternate way of writing ``self(*args, **kw).at(addr)`` that lets you put the address first. """
        self(*args, **kw).at(addr)

    def __call__(self, *args, **kw) -> Binhack:
        name_with_args = self._format_name(*args, **kw)
        if name_with_args not in self.binhacks:
            self.binhacks[name_with_args] = Binhack(self.callback(*args, **kw))
        return self.binhacks[name_with_args]

SizedInt = tp.Union['Int8', 'Int16', 'Int32', 'Int64']
SizedFloat = tp.Union['Float32', 'Float64']

BasicDataArg = tp.Union[int, str, float, bytes, SizedInt, SizedFloat]
DataArg = tp.Union[BasicDataArg, tp.Callable[[DataHelper], BasicDataArg], tp.Iterable[BasicDataArg]]

class ThcrapGen:
    auto_prefix: str
    binhack_collections: tp.Dict[str, BinhackCollection]
    single_binhacks: tp.Dict[str, Binhack]
    codecaves: tp.Dict[str, str]

    def __init__(self, auto_prefix=None):
        self.auto_prefix = auto_prefix
        self.binhack_collections = {}
        self.single_binhacks = {}
        self.codecaves = {}

    def binhack_collection(self, name, callback) -> BinhackCollection:
        """
        Define a new parameterized collection of binhacks.

        TODO: document.
        """
        name = (self.auto_prefix or '') + name
        if name in self.binhack_collections:
            raise KeyError(f'binhack collection {repr(name)} already exists')
        self.binhack_collections[name] = BinhackCollection(name=name, callback=callback)
        return self.binhack_collections[name]

    def binhack(self, name: str, binhack: Binhack) -> Binhack:
        """
        Define a single binhack, with corresponding yaml.

        Returns the new copy stored on self, wrapped with the ``Binhack`` subclass.
        """
        name = (self.auto_prefix or '') + name
        if name in self.single_binhacks:
            raise KeyError(f'binhack {repr(name)} already exists')
        self.single_binhacks[name] = Binhack(binhack)
        return self.single_binhacks[name]

    def codecave(self, name: str, hex: str):
        """
        Define a codecave, with its corresponding hex string.
        """
        name = (self.auto_prefix or '') + name
        if name in self.codecaves:
            raise KeyError(f'codecave {repr(name)} already exists')
        self.codecaves[name] = hex

    def asm(self, asm: tp.Union[str, tp.Callable[[CodeHelper], str]]):
        """
        Compile an x86 assembly string into hexadecimal for thcrap.

        >>> thc = ThcrapGen()
        >>> thc.asm('''
        ...   mov eax, 0x3
        ...   push eax
        ... ''')
        'b80300000050'

        If you need to do something that requires special thcrap syntax like calling a
        codecave, supply a function instead of a string.  The function will be given a
        single argument of type ``CodeHelper``, which has methods that will allow you to
        insert these symbols.

        >>> thc = ThcrapGen('my-namespace.')
        >>> thc.asm(lambda c: f'''
        ...   call {c.rel_auto('cool-cave')}
        ... ''')
        'e8[codecave:my-namespace.cool-cave]'
        """
        ctx = CodeHelper(auto_prefix=self.auto_prefix)
        if callable(asm):
            asm = asm(ctx)
        return ctx._asm_to_thcrap_hex(asm)

    def data(self, data: DataArg):
        """
        Compile a stream of data into hexadecimal for thcrap.

        * ``int`` will be encoded as a dword.
        * ``float`` will be encoded as a single-precision float.
        * ``bytes`` will be encoded as a stream of bytes.
        * ``Int16``, ``Float64`` etc. will be encoded as the appropriate size.
        * ``str`` will be left as-is.  This is meant for e.g. ``[codecave:...]`` refs.
        * A single-arg closure will be called with a ``DataHelper``, and then the
          result will be processed as the new input.
        * Any iterable types not listed above will have each item recursively encoded,
          and the outputs concatenated. This is particularly meant for namedtuples, such
          as those generated from ``struc`` defs by ``NasmDefs``.
        """
        if callable(data):
            data = data(DataHelper(auto_prefix=self.auto_prefix))
        if hasattr(data, 'to_hex'): # Int32, Int64, etc.
            return data.to_hex()
        if isinstance(data, int):
            return Int32(data).to_hex()
        if isinstance(data, float):
            return Float32(data).to_hex()
        if isinstance(data, str):
            return data
        if isinstance(data, bytes):
            return bytes_to_hex(data)
        if isinstance(data, collections.Iterable):
            if MINIMIZE_HEX_DIFF:
                return ' // '.join(map(self.data, data))
            else:
                return ''.join(map(self.data, data))
        raise TypeError(f'cannot hexify value of type {type(data)}')

    def cereal(self):
        """ Get the output JSON/YAML object. """
        cereal = {'binhacks': {}, 'codecaves': {}}
        for key, binhack in self.single_binhacks.items():
            cereal['binhacks'][key] = dict(binhack)
        for collection in self.binhack_collections.values():
            # note: the dict(v) is to strip the Binhack subclass for ruamel.yaml
            cereal['binhacks'].update([(k, dict(v)) for (k, v) in collection.binhacks.items()])
        
        # Make sure all addresses are hexadecimal strings
        def hexify_if_int(x):
            if isinstance(x, int): return '{:#x}'.format(x)  # NOTE: .format() to work around GitHub highlighting bug in f-strings
            else: return x

        for binhack in cereal['binhacks'].values():
            if 'addr' not in binhack: continue
            binhack['addr'] = hexify_if_int(binhack['addr'])
            if isinstance(binhack['addr'], list):
                binhack['addr'] = [hexify_if_int(x) for x in binhack['addr']]

        cereal['codecaves'].update(self.codecaves)

        # remove empty dicts
        if not cereal['binhacks']: del cereal['binhacks']
        if not cereal['codecaves']: del cereal['codecaves']
        return cereal

    def print(self, file=sys.stdout):
        from ruamel.yaml import YAML
        yaml = YAML(typ='rt')
        yaml.dump(self.cereal(), file)

def default_arg_parser(require_game=False):
    import argparse
    p = argparse.ArgumentParser(
        description='A binhack generating script.'
    )
    p.add_argument(
        '--game', required=require_game, type=Game,
        help='Game string.  Valid examples: th08, th08.v1.00d.  Invalid examples: 08, th8, TH08',
    )
    return p

GAME_BASE_RE = re.compile(r'th[012][0-9]{1,2}')
class Game:
    """
    Represents a Touhou game number, e.g. 'th08' or 'th08.v1.00d'.  Can be compared to plain
    python strings using equality and comparison operators.

    NOTE: Currently the version part is ignored.  alcostg is also not supported.
    """
    def __init__(self, game):
        if isinstance(game, Game):
            self.ordered_string = game.ordered_string
        else:
            base = game.split('.')[0]  # strip version part
            if not GAME_BASE_RE.match(base):
                raise ValueError(f'invalid game: {repr(base)}')
            # the pattern satisfied by base forms a lexical order
            self.ordered_string = base

    def __hash__(self): return self.ordered_string.__hash__()
    def __str__(self): return self.ordered_string
    def __repr__(self): return f'Game({repr(self.ordered_string)})'
    def __eq__(self, other): return self.ordered_string.__eq__(Game(other).ordered_string)
    def __ne__(self, other): return self.ordered_string.__ne__(Game(other).ordered_string)
    def __lt__(self, other): return self.ordered_string.__lt__(Game(other).ordered_string)
    def __le__(self, other): return self.ordered_string.__le__(Game(other).ordered_string)
    def __gt__(self, other): return self.ordered_string.__gt__(Game(other).ordered_string)
    def __ge__(self, other): return self.ordered_string.__ge__(Game(other).ordered_string)

def auto_radix_int(s):
    radix = 10
    if s[:2] in ['0x', '0X']:
        radix = 16
        s = s[2:]
    elif s[:2] in ['0b', '0B']:
        radix = 2
        s = s[2:]
    elif s[:2] in ['0d', '0D']:
        s = s[2:]
    return int(s, radix)

def _get_script_dir():
    """ Get the directory of the currently executing script. """
    import __main__
    if not hasattr(__main__, '__file__'):
        raise RuntimeError('This function cannot be used from the REPL!')
    return os.path.dirname(__main__.__file__)

RE_DEFINE_CONSTANT = re.compile('^ *%define +([_a-zA-Z0-9]+) +([^\n\r]+)$')
STRUC_BEGIN_RE = re.compile('^ *struc +([_a-zA-Z0-9]+) *')
STRUC_FIELD_RE = re.compile('^ *\.([_a-zA-Z0-9]+):')
STRUC_END_RE = re.compile('^ *endstruc')
class NasmDefs:
    """ Provides extremely basic parsing of nasm files for constants and type definitions.

    ``struc`` data structures will have corresponding ``collections.namedtuple``s created.
    ``%define``d constants will be attempted to be parsed as simple integers.

    All things will be generated as attributes on self.  I.e. use ``defs.MyType``, not
    ``defs['MyType']``.
    """
    def __init__(self, attrs):
        for k, v in attrs.items():
            setattr(self, k, v)

    @classmethod
    def from_file_rel(cls, relpath):
        """ Read a path relative to the path of the currently running script. """
        dir = _get_script_dir()
        with open(os.path.join(dir, relpath)) as f:
            return cls.from_lines(list(f))

    @classmethod
    def from_lines(cls, lines):
        struct_name = None
        attrs = {}
        for line in lines:
            # for each %define that defines a plain integer, add such a field to the object
            m = RE_DEFINE_CONSTANT.match(line)
            if m:
                try:
                    value = auto_radix_int(m.group(2))
                except ValueError:
                    continue
                attrs[m.group(1)] = value

            # for each struc, define a namedtuple
            m = STRUC_BEGIN_RE.match(line)
            if m:
                struct_name = m.group(1)
                struct_fields = []
                continue
            if struct_name:
                m = STRUC_FIELD_RE.match(line)
                if m:
                    struct_fields.append(m.group(1))
                    continue
                if STRUC_END_RE.match(line):
                    attrs[struct_name] = collections.namedtuple(struct_name, struct_fields)
                    struct_name = None
                    del struct_fields
                    continue
        return cls(attrs)

# Helpers for defining tables.
class Int64(int):
    """ Int wrapper that becomes an eight-byte integer (sign-agnostic) in ``ThcrapGen.data``. """
    def to_hex(self):
        return bytes_to_hex(struct.pack('<Q', self % 0x1_0000_0000_0000_0000))
class Int32(int):
    """ Int wrapper that becomes a four-byte integer (sign-agnostic) in ``ThcrapGen.data``. """
    def to_hex(self):
        return bytes_to_hex(struct.pack('<I', self % 0x1_0000_0000))
class Int16(int):
    """ Int wrapper that becomes a two-byte integer (sign-agnostic) in ``ThcrapGen.data``. """
    def to_hex(self):
        return bytes_to_hex(struct.pack('<H', self % 0x10000))
class Int8(int):
    """ Int wrapper that becomes a single byte (sign-agnostic) in ``ThcrapGen.data``. """
    def to_hex(self):
        return bytes_to_hex(struct.pack('<B', self % 0x100))
class Float64(float):
    """ Float wrapper that becomes an eight-byte float in ``ThcrapGen.data``. """
    def to_hex(self):
        return bytes_to_hex(struct.pack('<d', self))
class Float32(float):
    """ Float wrapper that becomes a four-byte float in ``ThcrapGen.data``. """
    def to_hex(self):
        return bytes_to_hex(struct.pack('<f', self))
