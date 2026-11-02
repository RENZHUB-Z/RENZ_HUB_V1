-- Reviewed v20: verified multi-floor approaches and current-target area recovery.
-- Nearby eggs on other floors use the verified landing route; safe staging checks all three axes.
-- Target removal or changed carry stops stale movement; relocated targets get a new landing probe.
-- Complete live map-boundary paths take precedence over fallback coordinates.
-- V19 GUI, filters, FPS controls, treadmill and continuous Halloween features are preserved.
-- Explicit matching delivery confirmations survive cancellation and late retry cleanup.
-- Bounded mutation metadata prevents a stalled helper from blocking future list refreshes.
-- Continuous Halloween mob farming and all event activities remain unchanged.
-- Background errors cannot cancel another trip; route errors retain their actual status.
-- Mob farming uses 0.05s single-bat / 0.10s alternate-bat pacing without fixed kill/hit/pass caps.
-- Stop ends farming; other enabled ready activities receive turns without competing for movement.
-- Unresponsive targets cool down; progress, exact ownership and bounded requests remain checked.
-- Kill speed depends on server confirmation; filters and owned cleanup remain enforced.
-- Eggs, mobs, Pumpkin Moon, Ghost Dog fishing/quest and Phantom Express use the event page.
-- New options start OFF; Auto buy spends 2,250 Candy Corn, Soul trades spend the displayed game cost.
-- Cross-world priority requires normal Auto steal ON and selected normal rarity tiers.
-- Train travel reserves movement until Home is confirmed; use Return Home after stopping a ride.
-- Requirements: bat for mobs, Haunted Rod for fishing, Train Pass or unlocked train access.
-- Original S2R methods retained, with carry, root, remote and startup ownership fixes.
-- Finish a normal trip before enabling Halloween; no Sena normal steal method is used.
-- Open Halloween; Auto Halloween starts OFF, Steal eggs and High zone first start ON.
-- No Halloween filter selections means all; selected names AND rarities must match.
-- Normal auto pauses during event ownership; opt-in cross-world hands matching eggs to normal Auto.
-- Stop preserves carried items; normal H-Claim and treadmill remain separate from event farming.
-- Return home refuses carried items; Candy Corn confirms Halloween deliveries.
-- Existing normal H-Claim routes remain available when Halloween automation is OFF.
-- Big Egg Finder retains all fresh reports; use Previous/Next to browse 25 per page.
-- Treadmill starts ON: confirmed deliveries return to the owned treadmill and mount it.
-- Treadmill return failure does not retry a delivered egg; turn it OFF beside Auto steal.
-- Big Egg Finder shows recent discovery reports, not confirmed live availability.
-- Drag the bottom-right corner to resize; Reset size restores the default.
-- Use Rarities to select one or more tiers, press Done, then enable Auto steal.
-- Filters can be changed while idle; rejected/missing targets exit without route movement.
-- Touch controls scale to the screen. Auto shows its retry cooldown after a failed target.
-- Auto starts OFF; Cancel disables it. Failed targets cool down for 30 seconds.
-- Auto watches current and newly spawned matches; an active trip finishes if Auto is switched OFF.
-- All existing routes, retry logic, blackout/code, reports and controls retained.
-- Close (X) restores graphics, camera, audio and the captured FPS cap.
-- Luau compile + mocked lifecycle tests are possible offline; verify gameplay in-game.
-- S2r Hub Instant steal!!! | Instant TP
-- Pick a pet (icon + value), press Steal. Dodge full: the player stays frozen where they stand, the body (the clown) jumps from the base onto the egg,
-- plants a clown, takes the egg, drops it, visits the treadmill, comes back through the clown and delivers.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local localPlayer = Players.LocalPlayer

-- Managed lifecycle: reload/close stops workers before restoring game settings.
local alive = true
local runtime = { Env = _G, Links = {}, Tasks = {}, Requests = {}, Animates = {}, Holds = {} }
pcall(function()
    if typeof(getgenv) == "function" then
        local env = getgenv()
        if type(env) == "table" then runtime.Env = env end
    end
end)
pcall(function()
    if type(runtime.Env.S2rInstantStealShutdown) == "function" then
        runtime.Env.S2rInstantStealShutdown()
    end
end)
if not localPlayer then
    warn("S2r Hub: run this on the client after the player has loaded.")
    return
end

function runtime.connect(signal, callback)
    local link = signal:Connect(function(...)
        if alive then runtime.dispatch(callback, ...) end
    end)
    runtime.Links[#runtime.Links + 1] = link
    return link
end

-- Signal callbacks can yield too. Keep them cancellable and route failures
-- through the same recovery path as scheduled workers.
function runtime.dispatch(callback, ...)
    if not alive then return end
    local thread = coroutine.running()
    local outer = runtime.Tasks[thread]
    runtime.Tasks[thread] = true
    local ok, err = pcall(callback, ...)
    runtime.Tasks[thread] = alive and outer or nil
    if not ok and alive then
        warn("S2r Hub: " .. tostring(err))
        if runtime.OnError then pcall(runtime.OnError, err) end
    end
end

function runtime.spawn(callback, ...)
    if not alive then return nil end
    return task.spawn(function(...)
        local thread = coroutine.running()
        runtime.Tasks[thread] = true
        local ok, err = pcall(callback, ...)
        runtime.Tasks[thread] = nil
        if not ok and alive then
            warn("S2r Hub: " .. tostring(err))
            if runtime.OnError then pcall(runtime.OnError, err) end
        end
    end, ...)
end

-- Only explicitly owned route workers may abort that same trip on an exception.
-- Background GUI, finder and dependency workers still report errors independently.
function runtime.spawnOwned(tripId, callback, ...)
    return runtime.spawn(function(...)
        local ok, err = pcall(callback, ...)
        if not ok and alive then
            warn("S2r Hub: " .. tostring(err))
            if runtime.OnError then pcall(runtime.OnError, err, tripId) end
        end
    end, ...)
end

function runtime.delay(seconds, callback, ...)
    if not alive then return nil end
    local thread = task.delay(seconds, function(...)
        local current = coroutine.running()
        if not alive then runtime.Tasks[current] = nil; return end
        local ok, err = pcall(callback, ...)
        runtime.Tasks[current] = nil
        if not ok and alive then
            warn("S2r Hub: " .. tostring(err))
            if runtime.OnError then pcall(runtime.OnError, err) end
        end
    end, ...)
    runtime.Tasks[thread] = true
    return thread
end

function runtime.cancel(thread)
    if not thread then return true end
    if thread == coroutine.running() or coroutine.status(thread) == "dead" then
        runtime.Tasks[thread] = nil
        return true
    end
    local ok = pcall(task.cancel, thread)
    if ok then runtime.Tasks[thread] = nil end
    return ok
end

-- Bind late/replaced game events exactly once. Watch links have their own
-- registry so replacement events do not accumulate dead connection entries.
function runtime.refreshWatches()
    for _, watch in pairs(runtime.Watches or {}) do
        local ok, source = pcall(watch.Resolve)
        if not ok then source = nil end
        local connected = watch.Link ~= nil
        if connected then
            local readable, active = pcall(function() return watch.Link.Connected end)
            if readable and active == false then connected = false end
        end
        if source ~= watch.Source or (source and not connected) then
            if watch.Link then pcall(function() watch.Link:Disconnect() end) end
            watch.Source, watch.Link = source, nil
            if source then
                local connected, link = pcall(function()
                    return source:Connect(function(...)
                        if alive and watch.Source == source then runtime.dispatch(watch.Callback, ...) end
                    end)
                end)
                if connected then watch.Link = link end
            end
        end
    end
end

function runtime.watch(key, resolve, callback)
    runtime.Watches = runtime.Watches or {}
    local old = runtime.Watches[key]
    if old and old.Link then pcall(function() old.Link:Disconnect() end) end
    if old then old.Source = nil end
    runtime.Watches[key] = { Resolve = resolve, Callback = callback }
    runtime.refreshWatches()
end

-- Prompt overrides belong to the active attempt and are restored even when
-- an executor's prompt call yields, throws, or its route is cancelled.
function runtime.restorePrompt(prompt, record)
    if not runtime.PromptHolds or runtime.PromptHolds[prompt] ~= record then return end
    runtime.PromptHolds[prompt] = nil
    pcall(function()
        if prompt.HoldDuration == 0 then prompt.HoldDuration = record.Duration end
    end)
end

function runtime.firePrompt(prompt)
    if not alive or typeof(fireproximityprompt) ~= "function" then return false end
    runtime.PromptHolds = runtime.PromptHolds or {}
    local record = runtime.PromptHolds[prompt]
    if not record then
        local ok, duration = pcall(function() return prompt.HoldDuration end)
        if ok and type(duration) == "number" and duration ~= 0 then
            if pcall(function() prompt.HoldDuration = 0 end) then
                record = { Duration = duration, Users = 0 }
                runtime.PromptHolds[prompt] = record
            end
        end
    end
    if record then record.Users += 1 end
    local ok, err = pcall(fireproximityprompt, prompt)
    if record and runtime.PromptHolds[prompt] == record then
        record.Users -= 1
        if record.Users == 0 then runtime.restorePrompt(prompt, record) end
    end
    return ok, err
end

function runtime.clearHolds()
    for link in pairs(runtime.Holds) do pcall(function() link:Disconnect() end) end
    table.clear(runtime.Holds)
    for prompt, record in pairs(runtime.PromptHolds or {}) do runtime.restorePrompt(prompt, record) end
end

function runtime.stop()
    runtime.clearHolds()
    if runtime.clearCarryProbe then runtime.clearCarryProbe() end
    for _, link in ipairs(runtime.Links) do pcall(function() link:Disconnect() end) end
    table.clear(runtime.Links)
    for _, watch in pairs(runtime.Watches or {}) do
        if watch.Link then pcall(function() watch.Link:Disconnect() end) end
    end
    runtime.Watches = {}
    local current = coroutine.running()
    for thread in pairs(runtime.Tasks) do
        if thread ~= current then pcall(task.cancel, thread) end
    end
    table.clear(runtime.Tasks)
    table.clear(runtime.Requests)
    for script, enabled in pairs(runtime.Animates) do
        pcall(function() script.Enabled = enabled end)
    end
    table.clear(runtime.Animates)
    if runtime.AnimateOwners then table.clear(runtime.AnimateOwners) end
end

-- A deadline retires the suspended client worker, permitting a later retry.
-- Concurrent callers share one request; late completions cannot replace a new one.
function runtime.cancelRequest(key, reason)
    local request = runtime.Requests[key]
    if not request then return true end
    if not runtime.cancel(request.Thread) then return false end
    runtime.cancel(request.Timer)
    request.Timer = nil
    request.Done = true
    request.Values = table.pack(false, reason or "Request cancelled")
    if runtime.Requests[key] == request then runtime.Requests[key] = nil end
    return true
end

function runtime.call(key, timeout, callback, ...)
    if not alive then return false, "Closed" end
    if type(timeout) ~= "number" or timeout ~= timeout or timeout <= 0 or timeout == math.huge then
        return false, "Request timed out"
    end
    local request = runtime.Requests[key]
    if not request then
        request = { Done = false, Deadline = os.clock() + timeout }
        runtime.Requests[key] = request
        request.Thread = runtime.spawn(function(...)
            local values = table.pack(pcall(callback, ...))
            if request.Done then return end
            runtime.cancel(request.Timer)
            request.Timer = nil
            request.Values, request.Done = values, true
            if runtime.Requests[key] == request then runtime.Requests[key] = nil end
        end, ...)
        if not request.Done then
            -- Retire the network worker even if every waiting route was
            -- cancelled before its deadline. Stale timers cannot touch retries.
            request.Timer = runtime.delay(math.max(0, request.Deadline - os.clock()), function()
                if runtime.Requests[key] == request and not request.Done then
                    runtime.cancelRequest(key, "Request timed out")
                end
            end)
        end
    end
    local deadline = math.min(request.Deadline, os.clock() + timeout)
    while alive and not request.Done and os.clock() < deadline do
        RunService.Heartbeat:Wait()
    end
    if not alive then return false, "Closed" end
    if not request.Done then
        -- A short-lived caller must not cancel a longer request another caller
        -- still owns. The shared worker retains its original upper bound.
        if os.clock() >= request.Deadline then
            runtime.cancelRequest(key, "Request timed out")
        end
        return false, "Request timed out"
    end
    return table.unpack(request.Values, 1, request.Values.n)
end

function runtime.invoke(event, timeout, ...)
    if not alive or not event or not event:IsA("RemoteFunction") then
        return false, "Remote unavailable"
    end
    return runtime.call(event, timeout, event.InvokeServer, event, ...)
end

-- Optional graphics-only low-device mode. Nothing is destroyed and physics,
-- prompts, textures, game UI, the day/night clock and FPS caps stay untouched.
-- The scoped factory adds only one local to the large main script.
local performance = (function()
    local api = { Enabled = false, Busy = false, Restoring = false, Stealing = false }
    local lighting = game:GetService("Lighting")
    local players = game:GetService("Players")
    local saved = setmetatable({}, { __mode = "k" })
    local queued = setmetatable({}, { __mode = "k" })
    local queue = {}
    local queueHead, queueTail = 1, 0
    local links = {}
    local worker
    local mode = "off"
    local closed = false
    local startWorker
    local activate

    local function disconnectSources()
        for _, link in ipairs(links) do
            pcall(function() link:Disconnect() end)
        end
        table.clear(links)
    end

    local function clearQueue()
        table.clear(queue)
        queueHead, queueTail = 1, 0
        queued = setmetatable({}, { __mode = "k" })
    end

    local function change(inst, property, value)
        if not inst then return end
        local properties = saved[inst]
        if properties and properties[property] then return end
        local ok, old = pcall(function() return inst[property] end)
        if not ok or old == value then return end
        if pcall(function() inst[property] = value end) then
            properties = properties or {}
            properties[property] = { Old = old, Applied = value }
            saved[inst] = properties
        end
    end

    local function restore(inst, properties)
        for property, entry in pairs(properties) do
            pcall(function()
                -- Preserve a different value set by the game after our change.
                if inst[property] == entry.Applied then
                    inst[property] = entry.Old
                end
            end)
        end
        saved[inst] = nil
    end

    local function inPlayerCharacter(inst)
        local ancestor = inst.Parent
        while ancestor and ancestor ~= workspace do
            if ancestor:IsA("Model") and players:GetPlayerFromCharacter(ancestor) then
                return true
            end
            ancestor = ancestor.Parent
        end
        return false
    end

    local function apply(inst)
        if not inst.Parent then return end
        if inst:IsA("BasePart") and not inst:IsA("Terrain") then
            change(inst, "CastShadow", false)
            change(inst, "Reflectance", 0)
        elseif inst:IsA("PostEffect") then
            change(inst, "Enabled", false)
        elseif inst:IsA("ParticleEmitter") or inst:IsA("Trail") or inst:IsA("Beam")
            or inst:IsA("Fire") or inst:IsA("Smoke") or inst:IsA("Sparkles") then
            -- Character effects are also managed by the frozen-view feature.
            if not inPlayerCharacter(inst) then
                change(inst, "Enabled", false)
            end
        end
    end

    local function push(entry)
        queueTail += 1
        queue[queueTail] = entry
    end

    local function pop()
        if queueHead > queueTail then return nil end
        local entry = queue[queueHead]
        queue[queueHead] = nil
        queueHead += 1
        if queueHead > queueTail then queueHead, queueTail = 1, 0 end
        return entry
    end

    local function enqueue(inst, recursive)
        if closed or mode ~= "on" then return end
        if not recursive and not saved[inst] and not (inst:IsA("BasePart")
            or inst:IsA("PostEffect") or inst:IsA("ParticleEmitter")
            or inst:IsA("Trail") or inst:IsA("Beam") or inst:IsA("Fire")
            or inst:IsA("Smoke") or inst:IsA("Sparkles")) then return end
        local existing = queued[inst]
        if existing then
            existing.Recursive = existing.Recursive or recursive
            return
        end
        local entry = { Inst = inst, Recursive = recursive }
        queued[inst] = entry
        push(entry)
        startWorker()
    end

    local function stopWorker()
        if worker then
            worker:Disconnect()
            worker = nil
        end
        api.Busy = false
    end

    startWorker = function()
        if worker or closed then return end
        api.Busy = true
        worker = RunService.Heartbeat:Connect(function(dt)
            local slowFrame = type(dt) == "number" and dt > 1 / 25
            local budget = slowFrame and 0.00035 or (api.Stealing and 0.00075 or 0.0015)
            local limit = slowFrame and 16 or (api.Stealing and 40 or 90)
            local deadline = os.clock() + budget
            local count = 0
            repeat
                if mode == "restoring" then
                    local inst, properties = next(saved)
                    if inst then
                        restore(inst, properties)
                    else
                        mode = "off"
                        api.Restoring = false
                        if api.Enabled and not closed then
                            activate()
                        else
                            stopWorker()
                            return
                        end
                    end
                elseif mode == "on" then
                    local entry = pop()
                    if not entry then
                        stopWorker()
                        return
                    end
                    if entry.Children then
                        -- Spread even wide sibling lists across the frame budget.
                        local child = entry.Children[entry.Index]
                        entry.Children[entry.Index] = false -- release visited objects during wide scans
                        entry.Index += 1
                        if entry.Index <= entry.Length then
                            push(entry)
                        end
                        if child then enqueue(child, true) end
                    else
                        queued[entry.Inst] = nil
                        pcall(function()
                            local inst = entry.Inst
                            -- Ignore objects moved outside the two visual scopes.
                            if inst ~= workspace and inst ~= lighting
                                and not inst:IsDescendantOf(workspace)
                                and not inst:IsDescendantOf(lighting) then
                                if saved[inst] then restore(inst, saved[inst]) end
                                return
                            end
                            apply(inst)
                            if entry.Recursive then
                                local children = inst:GetChildren()
                                if #children > 0 then
                                    push({ Children = children, Index = 1, Length = #children })
                                end
                            end
                        end)
                    end
                else
                    stopWorker()
                    return
                end
                count += 1
            until count >= limit or os.clock() >= deadline
        end)
    end

    activate = function()
        if closed then return end
        mode = "on"
        change(lighting, "GlobalShadows", false)
        local terrain = workspace:FindFirstChildOfClass("Terrain")
        change(terrain, "WaterWaveSize", 0)
        change(terrain, "WaterWaveSpeed", 0)
        change(terrain, "WaterReflectance", 0)
        pcall(function()
            local settings = UserSettings():GetService("UserGameSettings")
            change(settings, "SavedQualityLevel", Enum.SavedQualitySetting.QualityLevel1)
        end)
        for _, scope in ipairs({ workspace, lighting }) do
            -- Attach before traversal so streaming additions cannot be missed.
            links[#links + 1] = scope.DescendantAdded:Connect(function(inst)
                enqueue(inst, false)
            end)
            links[#links + 1] = scope.DescendantRemoving:Connect(function(inst)
                if saved[inst] then enqueue(inst, false) end
            end)
            enqueue(scope, true)
        end
    end

    function api.setStealing(stealing)
        if not closed then api.Stealing = stealing == true end
    end

    function api.setEnabled(enabled)
        if closed then return end
        enabled = enabled == true
        if api.Enabled == enabled then return end
        api.Enabled = enabled
        if enabled then
            -- Finish an older restoration before capturing the next baseline.
            if mode == "off" then activate() end
        elseif mode == "on" then
            disconnectSources()
            clearQueue()
            mode = "restoring"
            api.Restoring = true
            startWorker()
        end
    end

    function api.shutdown()
        if closed then return end
        closed = true
        api.Enabled = false
        api.Restoring = false
        api.Stealing = false
        mode = "closed"
        disconnectSources()
        clearQueue()
        stopWorker()
        -- No yield: a replacement script must see the original graphics values.
        for inst, properties in pairs(saved) do
            restore(inst, properties)
        end
    end

    return api
end)()

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

local networkingFolder
local EggState, Assets, Mutations

-- Dependencies can replicate after this script starts. Each missing module has
-- at most one loading worker, and failed loads are retried in the background.
function runtime.loadDependency(key, getter, accept)
    runtime.ModuleLoads = runtime.ModuleLoads or {}
    runtime.ModuleRetry = runtime.ModuleRetry or {}
    if runtime.ModuleLoads[key] or os.clock() < (runtime.ModuleRetry[key] or 0) then return end
    runtime.ModuleLoads[key] = true
    runtime.ModuleRetry[key] = os.clock() + 3
    runtime.spawn(function()
        local value = safeRequire(getter)
        if alive and type(value) == "table" then accept(value) end
        runtime.ModuleLoads[key] = nil
    end)
end

function runtime.refreshDependencies()
    if not EggState then
        runtime.loadDependency("EggState", function() return ReplicatedStorage.Client.EggState end, function(value) EggState = value end)
    end
    if not Assets then
        runtime.loadDependency("Assets", function() return ReplicatedStorage.Data.Assets end, function(value) Assets = value end)
    end
    if not Mutations then
        runtime.loadDependency("Mutations", function() return ReplicatedStorage.Shared.Modules.Mutations end, function(value) Mutations = value end)
    end
end
runtime.refreshDependencies()

local function remote(name)
    local packages = ReplicatedStorage:FindFirstChild("Packages")
    local current = packages and packages:FindFirstChild("Networking")
    -- A detached Packages folder can still parent the old Networking folder.
    -- Resolve against the live hierarchy so replacement remotes recover.
    if current ~= networkingFolder then
        networkingFolder = current
        runtime.EggSnapshot = nil
    end
    return networkingFolder and networkingFolder:FindFirstChild(name)
end

local function root()
	local character = localPlayer.Character
	return character and character:FindFirstChild("HumanoidRootPart")
end

-- "Humanoid Swap" (the default shield): the character runs on a copy of its humanoid,
-- the original is kept out of the character while we steal.
local shield = { Original = nil, Clone = nil, Character = nil, Links = {}, Tracks = {}, Connection = nil, Added = nil }

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
        if not runtime.TreadmillUtil then
            runtime.loadDependency("TreadmillUtil", function()
                return ReplicatedStorage.Shared.Util.TreadmillUtil
            end, function(value)
                if type(value.SpeedPowerToWalkSpeed) == "function" then runtime.TreadmillUtil = value end
            end)
        end
        local util = runtime.TreadmillUtil
        return stat and util and util.SpeedPowerToWalkSpeed(stat.Value) or nil
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
            -- A first PlayerModule require can yield through respawn or
            -- swap cleanup; never bind a stale humanoid after it resumes.
            local current = localPlayer.Character
            if type(controls) == "table" and current and humanoid
                and humanoid.Parent == current and humanoid.Health > 0 then
                controls.humanoid = humanoid
            end
		end
	end)
end

local function shieldAnimate(character)
    local animate = character and character:FindFirstChild("Animate")
    if not animate or not animate:IsA("LocalScript") then return end
    -- A restart already owns the original enabled state until its next frame.
    -- In particular, a second call must not capture our temporary false value.
    if runtime.Animates[animate] ~= nil then return end
    runtime.AnimateOwners = runtime.AnimateOwners or setmetatable({}, { __mode = "k" })
    local token = {}
    local enabled = animate.Enabled
    runtime.Animates[animate] = enabled
    runtime.AnimateOwners[animate] = token
    local function restart()
        local ok = pcall(function()
            animate.Enabled = false
            task.wait()
            if runtime.AnimateOwners[animate] == token and animate.Parent == character then
                animate.Enabled = enabled
            end
        end)
        if runtime.AnimateOwners[animate] == token then
            runtime.AnimateOwners[animate] = nil
            runtime.Animates[animate] = nil
            if not ok then pcall(function() animate.Enabled = enabled end) end
        end
    end
    if alive then
        runtime.spawn(restart)
    else
        -- Shutdown has already stopped managed workers; finish this restart
        -- before allowing another session to attach to the character.
        restart()
    end
end

local function shieldUnlink()
    for track, link in pairs(shield.Tracks) do
        pcall(function() link:Disconnect() end)
        pcall(function() track:Stop(0); track:Destroy() end)
    end
    table.clear(shield.Tracks)
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

-- Find the game's controller independently of our temporary clone.
function shield.LiveHumanoid(character, exclude)
    if not character then return nil end
    for _, child in ipairs(character:GetChildren()) do
        if child ~= exclude and child:IsA("Humanoid") and child.Health > 0 then
            return child
        end
    end
    return nil
end

function shield.Restore()
    shieldUnlink()
    local original, clone, owner = shield.Original, shield.Clone, shield.Character
    shield.Original, shield.Clone, shield.Character = nil, nil, nil
    local current = localPlayer.Character
    local subject
    if owner and current == owner then
        subject = shield.LiveHumanoid(owner, clone)
        if not subject and original then
            local ok = pcall(function()
                if original.Parent == nil and original.Health > 0 then original.Parent = owner end
                if original.Parent == owner and original.Health > 0 then subject = original end
            end)
            if not ok then subject = nil end
        end
        if subject then
            local camera = workspace.CurrentCamera
            if camera then
                pcall(function()
                    if camera.CameraSubject == clone or camera.CameraSubject == original or camera.CameraSubject == nil then
                        camera.CameraSubject = subject
                    end
                end)
            end
        end
    end
    if clone and clone ~= subject then pcall(function() clone:Destroy() end) end
    if original and original ~= subject then
        pcall(function() if original.Parent == nil then original:Destroy() end end)
    end
    -- Destroy the old clone before a controls-module load can yield.
    -- Otherwise a new swap could adopt the clone we are about to destroy.
    if subject then
        shieldControls(subject)
        if localPlayer.Character == owner and subject.Parent == owner then shieldAnimate(owner) end
    end
end

local function shieldSwap()
    local character = localPlayer.Character
    if shield.Original or shield.Clone then
        local clone = shield.Clone
        local owned = shield.Character == character and clone and clone.Parent == character
        if owned and not shield.LiveHumanoid(character, clone) then return end
        -- A removed clone, respawn, or game-installed replacement ends ownership
        -- of the old swap before a fresh controller can be adopted.
        shield.Restore()
    end
    local humanoid = shield.LiveHumanoid(character)
    if not humanoid or not grounded(humanoid) then return end
    local camera = workspace.CurrentCamera
    if not camera then return end
    local cloned, clone = pcall(function() return humanoid:Clone() end)
    if not cloned or not clone then return end
    shield.Original, shield.Clone, shield.Character = humanoid, clone, character
    local swappedOk = pcall(function()
        humanoid.Parent = nil
        clone.Parent = character
        camera.CameraSubject = clone
    end)
    if not swappedOk then
        shield.Restore()
        return
    end
    shieldControls(clone)
    if not alive or localPlayer.Character ~= character or shield.Clone ~= clone
        or shield.Original ~= humanoid or clone.Parent ~= character then
        if shield.Clone == clone and shield.Original == humanoid then shield.Restore() end
        return
    end
    shieldAnimate(character)

    table.insert(shield.Links, humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if shield.Clone == clone and clone.Parent == character then
            clone.WalkSpeed = humanoid.WalkSpeed
        end
    end))

    local animator = humanoid:FindFirstChildOfClass("Animator")
    local animator2 = clone:FindFirstChildOfClass("Animator")
    if animator and animator2 then
        table.insert(shield.Links, animator.AnimationPlayed:Connect(function(played)
            local animation = played.Animation
            if not animation or shield.Clone ~= clone or clone.Parent ~= character then return end
            local ok, track = pcall(function() return animator2:LoadAnimation(animation) end)
            if not ok or not track then return end
            pcall(function()
                track.Priority = played.Priority
                track.Looped = played.Looped
                track:Play(0.05, math.max(played.WeightTarget, 0.01), played.Speed)
            end)
            local stopped
            stopped = played.Stopped:Connect(function()
                stopped:Disconnect()
                shield.Tracks[track] = nil
                pcall(function() track:Stop(0); track:Destroy() end)
            end)
            shield.Tracks[track] = stopped
        end))
    end

    table.insert(shield.Links, clone.Died:Connect(function()
        if shield.Clone ~= clone or shield.Original ~= humanoid then return end
        shieldUnlink()
        shield.Original, shield.Clone, shield.Character = nil, nil, nil
        local current = localPlayer.Character
        local replacement = current == character and shield.LiveHumanoid(character, clone) or nil
        if current == character and not replacement and humanoid.Parent == nil then
            humanoid.Parent = character
            if workspace.CurrentCamera then workspace.CurrentCamera.CameraSubject = humanoid end
            shieldControls(humanoid)
            humanoid.Health = 0
        else
            if replacement then
                local camera = workspace.CurrentCamera
                if camera and camera.CameraSubject == clone then camera.CameraSubject = replacement end
                shieldControls(replacement)
            end
            pcall(function() if humanoid.Parent == nil then humanoid:Destroy() end end)
        end
        pcall(function() clone:Destroy() end)
    end))
end

local function shieldUndo()
    shield.Restore()
end

local function shieldStart()
    if not alive or shield.Connection or shield.Starting then return end
    local starting = {}
    shield.Starting = starting
    local ok, err = pcall(shieldSwap)
    if not ok then
        if shield.Starting == starting then
            shield.Starting = nil
            pcall(shield.Restore)
        end
        error(err, 0)
    end
    if not alive or shield.Starting ~= starting then return end
    shield.Starting = nil
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
        shieldUndo()
		runtime.spawn(function()
			character:WaitForChild("Humanoid", 10)
            task.wait(1)
			if alive and shield.Connection and localPlayer.Character == character then
				shieldSwap()
			end
		end)
	end)
end

local function shieldStop()
    shield.Starting = nil
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
local state = { Carrying = false, Uid = nil, Delivered = 0, Busy = false, Cancel = false, Mult = 1, PulledAt = 0, HeldSeen = 0, GuessedDrop = false }

local function progress(frac, text)
	local f = state.Progress
	if f then
		f(frac, text)
	end
end

runtime.watch("Carry", function()
    return type(EggState) == "table" and EggState.CarryChanged or nil
end, function(arg)
        local carrying = type(arg) == "table" and arg.IsCarrying == true
        local uid = type(arg) == "table" and type(arg.Uid) == "string" and arg.Uid ~= "" and arg.Uid or nil
        if carrying and arg.GuardDisabled == true then carrying = false end
        -- A delayed drop for another egg must not clear the current carry.
        if not carrying and uid and state.Carrying and state.Uid and uid ~= state.Uid then return end
        state.GuessedDrop = false
        if carrying then
            local newCarry = not state.Carrying or (uid and uid ~= state.Uid)
            state.HeldSeen = os.clock()
            if newCarry then
                state.CarryAt = os.clock()
                state.CarryLogged = false
                -- Missing identifiers must never inherit a previously dropped egg.
                state.Uid, state.Mult = uid, 1
            end
            if uid then state.Uid = uid end
            local mult = tonumber(arg.SpeedMultiplier)
            if mult and mult > 0 and mult < math.huge then state.Mult = mult end
            state.WakeReq = arg.RunBackWakeDelayRequired
        end
        state.Carrying = carrying
        runtime.EggSnapshot = nil
end)

-- A verdict event can be a failure; never count an explicit rejection as a delivery.
local function verdictIsRejected(payload)
    local function rejected(value)
        if value == false then return true end
        if type(value) ~= "string" then return false end
        value = string.lower(value):match("^%s*(.-)%s*$")
        return value == "failed" or value == "failure" or value == "rejected"
            or value == "denied" or value == "error" or value == "invalid"
            or value == "cancelled" or value == "canceled" or value == "false"
    end
    if rejected(payload) then return true end
    if type(payload) ~= "table" then return false end
    for _, key in ipairs({ "Success", "Succeeded", "Accepted", "Redeemed", "IsSuccess", "IsAccepted", "IsRedeemed" }) do
        if rejected(payload[key]) then return true end
    end
    for _, key in ipairs({ "Status", "Result", "Verdict" }) do
        if rejected(payload[key]) then return true end
    end
    return false
end

runtime.watch("Verdict", function()
    local event = remote("RE/EggWorld/FieldEggRedeemVerdict")
    return event and event:IsA("RemoteEvent") and event.OnClientEvent or nil
end, function(payload)
            if not state.Busy or state.HalloweenOwner then
                return
            end
            local verdictUid
            if type(payload) == "table" then
                verdictUid = payload.Uid or payload.EggUid or payload.FieldEggUid
                if verdictUid ~= nil and state.TargetUid ~= nil and tostring(verdictUid) ~= tostring(state.TargetUid) then
                    return
                end
            end
            if verdictIsRejected(payload) then
                state.DeliveryFailedAt = os.clock()
                return
            end
            -- Preserve compatibility with game versions that send only an empty success event.
            state.Delivered = os.clock()
            -- A durable completion needs this trip's delivery phase and an
            -- explicit egg identity. Old/unidentified events retain only the
            -- existing route timestamp compatibility above.
            local phase = state.DeliveryPhase
            if phase and phase.TripId == state.TripId and phase.Character == state.TripCharacter
                and phase.Uid == state.TargetUid and type(verdictUid) == "string"
                and verdictUid ~= "" and verdictUid == phase.Uid then
                state.TripDelivered = true
            end
end)

runtime.watch("Alerts", function()
    local event = remote("RE/Alerts/Raise")
    return event and event:IsA("RemoteEvent") and event.OnClientEvent or nil
end, function(arg)
		if type(arg) == "table" and type(arg.Text) == "string" and string.find(string.lower(arg.Text), "delivery failed", 1, true) then
			state.DeliveryFailedAt = os.clock()
		end
end)

-- the server pulling us back ("Relocate") is noted so the hop is simply repeated
runtime.watch("RigSync", function()
    local event = remote("RE/RigSync/Refresh")
    return event and event:IsA("RemoteEvent") and event.OnClientEvent or nil
end, function(arg)
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

function runtime.ready()
    if type(EggState) ~= "table" or type(EggState.CarryFieldEgg) ~= "function"
        or type(EggState.DropFieldEgg) ~= "function" then
        return false, "Game data not ready"
    end
    local event = remote("RF/EggWorld/AskFieldEggSnapshot")
    if not event or not event:IsA("RemoteFunction") then return false, "Game data not ready" end
    -- CarryChanged is optional: heldByMe supplies the original carry fallback.
    for _, key in ipairs({ "Verdict", "RigSync" }) do
        local watch = runtime.Watches and runtime.Watches[key]
        if not watch or not watch.Link then return false, "Game events not ready" end
    end
    return true
end

runtime.spawn(function()
    while alive do
        runtime.refreshDependencies()
        runtime.refreshWatches()
        task.wait(2)
    end
end)

local function takeEgg(uid)
    if not alive or state.Cancel or state.TakePending or state.Carrying then return end
    if type(uid) == "string" and type(EggState) == "table" and type(EggState.CarryFieldEgg) == "function" then
        local owner, tripId, character = coroutine.running(), state.TripId, localPlayer.Character
        state.TakePending = owner
        local ok, err = runtime.call("CarryFieldEgg", 4, EggState.CarryFieldEgg, uid)
        if state.TakePending == owner then
            state.TakePending = nil
            if alive and not state.Cancel and state.TripId == tripId and localPlayer.Character == character then
                state.LastTakeError = not ok and tostring(err) or nil
            end
        end
    end
end

local function dropEgg()
    runtime.EggSnapshot = nil
	if type(EggState) == "table" and type(EggState.DropFieldEgg) == "function" then
        return runtime.call("DropFieldEgg", 4, EggState.DropFieldEgg, "PlayerRequest")
	end
end

-- Only top-level physical objects can contain the original egg prompts.
do
    local parts = setmetatable({}, { __mode = "k" })
    runtime.PromptParts = parts
    local function add(child)
        if child:IsA("BasePart") then parts[child] = true end
    end
    runtime.connect(workspace.ChildAdded, add)
    runtime.connect(workspace.ChildRemoved, function(child) parts[child] = nil end)
    for _, child in ipairs(workspace:GetChildren()) do add(child) end
end

local function promptNear(position, radius)
    local best, bestDistance = nil, radius
    for child in pairs(runtime.PromptParts) do
        if child.Parent == workspace and child.Name == "SmartPromptPart" then
            local prompt = child:FindFirstChild("CarryAreaEgg")
            if prompt and prompt:IsA("ProximityPrompt") and prompt.Enabled == true then
                local distance = (child.Position - position).Magnitude
                if distance < bestDistance then best, bestDistance = prompt, distance end
            end
        end
    end
    return best
end

function runtime.clearCarryProbe()
    local probe = runtime.CarryProbe
    runtime.CarryProbe = nil
    if probe then
        for _, link in ipairs(probe.Links) do pcall(function() link:Disconnect() end) end
    end
end

-- Cache joint identities, but read their endpoints live on every carry check.
local function heldByMe(uid)
    local character = localPlayer.Character
    local egg = type(uid) == "string" and workspace:FindFirstChild(uid)
    if not character or not egg then runtime.clearCarryProbe(); return false end
    local probe = runtime.CarryProbe
    if not probe or probe.Egg ~= egg or probe.Character ~= character then
        runtime.clearCarryProbe()
        probe = { Egg = egg, Character = character, Joints = {}, Links = {} }
        runtime.CarryProbe = probe
        local function add(inst)
            if inst:IsA("WeldConstraint") or inst:IsA("JointInstance") then probe.Joints[inst] = true end
        end
        probe.Links[1] = egg.DescendantAdded:Connect(add)
        probe.Links[2] = egg.DescendantRemoving:Connect(function(inst) probe.Joints[inst] = nil end)
        for _, inst in ipairs(egg:GetDescendants()) do add(inst) end
    end
    for joint in pairs(probe.Joints) do
        local ok, held = pcall(function()
            local a, b = joint.Part0, joint.Part1
            return (a and a:IsDescendantOf(character)) or (b and b:IsDescendantOf(character))
        end)
        if ok and held then return true end
    end
    return false
end

-- An identifier-free carry update is only associated with the selected egg
-- after the live character joint confirms it. Never replace an explicit UID.
function runtime.confirmCarry(uid)
    if not alive or not state.Carrying or state.Uid ~= nil or type(uid) ~= "string" then return false end
    if not heldByMe(uid) then return false end
    state.Uid = uid
    state.HeldSeen = os.clock()
    state.GuessedDrop = false
    return true
end

runtime.spawn(function()
	while alive do
		task.wait(0.2)
        if not state.Carrying then
            local uid = state.TargetUid or state.Uid
            if type(uid) == "string" and heldByMe(uid) then
                local now = os.clock()
                state.GuessedDrop = false
                state.Carrying = true
                state.Uid = uid
                state.HeldSeen = now
                state.CarryAt = now
                state.CarryLogged = false
            end
        elseif state.Uid == nil then
            if not runtime.confirmCarry(state.TargetUid) and os.clock() - state.HeldSeen > 1.5 then
                state.Carrying, state.GuessedDrop = false, true
            end
        elseif heldByMe(state.Uid) then
            state.HeldSeen = os.clock()
        elseif os.clock() - state.HeldSeen > 1.5 then
			state.Carrying, state.GuessedDrop = false, true
		end
	end
end)

local function snapshot(force)
    local snapshotRemote = remote("RF/EggWorld/AskFieldEggSnapshot")
    if not (snapshotRemote and snapshotRemote:IsA("RemoteFunction")) then
        state.SnapshotError = "Egg snapshot remote unavailable"
        return {}
    end
    local cache = runtime.EggSnapshot
    local now = os.clock()
    if not force and cache and cache.Remote == snapshotRemote and now >= cache.At
        and now - cache.At < (cache.Error and 0.5 or 0.2) then
        state.SnapshotError = cache.Error
        return cache.List
    end
    local ok, result = runtime.invoke(snapshotRemote, 8)
    -- Game networking can be replaced while this bounded request yields.
    -- Its old response must not replace a newer cache or select a stale egg.
    if remote("RF/EggWorld/AskFieldEggSnapshot") ~= snapshotRemote then
        state.SnapshotError = "Egg snapshot changed; refresh and try again"
        return {}
    end
    local list, byUid, failure = {}, {}, nil
    if not ok then
        failure = result == "Request timed out" and "Egg snapshot timed out" or "Egg snapshot request failed"
    elseif type(result) ~= "table" or type(result.Records) ~= "table" then
        failure = "Egg snapshot format changed"
    else
        for _, record in pairs(result.Records) do
            if type(record) == "table" and type(record.Uid) == "string"
                and (record.State == "Slot" or record.State == "Dropped")
                and typeof(record.BottomCFrame) == "CFrame" and not byUid[record.Uid] then
                local position = record.BottomCFrame.Position
                if position.X == position.X and position.Y == position.Y and position.Z == position.Z
                    and math.abs(position.X) < math.huge and math.abs(position.Y) < math.huge
                    and math.abs(position.Z) < math.huge then
                    list[#list + 1] = record
                    byUid[record.Uid] = record
                end
            end
        end
    end
    state.SnapshotError = failure
    runtime.EggSnapshot = { Remote = snapshotRemote, At = os.clock(), List = list, ByUid = byUid, Error = failure }
    return list
end

local function eggPosition(uid)
    snapshot()
    local cache = runtime.EggSnapshot
    local record = not state.SnapshotError and cache and cache.ByUid[uid]
    return record and record.BottomCFrame.Position or nil
end

------------------------------------------------------------------ egg info for the list (icon, name, value)
local function describe(record)
    if type(record) ~= "table" then return nil end
	local directory = type(Assets) == "table" and Assets.Directory or nil
    local category = record.AssetCategory
	local entry = type(directory) == "table" and (directory[tostring(category)] or directory[category]) or nil
	local info = { Uid = record.Uid, Category = tostring(record.AssetCategory), Name = tostring(record.AssetCategory), Icon = "", Rarity = 0, Value = 0 }

	if type(entry) == "table" then
		info.Name = tostring(entry.DisplayName or record.AssetCategory)
		local icon = entry.Icon
		if icon ~= nil and tostring(icon) ~= "" then
			icon = tostring(icon)
			info.Icon = tonumber(icon) and ("rbxassetid://" .. icon) or icon
		end

        local scale = tonumber(record.AssetScale) or 1
        if scale ~= scale or scale < 0 or scale == math.huge then scale = 1 end
		local factor = scale > 5 and (scale / 5) ^ 1.2 * 19.637875755794113 or scale ^ 1.85
        local mutation = runtime.mutationEarnings(record.Mutations)
        info.Value = (tonumber(entry.EarningRate) or 0) * factor * mutation
        if info.Value ~= info.Value or info.Value < 0 or info.Value == math.huge then info.Value = 0 end
	end

    -- Resolve list colors/labels through the same metadata as filtering.
    -- This also handles numeric and named rarities and invalid rank fallbacks.
    local rarity = runtime.rarityFilter.identity(record)
    info.Rarity, info.RarityKey, info.RarityLabel = rarity.Rank, rarity.Key, rarity.Label
	return info
end

-- Mutation metadata may yield inside a game helper. Each caller owns its
-- arguments/request; a failed helper briefly falls back instead of stalling
-- every remaining row or leaking a blocked worker into later refreshes.
runtime.mutationEarnings = (function()
    local sources = setmetatable({}, { __mode = "k" })
    return function(input)
        local source = Mutations
        local callback = type(source) == "table" and source.EarningsFor
        if not alive or type(callback) ~= "function" then return 1 end
        local helpers = sources[source]
        if not helpers then helpers = setmetatable({}, { __mode = "k" }); sources[source] = helpers end
        local state = helpers[callback]
        if not state then state = { RetryAt = 0 }; helpers[callback] = state end
        if os.clock() < state.RetryAt then return 1 end
        local function current()
            return alive and Mutations == source and source.EarningsFor == callback
        end
        local ok, value = runtime.call({}, 0.75, function()
            if not current() then return nil end
            return callback(type(input) == "table" and input or {})
        end)
        if not current() then return 1 end
        if ok and type(value) == "number" and value == value and math.abs(value) < math.huge then
            return value
        end
        state.RetryAt = os.clock() + 3
        return 1
    end
end)()
-- End bounded mutation earnings.

local function money(value)
    value = tonumber(value) or 0
    if value ~= value or value < 0 or value == math.huge then value = 0 end
	local units = { { 1e12, "T" }, { 1e9, "B" }, { 1e6, "M" }, { 1e3, "K" } }
	for _, u in ipairs(units) do
		if value >= u[1] then
			return string.format("$%.2f%s/s", value / u[1], u[2])
		end
	end
	return string.format("$%d/s", math.floor(value + 0.5))
end

-- Rarity identity uses live game metadata, independently of display colors.
-- A missing rarity is Unknown, never an assumed Common/lowest tier.
runtime.rarityFilter = (function()
    local api = { All = true, Selected = {}, Generation = 0 }
    local labels = { unknown = "Unknown" }
    local previousCatalog = {}

    local function textValue(value)
        if type(value) ~= "string" then return nil end
        local value = string.gsub(value, "%s+", " ")
        value = string.match(value, "^%s*(.-)%s*$")
        return value ~= "" and value or nil
    end

    local function rankValue(value)
        if type(value) ~= "number" and type(value) ~= "string" then return nil end
        local number = tonumber(value)
        if number and number == number and number >= 0 and number < math.huge then return number end
        return nil
    end

    local function fromEntry(entry)
        local rarity = type(entry) == "table" and entry.Rarity or nil
        local rank, label
        if type(rarity) == "table" then
            rank = rankValue(rarity.RarityNumber) or rankValue(rarity.Rank)
            label = textValue(rarity.DisplayName) or textValue(rarity.Name)
        elseif type(rarity) == "number" then
            rank = rankValue(rarity)
        elseif type(rarity) == "string" then
            rank = rankValue(rarity)
            if not tonumber(rarity) then label = textValue(rarity) end
        end
        local key
        if rank ~= nil then
            key = "rank:" .. tostring(rank)
            label = label or ("Rarity " .. tostring(rank))
        elseif label then
            key = "name:" .. string.lower(label)
        else
            key, label = "unknown", "Unknown"
        end
        return { Key = key, Label = label, Name = label, Rank = rank or 0 }
    end

    function api.identity(record)
        local directory = type(Assets) == "table" and Assets.Directory or nil
        local category = type(record) == "table" and record.AssetCategory or nil
        local entry
        if type(directory) == "table" and (type(category) == "string" or type(category) == "number") then
            entry = directory[tostring(category)] or directory[category]
        end
        return fromEntry(entry)
    end

    function api.matches(record)
        if type(record) ~= "table" then return false end
        if api.All then return true end
        return api.Selected[api.identity(record).Key] == true
    end

    function api.catalog()
        local byKey = { unknown = fromEntry(nil) }
        local directory = type(Assets) == "table" and Assets.Directory or nil
        if type(directory) == "table" then
            for _, entry in pairs(directory) do
                local item = fromEntry(entry)
                local old = byKey[item.Key]
                -- Prefer a game-provided name over a numeric fallback. Make
                -- duplicate metadata independent of table iteration order.
                local fallback = "Rarity " .. tostring(item.Rank)
                if not old or (old.Label == fallback and item.Label ~= fallback)
                    or (item.Label ~= fallback and old.Label ~= fallback and item.Label < old.Label) then
                    byKey[item.Key] = item
                end
            end
        end
        for _, item in pairs(byKey) do item.Available = true end
        -- Replication can temporarily remove a selected tier. Keep its button
        -- visible so the user can still clear it; matching continues to use
        -- current metadata, never this display-only catalog history.
        for key, selected in pairs(api.Selected) do
            if selected and not byKey[key] then
                local old = previousCatalog[key]
                local rank = rankValue(string.match(key, "^rank:(.+)$"))
                local label = old and old.Label or labels[key]
                    or (rank and ("Rarity " .. tostring(rank)))
                    or string.gsub(key, "^name:", "")
                byKey[key] = { Key = key, Label = label, Name = label,
                    Rank = old and old.Rank or rank or 0, Available = false }
            end
        end
        local items, nextLabels = {}, { unknown = "Unknown" }
        for key, item in pairs(byKey) do
            nextLabels[key] = item.Label
            items[#items + 1] = item
        end
        labels, previousCatalog = nextLabels, byKey
        table.sort(items, function(a, b)
            if a.Key == "unknown" or b.Key == "unknown" then return b.Key == "unknown" and a.Key ~= "unknown" end
            if a.Rank ~= b.Rank then return a.Rank > b.Rank end
            if a.Label ~= b.Label then return a.Label < b.Label end
            return a.Key < b.Key
        end)
        return items
    end

    local function changed()
        api.Generation += 1
        return true
    end

    function api.setAll(enabled)
        if type(enabled) ~= "boolean" then return false end
        if api.All == enabled and next(api.Selected) == nil then return false end
        api.All = enabled
        table.clear(api.Selected)
        return changed()
    end

    function api.clear()
        return api.setAll(false)
    end

    function api.toggle(key)
        if type(key) ~= "string" then return false end
        if key ~= "unknown" then
            local rank = string.match(key, "^rank:(.+)$")
            local name = string.match(key, "^name:(.+)$")
            if rank then
                local number = rankValue(rank)
                if number == nil or key ~= "rank:" .. tostring(number) then return false end
            elseif not name or textValue(name) ~= name or string.lower(name) ~= name then
                return false
            end
        end
        if api.All then
            api.All = false
            table.clear(api.Selected)
        end
        api.Selected[key] = not api.Selected[key] or nil
        return changed()
    end

    function api.summary()
        if api.All then return "All rarities" end
        local count, selected = 0, nil
        for key, enabled in pairs(api.Selected) do
            if enabled then count += 1; selected = key end
        end
        if count == 0 then return "No rarities" end
        if count == 1 then
            return labels[selected] or string.gsub(selected, "^rank:", "Rarity "):gsub("^name:", "")
        end
        return tostring(count) .. " rarities"
    end

    return api
end)()

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
	runtime.Env.YslemSemiReport = function()
		return table.concat(semi.Log, "\n")
	end
	runtime.Env.S2rInstantStealReport = runtime.Env.YslemSemiReport
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

-- Delivery FPS dip: 50 / 40, respecting any lower user cap. Switches are 200 ms apart at <=200 ms ping;
-- otherwise it follows the ping (read once, when the dip starts). Only during the delivery.
local userFps = nil
local function restoreFps()
    if runtime.FpsChanged and typeof(setfpscap) == "function" then
        if pcall(setfpscap, userFps or 60) then runtime.FpsChanged = false end
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
    if not runtime.FpsChanged then
        userFps = nil
        if typeof(getfpscap) == "function" then
            local ok, cap = pcall(getfpscap)
            cap = ok and tonumber(cap) or nil
            if cap and cap == cap and cap >= 0 and cap < math.huge then userFps = cap end
        end
    end
	fpsGen += 1
	local mine = fpsGen
	runtime.spawn(function()
		local high = true
		local step = dipInterval()
		local started = os.clock()
        while alive and fpsGen == mine and os.clock() - started < 60 do
            local target = high and 50 or 40
            if userFps and userFps > 0 then target = math.min(target, userFps) end
            if pcall(setfpscap, target) then runtime.FpsChanged = true end
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
    local copied, copy = pcall(function() return character:Clone() end)
    character.Archivable = was
    if copied and copy then
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
            -- PlayerModule can yield while loading. Follow the current view
            -- owner when it returns, not the stale caller's requested state.
            if viewState then controls:Disable() else controls:Enable() end
		end
	end)
end

local function releaseView()
	local view = viewState
	if not view then
		return
	end
    viewState = nil
    runtime.cancel(view.Timer)
    for _, link in ipairs(view.DescendantLinks or {}) do
        pcall(function() link:Disconnect() end)
    end
	semi.Frozen = false
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
    for part, previous in pairs(view.HiddenOriginal or {}) do
        pcall(function() part.LocalTransparencyModifier = previous end)
    end
	for _, extra in ipairs(view.Extras) do
		pcall(function()
			extra.Inst.Enabled = extra.Prev
		end)
	end
    -- Each replacement camera has its own baseline. Do not overwrite a later
    -- camera owner that has already changed a property away from our value.
    for camera, previous in pairs(view.Cameras or {}) do
        pcall(function()
            if previous.AppliedType ~= nil and camera.CameraType == previous.AppliedType then
                camera.CameraType = previous.Type
            end
        end)
        pcall(function()
            if previous.AppliedSubject ~= nil and camera.CameraSubject == previous.AppliedSubject then
                local subject = previous.Subject
                if not subject or not subject.Parent then
                    subject = nil
                    if camera == workspace.CurrentCamera then
                        local character = localPlayer.Character
                        subject = character and character:FindFirstChildOfClass("Humanoid")
                    end
                end
                camera.CameraSubject = subject
            end
        end)
    end
	for _, copy in ipairs(view.Copies) do
		pcall(function()
			copy:Destroy()
		end)
	end
    -- Controls may load a module and yield; complete owned cleanup first
    -- so a new freeze always captures the real restored baselines.
    viewControls(true)
end

local function freezeView(character, offset, cameraCFrame, forced)
	local camera = workspace.CurrentCamera
    if not alive or viewState or not character or localPlayer.Character ~= character or not camera then
        return false
    end
	offset = offset or Vector3.zero
	local view = { Camera = camera, CameraType = camera.CameraType, CameraCFrame = cameraCFrame or camera.CFrame, Cameras = {}, Copies = {}, Hidden = {}, HiddenOriginal = {}, Parts = {}, Extras = {} }
    local function cameraBaseline(current)
        local previous = view.Cameras[current]
        if not previous then
            previous = { Type = current.CameraType, Subject = current.CameraSubject }
            view.Cameras[current] = previous
        end
        return previous
    end
    cameraBaseline(camera)
	viewState = view
	view.Forced = forced == true
	view.Follow = runtime.Env.YslemCamFollow ~= false
	if not view.Forced then
		view.Timer = runtime.delay(120, function()
			if viewState == view then
				releaseView()
			end
		end)
	end

    -- Track avatar changes once instead of rescanning the entire character
    -- twice every half second while the route is running.
    local partIndices, extraIndices = {}, {}
    local function addDescendant(d)
        if not alive or viewState ~= view then return end
        if d:IsA("BasePart") then
            if partIndices[d] then return end
            view.HiddenOriginal[d] = d.LocalTransparencyModifier
            view.Parts[#view.Parts + 1] = d
            partIndices[d] = #view.Parts
        elseif not extraIndices[d] and (d:IsA("BillboardGui") or d:IsA("SurfaceGui") or d:IsA("ParticleEmitter")
            or d:IsA("Trail") or d:IsA("Beam") or d:IsA("Highlight") or d:IsA("Fire")
            or d:IsA("Smoke") or d:IsA("Sparkles") or d:IsA("Light")) then
            local ok, enabled = pcall(function() return d.Enabled end)
            if ok then
                view.Extras[#view.Extras + 1] = { Inst = d, Prev = enabled }
                extraIndices[d] = #view.Extras
            end
        end
    end
    local function removeDescendant(d)
        if viewState ~= view then return end
        local at = partIndices[d]
        if at then
            local previous = view.HiddenOriginal[d]
            pcall(function()
                if d.LocalTransparencyModifier == (view.Follow and 0 or 1) then
                    d.LocalTransparencyModifier = previous
                end
            end)
            local last = view.Parts[#view.Parts]
            view.Parts[at] = last
            partIndices[last] = at
            view.Parts[#view.Parts] = nil
            partIndices[d], view.HiddenOriginal[d] = nil, nil
        end
        at = extraIndices[d]
        if at then
            local record = view.Extras[at]
            pcall(function() if d.Enabled == false then d.Enabled = record.Prev end end)
            local last = view.Extras[#view.Extras]
            view.Extras[at] = last
            extraIndices[last.Inst] = at
            view.Extras[#view.Extras] = nil
            extraIndices[d] = nil
        end
    end
    view.DescendantLinks = {
        character.DescendantAdded:Connect(addDescendant),
        character.DescendantRemoving:Connect(removeDescendant),
    }
    for _, d in ipairs(character:GetDescendants()) do addDescendant(d) end
    local lastScan = os.clock()

	local function tick()
        if not alive or viewState ~= view then return end
        -- A frozen view belongs to one character. Release its controls at the
        -- next render tick instead of waiting through the respawn grace period.
        if localPlayer.Character ~= character then
            releaseView()
            return
        end
		if os.clock() - lastScan > 0.5 then
			lastScan = os.clock()
			if view.Semi then
				hidePrompts(true)
			end

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
            if not live then return end
			if live ~= camera then
				camera = live
				view.Camera = live
                for _, copy in ipairs(view.Copies) do
                    pcall(function() copy.Parent = live end)
                end
			end
            local previous = cameraBaseline(camera)
			if view.Follow then
				local liveChar = localPlayer.Character
				local liveHum = liveChar and liveChar:FindFirstChildOfClass("Humanoid")
				if liveHum then
					if camera.CameraType ~= Enum.CameraType.Custom then
						camera.CameraType = Enum.CameraType.Custom
                        previous.AppliedType = Enum.CameraType.Custom
					end
					if camera.CameraSubject ~= liveHum then
						camera.CameraSubject = liveHum
                        previous.AppliedSubject = liveHum
					end
					return
				end
			end
			if camera.CameraType ~= Enum.CameraType.Scriptable then
				camera.CameraType = Enum.CameraType.Scriptable
                previous.AppliedType = Enum.CameraType.Scriptable
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
	-- Camera/visibility updates run once per rendered frame.

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

    if not alive or viewState ~= view or localPlayer.Character ~= character then
        if viewState == view then releaseView() end
        return false
    end
	view.Semi = true
	viewControls(false)
    -- A loading PlayerModule may have yielded through a respawn or cleanup.
    if not alive or viewState ~= view or localPlayer.Character ~= character then
        if viewState == view then releaseView() end
        return false
    end
	semi.Frozen = true
	return true
end

-- Auto Steal cancelled while frozen: the body first goes back to where the copy waits, then camera and controls return
local function releaseBackHome(home)
    local tripId, character = state.TripId, localPlayer.Character
	local frozen = viewState
	if not frozen then
		return
	end
	if typeof(home) ~= "Vector3" then
		releaseView()
		return
	end
	local started = os.clock()
	while os.clock() - started < 7 and alive and state.TripId == tripId and localPlayer.Character == character and viewState == frozen do
		local r = root()
		if not r or r.Position.Y < 5000 then
			break
		end
		RunService.Heartbeat:Wait()
	end
	for _ = 1, 10 do
		if not alive or state.TripId ~= tripId or localPlayer.Character ~= character or viewState ~= frozen then
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
	if alive and state.TripId == tripId and localPlayer.Character == character and viewState == frozen then
		releaseView()
	end
end

local function swapped()
	local character = localPlayer.Character
	return shield.Clone ~= nil and character ~= nil and shield.Clone.Parent == character
end

------------------------------------------------------------------ map helpers
local function lineInfo()
    -- A streamed/decorative World folder may coexist with the real map in
    -- __OBJECTS. Choose a complete physical boundary, not just its container.
    for _, name in ipairs({ "World", "__OBJECTS" }) do
        local container = workspace:FindFirstChild(name)
        local areas = container and container:FindFirstChild("Areas")
        local line = areas and areas:FindFirstChild("SeparationLine")
        if line and line:IsA("BasePart") then
            local position = line.Position
            local x, y = position and position.X, position and position.Y
            if type(x) == "number" and type(y) == "number" and x == x and y == y
                and math.abs(x) < math.huge and math.abs(y) < math.huge then return x, y end
        end
    end
    return 552.2, 67.67
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
    -- A late callback from the previous life must never reposition a new body.
    if not alive or (state.Busy and state.TripCharacter and localPlayer.Character ~= state.TripCharacter) then return end
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
local dangerCache, dangerAt = {}, -math.huge
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
            local half = Vector3.new(math.abs(size.X), math.abs(size.Y), math.abs(size.Z)) * 0.5
            -- Project each bounding-box axis separately; rotating one positive
            -- corner lets components cancel and underestimates diagonal portals.
            local right, up, look = cf.RightVector, cf.UpVector, cf.LookVector
            local rx = math.abs(right.X) * half.X + math.abs(up.X) * half.Y + math.abs(look.X) * half.Z
            local rz = math.abs(right.Z) * half.X + math.abs(up.Z) * half.Y + math.abs(look.Z) * half.Z
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
            -- Inline the two slab checks: no temporary axis tables each frame.
            local dx, dz = to.X - from.X, to.Z - from.Z
            if math.abs(dx) < 1e-6 then
                if from.X < x0 or from.X > x1 then hit = false end
            else
                local a, b = (x0 - from.X) / dx, (x1 - from.X) / dx
                if a > b then a, b = b, a end
                t0, t1 = math.max(t0, a), math.min(t1, b)
                if t0 > t1 then hit = false end
            end
            if hit then
                if math.abs(dz) < 1e-6 then
                    if from.Z < z0 or from.Z > z1 then hit = false end
                else
                    local a, b = (z0 - from.Z) / dz, (z1 - from.Z) / dz
                    if a > b then a, b = b, a end
                    t0, t1 = math.max(t0, a), math.min(t1, b)
                    if t0 > t1 then hit = false end
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
local function eggNow(uid, cache, nonBlocking)
    local function owned(request)
        return alive and not state.Cancel and state.TripId == request.TripId
            and localPlayer.Character == request.Character and root() == request.Root
    end
    local function finite(pos)
        return typeof(pos) == "Vector3" and pos.X == pos.X and pos.Y == pos.Y and pos.Z == pos.Z
            and math.abs(pos.X) < math.huge and math.abs(pos.Y) < math.huge and math.abs(pos.Z) < math.huge
    end
    local function remember(pos)
        if finite(pos) then
            cache.Pos, cache.Missing = pos, false
        elseif not state.SnapshotError then
            -- A successful snapshot that no longer lists this egg is different
            -- from a temporary networking failure. Do not chase its old floor.
            cache.Pos, cache.Missing = nil, true
        end
    end
    local pending = cache.Pending
    if pending and not owned(pending) then
        cache.Pending = nil
        runtime.cancel(pending.Thread)
    end
    if not alive or state.Cancel then return nil end
    local node = workspace:FindFirstChild(uid)
    local slots = workspace:FindFirstChild("AreaEggSlotsClient")
    node = node or (slots and slots:FindFirstChild(uid))
    if node then
        local ok, pos = pcall(function() return node:GetPivot().Position end)
        if ok and finite(pos) then
            cache.Generation = (cache.Generation or 0) + 1
            cache.Pos, cache.At, cache.Missing = pos, os.clock(), false
            return pos
        end
    end
    if not cache.Pending and os.clock() - (cache.At or 0) >= 0.5 then
        cache.At = os.clock()
        local request = { Character = localPlayer.Character, Root = root(), TripId = state.TripId, Generation = cache.Generation or 0 }
        if nonBlocking then
            cache.Pending = request
            local thread = runtime.spawn(function()
                local ok, pos = pcall(eggPosition, uid)
                if cache.Pending ~= request then return end
                cache.Pending = nil
                if not owned(request) or (cache.Generation or 0) ~= request.Generation then return end
                if ok then remember(pos) end
                cache.At = os.clock()
            end)
            request.Thread = thread
            if not thread and cache.Pending == request then cache.Pending = nil end
        else
            local ok, pos = pcall(eggPosition, uid)
            if not owned(request) then return nil end
            if (cache.Generation or 0) == request.Generation and ok then remember(pos) end
        end
    end
    return finite(cache.Pos) and cache.Pos or nil
end

local function holdStill()
	local character = localPlayer.Character
    local originalRoot = root()
    local tripId = state.TripId
	local function zero()
		if not alive or state.TripId ~= tripId or localPlayer.Character ~= character or root() ~= originalRoot then return end
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
			runtime.Holds[link] = true
		end
	end)
	return function()
		if link then
			runtime.Holds[link] = nil
			pcall(function()
				link:Disconnect()
			end)
		end
	end
end

local function ragdollWait()
    local character, tripId = localPlayer.Character, state.TripId
    local originalRoot = root()
	local seen = state.RagdollAt
	if not state.Ragdoll then return false end
	if type(seen) ~= "number" or seen ~= seen or os.clock() - seen >= 12 then
		state.Ragdoll = false
		return false
	end
	state.Hits = (state.Hits or 0) + 1
	status("Knocked down, staying still")
	local kb = state.RagdollArgs
	slog(string.format("hit by the guard (%d this trip): staying still until the ragdoll ends, knock-back %s", state.Hits, kb and string.format("%.0f,%.0f,%.0f", tonumber(kb[2]) or 0, tonumber(kb[3]) or 0, tonumber(kb[4]) or 0) or "?"))
	local release = holdStill()
	local stop = os.clock() + 8
	while alive and state.TripId == tripId and localPlayer.Character == character and root() == originalRoot and state.Ragdoll and os.clock() < stop and not state.Cancel do
		RunService.Heartbeat:Wait()
        if not alive or state.TripId ~= tripId or state.Cancel or localPlayer.Character ~= character or root() ~= originalRoot then break end
		local r = root()
		if r then
			pcall(function()
				r.AssemblyLinearVelocity = Vector3.zero
				r.AssemblyAngularVelocity = Vector3.zero
			end)
		end
	end
	release()
    if not alive or state.TripId ~= tripId or localPlayer.Character ~= character or root() ~= originalRoot then return false end
	state.Ragdoll = false
	local calm = 0
	while alive and state.TripId == tripId and localPlayer.Character == character and root() == originalRoot and calm < 0.15 and not state.Cancel do
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

    local routeTrip = state.TripId
    local originalRoot = root()
    local function valid()
        return alive and state.TripId == routeTrip and not state.Cancel and localPlayer.Character == character
            and originalRoot ~= nil and root() == originalRoot
    end
    if not valid() then return false end
    if state.Carrying then
        if state.Uid == nil and type(runtime.confirmCarry) == "function" then runtime.confirmCarry(uid) end
        return valid() and state.Uid == uid
    end
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
	-- Main-base staging applies only near the base floor. An interior can
    -- share the base's X range while being thousands of studs above/below it.
	if not opts.Field and math.abs(r.Position.Y - home.Y) <= 40 and r.Position.X < lineX - 2
        and Vector3.new(r.Position.X - home.X, 0, r.Position.Z - home.Z).Magnitude > 20 then
		stage = "safe"
	end

	local runY = egg.Y + 3
    local targetCache = { At = 0, Pos = egg }
    local refreshAt = 0
    local targetMissing = false
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
	while os.clock() - started < 120 and valid() do
		if ragdollWait() then
			started += 1
		end
		r = root()
		if not valid() or not r then
			return false
		end
        -- Area transitions and dropped eggs can move the target during a
        -- route. Refresh at 10 Hz; snapshot fallback stays asynchronous.
        if os.clock() >= refreshAt then
            local currentEgg = eggNow(uid, targetCache, true)
            refreshAt = os.clock() + 0.1
            if not valid() then return false end
            if currentEgg then egg, runY = currentEgg, currentEgg.Y + 3 end
            if targetCache.Missing then targetMissing = true;break end
        end
		local flatEgg = Vector3.new(egg.X - r.Position.X, 0, egg.Z - r.Position.Z)
        if state.Carrying then
            if state.Uid == nil and type(runtime.confirmCarry) == "function" then runtime.confirmCarry(uid) end
            break
        end
		if stage == "field" and flatEgg.Magnitude <= 2.5 and math.abs(r.Position.Y - runY) < 6 then
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
        if not valid() or state.Carrying then break end
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
		if stage == "field" and (egg - r.Position).Magnitude <= 9 and os.clock() - lastTake > 0.1 then
			lastTake = os.clock()
			runtime.spawn(takeEgg, uid)
		end
		RunService.Heartbeat:Wait()
	end

	r = root()
	if r and r == originalRoot and state.TripId == routeTrip and localPlayer.Character == character then
		pcall(function()
			r.AssemblyLinearVelocity = Vector3.new(0, r.AssemblyLinearVelocity.Y, 0)
			if humanoid then
				humanoid:Move(Vector3.zero, false)
			end
		end)
	end
    return valid() and ((state.Carrying and state.Uid == uid)
        or (not state.Carrying and not targetMissing and r ~= nil and (egg - r.Position).Magnitude <= 8))
end

-- take the egg that lies next to us (also used to take it back after the drop): follow it, fire its prompt and send the request
local function grab(uid, timeout)
    local character = localPlayer.Character

    local routeTrip = state.TripId
    local originalRoot = root()
    local function valid()
        return alive and state.TripId == routeTrip and not state.Cancel and localPlayer.Character == character
            and originalRoot ~= nil and root() == originalRoot
    end
    if not valid() then return false end
	local cache = { At = 0 }
	local deadline, since = os.clock() + timeout, 1
	while (not state.Carrying or state.Uid == nil) and os.clock() < deadline and valid() do
        if state.Carrying then
            if runtime.confirmCarry(uid) then break end
            -- Let the physical carry joint replicate without moving or issuing
            -- another pickup while the game says an unknown egg is in hand.
            RunService.Heartbeat:Wait()
            continue
        end
		local stillFrom = os.clock()
		if ragdollWait() then
			deadline += os.clock() - stillFrom
			since = 1
		end
		if not valid() then break end
        if state.Carrying then continue end
		local egg = eggNow(uid, cache, true)
		local dt = math.max(RunService.Heartbeat:Wait(), 1 / 240)
		local r = root()
		if not valid() or not r or os.clock() >= deadline then break end
        if state.Carrying then continue end
        if cache.Missing then break end
		since += dt
		if r and egg then
			local delta = egg - r.Position
			if delta.Magnitude > 2 then
				local pace = math.max(walkSpeed() * CFG.SpeedCap, 16)
                -- A live speed provider can yield; ownership and carry may
                -- change before it returns. Recheck before writing velocity.
                if not valid() or os.clock() >= deadline then break end
                if state.Carrying then continue end
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
                if prompt then runtime.firePrompt(prompt) end
                if not valid() or os.clock() >= deadline then break end
                if not state.Carrying then runtime.spawn(takeEgg, uid) end
			end
		elseif since >= CFG.GrabInterval then
			since = 0
			runtime.spawn(takeEgg, uid)
		end
	end
	local r = root()
	if r and r == originalRoot and state.TripId == routeTrip and localPlayer.Character == character then
		pcall(function()
			r.AssemblyLinearVelocity = Vector3.zero
		end)
	end
	return valid() and state.Carrying and state.Uid == uid
end

local function regrab(uid)
    local character, tripId = localPlayer.Character, state.TripId
    if not alive or state.Cancel or not root() then return false end
	if state.Carrying then
        if state.Uid == nil then return grab(uid, 3) end
		return state.Uid == uid
	end
	if state.Cancel or not root() then return false end
	local r = root()
	local egg = eggNow(uid, { At = 0 })
    if not alive or state.TripId ~= tripId or state.Cancel or localPlayer.Character ~= character or root() ~= r then return false end
    -- Snapshot lookup can finish after the game already gave us an egg.
    -- Confirm that carry before teleporting or starting another pickup.
    if state.Carrying then
        if state.Uid == nil then return grab(uid, 3) end
        return state.Uid == uid
    end
	local gap = r and egg and (r.Position - egg).Magnitude or 0
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
local function tpHome(lineX, laneZ, started, uid)
    uid = uid or state.TargetUid or state.Uid
    local character = localPlayer.Character
    local originalRoot = root()

    local routeTrip = state.TripId
    local function valid()
        return alive and state.TripId == routeTrip and not state.Cancel and localPlayer.Character == character and originalRoot ~= nil and root() == originalRoot
            and type(uid) == "string" and uid ~= ""
            and (not state.Carrying or state.Uid == uid)
    end
    if not valid() then return false end
    local originalDrop = dropEgg
    local function dropEgg()
        if valid() and state.Carrying and state.Uid == uid then return originalDrop() end
    end
	local home = homePoint()
	local steps = { Vector3.new(lineX - 7, home.Y, laneZ), home }
	status("Safe zone: teleporting")
	for _, target in ipairs(steps) do
		local tries = 0
		while state.Carrying and state.Delivered < started and valid() and tries < 3 do
			tries += 1
			local pulledBefore = state.PulledAt
			local held = 0
			while held < math.max(CFG.HopGap, 0.1) and valid() and root() do
				place(target)
				held += RunService.Heartbeat:Wait()
			end
			local check = root()
			local pulled = state.PulledAt > pulledBefore or (check ~= nil and (check.Position - target).Magnitude > 10)
			if not pulled then
				break
			end
		end
	end
	local waited = 0
	while state.Carrying and state.Delivered < started and valid() and waited < 1 do
		waited += RunService.Heartbeat:Wait()
	end
	if state.Carrying and state.Delivered < started and valid() then
		local at = root()
		if at and Vector3.new(at.Position.X - home.X, 0, at.Position.Z - home.Z).Magnitude > 6 then
			place(home)
			RunService.Heartbeat:Wait()
		end
		if not valid() then return false end
		local atHome = root()
		if not atHome or (atHome.Position - home).Magnitude > 15 then return false end
		status("Safe zone: dropping the egg on the base")
		dropEgg()
		local confirm = 0
		while state.Delivered < started and confirm < 1 and valid() do
			confirm += RunService.Heartbeat:Wait()
		end
	end
	return valid() and state.Delivered >= started
end

local function runHome(lineX, laneZ, uid)
    uid = uid or state.TargetUid or state.Uid
	local started = os.clock()
	local home = homePoint()
	local checkpoint = lineX - 7
	local height = semi.SlowRun and 0 or CFG.Height
	local share = math.clamp(CFG.ClimbShare, 0.1, 0.9)
	local descent = height * math.sqrt(1 - share * share) / share
	local character = localPlayer.Character
    local originalRoot = root()

    local routeTrip = state.TripId
    local function valid()
        return alive and state.TripId == routeTrip and not state.Cancel and localPlayer.Character == character and originalRoot ~= nil and root() == originalRoot
            and type(uid) == "string" and uid ~= ""
            and (not state.Carrying or state.Uid == uid)
    end
    if not valid() then return false end
    local originalDrop = dropEgg
    local function dropEgg()
        if valid() and state.Carrying and state.Uid == uid then return originalDrop() end
    end
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if state.TripId == routeTrip and root() == originalRoot and humanoid then
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
	while state.Carrying and state.Delivered < started and valid() and timeout < 25 do
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
		if toHome and (home - r.Position).Magnitude < 4 then
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

    if state.TripId == routeTrip and localPlayer.Character == character and root() == originalRoot then
        local stopped = root()
        if stopped then
            pcall(function() stopped.AssemblyLinearVelocity = Vector3.zero end)
        end
    end
	if state.TripId == routeTrip and root() == originalRoot and humanoid then
		pcall(function()
			humanoid:Move(Vector3.zero, false)
		end)
	end

	local settle = 0
	while settle < 2 and state.Delivered < started and state.Carrying and valid() do
		settle += RunService.Heartbeat:Wait()
	end
	-- still in the hands at home: put it down so the base takes it
	if state.Carrying and state.Delivered < started and valid() then
		task.wait(0.2)
		if not valid() then return false end
		if state.Delivered >= started then return true end
		local atHome = root()
		if not atHome or (atHome.Position - home).Magnitude > 15 then
			return false
		end
		dropEgg()
		local waited = 0
		while state.Delivered < started and waited < 1 and valid() do
			waited += RunService.Heartbeat:Wait()
		end
	end
	return valid() and state.Delivered >= started
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

local function treadmillMounted(timeout, expectedRemote)
	local snapshot = expectedRemote or remote("RF/Treadmill/AskRenderSnapshot")
	if not snapshot or not snapshot:IsA("RemoteFunction")
        or remote("RF/Treadmill/AskRenderSnapshot") ~= snapshot then return nil end
	local ok, ids = runtime.invoke(snapshot, timeout or 4)
	if not ok or type(ids) ~= "table" or remote("RF/Treadmill/AskRenderSnapshot") ~= snapshot then return nil end
    -- An error envelope or an unknown payload is not evidence of dismounting.
    if ids.Success == false or ids.success == false then return nil end
    local function userKey(value)
        if type(value) ~= "number" and type(value) ~= "string" then return nil end
        local number = tonumber(value)
        if not number or number ~= number or math.abs(number) == math.huge or number % 1 ~= 0 or number == 0 then return nil end
        return tostring(number)
    end
    local function activeRecord(record)
        -- Preserve the existing ID-record format, but never override an explicit
        -- negative mounted/active flag just because the record itself is truthy.
        for _, key in ipairs({"Mounted", "mounted", "IsMounted", "isMounted", "Active", "active"}) do
            if record[key] == false then return false end
        end
        return true
    end
    local userId, mounted, unmounted, unknown = userKey(localPlayer.UserId), false, false, false
    for key, value in pairs(ids) do
        local valueId = userKey(value)
        if type(value) == "boolean" and userKey(key) then
            if userKey(key) == userId then
                if value then mounted = true else unmounted = true end
            end
        elseif valueId and type(key) == "number" and key >= 1 and key % 1 == 0 then
            if valueId == userId then mounted = true end
        elseif type(value) == "table" then
            local recordId = userKey(value.UserId or value.userId or value.Id)
            if recordId and userKey(key) then
                if recordId == userId then
                    if activeRecord(value) then mounted = true else unmounted = true end
                end
            else
                -- A keyed record without an ID needs a boolean membership flag.
                local flag = value.Mounted
                if flag == nil then flag = value.mounted end
                if flag == nil then flag = value.IsMounted end
                if flag == nil then flag = value.isMounted end
                if flag == nil then flag = value.Active end
                if flag == nil then flag = value.active end
                if userKey(key) and type(flag) == "boolean" then
                    if userKey(key) == userId then
                        if flag and activeRecord(value) then mounted = true else unmounted = true end
                    end
                else unknown = true end
            end
        else unknown = true end
    end
    -- Duplicate entries must agree; iteration order cannot select a winner.
    if unknown or (mounted and unmounted) then return nil end
    return mounted
end

-- Each reset phase shares a four-second remote budget; quick retries keep the 0.7 s window.
local function treadmillReset()
	local character, startRoot = localPlayer.Character, root()
	local routeTrip = state.TripId
	local function valid()
		return alive and state.TripId == routeTrip and not state.Cancel and localPlayer.Character == character
			and startRoot ~= nil and root() == startRoot
	end
	if not valid() then return false end
	local wear = remote("RF/Treadmill/AskWearStill")
	local doff = remote("RF/Treadmill/AskDoff")
    local snapshot = remote("RF/Treadmill/AskRenderSnapshot")
    local function sameRemote(event)
        local name = event == wear and "RF/Treadmill/AskWearStill" or "RF/Treadmill/AskDoff"
        return remote(name) == event and remote("RF/Treadmill/AskRenderSnapshot") == snapshot
    end
    -- Requiring PlotState or resolving its folders can yield before any remote
    -- deadline starts. Give each lookup its own request identity and deadline.
    local standOk, stand = runtime.call({}, 4, treadmillStand)
	if not (standOk and wear and wear:IsA("RemoteFunction") and doff and doff:IsA("RemoteFunction")
        and snapshot and snapshot:IsA("RemoteFunction") and stand) or not valid()
        or not sameRemote(wear) or not sameRemote(doff) then
		slog("treadmill reset: not available (remote or stand missing)")
		return false
	end
	place(stand)
	local function pause(t, deadline)
		local untilAt = math.min(os.clock() + t, deadline or math.huge)
		while os.clock() < untilAt and valid() do
			RunService.Heartbeat:Wait()
		end
		return valid()
	end
	if not pause(0.15) then return false end
	local function phase(event, expected)
		local retryUntil, deadline = os.clock() + 0.7, os.clock() + 4
		while valid() and os.clock() < retryUntil do
            if not sameRemote(event) then return false end
			local ok, accepted = runtime.invoke(event, deadline - os.clock())
			if not valid() or not sameRemote(event) then return false end
			if not ok or accepted == false or (type(accepted) == "table"
                and (accepted.Success == false or accepted.success == false)) then return false end
			if not pause(0.08, deadline) or os.clock() >= deadline then return false end
			local confirmed = treadmillMounted(deadline - os.clock(), snapshot)
			if not valid() or not sameRemote(event) then return false end
			if confirmed == expected and os.clock() <= deadline then return true end
		end
		return false
	end
	local mounted = phase(wear, true)
	if not valid() then return false end
	if mounted and not pause(0.25) then return false end
	-- A timed-out wear can still have reached the server, so always try to dismount.
	local released = phase(doff, false)
	slog(string.format("treadmill reset: worn=%s, taken off=%s", tostring(mounted), tostring(released)))
	return valid() and mounted and released
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
    local character = localPlayer.Character
    local originalRoot = root()

    local routeTrip = state.TripId
    local function valid()
        return alive and state.TripId == routeTrip and not state.Cancel and localPlayer.Character == character and originalRoot ~= nil and root() == originalRoot
            and type(uid) == "string" and uid ~= ""
            and (not state.Carrying or state.Uid == uid or (state.Uid == nil and runtime.confirmCarry(uid)))
    end
    if not valid() then return false end
    local originalPlace = place
    local function place(position)
        if valid() then originalPlace(position) end
    end
	local function held()
		return valid() and state.Carrying and state.Uid == uid
	end
	local function wait(t)
		local w = 0
		while w < t and valid() do
			w += RunService.Heartbeat:Wait()
		end
	end
	local function flatAway(a, b)
		return Vector3.new(a.X - b.X, 0, a.Z - b.Z).Magnitude
	end
	local safe = Vector3.new(RELAY_SAFE.X, groundY(RELAY_SAFE, RELAY_SAFE.Y), RELAY_SAFE.Z)
	local function finish()
        if not alive or state.TripId ~= routeTrip or localPlayer.Character ~= character then return end
		clown.At = nil
		if semiFrozen and typeof(semi.Home) == "Vector3" and root() and valid() then
			status("Relay: the clown goes back to the player")
			place(semi.Home)
			wait(0.3)
		end
        if not alive or state.TripId ~= routeTrip or localPlayer.Character ~= character then return end
		releaseCamera()
		if semiFrozen then
			releaseView()
		end
        if not alive or state.TripId ~= routeTrip or localPlayer.Character ~= character then return end
		dropClone()
	end

	local burst
	local function ragdollGuard(around)
		local seen = state.RagdollAt
		if not state.Ragdoll then return false end
		if type(seen) ~= "number" or seen ~= seen or os.clock() - seen >= 12 then
			state.Ragdoll = false
			return false
		end
		status("Relay: knocked down, staying still")
		slog(string.format("Relay: ragdolled %.2f s after the pickup, holding still, carrying=%s", os.clock() - (state.CarryAt or seen), tostring(held())))
		local release = holdStill()
		local stop = os.clock() + 8
		while state.Ragdoll and os.clock() < stop and valid() do
			RunService.Heartbeat:Wait()
            if not valid() then break end
			local r = root()
			if r then
				pcall(function()
					r.AssemblyLinearVelocity = Vector3.zero
					r.AssemblyAngularVelocity = Vector3.zero
				end)
			end
		end
		release()
        if not valid() then return false end
		state.Ragdoll = false
		wait(0.15)
		slog(string.format("Relay: ragdoll over after %.2f s, carrying=%s", os.clock() - seen, tostring(held())))
		if not held() and valid() then
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
		while os.clock() < deadline and valid() do
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
			local paceGap = math.min(flat.Magnitude, hopStep) / math.max(walkSpeed() * (tonumber(runtime.Env.YslemPaceRatio) or RELAY_PACE_RATIO), 200)
			local holdFor = math.max(gap, paceGap)
			while held2 < holdFor and valid() and not state.Ragdoll do
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
		while os.clock() < stop and held() and valid() and not (state.DeliveryFailedAt and state.DeliveryFailedAt > firstPick) do
			local r = root()
			if r and pinAt and (r.Position - pinAt).Magnitude > 2.5 then
				place(pinAt)
			end
			RunService.Heartbeat:Wait()
		end
	end

	burst = function(seconds, around)
        local burstRoot = root()
        local ownerValid = valid
        local function valid() return ownerValid() and burstRoot ~= nil and root() == burstRoot end
		local cache = { At = 0, Pos = around }
		local deadline, since = os.clock() + seconds, 1
		while not held() and os.clock() < deadline and valid() do
            -- Do not move or fire another pickup while a carried egg
            -- is unidentified, and never replace a known different egg.
            if state.Carrying then
                if state.Uid ~= nil then return false end
                if runtime.confirmCarry(uid) then break end
                RunService.Heartbeat:Wait()
                continue
            end
			if state.Ragdoll and state.RagdollAt and os.clock() - state.RagdollAt < 12 then
				local pauseAt = os.clock()
				RunService.Heartbeat:Wait()
				deadline += os.clock() - pauseAt
				continue
			end
			local egg = eggNow(uid, cache, true) or around
			local dt = math.max(RunService.Heartbeat:Wait(), 1 / 240)
			local r = root()
			if not valid() or held() or not r or os.clock() >= deadline then break end
            if state.Carrying then continue end
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
					if prompt then runtime.firePrompt(prompt) end
					if not valid() or os.clock() >= deadline then break end
					if not state.Carrying then runtime.spawn(takeEgg, uid) end
				end
			end
		end
		return valid() and held()
	end

	if not held() then
		status("Relay: confirming the carry")
		local synced = 0
		while not held() and synced < 2.5 and valid() do
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
		local lane = tonumber(runtime.Env.YslemDodgeLane) or DODGE_LANE_Z
		local cruiseY = tonumber(runtime.Env.YslemDodgeY) or DODGE_Y
		local dropPos = DODGE_DROP_POINT
		local r0 = root()
		if not r0 or not valid() then finish(); return false end
		local startX = r0.Position.X
		local totalDist = math.abs(startX - dropX)
		slog(string.format("Dodge: %.0f studs from x=%.0f to the drop x=%.1f on lane z=%.1f y=%.0f, %.2f s after the pickup", totalDist, startX, dropX, lane, cruiseY, firstPick and (os.clock() - firstPick) or -1))
		status("Dodge: running the chain")
		progress(0.5, "Carrying the egg")
		local dir = startX > dropX and -1 or 1
		local travelled = 0
		local pulls = 0
		local lastPulled = state.PulledAt
		local chainStart = os.clock()
		local firstFrame = true
		local chainOk = true
		while travelled < totalDist and valid() do
			local dt = firstFrame and 0 or math.min(RunService.Heartbeat:Wait(), 0.1)
			if not valid() or not root() then chainOk = false; break end
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
			if state.PulledAt > lastPulled then
				lastPulled = state.PulledAt
				pulls += 1
				slog(string.format("Dodge: the server pulled us back at %.0f studs (%d)", travelled, pulls))
				if pulls > 3 then
					chainOk = false
					break
				end
			end
		end
		slog(string.format("Dodge: chain done=%s in %.2f s", tostring(chainOk and travelled >= totalDist), os.clock() - chainStart))
		if not chainOk or not valid() or not held() then
			status("Dodge: the chain was interrupted")
			finish()
			return false
		end
		status("Dodge: at the drop spot")
		progress(0.65, "At the drop spot")
		local holdEnd = os.clock() + DODGE_DROP_WAIT
		local minDrop = tonumber(runtime.Env.YslemDodgeMinDrop) or DODGE_MIN_DROP
		if firstPick then
			holdEnd = math.max(holdEnd, firstPick + minDrop)
		end
		slog(string.format("Dodge: at the drop spot %.2f s after the pickup, holding until %.2f s", os.clock() - (firstPick or os.clock()), holdEnd - (firstPick or os.clock())))
		while os.clock() < holdEnd and valid() and held() do
			place(dropPos)
			RunService.Heartbeat:Wait()
		end
		local released = false
		for attempt = 1, 4 do
			if not held() or not valid() then
				break
			end
			local rr = root()
			if rr and (rr.Position - dropPos).Magnitude > 1 then
				place(dropPos)
			end
			local settleUntil = os.clock() + (attempt == 1 and 0 or math.max(0.15, 2 * netPing()))
			while os.clock() < settleUntil and valid() and held() do
				place(dropPos)
				RunService.Heartbeat:Wait()
			end
			if not held() then
				break
			end
			slog(string.format("Dodge: drop button (try %d) %.2f s after the pickup, RunBackWakeDelayRequired=%s", attempt, os.clock() - (firstPick or os.clock()), tostring(state.WakeReq)))
            if not valid() then finish(); return false end
			dropEgg()
			local dropUntil = os.clock() + 0.3
			while held() and os.clock() < dropUntil and valid() do
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
		local pollBy = os.clock() + 3
		local dropCache = { At = 0 }
		while os.clock() < pollBy and valid() do
			dropAt = eggNow(uid, dropCache, true)
			if dropAt then
				break
			end
			place(dropPos)
			wait(0.1)
		end
        if not valid() then finish(); return false end
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
        if not okTread and valid() then
            status("Dodge: treadmill reset retry")
            wait(0.25)
            if not valid() then finish(); return false end
            okTread = treadmillReset()
        end
        slog(string.format("Dodge: treadmill before the regrab done=%s, %.2f s after the drop", tostring(okTread), os.clock() - droppedAt))
        if not okTread then
            status("Treadmill reset failed")
            finish()
            return false
        end
        if not valid() then finish(); return false end
		local back = clown.At or dropPos
		slog(string.format("Dodge: re-teleport to the clown at %.1f %.1f %.1f", back.X, back.Y, back.Z))
		place(back)
		local regrabEnd = droppedAt + DODGE_REGRAB_WAIT
		while os.clock() < regrabEnd and valid() do
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
		if not got and valid() then
			local again = eggNow(uid, { At = 0 }) or dropAt
			if again then
				place(again + Vector3.new(0, 3.2, 0))
			end
			got = burst(2.5, again or dropAt or back)
		end
		if not got and valid() then
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
        if not valid() then finish(); return false end
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
			while valid() and state.Delivered < started and os.clock() < runEnd and held() do
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
				if toBank.Magnitude < 2 and math.abs(bank.Y - rr.Position.Y) < 6 then
					break
				end
				local aim = avoid(rr.Position, bank)
				local flat = Vector3.new(aim.X - rr.Position.X, 0, aim.Z - rr.Position.Z)
				local waypointDistance = flat.Magnitude > 0.01 and flat.Magnitude or toBank.Magnitude
				local stepLen = math.min(DODGE_CRUISE_SPEED * dtRun, toBank.Magnitude, waypointDistance)
				local dir2 = flat.Magnitude > 0.01 and flat.Unit or (toBank.Magnitude > 0.01 and toBank.Unit or Vector3.zero)
				place(Vector3.new(rr.Position.X + dir2.X * stepLen, bank.Y, rr.Position.Z + dir2.Z * stepLen))
				RunService.Heartbeat:Wait()
			end
			pcall(function()
				local rr = root()
				if rr and valid() then
					rr.AssemblyLinearVelocity = Vector3.zero
				end
			end)
		end
		local verdictBy = os.clock() + 4
		while valid() and state.Delivered < started and os.clock() < verdictBy do
			RunService.Heartbeat:Wait()
		end
		slog(string.format("Dodge: verdict=%s %.2f s after the pickup", tostring(state.Delivered >= started), os.clock() - (firstPick or os.clock())))
	end
	status("Relay: waiting for the deposit")
	local depositBy = os.clock() + 8
	while valid() and state.Delivered < started and os.clock() < depositBy do
		if state.Ragdoll and ragdollGuard(nil) then
			depositBy = os.clock() + 8
		end
		wait(0.1)
	end
	slog(string.format("Relay: banked=%s", tostring(state.Delivered >= started)))
	if valid() and state.Delivered < started and firstPick and state.DeliveryFailedAt and state.DeliveryFailedAt > firstPick then
		semi.WakeWait = math.min(15, semi.WakeWait + 2.5)
		slog(string.format("Relay: the server refused the delivery %.1f s after the pickup, next try waits %.1f s", state.DeliveryFailedAt - firstPick, semi.WakeWait))
	end
	if state.Delivered < started and held() and valid() then
		local lineX, _, _ = lineInfo()
		local r = root()
		local laneZ = r and math.clamp(r.Position.Z, -425, -300) or -364
		slog("Relay: no deposit from the safe zone, running home")
		local wasSlow = semi.SlowRun
		semi.SlowRun = true
		local okHome = runHome(lineX, laneZ, uid)
        if not alive or state.TripId ~= routeTrip or localPlayer.Character ~= character then return false end
		semi.SlowRun = wasSlow
		finish()
		return okHome
	end
	finish()
	return valid() and state.Delivered >= started
end

local function instantTP(uid)
    local character = localPlayer.Character
    local originalRoot = root()

    local routeTrip = state.TripId
    local original_dropClone = dropClone
    local function dropClone(...)
        if alive and state.TripId == routeTrip and localPlayer.Character == character then
            return original_dropClone(...)
        end
    end
    local original_fpsOff = fpsOff
    local function fpsOff(...)
        if alive and state.TripId == routeTrip and localPlayer.Character == character then
            return original_fpsOff(...)
        end
    end
    local original_releaseView = releaseView
    local function releaseView(...)
        if alive and state.TripId == routeTrip and localPlayer.Character == character then
            return original_releaseView(...)
        end
    end
    local function valid()
        return alive and state.TripId == routeTrip and not state.Cancel and localPlayer.Character == character and originalRoot ~= nil and root() == originalRoot
            and type(uid) == "string" and uid ~= ""
            and (not state.Carrying or state.Uid == uid)
    end
    if not valid() then return false end
    local originalDrop = dropEgg
    local function dropEgg()
        if valid() and state.Carrying and state.Uid == uid then return originalDrop() end
    end
    local originalPlace = place
    local function place(position)
        if valid() then originalPlace(position) end
    end
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
	local releaseCameraOriginal = semiFrozen and function() end or frozenCamera()
    local function releaseCamera()
        if alive and state.TripId == routeTrip and localPlayer.Character == character then releaseCameraOriginal() end
    end
	state.ReleaseCamera = releaseCameraOriginal
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

	while x - hopStep > landing.X and valid() do
		if not state.Carrying then
			-- the server let go of the egg on the way: take it back right away
			if not regrab(uid) then
				break
			end
			local current = root()
			if current and valid() then
				x = math.min(x, current.Position.X)
			end
			continue
		end

		local nextX = x - hopStep
		status(string.format("Instant TP: hopping home, X %d", math.floor(nextX)))
		local pulledBefore = state.PulledAt
		local held = 0
		while held < CFG.HopGap and valid() and root() do
			place(Vector3.new(nextX, hopY, hopZ))
			held += RunService.Heartbeat:Wait()
		end

		local check = root()
		local pulled = state.PulledAt > pulledBefore or (check ~= nil and (check.Position.X - nextX > 10 or check.AssemblyLinearVelocity.Magnitude > 150))
		if pulled and state.Carrying and valid() then
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
			while settle < 0.12 and valid() do
				place(Vector3.new(x, hopY, hopZ))
				settle += RunService.Heartbeat:Wait()
			end
		else
			x = nextX
			CFG.HopGap = math.max(CFG.HopGapMin, CFG.HopGap - 0.01)
		end
	end

	if not valid() or not root() then
		releaseCamera()
		dropClone()
		fpsOff()
		return false
	end
	-- landing in front of the line
	status("Instant TP: landing next to the line")
	landing = Vector3.new(landing.X, groundY(landing, landing.Y), landing.Z)
	local function onSpot()
		local current = root()
		return valid() and current ~= nil and current.Position.X <= landing.X + 12 and math.abs(current.Position.Y - landing.Y) <= 10
            and math.abs(current.Position.Z - landing.Z) <= 12
	end
	local function land()
        if not valid() then return end
		local current = root()
		-- never jump backwards: if we are already on the landing spot, stay
		if current and current.Position.X <= landing.X + 1 and math.abs(current.Position.Y - landing.Y) <= 10
            and math.abs(current.Position.Z - landing.Z) <= 10 then
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
		while settle < CFG.LandSettle and valid() do
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
	if state.Carrying and valid() then
		local delay = 0
		while delay < CFG.DropDelay and valid() do
			delay += RunService.Heartbeat:Wait()
		end
		if state.Carrying and valid() and not onSpot() then
			land()
			local settle = 0
			while settle < CFG.LandSettle and valid() do
				settle += RunService.Heartbeat:Wait()
			end
		end
		if not state.Carrying or not valid() then
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
				while state.Carrying and waited < 0.8 and valid() do
					waited += RunService.Heartbeat:Wait()
				end
				if not state.Carrying or not valid() then
					break
				end
				status("Instant TP: the drop was not confirmed, trying again")
				if not onSpot() then
					land()
				end
			end
			local current = root()
			if current and valid() then
				pcall(function()
					current.AssemblyLinearVelocity = Vector3.zero
					current.AssemblyAngularVelocity = Vector3.zero
				end)
			end
			-- the server may send a dropped egg straight back to its nest: then there is nothing to take back, and no long teleport to chase it
			local dropSpot = root()
			if dropSpot and valid() then
				local looked = 0
				while looked < 0.25 and valid() do
					looked += RunService.Heartbeat:Wait()
				end
				local lies = eggNow(uid, { At = 0 })
                if not valid() then return false end
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
			if not valid() then return false end
            local tookBack = grab(uid, 3) or (valid() and regrab(uid))
			for _ = 1, 3 do
				if tookBack or not valid() then
					break
				end
				status("Instant TP: the egg is not in the hands yet, trying again")
				tookBack = regrab(uid) or (valid() and grab(uid, 2))
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
        if not valid() then return false end
		if semiEnd then
			for round = 1, 2 do
				if tpHome(lineX, laneZ, started, uid) then
					return true
				end
				if not state.Carrying or not valid() then
					return state.Delivered >= started
				end
				status(string.format("Instant TP: teleport home again (%d/2)", round))
			end
		end
		return runHome(lineX, laneZ, uid)
	end
	if state.Carrying then
		ok = goHome()
	end
	local again = 0
	while not ok and state.Delivered < started and valid() and again < 2 do
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
	return valid() and (ok or state.Delivered >= started)
end

-- after a failed Semi TP: the body goes back to the front of the base by itself (hops like the delivery)
local function returnFront()
    local character = localPlayer.Character
    local originalRoot = root()

    local routeTrip = state.TripId
    local function valid()
        return alive and state.TripId == routeTrip and not state.Cancel and localPlayer.Character == character and originalRoot ~= nil and root() == originalRoot
    end
    if not valid() then return false end
	local reached = false
	pcall(function()
		local waited = 0
		while root() and root().Position.Y > 5000 and waited < 8 and valid() do
			waited += RunService.Heartbeat:Wait()
		end
		local r = root()
		if not r or not valid() then
			return
		end
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
		while x - frontX > hopStep and valid() do
			local nextX = x - hopStep
			local pulledBefore = state.PulledAt
			local held = 0
			while held < gap and valid() do
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
				while settle < 0.12 and valid() do
					place(Vector3.new(x, hopY, hopZ))
					settle += RunService.Heartbeat:Wait()
				end
			else
				x = nextX
			end
		end
		if not valid() then
			return
		end
		for _, target in ipairs({ Vector3.new(frontX, home.Y, hopZ), home }) do
			local held = 0
			while held < math.max(gap, 0.1) and valid() do
				place(target)
				held += RunService.Heartbeat:Wait()
			end
		end
		local settle = 0
		while settle < 0.4 and valid() do
			settle += RunService.Heartbeat:Wait()
		end
		local at = root()
		reached = valid() and at ~= nil and (at.Position - home).Magnitude <= 20
	end)
	return reached
end

------------------------------------------------------------------ Semi TP: portal by touch (the only route, no alternative)
-- Returns true plus { Arrived, Ratio, Decoy } or false plus the reason. The player stays frozen (copy + camera) while the body works.
local function semiGo(uid, egg)
	local startRoot = root()
	if not alive or state.Cancel or not startRoot then
		return false, "Semi TP: no character yet"
	end
	local character = localPlayer.Character
	local routeTrip = state.TripId
    local original_releaseView = releaseView
    local function releaseView(...)
        if alive and state.TripId == routeTrip and localPlayer.Character == character then
            return original_releaseView(...)
        end
    end
	local function valid()
		return alive and state.TripId == routeTrip and not state.Cancel and localPlayer.Character == character and root() == startRoot
	end
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local startCF = startRoot.CFrame
	local cache = { At = 0, Pos = egg }
	local function eggPos()
        local current = eggNow(uid, cache, true)
        -- A successful snapshot can prove removal; transport failures cannot.
        if cache.Missing then return nil end
        return current or egg
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

    -- Decoy uses a ground-only approach. An egg on another nearby floor
    -- needs the existing verified Dodge landing, even at the same X/Z.
	if (egg - startRoot.Position).Magnitude <= 60
        and math.abs(startRoot.Position.Y - (egg.Y + 3)) < 6 then
		-- egg next to us: no portal. The copy waits at home, the body runs to the egg and brings it back.
		semi.Kind = "decoy"
		semi.AtDrop = true
		local spotAt = startRoot.Position
		local okFreeze = freezeView(character, Vector3.zero, nil)
		if not valid() then releaseView(); return false, "Semi TP: cancelled or no character" end
		semi.Home = okFreeze and spotAt or nil
		slog("egg close: decoy at home, frozen=" .. tostring(okFreeze))
		return true, { Decoy = true }
	end

	semi.Kind = "semi"
	semi.AtDrop = true
	for _ = 1, 3 do
		RunService.Heartbeat:Wait()
	end
	if not valid() then return false, "Semi TP: cancelled or no character" end
	local shieldSince = os.clock()
	while not swapped() and os.clock() - shieldSince < 5 and valid() do
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
	if not valid() then return false, "Semi TP: cancelled or no character" end
	slog(string.format("shield=%s after %.2f s", tostring(swapped()), os.clock() - shieldSince))
	local safeStand = Vector3.new(RELAY_SAFE.X, groundY(RELAY_SAFE, RELAY_SAFE.Y), RELAY_SAFE.Z)
	local atNow = root()
	local lineNow = lineInfo()
    -- This becomes semi.Home, the delivery bank: matching X/Z alone must
    -- not freeze that destination on an upper or lower interior floor.
	local needMove = atNow and (atNow.Position - safeStand).Magnitude > 3
	if needMove then
		if atNow.Position.X > lineNow + 100 then
			status("Semi TP: hopping back to the base first")
			returnFront()
			if not valid() then
				return false, "cancelled"
			end
		end
		status("Semi TP: going to the safe-zone point")
		place(safeStand)
		for _ = 1, 8 do
			if not valid() then return false, "Semi TP: cancelled or no character" end
			RunService.Heartbeat:Wait()
		end
		if not valid() then return false, "Semi TP: cancelled or no character" end
		pcall(function()
			local r1 = root()
			if r1 then
				r1.AssemblyLinearVelocity = Vector3.zero
				r1.AssemblyAngularVelocity = Vector3.zero
			end
		end)
	end
	if not valid() then return false, "Semi TP: cancelled or no character" end
	local freezeAt = root()
	local freezeSpot = freezeAt and freezeAt.Position or safeStand
	local function freezeNow()
		return freezeView(character, Vector3.zero, CFrame.new(freezeSpot + camOffset) * camRot)
	end
	local okFreeze = freezeNow()
    if not valid() then releaseView(); return false, "Semi TP: cancelled or no character" end
	if not okFreeze then
		releaseView()
		if not valid() then return false, "Semi TP: cancelled or no character" end
		okFreeze = freezeNow()
	end
    if not valid() then releaseView(); return false, "Semi TP: cancelled or no character" end
	semi.Home = okFreeze and freezeSpot or nil
	slog("player frozen at the safe-zone point = " .. tostring(okFreeze))
	for _ = 1, 6 do
		if not valid() then releaseView(); return false, "Semi TP: cancelled or no character" end
		RunService.Heartbeat:Wait()
	end
	if not valid() then releaseView(); return false, "Semi TP: cancelled or no character" end
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
				groundSkip = {}
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
            -- The active egg can be a part or use a non-32-character UID.
            -- Its collision surface and a newly replaced clone are not ground.
            local target = workspace:FindFirstChild(uid)
            if target then list[#list + 1] = target end
            if stealClone then list[#list + 1] = stealClone end
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
				if hit.Material ~= Enum.Material.Water and hit.Instance.CanCollide then
					found = hit.Position
					break
				end
				origin = hit.Position - Vector3.new(0, 0.05, 0)
			end
		end)
		return found
	end
	local function standHeight()
        -- Accessories can extend a model's bounding box below its feet. Match
        -- the rig's root-to-floor offset before using a model-box fallback.
        local h = 3
        local character2, r = localPlayer.Character, root()
        local ok, exact = pcall(function()
            local hum = character2 and character2:FindFirstChildOfClass("Humanoid")
            if not hum or not r then return nil end
            return r.Size.Y * 0.5 + (hum.RigType == Enum.HumanoidRigType.R6 and 2 or hum.HipHeight)
        end)
        if ok and type(exact) == "number" and exact > 1 and exact < 12 then
            return exact + 0.05
        end
        pcall(function()
            if character2 and r then
                local box, boxSize = character2:GetBoundingBox()
                local value = r.Position.Y - (box.Position.Y - boxSize.Y / 2)
                if value > 1 and value < 12 then h = value end
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
        local side = Vector3.new(-dir.Z, 0, dir.X)
        local diagonal = math.sqrt(0.5)
        local directions = {
            dir, dir * -1, side, side * -1,
            (dir + side) * diagonal, (dir - side) * diagonal,
            (side - dir) * diagonal, (dir + side) * -diagonal,
        }
        local height, lower = standHeight(), nil
        -- A ledge on one side does not make the other sides unusable. Keep
        -- the search small and prefer the egg's floor over a lower platform.
        for _, direction in ipairs(directions) do
            local base = Vector3.new(at.X + direction.X * stand, at.Y + 3, at.Z + direction.Z * stand)
            local hit = groundAt(base, at.Y + (high and 160 or 6))
            if hit then
                local gap = math.abs(hit.Y - at.Y)
                if gap < (high and 150 or 12) then
                    return Vector3.new(base.X, hit.Y + height, base.Z)
                end
                if not high and gap < 40 and not lower then
                    lower = Vector3.new(base.X, hit.Y + height, base.Z)
                end
            end
        end
        -- An unverified fallback can put the body into a void or on a roof.
        -- Let the caller retry when the map has not streamed in yet.
        return lower
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

	local touchWon, routeReason = nil, nil
	do
		status("Dodge: jump to the egg")
		if not valid() then releaseView(); return false, "Semi TP: cancelled or no character" end
		touchWon, routeReason = semi.DodgeRoute({ Uid = uid, EggPos = eggPos, LandFor = landFor, Grab = grab })
		if not valid() then releaseView(); return false, "Semi TP: cancelled or no character" end
		slog("Dodge route: " .. tostring(touchWon))
		if not touchWon then
			releaseView()
            if not valid() then return false, "cancelled" end
			local r = root()
			if r then
				pcall(function()
					r.CFrame = startCF
					r.AssemblyLinearVelocity = Vector3.zero
					r.AssemblyAngularVelocity = Vector3.zero
				end)
			end
			task.wait(0.2)
			return false, routeReason or "Dodge: the jump to the egg was not accepted"
		end
		semi.Plain = true
		return true, { Arrived = true, Plain = true }
	end
	return true, { Plain = true }
end

local worldResetTime, lastResetCheck = 0, 0
runtime.spawn(function()
	while alive do
		task.wait(1)
		if state.Busy and not state.HalloweenOwner then
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
	local character = localPlayer.Character
    local originalRoot = root()
	local routeTrip = state.TripId
	local function valid()
		return alive and state.TripId == routeTrip and not state.Cancel and localPlayer.Character == character and originalRoot ~= nil and root() == originalRoot
	end
    if typeof(target) ~= "Vector3" or target.X ~= target.X or target.Y ~= target.Y or target.Z ~= target.Z
        or math.abs(target.X) == math.huge or math.abs(target.Y) == math.huge or math.abs(target.Z) == math.huge
        or not valid() then return false end
	local waited = os.clock()
	while not swapped() and os.clock() - waited < 5 and valid() do
		RunService.Heartbeat:Wait()
	end
	if not valid() then return false end
	for attempt = 1, tries or 6 do
		local r = root()
		if not valid() then
			return false
		end
		if (r.Position - target).Magnitude <= 4 then
			stopMotion()
			return true
		end
		local pulledBefore = state.PulledAt
		local held = 0
		while held < 0.15 and valid() do
			place(target)
			held += RunService.Heartbeat:Wait()
		end
		if not valid() then return false end
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
	local character = localPlayer.Character
    local originalRoot = root()
	local routeTrip = state.TripId
	local function valid()
		return alive and state.TripId == routeTrip and not state.Cancel and localPlayer.Character == character and originalRoot ~= nil and root() == originalRoot
	end
    if typeof(target) ~= "Vector3" or target.X ~= target.X or target.Y ~= target.Y or target.Z ~= target.Z
        or math.abs(target.X) == math.huge or math.abs(target.Y) == math.huge or math.abs(target.Z) == math.huge
        or not valid() then return false end
	local waited = os.clock()
	while not swapped() and os.clock() - waited < 5 and valid() do
		RunService.Heartbeat:Wait()
	end
	if not valid() then return false end
	local step = math.max(walkSpeed() * CFG.HopRatio, CFG.HopMin)
	local gap = CFG.HopGap
	local retries, shrinks = 0, 0
	for _ = 1, maxHops or 70 do
		local r = root()
		if not valid() then
			return false
		end
		local delta = target - r.Position
		if delta.Magnitude <= 2 then
			return true
		end
		local nextPos = delta.Magnitude <= step and target or (r.Position + delta.Unit * step)
		local pulledBefore = state.PulledAt
		local held = 0
		while held < gap and valid() do
			place(nextPos)
			held += RunService.Heartbeat:Wait()
		end
		if not valid() then return false end
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
	return valid() and r ~= nil and (target - r.Position).Magnitude <= 6
end








local function getOffTreadmill()
	local character = localPlayer.Character
    local originalRoot = root()
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local routeTrip = state.TripId
	local function valid()
		return alive and state.TripId == routeTrip and not state.Cancel
            and localPlayer.Character == character and originalRoot ~= nil and root() == originalRoot
            and humanoid ~= nil and humanoid.Health > 0
	end
	for _ = 1, 3 do
		local r = root()
		if not valid() then return false end
		if not r.Anchored then return true end
		local askDoff = remote("RF/Treadmill/AskDoff")
		if askDoff and askDoff:IsA("RemoteFunction") then
			runtime.invoke(askDoff, 4)
		end
		if not valid() then return false end
		local held, limit = 0, 1.5 + netPing()
		while held < limit and valid() do
			local rr = root()
			if not rr then return false end
			if not rr.Anchored then return true end
			held += RunService.Heartbeat:Wait()
		end
	end
	local r = root()
	return valid() and r ~= nil and not r.Anchored
end

-- Run only after confirmed delivery, while its trip still owns Busy/character.
-- A wear request is not success: the server's render snapshot must confirm it.
runtime.autoTreadmill = (function()
    local api = { Enabled = true, Active = nil, Running = false, Generation = 0 }
    local function finite(position)
        return typeof(position) == "Vector3" and position.X == position.X and position.Y == position.Y and position.Z == position.Z
            and math.abs(position.X) < math.huge and math.abs(position.Y) < math.huge and math.abs(position.Z) < math.huge
    end
    function api.cancel()
        api.Generation += 1
        local token = api.Active
        api.Active, api.Running = nil, false
        if token and token.RequestKey then runtime.cancelRequest(token.RequestKey, "Auto treadmill cancelled") end
    end
    function api.setEnabled(enabled)
        enabled = enabled == true
        if api.Enabled == enabled then return end
        api.Enabled = enabled
        api.cancel()
    end
    function api.run(tripId, tripChar)
        if not api.Enabled then return false, "Auto treadmill is off" end
        local previous = api.Active
        if previous then
            -- Emergency abort may cancel the owning coroutine before its finally
            -- block runs. Never let that stale reservation block the next trip.
            local stale = previous.TripId ~= state.TripId or previous.Character ~= localPlayer.Character
                or previous.Root ~= root() or previous.Generation ~= api.Generation or not state.Busy
                or state.Cancel or state.Died or coroutine.status(previous.Thread) == "dead"
            if stale then api.cancel() else return false, "Auto treadmill is already running" end
        end
        local startRoot = root()
        local token = { Generation = api.Generation, TripId = tripId, Character = tripChar,
            Root = startRoot, Thread = coroutine.running() }
        api.Active, api.Running = token, true
        local function current()
            if not alive or api.Active ~= token or not api.Enabled or api.Generation ~= token.Generation
                or not state.Busy or state.TripId ~= tripId or state.Cancel or state.Died or state.Carrying
                or localPlayer.Character ~= tripChar or startRoot == nil or root() ~= startRoot or viewState then return false end
            if runtime.bigEggFinder and runtime.bigEggFinder.IsJoining then return false end
            local hum = tripChar and tripChar:FindFirstChildOfClass("Humanoid")
            return hum ~= nil and hum.Health > 0
        end
        local function request(budget, callback, ...)
            if not current() or budget <= 0 then return false, "Treadmill return cancelled" end
            local key = {}
            token.RequestKey = key
            local values = table.pack(runtime.call(key, budget, function(...)
                if not current() then return nil end
                return callback(...)
            end, ...))
            if token.RequestKey == key then token.RequestKey = nil end
            return table.unpack(values, 1, values.n)
        end
        local function cancelledReason()
            return api.Enabled and "Treadmill return cancelled" or "Auto treadmill is off"
        end
        local ok, mounted, reason = pcall(function()
            if not current() then return false, cancelledReason() end
            local wear = remote("RF/Treadmill/AskWearStill")
            local snapshotRemote = remote("RF/Treadmill/AskRenderSnapshot")
            if not wear or not wear:IsA("RemoteFunction") or not snapshotRemote or not snapshotRemote:IsA("RemoteFunction") then
                return false, "Treadmill remotes unavailable"
            end
            local function remotesCurrent()
                return remote("RF/Treadmill/AskWearStill") == wear
                    and remote("RF/Treadmill/AskRenderSnapshot") == snapshotRemote
            end
            local deadline = os.clock() + 12
            local function budget(limit) return math.min(limit, math.max(0, deadline - os.clock())) end
            local checkOk, alreadyMounted = request(budget(1.25), treadmillMounted, budget(1.25), snapshotRemote)
            if not current() then return false, cancelledReason() end
            if not remotesCurrent() then return false, "Treadmill changed; try again" end
            if checkOk and alreadyMounted == true then return true, "On treadmill" end
            if not checkOk or alreadyMounted == nil then return false, "Treadmill state unavailable" end
            local found, stand = request(budget(4), treadmillStand)
            if not current() then return false, cancelledReason() end
            if not found or not finite(stand) then return false, "Treadmill stand unavailable" end
            if os.clock() >= deadline then return false, "Treadmill return timed out" end
            if not remotesCurrent() then
                return false, "Treadmill changed; try again"
            end
            -- No fallback coordinates: only the locally resolved owned plot is used.
            place(stand)
            if not current() then return false, cancelledReason() end
            local settleUntil = math.min(deadline, os.clock() + 0.15)
            while current() and os.clock() < settleUntil do RunService.Heartbeat:Wait() end
            if not current() then return false, cancelledReason() end
            if not finite(startRoot.Position) or (startRoot.Position - stand).Magnitude > 5 then
                return false, "Could not reach treadmill"
            end
            -- Both request and confirmation must still belong to this hierarchy.
            if not remotesCurrent() then return false, "Treadmill changed; try again" end
            local wore, accepted = request(budget(3), wear.InvokeServer, wear)
            if not current() then return false, cancelledReason() end
            if not remotesCurrent() then return false, "Treadmill changed; try again" end
            if not wore or accepted == false or (type(accepted) == "table" and (accepted.Success == false or accepted.success == false)) then
                return false, "Treadmill mount was not accepted"
            end
            local confirmUntil = math.min(deadline, os.clock() + 3)
            for _ = 1, 8 do
                if not current() then return false, cancelledReason() end
                if not remotesCurrent() then return false, "Treadmill changed; try again" end
                local remaining = confirmUntil - os.clock()
                if remaining <= 0 then break end
                local confirmed, value = request(math.min(1, remaining), treadmillMounted, math.min(1, remaining), snapshotRemote)
                if not current() then return false, cancelledReason() end
                if not remotesCurrent() then return false, "Treadmill changed; try again" end
                if confirmed and value == true and os.clock() <= confirmUntil then return true, "On treadmill" end
                if not confirmed or value == nil then return false, "Treadmill mount unconfirmed" end
                local waitUntil = math.min(confirmUntil, os.clock() + 0.2)
                while current() and os.clock() < waitUntil do RunService.Heartbeat:Wait() end
            end
            return false, "Treadmill mount unconfirmed"
        end)
        if api.Active == token then api.Active, api.Running = nil, false end
        if not ok then
            slog("Auto treadmill: " .. tostring(mounted))
            return false, "Treadmill return failed"
        end
        return mounted == true, reason
    end
    return api
end)()

-- Request only the destination area when its ground has not replicated.
-- Roblox Player.RequestStreamAroundAsync is optional and always time-bounded.
function runtime.prepareArea(position)
    if not alive or state.Cancel or typeof(position) ~= "Vector3"
        or position.X ~= position.X or position.Y ~= position.Y or position.Z ~= position.Z
        or math.abs(position.X) == math.huge or math.abs(position.Y) == math.huge or math.abs(position.Z) == math.huge then
        return false
    end
    local supported = false
    pcall(function()
        supported = workspace.StreamingEnabled == true and type(localPlayer.RequestStreamAroundAsync) == "function"
    end)
    if not supported then return false end
    local character, tripId, originalRoot = localPlayer.Character, state.TripId, root()
    local function current()
        return alive and not state.Cancel and state.TripId == tripId
            and localPlayer.Character == character and originalRoot ~= nil and root() == originalRoot
    end
    if not current() then return false end
    local ok, completed = runtime.call({}, 2.5, function()
        if not current() then return false end
        localPlayer:RequestStreamAroundAsync(position, 2)
        return current()
    end)
    return ok and completed == true and current()
end

semi.DodgeRoute = function(ctx)
	if type(ctx) ~= "table" or type(ctx.Uid) ~= "string" or type(ctx.EggPos) ~= "function"
		or type(ctx.LandFor) ~= "function" or type(ctx.Grab) ~= "function" then return false end
	local character = localPlayer.Character
    local originalRoot = root()
	local routeTrip = state.TripId
    local function finite(point)
        return typeof(point) == "Vector3" and point.X == point.X and point.Y == point.Y and point.Z == point.Z
            and math.abs(point.X) < math.huge and math.abs(point.Y) < math.huge and math.abs(point.Z) < math.huge
    end
    local function valid()
        if not alive or state.TripId ~= routeTrip or state.Cancel or localPlayer.Character ~= character
            or originalRoot == nil or root() ~= originalRoot then return false end
        -- Streaming and prompt callbacks may finish after another carry update.
        -- Never reposition an unrelated or still unidentified carried item.
        return not state.Carrying or state.Uid == ctx.Uid
            or (state.Uid == nil and type(runtime.confirmCarry) == "function" and runtime.confirmCarry(ctx.Uid))
    end
	local function held()
		return valid() and state.Carrying and state.Uid == ctx.Uid
	end
	local function near(a, b, d)
        -- Interiors and raised areas can share X/Z with another floor. A
        -- relocation only confirms this landing when its height matches too.
        return typeof(a) == "Vector3" and typeof(b) == "Vector3" and (a - b).Magnitude <= d
	end
	local function pinFor(point, t, stopWhen)
		local w = 0
		while w < t and valid() and not held() do
			if stopWhen and stopWhen() then
				return true
			end
			local r = root()
			if r and (r.Position - point).Magnitude > 1 then
				place(point)
			end
			w += RunService.Heartbeat:Wait()
		end
		return valid() and stopWhen ~= nil and stopWhen() or false
	end
    if not valid() then return false end
    if held() then return "near" end
    if not getOffTreadmill() or not valid() then return false end
	local eggPos = ctx.EggPos()
    if not valid() then return false end
    if held() then return "near" end
    if not finite(eggPos) then return false, "that egg is gone; refresh and try again" end
	local at = ctx.LandFor(eggPos)
	if not valid() then return false end
    if held() then return "near" end
    if not finite(at) then
        status("Checking the egg area's ground")
        runtime.prepareArea(eggPos)
        if not valid() then return false end
    if held() then return "near" end
        local updated = ctx.EggPos()
        if not valid() then return false end
    if held() then return "near" end
        if not finite(updated) then return false, "that egg is gone; refresh and try again" end
        eggPos = updated
        at = ctx.LandFor(eggPos)
        if not valid() then return false end
    if held() then return "near" end
    end
	if not finite(at) then
		slog("Dodge route: no ground next to the egg")
        return false, "Dodge: no safe ground near the egg; refresh and try again"
	end
	local from = DODGE_BASE
	place(DODGE_BASE)
	pinFor(DODGE_BASE, 0.15)
	if not valid() then return false end
    if held() then return "near" end
    -- The initial floor probe can precede streaming or the base settling wait.
    -- Recompute only after a real target move, preserving the cheap fast path.
    local latest = ctx.EggPos()
    if not valid() then return false end
    if held() then return "near" end
    if not finite(latest) then return false, "that egg is gone; refresh and try again" end
    if (latest - eggPos).Magnitude > 1 then
        eggPos = latest
        at = ctx.LandFor(eggPos)
        if not valid() then return false end
    if held() then return "near" end
        if not finite(at) then
            runtime.prepareArea(eggPos)
            if not valid() then return false end
    if held() then return "near" end
            latest = ctx.EggPos()
            if not valid() then return false end
    if held() then return "near" end
            if not finite(latest) then return false, "that egg is gone; refresh and try again" end
            eggPos = latest
            at = ctx.LandFor(eggPos)
            if not valid() then return false end
    if held() then return "near" end
        end
        if not finite(at) then return false, "Dodge: no safe ground near the moved egg" end
    end
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
	if not valid() then return false end
    if held() then return "near" end
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
			if not valid() then return false end
    if held() then return "near" end
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
	if not valid() then return false end
    if held() then return "near" end
	if r2At then
		slog(string.format("Dodge route: R2 to the arrival %.2f s after R1", r2At - (r1At or r2At)))
	elseif r1At then
		slog("Dodge route: no R2 to the arrival: the server did not accept the jump, back to the base")
		place(DODGE_BASE)
		return false
	end
    local arrivalEgg = ctx.EggPos()
    if not valid() then return false end
    if held() then return "near" end
    if not finite(arrivalEgg) then return false, "that egg is gone; refresh and try again" end
    if (arrivalEgg - eggPos).Magnitude > 6 then
        return false, "Egg moved during arrival; retrying with its current position"
    end
	progress(0.3, "Jump accepted")
	plantClown(at)
	pinFor(at, math.max(0, (r2At or os.clock()) + pickDelay - os.clock()))
	if not valid() then return false end
    if held() then return "near" end
	local since, pickupBy = 1, os.clock() + 2.5
	while not held() and os.clock() < pickupBy and valid() do
        local egg = ctx.EggPos()
		if not valid() then return false end
    if held() then return "near" end
        if not finite(egg) then return false, "that egg is gone; refresh and try again" end
        if (egg - eggPos).Magnitude > 6 then
            return false, "Egg moved during pickup; retrying with its current position"
        end
		local r = root()
		if r and (r.Position - at).Magnitude > 1.5 then
			place(at)
		end
		local dt = RunService.Heartbeat:Wait()
		if not valid() then return false end
    if held() then return "near" end
		if os.clock() >= pickupBy then break end
		since += dt
		if since >= CFG.GrabInterval then
			since = 0
			local prompt = promptNear(egg, 12)
			if prompt then runtime.firePrompt(prompt) end
			if not valid() or os.clock() >= pickupBy then break end
			if not state.Carrying then runtime.spawn(takeEgg, ctx.Uid) end
		end
	end
	if not valid() then return false end
    if held() then return "near" end
	if not held() then
		ctx.Grab(ctx.Uid, 1)
	end
	if not valid() then return false end
    if held() then return "near" end
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



-- Violet & black UI palette: visual-only values, shared by the window and steal overlay.
local THEME = {
    Black = Color3.fromRGB(7, 5, 12),
    Surface = Color3.fromRGB(17, 10, 29),
    Violet = Color3.fromRGB(166, 72, 245),
    VioletBright = Color3.fromRGB(207, 140, 255),
    VioletDark = Color3.fromRGB(66, 23, 113),
    Border = Color3.fromRGB(91, 46, 139),
    Text = Color3.fromRGB(249, 243, 255),
    Muted = Color3.fromRGB(183, 155, 208),
}

-- blackout: a dark violet-black screen over the game and every game sound at zero for the whole trip
local blackout = { Enabled = true, Gui = nil, Sounds = {}, SoundLinks = {}, SoundRemovals = {}, Links = {}, MasterOld = nil }

function blackout.releaseSound(sound)
    local volume = blackout.Sounds[sound]
    blackout.Sounds[sound] = nil
    local link = blackout.SoundLinks[sound]
    blackout.SoundLinks[sound] = nil
    if link then pcall(function() link:Disconnect() end) end
    if volume ~= nil then
        pcall(function() if sound.Volume == 0 then sound.Volume = volume end end)
    end
end

function blackout.mute(sound)
    local screen = blackout.Gui
    if not alive or not screen or blackout.Sounds[sound] ~= nil then return end
    local ok, volume = pcall(function()
        if sound:IsA("Sound") then return sound.Volume end
    end)
    if not ok or type(volume) ~= "number" then return end
    if not pcall(function() sound.Volume = 0 end) then return end
    blackout.Sounds[sound] = volume
    local connected, link = pcall(function()
        return sound:GetPropertyChangedSignal("Volume"):Connect(function()
            if not alive or blackout.Gui ~= screen or blackout.Sounds[sound] == nil then return end
            pcall(function()
                local requested = sound.Volume
                if requested ~= 0 then
                    -- Restore the game's latest requested volume after the trip.
                    blackout.Sounds[sound] = requested
                    sound.Volume = 0
                end
            end)
        end)
    end)
    if connected then blackout.SoundLinks[sound] = link end
end

-- Walk incrementally: GetDescendants allocates the whole world before the
-- first yield. Attach all stream listeners before visiting either scope.
function blackout.startSoundScan(screen)
    local scopes = { workspace }
    pcall(function() scopes[#scopes + 1] = game:GetService("SoundService") end)
    local function removed(sound)
        if not alive or blackout.Gui ~= screen or blackout.Sounds[sound] == nil then return end
        blackout.SoundRemovals[sound] = true
        if blackout.SoundCleanupTask then return end
        local owner = {}
        blackout.SoundCleanupOwner = owner
        local thread = runtime.spawn(function()
            -- DescendantRemoving fires before Parent changes. Defer the scope
            -- check so moving a sound between the two scopes keeps it muted.
            task.wait()
            while alive and blackout.Gui == screen and blackout.SoundCleanupOwner == owner do
                local deadline, count = os.clock() + 0.0006, 0
                repeat
                    local sound = next(blackout.SoundRemovals)
                    if not sound then break end
                    blackout.SoundRemovals[sound] = nil
                    local ok, inside = pcall(function()
                        return sound:IsDescendantOf(workspace)
                            or (scopes[2] and sound:IsDescendantOf(scopes[2]))
                    end)
                    if not ok or not inside then blackout.releaseSound(sound) end
                    count += 1
                until count >= 40 or os.clock() >= deadline
                if not next(blackout.SoundRemovals) then break end
                task.wait()
            end
            if blackout.SoundCleanupOwner == owner then
                blackout.SoundCleanupTask, blackout.SoundCleanupOwner = nil, nil
            end
        end)
        if blackout.SoundCleanupOwner == owner then blackout.SoundCleanupTask = thread end
    end
    for _, scope in ipairs(scopes) do
        if not alive or blackout.Gui ~= screen then return end
        local ok, link = pcall(function()
            return scope.DescendantAdded:Connect(function(inst)
                if alive and blackout.Gui == screen and inst:IsA("Sound") then
                    blackout.mute(inst)
                end
            end)
        end)
        if ok then blackout.Links[#blackout.Links + 1] = link end
        local removedOk, removedLink = pcall(function()
            return scope.DescendantRemoving:Connect(removed)
        end)
        if removedOk then blackout.Links[#blackout.Links + 1] = removedLink end
    end
    blackout.ScanTask = runtime.spawn(function()
        local stack = {}
        for _, scope in ipairs(scopes) do stack[#stack + 1] = { Node = scope } end
        while alive and blackout.Gui == screen and #stack > 0 do
            local deadline, count = os.clock() + 0.0006, 0
            repeat
                local entry = stack[#stack]
                if not entry then return end
                if entry.Children then
                    local child = entry.Children[entry.Index]
                    entry.Children[entry.Index] = false -- release processed references
                    entry.Index += 1
                    if entry.Index > entry.Length then stack[#stack] = nil end
                    if child then stack[#stack + 1] = { Node = child } end
                else
                    stack[#stack] = nil
                    pcall(function()
                        local node = entry.Node
                        if node ~= workspace and node ~= scopes[2] and not node:IsDescendantOf(workspace)
                            and not node:IsDescendantOf(scopes[2] or workspace) then return end
                        if node:IsA("Sound") then blackout.mute(node) end
                        local children = node:GetChildren()
                        if #children > 0 then
                            stack[#stack + 1] = { Children = children, Index = 1, Length = #children }
                        end
                    end)
                end
                count += 1
            until #stack == 0 or count >= 40 or os.clock() >= deadline
            if #stack > 0 then task.wait() end
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
    frac = tonumber(frac) or 0
    if frac ~= frac then return end
    frac = math.clamp(frac, 0, 1)
	if frac == 0 then
		blackout.Frac = 0
	else
		blackout.Frac = math.max(blackout.Frac or 0, frac)
	end
    pcall(function()
        local fill = math.floor(blackout.Frac * 1000 + 0.5) / 1000
        local percent = math.floor(blackout.Frac * 100 + 0.5)
        if ui.LastFill ~= fill then
            ui.Fill.Size = UDim2.fromScale(fill, 1)
            ui.LastFill = fill
        end
        if ui.LastPct ~= percent then
            ui.Pct.Text = string.format("%d%%", percent)
            ui.LastPct = percent
        end
    end)
end

state.Progress = function(frac, text)
	blackout.set(frac, text)
end

function blackout.on()
	if not alive or not blackout.Enabled or blackout.Gui then
		return
	end
	local screen = Instance.new("ScreenGui")
    blackout.Gui = screen -- Register immediately so partial initialization can be cleaned.
	screen.Name = string.format("%08x", math.random(0, 0x7fffffff))
	screen.IgnoreGuiInset = true
	screen.ResetOnSpawn = false
	screen.DisplayOrder = 100000
	screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	local cover = Instance.new("Frame")
	cover.Size = UDim2.fromScale(1, 1)
	cover.BackgroundColor3 = THEME.Black
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
		local nameLabel = label(102, 18, 15, Enum.Font.GothamBold, THEME.Text)
		local valueLabel = label(121, 14, 11, Enum.Font.Gotham, THEME.Muted)
		local barBack = Instance.new("Frame")
		barBack.AnchorPoint = Vector2.new(0.5, 0)
		barBack.Position = UDim2.new(0.5, 0, 0, 148)
		barBack.Size = UDim2.new(1, 0, 0, 8)
		barBack.BackgroundColor3 = THEME.VioletDark
		barBack.BorderSizePixel = 0
		barBack.Parent = card
		local backCorner = Instance.new("UICorner")
		backCorner.CornerRadius = UDim.new(0, 4)
		backCorner.Parent = barBack
		local fill = Instance.new("Frame")
		fill.Size = UDim2.fromScale(0, 1)
		fill.BackgroundColor3 = THEME.Violet
		fill.BorderSizePixel = 0
		fill.Parent = barBack
		local fillCorner = Instance.new("UICorner")
		fillCorner.CornerRadius = UDim.new(0, 4)
		fillCorner.Parent = fill
		local pctLabel = label(162, 16, 11, Enum.Font.GothamMedium, THEME.VioletBright)
		blackout.Ui = { Icon = icon, Name = nameLabel, Value = valueLabel, Fill = fill, Pct = pctLabel }
		blackout.Frac = 0
		if blackout.Pet then
			blackout.setPet(blackout.Pet.Name, blackout.Pet.Icon, blackout.Pet.Value)
		end
		blackout.set(0, "Starting")
		pcall(function()
            if performance.Enabled then return end
			local VIOLET_, BRIGHT_, DEEP_ = THEME.Violet, THEME.VioletBright, THEME.VioletDark
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
				st.Color = THEME.Violet
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
				g.Color = bandSeq(BRIGHT_, VIOLET_)
				g.Parent = label
				texts[#texts + 1] = g
			end
			local panel = Instance.new("Frame")
			panel.AnchorPoint = Vector2.new(0.5, 0.5)
			panel.Position = UDim2.fromScale(0.5, 0.5)
			panel.Size = UDim2.fromOffset(268, 222)
			panel.BackgroundColor3 = THEME.Surface
			panel.BorderSizePixel = 0
			panel.ZIndex = 0
			panel.Parent = card
			local panelCorner = Instance.new("UICorner")
			panelCorner.CornerRadius = UDim.new(0, 20)
			panelCorner.Parent = panel
			ring(panel, 2, VIOLET_, DEEP_)
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
			ring(halo, 2, BRIGHT_, DEEP_)
			local iconScale = Instance.new("UIScale")
			iconScale.Parent = icon
			local cardScale = Instance.new("UIScale")
			cardScale.Scale = 0.82
			cardScale.Parent = card
			shine(nameLabel)
			shine(pctLabel)
			local barShine = Instance.new("UIGradient")
			barShine.Color = bandSeq(BRIGHT_, VIOLET_)
			barShine.Parent = fill
			local specks = {}
			for i = 1, 14 do
				local d = Instance.new("Frame")
				local size = math.random(2, 4)
				d.Size = UDim2.fromOffset(size, size)
				d.BackgroundColor3 = THEME.Violet
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
                if not alive or blackout.Gui ~= screen then return end
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
    local parented = pcall(function() screen.Parent = parent or CoreGui end)
    if not parented then screen.Parent = localPlayer:FindFirstChildOfClass("PlayerGui") end
    blackout.Gui = screen
    blackout.set(0, "Starting")
    local masterZero = false
    pcall(function()
        local settingsService = UserSettings():GetService("UserGameSettings")
        local old = settingsService.MasterVolume
        settingsService.MasterVolume = 0
        if settingsService.MasterVolume ~= 0 then return end
        blackout.MasterOld, blackout.MasterSettings = old, settingsService
        masterZero = true
        local connected, link = pcall(function()
            return settingsService:GetPropertyChangedSignal("MasterVolume"):Connect(function()
                if not alive or blackout.Gui ~= screen then return end
                pcall(function()
                    local requested = settingsService.MasterVolume
                    if requested ~= 0 then
                        blackout.MasterOld = requested
                        settingsService.MasterVolume = 0
                    end
                end)
            end)
        end)
        if connected then blackout.Links[#blackout.Links + 1] = link end
    end)
    if not masterZero then blackout.startSoundScan(screen) end
	slog("blackout on")
	blackout.Timer = runtime.delay(240, function()
		if blackout.Gui == screen then
			blackout.off()
		end
	end)
end

function blackout.off()
    runtime.cancel(blackout.Timer)
    blackout.Timer = nil
    runtime.cancel(blackout.ScanTask)
    blackout.ScanTask = nil
    runtime.cancel(blackout.SoundCleanupTask)
    blackout.SoundCleanupTask, blackout.SoundCleanupOwner = nil, nil
    table.clear(blackout.SoundRemovals)
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
    for sound in pairs(blackout.Sounds) do blackout.releaseSound(sound) end
    table.clear(blackout.SoundLinks)
	blackout.Sounds = {}
    pcall(function()
        local settingsService = blackout.MasterSettings
        if settingsService and blackout.MasterOld ~= nil and settingsService.MasterVolume == 0 then
            settingsService.MasterVolume = blackout.MasterOld
        end
    end)
    blackout.MasterOld, blackout.MasterSettings = nil, nil
	pcall(function()
		screen:Destroy()
	end)
	slog("blackout off")
end

local MAX_ATTEMPTS = 3

local function stealAndDeliver(uid, attempt, autoRun)
    if runtime.halloween and runtime.halloween.blocksNormal() then
        status(runtime.halloween.TrainReserved and not runtime.halloween.hasCarry()
            and "Halloween: use Return home to finish the train session"
            or "Halloween: stop farming and put down carried items before normal stealing")
        return false
    end
	attempt = attempt or 1
    if not alive or state.Busy or state.Aborting or type(uid) ~= "string" then return false end
    if runtime.bigEggFinder and runtime.bigEggFinder.IsJoining then
        status("Finish joining before stealing")
        return false
    end
    if performance.Restoring then status("Restoring graphics..."); return false end
    runtime.refreshWatches()
    local ready, reason = runtime.ready()
    if not ready then status(reason); return false end
    local currentRoot = root()
    local currentChar = localPlayer.Character
    local currentHum = currentChar and currentChar:FindFirstChildOfClass("Humanoid")
    if not currentRoot or not currentHum or currentHum.Health <= 0 then
        status("Wait for your character")
        return false
    end
    -- Only the known inventory held when this request began may be
    -- deliberately dropped in preflight. Metadata/snapshot waits can admit
    -- a different carry event; that item belongs to the new interaction.
    local initialCarryUid = state.Carrying and state.Uid or nil
    runtime.cancel(state.TakePending)
    state.TakePending = nil
    runtime.cancelRequest("CarryFieldEgg", "Cancelled")
    runtime.cancelRequest("DropFieldEgg", "Cancelled")
    state.TripId = (state.TripId or 0) + 1
    local tripId = state.TripId
    state.CancelAt = nil
    state.TripDeadline = os.clock() + 240
    state.Busy = true
    state.AutoRun = autoRun
    state.TripDelivered = false
    state.DeliveryPhase = nil
    state.TripCharacter = currentChar
    -- Startup callbacks run before TripTask/watchdog exist. Keep their
    -- failures attached to this trip so a UI error cannot leave Busy stuck.
    local startupOk, startupError = pcall(function()
    performance.setStealing(true)
    state.TargetUid = uid
    state.Cancel = false
	state.Died = false
	progress(0, attempt > 1 and string.format("Retry %d/%d", attempt, MAX_ATTEMPTS) or "Starting")
    state.Hits = 0
    state.Ragdoll = false
    state.DeliveryFailedAt = nil
	worldResetTime, lastResetCheck = 0, 0
    blackout.Pet = nil
    local overlayOk, overlayError = pcall(blackout.on)
    if not overlayOk then
        pcall(blackout.off)
        slog("Blackout unavailable: " .. tostring(overlayError))
    end
    end)
    if not startupOk then
        if alive and state.TripId == tripId then runtime.abortTrip("Error: " .. tostring(startupError)) end
        return false
    end
    if not alive or state.TripId ~= tripId or not state.Busy then return false end
    local tripChar = currentChar
    local function ownsTrip()
        return alive and state.TripId == tripId
    end
    local function activeTrip()
        if not ownsTrip() or state.Cancel or localPlayer.Character ~= tripChar then return false end
        if root() ~= currentRoot or currentHum.Health <= 0 then
            status("Wait for your character")
            return false
        end
        return true
    end
	runtime.spawn(function()
        while state.Busy and alive and state.TripId == tripId do
            task.wait(0.1)
            if not alive or not state.Busy or state.TripId ~= tripId then return end
            if state.Cancel then
                state.CancelAt = state.CancelAt or os.clock()
                if os.clock() - state.CancelAt >= 8 then
                    runtime.abortTrip("Cancelled")
                    return
                end
            elseif os.clock() >= state.TripDeadline then
                runtime.abortTrip("Trip timed out; try again")
                return
            end
			local now = localPlayer.Character
			local hum = tripChar and tripChar:FindFirstChildOfClass("Humanoid")
			if now ~= tripChar or not tripChar or (hum and hum.Health <= 0) then
				if state.Busy and not state.Cancel then
					state.Died = true
					state.Cancel = true
                    state.CancelAt = os.clock()
					status("Died: stopped, waiting for the respawn")
					slog("the body died, the trip is stopped and nothing moves the new body")
				end
			end
		end
	end)
	state.TripTask = runtime.spawnOwned(tripId, function()
		local semiTrip = true
		local delivered = false
		local failReason = nil
        local routeStarted = false
        local carryChanged = false
        local function checkCarry()
            if state.Carrying and state.Uid ~= uid then
                if state.Uid == nil and runtime.confirmCarry(uid) then return true end
                carryChanged = true
                failReason = state.Uid == nil and "Held egg is not identified yet" or "Held egg changed; stealing stopped"
                status(failReason)
                return false
            end
            return true
        end
        local function syncDelivery()
            if not delivered and ownsTrip() and state.TripDelivered == true then
                delivered, failReason = true, nil
                semi.Fails, semi.ResetDone = 0, false
                status("Delivered")
                progress(1, "Delivered")
            end
            return delivered
        end
		local ok, err = pcall(function()
			status("Looking for the egg")
            local egg, targetRecord
            local records = snapshot(true)
            local selectionAt = os.clock()
            -- Capture this response before describe/metadata callbacks can yield.
            -- A separate list refresh must not replace this trip's result.
            local snapshotError = state.SnapshotError
            if not activeTrip() then return end
            if snapshotError then
                failReason = snapshotError
                status(snapshotError)
                return
            end
            local function allowedTarget()
                if runtime.rarityFilter and not runtime.rarityFilter.matches(targetRecord) then
                    failReason = "Selected egg does not match filter"
                    status(failReason)
                    return false
                end
                return true
            end
            for _, record in ipairs(records) do
                if record.Uid == uid then
                    if runtime.rarityFilter and not runtime.rarityFilter.matches(record) then
                        failReason = "Selected egg does not match filter"
                        status(failReason)
                        return
                    end
                    targetRecord = record
                    egg = record.BottomCFrame.Position
                    local info = describe(record)
                    -- Game metadata helpers may yield. A cancelled/replaced
                    -- trip must not overwrite the new trip's pet overlay.
                    if not activeTrip() then return end
                    blackout.setPet(info.Name, info.Icon, info.Value)
                    break
                end
            end
            if not activeTrip() or not alive then return end
			progress(0.04, "Looking for the egg")
            if not egg then
                failReason = "that egg is gone"
                status("That egg is gone")
                return
            end
            if not allowedTarget() then return end
            if state.Carrying and state.Uid == nil then
                local confirmUntil = os.clock() + 0.6
                while state.Carrying and state.Uid == nil and activeTrip() and os.clock() < confirmUntil do
                    if runtime.confirmCarry(uid) then break end
                    RunService.Heartbeat:Wait()
                end
            end
            if not activeTrip() or not allowedTarget() then return end
            if state.Carrying and state.Uid == nil then
                failReason = "Held egg is not identified yet"
                status(failReason)
                return
            end
			if state.Carrying and state.Uid ~= uid then
                if initialCarryUid == nil or state.Uid ~= initialCarryUid then
                    checkCarry()
                    return
                end
				dropEgg()
				local waited = 0
				while state.Carrying and waited < 1 and activeTrip() do
					waited += RunService.Heartbeat:Wait()
				end
			end
            if not activeTrip() or not allowedTarget() then return end
            if state.Carrying and state.Uid ~= uid then
                failReason = "Drop held egg before stealing"
                status(failReason)
                return
            end
            local preflightRoot = root()
            if not preflightRoot then
                failReason = "no character"
                status("Wait for your character")
                return
            end
            if preflightRoot.Anchored then
                status("Leaving treadmill...")
                local leftTreadmill = getOffTreadmill()
                if not activeTrip() or not allowedTarget() then return end
                local current = root()
                if not leftTreadmill or not current or current.Anchored then
                    failReason = "Leave the treadmill before stealing"
                    status(failReason)
                    return
                end
            end
            -- Carry events can arrive while the dismount request is pending.
            if state.Carrying and state.Uid ~= uid then
                failReason = state.Uid == nil and "Held egg is not identified yet" or "Drop held egg before stealing"
                status(failReason)
                return
            end
            -- A slow dismount, held-egg drop, or metadata callback can outlive
            -- the selected field record. Refresh only old selections so fast
            -- trips keep one request; a confirmed held target needs no field slot.
            if os.clock() - selectionAt >= 0.5 and not (state.Carrying and state.Uid == uid) then
                local latest = snapshot(true)
                local refreshError = state.SnapshotError
                if not activeTrip() then return end
                if refreshError then
                    failReason = refreshError
                    status(refreshError)
                    return
                end
                if not checkCarry() then return end
                local currentRecord
                for _, record in ipairs(latest) do
                    if record.Uid == uid then currentRecord = record; break end
                end
                if currentRecord then
                    targetRecord = currentRecord
                    egg = currentRecord.BottomCFrame.Position
                elseif not (state.Carrying and state.Uid == uid) then
                    failReason = "that egg is gone"
                    status("That egg is gone")
                    return
                end
                if not allowedTarget() then return end
            end
            routeStarted = true
			state.NestBack = false
			if semiTrip then
				local r1 = root()
				local lineX1 = lineInfo()
				if r1 and r1.Position.Y < 5000 and not inDimension() and r1.Position.X > lineX1 + 800 and (egg - r1.Position).Magnitude > 100 then
					slog(string.format("Semi TP: the body stands %.0f studs past the line, hopping back to the base first", r1.Position.X - lineX1))
					status("Semi TP: hopping back to the base first")
					returnFront()
					if not activeTrip() then
						return
					end
				end
			end
			status("Going to the egg")
			progress(0.08, "Going to the egg")
			local reached
			if semiTrip then
				local okSemi, info = semiGo(uid, egg)
                if not activeTrip() or not checkCarry() then return end
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
                        if not activeTrip() then return end
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
            if not activeTrip() or not checkCarry() then return end
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
                if not activeTrip() or not checkCarry() then return end
				local taken = false
				if activeTrip() and checkCarry() then
					slog("the egg would not come free: back to the safe zone, treadmill reset, one more try")
					local safeAt = Vector3.new(RELAY_SAFE.X, groundY(RELAY_SAFE, RELAY_SAFE.Y), RELAY_SAFE.Z)
					local here = root()
					if here and here.Position.X > lineInfo() + 100 then
						returnFront()
					end
					if activeTrip() and checkCarry() then
						place(safeAt)
						local calm = 0
						while calm < 0.15 and activeTrip() and checkCarry() do
							calm += RunService.Heartbeat:Wait()
						end
                        if not activeTrip() or not checkCarry() then return end
						treadmillReset()
                        if not activeTrip() or not checkCarry() then return end
						place(safeAt)
						calm = 0
						while calm < 0.15 and activeTrip() and checkCarry() do
							calm += RunService.Heartbeat:Wait()
						end
						local current = eggNow(uid, { At = 0, Pos = egg }) or egg
                        if not activeTrip() or not checkCarry() then return end
						if runToEgg(uid, current, { Field = true, Ratio = RUN_RATIO }) then
							taken = grab(uid, 4)
						end
					end
				end
                if not activeTrip() or not checkCarry() then return end
				if not taken then
					failReason = "the egg would not come free"
					status("The egg would not come free")
					return
				end
			end
            if not activeTrip() or not checkCarry() then return end
            state.DeliveryPhase = { TripId = tripId, Uid = uid, Character = tripChar }
            local routeDelivered = instantTP(uid)
            if not ownsTrip() then return end
            if routeDelivered == true then state.TripDelivered = true end
            delivered = routeDelivered == true or syncDelivery()
            if not activeTrip() then return end
            if not delivered and not checkCarry() then return end
			if not delivered then
				failReason = state.NestBack and "the egg went back to its nest after the drop" or "delivery failed"
			end
			status(delivered and "Delivered" or "Delivery failed")
			if delivered then
				progress(1, "Delivered")
			end
		end)
        if not ownsTrip() then return end
        syncDelivery()
        if routeStarted and not delivered and not carryChanged and activeTrip() then checkCarry() end
		runtime.clearHolds()
        runtime.cancel(state.TakePending)
        state.TakePending = nil
        runtime.cancelRequest("CarryFieldEgg", "Cancelled")
        runtime.cancelRequest("DropFieldEgg", "Cancelled")
		fpsOff()
		dropClone()
		if state.ReleaseCamera then
            local release = state.ReleaseCamera
            state.ReleaseCamera = nil
            pcall(release)
		end
        if not ownsTrip() then return end
		semi.SlowRun = false
		semi.AtDrop = false
		semi.Plain = false
		if state.Died then
			local from = os.clock()
			while ownsTrip() and os.clock() - from < 15 and (localPlayer.Character == tripChar or not root()) do
				task.wait(0.1)
			end
			local calm = os.clock()
			while ownsTrip() and os.clock() - calm < 2.5 and not (swapped() and os.clock() - calm > 1.5) do
				task.wait(0.1)
			end
            if not ownsTrip() then return end
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
        if not ownsTrip() then return end
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

        syncDelivery()
		local why0 = tostring(failReason or "")
        local permanentFailure = string.find(why0, "no character", 1, true)
            or string.find(why0, "that egg is gone", 1, true)
            or string.find(why0, "portal not there", 1, true)
            or string.find(why0, "Selected egg does not match filter", 1, true)
        -- Rejected selections and unavailable snapshots never started a route.
        -- Do not teleport, treadmill-reset, delay or count a route failure for them.
        local willRetry = routeStarted and not carryChanged and not syncDelivery() and activeTrip() and not state.Died and attempt < MAX_ATTEMPTS and not permanentFailure and checkCarry()
		if willRetry then
			status("Delivery failed, treadmill then retry")
			slog(string.format("attempt %d/%d failed (%s): clean restart through the treadmill", attempt, MAX_ATTEMPTS, why0))
			local function wait(t)
				local w = 0
				while w < t and activeTrip() and checkCarry() and not syncDelivery() do
					w += RunService.Heartbeat:Wait()
				end
			end
			if state.Carrying and not syncDelivery() then
				dropEgg()
				local w = 0
				while state.Carrying and w < 1 and activeTrip() and checkCarry() and not syncDelivery() do
					w += RunService.Heartbeat:Wait()
				end
			end
			wait(0.6)
			local here = root()
			if here and here.Position.X > lineInfo() + 100 and activeTrip() and checkCarry() and not syncDelivery() then
				returnFront()
			end
			if activeTrip() and checkCarry() and not syncDelivery() then
				treadmillReset()
				wait(0.4)
			end
			willRetry = activeTrip() and not state.Died and root() ~= nil and checkCarry() and not carryChanged and not syncDelivery()
		end

        if not ownsTrip() then return end
        syncDelivery()
		-- Semi TP failed: the body goes back to the front by itself, and if that is not enough the player gets an instruction
		if willRetry then
			semi.Fails = semi.Fails + 1
		elseif semiTrip and routeStarted and not carryChanged then
			if delivered then
				semi.Fails, semi.ResetDone = 0, false
			elseif activeTrip() and checkCarry() and not syncDelivery() then
				semi.Fails += 1
				local untilAt = os.clock() + 1.5
				while os.clock() < untilAt and activeTrip() and checkCarry() and not syncDelivery() do
					RunService.Heartbeat:Wait()
				end
                if not ownsTrip() then return end
                -- Cancellation still owns the terminal cleanup. Do not leave
                -- Busy/blackout active until the emergency watchdog runs.
                if activeTrip() and checkCarry() and not syncDelivery() then
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
		end
        if not ownsTrip() then return end
        syncDelivery()
        -- Retain trip ownership until the optional return finishes: another
        -- steal or server join cannot race this movement. Delivery stays done
        -- even when the treadmill is unavailable or its confirmation times out.
        if delivered and activeTrip() and not state.Died and runtime.autoTreadmill and runtime.autoTreadmill.Enabled then
            state.TripDeadline = math.max(state.TripDeadline or 0, os.clock() + 15)
            pcall(blackout.off)
            status("Treadmill: returning after delivery")
            local returned, mounted, reason = pcall(runtime.autoTreadmill.run, tripId, tripChar)
            if not ownsTrip() then return end
            if activeTrip() then
                if returned and mounted then
                    status("Treadmill: training after delivery")
                else
                    if not returned then slog("Post-delivery treadmill: " .. tostring(mounted)) end
                    status("Treadmill: " .. (returned and tostring(reason or "not confirmed; egg delivered") or "unavailable; egg delivered"))
                end
            end
        end
        if not ownsTrip() then return end
		state.Busy = false
        state.TripCharacter = nil
    state.DeliveryPhase = nil
        performance.setStealing(false)
		if willRetry then
			slog(string.format("restarting the steal, attempt %d/%d", attempt + 1, MAX_ATTEMPTS))
            local restarted = stealAndDeliver(uid, attempt + 1, autoRun)
            if not restarted and ownsTrip() and not state.Busy then
                -- Dependencies or the character can disappear between tries.
                -- Keep the preflight status, but release the finished overlay.
                state.TargetUid = nil
                pcall(blackout.off)
            end
            if not restarted and runtime.autoSteal then runtime.autoSteal.finish(autoRun, false, failReason, 5) end
        else
            state.TargetUid = nil
            pcall(blackout.off)
            if state.Cancel and not state.Died then status("Cancelled") end
            if runtime.autoSteal then runtime.autoSteal.finish(autoRun, delivered, failReason) end
        end
    end)
    return true
end

runtime.abortTrip = function(message)
    if runtime.halloween and runtime.halloween.Active then
        runtime.halloween.cancel(message or "Cancelled")
        return
    end
    if not state.Busy or state.Aborting then return end
    state.Aborting = true
    if runtime.autoTreadmill and runtime.autoTreadmill.cancel then runtime.autoTreadmill.cancel() end
    local autoRun = state.AutoRun
    state.Cancel = true
    runtime.clearHolds()
    runtime.cancel(state.TakePending)
    state.TakePending = nil
    runtime.cancelRequest("CarryFieldEgg", "Cancelled")
    runtime.cancelRequest("DropFieldEgg", "Cancelled")
    state.TripId = (state.TripId or 0) + 1
    runtime.cancel(state.TripTask)
    state.TripTask = nil
    pcall(fpsOff)
    if state.ReleaseCamera then
        local release = state.ReleaseCamera
        state.ReleaseCamera = nil
        pcall(release)
    end
    pcall(releaseView)
    pcall(dropClone)
    pcall(blackout.off)
    if semi.Rotate then
        local info = semi.Rotate
        semi.Rotate = nil
        pcall(function() info.Hum.AutoRotate = info.Old end)
    end
    state.Busy = false
    state.TripCharacter = nil
    state.DeliveryPhase = nil
    performance.setStealing(false)
    state.TargetUid = nil
    semi.SlowRun, semi.AtDrop, semi.Plain = false, false, false
    semi.Kind, semi.Home = nil, nil
    state.Aborting = nil
    if runtime.autoSteal then runtime.autoSteal.finish(autoRun, state.TripDelivered == true, message) end
    status(message or "Cancelled")
end

runtime.OnError = function(err, tripId)
    slog((tripId and ("Trip " .. tostring(tripId)) or "Background") .. " error: " .. tostring(err))
    if tripId ~= nil and state.Busy and state.TripId == tripId then
        runtime.abortTrip("Error: " .. tostring(err))
    end
end

-- One automatic selection remains reserved across the trip's built-in retries.
runtime.autoSteal = (function()
    local api = { Enabled = false, Generation = 0, Pending = false, Active = nil, Handled = {}, NextScanAt = 0 }
    local started = false

    local function idle()
        if runtime.halloween and runtime.halloween.blocksNormal() then return false end
        if not alive or state.Busy or state.Aborting or state.Carrying or viewState or performance.Restoring then return false end
        if runtime.filterUi and runtime.filterUi.Panel and runtime.filterUi.Panel.Visible then return false end
        -- Editing event settings must not launch an unrelated normal trip.
        -- A deliberate cross-world handoff still uses this original controller.
        local halloween, settings = runtime.halloween, runtime.halloweenUi
        local handoff = halloween and halloween.NormalHandoff
        if settings and settings.IsOpen and not (halloween and halloween.Enabled
            and type(handoff) == "table" and handoff.Allow == true) then return false end
        local finder = runtime.bigEggFinder
        if finder and (finder.IsJoining or finder.IsOpen) then return false end
        local character = localPlayer.Character
        local hum = character and character:FindFirstChildOfClass("Humanoid")
        return root() ~= nil and hum ~= nil and hum.Health > 0
    end

    function api.setEnabled(enabled)
        enabled = enabled == true
        if api.Enabled == enabled then return end
        api.Enabled = enabled
        api.Generation += 1
        api.NextScanAt = 0
        if not state.Busy then status(enabled and "Auto steal: ON" or "Auto steal: OFF") end
    end

    function api.finish(token, delivered, reason, delay)
        if not token or api.Active ~= token then return end
        api.Active = nil
        if state.AutoRun == token then state.AutoRun = nil end
        api.Handled[token.Uid] = delivered and { Delivered = true }
            or { RetryAt = os.clock() + (delay or 30) }
        api.NextScanAt = os.clock() + 1
    end

    function api.startManual(uid)
        if runtime.halloween and runtime.halloween.blocksNormal() then
            status(runtime.halloween.TrainReserved and not runtime.halloween.hasCarry()
            and "Halloween: use Return home to finish the train session"
            or "Halloween: stop farming and put down carried items before normal stealing")
            return false
        end
        if not alive or state.Busy or state.Aborting or api.Active or type(uid) ~= "string" then return false end
        api.Generation += 1 -- invalidate a scanner that is waiting for a snapshot
        local cache = runtime.EggSnapshot
        local record = cache and cache.ByUid and cache.ByUid[uid]
        if record and not runtime.rarityFilter.matches(record) then
            status("Selected egg does not match filter")
            return false
        end
        -- The trip validates the fresh snapshot again before any movement.
        return stealAndDeliver(uid)
    end

    function api.step()
        if not api.Enabled or api.Pending or api.Active or os.clock() < api.NextScanAt or not idle() then return end
        local filter = runtime.rarityFilter
        if not filter.All and next(filter.Selected) == nil then
            api.NextScanAt = os.clock() + 1
            status("Choose a rarity")
            return
        end
        local generation, filterGeneration = api.Generation, filter.Generation
        local character, tripId = localPlayer.Character, state.TripId
        local function current()
            return api.Enabled and api.Generation == generation and filter.Generation == filterGeneration
                and localPlayer.Character == character and state.TripId == tripId and not api.Active and idle()
        end
        api.Pending = true
        local reserved
        local ok, err = pcall(function()
            local records = snapshot(false)
            if not current() then return end
            if state.SnapshotError or type(records) ~= "table" then
                api.NextScanAt = os.clock() + 3
                status("Auto: waiting for game data")
                return
            end
            local seen, best, bestValue = {}, nil, -1
            local bestRecord
            local earliestRetry
            local work, deadline = 0, os.clock() + 0.001
            for _, record in ipairs(records) do
                if type(record) == "table" and type(record.Uid) == "string" and record.Uid ~= "" then
                    local uid = record.Uid
                    seen[uid] = true
                    local handled = api.Handled[uid]
                    local eligible = not handled or (not handled.Delivered and os.clock() >= handled.RetryAt)
                    local matched = not (handled and handled.Delivered) and filter.matches(record)
                    if matched and not eligible then
                        earliestRetry = math.min(earliestRetry or math.huge, handled.RetryAt)
                    end
                    if eligible and matched then
                        local described, info = pcall(describe, record)
                        if not current() then return end
                        -- describe() can yield inside game metadata helpers.
                        -- The current live rarity must still qualify afterwards.
                        if described and type(info) == "table" and filter.matches(record) then
                            local value = tonumber(info.Value) or 0
                            if value ~= value or value < 0 or value == math.huge then value = 0 end
                            if not best or value > bestValue or (value == bestValue and uid < best) then
                                best, bestValue, bestRecord = uid, value, record
                            end
                        end
                    end
                end
                work += 1
                if work >= 40 or os.clock() >= deadline then
                    task.wait()
                    if not current() then return end
                    work, deadline = 0, os.clock() + 0.001
                end
            end
            if not current() then return end
            -- Only a successful full snapshot can prove that an old UID left.
            for uid in pairs(api.Handled) do if not seen[uid] then api.Handled[uid] = nil end end
            api.NextScanAt = os.clock() + 1
            if not best then
                -- Matching eggs in failure cooldown are still matches. Explain
                -- the wait using this existing one-second scan, not a new timer.
                status(earliestRetry and string.format("Auto: retrying in %ds", math.max(1, math.ceil(earliestRetry - os.clock())))
                    or "Waiting for matching eggs")
                return
            end
            if not filter.matches(bestRecord) then
                status("Auto: target changed; refreshing")
                return
            end
            reserved = { Uid = best, Generation = generation }
            api.Active = reserved
            local accepted = stealAndDeliver(best, 1, reserved)
            if not accepted and api.Active == reserved then api.finish(reserved, false, "Not ready", 5) end
        end)
        api.Pending = false
        if not ok then
            -- A stale list/metadata error must never abort a manual trip.
            if reserved and api.Active == reserved then
                if state.Busy and state.AutoRun == reserved then
                    runtime.abortTrip("Auto: trip stopped after an error")
                elseif not state.Busy then
                    api.finish(reserved, false, err)
                end
            end
            api.NextScanAt = os.clock() + 3
            slog("Auto selection: " .. tostring(err))
            if not state.Busy then status("Auto: selection failed; retrying") end
        end
    end

    function api.start()
        if started then return end
        started = true
        runtime.spawn(function()
            while alive do
                task.wait(0.25)
                if not alive then return end
                api.step()
            end
        end)
    end

    function api.stop()
        api.Enabled = false
        api.Generation += 1
        api.Active, api.Pending = nil, false
        state.AutoRun = nil
        table.clear(api.Handled)
    end
    return api
end)()

-- Source-backed Halloween field activities; all movement belongs to the supplied owner.
runtime.halloweenFieldFactory = function(ctx)
    local api = {}
    local prefs, stats, rt = ctx.Prefs, ctx.Stats, ctx.Runtime
    local player, world = ctx.Player, ctx.Workspace
    local knownNames, knownRarities = {}, {}
    local lastMobScan, lastPumpkinScan = -math.huge, -math.huge
    local cachedMob, cachedPumpkin
    local mobCandidates = {}
    local cooldown = setmetatable({}, { __mode = "k" })
    local mobProgress = setmetatable({}, { __mode = "k" })
    local nextBuyAt = 0
    local function number(value, signed)
        if type(value) ~= "number" and type(value) ~= "string" then return nil end
        local n = tonumber(value)
        return n and n == n and (signed or n >= 0) and math.abs(n) < math.huge and n or nil
    end
    local function finite(position)
        return typeof(position) == "Vector3" and position.X == position.X and position.Y == position.Y and position.Z == position.Z
            and math.abs(position.X) < math.huge and math.abs(position.Y) < math.huge and math.abs(position.Z) < math.huge
    end
    local function rejected(value)
        if value == false then return true end
        if type(value) == "string" then
            value = value:lower():match("^%s*(.-)%s*$")
            return value == "false" or value == "failed" or value == "failure" or value == "rejected"
                or value == "denied" or value == "error" or value == "invalid" or value == "cancelled" or value == "canceled"
        end
        if type(value) == "table" then
            for _, key in ipairs({"Success", "success", "Accepted", "IsSuccess", "Status", "Result", "Verdict"}) do
                if rejected(value[key]) then return true end
            end
        end
        return false
    end
    local function dimension() return world:FindFirstChild("HalloweenDimension") end
    local function pumpkinCarry()
        return ctx.attr("HalloweenPumpkinCarrying") == true or ctx.attr("PumpkinCarrying") == true
    end
    local function own(owner, kind)
        return ctx.valid(owner) and ctx.inside() and owner.TaskKind == kind
    end
    local function emptyHands()
        return not ctx.hasCarry()
    end
    local function allowed(name)
        if type(name) ~= "string" or name == "" then return false end
        if next(prefs.MobNames or {}) and prefs.MobNames[name] ~= true then return false end
        if next(prefs.MobRarities or {}) then
            local rarity = ctx.rarity(name)
            if type(rarity) ~= "string" or rarity == "" or rarity == "Unknown" or prefs.MobRarities[rarity] ~= true then return false end
        end
        return true
    end
    local function recordName(name)
        if type(name) ~= "string" or name == "" then return end
        knownNames[name] = true
        local rarity = ctx.rarity(name)
        if type(rarity) == "string" and rarity ~= "" and rarity ~= "Unknown" then knownRarities[rarity] = true end
    end
    local function batTool(tool)
        return tool and tool:IsA("Tool") and type(tool.Name) == "string" and tool.Name:lower():find("bat", 1, true) ~= nil
    end
    local function findBat()
        for _, parent in ipairs({ player.Character, player:FindFirstChild("Backpack") }) do
            if parent then
                local children = parent:GetChildren()
                for index = 1, math.min(#children, 256) do
                    if batTool(children[index]) then return children[index] end
                end
            end
        end
        return nil
    end
    local function primary(model)
        if not model then return nil end
        if model:IsA("BasePart") then return model end
        local part = model:IsA("Model") and model.PrimaryPart or nil
        return part or model:FindFirstChildWhichIsA("BasePart", true)
    end
    local function mobRecord(model)
        local h = dimension()
        local folder = h and h:FindFirstChild("Monsters")
        if not folder or not model or model.Parent ~= folder or not model:IsA("Model") or not allowed(model.Name) then return nil end
        local part = primary(model)
        local hitbox = model:FindFirstChild("Hitbox")
        if not part or not part:IsDescendantOf(model) or not finite(part.Position) or not hitbox then return nil end
        local health = number(hitbox:GetAttribute("Health"), true)
        if health ~= nil and health <= 0 then return nil end
        return { Model = model, Part = part, Hitbox = hitbox, Name = model.Name }
    end
    local function chooseMob(batch)
        if os.clock() - lastMobScan >= 0.25 then
            lastMobScan, cachedMob, mobCandidates = os.clock(), nil, {}
            local h = dimension()
            local folder = h and h:FindFirstChild("Monsters")
            if not folder then return nil end
            local children = folder:GetChildren()
            if #children > 2048 then return nil end
            for _, model in ipairs(children) do
                recordName(model.Name)
                mobCandidates[#mobCandidates + 1] = model
            end
        elseif not batch then
            return cachedMob and os.clock() >= (cooldown[cachedMob.Model] or 0) and mobRecord(cachedMob.Model) or nil
        end
        local root, distance = ctx.root(), math.huge
        if not root then return nil end
        cachedMob = nil
        for _, model in ipairs(mobCandidates) do
            local mob = mobRecord(model)
            if mob and os.clock() >= (cooldown[model] or 0) then
                local d = (mob.Part.Position - root.Position).Magnitude
                if d < distance then cachedMob, distance = mob, d end
            end
        end
        return cachedMob
    end
    local function batRemote()
        local remotes = ctx.dependency("Remotes")
        local ok, trigger = pcall(function() return remotes and remotes.BatSwing.Trigger end)
        return ok and trigger or nil, remotes
    end
    local function equipped(character)
        local first, count = nil, 0
        if character then
            for _, tool in ipairs(character:GetChildren()) do
                if tool:IsA("Tool") then first = first or tool; count += 1 end
            end
        end
        return first, count
    end
    local function ownedBat(owner, tool)
        local backpack = player:FindFirstChild("Backpack")
        return batTool(tool) and (tool.Parent == owner.Character or backpack and tool.Parent == backpack)
    end
    local function prepareTools(owner)
        local original, count = equipped(owner.Character)
        if count > 1 then return nil, "Finish changing your equipped tools" end
        local tools = { Original = original, Last = original, Bats = {}, Blocked = {}, Index = 1,
            Character = owner.Character, Root = owner.Root, Humanoid = owner.Character:FindFirstChildOfClass("Humanoid") }
        local backpack = player:FindFirstChild("Backpack")
        for _, parent in ipairs({ owner.Character, backpack }) do
            if parent then
                local children = parent:GetChildren()
                for i = 1, math.min(#children, 256) do
                    if batTool(children[i]) then tools.Bats[#tools.Bats + 1] = children[i] end
                end
            end
        end
        if #tools.Bats == 0 or not tools.Humanoid then return nil, "A bat in your backpack is required" end
        owner.FieldTools = tools
        return tools
    end
    local function equipBat(owner, tools, tool)
        if not own(owner, "Mob") or not emptyHands() or not prefs.HitMobs or not ownedBat(owner, tool) then
            return false, "Bat changed; try again"
        end
        local current, count = equipped(owner.Character)
        if count > 1 or (current ~= tools.Last and current ~= tools.Pending)
            or (current == nil and tools.Last and ownedBat(owner, tools.Last)) then
            tools.Abandoned = true
            return false, "Equipped tool changed; mob farming stopped"
        end
        if current == tool then tools.Last = tool; return true end
        local ok, accepted = ctx.request(owner, "FieldEquipBat", 1.25, function()
            if not own(owner, "Mob") or not emptyHands() or not prefs.HitMobs or not ownedBat(owner, tool) then return false end
            local live, amount = equipped(owner.Character)
            if amount > 1 or live ~= current then tools.Abandoned = true; return false end
            tools.Pending = tool
            tools.Humanoid:EquipTool(tool)
            if tool.Parent == owner.Character then tools.Last = tool; tools.Changed = true end
            return true
        end)
        tools.Pending = nil
        if not own(owner, "Mob") then return false, "Mob farming cancelled" end
        local after, amount = equipped(owner.Character)
        if amount > 1 or (after ~= tool and after ~= current) then tools.Abandoned = true; return false, "Equipped tool changed" end
        if not ok or accepted ~= true or after ~= tool or tool.Parent ~= owner.Character then
            tools.Blocked[tool] = true
            return false, "Bat equip was not confirmed"
        end
        tools.Last, tools.Changed = tool, true
        return true
    end
    local function restoreTools(owner)
        local tools = owner.FieldTools
        owner.FieldTools = nil
        if not tools or not tools.Changed or tools.Abandoned or player.Character ~= tools.Character
            or ctx.root() ~= tools.Root or not tools.Humanoid or tools.Humanoid.Health <= 0
            or tools.Character:FindFirstChildOfClass("Humanoid") ~= tools.Humanoid then return end
        -- Coordinator cleanup invokes this only for its exact current body.
        -- Never overwrite a tool manually selected since our last equip.
        local active = ctx.API and ctx.API.Active
        if active ~= nil and active ~= owner then return end
        local current, count = equipped(tools.Character)
        if count ~= 1 or (current ~= tools.Last and current ~= tools.Pending) then return end
        local original = tools.Original
        local backpack = player:FindFirstChild("Backpack")
        if original and original ~= current then
            if original:IsA("Tool") and original.Parent == backpack then pcall(tools.Humanoid.EquipTool, tools.Humanoid, original) end
        elseif original == nil then
            pcall(tools.Humanoid.UnequipTools, tools.Humanoid)
        end
    end
    local function usableBats(owner, tools)
        local count = 0
        for _, tool in ipairs(tools.Bats) do
            if not tools.Blocked[tool] and ownedBat(owner, tool) then count += 1 end
        end
        return count
    end
    local function nextBat(owner, tools)
        for offset = 1, #tools.Bats do
            local index = (tools.Index + offset - 1) % #tools.Bats + 1
            local tool = tools.Bats[index]
            if not tools.Blocked[tool] and ownedBat(owner, tool) then return tool, index end
        end
    end
    local function continueMob(owner)
        if not prefs.HitMobs or not own(owner, "Mob") or not emptyHands() then return false, "Mob farming stopped", false end
        -- The coordinator renews only this exact healthy owner's lease and
        -- yields when another ready activity needs a turn. No target or hit cap.
        if type(ctx.continueMob) ~= "function" or ctx.continueMob(owner) ~= true then
            owner.MobYielded = true
            return false, "Yielding to other enabled activities", true
        end
        if not own(owner, "Mob") or not emptyHands() then return false, "Mob farming stopped", false end
        return true
    end
    local function hitMob(owner, mob, tools)
        local trigger, remotes = batRemote()
        local readable, fire = pcall(function() return trigger and trigger.FireServer end)
        if not readable or type(fire) ~= "function" then return false, "Halloween bat remote unavailable" end
        local hitRequested = false
        local progress = mobProgress[mob.Model]
        if not progress or progress.Hitbox ~= mob.Hitbox then
            progress = { Hitbox = mob.Hitbox, Health = number(mob.Hitbox:GetAttribute("Health"), true), Elapsed = 0 }
            mobProgress[mob.Model] = progress
        end
        -- Preserve attempted work across scheduler turns, without counting
        -- the time another activity owns movement against this monster.
        local activeAt = os.clock()
        local function dead()
            local health = number(mob.Hitbox:GetAttribute("Health"), true)
            return hitRequested and health ~= nil and health <= 0
        end
        while true do
            if not prefs.HitMobs or not own(owner, "Mob") or not emptyHands() then return false, "Mob farming stopped" end
            if dead() then return true, "Monster defeat confirmed" end
            local now = os.clock()
            progress.Elapsed += math.max(0, now - activeAt)
            activeAt = now
            local health = number(mob.Hitbox:GetAttribute("Health"), true)
            if health ~= nil then
                if progress.Health ~= nil and health < progress.Health then progress.Elapsed = 0 end
                progress.Health = health
            end
            -- Missing/unchanging server health is not proof of a kill. Give
            -- this target a rest, then keep farming other eligible monsters.
            if progress.Elapsed >= 5 then return false, "No server health progress; trying another monster", "stalled" end
            local permitted, permitReason, yielded = continueMob(owner)
            if not permitted then
                if yielded then return nil, permitReason end
                return false, permitReason
            end
            local current = mobRecord(mob.Model)
            if not current or current.Part ~= mob.Part or current.Hitbox ~= mob.Hitbox then return false, "Monster changed; defeat unconfirmed" end
            local bat, count = equipped(owner.Character)
            if count ~= 1 or bat ~= tools.Last or not ownedBat(owner, bat) then
                tools.Abandoned = true
                return false, "Equipped bat changed"
            end
            if not ctx.move(owner, mob.Part.Position + Vector3.new(0, 2, 0)) then return false, "Monster position unavailable" end
            ctx.report("Hitting " .. mob.Name)
            local sentAt = os.clock()
            local ok, answer = ctx.request(owner, "FieldBatHit", 1.25, function()
                local live, liveRemotes = batRemote()
                local target = mobRecord(mob.Model)
                local held, amount = equipped(owner.Character)
                if not own(owner, "Mob") or not emptyHands() or not prefs.HitMobs or live ~= trigger or liveRemotes ~= remotes
                    or not target or target.Part ~= mob.Part or target.Hitbox ~= mob.Hitbox or held ~= bat or amount ~= 1 then return false end
                local stamp = os.clock()
                pcall(function() stamp = world:GetServerTimeNow() end)
                if type(stamp) ~= "number" or stamp ~= stamp or math.abs(stamp) == math.huge then stamp = os.clock() end
                owner.FieldHitSequence = (owner.FieldHitSequence or 0) + 1
                hitRequested = true
                trigger:FireServer(mob.Model, ("%d:%d:%d"):format(player.UserId, owner.FieldHitSequence, math.floor(stamp * 1000)))
                return true
            end)
            if not ok or answer ~= true or not own(owner, "Mob") then return false, "Bat hit failed or timed out" end
            local live, liveRemotes = batRemote()
            if live ~= trigger or liveRemotes ~= remotes then return false, "Bat remote changed" end
            -- Sena v7's supported rhythm: one bat every 0.05s; multiple
            -- owned bats rotate every 0.10s. Never catch up with a burst.
            local pace = usableBats(owner, tools) >= 2 and 0.10 or 0.05
            if not dead() and pace == 0.10 then
                local alternate, index = nextBat(owner, tools)
                if alternate and alternate ~= tools.Last then
                    local swapped, why = equipBat(owner, tools, alternate)
                    if not own(owner, "Mob") or tools.Abandoned then return false, why end
                    if swapped then tools.Index = index
                    elseif not ownedBat(owner, tools.Last) or tools.Last.Parent ~= owner.Character then return false, why end
                    if usableBats(owner, tools) < 2 then pace = 0.05 end
                end
            end
            local delay = math.max(0.01, pace - (os.clock() - sentAt))
            if not ctx.wait(owner, delay) then return false, "Mob farming cancelled" end
        end
    end
    local function runMob(owner)
        if not prefs.HitMobs or not own(owner, "Mob") or not emptyHands() then return nil, "Mob farming is unavailable" end
        local mob = chooseMob()
        if not mob then return nil, "No matching live Halloween monsters" end
        local permitted, permitReason, yielded = continueMob(owner)
        if not permitted then
            if yielded then return nil, permitReason end
            return false, permitReason
        end
        local tools, reason = prepareTools(owner)
        if not tools then return false, reason end
        local equippedOK, equipReason = equipBat(owner, tools, tools.Bats[1])
        if not equippedOK then return false, equipReason end
        local confirmed, lastReason = 0, nil
        while mob do
            local permittedNow, why, gaveTurn = continueMob(owner)
            if not permittedNow then
                if gaveTurn then return nil, why end
                return false, why
            end
            local defeated, result, skipped = hitMob(owner, mob, tools)
            if not own(owner, "Mob") then return false, "Mob farming cancelled" end
            if defeated == true then
                stats.Killed = (stats.Killed or 0) + 1
                confirmed += 1
                cooldown[mob.Model], cachedMob = os.clock() + 10, nil
                mobProgress[mob.Model] = nil
            elseif defeated == false then
                cooldown[mob.Model], cachedMob = os.clock() + 5, nil
                mobProgress[mob.Model] = nil -- a bounded retry may start after this backoff
                if skipped ~= "stalled" then return false, result end
                lastReason = result
                ctx.report(result)
            else
                return nil, result
            end
            local keepGoing, nextReason, nextYielded = continueMob(owner)
            if not keepGoing then
                if nextYielded then return nil, nextReason end
                return false, nextReason
            end
            mob = chooseMob(true)
        end
        if confirmed > 0 then return true, ("Confirmed %d monster defeat(s)"):format(confirmed) end
        return nil, lastReason or "Waiting for matching live monsters"
    end
    local function pumpkinBox()
        local h = dimension()
        if not h then return nil end
        local children = h:GetChildren()
        for index = 1, math.min(#children, 256) do
            local child = children[index]
            local name = child.Name:lower()
            if (child:IsA("Model") or child:IsA("Folder")) and name ~= "pumpkinmoon"
                and (name:find("runaway", 1, true) or name:find("pumpkin", 1, true)) and #child:GetChildren() > 0 then return child end
        end
        return nil
    end
    local function otherPlayerHolds(part)
        local assembly = part.AssemblyRootPart
        local model = assembly and assembly:FindFirstAncestorOfClass("Model")
        local ok, owner = pcall(function() return model and ctx.Players:GetPlayerFromCharacter(model) end)
        if ok and owner and owner ~= player then return true end
        for _, other in ipairs(ctx.Players:GetPlayers()) do
            if other ~= player and (other:GetAttribute("HalloweenPumpkinCarrying") == true
                or other:GetAttribute("PumpkinCarrying") == true) then
                local root = other.Character and other.Character:FindFirstChild("HumanoidRootPart")
                if root and finite(root.Position) and (root.Position - part.Position).Magnitude < 8 then return true end
            end
        end
        return false
    end
    local function pumpkinRecord(model)
        local folder = pumpkinBox()
        if not folder or not model or model.Parent ~= folder then return nil end
        local part = primary(model)
        if not part or not finite(part.Position) or (part ~= model and not part:IsDescendantOf(model)) or otherPlayerHolds(part) then return nil end
        local prompt = model:FindFirstChildWhichIsA("ProximityPrompt", true)
        if prompt and (prompt.Enabled ~= true or not prompt:IsDescendantOf(model)) then return nil end
        return { Model = model, Part = part, Prompt = prompt, Folder = folder }
    end
    local function choosePumpkin()
        if os.clock() - lastPumpkinScan < 1 then return cachedPumpkin and pumpkinRecord(cachedPumpkin.Model) end
        lastPumpkinScan, cachedPumpkin = os.clock(), nil
        local box, root = pumpkinBox(), ctx.root()
        if not box or not root then return nil end
        local children, distance = box:GetChildren(), math.huge
        if #children > 2048 then return nil end
        for _, model in ipairs(children) do
            local p = pumpkinRecord(model)
            if p and os.clock() >= (cooldown[model] or 0) then
                local d = (p.Part.Position - root.Position).Magnitude
                if d < distance then cachedPumpkin, distance = p, d end
            end
        end
        return cachedPumpkin
    end
    local function touchFunction()
        local env = rt.Env
        local fn = type(env) == "table" and env.firetouchinterest or nil
        if type(fn) ~= "function" then
            pcall(function() if type(firetouchinterest) == "function" then fn = firetouchinterest end end)
        end
        return fn
    end
    local function depositRecord()
        local h = dimension()
        local altar = h and h:FindFirstChild("Altar")
        local object = altar and altar:FindFirstChild("PumpkinDeposit")
        local part = primary(object)
        if not part or not finite(part.Position) or (part ~= object and not part:IsDescendantOf(object)) then return nil end
        local prompt = object:FindFirstChildWhichIsA("ProximityPrompt", true)
        if prompt and (prompt.Enabled ~= true or not prompt:IsDescendantOf(object)) then return nil end
        return { Model = object, Part = part, Prompt = prompt }
    end
    local function interactionCarry(deposit)
        return deposit and pumpkinCarry() or (not deposit and emptyHands())
    end
    local function interact(owner, record, deposit)
        local current = deposit and depositRecord() or pumpkinRecord(record.Model)
        if not current or current.Model ~= record.Model or current.Part ~= record.Part or current.Prompt ~= record.Prompt then return false end
        if not own(owner, "Pumpkin") or not prefs.CollectPumpkins or not interactionCarry(deposit) then return false end
        if record.Prompt then
            owner.Prompts = owner.Prompts or {}
            owner.Prompts[record.Prompt] = true
            local ok, fired = ctx.request(owner, deposit and "FieldPumpkinDeposit" or "FieldPumpkinPickup", 1.2, function()
                local live = deposit and depositRecord() or pumpkinRecord(record.Model)
                if not own(owner, "Pumpkin") or not prefs.CollectPumpkins or not interactionCarry(deposit) or not live or live.Model ~= record.Model
                    or live.Part ~= record.Part or live.Prompt ~= record.Prompt then return false end
                return rt.firePrompt(record.Prompt)
            end)
            return ok and fired == true and own(owner, "Pumpkin")
        end
        local touch = touchFunction()
        if not touch then return false end
        local ok, touched = ctx.request(owner, deposit and "FieldPumpkinDepositTouch" or "FieldPumpkinPickupTouch", 1.2, function()
            local live = deposit and depositRecord() or pumpkinRecord(record.Model)
            if not own(owner, "Pumpkin") or not prefs.CollectPumpkins or not interactionCarry(deposit) or not live or live.Model ~= record.Model
                or live.Part ~= record.Part or live.Prompt ~= nil then return false end
            touch(record.Part, owner.Root, 0)
            if not own(owner, "Pumpkin") then return false end
            local still = deposit and depositRecord() or pumpkinRecord(record.Model)
            local transitioned = deposit and not pumpkinCarry() or (not deposit and pumpkinCarry())
            if not transitioned and (not still or still.Model ~= record.Model or still.Part ~= record.Part) then return false end
            touch(record.Part, owner.Root, 1)
            return true
        end)
        return ok and touched == true and own(owner, "Pumpkin")
    end
    local function runPumpkin(owner)
        if not prefs.CollectPumpkins or not own(owner, "Pumpkin") then return nil, "Pumpkin collection is unavailable" end
        local before = number(ctx.attr("HalloweenPumpkins"))
        if before == nil then return false, "Pumpkin reward counter unavailable" end
        local deposit = depositRecord()
        if not deposit then return nil, "Pumpkin altar unavailable or disabled" end
        if not pumpkinCarry() then
            if not emptyHands() then return false, "A different carried item is preserved" end
            local pumpkin = choosePumpkin()
            if not pumpkin then return nil, "No available Pumpkin Moon pumpkins" end
            local picked = false
            for _ = 1, 30 do
                if not own(owner, "Pumpkin") or not prefs.CollectPumpkins then return false, "Pumpkin pickup cancelled" end
                if pumpkinCarry() then picked = true; break end
                local current = pumpkinRecord(pumpkin.Model)
                if not current or current.Part ~= pumpkin.Part or current.Prompt ~= pumpkin.Prompt then return false, "Selected pumpkin changed" end
                if not ctx.move(owner, pumpkin.Part.Position + Vector3.new(0, 2, 0)) then return false, "Pumpkin position unavailable" end
                if not interact(owner, pumpkin, false) then return false, "Pumpkin pickup failed or timed out" end
                if pumpkinCarry() then picked = true; break end
                if not ctx.wait(owner, 0.12) then return false, "Pumpkin pickup cancelled" end
            end
            cooldown[pumpkin.Model], cachedPumpkin = os.clock() + 5, nil
            if not picked then return false, "Pumpkin pickup was not confirmed" end
        end
        if not own(owner, "Pumpkin") or not prefs.CollectPumpkins or not pumpkinCarry() then return false, "Pumpkin carry changed" end
        ctx.report("Depositing Pumpkin Moon pumpkin")
        local requested = false
        for _ = 1, 30 do
            if not own(owner, "Pumpkin") or not prefs.CollectPumpkins then return false, "Pumpkin deposit cancelled" end
            local amount = number(ctx.attr("HalloweenPumpkins"))
            if requested and not pumpkinCarry() and amount ~= nil and amount > before then
                stats.Pumpkins = (stats.Pumpkins or 0) + 1
                return true, "Pumpkin reward confirmed"
            end
            if pumpkinCarry() then
                local current = depositRecord()
                if not current or current.Model ~= deposit.Model or current.Part ~= deposit.Part or current.Prompt ~= deposit.Prompt then return false, "Pumpkin altar changed" end
                requested = true
                if not ctx.move(owner, deposit.Part.Position + Vector3.new(0, 2, 0)) then return false, "Pumpkin altar position unavailable" end
                -- The live altar may accept on physical contact before its
                -- optional prompt runs. Confirmation still needs both signals.
                if pumpkinCarry() and not interact(owner, deposit, true) then return false, "Pumpkin deposit failed or timed out" end
            end
            if not ctx.wait(owner, 0.15) then return false, "Pumpkin deposit cancelled" end
        end
        return false, "Pumpkin deposit unconfirmed; carried item preserved"
    end
    local function buyRemote()
        local remotes = ctx.dependency("Remotes")
        local ok, remote = pcall(function() return remotes and remotes.HalloweenDimension.AskBuyEgg end)
        return ok and remote or nil, remotes
    end
    local function buy(owner)
        if not prefs.AutoBuy or not own(owner, "AutoBuy") or not emptyHands() then return nil, "Auto Buy is unavailable" end
        local before, reason = ctx.candy(owner)
        if not own(owner, "AutoBuy") or not prefs.AutoBuy or not emptyHands() then return false, "Auto Buy cancelled" end
        before = number(before)
        if before == nil then return nil, reason or "Candy Corn balance unavailable" end
        stats.Candy = before
        nextBuyAt = os.clock() + 5
        if before < 2250 then return nil, "Auto Buy needs 2250 Candy Corn" end
        local event, remotes = buyRemote()
        local readable, invoke = pcall(function() return event and event.InvokeServer end)
        if not readable or type(invoke) ~= "function" then return nil, "Halloween shop remote unavailable" end
        ctx.report("Buying Halloween egg for 2250 Candy Corn")
        local sent = false
        local ok, result = ctx.request(owner, "FieldBuyEgg", 3, function()
            local current, currentRemotes = buyRemote()
            if not own(owner, "AutoBuy") or not prefs.AutoBuy or not emptyHands() or current ~= event or currentRemotes ~= remotes then return false end
            sent = true
            owner.FieldPurchasePending = true
            return event:InvokeServer()
        end)
        if not sent then return false, "Auto Buy cancelled before purchase" end
        local current, currentRemotes = buyRemote()
        if not own(owner, "AutoBuy") or not ok or current ~= event or currentRemotes ~= remotes then
            prefs.AutoBuy = false
            return false, "Purchase unconfirmed; Auto Buy paused to prevent another spend"
        end
        if rejected(result) then
            owner.FieldPurchasePending = nil
            return false, "Halloween shop rejected the purchase"
        end
        local confirmed = result == true
        if not confirmed then
            for _ = 1, 4 do
                if not own(owner, "AutoBuy") or not emptyHands() then break end
                local after = number(ctx.candy(owner))
                if after ~= nil then
                    stats.Candy = after
                    if before - after >= 2250 then confirmed = true; break end
                end
                if not ctx.wait(owner, 0.25) then break end
            end
        end
        if confirmed and own(owner, "AutoBuy") and emptyHands() then
            owner.FieldPurchasePending = nil
            stats.Bought = (stats.Bought or 0) + 1
            return true, "Halloween egg purchase confirmed"
        end
        prefs.AutoBuy = false
        return false, "Purchase unconfirmed; Auto Buy paused to prevent another spend"
    end
    function api.ready(kind)
        if kind == "Mob" then
            if not prefs.HitMobs or not emptyHands() then return false end
            if not findBat() then return false, "A bat in your backpack is required" end
            return chooseMob() ~= nil, "No matching live Halloween monsters"
        elseif kind == "Pumpkin" then
            if not prefs.CollectPumpkins then return false end
            if pumpkinCarry() then return depositRecord() ~= nil, "Pumpkin altar unavailable" end
            if not emptyHands() then return false end
            return choosePumpkin() ~= nil, "Waiting for available Pumpkin Moon pumpkins"
        elseif kind == "AutoBuy" then
            return prefs.AutoBuy == true and emptyHands() and os.clock() >= nextBuyAt, "Auto Buy is waiting"
        end
        return false
    end
    function api.step(owner, kind)
        if kind == "Mob" then return runMob(owner) end
        if kind == "Pumpkin" then return runPumpkin(owner) end
        if kind == "AutoBuy" then return buy(owner) end
        return nil, "Unknown Halloween field activity"
    end
    function api.cancel(owner)
        if not owner then return end
        restoreTools(owner)
        -- A cancelled InvokeServer may already have spent currency remotely.
        -- Require a fresh, explicit Auto Buy opt-in before another request.
        if owner.FieldPurchasePending then
            prefs.AutoBuy = false
            owner.FieldPurchasePending = nil
        end
        for prompt in pairs(owner.Prompts or {}) do
            local record = rt.PromptHolds and rt.PromptHolds[prompt]
            if record then rt.restorePrompt(prompt, record) end
        end
    end
    function api.catalog()
        local pets = ctx.dependency("Pets")
        local specs = pets and type(pets.Specs) == "table" and pets.Specs or {}
        local count = 0
        for name in pairs(specs) do count += 1;if count > 512 then break end;recordName(name) end
        local names, rarities = {}, {}
        for name in pairs(knownNames) do names[#names + 1] = name end
        for name in pairs(knownRarities) do rarities[#rarities + 1] = name end
        table.sort(names);table.sort(rarities)
        return names, rarities
    end
    return api
end
-- End Halloween field activities


-- Ghost Dog lake fishing stays inside the Halloween movement reservation.
runtime.halloweenFishingFactory = function(ctx)
    local api, runtime = ctx.API, ctx.Runtime
    local player, storage, world = ctx.Player, ctx.ReplicatedStorage, ctx.Workspace
    local feature = {}
    local modules, sessions = {}, setmetatable({}, { __mode = "k" })
    local pauseUntil = 0
    local HOLD_SECONDS, REEL_CLICKS = 1.09, 18
    local FALLBACK_SPOT = Vector3.new(-5317.7, -203.65, -6128.83)
    local FALLBACK_TARGET = Vector3.new(-5317.7, -207.62, -6156.83)

    local function finite(v)
        return type(v) == "number" and v == v and math.abs(v) < math.huge
    end
    local function vector(p)
        return typeof(p) == "Vector3" and finite(p.X) and finite(p.Y) and finite(p.Z)
    end
    local function rejected(value)
        if value == false then return true end
        local words = { failed = true, failure = true, rejected = true, denied = true, error = true, ["false"] = true }
        local function negative(v)
            return v == false or type(v) == "string" and words[v:lower():match("^%s*(.-)%s*$")] == true
        end
        if type(value) == "string" then return negative(value) end
        if type(value) == "table" then
            for _, key in ipairs({ "Success", "success", "Accepted", "accepted", "IsSuccess", "Status", "Result", "Verdict" }) do
                if negative(value[key]) then return true end
            end
        end
        return false
    end
    local function find(path)
        local current = storage
        for _, name in ipairs(path) do current = current and current:FindFirstChild(name) end
        return current
    end
    local function load(path)
        local inst = find(path)
        if not inst then return nil, false end
        if modules[inst] then return modules[inst], true end
        runtime.loadDependency(inst, function() return inst end, function(value)
            if find(path) == inst then modules[inst] = value end
        end)
        return modules[inst], true
    end
    local function rod()
        for _, container in ipairs({ player.Character, player:FindFirstChild("Backpack") }) do
            if container then
                for _, tool in ipairs(container:GetChildren()) do
                    if tool:IsA("Tool") and tool:GetAttribute("GhostDogRod") then return tool end
                end
            end
        end
        return nil
    end
    local function allowed(owner)
        return ctx.valid(owner) and api.AutoFish == true and ctx.inside() and not ctx.hasCarry()
    end
    local function currentTool(owner, session)
        return allowed(owner) and session.Rod and session.Rod.Parent == owner.Character
    end
    local function invoke(owner, name, seconds, ...)
        if not allowed(owner) then return false, "Fishing cancelled" end
        local event = ctx.Remote(name)
        if not event or not event:IsA("RemoteFunction") then return false, "Fishing remote unavailable: " .. name end
        local values = table.pack(ctx.request(owner, "Fish:" .. name, seconds, function(...)
            if not allowed(owner) or ctx.Remote(name) ~= event then error("Fishing remote changed") end
            return event:InvokeServer(...)
        end, ...))
        if not allowed(owner) or ctx.Remote(name) ~= event then return false, "Fishing ownership or remote changed" end
        if values[1] and rejected(values[2]) then return false, "Fishing action was rejected" end
        return table.unpack(values, 1, values.n)
    end
    local function fire(owner, name, ...)
        if not allowed(owner) then return false end
        local event = ctx.Remote(name)
        if not event or not event:IsA("RemoteEvent") then return false end
        local ok = ctx.request(owner, "Fish:" .. name, 1, function(...)
            if not allowed(owner) or ctx.Remote(name) ~= event then error("Fishing event changed") end
            event:FireServer(...)
        end, ...)
        return ok and allowed(owner) and ctx.Remote(name) == event
    end
    local function cancelCast(owner, session)
        local id, event = session.CastId, session.CancelRemote
        session.CastId, session.CancelRemote = nil, nil
        -- FireServer is nonyielding; this cleanup never queues a worker that
        -- could later cancel a new character's cast or a replacement session.
        if id == nil or not event or api.Active ~= owner or player.Character ~= owner.Character
            or ctx.root() ~= owner.Root or ctx.Remote("RE/Fishing/Cancel") ~= event then return end
        pcall(event.FireServer, event, id)
    end
    local function restoreTool(owner, session)
        if api.Active ~= owner or player.Character ~= owner.Character or ctx.root() ~= owner.Root or not session.Equipped
            or not session.Rod or session.Rod.Parent ~= owner.Character then return end
        local hum = owner.Character:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then return end
        local previous = session.PreviousTool
        if previous and previous.Parent == player:FindFirstChild("Backpack") then
            pcall(hum.EquipTool, hum, previous)
        else
            -- Unequip only while the rod we equipped remains the equipped tool.
            pcall(hum.UnequipTools, hum)
        end
    end
    function feature.cancel(owner)
        local session = sessions[owner]
        if not session then return owner.FishingCleanupReason end
        cancelCast(owner, session)
        restoreTool(owner, session)
        sessions[owner] = nil
        if session.QuestStarted then
            -- The donor delays a failed quest by three seconds. This prevents
            -- immediate retry spam; it is not evidence that server state reset.
            pauseUntil = math.max(pauseUntil, os.clock() + 3)
            owner.FishingCleanupReason = "Fishing stopped; Ghost Dog server cleanup unconfirmed"
            return owner.FishingCleanupReason
        end
    end
    local function marker(name)
        local dimension = world:FindFirstChild("HalloweenDimension")
        local quest = dimension and dimension:FindFirstChild("GhostDogQuest")
        local markers = quest and quest:FindFirstChild("Markers")
        local part = markers and markers:FindFirstChild(name)
        return part and part:IsA("BasePart") and vector(part.Position) and part or nil
    end
    local function hop(owner, destination, stride, gap)
        if not allowed(owner) or not vector(destination) then return false end
        local position = owner.Root.Position
        if not vector(position) or (destination - position).Magnitude > 10000 then return false end
        local hops = 0
        while (destination - position).Magnitude > 0.5 do
            if not allowed(owner) then return false end
            hops += 1
            if hops > 180 then return false end
            local delta = destination - position
            position = delta.Magnitude > stride and position + delta.Unit * stride or destination
            if not ctx.move(owner, position) or not ctx.wait(owner, gap) then return false end
        end
        return allowed(owner)
    end
    local function wallSealed(owner)
        local wall, exists = load({ "Client", "AreaEggResetWall" })
        if not exists then return false end
        if not wall then return nil end
        for _, name in ipairs({ "IsSealed", "IsClosed" }) do
            if type(wall[name]) == "function" then
                local ok, value = ctx.request(owner, "Fish:Wall", 1, wall[name])
                if not ok or not allowed(owner) then return nil end
                if value == true then return true end
            end
        end
        return false
    end
    local function approach(owner, target)
        local z, centerX, halfWidth = -7238, -5808, 390
        local dimension = world:FindFirstChild("HalloweenDimension")
        local wall = dimension and dimension:FindFirstChild("NightWall")
        local curtain = wall and (wall:FindFirstChild("Curtain") or wall:FindFirstChild("Barrier"))
        if curtain and curtain:IsA("BasePart") and vector(curtain.Position) and vector(curtain.Size) then
            z, centerX, halfWidth = curtain.Position.Z, curtain.Position.X, curtain.Size.X / 2
        end
        local position = owner.Root.Position
        local fromSafe = position.Z < z
        if fromSafe ~= (target.Z < z) then
            if fromSafe and wallSealed(owner) ~= false then return false, "Waiting for the night wall" end
            if not allowed(owner) then return false, "Fishing cancelled" end
            if halfWidth < 31 then return false, "Night wall crossing unavailable" end
            local reference = fromSafe and target or position
            local x = math.clamp(reference.X, centerX - halfWidth + 30, centerX + halfWidth - 30)
            local a, b = Vector3.new(x, -201, z - 55), Vector3.new(x, -201, z + 23)
            if not fromSafe then a, b = b, a end
            if not hop(owner, a, 850, 0.15) or not hop(owner, b, 12, 0.03) then return false, "Night wall crossing stopped" end
        end
        if not hop(owner, target, 850, 0.15) then return false, "Fishing approach stopped" end
        return allowed(owner) and (owner.Root.Position - target).Magnitude <= 6, "Could not reach the fishing spot"
    end
    local function questStage(owner)
        local save = ctx.dependency("Save")
        if not save or type(save.Peek) ~= "function" then return nil end
        local ok, data = ctx.request(owner, "Fish:Save", 1.25, save.Peek)
        if not ok or not allowed(owner) or ctx.dependency("Save") ~= save then return nil end
        local stage = type(data) == "table" and type(data.GhostDogQuest) == "table" and tonumber(data.GhostDogQuest.Stage)
        return finite(stage) and stage >= 0 and stage % 1 == 0 and stage or nil
    end
    local function water(owner, target)
        local fishing = load({ "Shared", "Util", "Fishing" })
        if fishing and type(fishing.Probe) == "function" then
            local ok, hit = ctx.request(owner, "Fish:Probe", 1.25, fishing.Probe, target, { owner.Character })
            if not allowed(owner) then return nil end
            if ok and type(hit) == "table" and hit.Water and vector(hit.Point) then return hit.Point end
        end
        return target
    end
    local function cast(owner, session, target)
        if not currentTool(owner, session) then return nil, "Haunted Rod is no longer equipped" end
        local cancelRemote = ctx.Remote("RE/Fishing/Cancel")
        if not cancelRemote or not cancelRemote:IsA("RemoteEvent") then return nil, "Fishing cancel event unavailable" end
        if not fire(owner, "RE/Fishing/Hold") or not ctx.wait(owner, HOLD_SECONDS) then return nil, "Fishing hold stopped" end
        if not currentTool(owner, session) then return nil, "Haunted Rod changed during hold" end
        local point = water(owner, target)
        if not point then return nil, "Fishing cancelled" end
        if not currentTool(owner, session) then return nil, "Haunted Rod changed during water probe" end
        local ok, result = invoke(owner, "RF/Fishing/Cast", 3, HOLD_SECONDS, point)
        if not ok or type(result) ~= "table" then
            pauseUntil = os.clock() + 10
            return nil, "Cast response unconfirmed; retry later"
        end
        local id = result.Id
        if (type(id) ~= "string" or id == "") and not (finite(id) and id >= 0) then
            pauseUntil = os.clock() + 10
            return nil, "Cast returned no usable session ID"
        end
        if ctx.Remote("RE/Fishing/Cancel") ~= cancelRemote then return nil, "Fishing cancel event changed" end
        session.CastId, session.CancelRemote = id, cancelRemote
        if not currentTool(owner, session) then return nil, "Haunted Rod changed during cast" end
        return result
    end
    local function questLeg(owner, session, result)
        if result.Mode ~= "Quest" then return nil, "Waiting for the Ghost Dog quest cast" end
        cancelCast(owner, session)
        if not allowed(owner) then return false, "Fishing cancelled" end
        local ok = invoke(owner, "RF/GhostDogQuest/Cast", 3)
        if not ok then return false, "Ghost Dog quest cast was not accepted" end
        session.QuestStarted = true
        local diving = invoke(owner, "RF/GhostDogQuest/Dive", 3)
        if not diving then return false, "Ghost Dog dive was not accepted" end
        local config = load({ "Data", "GhostDogQuest" })
        local seconds = config and tonumber(config.ChaseSeconds) or 50
        if not finite(seconds) or seconds < 1 or seconds > 60 then seconds = 50 end
        ctx.report("Ghost Dog quest: waiting for the chase")
        if not ctx.wait(owner, seconds + 1) or not allowed(owner) then return false, "Ghost Dog quest stopped" end
        for _ = 1, 15 do
            if not allowed(owner) then return false, "Ghost Dog quest stopped" end
            local claimed, value = invoke(owner, "RF/GhostDogQuest/Claim", 2)
            if claimed and value == true then
                api.Stats.FishQuests = (api.Stats.FishQuests or 0) + 1
                return true, "Ghost Dog quest reward confirmed"
            end
            if not ctx.wait(owner, 1) then return false, "Ghost Dog quest stopped" end
        end
        return false, "Ghost Dog quest reward was not confirmed"
    end
    local function normalCatch(owner, session, result, spot)
        if result.Mode == "Nothing" or result.Mode == "Hint" or result.Mode == "Quest" or result.Mode == "GhostFish" then
            return nil, "Waiting for a normal fishing catch"
        end
        if type(result.Mode) ~= "string" or result.Mode == "" then return false, "Unknown fishing response" end
        local delay = result.Wait == nil and 3 or tonumber(result.Wait)
        if not finite(delay) or delay < 0 or delay > 30 then return false, "Invalid fishing wait time" end
        local finishAt = os.clock() + delay + 1
        local repositionAt = 0
        while os.clock() < finishAt do
            if not currentTool(owner, session) then return false, "Fishing stopped before reel" end
            if os.clock() >= repositionAt then
                repositionAt = os.clock() + 0.5
                if not ctx.move(owner, spot) then return false, "Fishing position lost" end
            end
            if not ctx.wait(owner, 0.05) then return false, "Fishing stopped before reel" end
        end
        local ok, caught = invoke(owner, "RF/Fishing/Reel", 3, session.CastId, "Caught", REEL_CLICKS)
        if not ok or caught ~= true then return false, "Fishing catch was not confirmed" end
        session.CastId, session.CancelRemote = nil, nil
        api.Stats.Fished = (api.Stats.Fished or 0) + 1
        return true, "Fish caught; server confirmed"
    end
    function feature.ready(kind)
        if kind ~= "Fishing" or api.AutoFish ~= true then return false end
        if os.clock() < pauseUntil then return false, "Fishing cooldown" end
        if not rod() then return false, "Haunted Rod required (Gilbert quest)" end
        return true
    end
    function feature.step(owner, kind)
        if kind ~= "Fishing" or not allowed(owner) then return nil, "Fishing is unavailable" end
        local tool = rod()
        if not tool then return nil, "Haunted Rod required (Gilbert quest)" end
        local session = { Rod = tool }
        sessions[owner] = session
        local ok, result, reason = pcall(function()
            load({ "Shared", "Util", "Fishing" }); load({ "Data", "GhostDogQuest" }); load({ "Client", "AreaEggResetWall" })
            local stage = questStage(owner)
            if stage == nil then return nil, "Ghost Dog quest data unavailable" end
            local spotPart, targetPart = marker("CastSpot"), marker("CastTarget")
            local spot = (spotPart and spotPart.Position or FALLBACK_SPOT) + Vector3.new(0, 2, 0)
            local target = targetPart and targetPart.Position or FALLBACK_TARGET
            ctx.report("Going to Ghost Dog's lake")
            local reached, moveReason = approach(owner, spot)
            if not reached then return false, moveReason end
            if not allowed(owner) or tool ~= rod() then return false, "Haunted Rod changed" end
            if tool.Parent ~= owner.Character then
                local hum = owner.Character:FindFirstChildOfClass("Humanoid")
                if not hum then return false, "Character unavailable" end
                session.PreviousTool = owner.Character:FindFirstChildWhichIsA("Tool")
                local equipped = ctx.request(owner, "Fish:Equip", 1, hum.EquipTool, hum, tool)
                session.Equipped = true
                if not equipped or not ctx.wait(owner, 0.3) or not currentTool(owner, session) then return false, "Could not equip Haunted Rod" end
            end
            ctx.report(stage < 4 and "Casting for the Ghost Dog quest" or "Casting at Ghost Dog's lake")
            local castResult, castReason = cast(owner, session, target)
            if not castResult then return false, castReason end
            if stage < 4 then return questLeg(owner, session, castResult) end
            return normalCatch(owner, session, castResult, spot)
        end)
        -- RemoteFunctions are only cleaned up while this exact live owner still
        -- holds movement. Emergency cancel/death never queues late quest calls.
        if session.QuestStarted and allowed(owner) then
            local surfaced = invoke(owner, "RF/GhostDogQuest/Surface", 1)
            local aborted = allowed(owner) and invoke(owner, "RF/GhostDogQuest/Abort", 1)
            if surfaced and aborted then session.QuestStarted = nil end
        end
        local cleanupReason = feature.cancel(owner)
        pauseUntil = math.max(pauseUntil, os.clock() + (result == true and 1.05 or 2.5))
        if not ok then return false, "Fishing error: " .. tostring(result) end
        return result, cleanupReason or reason
    end
    return feature
end
-- End Ghost Dog fishing factory.


-- Phantom Express event actions use only the Halloween coordinator's current owner.
runtime.halloweenTrainFactory = function(ctx)
    local api, player, world, replicated = ctx.API, ctx.Player, ctx.Workspace, ctx.ReplicatedStorage
    local mod = {}
    local ACTION = "RF/TrainEvent/Action"
    local lastState, nextPoll, suctionOwner = nil, 0, nil
    local suctionRemotes = {}
    local pendingTrade, boardUnconfirmed, observedAway = false, false, false
    local function finite(v)
        return typeof(v) == "Vector3" and v.X == v.X and v.Y == v.Y and v.Z == v.Z
            and math.abs(v.X) < math.huge and math.abs(v.Y) < math.huge and math.abs(v.Z) < math.huge
    end
    local function number(v)
        if type(v) ~= "number" or v ~= v or v < 0 or v == math.huge then return nil end
        return v
    end
    local function report(message) ctx.report("Phantom Express: " .. message) end
    local function attached(object)
        local ok, yes = pcall(function() return object and object:IsDescendantOf(world) end)
        return ok and yes == true
    end
    local function action(owner, kind, ...)
        local event = ctx.Remote(ACTION)
        if not event or not event:IsA("RemoteFunction") then return false, nil, nil, "Train remote unavailable" end
        local result = table.pack(ctx.request(owner, "TrainAction", 3, function(...)
            if not ctx.valid(owner) or ctx.Remote(ACTION) ~= event then error("Train action changed") end
            return event:InvokeServer(kind, ...)
        end, ...))
        if not ctx.valid(owner) then return false, nil, nil, "Train action cancelled" end
        if ctx.Remote(ACTION) ~= event then return false, nil, nil, "Train remote changed" end
        return result[1] == true, result[2], result[3], result[1] and nil or "Train action timed out"
    end
    local function status(owner)
        local ok, accepted, value, reason = action(owner, "Status")
        if not ok or accepted == false or type(value) ~= "table" or type(value.Phase) ~= "string"
            or value.Phase == "" or #value.Phase > 64 then return nil, reason or "Train status unavailable" end
        lastState = value
        if value.Phase ~= "Home" then
            observedAway, boardUnconfirmed = true, false
            ctx.reserveTrain(owner, true)
        elseif not boardUnconfirmed or observedAway then
            ctx.reserveTrain(owner, false)
            observedAway = false
        end
        local invasion = type(value.Invasion) == "table" and value.Invasion or nil
        if invasion and number(invasion.Captured) then api.Stats.Captured = invasion.Captured end
        local shop = type(value.SoulShop) == "table" and value.SoulShop or nil
        api.Stats.Souls = shop and number(shop.Souls) or nil
        api.Stats.SoulCost = shop and number(shop.Cost) or nil
        return value
    end
    local function serverNow()
        local ok, value = pcall(function() return world:GetServerTimeNow() end)
        return ok and number(value) or nil
    end
    local function tool(attribute)
        for _, container in ipairs({ player.Character, player:FindFirstChild("Backpack") }) do
            if container then
                local children = container:GetChildren()
                for index = 1, math.min(#children, 256) do
                    local item = children[index]
                    if item:IsA("Tool") and (item:GetAttribute(attribute) == true or item.Name == attribute) then return item end
                end
            end
        end
        return nil
    end
    local function equip(owner, item)
        if not ctx.valid(owner) or not item then return false end
        if item.Parent ~= owner.Character then
            local bag = player:FindFirstChild("Backpack")
            if item.Parent ~= bag then return false end
            local hum = owner.Character:FindFirstChildOfClass("Humanoid")
            if not hum then return false end
            local ok = pcall(hum.EquipTool, hum, item)
            if not ok or not ctx.wait(owner, .25) then return false end
        end
        return ctx.valid(owner) and item.Parent == owner.Character
    end
    local function promptPosition(prompt)
        if not prompt or not attached(prompt) or prompt.Enabled ~= true then return nil end
        local parent = prompt.Parent
        local ok, position = pcall(function()
            if parent:IsA("Attachment") then return parent.WorldPosition end
            if parent:IsA("BasePart") then return parent.Position end
            if parent:IsA("Model") then return parent:GetPivot().Position end
        end)
        return ok and finite(position) and position or nil
    end
    local function findPrompt(owner, name, returnRail)
        local preferred = world:FindFirstChild("TrainEventRuntime")
        local roots = preferred and {preferred, world} or {world}
        local seen, visited = {}, 0
        for _, start in ipairs(roots) do
            local queue, head = {start}, 1
            while head <= #queue and visited < 12000 do
                if not ctx.valid(owner) then return nil end
                local node = queue[head]; head += 1
                if not seen[node] then
                    seen[node] = true; visited += 1
                    if node:IsA("ProximityPrompt") and node.Enabled == true then
                        local matched = returnRail and node.Name == "TrainReturn"
                            and node:GetAttribute("TrainEventRequiredPhase") == "Town"
                            and not node:GetAttribute("TrainLocalReturn")
                            or not returnRail and node:GetAttribute("TrainEventAction") == name
                        local position = matched and promptPosition(node)
                        if position then return node, position end
                    end
                    for _, child in ipairs(node:GetChildren()) do queue[#queue + 1] = child end
                    if visited % 128 == 0 and not ctx.wait(owner, .01) then return nil end
                end
            end
        end
        return nil
    end
    local function move(owner, position, facing)
        if not ctx.valid(owner) or not finite(position) or not ctx.moveTrain(owner, position) then return false end
        if facing and finite(facing) and (facing - position).Magnitude > .01 then
            local ok = pcall(function() owner.Root.CFrame = CFrame.lookAt(position, facing) end)
            if not ok then return false end
        end
        return ctx.valid(owner)
    end
    local function fire(owner, name, enabled, direction)
        if not ctx.valid(owner) then return false end
        local event = ctx.Remote(name)
        if not event or not event:IsA("RemoteEvent") then return false end
        suctionOwner = owner; suctionRemotes[name] = event
        local ok = ctx.request(owner, "TrainFire:" .. name, 1, function()
            if not ctx.valid(owner) or ctx.Remote(name) ~= event then error("Train suction changed") end
            if direction then event:FireServer(enabled, direction) else event:FireServer(enabled) end
        end)
        return ok and ctx.valid(owner) and ctx.Remote(name) == event
    end
    function mod.cancel(owner)
        if suctionOwner ~= owner then return end
        suctionOwner = nil
        if owner.Cancelled or player.Character ~= owner.Character or ctx.root() ~= owner.Root then
            table.clear(suctionRemotes)
            return
        end
        -- FireServer itself is non-yielding. Never send a cleanup to a replacement remote.
        for name, event in pairs(suctionRemotes) do
            if ctx.Remote(name) == event then pcall(event.FireServer, event, false) end
        end
        table.clear(suctionRemotes)
    end
    local function pivot(object)
        local ok, value = pcall(function()
            if object:IsA("BasePart") then return object.Position end
            if object:IsA("Model") then return object:GetPivot().Position end
        end)
        return ok and finite(value) and value or nil
    end
    local function boss()
        local object = replicated:FindFirstChild("GhostBossState")
        if not object or not lastState or lastState.Phase ~= "Town" or object:GetAttribute("Realm") ~= "Town" then return nil end
        local phase = object:GetAttribute("Phase")
        if phase ~= "Alive" and phase ~= "Spawning" and phase ~= "Capturing" then return nil end
        local visuals = world:FindFirstChild("GhostBossVisuals")
        if visuals then
            local children = visuals:GetChildren()
            for index = 1, math.min(64, #children) do local position = pivot(children[index]); if position then return object, position end end
        end
        local ground = object:GetAttribute("Ground")
        return finite(ground) and object or nil, finite(ground) and ground + Vector3.new(0, 12, 0) or nil
    end
    local function ownedGhosts(owner)
        local folder = world:FindFirstChild("TrainGhostVisuals")
        local found = {}
        if folder then
            local children = folder:GetChildren()
            for index = 1, math.min(1024, #children) do
                if not ctx.valid(owner) then return {} end
                local ghost = children[index]
                if ghost:GetAttribute("OwnerUserId") == player.UserId then
                    local position = pivot(ghost)
                    if position then found[#found + 1] = { Object=ghost, Position=position } end
                end
                if index % 128 == 0 and not ctx.wait(owner, .01) then return {} end
            end
        end
        return found
    end
    local function kite(owner, target, radius, ghosts)
        local current = owner.Root.Position
        local delta = Vector3.new(current.X - target.X, 0, current.Z - target.Z)
        local distance = delta.Magnitude
        local away = distance > .1 and delta.Unit or Vector3.new(0, 0, 1)
        local push = Vector3.zero
        for _, ghost in ipairs(ghosts or {}) do
            local offset = Vector3.new(current.X-ghost.Position.X, 0, current.Z-ghost.Position.Z)
            local d = offset.Magnitude
            local danger = ghost.Object.Name:find("^Vengeful") and 15 or 11
            if d < danger then push += (d > .1 and offset.Unit or away) * (danger-d) end
        end
        if push.Magnitude > .1 then away = push.Unit end
        local targetPos = Vector3.new(target.X,current.Y,target.Z) + away * radius
        if distance < 8 then targetPos = Vector3.new(target.X,current.Y,target.Z) - away * radius end
        local step = targetPos - current
        if push.Magnitude > .1 and step.Magnitude > 4.5 then targetPos = current + step.Unit * 4.5 end
        if distance >= radius-6 and distance <= radius+4 and push.Magnitude <= .1 then targetPos = current end
        local ok, result = pcall(function()
            local params = RaycastParams.new()
            params.FilterType = Enum.RaycastFilterType.Exclude
            local excluded = {owner.Character}
            for _, name in ipairs({"TrainGhostVisuals", "GhostBossVisuals"}) do
                local folder = world:FindFirstChild(name)
                if folder then excluded[#excluded + 1] = folder end
            end
            params.FilterDescendantsInstances = excluded
            pcall(function() params.RespectCanCollide = true end)
            local here = world:Raycast(current, Vector3.new(0,-40,0), params)
            local height = here and math.clamp(current.Y-here.Position.Y,1.5,6) or 3
            local travel = targetPos-current
            if travel.Magnitude > .1 then
                local barrier = world:Raycast(current,travel,params)
                if barrier and barrier.Instance and barrier.Instance.CanCollide then
                    local side = Vector3.new(-travel.Z,0,travel.X)
                    side = side.Magnitude > .1 and side.Unit*math.min(travel.Magnitude,4.5) or Vector3.zero
                    if not world:Raycast(current,side,params) then targetPos=current+side
                    elseif not world:Raycast(current,-side,params) then targetPos=current-side else targetPos=current end
                end
            end
            local floor = world:Raycast(Vector3.new(targetPos.X,current.Y+4,targetPos.Z),Vector3.new(0,-44,0),params)
            return floor and Vector3.new(targetPos.X,floor.Position.Y+height,targetPos.Z) or nil
        end)
        if not ok or not finite(result) then return false, distance end
        return move(owner,result,Vector3.new(target.X,result.Y,target.Z)), distance
    end
    local function suction(owner, bossMode)
        local equipped = tool(bossMode and "GhostBossVacuum" or "GhostVacuum") or (bossMode and tool("GhostVacuum"))
        if not equip(owner,equipped) then return false,"Ghost Vacuum unavailable" end
        local untilAt, sentAt, scannedAt = math.min(owner.Deadline,os.clock()+(bossMode and 20 or 12)), -math.huge, -math.huge
        local ghosts, target, checkedAt = {}, nil, os.clock()
        local eventName = bossMode and "RE/GhostBoss/Suction" or "RE/TrainEvent/Suction"
        local active = false
        while ctx.valid(owner) and os.clock()<untilAt do
            if not api.PhantomExpress then break end
            if lastState.Phase~="Town" then break end
            if os.clock() - checkedAt >= 1 then
                local latest = status(owner)
                if not latest or latest.Phase ~= "Town" then break end
                checkedAt = os.clock()
            end
            if bossMode then
                local object,position=boss()
                if not object then break end
                target={Object=object,Position=position}
            else
                if boss() then break end
                if os.clock()-scannedAt >= .3 then ghosts=ownedGhosts(owner);scannedAt=os.clock() end
                target=nil
                local best
                for _,ghost in ipairs(ghosts) do
                    if attached(ghost.Object) and ghost.Object:GetAttribute("OwnerUserId")==player.UserId then
                        local position=pivot(ghost.Object)
                        if position then
                            local priority=(position-owner.Root.Position).Magnitude
                                +(ghost.Object.Name:find("^Vengeful") and 45 or ghost.Object.Name:find("^Haunted") and 12 or 0)
                                -((number(ghost.Object:GetAttribute("ServerCaptureProgress")) or 0)>0 and 25 or 0)
                            if not best or priority<best then best=priority;target={Object=ghost.Object,Position=position} end
                        end
                    end
                end
                if not target then break end
            end
            local moved,distance=kite(owner,target.Position,bossMode and 18 or 14,ghosts)
            if not moved then mod.cancel(owner);return false,"Waiting for safe ground near ghosts" end
            if os.clock()-sentAt >= (bossMode and .25 or .2) then
                if bossMode then
                    local aim=target.Position-owner.Root.Position;aim=Vector3.new(aim.X,0,aim.Z)
                    if not fire(owner,eventName,true,aim.Magnitude>.1 and aim.Unit or Vector3.new(1,0,0)) then break end
                    active=true;sentAt=os.clock()
                elseif distance<=19 then
                    if not fire(owner,eventName,true) then break end
                    active=true;sentAt=os.clock()
                end
            end
            if not ctx.wait(owner,.05) then break end
        end
        mod.cancel(owner)
        if not ctx.valid(owner) then return false,"Train action cancelled" end
        local value,reason=status(owner)
        if not value then return false,reason end
        if active then return nil, bossMode and "Ghouler phase checked" or "Ghost capture progress checked" end
        return false, "No active ghost suction target"
    end
    local function pickupVacuum(owner)
        local prompt,position=findPrompt(owner,"PickupVacuum")
        if not prompt then return false,"Ghost Vacuum prompt unavailable" end
        if not move(owner,position+Vector3.new(0,1,3),position) or not ctx.wait(owner,.15) then return false,"Cancelled" end
        for _=1,3 do
            if not ctx.valid(owner) or not promptPosition(prompt) then return false,"Vacuum prompt changed" end
            owner.Prompts = owner.Prompts or {}
            owner.Prompts[prompt] = true
            local ok,fired=ctx.request(owner,"TrainPrompt",1.5,function()
                if not ctx.valid(owner) or not promptPosition(prompt) then return false end
                return ctx.Runtime.firePrompt(prompt)
            end)
            if not ok or fired~=true then return false,"Vacuum prompt failed" end
            if not ctx.wait(owner,.4) then return false,"Cancelled" end
            local value,reason=status(owner)
            if not value then return false,reason end
            if value.Phase~="Town" then return nil,"Train phase changed" end
            if type(value.Invasion)=="table" and value.Invasion.VacuumOwned==true then return nil,"Ghost Vacuum confirmed" end
        end
        return false,"Ghost Vacuum pickup unconfirmed"
    end
    local function trade(owner,value)
        if not api.TradeSouls then return nil,"Soul trading is OFF" end
        local shop=type(value.SoulShop)=="table" and value.SoulShop or nil
        local souls,cost=shop and number(shop.Souls),shop and number(shop.Cost)
        if not shop or shop.CanTrade~=true or not souls or not cost or cost<=0 or souls<cost then return nil,"Not enough Souls or shop unavailable" end
        if pendingTrade then return false,"Previous Soul trade unconfirmed; toggle trading OFF before retrying" end
        local prompt,position=findPrompt(owner,"OpenSoulShop")
        if not prompt then return false,"Soul shop prompt unavailable" end
        if not move(owner,position+Vector3.new(0,0,6),position) or not ctx.wait(owner,.15) then return false,"Cancelled" end
        local opened,accepted=action(owner,"OpenSoulShop")
        if not opened or accepted~=true then return false,"Soul shop was not opened" end
        local current,reason=status(owner)
        if not current then return false,reason end
        shop=type(current.SoulShop)=="table" and current.SoulShop or nil
        souls,cost=shop and number(shop.Souls),shop and number(shop.Cost)
        if current.Phase~="Town" or not api.TradeSouls or not shop or shop.CanTrade~=true or not souls or not cost or cost<=0 or souls<cost then return nil,"Soul shop changed" end
        pendingTrade=true
        local ok,bought=action(owner,"TradeSouls",cost)
        if not ctx.valid(owner) then return false,"Trade interrupted; check Souls before retrying" end
        if not ok then return false,"Trade unconfirmed; automatic retry paused" end
        if bought==false then pendingTrade=false;return false,"Soul trade was rejected" end
        if bought~=true then return false,"Trade response unconfirmed; automatic retry paused" end
        api.Stats.Spectral=(api.Stats.Spectral or 0)+1
        pendingTrade=false
        if not ctx.wait(owner,.4) then return nil,"Soul trade accepted" end
        status(owner)
        return nil,"Soul trade accepted"
    end
    local function returnHomeOnce(owner)
        local value,reason=status(owner)
        if not value then return false,reason end
        if value.Phase=="Home" then
            boardUnconfirmed=false;ctx.reserveTrain(owner,false)
            return true,"Train Home confirmed"
        end
        if owner.TrainReturnAccepted then return nil,"Train return accepted; waiting for Home" end
        if value.Phase~="Town" then return nil,"Riding home; waiting for train phase" end
        local ok,accepted=action(owner,"Return")
        if not ok or accepted~=true then
            local latest, latestReason = status(owner)
            if not latest then return false, latestReason end
            if latest.Phase == "Home" then boardUnconfirmed=false;ctx.reserveTrain(owner,false);return true,"Train Home confirmed" end
            if latest.Phase ~= "Town" then owner.TrainReturnAccepted=true;return nil,"Train return is in progress" end
            local prompt,position=findPrompt(owner,nil,true)
            if not prompt then return false,"Return rail unavailable" end
            local a,b=prompt:GetAttribute("ReturnRailStart"),prompt:GetAttribute("ReturnRailEnd")
            if finite(a) and finite(b) and (b-a).Magnitude>.01 then
                local rail=b-a
                local t=math.clamp((owner.Root.Position-a):Dot(rail)/(rail:Dot(rail)),0,1)
                position=a+rail*t
            end
            if not move(owner,position+Vector3.new(0,3,0)) or not ctx.wait(owner,.35) then return false,"Cancelled" end
            ok,accepted=action(owner,"Return")
            if not ok or accepted~=true then return false,"Train return was not accepted" end
        end
        owner.TrainReturnAccepted=true
        if not ctx.wait(owner,.5) then return false,"Cancelled" end
        value,reason=status(owner)
        if not value then return false,reason end
        if value.Phase=="Home" then boardUnconfirmed=false;ctx.reserveTrain(owner,false);return true,"Train Home confirmed" end
        return nil,"Train return accepted; waiting for Home"
    end
    local function returnHome(owner)
        repeat
            local result,reason=returnHomeOnce(owner)
            if result~=nil or not owner.ReturnHome then return result,reason end
            -- Explicit Return Home runs with the master OFF. Keep this exact
            -- owner until Home is confirmed; no scheduler or detached worker
            -- is needed to finish a delayed server return.
            if not ctx.wait(owner,1) then
                return false,"Train Home unconfirmed; use Return home to check again"
            end
        until not ctx.valid(owner)
        return false,"Train Home unconfirmed; movement remains reserved"
    end
    function mod.preferenceChanged(name,value)
        if name=="TradeSouls" and value==false then pendingTrade=false end
    end
    function mod.ready()
        return os.clock()>=nextPoll and (api.PhantomExpress==true or api.TradeSouls==true or api.TrainReserved==true)
    end
    function mod.step(owner)
        if not ctx.valid(owner) or owner.TaskKind~="Train" then return false,"Train owner unavailable" end
        nextPoll=os.clock()+2
        if ctx.hasCarry() then return false,"Put down carried items before boarding" end
        if owner.ReturnHome then return returnHome(owner) end
        local value,reason=status(owner)
        if not value then return false,reason end
        if value.Phase=="Home" then
            if boardUnconfirmed then return false,"Boarding unconfirmed; use Return home before retrying" end
            if not api.PhantomExpress and not api.TradeSouls then return nil,"Train automation is OFF" end
            local now=serverNow()
            local departure=number(value.DepartureAt)
            if value.ArrivalOpen~=true or not now or not departure or departure-now<=3 then return nil,"Waiting for the Phantom Express" end
            local ticket=tool("ConductorTicket")
            if value.AccessUnlocked~=true and not ticket then return nil,"Train Pass required (finish Gilbert's quest)" end
            if value.StationAvailable==true and value.AtStation~=true then
                local ok,accepted=action(owner,"Station")
                if not ok or accepted~=true then return false,"Could not reach train station" end
                if not ctx.wait(owner,.5) then return false,"Cancelled" end
                value,reason=status(owner)
                if not value or value.Phase~="Home" or value.AtStation~=true then return false,reason or "Train station unconfirmed" end
                now=serverNow();departure=number(value.DepartureAt)
                if value.ArrivalOpen~=true or not now or not departure or departure-now<=3 then return nil,"Train departure is too close" end
            end
            if value.AccessUnlocked~=true and not equip(owner,ticket) then return false,"Train Pass could not be equipped" end
            if not ctx.valid(owner) or ctx.hasCarry() then return false,"Cancelled" end
            boardUnconfirmed=true;ctx.reserveTrain(owner,true)
            report("Boarding")
            local ok,accepted=action(owner,"Board")
            if not ok then return false,"Boarding unconfirmed; movement reserved until checked" end
            if accepted==false then boardUnconfirmed=false;status(owner);return false,"Boarding was not accepted" end
            if accepted~=true then return false,"Boarding response unconfirmed; use Return home before retrying" end
            if not ctx.wait(owner,.5) then return false,"Cancelled" end
            value,reason=status(owner)
            return nil,value and value.Phase~="Home" and "Train boarding confirmed" or reason or "Waiting for train boarding confirmation"
        end
        if value.Phase~="Town" then return nil,"Riding ("..value.Phase..")" end
        if not api.PhantomExpress and not api.TradeSouls then return returnHome(owner) end
        if api.PhantomExpress and boss() then report("Fighting Ghouler");return suction(owner,true) end
        local invasion=type(value.Invasion)=="table" and value.Invasion or nil
        local captured,goal=invasion and number(invasion.Captured),invasion and number(invasion.Goal)
        local now=serverNow()
        local ended=invasion and (invasion.Phase=="Ended" or captured and goal and goal>0 and captured>=goal
            or now and number(invasion.EndsAt) and now>=invasion.EndsAt)
        if api.PhantomExpress and not ended then
            if not invasion then return false,"Invasion status unavailable" end
            if invasion.VacuumOwned~=true then report("Picking up Ghost Vacuum");return pickupVacuum(owner) end
            report("Hunting ghosts")
            return suction(owner,false)
        end
        if api.TradeSouls then
            local shop=type(value.SoulShop)=="table" and value.SoulShop or nil
            if shop and shop.CanTrade==true and number(shop.Souls) and number(shop.Cost) and shop.Cost>0 and shop.Souls>=shop.Cost then
                report("Trading Souls at current game cost")
                return trade(owner,value)
            end
        end
        report("Returning from town")
        return returnHome(owner)
    end
    if type(ctx.Runtime.watch) == "function" then
        ctx.Runtime.watch("HalloweenTrainPhase", function() local event=ctx.Remote("RE/TrainEvent/State"); return event and event:IsA("RemoteEvent") and event.OnClientEvent or nil end, function(value)
            if type(value) == "table" and type(value.Phase) == "string" and value.Phase ~= "" and #value.Phase <= 64 then
                lastState = value
            end
        end)
    end
    return mod
end

-- End Phantom Express event factory.


-- Halloween egg farming: isolated, cancellable ownership of one egg cycle.
runtime.halloween = (function()
    local api = { Enabled = false, StealEggs = true, ZonePriority = true, Active = nil,
        Status = "Halloween: OFF", Stats = { Delivered = 0, Failed = 0, Candy = 0 },
        Names = {}, Rarities = {}, MobNames = {}, MobRarities = {},
        AutoBuy = false, CrossWorld = false, HitMobs = false, CollectPumpkins = false,
        AutoFish = false, PhantomExpress = false, TradeSouls = false,
        TrainReserved = false, NormalHandoff = nil }
    for _, key in ipairs({ "Bought", "Killed", "Pumpkins", "Fished", "FishQuests", "Captured", "Spectral" }) do api.Stats[key] = 0 end
    local modules = {}
    local function moduleFor(kind)
        if kind == "Mob" or kind == "Pumpkin" or kind == "AutoBuy" then return modules.Field end
        if kind == "Fishing" then return modules.Fishing end
        if kind == "Train" then return modules.Train end
    end
    local STAGE = Vector3.new(-5809.776, -203.938, -7233.45)
    local BANK = Vector3.new(-5809.41, -203.938, -7246.08)
    local CENTER = Vector3.new(-5800, -200, -6200)
    local dependencies, knownNames, knownRarities, cooldown = {}, {}, {}, {}
    local worker, running, nextScan = nil, false, 0
    local lastWorldScan = -math.huge
    local generation = 0

    local function finite(p)
        return typeof(p) == "Vector3" and p.X == p.X and p.Y == p.Y and p.Z == p.Z
            and math.abs(p.X) < math.huge and math.abs(p.Y) < math.huge and math.abs(p.Z) < math.huge
    end
    local function attr(name)
        local ok, value = pcall(function() return localPlayer:GetAttribute(name) end)
        return ok and value or nil
    end
    local function carrying() return attr("HalloweenCarrying") == true end
    function api.hasCarry()
        return carrying() or attr("HalloweenPumpkinCarrying") == true or attr("PumpkinCarrying") == true
    end
    function api.inside()
        local r = root()
        return attr("InHalloweenDimension") == true and r ~= nil and finite(r.Position)
            and (r.Position - CENTER).Magnitude < 4000
    end
    function api.blocksNormal()
        if api.Active or api.hasCarry() or api.TrainReserved then return true end
        local handoff = api.NormalHandoff
        if handoff and handoff.Allow == true and (api.CrossWorld or handoff.Started == true or state.AutoRun ~= nil)
            and (handoff.Started == true or state.AutoRun ~= nil or not api.inside()) then return false end
        return api.Enabled
    end
    local function report(message)
        api.Status = "Halloween: " .. tostring(message)
    end
    local function moduleAt(name)
        local folder = ReplicatedStorage:FindFirstChild(name == "Pets" and "Data" or "Shared")
        return folder and folder:FindFirstChild(name == "Pets" and "HalloweenPets" or name)
    end
    local function dependency(name)
        local inst = moduleAt(name)
        local saved = dependencies[name]
        if saved and saved.Instance == inst and inst then return saved.Value end
        dependencies[name] = nil
        if inst then
            -- A replaced ModuleScript must not wait behind an older require
            -- that is still suspended. Each instance has its own load slot.
            runtime.loadDependency(inst, function() return inst end, function(value)
                if moduleAt(name) == inst then dependencies[name] = { Instance = inst, Value = value } end
            end)
        end
        saved = dependencies[name]
        return saved and saved.Instance == moduleAt(name) and saved.Value or nil
    end
    local function refreshDependencies()
        dependency("Save"); dependency("Remotes"); dependency("Pets")
    end
    local function rarity(name)
        local pets = dependency("Pets")
        local spec = pets and type(pets.Specs) == "table" and pets.Specs[name]
        local value = type(spec) == "table" and spec.Rarity or nil
        if value == nil and type(Assets) == "table" and type(Assets.Directory) == "table" then
            local entry = Assets.Directory[name]
            value = type(entry) == "table" and entry.Rarity or nil
        end
        if type(value) == "table" then value = value._id or value.DisplayName or value.Name or value.Rank end
        if type(value) ~= "string" and type(value) ~= "number" then return "Unknown" end
        value = tostring(value)
        return value ~= "" and value or "Unknown"
    end
    local function filtersPass(name)
        return (next(api.Names) == nil or api.Names[name] == true)
            and (next(api.Rarities) == nil or api.Rarities[rarity(name)] == true)
    end
    local function worldEggs()
        local dimension = workspace:FindFirstChild("HalloweenDimension")
        return dimension and dimension:FindFirstChild("WorldEggs")
    end
    local function readEgg(model)
        local folder = worldEggs()
        if not model or not folder or model.Parent ~= folder then return nil end
        local ok, result = pcall(function()
            local uid = model:GetAttribute("HalloweenEggUid")
            if type(uid) ~= "string" or uid == "" then return nil end
            local prompt = model:FindFirstChildWhichIsA("ProximityPrompt", true)
            if not prompt or prompt.Enabled ~= true or not prompt:IsDescendantOf(model) then return nil end
            local part = prompt.Parent
            if part and part:IsA("Attachment") then part = part.Parent end
            if not part or not part:IsA("BasePart") then
                part = model:IsA("BasePart") and model or model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)
            end
            if not part or not part:IsDescendantOf(model) and part ~= model or not finite(part.Position) then return nil end
            local name = model:GetAttribute("PreparedSourceName")
            name = type(name) == "string" and name ~= "" and name or "Unknown"
            local zone = tonumber(model:GetAttribute("Zone")) or 0
            if zone ~= zone or math.abs(zone) == math.huge then zone = 0 end
            return { Model = model, Prompt = prompt, Part = part, Uid = uid, Name = name, Zone = zone }
        end)
        return ok and result or nil
    end
    local function valid(owner)
        if not alive or api.Active ~= owner or owner.Cancelled or owner.Generation ~= generation
            or state.HalloweenOwner ~= owner or state.TripId ~= owner.TripId or not state.Busy
            or state.Cancel or localPlayer.Character ~= owner.Character or root() ~= owner.Root
            or owner.Root == nil or state.Carrying or os.clock() >= owner.Deadline
            or (not owner.ReturnHome and not api.Enabled) then return false end
        if runtime.bigEggFinder and runtime.bigEggFinder.IsJoining then return false end
        local hum = owner.Character:FindFirstChildOfClass("Humanoid")
        return hum ~= nil and hum.Health > 0 and finite(owner.Root.Position)
            and (owner.TaskKind == "Egg" or not carrying())
            and (owner.TaskKind == "Pumpkin" or (attr("HalloweenPumpkinCarrying") ~= true and attr("PumpkinCarrying") ~= true))
    end
    local function waitFor(owner, seconds, predicate)
        local untilAt = math.min(owner.Deadline, os.clock() + seconds)
        repeat
            if not valid(owner) then return false end
            if predicate and predicate() then return true end
            if os.clock() >= untilAt then break end
            task.wait(math.min(0.05, math.max(0, untilAt - os.clock())))
        until false
        return valid(owner) and (not predicate or predicate())
    end
    local function request(owner, name, seconds, callback, ...)
        if not valid(owner) or os.clock() >= owner.Deadline then return false, "Cancelled" end
        local key = owner.Keys[name]
        if not key then key = {}; owner.Keys[name] = key end
        local values = table.pack(runtime.call(key, math.min(seconds, owner.Deadline - os.clock()), function(...)
            if not valid(owner) then error("Halloween cycle cancelled") end
            return callback(...)
        end, ...))
        if not valid(owner) then return false, "Cancelled" end
        return table.unpack(values, 1, values.n)
    end
    local function candy(owner)
        local save = dependency("Save")
        if not save or type(save.Peek) ~= "function" then return nil, "Candy data unavailable" end
        local ok, data = request(owner, "Candy", 1.25, save.Peek)
        if not ok then return nil, "Candy data timed out" end
        if dependency("Save") ~= save then return nil, "Candy data changed; try again" end
        local amount = type(data) == "table" and tonumber(data.HalloweenTokens)
        if not amount or amount ~= amount or amount < 0 or amount == math.huge then return nil, "Candy data unavailable" end
        api.Stats.Candy = amount
        return amount
    end
    local function liveEgg(owner, egg)
        if not valid(owner) or not api.inside() or not api.StealEggs then return nil end
        local current = readEgg(egg.Model)
        if not current or current.Uid ~= egg.Uid or not filtersPass(current.Name) then return nil end
        return current
    end
    local function move(owner, position)
        if not valid(owner) or not api.inside() or not finite(position) or (position - CENTER).Magnitude >= 4000 then return false end
        local ok = pcall(function()
            owner.Root.CFrame = CFrame.new(position)
            owner.Root.AssemblyLinearVelocity = Vector3.zero
            owner.Root.AssemblyAngularVelocity = Vector3.zero
        end)
        return ok and valid(owner)
    end
    local function prompt(owner, egg)
        local current = liveEgg(owner, egg)
        if not current or carrying() then return false, "Egg changed or prompt unavailable" end
        owner.Prompts[current.Prompt] = true
        local ok, fired = request(owner, "Prompt", 1.2, function()
            local fresh = liveEgg(owner, current)
            if not fresh or fresh.Prompt ~= current.Prompt or carrying() then return false end
            return runtime.firePrompt(current.Prompt)
        end)
        if not ok or fired ~= true then return false, "Egg prompt failed or timed out" end
        if not filtersPass(current.Name) then return false, "Egg no longer matches filters" end
        return true
    end
    local function pickUp(owner, egg, seconds)
        local untilAt = math.min(owner.Deadline, os.clock() + seconds)
        while valid(owner) and os.clock() < untilAt do
            if carrying() then return owner.PickupRequested == egg.Uid end
            local current = liveEgg(owner, egg)
            if not current then return false, "Selected egg or prompt changed" end
            if not move(owner, current.Part.Position + Vector3.new(0, 2, 0)) then return false, "Egg position unavailable" end
            owner.PickupRequested = egg.Uid
            local ok, reason = prompt(owner, current)
            if not valid(owner) then return false, "Cancelled" end
            if not ok then return false, reason end
            if carrying() then return true end
            if not waitFor(owner, 0.15) then return false, "Cancelled" end
        end
        return false, "Pickup was not confirmed"
    end
    local function scan(owner, exactUid)
        local gap = 1 - (os.clock() - lastWorldScan)
        if gap > 0 and not waitFor(owner, gap) then return nil, "Cancelled" end
        local folder = worldEggs()
        if not folder then return nil, "Halloween eggs are not loaded" end
        lastWorldScan = os.clock()
        local children = folder:GetChildren()
        if #children > 2048 then return nil, "Too many egg objects; refresh later" end
        local best, bestDistance, duplicate = nil, nil, false
        local uidCounts, candidates = {}, {}
        for i, model in ipairs(children) do
            if not valid(owner) or not api.inside() then return nil, "Cancelled" end
            local egg = readEgg(model)
            if egg then
                uidCounts[egg.Uid] = (uidCounts[egg.Uid] or 0) + 1
                knownNames[egg.Name], knownRarities[rarity(egg.Name)] = true, true
                if exactUid then
                    if egg.Uid == exactUid then if best then duplicate = true else best = egg end end
                elseif filtersPass(egg.Name) and os.clock() >= (cooldown[egg.Uid] or 0) then
                    candidates[#candidates + 1] = egg
                end
            end
            if i % 64 == 0 and not waitFor(owner, 0.03) then return nil, "Cancelled" end
        end
        if folder ~= worldEggs() then return nil, "Halloween eggs changed; try again" end
        if duplicate then return nil, "Duplicate egg UID; retry later" end
        if not exactUid then
            for _, egg in ipairs(candidates) do
                if uidCounts[egg.Uid] == 1 then
                    local distance = (egg.Part.Position - owner.Root.Position).Magnitude
                    if not best or api.ZonePriority and egg.Zone > best.Zone
                        or (not api.ZonePriority or egg.Zone == best.Zone) and distance < bestDistance then
                        best, bestDistance = egg, distance
                    end
                end
            end
        end
        return best, best and nil or (exactUid and "Selected dropped egg not found" or "No matching enabled egg prompts")
    end
    local function portalPart(wantInside)
        local world = wantInside and workspace:FindFirstChild("World") or workspace:FindFirstChild("HalloweenDimension")
        if not world and wantInside then return nil end
        local portal = world and world:FindFirstChild(wantInside and "HalloweenDimensionPortal" or "PortalHome", not wantInside)
        -- The donor locates the exact PortalHome name globally; some versions
        -- place it outside the dimension model. This runs only for Return Home.
        if not portal and not wantInside then portal = workspace:FindFirstChild("PortalHome", true) end
        local part = portal and (portal:FindFirstChild(wantInside and "Hitbox" or "Portal") or (not wantInside and portal:FindFirstChildWhichIsA("BasePart", true)))
        return part and part:IsA("BasePart") and part or nil
    end
    local function cross(owner, wantInside)
        if api.inside() == wantInside then return true end
        if api.hasCarry() or state.Carrying then return false, "Put down carried items before changing worlds" end
        if owner.Root.Anchored then
            report("Leaving treadmill")
            if not getOffTreadmill() or not valid(owner) or owner.Root.Anchored then return false, "Leave the treadmill before entering" end
        end
        for _ = 1, 2 do
            if not valid(owner) or api.hasCarry() then return false, "Cancelled" end
            local part = portalPart(wantInside)
            if not part then return false, wantInside and "Halloween entry portal unavailable" or "Return Home portal unavailable" end
            local size, cf = part.Size, part.CFrame
            if not finite(part.Position) or not finite(size) then return false, "Portal position unavailable" end
            local normal, thickness = cf.UpVector, size.Y
            if size.X <= size.Y and size.X <= size.Z then normal, thickness = cf.RightVector, size.X
            elseif size.Z <= size.Y then normal, thickness = cf.LookVector, size.Z end
            normal = Vector3.new(normal.X, 0, normal.Z)
            if normal.Magnitude < 0.01 then return false, "Portal direction unavailable" end
            normal = normal.Unit
            local side = (owner.Root.Position - part.Position):Dot(normal) >= 0 and 1 or -1
            local center = Vector3.new(part.Position.X, part.Position.Y - size.Y / 2 + 3, part.Position.Z)
            local front = center + normal * side * (thickness / 2 + 1.5)
            local goal = center - normal * side * (thickness / 2 + 3)
            if not finite(front) or not finite(goal) then return false, "Portal position unavailable" end
            owner.Root.CFrame = CFrame.new(front, goal)
            owner.Root.AssemblyLinearVelocity = Vector3.zero
            local untilAt = math.min(owner.Deadline, os.clock() + 3)
            while valid(owner) and os.clock() < untilAt do
                if portalPart(wantInside) ~= part or not part.Parent then return false, "Portal changed; try again" end
                if api.inside() == wantInside then return true end
                if api.hasCarry() then return false, "Carried item changed; crossing stopped" end
                owner.Character:FindFirstChildOfClass("Humanoid"):MoveTo(goal)
                if not waitFor(owner, 0.05) then return false, "Cancelled" end
            end
            if not valid(owner) then return false, "Cancelled" end
            if not waitFor(owner, 0.6) then return false, "Cancelled" end
        end
        return false, wantInside and "Halloween entry was not confirmed" or "Return Home was not confirmed"
    end
    local function resolveDrop()
        local remotes = dependency("Remotes")
        local ok, event = pcall(function() return remotes and remotes.HalloweenDimension.AskDropEgg end)
        return ok and event or nil, remotes
    end
    local function cycle(owner)
        if owner.TaskKind == "Train" then
            local feature = moduleFor("Train")
            if not feature then return false, "Train activity unavailable" end
            return feature.step(owner, "Train")
        end
        report(owner.ReturnHome and "Returning home" or "Entering Halloween")
        local entered, reason = cross(owner, not owner.ReturnHome)
        if not entered then return false, reason end
        if owner.ReturnHome then return true, "Returned home" end
        if not valid(owner) or not api.inside() then return false, "Halloween entry was not confirmed" end
        if owner.TaskKind == "Entry" then return nil, "Inside; waiting for enabled activities" end
        if owner.TaskKind ~= "Egg" then
            local feature = moduleFor(owner.TaskKind)
            if not feature then return false, owner.TaskKind .. " activity unavailable" end
            return feature.step(owner, owner.TaskKind)
        end
        if not api.StealEggs then return nil, "Inside; egg stealing is OFF" end
        local egg, scanReason = scan(owner)
        if not egg then return nil, scanReason end
        owner.Uid = egg.Uid
        if api.hasCarry() then return false, "A carried item appeared; stopped" end
        local before, candyReason = candy(owner)
        if before == nil then return false, candyReason end
        if not liveEgg(owner, egg) then return false, "Egg no longer matches filters or prompt changed" end
        report("Taking " .. egg.Name)
        local picked, pickReason = pickUp(owner, egg, 4)
        if not picked then return false, pickReason end
        if not valid(owner) or not carrying() or not filtersPass(egg.Name) then return false, "Pickup changed; stopped" end
        report("Moving selected egg to the stage")
        if not move(owner, STAGE) or not waitFor(owner, 0.12) then return false, "Stage move cancelled" end
        if not valid(owner) or not api.inside() or not carrying() or not filtersPass(egg.Name) then return false, "Carry or filter changed; stopped" end
        local event, remotes = resolveDrop()
        local readable, invoke = pcall(function() return event and event.InvokeServer end)
        if not readable or type(invoke) ~= "function" then return false, "Halloween drop remote unavailable" end
        local dropped, dropResult = request(owner, "Drop", 3, function()
            local current, currentRemotes = resolveDrop()
            if current ~= event or currentRemotes ~= remotes or not carrying() or not filtersPass(egg.Name) then
                error("Halloween drop dependency or carry changed")
            end
            return event:InvokeServer()
        end)
        if not valid(owner) then return false, "Cancelled" end
        local current, currentRemotes = resolveDrop()
        if current ~= event or currentRemotes ~= remotes then return false, "Halloween drop remote changed" end
        if not dropped or verdictIsRejected(dropResult) then return false, "Halloween drop failed or timed out" end
        if not waitFor(owner, 1, function() return not carrying() end) then return false, "Drop was not confirmed; held egg preserved" end
        owner.PickupRequested = nil
        report("Finding the same dropped egg")
        local regrabBy, lastScan = os.clock() + 4, -math.huge
        local again
        while valid(owner) and os.clock() < regrabBy do
            if carrying() then return false, "A different carry appeared before regrab" end
            if os.clock() - lastScan >= 1 then
                lastScan = os.clock()
                again = scan(owner, egg.Uid)
                if again then break end
            end
            if not waitFor(owner, 0.05) then return false, "Cancelled" end
        end
        if not again or not filtersPass(again.Name) then return false, "Same egg UID not available; no other egg taken" end
        if (again.Part.Position - STAGE).Magnitude > 80 then return false, "Selected egg moved away from the stage" end
        local got, gotReason = pickUp(owner, again, 3)
        if not got then return false, gotReason end
        local bankBefore, bankReason = candy(owner)
        if bankBefore == nil then return false, bankReason end
        if not valid(owner) or not carrying() or not filtersPass(again.Name) then return false, "Carry or filter changed; banking stopped" end
        report("Banking selected egg")
        local bankFrom = owner.Root.Position
        for i = 1, 4 do
            if not valid(owner) or not filtersPass(again.Name) then return false, "Carry or filter changed; banking stopped" end
            if not carrying() then break end -- the bank may accept during the crossing
            if not move(owner, bankFrom:Lerp(BANK, i / 4)) then return false, "Bank move was not confirmed" end
            if not waitFor(owner, 0.03) then return false, "Bank move cancelled" end
        end
        local confirmBy, lastCandy = math.min(owner.Deadline, os.clock() + 5), -math.huge
        local sawRelease, amount = false, bankBefore
        while valid(owner) and os.clock() < confirmBy do
            if not api.inside() then return false, "Left Halloween before delivery confirmation" end
            if not carrying() then sawRelease = true end
            if os.clock() - lastCandy >= 0.4 then
                lastCandy = os.clock()
                local value = candy(owner)
                if value then amount = value end
            end
            if not valid(owner) then return false, "Cancelled" end
            if sawRelease and not carrying() and amount > bankBefore then return true, "Delivered; Candy Corn confirmed" end
            if not waitFor(owner, 0.05) then return false, "Cancelled" end
        end
        return false, "Delivery unconfirmed; waiting for carry release and Candy Corn"
    end
    local function cleanup(owner)
        -- Feature cleanup is nonyielding and runs before retiring this owner.
        -- It may stop only an exact captured cast/suction session on this body.
        if not owner.FeatureCancelled then
            owner.FeatureCancelled = true
            local feature = moduleFor(owner.TaskKind)
            if feature and type(feature.cancel) == "function" and api.Active == owner
                and state.HalloweenOwner == owner and state.TripId == owner.TripId
                and localPlayer.Character == owner.Character and root() == owner.Root then
                local ok, reason = pcall(feature.cancel, owner)
                if ok and type(reason) == "string" and reason ~= "" then owner.CleanupReason = reason end
            end
        end
        owner.Cancelled = true
        for _, key in pairs(owner.Keys) do runtime.cancelRequest(key, "Halloween cycle stopped") end
        for promptObject in pairs(owner.Prompts) do
            local record = runtime.PromptHolds and runtime.PromptHolds[promptObject]
            if record then runtime.restorePrompt(promptObject, record) end
        end
        local ownsMovement = state.HalloweenOwner == owner and state.TripId == owner.TripId
        if state.HalloweenOwner == owner then state.HalloweenOwner = nil end
        -- Exact-session feature cleanup above still sees its live owner.
        -- Retire coordinator ownership before optional local restoration.
        if api.Active == owner then api.Active = nil end
        if ownsMovement then
            state.Busy, state.TripCharacter = false, nil
            if state.TripTask == owner.Task then state.TripTask = nil end
            pcall(performance.setStealing, false)
            if root() == owner.Root and localPlayer.Character == owner.Character then
                pcall(function()
                    owner.Root.AssemblyLinearVelocity = Vector3.zero
                    owner.Character:FindFirstChildOfClass("Humanoid"):Move(Vector3.zero, false)
                end)
            end
        end
    end
    function api.cancel(reason)
        if type(api.normalHandoffReset) == "function" then pcall(api.normalHandoffReset) end
        api.NormalHandoff = nil
        local owner = api.Active
        if owner then cleanup(owner) end
        api.Enabled = false
        generation += 1
        if owner then runtime.cancel(owner.Task) end
        report(owner and owner.CleanupReason or reason or "Stopped; carried items preserved")
        return true
    end
    local function begin(returning, kind)
        kind = kind or "Egg"
        local pumpkin = attr("HalloweenPumpkinCarrying") == true or attr("PumpkinCarrying") == true
        local allowedPumpkin = kind == "Pumpkin" and api.CollectPumpkins and not carrying()
        if not alive or api.Active or state.Busy or state.Aborting or state.Carrying or carrying()
            or (pumpkin and not allowedPumpkin) or (api.TrainReserved and kind ~= "Train")
            or viewState or performance.Restoring then return false end
        if runtime.bigEggFinder and (runtime.bigEggFinder.IsJoining or runtime.bigEggFinder.IsOpen) then return false end
        local character, r = localPlayer.Character, root()
        local hum = character and character:FindFirstChildOfClass("Humanoid")
        if not r or not hum or hum.Health <= 0 or not finite(r.Position) then report("Waiting for character"); return false end
        state.TripId = (state.TripId or 0) + 1
        local owner = { TripId = state.TripId, Character = character, Root = r, Generation = generation,
            Keys = {}, Prompts = {}, Deadline = os.clock() + (kind == "Fishing" and 90 or 45),
            ReturnHome = returning == true, TaskKind = kind }
        api.Active = owner
        state.HalloweenOwner, state.Busy, state.TripCharacter = owner, true, character
        state.Cancel, state.TripDelivered, state.TargetUid = false, false, nil
        performance.setStealing(true)
        owner.Task = runtime.spawnOwned(owner.TripId, function()
            local ok, delivered, reason = pcall(cycle, owner)
            if api.Active ~= owner then return end
            if not ok then delivered, reason = false, "Cycle error: " .. tostring(delivered) end
            if not valid(owner) then
                delivered, reason = false, os.clock() >= owner.Deadline and "Cycle timed out; carried items preserved" or "Cancelled or character changed"
            end
            if owner.Uid then
                if delivered == true then api.Stats.Delivered += 1
                elseif delivered == false then api.Stats.Failed += 1 end
                cooldown[owner.Uid] = os.clock() + (delivered and 20 or 8)
                local count = 0
                for uid, untilAt in pairs(cooldown) do
                    count += 1
                    if untilAt <= os.clock() or count > 256 then cooldown[uid] = nil end
                end
            end
            if not owner.Uid and not owner.ReturnHome and owner.TaskKind ~= "Entry" and delivered == false then api.Stats.Failed += 1 end
            cleanup(owner)
            nextScan = os.clock() + (owner.TaskKind == "Mob" and delivered ~= false
                and (owner.MobYielded and 0 or 0.25) or (delivered == false and 3 or 1))
            report(owner.CleanupReason or reason or (delivered and "Done" or "Waiting for matching eggs"))
        end)
        if api.Active == owner then state.TripTask = owner.Task end
        return true
    end
    local taskOrder, taskCursor = { "Egg", "Mob", "Pumpkin", "Fishing", "Train", "AutoBuy" }, 0
    local function wanted(kind)
        if kind == "Egg" then return api.StealEggs end
        if kind == "Mob" then return api.HitMobs end
        if kind == "Pumpkin" then return api.CollectPumpkins end
        if kind == "Fishing" then return api.AutoFish end
        if kind == "Train" then return api.PhantomExpress or api.TradeSouls or api.TrainReserved end
        return kind == "AutoBuy" and api.AutoBuy
    end
    local function ready(kind)
        if kind == "Egg" then
            -- When hunting mobs inside the event, an empty streamed egg
            -- folder should not reserve a one-second no-op egg cycle.
            if api.HitMobs and api.inside() then
                local folder = worldEggs()
                if not folder or #folder:GetChildren() == 0 then return false, "No matching enabled egg prompts" end
            end
            if dependency("Save") and dependency("Remotes") then return true end
            return false, "Waiting for Halloween game data"
        end
        local feature = moduleFor(kind)
        if not feature or type(feature.ready) ~= "function" then return false, kind .. " activity unavailable" end
        local ok, available, reason = pcall(feature.ready, kind)
        if not ok then return false, kind .. " activity is not ready" end
        return available == true, reason
    end
    -- Mob passes may continue indefinitely, but only their exact healthy
    -- owner can renew the short lease. Network requests keep their own bounds.
    local function mobEggReady(owner)
        if not api.StealEggs or not dependency("Save") or not dependency("Remotes") then
            owner.MobEggScan = nil
            return false, false
        end
        local folder = worldEggs()
        if not folder then owner.MobEggScan = nil; return false, false end
        local scanState = owner.MobEggScan
        if not scanState or scanState.Folder ~= folder then
            local children = folder:GetChildren()
            if #children > 2048 then return false, false end -- the egg cycle uses the same bound
            scanState = { Folder = folder, Children = children, Index = 1, Counts = {}, Candidates = {} }
            owner.MobEggScan = scanState
        end
        local last = math.min(#scanState.Children, scanState.Index + 127)
        for index = scanState.Index, last do
            if not valid(owner) then return false, false end
            local egg = readEgg(scanState.Children[index])
            if egg then
                scanState.Counts[egg.Uid] = (scanState.Counts[egg.Uid] or 0) + 1
                if filtersPass(egg.Name) and os.clock() >= (cooldown[egg.Uid] or 0) then
                    scanState.Candidates[#scanState.Candidates + 1] = egg
                end
            end
        end
        scanState.Index = last + 1
        if scanState.Index <= #scanState.Children then return false, true end
        owner.MobEggScan = nil
        if worldEggs() ~= folder then return false, false end
        for _, egg in ipairs(scanState.Candidates) do
            local current = readEgg(egg.Model)
            if current and current.Uid == egg.Uid and scanState.Counts[egg.Uid] == 1
                and filtersPass(current.Name) and os.clock() >= (cooldown[egg.Uid] or 0) then return true, false end
        end
        return false, false
    end
    local function continueMob(owner)
        if not owner or owner.TaskKind ~= "Mob" or owner.MobYielded or not api.HitMobs
            or not valid(owner) or not api.inside() or api.TrainReserved then return false end
        local now = os.clock()
        owner.Deadline = now + 45
        owner.MobFairAt = owner.MobFairAt or (now + 1)
        if now < owner.MobFairAt then return true end
        local shouldYield = false
        for _, kind in ipairs(taskOrder) do
            if kind ~= "Mob" and kind ~= "Egg" and wanted(kind) then
                local available = ready(kind)
                if not valid(owner) then return false end
                if available then shouldYield = true; break end
            end
        end
        local auto, filter, crossWorld = runtime.autoSteal, runtime.rarityFilter, runtime.halloweenCrossWorld
        if not shouldYield and api.CrossWorld and type(api.normalHandoff) == "function"
            and auto and auto.Enabled and filter and not filter.All and next(filter.Selected) ~= nil
            and not (crossWorld and crossWorld.Pending)
            and now >= (crossWorld and tonumber(crossWorld.NextProbe) or 0) then shouldYield = true end
        local incomplete = false
        if not shouldYield then shouldYield, incomplete = mobEggReady(owner) end
        if not valid(owner) then return false end
        owner.MobFairAt = os.clock() + (incomplete and 0.05 or 1)
        if shouldYield then owner.MobYielded = true; return false end
        return true
    end
    local function chooseTask()
        if api.TrainReserved then
            local ok, reason = ready("Train")
            return ok and "Train" or nil, reason or "Train session reserved; use Return Home"
        end
        if not api.inside() then
            local anyWanted, reason = false, nil
            for offset = 1, #taskOrder do
                local index = (taskCursor + offset - 1) % #taskOrder + 1
                local kind = taskOrder[index]
                if wanted(kind) then
                    anyWanted = true
                    if kind == "Egg" then
                        local available, why = ready(kind)
                        if available then taskCursor = index; return kind end
                        reason = reason or why
                    elseif moduleFor(kind) then
                        -- World objects may stream only after entry. Do not
                        -- require an outside target to enter for that activity.
                        taskCursor = index
                        return kind
                    end
                end
            end
            return not anyWanted and "Entry" or nil, reason or "Waiting for enabled event activities"
        end
        local pumpkin = attr("HalloweenPumpkinCarrying") == true or attr("PumpkinCarrying") == true
        if pumpkin then
            if api.CollectPumpkins then
                local ok, reason = ready("Pumpkin")
                return ok and "Pumpkin" or nil, reason
            end
            return nil, "Carried pumpkin preserved; enable collection to deposit"
        end
        local reason
        for offset = 1, #taskOrder do
            local index = (taskCursor + offset - 1) % #taskOrder + 1
            local kind = taskOrder[index]
            if wanted(kind) then
                local available, why = ready(kind)
                if available then taskCursor = index; return kind end
                reason = reason or why
            end
        end
        return nil, reason or "Inside; egg stealing is OFF"
    end
    function api.step()
        if not alive or not api.Enabled or api.Active then return false end
        -- The parent handoff tracker must also observe a still-running normal
        -- trip, so it runs before the normal Busy/scan scheduling checks.
        if type(api.normalHandoff) == "function" then
            local ok, handled = pcall(api.normalHandoff)
            if not ok then report("Cross-world handoff unavailable"); return false end
            if handled then return false end
        end
        if os.clock() < nextScan then return false end
        refreshDependencies()
        if carrying() or state.Carrying then report("Carried items preserved; put them down to continue"); nextScan = os.clock() + 1; return false end
        local kind, reason = chooseTask()
        if not kind then
            report(reason or "Waiting for enabled activities")
            nextScan = os.clock() + (api.HitMobs and 0.25 or 1)
            return false
        end
        nextScan = os.clock() + 1
        return begin(false, kind)
    end
    function api.start()
        if running or not alive then return false end
        running = true
        worker = runtime.spawn(function()
            while alive and running do
                api.step()
                task.wait(0.25)
            end
        end)
        return true
    end
    function api.stop()
        running = false
        api.cancel("OFF")
        runtime.cancel(worker)
        worker = nil
        return true
    end
    function api.setEnabled(value)
        value = value == true
        if not value then api.cancel("OFF; carried items preserved"); return true end
        -- Halloween may schedule its own cycle only after the existing normal
        -- steal (including its treadmill return and cleanup) has finished.
        if not api.Active and (state.Busy or state.Aborting) then
            report("Wait for the current steal to finish before enabling")
            return false
        end
        api.Enabled = true
        nextScan = 0
        report("ON; waiting for a safe start")
        api.start()
        return true
    end
    function api.setStealEggs(value)
        if api.Active then report("Stop the current cycle before changing egg mode"); return false end
        api.StealEggs = value == true
        nextScan = 0
        return true
    end
    function api.setZonePriority(value)
        if api.Active then report("Stop the current cycle before changing zone priority"); return false end
        api.ZonePriority = value == true
        return true
    end
    function api.setFilters(names, rarities)
        if api.Active or type(names) ~= "table" or type(rarities) ~= "table" then return false end
        local function clean(input)
            local result, count = {}, 0
            for name, selected in pairs(input) do
                if type(selected) ~= "boolean" then return nil end
                if selected then
                    if type(name) ~= "string" or name == "" then return nil end
                    count += 1
                    if count > 512 then return nil end
                    result[name] = true
                end
            end
            return result
        end
        local nextNames, nextRarities = clean(names), clean(rarities)
        if not nextNames or not nextRarities then report("Invalid filters; previous selection kept"); return false end
        api.Names, api.Rarities = nextNames, nextRarities
        nextScan = 0
        return true
    end
    function api.catalog()
        local pets = dependency("Pets")
        local count = 0
        for name in pairs(pets and type(pets.Specs) == "table" and pets.Specs or {}) do
            count += 1
            if count > 512 then break end
            if type(name) == "string" then knownNames[name], knownRarities[rarity(name)] = true, true end
        end
        local names, rarities = {}, {}
        for name in pairs(knownNames) do names[#names + 1] = name end
        for value in pairs(knownRarities) do rarities[#rarities + 1] = value end
        table.sort(names); table.sort(rarities)
        return names, rarities
    end
    local features = { AutoBuy = true, CrossWorld = true, HitMobs = true, CollectPumpkins = true,
        AutoFish = true, PhantomExpress = true, TradeSouls = true }
    function api.setFeature(name, value)
        if not features[name] or api.Active then return false end
        api[name] = value == true
        for _, feature in pairs(modules) do
            if type(feature.preferenceChanged) == "function" then pcall(feature.preferenceChanged, name, api[name]) end
        end
        nextScan = 0
        return true
    end
    function api.setMobFilters(names, rarities)
        if api.Active or type(names) ~= "table" or type(rarities) ~= "table" then return false end
        local function clean(input)
            local out, count = {}, 0
            for key, selected in pairs(input) do
                if type(selected) ~= "boolean" then return nil end
                if selected then
                    if type(key) ~= "string" or key == "" then return nil end
                    count += 1
                    if count > 512 then return nil end
                    out[key] = true
                end
            end
            return out
        end
        local nextNames, nextRarities = clean(names), clean(rarities)
        if not nextNames or not nextRarities then return false end
        api.MobNames, api.MobRarities = nextNames, nextRarities
        nextScan = 0
        return true
    end
    function api.mobCatalog()
        local feature = modules.Field
        if feature and type(feature.catalog) == "function" then
            local ok, names, rarities = pcall(feature.catalog)
            if ok and type(names) == "table" and type(rarities) == "table" then return names, rarities end
        end
        return {}, {}
    end
    function api.exitForNormal()
        if api.Active or state.Busy or state.Aborting or api.TrainReserved or state.Carrying or api.hasCarry() then return false end
        if not api.inside() then return true end
        return begin(true, "Return")
    end
    function api.returnHome()
        api.cancel("Returning home")
        if state.Carrying or api.hasCarry() then report("Put down carried items before Return Home"); return false end
        if api.TrainReserved then return begin(true, "Train") end
        if not api.inside() then report("Already outside Halloween"); return true end
        return begin(true, "Return")
    end
    local players
    pcall(function() players = game:GetService("Players") end)
    local ctx = { API = api, Prefs = api, Stats = api.Stats, Runtime = runtime, Player = localPlayer,
        Players = players, ReplicatedStorage = ReplicatedStorage, Workspace = workspace, Remote = remote,
        root = root, valid = valid, wait = waitFor, request = request, move = move,
        report = report, candy = candy, rarity = rarity, dependency = dependency,
        attr = attr, hasCarry = api.hasCarry, inside = api.inside }
    ctx.continueMob = continueMob
    function ctx.moveTrain(owner, position)
        if owner.TaskKind ~= "Train" or not valid(owner) or not finite(position) then return false end
        local ok = pcall(function()
            owner.Root.CFrame = CFrame.new(position)
            owner.Root.AssemblyLinearVelocity = Vector3.zero
            owner.Root.AssemblyAngularVelocity = Vector3.zero
        end)
        return ok and valid(owner)
    end
    function ctx.reserveTrain(owner, value)
        if owner.TaskKind ~= "Train" or not valid(owner) then return false end
        api.TrainReserved = value == true
        return true
    end
    function ctx.firePrompt(owner, promptObject, validatePrompt)
        if not valid(owner) or not promptObject or not promptObject.Parent or promptObject.Enabled ~= true then return false end
        owner.Prompts[promptObject] = true
        local ok, fired = request(owner, "ActivityPrompt", 1.2, function()
            if not valid(owner) or not promptObject.Parent or promptObject.Enabled ~= true
                or (validatePrompt and not validatePrompt()) then return false end
            return runtime.firePrompt(promptObject)
        end)
        return ok and fired == true and valid(owner)
    end
    for key, factory in pairs({ Field = runtime.halloweenFieldFactory, Fishing = runtime.halloweenFishingFactory, Train = runtime.halloweenTrainFactory }) do
        if type(factory) == "function" then
            local ok, feature = pcall(factory, ctx)
            if ok and type(feature) == "table" and type(feature.step) == "function" then modules[key] = feature end
        end
    end
    return api
end)()
-- End Halloween activity coordinator.




-- Cross-world priority delegates normal eggs to the existing S2R controller.
runtime.halloweenCrossWorld = (function()
    local hw = runtime.halloween
    local api = { Pending = false, NextProbe = 0, Probe = nil }
    local function normalBusy()
        local auto = runtime.autoSteal
        return (state.Busy and state.HalloweenOwner == nil) or (auto and (auto.Active ~= nil or auto.Pending))
    end
    local function reset()
        api.Probe, api.Pending = nil, false
        hw.NormalHandoff = false
        api.NextProbe = os.clock() + 3
    end
    hw.normalHandoffReset = reset
    local function eligible(record, auto, filter)
        if type(record) ~= "table" or type(record.Uid) ~= "string" or not filter.matches(record) then return false end
        local handled = auto.Handled and auto.Handled[record.Uid]
        return not handled or (not handled.Delivered and type(handled.RetryAt) == "number" and os.clock() >= handled.RetryAt)
    end
    function api.step()
        local auto, filter = runtime.autoSteal, runtime.rarityFilter
        local handoff = hw.NormalHandoff
        if handoff then
            if handoff.Phase == "Exit" then
                if hw.Active then return true end
                if hw.inside() then
                    reset()
                    hw.Status = "Halloween: cross-world exit was not confirmed; event mode resumed"
                    return false
                end
                handoff.Phase, handoff.Allow, handoff.Expires = "Normal", true, os.clock() + 12
            end
            -- An accepted normal trip owns all its original retries and treadmill
            -- return, even if the cross-world preference is switched OFF meanwhile.
            local acceptedTrip = (state.Busy and state.HalloweenOwner == nil)
                or (auto and auto.Active ~= nil) or state.AutoRun ~= nil
            if acceptedTrip then
                handoff.Started = true
                return true
            end
            -- A pending snapshot has not accepted a trip. Revoking priority
            -- must revoke its admission before it can begin a new normal route.
            if not hw.CrossWorld or not hw.Enabled or not auto or not auto.Enabled then
                reset()
                return false
            end
            if normalBusy() then return true end
            if handoff.Started or not hw.Enabled or not hw.CrossWorld or not auto or not auto.Enabled
                or os.clock() >= handoff.Expires or localPlayer.Character ~= handoff.Character then
                reset()
                return false
            end
            auto.step()
            if hw.NormalHandoff == handoff and state.Busy and not state.HalloweenOwner then handoff.Started = true end
            return hw.NormalHandoff == handoff
        end
        if not alive or not hw.Enabled or not hw.CrossWorld or hw.Active or hw.TrainReserved
            or hw.hasCarry() or state.Carrying or state.Busy or state.Aborting or api.Pending
            or os.clock() < api.NextProbe or not auto or not auto.Enabled or not filter
            or filter.All or next(filter.Selected) == nil or viewState or performance.Restoring then return false end
        local finder = runtime.bigEggFinder
        if finder and (finder.IsJoining or finder.IsOpen) then return false end
        if runtime.filterUi and runtime.filterUi.Panel.Visible then return false end
        local token = { Character = localPlayer.Character, Root = root(), TripId = state.TripId,
            FilterGeneration = filter.Generation, AutoGeneration = auto.Generation }
        if not token.Character or not token.Root then return false end
        local function current()
            return alive and api.Probe == token and hw.Enabled and hw.CrossWorld and not hw.Active
                and not hw.TrainReserved and not hw.hasCarry() and not state.Carrying and not state.Busy
                and not state.Aborting and state.TripId == token.TripId and localPlayer.Character == token.Character
                and root() == token.Root and auto.Enabled and auto.Generation == token.AutoGeneration
                and filter.Generation == token.FilterGeneration and not filter.All and next(filter.Selected) ~= nil
                and not (runtime.bigEggFinder and (runtime.bigEggFinder.IsJoining or runtime.bigEggFinder.IsOpen))
        end
        api.Probe, api.Pending, api.NextProbe = token, true, os.clock() + 3
        local found = false
        local ok, failure = pcall(function()
            -- snapshot already has its existing bounded request and remote guards.
            local records = snapshot(false)
            local snapshotError = state.SnapshotError
            if not current() or snapshotError or type(records) ~= "table" then return end
            for index, record in ipairs(records) do
                if eligible(record, auto, filter) then found = true; break end
                if index % 40 == 0 then
                    task.wait()
                    if not current() then return end
                end
            end
        end)
        local accepted = ok and found and current()
        if api.Probe == token then api.Probe, api.Pending = nil, false end
        if not ok then slog("Halloween cross-world: " .. tostring(failure)) end
        if not accepted then return false end
        local inside = hw.inside()
        handoff = { Phase = inside and "Exit" or "Normal", Allow = not inside, Started = false,
            Character = token.Character, Expires = os.clock() + 12 }
        hw.NormalHandoff = handoff
        if inside and not hw.exitForNormal() then reset(); return false end
        hw.Status = "Halloween: letting S2R take the matching normal egg"
        return true
    end
    hw.normalHandoff = api.step
    return api
end)()

------------------------------------------------------------------ UI: violet & black, low-device toggle added
local WHITE = THEME.Text
local SILVER = THEME.Violet
local STEEL = THEME.Border
local BG = THEME.Black
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
do
    local ok = pcall(function() gui.Parent = parentGui() end)
    if not ok then gui.Parent = localPlayer:FindFirstChildOfClass("PlayerGui") end
end

local W, H, HEADER = 340, 448, 36
local window = make("Frame", { Size = UDim2.fromOffset(W, H), Position = UDim2.new(0.5, -W / 2, 0.5, -H / 2), BackgroundColor3 = BG, BorderSizePixel = 0, ClipsDescendants = false })
window.Parent = gui
corner(window, 14)
stroke(window, 1, true)

-- Preferred dimensions survive minimize and rotation. Pointer work is event-driven.
do
    local scale = make("UIScale", { Scale = 1 })
    scale.Parent = window
    local api = { Scale = scale, Width = W, Height = H, Minimized = false,
        MinWidth = 340, MinHeight = 416, MaxWidth = 640, MaxHeight = 900 }
    runtime.guiLayout = api
    local cameraLink
    local function finite(value)
        return type(value) == "number" and value == value and math.abs(value) < math.huge
    end
    local function viewport()
        local camera = workspace.CurrentCamera
        local size = camera and camera.ViewportSize
        if size and finite(size.X) and finite(size.Y) and size.X > 16 and size.Y > 16 then return size end
    end
    function api.cancelGesture()
        local gesture = api.Gesture
        if gesture and gesture.Worker then runtime.cancel(gesture.Worker); gesture.Worker = nil end
        api.Gesture = nil
        api.Resizing, api.Dragging = false, false
    end
    function api.clamp()
        local size = viewport()
        if not size then return end
        local width = api.Width * scale.Scale
        local height = window.Size.Y.Offset * scale.Scale
        local x = window.Position.X.Scale * size.X + window.Position.X.Offset
        local y = window.Position.Y.Scale * size.Y + window.Position.Y.Offset
        x = math.clamp(x, 8, math.max(8, size.X - width - 8))
        y = math.clamp(y, 8, math.max(8, size.Y - height - 8))
        local current = window.Position
        if current.X.Scale ~= 0 or current.Y.Scale ~= 0 or current.X.Offset ~= x or current.Y.Offset ~= y then
            window.Position = UDim2.fromOffset(x, y)
        end
    end
    function api.render()
        local height = api.Minimized and HEADER + 4 or api.Height
        if window.Size.X.Offset ~= api.Width or window.Size.Y.Offset ~= height then
            window.Size = UDim2.fromOffset(api.Width, height)
        end
        local listHeight = math.max(92, api.Height - 324)
        if api.List and api.List.Size.Y.Offset ~= listHeight then api.List.Size = UDim2.new(1, 0, 0, listHeight) end
        if api.Footer and api.Footer.Visible == api.Minimized then api.Footer.Visible = not api.Minimized end
        api.clamp()
    end
    function api.fit()
        api.cancelGesture()
        local size = viewport()
        if not size then return end
        local fitted = math.max(0.01, math.min(1, (size.X - 16) / api.Width, (size.Y - 16) / api.Height))
        if scale.Scale ~= fitted then scale.Scale = fitted end
        api.render()
    end
    function api.setSize(width, height)
        if not finite(width) or not finite(height) then return false end
        api.Width = math.clamp(math.floor(width + 0.5), api.MinWidth, api.MaxWidth)
        api.Height = math.clamp(math.floor(height + 0.5), api.MinHeight, api.MaxHeight)
        api.fit()
        return true
    end
    local function paint(gesture)
        if api.Gesture ~= gesture or not alive or not gui.Parent or not gesture.Pending then return end
        local point = gesture.Pending
        gesture.Pending, gesture.LastPaint = nil, os.clock()
        local dx, dy = point.X - gesture.X, point.Y - gesture.Y
        if gesture.Kind == "resize" then
            -- Scale stays fixed under the finger. Integer dimensions avoid
            -- tiny geometry changes and unnecessary relayouts between pixels.
            api.Width = math.clamp(math.floor(gesture.Width + dx / gesture.Scale + 0.5), api.MinWidth, math.max(api.MinWidth, gesture.MaxWidth))
            api.Height = math.clamp(math.floor(gesture.Height + dy / gesture.Scale + 0.5), api.MinHeight, math.max(api.MinHeight, gesture.MaxHeight))
            api.render()
        else
            local x = math.floor(gesture.Position.X.Offset + dx + 0.5)
            local y = math.floor(gesture.Position.Y.Offset + dy + 0.5)
            if window.Position.X.Offset ~= x or window.Position.Y.Offset ~= y then
                window.Position = UDim2.fromOffset(x, y)
                api.clamp()
            end
        end
    end
    function api.flushGesture()
        local gesture = api.Gesture
        if gesture then
            if gesture.Worker then runtime.cancel(gesture.Worker); gesture.Worker = nil end
            paint(gesture)
        end
    end
    function api.setMinimized(value)
        -- Preserve the last observed pointer delta before hiding the content.
        api.flushGesture()
        api.cancelGesture()
        api.Minimized = value == true
        api.render()
    end
    function api.resetSize() api.setSize(W, H) end
    function api.begin(kind, input)
        if api.Gesture or not alive or not gui.Parent or (kind ~= "resize" and kind ~= "drag") then return false end
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return false end
        if not finite(input.Position.X) or not finite(input.Position.Y) or kind == "resize" and api.Minimized then return false end
        local size = viewport()
        if not size then return false end
        api.clamp()
        local x, y = window.Position.X.Offset, window.Position.Y.Offset
        local dragScale = scale.Scale
        api.Gesture = { Kind = kind, Input = input, X = input.Position.X, Y = input.Position.Y,
            Position = window.Position, Width = api.Width, Height = api.Height, Scale = dragScale,
            MaxWidth = math.floor(math.min(api.MaxWidth, (size.X - x - 8) / dragScale)),
            MaxHeight = math.floor(math.min(api.MaxHeight, (size.Y - y - 8) / dragScale)) }
        api.Resizing, api.Dragging = kind == "resize", kind == "drag"
        return true
    end
    function api.move(input)
        local gesture = api.Gesture
        if not gesture then return end
        local mouse = gesture.Input.UserInputType == Enum.UserInputType.MouseButton1
        if input ~= gesture.Input and not (mouse and input.UserInputType == Enum.UserInputType.MouseMovement) then return end
        local x, y = input.Position.X, input.Position.Y
        if not finite(x) or not finite(y) then return end
        gesture.Pending = { X = x, Y = y }
        local remaining = gesture.LastPaint and (1 / 60 - (os.clock() - gesture.LastPaint)) or 0
        if remaining <= 0 then
            api.flushGesture()
        elseif not gesture.Worker then
            -- A burst of touch events owns one cancellable job and the newest
            -- position. No permanent frame loop or animation work while idle.
            gesture.Worker = runtime.delay(remaining, function()
                if api.Gesture ~= gesture then return end
                gesture.Worker = nil
                paint(gesture)
            end)
        end
    end
    function api.finish(input)
        local gesture = api.Gesture
        if not gesture or gesture.Input ~= input then return end
        if input.UserInputType == Enum.UserInputType.Touch and finite(input.Position.X) and finite(input.Position.Y) then
            gesture.Pending = { X = input.Position.X, Y = input.Position.Y }
        end
        api.flushGesture()
        api.cancelGesture()
    end
    -- Scroll long feedback rather than hiding the cause behind an ellipsis.
    function api.makeStatus(parent, size, position, order, fontSize)
        local panel = make("ScrollingFrame", { Name = "StatusDetails", Size = size, Position = position or UDim2.new(),
            LayoutOrder = order or 0, BackgroundColor3 = THEME.Surface, BorderSizePixel = 0,
            CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollingDirection = Enum.ScrollingDirection.Y, ScrollBarThickness = 3,
            ScrollBarImageColor3 = SILVER, ClipsDescendants = true, Active = true })
        panel.Parent = parent; corner(panel, 7)
        local label = text(panel, { Size = UDim2.new(1, -16, 0, size.Y.Offset - 4), Position = UDim2.fromOffset(6, 2),
            AutomaticSize = Enum.AutomaticSize.Y, Font = Enum.Font.Gotham, TextSize = fontSize or 12,
            TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
            TextTruncate = Enum.TextTruncate.None, Text = "" })
        runtime.connect(label:GetPropertyChangedSignal("Text"), function()
            if panel.Parent then panel.CanvasPosition = Vector2.new(0, 0) end
        end)
        return label
    end
    local function watchCamera()
        if cameraLink then
            cameraLink:Disconnect()
            local index = table.find(runtime.Links, cameraLink)
            if index then table.remove(runtime.Links, index) end
            cameraLink = nil
        end
        local camera = workspace.CurrentCamera
        if camera then cameraLink = runtime.connect(camera:GetPropertyChangedSignal("ViewportSize"), api.fit) end
        api.fit()
    end
    runtime.connect(workspace:GetPropertyChangedSignal("CurrentCamera"), watchCamera)
    watchCamera()
end

-- violet header with high-contrast title
local header = make("Frame", { Size = UDim2.new(1, -8, 0, HEADER - 4), Position = UDim2.fromOffset(4, 4), BackgroundColor3 = THEME.Violet, BorderSizePixel = 0 })
header.Parent = window
corner(header, 10)
make("UIGradient", {
    Color = ColorSequence.new(THEME.Violet, THEME.VioletDark),
    Rotation = 0,
}).Parent = header
local headerTitle = text(header, {
	Size = UDim2.new(1, -196, 1, 0), Position = UDim2.fromOffset(10, 0), Font = Enum.Font.GothamBold, TextSize = 14,
	TextColor3 = THEME.Text, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Center,
	TextTruncate = Enum.TextTruncate.AtEnd, TextWrapped = false, Text = "Renz Hub | Steal",
})

local function headerButton(label, offset)
	local b = make("TextButton", { Size = UDim2.fromOffset(30, 28), Position = UDim2.new(1, offset, 0.5, -14), BackgroundColor3 = BG, Font = Enum.Font.GothamBold, TextSize = 16, TextColor3 = WHITE, Text = label, AutoButtonColor = true })
	b.Parent = header
	corner(b, 7)
	stroke(b, 1, true)
	return b
end
local pageButton = headerButton("Eggs", -104)
pageButton.Size = UDim2.fromOffset(36, 28)
pageButton.TextSize = 11
local minimize = headerButton("-", -66)
local close = headerButton("x", -33)

local body = make("Frame", { Size = UDim2.new(1, -10, 1, -(HEADER + 42)), Position = UDim2.fromOffset(5, HEADER + 4), BackgroundTransparency = 1 })
body.Parent = window
local showingEggPage = false
local minimized = false
local eggPage = make("Frame", {
    Name = "BigEggPage", Size = body.Size, Position = body.Position,
    BackgroundTransparency = 1, Visible = false,
})
eggPage.Parent = window
make("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, FillDirection = Enum.FillDirection.Vertical }).Parent = body

local list = make("ScrollingFrame", {
	Size = UDim2.new(1, 0, 0, 142), LayoutOrder = 1, Visible = true, BackgroundColor3 = BG, BorderSizePixel = 0, ScrollBarThickness = 4, ScrollBarImageColor3 = SILVER,
	CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
})
list.Parent = body
runtime.guiLayout.List = list
runtime.guiLayout.render()
corner(list, 12)
stroke(list, 1, false)
make("UIListLayout", { Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder }).Parent = list
make("UIPadding", { PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5), PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 6) }).Parent = list

local statusLabel = runtime.guiLayout.makeStatus(body, UDim2.new(1, 0, 0, 40), nil, 2, 12)
statusLabel.Text = "Pick a pet"
runtime.guiLayout.StatusLabel, runtime.guiLayout.StatusFrame = statusLabel, statusLabel.Parent

-- Keep user-facing statuses concise while exposing refresh and FPS feedback.
local PUBLIC = {
    ["Pick a pet"] = true, ["That egg is gone"] = true, ["Delivered"] = true,
    ["Delivery failed"] = true, ["Delivery failed, treadmill then retry"] = true,
    ["Cancelling"] = true, ["No eggs available"] = true, ["Refreshing..."] = true,
    ["Refresh failed; try again"] = true, ["Stop trip to change FPS"] = true,
    ["Unfreeze to change FPS"] = true, ["FPS boost: ON"] = true,
    ["FPS boost: OFF"] = true, ["FPS change failed"] = true,
    ["Game data not ready"] = true, ["Game events not ready"] = true,
    ["Wait for your character"] = true, ["Cancelled"] = true,
    ["Trip timed out; try again"] = true,
    ["Could not reach the egg"] = true, ["The egg would not come free"] = true,
    ["Could not take the egg back"] = true, ["Treadmill reset failed"] = true,
    ["Died: stopped, waiting for the respawn"] = true,
    ["Semi TP: no portal now. Set Go to Run"] = true,
    ["Semi TP failed, going back to the front"] = true,
    ["Semi TP failed again. Press Steal again"] = true,
    ["Restoring graphics..."] = true,
    ["No matching eggs"] = true, ["Filter updated"] = true,
    ["Auto steal: ON"] = true, ["Auto steal: OFF"] = true,
    ["Waiting for matching eggs"] = true, ["Choose a rarity"] = true,
    ["Selected egg does not match filter"] = true,
    ["Held egg is not identified yet"] = true, ["Drop held egg before stealing"] = true,
    ["Held egg changed; stealing stopped"] = true,
    ["Leaving treadmill..."] = true, ["Leave the treadmill before stealing"] = true,
    ["Finish joining before stealing"] = true,
    ["Finish the trip before changing treadmill"] = true,
    ["Drop held egg before stealing"] = true,
    ["Leave the treadmill before stealing"] = true,
    ["Finish the trip before changing filters"] = true, ["Close the filter with Done"] = true,
    ["Finish the current trip before opening Big Egg Finder"] = true,
    ["Filter unavailable; try again"] = true,
}
status = function(msg)
	if not alive or not gui.Parent then return end
	msg = tostring(msg)
	if PUBLIC[msg] or string.sub(msg, 1, 9) == "Selected:" or string.sub(msg, 1, 5) == "Auto:" or string.sub(msg, 1, 10) == "Treadmill:" or string.sub(msg, 1, 10) == "Halloween:" then
		statusLabel.Text = msg
	elseif string.sub(msg, 1, 12) == "Egg snapshot" then
		statusLabel.Text = "Refresh failed; try again"
	elseif string.sub(msg, 1, 5) == "Error" then
        -- Keep the cause visible instead of replacing every failure with the
        -- same generic label. Full technical details remain in existing logs.
        local detail = msg:gsub("^Error:?%s*", ""):gsub("^.-:%d+:%s*", "", 1)
        detail = detail:gsub("[%c]", " "):gsub("%s+", " ")
        statusLabel.Text = "Error: " .. string.sub(detail ~= "" and detail or "operation failed", 1, 140)
	elseif state.Busy then
		statusLabel.Text = "Delivering"
	end
end

local function bigButton(parent, label, position, size)
	local b = make("TextButton", { Size = size, Position = position, BackgroundColor3 = BG, Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = WHITE, Text = label, AutoButtonColor = true })
	b.Parent = parent
	corner(b, 14)
	stroke(b, 1, true)
	if label == "Steal" then
		b.BackgroundColor3 = THEME.Violet
		make("UIGradient", {
			Color = ColorSequence.new(THEME.Violet, THEME.VioletDark),
			Rotation = 0,
		}).Parent = b
	end
	return b
end
local function smallToggle(label, order)
	local b = make("TextButton", { Size = UDim2.new(1, 0, 0, 30), LayoutOrder = order, BackgroundColor3 = BG, Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = WHITE, Text = label, AutoButtonColor = true })
	b.Parent = body
	corner(b, 8)
	stroke(b, 1, true)
	return b
end
local BLACKOUT_CODE = "YXSAE"
local blackRow = make("Frame", { Size = UDim2.new(1, 0, 0, 30), LayoutOrder = 3, BackgroundTransparency = 1 })
blackRow.Parent = body
local blackButton = make("TextButton", { Size = UDim2.new(0.58, -2, 1, 0), BackgroundColor3 = BG, Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = WHITE, Text = "Blackout: ON", AutoButtonColor = true })
blackButton.Parent = blackRow
corner(blackButton, 8)
stroke(blackButton, 1, true)
local codeBox = make("TextBox", { Size = UDim2.new(0.42, -2, 1, 0), Position = UDim2.new(0.58, 2, 0, 0), BackgroundColor3 = BG, Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = WHITE, PlaceholderText = "code", PlaceholderColor3 = SILVER, Text = "", ClearTextOnFocus = true })
codeBox.Parent = blackRow
corner(codeBox, 8)
stroke(codeBox, 1, false)
blackout.Locked = true
runtime.connect(codeBox.FocusLost, function()
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
runtime.connect(blackButton.Activated, function()
    if not alive or not gui.Parent or not body.Visible then return end
    if runtime.filterUi and runtime.filterUi.Panel.Visible then return end
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
local fpsButton = smallToggle("FPS Boost: OFF", 4)
runtime.connect(fpsButton.Activated, function()
    if not alive or not gui.Parent or not body.Visible then return end
    if runtime.filterUi and runtime.filterUi.Panel.Visible then return end
    if state.Busy then
        status("Stop trip to change FPS")
        return
    end
    if viewState then
        status("Unfreeze to change FPS")
        return
    end
    local ok, err = pcall(performance.setEnabled, not performance.Enabled)
    if not alive or not gui.Parent then return end
    fpsButton.Text = "FPS Boost: " .. (performance.Enabled and "ON" or "OFF")
    if ok then
        status(performance.Enabled and "FPS boost: ON" or "FPS boost: OFF")
    else
        slog("FPS boost toggle: " .. tostring(err))
        status("FPS change failed")
    end
end)
local buttonRow = make("Frame", { Size = UDim2.new(1, 0, 0, 38), LayoutOrder = 8, BackgroundTransparency = 1 })
buttonRow.Parent = body
local refreshButton = bigButton(buttonRow, "Refresh", UDim2.new(0, 0, 0, 0), UDim2.new(0.4, -2, 1, 0))
local stealButton = bigButton(buttonRow, "Steal", UDim2.new(0.4, 2, 0, 0), UDim2.new(0.6, -2, 1, 0))

local selectedUid = nil
local rows = {}

local function setSelected(uid)
    local previous = selectedUid
    selectedUid = uid
    local function style(row, on)
        if not row then return end
        local thickness = on and 1.5 or 1
        local color = on and THEME.VioletBright or STEEL
        if row.Stroke.Thickness ~= thickness then row.Stroke.Thickness = thickness end
        if row.Stroke.Color ~= color then row.Stroke.Color = color end
    end
    if previous ~= uid then style(rows[previous], false) end
    style(rows[uid], true)
end

-- Only one refresh may wait for a snapshot at a time. Existing rows survive
-- temporary network errors, and unchanged rows keep their instances/listeners.
function runtime.listRefreshAllowed()
    local layout, filter = runtime.guiLayout, runtime.filterUi
    return alive and gui.Parent ~= nil and not state.Busy and not state.Aborting
        and not minimized and not (body and body.Visible == false)
        and not (layout and layout.Gesture)
        and not (filter and filter.Panel and filter.Panel.Visible)
end
local rebuilding = false
local function rebuild(force)
    if rebuilding or not alive or not gui.Parent then return end
    local function defer()
        if alive and gui.Parent then
            if runtime.filterUi then runtime.filterUi.Requested = true end
            if force then runtime.ListRefreshForce = true end
        end
    end
    if not runtime.listRefreshAllowed() then defer(); return end
    force = force or runtime.ListRefreshForce == true
    runtime.ListRefreshForce = nil
    if runtime.filterUi then runtime.filterUi.Requested = false end
    rebuilding = true
    local filterGeneration = runtime.rarityFilter.Generation
    local function current()
        local accepted = runtime.listRefreshAllowed()
            and runtime.rarityFilter.Generation == filterGeneration
        if not accepted then defer() end
        return accepted
    end
    if force then status("Refreshing...") end
    local ok, err = pcall(function()
        local records = snapshot(force)
        if not current() then return end
        if state.SnapshotError or type(records) ~= "table" then
            status("Refresh failed; try again")
            return
        end
        -- Batch every refresh phase, including unchanged rows and removals.
        -- New-row creation/destruction counts twice against the item budget.
        local work, deadline = 0, os.clock() + 0.001
        local function checkpoint(weight)
            work += weight or 1
            if work >= 40 or os.clock() >= deadline then
                task.wait()
                work, deadline = 0, os.clock() + 0.001
            end
            return current()
        end
        local infos, wanted = {}, {}
        for _, record in ipairs(records) do
            local info = runtime.rarityFilter.matches(record) and describe(record) or nil
            if type(info) == "table" and type(info.Uid) == "string" and not wanted[info.Uid]
                and runtime.rarityFilter.matches(record) then
                local value = tonumber(info.Value) or 0
                if value ~= value or value == math.huge or value == -math.huge then value = 0 end
                info.Value = math.max(0, value)
                local rarity = tonumber(info.Rarity) or 1
                if rarity ~= rarity or rarity == math.huge or rarity == -math.huge then rarity = 1 end
                info.Rarity = math.clamp(math.floor(rarity), 1, #RARITY_COLORS)
                info.Name, info.Icon = tostring(info.Name or "Egg"), tostring(info.Icon or "")
                info.Record = record
                wanted[info.Uid] = true
                infos[#infos + 1] = info
            end
            if not checkpoint() then return end
        end
        table.sort(infos, function(a, b)
            if a.Value == b.Value then return a.Uid < b.Uid end
            return a.Value > b.Value
        end)
        for index, info in ipairs(infos) do
            if not current() then return end
            if not runtime.rarityFilter.matches(info.Record) then
                wanted[info.Uid] = nil
                if not checkpoint() then return end
                continue
            end
            local row = rows[info.Uid]
            local creating = row == nil
            if not row then
                local frame = make("TextButton", {
                    Size = UDim2.new(1, -2, 0, 40), BackgroundColor3 = THEME.Surface,
                    LayoutOrder = index, Text = "", AutoButtonColor = true,
                })
                corner(frame, 10)
                row = { Frame = frame, Stroke = stroke(frame, 1, false), Uid = info.Uid }
                row.Icon = make("ImageLabel", {
                    Size = UDim2.fromOffset(32, 32), Position = UDim2.fromOffset(4, 4),
                    BackgroundTransparency = 1, Image = "", ScaleType = Enum.ScaleType.Fit,
                })
                row.Icon.Parent = frame
                row.Name = text(frame, {
                    Size = UDim2.new(1, -44, 0, 18), Position = UDim2.fromOffset(40, 2),
                    Font = Enum.Font.GothamBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd, Text = "",
                })
                row.Value = text(frame, {
                    Size = UDim2.new(1, -44, 0, 16), Position = UDim2.fromOffset(40, 21),
                    Font = Enum.Font.GothamMedium, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
                    Text = "",
                })
                -- Destroying a row disconnects this instance-owned listener.
                frame.Activated:Connect(function()
                    if not alive or not body.Visible or state.Busy or state.Aborting or not list.Visible or rows[row.Uid] ~= row or not row.Frame.Visible
                        or (runtime.filterUi and runtime.filterUi.Panel.Visible)
                        or not runtime.rarityFilter.matches(row.Record) then return end
                    setSelected(row.Uid)
                    status("Selected: " .. row.Name.Text)
                end)
                rows[info.Uid] = row
                frame.Parent = list
            end
            -- Description helpers may yield. Use the current tier when
            -- publishing rather than a label/color captured before the yield.
            local displayedRarity = runtime.rarityFilter.identity(info.Record)
            local displayRank = tonumber(displayedRarity.Rank) or 1
            if displayRank ~= displayRank or math.abs(displayRank) == math.huge then displayRank = 1 end
            local colorIndex = math.clamp(math.floor(displayRank), 1, #RARITY_COLORS)
            row.RarityKey, row.RarityLabel, row.RarityRank = displayedRarity.Key, displayedRarity.Label, displayedRarity.Rank
            row.Record = info.Record
            if row.Frame.Visible ~= true then row.Frame.Visible = true end
            if row.Frame.LayoutOrder ~= index then row.Frame.LayoutOrder = index end
            if row.Icon.Image ~= info.Icon then row.Icon.Image = info.Icon end
            if row.Name.Text ~= info.Name then row.Name.Text = info.Name end
            local color = RARITY_COLORS[colorIndex] or WHITE
            if row.Name.TextColor3 ~= color then row.Name.TextColor3 = color end
            local rarityLabel = displayedRarity.Label
            local valueText = money(info.Value) .. "  |  " .. rarityLabel
            if row.Value.Text ~= valueText then row.Value.Text = valueText end
            if not checkpoint(creating and 2 or 1) then return end
        end
        if not current() then return end
        local visibleCount = 0
        for uid, row in pairs(rows) do
            if not wanted[uid] or not runtime.rarityFilter.matches(row.Record) then
                wanted[uid] = nil
                rows[uid] = nil
                row.Frame:Destroy()
            else
                visibleCount += 1
            end
            if not checkpoint(wanted[uid] and 1 or 2) then return end
        end
        -- Only pure metadata checks run in this final no-yield gate. If a
        -- tier changed during the batched removals, hide the list and queue
        -- a fresh pass instead of exposing stale matches or doing a large
        -- synchronous instance-destruction pass.
        for _, row in pairs(rows) do
            local matching = runtime.rarityFilter.matches(row.Record)
            local currentRarity = runtime.rarityFilter.identity(row.Record)
            if not matching or row.RarityKey ~= currentRarity.Key
                or row.RarityLabel ~= currentRarity.Label or row.RarityRank ~= currentRarity.Rank then
                list.Visible = false
                -- Retain a still-matching manual target across a label change.
                -- The hidden list blocks actions until the queued pass finishes.
                if not matching then setSelected(nil) end
                if runtime.filterUi then runtime.filterUi.Requested = true end
                return
            end
        end
        if not list.Visible then list.Visible = true end
        local lostSelection = selectedUid ~= nil and not wanted[selectedUid]
        setSelected(selectedUid and wanted[selectedUid] and selectedUid or nil)
        local listStatus = statusLabel.Text == "Pick a pet" or statusLabel.Text == "No eggs available"
            or statusLabel.Text == "No matching eggs" or statusLabel.Text == "Filter updated"
            or statusLabel.Text == "Refreshing..." or statusLabel.Text == "Refresh failed; try again" or string.sub(statusLabel.Text, 1, 9) == "Selected:"
        if runtime.autoSteal.Enabled and not force then
            -- The auto controller owns idle/wait/failure feedback while enabled.
        elseif visibleCount == 0 and (force or listStatus) then
            status(#records == 0 and "No eggs available" or "No matching eggs")
        elseif (force or listStatus) and (force or lostSelection or string.sub(statusLabel.Text, 1, 9) == "Selected:"
            or statusLabel.Text == "No eggs available" or statusLabel.Text == "Refresh failed; try again"
            or statusLabel.Text == "Refreshing..." or statusLabel.Text == "No matching eggs"
            or statusLabel.Text == "Filter updated") then
            if selectedUid and rows[selectedUid] then
                status("Selected: " .. rows[selectedUid].Name.Text)
            else
                status("Pick a pet")
            end
        end
    end)
    rebuilding = false
    if not ok and alive and gui.Parent then
        slog("List refresh: " .. tostring(err))
        status("Refresh failed; try again")
    end
end

runtime.connect(refreshButton.Activated, function()
    if not alive or not gui.Parent or not body.Visible then return end
    if runtime.filterUi and runtime.filterUi.Panel.Visible then status("Close the filter with Done"); return end
    if viewState and viewState.Forced then
        releaseView()
        semi.Kind, semi.Home = nil, nil
        return
    end
    if not state.Busy and not rebuilding then
        runtime.spawn(rebuild, true)
    end
end)
-- Rarity controls are scoped so the large script keeps its local-register budget.
do
    local ui = { Rows = {}, Requested = false, NextCatalog = 0, Minimized = false, Syncing = false }
    runtime.filterUi = ui
    local rarityButton = smallToggle("Rarities: All", 5)
    rarityButton.Size = UDim2.new(1, 0, 0, 32)
    rarityButton.TextTruncate = Enum.TextTruncate.AtEnd
    local autoRow = make("Frame", { Size = UDim2.new(1, 0, 0, 32), LayoutOrder = 6, BackgroundTransparency = 1 })
    autoRow.Parent = body
    local autoButton = smallToggle("Auto steal: OFF", 6)
    autoButton.Parent = autoRow
    autoButton.Size = UDim2.new(0.52, -2, 1, 0)
    autoButton.TextSize = 11
    local treadmillButton = smallToggle("Treadmill: ON", 6)
    treadmillButton.Parent = autoRow
    treadmillButton.Size = UDim2.new(0.48, -2, 1, 0)
    treadmillButton.Position = UDim2.new(0.52, 2, 0, 0)
    treadmillButton.TextSize = 11
    ui.TreadmillButton = treadmillButton
    local hint = text(body, { Size = UDim2.new(1, 0, 0, 16), LayoutOrder = 7,
        Text = "Pick an egg, or turn Auto steal ON", Font = Enum.Font.Gotham, TextSize = 11 })
    ui.RarityButton, ui.AutoButton = rarityButton, autoButton

    -- The picker replaces the body while open, so taps cannot reach controls behind it.
    local panel = make("Frame", {
        Name = "RarityFilter", Size = UDim2.new(1, -10, 1, -(HEADER + 42)), Position = UDim2.fromOffset(5, HEADER + 4),
        BackgroundColor3 = BG, BorderSizePixel = 0, Visible = false, Active = true, ZIndex = 20,
    })
    panel.Parent = window
    corner(panel, 10)
    stroke(panel, 1, true)
    ui.Panel = panel
    ui.Title = text(panel, { Size = UDim2.new(1, -16, 0, 28), Position = UDim2.fromOffset(8, 4),
        Text = "Choose rarities", Font = Enum.Font.GothamBold, TextSize = 14, ZIndex = 21 })
    ui.Help = text(panel, { Size = UDim2.new(1, -16, 0, 30), Position = UDim2.fromOffset(8, 32),
        Text = "Tap tiers to choose which eggs appear", Font = Enum.Font.Gotham, TextSize = 11,
        TextWrapped = true, ZIndex = 21 })
    local choices = make("ScrollingFrame", {
        Size = UDim2.new(1, -16, 1, -110), Position = UDim2.fromOffset(8, 64),
        BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 4,
        CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ZIndex = 21,
    })
    choices.Parent = panel
    make("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }).Parent = choices
    local empty = text(choices, { Size = UDim2.new(1, -4, 0, 30), Text = "Waiting for game data",
        Font = Enum.Font.Gotham, TextSize = 12, TextWrapped = true, ZIndex = 22 })

    function ui.setOpen(open)
        open = open == true
        if open and (minimized or showingEggPage or (runtime.halloweenUi and runtime.halloweenUi.Open)) then return false end
        if open and (state.Busy or state.Aborting) then status("Finish the trip before changing filters"); return false end
        panel.Visible = open and not ui.Minimized
        body.Visible = not panel.Visible and not ui.Minimized and not showingEggPage
            and not (runtime.halloweenUi and runtime.halloweenUi.Open)
        ui.NextCatalog = 0
        if not panel.Visible then ui.Requested = true end
        return true
    end
    local function changed(didChange)
        if not didChange then return end
        setSelected(nil)
        -- Hide the list once; no synchronous walk of every row on each tap.
        list.Visible = false
        ui.Requested = true
        ui.NextCatalog = 0
        status("Filter updated")
    end
    local function syncBody()
        if state.Busy and panel.Visible then ui.setOpen(false) end
        local label = "Rarities: " .. runtime.rarityFilter.summary()
        if rarityButton.Text ~= label then rarityButton.Text = label end
        local treadmillEnabled = runtime.autoTreadmill and runtime.autoTreadmill.Enabled == true
        local treadmillLabel = "Treadmill: " .. (treadmillEnabled and "ON" or "OFF")
        if treadmillButton.Text ~= treadmillLabel then treadmillButton.Text = treadmillLabel end
        local treadmillColor = treadmillEnabled and THEME.Violet or BG
        if treadmillButton.BackgroundColor3 ~= treadmillColor then treadmillButton.BackgroundColor3 = treadmillColor end
        local enabled = runtime.autoSteal.Enabled
        local autoLabel = "Auto steal: " .. (enabled and "ON" or "OFF")
        if autoButton.Text ~= autoLabel then autoButton.Text = autoLabel end
        local color = enabled and THEME.Violet or BG
        if autoButton.BackgroundColor3 ~= color then autoButton.BackgroundColor3 = color end
        local hintText = enabled and "Auto watches only matching eggs" or "Pick an egg, or turn Auto steal ON"
        if hint.Text ~= hintText then hint.Text = hintText end
        if not panel.Visible or os.clock() < ui.NextCatalog then return end
        ui.NextCatalog = os.clock() + 2
        ui.Title.Text = "Rarities: " .. runtime.rarityFilter.summary()
        ui.Help.Text = runtime.rarityFilter.All and "All allowed. Tap a tier to select only it."
            or (next(runtime.rarityFilter.Selected) and "Checked tiers are allowed. Press Done." or "None selected: no eggs will be targeted.")
        local catalog, wanted = runtime.rarityFilter.catalog(), {}
        empty.Visible = #catalog == 0
        for index, descriptor in ipairs(catalog) do
            local key = descriptor.Key
            wanted[key] = true
            local button = ui.Rows[key]
            if not button then
                button = make("TextButton", { Size = UDim2.new(1, -6, 0, 34),
                    BackgroundColor3 = THEME.Surface, BorderSizePixel = 0, Font = Enum.Font.GothamBold,
                    TextSize = 12, TextColor3 = WHITE, Text = "", TextTruncate = Enum.TextTruncate.AtEnd,
                    ZIndex = 22, AutoButtonColor = true })
                button.Parent = choices
                corner(button, 6)
                ui.Rows[key] = button
                button.Activated:Connect(function()
                    if not alive or not panel.Visible or state.Busy or state.Aborting or ui.Rows[key] ~= button then return end
                    changed(runtime.rarityFilter.toggle(key))
                    ui.sync()
                end)
            end
            if button.LayoutOrder ~= index then button.LayoutOrder = index end
            local selected = runtime.rarityFilter.All or runtime.rarityFilter.Selected[key] == true
            local label = (selected and "[x] " or "[ ] ") .. descriptor.Label
                .. (descriptor.Available == false and " (unavailable)" or "")
            if button.Text ~= label then button.Text = label end
            local color = selected and THEME.VioletDark or THEME.Surface
            if button.BackgroundColor3 ~= color then button.BackgroundColor3 = color end
        end
        for key, button in pairs(ui.Rows) do
            if not wanted[key] then ui.Rows[key] = nil; button:Destroy() end
        end
    end
    function ui.sync()
        if not alive or not gui.Parent or ui.Syncing then return end
        ui.Syncing = true
        local ok, err = pcall(syncBody)
        ui.Syncing = false
        if not ok then
            ui.NextCatalog = os.clock() + 2
            slog("Filter UI: " .. tostring(err))
            if not state.Busy then status("Filter unavailable; try again") end
        end
    end
    local function panelButton(label, x, callback)
        local button = make("TextButton", { Size = UDim2.new(1/3, -6, 0, 34),
            Position = UDim2.new(x, 3, 1, -40), BackgroundColor3 = THEME.Violet,
            Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = WHITE, Text = label,
            AutoButtonColor = true, ZIndex = 22 })
        button.Parent = panel
        corner(button, 6)
        runtime.connect(button.Activated, function()
            if not panel.Visible or state.Busy or state.Aborting then return end
            callback()
        end)
        return button
    end
    ui.AllButton = panelButton("All", 0, function()
        changed(runtime.rarityFilter.setAll(true)); ui.sync()
    end)
    ui.NoneButton = panelButton("None", 1/3, function()
        changed(runtime.rarityFilter.setAll(false)); ui.sync()
    end)
    ui.DoneButton = panelButton("Done", 2/3, function() ui.setOpen(false) end)
    runtime.connect(rarityButton.Activated, function()
        ui.setOpen(not panel.Visible); ui.sync()
    end)
    runtime.connect(treadmillButton.Activated, function()
        if not alive or not gui.Parent then return end
        if panel.Visible then status("Close the filter with Done"); return end
        if minimized or showingEggPage or not body.Visible then return end
        if state.Busy or state.Aborting then status("Finish the trip before changing treadmill"); return end
        if not runtime.autoTreadmill then status("Treadmill: unavailable"); return end
        runtime.autoTreadmill.setEnabled(not runtime.autoTreadmill.Enabled)
        status(runtime.autoTreadmill.Enabled and "Treadmill: ON after delivery" or "Treadmill: OFF")
        ui.sync()
    end)
    runtime.connect(autoButton.Activated, function()
    if not alive or not gui.Parent or not body.Visible then return end
        if panel.Visible then status("Close the filter with Done"); return end
        runtime.autoSteal.setEnabled(not runtime.autoSteal.Enabled)
        ui.sync()
    end)
    ui.sync()
end

-- External reports are observations, not proof that an egg is still present.
-- Normalize before rendering so sorting, alerts and joins share one interpretation.
runtime.bigEggData = (function()
    local api = {}
    local MAX_TEXT = 160

    local function finite(value)
        if type(value) ~= "number" and type(value) ~= "string" then return nil end
        if type(value) == "string" then
            if #value > 128 then return nil end
            local s = value:match("^%s*(.-)%s*$")
            local mantissa, exponent = s:match("^([%+%-]?[%d%.]+)[eE]([%+%-]?%d+)$")
            mantissa = mantissa or s
            if not mantissa:match("^[%+%-]?%d+%.?%d*$")
                and not mantissa:match("^[%+%-]?%.%d+$") then return nil end
            -- Hexadecimal and other nondecimal tonumber syntax is not a
            -- kilogram count, Unix timestamp or Roblox numeric place ID.
        end
        local n = tonumber(value)
        return n and n == n and n >= 0 and n < math.huge and n or nil
    end
    local function clean(value, fallback)
        if type(value) ~= "string" and type(value) ~= "number" then return fallback end
        local s = tostring(value):gsub("[%z\1-\31\127]", " "):match("^%s*(.-)%s*$")
        return s ~= "" and s:sub(1, MAX_TEXT) or fallback
    end
    local function opaque(value)
        -- Identifiers must not be truncated or rewritten like display text:
        -- doing so can merge different eggs or alter a server destination.
        if type(value) ~= "string" or value == "" or #value > 160
            or value:find("[%z\1-\31\127]") or value:match("^%s") or value:match("%s$") then return nil end
        return value
    end
    local function numberText(s)
        if #s > 80 then return nil end
        s = s:gsub("^%+", "")
        local integer, fraction = s:match("^(.-)%.(%d*)$")
        if not integer then integer = s end
        if integer == "" and fraction and fraction ~= "" then integer = "0" end
        if integer:find(",", 1, true) then
            local first, rest = integer:match("^(%d+)(,.*)$")
            if not first or #first > 3 then return nil end
            while #rest > 0 do
                local group, tail = rest:match("^,(%d%d%d)(.*)$")
                if not group then return nil end
                rest = tail
            end
        elseif not integer:match("^%d+$") then return nil end
        return finite(s:gsub(",", ""))
    end

    function api.weight(egg)
        if type(egg) ~= "table" then return nil end
        local direct = finite(egg.weightKg)
        if direct ~= nil then return direct, "weightKg" end
        if type(egg.weightFormatted) ~= "string" then return nil end
        local s = egg.weightFormatted:lower():match("^%s*(.-)%s*$")
        if #s > 100 then return nil end
        local unit = 1
        local kg = s:match("kg%s*$") or s:match("kilograms?%s*$")
        if kg then
            s = s:gsub("kilograms?%s*$", ""):gsub("kg%s*$", "")
        elseif s:match("tonnes?%s*$") then
            unit = 1000; s = s:gsub("tonnes?%s*$", "")
        elseif s:match("grams?%s*$") or s:match("g%s*$") then
            unit = 0.001; s = s:gsub("grams?%s*$", ""):gsub("g%s*$", "")
        end
        s = s:match("^%s*(.-)%s*$")
        local text, suffix = s:match("^(.-)%s*([kmbt])$")
        local multiplier = 1
        if suffix then
            -- Bare 't' is ambiguous (tonnes versus trillion): require kg.
            if suffix == "t" and not kg then return nil end
            multiplier = ({ k = 1e3, m = 1e6, b = 1e9, t = 1e12 })[suffix]
            s = text
        end
        local n = numberText(s)
        n = n and n * multiplier * unit or nil
        n = finite(n)
        return n, n and "weightFormatted" or nil
    end

    function api.timestamp(value)
        local n = finite(value)
        if n then
            if n >= 1e14 then return nil end -- unsupported micro/nanosecond fields
            if n >= 1e11 then n /= 1000 end
            return n
        end
        if type(value) ~= "string" or #value > 40 then return nil end
        local y, mo, d, h, mi, se, suffix = value:match("^(%d%d%d%d)%-(%d%d)%-(%d%d)[Tt](%d%d):(%d%d):(%d%d)(.*)$")
        if not y then return nil end
        y, mo, d, h, mi, se = tonumber(y), tonumber(mo), tonumber(d), tonumber(h), tonumber(mi), tonumber(se)
        local fraction, zone = suffix:match("^(%.%d+)(.*)$")
        if fraction then suffix = zone; fraction = tonumber(fraction) else fraction = 0 end
        local offset = 0
        if suffix ~= "Z" and suffix ~= "z" then
            local sign, zh, zm = suffix:match("^([%+%-])(%d%d):(%d%d)$")
            zh, zm = tonumber(zh), tonumber(zm)
            if not sign or zh > 23 or zm > 59 then return nil end
            offset = (zh * 60 + zm) * 60 * (sign == "+" and 1 or -1)
        end
        local leap = y % 4 == 0 and (y % 100 ~= 0 or y % 400 == 0)
        local months = { 31, leap and 29 or 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }
        if y < 1970 or mo < 1 or mo > 12 or d < 1 or d > months[mo]
            or h > 23 or mi > 59 or se > 59 then return nil end
        local days = 365 * (y - 1970) + math.floor((y - 1) / 4) - math.floor(1969 / 4)
            - math.floor((y - 1) / 100) + math.floor(1969 / 100)
            + math.floor((y - 1) / 400) - math.floor(1969 / 400)
        for i = 1, mo - 1 do days += months[i] end
        return finite((days + d - 1) * 86400 + h * 3600 + mi * 60 + se + fraction - offset)
    end

    function api.fresh(item, now, maxAge)
        now, maxAge = finite(now), finite(maxAge)
        if type(item) ~= "table" or now == nil or maxAge == nil then return false end
        local stamp = item.Timestamp or item.timestamp
        return type(stamp) == "number" and stamp == stamp and now - stamp >= -30 and now - stamp <= maxAge
    end

    local function component(value)
        local s = tostring(value or "")
        return tostring(#s) .. ":" .. s
    end
    local function entry(item)
        if type(item) ~= "table" then return nil end
        local egg = type(item.egg) == "table" and item.egg or nil
        local uid = egg and (opaque(egg.uid) or opaque(egg.Uid) or opaque(egg.eggId) or opaque(egg.id))
            or opaque(item.eggId)
        if not egg and not uid then return nil end
        egg = egg or {}
        local numericTime, isoTime = api.timestamp(item.timestamp), api.timestamp(item.isoTime)
        local timestamp = numericTime and isoTime and math.min(numericTime, isoTime) or numericTime or isoTime
        if timestamp == nil then return nil end
        local timeConflict = numericTime ~= nil and isoTime ~= nil and math.abs(numericTime - isoTime) > 2
        local job = opaque(item.jobId) or ""
        local jobValid = job ~= "" and #job <= 128 and job:match("^[%w%-%_]+$") ~= nil
        local rawPlace = item.placeId
        if rawPlace == nil then rawPlace = item.PlaceId end
        local place = finite(rawPlace)
        if place and (place < 1 or place % 1 ~= 0 or place > 9007199254740991) then place = nil end
        local invalidPlace = rawPlace ~= nil and place == nil
        local name = clean(egg.name, nil)
        if not uid and not name then return nil end
        name = name or "Unknown egg"
        local rarity = clean(egg.rarity, "?")
        local area = clean(egg.area, "?")
        local weight, weightSource = api.weight(egg)
        local players = finite(item.serverPlayers)
        if players and players % 1 ~= 0 then players = nil end
        local inactive = item.active == false or item.isActive == false or item.removed == true
            or egg.active == false or egg.isActive == false or egg.removed == true
        local identity = uid and ("uid" .. component(uid)) or ("report" .. component(name)
            .. component(area) .. component(rarity) .. component(finite(egg.scale)) .. component(weight))
        local key = component(place or "current") .. component(job) .. identity
        local copy = table.clone(egg)
        copy.name, copy.rarity, copy.area = name, rarity, area
        copy.uid = uid
        copy.weightKg = weight
        local weightText = weight ~= nil and (string.format("%.10g", weight) .. " kg") or "Weight unknown"
        return {
            Key = key, JobId = job, jobId = job, Timestamp = timestamp, timestamp = timestamp,
            Name = name, WeightKg = weight, Weight = weight, WeightSource = weightSource, WeightText = weightText,
            WeightQuality = weightSource == "weightKg" and 2 or (weightSource == "weightFormatted" and 1 or 0),
            TimestampConflict = timeConflict,
            Rarity = rarity, Area = area, Players = players, serverPlayers = players,
            PlaceId = place, InvalidPlace = invalidPlace, Joinable = jobValid and not invalidPlace,
            RawEgg = copy, egg = copy, IdentityReliable = uid ~= nil, Inactive = inactive,
        }
    end

    local function signature(item)
        return component(item.Name) .. component(item.Rarity) .. component(item.Area) .. component(item.Players)
    end

    local function mergeEqual(previous, current)
        if previous.Inactive then return previous end
        if current.Inactive then return current end
        local pq, cq = previous.WeightQuality, current.WeightQuality
        local chosen = previous
        if cq > pq or (cq == pq and signature(current) < signature(previous)) then chosen = current end
        local quality = math.max(pq, cq)
        local conflict = pq == cq and quality > 0 and (previous.ConflictingWeight or current.ConflictingWeight
            or previous.WeightKg ~= current.WeightKg)
        -- Better numeric evidence can resolve a formatted-only disagreement;
        -- equal-quality disagreements remain unknown until a newer report.
        if pq > cq then conflict = previous.ConflictingWeight
        elseif cq > pq then conflict = current.ConflictingWeight end
        chosen.TimestampConflict = previous.TimestampConflict or current.TimestampConflict
        chosen.WeightQuality = quality
        chosen.ConflictingWeight = conflict == true
        if conflict then
            chosen.WeightKg, chosen.Weight, chosen.WeightSource = nil, nil, nil
            chosen.WeightText = "Weight conflict"
            chosen.RawEgg.weightKg, chosen.RawEgg.weightFormatted = nil, nil
        end
        return chosen
    end

    local function unpackEntries(result)
        if type(result) ~= "table" then return nil end
        if result.success == false or result.Success == false or result.error ~= nil then return nil end
        if type(result.egg) == "table" or result.eggId ~= nil then return { result } end
        local entries = result
        if result.data ~= nil then entries = result.data elseif result.eggs ~= nil then entries = result.eggs end
        if type(entries) ~= "table" then return nil end
        if type(entries.egg) == "table" or entries.eggId ~= nil then return { entries } end
        -- Only an array (including a genuinely empty table) is a valid list.
        for key in pairs(entries) do
            if type(key) ~= "number" or key < 1 or key % 1 ~= 0 then return nil end
        end
        return entries
    end

    function api.normalize(result, now, maxAge)
        now, maxAge = finite(now), finite(maxAge)
        if now == nil or maxAge == nil then return nil, "Invalid clock", {} end
        local entries = unpackEntries(result)
        if not entries then return nil, "Unexpected source format", {} end
        local stats = { Invalid = 0, Expired = 0, Future = 0, Duplicates = 0, Inactive = 0, UnknownWeight = 0, Rows = 0, Valid = 0 }
        local byKey = {}
        for _, raw in pairs(entries) do
            stats.Rows += 1
            local normalized = entry(raw)
            if normalized then stats.Valid += 1 end
            if not normalized then
                stats.Invalid += 1
            elseif now - normalized.Timestamp < -30 then
                stats.Future += 1
            else
                stats.NewestTimestamp = math.max(stats.NewestTimestamp or 0, normalized.Timestamp)
                local previous = byKey[normalized.Key]
                if previous then stats.Duplicates += 1 end
                if not previous or normalized.Timestamp > previous.Timestamp then
                    byKey[normalized.Key] = normalized
                elseif normalized.Timestamp == previous.Timestamp then
                    byKey[normalized.Key] = mergeEqual(previous, normalized)
                end
            end
        end
        -- A nonempty but wholly malformed response is a source failure, not
        -- evidence that earlier reports vanished. Valid expired/removal rows
        -- still describe a genuine empty result and may clear old entries.
        if stats.Rows > 0 and stats.Valid == 0 then
            return nil, "No valid reports in source", stats
        end
        local normalized = {}
        for _, item in pairs(byKey) do
            if item.Inactive then stats.Inactive += 1
            elseif not api.fresh(item, now, maxAge) then stats.Expired += 1
            else
                item.Age = math.max(0, now - item.Timestamp)
                item.ExpiresAt = item.Timestamp + maxAge
                if item.WeightKg == nil then stats.UnknownWeight += 1 end
                if item.ConflictingWeight then stats.ConflictingWeight = (stats.ConflictingWeight or 0) + 1 end
                if item.TimestampConflict then stats.TimestampConflict = (stats.TimestampConflict or 0) + 1 end
                normalized[#normalized + 1] = item
            end
        end
        table.sort(normalized, function(a, b)
            local aw, bw = a.WeightKg or -1, b.WeightKg or -1
            if aw ~= bw then return aw > bw end
            if a.Timestamp ~= b.Timestamp then return a.Timestamp > b.Timestamp end
            return a.Key < b.Key
        end)
        return normalized, nil, stats
    end
    return api
end)()

------------------------------------------------------------------ independent Big Egg Finder page
-- The feed reports discoveries from other servers; a recent report is not a
-- live confirmation that its egg is still present. Never execute feed scripts.
runtime.bigEggFinder = (function()
    local api = { Source = "http://-- erm rel ip : 127.0.0.1:8080/api/big-egg", MaxAge = 300,
        IsJoining = false, IsOpen = false, Refreshing = false, Entries = {}, Rows = {},
        NextRefreshAt = 0, Failures = 0, Closed = false, ByKey = {}, JoinNeedsRefresh = false,
        Page = 1, PageCount = 1, PageSize = 25, PageKeys = {}, Pool = {}, NeedsDraw = false }
    local notified, pending = {}, nil
    local refreshGeneration, joinAttempts = 0, 0
    local activeDraw
    -- Report timestamps are UTC seconds. A device clock can be hours wrong;
    -- prefer Roblox's synchronized clock and sample it at most once per second.
    local clockAnchor, clockAnchorAt, nextClockSample = nil, nil, 0
    local function reportNow()
        local monotonic = os.clock()
        if monotonic >= nextClockSample then
            nextClockSample = monotonic + 1
            local ok, value = pcall(function() return workspace:GetServerTimeNow() end)
            if ok and type(value) == "number" and value == value and value > 0 and value < math.huge then
                clockAnchor, clockAnchorAt = value, monotonic
            end
        end
        -- A temporary API failure must not switch an already synchronized
        -- finder back to a differently set device clock.
        if clockAnchor then return clockAnchor + math.max(0, monotonic - clockAnchorAt) end
        return os.time()
    end
    local httpKey = {}
    local httpService = game:GetService("HttpService")
    local teleportService = game:GetService("TeleportService")
    local title = text(eggPage, { Size = UDim2.new(1, -82, 0, 20), Position = UDim2.fromOffset(2, 0),
        Font = Enum.Font.GothamBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd, Text = "Recent Big Egg reports" })
    local feedback = text(eggPage, { Size = UDim2.new(1, -82, 0, 28), Position = UDim2.fromOffset(2, 22),
        Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = SILVER,
        TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, Text = "Not fetched yet." })
    local refreshButton = make("TextButton", { Size = UDim2.fromOffset(72, 34),
        Position = UDim2.new(1, -72, 0, 4), BackgroundColor3 = THEME.Violet,
        Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = WHITE, Text = "Refresh", AutoButtonColor = true })
    refreshButton.Parent = eggPage; corner(refreshButton, 8); stroke(refreshButton, 1, true)
    local results = make("ScrollingFrame", { Name = "BigEggResults", Size = UDim2.new(1, 0, 1, -104),
        Position = UDim2.fromOffset(0, 70), BackgroundColor3 = BG, BorderSizePixel = 0,
        ScrollBarThickness = 3, ScrollBarImageColor3 = SILVER, CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y })
    results.Parent = eggPage; corner(results, 9); stroke(results, 1, false)
    text(eggPage, { Size = UDim2.new(1, 0, 0, 16), Position = UDim2.fromOffset(0, 51),
        Font = Enum.Font.Gotham, TextSize = 10, TextColor3 = SILVER,
        TextXAlignment = Enum.TextXAlignment.Left, Text = "Reports under 5 min; availability unconfirmed." })
    make("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }).Parent = results
    make("UIPadding", { PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6),
        PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 5) }).Parent = results
    local empty = text(results, { Size = UDim2.new(1, -8, 0, 34), Font = Enum.Font.Gotham, TextSize = 12,
        TextWrapped = true, Text = "No recent reports." })
    local function pageButton(label, right)
        local button = make("TextButton", { Size = UDim2.fromOffset(70, 28),
            Position = right and UDim2.new(1, -70, 1, -28) or UDim2.new(0, 0, 1, -28),
            BackgroundColor3 = THEME.Surface, Font = Enum.Font.GothamBold, TextSize = 11,
            TextColor3 = WHITE, Text = label, AutoButtonColor = false })
        button.Parent = eggPage; corner(button, 6)
        return button
    end
    local previousButton, nextButton = pageButton("Previous", false), pageButton("Next", true)
    local pageLabel = text(eggPage, { Size = UDim2.new(1, -148, 0, 28), Position = UDim2.new(0, 74, 1, -28),
        Font = Enum.Font.Gotham, TextSize = 10, TextColor3 = SILVER, TextTruncate = Enum.TextTruncate.AtEnd, TextWrapped = false,
        Text = "0–0 / 0\nPage 1/1" })
    api.PreviousButton, api.NextButton, api.PageLabel = previousButton, nextButton, pageLabel
    api.Status, api.List, api.RefreshButton = feedback, results, refreshButton

    local function current()
        return alive and not api.Closed and gui.Parent ~= nil and eggPage.Parent ~= nil
    end
    local function say(message, ownsSummary)
        api.SummaryOwned = ownsSummary == true
        if current() and feedback.Text ~= message then feedback.Text = message end
    end
    local function summary()
        local since = math.max(0, math.floor(reportNow() - (api.LastSuccess or reportNow())))
        local checked = since == 0 and "Checked now" or ("Checked " .. tostring(since) .. "s ago")
        if #api.Entries == 0 and api.Stats and api.Stats.NewestTimestamp then
            local minutes = math.max(0, math.floor((reportNow() - api.Stats.NewestTimestamp) / 60))
            say("No fresh reports; newest " .. tostring(minutes) .. "m old\n" .. checked, true)
        else
            say(tostring(#api.Entries) .. " recent report(s)\n" .. checked, true)
        end
    end
    local function set(object, property, value)
        if object[property] ~= value then object[property] = value end
    end
    local function finite(value)
        if type(value) ~= "number" and type(value) ~= "string" then return nil end
        if type(value) == "string" then
            if #value > 128 then return nil end
            local s = value:match("^%s*(.-)%s*$")
            local mantissa, exponent = s:match("^([%+%-]?[%d%.]+)[eE]([%+%-]?%d+)$")
            mantissa = mantissa or s
            if not mantissa:match("^[%+%-]?%d+%.?%d*$")
                and not mantissa:match("^[%+%-]?%.%d+$") then return nil end
            -- Source earnings and model scale use decimal numbers, not
            -- hexadecimal or other nondecimal tonumber extensions.
        end
        local n = tonumber(value)
        return n and n == n and n >= 0 and n < math.huge and n or nil
    end
    local function pageState()
        api.PageCount = math.max(1, math.ceil(#api.Entries / api.PageSize))
        api.Page = math.clamp(api.Page, 1, api.PageCount)
        local first = #api.Entries == 0 and 0 or (api.Page - 1) * api.PageSize + 1
        local last = math.min(#api.Entries, api.Page * api.PageSize)
        set(pageLabel, "Text", tostring(first) .. "–" .. tostring(last) .. " / " .. tostring(#api.Entries)
            .. "\nPage " .. tostring(api.Page) .. "/" .. tostring(api.PageCount))
        local enabled = not state.Busy and not api.IsJoining
        for _, spec in ipairs({ { previousButton, api.Page > 1 }, { nextButton, api.Page < api.PageCount } }) do
            local can = enabled and spec[2]
            set(spec[1], "Active", can); set(spec[1], "AutoButtonColor", can)
            set(spec[1], "BackgroundColor3", can and THEME.Violet or THEME.Surface)
        end
    end
    local function selectPage()
        pageState()
        local wanted, changed = {}, false
        local first, last = (api.Page - 1) * api.PageSize + 1, math.min(#api.Entries, api.Page * api.PageSize)
        for index = first, last do
            local item = api.Entries[index]
            wanted[item.Key] = item
            if api.PageKeys[item.Key] ~= item then changed = true end
        end
        for key in pairs(api.PageKeys) do if not wanted[key] then changed = true end end
        api.PageKeys = wanted
        -- Retired cards are hidden immediately, before any yielding draw.
        -- Keep at most one page of card instances and rebind their callbacks.
        for key, row in pairs(api.Rows) do
            if not wanted[key] then
                api.Rows[key] = nil
                row.Frame.Visible = false
                if row.Link then row.Link:Disconnect(); row.Link = nil end
                row.BoundKey = nil
                api.Pool[#api.Pool + 1] = row
            end
        end
        set(empty, "Visible", #api.Entries == 0)
        if changed then api.NeedsDraw = true end
        return first, last
    end
    local indexedDirectory, nameIndex
    local function nameKey(value)
        return type(value) == "string" and value:lower():gsub("%s+", " "):match("^%s*(.-)%s*$") or nil
    end
    local function entryFor(egg)
        local directory = type(Assets) == "table" and Assets.Directory or nil
        if type(directory) ~= "table" then return nil end
        local entry = directory[tostring(egg.name or "")]
        if type(entry) == "table" then return entry end
        if indexedDirectory ~= directory then
            indexedDirectory, nameIndex = directory, {}
            for _, candidate in pairs(directory) do
                local key = type(candidate) == "table" and nameKey(candidate.DisplayName)
                if key and key ~= "" then
                    local previous = nameIndex[key]
                    if previous == nil or previous == candidate then nameIndex[key] = candidate
                    else nameIndex[key] = false end
                end
            end
        end
        local match = nameIndex[nameKey(egg.name)]
        return type(match) == "table" and match or nil
    end
    local function rate(egg)
        local reported = finite(egg.value)
        if reported then return reported, false end
        local entry = entryFor(egg)
        local base, scale = entry and finite(entry.EarningRate), finite(egg.scale)
        if not base or not scale or scale <= 0 then return nil, false end
        local factor = scale > 5 and (scale / 5) ^ 1.2 * 19.637875755794113 or scale ^ 1.85
        return finite(base * factor), true
    end
    api.Rate = rate
    local function requestFunction()
        local env = runtime.Env
        for _, key in ipairs({ "request", "http_request" }) do
            local candidate = type(env) == "table" and env[key]
            if type(candidate) == "function" then return candidate end
        end
        local ok, candidate = pcall(function() return request end)
        if ok and type(candidate) == "function" then return candidate end
        ok, candidate = pcall(function() return http_request end)
        if ok and type(candidate) == "function" then return candidate end
        for _, key in ipairs({ "syn", "http" }) do
            local group = type(env) == "table" and env[key]
            if type(group) == "table" and type(group.request) == "function" then return group.request end
        end
        ok, candidate = pcall(function() return syn and syn.request end)
        if ok and type(candidate) == "function" then return candidate end
        ok, candidate = pcall(function() return http and http.request end)
        if ok and type(candidate) == "function" then return candidate end
        return nil
    end
    local function available(item)
        return item and api.ByKey[item.Key] == item and api.PageKeys[item.Key] == item
            and item.Joinable and not item.InvalidPlace
            and not api.JoinNeedsRefresh and runtime.bigEggData.fresh(item, reportNow(), api.MaxAge)
    end
    local function buttonState(row)
        local item = api.ByKey[row.Item.Key] or row.Item
        local here = item.jobId == tostring(game.JobId) and (item.PlaceId or game.PlaceId) == game.PlaceId
        local canJoin = available(item) and not here and not api.IsJoining
        set(row.Join, "Active", canJoin)
        set(row.Join, "AutoButtonColor", canJoin)
        set(row.Join, "Text", here and "Here" or (pending and pending.Key == item.Key and "..."
            or (api.JoinNeedsRefresh and "Refresh" or (not available(item) and "N/A" or (api.IsJoining and "Wait" or "Join")))))
        set(row.Join, "BackgroundColor3", canJoin and THEME.Violet or THEME.Surface)
    end
    local function releaseJoin(token, message)
        if pending ~= token then return end
        pending, api.IsJoining = nil, false
        -- Keep failures visible briefly instead of immediately replacing them
        -- with the next background poll. Manual refresh remains available.
        api.NextRefreshAt = math.max(api.NextRefreshAt, os.clock() + 5)
        if token.Timer then runtime.cancel(token.Timer) end
        if not current() then return end
        for _, row in pairs(api.Rows) do buttonState(row) end
        pageState()
        if message then say(message) end
    end
    function api.Join(key)
        if not current() or not eggPage.Visible or api.IsJoining then return false end
        local row = api.Rows[key]
        -- A response can replace membership before its batched draw finishes.
        -- Resolve from that accepted response, never from a superseded card.
        local item = row and row.Frame.Visible and row.BoundKey == key and api.ByKey[key]
        if api.JoinNeedsRefresh then say("Refresh reports before retrying an unconfirmed join."); return false end
        if not available(item) then say("Report expired or has no valid server. Refresh first."); return false end
        local placeId = item.PlaceId or game.PlaceId
        if item.jobId == tostring(game.JobId) and placeId == game.PlaceId then return false end
        if state.Busy or state.Aborting or state.Carrying or viewState or performance.Restoring
            or (runtime.halloween and runtime.halloween.hasCarry()) then
            say("Finish the trip and release your egg before joining.")
            return false
        end
        -- This explicit Join owns the destination change; prevent an idle
        -- automatic steal from starting while Roblox handles the teleport.
        if runtime.autoSteal then runtime.autoSteal.setEnabled(false) end
        if runtime.halloween then runtime.halloween.setEnabled(false) end
        -- Retire any fetch/draw that began before this destination decision.
        -- It must stay retired even if the teleport fails before HTTP returns.
        refreshGeneration += 1
        if api.Refreshing then runtime.cancelRequest(httpKey, "Joining") end
        joinAttempts += 1
        local token = { Key = key, JobId = item.jobId, PlaceId = placeId,
            RequireServer = joinAttempts > 1 }
        pending, api.IsJoining = token, true
        for _, other in pairs(api.Rows) do buttonState(other) end
        pageState()
        say("Joining reported server...")
        token.Timer = runtime.delay(20, function()
            if pending ~= token then return end
            api.JoinNeedsRefresh = true
            releaseJoin(token, "Join not confirmed. Refresh before retrying.")
        end)
        local ok, err = pcall(teleportService.TeleportToPlaceInstance, teleportService, placeId, item.jobId, localPlayer)
        if not ok then releaseJoin(token, "Join failed: " .. string.sub(tostring(err), 1, 70)) end
        return ok and pending == token
    end
    pcall(function()
        runtime.connect(teleportService.TeleportInitFailed, function(player, result, message, placeId, options)
            local token = pending
            if not token or player ~= localPlayer or placeId ~= token.PlaceId then return end
            local ok, server = pcall(function() return options and options.ServerInstanceId end)
            if not ok or type(server) ~= "string" or server == "" then
                -- Older failures may arrive after a retry. Without a destination
                -- they cannot identify the current attempt; its timer still owns it.
                if token.RequireServer then return end
            elseif server ~= token.JobId then return end
            releaseJoin(token, "Join failed: " .. string.sub(tostring(message or result), 1, 70))
        end)
    end)
    local function createRow(item)
        local card = make("Frame", { Name = "BigEggReport", Size = UDim2.new(1, -10, 0, 104),
            BackgroundColor3 = THEME.Surface, BorderSizePixel = 0 })
        card.Parent = results; corner(card, 8)
        local row = { Frame = card, Stroke = stroke(card, 1, false), Item = item }
        row.Icon = make("ImageLabel", { Size = UDim2.fromOffset(32, 32), Position = UDim2.fromOffset(6, 5),
            BackgroundTransparency = 1, Image = "", ScaleType = Enum.ScaleType.Fit })
        row.Icon.Parent = card
        local function label(y, height, inset, reserve, size)
            return text(card, { Size = UDim2.new(1, -reserve, 0, height), Position = UDim2.fromOffset(inset, y),
                Font = Enum.Font.Gotham, TextSize = size, TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd, Text = "" })
        end
        row.Name = label(4, 17, 44, 122, 12); row.Name.Font = Enum.Font.GothamBold
        row.Weight = label(22, 18, 44, 122, 14); row.Weight.Font = Enum.Font.GothamBold
        row.Rate = label(43, 17, 8, 16, 11)
        row.Details = label(63, 15, 8, 16, 10)
        row.Age = label(82, 15, 8, 16, 10)
        row.Join = make("TextButton", { Size = UDim2.fromOffset(62, 28), Position = UDim2.new(1, -68, 0, 6),
            BackgroundColor3 = THEME.Violet, Font = Enum.Font.GothamBold, TextSize = 11,
            TextColor3 = WHITE, Text = "Join", AutoButtonColor = true })
        row.Join.Parent = card; corner(row.Join, 6)
        return row
    end
    local function draw(entries, generation)
        if not current() then return false end
        local token = {}
        activeDraw, api.Drawing, api.NeedsDraw = token, true, true
        local complete = false
        local function owns()
            return current() and activeDraw == token and not api.IsJoining and not state.Busy
                and generation == refreshGeneration and entries == api.Entries
        end
        local ok, failure = pcall(function()
            if not owns() then return end
            local first, last = selectPage()
            for index = first, last do
                if not owns() then return end
                local item = entries[index]
                local row = api.Rows[item.Key]
                if not row then
                    row = table.remove(api.Pool) or createRow(item)
                    api.Rows[item.Key] = row
                end
                row.Item = item
                if row.BoundKey ~= item.Key then
                    if row.Link then row.Link:Disconnect() end
                    local key = item.Key
                    row.BoundKey = key
                    row.Link = row.Join.Activated:Connect(function()
                        if api.Rows[key] == row and row.BoundKey == key then runtime.dispatch(api.Join, key) end
                    end)
                end
                set(row.Frame, "Visible", true)
                local egg = item.egg
                local big = item.Weight and item.Weight >= 10000000
                set(row.Frame, "LayoutOrder", index)
                set(row.Frame, "BackgroundColor3", big and Color3.fromRGB(44, 34, 13) or THEME.Surface)
                set(row.Stroke, "Color", big and Color3.fromRGB(255, 200, 70) or STEEL)
                set(row.Stroke, "Thickness", big and 1.4 or 1)
                set(row.Name, "Text", tostring(egg.name or "Unnamed egg"))
                set(row.Weight, "Text", item.WeightText)
                local amount, estimated = rate(egg)
                set(row.Rate, "Text", amount and ((estimated and "Estimate: ~" or "Reported: ") .. money(amount)) or "Earnings unknown")
                local entry = entryFor(egg)
                local icon = entry and entry.Icon
                icon = icon ~= nil and tostring(icon) or ""
                if tonumber(icon) then icon = "rbxassetid://" .. icon end
                set(row.Icon, "Image", icon)
                local players = item.serverPlayers ~= nil and tostring(item.serverPlayers) or "?"
                set(row.Details, "Text", tostring(egg.rarity or "?") .. " | " .. tostring(egg.area or "?") .. " | " .. players .. " players")
                set(row.Age, "Text", "Reported " .. tostring(math.max(0, math.floor(reportNow() - item.timestamp))) .. "s ago | availability unconfirmed")
                buttonState(row)
                if (index - first + 1) % 20 == 0 then task.wait() end
            end
            if not owns() then return end
            complete = true
        end)
        -- A retired drawing task cannot clear a newer page's ownership.
        if activeDraw == token then
            activeDraw, api.Drawing, api.NeedsDraw = nil, false, not complete
        end
        if not ok then error(failure) end
        return complete
    end
    function api.SetPage(page)
        if not current() or not eggPage.Visible or state.Busy or api.IsJoining then return false end
        page = finite(page)
        if not page or page % 1 ~= 0 then return false end
        api.Prune(true)
        page = math.clamp(page, 1, api.PageCount)
        if page == api.Page and not api.NeedsDraw then return true end
        api.Page = page
        set(results, "CanvasPosition", Vector2.new(0, 0))
        return draw(api.Entries, refreshGeneration)
    end
    function api.Prune(noDraw)
        if not current() or api.Drawing then return end
        local kept, now = {}, reportNow()
        for _, item in ipairs(api.Entries) do
            if runtime.bigEggData.fresh(item, now, api.MaxAge) then kept[#kept+1] = item end
        end
        -- Preserve identity while membership is unchanged so an unrelated
        -- HTTP/page task is not retired by the one-second age update.
        if #kept ~= #api.Entries then
            api.Entries = kept
            local byKey = {}
            for _, item in ipairs(kept) do byKey[item.Key] = item end
            api.ByKey = byKey
        end
        selectPage()
        for _, row in pairs(api.Rows) do
            local item = api.ByKey[row.Item.Key]
            set(row.Age, "Text", "Reported " .. tostring(math.max(0, math.floor(now - item.timestamp))) .. "s ago | availability unconfirmed")
            buttonState(row)
        end
        if api.NeedsDraw and not noDraw and not state.Busy and not api.IsJoining then
            draw(api.Entries, refreshGeneration)
        end
        if api.SummaryOwned and not api.Refreshing and not api.IsJoining then summary() end
        for key, lastSeen in pairs(notified) do if now - lastSeen > api.MaxAge then notified[key] = nil end end
    end
    local function notify(entries)
        local best, count, now = nil, 0, reportNow()
        for _, item in ipairs(entries) do
            if item.Weight and item.Weight >= 10000000 and runtime.bigEggData.fresh(item, now, api.MaxAge) then
                if not notified[item.Key] then
                    count += 1
                    if not best or item.Weight > best.Weight then best = item end
                end
                -- Last-seen extends suppression for repeated updates of one egg.
                notified[item.Key] = now
            end
        end
        if best then
            pcall(function() game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Big Egg report", Text = tostring(best.egg.name or "Egg") .. " | " .. best.WeightText
                    .. (count > 1 and (" (+" .. tostring(count-1) .. " more)") or ""), Duration = 8,
            }) end)
        end
    end
    function api.Refresh(force)
        if not current() or api.Refreshing or api.IsJoining or state.Busy then return false end
        if not force and (state.Busy or os.clock() < api.NextRefreshAt) then return false end
        api.Prune(true)
        local generation, deferred = refreshGeneration, false
        api.Refreshing = true
        set(refreshButton, "Text", "...")
        local ok, failure = pcall(function()
            local requestFn = requestFunction()
            if not requestFn then return "Executor has no request()" end
            say("Fetching reports...")
            local requested, response = runtime.call(httpKey, 12, function()
                return requestFn({ Url = api.Source, Method = "GET", Headers = { ["Cache-Control"] = "no-cache" } })
            end)
            if not current() or api.IsJoining or generation ~= refreshGeneration then return end
            if state.Busy then deferred = true; return end
            if not requested then return response == "Request timed out" and "Source timed out" or "Source request failed" end
            local body
            if type(response) == "string" then body = response
            elseif type(response) == "table" then
                local code = response.StatusCode
                if code == nil then code = response.Status end
                if code == nil then code = response.status_code end
                if response.Success == false then return "Source request failed" end
                if code ~= nil then
                    code = finite(code)
                    if not code or code % 1 ~= 0 or code < 200 or code >= 300 then return "Source HTTP error" end
                end
                body = response.Body or response.body
            end
            if type(body) ~= "string" or body == "" or #body > 2097152 then return "Invalid source response" end
            local decoded, result = pcall(httpService.JSONDecode, httpService, body)
            if not decoded then return "Unreadable source response" end
            local entries, reason, stats = runtime.bigEggData.normalize(result, reportNow(), api.MaxAge)
            if not entries then return reason or "Unrecognized source format" end
            if not current() then return end
            api.Entries, api.LastSuccess, api.Stats = entries, reportNow(), stats
            local byKey = {}
            for _, item in ipairs(entries) do byKey[item.Key] = item end
            api.ByKey, api.JoinNeedsRefresh = byKey, false
            indexedDirectory = nil -- one conservative display-name index per accepted response
            draw(entries, generation)
            if not current() or api.IsJoining or generation ~= refreshGeneration then return end
            if state.Busy then deferred = true; return end
            api.Prune(true)
            notify(api.Entries)
            summary()
        end)
        api.Refreshing = false
        if not current() then return false end
        set(refreshButton, "Text", "Refresh")
        if api.IsJoining or generation ~= refreshGeneration then
            api.Prune(true)
            return false
        end
        if deferred then
            api.NextRefreshAt = os.clock() + 5
            api.Prune(true)
            say("Refresh paused during trip; cached reports age out")
            return false
        end
        if not ok or failure then
            api.Failures += 1
            api.NextRefreshAt = os.clock() + math.min(30, 5 * 2 ^ math.min(api.Failures - 1, 3))
            api.Prune(true)
            if not ok then slog("Big Egg finder: " .. tostring(failure)) end
            say((ok and failure or "Refresh failed") .. "; cached reports age out")
            return false
        end
        api.Failures, api.NextRefreshAt = 0, os.clock() + 5
        return true
    end
    function api.Tick()
        if not current() then return end
        api.IsOpen = eggPage.Visible
        api.Prune()
        if not api.Refreshing and not api.IsJoining and not state.Busy and os.clock() >= api.NextRefreshAt then
            runtime.spawn(api.Refresh, false)
        end
    end
    function api.Close()
        if api.Closed then return end
        api.Closed, api.IsOpen = true, false
        activeDraw, api.Drawing = nil, false
        refreshGeneration += 1
        local token = pending
        if token then releaseJoin(token) end
        runtime.cancelRequest(httpKey, "Closed")
        api.Refreshing = false
    end
    runtime.connect(refreshButton.Activated, function() runtime.spawn(api.Refresh, true) end)
    runtime.connect(previousButton.Activated, function() api.SetPage(api.Page - 1) end)
    runtime.connect(nextButton.Activated, function() api.SetPage(api.Page + 1) end)
    pageState()
    return api
end)()
local function refreshBigEggs() return runtime.bigEggFinder.Refresh(true) end

-- Halloween controls are scoped independently from the normal egg filters.
do
    local ui = { Open = false, IsOpen = false, NameRows = {}, RarityRows = {}, MobNameRows = {}, MobRarityRows = {}, Section = "Eggs", NextCatalog = 0, Syncing = false }
    runtime.halloweenUi = ui
    local page = make("Frame", { Name = "HalloweenPage", Size = body.Size, Position = body.Position,
        BackgroundTransparency = 1, Visible = false })
    page.Parent = window; ui.Page = page
    local headerButtonHw = headerButton("Halloween", -184)
    headerButtonHw.Size = UDim2.fromOffset(78, 28); headerButtonHw.TextSize = 10
    ui.HeaderButton = headerButtonHw
    local function button(parent, label, size, position)
        local node = make("TextButton", { Size = size or UDim2.new(1, -8, 0, 32), Position = position or UDim2.new(),
            BackgroundColor3 = THEME.Surface, BorderSizePixel = 0, Font = Enum.Font.GothamBold,
            TextSize = 11, TextColor3 = WHITE, Text = label, TextTruncate = Enum.TextTruncate.AtEnd,
            AutoButtonColor = true })
        node.Parent = parent; corner(node, 7)
        return node
    end
    ui.MasterButton = button(page, "Auto Halloween: OFF", UDim2.new(1, 0, 0, 32))
    ui.StatusLabel = runtime.guiLayout.makeStatus(page, UDim2.new(1, -8, 0, 38), UDim2.fromOffset(4, 35), nil, 11)
    ui.StatusLabel.Text = "Halloween: ready"
    ui.CountsLabel = text(page, { Size = UDim2.new(1, -8, 0, 20), Position = UDim2.fromOffset(4, 76),
        Text = "Delivered 0 | Failed 0 | Candy 0", Font = Enum.Font.Gotham, TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd })
    ui.StopButton = button(page, "Stop", UDim2.new(.5, -3, 0, 32), UDim2.fromOffset(0, 100))
    ui.HomeButton = button(page, "Return home", UDim2.new(.5, -3, 0, 32), UDim2.new(.5, 3, 0, 100))
    ui.SectionButtons = {}
    local navigation = make("Frame", { Name = "HalloweenSections", Size = UDim2.new(1, 0, 0, 28),
        Position = UDim2.fromOffset(0, 140), BackgroundTransparency = 1 })
    navigation.Parent = page; ui.Navigation = navigation
    for index, name in ipairs({ "Eggs", "Mobs", "Events" }) do
        local node = button(navigation, name, UDim2.new(1/3, -4, 1, 0), UDim2.new((index-1)/3, 2, 0, 0))
        ui.SectionButtons[name] = node
    end
    local choices = make("ScrollingFrame", { Name = "HalloweenChoices", Size = UDim2.new(1, 0, 1, -174),
        Position = UDim2.fromOffset(0, 174), BackgroundColor3 = BG, BorderSizePixel = 0,
        ScrollBarThickness = 4, ScrollBarImageColor3 = SILVER, CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y })
    choices.Parent = page; ui.Choices = choices
    make("UIListLayout", { Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder }).Parent = choices
    make("UIPadding", { PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4) }).Parent = choices
    ui.StealEggsButton = button(choices, "Steal eggs: ON"); ui.StealEggsButton.LayoutOrder = 1
    ui.ZonePriorityButton = button(choices, "High zone first: ON"); ui.ZonePriorityButton.LayoutOrder = 2
    ui.Help = text(choices, { Size = UDim2.new(1, -8, 0, 52), LayoutOrder = 5,
        Font = Enum.Font.Gotham, TextSize = 10, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left,
        Text = "Eggs must match both filters. No selections means all.\nNormal stealing pauses while Auto Halloween is ON." })
    ui.FeatureButtons = {}
    local featureSpecs = {
        { Key = "AutoBuy", Label = "Auto buy (2,250 Candy Corn)", Section = "Eggs", Order = 3 },
        { Key = "CrossWorld", Label = "Cross-world priority", Section = "Eggs", Order = 4 },
        { Key = "HitMobs", Label = "Hit mobs (bat required)", Section = "Mobs", Order = 1 },
        { Key = "CollectPumpkins", Label = "Collect pumpkins", Section = "Events", Order = 1 },
        { Key = "AutoFish", Label = "Auto fish (Haunted Rod)", Section = "Events", Order = 3 },
        { Key = "PhantomExpress", Label = "Phantom Express", Section = "Events", Order = 5 },
        { Key = "TradeSouls", Label = "Trade Souls for Spectral", Section = "Events", Order = 7 },
    }
    ui.FeatureSpecs = featureSpecs
    for _, spec in ipairs(featureSpecs) do
        local node = button(choices, spec.Label .. ": OFF")
        node.LayoutOrder = spec.Order
        ui.FeatureButtons[spec.Key] = node
    end
    local function help(label, order, height)
        return text(choices, { Size = UDim2.new(1, -8, 0, height or 30), LayoutOrder = order,
            Font = Enum.Font.Gotham, TextSize = 10, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left,
            Text = label })
    end
    ui.CrossWorldHelp = help("Uses normal Auto steal and its rarity filter; choose specific tiers.", 6, 30)
    ui.MobHelp = help("A bat is required. Mob filters are separate from egg filters. No selections means all.", 2, 38)
    ui.PumpkinHelp = help("Collects and banks pumpkins while Pumpkin Moon is active.", 2)
    ui.FishHelp = help("Requires a Haunted Rod from Gilbert's quest inside Halloween.", 4)
    ui.TrainHelp = help("Requires a Train Pass or server-unlocked train access.", 6)
    ui.SoulCostLabel = help("Soul trade cost: current game price (not loaded).", 8, 30)
    ui.TradeHelp = help("Opt-in spending: each trade spends Souls at the current game cost. Stop disables farming.", 9, 38)
    ui.FeatureCountsLabel = help("Bought 0 | Mobs 0 | Pumpkins 0\nFish 0 | Ghosts 0 | Spectral 0", 0, 36)
    local function section(label)
        local row = make("Frame", { Size = UDim2.new(1, -8, 0, 28), BackgroundTransparency = 1 })
        row.Parent = choices
        local title = text(row, { Size = UDim2.new(1, -84, 1, 0), Font = Enum.Font.GothamBold, TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Text = label })
        local all = button(row, "All", UDim2.fromOffset(76, 28), UDim2.new(1, -76, 0, 0))
        return row, title, all
    end
    local namesHeader, namesTitle, allNames = section("Egg names: All")
    local raritiesHeader, raritiesTitle, allRarities = section("Rarities: All")
    ui.AllNamesButton, ui.AllRaritiesButton = allNames, allRarities
    local mobNamesHeader, mobNamesTitle, allMobNames = section("Mob names: All")
    local mobRaritiesHeader, mobRaritiesTitle, allMobRarities = section("Mob rarities: All")
    ui.AllMobNamesButton, ui.AllMobRaritiesButton = allMobNames, allMobRarities
    local mobEmpty = help("Waiting for Halloween mob data.", 100, 30)
    ui.MobEmptyLabel = mobEmpty
    local empty = text(choices, { Size = UDim2.new(1, -8, 0, 30), Font = Enum.Font.Gotham, TextSize = 11,
        TextWrapped = true, Text = "Waiting for Halloween egg data." })
    ui.EmptyLabel = empty
    local function current()
        return alive and gui.Parent ~= nil and page.Parent ~= nil
    end
    local function visible()
        return current() and ui.Open and page.Visible and not minimized
    end
    local function copySet(input)
        local result = {}
        for key, selected in pairs(type(input) == "table" and input or {}) do
            if type(key) == "string" and selected == true then result[key] = true end
        end
        return result
    end
    local function count(input)
        local result = 0; for _, selected in pairs(input or {}) do if selected == true then result += 1 end end
        return result
    end
    local function set(node, key, value)
        if node[key] ~= value then node[key] = value end
    end
    ui.SectionNodes = {
        Eggs = { ui.StealEggsButton, ui.ZonePriorityButton, ui.Help, ui.CrossWorldHelp,
            namesHeader, raritiesHeader, empty, ui.FeatureButtons.AutoBuy, ui.FeatureButtons.CrossWorld },
        Mobs = { ui.MobHelp, mobNamesHeader, mobRaritiesHeader, mobEmpty, ui.FeatureButtons.HitMobs },
        Events = { ui.FeatureButtons.CollectPumpkins, ui.PumpkinHelp, ui.FeatureButtons.AutoFish, ui.FishHelp,
            ui.FeatureButtons.PhantomExpress, ui.TrainHelp, ui.FeatureButtons.TradeSouls, ui.SoulCostLabel, ui.TradeHelp },
    }
    local function syncSections()
        for name, nodes in pairs(ui.SectionNodes) do
            for _, node in ipairs(nodes) do
                if node ~= empty and node ~= mobEmpty then set(node, "Visible", ui.Section == name) end
            end
            set(ui.SectionButtons[name], "BackgroundColor3", ui.Section == name and THEME.Violet or THEME.Surface)
        end
        if ui.Section ~= "Eggs" then empty.Visible = false end
        if ui.Section ~= "Mobs" then mobEmpty.Visible = false end
        for _, group in ipairs({ { ui.NameRows, "Eggs" }, { ui.RarityRows, "Eggs" },
            { ui.MobNameRows, "Mobs" }, { ui.MobRarityRows, "Mobs" } }) do
            for _, node in pairs(group[1]) do set(node, "Visible", ui.Section == group[2]) end
        end
    end
    function ui.setSection(name)
        if not visible() or not ui.SectionButtons[name] then return false end
        ui.Section = name
        choices.CanvasPosition = Vector2.new(0, 0)
        ui.NextCatalog = 0
        ui.sync(true)
        return true
    end
    local function action(callback, allowActive, section)
        local controller = runtime.halloween
        if not visible() or not controller or (section and ui.Section ~= section) then return false end
        if not allowActive and (controller.Active or state.Busy or state.Aborting) then return false end
        ui.Message = nil
        local ok, result = pcall(callback, controller)
        if not ok then ui.Message = "Halloween control unavailable; try again"; slog("Halloween UI: " .. tostring(result)) end
        ui.NextCatalog = 0; ui.sync()
        return ok and result ~= false
    end
    local function changeFilters(group, key)
        return action(function(controller)
            local mobs = group == "mobNames" or group == "mobRarities"
            local names = copySet(mobs and controller.MobNames or controller.Names)
            local rarities = copySet(mobs and controller.MobRarities or controller.Rarities)
            local selected = (group == "names" or group == "mobNames") and names or rarities
            if key then selected[key] = selected[key] ~= true or nil
            else table.clear(selected) end
            if mobs then return controller.setMobFilters(names, rarities) end
            return controller.setFilters(names, rarities)
        end, false, (group == "mobNames" or group == "mobRarities") and "Mobs" or "Eggs")
    end
    local function groupRows(rows, values, selected, group, order)
        local known, union, keys = {}, {}, {}
        for _, key in ipairs(type(values) == "table" and values or {}) do
            if type(key) == "string" and key ~= "" then known[key], union[key] = true, true end
        end
        for key in pairs(copySet(selected)) do union[key] = true end
        for key in pairs(union) do keys[#keys + 1] = key end
        table.sort(keys)
        for index, key in ipairs(keys) do
            local node = rows[key]
            if not node then
                node = button(choices, "")
                rows[key] = node
                node.Activated:Connect(function()
                    if rows[key] == node then changeFilters(group, key) end
                end)
            end
            set(node, "LayoutOrder", order + index)
            set(node, "Visible", ui.Section == ((group == "mobNames" or group == "mobRarities") and "Mobs" or "Eggs"))
            local chosen = type(selected) == "table" and selected[key] == true
            set(node, "Text", (chosen and "[x] " or "[ ] ") .. key .. (known[key] and "" or " (unavailable)"))
            set(node, "BackgroundColor3", chosen and THEME.VioletDark or THEME.Surface)
            local editable = not runtime.halloween.Active and not state.Busy and not state.Aborting
            set(node, "Active", editable); set(node, "AutoButtonColor", editable)
        end
        for key, node in pairs(rows) do
            if not union[key] then rows[key] = nil; node:Destroy() end
        end
        return order + #keys, #keys
    end
    function ui.sync(force)
        if not current() or ui.Syncing then return end
        ui.Syncing = true
        local ok, failure = pcall(function()
            local controller = runtime.halloween
            if not controller then ui.StatusLabel.Text = "Halloween controls unavailable"; return end
            set(ui.MasterButton, "Text", "Auto Halloween: " .. (controller.Enabled and "ON" or "OFF"))
            set(ui.MasterButton, "BackgroundColor3", controller.Enabled and THEME.Violet or THEME.Surface)
            set(ui.StealEggsButton, "Text", "Steal eggs: " .. (controller.StealEggs and "ON" or "OFF"))
            set(ui.ZonePriorityButton, "Text", "High zone first: " .. (controller.ZonePriority and "ON" or "OFF"))
            set(ui.StatusLabel, "Text", tostring(ui.Message or controller.Status or "Halloween: ready"))
            local stats = controller.Stats or {}
            set(ui.CountsLabel, "Text", "Delivered " .. tostring(stats.Delivered or 0) .. " | Failed " .. tostring(stats.Failed or 0)
                .. " | Candy " .. tostring(stats.Candy or 0))
            set(ui.FeatureCountsLabel, "Text", "Bought " .. tostring(stats.Bought or 0) .. " | Mobs " .. tostring(stats.Killed or 0)
                .. " | Pumpkins " .. tostring(stats.Pumpkins or 0) .. "\nFish " .. tostring(stats.Fished or 0)
                .. " | Ghosts " .. tostring(stats.Captured or 0) .. " | Spectral " .. tostring(stats.Spectral or 0))
            local cost, souls = stats.SoulCost, stats.Souls
            local knownCost = type(cost) == "number" and cost == cost and cost > 0 and cost < math.huge
            local costText = knownCost and ("Soul trade cost: " .. tostring(cost) .. " Souls per trade") or "Soul trade cost: current game price (not loaded)."
            if type(souls) == "number" and souls == souls and souls >= 0 and souls < math.huge then costText ..= " | Have " .. tostring(souls) end
            set(ui.SoulCostLabel, "Text", costText)
            local editable = not controller.Active and not state.Busy and not state.Aborting
            for _, spec in ipairs(featureSpecs) do
                local node = ui.FeatureButtons[spec.Key]
                set(node, "Text", spec.Label .. ": " .. (controller[spec.Key] and "ON" or "OFF"))
                set(node, "BackgroundColor3", controller[spec.Key] and THEME.VioletDark or THEME.Surface)
                set(node, "Active", editable); set(node, "AutoButtonColor", editable)
            end
            syncSections()
            for _, node in ipairs({ ui.StealEggsButton, ui.ZonePriorityButton, allNames, allRarities, allMobNames, allMobRarities }) do
                set(node, "Active", editable); set(node, "AutoButtonColor", editable)
            end
            if not ui.IsOpen then return end
            if not force and os.clock() < ui.NextCatalog then return end
            ui.NextCatalog = os.clock() + 2
            local mobSection = ui.Section == "Mobs"
            if ui.Section == "Events" then return end
            local names, rarities
            if mobSection then names, rarities = controller.mobCatalog()
            else names, rarities = controller.catalog() end
            local nameRows = mobSection and ui.MobNameRows or ui.NameRows
            local rarityRows = mobSection and ui.MobRarityRows or ui.RarityRows
            local selectedNamesSet = mobSection and controller.MobNames or controller.Names
            local selectedRaritySet = mobSection and controller.MobRarities or controller.Rarities
            local firstHeader = mobSection and mobNamesHeader or namesHeader
            local secondHeader = mobSection and mobRaritiesHeader or raritiesHeader
            local firstTitle = mobSection and mobNamesTitle or namesTitle
            local secondTitle = mobSection and mobRaritiesTitle or raritiesTitle
            local emptyNode = mobSection and mobEmpty or empty
            local firstOrder = mobSection and 3 or 7
            firstHeader.LayoutOrder = firstOrder
            local order, nameCount = groupRows(nameRows, names, selectedNamesSet, mobSection and "mobNames" or "names", firstOrder)
            secondHeader.LayoutOrder = order + 1
            local last, rarityCount = groupRows(rarityRows, rarities, selectedRaritySet, mobSection and "mobRarities" or "rarities", order + 1)
            emptyNode.LayoutOrder = last + 1; emptyNode.Visible = nameCount == 0 and rarityCount == 0
            local selectedNames, selectedRarities = count(selectedNamesSet), count(selectedRaritySet)
            firstTitle.Text = (mobSection and "Mob names: " or "Egg names: ") .. (selectedNames == 0 and "All" or tostring(selectedNames) .. " selected")
            secondTitle.Text = (mobSection and "Mob rarities: " or "Rarities: ") .. (selectedRarities == 0 and "All" or tostring(selectedRarities) .. " selected")
            syncSections()
        end)
        ui.Syncing = false
        if not ok then
            ui.NextCatalog = os.clock() + 2
            ui.StatusLabel.Text = "Halloween controls unavailable; try again"
            slog("Halloween UI: " .. tostring(failure))
        end
    end
    function ui.setOpen(open)
        if not current() then return false end
        open = open == true
        local controller = runtime.halloween
        if open and ((runtime.bigEggFinder and runtime.bigEggFinder.IsJoining)
            or ((state.Busy or state.Aborting) and not (controller and controller.Active))) then
            status("Halloween: finish the current trip before opening")
            return false
        end
        if runtime.filterUi and runtime.filterUi.Panel.Visible then runtime.filterUi.setOpen(false) end
        ui.Open, showingEggPage = open, false
        page.Visible = open and not minimized
        ui.IsOpen = page.Visible
        body.Visible = not open and not minimized
        eggPage.Visible = false
        runtime.bigEggFinder.IsOpen = false
        headerButtonHw.Text = open and "Back" or "Halloween"
        headerTitle.Text = open and "S2r Hub | Halloween" or "S2r Hub | Steal"
        pageButton.Text = "Eggs"
        if open then ui.NextCatalog = 0; ui.sync(true) end
        return true
    end
    runtime.connect(headerButtonHw.Activated, function() ui.setOpen(not ui.Open) end)
    runtime.connect(ui.MasterButton.Activated, function()
        local controller = runtime.halloween
        action(function(value) return value.setEnabled(not value.Enabled) end, controller and controller.Enabled == true)
    end)
    runtime.connect(ui.StealEggsButton.Activated, function()
        action(function(controller) return controller.setStealEggs(not controller.StealEggs) end, false, "Eggs")
    end)
    runtime.connect(ui.ZonePriorityButton.Activated, function()
        action(function(controller) return controller.setZonePriority(not controller.ZonePriority) end, false, "Eggs")
    end)
    runtime.connect(ui.StopButton.Activated, function() action(function(controller) return controller.cancel("Stopped by user") end, true) end)
    runtime.connect(ui.HomeButton.Activated, function() action(function(controller) return controller.returnHome() end, true) end)
    runtime.connect(allNames.Activated, function() changeFilters("names") end)
    runtime.connect(allRarities.Activated, function() changeFilters("rarities") end)
    runtime.connect(allMobNames.Activated, function() changeFilters("mobNames") end)
    runtime.connect(allMobRarities.Activated, function() changeFilters("mobRarities") end)
    for name, node in pairs(ui.SectionButtons) do
        runtime.connect(node.Activated, function() ui.setSection(name) end)
    end
    for _, spec in ipairs(featureSpecs) do
        runtime.connect(ui.FeatureButtons[spec.Key].Activated, function()
            action(function(controller) return controller.setFeature(spec.Key, not controller[spec.Key]) end, false, spec.Section)
        end)
    end
    ui.sync()
end

local function setMainPage(showEggs)
    showEggs = showEggs == true
    if showEggs and state.Busy then
        status("Finish the current trip before opening Big Egg Finder")
        return false
    end
    if runtime.filterUi and runtime.filterUi.Panel.Visible then
        runtime.filterUi.setOpen(false)
    end
    if runtime.halloweenUi then runtime.halloweenUi.setOpen(false) end
    showingEggPage = showEggs
    body.Visible = not minimized and not showingEggPage
    eggPage.Visible = not minimized and showingEggPage
    runtime.bigEggFinder.IsOpen = eggPage.Visible
    headerTitle.Text = showingEggPage and "S2r Hub | Big Eggs" or "S2r Hub | Steal"
    pageButton.Text = showingEggPage and "Back" or "Eggs"
    if showingEggPage then runtime.spawn(refreshBigEggs) end
    return true
end

runtime.connect(pageButton.Activated, function()
    setMainPage(not showingEggPage)
end)

runtime.spawn(function()
    task.wait(3)
    while alive and gui.Parent do
        runtime.bigEggFinder.Tick()
        task.wait(1)
    end
end)

runtime.Env.YslemUnfreeze = function()
    if not alive then return end
    releaseView()
    semi.Kind, semi.Home = nil, nil
end

runtime.connect(stealButton.Activated, function()
    if not alive or not gui.Parent or not body.Visible then return end
    if runtime.halloween and runtime.halloween.Active then
        runtime.autoSteal.setEnabled(false)
        runtime.filterUi.sync()
        runtime.halloween.cancel("Stopped by user")
        return
    end
    if not state.Busy and runtime.filterUi.Panel.Visible then status("Close the filter with Done"); return end
    if state.Busy then
        runtime.autoSteal.setEnabled(false)
        runtime.filterUi.sync()
        state.Cancel = true
        state.CancelAt = state.CancelAt or os.clock()
        status("Cancelling")
        return
    end
    if not selectedUid then
        status("Pick a pet")
        return
    end
    local row = rows[selectedUid]
    if not row or not list.Visible or not runtime.rarityFilter.matches(row.Record) then
        setSelected(nil)
        runtime.filterUi.Requested = true
        status("Selected egg does not match filter")
        return
    end
    runtime.autoSteal.startManual(selectedUid)
end)

runtime.spawn(function()
    while alive and gui.Parent do
        task.wait(0.25)
        if not alive or not gui.Parent then break end
        if showingEggPage and state.Busy then setMainPage(false) end
        runtime.filterUi.sync()
        if runtime.halloweenUi then runtime.halloweenUi.sync() end
        if runtime.filterUi.Requested and runtime.listRefreshAllowed() and not rebuilding then
            runtime.filterUi.Requested = false
            runtime.spawn(rebuild, false)
        end
        local st = state.Busy and "Cancel" or "Steal"
        if stealButton.Text ~= st then stealButton.Text = st end
        local rt = (viewState and viewState.Forced) and "Unfreeze" or "Refresh"
        if refreshButton.Text ~= rt then refreshButton.Text = rt end
    end
end)

-- One gesture owner prevents a second finger from taking over a drag or resize.
do
    local layout = runtime.guiLayout
    local footer = make("Frame", { Name = "WindowSizeControls", Size = UDim2.new(1, -10, 0, 28),
        Position = UDim2.new(0, 5, 1, -33), BackgroundTransparency = 1, ZIndex = 30 })
    footer.Parent = window
    layout.Footer = footer
    local reset = make("TextButton", { Name = "ResetWindowSize", Size = UDim2.fromOffset(88, 26),
        BackgroundColor3 = THEME.Surface, BorderSizePixel = 0, Font = Enum.Font.GothamBold,
        TextSize = 11, TextColor3 = WHITE, Text = "Reset size", AutoButtonColor = true, ZIndex = 31 })
    reset.Parent = footer
    corner(reset, 6)
    layout.ResetButton = reset
    text(footer, { Size = UDim2.new(1, -132, 1, 0), Position = UDim2.fromOffset(94, 0),
        Font = Enum.Font.Gotham, TextSize = 10, TextColor3 = SILVER,
        Text = "Drag header · resize corner", TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 31 })
    local grip = make("TextButton", { Name = "ResizeWindow", Size = UDim2.fromOffset(32, 28),
        Position = UDim2.new(1, -32, 0, 0), BackgroundColor3 = THEME.Violet,
        BorderSizePixel = 0, Font = Enum.Font.GothamBold, TextSize = 19, TextColor3 = WHITE,
        Text = "↘", Active = true, AutoButtonColor = true, ZIndex = 31 })
    grip.Parent = footer
    corner(grip, 6)
    layout.ResizeHandle = grip
    runtime.connect(reset.Activated, function() if not layout.Minimized then layout.resetSize() end end)
    runtime.connect(grip.InputBegan, function(input) layout.begin("resize", input) end)
    runtime.connect(header.InputBegan, function(input)
        if input.Position.X >= header.AbsolutePosition.X + header.AbsoluteSize.X - 188 * layout.Scale.Scale then return end
        layout.begin("drag", input)
    end)
    runtime.connect(UserInputService.InputChanged, layout.move)
    runtime.connect(UserInputService.InputEnded, layout.finish)
    pcall(function() runtime.connect(UserInputService.WindowFocusReleased, layout.cancelGesture) end)
    layout.render()
end

runtime.connect(minimize.Activated, function()
    minimized = not minimized
    runtime.filterUi.Minimized = minimized
    runtime.filterUi.setOpen(false)
    local halloweenOpen = runtime.halloweenUi and runtime.halloweenUi.Open
    body.Visible = not minimized and not showingEggPage and not halloweenOpen
    eggPage.Visible = not minimized and showingEggPage and not halloweenOpen
    runtime.bigEggFinder.IsOpen = eggPage.Visible
    if runtime.halloweenUi then
        runtime.halloweenUi.Page.Visible = not minimized and halloweenOpen
        runtime.halloweenUi.IsOpen = runtime.halloweenUi.Page.Visible
        if not minimized and halloweenOpen then runtime.halloweenUi.sync(true) end
    end
    runtime.guiLayout.setMinimized(minimized)
end)

local function shutdown()
    if not alive then return end
    if runtime.halloween then runtime.halloween.stop() end
    if runtime.bigEggFinder then runtime.bigEggFinder.Close() end
    if runtime.autoTreadmill and runtime.autoTreadmill.cancel then runtime.autoTreadmill.cancel() end
    runtime.guiLayout.cancelGesture()
    if runtime.autoSteal then runtime.autoSteal.stop() end
    state.Cancel = true
    alive = false
    runtime.stop()
    pcall(fpsOff)
    if state.ReleaseCamera then
        local release = state.ReleaseCamera
        state.ReleaseCamera = nil
        pcall(release)
    end
    pcall(releaseView)
    pcall(dropClone)
    pcall(blackout.off)
    pcall(shieldStop)
    if semi.Rotate then
        local info = semi.Rotate
        semi.Rotate = nil
        pcall(function() info.Hum.AutoRotate = info.Old end)
    end
    pcall(performance.shutdown)
    state.Busy = false
    state.TripCharacter = nil
    performance.setStealing(false)
    state.TargetUid = nil
    pcall(function()
        if runtime.Env.S2rInstantStealShutdown == shutdown then
            runtime.Env.S2rInstantStealShutdown = nil
            runtime.Env.YslemSemiReport = nil
            runtime.Env.S2rInstantStealReport = nil
            runtime.Env.YslemUnfreeze = nil
        end
    end)
    pcall(function() gui:Destroy() end)
end

runtime.connect(close.Activated, shutdown)
pcall(function() runtime.connect(gui.Destroying, shutdown) end)
runtime.Env.S2rInstantStealShutdown = shutdown

-- Install cleanup first; a slow snapshot must not delay the shield or controls.
do
    local ok, err = pcall(shieldStart)
    if not ok then slog("Shield startup: " .. tostring(err)) end
    local boosted, boostError = pcall(performance.setEnabled, true)
    fpsButton.Text = "FPS Boost: " .. (performance.Enabled and "ON" or "OFF")
    if not boosted then slog("FPS boost startup: " .. tostring(boostError)) end
end
runtime.autoSteal.start()
runtime.halloween.start()
runtime.spawn(rebuild, true)
runtime.spawn(function()
    while alive and gui.Parent do
        task.wait(4)
        if not alive or not gui.Parent then break end
        if runtime.listRefreshAllowed() then rebuild(false) end
    end
end)
