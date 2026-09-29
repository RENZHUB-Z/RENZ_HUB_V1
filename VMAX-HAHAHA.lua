-- RENZ HUB INTRO + ANTI-HIT - FINAL FIXED
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
bgFrame.Parent = introGui

local logoImage = Instance.new("ImageLabel")
logoImage.Size = UDim2.new(0, 200, 0, 200)
logoImage.Position = UDim2.new(0.5, 0, 0.5, -40)
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
titleText.Text = "RENZ HUB"
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
subText.Text = "[ RENZ HUB ]"
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

local flag = false
local spots = {
    Vector3.new(500.62, 70.28, -366.71),
    Vector3.new(508.3, 70.28, -366.02),
    Vector3.new(519.43, 70.28, -366.47),
    Vector3.new(529.22, 70.28, -366.71),
    Vector3.new(546.8, 70.28, -364.4),
}
ProximityPromptService.PromptTriggered:Connect(function(prompt, player)
    if player ~= LocalPlayer or flag then return end
    local char = LocalPlayer.Character
    if not char then return end
    flag = true
    for i, pos in ipairs(spots) do
        char:PivotTo(CFrame.new(pos))
        if i < #spots then RunService.Heartbeat:Wait() end
    end
    flag = false
end)

task.spawn(function()
    local function firePrompt(p)
        if fireproximityprompt then pcall(function() fireproximityprompt(p, 0) end) end
    end
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("ProximityPrompt") then v.HoldDuration = 0 v.RequiresLineOfSight = false end
    end
    Workspace.DescendantAdded:Connect(function(v)
        if v:IsA("ProximityPrompt") then v.HoldDuration = 0 v.RequiresLineOfSight = false end
    end)
    ProximityPromptService.PromptButtonHoldBegan:Connect(firePrompt)
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe or input.KeyCode ~= Enum.KeyCode.B then return end
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("ProximityPrompt") and v.Enabled then
                local part = v:FindFirstAncestorOfClass("BasePart") or v.Parent
                if part and part:IsA("BasePart") and (hrp.Position - part.Position).Magnitude <= 35 then
                    firePrompt(v)
                end
            end
        end
    end)
    print("RENZ HUB LOADED - Press B")
end)
