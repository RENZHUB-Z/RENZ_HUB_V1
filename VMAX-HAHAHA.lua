-- RENZ HUB VMAX FINAL FIXED - NO CONSOLE ERROR - REAL ANTI CHASE
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

if game.CoreGui:FindFirstChild("RenzHubFinal") then game.CoreGui:FindFirstChild("RenzHubFinal"):Destroy() end
if LocalPlayer.PlayerGui:FindFirstChild("RenzHubFinal") then LocalPlayer.PlayerGui:FindFirstChild("RenzHubFinal"):Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "RenzHubV1"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local function makeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragInput, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
end

local beeLeft = Instance.new("ImageButton")
beeLeft.Size = UDim2.new(0,80,0,80)
beeLeft.Position = UDim2.new(0,15,0.48,0)
beeLeft.BackgroundColor3 = Color3.fromRGB(10,10,10)
beeLeft.BorderSizePixel = 0
beeLeft.Parent = gui
Instance.new("UICorner",beeLeft).CornerRadius = UDim.new(0,18)
local sL = Instance.new("UIStroke",beeLeft)
sL.Color = Color3.fromRGB(255,204,0)
sL.Thickness = 3
local icon = Instance.new("TextLabel")
icon.Size = UDim2.new(1,0,1,0)
icon.BackgroundTransparency = 1
icon.Text = "🤑😎"
icon.TextScaled = true
icon.Parent = beeLeft
makeDraggable(beeLeft)

local panel = Instance.new("Frame")
panel.Size = UDim2.new(0,380,0,170)
panel.Position = UDim2.new(1,-20,0,70)
panel.AnchorPoint = Vector2.new(1,0)
panel.BackgroundColor3 = Color3.fromRGB(10,10,20)
panel.BorderSizePixel = 0
panel.Parent = gui
Instance.new("UICorner",panel).CornerRadius = UDim.new(0,16)
local sR = Instance.new("UIStroke",panel)
sR.Color = Color3.fromRGB(255,210,70)
sR.Thickness = 3

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1,0,0,40)
titleBar.BackgroundTransparency = 1
titleBar.Parent = panel

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,-80,1,0)
title.Position = UDim2.new(0,10,0,0)
title.BackgroundTransparency = 1
title.Text = "RENZ HUB | REAL ANTI-CHASE"
title.TextColor3 = Color3.fromRGB(255,220,80)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar
makeDraggable(panel, titleBar)

local btnExit = Instance.new("TextButton")
btnExit.Size = UDim2.new(0,30,0,30)
btnExit.Position = UDim2.new(1,-35,0,5)
btnExit.BackgroundColor3 = Color3.fromRGB(255,60,60)
btnExit.Text = "X"
btnExit.Font = Enum.Font.GothamBold
btnExit.TextSize = 16
btnExit.TextColor3 = Color3.fromRGB(255,255,255)
btnExit.Parent = titleBar
Instance.new("UICorner",btnExit).CornerRadius = UDim.new(0,8)

local btnMin = Instance.new("TextButton")
btnMin.Size = UDim2.new(0,30,0,30)
btnMin.Position = UDim2.new(1,-70,0,5)
btnMin.BackgroundColor3 = Color3.fromRGB(60,60,60)
btnMin.Text = "-"
btnMin.Font = Enum.Font.GothamBold
btnMin.TextSize = 18
btnMin.TextColor3 = Color3.fromRGB(255,255,255)
btnMin.Parent = titleBar
Instance.new("UICorner",btnMin).CornerRadius = UDim.new(0,8)

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1,-20,0,25)
status.Position = UDim2.new(0,10,0,45)
status.BackgroundTransparency = 1
status.Text = "READY 🥚"
status.TextColor3 = Color3.fromRGB(255,220,80)
status.Font = Enum.Font.GothamBold
status.TextSize = 16
status.Parent = panel

local btnTP = Instance.new("TextButton")
btnTP.Size = UDim2.new(0.48,0,0,50)
btnTP.Position = UDim2.new(0,10,0,80)
btnTP.BackgroundColor3 = Color3.fromRGB(30,30,30)
btnTP.Text = "SAFE TP (1x)"
btnTP.TextColor3 = Color3.fromRGB(255,255,255)
btnTP.Font = Enum.Font.GothamBold
btnTP.TextSize = 13
btnTP.Parent = panel
Instance.new("UICorner",btnTP).CornerRadius = UDim.new(0,10)

