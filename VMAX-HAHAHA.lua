-- RENZ HUB VMAX - FIXED ANTI-CHASE (Hindi na malaglag egg)
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "RenzHub"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- LEFT BEE BUTTON
local beeLeft = Instance.new("ImageButton")
beeLeft.Size = UDim2.new(0,75,0,75)
beeLeft.Position = UDim2.new(0,15,0.48,0)
beeLeft.BackgroundColor3 = Color3.fromRGB(10,10,10)
beeLeft.BorderSizePixel = 0
beeLeft.Parent = gui
Instance.new("UICorner",beeLeft).CornerRadius = UDim.new(0,18)
local strokeL = Instance.new("UIStroke",beeLeft)
strokeL.Color = Color3.fromRGB(255,204,0)
strokeL.Thickness = 3
local iconL = Instance.new("TextLabel")
iconL.Size = UDim2.new(1,0,1,0)
iconL.BackgroundTransparency = 1
iconL.Text = "RENZ HUB"
iconL.TextScaled = true
iconL.Parent = beeLeft

-- RIGHT PANEL - KATULAD SA PIC MO
local panel = Instance.new("Frame")
panel.Size = UDim2.new(0,380,0,160)
panel.Position = UDim2.new(1,-20,0,70)
panel.AnchorPoint = Vector2.new(1,0)
panel.BackgroundColor3 = Color3.fromRGB(10,10,20)
panel.BorderSizePixel = 0
panel.Parent = gui
Instance.new("UICorner",panel).CornerRadius = UDim.new(0,16)
local strokeR = Instance.new("UIStroke",panel)
strokeR.Color = Color3.fromRGB(255,210,70)
strokeR.Thickness = 3

local titlePanel = Instance.new("TextLabel")
titlePanel.Size = UDim2.new(1,-20,0,35)
titlePanel.Position = UDim2.new(0,10,0,8)
titlePanel.BackgroundTransparency = 1
titlePanel.Text = "RENZ HUB | HELPER | ANTI-CHASE"
titlePanel.TextColor3 = Color3.fromRGB(255,220,80)
titlePanel.Font = Enum.Font.GothamBold
titlePanel.TextSize = 15
titlePanel.Parent = panel

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1,-20,0,30)
status.Position = UDim2.new(0,10,0,50)
status.BackgroundTransparency = 1
status.Text = "WAS TELEPORT OFF 🥚"
status.TextColor3 = Color3.fromRGB(255,220,80)
status.Font = Enum.Font.GothamBold
status.TextSize = 18
status.Parent = panel

local btnTP = Instance.new("TextButton")
btnTP.Size = UDim2.new(0.48,0,0,50)
btnTP.Position = UDim2.new(0,10,0,95)
btnTP.BackgroundColor3 = Color3.fromRGB(30,30,30)
btnTP.Text = "SAFE TP"
btnTP.TextColor3 = Color3.fromRGB(255,255,255)
btnTP.Font = Enum.Font.GothamBold
btnTP.TextSize = 16
btnTP.Parent = panel
Instance.new("UICorner",btnTP).CornerRadius = UDim.new(0,10)
Instance.new("UIStroke",btnTP).Color = Color3.fromRGB(0,200,255)

local btnAnti = Instance.new("TextButton")
btnAnti.Size = UDim2.new(0.48,0,0,50)
btnAnti.Position = UDim2.new(0.52,0,0,95)
btnAnti.BackgroundColor3 = Color3.fromRGB(30,30,30)
btnAnti.Text = "ANTI-CHASE"
btnAnti.TextColor3 = Color3.fromRGB(255,255,255)
btnAnti.Font = Enum.Font.GothamBold
btnAnti.TextSize = 14
btnAnti.Parent = panel
Instance.new("UICorner",btnAnti).CornerRadius = UDim.new(0,10)
Instance.new("UIStroke",btnAnti).Color = Color3.fromRGB(255,204,0)

local hasEgg = false
local lastClick = 0

local function getSafe()
    for _,v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Name:lower():find("safe") then
            return v.CFrame + Vector3.new(0,6,0)
        end
    end
    if Workspace:FindFirstChild("Plots") then
        for _,plot in ipairs(Workspace.Plots:GetChildren()) do
            local o = plot:FindFirstChild("Owner") or plot:FindFirstChild("PlotOwner")
            if o and o.Value == LocalPlayer then
                return plot:GetPivot() + Vector3.new(0,5,0)
            end
        end
    end
    return CFrame.new(0,10,0)
end

local function safeTP()
    if not hasEgg then status.Text = "❌ TAP EGG FIRST 🥚" task.wait(1.5) status.Text = "WAS TELEPORT OFF 🥚" return end
    local char = LocalPlayer.Character
    if not char then return end
    status.Text = "TELEPORTING... 🌀"
    local cf = getSafe()
    char:PivotTo(cf)
    task.wait(0.2)
    char:PivotTo(cf + Vector3.new(0,0,15))
    status.Text = "SAFE ZONE DONE ✅"
    hasEgg = false
    task.wait(2)
    status.Text = "WAS TELEPORT OFF 🥚"
end

-- FIXED ANTI-CHASE - MALAPIT LANG, DI MALALAGLAG EGG
local function antiChase()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    
    status.Text = "ANTI-CHASE ON 🏃💨"
    btnAnti.BackgroundColor3 = Color3.fromRGB(255,204,0)
    btnAnti.TextColor3 = Color3.fromRGB(0,0,0)
    
    -- 10x na maliliit na teleport sa paligid lang - pang lito sa kalaban
    for i=1,12 do
        local randomAngle = math.random()*math.pi*2
        local randomDist = math.random(8,20) -- MALAPIT LANG 8-20 studs lang
        local offset = Vector3.new(math.cos(randomAngle)*randomDist, 0, math.sin(randomAngle)*randomDist)
        local newPos = hrp.Position + offset
        
        char:PivotTo(CFrame.new(newPos + Vector3.new(0,3,0)))
        RunService.Heartbeat:Wait()
        task.wait(0.08)
    end
    
    status.Text = "ANTI-CHASE DONE ✅"
    btnAnti.BackgroundColor3 = Color3.fromRGB(30,30,30)
    btnAnti.TextColor3 = Color3.fromRGB(255,255,255)
    task.wait(1.5)
    status.Text = "WAS TELEPORT OFF 🥚"
end

local function handleBeePress()
    local now = tick()
    if now - lastClick < 0.35 then
        antiChase()
    else
        task.wait(0.4)
        if tick() - lastClick >= 0.35 then
            safeTP()
        end
    end
    lastClick = tick()
end

beeLeft.MouseButton1Click:Connect(handleBeePress)
btnTP.MouseButton1Click:Connect(safeTP)
btnAnti.MouseButton1Click:Connect(antiChase)

ProximityPromptService.PromptTriggered:Connect(function(p,plr)
    if plr ~= LocalPlayer then return end
    if p.ObjectText:lower():find("steal") or p.ActionText:lower():find("steal") then
        hasEgg = true
        status.Text = "🥚 EGG GRABBED! READY!"
        beeLeft.BackgroundColor3 = Color3.fromRGB(50,40,0)
    end
end)

for _,v in ipairs(Workspace:GetDescendants()) do
    if v:IsA("ProximityPrompt") then v.HoldDuration = 0 v.RequiresLineOfSight = false end
end
Workspace.DescendantAdded:Connect(function(v)
    if v:IsA("ProximityPrompt") then v.HoldDuration = 0 v.RequiresLineOfSight = false end
end)

print("RENZ HUB FIXED - Anti-Chase no longer drops egg")
