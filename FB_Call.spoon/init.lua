local obj = {}
obj.__index = obj

-- Metadata
obj.name = "TabsAndEnter"
obj.version = "1.0"
obj.author = "Fintan Molloy"
obj.homepage = "https://github.com/Phinnnty/Hammerspoon"
obj.license = "MIT - https://opensource.org/licenses/MIT"

function obj:init()
    -- Initialization code
end

function obj:start()
    hs.hotkey.bind({"cmd", "alt"}, "T", function()
        for i = 1, 30 do
            hs.eventtap.keyStroke({}, "tab")
        end
        hs.eventtap.keyStroke({}, "return")
    end)
end

function obj:stop()
    -- Code to run when the Spoon stops
end

return obj
