RENZHUB | Instant TP
-- Pick a pet (icon + value), press Steal. Dodge full: the player stays frozen where they stand, the body (the clown) jumps from the base onto the egg,
-- plants a clown, takes the egg, drops it, visits the treadmill, comes back through the clown and delivers.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local localPlayer = Players.LocalPlayer



------------------------------------------------------------------ settings
local CFG = {
	SpeedCap = 1.15, -- never above 115% of the walk speed
	HopRatio = 1.515, -- hop distance = walk speed * ratio (a distance, not a speed)
	HopMin = 40,
	HopGap = 0.06, -- seconds between two hops (learned: grows after a pull-back, shrinks after a clean hop)
	HopGapMin = 0.06,
	HopGapMax = 0.2,
	HopRetries = 6,
	HopLift = 42, -- height of the hops above the start
	DimStep = 40, -- inside the Halloween dimension a teleport is a step of 40 studs per frame
	LandOffset = 14, -- landing spot in front of the line
	LandSettle = 0.08,
	DropDelay = 0.05,
	GrabInterval = 0.03,
	RegrabFar = 40, -- egg further than this: teleport onto it, otherwise run to it
	Height = 70, -- the safe-zone run starts above the base and comes down
	ClimbShare = 0.5,
	CarryRatio = 0.9,
	EasyRatio = 1.3,
}

-- Method: Relay: the drop lane (randomised a little each time) and the safe-zone point where the egg is banked
local RELAY_DROP = Vector3.new(554.071, 70.276, -395.573)
local RELAY_JITTER = 16
local RELAY_STEP = 500
local RELAY_LIFT = 40
local RELAY_GAP_MIN = 0.14
local RELAY_GAP_MAX = 0.16
local RELAY_PACE_RATIO = 7.5
local RELAY_SAFE = Vector3.new(542.93, 71.5, -405.58)
local PRE_GRAB_DELAY = 1.5
local RUN_RATIO = 1.05
local FIRST_HIT_WAIT = 1.4
local DODGE_LANE_Z = -382
local DODGE_Y = 152
local DODGE_DROP_POINT = Vector3.new(659.17, 70.83, -419.78)
local DODGE_BURST_STUDS = 855
local DODGE_BURST_SPEED = 5500
local DODGE_CRUISE_SPEED = 2200
local DODGE_DESCENT_STUDS = 120
local DODGE_DROP_WAIT = 0.2
local DODGE_MIN_DROP = 2.5
local DODGE_REGRAB_WAIT = 1.04
local DODGE_BASE = Vector3.new(540.4, 70.8, -383.3)
local DODGE_TRIP = Vector3.new(5846.0, 17010.1, 15699.4)
local DODGE_TRIP_HOLD = 0.15
local DODGE_R1_WAIT = 1.2
local DODGE_R2_WAIT = 1.6
local DODGE_PICK_DELAY = 0.35
local ISLAND_BACK = 2
local ISLANDS = {
	{ "Forest", 600, 661 },
	{ "Lake", 722, 811 },
	{ "Desert", 901, 1013 },
	{ "Jungle", 1125, 1265 },
	{ "Snow", 1405, 1582 },
	{ "Volcano", 1759, 1962 },
	{ "Abyss Ocean", 2166, 2400 },
	{ "Prehistoric", 2634, 2920 },
	{ "Cosmic", 3207, 3567 },
	{ "Cherry Blossom", 3928, 4170 },
	{ "Titan Temple", 4411, 5129 },
	{ "Light Dark", 5577, 6000 },
	{ "Enchanted Forest", 6524, math.huge },
}


------------------------------------------------------------------ game handles
local function safeRequire(getter)
	local ok, result = pcall(function()
		return require(getter())
	end)
	return ok and result or nil
end

local networkingFolder = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Networking")
local EggState = safeRequire(function() return ReplicatedStorage.Client.EggState end)
local Assets = safeRequire(function() return ReplicatedStorage.Data.Assets end)
local Mutations = safeRequire(function() return ReplicatedStorage.Shared.Modules.Mutations end)

local function remote(name)
	return networkingFolder:FindFirstChild(name)
end

local function root()
	local character = localPlayer.Character
	return character and character:FindFirstChild("HumanoidRootPart")
end

-- "Humanoid Swap" (the default shield): the character runs on a copy of its humanoid,
-- the original is kept out of the character while we steal.
local shield = { Original = nil, Clone = nil, Links = {}, Connection = nil, Added = nil }

local function walkSpeed()
	local character = localPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local speed = humanoid and humanoid.WalkSpeed or 16
	if shield.Original and shield.Original.Health > 0 then
		speed = math.min(speed, shield.Original.WalkSpeed)
	end
	local ok, result = pcall(function()
		local stat = localPlayer:FindFirstChild("leaderstats")
		stat = stat and stat:FindFirstChild("Speed")
		local util = require(ReplicatedStorage.Shared.Util.TreadmillUtil)
		return stat and util.SpeedPowerToWalkSpeed(stat.Value) or nil
	end)
	if ok and type(result) == "number" and result > 0 then
		speed = math.min(speed, result)
	end
	return speed
end

local function shieldControls(humanoid)
	pcall(function()
		local scripts = localPlayer:FindFirstChild("PlayerScripts")
		local module = scripts and scripts:FindFirstChild("PlayerModule")
		if module then
			local controls = require(module):GetControls()
			if type(controls) == "table" then
				controls.humanoid = humanoid
			end
		end
	end)
end

local function shieldAnimate(character)
	local animate = character and character:FindFirstChild("Animate")
	if animate and animate:IsA("LocalScript") then
		task.spawn(function()
			animate.Enabled = false
			task.wait()
			animate.Enabled = true
		end)
	end
end

local function shieldUnlink()
	for _, link in ipairs(shield.Links) do
		pcall(function()
			link:Disconnect()
		end)
	end
	table.clear(shield.Links)
end

local groundedStates = {
	[Enum.HumanoidStateType.Running] = true,
	[Enum.HumanoidStateType.RunningNoPhysics] = true,
	[Enum.HumanoidStateType.Landed] = true,
}

local function grounded(humanoid)
	if not humanoid or humanoid.Health <= 0 or humanoid.FloorMaterial == Enum.Material.Air then
		return false
	end
	return groundedStates[humanoid:GetState()] == true
end

local function shieldSwap()
	local character = localPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then
		return
	end
	if shield.Clone and shield.Clone.Parent == character then
		return
	end
	if not grounded(humanoid) then
		return
	end

	local clone = humanoid:Clone()
	humanoid.Parent = nil
	clone.Parent = character
	workspace.CurrentCamera.CameraSubject = clone
	shieldControls(clone)
	shieldAnimate(character)
	shield.Original = humanoid
	shield.Clone = clone

	table.insert(shield.Links, humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
		if clone.Parent ~= nil then
			clone.WalkSpeed = humanoid.WalkSpeed
		end
	end))

	local animator = humanoid:FindFirstChildOfClass("Animator")
	local animator2 = clone:FindFirstChildOfClass("Animator")
	if animator and animator2 then
		table.insert(shield.Links, animator.AnimationPlayed:Connect(function(played)
			local animation = played.Animation
			if not animation or clone.Parent == nil then
				return
			end
			local ok, track = pcall(function()
				return animator2:LoadAnimation(animation)
			end)
			if not ok or not track then
				return
			end
			pcall(function()
				track.Priority = played.Priority
				track.Looped = played.Looped
				track:Play(0.05, math.max(played.WeightTarget, 0.01), played.Speed)
			end)
			local stopped
			stopped = played.Stopped:Connect(function()
				stopped:Disconnect()
				pcall(function()
					track:Stop(0.1)
				end)
			end)
		end))
	end

	table.insert(shield.Links, clone.Died:Connect(function()
		shieldUnlink()
		shield.Original, shield.Clone = nil, nil
		local current = localPlayer.Character
		if current and humanoid.Parent == nil then
			humanoid.Parent = current
			workspace.CurrentCamera.CameraSubject = humanoid
			shieldControls(humanoid)
		end
		pcall(function()
			clone:Destroy()
		end)
		humanoid.Health = 0
	end))
end

local function shieldUndo()
	shieldUnlink()
	local character = localPlayer.Character
	local original, clone = shield.Original, shield.Clone
	shield.Original, shield.Clone = nil, nil
	if original and clone and character and original.Parent == nil and clone.Parent == character then
		original.Parent = character
		workspace.CurrentCamera.CameraSubject = original
		shieldControls(original)
		pcall(function()
			clone:Destroy()
		end)
		shieldAnimate(character)
	end
end

local function shieldStart()
	shieldSwap()
	local n = 0
	shield.Connection = RunService.Heartbeat:Connect(function(dt)
		n += dt
		local character = localPlayer.Character
		local missing = not (shield.Clone and character and shield.Clone.Parent == character)
		if (missing and 0.25 or 3) <= n then
			n = 0
			shieldSwap()
		end
	end)
	shield.Added = localPlayer.CharacterAdded:Connect(function(character)
		shieldUnlink()
		shield.Original, shield.Clone = nil, nil
		task.spawn(function()
			character:WaitForChild("Humanoid", 10)
			task.wait(1)
			if shield.Connection and localPlayer.Character == character then
				shieldSwap()
			end
		end)
	end)
end

local function shieldStop()
	if shield.Connection then
		shield.Connection:Disconnect()
		shield.Connection = nil
	end
	if shield.Added then
		shield.Added:Disconnect()
		shield.Added = nil
	end
	shieldUndo()
end

------------------------------------------------------------------ carry / delivery state
local alive = true
local state = { Carrying = false, Uid = nil, Delivered = 0, Busy = false, Cancel = false, Mult = 1, PulledAt = 0, HeldSeen = 0, GuessedDrop = false }

local function progress(frac, text)
	local f = state.Progress
	if f then
		f(frac, text)
	end
end

if type(EggState) == "table" and type(EggState.CarryChanged) == "table" and type(EggState.CarryChanged.Connect) == "function" then
	EggState.CarryChanged:Connect(function(arg)
		local carrying = type(arg) == "table" and arg.IsCarrying == true
		if carrying and arg.GuardDisabled == true then
			carrying = false
		end
		state.GuessedDrop = false
		if carrying then
			state.HeldSeen = os.clock()
			if not state.Carrying then
				state.CarryAt = os.clock()
				state.CarryLogged = false
			end
			state.WakeReq = arg.RunBackWakeDelayRequired
		end
		if carrying and type(arg.Uid) == "string" then
			state.Uid = arg.Uid
			local mult = tonumber(arg.SpeedMultiplier)
			if mult and mult > 0 then
				state.Mult = mult
			end
		end
		state.Carrying = carrying
	end)
end

pcall(function()
	remote("RE/EggWorld/FieldEggRedeemVerdict").OnClientEvent:Connect(function()
		state.Delivered = os.clock()
	end)
end)

pcall(function()
	remote("RE/Alerts/Raise").OnClientEvent:Connect(function(arg)
		if type(arg) == "table" and type(arg.Text) == "string" and string.find(string.lower(arg.Text), "delivery failed", 1, true) then
			state.DeliveryFailedAt = os.clock()
		end
	end)
end)

-- the server pulling us back ("Relocate") is noted so the hop is simply repeated
pcall(function()
	remote("RE/RigSync/Refresh").OnClientEvent:Connect(function(arg)
		if type(arg) == "string" then
			local ok, decoded = pcall(function()
				return game:GetService("HttpService"):JSONDecode(arg)
			end)
			arg = ok and decoded or nil
		end
		if type(arg) ~= "table" then
			return
		end
		if arg.Action == "Relocate" then
			state.PulledAt = os.clock()
			local a = arg.Arguments
			if type(a) == "table" and tonumber(a[1]) and tonumber(a[2]) and tonumber(a[3]) then
				state.RelocPos = Vector3.new(tonumber(a[1]), tonumber(a[2]), tonumber(a[3]))
			else
				state.RelocPos = nil
			end
		elseif arg.Action == "BeginRagdoll" then
			state.Ragdoll = true
			state.RagdollAt = os.clock()
			state.RagdollArgs = type(arg.Arguments) == "table" and arg.Arguments or nil
			local r = root()
			if r then
				pcall(function()
					r.AssemblyLinearVelocity = Vector3.zero
				end)
			end
		elseif arg.Action == "EndRagdoll" then
			state.Ragdoll = false
			state.RagdollEnd = os.clock()
		end
	end)
end)

local function takeEgg(uid)
	if type(uid) == "string" and type(EggState) == "table" and type(EggState.CarryFieldEgg) == "function" then
		pcall(EggState.CarryFieldEgg, uid)
	end
end

local function dropEgg()
	if type(EggState) == "table" and type(EggState.DropFieldEgg) == "function" then
		pcall(EggState.DropFieldEgg, "PlayerRequest")
	end
end

