-- ==========================================
-- MM2 Masterpiece Hub v14.1 | ULTRA V5 APEX Edition
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

-- Global Bağlantı Havuzu ve Temizlik
local ActiveConnections = {}
local function Track(conn)
    table.insert(ActiveConnections, conn)
    return conn
end

local function FullCleanup()
    _G.EmergencyDodge = false
    _G.AntiKnife = false
    _G.SmartFarm = false
    _G.NoclipActive = false
    _G.RoleESP = false
    _G.FullBright = false
    _G.SpeedEnabled = false
    _G.InfJump = false
    _G.Spinbot = false
    _G.HitboxExpand = false
    _G.XRayActive = false
    _G.AutoGun = false
    _G.Bhop = false

    for _, conn in ipairs(ActiveConnections) do
        if conn and typeof(conn) == "RBXScriptConnection" then
            conn:Disconnect()
        end
    end
    table.clear(ActiveConnections)

    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = 16
        LocalPlayer.Character.Humanoid.JumpPower = 50
    end
    Lighting.GlobalShadows = true
    Workspace.Gravity = 196.2
end

-- ==========================================
-- ULTRA V5 ARAYÜZ KÜTÜPHANESİNİ YÜKLE
-- ==========================================
local UltraV5 = loadstring(game:HttpGet("https://raw.githubusercontent.com/khlakgwwluwyohllhahalahlylgakh-byte/MM2-HUB/main/ULTRA%20V5%20-%20APEX%20EDITION"))()

local Window = UltraV5:CreateWindow({
    Name = "MM2 Masterpiece Hub v14.1",
    ToggleKey = Enum.KeyCode.RightControl,
    ConfigFileName = "MM2_Masterpiece_Config.json"
})

-- Sekmeler
local ProtectionTab = Window:CreateTab("Güvenli Koruma", "🛡️")
local FarmTab       = Window:CreateTab("Akıllı Farm & Noclip", "🌾")
local VisualsTab    = Window:CreateTab("Görsel / ESP", "👁️")
local PlayerTab     = Window:CreateTab("Karakter & Hareket", "⚡")
local TeleportTab   = Window:CreateTab("Işınlanma", "📍")
local MiscTab       = Window:CreateTab("Ekstralar", "⚙️")

