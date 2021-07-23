local package = require(script.Parent.Parent.package)
local Roact = package("Roact")

local LayersContext = require(script.Parent.LayersContext)
local LayersGui = require(script.Parent.LayersGui)

local LayersPluginGui = Roact.Component:extend("LayersPluginGui")

function LayersPluginGui:init(props)
	-- who decided dock widget plugin gui into should be a bunch of params instead of a dictionary??
	local pluginGui = props.plugin:CreateDockWidgetPluginGui(
		"Layers",
		DockWidgetPluginGuiInfo.new(
			Enum.InitialDockState.Right, -- initDockState
			false, -- initEnabled
			false, -- overrideEnabledRestore
			200, -- floatXSize
			100, -- floatYSize
			200, -- minWidth
			100 -- minHeight
		)
	)

	pluginGui.Title = "Layers"

	self:setState({
		pluginGui = pluginGui,
		enabled = pluginGui.Enabled,
	})

	pluginGui:GetPropertyChangedSignal("Enabled"):Connect(function()
		self:setState({ enabled = pluginGui.Enabled })
	end)

	if props.button then
		props.button.Click:Connect(function()
			pluginGui.Enabled = not pluginGui.Enabled
		end)
	end
end

function LayersPluginGui:render()
	return Roact.createElement(LayersContext.Consumer, {
		render = function(context)
			return Roact.createElement(Roact.Portal, {
				target = self.state.pluginGui,
			}, {
				Background = Roact.createElement("Frame", {
					BorderSizePixel = 0,
					BackgroundColor3 = context.theme:GetColor("MainBackground"),
					Size = UDim2.new(1, 0, 1, 0),
				}, {
					LayersGui = self.state.enabled and Roact.createElement(LayersGui),
				}),
			})
		end,
	})
end

return LayersPluginGui
