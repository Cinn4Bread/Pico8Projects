function Update_Menu()
    if btnp(4) and scene == "Menu" then
        scene = "Game"
    end
end

function Draw_Menu()
    cls(5)
    print("MAIN MENU", 63, 63, 7)
end

function Update_Game()
    if btnp(5) and scene == "Game" then
        scene = "Menu"
    end 
end