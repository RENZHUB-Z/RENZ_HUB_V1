-- RenzHub_V2.lua
-- RENZ HUB V2 - FINAL | github.com/RENZHUB-Z/RENZ_HUB_V1
-- Title: RENZ HUB V2 | Discord: discord.gg/CxdWcEn3u | No Bee Emoji

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local COLORS = {
    windowBg = Color3.fromRGB(20, 16, 4),
    headerBg2 = Color3.fromRGB(32, 24, 4),
    tabBg = Color3.fromRGB(40, 32, 6),
    tabHover = Color3.fromRGB(70, 55, 10),
    tabText = Color3.fromRGB(220, 210, 180),
    rowBg = Color3.fromRGB(38, 30, 6),
    rowAlt = Color3.fromRGB(48, 38, 8),
    rowHover = Color3.fromRGB(68, 54, 10),
    rowText = Color3.fromRGB(240, 235, 210),
    white = Color3.fromRGB(255, 255, 255),
    dimText = Color3.fromRGB(180, 170, 140),
    green = Color3.fromRGB(60, 220, 100),
    accent = Color3.fromRGB(240, 200, 30),
    accentDark = Color3.fromRGB(60, 45, 6),
    accentHover = Color3.fromRGB(255, 225, 80),
    border = Color3.fromRGB(240, 200, 30),
    borderSoft = Color3.fromRGB(110, 90, 15),
    scrollbar = Color3.fromRGB(240, 200, 30),
    activeBtn = Color3.fromRGB(220, 60, 60),
    activeBtnHover = Color3.fromRGB(255, 90, 90),
}

local SOUND_IDS = {
    click = "rbxassetid://6895070853",
    on = "rbxassetid://9114603783",
    off = "rbxassetid://9114649048",
    open = "rbxassetid://9114693783",
}

local soundFolder = Instance.new("Folder")
soundFolder.Name = "RenzHubSounds"
soundFolder.Parent = SoundService

local function makeSound(name, id, vol, speed)
    local s = Instance.new("Sound")
    s.Name = name; s.SoundId = id; s.Volume = vol or 0.5; s.PlaybackSpeed = speed or 1; s.Parent = soundFolder
    return s
end

local sounds = {
    click = makeSound("Click", SOUND_IDS.click, 0.5, 1.6),
    on = makeSound("On", SOUND_IDS.on, 0.6, 1),
    off = makeSound("Off", SOUND_IDS.off, 0.5, 1),
    open = makeSound("Open", SOUND_IDS.open, 0.5, 1),
}

local function playSound(name)
    local s = sounds[name]
    if not s then return end
    s.TimePosition = 0; s:Play()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RenzHubGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local uiScale = Instance.new("UIScale", screenGui)
local function updateScale()
    local vp = workspace.CurrentCamera.ViewportSize
    local minSide = math.min(vp.X, vp.Y)
    uiScale.Scale = if minSide < 500 then 0.72 elseif minSide < 800 then 0.9 else 1
end
updateScale()
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)

local window = Instance.new("Frame", screenGui)
window.Name = "Window"
window.AnchorPoint = Vector2.new(0.5, 0.5)
window.Position = UDim2.new(0.5, 0, 0.5, 0)
window.Size = UDim2.new(0, 620, 0, 460)
window.BackgroundColor3 = COLORS.windowBg
window.BorderSizePixel = 0
window.Active = true
window.Draggable = true
Instance.new("UICorner", window).CornerRadius = UDim.new(0,6)
local windowStroke = Instance.new("UIStroke", window)
windowStroke.Color = COLORS.border; windowStroke.Thickness = 1.5

local glow = Instance.new("ImageLabel", window)
glow.Name = "Glow"; glow.BackgroundTransparency = 1; glow.Image = "rbxassetid://5028857084"
glow.ImageColor3 = COLORS.accent; glow.ImageTransparency = 0.5
glow.Size = UDim2.new(1, 80, 1, 80); glow.Position = UDim2.new(0.5, 0, 0.5, 0)
glow.AnchorPoint = Vector2.new(0.5, 0.5); glow.ZIndex = -1
TweenService:Create(glow, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {ImageTransparency = 0.75, Size = UDim2.new(1, 110, 1, 110)}):Play()

