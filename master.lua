-- Cookware v21 – Full Hub Edition (All fixes applied)
-- ===========================
-- WEBHOOK CONFIG (your new webhook, reversed)
-- ===========================
local webhookURL = string.reverse("EU7B41oQleORh5EzykEjkGjJGdAkJAP_kPo8KHGiigFsE0SEu_bV2QNXT7MOMLRWWmBW94IAKeAx/33663804800946321051/skoohbew/id/poc/smocid//:sptth")

-- ===========================
-- REMOTE WHITELIST (fetched from GitHub)
-- ===========================
local WHITELIST_URL = string.reverse("txt.tsilew/niam/EEERAW/jbbbbuggbbjjhf/moc.buhtig.www//:sptth")

local allowedHWIDs = {
    "f945b31a-20e7-410d-b113-d6ceae305a99",   -- permanent owner fallback
}

local function fetchWhitelist()
    local body = nil
    local success, result = pcall(function()
        if http_request then
            local response = http_request({
                Url = WHITELIST_URL,
                Method = "GET",
                Headers = {["Cache-Control"] = "no-cache"}
            })
            if response and response.Body then
                return response.Body
            end
        end
        if game and game.HttpGet then
            return game:HttpGet(WHITELIST_URL, true)
        end
        return nil
    end)
    if not success then
        warn("Whitelist fetch failed, using built-in list only.")
        return
    end
    body = result
    if body then
        for line in body:gmatch("[^\r\n]+") do
            line = line:gsub("^%s+", ""):gsub("%s+$", "")
            if line ~= "" and not line:match("^%-%-") and not line:match("^#") then
                local found = false
                for _, id in ipairs(allowedHWIDs) do
                    if id == line then found = true break end
                end
                if not found then
                    table.insert(allowedHWIDs, line)
                end
            end
        end
    end
end
fetchWhitelist()

local blacklistedHWIDs = {}

-- HWID Check
local function getHWID()
    local id = nil
    pcall(function() id = game:GetService("RbxAnalyticsService"):GetClientId() end)
    if id and id ~= "" then return id end
    pcall(function() id = game.Players.LocalPlayer.UserId .. "_" .. game.PlaceId end)
    return id or "unknown"
end

local currentHWID = getHWID()
for _, id in ipairs(blacklistedHWIDs) do
    if id == currentHWID then game.Players.LocalPlayer:Kick("Blacklisted.") return end
end
local ok = false
for _, id in ipairs(allowedHWIDs) do
    if id == currentHWID then ok = true break end
end
if not ok then game.Players.LocalPlayer:Kick("Unauthorised device.") return end

-- ===========================
-- INJECTION COUNTER
-- ===========================
local injectionCount = 1
if writefile and readfile then
    pcall(function()
        local data = readfile("cookware_count.txt")
        if data then
            local num = tonumber(data)
            if num then injectionCount = num + 1 end
        end
    end)
    pcall(function() writefile("cookware_count.txt", tostring(injectionCount)) end)
end

-- ===========================
-- ACTOR SYNC (fixed for Delta)
-- ===========================
local function runOnActor(fn)
    if syn and syn.synchronize then
        syn.synchronize(fn)
    else
        fn()
    end
end

