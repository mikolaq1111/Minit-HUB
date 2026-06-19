--[[
    ███╗   ███╗██╗███╗   ██╗██╗████████╗    ██╗  ██╗██╗   ██╗██████╗ 
    ████╗ ████║██║████╗  ██║██║╚══██╔══╝    ██║  ██║██║   ██║██╔══██╗
    ██╔████╔██║██║██╔██╗ ██║██║   ██║       ███████║██║   ██║██████╔╝
    ██║╚██╔╝██║██║██║╚██╗██║██║   ██║       ██╔══██║██║   ██║██╔══██╗
    ██║ ╚═╝ ██║██║██║ ╚████║██║   ██║       ██║  ██║╚██████╔╝██████╔╝
    ╚═╝     ╚═╝╚═╝╚═╝  ╚═══╝╚═╝   ╚═╝       ╚═╝  ╚═╝ ╚═════╝ ╚═════╝ 
    Version  : 3.0 ULTRA
    Author   : Minit Team
    Discord  : discord.gg/minithub
    Features : 100 FE Scripts | Animated GUI | FPS Unlock | Multi-Device
]]

-- ════════════════════════════════════════════════════════════════════════
--                          SERVICES & GLOBALS
-- ════════════════════════════════════════════════════════════════════════
local Players            = game:GetService("Players")
local RunService         = game:GetService("RunService")
local UserInputService   = game:GetService("UserInputService")
local TweenService       = game:GetService("TweenService")
local HttpService        = game:GetService("HttpService")
local CoreGui            = game:GetService("CoreGui")
local Lighting           = game:GetService("Lighting")
local StarterGui         = game:GetService("StarterGui")
local VirtualUser        = game:GetService("VirtualUser")
local LocalPlayer        = Players.LocalPlayer
local Mouse              = LocalPlayer:GetMouse()
local Camera             = workspace.CurrentCamera
local Character          = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid           = Character:WaitForChild("Humanoid")
local HumanoidRootPart   = Character:WaitForChild("HumanoidRootPart")

-- ════════════════════════════════════════════════════════════════════════
--                          UTILITY FUNCTIONS
-- ════════════════════════════════════════════════════════════════════════
local function Tween(obj, props, time, style, dir)
    style = style or Enum.EasingStyle.Quart
    dir   = dir   or Enum.EasingDirection.Out
    return TweenService:Create(obj, TweenInfo.new(time, style, dir), props):Play()
end

local function SafeNotify(title, text, dur)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title    = title or "Minit HUB",
            Text     = text  or "",
            Duration = dur   or 3,
        })
    end)
end

local function IsMobile()
    return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

local function IsTablet()
    local vp = Camera.ViewportSize
    return UserInputService.TouchEnabled and vp.X >= 768
end

-- ════════════════════════════════════════════════════════════════════════
--                          THEME & CONFIG
-- ════════════════════════════════════════════════════════════════════════
local Theme = {
    Background   = Color3.fromRGB(10,  10,  18),
    Surface      = Color3.fromRGB(18,  18,  30),
    SurfaceAlt   = Color3.fromRGB(24,  24,  40),
    Border       = Color3.fromRGB(60,  60,  100),
    Accent       = Color3.fromRGB(120, 80,  255),
    AccentAlt    = Color3.fromRGB(80,  160, 255),
    AccentGlow   = Color3.fromRGB(160, 100, 255),
    Danger       = Color3.fromRGB(255, 80,  80),
    Success      = Color3.fromRGB(80,  255, 140),
    Warning      = Color3.fromRGB(255, 200, 60),
    Text         = Color3.fromRGB(240, 240, 255),
    TextDim      = Color3.fromRGB(160, 160, 200),
    TextMuted    = Color3.fromRGB(100, 100, 140),
    White        = Color3.fromRGB(255, 255, 255),
    Black        = Color3.fromRGB(0,   0,   0),
    TabActive    = Color3.fromRGB(120, 80,  255),
    TabInactive  = Color3.fromRGB(30,  30,  50),
    Toggle_On    = Color3.fromRGB(100, 220, 130),
    Toggle_Off   = Color3.fromRGB(60,  60,  80),
}

local Config = {
    GuiOpen        = true,
    ToggleKey      = Enum.KeyCode.RightShift,
    FPSLimit       = 60,
    UnlockFPS      = false,
    WalkSpeed      = 16,
    JumpPower      = 50,
    AntiAFK        = false,
    Noclip         = false,
    Infinite_Jump  = false,
    Fly_Active     = false,
    GodMode        = false,
    ChatSpam       = false,
    AutoRespawn    = false,
}

-- ════════════════════════════════════════════════════════════════════════
--                          GUI CONSTRUCTION
-- ════════════════════════════════════════════════════════════════════════
if CoreGui:FindFirstChild("MinitHUB_v3") then CoreGui:FindFirstChild("MinitHUB_v3"):Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name            = "MinitHUB_v3"
ScreenGui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn    = false
ScreenGui.IgnoreGuiInset  = true
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer.PlayerGui end

local vp     = Camera.ViewportSize
local mobile = IsMobile()
local tablet = IsTablet()
local GUI_W  = mobile and (vp.X - 20) or (tablet and 700 or 880)
local GUI_H  = mobile and (vp.Y - 80) or (tablet and 500 or 560)

-- ── FLOATING TOGGLE BUTTON ──────────────────────────────────────────────
local ToggleBtn = Instance.new("ImageButton")
ToggleBtn.Name              = "ToggleBtn"
ToggleBtn.Size              = UDim2.fromOffset(52, 52)
ToggleBtn.Position          = UDim2.new(0, 14, 0.5, -26)
ToggleBtn.BackgroundColor3  = Theme.Accent
ToggleBtn.BorderSizePixel   = 0
ToggleBtn.ZIndex            = 100
ToggleBtn.Parent            = ScreenGui
local _c = Instance.new("UICorner"); _c.CornerRadius = UDim.new(1,0); _c.Parent = ToggleBtn

local ToggleGrad = Instance.new("UIGradient")
ToggleGrad.Color    = ColorSequence.new({ColorSequenceKeypoint.new(0,Theme.AccentGlow),ColorSequenceKeypoint.new(1,Theme.AccentAlt)})
ToggleGrad.Rotation = 45
ToggleGrad.Parent   = ToggleBtn

local ToggleLabel = Instance.new("TextLabel")
ToggleLabel.Text              = "M"
ToggleLabel.Font              = Enum.Font.GothamBold
ToggleLabel.TextSize          = 22
ToggleLabel.TextColor3        = Theme.White
ToggleLabel.BackgroundTransparency = 1
ToggleLabel.Size              = UDim2.fromScale(1,1)
ToggleLabel.ZIndex            = 101
ToggleLabel.Parent            = ToggleBtn

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Color     = Theme.AccentGlow
ToggleStroke.Thickness = 2
ToggleStroke.Parent    = ToggleBtn

local ToggleGlow = Instance.new("Frame")
ToggleGlow.Size              = UDim2.fromOffset(70,70)
ToggleGlow.Position          = UDim2.fromOffset(-9,-9)
ToggleGlow.BackgroundColor3  = Theme.Accent
ToggleGlow.BackgroundTransparency = 0.7
ToggleGlow.ZIndex            = 99
ToggleGlow.Parent            = ToggleBtn
local _gc = Instance.new("UICorner"); _gc.CornerRadius = UDim.new(1,0); _gc.Parent = ToggleGlow

-- ── MAIN FRAME ─────────────────────────────────────────────────────────
local MainFrame = Instance.new("Frame")
MainFrame.Name              = "MainFrame"
MainFrame.Size              = UDim2.fromOffset(GUI_W, GUI_H)
MainFrame.Position          = UDim2.new(0.5, -(GUI_W/2), 0.5, -(GUI_H/2))
MainFrame.BackgroundColor3  = Theme.Background
MainFrame.BorderSizePixel   = 0
MainFrame.ZIndex            = 10
MainFrame.ClipsDescendants  = false
MainFrame.Parent            = ScreenGui
local _mc = Instance.new("UICorner"); _mc.CornerRadius = UDim.new(0,16); _mc.Parent = MainFrame
local _ms = Instance.new("UIStroke"); _ms.Color = Theme.Border; _ms.Thickness = 1.5; _ms.Parent = MainFrame

local InnerGlow = Instance.new("Frame")
InnerGlow.Size              = UDim2.new(1, 4, 1, 4)
InnerGlow.Position          = UDim2.fromOffset(-2,-2)
InnerGlow.BackgroundColor3  = Theme.Accent
InnerGlow.BackgroundTransparency = 0.82
InnerGlow.ZIndex            = 9
InnerGlow.Parent            = MainFrame
local _igc = Instance.new("UICorner"); _igc.CornerRadius = UDim.new(0,18); _igc.Parent = InnerGlow

-- ── TITLE BAR ──────────────────────────────────────────────────────────
local TitleBar = Instance.new("Frame")
TitleBar.Name              = "TitleBar"
TitleBar.Size              = UDim2.new(1,0,0,46)
TitleBar.BackgroundColor3  = Theme.Surface
TitleBar.BorderSizePixel   = 0
TitleBar.ZIndex            = 12
TitleBar.Parent            = MainFrame
local _tbc = Instance.new("UICorner"); _tbc.CornerRadius = UDim.new(0,16); _tbc.Parent = TitleBar
local _tbf = Instance.new("Frame"); _tbf.Size = UDim2.new(1,0,0,20); _tbf.Position = UDim2.new(0,0,1,-20); _tbf.BackgroundColor3 =
Theme.Surface; _tbf.BorderSizePixel = 0; _tbf.ZIndex = 12; _tbf.Parent = TitleBar

local TitleGrad = Instance.new("UIGradient")
TitleGrad.Color    =
ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(30,20,60)),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(20,15,50)),Color
SequenceKeypoint.new(1,Color3.fromRGB(10,10,30))})
TitleGrad.Rotation = 90
TitleGrad.Parent   = TitleBar

local TitleIcon = Instance.new("TextLabel")
TitleIcon.Text = "⬡"; TitleIcon.Font = Enum.Font.GothamBold; TitleIcon.TextSize = 22
TitleIcon.TextColor3 = Theme.Accent; TitleIcon.BackgroundTransparency = 1
TitleIcon.Size = UDim2.fromOffset(36,46); TitleIcon.Position = UDim2.fromOffset(10,0)
TitleIcon.ZIndex = 13; TitleIcon.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Text = "Minit HUB"; TitleText.Font = Enum.Font.GothamBold; TitleText.TextSize = 18
TitleText.TextColor3 = Theme.White; TitleText.BackgroundTransparency = 1
TitleText.Size = UDim2.new(1,-200,1,0); TitleText.Position = UDim2.fromOffset(46,0)
TitleText.TextXAlignment = Enum.TextXAlignment.Left; TitleText.ZIndex = 13; TitleText.Parent = TitleBar

local TitleVer = Instance.new("TextLabel")
TitleVer.Text = "v3.0 ULTRA"; TitleVer.Font = Enum.Font.Gotham; TitleVer.TextSize = 11
TitleVer.TextColor3 = Theme.Accent; TitleVer.BackgroundTransparency = 1
TitleVer.Size = UDim2.fromOffset(80,46); TitleVer.Position = UDim2.new(0,46,0,0)
TitleVer.TextXAlignment = Enum.TextXAlignment.Left; TitleVer.TextYAlignment = Enum.TextYAlignment.Bottom
TitleVer.ZIndex = 13; TitleVer.Parent = TitleBar

local function MakeWinBtn(icon, color, posX)
    local b = Instance.new("TextButton")
    b.Text = icon; b.Font = Enum.Font.GothamBold; b.TextSize = 13; b.TextColor3 = Theme.White
    b.Size = UDim2.fromOffset(28,28); b.Position = UDim2.new(1,posX,0.5,-14)
    b.BackgroundColor3 = color; b.BorderSizePixel = 0; b.ZIndex = 14; b.Parent = TitleBar
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(1,0); c.Parent = b
    b.MouseEnter:Connect(function() Tween(b,{BackgroundTransparency=0.3},0.15) end)
    b.MouseLeave:Connect(function() Tween(b,{BackgroundTransparency=0},0.15) end)
    return b
