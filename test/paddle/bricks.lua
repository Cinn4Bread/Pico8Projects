bricks = {}
brickWidth = 16
brickHeight = 8
gridCols = 8  
gapChance = 0.5  
moveAmount = 0.5
frameCount = 0

function spawnBrickWave()
    for col = 0, gridCols - 1 do
        if rnd() > gapChance then
            local brick = {
                -- coordinates
                x = col * brickWidth + 8,
                y = -4,
                -- half widths/heights
                halfWidth = 8,
                halfHeight = 3,
                -- if this brick is active
                active = true
            }
            add(bricks, brick)
        end
    end 
end

function brickMove(other)
    for brick in all(bricks) do
        if brick.active then
            -- move brick down by moveAmount
            brick.y += moveAmount
            -- check collision
            if brickCollision(brick, other) then
                handleBrickCollision(brick, other)
            end
            -- remove if off screen
            if brick.y > 128 then
                del(bricks, brick)
            end
        end
    end     
end

function getEdges(obj)
    return {
        left = obj.x - obj.halfWidth,
        right = obj.x + obj.halfWidth,
        top = obj.y - obj.halfHeight,
        bottom = obj.y + obj.halfHeight
    }
end

function brickCollision(brick, other)
    e1 = getEdges(brick)
    e2 = getEdges(other)

    if(e1.top > e2.bottom) then return false end 
    if(e2.top > e1.bottom) then return false end
    if(e1.left > e2.right) then return false end
    if(e2.left > e1.right) then return false end

    return true
end

function handleBrickCollision(brick, other)
    local dX = other.x - brick.x
    local dY = other.y - brick.y
    
    local overlapX = (other.halfWidth + brick.halfWidth) - abs(dX) 
    local overlapY = (other.halfHeight + brick.halfHeight) - abs(dY) 

    if overlapX < overlapY then
        if dX > 0 then
            -- calculate where to push the paddle to once collision
            -- brick center + brick half width = right edge
            -- right edge + paddle half width = paddle left edge pushed to brick right edge  
            other.x = brick.x + brick.halfWidth + other.halfWidth 
            other.vX = 0
        else
            other.x = brick.x - brick.halfWidth - other.halfWidth 
            other.vX = 0
        end
    else
        if dY > 0 then 
            -- brick center + brick half height = bottom edge
            -- bottom edge + paddle half height = paddle top edge pushed to brick bottom edge
            other.y = brick.y + brick.halfHeight + other.halfHeight
        else
            other.y = brick.y - brick.halfHeight - other.halfHeight 
            other.vY = 0 
        end
    end
end

function drawBricks()
    for brick in all(bricks) do
        if brick.active then
            spr(5, brick.x - 8, brick.y - 4)
            spr(6, brick.x, brick.y - 4)
        end
    end
end