local header = Instance.new("Frame", window)
header.Size = UDim2.new(1, 0, 0, 40); header.BackgroundColor3 = COLORS.accentDark; header.BorderSizePixel = 0; header.ZIndex = 2
Instance.new("UICorner", header).CornerRadius = UDim.new(0,6)
local headerCover = Instance.new("Frame", header)
headerCover.Size = UDim2.new(1, 0, 0, 6); headerCover.Position = UDim2.new(0, 0, 1, -6); headerCover.BackgroundColor3 = COLORS.accentDark; headerCover.BorderSizePixel = 0; headerCover.ZIndex = 3
local headerGradient = Instance.new("UIGradient", header)
headerGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, COLORS.accentDark), ColorSequenceKeypoint.new(1, COLORS.headerBg2)})

local title = Instance.new("TextLabel", header)
title.Position = UDim2.new(0, 14, 0, 0); title.Size = UDim2.new(0, 220, 1, 0); title.BackgroundTransparency = 1
title.Text = "RENZ HUB V2"; title.TextColor3 = COLORS.accent; title.Font = Enum.Font.GothamBold; title.TextSize = 18; title.TextXAlignment = Enum.TextXAlignment.Left; title.ZIndex = 4

local discord = Instance.new("TextLabel", header)
discord.Position = UDim2.new(0, 180, 0, 0); discord.Size = UDim2.new(0, 250, 1, 0); discord.BackgroundTransparency = 1
discord.Text = "discord.gg/CxdWcEn3u"; discord.TextColor3 = COLORS.dimText; discord.Font = Enum.Font.GothamMedium; discord.TextSize = 11; discord.TextXAlignment = Enum.TextXAlignment.Left; discord.ZIndex = 4

local minBtn = Instance.new("TextButton", header)
minBtn.AnchorPoint = Vector2.new(1,0); minBtn.Position = UDim2.new(1, -34, 0, 0); minBtn.Size = UDim2.new(0, 20, 1, 0)
minBtn.BackgroundTransparency = 1; minBtn.Text = "--"; minBtn.TextColor3 = COLORS.accent; minBtn.Font = Enum.Font.GothamBold; minBtn.TextSize = 16; minBtn.ZIndex = 5
local closeBtn = Instance.new("TextButton", header)
closeBtn.AnchorPoint = Vector2.new(1,0); closeBtn.Position = UDim2.new(1, -6, 0, 0); closeBtn.Size = UDim2.new(0, 20, 1, 0)
closeBtn.BackgroundTransparency = 1; closeBtn.Text = "X"; closeBtn.TextColor3 = COLORS.accent; closeBtn.Font = Enum.Font.GothamBold; closeBtn.TextSize = 14; closeBtn.ZIndex = 5

local tabBar = Instance.new("Frame", window)
tabBar.Position = UDim2.new(0, 10, 0, 48); tabBar.Size = UDim2.new(1, -20, 0, 34); tabBar.BackgroundTransparency = 1; tabBar.ZIndex = 2
local tabLayout = Instance.new("UIListLayout", tabBar); tabLayout.FillDirection = Enum.FillDirection.Horizontal; tabLayout.Padding = UDim.new(0,6)
local function createTab(name, order)
    local tab = Instance.new("TextButton"); tab.Name = name.."Tab"; tab.Size = UDim2.new(0.245, 0, 1, 0); tab.BackgroundColor3 = COLORS.tabBg; tab.BorderSizePixel = 0
    tab.Text = name; tab.TextColor3 = COLORS.tabText; tab.Font = Enum.Font.GothamBold; tab.TextSize = 12; tab.AutoButtonColor = false; tab.LayoutOrder = order; tab.ZIndex = 3; tab.Parent = tabBar
    Instance.new("UICorner", tab).CornerRadius = UDim.new(0,4); local s = Instance.new("UIStroke", tab); s.Color = COLORS.borderSoft; s.Thickness = 1
    return tab
end
local tabs = {createTab("SCRIPTS",1), createTab("SERVER HOP",2), createTab("SHADER",3), createTab("SETTINGS",4)}
local activeTab = tabs[3]
local function setActiveTab(tab)
    for _, t in ipairs(tabs) do if t == tab then t.BackgroundColor3 = COLORS.accent; t.TextColor3 = Color3.fromRGB(30,20,0); t.UIStroke.Color = COLORS.border else t.BackgroundColor3 = COLORS.tabBg; t.TextColor3 = COLORS.tabText; t.UIStroke.Color = COLORS.borderSoft end end
