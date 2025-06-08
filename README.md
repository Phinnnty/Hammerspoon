# Hammerspoon Scripts

A collection of Lua scripts for the [Hammerspoon](https://www.hammerspoon.org/) automation tool for macOS. These scripts provide various utilities to enhance productivity and automate repetitive tasks.

## Scripts Overview

### MouseToScrollBar.lua

A standalone script that automatically moves the mouse cursor to the right side of the screen (near the scrollbar area) and performs auto-scrolling.

**Features:**
- Automatically moves the mouse cursor to the right side of the screen when inactive
- Implements a trigger zone on the bottom-right portion of the screen
- Auto-scrolls when the mouse is in the trigger zone
- Includes debugging output in the Hammerspoon console
- Configurable scrolling speed and position

**Usage:**
Load this script in Hammerspoon to enable automatic mouse movement and scrolling.

### MoveMousetoScrollBar.spoon

A packaged Spoon version of the mouse movement and auto-scrolling functionality.

**Features:**
- Structured as a proper Hammerspoon Spoon for better organization
- Same core functionality as MouseToScrollBar.lua but in a reusable module
- Provides start/stop methods for controlling the functionality
- Includes detailed console logging for debugging

**Usage:**
```lua
hs.loadSpoon("MoveMousetoScrollBar")
spoon.MoveMousetoScrollBar:start()
```

### FB_Call.spoon

A utility Spoon that provides a keyboard shortcut for tabbing through form fields and submitting.

**Features:**
- Creates a hotkey (Cmd+Alt+T) that presses the Tab key 30 times
- Automatically presses Enter/Return after tabbing
- Useful for quickly navigating through form fields

**Usage:**
```lua
hs.loadSpoon("FB_Call")
spoon.FB_Call:start()
```

## Installation

1. Install [Hammerspoon](https://www.hammerspoon.org/) if you haven't already
2. Clone this repository to your local machine
3. Copy the scripts or Spoons to your Hammerspoon configuration directory (`~/.hammerspoon/`)
4. Add the necessary `require` or `hs.loadSpoon()` calls to your `init.lua`

## Configuration

Each script can be customized by modifying variables such as:
- `scrollSpeedY`: Controls the speed and direction of auto-scrolling
- Timer intervals: Adjust how frequently the mouse movement and scrolling checks occur

## License

MIT - See individual script files for details.
