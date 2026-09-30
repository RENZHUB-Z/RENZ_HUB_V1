-- RENZ HUB | MADE BY RENZ - V3 FIX

-- 1. INTRO
local intro = Instance.new("ScreenGui")
intro.Name = "RenzIntro"
intro.Parent = game:GetService("CoreGui")
local f = Instance.new("Frame", intro)
f.Size = UDim2.new(0,350,0,150)
f.Position = UDim2.new(0.5,-175,0.5,-75)
f.BackgroundColor3 = Color3.fromRGB(15,25,35)
Instance.new("UICorner", f).CornerRadius = UDim.new(0,12)
local s = Instance.new("UIStroke", f)
s.Color = Color3.fromRGB(0,255,136)
s.Thickness = 3
local t1 = Instance.new("TextLabel", f)
t1.Text = "RENZ HUB"
t1.Size = UDim2.new(1,0,0.5,0)
t1.BackgroundTransparency = 1
t1.TextColor3 = Color3.fromRGB(0,255,136)
t1.TextScaled = true
t1.Font = Enum.Font.GothamBold
local t2 = Instance.new("TextLabel", f)
t2.Text = "MADE BY RENZ"
t2.Size = UDim2.new(1,0,0.5,0)
t2.Position = UDim2.new(0,0,0.5,0)
t2.BackgroundTransparency = 1
t2.TextColor3 = Color3.fromRGB(0,170,255)
t2.TextScaled = true
t2.Font = Enum.Font.GothamBold
task.wait(3)
intro:Destroy()

-- 2. LOAD HUB
loadstring(game:HttpGet("https://raw.githubusercontent.com/sabscrip-arch/srver/refs/heads/main/Stealanegg"))()

-- 3. SUPER PATCH - HAHABULIN NYA HABANG BUHAY YUNG TITLE AT OWNER
task.spawn(function()
  local function fix(obj)
    pcall(function()
      if obj:IsA("TextLabel") then
        if obj.Text:lower():find("rene") or obj.Text:lower():find("batebonia") then
          obj.Text = "RENZ HUB | By RENZ"
        end
      end
      if obj.Text == "Owner" then
        obj.Visible = false
        if obj.Parent then 
          obj.Parent.Visible = false 
          -- try itago pati grandparent
          if obj.Parent.Parent and obj.Parent.Parent:FindFirstChild("Owner") then
            obj.Parent.Parent.Visible = false
          end
        end
      end
    end)
  end

  -- Connect para kahit bagong gawa na label, mahuhuli agad
  local cg = game:GetService("CoreGui")
  cg.DescendantAdded:Connect(fix)
  if gethui then
    pcall(function() gethui().DescendantAdded:Connect(fix) end)
  end
  
  -- Loop forever every 0.2 sec
  while true do
    task.wait(0.2)
    for _,v in pairs(cg:GetDescendants()) do fix(v) end
    if gethui then
      for _,v in pairs(gethui():GetDescendants()) do fix(v) end
    end
  end
end)
