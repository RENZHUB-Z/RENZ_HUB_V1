local v1 = ...
local CFrame_ = CFrame
local cFrameNew = CFrame_ and CFrame_.new
local lookAt = CFrame_ and CFrame_.lookAt
local Angles = CFrame_ and CFrame_.Angles
local v6 = v1

local function v7(p1)
	if type(p1) ~= "function" then
		return false
	end

	local ok, result = pcall(p1, "e5564300c360ac729086e2cc806e828a84877f1eb8e5d974d873e065224901555fb8821590a33bacc61e39701cf9b46bd25bf5f0595bbe24655141438e7a100b", "", "d75a980182b10ab7d54bfed3c964073a0ee172f3daa62325af021a68f707511a")

	if not ok or result ~= true then
		return false
	end

	local ok2, result2 = pcall(p1, ("e5564300c360ac729086e2cc806e828a84877f1eb8e5d974d873e065224901555fb8821590a33bacc61e39701cf9b46bd25bf5f0595bbe24655141438e7a100b"):sub(1, 126) .. "00", "", "d75a980182b10ab7d54bfed3c964073a0ee172f3daa62325af021a68f707511a")

	if not ok2 or result2 ~= false then
		return false
	end

	local ok3, result3 = pcall(p1, "e5564300c360ac729086e2cc806e828a84877f1eb8e5d974d873e065224901555fb8821590a33bacc61e39701cf9b46bd25bf5f0595bbe24655141438e7a100b", "zeroin_differential_test", "d75a980182b10ab7d54bfed3c964073a0ee172f3daa62325af021a68f707511a")

	if not ok3 or result3 ~= false then
		return false
	end

	local ok4, result4 = pcall(p1, "e5564300c360ac729086e2cc806e828a84877f1eb8e5d974d873e065224901555fb8821590a33bacc61e39701cf9b46bd25bf5f0595bbe24655141438e7a100b", "", ("d75a980182b10ab7d54bfed3c964073a0ee172f3daa62325af021a68f707511a"):sub(1, 62) .. "00")

	if ok4 and result4 == false then
		return true
	end

	return false
end
local function v16(p2)
	if type(p2) ~= "table" or p2.valid ~= true then
		return false, "Execution rejected: Script was not launched via Zeroin Key System."
	end

	local ok, result = pcall(function()
		return game:GetService("RbxAnalyticsService"):GetClientId()
	end)
	local v19 = ok and result and result ~= "" and tostring(result) or tostring(game:GetService("Players").LocalPlayer.UserId)

	if tostring(p2.hwid) ~= v19 then
		return false, "Hardware ID mismatch: Unauthorized device detected."
	end

	local now = os.time()
	local v21 = now - (tonumber(p2.timestamp) or tonumber(p2.sessionTime) or now)

	if v21 > 300 or v21 < -100 then
		return false, "Session expired: Please re-authenticate via Zeroin Key System."
	end

	if not p2.signature or not p2.nonce then
		return false, "Security error: Cryptographic signature missing."
	end

	local verify = p2.verify

	if not v7(verify) then
		local v23 = tostring(p2.serverUrl or "https://zeroinhub.com")
		local ok2, result2 = pcall(function()
			return game:HttpGet(v23 .. "/api/ed25519")
		end)

		if ok2 and result2 and result2 ~= "" then
			local ok3, result3 = pcall(loadstring, result2)

			if ok3 and type(result3) == "function" then
				local ok4, result4 = pcall(result3)

				if ok4 and result4 and type(result4.verify) == "function" then
					verify = result4.verify
				end
			end
		end
	end

	if not v7(verify) then
		return false, "Security error: Cryptographic verification engine spoofed or unavailable."
	end

	local v30 = tostring(p2.nonce) .. "|true|" .. tostring(p2.message or "")
	local ok2, result2 = pcall(verify, tostring(p2.signature), v30, "8ea91cb482075e9bd4f19a3b0e2278a02efee3f20ab6d2b2812b235826b8f95e")

	if ok2 and result2 == true then
		return true
	end

	return false, "Security error: Signature verification failed (tampered payload detected)."
end

local v33, v34 = v16(v6)

if not v33 then
	pcall(function()
		game:GetService("Players").LocalPlayer:Kick("\n[Zeroin Security]\n" .. tostring(v34 or "Unauthorized execution.") .. "\nPlease launch the script via Zeroin Key System.")
	end)

	return
end

print("[Zeroin Hub] Authentication successful. Initializing script...")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local genv = getgenv and getgenv() or _G

if type(genv.__ZeroinGlobalConnectionsCleanup) == "function" then
	pcall(genv.__ZeroinGlobalConnectionsCleanup)
end

local t1 = {}
local u43 = true

local function v44(p3)
	if p3 and not u43 then
		pcall(p3.Disconnect, p3)
	elseif p3 then
		table.insert(t1, p3)
	end

	return p3
end

genv.__ZeroinGlobalConnectionsCleanup = function()
	u43 = false

	for _, v in ipairs(t1) do
		pcall(v.Disconnect, v)
	end

	table.clear(t1)
end
genv.__ZeroinIdentityGetter = genv.getthreadidentity or genv.get_thread_identity or genv.getidentity or genv.getthreadcontext or genv.get_thread_context
genv.__ZeroinIdentitySetter = genv.setthreadidentity or genv.set_thread_identity or genv.setidentity or genv.setthreadcontext or genv.set_thread_context

local __ZeroinIdentitySetter = genv.__ZeroinIdentitySetter

if type(__ZeroinIdentitySetter) == "function" then
	pcall(__ZeroinIdentitySetter, 8)
	genv.__ZeroinUICapabilityIdentity = 8
end

genv.__ZeroinSetCapFps = function(p4)
	local v48 = math.clamp(math.floor(tonumber(p4) or 240), 1, 999)
	local setfpscap_ = rawget(_G, "setfpscap") or rawget(_G, "set_fps_cap") or type(setfpscap) == "function" and setfpscap

	if type(setfpscap_) == "function" then
		return pcall(setfpscap_, v48)
	end

	return false
end

local function v50()
end

genv.__ZeroinEnterUICallback = v50
genv.__ZeroinRunUICallback = function(p5, ...)
	return p5(...)
end
genv.__ZeroinWrapUICallback = function(p6)
	return p6
end
genv.__ZeroinResolveUIHost = function()
	local cloneref = genv.cloneref
	local LocalPlayer2 = Players.LocalPlayer
	local PlayerGui = LocalPlayer2

	if PlayerGui then
		PlayerGui = LocalPlayer2:FindFirstChildOfClass("PlayerGui") or LocalPlayer2:FindFirstChild("PlayerGui") or type(LocalPlayer2.WaitForChild) == "function" and LocalPlayer2:WaitForChild("PlayerGui", 5)
	end

	if type(cloneref) == "function" and PlayerGui then
		local ok, result = pcall(cloneref, PlayerGui)

		if ok and result then
			PlayerGui = result
		end
	end

	if PlayerGui then
		genv.__ZeroinUIHost = PlayerGui

		return PlayerGui
	end

	local __ZeroinUIHost = genv.__ZeroinUIHost

	if typeof(__ZeroinUIHost) == "Instance" and __ZeroinUIHost.Parent ~= nil and __ZeroinUIHost.Name ~= "RobloxGui" and pcall(function()
		local ScreenGui = Instance.new("ScreenGui")

		ScreenGui.Name = "__ZeroinProbe"
		ScreenGui.ResetOnSpawn = false
		ScreenGui.Parent = __ZeroinUIHost

		local Frame = Instance.new("Frame")

		Frame.Parent = ScreenGui
		Frame:Destroy()
		ScreenGui:Destroy()
	end) then
		return __ZeroinUIHost
	end

	local t2 = {}
	local t3 = {}

	local function v61(p7)
		if typeof(p7) == "Instance" and p7.Name ~= "RobloxGui" then
			if not t3[p7] then
				t3[p7] = true
				table.insert(t2, p7)
			end
		end
	end

	for _, v in ipairs({
		"gethui",
		"get_hidden_gui",
		"gethiddengui"
	}) do
		local v64 = genv[v]

		if type(v64) == "function" then
			local ok, result = pcall(v64)

			if ok then
				v61(result)
			end
		end
	end

	local ok, result = pcall(function()
		local CoreGui = game:GetService("CoreGui")

		return type(cloneref) == "function" and cloneref(CoreGui) or CoreGui
	end)

	if ok then
		v61(result)
	end

	local s1 = "UI host unavailable"

	for _, v in ipairs(t2) do
		local ok2, result2 = pcall(function()
			local ScreenGui = Instance.new("ScreenGui")

			ScreenGui.Name = "__ZeroinProbe"
			ScreenGui.ResetOnSpawn = false
			ScreenGui.Parent = v

			local Frame = Instance.new("Frame")

			Frame.Parent = ScreenGui
			Frame:Destroy()
			ScreenGui:Destroy()
		end)

		if ok2 then
			genv.__ZeroinUIHost = v

			return v
		end

		s1 = tostring(result2)
	end

	genv.__ZeroinUIHost = nil

	return nil, s1
end
genv.__ZeroinParentGui = function(p8)
	local v77, v78 = genv.__ZeroinResolveUIHost()

	if not v77 or typeof(p8) ~= "Instance" then
		return false, v78
	end

	if p8:IsA("ScreenGui") then
		pcall(function()
			p8.ResetOnSpawn = false
		end)
	end

	genv["__Stored_" .. tostring(p8.Name)] = p8

	local syn_ = genv.syn
	local protect_gui = syn_ and syn_.protect_gui or genv.protect_gui

	if type(protect_gui) == "function" then
		pcall(protect_gui, p8)
	end

	local ok, result = pcall(function()
		p8.Parent = v77
	end)

	return ok, result
end
pcall(function()
	local function v83(child)
		if child then
			if child:IsA("ScreenGui") then
				pcall(function()
					child.ResetOnSpawn = false
				end)

				local v84 = tostring(child.Name)

				if v84:find("Zeroin") or v84 == "NotifyGui" or v84 == "ToggleUIZeroin" then
					genv["__Stored_" .. v84] = child
				end
			end
		end
	end

	local v85 = genv.__ZeroinResolveUIHost()

	if v85 then
		for _, child in ipairs(v85:GetChildren()) do
			v83(child)
		end

		v44(v85.ChildAdded:Connect(v83))
	end

	v44(Players.LocalPlayer.CharacterAdded:Connect(function()
		task.wait(0.3)

		local v88 = genv.__ZeroinResolveUIHost()

		if v88 then
			for _, v in ipairs({
				"ZeroinOnTop",
				"ToggleUIZeroin",
				"ZeroinEggPanelUI",
				"NotifyGui",
				"ZeroinDiscordPrompt"
			}) do
				local v91 = genv["__Stored_" .. v]

				if v91 and typeof(v91) == "Instance" then
					pcall(function()
						v91.ResetOnSpawn = false

						if v91.Parent ~= v88 then
							v91.Parent = v88
						end
					end)
				end
			end
		end
	end))
end)

local v92, v93 = genv.__ZeroinResolveUIHost()

if not v92 then
	warn("[ZeroinUI] CoreGui unavailable: " .. tostring(v93))
end

pcall(function()
	local t4 = {
		"ZeroinOnTop",
		"ToggleUIZeroin",
		"NotifyGui",
		"ZeroinDiscordPrompt",
		"ZeroinEggPanelUI"
	}
	local t5 = {}
	local t6 = {}

	local function v97(p9)
		if not (typeof(p9) ~= "Instance" or t6[p9]) then
			t6[p9] = true
			table.insert(t5, p9)
		end
	end

	v97(LocalPlayer:FindFirstChildOfClass("PlayerGui"))
	v97(genv.__ZeroinUIHost)
	pcall(function()
		v97(game:GetService("CoreGui"))
	end)

	for _, v in ipairs({
		"gethui",
		"get_hidden_gui",
		"gethiddengui"
	}) do
		local v100 = genv[v]

		if type(v100) == "function" then
			local ok, result = pcall(v100)

			if ok then
				v97(result)
			end
		end
	end

	for _, v in ipairs(t5) do
		for _, v2 in ipairs(t4) do
			local v107 = v and v:FindFirstChild(v2)

			if v107 then
				v107:Destroy()
			end
		end
	end
end)

if type(genv.__ZeroinTweenRuntimeCleanup) == "function" then
	pcall(genv.__ZeroinTweenRuntimeCleanup)
end

if type(genv.__ZeroinScrambleCleanup) == "function" then
	pcall(genv.__ZeroinScrambleCleanup)
end

if type(genv.__ZeroinFuseCleanup) == "function" then
	pcall(genv.__ZeroinFuseCleanup)
end

if type(genv.__ZeroinAutoMutateCleanup) == "function" then
	pcall(genv.__ZeroinAutoMutateCleanup)
end

if type(genv.__ZeroinAntiAfkCleanup) == "function" then
	pcall(genv.__ZeroinAntiAfkCleanup)
end

if type(genv.__ZeroinVisualCleanup) == "function" then
	pcall(genv.__ZeroinVisualCleanup)
end

if type(genv.__ZeroinEggRuntimeCleanup) == "function" then
	pcall(genv.__ZeroinEggRuntimeCleanup)
end

if type(genv.__ZeroinAntiGuardCleanup) == "function" then
	pcall(genv.__ZeroinAntiGuardCleanup)
end

if type(genv.__ZeroinRiftCleanup) == "function" then
	pcall(genv.__ZeroinRiftCleanup)
end

if type(genv.__ZeroinBossCleanup) == "function" then
	pcall(genv.__ZeroinBossCleanup)
end

if type(genv.__ZeroinWebhookCleanup) == "function" then
	pcall(genv.__ZeroinWebhookCleanup)
end

genv.__ZeroinTweenRuntimeGeneration = (genv.__ZeroinTweenRuntimeGeneration or 0) + 1

local __ZeroinTweenRuntimeGeneration = genv.__ZeroinTweenRuntimeGeneration
local t7 = {
	KEY = "__FyyStealAnEggMovementSpoof",
	VERSION = 436,
	INTEGRITY_KEY = "__FyyStealAnEggIntegritySpoof",
	SIGNAL = "ClientCharacter: GetDebugSnapshot",
	HEADROOM = 1.35,
	CLAMP = 0.15,
	PADDING = 24,
	MULTIPLIER = 10,
	MIN_INPUT = 20,
	MAX_INPUT = 120,
	DEF_INPUT = 80,
	MIN_SPEED = 200,
	MAX_SPEED = 1200,
	DEF_SPEED = 800,
	FIELDS = {
		"LastObservedSample",
		"LastSample",
		"LastGoodSample",
		"LastGameplayTrustedSample",
		"LastValidatedSample",
		"LastValidatedGroundedSample",
		"LastConfirmedGroundSample",
		"CandidateGroundedSample"
	}
}
local KEY = t7.KEY
local VERSION = t7.VERSION
local INTEGRITY_KEY = t7.INTEGRITY_KEY
local SIGNAL = t7.SIGNAL
local HEADROOM = t7.HEADROOM
local CLAMP = t7.CLAMP
local PADDING = t7.PADDING
local MIN_SPEED = t7.MIN_SPEED
local MAX_SPEED = t7.MAX_SPEED
local DEF_SPEED = t7.DEF_SPEED
local FIELDS = t7.FIELDS
local u121
local v122 = tostring(math.random(100000, 999999))
local connection
local connection2
local t8 = {}
local u126
local v127

local function v128()
	for _, child in ipairs(Workspace:GetChildren()) do
		if child:IsA("BasePart") and child.Name == "__FyyHoverPad" and child ~= u121 then
			pcall(child.Destroy, child)
		end
	end
end
local function v131(p10)
	if u121 then
		if u121.Parent then
			local Character = LocalPlayer.Character
			local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
			local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

			if not HumanoidRootPart or not Humanoid then
				return false
			end

			local Position = typeof(p10) == "Vector3" and p10 or HumanoidRootPart.Position

			u121.CFrame = cFrameNew(Position.X, Position.Y - (Humanoid.RigType == Enum.HumanoidRigType.R15 and HumanoidRootPart.Size.Y * 0.5 + math.max(Humanoid.HipHeight, 0.5) or HumanoidRootPart.Size.Y * 0.5 + 2) - 0.5 - 0.05, Position.Z)

			return true
		end
	end

	return false
end
local function v136()
	if not u121 or not u121.Parent or u121:GetAttribute("FyyStealRuntimeOwner") ~= v122 then
		v128()

		if u121 and u121.Parent then
			pcall(u121.Destroy, u121)
		end

		local Part = Instance.new("Part")

		Part.Name = "__FyyHoverPad"
		Part:SetAttribute("FyyStealRuntimeOwner", v122)
		Part.Anchored = true
		Part.CanCollide = true
		Part.CanQuery = true
		Part.CanTouch = false
		Part.CastShadow = false
		Part.Transparency = 1
		Part.Material = Enum.Material.SmoothPlastic
		Part.Size = Vector3.new(8, 1, 8)
		u121 = Part
		Part.Parent = Workspace
	end

	v131()

	if not connection then
		connection = RunService.PreSimulation:Connect(function()
			if not v131() then
				v136()
			end
		end)
	end

	if not connection2 then
		connection2 = RunService.PostSimulation:Connect(function()
			v131()
		end)
	end
end
local function v138()
	if connection then
		pcall(connection.Disconnect, connection)
		connection = nil
	end

	if connection2 then
		pcall(connection2.Disconnect, connection2)
		connection2 = nil
	end

	if u121 then
		pcall(u121.Destroy, u121)
		u121 = nil
	end

	v128()
end

v138()

local function v139()
	u126 = nil
end
local function v140(p11, p12)
	if p11 then
		if typeof(p12) == "CFrame" then
			u126 = {
				Character = LocalPlayer.Character,
				RootPart = p11,
				CFrame = p12
			}
		end
	end
end
local function v141()
	local v142 = u126

	if type(v142) ~= "table" or typeof(v142.CFrame) ~= "CFrame" then
		return false
	end

	if LocalPlayer.Character ~= v142.Character or not v142.RootPart or not v142.RootPart.Parent then
		u126 = nil

		return false
	end

	v136()
	v142.RootPart.AssemblyLinearVelocity = Vector3.zero
	v142.RootPart.AssemblyAngularVelocity = Vector3.zero
	v131(v142.CFrame.Position)
	v142.RootPart.CFrame = v142.CFrame
	v131(v142.CFrame.Position)

	return true
end
local function v143()
	local Character = LocalPlayer.Character
	local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")

	for _, v in pairs(t8) do
		if type(v) == "table" then
			v.cancelled = true
		end
	end

	table.clear(t8)

	if HumanoidRootPart then
		HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
		HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
	end

	v139()
	v138()
end

genv.__ZeroinTweenRuntimeCleanup = function()
	for _, v in pairs(t8) do
		if type(v) == "table" then
			v.cancelled = true
		end
	end

	table.clear(t8)
	v139()
	v138()
end

local function v150()
	return getgenv and getgenv() or _G
end
local function v151()
	local v152 = v150()
	local v153 = v152[KEY]

	if type(v153) ~= "table" or v153.Version ~= VERSION then
		if type(v153) == "table" then
			v153.Enabled = false
		end

		v153 = {
			Version = VERSION,
			Installed = false,
			Enabled = false,
			Mode = "StateBaseline",
			Humanoid = nil,
			RootPart = nil,
			WalkSpeed = DEF_SPEED
		}
		v152[KEY] = v153
	end

	return v153
end
local function v154(p13, p14)
	local v155 = v151()

	if not v155 then
		return false
	end

	local Humanoid = p13 and p13:FindFirstChildOfClass("Humanoid")
	local HumanoidRootPart = p13 and p13:FindFirstChild("HumanoidRootPart")

	v155.Humanoid = Humanoid
	v155.RootPart = HumanoidRootPart
	v155.WalkSpeed = math.clamp(tonumber(p14) or DEF_SPEED, MIN_SPEED, MAX_SPEED * HEADROOM)
	v155.Enabled = false

	return Humanoid ~= nil and HumanoidRootPart ~= nil
end
local function v158()
	local v159 = v150()[KEY]

	if type(v159) == "table" then
		v159.Enabled = false
		v159.Humanoid = nil
		v159.RootPart = nil
	end
end
local function v160(p15, p16, p17)
	local u161

	if type(getcallbackvalue) == "function" and type(debug) == "table" and type(debug.getupvalue) == "function" then
		local Signal = ReplicatedStorage:FindFirstChild("Packages") and ReplicatedStorage.Packages:FindFirstChild("Signal")

		if Signal then
			local ok, result = pcall(require, Signal)

			if ok and type(result) == "table" and type(result.Invoked) == "function" then
				local ok2, result2 = pcall(result.Invoked, SIGNAL)

				if ok2 and result2 then
					local ok3, result3 = pcall(getcallbackvalue, result2, "OnInvoke")

					if ok3 and type(result3) == "function" then
						local ok4, result4 = pcall(debug.getinfo, result3)

						if ok4 then
							local function v171(p18, p19, p20)
								if u161 or type(p18) ~= "table" or p19 > 3 or p20[p18] then
									return
								end

								p20[p18] = true

								if rawget(p18, "Player") == p15 and rawget(p18, "Character") == p15.Character and rawget(p18, "Humanoid") == p16 and rawget(p18, "RootPart") == p17 and type(rawget(p18, "SampleHistory")) == "table" and type(rawget(p18, "Evidence")) == "table" then
									u161 = p18

									return
								end

								local n1 = 0

								for _, v in pairs(p18) do
									n1 += 1

									if n1 > 128 then
										break
									end

									if type(v) == "table" then
										v171(v, p19 + 1, p20)
									end
								end
							end

							local n2 = 1
							local nups = result4.nups or 0

							for i = n2, nups do
								local ok5, result5 = pcall(debug.getupvalue, result3, i)

								if not ok5 then
									continue
								end

								if type(result5) ~= "table" then
									continue
								end

								v171(result5, 0, {})

								if u161 then
									break
								end
							end
						end
					end
				end
			end
		end
	end

	if not u161 and type(getgc) == "function" then
		local ok, result = pcall(getgc, true)

		if ok and type(result) == "table" then
			for _, v in ipairs(result) do
				if type(v) == "table" and rawget(v, "Player") == p15 and rawget(v, "Character") == p15.Character and rawget(v, "Humanoid") == p16 and rawget(v, "RootPart") == p17 and type(rawget(v, "SampleHistory")) == "table" and type(rawget(v, "Evidence")) == "table" then
					u161 = v

					break
				end
			end
		end
	end

	return u161
end
local function v184(p21, p22, p23)
	if type(p21) ~= "table" then
		return false
	end

	local value = rawget(p21, "RootPart")
	local CFrame_2 = value and value.Parent and value.CFrame or nil
	local Position = CFrame_2 and CFrame_2.Position or nil
	local vector3 = typeof(p23) == "Vector3" and p23 or Vector3.zero

	local function v189(p24)
		if type(p24) == "table" then
			rawset(p24, "WalkSpeed", p22)

			if CFrame_2 then
				rawset(p24, "CFrame", CFrame_2)
				rawset(p24, "Position", Position)
				rawset(p24, "LinearVelocity", vector3)
				rawset(p24, "AngularVelocity", Vector3.zero)
			end
		end
	end

	for _, v in ipairs(FIELDS) do
		v189(rawget(p21, v))
	end

	local pairs_ = pairs
	local v193 = rawget(p21, "SampleHistory") or {}

	for _, v in pairs_(v193) do
		v189(v)
	end

	local pairs_2 = pairs
	local v197 = rawget(p21, "SafeGroundCheckpoints") or {}

	for _, v in pairs_2(v197) do
		v189(v)
	end

	local value2 = rawget(p21, "Evidence")

	if type(value2) == "table" then
		value2.Speed = 0
		value2.Teleport = 0
		value2.Flight = 0
	end

	local value3 = rawget(p21, "ImpulseContext")

	if type(value3) == "table" then
		local maxHorizontalSpeed = math.max(tonumber(value3.MaxHorizontalSpeed) or 0, p22)
		local v203 = math.max((tonumber(value3.ExpiresAt) or 0) - (tonumber(value3.StartedAt) or 0), CLAMP)

		value3.MaxHorizontalSpeed = maxHorizontalSpeed

		if Position then
			value3.OriginPosition = Position
		end

		value3.MaxHorizontalDistance = math.max(tonumber(value3.MaxHorizontalDistance) or 0, maxHorizontalSpeed * v203 + PADDING * 2)
		v189(value3.PreMovementSafeSample)
	end

	if rawget(p21, "CorrectionContext") == nil then
		rawset(p21, "FirstSuspiciousAt", nil)

		if rawget(p21, "ThreatLevel") == "Observing" then
			rawset(p21, "ThreatLevel", "Trusted")
		end
	end

	return true
end
local function v204()
	local v205 = v150()
	local v206 = v205[INTEGRITY_KEY]

	if type(v206) ~= "table" then
		v206 = {}
		v205[INTEGRITY_KEY] = v206
	end

	return v206
end
local function v207(p25, p26, p27)
	return type(p25) == "table" and rawget(p25, "Player") == LocalPlayer and rawget(p25, "Character") == LocalPlayer.Character and rawget(p25, "Humanoid") == p26 and rawget(p25, "RootPart") == p27
end
local function v208(p28, p29, p30)
	return v207(p28, p29, p30)
end
local function v209(p31, p32, p33)
	local v210 = v204()
	local State = v210.State

	if not v207(State, p31, p32) then
		local now = os.clock()

		if now < (v210.NextSearchAt or 0) then
			return false
		end

		v210.NextSearchAt = now + 0.2
		State = v160(LocalPlayer, p31, p32)
	end

	if not State then
		return false
	end

	if not v208(State, p31, p32) then
		v210.Enabled = false
		v210.Humanoid = p31
		v210.RootPart = p32
		v210.State = State

		return false
	end

	v210.NextSearchAt = 0
	v210.Enabled = true
	v210.Humanoid = p31
	v210.RootPart = p32
	v210.State = State
	v210.WalkSpeed = math.clamp(p33 * HEADROOM, MIN_SPEED, MAX_SPEED * HEADROOM)
	v210.TravelVelocity = Vector3.zero
	v184(State, v210.WalkSpeed, v210.TravelVelocity)

	return true
end
local function v213(p34, p35, p36, p37)
	local v214 = v150()[INTEGRITY_KEY]

	if type(v214) == "table" then
		if v214.Enabled and v214.Humanoid == p34 and v214.RootPart == p35 and v208(v214.State, p34, p35) then
			v214.WalkSpeed = math.clamp(p36 * HEADROOM, MIN_SPEED, MAX_SPEED * HEADROOM)

			if typeof(p37) == "Vector3" then
				v214.TravelVelocity = p37
			elseif typeof(v214.TravelVelocity) ~= "Vector3" then
				v214.TravelVelocity = Vector3.zero
			end

			return v184(v214.State, v214.WalkSpeed, v214.TravelVelocity)
		end
	end

	return false
end
local function v215(p38)
	local v216 = v150()[INTEGRITY_KEY]

	if type(v216) ~= "table" then
		return
	end

	if p38 == nil or v216.Humanoid == p38 then
		v216.Enabled = false
		v216.Humanoid = nil
		v216.RootPart = nil
		v216.State = nil
		v216.TravelVelocity = nil
		v216.NextSearchAt = 0
	end
end

local connection3

local function v218()
	if connection3 then
		return
	end

	connection3 = RunService.PreSimulation:Connect(function()
		if genv.__ZeroinTweenRuntimeGeneration ~= __ZeroinTweenRuntimeGeneration then
			local v219 = connection3

			connection3 = nil

			if v219 then
				pcall(v219.Disconnect, v219)
			end

			return
		end

		local Character = LocalPlayer.Character
		local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
		local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

		if not Character or not HumanoidRootPart or not Humanoid then
			return
		end

		local v223 = v127()

		v154(Character, v223 * HEADROOM)

		if not v213(Humanoid, HumanoidRootPart, v223) then
			v209(Humanoid, HumanoidRootPart, v223)
		end

		v141()
	end)
end
local function v224()
	if connection3 then
		pcall(connection3.Disconnect, connection3)
		connection3 = nil
	end

	v158()
	v215()
end

genv.__ZeroinTweenRuntimeCleanup = function()
	v143()
	v224()
end
v44(RunService.Heartbeat:Connect(function()
	local Character = LocalPlayer.Character
	local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")

	if not HumanoidRootPart then
		return
	end

	local AssemblyLinearVelocity = HumanoidRootPart.AssemblyLinearVelocity

	if Vector3.new(AssemblyLinearVelocity.X, 0, AssemblyLinearVelocity.Z).Magnitude > 400 or math.abs(AssemblyLinearVelocity.Y) > 400 then
		HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(math.clamp(AssemblyLinearVelocity.X, -100, 100), math.clamp(AssemblyLinearVelocity.Y, -100, 100), math.clamp(AssemblyLinearVelocity.Z, -100, 100))
	end
end))
pcall(function()
	game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
end)

local t9 = {
	k = 1000,
	m = 1000000,
	b = 1e9,
	t = 1e12,
	q = 1e15
}

local function v229(p39)
	local v230 = tostring(p39 or ""):lower():gsub("[%s,$]", ""):gsub("/s$", "")

	if v230 == "" then
		return 0, "0"
	end

	local match, v232 = v230:match("^([%d]+%.?[%d]*)([kmbtq]?)$")
	local v233 = tonumber(match)

	if v233 then
		return math.max(0, math.floor(v233 * (t9[v232] or 1) + 0.5)), v230
	end

	return nil
end

local zeroinConfig = {
	AutoSteal = false,
	StealMode = "Tween",
	StealZigzag = false,
	AutoRift = false,
	RiftTargetBanners = { "None" },
	IsRiftTrading = false,
	AutoScramble = false,
	AutoBuyScrambleShop = false,
	ScrambleShopItems = {},
	ScrambleShopAmount = 1,
	ScrambleShopInterval = 15,
	AutoCaptureEgg = false,
	StealFromPlayers = false,
	DropAtFirstArea = false,
	IsScrambleFarming = false,
	RiftRequiredCategories = {},
	RiftObjectiveCategories = {},
	RiftProtectedPetUids = {},
	StealAreas = { "None" },
	StealRarities = { "None" },
	StealNamesFilter = { "None" },
	StealMinValue = 0,
	StealMinValueInput = "0",
	AntiAFK = true,
	AutoReconnect = true,
	AutoPlace = false,
	PlaceRarities = { "None" },
	AutoHatch = false,
	AutoFuse = false,
	AutoFusePriority = "Lowest Rarity",
	AutoFuseRarities = { "All" },
	AutoFuseKeepPerPet = 1,
	AutoFuseMaxWeightKg = 0,
	IsFusing = false,
	AutoMutate = false,
	AutoMutateType = "Boss",
	AutoMutateRarities = {
		"Secret",
		"Eternal",
		"Divine",
		"Cosmic",
		"Mythic"
	},
	AutoMutateNames = {},
	AutoMutateMinValue = 0,
	AutoMutateMinValueInput = "0",
	SellAll = false,
	AutoSell = false,
	SellNames = { "None" },
	SellRarities = { "None" },
	AutoSellEgg = false,
	SellEggRarities = { "None" },
	WebhookEnabled = false,
	WebhookURL = "",
	TweenSpeedMultiplier = 80,
	AntiTreadmillMount = false,
	AutoTreadmillIdle = false,
	AntiGuardKnockback = true,
	GodMode = true,
	EggPredictUI = false,
	EggESP = false,
	PlacedEggESP = false,
	InventoryValueESP = true
}
local t10 = {}

local function v236(p40)
	if not p40 then
		return "Unknown"
	end

	local ok, result = pcall(function()
		return require(game:GetService("ReplicatedStorage").Data.Areas).Directory
	end)

	if ok and type(result) == "table" then
		for k, v in pairs(result) do
			if type(v) ~= "table" then
				continue
			end

			if type(v.DropTable) ~= "table" then
				continue
			end

			for _, v2 in ipairs(v.DropTable) do
				if v2[1] == p40 then
					return tostring(k)
				end
			end
		end
	end

	return "Unknown"
end

pcall(function()
	if type(isfile) ~= "function" or type(readfile) ~= "function" then
		return
	end

	local v243 = "Zeroin/Config/Zeroin_" .. tostring(game.GameId) .. ".json"

	if not isfile(v243) then
		return
	end

	local data = game:GetService("HttpService"):JSONDecode(readfile(v243))

	if type(data) ~= "table" then
		return
	end

	if type(data["Toggle_Auto Steal"]) == "boolean" then
		zeroinConfig.AutoSteal = data["Toggle_Auto Steal"]
	end

	if type(data["Dropdown_Filter By Rarity"]) == "table" then
		zeroinConfig.StealRarities = data["Dropdown_Filter By Rarity"]
	end

	if type(data["Dropdown_Filter By Area"]) == "table" then
		zeroinConfig.StealAreas = data["Dropdown_Filter By Area"]
	end

	if type(data["Dropdown_Filter By Egg Name"]) == "table" then
		zeroinConfig.StealNamesFilter = data["Dropdown_Filter By Egg Name"]
	end

	if type(data["Dropdown_Steal Mode"]) == "string" then
		zeroinConfig.StealMode = data["Dropdown_Steal Mode"]
	end

	if data.Input_Speed ~= nil and tonumber(data.Input_Speed) then
		zeroinConfig.TweenSpeedMultiplier = tonumber(data.Input_Speed)
	end

	if type(data["Toggle_Steal Zigzag"]) == "boolean" then
		zeroinConfig.StealZigzag = data["Toggle_Steal Zigzag"]
	end

	if data["Input_Steal By Value"] ~= nil then
		local v245, v246 = v229(data["Input_Steal By Value"])

		if v245 ~= nil then
			zeroinConfig.StealMinValue = v245
			zeroinConfig.StealMinValueInput = v246
		end
	end

	if type(data["Toggle_Anti Knock Back"]) == "boolean" then
		zeroinConfig.AntiGuardKnockback = data["Toggle_Anti Knock Back"]
	end

	if type(data["Toggle_God Mode"]) == "boolean" then
		zeroinConfig.GodMode = data["Toggle_God Mode"]
	end

	if type(data["Toggle_Auto Treadmill"]) == "boolean" then
		zeroinConfig.AutoTreadmillIdle = data["Toggle_Auto Treadmill"]
	end

	if type(data["Toggle_Anti AFK"]) == "boolean" then
		zeroinConfig.AntiAFK = data["Toggle_Anti AFK"]
	end

	if type(data["Toggle_Area Egg ESP"]) == "boolean" then
		zeroinConfig.EggESP = data["Toggle_Area Egg ESP"]
	elseif type(data["Toggle_Egg ESP"]) == "boolean" then
		zeroinConfig.EggESP = data["Toggle_Egg ESP"]
	end

	if type(data["Toggle_Inventory Value ESP"]) == "boolean" then
		zeroinConfig.InventoryValueESP = data["Toggle_Inventory Value ESP"]
	end

	if type(data["Input_Webhook URL"]) == "string" then
		zeroinConfig.WebhookURL = data["Input_Webhook URL"]
	end

	if type(data["Toggle_Webhook Logs"]) == "boolean" then
		zeroinConfig.WebhookEnabled = data["Toggle_Webhook Logs"]
	end

	if type(data["Toggle_Placed Egg ESP"]) == "boolean" then
		zeroinConfig.PlacedEggESP = data["Toggle_Placed Egg ESP"]
	end

	if type(data["Toggle_Auto Reconnect"]) == "boolean" then
		zeroinConfig.AutoReconnect = data["Toggle_Auto Reconnect"]
	end

	local toggleAutoTheRift = data["Toggle_Auto The Rift"]

	if type(toggleAutoTheRift) ~= "boolean" then
		toggleAutoTheRift = data["Toggle_Auto Riftborn"]
	end

	if type(toggleAutoTheRift) == "boolean" then
		zeroinConfig.AutoRift = toggleAutoTheRift
	end

	if type(data["Dropdown_Target Banner / Egg"]) == "table" then
		zeroinConfig.RiftTargetBanners = data["Dropdown_Target Banner / Egg"]

		local v248 = zeroinConfig.RiftTargetBanners[1]

		zeroinConfig.RiftTargetPrize = v248 ~= "None" and v248 or nil
	elseif type(data["Dropdown_Target Banner / Egg"]) == "string" then
		local dropdownTargetBannerEgg = data["Dropdown_Target Banner / Egg"]

		zeroinConfig.RiftTargetBanners = { dropdownTargetBannerEgg }
		zeroinConfig.RiftTargetPrize = dropdownTargetBannerEgg ~= "None" and dropdownTargetBannerEgg or nil
	end

	if type(data["Toggle_Auto Dr. Scramble"]) == "boolean" then
		zeroinConfig.AutoScramble = data["Toggle_Auto Dr. Scramble"]
	end

	if type(data["Toggle_Auto Buy Scramble Shop"]) == "boolean" then
		zeroinConfig.AutoBuyScrambleShop = data["Toggle_Auto Buy Scramble Shop"]
	end

	if type(data["Dropdown_Scramble Shop Items"]) == "table" then
		zeroinConfig.ScrambleShopItems = data["Dropdown_Scramble Shop Items"]
	end

	local v250 = tonumber(data["Input_Scramble Shop Amount"])

	if v250 then
		zeroinConfig.ScrambleShopAmount = math.clamp(math.floor(v250), 1, 100)
	end

	local v251 = tonumber(data["Input_Scramble Shop Interval"])

	if v251 then
		zeroinConfig.ScrambleShopInterval = math.clamp(v251, 1, 3600)
	end

	if type(data["Toggle_Steal From Players"]) == "boolean" then
		zeroinConfig.StealFromPlayers = data["Toggle_Steal From Players"]
	end

	if type(data["Toggle_Drop Egg At Forest"]) == "boolean" then
		zeroinConfig.DropAtFirstArea = data["Toggle_Drop Egg At Forest"]
	elseif type(data["Toggle_Drop At Forest"]) == "boolean" then
		zeroinConfig.DropAtFirstArea = data["Toggle_Drop At Forest"]
	elseif type(data["Toggle_Drop At First Area"]) == "boolean" then
		zeroinConfig.DropAtFirstArea = data["Toggle_Drop At First Area"]
	end

	if type(data["Toggle_Auto Capture The Egg"]) == "boolean" then
		zeroinConfig.AutoCaptureEgg = data["Toggle_Auto Capture The Egg"]
	end

	local toggleAutoPlaceEgg = data["Toggle_Auto Place Egg"]

	if type(toggleAutoPlaceEgg) ~= "boolean" then
		toggleAutoPlaceEgg = data["Toggle_Auto Place"]
	end

	if type(toggleAutoPlaceEgg) == "boolean" then
		zeroinConfig.AutoPlace = toggleAutoPlaceEgg
	end

	local toggleAutoHatchEgg = data["Toggle_Auto Hatch Egg"]

	if type(toggleAutoHatchEgg) ~= "boolean" then
		toggleAutoHatchEgg = data["Toggle_Auto Hatch"]
	end

	if type(toggleAutoHatchEgg) == "boolean" then
		zeroinConfig.AutoHatch = toggleAutoHatchEgg
	end

	if type(data["Dropdown_Place Egg Rarity"]) == "table" then
		zeroinConfig.PlaceRarities = data["Dropdown_Place Egg Rarity"]
	end

	if type(data["Toggle_Auto Fuse"]) == "boolean" then
		zeroinConfig.AutoFuse = data["Toggle_Auto Fuse"]
	end

	local dropdownFusePriority = data["Dropdown_Fuse Priority"]

	if type(dropdownFusePriority) == "table" then
		dropdownFusePriority = dropdownFusePriority[1]
	end

	if type(dropdownFusePriority) == "string" then
		zeroinConfig.AutoFusePriority = dropdownFusePriority
	end

	if type(data["Dropdown_Fuse Rarities"]) == "table" then
		zeroinConfig.AutoFuseRarities = data["Dropdown_Fuse Rarities"]
	end

	local v255 = tonumber(data["Input_Keep Pet Copies"]) or tonumber(data["Input_Keep Copies per Pet"])

	if v255 then
		zeroinConfig.AutoFuseKeepPerPet = math.max(0, math.floor(v255))
	end

	local v256 = tonumber(data["Input_Max Weight (Kg)"]) or tonumber(data["Input_Maximum Fuse Weight (Kg)"])

	if v256 then
		zeroinConfig.AutoFuseMaxWeightKg = math.max(0, v256)
	end

	if type(data["Toggle_Auto Consume Mutation"]) == "boolean" then
		zeroinConfig.AutoMutate = data["Toggle_Auto Consume Mutation"]
	end

	local dropdownMutationType = data["Dropdown_Mutation Type"]

	if type(dropdownMutationType) == "table" then
		dropdownMutationType = dropdownMutationType[1]
	end

	if type(dropdownMutationType) == "string" then
		zeroinConfig.AutoMutateType = dropdownMutationType
	end

	if type(data["Dropdown_Mutation Egg Rarities"]) == "table" then
		zeroinConfig.AutoMutateRarities = data["Dropdown_Mutation Egg Rarities"]
	end

	if type(data["Dropdown_Egg Names (Placed)"]) == "table" then
		zeroinConfig.AutoMutateNames = data["Dropdown_Egg Names (Placed)"]
	end

	if data["Input_Min Mutation Value /s"] ~= nil then
		local v258, v259 = v229(data["Input_Min Mutation Value /s"])

		if v258 ~= nil then
			zeroinConfig.AutoMutateMinValue = v258
			zeroinConfig.AutoMutateMinValueInput = v259
		end
	end

	if type(data["Toggle_Auto Sell Pet"]) == "boolean" then
		zeroinConfig.AutoSell = data["Toggle_Auto Sell Pet"]
	end

	if type(data["Toggle_Auto Sell Egg"]) == "boolean" then
		zeroinConfig.AutoSellEgg = data["Toggle_Auto Sell Egg"]
	end

	if type(data["Dropdown_Egg Rarity Filter"]) == "table" then
		zeroinConfig.SellEggRarities = data["Dropdown_Egg Rarity Filter"]
	end
end)

local EggState = require(game:GetService("ReplicatedStorage").Client.EggState)

EggState.GetAreaEggSnapshot = EggState.ReadFieldEggs
EggState.GetAreaEggRecord = EggState.ReadFieldEgg
EggState.RequestAreaEggSnapshot = EggState.SyncFieldEggs
EggState.RequestCarryAreaEgg = EggState.CarryFieldEgg
EggState.RequestDropHeldAreaEgg = EggState.DropFieldEgg
EggState.AreaEggCarryStateChanged = EggState.CarryChanged
EggState.AreaEggClaimed = EggState.FieldClaimed
EggState.AreaEggUpdated = EggState.FieldShifted
EggState.AreaEggRemoved = EggState.FieldGone
EggState.GetOwnerRuntimeRecords = EggState.ReadOwnerEggs
EggState.RequestEquipTool = EggState.WearEggTool
EggState.RequestPlaceEgg = EggState.PlantEgg
EggState.RequestHatchEgg = EggState.BeginHatch
EggState.RequestCompleteHatchEgg = EggState.FinishHatch
EggState.RequestRuntimeSnapshot = EggState.SyncOwnedEggs
EggState.RuntimeOwnerUpdated = EggState.OwnerRefreshed
EggState.RuntimeOwnerCleared = EggState.OwnerCleared

local PlotState = require(game:GetService("ReplicatedStorage").Client.PlotState)

PlotState.GetMySlot = PlotState.ResolveLocalSlot
PlotState.GetPlotsFolder = PlotState.ResolveFolder
PlotState.IsWorldPositionWithinLocalPlotBounds = PlotState.ContainsLocalPoint
PlotState.GetPlotData = PlotState.ResolvePlot

local AreaEggResetWall = require(game:GetService("ReplicatedStorage").Client.AreaEggResetWall)

AreaEggResetWall.IsClosed = AreaEggResetWall.IsSealed
v127 = function()
	return math.clamp(math.floor((tonumber(zeroinConfig.TweenSpeedMultiplier) or t7.DEF_INPUT) + 0.5), t7.MIN_INPUT, t7.MAX_INPUT) * t7.MULTIPLIER
end
zeroinConfig.applyStealValueInput = function(p41, p42)
	local v263, v264 = v229(p42)

	if v263 == nil then
		return false
	end

	p41.StealMinValue = v263
	p41.StealMinValueInput = v264

	return true
end

local function v265()
	return zeroinConfig.AutoSteal or zeroinConfig.AutoRift and next(zeroinConfig.RiftRequiredCategories) ~= nil
end
local function v266(p43)
	local v267 = zeroinConfig.AutoRift and type(p43) == "string"

	if v267 then
		v267 = (zeroinConfig.RiftObjectiveCategories[p43] or 0) > 0
	end

	return v267
end
local function v268(p44)
	return zeroinConfig.AutoRift and zeroinConfig.RiftProtectedPetUids[p44] == true
end
local function v269()
	local __ZeroinScrambleRuntime = genv.__ZeroinScrambleRuntime
	local v271 = __ZeroinScrambleRuntime and type(__ZeroinScrambleRuntime.isMovementBusy) == "function"

	v271 = v271 and __ZeroinScrambleRuntime:isMovementBusy()

	if zeroinConfig.IsStealing or zeroinConfig.IsRiftTrading or zeroinConfig.IsFusing or v271 then
		return false
	end

	if v265() then
		return os.clock() >= (zeroinConfig.StealPriorityUntil or 0)
	end

	return true
end
local function v272()
	local LocalPlayer2 = game:GetService("Players").LocalPlayer
	local t11 = {}

	t11.__index = t11
	t11.new = function()
		local obj = setmetatable({}, t11)

		obj.enabled = false
		obj.destroyed = false

		local getconnections_ = getconnections

		obj.getConnections = getconnections_ or get_signal_cons
		obj.idledConnections = {}

		return obj
	end
	t11._captureConnections = function(p45)
		if not p45.getConnections or not LocalPlayer2 then
			return
		end

		for _, v in ipairs(p45.getConnections(LocalPlayer2.Idled)) do
			if not table.find(p45.idledConnections, v) then
				table.insert(p45.idledConnections, v)
			end
		end
	end
	t11.setEnabled = function(p46, p47)
		if p46.destroyed then
			return false
		end

		local enabled = p47 == true

		p46.enabled = enabled

		if enabled then
			p46:_captureConnections()
		end

		for _, idledConnection in ipairs(p46.idledConnections) do
			pcall(function()
				if enabled then
					idledConnection:Disable()
				else
					idledConnection:Enable()
				end
			end)
		end

		return p46.enabled
	end
	t11.isEnabled = function(p48)
		return p48.enabled
	end
	t11.destroy = function(p49)
		if p49.destroyed then
			return
		end

		p49:setEnabled(false)
		p49.destroyed = true
		table.clear(p49.idledConnections)
	end

	return t11
end

local v282 = v272().new()

genv.__ZeroinAntiAfk = v282
v282:setEnabled(zeroinConfig.AntiAFK == true)

local function v283()
	v282:destroy()

	if genv.__ZeroinAntiAfk == v282 then
		genv.__ZeroinAntiAfk = nil
	end

	if genv.__ZeroinAntiAfkCleanup == v283 then
		genv.__ZeroinAntiAfkCleanup = nil
	end
end

genv.__ZeroinAntiAfkCleanup = v283

local u284 = false

local function v285()
	if u284 then
		return
	end

	u284 = true

	local genv2 = getgenv and getgenv()

	genv2 = genv2 or _G

	if genv2 and (genv2.SNE_AutoExecute or genv2.Zeroin_AutoExecute) then
		if type(genv2.writeAutoexecBootstrapper) == "function" then
			pcall(genv2.writeAutoexecBootstrapper)
		end
	end

	task.wait(3)

	local TeleportService = game:GetService("TeleportService")
	local LocalPlayer2 = game:GetService("Players").LocalPlayer
	local PlaceId = game.PlaceId
	local JobId = game.JobId
	local n3 = 0

	while true do
		n3 += 1
		pcall(function()
			if n3 <= 5 and JobId and #JobId > 0 then
				TeleportService:TeleportToPlaceInstance(PlaceId, JobId, LocalPlayer2)
			else
				TeleportService:Teleport(PlaceId, LocalPlayer2)
			end
		end)
		task.wait(6)
	end
end

pcall(function()
	local GuiService = game:GetService("GuiService")

	v44(GuiService.ErrorMessageChanged:Connect(function(p50)
		if zeroinConfig.AutoReconnect and p50 and #p50 > 0 then
			task.spawn(v285)
		end
	end))

	local errorMessage = GuiService:GetErrorMessage()

	if zeroinConfig.AutoReconnect and errorMessage and #errorMessage > 0 then
		task.spawn(v285)
	end
end)

local function v294()
	local lua

	if isfile and readfile and isfile("Zeroin_ZeroLib_cached_v15.lua") then
		pcall(function()
			lua = readfile("Zeroin_ZeroLib_cached_v15.lua")
		end)
	end

	if not lua or lua == "" or string.len(lua) < 100 then
		for i = 1, 3 do
			local ok, result = pcall(function()
				return game:HttpGet("https://raw.githubusercontent.com/iSylvesterr/library/1e50c1a/ZeroLib.lua")
			end)

			if ok and result and string.len(result) > 100 and not string.match(result, "404: Not Found") then
				lua = result

				if writefile then
					pcall(function()
						writefile("Zeroin_ZeroLib_cached_v15.lua", lua)
					end)
				end

				break
			end

			task.wait(1)
		end
	end

	if lua and string.len(lua) > 100 then
		if not genv.__ZeroinUIHost then
			warn("[ZeroinUI] CoreGui host is unavailable")

			return nil
		end

		lua = string.gsub(lua, "game:GetService%(\"CoreGui\"%)", "((getgenv and getgenv().__ZeroinUIHost) or _G.__ZeroinUIHost)")
		lua = string.gsub(lua, "game:GetService%('CoreGui'%)", "((getgenv and getgenv().__ZeroinUIHost) or _G.__ZeroinUIHost)")
		lua = string.gsub(lua, "(Instance%.new%s*%(%s*[\"']ScreenGui[\"']%s*%))", "(function() local _sg = %1; _sg.ResetOnSpawn = false; return _sg end)()")
		lua = string.gsub(lua, "ZeroinOnTop%.Destroying:Connect%s*%(%s*function%s*%(%s*%)%s*if%s+runCleanup%s+then%s+runCleanup%(true%)%s*end%s*end%)", "")
		lua = string.gsub(lua, "(:Connect%s*%(%s*function%s*%b())", "%1\nif getgenv and getgenv().__ZeroinEnterUICallback then getgenv().__ZeroinEnterUICallback() elseif _G.__ZeroinEnterUICallback then _G.__ZeroinEnterUICallback() end")
		lua = string.gsub(lua, "(:Once%s*%(%s*function%s*%b())", "%1\nif getgenv and getgenv().__ZeroinEnterUICallback then getgenv().__ZeroinEnterUICallback() elseif _G.__ZeroinEnterUICallback then _G.__ZeroinEnterUICallback() end")
		lua = string.gsub(lua, "(task%.spawn%s*%(%s*function%s*%b())", "%1\nif getgenv and getgenv().__ZeroinEnterUICallback then getgenv().__ZeroinEnterUICallback() elseif _G.__ZeroinEnterUICallback then _G.__ZeroinEnterUICallback() end")
		lua = string.gsub(lua, "(task%.defer%s*%(%s*function%s*%b())", "%1\nif getgenv and getgenv().__ZeroinEnterUICallback then getgenv().__ZeroinEnterUICallback() elseif _G.__ZeroinEnterUICallback then _G.__ZeroinEnterUICallback() end")
		lua = string.gsub(lua, "([^%w_%.])spawn%s*%(%s*function%s*(%b())", "%1spawn(function%2\nif getgenv and getgenv().__ZeroinEnterUICallback then getgenv().__ZeroinEnterUICallback() elseif _G.__ZeroinEnterUICallback then _G.__ZeroinEnterUICallback() end")
		lua = string.gsub(lua, "(task%.wait%s*%b())", "%1\nif getgenv and getgenv().__ZeroinEnterUICallback then getgenv().__ZeroinEnterUICallback() elseif _G.__ZeroinEnterUICallback then _G.__ZeroinEnterUICallback() end")
		lua = string.gsub(lua, "([^%w_%.])wait%s*(%b())", "%1wait%2\nif getgenv and getgenv().__ZeroinEnterUICallback then getgenv().__ZeroinEnterUICallback() elseif _G.__ZeroinEnterUICallback then _G.__ZeroinEnterUICallback() end")
		lua = string.gsub(lua, "(function%s+LoadConfigElements%s*%b())", [[%1
if getgenv and getgenv().__ZeroinEnterUICallback then getgenv().__ZeroinEnterUICallback() elseif _G.__ZeroinEnterUICallback then _G.__ZeroinEnterUICallback() end
]])
		lua = string.gsub(lua, "(function%s+[A-Za-z_][A-Za-z0-9_]*Func:Set%s*%b())", [[%1
if getgenv and getgenv().__ZeroinEnterUICallback then getgenv().__ZeroinEnterUICallback() elseif _G.__ZeroinEnterUICallback then _G.__ZeroinEnterUICallback() end
]])

		local v299 = string.find(lua, "function Items:AddInput", 1, true)
		local v300 = v299 and string.find(lua, "function Items:AddDropdown", v299, true)

		if v299 and v300 then
			local v301 = string.gsub(string.gsub(string.gsub(string.sub(lua, v299, v300 - 1), "local configKey = \"Input_\" %.%. InputConfig%.Title%s+if ConfigData%[configKey%] ~= nil then", [[local configKey = "Input_" .. InputConfig.Title
                local persistValue = InputConfig.Persist ~= false
                if not persistValue then
                    ConfigData[configKey] = nil
                    SaveConfig()
                elseif ConfigData[configKey] ~= nil then]], 1), "(InputTextBox%.TextColor3%s*=%s*Color3%.fromRGB%b())", "%1\n                InputTextBox.TextTransparency = InputConfig.Sensitive == true and 1 or 0", 1), "ConfigData%[configKey%] = Value%s+SaveConfig%(%)", [[if persistValue then
                        ConfigData[configKey] = Value
                    else
                        ConfigData[configKey] = nil
                    end
                    SaveConfig()]], 1)

			lua = string.sub(lua, 1, v299 - 1) .. v301 .. string.sub(lua, v300)
		end

		lua = string.gsub(lua, ":Connect%s*%(([A-Za-z_][A-Za-z0-9_%.]*)%)", ":Connect(((getgenv and getgenv().__ZeroinWrapUICallback) or _G.__ZeroinWrapUICallback)(%1))")
		lua = string.gsub(lua, ":Once%s*%(([A-Za-z_][A-Za-z0-9_%.]*)%)", ":Once(((getgenv and getgenv().__ZeroinWrapUICallback) or _G.__ZeroinWrapUICallback)(%1))")

		local chunk, v303 = loadstring(lua)

		if chunk then
			local ok, result = pcall(chunk)

			if ok and result then
				return result
			end

			warn("[ZeroinUI] Execution Error: " .. tostring(result))
		else
			warn("[ZeroinUI] Parse Error: " .. tostring(v303))
		end
	end

	return nil
end

local v306 = v294()

if not v306 then
	warn("Failed to load Zeroin UI Library!")

	return
end

local t12 = {}
local t13 = {}

local function v309(p51, p52)
	local t14 = {}

	if type(p51) == "table" then
		for k, v in pairs(p51) do
			if type(k) == "number" then
				table.insert(t14, v)
			elseif type(k) == "string" and v == true then
				table.insert(t14, k)
			end
		end
	else
		t14 = { p51 }
	end

	if p52 and t12[p52] then
		return t14
	end

	local v313 = p52 and t13[p52]
	local v314 = table.find(t14, "None") ~= nil
	local v315 = false

	if #t14 == 0 then
		t14 = { "None" }
		v315 = true
	elseif #t14 > 1 and v314 then
		if v313 == false then
			t14 = { "None" }
			v315 = true
		else
			local t15 = {}

			for _, v in ipairs(t14) do
				if v ~= "None" then
					table.insert(t15, v)
				end
			end

			t14 = t15
			v315 = true
		end
	end

	if p52 then
		t13[p52] = table.find(t14, "None") ~= nil
	end

	if v315 and p52 then
		t12[p52] = true
		pcall(function()
			p52:Set(t14)
		end)
		t12[p52] = nil
	end

	return t14
end
local function v319(p53)
	if not p53 or type(p53.GetValue) ~= "function" then
		return nil
	end

	local ok, result = pcall(function()
		return p53:GetValue()
	end)

	if not ok then
		return nil
	end

	if type(result) ~= "table" then
		if type(result) == "string" then
			return { result }
		end

		return nil
	end

	local t16 = {}

	for k, v in pairs(result) do
		if type(k) == "number" then
			table.insert(t16, v)
		elseif type(k) == "string" and v == true then
			table.insert(t16, k)
		end
	end

	return t16
end
local function v325(p54, p55, p56, p57)
	if zeroinConfig.SellAll then
		return true
	end

	if type(p56) ~= "table" or type(p57) ~= "table" then
		return false
	end

	local v326 = false

	if #p56 ~= 0 and not table.find(p56, "None") then
		if table.find(p56, "All") then
			v326 = true
		else
			v326 = table.find(p56, p54) ~= nil
		end
	end

	local v327 = false

	if #p57 ~= 0 and not table.find(p57, "None") then
		if table.find(p57, "All") then
			v327 = true
		else
			v327 = table.find(p57, p55) ~= nil
		end
	end

	return v326 or v327
end
local function v328(p58, p59)
	if type(p59) ~= "table" then
		return false
	end

	if #p59 == 0 or table.find(p59, "None") then
		return false
	end

	if table.find(p59, "All") then
		return true
	end

	return table.find(p59, p58) ~= nil
end
local function v329(p60)
	local HumanoidRootPart = p60 and p60:FindFirstChild("HumanoidRootPart")

	if HumanoidRootPart then
		HumanoidRootPart:SetAttribute("KillPartIgnore", true)
	end
end

local vector3 = Vector3.new(545, 71, -365)
local t17 = {
	CarryRetry = 0.25,
	CarryTimeout = 2,
	EarlyCarryDistance = 8,
	SafeStable = 0.35,
	ReturnValidation = 0.08,
	NextTarget = 0.05,
	SafeHandoff = 0.15
}

local function v333(p61)
	local clamp = math.clamp
	local floor = math.floor
	local tweenSpeedMultiplier = clamp(floor((tonumber(p61) or t7.DEF_INPUT) + 0.5), t7.MIN_INPUT, t7.MAX_INPUT)

	if math.abs((zeroinConfig.TweenSpeedMultiplier or 0) - tweenSpeedMultiplier) <= 0.001 then
		return
	end

	zeroinConfig.TweenSpeedMultiplier = tweenSpeedMultiplier

	local Humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	local WalkSpeed = Humanoid and Humanoid.WalkSpeed or 0

	warn(string.format("[Spoof] speed level %d (%.0f stud/detik, WalkSpeed %.0f).", tweenSpeedMultiplier, v127(), WalkSpeed))
end

t8 = t8 or {}

local function v339(p62, p63, p64, p65, p66, p67, p68)
	if not p62 or not p63 or typeof(p64) ~= "CFrame" then
		return false
	end

	if p65 and p65() then
		return false
	end

	local v340 = t8[p62]

	if v340 then
		v340.cancelled = true
		t8[p62] = nil
	end

	local Parent = p62.Parent

	if not Parent then
		return false
	end

	v139()
	v329(Parent)
	v218()

	local CurrentCamera = workspace.CurrentCamera

	if CurrentCamera and CurrentCamera.CameraSubject ~= p63 then
		pcall(function()
			CurrentCamera.CameraSubject = p63
		end)
	end

	local AutoRotate = p63.AutoRotate

	p63.AutoRotate = false

	local v344 = p68 and math.max(p62.Position.Y, p64.Position.Y + 45, vector3.Y + 45) or nil
	local v345 = v344 and cFrameNew(p64.Position.X, v344, p64.Position.Z) * p64.Rotation or p64
	local v346 = math.clamp(v127(), t7.MIN_SPEED, t7.MAX_SPEED)

	v154(Parent, v346 * t7.HEADROOM)

	local t18 = {
		cancelled = false
	}

	t8[p62] = t18
	v136()

	local now
	local v349
	local n4 = 0
	local v351 = v344 and (math.abs(p62.Position.Y - v344) > 0.35 and "takeoff" or "cruise") or nil
	local Magnitude = (v345.Position - p62.Position).Magnitude
	local v353 = os.clock() + math.max(Magnitude / v346, 0.08) * 3 + 8
	local v354 = false
	local v355 = false

	while not t18.cancelled and (not p65 or not p65()) and p62.Parent and not (v353 <= os.clock()) do
		local v356 = math.max(math.min(RunService.Heartbeat:Wait(), 0.15), 0.0041666666666666666)
		local v357 = math.clamp(v127(), t7.MIN_SPEED, t7.MAX_SPEED)

		v154(Parent, v357 * t7.HEADROOM)

		local v358 = v150()[t7.INTEGRITY_KEY]
		local State = type(v358) == "table" and v358.State or nil

		if v208(State, p63, p62) then
			local Position = p62.Position
			local v361 = v345.Position - Position
			local Magnitude2 = v361.Magnitude
			local vector32 = Vector3.new(v361.X, 0, v361.Z)

			if v344 and v351 == "takeoff" and math.abs(Position.Y - v344) <= 0.35 then
				v351 = "cruise"
			end

			local v364 = (v344 and v351 == "takeoff" and Vector3.new(Position.X, v344, Position.Z) or v345.Position) - Position
			local Magnitude3 = v364.Magnitude
			local Magnitude4 = v344 and vector32.Magnitude or Magnitude2

			if v349 and v349 + 2 < Magnitude4 then
				n4 = os.clock() + 0.5
			end

			v349 = Magnitude4

			local v367 = (os.clock() < n4 and math.max(t7.MIN_SPEED, v357 * 0.45) or v357) * v356

			if p67 and not v355 and Magnitude2 <= t17.EarlyCarryDistance then
				v355 = true
				task.spawn(p67)
			end

			local vector33 = Vector3.new(p62.CFrame.LookVector.X, 0, p62.CFrame.LookVector.Z)
			local Unit = vector32.Magnitude > 0.001 and vector32.Unit or vector33.Magnitude > 0.001 and vector33.Unit or Vector3.new(0, 0, -1)

			if (not v344 or v351 == "cruise") and Magnitude2 <= math.max(v367, 0.05) then
				if Magnitude2 > 0.5 then
					now = nil
				end

				v131(v345.Position)
				p62.CFrame = lookAt(v345.Position, v345.Position + Unit)
				p62.AssemblyLinearVelocity = Vector3.zero
				p62.AssemblyAngularVelocity = Vector3.zero
				v131(v345.Position)
				v213(p63, p62, v357, Vector3.zero)
				now = now or os.clock()

				if os.clock() - now >= 0.4 then
					v354 = true

					break
				end
			else
				now = nil

				if Magnitude3 <= 0.001 then
					p62.AssemblyLinearVelocity = Vector3.zero
					p62.AssemblyAngularVelocity = Vector3.zero
					v131(Position)
				else
					local v370 = Position + v364.Unit * math.min(v367, Magnitude3)
					local assemblyLinearVelocity = (v370 - Position) / v356

					v131(v370)
					p62.CFrame = lookAt(v370, v370 + Unit)
					p62.AssemblyLinearVelocity = assemblyLinearVelocity
					v131(v370)

					if not v213(p63, p62, v357, assemblyLinearVelocity) then
						v209(p63, p62, v357)
						v213(p63, p62, v357, assemblyLinearVelocity)
					end
				end
			end
		else
			v349 = nil
			now = nil
			p62.AssemblyLinearVelocity = Vector3.zero
			p62.AssemblyAngularVelocity = Vector3.zero
			v131(p62.Position)

			if v207(State, p63, p62) then
				v184(State, v357 * t7.HEADROOM, Vector3.zero)
			else
				v209(p63, p62, v357)
			end
		end
	end

	if p63.Parent and AutoRotate ~= nil then
		p63.AutoRotate = AutoRotate
	end

	p62.AssemblyLinearVelocity = Vector3.zero
	p62.AssemblyAngularVelocity = Vector3.zero

	if v354 and p66 then
		v140(p62, v345)
	else
		v138()
	end

	return v354 and not t18.cancelled
end

getgenv().ZeroinConfig = zeroinConfig

local u372

local function v373(p69)
	if not p69 or p69 == u372 then
		return
	end

	u372 = p69

	for _, child in ipairs(p69:GetChildren()) do
		if child.Name == "PlayerTrap" then
			pcall(child.Destroy, child)
		end
	end

	v44(p69.ChildAdded:Connect(function(child)
		if child.Name == "PlayerTrap" then
			pcall(child.Destroy, child)
		end
	end))
end

v373(workspace:FindFirstChild("__DEBRIS"))
v44(workspace.ChildAdded:Connect(function(child)
	if child.Name == "__DEBRIS" then
		v373(child)
	end
end))

if type(genv.__ZeroinDecomBoostCleanup) == "function" then
	pcall(genv.__ZeroinDecomBoostCleanup)
end

local t19 = {}
local u377 = false

genv.__ZeroinDecomBoostCleanup = function()
	for _, v in ipairs(t19) do
		pcall(function()
			v:Disconnect()
		end)
	end

	table.clear(t19)
	u377 = false
end

local function v380()
	local ClientRenderedAssets = workspace:FindFirstChild("ClientRenderedAssets")

	if not ClientRenderedAssets then
		return
	end

	for _, child in ipairs(ClientRenderedAssets:GetChildren()) do
		pcall(function()
			child:Destroy()
		end)
	end
end
local function v384(p70)
	if not p70 then
		return false
	end

	local v385 = tostring(LocalPlayer.UserId)
	local v386 = tostring(p70.Name)
	local match = v386:match("^(%d+)_") or v386:match("^(%d+):")

	if match and match == v385 then
		return true
	end

	if p70:GetAttribute("OwnerUserId") == LocalPlayer.UserId then
		return true
	end

	return false
end
local function v388()
	for _, child in ipairs(workspace:GetChildren()) do
		if child.Name == "PlacedEggRenders" then
			for _, child2 in ipairs(child:GetChildren()) do
				pcall(function()
					if not v384(child2) then
						if not child2:FindFirstChildOfClass("ProximityPrompt") then
							child2:Destroy()
						end
					end
				end)
			end
		end
	end
end
local function v393()
	local __DEBRIS = workspace:FindFirstChild("__DEBRIS")

	if not __DEBRIS then
		return
	end

	for _, child in ipairs(__DEBRIS:GetChildren()) do
		if child.Name == "PlayerTrap" then
			pcall(function()
				child:Destroy()
			end)
		end
	end
end
local function v397(descendant)
	pcall(function()
		if descendant:IsA("BasePart") then
			descendant.Material = Enum.Material.SmoothPlastic
			descendant.CastShadow = false
		elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
			descendant.Texture = ""
			descendant.Transparency = 1
		elseif descendant:IsA("Sound") then
			descendant.PlayOnRemove = false
			descendant:Stop()
		elseif descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") or descendant:IsA("Beam") or descendant:IsA("Sparkles") or descendant:IsA("Fire") or descendant:IsA("Smoke") or descendant:IsA("PostEffect") then
			descendant.Enabled = false
		end
	end)
end
local function v398()
	if u377 then
		return
	end

	u377 = true
	table.insert(t19, workspace.DescendantAdded:Connect(v397))
	table.insert(t19, workspace.ChildAdded:Connect(function(child)
		if child.Name == "ClientRenderedAssets" then
			v380()
			table.insert(t19, child.ChildAdded:Connect(function(child2)
				pcall(function()
					child2:Destroy()
				end)
			end))
		elseif child.Name == "PlacedEggRenders" then
			v388()
			table.insert(t19, child.ChildAdded:Connect(function(child2)
				pcall(function()
					if not v384(child2) and not child2:FindFirstChildOfClass("ProximityPrompt") then
						child2:Destroy()
					end
				end)
			end))
		elseif child.Name == "__DEBRIS" then
			table.insert(t19, child.ChildAdded:Connect(function(child2)
				if child2.Name == "PlayerTrap" then
					pcall(function()
						child2:Destroy()
					end)
				end
			end))
		end
	end))

	local ClientRenderedAssets = workspace:FindFirstChild("ClientRenderedAssets")

	if ClientRenderedAssets then
		table.insert(t19, ClientRenderedAssets.ChildAdded:Connect(function(child)
			pcall(function()
				child:Destroy()
			end)
		end))
	end

	for _, child in ipairs(workspace:GetChildren()) do
		if child.Name == "PlacedEggRenders" then
			table.insert(t19, child.ChildAdded:Connect(function(child2)
				pcall(function()
					if not v384(child2) and not child2:FindFirstChildOfClass("ProximityPrompt") then
						child2:Destroy()
					end
				end)
			end))
		end
	end
end
local function v402()
	if type(genv.__ZeroinSetCapFps) == "function" then
		genv.__ZeroinSetCapFps(240)
	end

	local Lighting = game:GetService("Lighting")

	pcall(function()
		settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
		settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Always
		Lighting.Technology = Enum.Technology.Compatibility
		Lighting.GlobalShadows = false
		Lighting.FogEnd = 9e9
		Lighting.Brightness = 2
		Lighting.Ambient = Color3.new(1, 1, 1)
		Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
	end)

	for _, descendant in ipairs(game:GetDescendants()) do
		if descendant:IsA("BasePart") then
			pcall(function()
				descendant.Material = Enum.Material.SmoothPlastic
				descendant.CastShadow = false
			end)
		elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
			pcall(function()
				descendant.Texture = ""
				descendant.Transparency = 1
			end)
		else
			v397(descendant)
		end
	end

	local Terrain = workspace:FindFirstChildOfClass("Terrain")

	if Terrain then
		pcall(function()
			Terrain.WaterWaveSize = 0
			Terrain.WaterWaveSpeed = 0
			Terrain.WaterReflectance = 0
			Terrain.WaterTransparency = 1
			Terrain.Decoration = false
		end)
	end

	pcall(function()
		local SettingsCmds = require(ReplicatedStorage.Shared.SettingsCmds)

		SettingsCmds.Write("HideOtherPets", true)
		SettingsCmds.Write("SFX", false)
		SettingsCmds.Write("Music", false)
		SettingsCmds.Write("DisableVideos", true)
	end)
	v380()
	v388()
	v393()
	v398()
end
local function v408(p71)
	if not p71 or not p71:IsA("Model") then
		return
	end

	local match = p71.Name:match("^(%d+)_")
	local v410 = match

	v410 = v410 and tonumber(match)

	if not v410 or v410 == LocalPlayer.UserId then
		return
	end

	for _, descendant in ipairs(p71:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.Transparency = 1
			descendant.CanCollide = false
		elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
			descendant.Transparency = 1
		elseif descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") or descendant:IsA("Beam") then
			descendant.Enabled = false
		elseif descendant:IsA("BillboardGui") or descendant:IsA("SurfaceGui") then
			descendant.Enabled = false
		end
	end
end
local function v413()
	if zeroinConfig._fpsEggsReady then
		return true
	end

	local u414 = false
	local ok, result = pcall(function()
		local v417 = require(game:GetService("ReplicatedStorage").Shared.Eggs.PlacedEggRenderer).GetRenderFolder()

		if not v417 then
			return
		end

		local children = v417:GetChildren()

		for _, child in ipairs(children) do
			v408(child)
		end

		v417.ChildAdded:Connect(function(child)
			task.defer(v408, child)
		end)
		u414 = true
	end)

	if not ok then
		warn("[FPSBoost] Gagal hide egg pemain lain:", result)

		return false
	end

	return u414
end
local function v421(p72)
	if not p72 then
		return
	end

	pcall(function()
		p72:Destroy()
	end)
end
local function v422()
	if zeroinConfig._fpsPetsReady then
		return true
	end

	local SettingsCmds
	local ok, result = pcall(function()
		SettingsCmds = require(game:GetService("ReplicatedStorage").Shared.SettingsCmds)
		SettingsCmds.Write("HideOtherPets", true)
	end)
	local v426 = false

	if ok and SettingsCmds then
		local ok2, result2 = pcall(SettingsCmds.Allows, "HideOtherPets")

		v426 = ok2 and result2 == true
	end

	if ok and v426 then
		local u429 = false
		local ok2, result2 = pcall(function()
			local ClientRenderedAssets = workspace:FindFirstChild("ClientRenderedAssets") or workspace:WaitForChild("ClientRenderedAssets", 10)

			if not ClientRenderedAssets then
				return
			end

			local children = ClientRenderedAssets:GetChildren()

			for _, child in ipairs(children) do
				v421(child)
			end

			ClientRenderedAssets.ChildAdded:Connect(function(child)
				task.defer(v421, child)
			end)
			u429 = true
		end)

		if not ok2 then
			warn("[FPSBoost] Gagal hide pet (manual):", result2)

			return false
		end

		return u429
	end

	warn("[FPSBoost] Gagal set HideOtherPets bawaan game:", result or "setting belum aktif")

	return false
end
local function v436()
	if type(genv.__ZeroinSetCapFps) == "function" then
		pcall(genv.__ZeroinSetCapFps, 240)
	end

	pcall(function()
		settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
	end)
	pcall(function()
		UserSettings():GetService("UserGameSettings").SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1
	end)
	pcall(function()
		require(game:GetService("ReplicatedStorage").Client.LightingsController):SetModifier("FPSBoost", function(p73)
			local v437 = table.clone(p73)

			v437.Bloom = nil
			v437.ColorCorrection = nil
			v437.SunRays = nil
			v437.DepthOfField = nil
			v437.Blur = nil
			v437.Clouds = nil
			v437.Atmosphere = nil
			v437.ShadowSoftness = 1

			return v437
		end, 100, 0)
	end)
	pcall(function()
		local Lighting = game:GetService("Lighting")

		Lighting.GlobalShadows = false
		Lighting.Technology = Enum.Technology.Compatibility
		Lighting.FogEnd = 9e9
		Lighting.Brightness = 2
	end)
	pcall(function()
		local Terrain = workspace:FindFirstChildOfClass("Terrain")

		if Terrain then
			Terrain.WaterWaveSize = 0
			Terrain.WaterWaveSpeed = 0
			Terrain.WaterReflectance = 0
			Terrain.WaterTransparency = 1
			Terrain.Decoration = false
		end
	end)
	pcall(function()
		local __DEBRIS = workspace:FindFirstChild("__DEBRIS")

		if __DEBRIS then
			for _, child in ipairs(__DEBRIS:GetChildren()) do
				if child.Name == "PlayerTrap" then
					pcall(function()
						child:Destroy()
					end)
				end
			end
		end
	end)
end

local color3 = Color3.fromRGB(120, 120, 120)

local function v444(p74)
	if not p74 or not p74:IsA("BasePart") then
		return
	end

	pcall(function()
		p74.Material = Enum.Material.SmoothPlastic
		p74.Color = color3
		p74.CastShadow = false
	end)

	for _, child in ipairs(p74:GetChildren()) do
		if child:IsA("Texture") or child:IsA("Decal") then
			pcall(function()
				child:Destroy()
			end)
		end
	end
end
local function v447(p75)
	pcall(function()
		if p75:IsA("ParticleEmitter") then
			p75.Enabled = false
			p75.Rate = 0
			pcall(function()
				p75:Clear()
			end)
		elseif p75:IsA("Trail") or p75:IsA("Beam") or p75:IsA("Smoke") or p75:IsA("Fire") or p75:IsA("Sparkles") or p75:IsA("PostEffect") or p75:IsA("Light") or p75:IsA("Highlight") or p75:IsA("Clouds") then
			p75.Enabled = false
		elseif p75:IsA("Atmosphere") then
			p75.Density = 0
			p75.Haze = 0
			p75.Glare = 0
		elseif p75:IsA("Explosion") then
			p75.Visible = false
		end
	end)
end
local function v448()
	for _, descendant in ipairs(workspace:GetDescendants()) do
		if descendant:IsA("BasePart") then
			v444(descendant)
		elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
			pcall(function()
				descendant:Destroy()
			end)
		else
			v447(descendant)
		end
	end

	local ipairs_ = ipairs
	local Lighting = game:GetService("Lighting")

	for _, descendant in ipairs_(Lighting:GetDescendants()) do
		v447(descendant)
	end

	v44(workspace.DescendantAdded:Connect(function(descendant)
		if descendant:IsA("BasePart") then
			task.defer(v444, descendant)
		elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
			pcall(function()
				descendant:Destroy()
			end)
		else
			task.defer(v447, descendant)
		end
	end))

	return true
end
local function v455()
	if zeroinConfig._fpsAreasReady then
		return true
	end

	local __OBJECTS = workspace:FindFirstChild("__OBJECTS")
	local Areas = __OBJECTS and __OBJECTS:FindFirstChild("Areas")
	local GuardAreas = Areas and Areas:FindFirstChild("GuardAreas")
	local Build = __OBJECTS and __OBJECTS:FindFirstChild("Build")

	if not GuardAreas or not Build then
		return false
	end

	for _, child in ipairs(GuardAreas:GetChildren()) do
		local RequiredSpeedSign = child:FindFirstChild("RequiredSpeedSign")

		if RequiredSpeedSign then
			pcall(function()
				RequiredSpeedSign:Destroy()
			end)
		end
	end

	local MainMap = Build:FindFirstChild("MainMap")
	local Bases = MainMap and MainMap:FindFirstChild("Bases")

	local function v465(p76)
		if Bases and p76:IsDescendantOf(Bases) then
			local v466 = p76.Size.Y <= 5

			return v466 and not string.find(string.upper(p76.Name), "WALL", 1, true)
		end

		local Parent = p76

		while Parent do
			if Parent == Build then
				break
			end

			if string.find(string.upper(Parent.Name), "BOTTOM", 1, true) then
				return true
			end

			Parent = Parent.Parent
		end

		return false
	end
	local function v468(p77)
		if not p77:IsA("BasePart") then
			return
		end

		if v465(p77) then
			v444(p77)
		else
			pcall(function()
				p77:Destroy()
			end)
		end
	end

	local connection4 = Build.DescendantAdded:Connect(function(descendant)
		task.defer(v468, descendant)
	end)
	local n5 = 0
	local fpsAreaDeleted = 0

	for _, descendant in ipairs(Build:GetDescendants()) do
		local v474 = descendant.Parent ~= nil

		v468(descendant)

		if v474 and descendant.Parent == nil then
			fpsAreaDeleted += 1
		end

		n5 += 1

		if n5 >= 250 then
			n5 = 0
			RunService.Heartbeat:Wait()
		end
	end

	zeroinConfig._fpsAreaListener = connection4
	zeroinConfig._fpsAreaDeleted = fpsAreaDeleted
	zeroinConfig._fpsAreasReady = true

	return true
end
local function v475()
	if zeroinConfig._fpsPlotsReady then
		return true
	end

	local u476 = false
	local ok, result = pcall(function()
		local PlotState2 = require(game:GetService("ReplicatedStorage").Client.PlotState)

		if PlotState2.GetMySlot() == nil then
			warn("[FPSBoost] Slot plot kita belum ke-resolve, skip delete plot dulu (biar aman).")

			return
		end

		local function v480(p78)
			local v481 = PlotState2.GetMySlot()

			return v481 ~= nil and p78.Name == tostring(v481)
		end

		local Plots = PlotState2.GetPlotsFolder() or workspace:WaitForChild("Plots", 10)

		if not Plots then
			warn("[FPSBoost] workspace.Plots gak ketemu sama sekali.")

			return
		end

		local children = Plots:GetChildren()
		local n6 = 0

		for _, child in ipairs(children) do
			if not v480(child) and pcall(function()
				child:Destroy()
			end) then
				n6 += 1
			end
		end

		Plots.ChildAdded:Connect(function(child)
			task.defer(function()
				if child.Parent then
					if not v480(child) then
						pcall(function()
							child:Destroy()
						end)
					end
				end
			end)
		end)
		u476 = true
	end)

	if not ok then
		warn("[FPSBoost] Gagal delete plot pemain lain:", result)

		return false
	end

	return u476
end
local function v487()
	if zeroinConfig._fpsTreadmillsReady then
		return true
	end

	local u488 = false
	local ok, result = pcall(function()
		local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
		local PlotState2 = require(ReplicatedStorage2.Client.PlotState)
		local RuntimeInstanceRegistry = require(ReplicatedStorage2.Client.Modules.RuntimeInstanceRegistry)
		local __ClientTreadmillRenders = workspace:FindFirstChild("__ClientTreadmillRenders") or workspace:WaitForChild("__ClientTreadmillRenders", 10)

		if not __ClientTreadmillRenders then
			return
		end

		local function v495()
			local v496 = PlotState2.GetMySlot()

			if v496 == nil then
				return nil
			end

			local ok, result = pcall(RuntimeInstanceRegistry.Get, "TreadmillPlotRender", tostring(v496))

			if ok then
				return result
			end

			return nil
		end
		local function v499(p79)
			local v500 = v495()

			if v500 then
				if p79 == v500 then
					return true
				end
			end

			local ok, result = pcall(function()
				return p79:GetPivot().Position
			end)

			if not ok then
				return true
			end

			local ok2, result2 = pcall(PlotState2.IsWorldPositionWithinLocalPlotBounds, result)

			return ok2 and result2
		end

		local children = __ClientTreadmillRenders:GetChildren()
		local n7 = 0

		for _, child in ipairs(children) do
			if child:IsA("Model") and not v499(child) and pcall(function()
				child:Destroy()
			end) then
				n7 += 1
			end
		end

		__ClientTreadmillRenders.ChildAdded:Connect(function(child)
			task.defer(function()
				if child.Parent then
					if child:IsA("Model") and not v499(child) then
						pcall(function()
							child:Destroy()
						end)
					end
				end
			end)
		end)
		u488 = true
	end)

	if not ok then
		warn("[FPSBoost] Gagal delete treadmill pemain lain:", result)

		return false
	end

	return u488
end
local function v509()
	if zeroinConfig._fpsBoostApplying then
		return
	end

	zeroinConfig._fpsBoostApplying = true

	local ok, result = pcall(function()
		if type(genv.__ZeroinSetCapFps) == "function" then
			pcall(genv.__ZeroinSetCapFps, 240)
		end

		v448()
		v436()
		zeroinConfig._fpsPlotsReady = v475() == true
		zeroinConfig._fpsTreadmillsReady = v487() == true
		zeroinConfig._fpsAreasReady = v455() == true
		zeroinConfig._fpsPetsReady = v422() == true
		zeroinConfig._fpsEggsReady = v413() == true
	end)

	zeroinConfig._fpsBoostApplying = nil

	if not ok then
		warn("[FPSBoost] Gagal menerapkan FPS Boost:", result)
	end
end

local v512 = v306:Window({
	Title = "Zeroin",
	Footer = "Steal An Egg",
	Version = "3.0.0",
	Discord = "https://discord.gg/CvVW5DBZKR",
	Color = Color3.fromRGB(0, 205, 122),
	Color2 = Color3.fromRGB(1, 18, 11),
	["Tab Width"] = 130,
	Image = "79481584966698",
	WindowIMG = "124404129684886",
	LogoHUB = "124404129684886",
	NotificationIcon = "124404129684886"
})
local v513 = v512

local function v514(p80, p81, p82)
	local u515 = true

	pcall(function()
		local filterDescendantsInstances = { p82 }
		local raycastParams = RaycastParams.new()

		raycastParams.FilterType = Enum.RaycastFilterType.Exclude

		local v518 = p80

		for i = 1, 8 do
			raycastParams.FilterDescendantsInstances = filterDescendantsInstances

			local v520 = p81 - v518

			if not (v520.Magnitude < 1) then
				local hit = workspace:Raycast(v518, v520, raycastParams)

				if hit then
					if hit.Instance.CanCollide then
						u515 = false

						break
					end

					table.insert(filterDescendantsInstances, hit.Instance)
					v518 = hit.Position + v520.Unit * 0.1

					continue
				end
			end

			break
		end
	end)

	return u515
end

local t20 = {}

local function v523()
	local t21 = {}

	t21.__index = t21

	local t22 = {
		auto_place = true,
		auto_fuse = true,
		auto_mutate = true,
		equip_best = true
	}
	local t23 = {
		auto_dr_scramble = 120,
		auto_steal = 100,
		auto_the_rift = 95,
		auto_hatch = 80,
		auto_place = 70,
		auto_mutate = 60,
		auto_fuse = 50,
		equip_best = 40,
		rewards = 20
	}

	local function v527(p83)
		local t24 = {}

		for k, v in pairs(p83) do
			t24[k] = v
		end

		return t24
	end

	t21.new = function()
		local obj = setmetatable({}, t21)

		obj.destroyed = false
		obj.active = nil
		obj.background = nil
		obj.reservations = {}
		obj.protections = {}
		obj.categoryProtections = {}
		obj.listeners = {}
		obj.backgroundListeners = {}
		obj.serial = 0

		return obj
	end
	t21._snapshot = function(p84)
		local active = p84.active

		return {
			busy = active ~= nil,
			operation = active and active.owner or nil,
			priority = active and active.priority or 0,
			reservedCount = active and #active.uids or 0,
			reservations = v527(p84.reservations)
		}
	end
	t21._emit = function(p85)
		local v533 = p85:_snapshot()

		for k in pairs(p85.listeners) do
			local ok, result = pcall(k, v533)

			if not ok then
				warn("[StealAnEgg] Coordinator listener failed:", result)
			end
		end
	end
	t21._emitBackground = function(p86)
		local background = p86.background
		local t25 = {
			busy = background ~= nil,
			operation = background and background.owner or nil
		}

		for k in pairs(p86.backgroundListeners) do
			local ok, result = pcall(k, t25)

			if not ok then
				warn("[StealAnEgg] Background coordinator listener failed:", result)
			end
		end
	end
	t21.subscribe = function(p87, p88)
		p87.listeners[p88] = true
		pcall(p88, p87:_snapshot())

		return function()
			p87.listeners[p88] = nil
		end
	end
	t21.subscribeBackground = function(p89, p90)
		p89.backgroundListeners[p90] = true

		local pcall_ = pcall
		local v543 = p90

		pcall_(v543, {
			busy = p89.background ~= nil,
			operation = p89.background and p89.background.owner or nil
		})

		return function()
			p89.backgroundListeners[p90] = nil
		end
	end
	t21.getSnapshot = function(p91)
		return p91:_snapshot()
	end
	t21.isBackgroundBusy = function(p92)
		return p92.background ~= nil
	end
	t21.isReserved = function(p93, p94, p95)
		local v544 = p93.reservations[p94]

		if v544 ~= nil and v544 ~= p95 then
			return true
		end

		local v545 = p93.protections[p94]

		if v545 == nil or v545 == p95 then
			return false
		end

		if v545 == "auto_the_rift" and (p95 == "auto_place" or p95 == "auto_hatch") then
			return false
		end

		return true
	end
	t21.isCategoryProtected = function(p96, p97, p98)
		local v546 = p96.categoryProtections[p97]

		if v546 == nil or v546 == p98 then
			return false
		end

		if v546 == "auto_the_rift" and (p98 == "auto_place" or p98 == "auto_hatch") then
			return false
		end

		return true
	end
	t21.setProtectedCategories = function(p99, p100, p101)
		if type(p100) ~= "string" or p100 == "" then
			return false
		end

		local t26 = {}
		local ipairs_ = ipairs
		local v549 = type(p101) == "table" and p101 or {}

		for _, v in ipairs_(v549) do
			if type(v) == "string" and v ~= "" then
				t26[v] = true
			end
		end

		local v552 = false

		for k, categoryProtection in pairs(p99.categoryProtections) do
			if not (categoryProtection ~= p100 or t26[k]) then
				p99.categoryProtections[k] = nil
				v552 = true
			end
		end

		for k in pairs(t26) do
			if p99.categoryProtections[k] ~= p100 then
				p99.categoryProtections[k] = p100
				v552 = true
			end
		end

		if v552 then
			p99:_emit()
		end

		return true
	end
	t21.setProtected = function(p102, p103, p104)
		if type(p103) ~= "string" or p103 == "" then
			return false
		end

		local t27 = {}
		local ipairs_ = ipairs
		local v558 = type(p104) == "table" and p104 or {}

		for _, v in ipairs_(v558) do
			if type(v) == "string" and v ~= "" then
				t27[v] = true
			end
		end

		local v561 = false

		for k, protection in pairs(p102.protections) do
			if protection == p103 and not t27[k] then
				p102.protections[k] = nil
				v561 = true
			end
		end

		for k in pairs(t27) do
			if p102.protections[k] ~= p103 then
				p102.protections[k] = p103
				v561 = true
			end
		end

		if v561 then
			p102:_emit()
		end

		return true
	end
	t21.clearProtected = function(p105, p106)
		for k, protection in pairs(p105.protections) do
			if p106 == nil or protection == p106 then
				p105.protections[k] = nil
			end
		end

		for k, categoryProtection in pairs(p105.categoryProtections) do
			if p106 == nil or categoryProtection == p106 then
				p105.categoryProtections[k] = nil
			end
		end

		p105:_emit()
	end
	t21.tryAcquire = function(p107, p108, p109, p110)
		if p107.destroyed then
			return nil, "Coordinator destroyed"
		end

		if type(p108) ~= "string" or p108 == "" then
			return nil, "Invalid operation owner"
		end

		if p107.active then
			return nil, "Busy: " .. p107.active.owner
		end

		if p107.background and t22[p108] then
			return nil, "Busy: background " .. p107.background.owner
		end

		local t28 = {}
		local t29 = {}
		local ipairs_ = ipairs
		local v572 = type(p109) == "table" and p109 or {}

		for _, v in ipairs_(v572) do
			if type(v) ~= "string" or v == "" or t29[v] then
				continue
			end

			if p107:isReserved(v, p108) then
				return nil, "UID reserved by " .. tostring(p107.reservations[v])
			end

			t29[v] = true
			table.insert(t28, v)
		end

		p107.serial += 1

		local active = {
			id = p107.serial,
			lane = "foreground",
			owner = p108,
			priority = tonumber(p110) or t23[p108] or 0,
			uids = t28,
			released = false
		}

		p107.active = active

		for _, v in ipairs(t28) do
			p107.reservations[v] = p108
		end

		p107:_emit()

		return active
	end
	t21.tryAcquireBackground = function(p111, p112, p113)
		if p111.destroyed then
			return nil, "Coordinator destroyed"
		end

		if type(p112) ~= "string" or p112 == "" then
			return nil, "Invalid operation owner"
		end

		if p111.background then
			return nil, "Background busy: " .. p111.background.owner
		end

		if p111.active and t22[p111.active.owner] then
			return nil, "Foreground tool busy: " .. p111.active.owner
		end

		local t30 = {}
		local t31 = {}
		local ipairs_ = ipairs
		local v581 = type(p113) == "table" and p113 or {}

		for _, v in ipairs_(v581) do
			if type(v) ~= "string" then
				continue
			end

			if v ~= "" then
				if t31[v] then
					continue
				end

				if p111:isReserved(v, p112) then
					return nil, "UID reserved by " .. tostring(p111.reservations[v])
				end

				t31[v] = true
				table.insert(t30, v)
			end
		end

		p111.serial += 1

		local background = {
			id = p111.serial,
			lane = "background",
			owner = p112,
			priority = 0,
			uids = t30,
			released = false
		}

		p111.background = background

		for _, v in ipairs(t30) do
			p111.reservations[v] = p112
		end

		p111:_emitBackground()

		return background
	end
	t21.release = function(p114, p115)
		if type(p115) == "table" then
			if not p115.released then
				p115.released = true

				local ipairs_ = ipairs
				local uids = p115.uids or {}

				for _, uid in ipairs_(uids) do
					if p114.reservations[uid] == p115.owner then
						p114.reservations[uid] = nil
					end
				end

				local v591 = p114.active == p115

				if v591 then
					p114.active = nil
				elseif p114.background == p115 then
					p114.background = nil
					p114:_emitBackground()
				end

				if v591 then
					p114:_emit()
				end

				return true
			end
		end

		return false
	end
	t21.forceRelease = function(p116, p117)
		local active = p116.active

		if active and (p117 == nil or active.owner == p117) then
			return p116:release(active)
		end

		return false
	end
	t21.destroy = function(p118)
		if p118.destroyed then
			return
		end

		p118.destroyed = true

		if p118.active then
			p118:release(p118.active)
		end

		if p118.background then
			p118:release(p118.background)
		end

		table.clear(p118.reservations)
		table.clear(p118.protections)
		table.clear(p118.categoryProtections)
		table.clear(p118.listeners)
		table.clear(p118.backgroundListeners)
	end

	return t21
end

local v593 = v523()

local function v594()
	local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
	local Areas = require(ReplicatedStorage2.Data.Areas)
	local Assets = require(ReplicatedStorage2.Data.Assets)
	local Guards = require(ReplicatedStorage2.Data.Guards)
	local Mutations = require(ReplicatedStorage2.Shared.Modules.Mutations)

	local function v600(p119)
		local t32 = {}
		local t33 = {}

		for _, v in ipairs(p119) do
			if type(v) == "string" and v ~= "" and not t32[v] then
				t32[v] = true
				table.insert(t33, v)
			end
		end

		table.sort(t33)

		return t33
	end

	return {
		getRarities = function()
			local t34 = {}

			for k in pairs(Assets.ByRarity) do
				table.insert(t34, k)
			end

			table.sort(t34, function(p120, p121)
				local key = Assets.ByRarity[p120] and next(Assets.ByRarity[p120])
				local key2 = Assets.ByRarity[p121] and next(Assets.ByRarity[p121])
				local v609 = key and Assets.Directory[key]
				local v610 = key2 and Assets.Directory[key2]

				return (v609 and v609.Rarity and v609.Rarity.RarityNumber or 0) > (v610 and v610.Rarity and v610.Rarity.RarityNumber or 0)
			end)

			return t34
		end,
		getNames = function()
			local t35 = {}

			for _, v in pairs(Assets.Directory) do
				table.insert(t35, v.DisplayName or v._id)
			end

			return v600(t35)
		end,
		getAreas = function()
			local t36 = {}

			for k, v in pairs(Areas.Directory) do
				if type(k) == "string" and type(v) == "table" and type(v.DropTable) == "table" then
					table.insert(t36, k)
				end
			end

			table.sort(t36, function(p122, p123)
				local v617 = Guards.Directory[p122]
				local v618 = Guards.Directory[p123]
				local WalkSpeed = v617 and v617.WalkSpeed or math.huge
				local WalkSpeed2 = v618 and v618.WalkSpeed or math.huge

				if WalkSpeed == WalkSpeed2 then
					return p122 < p123
				end

				return WalkSpeed < WalkSpeed2
			end)

			return t36
		end,
		getMutations = function()
			local t37 = {}
			local v622 = Mutations.Ids()
			local pairs_ = pairs
			local v624 = type(v622) == "table" and v622 or {}

			for k in pairs_(v624) do
				if type(k) == "string" and k ~= Mutations.NO_MUTATION then
					local ok, result = pcall(Mutations.LabelOf, k)

					table.insert(t37, ok and type(result) == "string" and result ~= "" and result or k)
				end
			end

			return v600(t37)
		end,
		resolveMutationId = function(p124)
			if type(p124) ~= "string" then
				return nil
			end

			if Mutations.IdSet[p124] then
				return p124
			end

			for k in pairs(Mutations.Ids()) do
				if k ~= Mutations.NO_MUTATION then
					if Mutations.LabelOf(k) == p124 then
						return k
					end
				end
			end

			return nil
		end,
		resolve = function(p125)
			local v629 = p125 and Assets.Directory[p125.AssetCategory]
			local Rarity = v629 and v629.Rarity

			return {
				name = v629 and (v629.DisplayName or v629._id) or p125 and p125.AssetCategory or "Unknown",
				category = p125 and p125.AssetCategory or "Unknown",
				rarity = Rarity and (Rarity.DisplayName or Rarity._id) or "Unknown",
				rarityRank = Rarity and Rarity.RarityNumber or 0,
				rarityColor = Rarity and Rarity.Color or nil
			}
		end
	}
end

local v631 = v594()

local function v632()
	local Players2 = game:GetService("Players")
	local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
	local RunService2 = game:GetService("RunService")
	local LocalPlayer2 = Players2.LocalPlayer
	local EggState2 = require(ReplicatedStorage2.Client.EggState)
	local Remotes = require(ReplicatedStorage2.Shared.Remotes)
	local EggWorld = Remotes.EggWorld
	local AreaEggs = require(ReplicatedStorage2.Shared.Types.AreaEggs)
	local AreaEggSlotIdentity = require(ReplicatedStorage2.Shared.Util.AreaEggSlotIdentity)
	local AreaEggResetWall2 = require(ReplicatedStorage2.Client.AreaEggResetWall)
	local AssetEarnings = require(ReplicatedStorage2.Shared.Util.AssetEarnings)
	local ToolGameplayGuard = require(ReplicatedStorage2.Client.ToolGameplayGuard)
	local Client = require(ReplicatedStorage2.Shared.Modules.BatController.Client)
	local t38 = {
		Divine = true,
		Eternal = true,
		Secret = true
	}
	local t39 = {
		"LastObservedSample",
		"LastSample",
		"LastGoodSample",
		"LastGameplayTrustedSample",
		"LastValidatedSample",
		"LastValidatedGroundedSample",
		"LastConfirmedGroundSample",
		"CandidateGroundedSample"
	}
	local vector32 = Vector3.new(545, 71, -365)
	local t40 = {
		Script = true,
		LocalScript = true,
		BillboardGui = true,
		Sound = true
	}
	local t41 = {}

	t41.__index = t41

	local Stats = game:GetService("Stats")

	local function v652(p126, p127, p128)
		local HumanoidRootPart = LocalPlayer2.Character and LocalPlayer2.Character:FindFirstChild("HumanoidRootPart")

		if HumanoidRootPart then
			pcall(function()
				HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
				HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
			end)
		end

		if not p128 then
			local n8 = 0

			pcall(function()
				n8 = Stats.Network.ServerStats.Ping:GetValue()
			end)
			task.wait(math.max(0.12, n8 * 1.5 / 1000))
		end

		local t42 = {
			Uid = p126
		}

		if p127 ~= nil then
			t42.FirstAreaSlotKey = p127
		end

		local response, v657 = EggWorld.AskFieldEggCarry:InvokeServer(t42)
		local v658 = response == true
		local v659 = typeof(v657) == "string" and v657 or nil

		return v658, v659
	end
	local function v660(p129, p130, p131)
		local connection4 = p129:Connect(p130)

		table.insert(p131, connection4)

		return connection4
	end
	local function v662(p132)
		for _, v in ipairs(p132) do
			pcall(v.Disconnect, v)
		end

		table.clear(p132)
	end
	local function v665(p133, p134)
		local ipairs_ = ipairs
		local v667 = p133 or {}

		for _, v in ipairs_(v667) do
			if v == p134 then
				return true
			end
		end

		return false
	end

	local v670

	local function v671(p135, p136)
		if type(p135) == "function" then
			if type(debug) == "table" and type(debug.getconstants) == "function" then
				local ok, result = pcall(debug.getconstants, p135)

				if not ok or type(result) ~= "table" then
					return false
				end

				local t43 = {}

				for _, v in ipairs(result) do
					if type(v) == "string" then
						t43[v] = true
					end
				end

				for _, v in ipairs(p136) do
					if not t43[v] then
						return false
					end
				end

				return true
			end
		end

		return false
	end
	local function v679(p137)
		if type(p137) ~= "function" or type(debug) ~= "table" or type(debug.info) ~= "function" then
			return ""
		end

		local ok, result = pcall(debug.info, p137, "s")

		return ok and tostring(result) or ""
	end
	local function v682(p138)
		local HumanoidRootPart = p138 and p138:FindFirstChild("HumanoidRootPart")

		if HumanoidRootPart then
			HumanoidRootPart:SetAttribute("KillPartIgnore", true)
		end
	end
	local function v684(p139)
		if p139._healthPinner then
			pcall(p139._healthPinner.Disconnect, p139._healthPinner)
			p139._healthPinner = nil
		end

		if p139._healthChangedConnection then
			pcall(p139._healthChangedConnection.Disconnect, p139._healthChangedConnection)
			p139._healthChangedConnection = nil
		end
	end
	local function v685(p140, p141)
		v684(p140)

		local Humanoid = p141 and p141:FindFirstChildOfClass("Humanoid")
		local HumanoidRootPart = p141 and p141:FindFirstChild("HumanoidRootPart")

		if not Humanoid then
			return false
		end

		local MaxHealth = Humanoid.MaxHealth > 0 and Humanoid.MaxHealth or 100
		local u689 = false

		local function v690()
			if u689 or p140.destroyed or LocalPlayer2.Character ~= p141 or Humanoid.Parent ~= p141 then
				return
			end

			u689 = true
			pcall(function()
				Humanoid.BreakJointsOnDeath = false
				Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)

				if Humanoid.Health <= 0 then
					Humanoid.Health = MaxHealth
				end

				if Humanoid:GetState() == Enum.HumanoidStateType.Dead then
					Humanoid:ChangeState(Enum.HumanoidStateType.Running)
				end

				if HumanoidRootPart and HumanoidRootPart.Parent == p141 and HumanoidRootPart.Anchored then
					HumanoidRootPart.Anchored = false
				end
			end)
			u689 = false
		end

		v690()
		p140._healthChangedConnection = Humanoid.HealthChanged:Connect(function(health)
			if health < MaxHealth then
				v690()
			end
		end)
		p140._healthPinner = RunService2.RenderStepped:Connect(v690)

		return true
	end

	t41.acquireHealthProtection = function(p142, p143)
		if type(p143) ~= "string" or p143 == "" or p142.destroyed then
			return false
		end

		p142.healthProtectionOwners[p143] = true

		local Character = LocalPlayer2.Character

		return Character ~= nil and v685(p142, Character) or false
	end
	t41.releaseHealthProtection = function(p144, p145)
		if type(p145) == "string" then
			p144.healthProtectionOwners[p145] = nil
		end

		if next(p144.healthProtectionOwners) == nil then
			v684(p144)
		end
	end

	local function v692(p146)
		local Humanoid = p146 and p146:FindFirstChildOfClass("Humanoid")

		if not Humanoid then
			return
		end

		pcall(function()
			if Humanoid.Health <= 0 then
				Humanoid.Health = math.max(Humanoid.MaxHealth, 1)
			end

			Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
			Humanoid.BreakJointsOnDeath = true
			Humanoid.RequiresNeck = true
		end)
	end
	local function v694()
		local genv2 = getgenv and getgenv()

		return genv2 or _G
	end
	local function v696()
		local v697 = v694()
		local __FyyStealAnEggMovementSpoof = v697.__FyyStealAnEggMovementSpoof

		if type(__FyyStealAnEggMovementSpoof) ~= "table" or __FyyStealAnEggMovementSpoof.Version ~= 436 then
			if type(__FyyStealAnEggMovementSpoof) == "table" then
				__FyyStealAnEggMovementSpoof.Enabled = false
			end

			__FyyStealAnEggMovementSpoof = {
				Version = 436,
				Installed = false,
				Enabled = false,
				Mode = "StateBaseline",
				Humanoid = nil,
				RootPart = nil,
				WalkSpeed = 800
			}
			v697.__FyyStealAnEggMovementSpoof = __FyyStealAnEggMovementSpoof
		end

		return __FyyStealAnEggMovementSpoof
	end
	local function v699(p147, p148)
		local v700 = v696()

		if not v700 then
			return false
		end

		local Humanoid = p147 and p147:FindFirstChildOfClass("Humanoid")
		local HumanoidRootPart = p147 and p147:FindFirstChild("HumanoidRootPart")

		v700.Humanoid = Humanoid
		v700.RootPart = HumanoidRootPart
		v700.WalkSpeed = math.clamp(tonumber(p148) or 800, 200, 1620)
		v700.Enabled = false

		return Humanoid ~= nil and HumanoidRootPart ~= nil
	end
	local function v703()
		local __FyyStealAnEggMovementSpoof = v694().__FyyStealAnEggMovementSpoof

		if type(__FyyStealAnEggMovementSpoof) == "table" then
			__FyyStealAnEggMovementSpoof.Enabled = false
			__FyyStealAnEggMovementSpoof.Humanoid = nil
			__FyyStealAnEggMovementSpoof.RootPart = nil
		end
	end
	local function v705(p149, p150, p151)
		local u706

		if type(getcallbackvalue) == "function" and type(debug) == "table" and type(debug.getupvalue) == "function" then
			local Signal = ReplicatedStorage2:FindFirstChild("Packages") and ReplicatedStorage2.Packages:FindFirstChild("Signal")

			if Signal then
				local ok, result = pcall(require, Signal)

				if ok and type(result) == "table" and type(result.Invoked) == "function" then
					local ok2, result2 = pcall(result.Invoked, "ClientCharacter: GetDebugSnapshot")

					if ok2 and result2 then
						local ok3, result3 = pcall(getcallbackvalue, result2, "OnInvoke")

						if ok3 and type(result3) == "function" then
							local ok4, result4 = pcall(debug.getinfo, result3)

							if ok4 then
								local function v716(p152, p153, p154)
									if u706 or type(p152) ~= "table" or p153 > 3 or p154[p152] then
										return
									end

									p154[p152] = true

									if rawget(p152, "Player") == p149 and rawget(p152, "Character") == p149.Character and rawget(p152, "Humanoid") == p150 and rawget(p152, "RootPart") == p151 and type(rawget(p152, "SampleHistory")) == "table" and type(rawget(p152, "Evidence")) == "table" then
										u706 = p152

										return
									end

									local n9 = 0

									for _, v in pairs(p152) do
										n9 += 1

										if n9 > 128 then
											break
										end

										if type(v) == "table" then
											v716(v, p153 + 1, p154)
										end
									end
								end

								local n10 = 1
								local nups = result4.nups or 0

								for i = n10, nups do
									local ok5, result5 = pcall(debug.getupvalue, result3, i)

									if ok5 then
										if type(result5) ~= "table" then
											continue
										end

										v716(result5, 0, {})

										if not u706 then
											continue
										end
									else
										continue
									end

									break
								end
							end
						end
					end
				end
			end
		end

		if not u706 and type(getgc) == "function" then
			local ok, result = pcall(getgc, true)

			if ok and type(result) == "table" then
				for _, v in ipairs(result) do
					if type(v) == "table" and rawget(v, "Player") == p149 and rawget(v, "Character") == p149.Character and rawget(v, "Humanoid") == p150 and rawget(v, "RootPart") == p151 and type(rawget(v, "SampleHistory")) == "table" and type(rawget(v, "Evidence")) == "table" then
						u706 = v

						break
					end
				end
			end
		end

		return u706
	end
	local function v729(p155, p156, p157)
		if type(p155) ~= "table" then
			return false
		end

		local value = rawget(p155, "RootPart")
		local CFrame_2 = value and value.Parent and value.CFrame or nil
		local Position = CFrame_2 and CFrame_2.Position or nil
		local vector33 = typeof(p157) == "Vector3" and p157 or Vector3.zero

		local function v734(p158)
			if type(p158) == "table" then
				rawset(p158, "WalkSpeed", p156)

				if CFrame_2 then
					rawset(p158, "CFrame", CFrame_2)
					rawset(p158, "Position", Position)
					rawset(p158, "LinearVelocity", vector33)
					rawset(p158, "AngularVelocity", Vector3.zero)
				end
			end
		end

		for _, v in ipairs(t39) do
			v734(rawget(p155, v))
		end

		local pairs_ = pairs
		local v738 = rawget(p155, "SampleHistory") or {}

		for _, v in pairs_(v738) do
			v734(v)
		end

		local pairs_2 = pairs
		local v742 = rawget(p155, "SafeGroundCheckpoints") or {}

		for _, v in pairs_2(v742) do
			v734(v)
		end

		local value2 = rawget(p155, "Evidence")

		if type(value2) == "table" then
			value2.Speed = 0
			value2.Teleport = 0
			value2.Flight = 0
		end

		local value3 = rawget(p155, "ImpulseContext")

		if type(value3) == "table" then
			local maxHorizontalSpeed = math.max(tonumber(value3.MaxHorizontalSpeed) or 0, p156)
			local v748 = math.max((tonumber(value3.ExpiresAt) or 0) - (tonumber(value3.StartedAt) or 0), 0.05)

			value3.MaxHorizontalSpeed = maxHorizontalSpeed

			if Position then
				value3.OriginPosition = Position
			end

			value3.MaxHorizontalDistance = math.max(tonumber(value3.MaxHorizontalDistance) or 0, maxHorizontalSpeed * v748 + 48)
			v734(value3.PreMovementSafeSample)
		end

		if rawget(p155, "CorrectionContext") == nil then
			rawset(p155, "FirstSuspiciousAt", nil)

			if rawget(p155, "ThreatLevel") == "Observing" then
				rawset(p155, "ThreatLevel", "Trusted")
			end
		end

		return true
	end
	local function v749()
		local v750 = v694()
		local __FyyStealAnEggIntegritySpoof = v750.__FyyStealAnEggIntegritySpoof

		if type(__FyyStealAnEggIntegritySpoof) ~= "table" then
			__FyyStealAnEggIntegritySpoof = {}
			v750.__FyyStealAnEggIntegritySpoof = __FyyStealAnEggIntegritySpoof
		end

		return __FyyStealAnEggIntegritySpoof
	end
	local function v752(p159, p160, p161)
		return type(p159) == "table" and rawget(p159, "Player") == LocalPlayer2 and rawget(p159, "Character") == LocalPlayer2.Character and rawget(p159, "Humanoid") == p160 and rawget(p159, "RootPart") == p161
	end
	local function v753(p162, p163, p164)
		return v752(p162, p163, p164)
	end
	local function v754(p165, p166, p167)
		local v755 = v749()
		local State = v755.State

		if not v752(State, p165, p166) then
			local now = os.clock()

			if now < (v755.NextSearchAt or 0) then
				return false
			end

			v755.NextSearchAt = now + 0.2
			State = v705(LocalPlayer2, p165, p166)
		end

		if not State then
			return false
		end

		if not v753(State, p165, p166) then
			v755.Enabled = false
			v755.Humanoid = p165
			v755.RootPart = p166
			v755.State = State

			return false
		end

		v755.NextSearchAt = 0
		v755.Enabled = true
		v755.Humanoid = p165
		v755.RootPart = p166
		v755.State = State
		v755.WalkSpeed = math.clamp(p167 * 1.35, 200, 1620)
		v755.TravelVelocity = Vector3.zero
		v729(State, v755.WalkSpeed, v755.TravelVelocity)

		return true
	end
	local function v758(p168, p169, p170, p171)
		local __FyyStealAnEggIntegritySpoof = v694().__FyyStealAnEggIntegritySpoof

		if type(__FyyStealAnEggIntegritySpoof) ~= "table" or not __FyyStealAnEggIntegritySpoof.Enabled or __FyyStealAnEggIntegritySpoof.Humanoid ~= p168 or __FyyStealAnEggIntegritySpoof.RootPart ~= p169 or not v753(__FyyStealAnEggIntegritySpoof.State, p168, p169) then
			return false
		end

		__FyyStealAnEggIntegritySpoof.WalkSpeed = math.clamp(p170 * 1.35, 200, 1620)

		if typeof(p171) == "Vector3" then
			__FyyStealAnEggIntegritySpoof.TravelVelocity = p171
		elseif typeof(__FyyStealAnEggIntegritySpoof.TravelVelocity) ~= "Vector3" then
			__FyyStealAnEggIntegritySpoof.TravelVelocity = Vector3.zero
		end

		return v729(__FyyStealAnEggIntegritySpoof.State, __FyyStealAnEggIntegritySpoof.WalkSpeed, __FyyStealAnEggIntegritySpoof.TravelVelocity)
	end
	local function v760(p172)
		local __FyyStealAnEggIntegritySpoof = v694().__FyyStealAnEggIntegritySpoof

		if type(__FyyStealAnEggIntegritySpoof) ~= "table" then
			return
		end

		if p172 == nil or __FyyStealAnEggIntegritySpoof.Humanoid == p172 then
			__FyyStealAnEggIntegritySpoof.Enabled = false
			__FyyStealAnEggIntegritySpoof.Humanoid = nil
			__FyyStealAnEggIntegritySpoof.RootPart = nil
			__FyyStealAnEggIntegritySpoof.State = nil
			__FyyStealAnEggIntegritySpoof.TravelVelocity = nil
			__FyyStealAnEggIntegritySpoof.NextSearchAt = 0
		end
	end

	t41.new = function(p173, p174, p175)
		local obj = setmetatable({}, t41)

		obj.catalog = p173
		obj.isPremium = p175 == true
		obj.preEventReadyAt = os.clock() + 2
		obj.coordinator = p174
		obj.operationToken = nil
		obj.connections = {}
		obj.healthProtectionOwners = {}
		obj.listeners = {}
		obj.records = {}
		obj.enabled = false
		obj.userStealEnabled = false
		obj.riftObjectiveEnabled = false
		obj.riftRequiredCategories = {}
		obj.running = false
		obj.safeStarting = false
		obj.movementRetryPending = false
		obj.destroyed = false
		obj.resetBlocked = AreaEggResetWall2.IsSealed()
		obj.gateOpenAt = obj.resetBlocked and math.huge or os.clock()
		obj.activeTween = nil
		obj.activeTarget = nil
		obj.claimPresentationNode = nil
		obj.claimPresentationOriginal = nil
		obj.claimPresentationSuppression = nil
		obj.carry = {
			active = false,
			uid = nil,
			generation = 0
		}
		obj.manualCarry = {
			active = false,
			uid = nil,
			generation = 0
		}
		obj.carryWorker = nil
		obj.tweenRecoveryUid = nil
		obj.planGeneration = 0
		obj.treadmillDecoy = nil
		obj.treadmillDecoyCamera = nil
		obj.treadmillDecoyCameraConnection = nil
		obj.treadmillDecoyCharacterConnection = nil
		obj.treadmillPopupConnection = nil
		obj.treadmillDecoyRealTransparency = nil
		obj.hoverPadOwnerId = string.format("%s:%0.6f", tostring(obj), os.clock())
		obj.zigzagWalls = obj:_snapshotZigzagWalls()
		obj.instantPhase = nil
		obj.primerUid = nil
		obj.lastAbandonedPrimerUid = nil
		obj.hasDepositedThisSession = false
		obj.targetUid = nil
		obj.resetSnapshotPending = false
		obj.lastAreaState = type(obj.catalog.getLastAreaState) == "function" and obj.catalog.getLastAreaState() or nil
		obj.panelTargetUid = nil
		obj.panelActiveUid = nil
		obj.intentionalGiftUid = nil
		obj.giftDropUids = {}
		obj.continueFromForestGift = false
		obj.playerHuntToken = nil
		obj.playerHuntCarrier = nil
		obj.playerStealBatAuraInstalled = false
		obj.hitTimer = nil
		obj.guardHitBoostInstalled = false
		obj.startupSettled = false
		obj.drScrambleRuntime = nil
		obj.drScrambleObjectiveEnabled = false
		obj.drScrambleRouteActive = false
		obj.drScrambleNeedsSafeReturn = false
		obj.captureTheEggRuntime = nil
		obj.stats = {
			status = obj.resetBlocked and "Reset wall closed" or "Ready",
			available = 0,
			matching = 0,
			lastTarget = "None",
			lastResult = "Idle"
		}
		obj.config = {
			stealMode = "Tween",
			speed = 800,
			stealZigzag = false,
			dropAtFirstArea = false,
			stealFromPlayers = false,
			minValuePerSec = 0,
			rarityEnabled = false,
			rarities = {},
			nameEnabled = false,
			names = {},
			areaEnabled = false,
			areas = {}
		}
		task.delay(3, function()
			if not obj.destroyed and not obj.startupSettled then
				obj:markStartupSettled()
			end
		end)

		if LocalPlayer2.Character then
			v682(LocalPlayer2.Character)
		end

		obj:_replaceSnapshot(EggState2.ReadFieldEggs())
		v660(EggState2.FieldRefreshed, function(p176)
			obj:_replaceSnapshot(p176)
		end, obj.connections)
		v660(EggState2.FieldShifted, function(p177)
			obj.records[p177.Uid] = p177

			if p177.State == AreaEggs.States.GuardCarried and obj.running and obj.activeTarget and obj.activeTarget.Uid == p177.Uid and not obj:isPrimerEgg(p177.Uid) and not obj:isIntentionalGiftDrop(p177.Uid) then
				obj.dropRecoveryUid = p177.Uid
			end

			obj:_refreshCounts()
		end, obj.connections)
		v660(EggState2.FieldGone, function(p178)
			obj.records[p178] = nil

			if obj.panelTargetUid == p178 then
				obj.panelTargetUid = nil
			end

			if obj.playerHuntToken and obj.activeTarget and obj.activeTarget.Uid == p178 then
				obj:_refreshCounts()

				return
			end

			if obj.activeTarget and obj.activeTarget.Uid == p178 then
				if obj:_isDropRecoveryPending(p178) then
					obj:_refreshCounts()

					return
				end

				if obj.carry.active and obj.carry.uid == p178 then
					obj:_refreshCounts()

					return
				end

				obj.carryAttemptToken = nil
				obj:_clearArrivalHold(p178)

				if obj.activeTween and obj.activeTween.Cancel then
					pcall(obj.activeTween.Cancel, obj.activeTween)
				end

				local activeTarget = obj.activeTarget

				task.delay(0.65, function()
					if obj.destroyed or not obj.enabled then
						return
					end

					if obj.carry.active and obj.carry.uid == p178 then
						return
					end

					if obj:_isDropRecoveryPending(p178) then
						return
					end

					if obj.activeTarget == activeTarget and activeTarget.Uid == p178 then
						obj:_finish("Target removed — continuing")
					end
				end)
			end

			obj:_refreshCounts()
		end, obj.connections)
		v660(EggState2.ResetCountdown, function()
			obj.resetSnapshotPending = true
			obj.planGeneration += 1
			obj.panelTargetUid = nil
			obj.panelActiveUid = nil
			obj.intentionalGiftUid = nil
			table.clear(obj.giftDropUids)
			obj.continueFromForestGift = false
			obj:_closeGate("Egg reset countdown")
		end, obj.connections)
		v660(EggState2.ResetFade, function()
			obj.resetSnapshotPending = true
			obj.planGeneration += 1
			obj:_closeGate("Egg reset teleport")
		end, obj.connections)
		v660(AreaEggResetWall2.Changed, function(p179)
			if p179 then
				obj.resetSnapshotPending = true
				obj.planGeneration += 1
				obj:_closeGate("Reset wall closed")
			else
				obj.resetBlocked = false
				obj.gateOpenAt = os.clock()
				obj.preEventReadyAt = os.clock() + 2
				obj:_setStatus(obj.enabled and "Refreshing new rotation" or "Ready")
				obj:_replaceSnapshot(EggState2.ReadFieldEggs())
			end
		end, obj.connections)
		v660(LocalPlayer2.CharacterRemoving, function()
			if obj.drScrambleObjectiveEnabled then
				obj.drScrambleNeedsSafeReturn = true
			end

			obj:releaseDrScrambleRoute(true)

			local manualCarry = obj.manualCarry

			manualCarry.generation += 1
			obj.manualCarry.active = false
			obj.manualCarry.uid = nil
			obj:_cleanupInstantSteal()
			obj:_hideTreadmillDecoy()
			obj.panelTargetUid = nil
			obj.panelActiveUid = nil

			local carry = obj.carry

			carry.generation += 1
			obj:_invalidateCarryWorker()
			obj.carry.active = false
			obj.carry.uid = nil
			obj.intentionalGiftUid = nil
			obj.continueFromForestGift = false
			obj.safeStarting = false
			obj.planGeneration += 1
			obj:_cancelTween("Character resetting")
			obj:_stopMovementProtection()
		end, obj.connections)
		v660(RunService2.Heartbeat, function()
			if obj.destroyed then
				return
			end

			local Character = LocalPlayer2.Character
			local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")

			if not HumanoidRootPart then
				return
			end

			local AssemblyLinearVelocity = HumanoidRootPart.AssemblyLinearVelocity

			if Vector3.new(AssemblyLinearVelocity.X, 0, AssemblyLinearVelocity.Z).Magnitude > 400 or math.abs(AssemblyLinearVelocity.Y) > 400 then
				HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(math.clamp(AssemblyLinearVelocity.X, -100, 100), math.clamp(AssemblyLinearVelocity.Y, -100, 100), math.clamp(AssemblyLinearVelocity.Z, -100, 100))
			end
		end, obj.connections)
		v660(LocalPlayer2.CharacterAdded, function(p180)
			obj:_hideTreadmillDecoy()
			v682(p180)

			if next(obj.healthProtectionOwners) ~= nil then
				v685(obj, p180)
			end

			task.delay(0.25, function()
				if not obj.destroyed and obj.enabled then
					obj:_startMovementProtection()
				end
			end)
			task.delay(1, function()
				if not obj.destroyed and obj.enabled and obj:_wallOpen() then
					obj:_schedule()
				end
			end)
		end, obj.connections)
		obj:_installClaimPresentationFilter()
		v660(EggState2.CarryChanged, function(p181)
			local v769 = p181.IsCarrying and obj.running and obj.activeTarget and p181.Uid == obj.activeTarget.Uid

			if p181.IsCarrying then
				if not v769 and type(p181.Uid) == "string" and p181.Uid ~= "" then
					obj.manualCarry.active = true
					obj.manualCarry.uid = p181.Uid

					local manualCarry = obj.manualCarry

					manualCarry.generation += 1
				end
			elseif obj.manualCarry.active and (p181.Uid == nil or p181.Uid == obj.manualCarry.uid) then
				obj.manualCarry.active = false
				obj.manualCarry.uid = nil

				local manualCarry = obj.manualCarry

				manualCarry.generation += 1
			end

			if p181.IsCarrying then
				if obj.running and obj.activeTarget and p181.Uid == obj.activeTarget.Uid then
					if obj.carry.active and obj.carry.uid == p181.Uid then
						return
					end

					if obj.instantPhase == "priming" and p181.Uid == obj.primerUid then
						obj.carry.active = true
						obj.carry.uid = p181.Uid
						obj:_clearArrivalHold(p181.Uid)
						obj:_enterBaitWait()

						return
					end

					obj.dropRecoveryUid = nil
					obj.guardReturnWait = nil

					local carry = obj.carry

					carry.generation += 1
					obj:_invalidateCarryWorker()
					obj:_clearArrivalHold(p181.Uid)
					obj.claimPresentationSuppression = {
						assetCategory = obj.activeTarget.AssetCategory,
						expiresAt = os.clock() + 8
					}
					obj.carry.active = true
					obj.carry.uid = p181.Uid
					obj.carryStartTime = os.clock()
					obj.carryStartPos = obj.activeTarget and obj.activeTarget.BottomCFrame and obj.activeTarget.BottomCFrame.Position or LocalPlayer2.Character and LocalPlayer2.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer2.Character.HumanoidRootPart.Position

					if obj.tweenRecoveryUid == p181.Uid then
						obj.tweenRecoveryUid = nil
					end

					obj.stats.lastResult = "Carry confirmed"
					obj:_notify()
					obj.carryAttemptToken = nil

					if obj.activeTween and obj.activeTween.Cancel then
						pcall(obj.activeTween.Cancel, obj.activeTween)
					end

					task.defer(function()
						if not obj.destroyed then
							if obj.enabled and obj.carry.uid == p181.Uid and obj:_hasConfirmedCarry(p181.Uid) then
								local v773 = v694()

								if v773 and v773.__ZeroinGodMode then
									pcall(function()
										v773.__ZeroinGodMode:stopDefend()
									end)
								end

								obj:_returnToSafe()
							end
						end
					end)
				end

				return
			end

			if p181.Uid ~= nil then
				if p181.Uid == obj.lastAbandonedPrimerUid and p181.Uid ~= obj.primerUid then
					return
				end

				local uid = obj.carry.uid or obj.activeTarget and obj.activeTarget.Uid

				if uid ~= nil and p181.Uid ~= uid and p181.Uid ~= obj.intentionalGiftUid then
					return
				end
			elseif not obj.carry.active then
				return
			end

			local Uid = p181.Uid or obj.carry.uid

			Uid = Uid or obj.activeTarget and obj.activeTarget.Uid

			if obj.intentionalGiftUid ~= nil and Uid == obj.intentionalGiftUid then
				local intentionalGiftUid = obj.intentionalGiftUid

				obj.intentionalGiftUid = nil
				obj.giftDropUids[intentionalGiftUid] = true

				local carry = obj.carry

				carry.generation += 1
				obj:_invalidateCarryWorker()
				obj:_clearArrivalHold(intentionalGiftUid)

				if obj.activeTween and obj.activeTween.Cancel then
					pcall(obj.activeTween.Cancel, obj.activeTween)
				end

				obj.carry.active = false
				obj.carry.uid = nil
				obj.continueFromForestGift = true
				obj:_finish("Egg dropped at Forest")

				return
			end

			if not obj.carry.active and obj:_isDropRecoveryPending(Uid) then
				return
			end

			local active = obj.carry.active

			if active and not obj:isPrimerEgg(Uid) and not obj:isIntentionalGiftDrop(Uid) then
				obj.dropRecoveryUid = Uid

				local v779 = v694()

				if v779 and v779.__ZeroinGodMode then
					pcall(function()
						v779.__ZeroinGodMode:startDefend(Uid)
					end)
				end
			end

			local carry = obj.carry

			carry.generation += 1

			local generation = obj.carry.generation

			obj:_invalidateCarryWorker()

			if obj.activeTween and obj.activeTween.Cancel then
				pcall(obj.activeTween.Cancel, obj.activeTween)
			end

			obj.carry.active = false
			obj.carry.uid = nil

			if obj.instantPhase == "priming" and (p181.Uid == obj.primerUid or Uid == obj.primerUid) then
				obj:_startPrimerTargetHunt()

				return
			end

			if not active then
				return
			end

			if not obj.running or not obj.activeTarget then
				return
			end

			local HumanoidRootPart = LocalPlayer2.Character and LocalPlayer2.Character:FindFirstChild("HumanoidRootPart")

			if HumanoidRootPart then
				if obj:_isInSafeArea(HumanoidRootPart) then
					obj:_finish("Safe return complete")

					return
				end
			end

			task.delay(0.03, function()
				if obj.destroyed or not obj.enabled or obj.carry.active or obj.carry.generation ~= generation then
					return
				end

				local HumanoidRootPart2 = LocalPlayer2.Character and LocalPlayer2.Character:FindFirstChild("HumanoidRootPart")

				if HumanoidRootPart2 and obj:_isInSafeArea(HumanoidRootPart2) then
					obj:_finish("Safe return complete")

					return
				end

				obj:_reStealDroppedEgg(Uid)
			end)
		end, obj.connections)
		v660(LocalPlayer2:GetAttributeChangedSignal("RagdollEndTime"), function()
			local attribute = LocalPlayer2:GetAttribute("RagdollEndTime") or 0

			if obj.instantPhase == "priming" and workspace:GetServerTimeNow() < attribute then
				obj:_startPrimerTargetHunt()
			end
		end, obj.connections)

		return obj
	end
	t41._installClaimPresentationFilter = function(p182)
		if p182.claimPresentationNode then
			return true
		end

		if type(EggState2.FieldClaimed.GetConnections) ~= "function" then
			return false
		end

		for _, v in ipairs(EggState2.FieldClaimed:GetConnections()) do
			local claimPresentationOriginal = type(v) == "table" and rawget(v, "_fn") or nil

			if v679(claimPresentationOriginal):find("PlayerScripts.Game.AreaEggs", 1, true) and v671(claimPresentationOriginal, {
				"Bottom",
				"Message",
				"Color",
				"Time"
			}) then
				p182.claimPresentationNode = v
				p182.claimPresentationOriginal = claimPresentationOriginal

				local function claimPresentationWrapper(p183)
					local claimPresentationSuppression = p182.claimPresentationSuppression

					if claimPresentationSuppression and claimPresentationSuppression.expiresAt < os.clock() then
						p182.claimPresentationSuppression = nil
						claimPresentationSuppression = nil
					end

					if not p182.destroyed and p182.enabled and claimPresentationSuppression and type(p183) == "table" and p183.AssetCategory == claimPresentationSuppression.assetCategory then
						p182.claimPresentationSuppression = nil

						return
					end

					return claimPresentationOriginal(p183)
				end

				p182.claimPresentationWrapper = claimPresentationWrapper
				v._fn = claimPresentationWrapper

				return true
			end
		end

		return false
	end
	t41._restoreClaimPresentationFilter = function(p184)
		local claimPresentationNode = p184.claimPresentationNode
		local claimPresentationOriginal = p184.claimPresentationOriginal

		if type(claimPresentationNode) == "table" then
			if type(claimPresentationOriginal) == "function" and rawget(claimPresentationNode, "_fn") == p184.claimPresentationWrapper then
				claimPresentationNode._fn = claimPresentationOriginal
			end
		end

		p184.claimPresentationNode = nil
		p184.claimPresentationOriginal = nil
		p184.claimPresentationWrapper = nil
		p184.claimPresentationSuppression = nil
	end
	t41._setStatus = function(p185, p186)
		if p185.stats.status == p186 then
			return
		end

		p185.stats.status = p186
		p185:_notify()
	end
	t41._notify = function(p187)
		local v792 = p187:getSnapshot()

		for k in pairs(p187.listeners) do
			local ok, result = pcall(k, v792)

			if not ok then
				warn("[StealAnEgg] UI listener failed:", result)
			end
		end
	end
	t41.onChanged = function(p188, p189)
		p188.listeners[p189] = true

		local ok, result = pcall(p189, p188:getSnapshot())

		if not ok then
			warn("[StealAnEgg] UI listener failed:", result)
		end

		return function()
			p188.listeners[p189] = nil
		end
	end
	t41.getSnapshot = function(p190)
		return {
			status = p190.stats.status,
			available = p190.stats.available,
			matching = p190.stats.matching,
			lastTarget = p190.stats.lastTarget,
			lastResult = p190.stats.lastResult,
			lastAreaLabel = p190.lastAreaState and p190.lastAreaState.label or "Unknown",
			lastAreaId = p190.lastAreaState and p190.lastAreaState.areaId or nil,
			lastAreaVariant = p190.lastAreaState and p190.lastAreaState.variantId or nil,
			lastAreaPeriod = p190.lastAreaState and p190.lastAreaState.period or nil,
			wallClosed = p190.resetBlocked or AreaEggResetWall2.IsSealed() or os.clock() < p190.gateOpenAt,
			enabled = p190.enabled,
			running = p190.running
		}
	end
	t41._replaceSnapshot = function(p191, p192)
		table.clear(p191.records)

		local Records = p192 and (p192.Records or p192) or {}

		for k, Record in pairs(Records) do
			if type(Record) == "table" and type(Record.Uid) == "string" then
				p191.records[Record.Uid] = Record
			elseif type(k) == "string" and type(Record) == "table" then
				p191.records[k] = Record
			end
		end

		p191.lastAreaState = type(p191.catalog.getLastAreaState) == "function" and p191.catalog.getLastAreaState() or nil

		if p191.resetSnapshotPending and not p191.resetBlocked and not AreaEggResetWall2.IsSealed() then
			p191.resetSnapshotPending = false
			p191.gateOpenAt = os.clock()
			p191:_setStatus(p191.enabled and "Searching" or "Ready")
		end

		p191:_refreshCounts()

		if not p191.resetSnapshotPending then
			p191:_schedule()
		end
	end
	t41.isIntentionalGiftDrop = function(p193, p194)
		return type(p194) == "string" and p194 ~= "" and (p194 == p193.intentionalGiftUid or p193.giftDropUids[p194] == true)
	end
	t41._isRiftObjective = function(p195, p196)
		return p195.riftObjectiveEnabled and type(p196) == "table" and not p195:isIntentionalGiftDrop(p196.Uid) and p195.riftRequiredCategories[p196.AssetCategory] == true
	end
	t41._matchesNormalFilter = function(p197, p198)
		if p197:isIntentionalGiftDrop(p198 and p198.Uid) then
			return false
		end

		local v801 = p197.catalog.resolve(p198)
		local config = p197.config

		if config.rarityEnabled and not (#config.rarities ~= 0 and v665(config.rarities, v801.rarity)) then
			return false
		end

		local v803

		if not config.nameEnabled then
			if config.areaEnabled and not (#config.areas ~= 0 and v665(config.areas, p198.AreaId)) then
				return false
			end

			local minValuePerSec = config.minValuePerSec or 0

			if minValuePerSec > 0 then
				v803 = v670(p198)

				if not v803 or v803 < config.minValuePerSec then
					return false
				end
			end

			return true
		end

		if #config.names == 0 or not v665(config.names, v801.name) and not v665(config.names, v801.category) then
			return false
		end

		if config.areaEnabled and not (#config.areas ~= 0 and v665(config.areas, p198.AreaId)) then
			return false
		end

		if (config.minValuePerSec or 0) > 0 then
			v803 = v670(p198)

			if not v803 or v803 < config.minValuePerSec then
				return false
			end
		end

		return true
	end
	t41._matches = function(p199, p200)
		if p200.State ~= AreaEggs.States.Slot and p200.State ~= AreaEggs.States.Dropped then
			return false
		end

		if p199.riftObjectiveEnabled and p199:_isRiftObjective(p200) then
			return true
		end

		if p199.userStealEnabled and p199:_matchesNormalFilter(p200) then
			return true
		end

		return false
	end
	t41._isForeignCarryCandidate = function(p201, p202)
		local stealFromPlayers = p201.isPremium and p201.config.stealFromPlayers

		return stealFromPlayers and p201.userStealEnabled and type(p202) == "table" and p202.State == AreaEggs.States.Carried and type(p202.CarrierUserId) == "number" and p202.CarrierUserId ~= LocalPlayer2.UserId and not p201:isIntentionalGiftDrop(p202.Uid) and p201:_matchesNormalFilter(p202)
	end
	t41._resolveForeignCarrier = function(p203, p204, p205)
		if not p203:_isForeignCarryCandidate(p204) then
			return nil
		end

		local playerByUserId = Players2:GetPlayerByUserId(p204.CarrierUserId)
		local Character = playerByUserId and playerByUserId.Character
		local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
		local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

		if not playerByUserId or not HumanoidRootPart or not Humanoid or Humanoid.Health <= 0 then
			return nil
		end

		if playerByUserId:GetAttribute("InBossArena") == true then
			return nil
		end

		local v810 = tonumber(playerByUserId:GetAttribute("RagdollEndTime")) or 0

		if workspace:GetServerTimeNow() < v810 then
			return nil
		end

		if p205 or ToolGameplayGuard.IsInsideArena(playerByUserId) and not ToolGameplayGuard.IsInsideSafeZone(playerByUserId) then
			return playerByUserId, HumanoidRootPart, Humanoid
		end

		return nil
	end
	t41.isPrimerEgg = function(p206, p207)
		if type(p207) == "string" then
			if p207 ~= "" then
				return p207 == p206.primerUid or p207 == p206.lastAbandonedPrimerUid
			end
		end

		return false
	end
	t41.hasMatchingUserEggs = function(p208)
		if p208.enabled then
			if p208.userStealEnabled and not p208.destroyed then
				if not p208.drScrambleRouteActive and (p208.running or p208.activeTarget ~= nil or p208.tweenRecoveryUid ~= nil) then
					return true
				end

				for _, record in pairs(p208.records) do
					if record.State ~= AreaEggs.States.Slot and record.State ~= AreaEggs.States.Dropped then
						if p208:_isForeignCarryCandidate(record) then
							return true
						end

						continue
					end

					if p208:_matchesNormalFilter(record) then
						return true
					end
				end

				return false
			end
		end

		return false
	end
	t41._hasActiveUserTargetFilter = function(p209)
		local config = p209.config
		local v814 = config.rarityEnabled == true or config.nameEnabled == true or config.areaEnabled == true

		if not v814 then
			v814 = (config.minValuePerSec or 0) > 0
		end

		return v814
	end
	t41.hasDrPriorityEggsAuthoritative = function(p210, p211)
		if p210.destroyed or not p210.userStealEnabled or not p210:_hasActiveUserTargetFilter() then
			return false
		end

		if p211 ~= true and not p210.drScrambleRouteActive and (p210.running or p210.activeTarget ~= nil or p210.tweenRecoveryUid ~= nil or p210.carry.active) then
			return true
		end

		local ok, result = pcall(EggState2.ReadFieldEggs)
		local Records = ok and type(result) == "table" and (type(result.Records) == "table" and result.Records or result) or p210.records

		for _, Record in pairs(Records) do
			if type(Record) ~= "table" then
				continue
			end

			if Record.State ~= AreaEggs.States.Slot and Record.State ~= AreaEggs.States.Dropped then
				continue
			end

			if p210:_matchesNormalFilter(Record) then
				return true
			end
		end

		return false
	end
	t41.hasMatchingUserEggsAuthoritative = function(p212)
		if p212.enabled then
			if p212.userStealEnabled and not p212.destroyed then
				if not p212.drScrambleRouteActive and (p212.running or p212.activeTarget ~= nil or p212.tweenRecoveryUid ~= nil) then
					return true
				end

				local ok, result = pcall(EggState2.ReadFieldEggs)

				if not ok or type(result) ~= "table" then
					return p212:hasMatchingUserEggs()
				end

				local Records = type(result.Records) == "table" and result.Records or result

				for _, Record in pairs(Records) do
					if type(Record) ~= "table" then
						continue
					end

					if (Record.State == AreaEggs.States.Slot or Record.State == AreaEggs.States.Dropped) and p212:_matchesNormalFilter(Record) then
						return true
					end

					if p212:_isForeignCarryCandidate(Record) then
						return true
					end
				end

				return p212:hasMatchingUserEggs()
			end
		end

		return false
	end
	t41._refreshCounts = function(p213)
		local available = 0
		local matching = 0

		for _, record in pairs(p213.records) do
			if record.State == AreaEggs.States.Slot then
				available += 1

				if p213:_matches(record) then
					matching += 1
				end
			elseif p213:_isForeignCarryCandidate(record) then
				matching += 1
			end
		end

		p213.stats.available = available
		p213.stats.matching = matching
		p213:_notify()
	end
	t41._chooseTarget = function(p214)
		local HumanoidRootPart = LocalPlayer2.Character and LocalPlayer2.Character:FindFirstChild("HumanoidRootPart")

		if not HumanoidRootPart then
			return nil
		end

		local panelTargetUid = p214.panelTargetUid

		if type(panelTargetUid) == "string" and panelTargetUid ~= "" then
			local v831 = EggState2.ReadFieldEgg(panelTargetUid) or p214.records[panelTargetUid]

			if not (type(v831) ~= "table" or v831.State ~= AreaEggs.States.Slot and v831.State ~= AreaEggs.States.Dropped or p214:isIntentionalGiftDrop(panelTargetUid)) then
				p214.panelTargetUid = nil
				p214.panelActiveUid = panelTargetUid

				return v831
			end

			p214.panelTargetUid = nil

			if not p214.userStealEnabled and not p214.riftObjectiveEnabled and p214.panelActiveUid == nil then
				task.defer(function()
					if not p214.destroyed then
						p214:_reconcileRunningState()
					end
				end)
			end
		end

		if p214.userStealEnabled and p214.config.stealFromPlayers then
			local v832
			local v833
			local v834

			for _, record in pairs(p214.records) do
				if p214:_isForeignCarryCandidate(record) then
					local playerByUserId = Players2:GetPlayerByUserId(record.CarrierUserId)
					local HumanoidRootPart2 = playerByUserId and playerByUserId.Character and playerByUserId.Character:FindFirstChild("HumanoidRootPart")
					local rarityRank = p214.catalog.resolve(record).rarityRank or 0
					local Magnitude = HumanoidRootPart2 and (HumanoidRootPart2.Position - HumanoidRootPart.Position).Magnitude or math.huge

					if not v832 or v833 < rarityRank or rarityRank == v833 and Magnitude < v834 then
						v832 = record
						v833 = rarityRank
						v834 = Magnitude
					end
				end
			end

			if v832 then
				return v832
			end
		end

		if p214.userStealEnabled then
			local v841
			local v842
			local v843

			for _, record in pairs(p214.records) do
				if (record.State == AreaEggs.States.Slot or record.State == AreaEggs.States.Dropped) and p214:_matchesNormalFilter(record) then
					local v846 = p214.catalog.resolve(record)

					if t38[v846.rarity] then
						local Magnitude = (record.BottomCFrame.Position - HumanoidRootPart.Position).Magnitude
						local rarityRank = v846.rarityRank or 0

						if not v841 or v842 < rarityRank or rarityRank == v842 and Magnitude < v843 then
							v841 = record
							v842 = rarityRank
							v843 = Magnitude
						end
					end
				end
			end

			if v841 then
				return v841
			end
		end

		if p214.riftObjectiveEnabled then
			local v849
			local v850

			for _, record in pairs(p214.records) do
				if (record.State == AreaEggs.States.Slot or record.State == AreaEggs.States.Dropped) and p214:_isRiftObjective(record) then
					local Magnitude = (record.BottomCFrame.Position - HumanoidRootPart.Position).Magnitude

					if not v849 or Magnitude < v850 then
						v849 = record
						v850 = Magnitude
					end
				end
			end

			if v849 then
				return v849
			end
		end

		if p214.userStealEnabled then
			local v854
			local v855
			local v856

			for _, record in pairs(p214.records) do
				if (record.State == AreaEggs.States.Slot or record.State == AreaEggs.States.Dropped) and p214:_matchesNormalFilter(record) then
					local Magnitude = (record.BottomCFrame.Position - HumanoidRootPart.Position).Magnitude
					local rarityRank = p214.catalog.resolve(record).rarityRank or 0

					if not v854 or v855 < rarityRank or rarityRank == v855 and Magnitude < v856 then
						v854 = record
						v855 = rarityRank
						v856 = Magnitude
					end
				end
			end

			if v854 then
				return v854
			end
		end

		return nil
	end
	t41.setTreadmillManager = function(p215, p216)
		p215.treadmillManager = p216
	end
	t41.setRiftRuntime = function(p217, p218)
		p217.riftRuntime = p218
	end
	t41.setDrScrambleRuntime = function(p219, p220)
		p219.drScrambleRuntime = p220
	end
	t41.setDrScrambleObjective = function(p221, p222)
		p221.drScrambleObjectiveEnabled = p222 == true

		if not p221.drScrambleObjectiveEnabled then
			p221.drScrambleNeedsSafeReturn = false
			p221:releaseDrScrambleRoute()
		end

		p221:_reconcileRunningState()
	end
	t41.releaseDrScrambleRoute = function(p223, p224)
		if not (p223.drScrambleRouteActive or p223.operationToken and p223.operationToken.owner == "auto_dr_scramble") then
			return false
		end

		local drScrambleRuntime = p223.drScrambleRuntime

		p223.drScrambleRouteActive = false
		p223.safeStarting = false
		p223.running = false
		p223.activeTarget = nil

		if drScrambleRuntime and type(drScrambleRuntime.releaseEventLock) == "function" then
			drScrambleRuntime:releaseEventLock()
		end

		p223:_cancelTween("Dr. Scramble route released")

		if p224 ~= true and not p223.destroyed and p223.enabled then
			p223:_scheduleMovementRetry()
		end

		return true
	end
	t41._finishDrScrambleTravel = function(p225, p226, p227, p228)
		p225.safeStarting = false
		p225.running = false

		if not p225.drScrambleRouteActive then
			return
		end

		if p226 and p227 and p227:lockAfterSharedTravel(p228) == true then
			p225:_setStatus("Locked to event robot")

			return
		end

		p225:releaseDrScrambleRoute()
	end
	t41._finishDrScrambleSafeReturn = function(p229, p230)
		if not p229.drScrambleRouteActive then
			return
		end

		p229.drScrambleRouteActive = false
		p229.safeStarting = false
		p229.running = false
		p229.activeTarget = nil
		p229:_releaseOperation()

		if p230 then
			p229.drScrambleNeedsSafeReturn = false
		end

		p229:_setStatus(p230 and "Safe zone ready for event" or "Retrying event safe zone")

		if not p229.destroyed and p229.enabled then
			p229:_scheduleMovementRetry()
		end
	end
	t41._returnToSafeForDrScramble = function(p231, p232)
		if p231.drScrambleRouteActive or not p232 then
			return false
		end

		local v862 = p231:_resolveSafeCFrame(p232)

		if not v862 then
			return false
		end

		local autoDrScramble, v864 = p231.coordinator:tryAcquire("auto_dr_scramble", {})

		if autoDrScramble then
			p231.operationToken = autoDrScramble
			p231.drScrambleRouteActive = true
			p231.safeStarting = true
			p231.running = true
			p231.activeTarget = nil
			p231:_setStatus("Returning to safe zone for event")
			p231:_tweenRoot(v862, function()
				p231:_finishDrScrambleSafeReturn(true)
			end, nil, {
				flightProfile = true,
				abort = function()
					return not p231.drScrambleObjectiveEnabled or not p231:_wallOpen()
				end,
				onDone = function(p233)
					if not p233 then
						p231:_finishDrScrambleSafeReturn(false)
					end
				end
			})

			return true
		end

		p231:_setStatus("Dr. Scramble safe zone waiting · " .. tostring(v864 or "busy"))
		p231:_scheduleMovementRetry()

		return false
	end
	t41._startDrScrambleRoute = function(p234, p235)
		if p234.drScrambleRouteActive or type(p235) ~= "table" or typeof(p235.destination) ~= "CFrame" then
			return false
		end

		local autoDrScramble, v866 = p234.coordinator:tryAcquire("auto_dr_scramble", {})

		if not autoDrScramble then
			p234:_setStatus("Dr. Scramble waiting · " .. tostring(v866 or "busy"))
			p234:_scheduleMovementRetry()

			return false
		end

		p234.operationToken = autoDrScramble
		p234.drScrambleRouteActive = true
		p234.safeStarting = true
		p234.running = true
		p234.activeTarget = nil
		p234:_setStatus("Traveling to event robot")

		local drScrambleRuntime = p234.drScrambleRuntime
		local v868 = drScrambleRuntime and drScrambleRuntime:getGeneration() or 0

		p234:_tweenRoot(p235.destination, function()
			p234:_finishDrScrambleTravel(true, drScrambleRuntime, v868)
		end, nil, {
			groundedProfile = true,
			dynamicDestination = function()
				local v869 = drScrambleRuntime and drScrambleRuntime:getEventRoute()

				return v869 and v869.destination or nil
			end,
			projectGroundPosition = function(p236)
				return drScrambleRuntime and drScrambleRuntime:projectGroundPosition(p236) or nil
			end,
			abort = function()
				return not p234.drScrambleObjectiveEnabled or not p234:_wallOpen() or p234:hasMatchingUserEggsAuthoritative()
			end,
			onDone = function(p237)
				if not p237 then
					p234:_finishDrScrambleTravel(false, drScrambleRuntime, v868)
				end
			end
		})

		return true
	end
	t41.setCaptureTheEggRuntime = function(p238, p239)
		p238.captureTheEggRuntime = p239
	end
	t41.setRiftObjective = function(p240, p241, p242)
		local riftObjectiveEnabled = p241 == true
		local riftRequiredCategories = {}
		local ipairs_ = ipairs
		local v873 = type(p242) == "table"

		v873 = v873 and p242 or {}

		for _, v in ipairs_(v873) do
			if type(v) == "string" and v ~= "" then
				riftRequiredCategories[v] = true
			end
		end

		p240.riftObjectiveEnabled = riftObjectiveEnabled
		p240.riftRequiredCategories = riftRequiredCategories
		p240:_reconcileRunningState()
	end
	t41.getStealMode = function(p243)
		return p243.config.stealMode or "Tween"
	end
	t41.setStealMode = function(p244, p245)
		local stealMode = p245 == "Instant" and "Instant" or "Tween"

		if p244.config.stealMode ~= stealMode then
			p244.config.stealMode = stealMode

			if p244.enabled then
				if p244.carry.active then
					p244.stats.lastResult = "Mode set to " .. stealMode .. " (finishing carry)"
					p244:_notify()

					return stealMode
				end

				p244.planGeneration += 1
				p244.safeStarting = false
				p244:_cancelTween("Mode changed")
				task.delay(0.1, function()
					if not p244.destroyed and p244.enabled and not p244.running then
						p244:_schedule()
					end
				end)
			end
		end

		return stealMode
	end
	t41._setInstantAnchored = function(p246, p247)
		pcall(function()
			local HumanoidRootPart = LocalPlayer2.Character and LocalPlayer2.Character:FindFirstChild("HumanoidRootPart")

			if HumanoidRootPart and HumanoidRootPart.Anchored ~= p247 then
				HumanoidRootPart.Anchored = p247
			end
		end)
	end
	t41._kbCancelTimer = function(p248)
		local hitTimer = p248.hitTimer

		p248.hitTimer = nil
		p248.baitWaitToken = nil
		p248.waitingGuardHit = false

		if hitTimer and hitTimer ~= coroutine.running() then
			pcall(task.cancel, hitTimer)
		end

		if p248.baitHitConnections then
			v662(p248.baitHitConnections)
			p248.baitHitConnections = nil
		end

		if p248.antiGuard then
			p248.antiGuard:setPrimerHitWindow(false)
		end
	end

	local _selectClosestTarget

	t41._installPlayerStealBatAura = function(p249)
		if p249.playerStealBatAuraInstalled then
			return true
		end

		if type(Client) == "table" then
			if type(Client._selectClosestTarget) == "function" then
				_selectClosestTarget = _selectClosestTarget or Client._selectClosestTarget

				local v880 = p249

				Client._selectClosestTarget = function(p250)
					local playerHuntCarrier = v880.playerHuntToken and v880.playerHuntCarrier

					playerHuntCarrier = playerHuntCarrier or nil

					if playerHuntCarrier and playerHuntCarrier.Parent == Players2 then
						local Character = LocalPlayer2.Character
						local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
						local HumanoidRootPart2 = playerHuntCarrier.Character and playerHuntCarrier.Character:FindFirstChild("HumanoidRootPart")

						if HumanoidRootPart and HumanoidRootPart2 and (HumanoidRootPart2.Position - HumanoidRootPart.Position).Magnitude <= 500 then
							local v885 = true

							if type(p250._isTargetEligible) == "function" then
								local ok, result = pcall(p250._isTargetEligible, p250, playerHuntCarrier, HumanoidRootPart, 500)

								v885 = ok and result == true
							end

							if v885 then
								return playerHuntCarrier
							end
						end
					end

					return _selectClosestTarget(p250)
				end
				p249.playerStealBatAuraInstalled = true

				return true
			end
		end

		return false
	end
	t41._removePlayerStealBatAura = function(p251)
		if not p251.playerStealBatAuraInstalled then
			return
		end

		if type(Client) == "table" and _selectClosestTarget then
			Client._selectClosestTarget = _selectClosestTarget
		end

		p251.playerStealBatAuraInstalled = false
	end
	t41._cleanupInstantSteal = function(p252)
		p252.instantPhase = nil
		p252.primerUid = nil
		p252.targetUid = nil
		p252.playerHuntToken = nil
		p252.playerHuntCarrier = nil
		p252:_removePlayerStealBatAura()
		p252:_kbCancelTimer()
		p252:_setInstantAnchored(false)
		p252:_hideTreadmillDecoy()
	end
	t41._triggerInstantForestHit = function(p253, p254)
		if p253.destroyed or not p253.enabled or not p253.waitingGuardHit or p253.baitWaitToken ~= p254 or p253.instantPhase ~= "priming" then
			return
		end

		local Character = LocalPlayer2.Character
		local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
		local Forest = p253:_findAreaGuardRoot("Forest")

		if not HumanoidRootPart or not Forest then
			return
		end

		local primerUid = p253.primerUid

		if not primerUid then
			return
		end

		HumanoidRootPart.CFrame = cFrameNew(Forest.Position + Vector3.new(0, 0.8, 0))
		HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
		HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero

		local Collider = Forest.Parent and Forest.Parent:FindFirstChild("Collider") or Forest
		local firetouchinterest_ = v694().firetouchinterest or firetouchinterest

		if Collider:IsA("BasePart") and type(firetouchinterest_) == "function" then
			pcall(function()
				firetouchinterest_(HumanoidRootPart, Collider, 0)
				firetouchinterest_(HumanoidRootPart, Collider, 1)
			end)
		end

		if p253.baitWaitToken ~= p254 or not p253.waitingGuardHit then
			return
		end

		local ForestStrike = Remotes.GuardPatrol and Remotes.GuardPatrol.ForestStrike

		if ForestStrike then
			pcall(function()
				ForestStrike:FireServer({
					EggUid = primerUid,
					GuardCFrame = Forest.CFrame
				})
			end)
		end
	end
	t41._choosePrimerEgg = function(p255, p256)
		local __OBJECTS = workspace:FindFirstChild("__OBJECTS")
		local Areas = __OBJECTS and __OBJECTS:FindFirstChild("Areas")
		local GuardAreas = Areas and Areas:FindFirstChild("GuardAreas")
		local Forest = GuardAreas and GuardAreas:FindFirstChild("Forest") or Areas and Areas:FindFirstChild("Forest")
		local Guard = Forest and (Forest:FindFirstChild("Guard") or Forest:FindFirstChild("ForestGuardAuthored"))
		local HumanoidRootPart = Guard and Guard:FindFirstChild("HumanoidRootPart")
		local Position = HumanoidRootPart and HumanoidRootPart.Position
		local v902
		local v903

		for _, record in pairs(p255.records) do
			if (record.State == AreaEggs.States.Slot or record.State == AreaEggs.States.Dropped) and record.AreaId == "Forest" and record.Uid ~= p256 then
				local v906 = -(Position and (record.BottomCFrame.Position - Position).Magnitude or LocalPlayer2.Character and LocalPlayer2.Character:FindFirstChild("HumanoidRootPart") and (record.BottomCFrame.Position - LocalPlayer2.Character.HumanoidRootPart.Position).Magnitude or math.huge) - (p255.catalog.resolve(record).rarityRank or 0) * 100

				if not v902 or v903 < v906 then
					v902 = record
					v903 = v906
				end
			end
		end

		return v902
	end
	t41._enterBaitWait = function(p257)
		if not p257.baitWaitToken and not p257.destroyed then
			if p257.enabled and p257.instantPhase == "priming" and p257.primerUid then
				local Character = LocalPlayer2.Character
				local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
				local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

				if not HumanoidRootPart or not Humanoid then
					p257:_finish("Character unavailable")

					return
				end

				p257.carryAttemptToken = nil

				if p257.activeTween then
					pcall(p257.activeTween.Cancel, p257.activeTween)
				end

				p257:_clearArrivalHold()
				p257:_stopHoverPad()
				p257:_setInstantAnchored(false)

				local baitWaitToken = {}
				local primerUid = p257.primerUid

				p257.baitWaitToken = baitWaitToken
				p257.waitingGuardHit = true
				p257:_setStatus("Waiting for guard hit")
				p257.baitHitConnections = {}

				local u912 = false

				local function v913()
					if p257.baitWaitToken == baitWaitToken and p257.waitingGuardHit then
						u912 = true
					end
				end

				v660(Humanoid.StateChanged, function(p258, p259)
					if p259 == Enum.HumanoidStateType.Ragdoll or p259 == Enum.HumanoidStateType.FallingDown or p259 == Enum.HumanoidStateType.PlatformStanding then
						v913()
					end
				end, p257.baitHitConnections)
				v660(Humanoid:GetPropertyChangedSignal("PlatformStand"), function()
					if Humanoid.PlatformStand then
						v913()
					end
				end, p257.baitHitConnections)

				local Packages = ReplicatedStorage2:FindFirstChild("Packages")
				local Networking = Packages and Packages:FindFirstChild("Networking")
				local RERigSyncRefresh = Networking and Networking:FindFirstChild("RE/RigSync/Refresh")

				if RERigSyncRefresh then
					pcall(function()
						v660(RERigSyncRefresh.OnClientEvent, v913, p257.baitHitConnections)
					end)
				end

				if p257.antiGuard then
					p257.antiGuard:setPrimerHitWindow(true)
				end

				p257.hitTimer = task.defer(function()
					local v917 = os.clock() + 1.2
					local n11 = 0
					local exitTo

					while true do
						if p257.baitWaitToken ~= baitWaitToken or not p257.waitingGuardHit or p257.destroyed or not p257.enabled or p257.instantPhase ~= "priming" then
							exitTo = 1

							break
						end

						if LocalPlayer2.Character ~= Character or not HumanoidRootPart.Parent or not Humanoid.Parent then
							exitTo = 2

							break
						end

						local state = Humanoid:GetState()

						if not u912 and not Humanoid.PlatformStand and not Humanoid.Sit and state ~= Enum.HumanoidStateType.Ragdoll and state ~= Enum.HumanoidStateType.FallingDown and not (HumanoidRootPart.AssemblyLinearVelocity.Magnitude > 18) then
							local now = os.clock()

							if not (v917 <= now) then
								if n11 <= now then
									n11 = now + 0.06
									p257:_triggerInstantForestHit(baitWaitToken)
								end

								RunService2.Heartbeat:Wait()

								continue
							end

							exitTo = 1

							break
						end

						break
					end

					if exitTo ~= 1 then
						if exitTo == 2 then
							p257:_kbCancelTimer()
							p257:_finish("Forest bait interrupted")

							return
						end

						p257:_startPrimerTargetHunt()

						return
					end

					if p257.baitWaitToken ~= baitWaitToken then
						return
					end

					p257:_kbCancelTimer()
					p257.lastAbandonedPrimerUid = primerUid
					p257.instantPhase = nil
					p257.primerUid = nil
					p257.targetUid = nil
					p257.carry.active = false
					p257.carry.uid = nil

					if LocalPlayer2.Character == Character and HumanoidRootPart.Parent and Humanoid.Parent then
						p257:_teleportRoot(HumanoidRootPart, Humanoid, p257:_resolveSafeCFrame(HumanoidRootPart))
					end

					p257:_finish("Forest guard hit timed out")
				end)

				return
			end
		end
	end
	t41._findPlayerStealBat = function()
		local Character = LocalPlayer2.Character
		local Backpack = LocalPlayer2:FindFirstChildOfClass("Backpack")

		local function v924(p260)
			local ipairs_ = ipairs
			local children = p260 and p260:GetChildren() or {}

			for _, child in ipairs_(children) do
				if child:IsA("Tool") and child:GetAttribute("IsBat") == true then
					return child
				end
			end

			return nil
		end

		return v924(Character) or v924(Backpack)
	end
	t41._ensurePlayerStealBat = function(p261, p262)
		local v929 = os.clock() + 2.5
		local n12 = 0

		while not p261.destroyed and p261.enabled and p261.playerHuntToken == p262 and os.clock() < v929 do
			local Character = LocalPlayer2.Character
			local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

			if not Character or not Humanoid or Humanoid.Health <= 0 then
				return nil
			end

			local v933 = p261:_findPlayerStealBat()

			if v933 then
				if v933.Parent ~= Character then
					pcall(Humanoid.EquipTool, Humanoid, v933)
				end

				if v933.Parent == Character then
					task.wait(0.08)

					if v933.Parent == Character then
						return v933
					end
				end
			end

			local now = os.clock()

			if n12 <= now then
				n12 = now + 0.45
				p261:_setStatus("Requesting Field Bat")
				pcall(function()
					Remotes.Codex.AskWearFieldBat:InvokeServer()
				end)
			end

			task.wait(0.05)
		end

		return nil
	end
	t41._activatePlayerStealBat = function(p263, p264, p265)
		if p264 and p265 then
			local Character = LocalPlayer2.Character
			local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

			if Character and Humanoid and not (Humanoid.Health <= 0 or p265.Parent ~= Character) then
				return pcall(p265.Activate, p265)
			end

			return false
		end

		return false
	end
	t41._startPlayerCarryHunt = function(p266, p267)
		local Uid = p267 and p267.Uid

		if type(Uid) ~= "string" or Uid == "" or p266.playerHuntToken then
			p266:_finish("Player target unavailable")

			return
		end

		local playerHuntToken = {}

		p266.playerHuntToken = playerHuntToken
		p266.instantPhase = "player_hunt"
		p266.activeTarget = p267
		p266.safeStarting = false
		p266.running = true
		p266:_hideTreadmillDecoy()
		task.spawn(function()
			p266:_setStatus("Equipping Field Bat")

			local v939 = p266:_ensurePlayerStealBat(playerHuntToken)

			if not v939 then
				if p266.playerHuntToken == playerHuntToken then
					p266.playerHuntToken = nil
					p266:_finish("Failed to equip Field Bat")
				end

				return
			end

			local function v940(p268)
				local v941 = EggState2.ReadFieldEgg(Uid) or p266.records[Uid]

				if v941 and v941.State == AreaEggs.States.Carried then
					local v942, v943 = p266:_resolveForeignCarrier(v941, p268)

					return v942, v943, v941
				end

				return nil
			end

			local v944, v945 = v940(false)

			if not v944 or not v945 then
				p266.playerHuntToken = nil
				p266:_finish("Player steal target lost")

				return
			end

			p266.playerHuntCarrier = v944

			if not p266:_installPlayerStealBatAura() then
				p266.playerHuntToken = nil
				p266.playerHuntCarrier = nil
				p266:_finish("Bat Aura unavailable")

				return
			end

			local vector33 = Vector3.zero
			local now = os.clock()

			local function v948()
				local _, v950 = v940(true)

				if not v950 then
					return nil
				end

				local now2 = os.clock()
				local v952 = math.clamp(now2 - now, 0, 0.1)

				now = now2

				local AssemblyLinearVelocity = v950.AssemblyLinearVelocity

				vector33 = vector33:Lerp(Vector3.new(AssemblyLinearVelocity.X, 0, AssemblyLinearVelocity.Z), 1 - math.exp(-12 * v952))

				local n13 = 0

				pcall(function()
					n13 = LocalPlayer2:GetNetworkPing()
				end)

				local v955 = vector33 * math.clamp(n13 + 0.18, 0.18, 0.35)

				if v955.Magnitude > 0.1 then
					v955 = v955.Unit * 0.1
				end

				local CFrame_2 = v950.CFrame

				return lookAt(CFrame_2:PointToWorldSpace(Vector3.new(0, 0, 0)) + v955, v950.Position + v955)
			end

			local v957 = v948()

			if not v957 then
				p266.playerHuntToken = nil
				p266:_finish("Player steal target lost")

				return
			end

			p266:_setStatus("Following egg carrier")
			p266:_tweenRoot(v957, nil, nil, {
				silent = true,
				continuous = true,
				dynamicDestination = v948,
				abort = function()
					return p266.playerHuntToken ~= playerHuntToken or not p266.config.stealFromPlayers or not p266:_wallOpen()
				end
			})

			local n14 = 0
			local n15 = 0
			local v960
			local v961 = os.clock() + 15
			local exitTo
			local v963

			while true do
				if p266.destroyed or not p266.enabled or p266.playerHuntToken ~= playerHuntToken then
					exitTo = 1

					break
				end

				local now2 = os.clock()

				if v961 <= now2 then
					exitTo = 1

					break
				end

				v963 = EggState2.ReadFieldEgg(Uid)
				v963 = v963 or p266.records[Uid]

				if not v963 then
					v960 = v960 or now2

					if not (now2 - v960 >= 0.45) then
						task.wait(0.03)

						continue
					end

					exitTo = 1

					break
				end

				v960 = nil

				if v963.State ~= AreaEggs.States.Dropped and v963.State ~= AreaEggs.States.Slot then
					if v963.State ~= AreaEggs.States.Carried or not p266:_matchesNormalFilter(v963) then
						exitTo = 1

						break
					end

					local v965 = now2 >= n15

					if v965 then
						n15 = now2 + 0.2
					end

					local v966, v967 = p266:_resolveForeignCarrier(v963, not v965)

					if not v966 or not v967 then
						exitTo = 1

						break
					end

					p266.playerHuntCarrier = v966

					local Character = LocalPlayer2.Character
					local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
					local v970, _setStatus, v972

					if HumanoidRootPart and v939.Parent == Character then
						if n14 <= now2 then
							n14 = now2 + 0.62
							v970 = p266
							_setStatus = p266._setStatus
							v972 = (HumanoidRootPart.Position - v967.Position).Magnitude <= 13 and "Striking egg carrier" or "Closing on egg carrier"
							_setStatus(v970, v972)
							p266:_activatePlayerStealBat(v966, v939)
						end

						task.wait(0.05)

						continue
					end

					v939 = p266:_ensurePlayerStealBat(playerHuntToken)

					if not v939 then
						exitTo = 1

						break
					end

					if n14 <= now2 then
						n14 = now2 + 0.62
						v970 = p266
						_setStatus = p266._setStatus
						v972 = (HumanoidRootPart.Position - v967.Position).Magnitude <= 13 and "Striking egg carrier" or "Closing on egg carrier"
						_setStatus(v970, v972)
						p266:_activatePlayerStealBat(v966, v939)
					end

					task.wait(0.05)

					continue
				end

				break
			end

			if exitTo == 1 then
				if p266.playerHuntToken == playerHuntToken then
					p266.playerHuntToken = nil
					p266.playerHuntCarrier = nil
					p266:_removePlayerStealBatAura()

					if p266.activeTween and p266.activeTween.Cancel then
						pcall(p266.activeTween.Cancel, p266.activeTween)
					end

					p266:_finish("Player steal target lost")
				end

				return
			end

			p266.playerHuntToken = nil
			p266.playerHuntCarrier = nil
			p266:_removePlayerStealBatAura()

			if p266.activeTween and p266.activeTween.Cancel then
				pcall(p266.activeTween.Cancel, p266.activeTween)
			end

			p266.instantPhase = "hunting"
			p266.activeTarget = v963

			local carry = p266.carry

			carry.generation += 1
			p266:_invalidateCarryWorker()
			p266:_reStealDroppedEgg(Uid)
		end)
	end
	t41._startPrimerTargetHunt = function(p269)
		if p269.instantPhase ~= "priming" then
			return
		end

		p269:_kbCancelTimer()
		p269:_setInstantAnchored(false)
		p269.instantPhase = "hunting"
		p269:_clearArrivalHold()
		p269.lastAbandonedPrimerUid = p269.primerUid
		p269.primerUid = nil

		local carry = p269.carry

		carry.generation += 1
		p269:_invalidateCarryWorker()
		p269.carry.active = false
		p269.carry.uid = nil

		local targetUid = p269.targetUid

		p269.targetUid = nil

		if not targetUid then
			p269:_finish("No target egg")

			return
		end

		local v976 = EggState2.ReadFieldEgg(targetUid) or p269.records[targetUid]

		if v976 and v976.State == AreaEggs.States.Carried and p269.isPremium and p269.config.stealFromPlayers then
			p269:_startPlayerCarryHunt(v976)

			return
		end

		if not v976 or v976.State ~= AreaEggs.States.Slot and v976.State ~= AreaEggs.States.Dropped then
			p269:_finish("Target egg no longer available")

			return
		end

		local Character = LocalPlayer2.Character
		local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
		local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

		if not HumanoidRootPart or not Humanoid then
			p269:_finish("Character unavailable")

			return
		end

		p269.activeTarget = v976

		local v980 = p269:_resolveEggDestination(v976, HumanoidRootPart, Humanoid)

		if not v980 then
			p269:_finish("Target destination unavailable")

			return
		end

		if p269.config.stealMode ~= "Instant" then
			p269:_setStatus("Traveling to target")
			p269:_tweenRoot(v980, function()
				if p269.instantPhase == "hunting" and p269.activeTarget and p269.activeTarget.Uid == v976.Uid then
					p269:_requestCarry(v976, true)
				end
			end, nil, {
				arrivalHoldSeconds = 0,
				holdAfterArrival = true,
				holdUid = v976.Uid,
				flightProfile = true,
				carryTarget = v976
			})

			return
		end

		p269:_setStatus("Teleporting to target")

		if not p269:_teleportRoot(HumanoidRootPart, Humanoid, v980) then
			p269:_finish("Teleport target failed")

			return
		end

		p269:_hideTreadmillDecoy()
		p269:_setArrivalHold(v980, v976.Uid)
		p269:_setStatus("Securing target egg")
		p269:_requestCarry(v976, true)
	end
	t41._wallOpen = function(p270)
		if not p270.resetBlocked and not AreaEggResetWall2.IsSealed() then
			if not (os.clock() < p270.gateOpenAt) then
				local Areas = workspace:FindFirstChild("__OBJECTS") and workspace.__OBJECTS:FindFirstChild("Areas")
				local WallStartCollision = Areas and Areas:FindFirstChild("WallStartCollision")

				if WallStartCollision and WallStartCollision:IsA("BasePart") and WallStartCollision.CanCollide then
					return false
				end

				return true
			end
		end

		return false
	end
	t41.isResetWallOpen = function(p271)
		return not p271.destroyed and p271:_wallOpen()
	end
	t41._closeGate = function(p272, p273)
		p272.resetBlocked = true

		if p272.drScrambleRuntime and type(p272.drScrambleRuntime.releaseEventLock) == "function" then
			p272.drScrambleRuntime:releaseEventLock()
		end

		p272:releaseDrScrambleRoute()
		p272.gateOpenAt = math.huge
		p272.continueFromForestGift = false

		if not p272.activeTween or not p272.activeTween.sharedTravel then
			p272:_cancelTween(p273)
		end

		p272:_setStatus(p273)
	end
	t41._releaseOperation = function(p274)
		local operationToken = p274.operationToken

		p274.operationToken = nil

		if operationToken and p274.coordinator then
			p274.coordinator:release(operationToken)
		end
	end
	t41._acquireOperation = function(p275)
		if p275.operationToken or not p275.coordinator then
			return true
		end

		local autoSteal, v985 = p275.coordinator:tryAcquire("auto_steal", {})

		if not autoSteal then
			return false, v985
		end

		p275.operationToken = autoSteal

		return true
	end
	t41._cancelTween = function(p276, p277, p278)
		if p277 ~= "Re-stealing dropped egg" then
			p276.dropRecoveryUid = nil
			p276.guardReturnWait = nil
		end

		p276:_cleanupInstantSteal()
		p276.safeStarting = false
		p276.carryAttemptToken = nil
		p276:_clearArrivalHold()

		if p276.activeTween then
			pcall(p276.activeTween.Cancel, p276.activeTween)
			p276.activeTween = nil
		end

		if not p276.activeTween and not p276.arrivalHold then
			p276:_stopHoverPad()
		end

		if p276.running then
			p276.running = false
			p276.activeTarget = nil
			p276.stats.lastResult = p277
			p276:_notify()
		end

		if not p278 then
			p276:_releaseOperation()
		end
	end
	t41._resolveForestBounds = function()
		local __OBJECTS = workspace:FindFirstChild("__OBJECTS")
		local Areas = __OBJECTS and __OBJECTS:FindFirstChild("Areas")
		local GuardAreas = Areas and Areas:FindFirstChild("GuardAreas")
		local Forest = GuardAreas and GuardAreas:FindFirstChild("Forest")
		local Bounds = Forest and Forest:FindFirstChild("Bounds")

		return Bounds and Bounds:IsA("BasePart") and Bounds or nil
	end
	t41._isInsideForest = function(p279, p280)
		local v991 = p279:_resolveForestBounds()

		if p280 and v991 then
			local v992 = v991.CFrame:PointToObjectSpace(p280.Position)
			local v993 = v991.Size * 0.5

			return math.abs(v992.X) <= v993.X and math.abs(v992.Z) <= v993.Z and v992.Y >= -6 and v992.Y <= 12
		end

		return false
	end
	t41._resolveForestDropCFrame = function(p281, p282)
		if not p282 then
			return nil
		end

		local v994 = p281:_resolveForestBounds()

		if not v994 then
			return nil
		end

		local v995 = v994.CFrame:PointToWorldSpace(Vector3.new(0, 4, 0))

		return cFrameNew(v995) * p282.CFrame.Rotation
	end
	t41._resolveSafeCFrame = function(p283, p284)
		if p284 then
			return cFrameNew(vector32) * p284.CFrame.Rotation
		end

		return nil
	end

	local function v996(p285)
		local v997 = p285.Size.X * 0.5
		local v998 = p285.Size.Z * 0.5
		local huge = math.huge
		local v1000 = -math.huge
		local huge2 = math.huge
		local v1002 = -math.huge

		for _, v in ipairs({
			Vector3.new(v997, 0, v998),
			Vector3.new(v997, 0, -v998),
			Vector3.new(-v997, 0, v998),
			Vector3.new(-v997, 0, -v998)
		}) do
			local v1005 = p285.CFrame:PointToWorldSpace(v)

			huge = math.min(huge, v1005.X)
			v1000 = math.max(v1000, v1005.X)
			huge2 = math.min(huge2, v1005.Z)
			v1002 = math.max(v1002, v1005.Z)
		end

		return huge, v1000, huge2, v1002
	end

	t41._snapshotZigzagWalls = function()
		local __OBJECTS = workspace:FindFirstChild("__OBJECTS")
		local Build = __OBJECTS and __OBJECTS:FindFirstChild("Build")
		local t44 = {}

		if not Build then
			return t44
		end

		local function v1009(p286)
			local v1010 = string.upper(p286.Name)

			if v1010 == "SIDE_WALLS" then
				return "high"
			end

			if v1010 == "SIDE_WALLS2" then
				return "low"
			end

			local Parent = p286

			while Parent and Parent ~= Build do
				local v1012 = string.upper(Parent.Name)

				if string.find(v1012, "WALL LEFT", 1, true) then
					return "low"
				end

				if string.find(v1012, "WALL RIGHT", 1, true) then
					return "high"
				end

				Parent = Parent.Parent
			end

			return nil
		end

		for _, descendant in ipairs(Build:GetDescendants()) do
			if descendant:IsA("BasePart") and descendant.CanCollide then
				local v1015 = v1009(descendant)

				if v1015 then
					local v1016, v1017, v1018, v1019 = v996(descendant)

					if v1017 - v1016 >= 100 then
						table.insert(t44, {
							side = v1015,
							minX = v1016,
							maxX = v1017,
							innerZ = v1015 == "low" and v1019 or v1018
						})
					end
				end
			end
		end

		return t44
	end
	t41._resolveZigzagBounds = function(p287, p288)
		local v1020 = -math.huge
		local huge = math.huge
		local v1022 = false
		local v1023 = false
		local ipairs_ = ipairs
		local zigzagWalls = p287.zigzagWalls

		zigzagWalls = zigzagWalls or {}

		for _, zigzagWall in ipairs_(zigzagWalls) do
			if zigzagWall.minX <= p288 and p288 <= zigzagWall.maxX then
				if zigzagWall.side == "low" and zigzagWall.innerZ < vector32.Z then
					v1020 = math.max(v1020, zigzagWall.innerZ)
					v1022 = true
				elseif zigzagWall.side == "high" and vector32.Z < zigzagWall.innerZ then
					huge = math.min(huge, zigzagWall.innerZ)
					v1023 = true
				end
			end
		end

		if not v1022 or not v1023 then
			return nil
		end

		local v1028 = v1020 + 18
		local v1029 = huge - 18

		if v1029 - v1028 < 48 then
			return nil
		end

		return v1028, v1029
	end
	t41._buildSafeZigzagWaypoints = function(p289, p290, p291)
		if p289.config.stealZigzag and p290 then
			if typeof(p291) == "CFrame" then
				local v1030 = p291.Position.X - p290.Position.X
				local v1031 = math.abs(v1030)

				if v1031 <= 30 then
					return {}
				end

				local v1032 = p289:_resolveRouteCruiseY(p290, p291)

				if not v1032 then
					return {}
				end

				local v1033 = math.max(1, math.floor(v1031 / 220))
				local t45 = {}
				local v1035 = p290.Position.Z <= vector32.Z

				for i = 1, v1033 do
					local v1037 = p290.Position.X + v1030 * (i / (v1033 + 1))
					local v1038, v1039 = p289:_resolveZigzagBounds(v1037)

					if not v1038 then
						return {}
					end

					table.insert(t45, cFrameNew(v1037, v1032, v1035 and v1039 or v1038))
					v1035 = not v1035
				end

				return t45
			end
		end

		return {}
	end

	local function v1040(p292)
		if typeof(p292) == "Instance" and p292:IsA("Trail") then
			pcall(p292.Destroy, p292)
		end
	end
	local function v1041(p293)
		if typeof(p293) == "Instance" and (p293.Name == "SpeedGainPopup" or p293.Name == "PlusOne") then
			pcall(p293.Destroy, p293)
		end
	end

	t41._showTreadmillDecoy = function(p294)
		if p294.treadmillDecoy and p294.treadmillDecoy.Parent then
			return true
		end

		p294:_hideTreadmillDecoy()

		local Character = LocalPlayer2.Character

		if not Character then
			return false
		end

		local Archivable = Character.Archivable

		Character.Archivable = true

		local ok, treadmillDecoy = pcall(Character.Clone, Character)

		Character.Archivable = Archivable

		if not ok or not treadmillDecoy or typeof(treadmillDecoy) ~= "Instance" then
			return false
		end

		treadmillDecoy.Name = "__FyyTreadmillDecoy"

		for _, descendant in ipairs(treadmillDecoy:GetDescendants()) do
			if t40[descendant.ClassName] or descendant:IsA("Trail") then
				pcall(descendant.Destroy, descendant)
			elseif descendant:IsA("BasePart") then
				descendant.LocalTransparencyModifier = 0
				descendant.Anchored = true
				descendant.CanCollide = false
				descendant.CanQuery = false
				descendant.CanTouch = false
			end
		end

		local HumanoidRootPart = treadmillDecoy:FindFirstChild("HumanoidRootPart")
		local Humanoid = treadmillDecoy:FindFirstChildOfClass("Humanoid")

		if HumanoidRootPart then
			if Humanoid then
				pcall(function()
					Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
					Humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
				end)
				treadmillDecoy.Parent = workspace
				treadmillDecoy:PivotTo(cFrameNew(vector32))
				p294.treadmillDecoy = treadmillDecoy

				local PlayerGui = LocalPlayer2:FindFirstChildOfClass("PlayerGui")

				if PlayerGui then
					for _, descendant in ipairs(PlayerGui:GetDescendants()) do
						if descendant.Name == "SpeedGainPopup" or descendant.Name == "PlusOne" then
							v1041(descendant)
						end
					end

					p294.treadmillPopupConnection = PlayerGui.DescendantAdded:Connect(function(descendant)
						if p294.treadmillDecoy == treadmillDecoy then
							v1041(descendant)
						end
					end)
				end

				local treadmillDecoyRealTransparency = setmetatable({}, {
					__mode = "k"
				})

				local function v1054(p295)
					if not p295 or not p295:IsA("BasePart") or not p295:IsDescendantOf(Character) then
						return
					end

					if treadmillDecoyRealTransparency[p295] == nil then
						treadmillDecoyRealTransparency[p295] = p295.LocalTransparencyModifier
					end

					p295.LocalTransparencyModifier = 1
				end

				for _, descendant in ipairs(Character:GetDescendants()) do
					v1054(descendant)
					v1040(descendant)
				end

				p294.treadmillDecoyRealTransparency = treadmillDecoyRealTransparency
				p294.treadmillDecoyCharacterConnection = Character.DescendantAdded:Connect(function(descendant)
					if p294.treadmillDecoy == treadmillDecoy then
						pcall(v1054, descendant)
						v1040(descendant)
					end
				end)

				local CurrentCamera = workspace.CurrentCamera

				if CurrentCamera then
					p294.treadmillDecoyCamera = CurrentCamera.CameraSubject
					CurrentCamera.CameraSubject = Humanoid
				end

				p294.treadmillDecoyCameraConnection = RunService2.RenderStepped:Connect(function()
					if p294.treadmillDecoy ~= treadmillDecoy or not treadmillDecoy.Parent or not Humanoid.Parent then
						return
					end

					for k in pairs(treadmillDecoyRealTransparency) do
						if k.Parent and k.LocalTransparencyModifier ~= 1 then
							k.LocalTransparencyModifier = 1
						end
					end

					local CurrentCamera2 = workspace.CurrentCamera

					if CurrentCamera2 and CurrentCamera2.CameraSubject ~= Humanoid then
						CurrentCamera2.CameraSubject = Humanoid
					end
				end)

				return true
			end
		end

		treadmillDecoy:Destroy()

		return false
	end
	t41._hideTreadmillDecoy = function(p296)
		if p296.treadmillDecoyCameraConnection then
			pcall(p296.treadmillDecoyCameraConnection.Disconnect, p296.treadmillDecoyCameraConnection)
			p296.treadmillDecoyCameraConnection = nil
		end

		if p296.treadmillDecoyCharacterConnection then
			pcall(p296.treadmillDecoyCharacterConnection.Disconnect, p296.treadmillDecoyCharacterConnection)
			p296.treadmillDecoyCharacterConnection = nil
		end

		if p296.treadmillPopupConnection then
			pcall(p296.treadmillPopupConnection.Disconnect, p296.treadmillPopupConnection)
			p296.treadmillPopupConnection = nil
		end

		local pairs_ = pairs
		local treadmillDecoyRealTransparency = p296.treadmillDecoyRealTransparency or {}

		for k, v in pairs_(treadmillDecoyRealTransparency) do
			if typeof(k) == "Instance" and k.Parent then
				pcall(function()
					k.LocalTransparencyModifier = v
				end)
			end
		end

		p296.treadmillDecoyRealTransparency = nil

		local Character = LocalPlayer2.Character
		local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
		local CurrentCamera = workspace.CurrentCamera

		if CurrentCamera then
			pcall(function()
				CurrentCamera.CameraSubject = Humanoid or p296.treadmillDecoyCamera
			end)
		end

		p296.treadmillDecoyCamera = nil

		if p296.treadmillDecoy then
			pcall(p296.treadmillDecoy.Destroy, p296.treadmillDecoy)
		end

		p296.treadmillDecoy = nil
	end
	t41._restoreTreadmillVisualAtSafe = function(p297)
		if not p297.treadmillDecoy then
			p297:_hideTreadmillDecoy()

			return true
		end

		local Character = LocalPlayer2.Character
		local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
		local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
		local v1070 = p297:_resolveSafeCFrame(HumanoidRootPart)

		if not HumanoidRootPart or not Humanoid or not v1070 then
			p297:_hideTreadmillDecoy()

			return false
		end

		local v1071 = os.clock() + 2
		local v1072
		local n16 = 0

		while not p297.destroyed and os.clock() < v1071 do
			local now = os.clock()

			if p297:_isInSafeArea(HumanoidRootPart) then
				v1072 = v1072 or now

				if now - v1072 >= 0.35 then
					p297:_hideTreadmillDecoy()

					return true
				end
			else
				v1072 = nil

				if n16 <= now then
					n16 = now + 0.1
					p297:_teleportRoot(HumanoidRootPart, Humanoid, v1070)
				end
			end

			task.wait(0.03)
		end

		p297:_hideTreadmillDecoy()

		return false
	end
	t41._findAreaGuardRoot = function(p298, p299)
		if type(p299) == "string" then
			if p299 ~= "" then
				local __OBJECTS = workspace:FindFirstChild("__OBJECTS")
				local Areas = __OBJECTS and __OBJECTS:FindFirstChild("Areas")
				local GuardAreas = Areas and Areas:FindFirstChild("GuardAreas")
				local v1078 = GuardAreas and GuardAreas:FindFirstChild(p299) or Areas and Areas:FindFirstChild(p299)

				if not v1078 then
					return nil
				end

				local Guard = v1078:FindFirstChild("Guard") or v1078:FindFirstChild(p299 .. "GuardAuthored") or v1078:FindFirstChild("ForestGuardAuthored") or v1078:FindFirstChildWhichIsA("Model")

				return Guard and (Guard:FindFirstChild("HumanoidRootPart") or Guard:FindFirstChild("Collider") or Guard:IsA("Model") and Guard.PrimaryPart or Guard:FindFirstChildWhichIsA("BasePart"))
			end
		end

		return nil
	end
	t41._resolveEggDestination = function(p300, p301, p302, p303)
		if type(p301) ~= "table" or typeof(p301.BottomCFrame) ~= "CFrame" then
			return nil
		end

		local Character = LocalPlayer2.Character
		local HumanoidRootPart = p302 or Character and Character:FindFirstChild("HumanoidRootPart")
		local Humanoid = p303 or Character and Character:FindFirstChildOfClass("Humanoid")

		if not HumanoidRootPart or not Humanoid then
			return nil
		end

		local v1083 = p301.BottomCFrame.Position + Vector3.new(0, p300:_feetOffset(HumanoidRootPart, Humanoid) + 0.15, 0)
		local v1084 = p300:_findAreaGuardRoot(p301.AreaId)

		if v1084 then
			local Position = v1084.Position
			local vector33 = Vector3.new(Position.X - v1083.X, 0, Position.Z - v1083.Z)

			if vector33.Magnitude > 0.2 then
				return lookAt(v1083, v1083 + vector33.Unit)
			end
		end

		return cFrameNew(v1083)
	end
	t41._resolveRouteCruiseY = function(p304, p305, p306)
		if p305 and typeof(p306) == "CFrame" then
			return math.max(p305.Position.Y, p306.Position.Y + 50, vector32.Y + 50)
		end

		return nil
	end
	t41._resolveElevatedDestination = function(p307, p308, p309)
		local v1087 = p307:_resolveRouteCruiseY(p308, p309)

		if v1087 then
			return cFrameNew(p309.Position.X, v1087, p309.Position.Z) * p309.Rotation
		end

		return nil
	end
	t41._teleportRoot = function(p310, p311, p312, p313)
		if p311 and p312 then
			if typeof(p313) == "CFrame" then
				if not pcall(function()
					p311.AssemblyLinearVelocity = Vector3.zero
					p311.AssemblyAngularVelocity = Vector3.zero
					p311.CFrame = p313
					p311.AssemblyLinearVelocity = Vector3.zero
					p311.AssemblyAngularVelocity = Vector3.zero
				end) then
					return false
				end

				local v1088 = math.clamp(p310.config.speed or 800, 200, 1200)

				v699(LocalPlayer2.Character, v1088 * 1.35)

				if not v758(p312, p311, v1088, Vector3.zero) then
					v754(p312, p311, v1088)
					v758(p312, p311, v1088, Vector3.zero)
				end

				return true
			end
		end

		return false
	end
	t41._isInSafeArea = function(p314, p315)
		if not p315 then
			return false
		end

		local v1089 = p315.Position - vector32

		return Vector2.new(v1089.X, v1089.Z).Magnitude <= 30 and math.abs(v1089.Y) <= 18
	end
	t41._isInField = function(p316, p317)
		local __OBJECTS = workspace:FindFirstChild("__OBJECTS")
		local Areas = __OBJECTS and __OBJECTS:FindFirstChild("Areas")
		local WallStartCollision = Areas and Areas:FindFirstChild("WallStartCollision")

		if WallStartCollision and WallStartCollision:IsA("BasePart") then
			return p317.Position.X >= WallStartCollision.Position.X + 3
		end

		return true
	end
	t41._invalidateCarryWorker = function(p318)
		p318.carryWorker = nil
	end
	t41._claimCarryWorker = function(p319, p320, p321)
		local generation = p319.carry.generation
		local carryWorker = p319.carryWorker

		if carryWorker and carryWorker.generation == generation then
			return nil
		end

		local carryWorker2 = {
			kind = p320,
			uid = p321,
			generation = generation,
			token = {}
		}

		p319.carryWorker = carryWorker2

		return carryWorker2
	end
	t41._isCarryWorkerCurrent = function(p322, p323)
		return type(p323) == "table" and p322.carryWorker == p323 and p322.carry.generation == p323.generation and not p322.destroyed and p322.enabled
	end
	t41._releaseCarryWorker = function(p324, p325)
		if p324.carryWorker == p325 then
			p324.carryWorker = nil
		end
	end
	t41.ownsCarryRecovery = function(p326, p327)
		if not p326.destroyed then
			if p326.enabled then
				if p326.carry.uid == p327 then
					return true
				end

				return p326.running and p326.activeTarget ~= nil and (p327 == nil or p326.activeTarget.Uid == p327)
			end
		end

		return false
	end
	t41.requestCarryRecovery = function(p328, p329)
		if not p328.destroyed then
			if p328.enabled and type(p329) == "string" and p329 ~= "" then
				if p328:isPrimerEgg(p329) or p328:isIntentionalGiftDrop(p329) then
					return false
				end

				if p328:_isDropRecoveryPending(p329) and (p328.guardReturnWait or p328.carryWorker or p328.carryAttemptToken) then
					return true
				end

				if p328.tweenRecoveryUid == p329 then
					p328:_scheduleMovementRetry()

					return true
				end

				if p328.carry.active and p328.carry.uid == p329 then
					return true
				end

				local v1096 = EggState2.ReadFieldEgg(p329) or p328.records[p329]

				if type(v1096) ~= "table" or v1096.State ~= AreaEggs.States.Dropped and v1096.State ~= AreaEggs.States.Slot and v1096.State ~= AreaEggs.States.GuardCarried then
					return false
				end

				local carryWorker = p328.carryWorker

				if carryWorker and carryWorker.kind == "re-steal" and carryWorker.uid == p329 or p328.activeTween and p328.activeTarget and p328.activeTarget.Uid == p329 or p328.carryAttemptToken and p328.activeTarget and p328.activeTarget.Uid == p329 then
					return true
				end

				p328.dropRecoveryUid = p329

				local carry = p328.carry

				carry.generation += 1
				p328:_invalidateCarryWorker()
				p328.carryAttemptToken = nil
				p328.running = true
				p328.activeTarget = v1096
				task.defer(function()
					if not p328.destroyed then
						if p328.enabled and not p328.carry.active then
							p328:_reStealDroppedEgg(p329)
						end
					end
				end)

				return true
			end
		end

		return false
	end
	t41._hasConfirmedCarry = function(p330, p331)
		if not p330.carry.active then
			return false
		end

		if p331 == nil or p330.carry.uid == nil then
			return true
		end

		return p330.carry.uid == p331
	end
	t41._recordShowsForeignCarry = function(p332, p333)
		if type(p333) ~= "string" or p333 == "" then
			return false
		end

		local v1099 = EggState2.ReadFieldEgg(p333) or p332.records[p333]

		return type(v1099) == "table" and v1099.State == AreaEggs.States.Carried and v1099.CarrierUserId ~= nil and v1099.CarrierUserId ~= LocalPlayer2.UserId
	end
	t41._resolveMovementSpeed = function(p334, p335)
		if p335.Parent and not (p335.Health <= 0) then
			return math.clamp(p334.config.speed, 200, 1200)
		end

		return nil
	end
	t41._feetOffset = function(p336, p337, p338)
		if p338.RigType == Enum.HumanoidRigType.R15 then
			return p337.Size.Y * 0.5 + math.max(p338.HipHeight, 0.5)
		end

		return p337.Size.Y * 0.5 + 2
	end
	t41._syncHoverPad = function(p339, p340)
		local hoverPad = p339.hoverPad

		if hoverPad then
			if hoverPad.Parent and hoverPad:GetAttribute("FyyStealRuntimeOwner") == p339.hoverPadOwnerId then
				local Character = LocalPlayer2.Character
				local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
				local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

				if not HumanoidRootPart or not Humanoid then
					return false
				end

				local Position = typeof(p340) == "Vector3" and p340 or HumanoidRootPart.Position

				hoverPad.CFrame = cFrameNew(Position.X, Position.Y - p339:_feetOffset(HumanoidRootPart, Humanoid) - 0.5 - 0.05, Position.Z)

				return true
			end
		end

		return false
	end
	t41._setArrivalHold = function(p341, p342, p343)
		if typeof(p342) ~= "CFrame" then
			return
		end

		local Character = LocalPlayer2.Character
		local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")

		if not Character or not HumanoidRootPart then
			return
		end

		p341.arrivalHold = {
			Character = Character,
			RootPart = HumanoidRootPart,
			CFrame = p342,
			Uid = p343
		}
	end
	t41._clearArrivalHold = function(p344, p345)
		local arrivalHold = p344.arrivalHold

		if arrivalHold then
			if p345 == nil or arrivalHold.Uid == nil or arrivalHold.Uid == p345 then
				p344.arrivalHold = nil
			end
		else
			p344.arrivalHold = nil

			return
		end
	end
	t41._enforceArrivalHold = function(p346)
		local arrivalHold = p346.arrivalHold

		if type(arrivalHold) ~= "table" or typeof(arrivalHold.CFrame) ~= "CFrame" then
			return false
		end

		if LocalPlayer2.Character ~= arrivalHold.Character or not arrivalHold.RootPart or not arrivalHold.RootPart.Parent then
			p346.arrivalHold = nil

			return false
		end

		p346:_startHoverPad()
		pcall(function()
			arrivalHold.RootPart.AssemblyLinearVelocity = Vector3.zero
			arrivalHold.RootPart.AssemblyAngularVelocity = Vector3.zero
			p346:_syncHoverPad(arrivalHold.CFrame.Position)
			arrivalHold.RootPart.CFrame = arrivalHold.CFrame
		end)
		p346:_syncHoverPad(arrivalHold.CFrame.Position)

		return true
	end
	t41._purgeOrphanHoverPads = function(p347)
		for _, child in ipairs(workspace:GetChildren()) do
			if child.Name == "__FyyHoverPad" and child ~= p347.hoverPad then
				pcall(child.Destroy, child)
			end
		end
	end
	t41._startHoverPad = function(p348)
		local hoverPad = p348.hoverPad

		if not hoverPad or not hoverPad.Parent or hoverPad:GetAttribute("FyyStealRuntimeOwner") ~= p348.hoverPadOwnerId then
			p348:_purgeOrphanHoverPads()

			if hoverPad and hoverPad.Parent then
				pcall(hoverPad.Destroy, hoverPad)
			end

			local Part = Instance.new("Part")

			Part.Name = "__FyyHoverPad"
			Part:SetAttribute("FyyStealRuntimeOwner", p348.hoverPadOwnerId)
			Part.Anchored = true
			Part.CanCollide = true
			Part.CanQuery = true
			Part.CanTouch = false
			Part.CastShadow = false
			Part.Transparency = 1
			Part.Material = Enum.Material.SmoothPlastic
			Part.Size = Vector3.new(8, 1, 8)
			p348.hoverPad = Part
			Part.Parent = workspace
		end

		p348:_syncHoverPad()

		if not p348.hoverPadConnection then
			p348.hoverPadConnection = RunService2.PreSimulation:Connect(function()
				if not p348:_syncHoverPad() then
					p348:_startHoverPad()
				end
			end)
		end

		if not p348.hoverPadPostConnection then
			p348.hoverPadPostConnection = RunService2.PostSimulation:Connect(function()
				if p348.activeTween then
					p348:_syncHoverPad()

					return
				elseif p348.arrivalHold then
					p348:_syncHoverPad()
				end
			end)
		end
	end
	t41._stopHoverPad = function(p349)
		if p349.hoverPadConnection then
			pcall(p349.hoverPadConnection.Disconnect, p349.hoverPadConnection)
			p349.hoverPadConnection = nil
		end

		if p349.hoverPadPostConnection then
			pcall(p349.hoverPadPostConnection.Disconnect, p349.hoverPadPostConnection)
			p349.hoverPadPostConnection = nil
		end

		if p349.hoverPad then
			pcall(p349.hoverPad.Destroy, p349.hoverPad)
			p349.hoverPad = nil
		end

		p349:_purgeOrphanHoverPads()
	end
	t41._startMovementProtection = function(p350)
		local Character = LocalPlayer2.Character
		local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
		local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

		if not Character or not HumanoidRootPart or not Humanoid then
			return false
		end

		local v1116 = math.clamp(p350.config.speed or 800, 200, 1200)

		p350.protectionCharacter = Character
		p350.protectionHumanoid = Humanoid
		p350.protectionRoot = HumanoidRootPart
		v699(Character, v1116 * 1.35)
		v754(Humanoid, HumanoidRootPart, v1116)

		if not p350.integritySpoofConnection then
			p350.integritySpoofConnection = RunService2.PreSimulation:Connect(function()
				local Character2 = LocalPlayer2.Character
				local HumanoidRootPart2 = Character2 and Character2:FindFirstChild("HumanoidRootPart")
				local Humanoid2 = Character2 and Character2:FindFirstChildOfClass("Humanoid")

				if not Character2 or not HumanoidRootPart2 or not Humanoid2 then
					return
				end

				local v1120 = math.clamp(p350.config.speed or 800, 200, 1200)

				p350.protectionCharacter = Character2
				p350.protectionHumanoid = Humanoid2
				p350.protectionRoot = HumanoidRootPart2
				v699(Character2, v1120 * 1.35)

				if not v758(Humanoid2, HumanoidRootPart2, v1120) then
					v754(Humanoid2, HumanoidRootPart2, v1120)
				end

				p350:_enforceArrivalHold()
			end)
		end

		if not p350.arrivalHoldConnection then
			p350.arrivalHoldConnection = RunService2.Heartbeat:Connect(function()
				p350:_enforceArrivalHold()
			end)
		end

		return true
	end
	t41._stopMovementProtection = function(p351)
		if p351.integritySpoofConnection then
			pcall(p351.integritySpoofConnection.Disconnect, p351.integritySpoofConnection)
			p351.integritySpoofConnection = nil
		end

		if p351.arrivalHoldConnection then
			pcall(p351.arrivalHoldConnection.Disconnect, p351.arrivalHoldConnection)
			p351.arrivalHoldConnection = nil
		end

		p351:_clearArrivalHold()
		p351:_stopHoverPad()
		v703()
		v760(p351.protectionHumanoid)
		p351.protectionCharacter = nil
		p351.protectionHumanoid = nil
		p351.protectionRoot = nil
	end
	t41.travelAndWait = function(p352, p353, p354)
		local v1121 = p354 or {}

		if not p352.destroyed then
			if not p352.travelBusy then
				if p352.activeTween and not p352.activeTween.sharedTravel and not p352.running then
					pcall(p352.activeTween.Cancel, p352.activeTween)
				end

				if p352.activeTween then
					return false
				end

				local Character = LocalPlayer2.Character
				local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")

				if not HumanoidRootPart then
					return false
				end

				p352.travelBusy = true

				local u1124
				local now = os.clock()
				local v1126 = now
				local Magnitude = (p353.Position - HumanoidRootPart.Position).Magnitude
				local v1128 = now + Magnitude / math.max(tonumber(v1121.speed) or p352.config.speed or 800, 200) + 6

				p352:_tweenRoot(p353, nil, v1121.speed, {
					silent = true,
					sharedTravel = true,
					keepHoverPad = v1121.keepHoverPad == true,
					arrivalHoldSeconds = v1121.arrivalHoldSeconds,
					abort = function()
						return p352.destroyed or v1121.abort ~= nil and v1121.abort()
					end,
					onDone = function(p355)
						u1124 = p355 == true
					end
				})

				while u1124 == nil do
					local now2 = os.clock()
					local HumanoidRootPart2 = LocalPlayer2.Character and LocalPlayer2.Character:FindFirstChild("HumanoidRootPart")
					local Magnitude2 = HumanoidRootPart2 and (p353.Position - HumanoidRootPart2.Position).Magnitude or math.huge

					if Magnitude2 < Magnitude - 0.5 then
						Magnitude = Magnitude2
						v1126 = now2
					end

					if p352.destroyed or v1121.abort ~= nil and v1121.abort() or now2 - v1126 >= 1.5 or v1128 <= now2 then
						if p352.activeTween and p352.activeTween.Cancel then
							pcall(p352.activeTween.Cancel)
						end

						u1124 = false

						break
					else
						task.wait(0.05)
					end
				end

				p352.travelBusy = false

				return u1124
			end
		end

		return false
	end

	local function v1132(p356, p357)
		local u1133
		local u1134 = false
		local u1135 = false
		local u1136 = false

		return {
			setMoving = function(p358, p359)
				if u1135 then
					return
				end

				if not p359 then
					if u1133 and u1136 then
						pcall(u1133.Stop, u1133, 0.12)
					end

					u1136 = false

					return
				end

				if not u1134 then
					u1134 = true

					local ok, result = pcall(function()
						local Animate = p356:FindFirstChild("Animate")
						local Animator = p357:FindFirstChildOfClass("Animator")

						if not Animate or not Animator then
							return
						end

						local v1141

						for _, v in ipairs({
							"run",
							"walk"
						}) do
							local v1144 = Animate:FindFirstChild(v)
							local descendants = v1144 and v1144:GetDescendants() or {}

							if v1144 then
								table.insert(descendants, 1, v1144)
							end

							for _, descendant in ipairs(descendants) do
								if descendant:IsA("Animation") and descendant.AnimationId ~= "" then
									v1141 = descendant

									break
								end
							end

							if v1141 then
								break
							end
						end

						if not v1141 then
							return
						end

						u1133 = Animator:LoadAnimation(v1141)
						u1133.Looped = true
						u1133.Priority = Enum.AnimationPriority.Movement
					end)

					if not ok then
						warn("[SAE] Travel run animation unavailable: " .. tostring(result))
					end
				end

				if u1133 and not u1136 then
					u1136 = pcall(u1133.Play, u1133, 0.12, 1, 3)
				end
			end,
			destroy = function()
				if u1135 then
					return
				end

				u1135 = true

				if u1133 then
					pcall(u1133.Stop, u1133, 0)
					pcall(u1133.Destroy, u1133)
					u1133 = nil
				end

				u1136 = false
			end
		}
	end

	t41._tweenRoot = function(p360, p361, p362, p363, p364)
		p360:_clearArrivalHold()

		local Character = LocalPlayer2.Character
		local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
		local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
		local v1151 = p364 or {}

		if not HumanoidRootPart or not Humanoid then
			p360.safeStarting = false

			if v1151.silent then
				if v1151.onDone then
					pcall(v1151.onDone, false)
				end

				return
			end

			p360:_finish("Character unavailable")

			return
		end

		local v1152 = p363 or p360:_resolveMovementSpeed(Humanoid)

		if not v1152 then
			p360.safeStarting = false

			if v1151.silent then
				if v1151.onDone then
					pcall(v1151.onDone, false)
				end

				return
			end

			p360:_finish("Movement unavailable")

			return
		end

		local v1153 = math.clamp(v1152, 200, 1200)

		p360:_startMovementProtection()
		pcall(v682, Character)

		local CurrentCamera = workspace.CurrentCamera

		if CurrentCamera and CurrentCamera.CameraSubject ~= Humanoid then
			pcall(function()
				CurrentCamera.CameraSubject = Humanoid
			end)
		end

		local AutoRotate = Humanoid.AutoRotate

		Humanoid.AutoRotate = false

		local v1156 = p361
		local v1157 = v1151.flightProfile == true and p360:_resolveRouteCruiseY(HumanoidRootPart, p361) or nil

		if v1157 then
			p361 = cFrameNew(p361.Position.X, v1157, p361.Position.Z) * p361.Rotation
		end

		local v1158 = type(v1151.pathWaypoints) == "table" and table.clone(v1151.pathWaypoints) or nil
		local n17 = 1
		local activeTween = {
			sharedTravel = v1151.sharedTravel == true,
			routeCruiseY = v1157,
			travelPhase = v1157 and "takeoff" or nil
		}

		p360.activeTween = activeTween

		if v1151.groundedProfile then
			p360:_stopHoverPad()
		else
			p360:_startHoverPad()
		end

		local v1161 = v1132(Character, Humanoid)
		local u1162 = false
		local connection4
		local now
		local v1165 = math.max(tonumber(v1151.arrivalHoldSeconds) or 0.4, 0)
		local u1166
		local n18 = 0
		local CFrame_2
		local u1169
		local travelPhase
		local n19 = 0
		local n20 = 0
		local Position
		local n21 = 0.016666666666666666

		local function v1175()
			CFrame_2 = nil
			u1169 = nil
			travelPhase = nil
			n19 = 0
			n20 = 0
			Position = nil
		end
		local function v1176(p365)
			if u1162 then
				return
			end

			u1162 = true
			now = nil
			v1161:destroy()

			if Humanoid.Parent ~= nil then
				Humanoid.AutoRotate = AutoRotate
			end

			if p365 and v1151.holdAfterArrival then
				local v1177 = p361

				if LocalPlayer2.Character == Character and HumanoidRootPart.Parent then
					v1177 = cFrameNew(v1177.Position) * HumanoidRootPart.CFrame.Rotation
				end

				p360:_setArrivalHold(v1177, v1151.holdUid)
			end

			if v1151.onDone then
				pcall(v1151.onDone, p365 == true)
			end

			if connection4 then
				connection4:Disconnect()
				connection4 = nil
			end

			if p360.activeTween == activeTween then
				p360.activeTween = nil
			end

			if not p360.arrivalHold and not v1151.keepHoverPad then
				p360:_stopHoverPad()
			end

			if not p360.enabled then
				p360:_stopMovementProtection()
			end

			pcall(function()
				if LocalPlayer2.Character == Character and HumanoidRootPart.Parent then
					HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
				end
			end)

			if p365 and LocalPlayer2.Character == Character and Humanoid.Parent ~= nil and p362 then
				p362()
			end
		end

		activeTween.Cancel = function()
			v1176(false)
		end
		connection4 = RunService2.Heartbeat:Connect(function(dt)
			if v1151.abort and v1151.abort() then
				v1176(false)

				return
			end

			if not p360.destroyed and p360.activeTween == activeTween and LocalPlayer2.Character == Character and HumanoidRootPart.Parent and Humanoid.Parent then
				if not pcall(function()
					if v1151.dynamicDestination then
						local ok, result = pcall(v1151.dynamicDestination)

						if not ok or typeof(result) ~= "CFrame" then
							v1176(false)

							return
						end

						p361 = result
					end

					if p360.activeTween ~= activeTween then
						return
					end

					local v1180 = math.clamp(p363 or p360.config.speed or v1153, 200, 1200)

					v699(Character, v1180 * 1.35)

					local __FyyStealAnEggIntegritySpoof = v694().__FyyStealAnEggIntegritySpoof
					local State = type(__FyyStealAnEggIntegritySpoof) == "table" and __FyyStealAnEggIntegritySpoof.State or nil

					if not v753(State, Humanoid, HumanoidRootPart) then
						v1161:setMoving(false)
						u1166 = nil
						now = nil
						v1175()
						HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
						HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero

						if not v1151.groundedProfile then
							p360:_syncHoverPad(HumanoidRootPart.Position)
						end

						if v752(State, Humanoid, HumanoidRootPart) then
							v729(State, v1180 * 1.35, Vector3.zero)
						else
							v754(Humanoid, HumanoidRootPart, v1180)
						end

						return
					end

					local Position2 = HumanoidRootPart.Position

					n21 += (math.max(dt, 0.001) - n21) * 0.1

					local v1184 = math.max(0, math.min(dt, 0.05, 2 * n21))
					local v1185 = os.clock() < n18 and math.max(200, v1180 * 0.45) or v1180
					local v1186 = v1185 * v1184

					if v1151.groundedProfile and v1151.projectGroundPosition then
						local v1187 = v1151.projectGroundPosition(p361.Position)

						if typeof(v1187) ~= "Vector3" then
							v1176(false)

							return
						end

						p361 = cFrameNew(v1187) * p361.Rotation
					end

					local v1188 = p361.Position - Position2
					local Magnitude = v1188.Magnitude
					local vector33 = Vector3.new(v1188.X, 0, v1188.Z)
					local Magnitude2 = vector33.Magnitude
					local Position3 = p361.Position

					if activeTween.routeCruiseY then
						if activeTween.travelPhase == "takeoff" and activeTween.routeCruiseY - Position2.Y <= math.max(v1186, 1.5) then
							activeTween.travelPhase = "cruise"
						end

						if activeTween.travelPhase == "takeoff" then
							Position3 = Vector3.new(Position2.X, activeTween.routeCruiseY, Position2.Z)
						else
							Position3 = p361.Position
						end
					end

					local Magnitude3 = (Position3 - Position2).Magnitude
					local routeCruiseY = activeTween.routeCruiseY and Magnitude2 or Magnitude

					if u1166 and u1166 + 2 < routeCruiseY then
						n18 = os.clock() + 0.5
					end

					u1166 = routeCruiseY

					local v1195 = vector33
					local vector34 = Vector3.new(HumanoidRootPart.CFrame.LookVector.X, 0, HumanoidRootPart.CFrame.LookVector.Z)
					local Unit = v1195.Magnitude > 0.001 and v1195.Unit or vector34.Magnitude > 0.001 and vector34.Unit or Vector3.new(0, 0, -1)
					local cFrame = lookAt(Position3, Position3 + Unit)
					local v1199 = Position and (Position2 - Position).Magnitude > 2

					if not CFrame_2 or travelPhase ~= activeTween.travelPhase or v1199 or (u1169.Position - Position3).Magnitude > 0.05 then
						CFrame_2 = HumanoidRootPart.CFrame
						u1169 = cFrame
						travelPhase = activeTween.travelPhase
						n19 = (u1169.Position - CFrame_2.Position).Magnitude
						n20 = 0

						if v1199 then
							now = nil
							n18 = os.clock() + 0.5
						end
					end

					local v1200 = math.min(v1185 * 0.22, n19 * 0.35)
					local n22 = 1

					if v1200 > 0 then
						local v1202 = v1158 and n17 <= #v1158
						local v1203 = activeTween.travelPhase == "landing"

						n22 = math.clamp(math.min((v1151.dynamicDestination or v1158 or v1203) and 1 or n20 / v1200, (v1202 or v1203) and 1 or (n19 - n20) / v1200), 0, 1)
					end

					local v1204 = v1185 * (0.18 + 0.82000000000000006 * math.sin(n22 * 3.1415926535897931 / 2)) * v1184

					if v1151.carryTarget and not activeTween.__earlyCarrySpam and Magnitude <= 30 then
						activeTween.__earlyCarrySpam = true

						local carryTarget = v1151.carryTarget
						local Uid = carryTarget.Uid
						local v1207 = AreaEggSlotIdentity.LooksLikeFirstAreaUid(Uid) and AreaEggSlotIdentity.SlotKey(carryTarget.AreaId, carryTarget.NestId) or nil

						task.spawn(function()
							while not p360.destroyed and p360.enabled and not (p360.activeTween ~= activeTween or p360:_hasConfirmedCarry(Uid)) do
								pcall(v652, Uid, v1207, true)
								task.wait(0.03)
							end
						end)
					end

					local v1208 = not activeTween.routeCruiseY or activeTween.travelPhase == "cruise"
					local v1209 = Magnitude

					if not v1208 or not (v1209 <= math.max(v1204, 0.05)) then
						now = nil

						if not (Magnitude3 <= 0.001) then
							if not v1151.groundedProfile and (not p360.hoverPad or not p360.hoverPad.Parent) then
								p360:_startHoverPad()
							end

							n20 = math.min(n19, n20 + v1204)

							local Position4 = CFrame_2:Lerp(u1169, n19 > 0.001 and n20 / n19 or 1).Position

							if v1151.groundedProfile and v1151.projectGroundPosition then
								local v1211 = v1151.projectGroundPosition(Position4)

								if typeof(v1211) ~= "Vector3" then
									v1176(false)

									return
								end

								Position4 = v1211
							else
								p360:_syncHoverPad(Position4)
							end

							HumanoidRootPart.CFrame = lookAt(Position4, Position4 + Unit)
							v1161:setMoving((Position4 - Position2).Magnitude > 0.001)
							Position = HumanoidRootPart.Position
							HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
							HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero

							if not v1151.groundedProfile then
								p360:_syncHoverPad(Position4)
							end

							if not v758(Humanoid, HumanoidRootPart, v1180, Vector3.zero) then
								v754(Humanoid, HumanoidRootPart, v1180)
								v758(Humanoid, HumanoidRootPart, v1180, Vector3.zero)
							end

							return
						end

						v1161:setMoving(false)
						HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
						HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero

						if not v1151.groundedProfile then
							p360:_syncHoverPad(Position2)
						end

						return
					end

					local Position4 = p361.Position

					if not v1151.groundedProfile then
						p360:_syncHoverPad(Position4)
					end

					HumanoidRootPart.CFrame = lookAt(Position4, Position4 + Unit)
					Position = HumanoidRootPart.Position
					HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
					HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero

					if not v1151.groundedProfile then
						p360:_syncHoverPad(Position4)
					end

					v758(Humanoid, HumanoidRootPart, v1180, Vector3.zero)

					local v1213 = v1158 and v1158[n17]

					if typeof(v1213) == "CFrame" then
						n17 += 1
						p361 = v1213
						activeTween.routeCruiseY = nil
						activeTween.travelPhase = nil
						u1166 = nil
						now = nil
						v1175()
						v1161:setMoving(true)

						return
					end

					if activeTween.routeCruiseY then
						p361 = v1156
						activeTween.routeCruiseY = nil
						activeTween.travelPhase = "landing"
						v1175()
						now = nil
						u1166 = nil

						return
					end

					v1161:setMoving(false)

					if v1209 > 0.5 then
						now = nil
					end

					if v1151.continuous then
						now = nil

						return
					end

					now = now or os.clock()

					if v1165 <= os.clock() - now then
						v1176(true)
					end
				end) then
					v1176(false)
				end

				return
			end

			v1176(false)
		end)
	end
	t41._isDropRecoveryPending = function(p366, p367)
		local v1214 = p367 ~= nil and p366.dropRecoveryUid == p367 and p366.running and p366.enabled and not p366.destroyed

		return v1214 and p366.activeTarget ~= nil and p366.activeTarget.Uid == p367
	end
	t41._waitForGuardReturn = function(p368, p369, p370)
		local Character = LocalPlayer2.Character
		local guardReturnWait = p368.guardReturnWait

		if not guardReturnWait or guardReturnWait.uid ~= p369 then
			guardReturnWait = {
				uid = p369,
				deadline = os.clock() + 15,
				character = Character
			}
			p368.guardReturnWait = guardReturnWait
		end

		p368.dropRecoveryUid = p369
		p368:_clearArrivalHold(p369)

		if p368.activeTween then
			pcall(p368.activeTween.Cancel, p368.activeTween)
		end

		local function v1217(p371, p372)
			if p368.guardReturnWait == guardReturnWait then
				p368.guardReturnWait = nil
			end

			return p371, p372
		end

		while p370() and p368.guardReturnWait == guardReturnWait do
			if LocalPlayer2.Character ~= guardReturnWait.character or not Character or not Character:FindFirstChild("HumanoidRootPart") then
				return v1217(nil, "Character unavailable")
			end

			if not p368:_wallOpen() then
				return v1217(nil, "Wall closed during guard return")
			end

			if p368:isPrimerEgg(p369) or p368:isIntentionalGiftDrop(p369) then
				return v1217(nil, "Egg excluded from recovery")
			end

			local v1218 = EggState2.ReadFieldEgg(p369) or p368.records[p369]

			if v1218 then
				if v1218.State == AreaEggs.States.Claimed then
					return v1217(nil, "Egg already claimed")
				end

				if v1218.State == AreaEggs.States.Carried and v1218.CarrierUserId and v1218.CarrierUserId ~= LocalPlayer2.UserId then
					return v1217(nil, "Egg carried by another player")
				end

				if v1218.State == AreaEggs.States.GuardCarried then
					guardReturnWait.guardSeen = true
				elseif not (v1218.State ~= AreaEggs.States.Slot and (v1218.State ~= AreaEggs.States.Dropped or guardReturnWait.guardSeen)) then
					return v1217(v1218)
				end
			end

			if not (guardReturnWait.deadline <= os.clock()) then
				p368:_setStatus("Waiting for guard to return egg")
				task.wait(0.03)

				continue
			end

			return v1217(nil, "Guard return timed out")
		end

		return v1217(nil, "Recovery cancelled")
	end
	t41._reStealDroppedEgg = function(p373, p374)
		if type(p374) == "string" and p374 ~= "" then
			if not p373:isPrimerEgg(p374) and not p373:isIntentionalGiftDrop(p374) then
				if p373.tweenRecoveryUid == p374 then
					p373.running = false
					p373.activeTarget = nil
					p373:_releaseOperation()
					p373:_scheduleMovementRetry()

					return
				end

				local v1219 = p373:_claimCarryWorker("re-steal", p374)

				if not v1219 then
					return
				end

				local v1220 = v694()

				if v1220 and v1220.__ZeroinGodMode then
					pcall(function()
						v1220.__ZeroinGodMode:startDefend(p374)
					end)
				end

				p373.dropRecoveryUid = p374
				p373:_setStatus("Re-stealing dropped egg")

				local v1221, v1222 = p373:_waitForGuardReturn(p374, function()
					return p373:_isCarryWorkerCurrent(v1219) and p373:_isDropRecoveryPending(p374)
				end)

				if not p373:_isCarryWorkerCurrent(v1219) then
					return
				end

				if not p373:_isDropRecoveryPending(p374) then
					p373:_releaseCarryWorker(v1219)

					return
				end

				if not v1221 or not p373:_wallOpen() then
					p373:_releaseCarryWorker(v1219)
					p373:_finish(v1222 or "Egg lost — retrying")

					return
				end

				p373:_cancelTween("Re-stealing dropped egg", true)

				local Character = LocalPlayer2.Character
				local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
				local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

				if HumanoidRootPart then
					HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
					HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
				end

				local v1226 = p373:_resolveEggDestination(v1221, HumanoidRootPart, Humanoid)

				if not v1226 then
					p373:_releaseCarryWorker(v1219)
					p373:_finish("Character unavailable")

					return
				end

				p373.running = true
				p373.activeTarget = v1221
				p373:_setStatus("Teleporting to dropped egg")

				if not p373:_teleportRoot(HumanoidRootPart, Humanoid, v1226) then
					p373:_releaseCarryWorker(v1219)
					p373:_finish("Dropped egg teleport failed")

					return
				end

				p373:_setArrivalHold(v1226, v1221.Uid)
				p373:_setStatus("Re-stealing egg")

				if p373:_isCarryWorkerCurrent(v1219) then
					p373:_requestCarry(v1221, true)
				end

				return
			end
		end

		p373:_finish("Egg lost — retrying")
	end
	t41._recoverCarryConfirmationTimeout = function(p375, p376, p377, p378)
		if not p375.destroyed and p375.enabled then
			if p375.carryAttemptToken == p376 and not p375:_hasConfirmedCarry(p377) then
				local Character = LocalPlayer2.Character
				local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
				local v1229 = HumanoidRootPart and p375:_resolveSafeCFrame(HumanoidRootPart)
				local v1230 = v1229 and p375:_resolveElevatedDestination(HumanoidRootPart, v1229) or nil

				p375.tweenRecoveryUid = p377
				p375.dropRecoveryUid = nil
				p375.guardReturnWait = nil

				local carry = p375.carry

				carry.generation += 1
				p375:_invalidateCarryWorker()
				p375.carryAttemptToken = nil
				p375:_clearArrivalHold(p377)

				if p375.activeTween and p375.activeTween.Cancel then
					pcall(p375.activeTween.Cancel, p375.activeTween)
				end

				p375.activeTween = nil
				p375:_stopMovementProtection()
				p375.running = false
				p375.activeTarget = nil
				p375.stats.lastResult = p378 and "Carry timeout: " .. p378 or "Carry confirmation timeout"

				if HumanoidRootPart and v1230 then
					pcall(function()
						HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
						HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
						HumanoidRootPart.CFrame = v1230
						HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
						HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
					end)
					p375:_setStatus(p375.stats.lastResult .. " — teleported safe")
				else
					p375:_setStatus(p375.stats.lastResult .. " — safe area unavailable")
				end

				if p375.enabled then
					p375:_startMovementProtection()
				end

				p375:_releaseOperation()
				task.delay(0.35, function()
					if not p375.destroyed and p375.enabled and p375.carryAttemptToken == nil then
						p375:_schedule()
					end
				end)

				return true
			end
		end

		return false
	end
	t41._requestCarry = function(p379, p380, p381)
		if not p379:_wallOpen() then
			p379:_finish("Wall closed before carry")

			return
		end

		local Uid = p380.Uid
		local carryAttemptToken = {}
		local u1234
		local u1235

		p379.carryAttemptToken = carryAttemptToken
		p379.stats.lastResult = "Carry requested"
		p379:_setStatus("Securing egg")

		local Character = LocalPlayer2.Character
		local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

		if Humanoid then
			pcall(Humanoid.UnequipTools, Humanoid)
		end

		if p379.coordinator then
			if p379.coordinator:isBackgroundBusy() then
				local v1238 = os.clock() + 0.08

				while p379.coordinator:isBackgroundBusy() and not p379.destroyed and p379.enabled and p379.carryAttemptToken == carryAttemptToken and os.clock() < v1238 do
					task.wait(0.02)
				end

				if Humanoid and Humanoid.Parent then
					pcall(Humanoid.UnequipTools, Humanoid)
				end
			end
		end

		task.spawn(function()
			while not p379.destroyed and p379.enabled and p379.running and p379.carryAttemptToken == carryAttemptToken and p379.activeTarget and p379.activeTarget.Uid == Uid do
				if p379:_hasConfirmedCarry(Uid) then
					p379:_clearArrivalHold(Uid)
					p379.carryAttemptToken = nil

					if p379.activeTween then
						pcall(p379.activeTween.Cancel, p379.activeTween)
						p379.activeTween = nil
					end

					if p379.instantPhase ~= "priming" or Uid ~= p379.primerUid then
						p379.stats.lastResult = "Carry confirmed"
						p379:_setStatus("Carry confirmed")
						task.defer(function()
							if not p379.destroyed and p379.enabled and p379:_hasConfirmedCarry(Uid) then
								p379:_returnToSafe()
							end
						end)

						return
					end

					p379.carry.active = true
					p379.carry.uid = Uid
					p379.stats.lastResult = "Primer secured"
					p379:_enterBaitWait()

					return
				end

				if not p379:_wallOpen() then
					p379:_finish("Wall closed before carry")

					return
				end

				local v1239 = EggState2.ReadFieldEgg(Uid) or p379.records[Uid]

				if not p379:isPrimerEgg(Uid) and not p379:isIntentionalGiftDrop(Uid) then
					local v1240, v1241, v1242, v1243, _finish, v1245

					if v1239 and v1239.State == AreaEggs.States.GuardCarried then
						v1240, v1241 = p379:_waitForGuardReturn(Uid, function()
							return not p379.destroyed and p379.enabled and p379.running and p379.carryAttemptToken == carryAttemptToken
						end)
						v1239 = v1240
						v1242 = v1241

						if p379.carryAttemptToken ~= carryAttemptToken or p379.destroyed or not p379.enabled then
							return
						end

						if not v1239 then
							v1243 = p379
							_finish = p379._finish
							v1245 = v1242 or "Guard return failed"
							_finish(v1243, v1245)

							return
						end

						p379.activeTarget = v1239
						u1234 = nil
						u1235 = nil
					elseif not v1239 and p379:_isDropRecoveryPending(Uid) then
						v1240, v1241 = p379:_waitForGuardReturn(Uid, function()
							return not p379.destroyed and p379.enabled and p379.running and p379.carryAttemptToken == carryAttemptToken
						end)
						v1239 = v1240
						v1242 = v1241

						if p379.carryAttemptToken ~= carryAttemptToken or p379.destroyed or not p379.enabled then
							return
						end

						if not v1239 then
							v1243 = p379
							_finish = p379._finish
							v1245 = v1242 or "Guard return failed"
							_finish(v1243, v1245)

							return
						end

						p379.activeTarget = v1239
						u1234 = nil
						u1235 = nil
					end
				end

				if u1234 then
					if u1234 <= os.clock() then
						p379:_recoverCarryConfirmationTimeout(carryAttemptToken, Uid, u1235)

						return
					end
				end

				if not v1239 then
					p379:_finish("Target unavailable")

					return
				end

				if v1239.State ~= AreaEggs.States.Carried then
					if v1239.State ~= AreaEggs.States.Slot and v1239.State ~= AreaEggs.States.Dropped then
						p379:_finish("Target changed")

						return
					end

					local Character2 = LocalPlayer2.Character
					local HumanoidRootPart = Character2 and Character2:FindFirstChild("HumanoidRootPart")

					if not HumanoidRootPart then
						p379:_finish("Character unavailable")

						return
					end

					local Humanoid2 = Character2 and Character2:FindFirstChildOfClass("Humanoid")

					if not Humanoid2 then
						p379:_finish("Character unavailable")

						return
					end

					local v1249 = p379:_resolveEggDestination(v1239, HumanoidRootPart, Humanoid2)
					local v1250 = v1249

					if not v1250 then
						p379:_finish("Character unavailable")

						return
					end

					if (HumanoidRootPart.Position - v1250.Position).Magnitude > 10 then
						if not p381 then
							p379:_setStatus("Re-approaching egg")

							local u1251 = false
							local v1252 = p379
							local _tweenRoot = p379._tweenRoot
							local v1254 = v1249

							local function v1255()
								u1251 = true

								if not (p379.carryAttemptToken ~= carryAttemptToken or p379:_hasConfirmedCarry(Uid)) then
									p379:_setStatus("Securing egg")
								end
							end

							_tweenRoot(v1252, v1254, v1255, nil, {
								holdAfterArrival = true,
								holdUid = Uid,
								flightProfile = not (p379.instantPhase == "priming" and Uid == p379.primerUid)
							})

							while not p379.destroyed and p379.enabled and p379.carryAttemptToken == carryAttemptToken and not p379:_hasConfirmedCarry(Uid) and not u1251 do
								task.wait(0.25)
							end

							continue
						end

						p379:_setStatus("Teleporting back to dropped egg")

						if not p379:_teleportRoot(HumanoidRootPart, Humanoid2, v1250) then
							p379:_finish("Dropped egg teleport failed")

							return
						end

						p379:_setArrivalHold(v1250, Uid)
						p379:_setStatus("Re-stealing egg")
					end

					local v1256 = AreaEggSlotIdentity.LooksLikeFirstAreaUid(v1239.Uid) and AreaEggSlotIdentity.SlotKey(v1239.AreaId, v1239.NestId) or nil
					local v1257 = (tonumber(LocalPlayer2:GetAttribute("RagdollEndTime")) or 0) - workspace:GetServerTimeNow()
					local v1258 = p381 and p379.config.stealMode == "Instant" and p379.instantPhase == "hunting"

					if Humanoid2.Parent and not v1258 then
						pcall(function()
							Humanoid2.PlatformStand = false
							Humanoid2.Sit = false

							local state = Humanoid2:GetState()

							if state == Enum.HumanoidStateType.Physics or state == Enum.HumanoidStateType.Ragdoll or state == Enum.HumanoidStateType.FallingDown or state == Enum.HumanoidStateType.PlatformStanding then
								Humanoid2:ChangeState(Enum.HumanoidStateType.Running)
							end
						end)
					end

					if not v1258 and v1257 > 0 then
						p379:_setStatus(string.format("Hit recovery (%.1fs)", v1257))

						if Remotes and Remotes.Limpness and Remotes.Limpness.WriteLimpness then
							pcall(function()
								Remotes.Limpness.WriteLimpness:FireServer(false)
							end)
						end

						if v1257 > 0.05 then
							task.wait(math.clamp(v1257 - 0.03, 0.02, 0.12))
						end
					end

					if p379.destroyed or not p379.enabled or p379.carryAttemptToken ~= carryAttemptToken or p379.carry.active or p379:_hasConfirmedCarry(Uid) or LocalPlayer2.Character ~= Character2 then
						return
					end

					local ok, result, result2 = pcall(v652, v1239.Uid, v1256, true)

					if p379.destroyed or not p379.enabled or p379.carryAttemptToken ~= carryAttemptToken or p379.carry.active then
						return
					end

					if p379:_hasConfirmedCarry(Uid) then
						return
					end

					u1234 = u1234 or os.clock() + 5

					if ok and result then
						u1235 = nil
						p379.stats.lastResult = "Carry accepted; awaiting confirmation"
						p379:_setStatus("Waiting for carry confirmation")
					else
						local v1263 = ok and result2 or "Request failed"

						if type(v1263) ~= "string" or v1263 == "" then
							v1263 = "Server rejected carry"
						end

						local carryRejected = v1263:sub(1, 100)

						if u1235 ~= carryRejected then
							u1235 = carryRejected
							p379.stats.lastResult = "Carry rejected: " .. carryRejected
							p379:_setStatus(p379.stats.lastResult)
						end
					end

					task.wait(0.05)

					continue
				end

				if v1239.CarrierUserId ~= LocalPlayer2.UserId then
					p379:_finish("Egg carried by another player")

					return
				end

				p379:_setStatus("Confirming carry state")
				task.wait(0.25)
			end
		end)
	end
	t41._dropCarriedEggAtFirstArea = function(p382)
		local uid = p382.carry.uid

		if type(uid) ~= "string" or uid == "" or p382:isPrimerEgg(uid) then
			return false
		end

		local v1266 = p382:_claimCarryWorker("gift-drop", uid)

		if not v1266 then
			return false
		end

		local Character = LocalPlayer2.Character
		local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
		local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
		local v1270 = p382:_resolveForestDropCFrame(HumanoidRootPart)

		if not HumanoidRootPart or not Humanoid or not v1270 then
			p382:_releaseCarryWorker(v1266)
			p382:_finish("Forest drop destination unavailable")

			return false
		end

		if not p382:_wallOpen() then
			p382:_releaseCarryWorker(v1266)
			p382:_finish("Forest drop interrupted by reset")

			return false
		end

		p382.running = true
		p382:_setStatus("Delivering egg to Forest")
		p382:_tweenRoot(v1270, function()
			if not p382:_isCarryWorkerCurrent(v1266) then
				return
			end

			if p382.destroyed or not p382.enabled or not p382.carry.active or p382.carry.uid ~= uid then
				p382:_releaseCarryWorker(v1266)

				return
			end

			p382.intentionalGiftUid = uid
			p382:_setStatus("Dropping egg at Forest")
			task.spawn(function()
				local v1271 = os.clock() + 2

				while p382:_isCarryWorkerCurrent(v1266) and not p382.destroyed and p382.enabled and p382.intentionalGiftUid == uid and p382.carry.active and p382.carry.uid == uid and os.clock() < v1271 do
					local ok, result = pcall(function()
						return EggWorld.AskFieldEggDrop:InvokeServer({
							Reason = "PlayerRequest"
						})
					end)

					if not ok then
						break
					end

					if result == true then
						task.wait(0.03)
					else
						task.wait(0.08)
					end
				end

				if p382.intentionalGiftUid == uid and p382.carry.active and p382.carry.uid == uid then
					p382.intentionalGiftUid = nil
					p382:_releaseCarryWorker(v1266)
					p382:_finish("Forest drop not confirmed")
				elseif p382:_isCarryWorkerCurrent(v1266) then
					p382:_releaseCarryWorker(v1266)
				end
			end)
		end, nil, {
			flightProfile = true,
			arrivalHoldSeconds = 0
		})

		return true
	end
	t41._returnToSafe = function(p383)
		p383:_hideTreadmillDecoy()

		local uid = p383.carry.uid

		if p383:isPrimerEgg(uid) then
			return
		end

		if p383.config.dropAtFirstArea then
			p383:_dropCarriedEggAtFirstArea()

			return
		end

		local v1275 = p383:_claimCarryWorker("return", uid)

		if not v1275 then
			return
		end

		p383:_clearArrivalHold(uid)

		if not p383:_wallOpen() then
			p383:_releaseCarryWorker(v1275)
			p383:_finish("Reset interrupted carry")

			return
		end

		local Character = LocalPlayer2.Character
		local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")

		if not HumanoidRootPart then
			p383:_releaseCarryWorker(v1275)
			p383:_finish("Character unavailable")

			return
		end

		if not p383:_hasConfirmedCarry(uid) or p383:_recordShowsForeignCarry(uid) then
			p383:_releaseCarryWorker(v1275)
			p383:_finish("Carry not confirmed — retrying")

			return
		end

		if p383:_isInSafeArea(HumanoidRootPart) then
			p383:_finalizeReturn(v1275)

			return
		end

		local v1278 = p383:_resolveSafeCFrame(HumanoidRootPart)

		if not v1278 then
			p383:_releaseCarryWorker(v1275)
			p383:_finish("Safe destination unavailable")

			return
		end

		local v1279 = p383:_buildSafeZigzagWaypoints(HumanoidRootPart, v1278)
		local v1280 = v1279[1]

		if not v1280 then
			p383:_setStatus("Returning to safe area")
			p383:_tweenRoot(v1278, function()
				if p383:_isCarryWorkerCurrent(v1275) then
					p383:_finalizeReturn(v1275)
				end
			end, nil, {
				flightProfile = true,
				arrivalHoldSeconds = 0
			})

			return
		end

		local t46 = {}

		for i = 2, #v1279 do
			table.insert(t46, v1279[i])
		end

		table.insert(t46, v1278)
		p383:_setStatus(string.format("Zigzag return · %d turns", #v1279))
		p383:_tweenRoot(v1280, function()
			if p383:_isCarryWorkerCurrent(v1275) then
				p383:_finalizeReturn(v1275)
			end
		end, nil, {
			pathWaypoints = t46,
			flightProfile = true,
			arrivalHoldSeconds = 0
		})
	end
	t41._finalizeReturn = function(p384, p385)
		if not p384:_isCarryWorkerCurrent(p385) then
			return
		end

		if not p384.carry.active then
			p384.hasDepositedThisSession = true
			p384:_releaseCarryWorker(p385)
			p384:_finish("Safe return complete")

			return
		end

		p384:_setStatus("Validating safe arrival")

		local now = os.clock()
		local v1284 = os.clock() + 6

		while p384:_isCarryWorkerCurrent(p385) and p384.carry.active and os.clock() < v1284 do
			local HumanoidRootPart = LocalPlayer2.Character and LocalPlayer2.Character:FindFirstChild("HumanoidRootPart")

			if not HumanoidRootPart then
				p384:_releaseCarryWorker(p385)
				p384:_finish("Character unavailable")

				return
			end

			if not p384:_isInSafeArea(HumanoidRootPart) then
				p384:_setStatus("Rollback detected — returning again")
				p384:_releaseCarryWorker(p385)
				task.defer(function()
					if not p384.destroyed and p384.enabled and p384.carry.active then
						p384:_returnToSafe()
					end
				end)

				return
			end

			if os.clock() - now >= 0.35 then
				p384:_setStatus("Waiting for deposit")
			end

			task.wait(0.08)
		end

		if not p384:_isCarryWorkerCurrent(p385) then
			return
		end

		if not p384.carry.active then
			p384:_releaseCarryWorker(p385)
			p384:_finish("Safe return complete")

			return
		end

		p384:_setStatus("Deposit pending — validating again")
		task.defer(function()
			if p384:_isCarryWorkerCurrent(p385) and p384.carry.active then
				p384:_finalizeReturn(p385)
			end
		end)
	end
	t41._finish = function(p386, p387)
		p386:_invalidateCarryWorker()
		p386.planGeneration += 1

		if p386.panelActiveUid ~= nil then
			p386.panelActiveUid = nil
		end

		local v1286 = p386:hasDrPriorityEggsAuthoritative(true)
		local v1287 = p386.riftRuntime and type(p386.riftRuntime.isPlacePending) == "function" and p386.riftRuntime:isPlacePending()
		local v1288 = not v1286 and p386.drScrambleRuntime and type(p386.drScrambleRuntime.isEventWindowActive) == "function" and p386.drScrambleRuntime:isEventWindowActive()
		local v1289 = p386.captureTheEggRuntime and type(p386.captureTheEggRuntime.isEngaged) == "function" and p386.captureTheEggRuntime:isEngaged()
		local v1290 = p386.enabled and not v1287 and not v1288 and not v1289

		p386:_cancelTween(p387, v1290)

		local v1291 = p386
		local _setStatus = p386._setStatus
		local v1293 = v1290 and "Searching"

		_setStatus(v1291, v1293 or v1288 and "Yielding to Dr. Scramble" or v1287 and "Yielding to Rift place" or "Idle")

		if p386.enabled then
			task.delay(0.1, function()
				if p386.destroyed then
					p386:_releaseOperation()

					return
				end

				if not (p386.userStealEnabled or p386.riftObjectiveEnabled or p386.drScrambleObjectiveEnabled or p386.panelTargetUid ~= nil or p386.panelActiveUid ~= nil) then
					p386:_reconcileRunningState()

					return
				end

				p386:_schedule()
			end)
		end
	end
	t41._scheduleMovementRetry = function(p388)
		if not p388.movementRetryPending and not p388.destroyed then
			if p388.enabled then
				p388.movementRetryPending = true
				task.delay(0.2, function()
					p388.movementRetryPending = false

					if not p388.destroyed and p388.enabled then
						p388:_schedule()
					end
				end)

				return
			end
		end
	end
	t41._schedule = function(p389)
		if p389.destroyed or not p389.enabled or p389.running or p389.safeStarting or p389.resetSnapshotPending then
			return
		end

		if not p389.startupSettled then
			p389:_setStatus("Waiting for filters")

			return
		end

		local Character = LocalPlayer2.Character
		local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
		local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

		if not HumanoidRootPart or not Humanoid then
			p389:_releaseOperation()
			p389:_setStatus("Character unavailable")

			return
		end

		p389:_startMovementProtection()

		if p389.carry.active and p389.carry.uid ~= nil then
			if p389:isPrimerEgg(p389.carry.uid) then
				return
			end

			p389:_returnToSafe()

			return
		end

		if not p389:_wallOpen() then
			p389:_releaseOperation()
			p389:_setStatus("Waiting for reset wall")

			return
		end

		if p389.riftRuntime and type(p389.riftRuntime.isTradeReady) == "function" then
			if p389.riftRuntime:isTradeReady() then
				p389:_releaseOperation()
				p389:_setStatus("Yielding to Rift trade")
				task.delay(0.5, function()
					if not p389.destroyed and p389.enabled then
						p389:_schedule()
					end
				end)

				return
			end
		end

		if p389.riftRuntime and type(p389.riftRuntime.isPlacePending) == "function" then
			if p389.riftRuntime:isPlacePending() then
				p389:_releaseOperation()
				p389:_setStatus("Yielding to Rift place")
				task.delay(0.5, function()
					if not p389.destroyed and p389.enabled then
						p389:_schedule()
					end
				end)

				return
			end
		end

		if p389.captureTheEggRuntime and type(p389.captureTheEggRuntime.isEngaged) == "function" then
			if p389.captureTheEggRuntime:isEngaged() then
				p389:_releaseOperation()
				p389:_setStatus("Yielding to Capture The Egg")
				task.delay(0.5, function()
					if not p389.destroyed and p389.enabled then
						p389:_schedule()
					end
				end)

				return
			end
		end

		local tweenRecoveryUid = p389.tweenRecoveryUid
		local v1298 = tweenRecoveryUid and (EggState2.ReadFieldEgg(tweenRecoveryUid) or p389.records[tweenRecoveryUid]) or nil

		if tweenRecoveryUid and (type(v1298) ~= "table" or v1298.State ~= AreaEggs.States.Slot and v1298.State ~= AreaEggs.States.Dropped) then
			p389.tweenRecoveryUid = nil
			tweenRecoveryUid = nil
			v1298 = nil
		end

		if not v1298 and p389.drScrambleObjectiveEnabled and p389.drScrambleRuntime then
			if p389.drScrambleRuntime:isEventWindowActive() and not p389:hasDrPriorityEggsAuthoritative() then
				if p389.drScrambleNeedsSafeReturn then
					if not p389:_isInSafeArea(HumanoidRootPart) then
						p389:_returnToSafeForDrScramble(HumanoidRootPart)

						return
					end

					p389.drScrambleNeedsSafeReturn = false
				end

				local v1299 = p389.drScrambleRuntime:getEventRoute()

				if v1299 then
					p389:_startDrScrambleRoute(v1299)
				else
					p389:_releaseOperation()
					p389:_setStatus("Waiting for event robot replication")
					p389:_scheduleMovementRetry()
				end

				return
			end
		end

		v1298 = v1298 or p389:_chooseTarget()

		if not v1298 then
			p389:_releaseOperation()

			local treadmillManager = p389.treadmillManager and p389.treadmillManager:isEngaged()

			if not treadmillManager and p389:_isInField(HumanoidRootPart) and not p389:_isInSafeArea(HumanoidRootPart) then
				local v1301 = p389:_resolveSafeCFrame(HumanoidRootPart)

				if v1301 and not p389.safeStarting then
					p389.safeStarting = true
					p389.running = true
					p389:_setStatus("Returning to safe area")
					p389:_tweenRoot(v1301, function()
						p389.safeStarting = false
						p389.running = false
						task.delay(0.2, function()
							if not p389.destroyed and p389.enabled then
								p389:_schedule()
							end
						end)
					end, nil, {
						flightProfile = true,
						arrivalHoldSeconds = 0
					})

					return
				end
			end

			p389:_setStatus(treadmillManager and "Training on treadmill" or "No matching eggs")

			return
		end

		local planGeneration = p389.planGeneration
		local v1303, v1304 = p389:_acquireOperation()

		if not v1303 then
			p389:_setStatus("Waiting · " .. tostring(v1304 or "another operation"))
			task.delay(0.5, function()
				if not p389.destroyed and p389.enabled and p389.planGeneration == planGeneration then
					p389:_schedule()
				end
			end)

			return
		end

		p389.safeStarting = true
		p389.running = true
		p389.activeTarget = v1298

		if v1298 and v1298.AssetCategory then
			if v1298.AreaId and type(t10) == "table" then
				t10[v1298.AssetCategory] = v1298.AreaId
			end

			local v1305 = v694()

			if v1305 then
				v1305.__ZeroinLastStolenEgg = {
					AssetCategory = v1298.AssetCategory,
					AssetScale = v1298.AssetScale,
					AreaId = v1298.AreaId,
					Mutations = v1298.Mutations,
					BaseMutation = v1298.BaseMutation,
					Timestamp = os.clock()
				}
			end
		end

		local v1306 = p389.catalog.resolve(v1298)

		p389.stats.lastTarget = string.format("%s · %s · %s", v1306.rarity, v1306.name, v1298.AreaId)

		if tweenRecoveryUid then
			p389.safeStarting = false
			p389.stats.lastResult = "Recovering with tween"

			local v1307 = p389:_resolveEggDestination(v1298, HumanoidRootPart, Humanoid)

			if not v1307 then
				p389.tweenRecoveryUid = nil
				p389:_finish("Recovery destination unavailable")

				return
			end

			p389:_setStatus("Returning to egg")
			p389:_tweenRoot(v1307, function()
				if p389.tweenRecoveryUid == v1298.Uid then
					p389:_requestCarry(v1298, false)
				end
			end, nil, {
				holdAfterArrival = true,
				holdUid = v1298.Uid,
				flightProfile = true,
				carryTarget = v1298
			})

			return
		end

		local dropAtFirstArea = p389.continueFromForestGift and p389.config.dropAtFirstArea and p389:_wallOpen() and p389:_isInsideForest(HumanoidRootPart)

		p389.continueFromForestGift = false

		if not dropAtFirstArea and p389:_isInField(HumanoidRootPart) and not p389:_isInSafeArea(HumanoidRootPart) then
			local v1309 = p389:_resolveSafeCFrame(HumanoidRootPart)

			if v1309 then
				p389.safeStarting = true
				p389.running = true
				p389:_setStatus("Repositioning to safe area")
				p389:_tweenRoot(v1309, function()
					p389.safeStarting = false
					p389.running = false
					task.delay(0.15, function()
						if not p389.destroyed and p389.enabled and p389.planGeneration == planGeneration then
							p389:_schedule()
						end
					end)
				end, nil, {
					flightProfile = true
				})

				return
			end
		end

		p389.safeStarting = false

		local v1310 = p389:_choosePrimerEgg(v1298.Uid)

		if not v1310 then
			p389.running = false
			p389.activeTarget = nil
			p389:_releaseOperation()
			p389:_setStatus("Waiting for Forest primer")
			task.delay(0.25, function()
				if not p389.destroyed and p389.enabled and p389.planGeneration == planGeneration then
					p389:_schedule()
				end
			end)

			return
		end

		p389.instantPhase = "priming"
		p389.primerUid = v1310.Uid
		p389.targetUid = v1298.Uid
		p389.activeTarget = v1310

		if p389.config.stealMode == "Instant" then
			p389:_showTreadmillDecoy()
		end

		local v1311 = p389.hasDepositedThisSession == true

		if p389.config.stealMode == "Instant" then
			v1311 = true
		end

		local v1312 = p389:_resolveEggDestination(v1310, HumanoidRootPart, Humanoid)

		if not v1312 then
			p389:_finish("Primer destination unavailable")

			return
		end

		if v1311 then
			p389.stats.lastResult = p389.config.stealMode .. " priming (teleport)"
			p389:_setStatus("Teleporting to Forest primer")

			if not p389:_teleportRoot(HumanoidRootPart, Humanoid, v1312) then
				p389:_finish("Teleport primer failed")

				return
			end

			p389:_setArrivalHold(v1312, v1310.Uid)
			p389:_requestCarry(v1310, true)
		else
			p389.stats.lastResult = p389.config.stealMode .. " priming (tween)"
			p389:_setStatus("Traveling to Forest primer")
			p389:_tweenRoot(v1312, function()
				p389:_requestCarry(v1310, false)
			end, nil, {
				holdAfterArrival = true,
				holdUid = v1310.Uid,
				flightProfile = false,
				carryTarget = v1310
			})
		end
	end
	t41._reconcileRunningState = function(p390)
		local enabled = p390.userStealEnabled == true or p390.riftObjectiveEnabled == true or p390.drScrambleObjectiveEnabled == true or p390.panelTargetUid ~= nil or p390.panelActiveUid ~= nil

		if p390.enabled == enabled then
			if p390.enabled then
				p390:_refreshCounts()
				p390:_schedule()
			end

			return
		end

		p390.enabled = enabled

		if p390.enabled then
			p390.healthProtectionOwners.auto_steal = true

			if LocalPlayer2.Character then
				v682(LocalPlayer2.Character)
				v685(p390, LocalPlayer2.Character)
			end

			p390:_startMovementProtection()
			p390:_setStatus("Searching")
			p390:_schedule()
		else
			p390.hasDepositedThisSession = false
			p390.panelTargetUid = nil
			p390.panelActiveUid = nil
			p390.planGeneration += 1

			local carry = p390.carry

			carry.generation += 1
			p390:_cleanupInstantSteal()
			p390:_invalidateCarryWorker()
			p390.carry.active = false
			p390.carry.uid = nil
			p390.intentionalGiftUid = nil
			table.clear(p390.giftDropUids)
			p390.continueFromForestGift = false
			p390.tweenRecoveryUid = nil
			p390.claimPresentationSuppression = nil
			p390.safeStarting = false
			p390.movementRetryPending = false
			p390:_cancelTween("Disabled")
			p390:_restoreTreadmillVisualAtSafe()
			p390:_releaseOperation()
			p390:_stopMovementProtection()
			p390:releaseHealthProtection("auto_steal")
			p390.activeTarget = nil
			p390.running = false
			p390:_setStatus("Idle")
		end

		p390:_refreshCounts()
	end
	t41.markStartupSettled = function(p391)
		if p391.startupSettled then
			return
		end

		p391.startupSettled = true
		p391:_refreshCounts()

		if p391.enabled and not p391.running and not p391.destroyed then
			p391:_schedule()
		end
	end
	t41.requestPanelSteal = function(p392, p393)
		if not p392.isPremium then
			return false, "PREMIUM_REQUIRED"
		end

		if p392.destroyed or type(p393) ~= "string" or p393 == "" then
			return false, "Invalid egg UID"
		end

		local v1315 = EggState2.ReadFieldEgg(p393) or p392.records[p393]

		if type(v1315) ~= "table" then
			return false, "Egg no longer exists"
		end

		if v1315.State ~= AreaEggs.States.Slot and v1315.State ~= AreaEggs.States.Dropped then
			return false, "Egg is no longer available"
		end

		if p392:isIntentionalGiftDrop(p393) then
			return false, "Gift egg is blacklisted"
		end

		p392.panelTargetUid = p393
		p392.stats.lastResult = "Egg Panel target queued"
		p392:_reconcileRunningState()

		return true
	end
	t41._sanitizePremiumToggleState = function(p394)
		if p394.isPremium then
			return false
		end

		local v1316 = p394.config.stealFromPlayers == true

		p394.config.stealFromPlayers = false

		return v1316
	end
	t41.setPremium = function(p395, p396)
		local isPremium = p396 == true

		if p395.isPremium == isPremium then
			if not isPremium then
				p395:_sanitizePremiumToggleState()
			end

			return p395.isPremium
		end

		p395.isPremium = isPremium

		if not isPremium then
			local v1318 = p395.playerHuntToken ~= nil

			p395:_sanitizePremiumToggleState()
			p395.playerHuntToken = nil
			p395.playerHuntCarrier = nil
			p395:_removePlayerStealBatAura()

			if v1318 then
				p395.planGeneration += 1
				p395:_cancelTween("Premium access changed")
			end
		end

		p395:_refreshCounts()
		p395:_schedule()

		return p395.isPremium
	end
	t41.setEnabled = function(p397, p398)
		p397:_sanitizePremiumToggleState()
		p397.userStealEnabled = p398 == true

		if p397.userStealEnabled then
			local manualCarry = p397.manualCarry

			manualCarry.generation += 1
			p397.manualCarry.active = false
			p397.manualCarry.uid = nil
		end

		p397:_reconcileRunningState()
	end
	t41.setDropAtFirstArea = function(p399, p400)
		p399.config.dropAtFirstArea = p400 == true

		if not p399.config.dropAtFirstArea then
			p399.continueFromForestGift = false
		end

		return p399.config.dropAtFirstArea
	end
	t41.setStealFromPlayers = function(p401, p402)
		if not (p402 ~= true or p401.isPremium) then
			p401.config.stealFromPlayers = false

			return false, "PREMIUM_REQUIRED"
		end

		p401.config.stealFromPlayers = p402 == true

		if not p401.config.stealFromPlayers then
			p401.playerHuntToken = nil
			p401.playerHuntCarrier = nil
			p401:_removePlayerStealBatAura()

			if p401.activeTween and p401.instantPhase == "player_hunt" then
				p401.planGeneration += 1
				p401:_cancelTween("Player steal disabled")
			end
		end

		p401:_refreshCounts()
		p401:_schedule()

		return p401.config.stealFromPlayers
	end
	v670 = function(p403)
		if type(p403) ~= "table" then
			return nil
		end

		local Category = p403.Category or p403.AssetCategory
		local v1321 = tonumber(p403.Scale or p403.AssetScale)

		if type(Category) ~= "string" or not v1321 or v1321 <= 0 then
			return nil
		end

		local ok, result = pcall(AssetEarnings.MutationOnlyRatePerSecond, {
			Category = Category,
			Scale = v1321,
			Mutations = type(p403.Mutations) == "table" and table.clone(p403.Mutations) or {},
			BaseMutation = type(p403.BaseMutation) == "string" and p403.BaseMutation or nil
		})

		return ok and type(result) == "number" and result or nil
	end
	t41.setMinValuePerSec = function(p404, p405)
		p404.config.minValuePerSec = math.max(tonumber(p405) or 0, 0)
		p404:_refreshCounts()
		p404:_schedule()
	end
	t41.setSpeed = function(p406, p407)
		local v1324 = math.clamp(math.floor((tonumber(p407) or 80) + 0.5), 20, 120)

		p406.config.speed = v1324 * 10

		if p406.enabled or p406.activeTween then
			p406:_startMovementProtection()
		end

		return v1324
	end
	t41.getDefaultSpeed = function()
		return 80
	end
	t41.setStealZigzag = function(p408, p409)
		p408.config.stealZigzag = p409 == true

		return p408.config.stealZigzag
	end
	t41.setFilterEnabled = function(p410, p411, p412)
		p410.config[p411 .. "Enabled"] = p412 == true
		p410:_refreshCounts()
		p410:_schedule()
	end
	t41.setFilter = function(p413, p414, p415)
		local config = p413.config

		config[p414] = type(p415) == "table" and table.clone(p415) or {}
		p413:_refreshCounts()
		p413:_schedule()
	end
	t41.destroy = function(p416)
		if p416.destroyed then
			return
		end

		p416.destroyed = true
		p416.enabled = false
		p416:releaseDrScrambleRoute(true)
		p416:_hideTreadmillDecoy()
		p416.panelTargetUid = nil
		p416.panelActiveUid = nil
		p416.planGeneration += 1

		local carry = p416.carry

		carry.generation += 1
		p416:_invalidateCarryWorker()
		p416.carry.active = false
		p416.carry.uid = nil
		p416.intentionalGiftUid = nil
		table.clear(p416.giftDropUids)
		p416.continueFromForestGift = false
		p416.playerHuntToken = nil
		p416.playerHuntCarrier = nil
		p416:_removePlayerStealBatAura()
		p416.tweenRecoveryUid = nil
		p416.safeStarting = false
		p416:_cancelTween("Destroyed")
		p416:_cleanupInstantSteal()
		p416:_releaseOperation()
		p416:_stopMovementProtection()
		table.clear(p416.healthProtectionOwners)

		if p416._healthPinner then
			pcall(p416._healthPinner.Disconnect, p416._healthPinner)
			p416._healthPinner = nil
		end

		if p416._healthChangedConnection then
			pcall(p416._healthChangedConnection.Disconnect, p416._healthChangedConnection)
			p416._healthChangedConnection = nil
		end

		p416:_restoreClaimPresentationFilter()
		v692(LocalPlayer2.Character)
		v662(p416.connections)
		table.clear(p416.listeners)
		table.clear(p416.records)
	end
	t41.hasPendingPreEventSteal = function(p417)
		if not p417.enabled or not p417.userStealEnabled or p417.destroyed then
			return false
		end

		if not p417.startupSettled then
			return true
		end

		if not p417:_wallOpen() then
			return true
		end

		if os.clock() < (p417.preEventReadyAt or 0) then
			return true
		end

		if not p417.running and not p417.safeStarting and p417.activeTarget == nil and p417.tweenRecoveryUid == nil and p417.playerHuntToken == nil and p417.operationToken == nil and (not p417.carry or not p417.carry.active) then
			return p417:hasMatchingUserEggsAuthoritative()
		end

		return true
	end
	t41.setAntiGuard = function(p418, p419)
		p418.antiGuard = p419
	end

	return t41
end

local v1327 = v632()

local function v1328()
	local Players2 = game:GetService("Players")
	local RunService2 = game:GetService("RunService")
	local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
	local LocalPlayer2 = Players2.LocalPlayer
	local Remotes = require(ReplicatedStorage2.Shared.Remotes)
	local EggState2 = require(ReplicatedStorage2.Client.EggState)
	local Ragdoll = require(ReplicatedStorage2.Shared.Modules.Ragdoll)
	local RagdollJoints = require(ReplicatedStorage2.Shared.Modules.RagdollJoints)
	local EggWorld = Remotes.EggWorld
	local t47 = {}

	t47.__index = t47

	local function v1339(p420)
		if p420 then
			pcall(p420.Disconnect, p420)
		end
	end

	t47.new = function(p421)
		local obj = setmetatable({}, t47)

		obj.eggRuntime = p421
		obj.enabled = true
		obj.destroyed = false
		obj.connections = {}
		obj.originalRagdoll = {}
		obj.originalHumanoidStates = setmetatable({}, {
			__mode = "k"
		})
		obj.stats = {
			blockedHits = 0,
			blockedDrops = 0,
			recarriedEggs = 0
		}
		obj.lastHeldEggUid = nil
		obj.lastHeldSlotKey = nil
		obj._installed = false
		obj._stickyToken = 0
		obj._nextBodyRecoveryAt = 0
		obj._nextJointSweepAt = 0
		obj._forestStrikeOldFire = nil

		return obj
	end
	t47._liveBody = function()
		local Character = LocalPlayer2.Character

		return Character, Character and Character:FindFirstChildOfClass("Humanoid"), Character and Character:FindFirstChild("HumanoidRootPart")
	end
	t47._recoverBody = function(p422, p423)
		if p422.enabled then
			if not p422.destroyed then
				local v1342, v1343, v1344 = p422:_liveBody()

				if not v1342 or not v1343 or not v1344 then
					return
				end

				local now = os.clock()

				if not p423 and now < p422._nextBodyRecoveryAt then
					return
				end

				p422._nextBodyRecoveryAt = now + 0.03

				if not p422.originalHumanoidStates[v1343] then
					p422.originalHumanoidStates[v1343] = {
						Dead = v1343:GetStateEnabled(Enum.HumanoidStateType.Dead),
						Physics = v1343:GetStateEnabled(Enum.HumanoidStateType.Physics),
						FallingDown = v1343:GetStateEnabled(Enum.HumanoidStateType.FallingDown),
						Ragdoll = v1343:GetStateEnabled(Enum.HumanoidStateType.Ragdoll),
						BreakJointsOnDeath = v1343.BreakJointsOnDeath,
						RequiresNeck = v1343.RequiresNeck
					}
				end

				local state = v1343:GetState()
				local v1347 = state == Enum.HumanoidStateType.Physics or state == Enum.HumanoidStateType.FallingDown or state == Enum.HumanoidStateType.Ragdoll or state == Enum.HumanoidStateType.PlatformStanding or state == Enum.HumanoidStateType.Seated

				pcall(function()
					v1343.BreakJointsOnDeath = false
					v1343.RequiresNeck = false
					v1343:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
					v1343:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
					v1343:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
					v1343:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
					v1343.PlatformStand = false
					v1343.Sit = false

					local state2 = v1343:GetState()

					if state2 == Enum.HumanoidStateType.Physics or state2 == Enum.HumanoidStateType.FallingDown or state2 == Enum.HumanoidStateType.Ragdoll or state2 == Enum.HumanoidStateType.PlatformStanding or state2 == Enum.HumanoidStateType.Seated then
						v1343:ChangeState(Enum.HumanoidStateType.GettingUp)
						v1343:ChangeState(Enum.HumanoidStateType.Running)
					end
				end)

				for _, descendant in ipairs(v1342:GetDescendants()) do
					if descendant:IsA("Motor6D") then
						if not descendant.Enabled then
							descendant.Enabled = true
						end
					elseif descendant:IsA("BallSocketConstraint") or descendant:IsA("HingeConstraint") then
						if descendant.Name:find("Ragdoll", 1, true) or descendant:GetAttribute("RagdollConstraint") then
							pcall(descendant.Destroy, descendant)
						end
					end
				end

				local AssemblyLinearVelocity = v1344.AssemblyLinearVelocity
				local Magnitude = Vector3.new(AssemblyLinearVelocity.X, 0, AssemblyLinearVelocity.Z).Magnitude

				if v1347 or Magnitude > 340 or math.abs(AssemblyLinearVelocity.Y) > 240 then
					v1344.AssemblyLinearVelocity = Vector3.zero
					v1344.AssemblyAngularVelocity = Vector3.zero
					p422.stats.blockedHits += 1
				end

				return
			end
		end
	end
	t47._watchCharacter = function(p424, p425)
		if not p425 then
			return
		end

		local connection4 = p425.DescendantAdded:Connect(function(descendant)
			if not p424.enabled or p424.destroyed then
				return
			end

			if not descendant:IsA("BallSocketConstraint") and not descendant:IsA("HingeConstraint") then
				if descendant:IsA("Motor6D") and not descendant.Enabled then
					descendant.Enabled = true
				end
			elseif descendant.Name:find("Ragdoll", 1, true) or descendant:GetAttribute("RagdollConstraint") then
				pcall(descendant.Destroy, descendant)
				p424:_recoverBody(true)
			end
		end)

		table.insert(p424.connections, connection4)
	end
	t47._installRagdollHooks = function(p426)
		if p426._installed then
			return
		end

		p426._installed = true

		local ForestStrike = Remotes.GuardPatrol and Remotes.GuardPatrol.ForestStrike

		if ForestStrike and type(hookfunction) == "function" then
			local u1355

			local function v1356(p427, ...)
				if p427 ~= ForestStrike or not p426.enabled or p426.destroyed then
					return u1355(p427, ...)
				end

				if p426.eggRuntime and p426.eggRuntime.instantPhase == "priming" or p426.primerHitWindow then
					return u1355(p427, ...)
				end

				p426.stats.blockedHits += 1
				p426:_recoverBody(true)

				if genv.__ZeroinGodMode then
					genv.__ZeroinGodMode:startDefend()
				end
			end

			pcall(function()
				u1355 = hookfunction(ForestStrike.FireServer, type(newcclosure) == "function" and newcclosure(v1356) or v1356)
				p426._forestStrikeOldFire = u1355
			end)
		end

		for _, v in ipairs({
			"ApplyClientRagdoll",
			"Ragdoll",
			"TimedRagdoll",
			"TimedRagdollAsync"
		}) do
			if type(Ragdoll[v]) == "function" then
				p426.originalRagdoll[v] = Ragdoll[v]
				Ragdoll[v] = function(...)
					if not p426.enabled or p426.destroyed then
						return p426.originalRagdoll[v](...)
					end

					p426.stats.blockedHits += 1
					p426:_recoverBody(true)
				end
			end
		end

		if type(Ragdoll.IsRagdolled) == "function" then
			p426.originalRagdoll.IsRagdolled = Ragdoll.IsRagdolled
			Ragdoll.IsRagdolled = function(p428)
				if p426.enabled and p428 == LocalPlayer2.Character then
					return false
				end

				return p426.originalRagdoll.IsRagdolled(p428)
			end
		end
	end
	t47._restoreLocalState = function(p429)
		for k, originalHumanoidState in pairs(p429.originalHumanoidStates) do
			if k.Parent then
				pcall(function()
					k:SetStateEnabled(Enum.HumanoidStateType.Dead, originalHumanoidState.Dead)
					k:SetStateEnabled(Enum.HumanoidStateType.Physics, originalHumanoidState.Physics)
					k:SetStateEnabled(Enum.HumanoidStateType.FallingDown, originalHumanoidState.FallingDown)
					k:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, originalHumanoidState.Ragdoll)
					k.BreakJointsOnDeath = originalHumanoidState.BreakJointsOnDeath
					k.RequiresNeck = originalHumanoidState.RequiresNeck
				end)
			end
		end

		p429.originalHumanoidStates = setmetatable({}, {
			__mode = "k"
		})
		pcall(RagdollJoints.Release, LocalPlayer2.Character)
	end
	t47._slotKey = function(p430, p431)
		if type(p431) == "table" and type(p431.AreaId) == "string" and type(p431.NestId) == "string" then
			return string.format("%s:%s", p431.AreaId, p431.NestId)
		end

		return nil
	end
	t47._requestCarry = function(p432, p433, p434)
		local t48 = {
			Uid = p433
		}

		if p434 ~= nil then
			t48.FirstAreaSlotKey = p434
		end

		return EggWorld.AskFieldEggCarry:InvokeServer(t48)
	end
	t47._startSticky = function(p435, p436, p437)
		if type(p436) == "string" then
			if p436 ~= "" then
				p435._stickyToken += 1

				local _stickyToken = p435._stickyToken

				p435.stats.recarriedEggs += 1
				task.spawn(function()
					local v1363 = os.clock() + 5

					while not p435.destroyed and p435.enabled and _stickyToken == p435._stickyToken and os.clock() < v1363 do
						local v1364 = EggState2.ReadFieldEgg(p436)

						if v1364 and v1364.State == "Carried" and v1364.CarrierUserId == LocalPlayer2.UserId then
							p435.lastHeldEggUid = p436
							p435.lastHeldSlotKey = p437 or p435:_slotKey(v1364)

							return
						end

						if v1364 and (v1364.State == "Dropped" or v1364.State == "Slot") then
							if p435.eggRuntime then
								if p435.eggRuntime:requestCarryRecovery(p436) then
									return
								end
							end

							local _, _, v1367 = p435:_liveBody()

							if v1367 and v1364.BottomCFrame and (v1367.Position - v1364.BottomCFrame.Position).Magnitude <= 10 then
								pcall(p435._requestCarry, p435, p436, p437 or p435:_slotKey(v1364))
							end
						end

						task.wait(0.05)
					end
				end)

				return
			end
		end
	end
	t47._bindSignals = function(p438)
		table.insert(p438.connections, EggState2.CarryChanged:Connect(function(p439)
			if not p438.enabled then
				return
			end

			if p439.IsCarrying and type(p439.Uid) == "string" then
				p438._stickyToken += 1
				p438.lastHeldEggUid = p439.Uid

				local v1368 = EggState2.ReadFieldEgg(p439.Uid)

				p438.lastHeldSlotKey = p438:_slotKey(v1368)

				return
			end

			local Uid = p439.Uid or p438.lastHeldEggUid
			local lastHeldSlotKey = p438.lastHeldSlotKey

			if Uid then
				p438.stats.blockedDrops += 1
				p438:_startSticky(Uid, lastHeldSlotKey)

				if genv.__ZeroinGodMode then
					genv.__ZeroinGodMode:startDefend(Uid)
				end
			end
		end))
		table.insert(p438.connections, LocalPlayer2.CharacterAdded:Connect(function(character)
			p438:_watchCharacter(character)
			task.defer(function()
				p438:_recoverBody(true)
			end)
		end))

		if LocalPlayer2.Character then
			p438:_watchCharacter(LocalPlayer2.Character)
		end

		table.insert(p438.connections, RunService2.Stepped:Connect(function()
			p438:_recoverBody()
		end))
	end
	t47.setEnabled = function(p440, p441)
		local enabled = p441 == true

		if p440.enabled == enabled then
			return
		end

		p440.enabled = enabled

		if p440.enabled then
			p440:_recoverBody()
		else
			p440._stickyToken += 1
			p440:_restoreLocalState()
		end
	end
	t47.install = function(p442)
		if p442.destroyed then
			return false
		end

		getgenv().__ZeroinAntiGuard = p442
		p442:_installRagdollHooks()
		p442:_bindSignals()
		p442:_recoverBody()

		return true
	end
	t47.destroy = function(p443)
		if p443.destroyed then
			return
		end

		p443.enabled = false
		p443:_restoreLocalState()
		p443.destroyed = true
		p443._stickyToken += 1

		for _, connection4 in ipairs(p443.connections) do
			v1339(connection4)
		end

		table.clear(p443.connections)

		for k, v in pairs(p443.originalRagdoll) do
			if type(v) == "function" then
				Ragdoll[k] = v
			end
		end

		local ForestStrike = Remotes.GuardPatrol and Remotes.GuardPatrol.ForestStrike

		if ForestStrike and p443._forestStrikeOldFire and type(hookfunction) == "function" then
			pcall(hookfunction, ForestStrike.FireServer, p443._forestStrikeOldFire)
		end

		p443._forestStrikeOldFire = nil
		p443.eggRuntime = nil

		if getgenv().__ZeroinAntiGuard == p443 then
			getgenv().__ZeroinAntiGuard = nil
		end
	end
	t47.setPrimerHitWindow = function(p444, p445)
		p444.primerHitWindow = p445 == true
	end
	t47.getStats = function(p446)
		return p446.stats
	end

	return t47
end

local v1377 = v1328()

local function v1378()
	local Players2 = game:GetService("Players")
	local RunService2 = game:GetService("RunService")
	local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
	local LocalPlayer2 = Players2.LocalPlayer
	local ToolGameplayGuard = require(ReplicatedStorage2.Client.ToolGameplayGuard)
	local t49 = {}

	t49.__index = t49
	t49.new = function(p447)
		local obj = setmetatable({}, t49)

		obj.eggRuntime = p447
		obj.enabled = zeroinConfig.GodMode == nil and true or zeroinConfig.GodMode == true
		obj.active = false
		obj.activeDroppedUid = nil
		obj.swingSequence = 0
		obj.lastSwingAt = 0
		obj.defendThread = nil
		obj.connections = {}
		obj.targetRange = 13
		obj.defenseBat = nil
		obj:_bindSignals()

		return obj
	end
	t49._isBat = function(p448, p449)
		if not p449 or not p449:IsA("Tool") then
			return false
		end

		if p449:GetAttribute("IsBat") == true or p449:GetAttribute("GearName") == "Bat" then
			return true
		end

		local v1386 = string.lower(p449.Name)

		return string.find(v1386, "bat", 1, true) ~= nil or string.find(v1386, "slap", 1, true) ~= nil
	end
	t49._findBat = function(p450)
		local Character = LocalPlayer2.Character
		local Backpack = LocalPlayer2:FindFirstChildOfClass("Backpack")

		if Character then
			for _, child in ipairs(Character:GetChildren()) do
				if p450:_isBat(child) then
					return child, true
				end
			end
		end

		if Backpack then
			for _, child in ipairs(Backpack:GetChildren()) do
				if p450:_isBat(child) then
					return child, false
				end
			end
		end

		pcall(function()
			local Networking = ReplicatedStorage2:FindFirstChild("Packages") and ReplicatedStorage2.Packages:FindFirstChild("Networking")
			local RFCodexAskWearFieldBat = Networking and Networking:FindFirstChild("RF/Codex/AskWearFieldBat")

			if RFCodexAskWearFieldBat then
				RFCodexAskWearFieldBat:InvokeServer()
			end
		end)

		return nil, false
	end
	t49._equipBat = function(p451)
		local Character = LocalPlayer2.Character
		local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

		if not Humanoid or Humanoid.Health <= 0 then
			return nil
		end

		local v1397, v1398 = p451:_findBat()

		if not v1397 then
			return nil
		end

		if v1398 and v1397.Parent == Character then
			return v1397
		end

		pcall(Humanoid.EquipTool, Humanoid, v1397)

		local v1399 = os.clock() + 0.35

		while true do
			if not (os.clock() < v1399) then
				return v1397.Parent == Character and v1397 or nil
			end

			if v1397.Parent ~= Character then
				task.wait(0.05)

				continue
			end

			break
		end

		return v1397
	end
	t49._getNearbyEnemies = function(p452)
		local Character = LocalPlayer2.Character
		local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
		local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

		if not HumanoidRootPart or not Humanoid or Humanoid.Health <= 0 or not ToolGameplayGuard.IsInsideArena(LocalPlayer2) or ToolGameplayGuard.IsInsideSafeZone(LocalPlayer2) then
			return {}
		end

		local t50 = {}

		for _, player in ipairs(Players2:GetPlayers()) do
			if player ~= LocalPlayer2 and player.Character then
				local HumanoidRootPart2 = player.Character:FindFirstChild("HumanoidRootPart")
				local Humanoid2 = player.Character:FindFirstChildOfClass("Humanoid")

				if HumanoidRootPart2 and Humanoid2 and Humanoid2.Health > 0 and ToolGameplayGuard.IsInsideArena(player) and not ToolGameplayGuard.IsInsideSafeZone(player) then
					local Magnitude = (HumanoidRootPart2.Position - HumanoidRootPart.Position).Magnitude

					if Magnitude <= p452.targetRange then
						table.insert(t50, {
							player = player,
							root = HumanoidRootPart2,
							humanoid = Humanoid2,
							distance = Magnitude
						})
					end
				end
			end
		end

		table.sort(t50, function(p453, p454)
			return p453.distance < p454.distance
		end)

		return t50
	end

	local s2 = "_swing"

	local function v1410(p455, p456, p457)
		if p456 then
			if p456.Parent == LocalPlayer2.Character then
				if not p457 or not p457.Parent then
					return false
				end

				local playerFromCharacter = Players2:GetPlayerFromCharacter(p457.Parent)

				if not playerFromCharacter or playerFromCharacter == LocalPlayer2 then
					return false
				end

				local Character = LocalPlayer2.Character
				local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
				local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
				local HumanoidRootPart2 = playerFromCharacter.Character and playerFromCharacter.Character:FindFirstChild("HumanoidRootPart")
				local Humanoid2 = playerFromCharacter.Character and playerFromCharacter.Character:FindFirstChildOfClass("Humanoid")

				if not HumanoidRootPart or not Humanoid or Humanoid.Health <= 0 or not HumanoidRootPart2 or not Humanoid2 or Humanoid2.Health <= 0 or p455.targetRange < (HumanoidRootPart2.Position - HumanoidRootPart.Position).Magnitude then
					return false
				end

				if not ToolGameplayGuard.IsInsideArena(LocalPlayer2) or ToolGameplayGuard.IsInsideSafeZone(LocalPlayer2) or not ToolGameplayGuard.IsInsideArena(playerFromCharacter) or ToolGameplayGuard.IsInsideSafeZone(playerFromCharacter) then
					return false
				end

				local serverTimeNow = workspace:GetServerTimeNow()

				if not (serverTimeNow - p455.lastSwingAt < 0.75 or p456:GetAttribute("CooldownActive") == true) then
					if not (serverTimeNow < (tonumber(p456:GetAttribute("CooldownEndTime")) or 0)) then
						if not (serverTimeNow < (tonumber(LocalPlayer2:GetAttribute("RagdollEndTime")) or 0)) then
							if not (serverTimeNow < (tonumber(playerFromCharacter:GetAttribute("RagdollEndTime")) or 0)) then
								local ok, result = pcall(function()
									local BatSwing = require(ReplicatedStorage2.Shared.Remotes).BatSwing

									if BatSwing then
										if BatSwing.Trigger then
											p455.swingSequence += 1

											local v1421 = string.format("%d:%d:%d", LocalPlayer2.UserId, p455.swingSequence, math.floor(serverTimeNow * 1000))

											BatSwing.Trigger:FireServer(playerFromCharacter, v1421)

											return true
										end
									end

									return false
								end)

								if ok and result then
									p455.lastSwingAt = serverTimeNow
								end

								return ok and result == true
							end
						end
					end
				end

				return false
			end
		end

		return false
	end

	t49[s2] = v1410
	t49.startDefend = function(p458, p459)
		if not p458.enabled then
			return
		end

		if zeroinConfig.IsFusing then
			return
		end

		if p458.eggRuntime and p458.eggRuntime.instantPhase == "priming" then
			return
		end

		if #p458:_getNearbyEnemies() == 0 then
			return
		end

		p458.active = true
		p458.activeDroppedUid = p459 or p458.activeDroppedUid

		if p458.defendThread then
			return
		end

		p458.defendThread = task.spawn(function()
			while p458.active and p458.enabled and not zeroinConfig.IsFusing and not zeroinConfig.IsScrambleFarming do
				if (not p458.eggRuntime or p458.eggRuntime.instantPhase ~= "priming" and p458.eggRuntime.playerHuntToken == nil) and (not p458.eggRuntime or not p458.eggRuntime.carry or not p458.eggRuntime.carry.active) then
					local v1422 = p458:_getNearbyEnemies()

					if #v1422 ~= 0 then
						if #v1422 > 0 then
							local Tool = LocalPlayer2.Character and LocalPlayer2.Character:FindFirstChildOfClass("Tool")
							local v1424 = p458:_equipBat()

							if v1424 then
								if v1424 ~= Tool then
									p458.defenseBat = v1424
								end

								local v1425 = p458:_getNearbyEnemies()

								for _, v in ipairs(v1425) do
									if not v.root then
										continue
									end

									if v.root.Parent then
										if not p458:_swing(v1424, v.root) then
											continue
										end
									else
										continue
									end

									break
								end
							end
						end

						task.wait(0.1)

						continue
					end
				end

				break
			end

			p458.active = false
			p458.defendThread = nil

			local defenseBat = p458.defenseBat

			p458.defenseBat = nil

			local Backpack = LocalPlayer2:FindFirstChildOfClass("Backpack")

			if defenseBat then
				if defenseBat.Parent == LocalPlayer2.Character and Backpack then
					defenseBat.Parent = Backpack
				end
			end
		end)
	end
	t49.stopDefend = function(p460)
		p460.active = false
		p460.activeDroppedUid = nil
	end
	t49.setEnabled = function(p461, p462)
		p461.enabled = p462 == true

		if not p461.enabled then
			p461:stopDefend()
		end
	end
	t49._bindSignals = function(p463)
		local n23 = 0

		local function v1431(dt)
			n23 += dt

			if n23 < 0.2 then
				return
			end

			n23 = 0

			if not p463.enabled or p463.defendThread then
				return
			end

			local eggRuntime = p463.eggRuntime

			if zeroinConfig.IsFusing or zeroinConfig.IsScrambleFarming or eggRuntime and (eggRuntime.instantPhase == "priming" or eggRuntime.playerHuntToken ~= nil or eggRuntime.carry and eggRuntime.carry.active) then
				return
			end

			if #p463:_getNearbyEnemies() > 0 then
				p463:startDefend()
			end
		end

		table.insert(p463.connections, RunService2.Heartbeat:Connect(v1431))
		pcall(function()
			table.insert(p463.connections, require(ReplicatedStorage2.Client.EggState).CarryChanged:Connect(function(p464)
				if p464.IsCarrying then
					p463:stopDefend()
				elseif p463.enabled then
					p463:startDefend(p464.Uid)
				end
			end))
		end)
		pcall(function()
			local Remotes = require(ReplicatedStorage2.Shared.Remotes)
			local ForestStrike = Remotes.GuardPatrol and Remotes.GuardPatrol.ForestStrike

			if ForestStrike then
				table.insert(p463.connections, ForestStrike.OnClientEvent:Connect(function()
					if p463.enabled then
						p463:startDefend()
					end
				end))
			end
		end)
	end
	t49.destroy = function(p465)
		p465:stopDefend()

		for _, connection4 in ipairs(p465.connections) do
			pcall(connection4.Disconnect, connection4)
		end

		table.clear(p465.connections)
	end

	return t49
end

local v1437 = v1378()

local function v1438()
	local Players2 = game:GetService("Players")
	local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
	local LocalPlayer2 = Players2.LocalPlayer
	local AssetEarnings = require(ReplicatedStorage2.Shared.Util.AssetEarnings)
	local AssetItems = require(ReplicatedStorage2.Shared.Util.AssetItems)
	local Remotes = require(ReplicatedStorage2.Shared.Remotes)
	local Save = require(ReplicatedStorage2.Shared.Save)
	local Rift = Remotes.Rift
	local t51 = {
		["Riftborn Egg"] = "Verdant",
		["Riftbeasts Egg"] = "Umbral",
		["Shattered Rift Egg"] = "Radiant"
	}
	local t52 = {
		"Riftborn Egg",
		"Riftbeasts Egg",
		"Shattered Rift Egg"
	}
	local t53 = {}

	t53.__index = t53

	local function v1450(p466, p467)
		local pcall_ = pcall
		local LiveRatePerSecond = AssetEarnings.LiveRatePerSecond
		local ok, result = pcall_(LiveRatePerSecond, {
			Category = p466.Category,
			Scale = math.max(tonumber(p466.Scale) or 1, 0.01),
			Mutations = type(p466.Mutations) == "table" and p466.Mutations or {}
		}, p467 and p467.Gamepasses, p467 and p467.Products)

		return ok and type(result) == "number" and result or math.huge
	end

	t53.new = function(p468, p469, p470, p471)
		local obj = setmetatable({}, t53)

		obj.coordinator = p468
		obj.eggRuntime = p469
		obj.eggLifecycle = p470
		obj.travel = p471
		obj.destroyed = false
		obj.enabled = false
		obj.running = false
		obj.generation = 0
		obj.listeners = {}
		obj.resources = {}
		obj.state = nil
		obj.protectedUids = {}
		obj.tradeReady = false
		obj.targetPrize = nil
		obj.stats = {
			status = "Disabled",
			banner = "Unknown",
			ready = 0,
			total = 3,
			missing = "None",
			rotation = 0,
			targetPrize = "None"
		}

		local v1456 = Save.WatchFields({
			"Inventory",
			"EggInventory",
			"Rift",
			"EquippedAssets"
		}, function()
			obj:_schedule()
		end)

		if v1456 then
			table.insert(obj.resources, v1456)
		end

		if Rift.BannerRotated then
			table.insert(obj.resources, Rift.BannerRotated.OnClientEvent:Connect(function()
				obj.state = nil
				obj:_schedule()
			end))
		end

		return obj
	end
	t53._snapshot = function(p472)
		return {
			enabled = p472.enabled,
			running = p472.running,
			status = p472.stats.status,
			banner = p472.stats.banner,
			ready = p472.stats.ready,
			total = p472.stats.total,
			missing = p472.stats.missing,
			rotation = p472.stats.rotation,
			targetPrize = p472.stats.targetPrize
		}
	end
	t53._emit = function(p473)
		local v1457 = p473:_snapshot()

		for k in pairs(p473.listeners) do
			pcall(k, v1457)
		end
	end
	t53.onChanged = function(p474, p475)
		p474.listeners[p475] = true
		pcall(p475, p474:_snapshot())

		return function()
			p474.listeners[p475] = nil
		end
	end
	t53._setStatus = function(p476, p477)
		p476.stats.status = p477
		p476:_emit()
	end
	t53._askState = function(p478)
		local ok, state = pcall(function()
			return Rift.AskState:InvokeServer()
		end)

		if not ok or type(state) ~= "table" then
			return nil, tostring(state or "State unavailable")
		end

		p478.state = state
		p478.stats.banner = tostring(state.BannerDisplayName or state.BannerId or "Unknown")
		p478.stats.rotation = math.max(tonumber(state.SecondsUntilRotation) or 0, 0)

		return state
	end
	t53._petEntries = function()
		local v1461 = Save.Get()
		local Inventory = v1461 and v1461.Inventory or {}
		local t54 = {}
		local ipairs_ = ipairs
		local EquippedAssets = v1461 and v1461.EquippedAssets or {}

		for _, EquippedAsset in ipairs_(EquippedAssets) do
			t54[EquippedAsset] = true
		end

		local t55 = {}

		pcall(function()
			for k in pairs(require(ReplicatedStorage2.Client.AssetRoster).ReadOwnerPen(LocalPlayer2.UserId)) do
				t55[k] = true
			end
		end)

		local t56 = {}

		for k, v in pairs(Inventory) do
			if type(k) == "string" and type(v) == "table" then
				local ok, result = pcall(AssetItems.Decode, v)

				if ok and type(result) == "table" then
					t56[#t56 + 1] = {
						uid = k,
						item = result,
						category = result.Category,
						favorite = result.IsFavorite == true,
						equipped = t54[k] == true,
						placed = t55[k] == true,
						inFuse = result.InFuse == true,
						rate = v1450(result, v1461)
					}
				end
			end
		end

		return t56
	end
	t53._selectPets = function(p479, p480)
		local t57 = {}

		for _, v in ipairs(p479:_petEntries()) do
			if not v.favorite and not v.equipped and not v.placed and not v.inFuse then
				t57[v.category] = t57[v.category] or {}
				table.insert(t57[v.category], v)
			end
		end

		for _, v in pairs(t57) do
			table.sort(v, function(p481, p482)
				if p481.rate == p482.rate then
					return p481.uid < p482.uid
				end

				return p481.rate < p482.rate
			end)
		end

		local t58 = {}
		local t59 = {}
		local t60 = {}

		for i, v in ipairs(p480) do
			local v1485
			local ipairs_ = ipairs
			local v1487 = t57[v] or {}

			for _, v2 in ipairs_(v1487) do
				if not t58[v2.uid] then
					v1485 = v2

					break
				end
			end

			if v1485 then
				t58[v1485.uid] = true
				t59[i] = v1485
			else
				t60[#t60 + 1] = v
			end
		end

		return t59, t60
	end
	t53.getPrizeOptions = function()
		return table.clone(t52)
	end
	t53.getTargetPrize = function(p483)
		return p483.targetPrize
	end
	t53.setTargetPrize = function(p484, p485)
		local v1490

		if type(p485) == "string" and t51[p485] then
			v1490 = p485
		end

		if p484.targetPrize ~= v1490 then
			p484.targetPrize = v1490
			p484.stats.targetPrize = v1490 or "None"
			p484.generation += 1

			if p484.enabled then
				p484:_schedule()
			else
				p484:_emit()
			end
		end
	end
	t53.isTradeReady = function(p486)
		return not p486.destroyed and p486.enabled and p486.tradeReady == true
	end
	t53.isPlacePending = function(p487)
		if p487.destroyed or not p487.enabled then
			return false
		end

		local state = p487.state
		local Requirements = state and state.Requirements

		if type(Requirements) ~= "table" or #Requirements == 0 then
			return false
		end

		local v1493 = Save.Get()
		local EggInventory = v1493 and v1493.EggInventory

		if type(EggInventory) ~= "table" then
			return false
		end

		local t61 = {}

		for _, Requirement in ipairs(Requirements) do
			t61[Requirement] = true
		end

		local n24 = 0
		local n25 = 0

		for _, v in pairs(EggInventory) do
			if type(v) == "table" and type(v.AssetCategory) == "string" then
				if v.Placement ~= nil then
					n24 += 1
				elseif t61[v.AssetCategory] then
					n25 += 1
				end
			end
		end

		if n25 == 0 then
			return false
		end

		local n26 = 0

		pcall(function()
			n26 = require(ReplicatedStorage2.Data.Bases).GetAssetEquipCapacity(v1493 and v1493.BaseUpgradeLevel or 0)
		end)

		return n24 < n26
	end
	t53._unhatchedCountByCategory = function()
		local t62 = {}
		local v1504 = Save.Get()
		local pairs_ = pairs
		local EggInventory = v1504 and v1504.EggInventory or {}

		for k, v in pairs_(EggInventory) do
			if type(k) == "string" and type(v) == "table" and type(v.AssetCategory) == "string" then
				t62[v.AssetCategory] = (t62[v.AssetCategory] or 0) + 1
			end
		end

		return t62
	end
	t53._objectiveCategories = function(p488, p489, p490)
		local t63 = {}
		local t64 = {}
		local v1511 = p488:_unhatchedCountByCategory()

		for i, v in ipairs(p489) do
			if not p490[i] then
				local v1514 = v1511[v] or 0

				if v1514 > 0 then
					v1511[v] = v1514 - 1
				elseif not t64[v] then
					t64[v] = true
					t63[#t63 + 1] = v
				end
			end
		end

		return t63
	end
	t53._protectedObjectiveUids = function(p491, p492, p493)
		local t65 = {}

		for _, v in pairs(p493) do
			t65[#t65 + 1] = v.uid
		end

		local t66 = {}

		for i, v in ipairs(p492) do
			if not p493[i] then
				t66[v] = (t66[v] or 0) + 1
			end
		end

		local v1521 = Save.Get()
		local pairs_ = pairs
		local EggInventory = v1521 and v1521.EggInventory or {}

		for k, v in pairs_(EggInventory) do
			if type(k) == "string" and type(v) == "table" then
				if (t66[v.AssetCategory] or 0) > 0 then
					t65[#t65 + 1] = k

					local AssetCategory = v.AssetCategory

					t66[AssetCategory] -= 1
				end
			end
		end

		return t65
	end
	t53._travelToMachine = function(p494, p495)
		local __OBJECTS = workspace:FindFirstChild("__OBJECTS")
		local Machines = __OBJECTS and __OBJECTS:FindFirstChild("Machines")
		local RiftMachine = Machines and Machines:FindFirstChild("RiftMachine")
		local Machine = RiftMachine and RiftMachine:FindFirstChild("Machine")

		if not Machine or not Machine:IsA("BasePart") then
			return false, "Rift machine unavailable"
		end

		local Character = LocalPlayer2.Character
		local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
		local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

		if not HumanoidRootPart or not Humanoid then
			return false, "Character unavailable"
		end

		local v1534 = Machine.CFrame * cFrameNew(0, Machine.Size.Y * 0.5 + (HumanoidRootPart.Size.Y * 0.5 + (Humanoid.RigType == Enum.HumanoidRigType.R15 and math.max(Humanoid.HipHeight, 0.5) or 2)) + 0.05, 4)

		if (HumanoidRootPart.Position - v1534.Position).Magnitude <= 7 then
			return true
		end

		if p494.travel then
			return p494.travel:travelAndWait(v1534, {
				abort = function()
					return p494.destroyed or not p494.enabled or p495 ~= p494.generation
				end
			}), "Travel interrupted"
		end

		return false, "Travel unavailable"
	end
	t53._finishPendingReward = function(p496, p497)
		p496:_setStatus("Finishing Rift reward")
		task.wait(0.8)

		if p496.destroyed or not p496.enabled or p497 ~= p496.generation then
			return false
		end

		local ok, result = pcall(function()
			return Rift.AskFinishReveal:InvokeServer()
		end)

		return ok and result ~= false
	end
	t53._trade = function(p498, p499, p500, p501)
		if p498.eggRuntime then
			if type(p498.eggRuntime.hasPendingPreEventSteal) == "function" then
				if p498.eggRuntime:hasPendingPreEventSteal() then
					return false, "Waiting for priority egg delivery"
				end
			end
		end

		local t67 = {}

		for i = 1, #p499 do
			local v1539 = p500[i]

			if not v1539 then
				return false, "Requirements incomplete"
			end

			t67[#t67 + 1] = v1539.uid
		end

		local autoTheRift, v1541 = p498.coordinator:tryAcquire("auto_the_rift", t67)

		if not autoTheRift then
			return false, v1541
		end

		local function v1542()
			p498.coordinator:release(autoTheRift)
		end

		local v1543, v1544 = p498:_travelToMachine(p501)

		if not v1543 then
			v1542()

			return false, v1544
		end

		local v1545, v1546 = p498:_askState()

		if not v1545 then
			v1542()

			return false, v1546
		end

		for i, v in ipairs(p499) do
			if v1545.Requirements[i] ~= v then
				v1542()

				return false, "Requirements rotated"
			end
		end

		local v1549 = Save.Get()

		for i, v in ipairs(t67) do
			local ok, result = pcall(AssetItems.Decode, v1549 and v1549.Inventory and v1549.Inventory[v])

			if not ok then
				v1542()

				return false, "Protected pet changed"
			end

			if type(result) ~= "table" or result.Category ~= p499[i] or result.IsFavorite == true or result.InFuse == true then
				v1542()

				return false, "Protected pet changed"
			end
		end

		p498:_setStatus("Trading Rift pets")

		local ok, result, result2 = pcall(function()
			return Rift.AskTradeIn:InvokeServer(t67)
		end)

		if not ok or result ~= true then
			v1542()

			return false, tostring(result2 or result or "Trade rejected")
		end

		local v1557 = os.clock() + 8

		while not p498.destroyed and p498.enabled and p501 == p498.generation and os.clock() < v1557 do
			local v1558 = Save.Get()
			local v1559 = true

			for _, v in ipairs(t67) do
				if v1558 and v1558.Inventory and v1558.Inventory[v] ~= nil then
					v1559 = false

					break
				end
			end

			if not v1559 then
				task.wait(0.1)

				continue
			end

			break
		end

		local v1562 = Save.Get()

		for _, v in ipairs(t67) do
			if v1562 and v1562.Inventory and v1562.Inventory[v] ~= nil then
				v1542()

				return false, "Trade confirmation timed out"
			end
		end

		v1542()
		p498:_finishPendingReward(p501)

		return true
	end
	t53._isCategoryOnField = function(p502, p503)
		if not p502.eggRuntime or not p502.eggRuntime.records then
			return false
		end

		for _, record in pairs(p502.eggRuntime.records) do
			local v1567 = record.State == 1 or record.State == 2

			if (v1567 or record.State == "Slot" or record.State == "Dropped") and record.AssetCategory == p503 then
				return true
			end
		end

		return false
	end
	t53._run = function(p504, p505)
		if p504.running then
			return
		end

		p504.running = true

		while not p504.destroyed and p504.enabled do
			if p505 ~= p504.generation then
				break
			end

			local v1568, v1569 = p504:_askState()

			if not v1568 then
				p504:_setStatus("Rift state: " .. tostring(v1569))
				task.wait(1)
			elseif v1568.Unlocked == false then
				p504:_setStatus("The Rift is locked")
				task.wait(2)
			elseif v1568.PendingReward then
				p504:_finishPendingReward(p505)
				task.wait(0.5)
			else
				local targetPrize = p504.targetPrize and t51[p504.targetPrize] or nil
				local RequirementsBannerId = v1568.RequirementsBannerId or v1568.BannerId

				if targetPrize and RequirementsBannerId and RequirementsBannerId ~= targetPrize then
					p504.tradeReady = false
					p504.eggRuntime:setRiftObjective(false, {})
					p504.eggLifecycle:setRiftObjective(false, {})
					p504.coordinator:clearProtected("auto_the_rift")
					p504.protectedUids = {}
					p504:_setStatus(string.format("Waiting for %s (Current: %s)", p504.targetPrize, p504.stats.banner))
					p504:_emit()
					task.wait(1)
				else
					local Requirements = type(v1568.Requirements) == "table" and v1568.Requirements

					Requirements = Requirements or {}
					p504.stats.total = #Requirements

					if #Requirements < 3 then
						p504:_setStatus("Waiting for Rift requirements")
						task.wait(1)
					else
						local v1573, v1574 = p504:_selectPets(Requirements)

						p504.stats.ready = #Requirements - #v1574
						p504.stats.missing = #v1574 > 0 and table.concat(v1574, ", ") or "None"

						local v1575 = p504:_objectiveCategories(Requirements, v1573)
						local v1576 = p504:_protectedObjectiveUids(Requirements, v1573)

						p504.protectedUids = v1576
						p504.coordinator:setProtected("auto_the_rift", v1576)
						p504.coordinator:setProtectedCategories("auto_the_rift", Requirements)

						local tradeReady = #v1574 == 0

						p504.tradeReady = tradeReady
						p504.eggRuntime:setRiftObjective(not tradeReady and #v1575 > 0, v1575)
						p504.eggLifecycle:setRiftObjective(not tradeReady, Requirements)

						if tradeReady then
							p504.eggRuntime:setRiftObjective(false, {})

							local v1578, v1579 = p504:_trade(Requirements, v1573, p505)

							p504.tradeReady = false
							p504:_setStatus(v1578 and "Rift trade complete" or "Rift trade: " .. tostring(v1579))
						elseif #v1575 > 0 then
							local v1580 = v1575[1]

							if p504:_isCategoryOnField(v1580) then
								p504:_setStatus("Stealing: " .. tostring(v1580) .. " egg")
							else
								p504:_setStatus("Waiting for " .. tostring(v1580) .. " to spawn")
							end
						else
							p504:_setStatus("Waiting for eggs to hatch")
						end

						p504:_emit()
						task.wait(0.5)
					end
				end
			end
		end

		p504.running = false
	end
	t53._schedule = function(p506)
		if p506.destroyed or not p506.enabled or p506.running then
			return
		end

		local generation = p506.generation

		task.defer(function()
			local ok, result = pcall(p506._run, p506, generation)

			if not ok and not p506.destroyed and p506.enabled then
				if generation == p506.generation then
					p506.running = false
					p506:_setStatus("Rift error: " .. tostring(result))
					task.delay(2, function()
						if not p506.destroyed and p506.enabled and generation == p506.generation then
							p506:_schedule()
						end
					end)
				end
			end
		end)
	end
	t53.setEnabled = function(p507, p508)
		p507.enabled = p508 == true
		p507.generation += 1

		if p507.enabled then
			p507:_setStatus("Reading Rift requirements")
			p507:_schedule()
		else
			p507.tradeReady = false
			p507.eggRuntime:setRiftObjective(false, {})
			p507.eggLifecycle:setRiftObjective(false, {})
			p507.coordinator:clearProtected("auto_the_rift")
			p507.protectedUids = {}
			p507:_setStatus("Disabled")
		end
	end
	t53.destroy = function(p509)
		if p509.destroyed then
			return
		end

		p509.destroyed = true
		p509.enabled = false
		p509.tradeReady = false
		p509.generation += 1
		p509.eggRuntime:setRiftObjective(false, {})
		p509.eggLifecycle:setRiftObjective(false, {})
		p509.coordinator:clearProtected("auto_the_rift")

		for _, resource in ipairs(p509.resources) do
			pcall(function()
				if typeof(resource) == "RBXScriptConnection" then
					resource:Disconnect()
				elseif type(resource) == "function" then
					resource()
				elseif type(resource) == "table" and type(resource.Disconnect) == "function" then
					resource:Disconnect()
				end
			end)
		end

		table.clear(p509.resources)
		table.clear(p509.listeners)
	end

	return t53
end

local v1586 = v1438()

local function v1587()
	local Players2 = game:GetService("Players")
	local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
	local RunService2 = game:GetService("RunService")
	local Workspace2 = game:GetService("Workspace")
	local LocalPlayer2 = Players2.LocalPlayer
	local Remotes = require(ReplicatedStorage2.Shared.Remotes)
	local Scramble = Remotes.Scramble
	local EggWorld = Remotes.EggWorld
	local ScrambleMotion = require(ReplicatedStorage2.Shared.Util.ScrambleMotion)
	local Save = require(ReplicatedStorage2.Shared.Save)
	local Gears = require(ReplicatedStorage2.Data.Gears)
	local t68 = {
		ScrapDrone = "Scrap Drone",
		ReactorDrone = "Reactor Drone",
		AugmentedDrone = "Augmented Drone"
	}
	local t69 = {
		Scrambled = "MutationConsumable",
		["Experiment #001"] = "LimitedTimeExperimentPet",
		["Nibbles #013"] = "Nibbles013",
		["2x Cash Booster"] = "CashBooster",
		["1.25x Speed"] = "SpeedBoost",
		["2x Treadmill Booster"] = "TreadmillBooster"
	}
	local t70 = {}

	t70.__index = t70

	local getgc_ = getgc
	local debug_ = debug

	local function v1604(p510)
		return p510
	end

	local v1605 = v1604(function()
		if type(getgc_) == "function" then
			if type(debug_) == "table" and type(debug.info) == "function" then
				if type(debug.getupvalues) == "function" then
					local u1606
					local t71 = {}
					local t72 = {}
					local n27 = 0

					local function v1610(p511, p512)
						if not (type(p511) ~= "table" or t72[p511]) then
							if not (p512 > 4) and not (n27 >= 1200) then
								t72[p511] = true
								n27 += 1

								if rawget(p511, "EventId") == "DrScrambleOutbreak" and type(rawget(p511, "Shop")) == "table" then
									u1606 = p511
								end

								if type(rawget(p511, "Upserts")) == "table" then
									t71[#t71 + 1] = p511

									return
								end

								if rawget(p511, "Id") ~= nil and typeof(rawget(p511, "CFrame")) == "CFrame" and tonumber(rawget(p511, "Health")) then
									t71[#t71 + 1] = {
										Upserts = { p511 }
									}

									return
								end

								for _, v in pairs(p511) do
									if type(v) == "table" then
										v1610(v, p512 + 1)
									end
								end

								return
							end
						end
					end

					local ok, result = pcall(getgc_, true)

					if not ok or type(result) ~= "table" then
						return nil, {}
					end

					for _, v in ipairs(result) do
						if type(v) == "function" then
							local ok2, result2 = pcall(debug.info, v, "s")

							if (ok2 and type(result2) == "string" and result2:lower() or ""):find("scrambleclient", 1, true) then
								local ok3, result3 = pcall(debug.getupvalues, v)

								if ok3 and type(result3) == "table" then
									for _, v2 in pairs(result3) do
										v1610(v2, 0)
									end
								end
							end
						end

						if u1606 and #t71 > 0 then
							break
						end
					end

					return u1606, t71
				end
			end
		end

		return nil, {}
	end)

	t70.new = function(p513)
		local obj = setmetatable({}, t70)

		obj.eggRuntime = p513
		obj.enabled = false
		obj.destroyed = false
		obj.generation = 0
		obj.droneCache = {}
		obj.context = nil
		obj.nextBootstrapAt = 0
		obj.cachedRoute = nil
		obj.lastVisualScanAt = 0
		obj.nextPriorityEggCheckAt = 0
		obj.priorityEggsCached = false
		obj.lockConnection = nil
		obj.lockHumanoid = nil
		obj.lockAutoRotate = nil
		obj.locked = false
		obj.lockedTargetKey = nil
		obj.stickyTargetKey = nil
		obj.batGearIds = {}
		obj.batIndex = 1
		obj.lastBatRefreshAt = 0
		obj.lastBatSwapAt = 0
		obj.worker = nil
		obj.stats = {
			status = "Off"
		}
		obj.autoBuy = false
		obj.shopItems = {}
		obj.shopAmount = 1
		obj.shopInterval = 15
		obj.nextShopCycleAt = 0
		obj.shopStatus = "Off"
		obj.shopPurchases = {}
		obj.lastShopRequestAt = 0
		obj.lastShopSignature = nil
		obj.connections = {}

		if Scramble and Scramble.State then
			table.insert(obj.connections, Scramble.State.OnClientEvent:Connect(function(p514)
				if type(p514) == "table" and p514.EventId == "DrScrambleOutbreak" then
					obj.context = p514

					if type(p514.Drones) == "table" then
						obj:_applyDronePacket(p514.Drones)
					end
				end

				if obj.enabled and obj.eggRuntime and type(obj.eggRuntime._schedule) == "function" then
					task.defer(function()
						obj.eggRuntime:_schedule()
					end)
				end
			end))
		end

		if Scramble and Scramble.Drones then
			table.insert(obj.connections, Scramble.Drones.OnClientEvent:Connect(function(...)
				for i = 1, select("#", ...) do
					obj:_applyDronePacket(select(i, ...))
				end

				if obj.enabled and obj.eggRuntime and type(obj.eggRuntime._schedule) == "function" then
					task.defer(function()
						obj.eggRuntime:_schedule()
					end)
				end
			end))
		end

		obj:_refreshBatGearIds(true)
		obj:_ensureWorker()

		return obj
	end
	t70._setStatus = function(p515, p516)
		p515.stats.status = p516
		genv.__ZeroinScrambleStatus = p515:getSnapshot()
	end
	t70._snapshot = function(p517)
		return p517:_resolveClientContext()
	end
	t70._bootstrapClientState = function(p518, p519)
		if p519 ~= true and os.clock() < p518.nextBootstrapAt then
			return
		end

		p518.nextBootstrapAt = os.clock() + 30

		local v1625, v1626 = v1605()

		if type(v1625) == "table" then
			p518.context = v1625
		end

		local ipairs_ = ipairs
		local v1628 = type(v1626) == "table" and v1626 or {}

		for _, v in ipairs_(v1628) do
			p518:_applyDronePacket(v)
		end
	end
	t70._resolveClientContext = function(p520)
		if type(p520.context) == "table" and type(p520.context.Shop) == "table" then
			return p520.context
		end

		p520:_bootstrapClientState(false)

		return p520.context
	end
	t70._refreshBatGearIds = function(p521, p522)
		if p522 ~= true and os.clock() - p521.lastBatRefreshAt < 2 then
			return
		end

		p521.lastBatRefreshAt = os.clock()

		local GearInventory = (Save.Get() or {}).GearInventory or {}
		local batGearIds = {}

		for k, v in pairs(GearInventory) do
			local Directory = Gears.Directory and Gears.Directory[k] or Gears[k]

			if tostring(k):lower():find("bat", 1, true) ~= nil or type(Directory) == "table" and Directory.ToolController == "Slap" then
				if (tonumber(v) or 0) > 0 then
					batGearIds[#batGearIds + 1] = k
				end
			end
		end

		table.sort(batGearIds)
		p521.batGearIds = batGearIds

		if p521.batIndex > #batGearIds then
			p521.batIndex = 1
		end
	end
	t70._equippedBat = function(p523)
		local Character = LocalPlayer2.Character

		if not Character then
			return nil
		end

		for _, child in ipairs(Character:GetChildren()) do
			if child:IsA("Tool") then
				local attribute = child:GetAttribute("GearName")
				local Directory = attribute and (Gears.Directory and Gears.Directory[attribute] or Gears[attribute])

				if not table.find(p523.batGearIds, attribute) then
					continue
				end

				if not Directory then
					continue
				end

				if Directory.ToolController == "Slap" then
					return child
				end
			end
		end

		return nil
	end
	t70._rotateBatIfNeeded = function(p524)
		p524:_refreshBatGearIds(false)

		local v1641 = #p524.batGearIds

		if v1641 == 0 then
			return
		end

		local v1642 = p524:_equippedBat()

		if not v1642 then
			if os.clock() - p524.lastBatSwapAt >= 0.12 and EggWorld and EggWorld.AskWearTool then
				p524.lastBatSwapAt = os.clock()
				pcall(EggWorld.AskWearTool.InvokeServer, EggWorld.AskWearTool, p524.batGearIds[p524.batIndex] or p524.batGearIds[1])
			end

			return
		end

		if v1641 == 1 then
			return
		end

		local serverTimeNow = Workspace2:GetServerTimeNow()
		local v1644 = v1642:GetAttribute("CooldownActive") == true

		if not v1644 then
			v1644 = (tonumber(v1642:GetAttribute("CooldownEndTime")) or 0) > serverTimeNow
		end

		if not v1644 or os.clock() - p524.lastBatSwapAt < 0.12 then
			return
		end

		p524.lastBatSwapAt = os.clock()
		p524.batIndex = p524.batIndex % v1641 + 1

		if EggWorld and EggWorld.AskWearTool then
			pcall(EggWorld.AskWearTool.InvokeServer, EggWorld.AskWearTool, p524.batGearIds[p524.batIndex])
		end
	end
	t70._ensureBatEquipped = function(p525, p526)
		p525:_refreshBatGearIds(true)

		if #p525.batGearIds == 0 then
			return false
		end

		if p525:_equippedBat() then
			return true
		end

		if not EggWorld or not EggWorld.AskWearTool then
			return false
		end

		pcall(EggWorld.AskWearTool.InvokeServer, EggWorld.AskWearTool, p525.batGearIds[p525.batIndex] or p525.batGearIds[1])

		local v1645 = os.clock() + math.max(tonumber(p526) or 0.75, 0)

		repeat
			if p525:_equippedBat() then
				return true
			end

			task.wait(0.05)
		until p525.destroyed or not p525.enabled or v1645 <= os.clock()

		return false
	end
	t70._eventWindowActive = function(p527, p528)
		local serverTimeNow = Workspace2:GetServerTimeNow()
		local v1647 = Workspace2:GetAttribute("ScrambleOutbreakActive") == true
		local v1648 = tonumber(Workspace2:GetAttribute("ScrambleOutbreakEndsAt")) or 0
		local v1649 = tonumber(Workspace2:GetAttribute("ScrambleActiveDrones")) or 0

		if v1647 and (v1648 <= 0 or serverTimeNow < v1648) then
			return true
		end

		if v1649 > 0 and (v1648 <= 0 or serverTimeNow < v1648) then
			return true
		end

		local v1650 = p528 or p527:_resolveClientContext()

		if type(v1650) ~= "table" or v1650.Ready ~= true or v1650.Enabled ~= true or v1650.WorldReady ~= true then
			return false
		end

		if tonumber(v1650.EventEndsAt) and v1650.EventEndsAt <= serverTimeNow then
			return false
		end

		return type(v1650.Window) == "table" and v1650.Window.Active == true
	end
	t70._hasPriorityEggs = function(p529, p530)
		if p530 == true or p529.nextPriorityEggCheckAt <= os.clock() then
			p529.nextPriorityEggCheckAt = os.clock() + 0.4
			p529.priorityEggsCached = p529.eggRuntime and type(p529.eggRuntime.hasDrPriorityEggsAuthoritative) == "function" and p529.eggRuntime:hasDrPriorityEggsAuthoritative() == true or false
		end

		return p529.priorityEggsCached
	end
	t70._applyDronePacket = function(p531, p532)
		if type(p532) ~= "table" then
			return
		end

		local v1651 = type(p532.Upserts) == "table" and p532 or type(p532[1]) == "table" and p532[1] or nil

		if not v1651 or type(v1651.Upserts) ~= "table" then
			return
		end

		for _, upsert in pairs(v1651.Upserts) do
			if type(upsert) == "table" then
				local Id = upsert.Id or upsert.id

				if Id ~= nil then
					p531.droneCache[tostring(Id)] = upsert
				end
			end
		end

		local pairs_ = pairs
		local Removed = type(v1651.Removed) == "table" and v1651.Removed or {}

		for _, v in pairs_(Removed) do
			p531.droneCache[tostring(type(v) == "table" and (v.Id or v.id) or v)] = nil
		end

		p531.cachedRoute = nil
	end

	local function v1659(p533)
		if type(p533) == "table" then
			return tonumber(p533.Health or p533.health or p533.HP or p533.Hp or p533.hp), tonumber(p533.MaxHealth or p533.maxHealth or p533.MaxHP or p533.maxHp)
		end

		return nil, nil
	end
	local function v1660(p534)
		local Attributes = type(p534) == "table" and p534.Attributes or nil
		local v1662 = type(p534) == "table"

		if v1662 then
			v1662 = p534.ScrambleTier or p534.Tier or p534.DroneTier
			v1662 = v1662 or type(Attributes) == "table" and (Attributes.ScrambleTier or Attributes.Tier)
		end

		return v1662 or nil
	end
	local function v1663(p535)
		local v1664 = tonumber(p535.maxHealth) or tonumber(p535.health) or 0

		if v1664 >= 10 then
			return 1
		end

		if v1664 >= 5 then
			return 2
		end

		return 3
	end
	local function v1665(p536)
		local Id = p536.Id or p536.id or p536.Uid or p536.uid or p536.DroneId or p536.droneId

		return Id ~= nil and "state:" .. tostring(Id) or "state-table:" .. tostring(p536)
	end

	t70._candidateFromState = function(p537, p538)
		if type(p538) ~= "table" then
			return nil
		end

		local v1667, v1668 = v1659(p538)

		if not v1667 or v1667 <= 0 then
			return nil
		end

		local CFrame_2 = typeof(p538.CFrame) == "CFrame" and p538.CFrame or typeof(p538.Position) == "Vector3" and cFrameNew(p538.Position)
		local Size = typeof(p538.Size) == "Vector3" and p538.Size or nil

		if not CFrame_2 then
			local ok, result = pcall(ScrambleMotion.Read, p538)

			if ok and type(result) == "table" then
				CFrame_2 = typeof(result.CFrame) == "CFrame" and result.CFrame or typeof(result.Position) == "Vector3" and cFrameNew(result.Position)

				local Size2 = typeof(result.Size) == "Vector3" and result.Size

				Size = Size2 or Size
			end
		end

		if not CFrame_2 or CFrame_2.Position.Y < 0 then
			return nil
		end

		return {
			key = v1665(p538),
			cframe = CFrame_2,
			radius = Size and math.max(Size.X, Size.Z) * 0.5 or 2,
			health = v1667,
			maxHealth = v1668,
			tier = v1660(p538),
			source = p538
		}
	end
	t70._visualCandidates = function(p539)
		local t73 = {}

		if os.clock() - p539.lastVisualScanAt < 1 then
			return t73
		end

		p539.lastVisualScanAt = os.clock()

		local ScrambleLocalVisuals = Workspace2:FindFirstChild("ScrambleLocalVisuals")

		if not ScrambleLocalVisuals then
			return t73
		end

		for _, child in ipairs(ScrambleLocalVisuals:GetChildren()) do
			local Hitbox = child:IsA("BasePart") and child.Name == "Hitbox" and child or child:IsA("Model") and child:FindFirstChild("Hitbox", true)
			local v1679 = Hitbox and tonumber(Hitbox:GetAttribute("Health"))

			if Hitbox and Hitbox:IsA("BasePart") and v1679 and v1679 > 0 and Hitbox.Position.Y >= 0 then
				t73[#t73 + 1] = {
					key = "visual:" .. tostring(child:GetAttribute("Id") or child:GetAttribute("DroneId") or child.Name),
					cframe = Hitbox.CFrame,
					radius = math.max(Hitbox.Size.X, Hitbox.Size.Z) * 0.5,
					health = v1679,
					maxHealth = tonumber(Hitbox:GetAttribute("MaxHealth")) or tonumber(Hitbox:GetAttribute("MaxHP")),
					tier = Hitbox:GetAttribute("ScrambleTier") or child:GetAttribute("ScrambleTier"),
					instance = Hitbox
				}
			end
		end

		return t73
	end
	t70.projectGroundPosition = function(p540, p541)
		local Character = LocalPlayer2.Character
		local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
		local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

		if not Character or not Humanoid or not HumanoidRootPart then
			return nil
		end

		local filterDescendantsInstances = { Character }

		for _, player in ipairs(Players2:GetPlayers()) do
			if player.Character and player.Character ~= Character then
				filterDescendantsInstances[#filterDescendantsInstances + 1] = player.Character
			end
		end

		for _, v in ipairs({
			"ScrambleLocalVisuals",
			"__ClientTreadmillRenders"
		}) do
			local v1688 = Workspace2:FindFirstChild(v)

			if v1688 then
				filterDescendantsInstances[#filterDescendantsInstances + 1] = v1688
			end
		end

		for _, child in ipairs(Workspace2:GetChildren()) do
			if child:IsA("BasePart") and child.Name == "__FyyHoverPad" then
				filterDescendantsInstances[#filterDescendantsInstances + 1] = child
			end
		end

		local raycastParams = RaycastParams.new()

		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = filterDescendantsInstances
		raycastParams.IgnoreWater = false

		local vector32 = Vector3.new(p541.X, math.max(p541.Y, HumanoidRootPart.Position.Y) + 64, p541.Z)
		local vector33 = Vector3.new(0, -256, 0)
		local hit

		for i = 1, 12 do
			hit = Workspace2:Raycast(vector32, vector33, raycastParams)

			if not hit then
				break
			end

			local Model = hit.Instance:FindFirstAncestorOfClass("Model")

			if not (Model and Model:FindFirstChildOfClass("Humanoid") ~= nil) and (hit.Instance:IsA("Terrain") or hit.Instance:IsA("BasePart") and hit.Instance.CanCollide) then
				break
			end

			filterDescendantsInstances[#filterDescendantsInstances + 1] = hit.Instance
			raycastParams.FilterDescendantsInstances = filterDescendantsInstances
			hit = nil
		end

		if hit then
			return (Vector3.new(p541.X, hit.Position.Y + (HumanoidRootPart.Size.Y * 0.5 + (Humanoid.RigType == Enum.HumanoidRigType.R15 and math.max(Humanoid.HipHeight, 0.5) or 2)) + 0.05, p541.Z))
		end

		return nil
	end
	t70._groundedDestination = function(p542, p543, p544)
		local v1697 = p542:projectGroundPosition(p543)

		if not v1697 then
			return nil
		end

		local vector32 = Vector3.new(p544.X, v1697.Y, p544.Z)

		if (vector32 - v1697).Magnitude <= 0.001 then
			return cFrameNew(v1697)
		end

		return lookAt(v1697, vector32)
	end
	t70._routeForKey = function(p545, p546, p547)
		if type(p546) ~= "string" then
			return nil
		end

		local cachedRoute

		if p546:sub(1, 6) == "state:" then
			cachedRoute = p545:_candidateFromState(p545.droneCache[p546:sub(7)])
		elseif p545.cachedRoute and p545.cachedRoute.key == p546 then
			cachedRoute = p545.cachedRoute

			if cachedRoute.instance and cachedRoute.instance.Parent then
				cachedRoute.cframe = cachedRoute.instance.CFrame
				cachedRoute.health = tonumber(cachedRoute.instance:GetAttribute("Health")) or cachedRoute.health
			end
		end

		if not cachedRoute or cachedRoute.health <= 0 then
			return nil
		end

		local Position = cachedRoute.cframe.Position
		local vector32 = Vector3.new(p547.Position.X - Position.X, 0, p547.Position.Z - Position.Z)

		cachedRoute.destination = p545:_groundedDestination(Position + (vector32.Magnitude > 0.001 and vector32.Unit or Vector3.new(0, 0, 1)) * (cachedRoute.radius + 0.7), Position, p547)

		if cachedRoute.destination then
			return cachedRoute
		end

		return nil
	end
	t70._nearestRoute = function(p548, p549)
		local HumanoidRootPart = LocalPlayer2.Character and LocalPlayer2.Character:FindFirstChild("HumanoidRootPart")

		if not HumanoidRootPart then
			return nil
		end

		if not p549 and p548.stickyTargetKey then
			local v1703 = p548:_routeForKey(p548.stickyTargetKey, HumanoidRootPart)

			if v1703 then
				p548.cachedRoute = v1703

				return v1703
			end

			p548.stickyTargetKey = nil
		end

		if not p549 and p548.cachedRoute then
			local v1704 = p548:_routeForKey(p548.cachedRoute.key, HumanoidRootPart)

			if v1704 then
				return v1704
			end
		end

		local t74 = {}

		for _, v in pairs(p548.droneCache) do
			local v1708 = p548:_candidateFromState(v)

			if v1708 then
				t74[#t74 + 1] = v1708
			end
		end

		if #t74 == 0 then
			for _, v in ipairs(p548:_visualCandidates()) do
				t74[#t74 + 1] = v
			end
		end

		local v1711
		local v1712
		local v1713

		for _, v in ipairs(t74) do
			local v1716 = v1663(v)
			local Magnitude = (HumanoidRootPart.Position - v.cframe.Position).Magnitude

			if v1713 and not (v1716 < v1713) then
				if v1716 ~= v1713 then
					continue
				end

				if not (Magnitude < v1712) then
					continue
				end
			end

			v1711 = v
			v1712 = Magnitude
			v1713 = v1716
		end

		if not v1711 then
			p548.cachedRoute = nil

			return nil
		end

		p548.stickyTargetKey = v1711.key
		p548.cachedRoute = v1711

		return p548:_routeForKey(v1711.key, HumanoidRootPart)
	end
	t70.isEventWindowActive = function(p550)
		return not p550.destroyed and p550.enabled and p550:_eventWindowActive()
	end
	t70.isEngaged = function(p551)
		return p551:isEventWindowActive() and p551:_nearestRoute() ~= nil
	end
	t70.getEventRoute = function(p552)
		if not p552.destroyed and p552.enabled and not p552:_hasPriorityEggs() and p552:_eventWindowActive() then
			return p552:_nearestRoute()
		end

		return nil
	end
	t70._releaseLock = function(p553)
		local locked = p553.locked or p553.lockConnection ~= nil or p553.lockHumanoid ~= nil

		if p553.lockConnection then
			pcall(p553.lockConnection.Disconnect, p553.lockConnection)
			p553.lockConnection = nil
		end

		local lockHumanoid = p553.lockHumanoid or locked and LocalPlayer2.Character and LocalPlayer2.Character:FindFirstChildOfClass("Humanoid")

		if lockHumanoid and lockHumanoid.Parent and locked then
			local lockAutoRotate = p553.lockAutoRotate

			if lockAutoRotate == nil then
				lockAutoRotate = true
			end

			pcall(function()
				lockHumanoid.AutoRotate = lockAutoRotate
			end)
		end

		p553.lockHumanoid = nil
		p553.lockAutoRotate = nil
		p553.locked = false
		p553.lockedTargetKey = nil
		zeroinConfig.IsScrambleFarming = false

		if p553.eggRuntime and type(p553.eggRuntime._stopHoverPad) == "function" then
			p553.eggRuntime:_stopHoverPad()
		end
	end
	t70.releaseEventLock = function(p554)
		p554:_releaseLock()
	end
	t70.getGeneration = function(p555)
		return p555.generation
	end
	t70.lockAfterSharedTravel = function(p556, p557)
		if not p556.destroyed then
			if p556.enabled and p557 == p556.generation and not p556:_hasPriorityEggs() then
				p556:_releaseLock()

				local v1721 = p556:_nearestRoute()

				if not v1721 then
					return false
				end

				if not p556:_ensureBatEquipped(0.75) then
					p556.stats.status = "Waiting for Slap tool"

					return false
				end

				local Character = LocalPlayer2.Character
				local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

				if not Humanoid or Humanoid.Health <= 0 then
					return false
				end

				p556.lockHumanoid = Humanoid
				p556.lockAutoRotate = Humanoid.AutoRotate
				p556.locked = true
				p556.lockedTargetKey = v1721.key
				zeroinConfig.IsScrambleFarming = true
				p556.stats.status = string.format("Locked to %s · 0.7 stud", tostring(t68[v1721.tier] or v1721.tier or "drone"))
				p556.lockConnection = RunService2.PreSimulation:Connect(function()
					if not p556.destroyed and p556.enabled and p557 == p556.generation and p556:_eventWindowActive() then
						if p556.eggRuntime:isResetWallOpen() then
							if p556:_hasPriorityEggs() then
								p556:_releaseLock()

								if p556.eggRuntime and type(p556.eggRuntime.releaseDrScrambleRoute) == "function" then
									p556.eggRuntime:releaseDrScrambleRoute()
								end

								return
							end

							local v1724 = p556:_nearestRoute()

							if not v1724 or v1724.key ~= p556.lockedTargetKey then
								p556:_releaseLock()

								if p556.eggRuntime and type(p556.eggRuntime.releaseDrScrambleRoute) == "function" then
									p556.eggRuntime:releaseDrScrambleRoute()
								end

								return
							end

							local Character2 = LocalPlayer2.Character
							local HumanoidRootPart = Character2 and Character2:FindFirstChild("HumanoidRootPart")
							local Humanoid2 = Character2 and Character2:FindFirstChildOfClass("Humanoid")

							if HumanoidRootPart and Humanoid2 and not (Humanoid2.Health <= 0) then
								if p556.lockHumanoid ~= Humanoid2 then
									p556.lockHumanoid = Humanoid2
									p556.lockAutoRotate = Humanoid2.AutoRotate
								end

								p556:_rotateBatIfNeeded()
								HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
								HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
								HumanoidRootPart.CFrame = v1724.destination
								Humanoid2.AutoRotate = false

								return
							end

							p556:_releaseLock()

							if p556.eggRuntime then
								if type(p556.eggRuntime.releaseDrScrambleRoute) == "function" then
									p556.eggRuntime:releaseDrScrambleRoute(true)
								end
							end

							return
						end
					end

					p556:_releaseLock()

					if p556.eggRuntime and type(p556.eggRuntime.releaseDrScrambleRoute) == "function" then
						p556.eggRuntime:releaseDrScrambleRoute()
					end
				end)

				return true
			end
		end

		return false
	end
	t70._purchaseCount = function(p558, p559, p560)
		local State = type(p559) == "table" and p559.State

		State = State or nil

		local ShopPurchases = type(State) == "table" and State.ShopPurchases or nil
		local v1730 = type(ShopPurchases) == "table" and ShopPurchases[p560.Id] or nil

		if type(v1730) == "table" and tostring(v1730.Period) == tostring(p559.ShopPeriod) then
			return math.max(tonumber(v1730.Count) or 0, 0)
		end

		return 0
	end
	t70._selectedShopOffer = function(p561, p562)
		local t75 = {}

		for _, shopItem in ipairs(p561.shopItems) do
			t75[shopItem] = true

			local v1734 = t69[shopItem]

			if v1734 then
				t75[v1734] = true
			end
		end

		local ipairs_ = ipairs
		local Shop = type(p562 and p562.Shop) == "table" and p562.Shop or {}

		for _, v in ipairs_(Shop) do
			if type(v) ~= "table" or not t75[v.Label] and not t75[v.Id] then
				continue
			end

			local v1739 = p561.shopPurchases[v.Id] or 0
			local shopAmount = p561.shopAmount
			local v1741 = p561:_purchaseCount(p562, v)
			local v1742 = tonumber(v.PurchaseLimit)

			if not (v1739 < shopAmount) then
				continue
			end

			if not v1742 then
				return v
			end

			if v1741 + (tonumber(v.Quantity) or 1) <= v1742 then
				return v
			end
		end

		return nil
	end
	t70._shopTick = function(p563)
		local now = os.clock()

		if now < p563.nextShopCycleAt then
			p563.shopStatus = string.format("Next purchase cycle in %ds", math.ceil(p563.nextShopCycleAt - now))

			return
		end

		local v1744 = p563:_snapshot()

		if type(v1744) ~= "table" or v1744.Ready ~= true or v1744.Enabled ~= true or v1744.WorldReady ~= true then
			p563.shopStatus = "Event inactive"

			return
		end

		if tonumber(v1744.EventEndsAt) then
			if v1744.EventEndsAt <= Workspace2:GetServerTimeNow() then
				p563.shopStatus = "Event inactive"

				return
			end
		end

		if type(p563.shopItems) ~= "table" or #p563.shopItems == 0 then
			p563.shopStatus = "No items selected"

			return
		end

		local v1745 = p563:_selectedShopOffer(v1744)

		if not v1745 then
			table.clear(p563.shopPurchases)
			p563.lastShopSignature = nil
			p563.nextShopCycleAt = now + p563.shopInterval
			p563.shopStatus = string.format("Selected offers unavailable or capped | retry in %ds", p563.shopInterval)

			return
		end

		local State = type(v1744.State) == "table" and v1744.State or nil

		if not State then
			p563.shopStatus = "Shop state unavailable"

			return
		end

		if type(v1745.Quote) ~= "string" or v1745.Quote == "" then
			p563.shopStatus = "Offer quote unavailable"

			return
		end

		if not Scramble or not Scramble.Request then
			p563.shopStatus = "Official shop remote unavailable"

			return
		end

		local v1747 = tonumber(State.Samples) or 0

		if v1747 < (tonumber(v1745.Price) or math.huge) then
			p563.nextShopCycleAt = now + p563.shopInterval
			p563.shopStatus = "Not enough Samples for " .. tostring(v1745.Label)

			return
		end

		local v1748 = p563:_purchaseCount(v1744, v1745)
		local concat = table.concat
		local t76 = {}
		local v1751 = tostring(v1744.ShopPeriod)
		local v1752 = tostring(v1745.Id)
		local v1753 = tostring(State.ShopSequence)
		local v1754 = tostring(v1747)
		local v1755 = tostring(v1748)
		local tostring_ = tostring
		local v1757 = p563.shopPurchases[v1745.Id] or 0

		do
			local values = table.pack(v1751, v1752, v1753, v1754, v1755, tostring_(v1757))

			table.move(values, 1, values.n, 1, t76)
		end

		local lastShopSignature = concat(t76, ":")

		if p563.lastShopSignature == lastShopSignature or now - p563.lastShopRequestAt < 1.5 then
			return
		end

		p563.lastShopRequestAt = now
		p563.lastShopSignature = lastShopSignature
		p563.shopStatus = "Buying " .. tostring(v1745.Label)

		local ok, result = pcall(function()
			return Scramble.Request:InvokeServer("Shop", v1745.Id, {
				Quote = v1745.Quote,
				Sequence = math.max(tonumber(State.ShopSequence) or 0, 0)
			})
		end)

		if ok and result ~= false then
			if type(result) == "table" and type(result.Snapshot) == "table" then
				p563.context = result.Snapshot
			end

			p563.shopPurchases[v1745.Id] = (p563.shopPurchases[v1745.Id] or 0) + 1
			p563.shopStatus = "Bought " .. tostring(v1745.Label)
		else
			p563.shopStatus = "Purchase failed: " .. tostring(type(result) == "table" and result.Reason or result)
		end
	end
	t70.setEnabled = function(p564, p565)
		p564.enabled = p565 == true
		p564.generation += 1

		if p564.eggRuntime and type(p564.eggRuntime.setDrScrambleObjective) == "function" then
			p564.eggRuntime:setDrScrambleObjective(p564.enabled)
		end

		if p564.enabled then
			p564:_setStatus("Waiting for event robot")
			p564:_ensureWorker()
		else
			p564.stickyTargetKey = nil
			p564:_releaseLock()
			p564:_setStatus("Off")
		end
	end
	t70.setAutoBuy = function(p566, p567)
		if not (p567 ~= true or p566.autoBuy) then
			table.clear(p566.shopPurchases)
			p566.nextShopCycleAt = 0
		end

		p566.autoBuy = p567 == true
		p566.lastShopRequestAt = 0
		p566.lastShopSignature = nil

		if p566.autoBuy then
			p566.shopStatus = "Monitoring shop"
		else
			p566.shopStatus = "Off"
		end

		p566:_ensureWorker()
	end
	t70.setShopItems = function(p568, p569)
		p568.shopItems = type(p569) == "table" and table.clone(p569) or {}
		table.clear(p568.shopPurchases)
		p568.lastShopSignature = nil
		p568.nextShopCycleAt = 0
	end
	t70.setShopAmount = function(p570, p571)
		p570.shopAmount = math.clamp(math.floor(tonumber(p571) or 1), 1, 100)
		table.clear(p570.shopPurchases)
		p570.lastShopSignature = nil
		p570.nextShopCycleAt = 0

		return p570.shopAmount
	end
	t70.setShopInterval = function(p572, p573)
		p572.shopInterval = math.clamp(tonumber(p573) or 15, 1, 3600)
		p572.lastShopSignature = nil
		p572.nextShopCycleAt = 0

		return p572.shopInterval
	end
	t70.isFightPending = function(p574)
		local enabled = not p574.destroyed and p574.enabled and p574:_eventWindowActive()

		return enabled and p574:_nearestRoute() ~= nil
	end
	t70.isMovementBusy = function(p575)
		return p575.locked or p575.eggRuntime and p575.eggRuntime.drScrambleRouteActive == true
	end
	t70.getSnapshot = function(p576)
		local v1763 = p576:_resolveClientContext()
		local serverTimeNow = Workspace2:GetServerTimeNow()
		local Window = type(v1763) == "table" and v1763.Window or nil
		local v1766 = p576:_eventWindowActive(v1763)
		local v1767 = v1766

		if v1767 then
			v1767 = math.max(tonumber(Workspace2:GetAttribute("ScrambleOutbreakEndsAt")) or 0, type(Window) == "table" and tonumber(Window.EndsAt) or 0)
		end

		v1767 = v1767 or type(Window) == "table" and (tonumber(Window.NextAt) or tonumber(Window.StartsAt)) or 0

		if v1767 <= 0 then
			v1767 = (math.floor(serverTimeNow / 1800) + 1) * 1800
		end

		local v1768 = p576:_nearestRoute()
		local t77 = {
			enabled = p576.enabled,
			active = v1766,
			status = p576.stats.status,
			targetTier = v1768 and (t68[v1768.tier] or v1768.tier) or nil,
			health = v1768 and v1768.health or 0,
			maxHealth = v1768 and v1768.maxHealth or 0
		}

		t77.secondsLeft = math.max(0, v1767 - serverTimeNow)
		t77.shopStatus = p576.shopStatus
		t77.shopAmount = p576.shopAmount
		t77.shopInterval = p576.shopInterval
		t77.samples = tonumber(type(v1763) == "table" and v1763.State and v1763.State.Samples) or 0
		t77.shopItemCount = type(p576.shopItems) == "table" and #p576.shopItems or 0

		return t77
	end
	t70._ensureWorker = function(p577)
		if p577.worker then
			return
		end

		p577.worker = task.spawn(function()
			while not p577.destroyed do
				local v1770 = p577:_resolveClientContext()

				if p577.autoBuy then
					local ok, result = xpcall(p577._shopTick, debug.traceback, p577)

					if not ok then
						warn("[SAE][ScrambleShop] " .. tostring(result))
						p577.shopStatus = "Shop runtime error"
					end
				end

				if p577.enabled then
					p577:_hasPriorityEggs(true)
				end

				if not p577.enabled then
					p577:_releaseLock()
				elseif p577:_hasPriorityEggs() then
					p577:_releaseLock()

					if p577.eggRuntime and type(p577.eggRuntime.releaseDrScrambleRoute) == "function" then
						p577.eggRuntime:releaseDrScrambleRoute()
					end

					p577.stats.status = "Prioritizing filtered egg"
				elseif not p577:_eventWindowActive(v1770) then
					p577:_releaseLock()
					p577.stickyTargetKey = nil

					if p577.eggRuntime then
						if type(p577.eggRuntime.releaseDrScrambleRoute) == "function" then
							p577.eggRuntime:releaseDrScrambleRoute()
						end
					end

					p577.stats.status = "Waiting for outbreak window"
				elseif not p577:_nearestRoute() then
					p577:_releaseLock()
					p577.stats.status = "Waiting for selected drone"
				elseif not p577.locked then
					p577.stats.status = "Ready for Auto Steal route"
				end

				genv.__ZeroinScrambleStatus = p577:getSnapshot()
				task.wait((p577.enabled or p577.autoBuy) and 0.15 or 1)
			end

			p577.worker = nil
		end)
	end
	t70.destroy = function(p578)
		if p578.destroyed then
			return
		end

		p578.destroyed = true
		p578.enabled = false
		p578.autoBuy = false
		p578.generation += 1

		if p578.eggRuntime and type(p578.eggRuntime.setDrScrambleObjective) == "function" then
			p578.eggRuntime:setDrScrambleObjective(false)
		end

		p578:_releaseLock()

		for _, connection4 in ipairs(p578.connections) do
			pcall(connection4.Disconnect, connection4)
		end

		table.clear(p578.connections)

		if p578.worker then
			pcall(task.cancel, p578.worker)
			p578.worker = nil
		end
	end

	return t70
end

local v1775 = v1587()

local function v1776()
	local Players2 = game:GetService("Players")
	local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
	local Workspace2 = game:GetService("Workspace")
	local LocalPlayer2 = Players2.LocalPlayer
	local Assets = require(ReplicatedStorage2.Data.Assets)
	local AssetRoster = require(ReplicatedStorage2.Client.AssetRoster)
	local AssetItems = require(ReplicatedStorage2.Shared.Util.AssetItems)
	local AssetEarnings = require(ReplicatedStorage2.Shared.Util.AssetEarnings)
	local Eggs = require(ReplicatedStorage2.Shared.Types.Eggs)
	local Remotes = require(ReplicatedStorage2.Shared.Remotes)
	local Save = require(ReplicatedStorage2.Shared.Save)
	local Fusery = Remotes.Fusery
	local t78 = {
		"Lowest Rarity",
		"Highest Rarity",
		"Lowest Value",
		"Lightest",
		"Heaviest"
	}
	local t79 = {}

	t79.__index = t79

	local function v1791(p579)
		pcall(function()
			if typeof(p579) == "RBXScriptConnection" then
				p579:Disconnect()
			elseif type(p579) == "function" then
				p579()
			elseif type(p579) == "table" and type(p579.Disconnect) == "function" then
				p579:Disconnect()
			elseif type(p579) == "table" and type(p579.Destroy) == "function" then
				p579:Destroy()
			end
		end)
	end
	local function v1792(p580)
		local n28 = 0
		local pairs_ = pairs
		local v1795 = type(p580) == "table" and p580 or {}

		for _ in pairs_(v1795) do
			n28 += 1
		end

		return n28
	end
	local function v1797(p581)
		local FusionSlots = type(p581) == "table" and type(p581.FusionSlots) == "table" and p581.FusionSlots

		return FusionSlots or {}
	end
	local function v1799(p582)
		return type(p582) == "table" and (type(p582.FusionReward) == "table" or type(p582.FusionEggReward) == "table")
	end
	local function v1800(p583)
		local v1801 = tonumber(type(p583) == "table" and p583.FusionEndsAt)
		local v1802 = tonumber(type(p583) == "table" and p583.FusionDuration) or 0

		return v1799(p583) or type(p583) == "table" and p583.FusionLocked == true or v1801 ~= nil and (v1802 > 0 or v1801 > Workspace2:GetServerTimeNow())
	end
	local function v1803(p584)
		local Packages = ReplicatedStorage2:FindFirstChild("Packages")
		local Networking = Packages and Packages:FindFirstChild("Networking")
		local v1806 = Networking and Networking:FindFirstChild("RF/Fusery/" .. p584)

		if v1806 then
			return v1806
		end

		return Fusery and Fusery[p584] or nil
	end

	t79.getPriorities = function()
		return table.clone(t78)
	end
	t79.new = function(p585, p586, p587, p588)
		local obj = setmetatable({}, t79)

		obj.coordinator = p585
		obj.travel = p586
		obj.treadmillManager = p587
		obj.captureRuntime = p588
		obj.destroyed = false
		obj.running = false
		obj.generation = 0
		obj.listeners = {}
		obj.resources = {}
		obj.retryScheduled = false
		obj.rescheduleRequested = false
		obj.startupRecoveryPending = true
		obj.pendingSinglePass = false
		obj.manualConfirmation = nil
		obj.lastCoordinatorOperation = nil
		obj.config = {
			enabled = false,
			priority = t78[1],
			rarities = { "All" },
			keepPerCategory = 1,
			maxWeightKg = 0
		}
		obj.stats = {
			status = "Disabled",
			lastFused = "None",
			eligibleGroups = nil
		}

		local v1808 = Save.WatchFields({
			"Inventory",
			"EquippedAssets",
			"EggInventory",
			"FusionSlots",
			"FusionLocked",
			"FusionEndsAt",
			"FusionDuration",
			"FusionReward",
			"FusionEggReward"
		}, function()
			obj:_emit()

			if obj.running then
				obj.rescheduleRequested = true
			else
				obj:_schedule()
			end
		end)

		if v1808 then
			table.insert(obj.resources, v1808)
		end

		if p585 then
			if type(p585.subscribe) == "function" then
				table.insert(obj.resources, p585:subscribe(function(p589)
					local operation = p589 and p589.operation or nil
					local lastCoordinatorOperation = obj.lastCoordinatorOperation

					obj.lastCoordinatorOperation = operation

					if operation == "auto_fuse" or lastCoordinatorOperation == "auto_fuse" or operation ~= nil then
						return
					end

					if obj.running then
						obj.rescheduleRequested = true
					else
						obj:_schedule()
					end
				end))
			end
		end

		task.defer(function()
			if obj.destroyed then
				return
			end

			local v1811 = Save.Get()

			if v1800(v1811) then
				obj.running = true
				zeroinConfig.IsFusing = true

				local ok, _, result2 = xpcall(obj._finishPendingFusion, debug.traceback, obj)

				if not ok then
					warn("[SAE][AutoFuse] Startup reward recovery failed")
				elseif result2 then
					obj:_setStatus(result2)
				end

				obj.running = false
				zeroinConfig.IsFusing = false
			end

			obj.startupRecoveryPending = false
			obj:_emit()

			if obj.pendingSinglePass then
				obj.pendingSinglePass = false
				obj:_schedule(true)
			elseif obj.config.enabled then
				obj:_schedule()
			end
		end)

		return obj
	end
	t79._snapshot = function(p590)
		local v1815 = Save.Get()

		return {
			enabled = p590.config.enabled,
			running = p590.running,
			status = p590.stats.status,
			lastFused = p590.stats.lastFused,
			eligibleGroups = p590.stats.eligibleGroups,
			machineCount = #v1797(v1815),
			priority = p590.config.priority,
			keepPerCategory = p590.config.keepPerCategory,
			maxWeightKg = p590.config.maxWeightKg,
			rarities = table.clone(p590.config.rarities)
		}
	end
	t79._emit = function(p591)
		local v1816 = p591:_snapshot()

		genv.__ZeroinFuseStatus = v1816

		for k in pairs(p591.listeners) do
			pcall(k, v1816)
		end
	end
	t79.onChanged = function(p592, p593)
		p592.listeners[p593] = true
		pcall(p593, p592:_snapshot())

		return function()
			p592.listeners[p593] = nil
		end
	end
	t79._setStatus = function(p594, p595)
		p594.stats.status = p595
		p594:_emit()
	end
	t79._waitFor = function(p596, p597, p598, p599)
		local v1818 = os.clock() + p598

		while true do
			if not (os.clock() < v1818) then
				return false
			end

			if p596.destroyed or p597 ~= p596.generation then
				break
			end

			if p599() then
				return true
			end

			task.wait(0.1)
		end

		return false
	end
	t79._placedUids = function()
		local ok, result = pcall(AssetRoster.ReadOwnerPen, LocalPlayer2.UserId)

		if not ok or type(result) ~= "table" then
			return nil
		end

		local t80 = {}

		for k, v in pairs(result) do
			if type(k) == "string" then
				t80[k] = true
			end

			if type(v) == "table" and type(v.UID) == "string" then
				t80[v.UID] = true
			end
		end

		return t80
	end
	t79._decodeInventory = function(p600)
		local v1824 = Save.Get()
		local Inventory = v1824 and v1824.Inventory

		if type(Inventory) ~= "table" then
			return nil, "Pet inventory unavailable"
		end

		local v1826 = p600:_placedUids()

		if not v1826 then
			return nil, "Placed pet status unavailable"
		end

		local t81 = {}
		local ipairs_ = ipairs
		local EquippedAssets = v1824.EquippedAssets or {}

		for _, EquippedAsset in ipairs_(EquippedAssets) do
			t81[EquippedAsset] = true
		end

		local t82 = {}

		for k, v in pairs(Inventory) do
			if type(k) == "string" and type(v) == "table" then
				local ok, result = pcall(AssetItems.Decode, v)

				if ok and type(result) == "table" and type(result.Category) == "string" then
					local v1837 = Assets.Directory[result.Category]
					local Rarity = v1837 and v1837.Rarity
					local ok2, result2 = pcall(AssetItems.WeightKg, result)
					local ok3, result3 = pcall(AssetEarnings.LiveRatePerSecond, {
						Category = result.Category,
						Scale = math.max(tonumber(result.Scale or result.AssetScale) or 1, 0.01),
						Mutations = type(result.Mutations) == "table" and result.Mutations or {}
					}, v1824.Gamepasses, v1824.Products)
					local v1843 = #t82 + 1
					local t83 = {
						uid = k,
						item = result,
						category = result.Category,
						displayName = v1837 and (v1837.DisplayName or v1837._id) or result.Category,
						rarity = Rarity and (Rarity.DisplayName or Rarity._id) or "Unknown",
						rarityId = Rarity and Rarity._id or "Unknown",
						rarityRank = Rarity and Rarity.RarityNumber or 0
					}
					local weightKg = ok2

					if weightKg then
						weightKg = math.max(tonumber(result2) or 0, 0)
					end

					t83.weightKg = weightKg or 0
					t83.weightKnown = ok2 and tonumber(result2) ~= nil
					t83.ratePerSecond = ok3 and type(result3) == "number" and math.max(result3, 0) or math.huge
					t83.favorite = result.IsFavorite == true
					t83.equipped = t81[k] == true
					t83.placed = v1826[k] == true
					t83.inFuse = result.InFuse == true
					t83.canFuse = v1837 ~= nil and v1837.CannotFuse ~= true
					t82[v1843] = t83
				end
			end
		end

		return t82
	end
	t79._rarityMatches = function(p601, p602)
		if table.find(p601.config.rarities, "All") then
			return true
		end

		return table.find(p601.config.rarities, p602.rarity) ~= nil or table.find(p601.config.rarities, p602.rarityId) ~= nil
	end
	t79._selectGroup = function(p603)
		local v1846 = Save.Get()

		if #v1797(v1846) > 0 then
			return nil, "Fuse machine already contains pets"
		end

		if Eggs.MAX_INVENTORY <= v1792(v1846 and v1846.EggInventory) then
			return nil, "Egg inventory is full"
		end

		local v1847, v1848 = p603:_decodeInventory()

		if not v1847 then
			return nil, v1848
		end

		local t84 = {}

		for _, v in ipairs(v1847) do
			if v.canFuse and not v.favorite and not v.inFuse and not v.equipped and not v.placed and p603:_rarityMatches(v) and (p603.config.priority ~= "Lightest" and p603.config.priority ~= "Heaviest" or v.weightKnown) and (p603.config.maxWeightKg <= 0 or v.weightKnown and v.weightKg <= p603.config.maxWeightKg) and not p603.coordinator:isCategoryProtected(v.category, "auto_fuse") and not p603.coordinator:isReserved(v.uid, "auto_fuse") then
				t84[v.category] = t84[v.category] or {}
				table.insert(t84[v.category], v)
			end
		end

		local t85 = {}
		local eligibleGroups = 0
		local v1854 = false
		local keepPerCategory = p603.config.keepPerCategory

		for k, v in pairs(t84) do
			if #v >= 3 and #v - keepPerCategory < 3 then
				v1854 = true
			end

			if #v - keepPerCategory >= 3 then
				eligibleGroups += math.floor((#v - keepPerCategory) / 3)
				table.sort(v, function(p604, p605)
					if p603.config.priority == "Heaviest" then
						return p604.weightKg > p605.weightKg
					end

					if p603.config.priority == "Lowest Value" and p604.ratePerSecond ~= p605.ratePerSecond then
						return p604.ratePerSecond < p605.ratePerSecond
					end

					if p604.weightKg == p605.weightKg then
						return p604.uid < p605.uid
					end

					return p604.weightKg < p605.weightKg
				end)
				t85[#t85 + 1] = {
					category = k,
					displayName = v[1].displayName,
					entries = {
						v[1],
						v[2],
						v[3]
					},
					rarityRank = v[1].rarityRank,
					weight = v[1].weightKg + v[2].weightKg + v[3].weightKg,
					ratePerSecond = v[1].ratePerSecond + v[2].ratePerSecond + v[3].ratePerSecond
				}
			end
		end

		p603.stats.eligibleGroups = eligibleGroups

		if #t85 == 0 then
			if v1854 then
				return nil, string.format("Need %d eligible copies of one pet (3 to fuse + %d kept)", keepPerCategory + 3, keepPerCategory)
			end

			return nil, "No pet type has 3 eligible copies"
		end

		table.sort(t85, function(p606, p607)
			if p603.config.priority == "Highest Rarity" and p606.rarityRank ~= p607.rarityRank then
				return p606.rarityRank > p607.rarityRank
			end

			if p603.config.priority == "Lowest Rarity" and p606.rarityRank ~= p607.rarityRank then
				return p606.rarityRank < p607.rarityRank
			end

			if p603.config.priority == "Lowest Value" and p606.ratePerSecond ~= p607.ratePerSecond then
				return p606.ratePerSecond < p607.ratePerSecond
			end

			if p603.config.priority == "Heaviest" and p606.weight ~= p607.weight then
				return p606.weight > p607.weight
			end

			if p603.config.priority ~= "Lightest" or p606.weight == p607.weight then
				return p606.category < p607.category
			end

			return p606.weight < p607.weight
		end)

		return t85[1]
	end
	t79._validateGroup = function(p608, p609)
		local v1858 = Save.Get()

		if #v1797(v1858) > 0 then
			return false, "Fuse machine already contains pets"
		end

		if Eggs.MAX_INVENTORY <= v1792(v1858 and v1858.EggInventory) then
			return false, "Egg inventory is full"
		end

		local v1859, v1860 = p608:_decodeInventory()

		if not v1859 then
			return false, v1860
		end

		local t86 = {}
		local n29 = 0

		for _, v in ipairs(v1859) do
			t86[v.uid] = v

			if v.category == p609.category and v.canFuse and not v.favorite and not v.inFuse and not v.equipped and not v.placed and p608:_rarityMatches(v) and (p608.config.priority ~= "Lightest" and p608.config.priority ~= "Heaviest" or v.weightKnown) then
				if not (p608.config.maxWeightKg <= 0) then
					if not v.weightKnown then
						continue
					end

					if not (v.weightKg <= p608.config.maxWeightKg) then
						continue
					end
				end

				if not p608.coordinator:isCategoryProtected(v.category, "auto_fuse") then
					if not p608.coordinator:isReserved(v.uid, "auto_fuse") then
						n29 += 1
					end
				end
			end
		end

		if n29 - p608.config.keepPerCategory < 3 then
			return false, "Keep Copies prevents selected group"
		end

		for _, entry in ipairs(p609.entries) do
			local v1867 = t86[entry.uid]

			if not v1867 or v1867.category ~= p609.category or not v1867.canFuse or v1867.favorite or v1867.inFuse or v1867.equipped or v1867.placed or not p608:_rarityMatches(v1867) or (p608.config.priority == "Lightest" or p608.config.priority == "Heaviest") and not v1867.weightKnown or p608.config.maxWeightKg > 0 and (not v1867.weightKnown or p608.config.maxWeightKg < v1867.weightKg) then
				return false, "Selected pets changed before fuse"
			end

			if p608.coordinator:isCategoryProtected(v1867.category, "auto_fuse") then
				return false, "Selected pets changed before fuse"
			end

			if p608.coordinator:isReserved(v1867.uid, "auto_fuse") then
				return false, "Selected pets changed before fuse"
			end
		end

		return true
	end
	t79._waitForTreadmill = function(p610)
		if not p610.treadmillManager then
			return true
		end

		if type(p610.treadmillManager._syncActiveTreadmillSnapshot) == "function" then
			p610.treadmillManager:_syncActiveTreadmillSnapshot()
		end

		if not p610.treadmillManager:isEngaged() then
			return true
		end

		if type(p610.treadmillManager._cancelIdle) == "function" then
			p610.treadmillManager:_cancelIdle(true)
		end

		local v1868 = os.clock() + 5

		while p610.treadmillManager:isEngaged() and os.clock() < v1868 do
			if type(p610.treadmillManager._requestUnequip) == "function" then
				p610.treadmillManager:_requestUnequip()
			end

			task.wait(0.1)
		end

		return not p610.treadmillManager:isEngaged()
	end
	t79._shouldAbort = function(p611, p612, p613)
		if p611.destroyed or p612 ~= p611.generation or not p613 and not p611.config.enabled then
			return true
		end

		if p611.captureRuntime and type(p611.captureRuntime.isEngaged) == "function" then
			if p611.captureRuntime:isEngaged() then
				return true
			end
		end

		if p611.travel and type(p611.travel.hasPendingPreEventSteal) == "function" then
			if p611.travel:hasPendingPreEventSteal() then
				return true
			end
		end

		local __ZeroinScrambleRuntime = genv.__ZeroinScrambleRuntime

		if __ZeroinScrambleRuntime and type(__ZeroinScrambleRuntime.isFightPending) == "function" and __ZeroinScrambleRuntime:isFightPending() then
			return true
		end

		local __ZeroinRiftRuntime = genv.__ZeroinRiftRuntime

		return __ZeroinRiftRuntime and type(__ZeroinRiftRuntime.isTradeReady) == "function" and __ZeroinRiftRuntime:isTradeReady() or false
	end
	t79._travelToMachine = function(p614, p615, p616)
		local __OBJECTS = Workspace2:FindFirstChild("__OBJECTS")
		local Machines = __OBJECTS and __OBJECTS:FindFirstChild("Machines")
		local FuseMachine = Machines and Machines:FindFirstChild("FuseMachine")
		local Machine = FuseMachine and FuseMachine:FindFirstChild("Machine")

		if not Machine or not Machine:IsA("BasePart") then
			return false, "Fuse machine unavailable"
		end

		local Character = LocalPlayer2.Character
		local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
		local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

		if not HumanoidRootPart or not Humanoid or Humanoid.Health <= 0 then
			return false, "Character unavailable"
		end

		local Attachment = Machine:FindFirstChildOfClass("Attachment")
		local WorldPosition = Attachment and Attachment.WorldPosition or Machine.Position
		local v1880 = WorldPosition - Machine.Position
		local vector32 = Vector3.new(v1880.X, 0, v1880.Z)
		local Unit = vector32.Magnitude > 0.1 and vector32.Unit or -Machine.CFrame.LookVector
		local v1883 = HumanoidRootPart.Size.Y * 0.5
		local v1884 = Humanoid.RigType == Enum.HumanoidRigType.R15 and math.max(Humanoid.HipHeight, 0.5)
		local v1885 = Vector3.new(WorldPosition.X, Machine.Position.Y - Machine.Size.Y * 0.5 + (v1883 + (v1884 or 2)), WorldPosition.Z) + Unit * 4
		local cFrame = lookAt(v1885, Vector3.new(WorldPosition.X, v1885.Y, WorldPosition.Z))

		if (HumanoidRootPart.Position - cFrame.Position).Magnitude <= 7 then
			return true
		end

		if not p614.travel then
			return false, "Shared travel unavailable"
		end

		if p614.travel:travelAndWait(cFrame, {
			abort = function()
				return p614:_shouldAbort(p615, p616)
			end
		}) then
			return true
		end

		return false, "Travel to fuse machine interrupted"
	end
	t79._rollback = function(p617, p618)
		local EjectPet = v1803("EjectPet")

		if not EjectPet then
			return
		end

		for _, v in ipairs(p618) do
			pcall(EjectPet.InvokeServer, EjectPet, v.uid)
		end
	end
	t79._clearStuckMachine = function(p619, p620)
		local v1890 = Save.Get()
		local t87 = {}

		for _, v in ipairs(v1797(v1890)) do
			if type(v) == "string" and v ~= "" then
				t87[v] = true
			end
		end

		local ipairs_ = ipairs
		local v1895 = p619:_decodeInventory() or {}

		for _, v in ipairs_(v1895) do
			if v.inFuse then
				t87[v.uid] = true
			end
		end

		if not next(t87) then
			return true
		end

		p619:_setStatus("Clearing unfinished fuse")

		local EjectPet = v1803("EjectPet")

		if not EjectPet then
			return false, "EjectPet remote unavailable"
		end

		for k in pairs(t87) do
			pcall(EjectPet.InvokeServer, EjectPet, k)
		end

		if p619:_waitFor(p620, 8, function()
			return #v1797(Save.Get()) == 0
		end) then
			return true
		end

		return false, "Fuse machine cleanup timed out"
	end
	t79._finishPendingFusion = function(p621)
		local v1900 = Save.Get()
		local v1901 = tonumber(v1900 and v1900.FusionEndsAt)

		if not v1800(v1900) then
			return false, nil
		end

		local v1902 = v1799(v1900)

		if not v1902 then
			p621:_setStatus("Waiting for existing fuse")

			local v1903 = tonumber(v1900 and v1900.FusionDuration) or 0
			local v1904 = v1901 and math.max(30, v1901 - Workspace2:GetServerTimeNow() + 8) or math.max(30, v1903 + 8)
			local v1905 = os.clock() + v1904

			while not p621.destroyed and os.clock() < v1905 do
				local v1906 = Save.Get()

				if v1799(v1906) then
					v1902 = true

					break
				end

				local v1907 = tonumber(v1906 and v1906.FusionEndsAt)

				if v1907 ~= nil and v1906.FusionLocked ~= true and v1907 <= Workspace2:GetServerTimeNow() then
					v1902 = true

					break
				end

				task.wait(0.1)
			end
		end

		if not v1902 then
			return true, "Existing fuse reward timed out"
		end

		local v1908, v1909 = p621:_finishReveal()

		if not v1908 then
			return true, "Finish reveal failed: " .. tostring(v1909)
		end

		p621:_setStatus("Recovered previous fuse reward")

		return true, nil
	end
	t79._finishReveal = function()
		local FinishReveal = v1803("FinishReveal")

		if not FinishReveal then
			return false, "FinishReveal remote unavailable"
		end

		local ok, result, result2 = pcall(FinishReveal.InvokeServer, FinishReveal)

		if ok and result ~= false then
			return true
		end

		return false, tostring(result2 or result or "Unknown")
	end
	t79._run = function(p622, p623, p624)
		if p622.running or p622.destroyed then
			return
		end

		p622.running = true
		zeroinConfig.IsFusing = true

		local v1914 = false

		while not p622.destroyed and p623 == p622.generation and (p622.config.enabled or p624) do
			local v1915, v1916 = p622:_finishPendingFusion()

			if v1916 then
				p622:_setStatus(v1916)
				v1914 = true

				break
			end

			if v1915 then
				if not p624 then
					task.wait(0.5)

					continue
				end
			else
				local ok2 = not (not not p622.captureRuntime and type(p622.captureRuntime.isEngaged) == "function")

				if not ok2 then
					ok2 = not p622.captureRuntime:isEngaged()
				end

				if not ok2 then
					p622:_setStatus("Waiting for Capture The Egg")
					v1914 = true

					break
				end

				local ok = not (not not p622.travel and type(p622.travel.hasPendingPreEventSteal) == "function")

				if not ok then
					ok = not p622.travel:hasPendingPreEventSteal()
				end

				if not ok then
					p622:_setStatus("Waiting for Auto Steal")
					v1914 = true

					break
				end

				local manualCarry = p622.travel and p622.travel.manualCarry

				if manualCarry and manualCarry.active then
					p622:_setStatus("Waiting for carried egg")
					v1914 = true

					break
				end

				local v1920, v1921 = p622:_clearStuckMachine(p623)

				if not v1920 then
					p622:_setStatus(v1921 or "Fuse cleanup failed")
					v1914 = true

					break
				end

				local v1922, v1923 = p622:_selectGroup()

				if not v1922 then
					p622:_setStatus(v1923 or "No eligible fuse group")
					v1914 = v1923 == "Pet inventory unavailable" or v1923 == "Placed pet status unavailable"

					break
				end

				local t88 = {}

				for _, entry in ipairs(v1922.entries) do
					t88[#t88 + 1] = entry.uid
				end

				local autoFuse, v1928 = p622.coordinator:tryAcquire("auto_fuse", t88)

				if not autoFuse then
					p622:_setStatus(v1928 or "Waiting for another automation")
					v1914 = true

					break
				end

				local u1929 = false

				local function v1930()
					if u1929 then
						return
					end

					u1929 = true
					p622.coordinator:release(autoFuse)
				end

				if not p622:_waitForTreadmill() then
					v1930()
					p622:_setStatus("Treadmill did not release")
					v1914 = true

					break
				end

				p622:_setStatus("Moving to Fuse Machine")

				local v1931, v1932 = p622:_travelToMachine(p623, p624)

				if not v1931 then
					v1930()
					p622:_setStatus(v1932 or "Fuse travel failed")
					v1914 = true

					break
				end

				local v1933, v1934 = p622:_validateGroup(v1922)

				if not v1933 then
					v1930()
					p622:_setStatus(v1934)

					break
				end

				pcall(function()
					local ConfirmBriefing = v1803("ConfirmBriefing")

					if ConfirmBriefing then
						ConfirmBriefing:InvokeServer()
					end
				end)

				local LoadPet = v1803("LoadPet")

				if not LoadPet then
					v1930()
					p622:_setStatus("LoadPet remote unavailable")

					break
				end

				local t89 = {}
				local fuseFailed

				for i, entry in ipairs(v1922.entries) do
					if p622:_shouldAbort(p623, p624) then
						fuseFailed = "Cancelled"

						break
					end

					if p622.coordinator:isCategoryProtected(v1922.category, "auto_fuse") then
						fuseFailed = "Pet category became protected"

						break
					end

					p622:_setStatus(string.format("Loading %s (%d/3)", v1922.displayName, i))

					local ok3, result, result2 = pcall(LoadPet.InvokeServer, LoadPet, entry.uid)

					if ok3 and result ~= false then
						t89[#t89 + 1] = entry
						task.wait(0.15)
					else
						fuseFailed = tostring(result2 or result or "Insert rejected")

						break
					end
				end

				if fuseFailed then
					p622:_rollback(t89)
					v1930()
					p622:_setStatus("Fuse failed: " .. fuseFailed)

					break
				end

				local BeginFuse = v1803("BeginFuse")

				if not BeginFuse then
					p622:_rollback(t89)
					v1930()
					p622:_setStatus("BeginFuse remote unavailable")

					break
				end

				if p622:_shouldAbort(p623, p624) then
					p622:_rollback(t89)
					v1930()
					p622:_setStatus("Fuse cancelled")

					break
				end

				if p622.coordinator:isCategoryProtected(v1922.category, "auto_fuse") then
					p622:_rollback(t89)
					v1930()
					p622:_setStatus("Fuse cancelled: pet category protected")

					break
				end

				local v1945 = Save.Get()

				if Eggs.MAX_INVENTORY <= v1792(v1945 and v1945.EggInventory) then
					p622:_rollback(t89)
					v1930()
					p622:_setStatus("Fuse cancelled: egg inventory is full")

					break
				end

				p622:_setStatus("Fusing " .. v1922.displayName)

				local ok3, result, result2, result3 = pcall(BeginFuse.InvokeServer, BeginFuse)

				if not ok3 or result == false then
					p622:_rollback(t89)
					v1930()
					p622:_setStatus("Fuse failed: " .. tostring(result2 or result or "Unknown"))

					break
				end

				v1930()

				local v1950 = Save.Get()
				local v1951 = tonumber(v1950 and v1950.FusionEndsAt)
				local v1952 = tonumber(v1950 and v1950.FusionDuration) or 0
				local n30 = 30
				local v1954

				if v1951 then
					v1954 = math.max(n30, v1951 - Workspace2:GetServerTimeNow() + 8)
				elseif v1952 > 0 then
					v1954 = math.max(n30, v1952 + 8)
				else
					v1954 = 5
				end

				p622:_setStatus("Waiting for fuse reward")

				local v1955 = os.clock() + v1954
				local v1956 = false

				while not p622.destroyed and os.clock() < v1955 do
					local v1957 = Save.Get()

					if v1799(v1957) then
						v1956 = true

						break
					end

					local v1958 = tonumber(v1957 and v1957.FusionEndsAt)

					if v1958 ~= nil and v1957.FusionLocked ~= true and v1958 <= Workspace2:GetServerTimeNow() then
						v1956 = true

						break
					end

					task.wait(0.1)
				end

				if not v1956 then
					p622:_setStatus("Fuse reward timed out")
					v1914 = true

					break
				end

				local v1959, v1960 = p622:_finishReveal()

				if not v1959 then
					p622:_setStatus("Finish reveal failed: " .. tostring(v1960))
					v1914 = true

					break
				end

				local stats = p622.stats
				local lastFused = type(result3) == "table"

				if lastFused then
					lastFused = tostring(result3.AssetCategory or v1922.displayName)
				end

				stats.lastFused = lastFused or v1922.displayName
				p622:_setStatus("Fused " .. p622.stats.lastFused)

				if p624 then
					break
				end

				task.wait(0.5)

				continue
			end

			break
		end

		p622.running = false
		zeroinConfig.IsFusing = false
		p622:_emit()

		if (v1914 or p622.rescheduleRequested or p624) and p622.config.enabled and not p622.destroyed then
			p622.rescheduleRequested = false
			p622:_scheduleRetry()
		end
	end
	t79._scheduleRetry = function(p625)
		if p625.retryScheduled or p625.destroyed or not p625.config.enabled then
			return
		end

		p625.retryScheduled = true

		local generation = p625.generation

		task.delay(1, function()
			p625.retryScheduled = false

			if not p625.destroyed and p625.config.enabled and generation == p625.generation then
				p625:_schedule()
			end
		end)
	end
	t79._schedule = function(p626, p627)
		if not p626.startupRecoveryPending then
			if not p626.destroyed and not p626.running and (p626.config.enabled or p627) then
				local generation = p626.generation

				task.defer(function()
					local ok, result = xpcall(p626._run, debug.traceback, p626, generation, p627 == true)

					if not ok then
						p626.running = false
						zeroinConfig.IsFusing = false
						p626.coordinator:forceRelease("auto_fuse")
						p626:_setStatus("Fuse runtime error")
						warn("[SAE][AutoFuse] " .. tostring(result))
						p626:_scheduleRetry()
					end
				end)

				return
			end

			return
		end

		p626.rescheduleRequested = p626.config.enabled or p627 == true
		p626.pendingSinglePass = p626.pendingSinglePass or p627 == true
	end
	t79.setEnabled = function(p628, p629)
		p628.config.enabled = p629 == true
		p628.generation += 1
		zeroinConfig.AutoFuse = p628.config.enabled

		if p628.config.enabled then
			if p628.running then
				p628.rescheduleRequested = true
			end

			p628:_setStatus("Scanning pets")
			p628:_schedule()
		else
			p628.rescheduleRequested = false
			zeroinConfig.IsFusing = p628.running
			p628:_setStatus("Disabled")
		end
	end
	t79.setPriority = function(p630, p631)
		if table.find(t78, p631) then
			p630.config.priority = p631
		end

		zeroinConfig.AutoFusePriority = p630.config.priority
		p630.manualConfirmation = nil
		p630.generation += 1
		p630:_emit()

		if p630.running then
			p630.rescheduleRequested = true
		else
			p630:_schedule()
		end

		return p630.config.priority
	end
	t79.setRarities = function(p632, p633)
		local t90 = {}
		local ipairs_ = ipairs
		local v1969 = type(p633) == "table" and p633 or { p633 }

		for _, v in ipairs_(v1969) do
			if type(v) == "string" and v ~= "" and not table.find(t90, v) then
				t90[#t90 + 1] = v
			end
		end

		p632.config.rarities = table.find(t90, "All") and { "All" } or #t90 > 0 and t90 or { "All" }
		zeroinConfig.AutoFuseRarities = table.clone(p632.config.rarities)
		p632.manualConfirmation = nil
		p632.generation += 1
		p632:_emit()

		if p632.running then
			p632.rescheduleRequested = true
		else
			p632:_schedule()
		end

		return table.clone(p632.config.rarities)
	end
	t79.setKeepPerCategory = function(p634, p635)
		local config = p634.config
		local max = math.max
		local n31 = 0
		local floor = math.floor

		config.keepPerCategory = max(n31, floor(tonumber(p635) or 1))
		zeroinConfig.AutoFuseKeepPerPet = p634.config.keepPerCategory
		p634.manualConfirmation = nil
		p634.generation += 1
		p634:_emit()

		if p634.running then
			p634.rescheduleRequested = true
		else
			p634:_schedule()
		end

		return p634.config.keepPerCategory
	end
	t79.setMaxWeightKg = function(p636, p637)
		p636.config.maxWeightKg = math.max(tonumber(p637) or 0, 0)
		zeroinConfig.AutoFuseMaxWeightKg = p636.config.maxWeightKg
		p636.manualConfirmation = nil
		p636.generation += 1
		p636:_emit()

		if p636.running then
			p636.rescheduleRequested = true
		else
			p636:_schedule()
		end

		return p636.config.maxWeightKg
	end
	t79.fuseOnce = function(p638)
		if p638.destroyed or p638.running then
			return false, "Auto Fuse is busy"
		end

		p638.generation += 1
		p638:_setStatus("Manual fuse requested")
		p638:_schedule(true)

		return true
	end
	t79.requestFuseOnce = function(p639)
		if p639.destroyed or p639.running then
			return false, "Auto Fuse is busy"
		end

		local v1976, v1977 = p639:_selectGroup()

		if not v1976 then
			p639.manualConfirmation = nil
			p639:_setStatus(v1977 or "No eligible fuse group")

			return false, p639.stats.status
		end

		local t91 = { v1976.category }

		for _, entry in ipairs(v1976.entries) do
			t91[#t91 + 1] = entry.uid
		end

		local v1981 = table.concat(t91, ":")
		local manualConfirmation = p639.manualConfirmation

		if manualConfirmation and not (manualConfirmation.signature ~= v1981 or manualConfirmation.expiresAt < os.clock()) then
			p639.manualConfirmation = nil

			return p639:fuseOnce()
		end

		p639.manualConfirmation = {
			signature = v1981,
			expiresAt = os.clock() + 8
		}
		p639:_setStatus("Ready: " .. v1976.displayName .. " x3 - press again to confirm")

		return false, "Press again within 8 seconds to confirm"
	end
	t79.preview = function(p640)
		local v1983, v1984 = p640:_selectGroup()

		p640:_emit()

		if v1983 then
			return {
				category = v1983.category,
				displayName = v1983.displayName,
				uids = {
					v1983.entries[1].uid,
					v1983.entries[2].uid,
					v1983.entries[3].uid
				}
			}, nil
		end

		return nil, v1984
	end
	t79.getSnapshot = function(p641)
		return p641:_snapshot()
	end
	t79.destroy = function(p642)
		if p642.destroyed then
			return
		end

		p642.destroyed = true
		p642.config.enabled = false
		p642.generation += 1
		zeroinConfig.IsFusing = false
		p642.coordinator:forceRelease("auto_fuse")

		for _, resource in ipairs(p642.resources) do
			v1791(resource)
		end

		table.clear(p642.resources)
		table.clear(p642.listeners)
	end

	return t79
end

local v1987 = v1776()

local function v1988()
	local Players2 = game:GetService("Players")
	local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
	local Workspace2 = game:GetService("Workspace")
	local LocalPlayer2 = Players2.LocalPlayer
	local Remotes = require(ReplicatedStorage2.Shared.Remotes)
	local Save = require(ReplicatedStorage2.Shared.Save)
	local Assets = require(ReplicatedStorage2.Data.Assets)
	local AssetEarnings = require(ReplicatedStorage2.Shared.Util.AssetEarnings)
	local BossMastery = Remotes.BossMastery
	local t92 = {
		"Boss",
		"Scrambled"
	}
	local t93 = {}

	t93.__index = t93

	local function v2000(p643)
		pcall(function()
			if typeof(p643) == "RBXScriptConnection" then
				p643:Disconnect()
			elseif type(p643) == "function" then
				p643()
			elseif type(p643) == "table" and type(p643.Disconnect) == "function" then
				p643:Disconnect()
			end
		end)
	end

	t93.new = function(p644, p645, p646, p647)
		local obj = setmetatable({}, t93)

		obj.coordinator = p644
		obj.travel = p645
		obj.treadmillManager = p646
		obj.captureRuntime = p647
		obj.destroyed = false
		obj.running = false
		obj.generation = 0
		obj.listeners = {}
		obj.resources = {}
		obj.manualConfirmation = nil
		obj.successHoldUntil = 0
		obj.config = {
			enabled = false,
			mutationType = "Boss",
			rarities = {
				"Secret",
				"Eternal",
				"Divine",
				"Cosmic",
				"Mythic"
			},
			names = {},
			minValuePerSec = 0
		}
		obj.stats = {
			status = "Disabled",
			consumables = 0,
			eligible = 0,
			target = nil,
			lastMutated = "None"
		}

		local v2002 = Save.WatchFields({
			"EggInventory",
			"BossMastery",
			"Gamepasses",
			"Products"
		}, function()
			obj:_emit()
			obj:_schedule()
		end)

		if v2002 then
			obj.resources[#obj.resources + 1] = v2002
		end

		return obj
	end
	t93.getMutationTypes = function()
		return table.clone(t92)
	end
	t93._snapshot = function(p648)
		return {
			enabled = p648.config.enabled,
			running = p648.running,
			status = p648.stats.status,
			consumables = p648.stats.consumables,
			eligible = p648.stats.eligible,
			target = p648.stats.target,
			lastMutated = p648.stats.lastMutated,
			mutationType = p648.config.mutationType,
			rarities = table.clone(p648.config.rarities),
			names = table.clone(p648.config.names),
			minValuePerSec = p648.config.minValuePerSec,
			placedNames = p648:getPlacedEggNames()
		}
	end
	t93._emit = function(p649)
		local v2003 = p649:_snapshot()

		genv.__ZeroinAutoMutateStatus = v2003

		for k in pairs(p649.listeners) do
			pcall(k, v2003)
		end
	end
	t93.onChanged = function(p650, p651)
		p650.listeners[p651] = true
		pcall(p651, p650:_snapshot())

		return function()
			p650.listeners[p651] = nil
		end
	end
	t93._setStatus = function(p652, p653)
		p652.stats.status = p653
		p652:_emit()
	end
	t93._toolMutationType = function(p654, p655)
		return p655 and (p655:GetAttribute("MutationId") or p655:GetAttribute("MutationTemplate")) or nil
	end
	t93._isConsumable = function(p656, p657)
		if not p657 or not p657:IsA("Tool") then
			return false
		end

		if p657:GetAttribute("ItemType") ~= "MutationConsumable" then
			if not p657.Name:find("Mutation Consumable", 1, true) then
				return false
			end
		end

		local v2005 = p656:_toolMutationType(p657)

		if p656.config.mutationType == "Scrambled" then
			return v2005 == "Scrambled"
		end

		return v2005 == nil or v2005 == "" or v2005 == "Boss"
	end
	t93._findConsumable = function(p658)
		for _, v in pairs({
			character = LocalPlayer2.Character,
			backpack = LocalPlayer2:FindFirstChildOfClass("Backpack")
		}) do
			local ipairs_ = ipairs
			local children = v and v:GetChildren() or {}

			for _, child in ipairs_(children) do
				if p658:_isConsumable(child) then
					return child, v == LocalPlayer2.Character
				end
			end
		end

		return nil, false
	end
	t93.getConsumableCount = function(p659)
		if p659.config.mutationType ~= "Scrambled" then
			local v2012 = Save.Get()

			return math.max(tonumber(v2012 and v2012.BossMastery and v2012.BossMastery.MutationConsumables) or 0, 0)
		end

		local n32 = 0

		for _, v in pairs({
			character = LocalPlayer2.Character,
			backpack = LocalPlayer2:FindFirstChildOfClass("Backpack")
		}) do
			local ipairs_ = ipairs
			local children = v and v:GetChildren() or {}

			for _, child in ipairs_(children) do
				if p659:_isConsumable(child) then
					n32 += math.max(tonumber(child:GetAttribute("Uses")) or 1, 0)
				end
			end
		end

		return n32
	end
	t93._ensureEquipped = function(p660)
		local v2020, v2021 = p660:_findConsumable()

		if v2021 then
			return v2020 ~= nil
		end

		local Character = LocalPlayer2.Character
		local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

		if not v2020 or not Humanoid then
			return false
		end

		pcall(Humanoid.EquipTool, Humanoid, v2020)

		local v2024 = os.clock() + 0.5

		while true do
			if not (os.clock() < v2024) then
				return false
			end

			if v2020.Parent ~= Character or not p660:_isConsumable(v2020) then
				task.wait(0.05)

				continue
			end

			break
		end

		return true
	end
	t93.getPlacedEggNames = function()
		local t94 = {}
		local t95 = {}
		local v2027 = Save.Get()
		local pairs_ = pairs
		local EggInventory = v2027 and v2027.EggInventory or {}

		for _, v in pairs_(EggInventory) do
			if type(v) == "table" and v.Placement ~= nil and type(v.AssetCategory) == "string" then
				local v2032 = Assets.Directory[v.AssetCategory]
				local DisplayName = v2032 and (v2032.DisplayName or v2032._id) or v.AssetCategory

				if not t95[DisplayName] then
					t95[DisplayName] = true
					t94[#t94 + 1] = DisplayName
				end
			end
		end

		table.sort(t94)

		return t94
	end
	t93._rate = function(p661, p662, p663)
		local pcall_ = pcall
		local LiveRatePerSecond = AssetEarnings.LiveRatePerSecond
		local t96 = {
			Category = p662.AssetCategory
		}

		t96.Scale = math.max(tonumber(p662.AssetScale or p662.Scale) or 1, 0.01)
		t96.Mutations = type(p662.Mutations) == "table" and p662.Mutations or {}
		t96.BaseMutation = p662.BaseMutation

		local ok, result = pcall_(LiveRatePerSecond, t96, p663 and p663.Gamepasses, p663 and p663.Products)

		return ok and type(result) == "number" and math.max(result, 0) or nil
	end
	t93._eligibleTargets = function(p664)
		local v2039 = Save.Get()
		local t97 = {}
		local pairs_ = pairs
		local EggInventory = v2039 and v2039.EggInventory or {}

		for k, v in pairs_(EggInventory) do
			if type(k) == "string" and type(v) == "table" and v.Placement ~= nil and type(v.AssetCategory) == "string" then
				local v2045 = Assets.Directory[v.AssetCategory]
				local DisplayName = v2045 and v2045.Rarity and (v2045.Rarity.DisplayName or v2045.Rarity._id) or "Unknown"
				local DisplayName2 = v2045 and (v2045.DisplayName or v2045._id) or v.AssetCategory
				local v2048 = p664:_rate(v, v2039)
				local v2049 = table.find(p664.config.rarities, "All") ~= nil or table.find(p664.config.rarities, DisplayName) ~= nil
				local v2050 = #p664.config.names == 0 or table.find(p664.config.names, DisplayName2) ~= nil
				local v2051 = v2048 ~= nil and v2048 >= p664.config.minValuePerSec
				local v2052 = table.find(type(v.Mutations) == "table" and v.Mutations or {}, p664.config.mutationType) ~= nil or v.BaseMutation == p664.config.mutationType

				if v2049 and v2050 and v2051 and not v2052 then
					if not p664.coordinator:isReserved(k, "auto_mutate") then
						t97[#t97 + 1] = {
							uid = k,
							egg = v,
							category = v.AssetCategory,
							name = DisplayName2,
							rarity = DisplayName,
							rate = v2048
						}
					end
				end
			end
		end

		table.sort(t97, function(p665, p666)
			if p665.rate == p666.rate then
				return p665.uid < p666.uid
			end

			return p665.rate > p666.rate
		end)
		p664.stats.eligible = #t97
		p664.stats.target = t97[1] and t97[1].name or nil

		return t97
	end
	t93._noTargetReason = function(p667)
		local v2053 = Save.Get()
		local t98 = {}
		local t99 = {}
		local t100 = {}
		local pairs_ = pairs
		local EggInventory = v2053 and v2053.EggInventory or {}

		for _, v in pairs_(EggInventory) do
			if type(v) == "table" and v.Placement ~= nil and type(v.AssetCategory) == "string" then
				local v2061 = Assets.Directory[v.AssetCategory]
				local DisplayName = v2061 and (v2061.DisplayName or v2061._id) or v.AssetCategory

				t98[DisplayName] = true

				if #p667.config.names == 0 or table.find(p667.config.names, DisplayName) then
					t99[DisplayName] = true

					if table.find(type(v.Mutations) == "table" and v.Mutations or {}, p667.config.mutationType) or v.BaseMutation == p667.config.mutationType then
						t100[DisplayName] = true
					end
				end
			end
		end

		if #p667.config.names > 0 then
			local t101 = {}
			local t102 = {}

			for _, name in ipairs(p667.config.names) do
				if not t98[name] then
					t101[#t101 + 1] = name
				elseif t100[name] then
					t102[#t102 + 1] = name
				end
			end

			if #t102 == #p667.config.names then
				return table.concat(t102, ", ") .. " already has " .. p667.config.mutationType .. " mutation"
			end

			if #t101 == #p667.config.names then
				return "Selected egg is no longer placed"
			end
		end

		if next(t99) and next(t100) then
			return "Matching placed eggs already have " .. p667.config.mutationType .. " mutation"
		end

		if p667.config.minValuePerSec > 0 then
			return "No placed egg meets the minimum value"
		end

		return "No placed egg matches the rarity or name filters"
	end
	t93._findModel = function(p668, p669)
		local PlacedEggRenders = Workspace2:FindFirstChild("PlacedEggRenders")

		if not PlacedEggRenders then
			return nil
		end

		local v2068 = PlacedEggRenders:FindFirstChild(string.format("%d_%s", LocalPlayer2.UserId, p669))

		if v2068 and v2068:IsA("Model") then
			return v2068
		end

		for _, child in ipairs(PlacedEggRenders:GetChildren()) do
			if child:IsA("Model") then
				if child.Name:find(p669, 1, true) then
					return child
				end
			end
		end

		return nil
	end
	t93._projectGround = function(p670, p671)
		local Character = LocalPlayer2.Character
		local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
		local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

		if not HumanoidRootPart or not Humanoid then
			return nil
		end

		local raycastParams = RaycastParams.new()

		raycastParams.FilterType = Enum.RaycastFilterType.Exclude

		local filterDescendantsInstances = { Character }
		local PlacedEggRenders = Workspace2:FindFirstChild("PlacedEggRenders")

		if PlacedEggRenders then
			filterDescendantsInstances[#filterDescendantsInstances + 1] = PlacedEggRenders
		end

		raycastParams.FilterDescendantsInstances = filterDescendantsInstances
		raycastParams.IgnoreWater = false

		local hit = Workspace2:Raycast(Vector3.new(p671.X, math.max(p671.Y, HumanoidRootPart.Position.Y) + 40, p671.Z), Vector3.new(0, -160, 0), raycastParams)

		if hit then
			return Vector3.new(p671.X, hit.Position.Y + (HumanoidRootPart.Size.Y * 0.5 + (Humanoid.RigType == Enum.HumanoidRigType.R15 and math.max(Humanoid.HipHeight, 0.5) or 2)) + 0.05, p671.Z)
		end

		return nil
	end
	t93._destination = function(p672, p673)
		local Character = LocalPlayer2.Character
		local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")

		if not HumanoidRootPart then
			return nil
		end

		local Position = p673:GetPivot().Position
		local vector32 = Vector3.new(HumanoidRootPart.Position.X - Position.X, 0, HumanoidRootPart.Position.Z - Position.Z)
		local v2082 = p672:_projectGround(Position + (vector32.Magnitude > 0.001 and vector32.Unit or Vector3.new(0, 0, 1)) * 4.5)

		if v2082 then
			return lookAt(v2082, Vector3.new(Position.X, v2082.Y, Position.Z))
		end

		return nil
	end
	t93._shouldAbort = function(p674, p675, p676)
		if not p674.destroyed and p675 == p674.generation then
			if p676 or p674.config.enabled then
				if p674.captureRuntime and type(p674.captureRuntime.isEngaged) == "function" then
					if p674.captureRuntime:isEngaged() then
						return true
					end
				end

				if p674.travel and type(p674.travel.hasPendingPreEventSteal) == "function" then
					if p674.travel:hasPendingPreEventSteal() then
						return true
					end
				end

				local __ZeroinScrambleRuntime = genv.__ZeroinScrambleRuntime

				if __ZeroinScrambleRuntime and type(__ZeroinScrambleRuntime.isFightPending) == "function" and __ZeroinScrambleRuntime:isFightPending() then
					return true
				end

				local __ZeroinRiftRuntime = genv.__ZeroinRiftRuntime

				return __ZeroinRiftRuntime and type(__ZeroinRiftRuntime.isTradeReady) == "function" and __ZeroinRiftRuntime:isTradeReady() or false
			end
		end

		return true
	end
	t93._applyTarget = function(p677, p678, p679, p680)
		local v2085 = p677:_findModel(p678.uid)

		if not v2085 then
			p677:_setStatus("Waiting for placed egg model")

			return false
		end

		if not p677:_ensureEquipped() then
			p677:_setStatus("Unable to equip " .. p677.config.mutationType .. " consumable")

			return false
		end

		if p677.treadmillManager and type(p677.treadmillManager._syncActiveTreadmillSnapshot) == "function" then
			p677.treadmillManager:_syncActiveTreadmillSnapshot()
		end

		if p677.treadmillManager then
			if p677.treadmillManager:isEngaged() then
				if type(p677.treadmillManager._cancelIdle) == "function" then
					p677.treadmillManager:_cancelIdle(true)
				end

				if type(p677.treadmillManager._requestUnequip) == "function" then
					p677.treadmillManager:_requestUnequip()
				end
			end
		end

		local v2086 = p677:_destination(v2085)
		local HumanoidRootPart = LocalPlayer2.Character and LocalPlayer2.Character:FindFirstChild("HumanoidRootPart")

		if v2086 then
			if HumanoidRootPart then
				if (HumanoidRootPart.Position - v2086.Position).Magnitude > 8 then
					p677:_setStatus("Moving to " .. p678.name)

					if not p677.travel:travelAndWait(v2086, {
						groundedProfile = true,
						projectGroundPosition = function(p681)
							return p677:_projectGround(p681)
						end,
						abort = function()
							return p677:_shouldAbort(p679, p680)
						end
					}) or p677:_shouldAbort(p679, p680) then
						p677:_setStatus("Mutation travel interrupted")

						return false
					end
				end

				local v2088 = Save.Get()
				local EggInventory = v2088 and v2088.EggInventory and v2088.EggInventory[p678.uid]
				local v2090 = p677:_eligibleTargets()
				local v2091 = false

				for _, v in ipairs(v2090) do
					if v.uid == p678.uid then
						v2091 = true

						break
					end
				end

				if not (EggInventory and EggInventory.Placement ~= nil and p677:getConsumableCount() > 0 and v2091) then
					p677:_setStatus("Target changed before mutation")

					return false
				end

				if not BossMastery or not BossMastery.AskUseMutationConsumable then
					p677:_setStatus("Mutation remote unavailable")

					return false
				end

				p677:_setStatus("Applying " .. p677.config.mutationType .. " to " .. p678.name)

				local ok, result = pcall(BossMastery.AskUseMutationConsumable.InvokeServer, BossMastery.AskUseMutationConsumable, p678.uid)

				if not ok or type(result) ~= "table" or not result.Success then
					p677:_setStatus("Server rejected mutation request")

					return false
				end

				if result.Mutated then
					p677.stats.lastMutated = p678.name
					p677.successHoldUntil = os.clock() + 5
					p677:_setStatus("Mutation applied to " .. p678.name)
				else
					p677:_setStatus("Mutation missed; retrying")
				end

				return true
			end
		end

		p677:_setStatus("Placed egg position unavailable")

		return false
	end
	t93._run = function(p682, p683, p684)
		if p682.running or p682.destroyed then
			return
		end

		p682.running = true

		local v2096 = p682:_eligibleTargets()

		p682.stats.consumables = p682:getConsumableCount()

		local v2097 = v2096[1]

		if v2097 or not (os.clock() < p682.successHoldUntil) then
			if not v2097 then
				p682:_setStatus(p682:_noTargetReason())
			elseif p682.stats.consumables <= 0 then
				p682:_setStatus("No " .. p682.config.mutationType .. " consumables left")
			elseif p682:_shouldAbort(p683, p684) then
				if p683 == p682.generation then
					p682:_setStatus("Waiting for another automation")
				end
			else
				local autoMutate, v2099 = p682.coordinator:tryAcquire("auto_mutate", { v2097.uid })

				if autoMutate then
					p682:_applyTarget(v2097, p683, p684)
					p682.coordinator:release(autoMutate)
				else
					p682:_setStatus(v2099 or "Waiting for another automation")
				end
			end
		end

		p682.running = false

		if p683 == p682.generation then
			p682:_emit()
		end

		if p682.config.enabled and not p682.destroyed and not p684 then
			task.delay(0.9, function()
				p682:_schedule()
			end)
		end
	end
	t93._schedule = function(p685, p686)
		if p685.destroyed or p685.running or not p685.config.enabled and not p686 then
			return
		end

		local generation = p685.generation

		task.defer(function()
			local ok, result = xpcall(p685._run, debug.traceback, p685, generation, p686 == true)

			if not ok then
				p685.running = false
				p685.coordinator:forceRelease("auto_mutate")
				p685:_setStatus("Mutation runtime error")
				warn("[SAE][AutoMutate] " .. tostring(result))

				if p685.config.enabled and not p685.destroyed then
					task.delay(0.9, function()
						p685:_schedule()
					end)
				end
			end
		end)
	end
	t93.setEnabled = function(p687, p688)
		p687.config.enabled = p688 == true
		zeroinConfig.AutoMutate = p687.config.enabled
		p687.generation += 1
		p687:_setStatus(p687.config.enabled and "Scanning placed eggs" or "Disabled")

		if p687.config.enabled then
			p687:_schedule()
		else
			p687.coordinator:forceRelease("auto_mutate")
		end
	end
	t93.setMutationType = function(p689, p690)
		if table.find(t92, p690) then
			p689.config.mutationType = p690
		end

		zeroinConfig.AutoMutateType = p689.config.mutationType
		p689.manualConfirmation = nil
		p689.successHoldUntil = 0
		p689.generation += 1
		p689:_emit()
		p689:_schedule()

		return p689.config.mutationType
	end
	t93.setRarities = function(p691, p692)
		local t103 = {}
		local ipairs_ = ipairs
		local v2105 = type(p692) == "table" and p692 or { p692 }

		for _, v in ipairs_(v2105) do
			if type(v) == "string" and v ~= "" and not table.find(t103, v) then
				t103[#t103 + 1] = v
			end
		end

		p691.config.rarities = table.find(t103, "All") and { "All" } or #t103 > 0 and t103 or { "All" }
		zeroinConfig.AutoMutateRarities = table.clone(p691.config.rarities)
		p691.manualConfirmation = nil
		p691.successHoldUntil = 0
		p691.generation += 1
		p691:_emit()
		p691:_schedule()

		return table.clone(p691.config.rarities)
	end
	t93.setNames = function(p693, p694)
		local v2108 = p693:getPlacedEggNames()
		local names = {}
		local ipairs_ = ipairs
		local v2111 = type(p694) == "table" and p694 or { p694 }

		for _, v in ipairs_(v2111) do
			if table.find(v2108, v) and not table.find(names, v) then
				names[#names + 1] = v
			end
		end

		p693.config.names = names
		zeroinConfig.AutoMutateNames = table.clone(names)
		p693.manualConfirmation = nil
		p693.successHoldUntil = 0
		p693.generation += 1
		p693:_emit()
		p693:_schedule()

		return table.clone(names)
	end
	t93.setMinValue = function(p695, p696)
		p695.config.minValuePerSec = math.max(tonumber(p696) or 0, 0)
		zeroinConfig.AutoMutateMinValue = p695.config.minValuePerSec
		p695.manualConfirmation = nil
		p695.successHoldUntil = 0
		p695.generation += 1
		p695:_emit()
		p695:_schedule()

		return p695.config.minValuePerSec
	end
	t93.requestOnce = function(p697)
		if p697.running then
			return false, "Auto Consume Mutation is busy"
		end

		local v2114 = p697:_eligibleTargets()[1]

		if not v2114 then
			p697.manualConfirmation = nil
			p697:_setStatus(p697:_noTargetReason())

			return false
		end

		local v2115 = table.concat({
			p697.config.mutationType,
			v2114.uid
		}, ":")
		local manualConfirmation = p697.manualConfirmation

		if manualConfirmation and not (manualConfirmation.signature ~= v2115 or manualConfirmation.expiresAt < os.clock()) then
			p697.manualConfirmation = nil
			p697.generation += 1
			p697:_schedule(true)

			return true
		end

		p697.manualConfirmation = {
			signature = v2115,
			expiresAt = os.clock() + 8
		}
		p697:_setStatus(string.format("Ready: %s -> %s ($%s/s) - press again", p697.config.mutationType, v2114.name, t20.formatMoneyShort(v2114.rate)))

		return false, "Press again within 8 seconds to confirm"
	end
	t93.getSnapshot = function(p698)
		return p698:_snapshot()
	end
	t93.destroy = function(p699)
		if p699.destroyed then
			return
		end

		p699.destroyed = true
		p699.config.enabled = false
		p699.generation += 1
		p699.coordinator:forceRelease("auto_mutate")

		for _, resource in ipairs(p699.resources) do
			v2000(resource)
		end

		table.clear(p699.resources)
		table.clear(p699.listeners)
	end

	return t93
end

local v2119 = v1988()

local function v2120()
	local Players2 = game:GetService("Players")
	local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
	local LocalPlayer2 = Players2.LocalPlayer
	local t104 = {}

	t104.__index = t104

	local vector32 = Vector3.new(8, 1, 8)

	t104.new = function()
		local obj = setmetatable({}, t104)

		obj.enabled = zeroinConfig.AutoCaptureEgg == true
		obj.destroyed = false
		obj.running = false
		obj.worker = nil
		obj.hoverPad = nil
		obj.hoverOrigin = nil
		obj.status = "Off"
		obj.changeCallbacks = {}
		obj.connections = {}
		obj:_bindSignals()

		if obj.enabled then
			obj:setEnabled(true)
		end

		return obj
	end
	t104.onChanged = function(p700, p701)
		if type(p701) == "function" then
			table.insert(p700.changeCallbacks, p701)
		end
	end
	t104._notify = function(p702, p703, p704)
		local t105 = {
			enabled = p702.enabled,
			status = p702.status,
			title = p703 or "Capture The Egg: " .. p702.status,
			content = p704 or "Waiting for event..."
		}

		for _, changeCallback in ipairs(p702.changeCallbacks) do
			pcall(changeCallback, t105)
		end
	end
	t104.isEventActive = function()
		return workspace:GetAttribute("Event_CaptureTheEgg") == true or workspace:GetAttribute("Event_CaptureTheEggGameplay") == true or workspace:GetAttribute("Event_CaptureTheEggUid") ~= nil
	end
	t104.getEventEggUid = function()
		local attribute = workspace:GetAttribute("Event_CaptureTheEggUid")

		if attribute and attribute ~= "" then
			return tostring(attribute)
		end

		local ok, result = pcall(function()
			return require(ReplicatedStorage2.Data.CaptureTheEgg)
		end)

		if ok and result and result.EggUidAttribute then
			local attribute2 = workspace:GetAttribute(result.EggUidAttribute)

			if attribute2 and attribute2 ~= "" then
				return tostring(attribute2)
			end
		end

		return nil
	end
	t104.isCarryingEventEgg = function(p705)
		local ok, result = pcall(function()
			return require(ReplicatedStorage2.Client.EggState)
		end)

		if not ok or not result then
			return false
		end

		local ReadLocalState = result.ReadLocalState and result.ReadLocalState()
		local v2137 = p705:getEventEggUid()

		if ReadLocalState and ReadLocalState.IsCarrying then
			if v2137 and ReadLocalState.Uid == v2137 then
				return true
			end

			if not v2137 then
				return true
			end
		end

		if v2137 then
			local v2138 = result.ReadFieldEgg(v2137)

			if v2138 and v2138.CarrierUserId == LocalPlayer2.UserId then
				return true
			end
		end

		return false
	end
	t104.isEngaged = function(p706)
		return not p706.destroyed and p706.enabled and p706:isEventActive()
	end
	t104._ensureHoverPad = function(p707, p708)
		if p707.hoverPad and p707.hoverPad.Parent then
			p707.hoverPad.CFrame = cFrameNew(p708.X, p708.Y - 3, p708.Z)
		else
			local Part = Instance.new("Part")

			Part.Name = "__CaptureHoverPad"
			Part.Size = vector32
			Part.Anchored = true
			Part.CanCollide = true
			Part.Transparency = 1
			Part.CFrame = cFrameNew(p708.X, p708.Y - 3, p708.Z)
			Part.Parent = workspace
			p707.hoverPad = Part
		end

		return p707.hoverPad
	end
	t104._destroyHoverPad = function(p709)
		if p709.hoverPad then
			pcall(p709.hoverPad.Destroy, p709.hoverPad)
			p709.hoverPad = nil
		end
	end
	t104._startWorker = function(p710)
		if p710.worker then
			return
		end

		p710.running = true
		p710.worker = task.spawn(function()
			while not p710.destroyed and p710.enabled do
				if p710:isEventActive() then
					local Character = LocalPlayer2.Character
					local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
					local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

					if HumanoidRootPart and Humanoid and not (Humanoid.Health <= 0) then
						local v2143 = p710:getEventEggUid()

						if p710:isCarryingEventEgg() then
							if not p710.hoverOrigin then
								p710.hoverOrigin = Vector3.new(HumanoidRootPart.Position.X, math.max(HumanoidRootPart.Position.Y, 71) + 45, HumanoidRootPart.Position.Z)
							end

							local Y = p710.hoverOrigin.Y
							local v2145 = os.clock() * 0.35
							local vector33 = Vector3.new(p710.hoverOrigin.X + math.cos(v2145) * 12, Y, p710.hoverOrigin.Z + math.sin(v2145) * 12)

							p710:_ensureHoverPad(vector33)
							HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
							HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
							HumanoidRootPart.CFrame = cFrameNew(vector33)
							p710.status = "Holding Egg (+45 studs)"
							p710:_notify("Holding Event Egg 🏆", string.format("Hovering at safe altitude (+45 studs) · Timer ticking up!"))
							task.wait(0.05)
						else
							p710:_destroyHoverPad()
							p710.hoverOrigin = nil

							local ok, result = pcall(function()
								return require(ReplicatedStorage2.Client.EggState)
							end)
							local v2149 = ok and v2143 and result.ReadFieldEgg(v2143)

							if v2149 and v2149.CarrierUserId and v2149.CarrierUserId ~= LocalPlayer2.UserId then
								local playerByUserId = Players2:GetPlayerByUserId(v2149.CarrierUserId)
								local Character2 = playerByUserId and playerByUserId.Character
								local HumanoidRootPart2 = Character2 and Character2:FindFirstChild("HumanoidRootPart")

								if HumanoidRootPart2 then
									p710.status = "Attacking Carrier"
									p710:_notify("Attacking Carrier ⚔️", string.format("Chasing %s to force drop the egg!", playerByUserId.DisplayName or playerByUserId.Name))

									local v2153 = HumanoidRootPart2.Position - HumanoidRootPart.Position
									local Magnitude = v2153.Magnitude

									if Magnitude > 7 then
										HumanoidRootPart.CFrame = cFrameNew(HumanoidRootPart.Position + v2153.Unit * math.min(Magnitude - 4, 4.25), HumanoidRootPart2.Position)
									else
										HumanoidRootPart.CFrame = cFrameNew(HumanoidRootPart2.Position + Vector3.new(0, 2, 0))

										if genv.__ZeroinGodMode then
											local v2155 = genv.__ZeroinGodMode:_equipBat()

											if v2155 then
												genv.__ZeroinGodMode:_swing(v2155, HumanoidRootPart2)
											end
										end
									end
								else
									p710.status = "Tracking Carrier"
									p710:_notify("Tracking Carrier...", "Carrier is moving or respawning")
								end

								task.wait(0.05)
							else
								p710.status = "Securing Egg"
								p710:_notify("Securing Event Egg ⚡", "Flying to egg to snatch it!")

								local v2156

								if v2149 and v2149.BottomCFrame then
									v2156 = v2149.BottomCFrame.Position + Vector3.new(0, 3, 0)
								else
									local CaptureTheEggSpawn = workspace:FindFirstChild("CaptureTheEggSpawn", true) or workspace:FindFirstChild("AdminAbuseEggSpawn", true)

									if CaptureTheEggSpawn and CaptureTheEggSpawn:IsA("BasePart") then
										v2156 = CaptureTheEggSpawn.Position + Vector3.new(0, 3, 0)
									end
								end

								if v2156 then
									local v2158 = v2156 - HumanoidRootPart.Position
									local Magnitude = v2158.Magnitude

									if Magnitude > 6 then
										HumanoidRootPart.CFrame = cFrameNew(HumanoidRootPart.Position + v2158.Unit * math.min(Magnitude, 4.5))
									else
										HumanoidRootPart.CFrame = cFrameNew(v2156)

										local Remotes = require(ReplicatedStorage2.Shared.Remotes)

										if Remotes and Remotes.EggWorld and Remotes.EggWorld.AskFieldEggCarry then
											pcall(function()
												Remotes.EggWorld.AskFieldEggCarry:InvokeServer({
													Uid = v2143
												})
											end)
										end
									end
								end

								task.wait(0.05)
							end
						end
					else
						p710:_destroyHoverPad()
						task.wait(0.5)
					end
				else
					p710:_destroyHoverPad()
					p710.hoverOrigin = nil
					p710.status = "Waiting for event"
					p710:_notify("Capture The Egg Event", "Waiting for event to begin...")
					task.wait(1)
				end
			end

			p710:_destroyHoverPad()
			p710.running = false
			p710.worker = nil
		end)
	end
	t104.setEnabled = function(p711, p712)
		local enabled = p712 == true

		if p711.enabled == enabled and p711.worker then
			return
		end

		p711.enabled = enabled
		zeroinConfig.AutoCaptureEgg = enabled

		if enabled then
			p711:_startWorker()
		else
			if p711.worker then
				pcall(task.cancel, p711.worker)
				p711.worker = nil
			end

			p711:_destroyHoverPad()
			p711.hoverOrigin = nil
			p711.running = false
			p711.status = "Off"
			p711:_notify("Capture The Egg Event", "Auto Capture is disabled")
		end
	end
	t104._bindSignals = function(p713)
		pcall(function()
			table.insert(p713.connections, workspace:GetAttributeChangedSignal("Event_CaptureTheEgg"):Connect(function()
				if p713.enabled then
					if not p713.destroyed then
						p713:_startWorker()
					end
				end
			end))
			table.insert(p713.connections, workspace:GetAttributeChangedSignal("Event_CaptureTheEggGameplay"):Connect(function()
				if p713.enabled and not p713.destroyed then
					p713:_startWorker()
				end
			end))
			table.insert(p713.connections, workspace:GetAttributeChangedSignal("Event_CaptureTheEggUid"):Connect(function()
				if p713.enabled and not p713.destroyed then
					p713:_startWorker()
				end
			end))
		end)
	end
	t104.destroy = function(p714)
		if p714.destroyed then
			return
		end

		p714.destroyed = true
		p714:setEnabled(false)

		for _, connection4 in ipairs(p714.connections) do
			pcall(connection4.Disconnect, connection4)
		end

		table.clear(p714.connections)
		p714:_destroyHoverPad()
	end

	return t104
end

local v2164 = v2120()

local function v2165()
	local Players2 = game:GetService("Players")
	local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
	local LocalPlayer2 = Players2.LocalPlayer
	local Remotes = require(ReplicatedStorage2.Shared.Remotes)
	local PlotState2 = require(ReplicatedStorage2.Client.PlotState)
	local t106 = {}

	t106.__index = t106
	t106.new = function(p715, p716)
		local obj = setmetatable({}, t106)

		obj.coordinator = p715
		obj.travel = p716
		obj.destroyed = false
		obj.listeners = {}
		obj.resources = {}
		obj.config = {
			disableDuringAutomation = true,
			idleFarm = false
		}
		obj.stats = {
			mode = "Idle",
			boost = "Waiting"
		}
		obj.busy = p715 and p715:getSnapshot().busy == true or false
		obj.idleGeneration = 0
		obj.lastEquipAt = 0
		obj.activeTreadmill = nil
		obj.travelingToTreadmill = false
		obj.treadmillEquipPending = false
		obj.unequipGuardRunning = false
		obj.backgroundYieldRunning = false
		obj.lastBackgroundYieldAt = 0
		obj.treadmillStateRevision = 0
		obj:_listenActiveTreadmill()
		obj:_syncActiveTreadmillSnapshot()
		obj:_listenCoordinator()
		obj:_listenSpeedGain()

		return obj
	end
	t106._snapshot = function(p717)
		return {
			mode = p717.stats.mode,
			boost = p717.stats.boost,
			disableDuringAutomation = p717.config.disableDuringAutomation,
			idleFarm = p717.config.idleFarm
		}
	end
	t106._emit = function(p718)
		local v2173 = p718:_snapshot()

		for _, listener in ipairs(p718.listeners) do
			pcall(listener, v2173)
		end
	end
	t106._setStatus = function(p719, p720, p721)
		if p720 ~= nil then
			p719.stats.mode = p720
		end

		if p721 ~= nil then
			p719.stats.boost = p721
		end

		p719:_emit()
	end
	t106.subscribe = function(p722, p723)
		table.insert(p722.listeners, p723)
		pcall(p723, p722:_snapshot())

		return function()
			local v2176 = table.find(p722.listeners, p723)

			if v2176 then
				table.remove(p722.listeners, v2176)
			end
		end
	end
	t106._requestUnequip = function()
		local ok, result, result2 = pcall(function()
			return Remotes.Treadmill.AskDoff:InvokeServer()
		end)

		if not ok then
			return false, tostring(result)
		end

		if result == false then
			return false, tostring(result2 or "Server rejected")
		end

		return true
	end

	local s3 = "_shouldBlockTreadmill"

	local function v2181(p724)
		local v2182 = not p724.destroyed

		return v2182 and p724.busy and p724.config.disableDuringAutomation
	end

	t106[s3] = v2181
	t106._startUnequipGuard = function(p725)
		if p725.unequipGuardRunning or not p725:_shouldBlockTreadmill() or p725.activeTreadmill == nil then
			return
		end

		p725.unequipGuardRunning = true
		task.spawn(function()
			local n33 = 0.15

			while p725:_shouldBlockTreadmill() do
				if p725.activeTreadmill == nil then
					break
				end

				local v2184, v2185 = p725:_requestUnequip()

				p725:_setStatus("Automation active", v2184 and "Blocked" or "Release retry: " .. tostring(v2185))
				task.wait(n33)
				n33 = math.min(n33 * 2, 0.75)
			end

			p725.unequipGuardRunning = false

			if p725:_shouldBlockTreadmill() and p725.activeTreadmill ~= nil then
				p725:_startUnequipGuard()
			end
		end)
	end
	t106._cancelIdle = function(p726, p727)
		p726.idleGeneration += 1

		local idleGeneration = p726.idleGeneration

		if p727 then
			p726:_requestUnequip()
		end

		task.delay(0.5, function()
			if not p726.destroyed and not p726.busy then
				if p726.config.idleFarm and p726.idleGeneration == idleGeneration then
					p726:_startIdle()
				end
			end
		end)
	end
	t106.setDisableDuringAutomation = function(p728, p729)
		p728.config.disableDuringAutomation = p729 == true

		if p728.busy and p728.config.disableDuringAutomation then
			p728:_cancelIdle(true)
			p728:_startUnequipGuard()
			p728:_setStatus("Automation active", "Blocked")
		elseif not p728.busy and p728.config.idleFarm then
			p728:_startIdle()
		end
	end
	t106.setIdleFarm = function(p730, p731)
		p730.config.idleFarm = p731 == true

		if not p730.config.idleFarm then
			p730:_cancelIdle(true)
			p730:_setStatus(p730.busy and "Automation active" or "Idle", "Disabled")
		elseif not p730.busy then
			p730:_startIdle()
		end
	end
	t106.setCaptureTheEggRuntime = function(p732, p733)
		p732.captureTheEggRuntime = p733
	end
	t106._resolveStandCFrame = function()
		local v2187 = PlotState2.ResolveLocalSlot()
		local v2188 = PlotState2.ResolveFolder()
		local v2189 = v2188 and v2187 and v2188:FindFirstChild(tostring(v2187))
		local TreadmillBottom = v2189 and v2189:FindFirstChild("TreadmillBottom")

		if not TreadmillBottom or not TreadmillBottom:IsA("BasePart") then
			return nil
		end

		local Character = LocalPlayer2.Character
		local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
		local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

		if not HumanoidRootPart or not Humanoid then
			return nil
		end

		local v2194

		if Humanoid.RigType == Enum.HumanoidRigType.R15 then
			v2194 = HumanoidRootPart.Size.Y * 0.5 + math.max(Humanoid.HipHeight, 0.5)
		else
			v2194 = HumanoidRootPart.Size.Y * 0.5 + 2
		end

		return TreadmillBottom.CFrame * cFrameNew(0, TreadmillBottom.Size.Y * 0.5 + v2194 + 0.05, 0)
	end
	t106.isEngaged = function(p734)
		return p734.activeTreadmill ~= nil or p734.travelingToTreadmill or p734.treadmillEquipPending
	end
	t106.yieldForBackground = function(p735)
		if p735.destroyed then
			return
		end

		p735:_cancelIdle(false)

		if p735.backgroundYieldRunning then
			return
		end

		p735.backgroundYieldRunning = true
		task.spawn(function()
			local n34 = 0.15

			while not p735.destroyed do
				if p735.coordinator and p735.coordinator:isBackgroundBusy() then
					p735.lastBackgroundYieldAt = os.clock()
					p735:_setStatus("Idle", "Yielding to background inventory")
					p735:_requestUnequip()
					task.wait(n34)

					if p735:_syncActiveTreadmillSnapshot() then
						n34 = math.min(n34 * 2, 0.75)

						continue
					end
				end

				break
			end

			p735.backgroundYieldRunning = false

			if not p735.destroyed and not p735:isEngaged() then
				p735:_setStatus("Idle", "Background inventory ready")
			end
		end)
	end
	t106._startIdle = function(p736)
		if p736.destroyed or p736.busy or not p736.config.idleFarm then
			return
		end

		p736.idleGeneration += 1

		local idleGeneration = p736.idleGeneration
		local now = os.clock()

		task.spawn(function()
			local ok, result = xpcall(function()
				while not p736.destroyed and not p736.busy and p736.config.idleFarm and idleGeneration == p736.idleGeneration do
					if p736.captureTheEggRuntime and type(p736.captureTheEggRuntime.isEngaged) == "function" then
						if p736.captureTheEggRuntime:isEngaged() then
							now = os.clock()
							p736:_setStatus("Idle", "Yielding to Capture The Egg")
							task.wait(0.25)

							continue
						end
					end

					if p736.coordinator then
						if p736.coordinator:isBackgroundBusy() then
							now = os.clock()
							p736:_setStatus("Idle", "Waiting for background inventory")
							task.wait(0.25)

							continue
						end
					end

					if p736.eggRuntime and p736.eggRuntime.enabled and not p736.eggRuntime.resetBlocked then
						local v2200 = false

						if p736.eggRuntime.records then
							for _, record in pairs(p736.eggRuntime.records) do
								if p736.eggRuntime:_matches(record) then
									v2200 = true

									break
								end
							end
						end

						if v2200 then
							now = os.clock()
							p736:_setStatus("Idle", "Yielding to Auto Steal")
							task.wait(0.25)

							continue
						end
					end

					if genv.__ZeroinIsAutoSellEggBusy and genv.__ZeroinIsAutoSellEggBusy() then
						now = os.clock()
						p736:_setStatus("Idle", "Waiting for Auto Sell Egg")
						task.wait(0.25)
					else
						local v2203 = 1 - (os.clock() - now)

						if v2203 > 0 then
							p736:_setStatus("Idle", string.format("Starting in %.0fs", math.ceil(v2203)))
							task.wait(math.min(v2203, 0.25))
						else
							local v2204 = p736:_resolveStandCFrame()

							if v2204 then
								p736.travelingToTreadmill = true
								p736:_setStatus("Moving", "Waiting")

								local travel = p736.travel and p736.travel:travelAndWait(v2204, {
									abort = function()
										local destroyed = p736.destroyed or p736.busy

										return destroyed or not p736.config.idleFarm or idleGeneration ~= p736.idleGeneration or p736.coordinator and p736.coordinator:isBackgroundBusy() or genv.__ZeroinIsAutoSellEggBusy and genv.__ZeroinIsAutoSellEggBusy()
									end
								})

								p736.travelingToTreadmill = false

								if not travel then
									if not p736.busy and p736.config.idleFarm then
										p736:_setStatus("Idle", "Travel failed")
										task.wait(1)
									end
								elseif not p736.busy and p736.config.idleFarm and idleGeneration == p736.idleGeneration then
									if p736.coordinator then
										if p736.coordinator:isBackgroundBusy() then
											continue
										end
									end

									if not genv.__ZeroinIsAutoSellEggBusy or not genv.__ZeroinIsAutoSellEggBusy() then
										task.wait(0.35)

										if not p736.busy and p736.config.idleFarm then
											if idleGeneration == p736.idleGeneration then
												if p736.coordinator then
													if p736.coordinator:isBackgroundBusy() then
														continue
													end
												end

												if not genv.__ZeroinIsAutoSellEggBusy or not genv.__ZeroinIsAutoSellEggBusy() then
													p736.treadmillEquipPending = true

													local ok3, result, result2 = pcall(function()
														return Remotes.Treadmill.AskWearStill:InvokeServer()
													end)

													if ok3 and result ~= false then
														p736.lastEquipAt = os.clock()
														p736:_setStatus("Active", "Waiting for gain")
														task.delay(2, function()
															if not p736.destroyed and p736.activeTreadmill == nil then
																p736.treadmillEquipPending = false
															end
														end)
													else
														p736.treadmillEquipPending = false
														p736:_setStatus("Preparing carry", "Activation failed: " .. tostring(result2 or result))
													end

													local v2210 = os.clock() + 8

													while (p736.activeTreadmill ~= nil or os.clock() < v2210) and not p736.destroyed and not p736.busy and p736.config.idleFarm and idleGeneration == p736.idleGeneration do
														local ok2 = not p736.coordinator

														if not ok2 then
															ok2 = not p736.coordinator:isBackgroundBusy()
														end

														if not ok2 then
															break
														end

														local ok = not (not not p736.captureTheEggRuntime and type(p736.captureTheEggRuntime.isEngaged) == "function")

														if not ok then
															ok = not p736.captureTheEggRuntime:isEngaged()
														end

														if not ok then
															p736:_cancelIdle(true)
															p736:_setStatus("Idle", "Yielding to Capture The Egg")

															break
														end

														if not p736.eggRuntime or not p736.eggRuntime.enabled or p736.eggRuntime.resetBlocked then
															if genv.__ZeroinIsAutoSellEggBusy and genv.__ZeroinIsAutoSellEggBusy() then
																p736:_cancelIdle(true)
																p736:_setStatus("Idle", "Yielding to Auto Sell Egg")

																break
															end

															task.wait(0.25)

															continue
														end

														local v2213 = false

														if p736.eggRuntime.records then
															for _, record in pairs(p736.eggRuntime.records) do
																if p736.eggRuntime:_matches(record) then
																	v2213 = true

																	break
																end
															end
														end

														if v2213 then
															p736:_cancelIdle(true)
															p736:_setStatus("Idle", "Yielding to Auto Steal")

															break
														end

														if genv.__ZeroinIsAutoSellEggBusy and genv.__ZeroinIsAutoSellEggBusy() then
															p736:_cancelIdle(true)
															p736:_setStatus("Idle", "Yielding to Auto Sell Egg")

															break
														end

														task.wait(0.25)
													end
												end
											end
										end
									end
								end
							else
								p736:_setStatus("Idle", "Position unavailable")
								task.wait(2)
							end
						end
					end
				end
			end, debug.traceback)

			if not ok then
				warn("[SAE][treadmill] idle error:\n" .. tostring(result))
			end
		end)
	end
	t106._onCoordinator = function(p737, p738)
		local busy = p737.busy

		p737.busy = p738.busy == true

		if p737.busy then
			p737:_cancelIdle(p737.config.disableDuringAutomation)
			p737:_startUnequipGuard()
			p737:_setStatus("Automation active", p737.config.disableDuringAutomation and "Blocked" or "Unchanged")
		elseif busy then
			if p737.config.idleFarm then
				p737:_startIdle()
			else
				p737:_setStatus("Idle", "Disabled")
			end
		end
	end
	t106._listenCoordinator = function(p739)
		if not p739.coordinator then
			return
		end

		table.insert(p739.resources, p739.coordinator:subscribe(function(p740)
			p739:_onCoordinator(p740)
		end))
		table.insert(p739.resources, p739.coordinator:subscribeBackground(function(p741)
			if p741.busy then
				p739:_cancelIdle(false)
				p739:_setStatus("Idle", "Waiting for background inventory")
			elseif not p739.destroyed and not p739.busy and p739.config.idleFarm then
				p739:_startIdle()
			end
		end))
	end
	t106._syncActiveTreadmillSnapshot = function(p742)
		local ok, result, treadmillStateRevision = pcall(function()
			return Remotes.Treadmill.AskRenderSnapshot:InvokeServer()
		end)

		if not ok or type(result) ~= "table" then
			return p742.activeTreadmill ~= nil
		end

		if type(treadmillStateRevision) == "number" and treadmillStateRevision < p742.treadmillStateRevision then
			return p742.activeTreadmill ~= nil
		end

		local v2220 = table.find(result, LocalPlayer2.UserId) ~= nil

		if type(treadmillStateRevision) == "number" then
			p742.treadmillStateRevision = treadmillStateRevision
		end

		p742.activeTreadmill = v2220 and "snapshot" or nil

		if not v2220 then
			p742.treadmillEquipPending = false
		end

		return v2220
	end
	t106._listenActiveTreadmill = function(p743)
		local RenderStateShifted = Remotes.Treadmill.RenderStateShifted

		if RenderStateShifted then
			table.insert(p743.resources, RenderStateShifted.OnClientEvent:Connect(function(p744, p745, p746)
				if p744 ~= LocalPlayer2 or type(p745) ~= "boolean" then
					return
				end

				if type(p746) == "number" and p746 <= p743.treadmillStateRevision then
					return
				end

				p743.treadmillStateRevision = type(p746) == "number" and p746 or p743.treadmillStateRevision + 1
				p743.activeTreadmill = p745 and true or nil
				p743.treadmillEquipPending = false

				if p745 and p743:_shouldBlockTreadmill() then
					p743:_startUnequipGuard()
				elseif not p745 and p743:_shouldBlockTreadmill() then
					p743:_setStatus("Automation active", "Blocked")
				elseif not p745 then
					p743:_setStatus("Idle", p743.config.idleFarm and "Released" or "Disabled")
				elseif not p743.busy then
					p743:_setStatus("Active", "Waiting for gain")
				end
			end))
		end
	end
	t106._listenSpeedGain = function(p747)
		local SpeedGained = Remotes.Treadmill.SpeedGained

		if SpeedGained then
			table.insert(p747.resources, SpeedGained.OnClientEvent:Connect(function(p748, p749)
				if p749 ~= "Treadmill" then
					return
				end

				p747.activeTreadmill = p747.activeTreadmill or true
				p747.treadmillEquipPending = false

				if p747:_shouldBlockTreadmill() then
					p747:_startUnequipGuard()

					return
				end

				p747:_setStatus("Active", "Gain ticking")
			end))
		end
	end
	t106.destroy = function(p750)
		if p750.destroyed then
			return
		end

		p750.destroyed = true
		p750:_cancelIdle(true)

		for _, resource in ipairs(p750.resources) do
			pcall(function()
				if typeof(resource) == "RBXScriptConnection" then
					resource:Disconnect()
				elseif type(resource) == "function" then
					resource()
				elseif type(resource) == "table" and type(resource.Disconnect) == "function" then
					resource:Disconnect()
				end
			end)
		end

		table.clear(p750.resources)
		table.clear(p750.listeners)
	end
	t106.Destroy = t106.destroy

	return t106
end

local v2225 = v2165()
local v2226 = v593.new()

v2226:subscribe(function(p751)
	local operation = p751.operation

	zeroinConfig.IsStealing = operation == "auto_steal"
	zeroinConfig.IsRiftTrading = operation == "auto_the_rift"

	local __ZeroinScrambleRuntime = genv.__ZeroinScrambleRuntime

	zeroinConfig.IsScrambleFarming = operation == "auto_dr_scramble" or __ZeroinScrambleRuntime and __ZeroinScrambleRuntime.locked == true or false
end)

local v2229 = v1327.new(v631, v2226, true)

genv.__ZeroinEggRuntime = v2229

local function v2230()
	local t107 = {}

	t107.__index = t107
	t107.new = function()
		local obj = setmetatable({}, t107)

		obj.destroyed = false

		return obj
	end
	t107.setRiftObjective = function(p752, p753, p754)
		table.clear(zeroinConfig.RiftObjectiveCategories)

		if p753 then
			local ipairs_ = ipairs
			local v2234 = p754 or {}

			for _, v in ipairs_(v2234) do
				zeroinConfig.RiftObjectiveCategories[v] = (zeroinConfig.RiftObjectiveCategories[v] or 0) + 1
			end

			if t20.AutoPlaceLoop then
				task.spawn(t20.AutoPlaceLoop)
			end

			if t20.AutoHatchLoop then
				task.spawn(t20.AutoHatchLoop)
			end
		end
	end
	t107.destroy = function(p755)
		p755.destroyed = true
		table.clear(zeroinConfig.RiftObjectiveCategories)
	end

	return t107
end

local v2237 = v2230().new()
local v2238 = v1586.new(v2226, v2229, v2237, v2229)

v2238:setTargetPrize(zeroinConfig.RiftTargetPrize)

local v2239 = v1775.new(v2229)

v2229:setDrScrambleRuntime(v2239)
genv.__ZeroinRiftRuntime = v2238
genv.__ZeroinScrambleRuntime = v2239
v2239:setEnabled(zeroinConfig.AutoScramble == true)
v2239:setShopItems(zeroinConfig.ScrambleShopItems)
v2239:setShopAmount(zeroinConfig.ScrambleShopAmount)
v2239:setShopInterval(zeroinConfig.ScrambleShopInterval)
v2239:setAutoBuy(zeroinConfig.AutoBuyScrambleShop == true)
v2229:setRiftRuntime(v2238)

local v2240 = v2164.new()

genv.__ZeroinCaptureTheEggRuntime = v2240
v2229:setCaptureTheEggRuntime(v2240)

local v2241 = v2225.new(v2226, v2229)

genv.__ZeroinTreadmillManager = v2241
v2229:setTreadmillManager(v2241)
v2241:setCaptureTheEggRuntime(v2240)

if zeroinConfig.AutoTreadmillIdle then
	v2241:setIdleFarm(true)
end

local v2242 = v1987.new(v2226, v2229, v2241, v2240)

genv.__ZeroinFuseRuntime = v2242
v2242:setPriority(zeroinConfig.AutoFusePriority)
v2242:setRarities(zeroinConfig.AutoFuseRarities)
v2242:setKeepPerCategory(zeroinConfig.AutoFuseKeepPerPet)
v2242:setMaxWeightKg(zeroinConfig.AutoFuseMaxWeightKg)
v2242:setEnabled(zeroinConfig.AutoFuse == true)

local v2243 = v2119.new(v2226, v2229, v2241, v2240)

genv.__ZeroinAutoMutateRuntime = v2243

local v2244 = zeroinConfig.AutoMutate == true

zeroinConfig.AutoMutate = false
v2243:setMutationType(zeroinConfig.AutoMutateType)
v2243:setRarities(zeroinConfig.AutoMutateRarities)
v2243:setNames(zeroinConfig.AutoMutateNames)
v2243:setMinValue(zeroinConfig.AutoMutateMinValue)
v2243:setEnabled(v2244)

local v2245 = v1377.new(v2229)

v2245:install()
v2245:setEnabled(zeroinConfig.AntiGuardKnockback == true)
genv.__ZeroinAntiGuard = v2245
v2229.antiGuard = v2245

local v2246 = v1437.new(v2229)

v2246:setEnabled(zeroinConfig.GodMode == nil and true or zeroinConfig.GodMode == true)
genv.__ZeroinGodMode = v2246
v2229:setStealMode((zeroinConfig.StealMode == "Instant" or zeroinConfig.StealMode == "Semi Teleport") and "Instant" or "Tween")
v2229:setSpeed(zeroinConfig.TweenSpeedMultiplier or 80)
v2229:setStealZigzag(zeroinConfig.StealZigzag == true)

if zeroinConfig.StealMinValue and zeroinConfig.StealMinValue > 0 then
	v2229:setMinValuePerSec(zeroinConfig.StealMinValue)
end

if zeroinConfig.StealAreas and not table.find(zeroinConfig.StealAreas, "None") and #zeroinConfig.StealAreas > 0 then
	local t108 = {}

	for _, stealArea in ipairs(zeroinConfig.StealAreas) do
		if stealArea ~= "None" then
			table.insert(t108, stealArea == "Angels & Demons" and "Light Dark" or stealArea)
		end
	end

	v2229:setFilter("areas", t108)
	v2229:setFilterEnabled("area", #t108 > 0)
end

if zeroinConfig.StealRarities and not table.find(zeroinConfig.StealRarities, "None") and #zeroinConfig.StealRarities > 0 then
	local t109 = {}

	for _, stealRarity in ipairs(zeroinConfig.StealRarities) do
		if stealRarity ~= "None" then
			table.insert(t109, stealRarity)
		end
	end

	v2229:setFilter("rarities", t109)
	v2229:setFilterEnabled("rarity", #t109 > 0)
end

if zeroinConfig.StealNamesFilter and not table.find(zeroinConfig.StealNamesFilter, "None") and #zeroinConfig.StealNamesFilter > 0 then
	local t110 = {}

	for _, v in ipairs(zeroinConfig.StealNamesFilter) do
		if v ~= "None" then
			table.insert(t110, v)
		end
	end

	v2229:setFilter("names", t110)
	v2229:setFilterEnabled("name", #t110 > 0)
end

v2229:markStartupSettled()
v2238:onChanged(function(p756)
	zeroinConfig.AutoRift = p756.enabled == true
	genv.__ZeroinRiftStatus = p756
	table.clear(zeroinConfig.RiftProtectedPetUids)

	local ipairs_ = ipairs
	local protectedUids = v2238.protectedUids or {}

	for _, protectedUid in ipairs_(protectedUids) do
		zeroinConfig.RiftProtectedPetUids[protectedUid] = true
	end
end)

local function v2260(p757)
	zeroinConfig.AutoRift = p757 == true
	v2238:setEnabled(p757)

	if p757 then
		if t20.AutoPlaceLoop then
			task.spawn(t20.AutoPlaceLoop)
		end

		if t20.AutoHatchLoop then
			task.spawn(t20.AutoHatchLoop)
		end
	end
end
local function v2261(p758)
	zeroinConfig.AutoScramble = p758 == true
	v2239:setEnabled(p758)
end
local function v2262(p759)
	zeroinConfig.AutoBuyScrambleShop = p759 == true
	v2239:setAutoBuy(p759)
end

local u2263

local function v2264(p760)
	local v2265 = p760 == true
	local v2266

	if v2229 and type(v2229.setStealFromPlayers) == "function" then
		v2265, v2266 = v2229:setStealFromPlayers(v2265)
	end

	zeroinConfig.StealFromPlayers = v2265 == true

	if not (p760 ~= true or zeroinConfig.StealFromPlayers) then
		task.defer(function()
			if u2263 and u2263.Value == true then
				u2263:Set(false)
			end
		end)
	end

	return zeroinConfig.StealFromPlayers, v2266
end
local function v2267(p761)
	zeroinConfig.DropAtFirstArea = p761 == true

	if v2229 and type(v2229.setDropAtFirstArea) == "function" then
		v2229:setDropAtFirstArea(p761)
	end
end

v2264(zeroinConfig.StealFromPlayers == true)
genv.__ZeroinSetAutoRift = v2260
genv.__ZeroinSetAutoScramble = v2261
genv.__ZeroinSetAutoBuyScrambleShop = v2262
genv.__ZeroinSetStealFromPlayers = v2264
genv.__ZeroinSetDropAtFirstArea = v2267

local function v2268()
	if v2237 then
		v2237:destroy()
	end

	v2238:destroy()
	v2226:forceRelease("auto_the_rift")
	v2226:forceRelease("auto_place")

	if genv.__ZeroinRiftRuntime == v2238 then
		genv.__ZeroinRiftRuntime = nil
	end

	if genv.__ZeroinSetAutoRift == v2260 then
		genv.__ZeroinSetAutoRift = nil
	end

	if genv.__ZeroinRiftCleanup == v2268 then
		genv.__ZeroinRiftCleanup = nil
	end
end

genv.__ZeroinRiftCleanup = v2268
genv.__ZeroinEggRuntimeCleanup = function()
	if v2229 then
		pcall(v2229.destroy, v2229)
	end

	if v2241 then
		pcall(v2241.destroy, v2241)
	end

	if v2240 then
		pcall(v2240.destroy, v2240)
	end

	if genv.__ZeroinEggRuntime == v2229 then
		genv.__ZeroinEggRuntime = nil
	end

	if genv.__ZeroinSetStealFromPlayers == v2264 then
		genv.__ZeroinSetStealFromPlayers = nil
	end

	if genv.__ZeroinSetDropAtFirstArea == v2267 then
		genv.__ZeroinSetDropAtFirstArea = nil
	end

	if genv.__ZeroinTreadmillManager == v2241 then
		genv.__ZeroinTreadmillManager = nil
	end

	if genv.__ZeroinCaptureTheEggRuntime == v2240 then
		genv.__ZeroinCaptureTheEggRuntime = nil
	end
end
genv.__ZeroinAntiGuardCleanup = function()
	if v2245 then
		pcall(v2245.destroy, v2245)
	end

	if v2246 then
		pcall(v2246.destroy, v2246)
	end

	if genv.__ZeroinAntiGuard == v2245 then
		genv.__ZeroinAntiGuard = nil
	end

	if genv.__ZeroinGodMode == v2246 then
		genv.__ZeroinGodMode = nil
	end
end

local function v2269()
	v2239:destroy()
	v2226:forceRelease("auto_dr_scramble")

	if genv.__ZeroinScrambleRuntime == v2239 then
		genv.__ZeroinScrambleRuntime = nil
		genv.__ZeroinSetAutoScramble = nil
		genv.__ZeroinSetAutoBuyScrambleShop = nil
	end

	if genv.__ZeroinScrambleCleanup == v2269 then
		genv.__ZeroinScrambleCleanup = nil
	end
end

genv.__ZeroinScrambleCleanup = v2269

local function v2270()
	v2242:destroy()
	v2226:forceRelease("auto_fuse")

	if genv.__ZeroinFuseRuntime == v2242 then
		genv.__ZeroinFuseRuntime = nil
	end

	genv.__ZeroinFuseStatus = nil

	if genv.__ZeroinFuseCleanup == v2270 then
		genv.__ZeroinFuseCleanup = nil
	end
end

genv.__ZeroinFuseCleanup = v2270

local function v2271()
	v2243:destroy()
	v2226:forceRelease("auto_mutate")

	if genv.__ZeroinAutoMutateRuntime == v2243 then
		genv.__ZeroinAutoMutateRuntime = nil
	end

	genv.__ZeroinAutoMutateStatus = nil

	if genv.__ZeroinAutoMutateCleanup == v2271 then
		genv.__ZeroinAutoMutateCleanup = nil
	end
end

genv.__ZeroinAutoMutateCleanup = v2271

local t111 = {
	Main = function()
		local v2273 = v513:AddTab({
			Name = "Main",
			Icon = "house"
		}):AddSection({
			Title = "Auto Farm",
			Layout = "Columns",
			ColumnGap = 6,
			ItemGap = 2
		})

		v2273:AddToggle({
			Title = "Auto Steal",
			Column = "Left",
			Row = 1,
			Default = zeroinConfig.AutoSteal == true,
			Callback = function(p762)
				zeroinConfig.AutoSteal = p762

				if v2229 then
					v2229:setEnabled(p762)
				end
			end
		})
		v2273:AddToggle({
			Title = "Auto Treadmill",
			Content = "Automatically ride plot treadmill when idle",
			Column = "Right",
			Row = 1,
			Default = zeroinConfig.AutoTreadmillIdle == true,
			Callback = function(p763)
				zeroinConfig.AutoTreadmillIdle = p763

				if v2241 then
					v2241:setIdleFarm(p763)
				end
			end
		})
		v2273:AddToggle({
			Title = "Anti Knock Back",
			Content = "Blocks chicken & guard hits, knockback, and ragdoll",
			Column = "Left",
			Row = 2,
			Default = true,
			Callback = function(p764)
				zeroinConfig.AntiGuardKnockback = p764

				if v2245 then
					v2245:setEnabled(p764)
				end
			end
		})
		v2273:AddToggle({
			Title = "God Mode",
			Content = "Equip bat & spam hit nearby players when egg is dropped",
			Column = "Right",
			Row = 2,
			Default = zeroinConfig.GodMode == nil and true or zeroinConfig.GodMode == true,
			Callback = function(p765)
				zeroinConfig.GodMode = p765

				if v2246 then
					v2246:setEnabled(p765)
				end
			end
		})

		local v2274 = v2273:AddInput({
			Title = "Speed",
			Content = "Auto Steal tween x10 (20 = 200, 80 = 800, 120 = 1200 studs/s)",
			Column = "Left",
			Row = 3,
			Default = tostring(zeroinConfig.TweenSpeedMultiplier or 80),
			Callback = function(p766)
				local v2275 = tonumber(p766)

				if not v2275 then
					v2275 = zeroinConfig.TweenSpeedMultiplier or 80
				end

				v333(v2275)

				if v2229 then
					v2229:setSpeed(v2275)
				end
			end
		})
		local v2276 = v2273
		local AddInput = v2273.AddInput
		local t112 = {
			Title = "Steal By Value",
			Content = "Minimum value; supports k, m, b",
			Column = "Right",
			Row = 3
		}
		local StealMinValueInput = zeroinConfig.StealMinValueInput

		if not StealMinValueInput then
			StealMinValueInput = tostring(zeroinConfig.StealMinValue or 0)
		end

		t112.Default = StealMinValueInput
		t112.Callback = function(p767)
			if zeroinConfig:applyStealValueInput(p767) and v2229 then
				v2229:setMinValuePerSec(zeroinConfig.StealMinValue)
			end
		end
		AddInput(v2276, t112)
		getgenv().__zeroinSetSpeed = function(p768)
			local v2280 = tonumber(p768)

			if v2280 then
				if v2274 and v2274.SetValue then
					pcall(function()
						v2274:SetValue(tostring(v2280))
					end)
				end

				v333(v2280)

				if v2229 then
					v2229:setSpeed(v2280)
				end

				return true
			end

			return false
		end

		local t113 = { "None" }

		if not pcall(function()
			local Directory = require(game:GetService("ReplicatedStorage").Data.Areas).Directory
			local ok, result = pcall(function()
				return require(game:GetService("ReplicatedStorage").Data.Assets)
			end)

			if ok and result and result.Directory then
				local Directory2 = result.Directory
				local t114 = {}

				for _, v in pairs(Directory) do
					if type(v) == "table" and type(v.DropTable) == "table" then
						for _, v2 in ipairs(v.DropTable) do
							local v2291 = v2[1]

							if not (type(v2291) ~= "string" or t114[v2291]) then
								t114[v2291] = true

								local v2292 = Directory2[v2291]

								t113[#t113 + 1] = v2292 and v2292.DisplayName or v2291
							end
						end
					end
				end
			end
		end) or #t113 <= 1 then
			t113 = { "None" }
		end

		table.sort(t113, function(p769, p770)
			if p769 == "None" then
				return true
			end

			if p770 == "None" then
				return false
			end

			return p769 < p770
		end)
		v2273:AddToggle({
			Title = "Steal Zigzag",
			Content = "Return through alternating wall-bounded waypoints before depositing",
			Column = "Full",
			Row = 4,
			Default = zeroinConfig.StealZigzag == true,
			Callback = function(p771)
				zeroinConfig.StealZigzag = p771 == true

				if v2229 then
					v2229:setStealZigzag(zeroinConfig.StealZigzag)
				end
			end
		})
		u2263 = v2273:AddToggle({
			Title = "Steal From Players",
			Content = "Chase and hit players carrying filtered eggs with bat to steal their egg",
			Column = "Full",
			Row = 5,
			Default = zeroinConfig.StealFromPlayers == true,
			Callback = v2264
		})
		v2273:AddToggle({
			Title = "Drop Egg At Forest",
			Content = "Deliver stolen eggs to Forest and drop them instead of returning to Safe Zone",
			Column = "Full",
			Row = 6,
			Default = zeroinConfig.DropAtFirstArea == true,
			Callback = v2267
		})

		local v2293

		v2293 = v2273:AddDropdown({
			Title = "Steal Mode",
			Content = "Tween or Instant (Semi Teleport) using selected egg filters",
			Column = "Full",
			Row = 8,
			Options = {
				"Tween",
				"Instant"
			},
			Default = zeroinConfig.StealMode and { zeroinConfig.StealMode } or { "Tween" },
			Multi = false,
			Callback = function(p772)
				local v2294 = v309(p772, v2293)
				local v2295 = type(v2294) == "table" and v2294[1] or p772
				local stealMode = (v2295 == "Instant" or v2295 == "Semi Teleport") and "Instant" or "Tween"

				zeroinConfig.StealMode = stealMode

				if v2229 then
					v2229:setStealMode(stealMode)
				end
			end
		})

		local v2297

		v2297 = v2273:AddDropdown({
			Title = "Filter By Egg Name",
			Content = "Choose specific eggs to steal",
			Column = "Full",
			Row = 9,
			Options = t113,
			Default = zeroinConfig.StealNamesFilter,
			Multi = true,
			Callback = function(p773)
				local v2298 = v309(p773, v2297)

				zeroinConfig.StealNamesFilter = v2298

				if v2229 then
					local t115 = {}

					if not table.find(v2298, "None") then
						for _, v in ipairs(v2298) do
							if v ~= "None" then
								table.insert(t115, v)
							end
						end
					end

					v2229:setFilter("names", t115)
					v2229:setFilterEnabled("name", #t115 > 0)
				end
			end
		})

		local t116 = { "None" }
		local t117 = {
			None = "None"
		}
		local t118 = {
			"Lake",
			"Jungle",
			"Desert",
			"Snow",
			"Volcano",
			"Abyss Ocean",
			"Prehistoric",
			"Cosmic",
			"Cherry Blossom",
			"Titan Temple",
			"Light Dark"
		}
		local t119 = {}

		if not pcall(function()
			for k, v in pairs(require(game:GetService("ReplicatedStorage").Data.Areas).Directory) do
				if type(v) == "table" then
					if type(v.DropTable) == "table" then
						t119[k] = v.DisplayName or k
					end
				end
			end
		end) or next(t119) == nil then
			for _, v in ipairs(t118) do
				t119[v] = v == "Light Dark" and "Angels & Demons" or v
			end
		end

		local function v2310(p774)
			local v2311 = t119[p774]

			if type(v2311) ~= "string" or v2311 == "" then
				return
			end

			table.insert(t116, v2311)
			t117[v2311] = p774
		end

		local t120 = {
			None = true,
			Forest = true
		}

		for _, v in ipairs(t118) do
			if t119[v] then
				v2310(v)
				t120[v] = true
			end
		end

		local t121 = {}

		for k in pairs(t119) do
			if not t120[k] then
				table.insert(t121, k)
			end
		end

		table.sort(t121)

		for _, v in ipairs(t121) do
			v2310(v)
		end

		local t122 = {}
		local ipairs_ = ipairs
		local StealAreas = zeroinConfig.StealAreas or { "None" }

		for _, StealArea in ipairs_(StealAreas) do
			table.insert(t122, StealArea == "Light Dark" and "Angels & Demons" or StealArea)
		end

		local v2324

		v2324 = v2273:AddDropdown({
			Title = "Select Area",
			Content = "Choose which area to farm",
			Column = "Full",
			Row = 10,
			Options = t116,
			Default = t122,
			Multi = true,
			Callback = function(p775)
				local v2325 = v309(p775, v2324)

				zeroinConfig.StealAreas = v2325

				if v2229 then
					local t123 = {}

					if not table.find(v2325, "None") then
						for _, v in ipairs(v2325) do
							if v ~= "None" then
								table.insert(t123, t117[v] or v)
							end
						end
					end

					v2229:setFilter("areas", t123)
					v2229:setFilterEnabled("area", #t123 > 0)
				end
			end
		})

		local v2329

		v2329 = v2273:AddDropdown({
			Title = "Filter By Rarity",
			Content = "Choose egg rarities to prioritize",
			Column = "Full",
			Row = 11,
			Options = {
				"None",
				"Common",
				"Uncommon",
				"Rare",
				"Epic",
				"Legendary",
				"Mythic",
				"Cosmic",
				"Secret",
				"Eternal",
				"Divine"
			},
			Default = zeroinConfig.StealRarities or { "None" },
			Multi = true,
			Callback = function(p776)
				local v2330 = v309(p776, v2329)

				zeroinConfig.StealRarities = v2330

				if v2229 then
					local t124 = {}

					if not table.find(v2330, "None") then
						for _, v in ipairs(v2330) do
							if v ~= "None" then
								table.insert(t124, v)
							end
						end
					end

					v2229:setFilter("rarities", t124)
					v2229:setFilterEnabled("rarity", #t124 > 0)
				end
			end
		})

		local v2334 = v513:AddTab({
			Name = "Event",
			Icon = "party-popper"
		})
		local v2335 = v2334:AddSection({
			Title = "Capture The Egg",
			Layout = "Grid",
			ItemGap = 4
		})
		local v2336 = v2335:AddParagraph({
			Title = "Capture The Egg Event",
			Content = "Waiting for event...",
			Icon = "trophy",
			Column = "Full",
			Row = 1
		})

		v2335:AddToggle({
			Title = "Auto Capture The Egg",
			Content = "Snatch event egg, hover at 45 studs safe altitude, and hold until victory",
			Column = "Full",
			Row = 2,
			Default = zeroinConfig.AutoCaptureEgg == true,
			Callback = function(p777)
				zeroinConfig.AutoCaptureEgg = p777

				if v2240 then
					v2240:setEnabled(p777)
				end
			end
		})

		if v2240 then
			v2240:onChanged(function(p778)
				pcall(function()
					if v2336 then
						local v2337 = v2336
						local SetTitle = v2336.SetTitle
						local title = p778.title

						SetTitle(v2337, title or "Capture The Egg Event")
						v2336:SetContent(p778.content or "Waiting for event...")
					end
				end)
			end)
		end

		local v2340 = v2334:AddSection({
			Title = "The Rift",
			Layout = "Grid",
			ItemGap = 4
		})
		local v2341 = v2340:AddParagraph({
			Title = "Auto Riftborn",
			Content = "Collect required eggs, place and hatch them, then trade matching pets at The Rift. Runs alongside Auto Steal and pauses only for the final trade.",
			Icon = "sparkles",
			Column = "Full",
			Row = 1
		})

		v2340:AddToggle({
			Title = "Auto The Rift",
			Content = "Automatically complete the active Rift requirements",
			Column = "Full",
			Row = 2,
			Default = zeroinConfig.AutoRift == true,
			Callback = function(p779)
				v2260(p779)
			end
		})

		local v2342

		v2342 = v2340:AddDropdown({
			Title = "Target Prize",
			Content = "Choose which Rift Egg prize to target (or None for any active)",
			Column = "Full",
			Row = 3,
			Options = {
				"None",
				"Riftborn Egg",
				"Riftbeasts Egg",
				"Shattered Rift Egg"
			},
			Default = zeroinConfig.RiftTargetPrize and { zeroinConfig.RiftTargetPrize } or { "None" },
			Multi = false,
			Callback = function(p780)
				local v2343 = v309(p780, v2342)
				local v2344 = type(v2343) == "table" and v2343[1] or p780
				local v2345

				if v2344 ~= "None" then
					v2345 = v2344
				end

				zeroinConfig.RiftTargetPrize = v2345

				if v2238 then
					v2238:setTargetPrize(v2345)
				end
			end
		})

		local v2346 = v2334:AddSection({
			Title = "Dr. Scramble Event",
			Layout = "Grid",
			ItemGap = 4
		})
		local v2347 = v2346:AddParagraph({
			Title = "Dr. Scramble · IDLE",
			Content = "Waits for filtered Auto Steal eggs, then farms highest health drones during an outbreak window.",
			Icon = "bot",
			Column = "Full",
			Row = 1
		})

		v2346:AddToggle({
			Title = "Auto Dr. Scramble",
			Content = "Tween into drone auto-attack range and advance when its Health reaches zero",
			Column = "Full",
			Row = 2,
			Default = zeroinConfig.AutoScramble == true,
			Callback = v2261
		})

		local v2348 = v2334:AddSection({
			Title = "Dr. Scramble Shop",
			Layout = "Grid",
			ItemGap = 4
		})
		local v2349 = v2348:AddParagraph({
			Title = "Scramble Shop · IDLE",
			Content = "Select items and the number of purchases for each item.",
			Icon = "shopping-cart",
			Column = "Full",
			Row = 1
		})

		v2348:AddToggle({
			Title = "Auto Buy Scramble Shop",
			Content = "Buy selected offers serially while Samples and stock are available",
			Column = "Full",
			Row = 2,
			Default = zeroinConfig.AutoBuyScrambleShop == true,
			Callback = v2262
		})

		local v2350

		v2350 = v2348:AddDropdown({
			Title = "Scramble Shop Items",
			Content = "Select one or more offers to buy",
			Column = "Full",
			Row = 3,
			Options = {
				"Scrambled",
				"Experiment #001",
				"Nibbles #013",
				"2x Cash Booster",
				"1.25x Speed",
				"2x Treadmill Booster"
			},
			Default = zeroinConfig.ScrambleShopItems,
			Multi = true,
			Callback = function(p781)
				local v2351 = v309(p781, v2350)

				zeroinConfig.ScrambleShopItems = type(v2351) == "table" and v2351 or {}
				v2239:setShopItems(zeroinConfig.ScrambleShopItems)
			end
		})
		v2348:AddInput({
			Title = "Buy Count per Item",
			Content = "Number of serial purchases for each selected offer (1-100)",
			Column = "Full",
			Row = 4,
			Default = tostring(zeroinConfig.ScrambleShopAmount or 1),
			Callback = function(p782)
				zeroinConfig.ScrambleShopAmount = v2239:setShopAmount(p782)
			end
		})
		v2348:AddInput({
			Title = "Scramble Shop Interval",
			Content = "Seconds to wait before starting the next purchase cycle (1-3600)",
			Column = "Full",
			Row = 5,
			Default = tostring(zeroinConfig.ScrambleShopInterval or 15),
			Callback = function(p783)
				zeroinConfig.ScrambleShopInterval = v2239:setShopInterval(p783)
			end
		})

		local function v2352()
			local __ZeroinRiftStatus = genv.__ZeroinRiftStatus

			if zeroinConfig.AutoRift and __ZeroinRiftStatus then
				pcall(function()
					local v2354 = math.max(tonumber(__ZeroinRiftStatus.rotation) or 0, 0)
					local v2355 = math.floor(v2354 / 3600)
					local v2356 = math.floor(v2354 % 3600 / 60)
					local v2357 = tostring(__ZeroinRiftStatus.status or "Active")
					local s4 = "ACTIVE"
					local v2359 = string.lower(v2357)

					if string.find(v2359, "placing") or string.find(v2359, "placed") then
						s4 = "PLACING"
					elseif string.find(v2359, "hatch") then
						s4 = "HATCHING"
					elseif string.find(v2359, "stealing") or string.find(v2359, "steal") then
						s4 = "STEALING"
					elseif string.find(v2359, "trading") or string.find(v2359, "trade") then
						s4 = "TRADING"
					end

					local v2360 = __ZeroinRiftStatus.targetPrize and __ZeroinRiftStatus.targetPrize ~= "None" and string.format("Target: %s · ", __ZeroinRiftStatus.targetPrize)

					v2360 = v2360 or ""
					v2341:SetTitle(string.format("The Rift · %s", s4))
					v2341:SetContent(string.format([[%sBanner: %s (%dh %02dm)
Progress: %d/%d Ready (Missing: %s)
Action: %s]], v2360, tostring(__ZeroinRiftStatus.banner or "Unknown"), v2355, v2356, tonumber(__ZeroinRiftStatus.ready) or 0, tonumber(__ZeroinRiftStatus.total) or 3, tostring(__ZeroinRiftStatus.missing or "None"), v2357))
				end)
			else
				pcall(function()
					v2341:SetTitle("The Rift · IDLE")
					v2341:SetContent("Collect required eggs, place and hatch them, then trade matching pets at The Rift.")
				end)
			end

			local v2361 = v2239:getSnapshot()

			pcall(function()
				local v2362 = v2361.active and "LIVE" or v2361.enabled and "ARMED" or "IDLE"
				local v2363 = math.max(0, math.floor(tonumber(v2361.secondsLeft) or 0))
				local v2364 = string.format("%02d:%02d", math.floor(v2363 / 60), v2363 % 60)

				v2347:SetTitle("Dr. Scramble · " .. v2362 .. " · " .. v2364)

				local v2365 = tonumber(v2361.health) or 0
				local v2366 = tonumber(v2361.maxHealth) or 0
				local targetTier = v2361.targetTier or v2361.active and "Searching..." or "None"
				local v2368 = v2366 > 0 and string.format(" | HP: %d/%d", v2365, v2366) or ""
				local v2369 = v2347
				local SetContent = v2347.SetContent
				local format = string.format

				SetContent(v2369, format("%s: %s\nTarget: %s%s\nStatus: %s", v2361.active and "Ends in" or "Next outbreak", v2364, targetTier, v2368, tostring(v2361.status or "Waiting")))
			end)
			pcall(function()
				v2349:SetTitle("Scramble Shop · " .. (zeroinConfig.AutoBuyScrambleShop and "ACTIVE" or "IDLE"))
				v2349:SetContent(string.format("Samples: %d · Selected: %d · Count each: %d · Interval: %ds\nStatus: %s", tonumber(v2361.samples) or 0, tonumber(v2361.shopItemCount) or 0, tonumber(v2361.shopAmount) or 1, tonumber(v2361.shopInterval) or 15, tostring(v2361.shopStatus or "Off")))
			end)
		end

		local t125 = {}

		genv.__ZeroinEventStatusGeneration = t125

		local ok, result = pcall(v2352)

		if not ok then
			warn("[Event UI] Initial status update failed:", result)
		end

		local v2375 = v512:CreateCleanupToken()

		coroutine.wrap(function()
			while v2375.Alive and genv.__ZeroinEventStatusGeneration == t125 do
				local ok2, result2 = pcall(v2352)

				if not ok2 then
					warn("[Event UI] Status update failed:", result2)
				end

				task.wait(1)
			end
		end)()
	end,
	Auto = function()
		local v2378 = v513:AddTab({
			Name = "Auto",
			Icon = "repeat-2"
		})
		local v2379 = v2378:AddSection({
			Title = "Egg Automation",
			Layout = "Columns",
			ColumnGap = 6,
			ItemGap = 2
		})

		t20.AutoPlaceLoop = function()
			if zeroinConfig.IsAutoPlaceWorkerRunning then
				return
			end

			zeroinConfig.IsAutoPlaceWorkerRunning = true

			while zeroinConfig.AutoPlace or zeroinConfig.AutoRift do
				local autoPlace
				local ok, result = pcall(function()
					if zeroinConfig.IsStealing then
						return
					end

					local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
					local EggState2 = require(ReplicatedStorage2.Client.EggState)
					local Assets = require(ReplicatedStorage2.Data.Assets)
					local PlotState2 = require(ReplicatedStorage2.Client.PlotState)
					local ResolveLocalSlot = PlotState2.ResolveLocalSlot and PlotState2.ResolveLocalSlot() or PlotState2.GetMySlot()
					local ResolveFolder = PlotState2.ResolveFolder and PlotState2.ResolveFolder() or PlotState2.GetPlotsFolder() or workspace:FindFirstChild("Plots")
					local v2389 = ResolveFolder and ResolveLocalSlot and ResolveFolder:FindFirstChild(tostring(ResolveLocalSlot))

					if not v2389 and ResolveFolder then
						for _, child in ipairs(ResolveFolder:GetChildren()) do
							local PlotSign = child:FindFirstChild("PlotSign")
							local PlayerPlotSign = PlotSign and PlotSign:FindFirstChild("PlayerPlotSign")

							if PlayerPlotSign and PlayerPlotSign:FindFirstChild("Frame") then
								if PlayerPlotSign.Frame:FindFirstChild("PlayerName") then
									local v2394 = string.gsub(PlayerPlotSign.Frame.PlayerName.Text, "<[^>]+>", "")

									if string.find(string.lower(v2394), string.lower(LocalPlayer.Name)) or string.find(string.lower(v2394), string.lower(LocalPlayer.DisplayName)) then
										v2389 = child

										break
									end
								end
							end
						end
					end

					if not v2389 then
						return
					end

					local ToUpdate = v2389:FindFirstChild("ToUpdate")
					local PetArea = ToUpdate and ToUpdate:FindFirstChild("PetArea")
					local CenterPoint = v2389:FindFirstChild("CenterPoint")

					CenterPoint = CenterPoint or ToUpdate and ToUpdate:FindFirstChild("CenterPoint") or PetArea

					if not PetArea or not PetArea:IsA("BasePart") then
						return
					end

					local function v2398()
						local t126 = {}
						local t127 = {}
						local Save = require(ReplicatedStorage2.Shared.Save)

						pcall(function()
							local v2402 = EggState2.GetOwnerRuntimeRecords(LocalPlayer.UserId)

							if type(v2402) == "table" then
								for k, v in pairs(v2402) do
									t127[k] = v
								end
							end
						end)
						pcall(function()
							local v2405 = Save.Get()
							local EggInventory = v2405 and v2405.EggInventory

							if type(EggInventory) == "table" then
								for k, v in pairs(EggInventory) do
									if not t127[k] then
										t127[k] = v
									end
								end
							end
						end)

						local v2409 = table.clone(zeroinConfig.RiftObjectiveCategories)
						local n35 = 0
						local t128 = {}

						for k, v in pairs(t127) do
							if v.Placement == nil then
								local AssetCategory = v.AssetCategory
								local v2415 = AssetCategory and Assets.Directory[AssetCategory]
								local s5 = "Unknown"

								if v2415 and v2415.Rarity then
									local Rarity = v2415.Rarity

									s5 = Rarity.DisplayName or Rarity._id or Rarity.Name or "Unknown"
								end

								local v2418

								if #zeroinConfig.PlaceRarities == 0 or table.find(zeroinConfig.PlaceRarities, "None") or table.find(zeroinConfig.PlaceRarities, "All") then
									v2418 = true
								else
									v2418 = table.find(zeroinConfig.PlaceRarities, s5) ~= nil
								end

								local v2419 = tonumber(v.Kg) or tonumber(v.Weight) or tonumber(v.kg)

								if not v2419 and v2415 then
									v2419 = tonumber(v2415.Kg) or tonumber(v2415.Weight) or tonumber(v2415.kg)
								end

								local v2420 = v2419 or 0
								local v2421 = (v2409[AssetCategory] or 0) > 0

								if v2421 or zeroinConfig.AutoPlace and v2418 then
									table.insert(t126, {
										Uid = k,
										Rarity = s5,
										Kg = v2420,
										IsRift = v2421
									})

									if v2421 then
										v2409[AssetCategory] -= 1
									end
								end
							else
								n35 += 1

								local Position

								if typeof(v.Placement) == "CFrame" then
									Position = v.Placement.Position
								elseif typeof(v.Placement) == "Vector3" then
									Position = v.Placement
								elseif type(v.Placement) == "table" and v.Placement.Position then
									Position = v.Placement.Position
								end

								if Position then
									table.insert(t128, Position)
								end
							end
						end

						table.sort(t126, function(p784, p785)
							if p784.IsRift == p785.IsRift then
								return p784.Kg > p785.Kg
							end

							return p784.IsRift == true
						end)

						return t126, n35, t128
					end

					local v2423, v2424 = v2398()
					local Character = LocalPlayer.Character
					local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
					local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
					local CFrame_2

					if #v2423 == 0 or v2424 >= 30 then
						return
					end

					autoPlace = v2226:tryAcquire("auto_place", {})

					if not autoPlace then
						return
					end

					if HumanoidRootPart then
						CFrame_2 = HumanoidRootPart.CFrame
					end

					if zeroinConfig.IsStealing then
						return
					end

					zeroinConfig.IsPlacing = true

					local function v2430()
						return not zeroinConfig.AutoPlace and not zeroinConfig.AutoRift or zeroinConfig.IsStealing or zeroinConfig.IsRiftTrading or zeroinConfig.IsScrambleFarming
					end

					if HumanoidRootPart then
						local v2431 = PetArea.CFrame * cFrameNew(0, 3, 0)

						if not v514(HumanoidRootPart.Position + Vector3.new(0, 2, 0), v2431.Position + Vector3.new(0, 2, 0), Character) then
							v339(HumanoidRootPart, Humanoid, cFrameNew(518.66, 70.57, -364.73) * Angles(3.1415926535897931, -1.5676547341413067, 3.1415926535897931), v2430)

							if v2430() then
								return
							end
						end

						v339(HumanoidRootPart, Humanoid, v2431, v2430)

						if v2430() then
							return
						end

						local n36 = 0

						while n36 < 0.3 and not v2430() do
							task.wait(0.05)
							n36 += 0.05
						end

						if zeroinConfig.IsStealing then
							return
						end

						if not zeroinConfig.AutoPlace and not zeroinConfig.AutoRift then
							return
						end
					end

					local n37 = 0
					local v2434 = false

					while not v2434 and (zeroinConfig.AutoPlace or zeroinConfig.AutoRift) and not v2430() do
						local v2435, v2436, v2437 = v2398()

						if #v2435 ~= 0 and not (v2436 >= 30) then
							local v2438 = v2436
							local v2439 = v2437
							local v2440 = false

							for _, v in ipairs(v2435) do
								if not zeroinConfig.AutoPlace and not zeroinConfig.AutoRift or v2434 or v2430() then
									break
								end

								if v2438 >= 30 then
									v2434 = true

									break
								end

								local Uid = v.Uid

								if EggState2.RequestEquipTool(Uid) and not v2430() then
									task.wait(0.15)

									local v2444 = false

									while n37 < 30 and not v2444 and not v2430() do
										local v2445

										if CenterPoint then
											while n37 < 30 do
												local v2446 = PetArea.Size.X - 6
												local v2447 = v2446 / 10
												local v2448 = CenterPoint.CFrame:PointToObjectSpace(PetArea.CFrame * Vector3.new(-(v2446 / 2) + v2447 / 2 + n37 % 10 * v2447, 0, -((PetArea.Size.Z - 6) / 2) + 3 + math.floor(n37 / 10) * 6))
												local cFrame = cFrameNew(v2448.X, -0.5, v2448.Z)
												local v2450 = false

												for _, v2 in ipairs(v2439) do
													if (v2 - cFrame.Position).Magnitude < 1 then
														v2450 = true

														break
													end
												end

												if not v2450 then
													v2445 = cFrame

													break
												end

												n37 += 1
											end
										end

										if not v2445 then
											v2434 = true

											break
										end

										if not v2430() then
											local v2453, v2454 = EggState2.RequestPlaceEgg(Uid, v2445)

											if v2453 then
												table.insert(v2439, v2445.Position)
												v2438 += 1
												v2444 = true
												v2440 = true
												n37 += 1
												task.wait(0.15)

												continue
											end

											local v2455 = v2454 and string.lower(tostring(v2454)) or ""

											if not string.find(v2455, "full") and not string.find(v2455, "limit") and not string.find(v2455, "capacity") and not string.find(v2455, "maximum") then
												table.insert(v2439, v2445.Position)
												n37 += 1
												task.wait(0.1)

												continue
											end

											if zeroinConfig.AutoPlace then
												zeroinConfig.AutoPlace = false
											end

											v2434 = true

											break
										end

										break
									end
								end
							end

							if v2440 then
								task.wait(0.2)

								continue
							end
						end

						break
					end

					if CFrame_2 and HumanoidRootPart and not zeroinConfig.IsStealing then
						if not v514(HumanoidRootPart.Position + Vector3.new(0, 2, 0), CFrame_2.Position + Vector3.new(0, 2, 0), Character) then
							v339(HumanoidRootPart, Humanoid, cFrameNew(518.66, 70.57, -364.73) * Angles(3.1415926535897931, -1.5676547341413067, 3.1415926535897931), v2430)
						end

						if v2430() then
							return
						end

						v339(HumanoidRootPart, Humanoid, CFrame_2, v2430)
						task.wait(0.2)
					end
				end)

				if autoPlace then
					v2226:release(autoPlace)
					autoPlace = nil
				end

				zeroinConfig.IsPlacing = false

				if not ok then
					warn("Auto Place Error: " .. tostring(result))
				end

				task.wait(1.5)
			end

			zeroinConfig.IsAutoPlaceWorkerRunning = false
		end
		v2379:AddToggle({
			Title = "Auto Place Egg",
			Column = "Left",
			Row = 1,
			Default = zeroinConfig.AutoPlace == true,
			Callback = function(p786)
				zeroinConfig.AutoPlace = p786

				if p786 then
					task.spawn(t20.AutoPlaceLoop)
				end
			end
		})

		local v2456

		v2456 = v2379:AddDropdown({
			Title = "Place Egg Rarity",
			Content = "Choose which egg rarities to place",
			Column = "Full",
			Row = 2,
			Options = {
				"None",
				"All",
				"Common",
				"Uncommon",
				"Rare",
				"Epic",
				"Legendary",
				"Mythic",
				"Cosmic",
				"Secret",
				"Eternal",
				"Divine"
			},
			Default = zeroinConfig.PlaceRarities,
			Multi = true,
			Callback = function(p787)
				zeroinConfig.PlaceRarities = v309(p787, v2456)
			end
		})
		t20.AutoHatchLoop = function()
			if zeroinConfig.IsAutoHatchWorkerRunning then
				return
			end

			zeroinConfig.IsAutoHatchWorkerRunning = true
			task.spawn(function()
				local t129 = {}

				while zeroinConfig.AutoHatch or zeroinConfig.AutoRift do
					task.wait(1.5)
					pcall(function()
						local EggState2 = require(game:GetService("ReplicatedStorage").Client.EggState)
						local v2459 = EggState2.GetOwnerRuntimeRecords(LocalPlayer.UserId)

						if not v2459 then
							return
						end

						local t130 = {}
						local v2461 = table.clone(zeroinConfig.RiftObjectiveCategories)

						for k, v in pairs(v2459) do
							if v.Placement ~= nil then
								if not zeroinConfig.AutoHatch then
									if not ((v2461[v.AssetCategory] or 0) > 0) then
										continue
									end
								end

								table.insert(t130, k)

								if not zeroinConfig.AutoHatch then
									v2461[v.AssetCategory] = (v2461[v.AssetCategory] or 1) - 1
								end
							end
						end

						local now = os.time()

						for _, v in ipairs(t130) do
							if not zeroinConfig.AutoHatch and not zeroinConfig.AutoRift then
								break
							end

							if not t129[v] or not (now < t129[v]) then
								local v2467 = v2459[v]

								if zeroinConfig.AutoHatch or v2467 and v266(v2467.AssetCategory) then
									local v2468 = false

									if type(EggState2.IsReadyToHatch) == "function" then
										local ok, result = pcall(EggState2.IsReadyToHatch, v)

										v2468 = ok and result == true
									end

									if v2468 or v2467.Ready == true or not t129[v] then
										if EggState2.RequestHatchEgg(v) then
											EggState2.RequestCompleteHatchEgg(v)
											t129[v] = nil
											task.wait(0.1)
										else
											t129[v] = now + 10
										end
									end
								end
							end
						end
					end)
				end

				zeroinConfig.IsAutoHatchWorkerRunning = false
			end)
		end
		v2379:AddToggle({
			Title = "Auto Hatch Egg",
			Column = "Right",
			Row = 1,
			Default = zeroinConfig.AutoHatch == true,
			Callback = function(p788)
				zeroinConfig.AutoHatch = p788

				if p788 and t20.AutoHatchLoop then
					task.spawn(t20.AutoHatchLoop)
				end
			end
		})

		local v2471 = v2378:AddSection({
			Title = "Auto Consume Mutation",
			Layout = "Columns",
			ColumnGap = 6,
			ItemGap = 2
		})
		local v2472 = v2471:AddParagraph({
			Title = "Auto Consume Mutation | IDLE",
			Content = "Automatically apply Boss or Scrambled consumables to eligible placed eggs.",
			Icon = "sparkles",
			Column = "Full",
			Row = 1
		})

		v2471:AddToggle({
			Title = "Auto Consume Mutation",
			Content = "Uses the selected consumable on matching eggs placed in your plot",
			Column = "Full",
			Row = 2,
			Default = zeroinConfig.AutoMutate == true,
			Callback = function(p789)
				zeroinConfig.AutoMutate = p789 == true
				v2243:setEnabled(zeroinConfig.AutoMutate)
			end
		})
		v2471:AddDropdown({
			Title = "Mutation Type",
			Content = "Choose Boss or Scrambled consumables",
			Column = "Left",
			Row = 3,
			Options = v2119.getMutationTypes(),
			Default = { zeroinConfig.AutoMutateType or "Boss" },
			Multi = false,
			Callback = function(p790)
				zeroinConfig.AutoMutateType = v2243:setMutationType(p790)
			end
		})

		local t131 = { "All" }

		for _, v in ipairs(v631.getRarities()) do
			if v ~= "All" then
				t131[#t131 + 1] = v
			end
		end

		local v2476
		local u2477 = false
		local u2478 = table.find(zeroinConfig.AutoMutateRarities or {}, "All") ~= nil

		v2476 = v2471:AddDropdown({
			Title = "Mutation Egg Rarities",
			Content = "All means every rarity",
			Column = "Right",
			Row = 3,
			Options = t131,
			Default = zeroinConfig.AutoMutateRarities,
			Multi = true,
			Callback = function(p791)
				if u2477 then
					return
				end

				local v2479 = type(p791) == "table" and table.clone(p791) or { p791 }
				local v2480 = table.find(v2479, "All") ~= nil
				local v2481 = false

				if #v2479 == 0 then
					v2479 = { "All" }
					v2481 = true
				elseif #v2479 > 1 and v2480 then
					if u2478 then
						local t132 = {}

						for _, v in ipairs(v2479) do
							if v ~= "All" then
								t132[#t132 + 1] = v
							end
						end

						v2479 = #t132 > 0 and t132 or { "All" }
					else
						v2479 = { "All" }
					end

					v2481 = true
				end

				u2478 = table.find(v2479, "All") ~= nil
				zeroinConfig.AutoMutateRarities = v2243:setRarities(v2479)

				if v2481 then
					task.defer(function()
						u2477 = true
						v2476:Set(zeroinConfig.AutoMutateRarities)
						u2477 = false
					end)
				end
			end
		})

		local v2485 = v2471:AddDropdown({
			Title = "Egg Names (Placed)",
			Content = "Leave empty to target every placed egg",
			Column = "Left",
			Row = 4,
			Options = v2243:getPlacedEggNames(),
			Default = zeroinConfig.AutoMutateNames,
			Multi = true,
			Callback = function(p792)
				zeroinConfig.AutoMutateNames = v2243:setNames(p792)
			end
		})
		local v2486

		v2486 = v2471:AddInput({
			Title = "Min Mutation Value /s",
			Content = "0 targets every value; accepts 100m, 50b, or 5t",
			Column = "Right",
			Row = 4,
			Default = zeroinConfig.AutoMutateMinValueInput or "0",
			Callback = function(p793)
				local v2487, v2488 = v229(p793)

				if v2487 == nil then
					task.defer(function()
						v2486:Set(zeroinConfig.AutoMutateMinValueInput or "0")
					end)

					return
				end

				zeroinConfig.AutoMutateMinValueInput = v2488
				zeroinConfig.AutoMutateMinValue = v2243:setMinValue(v2487)

				if tostring(p793):lower():gsub("[%s,$]", ""):gsub("/s$", "") ~= v2488 then
					task.defer(function()
						v2486:Set(v2488)
					end)
				end
			end
		})
		v2471:AddButton({
			Title = "Consume 1 Mutation Once",
			Icon = "sparkles",
			Column = "Full",
			Row = 5,
			Callback = function()
				v2243:requestOnce()
			end
		})

		local u2489

		v2243:onChanged(function(p794)
			local v2490 = tostring(p794.status or "Disabled")
			local v2491 = v2490:lower()
			local v2492 = p794.enabled and "ARMED" or "IDLE"

			if v2491:find("moving", 1, true) then
				v2492 = "MOVING"
			elseif v2491:find("applying", 1, true) then
				v2492 = "APPLYING"
			elseif v2491:find("ready:", 1, true) then
				v2492 = "CONFIRM"
			elseif v2491:find("applied", 1, true) then
				v2492 = "SUCCESS"
			elseif v2491:find("no ", 1, true) or v2491:find("unavailable", 1, true) or v2491:find("rejected", 1, true) or v2491:find("error", 1, true) then
				v2492 = "BLOCKED"
			end

			v2472:SetTitle("Auto Consume Mutation | " .. v2492)

			local v2493 = v2472
			local SetContent = v2472.SetContent
			local format = string.format
			local s6 = [[Status: %s
Mutation: %s | Consumables: %d | Eligible: %d
Target: %s | Last mutated: %s
Rarities: %s | Min value: $%s/s]]
			local v2497 = v2490
			local mutationType = p794.mutationType
			local v2499 = tonumber(p794.consumables) or 0
			local v2500 = tonumber(p794.eligible) or 0
			local target = p794.target or "--"

			SetContent(v2493, format(s6, v2497, mutationType, v2499, v2500, target, p794.lastMutated or "None", table.concat(p794.rarities or { "All" }, ", "), t20.formatMoneyShort(p794.minValuePerSec or 0)))

			local placedNames = p794.placedNames or {}
			local v2503 = table.concat(placedNames, "\0")

			if v2503 ~= u2489 then
				u2489 = v2503

				local t133 = {}
				local ipairs_ = ipairs
				local AutoMutateNames = zeroinConfig.AutoMutateNames or {}

				for _, AutoMutateName in ipairs_(AutoMutateNames) do
					if table.find(placedNames, AutoMutateName) then
						t133[#t133 + 1] = AutoMutateName
					end
				end

				v2485:SetValues(placedNames, t133)
			end
		end)

		local v2509 = v2378:AddSection({
			Title = "Pet Fusion",
			Layout = "Columns",
			ColumnGap = 6,
			ItemGap = 2
		})
		local v2510 = v2509:AddParagraph({
			Title = "Pet Fusion · IDLE",
			Content = "Auto Fuse is disabled. It only uses safe groups of 3 matching pet types.",
			Icon = "combine",
			Column = "Full",
			Row = 1
		})

		v2509:AddToggle({
			Title = "Auto Fuse",
			Content = "Continuously fuse eligible groups using the settings below",
			Column = "Full",
			Row = 2,
			Default = zeroinConfig.AutoFuse == true,
			Callback = function(p795)
				zeroinConfig.AutoFuse = p795 == true
				v2242:setEnabled(zeroinConfig.AutoFuse)
			end
		})
		v2509:AddDropdown({
			Title = "Fuse Priority",
			Content = "Choose which eligible group goes first",
			Column = "Left",
			Row = 3,
			Options = v1987.getPriorities(),
			Default = { zeroinConfig.AutoFusePriority or "Lowest Rarity" },
			Multi = false,
			Callback = function(p796)
				zeroinConfig.AutoFusePriority = v2242:setPriority(p796)
			end
		})

		local t134 = { "All" }

		for _, v in ipairs(v631.getRarities()) do
			if v ~= "All" then
				t134[#t134 + 1] = v
			end
		end

		local v2514
		local u2515 = false
		local u2516 = table.find(zeroinConfig.AutoFuseRarities or {}, "All") ~= nil

		v2514 = v2509:AddDropdown({
			Title = "Fuse Rarities",
			Content = "All means no rarity filter",
			Column = "Right",
			Row = 3,
			Options = t134,
			Default = zeroinConfig.AutoFuseRarities or { "All" },
			Multi = true,
			Callback = function(p797)
				if u2515 then
					return
				end

				local v2517 = type(p797) == "table" and table.clone(p797) or { p797 }
				local v2518 = table.find(v2517, "All") ~= nil
				local v2519 = false

				if #v2517 == 0 then
					v2517 = { "All" }
					v2519 = true
				elseif #v2517 > 1 and v2518 then
					if u2516 then
						local t135 = {}

						for _, v in ipairs(v2517) do
							if v ~= "All" then
								t135[#t135 + 1] = v
							end
						end

						v2517 = #t135 > 0 and t135 or { "All" }
					else
						v2517 = { "All" }
					end

					v2519 = true
				end

				u2516 = table.find(v2517, "All") ~= nil
				zeroinConfig.AutoFuseRarities = v2242:setRarities(v2517)

				if v2519 then
					task.defer(function()
						if not v2514 then
							return
						end

						u2515 = true
						v2514:Set(zeroinConfig.AutoFuseRarities)
						u2515 = false
					end)
				end
			end
		})

		local v2523

		v2523 = v2509:AddInput({
			Title = "Keep Pet Copies",
			Content = "Copies preserved per pet type; 1 recommended",
			Column = "Left",
			Row = 4,
			Default = tostring(zeroinConfig.AutoFuseKeepPerPet or 1),
			Callback = function(p798)
				local v2524 = v2242:setKeepPerCategory(p798)

				zeroinConfig.AutoFuseKeepPerPet = v2524

				if v2523 and tonumber(p798) ~= v2524 then
					task.defer(function()
						v2523:Set(tostring(v2524))
					end)
				end
			end
		})

		local v2525

		v2525 = v2509:AddInput({
			Title = "Max Weight (Kg)",
			Content = "0 means no limit; higher values protect heavier pets",
			Column = "Right",
			Row = 4,
			Default = tostring(zeroinConfig.AutoFuseMaxWeightKg or 0),
			Callback = function(p799)
				local v2526 = v2242:setMaxWeightKg(p799)

				zeroinConfig.AutoFuseMaxWeightKg = v2526

				if v2525 and tonumber(p799) ~= v2526 then
					task.defer(function()
						v2525:Set(tostring(v2526))
					end)
				end
			end
		})
		v2509:AddButton({
			Title = "Fuse 3 Pets Once",
			Icon = "combine",
			Column = "Full",
			Row = 5,
			Callback = function()
				v2242:requestFuseOnce()
			end
		})
		v2242:onChanged(function(p800)
			local v2527 = tostring(p800.status or "Disabled")
			local v2528 = v2527:lower()
			local v2529 = p800.enabled and "ARMED" or "IDLE"

			if v2528:find("moving", 1, true) then
				v2529 = "MOVING"
			elseif v2528:find("loading", 1, true) then
				v2529 = "LOADING"
			elseif v2528:find("fusing", 1, true) then
				v2529 = "FUSING"
			elseif v2528:find("waiting", 1, true) then
				v2529 = "WAITING"
			elseif v2528:find("ready:", 1, true) then
				v2529 = "CONFIRM"
			elseif v2528:find("fused ", 1, true) or v2528:find("recovered", 1, true) then
				v2529 = "COMPLETE"
			elseif v2528:find("failed", 1, true) or v2528:find("error", 1, true) or v2528:find("timed out", 1, true) or v2528:find("unavailable", 1, true) then
				v2529 = "ERROR"
			end

			local v2530 = p800.maxWeightKg > 0 and tostring(p800.maxWeightKg) .. " Kg" or "None"

			v2510:SetTitle("Pet Fusion · " .. v2529)
			v2510:SetContent(string.format([[Status: %s
Eligible groups: %s · Machine: %d/3 · Last fused: %s
Priority: %s · Keep copies: %d
Rarities: %s · Weight limit: %s]], v2527, p800.eligibleGroups == nil and "--" or tostring(p800.eligibleGroups), tonumber(p800.machineCount) or 0, tostring(p800.lastFused or "None"), tostring(p800.priority or "Lowest Rarity"), tonumber(p800.keepPerCategory) or 1, table.concat(p800.rarities or { "All" }, ", "), v2530))
		end)

		local v2531 = v2378:AddSection({
			Title = "Pet Selling",
			Layout = "Columns",
			ColumnGap = 6,
			ItemGap = 2
		})
		local v2532
		local v2533
		local v2534

		local function v2535(p801, p802, p803, p804)
			if type(p803) == "string" and v2226:isCategoryProtected(p803, p801) then
				return false, "item category is reserved for The Rift", "item"
			end

			local v2536, v2537 = v2226:tryAcquireBackground(p801, { p802 })

			if not v2536 then
				return false, v2537 or "another background operation is active", "global"
			end

			if v2241 and v2241:isEngaged() then
				v2241:yieldForBackground()

				local v2538 = os.clock() + 5

				while v2241:isEngaged() and os.clock() < v2538 do
					task.wait(0.05)
				end

				if v2241:isEngaged() then
					v2226:release(v2536)

					return false, "treadmill did not release its tool", "global"
				end
			end

			local ok, result, result2, result3 = xpcall(p804, debug.traceback)

			v2226:release(v2536)

			if ok then
				return result, result2, result3
			end

			return false, result, "global"
		end

		local u2543 = false

		t20.startAutoSellLoop = function()
			if u2543 then
				return
			end

			u2543 = true
			task.spawn(function()
				local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
				local Assets = require(ReplicatedStorage2.Data.Assets)
				local Save = require(ReplicatedStorage2.Shared.Save)
				local AssetRoster = require(ReplicatedStorage2.Client.AssetRoster)
				local Remotes = require(ReplicatedStorage2.Shared.Remotes)
				local LocalPlayer2 = game:GetService("Players").LocalPlayer

				local function v2550()
					local ok, result = pcall(function()
						return AssetRoster.ReadOwnerPen(LocalPlayer2.UserId)
					end)

					if not ok or type(result) ~= "table" then
						return nil
					end

					local t136 = {}

					for k, v in pairs(result) do
						if type(k) == "string" then
							t136[k] = true
						end

						if type(v) == "table" and v.UID then
							t136[v.UID] = true
						end
					end

					return t136
				end
				local function v2556(p805, p806)
					if not zeroinConfig.AutoSell then
						return false, "toggle Auto Sell Pet udah OFF", "global"
					end

					if not v269() then
						return false, "Auto Steal lagi megang kendali", "global"
					end

					if v268(p805.uid) then
						return false, "pet reserved for The Rift", "pet"
					end

					if v2226:isCategoryProtected(p805.category, "auto_sell_pets") then
						return false, "pet category is reserved for The Rift", "pet"
					end

					local v2557 = v319(v2532)
					local v2558 = v319(v2533)

					if not v2557 or not v2558 then
						return false, "filter dropdown gak bisa dibaca", "global"
					end

					if type(p806) ~= "table" then
						return false, "status pet dipajang gak bisa diverifikasi", "global"
					end

					if p806[p805.uid] then
						return false, "pet ini dipajang di plot", "pet"
					end

					if not v325(p805.petName, p805.rarity, v2557, v2558) then
						return false, "pet ini udah gak match filter yang sekarang", "pet"
					end

					local v2559 = Save.Get()
					local Inventory = v2559 and v2559.Inventory

					Inventory = Inventory and v2559.Inventory[p805.uid]

					if Inventory == nil then
						return false, "pet ini udah gak ada di inventory", "pet"
					end

					if Inventory.IsFavorite == true then
						return false, "pet ini di-favorite", "pet"
					end

					if Inventory.InFuse == true then
						return false, "pet ini sedang di-fuse", "pet"
					end

					if table.find(v2559.EquippedAssets or {}, p805.uid) == nil then
						return true
					end

					return false, "pet ini sedang dipasang", "pet"
				end

				while zeroinConfig.AutoSell do
					local ok, result = pcall(function()
						if not v269() then
							return
						end

						local v2563 = v319(v2532)
						local v2564 = v319(v2533)

						if not v2563 or not v2564 then
							warn("[AutoSell] Filter dropdown gak bisa dibaca -- ronde ini di-SKIP, gak ada yang dijual. Kalau ini terus-terusan, matiin Auto Sell Pet dan lapor.")

							return
						end

						local v2565 = Save.Get()
						local Inventory = v2565 and v2565.Inventory or {}
						local v2567 = v2550()

						if not v2567 then
							warn("[AutoSell] Status pet yang dipajang gak bisa diverifikasi -- ronde ini di-SKIP, gak ada yang dijual.")

							return
						end

						local t137 = {}
						local n38 = 0

						if type(Inventory) == "table" then
							for k, v in pairs(Inventory) do
								n38 += 1

								if n38 % 250 == 0 then
									RunService.Heartbeat:Wait()

									if not zeroinConfig.AutoSell then
										return
									end
								end

								if type(v) == "table" then
									local v2572 = v2567[k] == true
									local v2573 = v.IsFavorite == true or v["Jadikan Favorit"] == true or v.Favorite == true
									local v2574 = table.find(v2565.EquippedAssets or {}, k) ~= nil
									local v2575 = v.InFuse == true
									local Category = v.Category or v.id or v.AssetCategory or v.ItemId
									local v2577 = Category and Assets.Directory[Category]
									local DisplayName = v2577

									if DisplayName then
										DisplayName = v2577.DisplayName or v2577._id or v2577.Name
									end

									DisplayName = DisplayName or "Unknown"

									local Rarity = v2577 and v2577.Rarity
									local DisplayName2 = Rarity and (Rarity.DisplayName or Rarity._id or Rarity.Name) or "Unknown"

									if v325(DisplayName, DisplayName2, v2563, v2564) and not v2573 and not v2572 and not v2574 and not v2575 and not v268(k) and not v2226:isCategoryProtected(Category, "auto_sell_pets") then
										table.insert(t137, {
											uid = k,
											petName = DisplayName,
											rarity = DisplayName2,
											category = Category
										})
									end
								end
							end
						end

						if #t137 > 0 then
							for _, v in ipairs(t137) do
								local v2583, v2584, v2585 = v2535("auto_sell_pets", v.uid, v.category, function()
									local v2586 = v2550()
									local v2587, v2588, v2589 = v2556(v, v2586)

									if not v2587 then
										return false, v2588, v2589
									end

									local Character = LocalPlayer2.Character
									local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
									local v2592

									for _, v2 in ipairs({
										LocalPlayer2.Backpack,
										Character
									}) do
										if v2 then
											for _, child in ipairs(v2:GetChildren()) do
												if child:IsA("Tool") and child:GetAttribute("UID") == v.uid then
													v2592 = child

													break
												end
											end
										end

										if v2592 then
											break
										end
									end

									if not v2592 or not Humanoid then
										return false, "pet tool is unavailable", "pet"
									end

									Humanoid:EquipTool(v2592)
									task.wait(0.2)

									local v2597 = v2550()
									local v2598, v2599, v2600 = v2556(v, v2597)

									if v2598 then
										Remotes.PetSatchel.SellPet:FireServer({ v.uid })
										task.wait(0.05)

										return true
									end

									return false, v2599, v2600
								end)

								if v2583 then
									continue
								else
									warn("[AutoSell] Gak jual " .. tostring(v.petName) .. " -- " .. tostring(v2584))

									if v2585 ~= "global" then
										continue
									end
								end

								break
							end
						end
					end)

					if not ok then
						warn("Auto Sell Error:", result)
					end

					task.wait(1.5)
				end

				u2543 = false
			end)
		end

		local u2601 = false
		local u2602 = false

		local function v2603()
			local __ZeroinScrambleRuntime = genv.__ZeroinScrambleRuntime
			local v2605 = __ZeroinScrambleRuntime and type(__ZeroinScrambleRuntime.isMovementBusy) == "function" and __ZeroinScrambleRuntime:isMovementBusy()

			if zeroinConfig.IsRiftTrading or v2605 then
				return false
			end

			if not zeroinConfig.IsStealing then
				return v269()
			end

			local __ZeroinEggRuntime = genv.__ZeroinEggRuntime

			if not __ZeroinEggRuntime or __ZeroinEggRuntime.destroyed or not __ZeroinEggRuntime.enabled or not __ZeroinEggRuntime.activeTween or __ZeroinEggRuntime.carryAttemptToken or __ZeroinEggRuntime.playerHuntToken or __ZeroinEggRuntime.waitingGuardHit or __ZeroinEggRuntime.carry and __ZeroinEggRuntime.carry.active then
				return false
			end

			local Character = LocalPlayer.Character
			local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
			local activeTarget = __ZeroinEggRuntime.activeTarget
			local Position = activeTarget and activeTarget.BottomCFrame and activeTarget.BottomCFrame.Position

			if HumanoidRootPart and Position then
				return (HumanoidRootPart.Position - Position).Magnitude > math.max(60, (__ZeroinEggRuntime.config and __ZeroinEggRuntime.config.speed or 0) * 0.5 + 30)
			end

			return false
		end
		local function v2611()
			if not zeroinConfig.AutoSellEgg then
				return false
			end

			local v2612 = v319(v2534)

			if not v2612 or #v2612 == 0 or table.find(v2612, "None") then
				return false
			end

			local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
			local ok, result = pcall(function()
				return require(ReplicatedStorage2.Shared.Save)
			end)

			if not ok or not result then
				return false
			end

			local v2616 = result.Get()
			local EggInventory = v2616 and v2616.EggInventory

			if type(EggInventory) ~= "table" then
				return false
			end

			local ok2, result2 = pcall(function()
				return require(ReplicatedStorage2.Data.Assets)
			end)
			local Directory = ok2 and result2 and result2.Directory

			if not Directory then
				return false
			end

			for _, v in pairs(EggInventory) do
				local v2623 = type(v) == "table" and Directory[v.AssetCategory]
				local DisplayName = v2623 and v2623.Rarity and (v2623.Rarity.DisplayName or v2623.Rarity._id)

				if v.Placement ~= nil then
					continue
				end

				if not v266(v.AssetCategory) and not v2226:isCategoryProtected(v.AssetCategory, "auto_sell") then
					if v328(DisplayName or "Unknown", v2612) then
						return true
					end
				end
			end

			return false
		end

		genv.__ZeroinIsAutoSellEggBusy = function()
			return u2602 or v2611()
		end
		t20.startAutoSellEggLoop = function()
			if u2601 then
				return
			end

			u2601 = true
			task.spawn(function()
				local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
				local Directory = require(ReplicatedStorage2.Data.Assets).Directory
				local EggState2 = require(ReplicatedStorage2.Client.EggState)
				local Remotes = require(ReplicatedStorage2.Shared.Remotes)
				local Save = require(ReplicatedStorage2.Shared.Save)

				while zeroinConfig.AutoSellEgg do
					local v2630 = v319(v2534)
					local v2631 = Save.Get()
					local EggInventory = v2631 and v2631.EggInventory

					if v2630 and type(EggInventory) == "table" and v2603() then
						for k, v in pairs(EggInventory) do
							if zeroinConfig.AutoSellEgg and v2603() then
								local v2635 = type(v) == "table" and Directory[v.AssetCategory]
								local DisplayName = v2635 and v2635.Rarity and (v2635.Rarity.DisplayName or v2635.Rarity._id)

								if v.Placement ~= nil or v266(v.AssetCategory) or v2226:isCategoryProtected(v.AssetCategory, "auto_sell") then
									continue
								end

								if not v328(DisplayName or "Unknown", v2630) then
									continue
								end

								if v2603() then
									local v2637, v2638, v2639 = v2535("auto_sell", k, v.AssetCategory, function()
										if not zeroinConfig.AutoSellEgg or not v2603() then
											return false, "Auto Sell Egg is no longer available", "global"
										end

										u2602 = true

										if not EggState2.WearEggTool(k) then
											return false, "egg tool is unavailable", "item"
										end

										task.wait(0.2)

										if not zeroinConfig.AutoSellEgg or not v2603() then
											return false, "Auto Sell Egg is no longer available", "global"
										end

										local v2640 = Save.Get()
										local EggInventory2 = v2640 and v2640.EggInventory and v2640.EggInventory[k]

										if not EggInventory2 or EggInventory2.Placement ~= nil then
											return false, "egg is no longer sellable", "item"
										end

										if v266(EggInventory2.AssetCategory) or v2226:isCategoryProtected(EggInventory2.AssetCategory, "auto_sell") then
											return false, "egg category is reserved for The Rift", "item"
										end

										Remotes.PetSatchel.SellPet:FireServer({ k })
										task.wait(0.25)

										return true
									end)

									u2602 = false

									if v2637 then
										continue
									else
										warn("[AutoSellEgg] Gak jual " .. tostring(k) .. " -- " .. tostring(v2638))

										if v2639 ~= "global" then
											continue
										end
									end
								end
							end

							break
						end
					end

					u2602 = false
					task.wait(0.5)
				end

				u2602 = false
				u2601 = false
			end)
		end
		v2531:AddToggle({
			Title = "Auto Sell Pet",
			Column = "Left",
			Row = 1,
			Default = zeroinConfig.AutoSell == true,
			Callback = function(p807)
				zeroinConfig.AutoSell = p807

				if p807 then
					t20.startAutoSellLoop()
				end
			end
		})
		v2531:AddToggle({
			Title = "Sell All Pets",
			Column = "Right",
			Row = 1,
			Default = false,
			Callback = function(p808)
				zeroinConfig.SellAll = p808
			end
		})

		local t138 = {
			"None",
			"All"
		}

		pcall(function()
			local t139 = {}

			for _, v in pairs(require(game:GetService("ReplicatedStorage").Data.Assets).Directory) do
				if type(v) == "table" and (v.DisplayName or v._id or v.Name) then
					local DisplayName = v.DisplayName or v._id or v.Name

					if not t139[DisplayName] then
						t139[DisplayName] = true
						table.insert(t138, DisplayName)
					end
				end
			end

			table.sort(t138, function(p809, p810)
				if p809 == "None" then
					return true
				end

				if p810 == "None" then
					return false
				end

				if p809 == "All" then
					return true
				end

				if p810 == "All" then
					return false
				end

				return p809 < p810
			end)
		end)
		v2532 = v2531:AddDropdown({
			Title = "Pet Name Filter",
			Content = "Choose specific pets to sell",
			Column = "Full",
			Row = 2,
			Options = t138,
			Default = zeroinConfig.SellNames or { "None" },
			Multi = true,
			Callback = function(p811)
				zeroinConfig.SellNames = v309(p811, v2532)
			end
		})
		v2533 = v2531:AddDropdown({
			Title = "Pet Rarity Filter",
			Content = "Choose which pet rarities to sell",
			Column = "Full",
			Row = 3,
			Options = {
				"None",
				"All",
				"Common",
				"Uncommon",
				"Rare",
				"Epic",
				"Legendary",
				"Mythic",
				"Secret",
				"Divine",
				"Cosmic",
				"Eternal"
			},
			Default = { "None" },
			Multi = true,
			Callback = function(p812)
				zeroinConfig.SellRarities = v309(p812, v2533)
			end
		})

		local v2647 = v2378:AddSection({
			Title = "Egg Selling",
			Layout = "Grid",
			ItemGap = 4
		})

		v2647:AddToggle({
			Title = "Auto Sell Egg",
			Content = "Automatically sell matching unplaced eggs",
			Column = "Full",
			Row = 1,
			Default = zeroinConfig.AutoSellEgg == true,
			Callback = function(p813)
				zeroinConfig.AutoSellEgg = p813

				if p813 then
					t20.startAutoSellEggLoop()
				end
			end
		})
		v2534 = v2647:AddDropdown({
			Title = "Egg Rarity Filter",
			Content = "Choose which egg rarities to sell",
			Column = "Full",
			Row = 2,
			Options = {
				"None",
				"All",
				"Common",
				"Uncommon",
				"Rare",
				"Epic",
				"Legendary",
				"Mythic",
				"Secret",
				"Divine",
				"Cosmic",
				"Eternal"
			},
			Default = zeroinConfig.SellEggRarities or { "None" },
			Multi = true,
			Callback = function(p814)
				zeroinConfig.SellEggRarities = v309(p814, v2534)
			end
		})
	end,
	Webhook = function()
		local v2648 = v513:AddTab({
			Name = "Webhook",
			Icon = "webhook"
		}):AddSection({
			Title = "Discord Webhook",
			Layout = "Grid",
			ItemGap = 4
		})

		v2648:AddParagraph({
			Title = "Egg Claim Notifications",
			Content = "Send an embed to Discord whenever an egg is claimed, including its rarity, weight, value, area, and player information.",
			Icon = "send",
			Column = "Full",
			Row = 1
		})

		local function v2649(p815)
			local match = tostring(p815 or ""):match("^%s*(.-)%s*$") or ""

			if match == "" then
				return nil
			end

			local v2651 = match:gsub("[?#].*$", ""):gsub("/+$", "")

			if #v2651 > 2000 then
				return nil
			end

			return (v2651:match("^https://discord%.com/api/webhooks/%d+/[^/]+$") or v2651:match("^https://canary%.discord%.com/api/webhooks/%d+/[^/]+$") or v2651:match("^https://ptb%.discord%.com/api/webhooks/%d+/[^/]+$") or v2651:match("^https://discordapp%.com/api/webhooks/%d+/[^/]+$")) and v2651 or nil
		end

		v2648:AddToggle({
			Title = "Webhook Logs",
			Content = "Send a Discord log each time an egg is claimed",
			Column = "Full",
			Row = 3,
			Default = zeroinConfig.WebhookEnabled == true,
			Callback = function(p816)
				zeroinConfig.WebhookEnabled = p816 == true and v2649(zeroinConfig.WebhookURL) ~= nil
			end
		})
		v2648:AddInput({
			Title = "Webhook URL",
			Content = "Paste your Discord webhook URL here",
			Column = "Full",
			Row = 2,
			Default = zeroinConfig.WebhookURL or "",
			Persist = true,
			Sensitive = false,
			Callback = function(p817)
				zeroinConfig.WebhookURL = tostring(p817 or ""):match("^%s*(.-)%s*$") or ""

				if v2649(zeroinConfig.WebhookURL) == nil then
					zeroinConfig.WebhookEnabled = false
				end
			end
		})

		local function v2652(p818, p819)
			local request_ = syn and syn.request or request or http_request or http and http.request or fluxus and fluxus.request

			if type(request_) ~= "function" then
				return false, "Executor HTTP request is unavailable"
			end

			local v2654 = p818 .. (p818:find("?", 1, true) and "&wait=true" or "?wait=true")

			for i = 1, 3 do
				local ok, result = pcall(request_, {
					Url = v2654,
					url = v2654,
					Method = "POST",
					method = "POST",
					Headers = {
						["Content-Type"] = "application/json"
					},
					headers = {
						["Content-Type"] = "application/json"
					},
					Body = p819,
					body = p819
				})

				if not ok then
					return false, "Webhook request failed"
				end

				local v2658 = tonumber(result and (result.StatusCode or result.Status or result.status_code or result.statusCode))

				if v2658 and v2658 >= 200 and v2658 < 300 then
					return true
				end

				if v2658 ~= 429 or not (i < 3) then
					return false, "Discord rejected the webhook (HTTP " .. tostring(v2658 or "?") .. ")"
				end

				local Body = result and (result.Body or result.body)
				local pcall_ = pcall
				local JSONDecode = game:GetService("HttpService").JSONDecode
				local ok2, result2 = pcall_(JSONDecode, game:GetService("HttpService"), Body or "")

				task.wait(math.clamp(ok2 and type(result2) == "table" and tonumber(result2.retry_after) or 1, 0.5, 10))
			end

			return false, "Discord rate limit retry failed"
		end

		local t140 = {}
		local u2665 = false
		local v2666 = (genv.__ZeroinWebhookGeneration or 0) + 1

		genv.__ZeroinWebhookGeneration = v2666
		genv.__ZeroinWebhookCleanup = function()
			if genv.__ZeroinWebhookGeneration == v2666 then
				genv.__ZeroinWebhookGeneration += 1
			end

			table.clear(t140)
		end

		local function v2667(p820, p821, p822)
			if #t140 >= 20 then
				return false, "Webhook queue is full"
			end

			t140[#t140 + 1] = {
				url = p820,
				payload = p821,
				callback = p822
			}

			if u2665 then
				return true
			end

			u2665 = true
			task.spawn(function()
				while true do
					if genv.__ZeroinWebhookGeneration ~= v2666 then
						u2665 = false

						return
					end

					local v2668 = table.remove(t140, 1)

					if not v2668 then
						u2665 = false

						if #t140 ~= 0 then
							u2665 = true

							continue
						end

						break
					end

					local v2669, v2670 = v2652(v2668.url, v2668.payload)

					if type(v2668.callback) == "function" then
						task.defer(v2668.callback, v2669, v2670)
					elseif not v2669 then
						warn("[Webhook] " .. tostring(v2670))
					end

					task.wait(0.25)
				end
			end)

			return true
		end
		local function v2671(p823)
			local request_ = syn and syn.request or request or http_request or http and http.request or fluxus and fluxus.request

			if not request_ then
				return game:HttpGet(p823)
			end

			local v2673 = request_({
				Url = p823,
				Method = "GET"
			})

			return v2673 and (v2673.Body or v2673.body)
		end

		t20.formatMoneyShort = function(p824)
			local v2674 = math.floor(p824 + 0.5)

			if v2674 >= 1e9 then
				return string.format("%.2fB", v2674 / 1e9)
			end

			if v2674 >= 1000000 then
				return string.format("%.2fM", v2674 / 1000000)
			end

			if v2674 >= 1000 then
				return string.format("%.1fK", v2674 / 1000)
			end

			return tostring(v2674)
		end

		local function v2675()
			local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
			local EggState2 = require(ReplicatedStorage2.Client.EggState)
			local ok, result = pcall(function()
				local ReadOwnerEggs = EggState2.ReadOwnerEggs or EggState2.GetOwnerRuntimeRecords

				if type(ReadOwnerEggs) == "function" then
					return ReadOwnerEggs(LocalPlayer.UserId)
				end

				return nil
			end)

			if ok and type(result) == "table" then
				return result
			end

			local ok2, result2 = pcall(function()
				return require(ReplicatedStorage2.Shared.Save)
			end)
			local Get = ok2 and result2 and result2.Get and result2.Get()

			if Get and type(Get.EggInventory) == "table" then
				return Get.EggInventory
			end

			return {}
		end

		local t141 = {}

		pcall(function()
			local v2685 = v2675()

			for k in pairs(v2685) do
				t141[tostring(k)] = true
			end
		end)

		local function v2687(p825)
			local ok, result = pcall(function()
				local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
				local AssetItems = require(ReplicatedStorage2.Shared.Util.AssetItems)
				local AssetEarnings = require(ReplicatedStorage2.Shared.Util.AssetEarnings)
				local AssetCategory = p825 and p825.AssetCategory
				local v2694 = t10 and t10[AssetCategory]

				if not v2694 or v2694 == "Unknown" then
					v2694 = v236(AssetCategory)
				end

				local __ZeroinLastStolenEgg = genv.__ZeroinLastStolenEgg
				local v2696
				local exitTo
				local v2698

				for i = 1, 10 do
					v2698 = v2675()

					if type(v2698) == "table" then
						for k, v in pairs(v2698) do
							local v2702 = tostring(k)

							if not t141[v2702] and (not AssetCategory or v.AssetCategory == AssetCategory) then
								v2696 = v
								t141[v2702] = true

								break
							end
						end

						if v2696 then
							exitTo = 1

							break
						end

						task.wait(0.15)
					else
						task.wait(0.15)
					end
				end

				if exitTo == 1 then
					for k in pairs(v2698) do
						t141[tostring(k)] = true
					end

					if not v2696 and __ZeroinLastStolenEgg and __ZeroinLastStolenEgg.AssetCategory == AssetCategory then
						local now = os.clock()
						local Timestamp = __ZeroinLastStolenEgg.Timestamp or 0

						if now - Timestamp < 30 then
							v2696 = __ZeroinLastStolenEgg
						end
					end
				elseif not v2696 and __ZeroinLastStolenEgg and __ZeroinLastStolenEgg.AssetCategory == AssetCategory then
					if os.clock() - (__ZeroinLastStolenEgg.Timestamp or 0) < 30 then
						v2696 = __ZeroinLastStolenEgg
					end
				end

				if not v2696 then
					local v2706 = v2675()

					if type(v2706) == "table" then
						for _, v in pairs(v2706) do
							if v.AssetCategory == AssetCategory and v.Placement == nil then
								v2696 = v

								break
							end
						end

						if not v2696 then
							for _, v in pairs(v2706) do
								if v.AssetCategory == AssetCategory then
									v2696 = v

									break
								end
							end
						end
					end
				end

				local AssetScale = v2696 and (v2696.AssetScale or v2696.Scale) or 1
				local t142 = {
					Category = AssetCategory,
					Scale = AssetScale,
					Mutations = v2696 and v2696.Mutations or {},
					BaseMutation = v2696 and v2696.BaseMutation,
					EyeColor = v2696 and v2696.AssetEyeColor,
					ColorSeed = v2696 and v2696.AssetColorSeed,
					ColorIndex = v2696 and v2696.AssetColorIndex,
					Gender = v2696 and v2696.Gender,
					Personality = v2696 and (v2696.Personality or "Normal"),
					HasBeenFirstPlaced = v2696 and v2696.HasBeenFirstPlaced == true
				}
				local ok, result = pcall(AssetItems.WeightKg, t142)
				local ok2, result2 = pcall(function()
					return AssetEarnings.MutationOnlyRatePerSecond(t142)
				end)

				if not ok2 or not result2 then
					pcall(function()
						result2 = AssetEarnings.RatePerSecond(t142)
					end)
				end

				local t143 = {
					WeightKg = ok and result or nil,
					Scale = AssetScale,
					RatePerSec = result2,
					AreaId = v2694
				}

				return t143
			end)

			if ok and result then
				return result
			end

			return {
				WeightKg = nil,
				Scale = nil,
				RatePerSec = nil,
				AreaId = v236(p825 and p825.AssetCategory)
			}
		end

		local u2718

		local function v2719()
			if u2718 then
				return u2718
			end

			local ok, result = pcall(function()
				local HttpService = game:GetService("HttpService")
				local v2723 = v2671("https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=" .. LocalPlayer.UserId .. "&size=150x150&format=Png&isCircular=false")
				local data = HttpService:JSONDecode(v2723)
				local data2 = data and data.data and data.data[1]

				if data2 and data2.state == "Completed" and data2.imageUrl then
					return data2.imageUrl
				end

				return nil
			end)

			if ok and result then
				u2718 = result
			end

			return u2718
		end
		local function v2726()
			local v2727 = v2649(zeroinConfig.WebhookURL)

			if not v2727 then
				v306:MakeNotify({
					Title = "Webhook",
					Description = "Invalid URL",
					Content = "Enter a valid Discord webhook URL.",
					Color = Color3.fromRGB(220, 170, 80),
					Delay = 3
				})

				return
			end

			local t144 = {
				username = "Zeroin - Steal An Egg",
				embeds = { {
					title = "Webhook Test Successful",
					description = "Your Zeroin webhook is configured correctly.",
					color = 52410,
					footer = {
						text = "Zeroin - Steal An Egg"
					},
					timestamp = DateTime.now():ToIsoDate()
				} }
			}
			local v2729, v2730 = v2667(v2727, game:GetService("HttpService"):JSONEncode(t144), function(p826, p827)
				v306:MakeNotify({
					Title = "Webhook",
					Description = p826 and "Success" or "Failed",
					Content = p826 and "Test webhook sent successfully." or tostring(p827),
					Color = p826 and Color3.fromRGB(0, 205, 122) or Color3.fromRGB(220, 90, 90),
					Delay = 3
				})
			end)

			if not v2729 then
				v306:MakeNotify({
					Title = "Webhook",
					Description = "Failed",
					Content = tostring(v2730),
					Color = Color3.fromRGB(220, 90, 90),
					Delay = 3
				})
			end
		end
		local function v2731(p828)
			if not zeroinConfig.WebhookEnabled then
				return
			end

			local v2732 = v2649(zeroinConfig.WebhookURL)

			if not v2732 then
				zeroinConfig.WebhookEnabled = false

				return
			end

			if type(p828) ~= "table" then
				return
			end

			task.spawn(function()
				local ok, result = pcall(function()
					local HttpService = game:GetService("HttpService")
					local Assets = require(game:GetService("ReplicatedStorage").Data.Assets)
					local Rarity = p828.Rarity or "Unknown"
					local AssetCategory = p828.AssetCategory
					local DisplayName = p828.DisplayName

					if not DisplayName then
						DisplayName = tostring(AssetCategory or "Egg") .. " Egg"
					end

					local v2740
					local ok, result = pcall(function()
						return AssetCategory and Assets.Directory[AssetCategory]
					end)

					if ok and result and result.Egg and result.Egg.Icon then
						v2740 = tostring(result.Egg.Icon):gsub("rbxassetid://", "")
					end

					local v2743

					if v2740 then
						local ok2, result2 = pcall(function()
							local v2746 = v2671("https://thumbnails.roblox.com/v1/assets?assetIds=" .. v2740 .. "&size=420x420&format=Png&isCircular=false")
							local data = HttpService:JSONDecode(v2746)
							local data2 = data and data.data and data.data[1]

							if data2 and data2.state == "Completed" and data2.imageUrl then
								return data2.imageUrl
							end

							return nil
						end)

						if ok2 and result2 then
							v2743 = result2
						end
					end

					local n39 = 0

					if typeof(p828.Color) == "Color3" then
						local Color = p828.Color

						n39 = math.floor(Color.R * 255) * 65536 + math.floor(Color.G * 255) * 256 + math.floor(Color.B * 255)
					end

					local v2751 = v2687(p828) or {}
					local s7 = "Unknown"

					if type(v2751.WeightKg) == "number" then
						s7 = string.format("%s Kg", tostring(math.floor(v2751.WeightKg * 100 + 0.5) / 100))
					end

					local s8 = "Unknown"

					if type(v2751.Scale) == "number" then
						s8 = string.format("%.2fx", v2751.Scale)
					end

					local s9 = "Unknown"

					if type(v2751.RatePerSec) == "number" then
						s9 = "$" .. t20.formatMoneyShort(v2751.RatePerSec) .. "/s"
					end

					local v2755 = v2751.AreaId and v2751.AreaId ~= "Unknown" and tostring(v2751.AreaId)

					v2755 = v2755 or v236(p828.AssetCategory)

					local t145 = {
						author = {
							name = LocalPlayer.Name,
							icon_url = v2719()
						},
						description = "### " .. tostring(DisplayName),
						color = n39
					}
					local fields = {
						{
							name = "Rarity",
							value = tostring(Rarity),
							inline = true
						},
						{
							name = "Pet Species",
							value = tostring(AssetCategory or "Unknown"),
							inline = true
						},
						{
							name = "Weight",
							value = s7,
							inline = true
						},
						{
							name = "Value",
							value = s9,
							inline = true
						},
						{
							name = "Size",
							value = s8,
							inline = true
						},
						{
							name = "Area",
							value = v2755,
							inline = true
						}
					}

					t145.fields = fields
					t145.footer = {
						text = "Zeroin - Steal An Egg"
					}
					t145.timestamp = DateTime.now():ToIsoDate()

					if v2743 then
						t145.thumbnail = {
							url = v2743
						}
					end

					local v2760, v2761 = v2667(v2732, HttpService:JSONEncode({
						username = "Zeroin - Steal An Egg",
						embeds = { t145 }
					}))

					if not v2760 then
						error(v2761)
					end
				end)

				if not ok then
					warn("[Webhook] Gagal kirim webhook:", result)
				end
			end)
		end

		v2648:AddButton({
			Title = "Test Webhook",
			Icon = "send-horizontal",
			Column = "Full",
			Row = 4,
			Callback = v2726
		})
		pcall(function()
			v44(require(game:GetService("ReplicatedStorage").Client.EggState).AreaEggClaimed:Connect(function(p829)
				v2731(p829)
			end))
		end)
	end,
	Community = function()
		local v2762 = v513:AddTab({
			Name = "Community",
			Icon = "users"
		})

		genv.__ZeroinCommunityGeneration = (genv.__ZeroinCommunityGeneration or 0) + 1

		local __ZeroinCommunityGeneration = genv.__ZeroinCommunityGeneration
		local u2764 = true
		local HttpService = game:GetService("HttpService")
		local TeleportService = game:GetService("TeleportService")

		local function v2767(p830, p831, p832, p833)
			pcall(function()
				v306:MakeNotify({
					Title = p833 or "Zeroin",
					Description = "Community",
					Content = tostring(p830 or ""),
					Color = p832 or Color3.fromRGB(0, 205, 122),
					Delay = p831 or 3
				})
			end)
		end

		local t148 = {
			"wss://socket.zeroinhub.com",
			"wss://tunnel.zeroinhub.com"
		}
		local n40 = 1
		local t149 = {
			"Skeleton Horse (Dark Eternal)",
			"Pegasus (Light Eternal)",
			"World Burner (Dark Divine)",
			"ArchAngel (Light Divine)"
		}
		local t150 = {
			["Pegasus (Light Eternal)"] = "Skeleton Horse (Dark Eternal)",
			["Skeleton Horse (Dark Eternal)"] = "Pegasus (Light Eternal)",
			["ArchAngel (Light Divine)"] = "World Burner (Dark Divine)",
			["World Burner (Dark Divine)"] = "ArchAngel (Light Divine)"
		}
		local s10 = "Skeleton Horse (Dark Eternal)"
		local u2773 = t150[s10] or "Pegasus (Light Eternal)"
		local u2774
		local v2775 = tostring(LocalPlayer.UserId) == "11498668262"
		local u2776
		local u2777 = false
		local u2778 = false
		local u2779 = false
		local n41 = 0
		local u2781 = false
		local t151 = {}
		local u2783 = false
		local s11 = "Find Partner"
		local t152 = {}
		local t153 = {}
		local v2787 = v2762:AddSection({
			Title = "Community Mode",
			Layout = "Columns",
			ColumnGap = 6,
			ItemGap = 4
		})
		local v2788 = v2762:AddSection({
			Title = "Find Partner",
			Layout = "Columns",
			ColumnGap = 6,
			ItemGap = 4
		})
		local v2789 = v2762:AddSection({
			Title = "Community Feed",
			Layout = "Columns",
			ColumnGap = 6,
			ItemGap = 4
		})
		local v2790
		local v2791
		local n42 = 0

		local function createScreenGui()
			local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
			local ZeroinBroadcastGui = PlayerGui:FindFirstChild("ZeroinBroadcastGui")

			if ZeroinBroadcastGui then
				return ZeroinBroadcastGui
			end

			local ScreenGui = Instance.new("ScreenGui")

			ScreenGui.Name = "ZeroinBroadcastGui"
			ScreenGui.DisplayOrder = 999999
			ScreenGui.IgnoreGuiInset = false
			ScreenGui.ResetOnSpawn = false
			ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
			ScreenGui.Parent = PlayerGui

			return ScreenGui
		end
		local function v2797(p834)
			n42 += 1

			local v2798 = n42
			local v2799 = createScreenGui()
			local BroadcastCard = v2799:FindFirstChild("BroadcastCard")

			if BroadcastCard then
				BroadcastCard:Destroy()
			end

			local ViewportSize = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(800, 450)
			local v2802 = ViewportSize.X < 600 or ViewportSize.Y < 360
			local v2803 = v2802 and 82 or 94
			local Frame = Instance.new("Frame")

			Frame.Name = "BroadcastCard"
			Frame.AnchorPoint = Vector2.new(0.5, 0)
			Frame.Position = UDim2.new(0.5, 0, 0, -v2803 - 18)
			Frame.Size = UDim2.new(v2802 and 0.92 or 0.76, 0, 0, v2803)
			Frame.BackgroundColor3 = Color3.fromRGB(5, 30, 20)
			Frame.BackgroundTransparency = 0.04
			Frame.BorderSizePixel = 0
			Frame.ClipsDescendants = true
			Frame.ZIndex = 20
			Frame.Parent = v2799

			local UISizeConstraint = Instance.new("UISizeConstraint")

			UISizeConstraint.MinSize = Vector2.new(math.min(270, math.max(220, ViewportSize.X - 20)), v2803)
			UISizeConstraint.MaxSize = Vector2.new(640, v2803)
			UISizeConstraint.Parent = Frame

			local UICorner = Instance.new("UICorner")

			UICorner.CornerRadius = UDim.new(0, 12)
			UICorner.Parent = Frame

			local UIStroke = Instance.new("UIStroke")

			UIStroke.Color = Color3.fromRGB(245, 194, 74)
			UIStroke.Transparency = 0.08
			UIStroke.Thickness = 1.5
			UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			UIStroke.Parent = Frame

			local UIGradient = Instance.new("UIGradient")
			local colorSequenceKeypointNew = ColorSequenceKeypoint.new

			UIGradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(5, 30, 20)),
				ColorSequenceKeypoint.new(0.65, Color3.fromRGB(9, 62, 40)),
				colorSequenceKeypointNew(1, Color3.fromRGB(55, 44, 18))
			})
			UIGradient.Rotation = 8
			UIGradient.Parent = Frame

			local Frame2 = Instance.new("Frame")

			Frame2.Name = "Accent"
			Frame2.Size = UDim2.new(1, 0, 0, 3)
			Frame2.BackgroundColor3 = Color3.fromRGB(245, 194, 74)
			Frame2.BorderSizePixel = 0
			Frame2.ZIndex = 21
			Frame2.Parent = Frame

			local ImageLabel = Instance.new("ImageLabel")

			ImageLabel.Name = "OwnerAvatar"
			ImageLabel.BackgroundColor3 = Color3.fromRGB(10, 53, 35)
			ImageLabel.BorderSizePixel = 0
			ImageLabel.Position = UDim2.fromOffset(v2802 and 12 or 15, v2802 and 15 or 18)
			ImageLabel.Size = UDim2.fromOffset(v2802 and 52 or 58, v2802 and 52 or 58)
			ImageLabel.ZIndex = 22
			ImageLabel.Parent = Frame

			local UICorner2 = Instance.new("UICorner")

			UICorner2.CornerRadius = UDim.new(1, 0)
			UICorner2.Parent = ImageLabel

			local UIStroke2 = Instance.new("UIStroke")

			UIStroke2.Color = Color3.fromRGB(0, 229, 137)
			UIStroke2.Thickness = 1.5
			UIStroke2.Transparency = 0.05
			UIStroke2.Parent = ImageLabel
			task.spawn(function()
				local ok, image = pcall(function()
					return Players:GetUserThumbnailAsync(tonumber("11498668262"), Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
				end)

				if ok and ImageLabel.Parent then
					ImageLabel.Image = image
				end
			end)

			local TextLabel = Instance.new("TextLabel")

			TextLabel.Name = "OwnerBadge"
			TextLabel.BackgroundColor3 = Color3.fromRGB(245, 194, 74)
			TextLabel.BorderSizePixel = 0
			TextLabel.Position = UDim2.fromOffset(v2802 and 76 or 86, v2802 and 12 or 15)
			TextLabel.Size = UDim2.fromOffset(v2802 and 112 or 122, 20)
			TextLabel.Font = Enum.Font.GothamBold
			TextLabel.Text = "ZEROIN OWNER"
			TextLabel.TextColor3 = Color3.fromRGB(39, 29, 7)
			TextLabel.TextSize = v2802 and 9 or 10
			TextLabel.ZIndex = 22
			TextLabel.Parent = Frame

			local UICorner3 = Instance.new("UICorner")

			UICorner3.CornerRadius = UDim.new(0, 5)
			UICorner3.Parent = TextLabel

			local TextLabel2 = Instance.new("TextLabel")

			TextLabel2.Name = "LiveLabel"
			TextLabel2.BackgroundTransparency = 1
			TextLabel2.Position = UDim2.fromOffset(v2802 and 194 or 214, v2802 and 12 or 15)
			TextLabel2.Size = UDim2.fromOffset(90, 20)
			TextLabel2.Font = Enum.Font.GothamBold
			TextLabel2.Text = "LIVE BROADCAST"
			TextLabel2.TextColor3 = Color3.fromRGB(0, 229, 137)
			TextLabel2.TextSize = v2802 and 8 or 9
			TextLabel2.TextXAlignment = Enum.TextXAlignment.Left
			TextLabel2.ZIndex = 22
			TextLabel2.Parent = Frame

			local TextLabel3 = Instance.new("TextLabel")

			TextLabel3.Name = "BroadcastText"
			TextLabel3.BackgroundTransparency = 1
			TextLabel3.Position = UDim2.fromOffset(v2802 and 76 or 86, v2802 and 36 or 42)
			TextLabel3.Size = UDim2.new(1, v2802 and -88 or -101, 0, v2802 and 34 or 38)
			TextLabel3.Font = Enum.Font.GothamMedium
			TextLabel3.Text = tostring(p834.text or "")
			TextLabel3.TextColor3 = Color3.fromRGB(240, 250, 244)
			TextLabel3.TextSize = v2802 and 11 or 12
			TextLabel3.TextWrapped = true
			TextLabel3.TextTruncate = Enum.TextTruncate.AtEnd
			TextLabel3.TextXAlignment = Enum.TextXAlignment.Left
			TextLabel3.TextYAlignment = Enum.TextYAlignment.Top
			TextLabel3.ZIndex = 22
			TextLabel3.Parent = Frame

			local v2820 = v2802 and 8 or 14

			TweenService:Create(Frame, TweenInfo.new(0.42, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Position = UDim2.new(0.5, 0, 0, v2820)
			}):Play()
			task.delay(math.clamp(6 + #TextLabel3.Text / 45, 7, 14), function()
				if v2798 ~= n42 or not Frame.Parent then
					return
				end

				local tween = TweenService:Create(Frame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
					Position = UDim2.new(0.5, 0, 0, -v2803 - 18),
					BackgroundTransparency = 1
				})

				tween:Play()
				tween.Completed:Wait()

				if Frame.Parent then
					Frame:Destroy()
				end
			end)
		end
		local function v2822(p835)
			local ZeroinOnTop = LocalPlayer.PlayerGui:FindFirstChild("ZeroinOnTop")

			if not ZeroinOnTop then
				return
			end

			for _, descendant in ipairs(ZeroinOnTop:GetDescendants()) do
				if descendant:IsA("Frame") and descendant.Name == "ChatBox" then
					local BottomBar = descendant:FindFirstChild("BottomBar")
					local MessagesScroll = descendant:FindFirstChild("MessagesScroll")

					if BottomBar and MessagesScroll then
						BottomBar.Visible = p835
						MessagesScroll.Size = p835 and UDim2.new(1, -12, 1, -60) or UDim2.new(1, -12, 1, -34)
					end
				end
			end
		end
		local function v2828(p836)
			local ZeroinOnTop = LocalPlayer.PlayerGui:FindFirstChild("ZeroinOnTop")

			if not ZeroinOnTop then
				return
			end

			for _, descendant in ipairs(ZeroinOnTop:GetDescendants()) do
				if descendant:IsA("TextButton") then
					if (descendant.Text:find("Teleport To Partner Server", 1, true) or descendant.Text:find("Leave / Disconnect Partner", 1, true)) and descendant.Parent then
						descendant.Parent.Visible = p836
					end
				end
			end
		end
		local function v2832(p837)
			if u2764 and genv.__ZeroinCommunityGeneration == __ZeroinCommunityGeneration and u2776 then
				if u2777 then
					pcall(function()
						u2776:Send(HttpService:JSONEncode(p837))
					end)
				end
			end
		end

		v44(TeleportService.TeleportInitFailed:Connect(function(p838, p839, p840)
			if p838 == LocalPlayer and u2774 and u2783 then
				u2783 = false
				v2832({
					action = "cancel_teleport"
				})
				v2767("Could not join " .. u2774.username .. "'s server: " .. tostring(p840 or p839), 5, Color3.fromRGB(255, 150, 90), "Teleport Failed")
			end
		end))

		local function v2833(p841)
			if s11 ~= "Find Partner" or u2774 or not v2790 then
				return
			end

			v2790:Clear()
			v2790:SetTitle("Find Partner (Global Feed)")
			v2790:SetPartner("Lobby Online (" .. tostring(#p841) .. ")")
			v2822(false)
			v2828(false)

			if #p841 == 0 then
				v2790:AddMessage({
					from = "partner",
					sender = "System",
					text = "No active partner requests. Posts appear here for 1 minute after a player clicks 'Find Partner (Post Request)'.",
					time = os.date("%H:%M")
				})
			else
				for _, v in ipairs(p841) do
					v.isOwn = tostring(v.userId) == tostring(LocalPlayer.UserId)

					local t154 = {
						from = v.isOwn and "self" or "partner",
						sender = v.isOwn and v.username .. " (Your Request)" or v.username,
						text = (v.isOwn and "YOUR REQUEST\n" or "") .. "🔍 Needs: " .. tostring(v.needsPet or "-") .. "\n💼 Has: " .. tostring(v.hasPet or "-"),
						time = os.date("%H:%M")
					}

					if not v.isOwn then
						t154.buttonText = "Join & Chat"
						t154.onButtonClick = function()
							v2832({
								action = "invite_partner",
								targetUserId = v.userId
							})
							v2767("Requesting Join & Chat with " .. v.username .. "...", 3, Color3.fromRGB(0, 205, 122), "Fuse Partner")
						end
					end

					v2790:AddMessage(t154)
				end
			end
		end
		local function v2837(p842)
			local v2838 = tonumber(p842)

			if v2838 and v2838 > 1e11 then
				v2838 = math.floor(v2838 / 1000)
			end

			return v2838 and os.date("%H:%M", v2838) or os.date("%H:%M")
		end
		local function v2839()
			if s11 ~= "Global Chat" or not v2790 then
				return
			end

			v2790:Clear()
			v2790:SetTitle("Global Chat")
			v2790:SetPartner("Public Community")
			v2822(true)
			v2828(false)

			if #t152 == 0 then
				v2790:AddMessage({
					from = "partner",
					sender = "System",
					text = "No messages yet. Start a conversation with players across all servers.",
					time = os.date("%H:%M")
				})

				return
			end

			for _, v in ipairs(t152) do
				local v2842 = tostring(v.userId) == tostring(LocalPlayer.UserId)
				local v2843 = v2790
				local AddMessage = v2790.AddMessage
				local t155 = {
					from = v2842 and "self" or "partner"
				}
				local displayName = v.isOwner and "ZEROIN OWNER" or v.displayName or v.username

				t155.sender = displayName or "Player"
				t155.variant = v.isOwner and "owner" or nil
				t155.text = tostring(v.text or "")
				t155.time = v2837(v.time)
				AddMessage(v2843, t155)
			end
		end
		local function v2847()
			if s11 ~= "Find Partner" or not u2774 or not v2790 then
				return
			end

			v2788:SetVisible(false)
			v2790:Clear()
			v2790:SetTitle("Private Chat")
			v2790:SetPartner(u2774.username, "Connected")
			v2822(true)
			v2828(true)

			for _, v in ipairs(t153) do
				v2790:AddMessage(v)
			end
		end
		local function v2850(p843)
			u2774 = p843
			v2788:SetVisible(false)
			t153 = { {
				from = "partner",
				sender = "System",
				text = "You are now privately connected with " .. p843.username .. "! You can now chat and teleport together.",
				time = os.date("%H:%M")
			} }

			if s11 ~= "Find Partner" and v2791 then
				v2791:SetValue("Find Partner")
			else
				v2847()
			end
		end
		local function v2851()
			u2774 = nil
			t153 = {}

			if s11 == "Find Partner" then
				v2788:SetVisible(true)
				v2833(t151)
				v2832({
					action = "list_partners"
				})
			end
		end
		local function v2852(p844)
			local v2853 = p844 == "Global Chat" and "Global Chat"

			s11 = v2853 or "Find Partner"
			v2788:SetVisible(s11 == "Find Partner" and not u2774)

			if s11 == "Global Chat" then
				v2839()
				v2832({
					action = "get_global_chat"
				})
			elseif u2774 then
				v2847()
			else
				v2833(t151)
				v2832({
					action = "list_partners"
				})
			end
		end

		v2791 = v2787:AddDropdown({
			Title = "Chat Mode",
			Content = "Switch between partner matchmaking and public conversation",
			Column = "Full",
			Row = 1,
			Multi = false,
			Options = {
				"Find Partner",
				"Global Chat"
			},
			Default = "Find Partner",
			Callback = function(p845)
				v2852(p845)
			end
		})

		if v2775 then
			local v2854 = v2787:AddInput({
				Title = "Owner Broadcast",
				Content = "Send a live announcement to every player currently using Zeroin",
				Column = "Full",
				Row = 2,
				Default = "",
				Callback = function()
				end
			})

			v2787:AddButton({
				Title = "Broadcast To All Players",
				Content = "Display this announcement at the top of every connected player's screen",
				Icon = "radio-tower",
				Column = "Full",
				Row = 3,
				Callback = function()
					local v2855 = tostring(v2854:GetValue() or ""):gsub("^%s+", ""):gsub("%s+$", "")

					if v2855 == "" then
						v2767("Enter a broadcast message first.", 3, Color3.fromRGB(245, 194, 74), "Owner Broadcast")

						return
					end

					v2832({
						action = "owner_broadcast",
						text = v2855
					})
					v2854:Set("")
					v2767("Broadcast sent to all connected Zeroin users.", 3, Color3.fromRGB(0, 229, 137), "Owner Broadcast")
				end
			})
		end

		v2788:AddDropdown({
			Title = "Required Egg / Pet",
			Content = "Select the partner pet or egg you need for fusion",
			Column = "Full",
			Row = 1,
			Multi = false,
			Options = t149,
			Default = s10,
			Callback = function(p846)
				s10 = p846
				u2773 = t150[p846] or u2773
			end
		})
		v2788:AddButton({
			Title = "Find Partner (Post Request)",
			Content = "Broadcast your request to the public feed so other players can join & chat",
			Column = "Full",
			Row = 2,
			Callback = function()
				v2767("Posting request for " .. tostring(s10) .. "...", 3, Color3.fromRGB(0, 205, 122), "Fuse Partner")
				v2832({
					action = "update_request",
					hasPet = u2773,
					needsPet = s10
				})
			end
		})
		v2789:AddButton({
			Title = "Teleport To Partner Server",
			Content = "Instantly join the active partner's server",
			Column = "Left",
			Row = 1,
			Callback = function()
				if not u2774 or not u2774.jobId or u2774.jobId == "" then
					v2767("You are not connected to a private partner!", 3, Color3.fromRGB(255, 120, 120), "Fuse Partner")

					return
				end

				u2783 = true
				v2832({
					action = "begin_teleport"
				})
				v2767("Preparing transfer to " .. u2774.username .. "'s server...", 3, Color3.fromRGB(0, 205, 122), "Fuse Partner")
			end
		})
		v2789:AddButton({
			Title = "Leave / Disconnect Partner",
			Content = "End private chat and return to the global feed",
			Column = "Right",
			Row = 1,
			Callback = function()
				if not u2774 then
					v2767("You are currently in the public feed.", 2, Color3.fromRGB(200, 200, 200), "Fuse Partner")

					return
				end

				v2832({
					action = "leave_partner"
				})
				v2851()
				v2767("Disconnected from private partner.", 2, Color3.fromRGB(200, 200, 200), "Fuse Partner")
			end
		})
		v2790 = v2789:AddChatBox({
			Title = "Community Feed",
			Height = 260,
			Placeholder = "Type a message...",
			Partner = "Community",
			Column = "Full",
			Row = 2,
			OnSend = function(p847)
				if s11 == "Global Chat" then
					v2832({
						action = "global_chat",
						text = p847
					})
				elseif u2774 then
					v2832({
						action = "chat",
						text = p847
					})
				else
					v2767("Join & Chat with a partner from the feed above first!", 3, Color3.fromRGB(220, 180, 60), "Fuse Partner")
				end
			end
		})
		v2852(v2791:GetValue())

		local v2856

		local function v2857()
			if u2764 then
				if genv.__ZeroinCommunityGeneration == __ZeroinCommunityGeneration and not u2777 and not u2778 and not u2779 then
					n41 += 1
					u2779 = true
					task.delay(math.min(30, 2 ^ math.min(n41, 5)) + math.random() * 1.5, function()
						u2779 = false

						if u2764 and not (genv.__ZeroinCommunityGeneration ~= __ZeroinCommunityGeneration or u2777) then
							v2856()
						end
					end)

					return
				end
			end
		end

		v2856 = function()
			if not u2764 or genv.__ZeroinCommunityGeneration ~= __ZeroinCommunityGeneration or u2777 or u2778 then
				return
			end

			u2778 = true

			local genv2 = getgenv and getgenv() or _G
			local connect = WebSocket and (WebSocket.connect or WebSocket.Connect) or syn and syn.websocket and syn.websocket.connect or KRNL and KRNL.WebSocket and (KRNL.WebSocket.connect or KRNL.WebSocket.Connect) or websocket and (websocket.connect or websocket.Connect) or fluxus and fluxus.websocket and fluxus.websocket.connect or genv2.WebSocket and (genv2.WebSocket.connect or genv2.WebSocket.Connect)

			if not connect then
				if v2790 then
					v2790:AddMessage({
						from = "partner",
						sender = "System",
						text = "Your executor does not support WebSocket.",
						time = os.date("%H:%M")
					})
				end

				u2778 = false

				return
			end

			local ok, result = pcall(connect, t148[n40])

			u2778 = false

			if not u2764 or genv.__ZeroinCommunityGeneration ~= __ZeroinCommunityGeneration then
				if ok and result then
					pcall(function()
						result:Close()
					end)
				end

				return
			end

			if ok and result then
				u2776 = result
				u2777 = true
				result:Send(HttpService:JSONEncode({
					action = "register",
					userId = tostring(LocalPlayer.UserId),
					username = LocalPlayer.Name,
					jobId = tostring(game.JobId),
					placeId = game.PlaceId,
					hasPet = u2773,
					needsPet = s10
				}))
				result.OnMessage:Connect(function(p848)
					if not u2764 or genv.__ZeroinCommunityGeneration ~= __ZeroinCommunityGeneration or u2776 ~= result then
						return
					end

					local ok2, result2 = pcall(function()
						return HttpService:JSONDecode(p848)
					end)

					if not ok2 or type(result2) ~= "table" then
						return
					end

					local type_ = result2.type

					if type_ == "registered" then
						n41 = 0

						if u2781 and v2790 then
							u2781 = false
							v2790:AddMessage({
								from = "partner",
								sender = "System",
								text = "Backend connection restored.",
								time = os.date("%H:%M")
							})
						end

						v2832({
							action = "list_partners"
						})

						if s11 == "Global Chat" then
							v2832({
								action = "get_global_chat"
							})
						end
					elseif type_ == "partners_list" then
						t151 = result2.partners or {}
						v2833(t151)
					elseif type_ == "global_chat_history" then
						t152 = result2.messages or {}
						v2839()
					elseif type_ == "global_chat_message" then
						local message = result2.message

						if type(message) == "table" then
							table.insert(t152, message)

							while #t152 > 50 do
								table.remove(t152, 1)
							end

							if s11 == "Global Chat" and v2790 then
								local v2866 = tostring(message.userId) == tostring(LocalPlayer.UserId)
								local v2867 = v2790
								local AddMessage = v2790.AddMessage
								local t156 = {
									from = v2866 and "self" or "partner",
									sender = message.isOwner and "ZEROIN OWNER" or message.displayName or message.username or "Player"
								}
								local variant = message.isOwner and "owner"

								t156.variant = variant or nil
								t156.text = tostring(message.text or "")
								t156.time = v2837(message.time)
								AddMessage(v2867, t156)
							end
						end
					elseif type_ ~= "owner_broadcast" then
						if type_ == "partner_invite" then
							local fromUsername = result2.fromUsername or "Player"

							v2767(string.format("%s invited you to fuse!\nOpen Community tab to accept/decline.", fromUsername), 5, Color3.fromRGB(0, 229, 137), "Incoming Invitation")

							if v2790 and not u2774 then
								if s11 ~= "Find Partner" and v2791 then
									v2791:SetValue("Find Partner")
								end

								local v2872 = v2790
								local AddMessage = v2790.AddMessage
								local t157 = {
									from = "partner",
									sender = "🔔 INVITATION: " .. fromUsername,
									text = string.format([[💼 Has: %s
🔍 Needs: %s
Do you want to accept and start private chat?]], result2.hasPet or "-", result2.needsPet or "-"),
									bubbleColor = Color3.fromRGB(15, 60, 42)
								}
								local actions = {
									{
										text = "Decline ✕",
										width = 72,
										color = Color3.fromRGB(65, 25, 25),
										textColor = Color3.fromRGB(255, 170, 170),
										onClick = function()
											v2832({
												action = "reject_invite",
												fromUserId = result2.fromUserId
											})
											v2767("Declined invitation from " .. fromUsername, 2, Color3.fromRGB(200, 200, 200), "Fuse Partner")
											v2833(t151)
										end
									},
									{
										text = "Accept ✓",
										width = 78,
										color = Color3.fromRGB(0, 205, 122),
										textColor = Color3.fromRGB(4, 25, 16),
										onClick = function()
											v2832({
												action = "accept_invite",
												fromUserId = result2.fromUserId
											})
											v2767("Accepted invitation! Connecting...", 2, Color3.fromRGB(0, 205, 122), "Fuse Partner")
										end
									}
								}

								t157.actions = actions
								t157.time = os.date("%H:%M")
								AddMessage(v2872, t157)
							end
						elseif type_ == "invite_rejected" then
							v2767("Player " .. tostring(result2.fromUsername or "") .. " declined the invitation.", 3, Color3.fromRGB(255, 120, 120), "Fuse Partner")
						elseif type_ == "partner_connected" then
							u2783 = false
							v2767("Connected with partner " .. tostring(result2.partner and result2.partner.username or "") .. "!", 3, Color3.fromRGB(0, 205, 122), "Fuse Partner")
							v2850(result2.partner)
						elseif type_ == "request_updated" then
							v2767("Your partner request is live for 1 minute.", 3, Color3.fromRGB(0, 205, 122), "Fuse Partner")
						elseif type_ == "request_expired" then
							v2767("Your partner request expired. Post again if you still need a partner.", 3, Color3.fromRGB(220, 160, 60), "Fuse Partner")
						elseif type_ ~= "teleport_ready" then
							if type_ == "error" then
								v2767(tostring(result2.message or "Partner request failed."), 4, Color3.fromRGB(255, 120, 120), "Fuse Partner")
							elseif type_ == "chat_message" then
								local t160 = {
									from = "partner",
									sender = result2.fromUsername or u2774 and u2774.username or "Partner",
									text = result2.text,
									time = os.date("%H:%M")
								}

								table.insert(t153, t160)

								if v2790 and s11 == "Find Partner" then
									v2790:AddMessage(t160)
								end
							elseif type_ == "chat_sent" then
								local t161 = {
									from = "self",
									text = result2.text,
									time = os.date("%H:%M")
								}

								table.insert(t153, t161)

								if v2790 and s11 == "Find Partner" then
									v2790:AddMessage(t161)
								end
							elseif type_ == "partner_disconnected" or type_ == "partner_left" then
								v2767("Partner has left or disconnected.", 3, Color3.fromRGB(220, 160, 60), "Fuse Partner")
								v2851()
							end
						elseif u2783 and u2774 then
							v2767("Teleporting to " .. u2774.username .. "...", 3, Color3.fromRGB(0, 205, 122), "Fuse Partner")

							local ok3, result3 = pcall(function()
								TeleportService:TeleportToPlaceInstance(u2774.placeId or game.PlaceId, u2774.jobId, LocalPlayer)
							end)

							if not ok3 then
								u2783 = false
								v2832({
									action = "cancel_teleport"
								})
								v2767("Could not join the partner server. Private chat is still connected.", 4, Color3.fromRGB(255, 150, 90), "Teleport Failed")
								warn("[Fuse Partner] Teleport failed: " .. tostring(result3))
							end
						end
					elseif type(result2.announcement) == "table" then
						v2797(result2.announcement)
					end
				end)
				result.OnClose:Connect(function()
					if u2776 ~= result then
						return
					end

					u2777 = false
					u2776 = nil
					n40 = n40 % #t148 + 1
					v2857()
				end)

				return
			end

			n40 = n40 % #t148 + 1

			if v2790 and not u2781 then
				u2781 = true
				v2790:AddMessage({
					from = "partner",
					sender = "System",
					text = "Backend connection is temporarily unavailable. Reconnecting automatically...",
					time = os.date("%H:%M")
				})
			end

			v2857()
		end
		v512:OnClose(function()
			u2764 = false

			if genv.__ZeroinCommunityGeneration == __ZeroinCommunityGeneration then
				genv.__ZeroinCommunityGeneration = __ZeroinCommunityGeneration + 1
			end

			u2777 = false
			u2778 = false
			u2779 = false

			local v2882 = u2776

			u2776 = nil

			if v2882 then
				pcall(function()
					v2882:Close()
				end)
			end
		end)
		task.spawn(v2856)
	end,
	Misc = function()
		local v2883 = v513:AddTab({
			Name = "ESP",
			Icon = "scan-eye"
		})
		local v2884 = v513:AddTab({
			Name = "Panel",
			Icon = "panels-top-left"
		})
		local v2885 = v513:AddTab({
			Name = "Misc",
			Icon = "settings"
		})
		local v2886 = v2885:AddSection({
			Title = "Performance",
			Layout = "Grid",
			ItemGap = 4
		})

		v2886:AddToggle({
			Title = "Boost FPS",
			Content = "Extreme: grey parts, delete other plots, treadmills & decorations",
			Column = "Left",
			Row = 1,
			Default = false,
			Callback = function(p849)
				if p849 then
					v509()
				end
			end
		})
		v2886:AddToggle({
			Title = "Uncap FPS (240 FPS)",
			Content = "Unlock 240 FPS & smooth graphics (no texture, keep colors)",
			Column = "Right",
			Row = 1,
			Default = false,
			Callback = function(p850)
				if p850 then
					local __ZeroinSetCapFps = genv.__ZeroinSetCapFps

					if type(__ZeroinSetCapFps) == "function" then
						__ZeroinSetCapFps(240)
					end

					v402()
				end
			end
		})
		v2885:AddSection({
			Title = "Anti AFK",
			Layout = "Grid",
			ItemGap = 4
		}):AddToggle({
			Title = "Anti AFK",
			Content = "Disable captured LocalPlayer.Idled connections",
			Column = "Full",
			Row = 1,
			Default = zeroinConfig.AntiAFK == true,
			Callback = function(p851)
				zeroinConfig.AntiAFK = v282:setEnabled(p851)
			end
		})
		v2885:AddSection({
			Title = "Auto Reconnect",
			Layout = "Grid",
			ItemGap = 4
		}):AddToggle({
			Title = "Auto Reconnect",
			Content = "Automatically rejoin server when disconnected or kicked",
			Column = "Full",
			Row = 1,
			Default = zeroinConfig.AutoReconnect == true,
			Callback = function(p852)
				zeroinConfig.AutoReconnect = p852 == true
			end
		})
		v2885:AddSection({
			Title = "Community & Support",
			Layout = "Grid",
			ItemGap = 4
		}):AddButton({
			Title = "Join Discord",
			Content = "Get update info, report bugs & suggest features",
			Column = "Full",
			Row = 1,
			Callback = function()
				pcall(function()
					if setclipboard then
						setclipboard("https://discord.gg/CvVW5DBZKR")
					end

					local openurl_ = openurl or open_url

					openurl_ = openurl_ or syn and syn.open_url

					if type(openurl_) == "function" then
						pcall(openurl_, "https://discord.gg/CvVW5DBZKR")
					end

					game:GetService("StarterGui"):SetCore("SendNotification", {
						Title = "Zeroin",
						Text = "Opening Discord & copying link to clipboard!",
						Duration = 4
					})
				end)
			end
		})

		local function v2889()
			local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
			local Directory = require(ReplicatedStorage2.Data.Assets).Directory
			local AssetEarnings = require(ReplicatedStorage2.Shared.Util.AssetEarnings)
			local EggRecords = require(ReplicatedStorage2.Shared.Util.EggRecords)
			local Save = require(ReplicatedStorage2.Shared.Save)
			local EggState2 = require(ReplicatedStorage2.Client.EggState)
			local AreaEggs = require(ReplicatedStorage2.Shared.Types.AreaEggs)

			local function v2897(p853)
				local v2898 = math.max(tonumber(p853) or 0, 0)

				if v2898 >= 1e15 then
					return string.format("%.2fQ", v2898 / 1e15):gsub("%.00Q", "Q")
				end

				if v2898 >= 1e12 then
					return string.format("%.2fT", v2898 / 1e12):gsub("%.00T", "T")
				end

				return t20.formatMoneyShort(v2898)
			end
			local function v2899(p854, p855)
				local AssetCategory = p854.AssetCategory or p854.Category

				if type(AssetCategory) ~= "string" then
					return nil
				end

				local ok, result = pcall(AssetEarnings.LiveRatePerSecond, {
					Category = AssetCategory,
					Scale = math.max(tonumber(p854.AssetScale or p854.Scale) or 1, 0.01),
					Mutations = type(p854.Mutations) == "table" and p854.Mutations or {},
					BaseMutation = p854.BaseMutation
				}, p855 and p855.Gamepasses, p855 and p855.Products)
				local v2903 = ok and type(result) == "number"

				return v2903 and math.max(result, 0) or nil
			end
			local function v2904(p856)
				local ok, result = pcall(EggRecords.WeightKg, p856)

				if ok and type(result) == "number" then
					return math.max(result, 0)
				end

				local AssetCategory = p856.AssetCategory or p856.Category
				local v2908 = tonumber(p856.AssetScale or p856.Scale)
				local ok2, result2 = pcall(EggRecords.WeightKgForScale, AssetCategory, v2908)

				return ok2 and type(result2) == "number" and math.max(result2, 0) or nil
			end
			local function v2911(p857)
				local v2912 = type(p857) == "string" and Directory[p857] or nil
				local Rarity = v2912 and v2912.Rarity
				local DisplayName = Rarity and (Rarity.DisplayName or Rarity._id) or "Unknown"
				local Color = Rarity and Rarity.Color or Color3.fromRGB(255, 255, 255)
				local DisplayName2 = v2912 and (v2912.DisplayName or v2912._id)

				if not DisplayName2 then
					DisplayName2 = tostring(p857 or "Egg")
				end

				return DisplayName, Color, DisplayName2
			end
			local function v2917(p858)
				local t162 = {}

				local function v2919(p859)
					if type(p859) == "string" and p859 ~= "" and not table.find(t162, p859) then
						t162[#t162 + 1] = p859
					end
				end

				v2919(p858.BaseMutation)

				local ipairs_ = ipairs
				local Mutations = type(p858.Mutations) == "table" and p858.Mutations or {}

				for _, Mutation in ipairs_(Mutations) do
					v2919(Mutation)
				end

				return #t162 > 0 and table.concat(t162, ", ") or "None"
			end
			local function v2924(p860, p861)
				local __ZeroinAreaEggESP = p860:FindFirstChild("__ZeroinAreaEggESP")

				if not __ZeroinAreaEggESP then
					__ZeroinAreaEggESP = Instance.new("BillboardGui")
					__ZeroinAreaEggESP.Name = "__ZeroinAreaEggESP"
					__ZeroinAreaEggESP.AlwaysOnTop = true
					__ZeroinAreaEggESP.Size = UDim2.fromOffset(230, 42)
					__ZeroinAreaEggESP.StudsOffset = Vector3.new(0, 3.2, 0)
					__ZeroinAreaEggESP.MaxDistance = 850

					local TextLabel = Instance.new("TextLabel")

					TextLabel.Name = "Text"
					TextLabel.Size = UDim2.fromScale(1, 1)
					TextLabel.BackgroundTransparency = 1
					TextLabel.Font = Enum.Font.GothamBold
					TextLabel.TextSize = 12
					TextLabel.TextStrokeColor3 = Color3.fromRGB(4, 10, 7)
					TextLabel.TextStrokeTransparency = 0.2
					TextLabel.TextXAlignment = Enum.TextXAlignment.Center
					TextLabel.TextYAlignment = Enum.TextYAlignment.Center
					TextLabel.Parent = __ZeroinAreaEggESP
					__ZeroinAreaEggESP.Parent = p860
				end

				__ZeroinAreaEggESP.Adornee = p861

				return __ZeroinAreaEggESP:FindFirstChild("Text")
			end
			local function v2927(p862)
				local ok, result = pcall(EggRecords.DisplayNameWithWeight, p862)

				return ok and type(result) == "string" and result ~= "" and result or nil
			end
			local function createTextLabel(p863)
				local __ZeroinInventoryValue = p863:FindFirstChild("__ZeroinInventoryValue")

				if __ZeroinInventoryValue then
					return __ZeroinInventoryValue
				end

				local TextLabel = Instance.new("TextLabel")

				TextLabel.Name = "__ZeroinInventoryValue"
				TextLabel.AnchorPoint = Vector2.new(0.5, 0)
				TextLabel.Position = UDim2.new(0.5, 0, 0, 3)
				TextLabel.Size = UDim2.new(1, -8, 0, 18)
				TextLabel.BackgroundColor3 = Color3.fromRGB(6, 31, 21)
				TextLabel.BackgroundTransparency = 0.14
				TextLabel.BorderSizePixel = 0
				TextLabel.Font = Enum.Font.GothamBold
				TextLabel.TextColor3 = Color3.fromRGB(110, 244, 166)
				TextLabel.TextStrokeColor3 = Color3.fromRGB(2, 10, 7)
				TextLabel.TextStrokeTransparency = 0.45
				TextLabel.TextSize = 12
				TextLabel.TextTruncate = Enum.TextTruncate.AtEnd
				TextLabel.TextXAlignment = Enum.TextXAlignment.Center
				TextLabel.ZIndex = math.max(p863.ZIndex + 6, 30)

				local UICorner = Instance.new("UICorner")

				UICorner.CornerRadius = UDim.new(0, 4)
				UICorner.Parent = TextLabel
				TextLabel.Parent = p863

				return TextLabel
			end
			local function createTextBox(p864)
				local __ZeroinInventoryTotal = p864:FindFirstChild("__ZeroinInventoryTotal", true)

				if __ZeroinInventoryTotal and __ZeroinInventoryTotal:IsA("TextBox") then
					return __ZeroinInventoryTotal
				end

				local v2936

				for _, descendant in ipairs(p864:GetDescendants()) do
					if descendant:IsA("TextBox") then
						v2936 = descendant

						break
					end
				end

				local Parent = v2936 and v2936.Parent
				local Parent2 = Parent and Parent.Parent

				if not v2936 or not Parent or not Parent2 or not Parent2:IsA("GuiObject") then
					return nil
				end

				local TextBox = Instance.new("TextBox")

				TextBox.Name = "__ZeroinInventoryTotal"
				TextBox.AnchorPoint = Vector2.new(0, 0)
				TextBox.Position = UDim2.new(0, 8, Parent.Position.Y.Scale, Parent.Position.Y.Offset)
				TextBox.Size = UDim2.new(Parent.Position.X.Scale, Parent.Position.X.Offset - 16, Parent.Size.Y.Scale, Parent.Size.Y.Offset)
				TextBox.BackgroundColor3 = Color3.fromRGB(7, 34, 23)
				TextBox.BackgroundTransparency = 0.06
				TextBox.BorderSizePixel = 0
				TextBox.Font = Enum.Font.GothamBold
				TextBox.ClearTextOnFocus = false
				TextBox.TextEditable = false
				TextBox.TextColor3 = Color3.fromRGB(110, 244, 166)
				TextBox.TextSize = 13
				TextBox.TextXAlignment = Enum.TextXAlignment.Left
				TextBox.ZIndex = math.max(v2936.ZIndex + 2, 20)

				local UIPadding = Instance.new("UIPadding")

				UIPadding.PaddingLeft = UDim.new(0, 10)
				UIPadding.PaddingRight = UDim.new(0, 10)
				UIPadding.Parent = TextBox

				local UICorner = Instance.new("UICorner")

				UICorner.CornerRadius = UDim.new(0, 5)
				UICorner.Parent = TextBox

				local UIStroke = Instance.new("UIStroke")

				UIStroke.Color = Color3.fromRGB(34, 91, 68)
				UIStroke.Transparency = 0.25
				UIStroke.Parent = TextBox
				TextBox.Parent = Parent2

				return TextBox
			end

			local t163 = {
				destroyed = false,
				areaEnabled = false,
				placedEnabled = false,
				inventoryEnabled = false,
				labels = {},
				resources = {},
				refreshPending = false,
				areaGeneration = 0,
				placedGeneration = 0,
				inventoryGeneration = 0,
				refreshArea = function(p865)
					local AreaEggSlotsClient = workspace:FindFirstChild("AreaEggSlotsClient")

					if not AreaEggSlotsClient then
						return
					end

					local v2947 = Save.Get()
					local v2948 = EggState2.ReadFieldEggs()
					local Records = v2948 and v2948.Records or {}

					if #Records == 0 then
						pcall(function()
							local v2950 = EggState2.SyncFieldEggs()

							if v2950 and v2950.Records then
								Records = v2950.Records
							end
						end)
					end

					local t164 = {}

					for _, Record in ipairs(Records) do
						if Record.Uid then
							t164[Record.Uid] = Record
						end
					end

					for _, child in ipairs(AreaEggSlotsClient:GetChildren()) do
						local v2956 = t164[child.Name] or EggState2.ReadFieldEgg(child.Name)
						local v2957 = p865.areaEnabled and type(v2956) == "table" and (v2956.State == AreaEggs.States.Slot or v2956.State == AreaEggs.States.Dropped)
						local Hitbox = v2957 and (child:FindFirstChild("Hitbox") or child:FindFirstChildWhichIsA("BasePart", true))
						local __ZeroinAreaEggESP = child:FindFirstChild("__ZeroinAreaEggESP")
						local __ZeroinAreaEggHighlight = child:FindFirstChild("__ZeroinAreaEggHighlight")

						if v2957 then
							if Hitbox then
								local v2961, v2962, v2963 = v2911(v2956.AssetCategory)
								local v2964 = v2899(v2956, v2947)
								local v2965 = v2904(v2956)
								local v2966 = v2924(child, Hitbox)

								v2966.TextColor3 = v2962
								v2966.Text = string.format("%s\n%s  |  $%s/s  |  %s Kg", v2963, v2961, v2964 and v2897(v2964) or "?", v2965 and string.format("%.1f", v2965) or "?")

								if not __ZeroinAreaEggHighlight then
									__ZeroinAreaEggHighlight = Instance.new("Highlight")
									__ZeroinAreaEggHighlight.Name = "__ZeroinAreaEggHighlight"
									__ZeroinAreaEggHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
									__ZeroinAreaEggHighlight.Parent = child
								end

								__ZeroinAreaEggHighlight.Adornee = child
								__ZeroinAreaEggHighlight.FillColor = v2962
								__ZeroinAreaEggHighlight.FillTransparency = 0.82
								__ZeroinAreaEggHighlight.OutlineColor = v2962
								__ZeroinAreaEggHighlight.OutlineTransparency = 0.12

								continue
							end
						end

						if __ZeroinAreaEggESP then
							__ZeroinAreaEggESP:Destroy()
						end

						if __ZeroinAreaEggHighlight then
							__ZeroinAreaEggHighlight:Destroy()
						end
					end
				end,
				refreshPlaced = function(p866)
					local PlacedEggRenders = workspace:FindFirstChild("PlacedEggRenders")

					if not PlacedEggRenders then
						return
					end

					local v2968 = Save.Get()
					local t165 = {}
					local pairs_ = pairs
					local EggInventory = v2968 and v2968.EggInventory or {}

					for k, v in pairs_(EggInventory) do
						if p866.placedEnabled and type(k) == "string" and type(v) == "table" and v.Placement ~= nil and type(v.AssetCategory) == "string" then
							local v2974 = PlacedEggRenders:FindFirstChild(string.format("%d_%s", LocalPlayer.UserId, k))

							if v2974 and v2974:IsA("Model") then
								t165[v2974] = true

								local PrimaryPart = v2974.PrimaryPart or v2974:FindFirstChild("Hitbox") or v2974:FindFirstChildWhichIsA("BasePart", true)

								if PrimaryPart then
									local v2976, v2977, v2978 = v2911(v.AssetCategory)
									local v2979 = v2899(v, v2968)
									local v2980 = v2904(v)
									local __ZeroinPlacedEggESP = v2974:FindFirstChild("__ZeroinPlacedEggESP")

									if not __ZeroinPlacedEggESP then
										__ZeroinPlacedEggESP = Instance.new("BillboardGui")
										__ZeroinPlacedEggESP.Name = "__ZeroinPlacedEggESP"
										__ZeroinPlacedEggESP.AlwaysOnTop = true
										__ZeroinPlacedEggESP.Size = UDim2.fromOffset(250, 58)
										__ZeroinPlacedEggESP.StudsOffset = Vector3.new(0, 3.4, 0)
										__ZeroinPlacedEggESP.MaxDistance = 650

										local TextLabel = Instance.new("TextLabel")

										TextLabel.Name = "Text"
										TextLabel.Size = UDim2.fromScale(1, 1)
										TextLabel.BackgroundTransparency = 1
										TextLabel.Font = Enum.Font.GothamBold
										TextLabel.TextSize = 12
										TextLabel.TextStrokeColor3 = Color3.fromRGB(4, 10, 7)
										TextLabel.TextStrokeTransparency = 0.2
										TextLabel.TextXAlignment = Enum.TextXAlignment.Center
										TextLabel.TextYAlignment = Enum.TextYAlignment.Center
										TextLabel.Parent = __ZeroinPlacedEggESP
										__ZeroinPlacedEggESP.Parent = v2974
									end

									__ZeroinPlacedEggESP.Adornee = PrimaryPart

									local Text = __ZeroinPlacedEggESP:FindFirstChild("Text")

									Text.TextColor3 = v2977
									Text.Text = string.format("%s\n%s  |  $%s/s  |  %s Kg\nMutation: %s", v2978, v2976, v2979 and v2897(v2979) or "?", v2980 and string.format("%.1f", v2980) or "?", v2917(v))

									local __ZeroinPlacedEggHighlight = v2974:FindFirstChild("__ZeroinPlacedEggHighlight")

									if not __ZeroinPlacedEggHighlight then
										__ZeroinPlacedEggHighlight = Instance.new("Highlight")
										__ZeroinPlacedEggHighlight.Name = "__ZeroinPlacedEggHighlight"
										__ZeroinPlacedEggHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
										__ZeroinPlacedEggHighlight.Parent = v2974
									end

									__ZeroinPlacedEggHighlight.Adornee = v2974
									__ZeroinPlacedEggHighlight.FillColor = v2977
									__ZeroinPlacedEggHighlight.FillTransparency = 0.88
									__ZeroinPlacedEggHighlight.OutlineColor = v2977
									__ZeroinPlacedEggHighlight.OutlineTransparency = 0.18
								end
							end
						end
					end

					for _, child in ipairs(PlacedEggRenders:GetChildren()) do
						if not t165[child] then
							local __ZeroinPlacedEggESP = child:FindFirstChild("__ZeroinPlacedEggESP")
							local __ZeroinPlacedEggHighlight = child:FindFirstChild("__ZeroinPlacedEggHighlight")

							if __ZeroinPlacedEggESP then
								__ZeroinPlacedEggESP:Destroy()
							end

							if __ZeroinPlacedEggHighlight then
								__ZeroinPlacedEggHighlight:Destroy()
							end
						end
					end
				end,
				inventoryValues = function()
					local v2989 = Save.Get()
					local t166 = {}
					local n43 = 0
					local pairs_ = pairs
					local EggInventory = v2989 and v2989.EggInventory or {}

					for _, v in pairs_(EggInventory) do
						if type(v) == "table" then
							if v.Placement == nil then
								local v2996 = v2927(v)
								local v2997 = v2899(v, v2989)

								if v2996 and v2997 then
									t166[v2996] = t166[v2996] or {}
									t166[v2996][#t166[v2996] + 1] = v2997
									n43 += v2997
								end
							end
						end
					end

					for _, v in pairs(t166) do
						table.sort(v, function(p867, p868)
							return p867 > p868
						end)
					end

					return t166, n43
				end,
				refreshInventory = function(p869)
					if not p869.inventoryEnabled then
						return
					end

					local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
					local BackpackGui = PlayerGui and PlayerGui:FindFirstChild("BackpackGui")

					if not BackpackGui then
						return
					end

					local v3002, v3003 = p869:inventoryValues()
					local t167 = {}

					for _, descendant in ipairs(BackpackGui:GetDescendants()) do
						if descendant:IsA("GuiButton") and descendant:GetAttribute("IsInventorySlot") == true and descendant.Name ~= "Template" then
							t167[#t167 + 1] = descendant
						end
					end

					table.sort(t167, function(p870, p871)
						return p870.LayoutOrder < p871.LayoutOrder
					end)

					for _, v in ipairs(t167) do
						local ToolName = v:FindFirstChild("ToolName")
						local v3010 = ToolName and v3002[ToolName.Text]
						local v3011 = v3010 and table.remove(v3010, 1)
						local __ZeroinInventoryValue = v:FindFirstChild("__ZeroinInventoryValue")

						if v3011 then
							local v3013 = createTextLabel(v)

							v3013.Text = "$" .. v2897(v3011) .. "/s"
							v3013.Visible = ToolName.Text ~= ""
						elseif __ZeroinInventoryValue then
							__ZeroinInventoryValue.Visible = false
						end
					end

					local v3014 = createTextBox(BackpackGui)

					if v3014 then
						v3014.Text = "Total Egg Value  |  $" .. v2897(v3003) .. "/s"
					end
				end,
				removeInventory = function()
					local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
					local ipairs_ = ipairs
					local descendants = PlayerGui and PlayerGui:GetDescendants() or {}

					for _, descendant in ipairs_(descendants) do
						if descendant.Name == "__ZeroinInventoryValue" or descendant.Name == "__ZeroinInventoryTotal" then
							descendant:Destroy()
						end
					end
				end,
				scheduleInventory = function(p872)
					if not p872.refreshPending and p872.inventoryEnabled then
						if not p872.destroyed then
							p872.refreshPending = true
							task.delay(0.08, function()
								p872.refreshPending = false
								p872:refreshInventory()
							end)

							return
						end
					end
				end,
				setAreaEnabled = function(p873, p874)
					p873.areaEnabled = p874 == true
					p873.areaGeneration += 1

					local areaGeneration = p873.areaGeneration

					if p873.areaEnabled then
						p873:refreshArea()
						task.spawn(function()
							while not p873.destroyed and p873.areaEnabled and p873.areaGeneration == areaGeneration do
								task.wait(0.75)

								if not p873.destroyed and p873.areaEnabled and p873.areaGeneration == areaGeneration then
									p873:refreshArea()
								end
							end
						end)
					else
						local AreaEggSlotsClient = workspace:FindFirstChild("AreaEggSlotsClient")
						local ipairs_ = ipairs
						local children = AreaEggSlotsClient and AreaEggSlotsClient:GetChildren() or {}

						for _, child in ipairs_(children) do
							local __ZeroinAreaEggESP = child:FindFirstChild("__ZeroinAreaEggESP")
							local __ZeroinAreaEggHighlight = child:FindFirstChild("__ZeroinAreaEggHighlight")

							if __ZeroinAreaEggESP then
								__ZeroinAreaEggESP:Destroy()
							end

							if __ZeroinAreaEggHighlight then
								__ZeroinAreaEggHighlight:Destroy()
							end
						end
					end
				end,
				setInventoryEnabled = function(p875, p876)
					p875.inventoryEnabled = p876 == true
					p875.inventoryGeneration += 1

					local inventoryGeneration = p875.inventoryGeneration

					if p875.inventoryEnabled then
						p875:scheduleInventory()
						task.spawn(function()
							while not p875.destroyed do
								if not p875.inventoryEnabled or p875.inventoryGeneration ~= inventoryGeneration then
									break
								end

								task.wait(0.75)

								if not p875.destroyed and p875.inventoryEnabled and p875.inventoryGeneration == inventoryGeneration then
									p875:refreshInventory()
								end
							end
						end)
					else
						p875:removeInventory()
					end
				end,
				setPlacedEnabled = function(p877, p878)
					p877.placedEnabled = p878 == true
					p877.placedGeneration += 1

					local placedGeneration = p877.placedGeneration

					if p877.placedEnabled then
						p877:refreshPlaced()
						task.spawn(function()
							while not p877.destroyed and p877.placedEnabled and p877.placedGeneration == placedGeneration do
								task.wait(0.75)

								if not p877.destroyed and p877.placedEnabled and p877.placedGeneration == placedGeneration then
									p877:refreshPlaced()
								end
							end
						end)
					else
						local PlacedEggRenders = workspace:FindFirstChild("PlacedEggRenders")
						local ipairs_ = ipairs
						local children = PlacedEggRenders and PlacedEggRenders:GetChildren() or {}

						for _, child in ipairs_(children) do
							local __ZeroinPlacedEggESP = child:FindFirstChild("__ZeroinPlacedEggESP")
							local __ZeroinPlacedEggHighlight = child:FindFirstChild("__ZeroinPlacedEggHighlight")

							if __ZeroinPlacedEggESP then
								__ZeroinPlacedEggESP:Destroy()
							end

							if __ZeroinPlacedEggHighlight then
								__ZeroinPlacedEggHighlight:Destroy()
							end
						end
					end
				end,
				destroy = function(p879)
					if p879.destroyed then
						return
					end

					p879.destroyed = true
					p879:setAreaEnabled(false)
					p879:setPlacedEnabled(false)
					p879:setInventoryEnabled(false)

					for _, resource in ipairs(p879.resources) do
						pcall(resource.Disconnect, resource)
					end

					table.clear(p879.resources)
				end
			}

			if EggState2.FieldRefreshed then
				t163.resources[#t163.resources + 1] = EggState2.FieldRefreshed:Connect(function()
					if t163.areaEnabled then
						t163:refreshArea()
					end
				end)
			end

			t163.resources[#t163.resources + 1] = EggState2.FieldShifted:Connect(function()
				if t163.areaEnabled then
					t163:refreshArea()
				end
			end)
			t163.resources[#t163.resources + 1] = EggState2.FieldGone:Connect(function()
				if t163.areaEnabled then
					t163:refreshArea()
				end
			end)
			t163.resources[#t163.resources + 1] = LocalPlayer.PlayerGui.DescendantAdded:Connect(function(descendant)
				if t163.inventoryEnabled and (descendant.Name == "ToolName" or descendant.Name == "BackpackGui" or descendant:GetAttribute("IsInventorySlot") == true) then
					t163:scheduleInventory()
				end
			end)
			t163.resources[#t163.resources + 1] = Save.WatchFields({
				"Inventory",
				"EggInventory",
				"Gamepasses",
				"Products"
			}, function()
				if t163.placedEnabled then
					t163:refreshPlaced()
				end

				t163:scheduleInventory()
			end)

			return t163
		end

		local v3039 = v2889()

		genv.__ZeroinVisualRuntime = v3039
		genv.__ZeroinVisualCleanup = function()
			v3039:destroy()

			if genv.__ZeroinVisualRuntime == v3039 then
				genv.__ZeroinVisualRuntime = nil
			end

			genv.__ZeroinVisualCleanup = nil
		end

		local v3040 = v2883:AddSection({
			Title = "Area Egg ESP",
			Layout = "Grid",
			ItemGap = 4
		})

		v3040:AddParagraph({
			Title = "Live Area Eggs",
			Content = "Show egg name, rarity, value per second, and weight above every available egg in the world.",
			Icon = "scan-search",
			Column = "Full",
			Row = 1
		})
		v3040:AddToggle({
			Title = "Area Egg ESP",
			Content = "Track Slot and Dropped eggs across all areas",
			Column = "Full",
			Row = 2,
			Default = zeroinConfig.EggESP == true,
			Callback = function(p880)
				zeroinConfig.EggESP = p880 == true
				v3039:setAreaEnabled(zeroinConfig.EggESP)
			end
		})

		local v3041 = v2883:AddSection({
			Title = "Placed Egg ESP",
			Layout = "Grid",
			ItemGap = 4
		})

		v3041:AddParagraph({
			Title = "Your Plot Eggs",
			Content = "Show name, rarity, value per second, and weight above eggs placed in your plot.",
			Icon = "map-pinned",
			Column = "Full",
			Row = 1
		})
		v3041:AddToggle({
			Title = "Placed Egg ESP",
			Content = "Only tracks eggs placed by your account",
			Column = "Full",
			Row = 2,
			Default = zeroinConfig.PlacedEggESP == true,
			Callback = function(p881)
				zeroinConfig.PlacedEggESP = p881 == true
				v3039:setPlacedEnabled(zeroinConfig.PlacedEggESP)
			end
		})

		local v3042 = v2883:AddSection({
			Title = "Inventory ESP",
			Layout = "Grid",
			ItemGap = 4
		})

		v3042:AddParagraph({
			Title = "Inventory Value",
			Content = "Add total $/s above the native search bar and a compact $/s label at the top of each inventory card.",
			Icon = "badge-dollar-sign",
			Column = "Full",
			Row = 1
		})
		v3042:AddToggle({
			Title = "Inventory Value ESP",
			Content = "Keep egg names clear while showing each card's value",
			Column = "Full",
			Row = 2,
			Default = zeroinConfig.InventoryValueESP == true,
			Callback = function(p882)
				zeroinConfig.InventoryValueESP = p882 == true
				v3039:setInventoryEnabled(zeroinConfig.InventoryValueESP)
			end
		})
		v3039:setAreaEnabled(zeroinConfig.EggESP)
		v3039:setPlacedEnabled(zeroinConfig.PlacedEggESP)
		v3039:setInventoryEnabled(zeroinConfig.InventoryValueESP)

		local function v3043(p883)
			local v3044 = math.max(0, math.floor(p883))
			local v3045 = math.floor(v3044 / 86400)
			local v3046 = math.floor(v3044 % 86400 / 3600)
			local v3047 = math.floor(v3044 % 3600 / 60)

			if v3045 > 0 then
				return string.format("%dd %dh %dm", v3045, v3046, v3047)
			end

			if v3046 > 0 then
				return string.format("%dh %dm", v3046, v3047)
			end

			return string.format("%dm %02ds", v3047, v3044 % 60)
		end

		local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
		local Directory = require(ReplicatedStorage2.Data.Assets).Directory
		local Directory2 = require(ReplicatedStorage2.Data.Areas).Directory
		local AreaEggCycle = require(ReplicatedStorage2.Shared.Util.AreaEggCycle)
		local EggState2 = require(ReplicatedStorage2.Client.EggState)

		local function v3053()
			local t168 = {}
			local t169 = {}

			for _, v in pairs(Directory) do
				local Rarity = v.Rarity

				if Rarity and Rarity.DisplayName and not t168[Rarity.DisplayName] then
					t168[Rarity.DisplayName] = true
					table.insert(t169, {
						name = Rarity.DisplayName,
						color = Rarity.Color or Color3.fromRGB(255, 255, 255),
						order = Rarity.RarityNumber or 0
					})
				end
			end

			table.sort(t169, function(p884, p885)
				return p884.order > p885.order
			end)

			return t169
		end

		local v3059 = v3053()
		local t170 = {
			Any = Color3.fromRGB(255, 255, 255)
		}

		for _, v in ipairs(v3059) do
			t170[v.name] = v.color
		end

		local t171 = {
			Rainbow = Color3.fromRGB(255, 60, 255),
			Golden = Color3.fromRGB(255, 234, 0),
			Silver = Color3.fromRGB(220, 220, 220)
		}

		local function v3064()
			local t172 = {}
			local v3066 = EggState2.ReadFieldEggs()
			local Records = v3066 and v3066.Records

			if not Records or #Records == 0 then
				pcall(function()
					local v3068 = EggState2.SyncFieldEggs()

					if v3068 and v3068.Records then
						Records = v3068.Records
					end
				end)
			end

			if Records then
				for _, Record in pairs(Records) do
					local State = Record.State

					if State == "Slot" or State == "Dropped" or State == "Carried" or State == "GuardCarried" then
						local v3072 = Directory[Record.AssetCategory]

						if v3072 then
							local Egg = v3072.Egg or {}
							local v3074 = Directory2[Record.AreaId]
							local v3075

							if Record.Mutations and #Record.Mutations > 0 then
								v3075 = table.concat(Record.Mutations, " + ")
							end

							local s12 = ""

							if State == "Carried" then
								s12 = "[Carried] "
							elseif State == "GuardCarried" then
								s12 = "[Guard] "
							end

							table.insert(t172, {
								uid = Record.Uid,
								petName = v3072.DisplayName or Record.AssetCategory,
								eggName = s12 .. (Egg.DisplayName or v3072.DisplayName and v3072.DisplayName .. " Egg" or Record.AssetCategory),
								eggIcon = Egg.Icon or v3072.Icon or "",
								weightKg = Egg.WeightKg or 0,
								rarityName = v3072.Rarity and v3072.Rarity.DisplayName or "Common",
								rarityOrder = v3072.Rarity and v3072.Rarity.RarityNumber or 0,
								mutationText = v3075,
								mutationColor = t171[Record.BaseMutation] or Color3.fromRGB(255, 255, 255),
								area = v3074 and v3074.DisplayName or Record.AreaId or "Unknown"
							})
						end
					end
				end
			end

			table.sort(t172, function(p886, p887)
				if p886.rarityOrder == p887.rarityOrder then
					return p886.petName < p887.petName
				end

				return p886.rarityOrder > p887.rarityOrder
			end)

			return t172
		end

		local u3077

		if type(genv.__ZeroinEggPanelCleanup) == "function" then
			pcall(genv.__ZeroinEggPanelCleanup)
		end

		genv.__ZeroinEggPanelGeneration = (genv.__ZeroinEggPanelGeneration or 0) + 1

		local __ZeroinEggPanelGeneration = genv.__ZeroinEggPanelGeneration
		local t173 = {
			ActiveTab = "Logs",
			SearchText = "",
			SelectedRarity = "Any"
		}
		local u3080
		local u3081 = true
		local t174 = {
			Background = Color3.fromRGB(4, 28, 18),
			Surface = Color3.fromRGB(10, 40, 29),
			Input = Color3.fromRGB(8, 36, 25),
			Border = Color3.fromRGB(34, 91, 68),
			Accent = Color3.fromRGB(0, 205, 122),
			AccentSoft = Color3.fromRGB(151, 218, 184),
			Text = Color3.fromRGB(225, 238, 231),
			TextSecondary = Color3.fromRGB(151, 190, 169),
			TextMuted = Color3.fromRGB(116, 159, 136)
		}

		local function v3083()
			genv.__ZeroinEnterUICallback()

			local v3084 = t174
			local Accent = v3084.Accent
			local ScreenGui = Instance.new("ScreenGui")

			ScreenGui.Name = "ZeroinEggPanelUI"
			ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
			ScreenGui.ResetOnSpawn = false

			if not genv.__ZeroinParentGui(ScreenGui) then
				ScreenGui:Destroy()

				return nil
			end

			local ImageLabel = Instance.new("ImageLabel")

			ImageLabel.Name = "DropShadow"
			ImageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
			ImageLabel.BackgroundTransparency = 1
			ImageLabel.BorderSizePixel = 0
			ImageLabel.Image = "rbxassetid://6015897843"
			ImageLabel.ImageColor3 = Color3.fromRGB(0, 0, 0)
			ImageLabel.ImageTransparency = 0.55
			ImageLabel.ScaleType = Enum.ScaleType.Slice
			ImageLabel.SliceCenter = Rect.new(49, 49, 450, 450)
			ImageLabel.ZIndex = 0
			ImageLabel.Parent = ScreenGui

			local Frame = Instance.new("Frame")

			Frame.Name = "Main"
			Frame.Size = UDim2.new(0.72, 0, 0.62, 0)
			Frame.Position = UDim2.new(0.5, 0, 0.5, 0)
			Frame.AnchorPoint = Vector2.new(0.5, 0.5)
			Frame.BackgroundColor3 = v3084.Background
			Frame.BackgroundTransparency = 0.01
			Frame.BorderSizePixel = 0
			Frame.ZIndex = 1
			Frame.Active = true
			Frame.ClipsDescendants = true
			Frame.Parent = ScreenGui

			local UISizeConstraint = Instance.new("UISizeConstraint")

			UISizeConstraint.MinSize = Vector2.new(260, 340)
			UISizeConstraint.MaxSize = Vector2.new(320, 400)
			UISizeConstraint.Parent = Frame

			local UICorner = Instance.new("UICorner")

			UICorner.CornerRadius = UDim.new(0, 8)
			UICorner.Parent = Frame

			local UIStroke = Instance.new("UIStroke")

			UIStroke.Name = "MainOutline"
			UIStroke.Color = v3084.Border
			UIStroke.Thickness = 1.2
			UIStroke.Transparency = 0.18
			UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			UIStroke.Parent = Frame

			local function v3092()
				genv.__ZeroinEnterUICallback()
				ImageLabel.Position = UDim2.fromOffset(Frame.AbsolutePosition.X + Frame.AbsoluteSize.X * 0.5, Frame.AbsolutePosition.Y + Frame.AbsoluteSize.Y * 0.5)
				ImageLabel.Size = UDim2.fromOffset(Frame.AbsoluteSize.X + 44, Frame.AbsoluteSize.Y + 44)
			end

			Frame:GetPropertyChangedSignal("AbsolutePosition"):Connect(v3092)
			Frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(v3092)
			task.defer(v3092)

			local UserInputService = game:GetService("UserInputService")
			local u3094
			local u3095
			local Position
			local Position2

			Frame.InputBegan:Connect(function(input)
				genv.__ZeroinEnterUICallback()

				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					u3094 = true
					Position = input.Position
					Position2 = Frame.Position
					input.Changed:Connect(function()
						genv.__ZeroinEnterUICallback()

						if input.UserInputState == Enum.UserInputState.End then
							u3094 = false
						end
					end)

					return
				elseif input.UserInputType == Enum.UserInputType.Touch then
					u3094 = true
					Position = input.Position
					Position2 = Frame.Position
					input.Changed:Connect(function()
						genv.__ZeroinEnterUICallback()

						if input.UserInputState == Enum.UserInputState.End then
							u3094 = false
						end
					end)
				end
			end)
			Frame.InputChanged:Connect(function(input)
				genv.__ZeroinEnterUICallback()

				if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
					u3095 = input
				end
			end)
			v44(UserInputService.InputChanged:Connect(function(input)
				genv.__ZeroinEnterUICallback()

				if input == u3095 and u3094 then
					local v3098 = input.Position - Position

					Frame.Position = UDim2.new(Position2.X.Scale, Position2.X.Offset + v3098.X, Position2.Y.Scale, Position2.Y.Offset + v3098.Y)
				end
			end))

			local Frame2 = Instance.new("Frame")

			Frame2.Size = UDim2.new(1, 0, 0, 36)
			Frame2.BackgroundColor3 = v3084.Background
			Frame2.BackgroundTransparency = 0.01
			Frame2.BorderSizePixel = 0
			Frame2.Parent = Frame

			local UICorner2 = Instance.new("UICorner")

			UICorner2.CornerRadius = UDim.new(0, 8)
			UICorner2.Parent = Frame2

			local Frame3 = Instance.new("Frame")

			Frame3.Size = UDim2.new(1, 0, 0, 10)
			Frame3.Position = UDim2.new(0, 0, 1, -10)
			Frame3.BackgroundColor3 = v3084.Background
			Frame3.BackgroundTransparency = 0.01
			Frame3.BorderSizePixel = 0
			Frame3.Parent = Frame2

			local ImageLabel2 = Instance.new("ImageLabel")

			ImageLabel2.Size = UDim2.new(0, 20, 0, 20)
			ImageLabel2.Position = UDim2.new(0, 10, 0.5, -10)
			ImageLabel2.BackgroundTransparency = 1
			ImageLabel2.Image = "rbxassetid://124404129684886"
			ImageLabel2.Parent = Frame2

			local TextLabel = Instance.new("TextLabel")

			TextLabel.Size = UDim2.new(1, -66, 1, 0)
			TextLabel.Position = UDim2.new(0, 36, 0, 0)
			TextLabel.BackgroundTransparency = 1
			TextLabel.Text = "ZEROIN | EGG PANEL"
			TextLabel.TextColor3 = v3084.Text
			TextLabel.Font = Enum.Font.GothamBold
			TextLabel.TextSize = 12
			TextLabel.TextXAlignment = Enum.TextXAlignment.Left
			TextLabel.Parent = Frame2

			local TextButton = Instance.new("TextButton")

			TextButton.Size = UDim2.new(0, 24, 0, 24)
			TextButton.Position = UDim2.new(1, -30, 0.5, -12)
			TextButton.BackgroundColor3 = v3084.Surface
			TextButton.BackgroundTransparency = 0
			TextButton.Text = "×"
			TextButton.TextColor3 = v3084.Text
			TextButton.Font = Enum.Font.GothamBold
			TextButton.TextSize = 13
			TextButton.Parent = Frame2

			local UICorner3 = Instance.new("UICorner")

			UICorner3.CornerRadius = UDim.new(0, 6)
			UICorner3.Parent = TextButton

			local UIStroke2 = Instance.new("UIStroke")

			UIStroke2.Color = v3084.Border
			UIStroke2.Transparency = 0.35
			UIStroke2.Thickness = 1
			UIStroke2.Parent = TextButton
			TextButton.MouseButton1Click:Connect(function()
				genv.__ZeroinEnterUICallback()
				ScreenGui.Enabled = false
			end)

			local Frame4 = Instance.new("Frame")

			Frame4.Size = UDim2.new(1, -16, 0, 30)
			Frame4.Position = UDim2.new(0, 8, 0, 42)
			Frame4.BackgroundTransparency = 1
			Frame4.Parent = Frame

			local UIListLayout = Instance.new("UIListLayout")

			UIListLayout.FillDirection = Enum.FillDirection.Horizontal
			UIListLayout.Padding = UDim.new(0, 6)
			UIListLayout.Parent = Frame4

			local function createTextButton(p888)
				local TextButton2 = Instance.new("TextButton")

				TextButton2.Size = UDim2.new(0, 110, 1, 0)
				TextButton2.BackgroundColor3 = v3084.Surface
				TextButton2.BackgroundTransparency = 0
				TextButton2.Text = p888
				TextButton2.TextColor3 = v3084.TextSecondary
				TextButton2.Font = Enum.Font.GothamBold
				TextButton2.TextSize = 12
				TextButton2.Parent = Frame4

				local UICorner4 = Instance.new("UICorner")

				UICorner4.CornerRadius = UDim.new(0, 6)
				UICorner4.Parent = TextButton2

				local UIStroke3 = Instance.new("UIStroke")

				UIStroke3.Color = v3084.Border
				UIStroke3.Transparency = 0.35
				UIStroke3.Thickness = 1
				UIStroke3.Parent = TextButton2

				return TextButton2
			end

			local eggLogs = createTextButton("Egg Logs")
			local TextLabel2 = Instance.new("TextLabel")

			TextLabel2.Size = UDim2.new(1, -16, 0, 18)
			TextLabel2.Position = UDim2.new(0, 8, 0, 76)
			TextLabel2.BackgroundTransparency = 1
			TextLabel2.TextXAlignment = Enum.TextXAlignment.Left
			TextLabel2.Font = Enum.Font.GothamMedium
			TextLabel2.TextSize = 11
			TextLabel2.TextColor3 = v3084.AccentSoft
			TextLabel2.Text = "Next Reset: --"
			TextLabel2.Parent = Frame

			local TextBox = Instance.new("TextBox")

			TextBox.Size = UDim2.new(1, -72, 0, 26)
			TextBox.Position = UDim2.new(0, 8, 0, 98)
			TextBox.BackgroundColor3 = v3084.Input
			TextBox.BackgroundTransparency = 0
			TextBox.TextColor3 = v3084.Text
			TextBox.Text = ""
			TextBox.PlaceholderText = "Cari nama pet/egg..."
			TextBox.PlaceholderColor3 = v3084.TextMuted
			TextBox.Font = Enum.Font.Gotham
			TextBox.TextSize = 12
			TextBox.ClearTextOnFocus = false
			TextBox.TextXAlignment = Enum.TextXAlignment.Left
			TextBox.Parent = Frame

			local UICorner4 = Instance.new("UICorner")

			UICorner4.CornerRadius = UDim.new(0, 6)
			UICorner4.Parent = TextBox

			local UIStroke3 = Instance.new("UIStroke")

			UIStroke3.Color = v3084.Border
			UIStroke3.Transparency = 0.45
			UIStroke3.Thickness = 1
			UIStroke3.Parent = TextBox

			local UIPadding = Instance.new("UIPadding")

			UIPadding.PaddingLeft = UDim.new(0, 8)
			UIPadding.Parent = TextBox

			local TextButton2 = Instance.new("TextButton")

			TextButton2.Size = UDim2.new(0, 58, 0, 26)
			TextButton2.Position = UDim2.new(1, -62, 0, 98)
			TextButton2.BackgroundColor3 = v3084.Input
			TextButton2.BackgroundTransparency = 0
			TextButton2.Text = "Clear"
			TextButton2.TextColor3 = v3084.Text
			TextButton2.Font = Enum.Font.GothamMedium
			TextButton2.TextSize = 11
			TextButton2.Parent = Frame

			local UICorner5 = Instance.new("UICorner")

			UICorner5.CornerRadius = UDim.new(0, 6)
			UICorner5.Parent = TextButton2

			local UIStroke4 = Instance.new("UIStroke")

			UIStroke4.Color = v3084.Border
			UIStroke4.Transparency = 0.45
			UIStroke4.Thickness = 1
			UIStroke4.Parent = TextButton2
			TextButton2.MouseButton1Click:Connect(function()
				genv.__ZeroinEnterUICallback()
				TextBox.Text = ""
			end)

			local ScrollingFrame = Instance.new("ScrollingFrame")

			ScrollingFrame.Size = UDim2.new(1, -16, 0, 34)
			ScrollingFrame.Position = UDim2.new(0, 8, 0, 130)
			ScrollingFrame.BackgroundTransparency = 1
			ScrollingFrame.BorderSizePixel = 0
			ScrollingFrame.ScrollBarThickness = 0
			ScrollingFrame.ScrollingDirection = Enum.ScrollingDirection.X
			ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
			ScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.X
			ScrollingFrame.Parent = Frame

			local UIListLayout2 = Instance.new("UIListLayout")

			UIListLayout2.FillDirection = Enum.FillDirection.Horizontal
			UIListLayout2.VerticalAlignment = Enum.VerticalAlignment.Center
			UIListLayout2.Padding = UDim.new(0, 8)
			UIListLayout2.Parent = ScrollingFrame

			local ScrollingFrame2 = Instance.new("ScrollingFrame")

			ScrollingFrame2.Size = UDim2.new(1, -16, 1, -180)
			ScrollingFrame2.Position = UDim2.new(0, 8, 0, 172)
			ScrollingFrame2.BackgroundTransparency = 1
			ScrollingFrame2.BorderSizePixel = 0
			ScrollingFrame2.ScrollBarThickness = 3
			ScrollingFrame2.ScrollBarImageColor3 = v3084.Border
			ScrollingFrame2.ScrollBarImageTransparency = 0.2
			ScrollingFrame2.CanvasSize = UDim2.new(0, 0, 0, 0)
			ScrollingFrame2.AutomaticCanvasSize = Enum.AutomaticSize.Y
			ScrollingFrame2.Parent = Frame

			local UIPadding2 = Instance.new("UIPadding")

			UIPadding2.PaddingTop = UDim.new(0, 2)
			UIPadding2.Parent = ScrollingFrame2

			local UIListLayout3 = Instance.new("UIListLayout")

			UIListLayout3.Padding = UDim.new(0, 6)
			UIListLayout3.Parent = ScrollingFrame2

			local TextLabel3 = Instance.new("TextLabel")

			TextLabel3.Size = UDim2.new(1, 0, 0, 14)
			TextLabel3.LayoutOrder = -1
			TextLabel3.BackgroundTransparency = 1
			TextLabel3.TextXAlignment = Enum.TextXAlignment.Left
			TextLabel3.Font = Enum.Font.GothamMedium
			TextLabel3.TextSize = 10
			TextLabel3.TextColor3 = v3084.TextSecondary
			TextLabel3.Text = ""
			TextLabel3.Parent = ScrollingFrame2

			return {
				Gui = ScreenGui,
				Frame = Frame,
				LogsTabBtn = eggLogs,
				ResetLabel = TextLabel2,
				SearchBox = TextBox,
				ChipScroll = ScrollingFrame,
				ListScroll = ScrollingFrame2,
				CountLabel = TextLabel3,
				AccentColor = Accent
			}
		end
		local function createFrame(p889, p890)
			genv.__ZeroinEnterUICallback()

			local Frame = Instance.new("Frame")

			Frame.Size = UDim2.new(1, 0, 0, 56)

			local v3130 = t174

			Frame.BackgroundColor3 = v3130.Surface
			Frame.BackgroundTransparency = 0.08
			Frame.LayoutOrder = p889
			Frame.Parent = u3077.ListScroll

			local UICorner = Instance.new("UICorner")

			UICorner.CornerRadius = UDim.new(0, 8)
			UICorner.Parent = Frame

			local UIStroke = Instance.new("UIStroke")

			UIStroke.Color = v3130.Border
			UIStroke.Thickness = 1
			UIStroke.Transparency = 0.38
			UIStroke.Parent = Frame

			local Frame2 = Instance.new("Frame")

			Frame2.Size = UDim2.new(0, 4, 1, -12)
			Frame2.Position = UDim2.new(0, 0, 0, 6)
			Frame2.BackgroundColor3 = p890.rarityColor or Color3.fromRGB(255, 255, 255)
			Frame2.BorderSizePixel = 0
			Frame2.Parent = Frame

			local UICorner2 = Instance.new("UICorner")

			UICorner2.CornerRadius = UDim.new(1, 0)
			UICorner2.Parent = Frame2

			local ImageLabel = Instance.new("ImageLabel")

			ImageLabel.Size = UDim2.new(0, 40, 0, 40)
			ImageLabel.Position = UDim2.new(0, 12, 0.5, -20)
			ImageLabel.BackgroundColor3 = v3130.Input
			ImageLabel.BackgroundTransparency = 0
			ImageLabel.Image = p890.icon or ""
			ImageLabel.Parent = Frame

			local UICorner3 = Instance.new("UICorner")

			UICorner3.CornerRadius = UDim.new(0, 6)
			UICorner3.Parent = ImageLabel

			local UIStroke2 = Instance.new("UIStroke")

			UIStroke2.Color = v3130.Border
			UIStroke2.Transparency = 0.5
			UIStroke2.Thickness = 1
			UIStroke2.Parent = ImageLabel

			local TextLabel = Instance.new("TextLabel")

			TextLabel.Size = UDim2.new(1, -228, 0, 15)
			TextLabel.Position = UDim2.new(0, 60, 0, 4)
			TextLabel.BackgroundTransparency = 1
			TextLabel.TextXAlignment = Enum.TextXAlignment.Left
			TextLabel.Font = Enum.Font.GothamBold
			TextLabel.TextSize = 13
			TextLabel.TextColor3 = v3130.Text
			TextLabel.TextTruncate = Enum.TextTruncate.AtEnd
			TextLabel.Text = p890.title or ""
			TextLabel.Parent = Frame

			local TextLabel2 = Instance.new("TextLabel")

			TextLabel2.Size = UDim2.new(1, -228, 0, 13)
			TextLabel2.Position = UDim2.new(0, 60, 0, 19)
			TextLabel2.BackgroundTransparency = 1
			TextLabel2.TextXAlignment = Enum.TextXAlignment.Left
			TextLabel2.Font = Enum.Font.Gotham
			TextLabel2.TextSize = 10
			TextLabel2.TextColor3 = v3130.TextSecondary
			TextLabel2.TextTruncate = Enum.TextTruncate.AtEnd
			TextLabel2.Text = p890.subtitle or ""
			TextLabel2.Parent = Frame

			local TextLabel3 = Instance.new("TextLabel")

			TextLabel3.Size = UDim2.new(1, -228, 0, 13)
			TextLabel3.Position = UDim2.new(0, 60, 0, 33)
			TextLabel3.BackgroundTransparency = 1
			TextLabel3.TextXAlignment = Enum.TextXAlignment.Left
			TextLabel3.Font = Enum.Font.Gotham
			TextLabel3.TextSize = 10
			TextLabel3.TextColor3 = p890.metaColor or v3130.TextSecondary
			TextLabel3.TextTruncate = Enum.TextTruncate.AtEnd
			TextLabel3.Text = p890.meta or ""
			TextLabel3.Parent = Frame

			local TextLabel4 = Instance.new("TextLabel")

			TextLabel4.Size = UDim2.new(0, 90, 0, 16)
			TextLabel4.Position = UDim2.new(1, -164, 0, 8)
			TextLabel4.BackgroundTransparency = 1
			TextLabel4.TextXAlignment = Enum.TextXAlignment.Right
			TextLabel4.Font = Enum.Font.GothamBold
			TextLabel4.TextSize = 12
			TextLabel4.TextColor3 = p890.rightTopColor or v3130.Accent
			TextLabel4.Text = p890.rightTop or ""
			TextLabel4.Parent = Frame

			local TextLabel5 = Instance.new("TextLabel")

			TextLabel5.Size = UDim2.new(0, 90, 0, 14)
			TextLabel5.Position = UDim2.new(1, -164, 0, 26)
			TextLabel5.BackgroundTransparency = 1
			TextLabel5.TextXAlignment = Enum.TextXAlignment.Right
			TextLabel5.Font = Enum.Font.Gotham
			TextLabel5.TextSize = 10
			TextLabel5.TextColor3 = v3130.TextMuted
			TextLabel5.Text = p890.rightBottom or ""
			TextLabel5.Parent = Frame

			local TextButton = Instance.new("TextButton")

			TextButton.Name = "StealButton"
			TextButton.Size = UDim2.new(0, 56, 0, 26)
			TextButton.Position = UDim2.new(1, -66, 0.5, -13)
			TextButton.BackgroundColor3 = v3130.Accent
			TextButton.AutoButtonColor = false
			TextButton.Font = Enum.Font.GothamBold
			TextButton.TextSize = 11
			TextButton.TextColor3 = Color3.fromRGB(4, 28, 18)
			TextButton.Text = "Steal"
			TextButton.Parent = Frame

			local UICorner4 = Instance.new("UICorner")

			UICorner4.CornerRadius = UDim.new(0, 6)
			UICorner4.Parent = TextButton

			local UIStroke3 = Instance.new("UIStroke")

			UIStroke3.Color = Color3.fromRGB(0, 240, 140)
			UIStroke3.Transparency = 0.5
			UIStroke3.Thickness = 1
			UIStroke3.Parent = TextButton
			TextButton.MouseEnter:Connect(function()
				TextButton.BackgroundColor3 = Color3.fromRGB(0, 230, 138)
			end)
			TextButton.MouseLeave:Connect(function()
				TextButton.BackgroundColor3 = v3130.Accent
			end)
			TextButton.MouseButton1Click:Connect(function()
				if not p890.uid then
					return
				end

				local __ZeroinEggRuntime = v2229 or genv and genv.__ZeroinEggRuntime

				if not __ZeroinEggRuntime then
					pcall(function()
						v306:MakeNotify({
							Title = "Egg Steal",
							Description = "Error",
							Content = "Auto Steal runtime is not ready.",
							Color = Color3.fromRGB(220, 90, 90),
							Delay = 2.5
						})
					end)

					return
				end

				local v3147, v3148 = __ZeroinEggRuntime:requestPanelSteal(p890.uid)

				if v3147 then
					TextButton.Text = "Queued"
					TextButton.BackgroundColor3 = Color3.fromRGB(34, 91, 68)
					TextButton.TextColor3 = Color3.fromRGB(225, 238, 231)
					pcall(function()
						v306:MakeNotify({
							Title = "Egg Steal",
							Description = "Queued",
							Content = "Stealing " .. tostring(p890.title or "Egg") .. "...",
							Color = Color3.fromRGB(0, 205, 122),
							Delay = 2
						})
					end)
					task.delay(1.5, function()
						if TextButton and TextButton.Parent then
							TextButton.Text = "Steal"
							TextButton.BackgroundColor3 = v3130.Accent
							TextButton.TextColor3 = Color3.fromRGB(4, 28, 18)
						end
					end)
				else
					pcall(function()
						v306:MakeNotify({
							Title = "Egg Steal",
							Description = "Failed",
							Content = tostring(v3148 or "Cannot steal this egg"),
							Color = Color3.fromRGB(220, 90, 90),
							Delay = 3
						})
					end)
				end
			end)

			return Frame
		end
		local function v3149()
			genv.__ZeroinEnterUICallback()

			for _, child in ipairs(u3077.ListScroll:GetChildren()) do
				if child:IsA("Frame") then
					child:Destroy()
				end
			end
		end
		local function v3152(p891)
			if t173.SearchText == "" then
				return true
			end

			return string.find(string.lower(p891), string.lower(t173.SearchText), 1, true) ~= nil
		end
		local function v3153()
			genv.__ZeroinEnterUICallback()

			if not u3077 then
				return
			end

			v3149()

			local v3154 = u3080 or {}
			local n44 = 0

			for _, v in ipairs(v3154) do
				local v3158 = t173.SelectedRarity == "Any" or v.rarityName == t173.SelectedRarity
				local v3159 = v3152(v.petName) or v3152(v.eggName)

				if v3158 and v3159 then
					n44 += 1

					local color32 = t170[v.rarityName] or Color3.fromRGB(255, 255, 255)

					createFrame(n44, {
						uid = v.uid,
						icon = v.eggIcon,
						title = v.eggName,
						subtitle = v.petName,
						rarityColor = color32,
						meta = v.rarityName .. " • " .. (v.mutationText and "Mutasi: " .. v.mutationText or "No Mutation"),
						metaColor = color32,
						rightTop = v.area,
						rightTopColor = t174.AccentSoft,
						rightBottom = string.format("%s kg", tostring(v.weightKg or 0))
					})
				end
			end

			u3077.CountLabel.Text = n44 .. " egg(s) di area sekarang"
		end
		local function v3161(p892)
			local t175 = {}
			local ipairs_ = ipairs
			local v3164 = p892 or {}

			for _, v in ipairs_(v3164) do
				local insert = table.insert
				local v3168 = t175
				local concat = table.concat
				local t176 = {}
				local v3171 = tostring(v.uid)
				local v3172 = tostring(v.petName or "")
				local v3173 = tostring(v.eggName or "")
				local v3174 = tostring(v.eggIcon or "")
				local v3175 = tostring(v.weightKg or "")
				local v3176 = tostring(v.rarityName or "")
				local v3177 = tostring(v.mutationText or "")
				local tostring_ = tostring
				local area = v.area or ""

				do
					local values = table.pack(v3171, v3172, v3173, v3174, v3175, v3176, v3177, tostring_(area))

					table.move(values, 1, values.n, 1, t176)
				end

				insert(v3168, concat(t176, ":"))
			end

			table.sort(t175)

			return t173.SelectedRarity .. "|" .. t173.SearchText .. "|" .. table.concat(t175, ",")
		end

		local u3181

		local function v3182()
			genv.__ZeroinEnterUICallback()

			if not u3077 then
				return
			end

			u3080 = v3064()
			v3153()
			u3181 = v3161(u3080)
		end
		local function v3183()
			genv.__ZeroinEnterUICallback()

			if not u3077 then
				return
			end

			local AccentColor = u3077.AccentColor

			local function v3185(p893, p894)
				p893.BackgroundColor3 = p894 and AccentColor or t174.Surface
				p893.BackgroundTransparency = p894 and 0 or 0.08
				p893.TextColor3 = p894 and Color3.fromRGB(4, 28, 18) or t174.TextSecondary
			end

			v3185(u3077.LogsTabBtn, t173.ActiveTab == "Logs")
		end
		local function v3186()
			genv.__ZeroinEnterUICallback()

			if not u3077 then
				return
			end

			for _, child in ipairs(u3077.ChipScroll:GetChildren()) do
				if child:IsA("TextButton") then
					if child.Text == t173.SelectedRarity then
						child.BackgroundColor3 = t170[child.Text] or u3077.AccentColor
						child.TextColor3 = Color3.fromRGB(10, 10, 15)
					else
						child.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
						child.TextColor3 = Color3.fromRGB(200, 200, 200)
					end
				end
			end
		end
		local function v3189()
			genv.__ZeroinEnterUICallback()

			for _, child in ipairs(u3077.ChipScroll:GetChildren()) do
				if child:IsA("TextButton") then
					child:Destroy()
				end
			end

			local function createTextButton(p895)
				local TextButton = Instance.new("TextButton")

				TextButton.Size = UDim2.new(0, math.max(50, #p895 * 7 + 24), 0, 24)
				TextButton.BackgroundColor3 = t174.Surface
				TextButton.BackgroundTransparency = 0.08
				TextButton.Text = p895
				TextButton.TextColor3 = t174.TextSecondary
				TextButton.Font = Enum.Font.GothamBold
				TextButton.TextSize = 11
				TextButton.Parent = u3077.ChipScroll

				local UICorner = Instance.new("UICorner")

				UICorner.CornerRadius = UDim.new(1, 0)
				UICorner.Parent = TextButton

				local UIStroke = Instance.new("UIStroke")

				UIStroke.Color = t174.Border
				UIStroke.Transparency = 0.4
				UIStroke.Parent = TextButton
				TextButton.MouseButton1Click:Connect(function()
					genv.__ZeroinEnterUICallback()
					t173.SelectedRarity = p895
					v3186()
					v3182()
				end)

				return TextButton
			end

			createTextButton("Any")

			for _, v in ipairs(v3059) do
				createTextButton(v.name)
			end
		end

		t20.toggleEggPanelUI = function(p896)
			genv.__ZeroinEnterUICallback()

			if p896 then
				if not u3077 then
					u3077 = v3083()
					v3189()
					v3186()
					v3183()
					u3077.LogsTabBtn.MouseButton1Click:Connect(function()
						genv.__ZeroinEnterUICallback()
						t173.ActiveTab = "Logs"
						v3183()
						v3182()
					end)
					u3077.SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
						genv.__ZeroinEnterUICallback()
						t173.SearchText = u3077.SearchBox.Text
						v3182()
					end)
				end

				u3077.Gui.Enabled = true
				pcall(function()
					EggState2.SyncFieldEggs()
				end)
				v3182()
			elseif u3077 then
				u3077.Gui.Enabled = false
			end
		end
		v44(EggState2.FieldRefreshed:Connect(function()
			u3081 = true
		end))
		v44(EggState2.FieldShifted:Connect(function()
			u3081 = true
		end))
		v44(EggState2.FieldGone:Connect(function()
			u3081 = true
		end))
		v44(EggState2.ResetCountdown:Connect(function()
			u3081 = true
		end))
		v44(EggState2.RarityRevealed:Connect(function()
			u3081 = true
		end))

		local u3198 = false

		genv.__ZeroinEggPanelCleanup = function()
			u3198 = false
			zeroinConfig.EggPredictUI = false

			if u3077 and u3077.Gui then
				pcall(function()
					u3077.Gui:Destroy()
				end)
			end

			u3077 = nil
		end
		t20.startEggPanelLoop = function()
			if u3198 then
				return
			end

			u3198 = true
			task.spawn(function()
				genv.__ZeroinEnterUICallback()

				local n45 = 0

				while zeroinConfig.EggPredictUI and genv.__ZeroinEggPanelGeneration == __ZeroinEggPanelGeneration do
					genv.__ZeroinEnterUICallback()

					local ok, result = pcall(function()
						local serverTimeNow = game:GetService("Workspace"):GetServerTimeNow()
						local v3203 = AreaEggCycle.NextResetTime(serverTimeNow)

						if u3077 then
							genv.__ZeroinEnterUICallback()
							u3077.ResetLabel.Text = "Next Reset: " .. v3043(math.max(0, v3203 - serverTimeNow))

							local now = os.clock()

							if not u3080 or #u3080 == 0 or now - n45 >= 15 then
								n45 = now
								pcall(function()
									EggState2.SyncFieldEggs()
								end)
							end

							local v3205 = v3064()
							local v3206 = v3161(v3205)

							if v3206 ~= u3181 or u3081 then
								u3081 = false
								u3181 = v3206
								u3080 = v3205
								v3153()
							end
						end
					end)

					if not ok then
						warn("[EggPanel] Error di tick loop:", result)
					end

					task.wait(1.5)
				end

				u3198 = false

				if genv.__ZeroinEggPanelGeneration == __ZeroinEggPanelGeneration then
					t20.toggleEggPanelUI(false)
				end
			end)
		end

		local v3207 = v2884:AddSection({
			Title = "Egg Panel",
			Layout = "Grid",
			ItemGap = 4
		})

		v3207:AddParagraph({
			Title = "Area Egg Panel",
			Content = "Enable the Egg Panel to view which eggs are currently available in every area, including egg name, rarity, weight, mutation, and area.",
			Icon = "scan-search",
			Column = "Full",
			Row = 1
		})
		v3207:AddToggle({
			Title = "Show Egg Panel",
			Content = "Open the live egg list and area information panel",
			Column = "Full",
			Row = 2,
			Default = false,
			Callback = function(p897)
				zeroinConfig.EggPredictUI = p897

				if p897 then
					t20.toggleEggPanelUI(true)
					t20.startEggPanelLoop()
				else
					t20.toggleEggPanelUI(false)
				end
			end
		})
	end
}

genv.__ZeroinRunUICallback(function()
	local ok, result = pcall(t111.Main)

	if not ok then
		warn("[Zeroin] Error loading MainTab:", result)
	end

	pcall(t111.Auto)
	pcall(t111.Webhook)
	pcall(t111.Community)
	pcall(t111.Misc)
end)
pcall(function()
	local __ZeroinUIHost = genv.__ZeroinUIHost

	if not __ZeroinUIHost then
		return
	end

	for _, descendant in ipairs(__ZeroinUIHost:GetDescendants()) do
		if descendant.Name == "ScrollSelect" and descendant:IsA("ScrollingFrame") then
			local UIListLayout = descendant:FindFirstChildOfClass("UIListLayout")

			if UIListLayout then
				local function v3214()
					genv.__ZeroinEnterUICallback()
					descendant.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
				end

				v3214()
				UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(v3214)
			end
		end
	end
end)
task.spawn(function()
	genv.__ZeroinEnterUICallback()

	if not game:IsLoaded() then
		game.Loaded:Wait()
		genv.__ZeroinEnterUICallback()
	end

	local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

	genv.__ZeroinEnterUICallback()
	Character:WaitForChild("HumanoidRootPart", 15)
	genv.__ZeroinEnterUICallback()
	Character:WaitForChild("Humanoid", 15)
	genv.__ZeroinEnterUICallback()

	local now = os.clock()

	while os.clock() - now < 15 do
		genv.__ZeroinEnterUICallback()

		local __ZeroinUIHost = genv.__ZeroinUIHost
		local ZeroinOnTop = __ZeroinUIHost and __ZeroinUIHost:FindFirstChild("ZeroinOnTop")

		if ZeroinOnTop and ZeroinOnTop:FindFirstChild("DropShadowHolder", true) then
			genv.__Stored_ZeroinOnTop = ZeroinOnTop
			pcall(function()
				ZeroinOnTop.ResetOnSpawn = false
			end)

			local ToggleUIZeroin = __ZeroinUIHost and __ZeroinUIHost:FindFirstChild("ToggleUIZeroin")

			if ToggleUIZeroin then
				genv.__Stored_ToggleUIZeroin = ToggleUIZeroin
				pcall(function()
					ToggleUIZeroin.ResetOnSpawn = false
				end)
			end

			local NotifyGui = __ZeroinUIHost and __ZeroinUIHost:FindFirstChild("NotifyGui")

			if NotifyGui then
				genv.__Stored_NotifyGui = NotifyGui
				pcall(function()
					NotifyGui.ResetOnSpawn = false
				end)
			end

			break
		end

		task.wait(0.5)
	end

	task.wait(1.5)
	genv.__ZeroinEnterUICallback()
	genv.__ZeroinRunUICallback(function()
		if zeroinConfig.AutoRift then
			if v2238 and not v2238.enabled then
				v2260(true)
			end
		end

		if zeroinConfig.AutoSteal and v2229 then
			v2229:setEnabled(true)
		end

		if zeroinConfig.AutoPlace or zeroinConfig.AutoRift then
			task.spawn(t20.AutoPlaceLoop)
		end

		if zeroinConfig.AutoHatch or zeroinConfig.AutoRift then
			task.spawn(t20.AutoHatchLoop)
		end

		if zeroinConfig.AutoSell then
			t20.startAutoSellLoop()
		end

		if zeroinConfig.AutoSellEgg then
			t20.startAutoSellEggLoop()
		end

		if zeroinConfig.EggPredictUI then
			t20.toggleEggPanelUI(true)
			t20.startEggPanelLoop()
		end
	end)
end)