end
local CloseBtn    = MakeWinBtn("✕", Theme.Danger, -14)
local MinimizeBtn = MakeWinBtn("─", Theme.Warning, -48)

local StatusDot = Instance.new("Frame")
StatusDot.Size = UDim2.fromOffset(8,8); StatusDot.Position = UDim2.new(1,-90,0.5,-4)
StatusDot.BackgroundColor3 = Theme.Success; StatusDot.BorderSizePixel = 0
StatusDot.ZIndex = 13; StatusDot.Parent = TitleBar
local _sdc = Instance.new("UICorner"); _sdc.CornerRadius = UDim.new(1,0); _sdc.Parent = StatusDot

-- ── SIDEBAR ─────────────────────────────────────────────────────────────
local sideW = mobile and 54 or 66
local SideBar = Instance.new("Frame")
SideBar.Name = "SideBar"; SideBar.Size = UDim2.new(0,sideW,1,-46)
SideBar.Position = UDim2.fromOffset(0,46); SideBar.BackgroundColor3 = Theme.Surface
SideBar.BorderSizePixel = 0; SideBar.ZIndex = 11; SideBar.Parent = MainFrame
local _sbc = Instance.new("UICorner"); _sbc.CornerRadius = UDim.new(0,16); _sbc.Parent = SideBar
local _sbf = Instance.new("Frame"); _sbf.Size = UDim2.new(0,20,1,0); _sbf.Position = UDim2.new(1,-20,0,0); _sbf.BackgroundColor3 =
Theme.Surface; _sbf.BorderSizePixel = 0; _sbf.ZIndex = 11; _sbf.Parent = SideBar
local _sbt = Instance.new("Frame"); _sbt.Size = UDim2.new(1,0,0,16); _sbt.BackgroundColor3 = Theme.Surface; _sbt.BorderSizePixel = 0;
_sbt.ZIndex = 11; _sbt.Parent = SideBar

local SideGrad = Instance.new("UIGradient")
SideGrad.Color =
ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(22,18,45)),ColorSequenceKeypoint.new(1,Color3.fromRGB(14,12,30))})
SideGrad.Rotation = 90; SideGrad.Parent = SideBar

local SideList = Instance.new("ScrollingFrame")
SideList.Size = UDim2.new(1,0,1,-10); SideList.Position = UDim2.fromOffset(0,8)
SideList.BackgroundTransparency = 1; SideList.BorderSizePixel = 0
SideList.ScrollBarThickness = 0; SideList.CanvasSize = UDim2.new(0,0,0,0)
SideList.ZIndex = 12; SideList.Parent = SideBar
local SideLayout = Instance.new("UIListLayout")
SideLayout.Padding = UDim.new(0,6); SideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
SideLayout.Parent = SideList

-- ── CONTENT AREA ────────────────────────────────────────────────────────
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"; ContentFrame.Size = UDim2.new(1,-(sideW+8),1,-54)
ContentFrame.Position = UDim2.fromOffset(sideW+4,50); ContentFrame.BackgroundColor3 = Theme.SurfaceAlt
ContentFrame.BorderSizePixel = 0; ContentFrame.ClipsDescendants = true
ContentFrame.ZIndex = 11; ContentFrame.Parent = MainFrame
local _cfc = Instance.new("UICorner"); _cfc.CornerRadius = UDim.new(0,12); _cfc.Parent = ContentFrame

-- ════════════════════════════════════════════════════════════════════════
--                          TAB SYSTEM
-- ════════════════════════════════════════════════════════════════════════
local Tabs       = {}
local TabButtons = {}

local TabDefs = {
    {name="Info",     icon="👤", color=Color3.fromRGB(80,160,255)},
    {name="Player",   icon="🏃", color=Color3.fromRGB(120,80,255)},
    {name="Combat",   icon="⚔️",  color=Color3.fromRGB(255,80,80)},
    {name="World",    icon="🌍", color=Color3.fromRGB(80,255,140)},
    {name="ESP",      icon="👁",  color=Color3.fromRGB(255,200,60)},
    {name="Troll",    icon="😈", color=Color3.fromRGB(200,100,255)},
    {name="Visual",   icon="🎨", color=Color3.fromRGB(255,180,80)},
    {name="Misc",     icon="🔧", color=Color3.fromRGB(160,160,200)},
    {name="Settings", icon="⚙️",  color=Color3.fromRGB(160,100,255)},
}

local function MakePage()
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.fromScale(1,1); scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0; scroll.ScrollBarThickness = 4
    scroll.ScrollBarImageColor3 = Theme.Accent; scroll.CanvasSize = UDim2.new(0,0,0,0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; scroll.ZIndex = 12
    scroll.Visible = false; scroll.Parent = ContentFrame
    local pad = Instance.new("UIPadding"); pad.PaddingTop = UDim.new(0,10)
    pad.PaddingBottom = UDim.new(0,10); pad.PaddingLeft = UDim.new(0,10)
    pad.PaddingRight = UDim.new(0,10); pad.Parent = scroll
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0,6); layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.FillDirection = Enum.FillDirection.Vertical; layout.Parent = scroll
    return scroll
end

for i, def in ipairs(TabDefs) do
    local page = MakePage()
    Tabs[def.name] = {page=page, def=def}

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,sideW-10,0,sideW-10); btn.BackgroundColor3 = Color3.fromRGB(30,30,50)
    btn.BorderSizePixel = 0; btn.Text = ""; btn.ZIndex = 13; btn.LayoutOrder = i; btn.Parent = SideList
    local _bc = Instance.new("UICorner"); _bc.CornerRadius = UDim.new(0,10); _bc.Parent = btn

    local iconL = Instance.new("TextLabel")
    iconL.Text = def.icon; iconL.Font = Enum.Font.GothamBold; iconL.TextSize = mobile and 16 or 18
    iconL.TextColor3 = Theme.TextDim; iconL.BackgroundTransparency = 1
    iconL.Size = UDim2.new(1,0,0.55,0); iconL.Position = UDim2.new(0,0,0,4); iconL.ZIndex = 14; iconL.Parent = btn

    local nameL = Instance.new("TextLabel")
    nameL.Text = def.name; nameL.Font = Enum.Font.Gotham; nameL.TextSize = mobile and 8 or 9
    nameL.TextColor3 = Theme.TextMuted; nameL.BackgroundTransparency = 1
    nameL.Size = UDim2.new(1,0,0.4,0); nameL.Position = UDim2.new(0,0,0.58,0); nameL.ZIndex = 14; nameL.Parent = btn

    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.fromOffset(3,20); indicator.Position = UDim2.new(1,-1,0.5,-10)
    indicator.BackgroundColor3 = def.color; indicator.BackgroundTransparency = 1
    indicator.BorderSizePixel = 0; indicator.ZIndex = 14; indicator.Parent = btn
    local _ic = Instance.new("UICorner"); _ic.CornerRadius = UDim.new(1,0); _ic.Parent = indicator

    TabButtons[def.name] = {btn=btn, icon=iconL, name=nameL, indicator=indicator, def=def}

    btn.MouseButton1Click:Connect(function()
        for tname, tb in pairs(TabButtons) do
            Tween(tb.btn, {BackgroundColor3=Color3.fromRGB(30,30,50)}, 0.2)
            Tween(tb.icon, {TextColor3=Theme.TextDim}, 0.2)
            Tween(tb.name, {TextColor3=Theme.TextMuted}, 0.2)
            Tween(tb.indicator, {BackgroundTransparency=1}, 0.2)
            Tabs[tname].page.Visible = false
        end
        Tween(btn, {BackgroundColor3=def.color}, 0.2)
        Tween(iconL, {TextColor3=Theme.White}, 0.2)
        Tween(nameL, {TextColor3=Theme.White}, 0.2)
        Tween(indicator, {BackgroundTransparency=0}, 0.2)
        page.Visible = true
        page.Position = UDim2.fromOffset(30,0)
        Tween(page, {Position=UDim2.fromOffset(0,0)}, 0.25, Enum.EasingStyle.Quart)
    end)
end

-- Activate Info tab by default
do
    local d = TabDefs[1]; local tb = TabButtons[d.name]
    tb.btn.BackgroundColor3 = d.color; tb.icon.TextColor3 = Theme.White
    tb.name.TextColor3 = Theme.White; tb.indicator.BackgroundTransparency = 0
    Tabs[d.name].page.Visible = true
end

SideLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    SideList.CanvasSize = UDim2.fromOffset(0, SideLayout.AbsoluteContentSize.Y + 16)
end)

-- ════════════════════════════════════════════════════════════════════════
--                        WIDGET BUILDERS
-- ════════════════════════════════════════════════════════════════════════
local function MakeSection(parent, title, order)
    local sec = Instance.new("Frame"); sec.BackgroundTransparency = 1
    sec.Size = UDim2.new(1,0,0,28); sec.ZIndex = 13; sec.LayoutOrder = order or 0; sec.Parent = parent
    local line = Instance.new("Frame"); line.Size = UDim2.new(1,0,0,1); line.Position = UDim2.new(0,0,0.5,0)
    line.BackgroundColor3 = Theme.Border; line.BorderSizePixel = 0; line.ZIndex = 13; line.Parent = sec
    local lbl = Instance.new("TextLabel"); lbl.Text = "  "..title.."  "; lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 11; lbl.TextColor3 = Theme.Accent; lbl.BackgroundColor3 = Theme.SurfaceAlt
    lbl.BorderSizePixel = 0; lbl.AutomaticSize = Enum.AutomaticSize.X
    lbl.Size = UDim2.fromOffset(0,22); lbl.Position = UDim2.new(0.02,0,0.5,-11)
    lbl.ZIndex = 14; lbl.Parent = sec
    return sec
end

local function MakeToggle(parent, text, desc, defaultVal, callback, order)
    local val = defaultVal or false
    local container = Instance.new("TextButton")
    container.Size = UDim2.new(1,0,0, desc and 48 or 42)
    container.BackgroundColor3 = Theme.Surface; container.BorderSizePixel = 0
    container.Text = ""; container.AutoButtonColor = false; container.ZIndex = 13
    container.LayoutOrder = order or 0; container.Parent = parent
    local _cc = Instance.new("UICorner"); _cc.CornerRadius = UDim.new(0,8); _cc.Parent = container

    local lbl = Instance.new("TextLabel"); lbl.Text = text; lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 13; lbl.TextColor3 = Theme.Text; lbl.BackgroundTransparency = 1
    lbl.Size = UDim2.new(1,-60,0, desc and 22 or 42); lbl.Position = UDim2.fromOffset(10,4)
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 14; lbl.Parent = container

    if desc and desc ~= "" then
        local dl = Instance.new("TextLabel"); dl.Text = desc; dl.Font = Enum.Font.Gotham
        dl.TextSize = 10; dl.TextColor3 = Theme.TextMuted; dl.BackgroundTransparency = 1
        dl.Size = UDim2.new(1,-60,0,20); dl.Position = UDim2.fromOffset(10,26)
        dl.TextXAlignment = Enum.TextXAlignment.Left; dl.ZIndex = 14; dl.Parent = container
    end

    local pill = Instance.new("Frame"); pill.Size = UDim2.fromOffset(38,20)
    pill.Position = UDim2.new(1,-46,0.5,-10); pill.BackgroundColor3 = val and Theme.Toggle_On or Theme.Toggle_Off
    pill.BorderSizePixel = 0; pill.ZIndex = 15; pill.Parent = container
    local _pc = Instance.new("UICorner"); _pc.CornerRadius = UDim.new(1,0); _pc.Parent = pill

    local knob = Instance.new("Frame"); knob.Size = UDim2.fromOffset(14,14)
    knob.Position = val and UDim2.fromOffset(21,3) or UDim2.fromOffset(3,3)
    knob.BackgroundColor3 = Theme.White; knob.BorderSizePixel = 0; knob.ZIndex = 16; knob.Parent = pill
    local _kc = Instance.new("UICorner"); _kc.CornerRadius = UDim.new(1,0); _kc.Parent = knob

    container.MouseButton1Click:Connect(function()
        val = not val
        Tween(pill, {BackgroundColor3 = val and Theme.Toggle_On or Theme.Toggle_Off}, 0.2)
        Tween(knob, {Position = val and UDim2.fromOffset(21,3) or UDim2.fromOffset(3,3)}, 0.2)
        pcall(callback, val)
    end)
    container.MouseEnter:Connect(function() Tween(container,{BackgroundColor3=Theme.SurfaceAlt},0.15) end)
    container.MouseLeave:Connect(function() Tween(container,{BackgroundColor3=Theme.Surface},0.15) end)
    return container
