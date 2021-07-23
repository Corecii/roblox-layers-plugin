local RunService = game:GetService("RunService")

if not RunService:IsEdit() then
	return
end

local package = require(script.package)
local Roact = package("Roact")

local TagHider = require(script.TagHider)
local LayersPlugin = require(script.components.LayersPlugin)

TagHider.prepare()

Roact.setGlobalConfig({
	typeChecks = true,
	propValidation = true,
	elementTracing = true,
})

local app = Roact.createElement(LayersPlugin, {
	plugin = plugin,
})

Roact.mount(app, nil)
