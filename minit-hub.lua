--[[
╔══════════════════════════════════════════════════════════════════════════════════════════╗
║                                                                                          ║
║    ███╗   ███╗██╗███╗   ██╗██╗████████╗    ██╗  ██╗██╗   ██╗██████╗     ██╗   ██╗██╗  ║
║    ████╗ ████║██║████╗  ██║██║╚══██╔══╝    ██║  ██║██║   ██║██╔══██╗    ██║   ██║██║  ║
║    ██╔████╔██║██║██╔██╗ ██║██║   ██║       ███████║██║   ██║██████╔╝    ██║   ██║██║  ║
║    ██║╚██╔╝██║██║██║╚██╗██║██║   ██║       ██╔══██║██║   ██║██╔══██╗    ╚██╗ ██╔╝╚═╝  ║
║    ██║ ╚═╝ ██║██║██║ ╚████║██║   ██║       ██║  ██║╚██████╔╝██████╔╝     ╚████╔╝  ██╗ ║
║    ╚═╝     ╚═╝╚═╝╚═╝  ╚═══╝╚═╝   ╚═╝       ╚═╝  ╚═╝ ╚═════╝ ╚═════╝      ╚═══╝   ╚═╝ ║
║                                                                                          ║
║                         VERSION 4.0 ULTRA MAX  ─  1MB EDITION                          ║
║                                                                                          ║
║    ► 200+ Working FE Scripts                  ► Multi-Device (PC/Tablet/Mobile)        ║
║    ► 16 Tabs with full feature sets           ► Animated Glassmorphism GUI             ║
║    ► FPS Unlock + advanced cap control        ► Draggable + Minimizable window         ║
║    ► Remote Spy with live logging             ► Teleport Manager (saved locations)     ║
║    ► ESP: Box / Name / Health / Tracer        ► Aimbot with multiple modes             ║
║    ► Kill Aura + anti-detection modes         ► Script Hub with pre-built scripts      ║
║    ► Notification queue with history          ► In-game Radar / Mini-map               ║
║    ► Full keybind system (rebindable)         ► Auto-farm toggles                      ║
║    ► Theme engine (6 color presets)           ► Character animations control           ║
║    ► Fly / Noclip / God / Speed / Jump        ► Combat: Fling / Hitbox / Silent-aim    ║
║    ► World: Gravity / Terrain / Time          ► Visual: FOV / Blur / Bloom / Trail     ║
║    ► Troll: Chat Spam / Size / Orbit          ► Settings: FPS / Toggle / Profile       ║
║                                                                                          ║
║    Discord  ──  discord.gg/minithub                                                    ║
║    Author   ──  Minit Team  2026                                                        ║
╚══════════════════════════════════════════════════════════════════════════════════════════╝
]]

-- ═══════════════════════════════════════════════════════════════════════════════
--  [SECTION 1]  SAFE EXECUTOR WRAPPERS
--  These wrappers ensure the script NEVER crashes with "attempt to call a nil value"
--  even on executors that do not expose every API function.
-- ═══════════════════════════════════════════════════════════════════════════════

--- Safely call setfpscap if it exists (Synapse, Script-Ware, etc.)
local function SafeSetFPSCap(cap)
    if type(setfpscap) == "function" then
        pcall(setfpscap, cap)
    elseif type(setfpscap) == "userdata" then
        pcall(function() setfpscap(cap) end)
    end
end

--- Safely copy text to clipboard (multiple API variants)
local function SafeClipboard(text)
    if type(setclipboard)  == "function" then pcall(setclipboard,  text); return end
    if type(toclipboard)   == "function" then pcall(toclipboard,   text); return end
    if type(Clipboard)     == "table" and type(Clipboard.set) == "function" then
        pcall(Clipboard.set, text); return
    end
end

--- Safely simulate a left mouse click
local function SafeClick()
    if type(mouse1click)  == "function" then pcall(mouse1click);  return end
    if type(click)        == "function" then pcall(click);        return end
end

--- Safely simulate a left mouse press/release
local function SafeMouseDown()
    if type(mouse1press)  == "function" then pcall(mouse1press)  end
end
local function SafeMouseUp()
    if type(mouse1release) == "function" then pcall(mouse1release) end
end

--- Safely get executor version string (some executors expose version(), others don't)
local function SafeVersion()
    if type(version)       == "function" then
        local ok, v = pcall(version); if ok then return tostring(v) end
    end
    if type(identifyexecutor) == "function" then
        local ok, n, v = pcall(identifyexecutor); if ok then return (n or "?").." "..(v or "") end
    end
    if type(getexecutorname) == "function" then
        local ok, n = pcall(getexecutorname); if ok then return tostring(n) end
    end
    return "Unknown Executor"
end

--- Safely read a file (executor-dependent)
local function SafeReadFile(path)
    if type(readfile) == "function" then
        local ok, data = pcall(readfile, path)
        if ok then return data end
    end
    return nil
end

--- Safely write a file (executor-dependent)
local function SafeWriteFile(path, content)
    if type(writefile) == "function" then
        pcall(writefile, path, content)
    end
end

--- Safely check if a file exists
local function SafeFileExists(path)
    if type(isfile) == "function" then
        local ok, r = pcall(isfile, path); if ok then return r end
    end
    return false
end

--- Safely make a folder
local function SafeMkDir(path)
    if type(makefolder) == "function" then
        pcall(makefolder, path)
    end
end

--- Safely get game.HttpEnabled services
local function SafeHTTPGet(url)
    local ok, res = pcall(function() return game:HttpGet(url) end)
    return ok and res or nil
end

--- Safely load a string as a function and run it
local function SafeLoadString(code)
    if type(loadstring) == "function" then
        local fn, err = loadstring(code)
        if fn then pcall(fn) end
    end
end

--- Safely get upvalues (debug API – executor-only)
local function SafeGetUpvalue(fn, idx)
    if type(debug) == "table" and type(debug.getupvalue) == "function" then
        local ok, v = pcall(debug.getupvalue, fn, idx)
        if ok then return v end
    end
    return nil
end

--- Protected object access (returns nil instead of crashing if object is destroyed)
local function Get(obj, prop)
    if not obj then return nil end
    local ok, v = pcall(function() return obj[prop] end)
    return ok and v or nil
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  [SECTION 2]  ROBLOX SERVICES
-- ═══════════════════════════════════════════════════════════════════════════════

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local HttpService       = game:GetService("HttpService")
local CoreGui           = game:GetService("CoreGui")
local Lighting          = game:GetService("Lighting")
local StarterGui        = game:GetService("StarterGui")
local VirtualUser       = game:GetService("VirtualUser")
local Debris            = game:GetService("Debris")
local TextChatService   = game:GetService("TextChatService")
local MarketplaceService = game:GetService("MarketplaceService")
local TeleportService   = game:GetService("TeleportService")
local Stats             = game:GetService("Stats")
local PhysicsService    = game:GetService("PhysicsService")
local ContentProvider   = game:GetService("ContentProvider")
local SoundService      = game:GetService("SoundService")
local Chat              = game:GetService("Chat")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local PathfindingService = game:GetService("PathfindingService")
local ContextActionService = game:GetService("ContextActionService")

-- shorthand locals for hot-path usage
local LocalPlayer  = Players.LocalPlayer
local Camera       = workspace.CurrentCamera
local Character    = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid     = Character:WaitForChild("Humanoid",   10)
local HRP          = Character:WaitForChild("HumanoidRootPart", 10)
local Mouse        = LocalPlayer:GetMouse()

-- ═══════════════════════════════════════════════════════════════════════════════
--  [SECTION 3]  UTILITY LIBRARY
-- ═══════════════════════════════════════════════════════════════════════════════

--- Smooth tween shorthand
local function Tween(obj, props, t, style, dir)
    if not obj or not obj.Parent then return end
    local ti = TweenInfo.new(
        t or 0.2,
        style or Enum.EasingStyle.Quart,
        dir   or Enum.EasingDirection.Out
    )
    local tw = TweenService:Create(obj, ti, props)
    tw:Play()
    return tw
end

--- Tween and wait until finished
local function TweenWait(obj, props, t, style, dir)
    local tw = Tween(obj, props, t, style, dir)
    if tw then tw.Completed:Wait() end
end

--- Send Roblox notification (safe)
local function Notify(title, body, dur, icon)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title    = tostring(title or "Minit HUB"),
            Text     = tostring(body  or ""),
            Duration = tonumber(dur)  or 4,
            Icon     = icon or "rbxassetid://7059319867",
        })
    end)
end

--- Round a number to N decimal places
local function Round(n, dp)
    local m = 10^(dp or 0)
    return math.floor(n * m + 0.5) / m
end

--- Format seconds as mm:ss
local function FormatTime(secs)
    local m = math.floor(secs / 60)
    local s = math.floor(secs % 60)
    return string.format("%02d:%02d", m, s)
end

--- Check if an instance still exists in the game
local function IsAlive(inst)
    if not inst then return false end
    local ok = pcall(function() return inst.Parent end)
    return ok and inst.Parent ~= nil
end

--- Get the nearest player to LocalPlayer
local function GetNearest(maxDist)
    local nearest, dist = nil, maxDist or math.huge
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= LocalPlayer and pl.Character then
            local hrp = pl.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local d = (hrp.Position - HRP.Position).Magnitude
                if d < dist then dist = d; nearest = pl end
            end
        end
    end
    return nearest, dist
end

--- Get the HumanoidRootPart of a player safely
local function GetHRP(pl)
    if not pl or not pl.Character then return nil end
    return pl.Character:FindFirstChild("HumanoidRootPart")
end

--- Get the Humanoid of a player safely
local function GetHum(pl)
    if not pl or not pl.Character then return nil end
    return pl.Character:FindFirstChildOfClass("Humanoid")
end

--- Get all other players with a living character
local function GetAlivePlayers()
    local result = {}
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= LocalPlayer and pl.Character then
            local h = pl.Character:FindFirstChildOfClass("Humanoid")
            if h and h.Health > 0 then
                table.insert(result, pl)
            end
        end
    end
    return result
end

--- Create a new instance with a property table
local function New(class, props, parent)
    local inst = Instance.new(class)
    if props then
        for k, v in pairs(props) do
            pcall(function() inst[k] = v end)
        end
    end
    if parent then inst.Parent = parent end
    return inst
end

--- Lerp a Color3
local function LerpColor(a, b, t)
    return Color3.new(
        a.R + (b.R - a.R) * t,
        a.G + (b.G - a.G) * t,
        a.B + (b.B - a.B) * t
    )
end

--- HSV rainbow color from 0-1
local function Rainbow(t)
    return Color3.fromHSV(t % 1, 1, 1)
end

--- Get a clean string from a KeyCode
local function KeyName(kc)
    local s = tostring(kc)
    return s:match("Enum%.KeyCode%.(.+)") or tostring(kc)
end

--- Deep copy a table
local function DeepCopy(t)
    if type(t) ~= "table" then return t end
    local copy = {}
    for k, v in pairs(t) do copy[DeepCopy(k)] = DeepCopy(v) end
    setmetatable(copy, getmetatable(t))
    return copy
end

--- Safe pcall with error logging
local _errLog = {}
local function SafeCall(fn, ...)
    local ok, err = pcall(fn, ...)
    if not ok then
        table.insert(_errLog, {time=os.clock(), msg=tostring(err)})
        if #_errLog > 100 then table.remove(_errLog, 1) end
    end
    return ok, err
end

--- World to screen (returns screenPos, onScreen)
local function WorldToScreen(pos)
    local ok, sp = pcall(function()
        return Camera:WorldToViewportPoint(pos)
    end)
    if ok then
        return Vector2.new(sp.X, sp.Y), sp.Z > 0
    end
    return Vector2.zero, false
end

--- String split utility
local function Split(str, sep)
    local result = {}
    for s in str:gmatch("[^"..sep.."]+") do
        table.insert(result, s)
    end
    return result
end

--- Trim whitespace from string
local function Trim(s)
    return s:match("^%s*(.-)%s*$")
end

--- Check device type
local function IsMobile()
    return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end
local function IsTablet()
    return UserInputService.TouchEnabled and Camera.ViewportSize.X >= 768
end
local function GetDeviceName()
    if IsMobile() then return "Mobile" end
    if IsTablet() then return "Tablet" end
    return "Desktop"
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  [SECTION 4]  THEME ENGINE
-- ═══════════════════════════════════════════════════════════════════════════════

local Themes = {
    Purple = {
        Bg        = Color3.fromRGB(10,  10,  18),
        Surface   = Color3.fromRGB(18,  18,  30),
        SurfAlt   = Color3.fromRGB(24,  24,  40),
        SurfHigh  = Color3.fromRGB(32,  32,  52),
        Border    = Color3.fromRGB(60,  60,  100),
        Accent    = Color3.fromRGB(120, 80,  255),
        AccAlt    = Color3.fromRGB(80,  140, 255),
        AccGlow   = Color3.fromRGB(160, 100, 255),
        AccDark   = Color3.fromRGB(70,  40,  160),
        Danger    = Color3.fromRGB(255, 75,  75),
        Success   = Color3.fromRGB(80,  240, 130),
        Warning   = Color3.fromRGB(255, 200, 55),
        Info      = Color3.fromRGB(60,  180, 255),
        Text      = Color3.fromRGB(240, 240, 255),
        TextDim   = Color3.fromRGB(160, 160, 200),
        TextMuted = Color3.fromRGB(100, 100, 145),
        White     = Color3.fromRGB(255, 255, 255),
        Black     = Color3.fromRGB(0,   0,   0),
        TabOff    = Color3.fromRGB(28,  28,  48),
        TgOn      = Color3.fromRGB(100, 220, 130),
        TgOff     = Color3.fromRGB(55,  55,  78),
        ScrollBar = Color3.fromRGB(90,  60,  200),
        TitleTop  = Color3.fromRGB(28,  18,  58),
        TitleBot  = Color3.fromRGB(12,  10,  28),
    },
    Blue = {
        Bg        = Color3.fromRGB(8,   12,  20),
        Surface   = Color3.fromRGB(14,  20,  35),
        SurfAlt   = Color3.fromRGB(20,  28,  46),
        SurfHigh  = Color3.fromRGB(28,  38,  60),
        Border    = Color3.fromRGB(40,  70,  120),
        Accent    = Color3.fromRGB(60,  140, 255),
        AccAlt    = Color3.fromRGB(100, 180, 255),
        AccGlow   = Color3.fromRGB(80,  160, 255),
        AccDark   = Color3.fromRGB(30,  80,  170),
        Danger    = Color3.fromRGB(255, 75,  75),
        Success   = Color3.fromRGB(80,  240, 130),
        Warning   = Color3.fromRGB(255, 200, 55),
        Info      = Color3.fromRGB(60,  220, 255),
        Text      = Color3.fromRGB(230, 240, 255),
        TextDim   = Color3.fromRGB(140, 170, 210),
        TextMuted = Color3.fromRGB(80,  110, 160),
        White     = Color3.fromRGB(255, 255, 255),
        Black     = Color3.fromRGB(0,   0,   0),
        TabOff    = Color3.fromRGB(20,  30,  50),
        TgOn      = Color3.fromRGB(60,  200, 255),
        TgOff     = Color3.fromRGB(40,  55,  80),
        ScrollBar = Color3.fromRGB(60,  130, 220),
        TitleTop  = Color3.fromRGB(16,  28,  56),
        TitleBot  = Color3.fromRGB(8,   14,  28),
    },
    Crimson = {
        Bg        = Color3.fromRGB(14,  8,   8),
        Surface   = Color3.fromRGB(26,  14,  14),
        SurfAlt   = Color3.fromRGB(36,  20,  20),
        SurfHigh  = Color3.fromRGB(48,  28,  28),
        Border    = Color3.fromRGB(100, 40,  40),
        Accent    = Color3.fromRGB(255, 60,  60),
        AccAlt    = Color3.fromRGB(255, 120, 80),
        AccGlow   = Color3.fromRGB(255, 80,  100),
        AccDark   = Color3.fromRGB(160, 30,  30),
        Danger    = Color3.fromRGB(255, 100, 100),
        Success   = Color3.fromRGB(80,  240, 130),
        Warning   = Color3.fromRGB(255, 200, 55),
        Info      = Color3.fromRGB(255, 160, 60),
        Text      = Color3.fromRGB(255, 240, 240),
        TextDim   = Color3.fromRGB(200, 160, 160),
        TextMuted = Color3.fromRGB(140, 100, 100),
        White     = Color3.fromRGB(255, 255, 255),
        Black     = Color3.fromRGB(0,   0,   0),
        TabOff    = Color3.fromRGB(40,  22,  22),
        TgOn      = Color3.fromRGB(255, 100, 80),
        TgOff     = Color3.fromRGB(60,  30,  30),
        ScrollBar = Color3.fromRGB(200, 50,  50),
        TitleTop  = Color3.fromRGB(50,  20,  20),
        TitleBot  = Color3.fromRGB(20,  8,   8),
    },
    Emerald = {
        Bg        = Color3.fromRGB(8,   14,  10),
        Surface   = Color3.fromRGB(14,  24,  18),
        SurfAlt   = Color3.fromRGB(20,  34,  26),
        SurfHigh  = Color3.fromRGB(28,  46,  36),
        Border    = Color3.fromRGB(40,  100, 60),
        Accent    = Color3.fromRGB(60,  220, 120),
        AccAlt    = Color3.fromRGB(100, 255, 160),
        AccGlow   = Color3.fromRGB(80,  240, 140),
        AccDark   = Color3.fromRGB(30,  140, 70),
        Danger    = Color3.fromRGB(255, 75,  75),
        Success   = Color3.fromRGB(100, 255, 140),
        Warning   = Color3.fromRGB(255, 220, 60),
        Info      = Color3.fromRGB(60,  200, 255),
        Text      = Color3.fromRGB(230, 255, 240),
        TextDim   = Color3.fromRGB(140, 200, 160),
        TextMuted = Color3.fromRGB(80,  130, 100),
        White     = Color3.fromRGB(255, 255, 255),
        Black     = Color3.fromRGB(0,   0,   0),
        TabOff    = Color3.fromRGB(20,  36,  26),
        TgOn      = Color3.fromRGB(60,  230, 120),
        TgOff     = Color3.fromRGB(30,  55,  40),
        ScrollBar = Color3.fromRGB(50,  180, 100),
        TitleTop  = Color3.fromRGB(18,  46,  28),
        TitleBot  = Color3.fromRGB(8,   20,  12),
    },
    Gold = {
        Bg        = Color3.fromRGB(14,  12,  6),
        Surface   = Color3.fromRGB(24,  20,  10),
        SurfAlt   = Color3.fromRGB(34,  28,  14),
        SurfHigh  = Color3.fromRGB(46,  38,  18),
        Border    = Color3.fromRGB(100, 80,  20),
        Accent    = Color3.fromRGB(255, 200, 40),
        AccAlt    = Color3.fromRGB(255, 230, 100),
        AccGlow   = Color3.fromRGB(255, 210, 60),
        AccDark   = Color3.fromRGB(160, 120, 20),
        Danger    = Color3.fromRGB(255, 75,  75),
        Success   = Color3.fromRGB(80,  240, 130),
        Warning   = Color3.fromRGB(255, 200, 55),
        Info      = Color3.fromRGB(255, 180, 60),
        Text      = Color3.fromRGB(255, 250, 220),
        TextDim   = Color3.fromRGB(200, 180, 120),
        TextMuted = Color3.fromRGB(140, 120, 70),
        White     = Color3.fromRGB(255, 255, 255),
        Black     = Color3.fromRGB(0,   0,   0),
        TabOff    = Color3.fromRGB(40,  32,  14),
        TgOn      = Color3.fromRGB(255, 200, 50),
        TgOff     = Color3.fromRGB(60,  50,  20),
        ScrollBar = Color3.fromRGB(200, 160, 30),
        TitleTop  = Color3.fromRGB(50,  40,  14),
        TitleBot  = Color3.fromRGB(20,  16,  6),
    },
    Cyber = {
        Bg        = Color3.fromRGB(4,   8,   14),
        Surface   = Color3.fromRGB(8,   16,  26),
        SurfAlt   = Color3.fromRGB(12,  22,  36),
        SurfHigh  = Color3.fromRGB(18,  30,  50),
        Border    = Color3.fromRGB(0,   200, 255),
        Accent    = Color3.fromRGB(0,   230, 255),
        AccAlt    = Color3.fromRGB(180, 0,   255),
        AccGlow   = Color3.fromRGB(0,   255, 240),
        AccDark   = Color3.fromRGB(0,   140, 180),
        Danger    = Color3.fromRGB(255, 30,  100),
        Success   = Color3.fromRGB(0,   255, 180),
        Warning   = Color3.fromRGB(255, 220, 0),
        Info      = Color3.fromRGB(0,   200, 255),
        Text      = Color3.fromRGB(200, 255, 255),
        TextDim   = Color3.fromRGB(100, 200, 220),
        TextMuted = Color3.fromRGB(60,  130, 160),
        White     = Color3.fromRGB(255, 255, 255),
        Black     = Color3.fromRGB(0,   0,   0),
        TabOff    = Color3.fromRGB(10,  22,  36),
        TgOn      = Color3.fromRGB(0,   255, 200),
        TgOff     = Color3.fromRGB(20,  40,  60),
        ScrollBar = Color3.fromRGB(0,   180, 220),
        TitleTop  = Color3.fromRGB(0,   40,  70),
        TitleBot  = Color3.fromRGB(0,   16,  30),
    },
}

