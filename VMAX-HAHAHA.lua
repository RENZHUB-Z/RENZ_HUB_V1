-- RENZ HUB VMAX - BEE HUB FINAL UI (Buttons Inside Rectangle)
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- INTRO
local introGui = Instance.new("ScreenGui")
introGui.Name = "RenzIntro"
introGui.IgnoreGuiInset = true
introGui.ResetOnSpawn = false
introGui.DisplayOrder = 999
introGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
local bg = Instance.new("Frame")
bg.Size = UDim2.new(1,0,1,0)
bg.BackgroundColor3 = Color3.fromRGB(0,0,0)
bg.BackgroundTransparency = 1
bg.Parent = introGui
local logo = Instance.new("ImageLabel")
logo.Size = UDim2.new(0,200,0,200)
logo.Position = UDim2.new(0.5,0,0.5,-40)
logo.AnchorPoint = Vector2.new(0.5,0.5)
logo.BackgroundTransparency = 1
logo.Image = "rbxassetid://85660407447010"
logo.ImageTransparency = 1
logo.Parent = bg
local title = Instance.new("TextLabel")
title.Size = UDim2.new(0,600,0,70)
title.Position = UDim2.new(0.5,0,0.65,0)
title.AnchorPoint = Vector2.new(0.5,0.5)
title.BackgroundTransparency = 1
title.Text = "RENZ HUB"
title.TextColor3 = Color3.fromRGB(0,140,255)
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.TextTransparency = 1
title.Parent = bg
local function tween(o,t,p) local tw = TweenService:Create(o,TweenInfo.new(t,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),p) tw:Play() return tw end
tween(bg,0.5,{BackgroundTransparency=0})
task.wait(0.5)
tween(logo,1.5,{ImageTransparency=0})
tween(title,1.5,{TextTransparency=0})
task.wait(2.5)
tween(bg,1,{BackgroundTransparency=1})
tween(logo,1,{ImageTransparency=1})
tween(title,1,{TextTransparency=1})
task.wait(1)
introGui:Destroy()

-- MAIN GUI - KATULAD SA PIC MO
local gui = Instance.new("ScreenGui")
gui.Name = "RenzBeeHub"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- LEFT BEE BUTTON (yung sa baba ng Shop)
local beeLeft = Instance.new("ImageButton")
beeLeft.Size = UDim2.new(0,75,0,75)
beeLeft.Position = UDim2.new(0,15,0.48,0)
beeLeft.BackgroundColor3 = Color3.fromRGB(10,10,10)
beeLeft.BorderSizePixel = 0
beeLeft.Parent = gui
Instance.new("UICorner",beeLeft).CornerRadius = UDim.new(0,18)
local strokeL = Instance.new("UIStroke",beeLeft)
strokeL.Color = Color3.fromRGB(255,204,0)
strokeL.Thickness = 3
local iconL = Instance.new("TextLabel")
iconL.Size = UDim2.new(1,0,1,0)
iconL.BackgroundTransparency = 1
iconL.Text = "🐝"
iconL.TextScaled = true
iconL.Parent = beeLeft

-- RIGHT RECTANGLE PANEL - BEE HUB | HELPER | ANTI-CHASE (tulad sa pic mo)
local panel = Instance.new("Frame")
panel.Size = UDim2.new(0,380,0,160)
panel.Position = UDim2.new(1,-20,0,70)
panel.AnchorPoint = Vector2.new(1,0)
panel.BackgroundColor3 = Color3.fromRGB(10,10,20)
panel.BorderSizePixel = 0
panel.Parent = gui
Instance.new("UICorner",panel).CornerRadius = UDim.new(0,16)
local strokeR = Instance.new("UIStroke",panel)
strokeR.Color = Color3.fromRGB(255,210,70)
strokeR.Thickness = 3

local titlePanel = Instance.new("TextLabel")
titlePanel.Size = UDim2.new(1,-20,0,35)
titlePanel.Position = UDim2.new(0,10,0,8)
titlePanel.BackgroundTransparency = 1
titlePanel.Text = "RENZ HUB 😎| HELPER | ANTI-CHASE"
titlePanel.TextColor3 = Color3.fromRGB(255,220,80)
titlePanel.Font = Enum.Font.GothamBold
titlePanel.TextSize = 15
titlePanel.TextXAlignment = Enum.TextXAlignment.Center
titlePanel.Parent = panel

local status = Instance.new("TextLabel")
status.Name = "Status"
status.Size = UDim2.new(1,-20,0,30)
status.Position = UDim2.new(0,10,0,50)
status.BackgroundTransparency = 1
status.Text = "WAS TELEPORT OFF 🥚"
status.TextColor3 = Color3.fromRGB(255,220,80)
status.Font = Enum.Font.GothamBold
status.TextSize = 18
status.Parent = panel

