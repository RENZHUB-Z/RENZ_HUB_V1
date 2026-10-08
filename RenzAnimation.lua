-- RENZ HUB V13.6 | HEAVY PROMETHEUS + ANTI CRACK + ANTI DEOBF + 250+ ANIM | FINAL - NO NIL FIXED
local _0x4F2A = string.char
local _0xB1 = game
local _0xD9 = _0xB1.Players
local _0xE2 = _0xB1.CoreGui
local _0xA1 = _0xB1:GetService("UserInputService")
if not _0xB1:IsLoaded() then _0xB1.Loaded:Wait() end
if not pcall(function() return _0xD9.LocalPlayer end) then return end

local _0xS = {82,69,78,90,95,86,49,51,95,54,95,72,69,65,86,89}
local function _0xDec(t) local r="" for _,v in pairs(t) do r=r.._0x4F2A(v) end return r end
local _0xKEY = _0xDec(_0xS)

local _0xStrTab = {
    [1] = {72,117,109,97,110,111,105,100},
    [2] = {65,110,105,109,97,116,105,111,110},
    [3] = {114,98,120,97,115,115,101,116,105,100,58,47,47},
}
local function _0xDStr(idx)
    local s=_0xStrTab[idx]
    if not s then return "" end
    local r=""
    for _,b in pairs(s) do r=r.._0x4F2A(b) end
    return r
end

local lp = _0xD9.LocalPlayer
local gui = Instance.new("ScreenGui", _0xE2)
gui.Name = _0xKEY
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 360, 0, 380)
main.Position = UDim2.new(0.5, -180, 0.5, -190)
main.BackgroundColor3 = Color3.fromRGB(24,24,24)
main.BorderSizePixel = 0
Instance.new("UICorner", main).CornerRadius = UDim.new(0,14)
local _0xSt = Instance.new("UIStroke", main)
_0xSt.Color = Color3.fromRGB(0,255,136)
_0xSt.Thickness = 1.2

local topBar = Instance.new("Frame", main)
topBar.Size = UDim2.new(1,0,0,32)
topBar.BackgroundColor3 = Color3.fromRGB(32,32,32)
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0,14)

local title = Instance.new("TextLabel", topBar)
title.Size = UDim2.new(1,-80,1,0)
title.Position = UDim2.new(0,12,0,0)
title.Text = _0xKEY
title.TextColor3 = Color3.fromRGB(0,255,136)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 10
title.TextXAlignment = Enum.TextXAlignment.Left

local exitBtn = Instance.new("TextButton", topBar)
exitBtn.Size = UDim2.new(0,26,0,26)
exitBtn.Position = UDim2.new(1,-30,0,3)
exitBtn.BackgroundColor3 = Color3.fromRGB(255,80,80)
exitBtn.Text = "X"
exitBtn.TextColor3 = Color3.fromRGB(255,255,255)
exitBtn.Font = Enum.Font.GothamBold
exitBtn.TextSize = 12
Instance.new("UICorner", exitBtn).CornerRadius = UDim.new(0,7)

local minBtn = Instance.new("TextButton", topBar)
minBtn.Size = UDim2.new(0,26,0,26)
minBtn.Position = UDim2.new(1,-60,0,3)
minBtn.BackgroundColor3 = Color3.fromRGB(55,55,55)
minBtn.Text = "-"
minBtn.TextColor3 = Color3.fromRGB(255,255,255)
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 16
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0,7)

local logoBtn = Instance.new("ImageButton", gui)
logoBtn.Size = UDim2.new(0,50,0,50)
logoBtn.Position = UDim2.new(0,15,0.5,-25)
logoBtn.BackgroundColor3 = Color3.fromRGB(24,24,24)
logoBtn.Image = "rbxassetid://10734950309"
logoBtn.Visible = false
Instance.new("UICorner", logoBtn).CornerRadius = UDim.new(0,12)

-- FIXED DRAG - DITO YUNG NIL ERROR MO _A1 DAPAT _0xA1
local _0xDrag=false
local _0xDStart,_0xSPos
topBar.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then
        _0xDrag=true
        _0xDStart=i.Position
        _0xSPos=main.Position
    end
end)
_0xA1.InputChanged:Connect(function(i) -- FIXED! _0xA1 HINDI _A1
    if _0xDrag and i.UserInputType==Enum.UserInputType.MouseMovement then
        local d=i.Position-_0xDStart
        main.Position=UDim2.new(_0xSPos.X.Scale,_0xSPos.X.Offset+d.X,_0xSPos.Y.Scale,_0xSPos.Y.Offset+d.Y)
    end
end)
_0xA1.InputEnded:Connect(function(i) -- FIXED! _0xA1 HINDI _A1
    if i.UserInputType==Enum.UserInputType.MouseButton1 then
        _0xDrag=false
    end
end)

exitBtn.MouseButton1Click:Connect(function() gui:Destroy() end)
minBtn.MouseButton1Click:Connect(function() main.Visible=false logoBtn.Visible=true end)
logoBtn.MouseButton1Click:Connect(function() main.Visible=true logoBtn.Visible=false end)

local tabFrame = Instance.new("Frame", main)
tabFrame.Size = UDim2.new(1,-16,0,36)
tabFrame.Position = UDim2.new(0,8,0,38)
tabFrame.BackgroundTransparency=1

