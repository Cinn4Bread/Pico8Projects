-- raw color values
-- black = 0
-- dark_blue = 1
-- dark_purple = 2
-- dark_green = 3
-- brown = 4
-- dark_gray = 5
-- light_gray = 6
-- white = 7
-- red = 8
-- orange = 9
-- yellow = 10
-- green = 11
-- blue = 12
-- indigo = 13
-- pink = 14
-- peach = 15

-- paddle variables
paddle = {
    x = 63,
    y = 90,
    spr1 = 1,
    spr2 = 2,
    spr3 = 3,
    speed = 1
}

-- ball variables
ball = {
    x = 63,
    y = 85,
    spr = 4, 
    speed = 1
}

-- 8 direction movement (normalized)
function paddleMove()
local pX = 0
local pY = 0

if(btn(0)) then pX -= 1.5 end
if(btn(1)) then pX += 1.5 end
if(btn(2)) then pY -= 1.5 end
if(btn(3)) then pY += 1.5 end

if(pX != 0 and pY != 0) then
pX *= 0.7
pY *= 0.7
end

paddle.x += pX * paddle.speed
paddle.y += pY * paddle.speed

paddle.x = mid(12, paddle.x, 116)
paddle.y = mid(0, paddle.y, 123) 
end

-- updates 60 frames per sec
function _update60()
paddleMove()
end

-- visuals
function _draw()
-- clear screen 
cls(5)

-- print paddle coordinates
print("paddle coords", 8, 10, 7)
print(paddle.x, 8, 18, 7)
print(paddle.y, 8, 26, 7)

-- draw player sprites
spr(paddle.spr1, paddle.x - 12, paddle.y)
spr(paddle.spr2, paddle.x - 4, paddle.y)
spr(paddle.spr3, paddle.x + 4, paddle.y)

-- draw ball sprite
spr(ball.spr, ball.x - 3, ball.y - 3)

end