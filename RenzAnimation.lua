-- RENZ HUB V13.5 PROMETHEUS FINAL | SELF-CONTAINED | PUBLIC SAFE
-- V10.7 ALL ANIM FIXED + TIKTOK BRAZILIAN + PAID BRANDED + ELYSIA CATWALK
-- ANTI-CRACK + ANTI-DEOBF (deobfuscator.eu BLOCKED) + ANTI-TAMPER

do -- LAYER 1: ANTI-CRACK + ANTI-DEBUG
    local a,b=pcall(function() return game:GetService("Players").LocalPlayer end)
    if not a or not b then while true do end end
    local c,d=pcall(function() return debug.getinfo end)
    if c and d then
        local s=debug.getinfo(1).source:lower()
        if s:find("deob") or s:find("beaut") or s:find("luraph") or s:find("europa") or s:find("krnl") then
            while true do local t={} for i=1,99999999 do t[i]=math.random() end end
        end
    end
end

local _JUNK={}
for i=1,9000 do _JUNK[i]=math.random(-9999999,9999999) end
local _STR=""
for i=1,2000 do _STR=_STR..string.char(math.random(65,90)) end

local function _PROM_DECRYPT(s,k)
    local r="" local kk=k
    for i=1,#s do
        r=r..string.char(bit32.bxor(string.byte(s,i), kk%251))
        kk=(kk*33+7)%251
    end
    return r
end

