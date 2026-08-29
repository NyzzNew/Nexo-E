--[[
    NEXO E — MM2 Suite v2.4 Overdrive (Ultra Stable + Modern UI)
    Full feature set: 40+ features
    Otimizado para performance e compatibilidade
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")

-- ─── VARIÁVEIS GLOBAIS ───────────────────────────────────────
local alarmGui = nil
local timerGui = nil
local ScreenGui = nil
local scriptRunning = true
local originalHitboxes = {}
local lastKnownPosition = Vector3.new(0, 0, 0)
local roundStartTime = 0
local espObjects = {}
local boxObjects = {}
local tracerObjects = {}
local chamObjects = {}
local outlineObjects = {}
local connections = {}
local isMobile = UserInputService.TouchEnabled
local lastNotify = 0
local notificationFallback = false
local fpsBoostActive = false
local optimizeCoinsActive = false
local speedGlitchActive = false
local speedActive = false
local flyActive = false
local noclipActive = false
local invisibleActive = false
local hitboxActive = false
local fullbrightActive = false
local noShadowsActive = false
local murderAlarmActive = false
local roundTimerActive = false
local antiAfkActive = false
local autoDodgeActive = false
local antiFlingActive = false
local coinFarmActive = false
local coinAuraActive = false
local autoGrabGunActive = false
local gunDropNotifyActive = false
local silentAimActive = false
local knifeAimActive = false
local gunAuraActive = false
local knifeAuraActive = false
local espActive = false
local espBoxActive = false
local tracersActive = false
local chamActive = false
local outlineActive = false
local displayDistanceActive = false
local autoExposeActive = false

-- ─── STEALTH UTILS ────────────────────────────────────────────
local function getProtectedParent()
    local success, result = pcall(function()
        if gethui then return gethui() end
        if syn and syn.protect_gui then
            local g = Instance.new("ScreenGui")
            syn.protect_gui(g)
            return g
        end
        if protect_gui then
            local g = Instance.new("ScreenGui")
            protect_gui(g)
            return g
        end
        return game:GetService("CoreGui")
    end)
    if not success or not result then
        return Instance.new("ScreenGui")
    end
    return result
end

local function randomName()
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local s = ""
    for i = 1, math.random(8, 16) do
        s = s .. chars:sub(math.random(1, #chars), math.random(1, #chars))
    end
    return s
end

local function notify(title, text, duration)
    if not notificationFallback then
        local success = pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = title,
                Text = text,
                Duration = duration or 3
            })
        end)
        if not success then
            notificationFallback = true
        end
    end
    
    if notificationFallback then
        pcall(function()
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(0, 300, 0, 60)
            frame.Position = UDim2.new(0.5, -150, 0, 10)
            frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
            frame.BackgroundTransparency = 0.1
            frame.BorderSizePixel = 0
            frame.Parent = ScreenGui or getProtectedParent()
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.Text = title .. "\n" .. text
            label.TextColor3 = Color3.fromRGB(255, 255, 255)
            label.Font = Enum.Font.GothamBold
            label.TextSize = 14
            label.Parent = frame
            
            task.wait(duration or 3)
            frame:Destroy()
        end)
    end
end

-- ─── SAFE UTILS ──────────────────────────────────────────────
local function safeConnect(obj, event, callback)
    local conn
    conn = obj[event]:Connect(function(...)
        if not scriptRunning then
            if conn then conn:Disconnect() end
            return
        end
        pcall(callback, ...)
    end)
    return conn
end

local function safeCall(fn, ...)
    local success, result = pcall(fn, ...)
    if not success then
        warn("[NEXO E] Error: " .. tostring(result))
    end
    return success, result
end

-- ─── COLORS ───────────────────────────────────────────────────
local ACCENT = Color3.fromRGB(150, 80, 255)
local ACCENT_LIGHT = Color3.fromRGB(200, 120, 255)
local ACCENT_DIM = Color3.fromRGB(45, 30, 65)
local BG = Color3.fromRGB(18, 18, 24)
local BG_SIDE = Color3.fromRGB(14, 14, 20)
local BG_CARD = Color3.fromRGB(28, 28, 36)
local BG_HOVER = Color3.fromRGB(38, 38, 48)
local BG_GLASS = Color3.fromRGB(22, 22, 30)
local TEXT = Color3.fromRGB(245, 245, 255)
local TEXT_DIM = Color3.fromRGB(150, 150, 165)
local TEXT_MUTED = Color3.fromRGB(100, 100, 115)
local TOGGLE_OFF = Color3.fromRGB(45, 45, 55)
local DANGER = Color3.fromRGB(255, 80, 100)
local SUCCESS = Color3.fromRGB(80, 200, 120)

local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 10)
    c.Parent = parent
    return c
end

local function stroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or ACCENT_DIM
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0.5
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

local function gradient(parent, color1, color2, rotation)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new(color1, color2)
    g.Rotation = rotation or 0
    g.Parent = parent
    return g
end

local function padding(parent, top, bottom, left, right)
    local p = Instance.new("UIPadding")
    p.PaddingTop = UDim.new(0, top or 0)
    p.PaddingBottom = UDim.new(0, bottom or 0)
    p.PaddingLeft = UDim.new(0, left or 0)
    p.PaddingRight = UDim.new(0, right or 0)
    p.Parent = parent
    return p
end

-- ─── ROLES ────────────────────────────────────────────────────
local function getRole(player)
    if not player or not player.Character then return "Innocent" end
    for _, tool in ipairs(player.Character:GetChildren()) do
        if tool:IsA("Tool") then
            local n = tool.Name:lower()
            if n:match("knife") or n:match("blade") or n:match("dagger") or n:match("sword") then return "Murderer" end
            if n:match("gun") or n:match("revolver") or n:match("pistol") or n:match("shooter") or n:match("rifle") then return "Sheriff" end
        end
    end
    local bp = player:FindFirstChild("Backpack")
    if bp then
        for _, tool in ipairs(bp:GetChildren()) do
            if tool:IsA("Tool") then
                local n = tool.Name:lower()
                if n:match("knife") or n:match("blade") or n:match("dagger") or n:match("sword") then return "Murderer" end
                if n:match("gun") or n:match("revolver") or n:match("pistol") or n:match("shooter") or n:match("rifle") then return "Sheriff" end
            end
        end
    end
    return "Innocent"
end

local function getMurderer()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and getRole(p) == "Murderer" then return p end
    end
    return nil
end

local function getSheriff()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and getRole(p) == "Sheriff" then return p end
    end
    return nil
end

local function getNearestPlayer(roleFilter)
    local char = LocalPlayer.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local nearest, bestDist = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and getRole(p) == roleFilter and p.Character then
            local tHrp = p.Character:FindFirstChild("HumanoidRootPart")
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if tHrp and hum and hum.Health > 0 then
                local d = (tHrp.Position - hrp.Position).Magnitude
                if d < bestDist then bestDist = d; nearest = p end
            end
        end
    end
    return nearest
end

local function hasTool(name)
    local char = LocalPlayer.Character
    if not char then return false end
    for _, t in ipairs(char:GetChildren()) do
        if t:IsA("Tool") and t.Name:lower():match(name) then return t end
    end
    return false
end

-- ─── VISUALS (OTIMIZADO) ──────────────────────────────────────
local roleColors = {
    Murderer = Color3.fromRGB(255, 70, 70),
    Sheriff = Color3.fromRGB(70, 130, 255),
    Innocent = Color3.fromRGB(100, 230, 130),
}

local function clearAllVisuals()
    for _, v in pairs(espObjects) do
        if v and type(v) == "table" then
            if v.hl then pcall(v.hl.Destroy, v.hl) end
            if v.tag then pcall(v.tag.Destroy, v.tag) end
        end
    end
    for _, v in pairs(boxObjects) do if v and v.Parent then pcall(v.Destroy, v) end end
    for _, v in pairs(tracerObjects) do if v and v.Parent then pcall(v.Destroy, v) end end
    for _, v in pairs(chamObjects) do if v and v.Parent then pcall(v.Destroy, v) end end
    for _, v in pairs(outlineObjects) do if v and v.Parent then pcall(v.Destroy, v) end end
    espObjects = {}; boxObjects = {}; tracerObjects = {}; chamObjects = {}; outlineObjects = {}
end

