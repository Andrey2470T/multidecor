local modpath = minetest.get_modpath("craft_ingredients")

dofile(modpath .. "/ores.lua")


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
	local t2 = table.copy(t)
	for i, item_n in ipairs(t2) do
		if type(item_n) == "table" then
			for i2, item_n2 in ipairs(item_n) do
				t2[i][i2] = item_n2:format(wood)
			end
		else
			t2[i] = item_n:format(wood)
		end
	end

	return t2
end

for _, wood in ipairs(woods) do
	wood = wood ~= "" and wood ~= "jungle" and wood .. "_" or wood
	local to_capital_l = wood ~= "" and wood:sub(1,1):upper() .. wood:sub(2, -2) .. " " or ""

	for item, recipes in pairs(items_and_crafts) do
		minetest.register_craftitem(":multidecor:" .. wood .. item,
		{
			description = to_capital_l .. item:sub(1,1):upper() .. item:sub(2),
			inventory_image = "multidecor_" .. (wood == "jungle" and wood .. "_" or wood) .. item .. ".png"
		})

		for _, recipe in ipairs(recipes) do
			local def = {
				type = recipe.type,
				output = "multidecor:" .. wood .. item .. " " .. recipe.amount,
				recipe = format_nested_strings(recipe.recipe, wood),
				replacements = recipe.type == "shapeless" and {{"multidecor:saw", "multidecor:saw"}} or nil
			}
			minetest.register_craft(def)
		end
	end
end

minetest.register_craftitem(":multidecor:saw",
{
	description = "Saw",
	inventory_image = "multidecor_saw.png"
})

minetest.register_craftitem(":multidecor:metal_bar",
{
	description = "Metal Bar",
	inventory_image = "multidecor_metal_bar.png"
})

minetest.register_craftitem(":multidecor:steel_sheet",
{
	description = "Steel Sheet",
	inventory_image = "multidecor_steel_sheet.png"
})

minetest.register_craftitem(":multidecor:steel_scissors",
{
	description = "Steel Scissors",
	inventory_image = "multidecor_steel_scissors.png"
})

minetest.register_craftitem(":multidecor:bulb",
{
	description = "Bulb",
	inventory_image = "multidecor_bulb.png"
})

minetest.register_craftitem(":multidecor:lampshade",
{
	description = "Lampshade",
	inventory_image = "multidecor_lampshade.png"
})

minetest.register_craftitem(":multidecor:plastic_sheet",
{
	description = "Plastic Sheet",
	inventory_image = "multidecor_plastic_sheet.png"
})

minetest.register_craftitem(":multidecor:metal_wire",
{
	description = "Metal Wire",
	inventory_image = "multidecor_metal_wire.png"
})

minetest.register_craftitem(":multidecor:metal_chain",
{
	description = "Chain",
	inventory_image = "multidecor_chain.png"
})

minetest.register_craftitem(":multidecor:four_bulbs_set",
{
	description = "Set from four bulbs",
	inventory_image = "multidecor_four_bulbs_set.png"
})

minetest.register_craftitem(":multidecor:wolfram_wire",
{
	description = "Wolfram Wire",
	inventory_image = "multidecor_wolfram_wire.png"
})

minetest.register_craftitem(":multidecor:silver_wire",
{
	description = "Silver Wire",
	inventory_image = "multidecor_silver_wire.png"
})

minetest.register_craftitem(":multidecor:four_lampshades_set",
{
	description = "Set from four lampshades",
	inventory_image = "multidecor_four_lampshades_set.png"
})

minetest.register_craftitem(":multidecor:digital_dial",
{
	description = "Digital Dial",
	inventory_image = "multidecor_digital_dial.png"
})

minetest.register_craftitem(":multidecor:brass_ingot",
{
	description = "Brass Ingot",
	inventory_image = "multidecor_brass_ingot.png"
})

minetest.register_craftitem(":multidecor:gear",
{
	description = "Gear",
	inventory_image = "multidecor_gear.png"
})

minetest.register_craftitem(":multidecor:spring",
{
	description = "Spring",
	inventory_image = "multidecor_spring.png"
})

minetest.register_craft(
{
	type = "shapeless",
	output = "multidecor:steel_sheet 5",
	recipe = {"default:steel_ingot", "multidecor:steel_scissors"},
	replacements = {{"multidecor:steel_scissors", "multidecor:steel_scissors"}}
})

minetest.register_craft(
{
	type = "shapeless",
	output = "multidecor:metal_bar 2",
	recipe = {"default:steel_ingot", "default:steel_ingot", "multidecor:steel_scissors"},
	replacements = {{"multidecor:steel_scissors", "multidecor:steel_scissors"}}
})