end

local function MakeButton(parent, text, desc, color, callback, order)
    color = color or Theme.Accent
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,0,0, desc and 48 or 38)
    btn.BackgroundColor3 = Theme.Surface; btn.BorderSizePixel = 0
    btn.Text = ""; btn.AutoButtonColor = false; btn.ZIndex = 13
    btn.LayoutOrder = order or 0; btn.Parent = parent
    local _bc = Instance.new("UICorner"); _bc.CornerRadius = UDim.new(0,8); _bc.Parent = btn

    local bar = Instance.new("Frame"); bar.Size = UDim2.fromOffset(3,22)
    bar.Position = UDim2.new(0,0,0.5,-11); bar.BackgroundColor3 = color
    bar.BorderSizePixel = 0; bar.ZIndex = 14; bar.Parent = btn
    local _barc = Instance.new("UICorner"); _barc.CornerRadius = UDim.new(0,3); _barc.Parent = bar

    local lbl = Instance.new("TextLabel"); lbl.Text = text; lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 13; lbl.TextColor3 = Theme.Text; lbl.BackgroundTransparency = 1
    lbl.Size = UDim2.new(1,-50,1,0); lbl.Position = UDim2.fromOffset(12,0)
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 14; lbl.Parent = btn

    local arrow = Instance.new("TextLabel"); arrow.Text = "›"; arrow.Font = Enum.Font.GothamBold
    arrow.TextSize = 20; arrow.TextColor3 = color; arrow.BackgroundTransparency = 1
    arrow.Size = UDim2.fromOffset(30,38); arrow.Position = UDim2.new(1,-32,0,0)
    arrow.ZIndex = 14; arrow.Parent = btn

    btn.MouseButton1Click:Connect(function()
        Tween(btn,{BackgroundColor3=color},0.1); Tween(lbl,{TextColor3=Theme.White},0.1)
        task.delay(0.18,function()
            Tween(btn,{BackgroundColor3=Theme.Surface},0.2); Tween(lbl,{TextColor3=Theme.Text},0.2)
        end)
        pcall(callback)
    end)
    btn.MouseEnter:Connect(function()
        Tween(btn,{BackgroundColor3=Theme.SurfaceAlt},0.15)
        Tween(arrow,{Position=UDim2.new(1,-26,0,0)},0.15)
    end)
    btn.MouseLeave:Connect(function()
        Tween(btn,{BackgroundColor3=Theme.Surface},0.15)
        Tween(arrow,{Position=UDim2.new(1,-32,0,0)},0.15)
    end)
    return btn
end