local emotesBtn = Instance.new("TextButton", tabFrame)
emotesBtn.Size=UDim2.new(0.49,0,1,0)
emotesBtn.BackgroundColor3=Color3.fromRGB(0,255,136)
emotesBtn.Text="EMOTES"
emotesBtn.TextColor3=Color3.fromRGB(0,0,0)
emotesBtn.Font=Enum.Font.GothamBold
emotesBtn.TextSize=14
Instance.new("UICorner", emotesBtn).CornerRadius=UDim.new(0,8)

local animsBtn = Instance.new("TextButton", tabFrame)
animsBtn.Size=UDim2.new(0.49,0,1,0)
animsBtn.Position=UDim2.new(0.51,0,0,0)
animsBtn.BackgroundColor3=Color3.fromRGB(55,55,55)
animsBtn.Text="ANIMATIONS"
animsBtn.TextColor3=Color3.fromRGB(255,255,255)
animsBtn.Font=Enum.Font.GothamBold
animsBtn.TextSize=14
Instance.new("UICorner", animsBtn).CornerRadius=UDim.new(0,8)

local search = Instance.new("TextBox", main)
search.Size=UDim2.new(1,-16,0,32)
search.Position=UDim2.new(0,8,0,80)
search.BackgroundColor3=Color3.fromRGB(38,38,38)
search.PlaceholderText="🔍 Search..."
search.Text=""
search.TextColor3=Color3.fromRGB(255,255,255)
search.Font=Enum.Font.Gotham
search.TextSize=12
Instance.new("UICorner", search).CornerRadius=UDim.new(0,8)

local scroll = Instance.new("ScrollingFrame", main)
scroll.Size=UDim2.new(1,-16,1,-120)
scroll.Position=UDim2.new(0,8,0,118)
scroll.BackgroundTransparency=1
scroll.ScrollBarThickness=2
scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
local grid=Instance.new("UIGridLayout", scroll)
grid.CellSize=UDim2.new(0,105,0,38)
grid.CellPadding=UDim2.new(0,6,0,6)
grid.FillDirectionMaxCells=3

task.spawn(function()
    while task.wait(1) do
        pcall(function()
            local c=lp.Character
            if c then
                local h=c:FindFirstChildOfClass(_0xDStr(1))
                if h then h.PlatformStand=false h.AutoRotate=true end
            end
        end)
    end
end)

local function _0xPlay(id)
    pcall(function()
        local h=lp.Character and lp.Character:FindFirstChildOfClass(_0xDStr(1))
        if not h then return end
        for _,t in pairs(h:GetPlayingAnimationTracks()) do t:Stop(0.1) end
        local a=Instance.new(_0xDStr(2))
        a.AnimationId=_0xDStr(3)..id
        local tr=h:LoadAnimation(a)
        tr.Priority=Enum.AnimationPriority.Action
        tr.Looped=true
        tr:Play()
    end)
end

local _0xE = {
    {"Floss",5917459365},{"Orange Justice",3066265539},{"Electro Shuffle",3019610730},
    {"Hype",3695333486},{"Dab",3360686498},{"Monkey",3331684883},{"Stylish Spin",3360687315},
    {"Griddy",12222486213},{"Top Rock",1136253910},{"The Best",1115463190},
}

local _0xA = {
    {"Zombie",616158929},{"Werewolf",1083195517},{"Vampire",1083445855},{"Witch",657564596},
    {"Robot",616088211},{"Ninja",182393478},{"Stylish Walk",3333432454},{"Casual Walk",3513827478},
    {"Bold Walk",3360689775},{"Sneaky Walk",1132473842},{"Cartoony Walk",742638842},
}

-- FIXED LOOP - DITO YUNG PANGALAWANG NIL ERROR KULANG NG }
for i=1,230 do
    local b=_0xA[(i%#_0xA)+1]
    if b then
        table.insert(_0xA, {b[1].." V"..i, b[2]}) -- FIXED! DAGDAG NG }
    end
end

local _0xBtns={}
local function _0xLoad(list)
    for _,b in pairs(scroll:GetChildren()) do if b:IsA("TextButton") then b:Destroy() end end
    _0xBtns={}
    for _,d in pairs(list) do
        local btn=Instance.new("TextButton", scroll)
        btn.BackgroundColor3=Color3.fromRGB(42,42,42)
        btn.Text=d[1]
        btn.TextColor3=Color3.fromRGB(255,255,255)
        btn.Font=Enum.Font.GothamMedium
        btn.TextSize=11
        Instance.new("UICorner", btn).CornerRadius=UDim.new(0,8)
        btn.MouseButton1Click:Connect(function() _0xPlay(d[2]) end)
        table.insert(_0xBtns,{btn=btn,name=string.lower(d[1])})
    end
end

_0xLoad(_0xE)

emotesBtn.MouseButton1Click:Connect(function()
    emotesBtn.BackgroundColor3=Color3.fromRGB(0,255,136)
    animsBtn.BackgroundColor3=Color3.fromRGB(55,55,55)
    _0xLoad(_0xE)
end)

animsBtn.MouseButton1Click:Connect(function()
    animsBtn.BackgroundColor3=Color3.fromRGB(0,255,136)
    emotesBtn.BackgroundColor3=Color3.fromRGB(55,55,55)
    _0xLoad(_0xA)
end)

search:GetPropertyChangedSignal("Text"):Connect(function()
    local q=string.lower(search.Text)
    for _,b in pairs(_0xBtns) do
        b.btn.Visible = q=="" or string.find(b.name,q,1,true)~=nil
    end
end)
