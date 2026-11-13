--[[═══════════════════════════════════════════════════════════════
      SPAINHUB BY DEEPSEK AND JEFF | EDICIÓN VIP v17.1
      · Key System propio (Permanente/Temporal) + Guardado.
      · Generador de Keys exclusivo para el Dueño (elpor763).
      · UI mejorada de Rayfield.
      · Aimbot Milimétrico y Auto Recarga Reparado.
   ═══════════════════════════════════════════════════════════════]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local VirtualInputManager = game:GetService("VirtualInputManager")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local OWNER_NAME = "elpor763"
local isOwner = (LocalPlayer.Name == OWNER_NAME)
local hubTitle = "SpainHub by deepsek and jeff"

if game.PlaceId ~= 5041144419 then
    LocalPlayer:Kick("Este hub es exclusivo de SCP Roleplay.")
    return
end

-- ═══════════════════════════════════════════════════════════════
-- SISTEMA DE KEYS (Base de datos local)
-- ═══════════════════════════════════════════════════════════════
local KEYS_FILE = "SpainHub_Keys.json"
local SAVED_KEY_FILE = "SpainHub_SavedKey.txt"

local function loadKeysDB()
    if isfile(KEYS_FILE) then
        local success, data = pcall(function() return HttpService:JSONDecode(readfile(KEYS_FILE)) end)
        if success and type(data) == "table" then return data end
    end
    -- Key por defecto para el Dueño
    local defaultData = { keys = { ["SPAIN-OWNER-2011"] = { expires = -1 } } }
    writefile(KEYS_FILE, HttpService:JSONEncode(defaultData))
    return defaultData
end

local function saveKeysDB(data)
    pcall(function() writefile(KEYS_FILE, HttpService:JSONEncode(data)) end)
end

local function isValidKey(inputKey)
    if inputKey == "SPAIN-OWNER-2011" then return true end -- Master key
    local db = loadKeysDB()
    local keyData = db.keys[inputKey]
    if keyData then
        if keyData.expires == -1 then return true end -- Permanente
        if os.time() < keyData.expires then return true end -- Temporal válida
    end
    return false
end

local function getSavedKey()
    if isfile(SAVED_KEY_FILE) then
        return readfile(SAVED_KEY_FILE)
    end
    return nil
end

-- ═══════════════════════════════════════════════════════════════
-- UI DE KEY PERSONALIZADA
-- ═══════════════════════════════════════════════════════════════
local function showKeyUI()
    local keyGui = Instance.new("ScreenGui")
    keyGui.Name = "SpainHubKeyUI"
    keyGui.Parent = game:GetService("CoreGui")
    keyGui.IgnoreGuiInset = true
    keyGui.ResetOnSpawn = false

    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 350, 0, 200)
    main.Position = UDim2.new(0.5, -175, 0.5, -100)
    main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    main.Parent = keyGui
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", main)
    stroke.Color = Color3.fromRGB(0, 170, 255)
    stroke.Thickness = 1.5

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundTransparency = 1
    title.Text = hubTitle
    title.TextColor3 = Color3.fromRGB(0, 170, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.Parent = main

    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1, -40, 0, 35)
    input.Position = UDim2.new(0, 20, 0, 50)
    input.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    input.TextColor3 = Color3.fromRGB(255, 255, 255)
    input.PlaceholderText = "Introduce tu Key aquí..."
    input.Font = Enum.Font.Gotham
    input.TextSize = 14
    input.Parent = main
    Instance.new("UICorner", input).CornerRadius = UDim.new(0, 6)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -40, 0, 35)
    btn.Position = UDim2.new(0, 20, 0, 100)
    btn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    btn.Text = "Verificar Key"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Parent = main
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -40, 0, 20)
    status.Position = UDim2.new(0, 20, 0, 140)
    status.BackgroundTransparency = 1
    status.Text = ""
    status.TextColor3 = Color3.fromRGB(255, 50, 50)
    status.Font = Enum.Font.Gotham
    status.TextSize = 12
    status.Parent = main

    btn.MouseButton1Click:Connect(function()
        if isValidKey(input.Text) then
            status.Text = "¡Key Correcta! Cargando Hub..."
            status.TextColor3 = Color3.fromRGB(50, 255, 50)
            pcall(function() writefile(SAVED_KEY_FILE, input.Text) end)
            task.wait(1)
            keyGui:Destroy()
            loadHub()
        else
            status.Text = "Key inválida o expirada."
        end
    end)

    -- BOTÓN SECRETO DEL DUEÑO
    if isOwner then
        local genBtn = Instance.new("TextButton")
        genBtn.Size = UDim2.new(0, 100, 0, 20)
        genBtn.Position = UDim2.new(1, -110, 1, -25)
        genBtn.BackgroundTransparency = 1
        genBtn.Text = "⚙️ Generador"
        genBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
        genBtn.Font = Enum.Font.Gotham
        genBtn.TextSize = 11
        genBtn.Parent = main

        genBtn.MouseButton1Click:Connect(function()
            keyGui:Destroy()
            showGeneratorUI()
        end)
    end