-- BUTTONS NASA LOOB NG RECTANGLE
local btnTP = Instance.new("TextButton")
btnTP.Name = "TPButton"
btnTP.Size = UDim2.new(0.48,0,0,50)
btnTP.Position = UDim2.new(0,10,0,95)
btnTP.BackgroundColor3 = Color3.fromRGB(30,30,30)
btnTP.Text = "SAFE TP"
btnTP.TextColor3 = Color3.fromRGB(255,255,255)
btnTP.Font = Enum.Font.GothamBold
btnTP.TextSize = 16
btnTP.Parent = panel
Instance.new("UICorner",btnTP).CornerRadius = UDim.new(0,10)
local s1 = Instance.new("UIStroke",btnTP)
s1.Color = Color3.fromRGB(0,200,255)
s1.Thickness = 2

local btnAnti = Instance.new("TextButton")
btnAnti.Name = "AntiButton"
btnAnti.Size = UDim2.new(0.48,0,0,50)
btnAnti.Position = UDim2.new(0.52,0,0,95)
btnAnti.BackgroundColor3 = Color3.fromRGB(30,30,30)
btnAnti.Text = "ANTI-CHASE"
btnAnti.TextColor3 = Color3.fromRGB(255,255,255)
btnAnti.Font = Enum.Font.GothamBold
btnAnti.TextSize = 14
btnAnti.Parent = panel
Instance.new("UICorner",btnAnti).CornerRadius = UDim.new(0,10)
local s2 = Instance.new("UIStroke",btnAnti)
s2.Color = Color3.fromRGB(255,204,0)
s2.Thickness = 2

-- LOGIC
local hasEgg = false
local lastClick = 0
local spots = {
    Vector3.new(500.62, 70.28, -366.71),
    Vector3.new(508.3, 70.28, -366.02),
    Vector3.new(519.43, 70.28, -366.47),
    Vector3.new(529.22, 70.28, -366.71),
    Vector3.new(546.8, 70.28, -364.4),
}

local function getSafe()
    for _,v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Name:lower():find("safe") then
            return v.CFrame + Vector3.new(0,6,0)
        end
    end
    return CFrame.new(0,10,0)
end

local function safeTP()
    if not hasEgg then status.Text = "❌ TAP EGG FIRST 🥚" task.wait(1.5) status.Text = "WAS TELEPORT OFF 🥚" return end
    local char = LocalPlayer.Character
    if not char then return end
    status.Text = "TELEPORTING... 🌀"
    local cf = getSafe()
    char:PivotTo(cf)
    task.wait(0.2)
    char:PivotTo(cf + Vector3.new(0,0,15))
    status.Text = "SAFE ZONE DONE ✅"
    hasEgg = false
    task.wait(2)
    status.Text = "WAS TELEPORT OFF 🥚"
end

local function antiChase()
    local char = LocalPlayer.Character
    if not char then return end
    status.Text = "ANTI-CHASE ON 🏃"
    for _,pos in ipairs(spots) do
        char:PivotTo(CFrame.new(pos))
        RunService.Heartbeat:Wait()
    end
    status.Text = "ANTI-CHASE DONE ✅"
    task.wait(1.5)
    status.Text = "WAS TELEPORT OFF 🥚"
end

local function handleBeePress()
    local now = tick()
    if now - lastClick < 0.35 then
        antiChase()
    else
        task.wait(0.4)
        if tick() - lastClick >= 0.35 then
            safeTP()
        end
    end
    lastClick = tick()
end

beeLeft.MouseButton1Click:Connect(handleBeePress)
btnTP.MouseButton1Click:Connect(safeTP)
btnAnti.MouseButton1Click:Connect(antiChase)

ProximityPromptService.PromptTriggered:Connect(function(p,plr)
    if plr ~= LocalPlayer then return end
    if p.ObjectText:lower():find("steal") or p.ActionText:lower():find("steal") then
        hasEgg = true
        status.Text = "🥚 EGG GRABBED!"
        beeLeft.BackgroundColor3 = Color3.fromRGB(50,40,0)
        tween(strokeL,0.2,{Thickness=5})
        task.wait(0.2)
        tween(strokeL,0.2,{Thickness=3})
    end
end)

for _,v in ipairs(Workspace:GetDescendants()) do
    if v:IsA("ProximityPrompt") then v.HoldDuration = 0 v.RequiresLineOfSight = false end
end
Workspace.DescendantAdded:Connect(function(v)
    if v:IsA("ProximityPrompt") then v.HoldDuration = 0 v.RequiresLineOfSight = false end
end)
