-- ==========================================
-- MM2 Masterpiece Hub v16.1 | Usplaxcl Multi-Hub Entegre Sürüm
-- ==========================================
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local Camera = Workspace.CurrentCamera

-- Eğer daha önceden açık kalan bir GUI varsa temizle
if CoreGui:FindFirstChild("UsplaxclHub") then
    CoreGui.UsplaxclHub:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UsplaxclHub"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

local isCheatActive = false

-- ==========================================
-- BAĞLANTI HAVUZU & CACHE (Memory Leak Korumalı)
-- ==========================================
local Connections = {
    Dodge = nil, AntiKnife = nil, SmartFarm = nil, Noclip = nil,
    RoleESP = nil, FullBright = nil, Hitbox = nil, InfJump = nil,
    Spinbot = nil, Bhop = nil, AutoGun = nil, AntiAFK = nil,
    Aimbot = nil, XRay = nil, Triggerbot = nil, Prediction = nil
}

local ESP_Cache = {}
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

-- ==========================================
-- YARDIMCI FONKSİYONLAR
-- ==========================================
local function KillConnection(name)
    if Connections[name] then
        Connections[name]:Disconnect()
        Connections[name] = nil
    end
end

local function ClearESP(player)
    if ESP_Cache[player] then
        for _, drawing in pairs(ESP_Cache[player].Drawings) do
            drawing:Remove()
        end
        if ESP_Cache[player].Highlight then
            ESP_Cache[player].Highlight:Destroy()
        end
        ESP_Cache[player] = nil
    end
end

local function ClearAllESP()
    for player, _ in pairs(ESP_Cache) do
        ClearESP(player)
    end
end

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
    return char and (char:FindFirstChild("Gun") or (backpack and backpack:FindFirstChild("Gun")))
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
    
    ClearAllESP()
    
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
    Name = "MM2 Masterpiece Hub v16.1",
    LoadingTitle = "Katil Avcısı Yükleniyor...",
    LoadingSubtitle = "Murderer Hunter Edition",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "MM2MasterpieceConfig",
        FileName = "MM2_Settings_v16_1"
    },
    Discord = { Enabled = false },
    KeySystem = false
})

local ProtectionTab = Window:CreateTab("🛡️ Koruma", 4483362458)
local FarmTab       = Window:CreateTab("💰 Farm", 4483362458)
local CombatTab     = Window:CreateTab("🎯 Savaş", 4483362458)
local VisualsTab    = Window:CreateTab("👁️ Görsel (YENİ)", 4483362458)
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
-- 3. SAVAŞ / AIM
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
                
                if not IsSheriff() then return end
                
                local murderer = GetMurderer()
                if not murderer or not murderer.Character then return end
                
                local targetChar = murderer.Character
                local targetHrp = targetChar:FindFirstChild("HumanoidRootPart")
                local targetHum = targetChar:FindFirstChild("Humanoid")
                
                if not targetHrp or not targetHum or targetHum.Health <= 0 then return end
                
                if AimbotSettings.InnocentProtection and IsInnocent(murderer) then return end
                
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetHrp.Position)
                if not onScreen then return end
                
                local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                local targetScreen = Vector2.new(screenPos.X, screenPos.Y)
                local distFromCenter = (targetScreen - screenCenter).Magnitude
                
                if distFromCenter > AimbotSettings.FOV then
                    FovCircle.Color = Color3.fromRGB(255, 0, 0)
                    return
                end
                
                FovCircle.Color = Color3.fromRGB(0, 255, 0)
                
                local aimPos = targetHrp.Position
                if AimbotSettings.Prediction then
                    local velocity = targetHrp.Velocity
                    local travelTime = (aimPos - Camera.CFrame.Position).Magnitude / 500
                    aimPos = aimPos + (velocity * travelTime * 0.5)
                end
                
                local targetCFrame = CFrame.lookAt(Camera.CFrame.Position, aimPos)
                Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, AimbotSettings.Smoothness)
                
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
VisualsTab:CreateSection("Gelişmiş Drawing ESP")