end

-- ═══════════════════════════════════════════════════════════════
-- GENERADOR DE KEYS (Solo Dueño)
-- ═══════════════════════════════════════════════════════════════
local function showGeneratorUI()
    local genGui = Instance.new("ScreenGui")
    genGui.Name = "SpainHubGenUI"
    genGui.Parent = game:GetService("CoreGui")
    genGui.IgnoreGuiInset = true

    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 400, 0, 350)
    main.Position = UDim2.new(0.5, -200, 0.5, -175)
    main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    main.Parent = genGui
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundTransparency = 1
    title.Text = "GENERADOR DE KEYS (OWNER)"
    title.TextColor3 = Color3.fromRGB(255, 200, 0)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.Parent = main

    -- Input para generar
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1, -40, 0, 35)
    input.Position = UDim2.new(0, 20, 0, 50)
    input.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    input.TextColor3 = Color3.fromRGB(255, 255, 255)
    input.PlaceholderText = "Nombre/Código de la nueva Key..."
    input.Font = Enum.Font.Gotham
    input.Parent = main

    -- Botones de generación
    local permBtn = Instance.new("TextButton")
    permBtn.Size = UDim2.new(0.5, -25, 0, 30)
    permBtn.Position = UDim2.new(0, 20, 0, 95)
    permBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    permBtn.Text = "Crear Permanente"
    permBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    permBtn.Font = Enum.Font.GothamBold
    permBtn.Parent = main

    local tempBtn = Instance.new("TextButton")
    tempBtn.Size = UDim2.new(0.5, -25, 0, 30)
    tempBtn.Position = UDim2.new(0.5, 5, 0, 95)
    tempBtn.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
    tempBtn.Text = "Crear Temporal (1 Día)"
    tempBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    tempBtn.Font = Enum.Font.GothamBold
    tempBtn.Parent = main

    -- Lista de keys
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -40, 0, 150)
    scroll.Position = UDim2.new(0, 20, 0, 140)
    scroll.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    scroll.BorderSizePixel = 0
    scroll.Parent = main
    Instance.new("UICorner", scroll).CornerRadius = UDim.new(0, 6)
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 5)
    layout.Parent = scroll

    local function refreshKeys()
        for _, c in ipairs(scroll:GetChildren()) do
            if c:IsA("Frame") then c:Destroy() end
        end
        local db = loadKeysDB()
        for key, data in pairs(db.keys) do
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, 0, 0, 30)
            row.BackgroundTransparency = 1
            row.Parent = scroll

            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(0.7, 0, 1, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = key .. (data.expires == -1 and " [PERM]" or " [TEMP]")
            lbl.TextColor3 = data.expires == -1 and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 140, 0)
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Font = Enum.Font.Gotham
            lbl.TextSize = 12
            lbl.Parent = row

            local del = Instance.new("TextButton")
            del.Size = UDim2.new(0.3, -5, 1, 0)
            del.Position = UDim2.new(0.7, 5, 0, 0)
            del.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            del.Text = "Borrar"
            del.TextColor3 = Color3.fromRGB(255, 255, 255)
            del.Font = Enum.Font.GothamBold
            del.TextSize = 11
            del.Parent = row

            del.MouseButton1Click:Connect(function()
                db.keys[key] = nil
                saveKeysDB(db)
                refreshKeys()
            end)
        end
    end

    permBtn.MouseButton1Click:Connect(function()
        if input.Text ~= "" then
            local db = loadKeysDB()
            db.keys[input.Text] = { expires = -1 }
            saveKeysDB(db)
            input.Text = ""
            refreshKeys()
        end
    end)

    tempBtn.MouseButton1Click:Connect(function()
        if input.Text ~= "" then
            local db = loadKeysDB()
            db.keys[input.Text] = { expires = os.time() + 86400 } -- 1 día
            saveKeysDB(db)
            input.Text = ""
            refreshKeys()
        end
    end)

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(1, -40, 0, 30)
    closeBtn.Position = UDim2.new(0, 20, 1, -40)
    closeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    closeBtn.Text = "Cerrar Generador"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = main

    closeBtn.MouseButton1Click:Connect(function()
        genGui:Destroy()
        showKeyUI()
    end)

    refreshKeys()
