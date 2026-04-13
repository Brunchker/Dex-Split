-- ==========================================
-- 🔐 DEX UNIVERSAL TD: IMAGE HOTBAR + KEY SYSTEM (MELHORADO)
-- ==========================================
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

local API_URL = "https://378a1bde-b6e1-4db4-aff1-0cc7474cfd3c-00-2thtejootj7d7.kirk.replit.dev/validate"
local KEY_FILE = "Dex_Ultra_Key.txt"

-- ==========================================
-- UI DA KEY SYSTEM
-- ==========================================
local targetParent
pcall(function() targetParent = (gethui and gethui()) or game:GetService("CoreGui") end)
if not targetParent then targetParent = player:WaitForChild("PlayerGui") end

if targetParent:FindFirstChild("KeySystem") then targetParent.KeySystem:Destroy() end

local keyGui = Instance.new("ScreenGui")
keyGui.Name = "KeySystem"
keyGui.ResetOnSpawn = false
keyGui.Parent = targetParent

local frame = Instance.new("Frame", keyGui)
frame.Size = UDim2.new(0, 360, 0, 210)
frame.Position = UDim2.new(0.5, -180, 0.5, -105)
frame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 18)
local keyStroke = Instance.new("UIStroke", frame)
keyStroke.Color = Color3.fromRGB(0, 200, 255)
keyStroke.Thickness = 2

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundTransparency = 1
title.Text = "🔐 DEX ULTRA SYSTEM"
title.TextColor3 = Color3.fromRGB(0, 255, 255)
title.Font = Enum.Font.GothamBlack
title.TextSize = 22

local box = Instance.new("TextBox", frame)
box.Size = UDim2.new(1, -40, 0, 50)
box.Position = UDim2.new(0, 20, 0, 65)
box.PlaceholderText = "Cole sua key aqui..."
box.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
box.TextColor3 = Color3.fromRGB(255, 255, 255)
box.Font = Enum.Font.Gotham
box.TextSize = 16
box.ClearTextOnFocus = false
Instance.new("UICorner", box).CornerRadius = UDim.new(0, 12)

local btn = Instance.new("TextButton", frame)
btn.Size = UDim2.new(1, -40, 0, 50)
btn.Position = UDim2.new(0, 20, 0, 125)
btn.Text = "VALIDAR KEY"
btn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
btn.TextColor3 = Color3.fromRGB(255, 255, 255)
btn.Font = Enum.Font.GothamBlack
btn.TextSize = 18
Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)

