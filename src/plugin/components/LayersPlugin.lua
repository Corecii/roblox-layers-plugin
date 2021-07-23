local package = require(script.Parent.Parent.package)
local Roact = package("Roact")

local LayersContext = require(script.Parent.LayersContext)
local LayersPluginGui = require(script.Parent.LayersPluginGui)
-- local LayersOverlay = require(script.Parent.LayersOverlay)

local LayersPlugin = Roact.Component:extend("LayersPlugin")

function LayersPlugin:init(props)
	self.toolbar = props.plugin:CreateToolbar("Layers")
	self.widgetButton = self.toolbar:CreateButton(
		"LayersWidget",
		"Toggle Layers Widget",
		"rbxassetid://7139138534",
		"Layers Widget"
	)
	-- self.overlayButton = self.toolbar:CreateButton("LayersOverlay", "Toggle Layers Overlay", "", "Layers Overlay")

	settings().Studio:GetPropertyChangedSignal("Theme"):Connect(function()
		self:setState({})
	end)
end

function LayersPlugin:render()
	return Roact.createElement(LayersContext.Provider, {
		value = {
			plugin = self.props.plugin,
			theme = settings().Studio.Theme,
		},
	}, {
		LayersPluginGui = Roact.createElement(LayersPluginGui, {
			plugin = self.props.plugin,
			button = self.widgetButton,
		}),
		-- LayersOverlay = Roact.createElement(LayersOverlay, {
		-- 	plugin = self.props.plugin,
		-- 	button = self.overlayButton,
		-- }),
	})
end

return LayersPlugin
