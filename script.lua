-- Script todo em uma única string para usar com loadstring
local scriptSource = [[
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- GUI Setup
local VanGui = Instance.new("ScreenGui")
VanGui.Name = "VanGui"
VanGui.Parent = PlayerGui

local Opener = Instance.new("Frame")
Opener.Name = "Opener"
Opener.Parent = VanGui
Opener.BackgroundColor3 = Color3.new(0, 0, 0)
Opener.BackgroundTransparency = 0.5
Opener.Position = UDim2.new(0.01, 0, 0.8, 0)
Opener.Size = UDim2.new(0.15, 0, 0.05, 0)

local OpenButton = Instance.new("TextButton")
OpenButton.Name = "Open"
OpenButton.Parent = Opener
OpenButton.BackgroundColor3 = Color3.new(0, 0, 0)
OpenButton.BackgroundTransparency = 0.5
OpenButton.Size = UDim2.new(1, 0, 1, 0)
OpenButton.Font = Enum.Font.SciFi
OpenButton.FontSize = Enum.FontSize.Size24
OpenButton.Text = "Open Van GUI"
OpenButton.TextColor3 = Color3.new(0, 1, 1)
OpenButton.TextSize = 24

local DaGui = Instance.new("Frame")
DaGui.Name = "DaGui"
DaGui.Parent = VanGui
DaGui.BackgroundColor3 = Color3.new(0, 0, 0)
DaGui.BackgroundTransparency = 0.7
DaGui.Draggable = true
DaGui.Position = UDim2.new(0.5, -171, 0.5, -98)
DaGui.Size = UDim2.new(0, 343, 0, 197)
DaGui.Visible = false

local CloseButtonFrame = Instance.new("Frame")
CloseButtonFrame.Parent = DaGui
CloseButtonFrame.BackgroundColor3 = Color3.new(1, 0, 0.0156863)
CloseButtonFrame.Position = UDim2.new(1, -30, 0, 0)
CloseButtonFrame.Size = UDim2.new(0, 30, 0, 26)

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "Close"
CloseButton.Parent = CloseButtonFrame
CloseButton.BackgroundColor3 = Color3.new(1, 0, 0.0156863)
CloseButton.Size = UDim2.new(1, 0, 1, 0)
CloseButton.Font = Enum.Font.SciFi
CloseButton.FontSize = Enum.FontSize.Size14
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.new(1, 1, 1)
CloseButton.TextSize = 14

local UsernameTextBox = Instance.new("TextBox")
UsernameTextBox.Name = "Username"
UsernameTextBox.Parent = DaGui
UsernameTextBox.BackgroundColor3 = Color3.new(0, 0, 0)
UsernameTextBox.BackgroundTransparency = 0.5
UsernameTextBox.Position = UDim2.new(0.5, -100, 0.4, 0)
UsernameTextBox.Size = UDim2.new(0, 200, 0, 24)
UsernameTextBox.Font = Enum.Font.SciFi
UsernameTextBox.FontSize = Enum.FontSize.Size18
UsernameTextBox.PlaceholderText = "Enter Username"
UsernameTextBox.Text = ""
UsernameTextBox.TextColor3 = Color3.new(0, 1, 1)
UsernameTextBox.TextSize = 18

local VanPlayerButton = Instance.new("TextButton")
VanPlayerButton.Name = "VanPlayer"
VanPlayerButton.Parent = DaGui
VanPlayerButton.BackgroundColor3 = Color3.new(0, 0, 0)
VanPlayerButton.BackgroundTransparency = 0.5
VanPlayerButton.Position = UDim2.new(0.5, -75, 0.7, 0)
VanPlayerButton.Size = UDim2.new(0, 150, 0, 26)
VanPlayerButton.Font = Enum.Font.SciFi
VanPlayerButton.FontSize = Enum.FontSize.Size14
VanPlayerButton.Text = "Activate Van"
VanPlayerButton.TextColor3 = Color3.new(0, 1, 1)
VanPlayerButton.TextSize = 14

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Parent = DaGui
TitleLabel.BackgroundColor3 = Color3.new(0, 0, 0)
TitleLabel.BackgroundTransparency = 0.5
TitleLabel.Position = UDim2.new(0.5, -123, 0.1, 0)
TitleLabel.Size = UDim2.new(0, 246, 0, 19)
TitleLabel.Font = Enum.Font.SciFi
TitleLabel.FontSize = Enum.FontSize.Size18
TitleLabel.Text = "Van Player Gui by 345678 (Talha)"
TitleLabel.TextColor3 = Color3.new(0, 1, 1)
TitleLabel.TextSize = 17

OpenButton.MouseButton1Click:Connect(function()
    DaGui.Visible = true
    Opener.Visible = false
end)

CloseButton.MouseButton1Click:Connect(function()
    DaGui.Visible = false
    Opener.Visible = true
end)

VanPlayerButton.MouseButton1Click:Connect(function()
    local VictimName = UsernameTextBox.Text
    if VictimName and VictimName:len() > 0 then
        local VictimCharacter = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local VictimHumanoid = VictimCharacter and VictimCharacter:FindFirstChildOfClass("Humanoid")
        if VictimHumanoid then
            VictimHumanoid.WalkSpeed = 0
            VictimHumanoid.JumpPower = 0
            VictimHumanoid.Sit = true

            -- VAN CREATION --
            local playerRoot = VictimCharacter:WaitForChild("HumanoidRootPart")
            local o1 = Instance.new("Model"); o1.Name = "Van_"..LocalPlayer.Name; o1.Parent = workspace
            local spawnCFrame = playerRoot.CFrame * CFrame.new(0,0,-20)
            local function newPart(name, size, offset, color, mesh)
                local p = Instance.new("Part")
                p.Name = name
                p.Size = size
                p.BrickColor = BrickColor.new(color)
                p.Anchored = true
                p.CFrame = spawnCFrame * CFrame.new(offset)
                p.Parent = o1
                if mesh then mesh.Parent = p end
                return p
            end
            -- Exemplo de partes, repita até o124 ajustando offset/mesh
            local chassis = newPart("Chassis", Vector3.new(20,10,10), Vector3.new(0,5,0), "Really black", nil)
            local door = newPart("Door", Vector3.new(2,4,0.2), Vector3.new(-5,3,-10), "Dark stone grey", nil)

            -- SOUND OPTION (motor)
            local o21 = Instance.new("Sound", o1)
            o21.Name = "EngineSound"
            o21.SoundId = "rbxassetid://12345678"
            o21.Looped = true
            o21:Play()

            -- RESTORE MOVEMENT
            task.delay(10, function()
                VictimHumanoid.WalkSpeed = 16
                VictimHumanoid.JumpPower = 50
                VictimHumanoid.Sit = false
            end)
        end
    end
end)
-- FIM DA STRING DO SCRIPT
]]

-- Carrega e executa
loadstring(scriptSource)()
