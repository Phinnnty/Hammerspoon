# Mouse to Scroll Bar

- This spoon was specifically designed for users with accessibility needs who use eye tracking
- software to control their mouse. It helps by automatically positioning the mouse near the 
- scrollbar area when the mouse hasn't been moved manually, making it easier to scroll through content.

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

## Installation

1. Install [Hammerspoon](https://www.hammerspoon.org/) if you haven't already
2. Clone this repository to your local machine
3. Copy the scripts or Spoons to your Hammerspoon configuration directory (`~/.hammerspoon/`) - you can find it manually by opening the Finder application, then hitting Command + Shift + G to search Finder and type in Hammerspoon or Spoons. 
4. Add the necessary `require` or `hs.loadSpoon()` calls to your `init.lua`

All settings are automatically saved using Hammerspoon's persistent storage system and will be remembered across Hammerspoon restarts. The spoon also temporarily stops auto-movement while the settings interface is open to prevent interference with configuration.

Each setting has input validation to ensure values are within appropriate ranges:
- Check interval: 0.1 to 10.0 seconds
- Scrollbar offset: 1 to 200 pixels
- Vertical position: 0.01 to 0.99 (fraction of screen height)
- Trigger zone start: 0.001 to 0.9 (fraction of screen width)
- Edge buffer: 0 to 200 pixels

## License

MIT - See individual script files for details.
