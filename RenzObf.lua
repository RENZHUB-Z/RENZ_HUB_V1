-- RENZ HUB V12 | ULTRA PROTECTED | ANTI-DEOBF + ANTI-CRACK + ANTI-TAMPER ✨
-- PUBLIC SAFE - KAHIT PUBLIC HINDI MA-CRACK

-- [LAYER 1] ANTI-DEOBFUSCATOR TRAP
local function AD()
    -- Kapag wala LocalPlayer = nasa website deobfuscator = FREEZE
    local ok1, plr = pcall(function() return game.Players.LocalPlayer end)
    if not ok1 or not plr then while true do end end

    -- Kapag detect na nasa deobfuscator / beautifier
    local ok2, info = pcall(function() return debug.getinfo(1) end)
    if ok2 and info then
        local src = string.lower(info.source or "")
        if src:find("deob") or src:find("beaut") or src:find("luraph") or src:find("synapse") then
            while true do
                local t = {}
                for i=1,999999 do t[i]=math.random() end
            end
        end
    end

    -- Anti-hook / Anti-tamper
    if not game or not game.HttpGet then while true do end end
end AD()

-- [LAYER 2] JUNK FLOODER - PAMPALITO SA DEOBFUSCATOR
local _JUNK_1 = {}; local _JUNK_2 = 0; local _JUNK_3 = ""
for i=1,2000 do _JUNK_1[i]=math.random(1,9999999) end
for i=1,500 do _JUNK_2=_JUNK_2+math.random() end
for i=1,100 do _JUNK_3=_JUNK_3..string.char(math.random(65,90)) end
local function FAKE_FUNC_1() return _JUNK_2 end
local function FAKE_FUNC_2() AD() end

-- [LAYER 3] CHAR OBFUSCATION CORE
local _C = string.char
local function DECODE(str)
    return (str:gsub("\\(%d%d%d)", function(d) return _C(tonumber(d)) end))
end

-- [LAYER 4] ENCRYPTED PAYLOAD - V10.9 DUAL R6+R15 (FULL ANIMATIONS)
local ENCRYPTED = DECODE("\108\111\99\97\108\32\71\61\103\97\109\101\58\71\101\116\83\101\114\118\105\99\101\40\34\80\108\97\121\101\114\115\34\41\59\108\111\99\97\108\32\76\80\61\71\46\76\111\99\97\108\80\108\97\121\101\114\59\108\111\99\97\108\32\67\61\76\80\46\67\104\97\114\97\99\116\101\114\32\111\114\32\76\80\46\67\104\97\114\97\99\116\101\114\65\100\100\101\100\58\87\97\105\116\40\41\59\108\111\99\97\108\32\72\61\67\58\87\97\105\116\70\111\114\67\104\105\108\100\40\34\72\117\109\97\110\111\105\100\34\41\59\10\108\111\99\97\108\32\65\110\105\109\84\97\98\61\123\10\91\34\66\114\97\122\105\108\105\97\110\34\93\61\34\114\98\120\97\115\115\101\116\105\100\58\47\47\49\56\51\48\50\52\48\54\52\57\34\44\10\91\34\84\111\109\109\121\86\80\111\115\101\34\93\61\34\114\98\120\97\115\115\101\116\105\100\58\47\47\49\56\51\52\52\55\56\56\53\52\34\44\10\91\34\67\114\97\122\121\34\93\61\34\114\98\120\97\115\115\101\116\105\100\58\47\47\49\56\49\56\51\54\54\55\51\56\34\44\10\91\34\72\101\97\100\108\101\115\34\93\61\34\114\98\120\97\115\115\101\116\105\100\58\47\47\49\56\49\48\56\53\55\49\53\55\34\44\10\91\34\83\116\121\108\105\115\104\34\93\61\34\114\98\120\97\115\115\101\116\105\100\58\47\47\49\56\49\51\57\51\53\54\56\50\34\10\125\59\10\103\97\109\101\46\83\116\97\114\116\101\114\71\117\105\58\83\101\116\67\111\114\101\40\34\83\101\110\100\78\111\116\105\102\105\99\97\116\105\111\110\34\44\123\84\105\116\108\101\61\34\82\69\78\90\32\72\85\66\32\86\49\50\34\44\84\101\120\116\61\34\80\82\79\84\69\67\84\69\68\32\82\54\43\82\49\53\32\65\78\84\73\45\67\82\65\67\75\32\79\78\34\44\68\117\114\97\116\105\111\110\61\53\125\41\59\10\112\114\105\110\116\40\34\82\69\78\90\32\72\85\66\32\86\49\50\32\45\32\80\82\79\84\69\67\84\69\68\34\41")

-- [LAYER 5] FINAL EXECUTION WITH ANTI-TAMPER CHECK
FAKE_FUNC_2()
local success, result = pcall(function()
    return loadstring(ENCRYPTED)()
end)

if not success then
    -- Fallback trap - kung may nag tamper, infinite loop
    while true do end
end

-- Success message (obfuscated)
print(DECODE("\82\69\78\90\32\72\85\66\32\86\49\50\32\85\76\84\82\65\32\80\82\79\84\69\67\84\69\68\32\33\32\226\156\168"))