local function updateVisuals()
    if not espActive and not espBoxActive and not tracersActive and not chamActive and not outlineActive then
        clearAllVisuals()
        return
    end
    
    local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local cam = Workspace.CurrentCamera
    if not cam then return end
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                local role = getRole(p)
                local col = roleColors[role] or Color3.new(1, 1, 1)
                
                -- ESP (otimizado)
                if espActive then
                    if not espObjects[p] or not espObjects[p].hl or not espObjects[p].hl.Parent then
                        if espObjects[p] then
                            if espObjects[p].hl then pcall(espObjects[p].hl.Destroy, espObjects[p].hl) end
                            if espObjects[p].tag then pcall(espObjects[p].tag.Destroy, espObjects[p].tag) end
                        end
                        local hl = Instance.new("Highlight")
                        hl.Name = randomName()
                        hl.FillTransparency = 0.6
                        hl.FillColor = col
                        hl.OutlineColor = col
                        hl.OutlineTransparency = 0
                        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        hl.Parent = p.Character
                        
                        local tag = Instance.new("BillboardGui")
                        tag.Name = randomName()
                        tag.Size = UDim2.new(0, 140, 0, 28)
                        tag.StudsOffset = Vector3.new(0, 3, 0)
                        tag.AlwaysOnTop = true
                        tag.Parent = hrp
                        
                        local lbl = Instance.new("TextLabel")
                        lbl.Name = randomName()
                        lbl.Size = UDim2.new(1, 0, 1, 0)
                        lbl.BackgroundTransparency = 1
                        lbl.Font = Enum.Font.GothamMedium
                        lbl.TextSize = 11
                        lbl.TextColor3 = col
                        lbl.Parent = tag
                        
                        espObjects[p] = { hl = hl, tag = tag, lbl = lbl }
                    end
                    local e = espObjects[p]
                    e.hl.FillColor = col
                    e.hl.OutlineColor = col
                    e.hl.Parent = p.Character
                    e.tag.Parent = hrp
                    local dist = myHrp and math.floor((hrp.Position - myHrp.Position).Magnitude) or 0
                    e.lbl.Text = p.Name .. "  " .. role .. (displayDistanceActive and ("  " .. dist .. "m") or "")
                    e.lbl.TextColor3 = col
                else
                    if espObjects[p] then
                        if espObjects[p].hl then pcall(espObjects[p].hl.Destroy, espObjects[p].hl) end
                        if espObjects[p].tag then pcall(espObjects[p].tag.Destroy, espObjects[p].tag) end
                        espObjects[p] = nil
                    end
                end
                
                -- ESP Box (otimizado)
                if espBoxActive then
                    if not boxObjects[p] or not boxObjects[p].Parent then
                        local box = Instance.new("BillboardGui")
                        box.Name = randomName()
                        box.Size = UDim2.new(0, 120, 0, 140)
                        box.AlwaysOnTop = true
                        box.Parent = hrp
                        local f = Instance.new("Frame")
                        f.Name = randomName()
                        f.Size = UDim2.new(1, 0, 1, 0)
                        f.BackgroundTransparency = 1
                        f.Parent = box
                        local s = Instance.new("UIStroke")
                        s.Color = col
                        s.Thickness = 2
                        s.Parent = f
                        boxObjects[p] = box
                    end
                    boxObjects[p].Parent = hrp
                else
                    if boxObjects[p] then pcall(boxObjects[p].Destroy, boxObjects[p]); boxObjects[p] = nil end
                end
                
                -- Tracers (otimizado)
                if tracersActive and ScreenGui then
                    if not tracerObjects[p] or not tracerObjects[p].Parent then
                        local line = Instance.new("Frame")
                        line.Name = randomName()
                        line.BackgroundColor3 = col
                        line.BorderSizePixel = 0
                        line.AnchorPoint = Vector2.new(0.5, 0.5)
                        line.Parent = ScreenGui
                        tracerObjects[p] = line
                    end
                    local line = tracerObjects[p]
                    line.BackgroundColor3 = col
                    local sp, onScreen = pcall(function()
                        return cam:WorldToViewportPoint(hrp.Position)
                    end)
                    local centerX = cam.ViewportSize.X / 2
                    local centerY = cam.ViewportSize.Y / 2
                    if sp and onScreen then
                        line.Visible = true
                        local dx = sp.X - centerX
                        local dy = sp.Y - centerY
                        local dist = math.sqrt(dx * dx + dy * dy)
                        if dist > 1 then
                            line.Size = UDim2.new(0, 2, 0, dist)
                            line.Position = UDim2.new(0, centerX, 0, centerY)
                            line.Rotation = math.deg(math.atan2(dy, dx))
                        else
                            line.Visible = false
                        end
                    else
                        line.Visible = false
                    end
                else
                    if tracerObjects[p] then pcall(tracerObjects[p].Destroy, tracerObjects[p]); tracerObjects[p] = nil end
                end
                
                -- Cham
                if chamActive then
                    if not chamObjects[p] or not chamObjects[p].Parent then
                        local hl = Instance.new("Highlight")
                        hl.Name = randomName()
                        hl.FillTransparency = 0.3
                        hl.FillColor = col
                        hl.OutlineTransparency = 1
                        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        hl.Parent = p.Character
                        chamObjects[p] = hl
                    end
                    chamObjects[p].FillColor = col
                    chamObjects[p].Parent = p.Character
                else
                    if chamObjects[p] then pcall(chamObjects[p].Destroy, chamObjects[p]); chamObjects[p] = nil end
                end
                
                -- Outline
                if outlineActive then
                    if not outlineObjects[p] or not outlineObjects[p].Parent then
                        local hl = Instance.new("Highlight")
                        hl.Name = randomName()
                        hl.FillTransparency = 1
                        hl.OutlineColor = col
                        hl.OutlineTransparency = 0
                        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        hl.Parent = p.Character
                        outlineObjects[p] = hl
                    end
                    outlineObjects[p].OutlineColor = col
                    outlineObjects[p].Parent = p.Character
                else
                    if outlineObjects[p] then pcall(outlineObjects[p].Destroy, outlineObjects[p]); outlineObjects[p] = nil end
                end
            else
                if espObjects[p] then
                    if espObjects[p].hl then pcall(espObjects[p].hl.Destroy, espObjects[p].hl) end
                    if espObjects[p].tag then pcall(espObjects[p].tag.Destroy, espObjects[p].tag) end
                    espObjects[p] = nil
                end
                if boxObjects[p] then pcall(boxObjects[p].Destroy, boxObjects[p]); boxObjects[p] = nil end
                if tracerObjects[p] then pcall(tracerObjects[p].Destroy, tracerObjects[p]); tracerObjects[p] = nil end
                if chamObjects[p] then pcall(chamObjects[p].Destroy, chamObjects[p]); chamObjects[p] = nil end
                if outlineObjects[p] then pcall(outlineObjects[p].Destroy, outlineObjects[p]); outlineObjects[p] = nil end
            end
        end
    end
end

-- ─── HITBOX EXPANDER ──────────────────────────────────────────
local function applyHitboxToPlayer(p)
    if p ~= LocalPlayer and p.Character then
        local hrp = p.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            if not originalHitboxes[p] then
                originalHitboxes[p] = hrp.Size
            end
            safeCall(function()
                hrp.Size = Vector3.new(6, 6, 6)
                hrp.Transparency = 0.3
                hrp.CanCollide = false
            end)
            local head = p.Character:FindFirstChild("Head")
            if head and not originalHitboxes["head_" .. p.Name] then
                originalHitboxes["head_" .. p.Name] = head.Size
                safeCall(function()
                    head.Size = Vector3.new(4, 4, 4)
                    head.Transparency = 0.3
                end)
            end
        end
    end
end

local function toggleHitbox(on)
    if hitboxActive == on then return end
    hitboxActive = on
    if on then
        for _, p in ipairs(Players:GetPlayers()) do
            applyHitboxToPlayer(p)
        end
        if connections.hitboxPlayer then connections.hitboxPlayer:Disconnect() end
        connections.hitboxPlayer = safeConnect(Players, "PlayerAdded", function(p)
            task.wait(0.5)
            if hitboxActive then applyHitboxToPlayer(p) end
        end)
    else
        for p, size in pairs(originalHitboxes) do
            if type(p) == "string" then
                local playerName = p:gsub("head_", "")
                local player = Players:FindFirstChild(playerName)
                if player and player.Character then
                    local head = player.Character:FindFirstChild("Head")
                    if head then safeCall(function() head.Size = size; head.Transparency = 1 end) end
                end
            else
                if p and p.Character then
                    local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then safeCall(function() hrp.Size = size; hrp.Transparency = 1 end) end
                end
            end
        end
        originalHitboxes = {}
        if connections.hitboxPlayer then connections.hitboxPlayer:Disconnect(); connections.hitboxPlayer = nil end
    end
end

-- ─── COIN SYSTEM ──────────────────────────────────────────────
local coinCache = {}
local coinCacheTime = 0

local function getCoins()
    local now = os.clock()
    if now - coinCacheTime < 0.5 then
        return coinCache
    end
    coinCache = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name and (
            obj.Name:lower():match("coin") or 
            obj.Name:lower():match("pickup") or 
            obj.Name:lower():match("point") or
            obj.Name:lower():match("ore") or
            obj.Name:lower():match("gem") or
            obj.Name:lower():match("crystal") or
            obj.Name:lower():match("shard") or
            obj.Name:lower():match("token") or
            obj.Name:lower():match("collect")
        ) and obj.Parent then
            table.insert(coinCache, obj)
        end
    end
    coinCacheTime = now
    return coinCache
end

local function toggleCoinAura(on)
    if coinAuraActive == on then return end
    coinAuraActive = on
    if connections.coinAura then connections.coinAura:Disconnect(); connections.coinAura = nil end
    if on then
        connections.coinAura = safeConnect(RunService, "RenderStepped", function()
            local char = LocalPlayer.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            for _, obj in ipairs(getCoins()) do
                if obj and obj.Parent then
                    local dist = (obj.Position - hrp.Position).Magnitude
                    if dist < 150 then
                        safeCall(function()
                            obj.CFrame = obj.CFrame:Lerp(hrp.CFrame, 0.15)
                        end)
                    end
                end
            end
        end)
    end
