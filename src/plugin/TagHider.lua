local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local ServerStorage = game:GetService("ServerStorage")
local ChangeHistoryService = game:GetService("ChangeHistoryService")

local Hider = require(script.Parent.Hider)

local TagHider = {}

TagHider.updated = Instance.new("BindableEvent")

local hiddenTags = {}

local hiddenTagConns = {}

local function shouldHide(instance)
	for _, tag in ipairs(CollectionService:GetTags(instance)) do
		if hiddenTags[tag] then
			return true
		end
	end

	return false
end

local function updateHiddenTagsSaveState()
	ServerStorage:SetAttribute("StudioHideTags", HttpService:JSONEncode(hiddenTags))
end

function TagHider.hideTag(tag)
	if hiddenTags[tag] then
		return
	end

	hiddenTags[tag] = true

	for _, instance in ipairs(CollectionService:GetTagged(tag)) do
		Hider.updateInstanceState(instance, shouldHide)
	end

	hiddenTagConns[tag] = CollectionService:GetInstanceAddedSignal(tag):Connect(function(instance)
		Hider.updateInstanceState(instance, shouldHide)
	end)

	updateHiddenTagsSaveState()
	TagHider.updated:Fire()

	ChangeHistoryService:SetWaypoint("Layers: " .. tag)
end

function TagHider.showTag(tag)
	if not hiddenTags[tag] then
		return
	end

	hiddenTags[tag] = false
	hiddenTagConns[tag]:Disconnect()

	for _, instance in ipairs(CollectionService:GetTagged(tag)) do
		Hider.updateInstanceState(instance, shouldHide)
	end

	updateHiddenTagsSaveState()
	TagHider.updated:Fire()

	ChangeHistoryService:SetWaypoint("Layers: " .. tag)
end

function TagHider.forgetTag(tag)
	TagHider.showTag(tag)

	hiddenTags[tag] = nil

	updateHiddenTagsSaveState()
	TagHider.updated:Fire()

	ChangeHistoryService:SetWaypoint("Layers: " .. tag)
end

function TagHider.getTags()
	return hiddenTags
end

local function reapplyTag(tag)
	for _, instance in ipairs(CollectionService:GetTagged(tag)) do
		Hider.updateInstanceState(instance, shouldHide)
	end
end

function TagHider.reapply()
	for tag, _hidden in pairs(hiddenTags) do
		reapplyTag(tag)
	end
end

function TagHider.prepare()
	if ServerStorage:GetAttribute("StudioHideTags") then
		xpcall(function()
			hiddenTags = HttpService:JSONDecode(ServerStorage:GetAttribute("StudioHideTags"))
			assert(typeof(hiddenTags) == "table", "Should be a table")
		end, function(err)
			warn(
				"Layers Plugin: Failed to read StudioHideTags attribute of ServerStore -- is it malformed?\nError:",
				err
			)
		end)
	end

	local function changeReapply(waypoint)
		local tagName = waypoint:match("^Layers: (.*)$")
		if tagName then
			reapplyTag(tagName)
			updateHiddenTagsSaveState()
		end
	end

	ChangeHistoryService.OnUndo:Connect(changeReapply)
	ChangeHistoryService.OnRedo:Connect(changeReapply)
end

function TagHider.clean()
	local oldTags = hiddenTags

	hiddenTags = {}
	ServerStorage:SetAttribute("StudioHideTags", nil)

	if Hider.isEnabled() then
		for tag, hidden in pairs(oldTags) do
			if hidden then
				for _, instance in ipairs(CollectionService:GetTagged(tag)) do
					Hider.updateInstanceState(instance, shouldHide)
				end
			end
		end
	end

	TagHider.updated:Fire()
end

return TagHider
