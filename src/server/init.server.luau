local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:FindFirstChild("Shared")
local BossFight = require(Shared.BossFight)

local newBossFight = BossFight.New()
newBossFight:StartFight()
