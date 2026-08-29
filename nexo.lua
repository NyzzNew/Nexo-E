--[[
    NEXO E — MM2 Suite v2.0 Overdrive
    Features added: Gun/Knife Aura, Invisible, FPS Boost, Auto Dodge, ESP Boxes, Emotes, etc.
    UI: 5 Tabs, optimized scrolling, sidebar layout.
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

-- ─── STEALTH UTILS ────────────────────────────────────────────
local function getProtectedParent()
    if gethui then return gethui()
    elseif syn and syn.protect_gui then local g = Instance.new("ScreenGui"); syn.protect_gui(g); return game:GetService("CoreGui")
    elseif protect_gui then local g = Instance.new("ScreenGui"); protect_gui(g); return game:GetService("CoreGui")
    else return game:GetService("CoreGui") end
end

local function randomName()
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local s = ""
    for i = 1, math.random(8, 16) do s = s .. chars:sub(math.random(1, #chars), math.random(1, #chars)) end
    return s
end

local function notify(title, text)
    StarterGui:SetCore("SendNotification", {Title = title, Text = text, Duration = 3})
end

-- ─── COLORS ───────────────────────────────────────────────────
local ACCENT = Color3.fromRGB(150, 80, 255)
local ACCENT_LIGHT = Color3.fromRGB(200, 120, 255)
local ACCENT_DIM = Color3.fromRGB(45, 30, 65)
local BG = Color3.fromRGB(20, 20, 25)
local BG_SIDE = Color3.fromRGB(15, 15, 20)
local BG_CARD = Color3.fromRGB(30, 30, 38)
local BG_HOVER = Color3.fromRGB(40, 40, 50)
local TEXT = Color3.fromRGB(240, 240, 250)
local TEXT_DIM = Color3.fromRGB(140, 140, 155)
local TOGGLE_OFF = Color3.fromRGB(50, 50, 60)
local DANGER = Color3.fromRGB(255, 80, 100)

local function corner(parent, radius)
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, radius or 8); c.Parent = parent; return c
end
local function stroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke"); s.Color = color or ACCENT_DIM; s.Thickness = thickness or 1; s.Transparency = transparency or 0.5; s.Parent = parent; return s
end
local function gradient(parent, color1, color2, rotation)
    local g = Instance.new("UIGradient"); g.Color = ColorSequence.new(color1, color2); g.Rotation = rotation or 0; g.Parent = parent; return g
end
local function padding(parent, top, bottom, left, right)
    local p = Instance.new("UIPadding"); p.PaddingTop = UDim.new(0, top or 0); p.PaddingBottom = UDim.new(0, bottom or 0); p.PaddingLeft = UDim.new(0, left or 0); p.PaddingRight = UDim.new(0, right or 0); p.Parent = parent; return p
end

-- ─── ESTADO ───────────────────────────────────────────────────
local scriptRunning = true
local state = {
    silentAim = false, knifeAim = false, gunAura = false, knifeAura = false, 
    autoGrabGun = false, gunDropNotify = false, hitbox = false, 
    esp = false, tracers = false, espBox = false, fullbright = false, 
    murderAlarm = false, fly = false, noclip = false, speed = false, 
    invisible = false, autoDodge = false, autoFarm = false, antiAfk = false, 
    fpsBoost = false, noShadows = false, optimizeCoins = false,
}
local espObjects = {}
local boxObjects = {}
local tracerObjects = {}
local flyConn, noclipConn, autoFarmConn, dodgeConn, gunAuraConn, knifeAuraConn, coinConn, alarmConn, dropConn, antiAfkConn
local originalHitboxes = {}

-- ─── ROLES ────────────────────────────────────────────────────
local function getRole(player)
    if not player or not player.Character then return "Innocent" end
    for _, tool in ipairs(player.Character:GetChildren()) do
        if tool:IsA("Tool") then
            local n = tool.Name:lower()
            if n:match("knife") then return "Murderer" end
            if n:match("gun") or n:match("revolver") or n:match("pistol") then return "Sheriff" end
        end
    end
    local bp = player:FindFirstChild("Backpack")
    if bp then
        for _, tool in ipairs(bp:GetChildren()) do
            if tool:IsA("Tool") then
                local n = tool.Name:lower()
                if n:match("knife") then return "Murderer" end
                if n:match("gun") or n:match("revolver") or n:match("pistol") then return "Sheriff" end
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

-- ─── ESP + BOXES + TRACERS ────────────────────────────────────
local roleColors = {
    Murderer = Color3.fromRGB(255, 70, 70),
    Sheriff  = Color3.fromRGB(70, 130, 255),
    Innocent = Color3.fromRGB(100, 230, 130),
}

local function clearESP()
    for _, v in pairs(espObjects) do
        if v.hl then v.hl:Destroy() end
        if v.tag then v.tag:Destroy() end
    end
    espObjects = {}
end

local function clearBoxes()
    for _, v in pairs(boxObjects) do if v then v:Destroy() end end
    boxObjects = {}
end

local function clearTracers()
    for _, v in pairs(tracerObjects) do if v then v:Destroy() end end
    tracerObjects = {}
end

local function updateVisuals()
    if not state.esp then clearESP() end
    if not state.espBox then clearBoxes() end
    if not state.tracers then clearTracers() end
    if not state.esp and not state.espBox and not state.tracers then return end
    
    local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local cam = Workspace.CurrentCamera
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                local role = getRole(p)
                local col = roleColors[role] or Color3.new(1,1,1)
                
                if state.esp then
                    if not espObjects[p] or not espObjects[p].hl or not espObjects[p].hl.Parent then
                        if espObjects[p] then
                            if espObjects[p].hl then espObjects[p].hl:Destroy() end
                            if espObjects[p].tag then espObjects[p].tag:Destroy() end
                        end
                        local hl = Instance.new("Highlight")
                        hl.Name = randomName()
                        hl.FillTransparency = 0.6; hl.FillColor = col; hl.OutlineColor = col; hl.OutlineTransparency = 0
                        hl.Parent = p.Character
                        local tag = Instance.new("BillboardGui")
                        tag.Name = randomName()
                        tag.Size = UDim2.new(0, 140, 0, 28); tag.StudsOffset = Vector3.new(0, 3, 0); tag.AlwaysOnTop = true
                        tag.Parent = hrp
                        local lbl = Instance.new("TextLabel")
                        lbl.Name = randomName()
                        lbl.Size = UDim2.new(1, 0, 1, 0); lbl.BackgroundTransparency = 1; lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 11; lbl.TextColor3 = col
                        lbl.Parent = tag
                        espObjects[p] = { hl = hl, tag = tag, lbl = lbl }
                    end
                    local e = espObjects[p]
                    e.hl.FillColor = col; e.hl.OutlineColor = col; e.hl.Parent = p.Character; e.tag.Parent = hrp
                    local dist = myHrp and math.floor((hrp.Position - myHrp.Position).Magnitude) or 0
                    e.lbl.Text = p.Name .. "  " .. role .. "  " .. dist .. "m"; e.lbl.TextColor3 = col
                end
                
                if state.espBox then
                    if not boxObjects[p] or not boxObjects[p].Parent then
                        local box = Instance.new("BillboardGui")
                        box.Name = randomName()
                        box.Size = UDim2.new(0, 100, 0, 100)
                        box.AlwaysOnTop = true
                        box.Parent = hrp
                        local frame = Instance.new("Frame")
                        frame.Name = randomName()
                        frame.Size = UDim2.new(1, 0, 1, 0)
                        frame.BackgroundTransparency = 1
                        frame.Parent = box
                        local s = Instance.new("UIStroke"); s.Color = col; s.Thickness = 2; s.Parent = frame
                        boxObjects[p] = box
                    end
                    boxObjects[p].Parent = hrp
                end
                
                if state.tracers then
                    if not tracerObjects[p] or not tracerObjects[p].Parent then
                        local line = Instance.new("Frame")
                        line.Name = randomName()
                        line.BackgroundColor3 = col; line.BorderSizePixel = 0; line.AnchorPoint = Vector2.new(0.5, 0.5)
                        line.Parent = ScreenGui
                        tracerObjects[p] = line
                    end
                    local line = tracerObjects[p]
                    line.BackgroundColor3 = col
                    local screenPos, onScreen = cam:WorldToViewportPoint(hrp.Position)
                    if onScreen then
                        line.Visible = true
                        line.Size = UDim2.new(0, 1, 0, math.abs(screenPos.Y - (cam.ViewportSize.Y/2)))
                        line.Position = UDim2.new(0, screenPos.X, 0, screenPos.Y)
                    else
                        line.Visible = false
                    end
                end
            else
                if espObjects[p] then
                    if espObjects[p].hl then espObjects[p].hl:Destroy() end
                    if espObjects[p].tag then espObjects[p].tag:Destroy() end
                    espObjects[p] = nil
                end
                if boxObjects[p] then boxObjects[p]:Destroy(); boxObjects[p] = nil end
                if tracerObjects[p] then tracerObjects[p]:Destroy(); tracerObjects[p] = nil end
            end
        end
    end
end

-- ─── GUN SILENT AIM (PC + MOBILE) ─────────────────────────────
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

local cachedMurderer = nil
local lastMurdererCheck = 0

local function getMurdererOptimized()
    local now = os.clock()
    if now - lastMurdererCheck > 1 then
        cachedMurderer = getMurderer()
        lastMurdererCheck = now
    end
    return cachedMurderer
end

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if state.silentAim and method and (method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRay" or method == "FindPartOnRayWithWhitelist" or method == "Raycast") then
        if not checkcaller() then
            local char = LocalPlayer.Character
            if char then
                local hasGun = false
                for _, t in ipairs(char:GetChildren()) do
                    if t:IsA("Tool") and t.Name:lower():match("gun") then hasGun = true break end
                end
                
                if hasGun then
                    local murderer = getMurdererOptimized()
                    if murderer and murderer.Character then
                        local target = murderer.Character:FindFirstChild("Head") or murderer.Character:FindFirstChild("HumanoidRootPart")
                        if target then
                            local args = {...}
                            local cam = Workspace.CurrentCamera
                            
                            if method == "Raycast" then
                                local origin = args[1]
                                if origin and (origin - cam.CFrame.Position).Magnitude < 5 then
                                    args[2] = (target.Position - origin).Unit * 3000
                                    return oldNamecall(self, unpack(args))
                                end
                            else
                                local ray = args[1]
                                if typeof(ray) == "Ray" then
                                    if ray.Origin and (ray.Origin - cam.CFrame.Position).Magnitude < 5 then
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
    return oldNamecall(self, ...)
end)

setreadonly(mt, true)

-- ─── FEATURE FUNCTIONS ────────────────────────────────────────
local function toggleKnifeAim(on)
    state.knifeAim = on
    if on then
        knifeAuraConn = RunService.Heartbeat:Connect(function()
            local tool = hasTool("knife"); if not tool then return end
            local target = getNearestPlayer("Innocent") or getNearestPlayer("Sheriff")
            if not target or not target.Character then return end
            local tHrp = target.Character:FindFirstChild("HumanoidRootPart")
            local tHum = target.Character:FindFirstChildOfClass("Humanoid")
            if not tHrp or not tHum or tHum.Health <= 0 then return end
            local char = LocalPlayer.Character; if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
            if (tHrp.Position - hrp.Position).Magnitude < 35 then
                task.spawn(function() tool:Activate() end)
            end
        end)
    else
        if knifeAuraConn then knifeAuraConn:Disconnect() knifeAuraConn = nil end
    end
end

local function toggleGunAura(on)
    state.gunAura = on
    if on then
        gunAuraConn = RunService.Heartbeat:Connect(function()
            local tool = hasTool("gun"); if not tool then return end
            local target = getMurderer()
            if target and target.Character then
                local tHum = target.Character:FindFirstChildOfClass("Humanoid")
                if tHum and tHum.Health > 0 then
                    task.spawn(function() tool:Activate() end)
                end
            end
        end)
    else
        if gunAuraConn then gunAuraConn:Disconnect() gunAuraConn = nil end
    end
end

local function toggleAutoGrabGun(on)
    state.autoGrabGun = on
    if on then
        dropConn = RunService.Heartbeat:Connect(function()
            if hasTool("gun") then return end
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("Tool") and obj.Name:lower():match("gun") then
                    local handle = obj:FindFirstChild("Handle") or obj:FindFirstChildWhichIsA("BasePart")
                    if handle then
                        local char = LocalPlayer.Character; if char then
                            local hrp = char:FindFirstChild("HumanoidRootPart")
                            if hrp then
                                local dist = (handle.Position - hrp.Position).Magnitude
                                if dist < 500 then
                                    task.spawn(function()
                                        hrp.CFrame = CFrame.new(handle.Position)
                                        task.wait(0.1)
                                        firetouchinterest(hrp, handle, 0)
                                        firetouchinterest(hrp, handle, 1)
                                    end)
                                end
                            end
                        end
                    end
                end
            end
        end)
    else
        if dropConn then dropConn:Disconnect() dropConn = nil end
    end
end

local function toggleHitbox(on)
    state.hitbox = on
    if on then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    originalHitboxes[p] = hrp.Size
                    task.spawn(function() hrp.Size = Vector3.new(5,5,5); hrp.Transparency = 0.3; hrp.CanCollide = false end)
                end
            end
        end
    else
        for p, size in pairs(originalHitboxes) do
            if p.Character then
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if hrp then task.spawn(function() hrp.Size = size; hrp.Transparency = 1 end) end
            end
        end
        originalHitboxes = {}
    end
end

local function toggleFullbright(on)
    state.fullbright = on
    if on then
        task.spawn(function()
            Lighting.Brightness = 3; Lighting.ClockTime = 12; Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false; Lighting.Ambient = Color3.fromRGB(178, 178, 178)
        end)
    else
        Lighting.Brightness = 2; Lighting.ClockTime = 14; Lighting.FogEnd = 100000
        Lighting.GlobalShadows = true; Lighting.Ambient = Color3.fromRGB(100, 100, 100)
    end
end

local function toggleInvisible(on)
    state.invisible = on
    local char = LocalPlayer.Character
    if char then
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
                p.LocalTransparencyModifier = on and 1 or 0
            end
        end
    end
end

local function toggleAutoDodge(on)
    state.autoDodge = on
    if on then
        dodgeConn = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character; if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
            local murderer = getMurderer()
            if murderer and murderer.Character then
                local mHrp = murderer.Character:FindFirstChild("HumanoidRootPart")
                if mHrp then
                    if (mHrp.Position - hrp.Position).Magnitude < 15 then
                        hrp.CFrame = hrp.CFrame * CFrame.new(0, 0, 20)
                    end
                end
            end
        end)
    else
        if dodgeConn then dodgeConn:Disconnect() dodgeConn = nil end
    end
end

local function toggleFPSBoost(on)
    state.fpsBoost = on
    if on then
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Material = Enum.Material.SmoothPlastic
            end
        end
    else
        -- Revert is complex without storing originals, leaving smooth plastic is safer for performance
    end
end

local function toggleNoShadows(on)
    state.noShadows = on
    Lighting.GlobalShadows = not on
end

local function toggleOptimizeCoins(on)
    state.optimizeCoins = on
    if on then
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") and (v.Name:lower():match("coin") or v.Name:lower():match("pickup")) then
                v.Material = Enum.Material.SmoothPlastic
                v.Reflectance = 0
            end
        end
    end
end

local alarmGui
local function toggleMurderAlarm(on)
    state.murderAlarm = on
    if on then
        if not alarmGui then
            alarmGui = Instance.new("TextLabel")
            alarmGui.Name = randomName()
            alarmGui.Size = UDim2.new(0, 280, 0, 44); alarmGui.Position = UDim2.new(0.5, -140, 0, 16)
            alarmGui.BackgroundColor3 = Color3.fromRGB(40, 10, 15); alarmGui.TextColor3 = Color3.fromRGB(255, 100, 100)
            alarmGui.Font = Enum.Font.GothamBold; alarmGui.TextSize = 14; alarmGui.Text = ""; alarmGui.Visible = false
            corner(alarmGui, 8); stroke(alarmGui, Color3.fromRGB(200, 50, 50), 1, 0.3)
            alarmGui.Parent = ScreenGui
        end
        alarmConn = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character; if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
            local murderer = getMurderer()
            if murderer and murderer.Character then
                local mHrp = murderer.Character:FindFirstChild("HumanoidRootPart")
                if mHrp then
                    local dist = (mHrp.Position - hrp.Position).Magnitude
                    if dist < 30 then
                        alarmGui.Visible = true
                        alarmGui.Text = "MURDERER NEAR  " .. math.floor(dist) .. "m  " .. murderer.Name
                    else alarmGui.Visible = false end
                end
            else alarmGui.Visible = false end
        end)
    else
        if alarmConn then alarmConn:Disconnect() alarmConn = nil end
        if alarmGui then alarmGui.Visible = false end
    end
end

local function toggleAntiAfk(on)
    state.antiAfk = on
    if on then
        antiAfkConn = LocalPlayer.Idled:Connect(function()
            task.spawn(function() VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new()) end)
        end)
    else
        if antiAfkConn then antiAfkConn:Disconnect() antiAfkConn = nil end
    end
