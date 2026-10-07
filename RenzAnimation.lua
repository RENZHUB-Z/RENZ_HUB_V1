-- RENZ HUB | ANIMATION CHANGER V3 - FINAL FIXED
-- Emotes AND Animations + Draggable Fix + X = Hide not Destroy
-- File: RenzAnimation.lua

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- If already exists, just show it again
local OldGui = CoreGui:FindFirstChild("RENZ_HUB_ANIMATION_CHANGER")
if OldGui then
    OldGui.Main.Visible = true
    return
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RENZ_HUB_ANIMATION_CHANGER"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true

local MainFrame = Instance.new("Frame")
MainFrame.Name = "Main"
MainFrame.Size = UDim2.new(0, 750, 0, 520)
MainFrame.Position = UDim2.new(0.5, -375, 0.5, -260)
MainFrame.BackgroundColor3 = Color3.fromRGB(20,20,20)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0,10)

-- TITLE BAR - Draggable area
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1,0,0,50)
TitleBar.BackgroundColor3 = Color3.fromRGB(0,255,136)
TitleBar.BorderSizePixel = 0
TitleBar.ZIndex = 2
TitleBar.Parent = MainFrame
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0,10)
local Fix = Instance.new("Frame")
Fix.Size = UDim2.new(1,0,0,20)
Fix.Position = UDim2.new(0,0,1,-20)
Fix.BackgroundColor3 = Color3.fromRGB(0,255,136)
Fix.BorderSizePixel = 0
Fix.ZIndex = 2
Fix.Parent = TitleBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,-110,1,0)
Title.Position = UDim2.new(0,15,0,0)
Title.BackgroundTransparency = 1
Title.Text = "RENZ HUB | ANIMATION CHANGER"
Title.TextColor3 = Color3.new(0,0,0)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 18
Title.ZIndex = 3
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local ExitBtn = Instance.new("TextButton")
ExitBtn.Size = UDim2.new(0,30,0,30)
ExitBtn.Position = UDim2.new(1,-40,0,10)
ExitBtn.BackgroundColor3 = Color3.fromRGB(255,60,60)
ExitBtn.Text = "X"
ExitBtn.TextColor3 = Color3.new(1,1,1)
ExitBtn.Font = Enum.Font.GothamBold
ExitBtn.TextSize = 14
ExitBtn.ZIndex = 3
ExitBtn.Parent = TitleBar
Instance.new("UICorner", ExitBtn).CornerRadius = UDim.new(0,8)

-- TAB BUTTONS - Emotes vs Animations
local TabFrame = Instance.new("Frame")
TabFrame.Size = UDim2.new(1,-20,0,35)
TabFrame.Position = UDim2.new(0,10,0,60)
TabFrame.BackgroundTransparency = 1
TabFrame.Parent = MainFrame

local EmoteTab = Instance.new("TextButton")
EmoteTab.Size = UDim2.new(0.5,-5,1,0)
EmoteTab.Position = UDim2.new(0,0,0,0)
EmoteTab.BackgroundColor3 = Color3.fromRGB(0,255,136)
EmoteTab.Text = "EMOTES"
EmoteTab.Font = Enum.Font.GothamBlack
EmoteTab.TextSize = 13
EmoteTab.TextColor3 = Color3.new(0,0,0)
EmoteTab.Parent = TabFrame
Instance.new("UICorner", EmoteTab).CornerRadius = UDim.new(0,8)

local AnimTab = Instance.new("TextButton")
AnimTab.Size = UDim2.new(0.5,-5,1,0)
AnimTab.Position = UDim2.new(0.5,5,0,0)
AnimTab.BackgroundColor3 = Color3.fromRGB(50,50,50)
AnimTab.Text = "ANIMATIONS"
AnimTab.Font = Enum.Font.GothamBlack
AnimTab.TextSize = 13
AnimTab.TextColor3 = Color3.new(1,1,1)
AnimTab.Parent = TabFrame
Instance.new("UICorner", AnimTab).CornerRadius = UDim.new(0,8)

local SearchBar = Instance.new("TextBox")
SearchBar.Size = UDim2.new(1,-20,0,35)
SearchBar.Position = UDim2.new(0,10,0,105)
SearchBar.BackgroundColor3 = Color3.fromRGB(35,35,35)
SearchBar.PlaceholderText = "🔍 Search... zombie, werewolf, walk, idle, stylish"
SearchBar.Text = ""
SearchBar.TextColor3 = Color3.new(1,1,1)
SearchBar.PlaceholderColor3 = Color3.fromRGB(150,150,150)
SearchBar.Font = Enum.Font.Gotham
SearchBar.TextSize = 14
SearchBar.Parent = MainFrame
Instance.new("UICorner", SearchBar).CornerRadius = UDim.new(0,8)

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1,-20,1,-155)
Scroll.Position = UDim2.new(0,10,0,150)
Scroll.BackgroundColor3 = Color3.fromRGB(25,25,25)
Scroll.BorderSizePixel = 0
Scroll.CanvasSize = UDim2.new(0,0,0,0)
Scroll.ScrollBarThickness = 6
Scroll.Parent = MainFrame
Instance.new("UICorner", Scroll).CornerRadius = UDim.new(0,8)

local Grid = Instance.new("UIGridLayout", Scroll)
Grid.CellPadding = UDim2.new(0,10,0,10)
Grid.CellSize = UDim2.new(0,165,0,40)

-- ANIMATION PLAYER
local CurrentMode = "Emotes"