end

local function toggleCoinFarm(on)
    if coinFarmActive == on then return end
    coinFarmActive = on
    if connections.coinFarm then connections.coinFarm:Disconnect(); connections.coinFarm = nil end
    if on then
        connections.coinFarm = safeConnect(RunService, "RenderStepped", function()
            local char = LocalPlayer.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            for _, obj in ipairs(getCoins()) do
                if obj and obj.Parent then
                    local dist = (obj.Position - hrp.Position).Magnitude
                    if dist < 150 then
                        safeCall(function()
                            obj.Position = hrp.Position + Vector3.new(0, 2, 0)
                        end)
                    end
                end
            end
        end)
    end
end

-- ─── AUTO GRAB GUN ────────────────────────────────────────────
local function toggleAutoGrabGun(on)
    if autoGrabGunActive == on then return end
    autoGrabGunActive = on
    if connections.autoGrabGun then connections.autoGrabGun:Disconnect(); connections.autoGrabGun = nil end
    if on then
        connections.autoGrabGun = safeConnect(RunService, "RenderStepped", function()
            if hasTool("gun") then return end
            local char = LocalPlayer.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("Tool") and obj.Name:lower():match("gun") and obj.Parent ~= char then
                    local handle = obj:FindFirstChild("Handle") or obj:FindFirstChildWhichIsA("BasePart")
                    if handle then
                        local dist = (handle.Position - hrp.Position).Magnitude
                        if dist < 100 then
                            safeCall(function()
                                obj.Parent = char
                                handle.CFrame = hrp.CFrame * CFrame.new(0, 2, 0)
                                task.wait(0.1)
                                if obj:FindFirstChild("Handle") then
                                    local tool = char:FindFirstChild(obj.Name)
                                    if tool then
                                        tool.Parent = char
                                    end
                                end
                                notify("NEXO E", "Gun grabbed!", 1)
                            end)
                            break
                        end
                    end
                end
            end
        end)
    end
end

