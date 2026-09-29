-- RENZ HUB VMAX - BEE HUB UI EDITION - FINAL
-- Features: Tap Egg + Double Click = Anti Chase / Single Tap = Teleport to Safe Zone
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- INTRO RENZ HUB
local introGui = Instance.new("ScreenGui")
introGui.Name = "RenzIntro"
introGui.IgnoreGuiInset = true
introGui.ResetOnSpawn = false
introGui.DisplayOrder = 999
introGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
local bgFrame = Instance.new("Frame")
bgFrame.Size = UDim2.new(1,0,1,0)
bgFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
bgFrame.BackgroundTransparency = 1
bgFrame.Parent = introGui
local logoImage = Instance.new("ImageLabel")
logoImage.Size = UDim2.new(0,200,0,200)
logoImage.Position = UDim2.new(0.5,0,0.5,-40)
logoImage.AnchorPoint = Vector2.new(0.5,0.5)
logoImage.BackgroundTransparency = 1
logoImage.Image = "rbxassetid://85660407447010"
logoImage.ImageTransparency = 1
logoImage.Parent = bgFrame
local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(0,600,0,70)
titleText.Position = UDim2.new(0.5,0,0.65,0)
titleText.AnchorPoint = Vector2.new(0.5,0.5)
titleText.BackgroundTransparency = 1
titleText.Text = "RENZ HUB"
titleText.TextColor3 = Color3.fromRGB(0,140,255)
titleText.Font = Enum.Font.GothamBold
titleText.TextScaled = true
titleText.TextTransparency = 1
titleText.Parent = bgFrame
local function createTween(obj,time,props)
    local t = TweenService:Create(obj,TweenInfo.new(time,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),props)
    t:Play() return t
end
createTween(bgFrame,0.5,{BackgroundTransparency=0})
task.wait(0.5)
createTween(logoImage,1.5,{ImageTransparency=0})
createTween(titleText,1.5,{TextTransparency=0})
task.wait(3)
createTween(bgFrame,1,{BackgroundTransparency=1})
createTween(logoImage,1,{ImageTransparency=1})
createTween(titleText,1,{TextTransparency=1})
task.wait(1)
introGui:Destroy()

-- UI - BEE HUB HELPER
local mainGui = Instance.new("ScreenGui")
mainGui.Name = "BeeHubUI"
mainGui.ResetOnSpawn = false
mainGui.IgnoreGuiInset = true
mainGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- LEFT BEE BUTTON (Yung nasa screenshot mo)
local beeButton = Instance.new("ImageButton")
beeButton.Name = "BeeButton"
beeButton.Size = UDim2.new(0,70,0,70)
beeButton.Position = UDim2.new(0,15,0.5,-35)
beeButton.BackgroundColor3 = Color3.fromRGB(0,0,0)
beeButton.BorderSizePixel = 0
beeButton.Parent = mainGui
local beeCorner = Instance.new("UICorner",beeButton)
beeCorner.CornerRadius = UDim.new(0,18)
local beeStroke = Instance.new("UIStroke",beeButton)
beeStroke.Color = Color3.fromRGB(255,204,0)
beeStroke.Thickness = 3
local beeIcon = Instance.new("TextLabel")
beeIcon.Size = UDim2.new(1,0,1,0)
beeIcon.BackgroundTransparency = 1
beeIcon.Text = "🐝"
beeIcon.TextScaled = true
beeIcon.Font = Enum.Font.GothamBold
beeIcon.Parent = beeButton

-- RIGHT PANEL (BEE HUB | HELPER | ANTI-CHASE)
local rightPanel = Instance.new("Frame")
rightPanel.Size = UDim2.new(0,280,0,90)
rightPanel.Position = UDim2.new(1,-20,0,60)
rightPanel.AnchorPoint = Vector2.new(1,0)
rightPanel.BackgroundColor3 = Color3.fromRGB(15,15,15)
rightPanel.BorderSizePixel = 0
rightPanel.Parent = mainGui
Instance.new("UICorner",rightPanel).CornerRadius = UDim.new(0,12)
local panelStroke = Instance.new("UIStroke",rightPanel)
panelStroke.Color = Color3.fromRGB(255,204,0)
panelStroke.Thickness = 2

local panelTitle = Instance.new("TextLabel")
panelTitle.Size = UDim2.new(1,-10,0,30)
panelTitle.Position = UDim2.new(0,5,0,5)
panelTitle.BackgroundTransparency = 1
panelTitle.Text = "BEE HUB 🐝 | HELPER | ANTI-CHASE"
panelTitle.TextColor3 = Color3.fromRGB(255,204,0)
panelTitle.Font = Enum.Font.GothamBold
panelTitle.TextSize = 12
panelTitle.Parent = rightPanel

local statusText = Instance.new("TextLabel")
statusText.Name = "Status"
statusText.Size = UDim2.new(1,-10,0,50)
statusText.Position = UDim2.new(0,5,0,35)
statusText.BackgroundTransparency = 1
statusText.Text = "WAS TELEPORT OFF 🥚\nTap Egg First!"
statusText.TextColor3 = Color3.fromRGB(255,255,255)
statusText.Font = Enum.Font.GothamBold
statusText.TextSize = 14
statusText.TextWrapped = true
statusText.Parent = rightPanel

-- LOGIC
local hasEgg = false
local lastClick = 0
local isAntiChaseOn = false

