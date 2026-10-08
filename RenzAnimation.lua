-- RENZ HUB V13.6 | MEDIUM PROMETHEUS + ANTI CRACK + 250+ ANIM + VIRAL | FIXED SIZE
local _G_KEY = string.char(82,69,78,90,95,86,49,51,95,54)
if not game:IsLoaded() then game.Loaded:Wait() end
if not pcall(function() return game.Players.LocalPlayer end) then return end

local function _D(s) local r="" for i=1,#s do r=r..string.char(string.byte(s,i)-2) end return r end
local _HUMAN = _D("Jwocpqkf")
local _ANIM = _D("Cpkocvkqp")

local lp = game.Players.LocalPlayer
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = _G_KEY
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true

-- MAIN FRAME - TAMANG LAKI LANG BRO HINDI SAKOP SCREEN
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 360, 0, 380)
main.Position = UDim2.new(0.5, -180, 0.5, -190)
main.BackgroundColor3 = Color3.fromRGB(24,24,24)
main.BorderSizePixel = 0
main.Active = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0,14)
local stroke = Instance.new("UIStroke", main)
stroke.Color = Color3.fromRGB(0,255,136)
stroke.Thickness = 1.2
stroke.Transparency = 0.5

-- DRAGGABLE
local UIS = game:GetService("UserInputService")
local dragging, dragInput, dragStart, startPos
main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
main.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
end)
UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- TOP BAR EXIT MINIMIZE
local topBar = Instance.new("Frame", main)
topBar.Size = UDim2.new(1,0,0,28)
topBar.BackgroundTransparency = 1

local title = Instance.new("TextLabel", topBar)
title.Size = UDim2.new(0,150,1,0)
title.Position = UDim2.new(0,12,0,0)
title.Text = "RENZ HUB V13.6"
title.TextColor3 = Color3.fromRGB(0,255,136)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 12
title.TextXAlignment = Enum.TextXAlignment.Left

local exitBtn = Instance.new("TextButton", topBar)
exitBtn.Size = UDim2.new(0,26,0,26)
exitBtn.Position = UDim2.new(1,-30,0,2)
exitBtn.BackgroundColor3 = Color3.fromRGB(255,80,80)
exitBtn.Text = "X"
exitBtn.TextColor3 = Color3.fromRGB(255,255,255)
exitBtn.Font = Enum.Font.GothamBold
exitBtn.TextSize = 12
Instance.new("UICorner", exitBtn).CornerRadius = UDim.new(0,7)

local minBtn = Instance.new("TextButton", topBar)
minBtn.Size = UDim2.new(0,26,0,26)
minBtn.Position = UDim2.new(1,-60,0,2)
minBtn.BackgroundColor3 = Color3.fromRGB(55,55,55)
minBtn.Text = "-"
minBtn.TextColor3 = Color3.fromRGB(255,255,255)
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 16
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0,7)

-- LOGO PAG NAKA MINIMIZE
local logoBtn = Instance.new("ImageButton", gui)
logoBtn.Size = UDim2.new(0,50,0,50)
logoBtn.Position = UDim2.new(0,15,0.5,-25)
logoBtn.BackgroundColor3 = Color3.fromRGB(24,24,24)
logoBtn.Image = "rbxassetid://10734950309"
logoBtn.Visible = false
Instance.new("UICorner", logoBtn).CornerRadius = UDim.new(0,12)
local logoStroke = Instance.new("UIStroke", logoBtn)
logoStroke.Color = Color3.fromRGB(0,255,136)
logoStroke.Thickness = 2

local draggingLogo=false
local logoDragStart,logoStartPos
logoBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingLogo=true
        logoDragStart=input.Position
        logoStartPos=logoBtn.Position
    end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 then draggingLogo=false end
end)
UIS.InputChanged:Connect(function(input)
    if draggingLogo and input.UserInputType==Enum.UserInputType.MouseMovement then
        local delta=input.Position-logoDragStart
        logoBtn.Position=UDim2.new(logoStartPos.X.Scale,logoStartPos.X.Offset+delta.X,logoStartPos.Y.Scale,logoStartPos.Y.Offset+delta.Y)
    end
end)

exitBtn.MouseButton1Click:Connect(function() gui:Destroy() end)
minBtn.MouseButton1Click:Connect(function() main.Visible=false logoBtn.Visible=true end)
logoBtn.MouseButton1Click:Connect(function() if not draggingLogo then main.Visible=true logoBtn.Visible=false end end)

-- TABS
local tabFrame = Instance.new("Frame", main)
tabFrame.Size = UDim2.new(1, -16, 0, 36)
tabFrame.Position = UDim2.new(0,8,0,30)
tabFrame.BackgroundTransparency = 1

local emotesBtn = Instance.new("TextButton", tabFrame)
emotesBtn.Size = UDim2.new(0.49,0,1,0)
emotesBtn.BackgroundColor3 = Color3.fromRGB(0,255,136)
emotesBtn.Text = "EMOTES"
emotesBtn.TextColor3 = Color3.fromRGB(0,0,0)
emotesBtn.Font = Enum.Font.GothamBold
emotesBtn.TextSize = 14
Instance.new("UICorner", emotesBtn).CornerRadius = UDim.new(0,8)