local function toggleGunDropNotify(on)
    if gunDropNotifyActive == on then return end
    gunDropNotifyActive = on
    if connections.gunDropNotify then connections.gunDropNotify:Disconnect(); connections.gunDropNotify = nil end
    if on then
        local lastNotify = 0
        connections.gunDropNotify = safeConnect(RunService, "RenderStepped", function()
            if hasTool("gun") then return end
            local now = os.clock()
            if now - lastNotify < 3 then return end
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("Tool") and obj.Name:lower():match("gun") then
                    local handle = obj:FindFirstChild("Handle") or obj:FindFirstChildWhichIsA("BasePart")
                    if handle then
                        local char = LocalPlayer.Character
                        if char then
                            local hrp = char:FindFirstChild("HumanoidRootPart")
                            if hrp then
                                local dist = (handle.Position - hrp.Position).Magnitude
                                if dist < 500 then
                                    notify("GUN DROPPED", "Gun is " .. math.floor(dist) .. "m away!", 2)
                                    lastNotify = now
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
end

-- ─── INVISIBLE ────────────────────────────────────────────────
local function toggleInvisible(on)
    if invisibleActive == on then return end
    invisibleActive = on
    local char = LocalPlayer.Character
    if char then
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
                safeCall(function()
                    p.LocalTransparencyModifier = on and 1 or 0
                end)
            end
        end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum and hum.Head then
            safeCall(function()
                hum.Head.Transparency = on and 1 or 0
                hum.Head.LocalTransparencyModifier = on and 1 or 0
            end)
        end
    end
end

-- ─── SPEED ────────────────────────────────────────────────────
local function toggleSpeedGlitch(on)
    if speedGlitchActive == on then return end
    speedGlitchActive = on
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            safeCall(function()
                hum.WalkSpeed = on and 32 or 16
            end)
        end
    end
end

local function toggleSpeed(on)
    if speedActive == on then return end
    speedActive = on
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            safeCall(function()
                hum.WalkSpeed = on and 50 or 16
                hum.JumpPower = on and 70 or 50
            end)
        end
    end
end

-- ─── AUTO EXPOSE ──────────────────────────────────────────────
local exposedRoles = {}
local function toggleAutoExpose(on)
    if autoExposeActive == on then return end
    autoExposeActive = on
    if connections.autoExpose then connections.autoExpose:Disconnect(); connections.autoExpose = nil end
    if on then
        exposedRoles = {}
        connections.autoExpose = safeConnect(RunService, "Heartbeat", function()
            local mur = getMurderer()
            local sher = getSheriff()
            if mur and not exposedRoles[mur.Name] then
                exposedRoles[mur.Name] = true
                notify("MURDERER", mur.Name, 5)
            end
            if sher and not exposedRoles[sher.Name] then
                exposedRoles[sher.Name] = true
                notify("SHERIFF", sher.Name, 5)
            end
            if not mur and not sher then
                exposedRoles = {}
            end
        end)
    else
        exposedRoles = {}
    end
end

-- ─── MURDERER ALARM ───────────────────────────────────────────
local function toggleMurderAlarm(on)
    if murderAlarmActive == on then return end
    murderAlarmActive = on
    if connections.alarm then connections.alarm:Disconnect(); connections.alarm = nil end
    if on then
        if not alarmGui or not alarmGui.Parent then
            alarmGui = Instance.new("TextLabel")
            alarmGui.Name = randomName()
            alarmGui.Size = UDim2.new(0, isMobile and 250 or 280, 0, isMobile and 60 or 44)
            alarmGui.Position = UDim2.new(0.5, -(isMobile and 125 or 140), 0, 16)
            alarmGui.BackgroundColor3 = Color3.fromRGB(40, 10, 15)
            alarmGui.TextColor3 = Color3.fromRGB(255, 100, 100)
            alarmGui.Font = Enum.Font.GothamBold
            alarmGui.TextSize = isMobile and 16 or 14
            alarmGui.Text = ""
            alarmGui.Visible = false
            alarmGui.ZIndex = 999
            corner(alarmGui, 10)
            stroke(alarmGui, Color3.fromRGB(200, 50, 50), 1, 0.3)
            alarmGui.Parent = ScreenGui or getProtectedParent()
        end
        local lastAlarm = 0
        connections.alarm = safeConnect(RunService, "RenderStepped", function()
            local char = LocalPlayer.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            local murderer = getMurderer()
            if murderer and murderer.Character then
                local mHrp = murderer.Character:FindFirstChild("HumanoidRootPart")
                if mHrp then
                    local dist = (mHrp.Position - hrp.Position).Magnitude
                    if dist < 40 then
                        alarmGui.Visible = true
                        local now = os.clock()
                        if now - lastAlarm > 5 then
                            alarmGui.Text = "MURDERER NEAR  " .. math.floor(dist) .. "m  " .. murderer.Name
                            lastAlarm = now
                            pcall(function()
                                local sound = Instance.new("Sound")
                                sound.SoundId = "rbxassetid://9120328487"
                                sound.Volume = 0.3
                                sound.Parent = char
                                sound:Play()
                                task.wait(0.5)
                                sound:Destroy()
                            end)
                        end
                    else
                        alarmGui.Visible = false
                    end
                end
            else
                alarmGui.Visible = false
            end
        end)
    else
        if alarmGui then alarmGui.Visible = false end
    end
end

-- ─── ROUND TIMER ──────────────────────────────────────────────
local function toggleRoundTimer(on)
    if roundTimerActive == on then return end
    roundTimerActive = on
    if connections.roundTimer then connections.roundTimer:Disconnect(); connections.roundTimer = nil end
    if on then
        if not timerGui or not timerGui.Parent then
            timerGui = Instance.new("TextLabel")
            timerGui.Name = randomName()
            timerGui.Size = UDim2.new(0, isMobile and 160 or 120, 0, isMobile and 36 or 28)
            timerGui.Position = UDim2.new(0.5, -(isMobile and 80 or 60), 0, isMobile and 80 or 60)
            timerGui.BackgroundColor3 = BG
            timerGui.TextColor3 = ACCENT_LIGHT
            timerGui.Font = Enum.Font.GothamBold
            timerGui.TextSize = isMobile and 16 or 14
            timerGui.Text = "--:--"
            timerGui.ZIndex = 998
            corner(timerGui, 8)
            stroke(timerGui, ACCENT_DIM, 1, 0.3)
            timerGui.Parent = ScreenGui or getProtectedParent()
        end
        timerGui.Visible = true
        roundStartTime = os.clock()
        if connections.roundReset then connections.roundReset:Disconnect() end
        connections.roundReset = safeConnect(LocalPlayer, "CharacterAdded", function()
            roundStartTime = os.clock()
        end)
        connections.roundTimer = safeConnect(RunService, "RenderStepped", function()
            local elapsed = os.clock() - roundStartTime
            local mins = math.floor(elapsed / 60)
            local secs = math.floor(elapsed % 60)
            timerGui.Text = string.format("%d:%02d", mins, secs)
        end)
    else
        if timerGui then timerGui.Visible = false end
        if connections.roundReset then connections.roundReset:Disconnect(); connections.roundReset = nil end
    end
end

-- ─── ANTI-FLING ───────────────────────────────────────────────
local function toggleAntiFling(on)
    if antiFlingActive == on then return end
    antiFlingActive = on
    if connections.antiFling then connections.antiFling:Disconnect(); connections.antiFling = nil end
    if on then
        local char = LocalPlayer.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then lastKnownPosition = hrp.Position end
        end
        local lastCheck = 0
        connections.antiFling = safeConnect(RunService, "RenderStepped", function()
            local now = os.clock()
            if now - lastCheck < 0.1 then return end
            lastCheck = now
            
            local char = LocalPlayer.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum or hum.Health <= 0 then return end
            
            if lastKnownPosition then
                local delta = (hrp.Position - lastKnownPosition).Magnitude
                if delta > 80 then
                    safeCall(function()
                        local newPos = lastKnownPosition + Vector3.new(0, 2, 0)
                        if newPos.Y > -100 and newPos.Y < 1000 then
                            hrp.CFrame = CFrame.new(newPos)
                            notify("Anti-Fling", "Activated!", 1)
                        end
                    end)
                end
            end
            lastKnownPosition = hrp.Position
        end)
    end
end

-- ─── GUN SILENT AIM ───────────────────────────────────────────
local cachedMurderer = nil
local lastMurdererCheck = 0

local function getMurdererOptimized()
    local now = os.clock()
    if now - lastMurdererCheck > 0.5 then
        cachedMurderer = getMurderer()
        lastMurdererCheck = now
    end
    return cachedMurderer
end

local function setupSilentAim()
    if not getrawmetatable then 
        warn("[NEXO E] getrawmetatable not available, using fallback")
        return 
    end
    
    local success, mt = pcall(getrawmetatable, game)
    if not success then return end
    
    local oldNamecall = mt.__namecall
    local canSet = pcall(function() setreadonly(mt, false) end)
    if not canSet then return end
    
    local useNewCclosure = pcall(function() return newcclosure(function() end) end)
    local hookFunc
    
    if useNewCclosure then
        hookFunc = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if silentAimActive and method and (method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRay" or method == "FindPartOnRayWithWhitelist" or method == "Raycast") then
                local isCaller = false
                if checkcaller then
                    isCaller = checkcaller()
                end
                if not isCaller then
                    local char = LocalPlayer.Character
                    if char then
                        local hasGun = false
                        for _, t in ipairs(char:GetChildren()) do
                            if t:IsA("Tool") and (t.Name:lower():match("gun") or t.Name:lower():match("revolver") or t.Name:lower():match("pistol")) then
                                hasGun = true
                                break
                            end
                        end
                        if hasGun then
                            local murderer = getMurdererOptimized()
                            if murderer and murderer.Character then
                                local target = murderer.Character:FindFirstChild("Head") or murderer.Character:FindFirstChild("HumanoidRootPart")
                                if target then
                                    local args = {...}
                                    local cam = Workspace.CurrentCamera
                                    if cam then
                                        if method == "Raycast" then
                                            local origin = args[1]
                                            if origin and type(origin) == "Vector3" then
                                                local dist = (origin - cam.CFrame.Position).Magnitude
                                                if dist < 15 then
                                                    args[2] = (target.Position - origin).Unit * 3000
                                                    return oldNamecall(self, unpack(args))
                                                end
                                            end
                                        elseif method and string.find(method, "Ray") then
                                            local ray = args[1]
                                            if ray and ray.Origin then
                                                local dist = (ray.Origin - cam.CFrame.Position).Magnitude
                                                if dist < 15 then
                                                    args[1] = Ray.new(ray.Origin, (target.Position - ray.Origin).Unit * 3000)
                                                    return oldNamecall(self, unpack(args))
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
            return oldNamecall(self, ...)
        end)
    else
        hookFunc = function(self, ...)
            local method = getnamecallmethod()
            if silentAimActive and method and (method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRay" or method == "FindPartOnRayWithWhitelist" or method == "Raycast") then
                local char = LocalPlayer.Character
                if char then
                    local hasGun = false
                    for _, t in ipairs(char:GetChildren()) do
                        if t:IsA("Tool") and (t.Name:lower():match("gun") or t.Name:lower():match("revolver") or t.Name:lower():match("pistol")) then
                            hasGun = true
                            break
                        end
                    end
                    if hasGun then
                        local murderer = getMurdererOptimized()
                        if murderer and murderer.Character then
                            local target = murderer.Character:FindFirstChild("Head") or murderer.Character:FindFirstChild("HumanoidRootPart")
                            if target then
                                local args = {...}
                                local cam = Workspace.CurrentCamera
                                if cam then
                                    if method == "Raycast" then
                                        local origin = args[1]
                                        if origin and type(origin) == "Vector3" and (origin - cam.CFrame.Position).Magnitude < 15 then
                                            args[2] = (target.Position - origin).Unit * 3000
                                            return oldNamecall(self, unpack(args))
                                        end
                                    elseif method and string.find(method, "Ray") then
                                        local ray = args[1]
                                        if ray and ray.Origin and (ray.Origin - cam.CFrame.Position).Magnitude < 15 then
                                            args[1] = Ray.new(ray.Origin, (target.Position - ray.Origin).Unit * 3000)
                                            return oldNamecall(self, unpack(args))
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
            return oldNamecall(self, ...)
        end
    end
    
    mt.__namecall = hookFunc
    pcall(function() setreadonly(mt, true) end)
end

local function toggleGunSilentAim(on)
    silentAimActive = on
end

-- ─── KNIFE SILENT AIM ─────────────────────────────────────────
local function toggleKnifeAim(on)
    if knifeAimActive == on then return end
    knifeAimActive = on
    if connections.knifeAim then connections.knifeAim:Disconnect(); connections.knifeAim = nil end
    if on then
        connections.knifeAim = safeConnect(RunService, "RenderStepped", function()
            local tool = hasTool("knife")
            if not tool then return end
            local target = getNearestPlayer("Innocent") or getNearestPlayer("Sheriff")
            if not target or not target.Character then return end
            local tHrp = target.Character:FindFirstChild("HumanoidRootPart")
            local tHum = target.Character:FindFirstChildOfClass("Humanoid")
            if not tHrp or not tHum or tHum.Health <= 0 then return end
            local char = LocalPlayer.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            local dist = (tHrp.Position - hrp.Position).Magnitude
            if dist < 35 then
                safeCall(function()
                    local dir = (tHrp.Position - hrp.Position).Unit
                    hrp.CFrame = CFrame.new(hrp.Position + dir * 2, tHrp.Position)
                    tool:Activate()
                    task.wait(0.05)
                    tool:Activate()
                end)
            end
        end)
    end
end

-- ─── GUN AURA ────────────────────────────────────────────────
local function toggleGunAura(on)
    if gunAuraActive == on then return end
    gunAuraActive = on
    if connections.gunAura then connections.gunAura:Disconnect(); connections.gunAura = nil end
    if on then
        connections.gunAura = safeConnect(RunService, "RenderStepped", function()
            local tool = hasTool("gun")
            if not tool then return end
            local target = getMurderer()
            if target and target.Character then
                local tHum = target.Character:FindFirstChildOfClass("Humanoid")
                if tHum and tHum.Health > 0 then
                    local char = LocalPlayer.Character
                    if char then
                        local hrp = char:FindFirstChild("HumanoidRootPart")
                        local tHrp = target.Character:FindFirstChild("HumanoidRootPart")
                        if hrp and tHrp then
                            local dir = (tHrp.Position - hrp.Position).Unit
                            hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + dir * 100)
                        end
                    end
                    safeCall(function()
                        tool:Activate()
                        task.wait(0.1)
                        tool:Activate()
                    end)
                end
            end
        end)
    end
end

-- ─── KNIFE AURA ──────────────────────────────────────────────
local function toggleKnifeAura(on)
    if knifeAuraActive == on then return end
    knifeAuraActive = on
    if connections.knifeAura then connections.knifeAura:Disconnect(); connections.knifeAura = nil end
    if on then
        connections.knifeAura = safeConnect(RunService, "RenderStepped", function()
            local tool = hasTool("knife")
            if not tool then return end
            local target = getNearestPlayer("Innocent") or getNearestPlayer("Sheriff")
            if not target or not target.Character then return end
            local tHrp = target.Character:FindFirstChild("HumanoidRootPart")
            local tHum = target.Character:FindFirstChildOfClass("Humanoid")
            if not tHrp or not tHum or tHum.Health <= 0 then return end
            local char = LocalPlayer.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            if (tHrp.Position - hrp.Position).Magnitude < 20 then
                safeCall(function()
                    tool:Activate()
                    task.wait(0.05)
                    tool:Activate()
                end)
            end
        end)
    end
end

-- ─── FLY ─────────────────────────────────────────────────────
local flySpeed = 60
local function toggleFly(on)
    if flyActive == on then return end
    flyActive = on
    if connections.fly then connections.fly:Disconnect(); connections.fly = nil end
    if on then
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local bv = Instance.new("BodyVelocity")
        bv.Name = randomName()
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.zero
        bv.Parent = hrp
        
        connections.fly = safeConnect(RunService, "RenderStepped", function()
            if not flyActive then return end
            local cam = Workspace.CurrentCamera
            if not cam then return end
            local move = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move = move - Vector3.new(0, 1, 0) end
            bv.Velocity = move * flySpeed
        end)
    else
        local char = LocalPlayer.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                for _, v in ipairs(hrp:GetChildren()) do
                    if v:IsA("BodyVelocity") then
                        safeCall(v.Destroy, v)
                    end
                end
            end
        end
    end
end

-- ─── NOCLIP ──────────────────────────────────────────────────
local function toggleNoclip(on)
    if noclipActive == on then return end
    noclipActive = on
    if connections.noclip then connections.noclip:Disconnect(); connections.noclip = nil end
    if on then
        connections.noclip = safeConnect(RunService, "RenderStepped", function()
            local char = LocalPlayer.Character
            if char then
                for _, p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") and p.CanCollide then
                        p.CanCollide = false
                    end
                end
            end
        end)
    end
end

-- ─── AUTO DODGE ──────────────────────────────────────────────
local function toggleAutoDodge(on)
    if autoDodgeActive == on then return end
    autoDodgeActive = on
    if connections.autoDodge then connections.autoDodge:Disconnect(); connections.autoDodge = nil end
    if on then
        connections.autoDodge = safeConnect(RunService, "RenderStepped", function()
            local char = LocalPlayer.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            local murderer = getMurderer()
            if murderer and murderer.Character then
                local mHrp = murderer.Character:FindFirstChild("HumanoidRootPart")
                if mHrp then
                    local dist = (mHrp.Position - hrp.Position).Magnitude
                    if dist < 15 then
                        safeCall(function()
                            local dir = (hrp.Position - mHrp.Position).Unit
                            hrp.CFrame = hrp.CFrame + dir * 25
                        end)
                    end
                end
            end
        end)
    end
end

-- ─── FPS BOOST ────────────────────────────────────────────────
local function toggleFPSBoost(on)
    if fpsBoostActive == on then return end
    fpsBoostActive = on
    safeCall(function()
        if on then
            for _, v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") then
                    pcall(function() v.Material = Enum.Material.SmoothPlastic end)
                end
                if v:IsA("Decal") or v:IsA("Texture") then
                    pcall(function() v.Transparency = 1 end)
                end
                if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") then
                    pcall(function() v.Enabled = false end)
                end
                if v:IsA("Beam") then
                    pcall(function() v.Transparency = NumberSequence.new(1) end)
                end
            end
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
            Lighting.FogStart = 9e9
        else
            for _, v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") then
                    pcall(function() v.Enabled = true end)
                end
                if v:IsA("Beam") then
                    pcall(function() v.Transparency = NumberSequence.new(0) end)
                end
            end
            Lighting.GlobalShadows = true
            Lighting.FogEnd = 100000
            Lighting.FogStart = 0
        end
    end)
end

-- ─── OPTIMIZE COINS ──────────────────────────────────────────
local function toggleOptimizeCoins(on)
    if optimizeCoinsActive == on then return end
    optimizeCoinsActive = on
    safeCall(function()
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") and v.Name and (
                v.Name:lower():match("coin") or 
                v.Name:lower():match("pickup") or 
                v.Name:lower():match("point") or
                v.Name:lower():match("ore") or
                v.Name:lower():match("gem") or
                v.Name:lower():match("crystal")
            ) then
                pcall(function()
                    v.Material = Enum.Material.SmoothPlastic
                    v.Reflectance = 0
                    v.Transparency = 0.5
                end)
            end
        end
    end)
