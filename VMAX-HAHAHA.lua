-- RENZ HUB VMAX EDITION - CONVERTED FROM BEE HUB
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local introGui = Instance.new("ScreenGui")
introGui.Name = "RenzVMAX"
introGui.IgnoreGuiInset = true
introGui.ResetOnSpawn = false
introGui.DisplayOrder = 999
introGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local bgFrame = Instance.new("Frame")
bgFrame.Size = UDim2.new(1, 0, 1, 0)
bgFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
bgFrame.BackgroundTransparency = 1
bgFrame.Parent = introGui

local logoImage = Instance.new("ImageLabel")
logoImage.Size = UDim2.new(0, 200, 0, 200)
logoImage.Position = UDim2.new(0.5, 0, 0.5, -30)
logoImage.AnchorPoint = Vector2.new(0.5, 0.5)
logoImage.BackgroundTransparency = 1
logoImage.Image = "rbxassetid://85660407447010"
logoImage.ImageTransparency = 1
logoImage.Parent = bgFrame

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(0, 600, 0, 70)
titleText.Position = UDim2.new(0.5, 0, 0.65, 0)
titleText.AnchorPoint = Vector2.new(0.5, 0.5)
titleText.BackgroundTransparency = 1
titleText.Text = "RENZ HUB 🥶 | VMAX HAHAHA"
titleText.TextColor3 = Color3.fromRGB(0, 140, 255)
titleText.Font = Enum.Font.GothamBold
titleText.TextScaled = true
titleText.TextTransparency = 1
titleText.Parent = bgFrame

local subText = Instance.new("TextLabel")
subText.Size = UDim2.new(0, 350, 0, 35)
subText.Position = UDim2.new(0.5, 0, 0.71, 0)
subText.AnchorPoint = Vector2.new(0.5, 0.5)
subText.BackgroundTransparency = 1
subText.Text = "[ RENZ HUB VMAX ]"
subText.TextColor3 = Color3.fromRGB(255, 255, 255)
subText.Font = Enum.Font.GothamBold
subText.TextScaled = true
subText.TextTransparency = 1
subText.Parent = bgFrame

local function createTween(obj, time, props)
    local tween = TweenService:Create(obj, TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
    tween:Play()
    return tween
end

createTween(bgFrame, 0.5, {BackgroundTransparency = 0})
task.wait(0.5)
createTween(logoImage, 1.5, {ImageTransparency = 0})
createTween(titleText, 1.5, {TextTransparency = 0})
createTween(subText, 1.5, {TextTransparency = 0})
task.wait(3.5)
createTween(bgFrame, 1, {BackgroundTransparency = 1})
createTween(logoImage, 1, {ImageTransparency = 1})
createTween(titleText, 1, {TextTransparency = 1})
createTween(subText, 1, {TextTransparency = 1})
task.wait(1)
introGui:Destroy()

print("RENZ HUB VMAX HAHAHA loaded!")
-- Dito mo idugtong yung main hub mo kung gusto mo
loadstring(game:HttpGet("https://raw.githubusercontent.com/RENZHUB-Z/RENZ_HUB_V1/main/loader.lua"))()
