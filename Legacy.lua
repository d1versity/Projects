-- Fetch Libraries from GitHub
local Rayflare = loadstring(game:HttpGet("https://raw.githubusercontent.com/d1versity/Rayflare/refs/heads/main/Library.lua"))()
local WindUI   = loadstring(game:HttpGet("https://raw.githubusercontent.com/d1versity/Wind/refs/heads/main/Library.lua"))()
local Zeta     = loadstring(game:HttpGet("https://raw.githubusercontent.com/d1versity/Zeta/refs/heads/main/Library.lua"))()

-- Configure Default States for Rayflare
Rayflare.Settings.FOV.Radius = 50
Rayflare.Settings.TriggerBot = Rayflare.Settings.TriggerBot or {
    Enabled = false,
    Mode = "Camera",
    TriggerKey = Enum.UserInputType.MouseButton2,
    TriggerMode = "Hold",
    IsAiming = false,
    Delay = 0,
    WallCheck = { Enabled = true }
}

-- Configure Default States for Zeta
Zeta.Settings.MaxDistance = 400
Zeta.Settings.Enabled = false
Zeta.Settings.Chams.Enabled = false
Zeta.Settings.Box.Enabled = false
Zeta.Settings.Text.Enabled = false
Zeta.Settings.Text.UseDisplayName = false 
Zeta.Settings.Tracers.Enabled = false
Zeta.Settings.Tracers.Origin = "Top"
Zeta.Settings.Box.HeadCircle.Enabled = false
Zeta.Settings.HealthBar.Enabled = false

-- Initialize Background Engines
Rayflare:Load()
Zeta:Load()

-- Absolute Force-Hide for Zeta's Default "Label" Drawings
game:GetService("RunService").RenderStepped:Connect(function()
    if Zeta and Zeta.Cache then
        for _, espObj in pairs(Zeta.Cache) do
            if not espObj.DrawingsVisible then
                for _, drawing in pairs(espObj.Drawings) do
                    drawing.Visible = false
                    if drawing.Position then
                        drawing.Position = Vector2.new(-9999, -9999)
                    end
                end
            end
        end
    end
end)

-- ========================================================================= --
--                            UI CONSTRUCTION                              --
-- ========================================================================= --

local Window = WindUI:CreateWindow("Legacy")

-- ========================================== --
--               TAB 1: RAGE                  --
-- ========================================== --
local RageTab = Window:CreateTab("Rage", "Target")
local RageMainSec = RageTab:CreateSection("Main Settings", "Left")

local RageSettings = {
    InstantKill = false,
    InstantKillKey = nil,
    Target = "None"
}

RageMainSec:CreateToggle("Instant Kill", false, function(v)
    RageSettings.InstantKill = v
end)

RageMainSec:CreateKeybind("Instant Kill Key", nil, function(key, isPressed)
    if key and not isPressed then 
        RageSettings.InstantKillKey = key 
    end
end)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function GetEnemyList()
    local options = {"None", "All"}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if not LocalPlayer.Team or player.Team ~= LocalPlayer.Team then
                table.insert(options, player.Name)
            end
        end
    end
    return options
end

local RageTargetDropdown = RageMainSec:CreateDropdown("Select Target", GetEnemyList(), "None", function(v)
    RageSettings.Target = v
end)

local function UpdateRageDropdown()
    local newList = GetEnemyList()
    if RageTargetDropdown.Refresh then
        RageTargetDropdown:Refresh(newList, true)
    elseif RageTargetDropdown.Update then
        RageTargetDropdown:Update(newList)
    end
    
    if not table.find(newList, RageSettings.Target) then
        RageSettings.Target = "None"
    end
end

Players.PlayerAdded:Connect(function(player)
    player:GetPropertyChangedSignal("Team"):Connect(UpdateRageDropdown)
    UpdateRageDropdown()
end)
Players.PlayerRemoving:Connect(UpdateRageDropdown)
LocalPlayer:GetPropertyChangedSignal("Team"):Connect(UpdateRageDropdown)
for _, p in ipairs(Players:GetPlayers()) do
    p:GetPropertyChangedSignal("Team"):Connect(UpdateRageDropdown)
end

-- ========================================== --
--              TAB 2: LEGITBOT                 --
-- ========================================== --
local LegitbotTab = Window:CreateTab("Legitbot", "Crosshair")

local AimMainSec = LegitbotTab:CreateSection("Main Settings", "Left")

AimMainSec:CreateToggle("Legitbot", Rayflare.Settings.Enabled, function(v)
    Rayflare.Settings.Enabled = v
end)

AimMainSec:CreateKeybind("Trigger Key", Rayflare.Settings.Trigger.TriggerKey, function(key, isPressed)
    if key and not isPressed then 
        Rayflare.Settings.Trigger.TriggerKey = key 
    end
end)

AimMainSec:CreateSlider("Smoothness", 0, 20, Rayflare.Settings.Smoothness, function(v)
    Rayflare.Settings.Smoothness = v
end)

