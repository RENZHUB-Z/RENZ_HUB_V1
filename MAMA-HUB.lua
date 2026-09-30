-- RENZ HUB | MADE BY RENZ - INTRO

-- 1. INTRO NOTIFICATION
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "RENZ HUB",
    Text = "MADE BY RENZ - Loading...",
    Duration = 5,
    Icon = "rbxassetid://4483362458"
})

-- 2. INTRO GUI (Kita sa screen)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RenzHubIntro"
ScreenGui.Parent = game.CoreGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 350, 0, 150)
Frame.Position = UDim2.new(0.5, -175, 0.5, -75)
Frame.BackgroundColor3 = Color3.fromRGB(15, 25, 35)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

local UICorner = Instance.new("UICorner", Frame)
UICorner.CornerRadius = UDim.new(0, 12)

local UIStroke = Instance.new("UIStroke", Frame)
UIStroke.Color = Color3.fromRGB(0, 255, 136)
UIStroke.Thickness = 3

local Title = Instance.new("TextLabel")
Title.Text = "RENZ HUB"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 28
Title.TextColor3 = Color3.fromRGB(0, 255, 136)
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, 0, 0.5, 0)
Title.Parent = Frame

local MadeBy = Instance.new("TextLabel")
MadeBy.Text = "MADE BY RENZ"
MadeBy.Font = Enum.Font.GothamBold
MadeBy.TextSize = 18
MadeBy.TextColor3 = Color3.fromRGB(0, 170, 255)
MadeBy.BackgroundTransparency = 1
MadeBy.Size = UDim2.new(1, 0, 0.5, 0)
MadeBy.Position = UDim2.new(0, 0, 0.5, 0)
MadeBy.Parent = Frame

wait(3) -- 3 seconds intro
ScreenGui:Destroy()

-- 3. LOAD YUNG MADAMING SCRIPT
loadstring(game:HttpGet("https://raw.githubusercontent.com/sabscrip-arch/srver/refs/heads/main/Stealanegg"))()
