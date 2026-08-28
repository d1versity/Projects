-- Fetch Libraries from GitHub
local Rayflare = loadstring(game:HttpGet("https://raw.githubusercontent.com/d1versity/Rayflare/refs/heads/main/Library.lua"))()
local WindUI   = loadstring(game:HttpGet("https://raw.githubusercontent.com/d1versity/Wind/refs/heads/main/Library.lua"))()
local Zeta     = loadstring(game:HttpGet("https://raw.githubusercontent.com/d1versity/Zeta/refs/heads/main/Library.lua"))()

-- Configure Default States for Rayflare
Rayflare.Settings.FOV.Radius = 50

-- Configure Default States for Zeta (All disabled, Tracers to Top)
Zeta.Settings.MaxDistance = 400
Zeta.Settings.Enabled = false
Zeta.Settings.Chams.Enabled = false
Zeta.Settings.Box.Enabled = false
Zeta.Settings.Text.Enabled = false
Zeta.Settings.Tracers.Enabled = false
Zeta.Settings.Tracers.Origin = "Top"
Zeta.Settings.Box.HeadCircle.Enabled = false
Zeta.Settings.HealthBar.Enabled = false

-- Initialize Background Engines
Rayflare:Load()
Zeta:Load()

-- ========================================================================= --
--                               UI CONSTRUCTION                             --
-- ========================================================================= --

local Window = WindUI:CreateWindow("Legacy")

-- ========================================== --
--             TAB 1: LEGITBOT                --
-- ========================================== --
local LegitbotTab = Window:CreateTab("Legitbot", "Target")

local AimMainSec = LegitbotTab:CreateSection("Main Settings", "Left")

AimMainSec:CreateToggle("Legitbot", Rayflare.Settings.Enabled, function(v)
    Rayflare.Settings.Enabled = v
    Window:Notify("Settings Changed", "Legitbot set to: " .. tostring(v), 3)
end)

AimMainSec:CreateKeybind("Trigger Key", Rayflare.Settings.Trigger.TriggerKey, function(key, isPressed)
    -- Fixed: Only notifies when the key is assigned, NOT when you press it
    if key and not isPressed then 
        Rayflare.Settings.Trigger.TriggerKey = key 
        Window:Notify("Settings Changed", "Trigger Key bound to: " .. tostring(key.Name or key), 3)
    end
end)

AimMainSec:CreateSlider("Smoothness", 0, 20, Rayflare.Settings.Smoothness, function(v)
    Rayflare.Settings.Smoothness = v
end)