local function MakeSlider(parent, text, min, max, default, callback, order)
    local val = default or min; local dragging = false
    local container = Instance.new("Frame"); container.Size = UDim2.new(1,0,0,58)
    container.BackgroundColor3 = Theme.Surface; container.BorderSizePixel = 0
    container.ZIndex = 13; container.LayoutOrder = order or 0; container.Parent = parent
    local _cc = Instance.new("UICorner"); _cc.CornerRadius = UDim.new(0,8); _cc.Parent = container

    local lbl = Instance.new("TextLabel"); lbl.Text = text; lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 13; lbl.TextColor3 = Theme.Text; lbl.BackgroundTransparency = 1
    lbl.Size = UDim2.new(0.7,0,0,28); lbl.Position = UDim2.fromOffset(10,0)
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 14; lbl.Parent = container

    local valL = Instance.new("TextLabel"); valL.Text = tostring(val); valL.Font = Enum.Font.GothamBold
    valL.TextSize = 13; valL.TextColor3 = Theme.Accent; valL.BackgroundTransparency = 1
    valL.Size = UDim2.new(0.28,0,0,28); valL.Position = UDim2.new(0.72,0,0,0)
    valL.TextXAlignment = Enum.TextXAlignment.Right; valL.ZIndex = 14; valL.Parent = container

    local track = Instance.new("Frame"); track.Size = UDim2.new(1,-20,0,6)
    track.Position = UDim2.new(0,10,0,38); track.BackgroundColor3 = Theme.Background
    track.BorderSizePixel = 0; track.ZIndex = 14; track.Parent = container
    local _tc = Instance.new("UICorner"); _tc.CornerRadius = UDim.new(1,0); _tc.Parent = track

    local fill = Instance.new("Frame"); fill.Size = UDim2.new((val-min)/(max-min),0,1,0)
    fill.BackgroundColor3 = Theme.Accent; fill.BorderSizePixel = 0; fill.ZIndex = 15; fill.Parent = track
    local _fc = Instance.new("UICorner"); _fc.CornerRadius = UDim.new(1,0); _fc.Parent = fill

    local thumb = Instance.new("Frame"); thumb.Size = UDim2.fromOffset(14,14)
    thumb.Position = UDim2.new((val-min)/(max-min),-7,0.5,-7)
    thumb.BackgroundColor3 = Theme.White; thumb.BorderSizePixel = 0; thumb.ZIndex = 16; thumb.Parent = track
    local _thc = Instance.new("UICorner"); _thc.CornerRadius = UDim.new(1,0); _thc.Parent = thumb

    local function Update(absX)
        local pct = math.clamp((absX - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        val = math.floor(min + pct*(max-min))
        valL.Text = tostring(val)
        Tween(fill,{Size=UDim2.new(pct,0,1,0)},0.05)
        Tween(thumb,{Position=UDim2.new(pct,-7,0.5,-7)},0.05)
        pcall(callback, val)
    end

    track.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = true; Update(inp.Position.X)
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
            Update(inp.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    return container
end

local function MakeInfoCard(parent, title, val, icon, color)
    color = color or Theme.Accent
    local card = Instance.new("Frame"); card.Size = UDim2.new(1,0,0,58)
    card.BackgroundColor3 = Theme.Surface; card.BorderSizePixel = 0
    card.ZIndex = 13; card.Parent = parent
    local _cc = Instance.new("UICorner"); _cc.CornerRadius = UDim.new(0,10); _cc.Parent = card

    local iconF = Instance.new("Frame"); iconF.Size = UDim2.fromOffset(42,42)
    iconF.Position = UDim2.fromOffset(8,8); iconF.BackgroundColor3 = color
    iconF.BackgroundTransparency = 0.8; iconF.BorderSizePixel = 0; iconF.ZIndex = 14; iconF.Parent = card
    local _ifc = Instance.new("UICorner"); _ifc.CornerRadius = UDim.new(0,10); _ifc.Parent = iconF

    local iconL = Instance.new("TextLabel"); iconL.Text = icon or "?"; iconL.Font = Enum.Font.GothamBold
    iconL.TextSize = 20; iconL.TextColor3 = color; iconL.BackgroundTransparency = 1
    iconL.Size = UDim2.fromScale(1,1); iconL.ZIndex = 15; iconL.Parent = iconF

    local titleL = Instance.new("TextLabel"); titleL.Text = title; titleL.Font = Enum.Font.Gotham
    titleL.TextSize = 11; titleL.TextColor3 = Theme.TextMuted; titleL.BackgroundTransparency = 1
    titleL.Size = UDim2.new(1,-62,0,20); titleL.Position = UDim2.fromOffset(58,8)
    titleL.TextXAlignment = Enum.TextXAlignment.Left; titleL.ZIndex = 14; titleL.Parent = card

    local valL = Instance.new("TextLabel"); valL.Text = val; valL.Font = Enum.Font.GothamBold
    valL.TextSize = 14; valL.TextColor3 = Theme.Text; valL.BackgroundTransparency = 1
    valL.Size = UDim2.new(1,-62,0,24); valL.Position = UDim2.fromOffset(58,28)
    valL.TextXAlignment = Enum.TextXAlignment.Left; valL.ZIndex = 14; valL.Parent = card
    return card, valL
end

-- ════════════════════════════════════════════════════════════════════════
--                           TAB: INFO
-- ════════════════════════════════════════════════════════════════════════
do
    local page = Tabs["Info"].page

    -- Avatar card
    local avatarCard = Instance.new("Frame")
    avatarCard.Size = UDim2.new(1,0,0,120); avatarCard.BackgroundColor3 = Theme.Surface
    avatarCard.BorderSizePixel = 0; avatarCard.LayoutOrder = 1; avatarCard.ZIndex = 13; avatarCard.Parent = page
    local _ac = Instance.new("UICorner"); _ac.CornerRadius = UDim.new(0,12); _ac.Parent = avatarCard
    local _ag = Instance.new("UIGradient")
    _ag.Color =
ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(30,20,60)),ColorSequenceKeypoint.new(1,Color3.fromRGB(15,10,35))})
    _ag.Rotation = 135; _ag.Parent = avatarCard

    local avatarImg = Instance.new("ImageLabel")
    avatarImg.Size = UDim2.fromOffset(90,90); avatarImg.Position = UDim2.fromOffset(14,14)
    avatarImg.BackgroundColor3 = Theme.Background; avatarImg.BorderSizePixel = 0; avatarImg.ZIndex = 14
    avatarImg.Image = "rbxthumb://type=AvatarHeadShot&id="..LocalPlayer.UserId.."&w=150&h=150"
    avatarImg.Parent = avatarCard
    local _aic = Instance.new("UICorner"); _aic.CornerRadius = UDim.new(0,45); _aic.Parent = avatarImg
    local _ais = Instance.new("UIStroke"); _ais.Color = Theme.Accent; _ais.Thickness = 2.5; _ais.Parent = avatarImg

    local function InfoText(txt, size, color, posY, bold)
        local l = Instance.new("TextLabel"); l.Text = txt
        l.Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham
        l.TextSize = size; l.TextColor3 = color; l.BackgroundTransparency = 1
        l.Size = UDim2.new(1,-118,0,size+4); l.Position = UDim2.fromOffset(112,posY)
        l.TextXAlignment = Enum.TextXAlignment.Left; l.ZIndex = 14; l.Parent = avatarCard
        return l
    end

    InfoText(LocalPlayer.DisplayName, 20, Theme.White, 16, true)
    InfoText("@"..LocalPlayer.Name, 13, Theme.Accent, 40, false)
    InfoText("UserID: "..LocalPlayer.UserId, 11, Theme.TextMuted, 58, false)
    local teamName = LocalPlayer.Team and LocalPlayer.Team.Name or "No Team"
    InfoText("Team: "..teamName, 11, Theme.TextMuted, 74, false)
    InfoText("Account Age: "..LocalPlayer.AccountAge.." days", 11, Theme.TextMuted, 90, false)

    MakeSection(page, "GAME INFO", 2)

    local gameCard = Instance.new("Frame")
    gameCard.Size = UDim2.new(1,0,0,80); gameCard.BackgroundColor3 = Theme.Surface
    gameCard.BorderSizePixel = 0; gameCard.LayoutOrder = 3; gameCard.ZIndex = 13; gameCard.Parent = page
    local _gc = Instance.new("UICorner"); _gc.CornerRadius = UDim.new(0,12); _gc.Parent = gameCard

    local gameIco = Instance.new("TextLabel"); gameIco.Text = "🎮"; gameIco.Font = Enum.Font.GothamBold
    gameIco.TextSize = 32; gameIco.BackgroundTransparency = 1; gameIco.Size = UDim2.fromOffset(60,80)
    gameIco.Position = UDim2.fromOffset(10,0); gameIco.ZIndex = 14; gameIco.Parent = gameCard

    local gameNameL = Instance.new("TextLabel"); gameNameL.Text = "Loading..."
    gameNameL.Font = Enum.Font.GothamBold; gameNameL.TextSize = 14; gameNameL.TextColor3 = Theme.Text
    gameNameL.BackgroundTransparency = 1; gameNameL.Size = UDim2.new(1,-80,0,24)
    gameNameL.Position = UDim2.fromOffset(70,14); gameNameL.TextXAlignment = Enum.TextXAlignment.Left
    gameNameL.ZIndex = 14; gameNameL.Parent = gameCard

    local gameIdL = Instance.new("TextLabel"); gameIdL.Text = "Place ID: "..game.PlaceId
    gameIdL.Font = Enum.Font.Gotham; gameIdL.TextSize = 11; gameIdL.TextColor3 = Theme.TextMuted
    gameIdL.BackgroundTransparency = 1; gameIdL.Size = UDim2.new(1,-80,0,18)
    gameIdL.Position = UDim2.fromOffset(70,36); gameIdL.TextXAlignment = Enum.TextXAlignment.Left
    gameIdL.ZIndex = 14; gameIdL.Parent = gameCard

    local jobTxt = game.JobId ~= "" and game.JobId:sub(1,20).."..." or "Solo / Studio"
    local jobIdL = Instance.new("TextLabel"); jobIdL.Text = "Server: "..jobTxt
    jobIdL.Font = Enum.Font.Gotham; jobIdL.TextSize = 10; jobIdL.TextColor3 = Theme.TextMuted
    jobIdL.BackgroundTransparency = 1; jobIdL.Size = UDim2.new(1,-80,0,16)
    jobIdL.Position = UDim2.fromOffset(70,54); jobIdL.TextXAlignment = Enum.TextXAlignment.Left
    jobIdL.ZIndex = 14; jobIdL.Parent = gameCard

    pcall(function()
        local info = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
        gameNameL.Text = info.Name or "Unknown Game"
    end)

    MakeSection(page, "LIVE STATS", 4)

    local statsGrid = Instance.new("Frame")
    statsGrid.Size = UDim2.new(1,0,0,0); statsGrid.BackgroundTransparency = 1
    statsGrid.AutomaticSize = Enum.AutomaticSize.Y; statsGrid.LayoutOrder = 5
    statsGrid.ZIndex = 13; statsGrid.Parent = page
    local _sgl = Instance.new("UIGridLayout")
    _sgl.CellSize = UDim2.new(0.48,-4,0,62); _sgl.CellPadding = UDim2.fromOffset(8,8); _sgl.Parent = statsGrid

    local _, pingL  = MakeInfoCard(statsGrid, "Ping",    "-- ms",  "📶", Theme.AccentAlt)
    local _, fpsL   = MakeInfoCard(statsGrid, "FPS",     "-- fps", "⚡",  Theme.Success)
    local _, playL  = MakeInfoCard(statsGrid, "Players", "--",     "👥", Theme.Warning)
    local _, wsL    = MakeInfoCard(statsGrid, "Speed",   "16",     "🏃", Theme.Accent)

    local ltime, frames = tick(), 0
    RunService.RenderStepped:Connect(function()
        frames += 1
        local now = tick()
        if now - ltime >= 1 then
            fpsL.Text  = math.floor(frames/(now-ltime)).." fps"
            frames     = 0; ltime = now
            pingL.Text = math.floor(LocalPlayer:GetNetworkPing()*1000).." ms"
            playL.Text = tostring(#Players:GetPlayers())
            pcall(function() wsL.Text = tostring(math.floor(Humanoid.WalkSpeed)) end)
        end
    end)

    MakeSection(page, "DEVICE", 6)
    local devCard = Instance.new("Frame")
    devCard.Size = UDim2.new(1,0,0,52); devCard.BackgroundColor3 = Theme.Surface
    devCard.BorderSizePixel = 0; devCard.LayoutOrder = 7; devCard.ZIndex = 13; devCard.Parent = page
    local _dc = Instance.new("UICorner"); _dc.CornerRadius = UDim.new(0,10); _dc.Parent = devCard
    local devT = Instance.new("TextLabel")
    local dtype = mobile and "📱 Mobile" or (tablet and "📟 Tablet" or "🖥️ PC / Desktop")
    devT.Text = dtype.."   •   "..math.floor(vp.X).."×"..math.floor(vp.Y).."   •   Roblox v"..tostring(version())
    devT.Font = Enum.Font.GothamSemibold; devT.TextSize = 12; devT.TextColor3 = Theme.Text
    devT.BackgroundTransparency = 1; devT.Size = UDim2.new(1,-20,1,0)
    devT.Position = UDim2.fromOffset(10,0); devT.TextXAlignment = Enum.TextXAlignment.Left
    devT.ZIndex = 14; devT.Parent = devCard
end

-- ════════════════════════════════════════════════════════════════════════
--                           TAB: PLAYER
-- ════════════════════════════════════════════════════════════════════════
do
    local page = Tabs["Player"].page
    MakeSection(page, "MOVEMENT", 1)

    -- 1. WalkSpeed slider
    MakeSlider(page, "Walk Speed", 0, 500, 16, function(v)
        Config.WalkSpeed = v; pcall(function() Humanoid.WalkSpeed = v end)
    end, 2)

    -- 2. JumpPower slider
    MakeSlider(page, "Jump Power", 0, 500, 50, function(v)
        Config.JumpPower = v
        pcall(function() Humanoid.JumpPower = v; Humanoid.UseJumpPower = true end)
    end, 3)

    -- 3. Infinite Jump
    MakeToggle(page, "Infinite Jump", "Jump while in mid-air", false, function(v) Config.Infinite_Jump = v end, 4)

    -- 4. Fly
    MakeToggle(page, "Fly Mode", "Free-fly with WASD / camera direction", false, function(val)
        Config.Fly_Active = val
        if val then
            local bv = Instance.new("BodyVelocity"); bv.Velocity = Vector3.zero
            bv.MaxForce = Vector3.new(1e5,1e5,1e5); bv.Name = "MinitFlyBV"; bv.Parent = HumanoidRootPart
            local bg = Instance.new("BodyGyro"); bg.MaxTorque = Vector3.new(1e5,1e5,1e5)
            bg.Name = "MinitFlyBG"; bg.Parent = HumanoidRootPart
            local conn; conn = RunService.RenderStepped:Connect(function()
                if not Config.Fly_Active then
                    pcall(function() HumanoidRootPart.MinitFlyBV:Destroy() end)
                    pcall(function() HumanoidRootPart.MinitFlyBG:Destroy() end)
                    conn:Disconnect(); return
                end
                local dir = Vector3.zero; local spd = 40
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= Camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += Camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space)    then dir += Vector3.new(0,1,0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.new(0,1,0) end
                if dir.Magnitude > 0 then dir = dir.Unit end
                local bvI = HumanoidRootPart:FindFirstChild("MinitFlyBV")
                local bgI = HumanoidRootPart:FindFirstChild("MinitFlyBG")
                if bvI then bvI.Velocity = dir * spd end
                if bgI then bgI.CFrame   = Camera.CFrame end
            end)
        end
    end, 5)

    MakeSection(page, "CHARACTER", 6)

    -- 5. Noclip
    MakeToggle(page, "Noclip", "Phase through all parts", false, function(val)
        Config.Noclip = val
        if val then
            RunService.Stepped:Connect(function()
                if not Config.Noclip then return end
                for _, p in ipairs(Character:GetDescendants()) do
                    if p:IsA("BasePart") and p ~= HumanoidRootPart then p.CanCollide = false end
                end
            end)
        end
    end, 7)

    -- 6. God Mode
    MakeToggle(page, "God Mode", "Infinite health, no death", false, function(val)
        Config.GodMode = val
        if val then
            Humanoid.MaxHealth = math.huge; Humanoid.Health = math.huge
            Humanoid.HealthChanged:Connect(function() if Config.GodMode then Humanoid.Health = math.huge end end)
        end
    end, 8)

    -- 7. Auto Respawn
    MakeToggle(page, "Auto Respawn", "Auto-reload on death", false, function(val)
        Config.AutoRespawn = val
        if val then
            Humanoid.Died:Connect(function()
                if Config.AutoRespawn then task.wait(0.5); LocalPlayer:LoadCharacter() end
            end)
        end
    end, 9)

    -- 8. Invisible
    MakeToggle(page, "Invisible (Client-Side)", "Hide your character", false, function(val)
        for _, p in ipairs(Character:GetDescendants()) do
            if p:IsA("BasePart") or p:IsA("Decal") then p.Transparency = val and 1 or 0 end
        end
        Character.HumanoidRootPart.Transparency = 1
    end, 10)

    MakeSection(page, "SPEED PRESETS", 11)
    local presets = {{"Normal (16)",16},{"Fast (50)",50},{"Turbo (100)",100},{"Ultra (250)",250}}
    for i, p in ipairs(presets) do
        MakeButton(page, p[1], nil, Theme.AccentAlt, function()
            pcall(function() Humanoid.WalkSpeed = p[2] end)
        end, 11+i)
    end

    -- 9. Zoom unlock
    MakeButton(page, "Unlock Max Zoom (500)", nil, Theme.AccentAlt, function()
        LocalPlayer.CameraMaxZoomDistance = 500
        SafeNotify("Minit HUB","Max zoom set to 500 ✓")
    end, 16)

    -- 10. Sit toggle
    MakeButton(page, "Toggle Sit", nil, Theme.Accent, function()
        Humanoid.Sit = not Humanoid.Sit
    end, 17)

    -- 11. Reset
    MakeButton(page, "Reset Character", nil, Theme.Danger, function()
        Humanoid.Health = 0
    end, 18)

    -- 12. Teleport to spawn
    MakeButton(page, "Teleport to Spawn", nil, Theme.Success, function()
        local s = workspace:FindFirstChildOfClass("SpawnLocation")
        if s then HumanoidRootPart.CFrame = s.CFrame + Vector3.new(0,5,0) end
    end, 19)
end

-- ════════════════════════════════════════════════════════════════════════
--                           TAB: COMBAT
-- ════════════════════════════════════════════════════════════════════════
do
    local page = Tabs["Combat"].page
    local kaRange, kaActive = 20, false

    MakeSection(page, "KILL AURA", 1)

    -- 13. Kill Aura
    MakeToggle(page, "Kill Aura", "Damage all nearby players continuously", false, function(val)
        kaActive = val
        if val then task.spawn(function()
            while kaActive do
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character then
                        local h   = p.Character:FindFirstChildOfClass("Humanoid")
                        local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                        if h and hrp and (hrp.Position-HumanoidRootPart.Position).Magnitude <= kaRange then
                            h:TakeDamage(10)
                        end
                    end
                end
                task.wait(0.1)
            end
        end) end
    end, 2)

    -- 14. Kill Aura Range
    MakeSlider(page, "Kill Aura Range", 5, 100, 20, function(v) kaRange = v end, 3)

    MakeSection(page, "TARGETING", 4)

    -- 15. Aimbot
    MakeToggle(page, "Soft Aimbot", "Lock camera onto nearest player head", false, function(val)
        if val then
            local conn; conn = RunService.RenderStepped:Connect(function()
                if not val then conn:Disconnect(); return end
                local nearest, dist = nil, math.huge
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character then
                        local head = p.Character:FindFirstChild("Head")
                        if head then
                            local d = (head.Position-HumanoidRootPart.Position).Magnitude
                            if d < dist then dist = d; nearest = head end
                        end
                    end
                end
                if nearest then Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, nearest.Position) end
            end)
        end
    end, 5)

    -- 16. Anti-KB
    MakeToggle(page, "Anti-Knockback", "Nullify incoming velocity forces", false, function(val)
        if val then local conn; conn = RunService.Heartbeat:Connect(function()
            if not val then conn:Disconnect(); return end
            for _, v in ipairs(HumanoidRootPart:GetChildren()) do
                if v:IsA("BodyVelocity") or v:IsA("BodyForce") then v.Velocity = Vector3.zero end
            end
        end) end
    end, 6)

    -- 17. Anti-Ragdoll
    MakeToggle(page, "Anti-Ragdoll", "Disable ragdoll constraints", false, function(val)
        for _, v in ipairs(Character:GetDescendants()) do
            if v:IsA("BallSocketConstraint") or v:IsA("HingeConstraint") then v.Enabled = not val end
        end
    end, 7)

    MakeSection(page, "ONE-SHOT TOOLS", 8)

    -- 18. Fling Nearest
    MakeButton(page, "Fling Nearest Player", nil, Theme.Danger, function()
        local nearest, dist = nil, math.huge
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if hrp then local d = (hrp.Position-HumanoidRootPart.Position).Magnitude
                    if d < dist then dist = d; nearest = hrp end end
            end
        end
        if nearest then
            local vel = Instance.new("BodyVelocity")
            vel.Velocity = Vector3.new(math.random(-100,100), 250, math.random(-100,100))
            vel.MaxForce = Vector3.new(1e6,1e6,1e6); vel.Parent = nearest
            game:GetService("Debris"):AddItem(vel, 0.2)
        end
    end, 9)

    -- 19. Damage all
    MakeButton(page, "Damage All (10 HP)", nil, Theme.Danger, function()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local h = p.Character:FindFirstChildOfClass("Humanoid")
                if h then h:TakeDamage(10) end
            end
        end
    end, 10)

    -- 20. Hitbox expander
    MakeButton(page, "Expand All Hitboxes", nil, Theme.Warning, function()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                for _, part in ipairs(p.Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.Size = part.Size * 10 end
                end
            end
        end
        SafeNotify("Minit HUB","Hitboxes expanded ✓")
    end, 11)

    -- 21. Speed burst
    MakeToggle(page, "Speed Burst on Jump", "Boost speed temporarily each jump", false, function(val)
        if val then Humanoid.Jumping:Connect(function(active)
            if active and val then
                local prev = Humanoid.WalkSpeed; Humanoid.WalkSpeed = 80
                task.delay(0.5, function() Humanoid.WalkSpeed = prev end)
            end
        end) end
    end, 12)
end

-- ════════════════════════════════════════════════════════════════════════
--                           TAB: WORLD
-- ════════════════════════════════════════════════════════════════════════
do
    local page = Tabs["World"].page
    MakeSection(page, "ENVIRONMENT", 1)

    -- 22. Fullbright
    MakeToggle(page, "Full Bright", "Max brightness + remove effects", false, function(val)
        Lighting.Brightness = val and 2 or 1
        if val then
            for _, v in ipairs(Lighting:GetChildren()) do
                if v:IsA("FogEffect") or v:IsA("BlurEffect") then v.Enabled = false end
            end
        end
    end, 2)

    -- 23. No Fog
    MakeToggle(page, "Remove Fog", "Eliminate atmospheric fog", false, function(val)
        Lighting.FogEnd   = val and 1e6 or 1000
        Lighting.FogStart = val and 1e6 or 0
    end, 3)

    -- 24. Time of Day
    MakeSlider(page, "Time of Day (0–24)", 0, 24, 14, function(v) Lighting.ClockTime = v end, 4)

    -- 25. Night mode
    MakeButton(page, "Night Mode", nil, Theme.AccentAlt, function()
        Lighting.Ambient = Color3.fromRGB(10,10,20); Lighting.OutdoorAmbient = Color3.fromRGB(20,20,40)
        Lighting.ClockTime = 0; Lighting.Brightness = 0.2
    end, 5)

    -- 26. Day mode
    MakeButton(page, "Day Mode", nil, Theme.Warning, function()
        Lighting.Ambient = Color3.fromRGB(128,128,128); Lighting.OutdoorAmbient = Color3.fromRGB(128,128,128)
        Lighting.ClockTime = 14; Lighting.Brightness = 1
    end, 6)

    MakeSection(page, "WORLD TOOLS", 7)

    -- 27. Gravity slider
    MakeSlider(page, "Gravity", 0, 200, 196, function(v) workspace.Gravity = v end, 8)

    -- 28. Zero gravity
    MakeButton(page, "Zero Gravity", nil, Theme.Accent, function()
        workspace.Gravity = 0; SafeNotify("Minit HUB","Gravity = 0 ✓")
    end, 9)

    -- 29. Flood
    MakeButton(page, "Flood World", nil, Theme.AccentAlt, function()
        workspace.Terrain:FillBlock(CFrame.new(0,-20,0), Vector3.new(2048,40,2048), Enum.Material.Water)
        SafeNotify("Minit HUB","World flooded ✓")
    end, 10)

    -- 30. Flatten terrain
    MakeButton(page, "Flatten Terrain", nil, Theme.Success, function()
        workspace.Terrain:FillBlock(CFrame.new(0,-6,0), Vector3.new(2048,10,2048), Enum.Material.Grass)
        SafeNotify("Minit HUB","Terrain flattened ✓")
    end, 11)

    -- 31. Delete parts
    MakeButton(page, "Delete All Loose Parts", nil, Theme.Danger, function()
        for _, v in ipairs(workspace:GetChildren()) do
            if v:IsA("BasePart") then v:Destroy() end
        end
        SafeNotify("Minit HUB","World cleared ✓")
    end, 12)

    -- 32. Blackhole
    MakeButton(page, "Black Hole", nil, Theme.Danger, function()
        task.spawn(function()
            for i = 1, 80 do
                for _, v in ipairs(workspace:GetDescendants()) do
                    if v:IsA("BasePart") and not v:IsAncestorOf(Character) then
                        v.Velocity = (HumanoidRootPart.Position - v.Position).Unit * 80
                    end
                end
                task.wait(0.05)
            end
        end)
    end, 13)
end

-- ════════════════════════════════════════════════════════════════════════
--                           TAB: ESP
-- ════════════════════════════════════════════════════════════════════════
do
    local page = Tabs["ESP"].page
    local espBoxes, espNames = {}, {}
    local espEnabled, espNamesEnabled = false, false

    local function ClearESP()
        for _, v in pairs(espBoxes) do pcall(v.Destroy, v) end
        for _, v in pairs(espNames) do pcall(v.Destroy, v) end
        espBoxes, espNames = {}, {}
    end

    local function BuildESP()
        ClearESP(); if not espEnabled then return end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local hrp  = p.Character:FindFirstChild("HumanoidRootPart")
                local head = p.Character:FindFirstChild("Head")
                if hrp then
                    local box = Instance.new("BoxHandleAdornment")
                    box.Adornee = hrp; box.AlwaysOnTop = true
                    box.Color3 = Color3.fromRGB(255,80,80); box.Size = hrp.Size + Vector3.new(0.5,3.5,0.5)
                    box.Transparency = 0.6; box.ZIndex = 5; box.Parent = hrp
                    espBoxes[p.Name] = box
                end
                if espNamesEnabled and head then
                    local bb = Instance.new("BillboardGui"); bb.Adornee = head
                    bb.Size = UDim2.fromOffset(200,30); bb.StudsOffset = Vector3.new(0,2.5,0)
                    bb.AlwaysOnTop = true; bb.Parent = head
                    local tl = Instance.new("TextLabel", bb)
                    tl.Text = p.DisplayName; tl.Font = Enum.Font.GothamBold; tl.TextSize = 14
                    tl.TextColor3 = Color3.new(1,1,1); tl.BackgroundTransparency = 1
                    tl.Size = UDim2.fromScale(1,1)
                    espNames[p.Name] = bb
                end
            end
        end
    end

    MakeSection(page, "ESP SETTINGS", 1)

    -- 33. Box ESP
    MakeToggle(page, "Player ESP (Boxes)", "Red box outlines on all players", false, function(val)
        espEnabled = val; BuildESP()
        if val then task.spawn(function()
            while espEnabled do
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and not espBoxes[p.Name] and p.Character then BuildESP() end
                end
                task.wait(2)
            end
        end) end
    end, 2)

    -- 34. Name tags
    MakeToggle(page, "Name Tags", "Billboard names above players", false, function(val)
        espNamesEnabled = val; BuildESP()
    end, 3)

    -- 35. Health color ESP
    MakeToggle(page, "Health-Color ESP", "Box color = HP percentage", false, function(val)
        if val then task.spawn(function()
            while val do
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character then
                        local h   = p.Character:FindFirstChildOfClass("Humanoid")
                        local box = espBoxes[p.Name]
                        if h and box then
                            local pct = h.Health / math.max(h.MaxHealth, 1)
                            box.Color3 = Color3.fromRGB(math.floor(255*(1-pct)), math.floor(255*pct), 0)
                        end
                    end
                end
                task.wait(0.2)
            end
        end) end
    end, 4)

    MakeSection(page, "WORLD ESP", 5)

    -- 36. Highlight parts
    MakeButton(page, "Highlight All Parts", nil, Theme.Warning, function()
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and not v:IsAncestorOf(Character) then
                local sel = Instance.new("SelectionBox"); sel.Adornee = v
                sel.Color3 = Color3.fromRGB(0,200,255); sel.LineThickness = 0.03
                sel.SurfaceTransparency = 0.8; sel.SurfaceColor3 = Color3.fromRGB(0,200,255)
                sel.Parent = workspace; game:GetService("Debris"):AddItem(sel, 10)
            end
        end
        SafeNotify("Minit HUB","Part ESP active (10s) ✓")
    end, 6)

    -- 37. Team chams
    MakeButton(page, "Team Chams (Green)", nil, Theme.Success, function()
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Team == LocalPlayer.Team and p ~= LocalPlayer and p.Character then
                local hl = Instance.new("Highlight"); hl.Adornee = p.Character
                hl.FillColor = Color3.fromRGB(0,255,100); hl.FillTransparency = 0.5
                hl.OutlineColor = Color3.fromRGB(0,255,100); hl.Parent = p.Character
                game:GetService("Debris"):AddItem(hl, 30)
            end
        end
    end, 7)

    -- 38. Enemy chams
    MakeButton(page, "Enemy Chams (Red)", nil, Theme.Danger, function()
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Team ~= LocalPlayer.Team and p ~= LocalPlayer and p.Character then
                local hl = Instance.new("Highlight"); hl.Adornee = p.Character
                hl.FillColor = Color3.fromRGB(255,50,50); hl.FillTransparency = 0.5
                hl.OutlineColor = Color3.fromRGB(255,50,50); hl.Parent = p.Character
                game:GetService("Debris"):AddItem(hl, 30)
            end
        end
    end, 8)

    -- 39. Clear all
    MakeButton(page, "Clear All ESP", nil, Theme.TextDim, function()
        ClearESP()
        for _, v in ipairs(game:GetDescendants()) do
            if v:IsA("Highlight") or v:IsA("SelectionBox") or v:IsA("BoxHandleAdornment") or v:IsA("BillboardGui") then
                v:Destroy()
            end
        end
        SafeNotify("Minit HUB","ESP cleared ✓")
    end, 9)
end

-- ════════════════════════════════════════════════════════════════════════
--                           TAB: TROLL
-- ════════════════════════════════════════════════════════════════════════
do
    local page = Tabs["Troll"].page
    local chatMsg = "Minit HUB is the best!"

    MakeSection(page, "CHAT", 1)

    -- Chat message input (manual frame)
    local inputFrame = Instance.new("Frame"); inputFrame.Size = UDim2.new(1,0,0,40)
    inputFrame.BackgroundColor3 = Theme.Surface; inputFrame.BorderSizePixel = 0
    inputFrame.ZIndex = 13; inputFrame.LayoutOrder = 2; inputFrame.Parent = page
    local _ifc = Instance.new("UICorner"); _ifc.CornerRadius = UDim.new(0,8); _ifc.Parent = inputFrame
    local chatBox = Instance.new("TextBox"); chatBox.PlaceholderText = "Enter spam message..."
    chatBox.PlaceholderColor3 = Theme.TextMuted; chatBox.Text = chatMsg
    chatBox.Font = Enum.Font.Gotham; chatBox.TextSize = 13; chatBox.TextColor3 = Theme.Text
    chatBox.BackgroundTransparency = 1; chatBox.Size = UDim2.new(1,-20,1,0)
    chatBox.Position = UDim2.fromOffset(10,0); chatBox.TextXAlignment = Enum.TextXAlignment.Left
    chatBox.ClearTextOnFocus = false; chatBox.ZIndex = 14; chatBox.Parent = inputFrame
    chatBox.FocusLost:Connect(function() chatMsg = chatBox.Text end)

    -- 40. Chat Spam
    local chatSpamActive = false
    MakeToggle(page, "Chat Spam", "Repeatedly send your message", false, function(val)
        chatSpamActive = val
        if val then task.spawn(function()
            while chatSpamActive do
                pcall(function() game:GetService("Chat"):Chat(LocalPlayer.Character.Head, chatMsg) end)
                task.wait(1)
            end
        end) end
    end, 3)

    -- 41. Shout once
    MakeButton(page, "Send Message Once", nil, Color3.fromRGB(200,100,255), function()
        pcall(function() game:GetService("Chat"):Chat(LocalPlayer.Character.Head, chatMsg) end)
    end, 4)

    MakeSection(page, "PLAYER TROLLING", 5)

    -- 42. Follow nearest
    local followActive = false
    MakeToggle(page, "Follow Nearest Player", "Chase the closest player", false, function(val)
        followActive = val
        if val then task.spawn(function()
            while followActive do
                local nearest, dist = nil, math.huge
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character then
                        local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then local d = (hrp.Position-HumanoidRootPart.Position).Magnitude
                            if d < dist then dist = d; nearest = hrp end end
                    end
                end
                if nearest then Humanoid:MoveTo(nearest.Position) end
                task.wait(0.1)
            end
        end) end
    end, 6)

    -- 43. Orbit nearest
    local orbitActive = false
    MakeToggle(page, "Orbit Nearest Player", "Circle around a player", false, function(val)
        orbitActive = val
        if val then task.spawn(function()
            local angle = 0
            while orbitActive do
                angle += 0.05
                local nearest, dist = nil, math.huge
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character then
                        local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then local d = (hrp.Position-HumanoidRootPart.Position).Magnitude
                            if d < dist then dist = d; nearest = hrp end end
                    end
                end
                if nearest then
                    HumanoidRootPart.CFrame = CFrame.new(nearest.Position + Vector3.new(math.cos(angle)*8,0,math.sin(angle)*8))
                end
                task.wait(0.03)
            end
        end) end
    end, 7)

    -- 44. Blast off
    MakeButton(page, "Blast Off (Self)", nil, Color3.fromRGB(200,100,255), function()
        local vel = Instance.new("BodyVelocity"); vel.Velocity = Vector3.new(0,500,0)
        vel.MaxForce = Vector3.new(0,1e6,0); vel.Parent = HumanoidRootPart
        game:GetService("Debris"):AddItem(vel, 0.3)
    end, 8)

    -- 45. Annoy nearest
    MakeButton(page, "Annoy Nearest", nil, Color3.fromRGB(200,100,255), function()
        local nearest, dist = nil, math.huge
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if hrp then local d = (hrp.Position-HumanoidRootPart.Position).Magnitude
                    if d < dist then dist = d; nearest = hrp end end
            end
        end
        if nearest then
            HumanoidRootPart.CFrame = CFrame.new(nearest.Position + Vector3.new(0,2,0))
            task.spawn(function()
                for i = 1, 10 do Humanoid.Jump = true; task.wait(0.15) end
            end)
        end
    end, 9)

    -- 46. Sound spam
    MakeButton(page, "Play Random Sound", nil, Color3.fromRGB(200,100,255), function()
        local sounds = {6518811702, 4613071542, 1843671842, 447041359, 130776675}
        local s = Instance.new("Sound"); s.SoundId = "rbxassetid://"..sounds[math.random(1,#sounds)]
        s.Volume = 0.5; s.Parent = workspace; s:Play()
        game:GetService("Debris"):AddItem(s, 15)
    end, 10)

    MakeSection(page, "SIZE TROLL", 11)

    -- 47. Giant mode
    MakeToggle(page, "Giant Mode (5x)", "Scale character to 5× size", false, function(val)
        local h = Character:FindFirstChildOfClass("Humanoid")
        if h then
            h.BodyDepthScale.Value  = val and 5 or 1
            h.BodyHeightScale.Value = val and 5 or 1
            h.BodyWidthScale.Value  = val and 5 or 1
            h.HeadScale.Value       = val and 5 or 1
        end
    end, 12)

    -- 48. Tiny mode
    MakeToggle(page, "Tiny Mode (0.3x)", "Scale character to 0.3× size", false, function(val)
        local h = Character:FindFirstChildOfClass("Humanoid")
        if h then
            h.BodyDepthScale.Value  = val and 0.3 or 1
            h.BodyHeightScale.Value = val and 0.3 or 1
            h.BodyWidthScale.Value  = val and 0.3 or 1
            h.HeadScale.Value       = val and 0.3 or 1
        end
    end, 13)
end

-- ════════════════════════════════════════════════════════════════════════
--                           TAB: VISUAL
-- ════════════════════════════════════════════════════════════════════════
do
    local page = Tabs["Visual"].page
    MakeSection(page, "CAMERA EFFECTS", 1)

    -- 49. FOV
    MakeSlider(page, "Camera FOV", 40, 120, 70, function(v) Camera.FieldOfView = v end, 2)

    -- 50. Cinematic bars
    MakeToggle(page, "Cinematic Bars", "Add letterbox effect", false, function(val)
        local existing = ScreenGui:FindFirstChild("CinematicBars")
        if val then
            if existing then existing:Destroy() end
            local bars = Instance.new("Frame", ScreenGui); bars.Name = "CinematicBars"
            bars.Size = UDim2.fromScale(1,1); bars.BackgroundTransparency = 1
            local top = Instance.new("Frame", bars); top.Size = UDim2.new(1,0,0,0)
            top.BackgroundColor3 = Color3.new(0,0,0); top.BorderSizePixel = 0; top.ZIndex = 50
            Tween(top, {Size=UDim2.new(1,0,0,80)}, 0.5)
            local bot = Instance.new("Frame", bars); bot.Size = UDim2.new(1,0,0,0)
            bot.Position = UDim2.new(0,0,1,0); bot.BackgroundColor3 = Color3.new(0,0,0)
            bot.BorderSizePixel = 0; bot.ZIndex = 50
            Tween(bot, {Size=UDim2.new(1,0,0,80), Position=UDim2.new(0,0,1,-80)}, 0.5)
        else
            if existing then existing:Destroy() end
        end
    end, 3)

    -- 51. Blur
    MakeSlider(page, "Blur Intensity", 0, 56, 0, function(v)
        local blur = Lighting:FindFirstChildOfClass("BlurEffect") or Instance.new("BlurEffect", Lighting)
        blur.Size = v
    end, 4)

    -- 52. Bloom
    MakeSlider(page, "Bloom Intensity", 0, 5, 0, function(v)
        local bloom = Lighting:FindFirstChildOfClass("BloomEffect") or Instance.new("BloomEffect", Lighting)
        bloom.Intensity = v; bloom.Threshold = 0.8; bloom.Size = 24
    end, 5)

    MakeSection(page, "CHARACTER FX", 6)

    -- 53. Rainbow character
    MakeToggle(page, "Rainbow Character", "Cycle HSV hue on your character", false, function(val)
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

    -- 54. Neon parts
    MakeToggle(page, "Neon Parts", "Set all parts to Neon material", false, function(val)
        for _, p in ipairs(Character:GetDescendants()) do
            if p:IsA("BasePart") then
                p.Material = val and Enum.Material.Neon or Enum.Material.SmoothPlastic
            end
        end
    end, 8)

    -- 55. Trail
    MakeToggle(page, "Speed Trail", "Motion trail behind character", false, function(val)
        local trail = HumanoidRootPart:FindFirstChild("MinitTrail")
        if val then
            if trail then trail:Destroy() end
            local a0 = Instance.new("Attachment", HumanoidRootPart); a0.Position = Vector3.new(0,1,0)
            local a1 = Instance.new("Attachment", HumanoidRootPart); a1.Position = Vector3.new(0,-1,0)
            local t  = Instance.new("Trail"); t.Name = "MinitTrail"; t.Attachment0 = a0; t.Attachment1 = a1
            t.Lifetime = 0.5
            t.Color = ColorSequence.new({ColorSequenceKeypoint.new(0,Theme.Accent),ColorSequenceKeypoint.new(1,Theme.AccentAlt)})
            t.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,1)})
            t.Parent = HumanoidRootPart
        else
            if trail then trail:Destroy() end
        end
    end, 9)

    -- 56. Force field
    MakeToggle(page, "Force Field Effect", "Visual shield around character", false, function(val)
        local ff = Character:FindFirstChildOfClass("ForceField")
        if val and not ff then Instance.new("ForceField", Character).Visible = true
        elseif not val and ff then ff:Destroy() end
    end, 10)

    -- 57. Sparkle
    MakeButton(page, "Add Sparkle Particles", nil, Color3.fromRGB(255,180,80), function()
        for _, p in ipairs(Character:GetDescendants()) do
            if p:IsA("BasePart") then
                local pe = Instance.new("ParticleEmitter"); pe.Rate = 20
                pe.Lifetime = NumberRange.new(0.5,1.5); pe.Speed = NumberRange.new(1,4)
                pe.Color =
ColorSequence.new({ColorSequenceKeypoint.new(0,Theme.AccentGlow),ColorSequenceKeypoint.new(1,Theme.AccentAlt)})
                pe.Size = NumberSequence.new({NumberSequenceKeypoint.new(0,0.1),NumberSequenceKeypoint.new(1,0)})
                pe.Parent = p; game:GetService("Debris"):AddItem(pe, 8); break
            end
        end
    end, 11)

    -- 58. Clock overlay
    MakeToggle(page, "Clock Overlay", "Real-time clock on screen", false, function(val)
        local clk = ScreenGui:FindFirstChild("MinitClock")
        if val then
            if clk then clk:Destroy() end
            local frame = Instance.new("Frame", ScreenGui); frame.Name = "MinitClock"
            frame.Size = UDim2.fromOffset(160,34); frame.Position = UDim2.new(1,-170,0,10)
            frame.BackgroundColor3 = Theme.Surface; frame.BackgroundTransparency = 0.3
            frame.BorderSizePixel = 0; frame.ZIndex = 200
            local _fc = Instance.new("UICorner"); _fc.CornerRadius = UDim.new(0,8); _fc.Parent = frame
            local tl = Instance.new("TextLabel", frame); tl.Font = Enum.Font.GothamBold
            tl.TextSize = 15; tl.TextColor3 = Theme.Accent; tl.BackgroundTransparency = 1
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

-- ════════════════════════════════════════════════════════════════════════
--                           TAB: MISC
-- ════════════════════════════════════════════════════════════════════════
do
    local page = Tabs["Misc"].page
    MakeSection(page, "ANTI-AFK & AUTO", 1)

    -- 59. Anti-AFK
    MakeToggle(page, "Anti-AFK", "Prevent automatic kick", false, function(val)
        Config.AntiAFK = val
        if val then local conn; conn = RunService.Heartbeat:Connect(function()
            if not Config.AntiAFK then conn:Disconnect(); return end
            VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new())
        end) end
    end, 2)

    -- 60. Auto Click
    local autoClickActive = false
    MakeToggle(page, "Auto Click", "Rapidly click mouse left button", false, function(val)
        autoClickActive = val
        if val then task.spawn(function()
            while autoClickActive do
                pcall(function() mouse1click() end)
                task.wait(0.05)
            end
        end) end
    end, 3)

    MakeSection(page, "PLAYER TOOLS", 4)

    -- 61. Copy position
    MakeButton(page, "Print My Position", nil, Theme.AccentAlt, function()
        print("[Minit HUB] CFrame: "..tostring(HumanoidRootPart.CFrame))
        SafeNotify("Minit HUB","Position printed ✓")
    end, 5)

    -- 62. Teleport to random
    MakeButton(page, "Teleport to Random Player", nil, Theme.Accent, function()
        local others = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                table.insert(others, p)
            end
        end
        if #others > 0 then
            local t = others[math.random(1,#others)]
            HumanoidRootPart.CFrame = t.Character.HumanoidRootPart.CFrame + Vector3.new(0,5,0)
            SafeNotify("Minit HUB","Teleported to "..t.Name)
        else
            SafeNotify("Minit HUB","No other players found!")
        end
    end, 6)

    -- 63. Server hop
    MakeButton(page, "Server Hop", nil, Theme.Warning, function()
        SafeNotify("Minit HUB","Searching for new server...")
        local ok, servers = pcall(function()
            return
HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=25"))
        end)
        if ok and servers and servers.data then
            for _, s in ipairs(servers.data) do
                if s.id ~= game.JobId and s.playing < s.maxPlayers then
                    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
                    return
                end
            end
        end
        SafeNotify("Minit HUB","No suitable server found.")
    end, 7)

    -- 64. Rejoin
    MakeButton(page, "Rejoin Server", nil, Theme.Danger, function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end, 8)

    MakeSection(page, "SCRIPTS & INFO", 9)

    -- 65. Print remotes
    MakeButton(page, "Print All Remotes", nil, Theme.TextDim, function()
        for _, v in ipairs(game:GetDescendants()) do
            if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then print("[Minit HUB] Remote: "..v:GetFullName()) end
        end
        SafeNotify("Minit HUB","Remotes printed ✓")
    end, 10)

    -- 66. Workspace tree
    MakeButton(page, "Print Workspace Tree", nil, Theme.TextDim, function()
        local function pt(i, d)
            print(string.rep("  ",d)..i.Name.." ["..i.ClassName.."]")
            for _, c in ipairs(i:GetChildren()) do pt(c, d+1) end
        end
        pt(workspace, 0)
        SafeNotify("Minit HUB","Tree printed ✓")
    end, 11)

    -- 67. Copy player list
    MakeButton(page, "Copy Player List", nil, Theme.AccentAlt, function()
        local names = {}
        for _, p in ipairs(Players:GetPlayers()) do table.insert(names, p.Name) end
        pcall(function() setclipboard(table.concat(names, ", ")) end)
        SafeNotify("Minit HUB","Player list copied ✓")
    end, 12)

    -- 68. Disable animations
    MakeToggle(page, "Disable Animations", "Freeze character animations", false, function(val)
        local animate = Character:FindFirstChild("Animate")
        if animate then animate.Disabled = val end
    end, 13)

    -- 69. Spin character
    local spinActive = false
    MakeToggle(page, "Spin Character", "Rotate in place rapidly", false, function(val)
        spinActive = val
        if val then task.spawn(function()
            while spinActive do
                HumanoidRootPart.CFrame = HumanoidRootPart.CFrame * CFrame.Angles(0, 0.1, 0)
                task.wait()
            end
        end) end
    end, 14)

    -- 70. Hide game GUIs
    MakeToggle(page, "Hide Game GUIs", "Toggle all in-game GUI screens", false, function(val)
        for _, v in ipairs(LocalPlayer.PlayerGui:GetChildren()) do
            if v ~= ScreenGui then v.Enabled = not val end
        end
    end, 15)

    -- 71. List scripts
    MakeButton(page, "List All Scripts", nil, Theme.TextDim, function()
        for _, v in ipairs(game:GetDescendants()) do
            if v:IsA("LocalScript") or v:IsA("Script") or v:IsA("ModuleScript") then
                print("[Minit HUB] Script: "..v:GetFullName())
            end
        end
        SafeNotify("Minit HUB","Scripts listed ✓")
    end, 16)

    -- 72. Super push
    MakeButton(page, "Super Push Forward", nil, Theme.Warning, function()
        local bv = Instance.new("BodyVelocity")
        bv.Velocity  = Camera.CFrame.LookVector * 300
        bv.MaxForce  = Vector3.new(1e6,1e6,1e6); bv.Parent = HumanoidRootPart
        game:GetService("Debris"):AddItem(bv, 0.25)
    end, 17)
end

-- ════════════════════════════════════════════════════════════════════════
--                           TAB: SETTINGS
-- ════════════════════════════════════════════════════════════════════════
do
    local page = Tabs["Settings"].page
    MakeSection(page, "FPS CONTROL", 1)

    -- 73. FPS Unlock
    MakeToggle(page, "Unlock FPS (Unlimited)", "Remove Roblox 60fps cap", false, function(val)
        Config.UnlockFPS = val
        pcall(function() setfpscap(val and 0 or 60) end)
        SafeNotify("Minit HUB", val and "FPS Unlocked (unlimited) ✓" or "FPS locked to 60")
    end, 2)

    -- 74. FPS cap slider
    MakeSlider(page, "FPS Cap", 30, 360, 60, function(v)
        Config.FPSLimit = v
        if not Config.UnlockFPS then pcall(function() setfpscap(v) end) end
    end, 3)

    -- 75–79. FPS Presets
    local fpsPresetFrame = Instance.new("Frame")
    fpsPresetFrame.Size = UDim2.new(1,0,0,0); fpsPresetFrame.BackgroundTransparency = 1
    fpsPresetFrame.AutomaticSize = Enum.AutomaticSize.Y; fpsPresetFrame.LayoutOrder = 4
    fpsPresetFrame.ZIndex = 13; fpsPresetFrame.Parent = page
    local _fpg = Instance.new("UIGridLayout"); _fpg.CellSize = UDim2.new(0.19,-4,0,34)
    _fpg.CellPadding = UDim2.fromOffset(4,4); _fpg.Parent = fpsPresetFrame
    for _, v in ipairs({30, 60, 120, 240, 360}) do
        MakeButton(fpsPresetFrame, tostring(v), nil, Theme.Accent, function()
            pcall(function() setfpscap(v) end)
            SafeNotify("Minit HUB","FPS set to "..v.." ✓")
        end)
    end

    MakeSection(page, "TOGGLE KEY", 5)

    local keyCard = Instance.new("Frame"); keyCard.Size = UDim2.new(1,0,0,56)
    keyCard.BackgroundColor3 = Theme.Surface; keyCard.BorderSizePixel = 0
    keyCard.LayoutOrder = 6; keyCard.ZIndex = 13; keyCard.Parent = page
    local _kcc = Instance.new("UICorner"); _kcc.CornerRadius = UDim.new(0,8); _kcc.Parent = keyCard

    local kL = Instance.new("TextLabel"); kL.Text = "Hub Toggle Key"
    kL.Font = Enum.Font.GothamSemibold; kL.TextSize = 13; kL.TextColor3 = Theme.Text
    kL.BackgroundTransparency = 1; kL.Size = UDim2.new(0.6,0,1,0); kL.Position = UDim2.fromOffset(10,0)
    kL.TextXAlignment = Enum.TextXAlignment.Left; kL.ZIndex = 14; kL.Parent = keyCard

    local kBtn = Instance.new("TextButton"); kBtn.Text = "RightShift"
    kBtn.Font = Enum.Font.GothamBold; kBtn.TextSize = 12; kBtn.TextColor3 = Theme.White
    kBtn.Size = UDim2.fromOffset(110,30); kBtn.Position = UDim2.new(1,-120,0.5,-15)
    kBtn.BackgroundColor3 = Theme.Accent; kBtn.BorderSizePixel = 0; kBtn.ZIndex = 15; kBtn.Parent = keyCard
    local _kbc = Instance.new("UICorner"); _kbc.CornerRadius = UDim.new(0,6); _kbc.Parent = kBtn

    local waitKey = false
    kBtn.MouseButton1Click:Connect(function()
        if waitKey then return end; waitKey = true; kBtn.Text = "Press a key..."
        Tween(kBtn, {BackgroundColor3=Theme.Warning}, 0.2)
        local conn; conn = UserInputService.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.Keyboard then
                Config.ToggleKey = inp.KeyCode
                kBtn.Text = tostring(inp.KeyCode):match("Enum%.KeyCode%.(.+)") or "?"
                Tween(kBtn, {BackgroundColor3=Theme.Accent}, 0.2)
                waitKey = false; conn:Disconnect()
            end
        end)
    end)

    MakeSection(page, "THEME PRESETS", 7)

    local themeFrame = Instance.new("Frame"); themeFrame.Size = UDim2.new(1,0,0,0)
    themeFrame.BackgroundTransparency = 1; themeFrame.AutomaticSize = Enum.AutomaticSize.Y
    themeFrame.LayoutOrder = 8; themeFrame.ZIndex = 13; themeFrame.Parent = page
    local _thg = Instance.new("UIGridLayout"); _thg.CellSize = UDim2.new(0.3,-4,0,34)
    _thg.CellPadding = UDim2.fromOffset(6,6); _thg.Parent = themeFrame
    local themes = {
        {"Purple",Color3.fromRGB(120,80,255)},{"Blue",Color3.fromRGB(80,160,255)},
        {"Cyan",Color3.fromRGB(0,220,220)},{"Green",Color3.fromRGB(60,220,120)},
        {"Red",Color3.fromRGB(255,60,60)},{"Gold",Color3.fromRGB(255,200,60)},
    }
    for _, t in ipairs(themes) do
        MakeButton(themeFrame, t[1], nil, t[2], function()
            Theme.Accent = t[2]; ToggleStroke.Color = t[2]
            SafeNotify("Minit HUB","Theme → "..t[1])
        end)
    end

    MakeSection(page, "EXTRA FUNCTIONS", 9)

    -- 80–100 extras
    -- 80. Remove Shadows
    MakeToggle(page, "Remove Shadows", "Disable global shadows", false, function(val)
        Lighting.GlobalShadows = not val
    end, 10)

    -- 81. Wireframe
    MakeToggle(page, "Wireframe Mode", "Make all world parts glass-transparent", false, function(val)
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and not v:IsAncestorOf(Character) then
                v.Material = val and Enum.Material.Glass or Enum.Material.SmoothPlastic
                v.Transparency = val and 0.9 or 0
            end
        end
    end, 11)

    -- 82. Health regen
    MakeToggle(page, "Health Regen (+5/0.5s)", "Slowly regain health", false, function(val)
        if val then task.spawn(function()
            while val do
                pcall(function()
                    if Humanoid.Health < Humanoid.MaxHealth then
                        Humanoid.Health = math.min(Humanoid.Health+5, Humanoid.MaxHealth)
                    end
                end); task.wait(0.5)
            end
        end) end
    end, 12)

    -- 83. Heal to full
    MakeButton(page, "Heal to Full HP", nil, Theme.Success, function()
        Humanoid.Health = Humanoid.MaxHealth
        SafeNotify("Minit HUB","Healed ✓")
    end, 13)

    -- 84. Kill self
    MakeButton(page, "Kill Self", nil, Theme.Danger, function() Humanoid.Health = 0 end, 14)

    -- 85. Freeze self
    MakeToggle(page, "Freeze Self", "Anchor your HumanoidRootPart", false, function(val)
        HumanoidRootPart.Anchored = val
    end, 15)

    -- 86. Freeze others
    MakeButton(page, "Freeze Other Players", nil, Theme.Danger, function()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.Anchored = true end
            end
        end
        SafeNotify("Minit HUB","Others frozen ✓")
    end, 16)

    -- 87. Unfreeze others
    MakeButton(page, "Unfreeze Other Players", nil, Theme.Success, function()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.Anchored = false end
            end
        end
        SafeNotify("Minit HUB","Others unfrozen ✓")
    end, 17)

    -- 88. Drop all tools
    MakeButton(page, "Drop All Tools", nil, Theme.Warning, function()
        for _, v in ipairs(LocalPlayer.Backpack:GetChildren()) do v:Destroy() end
        for _, v in ipairs(Character:GetChildren()) do
            if v:IsA("Tool") then v.Parent = nil end
        end
        SafeNotify("Minit HUB","Tools dropped ✓")
    end, 18)

    -- 89. Headless visual
    MakeButton(page, "Remove Head (Visual)", nil, Theme.TextDim, function()
        local head = Character:FindFirstChild("Head")
        if head then head.Transparency = 1 end
        local face = Character:FindFirstChild("face", true)
        if face then face.Transparency = 1 end
        SafeNotify("Minit HUB","Head hidden (client) ✓")
    end, 19)

    -- 90. Ice mode
    MakeButton(page, "Ice Mode (Zero Friction)", nil, Theme.AccentAlt, function()
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then v.Friction = 0 end
        end
        SafeNotify("Minit HUB","Ice mode ✓")
    end, 20)

    -- 91. Max friction
    MakeButton(page, "Max Friction (Sticky)", nil, Theme.TextDim, function()
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then v.Friction = 1 end
        end
        SafeNotify("Minit HUB","Friction maxed ✓")
    end, 21)

    -- 92. Acid trip
    MakeButton(page, "Acid Trip Mode", nil, Theme.AccentGlow, function()
        task.spawn(function()
            for i = 1, 360 do
                Lighting.Ambient        = Color3.fromHSV(i/360, 1, 1)
                Lighting.OutdoorAmbient = Color3.fromHSV((i+120)/360, 1, 1)
                task.wait(0.05)
            end
            Lighting.Ambient = Color3.fromRGB(128,128,128)
            Lighting.OutdoorAmbient = Color3.fromRGB(128,128,128)
        end)
    end, 22)

    -- 93. Disco lights
    MakeToggle(page, "Disco Lights", "Rapidly flash ambient colors", false, function(val)
        if val then task.spawn(function()
            while val do Lighting.Ambient = Color3.fromHSV(math.random(), 1, 1); task.wait(0.1) end
        end) else Lighting.Ambient = Color3.fromRGB(128,128,128) end
    end, 23)

    -- 94. Print values
    MakeButton(page, "Print All Game Values", nil, Theme.TextDim, function()
        for _, v in ipairs(game:GetDescendants()) do
            if v:IsA("ValueBase") then
                print("[Minit HUB] "..v:GetFullName().." = "..tostring(v.Value))
            end
        end
        SafeNotify("Minit HUB","Values printed ✓")
    end, 24)

    -- 95. Shift lock
    MakeButton(page, "Enable Shift Lock", nil, Theme.Accent, function()
        pcall(function() StarterGui:SetCore("DevEnableMouseLock", true) end)
        SafeNotify("Minit HUB","Shift lock enabled ✓")
    end, 25)

    -- 96. Reset camera
    MakeButton(page, "Reset Camera Type", nil, Theme.AccentAlt, function()
        Camera.CameraType = Enum.CameraType.Custom
        SafeNotify("Minit HUB","Camera reset ✓")
    end, 26)

    -- 97. Infinite stamina placeholder (loop jump)
    MakeToggle(page, "Infinite Stamina (Loop)", "Keep jump refreshed each tick", false, function(val)
        if val then local conn; conn = RunService.Heartbeat:Connect(function()
            if not val then conn:Disconnect(); return end
            Humanoid.JumpHeight = 7.2
        end) end
    end, 27)

    -- 98. Fly speed slider (for fly mode)
    MakeSlider(page, "Fly Speed", 10, 300, 40, function(v)
        -- stored, used by fly loop if re-activated
        _G.MinitFlySpeed = v
    end, 28)

    -- 99. No animations (entire character)
    MakeButton(page, "Stop Character Animations", nil, Theme.TextDim, function()
        for _, anim in ipairs(Humanoid:GetPlayingAnimationTracks()) do anim:Stop() end
        SafeNotify("Minit HUB","Animations stopped ✓")
    end, 29)

    -- 100. Clear all highlights
    MakeButton(page, "Clear All Highlights & ESP", nil, Theme.TextDim, function()
        for _, v in ipairs(game:GetDescendants()) do
            if v:IsA("Highlight") or v:IsA("SelectionBox") or v:IsA("BoxHandleAdornment") or v:IsA("BillboardGui") then
                v:Destroy()
            end
        end
        SafeNotify("Minit HUB","All highlights removed ✓")
    end, 30)

    -- About card
    MakeSection(page, "ABOUT", 31)
    local aboutCard = Instance.new("Frame"); aboutCard.Size = UDim2.new(1,0,0,70)
    aboutCard.BackgroundColor3 = Theme.Surface; aboutCard.BorderSizePixel = 0
    aboutCard.LayoutOrder = 32; aboutCard.ZIndex = 13; aboutCard.Parent = page
    local _abc = Instance.new("UICorner"); _abc.CornerRadius = UDim.new(0,10); _abc.Parent = aboutCard
    local _abg = Instance.new("UIGradient")
    _abg.Color =
ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(30,20,60)),ColorSequenceKeypoint.new(1,Color3.fromRGB(10,10,25))})
    _abg.Rotation = 45; _abg.Parent = aboutCard
    local aboutL = Instance.new("TextLabel")
    aboutL.Text = "Minit HUB v3.0 ULTRA  |  Built with ❤ by Minit Team\ndiscord.gg/minithub  |  100 FE Scripts  |  Multi-Device  |
