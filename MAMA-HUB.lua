-- RENZ HUB V4 - NO LAG FIX

-- 1. INTRO
local intro = Instance.new("ScreenGui")
intro.Name = "RenzIntro"
intro.Parent = game.CoreGui
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
t1.BackgroundTransparency=1
t1.TextColor3=Color3.fromRGB(0,255,136)
t1.TextScaled=true
t1.Font=Enum.Font.GothamBold
local t2 = Instance.new("TextLabel", f)
t2.Text = "MADE BY RENZ"
t2.Size = UDim2.new(1,0,0.5,0)
t2.Position=UDim2.new(0,0,0.5,0)
t2.BackgroundTransparency=1
t2.TextColor3=Color3.fromRGB(0,170,255)
t2.TextScaled=true
t2.Font=Enum.Font.GothamBold
task.wait(2.5)
intro:Destroy()

-- 2. LOAD HUB
loadstring(game:HttpGet("https://raw.githubusercontent.com/sabscrip-arch/srver/refs/heads/main/Stealanegg"))()

-- 3. ONE-TIME FIX LANG, HINDI LOOP
task.wait(1.5)
local function patchAll()
  for _,root in pairs({game.CoreGui, gethui and gethui()}) do
    if root then
      for _,v in pairs(root:GetDescendants()) do
        pcall(function()
          if v:IsA("TextLabel") and v.Text:lower():find("rene") then
            v.Text = "RENZ HUB | By RENZ"
          end
          if v.Text == "Owner" then
            v.Text = ""
            v.Visible = false
          end
        end)
      end
    end
  end
end

patchAll()
task.wait(1)
patchAll() -- 2x lang para sure

-- Wag na mag infinite loop para di mag lag
