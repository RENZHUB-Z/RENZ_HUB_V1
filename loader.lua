local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local function MakeDraggable(frame)
    local dragging, dragStart, startPos
    frame.InputBegan:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true dragStart=input.Position startPos=frame.Position end end)
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType==Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+delta.X, startPos.Y.Scale, startPos.Y.Offset+delta.Y)
        end
    end)
    game:GetService("UserInputService").InputEnded:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RENZ_HUB_V1"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 620, 0, 420)
mainFrame.Position = UDim2.new(0.5, -310, 0.5, -210)
mainFrame.BackgroundColor3 = Color3.fromRGB(16,16,16)
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)
local stroke = Instance.new("UIStroke", mainFrame)
stroke.Color = Color3.fromRGB(110, 60, 255)
stroke.Thickness = 1.5
stroke.Parent = mainFrame
MakeDraggable(mainFrame)

-- MOBILE SCALE PARA DI SAKOP
local scale = Instance.new("UIScale")
scale.Scale = 0.8
scale.Parent = mainFrame

-- HEADER
local header = Instance.new("Frame")
header.Size = UDim2.new(1,0,0,50)
header.BackgroundTransparency = 1
header.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Text = "RENZ HUB V1"
title.Size = UDim2.new(0, 200, 0, 25)
title.Position = UDim2.new(0, 15, 0, 8)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local subTitle = Instance.new("TextLabel")
subTitle.Text = "Join Discord for more"
subTitle.Size = UDim2.new(0, 200, 0, 15)
subTitle.Position = UDim2.new(0, 15, 0, 28)
subTitle.BackgroundTransparency = 1
subTitle.TextColor3 = Color3.fromRGB(150,150,150)
subTitle.Font = Enum.Font.Gotham
subTitle.TextSize = 11
subTitle.TextXAlignment = Enum.TextXAlignment.Left
subTitle.Parent = header

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 32, 0, 32)
closeBtn.Position = UDim2.new(1, -40, 0, 9)
closeBtn.Text = "X"
closeBtn.BackgroundColor3 = Color3.fromRGB(180,40,40)
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = header
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
closeBtn.MouseButton1Click:Connect(function() mainFrame.Visible = false end)

-- SIDEBAR
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 150, 1, -60)
sidebar.Position = UDim2.new(0, 10, 0, 50)
sidebar.BackgroundColor3 = Color3.fromRGB(20,20,20)
sidebar.Parent = mainFrame
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 8)

local function makeSideBtn(text, y, active)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -10, 0, 38)
    b.Position = UDim2.new(0, 5, 0, y)
    b.Text = text
    b.BackgroundColor3 = active and Color3.fromRGB(110,60,255) or Color3.fromRGB(35,35,35)
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 12
    b.Parent = sidebar
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    return b
end

local btnSteal = makeSideBtn("Steal An Egg", 10, true)
local btnShader = makeSideBtn("Shader", 55, false)
local btnCreator = makeSideBtn("Creator", 100, false)

-- CONTENT AREA
local content = Instance.new("Frame")
content.Size = UDim2.new(1, -180, 1, -60)
content.Position = UDim2.new(0, 170, 0, 50)
content.BackgroundColor3 = Color3.fromRGB(22,22,22)
content.Parent = mainFrame
Instance.new("UICorner", content).CornerRadius = UDim.new(0, 8)

-- CREATOR PAGE (nakatago)
local creatorPage = Instance.new("Frame")
creatorPage.Size = UDim2.new(1,0,1,0)
creatorPage.BackgroundColor3 = Color3.fromRGB(22,22,22)
creatorPage.Visible = false
creatorPage.Parent = content
Instance.new("UICorner", creatorPage).CornerRadius = UDim.new(0, 8)

local function makeInfo(t,y)
    local l=Instance.new("TextLabel")
    l.Text=t l.Size=UDim2.new(1,-20,0,25) l.Position=UDim2.new(0,10,0,y)
    l.BackgroundTransparency=1 l.TextColor3=Color3.fromRGB(200,200,200)
    l.TextXAlignment=Enum.TextXAlignment.Left l.Font=Enum.Font.GothamBold l.TextSize=12 l.Parent=creatorPage
end
makeInfo("OWNER: RENZ / CRIZ", 20)
makeInfo("DISCORD: https://discord.gg/z8ycWNrrg", 55)
makeInfo("Promoter: official_l1amz", 90)
makeInfo("TikTok: @official_l1amz", 125)

-- STEAL AN EGG PAGE
local stealPage = Instance.new("Frame")
stealPage.Size = UDim2.new(1,0,1,0)
stealPage.BackgroundTransparency = 1
stealPage.Parent = content

local function makeButton(text, x, y)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 195, 0, 65)
    btn.Position = UDim2.new(0, x, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(35,35,35)
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.Parent = stealPage
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    return btn
end

local senaBtn = makeButton("SENA HUB\nLOAD", 10, 20)
local chilliBtn = makeButton("CHILLI HUB\nLOAD", 215, 20)
local ubBtn = makeButton("UB HUB\nLOAD", 10, 100)
local renzBtn = makeButton("RENZ HUB\nLOAD", 215, 100)

-- LOADSTRINGS
senaBtn.MouseButton1Click:Connect(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/senarbitx/sena/refs/heads/main/loader"))() end)
chilliBtn.MouseButton1Click:Connect(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/tienkhanht/spicy/main/Chilli.lua"))() end)
ubBtn.MouseButton1Click:Connect(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/TeamUBHub/UBLoader/refs/heads/main/Loader.lua"))() end)
renzBtn.MouseButton1Click:Connect(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/RENZHUB-Z/RENZ_HUB_V1/main/VMAX-HAHAHA.lua"))() end)

-- TAB LOGIC
btnSteal.MouseButton1Click:Connect(function()
    stealPage.Visible=true creatorPage.Visible=false
    btnSteal.BackgroundColor3=Color3.fromRGB(110,60,255)
    btnCreator.BackgroundColor3=Color3.fromRGB(35,35,35)
    btnShader.BackgroundColor3=Color3.fromRGB(35,35,35)
end)
btnCreator.MouseButton1Click:Connect(function()
    stealPage.Visible=false creatorPage.Visible=true
    btnCreator.BackgroundColor3=Color3.fromRGB(110,60,255)
    btnSteal.BackgroundColor3=Color3.fromRGB(35,35,35)
    btnShader.BackgroundColor3=Color3.fromRGB(35,35,35)
end)
