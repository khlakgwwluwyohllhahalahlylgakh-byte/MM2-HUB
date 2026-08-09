-- ==========================================
-- MM2 Masterpiece Hub v16.0 | KATİL HEDEFLİ
-- Aimbot Artık Sadece Murderer'ı Hedefliyor
-- ==========================================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local Camera = Workspace.CurrentCamera

-- ==========================================
-- BAĞLANTI HAVUZU (Memory Leak Korumalı)
-- ==========================================
local Connections = {
    Dodge = nil, AntiKnife = nil, SmartFarm = nil, Noclip = nil,
    RoleESP = nil, FullBright = nil, Hitbox = nil, InfJump = nil,
    Spinbot = nil, Bhop = nil, AutoGun = nil, AntiAFK = nil,
    Aimbot = nil, XRay = nil, Triggerbot = nil, Prediction = nil
}

local function KillConnection(name)
    if Connections[name] then
        Connections[name]:Disconnect()
        Connections[name] = nil
    end
end

local XRayParts = {}
local AimbotSettings = {
    FOV = 150,
    Smoothness = 0.15,
    Prediction = true,
    SilentAim = false,
    Triggerbot = false,
    InnocentProtection = true
}

local FovCircle = Drawing.new("Circle")
FovCircle.Thickness = 2
FovCircle.NumSides = 60
FovCircle.Radius = 150
FovCircle.Filled = false
FovCircle.Color = Color3.fromRGB(255, 0, 0)
FovCircle.Visible = false
FovCircle.Transparency = 0.8

local function GetMurderer()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local pChar = p.Character
            local backpack = p:FindFirstChild("Backpack")
            local humanoid = pChar:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                if pChar:FindFirstChild("Knife") or (backpack and backpack:FindFirstChild("Knife")) then
                    return p
                end
            end
        end
    end
    return nil
end

local function GetSheriff()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local pChar = p.Character
            local backpack = p:FindFirstChild("Backpack")
            local humanoid = pChar:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                if pChar:FindFirstChild("Gun") or (backpack and backpack:FindFirstChild("Gun")) then
                    return p
                end
            end
        end
    end
    return nil
end

local function IsInnocent(player)
    if not player or not player.Character then return false end
    local pChar = player.Character
    local backpack = player:FindFirstChild("Backpack")
    local hasKnife = pChar:FindFirstChild("Knife") or (backpack and backpack:FindFirstChild("Knife"))
    local hasGun = pChar:FindFirstChild("Gun") or (backpack and backpack:FindFirstChild("Gun"))
    return not hasKnife and not hasGun
end

local function IsSheriff()
    local char = LocalPlayer.Character
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    return char:FindFirstChild("Gun") or (backpack and backpack:FindFirstChild("Gun"))
end

local function FullCleanup()
    for name, _ in pairs(Connections) do
        KillConnection(name)
    end
    
    _G.EmergencyDodge = false
    _G.AntiKnife = false
    _G.SmartFarm = false
    _G.NoclipActive = false
    _G.RoleESP = false
    _G.FullBright = false
    _G.InfJump = false
    _G.Spinbot = false
    _G.HitboxExpand = false
    _G.XRayActive = false
    _G.AutoGun = false
    _G.Bhop = false
    _G.Aimbot = false
    _G.Triggerbot = false
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then
            for _, esp in ipairs(p.Character:GetChildren()) do
                if esp.Name:find("MM2") then esp:Destroy() end
            end
        end
    end
    
    for _, part in ipairs(XRayParts) do
        if part and part.Parent then part.LocalTransparencyModifier = 0 end
    end
    table.clear(XRayParts)
    
    FovCircle.Visible = false
    
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = 16
        LocalPlayer.Character.Humanoid.JumpPower = 50
    end
    
    Lighting.GlobalShadows = true
    Lighting.Brightness = 2
    Lighting.ClockTime = 14
    Workspace.Gravity = 196.2
