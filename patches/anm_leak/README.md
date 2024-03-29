# `anm_leak`

Fixes the infamous crashes in Hidden Star in Four Seasons that can happen when a large number of bullets are canceled along with some other effect.

In summary, the fix is to leak everything.

---

## Why the crash occurs

The tl;dr is:

* There are some animations (most notably enemy death) where a child ANM VM outlives a parent.
* When this happens, the game will try to access some fields on the destroyed parent.
* Typically, nothing bad happens, because the memory backing the parent VM has usually not been truly deallocated.  However, once more than 8191 automatically managed VMs exist (e.g. during big releases), they start getting individually allocated/deallocated.

For further explanation, [see this gist](https://gist.github.com/ExpHP/f275e0edc02603580f24a5ba3da952cc#addendum-20201007-reason-for-the-crashes).

## How this patch fixes the crashes

As described above, while the logic bug is technically present at all times, the actual symptom of crashing only occurs when VMs are individually allocated and deallocated.

So.  This patch fixes the crashes by *never freeing ANM VMs.*  They are kept around for reuse forever.

## Performance improvements for large effect counts

Since we're messing with the allocation and deallocation of VMs, I figured I'd tackle another problem while we can.

All games since TH15 track root VMs for "effects" as a leftover of TH15's pointdevice implementation.  Every frame, the game has to do an ANM ID search for each of these effects.  These searches make extremely inefficient use of memory cache and can produce **absolutely unbearable lag** if there are hundreds of thousands of VMs and a couple hundred (or thousand) effects, as can be the case in \*cough\* *some mods.*  To solve this, this patch allocates VMs in large batches, and changes the ANM ID system to directly indicate a batch and index.

The performance boost from this is more noticeable in some games than others.  It was pretty big in WBaWC, but not so big in LoLK (which has surprisingly few effects).

TH17 and TH18 also have an absurdly slow draw loop due to a seemingly hasty bugfix in TH17 v1.00b.  The issue here is similar to the above (poor usage of cache), and this patch solves that by generating densely filled arrays of the layers of all VMs to give the memory prefetcher a fighting chance during the repeated scans for VMs belonging to each layer.