-- ==========================================
-- GLOBAL NOCLIP MOTORU
-- ==========================================
Track(RunService.Stepped:Connect(function()
    if _G.NoclipActive then
        pcall(function()
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end
end))

-- ==========================================
-- 1. GÜVENLİ KORUMA
-- ==========================================
ProtectionTab:CreateToggle("Acil Kaçış Kalkanı (Katil Yaklaşınca)", false, function(state)
    _G.EmergencyDodge = state
    Track(RunService.Heartbeat:Connect(function()
        if not _G.EmergencyDodge then return end
        pcall(function()
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local pChar = p.Character
                    local pHrp = pChar:FindFirstChild("HumanoidRootPart")
                    local backpack = p:FindFirstChild("Backpack")
                    local isMurderer = pChar:FindFirstChild("Knife") or (backpack and backpack:FindFirstChild("Knife"))
                    
                    if isMurderer and pHrp then
                        local dist = (hrp.Position - pHrp.Position).Magnitude
                        if dist < 14 then
                            local escapeDir = (hrp.Position - pHrp.Position)
                            escapeDir = Vector3.new(escapeDir.X, 0, escapeDir.Z).Unit
                            
                            local targetPos = hrp.Position + (escapeDir * 32) + Vector3.new(0, 15, 0)
                            
                            local raycastParams = RaycastParams.new()
                            raycastParams.FilterType = Enum.RaycastFilterType.Exclude
                            raycastParams.IgnoreWater = true
                            raycastParams.FilterDescendantsInstances = {char, pChar}
                            
                            local rayResult = Workspace:Raycast(targetPos, Vector3.new(0, -60, 0), raycastParams)
                            if rayResult and rayResult.Instance and rayResult.Instance.CanCollide then
                                hrp.CFrame = CFrame.new(rayResult.Position + Vector3.new(0, 3, 0))
                            else
                                hrp.CFrame = CFrame.new(0, 20, 0)
                            end
                        end
                    end
                end
            end
        end)
    end))
end)

ProtectionTab:CreateToggle("Gelişmiş Bıçak Yok Edici (Anti-Throw)", false, function(state)
    _G.AntiKnife = state
    Track(Workspace.ChildAdded:Connect(function(child)
        if _G.AntiKnife then
            local name = child.Name:lower()
            if name:find("knife") or name:find("thrown") or name:find("dagger") then
                task.spawn(function()
                    pcall(function()
                        child:Destroy()
                    end)
                end)
            end
        end
    end))
end)

ProtectionTab:CreateToggle("Görünmezlik Modu (Client Stealth)", false, function(state)
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
end)

-- ==========================================
-- 2. AKILLI FARM & NOCLIP
-- ==========================================
FarmTab:CreateToggle("Akıllı Noclip + Coin Farm", false, function(state)
    _G.SmartFarm = state
    _G.NoclipActive = state
    task.spawn(function()
        while _G.SmartFarm do
            task.wait(0.2)
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    for _, obj in ipairs(Workspace:GetDescendants()) do
                        if not _G.SmartFarm then break end
                        if obj.Name == "CoinContainer" or obj.Name == "Coin_Server" then
                            local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
                            if part then
                                local targetCFrame = part.CFrame + Vector3.new(0, 1.5, 0)
                                local distance = (hrp.Position - targetCFrame.Position).Magnitude
                                local speed = 22
                                local timeToTravel = distance / speed
                                
                                local tween = TweenService:Create(hrp, TweenInfo.new(timeToTravel, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
                                tween:Play()
                                
                                local elapsed = 0
                                while elapsed < timeToTravel and _G.SmartFarm and part.Parent do
                                    elapsed = elapsed + task.wait()
                                end
                            end
                        end
                    end
                end
            end)
        end
        if not _G.SmartFarm then
            _G.NoclipActive = false
        end
    end)
end)

FarmTab:CreateToggle("Noclip Modu (Duvarlardan Geçiş)", false, function(state)
    _G.NoclipActive = state
end)

-- ==========================================
-- 3. GÖRSEL / ESP
-- ==========================================
VisualsTab:CreateToggle("Rol ESP (Katil/Şerif)", false, function(state)
    _G.RoleESP = state
    Track(RunService.RenderStepped:Connect(function()
        if not _G.RoleESP then return end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local char = p.Character
                local hl = char:FindFirstChild("MM2ESP")
                if not hl then
                    hl = Instance.new("Highlight")
                    hl.Name = "MM2ESP"
                    hl.Parent = char
                end
                local isM = char:FindFirstChild("Knife") or (p:FindFirstChild("Backpack") and p.Backpack:FindFirstChild("Knife"))
                local isS = char:FindFirstChild("Gun") or (p:FindFirstChild("Backpack") and p.Backpack:FindFirstChild("Gun"))
                if isM then
                    hl.FillColor = Color3.fromRGB(255, 40, 40)
                elseif isS then
                    hl.FillColor = Color3.fromRGB(40, 100, 255)
                else
                    hl.FillColor = Color3.fromRGB(40, 220, 90)
                end
            end
        end
    end))
end)

VisualsTab:CreateToggle("FullBright (Aydınlatma)", false, function(state)
    _G.FullBright = state
    Track(RunService.RenderStepped:Connect(function()
        if _G.FullBright then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.GlobalShadows = false
        else
            Lighting.GlobalShadows = true
        end
    end))
end)

VisualsTab:CreateToggle("X-Ray Duvarlar", false, function(state)
    _G.XRayActive = state
    pcall(function()
        for _, part in ipairs(Workspace:GetDescendants()) do
            if part:IsA("BasePart") and not part:IsDescendantOf(Players.LocalPlayer.Character) then
                if state and part.Transparency < 0.5 and part.Name ~= "HumanoidRootPart" then
                    part.LocalTransparencyModifier = 0.5
                else
                    part.LocalTransparencyModifier = 0
                end
            end
        end
    end)
end)

VisualsTab:CreateToggle("Hitbox Büyütücü", false, function(state)
    _G.HitboxExpand = state
    Track(RunService.Heartbeat:Connect(function()
        if not _G.HitboxExpand then return end
        pcall(function()
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = p.Character.HumanoidRootPart
                    hrp.Size = Vector3.new(4, 4, 4)
                    hrp.Transparency = 0.7
                    hrp.CanCollide = false
                end
            end
        end)
    end))
end)

-- ==========================================
-- 4. KARAKTER VE HAREKET
-- ==========================================
PlayerTab:CreateSlider("Yürüme Hızı (WalkSpeed)", 16, 100, 16, function(val)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = val
    end
end)

PlayerTab:CreateToggle("Sonsuz Zıplama (Inf Jump)", false, function(state)
    _G.InfJump = state
    Track(UserInputService.JumpRequest:Connect(function()
        if _G.InfJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end))
end)

PlayerTab:CreateToggle("Düşük Yerçekimi (Moon Gravity)", false, function(state)
    Workspace.Gravity = state and 50 or 196.2
end)

PlayerTab:CreateToggle("Spinbot", false, function(state)
    _G.Spinbot = state
    Track(RunService.RenderStepped:Connect(function()
        if _G.Spinbot and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(30), 0)
        end
    end))
end)

PlayerTab:CreateToggle("BunnyHop (Otomatik Zıplama)", false, function(state)
    _G.Bhop = state
    Track(RunService.RenderStepped:Connect(function()
        if _G.Bhop and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            if LocalPlayer.Character.Humanoid.FloorMaterial ~= Enum.Material.Air then
                LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end))
end)

PlayerTab:CreateKeybind("Arayüz Aç/Kapat Tuşu", Enum.KeyCode.RightControl, function(key)
    print("Arayüz tuşu basıldı")
end)

-- ==========================================
-- 5. IŞINLANMA ÖZELLİKLERİ
-- ==========================================
TeleportTab:CreateButton("Yere Düşen Silaha Işınlan", function()
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj.Name == "GunDrop" and obj:FindFirstChild("Handle") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = obj.Handle.CFrame + Vector3.new(0, 3, 0)
            break
        end
    end
end)

TeleportTab:CreateButton("Harita Merkezine Işınlan", function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, 50, 0)
    end
end)