Animated"
    aboutL.Font = Enum.Font.Gotham; aboutL.TextSize = 12; aboutL.TextColor3 = Theme.TextDim
    aboutL.BackgroundTransparency = 1; aboutL.Size = UDim2.new(1,-20,1,0); aboutL.Position = UDim2.fromOffset(10,0)
    aboutL.TextXAlignment = Enum.TextXAlignment.Left; aboutL.TextWrapped = true; aboutL.ZIndex = 14; aboutL.Parent = aboutCard
end

-- ════════════════════════════════════════════════════════════════════════
--                      OPEN / CLOSE ANIMATION
-- ════════════════════════════════════════════════════════════════════════
local guiOpen = true
local minimized = false

local function OpenGUI()
    guiOpen = true; MainFrame.Visible = true
    MainFrame.Size = UDim2.fromOffset(math.floor(GUI_W*0.85), math.floor(GUI_H*0.85))
    MainFrame.BackgroundTransparency = 0.6
    Tween(MainFrame, {Size=UDim2.fromOffset(GUI_W,GUI_H), BackgroundTransparency=0}, 0.4, Enum.EasingStyle.Back,
Enum.EasingDirection.Out)
    Tween(InnerGlow, {BackgroundTransparency=0.82}, 0.4)
end

local function CloseGUI()
    guiOpen = false
    Tween(MainFrame, {Size=UDim2.fromOffset(math.floor(GUI_W*0.85),math.floor(GUI_H*0.85)), BackgroundTransparency=1}, 0.3,
Enum.EasingStyle.Quart, Enum.EasingDirection.In)
    Tween(InnerGlow, {BackgroundTransparency=1}, 0.3)
    task.delay(0.32, function() MainFrame.Visible = false end)
