-- RENZ HUB | 3 IN 1 + VMAX - FINAL LOADER
-- File: RenzHubLoader.lua
repeat task.wait() until game:IsLoaded()

local BASE = "https://raw.githubusercontent.com/RENZHUB-Z/RENZ_HUB_V1/main/"

local FILES = {
    Avatar = BASE.."AVATAR%20CHANGER%20BEEHUB",
    Korblox = BASE.."KORBLOX",
    Premium = BASE.."PREMIUM%20BEE%20HUB%20BACK",
    Vmax = BASE.."VMAX-HAHAHA.lua"
}

if game.Players.LocalPlayer.PlayerGui:FindFirstChild("Renz3in1Final") then
    game.Players.LocalPlayer.PlayerGui:FindFirstChild("Renz3in1Final"):Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "Renz3in1Final"
gui.ResetOnSpawn = false
gui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.new(0,420,0,380)
main.Position = UDim2.new(0.5,0,0.5,0)
main.AnchorPoint = Vector2.new(0.5,0.5)
main.BackgroundColor3 = Color3.fromRGB(12,12,22)
main.Parent = gui
Instance.new("UICorner",main).CornerRadius = UDim.new(0,16)
local st = Instance.new("UIStroke",main) st.Color = Color3.fromRGB(255,204,0) st.Thickness = 2

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,50)
title.BackgroundTransparency = 1
title.Text = "RENZ HUB | 3 IN 1 🤑"
title.TextColor3 = Color3.fromRGB(255,204,0)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = main

local function makeBtn(text, y, color, url)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,-20,0,55)
    b.Position = UDim2.new(0,10,0,y)
    b.BackgroundColor3 = color
    b.Text = text
    b.TextColor3 = Color3.fromRGB(255,255,255)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 13
    b.Parent = main
    Instance.new("UICorner",b).CornerRadius = UDim.new(0,12)
    b.MouseButton1Click:Connect(function()
        task.spawn(function()
            pcall(function()
                loadstring(game:HttpGet(url.."?v="..tick()))()
            end)
        end)
    end)
end

makeBtn("🐝 AVATAR CHANGER BEEHUB", 60, Color3.fromRGB(255,140,0), FILES.Avatar)
makeBtn("💀 KORBLOX", 125, Color3.fromRGB(70,70,70), FILES.Korblox)
makeBtn("🍯 PREMIUM BEE HUB BACK", 190, Color3.fromRGB(200,160,0), FILES.Premium)
makeBtn("⚡ VMAX ANTI-CHASE + INSTANT STEAL", 255, Color3.fromRGB(0,180,80), FILES.Vmax)

local close = Instance.new("TextButton")
close.Size = UDim2.new(1,-20,0,35)
close.Position = UDim2.new(0,10,0,330)
close.BackgroundColor3 = Color3.fromRGB(180,0,0)
close.Text = "CLOSE"
close.TextColor3 = Color3.new(1,1,1)
close.Font = Enum.Font.GothamBold
close.TextSize = 13
close.Parent = main
Instance.new("UICorner",close).CornerRadius = UDim.new(0,10)
close.MouseButton1Click:Connect(function() gui:Destroy() end)

print("RENZ HUB 3-IN-1 LOADER READY")
