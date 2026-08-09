-- ==========================================
-- MM2 Masterpiece Hub v14.2 | Ultimate Fixed Edition
-- ==========================================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local Camera = Workspace.CurrentCamera

-- Eski arayüzleri tamamen temizle
if CoreGui:FindFirstChild("MM2ProHub") then CoreGui.MM2ProHub:Destroy() end
if CoreGui:FindFirstChild("MM2ProToggleBtn") then CoreGui.MM2ProToggleBtn:Destroy() end
if CoreGui:FindFirstChild("MM2Loading") then CoreGui.MM2Loading:Destroy() end

-- ==========================================
-- 1. ADIM: İLK AÇILIŞ VE YÜKLEME ANİMASYONU
-- ==========================================
local LoadingGui = Instance.new("ScreenGui")
LoadingGui.Name = "MM2Loading"
LoadingGui.Parent = CoreGui
LoadingGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local LoadFrame = Instance.new("Frame")
LoadFrame.Parent = LoadingGui
LoadFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
LoadFrame.Size = UDim2.new(0, 380, 0, 130)
LoadFrame.Position = UDim2.new(0.5, -190, 0.5, -65)

local LoadCorner = Instance.new("UICorner")
LoadCorner.CornerRadius = UDim.new(0, 12)
LoadCorner.Parent = LoadFrame

local LoadStroke = Instance.new("UIStroke")
LoadStroke.Parent = LoadFrame
LoadStroke.Color = Color3.fromRGB(0, 200, 120)
LoadStroke.Thickness = 2

local LoadTitle = Instance.new("TextLabel")
LoadTitle.Parent = LoadFrame
LoadTitle.BackgroundTransparency = 1
LoadTitle.Size = UDim2.new(1, 0, 0, 40)
LoadTitle.Position = UDim2.new(0, 0, 0.15, 0)
LoadTitle.Font = Enum.Font.GothamBold
LoadTitle.Text = "MM2 Masterpiece v14.2"
LoadTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
LoadTitle.TextSize = 18

local LoadStatus = Instance.new("TextLabel")
LoadStatus.Parent = LoadFrame
LoadStatus.BackgroundTransparency = 1
LoadStatus.Size = UDim2.new(1, 0, 0, 30)
LoadStatus.Position = UDim2.new(0, 0, 0.55, 0)
LoadStatus.Font = Enum.Font.Gotham
LoadStatus.Text = "Güvenli Zemin ve Silah Algılama Yükleniyor..."
LoadStatus.TextColor3 = Color3.fromRGB(170, 170, 180)
LoadStatus.TextSize = 13

-- Global Temizlik ve Bağlantı Havuzu
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
    _G.GunESP = false
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

-- Güvenli Harita İçi Rastgele Konum Bulucu (Lobiye Asla Atmaz)
local function GetSafeMapPosition(currentHrpPos, killerPos)
    for i = 1, 15 do
        local angle = math.random() * math.pi * 2
        local distance = math.random(35, 65)
        local testPos = currentHrpPos + Vector3.new(math.cos(angle) * distance, 40, math.sin(angle) * distance)
        
        local raycastParams = RaycastParams.new()
        raycastParams.FilterType = Enum.RaycastFilterType.Exclude
        raycastParams.IgnoreWater = true
        raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
        
        local rayResult = Workspace:Raycast(testPos, Vector3.new(0, -80, 0), raycastParams)
        if rayResult and rayResult.Instance and rayResult.Instance.CanCollide then
            local hitPos = rayResult.Position + Vector3.new(0, 3, 0)
            -- Katilin en az 20 birim uzakta olduğundan emin ol
            if (hitPos - killerPos).Magnitude > 20 then
                return hitPos
            end
        end
    end
    -- Zemin bulunamazsa oyuncunun arkasında güvenli yakın bir yere at
    return currentHrpPos + Vector3.new(math.random(-25, 25), 4, math.random(-25, 25))
end

