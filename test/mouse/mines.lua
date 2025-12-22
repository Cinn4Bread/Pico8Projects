mineList = {}
selectedMines = {}
greyFrameCount = 0
blueFrameCount = 0
redFrameCount = 0
spawnInterval = 120 
gameFrameCount = 0
blueThreshold = 3600
redThreshold = 7200

function checkMines(m)
    if boundingCol(m) == true then
        m.selected = true
        if m.color == "grey" then
            m.spr = 4
        elseif m.color == "blue" then
            m.spr = 6
        else
            m.spr = 8
        end
        add(selectedMines, m)
    else
        m.selected = false
        if m.color == "grey" then
            m.spr = 3
        elseif m.color == "blue" then
            m.spr = 5
        else
            m.spr = 7
        end
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

function spawnGreyMines()
    if greyFrameCount % spawnInterval == 1 then
        add(mineList, {
            x = mid(28, flr(rnd(100)), 100),
            y = mid(28, flr(rnd(100)), 100),
            spr = 3,
            selected = false,
            color = "grey"
            })
    end
    greyFrameCount += 1
end

function spawnBlueMines()
    if blueFrameCount % spawnInterval == 1 and gameFrameCount >= blueThreshold then
        add(mineList, {
            x = mid(28, flr(rnd(100)), 100),
            y = mid(28, flr(rnd(100)), 100),
            spr = 5,
            selected = false,
            color = "blue"
            })
    end
    blueFrameCount += 1
end

function spawnRedMines()
    if redFrameCount % spawnInterval == 1 and gameFrameCount >= redThreshold then
        add(mineList, {
            x = mid(28, flr(rnd(100)), 100),
            y = mid(28, flr(rnd(100)), 100),
            spr = 7,
            selected = false,
            color = "red"
            })
    end
    redFrameCount += 1
end