end

local flySpeed = 60
local function toggleFly(on)
    state.fly = on
    if on then
        local char = LocalPlayer.Character; if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        local bv = Instance.new("BodyVelocity")
        bv.Name = randomName(); bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge); bv.Velocity = Vector3.zero
        bv.Parent = hrp
        flyConn = RunService.RenderStepped:Connect(function()
            if not state.fly then return end
            local cam = Workspace.CurrentCamera; local move = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move = move - Vector3.new(0,1,0) end
            bv.Velocity = move * flySpeed
        end)
    else
        if flyConn then flyConn:Disconnect() flyConn = nil end
        local char = LocalPlayer.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then for _, v in ipairs(hrp:GetChildren()) do if v:IsA("BodyVelocity") then v:Destroy() end end end
        end
    end
end

local function toggleNoclip(on)
    state.noclip = on
    if on then
        noclipConn = RunService.Stepped:Connect(function()
            local char = LocalPlayer.Character
            if char then
                for _, p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
                end
            end
        end)
    else
        if noclipConn then noclipConn:Disconnect() noclipConn = nil end
    end
end

local function toggleSpeed(on) state.speed = on; local char = LocalPlayer.Character; if char then local hum = char:FindFirstChildOfClass("Humanoid") if hum then task.spawn(function() hum.WalkSpeed = on and 50 or 16 end) end end end

