-- RENZ HUB | FULL PACK ANIMATION CHANGER V8
-- TRUE FULL PACK: Idle, Walk, Run, Jump, Fall, Swim, Climb - Lahat papalitan!

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

if CoreGui:FindFirstChild("RENZ_HUB_ANIMATION_CHANGER") then
    CoreGui:FindFirstChild("RENZ_HUB_ANIMATION_CHANGER"):Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RENZ_HUB_ANIMATION_CHANGER"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 420, 0, 380)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(16,16,16)
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0,12)

local TitleBar = Instance.new("Frame", MainFrame)
TitleBar.Size = UDim2.new(1,0,0,36)
TitleBar.BackgroundColor3 = Color3.fromRGB(0,255,136)
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0,12)
local Fix = Instance.new("Frame", TitleBar)
Fix.Size = UDim2.new(1,0,0,12)
Fix.Position = UDim2.new(0,0,1,-12)
Fix.BackgroundColor3 = Color3.fromRGB(0,255,136)
Fix.BorderSizePixel = 0

local Title = Instance.new("TextLabel", TitleBar)
Title.Size = UDim2.new(1,-85,1,0)
Title.Position = UDim2.new(0,12,0,0)
Title.BackgroundTransparency = 1
Title.Text = "RENZ HUB | FULL PACK"
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 13
Title.TextColor3 = Color3.new(0,0,0)
Title.TextXAlignment = Enum.TextXAlignment.Left

local ExitBtn = Instance.new("TextButton", TitleBar)
ExitBtn.Size = UDim2.new(0,28,0,28)
ExitBtn.Position = UDim2.new(1,-32,0,4)
ExitBtn.BackgroundColor3 = Color3.fromRGB(255,45,45)
ExitBtn.Text = "X"
ExitBtn.Font = Enum.Font.GothamBold
ExitBtn.TextSize = 13
ExitBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", ExitBtn).CornerRadius = UDim.new(0,7)

local TabFrame = Instance.new("Frame", MainFrame)
TabFrame.Size = UDim2.new(1,-8,0,28)
TabFrame.Position = UDim2.new(0,4,0,42)
TabFrame.BackgroundTransparency = 1

local function MakeTab(name, pos, active)
    local b = Instance.new("TextButton", TabFrame)
    b.Size = UDim2.new(0.333,-3,1,0)
    b.Position = UDim2.new(pos,3,0,0)
    b.BackgroundColor3 = active and Color3.fromRGB(0,255,136) or Color3.fromRGB(38,38,38)
    b.Text = name
    b.Font = Enum.Font.GothamBold
    b.TextSize = 9
    b.TextColor3 = active and Color3.new(0,0,0) or Color3.new(1,1,1)
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
    return b
end

local EmoteTab = MakeTab("10K EMOTES", 0, false)
local AnimTab = MakeTab("FULL PACK", 0.333, true)
local ElysiaTab = MakeTab("ELYSIA V2", 0.666, false)

local SearchBar = Instance.new("TextBox", MainFrame)
SearchBar.Size = UDim2.new(1,-8,0,26)
SearchBar.Position = UDim2.new(0,4,0,76)
SearchBar.BackgroundColor3 = Color3.fromRGB(30,30,30)
SearchBar.PlaceholderText = "🔍 Search zombie, werewolf, elysia..."
SearchBar.Text = ""
SearchBar.TextColor3 = Color3.new(1,1,1)
SearchBar.PlaceholderColor3 = Color3.fromRGB(110,110,110)
SearchBar.Font = Enum.Font.Gotham
SearchBar.TextSize = 11
Instance.new("UICorner", SearchBar).CornerRadius = UDim.new(0,6)

local InfoLabel = Instance.new("TextLabel", MainFrame)
InfoLabel.Size = UDim2.new(1,-8,0,20)
InfoLabel.Position = UDim2.new(0,4,0,105)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Text = "FULL PACK: Idle + Walk + Run + Jump + Fall + Swim + Climb"
InfoLabel.Font = Enum.Font.Gotham
InfoLabel.TextSize = 9
InfoLabel.TextColor3 = Color3.fromRGB(0,255,136)
InfoLabel.TextXAlignment = Enum.TextXAlignment.Left

local Scroll = Instance.new("ScrollingFrame", MainFrame)
Scroll.Size = UDim2.new(1,-8,1,-132)
Scroll.Position = UDim2.new(0,4,0,128)
Scroll.BackgroundColor3 = Color3.fromRGB(26,26,26)
Scroll.BorderSizePixel = 0
Scroll.CanvasSize = UDim2.new(0,0,0,0)
Scroll.ScrollBarThickness = 3
Instance.new("UICorner", Scroll).CornerRadius = UDim.new(0,6)

