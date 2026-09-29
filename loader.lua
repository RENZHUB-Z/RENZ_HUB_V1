local player = game:GetService("Players").LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
pcall(function() playerGui:FindFirstChild("RENZ_HUB_V1"):Destroy() end)

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RENZ_HUB_V1"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 650, 0, 500)
mainFrame.Position = UDim2.new(0.5, -325, 0.5, -250)
mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)
local stroke = Instance.new("UIStroke", mainFrame)
stroke.Color = Color3.fromRGB(138, 43, 226)
stroke.Thickness = 2
stroke.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 40)
title.Position = UDim2.new(0, 15, 0, 5)
title.BackgroundTransparency = 1
title.Text = "RENZ HUB V1 ANTI HIT"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = mainFrame

local profile = Instance.new("ImageLabel")
profile.Size = UDim2.new(0, 50, 0, 50)
profile.Position = UDim2.new(1, -100, 0, 5)
profile.BackgroundTransparency = 1
profile.Parent = mainFrame
Instance.new("UICorner", profile).CornerRadius = UDim.new(1, 0)
pcall(function() profile.Image = "rbxassetid://85660407447010" end)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -40, 0, 10)
closeBtn.Text = "X"
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = mainFrame
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
closeBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -20, 1, -60)
scroll.Position = UDim2.new(0, 10, 0, 50)
scroll.BackgroundTransparency = 1
scroll.CanvasSize = UDim2.new(0, 0, 0, 600)
scroll.ScrollBarThickness = 8
scroll.ScrollBarImageColor3 = Color3.fromRGB(138, 43, 226)
scroll.Active = true
scroll.Parent = mainFrame

local function makeButton(text, x, y)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 280, 0, 80)
    btn.Position = UDim2.new(0, x, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255,255,255)
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
local flowBtn = makeButton("FLOW AUTH\nANTI HIT LOAD", 10, 310)

keylessBtn.MouseButton1Click:Connect(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/Dodoyung24/script-core/main/Steal-An-Egg"))() end)
diabloBtn.MouseButton1Click:Connect(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/Tsuo7/Tsuohub/main/stealanegg"))() end)
instantBtn.MouseButton1Click:Connect(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/betdoyvaka/stealanegg/main/Loader.lua"))() end)
senaBtn.MouseButton1Click:Connect(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/senarbitx/sena/refs/heads/main/loader"))() end)
chilliBtn.MouseButton1Click:Connect(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/tienkhanht/spicy/main/Chilli.lua"))() end)
ubBtn.MouseButton1Click:Connect(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/TeamUBHub/UBLoader/refs/heads/main/Loader.lua"))() end)
flowBtn.MouseButton1Click:Connect(function() loadstring(game:HttpGet("https://flowauth.net/v1/loaders/92535411e9fd2f0ce8e923e31c42c2ea.lua"))() end)