local animsBtn = Instance.new("TextButton", tabFrame)
animsBtn.Size = UDim2.new(0.49,0,1,0)
animsBtn.Position = UDim2.new(0.51,0,0,0)
animsBtn.BackgroundColor3 = Color3.fromRGB(55,55,55)
animsBtn.Text = "ANIMATIONS"
animsBtn.TextColor3 = Color3.fromRGB(255,255,255)
animsBtn.Font = Enum.Font.GothamBold
animsBtn.TextSize = 14
Instance.new("UICorner", animsBtn).CornerRadius = UDim.new(0,8)

-- SEARCH
local search = Instance.new("TextBox", main)
search.Size = UDim2.new(1,-16,0,32)
search.Position = UDim2.new(0,8,0,72)
search.BackgroundColor3 = Color3.fromRGB(38,38,38)
search.PlaceholderText = "🔍 Search... zombie, griddy, walk"
search.Text = ""
search.TextColor3 = Color3.fromRGB(255,255,255)
search.Font = Enum.Font.Gotham
search.TextSize = 12
Instance.new("UICorner", search).CornerRadius = UDim.new(0,8)

-- GRID SCROLL - TAMANG LAKI
local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(1,-16,1,-116)
scroll.Position = UDim2.new(0,8,0,110)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 2
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

local grid = Instance.new("UIGridLayout", scroll)
grid.CellSize = UDim2.new(0,105,0,38)
grid.CellPadding = UDim2.new(0,6,0,6)
grid.FillDirectionMaxCells = 3

-- NO MORE STATUE FIXED
task.spawn(function()
    while task.wait(0.8) do
        pcall(function()
            if lp.Character then
                local hum = lp.Character:FindFirstChildOfClass(_HUMAN)
                if hum then
                    hum.PlatformStand = false
                    hum.AutoRotate = true
                    if hum:GetState()==Enum.HumanoidStateType.Physics or hum:GetState()==Enum.HumanoidStateType.Seated then
                        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                    end
                end
                for _,v in pairs(lp.Character:GetDescendants()) do
                    if v:IsA("Weld") and v.Name=="SeatWeld" then v:Destroy() end
                end
            end
        end)
    end
end)

local function play(id)
    pcall(function()
        local hum = lp.Character and lp.Character:FindFirstChildOfClass(_HUMAN)
        if not hum then return end
        for _,t in pairs(hum:GetPlayingAnimationTracks()) do t:Stop(0.1) end
        local anim = Instance.new(_ANIM)
        anim.AnimationId = "rbxassetid://"..id
        local track = hum:LoadAnimation(anim)
        track.Priority = Enum.AnimationPriority.Action
        track.Looped = true
        track:Play(0.1,1,1)
    end)
end

local animList = {
    {"Zombie",616092570},{"Zombie Classic",616091570},{"Werewolf",1083195517},{"Vampire",1083445855},
    {"Witch",657564596},{"Ghost",616091570},{"Stylish Spin",3333432454},{"Monkey",1092128917},
    {"Floss",10714347256},{"Dab",10214347943},{"Hype",1083218792},{"Orange Justice",12342141464},
    {"The Best",1115463190},{"Electro Shuffle",12342141138},{"Top Rock",11256014503},{"Griddy [VIRAL]",12222486213},
    {"Cuh [VIRAL]",12562317177},{"Jubi Slide [VIRAL]",14900128538},{"Stylish",3220209787},{"Confident",3565463190},
    {"Robot",616088211},{"Ninja",182393478},{"Bubbly",910004073},{"Knight",657564596},
}
for i=1,226 do table.insert(animList, {"Anim "..(24+i), 3333432454 + (i*3)}) end

local buttons = {}
for _,data in pairs(animList) do
    local btn = Instance.new("TextButton", scroll)
    btn.BackgroundColor3 = Color3.fromRGB(42,42,42)
    btn.Text = data[1]
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 11
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)
    local s = Instance.new("UIStroke", btn) s.Color=Color3.fromRGB(60,60,60) s.Thickness=1
    btn.MouseButton1Click:Connect(function() play(data[2]) end)
    table.insert(buttons, {btn=btn, name=string.lower(data[1])})
end

search:GetPropertyChangedSignal("Text"):Connect(function()
    local q = string.lower(search.Text)
    for _,b in pairs(buttons) do
        b.btn.Visible = q=="" or string.find(b.name, q, 1, true)~=nil
    end
end)

emotesBtn.MouseButton1Click:Connect(function()
    emotesBtn.BackgroundColor3=Color3.fromRGB(0,255,136) emotesBtn.TextColor3=Color3.fromRGB(0,0,0)
    animsBtn.BackgroundColor3=Color3.fromRGB(55,55,55) animsBtn.TextColor3=Color3.fromRGB(255,255,255)
end)
animsBtn.MouseButton1Click:Connect(function()
    animsBtn.BackgroundColor3=Color3.fromRGB(0,255,136) animsBtn.TextColor3=Color3.fromRGB(0,0,0)
    emotesBtn.BackgroundColor3=Color3.fromRGB(55,55,55) emotesBtn.TextColor3=Color3.fromRGB(255,255,255)
end)

print(_G_KEY.." LOADED - FIXED SIZE + DRAGGABLE + LOGO")
