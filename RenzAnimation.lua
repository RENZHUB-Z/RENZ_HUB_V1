-- RENZ HUB V10.7 FINAL | ALL ANIM FIXED + TIKTOK BRAZILIAN + PAID BRANDED
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer
if LP.PlayerGui:FindFirstChild("RenzHub") then LP.PlayerGui.RenzHub:Destroy() end

local Gui = Instance.new("ScreenGui", LP.PlayerGui)
Gui.Name = "RenzHub"
Gui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", Gui)
MainFrame.Size = UDim2.new(0, 590, 0, 440)
MainFrame.Position = UDim2.new(0.5, -295, 0.5, -220)
MainFrame.BackgroundColor3 = Color3.fromRGB(18,18,18)
MainFrame.BorderSizePixel = 0
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0,12)

local TitleBar = Instance.new("Frame", MainFrame)
TitleBar.Size = UDim2.new(1,0,0,40)
TitleBar.BackgroundColor3 = Color3.fromRGB(30,30,30)
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0,12)

local Title = Instance.new("TextLabel", TitleBar)
Title.Text = "RENZ HUB V10.7 | TIKTOK BRAZILIAN + PAID"
Title.Size = UDim2.new(1,-90,1,0)
Title.Position = UDim2.new(0,15,0,0)
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBold
Title.TextSize = 12

local ExitBtn = Instance.new("TextButton", TitleBar)
ExitBtn.Size = UDim2.new(0,30,0,30)
ExitBtn.Position = UDim2.new(1,-35,0,5)
ExitBtn.Text = "X"
ExitBtn.BackgroundColor3 = Color3.fromRGB(200,50,50)
ExitBtn.TextColor3 = Color3.new(1,1,1)
ExitBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", ExitBtn).CornerRadius = UDim.new(0,6)

local TabFrame = Instance.new("Frame", MainFrame)
TabFrame.Size = UDim2.new(1,0,0,35)
TabFrame.Position = UDim2.new(0,0,0,40)
TabFrame.BackgroundColor3 = Color3.fromRGB(25,25,25)

local Content = Instance.new("ScrollingFrame", MainFrame)
Content.Size = UDim2.new(1,-10,1,-85)
Content.Position = UDim2.new(0,5,0,80)
Content.BackgroundTransparency = 1
Content.CanvasSize = UDim2.new(0,0,0,0)
Content.ScrollBarThickness = 4
local Grid = Instance.new("UIGridLayout", Content)
Grid.CellSize = UDim2.new(0,175,0,32)
Grid.CellPadding = UDim2.new(0,5,0,5)

local SearchBox = Instance.new("TextBox", MainFrame)
SearchBox.Size = UDim2.new(0,150,0,25)
SearchBox.Position = UDim2.new(1,-155,0,7)
SearchBox.PlaceholderText = "Search emote..."
SearchBox.BackgroundColor3 = Color3.fromRGB(50,50,50)
SearchBox.TextColor3 = Color3.new(1,1,1)
SearchBox.TextSize = 12
Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0,6)

-- ALL PACKS FIXED V10.6 CORE
local Packs = {
    {Name="Elyssa Catwalk", IDLE="616006778", WALK="616025407", RUN="616025755", JUMP="616026653"},
    {Name="Werewolf", IDLE="1083195517", WALK="1083178339", RUN="1083216690", JUMP="1083218792", FALL="1083188650"},
    {Name="Vampire", IDLE="1083445855", WALK="1083435962", RUN="1083462077", JUMP="1083455352"},
    {Name="Zombie", IDLE="616158929", WALK="616160636", RUN="616163682", JUMP="616161997"},
    {Name="Stylish", IDLE="616136790", WALK="616146177", RUN="616140816", JUMP="616139451"},
    {Name="Cartoony", IDLE="616146718", WALK="616155929", RUN="616151856", JUMP="616143378"},
    {Name="Ninja", IDLE="656118852", WALK="656121196", RUN="656118852", JUMP="656117878"},
    {Name="Levitation", IDLE="616006778", WALK="616010382", RUN="616010382"},
}

