# Hammerspoon Scripts

A collection of Lua scripts for the [Hammerspoon](https://www.hammerspoon.org/) automation tool for macOS. These scripts provide various utilities to enhance productivity and automate repetitive tasks.

## Scripts Overview

### MoveMousetoScrollBar.spoon

A packaged Spoon version of the mouse movement and auto-scrolling functionality with additional enhancements. 

**Features:**
- Structured as a proper Hammerspoon Spoon for better organization
- Same core functionality as MouseToScrollBar.lua but in a reusable module
- Provides start/stop methods for controlling the functionality
- Includes detailed console logging for debugging
- Graphical settings interface accessible via keyboard shortcut (Cmd+Alt+M) -- it would be good to set this up as menu bar item on mac, but haven't implemented this yet. 
- Persistent settings and state storage across Hammerspoon restarts

**Usage:**
```lua
hs.loadSpoon("MoveMousetoScrollBar")
spoon.MoveMousetoScrollBar:start()

-- Optional: Configure settings programmatically
spoon.MoveMousetoScrollBar:setConfig({
    disableKey = "fn",          -- Key to hold to temporarily disable mouse movement
    checkInterval = 0.375,      -- How frequently to check mouse position (in seconds)
    scrollBarOffset = 20,       -- Distance from the right edge to position the mouse (in pixels)
    verticalPosition = 0.85,    -- Relative position down the screen (0.0-1.0)
    triggerZoneStart = 0.01,    -- How far from left edge to start checking (as fraction of screen width)
    edgeBuffer = 40             -- Don't move mouse if already close to right edge (in pixels)
})

-- Settings can also be accessed via the GUI by using the keyboard shortcut Cmd+Alt+M
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
3. Copy the scripts or Spoons to your Hammerspoon configuration directory (`~/.hammerspoon/`) - you can find it manually by opening the Finder application, then hitting Command + Shift + G to search Finder and type in Hammerspoon or Spoons. 
4. Add the necessary `require` or `hs.loadSpoon()` calls to your `init.lua`

## Configuration

### Basic Configuration
Each script can be customized by modifying variables such as:
- Timer intervals: Adjust how frequently the mouse movement and scrolling checks occurt

### MoveMousetoScrollBar Settings GUI
The MoveMousetoScrollBar spoon provides a graphical settings interface that can be accessed by:
- Pressing the keyboard shortcut `Cmd+Alt+M`

The settings interface provides:
- Current status indicator showing if the spoon is enabled or disabled
- Sliders and dropdowns to adjust:
  - Disable key (which modifier key temporarily disables auto-movement)
  - Check interval (how frequently the mouse position is checked)
  - Scrollbar offset (distance from the right edge of the screen)
  - Vertical position (where vertically the mouse is positioned)
  - Trigger zone start (how far from the left edge to start checking)
  - Edge buffer (don't move mouse if already close to right edge)
- Three action buttons:
  - Reset to Defaults: Returns all settings to their default values
  - Cancel: Closes the settings window without saving changes
  - Save Settings: Applies and saves all current settings
 
    ![image](https://github.com/user-attachments/assets/55499a8d-94d4-46b7-93c9-b6c994eb1317)


All settings are automatically saved using Hammerspoon's persistent storage system and will be remembered across Hammerspoon restarts. The spoon also temporarily stops auto-movement while the settings interface is open to prevent interference with configuration.

Each setting has input validation to ensure values are within appropriate ranges:
- Check interval: 0.1 to 10.0 seconds
- Scrollbar offset: 1 to 200 pixels
- Vertical position: 0.01 to 0.99 (fraction of screen height)
- Trigger zone start: 0.001 to 0.9 (fraction of screen width)
- Edge buffer: 0 to 200 pixels

### MouseToScrollBar.lua

A standalone script that automatically moves the mouse cursor to the right side of the screen (near the scrollbar area) and performs auto-scrolling, it's more barebones than the packaged spoon; lacking the pause function via fn key, and the settings GUI. 

**Features:**
- Automatically moves the mouse cursor to the right side of the screen when inactive
- Implements a trigger zone on the bottom-right portion of the screen
- Auto-scrolls when the mouse is in the trigger zone
- Includes debugging output in the Hammerspoon console
- Configurable scrolling speed and position

**Usage:**
Load this script in Hammerspoon to enable automatic mouse movement and scrolling.

## License

MIT - See individual script files for details.
