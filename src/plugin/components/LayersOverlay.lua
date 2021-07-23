local CoreGui = game:GetService("CoreGui")

local package = require(script.Parent.Parent.package)
local Roact = package("Roact")

local LayersContext = require(script.Parent.LayersContext)
local LayersGui = require(script.Parent.LayersGui)

local LayersOverlay = Roact.Component:extend("LayersOverlay")

function LayersOverlay:init(props)
	self:setState({
		enabled = props.plugin:GetSetting("OverlayEnabled"),
		minimized = false,
	})

	if props.button then
		props.button.Click:Connect(function()
			if self.state.enabled then
				self:hide()
			else
				self:show()
			end
		end)
	end

	self.dragPosition = props.plugin:GetSetting("OverlayDragPosition")
	self.dragSize = props.plugin:GetSetting("OverlayDragPosition")

	self.containerRef = Roact.createRef()
end

function LayersOverlay:hide()
	self.props.plugin:SetSetting("OverlayEnabled", false)
	self:setState({ enabled = false })
end

function LayersOverlay:show()
	self.props.plugin:SetSetting("OverlayEnabled", true)
	self:setState({ enabled = true })
end

function LayersOverlay:windowPos()
	return self.dragPosition or UDim2.fromOffset(50, 50)
end

function LayersOverlay:windowSize()
	return self.dragSize or UDim2.fromOffset(200, 300)
end

function LayersOverlay:render()
	return Roact.createElement(LayersContext.Consumer, {
		render = function(context)
			return Roact.createElement(Roact.Portal, {
				target = CoreGui,
			}, {
				Layers = Roact.createElement("ScreenGui", {
					Enabled = self.state.enabled,
					[Roact.Change.AbsoluteSize] = function(rbx)
						local windowMin = self:windowPos()
						if rbx.AbsoluteSize.X < windowMin.X.Offset or rbx.AbsoluteSize.Y < windowMin.Y.Offset then
							self.dragPosition = nil
							self:setState({})
						end
					end,
				}, {
					Container = self.state.enabled and Roact.createElement("Frame", {
						[Roact.Ref] = self.containerRef,
						BorderSizePixel = 0,
						BackgroundColor3 = context.theme:GetColor("MainBackground"),
						Size = self.state.minimized and UDim2.fromOffset(self:windowSize().X.Offset, 30)
							or self:windowSize(),
						Position = self:windowPos(),
						Draggable = true,
						[Roact.Change.Position] = function(rbx)
							self.dragPosition = rbx.Position
							self.props.plugin:SetSetting("OverlayDragPosition", rbx.position)
						end,
					}, {
						UICorner = Roact.createElement("UICorner", {
							CornerRadius = UDim.new(0, 10),
						}),
						Titlebar = Roact.createElement("TextLabel", {
							Size = UDim2.new(1, 0, 0, 30),
							BorderSizePixel = 0,
							BackgroundColor3 = context.theme:GetColor("Titlebar"),
							TextColor3 = context.theme:GetColor("TitlebarText"),
							Text = "Layers",
							TextXAlignment = Enum.TextXAlignment.Center,
							TextYAlignment = Enum.TextYAlignment.Center,
							TextSize = 24,
						}, {
							UIPadding = Roact.createElement("UIPadding", {
								PaddingRight = UDim.new(0, 64),
							}),
							CloseButton = Roact.createElement("TextButton", {
								BackgroundColor3 = context.theme:GetColor("Titlebar"),
								TextColor3 = context.theme:GetColor("TitlebarText"),
								Text = "X",
								TextXAlignment = Enum.TextXAlignment.Center,
								TextYAlignment = Enum.TextYAlignment.Center,
								TextSize = 20,
								Size = UDim2.fromOffset(24, 24),
								Position = UDim2.new(1, -30, 0, 4),
								[Roact.Event.MouseButton1Click] = function()
									self:hide()
								end,
							}, {
								UICorner = Roact.createElement("UICorner", {
									CornerRadius = UDim.new(0, 4),
								}),
							}),
							MinimizeButton = Roact.createElement("TextButton", {
								BackgroundColor3 = context.theme:GetColor("Titlebar"),
								TextColor3 = context.theme:GetColor("TitlebarText"),
								Text = "_",
								TextXAlignment = Enum.TextXAlignment.Center,
								TextYAlignment = Enum.TextYAlignment.Center,
								TextSize = 20,
								Size = UDim2.fromOffset(24, 24),
								Position = UDim2.new(1, -30, 0, 4),
								[Roact.Event.MouseButton1Click] = function()
									self:setState({ minimized = not self.state.minimized })
								end,
							}, {
								UICorner = Roact.createElement("UICorner", {
									CornerRadius = UDim.new(0, 4),
								}),
							}),
						}),
						Content = not self.state.minimized and Roact.createElement("Frame", {
							BackgroundTransparency = 1,
							Size = UDim2.new(1, 0, 1, -30),
							Position = UDim2.fromOffset(0, 30),
						}, {
							LayersGui = Roact.createElement(LayersGui),
						}),
					}),
					Resize = self.state.Enabled and not self.state.minimized and Roact.createElement("Frame", {
						ZIndex = 2,
						BorderSizePixel = 0,
						BackgroundColor3 = context.theme:GetColor("Titlebar"),
						AnchorPoint = Vector2.new(1, 1),
						Position = self:windowPos() + self:windowSize(),
						Draggable = true,
						[Roact.Change.Position] = function(rbx)
							local size = rbx.AbsolutePosition - self.containerRef:getValue().AbsolutePosition
							self.dragSize = Vector2.new(math.max(100, size.x), math.max(100, size.y))
							if size ~= self.dragSize then
								rbx.Position = self:windowPos() + UDim2.fromOffset(self.dragSize.x, self.dragSize.y)
							end

							self.props.plugin:SetSetting("OverlayDragSize", self.dragSize)
						end,
					}),
				}),
			})
		end,
	})
end

return LayersOverlay