end

-- ==========================================
-- RAYFIELD UI
-- ==========================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "MM2 Masterpiece Hub v16.0",
    LoadingTitle = "Katil Avcısı Yükleniyor...",
    LoadingSubtitle = "Murderer Hunter Edition",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "MM2MasterpieceConfig",
        FileName = "MM2_Settings_v16"
    },
    Discord = { Enabled = false },
    KeySystem = false
})

local ProtectionTab = Window:CreateTab("🛡️ Koruma", 4483362458)
local FarmTab       = Window:CreateTab("💰 Farm", 4483362458)
local CombatTab     = Window:CreateTab("🎯 Savaş (YENİ)", 4483362458)
local VisualsTab    = Window:CreateTab("👁️ Görsel", 4483362458)
local PlayerTab     = Window:CreateTab("🏃 Karakter", 4483362458)
local TeleportTab   = Window:CreateTab("⚡ Işınlanma", 4483362458)
local MiscTab       = Window:CreateTab("🔧 Ekstralar", 4483362458)

-- ==========================================
-- GLOBAL NOCLIP
-- ==========================================
RunService.Stepped:Connect(function()
    if _G.NoclipActive and LocalPlayer.Character then
        pcall(function()
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.CanCollide = false
                end
            end
        end)
    end
end)

-- ==========================================
-- 1. KORUMA
-- ==========================================
ProtectionTab:CreateSection("Savunma Sistemleri")

ProtectionTab:CreateToggle({
    Name = "Acil Kaçış Kalkanı",
    CurrentValue = false,
    Flag = "EmergencyDodgeToggle",
    Callback = function(state)
        _G.EmergencyDodge = state
        if state then
            Connections.Dodge = RunService.Heartbeat:Connect(function()
                if not _G.EmergencyDodge then return end
                pcall(function()
                    local char = LocalPlayer.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if not hrp then return end
                    
                    local murderer = GetMurderer()
                    if murderer and murderer.Character then
                        local pHrp = murderer.Character:FindFirstChild("HumanoidRootPart")
                        if pHrp then
                            local dist = (hrp.Position - pHrp.Position).Magnitude
                            if dist < 14 then
                                local escapeDir = (hrp.Position - pHrp.Position)
                                escapeDir = Vector3.new(escapeDir.X, 0, escapeDir.Z).Unit
                                local targetPos = hrp.Position + (escapeDir * 32) + Vector3.new(0, 15, 0)
                                
                                local raycastParams = RaycastParams.new()
                                raycastParams.FilterType = Enum.RaycastFilterType.Exclude
                                raycastParams.FilterDescendantsInstances = {char, murderer.Character}
                                
                                local rayResult = Workspace:Raycast(targetPos, Vector3.new(0, -60, 0), raycastParams)
                                if rayResult and rayResult.Instance and rayResult.Instance.CanCollide then
                                    hrp.CFrame = CFrame.new(rayResult.Position + Vector3.new(0, 3, 0))
                                else
                                    hrp.CFrame = CFrame.new(0, 20, 0)
                                end
                            end
                        end
                    end
                end)
            end)
        else
            KillConnection("Dodge")
        end
    end,
})

ProtectionTab:CreateToggle({
    Name = "Bıçak Gizleyici",
    CurrentValue = false,
    Flag = "AntiKnifeToggle",
    Callback = function(state)
        _G.AntiKnife = state
        if state then
            Connections.AntiKnife = Workspace.ChildAdded:Connect(function(child)
                if not _G.AntiKnife then return end
                local name = child.Name:lower()
                if name:find("knife") or name:find("thrown") or name:find("dagger") then
                    task.spawn(function()
                        pcall(function()
                            child.LocalTransparencyModifier = 1
                            if child:IsA("BasePart") then
                                child.Size = Vector3.new(0.1, 0.1, 0.1)
                                child.Transparency = 1
                            end
                        end)
                    end)
                end
            end)
        else
            KillConnection("AntiKnife")
        end
    end,
})

