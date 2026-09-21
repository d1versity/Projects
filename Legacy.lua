-- Fetch Libraries from GitHub
local Rayflare = loadstring(game:HttpGet("https://raw.githubusercontent.com/d1versity/Rayflare/refs/heads/main/Library.lua"))()
local WindUI   = loadstring(game:HttpGet("https://raw.githubusercontent.com/d1versity/Wind/refs/heads/main/Library.lua"))()
local Zeta     = loadstring(game:HttpGet("https://raw.githubusercontent.com/d1versity/Zeta/refs/heads/main/Library.lua"))()

-- Configure Default States for Rayflare
Rayflare.Settings.FOV.Radius = 50
Rayflare.Settings.Flick = { Enabled = false } -- Explicitly set to false by default
Rayflare.Settings.TriggerBot = Rayflare.Settings.TriggerBot or {
    Enabled = false,
    Mode = "Camera",
    TriggerKey = Enum.UserInputType.MouseButton2,
    TriggerMode = "Hold",
    IsAiming = false,
    Delay = 0,
    TeamCheck = { Enabled = false },
    WallCheck = { Enabled = false }
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

-- Local Settings for the UI Script
local MovementSettings = {
    BhopEnabled = false,
    BhopSpeed = 30
}

local EnvSettings = {
    NightModeEnabled = false,
    FOVEnabled = false,
    FOV = 80
}

local FreecamSettings = {
    MasterSwitch = false,
    Active = false,
    Speed = 50,
    Keybind = nil,
    Pitch = 0,
    Yaw = 0,
    Pos = Vector3.zero,
    SavedCFrame = nil,
    SavedCameraCFrame = nil
}

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
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

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
AimMainSec:CreateToggle("Flick", Rayflare.Settings.Flick.Enabled, function(v)
    Rayflare.Settings.Flick.Enabled = v
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
TriggerBotSec:CreateToggle("Team Check", Rayflare.Settings.TriggerBot.TeamCheck.Enabled, function(v)
    Rayflare.Settings.TriggerBot.TeamCheck.Enabled = v
end)
TriggerBotSec:CreateToggle("Wall Check", Rayflare.Settings.TriggerBot.WallCheck.Enabled, function(v)
    Rayflare.Settings.TriggerBot.WallCheck.Enabled = v
end)

-- ========================================== --
--              TAB 3: MOVEMENT                 --
-- ========================================== --
local MovementTab = Window:CreateTab("Movement", "Person")

local MovementSec = MovementTab:CreateSection("Bunny Hop", "Left")
MovementSec:CreateToggle("Bunny Hop", MovementSettings.BhopEnabled, function(v)
    MovementSettings.BhopEnabled = v
end)
MovementSec:CreateSlider("Bhop Speed", 16, 100, MovementSettings.BhopSpeed, function(v)
    MovementSettings.BhopSpeed = v
end)

-- ========================================== --
--              TAB 4: VISUALS                  --
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
ESPElementsSec:CreateToggle("Chams", Zeta.Settings.Chams.Enabled, function(v) Zeta.Settings.Chams.Enabled = v end)
ESPElementsSec:CreateToggle("Box", Zeta.Settings.Box.Enabled, function(v) Zeta.Settings.Box.Enabled = v end)
ESPElementsSec:CreateToggle("Username", Zeta.Settings.Text.Enabled, function(v) Zeta.Settings.Text.Enabled = v end)
ESPElementsSec:CreateToggle("Tracers", Zeta.Settings.Tracers.Enabled, function(v) Zeta.Settings.Tracers.Enabled = v end)
ESPElementsSec:CreateToggle("Head Circle", Zeta.Settings.Box.HeadCircle.Enabled, function(v) Zeta.Settings.Box.HeadCircle.Enabled = v end)
ESPElementsSec:CreateToggle("Health Bar", Zeta.Settings.HealthBar.Enabled, function(v) Zeta.Settings.HealthBar.Enabled = v end)

local ESPColorsSec = VisualsTab:CreateSection("Colors", "Right")
ESPColorsSec:CreateColorPicker("Chams Color", Zeta.Settings.Chams.Color, function(c) Zeta.Settings.Chams.Color = c end)
ESPColorsSec:CreateColorPicker("Box Color", Zeta.Settings.Box.Color, function(c) Zeta.Settings.Box.Color = c end)
ESPColorsSec:CreateColorPicker("Username Color", Zeta.Settings.Text.Color, function(c) Zeta.Settings.Text.Color = c end)
ESPColorsSec:CreateColorPicker("Tracer Color", Zeta.Settings.Tracers.Color, function(c) Zeta.Settings.Tracers.Color = c end)
ESPColorsSec:CreateColorPicker("Head Circle Color", Zeta.Settings.Box.HeadCircle.Color, function(c) Zeta.Settings.Box.HeadCircle.Color = c end)

-- ========================================== --
--          TAB 5: SKIN CHANGER               --
-- ========================================== --
local SkinTab = Window:CreateTab("Skin Changer", "Code")

local function ApplySkin(teamFolders, weaponName, skinName)
    local skinFolder = LocalPlayer:FindFirstChild("SkinFolder")
    if not skinFolder then
        skinFolder = Instance.new("Folder")
        skinFolder.Name = "SkinFolder"
        skinFolder.Parent = LocalPlayer
    end
    
    for _, teamFolderName in ipairs(teamFolders) do
        local teamFolder = skinFolder:FindFirstChild(teamFolderName)
        if not teamFolder then
            teamFolder = Instance.new("Folder")
            teamFolder.Name = teamFolderName
            teamFolder.Parent = skinFolder
        end
        
        local weaponVal = teamFolder:FindFirstChild(weaponName)
        if not weaponVal then
            weaponVal = Instance.new("StringValue")
            weaponVal.Name = weaponName
            weaponVal.Parent = teamFolder
        end
        
        weaponVal.Value = skinName
    end
end

local PistolsSec = SkinTab:CreateSection("PISTOLS", "Left")
PistolsSec:CreateDropdown("Glock-18", {"Stock", "Desert Camo", "Day Dreamer", "Wetland", "Anubis", "Midnight Tiger", "Gravestomper", "Tarnish", "Rush", "Angler", "Spacedust", "Money Maker", "RSL", "Biotrip", "Underwater", "Hallows", "BloxersClub", "Lantern", "Exoskeleton", "Alpine", "Royal Crimson", "Chocolatier", "Independence", "Overdrive"}, "Stock", function(v)
    ApplySkin({"TFolder"}, "Glock", v)
end)
PistolsSec:CreateDropdown("USP-S", {"Stock", "Skull", "Yellowbelly", "Crimson", "Jade Dream", "Racing", "Frostbite", "Nighttown", "Paradise", "Dizzy", "Kraken", "Worlds Away", "Unseenremake", "Holiday", "Survivor", "BloxersClub", "Gingerbread", "Blossom", "Unseen", "Vision", "Infantry", "Overdrive"}, "Stock", function(v)
    ApplySkin({"CTFolder"}, "USP", v)
end)
PistolsSec:CreateDropdown("Deagle", {"Stock", "Glittery", "Grim", "Weeb", "Krystallos", "Honor-bound", "TC", "Xmas", "Blossom", "Cool Blue", "Survivor", "Ababa", "Heat", "Headwind", "Independence", "Racer", "Pumpkin Buster", "Skin Committee", "DropX", "Crystal", "Blue Fur", "Cold Truth", "BloxersClub", "Guapo", "Regal Eclipse", "Demon Eyes", "Royal Guard", "Industrial", "Engraved", "Blue Rail", "Cotton Tail", "Torque Hare", "Volcan", "Torque Hare P2", "Zeus"}, "Stock", function(v)
    ApplySkin({"CTFolder", "TFolder"}, "DesertEagle", v)
end)

local RiflesSec = SkinTab:CreateSection("Rifles", "Right")
RiflesSec:CreateDropdown("AK-47", {"Stock", "Hallows", "Ace", "Code Orange", "Clown", "Variant Camo", "Eve", "VAV", "Quantum", "Hypersonic", "Mean Green", "Bloodboom", "Elf", "Skin Committee", "Patch", "Outlaws", "Gifted", "Ugly Sweater", "Secret Santa", "Precision", "Outrunner", "Godess", "Maker", "Ghost", "Glo", "Survivor", "Shooting Star", "Halo", "Inversion", "Plated", "Quicktime", "Yltude", "Trinity", "Toxic Nitro", "Scythe", "Neonline", "Galaxy Corpse", "Weeb", "Super Weeb", "BloxersClub", "Jester", "Spooky", "Moon", "Lil Tim", "Iron Garden", "Maxal", "Kimura", "Bloom", "Torque Hare", "Sovereign", "Torque Hare P2", "Revolution"}, "Stock", function(v)
    ApplySkin({"TFolder"}, "AK47", v)
end)
RiflesSec:CreateDropdown("M4A1-S", {"Stock", "Toucan", "Animatic", "Desert Camo", "Wastelander", "BloxersClub", "Tecnician", "Impulse", "Burning", "Lunar", "Necropolis", "Jester", "Nightmare", "Heavens Gate", "Star Camo", "Snowman", "RacerX", "Kimura", "Street Hop", "Violet Circuits", "Warped"}, "Stock", function(v)
    ApplySkin({"CTFolder"}, "M4A1", v)
end)
RiflesSec:CreateDropdown("M4A4", {"Stock", "Devil", "Pinkvision", "Desert Camo", "BOT[S]", "Precision", "Candyskull", "Sleigher", "Toy Soldier", "Endline", "Pondside", "Ice Cap", "Pinkie", "Racer", "Stardust", "King", "Moonwalker", "RayTrack", "Mistletoe", "Delinquent", "Quicktime", "Jester", "Darkness", "Agony", "Rosebite", "Flashy Ride", "Pyros"}, "Stock", function(v)
    ApplySkin({"CTFolder"}, "M4A4", v)
end)
RiflesSec:CreateDropdown("SG 553", {"Stock", "Yltude", "Knighthood", "Variant Camo", "Magma", "DropX", "Dummy", "Kitty Cat", "Drop-Out", "Control", "NR8", "Volcanis", "Gilded Amore", "Electi"}, "Stock", function(v)
    ApplySkin({"TFolder"}, "SG", v)
end)
RiflesSec:CreateDropdown("SSG 08", {"Stock", "Xmas", "Coffin Biter", "Railgun", "Hellborn", "Hot Cocoa", "Theory", "Pulse", "Monstruo", "Flowing Mists", "Neon Regulation", "Posh", "Darkness", "Lunar", "Aurora", "Choco", "Fractured"}, "Stock", function(v)
    ApplySkin({"CTFolder", "TFolder"}, "Scout", v)
end)
RiflesSec:CreateDropdown("AWP", {"Stock", "Grepkin", "Instinct", "Nerf", "JTF2", "Difference", "Weeb", "Pink Vision", "Desert Camo", "BloxersClub", "Lunar", "Elfspire", "Coffin Biter", "Pear Tree", "Northern Lights", "Racer", "Forever", "Blastech", "Abaddon", "Retroactive", "Pinkie", "Autumness", "Venomus", "Hika", "Silence", "Kumanjayi", "Dragon", "Illusion", "Regina", "Quicktime", "Toxic Nitro", "Darkness", "Oriental", "Circuits", "Bloodborne", "Pumpkin Piercer", "Cemetery", "Cybertech", "Roses", "Grim", "Spring", "Patriot"}, "Stock", function(v)
    ApplySkin({"CTFolder", "TFolder"}, "AWP", v)
end)

-- ========================================== --
--            TAB 6: ENVIRONMENT              --
-- ========================================== --
local EnvTab = Window:CreateTab("Environment", "Home")

local EnvMainSec = EnvTab:CreateSection("Lighting", "Left")
local Lighting = game:GetService("Lighting")
local origClockTime = Lighting.ClockTime
local origAmbient = Lighting.Ambient
local origOutdoorAmbient = Lighting.OutdoorAmbient

EnvMainSec:CreateToggle("Night Mode", false, function(v)
    EnvSettings.NightModeEnabled = v
    if v then
        origClockTime = Lighting.ClockTime
        origAmbient = Lighting.Ambient
        origOutdoorAmbient = Lighting.OutdoorAmbient
    else
        Lighting.ClockTime = origClockTime
        Lighting.Ambient = origAmbient
        Lighting.OutdoorAmbient = origOutdoorAmbient
    end
end)

local EnvFOVSec = EnvTab:CreateSection("Camera", "Right")
EnvFOVSec:CreateToggle("FOV Changer", false, function(v)
    EnvSettings.FOVEnabled = v
end)

EnvFOVSec:CreateSlider("Field of View", 60, 120, 80, function(v)
    EnvSettings.FOV = v
    if EnvSettings.FOVEnabled and Workspace.CurrentCamera then
        Workspace.CurrentCamera.FieldOfView = v
    end
end)

-- Freecam Functionality
local UserInputService = game:GetService("UserInputService")

local function ToggleFreecam(state)
    FreecamSettings.Active = state
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    local currentCam = Workspace.CurrentCamera
    
    if state then
        -- Save original camera CFrame before manipulating anything
        FreecamSettings.SavedCameraCFrame = currentCam.CFrame
        
        -- Initialize orientation and position when turning on
        local rx, ry, rz = currentCam.CFrame:ToEulerAnglesYXZ()
        FreecamSettings.Pitch = rx
        FreecamSettings.Yaw = ry
        FreecamSettings.Pos = currentCam.CFrame.Position
        
        currentCam.CameraType = Enum.CameraType.Scriptable
        currentCam.CameraSubject = nil -- Decouple to prevent physics fighting
        
        -- Lock mouse for immediate first-person style control
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
        
        if hrp then
            FreecamSettings.SavedCFrame = hrp.CFrame
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
            hrp.Anchored = true
        end
        if hum then
            hum.AutoRotate = false
        end
    else
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        
        if hum then
            currentCam.CameraSubject = hum
            hum.AutoRotate = true
        end
        if hrp then
            hrp.Anchored = false
            FreecamSettings.SavedCFrame = nil
        end
        
        currentCam.CameraType = Enum.CameraType.Custom
        
        -- Restore original camera CFrame directly after resetting properties
        if FreecamSettings.SavedCameraCFrame then
            currentCam.CFrame = FreecamSettings.SavedCameraCFrame
            FreecamSettings.SavedCameraCFrame = nil
        end
    end
end

local EnvFreecamSec = EnvTab:CreateSection("Freecam", "Left")
EnvFreecamSec:CreateToggle("Freecam", false, function(v)
    FreecamSettings.MasterSwitch = v
    if not v and FreecamSettings.Active then
        ToggleFreecam(false)
    end
end)

EnvFreecamSec:CreateKeybind("Freecam Keybind", nil, function(key)
    -- Simply record the key, UserInputService handles the toggling
    FreecamSettings.Keybind = key
end)

EnvFreecamSec:CreateSlider("Freecam Speed", 10, 200, 50, function(v)
    FreecamSettings.Speed = v
end)

-- Safely reset Freecam if the player dies/respawns
LocalPlayer.CharacterAdded:Connect(function(newChar)
    if FreecamSettings.Active then
        ToggleFreecam(false)
    end
end)

-- ========================================== --
--        BACKGROUND LOGIC CONTROLLERS        --
-- ========================================== --

local RunService = game:GetService("RunService")

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
    
    local currentCam = Workspace.CurrentCamera
    if not FreecamSettings.Active then
        currentCam.CameraType = originalCamType
        currentCam.CameraSubject = originalSubject
    end
    
    if originalCamCFrame then
        currentCam.CFrame = originalCamCFrame
    end
    
    activeRageTargets = {}
end

UserInputService.InputChanged:Connect(function(input, gameProcessed)
    -- Freecam Mouse Look System
    if FreecamSettings.Active and input.UserInputType == Enum.UserInputType.MouseMovement then
        -- Force the lock to ensure we capture raw mouse delta continuously
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
        
        local delta = input.Delta
        FreecamSettings.Yaw = FreecamSettings.Yaw - math.rad(delta.X) * 0.5
        FreecamSettings.Pitch = FreecamSettings.Pitch - math.rad(delta.Y) * 0.5
        FreecamSettings.Pitch = math.clamp(FreecamSettings.Pitch, -math.rad(89), math.rad(89))
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- Freecam Input Check
    if FreecamSettings.MasterSwitch and FreecamSettings.Keybind then
        local isFreecamKey = (input.UserInputType == FreecamSettings.Keybind) or (input.KeyCode == FreecamSettings.Keybind)
        if isFreecamKey then
            ToggleFreecam(not FreecamSettings.Active)
        end
    end
    
    -- Rage Input Check
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
                
                local currentCam = Workspace.CurrentCamera
                originalCamType = currentCam.CameraType
                originalSubject = currentCam.CameraSubject
                originalCamCFrame = currentCam.CFrame
                currentCam.CameraType = Enum.CameraType.Scriptable
                
                rageFollowConnection = RunService.RenderStepped:Connect(function()
                    if baseHead and baseHead.Parent and baseHRP and baseHRP.Parent then
                        local camPos = baseHead.CFrame * CFrame.new(0, 0, -4)
                        Workspace.CurrentCamera.CFrame = CFrame.lookAt(camPos.Position, baseHead.Position)
                        
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

local bhopAttachment = nil
local bhopVelocity = nil

local function cleanupBhop()
    if bhopVelocity then bhopVelocity:Destroy(); bhopVelocity = nil end
    if bhopAttachment then bhopAttachment:Destroy(); bhopAttachment = nil end
end

RunService.RenderStepped:Connect(function(deltaTime)
    -- Freecam Movement and Character Locking Logic
    if FreecamSettings.Active then
        local currentCam = Workspace.CurrentCamera
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        
        -- Force Character to stay completely frozen at saved coordinates
        if hrp and FreecamSettings.SavedCFrame then
            hrp.CFrame = FreecamSettings.SavedCFrame
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        end
        
        -- Assemble rotation from Yaw and Pitch
        local camRotation = CFrame.fromEulerAnglesYXZ(FreecamSettings.Pitch, FreecamSettings.Yaw, 0)
        
        local movement = Vector3.zero
        local forward = camRotation.LookVector
        local right = camRotation.RightVector
        local up = Vector3.new(0, 1, 0)
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then movement = movement + forward end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then movement = movement - forward end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then movement = movement - right end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then movement = movement + right end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then movement = movement + up end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then movement = movement - up end
        
        if movement.Magnitude > 0 then
            -- Safe Delta limits physics anomalies/lags throwing the camera out of bounds
            local safeDelta = math.min(deltaTime, 0.1)
            FreecamSettings.Pos = FreecamSettings.Pos + (movement.Unit * FreecamSettings.Speed * safeDelta)
        end
        
        -- Override CFrame directly from custom vectors (ignores wall collision)
        currentCam.CFrame = CFrame.new(FreecamSettings.Pos) * camRotation
    end

    -- Forcefully lock Custom FOV if enabled
    if EnvSettings.FOVEnabled and Workspace.CurrentCamera then
        if Workspace.CurrentCamera.FieldOfView ~= EnvSettings.FOV then
            Workspace.CurrentCamera.FieldOfView = EnvSettings.FOV
        end
    end

    -- Force Persistent Brighter Night Mode
    if EnvSettings.NightModeEnabled then
        Lighting.ClockTime = 0
        Lighting.Ambient = Color3.fromRGB(130, 130, 145)
        Lighting.OutdoorAmbient = Color3.fromRGB(110, 110, 125)
    end

    if MovementSettings.BhopEnabled and not FreecamSettings.Active then
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChild("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        
        if hum and hrp and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            
            if not bhopAttachment or bhopAttachment.Parent ~= hrp then
                if bhopAttachment then bhopAttachment:Destroy() end
                bhopAttachment = Instance.new("Attachment")
                bhopAttachment.Name = "BhopAttachment"
                bhopAttachment.Parent = hrp
            end
            
            if not bhopVelocity or bhopVelocity.Parent ~= hrp then
                if bhopVelocity then bhopVelocity:Destroy() end
                bhopVelocity = Instance.new("LinearVelocity")
                bhopVelocity.Name = "BhopVelocity"
                bhopVelocity.Attachment0 = bhopAttachment
                bhopVelocity.ForceLimitMode = Enum.ForceLimitMode.PerAxis
                bhopVelocity.MaxAxesForce = Vector3.new(9e9, 0, 9e9)
                bhopVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
                bhopVelocity.Parent = hrp
            end
            
            bhopVelocity.Enabled = true

            local state = hum:GetState()
            local isGrounded = (hum.FloorMaterial ~= Enum.Material.Air) or (state == Enum.HumanoidStateType.Landed) or (state == Enum.HumanoidStateType.Running)
            
            if isGrounded then
                hum.Jump = true
            end
            
            local currentCam = Workspace.CurrentCamera
            local flatLook = Vector3.new(currentCam.CFrame.LookVector.X, 0, currentCam.CFrame.LookVector.Z).Unit
            local flatRight = Vector3.new(currentCam.CFrame.RightVector.X, 0, currentCam.CFrame.RightVector.Z).Unit
            
            local moveDir = Vector3.new(0, 0, 0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + flatLook end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - flatLook end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - flatRight end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + flatRight end
            
            if moveDir.Magnitude > 0 then
                bhopVelocity.VectorVelocity = moveDir.Unit * MovementSettings.BhopSpeed
            else
                bhopVelocity.VectorVelocity = Vector3.zero
            end
        else
            cleanupBhop()
        end
    else
        cleanupBhop()
    end
end)
