multidecor.tools_sounds = {}

-- Predefined sounds for these tools
multidecor.tools_sounds.sounds = {
	{name="saw", durability=3},
	{name="steel_scissors", durability=2},
	{name="hammer", durability=1},
	{name="scraping", durability=4}
}

-- Maps a playername to the current playing tool sound
multidecor.tools_sounds.current_sounds = {}

-- Plays some locationless sound having 'sound_index' in 'multidecor.tools_sounds.sounds' table
-- for player 'playername'
function multidecor.tools_sounds.play(playername, sound_index)
	if multidecor.tools_sounds.current_sounds[playername] then
		return
	end

	if not multidecor.tools_sounds.sounds[sound_index] then
		return
	end

	local sound = multidecor.tools_sounds.sounds[sound_index]
	multidecor.tools_sounds.current_sounds[playername] = {
		name = sound.name,
		cur_time = 0.0,
		durability = sound.durability
	}

	minetest.sound_play("multidecor_" .. sound.name, {to_player=playername})
end

minetest.register_on_craft(function(itemstack, player, old_craft_grid, craft_inv)
	local sound_index

	local function check_for_item(itemname)
		for i, sound in pairs(multidecor.tools_sounds.sounds) do
			if "multidecor:" .. sound.name == itemname then
				sound_index = i
				break
			end
		end
	end

	for _, stack in ipairs(old_craft_grid) do
		check_for_item(stack:get_name())
		if sound_index ~= nil then
			break
		end
	end

	if sound_index ~= nil then
		multidecor.tools_sounds.play(player:get_player_name(), sound_index)
	end

	return
end)

minetest.register_globalstep(function(dtime)
	for _, player in ipairs(minetest.get_connected_players()) do
		local playername = player:get_player_name()
		local cur_sound = multidecor.tools_sounds.current_sounds[playername]

		if cur_sound then
			cur_sound.cur_time = cur_sound.cur_time + dtime

			if cur_sound.cur_time >= cur_sound.durability then
				multidecor.tools_sounds.current_sounds[playername] = nil
			end
		end
	end
end)

