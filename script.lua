local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Criar van simples
local function createVan(position)
    local van = Instance.new("Part")
    van.Name = "Van"
    van.Size = Vector3.new(6, 3, 12)
    van.Position = position
    van.Anchored = false
    van.BrickColor = BrickColor.new("Bright blue")
    van.Parent = workspace
    return van
end

-- Fechar porta (mudar cor da van)
local function closeVanDoor(van)
    van.BrickColor = BrickColor.new("Really black")
end

-- Abrir porta (cor original)
local function openVanDoor(van)
    van.BrickColor = BrickColor.new("Bright blue")
end

-- Mover van com Tween
local function moveVanAway(van, distance, duration)
    local goal = {}
    goal.Position = van.Position + Vector3.new(distance, 0, 0)
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(van, tweenInfo, goal)
    tween:Play()
    tween.Completed:Wait()
end

-- Função principal: sequestrar jogador pelo nick
local function kidnapPlayerByName(nick)
    local targetPlayer = Players:FindFirstChild(nick)
    if not targetPlayer then
        warn("Jogador não encontrado: "..nick)
        return
    end

    local targetChar = targetPlayer.Character
    if not targetChar or not targetChar:FindFirstChild("HumanoidRootPart") then
        warn("Personagem do jogador não encontrado ou inválido")
        return
    end

    local vanStartPos = humanoidRootPart.Position + Vector3.new(10, 0, 10)
    local van = createVan(vanStartPos)

    -- Teleporta o personagem para perto da van (simulando o sequestro)
    targetChar:SetPrimaryPartCFrame(van.CFrame * CFrame.new(0, 0, -3))

    wait(1)

    closeVanDoor(van)

    wait(1)

    -- Move van pra longe
    moveVanAway(van, 100, 5)

    wait(1)

    openVanDoor(van)

    -- Derruba personagem (humanoid com health 0)
    local humanoid = targetChar:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.Health = 0
    end

    wait(1)

    van:Destroy()

    print("Sequestro finalizado para "..nick)
end

-- GUI para input do nick e botão
local function createGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "KidnapGUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui

    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(0, 200, 0, 40)
    textBox.Position = UDim2.new(0.5, -100, 0.1, 0)
    textBox.PlaceholderText = "Digite o nick da vítima"
    textBox.Parent = screenGui
    textBox.ClearTextOnFocus = false

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 120, 0, 40)
    button.Position = UDim2.new(0.5, -60, 0.2, 0)
    button.Text = "Sequestrar"
    button.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    button.TextColor3 = Color3.new(1,1,1)
    button.Parent = screenGui

    button.MouseButton1Click:Connect(function()
        local nick = textBox.Text
        if nick ~= "" then
            kidnapPlayerByName(nick)
        else
            warn("Digite um nick válido!")
        end
    end)
end

-- Iniciar GUI
createGUI()
