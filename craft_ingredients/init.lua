local woods = {"", "jungle", "aspen", "pine"}
local items_and_crafts = {
	["board"] = {
		{
			amount = 4,
			type = "shapeless",
			recipe = {"default:%swood", "multidecor:saw"}
        },
		{
			amount = 2,
			type = "shapeless",
			recipe = {"stairs:slab_%swood", "multidecor:saw"}
		}
	},
	["plank"] = {
		{
			amount = 2,
			type = "shapeless",
			recipe = {"multidecor:%sboard", "multidecor:saw"}
		}
	},
	["drawer"] = {
		{
			amount = 1,
			recipe = {
				{"multidecor:%splank", "multidecor:%splank", "multidecor:%splank"},
				{"multidecor:%splank", "multidecor:%sboard", ""},
				{"", "", ""}
			}
		}
	}
}

local format_nested_strings = function(t, wood)
	for i, item_n in ipairs(t) do
		if type(item_n) == "table" then
			for i2, item_n2 in ipairs(item_n) do
				t[i][i2] = item_n2:format(wood)
			end
		else
			t[i] = item_n:format(wood)
		end
	end
end

for _, wood in ipairs(woods) do
	wood = wood ~= "" and wood .. "_" or wood
	to_capital_l = wood ~= "" and wood:sub(1,1):upper() .. wood:sub(2) or ""

	for item, recipes in pairs(items_and_crafts) do
		minetest.debug("item: " .. dump(item))
		minetest.register_craftitem(":multidecor:" .. wood .. item,
		{
			description = to_capital_l .. " " .. item:sub(1,1):upper() .. item:sub(2),
			inventory_image = "multidecor_" .. wood .. item .. ".png"
		})

		for _, recipe in ipairs(recipes) do
			minetest.register_craft({
				type = recipe.type,
				output = "multidecor:" .. wood .. item .. " " .. recipe.amount,
				recipe = format_nested_strings(recipe.recipe, wood),
				replacements = recipe.type == "shapeless" and {{recipe.recipe[1]:format(wood), ""}, {"multidecor:saw", "multidecor:saw"}}
			})
		end
	end
end

minetest.register_craftitem("multidecor:saw",
{
	description = "Saw",
	inventory_image = "multidecor_saw.png"
})

minetest.register_craftitem("multidecor:metal_bar",
{
	description = "Metal Bar",
	inventory_image = "multidecor_metal_bar.png"
})

minetest.register_craftitem("multidecor:steel_sheet",
{
	description = "Steel Sheet",
	inventory_image = "multidecor_sheet.png"
})

minetest.register_craftitem("multidecor:steel_scissors",
{
	description = "Steel Scissors",
	inventory_image = "multidecor_steel_scissors.png"
})

minetest.register_craft(
{
	type = "shapeless",
	output = "multidecor:steel_sheet",
	recipe = {"default:steel_ingot", "multidecor:steel_scissors"},
	replacements = {{"default:steel_ingot", ""}, {"multidecor:steel_scissors", "multidecor:steel_scissors"}}
})

minetest.register_craft(
{
	output = "multidecor:metal_bar",
	recipe = {
		{"", "default:steel_ingot", ""},
		{"", "default:steel_ingot", ""},
		{"", "", ""}
	}
})

minetest.register_craft(
{
	output = "multidecor:saw",
	recipe = {
		{"multidecor:plank", "multidecor:steel_sheet", "multidecor:saw"},
		{"", "", ""},
		{"", "", ""}
	},
	replacements = {
		{{"multidecor:plank", ""}, {"multidecor:steel_sheet", ""}, {"multidecor:saw", "multidecor:saw"}},
		{{"", ""}, {"", ""}, {"", ""}},
		{{"", ""}, {"", ""}, {"", ""}}
	}
})

minetest.register_craft(
{
	output = "multidecor:steel_scissors",
	recipe = {
		{"multidecor:plank", "default:steel_ingot", "multidecor:saw"},
		{"", "", ""},
		{"", "", ""}
	},
	replacements = {
		{{"multidecor:plank", ""}, {"default:steel_ingot", ""}, {"multidecor:saw", "multidecor:saw"}},
		{{"", ""}, {"", ""}, {"", ""}},
		{{"", ""}, {"", ""}, {"", ""}}
	}
})


minetest.register_on_craft(function(itemstack, player, old_craft_grid, craft_inv)
	local contains_saw = false
	local contains_steel_scissors = false

	local function check_for_item(item)
		if item == "multidecor:saw" then
			contains_saw = true
			return
		end
		if item == "multidecor:steel_scissors" then
			contains_steel_scissors = true
			return
		end
	end
	for _, item in ipairs(old_craft_grid) do
		if contains_saw or contains_steel_scissors then
			break
		end
		if type(item) == "table" then
			for _, item2 in ipairs(item) do
				if contains_saw or contains_steel_scissors then
					break
				end
				check_for_item(item2)
			end
		else
			check_for_item(item)
		end
	end

	local sound = contains_saw and "multidecor_saw.ogg" or contains_steel_scissors and "multidecor_steel_scissors.ogg"

	if sound then
		minetest.sound_play(sound, {to_player = player:get_player_name()})
	end
end)
