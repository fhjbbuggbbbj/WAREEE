-- Cookware v21.8 – Whitelist debug + all fixes
-- ===========================
-- WEBHOOK CONFIG
-- ===========================
local webhookURL = "https://discord.com/api/webhooks/1510124638900846633/xAeKAI49mBWWRlMLOM7TXNQ2V_buES0gFgiiGHK8o_PkAJdGjEykZE5hROelQobRA7UE"

-- ===========================
-- REMOTE WHITELIST (correct raw URL)
-- ===========================
-- IMPORTANT: Replace the reversed string with your ACTUAL raw file URL reversed.
-- The current string yields: https://raw.githubusercontent.com/YOUR_USER/YOUR_REPO/main/list.txt
-- If your file is elsewhere, adjust accordingly.
local WHITELIST_URL = string.reverse("txt.tsilew/niam/oiber/erauqsrepyh/moc.tnetnocresubuhtigwar//:sptth")
-- This reversed equals: "https://raw.githubusercontent.com/hyperqsuaer/repo/main/list.txt" (example)
-- UPDATE IT to your own raw URL reversed.

local allowedHWIDs = {
    "f945b31a-20e7-410d-b113-d6ceae305a99",   -- permanent owner fallback
}

local function fetchWhitelist()
    print("[WHITELIST] Fetching from: " .. WHITELIST_URL)
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
        warn("[WHITELIST] Fetch failed, using built-in list only. Error: " .. tostring(result))
        return
    end
    body = result
    if body then
        local added = 0
        for line in body:gmatch("[^\r\n]+") do
            line = line:gsub("^%s+", ""):gsub("%s+$", "")
            if line ~= "" and not line:match("^%-%-") and not line:match("^#") then
                local found = false
                for _, id in ipairs(allowedHWIDs) do if id == line then found = true break end end
                if not found then
                    table.insert(allowedHWIDs, line)
                    added = added + 1
                end
            end
        end
        print("[WHITELIST] Added " .. added .. " HWIDs from GitHub. Total allowed: " .. #allowedHWIDs)
    else
        print("[WHITELIST] Fetch returned empty body. Using built-in list only.")
    end
end
fetchWhitelist()

local blacklistedHWIDs = {}
local function getHWID()
    local id = nil
    pcall(function() id = game:GetService("RbxAnalyticsService"):GetClientId() end)
    if id and id ~= "" then return id end
    pcall(function() id = game.Players.LocalPlayer.UserId .. "_" .. game.PlaceId end)
    return id or "unknown"
end
local currentHWID = getHWID()
print("[WHITELIST] Your HWID: " .. currentHWID)

-- Blacklist check
for _, id in ipairs(blacklistedHWIDs) do
    if id == currentHWID then
        game.Players.LocalPlayer:Kick("Blacklisted.")
        return
    end
end

-- Whitelist check
local ok = false
for idx, id in ipairs(allowedHWIDs) do
    if id == currentHWID then
        ok = true
        print("[WHITELIST] HWID found in list at position " .. idx .. ".")
        break
    end
end
if not ok then
    -- Fallback: check if it's the permanent owner
    if currentHWID == "f945b31a-20e7-410d-b113-d6ceae305a99" then
        print("[WHITELIST] HWID matches permanent owner fallback. Access granted.")
        ok = true
    else
        game.Players.LocalPlayer:Kick("Unauthorised device.")
        return
    end
end
print("[✔] HWID approved – " .. currentHWID)

-- ===========================
-- INJECTION COUNTER
-- ===========================
local injectionCount = 1
if writefile and readfile then
    pcall(function()
        local data = readfile("cookware_count.txt")
        if data then local num = tonumber(data) if num then injectionCount = num + 1 end end
    end)
    pcall(function() writefile("cookware_count.txt", tostring(injectionCount)) end)
end

-- ===========================
-- ACTOR SYNC
-- ===========================
local function runOnActor(fn)
    if syn and syn.synchronize then syn.synchronize(fn) else fn() end
end

runOnActor(function()
    local player = game.Players.LocalPlayer
    local camera = workspace.CurrentCamera
    local runService = game:GetService("RunService")
    local userInput = game:GetService("UserInputService")
    local replicatedStorage = game:GetService("ReplicatedStorage")
    local players = game:GetService("Players")
    local httpService = game:GetService("HttpService")
    local debris = game:GetService("Debris")
    local starterGui = game:GetService("StarterGui")
    local stats = game:GetService("Stats")

    -- ===========================
    -- SETTINGS
    -- ===========================
    local settings = {
        espEnabled = false,
        playerOutlineEnabled = false,
        outlineColorR=1, outlineColorG=0, outlineColorB=0,
        chamsEnabled = false,
        chamsColorR=0, chamsColorG=1, chamsColorB=0,
        skeletonEnabled = false,
        skeletonColorR=1, skeletonColorG=1, skeletonColorB=1,
        bigHeadEnabled = false,
        bigHeadSize = 3,
        bigHeadOutlineR = 1, bigHeadOutlineG = 0, bigHeadOutlineB = 0,
        aimAssistEnabled = false,
        aimFOV = 200,
        aimSmoothness = 5,
        aimVisibilityCheck = false,
        aimTeamCheck = false,
        aimShowFOV = false,
        aimFOVColorR=1, aimFOVColorG=1, aimFOVColorB=0,
        aimShowTarget = false,
        aimHitPart = "Head",
        silentAimEnabled = false,
        silentAimFOV = 100,
        silentAimShowFOV = false,
        silentAimFOVColorR=1, silentAimFOVColorG=0, silentAimFOVColorB=1,
        silentAimVisibilityCheck = true,
        silentAimTeamCheck = false,
        silentAimShowTarget = false,
        silentHitPart = "Head",
        infiniteAmmo = false,
        recoilReduction = 100,
        spreadReduction = 100,
        tpKillEnabled = false,
        tpKillKey = Enum.KeyCode.X,
        tpKillTeamCheck = true,
        cameraFOV = 70,
        lockFOV = false,
        aspectRatioEnabled = false,
        aspectRatioValue = 0.5,
        modAutoDisable = false,
        modDetectionEnabled = false,
        lockUI = false,
        lockToggleUI = false,
        uiColorR=0.12, uiColorG=0.12, uiColorB=0.16,
        modNamePatterns = {"mod","admin","staff","operator","dev","developer","roland","roblox"},
        modUserIds = {}
    }

    -- ===========================
    -- SAFETY & MODERATOR
    -- ===========================
    for _, obj in ipairs(replicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            if obj.Name:lower():find("honey") or obj.Name:lower():find("trap") or obj.Name:lower():find("ban") then
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
        debris:AddItem(notif, 5)
    end

    players.PlayerAdded:Connect(function(plr)
        if isModerator(plr) then
            if settings.modDetectionEnabled then showModNotification(plr.Name) end
            if settings.modAutoDisable then
                for k,_ in pairs(settings) do if type(settings[k]) == "boolean" and k ~= "modAutoDisable" and k ~= "modDetectionEnabled" then settings[k] = false end end
            end
        end
    end)
    for _, plr in pairs(players:GetPlayers()) do
        if isModerator(plr) then
            if settings.modDetectionEnabled then showModNotification(plr.Name) end
        end
    end

    -- ===========================
    -- REMOTE SPY (hook once, no spam)
    -- ===========================
    local detectedShootRemote = nil
    local detectedAmmoRemote = nil
    local remoteOriginal = {}
    local stealthHookApplied = false
    local remoteLogFile = "cookware_remotes.txt"

    local function initRemoteLog()
        if writefile then
            pcall(function() writefile(remoteLogFile, "-- Cookware Remote Spy Log\n-- " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n\n") end)
            print("[SPY] Log file created.")
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

    local function isDirectionVector(v)
        if typeof(v) == "Vector3" and v.Magnitude > 0.5 and v.Magnitude < 1.5 then return true end
        if typeof(v) == "CFrame" then return true end
        return false
    end

    local function onRemoteFire(remote, ...)
        local args = {...}
        local name = remote:GetFullName()
        local classification = "UNKNOWN"
        local nameLower = name:lower()
        if nameLower:find("shoot") or nameLower:find("fire") then classification = "SHOOT"
        elseif nameLower:find("damage") then classification = "DAMAGE"
        elseif nameLower:find("ammo") or nameLower:find("clip") then classification = "AMMO"
        elseif nameLower:find("reload") then classification = "RELOAD"
        end
        for _, arg in ipairs(args) do
            if isDirectionVector(arg) then classification = "SHOOT (direction)" break end
        end
        print("[SPY] " .. name .. " [" .. classification .. "]")
        local logLine = os.date("%H:%M:%S") .. " | " .. name .. " [" .. classification .. "] | Args: " .. (#args > 0 and table.concat(args, ", ") or "none")
        logRemoteToFile(logLine)

        if not detectedShootRemote then
            for _, arg in ipairs(args) do
                if isDirectionVector(arg) then
                    detectedShootRemote = remote
                    print("[Cookware] Shoot remote detected: " .. name)
                    logRemoteToFile(">>> SHOOT REMOTE: " .. name)
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
                    print("[Cookware] Ammo remote detected: " .. name .. " (index " .. i .. ")")
                    logRemoteToFile(">>> AMMO REMOTE: " .. name)
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
            if settings.infiniteAmmo and detectedAmmoRemote == shootRemote then
                if not settings.ammoIndex or settings.ammoIndex == 0 then
                    for i, arg in ipairs(args) do
                        if type(arg) == "number" and arg > 0 then settings.ammoIndex = i break end
                    end
                end
                if settings.ammoIndex and args[settings.ammoIndex] then
                    args[settings.ammoIndex] = 9999
                end
            end
            if settings.silentAimEnabled then
                local target = getClosestPlayerSilent()
                if target and target.Character then
                    local aimPos = getTargetPart(target, settings.silentHitPart)
                    if aimPos then
                        local direction = (aimPos - camera.CFrame.Position).Unit
                        for i, arg in ipairs(args) do
                            if isDirectionVector(arg) then args[i] = direction break end
                        end
                    end
                end
            end
            return orig(self, unpack(args))
        end
        stealthHookApplied = true
        print("[Cookware] Stealth hook applied.")
    end

    local function hookAllRemotes()
        local count = 0
        for _, obj in ipairs(replicatedStorage:GetDescendants()) do
            if (obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction")) and not remoteOriginal[obj] then
                pcall(function()
                    local orig = obj.FireServer or (obj:IsA("RemoteFunction") and obj.InvokeServer)
                    remoteOriginal[obj] = orig
                    if obj:IsA("RemoteEvent") then
                        obj.FireServer = function(self, ...)
                            onRemoteFire(self, ...)
                            return orig(self, ...)
                        end
                    else
                        obj.OnInvoke = function(self, ...)
                            onRemoteFire(self, ...)
                            return orig(self, ...)
                        end
                    end
                    count = count + 1
                end)
            end
        end
        print("[SPY] Hooked " .. count .. " remotes.")
    end

    task.wait(3)
    hookAllRemotes()
    replicatedStorage.DescendantAdded:Connect(function(obj)
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            task.wait(0.1)
            hookAllRemotes()
        end
    end)

    -- ===========================
    -- VISIBILITY CHECK
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
    -- TARGET BODY PART
    -- ===========================
    local function getTargetPart(targetPlr, partName)
        local char = targetPlr.Character
        if not char then return nil end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return nil end
        if partName == "Head" then
            local head = char:FindFirstChild("Head")
            return head and head.Position + Vector3.new(0, 0.5, 0) or root.Position + Vector3.new(0, 2, 0)
        elseif partName == "Torso" then
            local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
            return torso and torso.Position + Vector3.new(0, 0.2, 0) or root.Position + Vector3.new(0, 1.5, 0)
        elseif partName == "Feet" then
            return root.Position - Vector3.new(0, 2.5, 0)
        end
        return root.Position
    end

    -- ===========================
    -- AIM ASSIST & SILENT AIM
    -- ===========================
    local aimFOVCircle = Drawing and Drawing.new("Circle") or nil
    if aimFOVCircle then aimFOVCircle.Thickness=1; aimFOVCircle.Filled=false; aimFOVCircle.Visible=false end
    local silentFOVCircle = Drawing and Drawing.new("Circle") or nil
    if silentFOVCircle then silentFOVCircle.Thickness=1; silentFOVCircle.Filled=false; silentFOVCircle.Visible=false end

    local targetGui = Instance.new("ScreenGui")
    targetGui.Name = "CookwareTargets"
    targetGui.ResetOnSpawn = false
    targetGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    targetGui.Parent = player:WaitForChild("PlayerGui")

    local aimTargetLabel = Instance.new("TextLabel")
    aimTargetLabel.Size = UDim2.new(0, 200, 0, 20)
    aimTargetLabel.Position = UDim2.new(0.5, -100, 0.6, 0)
    aimTargetLabel.BackgroundTransparency = 1
    aimTargetLabel.TextColor3 = Color3.new(1,1,1)
    aimTargetLabel.Font = Enum.Font.SourceSansBold
    aimTargetLabel.TextSize = 14
    aimTargetLabel.Visible = false
    aimTargetLabel.Parent = targetGui

    local silentTargetLabel = Instance.new("TextLabel")
    silentTargetLabel.Size = UDim2.new(0, 200, 0, 20)
    silentTargetLabel.Position = UDim2.new(0.5, -100, 0.65, 0)
    silentTargetLabel.BackgroundTransparency = 1
    silentTargetLabel.TextColor3 = Color3.new(1,0,1)
    silentTargetLabel.Font = Enum.Font.SourceSansBold
    silentTargetLabel.TextSize = 14
    silentTargetLabel.Visible = false
    silentTargetLabel.Parent = targetGui

    local function getClosestPlayerGeneric(fov, visCheck, teamCheck, partName)
        local closest, shortest = nil, fov
        local center = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)
        for _, plr in pairs(players:GetPlayers()) do
            if plr == player then continue end
            if teamCheck and plr.Team and player.Team and plr.Team == player.Team then continue end
            local char = plr.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then continue end
            if visCheck and not isVisible(char) then continue end
            local pos = getTargetPart(plr, partName)
            if not pos then continue end
            local screenPos, onScreen = camera:WorldToViewportPoint(pos)
            if onScreen then
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                if dist < shortest then shortest = dist closest = plr end
            end
        end
        return closest
    end

    local function getClosestPlayerAim() return getClosestPlayerGeneric(settings.aimFOV, settings.aimVisibilityCheck, settings.aimTeamCheck, settings.aimHitPart) end
    local function getClosestPlayerSilent() return getClosestPlayerGeneric(settings.silentAimFOV, settings.silentAimVisibilityCheck, settings.silentAimTeamCheck, settings.silentHitPart) end
    local function getClosestPlayerTPKill() return getClosestPlayerGeneric(500, false, settings.tpKillTeamCheck, "Torso") end

    local function updateAimAssist()
        if not settings.aimAssistEnabled then
            if aimFOVCircle then aimFOVCircle.Visible = false end
            aimTargetLabel.Visible = false
        else
            local target = getClosestPlayerAim()
            if target and target.Character then
                local targetPos = getTargetPart(target, settings.aimHitPart)
                local targetCF = CFrame.lookAt(camera.CFrame.Position, targetPos)
                camera.CFrame = camera.CFrame:Lerp(targetCF, math.clamp(1 / settings.aimSmoothness, 0.01, 1))
                aimTargetLabel.Text = "AIM: " .. target.Name .. " [" .. settings.aimHitPart .. "]"
                aimTargetLabel.Visible = settings.aimShowTarget
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

        if not settings.silentAimEnabled then
            if silentFOVCircle then silentFOVCircle.Visible = false end
            silentTargetLabel.Visible = false
        else
            local target = getClosestPlayerSilent()
            if target and target.Character then
                silentTargetLabel.Text = "SILENT: " .. target.Name .. " [" .. settings.silentHitPart .. "]"
                silentTargetLabel.Visible = settings.silentAimShowTarget
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
    -- ESP – Name & Distance (BillboardGui)
    -- ===========================
    local espBills = {}
    local function removeESP(plr)
        if espBills[plr] then espBills[plr].bill:Destroy(); espBills[plr] = nil end
    end
    local function ensureESP(plr)
        if plr == player or not settings.espEnabled then return end
        if espBills[plr] then return end
        local char = plr.Character
        if not char or not char:FindFirstChild("Head") then return end
        local bill = Instance.new("BillboardGui")
        bill.Adornee = char.Head
        bill.StudsOffset = Vector3.new(0, 2.5, 0)
        bill.Size = UDim2.new(0, 200, 0, 24)
        bill.AlwaysOnTop = true
        bill.Enabled = true
        bill.Parent = char.Head
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
            if not plr.Parent or not plr.Character or not plr.Character:FindFirstChild("Head") then
                data.bill:Destroy(); espBills[plr] = nil
            else
                local root = plr.Character:FindFirstChild("HumanoidRootPart")
                local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                if hum and root then
                    local dist = (camera.CFrame.Position - root.Position).Magnitude
                    data.label.Text = plr.Name .. " | " .. math.floor(dist) .. "m"
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
        plr.CharacterAdded:Connect(function(char)
            local head = char:WaitForChild("Head", 5)
            if head then
                removeESP(plr)
                if settings.espEnabled then ensureESP(plr) end
            end
        end)
        if settings.espEnabled then
            if plr.Character and plr.Character:FindFirstChild("Head") then
                ensureESP(plr)
            end
        end
    end)
    players.PlayerRemoving:Connect(removeESP)

    -- ===========================
    -- VISUALS (Outline, Chams, Skeleton, BigHead)
    -- ===========================
    local drawingAvailable = Drawing ~= nil
    if not drawingAvailable then
        warn("Drawing library not available; outlines/chams will use Highlight fallback.")
    end

    local outlineObjects = {}
    local chamObjects = {}
    local skeletonLines = {}
    local bigHeadObjects = {}

    local function getScreenBounds(character)
        local root = character:FindFirstChild("HumanoidRootPart")
        local head = character:FindFirstChild("Head")
        if not root or not head then return nil end
        local top = camera:WorldToViewportPoint(head.Position + Vector3.new(0, 1.8, 0))
        local bottom = camera:WorldToViewportPoint(root.Position - Vector3.new(0, 2.5, 0))
        if top.Z < 0 or bottom.Z < 0 then return nil end
        return Vector2.new(top.X, top.Y), Vector2.new(bottom.X, bottom.Y)
    end

    local function updateOutline()
        if not settings.playerOutlineEnabled then
            for plr, obj in pairs(outlineObjects) do
                if drawingAvailable then for _, d in ipairs(obj) do d:Remove() end else obj:Destroy() end
                outlineObjects[plr] = nil
            end
            return
        end
        local col = Color3.new(settings.outlineColorR, settings.outlineColorG, settings.outlineColorB)
        for _, plr in pairs(players:GetPlayers()) do
            if plr == player then continue end
            local char = plr.Character
            if char then
                local top, bottom = getScreenBounds(char)
                if top and bottom then
                    local size = Vector2.new(math.abs(bottom.X - top.X), math.abs(bottom.Y - top.Y))
                    local pos = Vector2.new(math.min(top.X, bottom.X), math.min(top.Y, bottom.Y))
                    if drawingAvailable then
                        if not outlineObjects[plr] then
                            outlineObjects[plr] = { Drawing.new("Square"), Drawing.new("Square") }
                            for _, box in ipairs(outlineObjects[plr]) do
                                box.Thickness = 2; box.Filled = false; box.ZIndex = 100; box.Visible = false
                            end
                        end
                        for _, box in ipairs(outlineObjects[plr]) do
                            box.Size = size; box.Position = pos; box.Color = col; box.Visible = true
                        end
                    else
                        if not outlineObjects[plr] then
                            local hl = Instance.new("Highlight")
                            hl.FillTransparency = 1
                            hl.OutlineTransparency = 0
                            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                            hl.Enabled = true
                            hl.Adornee = char
                            hl.Parent = workspace
                            outlineObjects[plr] = hl
                        end
                        outlineObjects[plr].OutlineColor = col
                    end
                else
                    if outlineObjects[plr] then
                        if drawingAvailable then for _, d in ipairs(outlineObjects[plr]) do d.Visible = false end end
                    end
                end
            else
                if outlineObjects[plr] then
                    if drawingAvailable then for _, d in ipairs(outlineObjects[plr]) do d:Remove() end else outlineObjects[plr]:Destroy() end
                    outlineObjects[plr] = nil
                end
            end
        end
    end

    local function updateChams()
        if not settings.chamsEnabled then
            for plr, obj in pairs(chamObjects) do
                if drawingAvailable then for _, d in ipairs(obj) do d:Remove() end else obj:Destroy() end
                chamObjects[plr] = nil
            end
            return
        end
        local col = Color3.new(settings.chamsColorR, settings.chamsColorG, settings.chamsColorB)
        for _, plr in pairs(players:GetPlayers()) do
            if plr == player then continue end
            local char = plr.Character
            if char then
                local top, bottom = getScreenBounds(char)
                if top and bottom then
                    local size = Vector2.new(math.abs(bottom.X - top.X), math.abs(bottom.Y - top.Y))
                    local pos = Vector2.new(math.min(top.X, bottom.X), math.min(top.Y, bottom.Y))
                    if drawingAvailable then
                        if not chamObjects[plr] then
                            chamObjects[plr] = { Drawing.new("Square"), Drawing.new("Square") }
                            for _, box in ipairs(chamObjects[plr]) do
                                box.Thickness = 0; box.Filled = true; box.Transparency = 0.6; box.ZIndex = 99; box.Visible = false
                            end
                        end
                        for _, box in ipairs(chamObjects[plr]) do
                            box.Size = size; box.Position = pos; box.Color = col; box.Visible = true
                        end
                    else
                        if not chamObjects[plr] then
                            local hl = Instance.new("Highlight")
                            hl.FillTransparency = 0.4
                            hl.OutlineTransparency = 1
                            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                            hl.Enabled = true
                            hl.Adornee = char
                            hl.Parent = workspace
                            chamObjects[plr] = hl
                        end
                        chamObjects[plr].FillColor = col
                    end
                else
                    if chamObjects[plr] then
                        if drawingAvailable then for _, d in ipairs(chamObjects[plr]) do d.Visible = false end end
                    end
                end
            else
                if chamObjects[plr] then
                    if drawingAvailable then for _, d in ipairs(chamObjects[plr]) do d:Remove() end else chamObjects[plr]:Destroy() end
                    chamObjects[plr] = nil
                end
            end
        end
    end

    local function updateSkeleton()
        if not drawingAvailable then return end
        if not settings.skeletonEnabled then
            for plr, lines in pairs(skeletonLines) do
                for _, l in ipairs(lines) do l.Visible = false end
            end
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
                    line.Thickness = 2; line.ZIndex = 100; line.Visible = false
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

    local function updateBigHead()
        if not settings.bigHeadEnabled then
            for plr, hl in pairs(bigHeadObjects) do hl:Destroy() end
            bigHeadObjects = {}
            return
        end
        local col = Color3.new(settings.bigHeadOutlineR, settings.bigHeadOutlineG, settings.bigHeadOutlineB)
        for _, plr in pairs(players:GetPlayers()) do
            if plr == player then continue end
            local char = plr.Character
            if char and char:FindFirstChild("Head") then
                local head = char.Head
                pcall(function() head.Size = Vector3.new(settings.bigHeadSize, settings.bigHeadSize, settings.bigHeadSize) end)
                if not bigHeadObjects[plr] then
                    local hl = Instance.new("Highlight")
                    hl.FillTransparency = 1
                    hl.OutlineTransparency = 0
                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    hl.Enabled = true
                    hl.Adornee = head
                    hl.Parent = workspace
                    bigHeadObjects[plr] = hl
                end
                bigHeadObjects[plr].OutlineColor = col
            else
                if bigHeadObjects[plr] then
                    bigHeadObjects[plr]:Destroy()
                    bigHeadObjects[plr] = nil
                end
            end
        end
        for plr, hl in pairs(bigHeadObjects) do
            if not plr.Parent or not plr.Character or not plr.Character:FindFirstChild("Head") then
                hl:Destroy()
                bigHeadObjects[plr] = nil
            end
        end
    end

    -- ===========================
    -- TP KILL (fixed teleport)
    -- ===========================
    local tpKillConn = nil
    local tpKillButton = nil
    local function createTPKillButton()
        if tpKillButton then tpKillButton:Destroy() end
        tpKillButton = Instance.new("TextButton")
        tpKillButton.Size = UDim2.new(0, 80, 0, 40)
        tpKillButton.Position = UDim2.new(0, 5, 0.5, -20)
        tpKillButton.BackgroundColor3 = Color3.fromRGB(200,0,0)
        tpKillButton.BackgroundTransparency = 0.3
        tpKillButton.Text = "TP KILL"
        tpKillButton.TextColor3 = Color3.new(1,1,1)
        tpKillButton.Font = Enum.Font.GothamBold
        tpKillButton.TextSize = 14
        tpKillButton.ZIndex = 10
        tpKillButton.Parent = screenGui
        tpKillButton.Activated:Connect(performTPKill)
    end
    local function performTPKill()
        local target = getClosestPlayerTPKill()
        if not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then
            print("[TP KILL] No valid target found.")
            return
        end
        local targetRoot = target.Character.HumanoidRootPart
        local myChar = player.Character
        if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
        local myRoot = myChar.HumanoidRootPart
        myRoot.CFrame = targetRoot.CFrame + targetRoot.CFrame.LookVector * 3
        task.wait(0.05)
        local tool = player.Backpack:FindFirstChildOfClass("Tool") or player.Character:FindFirstChildOfClass("Tool")
        if tool then
            tool:Activate()
            task.wait(0.1)
            tool:Deactivate()
            print("[TP KILL] Attacked " .. target.Name)
        else
            print("[TP KILL] No tool equipped.")
        end
    end
    local function startTPKill()
        if tpKillConn then tpKillConn:Disconnect() end
        tpKillConn = userInput.InputBegan:Connect(function(input, gp)
            if gp then return end
            if input.KeyCode == settings.tpKillKey then performTPKill() end
        end)
        createTPKillButton()
    end
    local function stopTPKill()
        if tpKillConn then tpKillConn:Disconnect(); tpKillConn = nil end
        if tpKillButton then tpKillButton:Destroy(); tpKillButton = nil end
    end

    -- ===========================
    -- CAMERA (FOV lock improved)
    -- ===========================
    local function updateCamera()
        if settings.lockFOV and math.abs(camera.FieldOfView - settings.cameraFOV) > 2 then
            camera.FieldOfView = settings.cameraFOV
        end
        if settings.aspectRatioEnabled then
            camera.CFrame = camera.CFrame * CFrame.new(0,0,0, 1,0,0, 0,settings.aspectRatioValue,0, 0,0,1)
        end
    end

    -- ===========================
    -- WEBHOOK (every 10 minutes)
    -- ===========================
    local function getActiveFeatures()
        local list = {}
        for k, v in pairs(settings) do if type(v) == "boolean" and v then table.insert(list, k) end end
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
                        {name = "Active Features", value = getActiveFeatures(), inline = false},
                        {name = "Time", value = os.date("%Y-%m-%d %H:%M:%S"), inline = false}
                    },
                    footer = {text = "Cookware Injection Logger"}
                }
                local payload = httpService:JSONEncode({embeds = {embed}})
                if syn and syn.request then
                    syn.request({Url = webhookURL, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = payload})
                elseif http_request then
                    http_request({Url = webhookURL, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = payload})
                end
            end)
        end)
    end
    sendWebhook(true)
    task.spawn(function() while true do task.wait(600) sendWebhook(false) end end)

    -- ===========================
    -- UI (with overlay)
    -- ===========================
    task.wait(1)
    local parentGui = player:FindFirstChild("PlayerGui") or game:GetService("CoreGui")
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CookwareMenu"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = parentGui

    -- Overlay for FPS/Ping/HWID
    local overlayFrame = Instance.new("Frame")
    overlayFrame.Size = UDim2.new(0, 200, 0, 70)
    overlayFrame.Position = UDim2.new(0, 10, 0, 10)
    overlayFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    overlayFrame.BackgroundTransparency = 0.5
    overlayFrame.BorderSizePixel = 0
    overlayFrame.ZIndex = 100
    overlayFrame.Parent = screenGui
    local overlayLayout = Instance.new("UIListLayout", overlayFrame)
    overlayLayout.Padding = UDim.new(0, 2)
    overlayLayout.FillDirection = Enum.FillDirection.Vertical
    overlayLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    overlayLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    overlayLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local function addOverlayLabel(text)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -10, 0, 20)
        lbl.Position = UDim2.new(0, 5, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        lbl.Font = Enum.Font.SourceSansBold
        lbl.TextSize = 14
        lbl.Text = text
        lbl.Parent = overlayFrame
        return lbl
    end

    local fpsLabel = addOverlayLabel("FPS: --")
    local pingLabel = addOverlayLabel("Ping: --")
    local hwidLabel = addOverlayLabel("HWID: " .. currentHWID)

    -- FPS counter
    local fps = 0
    local frameCount = 0
    local lastTime = tick()
    runService.RenderStepped:Connect(function()
        frameCount = frameCount + 1
        if tick() - lastTime >= 1 then
            fps = frameCount
            frameCount = 0
            lastTime = tick()
            fpsLabel.Text = "FPS: " .. fps
        end
    end)

    -- Ping
    task.spawn(function()
        while true do
            task.wait(2)
            local ping = 0
            pcall(function()
                local network = stats:FindFirstChild("Network") or stats:FindFirstChild("PerformanceStats")
                if network then
                    local serverStats = network:FindFirstChild("ServerStatsItem") or network:FindFirstChild("Server")
                    if serverStats and serverStats:FindFirstChild("DataPing") then
                        ping = serverStats.DataPing:GetValue() * 1000
                    end
                end
            end)
            if ping == 0 then
                local start = tick()
                pcall(function() game:GetService("ReplicatedStorage"):WaitForChild("NonExistent", 0.05) end)
                ping = math.floor((tick() - start) * 1000)
            end
            pingLabel.Text = "Ping: " .. tostring(ping) .. "ms"
        end
    end)

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

    local function makeDraggable(gui, lockSetting)
        local dragging, dragInput, dragStart, startPos
        gui.InputBegan:Connect(function(input)
            if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and not lockSetting then
                dragging = true; dragStart = input.Position; startPos = gui.Position
                input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
            end
        end)
        gui.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end)
        userInput.InputChanged:Connect(function(input)
            if dragging and input == dragInput then
                local delta = input.Position - dragStart
                gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
    end
    makeDraggable(toggleBtn, settings.lockToggleUI)
    makeDraggable(mainFrame, settings.lockUI)

    local tabNames = {"ESP", "AIM", "WEAPONS", "RAGE", "UI", "MISC"}
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
        btn.Size = UDim2.new(0, 60, 0, 30)
        btn.Position = UDim2.new(0, (i-1)*62, 0, 30)
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

    local function addToggle(tabIdx, text, settingName, callback)
        local frame = tabFrames[tabIdx]
        elementCounts[tabIdx] = elementCounts[tabIdx] + 1
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 340, 0, 35)
        btn.LayoutOrder = elementCounts[tabIdx]
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
            if settingName == "espEnabled" then setESPEnabled(settings.espEnabled)
            elseif settingName == "playerOutlineEnabled" then updateOutline()
            elseif settingName == "chamsEnabled" then updateChams()
            elseif settingName == "skeletonEnabled" then updateSkeleton()
            elseif settingName == "bigHeadEnabled" then updateBigHead()
            elseif settingName == "tpKillEnabled" then
                if settings.tpKillEnabled then startTPKill() else stopTPKill() end
            end
        end)
    end

    local function addSlider(tabIdx, text, settingName, min, max, step, callback)
        local frame = tabFrames[tabIdx]
        elementCounts[tabIdx] = elementCounts[tabIdx] + 1
        local cont = Instance.new("Frame")
        cont.Size = UDim2.new(0, 340, 0, 40)
        cont.LayoutOrder = elementCounts[tabIdx]
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

    -- Fixed color picker
    local function addColorPicker(tabIdx, titleText, rKey, gKey, bKey, callback)
        local frame = tabFrames[tabIdx]
        elementCounts[tabIdx] = elementCounts[tabIdx] + 1
        local cont = Instance.new("Frame")
        cont.Size = UDim2.new(0, 340, 0, 150)
        cont.LayoutOrder = elementCounts[tabIdx]
        cont.BackgroundColor3 = Color3.fromRGB(50,50,50)
        cont.Parent = frame

        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(0, 200, 0, 18)
        title.Position = UDim2.new(0, 5, 0, 2)
        title.BackgroundTransparency = 1
        title.Text = titleText
        title.TextColor3 = Color3.fromRGB(255,255,255)
        title.Font = Enum.Font.SourceSansBold
        title.TextSize = 13
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Parent = cont

        local hueBar = Instance.new("ImageButton")
        hueBar.Size = UDim2.new(0, 280, 0, 20)
        hueBar.Position = UDim2.new(0, 10, 0, 25)
        hueBar.Image = "rbxassetid://7488764949"
        hueBar.BackgroundTransparency = 1
        hueBar.Parent = cont
        local hueSelector = Instance.new("Frame")
        hueSelector.Size = UDim2.new(0, 4, 0, 20)
        hueSelector.BackgroundColor3 = Color3.new(1,1,1)
        hueSelector.BorderSizePixel = 0
        hueSelector.AnchorPoint = Vector2.new(0.5, 0)
        hueSelector.Parent = hueBar

        local brightBar = Instance.new("Frame")
        brightBar.Size = UDim2.new(0, 280, 0, 20)
        brightBar.Position = UDim2.new(0, 10, 0, 55)
        brightBar.BackgroundColor3 = Color3.new(1,1,1)
        brightBar.Parent = cont
        local brightGradient = Instance.new("UIGradient", brightBar)
        brightGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0,0,0)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255))
        })
        local brightSelector = Instance.new("Frame")
        brightSelector.Size = UDim2.new(0, 4, 0, 20)
        brightSelector.BackgroundColor3 = Color3.new(1,1,1)
        brightSelector.BorderSizePixel = 0
        brightSelector.AnchorPoint = Vector2.new(0.5, 0)
        brightSelector.Parent = brightBar
        local brightButton = Instance.new("TextButton")
        brightButton.Size = UDim2.new(1,0,1,0)
        brightButton.BackgroundTransparency = 1
        brightButton.Text = ""
        brightButton.Parent = brightBar

        local preview = Instance.new("Frame")
        preview.Size = UDim2.new(0, 40, 0, 40)
        preview.Position = UDim2.new(1, -45, 0, 90)
        preview.BackgroundColor3 = Color3.new(settings[rKey], settings[gKey], settings[bKey])
        preview.Parent = cont
        Instance.new("UICorner", preview).CornerRadius = UDim.new(0,8)

        local currentHue = 0
        local currentBrightness = 1

        local function updatePreview()
            local c = Color3.fromHSV(currentHue, 1, currentBrightness)
            preview.BackgroundColor3 = c
            settings[rKey] = c.r
            settings[gKey] = c.g
            settings[bKey] = c.b
            if callback then callback() end
        end

        local initR, initG, initB = settings[rKey], settings[gKey], settings[bKey]
        local h, s, v = Color3.toHSV(Color3.new(initR, initG, initB))
        currentHue = h
        currentBrightness = v
        hueSelector.Position = UDim2.new(currentHue, 0, 0, 0)
        brightSelector.Position = UDim2.new(currentBrightness, 0, 0, 0)
        updatePreview()

        local function onHueInput(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                local pos = input.Position.X - hueBar.AbsolutePosition.X
                currentHue = math.clamp(pos / hueBar.AbsoluteSize.X, 0, 1)
                hueSelector.Position = UDim2.new(currentHue, 0, 0, 0)
                updatePreview()
            end
        end
        hueBar.InputBegan:Connect(onHueInput)
        hueBar.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                if input.UserInputState == Enum.UserInputState.Change then onHueInput(input) end
            end
        end)

        local function onBrightInput(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                local pos = input.Position.X - brightBar.AbsolutePosition.X
                currentBrightness = math.clamp(pos / brightBar.AbsoluteSize.X, 0, 1)
                brightSelector.Position = UDim2.new(currentBrightness, 0, 0, 0)
                updatePreview()
            end
        end
        brightButton.InputBegan:Connect(onBrightInput)
        brightButton.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                if input.UserInputState == Enum.UserInputState.Change then onBrightInput(input) end
            end
        end)
    end

    local function addSeparator(tabIdx, text)
        local frame = tabFrames[tabIdx]
        elementCounts[tabIdx] = elementCounts[tabIdx] + 1
        local sep = Instance.new("TextLabel")
        sep.Size = UDim2.new(0, 340, 0, 25)
        sep.LayoutOrder = elementCounts[tabIdx]
        sep.BackgroundTransparency = 1
        sep.Text = text
        sep.TextColor3 = Color3.fromRGB(200,200,200)
        sep.Font = Enum.Font.SourceSansBold
        sep.TextSize = 12
        sep.Parent = frame
    end

    local function addDropdown(tabIdx, text, settingName, options, callback)
        local frame = tabFrames[tabIdx]
        elementCounts[tabIdx] = elementCounts[tabIdx] + 1
        local cont = Instance.new("Frame")
        cont.Size = UDim2.new(0, 340, 0, 40)
        cont.LayoutOrder = elementCounts[tabIdx]
        cont.BackgroundColor3 = Color3.fromRGB(50,50,50)
        cont.Parent = frame
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0, 140, 1, 0)
        label.Position = UDim2.new(0, 5, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text .. ": " .. settings[settingName]
        label.TextColor3 = Color3.fromRGB(255,255,255)
        label.Font = Enum.Font.SourceSans
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = cont
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 120, 0, 30)
        btn.Position = UDim2.new(0, 200, 0, 5)
        btn.Text = "Cycle"
        btn.BackgroundColor3 = Color3.fromRGB(80,80,80)
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 12
        btn.Parent = cont
        local idx = table.find(options, settings[settingName]) or 1
        btn.Activated:Connect(function()
            idx = idx % #options + 1
            settings[settingName] = options[idx]
            label.Text = text .. ": " .. settings[settingName]
            if callback then callback(settings[settingName]) end
        end)
    end

    -- ================= POPULATE TABS =================
    addSeparator(1, "──── ESP ────")
    addToggle(1, "ESP Master", "espEnabled")
    addToggle(1, "Player Outline", "playerOutlineEnabled")
    addColorPicker(1, "Outline Color", "outlineColorR", "outlineColorG", "outlineColorB", updateOutline)
    addToggle(1, "Chams", "chamsEnabled")
    addColorPicker(1, "Chams Color", "chamsColorR", "chamsColorG", "chamsColorB", updateChams)
    addToggle(1, "Skeleton", "skeletonEnabled")
    addColorPicker(1, "Skeleton Color", "skeletonColorR", "skeletonColorG", "skeletonColorB", updateSkeleton)

    addSeparator(2, "──── AIM ASSIST ────")
    addToggle(2, "Aim Assist", "aimAssistEnabled")
    addSlider(2, "FOV", "aimFOV", 20, 500, 10)
    addSlider(2, "Smoothness", "aimSmoothness", 1, 20, 1)
    addDropdown(2, "Target Part", "aimHitPart", {"Head", "Torso", "Feet"})
    addToggle(2, "Visibility Check", "aimVisibilityCheck")
    addToggle(2, "Team Check", "aimTeamCheck")
    addToggle(2, "Show FOV Circle", "aimShowFOV")
    addColorPicker(2, "FOV Color", "aimFOVColorR", "aimFOVColorG", "aimFOVColorB")
    addToggle(2, "Show Aim Target", "aimShowTarget")
    addSeparator(2, "──── SILENT AIM ────")
    addToggle(2, "Silent Aim", "silentAimEnabled")
    addSlider(2, "Silent FOV", "silentAimFOV", 20, 500, 10)
    addDropdown(2, "Silent Target", "silentHitPart", {"Head", "Torso", "Feet"})
    addToggle(2, "Silent Vis Check", "silentAimVisibilityCheck")
    addToggle(2, "Silent Team Check", "silentAimTeamCheck")
    addToggle(2, "Show Silent FOV", "silentAimShowFOV")
    addColorPicker(2, "Silent FOV Color", "silentAimFOVColorR", "silentAimFOVColorG", "silentAimFOVColorB")
    addToggle(2, "Show Silent Target", "silentAimShowTarget")

    addSeparator(3, "──── WEAPONS ────")
    addToggle(3, "Infinite Ammo", "infiniteAmmo")
    addSlider(3, "Recoil Reduction", "recoilReduction", 0, 100, 5)
    addSlider(3, "Spread Reduction", "spreadReduction", 0, 100, 5)

    addSeparator(4, "──── RAGE ────")
    addToggle(4, "Big Head", "bigHeadEnabled")
    addSlider(4, "Head Size", "bigHeadSize", 1, 10, 1)
    addColorPicker(4, "BigHead Outline", "bigHeadOutlineR", "bigHeadOutlineG", "bigHeadOutlineB", updateBigHead)
    addToggle(4, "TP Kill", "tpKillEnabled")
    addToggle(4, "TP Kill Team Check", "tpKillTeamCheck")
    addSeparator(4, "──── CAMERA ────")
    addSlider(4, "Camera FOV", "cameraFOV", 30, 120, 1)
    addToggle(4, "Lock FOV", "lockFOV")
    addToggle(4, "Aspect Ratio", "aspectRatioEnabled")
    addSlider(4, "Stretch", "aspectRatioValue", 0.1, 2, 0.05, updateCamera)

    addSeparator(5, "──── UI ────")
    addColorPicker(5, "UI Color", "uiColorR", "uiColorG", "uiColorB", applyFullUIColor)

    addSeparator(6, "──── MISC ────")
    addToggle(6, "Mod Auto-Disable", "modAutoDisable")
    addToggle(6, "Mod Notify", "modDetectionEnabled")
    addToggle(6, "Lock Main Window", "lockUI")
    addToggle(6, "Lock Toggle Button", "lockToggleUI")

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
        updateOutline()
        updateChams()
        updateSkeleton()
        updateBigHead()
        updateAimAssist()
        updateCamera()
    end)

    player.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        if settings.espEnabled then for _, plr in pairs(players:GetPlayers()) do ensureESP(plr) end end
        if settings.playerOutlineEnabled then updateOutline() end
        if settings.chamsEnabled then updateChams() end
        if settings.skeletonEnabled then updateSkeleton() end
        if settings.bigHeadEnabled then updateBigHead() end
    end)

    camera.FieldOfView = settings.cameraFOV

    print("Cookware v21.8 – Whitelist debug active.")
    pcall(function()
        starterGui:SetCore("SendNotification",{Title="cookware v21.8",Text="Whitelist check logged.",Duration=5})
    end)
end)