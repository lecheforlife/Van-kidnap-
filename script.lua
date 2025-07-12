if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

print("[DeltaScript] Iniciando...")

local function EquipSnowGlove()
    local lobby = workspace:FindFirstChild("Lobby")
    if lobby and lobby:FindFirstChild("Snow") then
        local clickdetector = lobby.Snow:FindFirstChildWhichIsA("ClickDetector")
        if clickdetector then
            print("[DeltaScript] Equipando luva Snow...")
            fireclickdetector(clickdetector)
            task.wait(1)
        else
            warn("[DeltaScript] ClickDetector não encontrado")
        end
    else
        warn("[DeltaScript] Lobby ou Snow não encontrado")
    end
end

local function EnterPortal()
    local portal = workspace:FindFirstChild("Arena") or workspace:FindFirstChild("Portal")
    if not portal then
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name:lower():find("portal") then
                portal = obj
                break
            end
        end
    end
    if portal then
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")
        print("[DeltaScript] Indo para o portal...")
        hrp.CFrame = portal.CFrame + Vector3.new(0, 3, 0)
        task.wait(2)
    else
        warn("[DeltaScript] Portal não encontrado")
    end
end

local remote = ReplicatedStorage:WaitForChild("SnowHit")

local function GetValidTarget()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("entered")
           and plr.Character.entered.Value == true and plr.Character:FindFirstChild("HumanoidRootPart")
           and plr.Character:FindFirstChildWhichIsA("Humanoid") and plr.Character:FindFirstChildWhichIsA("Humanoid").Health > 0 then
            return plr
        end
    end
    return nil
end

local function FarmSlaps(targetSlaps)
    print("[DeltaScript] Iniciando farm até "..tostring(targetSlaps).." slaps")
    while LocalPlayer.leaderstats.Slaps.Value < targetSlaps do
        local target = GetValidTarget()
        if target and target.Character then
            local root = target.Character:FindFirstChild("HumanoidRootPart")
            local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if root and hrp then
                hrp.CFrame = root.CFrame * CFrame.new(0, 0, -5)
                remote:FireServer(root)
                print("[DeltaScript] Slap em "..target.Name)
            end
        else
            print("[DeltaScript] Nenhum alvo válido encontrado, aguardando...")
            task.wait(1)
        end
        task.wait(0.3)
    end
    print("[DeltaScript] Meta de slaps alcançada!")
end

-- EXECUÇÃO

EquipSnowGlove()
EnterPortal()
FarmSlaps(200)  -- meta de slaps pode ajustar aqui
