local TweenService = game:GetService("TweenService")

local function random(min : number, max : number, j : number)
	return math.random(math.min(min,max)*j,math.max(min,max)*j)/j
end

local AreaShapeFormulas = {
	["Circle"] = {
		ModAmountsFormula = function(segments : number, mod : number, index : number)
			assert(mod, "[AreaEffect] Expected mod got nil")

			return (20 * mod)/10
		end,
		SegmentsRotationFormula = function(segments : number, mod : number, index : number)
			assert(segments, "[AreaEffect] Expected segments got nil")
			assert(index, "[AreaEffect] Expected index got nil")

			return CFrame.Angles(0,math.rad(360/segments) * index,0)
		end,
		SegmentsOffsetFormula = function(segments : number, mod : number, index : number)
			assert(mod, "[AreaEffect] Expected mod got nil")
			assert(index, "[AreaEffect] Expected index got nil")

			return CFrame.new(0,0,(index * -(25 * mod)/3) - 2)
		end,
		SegmentSizeFormula = function(segments : number, mod : number, index : number)
			assert(mod, "[AreaEffect] Expected mod got nil")
			assert(segments, "[AreaEffect] Expected segments got nil")
			
			return Vector3.new(random(4,6,1) * 15 * mod/segments, random(3,5,1), random(5,10,1))
		end,
		SegmentYoffset = function(segments : number, mod : number, index : number)
			return Vector3.new(0,5,0)
		end,
		SegmentAnglesOffset = function(segments : number, mod : number, index : number)
			return CFrame.Angles(math.rad(random(10,45,1)),0,0)
		end,
	};
	
	["OneLine"] = {
		ModAmountsFormula = function(segments : number, mod : number, index : number)
			assert(mod, "[AreaEffect] Expected mod got nil")

			return mod --(20 * mod)/10
		end,
		SegmentsRotationFormula = function(segments : number, mod : number, index : number)
			assert(segments, "[AreaEffect] Expected segments got nil")
			assert(index, "[AreaEffect] Expected index got nil")

			return CFrame.Angles(0,0,0)
		end,
		SegmentsOffsetFormula = function(segments : number, mod : number, index : number)
			assert(mod, "[AreaEffect] Expected mod got nil")
			assert(index, "[AreaEffect] Expected index got nil")

			return CFrame.new(0,0,mod + (segments * (index*6))/segments)
		end,
		SegmentSizeFormula = function(segments : number, mod : number, index : number)
			assert(mod, "[AreaEffect] Expected mod got nil")
			assert(segments, "[AreaEffect] Expected segments got nil")
			local size = random(4,6,1)

			return Vector3.new(size,size,size)
		end,
		SegmentYoffset = function(segments : number, mod : number, index : number)
			return Vector3.new(0,6,0)
		end,
		SegmentAnglesOffset = function(segments : number, mod : number, index : number)
			local min_angles = -90
			local max_angles = 90
			
			return CFrame.Angles(math.rad(random(min_angles,max_angles,1)),math.rad(random(min_angles,max_angles,1)),math.rad(random(min_angles,max_angles,1)))
		end,
	};

};

local Debris = game:GetService("Debris")

