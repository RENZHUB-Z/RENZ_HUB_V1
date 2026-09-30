-- RENZ HUB | MADE BY RENZ - WITH INTRO + AUTO PATCH

-- 1. INTRO MUNA (GREEN & BLUE)
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

-- 2. LOAD ORIGINAL MADAMING SCRIPT
loadstring(game:HttpGet("https://raw.githubusercontent.com/sabscrip-arch/srver/refs/heads/main/Stealanegg"))()

-- 3. AUTO PALIT NAME AT TANGGAL OWNER ( Paulit-ulit hahanapin for 10 sec )
task.spawn(function()
 for i=1,30 do
  task.wait(0.5)
  local places = {game:GetService("CoreGui"), game.Players.LocalPlayer:FindFirstChild("PlayerGui"), gethui and gethui() or nil}
  for _,root in pairs(places) do
   if root then
    for _,v in pairs(root:GetDescendants()) do
     if v:IsA("TextLabel") then
      -- Palitan yung rene-batebonia title
      if v.Text:lower():find("rene") and v.Text:lower():find("batebonia") then
       v.Text = "RENZ HUB | By RENZ"
      end
     end
     if v:IsA("TextLabel") or v:IsA("TextButton") then
      if v.Text == "Owner" then
       -- Itago yung buong Owner tab/button
       pcall(function() v.Parent.Visible = false end)
       pcall(function() v.Parent.Parent.Visible = false end)
       -- Kung nasa loob ng list, burahin
       if v.Parent:FindFirstChild("Owner") or v.Text == "Owner" then
        -- wag i-destroy agad para di mag error hub, itago lang
        v.Text = ""
       end
      end
     end
    end
   end
  end
 end
end)
