local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

local Window = OrionLib:MakeWindow({Name = "TheyTraXx Script", HidePremium = false, SaveConfig = true, ConfigFolder = "Test"})

local Tab = Window:MakeTab({
    Name = "Visuals",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local Section = Tab:AddSection({
    Name = "ESP"
})

-- =============================
-- Variables de Skeleton ESP
-- =============================
local SkeletonEnabled = false
local SkeletonConnections = {}
local skeletons = {}

local function clearAllSkeletons()
    for _, playerSkeleton in pairs(skeletons) do
        for _, line in pairs(playerSkeleton) do
            line:Remove()
        end
    end
    skeletons = {}
end

local function toggleSkeleton(state)
    if state then
        local Players = game:GetService("Players")
        local RunService = game:GetService("RunService")
        local Camera = workspace.CurrentCamera

        local LocalPlayer = Players.LocalPlayer

        local bodyConnections = {
            R15 = {
                {"Head", "UpperTorso"},
                {"UpperTorso", "LowerTorso"},
                {"LowerTorso", "LeftUpperLeg"},
                {"LowerTorso", "RightUpperLeg"},
                {"LeftUpperLeg", "LeftLowerLeg"},
                {"LeftLowerLeg", "LeftFoot"},
                {"RightUpperLeg", "RightLowerLeg"},
                {"RightLowerLeg", "RightFoot"},
                {"UpperTorso", "LeftUpperArm"},
                {"UpperTorso", "RightUpperArm"},
                {"LeftUpperArm", "LeftLowerArm"},
                {"LeftLowerArm", "LeftHand"},
                {"RightUpperArm", "RightLowerArm"},
                {"RightLowerArm", "RightHand"}
            },
            R6 = {
                {"Head", "Torso"},
                {"Torso", "Left Arm"},
                {"Torso", "Right Arm"},
                {"Torso", "Left Leg"},
                {"Torso", "Right Leg"}
            }
        }

        local function createLine()
            local line = Drawing.new("Line")
            line.Color = Color3.fromRGB(255, 255, 255)
            line.Thickness = 1
            line.Transparency = 1
            return line
        end

        local function updateSkeleton(player)
            if player == LocalPlayer then return end

            local character = player.Character
            if not character then return end

            local humanoid = character:FindFirstChild("Humanoid")
            if not humanoid then return end

            local rigType = humanoid.RigType.Name
            local connections = bodyConnections[rigType]
            if not connections then return end

            if not skeletons[player] then
                skeletons[player] = {}
            end

            for _, connection in pairs(connections) do
                local partA = character:FindFirstChild(connection[1])
                local partB = character:FindFirstChild(connection[2])
                if partA and partB then
                    local line = skeletons[player][connection[1] .. "-" .. connection[2]] or createLine()
                    local posA, onScreenA = Camera:WorldToViewportPoint(partA.Position)
                    local posB, onScreenB = Camera:WorldToViewportPoint(partB.Position)

                    if onScreenA and onScreenB then
                        line.From = Vector2.new(posA.X, posA.Y)
                        line.To = Vector2.new(posB.X, posB.Y)
                        line.Visible = true
                    else
                        line.Visible = false
                    end

                    skeletons[player][connection[1] .. "-" .. connection[2]] = line
                end
            end
        end

        local function removeSkeleton(player)
            if skeletons[player] then
                for _, line in pairs(skeletons[player]) do
                    line:Remove()
                end
                skeletons[player] = nil
            end
        end

        SkeletonConnections[#SkeletonConnections + 1] = RunService.RenderStepped:Connect(function()
            for _, player in pairs(Players:GetPlayers()) do
                updateSkeleton(player)
            end
        end)

        SkeletonConnections[#SkeletonConnections + 1] = Players.PlayerRemoving:Connect(function(player)
            removeSkeleton(player)
        end)
    else
        for _, connection in pairs(SkeletonConnections) do
            connection:Disconnect()
        end
        SkeletonConnections = {}
        clearAllSkeletons()
    end
end

Tab:AddButton({
    Name = "Skeleton",
    Callback = function()
        SkeletonEnabled = not SkeletonEnabled
        toggleSkeleton(SkeletonEnabled)
        OrionLib:MakeNotification({
            Name = "Skeleton",
            Content = SkeletonEnabled and "Skeleton ESP Activado" or "Skeleton ESP Desactivado",
            Image = "rbxassetid://4483345998",
            Time = 5
        })
    end
})

-- =============================
-- Variables del Health Bar
-- =============================
local HealthBarEnabled = false
local Players = game:GetService("Players")

-- =============================
-- Funciones del Health Bar
-- =============================

local function createHealthBar(character)
    if character:FindFirstChild("Humanoid") and character:FindFirstChild("Head") then
        local humanoid = character:FindFirstChild("Humanoid")
        local head = character:FindFirstChild("Head")

        if head:FindFirstChild("HealthBar") then
            return
        end

        local billboard = Instance.new("BillboardGui")
        billboard.Name = "HealthBar"
        billboard.Adornee = head
        billboard.Size = UDim2.new(4, 0, 0.5, 0)
        billboard.StudsOffset = Vector3.new(0, 2, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = head

        local backgroundBar = Instance.new("Frame")
        backgroundBar.Name = "Background"
        backgroundBar.Size = UDim2.new(1, 0, 0.2, 0)
        backgroundBar.Position = UDim2.new(0, 0, 0.8, 0)
        backgroundBar.BackgroundColor3 = Color3.new(0, 0, 0)
        backgroundBar.BorderSizePixel = 0
        backgroundBar.Parent = billboard

        local healthBar = Instance.new("Frame")
        healthBar.Name = "Health"
        healthBar.Size = UDim2.new(1, 0, 1, 0)
        healthBar.BackgroundColor3 = Color3.new(0, 1, 0)
        healthBar.BorderSizePixel = 0
        healthBar.Parent = backgroundBar

        humanoid.HealthChanged:Connect(function(health)
            local healthPercent = health / humanoid.MaxHealth
            healthBar.Size = UDim2.new(healthPercent, 0, 1, 0)

            if healthPercent > 0.5 then
                healthBar.BackgroundColor3 = Color3.new(0, 1, 0)
            elseif healthPercent > 0.25 then
                healthBar.BackgroundColor3 = Color3.new(1, 1, 0)
            else
                healthBar.BackgroundColor3 = Color3.new(1, 0, 0)
            end
        end)

        humanoid.Died:Connect(function()
            if billboard then
                billboard:Destroy()
            end
        end)
    end
end

local function toggleHealthBar(state)
    if state then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= Players.LocalPlayer and player.Character then
                createHealthBar(player.Character)
            end
        end

        Players.PlayerAdded:Connect(function(player)
            player.CharacterAdded:Connect(function(character)
                wait(1)
                createHealthBar(character)
            end)
        end)
    else
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("Head") then
                local head = player.Character:FindFirstChild("Head")
                if head:FindFirstChild("HealthBar") then
                    head.HealthBar:Destroy()
                end
            end
        end
    end
end

Tab:AddButton({
    Name = "Health Bars",
    Callback = function()
        HealthBarEnabled = not HealthBarEnabled
        toggleHealthBar(HealthBarEnabled)
        OrionLib:MakeNotification({
            Name = "Health Bars",
            Content = HealthBarEnabled and "Health Bars Activadas" or "Health Bars Desactivadas",
            Image = "rbxassetid://4483345998",
            Time = 5
        })
    end
})




-- BOX 3D

local BoxEnabled = false -- Estado del botón (activado/desactivado)
local BoxConnections = {} -- Conexiones activas de RunService para Box ESP
local espBoxes = {} -- Tabla que almacena las cajas de ESP

local function clearAllBoxes()
    -- Eliminar todas las cajas visuales
    for _, box in pairs(espBoxes) do
        box:Remove()
    end
    espBoxes = {} -- Limpiar la tabla de cajas
end

local function toggleBoxESP(state)
    if state then
        local Players = game:GetService("Players")
        local RunService = game:GetService("RunService")
        local Camera = workspace.CurrentCamera
        local LocalPlayer = Players.LocalPlayer

        local function createBox()
            local box = Drawing.new("Square")
            box.Thickness = 1
            box.Transparency = 1
            box.Color = Color3.fromRGB(255, 255, 255)
            box.Filled = false
            box.Visible = false
            return box
        end

        local function updateBox(player)
            if player == LocalPlayer then return end

            local character = player.Character
            if not character then return end

            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            if not humanoidRootPart then return end

            local box = espBoxes[player] or createBox()
            espBoxes[player] = box

            local rootPos, onScreen = Camera:WorldToViewportPoint(humanoidRootPart.Position)
            if onScreen then
                local distance = (Camera.CFrame.Position - humanoidRootPart.Position).Magnitude
                local boxSize = Vector2.new(2000 / distance, 3000 / distance)
                local boxPosition = Vector2.new(rootPos.X - boxSize.X / 2, rootPos.Y - boxSize.Y / 2)

                box.Size = boxSize
                box.Position = boxPosition
                box.Visible = true
            else
                box.Visible = false
            end
        end

        local function removeBox(player)
            if espBoxes[player] then
                espBoxes[player]:Remove()
                espBoxes[player] = nil
            end
        end

        BoxConnections[#BoxConnections + 1] = RunService.RenderStepped:Connect(function()
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    updateBox(player)
                end
            end
        end)

        BoxConnections[#BoxConnections + 1] = Players.PlayerRemoving:Connect(function(player)
            removeBox(player)
        end)
    else
        -- Desactivar: Limpiar conexiones activas y borrar cajas
        for _, connection in pairs(BoxConnections) do
            connection:Disconnect()
        end
        BoxConnections = {}
        clearAllBoxes() -- Borrar todas las cajas de ESP
    end
end

-- Botón para activar/desactivar Box ESP
Tab:AddButton({
    Name = "Box ESP",
    Callback = function()
        BoxEnabled = not BoxEnabled -- Alterna el estado
        toggleBoxESP(BoxEnabled)
        OrionLib:MakeNotification({
            Name = "Box ESP",
            Content = BoxEnabled and "Box ESP Activado" or "Box ESP Desactivado",
            Image = "rbxassetid://4483345998",
            Time = 5
        })
    end
})




-- TRACERS 

local TracerEnabled = false -- Estado del botón (activado/desactivado)
local TracerConnections = {} -- Conexiones activas de RunService para Tracer ESP
local tracers = {} -- Tabla que almacena los trazadores
local TracerThickness = 1 -- Grosor inicial de las líneas de los trazadores

local function clearAllTracers()
    -- Eliminar todas las líneas visuales
    for _, tracer in pairs(tracers) do
        tracer:Remove()
    end
    tracers = {} -- Limpiar la tabla de trazadores
end

local function toggleTracerESP(state)
    if state then
        local Players = game:GetService("Players")
        local RunService = game:GetService("RunService")
        local Camera = workspace.CurrentCamera
        local LocalPlayer = Players.LocalPlayer

        local function createTracer()
            local tracer = Drawing.new("Line")
            tracer.Thickness = TracerThickness -- Usar el grosor actual
            tracer.Transparency = 1
            tracer.Color = Color3.fromRGB(255, 255, 255)
            tracer.Visible = false
            return tracer
        end

        local function updateTracer(player)
            if player == LocalPlayer then return end

            local character = player.Character
            if not character then return end

            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            if not humanoidRootPart then return end

            local tracer = tracers[player] or createTracer()
            tracers[player] = tracer

            -- Actualizar el grosor de las líneas al tamaño configurado
            tracer.Thickness = TracerThickness

            local rootPos, onScreen = Camera:WorldToViewportPoint(humanoidRootPart.Position)
            if onScreen then
                tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y) -- Centro inferior de la pantalla
                tracer.To = Vector2.new(rootPos.X, rootPos.Y)
                tracer.Visible = true
            else
                tracer.Visible = false
            end
        end

        local function removeTracer(player)
            if tracers[player] then
                tracers[player]:Remove()
                tracers[player] = nil
            end
        end

        TracerConnections[#TracerConnections + 1] = RunService.RenderStepped:Connect(function()
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    updateTracer(player)
                end
            end
        end)

        TracerConnections[#TracerConnections + 1] = Players.PlayerRemoving:Connect(function(player)
            removeTracer(player)
        end)
    else
        -- Desactivar: Limpiar conexiones activas y borrar trazadores
        for _, connection in pairs(TracerConnections) do
            connection:Disconnect()
        end
        TracerConnections = {}
        clearAllTracers() -- Borrar todas las líneas de trazadores
    end
end

Tab:AddButton({
    Name = "Tracer ESP",
    Callback = function()
        TracerEnabled = not TracerEnabled -- Alternar el estado
        toggleTracerESP(TracerEnabled)
        OrionLib:MakeNotification({
            Name = "Tracer ESP",
            Content = TracerEnabled and "Tracer ESP Activado" or "Tracer ESP Desactivado",
            Image = "rbxassetid://4483345998",
            Time = 5
        })
    end
})

Tab:AddSlider({
    Name = "Tracer Thickness",
    Min = 1,
    Max = 10,
    Default = 1,
    Increment = 1,
    ValueName = "Thickness",
    Callback = function(value)
        TracerThickness = value -- Actualizar el grosor según el valor del slider
    end
})



-- Head Hitbox

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local hitboxCircles = {}
local CirclesEnabled = false -- Estado del botón
local circleBaseRadius = 50 -- Radio base del círculo
local connections = {}

local function createCircle()
    local circle = Drawing.new("Circle")
    circle.Thickness = 2
    circle.Transparency = 1
    circle.Color = Color3.fromRGB(255, 255, 255) -- Blanco
    circle.Filled = false
    circle.Visible = false
    return circle
end

local function updateCircle(player)
    if player == LocalPlayer then return end

    local character = player.Character
    if not character then return end

    local head = character:FindFirstChild("Head")
    if not head then return end

    local circle = hitboxCircles[player] or createCircle()
    hitboxCircles[player] = circle

    local headPosition, onScreen = Camera:WorldToViewportPoint(head.Position)
    if onScreen then
        local distance = (Camera.CFrame.Position - head.Position).Magnitude
        local adjustedRadius = circleBaseRadius / (distance / 10) -- Ajustar el tamaño en función de la distancia
        adjustedRadius = math.clamp(adjustedRadius, 5, 50) -- Limitar el tamaño mínimo y máximo del círculo

        circle.Position = Vector2.new(headPosition.X, headPosition.Y)
        circle.Radius = adjustedRadius
        circle.Visible = true
    else
        circle.Visible = false
    end
end

local function removeCircle(player)
    if hitboxCircles[player] then
        hitboxCircles[player]:Remove()
        hitboxCircles[player] = nil
    end
end

local function toggleHitboxCircles(state)
    CirclesEnabled = state

    if state then
        -- Conectar la lógica de RenderStepped
        connections[#connections + 1] = RunService.RenderStepped:Connect(function()
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    updateCircle(player)
                end
            end
        end)
    else
        -- Desactivar y limpiar las hitboxes
        for _, connection in pairs(connections) do
            connection:Disconnect()
        end
        connections = {}

        for _, circle in pairs(hitboxCircles) do
            circle:Remove()
        end
        hitboxCircles = {}
    end
end

-- Botón de activación/desactivación
Tab:AddButton({
    Name = "Head ESP",
    Callback = function()
        toggleHitboxCircles(not CirclesEnabled)
        OrionLib:MakeNotification({
            Name = "Hitbox",
            Content = CirclesEnabled and "Hitbox Activada" or "Hitbox Desactivada",
            Image = "rbxassetid://4483345998",
            Time = 5
        })
    end
})





-- Distancia ESP

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local distanceLabels = {}
local DistanceEnabled = false
local TextScale = 1 -- Escala del texto
local connections = {}

local function createDistanceLabel()
    local text = Drawing.new("Text")
    text.Size = 16
    text.Transparency = 1
    text.Color = Color3.fromRGB(255, 255, 255) -- Blanco
    text.Center = true
    text.Outline = true
    text.Visible = false
    return text
end

local function updateDistanceLabel(player)
    if player == LocalPlayer then return end

    local character = player.Character
    if not character then return end

    local head = character:FindFirstChild("Head")
    if not head then return end

    local label = distanceLabels[player] or createDistanceLabel()
    distanceLabels[player] = label

    local headPosition, onScreen = Camera:WorldToViewportPoint(head.Position)
    if onScreen then
        local distance = (Camera.CFrame.Position - head.Position).Magnitude

        -- Actualizar posición y texto
        label.Position = Vector2.new(headPosition.X, headPosition.Y + 20) -- Posición debajo de la cabeza
        label.Text = string.format("%.1fm", distance) -- Solo el número con "m"
        label.Size = 16 * TextScale -- Escala ajustable
        label.Visible = true
    else
        label.Visible = false
    end
end

local function removeDistanceLabel(player)
    if distanceLabels[player] then
        distanceLabels[player]:Remove()
        distanceLabels[player] = nil
    end
end

local function toggleDistance(state)
    DistanceEnabled = state

    if state then
        connections[#connections + 1] = RunService.RenderStepped:Connect(function()
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    updateDistanceLabel(player)
                end
            end
        end)
    else
        for _, connection in pairs(connections) do
            connection:Disconnect()
        end
        connections = {}

        for _, label in pairs(distanceLabels) do
            label:Remove()
        end
        distanceLabels = {}
    end
end

-- Botón de activación/desactivación
Tab:AddButton({
    Name = "Player Distance",
    Callback = function()
        toggleDistance(not DistanceEnabled)
        OrionLib:MakeNotification({
            Name = "Distancia",
            Content = DistanceEnabled and "Distancia Activada" or "Distancia Desactivada",
            Image = "rbxassetid://4483345998",
            Time = 5
        })
    end
})

-- Slider para ajustar el tamaño del texto de distancia
Tab:AddSlider({
    Name = "Text Size Scale",
    Min = 0.5,
    Max = 3,
    Default = 1,
    Increment = 0.1,
    ValueName = "Tamaño",
    Callback = function(value)
        TextScale = value
    end
})


-- USERNAME ESP

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local nameLabels = {}
local NameEnabled = false
local NameFontSize = 16 -- Tamaño inicial del texto
local connections = {}

local function createNameLabel()
    local text = Drawing.new("Text")
    text.Size = NameFontSize
    text.Transparency = 1
    text.Color = Color3.fromRGB(255, 255, 255) -- Blanco
    text.Center = true
    text.Outline = true
    text.Visible = false
    return text
end

local function updateNameLabel(player)
    if player == LocalPlayer then return end

    local character = player.Character
    if not character then return end

    local head = character:FindFirstChild("Head")
    if not head then return end

    local label = nameLabels[player] or createNameLabel()
    nameLabels[player] = label

    local headPosition, onScreen = Camera:WorldToViewportPoint(head.Position)
    if onScreen then
        -- Actualizar posición y texto
        label.Position = Vector2.new(headPosition.X, headPosition.Y - 20) -- Posición sobre la cabeza
        label.Text = player.Name
        label.Size = NameFontSize -- Ajustar tamaño con el slider
        label.Visible = true
    else
        label.Visible = false
    end
end

local function removeNameLabel(player)
    if nameLabels[player] then
        nameLabels[player]:Remove()
        nameLabels[player] = nil
    end
end

local function toggleNames(state)
    NameEnabled = state

    if state then
        connections[#connections + 1] = RunService.RenderStepped:Connect(function()
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    updateNameLabel(player)
                end
            end
        end)
    else
        for _, connection in pairs(connections) do
            connection:Disconnect()
        end
        connections = {}

        for _, label in pairs(nameLabels) do
            label:Remove()
        end
        nameLabels = {}
    end
end

-- Botón para activar/desactivar los nombres
Tab:AddButton({
    Name = "Toggle Player Names",
    Callback = function()
        toggleNames(not NameEnabled)
        OrionLib:MakeNotification({
            Name = "Nombres",
            Content = NameEnabled and "Nombres Activados" or "Nombres Desactivados",
            Image = "rbxassetid://4483345998",
            Time = 5
        })
    end
})

-- Slider para ajustar el tamaño de los nombres
Tab:AddSlider({
    Name = "Font Size",
    Min = 10,
    Max = 30,
    Default = 16,
    Increment = 1,
    ValueName = "Size",
    Callback = function(value)
        NameFontSize = value
    end
})



-- ITEM ESP

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local itemLabels = {}
local ItemEnabled = false
local ItemFontSize = 16 -- Tamaño inicial del texto
local connections = {}

-- Función para crear una nueva etiqueta
local function createItemLabel()
    local text = Drawing.new("Text")
    text.Size = ItemFontSize
    text.Transparency = 1
    text.Color = Color3.fromRGB(255, 255, 255) -- Blanco
    text.Center = true
    text.Outline = true
    text.Visible = false
    return text
end

-- Función para actualizar la etiqueta de los objetos en las manos
local function updateItemLabel(player)
    if player == LocalPlayer then return end

    local character = player.Character
    if not character then return end

    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end

    -- Buscar la herramienta equipada (el objeto en la mano)
    local tool = character:FindFirstChildOfClass("Tool") -- Ajuste aquí
    if not tool then return end -- Si no hay herramienta, salir

    -- Crear o reutilizar etiqueta
    local label = itemLabels[player] or createItemLabel()
    itemLabels[player] = label

    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end

    local rootPos, onScreen = Camera:WorldToViewportPoint(humanoidRootPart.Position)
    if onScreen then
        -- Actualizar posición y texto
        label.Position = Vector2.new(rootPos.X, rootPos.Y - 20) -- Posición sobre la cabeza
        label.Text = tool.Name -- Nombre del objeto en la mano
        label.Size = ItemFontSize
        label.Visible = true
    else
        label.Visible = false
    end
end

-- Función para eliminar la etiqueta de los objetos
local function removeItemLabel(player)
    if itemLabels[player] then
        itemLabels[player]:Remove()
        itemLabels[player] = nil
    end
end

-- Función para activar o desactivar el ESP de objetos
local function toggleItemESP(state)
    ItemEnabled = state

    if state then
        -- Limpiar conexiones previas para evitar duplicados
        for _, connection in pairs(connections) do
            connection:Disconnect()
        end
        connections = {}

        connections[#connections + 1] = RunService.RenderStepped:Connect(function()
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    updateItemLabel(player)
                end
            end
        end)
    else
        for _, connection in pairs(connections) do
            connection:Disconnect()
        end
        connections = {}

        for _, label in pairs(itemLabels) do
            label:Remove()
        end
        itemLabels = {}
    end
end

-- Botón de activación/desactivación para el ESP de herramientas
Tab:AddButton({
    Name = "Item ESP",
    Callback = function()
        toggleItemESP(not ItemEnabled)
        OrionLib:MakeNotification({
            Name = "Item ESP",
            Content = ItemEnabled and "Item ESP Activado" or "Item ESP Desactivado",
            Image = "rbxassetid://4483345998",
            Time = 5
        })
    end
})

-- Slider para ajustar el tamaño del texto de los objetos
Tab:AddSlider({
    Name = "Item Text Size",
    Min = 10,
    Max = 30,
    Default = 16,
    Increment = 1,
    ValueName = "Size",
    Callback = function(value)
        ItemFontSize = value
    end
})
