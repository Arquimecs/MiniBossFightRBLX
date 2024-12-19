-- this is inside of the module initializer, for some reason it bugs

local UIModule = {}

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:FindFirstChild("PlayerGui")
local Main = PlayerGui:WaitForChild("Healthbar")
local Bar = Main.Health:WaitForChild("Bar")
local HealthText = Main.Health:WaitForChild("Health")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MaxHealth = ReplicatedStorage:WaitForChild("MaxHealth")
local Health = ReplicatedStorage:WaitForChild("Health")

Health.Changed:Connect(function()
	Bar.Size = UDim2.new(Health.Value / MaxHealth.Value, 0, 1, 0)
	HealthText.Text = tostring(Health.Value.. " / ".. MaxHealth.Value.. "HP")
end)

return UIModule