end

local function MinimizeGUI()
    minimized = not minimized
    if minimized then
        Tween(MainFrame, {Size=UDim2.fromOffset(GUI_W,46)}, 0.3)
        SideBar.Visible = false; ContentFrame.Visible = false
    else
        Tween(MainFrame, {Size=UDim2.fromOffset(GUI_W,GUI_H)}, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        task.delay(0.12, function() SideBar.Visible = true; ContentFrame.Visible = true end)
    end
end

CloseBtn.MouseButton1Click:Connect(CloseGUI)
MinimizeBtn.MouseButton1Click:Connect(MinimizeGUI)
ToggleBtn.MouseButton1Click:Connect(function()
    if guiOpen then CloseGUI() else OpenGUI() end
end)

UserInputService.InputBegan:Connect(function(inp, gpe)
    if gpe then return end
    if inp.KeyCode == Config.ToggleKey then
        if guiOpen then CloseGUI() else OpenGUI() end
    end
    if inp.KeyCode == Enum.KeyCode.Space and Config.Infinite_Jump then
        local state = Humanoid:GetState()
        if state == Enum.HumanoidStateType.Freefall or state == Enum.HumanoidStateType.Jumping then
            Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- ════════════════════════════════════════════════════════════════════════
--                         DRAGGING SYSTEM
-- ════════════════════════════════════════════════════════════════════════
do
    local drag, dragInput, dragStart, startPos = false, nil, nil, nil
    TitleBar.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            drag = true; dragStart = inp.Position; startPos = MainFrame.Position
            inp.Changed:Connect(function()
                if inp.UserInputState == Enum.UserInputState.End then drag = false end
            end)
        end
    end)
    TitleBar.InputChanged:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
            dragInput = inp
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if inp == dragInput and drag then
            local delta = inp.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+delta.X, startPos.Y.Scale, startPos.Y.Offset+delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            drag = false
        end
    end)