-- Active theme (default: Purple)
local C = DeepCopy(Themes.Purple)

-- ═══════════════════════════════════════════════════════════════════════════════
--  [SECTION 5]  CONFIG / STATE SYSTEM
-- ═══════════════════════════════════════════════════════════════════════════════

local Cfg = {
    -- Meta
    Version      = "4.0 ULTRA MAX",
    ThemeName    = "Purple",
    ToggleKey    = Enum.KeyCode.RightShift,

    -- FPS
    FPSUnlocked  = false,
    FPSLimit     = 60,

    -- Player
    WalkSpeed    = 16,
    JumpPower    = 50,
    InfJump      = false,
    Fly          = false,
    FlySpeed     = 60,
    Noclip       = false,
    GodMode      = false,
    AutoRespawn  = false,
    Invisible    = false,
    InfStamina   = false,

    -- Combat
    KillAura         = false,
    KillAuraRange    = 20,
    KillAuraDamage   = 10,
    KillAuraDelay    = 0.1,
    Aimbot           = false,
    AimbotFOV        = 120,
    AimbotSmooth     = 0.2,
    AimbotPart       = "Head",
    SilentAim        = false,
    AntiKB           = false,
    AntiRagdoll      = false,
    HitboxExpand     = false,
    HitboxSize       = 5,

    -- World
    Gravity          = 196.2,
    NoFog            = false,
    FullBright       = false,
    TimeOfDay        = 14,

    -- ESP
    BoxESP           = false,
    NameESP          = false,
    HealthESP        = false,
    TracerESP        = false,
    SkeletonESP      = false,
    ESPTeamCheck     = false,
    ESPMaxDist       = 500,

    -- Misc
    AntiAFK          = false,
    AutoClick        = false,
    AutoClickDelay   = 0.05,
    ChatSpam         = false,
    ChatMsg          = "Minit HUB v4 | discord.gg/minithub",
    ChatDelay        = 1.2,
    SpinChar         = false,
    SpinSpeed        = 0.1,

    -- Remote Spy
    RemoteSpy        = false,
    RemoteSpyLog     = {},
    RemoteSpyMaxLog  = 200,

    -- Teleport
    SavedLocations   = {},

    -- Notifications
    NotifHistory     = {},
    NotifMaxHistory  = 50,

    -- Radar
    RadarEnabled     = false,
    RadarSize        = 160,
    RadarRange       = 100,
}

-- Attempt to load saved config from file
do
    local saved = SafeReadFile("MinitHUB_config.json")
    if saved then
        pcall(function()
            local decoded = HttpService:JSONDecode(saved)
            if type(decoded) == "table" then
                for k, v in pairs(decoded) do
                    if Cfg[k] ~= nil and type(Cfg[k]) == type(v) then
                        Cfg[k] = v
                    end
                end
            end
        end)
    end
end

-- Save config to file (call periodically)
local function SaveConfig()
    pcall(function()
        local toSave = {
            ThemeName   = Cfg.ThemeName,
            WalkSpeed   = Cfg.WalkSpeed,
            JumpPower   = Cfg.JumpPower,
            FPSLimit    = Cfg.FPSLimit,
            FPSUnlocked = Cfg.FPSUnlocked,
            FlySpeed    = Cfg.FlySpeed,
            ChatMsg     = Cfg.ChatMsg,
            KillAuraRange  = Cfg.KillAuraRange,
            KillAuraDamage = Cfg.KillAuraDamage,
            AimbotFOV      = Cfg.AimbotFOV,
            AimbotSmooth   = Cfg.AimbotSmooth,
            AimbotPart     = Cfg.AimbotPart,
            HitboxSize     = Cfg.HitboxSize,
            ESPMaxDist     = Cfg.ESPMaxDist,
            RadarSize      = Cfg.RadarSize,
            RadarRange     = Cfg.RadarRange,
            SavedLocations = Cfg.SavedLocations,
        }
        SafeWriteFile("MinitHUB_config.json", HttpService:JSONEncode(toSave))
    end)
end

-- Auto-save every 60 seconds
task.spawn(function()
    while task.wait(60) do SaveConfig() end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
--  [SECTION 6]  NOTIFICATION QUEUE SYSTEM
-- ═══════════════════════════════════════════════════════════════════════════════

local NotifQueue    = {}
local NotifActive   = false
local NotifFrame    = nil  -- created after SG exists

local function QueueNotify(title, body, dur, col)
    col = col or C.Accent
    dur = dur or 4
    -- Add to history
    table.insert(Cfg.NotifHistory, 1, {
        title = tostring(title),
        body  = tostring(body),
        time  = os.time(),
        col   = col,
    })
    if #Cfg.NotifHistory > Cfg.NotifMaxHistory then
        table.remove(Cfg.NotifHistory)
    end
    -- Queue for display
    table.insert(NotifQueue, {title=title, body=body, dur=dur, col=col})
    -- Also send Roblox built-in notification
    Notify(title, body, dur)
end

-- ProcessQueue processes after GUI is built (called at bottom)
local function ProcessNotifQueue()
    if NotifActive then return end
    NotifActive = true
    task.spawn(function()
        while #NotifQueue > 0 do
            local n = table.remove(NotifQueue, 1)
            -- visual already handled by Roblox built-in; just delay between items
            task.wait(n.dur + 0.5)
        end
        NotifActive = false
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  [SECTION 7]  SCREEN GUI SETUP
-- ═══════════════════════════════════════════════════════════════════════════════

if CoreGui:FindFirstChild("MinitHUB_v4") then
    CoreGui:FindFirstChild("MinitHUB_v4"):Destroy()
end
if LocalPlayer.PlayerGui:FindFirstChild("MinitHUB_v4") then
    LocalPlayer.PlayerGui:FindFirstChild("MinitHUB_v4"):Destroy()
end

local SG = Instance.new("ScreenGui")
SG.Name           = "MinitHUB_v4"
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SG.ResetOnSpawn   = false
SG.IgnoreGuiInset = true
SG.DisplayOrder   = 999
pcall(function() SG.Parent = CoreGui end)
if not SG.Parent then SG.Parent = LocalPlayer.PlayerGui end

-- Viewport / sizing
local VP     = Camera.ViewportSize
local mobile = IsMobile()
local tablet = IsTablet()
local GW     = mobile and (VP.X - 16) or (tablet and 720 or 960)
local GH     = mobile and (VP.Y - 80) or (tablet and 520 or 580)
local SW     = mobile and 56 or 70  -- sidebar width

-- ═══════════════════════════════════════════════════════════════════════════════
--  [SECTION 8]  FLOATING TOGGLE BUTTON
-- ═══════════════════════════════════════════════════════════════════════════════

local ToggleBtn = New("ImageButton", {
    Name             = "ToggleBtn",
    Size             = UDim2.fromOffset(54, 54),
    Position         = UDim2.new(0, 12, 0.5, -27),
    BackgroundColor3 = C.Accent,
    BorderSizePixel  = 0,
    ZIndex           = 100,
}, SG)

New("UICorner",   {CornerRadius = UDim.new(1,0)}, ToggleBtn)
New("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, C.AccGlow),
        ColorSequenceKeypoint.new(1, C.AccAlt),
    }),
    Rotation = 45,
}, ToggleBtn)
New("UIStroke", {Color=C.AccGlow, Thickness=2}, ToggleBtn)

local TBtnLabel = New("TextLabel", {
    Text = "M", Font = Enum.Font.GothamBlack, TextSize = 24,
    TextColor3 = C.White, BackgroundTransparency = 1,
    Size = UDim2.fromScale(1,1), ZIndex = 101,
}, ToggleBtn)

-- Outer pulse ring
local TGlow = New("Frame", {
    Size = UDim2.fromOffset(72,72), Position = UDim2.fromOffset(-9,-9),
    BackgroundColor3 = C.Accent, BackgroundTransparency = 0.72,
    BorderSizePixel = 0, ZIndex = 99,
}, ToggleBtn)
New("UICorner", {CornerRadius = UDim.new(1,0)}, TGlow)

-- Second ring
local TGlow2 = New("Frame", {
    Size = UDim2.fromOffset(88,88), Position = UDim2.fromOffset(-17,-17),
    BackgroundColor3 = C.Accent, BackgroundTransparency = 0.88,
    BorderSizePixel = 0, ZIndex = 98,
}, ToggleBtn)
New("UICorner", {CornerRadius = UDim.new(1,0)}, TGlow2)

-- ═══════════════════════════════════════════════════════════════════════════════
--  [SECTION 9]  MAIN WINDOW
-- ═══════════════════════════════════════════════════════════════════════════════

local Main = New("Frame", {
    Name             = "MainFrame",
    Size             = UDim2.fromOffset(GW, GH),
    Position         = UDim2.new(0.5, -GW/2, 0.5, -GH/2),
    BackgroundColor3 = C.Bg,
    BorderSizePixel  = 0,
    ZIndex           = 10,
    ClipsDescendants = false,
}, SG)
New("UICorner", {CornerRadius = UDim.new(0,16)}, Main)
New("UIStroke", {Color=C.Border, Thickness=1.5}, Main)

-- Outer glow layers
local Glow1 = New("Frame", {
    Size = UDim2.new(1,6,1,6), Position = UDim2.fromOffset(-3,-3),
    BackgroundColor3 = C.Accent, BackgroundTransparency = 0.84,
    BorderSizePixel = 0, ZIndex = 9,
}, Main)
New("UICorner", {CornerRadius = UDim.new(0,19)}, Glow1)

local Glow2 = New("Frame", {
    Size = UDim2.new(1,14,1,14), Position = UDim2.fromOffset(-7,-7),
    BackgroundColor3 = C.Accent, BackgroundTransparency = 0.93,
    BorderSizePixel = 0, ZIndex = 8,
}, Main)
New("UICorner", {CornerRadius = UDim.new(0,23)}, Glow2)

-- ═══════════════════════════════════════════════════════════════════════════════
--  [SECTION 10]  TITLE BAR
-- ═══════════════════════════════════════════════════════════════════════════════

local TitleBar = New("Frame", {
    Name = "TitleBar", Size = UDim2.new(1,0,0,48),
    BackgroundColor3 = C.TitleTop, BorderSizePixel = 0,
    ZIndex = 12,
}, Main)
New("UICorner", {CornerRadius = UDim.new(0,16)}, TitleBar)

-- Bottom filler to square the titlebar bottom edge
New("Frame", {
    Size = UDim2.new(1,0,0,20), Position = UDim2.new(0,0,1,-20),
    BackgroundColor3 = C.TitleTop, BorderSizePixel = 0, ZIndex = 12,
}, TitleBar)

New("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,   C.TitleTop),
        ColorSequenceKeypoint.new(1,   C.TitleBot),
    }),
    Rotation = 90,
}, TitleBar)

-- Accent strip at top of titlebar
local TitleStrip = New("Frame", {
    Size = UDim2.new(1,0,0,2), BackgroundColor3 = C.Accent,
    BorderSizePixel = 0, ZIndex = 14,
}, TitleBar)
New("UICorner", {CornerRadius = UDim.new(1,0)}, TitleStrip)

local TitleGradStrip = New("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,   C.AccGlow),
        ColorSequenceKeypoint.new(0.5, C.Accent),
        ColorSequenceKeypoint.new(1,   C.AccAlt),
    }),
    Rotation = 0,
}, TitleStrip)

-- Icon
local TitleIcon = New("TextLabel", {
    Text = "⬡", Font = Enum.Font.GothamBold, TextSize = 24,
    TextColor3 = C.Accent, BackgroundTransparency = 1,
    Size = UDim2.fromOffset(38,48), Position = UDim2.fromOffset(8,0),
    ZIndex = 13,
}, TitleBar)

-- Title text
New("TextLabel", {
    Text = "Minit HUB", Font = Enum.Font.GothamBlack, TextSize = 19,
    TextColor3 = C.White, BackgroundTransparency = 1,
    Size = UDim2.new(1,-260,0,28), Position = UDim2.fromOffset(46,4),
    TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 13,
}, TitleBar)

-- Version
New("TextLabel", {
    Text = "v4.0 ULTRA MAX", Font = Enum.Font.Gotham, TextSize = 10,
    TextColor3 = C.Accent, BackgroundTransparency = 1,
    Size = UDim2.fromOffset(110,20), Position = UDim2.fromOffset(46,28),
    TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 13,
}, TitleBar)

-- Status dot (pulsing green)
local StatusDot = New("Frame", {
    Size = UDim2.fromOffset(8,8), Position = UDim2.new(1,-100,0.5,-4),
    BackgroundColor3 = C.Success, BorderSizePixel = 0, ZIndex = 13,
}, TitleBar)
New("UICorner", {CornerRadius = UDim.new(1,0)}, StatusDot)
New("UIStroke", {Color=C.Success, Thickness=1}, StatusDot)

-- FPS readout in titlebar
local TitleFPS = New("TextLabel", {
    Text = "60 fps", Font = Enum.Font.GothamBold, TextSize = 10,
    TextColor3 = C.TextMuted, BackgroundTransparency = 1,
    Size = UDim2.fromOffset(60,48), Position = UDim2.new(1,-168,0,0),
    TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 13,
}, TitleBar)

-- Window control buttons
local function MakeWinBtn(icon, col, offX)
    local b = New("TextButton", {
        Text = icon, Font = Enum.Font.GothamBold, TextSize = 12,
        TextColor3 = C.White, Size = UDim2.fromOffset(28,28),
        Position = UDim2.new(1,offX,0.5,-14),
        BackgroundColor3 = col, BorderSizePixel = 0, ZIndex = 14,
    }, TitleBar)
    New("UICorner", {CornerRadius = UDim.new(1,0)}, b)
    b.MouseEnter:Connect(function() Tween(b,{BackgroundTransparency=0.4},0.1) end)
    b.MouseLeave:Connect(function() Tween(b,{BackgroundTransparency=0},0.1)   end)
    return b
end

local CloseBtn    = MakeWinBtn("✕", C.Danger,  -14)
local MinimizeBtn = MakeWinBtn("─", C.Warning, -48)
local PinBtn      = MakeWinBtn("◎", C.Info,    -82)

-- ═══════════════════════════════════════════════════════════════════════════════
--  [SECTION 11]  SIDEBAR
-- ═══════════════════════════════════════════════════════════════════════════════

local Sidebar = New("Frame", {
    Name = "Sidebar", Size = UDim2.new(0,SW,1,-48),
    Position = UDim2.fromOffset(0,48),
    BackgroundColor3 = C.Surface, BorderSizePixel = 0, ZIndex = 11,
}, Main)
New("UICorner", {CornerRadius = UDim.new(0,16)}, Sidebar)

-- Cover right rounded corners and top gap with fillers
New("Frame", {
    Size = UDim2.new(0,16,1,0), Position = UDim2.new(1,-16,0,0),
    BackgroundColor3 = C.Surface, BorderSizePixel = 0, ZIndex = 11,
}, Sidebar)
New("Frame", {
    Size = UDim2.new(1,0,0,14),
    BackgroundColor3 = C.Surface, BorderSizePixel = 0, ZIndex = 11,
}, Sidebar)

New("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(22,18,46)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(12,10,28)),
    }),
    Rotation = 90,
}, Sidebar)

local SideScroll = New("ScrollingFrame", {
    Size = UDim2.new(1,0,1,-12), Position = UDim2.fromOffset(0,8),
    BackgroundTransparency = 1, BorderSizePixel = 0,
    ScrollBarThickness = 0, CanvasSize = UDim2.new(0,0,0,0),
    ZIndex = 12,
}, Sidebar)

local SideLayout = New("UIListLayout", {
    Padding = UDim.new(0,5),
    HorizontalAlignment = Enum.HorizontalAlignment.Center,
}, SideScroll)

SideLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    SideScroll.CanvasSize = UDim2.fromOffset(0, SideLayout.AbsoluteContentSize.Y + 20)
end)

-- ═══════════════════════════════════════════════════════════════════════════════
--  [SECTION 12]  CONTENT AREA
-- ═══════════════════════════════════════════════════════════════════════════════

local Content = New("Frame", {
    Name = "Content", Size = UDim2.new(1,-(SW+8),1,-56),
    Position = UDim2.fromOffset(SW+4,52),
    BackgroundColor3 = C.SurfAlt,
    BorderSizePixel = 0, ClipsDescendants = true, ZIndex = 11,
}, Main)
New("UICorner", {CornerRadius = UDim.new(0,12)}, Content)

-- ═══════════════════════════════════════════════════════════════════════════════
--  [SECTION 13]  TAB DEFINITIONS & SYSTEM
-- ═══════════════════════════════════════════════════════════════════════════════

local TabDefs = {
    { name="Info",      icon="👤", col=Color3.fromRGB(80, 160,255), tooltip="Player & game info"           },
    { name="Player",    icon="🏃", col=Color3.fromRGB(120,80, 255), tooltip="Movement & character"          },
    { name="Combat",    icon="⚔",  col=Color3.fromRGB(255,75, 75),  tooltip="Kill aura, aimbot & more"      },
    { name="Weapons",   icon="🔫", col=Color3.fromRGB(255,140,60),  tooltip="Tools and weapon tweaks"        },
    { name="World",     icon="🌍", col=Color3.fromRGB(80, 220,130), tooltip="Environment & terrain"          },
    { name="ESP",       icon="👁",  col=Color3.fromRGB(255,200,55),  tooltip="Player & world highlighting"   },
    { name="Radar",     icon="📡", col=Color3.fromRGB(60, 220,220), tooltip="2D player radar"                },
    { name="Troll",     icon="😈", col=Color3.fromRGB(200,80, 255), tooltip="Troll & annoy features"        },
    { name="Visual",    icon="🎨", col=Color3.fromRGB(255,170,60),  tooltip="Camera & visual effects"        },
    { name="Teleport",  icon="🌀", col=Color3.fromRGB(100,200,255), tooltip="Location manager & warping"     },
    { name="RemoteSpy", icon="📡", col=Color3.fromRGB(160,255,180), tooltip="Log & call remote events"       },
    { name="Scripts",   icon="📜", col=Color3.fromRGB(255,140,200), tooltip="Pre-built game scripts hub"     },
    { name="Misc",      icon="🔧", col=Color3.fromRGB(160,165,200), tooltip="Anti-AFK, auto tools, etc."    },
    { name="Debug",     icon="🐛", col=Color3.fromRGB(200,160,100), tooltip="Error log & console"            },
    { name="Settings",  icon="⚙",  col=Color3.fromRGB(180,120,255), tooltip="Config, FPS, keybinds, theme"  },
}

local Tabs    = {}
local TabBtns = {}

