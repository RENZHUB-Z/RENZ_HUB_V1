-- RENZ HUB VMAX FINAL - FULL SCRIPT - LOGO 85660407447010
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
titleText.Text = "RENZ HUB | VMAX"
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

local function createTween(obj, time, props)
    local t = TweenService:Create(obj, TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
    t:Play()
    return t
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

local function showNotification(text, isTop)
    local notifGui = Instance.new("ScreenGui")
    notifGui.Name = "RenzHubNotifs"
    notifGui.IgnoreGuiInset = true
    notifGui.ResetOnSpawn = false
    notifGui.DisplayOrder = 1000
    notifGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    local notifFrame = Instance.new("Frame")
    notifFrame.Size = UDim2.new(0, 350, 0, 50)
    notifFrame.Position = UDim2.new(1, 400, 0, isTop and 0.35 or 0.45)
    notifFrame.AnchorPoint = Vector2.new(1, 0)
    notifFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    notifFrame.Parent = notifGui
    Instance.new("UIStroke", notifFrame).Color = Color3.fromRGB(255, 204, 0)
    local notifText = Instance.new("TextLabel")
    notifText.Size = UDim2.new(1, -20, 1, 0)
    notifText.Position = UDim2.new(0.5, 0, 0.5, 0)
    notifText.AnchorPoint = Vector2.new(0.5, 0.5)
    notifText.BackgroundTransparency = 1
    notifText.Text = text
    notifText.TextColor3 = Color3.fromRGB(255, 204, 0)
    notifText.Font = Enum.Font.GothamBold
    notifText.TextScaled = true
    notifText.Parent = notifFrame
    TweenService:Create(notifFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(1, -20, 0, isTop and 0.35 or 0.45)}):Play()
    task.wait(3.5)
    notifGui:Destroy()
end

task.spawn(function()
    showNotification("🐝 RENZ HUB INSTANT STEAL 🐝", true)
    task.wait(1)
    showNotification("🍯 RENZ HUB INSTANT GRAB 🍯", false)
end)

-- MAIN ANTI-CHASE LOGIC
local function getAntiChaseState() return true end
local updateInstancePropertiesData = {
    Vector3.new(500.62, 70.28, -366.71),
    Vector3.new(508.3, 70.28, -366.02),
    Vector3.new(519.43, 70.28, -366.47),
    Vector3.new(529.22, 70.28, -366.71),
    Vector3.new(546.8, 70.28, -364.4),
}
local flag = false
local function updateInstanceProperties(character)
    if not getAntiChaseState() then return end
    if not character or not character.Parent then return end
    for index, item in ipairs(updateInstancePropertiesData) do
        if not getAntiChaseState() then return end
        character:PivotTo(CFrame.new(item))
        if index < #updateInstancePropertiesData then RunService.Heartbeat:Wait() end
    end
end

ProximityPromptService.PromptTriggered:Connect(function(prompt, player)
    if player ~= LocalPlayer then return end
    if not getAntiChaseState() or flag then return end
    local character = LocalPlayer.Character
    if not character then return end
    flag = true
    updateInstanceProperties(character)
    flag = false
end)

task.spawn(function()
    local function firePrompt(prompt)
        if not prompt or not prompt.Parent then return end
        if fireproximityprompt then pcall(function() fireproximityprompt(prompt, 0) end) end
    end
    local function optimizePrompt(prompt)
        if prompt:IsA("ProximityPrompt") then
            prompt.HoldDuration = 0
            prompt.RequiresLineOfSight = false
        end
    end
    for _, desc in ipairs(Workspace:GetDescendants()) do optimizePrompt(desc) end
    Workspace.DescendantAdded:Connect(optimizePrompt)
    ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt) firePrompt(prompt) end)
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.B then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    for _, desc in ipairs(Workspace:GetDescendants()) do
                        if desc:IsA("ProximityPrompt") and desc.Enabled then
                            local part = desc:FindFirstAncestorOfClass("BasePart") or desc.Parent
                            if part and part:IsA("BasePart") then
                                if (hrp.Position - part.Position).Magnitude <= 35 then firePrompt(desc) end
                            end
                        end
                    end
                end
            end)
        end
    end)
    print("RENZ HUB VMAX LOADED")
end)
