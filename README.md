# Hammerspoon Accessibility Repo

A collection of Lua scripts for the [Hammerspoon](https://www.hammerspoon.org/) automation tool for macOS. These scripts provide various utilities to provide aid for those with accessibilty needs 

## Scripts Overview

### MoveMousetoScrollBar.spoon

# MoveMousetoScrollBar

## Overview

MoveMousetoScrollBar is a Hammerspoon spoon designed specifically for users with accessibility needs who use eye tracking software to control their mouse. It automatically positions the mouse cursor near the scrollbar area when the mouse hasn't been moved manually, making it easier to scroll through content.

This accessibility tool is particularly helpful for users who:
- Have mobility impairments that make precise mouse movement difficult
- Rely on eye tracking or other assistive technologies
- Need assistance with scrolling actions in various applications

## Features

- **Automatic Positioning**: Moves the cursor to the scrollbar area when idle
- **Temporary Disable**: Hold a configurable key (default: fn) to temporarily disable auto-movement
- **Highly Configurable**: Customize position, timing, and behavior
- **Non-Intrusive**: Only activates when the mouse hasn't moved for a period

## Installation

1. Install [Hammerspoon](https://www.hammerspoon.org/) if you haven't already
2. Download the [MoveMousetoScrollBar.spoon](https://github.com/Phinnnty/Hammerspoon/raw/master/MoveMousetoScrollBar.spoon.zip)
3. Double-click the downloaded file to unzip it
4. Move the extracted `MoveMousetoScrollBar.spoon` folder to `~/.hammerspoon/Spoons/`
5. Add the following to your Hammerspoon `init.lua` configuration file:

```lua
hs.loadSpoon("MoveMousetoScrollBar")
spoon.MoveMousetoScrollBar:start()
```

## Configuration

The spoon is highly customizable to adapt to different user needs and preferences:

```lua
-- Optional: Configure settings programmatically
spoon.MoveMousetoScrollBar:setConfig({
    disableKey = "fn",          -- Key to hold to temporarily disable mouse movement
    checkInterval = 0.375,      -- How frequently to check mouse position (in seconds)
    scrollBarOffset = 25,       -- Distance from the right edge to position the mouse (in pixels)
    verticalPosition = 0.7,     -- Relative position down the screen (0.0-1.0)
    triggerZoneStart = 0.01,    -- How far from left edge to start checking (as fraction of screen width)
    edgeBuffer = 40             -- Don't move mouse if already close to right edge (in pixels)
})
```

### Configuration Options

| Setting | Default | Description |
|---------|---------|-------------|
| disableKey | "fn" | Key to hold to temporarily disable mouse movement |
| checkInterval | 0.375 | How frequently to check mouse position (seconds) |
| scrollBarOffset | 25 | Distance from right edge to position mouse (pixels) |
| verticalPosition | 0.7 | Relative position down the screen (0.0-1.0) |
| triggerZoneStart | 0.01 | How far from left edge to start checking (fraction of screen width) |
| edgeBuffer | 40 | Don't move mouse if already close to right edge (pixels) |

## How It Works

1. The spoon regularly checks if the mouse has moved since the last check
2. If the mouse hasn't moved and is beyond the trigger zone from the left edge
3. And if the mouse isn't already near the right edge (within edgeBuffer)
4. Then it automatically positions the mouse near the scrollbar area

This behavior makes scrolling more accessible without interfering with normal mouse usage.

## Keyboard Shortcuts

- **Hold fn key**: Temporarily disable automatic mouse movement
- **Cmd+Alt+Ctrl+R**: Reload Hammerspoon configuration

## License

[MIT License](https://opensource.org/licenses/MIT)

---

*This spoon is part of a collection of accessibility tools designed to make computer interaction easier for users with special needs. 


## License

MIT - See individual script files for details.