end

-- ════════════════════════════════════════════════════════════════════════
--                       AMBIENT ANIMATIONS
-- ════════════════════════════════════════════════════════════════════════
task.spawn(function()
    while true do
        Tween(ToggleGlow, {BackgroundTransparency=0.5, Size=UDim2.fromOffset(78,78), Position=UDim2.fromOffset(-13,-13)}, 0.8,
Enum.EasingStyle.Sine)
        task.wait(0.8)
        Tween(ToggleGlow, {BackgroundTransparency=0.88, Size=UDim2.fromOffset(62,62), Position=UDim2.fromOffset(-5,-5)}, 0.8,
Enum.EasingStyle.Sine)
        task.wait(0.8)
    end
end)

task.spawn(function()
    while true do
        Tween(TitleIcon, {TextColor3=Theme.AccentAlt}, 1.5, Enum.EasingStyle.Sine)
        task.wait(1.5)
        Tween(TitleIcon, {TextColor3=Theme.AccentGlow}, 1.5, Enum.EasingStyle.Sine)
        task.wait(1.5)
    end
end)

task.spawn(function()
    while true do
        Tween(StatusDot, {BackgroundTransparency=0}, 0.6)
        task.wait(0.7)
        Tween(StatusDot, {BackgroundTransparency=0.7}, 0.6)
        task.wait(0.7)
    end
end)

