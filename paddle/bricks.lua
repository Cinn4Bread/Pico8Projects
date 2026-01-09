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

function brickMove(paddle, ball)
    for brick in all(bricks) do
        if brick.active then
            -- move brick down by moveAmount
            brick.y += moveAmount
            -- check collision
            if collisionCheck(brick, paddle) then
                brickPaddleCollision(brick, paddle)
            end
            if collisionCheck(brick, ball) then
                brickBallCollision(brick, ball)
                break
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

function collisionCheck(brick, other)
    e1 = getEdges(brick)
    e2 = getEdges(other)

    if(e1.top > e2.bottom) then return false end 
    if(e2.top > e1.bottom) then return false end
    if(e1.left > e2.right) then return false end
    if(e2.left > e1.right) then return false end

    return true
end

function brickPaddleCollision(brick, paddle)
    local dX = paddle.x - brick.x
    local dY = paddle.y - brick.y
    
    local overlapX = (paddle.halfWidth + brick.halfWidth) - abs(dX) 
    local overlapY = (paddle.halfHeight + brick.halfHeight) - abs(dY) 

    if overlapX < overlapY then
        if dX > 0 then
            -- calculate where to push the paddle to once collision
            -- brick center + brick half width = right edge
            -- right edge + paddle half width = paddle left edge pushed to brick right edge  
            paddle.x = brick.x + brick.halfWidth + paddle.halfWidth 
            paddle.vX = 0
        else
            paddle.x = brick.x - brick.halfWidth - paddle.halfWidth 
            paddle.vX = 0
        end
    else
        if dY > 0 then 
            -- brick center + brick half height = bottom edge
            -- bottom edge + paddle half height = paddle top edge pushed to brick bottom edge
            paddle.y = brick.y + brick.halfHeight + paddle.halfHeight
        else
            paddle.y = brick.y - brick.halfHeight - paddle.halfHeight 
            paddle.vY = 0 
        end
    end
end

function brickBallCollision(brick, ball)
    local dY = ball.y - brick.y
    local dX = ball.x - brick.x
    
    local overlapX = (ball.halfWidth + brick.halfWidth) - abs(dX) 
    local overlapY = (ball.halfHeight + brick.halfHeight) - abs(dY) 

    if overlapX < overlapY then
        ball.vX = -ball.vX
        if dX > 0 then  
            ball.x = brick.x + brick.halfWidth + ball.halfWidth 
            del(bricks, brick)
            return
        else
            ball.x = brick.x - brick.halfWidth - ball.halfWidth 
            del(bricks, brick)
            return
        end
    else
        ball.vY = -ball.vY
        if dY > 0 then 
            ball.y = brick.y + brick.halfHeight + ball.halfHeight
            del(bricks, brick)
            return
        else
            ball.y = brick.y - brick.halfHeight - ball.halfHeight 
            del(bricks, brick)
            return
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