-- the prompt of the egg itself (nearest egg prompt to the egg's position), never one of another egg
local function promptNear(position, radius)
	local best, bestDistance = nil, radius
	for _, child in ipairs(workspace:GetChildren()) do
		if child.Name == "SmartPromptPart" and child:IsA("BasePart") then
			local prompt = child:FindFirstChild("CarryAreaEgg")
			if prompt and prompt:IsA("ProximityPrompt") then
				local distance = (child.Position - position).Magnitude
				if distance < bestDistance then
					best, bestDistance = prompt, distance
				end
			end
		end
	end
	return best
end

-- the carried egg is welded to the character: used to catch a missed carry signal
local function heldByMe(uid)
	local character = localPlayer.Character
	if type(uid) ~= "string" or not character then
		return false
	end
	local egg = workspace:FindFirstChild(uid)
	if not egg then
		return false
	end
	for _, d in ipairs(egg:GetDescendants()) do
		if d:IsA("WeldConstraint") or d:IsA("JointInstance") then
			local ok, a, b = pcall(function()
				return d.Part0, d.Part1
			end)
			if ok and ((a and a:IsDescendantOf(character)) or (b and b:IsDescendantOf(character))) then
				return true
			end
		end
	end
	return false
end

task.spawn(function()
	while alive do
		task.wait(0.2)
		if not state.Carrying then
			if state.GuessedDrop and heldByMe(state.Uid) then
				state.GuessedDrop, state.Carrying, state.HeldSeen = false, true, os.clock()
			end
		elseif heldByMe(state.Uid) then
			state.HeldSeen = os.clock()
		elseif os.clock() - state.HeldSeen > 0.8 then
			state.Carrying, state.GuessedDrop = false, true
		end
	end
end)

local function snapshot()
	local list = {}
	local ok, result = pcall(function()
		return remote("RF/EggWorld/AskFieldEggSnapshot"):InvokeServer()
	end)
	local records = ok and type(result) == "table" and result.Records or nil
	if type(records) ~= "table" then
		return list
	end
	for _, record in pairs(records) do
		if type(record) == "table" and type(record.Uid) == "string" and (record.State == "Slot" or record.State == "Dropped") and typeof(record.BottomCFrame) == "CFrame" then
			list[#list + 1] = record
		end
	end
	return list
end

local function eggPosition(uid)
	for _, record in ipairs(snapshot()) do
		if record.Uid == uid then
			return record.BottomCFrame.Position
		end
	end
	return nil
end

------------------------------------------------------------------ egg info for the list (icon, name, value)
local function describe(record)
	local directory = type(Assets) == "table" and Assets.Directory or nil
	local entry = type(directory) == "table" and directory[tostring(record.AssetCategory)] or nil
	local info = { Uid = record.Uid, Category = tostring(record.AssetCategory), Name = tostring(record.AssetCategory), Icon = "", Rarity = 0, Value = 0 }

	if type(entry) == "table" then
		info.Name = tostring(entry.DisplayName or record.AssetCategory)
		local icon = entry.Icon
		if icon ~= nil and tostring(icon) ~= "" then
			icon = tostring(icon)
			info.Icon = tonumber(icon) and ("rbxassetid://" .. icon) or icon
		end
		if type(entry.Rarity) == "table" then
			info.Rarity = tonumber(entry.Rarity.RarityNumber or entry.Rarity.Rank) or 0
		end

		local scale = tonumber(record.AssetScale) or 1
		local factor = scale > 5 and (scale / 5) ^ 1.2 * 19.637875755794113 or scale ^ 1.85
		local mutation = 1
		if type(Mutations) == "table" and type(Mutations.EarningsFor) == "function" then
			local okM, resM = pcall(Mutations.EarningsFor, type(record.Mutations) == "table" and record.Mutations or {})
			if okM and type(resM) == "number" then
				mutation = resM
			end
		end
		info.Value = (tonumber(entry.EarningRate) or 0) * factor * mutation
	end

	return info
end

local function money(value)
	local units = { { 1e12, "T" }, { 1e9, "B" }, { 1e6, "M" }, { 1e3, "K" } }
	for _, u in ipairs(units) do
		if value >= u[1] then
			return string.format("$%.2f%s/s", value / u[1], u[2])
		end
	end
	return string.format("$%d/s", math.floor(value + 0.5))
end

------------------------------------------------------------------ Instant TP logic
local status = function(text) end

local semi = { Dodge = true, DodgeGo = true, TakeFirstHit = true, WakeWait = 2.8, Frozen = false, Home = nil, Kind = nil, AtDrop = false, SlowRun = false, Fails = 0, ResetDone = false, Rotate = nil, ExitPath = nil, Log = {} }
local inDimensionNow = function()
	return localPlayer.Character ~= nil and localPlayer:GetAttribute("InHalloweenDimension") == true
end
local method = "Relay"

local function slog(msg)
	local r = root()
	local list = semi.Log
	list[#list + 1] = string.format("%.1f %s | y=%s", os.clock() % 1000, msg, r and string.format("%.0f", r.Position.Y) or "nil")
	if #list > 300 then
		table.remove(list, 1)
	end
end

pcall(function()
	getgenv().YslemSemiReport = function()
		return table.concat(semi.Log, "\n")
	end
end)

local function frozenCamera()
	local camera = workspace.CurrentCamera
	if not camera then
		return function() end
	end
	local oldType = camera.CameraType
	local frame = camera.CFrame
	pcall(function()
		camera.CameraType = Enum.CameraType.Scriptable
		camera.CFrame = frame
	end)
	return function()
		pcall(function()
			camera.CameraType = oldType
		end)
	end
end

-- FPS dip: 50 / 40 (never below 40), the pause between two switches is 200 ms while the ping is 200 ms or less,
-- otherwise it follows the ping (read once, when the dip starts). Only during the delivery.
local userFps = 240
pcall(function()
	if typeof(getfpscap) == "function" then
		local cap = tonumber(getfpscap())
		if cap and (cap == 0 or cap >= 60) then
			userFps = cap
		end
	end
end)

local function restoreFps()
	if typeof(setfpscap) == "function" then
		pcall(setfpscap, math.clamp(math.floor(userFps), 0, 1000))
	end
end

local function dipInterval()
	local ping = 0
	local ok, value = pcall(function()
		return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
	end)
	if ok then
		ping = tonumber(value) or 0
	end
	if ping <= 200 then
		return 0.2
	end
	return math.clamp(ping / 1000, 0.2, 1)
end

local function netPing()
	local ping = 0.1
	pcall(function()
		ping = localPlayer:GetNetworkPing()
	end)
	return math.clamp(tonumber(ping) or 0.1, 0, 1)
end

local fpsGen = 0
local function fpsOn()
	if typeof(setfpscap) ~= "function" then
		return
	end
	fpsGen += 1
	local mine = fpsGen
	task.spawn(function()
		local high = true
		local step = dipInterval()
		local started = os.clock()
		while fpsGen == mine and os.clock() - started < 60 do
			pcall(setfpscap, high and 50 or 40)
			high = not high
			task.wait(step)
		end
		if fpsGen == mine then
			restoreFps()
		end
	end)
end

local function fpsOff()
	fpsGen += 1
	restoreFps()
end

-- a still copy of the player stays where the egg was taken during the flight; removed on arrival
local stealClone = nil
local function dropClone()
	local copy = stealClone
	stealClone = nil
	if copy then
		pcall(function()
			copy:Destroy()
		end)
	end
end

local function postClone()
	dropClone()
	local character = localPlayer.Character
	if not character then
		return
	end
	local was = character.Archivable
	character.Archivable = true
	local copy = character:Clone()
	character.Archivable = was
	if copy then
		for _, d in ipairs(copy:GetDescendants()) do
			if d:IsA("LuaSourceContainer") or d:IsA("Animator") or d:IsA("AnimationController") or d:IsA("Sound") then
				pcall(function()
					d:Destroy()
				end)
			elseif d:IsA("Humanoid") then
				pcall(function()
					d.PlatformStand = true
					d.AutoRotate = false
					d.WalkSpeed = 0
					d.JumpPower = 0
					d.JumpHeight = 0
					d.BreakJointsOnDeath = false
					d.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
					d.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
				end)
			elseif d:IsA("BasePart") then
				d.Anchored = true
				d.CanCollide = false
				d.CanTouch = false
				d.CanQuery = false
			end
		end
		copy.Name = "Clone"
		copy.Parent = workspace
		stealClone = copy
	end
end

------------------------------------------------------------------ Semi TP: frozen view (the player stays still while the body works)
local viewState = nil

local function randomName()
	return string.format("%08x", math.random(0, 2147483647))
end

local function cloneModel(model, parent)
	local map = {}
	for _, d in ipairs(model:GetDescendants()) do
		map[d] = d.Archivable
		pcall(function()
			d.Archivable = true
		end)
	end
	local was = model.Archivable
	model.Archivable = true
	local ok, result = pcall(function()
		return model:Clone()
	end)
	model.Archivable = was
	for inst, value in pairs(map) do
		pcall(function()
			inst.Archivable = value
		end)
	end
	if not ok or not result then
		return nil
	end
	result.Name = randomName()
	for _, d in ipairs(result:GetDescendants()) do
		if d:IsA("LuaSourceContainer") or d:IsA("Sound") or d:IsA("ForceField") or d:IsA("JointInstance") or d:IsA("Constraint") or d:IsA("WeldConstraint") or d:IsA("BodyMover") or d:IsA("ProximityPrompt") or d:IsA("BillboardGui") then
			pcall(function()
				d:Destroy()
			end)
		elseif d:IsA("BasePart") then
			d.Anchored = true
			d.CanCollide = false
			d.CanQuery = false
			d.CanTouch = false
		elseif d:IsA("Humanoid") then
			d.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
			d.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
		end
	end
	result.Parent = parent
	return result
end

local promptSaved = nil
local function hidePrompts(hide)
	pcall(function()
		local service = game:GetService("ProximityPromptService")
		if hide then
			promptSaved = promptSaved or { guis = {}, max = nil }
			if promptSaved.max == nil then
				local okMax, current = pcall(function()
					return service.MaxPromptsVisible
				end)
				if okMax then
					promptSaved.max = current
				end
			end
			pcall(function()
				service.MaxPromptsVisible = 0
			end)
			local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")
			if playerGui then
				for _, promptGui in ipairs(playerGui:GetChildren()) do
					local guiName = string.lower(promptGui.Name)
					if promptGui:IsA("ScreenGui") and promptGui.Enabled and not string.find(guiName, "yslem", 1, true)
						and (string.find(guiName, "prompt", 1, true) or string.find(guiName, "interact", 1, true)) then
						promptGui.Enabled = false
						promptSaved.guis[#promptSaved.guis + 1] = promptGui
					end
				end
			end
		elseif promptSaved then
			local saved = promptSaved
			promptSaved = nil
			for _, promptGui in ipairs(saved.guis) do
				pcall(function()
					promptGui.Enabled = true
				end)
			end
			if saved.max ~= nil then
				pcall(function()
					service.MaxPromptsVisible = saved.max
				end)
			end
		end
	end)
end

local sinkName = nil
local touchSaved = nil
local function sinkInput(on)
	pcall(function()
		local cas = game:GetService("ContextActionService")
		if on then
			if sinkName then
				return
			end
			sinkName = "YslemFreeze" .. tostring(math.random(100000, 999999))
			cas:BindActionAtPriority(sinkName, function()
				return Enum.ContextActionResult.Sink
			end, false, 3000, Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.Up, Enum.KeyCode.Down,
				Enum.KeyCode.Left, Enum.KeyCode.Right, Enum.KeyCode.Space, Enum.KeyCode.Thumbstick1, Enum.KeyCode.ButtonA)
		elseif sinkName then
			local name = sinkName
			sinkName = nil
			cas:UnbindAction(name)
		end
	end)
	pcall(function()
		local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")
		local touch = playerGui and playerGui:FindFirstChild("TouchGui")
		if on then
			if touch and touch:IsA("ScreenGui") and not touchSaved then
				touchSaved = { Gui = touch, Enabled = touch.Enabled }
				touch.Enabled = false
			end
		elseif touchSaved then
			local saved = touchSaved
			touchSaved = nil
			saved.Gui.Enabled = saved.Enabled
		end
	end)
end

local function viewControls(on)
	hidePrompts(not on)
	sinkInput(not on)
	pcall(function()
		local scripts = localPlayer:FindFirstChild("PlayerScripts")
		local module = scripts and scripts:FindFirstChild("PlayerModule")
		if module then
			local controls = require(module):GetControls()
			if on then
				controls:Enable()
			else
				controls:Disable()
			end
		end
	end)
end

local function releaseView()
	local view = viewState
	if not view then
		return
	end
	viewState = nil
	semi.Frozen = false
	viewControls(true)
	if view.BindName then
		pcall(function()
			RunService:UnbindFromRenderStep(view.BindName)
		end)
	end
	if view.Link then
		pcall(function()
			view.Link:Disconnect()
		end)
	end
	if view.Beat then
		pcall(function()
			view.Beat:Disconnect()
		end)
	end
	for _, part in ipairs(view.Hidden) do
		pcall(function()
			part.LocalTransparencyModifier = 0
		end)
	end
	for _, extra in ipairs(view.Extras) do
		pcall(function()
			extra.Inst.Enabled = extra.Prev
		end)
	end
	pcall(function()
		view.Camera.CameraType = view.CameraType
		if view.Follow then
			local liveChar = localPlayer.Character
			local liveHum = liveChar and liveChar:FindFirstChildOfClass("Humanoid")
			if liveHum then
				view.Camera.CameraSubject = liveHum
			end
		end
	end)
	for _, copy in ipairs(view.Copies) do
		pcall(function()
			copy:Destroy()
		end)
	end
end

local function freezeView(character, offset, cameraCFrame, forced)
	local camera = workspace.CurrentCamera
	if viewState or not character or not camera then
		return false
	end
	offset = offset or Vector3.zero
	local view = { Camera = camera, CameraType = camera.CameraType, CameraCFrame = cameraCFrame or camera.CFrame, Copies = {}, Hidden = {}, Parts = {}, Extras = {} }
	viewState = view
	view.Forced = forced == true
	view.Follow = getgenv().YslemCamFollow ~= false
	if not view.Forced then
		task.delay(120, function()
			if viewState == view then
				releaseView()
			end
		end)
	end

	local hiddenSet, extraSet = {}, {}
	for _, d in ipairs(character:GetDescendants()) do
		if d:IsA("BasePart") or d:IsA("Decal") or d:IsA("Texture") then
			hiddenSet[d] = true
			view.Hidden[#view.Hidden + 1] = d
			if d:IsA("BasePart") then
				view.Parts[#view.Parts + 1] = d
			end
		end
	end
	local lastScan = os.clock()

	local function scanExtras()
		for _, d in ipairs(character:GetDescendants()) do
			if not extraSet[d] and (d:IsA("BillboardGui") or d:IsA("SurfaceGui") or d:IsA("ParticleEmitter") or d:IsA("Trail") or d:IsA("Beam")
				or d:IsA("Highlight") or d:IsA("Fire") or d:IsA("Smoke") or d:IsA("Sparkles") or d:IsA("Light")) then
				extraSet[d] = true
				local okEnabled, enabledValue = pcall(function()
					return d.Enabled
				end)
				view.Extras[#view.Extras + 1] = { Inst = d, Prev = okEnabled and enabledValue or false }
			end
		end
	end
	pcall(scanExtras)

	local function tick()
		if os.clock() - lastScan > 0.5 then
			lastScan = os.clock()
			if view.Semi then
				hidePrompts(true)
			end
			pcall(function()
				for _, d in ipairs(character:GetDescendants()) do
					if not hiddenSet[d] and (d:IsA("BasePart") or d:IsA("Decal") or d:IsA("Texture")) then
						hiddenSet[d] = true
						view.Hidden[#view.Hidden + 1] = d
						if d:IsA("BasePart") then
							view.Parts[#view.Parts + 1] = d
						end
					end
				end
				for _, copy in ipairs(view.Copies) do
					if copy.Parent ~= camera then
						copy.Parent = camera
					end
				end
				scanExtras()
			end)
		end
		local shown = view.Follow and 0 or 1
		pcall(function()
			for _, part in ipairs(view.Parts) do
				if part.LocalTransparencyModifier ~= shown then
					part.LocalTransparencyModifier = shown
				end
			end
		end)
		if #view.Extras > 0 then
			pcall(function()
				for _, extra in ipairs(view.Extras) do
					if extra.Inst.Enabled then
						extra.Inst.Enabled = false
					end
				end
			end)
		end
		pcall(function()
			local live = workspace.CurrentCamera
			if live and live ~= camera then
				camera = live
				view.Camera = live
			end
			if view.Follow then
				local liveChar = localPlayer.Character
				local liveHum = liveChar and liveChar:FindFirstChildOfClass("Humanoid")
				if liveHum then
					if camera.CameraType ~= Enum.CameraType.Custom then
						camera.CameraType = Enum.CameraType.Custom
					end
					if camera.CameraSubject ~= liveHum then
						camera.CameraSubject = liveHum
					end
					return
				end
			end
			if camera.CameraType ~= Enum.CameraType.Scriptable then
				camera.CameraType = Enum.CameraType.Scriptable
			end
			camera.CFrame = view.CameraCFrame
		end)
	end

	tick()
	view.BindName = randomName()
	if not pcall(function()
		RunService:BindToRenderStep(view.BindName, Enum.RenderPriority.Last.Value + 1, tick)
	end) then
		view.BindName = nil
		view.Link = RunService.RenderStepped:Connect(tick)
	end
	view.Beat = RunService.Heartbeat:Connect(tick)

	local ok, copy = false, nil
	if not view.Follow then
		ok, copy = pcall(cloneModel, character, camera)
	end
	if ok and copy then
		if offset.Magnitude > 0.01 then
			for _, d in ipairs(copy:GetDescendants()) do
				if d:IsA("BasePart") then
					pcall(function()
						d.CFrame = d.CFrame + offset
					end)
				end
			end
		end
		view.Copies[#view.Copies + 1] = copy
	end

	view.Semi = true
	viewControls(false)
	semi.Frozen = true
	return true
end

-- Auto Steal cancelled while frozen: the body first goes back to where the copy waits, then camera and controls return
local function releaseBackHome(home)
	local frozen = viewState
	if not frozen then
		return
	end
	if typeof(home) ~= "Vector3" then
		releaseView()
		return
	end
	local started = os.clock()
	while os.clock() - started < 7 and viewState == frozen do
		local r = root()
		if not r or r.Position.Y < 5000 then
			break
		end
		RunService.Heartbeat:Wait()
	end
	for _ = 1, 10 do
		if viewState ~= frozen then
			return
		end
		local r = root()
		if r then
			pcall(function()
				r.CFrame = CFrame.new(home) * r.CFrame.Rotation
				r.AssemblyLinearVelocity = Vector3.zero
				r.AssemblyAngularVelocity = Vector3.zero
			end)
		end
		RunService.Heartbeat:Wait()
	end
	if viewState == frozen then
		releaseView()
	end
end

local function swapped()
	local character = localPlayer.Character
	return shield.Clone ~= nil and character ~= nil and shield.Clone.Parent == character
end

------------------------------------------------------------------ map helpers
local function lineInfo()
	local world = workspace:FindFirstChild("World") or workspace:FindFirstChild("__OBJECTS")
	world = world and world:FindFirstChild("Areas")
	world = world and world:FindFirstChild("SeparationLine")
	local ok = world and world:IsA("BasePart")
	return ok and world.Position.X or 552.2, ok and world.Position.Y or 67.67
end

local function homePoint()
	for _, def in ipairs({
		{ { "GearGiver_Slap", "Podium" }, Vector3.new(-16.415, 21.072, -6.106) },
		{ { "World", "Machines", "RiftMachine", "Rift", "Meshes/VoidPortal_Cube.003" }, Vector3.new(-26.776, 1.75, 18.665) },
		{ { "__OBJECTS", "Machines", "RiftMachine", "Rift", "Meshes/VoidPortal_Cube.003" }, Vector3.new(-26.776, 1.75, 18.665) },
	}) do
		local node = workspace
		for _, name in ipairs(def[1]) do
			node = node and node:FindFirstChild(name) or nil
		end
		if node and node:IsA("BasePart") then
			return node.CFrame:PointToWorldSpace(def[2])
		end
	end
	return Vector3.new(528.7, 70.57, -364.11)
end

local function place(position)
	local r = root()
	if not r then
		return
	end
	pcall(function()
		r.CFrame = CFrame.new(position) * CFrame.Angles(0, math.rad(90), 0)
		r.AssemblyLinearVelocity = Vector3.zero
		r.AssemblyAngularVelocity = Vector3.zero
	end)
end

-- portals / arenas / teleporters are walked around 
local dangerCache, dangerAt = {}, 0
local function dangers()
	if os.clock() - dangerAt < 5 then
		return dangerCache
	end
	dangerAt = os.clock()
	local list = {}
	local function add(inst)
		local ok, cf, size = pcall(function()
			if inst:IsA("Model") then
				return inst:GetBoundingBox()
			elseif inst:IsA("BasePart") then
				return inst.CFrame, inst.Size
			end
		end)
		if ok and cf and size then
			local half = Vector3.new(math.abs(size.X), 0, math.abs(size.Z)) * 0.5
			local rot = (cf - cf.Position):VectorToWorldSpace(half)
			local rx = math.max(math.abs(rot.X), half.X, half.Z)
			local rz = math.max(math.abs(rot.Z), half.X, half.Z)
			list[#list + 1] = { MinX = cf.Position.X - rx, MaxX = cf.Position.X + rx, MinZ = cf.Position.Z - rz, MaxZ = cf.Position.Z + rz }
		end
	end
	local function bad(name)
		if name == "ScrambleLocalVisuals" or name == "DrScrambleEvent" then
			return false
		end
		name = string.lower(name)
		return string.find(name, "portal", 1, true) or string.find(name, "teleport", 1, true) or string.find(name, "mech", 1, true) or string.find(name, "arena", 1, true) or string.find(name, "scramble", 1, true)
	end
	for _, child in ipairs(workspace:GetChildren()) do
		if (child:IsA("Model") or child:IsA("BasePart") or child:IsA("Folder")) and bad(child.Name) then
			if child:IsA("Folder") then
				for _, inner in ipairs(child:GetChildren()) do
					add(inner)
				end
			else
				add(child)
			end
		end
	end
	local build = workspace:FindFirstChild("World")
	build = build and build:FindFirstChild("Build")
	if build then
		for _, child in ipairs(build:GetChildren()) do
			if bad(child.Name) then
				for _, inner in ipairs(child:GetChildren()) do
					add(inner)
				end
			end
		end
	end
	dangerCache = list
	return list
end

-- if the straight line crosses a danger zone, aim at the corner of it instead
local function avoid(from, to)
	for _, d in ipairs(dangers()) do
		local x0, x1, z0, z1 = d.MinX - 12, d.MaxX + 12, d.MinZ - 12, d.MaxZ + 12
		local inside = from.X >= x0 and from.X <= x1 and from.Z >= z0 and from.Z <= z1
		if not inside then
			local t0, t1, hit = 0, 1, true
			for _, axis in ipairs({ { from.X, to.X - from.X, x0, x1 }, { from.Z, to.Z - from.Z, z0, z1 } }) do
				local pos, delta, lo, hi = axis[1], axis[2], axis[3], axis[4]
				if math.abs(delta) < 1e-6 then
					if pos < lo or pos > hi then
						hit = false
					end
				else
					local ta, tb = (lo - pos) / delta, (hi - pos) / delta
					if ta > tb then
						ta, tb = tb, ta
					end
					t0, t1 = math.max(t0, ta), math.min(t1, tb)
					if t0 > t1 then
						hit = false
					end
				end
			end
			if hit then
				local zLow, zHigh = z0 - 2, z1 + 2
				local z = math.abs(from.Z - zLow) <= math.abs(from.Z - zHigh) and zLow or zHigh
				if z < -440 or z > -290 then
					z = z == zLow and zHigh or zLow
				end
				local x = math.abs(from.X - x0) <= math.abs(from.X - x1) and x0 or x1
				if math.abs(from.Z - z) < 3 then
					x = math.abs(to.X - x0) <= math.abs(to.X - x1) and x0 or x1
				end
				return Vector3.new(x, to.Y, z)
			end
		end
	end
	return to
end

-- current position of an egg lying in the world (cheap), with the snapshot as fallback
local function eggNow(uid, cache)
	local node = workspace:FindFirstChild(uid)
	local slots = workspace:FindFirstChild("AreaEggSlotsClient")
	node = node or (slots and slots:FindFirstChild(uid))
	if node then
		local ok, pos = pcall(function()
			return node:GetPivot().Position
		end)
		if ok and pos then
			cache.Pos, cache.At = pos, os.clock()
			return pos
		end
	end
	if os.clock() - cache.At >= 0.5 then
		cache.At = os.clock()
		cache.Pos = eggPosition(uid) or cache.Pos
	end
	return cache.Pos
end

local function holdStill()
	local function zero()
		local r = root()
		if r then
			pcall(function()
				r.AssemblyLinearVelocity = Vector3.zero
				r.AssemblyAngularVelocity = Vector3.zero
			end)
		end
	end
	zero()
	local link
	pcall(function()
		if RunService.Stepped then
			link = RunService.Stepped:Connect(zero)
		end
	end)
	return function()
		if link then
			pcall(function()
				link:Disconnect()
			end)
		end
	end
end

local function ragdollWait()
	local seen = state.RagdollAt
	if not (state.Ragdoll and seen and os.clock() - seen < 12) then
		return false
	end
	state.Hits = (state.Hits or 0) + 1
	status("Knocked down, staying still")
	local kb = state.RagdollArgs
	slog(string.format("hit by the guard (%d this trip): staying still until the ragdoll ends, knock-back %s", state.Hits, kb and string.format("%.0f,%.0f,%.0f", tonumber(kb[2]) or 0, tonumber(kb[3]) or 0, tonumber(kb[4]) or 0) or "?"))
	local release = holdStill()
	local stop = os.clock() + 8
	while state.Ragdoll and os.clock() < stop and not state.Cancel do
		RunService.Heartbeat:Wait()
		local r = root()
		if r then
			pcall(function()
				r.AssemblyLinearVelocity = Vector3.zero
				r.AssemblyAngularVelocity = Vector3.zero
			end)
		end
	end
	release()
	state.Ragdoll = false
	local calm = 0
	while calm < 0.15 and not state.Cancel do
		calm += RunService.Heartbeat:Wait()
	end
	return true
end

-- go to the egg: straight on the ground at 115% of the walk speed (never faster), or, after the Semi TP exit, in the air
-- at the given ratio with a cruise height above the egg. From the base side it first walks out to the safe-zone point.
local function runToEgg(uid, egg, opts)
	opts = opts or {}
	local ratio = math.min(opts.Ratio or CFG.SpeedCap, CFG.SpeedCap)
	local height = opts.Height or 0
	local lineX = lineInfo()
	local home = homePoint()
	local character = localPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.PlatformStand = false
		if character:FindFirstChildWhichIsA("Tool") then
			pcall(function()
				humanoid:UnequipTools()
			end)
		end
	end

	local r = root()
	if not r then
		return false
	end
	local stage = "field"
	if not opts.Field and r.Position.X < lineX - 2 and Vector3.new(r.Position.X - home.X, 0, r.Position.Z - home.Z).Magnitude > 20 then
		stage = "safe"
	end

	local runY = egg.Y + 3
	local function snapToHeight(target)
		local at = root()
		local current = localPlayer.Character
		if not at or not current or math.abs(at.Position.Y - target) < 1 or math.abs(at.Position.Y - target) > 90 then
			return false
		end
		pcall(function()
			current:PivotTo(CFrame.new(Vector3.new(at.Position.X, target, at.Position.Z)) * at.CFrame.Rotation)
			at.AssemblyLinearVelocity = Vector3.new(at.AssemblyLinearVelocity.X, 0, at.AssemblyLinearVelocity.Z)
		end)
		return true
	end
	if stage == "field" and height > 0.5 then
		snapToHeight(runY + height)
	end

	local started, lastCheck, lastPos, lastTake = os.clock(), os.clock(), r.Position, 0
	while os.clock() - started < 120 and not state.Cancel do
		if ragdollWait() then
			started += 1
		end
		r = root()
		if not r then
			return false
		end
		local flatEgg = Vector3.new(egg.X - r.Position.X, 0, egg.Z - r.Position.Z)
		if state.Carrying and state.Uid == uid then
			break
		end
		if stage == "field" and flatEgg.Magnitude <= 2.5 and (height <= 0.5 or r.Position.Y - runY < 4) then
			break
		end
		local target = egg
		if stage == "safe" then
			if Vector3.new(home.X - r.Position.X, 0, home.Z - r.Position.Z).Magnitude <= 6 then
				stage = "field"
				if height > 0.5 then
					snapToHeight(runY + height)
				end
			else
				target = home
			end
		end

		local waypoint = avoid(r.Position, target)
		local flat = Vector3.new(waypoint.X - r.Position.X, 0, waypoint.Z - r.Position.Z)
		local unit = flat.Magnitude > 0.01 and flat.Unit or Vector3.zero
		local speed = math.max(walkSpeed() * ratio, 8)
		if height > 0.5 and stage == "field" then
			local wantY = flatEgg.Magnitude <= 3 and runY or runY + height
			if (flatEgg.Magnitude <= 3 and snapToHeight(runY)) or (math.abs(wantY - r.Position.Y) > 2 and snapToHeight(wantY)) then
				RunService.Heartbeat:Wait()
				continue
			end
			local vy = math.clamp((wantY - r.Position.Y) / 0.12, -speed * 0.5, speed * 0.5)
			local horizontal = unit * math.min(math.sqrt(math.max(speed * speed - vy * vy, 0)), flat.Magnitude / 0.05)
			pcall(function()
				r.AssemblyLinearVelocity = Vector3.new(horizontal.X, vy, horizontal.Z)
			end)
		else
			local v = unit * math.min(speed, flat.Magnitude / 0.05)
			pcall(function()
				r.AssemblyLinearVelocity = Vector3.new(v.X, r.AssemblyLinearVelocity.Y, v.Z)
				if humanoid and unit.Magnitude > 0 then
					humanoid:Move(unit, false)
				end
			end)
		end

		-- stuck on something: jump
		if os.clock() - lastCheck >= 1.5 then
			if (r.Position - lastPos).Magnitude < 3 and humanoid and flatEgg.Magnitude > 15 then
				pcall(function()
					humanoid.Jump = true
				end)
			end
			lastPos, lastCheck = r.Position, os.clock()
		end

		-- close enough for the prompt: ask for the egg while arriving
		if stage == "field" and flatEgg.Magnitude <= 9 and os.clock() - lastTake > 0.1 then
			lastTake = os.clock()
			task.spawn(takeEgg, uid)
		end
		RunService.Heartbeat:Wait()
	end

	r = root()
	if r then
		pcall(function()
			r.AssemblyLinearVelocity = Vector3.new(0, r.AssemblyLinearVelocity.Y, 0)
			if humanoid then
				humanoid:Move(Vector3.zero, false)
			end
		end)
	end
	return state.Carrying or (r ~= nil and Vector3.new(egg.X - r.Position.X, 0, egg.Z - r.Position.Z).Magnitude <= 6)
end

-- take the egg that lies next to us (also used to take it back after the drop): follow it, fire its prompt and send the request
local function grab(uid, timeout)
	local cache = { At = 0 }
	local waited, since = 0, 1
	while not state.Carrying and waited < timeout and not state.Cancel do
		local stillFrom = os.clock()
		if ragdollWait() then
			timeout += os.clock() - stillFrom
			since = 1
		end
		local r = root()
		local egg = eggNow(uid, cache)
		local dt = math.max(RunService.Heartbeat:Wait(), 1 / 240)
		waited += dt
		since += dt
		if r and egg then
			local delta = egg - r.Position
			if delta.Magnitude > 2 then
				local pace = math.max(walkSpeed() * CFG.SpeedCap, 16)
				local v = delta / math.max(0.08, dt)
				if v.Magnitude > pace then
					v = v.Unit * pace
				end
				pcall(function()
					r.AssemblyLinearVelocity = v + Vector3.new(0, workspace.Gravity * dt * 0.5, 0)
					r.AssemblyAngularVelocity = Vector3.zero
				end)
			end
			if since >= CFG.GrabInterval then
				since = 0
				local prompt = promptNear(egg - Vector3.new(0, 3, 0), 10)
				if prompt and typeof(fireproximityprompt) == "function" then
					pcall(function()
						prompt.HoldDuration = 0
					end)
					pcall(fireproximityprompt, prompt)
				end
				task.spawn(takeEgg, uid)
			end
		elseif since >= CFG.GrabInterval then
			since = 0
			task.spawn(takeEgg, uid)
		end
	end
	local r = root()
	if r then
		pcall(function()
			r.AssemblyLinearVelocity = Vector3.zero
		end)
	end
	return state.Carrying and state.Uid == uid
end

local function regrab(uid)
	if state.Carrying then
		return true
	end
	local r = root()
	local egg = eggNow(uid, { At = 0 })
	local gap = r and egg and Vector3.new(r.Position.X - egg.X, 0, r.Position.Z - egg.Z).Magnitude or 0
	if gap > 1500 then
		slog(string.format("the egg is %.0f studs away: no teleport that long to take it back", gap))
		status("The egg is too far to take back")
		return false
	end
	if r and egg and gap > CFG.RegrabFar then
		status("The egg fell far behind, teleporting onto it")
		place(egg + Vector3.new(0, 3, 0))
	else
		status("The egg fell close, taking it back")
	end
	return grab(uid, 3)
end

local function groundY(position, fallback)
	local y = fallback
	pcall(function()
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = { localPlayer.Character }
		params.IgnoreWater = true
		params.RespectCanCollide = true
		local hit = workspace:Raycast(position + Vector3.new(0, 60, 0), Vector3.new(0, -140, 0), params)
		if hit and hit.Material ~= Enum.Material.Water and math.abs(hit.Position.Y - fallback) < 40 then
			y = hit.Position.Y + 3.5
		end
	end)
	return y
end

-- safe zone: same route as the Normal mode: checkpoint 7 studs past the line, then the base.
-- Speed = the carry plan (never above 115% of the walk speed), the run starts above the base and comes down.
local function carrySpeed(distance)
	local ws = walkSpeed()
	if semi.SlowRun then
		return math.max(ws * 0.8 * state.Mult, 8)
	end
	local base = ws * math.min(CFG.CarryRatio, CFG.SpeedCap) * state.Mult
	local fast = base * 1.5 -- SpeedRatio
	local excess = 5.5 * base -- ExcessSeconds
	local limit = fast
	if distance and distance > excess then
		limit = math.min(fast, base * distance / (distance - excess))
	end
	return math.min(math.max(math.min(base * CFG.EasyRatio, limit), base), math.max(ws * CFG.SpeedCap, base))
end

-- Semi TP delivery: two teleports (checkpoint past the line, then the base), the egg is put down on the base
local function tpHome(lineX, laneZ, started)
	local home = homePoint()
	local steps = { Vector3.new(lineX - 7, home.Y, laneZ), home }
	status("Safe zone: teleporting")
	for _, target in ipairs(steps) do
		local tries = 0
		while state.Carrying and state.Delivered < started and not state.Cancel and tries < 3 do
			tries += 1
			local pulledBefore = state.PulledAt
			local held = 0
			while held < math.max(CFG.HopGap, 0.1) do
				place(target)
				held += RunService.Heartbeat:Wait()
			end
			local check = root()
			local pulled = state.PulledAt > pulledBefore or (check ~= nil and Vector3.new(check.Position.X - target.X, 0, check.Position.Z - target.Z).Magnitude > 10)
			if not pulled then
				break
			end
		end
	end
	local waited = 0
	while state.Carrying and state.Delivered < started and not state.Cancel and waited < 1 do
		waited += RunService.Heartbeat:Wait()
	end
	if state.Carrying and state.Delivered < started and not state.Cancel then
		local at = root()
		if at and Vector3.new(at.Position.X - home.X, 0, at.Position.Z - home.Z).Magnitude > 6 then
			place(home)
			RunService.Heartbeat:Wait()
		end
		status("Safe zone: dropping the egg on the base")
		dropEgg()
		local confirm = 0
		while state.Delivered < started and confirm < 1 and not state.Cancel do
			confirm += RunService.Heartbeat:Wait()
		end
	end
	return state.Delivered >= started
end

local function runHome(lineX, laneZ)
	local started = os.clock()
	local home = homePoint()
	local checkpoint = lineX - 7
	local height = semi.SlowRun and 0 or CFG.Height
	local share = math.clamp(CFG.ClimbShare, 0.1, 0.9)
	local descent = height * math.sqrt(1 - share * share) / share
	local character = localPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.PlatformStand = false
	end

	-- rise above the base first (no horizontal move)
	local r = root()
	if r and character and height > 0.5 and home.Y + height - 2 > r.Position.Y then
		pcall(function()
			character:PivotTo(CFrame.new(Vector3.new(r.Position.X, home.Y + height, r.Position.Z)) * r.CFrame.Rotation)
			r.AssemblyLinearVelocity = Vector3.zero
			r.AssemblyAngularVelocity = Vector3.zero
		end)
	end

	-- the speed is planned once, at the start, from the distance still to go
	local start = root()
	local speed = carrySpeed(start and (Vector3.new(start.Position.X - home.X, 0, start.Position.Z - home.Z).Magnitude + math.max(0, height) * 2) or nil)

	local last = os.clock()
	local timeout = 0
	status("Safe zone")
	while state.Carrying and state.Delivered < started and not state.Cancel and timeout < 25 do
		r = root()
		if not r then
			return false
		end
		local now = os.clock()
		local dt = math.max(now - last, 1 / 240)
		last = now
		timeout += dt

		local toHome = r.Position.X <= checkpoint + 2
		local target = toHome and home or Vector3.new(checkpoint, home.Y, laneZ)
		if toHome and Vector3.new(home.X - r.Position.X, 0, home.Z - r.Position.Z).Magnitude < 2 then
			break
		end
		local aim = avoid(r.Position, target)
		local flat = Vector3.new(aim.X - r.Position.X, 0, aim.Z - r.Position.Z)
		local remaining = toHome and 0 or math.max(0, r.Position.X - checkpoint)
		local wantY = home.Y + height
		if toHome or remaining <= descent then
			wantY = home.Y + height * math.clamp(remaining / math.max(descent, 1), 0, 1)
		end
		local vy = math.clamp((wantY - r.Position.Y) / 0.12, -speed * share, speed * share)
		local horizontal = math.sqrt(math.max(speed * speed - vy * vy, 0))
		local v = flat.Magnitude > 0.01 and flat.Unit * math.min(horizontal, flat.Magnitude / 0.05) or Vector3.zero
		pcall(function()
			r.AssemblyLinearVelocity = Vector3.new(v.X, vy, v.Z)
		end)
		RunService.Heartbeat:Wait()
	end

	if humanoid then
		pcall(function()
			humanoid:Move(Vector3.zero, false)
		end)
	end

	local settle = 0
	while settle < 2 and state.Delivered < started and state.Carrying and not state.Cancel do
		settle += RunService.Heartbeat:Wait()
	end
	-- still in the hands at home: put it down so the base takes it
	if state.Carrying and state.Delivered < started and not state.Cancel then
		task.wait(0.2)
		dropEgg()
		local waited = 0
		while state.Delivered < started and waited < 1 do
			waited += RunService.Heartbeat:Wait()
		end
	end
	return state.Delivered >= started
end

-- Dodge return: chain on the lane, drop in front of the line, take it back, bank where the clown waits.
local function treadmillStand()
	local ok, standAt = pcall(function()
		local PlotState = require(ReplicatedStorage.Client.PlotState)
		local slot = type(PlotState.ResolveLocalSlot) == "function" and PlotState.ResolveLocalSlot() or PlotState.GetMySlot()
		local plots = type(PlotState.ResolveFolder) == "function" and PlotState.ResolveFolder() or PlotState.GetPlotsFolder()
		local plot = plots and slot and plots:FindFirstChild(tostring(slot))
		local bottom = plot and plot:FindFirstChild("TreadmillBottom")
		if not (bottom and bottom:IsA("BasePart")) then
			return nil
		end
		local character = localPlayer.Character
		local r = character and character:FindFirstChild("HumanoidRootPart")
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if not r or not humanoid then
			return nil
		end
		local feet = humanoid.RigType == Enum.HumanoidRigType.R15 and (r.Size.Y * 0.5 + math.max(humanoid.HipHeight, 0.5)) or (r.Size.Y * 0.5 + 2)
		return (bottom.CFrame * CFrame.new(0, bottom.Size.Y * 0.5 + feet + 0.05, 0)).Position
	end)
	return ok and standAt or nil
end

local function treadmillMounted()
	local snapshot = remote("RF/Treadmill/AskRenderSnapshot")
	if not snapshot or not snapshot:IsA("RemoteFunction") then
		return nil
	end
	local ok, ids = pcall(snapshot.InvokeServer, snapshot)
	if not ok or type(ids) ~= "table" then
		return nil
	end
	return table.find(ids, localPlayer.UserId) ~= nil
end

-- the treadmill reset: onto the own treadmill, worn (confirmed by the server, 0.7 s), held 0.25 s, taken off (confirmed, 0.7 s)
local function treadmillReset()
	local wear = remote("RF/Treadmill/AskWearStill")
	local doff = remote("RF/Treadmill/AskDoff")
	local stand = treadmillStand()
	if not (wear and doff and stand) or state.Cancel then
		slog("treadmill reset: not available (remote or stand missing)")
		return false
	end
	place(stand)
	local function pause(t)
		local w = 0
		while w < t and not state.Cancel do
			w += RunService.Heartbeat:Wait()
		end
	end
	pause(0.15)
	local mounted = false
	local mountBy = os.clock() + 0.7
	while not state.Cancel and os.clock() < mountBy do
		pcall(wear.InvokeServer, wear)
		pause(0.08)
		if treadmillMounted() == true then
			mounted = true
			break
		end
	end
	if mounted then
		pause(0.25)
	end
	local released = false
	local releaseBy = os.clock() + 0.7
	while not state.Cancel and os.clock() < releaseBy do
		pcall(doff.InvokeServer, doff)
		pause(0.08)
		if treadmillMounted() == false then
			released = true
			break
		end
	end
	slog(string.format("treadmill reset: worn=%s, taken off=%s", tostring(mounted), tostring(released)))
	return mounted and released
end

local clown = { At = nil }
local function plantClown(pos)
	pcall(postClone)
	local copy = stealClone
	local r = root()
	if copy and r then
		pcall(function()
			copy.Name = randomName()
			copy:PivotTo(CFrame.new(pos) * r.CFrame.Rotation)
		end)
	end
	clown.At = pos
	slog(string.format("Clown planted at %.1f %.1f %.1f", pos.X, pos.Y, pos.Z))
end

local function relayFlow(uid, started, releaseCamera, semiFrozen)
	local function held()
		return state.Carrying and state.Uid == uid
	end
	local function wait(t)
		local w = 0
		while w < t and not state.Cancel do
			w += RunService.Heartbeat:Wait()
		end
	end
	local function flatAway(a, b)
		return Vector3.new(a.X - b.X, 0, a.Z - b.Z).Magnitude
	end
	local safe = Vector3.new(RELAY_SAFE.X, groundY(RELAY_SAFE, RELAY_SAFE.Y), RELAY_SAFE.Z)
	local function finish()
		clown.At = nil
		if semiFrozen and typeof(semi.Home) == "Vector3" and root() and not state.Cancel then
			status("Relay: the clown goes back to the player")
			place(semi.Home)
			wait(0.3)
		end
		releaseCamera()
		if semiFrozen then
			releaseView()
		end
		dropClone()
	end

	local burst
	local function ragdollGuard(around)
		local seen = state.RagdollAt
		if not (state.Ragdoll and seen and os.clock() - seen < 12) then
			return false
		end
		status("Relay: knocked down, staying still")
		slog(string.format("Relay: ragdolled %.2f s after the pickup, holding still, carrying=%s", os.clock() - (state.CarryAt or seen), tostring(held())))
		local release = holdStill()
		local stop = os.clock() + 8
		while state.Ragdoll and os.clock() < stop and not state.Cancel do
			RunService.Heartbeat:Wait()
			local r = root()
			if r then
				pcall(function()
					r.AssemblyLinearVelocity = Vector3.zero
					r.AssemblyAngularVelocity = Vector3.zero
				end)
			end
		end
		release()
		state.Ragdoll = false
		wait(0.15)
		slog(string.format("Relay: ragdoll over after %.2f s, carrying=%s", os.clock() - seen, tostring(held())))
		if not held() and not state.Cancel then
			status("Relay: taking the egg back")
			local got = burst(3, around)
			slog(string.format("Relay: egg taken back after the ragdoll=%s", tostring(got)))
		end
		return true
	end

	local function hopTo(target)
		local r = root()
		if not r then
			return false
		end
		local hopStep = RELAY_STEP
		local cruiseY = target.Y + RELAY_LIFT
		local baseGap = RELAY_GAP_MIN + math.random() * (RELAY_GAP_MAX - RELAY_GAP_MIN)
		local gap = baseGap
		local firstHop = true
		local deadline = os.clock() + 20
		local retries, shrinks = 0, 0
		while os.clock() < deadline and not state.Cancel do
			r = root()
			if not r then
				return false
			end
			local flat = Vector3.new(target.X - r.Position.X, 0, target.Z - r.Position.Z)
			local pulledBefore = state.PulledAt
			local nextPos
			if flat.Magnitude <= hopStep then
				nextPos = target
			else
				local dir = flat.Unit
				local hopY = firstHop and (r.Position.Y + 39) or cruiseY
				nextPos = Vector3.new(r.Position.X + dir.X * hopStep, hopY, r.Position.Z + dir.Z * hopStep)
			end
			local held2 = 0
			if firstHop and state.CarryAt and not state.CarryLogged then
				state.CarryLogged = true
				slog(string.format("Relay: first hop %.2f s after the carry started", os.clock() - state.CarryAt))
			end
			local paceGap = math.min(flat.Magnitude, hopStep) / math.max(walkSpeed() * (tonumber(getgenv().YslemPaceRatio) or RELAY_PACE_RATIO), 200)
			local holdFor = math.max(gap, paceGap)
			while held2 < holdFor and not state.Cancel and not state.Ragdoll do
				place(nextPos)
				held2 += RunService.Heartbeat:Wait()
			end
			if state.Ragdoll then
				ragdollGuard(nil)
				if not held() then
					return false
				end
				deadline = os.clock() + 20
				continue
			end
			local check = root()
			local pulled = state.PulledAt > pulledBefore or (check ~= nil and (check.Position - nextPos).Magnitude > 10)
			if not pulled then
				firstHop = false
				gap = RELAY_GAP_MIN + math.random() * (RELAY_GAP_MAX - RELAY_GAP_MIN)
				if nextPos == target then
					return true
				end
			else
				retries += 1
				gap = math.min(CFG.HopGapMax, gap + 0.02)
				if retries > CFG.HopRetries then
					if shrinks >= 2 then
						return false
					end
					shrinks += 1
					retries = 0
					hopStep = math.max(hopStep * 0.6, CFG.HopMin * 0.5)
				end
			end
		end
		return false
	end

	local firstPick = state.CarryAt
	local function waitWake(pinAt)
		if not firstPick or semi.WakeWait <= 0 then
			return
		end
		local need = semi.WakeWait
		local left = firstPick + need - os.clock()
		if left <= 0 then
			slog(string.format("Relay: %.1f s since the pickup, no wait needed", os.clock() - firstPick))
			return
		end
		status("Relay: letting the pickup delay pass")
		slog(string.format("Relay: holding %.1f s so that %.1f s have passed since the pickup", left, need))
		local stop = os.clock() + left
		while os.clock() < stop and held() and not state.Cancel and not (state.DeliveryFailedAt and state.DeliveryFailedAt > firstPick) do
			local r = root()
			if r and pinAt and (r.Position - pinAt).Magnitude > 2.5 then
				place(pinAt)
			end
			RunService.Heartbeat:Wait()
		end
	end

	burst = function(seconds, around)
		local cache = { At = 0, Pos = around }
		local waited, since = 0, 1
		while not held() and waited < seconds and not state.Cancel do
			if state.Ragdoll and state.RagdollAt and os.clock() - state.RagdollAt < 12 then
				RunService.Heartbeat:Wait()
				continue
			end
			local egg = eggNow(uid, cache) or around
			local r = root()
			local dt = math.max(RunService.Heartbeat:Wait(), 1 / 240)
			waited += dt
			since += dt
			if r and egg then
				place(egg + Vector3.new(0, 3.2, 0))
				pcall(function()
					local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")
					if humanoid then
						humanoid.PlatformStand = false
						humanoid.Jump = true
					end
					r.AssemblyLinearVelocity = Vector3.new(0, 45, 0)
				end)
				if since >= CFG.GrabInterval then
					since = 0
					local prompt = promptNear(egg - Vector3.new(0, 3, 0), 10)
					if prompt and typeof(fireproximityprompt) == "function" then
						pcall(function()
							prompt.HoldDuration = 0
						end)
						pcall(fireproximityprompt, prompt)
					end
					task.spawn(takeEgg, uid)
				end
			end
		end
		return held()
	end

	if not held() then
		status("Relay: confirming the carry")
		local synced = 0
		while not held() and synced < 2.5 and not state.Cancel do
			synced += RunService.Heartbeat:Wait()
		end
		if not held() then
			return false
		end
	end

	local dropAt
	local bank = typeof(semi.Home) == "Vector3" and semi.Home or safe
	do
		local dropX = DODGE_DROP_POINT.X
		local lane = tonumber(getgenv().YslemDodgeLane) or DODGE_LANE_Z
		local cruiseY = tonumber(getgenv().YslemDodgeY) or DODGE_Y
		local dropPos = DODGE_DROP_POINT
		local r0 = root()
		local startX = r0 and r0.Position.X or dropX
		local totalDist = math.abs(startX - dropX)
		slog(string.format("Dodge: %.0f studs from x=%.0f to the drop x=%.1f on lane z=%.1f y=%.0f, %.2f s after the pickup", totalDist, startX, dropX, lane, cruiseY, firstPick and (os.clock() - firstPick) or -1))
		status("Dodge: running the chain")
		progress(0.5, "Carrying the egg")
		local dir = startX > dropX and -1 or 1
		local travelled = 0
		local pulls = 0
		local chainStart = os.clock()
		local firstFrame = true
		local chainOk = true
		while travelled < totalDist and not state.Cancel do
			local dt = firstFrame and 0 or math.min(RunService.Heartbeat:Wait(), 0.1)
			if state.Ragdoll then
				ragdollGuard(nil)
				if not held() then
					chainOk = false
					break
				end
				local rr = root()
				if rr then
					travelled = math.clamp((rr.Position.X - startX) * dir, 0, totalDist)
				end
				continue
			end
			if not held() then
				chainOk = false
				break
			end
			local speed = travelled < DODGE_BURST_STUDS and DODGE_BURST_SPEED or DODGE_CRUISE_SPEED
			local pulledBefore = state.PulledAt
			travelled = math.min(travelled + speed * dt, totalDist)
			local slowLen = DODGE_DESCENT_STUDS
			local yNow = cruiseY
			if slowLen > 0 and totalDist - travelled < slowLen then
				yNow = cruiseY + (dropPos.Y - cruiseY) * (1 - (totalDist - travelled) / slowLen)
			end
			local frac = slowLen > 0 and totalDist - travelled < slowLen and (1 - (totalDist - travelled) / slowLen) or 0
			place(Vector3.new(startX + dir * travelled, yNow, lane + (dropPos.Z - lane) * frac))
			if firstFrame then
				firstFrame = false
				if firstPick and not state.CarryLogged then
					state.CarryLogged = true
					slog(string.format("Dodge: first write %.2f s after the carry started", os.clock() - firstPick))
				end
			end
			if state.PulledAt > pulledBefore then
				pulls += 1
				slog(string.format("Dodge: the server pulled us back at %.0f studs (%d)", travelled, pulls))
				if pulls > 3 then
					chainOk = false
					break
				end
			end
		end
		slog(string.format("Dodge: chain done=%s in %.2f s", tostring(chainOk and travelled >= totalDist), os.clock() - chainStart))
		if not chainOk or state.Cancel or not held() then
			status("Dodge: the chain was interrupted")
			finish()
			return false
		end
		status("Dodge: at the drop spot")
		progress(0.65, "At the drop spot")
		local holdEnd = os.clock() + DODGE_DROP_WAIT
		local minDrop = tonumber(getgenv().YslemDodgeMinDrop) or DODGE_MIN_DROP
		if firstPick then
			holdEnd = math.max(holdEnd, firstPick + minDrop)
		end
		slog(string.format("Dodge: at the drop spot %.2f s after the pickup, holding until %.2f s", os.clock() - (firstPick or os.clock()), holdEnd - (firstPick or os.clock())))
		while os.clock() < holdEnd and not state.Cancel and held() do
			place(dropPos)
			RunService.Heartbeat:Wait()
		end
		local released = false
		for attempt = 1, 4 do
			if not held() or state.Cancel then
				break
			end
			local rr = root()
			if rr and (rr.Position - dropPos).Magnitude > 1 then
				place(dropPos)
			end
			local settleUntil = os.clock() + (attempt == 1 and 0 or math.max(0.15, 2 * netPing()))
			while os.clock() < settleUntil and not state.Cancel and held() do
				place(dropPos)
				RunService.Heartbeat:Wait()
			end
			if not held() then
				break
			end
			slog(string.format("Dodge: drop button (try %d) %.2f s after the pickup, RunBackWakeDelayRequired=%s", attempt, os.clock() - (firstPick or os.clock()), tostring(state.WakeReq)))
			dropEgg()
			local dropUntil = os.clock() + 0.3
			while held() and os.clock() < dropUntil and not state.Cancel do
				place(dropPos)
				RunService.Heartbeat:Wait()
			end
			if not held() then
				break
			end
		end
		released = not held()
		if not released then
			slog("Dodge: the drop did not go through")
			status("Dodge: the drop did not go through")
			finish()
			return false
		end
		local droppedAt = os.clock()
		dropAt = nil
		local polled = 0
		while polled < 3 and not state.Cancel do
			dropAt = eggNow(uid, { At = 0 })
			if dropAt then
				break
			end
			place(dropPos)
			wait(0.1)
			polled += 0.1
		end
		if dropAt and (dropAt - dropPos).Magnitude > 1500 then
			state.NestBack = true
			slog(string.format("the egg went back to its nest %.2f s after the pickup", os.clock() - (firstPick or os.clock())))
			finish()
			status("The egg went back to its nest")
			return false
		end
		slog(string.format("Dodge: egg seen after the drop at %s, %.0f studs from the drop spot", dropAt and string.format("%.1f %.1f %.1f", dropAt.X, dropAt.Y, dropAt.Z) or "nowhere", dropAt and (dropAt - dropPos).Magnitude or -1))
		plantClown(dropPos)
		progress(0.75, "Egg dropped")
		status("Dodge: treadmill before the regrab")
		local okTread = treadmillReset()
		slog(string.format("Dodge: treadmill before the regrab done=%s, %.2f s after the drop", tostring(okTread), os.clock() - droppedAt))
		local back = clown.At or dropPos
		slog(string.format("Dodge: re-teleport to the clown at %.1f %.1f %.1f", back.X, back.Y, back.Z))
		place(back)
		local regrabEnd = droppedAt + DODGE_REGRAB_WAIT
		while os.clock() < regrabEnd and not state.Cancel do
			place(back)
			RunService.Heartbeat:Wait()
		end
		progress(0.85, "Taking the egg back")
		status("Dodge: taking the egg back")
		dropAt = eggNow(uid, { At = 0 }) or dropAt
		if dropAt then
			place(dropAt + Vector3.new(0, 3.2, 0))
		end
		local got = burst(1.5, dropAt or back)
		slog(string.format("Dodge: taken back=%s %.2f s after the drop, RunBackWakeDelayRequired=%s", tostring(got), os.clock() - droppedAt, tostring(state.WakeReq)))
		if not got and not state.Cancel then
			local again = eggNow(uid, { At = 0 }) or dropAt
			if again then
				place(again + Vector3.new(0, 3.2, 0))
			end
			got = burst(2.5, again or dropAt or back)
		end
		if not got and not state.Cancel then
			place(back)
			wait(0.2)
			local last = eggNow(uid, { At = 0 }) or dropAt or back
			got = burst(3, last)
		end
		if not got then
			slog("Dodge: could not take the egg back")
			status("Could not take the egg back")
			finish()
			return false
		end
		progress(0.93, "Bringing it home")
		status("Dodge: running to the clown's spot")
		slog(string.format("Dodge: running to the clown's spot %.1f %.1f %.1f, %.2f s after the pickup", bank.X, bank.Y, bank.Z, os.clock() - (firstPick or os.clock())))
		do
			local hum = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")
			if hum then
				hum.PlatformStand = false
			end
			local runEnd = os.clock() + 25
			local lastRun = os.clock()
			while not state.Cancel and state.Delivered < started and os.clock() < runEnd and held() do
				local rr = root()
				if not rr then
					break
				end
				if state.Ragdoll then
					ragdollGuard(nil)
					continue
				end
				local nowRun = os.clock()
				local dtRun = math.min(nowRun - lastRun, 0.1)
				lastRun = nowRun
				local toBank = Vector3.new(bank.X - rr.Position.X, 0, bank.Z - rr.Position.Z)
				if toBank.Magnitude < 2 then
					break
				end
				local aim = avoid(rr.Position, bank)
				local flat = Vector3.new(aim.X - rr.Position.X, 0, aim.Z - rr.Position.Z)
				local stepLen = math.min(DODGE_CRUISE_SPEED * dtRun, toBank.Magnitude)
				local dir2 = flat.Magnitude > 0.01 and flat.Unit or toBank.Unit
				place(Vector3.new(rr.Position.X + dir2.X * stepLen, bank.Y, rr.Position.Z + dir2.Z * stepLen))
				RunService.Heartbeat:Wait()
			end
			pcall(function()
				local rr = root()
				if rr then
					rr.AssemblyLinearVelocity = Vector3.zero
				end
			end)
		end
		local verdictBy = os.clock() + 4
		while not state.Cancel and state.Delivered < started and os.clock() < verdictBy do
			RunService.Heartbeat:Wait()
		end
		slog(string.format("Dodge: verdict=%s %.2f s after the pickup", tostring(state.Delivered >= started), os.clock() - (firstPick or os.clock())))
	end
	status("Relay: waiting for the deposit")
	local depositBy = os.clock() + 8
	while not state.Cancel and state.Delivered < started and os.clock() < depositBy do
		if state.Ragdoll then
			ragdollGuard(nil)
			depositBy = os.clock() + 8
		end
		wait(0.1)
	end
	slog(string.format("Relay: banked=%s", tostring(state.Delivered >= started)))
	if state.Delivered < started and firstPick and state.DeliveryFailedAt and state.DeliveryFailedAt > firstPick then
		semi.WakeWait = math.min(15, semi.WakeWait + 2.5)
		slog(string.format("Relay: the server refused the delivery %.1f s after the pickup, next try waits %.1f s", state.DeliveryFailedAt - firstPick, semi.WakeWait))
	end
	if state.Delivered < started and held() and not state.Cancel then
		local lineX, _, _ = lineInfo()
		local r = root()
		local laneZ = r and math.clamp(r.Position.Z, -425, -300) or -364
		slog("Relay: no deposit from the safe zone, running home")
		local wasSlow = semi.SlowRun
		semi.SlowRun = true
		local okHome = runHome(lineX, laneZ)
		semi.SlowRun = wasSlow
		finish()
		return okHome
	end
	finish()
	return state.Delivered >= started
end

local function instantTP(uid)
	local started = os.clock()
	local lineX, lineY = lineInfo()
	local r = root()
	if not r then
		return false
	end
	local laneZ = math.clamp(r.Position.Z, -425, -300)
	local hopZ = math.clamp(r.Position.Z, -425, -300)
	local semiFrozen = viewState ~= nil
	local landing = Vector3.new(lineX + CFG.LandOffset, lineY + 3.35, laneZ)
	local semiOnly = semiFrozen and semi.Kind ~= "decoy" and not semi.Plain
	local semiEnd = (semiFrozen and not semi.Plain) or semi.SlowRun == true

	-- hops towards the line; a pull-back repeats the same hop with a longer pause (the pause is learned)
	local hopStep = math.max(walkSpeed() * CFG.HopRatio * (semiOnly and 0.85 or 1), CFG.HopMin)
	local hopY = r.Position.Y + CFG.HopLift
	local x = r.Position.X
	local retries = 0
	local shrinks = 0
	local releaseCamera = semiFrozen and function() end or frozenCamera()
	state.ReleaseCamera = releaseCamera
	if not semiFrozen then
		pcall(postClone)
	end
	if not semi.Dodge then
		fpsOn()
	end
	if semiFrozen or method == "Relay" then
		local okRelay = relayFlow(uid, started, releaseCamera, semiFrozen)
		fpsOff()
		return okRelay
	end

	while x - hopStep > landing.X and not state.Cancel do
		if not state.Carrying then
			-- the server let go of the egg on the way: take it back right away
			if not regrab(uid) then
				break
			end
			local current = root()
			if current then
				x = math.min(x, current.Position.X)
			end
			continue
		end

		local nextX = x - hopStep
		status(string.format("Instant TP: hopping home, X %d", math.floor(nextX)))
		local pulledBefore = state.PulledAt
		local held = 0
		while held < CFG.HopGap do
			place(Vector3.new(nextX, hopY, hopZ))
			held += RunService.Heartbeat:Wait()
		end

		local check = root()
		local pulled = state.PulledAt > pulledBefore or (check ~= nil and (check.Position.X - nextX > 10 or check.AssemblyLinearVelocity.Magnitude > 150))
		if pulled and state.Carrying and not state.Cancel then
			retries += 1
			CFG.HopGap = math.min(CFG.HopGapMax, CFG.HopGap + 0.02)
			if retries > CFG.HopRetries then
				if shrinks >= 2 then
					break
				end
				shrinks += 1
				retries = 0
				hopStep = math.max(hopStep * 0.6, CFG.HopMin * 0.5)
				CFG.HopGap = CFG.HopGapMax
				status(string.format("Instant TP: pulled back too often, shorter hops (%d/2)", shrinks))
			end
			status(string.format("Instant TP: pulled back, retry %d/%d", retries, CFG.HopRetries))
			local settle = 0
			while settle < 0.12 and not state.Cancel do
				place(Vector3.new(x, hopY, hopZ))
				settle += RunService.Heartbeat:Wait()
			end
		else
			x = nextX
			CFG.HopGap = math.max(CFG.HopGapMin, CFG.HopGap - 0.01)
		end
	end

	-- landing in front of the line
	status("Instant TP: landing next to the line")
	landing = Vector3.new(landing.X, groundY(landing, landing.Y), landing.Z)
	local function onSpot()
		local current = root()
		return current ~= nil and current.Position.X <= landing.X + 12 and math.abs(current.Position.Y - landing.Y) <= 10
	end
	local function land()
		local current = root()
		-- never jump backwards: if we are already on the landing spot, stay
		if current and current.Position.X <= landing.X + 1 and math.abs(current.Position.Y - landing.Y) <= 10 then
			pcall(function()
				current.AssemblyLinearVelocity = Vector3.zero
			end)
			return
		end
		place(landing)
	end
	land()
	for attempt = 1, 5 do
		local settle = 0
		while settle < CFG.LandSettle and not state.Cancel do
			settle += RunService.Heartbeat:Wait()
		end
		if state.Carrying and not onSpot() then
			status("Instant TP: landing retry " .. attempt)
			land()
		else
			break
		end
	end
	dropClone()

	-- drop at the line (only when we really stand on the spot, and only once the server confirmed it), take it back
	if state.Carrying and not state.Cancel then
		local delay = 0
		while delay < CFG.DropDelay do
			delay += RunService.Heartbeat:Wait()
		end
		if state.Carrying and not state.Cancel and not onSpot() then
			land()
			local settle = 0
			while settle < CFG.LandSettle and not state.Cancel do
				settle += RunService.Heartbeat:Wait()
			end
		end
		if not state.Carrying or state.Cancel then
			-- nothing to drop
		elseif not onSpot() then
			status("Instant TP: not on the drop spot, going home with the egg")
		else
			status("Instant TP: dropping the egg")
			if semiFrozen then
				local at = root()
				if at then
					slog(string.format("Instant TP: the clown drops the egg at x=%.0f z=%.0f (line %+.0f)", at.Position.X, at.Position.Z, at.Position.X - lineX))
				end
			end
			for _ = 1, 3 do
				dropEgg()
				local waited = 0
				while state.Carrying and waited < 0.8 and not state.Cancel do
					waited += RunService.Heartbeat:Wait()
				end
				if not state.Carrying or state.Cancel then
					break
				end
				status("Instant TP: the drop was not confirmed, trying again")
				if not onSpot() then
					land()
				end
			end
			local current = root()
			if current then
				pcall(function()
					current.AssemblyLinearVelocity = Vector3.zero
					current.AssemblyAngularVelocity = Vector3.zero
				end)
			end
			-- the server may send a dropped egg straight back to its nest: then there is nothing to take back, and no long teleport to chase it
			local dropSpot = root()
			if dropSpot and not state.Cancel then
				local looked = 0
				while looked < 0.25 and not state.Cancel do
					looked += RunService.Heartbeat:Wait()
				end
				local lies = eggNow(uid, { At = 0 })
				if lies then
					local away = (lies - dropSpot.Position).Magnitude
					slog(string.format("timeline: the egg lies %.0f studs from the drop spot %.2f s after the drop", away, looked))
					if away > 120 then
						state.NestBack = true
						slog("the egg went back to its nest after the drop")
						releaseCamera()
						if semiFrozen then
							releaseView()
						end
						dropClone()
						fpsOff()
						status("The egg went back to its nest")
						return false
					end
				end
			end
			-- egg is down: let go of the camera and the copy, then take it back
			releaseCamera()
			if semiFrozen and semi.AtDrop == true then
				releaseView()
			end
			dropClone()
			status("Instant TP: taking the egg back")
			local tookBack = grab(uid, 3) or regrab(uid)
			for _ = 1, 3 do
				if tookBack or state.Cancel then
					break
				end
				status("Instant TP: the egg is not in the hands yet, trying again")
				tookBack = regrab(uid) or grab(uid, 2)
			end
			if not tookBack then
				fpsOff()
				status("Could not take the egg back")
				return false
			end
			dropClone()
		end
	end
	releaseCamera()

	-- safe zone: Semi TP ends with teleports (never a run unless both fail), the rest keeps the run
	local ok = false
	local function goHome()
		if semiEnd then
			for round = 1, 2 do
				if tpHome(lineX, laneZ, started) then
					return true
				end
				if not state.Carrying or state.Cancel then
					return state.Delivered >= started
				end
				status(string.format("Instant TP: teleport home again (%d/2)", round))
			end
		end
		return runHome(lineX, laneZ)
	end
	if state.Carrying then
		ok = goHome()
	end
	local again = 0
	while not ok and state.Delivered < started and not state.Cancel and again < 2 do
		again += 1
		status(string.format("Instant TP: not delivered yet, going home again (%d/2)", again))
		if not state.Carrying and not regrab(uid) then
			break
		end
		local current = root()
		if current and current.Position.X > lineX + 8 then
			place(Vector3.new(lineX + 8, math.max(current.Position.Y, lineY + 3.35), current.Position.Z))
			RunService.Heartbeat:Wait()
		end
		ok = goHome()
	end
	fpsOff()
	return ok or state.Delivered >= started
end

-- after a failed Semi TP: the body goes back to the front of the base by itself (hops like the delivery)
local function returnFront()
	local reached = false
	pcall(function()
		local waited = 0
		while root() and root().Position.Y > 5000 and waited < 8 and not state.Cancel do
			waited += RunService.Heartbeat:Wait()
		end
		local r = root()
		if not r or state.Cancel then
			return
		end
		local character = localPlayer.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.PlatformStand = false
		end
		local lineX = lineInfo()
		local home = homePoint()
		local hopZ = math.clamp(r.Position.Z, -425, -300)
		local frontX = lineX - 7
		local hopStep = math.max(walkSpeed() * CFG.HopRatio * 0.85, CFG.HopMin)
		local hopY = r.Position.Y + CFG.HopLift
		local x = r.Position.X
		local gap = CFG.HopGap
		local retries, shrinks = 0, 0
		status("Going back to the front")
		while x - frontX > hopStep and not state.Cancel do
			local nextX = x - hopStep
			local pulledBefore = state.PulledAt
			local held = 0
			while held < gap and not state.Cancel do
				place(Vector3.new(nextX, hopY, hopZ))
				held += RunService.Heartbeat:Wait()
			end
			local check = root()
			local pulled = state.PulledAt > pulledBefore or (check ~= nil and check.Position.X - nextX > 10)
			if pulled then
				retries += 1
				gap = math.min(CFG.HopGapMax, gap + 0.02)
				if retries > CFG.HopRetries then
					if shrinks >= 2 then
						break
					end
					shrinks += 1
					retries = 0
					hopStep = math.max(hopStep * 0.6, CFG.HopMin * 0.5)
				end
				local settle = 0
				while settle < 0.12 and not state.Cancel do
					place(Vector3.new(x, hopY, hopZ))
					settle += RunService.Heartbeat:Wait()
				end
			else
				x = nextX
			end
		end
		if state.Cancel then
			return
		end
		for _, target in ipairs({ Vector3.new(frontX, home.Y, hopZ), home }) do
			local held = 0
			while held < math.max(gap, 0.1) and not state.Cancel do
				place(target)
				held += RunService.Heartbeat:Wait()
			end
		end
		local settle = 0
		while settle < 0.4 and not state.Cancel do
			settle += RunService.Heartbeat:Wait()
		end
		local at = root()
		reached = at ~= nil and Vector3.new(at.Position.X - home.X, 0, at.Position.Z - home.Z).Magnitude <= 20
	end)
	return reached
end

------------------------------------------------------------------ Semi TP: portal by touch (the only route, no alternative)
-- Returns true plus { Arrived, Ratio, Decoy } or false plus the reason. The player stays frozen (copy + camera) while the body works.
local function semiGo(uid, egg)
	local startRoot = root()
	if not startRoot then
		return false, "Semi TP: no character yet"
	end
	local character = localPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local startCF = startRoot.CFrame
	local cache = { At = 0, Pos = egg }
	local function eggPos()
		return eggNow(uid, cache) or egg
	end
	local function eggPart()
		local node = workspace:FindFirstChild(uid)
		local slots = workspace:FindFirstChild("AreaEggSlotsClient")
		node = node or (slots and slots:FindFirstChild(uid))
		if not node then
			return nil
		end
		if node:IsA("BasePart") then
			return node
		end
		return node:FindFirstChild("Hitbox", true) or node:FindFirstChildWhichIsA("BasePart", true)
	end

	local camera = workspace.CurrentCamera
	local camOffset = camera and (camera.CFrame.Position - startRoot.Position) or Vector3.new(0, 8, 14)
	local camRot = camera and camera.CFrame.Rotation or CFrame.new()

	semi.Kind, semi.AtDrop, semi.Home, semi.Plain = nil, false, nil, false
	slog(string.format("Semi TP from %.0f,%.0f,%.0f to the egg %.0f,%.0f,%.0f", startRoot.Position.X, startRoot.Position.Y, startRoot.Position.Z, egg.X, egg.Y, egg.Z))

	if Vector3.new(egg.X - startRoot.Position.X, 0, egg.Z - startRoot.Position.Z).Magnitude <= 60 then
		-- egg next to us: no portal. The copy waits at home, the body runs to the egg and brings it back.
		semi.Kind = "decoy"
		semi.AtDrop = true
		local spotAt = startRoot.Position
		local okFreeze = freezeView(character, Vector3.zero, nil)
		semi.Home = okFreeze and spotAt or nil
		slog("egg close: decoy at home, frozen=" .. tostring(okFreeze))
		return true, { Decoy = true }
	end

	semi.Kind = "semi"
	semi.AtDrop = true
	for _ = 1, 3 do
		RunService.Heartbeat:Wait()
	end
	local shieldSince = os.clock()
	while not swapped() and os.clock() - shieldSince < 5 and not state.Cancel do
		pcall(function()
			local r0 = root()
			if r0 then
				r0.AssemblyLinearVelocity = Vector3.zero
			end
			if humanoid then
				humanoid:Move(Vector3.zero, false)
			end
		end)
		RunService.Heartbeat:Wait()
	end
	slog(string.format("shield=%s after %.2f s", tostring(swapped()), os.clock() - shieldSince))
	local safeStand = Vector3.new(RELAY_SAFE.X, groundY(RELAY_SAFE, RELAY_SAFE.Y), RELAY_SAFE.Z)
	local atNow = root()
	local lineNow = lineInfo()
	local needMove = atNow and Vector3.new(atNow.Position.X - safeStand.X, 0, atNow.Position.Z - safeStand.Z).Magnitude > 3
	if needMove then
		if atNow.Position.X > lineNow + 100 then
			status("Semi TP: hopping back to the base first")
			returnFront()
			if state.Cancel then
				return false, "cancelled"
			end
		end
		status("Semi TP: going to the safe-zone point")
		place(safeStand)
		for _ = 1, 8 do
			RunService.Heartbeat:Wait()
		end
		pcall(function()
			local r1 = root()
			if r1 then
				r1.AssemblyLinearVelocity = Vector3.zero
				r1.AssemblyAngularVelocity = Vector3.zero
			end
		end)
	end
	local freezeAt = root()
	local freezeSpot = freezeAt and freezeAt.Position or safeStand
	local function freezeNow()
		return freezeView(character, Vector3.zero, CFrame.new(freezeSpot + camOffset) * camRot)
	end
	local okFreeze = freezeNow()
	if not okFreeze then
		releaseView()
		okFreeze = freezeNow()
	end
	semi.Home = okFreeze and freezeSpot or nil
	slog("player frozen at the safe-zone point = " .. tostring(okFreeze))
	for _ = 1, 6 do
		RunService.Heartbeat:Wait()
	end
	pcall(function()
		local hum = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")
		if hum then
			semi.Rotate = { Hum = hum, Old = hum.AutoRotate }
			hum.AutoRotate = false
		end
	end)

	local stableRot = startRoot.CFrame.Rotation
	pcall(function()
		local flat = Vector3.new(egg.X - startRoot.Position.X, 0, egg.Z - startRoot.Position.Z)
		if flat.Magnitude > 1 then
			stableRot = CFrame.lookAt(Vector3.zero, flat).Rotation
		end
	end)
	local function placeAt(p)
		local r = root()
		if r then
			pcall(function()
				r.CFrame = CFrame.new(p) * stableRot
				r.AssemblyLinearVelocity = Vector3.zero
				r.AssemblyAngularVelocity = Vector3.zero
			end)
		end
	end
	local function inBiome()
		local r = root()
		return r ~= nil and r.Position.Y > 5000
	end
	local function jumpNow()
		local hum = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")
		if hum then
			pcall(function()
				hum.Jump = true
				hum:ChangeState(Enum.HumanoidStateType.Jumping)
			end)
		end
	end
	local function holdPause(t)
		local w = 0
		while w < t and not state.Cancel do
			w += RunService.Heartbeat:Wait()
		end
	end

	local groundSkip, groundSkipAt = nil, 0
	local function groundAt(pos, from)
		local found = nil
		pcall(function()
			if not groundSkip or os.clock() - groundSkipAt > 1 then
				groundSkip = { stealClone }
				groundSkipAt = os.clock()
				local slots = workspace:FindFirstChild("AreaEggSlotsClient")
				if slots then
					groundSkip[#groundSkip + 1] = slots
				end
				for _, child in ipairs(workspace:GetChildren()) do
					if child:IsA("Model") and #child.Name == 32 and child:FindFirstChild("Hitbox") then
						groundSkip[#groundSkip + 1] = child
					end
				end
			end
			local list = { localPlayer.Character }
			for _, v in ipairs(groundSkip) do
				list[#list + 1] = v
			end
			local params = RaycastParams.new()
			params.FilterType = Enum.RaycastFilterType.Exclude
			params.FilterDescendantsInstances = list
			params.IgnoreWater = true
			pcall(function()
				params.RespectCanCollide = true
			end)
			local origin = Vector3.new(pos.X, from, pos.Z)
			for _ = 1, 4 do
				local hit = workspace:Raycast(origin, Vector3.new(0, -400, 0), params)
				if not hit then
					break
				end
				if hit.Material ~= Enum.Material.Water and hit.Instance.CanCollide and hit.Instance.Transparency < 0.95 then
					found = hit.Position
					break
				end
				origin = hit.Position - Vector3.new(0, 0.05, 0)
			end
		end)
		return found
	end
	local function standHeight()
		local h = 3
		pcall(function()
			local character2 = localPlayer.Character
			local r = root()
			local hum = character2 and character2:FindFirstChildOfClass("Humanoid")
			if character2 and r then
				local box, boxSize = character2:GetBoundingBox()
				local value = r.Position.Y - (box.Position.Y - boxSize.Y / 2)
				if value > 1 and value < 12 then
					h = value
				end
				if hum and hum.HipHeight > 0.2 then
					local exact = hum.HipHeight + r.Size.Y / 2
					if exact > 1 and exact < 12 then
						h = exact
					end
				end
			end
		end)
		return h + 0.05
	end
	local approachDir = nil
	pcall(function()
		local flat = Vector3.new(startRoot.Position.X - egg.X, 0, startRoot.Position.Z - egg.Z)
		if flat.Magnitude > 1 then
			approachDir = flat.Unit
		end
	end)
	local function landFor(at, high)
		local dir = approachDir or Vector3.new(-1, 0, 0)
		local stand = 2.5
		pcall(function()
			local part = eggPart()
			if part and part.CanCollide then
				stand = math.clamp(math.sqrt(part.Size.X ^ 2 + part.Size.Z ^ 2) / 2 + 2.2, 2.5, 7)
			end
		end)
		local base = Vector3.new(at.X + dir.X * stand, at.Y + 3, at.Z + dir.Z * stand)
		if high then
			local top = groundAt(base, at.Y + 160)
			if top and math.abs(top.Y - at.Y) < 150 then
				return Vector3.new(base.X, top.Y + standHeight(), base.Z)
			end
			return nil
		end
		local hit = groundAt(base, at.Y + 6)
		if hit and math.abs(hit.Y - at.Y) < 12 then
			return Vector3.new(base.X, hit.Y + standHeight(), base.Z)
		end
		hit = groundAt(base, at.Y + 40)
		if hit and math.abs(hit.Y - at.Y) < 40 then
			return Vector3.new(base.X, hit.Y + standHeight(), base.Z)
		end
		return base
	end
	semi.LandFor = landFor

	-- the biome has no usable exit by itself: wait for the game's automatic return, then look for an exit, then step back
	local function zoneRoots()
		local out = {}
		local base = workspace:FindFirstChild("World") or workspace:FindFirstChild("__OBJECTS")
		base = base and base:FindFirstChild("Build")
		for _, name in ipairs({ "FuseBiomeZone", "EnchantedTreeInterior" }) do
			local node = base and base:FindFirstChild(name)
			if node then
				out[#out + 1] = node
			end
		end
		return out
	end
	local function zoneExits()
		local list, all = {}, {}
		for _, zone in ipairs(zoneRoots()) do
			for _, d in ipairs(zone:GetDescendants()) do
				all[#all + 1] = d
			end
		end
		local good = { "exit", "leave", "return", "back", "home", "portal", "gate", "door", "out", "teleport", "warp", "spawn", "lobby", "world", "main" }
		local bad = { "fusion", "shrine", "pad", "place", "sell", "buy", "shop", "lion", "whale" }
		local function score(inst, extra)
			local label = string.lower(inst.Name .. " " .. (inst.Parent and inst.Parent.Name or "") .. " " .. (extra or ""))
			for _, w in ipairs(bad) do
				if string.find(label, w, 1, true) then
					return 0
				end
			end
			for _, w in ipairs(good) do
				if string.find(label, w, 1, true) then
					return 1
				end
			end
			return 0
		end
		pcall(function()
			for _, d in ipairs(all) do
				if d:IsA("ProximityPrompt") and score(d, d.ActionText .. " " .. d.ObjectText) > 0 then
					list[#list + 1] = d
				elseif d:IsA("BasePart") and d.Size.Magnitude < 250 and score(d) > 0 then
					list[#list + 1] = d
				end
				if #list >= 16 then
					break
				end
			end
		end)
		return list
	end
	local function leaveByExits()
		local list = zoneExits()
		local function posOf(c)
			if c:IsA("ProximityPrompt") then
				local part = c.Parent
				local reach = math.max(3, math.min(c.MaxActivationDistance - 1.5, 8))
				if part and part:IsA("BasePart") then
					return part.Position, reach
				end
				if part and part:IsA("Attachment") then
					return part.WorldPosition, reach
				end
				return nil, 0
			end
			return c.Position, 1.5
		end
		local tried = {}
		local deadline = os.clock() + 16
		while os.clock() < deadline and not state.Cancel do
			if not inBiome() then
				return true
			end
			local r0 = root()
			if not r0 then
				break
			end
			local best, bestD, bestReach, bestPos
			for _, c in ipairs(list) do
				if not tried[c] and c.Parent then
					local tp, rc = posOf(c)
					if tp then
						local d = (tp - r0.Position).Magnitude
						if semi.ExitPath and c:GetFullName() == semi.ExitPath then
							d = d - 1e6
						end
						if not bestD or d < bestD then
							best, bestD, bestReach, bestPos = c, d, rc, tp
						end
					end
				end
			end
			if not best then
				break
			end
			tried[best] = true
			slog("walking to " .. best.Name)
			bestD = math.max(bestD, 0)
			local speed = math.max(walkSpeed() * 1.1, walkSpeed() * 1.8, 22)
			local legEnd = os.clock() + math.min(bestD / speed + 1.5, 7)
			local lastJump = 0
			while os.clock() < legEnd and os.clock() < deadline and not state.Cancel do
				if not inBiome() then
					pcall(function()
						semi.ExitPath = best:GetFullName()
					end)
					slog("out through " .. best.Name)
					return true
				end
				local r = root()
				local hum = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")
				if not r or not hum then
					break
				end
				local flat = Vector3.new(bestPos.X - r.Position.X, 0, bestPos.Z - r.Position.Z)
				local dist = (r.Position - bestPos).Magnitude
				if best:IsA("ProximityPrompt") and dist <= bestReach + 1 then
					if typeof(fireproximityprompt) == "function" then
						pcall(fireproximityprompt, best)
					end
					local w = 0
					while w < 1.2 and inBiome() and not state.Cancel do
						w += RunService.Heartbeat:Wait()
					end
					break
				end
				pcall(function()
					hum:MoveTo(bestPos)
					if flat.Magnitude > 2 then
						local dir = flat.Unit
						r.AssemblyLinearVelocity = Vector3.new(dir.X * speed, r.AssemblyLinearVelocity.Y, dir.Z * speed)
					end
				end)
				if os.clock() - lastJump > 0.7 and (dist < 14 or (r.AssemblyLinearVelocity * Vector3.new(1, 0, 1)).Magnitude < 1) then
					lastJump = os.clock()
					jumpNow()
				end
				RunService.Heartbeat:Wait()
			end
		end
		return not inBiome()
	end
	local function walkOut()
		status("Semi TP: waiting for the return")
		local t0 = os.clock()
		while inBiome() and os.clock() - t0 < 5.5 and not state.Cancel do
			RunService.Heartbeat:Wait()
		end
		if not inBiome() then
			return true
		end
		leaveByExits()
		if not inBiome() then
			return true
		end
		local arrival = root() and root().Position or nil
		local backDirs = {}
		do
			local r = root()
			if r then
				local look = r.CFrame.LookVector
				local flat = Vector3.new(look.X, 0, look.Z)
				if flat.Magnitude > 0.1 then
					backDirs[#backDirs + 1] = -flat.Unit
					backDirs[#backDirs + 1] = flat.Unit
				end
			end
			backDirs[#backDirs + 1] = Vector3.new(-1, 0, 0)
		end
		local stepsDone = 0
		for _, dir in ipairs(backDirs) do
			for _ = 1, 2 do
				if not inBiome() or state.Cancel then
					break
				end
				local r = root()
				if r and arrival then
					local origin = r.Position
					local moveEnd = os.clock() + 0.45
					while inBiome() and os.clock() < moveEnd and not state.Cancel do
						pcall(function()
							r.AssemblyLinearVelocity = Vector3.new(dir.X * 110, 0, dir.Z * 110)
						end)
						RunService.Heartbeat:Wait()
						if (r.Position - origin).Magnitude >= 30 or r.Position.Y < arrival.Y - 6 then
							break
						end
					end
					pcall(function()
						r.AssemblyLinearVelocity = Vector3.zero
					end)
				end
				stepsDone += 1
				task.wait(0.15)
			end
			if not inBiome() then
				break
			end
			if arrival and root() then
				placeAt(arrival)
			end
		end
		slog("went back " .. stepsDone .. " times, inBiome=" .. tostring(inBiome()))
		local t1 = os.clock()
		while inBiome() and os.clock() - t1 < 8 and not state.Cancel do
			RunService.Heartbeat:Wait()
		end
		return not inBiome()
	end

	local touchWon = nil
	do
		status("Dodge: jump to the egg")
		touchWon = semi.DodgeRoute({ Uid = uid, EggPos = eggPos, LandFor = landFor, Grab = grab })
		slog("Dodge route: " .. tostring(touchWon))
		if not touchWon then
			releaseView()
			local r = root()
			if r then
				pcall(function()
					r.CFrame = startCF
					r.AssemblyLinearVelocity = Vector3.zero
					r.AssemblyAngularVelocity = Vector3.zero
				end)
			end
			task.wait(0.2)
			return false, "Dodge: the jump to the egg was not accepted"
		end
		semi.Plain = true
		return true, { Arrived = true, Plain = true }
	end
	return true, { Plain = true }
end

local worldResetTime, lastResetCheck = 0, 0
task.spawn(function()
	while alive do
		task.wait(1)
		if state.Busy then
			local now = os.clock()
			if now - lastResetCheck >= 1 then
				lastResetCheck = now
				local okClock, clock = pcall(function()
					return game:GetService("Lighting").ClockTime
				end)
				local wt = okClock and tonumber(clock) or 0
				if wt < 0.5 and worldResetTime > 0 and os.clock() - worldResetTime > 60 then
					worldResetTime = 0
					state.Cancel = true
					status("World reset detected")
				elseif wt >= 0.5 then
					worldResetTime = now
				end
			end
		end
	end
end)

------------------------------------------------------------------ H-Claim: frozen at HCLAIM, the clown fetches the egg through the Halloween portal
local HCLAIM = Vector3.new(-5819.16, -199.64, -7387.18)
local ALTV = Vector3.new(-5806.25, -203.38, -7196.68)

-- the attribute can stay true after a teleport out: the body must also really be in the dimension
local DIM_CENTER = Vector3.new(-5800, -200, -6200)
local function inDimension()
	if localPlayer:GetAttribute("InHalloweenDimension") ~= true then
		return false
	end
	local r = root()
	return r == nil or (r.Position - DIM_CENTER).Magnitude < 4000
end





local function stopMotion()
	local r = root()
	if r then
		pcall(function()
			r.AssemblyLinearVelocity = Vector3.zero
			r.AssemblyAngularVelocity = Vector3.zero
		end)
	end
	local character = localPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		pcall(function()
			humanoid.PlatformStand = false
			humanoid:Move(Vector3.zero, false)
		end)
	end
end



-- through a portal: the thinnest axis of the part is the way through, from the side we are on, then from the other side
local hopTo



-- a real teleport: ONE position write onto the target (held 0.15 s), checked (no Relocate, within 8 studs); a rewind repeats the same
-- teleport at once, several times; only after that do the chains of hops / steps take over
local function tpTo(target, tries)
	local waited = os.clock()
	while not swapped() and os.clock() - waited < 5 and not state.Cancel do
		RunService.Heartbeat:Wait()
	end
	local character = localPlayer.Character
	for attempt = 1, tries or 6 do
		local r = root()
		if state.Cancel or not r or localPlayer.Character ~= character then
			return false
		end
		if (r.Position - target).Magnitude <= 4 then
			stopMotion()
			return true
		end
		local pulledBefore = state.PulledAt
		local held = 0
		while held < 0.15 and not state.Cancel do
			place(target)
			held += RunService.Heartbeat:Wait()
		end
		local check = root()
		if state.PulledAt <= pulledBefore and check ~= nil and (check.Position - target).Magnitude <= 8 then
			slog(string.format("H-Claim: teleport held (attempt %d)", attempt))
			stopMotion()
			return true
		end
		slog(string.format("H-Claim: teleport rewound (attempt %d), again", attempt))
	end
	return false
end

semi.TpTo = tpTo




-- Instant TP hops toward a point (step = walk speed x 1.515, a pull-back repeats the hop, shorter hops after too many)
hopTo = function(target, maxHops)
	local waited = os.clock()
	while not swapped() and os.clock() - waited < 5 and not state.Cancel do
		RunService.Heartbeat:Wait()
	end
	local character = localPlayer.Character
	local step = math.max(walkSpeed() * CFG.HopRatio, CFG.HopMin)
	local gap = CFG.HopGap
	local retries, shrinks = 0, 0
	for _ = 1, maxHops or 70 do
		local r = root()
		if state.Cancel or not r or localPlayer.Character ~= character then
			return false
		end
		local delta = target - r.Position
		if delta.Magnitude <= 2 then
			return true
		end
		local nextPos = delta.Magnitude <= step and target or (r.Position + delta.Unit * step)
		local pulledBefore = state.PulledAt
		local held = 0
		while held < gap and not state.Cancel do
			place(nextPos)
			held += RunService.Heartbeat:Wait()
		end
		local check = root()
		if state.PulledAt > pulledBefore or (check ~= nil and (check.Position - nextPos).Magnitude > 10) then
			-- a rewind: the same hop again at once (the pause only grows after three in a row)
			retries += 1
			if retries > 3 then
				gap = math.min(CFG.HopGapMax, gap + 0.02)
			end
			if retries > 12 then
				if shrinks >= 2 then
					return false
				end
				shrinks += 1
				retries = 0
				step = math.max(step * 0.6, CFG.HopMin * 0.5)
			end
		else
			retries = 0
		end
	end
	local r = root()
	return r ~= nil and (target - r.Position).Magnitude <= 6
end








local function getOffTreadmill()
	for _ = 1, 3 do
		local r = root()
		if not r or not r.Anchored or state.Cancel then
			return true
		end
		local askDoff = remote("RF/Treadmill/AskDoff")
		if askDoff and askDoff:IsA("RemoteFunction") then
			pcall(askDoff.InvokeServer, askDoff)
		end
		local held, limit = 0, 1.5 + netPing()
		while held < limit and not state.Cancel do
			local rr = root()
			if not rr or not rr.Anchored then
				return true
			end
			held += RunService.Heartbeat:Wait()
		end
	end
	local r = root()
	return not (r and r.Anchored)
end

semi.DodgeRoute = function(ctx)
	local function held()
		return state.Carrying and state.Uid == ctx.Uid
	end
	local function near(a, b, d)
		return a and b and Vector3.new(a.X - b.X, 0, a.Z - b.Z).Magnitude <= d
	end
	local function pinFor(point, t, stopWhen)
		local w = 0
		while w < t and not state.Cancel do
			if stopWhen and stopWhen() then
				return true
			end
			local r = root()
			if r and (r.Position - point).Magnitude > 1 then
				place(point)
			end
			w += RunService.Heartbeat:Wait()
		end
		return stopWhen ~= nil and stopWhen() or false
	end
	if not root() then
		return false
	end
	getOffTreadmill()
	local eggPos = ctx.EggPos()
	local at = ctx.LandFor(eggPos)
	if not at then
		slog("Dodge route: no ground next to the egg")
		return false
	end
	local from = DODGE_BASE
	place(DODGE_BASE)
	pinFor(DODGE_BASE, 0.15)
	local ping = netPing()
	local r1Wait, r2Wait = DODGE_R1_WAIT + ping, DODGE_R2_WAIT + ping
	local pickDelay = math.max(DODGE_PICK_DELAY, ping * 2.5)
	local before = state.PulledAt
	local jumpAt = os.clock()
	place(at)
	progress(0.15, "Jumping onto the egg")
	slog(string.format("Dodge route: jump of %.0f studs from %.0f %.0f %.0f to %.1f %.1f %.1f", (at - from).Magnitude, from.X, from.Y, from.Z, at.X, at.Y, at.Z))
	local r1 = pinFor(at, r1Wait, function()
		return state.PulledAt > before
	end)
	local r1At = r1 and state.PulledAt or nil
	local r2At = nil
	if r1At then
		local toStart = state.RelocPos and near(state.RelocPos, at, 25) and "the arrival" or (state.RelocPos and string.format("%.0f %.0f %.0f", state.RelocPos.X, state.RelocPos.Y, state.RelocPos.Z) or "?")
		slog(string.format("Dodge route: R1 %.2f s after the jump, target %s", r1At - jumpAt, toStart))
		if state.RelocPos and near(state.RelocPos, at, 25) then
			r2At = r1At
		else
			local tripStart = os.clock()
			pinFor(DODGE_TRIP, DODGE_TRIP_HOLD)
			place(at)
			slog(string.format("Dodge route: round trip held %.2f s, back on the arrival", os.clock() - tripStart))
			local mark = state.PulledAt
			pinFor(at, r2Wait, function()
				if state.PulledAt > mark then
					mark = state.PulledAt
					if state.RelocPos and near(state.RelocPos, at, 25) then
						r2At = state.PulledAt
						return true
					end
				end
				return false
			end)
		end
	else
		slog(string.format("Dodge route: no Relocate within %.2f s after the jump (ping %.0f ms)", r1Wait, ping * 1000))
	end
	if r2At then
		slog(string.format("Dodge route: R2 to the arrival %.2f s after R1", r2At - (r1At or r2At)))
	elseif r1At then
		slog("Dodge route: no R2 to the arrival: the server did not accept the jump, back to the base")
		place(DODGE_BASE)
		return false
	end
	progress(0.3, "Jump accepted")
	plantClown(at)
	pinFor(at, math.max(0, (r2At or os.clock()) + pickDelay - os.clock()))
	local since, waited = 1, 0
	while not held() and waited < 2.5 and not state.Cancel do
		local r = root()
		local egg = ctx.EggPos() or eggPos
		if r and (r.Position - at).Magnitude > 1.5 then
			place(at)
		end
		local dt = RunService.Heartbeat:Wait()
		waited += dt
		since += dt
		if since >= CFG.GrabInterval then
			since = 0
			local prompt = promptNear(egg, 12)
			if prompt and typeof(fireproximityprompt) == "function" then
				pcall(function()
					prompt.HoldDuration = 0
				end)
				pcall(fireproximityprompt, prompt)
			end
			task.spawn(takeEgg, ctx.Uid)
		end
	end
	if not held() and not state.Cancel then
		ctx.Grab(ctx.Uid, 1)
	end
	if held() then
		progress(0.4, "Egg taken")
	end
	slog(string.format("Dodge route: carrying=%s %.2f s after the jump", tostring(held()), os.clock() - jumpAt))
	if not held() then
		place(DODGE_BASE)
		return false
	end
	return "near"
end



-- blackout: a black screen over the game and every game sound at zero for the whole trip, nothing seen and nothing heard on this screen
local blackout = { Enabled = true, Gui = nil, Sounds = {}, Links = {}, MasterOld = nil }

function blackout.mute(sound)
	if not sound:IsA("Sound") or blackout.Sounds[sound] ~= nil then
		return
	end
	blackout.Sounds[sound] = sound.Volume
	pcall(function()
		sound.Volume = 0
	end)
	blackout.Links[#blackout.Links + 1] = sound:GetPropertyChangedSignal("Volume"):Connect(function()
		if blackout.Gui and sound.Volume ~= 0 then
			sound.Volume = 0
		end
	end)
end

function blackout.setPet(name, icon, value)
	blackout.Pet = { Name = name, Icon = icon, Value = value }
	local ui = blackout.Ui
	if blackout.Gui and ui then
		pcall(function()
			ui.Name.Text = tostring(name or "")
			ui.Icon.Image = tostring(icon or "")
			ui.Value.Text = value and money(value) or ""
		end)
	end
end

function blackout.set(frac, text)
	local ui = blackout.Ui
	if not (blackout.Gui and ui) then
		return
	end
	frac = math.clamp(tonumber(frac) or 0, 0, 1)
	if frac == 0 then
		blackout.Frac = 0
	else
		blackout.Frac = math.max(blackout.Frac or 0, frac)
	end
	pcall(function()
		ui.Fill.Size = UDim2.fromScale(blackout.Frac, 1)
		ui.Pct.Text = string.format("%d%%", math.floor(blackout.Frac * 100 + 0.5))
	end)
end

state.Progress = function(frac, text)
	blackout.set(frac, text)
end

function blackout.on()
	if not blackout.Enabled or blackout.Gui then
		return
	end
	local screen = Instance.new("ScreenGui")
	screen.Name = string.format("%08x", math.random(0, 0x7fffffff))
	screen.IgnoreGuiInset = true
	screen.ResetOnSpawn = false
	screen.DisplayOrder = 100000
	screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	local cover = Instance.new("Frame")
	cover.Size = UDim2.fromScale(1, 1)
	cover.BackgroundColor3 = Color3.new(0, 0, 0)
	cover.BorderSizePixel = 0
	cover.Active = false
	cover.Parent = screen
	pcall(function()
		local card = Instance.new("Frame")
		card.AnchorPoint = Vector2.new(0.5, 0.5)
		card.Position = UDim2.fromScale(0.5, 0.5)
		card.Size = UDim2.fromOffset(240, 190)
		card.BackgroundTransparency = 1
		card.Parent = cover
		local function label(y, h, size, font, color)
			local l = Instance.new("TextLabel")
			l.AnchorPoint = Vector2.new(0.5, 0)
			l.Position = UDim2.new(0.5, 0, 0, y)
			l.Size = UDim2.new(1, 0, 0, h)
			l.BackgroundTransparency = 1
			l.Font = font
			l.TextSize = size
			l.TextColor3 = color
			l.TextTruncate = Enum.TextTruncate.AtEnd
			l.Text = ""
			l.Parent = card
			return l
		end
		local icon = Instance.new("ImageLabel")
		icon.AnchorPoint = Vector2.new(0.5, 0)
		icon.Position = UDim2.new(0.5, 0, 0, 0)
		icon.Size = UDim2.fromOffset(96, 96)
		icon.BackgroundTransparency = 1
		icon.ScaleType = Enum.ScaleType.Fit
		icon.Image = ""
		icon.Parent = card
		local nameLabel = label(102, 18, 15, Enum.Font.GothamBold, Color3.new(1, 1, 1))
		local valueLabel = label(121, 14, 11, Enum.Font.Gotham, Color3.fromRGB(150, 150, 156))
		local barBack = Instance.new("Frame")
		barBack.AnchorPoint = Vector2.new(0.5, 0)
		barBack.Position = UDim2.new(0.5, 0, 0, 148)
		barBack.Size = UDim2.new(1, 0, 0, 8)
		barBack.BackgroundColor3 = Color3.fromRGB(40, 40, 44)
		barBack.BorderSizePixel = 0
		barBack.Parent = card
		local backCorner = Instance.new("UICorner")
		backCorner.CornerRadius = UDim.new(0, 4)
		backCorner.Parent = barBack
		local fill = Instance.new("Frame")
		fill.Size = UDim2.fromScale(0, 1)
		fill.BackgroundColor3 = Color3.new(1, 1, 1)
		fill.BorderSizePixel = 0
		fill.Parent = barBack
		local fillCorner = Instance.new("UICorner")
		fillCorner.CornerRadius = UDim.new(0, 4)
		fillCorner.Parent = fill
		local pctLabel = label(162, 16, 11, Enum.Font.GothamMedium, Color3.fromRGB(200, 200, 205))
		blackout.Ui = { Icon = icon, Name = nameLabel, Value = valueLabel, Fill = fill, Pct = pctLabel }
		blackout.Frac = 0
		if blackout.Pet then
			blackout.setPet(blackout.Pet.Name, blackout.Pet.Icon, blackout.Pet.Value)
		end
		blackout.set(0, "Starting")
		pcall(function()
			local WHITE_, SILVER_, STEEL_ = Color3.new(1, 1, 1), Color3.fromRGB(150, 150, 156), Color3.fromRGB(70, 70, 76)
			local function bandSeq(c1, c2)
				return ColorSequence.new({
					ColorSequenceKeypoint.new(0, c1), ColorSequenceKeypoint.new(0.25, c2), ColorSequenceKeypoint.new(0.5, c1),
					ColorSequenceKeypoint.new(0.75, c2), ColorSequenceKeypoint.new(1, c1),
				})
			end
			local rings, texts = {}, {}
			local function ring(parent, thickness, c1, c2)
				local st = Instance.new("UIStroke")
				st.Thickness = thickness
				st.Color = Color3.new(1, 1, 1)
				st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				st.Parent = parent
				local g = Instance.new("UIGradient")
				g.Color = bandSeq(c1, c2)
				g.Parent = st
				rings[#rings + 1] = g
				return st
			end
			local function shine(label)
				local g = Instance.new("UIGradient")
				g.Color = bandSeq(WHITE_, SILVER_)
				g.Parent = label
				texts[#texts + 1] = g
			end
			local panel = Instance.new("Frame")
			panel.AnchorPoint = Vector2.new(0.5, 0.5)
			panel.Position = UDim2.fromScale(0.5, 0.5)
			panel.Size = UDim2.fromOffset(268, 222)
			panel.BackgroundColor3 = Color3.fromRGB(8, 8, 10)
			panel.BorderSizePixel = 0
			panel.ZIndex = 0
			panel.Parent = card
			local panelCorner = Instance.new("UICorner")
			panelCorner.CornerRadius = UDim.new(0, 20)
			panelCorner.Parent = panel
			ring(panel, 2, WHITE_, STEEL_)
			local halo = Instance.new("Frame")
			halo.AnchorPoint = Vector2.new(0.5, 0)
			halo.Position = UDim2.new(0.5, 0, 0, -6)
			halo.Size = UDim2.fromOffset(108, 108)
			halo.BackgroundTransparency = 1
			halo.ZIndex = 0
			halo.Parent = card
			local haloCorner = Instance.new("UICorner")
			haloCorner.CornerRadius = UDim.new(0.5, 0)
			haloCorner.Parent = halo
			ring(halo, 2, WHITE_, STEEL_)
			local iconScale = Instance.new("UIScale")
			iconScale.Parent = icon
			local cardScale = Instance.new("UIScale")
			cardScale.Scale = 0.82
			cardScale.Parent = card
			shine(nameLabel)
			shine(pctLabel)
			local barShine = Instance.new("UIGradient")
			barShine.Color = bandSeq(WHITE_, SILVER_)
			barShine.Parent = fill
			local specks = {}
			for i = 1, 14 do
				local d = Instance.new("Frame")
				local size = math.random(2, 4)
				d.Size = UDim2.fromOffset(size, size)
				d.BackgroundColor3 = Color3.new(1, 1, 1)
				d.BorderSizePixel = 0
				d.ZIndex = 0
				d.Parent = cover
				local dc = Instance.new("UICorner")
				dc.CornerRadius = UDim.new(0.5, 0)
				dc.Parent = d
				specks[i] = { F = d, X = math.random(), Y = math.random(), Speed = 0.04 + math.random() * 0.07, Phase = math.random() * 6.28 }
			end
			local born, acc = os.clock(), 0
			blackout.Links[#blackout.Links + 1] = RunService.Heartbeat:Connect(function(dt)
				acc += dt
				if acc < 0.033 then
					return
				end
				local step = acc
				acc = 0
				local t = os.clock() - born
				local spin = (t * 80) % 360
				for _, g in ipairs(rings) do
					g.Rotation = spin
				end
				for _, g in ipairs(texts) do
					g.Rotation = (t * 50) % 360
					g.Offset = Vector2.new(math.sin(t * 1.6) * 0.5, 0)
				end
				barShine.Offset = Vector2.new(((t * 0.9) % 2) - 1, 0)
				iconScale.Scale = 1 + math.sin(t * 2.4) * 0.05
				cardScale.Scale = math.min(1, 0.82 + (1 - math.exp(-t * 7)) * 0.18)
				for _, sp in ipairs(specks) do
					sp.Y -= sp.Speed * step
					if sp.Y < -0.03 then
						sp.Y = 1.03
						sp.X = math.random()
					end
					sp.F.Position = UDim2.fromScale(sp.X + math.sin(t * 0.8 + sp.Phase) * 0.012, sp.Y)
					sp.F.BackgroundTransparency = 0.35 + 0.55 * math.abs(math.sin(t * 1.3 + sp.Phase))
				end
			end)
		end)
	end)
	local parent
	if typeof(gethui) == "function" then
		local ok, result = pcall(gethui)
		if ok and typeof(result) == "Instance" then
			parent = result
		end
	end
	screen.Parent = parent or CoreGui
	blackout.Gui = screen
	pcall(function()
		local settingsService = UserSettings():GetService("UserGameSettings")
		blackout.MasterOld = settingsService.MasterVolume
		settingsService.MasterVolume = 0
	end)
	local masterZero = false
	pcall(function()
		masterZero = UserSettings():GetService("UserGameSettings").MasterVolume == 0
	end)
	if not masterZero then
		task.spawn(function()
			local scopes = { workspace }
			pcall(function()
				scopes[#scopes + 1] = game:GetService("SoundService")
			end)
			pcall(function()
				local count = 0
				for _, scope in ipairs(scopes) do
					for _, d in ipairs(scope:GetDescendants()) do
						if d:IsA("Sound") then
							blackout.mute(d)
						end
						count += 1
						if count % 600 == 0 then
							task.wait()
						end
					end
					blackout.Links[#blackout.Links + 1] = scope.DescendantAdded:Connect(function(d)
						if d:IsA("Sound") then
							blackout.mute(d)
						end
					end)
				end
			end)
		end)
	end
	slog("blackout on")
	task.delay(240, function()
		if blackout.Gui == screen then
			blackout.off()
		end
	end)
end

function blackout.off()
	local screen = blackout.Gui
	if not screen then
		return
	end
	blackout.Gui = nil
	blackout.Ui = nil
	for _, link in ipairs(blackout.Links) do
		pcall(function()
			link:Disconnect()
		end)
	end
	blackout.Links = {}
	for sound, volume in pairs(blackout.Sounds) do
		pcall(function()
			sound.Volume = volume
		end)
	end
	blackout.Sounds = {}
	pcall(function()
		if blackout.MasterOld ~= nil then
			UserSettings():GetService("UserGameSettings").MasterVolume = blackout.MasterOld
		end
	end)
	blackout.MasterOld = nil
	pcall(function()
		screen:Destroy()
	end)
	slog("blackout off")
end

local MAX_ATTEMPTS = 3

local function stealAndDeliver(uid, attempt)
	attempt = attempt or 1
	if state.Busy then
		return
	end
	state.Busy = true
	state.Cancel = false
	state.Died = false
	progress(0, attempt > 1 and string.format("Retry %d/%d", attempt, MAX_ATTEMPTS) or "Starting")
	state.Hits = 0
	state.Ragdoll = false
	worldResetTime, lastResetCheck = 0, 0
	blackout.on()
	local tripChar = localPlayer.Character
	task.spawn(function()
		while state.Busy and alive do
			task.wait(0.05)
			local now = localPlayer.Character
			local hum = tripChar and tripChar:FindFirstChildOfClass("Humanoid")
			if now ~= tripChar or not tripChar or (hum and hum.Health <= 0) then
				if state.Busy and not state.Cancel then
					state.Died = true
					state.Cancel = true
					status("Died: stopped, waiting for the respawn")
					slog("the body died, the trip is stopped and nothing moves the new body")
				end
				return
			end
		end
	end)
	task.spawn(function()
		local semiTrip = true
		local delivered = false
		local failReason = nil
		local ok, err = pcall(function()
			status("Looking for the egg")
			pcall(function()
				for _, record in ipairs(snapshot()) do
					if record.Uid == uid then
						local info = describe(record)
						blackout.setPet(info.Name, info.Icon, info.Value)
						return
					end
				end
			end)
			progress(0.04, "Looking for the egg")
			local egg = eggPosition(uid)
			if not egg then
				status("That egg is gone")
				return
			end
			if state.Carrying and state.Uid ~= uid then
				dropEgg()
				local waited = 0
				while state.Carrying and waited < 1 do
					waited += RunService.Heartbeat:Wait()
				end
			end
			state.NestBack = false
			if semiTrip then
				local r1 = root()
				local lineX1 = lineInfo()
				if r1 and r1.Position.Y < 5000 and not inDimension() and r1.Position.X > lineX1 + 800 and (egg - r1.Position).Magnitude > 100 then
					slog(string.format("Semi TP: the body stands %.0f studs past the line, hopping back to the base first", r1.Position.X - lineX1))
					status("Semi TP: hopping back to the base first")
					returnFront()
					if state.Cancel then
						return
					end
				end
			end
			status("Going to the egg")
			progress(0.08, "Going to the egg")
			local reached
			if semiTrip then
				local okSemi, info = semiGo(uid, egg)
				if not okSemi then
					failReason = info
					status("Could not reach the egg")
					return
				end
				semi.SlowRun = not (info.Plain or semi.Plain)
				local inHand = state.Carrying and state.Uid == uid
				local current = egg
				if not inHand then
					current = eggNow(uid, { At = 0, Pos = egg }) or egg
				end
				if info.Arrived or inHand then
					reached = true
				elseif info.Plain then
					reached = runToEgg(uid, current)
				elseif info.Decoy then
					reached = runToEgg(uid, current, { Field = true, Ratio = 1 })
				else
					reached = runToEgg(uid, current, { Field = true, Ratio = info.Ratio or 1.1, Height = 50 })
				end
			else
				reached = runToEgg(uid, egg)
			end
			if not reached then
				failReason = failReason or "could not reach the egg"
				status("Could not reach the egg")
				return
			end
			local inHandNow = state.Carrying and state.Uid == uid
			if not inHandNow then
				status("Taking the egg")
			end
			if not inHandNow and not grab(uid, 4) then
				local taken = false
				if not state.Cancel then
					slog("the egg would not come free: back to the safe zone, treadmill reset, one more try")
					local safeAt = Vector3.new(RELAY_SAFE.X, groundY(RELAY_SAFE, RELAY_SAFE.Y), RELAY_SAFE.Z)
					local here = root()
					if here and here.Position.X > lineInfo() + 100 then
						returnFront()
					end
					if not state.Cancel then
						place(safeAt)
						local calm = 0
						while calm < 0.15 and not state.Cancel do
							calm += RunService.Heartbeat:Wait()
						end
						treadmillReset()
						place(safeAt)
						calm = 0
						while calm < 0.15 and not state.Cancel do
							calm += RunService.Heartbeat:Wait()
						end
						local current = eggNow(uid, { At = 0, Pos = egg }) or egg
						if runToEgg(uid, current, { Field = true, Ratio = RUN_RATIO }) then
							taken = grab(uid, 4)
						end
					end
				end
				if not taken then
					failReason = "the egg would not come free"
					status("The egg would not come free")
					return
				end
			end
			delivered = instantTP(uid)
			if not delivered then
				failReason = state.NestBack and "the egg went back to its nest after the drop" or "delivery failed"
			end
			status(delivered and "Delivered" or "Delivery failed")
			if delivered then
				progress(1, "Delivered")
			end
		end)
		fpsOff()
		dropClone()
		if state.ReleaseCamera then
			pcall(state.ReleaseCamera)
			state.ReleaseCamera = nil
		end
		semi.SlowRun = false
		semi.AtDrop = false
		semi.Plain = false
		if state.Died then
			local from = os.clock()
			while os.clock() - from < 15 and (localPlayer.Character == tripChar or not root()) do
				task.wait(0.1)
			end
			local calm = os.clock()
			while os.clock() - calm < 2.5 and not (swapped() and os.clock() - calm > 1.5) do
				task.wait(0.1)
			end
			if viewState then
				releaseView()
			end
		elseif viewState and viewState.Forced then
			slog("H-Claim: the view stays frozen (forced)")
		elseif viewState then
			if state.Cancel and semi.Home then
				releaseBackHome(semi.Home)
			else
				releaseView()
			end
		end
		semi.Kind, semi.Home = nil, nil
		if semi.Rotate then
			local info = semi.Rotate
			semi.Rotate = nil
			pcall(function()
				info.Hum.AutoRotate = info.Old
			end)
		end
		if not ok then
			failReason = failReason or tostring(err)
			status("Error: " .. tostring(err))
		end
		slog("delivery " .. (delivered and "DONE" or "NOT done") .. ", " .. tostring(failReason or ""))

		local why0 = tostring(failReason or "")
		local willRetry = not delivered and not state.Cancel and not state.Died and attempt < MAX_ATTEMPTS and not string.find(why0, "no character", 1, true)
		if willRetry then
			status("Delivery failed, treadmill then retry")
			slog(string.format("attempt %d/%d failed (%s): clean restart through the treadmill", attempt, MAX_ATTEMPTS, why0))
			local function wait(t)
				local w = 0
				while w < t and not state.Cancel do
					w += RunService.Heartbeat:Wait()
				end
			end
			if state.Carrying then
				dropEgg()
				local w = 0
				while state.Carrying and w < 1 and not state.Cancel do
					w += RunService.Heartbeat:Wait()
				end
			end
			wait(0.6)
			local here = root()
			if here and here.Position.X > lineInfo() + 100 and not state.Cancel then
				returnFront()
			end
			if not state.Cancel then
				treadmillReset()
				wait(0.4)
			end
			willRetry = not state.Cancel and not state.Died and root() ~= nil
		end

		-- Semi TP failed: the body goes back to the front by itself, and if that is not enough the player gets an instruction
		if willRetry then
			semi.Fails = semi.Fails + 1
		elseif semiTrip then
			if delivered then
				semi.Fails, semi.ResetDone = 0, false
			elseif not state.Cancel then
				semi.Fails += 1
				local untilAt = os.clock() + 1.5
				while os.clock() < untilAt and not state.Cancel do
					RunService.Heartbeat:Wait()
				end
				local why = tostring(failReason or "unknown")
				if string.find(why, "portal not there", 1, true) then
					status("Semi TP: no portal now. Set Go to Run")
				elseif not semi.ResetDone then
					semi.ResetDone = true
					status("Semi TP failed, going back to the front")
					returnFront()
				else
					status("Semi TP failed again. Press Steal again")
				end
			end
		end
		state.Busy = false
		if willRetry then
			slog(string.format("restarting the steal, attempt %d/%d", attempt + 1, MAX_ATTEMPTS))
			stealAndDeliver(uid, attempt + 1)
		else
			blackout.off()
		end
	end)
end

------------------------------------------------------------------ UI: full black + yslemStyle
local WHITE = Color3.fromRGB(255, 255, 255)
local SILVER = Color3.fromRGB(150, 150, 156)
local STEEL = Color3.fromRGB(70, 70, 76)
local BG = Color3.fromRGB(0, 0, 0)
local RARITY_COLORS = {
	Color3.fromRGB(190, 190, 190), Color3.fromRGB(110, 210, 110), Color3.fromRGB(90, 160, 255),
	Color3.fromRGB(190, 110, 255), Color3.fromRGB(255, 170, 50), Color3.fromRGB(255, 80, 80),
	Color3.fromRGB(255, 90, 200), Color3.fromRGB(80, 235, 235),
}

local function parentGui()
	if typeof(gethui) == "function" then
		local ok, result = pcall(gethui)
		if ok and typeof(result) == "Instance" then
			return result
		end
	end
	return CoreGui
end

local function make(class, props)
	local inst = Instance.new(class)
	for k, v in pairs(props or {}) do
		inst[k] = v
	end
	return inst
end

local function corner(parent, radius)
	make("UICorner", { CornerRadius = UDim.new(0, radius or 6) }).Parent = parent
end

local function stroke(parent, thickness, bright)
	local s = make("UIStroke", { Thickness = thickness or 1, Color = bright and SILVER or STEEL, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
	s.Parent = parent
	return s
end

local function text(parent, props)
	props.BackgroundTransparency = 1
	props.TextColor3 = props.TextColor3 or WHITE
	local l = make("TextLabel", props)
	l.Parent = parent
	return l
end

local old = parentGui():FindFirstChild("yslemEgg")
if old then
	old:Destroy()
end

local gui = make("ScreenGui", { Name = "yslemEgg", DisplayOrder = 200000, ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, IgnoreGuiInset = true })
gui.Parent = parentGui()

local W, H, HEADER = 150, 214, 20
local window = make("Frame", { Size = UDim2.fromOffset(W, H), Position = UDim2.new(0.5, -W / 2, 0.5, -H / 2), BackgroundColor3 = BG, BorderSizePixel = 0, ClipsDescendants = false })
window.Parent = gui
corner(window, 18)
stroke(window, 1, true)

-- header bar, the title is black
local header = make("Frame", { Size = UDim2.new(1, -8, 0, HEADER - 4), Position = UDim2.fromOffset(4, 4), BackgroundColor3 = WHITE, BorderSizePixel = 0 })
header.Parent = window
corner(header, 10)
text(header, {
	Size = UDim2.new(1, -44, 1, 0), Position = UDim2.fromOffset(6, 0), Font = Enum.Font.GothamBlack, TextSize = 10,
	TextColor3 = Color3.new(0, 0, 0), TextXAlignment = Enum.TextXAlignment.Left, Text = "yslemEgg",
})

local function headerButton(label, offset)
	local b = make("TextButton", { Size = UDim2.fromOffset(17, 14), Position = UDim2.new(1, offset, 0.5, -7), BackgroundColor3 = BG, Font = Enum.Font.GothamBold, TextSize = 10, TextColor3 = WHITE, Text = label, AutoButtonColor = true })
	b.Parent = header
	corner(b, 7)
	stroke(b, 1, true)
	return b
end
local minimize = headerButton("-", -39)
local close = headerButton("x", -20)

local body = make("Frame", { Size = UDim2.new(1, -10, 1, -(HEADER + 10)), Position = UDim2.fromOffset(5, HEADER + 4), BackgroundTransparency = 1 })
body.Parent = window
make("UIListLayout", { Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder, FillDirection = Enum.FillDirection.Vertical }).Parent = body

local list = make("ScrollingFrame", {
	Size = UDim2.new(1, 0, 0, 118), LayoutOrder = 1, BackgroundColor3 = BG, BorderSizePixel = 0, ScrollBarThickness = 2, ScrollBarImageColor3 = SILVER,
	CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
})
list.Parent = body
corner(list, 12)
stroke(list, 1, false)
make("UIListLayout", { Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder }).Parent = list
make("UIPadding", { PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5), PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 6) }).Parent = list

local statusLabel = text(body, {
	Size = UDim2.new(1, 0, 0, 12), LayoutOrder = 2, Font = Enum.Font.Gotham, TextSize = 9,
	TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Text = "Pick a pet",
})

-- the panel only shows what happens to the egg, never timings or internals
local PUBLIC = { ["Pick a pet"] = true, ["That egg is gone"] = true, ["Delivered"] = true, ["Delivery failed"] = true, ["Delivery failed, treadmill then retry"] = true, ["Cancelling"] = true }
status = function(msg)
	msg = tostring(msg)
	if PUBLIC[msg] or string.sub(msg, 1, 9) == "Selected:" then
		statusLabel.Text = msg
	elseif string.sub(msg, 1, 5) == "Error" then
		statusLabel.Text = "Something went wrong"
	elseif state.Busy then
		statusLabel.Text = "Delivering"
	end
end

local function bigButton(parent, label, position, size)
	local b = make("TextButton", { Size = size, Position = position, BackgroundColor3 = BG, Font = Enum.Font.GothamBlack, TextSize = 12, TextColor3 = WHITE, Text = label, AutoButtonColor = true })
	b.Parent = parent
	corner(b, 14)
	stroke(b, 1, true)
	return b
end
local function smallToggle(label, order)
	local b = make("TextButton", { Size = UDim2.new(1, 0, 0, 16), LayoutOrder = order, BackgroundColor3 = BG, Font = Enum.Font.GothamBold, TextSize = 9, TextColor3 = WHITE, Text = label, AutoButtonColor = true })
	b.Parent = body
	corner(b, 8)
	stroke(b, 1, true)
	return b
end
local BLACKOUT_CODE = "YXSAE"
local blackRow = make("Frame", { Size = UDim2.new(1, 0, 0, 16), LayoutOrder = 3, BackgroundTransparency = 1 })
blackRow.Parent = body
local blackButton = make("TextButton", { Size = UDim2.new(0.58, -2, 1, 0), BackgroundColor3 = BG, Font = Enum.Font.GothamBold, TextSize = 9, TextColor3 = WHITE, Text = "Blackout: ON", AutoButtonColor = true })
blackButton.Parent = blackRow
corner(blackButton, 8)
stroke(blackButton, 1, true)
local codeBox = make("TextBox", { Size = UDim2.new(0.42, -2, 1, 0), Position = UDim2.new(0.58, 2, 0, 0), BackgroundColor3 = BG, Font = Enum.Font.GothamBold, TextSize = 9, TextColor3 = WHITE, PlaceholderText = "code", PlaceholderColor3 = SILVER, Text = "", ClearTextOnFocus = true })
codeBox.Parent = blackRow
corner(codeBox, 8)
stroke(codeBox, 1, false)
blackout.Locked = true
codeBox.FocusLost:Connect(function()
	local typed = string.upper((string.gsub(codeBox.Text, "%s", "")))
	if typed == BLACKOUT_CODE then
		blackout.Locked = false
		codeBox.Visible = false
		blackButton.Size = UDim2.new(1, 0, 1, 0)
	else
		codeBox.Text = ""
		if typed ~= "" then
			codeBox.PlaceholderText = "wrong"
		end
	end
end)
blackButton.MouseButton1Click:Connect(function()
	if state.Busy then
		return
	end
	if blackout.Enabled and blackout.Locked then
		codeBox.PlaceholderText = "code needed"
		return
	end
	blackout.Enabled = not blackout.Enabled
	blackButton.Text = "Blackout: " .. (blackout.Enabled and "ON" or "OFF")
end)
local buttonRow = make("Frame", { Size = UDim2.new(1, 0, 0, 28), LayoutOrder = 4, BackgroundTransparency = 1 })
buttonRow.Parent = body
local refreshButton = bigButton(buttonRow, "Refresh", UDim2.new(0, 0, 0, 0), UDim2.new(0.4, -2, 1, 0))
local stealButton = bigButton(buttonRow, "Steal", UDim2.new(0.4, 2, 0, 0), UDim2.new(0.6, -2, 1, 0))

local selectedUid = nil
local rows = {}

local function setSelected(uid)
	selectedUid = uid
	for rowUid, row in pairs(rows) do
		local on = rowUid == uid
		row.Stroke.Thickness = on and 1.5 or 1
		row.Stroke.Color = on and WHITE or STEEL
	end
end

local listSig = nil
local function rebuild(force)
	local infos = {}
	for _, record in ipairs(snapshot()) do
		infos[#infos + 1] = describe(record)
	end
	table.sort(infos, function(a, b)
		return a.Value > b.Value
	end)
	local parts = {}
	for i, info in ipairs(infos) do
		parts[i] = tostring(info.Uid) .. ":" .. tostring(info.Value)
	end
	local sig = table.concat(parts, ",")
	if not force and sig == listSig then
		return
	end
	listSig = sig
	for _, row in pairs(rows) do
		row.Frame:Destroy()
	end
	table.clear(rows)
	local still = false
	for index, info in ipairs(infos) do
		still = still or info.Uid == selectedUid
		local frame = make("TextButton", { Size = UDim2.new(1, 0, 0, 28), BackgroundColor3 = BG, LayoutOrder = index, Text = "", AutoButtonColor = true })
		frame.Parent = list
		corner(frame, 10)
		local rowStroke = stroke(frame, 1, false)

		make("ImageLabel", { Size = UDim2.fromOffset(22, 22), Position = UDim2.fromOffset(3, 3), BackgroundTransparency = 1, Image = info.Icon, ScaleType = Enum.ScaleType.Fit }).Parent = frame
		text(frame, {
			Size = UDim2.new(1, -30, 0, 13), Position = UDim2.fromOffset(28, 2), Font = Enum.Font.GothamBold, TextSize = 10,
			TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Text = info.Name,
			TextColor3 = RARITY_COLORS[math.clamp(info.Rarity, 1, #RARITY_COLORS)] or WHITE,
		})
		text(frame, {
			Size = UDim2.new(1, -30, 0, 11), Position = UDim2.fromOffset(28, 15), Font = Enum.Font.GothamMedium, TextSize = 9,
			TextXAlignment = Enum.TextXAlignment.Left, Text = money(info.Value),
		})

		rows[info.Uid] = { Frame = frame, Stroke = rowStroke }
		frame.MouseButton1Click:Connect(function()
			setSelected(info.Uid)
			status("Selected: " .. info.Name)
		end)
	end

	setSelected(still and selectedUid or nil)
	if #infos == 0 then
		status("Pick a pet")
	end
end

refreshButton.MouseButton1Click:Connect(function()
	if viewState and viewState.Forced then
		releaseView()
		semi.Kind, semi.Home = nil, nil
		return
	end
	if not state.Busy then
		rebuild(true)
	end
end)
pcall(function()
	getgenv().YslemUnfreeze = function()
		releaseView()
		semi.Kind, semi.Home = nil, nil
	end
end)

stealButton.MouseButton1Click:Connect(function()
	if state.Busy then
		state.Cancel = true
		status("Cancelling")
		return
	end
	if not selectedUid then
		status("Pick a pet")
		return
	end
	stealAndDeliver(selectedUid)
end)

task.spawn(function()
	while gui.Parent do
		task.wait(0.25)
		local st = state.Busy and "Cancel" or "Steal"
		if stealButton.Text ~= st then
			stealButton.Text = st
		end
		local rt = (viewState and viewState.Forced) and "Unfreeze" or "Refresh"
		if refreshButton.Text ~= rt then
			refreshButton.Text = rt
		end
	end
end)

-- drag
do
	local dragging, startPos, startInput
	header.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging, startPos, startInput = true, window.Position, input.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - startInput
			window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

local minimized = false
minimize.MouseButton1Click:Connect(function()
	minimized = not minimized
	body.Visible = not minimized
	window.Size = minimized and UDim2.fromOffset(W, HEADER + 4) or UDim2.fromOffset(W, H)
end)

close.MouseButton1Click:Connect(function()
	state.Cancel = true
	alive = false
	fpsOff()
	releaseView()
	pcall(function()
		getgenv().YslemSemiReport = nil
		getgenv().YslemUnfreeze = nil
	end)
	blackout.off()
	shieldStop()
	gui:Destroy()
end)

rebuild()
task.spawn(function()
	while gui.Parent do
		task.wait(4)
		if not state.Busy and body.Visible then
			rebuild()
		end
	end
end)

shieldStart()