-- V10.7 FULL EMOTES LIST - PAID BRANDED + TIKTOK + BRAZILIAN
local Emotes = {
    -- BRAZILIAN / PHONK VIRAL (TIKTOK)
    {Name="Brazilian Funk Phonk", Id="13504939612"},
    {Name="Passinho Brasileiro", Id="13460944293"},
    {Name="Favela Dance", Id="13533642593"},
    {Name="Samba Funk", Id="13460808519"},
    {Name="Brazilian Flow", Id="13459167876"},
    {Name="Brazilian 2", Id="13215808543"},
    {Name="Funk Paulista", Id="13504939612"},

    -- TOMMY HILFIGER PREMIUM 170 ROBUX (YUNG V POSE NA HINAHANAP MO)
    {Name="V POSE - Tommy [170R]", Id="10214418283"},
    {Name="Frosty Flair - Tommy", Id="10214369643"},
    {Name="Floor Rock Freeze - Tommy", Id="10214311273"},
    {Name="Mean Mug - Tommy", Id="10214405757"},
    {Name="Uprise - Tommy", Id="10214391577"},
    {Name="Tommy Archer", Id="12342126660"},

    -- TIKTOK VIRAL 2024-2026
    {Name="Cuh Dance TikTok", Id="13126496015"},
    {Name="Griddy Dance", Id="12292875863"},
    {Name="Wednesday Dance", Id="12342124117"},
    {Name="Skibidi Toilet", Id="13543113174"},
    {Name="L Dance Fortnite", Id="12550606757"},
    {Name="Gigachad Sigma", Id="13254694178"},
    {Name="Rizz Walk TikTok", Id="13440056158"},
    {Name="SkeeYee", Id="13254775406"},
    {Name="Gangnam Style", Id="12272894215"},
    {Name="Ohio Meme Dance", Id="13543113174"},

    -- CLASSIC PAID VIRAL
    {Name="Monkey [VIRAL]", Id="3333499508"},
    {Name="Stylish Spin", Id="3333531056"},
    {Name="Hype Dance", Id="3333432454"},
    {Name="Top Rock", Id="3360689477"},
    {Name="Stadium", Id="3360689775"},
    {Name="Star Power", Id="3360686498"},
    {Name="Get Loose", Id="3360686103"},
    {Name="Smug Dance", Id="3361630598"},
    {Name="Infinite Dab", Id="3360692679"},
    {Name="Robot", Id="3333644109"},
    {Name="Best Mates", Id="3333567226"},
    {Name="Confident", Id="3333568037"},
    {Name="Goat", Id="3333643359"},
    {Name="Floss", Id="3333519895"},
    {Name="Shuffle", Id="3333432467"},
    {Name="Orange Justice", Id="3333499200"},
    {Name="Electro Shuffle", Id="3333519794"},

    -- FREE
    {Name="Shrug FREE", Id="3333851889"},
    {Name="Hello FREE", Id="3333841426"},
    {Name="Salute FREE", Id="3360684523"},
    {Name="Dab FREE", Id="3333496352"},
    {Name="T-Pose FREE", Id="3333498488"},
    {Name="Face Palm FREE", Id="3333538754"},
}

local currentTab = "Full"

-- FIXED CORE NO MORE STATUE
local function setAndPlay(folderName, id, forcePlay)
    local char = LP.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local animate = char:FindFirstChild("Animate") or char:FindFirstChild("animate")
    if not hum then return end
    local cleanId = tostring(id):match("%d+")
    if not cleanId then return end
    local asset = "rbxassetid://"..cleanId
    if animate then
        local folder = animate:FindFirstChild(folderName) or animate:FindFirstChild(string.lower(folderName))
        if folder then
            for _, v in ipairs(folder:GetChildren()) do
                if v:IsA("Animation") then v.AnimationId = asset end
            end
        end
        animate.Disabled = true
        task.wait(0.08)
        animate.Disabled = false
    end
    if forcePlay then
        for _, tr in pairs(hum:GetPlayingAnimationTracks()) do tr:Stop(0.1) end
        task.wait(0.1)
        local a = Instance.new("Animation")
        a.AnimationId = asset
        local t = hum:LoadAnimation(a)
        t.Priority = Enum.AnimationPriority.Action
        t.Looped = true
        t:Play()
    end
