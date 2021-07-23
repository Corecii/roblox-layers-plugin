local Selection = game:GetService("Selection")
local CollectionService = game:GetService("CollectionService")

local package = require(script.Parent.Parent.package)
local Roact = package("Roact")

local Hider = require(script.Parent.Parent.Hider)
local TagHider = require(script.Parent.Parent.TagHider)

local LayersContext = require(script.Parent.LayersContext)
local ButtonEntry = require(script.Parent.ButtonEntry)

local LayersGui = Roact.Component:extend("LayersGui")

function LayersGui:init(_props)
	Hider.updated.Event:Connect(function()
		self:setState({})
	end)
	TagHider.updated.Event:Connect(function()
		self:setState({})
	end)

	Selection.SelectionChanged:Connect(function()
		self:setState({})
	end)
end

function LayersGui:render()
	return Roact.createElement(LayersContext.Consumer, {
		render = function(context)
			local enabled = Hider.isEnabled()

			local tagButtons = {}

			if enabled then
				local tags = {}

				local knownTags = TagHider.getTags()
				for tag, isHidden in pairs(knownTags) do
					table.insert(tags, { tag = tag, hidden = isHidden, known = true })
				end

				local selectedTags = {}
				for _, item in ipairs(Selection:Get()) do
					for _, tag in ipairs(CollectionService:GetTags(item)) do
						if tag ~= "StudioHide" then
							selectedTags[tag] = true
						end
					end
				end

				for tag, _ in pairs(selectedTags) do
					if knownTags[tag] == nil then
						table.insert(tags, { tag = tag, hidden = false, known = false })
					end
				end

				table.sort(tags, function(a, b)
					if a.known == b.known then
						return a.tag < b.tag
					end

					return a.known
				end)

				for index, tagInfo in ipairs(tags) do
					table.insert(
						tagButtons,
						Roact.createElement("Frame", {
							Size = UDim2.new(1, 0, 0, 32),
							BackgroundTransparency = selectedTags[tagInfo.tag] and 0.7 or 1,
							BackgroundColor3 = Color3.fromRGB(86, 112, 209),
							LayoutOrder = 100 + index,
						}, {
							UIPadding = Roact.createElement("UIPadding", {
								PaddingTop = UDim.new(0, 4),
								PaddingBottom = UDim.new(0, 4),
							}),
							NameLabel = Roact.createElement("TextLabel", {
								Size = UDim2.new(1, 0, 1, 0),
								BackgroundTransparency = 1,
								TextXAlignment = Enum.TextXAlignment.Left,
								TextSize = 12,
								TextColor3 = context.theme:GetColor("MainText"),
								Text = tagInfo.tag,
								ClipsDescendants = true,
							}, {
								UIPadding = Roact.createElement("UIPadding", {
									PaddingLeft = UDim.new(0, 12),
									PaddingRight = UDim.new(0, 12),
								}),
							}),
							Toggle = Roact.createElement(ButtonEntry, {
								size = UDim2.new(0, 80, 1, 0),
								position = UDim2.new(1, -84, 0, 0),
								text = tagInfo.hidden and "Show" or "Hide",
								textSize = 12,
								onClick = function()
									if tagInfo.hidden then
										TagHider.showTag(tagInfo.tag)
									else
										TagHider.hideTag(tagInfo.tag)
									end
								end,
							}),
							Forget = tagInfo.known and Roact.createElement(ButtonEntry, {
								size = UDim2.new(0, 80, 1, 0),
								position = UDim2.new(1, -168, 0, 0),
								text = "Forget",
								textSize = 12,
								onClick = function()
									TagHider.forgetTag(tagInfo.tag)
								end,
							}),
						})
					)
				end
			end

			return Roact.createElement("ScrollingFrame", {
				Size = UDim2.new(1, 0, 1, 0),
				CanvasSize = UDim2.new(0, 0, 0, 0),
				BackgroundTransparency = 1,
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				ScrollBarImageColor3 = context.theme:GetColor("ScrollBar"),
				ScrollBarImageTransparency = 0,
			}, {
				UIListLayout = Roact.createElement("UIListLayout", {
					SortOrder = "LayoutOrder",
					Padding = UDim.new(0, 4),
				}),
				UIPadding = Roact.createElement("UIPadding", {
					PaddingTop = UDim.new(0, 4),
					PaddingBottom = UDim.new(0, 4),
					PaddingLeft = UDim.new(0, 4),
					PaddingRight = UDim.new(0, 4),
				}),

				SettingEnable = Roact.createElement(ButtonEntry, {
					layoutOrder = 1,
					size = UDim2.new(1, 0, 0, 24),
					text = enabled and "Disable" or "Enable",
					textSize = 12,
					onClick = function()
						if Hider.isEnabled() then
							Hider.disable()
						else
							Hider.enable()
							TagHider.reapply()
						end
					end,
				}),

				SettingClear = Roact.createElement(ButtonEntry, {
					layoutOrder = 2,
					size = UDim2.new(1, 0, 0, 24),
					text = "Clear Layers",
					textSize = 12,
					onClick = function()
						TagHider:clean()
					end,
				}),

				Roact.createFragment(tagButtons),
			})
		end,
	})
end

return LayersGui
