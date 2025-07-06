-- 🚐 VAN DO SEQUESTRO SCRIPT (memes 2017 vibes)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

repeat wait() until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

-- Cria a van
local van = Instance.new("Model", Workspace)
van.Name = "VanDoSequestro"

local base = Instance.new("Part", van)
base.Size = Vector3.new(6, 3, 10)
base.Position = LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, 3, -30)
base.Anchored = false
base.BrickColor = BrickColor.new("Black")
base.Name = "Base"
base.TopSurface = Enum.SurfaceType.Smooth
base.BottomSurface = Enum.SurfaceType.Smooth

local seat = Instance.new("VehicleSeat", van)
seat.Size = Vector3.new(2, 1, 2)
seat.Position = base.Position + Vector3.new(0, 1.5, 0)
seat.Name = "DriverSeat"
seat.Anchored = false

-- Junta as partes
local weld = Instance.new("WeldConstraint", base)
weld.Part0 = base
weld.Part1 = seat

-- Mecanismo de “sequestro”
local function sequestrar(target)
    local char = target.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        wait(1)
        -- Teleporta o player dentro da van
        char:MoveTo(base.Position + Vector3.new(0, 2, 0))
        
        -- Mensagem no chat
        game.StarterGui:SetCore("ChatMakeSystemMessage", {
            Text = "🚐 Pegamos o "..target.Name.."! Van do Sequestro strikes again!";
            Color = Color3.fromRGB(255, 0, 0);
            Font = Enum.Font.SourceSansBold;
            FontSize = Enum.FontSize.Size24;
        })
    end
end

-- Move a van até o player e sequestra ele
local function startVanSequestro()
    local humanoid = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not humanoid then return end

    local goalPos = humanoid.Position
    local bodyVelocity = Instance.new("BodyVelocity", base)
    bodyVelocity.Velocity = (goalPos - base.Position).Unit * 50
    bodyVelocity.MaxForce = Vector3.new(999999, 999999, 999999)

    wait(2.5)
    bodyVelocity:Destroy()
    sequestrar(LocalPlayer)
end

startVanSequestro()
