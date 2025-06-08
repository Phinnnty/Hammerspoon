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
    scrollBarOffset = 20,       -- Distance from the right edge to position the mouse (in pixels)
    verticalPosition = 0.85,    -- Relative position down the screen (0.0-1.0)
    triggerZoneStart = 0.01,    -- How far from left edge to start checking (as fraction of screen width)
    edgeBuffer = 40             -- Don't move mouse if already close to right edge (in pixels)
}

-- Settings key for persistent storage
-- This key is used with hs.settings.set() and hs.settings.get() to save and load
-- the user's configuration across Hammerspoon restarts.
-- The settings are stored in Hammerspoon's settings storage as a serialized table.
obj.settingsKey = "MoveMousetoScrollBar_settings"

--- MoveMousetoScrollBar:init()
--- Method
--- Initialize the spoon
function obj:init()
    -- Load saved settings or use defaults
    -- First, try to retrieve any previously saved settings from Hammerspoon's persistent storage
    -- If no saved settings exist, an empty table is used instead
    local savedSettings = hs.settings.get(self.settingsKey) or {}
    
    -- Initialize our configuration table
    self.config = {}
    
    -- For each default setting, check if we have a saved value and use it
    -- Otherwise, fall back to the default value
    -- This ensures that if new settings are added in future versions,
    -- they will be initialized with their default values
    for k, v in pairs(self.defaultConfig) do
        self.config[k] = savedSettings[k] or v
    end
    
    -- Load saved running state if available, otherwise default to false (disabled)
    self.running = hs.settings.get(self.settingsKey .. "_running") or false
    
    self.lastMousePosition = hs.mouse.absolutePosition()
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
    
    -- Create menubar item
    self.menubar = hs.menubar.new()
    if self.menubar then
        -- Set initial icon based on running state (will be updated in start/stop methods)
        self:updateMenubarIcon()
        
        -- Set tooltip with current status
        self:updateMenubarTooltip()
        
        -- Define the menubar dropdown menu
        self.menubar:setMenu(function()
            return {
                {title = "✨ Open Settings...", fn = function() self:showConfigGUI() end},
                {title = "-"}, -- Separator
                {title = self.running and "⏹ Disable" or "▶️ Enable", fn = function() 
                    if self.running then
                        self:stop()
                    else
                        self:start()
                    end
                    -- Menu will be rebuilt next time it's opened with updated state
                end},
                {title = "-"}, -- Separator
                {title = "🔄 Restart", fn = function()
                    if self.running then self:stop() end
                    self:start()
                    hs.alert.show("Mouse to ScrollBar restarted")
                end},
                {title = "-"}, -- Separator
                {title = "ℹ️ About", fn = function() 
                    hs.alert.show("Mouse to ScrollBar v" .. self.version .. "\nBy " .. self.author .. "\n\nCmd+Alt+M for settings") 
                end}
            }
        end)
        
        -- Make the menubar clickable - toggle enabled/disabled state on click
        self.menubar:setClickCallback(function() 
            if self.running then
                self:stop()
            else
                self:start()
            end
        end)
    end
    
    -- Track running state
    self.running = false
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
--- MoveMousetoScrollBar:setConfig(config)
--- Method
--- Configure the spoon and save settings to persistent storage
---
--- Parameters:
---  * config - A table with configuration options
---
--- Notes:
---  * This method updates the current configuration and saves it to Hammerspoon's
---    persistent storage using hs.settings.set(). The settings will be automatically
---    loaded when Hammerspoon restarts or when the spoon is reinitialized.
---  * Only the provided settings will be updated; other settings will retain their
---    current values.
function obj:setConfig(config)
    if config then
        -- Update our current configuration with the new values
        for k, v in pairs(config) do
            self.config[k] = v
        end
        
        -- Save settings to persist across Hammerspoon restarts
        -- The entire config table is saved as a single serialized object
        -- hs.settings handles the serialization and deserialization automatically
        hs.settings.set(self.settingsKey, self.config)
    end
end

