-- AutoSlapV2.lua

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")

-- CONFIGURAÇÕES
_G.SnowFarm = _G.SnowFarm == nil and true or _G.SnowFarm
_G.FarmSlapsSnowFarm = _G.FarmSlapsSnowFarm or 200
_G.WaitRegisterSnowFarm = _G.WaitRegisterSnowFarm or 2
_G.AutoRejoin = _G.AutoRejoin == nil and true or _G.AutoRejoin
_G.AutoEnterArena = _G.AutoEnterArena == nil and true or _G.AutoEnterArena
_G.DelayBetweenSlaps = _G.DelayBetweenSlaps or 0.3

local REMOTE_NAME = "SnowHit" -- Pode mudar aqui pra outra luva se quiser
local FILE_NAME = "SmallServerServerHop-Nexer1234.json" -- arquivo local pra salvar servidores visitados

-- Variáveis locais
local Remote = ReplicatedStorage:WaitForChild(REMOTE_NAME)
local GloveValue = function()
    local glove = LocalPlayer.leaderstats and LocalPlayer.leaderstats.Glove
    if glove then return glove.Value else return "" end
end

local function GetRoot(char)
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
end

local function GetRandomPlayer()
    local candidates = {}
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer 
        and plr.Character 
        and plr.Character:FindFirstChild("entered") 
        and plr.Character.entered.Value == true
        and not (plr.Character:FindFirstChild("Ragdolled") and plr.Character.Ragdolled.Value == true)
        and plr.Character:FindFirstChildWhichIsA("Humanoid") 
        and plr.Character:FindFirstChildWhichIsA("Humanoid").Health > 0
        and plr.Character:FindFirstChild("HumanoidRootPart")
        and not plr.Character:FindFirstChild("rock")
        and not plr.Character:FindFirstChild("stevebody") then
            table.insert(candidates, plr)
        end
    end
    if #candidates == 0 then return nil end
    return candidates[math.random(1,#candidates)]
end

local function EquipSnowGlove()
    if GloveValue() ~= "Snow" then
        local LobbySnow = workspace:FindFirstChild("Lobby") and workspace.Lobby:FindFirstChild("Snow")
        if LobbySnow and LobbySnow:FindFirstChildWhichIsA("ClickDetector") then
            fireclickdetector(LobbySnow:FindFirstChildWhichIsA("ClickDetector"))
            task.wait(1)
        end
    end
end

local function EnterArena()
    if not _G.AutoEnterArena then return end

    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    local portal

    -- Tenta achar o portal na workspace
    portal = workspace:FindFirstChild("Arena") or workspace:FindFirstChild("Portal")
    if not portal then
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Part") and obj.Name:lower():find("portal") then
                portal = obj
                break
            end
        end
    end

    if portal then
        hrp.CFrame = portal.CFrame + Vector3.new(0, 2, 0)
        task.wait(1)
    else
        warn("[AutoSlapV2] Portal não encontrado!")
    end
end

local function ClearErrors()
    RunService.RenderStepped:Connect(function()
        pcall(function()
            GuiService:ClearError()
            if game.CoreGui:FindFirstChild("RobloxLoadingGUI") then
                game.CoreGui.RobloxLoadingGUI:Destroy()
            end
        end)
    end)
end

local function LoadServerHopData()
    local data = {}
    local suc, err = pcall(function()
        data = HttpService:JSONDecode(readfile(FILE_NAME))
    end)
    if not suc then
        data = {}
        writefile(FILE_NAME, HttpService:JSONEncode(data))
    end
    return data
end

local function SaveServerHopData(data)
    pcall(function()
        writefile(FILE_NAME, HttpService:JSONEncode(data))
    end)
end

local function GetNewServer(serversList, visited)
    for _, server in pairs(serversList) do
        local id = tostring(server.id or server.idStr or server.id_str or "")
        if server.playing < server.maxPlayers and not table.find(visited, id) then
            return id
        end
    end
    return nil
end

local function TeleportToNewServer()
    local placeId = game.PlaceId
    local visitedServers = LoadServerHopData()

    local nextPageCursor = ""
    while true do
        local url = "https://games.roblox.com/v1/games/"..placeId.."/servers/Public?sortOrder=Asc&limit=100"
        if nextPageCursor ~= "" then
            url = url .. "&cursor=" .. nextPageCursor
        end

        local success, response = pcall(function()
            return game:HttpGet(url)
        end)
        if not success then
            warn("[AutoSlapV2] Falha ao buscar servidores.")
            break
        end

        local servers = HttpService:JSONDecode(response)
        local serverId = GetNewServer(servers.data, visitedServers)

        if serverId then
            table.insert(visitedServers, serverId)
            SaveServerHopData(visitedServers)
            warn("[AutoSlapV2] Teleportando para servidor: "..serverId)
            TeleportService:TeleportToPlaceInstance(placeId, serverId, LocalPlayer)
            return true
        elseif servers.nextPageCursor then
            nextPageCursor = servers.nextPageCursor
        else
            warn("[AutoSlapV2] Não encontrou servidores disponíveis não visitados.")
            break
        end
    end

    return false
end

-- Função principal de farm
local function StartFarm()
    ClearErrors()
    EquipSnowGlove()
    EnterArena()

    task.wait(2)

    local startTime = tick()
    local slapsFarmed = 0

    while LocalPlayer.leaderstats.Slaps.Value < _G.FarmSlapsSnowFarm do
        local target = GetRandomPlayer()
        if target and target.Character then
            local root = GetRoot(target.Character)
            if root then
                -- Teleportar perto do alvo para garantir hit
                HRP.CFrame = root.CFrame * CFrame.new(0, 0, -5)
                task.wait(0.15)
                Remote:FireServer(root)
                slapsFarmed += 1
            else
                task.wait(0.1)
            end
        else
            task.wait(0.5)
        end
        task.wait(_G.DelayBetweenSlaps)
    end

    warn("[AutoSlapV2] Meta alcançada: "..slapsFarmed.." slaps em "..math.floor(tick() - startTime).." segundos.")
    task.wait(_G.WaitRegisterSnowFarm or 2)
end

-- Define o QueueOnTeleport para auto executar o script no servidor novo
local function SetupAutoExec()
    local scriptURL = "https://raw.githubusercontent.com/SEU_USUARIO/AutoSlapV2/main/AutoSlapV2.lua" -- Substitua pelo seu link raw no GitHub
    pcall(function()
        queue_on_teleport(string.format('loadstring(game:HttpGet("%s"))()', scriptURL))
    end)
end

-- Event listener para quando personagem reaparecer (morrer e spawnar)
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(3)
    if _G.AutoRejoin then
        TeleportToNewServer()
    end
end)

-- Evita múltiplas execuções
if _G.SlapFarmActive then return end
_G.SlapFarmActive = true

-- Inicia a autoexec no teleport
SetupAutoExec()

-- Inicia o farm
while true do
    StartFarm()
    if _G.AutoRejoin then
        TeleportToNewServer()
        break
    else
        break
    end
end
