local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

pcall(function() playerGui:FindFirstChild("RENZ_HUB_V1"):Destroy() end)

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RENZ_HUB_V1"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 650, 0, 500)
mainFrame.Position = UDim2.new(0.5, -325, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)
local stroke = Instance.new("UIStroke", mainFrame)
stroke.Color = Color3.fromRGB(138, 43, 226)
stroke.Thickness = 2

local function makeButton(text, pos, parent)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0, 280, 0, 80)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.TextSize = 16
    btn.Font = Enum.Font.GothamBold
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    return btn
end

local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, -20, 0, 40)
title.Position = UDim2.new(0, 10, 0, 5)
title.BackgroundTransparency = 1
title.Text = "RENZ HUB V1 ANTI HIT"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextXAlignment = Enum.TextXAlignment.Left

-- PROFILE MO - YUNG LOGO
local profile = Instance.new("ImageLabel", mainFrame)
profile.Size = UDim2.new(0, 50, 0, 50)
profile.Position = UDim2.new(1, -100, 0, 5)
profile.BackgroundTransparency = 1
profile.Image = "rbxassetid://85660407447010"
Instance.new("UICorner", profile).CornerRadius = UDim.new(1, 0)

-- BUTTONS
local keylessBtn = makeButton("KEYLESS HUB\nLOAD", UDim2.new(0, 20, 0, 60), mainFrame)
local diabloBtn = makeButton("DIABLO SCRIPT\nLOAD", UDim2.new(0, 320, 0, 60), mainFrame)
local instantBtn = makeButton("INSTANT STEAL\nLOAD", UDim2.new(0, 20, 0, 160), mainFrame)
local senaBtn = makeButton("SENA HUB 5.2\nLOAD", UDim2.new(0, 320, 0, 160), mainFrame)
local chilliBtn = makeButton("CHILLI HUB\nLOAD", UDim2.new(0, 20, 0, 260), mainFrame)
local ubBtn = makeButton("UB HUB (BEST)\nLOAD", UDim2.new(0, 320, 0, 260), mainFrame)
local flowBtn = makeButton("FLOW AUTH\nLOAD", UDim2.new(0, 20, 0, 360), mainFrame)

-- CLOSE BUTTON
local closeBtn = Instance.new("TextButton", mainFrame)
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -40, 0, 10)
closeBtn.Text = "X"
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
closeBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)

-- WORKING SCRIPTS
keylessBtn.MouseButton1Click:Connect(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/Dodoyung24/script-core/main/Steal-An-Egg"))() end)
diabloBtn.MouseButton1Click:Connect(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/Tsuo7/Tsuohub/main/stealanegg"))() end)
instantBtn.MouseButton1Click:Connect(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/betdoyvaka/stealanegg/main/Loader.lua"))() end)
senaBtn.MouseButton1Click:Connect(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/senarbitx/sena/refs/heads/main/loader"))() end)
chilliBtn.MouseButton1Click:Connect(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/tienkhanht/spicy/main/Chilli.lua"))() end)
ubBtn.MouseButton1Click:Connect(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/TeamUBHub/UBLoader/refs/heads/main/Loader.lua"))() end)

flowBtn.MouseButton1Click:Connect(function()
    loadstring(game:HttpGet("https://flowauth.net/v1/loaders/a31003a235b2c0b904e90cc236eed925.lua"))()
    task.wait(3)
    for _, gui in pairs(game.CoreGui:GetDescendants()) do
        if gui:IsA("TextLabel") and gui.Text == "KHAY" then gui.Text = "RENZ HUB V1 ANTI HIT" end
        if (gui:IsA("ImageLabel") or gui:IsA("ImageButton")) and gui.Image ~= "" and gui.Image ~= "rbxassetid://85660407447010" then
             if string.find(gui.Parent.Name:lower(), "khay") or gui.Size.X.Offset < 200 then
                pcall(function() gui.Image = "rbxassetid://85660407447010" end)
             end
        end
    end
end)
