local player = game:GetService("Players").LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
pcall(function() playerGui:FindFirstChild("RENZ_HUB_V1"):Destroy() end)

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RENZ_HUB_V1"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- LOGO MO BOSS
local LOGO_ID = "rbxassetid://85660407447010"

-- MALAKING BOX
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 650, 0, 500)
mainFrame.Position = UDim2.new(0.5, -325, 0.5, -250)
mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)
local stroke = Instance.new("UIStroke", mainFrame)
stroke.Color = Color3.fromRGB(0, 140, 255)
stroke.Thickness = 2
stroke.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -80, 0, 40)
title.Position = UDim2.new(0, 15, 0, 5)
title.BackgroundTransparency = 1
title.Text = "RENZ HUB V1 ANTI HIT"
title.TextColor3 = Color3.fromRGB(0, 180, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = mainFrame

local profile = Instance.new("ImageLabel")
profile.Size = UDim2.new(0, 50, 0, 50)
profile.Position = UDim2.new(1, -100, 0, 5)
profile.BackgroundTransparency = 1
profile.Image = LOG