end

local listContainer = Instance.new("Frame", window)
listContainer.Position = UDim2.new(0, 10, 0, 90); listContainer.Size = UDim2.new(1, -20, 1, -100); listContainer.BackgroundTransparency = 1; listContainer.ClipsDescendants = true; listContainer.ZIndex = 2
local scroll = Instance.new("ScrollingFrame", listContainer)
scroll.Size = UDim2.new(1, -8, 1, 0); scroll.BackgroundTransparency = 1; scroll.BorderSizePixel = 0; scroll.ScrollBarThickness = 4; scroll.ScrollBarImageColor3 = COLORS.scrollbar
scroll.CanvasSize = UDim2.new(0,0,0,0); scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; scroll.ZIndex = 3
local listLayout = Instance.new("UIListLayout", scroll); listLayout.Padding = UDim.new(0,6)
local trackedRows = {}; local trackedButtons = {}
local function createRow(name, index, callback)
    local row = Instance.new("Frame"); row.Size = UDim2.new(1, 0, 0, 34); row.BackgroundColor3 = (index % 2 == 0) and COLORS.rowAlt or COLORS.rowBg; row.BorderSizePixel = 0; row.LayoutOrder = index; row.Parent = scroll
    Instance.new("UICorner", row).CornerRadius = UDim.new(0,4)
    local label = Instance.new("TextLabel", row); label.Position = UDim2.new(0,10,0,0); label.Size = UDim2.new(1,-90,1,0); label.BackgroundTransparency = 1; label.Text = name; label.TextColor3 = COLORS.rowText; label.Font = Enum.Font.GothamMedium; label.TextSize = 13; label.TextXAlignment = Enum.TextXAlignment.Left
    local btn = Instance.new("TextButton", row); btn.Size = UDim2.new(0,60,0,24); btn.Position = UDim2.new(1,-70,0.5,-12); btn.BackgroundColor3 = COLORS.tabBg; btn.Text = "OFF"; btn.TextColor3 = COLORS.white; btn.Font = Enum.Font.GothamBold; btn.TextSize = 11
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,4)
    local isOn = false
    btn.MouseButton1Click:Connect(function() isOn = not isOn; btn.Text = isOn and "ON" or "OFF"; btn.BackgroundColor3 = isOn and COLORS.activeBtn or COLORS.tabBg; playSound(isOn and "on" or "off"); callback(isOn) end)
    return row
end

