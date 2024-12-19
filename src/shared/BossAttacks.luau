-- Used for Hidden devs coder role

local BossAttacks = {} 
-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage") 
local RunService = game:GetService("RunService") 
local TweenService = game:GetService("TweenService")

-- // References to Assets and Modules
local Packages = script.Parent:FindFirstChild("Packages") 
local Assets = ReplicatedStorage:FindFirstChild("Assets")

-- // Boss Attack Assets
local Spike = Assets:FindFirstChild("Spike") -- Rock spike asset
local Shockwave = Assets:FindFirstChild("Shockwave") -- Shockwave effect asset
local MeteorModel = Assets:FindFirstChild("Meteor") -- Meteor model asset

-- // External Modules
local AOEModule = require(Packages:WaitForChild("AreaEffect")) -- AOE Module

-- // Boss References
local BossTorso -- Boss's torso part (initialized later)
local BossLasers -- Laser part attached to the boss
local BossModel -- Main model representing the boss

-- // Function: Assign the Boss Model
function BossAttacks.GetBossModel(newBossModel)
	
	BossModel = newBossModel -- get the passed boss model function

	-- Find and store references to specific parts of the boss
	BossTorso = newBossModel:FindFirstChild("FakeBody").FTorso -- The fake torso part
	BossLasers = BossTorso.Parent:FindFirstChild("Lasers") -- Lasers attached to the torso
end


function BossAttacks.LaserSpin()
	print("Skibidi segma") -- sigma brainrot debug message for testing

	-- // Set up the laser visibility and collision
	BossLasers.Transparency = 0 -- make the laser visible
	BossLasers.CanCollide = true -- enable collisions to detect hits

	-- // Laser Spin settings
	local duration = 5 -- How long the laser spin lasts (seconds)
	local spinSpeed = 90 -- Degrees per second for the spin speed
	local startTime = tick() -- Get the start time to compare it with later, so we can get accurate delays that are better than task.wait(), they generally run in more than 60 FPS

	-- // Position the laser to match the boss's torso initially
	BossLasers.CFrame = BossTorso.CFrame

	-- // Detect players hit by the laser
	local touchedConnection
	touchedConnection = BossLasers.Touched:Connect(function(hit)
		-- Check if the touched object is part of a character
		local humanoid = hit.Parent:FindFirstChild("Humanoid")
		if humanoid then
			humanoid:TakeDamage(10) -- Deal 10 damage to the player
			print(hit.Parent.Name .. " was hit by the laser!") -- Debug log for hits
		end
	end)

	-- // Spin the boss and laser over time
	local connection
	connection = RunService.Heartbeat:Connect(function(deltaTime)
		-- Check how much time has passed
		local timeElapsed = tick() - startTime

		-- If the duration is up, stop the spin and clean up
		if timeElapsed >= duration then
			BossLasers.Transparency = 1 -- Hide the laser
			BossLasers.CanCollide = false -- Turn off collisions
			connection:Disconnect() -- Stop the Heartbeat loop
			touchedConnection:Disconnect() -- Stop checking for hits
			return -- Exit the function early
		end

		-- Calculate the spin angle based on time passed (deltaTime)
		local spinAngle = math.rad(spinSpeed * deltaTime) -- Convert speed to radians
		BossTorso.CFrame = BossTorso.CFrame * CFrame.Angles(0, spinAngle, 0) -- Spin the boss
		BossLasers.CFrame = BossTorso.CFrame -- Keep the laser aligned with the boss
	end)
end