TeleportTab:CreateButton("Katilin Arkasına Işınlan", function()
    pcall(function()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local pChar = p.Character
                local backpack = p:FindFirstChild("Backpack")
                if pChar:FindFirstChild("Knife") or (backpack and backpack:FindFirstChild("Knife")) then
                    if pChar:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = pChar.HumanoidRootPart.CFrame * CFrame.new(0, 0, 4)
                        break
                    end
                end
            end
        end
    end)
end)

TeleportTab:CreateButton("Şerifin Yanına Işınlan", function()
    pcall(function()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local pChar = p.Character
                local backpack = p:FindFirstChild("Backpack")
                if pChar:FindFirstChild("Gun") or (backpack and backpack:FindFirstChild("Gun")) then
                    if pChar:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = pChar.HumanoidRootPart.CFrame + Vector3.new(3, 0, 0)
                        break
                    end
                end
            end
        end
    end)
end)

-- ==========================================
-- 6. EKSTRALAR VE AYARLAR
-- ==========================================
MiscTab:CreateToggle("Yere Düşen Silahı Otomatik Al", false, function(state)
    _G.AutoGun = state
    Track(RunService.Heartbeat:Connect(function()
        if not _G.AutoGun then return end
        pcall(function()
            for _, obj in ipairs(Workspace:GetChildren()) do
                if obj.Name == "GunDrop" and obj:FindFirstChild("Handle") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = obj.Handle.CFrame
                end
            end
        end)
    end))
end)

MiscTab:CreateButton("Sunucuyu Yenile (Rejoin)", function()
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
end)

MiscTab:CreateButton("FPS / Lag Temizleyici", function()
    pcall(function()
        for _, v in ipairs(Lighting:GetChildren()) do
            if v:IsA("PostEffect") then v.Enabled = false end
        end
        Workspace.Terrain.WaterWaveSize = 0
        Workspace.Terrain.WaterWaveTransparency = 1
    end)
end)

MiscTab:CreateButton("Katili İzle (Kamera Kilidi)", function()
    pcall(function()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local pChar = p.Character
                local backpack = p:FindFirstChild("Backpack")
                if pChar:FindFirstChild("Knife") or (backpack and backpack:FindFirstChild("Knife")) then
                    if pChar:FindFirstChild("Humanoid") then
                        Camera.CameraSubject = pChar.Humanoid
                        break
                    end
                end
            end
        end
    end)
end)

MiscTab:CreateButton("Kamerayı Kendine Geri Getir", function()
    pcall(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            Camera.CameraSubject = LocalPlayer.Character.Humanoid
        end
    end)
end)

MiscTab:CreateButton("Özel Nişangah (Crosshair)", function()
    pcall(function()
        local CoreGui = game:GetService("CoreGui")
        local chGui = Instance.new("ScreenGui", CoreGui)
        chGui.Name = "CustomCrosshair"
        local dot = Instance.new("Frame", chGui)
        dot.Size = UDim2.new(0, 6, 0, 6)
        dot.Position = UDim2.new(0.5, -3, 0.5, -3)
        dot.BackgroundColor3 = Color3.fromRGB(0, 255, 120)
        dot.BorderSizePixel = 0
        Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
    end)
end)

MiscTab:CreateButton("Arayüzü Ve Hileleri Tamamen Kapat", function()
    FullCleanup()
end)
