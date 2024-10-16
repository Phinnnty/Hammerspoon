local obj = {}
obj.__index = obj

-- Metadata
obj.name = "ConfigReloadAndAutoScroll"
obj.version = "1.0"
obj.author = "Fintan Molloy"
obj.homepage = "https://github.com/Phinnnty/Hammerspoon"
obj.license = "MIT - https://opensource.org/licenses/MIT"

function obj:init()
    self.lastMousePosition = hs.mouse.getAbsolutePosition()
    self.scrollSpeedY = -1
end

function obj:start()
    hs.hotkey.bind({"cmd", "alt", "ctrl"}, "R", function()
        hs.reload()
        hs.alert.show("Config loaded")
    end)

    self.mouseMoveTimer = hs.timer.doEvery(.375, function() self:moveMouseToRight() end)
    self.autoScrollTimer = hs.timer.doEvery(1, function() self:autoScroll() end)
end

function obj:stop()
    if self.mouseMoveTimer then self.mouseMoveTimer:stop() end
    if self.autoScrollTimer then self.autoScrollTimer:stop() end
end

function obj:hasMouseMoved()
    local currentMousePosition = hs.mouse.getAbsolutePosition()
    return not (currentMousePosition.x == self.lastMousePosition.x and currentMousePosition.y == self.lastMousePosition.y)
end

function obj:moveMouseToRight()
    local screenFrame = hs.screen.mainScreen():frame()
    local triggerZoneStart = screenFrame.w * (1/100)
    local currentMousePosition = hs.mouse.getAbsolutePosition()

    if currentMousePosition.x > triggerZoneStart and not self:hasMouseMoved() then
        if currentMousePosition.x < screenFrame.w - 40 then
            hs.mouse.setAbsolutePosition(hs.geometry.point(screenFrame.w - 25, screenFrame.h * 7/10))
        end
    end

    self.lastMousePosition = hs.mouse.getAbsolutePosition()
end

function obj:autoScroll()
    local mousePos = hs.mouse.getAbsolutePosition()
    local screenFrame = hs.screen.mainScreen():frame()
    local frontApp = hs.application.frontmostApplication()

    local triggerZone = {
        x = screenFrame.w * 0.8,
        y = screenFrame.h * 0.8
    }

    hs.console.printStyledtext("Mouse Position: X=" .. mousePos.x .. ", Y=" .. mousePos.y)
    hs.console.printStyledtext("Checking trigger zone: X=" .. triggerZone.x .. ", Y=" .. triggerZone.y)
    hs.console.printStyledtext("Frontmost app: " .. frontApp:name())

    if mousePos.x > triggerZone.x and mousePos.y > triggerZone.y then
        hs.console.printStyledtext("Mouse is in the trigger zone. Attempting to scroll...")
        hs.eventtap.scrollWheel({0, self.scrollSpeedY}, {}, "line")
    else
        hs.console.printStyledtext("Mouse is not in the trigger zone.")
    end
end

return obj
