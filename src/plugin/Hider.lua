local PhysicsService = game:GetService("PhysicsService")
local CollectionService = game:GetService("CollectionService")

local hiddenInstanceCleanup = {}

local Hider = {}

Hider.updated = Instance.new("BindableEvent")

local enabled = false

function Hider.enable()
	enabled = true

	for _, group in ipairs(PhysicsService:GetCollisionGroups()) do
		if group.name == "StudioHide" then
			return
		end
	end

	PhysicsService:CreateCollisionGroup("StudioHide")
	PhysicsService:CollisionGroupSetCollidable("StudioHide", "Default", false)
	Hider.updated:Fire()
end

for _, group in ipairs(PhysicsService:GetCollisionGroups()) do
	if group.name == "StudioHide" then
		Hider.enable()
		break
	end
end

function Hider.isEnabled()
	return enabled
end

local function hidePart(part)
	if CollectionService:HasTag(part, "StudioHide") then
		return
	end

	if part:IsA("BasePart") then
		part:SetAttribute("StudioHideCollisionGroupId", part.CollisionGroupId)
		PhysicsService:SetPartCollisionGroup(part, "StudioHide")

		part.LocalTransparencyModifier = 1
	elseif part:IsA("Texture") then
		part.LocalTransparencyModifier = 1
	end

	CollectionService:AddTag(part, "StudioHide")
end

local function showPart(part)
	if not CollectionService:HasTag(part, "StudioHide") then
		return
	end

	if part:IsA("BasePart") then
		part.CollisionGroupId = part:GetAttribute("StudioHideCollisionGroupId") or 0
		part:SetAttribute("StudioHideCollisionGroupId", nil)

		part.LocalTransparencyModifier = 0
	elseif part:IsA("Texture") then
		part.LocalTransparencyModifier = 0
	end

	CollectionService:RemoveTag(part, "StudioHide")
end

local function getHighestHiddenAncestor(instance, shouldHide)
	local highestHiddenAncestor = nil
	local parent = instance.Parent
	while parent ~= nil and parent ~= game and parent.Parent ~= game do
		if shouldHide(parent) then
			highestHiddenAncestor = parent
		end

		parent = parent.Parent
	end

	return highestHiddenAncestor
end

local function updateInstance(instance, shouldHide, hiddenAncestorCausingUpdate)
	if not enabled then
		return
	end

	local isSelfHidden = shouldHide(instance)

	if instance:IsA("BasePart") or instance:IsA("Texture") then
		local isHidden = isSelfHidden or hiddenAncestorCausingUpdate ~= nil

		if isHidden then
			hidePart(instance)
		else
			showPart(instance)
		end
	end

	local cleanup = hiddenInstanceCleanup[instance]

	local shouldHandleDescendantHiding = isSelfHidden and not hiddenAncestorCausingUpdate
	if cleanup and not shouldHandleDescendantHiding then
		cleanup(hiddenAncestorCausingUpdate ~= nil)
	end

	if shouldHandleDescendantHiding then
		if cleanup then
			cleanup(true)
		end

		local conn1 = instance.DescendantAdded:Connect(function(descendant)
			updateInstance(descendant, shouldHide, instance)
		end)
		local conn2 = instance.DescendantRemoving:Connect(function(descendant)
			descendant.AncestryChanged:Wait()
			updateInstance(descendant, shouldHide, getHighestHiddenAncestor(instance, shouldHide))
		end)

		cleanup = function(skipDescendants)
			if hiddenInstanceCleanup[instance] == cleanup then
				hiddenInstanceCleanup[instance] = nil
			end

			conn1:Disconnect()
			conn2:Disconnect()

			if skipDescendants then
				return
			end

			for _, child in ipairs(instance:GetDescendants()) do
				updateInstance(child, shouldHide, getHighestHiddenAncestor(child, shouldHide))
			end
		end

		hiddenInstanceCleanup[instance] = cleanup

		for _, descendant in ipairs(instance:GetDescendants()) do
			updateInstance(descendant, shouldHide, instance)
		end
	end
end

function Hider.updateInstanceState(instance, shouldHide)
	if not enabled then
		error("Not enabled")
	end

	updateInstance(instance, shouldHide, getHighestHiddenAncestor(instance, shouldHide))
end

function Hider.disable()
	enabled = false

	for _, part in ipairs(CollectionService:GetTagged("StudioHide")) do
		if part:IsA("BasePart") or part:IsA("Texture") then
			showPart(part)
		end

		CollectionService:RemoveTag(part, "StudioHide")
	end

	for _instance, cleanup in pairs(hiddenInstanceCleanup) do
		cleanup()
	end

	PhysicsService:RemoveCollisionGroup("StudioHide")
	Hider.updated:Fire()
end

return Hider
