# Indybox theme for Pegasus

Black, orange and pixel-font front end for Indybox cabinets, styled from indybox.games
(palette, Anton / Inter / Jersey 10 fonts, 15px boxed buttons, orange fill on focus).

## Install

1. Run Pegasus once so it creates its config folder. On Windows that's
   `C:\Users\<you>\AppData\Local\pegasus-frontend\` (portable mode: `config\` next to the program).
2. Copy this whole `indybox` folder into that folder's `themes\` subfolder, so you end up with
   `...\pegasus-frontend\themes\indybox\theme.qml`.
3. In Pegasus: Settings > Theme > Indybox. Press F5 to reload after any edit.

## Updating

If this folder was cloned with git, double-click `update-theme.bat` to pull the latest version,
then press F5 in Pegasus. Your own edits to `config.js` (venue name etc.) are kept.

## Per-cabinet settings

Open `config.js`. The layout (`"grid"` or `"strip"`), venue name (`BLONDIES`), idle time before
attract mode, and how long each title card shows are all there. Nothing else changes per venue.

## What it does

- **Menu, grid layout (default):** a 3-column grid of tiles with a detail panel on the right
  (title, players, blurb, credits/QR). Stick in any direction moves around the grid, up/down wrap
  top to bottom, and it scrolls a row at a time once you have more than nine games.
- **Menu, strip layout:** one big hero for the selected game over a single row of tiles.
  Any stick direction steps along the row.
- Both: the accept button plays, and the last game is remembered after you quit a game.
- **Settings:** the theme leaves the cancel key (Esc) alone so Pegasus can open its own menu.
  Keep Esc on the cabinet's keyboard only; don't map any player button to it, or patrons can
  open settings. Check Settings > Controls.
- **Attract mode:** starts after 90s idle. Bouncing `indybox@VENUE` tag that changes colour on each
  wall hit, cycling "now showing" cards, blinking prompt. The first button press only wakes it,
  it never starts a game.
- **Credits/QR zone:** bottom right on both screens. Shows the developer and, if set, a QR code.

## Game metadata

See `example/metadata.pegasus.txt`. Per game you can set `developer`, `players`, `genre`,
`summary`, plus two custom fields this theme reads:

- `x-qr:` path to a QR image (absolute path, e.g. `C:/indybox/qr/verminian-trap.png`)
- `x-url:` short text shown under the QR (e.g. `itch.io/locomalito`)

Where games go: Pegasus has no default games folder. Pick one (e.g. `C:\indybox\games`), put
`metadata.pegasus.txt` in it, and add that folder under Settings > Game directories.

Artwork: Pegasus looks in a `media` folder next to `metadata.pegasus.txt`, in a subfolder named
after the game's title or its exe file name without `.exe`:

    C:\indybox\games\
        metadata.pegasus.txt
        Locomalito\VerminianTrap\VerminianTrap.exe
        media\
            Verminian Trap\screenshot.png   (also background.png, banner.png, logo.png; PNG or JPG)

The theme uses `screenshot` (falling back to titlescreen, background, banner, boxFront) for the
tile and `background` (falling back to screenshot) for the dimmed backdrop. You can also point at
an image explicitly per game with `assets.screenshot: path/to/file.png` in the metadata.

## Notes

- Designed at 1920x1080 and scales to other 16:9 sizes.
- Pegasus passes gamepad input to themes as keys, so an encoder that presents as a keyboard works.
  Check Settings > Controls so accept/cancel match your buttons.
- Not in the theme (needs doing outside Pegasus): the hold-two-buttons exit combo, an idle
  watchdog that closes a running game, and booting straight into Pegasus.