end

-- ═══════════════════════════════════════════════════════════════
-- CARGA DEL HUB PRINCIPAL
-- ═══════════════════════════════════════════════════════════════
function loadHub()
    local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
    local Window = Rayfield:CreateWindow({
        Name = hubTitle .. (isOwner and " [OWNER]" or ""),
        LoadingTitle = "Cargando " .. hubTitle .. "...",
        LoadingSubtitle = isOwner and "Bienvenido, Dueño" or "Ultimate Edition",
        ConfigurationSaving = { Enabled = false },
        KeySystem = false, -- Desactivado porque usamos el nuestro
    })

    local TabCombat = Window:CreateTab("Combate", 4483362458)
    local TabVisual = Window:CreateTab("Visual", 4483362458)
    local TabUtil = Window:CreateTab("Utilidades", 4483362458)
    local TabConfig = Window:CreateTab("Config", 4483362458)

    local CONFIG_FILE = "SpainHub_Config.json"

    local State = {
        Aimbot = false, AimbotRMB = false,
        LockMode = "mousemoverel", LockPart = "Head", HeadOffset = 0.0,       
        AimSmooth = 25, AimDeadzone = 0.1, AimPrediction = 0.12,
        AimPriority = "Cercano al crosshair",
        FOV = 600, FOVVisible = true, FOVColor = Color3.fromRGB(0, 255, 255),
        WallCheck = false, SmartTeamCheck = true, IgnoreTeam = true,
        ESP = false, ESPName = true, ESPDist = true, ESPHealth = true,
        ESPMaxDist = 2000, ESPColor = Color3.fromRGB(255, 255, 255), ESPUseTeamColor = true,
        AutoReload = false, Fullbright = false,
        AutoInteract = false, AutoRejoin = false, AntiAFK = false,
    }

    local UIRefs = {}
    local aimState = { target = nil, locked = false, coasting = false }
    local fovGui, fovRing, fovStroke
    local reloadCooldown = 0

    local function isAlive(plr)
        if not plr or not plr.Character then return false end
        local hum = plr.Character:FindFirstChildOfClass("Humanoid")
        return hum and hum.Health > 0 and hum:GetState() ~= Enum.HumanoidStateType.Dead
    end
    
    local function getTeamGroup(teamName)
        if not teamName then return "Neutral" end
        local name = string.lower(teamName)
        if name:find("class") or name:find("d%-") then return "ClassD" end
        if name:find("chaos") or name:find("insurgency") then return "Chaos" end
        if name:find("mtf") or name:find("task") or name:find("foundation") or name:find("security") or name:find("scientist") or name:find("research") then return "Foundation" end
        if name:find("scp") then return "SCP" end
        return "Neutral"
    end

    local function isAlly(plr)
        if plr == LocalPlayer then return true end
        if not State.SmartTeamCheck then return plr.Team == LocalPlayer.Team end
        local myGroup = getTeamGroup(LocalPlayer.Team and LocalPlayer.Team.Name or "")
        local theirGroup = getTeamGroup(plr.Team and plr.Team.Name or "")
        if myGroup == "ClassD" and theirGroup == "Chaos" then return true end
        if myGroup == "Chaos" and theirGroup == "ClassD" then return true end
        if myGroup == theirGroup and myGroup ~= "Neutral" then return true end
        return false
    end

    local function hasLineOfSight(targetChar)
        local cam = workspace.CurrentCamera
        local origin = cam.CFrame.Position
        local targetPos = targetChar:FindFirstChild("Head") and targetChar.Head.Position or targetChar:GetPivot().Position
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = { LocalPlayer.Character, targetChar }
        params.RespectCanCollide = true
        local result = workspace:Raycast(origin, targetPos - origin, params)
        return result == nil
    end

    local function getPredictedPos(plr, part)
        local basePos = part.Position + Vector3.new(0, State.HeadOffset, 0)
        if State.AimPrediction <= 0 then return basePos end
        local root = plr.Character:FindFirstChild("HumanoidRootPart")
        if root then 
            local vel = root.AssemblyLinearVelocity
            vel = Vector3.new(vel.X, 0, vel.Z)
            return basePos + (vel * State.AimPrediction) 
        end
        return basePos
    end

    local function findTarget(cam)
        local fovCenter = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
        local camPos = cam.CFrame.Position
        local best, bestScore = nil, math.huge
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and isAlive(plr) then
                if not (State.IgnoreTeam and isAlly(plr)) then
                    local part = plr.Character:FindFirstChild(State.LockPart)
                    if part then
                        local wd = (part.Position - camPos).Magnitude
                        if wd <= 5000 then
                            local pos = cam:WorldToViewportPoint(part.Position)
                            if pos.Z > 0 then
                                local sd = (Vector2.new(pos.X, pos.Y) - fovCenter).Magnitude
                                if sd <= State.FOV and (not State.WallCheck or hasLineOfSight(plr.Character)) then
                                    local score = sd
                                    if State.AimPriority == "Menor HP" then score = plr.Character.Humanoid.Health
                                    elseif State.AimPriority == "Más cercano en studs" then score = wd end
                                    if aimState.target == plr then score = score * 0.7 end
                                    if score < bestScore then
                                        best = { plr = plr, part = part, score = score }
                                        bestScore = score
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        return best
    end

    local function aimStep(dt)
        if not State.Aimbot or not isAlive(LocalPlayer) then return end
        if State.AimbotRMB and not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return end
        local cam = workspace.CurrentCamera
        local target = findTarget(cam)
        if not target then aimState.locked = false; return end
        if aimState.target ~= target.plr then
            aimState.target = target.plr
            aimState.coasting = false
        end
        aimState.locked = true
        local aimPos = getPredictedPos(target.plr, target.part)
        local camPos = cam.CFrame.Position
        local delta = aimPos - camPos
        if delta.Magnitude < 0.3 then return end
        local dot = math.clamp(cam.CFrame.LookVector:Dot(delta.Unit), -1, 1)
        local angleDeg = math.deg(math.acos(dot))
        if aimState.coasting then
            if angleDeg > State.AimDeadzone * 4 then aimState.coasting = false end
        else
            if angleDeg < State.AimDeadzone then aimState.coasting = true end
        end
        if aimState.coasting then return end
        if State.LockMode == "mousemoverel" then
            local screenPos = cam:WorldToViewportPoint(aimPos)
            if screenPos.Z > 0 then
                local mouse = UserInputService:GetMouseLocation()
                local distX = screenPos.X - mouse.X
                local distY = screenPos.Y - mouse.Y
                local baseAlpha = math.clamp(0.9 - (State.AimSmooth / 100) * 0.8, 0.1, 0.9)
                local moveX, moveY = distX * baseAlpha, distY * baseAlpha
                if math.abs(distX) < 10 then moveX = distX end
                if math.abs(distY) < 10 then moveY = distY end
                pcall(function() mousemoverel(moveX, moveY) end)
            end
        else
            local baseAlpha = math.clamp(0.9 - (State.AimSmooth / 100) * 0.8, 0.1, 0.9)
            pcall(function() cam.CFrame = cam.CFrame:Lerp(CFrame.new(camPos, aimPos), baseAlpha) end)
        end
    end

    local function setAimbotBinding()
        pcall(function() RunService:UnbindFromRenderStep("SpainHubAimbot") end)
        aimState.locked = false; aimState.target = nil
        if State.Aimbot then
            local ok = pcall(function() RunService:BindToRenderStep("SpainHubAimbot", Enum.RenderPriority.Last.Value - 1, aimStep) end)
            if not ok then RunService.RenderStepped:Connect(aimStep) end
        end
    end

    -- ESP
    local ESP = {}
    local DrawingSupported = pcall(function() local t = Drawing.new("Square"); t:Remove() end)
    local function createESP(plr)
        if not DrawingSupported then return end
        local box = Drawing.new("Square"); box.Thickness = 1; box.Filled = false; box.Visible = false
        local name = Drawing.new("Text"); name.Size = 14; name.Center = true; name.Outline = true; name.Visible = false
        local dist = Drawing.new("Text"); dist.Size = 12; dist.Center = true; dist.Outline = true; dist.Visible = false
        local healthBg = Drawing.new("Square"); healthBg.Thickness = 0; healthBg.Filled = true; healthBg.Color = Color3.fromRGB(0,0,0); healthBg.Visible = false
        local health = Drawing.new("Square"); health.Thickness = 0; health.Filled = true; health.Visible = false
        ESP[plr] = { Box = box, Name = name, Dist = dist, HealthBg = healthBg, Health = health }
    end
    local function removeESP(plr)
        if ESP[plr] then for _, obj in pairs(ESP[plr]) do obj:Remove() end; ESP[plr] = nil end
    end
    RunService.RenderStepped:Connect(function()
        if not State.ESP or not DrawingSupported then
            if not State.ESP then for plr, _ in pairs(ESP) do removeESP(plr) end end
            return
        end
        local cam = workspace.CurrentCamera
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and isAlive(plr) then
                if not ESP[plr] then createESP(plr) end
                local esp = ESP[plr]
                local char = plr.Character
                local hrp, head, hum = char:FindFirstChild("HumanoidRootPart"), char:FindFirstChild("Head"), char:FindFirstChildOfClass("Humanoid")
                if hrp and head and hum then
                    local distNum = (cam.CFrame.Position - hrp.Position).Magnitude
                    if distNum <= State.ESPMaxDist then
                        local topPos = cam:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                        local botPos = cam:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                        if topPos.Z > 0 then
                            local height = math.abs(topPos.Y - botPos.Y)
                            local width = height / 2
                            local color = State.ESPUseTeamColor and (plr.Team and plr.Team.TeamColor.Color or Color3.new(1,1,1)) or State.ESPColor
                            esp.Box.Size = Vector2.new(width, height); esp.Box.Position = Vector2.new(topPos.X - width/2, topPos.Y); esp.Box.Color = color; esp.Box.Visible = true
                            esp.Name.Text = plr.Name; esp.Name.Position = Vector2.new(topPos.X, topPos.Y - 16); esp.Name.Color = color; esp.Name.Visible = State.ESPName
                            esp.Dist.Text = math.floor(distNum) .. "m"; esp.Dist.Position = Vector2.new(topPos.X, botPos.Y + 2); esp.Dist.Visible = State.ESPDist
                            local hpPct = hum.Health / hum.MaxHealth
                            esp.HealthBg.Size = Vector2.new(2, height); esp.HealthBg.Position = Vector2.new(topPos.X - width/2 - 4, topPos.Y); esp.HealthBg.Visible = State.ESPHealth
                            esp.Health.Size = Vector2.new(2, height * hpPct); esp.Health.Position = Vector2.new(topPos.X - width/2 - 4, topPos.Y + (height - height*hpPct))
                            esp.Health.Color = Color3.fromRGB(255*(1-hpPct), 255*hpPct, 0); esp.Health.Visible = State.ESPHealth
                        else for _, obj in pairs(esp) do obj.Visible = false end end
                    else for _, obj in pairs(esp) do obj.Visible = false end end
                end
            elseif ESP[plr] then removeESP(plr) end
        end
    end)
    Players.PlayerRemoving:Connect(function(plr) removeESP(plr) end)

    -- FOV
    pcall(function()
        local parentGui = (typeof(gethui) == "function" and gethui()) or game:GetService("CoreGui")
        fovGui = Instance.new("ScreenGui"); fovGui.Name = "SpainHubFOV"; fovGui.Parent = parentGui; fovGui.IgnoreGuiInset = true
        fovRing = Instance.new("Frame"); fovRing.AnchorPoint = Vector2.new(0.5, 0.5); fovRing.BackgroundTransparency = 1; fovRing.Parent = fovGui
        Instance.new("UICorner", fovRing).CornerRadius = UDim.new(1, 0)
        fovStroke = Instance.new("UIStroke", fovRing); fovStroke.Thickness = 1.5
    end)
    RunService.RenderStepped:Connect(function()
        if not fovGui then return end
        if not State.Aimbot or not State.FOVVisible then fovGui.Enabled = false; return end
        fovGui.Enabled = true
        local cam = workspace.CurrentCamera
        local center = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
        fovRing.Position = UDim2.fromOffset(center.X, center.Y)
        fovRing.Size = UDim2.fromOffset(State.FOV * 2, State.FOV * 2)
        fovStroke.Color = aimState.coasting and Color3.fromRGB(100, 255, 100) or (aimState.locked and Color3.fromRGB(255, 150, 150) or State.FOVColor)
    end)

    -- AutoReload & Utilidades
    local function getAmmoValue(tool)
        if not tool then return nil end
        local attrNames = {"Ammo", "AmmoCount", "CurrentAmmo", "Clip", "Mag", "Magazine", "Bullets", "Rounds", "StoredAmmo", "Reserve"}
        for _, attr in ipairs(attrNames) do local val = tool:GetAttribute(attr); if type(val) == "number" then return val end end
        for _, child in ipairs(tool:GetDescendants()) do
            if child:IsA("IntValue") or child:IsA("NumberValue") or child:IsA("StringValue") then
                local name = string.lower(child.Name)
                for _, attr in ipairs(attrNames) do 
                    if name:find(string.lower(attr)) then 
                        local num = tonumber(child.Value)
                        if num then return num end
                    end 
                end
            end
        end
        return nil
    end

    task.spawn(function()
        while task.wait(0.1) do
            if State.AutoReload and isAlive(LocalPlayer) then
                local char = LocalPlayer.Character
                local tool = char and char:FindFirstChildOfClass("Tool")
                if tool and not tool.Name:lower():find("shield") then
                    local ammo = getAmmoValue(tool)
                    if ammo == 0 and os.clock() > reloadCooldown then
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.R, false, game)
                        task.wait(0.05)
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.R, false, game)
                        reloadCooldown = os.clock() + 2.5
                    end
                end
            end
        end
    end)

    local function processPrompts()
        if not State.AutoInteract then return end
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                if obj:GetAttribute("OrigHold") == nil then obj:SetAttribute("OrigHold", obj.HoldDuration) end
                obj.HoldDuration = 0
            end
        end
    end
    workspace.DescendantAdded:Connect(function(obj)
        if obj:IsA("ProximityPrompt") and State.AutoInteract then
            task.wait(0.1)
            if obj:GetAttribute("OrigHold") == nil then obj:SetAttribute("OrigHold", obj.HoldDuration) end
            obj.HoldDuration = 0
        end
    end)
    LocalPlayer.Idled:Connect(function()
        if State.AntiAFK then VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new()) end
    end)
    LocalPlayer.AncestryChanged:Connect(function()
        if not game:IsLoaded() then return end
        if LocalPlayer.Parent == nil and State.AutoRejoin then
            task.wait(2)
            pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer) end)
        end
    end)

    -- CONFIG
    local function saveConfig()
        local data = {}
        for k, v in pairs(State) do
            if typeof(v) == "Color3" then data[k] = {r = v.R, g = v.G, b = v.B}
            else data[k] = v end
        end
        pcall(function() writefile(CONFIG_FILE, HttpService:JSONEncode(data)) end)
    end
    local function loadConfig()
        if not isfile(CONFIG_FILE) then return false end
        local success, data = pcall(function() return HttpService:JSONDecode(readfile(CONFIG_FILE)) end)
        if not success or type(data) ~= "table" then return false end
        for k, v in pairs(data) do
            if typeof(State[k]) == "Color3" and type(v) == "table" then State[k] = Color3.new(v.r, v.g, v.b)
            elseif State[k] ~= nil then State[k] = v end
        end
        
        if UIRefs.Aimbot then UIRefs.Aimbot:Set(State.Aimbot) end
        if UIRefs.AimbotRMB then UIRefs.AimbotRMB:Set(State.AimbotRMB) end
        if UIRefs.WallCheck then UIRefs.WallCheck:Set(State.WallCheck) end
        if UIRefs.SmartTeamCheck then UIRefs.SmartTeamCheck:Set(State.SmartTeamCheck) end
        if UIRefs.IgnoreTeam then UIRefs.IgnoreTeam:Set(State.IgnoreTeam) end
        if UIRefs.AimPriority then UIRefs.AimPriority:Set(State.AimPriority) end
        if UIRefs.LockMode then UIRefs.LockMode:Set(State.LockMode == "mousemoverel" and "mousemoverel (Seguro)" or "CFrame (Riesgoso)") end
        if UIRefs.AimPrediction then UIRefs.AimPrediction:Set(State.AimPrediction) end
        if UIRefs.AimSmooth then UIRefs.AimSmooth:Set(State.AimSmooth) end
        if UIRefs.AimDeadzone then UIRefs.AimDeadzone:Set(State.AimDeadzone) end
        if UIRefs.FOV then UIRefs.FOV:Set(State.FOV) end
        if UIRefs.FOVVisible then UIRefs.FOVVisible:Set(State.FOVVisible) end
        if UIRefs.FOVColor then UIRefs.FOVColor:Set(State.FOVColor) end
        if UIRefs.ESP then UIRefs.ESP:Set(State.ESP) end
        if UIRefs.ESPName then UIRefs.ESPName:Set(State.ESPName) end
        if UIRefs.ESPDist then UIRefs.ESPDist:Set(State.ESPDist) end
        if UIRefs.ESPHealth then UIRefs.ESPHealth:Set(State.ESPHealth) end
        if UIRefs.ESPUseTeamColor then UIRefs.ESPUseTeamColor:Set(State.ESPUseTeamColor) end
        if UIRefs.ESPMaxDist then UIRefs.ESPMaxDist:Set(State.ESPMaxDist) end
        if UIRefs.ESPColor then UIRefs.ESPColor:Set(State.ESPColor) end
        if UIRefs.AutoReload then UIRefs.AutoReload:Set(State.AutoReload) end
        if UIRefs.Fullbright then UIRefs.Fullbright:Set(State.Fullbright) end
        if UIRefs.AutoInteract then UIRefs.AutoInteract:Set(State.AutoInteract) end
        if UIRefs.AutoRejoin then UIRefs.AutoRejoin:Set(State.AutoRejoin) end
        if UIRefs.AntiAFK then UIRefs.AntiAFK:Set(State.AntiAFK) end
        
        setAimbotBinding()
        processPrompts()
        Lighting.Ambient = State.Fullbright and Color3.fromRGB(200,200,200) or Color3.fromRGB(0,0,0)
        Lighting.Brightness = State.Fullbright and 3 or 2
        Lighting.FogEnd = State.Fullbright and 100000 or 1000
        return true
    end

    -- UI
    UIRefs.Aimbot = TabCombat:CreateToggle({ Name = "Aimbot (Anti-Kick)", CurrentValue = State.Aimbot, Callback = function(v) State.Aimbot = v; setAimbotBinding() end })
    UIRefs.AimbotRMB = TabCombat:CreateToggle({ Name = "Solo con clic derecho", CurrentValue = State.AimbotRMB, Callback = function(v) State.AimbotRMB = v end })
    UIRefs.WallCheck = TabCombat:CreateToggle({ Name = "Wall Check", CurrentValue = State.WallCheck, Callback = function(v) State.WallCheck = v end })
    UIRefs.SmartTeamCheck = TabCombat:CreateToggle({ Name = "Team Check SCP (Class-D + Caos)", CurrentValue = State.SmartTeamCheck, Callback = function(v) State.SmartTeamCheck = v end })
    UIRefs.IgnoreTeam = TabCombat:CreateToggle({ Name = "Ignorar aliados", CurrentValue = State.IgnoreTeam, Callback = function(v) State.IgnoreTeam = v end })

    UIRefs.LockPart = TabCombat:CreateDropdown({ Name = "Parte del cuerpo a apuntar", Options = {"Head", "UpperTorso", "Torso"}, CurrentOption = {State.LockPart}, Callback = function(opt) State.LockPart = opt[1] end })
    UIRefs.AimPriority = TabCombat:CreateDropdown({ Name = "Prioridad de Objetivo", Options = {"Cercano al crosshair", "Menor HP", "Más cercano en studs"}, CurrentOption = {State.AimPriority}, Callback = function(opt) State.AimPriority = opt[1] end })
    UIRefs.LockMode = TabCombat:CreateDropdown({ Name = "Modo de apuntado", Options = {"mousemoverel (Seguro)", "CFrame (Riesgoso)"}, CurrentOption = {State.LockMode == "mousemoverel" and "mousemoverel (Seguro)" or "CFrame (Riesgoso)"}, Callback = function(opt) State.LockMode = (opt[1] == "mousemoverel (Seguro)") and "mousemoverel" or "CFrame" end })

    UIRefs.AimPrediction = TabCombat:CreateSlider({ Name = "Predicción de movimiento", Range = {0, 0.3}, Increment = 0.01, Suffix = "s", CurrentValue = State.AimPrediction, Callback = function(v) State.AimPrediction = v end })
    UIRefs.AimSmooth = TabCombat:CreateSlider({ Name = "Suavidad", Range = {0, 100}, Increment = 5, CurrentValue = State.AimSmooth, Callback = function(v) State.AimSmooth = v end })
    UIRefs.AimDeadzone = TabCombat:CreateSlider({ Name = "Tolerancia (° antes de corregir)", Range = {0.1, 5}, Increment = 0.1, Suffix = "°", CurrentValue = State.AimDeadzone, Callback = function(v) State.AimDeadzone = v end })
    UIRefs.FOV = TabCombat:CreateSlider({ Name = "FOV (radio px)", Range = {10, 800}, Increment = 10, CurrentValue = State.FOV, Callback = function(v) State.FOV = v end })

    UIRefs.HeadOffset = TabCombat:CreateSlider({ Name = "Offset Vertical (Sube la mira)", Range = {-1.0, 1.5}, Increment = 0.1, Suffix = "", CurrentValue = State.HeadOffset, Callback = function(v) State.HeadOffset = v end })

    UIRefs.FOVVisible = TabCombat:CreateToggle({ Name = "Mostrar FOV", CurrentValue = State.FOVVisible, Callback = function(v) State.FOVVisible = v end })
    UIRefs.FOVColor = TabCombat:CreateColorPicker({ Name = "Color del FOV", Color = State.FOVColor, Callback = function(color) State.FOVColor = color end })

    UIRefs.ESP = TabVisual:CreateToggle({ Name = "ESP (Drawing API)", CurrentValue = State.ESP, Callback = function(v) State.ESP = v end })
    UIRefs.ESPName = TabVisual:CreateToggle({ Name = "ESP: Nombre", CurrentValue = State.ESPName, Callback = function(v) State.ESPName = v end })
    UIRefs.ESPDist = TabVisual:CreateToggle({ Name = "ESP: Distancia", CurrentValue = State.ESPDist, Callback = function(v) State.ESPDist = v end })
    UIRefs.ESPHealth = TabVisual:CreateToggle({ Name = "ESP: Barra de Vida", CurrentValue = State.ESPHealth, Callback = function(v) State.ESPHealth = v end })
    UIRefs.ESPUseTeamColor = TabVisual:CreateToggle({ Name = "ESP: Color por Equipo", CurrentValue = State.ESPUseTeamColor, Callback = function(v) State.ESPUseTeamColor = v end })
    UIRefs.ESPMaxDist = TabVisual:CreateSlider({ Name = "ESP: Distancia Máx", Range = {100, 5000}, Increment = 100, CurrentValue = State.ESPMaxDist, Callback = function(v) State.ESPMaxDist = v end })
    UIRefs.ESPColor = TabVisual:CreateColorPicker({ Name = "ESP: Color custom", Color = State.ESPColor, Callback = function(color) State.ESPColor = color end })

    UIRefs.Fullbright = TabVisual:CreateToggle({ Name = "Fullbright", CurrentValue = State.Fullbright, Callback = function(v)
        State.Fullbright = v
        if v then Lighting.Ambient = Color3.fromRGB(200,200,200); Lighting.Brightness = 3; Lighting.FogEnd = 100000
        else Lighting.Ambient = Color3.fromRGB(0,0,0); Lighting.Brightness = 2; Lighting.FogEnd = 1000 end
    end })

    UIRefs.AutoReload = TabUtil:CreateToggle({ Name = "Auto Recarga Extremo", CurrentValue = State.AutoReload, Callback = function(v) State.AutoReload = v end })
    UIRefs.AutoInteract = TabUtil:CreateToggle({ Name = "Auto Interact (E instantánea)", CurrentValue = State.AutoInteract, Callback = function(v) State.AutoInteract = v; processPrompts() end })
    UIRefs.AntiAFK = TabUtil:CreateToggle({ Name = "Anti-AFK (Evita expulsión)", CurrentValue = State.AntiAFK, Callback = function(v) State.AntiAFK = v end })
    UIRefs.AutoRejoin = TabUtil:CreateToggle({ Name = "Auto Rejoin (Reconectar al ser kickeado)", CurrentValue = State.AutoRejoin, Callback = function(v) State.AutoRejoin = v end })
    TabUtil:CreateButton({ Name = "Reconectar Ahora (Manual)", Callback = function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end })
    TabUtil:CreateToggle({ Name = "Desbloquear FPS (240)", Callback = function(v) pcall(function() if setfpscap then setfpscap(v and 240 or 60) end end) end })

    TabConfig:CreateButton({ Name = "Guardar Configuración", Callback = function() saveConfig(); Rayfield:Notify({ Title = "Configuración", Content = "Ajustes guardados.", Duration = 3 }) end })
    TabConfig:CreateButton({ Name = "Cargar Configuración", Callback = function() if loadConfig() then Rayfield:Notify({ Title = "Configuración", Content = "Ajustes cargados.", Duration = 3 }) end end })
    TabConfig:CreateButton({ Name = "Borrar Configuración", Callback = function() pcall(function() if delfile then delfile(CONFIG_FILE) end end); Rayfield:Notify({ Title = "Configuración", Content = "Archivo borrado.", Duration = 3 }) end })

    if isOwner then
        task.delay(1, function()
            Rayfield:Notify({ Title = "¡BIENVENIDO DUEÑO!", Content = "El generador de keys está activo en la pantalla de inicio.", Duration = 5 })
        end)
    end
end

-- ═══════════════════════════════════════════════════════════════
-- INICIO DEL SCRIPT
-- ═══════════════════════════════════════════════════════════════
local savedKey = getSavedKey()
if savedKey and isValidKey(savedKey) then
    loadHub()
else
    showKeyUI()
end