ProtectionTab:CreateToggle({
    Name = "Görünmezlik Modu",
    CurrentValue = false,
    Flag = "StealthToggle",
    Callback = function(state)
        pcall(function()
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        part.Transparency = state and 0.6 or 0
                    end
                end
            end
        end)
    end,
})

ProtectionTab:CreateToggle({
    Name = "Anti-AFK",
    CurrentValue = false,
    Flag = "AntiAFKToggle",
    Callback = function(state)
        if state then
            Connections.AntiAFK = RunService.Heartbeat:Connect(function()
                task.wait(300)
                pcall(function()
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local hrp = LocalPlayer.Character.HumanoidRootPart
                        hrp.CFrame = hrp.CFrame + Vector3.new(0, 0.1, 0)
                        hrp.CFrame = hrp.CFrame - Vector3.new(0, 0.1, 0)
                    end
                end)
            end)
        else
            KillConnection("AntiAFK")
        end
    end,
})

-- ==========================================
-- 2. FARM
-- ==========================================
FarmTab:CreateSection("Otomatik Toplama")

FarmTab:CreateToggle({
    Name = "Akıllı Noclip + Coin Farm",
    CurrentValue = false,
    Flag = "SmartFarmToggle",
    Callback = function(state)
        _G.SmartFarm = state
        _G.NoclipActive = state
        if state then
            task.spawn(function()
                while _G.SmartFarm do
                    task.wait(0.3)
                    pcall(function()
                        local char = LocalPlayer.Character
                        local hrp = char and char:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            for _, obj in ipairs(Workspace:GetDescendants()) do
                                if not _G.SmartFarm then break end
                                if obj.Name == "CoinContainer" or obj.Name == "Coin_Server" then
                                    local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
                                    if part then
                                        local distance = (hrp.Position - part.Position).Magnitude
                                        if distance > 500 then continue end
                                        
                                        local targetCFrame = part.CFrame + Vector3.new(0, 1.5, 0)
                                        local speed = 22
                                        local timeToTravel = distance / speed
                                        
                                        local tween = TweenService:Create(hrp, TweenInfo.new(timeToTravel, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
                                        tween:Play()
                                        
                                        local elapsed = 0
                                        while elapsed < timeToTravel and _G.SmartFarm and part.Parent do
                                            elapsed = elapsed + task.wait()
                                        end
                                        tween:Cancel()
                                    end
                                end
                            end
                        end
                    end)
                end
            end)
        else
            _G.NoclipActive = false
        end
    end,
})

FarmTab:CreateToggle({
    Name = "Noclip Modu",
    CurrentValue = false,
    Flag = "NoclipToggleMM2",
    Callback = function(state)
        _G.NoclipActive = state
    end,
})

-- ==========================================
-- 3. SAVAŞ / AIM (YENİ GELİŞTİRİLMİŞ)
-- ==========================================
CombatTab:CreateSection("🎯 KATİL HEDEFLİ AIMBOT")

CombatTab:CreateToggle({
    Name = "KATİL AVCI (Aimbot)",
    CurrentValue = false,
    Flag = "AimbotToggle",
    Callback = function(state)
        _G.Aimbot = state
        FovCircle.Visible = state
        
        if state then
            Connections.Aimbot = RunService.RenderStepped:Connect(function()
                if not _G.Aimbot then return end
                FovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                FovCircle.Radius = AimbotSettings.FOV
                
                -- Sadece şerif olduğunda çalış (katil değilken aimbot mantıksız)
                if not IsSheriff() then return end
                
                local murderer = GetMurderer()
                if not murderer or not murderer.Character then return end
                
                local targetChar = murderer.Character
                local targetHrp = targetChar:FindFirstChild("HumanoidRootPart")
                local targetHum = targetChar:FindFirstChild("Humanoid")
                
                if not targetHrp or not targetHum or targetHum.Health <= 0 then return end
                
                -- Innocent protection
                if AimbotSettings.InnocentProtection and IsInnocent(murderer) then return end
                
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetHrp.Position)
                if not onScreen then return end
                
                -- FOV kontrolü (sadece daire içindeki katili hedefle)
                local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                local targetScreen = Vector2.new(screenPos.X, screenPos.Y)
                local distFromCenter = (targetScreen - screenCenter).Magnitude
                
                if distFromCenter > AimbotSettings.FOV then
                    FovCircle.Color = Color3.fromRGB(255, 0, 0) -- Hedef dışında
                    return
                end
                
                FovCircle.Color = Color3.fromRGB(0, 255, 0) -- Hedef içinde (yeşil)
                
                -- Prediction: Katil hareket ediyorsa öne saptır
                local aimPos = targetHrp.Position
                if AimbotSettings.Prediction then
                    local velocity = targetHrp.Velocity
                    local travelTime = (aimPos - Camera.CFrame.Position).Magnitude / 500 -- Mermi hızı ~500
                    aimPos = aimPos + (velocity * travelTime * 0.5)
                end
                
                -- Smooth aim
                local targetCFrame = CFrame.lookAt(Camera.CFrame.Position, aimPos)
                Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, AimbotSettings.Smoothness)
                
                -- Triggerbot
                if AimbotSettings.Triggerbot then
                    local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA("Tool")
                    if tool and tool.Name == "Gun" then
                        local mousePos = UserInputService:GetMouseLocation()
                        local distToCenter = (mousePos - Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)).Magnitude
                        if distToCenter < 30 then
                            tool:Activate()
                        end
                    end
                end
            end)
        else
            KillConnection("Aimbot")
        end
    end,
})

