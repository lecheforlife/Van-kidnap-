if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- Configurações globais
local SnowFarm = _G.SnowFarm == nil and true or _G.SnowFarm
local FarmSlapsGoal = _G.FarmSlapsSnowFarm or 200
local WaitRegister = _G.WaitRegisterSnowFarm or 2
local AutoRejoin = _G.AutoRejoin == nil and true or _G.AutoRejoin
local AutoEnterArena = _G.AutoEnterArena == nil and true or _G.AutoEnterArena
local DelayBetweenSlaps = _G.DelayBetweenSlaps or 0.3

local FILE_NAME = "SmallServerServerHop-Nexer1234.json"
local REMOTE_NAME = "SnowHit"

-- Evitar múltiplas execuções
if _G.AutoSlapV2_Active then
    warn("[AutoSlapV2] Já está rodando!")
    return
end
_G.AutoSlapV2_Active = true

print("[AutoSlapV2] Script iniciado")

-- Funções auxiliares

local function GetGloveValue()
    local ls = LocalPlayer:FindFirstChild("leaderstats")
    if not ls then return "" end
    local glove = ls:FindFirstChild("Glove")
    if glove then
        return glove.Value
    end
    return ""
end

local function GetRoot(char)
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
end

local function EquipSnowGlove()
    if GetGloveValue() ~= "Snow" then
        local lobbySnow = workspace:FindFirstChild("Lobby") and workspace.Lobby:FindFirstChild("Snow")
        if lobbySnow then
            local clickdetector = lobbySnow:FindFirstChildWhichIsA("ClickDetector")
            if clickdetector then
                print("[AutoSlapV2] Equipando luva Snow...")
                fireclickdetector(clickdetector)
                task.wait(1)
            else
                warn("[AutoSlapV2] ClickDetector não encontrado em Lobby.Snow")
            end
        else
            warn("[AutoSlapV2] Lobby.Snow não encontrado")
        end
    else
        print("[AutoSlapV2] Luva Snow já equipada")
    end
end

local function EnterArena()
    if not AutoEnterArena then return end
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    local portal

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
        print("[AutoSlapV2] Indo para o portal da arena...")
        hrp.CFrame = portal.CFrame + Vector3.new(0, 2, 0)
        task.wait(2)
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
    if #candidates == 0 then
        print("[AutoSlapV2] Nenhum jogador válido encontrado")
        return nil
    end
    local chosen = candidates[math.random(1,#candidates)]
    print("[AutoSlapV2] Jogador escolhido: "..chosen.Name)
    return chosen
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
        if tonumber(server.maxPlayers) > tonumber(server.playing) and not table.find(visited, id) then
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
            warn("[AutoSlapV2] Falha ao buscar servidores: "..tostring(response))
            break
        end

        local servers = HttpService:JSONDecode(response)
        local serverId = GetNewServer(servers.data, visitedServers)

        if serverId then
            table.insert(visitedServers, serverId)
            SaveServerHopData(visitedServers)
            print("[AutoSlapV2] Teleportando para servidor: "..serverId)
            TeleportService:TeleportToPlaceInstance(placeId, serverId, LocalPlayer)
            return true
        elseif servers.nextPageCursor then
            nextPageCursor = servers.nextPageCursor
        else
            warn("[AutoSlapV2] Não encontrou servidores disponíveis para teleporte.")
            break
        end
    end
    return false
end

local Remote = ReplicatedStorage:WaitForChild(REMOTE_NAME)

local function StartFarm()
    ClearErrors()
    EquipSnowGlove()
    EnterArena()
    task.wait(2)

    while LocalPlayer.leaderstats.Slaps.Value < FarmSlapsGoal do
        local target = GetRandomPlayer()
        if target and target.Character then
            local root = GetRoot(target.Character)
            if root then
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.CFrame = root.CFrame * CFrame.new(0, 0, -5)
                    task.wait(0.15)
                    Remote:FireServer(root)
                    print("[AutoSlapV2] Slap dado em "..target.Name)
                end
            else
                task.wait(0.1)
            end
        else
            task.wait(0.5)
        end
        task.wait(DelayBetweenSlaps)
    end
    print("[AutoSlapV2] Meta de slaps alcançada: "..FarmSlapsGoal)
    task.wait(WaitRegister)
end

-- Auto rejoin ao morrer e auto serverhop
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(3)
    if AutoRejoin then
        print("[AutoSlapV2] Personagem reapareceu, fazendo serverhop...")
        TeleportToNewServer()
    end
end)

-- Setup queue_on_teleport para autoexec
local function SetupAutoExec()
    local scriptURL = "https://raw.githubusercontent.com/lecheforlife/Van-kidnap-/main/AutoSlapV2.lua"
    if queue_on_teleport then
        queue_on_teleport(string.format('loadstring(game:HttpGet("%s"))()', scriptURL))
    elseif syn and syn.queue_on_teleport then
        syn.queue_on_teleport(string.format('loadstring(game:HttpGet("%s"))()', scriptURL))
    elseif KRNL and KRNL.QueueOnTeleport then
        KRNL.QueueOnTeleport(string.format('loadstring(game:HttpGet("%s"))()', scriptURL))
    else
        warn("[AutoSlapV2] Seu executor não suporta queue_on_teleport!")
    end
end

SetupAutoExec()
StartFarm()

if AutoRejoin then
    TeleportToNewServer()
end
