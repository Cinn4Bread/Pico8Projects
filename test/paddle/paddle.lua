paddle = {
    -- paddle coordinates
    x = 63,
    y = 93,
    -- paddle velocity
    vX = 0,
    vY = 0,
    -- paddle sprites (left, center, right)
    spr1 = 1,
    spr2 = 2,
    spr3 = 3,
    -- paddle move amount, base speed, acceleration, and velocity retention
    moveAmount = 1,
    speed = 0.5,
    accel = 0.3,
    velocityRetention = 0.8,
    -- half widths/heights (for collision)
    halfWidth = 12,
    halfHeight = 4,
    -- for preventing visual overlap with the ball
    preCollideX = 0,
    preCollideY = 0
}

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

function ballMove()

    ball.x += ball.vX * ball.speed
    ball.y += ball.vY * ball.speed

    if ball.x < 3 then ball.vX = -ball.vX end
    if ball.y < 3 then ball.vY = -ball.vY end
    if ball.x > 125 then ball.vX = -ball.vX end
    if ball.y > 125 then ball.vY = -ball.vY end

    -- clamp ball to screen
    ball.x = mid(3, ball.x, 125)
    ball.y = mid(3, ball.y, 125)

end

-- 8 direction movement (normalized)
function paddleMove()

    -- previous point in space before collision, used later
    paddle.preCollideX = paddle.x;
    paddle.preCollideY = paddle.y;

    -- for storing input direction
    -- acts as a buffer between the player inputting a direction -> applying that input to movement
    local inputX = 0
    local inputY = 0

    -- read input and update directional values
    if(btn(0)) then inputX -= 1 end
    if(btn(1)) then inputX += 1 end
    if(btn(2)) then inputY -= 1 end
    if(btn(3)) then inputY += 1 end

    -- normalize the direction values if moving diagonally 
    -- because of pythagorean's theorem, moving diagonally would normally mean you'd move 1.4x faster
    -- multiplying the direction x and y values by 0.7 (roughly 1/sqrt(2)) keeps diagonal speed equal to cardinal movement
    -- we do this to the directional values instead of the velocity itself to stray away from unpredictable behavior in movement 
    if(inputX != 0 and inputY != 0) then
        inputX *= 0.7
        inputY *= 0.7
    end

    -- apply directional values to velocity times the paddle move amount
    paddle.vX += inputX * paddle.moveAmount
    paddle.vY += inputY * paddle.moveAmount

    -- apply velocity retention to paddle velocity
    -- velocity is multiplied by velocityRetention every frame when not inputting a direction to slow the paddle down to a stop
    -- imagine a leak in velocity over time:
    -- frame 1, player is inputting a direction: let's say velocity is 10
    -- frame 2, player has stopped inputting a direction: velocity (10) times velocityRetention (0.8) = 8
    -- on frame 2, 80% velocity is retained while 20% is lost
    -- repeat on every frame until velocity is basically zero 
    paddle.vX *= paddle.velocityRetention
    paddle.vY *= paddle.velocityRetention

    -- apply movement to paddle coordinates using calculated velocity values times base speed
    paddle.x += paddle.vX * paddle.speed
    paddle.y += paddle.vY * paddle.speed

    -- clamp paddle movement to screen
    paddle.x = mid(12, paddle.x, 116)
    paddle.y = mid(3, paddle.y, 125) 

    -- collision handling with the ball
    if(collision(paddle, ball)) then
        handlePaddleCollision(paddle, ball)
        handleBallCollision(paddle)
    end
end

-- AABB (axis-aligned bounding box) collision detection
-- returns false if the edges of two hitboxes won't overlap, true otherwise
function collision(paddle, ball)
    -- get collision edges
    e1 = getEdges(paddle)
    e2 = getEdges(ball)

    -- if any of the paddle's edges don't intersect with any of the ball's edges, no collision 
    if(e1.top > e2.bottom) then return false end 
    if(e2.top > e1.bottom) then return false end
    if(e1.left > e2.right) then return false end
    if(e2.left > e1.right) then return false end

    -- otherwise, collision
    return true
end

function handlePaddleCollision(paddle, ball)
    
    -- if dX is negative, paddle is to the left of ball
    -- if dX is positive, paddle is to the right of ball
    -- if dY is negative, paddle is above the ball
    -- if dY is positive, paddle is below the ball

    local dX = paddle.x - ball.x
    local dY = paddle.y - ball.y  

    -- same idea applies to paddle velocity
    -- if paddle.vX is negative, paddle is moving left
    -- if paddle.vX is positive, paddle is moving right
    -- if paddle.vY is negative, paddle is moving up
    -- if paddle.vY is positive, paddle is moving down

    -- calculate how much overlap on each axis
    -- for overlapX, we first add the half-widths of both sprites together (12 + 3 = 15)
    -- then we get the absolute value (abs) of dX to get the amount of pixels apart their centers are
    -- and finally, 15 minus abs(dX) equals the amount of overlap in pixels on the X-axis

    local overlapX = (paddle.halfWidth + ball.halfWidth) - abs(dX)

    -- same logic for overlapY, so:
    -- half-heights of both sprites (4 + 3 = 7)
    -- the amount of pixels apart the two centers are (abs(dY))
    -- finally, 7 minus abs(dY) equals the amount of overlap in pixels on the Y-axis

    local overlapY = (paddle.halfHeight + ball.halfHeight) - abs(dY)

    -- now, we check if the overlap on the X-axis is less than the overlap on the Y-axis
    -- whichever axis has the smaller overlap is the one actually colliding with the other object (in this case, the ball)
    -- separating the checks based on the difference in overlap allows the paddle to "slide" along the edge of an object while also holding towards it
    -- without doing this, any of either the X-axis and Y-axis checks for stopping the paddle's velocity could both trigger at once, 
    -- causing unnecessary stops in the paddle's movement when triggering just one of the checks on either axis would have been more appropriate
    if(overlapX < overlapY) then
            
        -- if dX is negative (left of ball) and paddle.vX is positive (moving right), stop X-axis velocity
        if dX < 0 and paddle.vX > 0 then 
            paddle.vX = 0
            paddle.x = paddle.preCollideX -- snap paddle.x back to previous position to prevent visual overlap
        end
        
        -- if dX is positive (right of ball) and paddle.vX is negative (moving left), stop X-axis velocity
        if dX > 0 and paddle.vX < 0 then 
            paddle.vX = 0 
            paddle.x = paddle.preCollideX -- snap paddle.x back to previous position to prevent visual overlap
        end
 
    else -- same thing but for when the overlap on the Y-axis is smaller than the X-axis

        -- if dY is negative (above ball) and paddle.vY is positive (moving down), stop Y-axis velocity
        if dY < 0 and paddle.vY > 0 then 
            paddle.vY = 0 
            paddle.y = paddle.preCollideY -- snap paddle.y back to previous position to prevent visual overlap
        end

        -- if dY is positive (below ball) and paddle.vY is negative (moving up), stop Y-axis velocity
        if dY > 0 and paddle.vY < 0 then 
            paddle.vY = 0 
            paddle.y = paddle.preCollideY -- snap paddle.y back to previous position to prevent visual overlap
        end
    end
end

-- modified this to match architecture of existing collision function 
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

-- calculate an object's collision edges
function getEdges(obj)
    return {
        -- either add or subtract a sprite's half-width or height to the sprite's x/y (center)
        -- to find the sprite's left, right, top, and bottom edges.
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