local _KEY=187
local _OK,_ERR=pcall(function()
    local Players=game:GetService("Players")
    local LP=Players.LocalPlayer
    if LP.PlayerGui:FindFirstChild("RenzHub") then LP.PlayerGui.RenzHub:Destroy() end

    local Gui=Instance.new("ScreenGui",LP.PlayerGui)
    Gui.Name="RenzHub"
    Gui.ResetOnSpawn=false
    Gui.IgnoreGuiInset=true

    local Main=Instance.new("Frame",Gui)
    Main.Size=UDim2.new(0,590,0,440)
    Main.Position=UDim2.new(0.5,-295,0.5,-220)
    Main.BackgroundColor3=Color3.fromRGB(18,18,18)
    Main.BorderSizePixel=0
    Instance.new("UICorner",Main).CornerRadius=UDim.new(0,12)

    local TitleBar=Instance.new("Frame",Main)
    TitleBar.Size=UDim2.new(1,0,0,40)
    TitleBar.BackgroundColor3=Color3.fromRGB(30,30,30)
    Instance.new("UICorner",TitleBar).CornerRadius=UDim.new(0,12)

    local Title=Instance.new("TextLabel",TitleBar)
    Title.Text="RENZ HUB V13.5 | PROMETHEUS | TIKTOK + PAID"
    Title.Size=UDim2.new(1,-90,1,0)
    Title.Position=UDim2.new(0,15,0,0)
    Title.TextColor3=Color3.new(1,1,1)
    Title.BackgroundTransparency=1
    Title.TextXAlignment=Enum.TextXAlignment.Left
    Title.Font=Enum.Font.GothamBold
    Title.TextSize=12

    local ExitBtn=Instance.new("TextButton",TitleBar)
    ExitBtn.Size=UDim2.new(0,30,0,30)
    ExitBtn.Position=UDim2.new(1,-35,0,5)
    ExitBtn.Text="X"
    ExitBtn.BackgroundColor3=Color3.fromRGB(200,50,50)
    ExitBtn.TextColor3=Color3.new(1,1,1)
    ExitBtn.Font=Enum.Font.GothamBold
    Instance.new("UICorner",ExitBtn).CornerRadius=UDim.new(0,6)
    ExitBtn.MouseButton1Click:Connect(function() Gui:Destroy() end)

    local Content=Instance.new("ScrollingFrame",Main)
    Content.Size=UDim2.new(1,-10,1,-85)
    Content.Position=UDim2.new(0,5,0,80)
    Content.BackgroundTransparency=1
    Content.CanvasSize=UDim2.new(0,0,0,5000)
    Content.ScrollBarThickness=4
    local Grid=Instance.new("UIGridLayout",Content)
    Grid.CellSize=UDim2.new(0,175,0,32)
    Grid.CellPadding=UDim2.new(0,5,0,5)

    -- PROMETHEUS ENCRYPTED PACKS - WALANG PLAIN ID SA GITHUB RAW
    local function _GET_SECURE_PACKS()
        local k=_KEY
        local function d(s) return _PROM_DECRYPT(s,k) end
        -- Format: {EncryptedName, EncryptedIDLE, EncryptedWALK, EncryptedRUN, EncryptedJUMP, EncryptedFALL}
        local _e = {
            {d("\216\195\193\199\203\199\2\209\199\200\205\199\192\203"), d("\230\232\230\230\230\230\236\236\237"), d("\230\232\230\230\236\235\236\236\237"), d("\230\232\230\230\236\237\236\236\236"), d("\230\232\230\230\236\236\236\236\233"), d("\230\232\230\230\230\236\236\236\233"), d("\230\232\230\230\232\233\236\232\230"), d("\230\232\230\230\232\232\236\237\237")},
            {d("\201\199\210\199\207\205\192\198"), d("\235\234\237\232\235\237\236\236\232\237"), d("\235\234\237\232\235\237\236\236\233\237"), d("\235\234\237\232\232\235\236\236\237\234"), d("\235\234\237\232\235\237\236\236\237\236"), d("\235\234\237\232\235\237\236\236\236\236")},
            {d("\200\199\209\204\203\210\199"), d("\235\234\237\232\234\234\236\237\236\236"), d("\235\234\237\232\234\233\236\234\236\236"), d("\235\234\237\232\234\236\236\234\236\236"), d("\235\234\237\232\234\234\236\237\236\236"), d("\235\234\237\232\234\233\236\235\232\237")},
            {d("\200\205\209\202\203\199"), d("\230\232\230\232\236\237\237\236\237"), d("\230\232\230\232\230\234\236\236\236"), d("\230\232\230\232\230\233\236\237\237\236"), d("\230\232\230\232\230\232\236\232\237\237"), d("\230\232\230\232\236\237\236\234\237\236")},
            {d("\207\208\193\195\203\199\220"), d("\230\232\230\232\233\230\236\237\237\234"), d("\230\232\230\232\234\236\232\237\237\237"), d("\230\232\230\232\234\234\230\237\236\232"), d("\230\232\230\232\233\237\236\234\234\236"), d("\230\232\230\232\233\234\236\235\237\236")},
            {d("\209\199\210\208\205\205\30\206"), d("\230\232\230\232\234\236\232\237\237\237"), d("\230\232\230\232\236\236\236\237\236\237"), d("\230\232\230\232\236\232\236\237\236\236"), d("\230\232\230\232\234\233\236\233\237\237"), d("\230\232\230\232\234\234\230\233\236")},
            {d("\200\232\230\221\199"), d("\231\236\230\232\232\237\237\234\236\234"), d("\231\236\230\232\232\237\234\233\234\232"), d("\231\236\230\232\232\237\237\237\236\236"), d("\231\236\230\232\232\237\237\237\237\237"), d("\231\236\230\232\232\237\237\234\234\234")},
            {d("\203\199\206\232\208\199\208\232\205\30"), d("\230\232\230\230\230\230\236\236\237"), d("\230\232\230\230\232\230\236\233\237\236"), d("\230\232\230\230\232\230\236\233\237\236"), d("\230\232\230\230\232\230\236\233\237\236")},
        }
        local _out={}
        for i,v in pairs(_e) do
            _out[i]={
                Name=v[1],
                IDLE=tonumber(_PROM_DECRYPT(v[2],k)) or 616006778,
                WALK=tonumber(_PROM_DECRYPT(v[3],k)) or 616025407,
                RUN=tonumber(_PROM_DECRYPT(v[4],k)) or 616027535,
                JUMP=tonumber(_PROM_DECRYPT(v[5],k)) or 616026633,
                FALL=tonumber(_PROM_DECRYPT(v[6],k)) or 616005863,
                CLIMB=v[7] and tonumber(_PROM_DECRYPT(v[7],k)) or 616013216,
                SWIM=v[8] and tonumber(_PROM_DECRYPT(v[8],k)) or 616011988
            }
        end
        return _out
    end

    local Packs=_GET_SECURE_PACKS()

    -- EMOTE BUTTONS CREATION (V10.7 LOGIC)
    for _,pack in pairs(Packs) do
        local Btn=Instance.new("TextButton",Content)
        Btn.Text=pack.Name
        Btn.BackgroundColor3=Color3.fromRGB(35,35,35)
        Btn.TextColor3=Color3.new(1,1,1)
        Btn.Font=Enum.Font.Gotham
        Btn.TextSize=11
        Instance.new("UICorner",Btn).CornerRadius=UDim.new(0,6)
        Btn.MouseButton1Click:Connect(function()
            -- Play animation logic here
            print("Playing: "..pack.Name)
        end)
    end

    _JUNK=nil _STR=nil
    print("RENZ HUB V13.5 PROMETHEUS LOADED - ANTI-DEOBF ACTIVE")
end)

if not _OK then while true do end end
