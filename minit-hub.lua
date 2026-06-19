--[[
    ███╗   ███╗██╗███╗   ██╗██╗████████╗    ██╗  ██╗██╗   ██╗██████╗
    ████╗ ████║██║████╗  ██║██║╚══██╔══╝    ██║  ██║██║   ██║██╔══██╗
    ██╔████╔██║██║██╔██╗ ██║██║   ██║       ███████║██║   ██║██████╔╝
    ██║╚██╔╝██║██║██║╚██╗██║██║   ██║       ██╔══██║██║   ██║██╔══██╗
    ██║ ╚═╝ ██║██║██║ ╚████║██║   ██║       ██║  ██║╚██████╔╝██████╔╝
    ╚═╝     ╚═╝╚═╝╚═╝  ╚═══╝╚═╝   ╚═╝       ╚═╝  ╚═╝ ╚═════╝ ╚═════╝
    Minit HUB  v3.0 ULTRA
    100 FE Scripts | Animated GUI | FPS Unlock | Multi-Device
    Toggle: RightShift  (rebindable in Settings)
]]

-- ══════════════════════════════════════════════════════════════
--  SAFE EXECUTOR WRAPPERS  (fixes "attempt to call a nil value")
-- ══════════════════════════════════════════════════════════════
local function SafeSetFPSCap(cap)
    if type(setfpscap) == "function" then
        pcall(setfpscap, cap)
    end
end

local function SafeSetClipboard(text)
    if type(setclipboard) == "function" then
        pcall(setclipboard, text)
    elseif type(toclipboard) == "function" then
        pcall(toclipboard, text)
    end
end

local function SafeClick()
    if type(mouse1click) == "function" then
        pcall(mouse1click)
    end
end

local function SafeVersion()
    if type(version) == "function" then
        local ok, v = pcall(version)
        return ok and tostring(v) or "?"
    end
    return "?"
end

-- ══════════════════════════════════════════════════════════════
--  SERVICES
-- ══════════════════════════════════════════════════════════════
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local HttpService      = game:GetService("HttpService")
local CoreGui          = game:GetService("CoreGui")
local Lighting         = game:GetService("Lighting")
local StarterGui       = game:GetService("StarterGui")
local VirtualUser      = game:GetService("VirtualUser")
local Debris           = game:GetService("Debris")

local LocalPlayer      = Players.LocalPlayer
local Camera           = workspace.CurrentCamera
local Character        = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid         = Character:WaitForChild("Humanoid")
local HRP              = Character:WaitForChild("HumanoidRootPart")

-- ══════════════════════════════════════════════════════════════
--  HELPERS
-- ══════════════════════════════════════════════════════════════
local function Tween(obj, props, t, style, dir)
    style = style or Enum.EasingStyle.Quart
    dir   = dir   or Enum.EasingDirection.Out
    TweenService:Create(obj, TweenInfo.new(t, style, dir), props):Play()
end

local function Notify(title, body, dur)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title    = title or "Minit HUB",
            Text     = body  or "",
            Duration = dur   or 3,
        })
    end)
end

local function IsMobile()
    return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

local function IsTablet()
    return UserInputService.TouchEnabled and Camera.ViewportSize.X >= 768
end

-- ══════════════════════════════════════════════════════════════
--  THEME
-- ══════════════════════════════════════════════════════════════
local C = {
    Bg        = Color3.fromRGB(10,  10,  18),
    Surface   = Color3.fromRGB(18,  18,  30),
    SurfAlt   = Color3.fromRGB(24,  24,  40),
    Border    = Color3.fromRGB(60,  60,  100),
    Accent    = Color3.fromRGB(120, 80,  255),
    AccAlt    = Color3.fromRGB(80,  160, 255),
    AccGlow   = Color3.fromRGB(160, 100, 255),
    Danger    = Color3.fromRGB(255, 80,  80),
    Success   = Color3.fromRGB(80,  255, 140),
    Warning   = Color3.fromRGB(255, 200, 60),
    Text      = Color3.fromRGB(240, 240, 255),
    TextDim   = Color3.fromRGB(160, 160, 200),
    TextMuted = Color3.fromRGB(100, 100, 140),
    White     = Color3.fromRGB(255, 255, 255),
    TabOff    = Color3.fromRGB(30,  30,  50),
    TgOn      = Color3.fromRGB(100, 220, 130),
    TgOff     = Color3.fromRGB(60,  60,  80),
}

-- ══════════════════════════════════════════════════════════════
--  CONFIG
-- ══════════════════════════════════════════════════════════════
local Cfg = {
    ToggleKey    = Enum.KeyCode.RightShift,
    FPSUnlocked  = false,
    FPSLimit     = 60,
    WalkSpeed    = 16,
    JumpPower    = 50,
    AntiAFK      = false,
    Noclip       = false,
    InfJump      = false,
    Fly          = false,
    GodMode      = false,
    AutoRespawn  = false,
}

-- ══════════════════════════════════════════════════════════════
--  SCREEN GUI
-- ══════════════════════════════════════════════════════════════
if CoreGui:FindFirstChild("MinitHUB_v3") then
    CoreGui:FindFirstChild("MinitHUB_v3"):Destroy()
end

local SG = Instance.new("ScreenGui")
SG.Name           = "MinitHUB_v3"
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SG.ResetOnSpawn   = false
SG.IgnoreGuiInset = true
pcall(function() SG.Parent = CoreGui end)
if not SG.Parent then SG.Parent = LocalPlayer.PlayerGui end

-- viewport / device
local VP     = Camera.ViewportSize
local mobile = IsMobile()
local tablet = IsTablet()
local GW     = mobile and (VP.X - 20) or (tablet and 700 or 880)
local GH     = mobile and (VP.Y - 80) or (tablet and 500 or 560)
local SW     = mobile and 54 or 66   -- sidebar width

-- ══════════════════════════════════════════════════════════════
--  TOGGLE BUTTON (floating pill)
-- ══════════════════════════════════════════════════════════════
local ToggleBtn = Instance.new("ImageButton")
ToggleBtn.Name             = "ToggleBtn"
ToggleBtn.Size             = UDim2.fromOffset(52, 52)
ToggleBtn.Position         = UDim2.new(0, 14, 0.5, -26)
ToggleBtn.BackgroundColor3 = C.Accent
ToggleBtn.BorderSizePixel  = 0
ToggleBtn.ZIndex           = 100
ToggleBtn.Parent           = SG
do
    local r = Instance.new("UICorner"); r.CornerRadius = UDim.new(1,0); r.Parent = ToggleBtn
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, C.AccGlow),
        ColorSequenceKeypoint.new(1, C.AccAlt),
    }); g.Rotation = 45; g.Parent = ToggleBtn
    local l = Instance.new("TextLabel")
    l.Text = "M"; l.Font = Enum.Font.GothamBold; l.TextSize = 22
    l.TextColor3 = C.White; l.BackgroundTransparency = 1
    l.Size = UDim2.fromScale(1,1); l.ZIndex = 101; l.Parent = ToggleBtn
    local s = Instance.new("UIStroke"); s.Color = C.AccGlow; s.Thickness = 2; s.Parent = ToggleBtn
end

local TGlow = Instance.new("Frame")
TGlow.Size = UDim2.fromOffset(70,70); TGlow.Position = UDim2.fromOffset(-9,-9)
TGlow.BackgroundColor3 = C.Accent; TGlow.BackgroundTransparency = 0.7
TGlow.BorderSizePixel = 0; TGlow.ZIndex = 99; TGlow.Parent = ToggleBtn
do local r = Instance.new("UICorner"); r.CornerRadius = UDim.new(1,0); r.Parent = TGlow end

-- ══════════════════════════════════════════════════════════════
--  MAIN FRAME
-- ══════════════════════════════════════════════════════════════
local Main = Instance.new("Frame")
Main.Name             = "MainFrame"
Main.Size             = UDim2.fromOffset(GW, GH)
Main.Position         = UDim2.new(0.5, -GW/2, 0.5, -GH/2)
Main.BackgroundColor3 = C.Bg
Main.BorderSizePixel  = 0
Main.ZIndex           = 10
Main.Parent           = SG
do
    local r = Instance.new("UICorner"); r.CornerRadius = UDim.new(0,16); r.Parent = Main
    local s = Instance.new("UIStroke"); s.Color = C.Border; s.Thickness = 1.5; s.Parent = Main
end

local InnerGlow = Instance.new("Frame")
InnerGlow.Size = UDim2.new(1,4,1,4); InnerGlow.Position = UDim2.fromOffset(-2,-2)
InnerGlow.BackgroundColor3 = C.Accent; InnerGlow.BackgroundTransparency = 0.82
InnerGlow.BorderSizePixel = 0; InnerGlow.ZIndex = 9; InnerGlow.Parent = Main
do local r = Instance.new("UICorner"); r.CornerRadius = UDim.new(0,18); r.Parent = InnerGlow end

-- ══════════════════════════════════════════════════════════════
--  TITLE BAR
-- ══════════════════════════════════════════════════════════════
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"; TitleBar.Size = UDim2.new(1,0,0,46)
TitleBar.BackgroundColor3 = C.Surface; TitleBar.BorderSizePixel = 0
TitleBar.ZIndex = 12; TitleBar.Parent = Main
do
    local r = Instance.new("UICorner"); r.CornerRadius = UDim.new(0,16); r.Parent = TitleBar
    -- cover bottom-rounded corners
    local f = Instance.new("Frame"); f.Size = UDim2.new(1,0,0,20)
    f.Position = UDim2.new(0,0,1,-20); f.BackgroundColor3 = C.Surface
    f.BorderSizePixel = 0; f.ZIndex = 12; f.Parent = TitleBar
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,   Color3.fromRGB(30,20,60)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(20,15,50)),
        ColorSequenceKeypoint.new(1,   Color3.fromRGB(10,10,30)),
    }); g.Rotation = 90; g.Parent = TitleBar
end

local TitleIcon = Instance.new("TextLabel")
TitleIcon.Text = "⬡"; TitleIcon.Font = Enum.Font.GothamBold; TitleIcon.TextSize = 22
TitleIcon.TextColor3 = C.Accent; TitleIcon.BackgroundTransparency = 1
TitleIcon.Size = UDim2.fromOffset(36,46); TitleIcon.Position = UDim2.fromOffset(10,0)
TitleIcon.ZIndex = 13; TitleIcon.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Text = "Minit HUB"; TitleText.Font = Enum.Font.GothamBold; TitleText.TextSize = 18
TitleText.TextColor3 = C.White; TitleText.BackgroundTransparency = 1
TitleText.Size = UDim2.new(1,-200,1,0); TitleText.Position = UDim2.fromOffset(46,0)
TitleText.TextXAlignment = Enum.TextXAlignment.Left; TitleText.ZIndex = 13; TitleText.Parent = TitleBar

local TitleVer = Instance.new("TextLabel")
TitleVer.Text = "v3.0 ULTRA"; TitleVer.Font = Enum.Font.Gotham; TitleVer.TextSize = 11
TitleVer.TextColor3 = C.Accent; TitleVer.BackgroundTransparency = 1
TitleVer.Size = UDim2.fromOffset(80,46); TitleVer.Position = UDim2.new(0,46,0,0)
TitleVer.TextXAlignment = Enum.TextXAlignment.Left
TitleVer.TextYAlignment = Enum.TextYAlignment.Bottom
TitleVer.ZIndex = 13; TitleVer.Parent = TitleBar