function BossAttacks.MeteorFall()
	-- Get the boss's current position (center point for meteors)
	local bossPosition = BossModel.HumanoidRootPart.Position

	-- Drop between 5 to 10 meteors randomly
	for i = 1, math.random(5, 10) do
		-- Each meteor runs in its own "thread" (doesn't block the others)
		task.spawn(function()

			-- // Randomize where the meteor will fall (circle around the boss)
			local angle = math.rad(math.random(0, 360)) -- Random angle in degrees converted to radians
			local distance = 50 -- Radius for the meteor spawn circle

			-- Calculate X and Z offsets using basic trigonometry
			local offsetX = math.cos(angle) * distance
			local offsetZ = math.sin(angle) * distance

			-- Final position in X and Z (around the boss)
			local randomX = bossPosition.X + offsetX
			local randomZ = bossPosition.Z + offsetZ

			-- // Define meteor's starting and ending positions
			local startPos = Vector3.new(randomX, 100, randomZ) -- Start way up in the sky
			local endPos = Vector3.new(randomX, 0, randomZ) -- End at ground level

			-- // Create the meteor and place it at start
			local meteor = MeteorModel:Clone() -- Clone the meteor asset
			meteor.Position = startPos -- Set its position to the sky start
			meteor.Parent = game.Workspace -- Parent it to the Workspace so it shows up
			meteor.Anchored = true -- Lock it in place, no physics involved

			-- // Tween the meteor to "fall" down to the ground
			local fallTween = TweenService:Create(meteor, TweenInfo.new(2), {Position = endPos}) -- Tween duration = 2 seconds
			fallTween:Play() -- Start the tween (fall effect)

			-- When the tween finishes, trigger impact effects
			fallTween.Completed:Connect(function()
				meteor:Destroy() -- Remove the meteor after it "lands"

				-- // AOE effect on meteor impact
				local behavior = AOEModule.newBehavior()
				behavior.Shape = AOEModule.AreaShapes["Circle"] -- Circle-shaped area
				behavior.Mod = 1 -- Damage multiplier, or other mod values
				behavior.Segments = 20 -- Visual segments for the AOE (smooth circle effect)
				behavior.Lifetime = 3 -- Effect lasts 3 seconds
				AOEModule.Emit(CFrame.new(endPos), behavior) -- Spawn the AOE at the impact position

				-- // Damage players in the impact zone
				for _, player in game.Players:GetPlayers() do -- Loop through all players
					local character = player.Character -- Get their character
					if character and character:FindFirstChild("HumanoidRootPart") then -- Make sure character exists
						-- Calculate distance from impact point to the player
						local distance = (character.HumanoidRootPart.Position - endPos).Magnitude
						if distance <= 10 then -- If player is close enough (within 10 studs)
							local humanoid = character:FindFirstChild("Humanoid") -- Get humanoid to apply damage
							if humanoid then
								humanoid:TakeDamage(15) -- Deal 15 damage
								print(player.Name .. " was hit by the meteor!") -- Confirm in output
							end
						end
					end
				end
			end)
		end)
	end
end

function BossAttacks.Shockwave()
	print("Shockwave Attack!")

	-- // Shockwave settings
	local shockwaveRadius = 20 -- The max distance the shockwave affects players
	local damage = 30 -- Damage dealt to players caught in the shockwave
	local duration = 3 -- How long the shockwave lasts (in seconds)
	local bossPosition = BossModel.HumanoidRootPart.Position -- Get the boss's position

	-- // Clone the shockwave asset
	local shockwaveEffect = Shockwave:Clone() -- Use the pre-provided shockwave asset
	shockwaveEffect.Position = bossPosition -- Spawn it at the boss's location
	shockwaveEffect.Anchored = true -- Stops it from falling or moving
	shockwaveEffect.CanCollide = false -- No physical collisions
	shockwaveEffect.Parent = game.Workspace -- Parent it to the Workspace so it's visible

	-- // Initial shockwave appearance
	shockwaveEffect.Size = Vector3.new(1, 1, 1) -- Start as a small, almost invisible sphere
	shockwaveEffect.Transparency = 0.3 -- Slightly see-through for cool visuals

	-- // Animate the shockwave (scale up and fade out)
	local expandTween = TweenService:Create(
		shockwaveEffect, -- The part we're tweening
		TweenInfo.new(duration, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), -- Smooth easing over 'duration'
		{
			Size = Vector3.new(shockwaveRadius * 4, 1, shockwaveRadius * 4), -- Grow the shockwave's size
			Transparency = 1 -- Make it fully transparent (invisible) at the end
		}
	)
	expandTween:Play() -- Start the tween

	-- // Check for nearby players (damage application)
	task.delay(duration / 2, function() -- Halfway through the shockwave animation
		for _, player in game.Players:GetPlayers() do -- Loop through all players in the game
			local character = player.Character -- Get the player's character model
			if character and character:FindFirstChild("HumanoidRootPart") then -- Ensure the character exists
				-- Calculate the distance between the player and the shockwave center
				local distance = (character.HumanoidRootPart.Position - bossPosition).Magnitude
				if distance <= shockwaveRadius then -- If the player is within the radius
					local humanoid = character:FindFirstChild("Humanoid") -- Find the humanoid (for health/damage)
					if humanoid then
						humanoid:TakeDamage(damage) -- Deal the damage
						print(player.Name .. " got hit by the shockwave!") -- Confirmation in the output
					end
				end
			end
		end
	end)

	-- // Clean up the shockwave effect
	expandTween.Completed:Connect(function() -- Runs when the tween finishes
		shockwaveEffect:Destroy() -- Remove the shockwave part from the Workspace
	end)
end

function BossAttacks.Spikes()
	print("Spikes Attack!") -- debug msg

	-- // Spike attack settings
	local spikeDuration = 5 -- How long each spike stays on the ground
	local spikeCount = 10 -- How many spikes to spawn
	local bossPosition = BossModel.HumanoidRootPart.Position -- get the boss pos

	-- // Loop to create spikes at random positions
	for i = 1, spikeCount do
		task.spawn(function()
			-- Generate random position around the boss
			local angle = math.rad(math.random(0, 360)) -- Random angle for spread
			local distance = math.random(5, 20) -- Random distance for spike
			local offsetX = math.cos(angle) * distance -- X offset
			local offsetZ = math.sin(angle) * distance -- Z offset
			local spawnPos = bossPosition + Vector3.new(offsetX, 0, offsetZ) -- Final spawn position

			-- Clone the spike asset and set it up
			local spike = Spike:Clone()
			spike.Size = Vector3.new(1, 1, 1) -- Tiny size initially
			spike.Position = spawnPos - Vector3.new(0, spike.Size.Y / 2, 0) -- Adjust to be on the ground
			spike.Anchored = true
			spike.Parent = game.Workspace
			spike.Transparency = 1 -- Invisible at first

			-- // Tween the spike to grow and become visible
			local appearTween = TweenService:Create(spike, TweenInfo.new(0.5, Enum.EasingStyle.Bounce), {
				Size = Vector3.new(3, 10, 3), -- Spike grows in size
				Position = spawnPos, -- Keep the position where it should be
				Transparency = 0 -- Make it visible
			})
			appearTween:Play() -- Play the tween to make it appear

			-- // After spike appears, it stays for a bit and then disappears
			task.delay(spikeDuration, function()
				local disappearTween = TweenService:Create(spike, TweenInfo.new(0.5), {
					Transparency = 1 -- Fade it out
				})
				disappearTween:Play() -- Play the fade out effect
				-- When the fade out is done, destroy the spike
				disappearTween.Completed:Connect(function()
					spike:Destroy()
				end)
			end)

			-- // Check if players are close enough to get hit
			for _, player in game.Players:GetPlayers() do
				local character = player.Character
				if character and character:FindFirstChild("HumanoidRootPart") then
					-- Calculate the distance between player and spike
					distance = (character.HumanoidRootPart.Position - spawnPos).Magnitude
					if distance <= 5 then -- Magnitude distance check
						local humanoid = character:FindFirstChild("Humanoid")
						if humanoid then
							humanoid:TakeDamage(20) -- Damage player
							print(player.Name .. " was hit by a spike!") -- Debug message
						end
					end
				end
			end
		end)
	end
end

return BossAttacks
