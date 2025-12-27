function Update_Menu()
    if btnp(4) and scene == "Menu" then
        scene = "Game"
    end
end

function Draw_Menu()
    cls(5)
    print("\^t\^wlava breakout", 13, 5, 8)

    print("gain points by:", 35, 30, 11)
    print("breaking bricks", 35, 40, 11)
    print("going up", 49, 50, 11)
    
    print("press z to start", 30, 120, 14)
end

function Update_Game()
    if btnp(5) and scene == "Game" then
        scene = "Menu"
    end 
end