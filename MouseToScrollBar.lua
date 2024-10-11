hs.hotkey.bind({"cmd", "alt", "ctrl"}, "R", function()

        hs.reload()

    end)

    hs.alert.show("Config loaded")

    -- Variable to store the last known position of the mouse

    local lastMousePosition = hs.mouse.getAbsolutePosition()

    -- Function to check if the mouse has moved

    local function hasMouseMoved()

        local currentMousePosition = hs.mouse.getAbsolutePosition()

        return not (currentMousePosition.x == lastMousePosition.x and currentMousePosition.y == lastMousePosition.y)

    end

    -- Function to move the mouse to the right-hand side of the screen, near the scrollbar

    local function moveMouseToRight()

        local screenFrame = hs.screen.mainScreen():frame()

        local triggerZoneStart = screenFrame.w * (1/100)

        local currentMousePosition = hs.mouse.getAbsolutePosition()

        -- Check if the mouse is in the trigger zone and hasn't moved

        if currentMousePosition.x > triggerZoneStart and not hasMouseMoved() then

            -- Check if not too close to the edge which might be the scrollbar

            if currentMousePosition.x < screenFrame.w - 40 then -- Assuming scrollbar is less than 20 pixels

                -- Move the mouse slightly away from the very edge to avoid the scrollbar

                hs.mouse.setAbsolutePosition(hs.geometry.point(screenFrame.w - 25, screenFrame.h * 7/10))

            end

        end

        -- Update the last mouse position to the current position

        lastMousePosition = hs.mouse.getAbsolutePosition()

    end

    -- Set up a timer to trigger every 5 seconds instead of 30 for quicker response

    mouseMoveTimer = hs.timer.doEvery(.375, moveMouseToRight)

-- Variable to control the scrolling speed and direction

local scrollSpeedY = -1 -- Adjusted for possibly more noticeable scrolling

-- Function to check the mouse position and scroll

local function autoScroll()

    local mousePos = hs.mouse.getAbsolutePosition()

    local screenFrame = hs.screen.mainScreen():frame()

    local frontApp = hs.application.frontmostApplication()

    -- Define the trigger zone

    local triggerZone = {

        x = screenFrame.w * 0.8,

        y = screenFrame.h * 0.8

    }

    -- Enhanced logging

    hs.console.printStyledtext("Mouse Position: X=" .. mousePos.x .. ", Y=" .. mousePos.y)

    hs.console.printStyledtext("Checking trigger zone: X=" .. triggerZone.x .. ", Y=" .. triggerZone.y)

    hs.console.printStyledtext("Frontmost app: " .. frontApp:name())

    -- Check if the mouse is in the trigger zone and log the attempt to scroll

    if mousePos.x > triggerZone.x and mousePos.y > triggerZone.y then

        hs.console.printStyledtext("Mouse is in the trigger zone. Attempting to scroll...")

        hs.eventtap.scrollWheel({0, scrollSpeedY}, {}, "line")

    else

        hs.console.printStyledtext("Mouse is not in the trigger zone.")

    end

end

-- Timer to run the autoScroll function every 0.5 seconds

local autoScrollTimer = hs.timer.doEvery(1, autoScroll)
 