local btnAnti = Instance.new("TextButton")
btnAnti.Size = UDim2.new(0.48,0,0,50)
btnAnti.Position = UDim2.new(0.52,0,0,80)
btnAnti.BackgroundColor3 = Color3.fromRGB(30,30,30)
btnAnti.Text = "ANTI-CHASE (2x)"
btnAnti.TextColor3 = Color3.fromRGB(255,255,255)
btnAnti.Font = Enum.Font.GothamBold
btnAnti.TextSize = 11
btnAnti.Parent = panel
Instance.new("UICorner",btnAnti).CornerRadius = UDim.new(0,10)

local btnToggleMode = Instance.new("TextButton")
btnToggleMode.Size = UDim2.new(1,-20,0,30)
btnToggleMode.Position = UDim2.new(0,10,0,135)
btnToggleMode.BackgroundColor3 = Color3.fromRGB(255,204,0)
btnToggleMode.Text = "TOGGLE PANEL: ON ✅"
btnToggleMode.TextColor3 = Color3.fromRGB(0,0,0)
btnToggleMode.Font = Enum.Font.GothamBold
btnToggleMode.TextSize = 12
btnToggleMode.Parent = panel
Instance.new("UICorner",btnToggleMode).CornerRadius = UDim.new(0,8)

local hasEgg = false
local lastClick = 0
local panelVisible = true

local function getSafe()
    for _,v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Name:lower():find("safe") then return v.CFrame + Vector3.new(0,6,0) end
    end
    return CFrame.new(0,10,0)
end

local function safeTP()
    if not hasEgg then status.Text = "❌ TAP EGG FIRST" task.wait(1) status.Text = "READY 🥚" return end
    local char = LocalPlayer.Character
    if not char then return end
    status.Text = "TP TO BASE... 🌀"
    char:PivotTo(getSafe())
    status.Text = "BASE TP DONE ✅"
    hasEgg = false
    task.wait(1.5)
    status.Text = "READY 🥚"
end

local function realAntiChase()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    status.Text = "REAL ANTI-CHASE 🔥"
    -- FIXED: Hindi na gagalawin yung Guard mismo, yung ikaw lang yung i-de-desync para di ka ma-detect
    pcall(function()
        hrp.CFrame = hrp.CFrame + Vector3.new(0,5,0)
        task.wait(0.1)
        -- Paikot ikot mabilis para malito yung guard AI
        for i=1,6 do
            local ang = math.random()*math.pi*2
            local off = Vector3.new(math.cos(ang)*15,0,math.sin(ang)*15)
            char:PivotTo(CFrame.new(hrp.Position + off + Vector3.new(0,2,0)))
            task.wait(0.07)
        end
    end)
    status.Text = "DI KA NA HINAHABOL ✅"
    task.wait(1.5)
    status.Text = "READY 🥚"
end

local function handleBee()
    local now = tick()
    if now - lastClick < 0.4 then
        realAntiChase()
    else
        task.wait(0.45)
        if tick() - lastClick >= 0.4 then
            if hasEgg then safeTP() else
                panelVisible = not panelVisible
                panel.Visible = panelVisible
            end
        end
    end
    lastClick = tick()
end

btnExit.MouseButton1Click:Connect(function() panel.Visible = false panelVisible = false end)
btnMin.MouseButton1Click:Connect(function() panel.Visible = false panelVisible = false end)
beeLeft.MouseButton1Click:Connect(function()
    if not panelVisible then panel.Visible = true panelVisible = true else handleBee() end
end)
btnTP.MouseButton1Click:Connect(safeTP)
btnAnti.MouseButton1Click:Connect(realAntiChase)
btnToggleMode.MouseButton1Click:Connect(function() panelVisible = not panelVisible panel.Visible = panelVisible btnToggleMode.Text = panelVisible and "TOGGLE PANEL: ON ✅" or "TOGGLE PANEL: OFF ❌" end)

ProximityPromptService.PromptTriggered:Connect(function(p,plr)
    if plr ~= LocalPlayer then return end
    if p.ObjectText:lower():find("steal") or p.ActionText:lower():find("steal") then hasEgg = true status.Text = "🥚 EGG GRABBED!" end
end)

for _,v in ipairs(Workspace:GetDescendants()) do if v:IsA("ProximityPrompt") then v.HoldDuration = 0 v.RequiresLineOfSight = false end end
Workspace.DescendantAdded:Connect(function(v) if v:IsA("ProximityPrompt") then v.HoldDuration = 0 v.RequiresLineOfSight = false end end)

status.Text = "FIXED - NO ERROR ✅"