local function toggleCoinFarm(on)
    state.coinFarm = on
    if on then
        coinConn = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character; if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("BasePart") and (obj.Name:lower():match("coin") or obj.Name:lower():match("pickup")) then
                    if (obj.Position - hrp.Position).Magnitude < 200 then
                        task.spawn(function() obj.Position = hrp.Position end)
                    end
                end
            end
        end)
    else
        if coinConn then coinConn:Disconnect() coinConn = nil end
    end
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
        if myHrp and tHrp then task.spawn(function() myHrp.CFrame = tHrp.CFrame * CFrame.new(0, 0, 3) end) end
    end
end

local function forceSheriffShoot()
    local sheriff = getSheriff()
    if sheriff and sheriff.Character then
        local tool = sheriff.Character:FindFirstChildOfClass("Tool")
        if tool and tool.Name:lower():match("gun") then
            tool:Activate()
        end
    end
end

local function playEmote(name)
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            local emote = Instance.new("Animation")
            emote.AnimationId = "rbxassetid://" .. name
            local track = hum:LoadAnimation(emote)
            track:Play()
        end
    end
end

-- ─── MAIN GUI ─────────────────────────────────────────────────
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = randomName()
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = getProtectedParent()

-- ─── FLOATING BUTTON ──────────────────────────────────────────
local FloatBtn = Instance.new("TextButton")
FloatBtn.Name = randomName()
FloatBtn.Size = UDim2.new(0, 45, 0, 45)
FloatBtn.Position = UDim2.new(0, 20, 0.5, -22)
FloatBtn.BackgroundColor3 = BG_SIDE
FloatBtn.Text = "N"
FloatBtn.TextColor3 = ACCENT_LIGHT
FloatBtn.Font = Enum.Font.GothamBlack
FloatBtn.TextSize = 20
FloatBtn.Visible = false
FloatBtn.Parent = ScreenGui
corner(FloatBtn, 25)
local floatStroke = stroke(FloatBtn, ACCENT, 1.5, 0.2)

