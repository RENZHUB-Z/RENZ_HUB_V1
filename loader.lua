local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- DRAGGABLE FIX PANG MOBILE
local function MakeDraggable(frame, dragHandle)
    local UIS = game:GetService("UserInputService")
    local dragging, dragInput, dragStart, startPos
    dragHandle = dragHandle or frame
    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then update(input) end
    end)
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RENZ_HUB_V1"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- FLOATING ICON PARA MAKAPASOK ULET
local floatBtn = Instance.new("ImageButton")
floatBtn.Size = UDim2.new(0, 55, 0, 55)
floatBtn.Position = UDim2.new(0, 20, 0.5, -27)
floatBtn.Image = "rbxassetid://6031094670"
floatBtn.BackgroundColor3 = Color3.fromRGB(16,16,16)
floatBtn.Visible = false
floatBtn.Parent = screenGui
Instance.new("UICorner", floatBtn).CornerRadius = UDim.new(1,0)
local floatStroke = Instance.new("UIStroke", floatBtn)
floatStroke.Color = Color3.fromRGB(110,60,255)
floatStroke.Thickness = 2
MakeDraggable(floatBtn, floatBtn)

-- MAIN FRAME
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 580, 0, 380)
mainFrame.Position = UDim2.new(0.5, -290, 0.5, -190)
mainFrame.BackgroundColor3 = Color3.fromRGB(16,16,16)
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)
local stroke = Instance.new("UIStroke", mainFrame)
stroke.Color = Color3.fromRGB(110,60,255)
stroke.Thickness = 1.5
Instance.new("UIScale", mainFrame).Scale = 0.75

-- HEADER
local header = Instance.new("Frame")
header.Size = UDim2.new(1,0,0,45)
header.BackgroundTransparency = 1
header.Parent = mainFrame
MakeDraggable(mainFrame, header)

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

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 32, 0, 32)
closeBtn.Position = UDim2.new(1, -40, 0, 6)
closeBtn.Text = "X"
closeBtn.BackgroundColor3 = Color3.fromRGB(180,40,40)
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = header
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 32, 0, 32)
minBtn.Position = UDim2.new(1, -78, 0, 6)
minBtn.Text = "-"
minBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
minBtn.TextColor3 = Color3.new(1,1,1)
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 16
minBtn.Parent = header
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 6)

closeBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)
minBtn.MouseButton1Click:Connect(function() mainFrame.Visible = false floatBtn.Visible = true end)
floatBtn.MouseButton1Click:Connect(function() mainFrame.Visible = true floatBtn.Visible = false end)

-- SIDEBAR
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 140, 1, -55)
sidebar.Position = UDim2.new(0, 10, 0, 45)
sidebar.BackgroundColor3 = Color3.fromRGB(20,20,20)
sidebar.Parent = mainFrame
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 8)

local function makeSideBtn(text, y, active)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -10, 0, 38) b.Position = UDim2.new(0, 5, 0, y) b.Text = text
    b.BackgroundColor3 = active and Color3.fromRGB(110,60,255) or Color3.fromRGB(35,35,35)
    b.TextColor3 = Color3.new(1,1,1) b.Font = Enum.Font.GothamBold b.TextSize = 12 b.Parent = sidebar
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6) return b
end

local btnSteal = makeSideBtn("Steal An Egg", 10, true)
local btnShader = makeSideBtn("Shader", 55, false)
local btnCreator = makeSideBtn("Creator", 100, false)

-- CONTENT (MALAKING BOX)
local content = Instance.new("Frame")
content.Size = UDim2.new(1, -165, 1, -55) content.Position = UDim2.new(0, 155, 0, 45)
content.BackgroundColor3 = Color3.fromRGB(22,22,22) content.Parent = mainFrame
Instance.new("UICorner", content).CornerRadius = UDim.new(0, 8)

-- PAGES
local stealPage = Instance.new("Frame") stealPage.Size = UDim2.new(1,0,1,0) stealPage.BackgroundTransparency = 1 stealPage.Parent = content
local creatorPage = Instance.new("Frame") creatorPage.Size = UDim2.new(1,0,1,0) creatorPage.BackgroundColor3 = Color3.fromRGB(22,22,22) creatorPage.Visible = false creatorPage.Parent = content Instance.new("UICorner", creatorPage).CornerRadius = UDim.new(0, 8)

-- COPY SYSTEM
local function copyToClipboard(text)
    if setclipboard then
        setclipboard(text)
        game.StarterGui:SetCore("SendNotification", {Title = "RENZ HUB V1", Text = "Copied: " .. text, Duration = 2})
    end
end

local function makeCopyBtn(text, copyText, y)
    local btn = Instance.new("TextButton")
    btn.Text = text .. " [COPY]"
    btn.Size = UDim2.new(1, -20, 0, 36)
    btn.Position = UDim2.new(0, 10, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(35,35,35)
    btn.TextColor3 = Color3.fromRGB(220,220,220)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = creatorPage
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(function() copyToClipboard(copyText) end)
end

makeCopyBtn(" OWNER: RENZ / CRIZ", "RENZ / CRIZ", 15)
makeCopyBtn(" DISCORD: discord.gg/z8ycWNrrg", "https://discord.gg/z8ycWNrrg", 60)
makeCopyBtn(" TIKTOK: @official_l1amz", "https://www.tiktok.com/@official_l1amz", 105)
makeCopyBtn(" PROMOTER: official_l1amz", "official_l1amz", 150)

-- SCRIPTS BUTTONS SA MALAKING BOX
local function makeButton(text, x, y)
    local btn = Instance.new("TextButton") btn.Size = UDim2.new(0, 185, 0, 60) btn.Position = UDim2.new(0, x, 0, y) btn.BackgroundColor3 = Color3.fromRGB(35,35,35) btn.Text = text btn.TextColor3 = Color3.new(1,1,1) btn.Font = Enum.Font.GothamBold btn.TextSize = 11 btn.Parent = stealPage Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8) return btn
end

local senaBtn = makeButton("SENA HUB\nLOAD", 10, 20)
local chilliBtn = makeButton("CHILLI HUB\nLOAD", 205, 20)
local ubBtn = makeButton("UB HUB\nLOAD", 10, 95)
local renzBtn = makeButton("RENZ HUB\nLOAD", 205, 95)

senaBtn.MouseButton1Click:Connect(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/senarbitx/sena/refs/heads/main/loader"))() end)
chilliBtn.MouseButton1Click:Connect(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/tienkhanh1/spicy/main/Chilli.lua"))() end)
ubBtn.MouseButton1Click:Connect(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/TeamUBHub/UBLoader/refs/heads/main/Loader.lua"))() end)
renzBtn.MouseButton1Click:Connect(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/RENZHUB-Z/RENZ_HUB_V1/main/VMAX-HAHAHA.lua"))() end)

-- TAB LOGIC NASA BABA
btnSteal.MouseButton1Click:Connect(function() stealPage.Visible=true creatorPage.Visible=false btnSteal.BackgroundColor3=Color3.fromRGB(110,60,255) btnCreator.BackgroundColor3=Color3.fromRGB(35,35,35) btnShader.BackgroundColor3=Color3.fromRGB(35,35,35) end)
btnCreator.MouseButton1Click:Connect(function() stealPage.Visible=false creatorPage.Visible=true btnCreator.BackgroundColor3=Color3.fromRGB(110,60,255) btnSteal.BackgroundColor3=Color3.fromRGB(35,35,35) btnShader.BackgroundColor3=Color3.fromRGB(35,35,35) end)
