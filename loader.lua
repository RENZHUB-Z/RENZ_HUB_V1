local player = game:GetService("Players").LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
pcall(function() playerGui:FindFirstChild("RENZ_ULTRA"):Destroy() end)
pcall(function() playerGui:FindFirstChild("RENZ_HUB_V1"):Destroy() end)

local UserInputService = game:GetService("UserInputService")
local LOGO = "rbxassetid://85660407447010"

local function MakeDraggable(frame)
    local dragging = false
    local dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            pcall(function() update(input) end)
        end
    end)
    UserInputService.InputEnded:Connect(function()
        dragging = false
    end)
end

-- [ RENZ HUB • ULTRA EDITION ] LOADING
local gui = Instance.new("ScreenGui")
gui.Name = "RENZ_ULTRA"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local main = Instance.new("Frame")
main.Size = UDim2.new(1, 0, 1, 0)
main.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
main.BorderSizePixel = 0
main.Parent = gui

local title = Instance.new("TextLabel")
title.Text = "[ RENZ HUB • ULTRA EDITION ]"
title.Size = UDim2.new(0, 400, 0, 30)
title.Position = UDim2.new(0.5, -200, 0, 15)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(150, 150, 160)
title.Font = Enum.Font.Code
title.TextSize = 14
title.Parent = main

local centerLogo = Instance.new("ImageLabel")
centerLogo.Size = UDim2.new(0, 120, 0, 120)
centerLogo.Position = UDim2.new(0.5, -60, 0.5, -60)
centerLogo.Image = LOGO
centerLogo.BackgroundTransparency = 1
centerLogo.Parent = main

local loading = Instance.new("Frame")
loading.Size = UDim2.new(0, 150, 0, 3)
loading.Position = UDim2.new(0.5, -75, 0.5, 80)
loading.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
loading.BorderSizePixel = 0
loading.Parent = main

local renzText = Instance.new("TextLabel")
renzText.Text = "RENZ"
renzText.Size = UDim2.new(0, 200, 0, 50)
renzText.Position = UDim2.new(0.5, -100, 0.85, 0)
renzText.BackgroundTransparency = 1
renzText.TextColor3 = Color3.fromRGB(180, 180, 255)
renzText.Font = Enum.Font.GothamBlack
renzText.TextSize = 35
renzText.Parent = main

task.wait(2)
gui:Destroy()

-- MAIN HUB
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RENZ_HUB_V1"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 650, 0, 500)
mainFrame.Position = UDim2.new(0.5, -325, 0.5, -250)
mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

local stroke = Instance.new("UIStroke", mainFrame)
stroke.Color = Color3.fromRGB(0, 140, 255)
stroke.Thickness = 2
stroke.Parent = mainFrame

MakeDraggable(mainFrame)

local title2 = Instance.new("TextLabel")
title2.Size = UDim2.new(1, -80, 0, 40)
title2.Position = UDim2.new(0, 15, 0, 5)
title2.BackgroundTransparency = 1
title2.Text = "RENZ HUB V1 ANTI HIT"
title2.TextColor3 = Color3.fromRGB(0, 180, 255)
title2.Font = Enum.Font.GothamBold
title2.TextSize = 20
title2.TextXAlignment = Enum.TextXAlignment.Left
title2.Parent = mainFrame

local profile = Instance.new("ImageLabel")
profile.Size = UDim2.new(0, 50, 0, 50)
profile.Position = UDim2.new(1, -100, 0, 5)
profile.BackgroundTransparency = 1
profile.Image = LOGO
profile.Parent = mainFrame
Instance.new("UICorner", profile).CornerRadius = UDim.new(1, 0)

local openBtn = Instance.new("ImageButton")
openBtn.Size = UDim2.new(0, 65, 0, 65)
openBtn.Position = UDim2.new(0, 20, 0.5, -30)
openBtn.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
openBtn.Image = LOGO
openBtn.Visible = false
openBtn.Active = true
openBtn.Parent = screenGui
Instance.new("UICorner", openBtn).CornerRadius = UDim.new(1, 0)
local openStroke = Instance.new("UIStroke", openBtn)
openStroke.Color = Color3.fromRGB(0, 140, 255)
openStroke.Thickness = 3
openStroke.Parent = openBtn
MakeDraggable(openBtn)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -40, 0, 10)
closeBtn.Text = "X"
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = mainFrame
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
closeBtn.MouseButton1Click:Connect(function() mainFrame.Visible = false openBtn.Visible = true end)
openBtn.MouseButton1Click:Connect(function() mainFrame.Visible = true openBtn.Visible = false end)

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -20, 1, -60)
scroll.Position = UDim2.new(0, 10, 0, 50)
scroll.BackgroundTransparency = 1
scroll.CanvasSize = UDim2.new(0, 0, 0, 600)
scroll.ScrollBarThickness = 8
scroll.ScrollBarImageColor3 = Color3.fromRGB(0, 140, 255)
scroll.Active = true
scroll.Parent = mainFrame

local function makeButton(text, x, y)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 280, 0, 80)
    btn.Position = UDim2.new(0, x, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 16
    btn.Font = Enum.Font.GothamBold
    btn.Parent = scroll
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    return btn
end

local keylessBtn = makeButton("KEYLESS HUB\nLOAD", 10, 10)
local diabloBtn = makeButton("DIABLO SCRIPT\nLOAD", 310, 10)
local instantBtn = makeButton("INSTANT STEAL\nLOAD", 10, 110)
local senaBtn = makeButton("SENA HUB 5.2\nLOAD", 310, 110)
local chilliBtn = makeButton("CHILLI HUB\nLOAD", 10, 210)
local ubBtn = makeButton("UB HUB (BEST)\nLOAD", 310, 210)
local flowBtn = makeButton("RENZ ANTI HIT\nLOAD", 10, 310)

keylessBtn.MouseButton1Click:Connect(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/Dodoyung24/script-core/main/Steal-An-Egg"))() end)
diabloBtn.MouseButton1Click:Connect(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/Tsuo7/Tsuohub/main/stealanegg"))() end)
instantBtn.MouseButton1Click:Connect(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/betdoyvaka/stealanegg/main/Loader.lua"))() end)
senaBtn.MouseButton1Click:Connect(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/senarbitx/sena/refs/heads/main/loader"))() end)
chilliBtn.MouseButton1Click:Connect(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/tienkhanht/spicy/main/Chilli.lua"))() end)
ubBtn.MouseButton1Click:Connect(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/TeamUBHub/UBLoader/refs/heads/main/Loader.lua"))() end)
flowBtn.MouseButton1Click:Connect(function() loadstring(game:HttpGet("https://flowauth.net/v1/loaders/a31003a235b2c0b094eb90c236eed925.lua"))() end)
