--[[
	Area Effect Module made by FoxProGamingYouTube.
	For more info check out : link here
]]

local ShapeEffects = require(script.Parent:WaitForChild("ShapeEffects"))

local DefaultRaycastParams = RaycastParams.new()
DefaultRaycastParams.FilterType = Enum.RaycastFilterType.Exclude
DefaultRaycastParams.IgnoreWater = true
DefaultRaycastParams.FilterDescendantsInstances = {}

local AreaShapes = {
	["Circle"] = "Circle";
	["OneLine"] = "OneLine";
};

local BehaviorTemplate = {
	Debug = false;
	
	Lifetime = 2;
	TweenInfo_OUT = TweenInfo.new(.1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0);
	TweenInfo_IN =  TweenInfo.new(.5,Enum.EasingStyle.Quad,Enum.EasingDirection.In,0,false,0);
	
	Segments = 10;
	Mod = 1;
	TimeEachMode = .3;
	SegmentFinalPositionMinusY = 1;
	Shape = AreaShapes["Circle"];
	Container = workspace;
	PartTemplate = nil;
	Formulas = ShapeEffects.AreaShapeFormulas["Circle"];
	
	raycast = {
		params = DefaultRaycastParams;
		originOffset = Vector3.new(0,3,0);
		direction = Vector3.new(0,-10,0);
	};
}

local AREA_MODULE = {
	AreaShapes = AreaShapes;
	AreaShapeFormulas = ShapeEffects.AreaShapeFormulas;
}

function AREA_MODULE.newBehavior() : {
		Lifetime 					: number;
		TweenInfo_OUT 				: TweenInfo;
		TweenInfo_IN 				: TweenInfo ;
		Segments 					: number;
		Mod   						: number;
		TimeEachMode				: number;
		SegmentFinalPositionMinusY 	: number;
		Shape 						: string;
		Container 					: Instance;
		PartTemplate 				: BasePart?;
		Formulas 					: {
			ModAmountsFormula 		: any?;
			SegmentsRotationFormula : any?;
			SegmentsOffsetFormula 	: any?;
			SegmentSizeFormula 		: any?;
			SegmentYoffset 			: any?;
			SegmentAnglesOffset 	: any?;
		};
		raycast 					: {
			params 					: RaycastParams;
			originOffset 			: Vector3;
			direction 				: Vector3;
		};
	}
	return table.clone(BehaviorTemplate)
end

function AREA_MODULE.Emit(CF : CFrame, behavior : {})
	
	assert(CF, "[AreaEffect] Expected CFrame got nil")
	if not behavior then
		behavior = BehaviorTemplate
	end
	
	ShapeEffects[behavior.Shape](CF, behavior)
end

return AREA_MODULE