local antiChaseSpots = {
    Vector3.new(500.62, 70.28, -366.71),
    Vector3.new(508.3, 70.28, -366.02),
    Vector3.new(519.43, 70.28, -366.47),
    Vector3.new(529.22, 70.28, -366.71),
    Vector3.new(546.8, 70.28, -364.4),
}

local function getSafeZone()
    -- Hanapin SafeZone ng player
    local char = LocalPlayer.Character
    if not char then return nil end
    -- Try hanapin SAFE ZONE text part
    for _,v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Name:lower():find("safe") then
            return v.CFrame + Vector3.new(0,5,0)
        end
    end
    -- Fallback - base ng player or 0,0
    if Workspace:FindFirstChild("Plots") then
        for _,plot in ipairs(Workspace.Plots:GetChildren()) do
            local owner = plot:FindFirstChild("Owner") or plot:FindFirstChild("PlotOwner")
            if owner and owner.Value == LocalPlayer then
                return plot:GetPivot() + Vector3.new(0,5,0)
            end
        end
    end
    return CFrame.new(0,10,0)
end

local function doAntiChase()
    local char = LocalPlayer.Character
    if not char then return end
    isAntiChaseOn = true
    statusText.Text = "TELEPORT ON 🏃 RUNNING!"
    statusText.TextColor3 = Color3.fromRGB(0,255,100)
    for i,pos in ipairs(antiChaseSpots) do
        char:PivotTo(CFrame.new(pos))
        RunService.Heartbeat:Wait()
    end
    statusText.Text = "ANTI-CHASE DONE ✅"
    task.wait(1)
    statusText.Text = "WAS TELEPORT OFF 🥚"
    statusText.TextColor3 = Color3.fromRGB(255,255,255)
    isAntiChaseOn = false
end

local function doSafeTeleport()
    if not hasEgg then
        statusText.Text = "❌ NO EGG! TAP EGG FIRST 🥚"
        statusText.TextColor3 = Color3.fromRGB(255,50,50)
        task.wait(2)
        statusText.Text = "WAS TELEPORT OFF 🥚\nTap Egg First!"
        statusText.TextColor3 = Color3.fromRGB(255,255,255)
        return
    end
    local char = LocalPlayer.Character
    if not char then return end
    statusText.Text = "TELEPORTING TO SAFE ZONE..."
    statusText.TextColor3 = Color3.fromRGB(0,200,255)
    local safeCf = getSafeZone()
    -- Hanapin yung malaking SAFE ZONE sa map (galing sa vid mo)
    local safeParts = {}
    for _,v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("TextLabel") and v.Text:lower():find("safe zone") then
            table.insert(safeParts, v.Parent)
        end
    end
    char:PivotTo(safeCf)
    task.wait(0.2)
    char:PivotTo(safeCf + Vector3.new(0,0,20))
    statusText.Text = "SAFE ZONE TELEPORT DONE ✅"
    statusText.TextColor3 = Color3.fromRGB(0,255,100)
    hasEgg = false
    task.wait(2)
    statusText.Text = "WAS TELEPORT OFF 🥚\nTap Egg First!"
    statusText.TextColor3 = Color3.fromRGB(255,255,255)
end

-- Detect pag nag Steal ng Egg
ProximityPromptService.PromptTriggered:Connect(function(prompt,player)
    if player ~= LocalPlayer then return end
    if prompt.ObjectText:lower():find("steal") or prompt.ActionText:lower():find("steal") then
        hasEgg = true
        statusText.Text = "🥚 EGG GRABBED! READY!"
        statusText.TextColor3 = Color3.fromRGB(255,204,0)
        beeButton.BackgroundColor3 = Color3.fromRGB(40,40,0)
        task.wait(0.5)
        TweenService:Create(beeStroke,TweenInfo.new(0.3,Enum.EasingStyle.Quad,Enum.EasingDirection.InOut),{Thickness=5}):Play()
        task.wait(0.3)
        TweenService:Create(beeStroke,TweenInfo.new(0.3),{Thickness=3}):Play()
    end
end)

-- BEE HUB BUTTON LOGIC - SINGLE / DOUBLE CLICK
beeButton.MouseButton1Click:Connect(function()
    local now = tick()
    local diff = now - lastClick
    
    if diff < 0.4 then
        -- DOUBLE CLICK = ANTI CHASE (galing sa vid mo #1)
        print("DOUBLE CLICK - ANTI CHASE")
        doAntiChase()
    else
        -- SINGLE CLICK = TELEPORT TO SAFE ZONE (galing sa vid mo #2)
        -- Delay konti para ma-detect kung double
        task.wait(0.45)
        if tick() - lastClick >= 0.4 then
            print("SINGLE CLICK - SAFE ZONE TP")
            doSafeTeleport()
        end
    end
    lastClick = now
end)

-- Instant Prompt + Floor Steal B
task.spawn(function()
    local function firePrompt(p)
        if fireproximityprompt then pcall(function() fireproximityprompt(p,0) end) end
    end
    for _,v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("ProximityPrompt") then v.HoldDuration = 0 v.RequiresLineOfSight = false end
    end
    Workspace.DescendantAdded:Connect(function(v)
        if v:IsA("ProximityPrompt") then v.HoldDuration = 0 v.RequiresLineOfSight = false end
    end)
end)

print("RENZ HUB BEE UI LOADED - 1. Tap Egg 2. Double Click Bee = Anti Chase / Single = Safe Zone")