CombatTab:CreateSlider({
    Name = "FOV (Görüş Alanı)",
    Range = {50, 400},
    Increment = 10,
    Suffix = " px",
    CurrentValue = 150,
    Flag = "AimbotFOV",
    Callback = function(val)
        AimbotSettings.FOV = val
        FovCircle.Radius = val
    end,
})

CombatTab:CreateSlider({
    Name = "Aim Smoothness (Yumuşaklık)",
    Range = {5, 50},
    Increment = 1,
    Suffix = " / 100",
    CurrentValue = 15,
    Flag = "AimbotSmoothness",
    Callback = function(val)
        AimbotSettings.Smoothness = val / 100
    end,
})

CombatTab:CreateToggle({
    Name = "Triggerbot (Otomatik Ateş)",
    CurrentValue = false,
    Flag = "TriggerbotToggle",
    Callback = function(state)
        AimbotSettings.Triggerbot = state
    end,
})

CombatTab:CreateToggle({
    Name = "Prediction (Katil Hareketi Tahmini)",
    CurrentValue = true,
    Flag = "PredictionToggle",
    Callback = function(state)
        AimbotSettings.Prediction = state
    end,
})

CombatTab:CreateToggle({
    Name = "Innocent Protection (Masum Koruması)",
    CurrentValue = true,
    Flag = "InnocentProtectionToggle",
    Callback = function(state)
        AimbotSettings.InnocentProtection = state
    end,
})

CombatTab:CreateToggle({
    Name = "Hitbox Büyütücü (Görsel)",
    CurrentValue = false,
    Flag = "HitboxExpandToggle",
    Callback = function(state)
        _G.HitboxExpand = state
        if state then
            Connections.Hitbox = RunService.Heartbeat:Connect(function()
                if not _G.HitboxExpand then return end
                pcall(function()
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                            local hrp = p.Character.HumanoidRootPart
                            hrp.Size = Vector3.new(5, 5, 5)
                            hrp.Transparency = 0.7
                            hrp.CanCollide = false
                        end
                    end
                end)
            end)
        else
            KillConnection("Hitbox")
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = p.Character.HumanoidRootPart
                    hrp.Size = Vector3.new(2, 2, 1)
                    hrp.Transparency = 1
                end
            end
        end
    end,
})

