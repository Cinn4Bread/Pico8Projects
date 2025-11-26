mouse = {
    sprNormal = 1,
    sprClick = 2,
    x = stat(32),
    y = stat(33),
    button = stat(34),
    dragging = false,
    movingMines = false
}

mineList = {}
selectedMines = {}

function _init()
    poke(0x5f2d, 1)
    initMouseX = 0
    initMouseY = 0

    for i = 1, 5 do
        add(mineList, {
            x = flr(rnd(120)),
            y = flr(rnd(120)),
            spr = 3, -- selected sprite is 4
            selected = false
            })
    end
end

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

function drawMines(m)
    local yOffset = 0
    if m.selected and mouse.movingMines == true then
        yOffset -= 2
    end
    spr(m.spr, m.x, m.y + yOffset)
end

function pointInMine(m)
    return mouse.x >= m.x and mouse.x <= m.x + 5 and mouse.y >= m.y and mouse.y <= m.y + 5
end

function _update60()
    mouse.x = stat(32)
    mouse.y = stat(33)
    mouse.button = stat(34) 

    if mouse.button == 1 and not mouse.dragging and not mouse.movingMines then
        local clickedSelected = false
        for m in all(selectedMines) do
            if(pointInMine(m)) then
                clickedSelected = true
                mouse.movingMines = true
                mouse.dragStartX = mouse.x
                mouse.dragStartY = mouse.y
                for mine in all(selectedMines) do
                    mine.dragStartX = mine.x
                    mine.dragStartY = mine.y
                end
                break
            end
        end
        
        if not clickedSelected then
            initMouseX = mouse.x
            initMouseY = mouse.y
            mouse.dragging = true
        end
            
    elseif mouse.button == 0 and mouse.dragging then
        selectedMines = {}
        foreach(mineList, checkMines)
        mouse.dragging = false

    elseif mouse.button == 0 and mouse.movingMines then
        mouse.movingMines = false
    end

    if mouse.movingMines then
        local deltaX = mouse.x - mouse.dragStartX
        local deltaY = mouse.y - mouse.dragStartY
        for m in all(selectedMines) do
            m.x = m.dragStartX + deltaX
            m.y = m.dragStartY + deltaY
        end
    end
end

function _draw()
    cls(6)
    foreach(mineList, drawMines)
    
    if mouse.dragging then
    	rect(initMouseX, initMouseY, mouse.x, mouse.y, 1)
        spr(mouse.sprClick, mouse.x, mouse.y)
    else
        spr(mouse.sprNormal, mouse.x, mouse.y)
    end

    local selectedCount = 0
    for m in all(mineList) do
        if m.selected then selectedCount += 1 end
    end

    print("mines selected", 6, 6, 0)
    print(selectedCount, 6, 16, 0)
end