end

local function ApplyFullPack(packData)
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then for _, tr in pairs(hum:GetPlayingAnimationTracks()) do tr:Stop(0) end end
    task.wait(0.1)
    for k,v in pairs(packData) do
        if k ~= "Name" and v and v ~= "" then
            setAndPlay(string.lower(k), v, false)
            task.wait(0.12)
        end
    end
end

local function PlayEmote(id)
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    for _, tr in pairs(hum:GetPlayingAnimationTracks()) do tr:Stop(0.1) end
    local a = Instance.new("Animation")
    a.AnimationId = "rbxassetid://"..tostring(id):match("%d+")
    local t = hum:LoadAnimation(a)
    t.Priority = Enum.AnimationPriority.Action
    t.Looped = false
    t:Play()
end

local function CreateButtons(filter)
    for _, v in ipairs(Content:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    local list = {}
    if currentTab == "Full" or currentTab == "Mix" then list = Packs else list = Emotes end
    for _, data in ipairs(list) do
        if filter == "" or data.Name:lower():find(filter:lower()) then
            if currentTab == "Full" then
                local b = Instance.new("TextButton", Content)
                b.Text = data.Name.." [FULL]"
                b.BackgroundColor3 = Color3.fromRGB(0,150,100)
                b.TextColor3 = Color3.new(1,1,1)
                b.Font = Enum.Font.GothamBold
                b.TextSize = 11
                Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
                b.MouseButton1Click:Connect(function() ApplyFullPack(data) end)
            elseif currentTab == "Mix" then
                for k,v in pairs(data) do
                    if k ~= "Name" then
                        local b = Instance.new("TextButton", Content)
                        b.Text = data.Name.." "..k
                        b.BackgroundColor3 = Color3.fromRGB(60,60,60)
                        b.TextColor3 = Color3.new(1,1,1)
                        b.TextSize = 10
                        Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
                        b.MouseButton1Click:Connect(function() setAndPlay(string.lower(k), v, true) end)
                    end
                end
            else
                local b = Instance.new("TextButton", Content)
                b.Text = data.Name
                b.BackgroundColor3 = Color3.fromRGB(90,70,180)
                b.TextColor3 = Color3.new(1,1,1)
                b.Font = Enum.Font.GothamBold
                b.TextSize = 10
                Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
                b.MouseButton1Click:Connect(function() PlayEmote(data.Id) end)
            end
        end
    end
    task.wait(0.1)
    Content.CanvasSize = UDim2.new(0,0,0,Grid.AbsoluteContentSize.Y+20)
end

local function MakeTab(name, pos)
    local b = Instance.new("TextButton", TabFrame)
    b.Text = name
    b.Size = UDim2.new(0,85,0,25)
    b.Position = UDim2.new(0,pos,0,5)
    b.BackgroundColor3 = Color3.fromRGB(50,50,50)
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 12
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
    b.MouseButton1Click:Connect(function() currentTab = name CreateButtons(SearchBox.Text) end)
end
MakeTab("Mix", 5)
MakeTab("Full", 95)
MakeTab("Emotes", 185)

SearchBox:GetPropertyChangedSignal("Text"):Connect(function() CreateButtons(SearchBox.Text) end)

local dragging, dragInput, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
UIS.InputChanged:Connect(function(input) if input == dragInput and dragging then update(input) end end)
ExitBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)
UIS.InputBegan:Connect(function(input,gp) if not gp and input.KeyCode == Enum.KeyCode.RightShift then MainFrame.Visible = not MainFrame.Visible end end)

CreateButtons("")
print("RENZ HUB V10.7 TIKTOK + BRAZILIAN + PAID LOADED")