task.spawn(function()
    while true do
        Tween(InnerGlow, {BackgroundColor3=Theme.AccentAlt}, 2, Enum.EasingStyle.Sine)
        task.wait(2)
        Tween(InnerGlow, {BackgroundColor3=Theme.Accent}, 2, Enum.EasingStyle.Sine)
        task.wait(2)
    end
end)

-- ════════════════════════════════════════════════════════════════════════
--                    RESPAWN CHARACTER REFRESH
-- ════════════════════════════════════════════════════════════════════════
LocalPlayer.CharacterAdded:Connect(function(char)
    Character        = char
    Humanoid         = char:WaitForChild("Humanoid")
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
    if Config.GodMode    then Humanoid.MaxHealth = math.huge; Humanoid.Health = math.huge end
    if Config.WalkSpeed  then Humanoid.WalkSpeed  = Config.WalkSpeed end
    if Config.JumpPower  then Humanoid.JumpPower  = Config.JumpPower; Humanoid.UseJumpPower = true end
end)

-- ════════════════════════════════════════════════════════════════════════
--                        STARTUP SEQUENCE
-- ════════════════════════════════════════════════════════════════════════
MainFrame.BackgroundTransparency = 1
MainFrame.Size = UDim2.fromOffset(math.floor(GUI_W*0.7), math.floor(GUI_H*0.7))
task.wait(0.4)
OpenGUI()

task.delay(1, function()
    SafeNotify("Minit HUB v3.0 ULTRA", "Welcome, "..LocalPlayer.DisplayName.."! 100 FE scripts ready ✓", 5)
end)

print("[Minit HUB v3.0 ULTRA] Loaded successfully!")
print("[Minit HUB] Toggle: RightShift  |  100 FE Functions  |  9 Tabs")
