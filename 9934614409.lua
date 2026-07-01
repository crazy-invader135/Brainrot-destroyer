-- Ensure the module gives a clean execution environment
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Retrieve the initialized core frame from the boot loader environment
local Window = _G.WindowContext

-- Verify context exists before injecting the game modules
if not Window then
    warn("Execution halted: Parent Window context reference missing.")
    return
end

---------------------------------------------------------
-- TABS SETUP
---------------------------------------------------------
local GameTab = Window:CreateTab("Game")

---------------------------------------------------------
-- REMOTE CONFIGURATION
---------------------------------------------------------
local PurchaseEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("PurchaseUpgrade")
local RebirthEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("RequestRebirth")

-- Toggle States
local autoUpgradeJump = false
local autoUpgradeSpeed = false
local autoRebirth = false
local autoLevelUp = false

-- Auto Upgrade Jump Logic
GameTab:CreateToggle("Auto Upgrade Jump", false, function(state)
    autoUpgradeJump = state
    
    if autoUpgradeJump then
        task.spawn(function()
            while autoUpgradeJump do
                PurchaseEvent:FireServer("JumpPower", 10)
                task.wait(0.1)
            end
        end)
    end
end)

-- Auto Upgrade Speed Logic
GameTab:CreateToggle("Auto Upgrade Speed", false, function(state)
    autoUpgradeSpeed = state
    
    if autoUpgradeSpeed then
        task.spawn(function()
            while autoUpgradeSpeed do
                PurchaseEvent:FireServer("BikeSpeed", 10)
                task.wait(0.1)
            end
        end)
    end
end)

-- Auto Rebirth Logic (Fires Rebirth then Speed Upgrade)
GameTab:CreateToggle("Auto Rebirth", false, function(state)
    autoRebirth = state
    
    if autoRebirth then
        task.spawn(function()
            while autoRebirth do
                RebirthEvent:FireServer()
                PurchaseEvent:FireServer("BikeSpeed", 10)
                task.wait(0.1)
            end
        end)
    end
end)

-- Auto Level Up ClickDetector Spam (Matches Game Hierarchy)
GameTab:CreateToggle("Auto Level Up (Spam)", false, function(state)
    autoLevelUp = state
    
    if autoLevelUp then
        task.spawn(function()
            while autoLevelUp do
                local targetPlot = workspace:FindFirstChild("Plot_" .. LocalPlayer.Name)
                
                if targetPlot then
                    local buttonsFolder = targetPlot:FindFirstChild("Buttons")
                    if buttonsFolder then
                        -- Loop through all floor folders dynamically
                        for _, floor in ipairs(buttonsFolder:GetChildren()) do
                            if floor.Name:lower():find("floor") then
                                local levelFolder = floor:FindFirstChild("Level")
                                if levelFolder then
                                    -- Scan all children inside the Level folder
                                    for _, button in ipairs(levelFolder:GetChildren()) do
                                        if button.Name == "LevelUpButton" and button:IsA("BasePart") then
                                            local clickDetector = button:FindFirstChildOfClass("ClickDetector")
                                            if clickDetector then
                                                -- Instantly fire the click detector
                                                fireclickdetector(clickDetector, 0)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                task.wait(0.05) -- Fast loop delay for high-speed spamming
            end
        end)
    end
end)

---------------------------------------------------------
-- TELEPORT UTILITIES
---------------------------------------------------------

-- TP to End Button
GameTab:CreateButton("TP to End", function()
    local character = LocalPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    local endPart = workspace:FindFirstChild("ItemSpawns") and workspace.ItemSpawns:FindFirstChild("10")
    
    if rootPart and endPart and endPart:IsA("BasePart") then
        rootPart.CFrame = endPart.CFrame + Vector3.new(0, 3, 0)
    end
end)

-- TP to Spawn Button (Matches Exact Index Path)
GameTab:CreateButton("TP to Spawn", function()
    local character = LocalPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    
    local mapFolder = workspace:FindFirstChild("Map")
    if mapFolder and rootPart then
        local mapChildren = mapFolder:GetChildren()
        local parentPart = mapChildren[102]
        
        if parentPart then
            local subChildren = parentPart:GetChildren()
            local spawnTarget = subChildren[3]
            
            if spawnTarget and spawnTarget:IsA("BasePart") then
                rootPart.CFrame = spawnTarget.CFrame + Vector3.new(0, 3, 0)
            end
        end
    end
end)
