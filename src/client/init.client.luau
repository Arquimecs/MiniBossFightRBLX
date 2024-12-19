for _, module in script:GetChildren() do
	if module:IsA("ModuleScript") and module then
		require(module)
	end
end