-- ==========================================
-- 2. ADIM: ARAYÜZÜ KUR
-- ==========================================
task.delay(1.6, function()
    TweenService:Create(LoadFrame, TweenInfo.new(0.4), {Size = UDim2.new(0,0,0,0), BackgroundTransparency = 1}):Play()
    task.wait(0.4)
    LoadingGui:Destroy()

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MM2ProHub"
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local ToggleGui = Instance.new("ScreenGui")
    ToggleGui.Name = "MM2ProToggleBtn"
    ToggleGui.Parent = CoreGui
    ToggleGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Açma / Kapama Tuşu
    local FloatButton = Instance.new("TextButton")
    FloatButton.Parent = ToggleGui
    FloatButton.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    FloatButton.Position = UDim2.new(0.02, 0, 0.4, 0)
    FloatButton.Size = UDim2.new(0, 56, 0, 56)
    FloatButton.Font = Enum.Font.GothamBold
    FloatButton.Text = "MM2\nPRO"
    FloatButton.TextColor3 = Color3.fromRGB(0, 200, 120)
    FloatButton.TextSize = 11
    FloatButton.Active = true
    FloatButton.Draggable = true

    local FloatCorner = Instance.new("UICorner")
    FloatCorner.CornerRadius = UDim.new(1, 0)
    FloatCorner.Parent = FloatButton

    local FloatStroke = Instance.new("UIStroke")
    FloatStroke.Parent = FloatButton
    FloatStroke.Color = Color3.fromRGB(0, 200, 120)
    FloatStroke.Thickness = 2

    -- Ana Pencere
    local MainFrame = Instance.new("Frame")
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
    MainFrame.Position = UDim2.new(0.5, -300, 0.5, -210)
    MainFrame.Size = UDim2.new(0, 600, 0, 420)
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Visible = false

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 10)
    MainCorner.Parent = MainFrame

    FloatButton.MouseButton1Click:Connect(function()
        MainFrame.Visible = not MainFrame.Visible
    end)

    -- Üst Bar
    local TopBar = Instance.new("Frame")
    TopBar.Parent = MainFrame
    TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 34)
    TopBar.Size = UDim2.new(1, 0, 0, 42)

    local TopCorner = Instance.new("UICorner")
    TopCorner.CornerRadius = UDim.new(0, 10)
    TopCorner.Parent = TopBar

    local Title = Instance.new("TextLabel")
    Title.Parent = TopBar
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0.03, 0, 0, 0)
    Title.Size = UDim2.new(0.6, 0, 1, 0)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "MM2 Masterpiece Hub v14.2 | Fixed Safe Teleport & Gun"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 13
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local CloseButton = Instance.new("TextButton")
    CloseButton.Parent = TopBar
    CloseButton.BackgroundColor3 = Color3.fromRGB(220, 45, 45)
    CloseButton.Position = UDim2.new(0.93, 0, 0.2, 0)
    CloseButton.Size = UDim2.new(0, 26, 0, 26)
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 13

    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 6)
    CloseCorner.Parent = CloseButton

    CloseButton.MouseButton1Click:Connect(function()
        FullCleanup()
        ScreenGui:Destroy()
        ToggleGui:Destroy()
    end)

    -- Sol Menü & Sekmeler
    local Sidebar = Instance.new("Frame")
    Sidebar.Parent = MainFrame
    Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    Sidebar.Position = UDim2.new(0, 0, 0, 42)
    Sidebar.Size = UDim2.new(0, 150, 1, -42)

    local SidebarLayout = Instance.new("UIListLayout")
    SidebarLayout.Parent = Sidebar
    SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    SidebarLayout.Padding = UDim.new(0, 4)

    local Container = Instance.new("Frame")
    Container.Parent = MainFrame
    Container.BackgroundTransparency = 1
    Container.Position = UDim2.new(0, 160, 0, 50)
    Container.Size = UDim2.new(1, -170, 1, -60)

    local pages = {}
    local function CreatePage(name)
        local ScrollingFrame = Instance.new("ScrollingFrame")
        ScrollingFrame.Name = name .. "Page"
        ScrollingFrame.Parent = Container
        ScrollingFrame.Active = true
        ScrollingFrame.BackgroundTransparency = 1
        ScrollingFrame.Size = UDim2.new(1, 0, 1, 0)
        ScrollingFrame.CanvasSize = UDim2.new(0, 0, 4.5, 0)
        ScrollingFrame.ScrollBarThickness = 4
        ScrollingFrame.Visible = false

        local Layout = Instance.new("UIListLayout")
        Layout.Parent = ScrollingFrame
        Layout.SortOrder = Enum.SortOrder.LayoutOrder
        Layout.Padding = UDim.new(0, 8)

        pages[name] = ScrollingFrame
        return ScrollingFrame
    end

    local function SwitchPage(name)
        for _, page in pairs(pages) do page.Visible = false end
        if pages[name] then pages[name].Visible = true end
    end

    local function CreateTab(name, targetPage)
        local TabButton = Instance.new("TextButton")
        TabButton.Parent = Sidebar
        TabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        TabButton.Size = UDim2.new(1, 0, 0, 32)
        TabButton.Font = Enum.Font.GothamMedium
        TabButton.Text = name
        TabButton.TextColor3 = Color3.fromRGB(180, 180, 190)
        TabButton.TextSize = 11

        TabButton.MouseButton1Click:Connect(function()
            SwitchPage(targetPage)
        end)
    end

    CreatePage("Protection")
    CreatePage("Farm")
    CreatePage("Visuals")
    CreatePage("Player")
    CreatePage("Teleports")
    CreatePage("Misc")

    CreateTab("Güvenli Koruma", "Protection")
    CreateTab("Akıllı Farm & Noclip", "Farm")
    CreateTab("Görsel / ESP", "Visuals")
    CreateTab("Karakter & Hareket", "Player")
    CreateTab("Işınlanma", "Teleports")
    CreateTab("Ekstralar & Ayarlar", "Misc")

    SwitchPage("Protection")

    local function AddToggle(page, text, callback)
        local ToggleBtn = Instance.new("TextButton")
        ToggleBtn.Parent = pages[page]
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 42)
        ToggleBtn.Size = UDim2.new(0.95, 0, 0, 36)
        ToggleBtn.Font = Enum.Font.Gotham
        ToggleBtn.Text = "  [OFF] " .. text
        ToggleBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
        ToggleBtn.TextSize = 11
        ToggleBtn.TextXAlignment = Enum.TextXAlignment.Left

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 6)
        Corner.Parent = ToggleBtn

        local state = false
        ToggleBtn.MouseButton1Click:Connect(function()
            state = not state
            if state then
                ToggleBtn.Text = "  [ON] " .. text
                ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
            else
                ToggleBtn.Text = "  [OFF] " .. text
                ToggleBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 42)
            end
            callback(state)
        end)
    end

    local function AddButton(page, text, callback)
        local Btn = Instance.new("TextButton")
        Btn.Parent = pages[page]
        Btn.BackgroundColor3 = Color3.fromRGB(45, 45, 58)
        Btn.Size = UDim2.new(0.95, 0, 0, 36)
        Btn.Font = Enum.Font.GothamMedium
        Btn.Text = text
        Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        Btn.TextSize = 11

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 6)
        Corner.Parent = Btn

        Btn.MouseButton1Click:Connect(callback)
    end

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
    -- 1. GÜVENLİ KORUMA (HARİTA İÇİ GÜVENLİ RASTGELE NOKTA)
    -- ==========================================
    AddToggle("Protection", "Acil Kaçış Kalkanı (Katil Yaklaşınca Haritaya Işınlan)", function(state)
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
                                -- Lobiye değil, harita içinde katilden uzak güvenli rastgele bir zemine ışınla
                                local safePos = GetSafeMapPosition(hrp.Position, pHrp.Position)
                                hrp.CFrame = CFrame.new(safePos)
                            end
                        end
                    end
                end
            end)
        end))
    end)

    AddToggle("Protection", "Gelişmiş Bıçak Yok Edici (Anti-Throw Knife)", function(state)
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

    AddToggle("Protection", "Görünmezlik Modu (Client Stealth)", function(state)
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
    AddToggle("Farm", "Akıllı Noclip + Yumuşak Uçuş Coin Farm", function(state)
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
                end
            end
            if not _G.SmartFarm then
                _G.NoclipActive = false
            end
        end)
    end)

    AddToggle("Farm", "Noclip Modu (Duvarlardan Geçiş)", function(state)
        _G.NoclipActive = state
    end)

    -- ==========================================
    -- 3. GÖRSEL / ESP & ÖZELLİKLER (DÜZELTİLDİ: GUN ESP EKLENDİ)
    -- ==========================================
    AddToggle("Visuals", "Rol ESP (Katil: Kırmızı, Şerif: Mavi)", function(state)
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

    AddToggle("Visuals", "Yerdeki Silah ESP (GunDrop ESP)", function(state)
        _G.GunESP = state
        Track(RunService.RenderStepped:Connect(function()
            if not _G.GunESP then return end
            for _, obj in ipairs(Workspace:GetChildren()) do
                if obj.Name == "GunDrop" then
                    local handle = obj:FindFirstChild("Handle") or obj:FindFirstChildWhichIsA("BasePart")
                    if handle then
                        local hl = handle:FindFirstChild("GunHighlight")
                        if not hl then
                            hl = Instance.new("Highlight")
                            hl.Name = "GunHighlight"
                            hl.FillColor = Color3.fromRGB(255, 215, 0)
                            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                            hl.Parent = handle
                        end
                    end
                end
            end
        end))
    end)

    AddToggle("Visuals", "FullBright (Karanlık Haritaları Aydınlat)", function(state)
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

    AddToggle("Visuals", "Hitbox Büyütücü (Kolay Hedef Alma)", function(state)
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
    AddToggle("Player", "Hız Hilesi (WalkSpeed: 22)", function(state)
        _G.SpeedEnabled = state
        Track(RunService.RenderStepped:Connect(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = _G.SpeedEnabled and 22 or 16
            end
        end))
    end)

    AddToggle("Player", "Sonsuz Zıplama (Inf Jump)", function(state)
        _G.InfJump = state
        Track(UserInputService.JumpRequest:Connect(function()
            if _G.InfJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end))
    end)

    AddToggle("Player", "Düşük Yerçekimi (Moon Gravity)", function(state)
        Workspace.Gravity = state and 50 or 196.2
    end)

    AddToggle("Player", "Spinbot (Etrafta Hızlı Dönme)", function(state)
        _G.Spinbot = state
        Track(RunService.RenderStepped:Connect(function()
            if _G.Spinbot and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(30), 0)
            end
        end))
    end)

    AddButton("Player", "Görüş Açısını Genişlet (FOV 90)", function()
        pcall(function()
            Camera.FieldOfView = 90
        end)
    end)

    -- ==========================================
    -- 5. IŞINLANMA & OTOMATİK SİLAH ALMA (DÜZELTİLDİ)
    -- ==========================================
    AddButton("Teleports", "Yere Düşen Silaha (GunDrop) Işınlan", function()
        pcall(function()
            for _, obj in ipairs(Workspace:GetChildren()) do
                if obj.Name == "GunDrop" then
                    local handle = obj:FindFirstChild("Handle") or obj:FindFirstChildWhichIsA("BasePart")
                    if handle and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = handle.CFrame + Vector3.new(0, 3, 0)
                        break
                    end
                end
            end
        end)
    end)

    AddButton("Teleports", "Harita Merkezine Işınlan", function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, 50, 0)
        end
    end)

    AddButton("Teleports", "Katilin Arkasına Işınlan", function()
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

    -- ==========================================
    -- 6. EKSTRALAR VE AYARLAR
    -- ==========================================
    AddButton("Misc", "Sunucuyu Yenile (Rejoin Server)", function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end)

    AddButton("Misc", "FPS / Lag Temizleyici (Optimize)", function()
        pcall(function()
            for _, v in ipairs(Lighting:GetChildren()) do
                if v:IsA("PostEffect") then v.Enabled = false end
            end
            Workspace.Terrain.WaterWaveSize = 0
            Workspace.Terrain.WaterWaveTransparency = 1
        end)
    end)

    AddToggle("Misc", "Yere Düşen Silahı Otomatik Al", function(state)
        _G.AutoGun = state
        Track(RunService.Heartbeat:Connect(function()
            if not _G.AutoGun then return end
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end

                for _, obj in ipairs(Workspace:GetChildren()) do
                    if obj.Name == "GunDrop" then
                        local handle = obj:FindFirstChild("Handle") or obj:FindFirstChildWhichIsA("BasePart")
                        if handle then
                            hrp.CFrame = handle.CFrame + Vector3.new(0, 1, 0)
                        end
                    end
                end
            end)
        end))
    end)

    AddButton("Misc", "Ekrana Özel Crosshair (Nişangah) Ekle", function()
        pcall(function()
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
end)

