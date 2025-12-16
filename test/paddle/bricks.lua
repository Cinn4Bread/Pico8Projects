bricks = {}
brickWidth = 8
brickHeight = 8
gridCols = 16  
gapChance = 0.3  
moveAmount = 0.5
frameCount = 0

function spawnBrickWave()
    for col = 0, gridCols - 1 do
        if rnd() > gapChance then
            local brick = {
                x = col * brickWidth,
                y = -brickHeight,
                active = true
            }
            add(bricks, brick)
        end
    end 
end

function updateBricks()
    for brick in all(bricks) do
        if brick.active then
            brick.y += moveAmount

            if brick.y > 128 then
            del(bricks, brick)
            end
        end
    end
end

function drawBricks()
    for brick in all(bricks) do
        if brick.active then
            rectfill(brick.x, brick.y, brick.x + brickWidth - 1, brick.y + brickHeight - 1, 8)
        end
    end
end