-- RENZ HUB | ANIMATION CHANGER
-- File: RenzAnimation.lua
-- Repo: RENZHUB-Z/RENZ_HUB_V1
-- Author: Renz
-- Features: RENZ HUB Title, Draggable, Search Bar, Exitable

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

if CoreGui:FindFirstChild("RENZ_HUB_ANIMATION_CHANGER") then
    CoreGui:FindFirstChild("RENZ_HUB_ANIMATION_CHANGER"):Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RENZ_HUB_ANIMATION_CHANGER"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 650, 0, 450)
MainFrame.Position = UDim2.new(0.5, -325, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(20,20,20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0,10)

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1,0,0,50)
TitleBar.BackgroundColor3 = Color3.fromRGB(0,255,136)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0,10)

local TitleFix = Instance.new("Frame")
TitleFix.Size = UDim2.new(1,0,0,20)
TitleFix.Position = UDim2.new(0,0,1,-20)
TitleFix.BackgroundColor3 = Color3.fromRGB(0,255,136)
TitleFix.BorderSizePixel = 0
TitleFix.Parent = TitleBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,-100,1,0)
Title.Position = UDim2.new(0,15,0,0)
Title.BackgroundTransparency = 1
Title.Text = "RENZ HUB | ANIMATION CHANGER"
Title.TextColor3 = Color3.fromRGB(0,0,0)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 18
Title.Parent = TitleBar

local ExitBtn = Instance.new("TextButton")
ExitBtn.Size = UDim2.new(0,30,0,30)
ExitBtn.Position = UDim2.new(1,-40,0,10)
ExitBtn.BackgroundColor3 = Color3.fromRGB(255,60,60)
ExitBtn.Text = "X"
ExitBtn.TextColor3 = Color3.fromRGB(255,255,255)
ExitBtn.Font = Enum.Font.GothamBold
ExitBtn.TextSize = 14
ExitBtn.Parent = TitleBar
Instance.new("UICorner", ExitBtn).CornerRadius = UDim.new(0,8)
ExitBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local SearchBar = Instance.new("TextBox")
SearchBar.Size = UDim2.new(1,-20,0,35)
SearchBar.Position = UDim2.new(0,10,0,60)
SearchBar.BackgroundColor3 = Color3.fromRGB(35,35,35)
SearchBar.PlaceholderText = "🔍 Search emotes... Floss, Dab, Monkey"
SearchBar.Text = ""
SearchBar.TextColor3 = Color3.fromRGB(255,255,255)
SearchBar.PlaceholderColor3 = Color3.fromRGB(150,150,150)
SearchBar.Font = Enum.Font.Gotham
SearchBar.TextSize = 14
SearchBar.Parent = MainFrame
Instance.new("UICorner", SearchBar).CornerRadius = UDim.new(0,8)

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1,-20,1,-110)
Scroll.Position = UDim2.new(0,10,0,105)
Scroll.BackgroundColor3 = Color3.fromRGB(25,25,25)
Scroll.BorderSizePixel = 0
Scroll.CanvasSize = UDim2.new(0,0,0,0)
Scroll.ScrollBarThickness = 6
Scroll.Parent = MainFrame
Instance.new("UICorner", Scroll).CornerRadius = UDim.new(0,8)

local Grid = Instance.new("UIGridLayout")
Grid.CellPadding = UDim2.new(0,10,0,10)
Grid.CellSize = UDim2.new(0,140,0,40)
Grid.Parent = Scroll

local EmoteCache = {}
local function PlayEmote(id)
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local anim = hum:FindFirstChildOfClass("Animator") or Instance.new("Animator", hum)
    for _, t in pairs(anim:GetPlayingAnimationTracks()) do t:Stop() end
    if not EmoteCache[id] then
        local a = Instance.new("Animation")
        a.AnimationId = "rbxassetid://"..id
        EmoteCache[id] = anim:LoadAnimation(a)
    end
    EmoteCache[id]:Play()
end

local AllEmotes = {
    {Name="Stylish Spin", Id="3333432454"},
    {Name="Monkey", Id="3333499508"},
    {Name="Floss", Id="3360686498"},
    {Name="Dab", Id="3360793246"},
    {Name="Hype", Id="3695338120"},
    {Name="Infinite", Id="3695309750"},
    {Name="The Best", Id="3333533678"},
}

local Buttons = {}
local function CreateButtons(filter)
    for _, b in pairs(Buttons) do b:Destroy() end
    Buttons = {}
    filter = string.lower(filter or "")
    for _, emote in pairs(AllEmotes) do
        if filter == "" or string.find(string.lower(emote.Name), filter) then
            local Btn = Instance.new("TextButton")
            Btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
            Btn.Text = emote.Name
            Btn.TextColor3 = Color3.new(1,1,1)
            Btn.Font = Enum.Font.GothamBold
            Btn.TextSize = 12
            Btn.Parent = Scroll
            Instance.new("UICorner", Btn).CornerRadius = UDim.new(0,6)
            Btn.MouseButton1Click:Connect(function() PlayEmote(emote.Id) end)
            table.insert(Buttons, Btn)
        end
    end
    Scroll.CanvasSize = UDim2.new(0,0,0,Grid.AbsoluteContentSize.Y+10)
end

CreateButtons("")
SearchBar:GetPropertyChangedSignal("Text"):Connect(function() CreateButtons(SearchBar.Text) end)

local dragging, dragInput, dragStart, startPos
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
TitleBar.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+delta.X, startPos.Y.Scale, startPos.Y.Offset+delta.Y)
    end
end)

print("RENZ HUB | ANIMATION CHANGER Loaded")