minetest.register_craft(
{
	type = "shapeless",
	output = "multidecor:saw",
	recipe = {"multidecor:plank", "multidecor:steel_sheet"}
})

minetest.register_craft(
{
	type = "shapeless",
	output = "multidecor:steel_scissors",
	recipe = {"multidecor:plank", "default:steel_ingot"}
})

minetest.register_craft(
{
	type = "shapeless",
	output = "multidecor:lampshade 3",
	recipe = {"wool:white", "multidecor:metal_wire"}
})

minetest.register_craft({
    type = "cooking",
    output = "multidecor:plastic_sheet",
    recipe = "default:leaves",
	cooktime = 10
})

if minetest.get_modpath("moreores") then
	minetest.register_craft(
	{
		type = "shapeless",
		output = "multidecor:silver_chain 3",
		recipe = {"multidecor:metal_bar", "moreores:silver_ingot", "multidecor:steel_scissors"},
		replacements = {{"multidecor:steel_scissors", "multidecor:steel_scissors"}}
	})

	minetest.register_craft({
		type = "shapeless",
		output = "multidecor:silver_wire 4",
		recipe = {"moreores:silver_ingot", "multidecor:steel_scissors"},
		replacements = {{"multidecor:steel_scissors", "multidecor:steel_scissors"}}
	})
end

minetest.register_craft({
	output = "multidecor:bulb",
	recipe = {
		{"vessels:glass_bottle", "multidecor:wolfram_wire", ""},
		{"multidecor:steel_sheet", "multidecor:steel_scissors", ""},
		{"", "", ""}
	},
	replacements = {{"multidecor:steel_scissors", "multidecor:steel_scissors"}}
})

minetest.register_craft({
	type = "shapeless",
	output = "multidecor:four_bulbs_set",
	recipe = {"multidecor:bulb", "multidecor:bulb", "multidecor:bulb", "multidecor:bulb"}
})

minetest.register_craft({
	type = "shapeless",
	output = "multidecor:metal_wire 5",
	recipe = {"multidecor:metal_bar", "multidecor:steel_scissors"},
	replacements = {{"multidecor:steel_scissors", "multidecor:steel_scissors"}}
})

minetest.register_craft({
	type = "shapeless",
	output = "multidecor:wolfram_wire 4",
	recipe = {"multidecor:wolfram_ingot", "multidecor:steel_scissors"},
	replacements = {{"multidecor:steel_scissors", "multidecor:steel_scissors"}}
})

minetest.register_craft({
	type = "shapeless",
	output = "multidecor:metal_chain",
	recipe = {"multidecor:metal_wire", "multidecor:metal_wire"}
})

minetest.register_craft({
	type = "shapeless",
	output = "multidecor:four_lampshades_set",
	recipe = {"multidecor:lampshade", "multidecor:lampshade", "multidecor:lampshade", "multidecor:lampshade"}
})

minetest.register_craft({
	type = "shapeless",
	output = "multidecor:brass_ingot",
	recipe = {"default:copper_ingot", "multidecor:zinc_ingot"}
})

minetest.register_craft({
	type = "shapeless",
	output = "multidecor:brass_ingot",
	recipe = {"default:copper_ingot", "default:tin_ingot"}
})

minetest.register_craft({
	output = "multidecor:digital_dial",
	recipe = {
		{"multidecor:plastic_sheet", "dye:white", "dye:black"},
		{"multidecor:steel_scissors", "", ""},
		{"", "", ""}
	},
	replacements = {{"multidecor:steel_scissors", "multidecor:steel_scissors"}}
})

minetest.register_craft({
	type = "shapeless",
	output = "multidecor:gear",
	recipe = {"multidecor:steel_sheet", "default:tin_ingot", "multidecor:steel_scissors"},
	replacements = {{"multidecor:steel_scissors", "multidecor:steel_scissors"}}
})

minetest.register_craft({
	type = "shapeless",
	output = "multidecor:spring",
	recipe = {"multidecor:metal_wire", "multidecor:metal_wire"}
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

	for _, stack in ipairs(old_craft_grid) do
		check_for_item(stack:get_name())
		if contains_saw or contains_steel_scissors then
			break
		end
	end

	local sound = contains_saw and "multidecor_saw" or contains_steel_scissors and "multidecor_steel_scissors"
	if sound then
		minetest.sound_play(sound, {to_player = player:get_player_name()})
	end

	return
end)
