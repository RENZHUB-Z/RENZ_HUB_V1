-- RenzObf.lua V13.6 SUPER OBF | DO NOT EDIT | ANTI-DEOBF + ANTI-CRACK + AUTO CRASH ACTIVE
do
    local a,b=pcall(function() return game:GetService("Players").LocalPlayer end)
    if not a or not b then while true do end end
    local ok,dbg=pcall(function() return debug.getinfo end)
    if ok and dbg then
        local src=string.lower(debug.getinfo(1).source or "")
        if src:find("deob") or src:find("beaut") or src:find("luraph") or src:find("europa") or src:find("pretty") or src:find("format") or src:find("krnl") then
            while true do local t={} for i=1,9999999 do t[i]=string.rep("RENZOBF_V13.6_PROTECT_"..math.random(),200) end end
        end
    end
end
local function _I(...) return tonumber(string.char(...)) end
local function _S(...)
    local s=string.char(...)
    local o=""
    for i=1,#s do o=o..string.char(string.byte(s,i)-3) end
    return o
end

local Players=game:GetService("Players") local UIS=game:GetService("UserInputService") local LP=Players.LocalPlayer
if LP.PlayerGui:FindFirstChild(_S(Uhq}Rei)) then LP.PlayerGui:FindFirstChild(_S(Uhq}Rei)):Destroy() end
local Gui=Instance.new(_S(VfuhhqJxl),LP.PlayerGui) Gui.Name=_S(Uhq}Rei) Gui.ResetOnSpawn=false
local MainFrame=Instance.new(_S(Iudph),Gui) MainFrame.Size=UDim2.new(0,590,0,440) MainFrame.Position=UDim2.new(0.5,-295,0.5,-220) MainFrame.BackgroundColor3=Color3.fromRGB(18,18,18) MainFrame.BorderSizePixel=0 Instance.new(_S(XLFruqhu),MainFrame).CornerRadius=UDim.new(0,12)
local TitleBar=Instance.new(_S(Iudph),MainFrame) TitleBar.Size=UDim2.new(1,0,0,40) TitleBar.BackgroundColor3=Color3.fromRGB(30,30,30) Instance.new(_S(XLFruqhu),TitleBar).CornerRadius=UDim.new(0,12)
local Title=Instance.new(_S(Wh{wOdeho),TitleBar) Title.Text=_S(UHQ]0REI0Y46C40VXOWUD0#0HQFU|SWHG) Title.Size=UDim2.new(1,-90,1,0) Title.Position=UDim2.new(0,15,0,0) Title.TextColor3=Color3.new(1,1,1) Title.BackgroundTransparency=1 Title.TextXAlignment=Enum.TextXAlignment.Left Title.Font=Enum.Font.GothamBold Title.TextSize=12
local ExitBtn=Instance.new(_S(Wh{wExwwrq),TitleBar) ExitBtn.Size=UDim2.new(0,30,0,30) ExitBtn.Position=UDim2.new(1,-35,0,5) ExitBtn.Text="X" ExitBtn.BackgroundColor3=Color3.fromRGB(200,50,50) ExitBtn.TextColor3=Color3.new(1,1,1) ExitBtn.Font=Enum.Font.GothamBold Instance.new(_S(XLFruqhu),ExitBtn).CornerRadius=UDim.new(0,6)
local TabFrame=Instance.new(_S(Iudph),MainFrame) TabFrame.Size=UDim2.new(1,0,0,35) TabFrame.Position=UDim2.new(0,0,0,40) TabFrame.BackgroundColor3=Color3.fromRGB(25,25,25)
local Content=Instance.new(_S(VfurollqjIudph),MainFrame) Content.Size=UDim2.new(1,-10,1,-85) Content.Position=UDim2.new(0,5,0,80) Content.BackgroundTransparency=1 Content.CanvasSize=UDim2.new(0,0,0,0) Content.ScrollBarThickness=4
local Grid=Instance.new(_S(XLJulgOd|rxw),Content) Grid.CellSize=UDim2.new(0,175,0,32) Grid.CellPadding=UDim2.new(0,5,0,5)
local SearchBox=Instance.new(_S(Wh{wEr{),MainFrame) SearchBox.Size=UDim2.new(0,150,0,25) SearchBox.Position=UDim2.new(1,-155,0,7) SearchBox.PlaceholderText=_S(Vhdufk#hprwh888) SearchBox.BackgroundColor3=Color3.fromRGB(50,50,50) SearchBox.TextColor3=Color3.new(1,1,1) SearchBox.TextSize=12 Instance.new(_S(XLFruqhu),SearchBox).CornerRadius=UDim.new(0,6)

local Packs={
    {Name=_S(Ho|vvd#Fdwzdon),IDLE=_I(54,49,54,48,48,54,55,55,56),WALK=_I(54,49,54,48,50,53,52,48,55),RUN=_I(54,49,54,48,50,53,55,53,53),JUMP=_I(54,49,54,48,50,54,54,53,51)},
    {Name=_S(Zhuhzroi),IDLE=_I(49,48,56,51,49,57,53,53,49,55),WALK=_I(49,48,56,51,49,55,56,51,51,57),RUN=_I(49,48,56,51,50,49,54,54,57,48),JUMP=_I(49,48,56,51,50,49,56,55,57,50),FALL=_I(49,48,56,51,49,56,56,54,53,48)},
    {Name=_S(Ydpsluh),IDLE=_I(49,48,56,51,52,52,53,56,53,53),WALK=_I(49,48,56,51,52,51,53,57,54,50),RUN=_I(49,48,56,51,52,54,50,48,55,55),JUMP=_I(49,48,56,51,52,53,53,51,53,50)},
    {Name=_S(Crpelh),IDLE=_I(54,49,54,49,53,56,57,50,57),WALK=_I(54,49,54,49,54,48,54,51,54),RUN=_I(54,49,54,49,54,51,54,56,50),JUMP=_I(54,49,54,49,54,49,57,57,55)},
    {Name=_S(Vw|olvk),IDLE=_I(54,49,54,49,51,54,55,57,48),WALK=_I(54,49,54,49,52,54,49,55,55),RUN=_I(54,49,54,49,52,48,56,49,54),JUMP=_I(54,49,54,49,51,57,52,53,49)},
    {Name=_S(Fduwrrq|),IDLE=_I(54,49,54,49,52,54,55,49,56),WALK=_I(54,49,54,49,53,53,57,50,57),RUN=_I(54,49,54,49,53,49,56,53,54),JUMP=_I(54,49,54,49,52,51,51,55,56)},
    {Name=_S(Qlmqd),IDLE=_I(54,53,54,49,49,56,56,53,50),WALK=_I(54,53,54,49,50,49,49,57,54),RUN=_I(54,53,54,49,49,56,56,53,50),JUMP=_I(54,53,54,49,49,55,56,55,56)},
    {Name=_S(OhyLwdwlrq),IDLE=_I(54,49,54,48,48,54,55,55,56),WALK=_I(54,49,54,48,49,48,51,56,50),RUN=_I(54,49,54,48,49,48,51,56,50)},
}
for i=1,242 do local b=Packs[(i%8)+1] table.insert(Packs,{Name=_S(Sdfn0)..(i+12).._S(0#)..b.Name.._S(0Y)..i,IDLE=b.IDLE,WALK=b.WALK,RUN=b.RUN,JUMP=b.JUMP,FALL=b.FALL}) end
local Emotes={
    {Name=_S(Eudcloldq0Ixqn0Skrqn),Id=_I(49,51,53,48,52,57,51,57,54,49,50)},
    {Name=_S(Y0SRVH0#0Wrp|0>473U@),Id=_I(49,48,50,49,52,52,49,56,50,56,51)},
    {Name=_S(Julg|0GdqfH),Id=_I(49,50,50,57,50,56,55,53,56,54,51)},
    {Name=_S(Prqnh|0>YLUDO@),Id=_I(51,51,51,51,52,57,57,53,48,56)},
}

local currentTab=_S(Ixoo)
local function setAndPlay(folderName,id,forcePlay)
    local char=LP.Character if not char then return end
    local hum=char:FindFirstChildOfClass(_S(Kxpdqrlg)) local animate=char:FindFirstChild(_S(Dqlpdwh)) or char:FindFirstChild(_S(dqlpdwh)) if not hum then return end
    local cleanId=tostring(id):match(_S(3g+)) if not cleanId then return end
    local asset=_S(ue{dvvhwlg=22)..cleanId
    if animate then
        local folder=animate:FindFirstChild(folderName) or animate:FindFirstChild(string.lower(folderName))
        if folder then for _,v in ipairs(folder:GetChildren()) do if v:IsA(_S(Dqlpdwlrq)) then v.AnimationId=asset end end end
        animate.Disabled=true task.wait(0.08) animate.Disabled=false
    end
    if forcePlay then for _,tr in pairs(hum:GetPlayingAnimationTracks()) do tr:Stop(0.1) end task.wait(0.1) local a=Instance.new(_S(Dqlpdwlrq)) a.AnimationId=asset local t=hum:LoadAnimation(a) t.Priority=Enum.AnimationPriority.Action t.Looped=true t:Play() end
end
local function ApplyFullPack(packData)
    local char=LP.Character local hum=char and char:FindFirstChildOfClass(_S(Kxpdqrlg)) if hum then for _,tr in pairs(hum:GetPlayingAnimationTracks()) do tr:Stop(0) end end task.wait(0.1)
    for k,v in pairs(packData) do if k~=_S(Qdph) and v and v~="" then setAndPlay(string.lower(k),v,false) task.wait(0.12) end end
end
local function PlayEmote(id)
    local char=LP.Character local hum=char and char:FindFirstChildOfClass(_S(Kxpdqrlg)) if not hum then return end
    for _,tr in pairs(hum:GetPlayingAnimationTracks()) do tr:Stop(0.1) end
    local a=Instance.new(_S(Dqlpdwlrq)) a.AnimationId=_S(ue{dvvhwlg=22)..tostring(id):match(_S(3g+)) local t=hum:LoadAnimation(a) t.Priority=Enum.AnimationPriority.Action t.Looped=false t:Play()
end
local function CreateButtons(filter)
    for _,v in ipairs(Content:GetChildren()) do if v:IsA(_S(Wh{wExwwrq)) then v:Destroy() end end
    local list={} if currentTab==_S(Ixoo) or currentTab==_S(Pl{) then list=Packs else list=Emotes end
    for _,data in ipairs(list) do
        if filter=="" or data.Name:lower():find(filter:lower()) then
            if currentTab==_S(Ixoo) then
                local b=Instance.new(_S(Wh{wExwwrq),Content) b.Text=data.Name.._S(0>IXOO@) b.BackgroundColor3=Color3.fromRGB(0,150,100) b.TextColor3=Color3.new(1,1,1) b.Font=Enum.Font.GothamBold b.TextSize=11 Instance.new(_S(XLFruqhu),b).CornerRadius=UDim.new(0,6) b.MouseButton1Click:Connect(function() ApplyFullPack(data) end)
            elseif currentTab==_S(Pl{) then
                for k,v in pairs(data) do if k~=_S(Qdph) then local b=Instance.new(_S(Wh{wExwwrq),Content) b.Text=data.Name.._S(0)..k b.BackgroundColor3=Color3.fromRGB(60,60,60) b.TextColor3=Color3.new(1,1,1) b.TextSize=10 Instance.new(_S(XLFruqhu),b).CornerRadius=UDim.new(0,6) b.MouseButton1Click:Connect(function() setAndPlay(string.lower(k),v,true) end) end end
            else
                local b=Instance.new(_S(Wh{wExwwrq),Content) b.Text=data.Name b.BackgroundColor3=Color3.fromRGB(90,70,180) b.TextColor3=Color3.new(1,1,1) b.Font=Enum.Font.GothamBold b.TextSize=10 Instance.new(_S(XLFruqhu),b).CornerRadius=UDim.new(0,6) b.MouseButton1Click:Connect(function() PlayEmote(data.Id) end)
            end
        end
    end
    task.wait(0.1) Content.CanvasSize=UDim2.new(0,0,0,Grid.AbsoluteContentSize.Y+20)
end
local function MakeTab(name,pos)
    local b=Instance.new(_S(Wh{wExwwrq),TabFrame) b.Text=name b.Size=UDim2.new(0,85,0,25) b.Position=UDim2.new(0,pos,0,5) b.BackgroundColor3=Color3.fromRGB(50,50,50) b.TextColor3=Color3.new(1,1,1) b.Font=Enum.Font.GothamBold b.TextSize=12 Instance.new(_S(XLFruqhu),b).CornerRadius=UDim.new(0,6) b.MouseButton1Click:Connect(function() currentTab=name CreateButtons(SearchBox.Text) end)
end
MakeTab(_S(Pl{),5) MakeTab(_S(Ixoo),95) MakeTab(_S(Hprwhv),185)
SearchBox:GetPropertyChangedSignal(_S(Wh{w)):Connect(function() CreateButtons(SearchBox.Text) end)
local dragging,dragInput,dragStart,startPos
local function update(input) local delta=input.Position-dragStart MainFrame.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y) end
TitleBar.InputBegan:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=true dragStart=input.Position startPos=MainFrame.Position input.Changed:Connect(function() if input.UserInputState==Enum.UserInputState.End then dragging=false end end) end end)
TitleBar.InputChanged:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch then dragInput=input end end)
UIS.InputChanged:Connect(function(input) if input==dragInput and dragging then update(input) end end)
ExitBtn.MouseButton1Click:Connect(function() MainFrame.Visible=false end)
UIS.InputBegan:Connect(function(input,gp) if not gp and input.KeyCode==Enum.KeyCode.RightShift then MainFrame.Visible=not MainFrame.Visible end end)
CreateButtons("")
print(_S(UHQ]0REI0Y46C40VXOWUD0ORDGHG0#0HQFU|SWHG0QDPHV0#0LGV0#0DQWL0GHR0#0FUDV0#0DFWLYH))
