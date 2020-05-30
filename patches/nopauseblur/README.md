# `nopauseblur`

Disables blur on pause.

Mostly created to make the Za Warudo patch (`nopause_enm`) reasonably playable, but might also be helpful for seeing things after a game over.

## Supported games

Supports TH15-TH17 and VD.

Unfortunately, the pause blur works differently in TH11-TH14 (those games softlock on stage load if I try to make the same change), and even more differently in TH10 (its pause blur is an opaque surface).  I haven't figured out how to support those games.