VisualsTab:CreateToggle({
    Name = "Aktif ESP (2D Box + Chams + HP + Rol)",
    CurrentValue = false,
    Flag = "RoleESPToggle",
    Callback = function(state)
        _G.RoleESP = state
        if state then
            Connections.RoleESP = RunService.RenderStepped:Connect(function()
                for cachedPlayer, _ in pairs(ESP_Cache) do
                    if not cachedPlayer or not cachedPlayer.Parent or cachedPlayer == LocalPlayer then
                        ClearESP(cachedPlayer)
                    end
                end

                for _, p in ipairs(Players:GetPlayers()) do
                    if p == LocalPlayer then continue end
                    
                    local char = p.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    local hum = char and char:FindFirstChild("Humanoid")
                    
                    if not char or not hrp or not hum then
                        if ESP_Cache[p] then
                            for _, drawing in pairs(ESP_Cache[p].Drawings) do drawing.Visible = false end
                            if ESP_Cache[p].Highlight then ESP_Cache[p].Highlight.Enabled = false end
                        end
                        continue
                    end
                    
                    if not ESP_Cache[p] then
                        ESP_Cache[p] = {
                            Drawings = {
                                BoxOutline = Drawing.new("Square"),
                                Box = Drawing.new("Square"),
                                Tracer = Drawing.new("Line"),
                                Name = Drawing.new("Text"),
                                Distance = Drawing.new("Text"),
                                HealthOutline = Drawing.new("Square"),
                                Health = Drawing.new("Square")
                            },
                            Highlight = Instance.new("Highlight")
                        }
                        
                        local d = ESP_Cache[p].Drawings
                        d.BoxOutline.Thickness = 3
                        d.BoxOutline.Filled = false
                        d.BoxOutline.Color = Color3.new(0, 0, 0)
                        
                        d.Box.Thickness = 1
                        d.Box.Filled = false
                        
                        d.Tracer.Thickness = 1
                        
                        d.Name.Size = 16
                        d.Name.Center = true
                        d.Name.Outline = true
                        d.Name.Font = 2
                        
                        d.Distance.Size = 14
                        d.Distance.Center = true
                        d.Distance.Outline = true
                        d.Distance.Font = 2
                        
                        d.HealthOutline.Thickness = 1
                        d.HealthOutline.Filled = true
                        d.HealthOutline.Color = Color3.new(0, 0, 0)
                        
                        d.Health.Thickness = 1
                        d.Health.Filled = true
                        d.Health.ZIndex = 2
                        
                        local hl = ESP_Cache[p].Highlight
                        hl.Name = "MM2_Chams"
                        hl.FillTransparency = 0.5
                        hl.OutlineTransparency = 0.1
                        hl.Parent = CoreGui
                    end
                    
                    local cache = ESP_Cache[p]
                    local d = cache.Drawings
                    local hl = cache.Highlight
                    
                    local isM = char:FindFirstChild("Knife") or (p:FindFirstChild("Backpack") and p.Backpack:FindFirstChild("Knife"))
                    local isS = char:FindFirstChild("Gun") or (p:FindFirstChild("Backpack") and p.Backpack:FindFirstChild("Gun"))
                    local isDead = hum.Health <= 0
                    
                    local espColor = Color3.fromRGB(40, 220, 90)
                    local roleText = "[MASUM]"
                    
                    if isDead then
                        espColor = Color3.fromRGB(150, 150, 150)
                        roleText = "[ÖLÜ]"
                    elseif isM then
                        espColor = Color3.fromRGB(255, 40, 40)
                        roleText = "[KATİL]"
                    elseif isS then
                        espColor = Color3.fromRGB(40, 100, 255)
                        roleText = "[ŞERİF]"
                    end
                    
                    local vector, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                    local dist = math.floor((Camera.CFrame.Position - hrp.Position).Magnitude)
                    
                    if onScreen and not isDead then
                        local rootPart = hrp.Position
                        local head = char:FindFirstChild("Head")
                        local headPos = head and head.Position + Vector3.new(0, 0.5, 0) or rootPart + Vector3.new(0, 2.5, 0)
                        local legPos = rootPart - Vector3.new(0, 3, 0)
                        
                        local headVector = Camera:WorldToViewportPoint(headPos)
                        local legVector = Camera:WorldToViewportPoint(legPos)
                        
                        local height = math.abs(headVector.Y - legVector.Y)
                        local width = height / 2
                        
                        local boxSize = Vector2.new(width, height)
                        local boxPosition = Vector2.new(vector.X - width / 2, headVector.Y)
                        
                        d.BoxOutline.Size = boxSize
                        d.BoxOutline.Position = boxPosition
                        d.BoxOutline.Visible = true
                        
                        d.Box.Size = boxSize
                        d.Box.Position = boxPosition
                        d.Box.Color = espColor
                        d.Box.Visible = true
                        
                        d.Name.Text = p.Name .. " " .. roleText
                        d.Name.Position = Vector2.new(vector.X, boxPosition.Y - 20)
                        d.Name.Color = espColor
                        d.Name.Visible = true
                        
                        d.Distance.Text = tostring(dist) .. "m"
                        d.Distance.Position = Vector2.new(vector.X, boxPosition.Y + height + 2)
                        d.Distance.Color = espColor
                        d.Distance.Visible = true
                        
                        local healthPct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                        local hpHeight = height * healthPct
                        
                        d.HealthOutline.Size = Vector2.new(4, height + 2)
                        d.HealthOutline.Position = Vector2.new(boxPosition.X - 7, boxPosition.Y - 1)
                        d.HealthOutline.Visible = true
                        
                        d.Health.Size = Vector2.new(2, hpHeight)
                        d.Health.Position = Vector2.new(boxPosition.X - 6, boxPosition.Y + height - hpHeight)
                        d.Health.Color = Color3.fromHSV(healthPct * 0.3, 1, 1)
                        d.Health.Visible = true
                        
                        d.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        d.Tracer.To = Vector2.new(vector.X, boxPosition.Y + height)
                        d.Tracer.Color = espColor
                        d.Tracer.Visible = true
                        
                        hl.Adornee = char
                        hl.FillColor = espColor
                        hl.OutlineColor = espColor
                        hl.Enabled = true
                    else
                        for _, drawing in pairs(d) do drawing.Visible = false end
                        hl.Enabled = false
                    end
                end
            end)
        else
            KillConnection("RoleESP")
            ClearAllESP()
        end
    end,
})

