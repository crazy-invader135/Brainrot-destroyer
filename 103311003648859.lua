local function getOrCreateWindow()
    if _G.LuckTestUIState and _G.LuckTestUIState.Window then
        return _G.LuckTestUIState.Window
    end

    if _G.WindowContext and type(_G.WindowContext.CreateTab) == "function" then
        _G.LuckTestUIState = _G.LuckTestUIState or {}
        _G.LuckTestUIState.Window = _G.WindowContext
        return _G.WindowContext
    end

    local success, lib = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/crazy-invader135/VeenzeGui/refs/heads/main/Lib.lua"))()
    end)

    if not success or not lib then
        warn("Failed to load UI library for Luck Test UI: " .. tostring(lib))
        return nil
    end

    _G.VeenzeLib = lib
    local window = lib:CreateWindow("Luck Test UI")
    _G.WindowContext = window
    _G.LuckTestUIState = _G.LuckTestUIState or {}
    _G.LuckTestUIState.Window = window
    return window
end

local Window = getOrCreateWindow()
if not Window then
    return
end

_G.LuckTestUIState = _G.LuckTestUIState or {}
if _G.LuckTestUIState.Initialized then
    return
end

_G.LuckTestUIState.Window = Window
local MainTab = _G.LuckTestUIState.MainTab or Window:CreateTab("Main")
_G.LuckTestUIState.MainTab = MainTab
_G.LuckTestUIState.Initialized = true

-- Configuration and State
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local remotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
local DoorEvent = remotesFolder and remotesFolder:FindFirstChild("DoorEvent")
local UpgradeBrainrotEvent = remotesFolder and remotesFolder:FindFirstChild("UpgradeBrainrotEvent")
local EnergyEvent = remotesFolder and remotesFolder:FindFirstChild("EnergyEvent")
local DamageEvent = remotesFolder and remotesFolder:FindFirstChild("DamageEvent")

if not DoorEvent or not UpgradeBrainrotEvent or not EnergyEvent or not DamageEvent then
    warn("Luck Test UI: required remotes were not found, so auto features were disabled.")
    MainTab:CreateButton("Required remotes missing", function()
    end)
    return
end

local farmLoopActive = false
local upgradeLoopActive = false
local collectLoopActive = false
local energyLoopActive = false
local godModeActive = false

-- Helper function to find your base dynamically
local function getMyBase()
    local basesFolder = Workspace:FindFirstChild("Bases")
    if not basesFolder then return nil end
    
    for _, base in ipairs(basesFolder:GetChildren()) do
        local display1 = base:FindFirstChild("BaseDisplay")
        if display1 then
            local display2 = display1:FindFirstChild("BaseDisplay")
            if display2 then
                return base
            end
        end
    end
    return nil
end

-- Auto Farm Loop
MainTab:CreateToggle("Auto Farm", false, function(Value)
    farmLoopActive = Value
    
    if farmLoopActive then
        task.spawn(function()
            while farmLoopActive do
                
                -- Loop the teleportation and remote spam exactly 5 times
                for cycle = 1, 5 do
                    if not farmLoopActive then break end
                    
                    -- 1. First Teleport player to workspace.StartPad.GuiPart
                    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                    local rootPart = character:FindFirstChild("HumanoidRootPart")
                    local targetPart = Workspace:FindFirstChild("StartPad") and Workspace.StartPad:FindFirstChild("GuiPart")
                    
                    if rootPart and targetPart then
                        rootPart.CFrame = targetPart.CFrame
                    end
                    
                    -- 2. Wait a second
                    task.wait(1.0)
                    
                    -- 3. Teleport again to ensure correct alignment/loading
                    character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                    rootPart = character:FindFirstChild("HumanoidRootPart")
                    if rootPart and targetPart then
                        rootPart.CFrame = targetPart.CFrame
                    end
                    task.wait(0.1)
                    
                    -- 4. Fire all the "add" remotes from 0.1 to 4.0
                    for i = 1, 40 do
                        if not farmLoopActive then break end
                        local val = i / 10
                        DoorEvent:FireServer(val, "add", nil)
                        task.wait(0.01)
                    end
                    
                    -- 5. Fire all the "mul" remotes from 1.1 to 2.0
                    for i = 11, 20 do
                        if not farmLoopActive then break end
                        local val = i / 10
                        DoorEvent:FireServer(val, "mul", nil)
                        task.wait(0.01)
                    end
                end
                
                -- Break out early if user turned toggle off mid-cycle
                if not farmLoopActive then break end
                
                -- 6. Wait for 3 seconds after the 5 loops are done
                task.wait(3.0)
                
                -- 7. Send the damage event
                if farmLoopActive then
                    local originalGodMode = godModeActive
                    godModeActive = false 
                    
                    DamageEvent:FireServer(85000000000)
                    
                    task.wait(0.05)
                    godModeActive = originalGodMode
                end
                
                -- 8. Wait for 1 second before starting the whole sequence again
                task.wait(1.0)
            end
        end)
    end
end)

MainTab:CreateToggle("Auto Upgrade", false, function(Value)
    upgradeLoopActive = Value
    
    if upgradeLoopActive then
        task.spawn(function()
            while upgradeLoopActive do
                local randomNum = math.random(1, 10)
                UpgradeBrainrotEvent:FireServer(randomNum)
                task.wait(0.1)
            end
        end)
    end
end)

MainTab:CreateToggle("Auto Collect", false, function(Value)
    collectLoopActive = Value
    
    if collectLoopActive then
        task.spawn(function()
            while collectLoopActive do
                local myBase = getMyBase()
                local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                
                if myBase and rootPart then
                    for _, child in ipairs(myBase:GetChildren()) do
                        local platforms = child:FindFirstChild("Platforms")
                        if platforms then
                            for _, platform in ipairs(platforms:GetChildren()) do
                                local collectPart = platform:FindFirstChild("Collect")
                                if collectPart then
                                    local touchInterest = collectPart:FindFirstChildWhichIsA("TouchTransmitter") or collectPart:FindFirstChild("TouchInterest")
                                    if touchInterest then
                                        firetouchinterest(rootPart, collectPart, 0)
                                        task.wait()
                                        firetouchinterest(rootPart, collectPart, 1)
                                    end
                                end
                            end
                        end
                    end
                end
                task.wait(0.5)
            end
        end)
    end
end)

MainTab:CreateToggle("Auto Energy", false, function(Value)
    energyLoopActive = Value
    
    if energyLoopActive then
        task.spawn(function()
            while energyLoopActive do
                EnergyEvent:FireServer(true, 2)
                EnergyEvent:FireServer()
                task.wait(0.1)
            end
        end)
    end
end)

MainTab:CreateToggle("God Mode (Block Damage)", false, function(Value)
    godModeActive = Value
end)

-- Metatable hook
local ok, rawmetatable = pcall(getrawmetatable, game)
if ok and rawmetatable then
    local oldNamecall = rawmetatable.__namecall
    setreadonly(rawmetatable, false)

    rawmetatable.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()

        if godModeActive and self == DamageEvent and (method == "FireServer" or method == "fireServer") then
            return nil
        end

        return oldNamecall(self, ...)
    end)

    setreadonly(rawmetatable, true)
end