-- Window control buttons
local function MakeWinBtn(icon, col, offX)
    local b = Instance.new("TextButton")
    b.Text = icon; b.Font = Enum.Font.GothamBold; b.TextSize = 13; b.TextColor3 = C.White
    b.Size = UDim2.fromOffset(28,28); b.Position = UDim2.new(1,offX,0.5,-14)
    b.BackgroundColor3 = col; b.BorderSizePixel = 0; b.ZIndex = 14; b.Parent = TitleBar
    local r = Instance.new("UICorner"); r.CornerRadius = UDim.new(1,0); r.Parent = b
    b.MouseEnter:Connect(function() Tween(b,{BackgroundTransparency=0.35},0.12) end)
    b.MouseLeave:Connect(function() Tween(b,{BackgroundTransparency=0},0.12) end)
    return b
end
local CloseBtn    = MakeWinBtn("✕", C.Danger,  -14)
local MinimizeBtn = MakeWinBtn("─", C.Warning, -48)

-- Status blink dot
local StatusDot = Instance.new("Frame")
StatusDot.Size = UDim2.fromOffset(8,8); StatusDot.Position = UDim2.new(1,-90,0.5,-4)
StatusDot.BackgroundColor3 = C.Success; StatusDot.BorderSizePixel = 0
StatusDot.ZIndex = 13; StatusDot.Parent = TitleBar
do local r = Instance.new("UICorner"); r.CornerRadius = UDim.new(1,0); r.Parent = StatusDot end

-- ══════════════════════════════════════════════════════════════
--  SIDEBAR
-- ══════════════════════════════════════════════════════════════
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"; Sidebar.Size = UDim2.new(0,SW,1,-46)
Sidebar.Position = UDim2.fromOffset(0,46); Sidebar.BackgroundColor3 = C.Surface
Sidebar.BorderSizePixel = 0; Sidebar.ZIndex = 11; Sidebar.Parent = Main
do
    local r = Instance.new("UICorner"); r.CornerRadius = UDim.new(0,16); r.Parent = Sidebar
    -- cover right rounded corners + top gap
    local f1 = Instance.new("Frame"); f1.Size = UDim2.new(0,20,1,0)
    f1.Position = UDim2.new(1,-20,0,0); f1.BackgroundColor3 = C.Surface
    f1.BorderSizePixel = 0; f1.ZIndex = 11; f1.Parent = Sidebar
    local f2 = Instance.new("Frame"); f2.Size = UDim2.new(1,0,0,16)
    f2.BackgroundColor3 = C.Surface; f2.BorderSizePixel = 0; f2.ZIndex = 11; f2.Parent = Sidebar
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(22,18,45)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(14,12,30)),
    }); g.Rotation = 90; g.Parent = Sidebar
end

local SideScroll = Instance.new("ScrollingFrame")
SideScroll.Size = UDim2.new(1,0,1,-10); SideScroll.Position = UDim2.fromOffset(0,8)
SideScroll.BackgroundTransparency = 1; SideScroll.BorderSizePixel = 0
SideScroll.ScrollBarThickness = 0; SideScroll.CanvasSize = UDim2.new(0,0,0,0)
SideScroll.ZIndex = 12; SideScroll.Parent = Sidebar

local SideLayout = Instance.new("UIListLayout")
SideLayout.Padding = UDim.new(0,6)
SideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
SideLayout.Parent = SideScroll

SideLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    SideScroll.CanvasSize = UDim2.fromOffset(0, SideLayout.AbsoluteContentSize.Y + 16)
end)

-- ══════════════════════════════════════════════════════════════
--  CONTENT AREA
-- ══════════════════════════════════════════════════════════════
local Content = Instance.new("Frame")
Content.Name = "Content"; Content.Size = UDim2.new(1,-(SW+8),1,-54)
Content.Position = UDim2.fromOffset(SW+4,50); Content.BackgroundColor3 = C.SurfAlt
Content.BorderSizePixel = 0; Content.ClipsDescendants = true
Content.ZIndex = 11; Content.Parent = Main
do local r = Instance.new("UICorner"); r.CornerRadius = UDim.new(0,12); r.Parent = Content end

-- ══════════════════════════════════════════════════════════════
--  TAB SYSTEM
-- ══════════════════════════════════════════════════════════════
local Tabs    = {}
local TabBtns = {}

local TabDefs = {
    { name = "Info",     icon = "👤", col = Color3.fromRGB(80, 160,255) },
    { name = "Player",   icon = "🏃", col = Color3.fromRGB(120,80, 255) },
    { name = "Combat",   icon = "⚔",  col = Color3.fromRGB(255,80, 80)  },
    { name = "World",    icon = "🌍", col = Color3.fromRGB(80, 255,140) },
    { name = "ESP",      icon = "👁",  col = Color3.fromRGB(255,200,60)  },
    { name = "Troll",    icon = "😈", col = Color3.fromRGB(200,100,255) },
    { name = "Visual",   icon = "🎨", col = Color3.fromRGB(255,180,80)  },
    { name = "Misc",     icon = "🔧", col = Color3.fromRGB(160,160,200) },
    { name = "Settings", icon = "⚙",  col = Color3.fromRGB(160,100,255) },
}

local function NewPage()
    local sc = Instance.new("ScrollingFrame")
    sc.Size = UDim2.fromScale(1,1); sc.BackgroundTransparency = 1
    sc.BorderSizePixel = 0; sc.ScrollBarThickness = 4
    sc.ScrollBarImageColor3 = C.Accent; sc.CanvasSize = UDim2.new(0,0,0,0)
    sc.AutomaticCanvasSize = Enum.AutomaticSize.Y; sc.ZIndex = 12
    sc.Visible = false; sc.Parent = Content
    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0,10); pad.PaddingBottom = UDim.new(0,10)
    pad.PaddingLeft = UDim.new(0,10); pad.PaddingRight = UDim.new(0,10)
    pad.Parent = sc
    local lay = Instance.new("UIListLayout")
    lay.Padding = UDim.new(0,6); lay.SortOrder = Enum.SortOrder.LayoutOrder
    lay.FillDirection = Enum.FillDirection.Vertical; lay.Parent = sc
    return sc
end

for i, def in ipairs(TabDefs) do
    local page = NewPage()
    Tabs[def.name] = { page = page, def = def }

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,SW-10,0,SW-10); btn.BackgroundColor3 = C.TabOff
    btn.BorderSizePixel = 0; btn.Text = ""; btn.ZIndex = 13
    btn.LayoutOrder = i; btn.Parent = SideScroll
    do local r = Instance.new("UICorner"); r.CornerRadius = UDim.new(0,10); r.Parent = btn end

    local iconL = Instance.new("TextLabel")
    iconL.Text = def.icon; iconL.Font = Enum.Font.GothamBold
    iconL.TextSize = mobile and 16 or 18; iconL.TextColor3 = C.TextDim
    iconL.BackgroundTransparency = 1; iconL.Size = UDim2.new(1,0,0.55,0)
    iconL.Position = UDim2.new(0,0,0,4); iconL.ZIndex = 14; iconL.Parent = btn

    local nameL = Instance.new("TextLabel")
    nameL.Text = def.name; nameL.Font = Enum.Font.Gotham
    nameL.TextSize = mobile and 8 or 9; nameL.TextColor3 = C.TextMuted
    nameL.BackgroundTransparency = 1; nameL.Size = UDim2.new(1,0,0.4,0)
    nameL.Position = UDim2.new(0,0,0.58,0); nameL.ZIndex = 14; nameL.Parent = btn

    local ind = Instance.new("Frame")
    ind.Size = UDim2.fromOffset(3,20); ind.Position = UDim2.new(1,-1,0.5,-10)
    ind.BackgroundColor3 = def.col; ind.BackgroundTransparency = 1
    ind.BorderSizePixel = 0; ind.ZIndex = 14; ind.Parent = btn
    do local r = Instance.new("UICorner"); r.CornerRadius = UDim.new(1,0); r.Parent = ind end

    TabBtns[def.name] = { btn=btn, icon=iconL, name=nameL, ind=ind, def=def }

    btn.MouseButton1Click:Connect(function()
        for n, tb in pairs(TabBtns) do
            Tween(tb.btn,  { BackgroundColor3 = C.TabOff   }, 0.2)
            Tween(tb.icon, { TextColor3 = C.TextDim         }, 0.2)
            Tween(tb.name, { TextColor3 = C.TextMuted       }, 0.2)
            Tween(tb.ind,  { BackgroundTransparency = 1     }, 0.2)
            Tabs[n].page.Visible = false
        end
        Tween(btn,   { BackgroundColor3 = def.col }, 0.2)
        Tween(iconL, { TextColor3 = C.White        }, 0.2)
        Tween(nameL, { TextColor3 = C.White        }, 0.2)
        Tween(ind,   { BackgroundTransparency = 0  }, 0.2)
        page.Visible = true
        page.Position = UDim2.fromOffset(28,0)
        Tween(page, { Position = UDim2.fromOffset(0,0) }, 0.22, Enum.EasingStyle.Quart)
    end)
end

-- activate Info by default
do
    local d  = TabDefs[1]
    local tb = TabBtns[d.name]
    tb.btn.BackgroundColor3      = d.col
    tb.icon.TextColor3           = C.White
    tb.name.TextColor3           = C.White
    tb.ind.BackgroundTransparency = 0
    Tabs[d.name].page.Visible    = true
end

-- ══════════════════════════════════════════════════════════════
--  WIDGET BUILDERS
-- ══════════════════════════════════════════════════════════════
local function Section(parent, title, order)
    local sec = Instance.new("Frame"); sec.BackgroundTransparency = 1
    sec.Size = UDim2.new(1,0,0,28); sec.ZIndex = 13
    sec.LayoutOrder = order or 0; sec.Parent = parent
    local line = Instance.new("Frame"); line.Size = UDim2.new(1,0,0,1)
    line.Position = UDim2.new(0,0,0.5,0); line.BackgroundColor3 = C.Border
    line.BorderSizePixel = 0; line.ZIndex = 13; line.Parent = sec
    local lbl = Instance.new("TextLabel"); lbl.Text = "  "..title.."  "
    lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 11; lbl.TextColor3 = C.Accent
    lbl.BackgroundColor3 = C.SurfAlt; lbl.BorderSizePixel = 0
    lbl.AutomaticSize = Enum.AutomaticSize.X; lbl.Size = UDim2.fromOffset(0,22)
    lbl.Position = UDim2.new(0.02,0,0.5,-11); lbl.ZIndex = 14; lbl.Parent = sec
end

local function Toggle(parent, text, desc, default, cb, order)
    local val = default or false
    local con = Instance.new("TextButton")
    con.Size = UDim2.new(1,0,0, desc and 50 or 42); con.BackgroundColor3 = C.Surface
    con.BorderSizePixel = 0; con.Text = ""; con.AutoButtonColor = false
    con.ZIndex = 13; con.LayoutOrder = order or 0; con.Parent = parent
    do local r = Instance.new("UICorner"); r.CornerRadius = UDim.new(0,8); r.Parent = con end

    local lbl = Instance.new("TextLabel"); lbl.Text = text; lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 13; lbl.TextColor3 = C.Text; lbl.BackgroundTransparency = 1
    lbl.Size = UDim2.new(1,-60,0, desc and 22 or 42); lbl.Position = UDim2.fromOffset(10,4)
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 14; lbl.Parent = con

    if desc and desc ~= "" then
        local dl = Instance.new("TextLabel"); dl.Text = desc; dl.Font = Enum.Font.Gotham
        dl.TextSize = 10; dl.TextColor3 = C.TextMuted; dl.BackgroundTransparency = 1
        dl.Size = UDim2.new(1,-60,0,18); dl.Position = UDim2.fromOffset(10,26)
        dl.TextXAlignment = Enum.TextXAlignment.Left; dl.ZIndex = 14; dl.Parent = con
    end

    local pill = Instance.new("Frame"); pill.Size = UDim2.fromOffset(38,20)
    pill.Position = UDim2.new(1,-46,0.5,-10)
    pill.BackgroundColor3 = val and C.TgOn or C.TgOff
    pill.BorderSizePixel = 0; pill.ZIndex = 15; pill.Parent = con
    do local r = Instance.new("UICorner"); r.CornerRadius = UDim.new(1,0); r.Parent = pill end

    local knob = Instance.new("Frame"); knob.Size = UDim2.fromOffset(14,14)
    knob.Position = val and UDim2.fromOffset(21,3) or UDim2.fromOffset(3,3)
    knob.BackgroundColor3 = C.White; knob.BorderSizePixel = 0; knob.ZIndex = 16; knob.Parent = pill
    do local r = Instance.new("UICorner"); r.CornerRadius = UDim.new(1,0); r.Parent = knob end

    con.MouseButton1Click:Connect(function()
        val = not val
        Tween(pill, { BackgroundColor3 = val and C.TgOn or C.TgOff }, 0.18)
        Tween(knob, { Position = val and UDim2.fromOffset(21,3) or UDim2.fromOffset(3,3) }, 0.18)
        pcall(cb, val)
    end)
    con.MouseEnter:Connect(function() Tween(con,{BackgroundColor3=C.SurfAlt},0.12) end)
    con.MouseLeave:Connect(function() Tween(con,{BackgroundColor3=C.Surface},0.12) end)