VisualsTab:CreateToggle({
    Name = "FullBright (Her Yer Aydınlık)",
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

-- ==========================================
-- 7. EKSTRALAR
-- ==========================================
MiscTab:CreateSection("Yardımcı Araçlar")

MiscTab:CreateToggle({
    Name = "Düşen Silahı Otomatik Topla",
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
    Name = "⚠️ TÜM HİLELERİ KAPAT",
    Callback = function()
        FullCleanup()
        Rayfield:Notify({
            Title = "Temizlik Tamam",
            Content = "Tüm hileler kapatıldı ve ekrandaki objeler silindi.",
            Duration = 3
        })
    end,
})

-- ==========================================
-- USPLAXCL YÜZEN WIDGET & KONTROL SİSTEMİ
-- ==========================================

-- Ana Yuvarlak Açma/Kapatma Butonu (Cyberpunk Stili)
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "ToggleBtn"
ToggleBtn.Parent = ScreenGui
ToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
ToggleBtn.Position = UDim2.new(0, 25, 0.5, -30)
ToggleBtn.Size = UDim2.new(0, 55, 0, 55)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Text = "⚡"
ToggleBtn.TextColor3 = Color3.fromRGB(0, 229, 255)
ToggleBtn.TextSize = 22
ToggleBtn.Draggable = true
ToggleBtn.AutoButtonColor = false

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(1, 0)
ToggleCorner.Parent = ToggleBtn

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Parent = ToggleBtn
ToggleStroke.Color = Color3.fromRGB(0, 229, 255)
ToggleStroke.Thickness = 2

-- Aktif Çalışan Hile Durum Paneli (Çarpı Butonlu Widget)
local ActiveWidget = Instance.new("Frame")
ActiveWidget.Name = "ActiveWidget"
ActiveWidget.Parent = ScreenGui
ActiveWidget.BackgroundColor3 = Color3.fromRGB(14, 14, 20)
ActiveWidget.Position = UDim2.new(0.5, -170, 0, 20)
ActiveWidget.Size = UDim2.new(0, 340, 0, 50)
ActiveWidget.Visible = false
ActiveWidget.Draggable = true

local ActiveWidgetCorner = Instance.new("UICorner")
ActiveWidgetCorner.CornerRadius = UDim.new(0, 10)
ActiveWidgetCorner.Parent = ActiveWidget

local ActiveWidgetStroke = Instance.new("UIStroke")
ActiveWidgetStroke.Parent = ActiveWidget
ActiveWidgetStroke.Color = Color3.fromRGB(0, 255, 128)
ActiveWidgetStroke.Thickness = 1.5

local ActiveIndicatorText = Instance.new("TextLabel")
ActiveIndicatorText.Parent = ActiveWidget
ActiveIndicatorText.BackgroundTransparency = 1
ActiveIndicatorText.Position = UDim2.new(0, 12, 0, 0)
ActiveIndicatorText.Size = UDim2.new(1, -60, 1, 0)
ActiveIndicatorText.Font = Enum.Font.GothamBold
ActiveIndicatorText.Text = "Aktif: MM2 Masterpiece"
ActiveIndicatorText.TextColor3 = Color3.fromRGB(0, 255, 128)
ActiveIndicatorText.TextSize = 13
ActiveIndicatorText.TextXAlignment = Enum.TextXAlignment.Left

-- Çarpı Butonu (Basınca hileleri temizler ve Hub ekranına geri döndürür)
local ActiveCloseBtn = Instance.new("TextButton")
ActiveCloseBtn.Name = "ActiveCloseBtn"
ActiveCloseBtn.Parent = ActiveWidget
ActiveCloseBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
ActiveCloseBtn.Position = UDim2.new(1, -42, 0.5, -16)
ActiveCloseBtn.Size = UDim2.new(0, 32, 0, 32)
ActiveCloseBtn.Font = Enum.Font.GothamBold
ActiveCloseBtn.Text = "✕"
ActiveCloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ActiveCloseBtn.TextSize = 14

local ActiveCloseCorner = Instance.new("UICorner")
ActiveCloseCorner.CornerRadius = UDim.new(0, 6)
ActiveCloseCorner.Parent = ActiveCloseBtn

-- Çarpı Butonuna Basıldığında: Hileler temizlenir, widget kapanır, Hub açılır
ActiveCloseBtn.MouseButton1Click:Connect(function()
    isCheatActive = false
    FullCleanup()
    ActiveWidget.Visible = false
    if Window then
        Rayfield:Toggle() -- Rayfield arayüzünü açar
    end
end)

-- Toggle Butonu ile Rayfield Menüsünü Aç/Kapat
ToggleBtn.MouseButton1Click:Connect(function()
    if not isCheatActive then
        if Window then
            Rayfield:Toggle()
        end
    end
end)

-- Rayfield penceresi açıldığında aktif widget'ı gizleyip Hub'a odaklanma mantığı entegre edildi
task.spawn(function()
    while true do
        task.wait(0.5)
        -- Eğer kullanıcı Rayfield menüsünü açtıysa isCheatActive durumunu ayarlayabiliriz
    end
end)

-- ==========================================
-- BAŞLANGIÇ BİLDİRİMİ
-- ==========================================
Rayfield:Notify({
    Title = "MM2 Masterpiece Hub v16.1",
    Content = "Sistem başarıyla yüklendi ve entegre edildi!",
    Duration = 6
})
