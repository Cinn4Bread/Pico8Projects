mouse = {
    sprNormal = 1,
    sprClick = 2,
    x = stat(32),
    y = stat(33),
    button = stat(34),
    dragging = false,
    clickedSingle = false,
    clickedSelected = false,
    movingMines = false
}

mineList = {}
selectedMines = {}

function _init()

    -- enables the mouse during gameplay
    poke(0x5f2d, 1)
    initMouseX = 0
    initMouseY = 0

    -- generate 5 mines in random locations on screen (clamped within range)
    for i = 1, 5 do
        add(mineList, {
            x = mid(28, flr(rnd(100)), 100),
            y = mid(28, flr(rnd(100)), 100),
            spr = 3, -- selected sprite is 4
            selected = false
            })
    end
end

-- AABB collision detection between the bounding box and the mines
function boundingCol(mine)
    if mouse.dragging then
        local boundingLEFT = min(initMouseX, mouse.x)
        local boundingRIGHT = max(initMouseX, mouse.x)
        local boundingTOP = min(initMouseY, mouse.y)
        local boundingBOTTOM = max(initMouseY, mouse.y)

        local mineLEFT = mine.x
        local mineTOP = mine.y
        local mineRIGHT = mine.x + 5
        local mineBOTTOM = mine.y + 5

        if(boundingTOP > mineBOTTOM) then return false end 
        if(mineTOP > boundingBOTTOM) then return false end
        if(boundingLEFT > mineRIGHT) then return false end
        if(mineLEFT > boundingRIGHT) then return false end
        return true
    else
        return false
    end
end

function checkMines(m)
    if boundingCol(m) == true then
        m.selected = true
        m.spr = 4
        add(selectedMines, m)
    else
        m.selected = false
        m.spr = 3
    end
end

-- draw mine
-- if the mine is currently selected and the player is moving mines, apply y-offset of 2 pixels to imitate "floating" behavior 
function drawMines(m)
    local yOffset = 0
    if m.selected and mouse.movingMines == true then
        yOffset -= 2
    end
    spr(m.spr, m.x, m.y + yOffset)
end

-- check if mouse is touching the given sprite
function mouseTouchingMine(m)
    return mouse.x >= m.x and mouse.x <= m.x + 5 and mouse.y >= m.y and mouse.y <= m.y + 5
end

function _update60()

    -- stat(32) and stat(33) return the mouse's x and y values, and stat(34) returns a 0-1 value controlled by LMB
    mouse.x = stat(32)
    mouse.y = stat(33)
    mouse.button = stat(34) 

    -- check if clicking on selected mine
    if mouse.button == 1 and not mouse.dragging and not mouse.movingMines then
        mouse.clickedSelected = false
        for m in all(selectedMines) do
            if(mouseTouchingMine(m)) then
                mouse.clickedSelected = true
                mouse.movingMines = true
                mouse.dragStartX = mouse.x
                mouse.dragStartY = mouse.y
                for mine in all(selectedMines) do
                    mine.dragStartX = mine.x
                    mine.dragStartY = mine.y
                end
                return
            end
        end
        
        -- if not clicking selected mine, check every mine to see which one was clicked (for single drag)
        if not mouse.clickedSelected then
            mouse.clickedSingle = false
            for m in all(mineList) do
                if(mouseTouchingMine(m)) then
                    for k in all(selectedMines) do
                        k.selected = false
                        k.spr = 3
                    end
                    selectedMines = {}
                    add(selectedMines, m)
                    m.selected = true
                    mouse.clickedSingle = true
                    mouse.movingMines = true
                    mouse.dragStartX = mouse.x
                    mouse.dragStartY = mouse.y
                    m.dragStartX = m.x
                    m.dragStartY = m.y
                    return
                end
            end
        end

        -- if no mine was clicked, start bounding box
        if not mouse.clickedSingle and not mouse.clickedSelected then
            initMouseX = mouse.x
            initMouseY = mouse.y
            mouse.dragging = true
            foreach(mineList, checkMines)
        end
    
    -- deselect any selected mines and update status of all mines while dragging bounding box 
    elseif mouse.button == 1 and mouse.dragging then
        selectedMines = {}
        foreach(mineList, checkMines)
    
    -- stop dragging bounding box
    elseif mouse.button == 0 and mouse.dragging then
        mouse.dragging = false

    -- put down all mines being moved by player when they stop holding down LMB
    elseif mouse.button == 0 and mouse.movingMines then
        mouse.movingMines = false

        -- 
        if mouse.clickedSingle then
            selectedMines = {}
            foreach(mineList, checkMines)
        end
    end

    -- update all selected mine locations to move with the mouse 
    if mouse.movingMines then
        -- amount to move mine based on how far the mouse moved from its starting position
        local deltaX = mouse.x - mouse.dragStartX
        local deltaY = mouse.y - mouse.dragStartY
        -- add that amount to starting positions of all selected mines and then apply the 
        -- result to their actual X and y values to move them with the mouse
        for m in all(selectedMines) do
            m.x = m.dragStartX + deltaX
            m.y = m.dragStartY + deltaY
        end
    end
end

function _draw()
    cls()
    foreach(mineList, drawMines)
    
    if mouse.dragging and not mouse.clickedSingle then
    	rect(initMouseX, initMouseY, mouse.x, mouse.y, 7)
        spr(mouse.sprClick, mouse.x - 1, mouse.y)
    else
        spr(mouse.sprNormal, mouse.x - 1, mouse.y)
    end

    local selectedCount = 0
    for m in all(mineList) do
        if m.selected then selectedCount += 1 end
    end

    print("mines selected", 6, 6, 6)
    print(selectedCount, 6, 16, 6)
end