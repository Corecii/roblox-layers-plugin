local package = require(script.Parent.Parent.package)
local Roact = package("Roact")

local LayersContext = require(script.Parent.LayersContext)

local ButtonEntry = Roact.Component:extend("ButtonEntry")

function ButtonEntry:init(_props)
	self:setState({
		hover = false,
		pressed = false,
	})
end

function ButtonEntry:getStatus()
	return (self.props.disabled and "Disabled")
		or (self.state.pressed and "Pressed")
		or (self.state.hover and "Hover")
		or "Default"
end

function ButtonEntry:render()
	return Roact.createElement(LayersContext.Consumer, {
		render = function(context)
			return Roact.createElement("TextButton", {
				BorderSizePixel = 0,
				Size = self.props.size or UDim2.fromScale(1, 1),
				Position = self.props.position,

				AutoButtonColor = false,
				BackgroundColor3 = context.theme:GetColor("Button", self:getStatus()),
				[Roact.Event.MouseEnter] = function()
					self:setState({ hover = true })
				end,
				[Roact.Event.MouseLeave] = function()
					self:setState({ hover = false })
				end,
				[Roact.Event.MouseButton1Down] = function()
					self:setState({ pressed = true })
				end,
				[Roact.Event.MouseButton1Up] = function()
					self:setState({ pressed = false })
				end,

				TextColor3 = context.theme:GetColor("ButtonText"),
				Text = self.props.text,
				TextSize = self.props.textSize or 24,

				[Roact.Event.MouseButton1Click] = not self.props.disabled and function(_rbx)
					if self.props.onClick then
						self.props.onClick()
					end
				end,

				LayoutOrder = self.props.layoutOrder,
			}, {
				UICorner = Roact.createElement("UICorner", {
					CornerRadius = UDim.new(0, 2),
				}),
			})
		end,
	})
end

return ButtonEntry
