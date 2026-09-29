-- RENZ HUB VMAX - DRAGGABLE + TOGGLEABLE + EXIT/BACK - REAL ANTI-CHASE
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "RenzHubFinal"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- DRAG FUNCTION
local function makeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragInput, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- LEFT BEE BOX - DRAGGABLE + TOGGLE BUTTON
local beeLeft = Instance.new("ImageButton")
beeLeft.Name = "BeeToggle"
beeLeft.Size = UDim2.new(0,80,0,80)
beeLeft.Position = UDim2.new(0,15,0.48,0)
beeLeft.BackgroundColor3 = Color3.fromRGB(10,10,10)
beeLeft.BorderSizePixel = 0
beeLeft.Parent = gui
Instance.new("UICorner",beeLeft).CornerRadius = UDim.new(0,18)
local sL = Instance.new("UIStroke",beeLeft)
sL.Color = Color3.fromRGB(255,204,0)
sL.Thickness = 3
local iL = Instance.new("TextLabel")
iL.Size = UDim2.new(1,0,1,0)
iL.BackgroundTransparency = 1
iL.Text = "RENZ HUB 😎🤑"
iL.TextScaled = true
iL.Parent = beeLeft
makeDraggable(beeLeft)

-- RIGHT PANEL
local panel = Instance.new("Frame")
panel.Name = "MainPanel"
panel.Size = UDim2.new(0,380,0,170)
panel.Position = UDim2.new(1,-20,0,70)
panel.AnchorPoint = Vector2.new(1,0)
panel.BackgroundColor3 = Color3.fromRGB(10,10,20)
panel.BorderSizePixel = 0
panel.Parent = gui
Instance.new("UICorner",panel).CornerRadius = UDim.new(0,16)
local sR = Instance.new("UIStroke",panel)
sR.Color = Color3.fromRGB(255,210,70)
sR.Thickness = 3

-- TITLE BAR - DRAG HANDLE
local titleBar = Instance.new("Frame")
titleBar.Name = "DragBar"
titleBar.Size = UDim2.new(1,0,0,40)
titleBar.BackgroundTransparency = 1
titleBar.Parent = panel

local titleP = Instance.new("TextLabel")
titleP.Size = UDim2.new(1,-80,0,35)
titleP.Position = UDim2.new(0,10,0,5)
titleP.BackgroundTransparency = 1
titleP.Text = "RENZ HUB | ANTI-CHASE"
titleP.TextColor3 = Color3.fromRGB(255,220,80)
titleP.Font = Enum.Font.GothamBold
titleP.TextSize = 14
titleP.TextXAlignment = Enum.TextXAlignment.Left
titleP.Parent = titleBar

-- EXIT BUTTON X
local btnExit = Instance.new("TextButton")
btnExit.Name = "Exit"
btnExit.Size = UDim2.new(0,30,0,30)
btnExit.Position = UDim2.new(1,-35
