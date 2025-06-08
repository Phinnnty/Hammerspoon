--- === MoveMousetoScrollBar ===
---
--- Automatically moves the mouse cursor to the scrollbar area when idle
---
--- This spoon was specifically designed for users with accessibility needs who use eye tracking
--- software to control their mouse. It helps by automatically positioning the mouse near the 
--- scrollbar area when the mouse hasn't been moved manually, making it easier to scroll through content.
---
--- The script can be temporarily disabled by holding the fn key (configurable).
---
--- Download: [https://github.com/Phinnnty/Hammerspoon/raw/master/MoveMousetoScrollBar.spoon.zip](https://github.com/Phinnnty/Hammerspoon/raw/master/MoveMousetoScrollBar.spoon.zip)

local obj = {}
obj.__index = obj

-- Metadata
obj.name = "MoveMousetoScrollBar"
obj.version = "1.0"
obj.author = "Fintan Molloy"
obj.homepage = "https://github.com/Phinnnty/Hammerspoon"
obj.license = "MIT - https://opensource.org/licenses/MIT"

-- Default configuration
obj.defaultConfig = {
    disableKey = "fn",          -- Key to hold to temporarily disable mouse movement
    checkInterval = 0.375,      -- How frequently to check mouse position (in seconds)
    scrollBarOffset = 25,       -- Distance from the right edge to position the mouse (in pixels)
    verticalPosition = 0.7,     -- Relative position down the screen (0.0-1.0)
    triggerZoneStart = 0.01,    -- How far from left edge to start checking (as fraction of screen width)
    edgeBuffer = 40             -- Don't move mouse if already close to right edge (in pixels)
}

--- MoveMousetoScrollBar:init()
--- Method
--- Initialize the spoon
function obj:init()
    self.config = {}
    for k, v in pairs(self.defaultConfig) do
        self.config[k] = v
    end
    
    self.lastMousePosition = hs.mouse.getAbsolutePosition()
    self.disableFlag = false
    
    -- Set up event watcher for the disable key
    self.keyWatcher = hs.eventtap.new({hs.eventtap.event.types.flagsChanged}, function(event)
        local flags = event:getFlags()
        
        -- Check if the disable key is being held down
        if flags[self.config.disableKey] then
            self.disableFlag = true
        else
            self.disableFlag = false
        end
        return false
    end)
end

--- MoveMousetoScrollBar:setConfig(config)
--- Method
--- Configure the spoon
---
--- Parameters:
---  * config - A table with configuration options:
---    * disableKey - Key to hold to temporarily disable mouse movement (default: "fn")
---    * checkInterval - How frequently to check mouse position in seconds (default: 0.375)
---    * scrollBarOffset - Distance from right edge to position mouse (default: 25)
---    * verticalPosition - Relative position down the screen from 0-1 (default: 0.7)
---    * triggerZoneStart - How far from left edge to start checking (default: 0.01)
---    * edgeBuffer - Don't move mouse if already close to right edge (default: 40)
function obj:setConfig(config)
    if config then
        for k, v in pairs(config) do
            self.config[k] = v
        end
    end
end

--- MoveMousetoScrollBar:start()
--- Method
--- Start the mouse positioning timer
function obj:start()
    -- Add reload hotkey
    hs.hotkey.bind({"cmd", "alt", "ctrl"}, "R", function()
        hs.reload()
        hs.alert.show("Config loaded")
    end)

    -- Start the key watcher
    self.keyWatcher:start()
    
    -- Start the timer to check mouse position
    self.mouseMoveTimer = hs.timer.doEvery(self.config.checkInterval, function() self:moveMouseToRight() end)
    
    hs.alert.show("Mouse to ScrollBar enabled")
    return self
end

--- MoveMousetoScrollBar:stop()
--- Method
--- Stop the mouse positioning timer
function obj:stop()
    if self.mouseMoveTimer then self.mouseMoveTimer:stop() end
    if self.keyWatcher then self.keyWatcher:stop() end
    hs.alert.show("Mouse to ScrollBar disabled")
    return self
end

--- MoveMousetoScrollBar:hasMouseMoved()
--- Method
--- Check if the mouse has moved since the last check
---
--- Returns:
---  * Boolean indicating if the mouse position has changed
function obj:hasMouseMoved()
    local currentMousePosition = hs.mouse.getAbsolutePosition()
    return not (currentMousePosition.x == self.lastMousePosition.x and currentMousePosition.y == self.lastMousePosition.y)
end

--- MoveMousetoScrollBar:moveMouseToRight()
--- Method
--- Check conditions and move the mouse to the scrollbar area if needed
function obj:moveMouseToRight()
    -- Skip if disabled via modifier key
    if self.disableFlag then
        return
    end
    
    local screenFrame = hs.screen.mainScreen():frame()
    local triggerZoneStart = screenFrame.w * self.config.triggerZoneStart
    local currentMousePosition = hs.mouse.getAbsolutePosition()

    -- Check if the mouse is beyond the trigger zone and hasn't moved manually
    if currentMousePosition.x > triggerZoneStart and not self:hasMouseMoved() then
        -- Only move the mouse if it's not already near the scrollbar
        if currentMousePosition.x < screenFrame.w - self.config.edgeBuffer then
            hs.mouse.setAbsolutePosition(hs.geometry.point(
                screenFrame.w - self.config.scrollBarOffset, 
                screenFrame.h * self.config.verticalPosition
            ))
        end
    end

    -- Update the last known position
    self.lastMousePosition = hs.mouse.getAbsolutePosition()
end

return obj