local Grid = Instance.new("UIGridLayout", Scroll)
Grid.CellPadding = UDim2.new(0,4,0,4)
Grid.CellSize = UDim2.new(0,124,0,32)

-- TRUE FULL PACK CHANGER - Papalitan lahat ng Animate script
local function ApplyFullPack(pack)
    local char = LocalPlayer.Character
    if not char then return end
    local animate = char:FindFirstChild("Animate")
    if not animate then return end
    
    -- Stop all playing anims
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        local animator = hum:FindFirstChildOfClass("Animator")
        if animator then
            for _, t in pairs(animator:GetPlayingAnimationTracks()) do t:Stop() end
        end
    end

    -- FULL PACK - Change all states
    pcall(function()
        -- IDLE
        animate.idle.Animation1.AnimationId = "rbxassetid://"..pack.Idle
        animate.idle.Animation2.AnimationId = "rbxassetid://"..pack.Idle
        -- WALK
        animate.walk.WalkAnim.AnimationId = "rbxassetid://"..pack.Walk
        -- RUN
        animate.run.RunAnim.AnimationId = "rbxassetid://"..pack.Run
        -- JUMP
        animate.jump.JumpAnim.AnimationId = "rbxassetid://"..pack.Jump
        -- FALL
        animate.fall.FallAnim.AnimationId = "rbxassetid://"..pack.Fall
        -- SWIM
        if animate:FindFirstChild("swim") then
            animate.swim.Swim.AnimationId = "rbxassetid://"..pack.Swim
        end
        -- CLIMB
        if animate:FindFirstChild("climb") then
            animate.climb.ClimbAnim.AnimationId = "rbxassetid://"..pack.Climb
        end
    end)
    
    -- Play idle agad para makita
    task.wait(0.1)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        local animator = hum:FindFirstChildOfClass("Animator") or Instance.new("Animator", hum)
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://"..pack.Idle
        local track = animator:LoadAnimation(anim)
        track:Play()
        track.Looped = true
    end
    
    print("FULL PACK Applied: "..pack.Name)
end

