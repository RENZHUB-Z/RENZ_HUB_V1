-- RENZHUB V1 | INSTANT ONE TAP CODY | SAFE ZONE EDGE FIXED
-- Built by RENZHUB - No more Delivery Failed

getgenv().RENZHUB = true

local lp = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")

local CFG = {
    Height = 15,
    LandOffset = 5,
    HopLift = 15,
    HopRatio = 2.5,
    HopMin = 20,
    HopGap = 0.02,
    DropDelay = 0.01,
    GrabInterval = 0.01,
    CarryRatio = 1.8,
    EasyRatio = 2.0,
    SpeedCap = 1.5
}

local function getHRP()
    return lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
end

local function getSafeCFrame()
    -- hanap safe zone part (white area sa video mo)
    for _,v in pairs(workspace:GetDescendants()) do
        if v.Name:lower():find("safe") and v:IsA("BasePart") then
            return v.CFrame + Vector3.new(0,3,0)
        end
    end
    -- fallback kung wala, likod lang ng 5 studs
    local hrp = getHRP()
    if hrp then
        return hrp.CFrame * CFrame.new(0,0,-CFG.LandOffset)
    end
    return CFrame.new(0,10,0)
end

-- ONE TAP CORE
_G.OneTapSteal = function(target)
    local hrp = getHRP()
    if not hrp then return end
    
    local part = target
    if target:IsA("Model") then
        part = target.PrimaryPart or target:FindFirstChildWhichIsA("BasePart")
    end
    if not part then return end

    -- 1. TP sa egg (0.01 sec lang gaya ng video 2)
    hrp.CFrame = CFrame.new(part.Position + Vector3.new(0,3,2), part.Position)
    task.wait(CFG.GrabInterval)
    
    -- 2. Steal
    local prompt = target:FindFirstChildWhichIsA("ProximityPrompt", true)
    if prompt then
        fireproximityprompt(prompt)
    else
        -- fallback remote
        pcall(function()
            RS.Packages.Knit.Services.EggService.RF.StealEgg:InvokeServer(target)
        end)
    end
    
    task.wait(0.08)
    
    -- 3. INSTANT balik SAFE ZONE (kita mo sa video 2, 5 studs lang atras)
    hrp.CFrame = getSafeCFrame()
    task.wait(CFG.DropDelay)
    
    -- 4. Auto Drop
    pcall(function()
        RS.Packages.Knit.Services.EggService.RF.DropEgg:InvokeServer()
    end)
end

-- AUTO EDGE LOOP - gaya nung Refresh Loop ON sa video 2 mo
spawn(function()
    while task.wait(0.1) do
        if not getgenv().AutoEdge then continue end
        local hrp = getHRP()
        if not hrp then continue end
        
        local closest, dist = nil, 60 -- 60 studs lang malapit sa SAFE ZONE
        for _,v in pairs(workspace:GetDescendants()) do
            if v.Name:lower():find("egg") and v:IsA("BasePart") and v.Parent.Name:lower():find("egg") then
                local d = (hrp.Position - v.Position).Magnitude
                if d < dist then
                    closest = v.Parent
                    dist = d
                end
            end
        end
        
        if closest then
            _G.OneTapSteal(closest)
        end
    end
end)

-- UI
print("==================================")
print("[RENZHUB] ONE TAP LOADED!")
print("Use: _G.OneTapSteal(egg)")
print("Auto: getgenv().AutoEdge = true")
print("Fixed Delivery Failed - SAFE ZONE EDGE")
print("==================================")