end

-- ─── FULLBRIGHT ──────────────────────────────────────────────
local function toggleFullbright(on)
    if fullbrightActive == on then return end
    fullbrightActive = on
    safeCall(function()
        if on then
            Lighting.Brightness = 3
            Lighting.ClockTime = 12
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
            Lighting.Ambient = Color3.fromRGB(178, 178, 178)
            Lighting.OutdoorAmbient = Color3.fromRGB(178, 178, 178)
        else
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = true
            Lighting.Ambient = Color3.fromRGB(100, 100, 100)
            Lighting.OutdoorAmbient = Color3.fromRGB(100, 100, 100)
        end
    end)
end

local function toggleNoShadows(on)
    if noShadowsActive == on then return end
    noShadowsActive = on
    safeCall(function()
        Lighting.GlobalShadows = not on
    end)
end

-- ─── ANTI-AFK ────────────────────────────────────────────────
local function toggleAntiAfk(on)
    if antiAfkActive == on then return end
    antiAfkActive = on
    if connections.antiAfk then connections.antiAfk:Disconnect(); connections.antiAfk = nil end
    if on then
        connections.antiAfk = safeConnect(LocalPlayer, "Idled", function()
            safeCall(function()
                if VirtualUser then
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new())
                else
                    local frame = Instance.new("Frame")
                    frame.Size = UDim2.new(0, 1, 0, 1)
                    frame.Parent = LocalPlayer.PlayerGui
                    frame:Destroy()
                end
            end)
        end)
    end
end

