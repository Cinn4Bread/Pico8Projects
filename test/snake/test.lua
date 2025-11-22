-- globals
x = 63
y = 63
aX = 63 
aY = 63
bX = 63
bY = 63

follow_frames_1 = 10
follow_frames_2 = 20

history = {}
max_frames = 30

local colors = {
  black = 0,
  dark_blue = 1,
  dark_purple = 2,
  dark_green = 3,
  brown = 4,
  dark_gray = 5,
  light_gray = 6,
  white = 7,
  red = 8,
  orange = 9,
  yellow = 10,
  green = 11,
  blue = 12,
  indigo = 13,
  pink = 14,
  peach = 15,
}

player = {
    x = 64,
    y = 64,
    radius = 5,
    speed = 1
}

function _update60()
add(history, {x=player.x, y=player.y})
if(#history > max_frames) then del(history, history[1]) end

if(#history > follow_frames_1) then
aX = history[#history-follow_frames_1].x
aY = history[#history-follow_frames_1].y
end

if(#history > follow_frames_2) then
bX = history[#history-follow_frames_2].x
bY = history[#history-follow_frames_2].y
end

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

player.x += pX * player.speed
player.y += pY * player.speed

player.x = mid(0, player.x, 128)
player.y = mid(0, player.y, 128) 
end

function _draw()
    cls(colors.white)
    circfill(bX, bY, player.radius, colors.blue)
    circfill(aX, aY, player.radius, colors.green)
    circfill(player.x, player.y, player.radius, colors.red)
end