-- ==========================================
-- 4. GÖRSEL / ESP
-- ==========================================
VisualsTab:CreateSection("ESP & Aydınlatma")

VisualsTab:CreateToggle({
    Name = "Gelişmiş ESP (Rol + Mesafe + Tracer + HP)",
    CurrentValue = false,
    Flag = "RoleESPToggle",
    Callback = function(state)
        _G.RoleESP = state
        if state then
            Connections.RoleESP = RunService.RenderStepped:Connect(function()
                if not _G.RoleESP then return end
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character then
                        local char = p.Character
                        local hrp = char:FindFirstChild("HumanoidRootPart")
                        local humanoid = char:FindFirstChild("Humanoid")
                        
                        if not hrp or not humanoid then continue end
                        
                        -- Highlight
                        local hl = char:FindFirstChild("MM2ESP")
                        if not hl then
                            hl = Instance.new("Highlight")
                            hl.Name = "MM2ESP"
                            hl.Parent = char
                        end
                        
                        -- Text Label
                        local label = char:FindFirstChild("MM2Label")
                        if not label then
                            label = Instance.new("BillboardGui")
                            label.Name = "MM2Label"
                            label.Size = UDim2.new(0, 200, 0, 50)
                            label.StudsOffset = Vector3.new(0, 3, 0)
                            label.AlwaysOnTop = true
                            local text = Instance.new("TextLabel", label)
                            text.Name = "RoleText"
                            text.Size = UDim2.new(1, 0, 1, 0)
                            text.BackgroundTransparency = 1
                            text.TextStrokeTransparency = 0
                            text.TextScaled = true
                            text.Font = Enum.Font.GothamBold
                            label.Parent = char
                        end
                        
                        -- Health Bar
                        local hpBar = char:FindFirstChild("MM2HPBar")
                        if not hpBar then
                            hpBar = Instance.new("BillboardGui")
                            hpBar.Name = "MM2HPBar"
                            hpBar.Size = UDim2.new(0, 100, 0, 8)
                            hpBar.StudsOffset = Vector3.new(0, 4.5, 0)
                            hpBar.AlwaysOnTop = true
                            local bg = Instance.new("Frame", hpBar)
                            bg.Name = "BG"
                            bg.Size = UDim2.new(1, 0, 1, 0)
                            bg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                            bg.BorderSizePixel = 0
                            local fill = Instance.new("Frame", bg)
                            fill.Name = "Fill"
                            fill.Size = UDim2.new(1, 0, 1, 0)
                            fill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                            fill.BorderSizePixel = 0
                            hpBar.Parent = char
                        end
                        
                        -- Tracer
                        local tracer = Camera:FindFirstChild("MM2Tracer_" .. p.Name)
                        if not tracer then
                            tracer = Drawing.new("Line")
                            tracer.Thickness = 1.5
                            tracer.Name = "MM2Tracer_" .. p.Name
                        end
                        
                        local textObj = label:FindFirstChild("RoleText")
                        local fillObj = hpBar:FindFirstChild("BG") and hpBar.BG:FindFirstChild("Fill")
                        if not textObj or not fillObj then continue end
                        
                        -- HP güncelle
                        local hpPercent = humanoid.Health / humanoid.MaxHealth
                        fillObj.Size = UDim2.new(hpPercent, 0, 1, 0)
                        
                        -- Rol tespiti
                        local isM = char:FindFirstChild("Knife") or (p:FindFirstChild("Backpack") and p.Backpack:FindFirstChild("Knife"))
                        local isS = char:FindFirstChild("Gun") or (p:FindFirstChild("Backpack") and p.Backpack:FindFirstChild("Gun"))
                        local isDead = humanoid.Health <= 0
                        
                        -- Tracer pozisyonu
                        local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                        if onScreen then
                            tracer.Visible = true
                            tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                            tracer.To = Vector2.new(screenPos.X, screenPos.Y)
                        else
                            tracer.Visible = false
                        end
                        
                        -- Distance
                        local distance = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") 
                            and math.floor((LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude) or 0
                        
                        if isDead then
                            hl.FillColor = Color3.fromRGB(100, 100, 100)
                            tracer.Color = Color3.fromRGB(100, 100, 100)
                            textObj.Text = p.Name .. " [ÖLÜ] " .. distance .. "m"
                            textObj.TextColor3 = Color3.fromRGB(100, 100, 100)
                        elseif isM then
                            hl.FillColor = Color3.fromRGB(255, 40, 40)
                            tracer.Color = Color3.fromRGB(255, 40, 40)
                            textObj.Text = "🔪 KATİL " .. distance .. "m"
                            textObj.TextColor3 = Color3.fromRGB(255, 80, 80)
                        elseif isS then
                            hl.FillColor = Color3.fromRGB(40, 100, 255)
                            tracer.Color = Color3.fromRGB(40, 100, 255)
                            textObj.Text = "🔫 ŞERİF " .. distance .. "m"
                            textObj.TextColor3 = Color3.fromRGB(80, 150, 255)
                        else
                            hl.FillColor = Color3.fromRGB(40, 220, 90)
                            tracer.Color = Color3.fromRGB(40, 220, 90)
                            textObj.Text = p.Name .. " [MASUM] " .. distance .. "m"
                            textObj.TextColor3 = Color3.fromRGB(80, 220, 130)
                        end
                    end
                end
            end)
        else
            KillConnection("RoleESP")
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Character then
                    for _, esp in ipairs(p.Character:GetChildren()) do
                        if esp.Name:find("MM2") then esp:Destroy() end
                    end
                end
                local tracer = Camera:FindFirstChild("MM2Tracer_" .. p.Name)
                if tracer then tracer:Destroy() end
            end
        end
    end,
})

VisualsTab:CreateToggle({
    Name = "FullBright",
    CurrentValue = false,
    Flag = "FullBrightToggle",
    Callback = function(state)
        _G.FullBright = state
        if state then
            Connections.FullBright = RunService.RenderStepped:Connect(function()
                if _G.FullBright then
                    Lighting.Brightness = 2
                    Lighting.ClockTime = 14
                    Lighting.GlobalShadows = false
                    Lighting.FogEnd = 100000
                end
            end)
        else
            KillConnection("FullBright")
            Lighting.GlobalShadows = true
        end
    end,
})

VisualsTab:CreateToggle({
    Name = "X-Ray Duvarlar",
    CurrentValue = false,
    Flag = "XRayToggle",
    Callback = function(state)
        _G.XRayActive = state
        if state then
            pcall(function()
                table.clear(XRayParts)
                for _, part in ipairs(Workspace:GetDescendants()) do
                    if part:IsA("BasePart") 
                       and not part:IsDescendantOf(LocalPlayer.Character) 
                       and part.Transparency < 0.5 
                       and part.Name ~= "HumanoidRootPart" then
                        part.LocalTransparencyModifier = 0.5
                        table.insert(XRayParts, part)
                    end
                end
            end)
        else
            for _, part in ipairs(XRayParts) do
                if part and part.Parent then
                    part.LocalTransparencyModifier = 0
                end
            end
            table.clear(XRayParts)
        end
    end,
})

-- ==========================================
-- 5. KARAKTER
-- ==========================================
PlayerTab:CreateSection("Hareket")

PlayerTab:CreateSlider({
    Name = "Yürüme Hızı",
    Range = {16, 150},
    Increment = 1,
    Suffix = " Speed",
    CurrentValue = 16,
    Flag = "WalkSpeedSliderMM2",
    Callback = function(val)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = val
        end
    end,
})

PlayerTab:CreateSlider({
    Name = "Zıplama Gücü",
    Range = {50, 200},
    Increment = 1,
    Suffix = " Power",
    CurrentValue = 50,
    Flag = "JumpPowerSliderMM2",
    Callback = function(val)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = val
            LocalPlayer.Character.Humanoid.UseJumpPower = true
        end
    end,
})

PlayerTab:CreateToggle({
    Name = "Sonsuz Zıplama",
    CurrentValue = false,
    Flag = "InfJumpMM2Toggle",
    Callback = function(state)
        _G.InfJump = state
        if state then
            Connections.InfJump = UserInputService.JumpRequest:Connect(function()
                if _G.InfJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        else
            KillConnection("InfJump")
        end
    end,
})

PlayerTab:CreateToggle({
    Name = "Düşük Yerçekimi",
    CurrentValue = false,
    Flag = "MoonGravityToggle",
    Callback = function(state)
        Workspace.Gravity = state and 30 or 196.2
    end,
})

PlayerTab:CreateToggle({
    Name = "Spinbot",
    CurrentValue = false,
    Flag = "SpinbotToggle",
    Callback = function(state)
        _G.Spinbot = state
        if state then
            Connections.Spinbot = RunService.RenderStepped:Connect(function()
                if _G.Spinbot and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(30), 0)
                end
            end)
        else
            KillConnection("Spinbot")
        end
    end,
})

PlayerTab:CreateToggle({
    Name = "BunnyHop",
    CurrentValue = false,
    Flag = "BhopToggle",
    Callback = function(state)
        _G.Bhop = state
        if state then
            Connections.Bhop = RunService.RenderStepped:Connect(function()
                if _G.Bhop and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    if LocalPlayer.Character.Humanoid.FloorMaterial ~= Enum.Material.Air then
                        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end
            end)
        else
            KillConnection("Bhop")
        end
    end,
})

PlayerTab:CreateKeybind({
    Name = "Arayüz Toggle (Right Ctrl)",
    CurrentKeybind = "RightControl",
    HoldToInteract = false,
    Flag = "ToggleKeybindMM2",
    Callback = function()
        if Rayfield then Rayfield:Toggle() end
    end,
})

-- ==========================================
-- 6. IŞINLANMA
-- ==========================================
TeleportTab:CreateSection("Harita & Oyuncu")

TeleportTab:CreateButton({
    Name = "Yere Düşen Silaha Işınlan",
    Callback = function()
        for _, obj in ipairs(Workspace:GetChildren()) do
            if (obj.Name == "GunDrop" or obj.Name == "DroppedGun") and obj:FindFirstChild("Handle") 
               and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = obj.Handle.CFrame + Vector3.new(0, 3, 0)
                break
            end
        end
    end,
})

TeleportTab:CreateButton({
    Name = "Katilin Yanına Işınlan",
    Callback = function()
        pcall(function()
            local murderer = GetMurderer()
            if murderer and murderer.Character and murderer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = murderer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5)
            end
        end)
    end,
})