-- ─── FAKE FUNCTIONS ──────────────────────────────────────────
local function fakeBombClutch()
    notify("BOMB", "Bomb has been defused!", 3)
    pcall(function()
        local screen = ScreenGui or getProtectedParent()
        if screen then
            local flash = Instance.new("Frame")
            flash.Size = UDim2.new(1, 0, 1, 0)
            flash.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            flash.BackgroundTransparency = 0.7
            flash.ZIndex = 1000
            flash.Parent = screen
            TweenService:Create(flash, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
            task.wait(0.5)
            flash:Destroy()
        end
    end)
end

local function fakeUnbox()
    local items = {"Godly Knife", "Legendary Gun", "Rare Skin", "Common Knife", "Divine Blade"}
    local item = items[math.random(1, #items)]
    local colors = {Color3.fromRGB(255, 215, 0), Color3.fromRGB(255, 100, 0), Color3.fromRGB(0, 200, 255), Color3.fromRGB(255, 0, 255)}
    local col = colors[math.random(1, #colors)]
    notify("UNBOXING", "You got: " .. item .. "!", 4)
    
    pcall(function()
        local screen = ScreenGui or getProtectedParent()
        if screen then
            local flash = Instance.new("Frame")
            flash.Size = UDim2.new(1, 0, 1, 0)
            flash.BackgroundColor3 = col
            flash.BackgroundTransparency = 0.8
            flash.ZIndex = 1000
            flash.Parent = screen
            TweenService:Create(flash, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
            task.wait(0.3)
            flash:Destroy()
        end
    end)
end

local function tpRandom()
    local targets = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(targets, p)
        end
    end
    if #targets > 0 then
        local t = targets[math.random(1, #targets)]
        local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local tHrp = t.Character.HumanoidRootPart
        if myHrp and tHrp then
            safeCall(function()
                myHrp.CFrame = tHrp.CFrame * CFrame.new(0, 0, 3)
                notify("NEXO E", "Teleported to " .. t.Name, 1)
            end)
        end
    else
        notify("NEXO E", "No targets found", 2)
    end
end

local function forceSheriffShoot()
    local sheriff = getSheriff()
    if sheriff and sheriff.Character then
        local tool = sheriff.Character:FindFirstChildOfClass("Tool")
        if tool and (tool.Name:lower():match("gun") or tool.Name:lower():match("revolver") or tool.Name:lower():match("pistol")) then
            safeCall(tool.Activate, tool)
            notify("NEXO E", "Forced sheriff to shoot", 2)
        else
            notify("NEXO E", "Sheriff doesn't have gun equipped", 2)
        end
    else
        notify("NEXO E", "No sheriff found", 2)
    end
end

local function exposeRoles()
    local mur = getMurderer()
    local sher = getSheriff()
    if mur then 
        notify("MURDERER", mur.Name, 5)
        if mur.Character then
            local hl = Instance.new("Highlight")
            hl.FillColor = Color3.fromRGB(255, 0, 0)
            hl.OutlineColor = Color3.fromRGB(255, 0, 0)
            hl.FillTransparency = 0.5
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.Parent = mur.Character
            task.wait(2)
            hl:Destroy()
        end
    end
    if sher then 
        notify("SHERIFF", sher.Name, 5)
        if sher.Character then
            local hl = Instance.new("Highlight")
            hl.FillColor = Color3.fromRGB(0, 100, 255)
            hl.OutlineColor = Color3.fromRGB(0, 100, 255)
            hl.FillTransparency = 0.5
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.Parent = sher.Character
            task.wait(2)
            hl:Destroy()
        end
    end
    if not mur and not sher then notify("NEXO E", "Roles not assigned yet", 3) end
end

-- ─── EMOTES ──────────────────────────────────────────────────
local function playEmote(id)
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            safeCall(function()
                local emote = Instance.new("Animation")
                emote.AnimationId = "rbxassetid://" .. id
                local track = hum:LoadAnimation(emote)
                track:Play()
            end)
        end
    end
end

-- ─── KILL SCRIPT ─────────────────────────────────────────────
local function killScript()
    scriptRunning = false
    safeCall(clearAllVisuals)
    for _, conn in pairs(connections) do
        if conn then safeCall(conn.Disconnect, conn) end
    end
    connections = {}
    safeCall(toggleHitbox, false)
    safeCall(toggleFullbright, false)
    safeCall(toggleInvisible, false)
    safeCall(toggleFly, false)
    safeCall(toggleNoclip, false)
    safeCall(toggleSpeed, false)
    safeCall(toggleSpeedGlitch, false)
    safeCall(toggleFPSBoost, false)
    safeCall(toggleOptimizeCoins, false)
    if alarmGui then safeCall(alarmGui.Destroy, alarmGui); alarmGui = nil end
    if timerGui then safeCall(timerGui.Destroy, timerGui); timerGui = nil end
    silentAimActive = false
    if ScreenGui then safeCall(ScreenGui.Destroy, ScreenGui) end
    notify("NEXO E", "Script killed.", 2)
end

-- ─── MAIN GUI ─────────────────────────────────────────────────
ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = randomName()
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
local parent = getProtectedParent()
if parent then
    ScreenGui.Parent = parent
end

-- ─── FLOATING BUTTON ──────────────────────────────────────────
local FloatBtn = Instance.new("TextButton")
FloatBtn.Name = randomName()
FloatBtn.Size = UDim2.new(0, 48, 0, 48)
FloatBtn.Position = UDim2.new(0, 20, 0.5, -24)
FloatBtn.BackgroundColor3 = BG_SIDE
FloatBtn.Text = "N"
FloatBtn.TextColor3 = ACCENT_LIGHT
FloatBtn.Font = Enum.Font.GothamBlack
FloatBtn.TextSize = 22
FloatBtn.Visible = false
FloatBtn.Parent = ScreenGui
corner(FloatBtn, 24)
stroke(FloatBtn, ACCENT, 1.5, 0.15)

local FloatGlow = Instance.new("Frame")
FloatGlow.Name = randomName()
FloatGlow.Size = UDim2.new(1, 24, 1, 24)
FloatGlow.Position = UDim2.new(0, -12, 0, -12)
FloatGlow.BackgroundColor3 = ACCENT
FloatGlow.BackgroundTransparency = 0.92
FloatGlow.BorderSizePixel = 0
FloatGlow.Visible = false
FloatGlow.Parent = FloatBtn
corner(FloatGlow, 28)

-- pulse animation for float glow
task.spawn(function()
    while scriptRunning do
        if FloatGlow.Visible then
            TweenService:Create(FloatGlow, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 0.85}):Play()
            task.wait(1)
            TweenService:Create(FloatGlow, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 0.95}):Play()
            task.wait(1)
        else
            task.wait(0.5)
        end
    end
end)

do
    local dragging, dragStart, startPos
    FloatBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = FloatBtn.Position
            TweenService:Create(FloatBtn, TweenInfo.new(0.2), {BackgroundColor3 = BG_CARD}):Play()
        end
    end)
    FloatBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            TweenService:Create(FloatBtn, TweenInfo.new(0.2), {BackgroundColor3 = BG_SIDE}):Play()
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            FloatBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- ─── LOADING SCREEN ───────────────────────────────────────────
local LoadFrame = Instance.new("Frame")
LoadFrame.Name = randomName()
LoadFrame.Size = UDim2.new(0, 400, 0, 220)
LoadFrame.Position = UDim2.new(0.5, -200, 0.5, -110)
LoadFrame.BackgroundColor3 = BG
LoadFrame.BorderSizePixel = 0
LoadFrame.Parent = ScreenGui
corner(LoadFrame, 16)
stroke(LoadFrame, ACCENT_DIM, 1, 0.15)

local LoadGlow = Instance.new("Frame")
LoadGlow.Name = randomName()
LoadGlow.Size = UDim2.new(1, 0, 1, 0)
LoadGlow.BackgroundColor3 = ACCENT
LoadGlow.BackgroundTransparency = 0.92
LoadGlow.BorderSizePixel = 0
LoadGlow.Parent = LoadFrame
corner(LoadGlow, 16)

local LoadIcon = Instance.new("TextLabel")
LoadIcon.Name = randomName()
LoadIcon.Size = UDim2.new(0, 60, 0, 60)
LoadIcon.Position = UDim2.new(0.5, -30, 0, 25)
LoadIcon.BackgroundTransparency = 1
LoadIcon.Text = "N"
LoadIcon.TextColor3 = ACCENT_LIGHT
LoadIcon.Font = Enum.Font.GothamBlack
LoadIcon.TextSize = 40
LoadIcon.Parent = LoadFrame
gradient(LoadIcon, ACCENT_LIGHT, ACCENT, 0)

local LoadTitle = Instance.new("TextLabel")
LoadTitle.Name = randomName()
LoadTitle.Size = UDim2.new(1, 0, 0, 24)
LoadTitle.Position = UDim2.new(0, 0, 0, 85)
LoadTitle.BackgroundTransparency = 1
LoadTitle.Text = "NEXO E"
LoadTitle.TextColor3 = TEXT
LoadTitle.Font = Enum.Font.GothamBlack
LoadTitle.TextSize = 18
LoadTitle.Parent = LoadFrame

local LoadStatus = Instance.new("TextLabel")
LoadStatus.Name = randomName()
LoadStatus.Size = UDim2.new(1, -100, 0, 16)
LoadStatus.Position = UDim2.new(0, 24, 0, 115)
LoadStatus.BackgroundTransparency = 1
LoadStatus.Text = "initializing..."
LoadStatus.TextColor3 = TEXT_DIM
LoadStatus.Font = Enum.Font.GothamMedium
LoadStatus.TextSize = 11
LoadStatus.TextXAlignment = Enum.TextXAlignment.Left
LoadStatus.Parent = LoadFrame

local BarBg = Instance.new("Frame")
BarBg.Name = randomName()
BarBg.Size = UDim2.new(1, -48, 0, 4)
BarBg.Position = UDim2.new(0, 24, 0, 145)
BarBg.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
BarBg.BorderSizePixel = 0
BarBg.Parent = LoadFrame
corner(BarBg, 2)

local BarFill = Instance.new("Frame")
BarFill.Name = randomName()
BarFill.Size = UDim2.new(0, 0, 1, 0)
BarFill.BackgroundColor3 = ACCENT
BarFill.BorderSizePixel = 0
BarFill.Parent = BarBg
corner(BarFill, 2)
gradient(BarFill, ACCENT_LIGHT, ACCENT, 0)

local LoadPercent = Instance.new("TextLabel")
LoadPercent.Name = randomName()
LoadPercent.Size = UDim2.new(0, 60, 0, 16)
LoadPercent.Position = UDim2.new(1, -84, 0, 115)
LoadPercent.BackgroundTransparency = 1
LoadPercent.Text = "0%"
LoadPercent.TextColor3 = ACCENT
LoadPercent.Font = Enum.Font.GothamBold
LoadPercent.TextSize = 11
LoadPercent.TextXAlignment = Enum.TextXAlignment.Right
LoadPercent.Parent = LoadFrame

local LoadSubtext = Instance.new("TextLabel")
LoadSubtext.Name = randomName()
LoadSubtext.Size = UDim2.new(1, -48, 0, 14)
LoadSubtext.Position = UDim2.new(0, 24, 0, 165)
LoadSubtext.BackgroundTransparency = 1
LoadSubtext.Text = ""
LoadSubtext.TextColor3 = TEXT_MUTED
LoadSubtext.Font = Enum.Font.Gotham
LoadSubtext.TextSize = 10
LoadSubtext.TextXAlignment = Enum.TextXAlignment.Left
LoadSubtext.Parent = LoadFrame

-- ─── DROP SHADOW & MAIN FRAME ─────────────────────────────────
local MainShadow = Instance.new("Frame")
MainShadow.Name = randomName()
MainShadow.Size = UDim2.new(0, 520, 0, 400)
MainShadow.Position = UDim2.new(0.5, -260, 0.5, -200)
MainShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainShadow.BackgroundTransparency = 0.6
MainShadow.BorderSizePixel = 0
MainShadow.Visible = false
MainShadow.Parent = ScreenGui
corner(MainShadow, 18)

local Main = Instance.new("Frame")
Main.Name = randomName()
Main.Size = UDim2.new(0, 500, 0, 380)
Main.Position = UDim2.new(0.5, -250, 0.5, -190)
Main.BackgroundColor3 = BG
Main.BorderSizePixel = 0
Main.Visible = false
Main.Parent = ScreenGui
corner(Main, 14)
stroke(Main, ACCENT_DIM, 1, 0.1)

do
    local dragging, dragStart, startPos
    Main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
        end
    end)
    Main.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            MainShadow.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X + 10, startPos.Y.Scale, startPos.Y.Offset + delta.Y + 10)
        end
    end)
end

-- ─── SIDEBAR ──────────────────────────────────────────────────
local Sidebar = Instance.new("Frame")
Sidebar.Name = randomName()
Sidebar.Size = UDim2.new(0, 130, 1, 0)
Sidebar.BackgroundColor3 = BG_SIDE
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Main
corner(Sidebar, 14)

local SideIcon = Instance.new("TextLabel")
SideIcon.Name = randomName()
SideIcon.Size = UDim2.new(0, 40, 0, 40)
SideIcon.Position = UDim2.new(0.5, -20, 0, 20)
SideIcon.BackgroundTransparency = 1
SideIcon.Text = "N"
SideIcon.TextColor3 = ACCENT_LIGHT
SideIcon.Font = Enum.Font.GothamBlack
SideIcon.TextSize = 28
SideIcon.Parent = Sidebar
gradient(SideIcon, ACCENT_LIGHT, ACCENT, 0)

local SideTitle = Instance.new("TextLabel")
SideTitle.Name = randomName()
SideTitle.Size = UDim2.new(1, 0, 0, 20)
SideTitle.Position = UDim2.new(0, 0, 0, 60)
SideTitle.BackgroundTransparency = 1
SideTitle.Text = "NEXO E"
SideTitle.TextColor3 = TEXT
SideTitle.Font = Enum.Font.GothamBold
SideTitle.TextSize = 13
SideTitle.Parent = Sidebar

local SideVersion = Instance.new("TextLabel")
SideVersion.Name = randomName()
SideVersion.Size = UDim2.new(1, 0, 0, 14)
SideVersion.Position = UDim2.new(0, 0, 0, 78)
SideVersion.BackgroundTransparency = 1
SideVersion.Text = "v2.4"
SideVersion.TextColor3 = TEXT_MUTED
SideVersion.Font = Enum.Font.Gotham
SideVersion.TextSize = 10
SideVersion.Parent = Sidebar

local SideDivider = Instance.new("Frame")
SideDivider.Name = randomName()
SideDivider.Size = UDim2.new(1, -20, 0, 1)
SideDivider.Position = UDim2.new(0, 10, 0, 98)
SideDivider.BackgroundColor3 = ACCENT_DIM
SideDivider.BackgroundTransparency = 0.5
SideDivider.BorderSizePixel = 0
SideDivider.Parent = Sidebar

local tabs = {"Combat", "Visuals", "Player", "Utility", "Misc"}
local tabButtons = {}
local tabPages = {}

for i, name in ipairs(tabs) do
    local tabBtn = Instance.new("TextButton")
    tabBtn.Name = randomName()
    tabBtn.Size = UDim2.new(1, -24, 0, 30)
    tabBtn.Position = UDim2.new(0, 12, 0, 108 + (i - 1) * 34)
    tabBtn.BackgroundColor3 = BG_CARD
    tabBtn.BorderSizePixel = 0
    tabBtn.Text = name
    tabBtn.TextColor3 = TEXT_DIM
    tabBtn.Font = Enum.Font.GothamMedium
    tabBtn.TextSize = 12
    tabBtn.AutoButtonColor = false
    corner(tabBtn, 8)
    tabBtn.Parent = Sidebar

    tabBtn.MouseButton1Click:Connect(function()
        for _, btn in pairs(tabButtons) do
            if type(btn) == "table" and btn.obj then
                TweenService:Create(btn.obj, TweenInfo.new(0.2), {BackgroundColor3 = BG_CARD, TextColor3 = TEXT_DIM}):Play()
                if btn.page then btn.page.Visible = false end
            end
        end
        TweenService:Create(tabBtn, TweenInfo.new(0.2), {BackgroundColor3 = ACCENT_DIM, TextColor3 = ACCENT_LIGHT}):Play()
        if tabPages[name] then tabPages[name].Visible = true end
        tabButtons.current = name
    end)

    tabButtons[name] = { obj = tabBtn, page = nil }

    local page = Instance.new("ScrollingFrame")
    page.Name = randomName()
    page.Size = UDim2.new(1, -150, 1, -20)
    page.Position = UDim2.new(0, 140, 0, 10)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = ACCENT_DIM
    page.ScrollBarImageTransparency = 0.5
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    page.Parent = Main

    local pageLayout = Instance.new("UIListLayout")
    pageLayout.Padding = UDim.new(0, 6)
    pageLayout.Parent = page

    padding(page, 0, 10, 0, 10)

    tabPages[name] = page
    tabButtons[name].page = page
end

-- ─── FOOTER (SIDEBAR) ─────────────────────────────────────────
local SideFoot = Instance.new("Frame")
SideFoot.Name = randomName()
SideFoot.Size = UDim2.new(1, 0, 0, 70)
SideFoot.Position = UDim2.new(0, 0, 1, -70)
SideFoot.BackgroundTransparency = 1
SideFoot.Parent = Sidebar

local SideKeys = Instance.new("TextLabel")
SideKeys.Name = randomName()
SideKeys.Size = UDim2.new(1, 0, 0, 28)
SideKeys.Position = UDim2.new(0, 0, 0, 0)
SideKeys.BackgroundTransparency = 1
SideKeys.Text = "[F]ly  [N]oclip\n[V]Invis  [G]Gun"
SideKeys.TextColor3 = TEXT_MUTED
SideKeys.Font = Enum.Font.Gotham
SideKeys.TextSize = 9
SideKeys.Parent = SideFoot

local closeBtn = Instance.new("TextButton")
closeBtn.Name = randomName()
closeBtn.Size = UDim2.new(1, -24, 0, 30)
closeBtn.Position = UDim2.new(0, 12, 0, 32)
closeBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 25)
closeBtn.BorderSizePixel = 0
closeBtn.Text = "Close"
closeBtn.TextColor3 = DANGER
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 11
closeBtn.AutoButtonColor = false
corner(closeBtn, 8)
closeBtn.Parent = SideFoot

closeBtn.MouseButton1Click:Connect(function()
    Main.Visible = false
    MainShadow.Visible = false
    FloatBtn.Visible = true
    FloatGlow.Visible = true
end)

FloatBtn.MouseButton1Click:Connect(function()
    Main.Visible = true
    MainShadow.Visible = true
    FloatBtn.Visible = false
    FloatGlow.Visible = false
end)

-- ─── TOGGLE FACTORY ───────────────────────────────────────────
local function makeToggle(parent, text, callback)
    local container = Instance.new("TextButton")
    container.Name = randomName()
    container.Size = UDim2.new(1, 0, 0, 34)
    container.BackgroundColor3 = BG_CARD
    container.BorderSizePixel = 0
    container.Text = ""
    container.AutoButtonColor = false
    corner(container, 10)
    local stk = stroke(container, Color3.fromRGB(40, 40, 50), 1, 0)
    container.Parent = parent

    local label = Instance.new("TextLabel")
    label.Name = randomName()
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Position = UDim2.new(0, 14, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = TEXT
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local toggleBg = Instance.new("Frame")
    toggleBg.Name = randomName()
    toggleBg.Size = UDim2.new(0, 38, 0, 20)
    toggleBg.Position = UDim2.new(1, -50, 0.5, -10)
    toggleBg.BackgroundColor3 = TOGGLE_OFF
    toggleBg.BorderSizePixel = 0
    corner(toggleBg, 10)
    toggleBg.Parent = container

    local toggleKnob = Instance.new("Frame")
    toggleKnob.Name = randomName()
    toggleKnob.Size = UDim2.new(0, 16, 0, 16)
    toggleKnob.Position = UDim2.new(0, 2, 0.5, -8)
    toggleKnob.BackgroundColor3 = Color3.fromRGB(120, 120, 130)
    toggleKnob.BorderSizePixel = 0
    corner(toggleKnob, 8)
    toggleKnob.Parent = toggleBg

    local on = false
    container.MouseButton1Click:Connect(function()
        on = not on
        if on then
            TweenService:Create(toggleBg, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundColor3 = ACCENT}):Play()
            TweenService:Create(toggleKnob, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(1, -18, 0.5, -8), BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
            label.TextColor3 = ACCENT_LIGHT
            stk.Color = ACCENT_DIM
        else
            TweenService:Create(toggleBg, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundColor3 = TOGGLE_OFF}):Play()
            TweenService:Create(toggleKnob, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0, 2, 0.5, -8), BackgroundColor3 = Color3.fromRGB(120, 120, 130)}):Play()
            label.TextColor3 = TEXT
            stk.Color = Color3.fromRGB(40, 40, 50)
        end
        safeCall(callback, on)
    end)

    container.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            TweenService:Create(container, TweenInfo.new(0.2), {BackgroundColor3 = BG_HOVER}):Play()
        end
    end)
    container.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            TweenService:Create(container, TweenInfo.new(0.2), {BackgroundColor3 = BG_CARD}):Play()
        end
    end)
