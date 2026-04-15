> **ReaPack users:** This script is distributed through the unified Dead Pixel Design repository.
> Add this URL in REAPER under `Extensions → ReaPack → Import repositories`:
> ```
> https://raw.githubusercontent.com/wretcher207/dead-pixel-design/main/index.xml
> ```

---

# The Separator

![REAPER](https://img.shields.io/badge/REAPER-6%2B-green?style=flat-square)
![Lua](https://img.shields.io/badge/Lua-ReaScript-blue?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-yellow?style=flat-square)
![Status](https://img.shields.io/badge/Status-Production--Ready-brightgreen?style=flat-square)

**Extract audio from video items onto dedicated tracks in one click.**

Reaper's video workflow is a legitimate pain. Drag in a video, get a single item playing both streams, and now you have to manually create a track, re-import the file, align everything, and configure it twice — every time. The Separator does all of that in one action.

---

## What It Does

Select one or more video items on the timeline and run the action. For each item:

- A new audio track is created directly below the video track
- The same source file is added to it as a new item — synced, same position, same length
- The audio track is named and color-paired with the video track
- The original video item's audio output is silenced so nothing double-plays

The result is a clean split: video on one track, audio on another, ready to edit independently.

---

## Supported Formats

MP4, MOV, AVI, MKV, WMV, M4V, WebM, FLV, MTS, M2TS, TS

---

## Prerequisites

- **REAPER** 6.0 or later
- No other dependencies required

---

## Installation

### Via ReaPack (recommended)

1. Open REAPER
2. Go to `Extensions → ReaPack → Import repositories…`
3. Paste:
   ```
   https://raw.githubusercontent.com/wretcher207/dead-pixel-design/main/index.xml
   ```
4. Click OK
5. Go to `Extensions → ReaPack → Browse packages`
6. Search **The Separator**, right-click → Install
7. Restart REAPER or run `Actions → ReaPack: Synchronize packages`

### Manual

Download `dpd_TheSeparator.lua` and drop it into your REAPER Scripts folder:
- **Windows:** `%APPDATA%\REAPER\Scripts\`
- **macOS:** `~/Library/Application Support/REAPER/Scripts/`

Then add it via `Actions → Show Action List → Load`.

---

## Usage

1. Select one or more video items on the timeline
2. Run **Script: dpd_TheSeparator.lua** from the Action List
3. Assign a keyboard shortcut for fast access: `Actions → Show Action List → search "Separator" → Add shortcut`

The action is fully undoable with Ctrl+Z / Cmd+Z.

---

## Notes

- The original video item is not deleted or modified — only its take volume is set to 0 to prevent double-playback. This is reversible: open Item Properties and drag the take volume back up.
- If you select non-video items alongside video items, they are skipped and counted in the result dialog.

---

## Author

David W. Russell III / [Dead Pixel Design](https://www.deadpixeldesign.com)

*We don't optimize. We haunt.*

---

## License

MIT