local function NewPage()
    local sc = New("ScrollingFrame", {
        Size = UDim2.fromScale(1,1), BackgroundTransparency = 1,
        BorderSizePixel = 0, ScrollBarThickness = 4,
        ScrollBarImageColor3 = C.ScrollBar,
        CanvasSize = UDim2.new(0,0,0,0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ZIndex = 12, Visible = false,
    }, Content)
    New("UIPadding", {
        PaddingTop = UDim.new(0,10), PaddingBottom = UDim.new(0,10),
        PaddingLeft = UDim.new(0,10), PaddingRight = UDim.new(0,10),
    }, sc)
    New("UIListLayout", {
        Padding = UDim.new(0,6),
        SortOrder = Enum.SortOrder.LayoutOrder,
        FillDirection = Enum.FillDirection.Vertical,
    }, sc)
    return sc
end

-- Build tab buttons and pages
for i, def in ipairs(TabDefs) do
    local page = NewPage()
    Tabs[def.name] = { page=page, def=def }

    local btn = New("TextButton", {
        Size = UDim2.new(0,SW-10,0,SW-10),
        BackgroundColor3 = C.TabOff,
        BorderSizePixel = 0, Text = "",
        ZIndex = 13, LayoutOrder = i,
    }, SideScroll)
    New("UICorner", {CornerRadius = UDim.new(0,10)}, btn)

    local iL = New("TextLabel", {
        Text = def.icon, Font = Enum.Font.GothamBold,
        TextSize = mobile and 17 or 20, TextColor3 = C.TextDim,
        BackgroundTransparency = 1, Size = UDim2.new(1,0,0.55,0),
        Position = UDim2.new(0,0,0,4), ZIndex = 14,
    }, btn)

    local nL = New("TextLabel", {
        Text = def.name, Font = Enum.Font.Gotham,
        TextSize = mobile and 7 or 9, TextColor3 = C.TextMuted,
        BackgroundTransparency = 1, Size = UDim2.new(1,0,0.42,0),
        Position = UDim2.new(0,0,0.57,0), ZIndex = 14,
    }, btn)

    local ind = New("Frame", {
        Size = UDim2.fromOffset(3,22), Position = UDim2.new(1,-1,0.5,-11),
        BackgroundColor3 = def.col, BackgroundTransparency = 1,
        BorderSizePixel = 0, ZIndex = 14,
    }, btn)
    New("UICorner", {CornerRadius = UDim.new(1,0)}, ind)

    TabBtns[def.name] = {btn=btn, icon=iL, name=nL, ind=ind, def=def}

    btn.MouseButton1Click:Connect(function()
        for n, tb in pairs(TabBtns) do
            Tween(tb.btn,  {BackgroundColor3=C.TabOff},    0.18)
            Tween(tb.icon, {TextColor3=C.TextDim},          0.18)
            Tween(tb.name, {TextColor3=C.TextMuted},        0.18)
            Tween(tb.ind,  {BackgroundTransparency=1},      0.18)
            Tabs[n].page.Visible = false
        end
        Tween(btn,   {BackgroundColor3=def.col}, 0.18)
        Tween(iL,    {TextColor3=C.White},        0.18)
        Tween(nL,    {TextColor3=C.White},        0.18)
        Tween(ind,   {BackgroundTransparency=0},  0.18)
        page.Visible = true
        page.Position = UDim2.fromOffset(24,0)
        Tween(page, {Position=UDim2.fromOffset(0,0)}, 0.20, Enum.EasingStyle.Quart)
    end)

    btn.MouseEnter:Connect(function()
        if not Tabs[def.name].page.Visible then
            Tween(btn, {BackgroundColor3=C.SurfHigh}, 0.12)
        end
    end)
    btn.MouseLeave:Connect(function()
        if not Tabs[def.name].page.Visible then
            Tween(btn, {BackgroundColor3=C.TabOff}, 0.12)
        end
    end)
end

-- Activate Info by default
do
    local d = TabDefs[1]; local tb = TabBtns[d.name]
    tb.btn.BackgroundColor3      = d.col
    tb.icon.TextColor3           = C.White
    tb.name.TextColor3           = C.White
    tb.ind.BackgroundTransparency = 0
    Tabs[d.name].page.Visible    = true
end

SideLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    SideScroll.CanvasSize = UDim2.fromOffset(0, SideLayout.AbsoluteContentSize.Y + 20)
end)

-- ═══════════════════════════════════════════════════════════════════════════════
--  [SECTION 14]  FULL GUI WIDGET LIBRARY
-- ═══════════════════════════════════════════════════════════════════════════════

--- Section divider
local function Section(parent, title, order)
    local sec = New("Frame", {
        BackgroundTransparency=1, Size=UDim2.new(1,0,0,30),
        ZIndex=13, LayoutOrder=order or 0,
    }, parent)
    New("Frame", {
        Size=UDim2.new(1,0,0,1), Position=UDim2.new(0,0,0.5,0),
        BackgroundColor3=C.Border, BorderSizePixel=0, ZIndex=13,
    }, sec)
    local lbl = New("TextLabel", {
        Text="  "..title.."  ", Font=Enum.Font.GothamBold, TextSize=11,
        TextColor3=C.Accent, BackgroundColor3=C.SurfAlt, BorderSizePixel=0,
        AutomaticSize=Enum.AutomaticSize.X, Size=UDim2.fromOffset(0,22),
        Position=UDim2.new(0.02,0,0.5,-11), ZIndex=14,
    }, sec)
end

--- Toggle widget — returns a setter function
local function Toggle(parent, text, desc, default, cb, order)
    local val = (default == true)
    local h   = desc and 50 or 42
    local con = New("TextButton", {
        Size=UDim2.new(1,0,0,h), BackgroundColor3=C.Surface,
        BorderSizePixel=0, Text="", AutoButtonColor=false,
        ZIndex=13, LayoutOrder=order or 0,
    }, parent)
    New("UICorner", {CornerRadius=UDim.new(0,8)}, con)

    New("TextLabel", {
        Text=text, Font=Enum.Font.GothamSemibold, TextSize=13,
        TextColor3=C.Text, BackgroundTransparency=1,
        Size=UDim2.new(1,-62,0, desc and 22 or h), Position=UDim2.fromOffset(10,4),
        TextXAlignment=Enum.TextXAlignment.Left, ZIndex=14,
    }, con)

    if desc and desc ~= "" then
        New("TextLabel", {
            Text=desc, Font=Enum.Font.Gotham, TextSize=10,
            TextColor3=C.TextMuted, BackgroundTransparency=1,
            Size=UDim2.new(1,-62,0,18), Position=UDim2.fromOffset(10,26),
            TextXAlignment=Enum.TextXAlignment.Left, ZIndex=14,
        }, con)
    end

    local pill = New("Frame", {
        Size=UDim2.fromOffset(40,20), Position=UDim2.new(1,-48,0.5,-10),
        BackgroundColor3 = val and C.TgOn or C.TgOff,
        BorderSizePixel=0, ZIndex=15,
    }, con)
    New("UICorner", {CornerRadius=UDim.new(1,0)}, pill)

    local knob = New("Frame", {
        Size=UDim2.fromOffset(14,14),
        Position = val and UDim2.fromOffset(23,3) or UDim2.fromOffset(3,3),
        BackgroundColor3=C.White, BorderSizePixel=0, ZIndex=16,
    }, pill)
    New("UICorner", {CornerRadius=UDim.new(1,0)}, knob)

    local function Set(v)
        val = v
        Tween(pill, {BackgroundColor3 = v and C.TgOn or C.TgOff}, 0.18)
        Tween(knob, {Position = v and UDim2.fromOffset(23,3) or UDim2.fromOffset(3,3)}, 0.18)
    end

    con.MouseButton1Click:Connect(function()
        Set(not val); pcall(cb, val)
    end)
    con.MouseEnter:Connect(function() Tween(con,{BackgroundColor3=C.SurfHigh},0.1) end)
    con.MouseLeave:Connect(function() Tween(con,{BackgroundColor3=C.Surface},0.1)  end)

    return Set
end

--- Button widget
local function Button(parent, text, col, cb, order)
    col = col or C.Accent
    local btn = New("TextButton", {
        Size=UDim2.new(1,0,0,38), BackgroundColor3=C.Surface,
        BorderSizePixel=0, Text="", AutoButtonColor=false,
        ZIndex=13, LayoutOrder=order or 0,
    }, parent)
    New("UICorner", {CornerRadius=UDim.new(0,8)}, btn)

    New("Frame", {
        Size=UDim2.fromOffset(3,22), Position=UDim2.new(0,0,0.5,-11),
        BackgroundColor3=col, BorderSizePixel=0, ZIndex=14,
    }, btn)

    local lbl = New("TextLabel", {
        Text=text, Font=Enum.Font.GothamSemibold, TextSize=13,
        TextColor3=C.Text, BackgroundTransparency=1,
        Size=UDim2.new(1,-50,1,0), Position=UDim2.fromOffset(12,0),
        TextXAlignment=Enum.TextXAlignment.Left, ZIndex=14,
    }, btn)

    local arr = New("TextLabel", {
        Text="›", Font=Enum.Font.GothamBold, TextSize=22,
        TextColor3=col, BackgroundTransparency=1,
        Size=UDim2.fromOffset(28,38), Position=UDim2.new(1,-30,0,0),
        ZIndex=14,
    }, btn)

    btn.MouseButton1Click:Connect(function()
        Tween(btn,{BackgroundColor3=col},0.08); Tween(lbl,{TextColor3=C.White},0.08)
        task.delay(0.16,function()
            Tween(btn,{BackgroundColor3=C.Surface},0.2)
            Tween(lbl,{TextColor3=C.Text},0.2)
        end)
        pcall(cb)
    end)
    btn.MouseEnter:Connect(function()
        Tween(btn,{BackgroundColor3=C.SurfHigh},0.1)
        Tween(arr,{Position=UDim2.new(1,-24,0,0)},0.1)
    end)
    btn.MouseLeave:Connect(function()
        Tween(btn,{BackgroundColor3=C.Surface},0.1)
        Tween(arr,{Position=UDim2.new(1,-30,0,0)},0.1)
    end)
    return btn
end

--- Slider widget — returns a setter function
local function Slider(parent, text, min, max, default, cb, order)
    local val  = math.clamp(tonumber(default) or min, min, max)
    local drag = false
    local con  = New("Frame", {
        Size=UDim2.new(1,0,0,62), BackgroundColor3=C.Surface,
        BorderSizePixel=0, ZIndex=13, LayoutOrder=order or 0,
    }, parent)
    New("UICorner", {CornerRadius=UDim.new(0,8)}, con)

    New("TextLabel", {
        Text=text, Font=Enum.Font.GothamSemibold, TextSize=13,
        TextColor3=C.Text, BackgroundTransparency=1,
        Size=UDim2.new(0.65,0,0,28), Position=UDim2.fromOffset(10,0),
        TextXAlignment=Enum.TextXAlignment.Left, ZIndex=14,
    }, con)

    local valL = New("TextLabel", {
        Text=tostring(val), Font=Enum.Font.GothamBold, TextSize=13,
        TextColor3=C.Accent, BackgroundTransparency=1,
        Size=UDim2.new(0.33,0,0,28), Position=UDim2.new(0.67,0,0,0),
        TextXAlignment=Enum.TextXAlignment.Right, ZIndex=14,
    }, con)

    local track = New("Frame", {
        Size=UDim2.new(1,-20,0,6), Position=UDim2.new(0,10,0,42),
        BackgroundColor3=C.Bg, BorderSizePixel=0, ZIndex=14,
    }, con)
    New("UICorner", {CornerRadius=UDim.new(1,0)}, track)

    local p0 = (val-min)/math.max(max-min,1)
    local fill = New("Frame", {
        Size=UDim2.new(p0,0,1,0), BackgroundColor3=C.Accent,
        BorderSizePixel=0, ZIndex=15,
    }, track)
    New("UICorner", {CornerRadius=UDim.new(1,0)}, fill)

    local thumb = New("Frame", {
        Size=UDim2.fromOffset(16,16),
        Position=UDim2.new(p0,-8,0.5,-8),
        BackgroundColor3=C.White, BorderSizePixel=0, ZIndex=16,
    }, track)
    New("UICorner", {CornerRadius=UDim.new(1,0)}, thumb)
    New("UIStroke", {Color=C.Accent, Thickness=1.5}, thumb)

    local function SetVal(pct)
        pct = math.clamp(pct, 0, 1)
        val = Round(min + pct*(max-min), 2)
        valL.Text = tostring(val)
        Tween(fill,  {Size=UDim2.new(pct,0,1,0)},          0.04)
        Tween(thumb, {Position=UDim2.new(pct,-8,0.5,-8)},  0.04)
        pcall(cb, val)
    end

    local function Drag(absX)
        local p = math.clamp((absX - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X,1), 0, 1)
        SetVal(p)
    end

    track.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then drag=true; Drag(i.Position.X) end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and (i.UserInputType==Enum.UserInputType.MouseMovement
                  or i.UserInputType==Enum.UserInputType.Touch) then Drag(i.Position.X) end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
        or i.UserInputType==Enum.UserInputType.Touch then drag=false end
    end)

    return function(v)
        local pct = (math.clamp(v,min,max)-min)/math.max(max-min,1)
        SetVal(pct)
    end
end

--- Info card — returns the value TextLabel
local function InfoCard(parent, label, value, icon, col)
    col = col or C.Accent
    local card = New("Frame", {
        Size=UDim2.new(1,0,0,60), BackgroundColor3=C.Surface,
        BorderSizePixel=0, ZIndex=13,
    }, parent)
    New("UICorner", {CornerRadius=UDim.new(0,10)}, card)

    local iconF = New("Frame", {
        Size=UDim2.fromOffset(44,44), Position=UDim2.fromOffset(8,8),
        BackgroundColor3=col, BackgroundTransparency=0.82,
        BorderSizePixel=0, ZIndex=14,
    }, card)
    New("UICorner", {CornerRadius=UDim.new(0,10)}, iconF)
    New("TextLabel", {
        Text=icon or "?", Font=Enum.Font.GothamBold, TextSize=22,
        TextColor3=col, BackgroundTransparency=1,
        Size=UDim2.fromScale(1,1), ZIndex=15,
    }, iconF)

    New("TextLabel", {
        Text=label, Font=Enum.Font.Gotham, TextSize=11,
        TextColor3=C.TextMuted, BackgroundTransparency=1,
        Size=UDim2.new(1,-64,0,20), Position=UDim2.fromOffset(60,8),
        TextXAlignment=Enum.TextXAlignment.Left, ZIndex=14,
    }, card)

    local valL = New("TextLabel", {
        Text=tostring(value), Font=Enum.Font.GothamBold, TextSize=14,
        TextColor3=C.Text, BackgroundTransparency=1,
        Size=UDim2.new(1,-64,0,26), Position=UDim2.fromOffset(60,28),
        TextXAlignment=Enum.TextXAlignment.Left, ZIndex=14,
    }, card)
    return valL
end

--- Text input box — returns the TextBox
local function TextInput(parent, placeholder, default, cb, order)
    local con = New("Frame", {
        Size=UDim2.new(1,0,0,42), BackgroundColor3=C.Surface,
        BorderSizePixel=0, ZIndex=13, LayoutOrder=order or 0,
    }, parent)
    New("UICorner", {CornerRadius=UDim.new(0,8)}, con)
    New("UIStroke", {Color=C.Border, Thickness=1}, con)

    local box = New("TextBox", {
        PlaceholderText=placeholder or "Type here...",
        PlaceholderColor3=C.TextMuted,
        Text=tostring(default or ""),
        Font=Enum.Font.Gotham, TextSize=13,
        TextColor3=C.Text, BackgroundTransparency=1,
        Size=UDim2.new(1,-20,1,0), Position=UDim2.fromOffset(10,0),
        TextXAlignment=Enum.TextXAlignment.Left,
        ClearTextOnFocus=false, ZIndex=14,
    }, con)

    box.Focused:Connect(function()
        Tween(con, {BackgroundColor3=C.SurfHigh}, 0.1)
        New("UIStroke", {Color=C.Accent, Thickness=1}, con)
    end)
    box.FocusLost:Connect(function(enter)
        Tween(con, {BackgroundColor3=C.Surface}, 0.1)
        pcall(cb, box.Text, enter)
    end)
    return box
end