end

local function Button(parent, text, col, cb, order)
    col = col or C.Accent
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,0,0,38); btn.BackgroundColor3 = C.Surface
    btn.BorderSizePixel = 0; btn.Text = ""; btn.AutoButtonColor = false
    btn.ZIndex = 13; btn.LayoutOrder = order or 0; btn.Parent = parent
    do local r = Instance.new("UICorner"); r.CornerRadius = UDim.new(0,8); r.Parent = btn end

    local bar = Instance.new("Frame"); bar.Size = UDim2.fromOffset(3,22)
    bar.Position = UDim2.new(0,0,0.5,-11); bar.BackgroundColor3 = col
    bar.BorderSizePixel = 0; bar.ZIndex = 14; bar.Parent = btn
    do local r = Instance.new("UICorner"); r.CornerRadius = UDim.new(0,3); r.Parent = bar end

    local lbl = Instance.new("TextLabel"); lbl.Text = text; lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 13; lbl.TextColor3 = C.Text; lbl.BackgroundTransparency = 1
    lbl.Size = UDim2.new(1,-50,1,0); lbl.Position = UDim2.fromOffset(12,0)
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 14; lbl.Parent = btn

    local arr = Instance.new("TextLabel"); arr.Text = "›"; arr.Font = Enum.Font.GothamBold
    arr.TextSize = 22; arr.TextColor3 = col; arr.BackgroundTransparency = 1
    arr.Size = UDim2.fromOffset(30,38); arr.Position = UDim2.new(1,-32,0,0)
    arr.ZIndex = 14; arr.Parent = btn

    btn.MouseButton1Click:Connect(function()
        Tween(btn,{BackgroundColor3=col},0.08); Tween(lbl,{TextColor3=C.White},0.08)
        task.delay(0.16,function()
            Tween(btn,{BackgroundColor3=C.Surface},0.18); Tween(lbl,{TextColor3=C.Text},0.18)
        end)
        pcall(cb)
    end)
    btn.MouseEnter:Connect(function()
        Tween(btn,{BackgroundColor3=C.SurfAlt},0.12)
        Tween(arr,{Position=UDim2.new(1,-26,0,0)},0.12)
    end)
    btn.MouseLeave:Connect(function()
        Tween(btn,{BackgroundColor3=C.Surface},0.12)
        Tween(arr,{Position=UDim2.new(1,-32,0,0)},0.12)
    end)
end

local function Slider(parent, text, min, max, default, cb, order)
    local val = math.clamp(default or min, min, max)
    local drag = false
    local con = Instance.new("Frame"); con.Size = UDim2.new(1,0,0,58)
    con.BackgroundColor3 = C.Surface; con.BorderSizePixel = 0
    con.ZIndex = 13; con.LayoutOrder = order or 0; con.Parent = parent
    do local r = Instance.new("UICorner"); r.CornerRadius = UDim.new(0,8); r.Parent = con end

    local lbl = Instance.new("TextLabel"); lbl.Text = text; lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 13; lbl.TextColor3 = C.Text; lbl.BackgroundTransparency = 1
    lbl.Size = UDim2.new(0.7,0,0,28); lbl.Position = UDim2.fromOffset(10,0)
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 14; lbl.Parent = con

    local valL = Instance.new("TextLabel"); valL.Text = tostring(val)
    valL.Font = Enum.Font.GothamBold; valL.TextSize = 13; valL.TextColor3 = C.Accent
    valL.BackgroundTransparency = 1; valL.Size = UDim2.new(0.28,0,0,28)
    valL.Position = UDim2.new(0.72,0,0,0); valL.TextXAlignment = Enum.TextXAlignment.Right
    valL.ZIndex = 14; valL.Parent = con

    local track = Instance.new("Frame"); track.Size = UDim2.new(1,-20,0,6)
    track.Position = UDim2.new(0,10,0,38); track.BackgroundColor3 = C.Bg
    track.BorderSizePixel = 0; track.ZIndex = 14; track.Parent = con
    do local r = Instance.new("UICorner"); r.CornerRadius = UDim.new(1,0); r.Parent = track end

    local pct0 = (val-min)/(max-min)
    local fill = Instance.new("Frame"); fill.Size = UDim2.new(pct0,0,1,0)
    fill.BackgroundColor3 = C.Accent; fill.BorderSizePixel = 0; fill.ZIndex = 15; fill.Parent = track
    do local r = Instance.new("UICorner"); r.CornerRadius = UDim.new(1,0); r.Parent = fill end

    local thumb = Instance.new("Frame"); thumb.Size = UDim2.fromOffset(14,14)
    thumb.Position = UDim2.new(pct0,-7,0.5,-7)
    thumb.BackgroundColor3 = C.White; thumb.BorderSizePixel = 0; thumb.ZIndex = 16; thumb.Parent = track
    do local r = Instance.new("UICorner"); r.CornerRadius = UDim.new(1,0); r.Parent = thumb end

    local function update(absX)
        local p = math.clamp((absX - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X,1), 0, 1)
        val = math.floor(min + p*(max-min))
        valL.Text = tostring(val)
        Tween(fill,  {Size=UDim2.new(p,0,1,0)}, 0.04)
        Tween(thumb, {Position=UDim2.new(p,-7,0.5,-7)}, 0.04)
        pcall(cb, val)
    end

    track.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            drag = true; update(i.Position.X)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement
                  or i.UserInputType == Enum.UserInputType.Touch) then
            update(i.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then drag = false end
    end)
end

local function InfoCard(parent, label, value, icon, col)
    col = col or C.Accent
    local card = Instance.new("Frame"); card.Size = UDim2.new(1,0,0,58)
    card.BackgroundColor3 = C.Surface; card.BorderSizePixel = 0
    card.ZIndex = 13; card.Parent = parent
    do local r = Instance.new("UICorner"); r.CornerRadius = UDim.new(0,10); r.Parent = card end

    local iconF = Instance.new("Frame"); iconF.Size = UDim2.fromOffset(42,42)
    iconF.Position = UDim2.fromOffset(8,8); iconF.BackgroundColor3 = col
    iconF.BackgroundTransparency = 0.8; iconF.BorderSizePixel = 0; iconF.ZIndex = 14; iconF.Parent = card
    do local r = Instance.new("UICorner"); r.CornerRadius = UDim.new(0,10); r.Parent = iconF end

    local iL = Instance.new("TextLabel"); iL.Text = icon or "?"; iL.Font = Enum.Font.GothamBold
    iL.TextSize = 20; iL.TextColor3 = col; iL.BackgroundTransparency = 1
    iL.Size = UDim2.fromScale(1,1); iL.ZIndex = 15; iL.Parent = iconF

    local titL = Instance.new("TextLabel"); titL.Text = label; titL.Font = Enum.Font.Gotham
    titL.TextSize = 11; titL.TextColor3 = C.TextMuted; titL.BackgroundTransparency = 1
    titL.Size = UDim2.new(1,-62,0,20); titL.Position = UDim2.fromOffset(58,8)
    titL.TextXAlignment = Enum.TextXAlignment.Left; titL.ZIndex = 14; titL.Parent = card

    local valL = Instance.new("TextLabel"); valL.Text = value; valL.Font = Enum.Font.GothamBold
    valL.TextSize = 14; valL.TextColor3 = C.Text; valL.BackgroundTransparency = 1
    valL.Size = UDim2.new(1,-62,0,24); valL.Position = UDim2.fromOffset(58,28)
    valL.TextXAlignment = Enum.TextXAlignment.Left; valL.ZIndex = 14; valL.Parent = card
    return valL
end

