local PLANETS = require("PLANETS")
local newControls = {}
for planet, _ in pairs(PLANETS) do
	table.insert(newControls, {
		type = "custom-input",
		name = "PlanetShortcuts-" .. planet,
		key_sequence = "SHIFT + ALT + " .. planet:sub(1,1):upper(),
		order = "" .. #newControls,

		-- Apparently this doesn't work. The localised name must be called controls.PlanetShortcuts-nauvis etc., no parameters. It ignores this localised_name field.
		--localised_name = {"custom.PlanetShortcuts-name", {planet, data.raw.planet[planet].localised_name}},
	})
end
data:extend(newControls)