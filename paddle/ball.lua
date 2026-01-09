ball = {
    -- ball coordinates
    x = 63,
    y = 87,
    -- ball velocity
    vX = -1,
    vY = 1,
    -- ball sprite
    spr = 4, 
    -- ball speed, accel
    speed = 1,
    acceleration = 0.5,
    -- half widths/heights (for collision)
    halfWidth = 3,
    halfHeight = 2,
    -- collision cooldown
    collisionTimer = 0,
    collisionCD = 2
}

function ballMove(paddle)

    ball.x += ball.vX * ball.speed
    ball.y += ball.vY * ball.speed

    if ball.x < 3 then ball.vX = -ball.vX end
    if ball.y < 3 then ball.vY = -ball.vY end
    if ball.x > 125 then ball.vX = -ball.vX end
    if ball.y > 125 then ball.vY = -ball.vY end

    -- clamp ball to screen
    ball.x = mid(3, ball.x, 125)
    ball.y = mid(3, ball.y, 125)

    if(collisionCheck(ball, paddle)) then
        handleBallCollision(paddle)
    end
end

function collisionCheck(ball, other)
    e1 = getEdges(ball)
    e2 = getEdges(other)

    if(e1.top > e2.bottom) then return false end 
    if(e2.top > e1.bottom) then return false end
    if(e1.left > e2.right) then return false end
    if(e2.left > e1.right) then return false end

    return true
end

-- collision handling for ball/paddle
function handleBallCollision(paddle)

    local paddleEdges = getEdges(paddle)

    -- works similar to collision handling in paddleMove()
    if ball.collisionTimer <= 0 then

        -- start cooldown timer
        ball.collisionTimer = ball.collisionCD

        local dX = ball.x - paddle.x
        local dY = ball.y - paddle.y 

        local overlapX = (paddle.halfWidth + ball.halfWidth) - abs(dX)
        local overlapY = (paddle.halfHeight + ball.halfHeight) - abs(dY)

        -- push ball away from paddle to prevent ball from phasing through it
        if overlapX < overlapY then
            -- reverse ball x velocity when hitting paddle sides 
            ball.vX = -ball.vX
            if dX < 0 then 
                ball.x = paddleEdges.left - ball.halfWidth
            else
                ball.x = paddleEdges.right + ball.halfWidth
            end
        else
            -- reverse ball y velocity when hitting paddle top or bottom
            ball.vY = -ball.vY
            if dY < 0 then
                ball.y = paddleEdges.top - ball.halfHeight
            else
                ball.y = paddleEdges.bottom + ball.halfHeight
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

-- technically the collision handling in ballCollision already fixes the jitters but this is just here for edge cases
function ballCollisionCDTimer()
    if ball.collisionTimer > 0 then
        ball.collisionTimer -= 1
    end
end