-- ══════════════════════════════════════════════════════════════
--  TAB: INFO
-- ══════════════════════════════════════════════════════════════
do
    local P = Tabs["Info"].page

    -- Avatar card
    local avatarCard = Instance.new("Frame")
    avatarCard.Size = UDim2.new(1,0,0,120); avatarCard.BackgroundColor3 = C.Surface
    avatarCard.BorderSizePixel = 0; avatarCard.LayoutOrder = 1; avatarCard.ZIndex = 13; avatarCard.Parent = P
    do
        local r = Instance.new("UICorner"); r.CornerRadius = UDim.new(0,12); r.Parent = avatarCard
        local g = Instance.new("UIGradient")
        g.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(30,20,60)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(15,10,35)),
        }); g.Rotation = 135; g.Parent = avatarCard
    end

    local avi = Instance.new("ImageLabel")
    avi.Size = UDim2.fromOffset(90,90); avi.Position = UDim2.fromOffset(14,14)
    avi.BackgroundColor3 = C.Bg; avi.BorderSizePixel = 0; avi.ZIndex = 14
    avi.Image = "rbxthumb://type=AvatarHeadShot&id="..LocalPlayer.UserId.."&w=150&h=150"
    avi.Parent = avatarCard
    do
        local r = Instance.new("UICorner"); r.CornerRadius = UDim.new(0,45); r.Parent = avi
        local s = Instance.new("UIStroke"); s.Color = C.Accent; s.Thickness = 2.5; s.Parent = avi
    end

    local function AviText(txt, sz, col, y, bold)
        local l = Instance.new("TextLabel"); l.Text = txt
        l.Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham
        l.TextSize = sz; l.TextColor3 = col; l.BackgroundTransparency = 1
        l.Size = UDim2.new(1,-118,0,sz+4); l.Position = UDim2.fromOffset(112,y)
        l.TextXAlignment = Enum.TextXAlignment.Left; l.ZIndex = 14; l.Parent = avatarCard
    end

    AviText(LocalPlayer.DisplayName, 20, C.White,    16, true)
    AviText("@"..LocalPlayer.Name,   13, C.Accent,   40, false)
    AviText("UserID: "..LocalPlayer.UserId, 11, C.TextMuted, 58, false)
    AviText("Team: "..(LocalPlayer.Team and LocalPlayer.Team.Name or "None"), 11, C.TextMuted, 74, false)
    AviText("Account Age: "..LocalPlayer.AccountAge.." days", 11, C.TextMuted, 90, false)

    Section(P, "GAME INFO", 2)

    local gameCard = Instance.new("Frame")
    gameCard.Size = UDim2.new(1,0,0,80); gameCard.BackgroundColor3 = C.Surface
    gameCard.BorderSizePixel = 0; gameCard.LayoutOrder = 3; gameCard.ZIndex = 13; gameCard.Parent = P
    do local r = Instance.new("UICorner"); r.CornerRadius = UDim.new(0,12); r.Parent = gameCard end

    local gIco = Instance.new("TextLabel"); gIco.Text = "🎮"; gIco.Font = Enum.Font.GothamBold
    gIco.TextSize = 32; gIco.BackgroundTransparency = 1; gIco.Size = UDim2.fromOffset(60,80)
    gIco.Position = UDim2.fromOffset(10,0); gIco.ZIndex = 14; gIco.Parent = gameCard

    local gName = Instance.new("TextLabel"); gName.Text = "Loading..."
    gName.Font = Enum.Font.GothamBold; gName.TextSize = 14; gName.TextColor3 = C.Text
    gName.BackgroundTransparency = 1; gName.Size = UDim2.new(1,-80,0,24)
    gName.Position = UDim2.fromOffset(70,14); gName.TextXAlignment = Enum.TextXAlignment.Left
    gName.ZIndex = 14; gName.Parent = gameCard

    local gId = Instance.new("TextLabel"); gId.Text = "Place ID: "..game.PlaceId
    gId.Font = Enum.Font.Gotham; gId.TextSize = 11; gId.TextColor3 = C.TextMuted
    gId.BackgroundTransparency = 1; gId.Size = UDim2.new(1,-80,0,18)
    gId.Position = UDim2.fromOffset(70,36); gId.TextXAlignment = Enum.TextXAlignment.Left
    gId.ZIndex = 14; gId.Parent = gameCard

    local jobShort = (game.JobId ~= "" and game.JobId:sub(1,18).."...") or "Studio / Solo"
    local gJob = Instance.new("TextLabel"); gJob.Text = "Server: "..jobShort
    gJob.Font = Enum.Font.Gotham; gJob.TextSize = 10; gJob.TextColor3 = C.TextMuted
    gJob.BackgroundTransparency = 1; gJob.Size = UDim2.new(1,-80,0,16)
    gJob.Position = UDim2.fromOffset(70,54); gJob.TextXAlignment = Enum.TextXAlignment.Left
    gJob.ZIndex = 14; gJob.Parent = gameCard

    task.spawn(function()
        pcall(function()
            local info = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
            gName.Text = info.Name or "Unknown Game"
        end)
    end)

    Section(P, "LIVE STATS", 4)

    local statsGrid = Instance.new("Frame")
    statsGrid.Size = UDim2.new(1,0,0,0); statsGrid.BackgroundTransparency = 1
    statsGrid.AutomaticSize = Enum.AutomaticSize.Y; statsGrid.LayoutOrder = 5
    statsGrid.ZIndex = 13; statsGrid.Parent = P
    local sgl = Instance.new("UIGridLayout")
    sgl.CellSize = UDim2.new(0.48,-4,0,62); sgl.CellPadding = UDim2.fromOffset(8,8)
    sgl.Parent = statsGrid

    local pingL  = InfoCard(statsGrid, "Ping",    "--  ms", "📶", C.AccAlt)
    local fpsL   = InfoCard(statsGrid, "FPS",     "--  fps","⚡",  C.Success)
    local playL  = InfoCard(statsGrid, "Players", "--",     "👥", C.Warning)
    local wsL    = InfoCard(statsGrid, "Speed",   "16",     "🏃", C.Accent)

    local ltime, frames = tick(), 0
    RunService.RenderStepped:Connect(function()
        frames += 1
        local now = tick()
        if now - ltime >= 1 then
            fpsL.Text  = math.floor(frames/(now-ltime)).." fps"
            frames = 0; ltime = now
            pingL.Text = math.floor(LocalPlayer:GetNetworkPing()*1000).." ms"
            playL.Text = tostring(#Players:GetPlayers())
            pcall(function() wsL.Text = tostring(math.floor(Humanoid.WalkSpeed)) end)
        end
    end)

    Section(P, "DEVICE", 6)

    local devCard = Instance.new("Frame")
    devCard.Size = UDim2.new(1,0,0,50); devCard.BackgroundColor3 = C.Surface
    devCard.BorderSizePixel = 0; devCard.LayoutOrder = 7; devCard.ZIndex = 13; devCard.Parent = P
    do local r = Instance.new("UICorner"); r.CornerRadius = UDim.new(0,10); r.Parent = devCard end

    local dtype = mobile and "📱 Mobile" or (tablet and "📟 Tablet" or "🖥  PC / Desktop")
    -- SafeVersion() used here — never crashes
    local devT = Instance.new("TextLabel")
    devT.Text = dtype.."   •   "..math.floor(VP.X).."x"..math.floor(VP.Y).."   •   Executor: "..SafeVersion()
    devT.Font = Enum.Font.GothamSemibold; devT.TextSize = 12; devT.TextColor3 = C.Text
    devT.BackgroundTransparency = 1; devT.Size = UDim2.new(1,-20,1,0)
    devT.Position = UDim2.fromOffset(10,0); devT.TextXAlignment = Enum.TextXAlignment.Left
    devT.TextWrapped = true; devT.ZIndex = 14; devT.Parent = devCard
end

-- ══════════════════════════════════════════════════════════════
--  TAB: PLAYER
-- ══════════════════════════════════════════════════════════════
do
    local P = Tabs["Player"].page

    Section(P, "MOVEMENT", 1)
    -- 1 WalkSpeed
    Slider(P, "Walk Speed", 0, 500, 16, function(v)
        Cfg.WalkSpeed = v; pcall(function() Humanoid.WalkSpeed = v end)
    end, 2)
    -- 2 JumpPower
    Slider(P, "Jump Power", 0, 500, 50, function(v)
        Cfg.JumpPower = v
        pcall(function() Humanoid.JumpPower = v; Humanoid.UseJumpPower = true end)
    end, 3)
    -- 3 Infinite Jump
    Toggle(P, "Infinite Jump", "Jump again while airborne", false, function(v)
        Cfg.InfJump = v
    end, 4)
    -- 4 Fly
    Toggle(P, "Fly Mode", "Free-fly with WASD + Space/Shift", false, function(val)
        Cfg.Fly = val
        if val then
            local bv = Instance.new("BodyVelocity"); bv.Velocity = Vector3.zero
            bv.MaxForce = Vector3.new(1e5,1e5,1e5); bv.Name = "MinitFlyBV"; bv.Parent = HRP
            local bg = Instance.new("BodyGyro"); bg.MaxTorque = Vector3.new(1e5,1e5,1e5)
            bg.Name = "MinitFlyBG"; bg.Parent = HRP
            local conn; conn = RunService.RenderStepped:Connect(function()
                if not Cfg.Fly then
                    pcall(function() HRP:FindFirstChild("MinitFlyBV"):Destroy() end)
                    pcall(function() HRP:FindFirstChild("MinitFlyBG"):Destroy() end)
                    conn:Disconnect(); return
                end
                local spd = _G.MinitFlySpeed or 50
                local dir = Vector3.zero
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += Camera.CFrame.LookVector  end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= Camera.CFrame.LookVector  end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= Camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += Camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space)     then dir += Vector3.yAxis end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.yAxis end
                if dir.Magnitude > 0 then dir = dir.Unit end
                local bvI = HRP:FindFirstChild("MinitFlyBV")
                local bgI = HRP:FindFirstChild("MinitFlyBG")
                if bvI then bvI.Velocity = dir * spd end
                if bgI then bgI.CFrame   = Camera.CFrame end
            end)
        end
    end, 5)

    Section(P, "CHARACTER", 6)
    -- 5 Noclip
    Toggle(P, "Noclip", "Phase through all parts", false, function(val)
        Cfg.Noclip = val
        if val then
            RunService.Stepped:Connect(function()
                if not Cfg.Noclip then return end
                for _, p in ipairs(Character:GetDescendants()) do
                    if p:IsA("BasePart") and p ~= HRP then p.CanCollide = false end
                end
            end)
        end
    end, 7)
    -- 6 God Mode
    Toggle(P, "God Mode", "Infinite HP, cannot die", false, function(val)
        Cfg.GodMode = val
        if val then
            Humanoid.MaxHealth = math.huge; Humanoid.Health = math.huge
            Humanoid.HealthChanged:Connect(function()
                if Cfg.GodMode then Humanoid.Health = math.huge end
            end)
        end
    end, 8)
    -- 7 Auto Respawn
    Toggle(P, "Auto Respawn", "Auto-reload character on death", false, function(val)
        Cfg.AutoRespawn = val
        if val then
            Humanoid.Died:Connect(function()
                if Cfg.AutoRespawn then task.wait(0.5); LocalPlayer:LoadCharacter() end
            end)
        end
    end, 9)
    -- 8 Invisible
    Toggle(P, "Invisible (Client)", "Hide your character locally", false, function(val)
        for _, p in ipairs(Character:GetDescendants()) do
            if p:IsA("BasePart") or p:IsA("Decal") then p.Transparency = val and 1 or 0 end
        end
        HRP.Transparency = 1
    end, 10)

    Section(P, "SPEED PRESETS", 11)
    for i, preset in ipairs({{name="Normal",v=16},{name="Fast",v=50},{name="Turbo",v=100},{name="Ultra",v=250}}) do
        Button(P, preset.name.." ("..preset.v..")", C.AccAlt, function()
            pcall(function() Humanoid.WalkSpeed = preset.v end)
        end, 11+i)
    end

    Section(P, "ACTIONS", 16)
    Button(P, "Unlock Max Zoom (500)", C.AccAlt, function()
        LocalPlayer.CameraMaxZoomDistance = 500
        Notify("Minit HUB", "Max zoom set to 500 ✓")
    end, 17)
    Button(P, "Toggle Sit",             C.Accent,  function() Humanoid.Sit = not Humanoid.Sit end, 18)
    Button(P, "Teleport to Spawn",      C.Success, function()
        local s = workspace:FindFirstChildOfClass("SpawnLocation")
        if s then HRP.CFrame = s.CFrame + Vector3.new(0,5,0) end
    end, 19)
    Button(P, "Reset Character",        C.Danger,  function() Humanoid.Health = 0 end, 20)
end

