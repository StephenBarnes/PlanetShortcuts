local PLANETS = require("PLANETS")

-- Function called to update the last thing a player viewed so that we can go back to it when switching to map view.
local function setPlayerLastViewPos(player)
	if global == nil then global = {} end
	if global[player.index] == nil then global[player.index] = {} end
	if player.controller_type ~= defines.controllers.remote then return end
	--if player.render_mode == defines.render_mode.game then return end
	--local centered = player.centered_on --- This doesn't work, seems to be only for stuff like alerts, not for just viewing an entity in remote view.
	local selected = player.selected
	if selected == nil or not selected.valid then return end
	local viewedSurface = selected.surface
	if viewedSurface == nil or not viewedSurface.valid then return end
	if not PLANETS[viewedSurface.name] then return end
	local pos = selected.position
	if pos == nil then return end
	global[player.index][viewedSurface.name] = pos
end

-- Get the last map view position we recorded for the given player.
local function getPlayerLastViewPos(player, planet)
	if global == nil then global = {} end
	if global[player.index] == nil then global[player.index] = {} end
	if global[player.index][planet] == nil then return {0, 0} end
	return global[player.index][planet]
end

-- When selected entity changes, set player's last viewed position to that entity's position.
-- This is a workaround for the fact that we can't directly read a player's map position, or just switch to map view at last position like the engine does.
script.on_event(defines.events.on_selected_entity_changed, function(event)
	setPlayerLastViewPos(game.get_player(event.player_index))
end)

-- Create events for each shortcut.
for planet, _ in pairs(PLANETS) do
	script.on_event("PlanetShortcuts-" .. planet, function(event)
		local player = game.get_player(event.player_index)
		if player == nil or not player.valid then return end
		local surface = game.surfaces[planet]
		if surface == nil or not surface.valid then
			log("Player tried to view surface " .. planet .. " using shortcut but it does not exist.")
			return
		end
		if player.force == nil or not player.force.valid then
			log("Player tried to view surface " .. planet .. " using shortcut but force doesn't exist???")
			return
		end
		if player.force.get_surface_hidden(surface) then
			log("Player tried to view surface " .. planet .. " using shortcut but it is hidden for his force.")
			return
		end

		-- Factorio docs says you can use LuaPlayer.open_map or .zoom_to_world, but apparently those don't exist, got removed in 2.0.
		-- Could use player.set_controller, but we need the last position, else it goes to {0,0} on that planet.
		player.set_controller{
			type = defines.controllers.remote,
			surface = planet,
			position = getPlayerLastViewPos(player, planet),
		}
	end)
end