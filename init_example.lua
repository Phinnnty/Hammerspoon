-- Example usage for MoveMousetoScrollBar.spoon
-- This creates a menubar icon at the top of the screen

-- Load the spoon
hs.loadSpoon("MoveMousetoScrollBar")

-- Print a debug message to confirm spoon is loaded
print("[Hammerspoon] MoveMousetoScrollBar spoon loaded")

-- Initialize hotkeys and restore previous state 
-- This also ensures the menubar icon is visible and properly configured
local status, err = pcall(function()
    spoon.MoveMousetoScrollBar:autoStart()
end)

if not status then
    print("[Hammerspoon] Error in autoStart: " .. tostring(err))
    hs.alert.show("Error loading MoveMousetoScrollBar: " .. tostring(err))
else
    print("[Hammerspoon] MoveMousetoScrollBar autoStart completed successfully")
    hs.alert.show("MoveMousetoScrollBar initialized")
end

-- If you don't want to use a separate menubar icon
-- and prefer to have it in the Hammerspoon menu only,
-- you can hide the icon after setup:
-- spoon.MoveMousetoScrollBar.menubar:removeFromMenuBar()

-- Alternatively, if you want to explicitly start it:
-- spoon.MoveMousetoScrollBar:start()

-- If you want to customize settings:
-- spoon.MoveMousetoScrollBar:setConfig({
--     checkInterval = 0.5,
--     scrollBarOffset = 15,
--     verticalPosition = 0.8
-- })