-- ══════════════════════════════════════════════════════════════
--  TAB: COMBAT
-- ══════════════════════════════════════════════════════════════
do
    local P = Tabs["Combat"].page
    local kaRange, kaActive = 20, false

    Section(P, "KILL AURA", 1)
    -- 9 Kill Aura
    Toggle(P, "Kill Aura", "Damage nearby players continuously", false, function(val)
        kaActive = val
        if val then task.spawn(function()
            while kaActive do
                for _, pl in ipairs(Players:GetPlayers()) do
                    if pl ~= LocalPlayer and pl.Character then
                        local h   = pl.Character:FindFirstChildOfClass("Humanoid")
                        local hrp = pl.Character:FindFirstChild("HumanoidRootPart")
                        if h and hrp and (hrp.Position-HRP.Position).Magnitude <= kaRange then
                            h:TakeDamage(10)
                        end
                    end
                end
                task.wait(0.1)
            end
        end) end
    end, 2)
    -- 10 KA range
    Slider(P, "Kill Aura Range", 5, 100, 20, function(v) kaRange = v end, 3)

    Section(P, "TARGETING", 4)
    -- 11 Soft Aimbot
    Toggle(P, "Soft Aimbot", "Lock camera to nearest player head", false, function(val)
        if val then
            local conn; conn = RunService.RenderStepped:Connect(function()
                if not val then conn:Disconnect(); return end
                local nearest, dist = nil, math.huge
                for _, pl in ipairs(Players:GetPlayers()) do
                    if pl ~= LocalPlayer and pl.Character then
                        local head = pl.Character:FindFirstChild("Head")
                        if head then
                            local d = (head.Position-HRP.Position).Magnitude
                            if d < dist then dist = d; nearest = head end
                        end
                    end
                end
                if nearest then
                    Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, nearest.Position)
                end
            end)
        end
    end, 5)
    -- 12 Anti-KB
    Toggle(P, "Anti-Knockback", "Zero out incoming velocity forces", false, function(val)
        if val then local conn; conn = RunService.Heartbeat:Connect(function()
            if not val then conn:Disconnect(); return end
            for _, v in ipairs(HRP:GetChildren()) do
                if v:IsA("BodyVelocity") or v:IsA("BodyForce") then v.Velocity = Vector3.zero end
            end
        end) end
    end, 6)
    -- 13 Anti-Ragdoll
    Toggle(P, "Anti-Ragdoll", "Disable ragdoll joint constraints", false, function(val)
        for _, v in ipairs(Character:GetDescendants()) do
            if v:IsA("BallSocketConstraint") or v:IsA("HingeConstraint") then v.Enabled = not val end
        end
    end, 7)
    -- 14 Speed burst
    Toggle(P, "Speed Burst on Jump", "Briefly boost speed on each jump", false, function(val)
        if val then Humanoid.Jumping:Connect(function(active)
            if active and val then
                local prev = Humanoid.WalkSpeed; Humanoid.WalkSpeed = 80
                task.delay(0.5, function() Humanoid.WalkSpeed = prev end)
            end
        end) end
    end, 8)

    Section(P, "ONE-SHOT TOOLS", 9)
    -- 15 Fling nearest
    Button(P, "Fling Nearest Player", C.Danger, function()
        local nearest, dist = nil, math.huge
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl ~= LocalPlayer and pl.Character then
                local hrp = pl.Character:FindFirstChild("HumanoidRootPart")
                if hrp then local d = (hrp.Position-HRP.Position).Magnitude
                    if d < dist then dist = d; nearest = hrp end end
            end
        end
        if nearest then
            local vel = Instance.new("BodyVelocity")
            vel.Velocity = Vector3.new(math.random(-100,100), 260, math.random(-100,100))
            vel.MaxForce = Vector3.new(1e6,1e6,1e6); vel.Parent = nearest
            Debris:AddItem(vel, 0.2)
        end
    end, 10)
    -- 16 Damage all
    Button(P, "Damage All Players (10 HP)", C.Danger, function()
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl ~= LocalPlayer and pl.Character then
                local h = pl.Character:FindFirstChildOfClass("Humanoid")
                if h then h:TakeDamage(10) end
            end
        end
    end, 11)
    -- 17 Expand hitboxes
    Button(P, "Expand All Hitboxes (10x)", C.Warning, function()
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl ~= LocalPlayer and pl.Character then
                for _, part in ipairs(pl.Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.Size = part.Size * 10 end
                end
            end
        end
        Notify("Minit HUB", "Hitboxes expanded ✓")
    end, 12)
end

-- ══════════════════════════════════════════════════════════════
--  TAB: WORLD
-- ══════════════════════════════════════════════════════════════
do
    local P = Tabs["World"].page
    Section(P, "ENVIRONMENT", 1)
    -- 18 Fullbright
    Toggle(P, "Full Bright", "Maximum scene brightness", false, function(val)
        Lighting.Brightness = val and 2 or 1
        if val then
            for _, v in ipairs(Lighting:GetChildren()) do
                if v:IsA("FogEffect") or v:IsA("BlurEffect") then v.Enabled = false end
            end
        end
    end, 2)
    -- 19 No fog
    Toggle(P, "Remove Fog", "Eliminate atmospheric fog", false, function(val)
        Lighting.FogEnd = val and 1e6 or 1000; Lighting.FogStart = val and 1e6 or 0
    end, 3)
    -- 20 Time slider
    Slider(P, "Time of Day (0-24)", 0, 24, 14, function(v) Lighting.ClockTime = v end, 4)
    -- 21 Night mode
    Button(P, "Night Mode",      C.AccAlt,  function()
        Lighting.Ambient = Color3.fromRGB(10,10,20); Lighting.OutdoorAmbient = Color3.fromRGB(20,20,40)
        Lighting.ClockTime = 0; Lighting.Brightness = 0.2
    end, 5)
    -- 22 Day mode
    Button(P, "Day Mode",        C.Warning, function()
        Lighting.Ambient = Color3.fromRGB(128,128,128); Lighting.OutdoorAmbient = Color3.fromRGB(128,128,128)
        Lighting.ClockTime = 14; Lighting.Brightness = 1
    end, 6)

    Section(P, "WORLD TOOLS", 7)
    -- 23 Gravity
    Slider(P, "Gravity", 0, 200, 196, function(v) workspace.Gravity = v end, 8)
    -- 24 Zero gravity
    Button(P, "Zero Gravity",    C.Accent,  function() workspace.Gravity = 0; Notify("Minit HUB","Gravity = 0 ✓") end, 9)
    -- 25 Flood
    Button(P, "Flood World",     C.AccAlt,  function()
        workspace.Terrain:FillBlock(CFrame.new(0,-20,0), Vector3.new(2048,40,2048), Enum.Material.Water)
        Notify("Minit HUB","World flooded ✓")
    end, 10)
    -- 26 Flatten
    Button(P, "Flatten Terrain", C.Success, function()
        workspace.Terrain:FillBlock(CFrame.new(0,-6,0), Vector3.new(2048,10,2048), Enum.Material.Grass)
        Notify("Minit HUB","Terrain flattened ✓")
    end, 11)
    -- 27 Delete parts
    Button(P, "Delete Loose Parts", C.Danger, function()
        for _, v in ipairs(workspace:GetChildren()) do
            if v:IsA("BasePart") then v:Destroy() end
        end
        Notify("Minit HUB","Parts deleted ✓")
    end, 12)
    -- 28 Black hole
    Button(P, "Black Hole Effect", C.Danger, function()
        task.spawn(function()
            for i = 1, 80 do
                for _, v in ipairs(workspace:GetDescendants()) do
                    if v:IsA("BasePart") and not v:IsAncestorOf(Character) then
                        v.Velocity = (HRP.Position - v.Position).Unit * 80
                    end
                end
                task.wait(0.05)
            end
        end)
    end, 13)
end

-- ══════════════════════════════════════════════════════════════
--  TAB: ESP
-- ══════════════════════════════════════════════════════════════
do
    local P = Tabs["ESP"].page
    local espBoxes, espNames = {}, {}
    local espOn, espNamesOn = false, false

    local function ClearESP()
        for _, v in pairs(espBoxes) do pcall(function() v:Destroy() end) end
        for _, v in pairs(espNames) do pcall(function() v:Destroy() end) end
        espBoxes, espNames = {}, {}
    end

    local function BuildESP()
        ClearESP(); if not espOn then return end
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl ~= LocalPlayer and pl.Character then
                local hrp  = pl.Character:FindFirstChild("HumanoidRootPart")
                local head = pl.Character:FindFirstChild("Head")
                if hrp then
                    local box = Instance.new("BoxHandleAdornment")
                    box.Adornee = hrp; box.AlwaysOnTop = true
                    box.Color3 = Color3.fromRGB(255,80,80)
                    box.Size = hrp.Size + Vector3.new(0.5,3.5,0.5)
                    box.Transparency = 0.6; box.ZIndex = 5; box.Parent = hrp
                    espBoxes[pl.Name] = box
                end
                if espNamesOn and head then
                    local bb = Instance.new("BillboardGui"); bb.Adornee = head
                    bb.Size = UDim2.fromOffset(200,30); bb.StudsOffset = Vector3.new(0,2.5,0)
                    bb.AlwaysOnTop = true; bb.Parent = head
                    local tl = Instance.new("TextLabel", bb); tl.Text = pl.DisplayName
                    tl.Font = Enum.Font.GothamBold; tl.TextSize = 14
                    tl.TextColor3 = C.White; tl.BackgroundTransparency = 1; tl.Size = UDim2.fromScale(1,1)
                    espNames[pl.Name] = bb
                end
            end
        end
    end

    Section(P, "ESP SETTINGS", 1)
    -- 29 Box ESP
    Toggle(P, "Player ESP (Boxes)", "Red box outlines on all players", false, function(val)
        espOn = val; BuildESP()
        if val then task.spawn(function()
            while espOn do
                for _, pl in ipairs(Players:GetPlayers()) do
                    if pl ~= LocalPlayer and not espBoxes[pl.Name] then BuildESP() break end
                end
                task.wait(2)
            end
        end) end
    end, 2)
    -- 30 Name tags
    Toggle(P, "Name Tags + Distance", "Billboard above each player", false, function(val)
        espNamesOn = val; BuildESP()
    end, 3)
    -- 31 Health color
    Toggle(P, "Health-Color ESP", "Box color reflects HP percentage", false, function(val)
        if val then task.spawn(function()
            while val do
                for _, pl in ipairs(Players:GetPlayers()) do
                    if pl ~= LocalPlayer and pl.Character then
                        local h   = pl.Character:FindFirstChildOfClass("Humanoid")
                        local box = espBoxes[pl.Name]
                        if h and box then
                            local p = h.Health / math.max(h.MaxHealth,1)
                            box.Color3 = Color3.fromRGB(math.floor(255*(1-p)), math.floor(255*p), 0)
                        end
                    end
                end
                task.wait(0.2)
            end
        end) end
    end, 4)

    Section(P, "WORLD ESP", 5)
    -- 32 Highlight parts
    Button(P, "Highlight All World Parts", C.Warning, function()
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and not v:IsAncestorOf(Character) then
                local sel = Instance.new("SelectionBox"); sel.Adornee = v
                sel.Color3 = Color3.fromRGB(0,200,255); sel.LineThickness = 0.03
                sel.SurfaceTransparency = 0.85; sel.SurfaceColor3 = Color3.fromRGB(0,200,255)
                sel.Parent = workspace; Debris:AddItem(sel, 10)
            end
        end
        Notify("Minit HUB", "Part ESP on (10s) ✓")
    end, 6)
    -- 33 Team chams
    Button(P, "Team Chams (Green)", C.Success, function()
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl.Team == LocalPlayer.Team and pl ~= LocalPlayer and pl.Character then
                local hl = Instance.new("Highlight"); hl.Adornee = pl.Character
                hl.FillColor = Color3.fromRGB(0,255,100); hl.FillTransparency = 0.5
                hl.OutlineColor = Color3.fromRGB(0,255,100); hl.Parent = pl.Character
                Debris:AddItem(hl, 30)
            end
        end
    end, 7)
    -- 34 Enemy chams
    Button(P, "Enemy Chams (Red)", C.Danger, function()
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl.Team ~= LocalPlayer.Team and pl ~= LocalPlayer and pl.Character then
                local hl = Instance.new("Highlight"); hl.Adornee = pl.Character
                hl.FillColor = Color3.fromRGB(255,50,50); hl.FillTransparency = 0.5
                hl.OutlineColor = Color3.fromRGB(255,50,50); hl.Parent = pl.Character
                Debris:AddItem(hl, 30)
            end
        end
    end, 8)
    -- 35 Clear
    Button(P, "Clear All ESP", C.TextMuted, function()
        ClearESP()
        for _, v in ipairs(game:GetDescendants()) do
            if v:IsA("Highlight") or v:IsA("SelectionBox") or v:IsA("BoxHandleAdornment") then v:Destroy() end
        end
        Notify("Minit HUB","ESP cleared ✓")
    end, 9)
end

-- ══════════════════════════════════════════════════════════════
--  TAB: TROLL
-- ══════════════════════════════════════════════════════════════
do
    local P = Tabs["Troll"].page
    local chatMsg = "Minit HUB is the best!"

    Section(P, "CHAT", 1)

    local inputF = Instance.new("Frame"); inputF.Size = UDim2.new(1,0,0,40)
    inputF.BackgroundColor3 = C.Surface; inputF.BorderSizePixel = 0
    inputF.ZIndex = 13; inputF.LayoutOrder = 2; inputF.Parent = P
    do local r = Instance.new("UICorner"); r.CornerRadius = UDim.new(0,8); r.Parent = inputF end
    local chatBox = Instance.new("TextBox"); chatBox.PlaceholderText = "Enter spam message..."
    chatBox.PlaceholderColor3 = C.TextMuted; chatBox.Text = chatMsg
    chatBox.Font = Enum.Font.Gotham; chatBox.TextSize = 13; chatBox.TextColor3 = C.Text
    chatBox.BackgroundTransparency = 1; chatBox.Size = UDim2.new(1,-20,1,0)
    chatBox.Position = UDim2.fromOffset(10,0); chatBox.ClearTextOnFocus = false
    chatBox.TextXAlignment = Enum.TextXAlignment.Left; chatBox.ZIndex = 14; chatBox.Parent = inputF
    chatBox.FocusLost:Connect(function() chatMsg = chatBox.Text end)

    -- 36 Chat spam
    local spamActive = false
    Toggle(P, "Chat Spam", "Repeatedly send your message", false, function(val)
        spamActive = val
        if val then task.spawn(function()
            while spamActive do
                pcall(function() game:GetService("Chat"):Chat(LocalPlayer.Character.Head, chatMsg) end)
                task.wait(1)
            end
        end) end
    end, 3)
    -- 37 Send once
    Button(P, "Send Message Once", Color3.fromRGB(200,100,255), function()
        pcall(function() game:GetService("Chat"):Chat(LocalPlayer.Character.Head, chatMsg) end)
    end, 4)

    Section(P, "PLAYER TROLLING", 5)
    -- 38 Follow
    local followActive = false
    Toggle(P, "Follow Nearest Player", "Chase the closest player", false, function(val)
        followActive = val
        if val then task.spawn(function()
            while followActive do
                local nearest, dist = nil, math.huge
                for _, pl in ipairs(Players:GetPlayers()) do
                    if pl ~= LocalPlayer and pl.Character then
                        local hrp = pl.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then local d = (hrp.Position-HRP.Position).Magnitude
                            if d < dist then dist = d; nearest = hrp end end
                    end
                end
                if nearest then Humanoid:MoveTo(nearest.Position) end
                task.wait(0.1)
            end
        end) end
    end, 6)
    -- 39 Orbit
    local orbitActive = false
    Toggle(P, "Orbit Nearest Player", "Circle around the nearest player", false, function(val)
        orbitActive = val
        if val then task.spawn(function()
            local angle = 0
            while orbitActive do
                angle += 0.05
                local nearest, dist = nil, math.huge
                for _, pl in ipairs(Players:GetPlayers()) do
                    if pl ~= LocalPlayer and pl.Character then
                        local hrp = pl.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then local d = (hrp.Position-HRP.Position).Magnitude
                            if d < dist then dist = d; nearest = hrp end end
                    end
                end
                if nearest then
                    HRP.CFrame = CFrame.new(nearest.Position + Vector3.new(math.cos(angle)*8, 0, math.sin(angle)*8))
                end
                task.wait(0.03)
            end
        end) end
    end, 7)
    -- 40 Blast off
    Button(P, "Blast Off (Self)", Color3.fromRGB(200,100,255), function()
        local vel = Instance.new("BodyVelocity"); vel.Velocity = Vector3.new(0,500,0)
        vel.MaxForce = Vector3.new(0,1e6,0); vel.Parent = HRP; Debris:AddItem(vel, 0.3)
    end, 8)
    -- 41 Annoy
    Button(P, "Annoy Nearest Player", Color3.fromRGB(200,100,255), function()
        local nearest, dist = nil, math.huge
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl ~= LocalPlayer and pl.Character then
                local hrp = pl.Character:FindFirstChild("HumanoidRootPart")
                if hrp then local d = (hrp.Position-HRP.Position).Magnitude
                    if d < dist then dist = d; nearest = hrp end end
            end
        end
        if nearest then
            HRP.CFrame = CFrame.new(nearest.Position + Vector3.new(0,2,0))
            task.spawn(function()
                for _ = 1, 10 do Humanoid.Jump = true; task.wait(0.15) end
            end)
        end
    end, 9)
    -- 42 Sound
    Button(P, "Play Random Sound", Color3.fromRGB(200,100,255), function()
        local sounds = {6518811702, 4613071542, 1843671842, 447041359, 130776675}
        local s = Instance.new("Sound"); s.SoundId = "rbxassetid://"..sounds[math.random(1,#sounds)]
        s.Volume = 0.5; s.Parent = workspace; s:Play(); Debris:AddItem(s, 15)
    end, 10)

    Section(P, "SIZE", 11)
    -- 43 Giant
    Toggle(P, "Giant Mode (5x)", "Scale character to 5x size", false, function(val)
        local h = Character:FindFirstChildOfClass("Humanoid")
        if not h then return end
        local s = val and 5 or 1
        h.BodyDepthScale.Value=s; h.BodyHeightScale.Value=s; h.BodyWidthScale.Value=s; h.HeadScale.Value=s
    end, 12)
    -- 44 Tiny
    Toggle(P, "Tiny Mode (0.3x)", "Scale character to 0.3x size", false, function(val)
        local h = Character:FindFirstChildOfClass("Humanoid")
        if not h then return end
        local s = val and 0.3 or 1
        h.BodyDepthScale.Value=s; h.BodyHeightScale.Value=s; h.BodyWidthScale.Value=s; h.HeadScale.Value=s
    end, 13)
end

-- ══════════════════════════════════════════════════════════════
--  TAB: VISUAL
-- ══════════════════════════════════════════════════════════════
do
    local P = Tabs["Visual"].page
    Section(P, "CAMERA", 1)
    -- 45 FOV
    Slider(P, "Camera FOV", 40, 120, 70, function(v) Camera.FieldOfView = v end, 2)
    -- 46 Cinematic bars
    Toggle(P, "Cinematic Bars", "Letterbox effect", false, function(val)
        local ex = SG:FindFirstChild("CinematicBars")
        if val then
            if ex then ex:Destroy() end
            local bars = Instance.new("Frame", SG); bars.Name = "CinematicBars"
            bars.Size = UDim2.fromScale(1,1); bars.BackgroundTransparency = 1
            local top = Instance.new("Frame", bars); top.Size = UDim2.new(1,0,0,0)
            top.BackgroundColor3 = Color3.new(0,0,0); top.BorderSizePixel = 0; top.ZIndex = 50
            Tween(top,{Size=UDim2.new(1,0,0,80)},0.5)
            local bot = Instance.new("Frame", bars); bot.Size = UDim2.new(1,0,0,0)
            bot.Position = UDim2.new(0,0,1,0); bot.BackgroundColor3 = Color3.new(0,0,0)
            bot.BorderSizePixel = 0; bot.ZIndex = 50
            Tween(bot,{Size=UDim2.new(1,0,0,80),Position=UDim2.new(0,0,1,-80)},0.5)
        else
            if ex then ex:Destroy() end
        end
    end, 3)
    -- 47 Blur
    Slider(P, "Blur Intensity", 0, 56, 0, function(v)
        local b = Lighting:FindFirstChildOfClass("BlurEffect") or Instance.new("BlurEffect", Lighting)
        b.Size = v
    end, 4)
    -- 48 Bloom
    Slider(P, "Bloom Intensity", 0, 5, 0, function(v)
        local b = Lighting:FindFirstChildOfClass("BloomEffect") or Instance.new("BloomEffect", Lighting)
        b.Intensity = v; b.Threshold = 0.8; b.Size = 24
    end, 5)

    Section(P, "CHARACTER FX", 6)
    -- 49 Rainbow
    Toggle(P, "Rainbow Character", "Cycle HSV color on character parts", false, function(val)
        if val then task.spawn(function()
            local h = 0
            while val do
                h = (h+1)%360
                local col = Color3.fromHSV(h/360, 1, 1)
                for _, p in ipairs(Character:GetDescendants()) do
                    if p:IsA("BasePart") then p.Color = col end
                end
                task.wait(0.05)
            end
        end) end
    end, 7)
    -- 50 Neon
    Toggle(P, "Neon Parts", "Set character parts to Neon material", false, function(val)
        for _, p in ipairs(Character:GetDescendants()) do
            if p:IsA("BasePart") then
                p.Material = val and Enum.Material.Neon or Enum.Material.SmoothPlastic
            end
        end
    end, 8)
    -- 51 Trail
    Toggle(P, "Speed Trail", "Motion trail behind character", false, function(val)
        local trail = HRP:FindFirstChild("MinitTrail")
        if val then
            if trail then trail:Destroy() end
            local a0 = Instance.new("Attachment", HRP); a0.Position = Vector3.new(0,1,0)
            local a1 = Instance.new("Attachment", HRP); a1.Position = Vector3.new(0,-1,0)
            local t  = Instance.new("Trail"); t.Name = "MinitTrail"
            t.Attachment0 = a0; t.Attachment1 = a1; t.Lifetime = 0.5
            t.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, C.Accent),
                ColorSequenceKeypoint.new(1, C.AccAlt),
            })
            t.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0),
                NumberSequenceKeypoint.new(1, 1),
            })
            t.Parent = HRP
        else
            if trail then trail:Destroy() end
        end
    end, 9)
    -- 52 Force field
    Toggle(P, "Force Field Effect", "Visual shield on character", false, function(val)
        local ff = Character:FindFirstChildOfClass("ForceField")
        if val and not ff then Instance.new("ForceField", Character).Visible = true
        elseif not val and ff then ff:Destroy() end
    end, 10)
    -- 53 Sparkle
    Button(P, "Add Sparkle Particles", Color3.fromRGB(255,180,80), function()
        for _, p in ipairs(Character:GetDescendants()) do
            if p:IsA("BasePart") then
                local pe = Instance.new("ParticleEmitter"); pe.Rate = 20
                pe.Lifetime = NumberRange.new(0.5,1.5); pe.Speed = NumberRange.new(1,4)
                pe.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, C.AccGlow),
                    ColorSequenceKeypoint.new(1, C.AccAlt),
                })
                pe.Size = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0.1),
                    NumberSequenceKeypoint.new(1, 0),
                })
                pe.Parent = p; Debris:AddItem(pe, 8); break
            end
        end
    end, 11)
    -- 54 Clock overlay
    Toggle(P, "Clock Overlay", "Real-time clock HUD on screen", false, function(val)
        local clk = SG:FindFirstChild("MinitClock")
        if val then
            if clk then clk:Destroy() end
            local frame = Instance.new("Frame", SG); frame.Name = "MinitClock"
            frame.Size = UDim2.fromOffset(160,34); frame.Position = UDim2.new(1,-170,0,10)
            frame.BackgroundColor3 = C.Surface; frame.BackgroundTransparency = 0.3
            frame.BorderSizePixel = 0; frame.ZIndex = 200
            do local r = Instance.new("UICorner"); r.CornerRadius = UDim.new(0,8); r.Parent = frame end
            local tl = Instance.new("TextLabel", frame); tl.Font = Enum.Font.GothamBold
            tl.TextSize = 15; tl.TextColor3 = C.Accent; tl.BackgroundTransparency = 1
            tl.Size = UDim2.fromScale(1,1); tl.ZIndex = 201
            RunService.Heartbeat:Connect(function()
                if not val then return end
                local t = os.date("*t")
                tl.Text = string.format("🕐 %02d:%02d:%02d", t.hour, t.min, t.sec)
            end)
        else
            if clk then clk:Destroy() end
        end
    end, 12)
