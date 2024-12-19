--[[

Change (in the game's settings):

    1. RenderFidelity to Precise
    2. CollisionFidelity to PreciseConvexDecomposition
    

Otherwise, collisions will be wonky.
]]

local BossFight = {}
BossFight.__index = BossFight


local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Assets = ReplicatedStorage:FindFirstChild("Assets")
local BossModel = Assets:FindFirstChild("Wenda")
local newBossModel
local SharedModules = ReplicatedStorage.Shared
local BossAttacks = require(SharedModules.BossAttacks)

local Health = ReplicatedStorage:FindFirstChild("Health")

function BossFight.New()

	local self = setmetatable({}, BossFight)
	self.Health = 100 -- set this to whatever u want
	self.MaxHealth = 100 -- set this to whatever u want
	self.RageHealth = self.Health * 1.5 -- best settings, if on 50% hp it will do a good heal
	self.AttackDamage = {
		LaserSpin = 10,
		MeteorFall = 15,
		MinionSummon = 2,
		Spikes = 5
	}
	self.Attacks = {
		BossAttacks.LaserSpin,
		BossAttacks.MeteorFall,
		BossAttacks.Shockwave,
		BossAttacks.Spikes
	}

	self.connection = nil

	return self
end

function BossFight:Attack(attackNum: number)
	
	self.Attacks[attackNum]()
	
end

function BossFight:EndFight()
	
	BossModel:Destroy()
	
end

function BossFight:StartFight()
	
	newBossModel = BossModel:Clone()
	newBossModel.Parent = game.Workspace
	
	BossAttacks.GetBossModel(newBossModel)
	
	self:Movement()
end
function BossFight:Movement()
	self.connection = nil
	local delayTime = 2
	local timeElapsed = 0

	if not BossModel or not BossModel.PrimaryPart then return end

	if self.connection then
		self.connection:Disconnect()
		self.connection = nil
	end

	self.connection = RunService.Heartbeat:Connect(function(deltaTime)
		timeElapsed = timeElapsed + deltaTime

		local function changeHealth()
			self.Health = newBossModel.Humanoid.Health
			Health.Value = self.Health
		end

		local healthConnection
		task.spawn(function()
			healthConnection = newBossModel.Humanoid.HealthChanged:Connect(function()
				changeHealth()
			end)
		end)

		if timeElapsed >= delayTime then
			timeElapsed = 0 
			print("skibidi attack")

			if math.random(1, 2) == 1 then
				self:Attack(math.random(1, 4))
			end
		end

		if self.Health <= 0 then
			self.connection:Disconnect()
			self.connection = nil
			healthConnection:Disconnect()
			healthConnection = nil

			self:EndFight()
			print("fight ended")
		end
	end)
end

return BossFight