-- FULL PACK DATA - Lahat may Idle, Walk, Run, Jump, Fall, Swim, Climb
local FullPacks = {
    {Name="Zombie FULL PACK", Idle="616158929", Walk="616168032", Run="616163682", Jump="616161280", Fall="616160636", Swim="616160636", Climb="616156119"},
    {Name="Werewolf FULL PACK", Idle="616158665", Walk="616168219", Run="616168219", Jump="616161280", Fall="616160033", Swim="616160033", Climb="616156119"},
    {Name="Vampire FULL PACK", Idle="616158699", Walk="616168056", Run="616168056", Jump="616161280", Fall="616158699", Swim="616158699", Climb="616156119"},
    {Name="Ghost FULL PACK", Idle="616158669", Walk="616161280", Run="616161280", Jump="616161280", Fall="616158669", Swim="616158669", Climb="616156119"},
    {Name="Skeleton FULL PACK", Idle="616160033", Walk="616168211", Run="616163682", Jump="616161280", Fall="616160033", Swim="616160033", Climb="616156119"},
    {Name="Witch FULL PACK", Idle="616133919", Walk="616133919", Run="616133919", Jump="616161280", Fall="616133919", Swim="616133919", Climb="616156119"},
    {Name="Robot FULL PACK", Idle="616159216", Walk="616159216", Run="616159216", Jump="616159216", Fall="616159216", Swim="616159216", Climb="616159216"},
    {Name="Toy FULL PACK", Idle="616158742", Walk="616158742", Run="616158742", Jump="616158742", Fall="616158742", Swim="616158742", Climb="616158742"},
    {Name="Levitate FULL PACK", Idle="616161402", Walk="616161402", Run="616161402", Jump="616161402", Fall="616161402", Swim="616161402", Climb="616161402"},
    {Name="Bold FULL PACK", Idle="616157476", Walk="616157476", Run="616160101", Jump="616160101", Fall="616157476", Swim="616157476", Climb="616157476"},
    {Name="Bubbly FULL PACK", Idle="616155929", Walk="616155929", Run="616160101", Jump="616155929", Fall="616155929", Swim="616155929", Climb="616155929"},
    {Name="Cartoony FULL PACK", Idle="616157476", Walk="616157476", Run="616160101", Jump="616157476", Fall="616157476", Swim="616157476", Climb="616157476"},
    {Name="Confident FULL PACK", Idle="616156119", Walk="616156119", Run="616160101", Jump="616156119", Fall="616156119", Swim="616156119", Climb="616156119"},
    {Name="Sneaky FULL PACK", Idle="616160179", Walk="616160179", Run="616160101", Jump="616160179", Fall="616160179", Swim="616160179", Climb="616160179"},
    {Name="Elder FULL PACK", Idle="616156614", Walk="616156614", Run="616160101", Jump="616156614", Fall="616156614", Swim="616156614", Climb="616156614"},
    {Name="Mage FULL PACK", Idle="616160646", Walk="616160646", Run="616160646", Jump="616160646", Fall="616160646", Swim="616160646", Climb="616160646"},
    {Name="Pirate FULL PACK", Idle="616161264", Walk="616161264", Run="616160101", Jump="616161264", Fall="616161264", Swim="616161264", Climb="616161264"},
    {Name="Popstar FULL PACK", Idle="616160911", Walk="616160911", Run="616160911", Jump="616160911", Fall="616160911", Swim="616160911", Climb="616160911"},
    {Name="Princess FULL PACK", Idle="616160509", Walk="616160509", Run="616160509", Jump="616160509", Fall="616160509", Swim="616160509", Climb="616160509"},
    {Name="Patrol FULL PACK", Idle="616160345", Walk="616160345", Run="616160345", Jump="616160345", Fall="616160345", Swim="616160345", Climb="616160345"},
    {Name="Stylish FULL PACK", Idle="616158341", Walk="616158341", Run="616158341", Jump="616158341", Fall="616158341", Swim="616158341", Climb="616158341"},
    {Name="Astronaut FULL PACK", Idle="616159968", Walk="616159968", Run="616159968", Jump="616159968", Fall="616159968", Swim="616159968", Climb="616159968"},
    {Name="Knight FULL PACK", Idle="616159030", Walk="616159030", Run="616159030", Jump="616159030", Fall="616159030", Swim="616159030", Climb="616159030"},
    {Name="Superhero FULL PACK", Idle="616159029", Walk="616159029", Run="616160101", Jump="616159029", Fall="616159029", Swim="616159029", Climb="616159029"},
    {Name="Ninja FULL PACK", Idle="616156119", Walk="616156119", Run="616160101", Jump="616156119", Fall="616156119", Swim="616156119", Climb="616156119"},
    -- ELYSIA V2 FULL PACK
    {Name="Elysia V2 FULL PACK", Idle="13311448203", Walk="13311448203", Run="13311448203", Jump="13311448203", Fall="13311448203", Swim="13311448203", Climb="13311448203"},
    {Name="Elysia Elegant FULL", Idle="15541337573", Walk="15541337573", Run="15541337573", Jump="15541337573", Fall="15541337573", Swim="15541337573", Climb="15541337573"},
    {Name="Elysia Catwalk FULL", Idle="17438648566", Walk="17438648566", Run="17438648566", Jump="17438648566", Fall="17438648566", Swim="17438648566", Climb="17438648566"},
    {Name="Elysia Slay FULL PACK", Idle="13311448203", Walk="13311448203", Run="13311448203", Jump="13311448203", Fall="13311448203", Swim="13311448203", Climb="13311448203"},
}

local ElysiaFullPacks = {
    {Name="Elysia V2 Walk FULL", Idle="13311448203", Walk="13311448203", Run="13311448203", Jump="13311448203", Fall="13311448203", Swim="13311448203", Climb="13311448203"},
    {Name="Elysia V2 Idle FULL", Idle="15541337573", Walk="15541337573", Run="15541337573", Jump="15541337573", Fall="15541337573", Swim="15541337573", Climb="15541337573"},
    {Name="Elysia V2 Run FULL", Idle="17438648566", Walk="17438648566", Run="17438648566", Jump="17438648566", Fall="17438648566", Swim="17438648566", Climb="17438648566"},
    {Name="Elysia Model FULL", Idle="13311448203", Walk="13311448203", Run="13311448203", Jump="13311448203", Fall="13311448203", Swim="13311448203", Climb="13311448203"},
    {Name="Elysia Catwalk FULL", Idle="15541337573", Walk="15541337573", Run="15541337573", Jump="15541337573", Fall="15541337573", Swim="15541337573", Climb="15541337573"},
}

local AllEmotes = {}
local Buttons = {}
local CurrentList = FullPacks

