
-- globals
x = x or 63
y = y or 63

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
    radius = 5
}

function _init()
end

function _update60()
   
   if (btn(0)) then player.x=player.x-1.5 end
   if (btn(1)) then player.x=player.x+1.5 end
   if (btn(2)) then player.y=player.y-1.5 end
   if (btn(3)) then player.y=player.y+1.5 end

   player.x = mid(0, player.x, 128)
   player.y = mid(0, player.y, 128)
   
end

function _draw()
    cls(colors.brown)
    circfill(player.x, player.y, player.radius, colors.red)
end