AimMainSec:CreateDropdown("Aim Part", {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"}, Rayflare.Settings.AimPart, function(v)
    Rayflare.Settings.AimPart = v
    Window:Notify("Settings Changed", "Aim Part set to: " .. tostring(v), 3)
end)

AimMainSec:CreateDropdown("Trigger Mode", {"Hold", "Toggle", "Always"}, Rayflare.Settings.Trigger.TriggerMode, function(v)
    Rayflare.Settings.Trigger.TriggerMode = v
    Window:Notify("Settings Changed", "Trigger Mode set to: " .. tostring(v), 3)
end)

AimMainSec:CreateDropdown("Aim Type", {"Camera", "Cursor"}, Rayflare.Settings.AimType, function(v)
    Rayflare.Settings.AimType = v
    Window:Notify("Settings Changed", "Aim Type set to: " .. tostring(v), 3)
end)


local AimChecksSec = LegitbotTab:CreateSection("Checks", "Left")

AimChecksSec:CreateToggle("Team Check", Rayflare.Settings.TeamCheck.Enabled, function(v)
    Rayflare.Settings.TeamCheck.Enabled = v
    Window:Notify("Settings Changed", "Aim Team Check set to: " .. tostring(v), 3)
end)

AimChecksSec:CreateToggle("Wall Check", Rayflare.Settings.WallCheck.Enabled, function(v)
    Rayflare.Settings.WallCheck.Enabled = v
    Window:Notify("Settings Changed", "Aim Wall Check set to: " .. tostring(v), 3)
end)


local AimFOVSec = LegitbotTab:CreateSection("Field of View", "Right")

AimFOVSec:CreateToggle("Show FOV", Rayflare.Settings.FOV.Visible, function(v)
    Rayflare.Settings.FOV.Visible = v
    Window:Notify("Settings Changed", "Show FOV set to: " .. tostring(v), 3)
end)

AimFOVSec:CreateSlider("FOV Radius", 10, 500, Rayflare.Settings.FOV.Radius, function(v)
    Rayflare.Settings.FOV.Radius = v
end)

AimFOVSec:CreateToggle("Chroma FOV", Rayflare.Settings.FOV.Chroma, function(v)
    Rayflare.Settings.FOV.Chroma = v
    Window:Notify("Settings Changed", "Chroma FOV set to: " .. tostring(v), 3)
end)

AimFOVSec:CreateColorPicker("FOV Color", Rayflare.Settings.FOV.Color, function(c)
    Rayflare.Settings.FOV.Color = c
end)


-- ========================================== --
--              TAB 2: VISUALS                --
-- ========================================== --
local VisualsTab = Window:CreateTab("Visuals", "Eye")

local ESPMainSec = VisualsTab:CreateSection("Main Controller", "Left")

ESPMainSec:CreateToggle("Master Switch", Zeta.Settings.Enabled, function(v)
    Zeta.Settings.Enabled = v
    Window:Notify("Settings Changed", "ESP Master Switch set to: " .. tostring(v), 3)
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
    Window:Notify("Settings Changed", "ESP Team Check set to: " .. tostring(v), 3)
end)


local ESPElementsSec = VisualsTab:CreateSection("ESP Elements", "Left")

ESPElementsSec:CreateToggle("Chams", Zeta.Settings.Chams.Enabled, function(v)
    Zeta.Settings.Chams.Enabled = v
    Window:Notify("Settings Changed", "Chams set to: " .. tostring(v), 3)
end)

ESPElementsSec:CreateToggle("Box", Zeta.Settings.Box.Enabled, function(v)
    Zeta.Settings.Box.Enabled = v
    Window:Notify("Settings Changed", "Box ESP set to: " .. tostring(v), 3)
end)

ESPElementsSec:CreateToggle("Username", Zeta.Settings.Text.Enabled, function(v)
    Zeta.Settings.Text.Enabled = v
    Window:Notify("Settings Changed", "Username ESP set to: " .. tostring(v), 3)
end)

ESPElementsSec:CreateToggle("Tracers", Zeta.Settings.Tracers.Enabled, function(v)
    Zeta.Settings.Tracers.Enabled = v
    Window:Notify("Settings Changed", "Tracers set to: " .. tostring(v), 3)
end)

ESPElementsSec:CreateToggle("Head Circle", Zeta.Settings.Box.HeadCircle.Enabled, function(v)
    Zeta.Settings.Box.HeadCircle.Enabled = v
    Window:Notify("Settings Changed", "Head Circle set to: " .. tostring(v), 3)
end)

ESPElementsSec:CreateToggle("Health Bar", Zeta.Settings.HealthBar.Enabled, function(v)
    Zeta.Settings.HealthBar.Enabled = v
    Window:Notify("Settings Changed", "Health Bar set to: " .. tostring(v), 3)
end)


local ESPColorsSec = VisualsTab:CreateSection("Colors", "Right")

ESPColorsSec:CreateColorPicker("Chams Color", Zeta.Settings.Chams.Color, function(c)
    Zeta.Settings.Chams.Color = c
end)

ESPColorsSec:CreateColorPicker("Box Color", Zeta.Settings.Box.Color, function(c)
    Zeta.Settings.Box.Color = c
end)

ESPColorsSec:CreateColorPicker("Username Color", Zeta.Settings.Text.Color, function(c)
    Zeta.Settings.Text.Color = c
end)

ESPColorsSec:CreateColorPicker("Tracer Color", Zeta.Settings.Tracers.Color, function(c)
    Zeta.Settings.Tracers.Color = c
end)

ESPColorsSec:CreateColorPicker("Head Circle Color", Zeta.Settings.Box.HeadCircle.Color, function(c)
    Zeta.Settings.Box.HeadCircle.Color = c
end)


-- ========================================== --
--            TAB 3: ENVIRONMENT              --
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
    Window:Notify("Settings Changed", "Night Mode set to: " .. tostring(v), 3)
end)