--- MoveMousetoScrollBar:showConfigGUI()
--- Method
--- Display a GUI for configuring the spoon settings
---
--- This method provides a user-friendly interface for adjusting the spoon's settings
--- without having to edit code directly. It's particularly helpful for users with accessibility needs.
function obj:showConfigGUI()
    -- Get the current screen frame for positioning
    local screen = hs.screen.mainScreen()
    local screenFrame = screen:frame()
    
    -- Store the current running state so we can restore it later
    local wasRunning = self.running
    
    -- Temporarily stop auto-movement while settings are open
    if self.running then
        if self.mouseMoveTimer then 
            self.mouseMoveTimer:stop() 
        end
        -- We don't call full stop() to avoid changing menubar state
    end
    
    -- Define settings descriptions and their current values
    local settingsDescriptions = {
        disableKey = {
            description = "Key to hold to temporarily disable mouse movement",
            type = "select",
            options = {"fn", "cmd", "alt", "shift", "ctrl"},
            current = self.config.disableKey
        },
        checkInterval = {
            description = "Check interval (seconds)",
            type = "number",
            min = 0.1,
            max = 5.0,
            step = 0.1,
            current = self.config.checkInterval
        },
        scrollBarOffset = {
            description = "Distance from right edge (pixels)",
            type = "number",
            min = 5,
            max = 100,
            step = 5,
            current = self.config.scrollBarOffset
        },
        verticalPosition = {
            description = "Vertical position (0.0-1.0)",
            type = "number",
            min = 0.1,
            max = 0.9,
            step = 0.05,
            current = self.config.verticalPosition
        },
        triggerZoneStart = {
            description = "Left edge trigger zone (0.0-0.5)",
            type = "number",
            min = 0.001,
            max = 0.5,
            step = 0.01,
            current = self.config.triggerZoneStart
        },
        edgeBuffer = {
            description = "Right edge buffer (pixels)",
            type = "number",
            min = 10,
            max = 100,
            step = 5,
            current = self.config.edgeBuffer
        }
    }
    
    -- Create a webview for our settings dialog
    local webviewWidth = 600
    local webviewHeight = 600  -- Increased height to accommodate all content
    local settingsWebview = hs.webview.new({
        x = (screenFrame.w - webviewWidth) / 2,
        y = (screenFrame.h - webviewHeight) / 2,
        w = webviewWidth,
        h = webviewHeight
    })
    
    -- Generate the HTML for our settings form
    local html = [[
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="UTF-8">
        <title>Mouse to ScrollBar Settings</title>
        <style>
            body {
                font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
                margin: 0;
                padding: 10px;
                color: #333;
                background-color: #f8f8f8;
                overflow: hidden;  /* Prevent scrollbars */
            }
            h1 {
                font-size: 22px;
                margin-top: 0;
                margin-bottom: 5px;
                color: #333;
            }
            .status-indicator {
                display: inline-flex;
                align-items: center;
                margin-bottom: 15px;
                padding: 5px 10px;
                border-radius: 15px;
                font-size: 13px;
                font-weight: 500;
            }
            .status-enabled {
                background-color: #e3f8e3;
                color: #1a791a;
                border: 1px solid #c1e8c1;
            }
            .status-disabled {
                background-color: #f8e3e3;
                color: #791a1a;
                border: 1px solid #e8c1c1;
            }
            .status-dot {
                width: 8px;
                height: 8px;
                border-radius: 50%;
                margin-right: 6px;
            }
            .dot-enabled {
                background-color: #1a791a;
            }
            .dot-disabled {
                background-color: #791a1a;
            }
            .container {
                max-width: 560px;
                margin: 0 auto;
                background-color: white;
                border-radius: 10px;
                padding: 15px;
                box-shadow: 0 1px 5px rgba(0,0,0,0.1);
                height: calc(100vh - 20px);
                max-height: 550px;
                overflow-y: auto;  /* Scrollable container if needed */
            }
            .form-group {
                margin-bottom: 12px;  /* Reduced spacing */
            }
            label {
                display: block;
                margin-bottom: 5px;
                font-weight: 500;
            }
            .description {
                font-size: 12px;
                color: #666;
                margin-top: 4px;
            }
            input[type="number"], select {
                width: 100%;
                padding: 6px;
                border: 1px solid #ddd;
                border-radius: 4px;
                font-size: 14px;
                box-sizing: border-box;
            }
            .button-row {
                display: flex;
                justify-content: space-between;
                margin-top: 20px;
            }
            button {
                padding: 10px 20px;
                border: none;
                border-radius: 5px;
                font-size: 15px;
                cursor: pointer;
                font-weight: bold;
                transition: all 0.2s;
                box-shadow: 0 2px 4px rgba(0,0,0,0.2);
            }
            .save-button {
                background-color: #0071e3;
                color: white;
                min-width: 120px;
            }
            .save-button:hover {
                background-color: #0077ed;
            }
            .cancel-button {
                background-color: #f2f2f2;
                color: #333;
                min-width: 80px;
            }
            .cancel-button:hover {
                background-color: #e5e5e5;
            }
            .reset-button {
                background-color: #ff3b30;
                color: white;
                min-width: 140px;
            }
            .reset-button:hover {
                background-color: #ff4f45;
            }
            .disabled {
                opacity: 0.5;
                cursor: not-allowed;
            }
            .range-container {
                display: flex;
                align-items: center;
            }
            input[type="range"] {
                flex: 1;
                margin-right: 10px;
                height: 6px;  /* Slimmer slider */
            }
            .range-value {
                min-width: 50px;
                text-align: right;
                font-family: monospace;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>Mouse to ScrollBar Settings</h1>
            <div class="status-indicator ]] .. (self.running and "status-enabled" or "status-disabled") .. [[">
                <span class="status-dot ]] .. (self.running and "dot-enabled" or "dot-disabled") .. [["></span>
                <span>]] .. (self.running and "Enabled" or "Disabled") .. [[</span>
            </div>
            <form id="settingsForm">
    ]]
    
    -- Generate form fields for each setting
    for settingKey, settingInfo in pairs(settingsDescriptions) do
        html = html .. [[
                <div class="form-group">
                    <label for="]] .. settingKey .. [[">]] .. settingInfo.description .. [[</label>
        ]]
        
        if settingInfo.type == "select" then
            html = html .. [[
                    <select id="]] .. settingKey .. [[" name="]] .. settingKey .. [[">
            ]]
            
            for _, option in ipairs(settingInfo.options) do
                local selected = ""
                if option == settingInfo.current then
                    selected = " selected"
                end
                html = html .. [[
                        <option value="]] .. option .. [["]] .. selected .. [[>]] .. option .. [[</option>
                ]]
            end
            
            html = html .. [[
                    </select>
            ]]
        elseif settingInfo.type == "number" then
            html = html .. [[
                    <div class="range-container">
                        <input type="range" id="]] .. settingKey .. [[" name="]] .. settingKey .. [[" 
                            min="]] .. settingInfo.min .. [[" max="]] .. settingInfo.max .. [[" 
                            step="]] .. settingInfo.step .. [[" value="]] .. settingInfo.current .. [[">
                        <span class="range-value" id="]] .. settingKey .. [[Value">]] .. settingInfo.current .. [[</span>
                    </div>
            ]]
        end
        
        html = html .. [[
                </div>
        ]]
    end
    
    -- Add form buttons and closing tags
    html = html .. [[
                <div class="button-row">
                    <button type="button" class="reset-button" id="resetButton">Reset to Defaults</button>
                    <div>
                        <button type="button" class="cancel-button" id="cancelButton">Cancel</button>
                        <button type="button" class="save-button" id="saveButton">Save Settings</button>
                    </div>
                </div>
            </form>
        </div>
        
        <script>
            // Update number display when sliders change
            const sliders = document.querySelectorAll('input[type="range"]');
            sliders.forEach(slider => {
                slider.addEventListener('input', function() {
                    document.getElementById(this.id + 'Value').textContent = this.value;
                });
            });
            
            // Function to collect form data
            function collectFormData() {
                const formData = {};
                const form = document.getElementById('settingsForm');
                
                // Collect form data
                for (const element of form.elements) {
                    if (element.name) {
                        // Convert number fields from strings to numbers
                        if (element.type === 'range') {
                            formData[element.name] = parseFloat(element.value);
                        } else {
                            formData[element.name] = element.value;
                        }
                    }
                }
                return formData;
            }
            
            // Setup button handlers
            document.getElementById('saveButton').addEventListener('click', function() {
                const formData = collectFormData();
                this.textContent = "Saving...";
                
                // Convert the form data to a URL-encoded query string
                const params = Object.entries(formData).map(([key, value]) => {
                    return encodeURIComponent(key) + '=' + encodeURIComponent(value);
                }).join('&');
                
                // Navigate to the URL with properly encoded parameters
                window.location.href = 'hammerspoon://saveSettings?' + params;
            });
            
            document.getElementById('cancelButton').addEventListener('click', function() {
                this.textContent = "Closing...";
                window.location.href = 'hammerspoon://cancelSettings';
            });
            
            document.getElementById('resetButton').addEventListener('click', function() {
                this.textContent = "Resetting...";
                window.location.href = 'hammerspoon://resetSettings';
            });
            
            // Style buttons for better visibility
            document.querySelectorAll('button').forEach(button => {
                button.style.fontSize = '16px';
                button.style.padding = '10px 20px';
                button.style.cursor = 'pointer';
                button.style.boxShadow = '0 2px 4px rgba(0,0,0,0.2)';
                button.addEventListener('mouseover', function() {
                    this.style.opacity = '0.9';
                    this.style.transform = 'scale(1.05)';
                });
                button.addEventListener('mouseout', function() {
                    this.style.opacity = '1';
                    this.style.transform = 'scale(1)';
                });
                button.addEventListener('mousedown', function() {
                    this.style.transform = 'scale(0.98)';
                });
                button.addEventListener('mouseup', function() {
                    this.style.transform = 'scale(1)';
                });
            });
        </script>
    </body>
    </html>
    ]]
    
    -- We're using direct URL handlers, so we don't need a message callback function
    
    -- Set window appearance using the standard style constants
    settingsWebview:windowTitle("Mouse to ScrollBar Settings")
    settingsWebview:darkMode(false)
    
    -- Use the correct window style - these should be individual constants, not a table
    local style = hs.webview.windowMasks.titled | 
                  hs.webview.windowMasks.closable | 
                  hs.webview.windowMasks.resizable
    
    settingsWebview:windowStyle(style)
    settingsWebview:level(hs.drawing.windowLevels.floating)
    
    -- Set basic properties
    settingsWebview:allowNewWindows(false)
    settingsWebview:allowTextEntry(true)
    settingsWebview:deleteOnClose(true)
    
    -- Use a simpler approach - inject direct links into the HTML
    
    -- Create a local reference that will persist
    local currentWebview = settingsWebview

    -- Create a cleanup function to be called from URL handlers
    local function cleanupHandlers()
        -- Unbind all our URL handlers
        hs.urlevent.bind("saveSettings", nil)
        hs.urlevent.bind("cancelSettings", nil)
        hs.urlevent.bind("resetSettings", nil)
    end
    
    -- Register URL handlers for our button actions
    -- These handlers are bound to URL schemes that the webview will navigate to
    -- when the corresponding buttons are clicked
    hs.urlevent.bind("saveSettings", function(eventName, params)
        -- Create a logger for debugging purposes
        local logger = hs.logger.new("MoveMouseToScrollBar", "debug")
        
        -- Validate that we received parameters
        if not params then
            logger:e("No parameters received")
            hs.alert.show("Error: No settings data received")
            return
        end
        
        -- Log the raw parameters for debugging
        -- When a form submits via URL with query parameters, Hammerspoon automatically
        -- parses them into a table
        logger:d("Raw params received: " .. hs.inspect(params))
        
        -- Create a table to store our settings
        -- This will hold the parsed and validated settings before saving them
        local settings = {}
        
        -- Parse the form parameters directly
        for key, value in pairs(params) do
            -- Convert numeric values from strings to numbers
            if key == "checkInterval" or 
               key == "scrollBarOffset" or 
               key == "verticalPosition" or 
               key == "triggerZoneStart" or 
               key == "edgeBuffer" then
                settings[key] = tonumber(value)
            else
                settings[key] = value
            end
            
            logger:d("Parsed setting: " .. key .. " = " .. tostring(settings[key]))
        end
        
        if not settings or type(settings) ~= "table" then
            logger:e("Settings is not a valid table: " .. tostring(settings))
            hs.alert.show("Error: Settings data is not valid")
            return
        end
        
        -- Validate individual settings
        -- Define valid ranges for each numeric setting
        local validationRanges = {
            checkInterval = {min = 0.1, max = 10.0},
            scrollBarOffset = {min = 1, max = 200},
            verticalPosition = {min = 0.01, max = 0.99},
            triggerZoneStart = {min = 0.001, max = 0.9},
            edgeBuffer = {min = 0, max = 200}
        }
        
        -- Check that numeric values are within their allowed ranges
        local invalidSettings = {}
        for key, range in pairs(validationRanges) do
            if settings[key] ~= nil then
                if type(settings[key]) ~= "number" or settings[key] < range.min or settings[key] > range.max then
                    table.insert(invalidSettings, key .. " (must be between " .. range.min .. " and " .. range.max .. ")")
                    logger:e("Invalid setting: " .. key .. " = " .. tostring(settings[key]) .. " (range: " .. range.min .. "-" .. range.max .. ")")
                end
            end
        end
        
        -- Validate that disableKey is one of the allowed values
        if settings.disableKey and not hs.fnutils.contains({"fn", "cmd", "alt", "shift", "ctrl"}, settings.disableKey) then
            table.insert(invalidSettings, "disableKey (must be one of: fn, cmd, alt, shift, ctrl)")
            logger:e("Invalid setting: disableKey = " .. tostring(settings.disableKey))
        end
        
        -- Show error if validation failed
        if #invalidSettings > 0 then
            local msg = "Invalid settings: " .. table.concat(invalidSettings, ", ")
            logger:e(msg)
            hs.alert.show("Error: " .. msg)
            return
        end
        
        -- Print settings for debugging
        for k, v in pairs(settings) do
            logger:d("Setting: " .. k .. " = " .. tostring(v))
        end
        
        -- Check if all required settings are present
        local requiredKeys = {"disableKey", "checkInterval", "scrollBarOffset", 
                             "verticalPosition", "triggerZoneStart", "edgeBuffer"}
        local missingKeys = {}
        
        for _, key in ipairs(requiredKeys) do
            if settings[key] == nil then
                table.insert(missingKeys, key)
            end
        end
        
        if #missingKeys > 0 then
            local msg = "Missing settings: " .. table.concat(missingKeys, ", ")
            logger:e(msg)
            hs.alert.show("Error: " .. msg)
            return
        end
        
        -- All validation passed, update settings
        self:setConfig(settings)
        
        -- If timer is running, restart it with new interval
        if self.mouseMoveTimer then
            self.mouseMoveTimer:stop()
            self.mouseMoveTimer = hs.timer.doEvery(self.config.checkInterval, function() self:moveMouseToRight() end)
        end
        
        hs.alert.show("Settings saved")
        
        -- Clean up handlers
        cleanupHandlers()
        
        -- Close the webview (after a short delay to ensure alert is seen)
        hs.timer.doAfter(0.5, function()
            if currentWebview then currentWebview:delete() end
            
            -- If the spoon was running before we opened settings, restart the timer
            if wasRunning then
                self.mouseMoveTimer = hs.timer.doEvery(self.config.checkInterval, function() self:moveMouseToRight() end)
            end
        end)
    end)
    
    hs.urlevent.bind("cancelSettings", function()
        -- Clean up handlers
        cleanupHandlers()
        
        -- Close the webview
        if currentWebview then currentWebview:delete() end
        
        -- If the spoon was running before we opened settings, restart the timer
        if wasRunning then
            self.mouseMoveTimer = hs.timer.doEvery(self.config.checkInterval, function() self:moveMouseToRight() end)
        end
    end)
    
    hs.urlevent.bind("resetSettings", function()
        -- Reset to default settings
        self:setConfig(self.defaultConfig)
        
        -- Clean up handlers
        cleanupHandlers()
        
        -- Close current webview
        if currentWebview then currentWebview:delete() end
        
        -- If the spoon was running before we opened settings, restart the timer temporarily
        -- It will be stopped again when the new settings window opens
        if wasRunning then
            self.mouseMoveTimer = hs.timer.doEvery(self.config.checkInterval, function() self:moveMouseToRight() end)
        end
        
        -- Show the GUI again with default settings
        hs.timer.doAfter(0.3, function() 
            self:showConfigGUI() 
            hs.alert.show("Settings reset to defaults")
        end)
    end)
    
    -- Set up cleanup for URL handlers when webview is deleted
    -- We'll use the fact that handlers will be removed when the window closes
    
    -- Display the webview
    settingsWebview:html(html)
    settingsWebview:show()
    settingsWebview:bringToFront()
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
    
    -- Add settings GUI hotkey (Cmd+Alt+S)
    hs.hotkey.bind({"cmd", "alt"}, "M", function()
        self:showConfigGUI()
    end)

    -- Start the key watcher
    self.keyWatcher:start()
    
    -- Start the timer to check mouse position
    self.mouseMoveTimer = hs.timer.doEvery(self.config.checkInterval, function() self:moveMouseToRight() end)
    
    -- Update running state
    self.running = true
    
    -- Save running state to persist across Hammerspoon restarts
    hs.settings.set(self.settingsKey .. "_running", true)
    
    -- Update menubar icon and tooltip
    self:updateMenubarIcon()
    self:updateMenubarTooltip()
    
    hs.alert.show("Mouse to ScrollBar enabled (Cmd+Alt+S for settings)")
    return self
end

--- MoveMousetoScrollBar:stop()
--- Method
--- Stop the mouse positioning timer
function obj:stop()
    if self.mouseMoveTimer then self.mouseMoveTimer:stop() end
    if self.keyWatcher then self.keyWatcher:stop() end
    
    -- Update running state
    self.running = false
    
    -- Save running state to persist across Hammerspoon restarts
    hs.settings.set(self.settingsKey .. "_running", false)
    
    -- Update menubar icon and tooltip
    self:updateMenubarIcon()
    self:updateMenubarTooltip()
    
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
    local currentMousePosition = hs.mouse.absolutePosition()
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
    local currentMousePosition = hs.mouse.absolutePosition()

    -- Check if the mouse is beyond the trigger zone and hasn't moved manually
    if currentMousePosition.x > triggerZoneStart and not self:hasMouseMoved() then
        -- Only move the mouse if it's not already near the scrollbar
        if currentMousePosition.x < screenFrame.w - self.config.edgeBuffer then
            hs.mouse.absolutePosition(hs.geometry.point(
                screenFrame.w - self.config.scrollBarOffset, 
                screenFrame.h * self.config.verticalPosition
            ))
        end
    end

    -- Update the last known position
    self.lastMousePosition = hs.mouse.absolutePosition()
end

--- MoveMousetoScrollBar:updateMenubarIcon()
--- Method
--- Updates the menubar icon based on the current running state
function obj:updateMenubarIcon()
    if not self.menubar then return end
    
    if self.running then
        -- When enabled: Show a pointing hand cursor icon
        self.menubar:setIcon(hs.image.imageFromName("NSCursorPointingHand"))
    else
        -- When disabled: Show a "stopped" icon
        self.menubar:setIcon(hs.image.imageFromName("NSSharingServiceOff"))
    end
end

--- MoveMousetoScrollBar:updateMenubarTooltip()
--- Method
--- Updates the menubar tooltip text based on the current running state
function obj:updateMenubarTooltip()
    if not self.menubar then return end
    
    local status = self.running and "Enabled" or "Disabled"
    self.menubar:setTooltip("Mouse to ScrollBar: " .. status .. " (click to toggle)")
end

--- MoveMousetoScrollBar:autoStart()
--- Method
--- Automatically starts the spoon if it was running when Hammerspoon was last quit
--- This should be called after init() to restore previous state
function obj:autoStart()
    -- Register hotkeys
    hs.hotkey.bind({"cmd", "alt", "ctrl"}, "R", function()
        hs.reload()
        hs.alert.show("Config loaded")
    end)
    
    -- Add settings GUI hotkey (Cmd+Alt+S)
    hs.hotkey.bind({"cmd", "alt"}, "S", function()
        self:showConfigGUI()
    end)
    
    -- If the spoon was previously running, start it again
    if self.running then
        -- Start the key watcher
        self.keyWatcher:start()
        
        -- Start the timer to check mouse position
        self.mouseMoveTimer = hs.timer.doEvery(self.config.checkInterval, function() self:moveMouseToRight() end)
        
        -- Update menubar
        self:updateMenubarIcon()
        self:updateMenubarTooltip()
    end
    
    return self
end

return obj