local FloatGlow = Instance.new("Frame")
FloatGlow.Name = randomName()
FloatGlow.Size = UDim2.new(1, 20, 1, 20)
FloatGlow.Position = UDim2.new(0, -10, 0, -10)
FloatGlow.BackgroundColor3 = ACCENT
FloatGlow.BackgroundTransparency = 0.95
FloatGlow.BorderSizePixel = 0
FloatGlow.Visible = false
FloatGlow.Parent = FloatBtn
corner(FloatGlow, 30)

do
    local dragging, dragStart, startPos
    FloatBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = FloatBtn.Position
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
LoadFrame.Size = UDim2.new(0, 380, 0, 200)
LoadFrame.Position = UDim2.new(0.5, -190, 0.5, -100)
LoadFrame.BackgroundColor3 = BG
LoadFrame.BorderSizePixel = 0
LoadFrame.Parent = ScreenGui
corner(LoadFrame, 14)
stroke(LoadFrame, ACCENT_DIM, 1, 0.2)

local LoadGlow = Instance.new("Frame")
LoadGlow.Name = randomName()
LoadGlow.Size = UDim2.new(1, 0, 1, 0)
LoadGlow.BackgroundColor3 = ACCENT
LoadGlow.BackgroundTransparency = 0.9
LoadGlow.BorderSizePixel = 0
LoadGlow.Parent = LoadFrame
corner(LoadGlow, 14)