local ShapeEffects = {
	AreaShapeFormulas = AreaShapeFormulas;
	
	["Circle"] = function(CF : CFrame, behavior : {})
		
		assert(CF, "[AreaEffect] CFrame Expected got nil")
		assert(behavior, "[AreaEffect] Behavior Expected got nil")
		assert(behavior.Formulas, "Formulas Expected got nil")
		
		local Formulas : {} = behavior.Formulas
		
		local ModAmounts = Formulas.ModAmountsFormula
		local SegmentsRotation = Formulas.SegmentsRotationFormula
		local SegmentsOffset = Formulas.SegmentsOffsetFormula
		local SegmentSize = Formulas.SegmentSizeFormula
		local SegmentYoffset = Formulas.SegmentYoffset
		local SegmentAnglesOffset = Formulas.SegmentAnglesOffset
		
		local mod : number = behavior.Mod
		
		for i = 1, ModAmounts(0, mod, 0) do
			local segments
			if typeof(behavior.Segments) == "number" then
				segments = behavior.Segments
			elseif typeof(behavior.Segments) == "function" then
				segments = behavior.Segments(segments, mod, i)
			end
			assert(segments, "[AreaEffect] Segments Expected got nil")
			
			local raycast = behavior.raycast
			assert(raycast, "[AreaEffect] raycast behavior expected got nil")
			
			for i2 = 0, segments-1 do
				local potCF : CFrame = CF * SegmentsRotation(segments, mod, i2) * SegmentsOffset(segments, mod,i)
				local result = workspace:Raycast(potCF.Position + raycast.originOffset, raycast.direction, raycast.params)
				if not result then
					if behavior.Debug == true then
						warn("[AreaEffect.Debug] ground was not found for", i2, i)
					end
					continue
				end
				
				local hb : BasePart
				if behavior.PartTemplate then
					hb = behavior.PartTemplate
				else
					hb = Instance.new("Part")
					hb.CanCollide = false
					hb.Transparency = result.Instance.Transparency
					hb.Color = result.Instance.Color
					hb.Material = result.Material
					hb.Name = "hb"
					hb.CanQuery = false
					hb.TopSurface = Enum.SurfaceType.Smooth
					hb.BottomSurface = Enum.SurfaceType.Smooth
				end
				hb.Anchored = true
				hb.Parent = behavior.Container
				hb.Size = SegmentSize(segments, mod, i)
				hb.CFrame = potCF
				hb.Position = result.Position - SegmentYoffset()
				hb.CFrame *= SegmentAnglesOffset()
				hb.Parent = behavior.Container
				
				TweenService:Create(
					hb,
					behavior.TweenInfo_OUT,
					{Position = hb.Position + Vector3.new(0,SegmentYoffset().Y-behavior.SegmentFinalPositionMinusY,0)}
				):Play()
				task.delay(behavior.Lifetime,function()
					TweenService:Create(
						hb,
						behavior.TweenInfo_IN,
						{
							Position = hb.Position - Vector3.new(0,((SegmentYoffset().Y-behavior.SegmentFinalPositionMinusY)*2) * behavior.Mod,0);
							Size = Vector3.zero;
						}
					):Play()
					task.delay(behavior.TweenInfo_IN.Time,function()
						hb:Destroy()
						hb = nil
					end)
				end)
			end
			
			task.wait(behavior.TimeEachMode)
		end
		
	end;
	
	["OneLine"] = function(CF : CFrame, behavior : {})

		assert(CF, "[AreaEffect] CFrame Expected got nil")
		assert(behavior, "[AreaEffect] Behavior Expected got nil")
		assert(behavior.Formulas, "Formulas Expected got nil")

		local Formulas : {} = behavior.Formulas
		
		local ModAmounts = Formulas.ModAmountsFormula
		local SegmentsRotation = Formulas.SegmentsRotationFormula
		local SegmentsOffset = Formulas.SegmentsOffsetFormula
		local SegmentSize = Formulas.SegmentSizeFormula
		local SegmentYoffset = Formulas.SegmentYoffset
		local SegmentAnglesOffset = Formulas.SegmentAnglesOffset

		local mod : number = behavior.Mod

		for i = 1, ModAmounts(0, mod, 0) do
			local segments
			if typeof(behavior.Segments) == "number" then
				segments = behavior.Segments
			elseif typeof(behavior.Segments) == "function" then
				segments = behavior.Segments(segments, mod, i)
			end
			assert(segments, "[AreaEffect] Segments Expected got nil")

			local raycast = behavior.raycast
			assert(raycast, "[AreaEffect] raycast behavior expected got nil")

			coroutine.wrap(function()
				for i2 = 0, segments-1 do
					local potCF : CFrame = CF * SegmentsRotation(segments, mod, i2) * SegmentsOffset(segments, i, i2)
					local result = workspace:Raycast(potCF.Position + raycast.originOffset, raycast.direction, raycast.params)
					if not result then
						if behavior.Debug == true then
							warn("[AreaEffect.Debug] ground was not found for", i2, i)
						end
						continue
					end

					local hb : BasePart
					if behavior.PartTemplate then
						hb = behavior.PartTemplate
					else
						hb = Instance.new("Part")
						hb.CanCollide = false
						hb.Transparency = result.Instance.Transparency
						hb.Color = result.Instance.Color
						hb.Material = result.Material
						hb.Name = "hb"
						hb.CanQuery = false
						hb.TopSurface = Enum.SurfaceType.Smooth
						hb.BottomSurface = Enum.SurfaceType.Smooth
					end
					hb.Anchored = true
					hb.Parent = behavior.Container
					hb.Size = SegmentSize(segments, mod, i)
					hb.CFrame = potCF
					hb.Position = result.Position - SegmentYoffset()
					hb.CFrame *= SegmentAnglesOffset()
					hb.Parent = behavior.Container
					
					TweenService:Create(
						hb,
						behavior.TweenInfo_OUT,
						{Position = hb.Position + Vector3.new(0,SegmentYoffset().Y-behavior.SegmentFinalPositionMinusY,0)}
					):Play()
					task.delay(behavior.Lifetime,function()
						TweenService:Create(
							hb,
							behavior.TweenInfo_IN,
							{
								Position = hb.Position - Vector3.new(0,((SegmentYoffset().Y-behavior.SegmentFinalPositionMinusY)*2) * behavior.Mod,0);
								Size = Vector3.zero;
							}
						):Play()
						task.delay(behavior.TweenInfo_IN.Time,function()
							hb:Destroy()
							hb = nil
						end)
					end)
					task.wait(behavior.TimeEachMode)
				end
			end)()

			task.wait(behavior.TimeEachMode)
		end

	end;
}

return ShapeEffects
