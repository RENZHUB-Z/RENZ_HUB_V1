-- RENZ HUB SPEED | Toggleable 1-1000
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local NORMAL_SPEED = 16
local selectedSpeed = 200
local enabled = false

local gui = Instance.new("ScreenGui")
gui.Name = "RENZ_HUB_SPEED"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 260)
frame.Position = UDim2.new(0.5, -150, 0.5, -130)
frame.BackgroundColor3 = Color3.fromRGB(25,25,30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,12)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,50)
title.BackgroundTransparency = 1
title.Text = "RENZ HUB SPEED"
title.TextColor3 = Color3.new(1,1,1)
title.TextSize = 22
title.Font = Enum.Font.GothamBold
title.Parent = frame

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1,-20,0,30)
status.Position = UDim2.new(0,10,0,50)
status.BackgroundTransparency = 1
status.Text = "Status: OFF | Speed: 200"
status.TextColor3 = Color3.fromRGB(200,200,200)
status.TextSize = 14
status.Font = Enum.Font.Gotham
status.Parent = frame

local box = Instance.new("TextBox")
box.Size = UDim2.new(1,-20,0,40)
box.Position = UDim2.new(0,10,0,85)
box.BackgroundColor3 = Color3.fromRGB(40,40,45)
box.Text = "200"
box.PlaceholderText = "1 - 1000"
box.TextColor3 = Color3.new(1,1,1)
box.TextSize = 18
box.Font = Enum.Font.GothamBold
box.Parent = frame
Instance.new("UICorner", box).CornerRadius = UDim.new(0,8)

local onBtn = Instance.new("TextButton")
onBtn.Size = UDim2.new(0.5,-15,0,45)
onBtn.Position = UDim2.new(0,10,0,140)
onBtn.BackgroundColor3 = Color3.fromRGB(0,255,136)
onBtn.Text = "ON"
onBtn.TextColor3 = Color3.new(0,0,0)
onBtn.TextSize = 18
onBtn.Font = Enum.Font.GothamBold
onBtn.Parent = frame
Instance.new("UICorner", onBtn).CornerRadius = UDim.new(0,8)

local offBtn = Instance.new("TextButton")
offBtn.Size = UDim2.new(0.5,-15,0,45)
offBtn.Position = UDim2.new(0.5,5,0,140)
offBtn.BackgroundColor3 = Color3.fromRGB(255,80,80)
offBtn.Text = "OFF"
offBtn.TextColor3 = Color3.new(1,1,1)
offBtn.TextSize = 18
offBtn.Font = Enum.Font.GothamBold
offBtn.Parent = frame
Instance.new("UICorner", offBtn).CornerRadius = UDim.new(0,8)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(1,-20,0,35)
closeBtn.Position = UDim2.new(0,10,0,200)
closeBtn.BackgroundColor3 = Color3.fromRGB(60,60,65)
closeBtn.Text = "CLOSE"
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.TextSize = 14
closeBtn.Font = Enum.Font.Gotham
closeBtn.Parent = frame
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0,8)

local function getHumanoid()
  local char = player.Character or player.CharacterAdded:Wait()
  return char:FindFirstChildOfClass("Humanoid")
end

local function applySpeed()
  local hum = getHumanoid()
  if hum then
    hum.WalkSpeed = enabled and selectedSpeed or NORMAL_SPEED
  end
end

box.FocusLost:Connect(function()
  local num = tonumber(box.Text)
  if num then
    num = math.clamp(math.floor(num), 1, 1000)
    selectedSpeed = num
    box.Text = tostring(num)
    status.Text = (enabled and "Status: ON | " or "Status: OFF | ").."Speed: "..num
    if enabled then applySpeed() end
  end
end)

onBtn.MouseButton1Click:Connect(function()
  enabled = true
  applySpeed()
  status.Text = "Status: ON | Speed: "..selectedSpeed
end)

offBtn.MouseButton1Click:Connect(function()
  enabled = false
  applySpeed()
  status.Text = "Status: OFF | Speed: "..selectedSpeed
end)

closeBtn.MouseButton1Click:Connect(function()
  enabled = false
  applySpeed()
  gui:Destroy()
end)

player.CharacterAdded:Connect(function()
  task.wait(0.5)
  if enabled then applySpeed() end
end)

-- Keep speed (pag may anti-speed na bumabalik sa 16)
task.spawn(function()
  while gui.Parent do
    task.wait(0.3)
    if enabled then
      local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
      if hum and hum.WalkSpeed ~= selectedSpeed then
        hum.WalkSpeed = selectedSpeed
      end
    end
  end
end)