local LoadTitle = Instance.new("TextLabel")
LoadTitle.Name = randomName()
LoadTitle.Size = UDim2.new(1, -32, 0, 40)
LoadTitle.Position = UDim2.new(0, 16, 0, 30)
LoadTitle.BackgroundTransparency = 1
LoadTitle.Text = "NEXO E"
LoadTitle.TextColor3 = TEXT
LoadTitle.Font = Enum.Font.GothamBlack
LoadTitle.TextSize = 28
LoadTitle.TextXAlignment = Enum.TextXAlignment.Left
LoadTitle.Parent = LoadFrame
gradient(LoadTitle, ACCENT_LIGHT, ACCENT, 0)

local LoadStatus = Instance.new("TextLabel")
LoadStatus.Name = randomName()
LoadStatus.Size = UDim2.new(1, -100, 0, 18)
LoadStatus.Position = UDim2.new(0, 16, 0, 75)
LoadStatus.BackgroundTransparency = 1
LoadStatus.Text = "initializing..."
LoadStatus.TextColor3 = TEXT_DIM
LoadStatus.Font = Enum.Font.GothamMedium
LoadStatus.TextSize = 12
LoadStatus.TextXAlignment = Enum.TextXAlignment.Left
LoadStatus.Parent = LoadFrame

