local packageRepos = {}

if not script.Parent:FindFirstChild("_packages") then
	table.insert(packageRepos, script.Parent.Parent)
end

for _, child in ipairs(script.Parent:GetChildren()) do
	if child.Name:match("^_packages") then
		table.insert(packageRepos, 1, child)
	end
end

local function package(packageName)
	for _, repo in ipairs(packageRepos) do
		if repo:FindFirstChild(packageName) then
			return require(repo:FindFirstChild(packageName))
		end
	end

	error(string.format("Cannot find package '%s'", tostring(packageName)))
end

return package
