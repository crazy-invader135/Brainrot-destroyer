-- Initialize the core UI library
local VeenzeLib
local success, err = pcall(function()
    VeenzeLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/crazy-invader135/VeenzeGui/main/Lib.lua"))()
end)

if not success or not VeenzeLib then
    warn("Failed to load UI library: " .. tostring(err))
    return
end

local Window = VeenzeLib:CreateWindow("Brainrot killer")

-- Configuration Table mapping Place IDs to standalone source loadstrings
local SupportedGames = {
    [136919941417380] = "https://raw.githubusercontent.com/crazy-invader135/Brainrot-destroyer/main/136919941417380.lua",
}

local CurrentPlaceId = game.PlaceId

if SupportedGames[CurrentPlaceId] then
    -- 1. Pass the initialized Window context to a global variable
    _G.WindowContext = Window
    
    -- 2. Fetch and execute the game-specific standalone script
    local success, err = pcall(function()
        loadstring(game:HttpGet(SupportedGames[CurrentPlaceId]))()
    end)
    
    if not success then
        warn("Failed to load game script: " .. tostring(err))
    end
else
    -- Fallback: Display an unsupported error tab if the Place ID isn't registered
    local ErrorTab = Window:CreateTab("Unsupported")
    ErrorTab:CreateButton("this game isnt supported doofus", function()
        -- Optional fallback action
    end)
end

-- Establish global interface metadata elements
Window:CreateSupportedGamesTab({
    {name = "Bike obby for brainrots", status = "green", placeId = 136919941417380},
})

Window:SetCredits("Credits:\n\nUI lib made by: Veenze\n\nScript compiler: Developer")