local BarBg = Instance.new("Frame")
BarBg.Name = randomName()
BarBg.Size = UDim2.new(1, -32, 0, 4)
BarBg.Position = UDim2.new(0, 16, 0, 115)
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
LoadPercent.Size = UDim2.new(0, 60, 0, 18)
LoadPercent.Position = UDim2.new(1, -76, 0, 75)
LoadPercent.BackgroundTransparency = 1
LoadPercent.Text = "0%"
LoadPercent.TextColor3 = ACCENT
LoadPercent.Font = Enum.Font.GothamBold
LoadPercent.TextSize = 12
LoadPercent.TextXAlignment = Enum.TextXAlignment.Right
LoadPercent.Parent = LoadFrame

local LoadSubtext = Instance.new("TextLabel")
LoadSubtext.Name = randomName()
LoadSubtext.Size = UDim2.new(1, -32, 0, 16)
LoadSubtext.Position = UDim2.new(0, 16, 0, 130)
LoadSubtext.BackgroundTransparency = 1
LoadSubtext.Text = ""
LoadSubtext.TextColor3 = Color3.fromRGB(80, 80, 95)
LoadSubtext.Font = Enum.Font.Gotham
LoadSubtext.TextSize = 10
LoadSubtext.TextXAlignment = Enum.TextXAlignment.Left
LoadSubtext.Parent = LoadFrame

-- ─── DROP SHADOW & MAIN FRAME ─────────────────────────────────
local MainShadow = Instance.new("Frame")
MainShadow.Name = randomName()
MainShadow.Size = UDim2.new(0, 500, 0, 380)
MainShadow.Position = UDim2.new(0.5, -250, 0.5, -190)
MainShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainShadow.BackgroundTransparency = 0.5
MainShadow.BorderSizePixel = 0
MainShadow.Visible = false
MainShadow.Parent = ScreenGui
corner(MainShadow, 16)

local Main = Instance.new("Frame")
Main.Name = randomName()
Main.Size = UDim2.new(0, 480, 0, 360)
Main.Position = UDim2.new(0.5, -240, 0.5, -180)
Main.BackgroundColor3 = BG
Main.BorderSizePixel = 0
Main.Visible = false
Main.Parent = ScreenGui
corner(Main, 12)
stroke(Main, ACCENT_DIM, 1, 0.1)

do
    local dragging, dragStart, startPos
    Main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = Main.Position
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
            MainShadow.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X + 5, startPos.Y.Scale, startPos.Y.Offset + delta.Y + 5)
        end
    end)
end

-- ─── SIDEBAR ──────────────────────────────────────────────────
local Sidebar = Instance.new("Frame")
Sidebar.Name = randomName()
Sidebar.Size = UDim2.new(0, 120, 1, 0)
Sidebar.BackgroundColor3 = BG_SIDE
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Main
corner(Sidebar, 12)

local SideTitle = Instance.new("TextLabel")
SideTitle.Name = randomName()
SideTitle.Size = UDim2.new(1, 0, 0, 50)
SideTitle.BackgroundTransparency = 1
SideTitle.Text = "NEXO E"
SideTitle.TextColor3 = TEXT
SideTitle.Font = Enum.Font.GothamBlack
SideTitle.TextSize = 16
SideTitle.Parent = Sidebar
gradient(SideTitle, ACCENT_LIGHT, ACCENT, 0)

local tabs = {"Combat", "Visuals", "Player", "Utility", "Misc"}
local tabButtons = {}
local tabPages = {}

