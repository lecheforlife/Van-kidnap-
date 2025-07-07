-- Kidnap Van Script por lecheforlife😈🚐

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

-- Cria RemoteEvent se não existir
local event = ReplicatedStorage:FindFirstChild("KidnapPlayer")
if not event then
    event = Instance.new("RemoteEvent")
    event.Name = "KidnapPlayer"
    event.Parent = ReplicatedStorage
end

-- Sequestro quando ativado
event.OnServerEvent:Connect(function(player, victim)
    local van = Workspace:FindFirstChild("Van")
    local seat = van and van:FindFirstChild("Seat")
    local waypointsFolder = Workspace:FindFirstChild("Waypoints")
    local waypoints = waypointsFolder and waypointsFolder:GetChildren()

    if not (victim and victim.Character and seat and van and waypoints and #waypoints > 0) then
        warn("Componentes faltando!")
        return
    end

    local char = victim.Character
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- Leva pra van
    hrp.CFrame = seat.CFrame * CFrame.new(0, 2, 0)

    -- Solda pra não cair
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = seat
    weld.Part1 = hrp
    weld.Parent = seat

    -- Mover van entre os pontos
    for _, wp in ipairs(waypoints) do
        van:SetPrimaryPartCFrame(CFrame.new(wp.Position))
        task.wait(1.5)
    end

    -- Ejetar vítima
    weld:Destroy()
    hrp.Velocity = Vector3.new(0, 50, -50)

    -- Efeito de sangue leve
    local head = char:FindFirstChild("Head")
    if head then
        local blood = Instance.new("ParticleEmitter", head)
        blood.Texture = "rbxassetid://248625108"
        blood.Lifetime = NumberRange.new(1)
        blood.Rate = 100
        blood.Speed = NumberRange.new(10)
        task.wait(1)
        blood.Enabled = false
        blood:Destroy()
    end
end)