TeleportTab:CreateButton({
    Name = "Şerifin Yanına Işınlan",
    Callback = function()
        pcall(function()
            local sheriff = GetSheriff()
            if sheriff and sheriff.Character and sheriff.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = sheriff.Character.HumanoidRootPart.CFrame * CFrame.new(3, 0, 0)
            end
        end)
    end,
})

TeleportTab:CreateButton({
    Name = "Harita Merkezine",
    Callback = function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, 50, 0)
        end
    end,
})

TeleportTab:CreateButton({
    Name = "Rastgele Oyuncuya",
    Callback = function()
        pcall(function()
            local players = Players:GetPlayers()
            local target = players[math.random(1, #players)]
            if target ~= LocalPlayer and target.Character and LocalPlayer.Character then
                local tHrp = target.Character:FindFirstChild("HumanoidRootPart")
                if tHrp then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = tHrp.CFrame * CFrame.new(5, 0, 0)
                end
            end
        end)
    end,
})

-- ==========================================
-- 7. EKSTRALAR
-- ==========================================
MiscTab:CreateSection("Yardımcı Araçlar")

MiscTab:CreateToggle({
    Name = "Düşen Silahı Toplayıcı",
    CurrentValue = false,
    Flag = "AutoGunToggle",
    Callback = function(state)
        _G.AutoGun = state
        if state then
            Connections.AutoGun = RunService.Heartbeat:Connect(function()
                if not _G.AutoGun then return end
                pcall(function()
                    for _, obj in ipairs(Workspace:GetChildren()) do
                        if (obj.Name == "GunDrop" or obj.Name == "DroppedGun") 
                           and obj:FindFirstChild("Handle") 
                           and LocalPlayer.Character 
                           and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            local dist = (LocalPlayer.Character.HumanoidRootPart.Position - obj.Handle.Position).Magnitude
                            if dist > 5 then
                                LocalPlayer.Character.HumanoidRootPart.CFrame = obj.Handle.CFrame
                            end
                        end
                    end
                end)
            end)
        else
            KillConnection("AutoGun")
        end
    end,
})

MiscTab:CreateButton({
    Name = "Katili İzle (Kamera Kilidi)",
    Callback = function()
        pcall(function()
            local murderer = GetMurderer()
            if murderer and murderer.Character then
                local hum = murderer.Character:FindFirstChild("Humanoid")
                if hum then Camera.CameraSubject = hum end
            end
        end)
    end,
})

MiscTab:CreateButton({
    Name = "Kamerayı Kendine Getir",
    Callback = function()
        pcall(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                Camera.CameraSubject = LocalPlayer.Character.Humanoid
            end
        end)
    end,
})

MiscTab:CreateButton({
    Name = "FPS / Lag Temizleyici",
    Callback = function()
        pcall(function()
            for _, v in ipairs(Lighting:GetChildren()) do
                if v:IsA("PostEffect") then v.Enabled = false end
            end
            if Workspace.Terrain then
                Workspace.Terrain.WaterWaveSize = 0
                Workspace.Terrain.WaterWaveTransparency = 1
                Workspace.Terrain.WaterReflectance = 0
            end
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 100000
        end)
    end,
})

MiscTab:CreateButton({
    Name = "Sunucuyu Yenile (Rejoin)",
    Callback = function()
        pcall(function()
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end)
    end,
})

MiscTab:CreateButton({
    Name = "Özel Nişangah Ekle",
    Callback = function()
        pcall(function()
            local CoreGui = game:GetService("CoreGui")
            if CoreGui:FindFirstChild("CustomCrosshair") then
                CoreGui.CustomCrosshair:Destroy()
                return
            end
            local chGui = Instance.new("ScreenGui", CoreGui)
            chGui.Name = "CustomCrosshair"
            local dot = Instance.new("Frame", chGui)
            dot.Size = UDim2.new(0, 6, 0, 6)
            dot.Position = UDim2.new(0.5, -3, 0.5, -3)
            dot.BackgroundColor3 = Color3.fromRGB(0, 255, 120)
            dot.BorderSizePixel = 0
            Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
        end)
    end,
})

MiscTab:CreateButton({
    Name = "⚠️ TÜM HİLELERİ KAPAT",
    Callback = function()
        FullCleanup()
        Rayfield:Notify({
            Title = "Temizlik Tamam",
            Content = "Tüm hileler ve bağlantılar kapatıldı.",
            Duration = 3
        })
    end,
})

-- ==========================================
-- BAŞLANGIÇ BİLDİRİMİ
-- ==========================================
Rayfield:Notify({
    Title = "MM2 Masterpiece Hub v16.0",
    Content = "🎯 Aimbot artık SADECE KATİLİ hedefliyor!\n📍 Prediction + FOV + Triggerbot aktif",
    Duration = 6
})