for i, name in ipairs(tabs) do
    local tabBtn = Instance.new("TextButton")
    tabBtn.Name = randomName()
    tabBtn.Size = UDim2.new(1, -20, 0, 28)
    tabBtn.Position = UDim2.new(0, 10, 0, 50 + (i-1)*32)
    tabBtn.BackgroundColor3 = BG_CARD
    tabBtn.BorderSizePixel = 0
    tabBtn.Text = name
    tabBtn.TextColor3 = TEXT_DIM
    tabBtn.Font = Enum.Font.GothamBold
    tabBtn.TextSize = 11
    tabBtn.AutoButtonColor = false
    corner(tabBtn, 6)
    tabBtn.Parent = Sidebar

    tabBtn.MouseButton1Click:Connect(function()
        for _, btn in pairs(tabButtons) do
            if type(btn) == "table" then
                TweenService:Create(btn.obj, TweenInfo.new(0.2), {BackgroundColor3 = BG_CARD, TextColor3 = TEXT_DIM}):Play()
                btn.page.Visible = false
            end
        end
        TweenService:Create(tabBtn, TweenInfo.new(0.2), {BackgroundColor3 = ACCENT_DIM, TextColor3 = ACCENT_LIGHT}):Play()
        tabPages[name].Visible = true
        tabButtons.current = name
    end)

    tabButtons[name] = { obj = tabBtn, page = nil }

    local page = Instance.new("ScrollingFrame")
    page.Name = randomName()
    page.Size = UDim2.new(1, -140, 1, -20)
    page.Position = UDim2.new(0, 130, 0, 10)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 2
    page.ScrollBarImageColor3 = ACCENT_DIM
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    page.Parent = Main

    local pageLayout = Instance.new("UIListLayout")
    pageLayout.Padding = UDim.new(0, 8)
    pageLayout.Parent = page

    padding(page, 0, 10, 0, 10)

    tabPages[name] = page
    tabButtons[name].page = page
end

-- ─── FOOTER (SIDEBAR) ─────────────────────────────────────────
local SideFoot = Instance.new("Frame")
SideFoot.Name = randomName()
SideFoot.Size = UDim2.new(1, 0, 0, 36)
SideFoot.Position = UDim2.new(0, 0, 1, -36)
SideFoot.BackgroundTransparency = 1
SideFoot.Parent = Sidebar

local closeBtn = Instance.new("TextButton")
closeBtn.Name = randomName()
closeBtn.Size = UDim2.new(1, -20, 0, 28)
closeBtn.Position = UDim2.new(0, 10, 0.5, -14)
closeBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 25)
closeBtn.BorderSizePixel = 0
closeBtn.Text = "Close"
closeBtn.TextColor3 = DANGER
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 11
closeBtn.AutoButtonColor = false
corner(closeBtn, 6)
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
    container.Size = UDim2.new(1, 0, 0, 32)
    container.BackgroundColor3 = BG_CARD
    container.BorderSizePixel = 0
    container.Text = ""
    container.AutoButtonColor = false
    corner(container, 8)
    local stk = stroke(container, Color3.fromRGB(40, 40, 50), 1, 0)
    container.Parent = parent

    local label = Instance.new("TextLabel")
    label.Name = randomName()
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = TEXT
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local toggleBg = Instance.new("Frame")
    toggleBg.Name = randomName()
    toggleBg.Size = UDim2.new(0, 36, 0, 18)
    toggleBg.Position = UDim2.new(1, -46, 0.5, -9)
    toggleBg.BackgroundColor3 = TOGGLE_OFF
    toggleBg.BorderSizePixel = 0
    corner(toggleBg, 9)
    toggleBg.Parent = container

    local toggleKnob = Instance.new("Frame")
    toggleKnob.Name = randomName()
    toggleKnob.Size = UDim2.new(0, 14, 0, 14)
    toggleKnob.Position = UDim2.new(0, 2, 0.5, -7)
    toggleKnob.BackgroundColor3 = Color3.fromRGB(120, 120, 130)
    toggleKnob.BorderSizePixel = 0
    corner(toggleKnob, 7)
    toggleKnob.Parent = toggleBg

    local on = false
    container.MouseButton1Click:Connect(function()
        on = not on
        if on then
            TweenService:Create(toggleBg, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundColor3 = ACCENT}):Play()
            TweenService:Create(toggleKnob, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(1, -16, 0.5, -7), BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
            label.TextColor3 = ACCENT_LIGHT
            stk.Color = ACCENT_DIM
        else
            TweenService:Create(toggleBg, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundColor3 = TOGGLE_OFF}):Play()
            TweenService:Create(toggleKnob, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0, 2, 0.5, -7), BackgroundColor3 = Color3.fromRGB(120, 120, 130)}):Play()
            label.TextColor3 = TEXT
            stk.Color = Color3.fromRGB(40, 40, 50)
        end
        callback(on)
    end)

    container.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            TweenService:Create(container, TweenInfo.new(0.15), {BackgroundColor3 = BG_HOVER}):Play()
        end
    end)
    container.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            TweenService:Create(container, TweenInfo.new(0.15), {BackgroundColor3 = BG_CARD}):Play()
        end
    end)
end

local function makeAction(parent, text, color, callback)
    local btn = Instance.new("TextButton")
    btn.Name = randomName()
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = BG_CARD
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = color or TEXT
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.AutoButtonColor = false
    corner(btn, 8)
    stroke(btn, color and Color3.new(color.R * 0.3, color.G * 0.3, color.B * 0.3) or ACCENT_DIM, 1, 0)
    btn.Parent = parent

    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = BG_HOVER}):Play()
        end
    end)
    btn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = BG_CARD}):Play()
        end
    end)
    btn.MouseButton1Click:Connect(callback)