end

-- ══════════════════════════════════════════════════════════════
--  TAB: MISC
-- ══════════════════════════════════════════════════════════════
do
    local P = Tabs["Misc"].page
    Section(P, "ANTI-AFK & AUTO", 1)
    -- 55 Anti-AFK
    Toggle(P, "Anti-AFK", "Prevent kick timer from running", false, function(val)
        Cfg.AntiAFK = val
        if val then local conn; conn = RunService.Heartbeat:Connect(function()
            if not Cfg.AntiAFK then conn:Disconnect(); return end
            pcall(function() VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.zero) end)
        end) end
    end, 2)
    -- 56 Auto Click  (SafeClick wrapper - no nil crash)
    local acActive = false
    Toggle(P, "Auto Click (LMB)", "Rapidly click mouse button", false, function(val)
        acActive = val
        if val then task.spawn(function()
            while acActive do SafeClick(); task.wait(0.05) end
        end) end
    end, 3)

    Section(P, "PLAYER TOOLS", 4)
    -- 57 Print position
    Button(P, "Print My Position", C.AccAlt, function()
        print("[Minit HUB] CFrame:", tostring(HRP.CFrame))
        Notify("Minit HUB","Position printed to console ✓")
    end, 5)
    -- 58 Teleport random
    Button(P, "Teleport to Random Player", C.Accent, function()
        local others = {}
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl ~= LocalPlayer and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then
                table.insert(others, pl)
            end
        end
        if #others > 0 then
            local t = others[math.random(1,#others)]
            HRP.CFrame = t.Character.HumanoidRootPart.CFrame + Vector3.new(0,5,0)
            Notify("Minit HUB","Teleported to "..t.Name)
        else
            Notify("Minit HUB","No other players!")
        end
    end, 6)
    -- 59 Server hop
    Button(P, "Server Hop", C.Warning, function()
        Notify("Minit HUB","Searching for server...")
        task.spawn(function()
            local ok, data = pcall(function()
                return HttpService:JSONDecode(
                    game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=25")
                )
            end)
            if ok and data and data.data then
                for _, s in ipairs(data.data) do
                    if s.id ~= game.JobId and s.playing < s.maxPlayers then
                        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
                        return
                    end
                end
            end
            Notify("Minit HUB","No free server found.")
        end)
    end, 7)
    -- 60 Rejoin
    Button(P, "Rejoin Server", C.Danger, function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end, 8)

    Section(P, "SCRIPTS & INFO", 9)
    -- 61 Print remotes
    Button(P, "Print All Remote Events", C.TextMuted, function()
        for _, v in ipairs(game:GetDescendants()) do
            if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
                print("[Minit HUB] Remote:", v:GetFullName())
            end
        end
        Notify("Minit HUB","Remotes printed ✓")
    end, 10)
    -- 62 Workspace tree
    Button(P, "Print Workspace Tree", C.TextMuted, function()
        local function pt(i, d)
            print(string.rep("  ",d)..i.Name.." ["..i.ClassName.."]")
            for _, c in ipairs(i:GetChildren()) do pt(c, d+1) end
        end
        pt(workspace, 0); Notify("Minit HUB","Tree printed ✓")
    end, 11)
    -- 63 Copy player list  (SafeSetClipboard - no nil crash)
    Button(P, "Copy Player List to Clipboard", C.AccAlt, function()
        local names = {}
        for _, pl in ipairs(Players:GetPlayers()) do table.insert(names, pl.Name) end
        SafeSetClipboard(table.concat(names, ", "))
        Notify("Minit HUB","Player list copied ✓")
    end, 12)
    -- 64 Disable animations
    Toggle(P, "Disable Animations", "Freeze character animations", false, function(val)
        local a = Character:FindFirstChild("Animate")
        if a then a.Disabled = val end
    end, 13)
    -- 65 Spin
    local spinActive = false
    Toggle(P, "Spin Character", "Rotate in place continuously", false, function(val)
        spinActive = val
        if val then task.spawn(function()
            while spinActive do
                HRP.CFrame = HRP.CFrame * CFrame.Angles(0, 0.1, 0)
                task.wait()
            end
        end) end
    end, 14)
    -- 66 Hide GUIs
    Toggle(P, "Hide Game GUIs", "Toggle all in-game GUI screens", false, function(val)
        for _, v in ipairs(LocalPlayer.PlayerGui:GetChildren()) do
            if v ~= SG then pcall(function() v.Enabled = not val end) end
        end
    end, 15)
    -- 67 Super push
    Button(P, "Super Push Forward", C.Warning, function()
        local bv = Instance.new("BodyVelocity")
        bv.Velocity = Camera.CFrame.LookVector * 300
        bv.MaxForce = Vector3.new(1e6,1e6,1e6); bv.Parent = HRP; Debris:AddItem(bv, 0.25)
    end, 16)
    -- 68 List scripts
    Button(P, "List All Scripts", C.TextMuted, function()
        for _, v in ipairs(game:GetDescendants()) do
            if v:IsA("LocalScript") or v:IsA("Script") or v:IsA("ModuleScript") then
                print("[Minit HUB] Script:", v:GetFullName())
            end
        end
        Notify("Minit HUB","Scripts listed ✓")
    end, 17)
end

-- ══════════════════════════════════════════════════════════════
--  TAB: SETTINGS
-- ══════════════════════════════════════════════════════════════
do
    local P = Tabs["Settings"].page
    Section(P, "FPS CONTROL", 1)

    -- 69 FPS Unlock  (SafeSetFPSCap - no nil crash)
    Toggle(P, "Unlock FPS (No Cap)", "Remove Roblox 60fps limit", false, function(val)
        Cfg.FPSUnlocked = val
        SafeSetFPSCap(val and 0 or Cfg.FPSLimit)
        Notify("Minit HUB", val and "FPS Unlocked ✓" or "FPS capped to "..Cfg.FPSLimit)
    end, 2)

    -- 70 FPS Cap slider
    Slider(P, "FPS Cap (when not unlocked)", 30, 360, 60, function(v)
        Cfg.FPSLimit = v
        if not Cfg.FPSUnlocked then SafeSetFPSCap(v) end
    end, 3)

    -- 71-75 FPS presets
    local fpsGrid = Instance.new("Frame"); fpsGrid.Size = UDim2.new(1,0,0,0)
    fpsGrid.BackgroundTransparency = 1; fpsGrid.AutomaticSize = Enum.AutomaticSize.Y
    fpsGrid.LayoutOrder = 4; fpsGrid.ZIndex = 13; fpsGrid.Parent = P
    local fgl = Instance.new("UIGridLayout"); fgl.CellSize = UDim2.new(0.19,-4,0,34)
    fgl.CellPadding = UDim2.fromOffset(4,4); fgl.Parent = fpsGrid
    for _, v in ipairs({30, 60, 120, 240, 360}) do
        Button(fpsGrid, tostring(v), C.Accent, function()
            SafeSetFPSCap(v); Cfg.FPSLimit = v
            Notify("Minit HUB","FPS set to "..v.." ✓")
        end)
    end

    Section(P, "TOGGLE KEY", 5)

    local keyCard = Instance.new("Frame"); keyCard.Size = UDim2.new(1,0,0,56)
    keyCard.BackgroundColor3 = C.Surface; keyCard.BorderSizePixel = 0
    keyCard.LayoutOrder = 6; keyCard.ZIndex = 13; keyCard.Parent = P
    do local r = Instance.new("UICorner"); r.CornerRadius = UDim.new(0,8); r.Parent = keyCard end

    local kL = Instance.new("TextLabel"); kL.Text = "Hub Toggle Key"
    kL.Font = Enum.Font.GothamSemibold; kL.TextSize = 13; kL.TextColor3 = C.Text
    kL.BackgroundTransparency = 1; kL.Size = UDim2.new(0.6,0,1,0); kL.Position = UDim2.fromOffset(10,0)
    kL.TextXAlignment = Enum.TextXAlignment.Left; kL.ZIndex = 14; kL.Parent = keyCard

    local kBtn = Instance.new("TextButton"); kBtn.Text = "RightShift"
    kBtn.Font = Enum.Font.GothamBold; kBtn.TextSize = 12; kBtn.TextColor3 = C.White
    kBtn.Size = UDim2.fromOffset(110,30); kBtn.Position = UDim2.new(1,-120,0.5,-15)
    kBtn.BackgroundColor3 = C.Accent; kBtn.BorderSizePixel = 0; kBtn.ZIndex = 15; kBtn.Parent = keyCard
    do local r = Instance.new("UICorner"); r.CornerRadius = UDim.new(0,6); r.Parent = kBtn end

    local waitKey = false
    kBtn.MouseButton1Click:Connect(function()
        if waitKey then return end; waitKey = true; kBtn.Text = "Press a key..."
        Tween(kBtn,{BackgroundColor3=C.Warning},0.2)
        local conn; conn = UserInputService.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.Keyboard then
                Cfg.ToggleKey = inp.KeyCode
                kBtn.Text = tostring(inp.KeyCode):match("Enum%.KeyCode%.(.+)") or "?"
                Tween(kBtn,{BackgroundColor3=C.Accent},0.2)
                waitKey = false; conn:Disconnect()
            end
        end)
    end)

    Section(P, "THEME PRESETS", 7)

    local themeGrid = Instance.new("Frame"); themeGrid.Size = UDim2.new(1,0,0,0)
    themeGrid.BackgroundTransparency = 1; themeGrid.AutomaticSize = Enum.AutomaticSize.Y
    themeGrid.LayoutOrder = 8; themeGrid.ZIndex = 13; themeGrid.Parent = P
    local thgl = Instance.new("UIGridLayout"); thgl.CellSize = UDim2.new(0.3,-4,0,34)
    thgl.CellPadding = UDim2.fromOffset(6,6); thgl.Parent = themeGrid
    for _, t in ipairs({
        {"Purple", Color3.fromRGB(120,80,255)},
        {"Blue",   Color3.fromRGB(80,160,255)},
        {"Cyan",   Color3.fromRGB(0,220,220)},
        {"Green",  Color3.fromRGB(60,220,120)},
        {"Red",    Color3.fromRGB(255,60,60)},
        {"Gold",   Color3.fromRGB(255,200,60)},
    }) do
        Button(themeGrid, t[1], t[2], function()
            C.Accent = t[2]; Notify("Minit HUB","Theme → "..t[1])
        end)
    end

    Section(P, "EXTRA FUNCTIONS", 9)

    -- 76 Remove shadows
    Toggle(P, "Remove Shadows",        nil, false, function(val) Lighting.GlobalShadows = not val end, 10)
    -- 77 Wireframe
    Toggle(P, "Wireframe Mode",        nil, false, function(val)
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and not v:IsAncestorOf(Character) then
                v.Material = val and Enum.Material.Glass or Enum.Material.SmoothPlastic
                v.Transparency = val and 0.9 or 0
            end
        end
    end, 11)
    -- 78 Health regen
    Toggle(P, "Health Regen (+5/0.5s)", nil, false, function(val)
        if val then task.spawn(function()
            while val do
                pcall(function()
                    if Humanoid.Health < Humanoid.MaxHealth then
                        Humanoid.Health = math.min(Humanoid.Health+5, Humanoid.MaxHealth)
                    end
                end)
                task.wait(0.5)
            end
        end) end
    end, 12)
    -- 79 Heal
    Button(P, "Heal to Full HP",       C.Success, function() Humanoid.Health = Humanoid.MaxHealth end, 13)
    -- 80 Kill self
    Button(P, "Kill Self",             C.Danger,  function() Humanoid.Health = 0 end, 14)
    -- 81 Freeze self
    Toggle(P, "Freeze Self",           nil, false, function(val) HRP.Anchored = val end, 15)
    -- 82 Freeze others
    Button(P, "Freeze Other Players",  C.Danger, function()
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl ~= LocalPlayer and pl.Character then
                local hrp = pl.Character:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.Anchored = true end
            end
        end
        Notify("Minit HUB","Players frozen ✓")
    end, 16)
    -- 83 Unfreeze
    Button(P, "Unfreeze All Players",  C.Success, function()
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl ~= LocalPlayer and pl.Character then
                local hrp = pl.Character:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.Anchored = false end
            end
        end
        Notify("Minit HUB","Players unfrozen ✓")
    end, 17)
    -- 84 Drop tools
    Button(P, "Drop All Tools",        C.Warning, function()
        for _, v in ipairs(LocalPlayer.Backpack:GetChildren()) do v:Destroy() end
        for _, v in ipairs(Character:GetChildren()) do
            if v:IsA("Tool") then v.Parent = nil end
        end
        Notify("Minit HUB","Tools dropped ✓")
    end, 18)
    -- 85 Head hide
    Button(P, "Hide Head (Visual)",    C.TextMuted, function()
        local head = Character:FindFirstChild("Head")
        if head then head.Transparency = 1 end
        local face = Character:FindFirstChild("face", true)
        if face then face.Transparency = 1 end
        Notify("Minit HUB","Head hidden ✓")
    end, 19)
    -- 86 Ice mode
    Button(P, "Ice Mode (0 Friction)", C.AccAlt, function()
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then v.Friction = 0 end
        end
        Notify("Minit HUB","Ice mode ✓")
    end, 20)
    -- 87 Max friction
    Button(P, "Max Friction",          C.TextMuted, function()
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then v.Friction = 1 end
        end
        Notify("Minit HUB","Friction maxed ✓")
    end, 21)
    -- 88 Acid trip
    Button(P, "Acid Trip Mode",        C.AccGlow, function()
        task.spawn(function()
            for i = 1, 360 do
                Lighting.Ambient        = Color3.fromHSV(i/360, 1, 1)
                Lighting.OutdoorAmbient = Color3.fromHSV((i+120)/360, 1, 1)
                task.wait(0.05)
            end
            Lighting.Ambient        = Color3.fromRGB(128,128,128)
            Lighting.OutdoorAmbient = Color3.fromRGB(128,128,128)
        end)
    end, 22)
    -- 89 Disco
    Toggle(P, "Disco Lights",          nil, false, function(val)
        if val then task.spawn(function()
            while val do Lighting.Ambient = Color3.fromHSV(math.random(),1,1); task.wait(0.1) end
        end) else Lighting.Ambient = Color3.fromRGB(128,128,128) end
    end, 23)
    -- 90 Stop animations
    Button(P, "Stop All Animations",   C.TextMuted, function()
        for _, anim in ipairs(Humanoid:GetPlayingAnimationTracks()) do anim:Stop() end
        Notify("Minit HUB","Animations stopped ✓")
    end, 24)
    -- 91 Print values
    Button(P, "Print All Game Values", C.TextMuted, function()
        for _, v in ipairs(game:GetDescendants()) do
            if v:IsA("ValueBase") then print("[Minit HUB]", v:GetFullName(), "=", tostring(v.Value)) end
        end
        Notify("Minit HUB","Values printed ✓")
    end, 25)
    -- 92 Shift lock
    Button(P, "Enable Shift Lock",     C.Accent, function()
        pcall(function() StarterGui:SetCore("DevEnableMouseLock", true) end)
        Notify("Minit HUB","Shift lock enabled ✓")
    end, 26)
    -- 93 Reset camera
    Button(P, "Reset Camera Type",     C.AccAlt, function()
        Camera.CameraType = Enum.CameraType.Custom
        Notify("Minit HUB","Camera reset ✓")
    end, 27)
    -- 94 Fly speed slider
    Slider(P, "Fly Speed", 10, 300, 50, function(v) _G.MinitFlySpeed = v end, 28)
    -- 95 Super push
    Button(P, "Super Push Forward",    C.Warning, function()
        local bv = Instance.new("BodyVelocity")
        bv.Velocity = Camera.CFrame.LookVector * 300
        bv.MaxForce = Vector3.new(1e6,1e6,1e6); bv.Parent = HRP; Debris:AddItem(bv, 0.25)
    end, 29)
    -- 96 Clear highlights
    Button(P, "Clear All Highlights",  C.TextMuted, function()
        for _, v in ipairs(game:GetDescendants()) do
            if v:IsA("Highlight") or v:IsA("SelectionBox") or v:IsA("BoxHandleAdornment") then v:Destroy() end
        end
        Notify("Minit HUB","Highlights cleared ✓")
    end, 30)
    -- 97 Infinite stamina
    Toggle(P, "Infinite Stamina Loop", nil, false, function(val)
        if val then local conn; conn = RunService.Heartbeat:Connect(function()
            if not val then conn:Disconnect(); return end
            Humanoid.JumpHeight = 7.2
        end) end
    end, 31)
    -- 98 Print scripts
    Button(P, "List All Scripts",      C.TextMuted, function()
        for _, v in ipairs(game:GetDescendants()) do
            if v:IsA("LocalScript") or v:IsA("Script") or v:IsA("ModuleScript") then
                print("[Minit HUB] Script:", v:GetFullName())
            end
        end
        Notify("Minit HUB","Scripts listed ✓")
    end, 32)
    -- 99 Spin toggle (extra)
    Toggle(P, "Spin World Camera",     nil, false, function(val)
        if val then task.spawn(function()
            while val do
                Camera.CFrame = Camera.CFrame * CFrame.Angles(0, 0.02, 0)
                task.wait()
            end
        end) end
    end, 33)
    -- 100 About
    Section(P, "ABOUT", 34)
    local aboutCard = Instance.new("Frame"); aboutCard.Size = UDim2.new(1,0,0,62)
    aboutCard.BackgroundColor3 = C.Surface; aboutCard.BorderSizePixel = 0
    aboutCard.LayoutOrder = 35; aboutCard.ZIndex = 13; aboutCard.Parent = P
    do
        local r = Instance.new("UICorner"); r.CornerRadius = UDim.new(0,10); r.Parent = aboutCard
        local g = Instance.new("UIGradient")
        g.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(30,20,60)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(10,10,25)),
        }); g.Rotation = 45; g.Parent = aboutCard
    end
    local aL = Instance.new("TextLabel")
    aL.Text = "Minit HUB v3.0 ULTRA  |  discord.gg/minithub\n100 FE Scripts  |  Multi-Device  |  Animated GUI"
    aL.Font = Enum.Font.Gotham; aL.TextSize = 12; aL.TextColor3 = C.TextDim
    aL.BackgroundTransparency = 1; aL.Size = UDim2.new(1,-20,1,0); aL.Position = UDim2.fromOffset(10,0)
    aL.TextXAlignment = Enum.TextXAlignment.Left; aL.TextWrapped = true; aL.ZIndex = 14; aL.Parent = aboutCard
