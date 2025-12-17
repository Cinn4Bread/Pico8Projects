pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
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
    friction = .7
}

ball = {
    -- ball coordinates
    x = 63,
    y = 87,
    -- ball sprite
    spr = 4, 
    -- ball speed (unused for now, no ball movement yet)
    speed = 1
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

-- these values define the hitbox of the paddle
-- left edge, top edge, right edge, and bottom edge
-- calculated from the paddle's pivot point to match the offsets placed on the sprites (so the hitbox is properly centered)
local player_left = player.x - 12
local player_top = player.y - 3
local player_right = player.x + 12
local player_bottom = player.y + 3

-- same thing here, just for the ball sprite
local other_left = other.x - 3
local other_top = other.y - 3
local other_right = other.x + 3
local other_bottom = other.y + 3

-- if any of the paddle's edges don't intersect with any of the ball's edges, no collision 
if(player_top > other_bottom) then return false end 
if(other_top > player_bottom) then return false end
if(player_left > other_right) then return false end
if(other_left > player_right) then return false end

-- otherwise, collision
return true
end


__sfx__
05090020000500e00000000000520005200000000000305218620136200400000000000520005200050030500005003000040000005200052000000c0000c000196201962013000130001e6201e620130000e000
05090020000500e00000000000520005200000000000305218620136200400000000000520005200050030500005003000040000005200052000000c0000c000196201962013000130001300010000130000e000
010900200c5201c50012500125200c5202350011500115001152011520115200f520115201152011520135200c5200c5202450000500005002b5002b5002d5001f500215001f5000050028500245002850024500
0109002013124131211312013120161201810018100181241812218122181221812013120131201312011120131201312013120121200f1200f1200f1000c1000c1240c1200c1200c1200e1210f1220f1220f122
010900001312413120001001310013120131200010016124131201312013120181000c1200c1200f1201212112121131201312013120131201312013120111201112500100001000010000100001000010000100
010900001b1211b1211b1261b1271d125001000010018124181221812218122181221312113120121200f1201312013120121200e120111211112111120111201d1211d1201d1201d1201b1211b1211b1201b120
01090000181241812018100161001612116121161211812018122181221812212120111201112011120131200c1200c1200c1200c125000000000000000000000000000000000000000000000000000000000000
010900200c5201c50012500125200c5202350011500115001152011520115200f520115201152011520135200c5200c5202450000500005002b5002b5002d5000a5200a5200a5200a5200e5200e5200e5200e520
490900000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007001f5241f5211f5211b5201e5201e5221e52222522
4909000024514245102451024510185101851018510245102451024510245150c5000c5000c5000c5000050022512225122251222512185141851018512225122251222512225122251222511215112151221512
490900001f5141f5101f5101f5001d5111d5111f5001f5001f5101f5101f5101d5100000000000000001f5121f5121f5121f5101f5101f5101f51000000000000000000000000000000000000000000000000000
010900001b1211b1211b1261b1271d125001000010018100181221812218122181221312113120121200f1201312013120121200e120111211112111120111201f1211f1201f1201f1201b1211b1211b1201b120
490900001d5141d5101d5101d5101b5101b5101b5101b5101f5101f5101f5101f5101d5101d5101d5211f5221f5221f5221f522205201f5101f5101f510205112251122510225102251029524295222952229520
490900002b5202b5202b5202a5202952029520295202a520275102751027510245100000000000245212452124520245202452300000000000000000000000000000000000000000000000000000000000000000
__music__
01 01020344
00 01020444
00 01020544
00 00070608
00 01020309
00 0102040a
00 01020b0c
00 0002060d
00 01024744
02 00024344