local function PlayAnim(id, isAnimationChanger)
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local animator = hum:FindFirstChildOfClass("Animator")
    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = hum
    end

    for _, track in pairs(animator:GetPlayingAnimationTracks()) do
        track:Stop()
    end

    -- If Animations mode (Walk, Idle etc), need to change Animate script
    if isAnimationChanger then
        -- For Animation Changer (Idle/Walk/Run)
        local animate = char:FindFirstChild("Animate")
        if animate then
            -- Override default animations
            if CurrentMode == "Walk" then
                animate.walk.WalkAnim.AnimationId = "rbxassetid://"..id
            elseif CurrentMode == "Idle" then
                animate.idle.Animation1.AnimationId = "rbxassetid://"..id
                animate.idle.Animation2.AnimationId = "rbxassetid://"..id
            elseif CurrentMode == "Run" then
                animate.run.RunAnim.AnimationId = "rbxassetid://"..id
            elseif CurrentMode == "Jump" then
                animate.jump.JumpAnim.AnimationId = "rbxassetid://"..id
            end
        end
    end

    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://"..id
    local track = animator:LoadAnimation(anim)
    track:Play()
    track.Looped = true
    track.Priority = Enum.AnimationPriority.Action
end

-- FULL DATA - Emotes AND Animations
local EmotesData = {
    {Name="Zombie", Id="616158929"}, {Name="Zombie Classic", Id="616160636"},
    {Name="Werewolf", Id="616158992"}, {Name="Vampire", Id="616158699"},
    {Name="Witch", Id="616133919"}, {Name="Ghost", Id="616158669"},
    {Name="Stylish Spin", Id="3333432454"}, {Name="Monkey", Id="3333499508"},
    {Name="Floss", Id="3360686498"}, {Name="Dab", Id="3360793246"},
    {Name="Hype", Id="3695338120"}, {Name="Orange Justice", Id="3360686107"},
    {Name="The Best", Id="3333533678"}, {Name="Electro Shuffle", Id="3333533588"},
}

local AnimationsData = {
    {Name="Zombie Walk", Id="616168032", Type="Walk"},
    {Name="Werewolf Walk", Id="616168219", Type="Walk"},
    {Name="Vampire Walk", Id="616168056", Type="Walk"},
    {Name="Levitate Walk", Id="616168211", Type="Walk"},
    {Name="Zombie Idle", Id="616158929", Type="Idle"},
    {Name="Werewolf Idle", Id="616158665", Type="Idle"},
    {Name="Bold Walk", Id="616157476", Type="Walk"},
    {Name="Robot Walk", Id="616159216", Type="Walk"},
    {Name="Toy Walk", Id="616158742", Type="Walk"},
    {Name="Ninja Run", Id="616160101", Type="Run"},
    {Name="Superhero Run", Id="616160101", Type="Run"},
    {Name="Zombie Run", Id="616163682", Type="Run"},
}

local Buttons = {}
local CurrentList = EmotesData

local function CreateButtons(filter)
    for _, b in pairs(Buttons) do b:Destroy() end
    Buttons = {}
    filter = string.lower(filter or "")
    for _, item in pairs(CurrentList) do
        if filter == "" or string.find(string.lower(item.Name), filter) then
            local Btn = Instance.new("TextButton")
            Btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
            Btn.Text = item.Name
            Btn.TextColor3 = Color3.new(1,1,1)
            Btn.Font = Enum.Font.GothamBold
            Btn.TextSize = 11
            Btn.Parent = Scroll
            Instance.new("UICorner", Btn).CornerRadius = UDim.new(0,6)
            Btn.MouseButton1Click:Connect(function()
                if CurrentMode == "Emotes" then
                    PlayAnim(item.Id, false)
                else
                    PlayAnim(item.Id, true)
                end
            end)
            table.insert(Buttons, Btn)
        end
    end
    Scroll.CanvasSize = UDim2.new(0,0,0,Grid.AbsoluteContentSize.Y+10)
end

EmoteTab.MouseButton1Click:Connect(function()
    CurrentMode = "Emotes"
    CurrentList = EmotesData
    EmoteTab.BackgroundColor3 = Color3.fromRGB(0,255,136)
    EmoteTab.TextColor3 = Color3.new(0,0,0)
    AnimTab.BackgroundColor3 = Color3.fromRGB(50,50,50)
    AnimTab.TextColor3 = Color3.new(1,1,1)
    CreateButtons(SearchBar.Text)
end)

AnimTab.MouseButton1Click:Connect(function()
    CurrentMode = "Animations"
    CurrentList = AnimationsData
    AnimTab.BackgroundColor3 = Color3.fromRGB(0,255,136)
    AnimTab.TextColor3 = Color3.new(0,0,0)
    EmoteTab.BackgroundColor3 = Color3.fromRGB(50,50,50)
    EmoteTab.TextColor3 = Color3.new(1,1,1)
    CreateButtons(SearchBar.Text)
end)

CreateButtons("")
SearchBar:GetPropertyChangedSignal("Text"):Connect(function() CreateButtons(SearchBar.Text) end)

-- FIXED DRAGGABLE - Whole TitleBar draggable
local dragging = false
local dragStart, startPos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

TitleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- FIXED X BUTTON - Hide not Destroy, RightShift to show again
ExitBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    -- Show hint
    game.StarterGui:SetCore("SendNotification", {
        Title = "RENZ HUB";
        Text = "Press RightShift to open again";
        Duration = 3;
    })
end)

UIS.InputBegan:Connect(function(input, processed)
    if input.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

print("✅ RENZ HUB V3 Loaded - Emotes + Animations | Draggable Fixed | RightShift to Toggle")
