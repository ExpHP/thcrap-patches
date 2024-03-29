# ExpHP's thcrap patches

This is the source repository for my patches published via `thcrap_configure`, as well as a few patches that are not published.  Most of these are binhacks that either improve the gameplay experience or do obscure, silly things.  The patches are located in [`/patches`](https://github.com/ExpHP/thcrap-patches/tree/master/patches), where many of them have README files that you can read for more information.

## Source structure

As thcrap does not support patch level plugins yet, most of these are implemented as thcrap binhacks and codecaves: i.e. hexadecimal strings that encode raw x86 assembly, defined in json files.  But of course, JSON files suck, because they have no comments.  I believe it is important for the reader to *at least* be able to see the assembly mnemonics behind these hex strings, so fairly early on, I added a form of YAML files which break the code up into lines, giving room for comments.  [`scripts/convert-yaml.py`](https://github.com/ExpHP/thcrap-patches/blob/master/scripts/convert-yaml.py) is responsible for the conversion to JSON.

For a while, I just maintained these YAML files directly, but as time progressed, even that become arduous.  So over time I have piled more and more text transformations onto the output of `nasm -l` to make it more closely resemble the final desired YAML file.  This is done in [`scripts/list-asm`](https://github.com/ExpHP/thcrap-patches/blob/master/scripts/list-asm) (with a considerable portion in the [python script it calls](https://github.com/ExpHP/thcrap-patches/blob/master/scripts/list-asm-postprocess.py)).  In the end, *it works,* though I can't help but liken the feeling to living in a house made of cards, as I don't think `nasm -l` was ever meant to be used like this.  (I should note I am using NASM version 2.13.02, just in case they ever make an update that changes the output enough to break my scripts...)

On the bright side, these days some files which only include codecaves (i.e. no regular binhacks) have the ASM -> JSON process fully automated by `make`, and the intermediate YAML files don't even need to be checked into version control, which is admittedly pretty dope considering that all I had to do was sell my soul to the devil.

Binhacks in some patches also now have a fully automated compilation process beginning from python scripts that use [keystone](https://github.com/keystone-engine/keystone) to assemble.  They're not the prettiest thing around (at least, not without highlighting of assembly in string literals), but if you stare hard enough you almost may find some semblance of sanity in them.

The scripts have a couple of dependencies.  To install them, do:

```python3
python3 -m pip install --user -r requirements.txt
```