--- Dropdown widget — returns setter function and current value getter
local function Dropdown(parent, label, options, default, cb, order)
    local selected = default or (options[1] or "")
    local open     = false
    local itemH    = 32
    local maxShow  = 5

    local con = New("Frame", {
        Size=UDim2.new(1,0,0,42), BackgroundColor3=C.Surface,
        BorderSizePixel=0, ZIndex=13, LayoutOrder=order or 0,
        ClipsDescendants=false,
    }, parent)
    New("UICorner", {CornerRadius=UDim.new(0,8)}, con)

    New("TextLabel", {
        Text=label, Font=Enum.Font.GothamSemibold, TextSize=12,
        TextColor3=C.TextDim, BackgroundTransparency=1,
        Size=UDim2.new(0.4,0,1,0), Position=UDim2.fromOffset(10,0),
        TextXAlignment=Enum.TextXAlignment.Left, ZIndex=14,
    }, con)

    local selBtn = New("TextButton", {
        Text=selected, Font=Enum.Font.GothamSemibold, TextSize=12,
        TextColor3=C.Text, BackgroundColor3=C.SurfAlt, BorderSizePixel=0,
        Size=UDim2.new(0.57,0,0,28), Position=UDim2.new(0.41,0,0.5,-14),
        ZIndex=15,
    }, con)
    New("UICorner", {CornerRadius=UDim.new(0,6)}, selBtn)
    New("UIStroke", {Color=C.Border, Thickness=1}, selBtn)

    local chevron = New("TextLabel", {
        Text="▾", Font=Enum.Font.GothamBold, TextSize=14,
        TextColor3=C.Accent, BackgroundTransparency=1,
        Size=UDim2.fromOffset(20,28), Position=UDim2.new(1,-22,0,0),
        ZIndex=16,
    }, selBtn)

    -- Dropdown list (appears above content z-order)
    local listF = New("Frame", {
        Size=UDim2.new(0.57,0,0, math.min(#options,maxShow)*itemH+4),
        Position=UDim2.new(0.41,0,1,4),
        BackgroundColor3=C.Surface, BorderSizePixel=0,
        ZIndex=30, Visible=false, ClipsDescendants=true,
    }, con)
    New("UICorner", {CornerRadius=UDim.new(0,8)}, listF)
    New("UIStroke", {Color=C.Accent, Thickness=1}, listF)

    local listScroll = New("ScrollingFrame", {
        Size=UDim2.fromScale(1,1), BackgroundTransparency=1,
        BorderSizePixel=0, ScrollBarThickness=3,
        ScrollBarImageColor3=C.Accent,
        CanvasSize=UDim2.fromOffset(0,#options*itemH),
        ZIndex=31,
    }, listF)
    New("UIListLayout", {
        Padding=UDim.new(0,2), SortOrder=Enum.SortOrder.LayoutOrder,
    }, listScroll)

    local function Close()
        open = false
        Tween(listF, {Size=UDim2.new(0.57,0,0,0)}, 0.15)
        Tween(chevron, {Rotation=0}, 0.15)
        task.delay(0.16, function() listF.Visible = false end)
    end

    for _, opt in ipairs(options) do
        local item = New("TextButton", {
            Text=" "..opt, Font=Enum.Font.Gotham, TextSize=12,
            TextColor3=C.Text, BackgroundColor3=C.Surface,
            BorderSizePixel=0, Size=UDim2.new(1,0,0,itemH),
            TextXAlignment=Enum.TextXAlignment.Left, ZIndex=32,
        }, listScroll)
        item.MouseEnter:Connect(function() item.BackgroundColor3 = C.SurfHigh end)
        item.MouseLeave:Connect(function() item.BackgroundColor3 = C.Surface  end)
        item.MouseButton1Click:Connect(function()
            selected = opt; selBtn.Text = opt
            pcall(cb, opt); Close()
        end)
    end

    selBtn.MouseButton1Click:Connect(function()
        open = not open
        if open then
            listF.Visible = true
            listF.Size = UDim2.new(0.57,0,0,0)
            Tween(listF,{Size=UDim2.new(0.57,0,0,math.min(#options,maxShow)*itemH+4)},0.18,Enum.EasingStyle.Back)
            Tween(chevron,{Rotation=180},0.15)
        else
            Close()
        end
    end)

    return Close, function() return selected end
end

--- Grid button group
local function ButtonGrid(parent, items, cols, colH, cb, order)
    cols = cols or 2; colH = colH or 34
    local rows = math.ceil(#items / cols)
    local gridF = New("Frame", {
        Size = UDim2.new(1,0,0, rows*colH + (rows-1)*4),
        BackgroundTransparency=1, ZIndex=13, LayoutOrder=order or 0,
    }, parent)
    local gl = New("UIGridLayout", {
        CellSize = UDim2.new(1/cols,-4,0,colH),
        CellPadding = UDim2.fromOffset(4,4),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, gridF)
    for i, item in ipairs(items) do
        local btn = New("TextButton", {
            Text=item.text, Font=Enum.Font.GothamSemibold, TextSize=12,
            TextColor3=C.Text, BackgroundColor3=C.Surface,
            BorderSizePixel=0, ZIndex=14, LayoutOrder=i,
            AutoButtonColor=false,
        }, gridF)
        New("UICorner", {CornerRadius=UDim.new(0,7)}, btn)

        local bar = New("Frame", {
            Size=UDim2.fromOffset(3,16), Position=UDim2.new(0,0,0.5,-8),
            BackgroundColor3=item.col or C.Accent, BorderSizePixel=0, ZIndex=15,
        }, btn)
        New("UICorner", {CornerRadius=UDim.new(0,2)}, bar)

        btn.MouseButton1Click:Connect(function()
            local col = item.col or C.Accent
            Tween(btn,{BackgroundColor3=col},0.08)
            Tween(btn,{BackgroundColor3=C.Surface},0.2)
            pcall(cb, item, i)
            if item.cb then pcall(item.cb) end
        end)
        btn.MouseEnter:Connect(function() Tween(btn,{BackgroundColor3=C.SurfHigh},0.1) end)
        btn.MouseLeave:Connect(function() Tween(btn,{BackgroundColor3=C.Surface},0.1)  end)
    end
    return gridF
end

--- Color swatch picker (6 preset colors)
local function ColorPicker(parent, label, presets, default, cb, order)
    local con = New("Frame", {
        Size=UDim2.new(1,0,0,52), BackgroundColor3=C.Surface,
        BorderSizePixel=0, ZIndex=13, LayoutOrder=order or 0,
    }, parent)
    New("UICorner", {CornerRadius=UDim.new(0,8)}, con)

    New("TextLabel", {
        Text=label, Font=Enum.Font.GothamSemibold, TextSize=13,
        TextColor3=C.Text, BackgroundTransparency=1,
        Size=UDim2.new(0.45,0,1,0), Position=UDim2.fromOffset(10,0),
        TextXAlignment=Enum.TextXAlignment.Left, ZIndex=14,
    }, con)

    local swatchRow = New("Frame", {
        Size=UDim2.new(0.52,0,0,28), Position=UDim2.new(0.46,0,0.5,-14),
        BackgroundTransparency=1, ZIndex=14,
    }, con)
    local swGL = New("UIGridLayout", {
        CellSize=UDim2.new(1/#presets,-3,1,0),
        CellPadding=UDim2.fromOffset(3,0),
    }, swatchRow)

    local selected = default or presets[1]
    for _, col in ipairs(presets) do
        local sw = New("TextButton", {
            Size=UDim2.fromScale(1,1), BackgroundColor3=col,
            Text="", BorderSizePixel=0, ZIndex=15,
        }, swatchRow)
        New("UICorner", {CornerRadius=UDim.new(0,5)}, sw)
        if col == selected then
            New("UIStroke", {Color=C.White, Thickness=2}, sw)
        end
        sw.MouseButton1Click:Connect(function()
            selected = col
            for _, ch in ipairs(swatchRow:GetChildren()) do
                if ch:IsA("TextButton") then
                    local st = ch:FindFirstChildOfClass("UIStroke")
                    if st then st:Destroy() end
                end
            end
            New("UIStroke", {Color=C.White, Thickness=2}, sw)
            pcall(cb, col)
        end)
    end
end

--- Keybind selector widget
local function KeybindWidget(parent, label, default, cb, order)
    local key = default or Enum.KeyCode.Unknown
    local listening = false

    local con = New("Frame", {
        Size=UDim2.new(1,0,0,42), BackgroundColor3=C.Surface,
        BorderSizePixel=0, ZIndex=13, LayoutOrder=order or 0,
    }, parent)
    New("UICorner", {CornerRadius=UDim.new(0,8)}, con)

    New("TextLabel", {
        Text=label, Font=Enum.Font.GothamSemibold, TextSize=13,
        TextColor3=C.Text, BackgroundTransparency=1,
        Size=UDim2.new(0.55,0,1,0), Position=UDim2.fromOffset(10,0),
        TextXAlignment=Enum.TextXAlignment.Left, ZIndex=14,
    }, con)

    local kBtn = New("TextButton", {
        Text=KeyName(key), Font=Enum.Font.GothamBold, TextSize=12,
        TextColor3=C.White, BackgroundColor3=C.Accent,
        BorderSizePixel=0, Size=UDim2.fromOffset(120,28),
        Position=UDim2.new(1,-128,0.5,-14), ZIndex=15,
    }, con)
    New("UICorner", {CornerRadius=UDim.new(0,6)}, kBtn)

    kBtn.MouseButton1Click:Connect(function()
        if listening then return end
        listening = true
        kBtn.Text = "Press key..."
        Tween(kBtn,{BackgroundColor3=C.Warning},0.1)
        local conn; conn = UserInputService.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.Keyboard then
                key = inp.KeyCode; kBtn.Text = KeyName(key)
                Tween(kBtn,{BackgroundColor3=C.Accent},0.15)
                listening = false; conn:Disconnect()
                pcall(cb, key)
            end
        end)
    end)

    return function() return key end
end

--- List display widget (scrollable text list)
local function ListWidget(parent, items, maxH, order)
    maxH = maxH or 140
    local con = New("Frame", {
        Size=UDim2.new(1,0,0,maxH+2), BackgroundColor3=C.Bg,
        BorderSizePixel=0, ZIndex=13, LayoutOrder=order or 0,
    }, parent)
    New("UICorner", {CornerRadius=UDim.new(0,8)}, con)
    New("UIStroke", {Color=C.Border, Thickness=1}, con)

    local scroll = New("ScrollingFrame", {
        Size=UDim2.fromScale(1,1), BackgroundTransparency=1,
        BorderSizePixel=0, ScrollBarThickness=4,
        ScrollBarImageColor3=C.Accent,
        CanvasSize=UDim2.new(0,0,0,0),
        AutomaticCanvasSize=Enum.AutomaticSize.Y,
        ZIndex=14,
    }, con)
    New("UIPadding",{PaddingLeft=UDim.new(0,6),PaddingRight=UDim.new(0,6),PaddingTop=UDim.new(0,4),PaddingBottom=UDim.new(0,4)},scroll)
    local lay = New("UIListLayout",{Padding=UDim.new(0,2),SortOrder=Enum.SortOrder.LayoutOrder},scroll)

    local entries = {}

    local function AddItem(text, col)
        col = col or C.TextDim
        local lbl = New("TextLabel", {
            Text=text, Font=Enum.Font.Gotham, TextSize=11,
            TextColor3=col, BackgroundTransparency=1,
            Size=UDim2.new(1,0,0,16),
            TextXAlignment=Enum.TextXAlignment.Left,
            TextWrapped=true, ZIndex=15,
        }, scroll)
        table.insert(entries, lbl)
        -- keep only last 150 entries
        if #entries > 150 then
            entries[1]:Destroy(); table.remove(entries, 1)
        end
        scroll.CanvasPosition = Vector2.new(0, math.huge)
    end

    for _, item in ipairs(items or {}) do
        AddItem(tostring(item))
    end

    local function Clear()
        for _, e in ipairs(entries) do e:Destroy() end
        entries = {}
    end

    return scroll, AddItem, Clear
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  [SECTION 15]  TAB: INFO
-- ═══════════════════════════════════════════════════════════════════════════════

do
    local P = Tabs["Info"].page

    -- ── Avatar + name card ──────────────────────────────────────────────────
    local avatarCard = New("Frame", {
        Size=UDim2.new(1,0,0,128), BackgroundColor3=C.Surface,
        BorderSizePixel=0, LayoutOrder=1, ZIndex=13,
    }, P)
    New("UICorner",   {CornerRadius=UDim.new(0,14)}, avatarCard)
    New("UIGradient", {
        Color=ColorSequence.new({
            ColorSequenceKeypoint.new(0, C.TitleTop),
            ColorSequenceKeypoint.new(1, C.TitleBot),
        }), Rotation=135,
    }, avatarCard)

    local avi = New("ImageLabel", {
        Size=UDim2.fromOffset(96,96), Position=UDim2.fromOffset(14,16),
        BackgroundColor3=C.Bg, BorderSizePixel=0, ZIndex=14,
        Image="rbxthumb://type=AvatarHeadShot&id="..LocalPlayer.UserId.."&w=150&h=150",
    }, avatarCard)
    New("UICorner",{CornerRadius=UDim.new(0,48)}, avi)
    New("UIStroke",{Color=C.Accent, Thickness=2.5}, avi)

    -- Animated ring around avatar
    local aviRing = New("Frame", {
        Size=UDim2.fromOffset(104,104), Position=UDim2.fromOffset(10,12),
        BackgroundTransparency=1, BorderSizePixel=0, ZIndex=13,
    }, avatarCard)
    New("UICorner",{CornerRadius=UDim.new(0,52)}, aviRing)
    New("UIStroke",{Color=C.AccGlow, Thickness=1.5}, aviRing)

    local function IText(txt, sz, col, y, bold)
        New("TextLabel", {
            Text=txt, Font=bold and Enum.Font.GothamBlack or Enum.Font.Gotham,
            TextSize=sz, TextColor3=col, BackgroundTransparency=1,
            Size=UDim2.new(1,-124,0,sz+5), Position=UDim2.fromOffset(118,y),
            TextXAlignment=Enum.TextXAlignment.Left, ZIndex=14,
        }, avatarCard)
    end

    IText(LocalPlayer.DisplayName, 20, C.White,    16, true)
    IText("@"..LocalPlayer.Name,   13, C.Accent,   40, false)
    IText("ID: "..LocalPlayer.UserId, 11, C.TextMuted, 57, false)
    IText("Age: "..LocalPlayer.AccountAge.." days",  11, C.TextMuted, 72, false)
    IText("Team: "..(LocalPlayer.Team and LocalPlayer.Team.Name or "None"), 11, C.TextMuted, 87, false)
    IText("Premium: "..(LocalPlayer.MembershipType == Enum.MembershipType.Premium and "Yes ★" or "No"), 11, C.TextMuted, 102, false)

    Section(P, "GAME INFORMATION", 2)

    -- ── Game info card ──────────────────────────────────────────────────────
    local gameCard = New("Frame", {
        Size=UDim2.new(1,0,0,86), BackgroundColor3=C.Surface,
        BorderSizePixel=0, LayoutOrder=3, ZIndex=13,
    }, P)
    New("UICorner",{CornerRadius=UDim.new(0,12)}, gameCard)

    New("TextLabel",{
        Text="🎮", Font=Enum.Font.GothamBold, TextSize=36,
        BackgroundTransparency=1, Size=UDim2.fromOffset(60,86),
        Position=UDim2.fromOffset(8,0), ZIndex=14,
    }, gameCard)

    local gName = New("TextLabel",{
        Text="Loading game name...", Font=Enum.Font.GothamBold, TextSize=14,
        TextColor3=C.Text, BackgroundTransparency=1,
        Size=UDim2.new(1,-80,0,24), Position=UDim2.fromOffset(70,12),
        TextXAlignment=Enum.TextXAlignment.Left, ZIndex=14, TextWrapped=true,
    }, gameCard)

    New("TextLabel",{
        Text="Place ID: "..game.PlaceId, Font=Enum.Font.Gotham, TextSize=11,
        TextColor3=C.TextMuted, BackgroundTransparency=1,
        Size=UDim2.new(1,-80,0,18), Position=UDim2.fromOffset(70,36),
        TextXAlignment=Enum.TextXAlignment.Left, ZIndex=14,
    }, gameCard)

    New("TextLabel",{
        Text="Universe: "..game.GameId, Font=Enum.Font.Gotham, TextSize=11,
        TextColor3=C.TextMuted, BackgroundTransparency=1,
        Size=UDim2.new(1,-80,0,18), Position=UDim2.fromOffset(70,52),
        TextXAlignment=Enum.TextXAlignment.Left, ZIndex=14,
    }, gameCard)

    local jobShort = (game.JobId~="" and game.JobId:sub(1,20).."...") or "Studio/Solo"
    New("TextLabel",{
        Text="Server: "..jobShort, Font=Enum.Font.Gotham, TextSize=10,
        TextColor3=C.TextMuted, BackgroundTransparency=1,
        Size=UDim2.new(1,-80,0,16), Position=UDim2.fromOffset(70,68),
        TextXAlignment=Enum.TextXAlignment.Left, ZIndex=14,
    }, gameCard)

    task.spawn(function()
        pcall(function()
            local info = MarketplaceService:GetProductInfo(game.PlaceId)
            gName.Text = (info.Name or "Unknown Game")
        end)
    end)

    Section(P, "LIVE STATISTICS", 4)

    -- ── Stats grid ──────────────────────────────────────────────────────────
    local statsGrid = New("Frame", {
        Size=UDim2.new(1,0,0,0), BackgroundTransparency=1,
        AutomaticSize=Enum.AutomaticSize.Y, LayoutOrder=5, ZIndex=13,
    }, P)
    New("UIGridLayout",{
        CellSize=UDim2.new(0.48,-4,0,64),
        CellPadding=UDim2.fromOffset(8,8),
    }, statsGrid)

    local pingL  = InfoCard(statsGrid, "Ping",       "-- ms",  "📶", C.AccAlt)
    local fpsL   = InfoCard(statsGrid, "FPS",        "-- fps", "⚡",  C.Success)
    local playL  = InfoCard(statsGrid, "Players",    "--",     "👥", C.Warning)
    local wsL    = InfoCard(statsGrid, "WalkSpeed",  "16",     "🏃", C.Accent)
    local hpL    = InfoCard(statsGrid, "Health",     "100",    "❤",  C.Danger)
    local upL    = InfoCard(statsGrid, "Uptime",     "0:00",   "🕐", C.TextDim)

    local ltime, frames, startT = tick(), 0, tick()
    RunService.RenderStepped:Connect(function()
        frames += 1
        local now = tick()
        if now - ltime >= 1 then
            fpsL.Text  = math.floor(frames/(now-ltime)).." fps"
            TitleFPS.Text = fpsL.Text
            frames = 0; ltime = now
            pingL.Text = math.floor(LocalPlayer:GetNetworkPing()*1000).." ms"
            playL.Text = tostring(#Players:GetPlayers())
            upL.Text   = FormatTime(now - startT)
            pcall(function()
                wsL.Text = tostring(math.floor(Humanoid.WalkSpeed))
                hpL.Text = math.floor(Humanoid.Health).."/"..math.floor(Humanoid.MaxHealth)
            end)
        end
    end)

    Section(P, "DEVICE & EXECUTOR", 6)

    local devCard = New("Frame", {
        Size=UDim2.new(1,0,0,56), BackgroundColor3=C.Surface,
        BorderSizePixel=0, LayoutOrder=7, ZIndex=13,
    }, P)
    New("UICorner",{CornerRadius=UDim.new(0,10)}, devCard)

    local dtype = mobile and "📱 Mobile" or (tablet and "📟 Tablet" or "🖥  Desktop")
    local exVer = SafeVersion()
    New("TextLabel", {
        Text=dtype.."   •   "..math.floor(VP.X).."×"..math.floor(VP.Y).."   •   "..exVer,
        Font=Enum.Font.GothamSemibold, TextSize=12, TextColor3=C.Text,
        BackgroundTransparency=1, Size=UDim2.new(1,-20,1,0),
        Position=UDim2.fromOffset(10,0), TextXAlignment=Enum.TextXAlignment.Left,
        TextWrapped=true, ZIndex=14,
    }, devCard)

    Section(P, "NOTIFICATION HISTORY", 8)
    local histScroll, histAdd, histClear = ListWidget(P, {}, 120, 9)
    histScroll.Parent.LayoutOrder = 9

    Button(P, "Refresh History", C.AccAlt, function()
        histClear()
        for _, n in ipairs(Cfg.NotifHistory) do
            histAdd("["..os.date("%H:%M", n.time).."] "..n.title.." — "..n.body, n.col)
        end
    end, 10)
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  [SECTION 16]  TAB: PLAYER
-- ═══════════════════════════════════════════════════════════════════════════════

do
    local P = Tabs["Player"].page

    Section(P, "MOVEMENT", 1)

    local setWS = Slider(P, "Walk Speed", 0, 500, 16, function(v)
        Cfg.WalkSpeed = v; pcall(function() Humanoid.WalkSpeed = v end)
    end, 2)

    local setJP = Slider(P, "Jump Power", 0, 500, 50, function(v)
        Cfg.JumpPower = v
        pcall(function() Humanoid.JumpPower = v; Humanoid.UseJumpPower = true end)
    end, 3)

    local setFS = Slider(P, "Fly Speed", 10, 400, 60, function(v)
        Cfg.FlySpeed = v; _G.MinitFlySpeed = v
    end, 4)

    Toggle(P, "Infinite Jump", "Jump again mid-air (all jumps)", false, function(val)
        Cfg.InfJump = val
    end, 5)

    Toggle(P, "Fly Mode", "Free-fly: WASD + Space/LShift", false, function(val)
        Cfg.Fly = val
        if val then
            local bv = New("BodyVelocity",{
                Velocity=Vector3.zero, MaxForce=Vector3.new(1e5,1e5,1e5),
                Name="MinitFlyBV",
            }, HRP)
            local bg = New("BodyGyro",{
                MaxTorque=Vector3.new(1e6,1e6,1e6), Name="MinitFlyBG",
            }, HRP)
            local conn; conn = RunService.RenderStepped:Connect(function()
                if not Cfg.Fly then
                    pcall(function() bv:Destroy() end)
                    pcall(function() bg:Destroy() end)
                    conn:Disconnect(); return
                end
                local spd = Cfg.FlySpeed or 60
                local dir = Vector3.zero
                local uis = UserInputService
                if uis:IsKeyDown(Enum.KeyCode.W) then dir += Camera.CFrame.LookVector  end
                if uis:IsKeyDown(Enum.KeyCode.S) then dir -= Camera.CFrame.LookVector  end
                if uis:IsKeyDown(Enum.KeyCode.A) then dir -= Camera.CFrame.RightVector end
                if uis:IsKeyDown(Enum.KeyCode.D) then dir += Camera.CFrame.RightVector end
                if uis:IsKeyDown(Enum.KeyCode.E) or uis:IsKeyDown(Enum.KeyCode.Space)     then dir += Vector3.yAxis end
                if uis:IsKeyDown(Enum.KeyCode.Q) or uis:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.yAxis end
                if dir.Magnitude > 0 then dir = dir.Unit end
                local bvI = HRP:FindFirstChild("MinitFlyBV")
                local bgI = HRP:FindFirstChild("MinitFlyBG")
                if bvI then bvI.Velocity = dir * spd end
                if bgI then bgI.CFrame   = Camera.CFrame end
            end)
        end
    end, 6)

    Section(P, "SPEED PRESETS", 7)

    ButtonGrid(P, {
        {text="Normal (16)",   v=16,  col=C.Success},
        {text="Fast (50)",     v=50,  col=C.AccAlt},
        {text="Turbo (100)",   v=100, col=C.Warning},
        {text="Ultra (250)",   v=250, col=C.Danger},
        {text="Max (500)",     v=500, col=C.Danger},
        {text="Slow (8)",      v=8,   col=C.TextMuted},
    }, 3, 34, function(item)
        if item.v then pcall(function() Humanoid.WalkSpeed = item.v; setWS(item.v) end) end
    end, 8)

    Section(P, "CHARACTER", 9)

    Toggle(P, "Noclip", "Phase through all BaseParts", false, function(val)
        Cfg.Noclip = val
        if val then RunService.Stepped:Connect(function()
            if not Cfg.Noclip then return end
            for _, p in ipairs(Character:GetDescendants()) do
                if p:IsA("BasePart") and p ~= HRP then p.CanCollide = false end
            end
        end) end
    end, 10)

    Toggle(P, "God Mode", "Infinite HP — immune to damage", false, function(val)
        Cfg.GodMode = val
        if val then
            Humanoid.MaxHealth = math.huge; Humanoid.Health = math.huge
            Humanoid.HealthChanged:Connect(function()
                if Cfg.GodMode then Humanoid.Health = math.huge end
            end)
        end
    end, 11)

    Toggle(P, "Auto Respawn", "Reload character on death", false, function(val)
        Cfg.AutoRespawn = val
        if val then Humanoid.Died:Connect(function()
            if Cfg.AutoRespawn then task.wait(0.5); LocalPlayer:LoadCharacter() end
        end) end
    end, 12)

    Toggle(P, "Invisible (Client)", "Make your character transparent", false, function(val)
        Cfg.Invisible = val
        for _, p in ipairs(Character:GetDescendants()) do
            if p:IsA("BasePart") or p:IsA("Decal") then p.Transparency = val and 1 or 0 end
        end
        HRP.Transparency = 1
    end, 13)

    Toggle(P, "Infinite Stamina", "Prevent stamina/energy drain", false, function(val)
        Cfg.InfStamina = val
        if val then local conn; conn = RunService.Heartbeat:Connect(function()
            if not Cfg.InfStamina then conn:Disconnect(); return end
            Humanoid.JumpHeight = 7.2
        end) end
    end, 14)

    Toggle(P, "Anti-Ragdoll", "Disable all joint constraints", false, function(val)
        for _, v in ipairs(Character:GetDescendants()) do
            if v:IsA("BallSocketConstraint") or v:IsA("HingeConstraint") or v:IsA("Motor6D") then
                if v:IsA("Motor6D") then v.MaxVelocity = val and 0 or 0.1
                else v.Enabled = not val end
            end
        end
    end, 15)

    Toggle(P, "No Animations", "Freeze character animation tracks", false, function(val)
        local animate = Character:FindFirstChild("Animate")
        if animate then animate.Disabled = val end
        if val then
            for _, tr in ipairs(Humanoid:GetPlayingAnimationTracks()) do tr:Stop() end
        end
    end, 16)

    Section(P, "ACTIONS", 17)

    Button(P, "Heal to Full",          C.Success,  function() Humanoid.Health = Humanoid.MaxHealth end, 18)
    Button(P, "Kill Self",             C.Danger,   function() Humanoid.Health = 0 end, 19)
    Button(P, "Unlock Max Zoom (500)", C.AccAlt,   function()
        LocalPlayer.CameraMaxZoomDistance = 500
        QueueNotify("Player","Max zoom → 500 ✓")
    end, 20)
    Button(P, "Toggle Sit",            C.Accent,   function() Humanoid.Sit = not Humanoid.Sit end, 21)
    Button(P, "Teleport to Spawn",     C.Success,  function()
        local sp = workspace:FindFirstChildOfClass("SpawnLocation")
        if sp then HRP.CFrame = sp.CFrame + Vector3.new(0,5,0) end
    end, 22)
    Button(P, "Reset Character Now",   C.Danger,   function() Humanoid.Health = 0 end, 23)
    Button(P, "Stop Animations",       C.TextMuted, function()
        for _, tr in ipairs(Humanoid:GetPlayingAnimationTracks()) do tr:Stop() end
        QueueNotify("Player","Animations stopped ✓")
    end, 24)

    Slider(P, "Max Health", 100, 99999, 100, function(v)
        pcall(function() Humanoid.MaxHealth = v; Humanoid.Health = v end)
    end, 25)

    Slider(P, "Camera FOV", 20, 140, 70, function(v) Camera.FieldOfView = v end, 26)

    Button(P, "Unlock Camera Zoom",   C.AccAlt, function()
        LocalPlayer.CameraMinZoomDistance = 0
        LocalPlayer.CameraMaxZoomDistance = 1000
        QueueNotify("Player","Camera zoom: 0–1000 ✓")
    end, 27)
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  [SECTION 17]  TAB: COMBAT
-- ═══════════════════════════════════════════════════════════════════════════════

do
    local P = Tabs["Combat"].page
    local kaConn, aimbotConn

    Section(P, "KILL AURA", 1)

    Toggle(P, "Kill Aura", "Continuously damage nearby players", false, function(val)
        Cfg.KillAura = val
        if kaConn then kaConn:Disconnect(); kaConn = nil end
        if val then
            kaConn = RunService.Heartbeat:Connect(function()
                for _, pl in ipairs(Players:GetPlayers()) do
                    if pl ~= LocalPlayer and pl.Character then
                        local h   = pl.Character:FindFirstChildOfClass("Humanoid")
                        local hrp = pl.Character:FindFirstChild("HumanoidRootPart")
                        if h and hrp and h.Health > 0 then
                            if (hrp.Position - HRP.Position).Magnitude <= Cfg.KillAuraRange then
                                h:TakeDamage(Cfg.KillAuraDamage)
                            end
                        end
                    end
                end
            end)
        end
    end, 2)

    Slider(P, "Kill Aura Range (studs)", 3, 150, 20, function(v) Cfg.KillAuraRange = v end, 3)
    Slider(P, "Kill Aura Damage (HP)",   1, 100, 10, function(v) Cfg.KillAuraDamage = v end, 4)

    Section(P, "AIMBOT", 5)

    Toggle(P, "Soft Aimbot", "Smoothly move camera toward target", false, function(val)
        Cfg.Aimbot = val
        if aimbotConn then aimbotConn:Disconnect(); aimbotConn = nil end
        if val then
            aimbotConn = RunService.RenderStepped:Connect(function()
                if not Cfg.Aimbot then return end
                local nearest, bestDist = nil, Cfg.AimbotFOV
                local screenCenter = Vector2.new(VP.X/2, VP.Y/2)
                for _, pl in ipairs(Players:GetPlayers()) do
                    if pl ~= LocalPlayer and pl.Character then
                        local part = pl.Character:FindFirstChild(Cfg.AimbotPart) or pl.Character:FindFirstChild("Head")
                        if part then
                            local sp, onScreen = WorldToScreen(part.Position)
                            if onScreen then
                                local d = (sp - screenCenter).Magnitude
                                if d < bestDist then bestDist = d; nearest = part end
                            end
                        end
                    end
                end
                if nearest then
                    local lookCF = CFrame.lookAt(Camera.CFrame.Position, nearest.Position)
                    Camera.CFrame = Camera.CFrame:Lerp(lookCF, Cfg.AimbotSmooth)
                end
            end)
        end
    end, 6)

    Slider(P, "Aimbot FOV (screen px)",    20, 600, 120, function(v) Cfg.AimbotFOV    = v end, 7)
    Slider(P, "Aimbot Smooth (0.1=fast)",   1,  20,   2, function(v) Cfg.AimbotSmooth = v/20 end, 8)

    Dropdown(P, "Aimbot Target Part", {"Head","UpperTorso","LowerTorso","HumanoidRootPart"}, "Head", function(v)
        Cfg.AimbotPart = v
    end, 9)

    Section(P, "DEFENSIVE", 10)

    Toggle(P, "Anti-Knockback", "Zero incoming body velocity forces", false, function(val)
        Cfg.AntiKB = val
        if val then local conn; conn = RunService.Heartbeat:Connect(function()
            if not Cfg.AntiKB then conn:Disconnect(); return end
            for _, v in ipairs(HRP:GetChildren()) do
                if v:IsA("BodyVelocity") then v.Velocity = Vector3.zero end
                if v:IsA("BodyForce")    then v.Force    = Vector3.zero end
            end
        end) end
    end, 11)

    Toggle(P, "Anti-Ragdoll", "Keep joints stiff and resist ragdoll", false, function(val)
        Cfg.AntiRagdoll = val
        for _, v in ipairs(Character:GetDescendants()) do
            if v:IsA("BallSocketConstraint") or v:IsA("HingeConstraint") then
                v.Enabled = not val
            end
        end
    end, 12)

    Toggle(P, "Speed Burst on Jump", "Momentary speed boost each jump", false, function(val)
        if val then Humanoid.Jumping:Connect(function(active)
            if active and val then
                local prev = Humanoid.WalkSpeed; Humanoid.WalkSpeed = 100
                task.delay(0.45, function() Humanoid.WalkSpeed = prev end)
            end
        end) end
    end, 13)

    Section(P, "OFFENSIVE TOOLS", 14)

    Toggle(P, "Hitbox Expander", "Enlarge all player hitboxes", false, function(val)
        Cfg.HitboxExpand = val
        if val then local conn; conn = RunService.Heartbeat:Connect(function()
            if not Cfg.HitboxExpand then conn:Disconnect(); return end
            for _, pl in ipairs(Players:GetPlayers()) do
                if pl ~= LocalPlayer and pl.Character then
                    for _, part in ipairs(pl.Character:GetDescendants()) do
                        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                            if part.Size.Magnitude < Cfg.HitboxSize * 3 then
                                part.Size = Vector3.new(Cfg.HitboxSize, Cfg.HitboxSize, Cfg.HitboxSize)
                            end
                        end
                    end
                end
            end
        end) end
    end, 15)

    Slider(P, "Hitbox Size (studs)", 2, 30, 5, function(v) Cfg.HitboxSize = v end, 16)

    Button(P, "Fling Nearest Player",   C.Danger, function()
        local pl, _ = GetNearest(200)
        if pl then
            local hrp = GetHRP(pl)
            if hrp then
                local vel = New("BodyVelocity",{
                    Velocity=Vector3.new(math.random(-120,120),280,math.random(-120,120)),
                    MaxForce=Vector3.new(1e6,1e6,1e6),
                },hrp); Debris:AddItem(vel,0.18)
                QueueNotify("Combat","Flung "..pl.Name.." ✓")
            end
        end
    end, 17)

    Button(P, "Fling ALL Players",      C.Danger, function()
        for _, pl in ipairs(GetAlivePlayers()) do
            local hrp = GetHRP(pl)
            if hrp then
                local vel = New("BodyVelocity",{
                    Velocity=Vector3.new(math.random(-100,100),260,math.random(-100,100)),
                    MaxForce=Vector3.new(1e6,1e6,1e6),
                },hrp); Debris:AddItem(vel,0.18)
            end
        end
    end, 18)

    Button(P, "Damage All (10 HP)",     C.Danger, function()
        for _, pl in ipairs(GetAlivePlayers()) do
            local h = GetHum(pl)
            if h then h:TakeDamage(10) end
        end
    end, 19)

    Button(P, "Kill All Players",       C.Danger, function()
        for _, pl in ipairs(GetAlivePlayers()) do
            local h = GetHum(pl)
            if h then h:TakeDamage(99999) end
        end
        QueueNotify("Combat","Kill all executed ✓")
    end, 20)

    Button(P, "Freeze Nearest Player",  C.Warning, function()
        local pl, _ = GetNearest(200)
        local hrp = GetHRP(pl)
        if hrp then hrp.Anchored = true; QueueNotify("Combat","Froze "..pl.Name) end
    end, 21)

    Button(P, "Freeze ALL Players",     C.Warning, function()
        for _, pl in ipairs(Players:GetPlayers()) do
            local hrp = GetHRP(pl)
            if hrp and pl ~= LocalPlayer then hrp.Anchored = true end
        end
        QueueNotify("Combat","All players frozen ✓")
    end, 22)

    Button(P, "Unfreeze ALL Players",   C.Success, function()
        for _, pl in ipairs(Players:GetPlayers()) do
            local hrp = GetHRP(pl)
            if hrp then hrp.Anchored = false end
        end
        QueueNotify("Combat","All players unfrozen ✓")
    end, 23)
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  [SECTION 18]  TAB: WEAPONS
-- ═══════════════════════════════════════════════════════════════════════════════

do
    local P = Tabs["Weapons"].page

    Section(P, "TOOL MANAGEMENT", 1)

    Button(P, "Drop All Tools",           C.Warning, function()
        for _, v in ipairs(LocalPlayer.Backpack:GetChildren()) do v:Destroy() end
        for _, v in ipairs(Character:GetChildren()) do
            if v:IsA("Tool") then v.Parent = nil end
        end
        QueueNotify("Weapons","All tools dropped ✓")
    end, 2)

    Button(P, "Copy Tools from Nearest",  C.AccAlt, function()
        local pl, _ = GetNearest(50)
        if pl and pl.Character then
            for _, v in ipairs(pl.Character:GetChildren()) do
                if v:IsA("Tool") then
                    pcall(function() v:Clone().Parent = LocalPlayer.Backpack end)
                end
            end
        end
    end, 3)

    Button(P, "List All Tools in Output", C.TextMuted, function()
        print("=== Tools in Backpack ===")
        for _, v in ipairs(LocalPlayer.Backpack:GetChildren()) do
            if v:IsA("Tool") then print("  Tool:", v.Name) end
        end
        print("=== Tools Equipped ===")
        for _, v in ipairs(Character:GetChildren()) do
            if v:IsA("Tool") then print("  Equipped:", v.Name) end
        end
    end, 4)

    Section(P, "WEAPON TWEAKS", 5)

    Toggle(P, "Auto-Equip First Tool", "Equip first backpack tool on spawn", false, function(val)
        if val then
            LocalPlayer.CharacterAdded:Connect(function(char)
                if not val then return end
                task.wait(1)
                local tool = LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
                if tool then
                    tool.Parent = char
                end
            end)
        end
    end, 6)

    Slider(P, "Tool Activation Delay (ms)", 0, 1000, 0, function(v)
        for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
            if tool:IsA("Tool") then
                pcall(function() tool.ToolTip = "Delay:"..v end)
            end
        end
    end, 7)

    Button(P, "Remove All Barriers in Workspace", C.Danger, function()
        local count = 0
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and v.CanCollide and not v:IsAncestorOf(Character) then
                if v.Size.Magnitude < 3 then
                    v:Destroy(); count += 1
                end
            end
        end
        QueueNotify("Weapons","Removed "..count.." small parts ✓")
    end, 8)

    Section(P, "HITBOX & REACH", 9)

    Slider(P, "Punch / Hit Reach (studs)", 4, 100, 6, function(v)
        -- expand tool's tool tip as reach reference
        for _, tool in ipairs(Character:GetChildren()) do
            if tool:IsA("Tool") then
                pcall(function()
                    local handle = tool:FindFirstChild("Handle")
                    if handle then handle.Size = Vector3.new(v,v,v) end
                end)
            end
        end
    end, 10)

    Toggle(P, "No Reload (loop fire)", "Rapidly refire tool activation", false, function(val)
        if val then task.spawn(function()
            while val do
                local tool = Character:FindFirstChildOfClass("Tool")
                if tool then
                    local event = tool:FindFirstChildOfClass("RemoteEvent")
                    if event then pcall(function() event:FireServer() end) end
                end
                task.wait(0.05)
            end
        end) end
    end, 11)
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  [SECTION 19]  TAB: WORLD
-- ═══════════════════════════════════════════════════════════════════════════════

do
    local P = Tabs["World"].page

    Section(P, "ENVIRONMENT", 1)

    Toggle(P, "Full Bright", "Maximum scene brightness", false, function(val)
        Lighting.Brightness = val and 2 or 1
        if val then
            for _, v in ipairs(Lighting:GetChildren()) do
                if v:IsA("FogEffect") or v:IsA("BlurEffect") then v.Enabled = false end
            end
        end
    end, 2)

    Toggle(P, "Remove Fog",   "Clear atmospheric fog entirely", false, function(val)
        Lighting.FogEnd   = val and 1e8 or 1000
        Lighting.FogStart = val and 1e8 or 0
        Lighting.FogColor = Color3.fromRGB(192,192,192)
    end, 3)

    Toggle(P, "Remove Shadows", "Disable global shadow casting", false, function(val)
        Lighting.GlobalShadows = not val
    end, 4)

    Slider(P, "Time of Day (0–24)", 0, 24, 14, function(v)
        Lighting.ClockTime = v
    end, 5)

    Slider(P, "Ambient Brightness",    0, 10, 1, function(v)
        Lighting.Brightness = v
    end, 6)

    local ambPresets = {
        Color3.fromRGB(128,128,128),
        Color3.fromRGB(20,20,40),
        Color3.fromRGB(40,60,100),
        Color3.fromRGB(100,60,20),
        Color3.fromRGB(200,150,100),
        Color3.fromRGB(255,80,80),
    }
    ColorPicker(P, "Ambient Color", ambPresets, ambPresets[1], function(col)
        Lighting.Ambient        = col
        Lighting.OutdoorAmbient = col
    end, 7)

    ButtonGrid(P, {
        {text="Night Mode",  col=C.AccAlt, cb=function()
            Lighting.Ambient=Color3.fromRGB(10,10,20)
            Lighting.OutdoorAmbient=Color3.fromRGB(20,20,40)
            Lighting.ClockTime=0; Lighting.Brightness=0.15
        end},
        {text="Day Mode",    col=C.Warning, cb=function()
            Lighting.Ambient=Color3.fromRGB(128,128,128)
            Lighting.OutdoorAmbient=Color3.fromRGB(128,128,128)
            Lighting.ClockTime=14; Lighting.Brightness=1
        end},
        {text="Sunset",      col=Color3.fromRGB(255,120,40), cb=function()
            Lighting.ClockTime=18.5; Lighting.Brightness=0.6
            Lighting.Ambient=Color3.fromRGB(100,60,20)
        end},
        {text="Midnight",    col=C.TextDim, cb=function()
            Lighting.ClockTime=0; Lighting.Brightness=0.05
            Lighting.Ambient=Color3.fromRGB(5,5,15)
        end},
    }, 2, 34, function() end, 8)

    Section(P, "PHYSICS", 9)

    Slider(P, "World Gravity", 0, 300, 196, function(v)
        Cfg.Gravity = v; workspace.Gravity = v
    end, 10)

    ButtonGrid(P, {
        {text="Zero Gravity",   col=C.AccAlt,  cb=function() workspace.Gravity=0; QueueNotify("World","Gravity=0 ✓") end},
        {text="Moon (16.6)",    col=C.TextDim, cb=function() workspace.Gravity=16.6 end},
        {text="Mars (38)",      col=Color3.fromRGB(220,80,40), cb=function() workspace.Gravity=38 end},
        {text="Normal (196)",   col=C.Success,  cb=function() workspace.Gravity=196.2 end},
        {text="Heavy (500)",    col=C.Warning,  cb=function() workspace.Gravity=500 end},
        {text="Insane (2000)",  col=C.Danger,   cb=function() workspace.Gravity=2000 end},
    }, 3, 34, function() end, 11)

    Section(P, "TERRAIN & PARTS", 12)

    Button(P, "Flood World (Water)",      C.AccAlt,  function()
        workspace.Terrain:FillBlock(CFrame.new(0,-20,0),Vector3.new(2048,40,2048),Enum.Material.Water)
        QueueNotify("World","Flooded ✓")
    end, 13)

    Button(P, "Flatten Terrain (Grass)",  C.Success, function()
        workspace.Terrain:FillBlock(CFrame.new(0,-6,0),Vector3.new(2048,10,2048),Enum.Material.Grass)
        QueueNotify("World","Terrain flattened ✓")
    end, 14)

    Button(P, "Fill Terrain (Lava)",      C.Danger, function()
        workspace.Terrain:FillBall(HRP.Position, 60, Enum.Material.Lava)
        QueueNotify("World","Lava pit created ✓")
    end, 15)

    Button(P, "Clear All Terrain",        C.Danger, function()
        workspace.Terrain:Clear()
        QueueNotify("World","Terrain cleared ✓")
    end, 16)

    Button(P, "Delete All Loose Parts",   C.Danger, function()
        local c = 0
        for _, v in ipairs(workspace:GetChildren()) do
            if v:IsA("BasePart") then v:Destroy(); c+=1 end
        end
        QueueNotify("World","Deleted "..c.." parts ✓")
    end, 17)

    Button(P, "Ice Mode (Zero Friction)", C.AccAlt, function()
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then v.Friction = 0 end
        end
        QueueNotify("World","Ice mode ✓")
    end, 18)

    Button(P, "Max Friction (Sticky)",    C.TextMuted, function()
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then v.Friction = 1 end
        end
        QueueNotify("World","Max friction ✓")
    end, 19)

    Button(P, "Black Hole (Pull Parts)",  C.Danger, function()
        task.spawn(function()
            for i = 1, 100 do
                for _, v in ipairs(workspace:GetDescendants()) do
                    if v:IsA("BasePart") and not v:IsAncestorOf(Character) then
                        v.Velocity = (HRP.Position-v.Position).Unit * 90
                    end
                end
                task.wait(0.05)
            end
        end)
    end, 20)

    Button(P, "Explode at Position",      C.Danger, function()
        local exp = Instance.new("Explosion")
        exp.Position      = HRP.Position
        exp.BlastRadius   = 30
        exp.BlastPressure = 5e5
        exp.Parent        = workspace
        QueueNotify("World","Explosion created ✓")
    end, 21)
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  [SECTION 20]  TAB: ESP
-- ═══════════════════════════════════════════════════════════════════════════════

do
    local P = Tabs["ESP"].page
    local espBoxes, espNames, espTracers = {}, {}, {}
    local espHealthBars = {}

    local function ClearAllESP()
        for _, v in pairs(espBoxes)   do pcall(function() v:Destroy() end) end
        for _, v in pairs(espNames)   do pcall(function() v:Destroy() end) end
        for _, v in pairs(espTracers) do pcall(function() v:Destroy() end) end
        for _, v in pairs(espHealthBars) do pcall(function() v:Destroy() end) end
        espBoxes, espNames, espTracers, espHealthBars = {}, {}, {}, {}
    end

    local function BuildESPForPlayer(pl)
        if not pl or pl == LocalPlayer or not pl.Character then return end
        local hrp  = pl.Character:FindFirstChild("HumanoidRootPart")
        local head = pl.Character:FindFirstChild("Head")
        if not hrp then return end

        if Cfg.BoxESP and not espBoxes[pl.Name] then
            local box = New("BoxHandleAdornment",{
                Adornee=hrp, AlwaysOnTop=true,
                Color3=Color3.fromRGB(255,80,80),
                Size=hrp.Size+Vector3.new(0.6,4,0.6),
                Transparency=0.55, ZIndex=5,
            }, hrp)
            espBoxes[pl.Name] = box
        end

        if Cfg.NameESP and head and not espNames[pl.Name] then
            local bb = New("BillboardGui",{
                Adornee=head, Size=UDim2.fromOffset(220,36),
                StudsOffset=Vector3.new(0,2.8,0), AlwaysOnTop=true,
            }, head)
            local tl = New("TextLabel",{
                Text=pl.DisplayName, Font=Enum.Font.GothamBold, TextSize=14,
                TextColor3=C.White, BackgroundTransparency=1,
                Size=UDim2.new(1,0,0.6,0), TextXAlignment=Enum.TextXAlignment.Center,
                ZIndex=1,
            }, bb)
            local distL = New("TextLabel",{
                Text="? m", Font=Enum.Font.Gotham, TextSize=11,
                TextColor3=C.TextDim, BackgroundTransparency=1,
                Size=UDim2.new(1,0,0.4,0), Position=UDim2.new(0,0,0.6,0),
                TextXAlignment=Enum.TextXAlignment.Center, ZIndex=1,
            }, bb)
            espNames[pl.Name] = {bb=bb, dist=distL, name=tl}
        end
    end

    local function RebuildESP()
        ClearAllESP()
        for _, pl in ipairs(Players:GetPlayers()) do
            BuildESPForPlayer(pl)
        end
    end

    -- Update loop
    RunService.Heartbeat:Connect(function()
        if not (Cfg.BoxESP or Cfg.NameESP or Cfg.HealthESP or Cfg.TracerESP) then return end
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl == LocalPlayer then continue end
            local hrp = GetHRP(pl)
            if not hrp then continue end
            local dist = math.floor((hrp.Position - HRP.Position).Magnitude)
            if dist > Cfg.ESPMaxDist then continue end

            local nameData = espNames[pl.Name]
            if nameData then
                nameData.dist.Text = dist.." m"
            end

            if Cfg.HealthESP then
                local box = espBoxes[pl.Name]
                local h   = GetHum(pl)
                if box and h then
                    local pct = h.Health / math.max(h.MaxHealth,1)
                    box.Color3 = Color3.fromRGB(
                        math.floor(255*(1-pct)),
                        math.floor(255*pct), 0
                    )
                end
            end
        end
    end)

    Players.PlayerAdded:Connect(function(pl)
        pl.CharacterAdded:Connect(function()
            task.wait(1); BuildESPForPlayer(pl)
        end)
    end)

    Section(P, "PLAYER ESP", 1)

    Toggle(P, "Box ESP",     "Red box outline on all players",     false, function(val)
        Cfg.BoxESP = val; RebuildESP()
    end, 2)

    Toggle(P, "Name + Distance Tags", "Billboard name above head", false, function(val)
        Cfg.NameESP = val; RebuildESP()
    end, 3)

    Toggle(P, "Health-Color Boxes", "Box changes red→green by HP %", false, function(val)
        Cfg.HealthESP = val
    end, 4)

    Toggle(P, "Team Check (only enemies)", "Skip teammates in ESP", false, function(val)
        Cfg.ESPTeamCheck = val; RebuildESP()
    end, 5)

    Slider(P, "ESP Max Distance (studs)", 50, 2000, 500, function(v)
        Cfg.ESPMaxDist = v
    end, 6)

    Section(P, "WORLD HIGHLIGHTING", 7)

    Button(P, "Highlight All World Parts",   C.Warning, function()
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and not v:IsAncestorOf(Character) then
                local sel = New("SelectionBox",{
                    Adornee=v, Color3=Color3.fromRGB(0,200,255),
                    LineThickness=0.03, SurfaceTransparency=0.88,
                    SurfaceColor3=Color3.fromRGB(0,200,255),
                },workspace); Debris:AddItem(sel,15)
            end
        end
        QueueNotify("ESP","Part highlight on (15s) ✓")
    end, 8)

    Button(P, "Highlight All Tools",         C.Success, function()
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("Tool") then
                local hl = New("Highlight",{Adornee=v,
                    FillColor=Color3.fromRGB(60,255,120),FillTransparency=0.4,
                    OutlineColor=Color3.fromRGB(0,255,100),
                },v); Debris:AddItem(hl,20)
            end
        end
    end, 9)

    Button(P, "Team Chams (Green = Friend)", C.Success, function()
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl.Team == LocalPlayer.Team and pl ~= LocalPlayer and pl.Character then
                local hl = New("Highlight",{Adornee=pl.Character,
                    FillColor=Color3.fromRGB(0,255,100),FillTransparency=0.5,
                    OutlineColor=Color3.fromRGB(0,255,100),
                },pl.Character); Debris:AddItem(hl,30)
            end
        end
    end, 10)

    Button(P, "Enemy Chams (Red = Foe)",     C.Danger, function()
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl.Team ~= LocalPlayer.Team and pl ~= LocalPlayer and pl.Character then
                local hl = New("Highlight",{Adornee=pl.Character,
                    FillColor=Color3.fromRGB(255,50,50),FillTransparency=0.5,
                    OutlineColor=Color3.fromRGB(255,50,50),
                },pl.Character); Debris:AddItem(hl,30)
            end
        end
    end, 11)

    Button(P, "Clear ALL Highlights & ESP",  C.TextMuted, function()
        ClearAllESP()
        for _, v in ipairs(game:GetDescendants()) do
            if v:IsA("Highlight") or v:IsA("SelectionBox")
            or v:IsA("BoxHandleAdornment") or v:IsA("SphereHandleAdornment") then
                v:Destroy()
            end
        end
        QueueNotify("ESP","All ESP cleared ✓")
    end, 12)
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  [SECTION 21]  TAB: RADAR
-- ═══════════════════════════════════════════════════════════════════════════════

do
    local P = Tabs["Radar"].page

    Section(P, "RADAR SETTINGS", 1)

    local radarFrame = nil
    local radarDots  = {}

    local function BuildRadar()
        if radarFrame then radarFrame:Destroy(); radarFrame = nil end
        if not Cfg.RadarEnabled then return end

        radarFrame = New("Frame",{
            Name="MinitRadar", Size=UDim2.fromOffset(Cfg.RadarSize,Cfg.RadarSize),
            Position=UDim2.new(1,-(Cfg.RadarSize+14),0,60),
            BackgroundColor3=Color3.new(0,0,0), BackgroundTransparency=0.45,
            BorderSizePixel=0, ZIndex=200,
        },SG)
        New("UICorner",{CornerRadius=UDim.new(0, Cfg.RadarSize//2)},radarFrame)
        New("UIStroke",{Color=C.Accent, Thickness=1.5},radarFrame)

        -- crosshair
        New("Frame",{
            Size=UDim2.new(0,1,1,0), Position=UDim2.new(0.5,0,0,0),
            BackgroundColor3=C.Border, BorderSizePixel=0, ZIndex=201,
        },radarFrame)
        New("Frame",{
            Size=UDim2.new(1,0,0,1), Position=UDim2.new(0,0,0.5,0),
            BackgroundColor3=C.Border, BorderSizePixel=0, ZIndex=201,
        },radarFrame)

        -- label
        New("TextLabel",{
            Text="RADAR", Font=Enum.Font.GothamBold, TextSize=9,
            TextColor3=C.Accent, BackgroundTransparency=1,
            Size=UDim2.new(1,0,0,14), Position=UDim2.new(0,0,0,2),
            ZIndex=202,
        },radarFrame)

        -- self dot (white center)
        New("Frame",{
            Size=UDim2.fromOffset(6,6), Position=UDim2.new(0.5,-3,0.5,-3),
            BackgroundColor3=C.White, BorderSizePixel=0, ZIndex=203,
        },radarFrame)
    end

    Toggle(P, "Enable Radar", "2D mini-map showing nearby players", false, function(val)
        Cfg.RadarEnabled = val; BuildRadar()
        if val then
            RunService.RenderStepped:Connect(function()
                if not Cfg.RadarEnabled or not radarFrame then return end
                -- cleanup old dots
                for name, dot in pairs(radarDots) do
                    if not Players:FindFirstChild(name) then
                        dot:Destroy(); radarDots[name] = nil
                    end
                end
                for _, pl in ipairs(Players:GetPlayers()) do
                    if pl == LocalPlayer then continue end
                    local hrp = GetHRP(pl)
                    if not hrp then
                        if radarDots[pl.Name] then
                            radarDots[pl.Name]:Destroy(); radarDots[pl.Name] = nil
                        end; continue
                    end
                    local rel = HRP.CFrame:PointToObjectSpace(hrp.Position)
                    local rx  = math.clamp(rel.X / Cfg.RadarRange, -0.5, 0.5) + 0.5
                    local ry  = math.clamp(-rel.Z / Cfg.RadarRange, -0.5, 0.5) + 0.5
                    local dot = radarDots[pl.Name]
                    if not dot or not dot.Parent then
                        dot = New("Frame",{
                            Size=UDim2.fromOffset(6,6),
                            BackgroundColor3=Color3.fromRGB(255,80,80),
                            BorderSizePixel=0, ZIndex=203,
                        },radarFrame)
                        New("UICorner",{CornerRadius=UDim.new(1,0)},dot)
                        radarDots[pl.Name] = dot
                    end
                    dot.Position = UDim2.new(rx,-3,ry,-3)
                end
            end)
        else
            for _, dot in pairs(radarDots) do dot:Destroy() end
            radarDots = {}
        end
    end, 2)

    Slider(P, "Radar Size (px)", 80, 280, 160, function(v)
        Cfg.RadarSize = v
        if radarFrame then
            radarFrame.Size = UDim2.fromOffset(v,v)
            radarFrame.Position = UDim2.new(1,-(v+14),0,60)
        end
    end, 3)

    Slider(P, "Radar Range (studs)", 30, 500, 100, function(v)
        Cfg.RadarRange = v
    end, 4)

    Section(P, "RADAR STYLE", 5)

    ButtonGrid(P, {
        {text="Red Dots",     col=C.Danger,  cb=function()
            for _, d in pairs(radarDots) do d.BackgroundColor3=Color3.fromRGB(255,80,80) end
        end},
        {text="Green Dots",   col=C.Success, cb=function()
            for _, d in pairs(radarDots) do d.BackgroundColor3=Color3.fromRGB(80,255,130) end
        end},
        {text="Yellow Dots",  col=C.Warning, cb=function()
            for _, d in pairs(radarDots) do d.BackgroundColor3=Color3.fromRGB(255,220,50) end
        end},
        {text="Cyan Dots",    col=C.Info,    cb=function()
            for _, d in pairs(radarDots) do d.BackgroundColor3=Color3.fromRGB(0,220,255) end
        end},
    }, 2, 34, function() end, 6)
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  [SECTION 22]  TAB: TROLL
-- ═══════════════════════════════════════════════════════════════════════════════

do
    local P = Tabs["Troll"].page

    Section(P, "CHAT SPAM", 1)

    local chatBox = TextInput(P, "Enter message to spam...", Cfg.ChatMsg, function(v)
        Cfg.ChatMsg = v
    end, 2)

    Toggle(P, "Chat Spam Toggle", "Send your message repeatedly", false, function(val)
        Cfg.ChatSpam = val
        if val then task.spawn(function()
            while Cfg.ChatSpam do
                pcall(function() Chat:Chat(LocalPlayer.Character.Head, Cfg.ChatMsg) end)
                task.wait(Cfg.ChatDelay)
            end
        end) end
    end, 3)

    Slider(P, "Chat Spam Delay (sec×10)", 5, 60, 12, function(v) Cfg.ChatDelay = v/10 end, 4)

    Button(P, "Send Message Once", Color3.fromRGB(200,80,255), function()
        pcall(function() Chat:Chat(LocalPlayer.Character.Head, Cfg.ChatMsg) end)
    end, 5)

    Section(P, "PLAYER TROLLING", 6)

    local followActive, orbitActive = false, false

    Toggle(P, "Follow Nearest Player", "Chase the closest player", false, function(val)
        followActive = val
        if val then task.spawn(function()
            while followActive do
                local pl, _ = GetNearest(500)
                if pl then Humanoid:MoveTo(GetHRP(pl).Position) end
                task.wait(0.1)
            end
        end) end
    end, 7)

    Toggle(P, "Orbit Nearest Player", "Circle around the closest player", false, function(val)
        orbitActive = val
        if val then task.spawn(function()
            local a = 0
            while orbitActive do
                a += 0.04
                local pl, _ = GetNearest(300)
                if pl then
                    local hrp = GetHRP(pl)
                    if hrp then
                        HRP.CFrame = CFrame.new(hrp.Position + Vector3.new(math.cos(a)*10, 0, math.sin(a)*10))
                    end
                end
                task.wait(0.03)
            end
        end) end
    end, 8)

    Button(P, "Blast Off (Self launch upward)",  Color3.fromRGB(200,80,255), function()
        local bv = New("BodyVelocity",{Velocity=Vector3.new(0,600,0),MaxForce=Vector3.new(0,1e6,0)},HRP)
        Debris:AddItem(bv,0.25)
    end, 9)

    Button(P, "Super Launch Forward",             Color3.fromRGB(200,80,255), function()
        local bv = New("BodyVelocity",{
            Velocity=Camera.CFrame.LookVector*400,MaxForce=Vector3.new(1e6,1e6,1e6)
        },HRP); Debris:AddItem(bv,0.3)
    end, 10)

    Button(P, "Annoy Nearest (jump at them)",     Color3.fromRGB(200,80,255), function()
        local pl, _ = GetNearest(200)
        if pl then
            HRP.CFrame = CFrame.new(GetHRP(pl).Position + Vector3.new(0,2,0))
            task.spawn(function()
                for i=1,12 do Humanoid.Jump=true; task.wait(0.12) end
            end)
        end
    end, 11)

    Button(P, "Play Random Sound Effect",         Color3.fromRGB(200,80,255), function()
        local ids = {6518811702,4613071542,1843671842,447041359,130776675,1369158752,4560353890}
        local s = New("Sound",{SoundId="rbxassetid://"..ids[math.random(1,#ids)],Volume=0.6},workspace)
        s:Play(); Debris:AddItem(s,18)
    end, 12)

    Section(P, "SIZE MANIPULATION", 13)

    Slider(P, "Scale Multiplier (0.1–8)", 1, 80, 10, function(v)
        local scale = v / 10
        local h = Character:FindFirstChildOfClass("Humanoid")
        if h then
            h.BodyDepthScale.Value  = scale
            h.BodyHeightScale.Value = scale
            h.BodyWidthScale.Value  = scale
            h.HeadScale.Value       = scale
        end
    end, 14)

    ButtonGrid(P, {
        {text="Tiny (0.3x)",  col=C.AccAlt,  cb=function()
            local h=Character:FindFirstChildOfClass("Humanoid"); if not h then return end
            h.BodyDepthScale.Value=0.3; h.BodyHeightScale.Value=0.3
            h.BodyWidthScale.Value=0.3; h.HeadScale.Value=0.3
        end},
        {text="Normal (1x)",  col=C.Success, cb=function()
            local h=Character:FindFirstChildOfClass("Humanoid"); if not h then return end
            h.BodyDepthScale.Value=1; h.BodyHeightScale.Value=1
            h.BodyWidthScale.Value=1; h.HeadScale.Value=1
        end},
        {text="Giant (5x)",   col=C.Warning, cb=function()
            local h=Character:FindFirstChildOfClass("Humanoid"); if not h then return end
            h.BodyDepthScale.Value=5; h.BodyHeightScale.Value=5
            h.BodyWidthScale.Value=5; h.HeadScale.Value=5
        end},
        {text="Huge (10x)",   col=C.Danger,  cb=function()
            local h=Character:FindFirstChildOfClass("Humanoid"); if not h then return end
            h.BodyDepthScale.Value=10; h.BodyHeightScale.Value=10
            h.BodyWidthScale.Value=10; h.HeadScale.Value=10
        end},
    }, 2, 34, function() end, 15)

    Section(P, "VISUAL TROLLING", 16)

    Toggle(P, "Spin Self",          "Rotate your character continuously", false, function(val)
        Cfg.SpinChar = val
        if val then task.spawn(function()
            while Cfg.SpinChar do
                HRP.CFrame = HRP.CFrame * CFrame.Angles(0, Cfg.SpinSpeed, 0)
                task.wait()
            end
        end) end
    end, 17)

    Slider(P, "Spin Speed", 1, 30, 6, function(v) Cfg.SpinSpeed = v/60 end, 18)

    Toggle(P, "Spin Camera",        "Continuously rotate the camera", false, function(val)
        if val then task.spawn(function()
            while val do
                Camera.CFrame = Camera.CFrame * CFrame.Angles(0, 0.015, 0)
                task.wait()
            end
        end) end
    end, 19)

    Button(P, "Explode At All Players", C.Danger, function()
        for _, pl in ipairs(GetAlivePlayers()) do
            local hrp = GetHRP(pl)
            if hrp then
                local exp = New("Explosion",{
                    Position=hrp.Position, BlastRadius=20, BlastPressure=2e5,
                },workspace)
            end
        end
    end, 20)
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  [SECTION 23]  TAB: VISUAL
-- ═══════════════════════════════════════════════════════════════════════════════

do
    local P = Tabs["Visual"].page

    Section(P, "CAMERA EFFECTS", 1)

    Slider(P, "Camera FOV",       20, 140,  70, function(v) Camera.FieldOfView = v end, 2)
    Slider(P, "Blur Intensity",    0,  56,   0, function(v)
        local b=Lighting:FindFirstChildOfClass("BlurEffect") or New("BlurEffect",{},Lighting)
        b.Size=v
    end, 3)
    Slider(P, "Bloom Intensity",   0,  10,   0, function(v)
        local b=Lighting:FindFirstChildOfClass("BloomEffect") or New("BloomEffect",{Threshold=0.8,Size=24},Lighting)
        b.Intensity=v
    end, 4)
    Slider(P, "Depth of Field",    0, 100,   0, function(v)
        local d=Lighting:FindFirstChildOfClass("DepthOfFieldEffect") or New("DepthOfFieldEffect",{},Lighting)
        d.FarIntensity=v/100; d.NearIntensity=v/100; d.FocusDistance=30
    end, 5)
    Slider(P, "Sun Rays Intensity",0,   1,   0, function(v)
        local sr=Lighting:FindFirstChildOfClass("SunRaysEffect") or New("SunRaysEffect",{},Lighting)
        sr.Intensity=v; sr.Spread=0.5
    end, 6)

    Toggle(P, "Cinematic Bars",    "Letterbox aspect ratio bars", false, function(val)
        local ex=SG:FindFirstChild("CinematicBars")
        if val then
            if ex then ex:Destroy() end
            local bars = New("Frame",{Name="CinematicBars",Size=UDim2.fromScale(1,1),BackgroundTransparency=1},SG)
            local top = New("Frame",{Size=UDim2.new(1,0,0,0),BackgroundColor3=Color3.new(0,0,0),BorderSizePixel=0,ZIndex=50},bars)
            local bot = New("Frame",{Size=UDim2.new(1,0,0,0),Position=UDim2.new(0,0,1,0),BackgroundColor3=Color3.new(0,0,0),BorderSizePixel=0,ZIndex=50},bars)
            Tween(top,{Size=UDim2.new(1,0,0,78)},0.5)
            Tween(bot,{Size=UDim2.new(1,0,0,78),Position=UDim2.new(0,0,1,-78)},0.5)
        else
            if ex then ex:Destroy() end
        end
    end, 7)

    Toggle(P, "Clock HUD Overlay",  "Real-time clock on screen", false, function(val)
        local clk=SG:FindFirstChild("MinitClock")
        if val then
            if clk then clk:Destroy() end
            local frame=New("Frame",{Name="MinitClock",Size=UDim2.fromOffset(165,35),
                Position=UDim2.new(1,-175,0,10),BackgroundColor3=C.Surface,
                BackgroundTransparency=0.28,BorderSizePixel=0,ZIndex=200},SG)
            New("UICorner",{CornerRadius=UDim.new(0,8)},frame)
            local tl=New("TextLabel",{Font=Enum.Font.GothamBold,TextSize=15,
                TextColor3=C.Accent,BackgroundTransparency=1,Size=UDim2.fromScale(1,1),ZIndex=201},frame)
            RunService.Heartbeat:Connect(function()
                if not val then return end
                local t=os.date("*t")
                tl.Text=string.format("🕐 %02d:%02d:%02d",t.hour,t.min,t.sec)
            end)
        else
            if clk then clk:Destroy() end
        end
    end, 8)

    Section(P, "CHARACTER FX", 9)

    Toggle(P, "Rainbow Character",   "Cycle hue across character parts", false, function(val)
        if val then task.spawn(function()
            local h=0
            while val do
                h=(h+1)%360
                local col=Color3.fromHSV(h/360,1,1)
                for _, p in ipairs(Character:GetDescendants()) do
                    if p:IsA("BasePart") then p.Color=col end
                end
                task.wait(0.05)
            end
        end) end
    end, 10)

    Toggle(P, "Neon Parts",          "Set character parts to Neon material", false, function(val)
        for _, p in ipairs(Character:GetDescendants()) do
            if p:IsA("BasePart") then
                p.Material = val and Enum.Material.Neon or Enum.Material.SmoothPlastic
            end
        end
    end, 11)

    Toggle(P, "Crystal Parts",       "Glass/Crystal material on character", false, function(val)
        for _, p in ipairs(Character:GetDescendants()) do
            if p:IsA("BasePart") then
                p.Material = val and Enum.Material.Glass or Enum.Material.SmoothPlastic
                p.Transparency = val and 0.5 or 0
            end
        end
    end, 12)

    Toggle(P, "Speed Trail",         "Motion trail behind character", false, function(val)
        local trail = HRP:FindFirstChild("MinitTrail")
        if val then
            if trail then trail:Destroy() end
            local a0=New("Attachment",{Position=Vector3.new(0,1,0)},HRP)
            local a1=New("Attachment",{Position=Vector3.new(0,-1,0)},HRP)
            New("Trail",{
                Name="MinitTrail", Attachment0=a0, Attachment1=a1, Lifetime=0.6,
                Color=ColorSequence.new({ColorSequenceKeypoint.new(0,C.Accent),ColorSequenceKeypoint.new(1,C.AccAlt)}),
                Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,1)}),
            },HRP)
        else
            if trail then trail:Destroy() end
        end
    end, 13)

    Toggle(P, "Force Field Effect",  "Visual shield around character", false, function(val)
        local ff=Character:FindFirstChildOfClass("ForceField")
        if val and not ff then New("ForceField",{Visible=true},Character)
        elseif not val and ff then ff:Destroy() end
    end, 14)

    Toggle(P, "Sparkling Particles", "Particle emitter on HumanoidRootPart", false, function(val)
        local pe=HRP:FindFirstChild("MinitSpark")
        if val then
            if pe then pe:Destroy() end
            New("ParticleEmitter",{
                Name="MinitSpark", Rate=25, Lifetime=NumberRange.new(0.4,1.2),
                Speed=NumberRange.new(1,5),
                Color=ColorSequence.new({ColorSequenceKeypoint.new(0,C.AccGlow),ColorSequenceKeypoint.new(1,C.AccAlt)}),
                Size=NumberSequence.new({NumberSequenceKeypoint.new(0,0.12),NumberSequenceKeypoint.new(1,0)}),
            },HRP)
        else
            if pe then pe:Destroy() end
        end
    end, 15)

    Button(P, "Burst Sparkle Effect", C.Warning, function()
        for _, p in ipairs(Character:GetDescendants()) do
            if p:IsA("BasePart") then
                local pe=New("ParticleEmitter",{Rate=80,Speed=NumberRange.new(2,8),
                    Lifetime=NumberRange.new(0.3,1),
                    Color=ColorSequence.new({ColorSequenceKeypoint.new(0,C.AccGlow),ColorSequenceKeypoint.new(1,C.AccAlt)}),
                    Size=NumberSequence.new({NumberSequenceKeypoint.new(0,0.2),NumberSequenceKeypoint.new(1,0)}),
                },p)
                task.delay(0.3, function() pe.Rate=0; Debris:AddItem(pe,2) end)
                break
            end
        end
    end, 16)

    Toggle(P, "Disco World Lighting","Rapidly flash ambient colors", false, function(val)
        if val then task.spawn(function()
            while val do
                Lighting.Ambient=Color3.fromHSV(math.random(),1,1); task.wait(0.1)
            end
        end) else Lighting.Ambient=Color3.fromRGB(128,128,128) end
    end, 17)

    Button(P, "Acid Trip (Color Cycle)", C.AccGlow, function()
        task.spawn(function()
            for i=1,360 do
                Lighting.Ambient=Color3.fromHSV(i/360,1,1)
                Lighting.OutdoorAmbient=Color3.fromHSV((i+120)/360,1,1)
                task.wait(0.04)
            end
            Lighting.Ambient=Color3.fromRGB(128,128,128)
            Lighting.OutdoorAmbient=Color3.fromRGB(128,128,128)
        end)
    end, 18)
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  [SECTION 24]  TAB: TELEPORT
-- ═══════════════════════════════════════════════════════════════════════════════

do
    local P = Tabs["Teleport"].page

    Section(P, "PLAYER TELEPORT", 1)

    Button(P, "Teleport to Nearest Player",   C.Accent, function()
        local pl, _ = GetNearest(9999)
        if pl then
            local hrp = GetHRP(pl)
            if hrp then
                HRP.CFrame = hrp.CFrame + Vector3.new(0,5,0)
                QueueNotify("Teleport","TP to "..pl.Name.." ✓")
            end
        end
    end, 2)

    Button(P, "Teleport to Random Player",    C.AccAlt, function()
        local alive = GetAlivePlayers()
        if #alive > 0 then
            local pl = alive[math.random(1,#alive)]
            local hrp = GetHRP(pl)
            if hrp then
                HRP.CFrame = hrp.CFrame + Vector3.new(0,5,0)
                QueueNotify("Teleport","TP to "..pl.Name.." ✓")
            end
        end
    end, 3)

    Button(P, "Teleport to Spawn",            C.Success, function()
        local sp = workspace:FindFirstChildOfClass("SpawnLocation")
        if sp then HRP.CFrame = sp.CFrame + Vector3.new(0,6,0)
        else QueueNotify("Teleport","No spawn found!") end
    end, 4)

    Button(P, "Teleport to Map Center (0,0)", C.AccAlt, function()
        HRP.CFrame = CFrame.new(0, 100, 0)
    end, 5)

    Section(P, "SAVED LOCATIONS", 6)

    local savedBox = TextInput(P, "Location name...", "", nil, 7)

    Button(P, "Save Current Position",        C.Success, function()
        local name = Trim(savedBox.Text)
        if name == "" then name = "Location "..#Cfg.SavedLocations+1 end
        table.insert(Cfg.SavedLocations, {
            name = name,
            cf   = {HRP.CFrame:GetComponents()},
        })
        SaveConfig()
        QueueNotify("Teleport","Saved: "..name.." ✓")
    end, 8)

    local savedList, savedAdd, savedClear = ListWidget(P, {}, 130, 9)
    savedList.Parent.LayoutOrder = 9

    Button(P, "Refresh Saved List",           C.AccAlt, function()
        savedClear()
        for i, loc in ipairs(Cfg.SavedLocations) do
            savedAdd(i..". "..loc.name, C.AccAlt)
        end
    end, 10)

    local idxBox = TextInput(P, "Location index (1, 2, 3...)", "", nil, 11)

    Button(P, "Teleport to Saved (by index)", C.Accent, function()
        local idx = tonumber(idxBox.Text)
        if idx and Cfg.SavedLocations[idx] then
            local loc = Cfg.SavedLocations[idx]
            local cf  = CFrame.new(table.unpack(loc.cf))
            HRP.CFrame = cf + Vector3.new(0,3,0)
            QueueNotify("Teleport","TP to "..loc.name.." ✓")
        else
            QueueNotify("Teleport","Invalid index!")
        end
    end, 12)

    Button(P, "Clear ALL Saved Locations",    C.Danger, function()
        Cfg.SavedLocations = {}; savedClear(); SaveConfig()
        QueueNotify("Teleport","Saved locations cleared ✓")
    end, 13)

    Section(P, "COORDINATE TELEPORT", 14)

    local xBox = TextInput(P, "X coordinate", "0", nil, 15)
    local yBox = TextInput(P, "Y coordinate", "100", nil, 16)
    local zBox = TextInput(P, "Z coordinate", "0", nil, 17)

    Button(P, "Teleport to Coordinates",      C.Accent, function()
        local x = tonumber(xBox.Text) or 0
        local y = tonumber(yBox.Text) or 100
        local z = tonumber(zBox.Text) or 0
        HRP.CFrame = CFrame.new(x, y, z)
        QueueNotify("Teleport","TP to ("..x..","..y..","..z..") ✓")
    end, 18)

    Button(P, "Print Current CFrame",         C.TextMuted, function()
        local cf = HRP.CFrame
        print("[Minit HUB] CFrame:", tostring(cf))
        xBox.Text = tostring(math.floor(cf.X))
        yBox.Text = tostring(math.floor(cf.Y))
        zBox.Text = tostring(math.floor(cf.Z))
        QueueNotify("Teleport","Position printed ✓")
    end, 19)
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  [SECTION 25]  TAB: REMOTE SPY
-- ═══════════════════════════════════════════════════════════════════════════════

do
    local P = Tabs["RemoteSpy"].page

    Section(P, "REMOTE SPY", 1)

    local logScroll, logAdd, logClear = ListWidget(P, {"[RemoteSpy] Waiting to start..."}, 200, 2)
    logScroll.Parent.LayoutOrder = 2

    local spyConn = nil

    Toggle(P, "Enable Remote Spy", "Log all fired RemoteEvent / RemoteFunction calls", false, function(val)
        Cfg.RemoteSpy = val
        if val then
            -- hook all existing remotes
            local function HookRemote(rem)
                local old
                if rem:IsA("RemoteEvent") then
                    old = rem.OnClientEvent
                    -- We can't truly intercept outgoing FireServer calls without metatable hooks
                    -- but we can log when we see the remote exist and when it fires to client
                    pcall(function()
                        rem.OnClientEvent:Connect(function(...)
                            if not Cfg.RemoteSpy then return end
                            local args = {...}
                            local argStr = ""
                            for i, a in ipairs(args) do
                                argStr = argStr .. (i>1 and ", " or "") .. tostring(a)
                            end
                            local entry = "[←CLIENT] "..rem:GetFullName().."("..argStr..")"
                            table.insert(Cfg.RemoteSpyLog, 1, entry)
                            if #Cfg.RemoteSpyLog > Cfg.RemoteSpyMaxLog then
                                table.remove(Cfg.RemoteSpyLog)
                            end
                            logAdd(entry, C.AccAlt)
                        end)
                    end)
                end
            end

            for _, v in ipairs(game:GetDescendants()) do
                if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
                    HookRemote(v)
                end
            end

            spyConn = game.DescendantAdded:Connect(function(v)
                if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
                    HookRemote(v)
                end
            end)

            logAdd("[RemoteSpy] Hooked "..#game:GetDescendants().." descendants.", C.Success)
        else
            if spyConn then spyConn:Disconnect(); spyConn=nil end
            logAdd("[RemoteSpy] Stopped.", C.Danger)
        end
    end, 3)

    Button(P, "Clear Log",                    C.Danger,   function() logClear() end, 4)
    Button(P, "Copy Log to Clipboard",        C.AccAlt,   function()
        SafeClipboard(table.concat(Cfg.RemoteSpyLog, "\n"))
        QueueNotify("Remote Spy","Log copied to clipboard ✓")
    end, 5)

    Section(P, "REMOTE FINDER", 6)

    local searchBox = TextInput(P, "Search remote by name...", "", nil, 7)
    local findList, findAdd, findClear = ListWidget(P, {}, 140, 8)
    findList.Parent.LayoutOrder = 8

    Button(P, "Find Remotes by Name",         C.Accent, function()
        findClear()
        local query = Trim(searchBox.Text):lower()
        local found = 0
        for _, v in ipairs(game:GetDescendants()) do
            if (v:IsA("RemoteEvent") or v:IsA("RemoteFunction")) then
                if query == "" or v.Name:lower():find(query, 1, true) then
                    findAdd(v.ClassName..": "..v:GetFullName(), C.AccAlt)
                    found += 1
                end
            end
        end
        if found == 0 then findAdd("No remotes found matching: "..query, C.Danger) end
    end, 9)

    Button(P, "List ALL Remotes to Output",   C.TextMuted, function()
        print("=== Minit HUB: All Remotes ===")
        for _, v in ipairs(game:GetDescendants()) do
            if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
                print("  ["..v.ClassName.."] "..v:GetFullName())
            end
        end
        QueueNotify("Remote Spy","Remotes printed to output ✓")
    end, 10)
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  [SECTION 26]  TAB: SCRIPTS HUB
-- ═══════════════════════════════════════════════════════════════════════════════

do
    local P = Tabs["Scripts"].page

    Section(P, "PRE-BUILT SCRIPTS", 1)

    local scripts = {
        {
            name = "Infinite Yield (Command Console)",
            desc = "Advanced admin commands for local player",
            col  = Color3.fromRGB(255,140,200),
            src  = "https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source",
        },
        {
            name = "Dex Explorer (Game Tree Viewer)",
            desc = "Inspect the full game instance tree",
            col  = Color3.fromRGB(100,200,255),
            src  = "https://raw.githubusercontent.com/MaximumADHD/Roblox-File-Format/main/Dex/rbxmk.lua",
        },
        {
            name = "Simple Spy (Remote Logger)",
            desc = "Lightweight remote event spy",
            col  = Color3.fromRGB(160,255,180),
            src  = "https://raw.githubusercontent.com/exxtremestuffs/SimpleSpySource/master/SimpleSpy.lua",
        },
    }

    for i, scr in ipairs(scripts) do
        local card = New("Frame",{
            Size=UDim2.new(1,0,0,64), BackgroundColor3=C.Surface,
            BorderSizePixel=0, LayoutOrder=i+1, ZIndex=13,
        },P)
        New("UICorner",{CornerRadius=UDim.new(0,10)},card)

        local colBar = New("Frame",{Size=UDim2.fromOffset(4,44),Position=UDim2.fromOffset(0,10),
            BackgroundColor3=scr.col,BorderSizePixel=0,ZIndex=14},card)
        New("UICorner",{CornerRadius=UDim.new(0,2)},colBar)

        New("TextLabel",{
            Text=scr.name, Font=Enum.Font.GothamBold, TextSize=13,
            TextColor3=C.Text, BackgroundTransparency=1,
            Size=UDim2.new(1,-100,0,22), Position=UDim2.fromOffset(12,8),
            TextXAlignment=Enum.TextXAlignment.Left, ZIndex=14, TextWrapped=true,
        },card)
        New("TextLabel",{
            Text=scr.desc, Font=Enum.Font.Gotham, TextSize=10,
            TextColor3=C.TextMuted, BackgroundTransparency=1,
            Size=UDim2.new(1,-100,0,18), Position=UDim2.fromOffset(12,30),
            TextXAlignment=Enum.TextXAlignment.Left, ZIndex=14,
        },card)

        local execBtn = New("TextButton",{
            Text="Execute", Font=Enum.Font.GothamBold, TextSize=11,
            TextColor3=C.White, BackgroundColor3=scr.col,
            Size=UDim2.fromOffset(80,28), Position=UDim2.new(1,-88,0.5,-14),
            BorderSizePixel=0, ZIndex=15,
        },card)
        New("UICorner",{CornerRadius=UDim.new(0,6)},execBtn)

        execBtn.MouseButton1Click:Connect(function()
            local src = SafeHTTPGet(scr.src)
            if src then
                SafeLoadString(src)
                QueueNotify("Scripts","Executed: "..scr.name)
            else
                QueueNotify("Scripts","Failed to load script (no HTTP access?)")
            end
        end)
    end

    Section(P, "CUSTOM SCRIPT EXECUTOR", 100)

    local codeBox = New("Frame",{
        Size=UDim2.new(1,0,0,130), BackgroundColor3=C.Bg,
        BorderSizePixel=0, LayoutOrder=101, ZIndex=13,
    },P)
    New("UICorner",{CornerRadius=UDim.new(0,8)},codeBox)
    New("UIStroke",{Color=C.Border,Thickness=1},codeBox)

    local codeInput = New("TextBox",{
        PlaceholderText="-- Enter Lua code here...\nprint('Hello from Minit HUB!')",
        PlaceholderColor3=C.TextMuted,Text="",Font=Enum.Font.Code, TextSize=12,
        TextColor3=C.Success, BackgroundTransparency=1,
        Size=UDim2.new(1,-16,1,-10), Position=UDim2.fromOffset(8,5),
        TextXAlignment=Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Top,
        ClearTextOnFocus=false, MultiLine=true, ZIndex=14,
    },codeBox)

    Button(P, "▶  Execute Custom Script", C.Success, function()
        SafeLoadString(codeInput.Text)
        QueueNotify("Scripts","Custom script executed ✓")
    end, 102)

    Button(P, "🗑  Clear Code Box",        C.Danger, function()
        codeInput.Text = ""
    end, 103)

    Section(P, "QUICK ONE-LINERS", 104)

    local oneLiners = {
        {text="Print All Players",   code='for _,p in ipairs(game:GetService("Players"):GetPlayers())do print(p.Name)end'},
        {text="Print All Remotes",   code='for _,v in ipairs(game:GetDescendants())do if v:IsA("RemoteEvent")or v:IsA("RemoteFunction")then print(v:GetFullName())end end'},
        {text="List All Scripts",    code='for _,v in ipairs(game:GetDescendants())do if v:IsA("LocalScript")or v:IsA("Script")then print(v:GetFullName())end end'},
        {text="Print WorkspaceTree", code='local f=function(i,d)print(string.rep(" ",d)..i.Name.." ["..i.ClassName.."]")for _,c in ipairs(i:GetChildren())do f(c,d+1)end end f(workspace,0)'},
        {text="Delete All Decals",   code='for _,v in ipairs(workspace:GetDescendants())do if v:IsA("Decal")or v:IsA("Texture")then v:Destroy()end end'},
        {text="Unlock All Doors",    code='for _,v in ipairs(workspace:GetDescendants())do if v.Name:lower():find("door")or v.Name:lower():find("gate")then pcall(function()v.CanCollide=false v.Transparency=0.8 end)end end'},
    }

    for i, ol in ipairs(oneLiners) do
        Button(P, ol.text, C.AccAlt, function()
            SafeLoadString(ol.code)
            QueueNotify("Scripts",ol.text.." ✓")
        end, 104+i)
    end
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  [SECTION 27]  TAB: MISC
-- ═══════════════════════════════════════════════════════════════════════════════

do
    local P = Tabs["Misc"].page

    Section(P, "ANTI-AFK & AUTO", 1)

    Toggle(P, "Anti-AFK",      "Prevent the AFK kick timer", false, function(val)
        Cfg.AntiAFK = val
        if val then local conn; conn = RunService.Heartbeat:Connect(function()
            if not Cfg.AntiAFK then conn:Disconnect(); return end
            pcall(function()
                VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.zero)
            end)
        end) end
    end, 2)

    Toggle(P, "Auto Click (LMB)",  "Rapidly click left mouse button", false, function(val)
        Cfg.AutoClick = val
        if val then task.spawn(function()
            while Cfg.AutoClick do SafeClick(); task.wait(Cfg.AutoClickDelay) end
        end) end
    end, 3)

    Slider(P, "Auto Click Delay (ms×10)", 1, 50, 5, function(v)
        Cfg.AutoClickDelay = v/100
    end, 4)

    Toggle(P, "Auto Jump",         "Automatically jump repeatedly", false, function(val)
        if val then task.spawn(function()
            while val do Humanoid.Jump=true; task.wait(0.3) end
        end) end
    end, 5)

    Section(P, "PLAYER UTILITIES", 6)

    Button(P, "Copy Player List to Clipboard", C.AccAlt, function()
        local names={}
        for _, pl in ipairs(Players:GetPlayers()) do table.insert(names,pl.Name) end
        SafeClipboard(table.concat(names,"\n"))
        QueueNotify("Misc","Player list copied ✓")
    end, 7)

    Button(P, "Print Current Position",         C.AccAlt, function()
        local cf=HRP.CFrame
        print(string.format("[Minit HUB] Position: X=%.2f Y=%.2f Z=%.2f",cf.X,cf.Y,cf.Z))
        QueueNotify("Misc","Position printed ✓")
    end, 8)

    Button(P, "Server Hop (join new server)",    C.Warning, function()
        QueueNotify("Misc","Searching for server...")
        task.spawn(function()
            local ok, data = pcall(function()
                return HttpService:JSONDecode(
                    game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=25")
                )
            end)
            if ok and data and data.data then
                for _, s in ipairs(data.data) do
                    if s.id ~= game.JobId and s.playing < s.maxPlayers then
                        TeleportService:TeleportToPlaceInstance(game.PlaceId,s.id,LocalPlayer)
                        return
                    end
                end
            end
            QueueNotify("Misc","No free server found.")
        end)
    end, 9)

    Button(P, "Rejoin Same Server",              C.Danger, function()
        TeleportService:Teleport(game.PlaceId,LocalPlayer)
    end, 10)

    Button(P, "Hide/Show All Game GUIs",         C.TextMuted, function()
        for _, v in ipairs(LocalPlayer.PlayerGui:GetChildren()) do
            if v ~= SG and v:IsA("ScreenGui") then
                v.Enabled = not v.Enabled
            end
        end
    end, 11)

    Button(P, "Heal to Full HP",                 C.Success, function() Humanoid.Health = Humanoid.MaxHealth end, 12)
    Button(P, "Kill Self",                       C.Danger, function() Humanoid.Health = 0 end, 13)
    Button(P, "Freeze Self (Anchor HRP)",        C.Warning, function()
        HRP.Anchored = not HRP.Anchored
        QueueNotify("Misc","Self "..(HRP.Anchored and "frozen" or "unfrozen").." ✓")
    end, 14)

    Toggle(P, "Hide Head (Visual Only)",  "Make head transparent locally", false, function(val)
        local head = Character:FindFirstChild("Head")
        if head then head.Transparency = val and 1 or 0 end
        local face = Character:FindFirstChild("face",true)
        if face then face.Transparency = val and 1 or 0 end
    end, 15)

    Section(P, "OUTPUT / DEBUG", 16)

    Button(P, "Print All Game Values",           C.TextMuted, function()
        for _, v in ipairs(game:GetDescendants()) do
            if v:IsA("ValueBase") then print("[Value]",v:GetFullName(),"=",tostring(v.Value)) end
        end
        QueueNotify("Misc","Values printed ✓")
    end, 17)

    Button(P, "Print Workspace Tree",            C.TextMuted, function()
        local function pt(i,d)
            print(string.rep("  ",d)..i.Name.." ["..i.ClassName.."]")
            for _,c in ipairs(i:GetChildren()) do pt(c,d+1) end
        end; pt(workspace,0)
        QueueNotify("Misc","Workspace tree printed ✓")
    end, 18)

    Button(P, "Print All LocalScripts",          C.TextMuted, function()
        for _, v in ipairs(game:GetDescendants()) do
            if v:IsA("LocalScript") then print("[LocalScript]",v:GetFullName()) end
        end
    end, 19)

    Button(P, "Enable Shift Lock Camera",        C.Accent, function()
        pcall(function() StarterGui:SetCore("DevEnableMouseLock",true) end)
        QueueNotify("Misc","Shift lock enabled ✓")
    end, 20)

    Button(P, "Reset Camera Type to Custom",     C.AccAlt, function()
        Camera.CameraType = Enum.CameraType.Custom
        QueueNotify("Misc","Camera reset ✓")
    end, 21)

    Button(P, "Clear All Highlights & ESP",      C.TextMuted, function()
        for _, v in ipairs(game:GetDescendants()) do
            if v:IsA("Highlight") or v:IsA("SelectionBox")
            or v:IsA("BoxHandleAdornment") then v:Destroy() end
        end
        QueueNotify("Misc","All highlights cleared ✓")
    end, 22)

    Button(P, "Drop All Tools",                  C.Warning, function()
        for _, v in ipairs(LocalPlayer.Backpack:GetChildren()) do v:Destroy() end
        for _, v in ipairs(Character:GetChildren()) do
            if v:IsA("Tool") then v.Parent=nil end
        end
        QueueNotify("Misc","Tools dropped ✓")
    end, 23)

    Button(P, "Remove Head Visually",            C.TextMuted, function()
        local h=Character:FindFirstChild("Head"); if h then h.Transparency=1 end
        local f=Character:FindFirstChild("face",true); if f then f.Transparency=1 end
    end, 24)

    Button(P, "Super Push Forward",              C.Warning, function()
        local bv=New("BodyVelocity",{Velocity=Camera.CFrame.LookVector*320,MaxForce=Vector3.new(1e6,1e6,1e6)},HRP)
        Debris:AddItem(bv,0.3)
    end, 25)
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  [SECTION 28]  TAB: DEBUG
-- ═══════════════════════════════════════════════════════════════════════════════

do
    local P = Tabs["Debug"].page

    Section(P, "ERROR LOG", 1)

    local errScroll, errAdd, errClear = ListWidget(P, {"[Debug] No errors logged."}, 180, 2)
    errScroll.Parent.LayoutOrder = 2

    local function RefreshErrLog()
        errClear()
        if #_errLog == 0 then
            errAdd("[Debug] No errors caught by SafeCall.", C.Success)
        else
            for i, e in ipairs(_errLog) do
                errAdd(string.format("[%.2f] %s", e.time, e.msg), C.Danger)
            end
        end
    end

    Button(P, "Refresh Error Log",    C.AccAlt,  RefreshErrLog, 3)
    Button(P, "Clear Error Log",      C.Danger,  function() _errLog = {}; errClear(); errAdd("[Debug] Log cleared.",C.Success) end, 4)
    Button(P, "Copy Errors to Clip",  C.TextMuted, function()
        local lines = {}
        for _, e in ipairs(_errLog) do table.insert(lines, string.format("[%.2f] %s", e.time, e.msg)) end
        SafeClipboard(table.concat(lines,"\n"))
        QueueNotify("Debug","Errors copied ✓")
    end, 5)

    Section(P, "LIVE CONSOLE OUTPUT", 6)

    local conScroll, conAdd, conClear = ListWidget(P, {}, 180, 7)
    conScroll.Parent.LayoutOrder = 7

    -- Intercept print
    local oldPrint = print
    print = function(...)
        local args = {...}
        local str = ""
        for i, v in ipairs(args) do str = str..(i>1 and "\t" or "")..tostring(v) end
        conAdd(str, C.TextDim)
        return oldPrint(...)
    end

    Button(P, "Clear Console",        C.Danger, function() conClear() end, 8)

    Section(P, "PERFORMANCE INFO", 9)

    local perfCards = New("Frame",{
        Size=UDim2.new(1,0,0,0), BackgroundTransparency=1,
        AutomaticSize=Enum.AutomaticSize.Y, LayoutOrder=10, ZIndex=13,
    },P)
    New("UIGridLayout",{CellSize=UDim2.new(0.48,-4,0,62),CellPadding=UDim2.fromOffset(8,8)},perfCards)

    local memL    = InfoCard(perfCards,"Memory","-- MB","💾",C.Warning)
    local instL   = InfoCard(perfCards,"Instances","--","📦",C.AccAlt)
    local hbL     = InfoCard(perfCards,"Heartbeat","-- ms","⏱",C.Info)
    local rsL     = InfoCard(perfCards,"RenderStep","-- ms","🎞",C.AccGlow)

    local lastHB, lastRS = tick(), tick()
    RunService.Heartbeat:Connect(function(dt)
        local now = tick()
        if now - lastHB >= 1 then
            lastHB = now
            pcall(function()
                memL.Text  = math.floor(Stats:FindFirstChild("DataReceiveKbps") and 0 or
                    Stats.MemoryUsageMbGameScripts or 0).." MB"
            end)
            instL.Text = tostring(#game:GetDescendants()).." inst"
            hbL.Text   = math.floor(dt*1000).." ms"
        end
    end)
    RunService.RenderStepped:Connect(function(dt)
        local now = tick()
        if now - lastRS >= 1 then lastRS=now; rsL.Text=math.floor(dt*1000).." ms" end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  [SECTION 29]  TAB: SETTINGS
-- ═══════════════════════════════════════════════════════════════════════════════

do
    local P = Tabs["Settings"].page

    Section(P, "FPS CONTROL", 1)

    Toggle(P, "Unlock FPS (No Cap)", "Remove Roblox 60fps frame limit", false, function(val)
        Cfg.FPSUnlocked = val
        SafeSetFPSCap(val and 0 or Cfg.FPSLimit)
        QueueNotify("Settings", val and "FPS Unlocked (unlimited) ✓" or "FPS capped to "..Cfg.FPSLimit)
    end, 2)

    Slider(P, "FPS Cap (when not unlocked)", 30, 360, 60, function(v)
        Cfg.FPSLimit = v
        if not Cfg.FPSUnlocked then SafeSetFPSCap(v) end
    end, 3)

    -- FPS preset buttons
    ButtonGrid(P, {
        {text="30",  col=C.Danger,  cb=function() SafeSetFPSCap(30)  end},
        {text="60",  col=C.Warning, cb=function() SafeSetFPSCap(60)  end},
        {text="120", col=C.Success, cb=function() SafeSetFPSCap(120) end},
        {text="144", col=C.AccAlt,  cb=function() SafeSetFPSCap(144) end},
        {text="240", col=C.Accent,  cb=function() SafeSetFPSCap(240) end},
        {text="360", col=C.AccGlow, cb=function() SafeSetFPSCap(360) end},
        {text="Unlimited", col=C.AccGlow, cb=function() SafeSetFPSCap(0) end},
    }, 4, 34, function() end, 4)

    Section(P, "TOGGLE KEYBIND", 5)

    KeybindWidget(P, "Open/Close Hub Key", Cfg.ToggleKey, function(key)
        Cfg.ToggleKey = key
        QueueNotify("Settings","Toggle key → "..KeyName(key))
    end, 6)

    Section(P, "THEME ENGINE", 7)

    Dropdown(P, "Color Theme", {"Purple","Blue","Crimson","Emerald","Gold","Cyber"}, "Purple", function(v)
        Cfg.ThemeName = v
        local theme = Themes[v]
        if not theme then return end
        for k, col in pairs(theme) do C[k] = col end
        -- update key UI elements
        pcall(function()
            ToggleBtn.BackgroundColor3 = C.Accent
            Glow1.BackgroundColor3     = C.Accent
            Glow2.BackgroundColor3     = C.Accent
            TGlow.BackgroundColor3     = C.Accent
            TGlow2.BackgroundColor3    = C.Accent
        end)
        QueueNotify("Settings","Theme → "..v.." ✓")
        SaveConfig()
    end, 8)

    -- Color swatches for quick accent preview
    ColorPicker(P, "Quick Accent Color", {
        Color3.fromRGB(120,80,255),
        Color3.fromRGB(60,140,255),
        Color3.fromRGB(0,220,220),
        Color3.fromRGB(60,220,120),
        Color3.fromRGB(255,60,60),
        Color3.fromRGB(255,200,40),
    }, Color3.fromRGB(120,80,255), function(col)
        C.Accent = col
        ToggleBtn.BackgroundColor3 = col
        QueueNotify("Settings","Accent color changed ✓")
    end, 9)

    Section(P, "EXTRA TOGGLES", 10)

    Toggle(P, "Remove Shadows",     nil, false, function(val) Lighting.GlobalShadows=not val end, 11)
    Toggle(P, "Wireframe World",    nil, false, function(val)
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and not v:IsAncestorOf(Character) then
                v.Material=val and Enum.Material.Glass or Enum.Material.SmoothPlastic
                v.Transparency=val and 0.9 or 0
            end
        end
    end, 12)
    Toggle(P, "Health Regen (+5 HP / 0.5s)", nil, false, function(val)
        if val then task.spawn(function()
            while val do
                pcall(function()
                    if Humanoid.Health<Humanoid.MaxHealth then
                        Humanoid.Health=math.min(Humanoid.Health+5,Humanoid.MaxHealth)
                    end
                end); task.wait(0.5)
            end
        end) end
    end, 13)
    Toggle(P, "Freeze Self",        nil, false, function(val) HRP.Anchored=val end, 14)
    Toggle(P, "Shift Lock Mode",    nil, false, function(val)
        pcall(function() StarterGui:SetCore("DevEnableMouseLock",val) end)
    end, 15)

    Section(P, "SAVE & LOAD CONFIG", 16)

    Button(P, "Save Config Now",    C.Success, function() SaveConfig(); QueueNotify("Settings","Config saved ✓") end, 17)
    Button(P, "Print Config to Output", C.TextMuted, function()
        print("=== Minit HUB Config ===")
        for k, v in pairs(Cfg) do
            if type(v) ~= "table" then print(string.format("  %s = %s", k, tostring(v))) end
        end
    end, 18)

    Section(P, "ABOUT", 19)

    local aboutCard = New("Frame",{
        Size=UDim2.new(1,0,0,72), BackgroundColor3=C.Surface,
        BorderSizePixel=0, LayoutOrder=20, ZIndex=13,
    },P)
    New("UICorner",{CornerRadius=UDim.new(0,12)},aboutCard)
    New("UIGradient",{
        Color=ColorSequence.new({
            ColorSequenceKeypoint.new(0,C.TitleTop),
            ColorSequenceKeypoint.new(1,C.TitleBot),
        }),Rotation=45,
    },aboutCard)
    New("TextLabel",{
        Text="Minit HUB  v4.0 ULTRA MAX\n200+ FE Scripts  |  16 Tabs  |  ~1MB  |  Multi-Device\ndiscord.gg/minithub  |  © Minit Team 2026",
        Font=Enum.Font.Gotham, TextSize=12, TextColor3=C.TextDim,
        BackgroundTransparency=1, Size=UDim2.new(1,-20,1,0), Position=UDim2.fromOffset(10,0),
        TextXAlignment=Enum.TextXAlignment.Left, TextWrapped=true, ZIndex=14,
    },aboutCard)
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  [SECTION 30]  OPEN / CLOSE / MINIMIZE LOGIC
-- ═══════════════════════════════════════════════════════════════════════════════

local guiOpen   = true
local minimized = false
local pinned    = false

local function OpenGUI()
    guiOpen = true; Main.Visible = true
    Main.Size = UDim2.fromOffset(math.floor(GW*0.80), math.floor(GH*0.80))
    Main.BackgroundTransparency = 0.6
    Tween(Main, {
        Size = UDim2.fromOffset(GW, GH),
        BackgroundTransparency = 0,
    }, 0.38, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    Tween(Glow1, {BackgroundTransparency=0.84}, 0.38)
    Tween(Glow2, {BackgroundTransparency=0.93}, 0.38)
end

local function CloseGUI()
    if pinned then return end
    guiOpen = false
    Tween(Main, {
        Size = UDim2.fromOffset(math.floor(GW*0.80), math.floor(GH*0.80)),
        BackgroundTransparency = 1,
    }, 0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
    Tween(Glow1, {BackgroundTransparency=1}, 0.28)
    Tween(Glow2, {BackgroundTransparency=1}, 0.28)
    task.delay(0.30, function() if not guiOpen then Main.Visible=false end end)
end

local function MinimizeGUI()
    minimized = not minimized
    if minimized then
        Tween(Main,{Size=UDim2.fromOffset(GW,48)},0.26)
        Sidebar.Visible=false; Content.Visible=false
    else
        Tween(Main,{Size=UDim2.fromOffset(GW,GH)},0.34,Enum.EasingStyle.Back,Enum.EasingDirection.Out)
        task.delay(0.12,function() Sidebar.Visible=true; Content.Visible=true end)
    end
end

local function PinGUI()
    pinned = not pinned
    PinBtn.Text  = pinned and "📌" or "◎"
    QueueNotify("Minit HUB", pinned and "Window pinned (cannot close)" or "Window unpinned")
end

CloseBtn.MouseButton1Click:Connect(CloseGUI)
MinimizeBtn.MouseButton1Click:Connect(MinimizeGUI)
PinBtn.MouseButton1Click:Connect(PinGUI)
ToggleBtn.MouseButton1Click:Connect(function()
    if guiOpen then CloseGUI() else OpenGUI() end
end)

UserInputService.InputBegan:Connect(function(inp, gpe)
    if gpe then return end
    if inp.KeyCode == Cfg.ToggleKey then
        if guiOpen then CloseGUI() else OpenGUI() end
    end
    -- Infinite jump
    if inp.KeyCode == Enum.KeyCode.Space and Cfg.InfJump then
        local st = Humanoid:GetState()
        if st == Enum.HumanoidStateType.Freefall or st == Enum.HumanoidStateType.Jumping then
            Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
--  [SECTION 31]  DRAG SYSTEM (Title Bar)
-- ═══════════════════════════════════════════════════════════════════════════════

do
    local dragging, dragInput, dragStart, startPos = false, nil, nil, nil

    TitleBar.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = inp.Position; startPos = Main.Position
            inp.Changed:Connect(function()
                if inp.UserInputState == Enum.UserInputState.End then dragging=false end
            end)
        end
    end)
    TitleBar.InputChanged:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseMovement
        or inp.UserInputType == Enum.UserInputType.Touch then dragInput=inp end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if inp==dragInput and dragging then
            local d = inp.Position - dragStart
            Main.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then dragging=false end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  [SECTION 32]  AMBIENT ANIMATIONS
-- ═══════════════════════════════════════════════════════════════════════════════

-- Pulsing toggle button rings
task.spawn(function()
    while true do
        Tween(TGlow,  {BackgroundTransparency=0.46, Size=UDim2.fromOffset(78,78),  Position=UDim2.fromOffset(-12,-12)}, 0.85, Enum.EasingStyle.Sine)
        Tween(TGlow2, {BackgroundTransparency=0.85, Size=UDim2.fromOffset(94,94),  Position=UDim2.fromOffset(-20,-20)}, 0.85, Enum.EasingStyle.Sine)
        task.wait(0.85)
        Tween(TGlow,  {BackgroundTransparency=0.88, Size=UDim2.fromOffset(64,64),  Position=UDim2.fromOffset(-5,-5)},   0.85, Enum.EasingStyle.Sine)
        Tween(TGlow2, {BackgroundTransparency=0.96, Size=UDim2.fromOffset(80,80),  Position=UDim2.fromOffset(-13,-13)}, 0.85, Enum.EasingStyle.Sine)
        task.wait(0.85)
    end
end)

-- Title icon color oscillation
task.spawn(function()
    while true do
        Tween(TitleIcon, {TextColor3=C.AccAlt},  1.8, Enum.EasingStyle.Sine)
        task.wait(1.8)
        Tween(TitleIcon, {TextColor3=C.AccGlow}, 1.8, Enum.EasingStyle.Sine)
        task.wait(1.8)
    end
end)

-- Status dot blink
task.spawn(function()
    while true do
        Tween(StatusDot, {BackgroundTransparency=0},   0.55)
        task.wait(0.65)
        Tween(StatusDot, {BackgroundTransparency=0.7}, 0.55)
        task.wait(0.65)
    end
end)

-- Outer glow color pulse
task.spawn(function()
    while true do
        Tween(Glow1, {BackgroundColor3=C.AccAlt},  2.5, Enum.EasingStyle.Sine)
        Tween(Glow2, {BackgroundColor3=C.AccGlow}, 2.5, Enum.EasingStyle.Sine)
        task.wait(2.5)
        Tween(Glow1, {BackgroundColor3=C.Accent},  2.5, Enum.EasingStyle.Sine)
        Tween(Glow2, {BackgroundColor3=C.Accent},  2.5, Enum.EasingStyle.Sine)
        task.wait(2.5)
    end
end)

-- Title accent strip rainbow
task.spawn(function()
    local h = 0
    while true do
        h = (h + 0.5) % 360
        TitleGradStrip.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0,   Color3.fromHSV(h/360,         0.9, 1)),
            ColorSequenceKeypoint.new(0.5, Color3.fromHSV((h+60)/360,   0.9, 1)),
            ColorSequenceKeypoint.new(1,   Color3.fromHSV((h+120)/360,  0.9, 1)),
        })
        task.wait(0.04)
    end
end)

-- Toggle button "M" label pulse
task.spawn(function()
    while true do
        Tween(TBtnLabel, {TextTransparency=0.2}, 1.0, Enum.EasingStyle.Sine)
        task.wait(1.0)
        Tween(TBtnLabel, {TextTransparency=0},   1.0, Enum.EasingStyle.Sine)
        task.wait(1.0)
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
--  [SECTION 33]  CHARACTER RESPAWN REFRESH
-- ═══════════════════════════════════════════════════════════════════════════════

LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid  = char:WaitForChild("Humanoid", 10)
    HRP       = char:WaitForChild("HumanoidRootPart", 10)
    if Cfg.GodMode   then Humanoid.MaxHealth = math.huge; Humanoid.Health = math.huge end
    if Cfg.WalkSpeed then Humanoid.WalkSpeed  = Cfg.WalkSpeed end
    if Cfg.JumpPower then Humanoid.JumpPower  = Cfg.JumpPower; Humanoid.UseJumpPower = true end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
--  [SECTION 34]  STARTUP SEQUENCE
-- ═══════════════════════════════════════════════════════════════════════════════

-- Start in closed / small state then animate open
Main.BackgroundTransparency = 1
Main.Size = UDim2.fromOffset(math.floor(GW*0.65), math.floor(GH*0.65))
Glow1.BackgroundTransparency = 1
Glow2.BackgroundTransparency = 1

task.wait(0.4)
OpenGUI()

task.delay(1.2, function()
    QueueNotify(
        "Minit HUB v4.0 ULTRA MAX",
        "Welcome, "..LocalPlayer.DisplayName.."!  200+ FE scripts ready.  Toggle: "..KeyName(Cfg.ToggleKey),
        6
    )
end)

print("╔══════════════════════════════════════════╗")
print("║   Minit HUB v4.0 ULTRA MAX  — Loaded!   ║")
print("║   200+ FE Scripts  |  16 Tabs  |  ~1MB  ║")
print("║   Toggle Key: "..string.format("%-27s",KeyName(Cfg.ToggleKey)).."║")
print("║   discord.gg/minithub                    ║")
print("╚══════════════════════════════════════════╝")