AimMainSec:CreateDropdown("Aim Part", {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"}, Rayflare.Settings.AimPart, function(v)
    Rayflare.Settings.AimPart = v
end)

AimMainSec:CreateDropdown("Trigger Mode", {"Hold", "Toggle", "Always"}, Rayflare.Settings.Trigger.TriggerMode, function(v)
    Rayflare.Settings.Trigger.TriggerMode = v
end)

AimMainSec:CreateDropdown("Aim Type", {"Camera", "Cursor"}, Rayflare.Settings.AimType, function(v)
    Rayflare.Settings.AimType = v
end)

AimMainSec:CreateToggle("Team Check", Rayflare.Settings.TeamCheck.Enabled, function(v)
    Rayflare.Settings.TeamCheck.Enabled = v
end)

AimMainSec:CreateToggle("Wall Check", Rayflare.Settings.WallCheck.Enabled, function(v)
    Rayflare.Settings.WallCheck.Enabled = v
end)


local AimFOVSec = LegitbotTab:CreateSection("Field of View", "Right")
AimFOVSec:CreateToggle("Show FOV", Rayflare.Settings.FOV.Visible, function(v)
    Rayflare.Settings.FOV.Visible = v
end)
AimFOVSec:CreateSlider("FOV Radius", 10, 500, Rayflare.Settings.FOV.Radius, function(v)
    Rayflare.Settings.FOV.Radius = v
end)
AimFOVSec:CreateToggle("Chroma FOV", Rayflare.Settings.FOV.Chroma, function(v)
    Rayflare.Settings.FOV.Chroma = v
end)
AimFOVSec:CreateColorPicker("FOV Color", Rayflare.Settings.FOV.Color, function(c)
    Rayflare.Settings.FOV.Color = c
end)


local TriggerBotSec = LegitbotTab:CreateSection("Triggerbot", "Right")

TriggerBotSec:CreateToggle("Triggerbot", Rayflare.Settings.TriggerBot.Enabled, function(v)
    Rayflare.Settings.TriggerBot.Enabled = v
end)
TriggerBotSec:CreateKeybind("Triggerbot Key", Rayflare.Settings.TriggerBot.TriggerKey, function(key, isPressed)
    if key and not isPressed then
        Rayflare.Settings.TriggerBot.TriggerKey = key
    end
end)
TriggerBotSec:CreateDropdown("Trigger Mode", {"Hold", "Toggle", "Always"}, Rayflare.Settings.TriggerBot.TriggerMode, function(v)
    Rayflare.Settings.TriggerBot.TriggerMode = v
end)
TriggerBotSec:CreateDropdown("Aim Type", {"Camera", "Cursor"}, Rayflare.Settings.TriggerBot.Mode, function(v)
    Rayflare.Settings.TriggerBot.Mode = v
end)
TriggerBotSec:CreateSlider("Trigger Delay", 0, 1000, math.floor(Rayflare.Settings.TriggerBot.Delay * 1000), function(v)
    Rayflare.Settings.TriggerBot.Delay = v / 1000
end)
TriggerBotSec:CreateToggle("Wall Check", Rayflare.Settings.TriggerBot.WallCheck.Enabled, function(v)
    Rayflare.Settings.TriggerBot.WallCheck.Enabled = v
end)


-- ========================================== --
--              TAB 3: VISUALS                  --
-- ========================================== --
local VisualsTab = Window:CreateTab("Visuals", "Eye")

local ESPMainSec = VisualsTab:CreateSection("Main Controller", "Left")
ESPMainSec:CreateToggle("Master Switch", Zeta.Settings.Enabled, function(v)
    Zeta.Settings.Enabled = v
end)
ESPMainSec:CreateToggle("Team Check", false, function(v)
    if v then
        Zeta.Settings.Filter = function(player)
            if not game.Players.LocalPlayer.Team then return true end
            return player.Team ~= game.Players.LocalPlayer.Team
        end
    else
        Zeta.Settings.Filter = function(player) return true end
    end
end)

local ESPElementsSec = VisualsTab:CreateSection("ESP Elements", "Left")
ESPElementsSec:CreateToggle("Chams", Zeta.Settings.Chams.Enabled, function(v)
    Zeta.Settings.Chams.Enabled = v
end)
ESPElementsSec:CreateToggle("Box", Zeta.Settings.Box.Enabled, function(v)
    Zeta.Settings.Box.Enabled = v
end)
ESPElementsSec:CreateToggle("Username", Zeta.Settings.Text.Enabled, function(v)
    Zeta.Settings.Text.Enabled = v
end)
ESPElementsSec:CreateToggle("Tracers", Zeta.Settings.Tracers.Enabled, function(v)
    Zeta.Settings.Tracers.Enabled = v
end)
ESPElementsSec:CreateToggle("Head Circle", Zeta.Settings.Box.HeadCircle.Enabled, function(v)
    Zeta.Settings.Box.HeadCircle.Enabled = v
end)
ESPElementsSec:CreateToggle("Health Bar", Zeta.Settings.HealthBar.Enabled, function(v)
    Zeta.Settings.HealthBar.Enabled = v
end)

local ESPColorsSec = VisualsTab:CreateSection("Colors", "Right")
ESPColorsSec:CreateColorPicker("Chams Color", Zeta.Settings.Chams.Color, function(c) Zeta.Settings.Chams.Color = c end)
ESPColorsSec:CreateColorPicker("Box Color", Zeta.Settings.Box.Color, function(c) Zeta.Settings.Box.Color = c end)
ESPColorsSec:CreateColorPicker("Username Color", Zeta.Settings.Text.Color, function(c) Zeta.Settings.Text.Color = c end)
ESPColorsSec:CreateColorPicker("Tracer Color", Zeta.Settings.Tracers.Color, function(c) Zeta.Settings.Tracers.Color = c end)
ESPColorsSec:CreateColorPicker("Head Circle Color", Zeta.Settings.Box.HeadCircle.Color, function(c) Zeta.Settings.Box.HeadCircle.Color = c end)

-- ========================================== --
--            TAB 4: ENVIRONMENT              --
-- ========================================== --
local EnvTab = Window:CreateTab("Environment", "Home")
local EnvMainSec = EnvTab:CreateSection("Lighting", "Left")

local Lighting = game:GetService("Lighting")
local origClockTime = Lighting.ClockTime
local origAmbient = Lighting.Ambient
local origOutdoorAmbient = Lighting.OutdoorAmbient

EnvMainSec:CreateToggle("Night Mode", false, function(v)
    if v then
        origClockTime = Lighting.ClockTime
        origAmbient = Lighting.Ambient
        origOutdoorAmbient = Lighting.OutdoorAmbient
        Lighting.ClockTime = 0
        Lighting.Ambient = Color3.fromRGB(40, 40, 60)
        Lighting.OutdoorAmbient = Color3.fromRGB(40, 40, 60)
    else
        Lighting.ClockTime = origClockTime
        Lighting.Ambient = origAmbient
        Lighting.OutdoorAmbient = origOutdoorAmbient
    end
end)


-- ========================================== --
--        BACKGROUND LOGIC CONTROLLERS        --
-- ========================================== --

local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Camera = Workspace.CurrentCamera

local isExecutingRage = false
local rageFollowConnection = nil
local originalCamType = nil
local originalSubject = nil
local originalCamCFrame = nil
local activeRageTargets = {}

local function StopRageMode()
    if not isExecutingRage then return end
    isExecutingRage = false
    
    if rageFollowConnection then
        rageFollowConnection:Disconnect()
        rageFollowConnection = nil
    end
    
    Camera.CameraType = originalCamType
    Camera.CameraSubject = originalSubject
    if originalCamCFrame then
        Camera.CFrame = originalCamCFrame
    end
    
    activeRageTargets = {}
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if RageSettings.InstantKill and RageSettings.InstantKillKey then
        local isTriggerKey = (input.UserInputType == RageSettings.InstantKillKey) or (input.KeyCode == RageSettings.InstantKillKey)
        
        if isTriggerKey and RageSettings.Target ~= "None" and not isExecutingRage then
            isExecutingRage = true
            
            local targets = {}
            local baseTarget = nil
            
            if RageSettings.Target == "All" then
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and (not LocalPlayer.Team or p.Team ~= LocalPlayer.Team) then
                        if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Head") then
                            table.insert(targets, p.Character)
                        end
                    end
                end
                baseTarget = targets[1]
            else
                local targetPlayer = Players:FindFirstChild(RageSettings.Target)
                if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") and targetPlayer.Character:FindFirstChild("Head") then
                    table.insert(targets, targetPlayer.Character)
                    baseTarget = targetPlayer.Character
                end
            end
            
            if #targets > 0 and baseTarget then
                activeRageTargets = targets
                local baseHRP = baseTarget:FindFirstChild("HumanoidRootPart")
                local baseHead = baseTarget:FindFirstChild("Head")
                
                originalCamType = Camera.CameraType
                originalSubject = Camera.CameraSubject
                originalCamCFrame = Camera.CFrame
                Camera.CameraType = Enum.CameraType.Scriptable
                
                rageFollowConnection = RunService.RenderStepped:Connect(function()
                    if baseHead and baseHead.Parent and baseHRP and baseHRP.Parent then
                        local camPos = baseHead.CFrame * CFrame.new(0, 0, -4)
                        Camera.CFrame = CFrame.lookAt(camPos.Position, baseHead.Position)
                        
                        if RageSettings.Target == "All" then
                            for _, char in ipairs(activeRageTargets) do
                                local hrp = char:FindFirstChild("HumanoidRootPart")
                                if hrp then
                                    hrp.AssemblyLinearVelocity = Vector3.zero
                                    hrp.AssemblyAngularVelocity = Vector3.zero
                                    
                                    if char ~= baseTarget then
                                        hrp.CFrame = baseHRP.CFrame
                                    end
                                end
                            end
                        end
                    else
                        StopRageMode()
                    end
                end)
            else
                isExecutingRage = false
            end
        end
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if RageSettings.InstantKillKey then
        local isTriggerKey = (input.UserInputType == RageSettings.InstantKillKey) or (input.KeyCode == RageSettings.InstantKillKey)
        
        if isTriggerKey then
            StopRageMode()
        end
    end
end)