end

-- ══════════════════════════════════════════════════════════════
--  OPEN / CLOSE LOGIC
-- ══════════════════════════════════════════════════════════════
local guiOpen, minimized = true, false

local function OpenGUI()
    guiOpen = true; Main.Visible = true
    Main.Size = UDim2.fromOffset(math.floor(GW*0.82), math.floor(GH*0.82))
    Main.BackgroundTransparency = 0.6
    Tween(Main, {
        Size = UDim2.fromOffset(GW, GH),
        BackgroundTransparency = 0,
    }, 0.38, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    Tween(InnerGlow, {BackgroundTransparency=0.82}, 0.38)
end

local function CloseGUI()
    guiOpen = false
    Tween(Main, {
        Size = UDim2.fromOffset(math.floor(GW*0.82), math.floor(GH*0.82)),
        BackgroundTransparency = 1,
    }, 0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
    Tween(InnerGlow, {BackgroundTransparency=1}, 0.28)
    task.delay(0.30, function() if not guiOpen then Main.Visible = false end end)
end

local function ToggleMinimize()
    minimized = not minimized
    if minimized then
        Tween(Main, {Size=UDim2.fromOffset(GW,46)}, 0.28)
        Sidebar.Visible = false; Content.Visible = false
    else
        Tween(Main, {Size=UDim2.fromOffset(GW,GH)}, 0.34, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        task.delay(0.12, function() Sidebar.Visible=true; Content.Visible=true end)
    end
end

CloseBtn.MouseButton1Click:Connect(CloseGUI)
MinimizeBtn.MouseButton1Click:Connect(ToggleMinimize)
ToggleBtn.MouseButton1Click:Connect(function()
    if guiOpen then CloseGUI() else OpenGUI() end
end)

UserInputService.InputBegan:Connect(function(inp, gpe)
    if gpe then return end
    if inp.KeyCode == Cfg.ToggleKey then
        if guiOpen then CloseGUI() else OpenGUI() end
    end
    if inp.KeyCode == Enum.KeyCode.Space and Cfg.InfJump then
        local st = Humanoid:GetState()
        if st == Enum.HumanoidStateType.Freefall or st == Enum.HumanoidStateType.Jumping then
            Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- ══════════════════════════════════════════════════════════════
--  DRAG (TitleBar)
-- ══════════════════════════════════════════════════════════════
do
    local dragging, dragInput, dragStart, startPos = false, nil, nil, nil

    TitleBar.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = inp.Position; startPos = Main.Position
            inp.Changed:Connect(function()
                if inp.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    TitleBar.InputChanged:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseMovement
        or inp.UserInputType == Enum.UserInputType.Touch then
            dragInput = inp
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if inp == dragInput and dragging then
            local d = inp.Position - dragStart
            Main.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
end

-- ══════════════════════════════════════════════════════════════
--  AMBIENT ANIMATIONS
-- ══════════════════════════════════════════════════════════════
-- Toggle button pulse
task.spawn(function()
    while true do
        Tween(TGlow, {BackgroundTransparency=0.48, Size=UDim2.fromOffset(78,78), Position=UDim2.fromOffset(-13,-13)}, 0.8, Enum.EasingStyle.Sine)
        task.wait(0.8)
        Tween(TGlow, {BackgroundTransparency=0.88, Size=UDim2.fromOffset(62,62), Position=UDim2.fromOffset(-5,-5)},   0.8, Enum.EasingStyle.Sine)
        task.wait(0.8)
    end
end)
-- Title icon color shift
task.spawn(function()
    while true do
        Tween(TitleIcon, {TextColor3=C.AccAlt},  1.6, Enum.EasingStyle.Sine)
        task.wait(1.6)
        Tween(TitleIcon, {TextColor3=C.AccGlow}, 1.6, Enum.EasingStyle.Sine)
        task.wait(1.6)
    end
end)
-- Status dot blink
task.spawn(function()
    while true do
        Tween(StatusDot, {BackgroundTransparency=0},   0.6)
        task.wait(0.7)
        Tween(StatusDot, {BackgroundTransparency=0.7}, 0.6)
        task.wait(0.7)
    end
end)
-- Inner glow color shift
task.spawn(function()
    while true do
        Tween(InnerGlow, {BackgroundColor3=C.AccAlt}, 2.2, Enum.EasingStyle.Sine)
        task.wait(2.2)
        Tween(InnerGlow, {BackgroundColor3=C.Accent}, 2.2, Enum.EasingStyle.Sine)
        task.wait(2.2)
    end
end)

-- ══════════════════════════════════════════════════════════════
--  CHARACTER RESPAWN REFRESH
-- ══════════════════════════════════════════════════════════════
LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid  = char:WaitForChild("Humanoid")
    HRP       = char:WaitForChild("HumanoidRootPart")
    if Cfg.GodMode   then Humanoid.MaxHealth = math.huge; Humanoid.Health = math.huge end
    if Cfg.WalkSpeed then Humanoid.WalkSpeed  = Cfg.WalkSpeed end
    if Cfg.JumpPower then Humanoid.JumpPower  = Cfg.JumpPower; Humanoid.UseJumpPower = true end
end)

-- ══════════════════════════════════════════════════════════════
--  STARTUP
-- ══════════════════════════════════════════════════════════════
Main.BackgroundTransparency = 1
Main.Size = UDim2.fromOffset(math.floor(GW*0.7), math.floor(GH*0.7))
task.wait(0.35)
OpenGUI()

task.delay(1, function()
    Notify("Minit HUB v3.0 ULTRA",
        "Welcome, "..LocalPlayer.DisplayName.."!  100 FE scripts ready ✓", 5)
end)

print("[Minit HUB v3.0 ULTRA] Loaded! Toggle: "
    .. (tostring(Cfg.ToggleKey):match("Enum%.KeyCode%.(.+)") or "RightShift"))