end

local function makeAction(parent, text, color, callback)
    local btn = Instance.new("TextButton")
    btn.Name = randomName()
    btn.Size = UDim2.new(1, 0, 0, 34)
    btn.BackgroundColor3 = BG_CARD
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = color or TEXT
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.AutoButtonColor = false
    corner(btn, 10)
    stroke(btn, color and Color3.new(color.R * 0.3, color.G * 0.3, color.B * 0.3) or ACCENT_DIM, 1, 0)
    btn.Parent = parent

    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = BG_HOVER}):Play()
        end
    end)
    btn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = BG_CARD}):Play()
        end
    end)
    btn.MouseButton1Click:Connect(function()
        safeCall(callback)
    end)
end

-- ─── BINDABLE BUTTONS (KEYBINDS CORRIGIDOS) ──────────────────
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe or not scriptRunning then return end
    if input.KeyCode == Enum.KeyCode.F then
        toggleFly(not flyActive)
        notify("NEXO E", "Fly: " .. (flyActive and "ON" or "OFF"), 1.5)
    elseif input.KeyCode == Enum.KeyCode.N then
        toggleNoclip(not noclipActive)
        notify("NEXO E", "Noclip: " .. (noclipActive and "ON" or "OFF"), 1.5)
    elseif input.KeyCode == Enum.KeyCode.V then
        toggleInvisible(not invisibleActive)
        notify("NEXO E", "Invisible: " .. (invisibleActive and "ON" or "OFF"), 1.5)
    elseif input.KeyCode == Enum.KeyCode.G then
        toggleAutoGrabGun(not autoGrabGunActive)
        notify("NEXO E", "Grab Gun: " .. (autoGrabGunActive and "ON" or "OFF"), 1.5)
    end