end

-- ─── LOADING SEQUENCE ─────────────────────────────────────────
local loadSteps = {
    { status = "booting core modules...",         sub = "hooking metamethods", fn = function() task.wait(0.3) end },
    { status = "establishing stealth layer...",    sub = "gethui + randomization", fn = function() task.wait(0.25) end },
    { status = "loading combat systems...",        sub = "silent aim + aura", fn = function()
        makeToggle(tabPages["Combat"], "Gun Silent Aim", function(on) state.silentAim = on end)
        makeToggle(tabPages["Combat"], "Knife Silent Aim", toggleKnifeAim)
        makeToggle(tabPages["Combat"], "Gun Aura", toggleGunAura)
        makeToggle(tabPages["Combat"], "Auto Grab Gun", toggleAutoGrabGun)
        makeToggle(tabPages["Combat"], "Hitbox Expander", toggleHitbox)
        makeAction(tabPages["Combat"], "Force Sheriff Shoot", ACCENT_LIGHT, forceSheriffShoot)
    end },
    { status = "loading visual systems...",        sub = "esp + boxes + tracers", fn = function()
        makeToggle(tabPages["Visuals"], "ESP (Roles + Dist)", function(on) state.esp = on end)
        makeToggle(tabPages["Visuals"], "ESP Boxes", function(on) state.espBox = on end)
        makeToggle(tabPages["Visuals"], "Tracers", function(on) state.tracers = on end)
        makeToggle(tabPages["Visuals"], "Fullbright", toggleFullbright)
        makeToggle(tabPages["Visuals"], "No Shadows", toggleNoShadows)
        makeToggle(tabPages["Visuals"], "Murderer Alarm", toggleMurderAlarm)
    end },
    { status = "loading player systems...",        sub = "fly + noclip + speed", fn = function()
        makeToggle(tabPages["Player"], "Fly (WASD/Space/Ctrl)", toggleFly)
        makeToggle(tabPages["Player"], "Noclip", toggleNoclip)
        makeToggle(tabPages["Player"], "Speed x3", toggleSpeed)
        makeToggle(tabPages["Player"], "Invisible", toggleInvisible)
        makeToggle(tabPages["Player"], "Auto Dodge Murderer", toggleAutoDodge)
        makeAction(tabPages["Player"], "Teleport Random", ACCENT_LIGHT, tpRandom)
    end },
    { status = "loading utility systems...",       sub = "farm + fps + emotes", fn = function()
        makeToggle(tabPages["Utility"], "Coin Farm", toggleCoinFarm)
        makeToggle(tabPages["Utility"], "FPS Boost", toggleFPSBoost)
        makeToggle(tabPages["Utility"], "Optimize Coins", toggleOptimizeCoins)
        makeAction(tabPages["Utility"], "Emote: Sit", TEXT_DIM, function() playEmote("507768133") end)
        makeAction(tabPages["Utility"], "Emote: Dab", TEXT_DIM, function() playEmote("248263260") end)
        makeAction(tabPages["Utility"], "Emote: Wave", TEXT_DIM, function() playEmote("128777973") end)
    end },
    { status = "loading misc systems...",          sub = "anti-afk + kill", fn = function()
        makeToggle(tabPages["Misc"], "Anti-AFK", toggleAntiAfk)
        makeAction(tabPages["Misc"], "Kill Script", DANGER, function()
            scriptRunning = false
            clearESP(); clearBoxes(); clearTracers()
            for _, conn in pairs({flyConn, noclipConn, autoFarmConn, dodgeConn, gunAuraConn, knifeAuraConn, coinConn, alarmConn, dropConn, antiAfkConn}) do
                if conn then conn:Disconnect() end
            end
            toggleHitbox(false); toggleFullbright(false); toggleInvisible(false)
            if alarmGui then alarmGui:Destroy() end
            state.silentAim = false
            ScreenGui:Destroy()
        end)
    end },
    { status = "finalizing...",                     sub = "ready", fn = function() task.wait(0.2) end },
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
                local tb = tabButtons[tabName].obj
                tb.Visible = true
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
    while scriptRunning do
        updateVisuals()
        task.wait(0.3)
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if not scriptRunning then return end
    if state.speed then toggleSpeed(true) end
    if state.hitbox then toggleHitbox(true) end
    if state.invisible then toggleInvisible(true) end
end)

print("[NEXO E] loaded — welcome, Maker.")
