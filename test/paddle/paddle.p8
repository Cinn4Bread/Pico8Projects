pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
#include paddle.lua
#include bricks.lua

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

-- worth noting: any code that needs to be run in these two functions (update60 and draw) have to be called in the main p8 file
-- otherwise things break

function _update60() 
    updateBricks()
    paddleMove()
    ballMove()
    
    -- wait 3 seconds before spawning each wave
    if frameCount % 180 == 1 then
        spawnBrickWave()
    end
    frameCount += 1 

    -- ball collision cooldown timer
    ballCollisionCDTimer()
end

function _draw() 
    -- clears screen and sets background color
    cls(5)

    -- print paddle coordinates
    print("paddle coords", 8, 10, 7)
    print(paddle.x, 8, 18, 7)
    print(paddle.y, 8, 26, 7)
    -- message to confirm bricks.lua is working
    print("brick.lua working", 8, 34, 7)
    
    -- draw player sprites
    -- offset them so they center on the paddle's pivot point
    spr(paddle.spr1, paddle.x - 12, paddle.y - 4)
    spr(paddle.spr2, paddle.x - 4, paddle.y - 4)
    spr(paddle.spr3, paddle.x + 4, paddle.y - 4)
    
    -- draw ball sprite
    -- offset to center on pivot point, same as player sprites
    spr(ball.spr, ball.x - 4, ball.y - 4)

    -- draw "bricks"
    drawBricks()
end

__gfx__
00000000000000000000000000000000000000008888888800000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000dddddd0dddddddd0dddddd000aaaa008888888800000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700d666666d66666666d666666d0a77aaa08888888800000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000d777777d77777777d777777d0a7aaaa08888888800000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000d777777d77777777d777777d0aaaa9a08888888800000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700d666666d66666666d666666d0aaa99a08888888800000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000dddddd0dddddddd0dddddd000aaaa008888888800000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000002222222200000000000000000000000000000000000000000000000000000000000000000000000000000000
