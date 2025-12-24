greyContainer = {
    x = 60,
    y = 60,
    sprClosed = 9,
    sprOpen = 10,
    active = true
}

blueContainer = {
    x = 0,
    y = 0,
    sprClosed = 11,
    sprOpen = 12,
    active = false
}

redContainer = {
    x = 0,
    y = 0,
    sprClosed = 13,
    sprOpen = 14,
    active = false
}

containerList = {greyContainer}

function drawContainers()
    for c in all(containerList) do
        if mouseTouchingObj(c) and mouse.movingMines then
            spr(c.sprOpen, c.x, c.y)
        else
            spr(c.sprClosed, c.x, c.y)
        end
    end
end