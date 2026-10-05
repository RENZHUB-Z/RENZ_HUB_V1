local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local LOGO = "rbxassetid://85660407447010"

local function MakeDraggable(frame)
    local dragging, dragInput, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
end

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

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -40, 0, 10)
closeBtn.Text = "X"
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = mainFrame
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
closeBtn.MouseButton1Click:Connect(function() mainFrame.Visible = false end)

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -20, 1, -100)
scroll.Position = UDim2.new(0, 10, 0, 90)
scroll.BackgroundTransparency = 1
scroll.CanvasSize = UDim2.new(0, 0, 0, 300)
scroll.ScrollBarThickness = 8
scroll.ScrollBarImageColor3 = Color3.fromRGB(0, 140, 255)
scroll.Active = true
scroll.Parent = mainFrame

-- [ TAB BUTTONS SA TAAS NG SCROLL ]
local tabHolder = Instance.new("Frame")
tabHolder.Size = UDim2.new(1, -20, 0, 35)
tabHolder.Position = UDim2.new(0, 10, 0, 50)
tabHolder.BackgroundTransparency = 1
tabHolder.Parent = mainFrame

local tabMain = Instance.new("TextButton")
tabMain.Size = UDim2.new(0, 110, 0, 30)
tabMain.Position = UDim2.new(0, 0, 0, 0)
tabMain.Text = "Steal An Egg"
tabMain.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
tabMain.TextColor3 = Color3.new(1,1,1)
tabMain.Font = Enum.Font.GothamBold
tabMain.TextSize = 13
tabMain.Parent = tabHolder
Instance.new("UICorner", tabMain).CornerRadius = UDim.new(0, 8)

local tabCreator = Instance.new("TextButton")
tabCreator.Size = UDim2.new(0, 90, 0, 30)
tabCreator.Position = UDim2.new(0, 120, 0, 0)
tabCreator.Text = "Creator"
tabCreator.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
tabCreator.TextColor3 = Color3.new(1,1,1)
tabCreator.Font = Enum.Font.GothamBold
tabCreator.TextSize = 13
tabCreator.Parent = tabHolder
Instance.new("UICorner", tabCreator).CornerRadius = UDim.new(0, 8)

-- [ CREATOR PAGE FRAME - NAKA TAGO SA SIMULA ]
local creatorPage = Instance.new("Frame")
creatorPage.Size = UDim2.new(1, -20, 1, -100)
creatorPage.Position = UDim2.new(0, 10, 0, 90)
creatorPage.BackgroundColor3 = Color3.fromRGB(20,20,20)
creatorPage.Visible = false
creatorPage.Parent = mainFrame
Instance.new("UICorner", creatorPage).CornerRadius = UDim.new(0, 8)

local function makeInfo(text, y)
    local lbl = Instance.new("TextLabel")
    lbl.Text = text
    lbl.Size = UDim2.new(1, -20, 0, 25)
    lbl.Position = UDim2.new(0, 10, 0, y)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(200,200,200)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 13
    lbl.Parent = creatorPage
    return lbl
end

makeInfo("OWNER: RENZ / CRIZ", 15)
makeInfo("DISCORD: https://discord.gg/z8ycWNrrg", 50)
makeInfo("Promoter: official_l1amz", 85)
makeInfo("TikTok: @official_l1amz", 120)
makeInfo("https://www.tiktok.com/@official_l1amz", 145)

-- [ PAG PALIT NG TAB ]
tabMain.MouseButton1Click:Connect(function()
    scroll.Visible = true
    creatorPage.Visible = false
    tabMain.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
    tabCreator.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
end)

tabCreator.MouseButton1Click:Connect(function()
    scroll.Visible = false
    creatorPage.Visible = true
    tabCreator.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
    tabMain.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
end)

-- [ BUTTONS ]
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

local senaBtn = makeButton("SENA HUB\nLOAD", 10, 10)
local chilliBtn = makeButton("CHILLI HUB\nLOAD", 310, 10)
local ubBtn = makeButton("UB HUB\nLOAD", 10, 110)
local renzBtn = makeButton("RENZ HUB\nLOAD", 310, 110)

-- [ SCRIPTS LAHAT - 4 LANG ]
senaBtn.MouseButton1Click:Connect(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/senarbitx/sena/refs/heads/main/loader"))() end)
chilliBtn.MouseButton1Click:Connect(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/tienkhanht/spicy/main/Chilli.lua"))() end)
ubBtn.MouseButton1Click:Connect(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/TeamUBHub/UBLoader/refs/heads/main/Loader.lua"))() end)
renzBtn.MouseButton1Click:Connect(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/RENZHUB-Z/RENZ_HUB_V1/main/VMAX-HAHAHA.lua"))() end)