local shaderEffects = {
    { name = "CINEMATIC BLOOM", setup = function() local fx=Instance.new("BloomEffect") fx.Name="RenzHub_Bloom" fx.Intensity=1.5 fx.Size=32 fx.Threshold=0.8 fx.Parent=Lighting end, teardown = function() local f=Lighting:FindFirstChild("RenzHub_Bloom") if f then f:Destroy() end end },
    { name = "VIBRANT COLOR", setup = function() local fx=Instance.new("ColorCorrectionEffect") fx.Name="RenzHub_Vibrant" fx.Saturation=0.8 fx.Contrast=0.25 fx.Parent=Lighting end, teardown = function() local f=Lighting:FindFirstChild("RenzHub_Vibrant") if f then f:Destroy() end end },
    { name = "RETRO / SEPIA", setup = function() local fx=Instance.new("ColorCorrectionEffect") fx.Name="RenzHub_Sepia" fx.Saturation=-1 fx.TintColor=Color3.fromRGB(230,190,120) fx.Parent=Lighting end, teardown = function() local f=Lighting:FindFirstChild("RenzHub_Sepia") if f then f:Destroy() end end },
    { name = "DEEP NIGHTS", setup = function() local fx=Instance.new("ColorCorrectionEffect") fx.Name="RenzHub_Night" fx.Brightness=-0.15 fx.Parent=Lighting end, teardown = function() local f=Lighting:FindFirstChild("RenzHub_Night") if f then f:Destroy() end end },
    { name = "SOFT BLUR", setup = function() local fx=Instance.new("BlurEffect") fx.Name="RenzHub_Blur" fx.Size=12 fx.Parent=Lighting end, teardown = function() local f=Lighting:FindFirstChild("RenzHub_Blur") if f then f:Destroy() end end },
    { name = "SUN GLOW", setup = function() local fx=Instance.new("SunRaysEffect") fx.Name="RenzHub_SunRays" fx.Intensity=0.25 fx.Parent=Lighting end, teardown = function() local f=Lighting:FindFirstChild("RenzHub_SunRays") if f then f:Destroy() end end },
}
local themes = {
    { name = "HONEY (DEFAULT)", r=240,g=200,b=30 }, { name = "RED", r=210,g=25,b=25 }, { name = "GREEN", r=40,g=200,b=70 },
    { name = "BLUE", r=40,g=120,b=230 }, { name = "PURPLE", r=150,g=60,b=220 }, { name = "GOLD", r=220,g=180,b=30 },
    { name = "PINKY", r=220,g=70,b=150 }, { name = "CYAN", r=40,g=200,b=210 }, { name = "WHITE", r=220,g=220,b=220 }, { name = "ORANGE", r=240,g=130,b=30 },
}
local function applyTheme(r,g,b) COLORS.accent=Color3.fromRGB(r,g,b); windowStroke.Color=COLORS.accent; title.TextColor3=COLORS.accent; glow.ImageColor3=COLORS.accent; scroll.ScrollBarImageColor3=COLORS.accent end
local function clearList() for _, child in ipairs(scroll:GetChildren()) do if child:IsA("Frame") then child:Destroy() end end end
local function buildShaderList() for i, shader in ipairs(shaderEffects) do createRow(shader.name, i, function(isOn) if isOn then shader.setup() print("[RENZ HUB V2] "..shader.name.." ON") else shader.teardown() print("[RENZ HUB V2] "..shader.name.." OFF") end end) end end
local function buildSettingsList() for i, theme in ipairs(themes) do local ct=theme; createRow(ct.name, i, function() applyTheme(ct.r, ct.g, ct.b) print("[RENZ HUB V2] Theme -> "..ct.name) end) end end
local placeholderData = { SCRIPTS={"AUTO FARM","SPEED HACK","JUMP POWER","INFINITE YIELD"}, ["SERVER HOP"]={"LOWEST PING","REGION: ASIA","REGION: EU","REGION: US"} }
local function buildList(tabName) clearList(); if tabName=="SHADER" then buildShaderList() elseif tabName=="SETTINGS" then buildSettingsList() else local data=placeholderData[tabName] or {}; for i, name in ipairs(data) do createRow(name, i, function() print("[RENZ HUB V2] "..name.." on "..tabName) end) end end end

for _, t in ipairs(tabs) do t.MouseButton1Click:Connect(function() playSound("click"); setActiveTab(t); activeTab=t; buildList(t.Name:gsub("Tab$","")) end) end
closeBtn.MouseButton1Click:Connect(function() playSound("click"); for _, shader in ipairs(shaderEffects) do shader.teardown() end; TweenService:Create(window,TweenInfo.new(0.25,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Size=UDim2.new(0,0,0,0),BackgroundTransparency=1}):Play(); task.delay(0.3,function() screenGui.Enabled=false end) end)
minBtn.MouseButton1Click:Connect(function() playSound("click"); local visible=listContainer.Visible; listContainer.Visible=not visible; TweenService:Create(window,TweenInfo.new(0.25,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Size=visible and UDim2.new(0,620,0,130) or UDim2.new(0,620,0,460)}):Play() end)
do local dragging, dragStart, startPos; header.InputBegan:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=true; dragStart=input.Position; startPos=window.Position end end); header.InputEnded:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=false end end); UserInputService.InputChanged:Connect(function(input) if dragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then local delta=input.Position-dragStart; window.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y) end end) end
local function playIntro() local originalSize=window.Size; window.Size=UDim2.new(0,0,0,0); TweenService:Create(window,TweenInfo.new(0.45,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=originalSize}):Play(); playSound("open") end
setActiveTab(activeTab); buildList("SHADER"); playIntro()
print("[RENZ HUB V2] Loaded | discord.gg/CxdWcEn3u")