-- ==========================================
-- FUNÇÃO LOAD DEX
-- ==========================================
local function loadDex()
    keyGui:Destroy()

    local FILE = "Dex_Ultra_Loadouts.json"
    local function loadFile()
        if isfile and isfile(FILE) then
            local success, result = pcall(function() return HttpService:JSONDecode(readfile(FILE)) end)
            if success then return result end
        end
        return {}
    end
    local function saveFile(data)
        if writefile then pcall(function() writefile(FILE, HttpService:JSONEncode(data)) end) end
    end
    local Saves = loadFile()
    getgenv().SavedTowers = getgenv().SavedTowers or {}

    local selectedTower, preview, rangeCircle = nil, nil, nil
    local rotation, heightOffset, autoOffset = 0, 0, 0
    local selectedSlot = nil

    -- ==================== FUNÇÃO DETECTOR MELHORADO (DEX EXPLORER) ====================
    local function getUniversalTowersFolder()
        local bestFolder = nil
        local maxScore = 0

        local searchContainers = {
            ReplicatedStorage,
            workspace,
            game:FindFirstChild("ServerStorage"),
            game:FindFirstChild("StarterPack"),
            game:FindFirstChild("StarterGui"),
        }

        local keywords = {"tower", "unit", "hero", "enemy", "wave", "shop", "buy", "place", "spawn", "tiers", "pack", "models"}

        for _, container in ipairs(searchContainers) do
            if container then
                for _, desc in ipairs(container:GetDescendants()) do
                    if desc:IsA("Folder") or desc:IsA("Model") then
                        local modelCount = 0
                        local nameLower = desc.Name:lower()

                        for _, child in ipairs(desc:GetChildren()) do
                            if child:IsA("Model") then modelCount += 1 end
                        end

                        local nameScore = 0
                        for _, kw in ipairs(keywords) do
                            if nameLower:find(kw) then nameScore += 30 end
                        end

                        local score = (modelCount * 12) + nameScore

                        if modelCount >= 3 and score > maxScore then
                            maxScore = score
                            bestFolder = desc
                        end
                    end
                end
            end
        end

        -- Backup bruto
        if not bestFolder then
            for _, desc in ipairs(ReplicatedStorage:GetDescendants()) do
                if (desc:IsA("Folder") or desc:IsA("Model")) and #desc:GetChildren() >= 5 then
                    bestFolder = desc
                    break
                end
            end
        end

        if bestFolder then
            print("✅ DEX EXPLORER encontrou towers em: " .. bestFolder:GetFullName())
            print("   Quantidade aproximada: " .. #bestFolder:GetChildren())
        else
            warn("⚠️ DEX não encontrou nenhuma pasta de towers!")
        end

        return bestFolder
    end

    local function getCleanName(rawName)
        local name = rawName
        name = string.gsub(name, "%[.-%]", "")
        name = string.gsub(name, "%(.-%)", "")
        name = string.gsub(name, "[Ll][Vv][Ll]%s*%w*", "")
        name = string.gsub(name, "[Ll][Ee][Vv][Ee][Ll]%s*%w*", "")
        name = string.gsub(name, "[Mm][Aa][Xx]", "")
        name = string.gsub(name, "[Tt][Ii][Ee][Rr]%s*%w+", "")
        name = string.gsub(name, "[Ss][Tt][Aa][Rr]%s*%w+", "")
        name = string.gsub(name, "[%s_%-]*%d+$", "")
        name = string.gsub(name, "^%d+[%s_%-]*", "")
        name = string.gsub(name, "[_%-]+$", "")
        name = string.match(name, "^%s*(.-)%s*$") or name
        return name
    end

    local function getUniversalInfo(unit, keyword)
        for _, v in ipairs(unit:GetDescendants()) do
            if (v:IsA("IntValue") or v:IsA("NumberValue")) and string.find(v.Name:lower(), keyword) then
                return v.Value
            end
        end
        return nil
    end

    -- ==================== RESTO DO CÓDIGO (UI + Funcionamento) ====================
    local tInfoHover = TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    local tInfoSlide = TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

    local function playSound(id, pitch)
        pcall(function()
            local s = Instance.new("Sound", workspace)
            s.SoundId = "rbxassetid://" .. id; s.Volume = 0.4; s.PlaybackSpeed = pitch or 1
            s:Play(); game.Debris:AddItem(s, 2)
        end)
    end

    if targetParent:FindFirstChild("DexUltraTD") then targetParent.DexUltraTD:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "DexUltraTD"; gui.ResetOnSpawn = false; gui.Parent = targetParent

    local hotbarWrap = Instance.new("Frame", gui)
    hotbarWrap.Size = UDim2.new(0, 600, 0, 140)
    hotbarWrap.Position = UDim2.new(0.5, 0, 0.98, 0)
    hotbarWrap.AnchorPoint = Vector2.new(0.5, 1)
    hotbarWrap.BackgroundTransparency = 1
    hotbarWrap.ClipsDescendants = true

    local hotbarBg = Instance.new("ImageLabel", hotbarWrap)
    hotbarBg.Size = UDim2.new(1, 0, 1, 0)
    hotbarBg.BackgroundTransparency = 1
    hotbarBg.Image = "rbxassetid://10651034444" 
    hotbarBg.ScaleType = Enum.ScaleType.Stretch
    hotbarBg.ImageColor3 = Color3.fromRGB(180, 200, 255)

    local animatedGrid = Instance.new("ImageLabel", hotbarWrap)
    animatedGrid.Size = UDim2.new(1, 0, 1, 0)
    animatedGrid.BackgroundTransparency = 1
    animatedGrid.Image = "rbxassetid://7151855462" 
    animatedGrid.ImageColor3 = Color3.fromRGB(0, 200, 255)
    animatedGrid.ImageTransparency = 0.8 
    animatedGrid.ScaleType = Enum.ScaleType.Tile
    animatedGrid.TileSize = UDim2.new(0, 100, 0, 100)
    animatedGrid.ZIndex = 2

    RunService.RenderStepped:Connect(function(dt)
        if animatedGrid then
            local currentOffset = animatedGrid.ImageRectOffset
            animatedGrid.ImageRectOffset = Vector2.new(currentOffset.X + (dt * 20), currentOffset.Y - (dt * 10))
        end
    end)

    local hotbarScroll = Instance.new("ScrollingFrame", hotbarWrap)
    hotbarScroll.Size = UDim2.new(1, -90, 1, -20)
    hotbarScroll.Position = UDim2.new(0, 75, 0, 10)
    hotbarScroll.BackgroundTransparency = 1
    hotbarScroll.ScrollBarThickness = 0
    hotbarScroll.ScrollingDirection = Enum.ScrollingDirection.X
    hotbarScroll.ZIndex = 5

    local layoutHotbar = Instance.new("UIListLayout", hotbarScroll)
    layoutHotbar.FillDirection = Enum.FillDirection.Horizontal
    layoutHotbar.Padding = UDim.new(0, 15)
    layoutHotbar.VerticalAlignment = Enum.VerticalAlignment.Center

    layoutHotbar:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        hotbarScroll.CanvasSize = UDim2.new(0, layoutHotbar.AbsoluteContentSize.X + 20, 0, 0)
        hotbarWrap.Size = UDim2.new(0, math.min(layoutHotbar.AbsoluteContentSize.X + 110, 850), 0, 140)
    end)

    local hintTxt = Instance.new("TextLabel", hotbarWrap)
    hintTxt.Size = UDim2.new(1, 0, 0, 30)
    hintTxt.Position = UDim2.new(0, 0, 0, -35)
    hintTxt.BackgroundTransparency = 1
    hintTxt.Text = "✨ [X] Cancelar | [Q/E] Rotacionar | [R/F] Altura"
    hintTxt.TextColor3 = Color3.fromRGB(0, 255, 255)
    hintTxt.Font = Enum.Font.GothamBlack
    hintTxt.TextSize = 16
    hintTxt.TextStrokeTransparency = 0
    hintTxt.TextTransparency = 1

    -- Loadout Panel (mesmo de antes)
    local loadoutPanel = Instance.new("Frame", gui)
    loadoutPanel.Size = UDim2.new(0, 280, 0, 480)
    loadoutPanel.Position = UDim2.new(0, -350, 0.5, 0)
    loadoutPanel.AnchorPoint = Vector2.new(0, 0.5)
    loadoutPanel.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    Instance.new("UICorner", loadoutPanel).CornerRadius = UDim.new(0, 16)
    Instance.new("UIStroke", loadoutPanel).Color = Color3.fromRGB(0, 180, 255)

    local titleLoad = Instance.new("TextLabel", loadoutPanel)
    titleLoad.Size = UDim2.new(1, 0, 0, 50); titleLoad.BackgroundTransparency = 1
    titleLoad.Text = "🔮 LOADOUTS"; titleLoad.TextColor3 = Color3.new(1,1,1)
    titleLoad.Font = Enum.Font.GothamBlack; titleLoad.TextSize = 24

    local inputLoad = Instance.new("TextBox", loadoutPanel)
    inputLoad.Size = UDim2.new(1, -30, 0, 40); inputLoad.Position = UDim2.new(0, 15, 0, 60)
    inputLoad.BackgroundColor3 = Color3.fromRGB(25, 25, 35); inputLoad.TextColor3 = Color3.fromRGB(0, 255, 255)
    inputLoad.PlaceholderText = "Nome do Loadout..."; inputLoad.Font = Enum.Font.GothamBold
    Instance.new("UICorner", inputLoad).CornerRadius = UDim.new(0, 10)

    local function createGradientButton(parent, pos, text, c1, c2)
        local btn = Instance.new("TextButton", parent)
        btn.Size = UDim2.new(1, -30, 0, 45); btn.Position = pos; btn.BackgroundColor3 = Color3.new(1,1,1)
        btn.Text = text; btn.TextColor3 = Color3.new(1,1,1); btn.Font = Enum.Font.GothamBlack; btn.TextSize = 16
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
        local grad = Instance.new("UIGradient", btn)
        grad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, c1), ColorSequenceKeypoint.new(1, c2)}
        local scale = Instance.new("UIScale", btn)
        btn.MouseEnter:Connect(function() TweenService:Create(scale, tInfoHover, {Scale = 1.06}):Play() end)
        btn.MouseLeave:Connect(function() TweenService:Create(scale, tInfoHover, {Scale = 1}):Play() end)
        return btn
    end

    local btnSave = createGradientButton(loadoutPanel, UDim2.new(0, 15, 0, 115), "💾 SALVAR LOADOUT", Color3.fromRGB(0, 200, 100), Color3.fromRGB(0, 120, 255))
    local btnReset = createGradientButton(loadoutPanel, UDim2.new(0, 15, 1, -60), "🔄 RESETAR TUDO", Color3.fromRGB(255, 80, 60), Color3.fromRGB(180, 0, 40))

    local saveList = Instance.new("ScrollingFrame", loadoutPanel)
    saveList.Size = UDim2.new(1, -30, 1, -240); saveList.Position = UDim2.new(0, 15, 0, 170)
    saveList.BackgroundTransparency = 1; saveList.ScrollBarThickness = 4
    local layoutSaves = Instance.new("UIListLayout", saveList)
    layoutSaves.Padding = UDim.new(0, 8)

    local toggleMenuBtn = Instance.new("TextButton", hotbarWrap)
    toggleMenuBtn.Size = UDim2.new(0, 60, 0, 60); toggleMenuBtn.Position = UDim2.new(0, 8, 0.5, 0)
    toggleMenuBtn.AnchorPoint = Vector2.new(0, 0.5); toggleMenuBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 32)
    toggleMenuBtn.Text = "≡"; toggleMenuBtn.TextColor3 = Color3.fromRGB(0, 220, 255); toggleMenuBtn.TextSize = 40
    toggleMenuBtn.ZIndex = 6
    Instance.new("UICorner", toggleMenuBtn).CornerRadius = UDim.new(0, 14)
    Instance.new("UIStroke", toggleMenuBtn).Color = Color3.fromRGB(0, 180, 255)

    local isMenuOpen = false
    toggleMenuBtn.MouseButton1Click:Connect(function()
        playSound("6895086153", 1)
        isMenuOpen = not isMenuOpen
        local target = isMenuOpen and UDim2.new(0, 20, 0.5, 0) or UDim2.new(0, -350, 0.5, 0)
        TweenService:Create(loadoutPanel, tInfoSlide, {Position = target}):Play()
    end)

    local function cancelPlacement()
        selectedTower = nil
        if preview then preview:Destroy() preview = nil end
        if rangeCircle then rangeCircle:Destroy() rangeCircle = nil end
        if selectedSlot then
            selectedSlot.UIStroke.Color = Color3.fromRGB(60, 60, 80)
            selectedSlot = nil
        end
        TweenService:Create(hintTxt, tInfoHover, {TextTransparency = 1}):Play()
    end

    local function createPreview(towerName)
        if preview then preview:Destroy() end
        if rangeCircle then rangeCircle:Destroy() end

        local folder = getUniversalTowersFolder()
        local realModel = nil
        local rangeValue = 15

        if folder then
            for _, child in ipairs(folder:GetChildren()) do
                if getCleanName(child.Name) == towerName then
                    realModel = child
                    local r = getUniversalInfo(child, "range")
                    if r then rangeValue = r end
                    break
                end
            end
        end

        rangeCircle = Instance.new("Part")
        rangeCircle.Size = Vector3.new(rangeValue*2, 0.1, rangeValue*2)
        rangeCircle.Anchored = true; rangeCircle.CanCollide = false; rangeCircle.Transparency = 0.65
        rangeCircle.Color = Color3.fromRGB(0, 255, 180); rangeCircle.Material = Enum.Material.Neon
        Instance.new("CylinderMesh", rangeCircle); rangeCircle.Parent = workspace

        if realModel then
            preview = realModel:Clone()
            autoOffset = 0
            local lowest = math.huge
            for _, v in ipairs(preview:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = false; v.CanQuery = false; v.Transparency = 0.35
                    v.Material = Enum.Material.Neon; v.Color = Color3.fromRGB(0, 160, 255)
                    local bottom = v.Position.Y - v.Size.Y/2
                    if bottom < lowest then lowest = bottom end
                elseif v:IsA("Script") or v:IsA("LocalScript") then v:Destroy() end
            end
            if lowest ~= math.huge then autoOffset = preview:GetPivot().Position.Y - lowest end
        else
            preview = Instance.new("Part"); preview.Size = Vector3.new(5,5,5); preview.Transparency = 0.4
            preview.Color = Color3.fromRGB(0, 170, 255); preview.Material = Enum.Material.Neon; autoOffset = 2.5
        end
        preview.Parent = workspace
    end

    RunService.RenderStepped:Connect(function()
        if preview and rangeCircle then
            local rayParams = RaycastParams.new()
            rayParams.FilterDescendantsInstances = {preview, rangeCircle, player.Character}
            rayParams.FilterType = Enum.RaycastFilterType.Exclude
            local ray = workspace:Raycast(mouse.UnitRay.Origin, mouse.UnitRay.Direction * 1000, rayParams)
            if ray then
                rangeCircle.CFrame = CFrame.new(ray.Position + Vector3.new(0, 0.15, 0))
                local cf = CFrame.new(ray.Position + Vector3.new(0, autoOffset + heightOffset, 0)) * CFrame.Angles(0, math.rad(rotation), 0)
                if preview:IsA("Model") then preview:PivotTo(cf) else preview.CFrame = cf end
            end
        end
    end)

    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.Q then rotation -= 90
        elseif input.KeyCode == Enum.KeyCode.E then rotation += 90
        elseif input.KeyCode == Enum.KeyCode.R then heightOffset += 0.5
        elseif input.KeyCode == Enum.KeyCode.F then heightOffset -= 0.5
        elseif input.KeyCode == Enum.KeyCode.X then cancelPlacement()
        elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
            if selectedTower and preview then
                playSound("876939830", 1)
                local cf = preview:IsA("Model") and preview:GetPivot() or preview.CFrame
                ReplicatedStorage:WaitForChild("Functions"):WaitForChild("SpawnTower"):InvokeServer(selectedTower, cf)
            end
        end
    end)

    local function createCard(unitName, priceVal)
        local card = Instance.new("TextButton", hotbarScroll)
        card.Size = UDim2.new(0, 95, 0, 115)
        card.BackgroundColor3 = Color3.fromRGB(22, 22, 35)
        card.Text = ""; card.AutoButtonColor = false; card.ZIndex = 6
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)
        
        local stroke = Instance.new("UIStroke", card)
        stroke.Thickness = 2.8; stroke.Color = Color3.fromRGB(60, 60, 80)
        
        local grad = Instance.new("UIGradient", card)
        grad.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(45, 45, 65)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(18, 18, 32))
        }

        local title = Instance.new("TextLabel", card)
        title.Size = UDim2.new(1, -12, 0.5, 0); title.Position = UDim2.new(0, 6, 0, 8)
        title.BackgroundTransparency = 1; title.Text = unitName
        title.TextColor3 = Color3.new(1,1,1); title.Font = Enum.Font.GothamBlack; title.TextScaled = true; title.ZIndex = 6

        local cost = Instance.new("TextLabel", card)
        cost.Size = UDim2.new(1, 0, 0.3, 0); cost.Position = UDim2.new(0, 0, 0.63, 0)
        cost.BackgroundTransparency = 1; cost.Text = "💲 " .. tostring(priceVal or "?")
        cost.TextColor3 = Color3.fromRGB(0, 255, 170); cost.Font = Enum.Font.GothamBold; cost.TextScaled = true; cost.ZIndex = 6

        local scale = Instance.new("UIScale", card)
        card.MouseEnter:Connect(function() TweenService:Create(scale, tInfoHover, {Scale = 1.09}):Play() end)
        card.MouseLeave:Connect(function() TweenService:Create(scale, tInfoHover, {Scale = 1}):Play() end)

        card.MouseButton1Click:Connect(function()
            playSound("138677306", 1); cancelPlacement()
            selectedTower = unitName; createPreview(unitName)
            stroke.Color = Color3.fromRGB(0, 255, 255); selectedSlot = card
            TweenService:Create(hintTxt, tInfoHover, {TextTransparency = 0}):Play()
        end)
    end

    local function loadTowers()
        for _, v in ipairs(hotbarScroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
        local folder = getUniversalTowersFolder()
        if folder then
            local added = {}
            for _, u in ipairs(folder:GetChildren()) do
                if u:IsA("Model") then
                    local name = getCleanName(u.Name)
                    if not added[name] then
                        createCard(name, getUniversalInfo(u, "price") or getUniversalInfo(u, "cost") or "?")
                        added[name] = true
                    end
                end
            end
        end
    end

    -- Loadout functions (mantidas iguais)
    local function renderSaves()
        for _, v in ipairs(saveList:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end
        for name, towers in pairs(Saves) do
            local f = Instance.new("Frame", saveList)
            f.Size = UDim2.new(1,0,0,45); f.BackgroundColor3 = Color3.fromRGB(30,30,40)
            Instance.new("UICorner", f).CornerRadius = UDim.new(0,10)
            
            local b = Instance.new("TextButton", f)
            b.Size = UDim2.new(0.75,0,1,0); b.BackgroundTransparency = 1; b.Text = "  "..name
            b.TextColor3 = Color3.new(1,1,1); b.Font = Enum.Font.GothamBold; b.TextXAlignment = Enum.TextXAlignment.Left
            
            local d = Instance.new("TextButton", f)
            d.Size = UDim2.new(0.25,0,1,0); d.Position = UDim2.new(0.75,0,0,0)
            d.BackgroundTransparency = 1; d.Text = "🗑"; d.TextSize = 18
            
            b.MouseButton1Click:Connect(function()
                getgenv().SavedTowers = towers; loadTowers()
                isMenuOpen = false; TweenService:Create(loadoutPanel, tInfoSlide, {Position = UDim2.new(0, -350, 0.5, 0)}):Play()
            end)
            d.MouseButton1Click:Connect(function() Saves[name] = nil; saveFile(Saves); renderSaves() end)
        end
    end

    btnSave.MouseButton1Click:Connect(function()
        if inputLoad.Text ~= "" then
            local list, added, folder = {}, {}, getUniversalTowersFolder()
            if folder then
                for _, v in ipairs(folder:GetChildren()) do
                    if v:IsA("Model") then
                        local c = getCleanName(v.Name)
                        if not added[c] then table.insert(list, c); added[c] = true end
                    end
                end
            end
            Saves[inputLoad.Text] = list; saveFile(Saves); renderSaves(); inputLoad.Text = ""
        end
    end)

    btnReset.MouseButton1Click:Connect(function() getgenv().SavedTowers = {}; loadTowers() end)

    local hotbarScale = Instance.new("UIScale", hotbarWrap); hotbarScale.Scale = 0
    TweenService:Create(hotbarScale, tInfoSlide, {Scale = 1}):Play()
    playSound("6895086153", 0.5)

    task.wait(0.4); loadTowers(); renderSaves()
end

-- ==========================================
-- KEY SYSTEM (mantido igual)
-- ==========================================
local function validateKey(key)
    if key == "DEV" then return true end
    local success, response = pcall(function()
        return game:HttpGet(API_URL .. "?key=" .. HttpService:UrlEncode(key))
    end)
    if not success then return false end
    local decodeSuccess, data = pcall(function() return HttpService:JSONDecode(response) end)
    if not decodeSuccess then return false end
    return data.success == true
end

local function getSavedKey()
    if isfile and isfile(KEY_FILE) then
        local success, result = pcall(function() return readfile(KEY_FILE) end)
        if success and result and result ~= "" then return result end
    end
    return nil
end

local function saveKeyFile(key)
    if writefile then pcall(function() writefile(KEY_FILE, key) end) end
end

local function deleteKeyFile()
    if delfile and isfile and isfile(KEY_FILE) then
        pcall(function() delfile(KEY_FILE) end)
    elseif writefile then
        pcall(function() writefile(KEY_FILE, "") end)
    end
end

btn.MouseButton1Click:Connect(function()
    local key = box.Text
    if key == "" then return end
    btn.Text = "VALIDANDO..."
    btn.BackgroundColor3 = Color3.fromRGB(255, 140, 0)

    if validateKey(key) then
        saveKeyFile(key)
        btn.Text = "KEY VÁLIDA ✓"
        btn.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
        task.wait(1)
        loadDex()
    else
        btn.Text = "KEY INVÁLIDA (Ou API off) ✕"
        btn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
        task.wait(1.5)
        btn.Text = "VALIDAR KEY"
        btn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    end
end)

local savedKey = getSavedKey()
if savedKey then
    box.Text = savedKey
    btn.Text = "VERIFICANDO KEY SALVA..."
    btn.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
    
    task.spawn(function()
        if validateKey(savedKey) then
            btn.Text = "LOGIN AUTOMÁTICO ✓"
            btn.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
            task.wait(0.5)
            loadDex()
        else
            deleteKeyFile()
            btn.Text = "KEY EXPIRADA ✕"
            btn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
            box.Text = ""
            task.wait(1.5)
            btn.Text = "VALIDAR KEY"
            btn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        end
    end)
end

print("🔐 DEX ULTRA com Detector Melhorado Carregado!")