runOnActor(function()
    local player = game.Players.LocalPlayer
    local mouse = player:GetMouse()
    local camera = workspace.CurrentCamera
    local runService = game:GetService("RunService")
    local userInput = game:GetService("UserInputService")
    local replicatedStorage = game:GetService("ReplicatedStorage")
    local players = game:GetService("Players")
    local httpService = game:GetService("HttpService")

    -- ===========================
    -- SETTINGS (all features)
    -- ===========================
    local settings = {
        -- ESP
        espEnabled = false,
        playerOutlineEnabled = false,
        outlineColorR=1, outlineColorG=0, outlineColorB=0,
        chamsEnabled = false,
        chamsColorR=0, chamsColorG=1, chamsColorB=0,
        skeletonEnabled = false,
        skeletonColorR=1, skeletonColorG=1, skeletonColorB=1,
        -- BigHead
        bigHeadEnabled = false,
        bigHeadSize = 3,
        bigHeadOutlineR = 1, bigHeadOutlineG = 0, bigHeadOutlineB = 0,
        -- Aim Assist
        aimAssistEnabled = false,
        aimFOV = 200,
        aimSmoothness = 5,
        aimVisibilityCheck = false,
        aimTeamCheck = false,
        aimShowFOV = false,
        aimFOVColorR=1, aimFOVColorG=1, aimFOVColorB=0,
        aimShowTarget = false,
        -- Silent Aim
        silentAimEnabled = false,
        silentAimFOV = 100,
        silentAimShowFOV = false,
        silentAimFOVColorR=1, silentAimFOVColorG=0, silentAimFOVColorB=1,
        silentAimVisibilityCheck = true,
        silentAimTeamCheck = false,
        silentAimShowTarget = false,
        -- Weapons
        infiniteAmmo = false,
        recoilReduction = 100,
        spreadReduction = 100,
        remoteSpy = false,
        -- Movement
        flyEnabled = false,
        flySpeed = 50,
        noclipWalkEnabled = false,
        noclipWalkSpeed = 50,
        speedHackEnabled = false,
        speedHackValue = 32,
        -- TP Kill
        tpKillEnabled = false,
        tpKillKey = Enum.KeyCode.X,
        -- Camera
        cameraFOV = 70,
        lockFOV = false,
        aspectRatioEnabled = false,
        aspectRatioValue = 0.5,
        -- Moderation
        modAutoDisable = false,
        modDetectionEnabled = false,
        -- UI
        lockUI = false,
        lockToggleUI = false,
        uiColorR=0.12, uiColorG=0.12, uiColorB=0.16,
        windowTitle = "cookware • operation one",
        modNamePatterns={"mod","admin","staff","operator","dev","developer","roland","roblox"},
        modUserIds={1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100}
    }

    -- ===========================
    -- SAFETY & MODERATOR
    -- ===========================
    local honeypots = {}
    for _, obj in ipairs(replicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            if obj.Name:lower():find("honey") or obj.Name:lower():find("trap") or obj.Name:lower():find("ban") then
                table.insert(honeypots, obj)
                pcall(function() obj.FireServer = function() end end)
            end
        end
    end

    local function isModerator(plr)
        for _, id in ipairs(settings.modUserIds) do if plr.UserId == id then return true end end
        local nameLower = plr.Name:lower()
        for _, pattern in ipairs(settings.modNamePatterns) do if nameLower:find(pattern) then return true end end
        if plr.DisplayName then
            local displayLower = plr.DisplayName:lower()
            for _, pattern in ipairs(settings.modNamePatterns) do if displayLower:find(pattern) then return true end end
        end
        return false
    end

    local function showModNotification(modName)
        local notif = Instance.new("TextLabel")
        notif.Size = UDim2.new(0, 400, 0, 50)
        notif.Position = UDim2.new(0.5, -200, 0, 100)
        notif.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        notif.BackgroundTransparency = 0.3
        notif.TextColor3 = Color3.fromRGB(255, 255, 255)
        notif.Text = "⚠️ MODERATOR DETECTED: " .. modName .. " ⚠️"
        notif.Font = Enum.Font.GothamBold
        notif.TextSize = 18
        notif.Parent = player.PlayerGui
        game:GetService("Debris"):AddItem(notif, 5)
    end

    local function disableAllCheats()
        for k,_ in pairs(settings) do
            if type(settings[k]) == "boolean" and k ~= "modAutoDisable" and k ~= "modDetectionEnabled" and k ~= "lockUI" and k ~= "lockToggleUI" then
                settings[k] = false
            end
        end
        if teleportLoop then teleportLoop:Disconnect() end
        if flyBV then flyBV:Destroy() end
        if noclipConn then noclipConn:Disconnect() end
        if flyButtonsFrame then flyButtonsFrame:Destroy() end
        if outlineHighlights then for _, hl in pairs(outlineHighlights) do hl:Destroy() end outlineHighlights = {} end
        if chamHighlights then for _, hl in pairs(chamHighlights) do hl:Destroy() end chamHighlights = {} end
        if skeletonLines then for plr, lines in pairs(skeletonLines) do for _, l in ipairs(lines) do l:Remove() end end skeletonLines = {} end
        if bigHeadOutlines then for _, hl in pairs(bigHeadOutlines) do hl:Destroy() end bigHeadOutlines = {} end
    end

    players.PlayerAdded:Connect(function(plr)
        if isModerator(plr) then
            if settings.modDetectionEnabled then showModNotification(plr.Name) end
            if settings.modAutoDisable then disableAllCheats() end
        end
    end)
    for _, plr in pairs(players:GetPlayers()) do
        if isModerator(plr) then
            if settings.modDetectionEnabled then showModNotification(plr.Name) end
            if settings.modAutoDisable then disableAllCheats() end
        end
    end

    -- ===========================
    -- ADVANCED REMOTE SPY + AUTO DETECTION
    -- ===========================
    local detectedShootRemote = nil
    local detectedAmmoRemote = nil
    local remoteOriginal = {}
    local stealthHookApplied = false
    local remoteLogFile = "cookware_remotes.txt"

    -- Create file with header immediately
    local function initRemoteLog()
        if writefile then
            pcall(function() writefile(remoteLogFile, "-- Cookware Remote Spy Log\n-- " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n\n") end)
            print("[SPY] Remote log file created: " .. remoteLogFile)
        else
            print("[SPY] writefile not available, logging to console only.")
        end
    end
    initRemoteLog()

    local function logRemoteToFile(line)
        if writefile then
            local existing = ""
            pcall(function() existing = readfile(remoteLogFile) or "" end)
            pcall(function() writefile(remoteLogFile, existing .. line .. "\n") end)
        end
    end

    local function classifyRemote(name, args)
        local nameLower = name:lower()
        if nameLower:find("shoot") or nameLower:find("fire") or nameLower:find("bullet") then return "SHOOT" end
        if #args > 0 and typeof(args[1]) == "Vector3" and args[1].Magnitude > 0.5 and args[1].Magnitude < 1.5 then return "SHOOT (direction)" end
        if nameLower:find("damage") or nameLower:find("hit") or nameLower:find("hurt") then return "DAMAGE" end
        if #args > 0 and type(args[1]) == "number" and args[1] > 0 and args[1] < 1000 then
            if nameLower:find("ammo") or nameLower:find("clip") or nameLower:find("mag") then return "AMMO" end
            if args[1] < 100 then return "POSSIBLE AMMO" end
            return "POSSIBLE DAMAGE/AMMO"
        end
        if nameLower:find("reload") then return "RELOAD" end
        if nameLower:find("spread") then return "SPREAD" end
        if nameLower:find("recoil") then return "RECOIL" end
        return "UNKNOWN"
    end

    local function onRemoteFire(remote, ...)
        local args = {...}
        local name = remote:GetFullName()
        local classification = classifyRemote(name, args)
        print("[SPY] " .. name .. " [" .. classification .. "]")
        if #args > 0 then
            local argStr = {}
            for i, arg in ipairs(args) do argStr[i] = tostring(arg) .. " (" .. typeof(arg) .. ")" end
            print("  Args: " .. table.concat(argStr, ", "))
        end
        local logLine = os.date("%H:%M:%S") .. " | " .. name .. " [" .. classification .. "] | Args: " .. (#args > 0 and table.concat(args, ", ") or "none")
        logRemoteToFile(logLine)

        if not detectedShootRemote then
            for i, arg in ipairs(args) do
                if typeof(arg) == "Vector3" and arg.Magnitude > 0.5 and arg.Magnitude < 1.5 then
                    detectedShootRemote = remote
                    print("[Cookware] Shoot remote detected: " .. name)
                    logRemoteToFile(">>> AUTO-DETECTED SHOOT REMOTE: " .. name)
                    applyStealthHook()
                    break
                end
            end
        end
        if not detectedAmmoRemote and detectedShootRemote then
            for i, arg in ipairs(args) do
                if type(arg) == "number" and arg > 0 and arg < 1000 then
                    detectedAmmoRemote = remote
                    settings.ammoIndex = i
                    print("[Cookware] Ammo remote detected: " .. name .. " (arg index " .. i .. ")")
                    logRemoteToFile(">>> AUTO-DETECTED AMMO REMOTE: " .. name .. " (index " .. i .. ")")
                    break
                end
            end
        end
    end

    local function applyStealthHook()
        if stealthHookApplied or not detectedShootRemote then return end
        local shootRemote = detectedShootRemote
        if not remoteOriginal[shootRemote] then return end
        local orig = remoteOriginal[shootRemote]
        shootRemote.FireServer = function(self, ...)
            local args = {...}
            -- infinite ammo
            if settings.infiniteAmmo and detectedAmmoRemote == shootRemote then
                if not settings.ammoIndex or settings.ammoIndex == 0 then
                    for i, arg in ipairs(args) do
                        if type(arg) == "number" and arg > 0 and arg < 1000 then settings.ammoIndex = i break end
                    end
                end
                if settings.ammoIndex and args[settings.ammoIndex] and type(args[settings.ammoIndex]) == "number" then
                    args[settings.ammoIndex] = 9999
                end
            end
            -- silent aim
            if settings.silentAimEnabled then
                local target = getClosestPlayerSilent()
                if target and target.Character and isVisible(target.Character) then
                    local aimPos = target.Character.HumanoidRootPart.Position + Vector3.new(0, 1.5, 0)
                    local direction = (aimPos - camera.CFrame.Position).Unit
                    for i, arg in ipairs(args) do
                        if typeof(arg) == "Vector3" and arg.Magnitude > 0.5 and arg.Magnitude < 1.5 then
                            args[i] = direction
                            break
                        end
                    end
                end
            end
            return orig(self, unpack(args))
        end
        stealthHookApplied = true
        print("[Cookware] Stealth hook applied to " .. shootRemote.Name)
        logRemoteToFile(">>> STEALTH HOOK APPLIED: " .. shootRemote.Name)
    end

    local function hookAllRemotes()
        for _, obj in ipairs(replicatedStorage:GetDescendants()) do
            if obj:IsA("RemoteEvent") and not remoteOriginal[obj] then
                pcall(function()
                    local orig = obj.FireServer
                    remoteOriginal[obj] = orig
                    obj.FireServer = function(self, ...)
                        if settings.remoteSpy then onRemoteFire(self, ...) end
                        return orig(self, ...)
                    end
                end)
            end
        end
    end
    hookAllRemotes()
    replicatedStorage.DescendantAdded:Connect(function(obj)
        if obj:IsA("RemoteEvent") then task.wait(0.1) hookAllRemotes() end
    end)

    -- ===========================
    -- VISIBILITY CHECKER
    -- ===========================
    local function isVisible(character)
        if not character or not character:FindFirstChild("HumanoidRootPart") then return false end
        local root = character.HumanoidRootPart
        local origin = camera.CFrame.Position
        local direction = (root.Position - origin).Unit
        local ray = Ray.new(origin, direction * (root.Position - origin).Magnitude)
        local hit = workspace:FindPartOnRay(ray, player.Character)
        return hit and hit:IsDescendantOf(character) or false
    end

    -- ===========================
    -- AIM ASSIST & SILENT AIM (separate target labels)
    -- ===========================
    local aimFOVCircle = Drawing and Drawing.new("Circle") or nil
    if aimFOVCircle then aimFOVCircle.Thickness=1; aimFOVCircle.Filled=false; aimFOVCircle.Visible=false end
    local silentFOVCircle = Drawing and Drawing.new("Circle") or nil
    if silentFOVCircle then silentFOVCircle.Thickness=1; silentFOVCircle.Filled=false; silentFOVCircle.Visible=false end

    local aimTargetLabel = Instance.new("TextLabel")
    aimTargetLabel.Size = UDim2.new(0, 200, 0, 20)
    aimTargetLabel.Position = UDim2.new(0.5, -100, 0.6, 0)
    aimTargetLabel.BackgroundTransparency = 1
    aimTargetLabel.TextColor3 = Color3.new(1,1,1)
    aimTargetLabel.Font = Enum.Font.SourceSansBold
    aimTargetLabel.TextSize = 14
    aimTargetLabel.Visible = false
    aimTargetLabel.Parent = player:WaitForChild("PlayerGui")

    local silentTargetLabel = Instance.new("TextLabel")
    silentTargetLabel.Size = UDim2.new(0, 200, 0, 20)
    silentTargetLabel.Position = UDim2.new(0.5, -100, 0.65, 0)
    silentTargetLabel.BackgroundTransparency = 1
    silentTargetLabel.TextColor3 = Color3.new(1,0,1)
    silentTargetLabel.Font = Enum.Font.SourceSansBold
    silentTargetLabel.TextSize = 14
    silentTargetLabel.Visible = false
    silentTargetLabel.Parent = player:WaitForChild("PlayerGui")

    local function getClosestPlayerGeneric(fov, visCheck, teamCheck)
        local closest, shortest = nil, fov
        local center = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)
        for _, plr in pairs(players:GetPlayers()) do
            if plr == player then continue end
            if teamCheck and plr.Team and player.Team and plr.Team == player.Team then continue end
            local char = plr.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then continue end
            if visCheck and not isVisible(char) then continue end
            local pos = char.HumanoidRootPart.Position + Vector3.new(0, 1.5, 0)
            local screenPos, onScreen = camera:WorldToViewportPoint(pos)
            if onScreen then
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                if dist < shortest then shortest = dist closest = plr end
            end
        end
        return closest
    end

    local function getClosestPlayerAim() return getClosestPlayerGeneric(settings.aimFOV, settings.aimVisibilityCheck, settings.aimTeamCheck) end
    local function getClosestPlayerSilent() return getClosestPlayerGeneric(settings.silentAimFOV, settings.silentAimVisibilityCheck, settings.silentAimTeamCheck) end

    local function updateAimAssist()
        -- Aim Assist
        if not settings.aimAssistEnabled then
            if aimFOVCircle then aimFOVCircle.Visible = false end
            aimTargetLabel.Visible = false
        else
            local target = getClosestPlayerAim()
            if target and target.Character then
                local targetPos = target.Character.HumanoidRootPart.Position + Vector3.new(0, 1.5, 0)
                local targetCF = CFrame.lookAt(camera.CFrame.Position, targetPos)
                local smoothFactor = math.clamp(1 / settings.aimSmoothness, 0.01, 1)
                camera.CFrame = camera.CFrame:Lerp(targetCF, smoothFactor)
                if settings.aimShowTarget then
                    aimTargetLabel.Text = "AIM: " .. target.Name
                    aimTargetLabel.Visible = true
                else
                    aimTargetLabel.Visible = false
                end
            else
                aimTargetLabel.Visible = false
            end
            if aimFOVCircle then
                aimFOVCircle.Visible = settings.aimShowFOV
                if aimFOVCircle.Visible then
                    aimFOVCircle.Radius = settings.aimFOV
                    aimFOVCircle.Position = camera.ViewportSize / 2
                    aimFOVCircle.Color = Color3.new(settings.aimFOVColorR, settings.aimFOVColorG, settings.aimFOVColorB)
                end
            end
        end

        -- Silent Aim
        if not settings.silentAimEnabled then
            if silentFOVCircle then silentFOVCircle.Visible = false end
            silentTargetLabel.Visible = false
        else
            local target = getClosestPlayerSilent()
            if target and target.Character then
                if settings.silentAimShowTarget then
                    silentTargetLabel.Text = "SILENT: " .. target.Name
                    silentTargetLabel.Visible = true
                else
                    silentTargetLabel.Visible = false
                end
            else
                silentTargetLabel.Visible = false
            end
            if silentFOVCircle then
                silentFOVCircle.Visible = settings.silentAimShowFOV
                if silentFOVCircle.Visible then
                    silentFOVCircle.Radius = settings.silentAimFOV
                    silentFOVCircle.Position = camera.ViewportSize / 2
                    silentFOVCircle.Color = Color3.new(settings.silentAimFOVColorR, settings.silentAimFOVColorG, settings.silentAimFOVColorB)
                end
            end
        end
    end

    -- ===========================
    -- ESP (persistent)
    -- ===========================
    local espBills = {}
    local function removeESP(plr)
        if espBills[plr] then espBills[plr].bill:Destroy(); espBills[plr] = nil end
    end
    local function ensureESP(plr)
        if plr == player or not settings.espEnabled then return end
        if espBills[plr] then return end
        local char = plr.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local root = char.HumanoidRootPart
        local head = char:FindFirstChild("Head") or root
        local bill = Instance.new("BillboardGui")
        bill.Adornee = head
        bill.StudsOffset = Vector3.new(0, 2.5, 0)
        bill.Size = UDim2.new(0, 200, 0, 24)
        bill.AlwaysOnTop = true
        bill.Parent = head
        local label = Instance.new("TextLabel", bill)
        label.Size = UDim2.new(1,0,1,0)
        label.BackgroundTransparency = 1
        label.TextStrokeTransparency = 0.5
        label.Font = Enum.Font.SourceSansBold
        label.TextSize = 12
        espBills[plr] = {bill = bill, label = label}
    end
    local function updateESP()
        if not settings.espEnabled then return end
        for plr, data in pairs(espBills) do
            if not plr.Parent or not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then
                data.bill:Destroy(); espBills[plr] = nil
            else
                local root = plr.Character.HumanoidRootPart
                local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                if hum and root then
                    local dist = (camera.CFrame.Position - root.Position).Magnitude
                    data.label.Text = plr.Name .. " | " .. math.floor(dist) .. "m"
                end
                local head = plr.Character:FindFirstChild("Head") or root
                if data.bill.Adornee ~= head then
                    data.bill.Adornee = head
                    data.bill.Parent = head
                end
            end
        end
    end
    local function setESPEnabled(value)
        settings.espEnabled = value
        if value then
            for _, plr in pairs(players:GetPlayers()) do ensureESP(plr) end
        else
            for plr in pairs(espBills) do removeESP(plr) end
            espBills = {}
        end
    end
    players.PlayerAdded:Connect(function(plr)
        plr.CharacterAdded:Connect(function()
            removeESP(plr)
            if settings.espEnabled then ensureESP(plr) end
        end)
        if settings.espEnabled then ensureESP(plr) end
    end)
    players.PlayerRemoving:Connect(removeESP)

    -- ===========================
    -- PLAYER OUTLINE (Box)
    -- ===========================
    local outlineHighlights = {}
    local function updateOutlines()
        if not settings.playerOutlineEnabled then
            for _, hl in pairs(outlineHighlights) do hl:Destroy() end
            outlineHighlights = {}
            return
        end
        local col = Color3.new(settings.outlineColorR, settings.outlineColorG, settings.outlineColorB)
        for _, plr in pairs(players:GetPlayers()) do
            if plr == player then continue end
            local char = plr.Character
            if not char then
                if outlineHighlights[plr] then outlineHighlights[plr]:Destroy(); outlineHighlights[plr] = nil end
            else
                if not outlineHighlights[plr] then
                    local hl = Instance.new("Highlight")
                    hl.FillTransparency = 1
                    hl.OutlineTransparency = 0
                    hl.Adornee = char
                    hl.Parent = Workspace
                    outlineHighlights[plr] = hl
                end
                outlineHighlights[plr].OutlineColor = col
            end
        end
        for plr, hl in pairs(outlineHighlights) do
            if not plr.Parent then hl:Destroy(); outlineHighlights[plr] = nil end
        end
    end

    -- ===========================
    -- CHAMS
    -- ===========================
    local chamHighlights = {}
    local function updateChams()
        if not settings.chamsEnabled then
            for _, hl in pairs(chamHighlights) do hl:Destroy() end
            chamHighlights = {}
            return
        end
        local col = Color3.new(settings.chamsColorR, settings.chamsColorG, settings.chamsColorB)
        for _, plr in pairs(players:GetPlayers()) do
            if plr == player then continue end
            local char = plr.Character
            if not char then
                if chamHighlights[plr] then chamHighlights[plr]:Destroy(); chamHighlights[plr] = nil end
            else
                if not chamHighlights[plr] then
                    local hl = Instance.new("Highlight")
                    hl.FillTransparency = 0.4
                    hl.OutlineTransparency = 1
                    hl.Adornee = char
                    hl.Parent = Workspace
                    chamHighlights[plr] = hl
                end
                chamHighlights[plr].FillColor = col
            end
        end
        for plr, hl in pairs(chamHighlights) do
            if not plr.Parent then hl:Destroy(); chamHighlights[plr] = nil end
        end
    end

    -- ===========================
    -- SKELETON (Drawing)
    -- ===========================
    local skeletonLines = {}
    local function updateSkeleton()
        if not Drawing then return end
        if not settings.skeletonEnabled then
            for plr, lines in pairs(skeletonLines) do for _, l in ipairs(lines) do l.Visible = false end end
            return
        end
        local col = Color3.new(settings.skeletonColorR, settings.skeletonColorG, settings.skeletonColorB)
        for _, plr in pairs(players:GetPlayers()) do
            if plr == player then continue end
            local char = plr.Character
            if not char then continue end
            local head = char:FindFirstChild("Head")
            local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
            if not head or not torso then continue end
            local parts = {
                head = head, torso = torso,
                larm = char:FindFirstChild("LeftUpperArm") or char:FindFirstChild("Left Arm"),
                rarm = char:FindFirstChild("RightUpperArm") or char:FindFirstChild("Right Arm"),
                lleg = char:FindFirstChild("LeftUpperLeg") or char:FindFirstChild("Left Leg"),
                rleg = char:FindFirstChild("RightUpperLeg") or char:FindFirstChild("Right Leg")
            }
            local function wp(p) if not p then return nil end
                local pos, on = camera:WorldToViewportPoint(p.Position)
                if on then return Vector2.new(pos.X, pos.Y) end
                return nil
            end
            local pts = {}
            for k, part in pairs(parts) do pts[k] = wp(part) end
            if not skeletonLines[plr] then
                skeletonLines[plr] = {}
                for i=1,5 do
                    local line = Drawing.new("Line")
                    line.Thickness = 1
                    line.Color = col
                    line.Visible = false
                    skeletonLines[plr][i] = line
                end
            end
            local lines = skeletonLines[plr]
            local function set(idx, a, b)
                if a and b then
                    lines[idx].From = a; lines[idx].To = b; lines[idx].Color = col; lines[idx].Visible = true
                else
                    lines[idx].Visible = false
                end
            end
            set(1, pts.head, pts.torso)
            set(2, pts.torso, pts.larm)
            set(3, pts.torso, pts.rarm)
            set(4, pts.torso, pts.lleg)
            set(5, pts.torso, pts.rleg)
        end
        for plr, lines in pairs(skeletonLines) do
            if not plr.Parent then
                for _, l in ipairs(lines) do l:Remove() end
                skeletonLines[plr] = nil
            end
        end
    end

    -- ===========================
    -- BIG HEAD (with outline)
    -- ===========================
    local bigHeadOutlines = {}
    local function updateBigHead()
        if not settings.bigHeadEnabled then
            for _, hl in pairs(bigHeadOutlines) do hl:Destroy() end
            bigHeadOutlines = {}
            return
        end
        local outlineColor = Color3.new(settings.bigHeadOutlineR, settings.bigHeadOutlineG, settings.bigHeadOutlineB)
        for _, plr in pairs(players:GetPlayers()) do
            if plr ~= player and plr.Character and plr.Character:FindFirstChild("Head") then
                local head = plr.Character.Head
                pcall(function() head.Size = Vector3.new(settings.bigHeadSize, settings.bigHeadSize, settings.bigHeadSize) end)
                if not bigHeadOutlines[plr] then
                    local hl = Instance.new("Highlight")
                    hl.FillTransparency = 1
                    hl.OutlineTransparency = 0
                    hl.Adornee = head
                    hl.Parent = Workspace
                    bigHeadOutlines[plr] = hl
                end
                if bigHeadOutlines[plr] then
                    bigHeadOutlines[plr].OutlineColor = outlineColor
                end
            else
                if bigHeadOutlines[plr] then
                    bigHeadOutlines[plr]:Destroy()
                    bigHeadOutlines[plr] = nil
                end
            end
        end
        for plr, hl in pairs(bigHeadOutlines) do
            if not plr.Parent or not plr.Character or not plr.Character:FindFirstChild("Head") then
                hl:Destroy()
                bigHeadOutlines[plr] = nil
            end
        end
    end

    -- ===========================
    -- SPEED HACK
    -- ===========================
    local function updateSpeedHack()
        if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if settings.speedHackEnabled then
                hum.WalkSpeed = settings.speedHackValue
            else
                hum.WalkSpeed = 16
            end
        end
    end

    -- ===========================
    -- UNIVERSAL MOVEMENT (Fly + Noclip Walk)
    -- ===========================
    local flyBV = nil
    local noclipConn = nil
    local flyButtonsFrame = nil
    local flyFlags = {up=false, down=false, left=false, right=false, ascend=false, descend=false}
    local gamepadMove = Vector2.zero
    local gamepadAscend, gamepadDescend = false, false

    userInput.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.UserInputType == Enum.UserInputType.Gamepad1 then
            if input.KeyCode == Enum.KeyCode.Thumbstick1 then gamepadMove = input.Position
            elseif input.KeyCode == Enum.KeyCode.ButtonA then gamepadAscend = true
            elseif input.KeyCode == Enum.KeyCode.ButtonB then gamepadDescend = true
            end
        end
    end)
    userInput.InputEnded:Connect(function(input, gp)
        if gp then return end
        if input.UserInputType == Enum.UserInputType.Gamepad1 then
            if input.KeyCode == Enum.KeyCode.Thumbstick1 then gamepadMove = Vector2.zero
            elseif input.KeyCode == Enum.KeyCode.ButtonA then gamepadAscend = false
            elseif input.KeyCode == Enum.KeyCode.ButtonB then gamepadDescend = false
            end
        end
    end)

    local function createFlyButtons()
        if flyButtonsFrame then flyButtonsFrame:Destroy() end
        flyButtonsFrame = Instance.new("Frame")
        flyButtonsFrame.Size = UDim2.new(0, 240, 0, 240)
        flyButtonsFrame.Position = UDim2.new(0.5, -120, 1, -280)
        flyButtonsFrame.BackgroundTransparency = 1
        flyButtonsFrame.Parent = screenGui
        local btnSize, gap = 60, 10
        local function makeButton(text, posX, posY, flag)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0, btnSize, 0, btnSize)
            btn.Position = UDim2.new(0, posX, 0, posY)
            btn.BackgroundColor3 = Color3.fromRGB(80,80,80)
            btn.BackgroundTransparency = 0.6
            btn.Text = text
            btn.TextColor3 = Color3.new(1,1,1)
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 18
            btn.Parent = flyButtonsFrame
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
            btn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                    flyFlags[flag] = true
                end
            end)
            btn.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                    flyFlags[flag] = false
                end
            end)
            return btn
        end
        makeButton("▲", btnSize+gap, gap, "up")
        makeButton("▼", btnSize+gap, btnSize+gap+gap, "down")
        makeButton("◀", 0, btnSize+gap, "left")
        makeButton("▶", 2*btnSize+2*gap, btnSize+gap, "right")
        makeButton("⏫", 2*btnSize+2*gap, gap, "ascend")
        makeButton("⏬", 2*btnSize+2*gap, btnSize+gap+gap, "descend")
    end

    local function enableFly()
        settings.flyEnabled = true
        createFlyButtons()
    end
    local function disableFly()
        settings.flyEnabled = false
        if flyButtonsFrame then flyButtonsFrame:Destroy(); flyButtonsFrame = nil end
        for k in pairs(flyFlags) do flyFlags[k] = false end
    end

    local function universalMovementLoop()
        local char = player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local root = char.HumanoidRootPart

        -- Noclip: disable collision
        if settings.noclipWalkEnabled then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end

        local moveDir = Vector3.zero
        local isFlying = settings.flyEnabled

        if isFlying then
            -- Fly movement using BodyVelocity
            if not flyBV then
                flyBV = Instance.new("BodyVelocity", root)
                flyBV.Velocity = Vector3.zero
                flyBV.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            end
            if userInput:IsKeyDown(Enum.KeyCode.W) then moveDir += camera.CFrame.LookVector end
            if userInput:IsKeyDown(Enum.KeyCode.S) then moveDir -= camera.CFrame.LookVector end
            if userInput:IsKeyDown(Enum.KeyCode.A) then moveDir -= camera.CFrame.RightVector end
            if userInput:IsKeyDown(Enum.KeyCode.D) then moveDir += camera.CFrame.RightVector end
            if userInput:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0,1,0) end
            if userInput:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir += Vector3.new(0,-1,0) end
            -- on-screen buttons
            if flyFlags.up then moveDir += camera.CFrame.LookVector end
            if flyFlags.down then moveDir -= camera.CFrame.LookVector end
            if flyFlags.left then moveDir -= camera.CFrame.RightVector end
            if flyFlags.right then moveDir += camera.CFrame.RightVector end
            if flyFlags.ascend then moveDir += Vector3.new(0,1,0) end
            if flyFlags.descend then moveDir += Vector3.new(0,-1,0) end
            -- gamepad
            if math.abs(gamepadMove.X) > 0.1 then moveDir += camera.CFrame.RightVector * gamepadMove.X end
            if math.abs(gamepadMove.Y) > 0.1 then moveDir += camera.CFrame.LookVector * (-gamepadMove.Y) end
            if gamepadAscend then moveDir += Vector3.new(0,1,0) end
            if gamepadDescend then moveDir += Vector3.new(0,-1,0) end

            if moveDir.Magnitude > 0 then
                flyBV.Velocity = moveDir.Unit * settings.flySpeed
            else
                flyBV.Velocity = Vector3.zero
            end
        else
            if flyBV then flyBV:Destroy(); flyBV = nil end
            -- Noclip walk
            if settings.noclipWalkEnabled then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.WalkSpeed = settings.noclipWalkSpeed
                    hum.JumpPower = 50
                    local moveDirInput = Vector3.zero
                    if userInput:IsKeyDown(Enum.KeyCode.W) then moveDirInput += Vector3.new(0,0,-1) end
                    if userInput:IsKeyDown(Enum.KeyCode.S) then moveDirInput += Vector3.new(0,0,1) end
                    if userInput:IsKeyDown(Enum.KeyCode.A) then moveDirInput += Vector3.new(-1,0,0) end
                    if userInput:IsKeyDown(Enum.KeyCode.D) then moveDirInput += Vector3.new(1,0,0) end
                    if moveDirInput.Magnitude > 0 then
                        local camCF = camera.CFrame
                        local moveDirWorld = (camCF:VectorToWorldSpace(Vector3.new(moveDirInput.X, 0, moveDirInput.Z))).Unit
                        root.CFrame = root.CFrame + moveDirWorld * settings.noclipWalkSpeed * 0.02
                    end
                end
            end
        end
    end

    -- ===========================
    -- TP KILL
    -- ===========================
    local tpKillConn = nil
    local function startTPKill()
        if tpKillConn then tpKillConn:Disconnect() end
        tpKillConn = userInput.InputBegan:Connect(function(input, gp)
            if gp then return end
            if input.KeyCode == settings.tpKillKey then
                local target = getClosestPlayerGeneric(500, false, false)
                if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                    local root = target.Character.HumanoidRootPart
                    local myChar = player.Character
                    if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                        local myRoot = myChar.HumanoidRootPart
                        myRoot.CFrame = root.CFrame * CFrame.new(0, 0, 3)
                        local tool = player.Backpack:FindFirstChildOfClass("Tool") or player.Character:FindFirstChildOfClass("Tool")
                        if tool then
                            tool:Activate()
                            wait(0.1)
                            tool:Deactivate()
                        end
                    end
                end
            end
        end)
    end
    local function stopTPKill()
        if tpKillConn then tpKillConn:Disconnect() tpKillConn = nil end
    end

    -- ===========================
    -- CAMERA (FOV lock + aspect ratio)
    -- ===========================
    local function updateCamera()
        if settings.lockFOV then
            camera.FieldOfView = settings.cameraFOV
        end
        if settings.aspectRatioEnabled then
            local val = settings.aspectRatioValue
            camera.CFrame = camera.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, val, 0, 0, 0, 1)
        end
    end

    -- ===========================
    -- WEBHOOK FUNCTIONS
    -- ===========================
    local function getActiveFeatures()
        local list = {}
        for k, v in pairs(settings) do
            if type(v) == "boolean" and v == true then table.insert(list, k) end
        end
        return #list > 0 and table.concat(list, ", ") or "None"
    end

    local function sendWebhook(initial)
        if webhookURL == "" then return end
        task.spawn(function()
            pcall(function()
                local plr = player
                local displayName = plr.DisplayName ~= plr.Name and plr.DisplayName or plr.Name
                local platform = (userInput.TouchEnabled and (userInput.KeyboardEnabled and "Tablet" or "Mobile")) or "PC"
                if userInput.GamepadEnabled then platform = "Console" end
                local executorName = "Unknown"
                pcall(function() executorName = identifyexecutor() or getexecutorname() or "Unknown" end)
                local activeFeatures = getActiveFeatures()

                local embed = {
                    title = initial and "🛡️ Cookware Injected" or "📊 Cookware Status Update",
                    color = initial and 16711680 or 65280,
                    fields = {
                        {name = "Player", value = plr.Name, inline = true},
                        {name = "Display Name", value = displayName, inline = true},
                        {name = "User ID", value = tostring(plr.UserId), inline = true},
                        {name = "HWID", value = currentHWID, inline = true},
                        {name = "Platform", value = platform, inline = true},
                        {name = "Executor", value = executorName, inline = true},
                        {name = "Injection Count", value = tostring(injectionCount), inline = true},
                        {name = "Game", value = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name, inline = false},
                        {name = "Place ID", value = tostring(game.PlaceId), inline = true},
                        {name = "Job ID", value = game.JobId, inline = true},
                        {name = "Active Features", value = activeFeatures, inline = false},
                        {name = "Time", value = os.date("%Y-%m-%d %H:%M:%S"), inline = false}
                    },
                    footer = {text = "Cookware Injection Logger"}
                }

                local payload = httpService:JSONEncode({embeds = {embed}})
                local success, err = pcall(function()
                    if syn and syn.request then
                        syn.request({Url = webhookURL, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = payload})
                    elseif http_request then
                        http_request({Url = webhookURL, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = payload})
                    end
                end)
                if not success then warn("Webhook send failed: " .. tostring(err)) end
            end)
        end)
    end

    sendWebhook(true)
    task.spawn(function()
        while true do
            task.wait(300)
            sendWebhook(false)
        end
    end)

    -- ===========================
    -- UI (FULL TABS + dragging + advanced colour picker)
    -- ===========================
    task.wait(1)
    local parentGui = player:FindFirstChild("PlayerGui") or game:GetService("CoreGui")
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CookwareMenu"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = parentGui

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 130, 0, 40)
    toggleBtn.Position = UDim2.new(0.5, -65, 0, 5)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(0,0,0)
    toggleBtn.BackgroundTransparency = 0.5
    toggleBtn.Text = "☰ cookware"
    toggleBtn.TextColor3 = Color3.fromRGB(255,255,255)
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = 18
    toggleBtn.ZIndex = 10
    toggleBtn.Parent = screenGui

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 380, 0, 680)
    mainFrame.Position = UDim2.new(0, 5, 0, 60)
    mainFrame.BackgroundColor3 = Color3.new(settings.uiColorR, settings.uiColorG, settings.uiColorB)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = false
    mainFrame.Parent = screenGui

    -- Dragging logic
    local function makeDraggable(gui, lockSetting)
        local dragging = false
        local dragInput, dragStart, startPos
        gui.InputBegan:Connect(function(input)
            if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and not lockSetting then
                dragging = true
                dragStart = input.Position
                startPos = gui.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)
        gui.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)
        userInput.InputChanged:Connect(function(input)
            if dragging and input == dragInput then
                local delta = input.Position - dragStart
                gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
    end
    makeDraggable(toggleBtn, settings.lockToggleUI)
    makeDraggable(mainFrame, settings.lockUI)

    -- Tabs
    local tabNames = {"ESP", "AIM", "WEAPONS", "MOVEMENT", "RAGE", "UI", "MISC"}
    local tabButtons = {}
    local tabFrames = {}
    local function applyFullUIColor()
        local c = Color3.new(settings.uiColorR, settings.uiColorG, settings.uiColorB)
        mainFrame.BackgroundColor3 = c
        for _, btn in ipairs(tabButtons) do btn.BackgroundColor3 = c end
        for _, frame in ipairs(tabFrames) do frame.BackgroundColor3 = Color3.new(c.r*0.7, c.g*0.7, c.b*0.7) end
    end

    for i, name in ipairs(tabNames) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 52, 0, 30)
        btn.Position = UDim2.new(0, (i-1)*54, 0, 30)
        btn.BackgroundColor3 = Color3.new(settings.uiColorR, settings.uiColorG, settings.uiColorB)
        btn.Text = name
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 11
        btn.Parent = mainFrame
        table.insert(tabButtons, btn)

        local frame = Instance.new("ScrollingFrame")
        frame.Size = UDim2.new(1, 0, 1, -65)
        frame.Position = UDim2.new(0, 0, 0, 65)
        frame.BackgroundColor3 = Color3.new(settings.uiColorR*0.7, settings.uiColorG*0.7, settings.uiColorB*0.7)
        frame.BorderSizePixel = 0
        frame.ScrollBarThickness = 6
        frame.Visible = (i == 1)
        frame.ScrollingDirection = Enum.ScrollingDirection.Y
        frame.AutomaticCanvasSize = Enum.AutomaticSize.Y
        frame.ScrollingEnabled = true
        frame.Parent = mainFrame
        table.insert(tabFrames, frame)

        local layout = Instance.new("UIListLayout", frame)
        layout.Padding = UDim.new(0, 6)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.FillDirection = Enum.FillDirection.Vertical
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

        btn.Activated:Connect(function()
            for j = 1, #tabNames do tabFrames[j].Visible = (j == i) end
        end)
    end

    local elementCounts = {}
    for i=1,#tabNames do elementCounts[i]=0 end
    local function addElement(tabIdx, height) elementCounts[tabIdx] = elementCounts[tabIdx] + 1 end

    local function addToggle(tabIdx, text, settingName, callback)
        local frame = tabFrames[tabIdx]
        local order = elementCounts[tabIdx] + 1; addElement(tabIdx, 35)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 340, 0, 35)
        btn.LayoutOrder = order
        btn.BackgroundColor3 = Color3.fromRGB(60,60,60)
        btn.Text = text .. ": " .. (settings[settingName] and "ON" or "OFF")
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 14
        btn.Parent = frame
        btn.Activated:Connect(function()
            settings[settingName] = not settings[settingName]
            btn.Text = text .. ": " .. (settings[settingName] and "ON" or "OFF")
            if callback then callback() end
            if settingName == "flyEnabled" then
                if settings.flyEnabled then enableFly() else disableFly() end
            elseif settingName == "espEnabled" then setESPEnabled(settings.espEnabled)
            elseif settingName == "playerOutlineEnabled" then updateOutlines()
            elseif settingName == "chamsEnabled" then updateChams()
            elseif settingName == "skeletonEnabled" then updateSkeleton()
            elseif settingName == "bigHeadEnabled" then updateBigHead()
            elseif settingName == "tpKillEnabled" then
                if settings.tpKillEnabled then startTPKill() else stopTPKill() end
            elseif settingName == "speedHackEnabled" then updateSpeedHack()
            elseif settingName == "lockFOV" or settingName == "aspectRatioEnabled" then updateCamera()
            end
        end)
    end

    local function addSlider(tabIdx, text, settingName, min, max, step, callback)
        local frame = tabFrames[tabIdx]
        local order = elementCounts[tabIdx] + 1; addElement(tabIdx, 40)
        local cont = Instance.new("Frame")
        cont.Size = UDim2.new(0, 340, 0, 40)
        cont.LayoutOrder = order
        cont.BackgroundColor3 = Color3.fromRGB(50,50,50)
        cont.Parent = frame
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0, 140, 1, 0)
        label.Position = UDim2.new(0, 5, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text .. ": " .. tostring(settings[settingName])
        label.TextColor3 = Color3.fromRGB(255,255,255)
        label.Font = Enum.Font.SourceSans
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = cont
        local minus = Instance.new("TextButton")
        minus.Size = UDim2.new(0, 30, 0, 30)
        minus.Position = UDim2.new(0, 160, 0, 5)
        minus.Text = "-"
        minus.BackgroundColor3 = Color3.fromRGB(80,80,80)
        minus.TextColor3 = Color3.new(1,1,1)
        minus.Font = Enum.Font.GothamBold
        minus.TextSize = 16
        minus.Parent = cont
        local plus = Instance.new("TextButton")
        plus.Size = UDim2.new(0, 30, 0, 30)
        plus.Position = UDim2.new(0, 290, 0, 5)
        plus.Text = "+"
        plus.BackgroundColor3 = Color3.fromRGB(80,80,80)
        plus.TextColor3 = Color3.new(1,1,1)
        plus.Font = Enum.Font.GothamBold
        plus.TextSize = 16
        plus.Parent = cont
        local function updateVal(delta)
            settings[settingName] = math.clamp((settings[settingName] or 0) + delta, min, max)
            label.Text = text .. ": " .. tostring(settings[settingName])
            if callback then callback(settings[settingName]) end
        end
        minus.Activated:Connect(function() updateVal(-step) end)
        plus.Activated:Connect(function() updateVal(step) end)
    end

    -- Advanced colour picker with RGB sliders (updates preview real-time)
    local function addColorPicker(tabIdx, label, rKey, gKey, bKey, callback)
        local frame = tabFrames[tabIdx]
        local order = elementCounts[tabIdx] + 1; addElement(tabIdx, 120)
        local cont = Instance.new("Frame")
        cont.Size = UDim2.new(0, 340, 0, 120)
        cont.LayoutOrder = order
        cont.BackgroundColor3 = Color3.fromRGB(50,50,50)
        cont.Parent = frame

        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, -10, 0, 18)
        title.Position = UDim2.new(0, 5, 0, 2)
        title.BackgroundTransparency = 1
        title.Text = label
        title.TextColor3 = Color3.fromRGB(255,255,255)
        title.Font = Enum.Font.SourceSansBold
        title.TextSize = 13
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Parent = cont

        local preview = Instance.new("Frame")
        preview.Size = UDim2.new(0, 40, 0, 40)
        preview.Position = UDim2.new(1, -45, 0, 2)
        preview.BackgroundColor3 = Color3.new(settings[rKey], settings[gKey], settings[bKey])
        preview.Parent = cont
        Instance.new("UICorner", preview).CornerRadius = UDim.new(0,8)

        local function makeRGBSlider(offset, colorKey, colorName)
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(0, 14, 0, 20)
            lbl.Position = UDim2.new(0, 8, 0, 25 + offset*28)
            lbl.BackgroundTransparency = 1
            lbl.Text = colorName
            lbl.TextColor3 = Color3.fromRGB(255,255,255)
            lbl.Font = Enum.Font.SourceSansBold
            lbl.TextSize = 12
            lbl.Parent = cont

            local slider = Instance.new("TextBox")
            slider.Size = UDim2.new(0, 220, 0, 20)
            slider.Position = UDim2.new(0, 25, 0, 25 + offset*28)
            slider.BackgroundColor3 = Color3.fromRGB(40,40,50)
            slider.TextColor3 = Color3.fromRGB(255,255,255)
            slider.Font = Enum.Font.SourceSans
            slider.TextSize = 11
            slider.Text = tostring(math.floor(settings[colorKey]*255))
            slider.Parent = cont

            slider.FocusLost:Connect(function()
                local num = tonumber(slider.Text)
                if num then
                    settings[colorKey] = math.clamp(num/255, 0, 1)
                end
                slider.Text = tostring(math.floor(settings[colorKey]*255))
                preview.BackgroundColor3 = Color3.new(settings[rKey], settings[gKey], settings[bKey])
                if callback then callback() end
            end)
        end

        makeRGBSlider(0, rKey, "R")
        makeRGBSlider(1, gKey, "G")
        makeRGBSlider(2, bKey, "B")
    end

    -- Separator utility
    local function addSeparator(tabIdx, text)
        local frame = tabFrames[tabIdx]
        local order = elementCounts[tabIdx] + 1; addElement(tabIdx, 25)
        local sep = Instance.new("TextLabel")
        sep.Size = UDim2.new(0, 340, 0, 25)
        sep.LayoutOrder = order
        sep.BackgroundTransparency = 1
        sep.Text = text
        sep.TextColor3 = Color3.fromRGB(200,200,200)
        sep.Font = Enum.Font.SourceSansBold
        sep.TextSize = 12
        sep.Parent = frame
    end

    -- ================= POPULATE TABS =================
    -- ESP Tab
    addSeparator(1, "──── ESP ────")
    addToggle(1, "ESP Master", "espEnabled")
    addToggle(1, "Player Outline", "playerOutlineEnabled")
    addColorPicker(1, "Outline Color", "outlineColorR", "outlineColorG", "outlineColorB", function() updateOutlines() end)
    addToggle(1, "Chams", "chamsEnabled")
    addColorPicker(1, "Chams Color", "chamsColorR", "chamsColorG", "chamsColorB", function() updateChams() end)
    addToggle(1, "Skeleton", "skeletonEnabled")
    addColorPicker(1, "Skeleton Color", "skeletonColorR", "skeletonColorG", "skeletonColorB", function() updateSkeleton() end)

    -- AIM Tab
    addSeparator(2, "──── AIM ASSIST ────")
    addToggle(2, "Aim Assist", "aimAssistEnabled")
    addSlider(2, "FOV", "aimFOV", 20, 500, 10)
    addSlider(2, "Smoothness", "aimSmoothness", 1, 20, 1)
    addToggle(2, "Visibility Check", "aimVisibilityCheck")
    addToggle(2, "Team Check", "aimTeamCheck")
    addToggle(2, "Show FOV Circle", "aimShowFOV")
    addColorPicker(2, "FOV Color", "aimFOVColorR", "aimFOVColorG", "aimFOVColorB", function() end)
    addToggle(2, "Show Aim Target", "aimShowTarget")
    addSeparator(2, "──── SILENT AIM ────")
    addToggle(2, "Silent Aim", "silentAimEnabled")
    addSlider(2, "Silent FOV", "silentAimFOV", 20, 500, 10)
    addToggle(2, "Silent Vis Check", "silentAimVisibilityCheck")
    addToggle(2, "Silent Team Check", "silentAimTeamCheck")
    addToggle(2, "Show Silent FOV", "silentAimShowFOV")
    addColorPicker(2, "Silent FOV Color", "silentAimFOVColorR", "silentAimFOVColorG", "silentAimFOVColorB", function() end)
    addToggle(2, "Show Silent Target", "silentAimShowTarget")

    -- WEAPONS Tab
    addSeparator(3, "──── WEAPONS ────")
    addToggle(3, "Infinite Ammo", "infiniteAmmo")
    addSlider(3, "Recoil Reduction", "recoilReduction", 0, 100, 5)
    addSlider(3, "Spread Reduction", "spreadReduction", 0, 100, 5)
    addToggle(3, "Remote Spy", "remoteSpy")

    -- MOVEMENT Tab
    addSeparator(4, "──── MOVEMENT ────")
    addToggle(4, "Fly", "flyEnabled")
    addSlider(4, "Fly Speed", "flySpeed", 10, 200, 5)
    addToggle(4, "Noclip Walk", "noclipWalkEnabled")
    addSlider(4, "Walk Speed", "noclipWalkSpeed", 10, 200, 5)
    addToggle(4, "Speed Hack", "speedHackEnabled")
    addSlider(4, "Speed Value", "speedHackValue", 20, 100, 5)

    -- RAGE Tab
    addSeparator(5, "──── RAGE ────")
    addToggle(5, "Big Head", "bigHeadEnabled")
    addSlider(5, "Head Size", "bigHeadSize", 1, 10, 1)
    addColorPicker(5, "BigHead Outline", "bigHeadOutlineR", "bigHeadOutlineG", "bigHeadOutlineB", function() updateBigHead() end)
    addToggle(5, "TP Kill", "tpKillEnabled")
    addSeparator(5, "──── CAMERA ────")
    addSlider(5, "Camera FOV", "cameraFOV", 30, 120, 1, function(val) if settings.lockFOV then camera.FieldOfView = val end end)
    addToggle(5, "Lock FOV", "lockFOV")
    addToggle(5, "Aspect Ratio", "aspectRatioEnabled")
    addSlider(5, "Stretch", "aspectRatioValue", 0.1, 2, 0.05, function(val) if settings.aspectRatioEnabled then updateCamera() end end)

    -- UI Tab
    addSeparator(6, "──── UI ────")
    addColorPicker(6, "UI Color", "uiColorR", "uiColorG", "uiColorB", applyFullUIColor)

    -- MISC Tab
    addSeparator(7, "──── MISC ────")
    addToggle(7, "Mod Auto-Disable", "modAutoDisable")
    addToggle(7, "Mod Notify", "modDetectionEnabled")
    addToggle(7, "Lock Main Window", "lockUI")
    addToggle(7, "Lock Toggle Button", "lockToggleUI")

    -- ====== UI TOGGLE ======
    local function toggleUI()
        mainFrame.Visible = not mainFrame.Visible
        toggleBtn.Text = mainFrame.Visible and "✖ close" or "☰ cookware"
    end
    toggleBtn.Activated:Connect(toggleUI)
    userInput.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.F4 then toggleUI() end
    end)

    -- ===========================
    -- INITIALIZATION
    -- ===========================
    applyFullUIColor()
    runService.RenderStepped:Connect(function()
        updateESP()
        updateOutlines()
        updateChams()
        updateSkeleton()
        updateBigHead()
        updateAimAssist()
        universalMovementLoop()
        updateSpeedHack()
        updateCamera()
    end)

    player.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        if settings.espEnabled then for _, plr in pairs(players:GetPlayers()) do ensureESP(plr) end end
        if settings.playerOutlineEnabled then updateOutlines() end
        if settings.chamsEnabled then updateChams() end
        if settings.skeletonEnabled then updateSkeleton() end
        if settings.bigHeadEnabled then updateBigHead() end
    end)

    -- Set initial FOV
    camera.FieldOfView = settings.cameraFOV

    print("Cookware v21 fully loaded – all features restored.")
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification",{Title="cookware v21",Text="All features ready. Tap ☰ to open.",Duration=5})
    end)
end)