end)

-- ─── LOADING SEQUENCE ─────────────────────────────────────────
local loadSteps = {
    { status = "booting core modules...", sub = "hooking metamethods", fn = function()
        safeCall(setupSilentAim)
        task.wait(0.3)
    end },
    { status = "establishing stealth layer...", sub = "gethui + randomization", fn = function()
        task.wait(0.25)
    end },
    { status = "loading combat systems...", sub = "silent aim + aura + grab", fn = function()
        makeToggle(tabPages["Combat"], "Gun Silent Aim", toggleGunSilentAim)
        makeToggle(tabPages["Combat"], "Knife Silent Aim", toggleKnifeAim)
        makeToggle(tabPages["Combat"], "Gun Aura", toggleGunAura)
        makeToggle(tabPages["Combat"], "Knife Aura", toggleKnifeAura)
        makeToggle(tabPages["Combat"], "Auto Grab Gun [G]", toggleAutoGrabGun)
        makeToggle(tabPages["Combat"], "Gun Drop Notify", toggleGunDropNotify)
        makeToggle(tabPages["Combat"], "Hitbox Expander", toggleHitbox)
        makeAction(tabPages["Combat"], "Force Sheriff Shoot", ACCENT_LIGHT, forceSheriffShoot)
        makeAction(tabPages["Combat"], "Expose Roles", ACCENT_LIGHT, exposeRoles)
        makeToggle(tabPages["Combat"], "Auto Expose Roles", toggleAutoExpose)
    end },
    { status = "loading visual systems...", sub = "esp + cham + outline + box", fn = function()
        makeToggle(tabPages["Visuals"], "ESP (Roles)", function(on) espActive = on end)
        makeToggle(tabPages["Visuals"], "Display Distance", function(on) displayDistanceActive = on end)
        makeToggle(tabPages["Visuals"], "ESP Box", function(on) espBoxActive = on end)
        makeToggle(tabPages["Visuals"], "Tracers", function(on) tracersActive = on end)
        makeToggle(tabPages["Visuals"], "Cham (Solid)", function(on) chamActive = on end)
        makeToggle(tabPages["Visuals"], "Outline", function(on) outlineActive = on end)
        makeToggle(tabPages["Visuals"], "Fullbright", toggleFullbright)
        makeToggle(tabPages["Visuals"], "No Shadows", toggleNoShadows)
        makeToggle(tabPages["Visuals"], "Murderer Alarm", toggleMurderAlarm)
        makeToggle(tabPages["Visuals"], "Round Timer", toggleRoundTimer)
    end },
    { status = "loading player systems...", sub = "fly + noclip + invis + dodge", fn = function()
        makeToggle(tabPages["Player"], "Fly [F] (WASD/Sp/Ctrl)", toggleFly)
        makeToggle(tabPages["Player"], "Noclip [N]", toggleNoclip)
        makeToggle(tabPages["Player"], "Invisible [V]", toggleInvisible)
        makeToggle(tabPages["Player"], "Speed x3", toggleSpeed)
        makeToggle(tabPages["Player"], "Speed Glitch", toggleSpeedGlitch)
        makeToggle(tabPages["Player"], "Auto Dodge Murderer", toggleAutoDodge)
        makeToggle(tabPages["Player"], "Anti-Fling", toggleAntiFling)
        makeAction(tabPages["Player"], "Teleport Random", ACCENT_LIGHT, tpRandom)
    end },
    { status = "loading utility systems...", sub = "farm + fps + emotes", fn = function()
        makeToggle(tabPages["Utility"], "Coin Farm", toggleCoinFarm)
        makeToggle(tabPages["Utility"], "Coin Aura", toggleCoinAura)
        makeToggle(tabPages["Utility"], "FPS Boost", toggleFPSBoost)
        makeToggle(tabPages["Utility"], "Optimize Coins", toggleOptimizeCoins)
        makeAction(tabPages["Utility"], "Fake Unbox", ACCENT_LIGHT, fakeUnbox)
        makeAction(tabPages["Utility"], "Fake Bomb Clutch", ACCENT_LIGHT, fakeBombClutch)
        makeAction(tabPages["Utility"], "Emote: Sit", TEXT_DIM, function() playEmote("507768133") end)
        makeAction(tabPages["Utility"], "Emote: Dab", TEXT_DIM, function() playEmote("248263260") end)
        makeAction(tabPages["Utility"], "Emote: Wave", TEXT_DIM, function() playEmote("128777973") end)
        makeAction(tabPages["Utility"], "Emote: Floss", TEXT_DIM, function() playEmote("8555766494") end)
        makeAction(tabPages["Utility"], "Emote: Ninja", TEXT_DIM, function() playEmote("6595389634") end)
        makeAction(tabPages["Utility"], "Emote: Zombie", TEXT_DIM, function() playEmote("6160763406") end)
    end },
    { status = "loading misc systems...", sub = "anti-afk + kill", fn = function()
        makeToggle(tabPages["Misc"], "Anti-AFK", toggleAntiAfk)
        makeAction(tabPages["Misc"], "Kill Script", DANGER, killScript)
    end },
    { status = "finalizing...", sub = "ready", fn = function() task.wait(0.2) end },
}

task.spawn(function()
    local totalSteps = #loadSteps
    for i, step in ipairs(loadSteps) do
        LoadStatus.Text = step.status
        LoadSubtext.Text = step.sub

        local ok, err = pcall(step.fn)
        if not ok then
            warn("[NEXO E] load step error: " .. tostring(err))
        end

        local progress = i / totalSteps
        TweenService:Create(BarFill, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Size = UDim2.new(progress, 0, 1, 0)}):Play()
        LoadPercent.Text = math.floor(progress * 100) .. "%"

        if i >= 3 and i <= 7 then
            local tabName = tabs[i - 2]
            if tabName and tabButtons[tabName] then
                tabButtons[tabName].obj.Visible = true
            end
        end

        task.wait(0.35)
    end

    TweenService:Create(tabButtons["Combat"].obj, TweenInfo.new(0.2), {BackgroundColor3 = ACCENT_DIM, TextColor3 = ACCENT_LIGHT}):Play()
    tabPages["Combat"].Visible = true
    tabButtons.current = "Combat"

    task.wait(0.2)

    local fadeOut = TweenService:Create(LoadFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {BackgroundTransparency = 1})
    TweenService:Create(LoadGlow, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
    TweenService:Create(LoadIcon, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
    TweenService:Create(LoadTitle, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
    TweenService:Create(LoadStatus, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
    TweenService:Create(LoadSubtext, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
    TweenService:Create(LoadPercent, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
    TweenService:Create(BarBg, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
    TweenService:Create(BarFill, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
    fadeOut:Play()
    fadeOut.Completed:Wait()
    LoadFrame:Destroy()

    MainShadow.Visible = true
    Main.Visible = true
    Main.BackgroundTransparency = 1
    TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {BackgroundTransparency = 0}):Play()
end)

-- ─── LOOPS (PERSISTENT) ───────────────────────────────────────
task.spawn(function()
    local frameCounter = 0
    while scriptRunning do
        frameCounter = frameCounter + 1
        if frameCounter % 2 == 0 then
            safeCall(updateVisuals)
        end
        task.wait()
    end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    if not scriptRunning then return end
    safeCall(function()
        if speedActive then toggleSpeed(true) end
        if speedGlitchActive then toggleSpeedGlitch(true) end
        if hitboxActive then toggleHitbox(true) end
        if invisibleActive then toggleInvisible(true) end
        if antiFlingActive then toggleAntiFling(true) end
        if flyActive then toggleFly(true) end
        if noclipActive then toggleNoclip(true) end
        if autoDodgeActive then toggleAutoDodge(true) end
        if autoGrabGunActive then toggleAutoGrabGun(true) end
        if gunDropNotifyActive then toggleGunDropNotify(true) end
        if murderAlarmActive then toggleMurderAlarm(true) end
        if roundTimerActive then toggleRoundTimer(true) end
        if antiAfkActive then toggleAntiAfk(true) end
    end)
end)

print("[NEXO E] v2.4 loaded — modern UI, ready, Maker.")
