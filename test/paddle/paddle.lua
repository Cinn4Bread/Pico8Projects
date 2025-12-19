-- This script is just placeholder code to visualize what the game could start from
-- To help make understanding what's here easier, I've included explanations for everything via comments
-- I know Pico-8/Lua is completely different compared to Unity/Unreal, so I want to make learning things as we go as painless as possible. 
-- Feel free to ask questions (or offer feedback if something is wrong/could be improved), I'm always happy to discuss :)

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
    -- paddle base speed, acceleration, and friction
    speed = 1,
    accel = 0.5,
    friction = .7,
    -- half widths/heights
    halfWidth = 12,
    halfHeight = 4
}

ball = {
    -- ball coordinates
    x = 63,
    y = 87,
    -- ball sprite
    spr = 4, 
    -- ball speed (unused for now, no ball movement yet)
    speed = 1,
    -- half widths/heights
    halfWidth = 3,
    halfHeight = 2
}

-- 8 direction movement (normalized)
function paddleMove()

-- previous point in space before collision, used later
local preCollideX = paddle.x;
local preCollideY = paddle.y;

-- target velocity
local targetVX = 0
local targetVY = 0

-- read input and update target velocity
if(btn(0)) then targetVX -= 1.7 end
if(btn(1)) then targetVX += 1.7 end
if(btn(2)) then targetVY -= 1.7 end
if(btn(3)) then targetVY += 1.7 end

-- normalize diagonal speed if the target x and y values are both being changed (moving diagonally)
-- because of pythagorean's theorem, moving diagonally would normally mean you'd move 1.4x faster
-- multiplying the target velocity x and y by 0.7 (roughly 1/sqrt(2)) keeps diagonal speed equal to cardinal movement
if(targetVX != 0 and targetVY != 0) then
targetVX *= 0.7
targetVY *= 0.7
end

-- smoothly ramp up actual velocity values to match targets
-- say targetVX was 1.7, paddle.vX was 0 and accel was 0.3
-- targetVX - paddle.vX calculates the "distance" between the target velocity and the current velocity
-- every frame, this value is multiplied by accel (0.3) to get a smaller "step" (value) towards the target 
-- that smaller step is what is then added to the paddle's actual velocity, which results in a smooth ramping up of velocity over time
paddle.vX += (targetVX - paddle.vX) * paddle.accel
paddle.vY += (targetVY - paddle.vY) * paddle.accel

-- apply friction to slow the paddle down if no input
-- paddle velocity is multiplied by friction every frame (small value, 0.85 to start) which gradually decreases both until they're basically zero
if targetVX == 0 then paddle.vX *= paddle.friction end
if targetVY == 0 then paddle.vY *= paddle.friction end

-- apply movement to paddle coordinates using calculated velocity values times base speed
paddle.x += paddle.vX * paddle.speed
paddle.y += paddle.vY * paddle.speed

-- clamp paddle movement to screen
paddle.x = mid(12, paddle.x, 116)
paddle.y = mid(3, paddle.y, 125) 

-- collision handling, lots of math
-- don't be intimidated by the amount of comments, lol
if(collision(paddle, ball)) then

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
-- for overlapX, the 15 comes from the half-widths (in pixels) of the paddle and ball added together (12 + 3 = 15)
-- we get the absolute value (abs) of dX to get the amount of pixels apart their centers are
-- and finally, 15 minus abs(dX) equals the amount of overlap in pixels on the X-axis

local overlapX = 15 - abs(dX)

-- same logic for overlapY, so:
-- half-heights of both sprites (4 + 3 = 7)
-- the amount of pixels apart the two centers are (abs(dY))
-- finally, 7 minus abs(dY) equals the amount of overlap in pixels on the Y-axis

local overlapY = 7 - abs(dY)

-- now, we check if the overlap on the X-axis is less than the overlap on the Y-axis
-- whichever axis has the smaller overlap is the one actually colliding with the other object (in this case, the ball)
-- separating the checks based on the difference in overlap allows the paddle to "slide" along the edge of an object while also holding towards it
-- without doing this, any of either the X-axis and Y-axis checks for stopping the paddle's velocity could both trigger at once, 
-- causing unnecessary stops in the paddle's movement when triggering just one of the checks on either axis would have been more appropriate
if(overlapX < overlapY) then

-- if dX is negative (left of ball) and paddle.vX is positive (moving right), stop X-axis velocity
if dX < 0 and paddle.vX > 0 then 
paddle.vX = 0
paddle.x = preCollideX -- snap paddle.x back to previous position to prevent visual overlap
end

-- if dX is positive (right of ball) and paddle.vX is negative (moving left), stop X-axis velocity
if dX > 0 and paddle.vX < 0 then 
paddle.vX = 0 
paddle.x = preCollideX -- snap paddle.x back to previous position to prevent visual overlap
end
 
else -- same thing but for when the overlap on the Y-axis is smaller than the X-axis

-- if dY is negative (above ball) and paddle.vY is positive (moving down), stop Y-axis velocity
if dY < 0 and paddle.vY > 0 then 
paddle.vY = 0 
paddle.y = preCollideY -- snap paddle.y back to previous position to prevent visual overlap
end

-- if dY is positive (below ball) and paddle.vY is negative (moving up), stop Y-axis velocity
if dY > 0 and paddle.vY < 0 then 
paddle.vY = 0 
paddle.y = preCollideY -- snap paddle.y back to previous position to prevent visual overlap
end

end
end
end

-- AABB (axis-aligned bounding box) collision detection
-- returns false if the edges of two hitboxes won't overlap, true otherwise
function collision(player,other)
    -- get collision edges
    e1 = getEdges(player)
    e2 = getEdges(other)

    -- if any of the paddle's edges don't intersect with any of the ball's edges, no collision 
    if(e1.top > e2.bottom) then return false end 
    if(e2.top > e1.bottom) then return false end
    if(e1.left > e2.right) then return false end
    if(e2.left > e1.right) then return false end

    -- otherwise, collision
    return true
end

-- calculate an object's collision edges
function getEdges(obj)
    return {
        left = obj.x - obj.halfWidth,
        right = obj.x + obj.halfWidth,
        top = obj.y - obj.halfHeight,
        bottom = obj.y + obj.halfHeight
    }
end