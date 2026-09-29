local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local introGui = Instance.new("ScreenGui")
introGui.Name = "RenzHubIntro"
introGui.IgnoreGuiInset = true
introGui.ResetOnSpawn = false
introGui.DisplayOrder = 999
introGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local bgFrame = Instance.new("Frame")
bgFrame.Size = UDim2.new(1, 0, 1, 0)
bgFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
bgFrame.BackgroundTransparency = 1
bgFrame.BorderSizePixel = 0
bgFrame.Parent = introGui

local logoImage = Instance.new("ImageLabel")
logoImage.Size = UDim2.new(1, 0, 1, 0)
logoImage.Position = UDim2.new(0.5, 0, 0.5, 0)
logoImage.AnchorPoint = Vector2.new(0.5, 0.5)
logoImage.BackgroundTransparency = 1
logoImage.Image = "rbxassetid://85660407447010"
logoImage.ImageTransparency = 1
logoImage.ScaleType = Enum.ScaleType.Fit
logoImage.Parent = bgFrame

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(0, 600, 0, 70)
titleText.Position = UDim2.new(0.5, 0, 0.65, 0)
titleText.AnchorPoint = Vector2.new(0.5, 0.5)
titleText.BackgroundTransparency = 1
titleText.Text = "RENZ HUB 🤑😎| VMAX"
titleText.TextColor3 = Color3.fromRGB(255, 204, 0)
titleText.Font = Enum.Font.GothamBold
titleText.TextScaled = true
titleText.TextTransparency = 1
titleText.Parent = bgFrame

local subText = Instance.new("TextLabel")
subText.Size = UDim2.new(0, 350, 0, 35)
subText.Position = UDim2.new(0.5, 0, 0.71, 0)
subText.AnchorPoint = Vector2.new(0.5, 0.5)
subText.BackgroundTransparency = 1
subText.Text = "[ RENZ HUB ]"
subText.TextColor3 = Color3.fromRGB(255, 255, 255)
subText.Font = Enum.Font.GothamBold
subText.TextScaled = true
subText.TextTransparency = 1
subText.Parent = bgFrame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255, 204, 0)
stroke.Thickness = 1.5
stroke.Transparency = 0.5
stroke.Parent = subText

local