local function CreateButtons(filter)
    for _, b in pairs(Buttons) do b:Destroy() end
    Buttons = {}
    filter = string.lower(filter or "")
    local shown = 0
    for _, item in pairs(CurrentList) do
        if shown >= 600 then break end
        if filter == "" or string.find(string.lower(item.Name), filter) then
            local Btn = Instance.new("TextButton", Scroll)
            Btn.BackgroundColor3 = Color3.fromRGB(42,42,42)
            Btn.Text = item.Name
            Btn.TextColor3 = Color3.new(1,1,1)
            Btn.Font = Enum.Font.GothamBold
            Btn.TextSize = 9
            Btn.TextWrapped = true
            Instance.new("UICorner", Btn).CornerRadius = UDim.new(0,5)
            Btn.MouseButton1Click:Connect(function()
                if item.Idle then
                    ApplyFullPack(item)
                else
                    -- Emote
                    local char = LocalPlayer.Character
                    if not char then return end
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if not hum then return end
                    local animator = hum:FindFirstChildOfClass("Animator") or Instance.new("Animator", hum)
                    for _, t in pairs(animator:GetPlayingAnimationTracks()) do t:Stop() end
                    local anim = Instance.new("Animation")
                    anim.AnimationId = "rbxassetid://"..item.Id
                    local track = animator:LoadAnimation(anim)
                    track:Play()
                    track.Looped = true
                end
            end)
            table.insert(Buttons, Btn)
            shown = shown + 1
        end
    end
    task.wait()
    Scroll.CanvasSize = UDim2.new(0,0,0,Grid.AbsoluteContentSize.Y+10)
end

local function SetTab(tab)
    for _, b in pairs({EmoteTab, AnimTab, ElysiaTab}) do b.BackgroundColor3 = Color3.fromRGB(38,38,38) b.TextColor3 = Color3.new(1,1,1) end
    tab.BackgroundColor3 = Color3.fromRGB(0,255,136) tab.TextColor3 = Color3.new(0,0,0)
end

task.spawn(function()
    SearchBar.PlaceholderText = "Loading 10K..."
    local ok, content = pcall(function() return game:HttpGet("https://raw.githubusercontent.com/7yd7/Hub/refs/heads/Branch/GUIS/Emotes.lua") end)
    if ok and content then
        local found = {}
        for id in string.gmatch(content, "(%d%d%d%d%d%d%d%d%d%d?)") do
            if tonumber(id) and tonumber(id) > 100000000 and tonumber(id) < 20000000000 then
                local exists=false for _,v in pairs(found) do if v.Id==id then exists=true break end end
                if not exists then table.insert(found, {Name="Emote "..id, Id=id}) end
            end
        end
        if #found > 200 then AllEmotes = found end
    end
end)

EmoteTab.MouseButton1Click:Connect(function() SetTab(EmoteTab) CurrentList=AllEmotes CreateButtons(SearchBar.Text) end)
AnimTab.MouseButton1Click:Connect(function() SetTab(AnimTab) CurrentList=FullPacks CreateButtons(SearchBar.Text) end)
ElysiaTab.MouseButton1Click:Connect(function() SetTab(ElysiaTab) CurrentList=ElysiaFullPacks CreateButtons(SearchBar.Text) end)
SearchBar:GetPropertyChangedSignal("Text"):Connect(function() CreateButtons(SearchBar.Text) end)

-- DRAG
local dragging, dragInput, dragStart, startPos
local function update(input) local delta=input.Position-dragStart MainFrame.Position=UDim2.new(startPos.X.Scale, startPos.X.Offset+delta.X, startPos.Y.Scale, startPos.Y.Offset+delta.Y) end
TitleBar.InputBegan:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=true dragStart=input.Position startPos=MainFrame.Position input.Changed:Connect(function() if input.UserInputState==Enum.UserInputState.End then dragging=false end end) end end)
TitleBar.InputChanged:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch then dragInput=input end end)
UIS.InputChanged:Connect(function(input) if input==dragInput and dragging then update(input) end end)

ExitBtn.MouseButton1Click:Connect(function() MainFrame.Visible=false end)
UIS.InputBegan:Connect(function(input,gp) if not gp and input.KeyCode==Enum.KeyCode.RightShift then MainFrame.Visible=not MainFrame.Visible end end)

CreateButtons("")
print("RENZ HUB V8 TRUE FULL PACK Loaded - Idle/Walk/Run/Jump/Fall/Swim/Climb")
