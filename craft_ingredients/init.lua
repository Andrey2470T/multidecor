local modpath = minetest.get_modpath("craft_ingredients")
local S = minetest.get_translator(minetest.get_current_modname())

dofile(modpath .. "/ores.lua")

local woods = {"", "jungle", "aspen", "pine"}

if minetest.get_modpath("ethereal") then
	table.insert(woods, "redwood")
end

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
			description = S(to_capital_l .. item:sub(1,1):upper() .. item:sub(2)),
			inventory_image = "multidecor_" .. (wood == "jungle" and wood .. "_" or wood) .. item .. ".png"
		})

		for i, recipe in ipairs(recipes) do
			local recipe_c = table.copy(recipe)

			if wood == "redwood_" and item == "board" then
				if i == 1 then
					recipe_c.recipe[1] = "ethereal:%swood"
				end
			end
			recipe_c.recipe = format_nested_strings(recipe_c.recipe, wood)

			local def = {
				type = recipe_c.type,
				output = "multidecor:" .. wood .. item .. " " .. recipe_c.amount,
				recipe = recipe_c.recipe,
				replacements = recipe_c.type == "shapeless" and {{"multidecor:saw", "multidecor:saw"}} or nil
			}
			minetest.register_craft(def)
		end
	end
end

bucket.register_liquid(
	"multidecor:oil_source",
	"multidecor:oil_flowing",
	"craft_ingredients:oil_bucket",
	"multidecor_oil_bucket.png",
	"Oil Bucket",
	nil,
	true
)

minetest.register_node(":multidecor:marble_block", {
	description = S("Marble Block"),
	paramtype = "light",
	paramtype2 = "none",
	sunlight_propagates = true,
	tiles = {"multidecor_marble_material.png^[sheet:2x2:0,0"},
	groups = {cracky=2.5},
	sounds = default.node_sound_stone_defaults()
})


minetest.register_craftitem(":multidecor:cabinet_door",
{
	description = S("Cabinet Door"),
	inventory_image = "multidecor_cabinet_door.png"
})

minetest.register_craftitem(":multidecor:cabinet_half_door",
{
	description = S("Cabinet Half Door"),
	inventory_image = "multidecor_cabinet_half_door.png"
})

minetest.register_craftitem(":multidecor:cabinet_half_glass_door",
{
	description = S("Cabinet Half Glass Door"),
	inventory_image = "multidecor_cabinet_half_glass_door.png"
})

minetest.register_craftitem(":multidecor:saw",
{
	description = S("Saw"),
	inventory_image = "multidecor_saw.png"
})

minetest.register_craftitem(":multidecor:wool_cloth",
{
	description = S("Wool Cloth"),
	inventory_image = "multidecor_wool_cloth.png"
})

minetest.register_craftitem(":multidecor:metal_bar",
{
	description = S("Metal Bar"),
	inventory_image = "multidecor_metal_bar.png"
})

if minetest.get_modpath("moreores") then
	minetest.register_craftitem(":multidecor:silver_sheet",
	{
		description = S("Silver Sheet"),
		inventory_image = "multidecor_silver_sheet.png"
	})
end

minetest.register_craftitem(":multidecor:steel_sheet",
{
	description = S("Steel Sheet"),
	inventory_image = "multidecor_steel_sheet.png"
})

minetest.register_craftitem(":multidecor:brass_sheet",
{
	description = S("Brass Sheet"),
	inventory_image = "multidecor_brass_sheet.png"
})

minetest.register_craftitem(":multidecor:coarse_steel_sheet",
{
	description = S("Coarse Steel Sheet"),
	inventory_image = "multidecor_coarse_steel_sheet.png"
})

minetest.register_craftitem(":multidecor:steel_scissors",
{
	description = S("Steel Scissors"),
	inventory_image = "multidecor_steel_scissors.png"
})

minetest.register_craftitem(":multidecor:hammer",
{
	description = S("Hammer"),
	inventory_image = "multidecor_hammer.png"
})

minetest.register_craftitem(":multidecor:bulb",
{
	description = S("Bulb"),
	inventory_image = "multidecor_bulb.png"
})

minetest.register_craftitem(":multidecor:lampshade",
{
	description = S("Lampshade"),
	inventory_image = "multidecor_lampshade.png"
})

minetest.register_craftitem(":multidecor:plastic_sheet",
{
	description = S("Plastic Sheet"),
	inventory_image = "multidecor_plastic_sheet.png"
})

minetest.register_craftitem(":multidecor:plastic_strip",
{
	description = S("Plastic Strip"),
	inventory_image = "multidecor_plastic_strip.png"
})

minetest.register_craftitem(":multidecor:metal_wire",
{
	description = S("Metal Wire"),
	inventory_image = "multidecor_metal_wire.png"
})

minetest.register_craftitem(":multidecor:metal_chain",
{
	description = S("Chain"),
	inventory_image = "multidecor_chain.png"
})

minetest.register_craftitem(":multidecor:four_bulbs_set",
{
	description = S("Set from four bulbs"),
	inventory_image = "multidecor_four_bulbs_set.png"
})

minetest.register_craftitem(":multidecor:wolfram_wire",
{
	description = S("Wolfram Wire"),
	inventory_image = "multidecor_wolfram_wire.png"
})

minetest.register_craftitem(":multidecor:silver_wire",
{
	description = S("Silver Wire"),
	inventory_image = "multidecor_silver_wire.png"
})

minetest.register_craftitem(":multidecor:four_lampshades_set",
{
	description = S("Set from four lampshades"),
	inventory_image = "multidecor_four_lampshades_set.png"
})

minetest.register_craftitem(":multidecor:digital_dial",
{
	description = S("Digital Dial"),
	inventory_image = "multidecor_digital_dial.png"
})

minetest.register_craftitem(":multidecor:brass_ingot",
{
	description = S("Brass Ingot"),
	inventory_image = "multidecor_brass_ingot.png"
})

minetest.register_craftitem(":multidecor:steel_stripe",
{
	description = S("Steel Stripe"),
	inventory_image = "multidecor_steel_stripe.png"
})

minetest.register_craftitem(":multidecor:brass_stripe",
{
	description = S("Brass Stripe"),
	inventory_image = "multidecor_brass_stripe.png"
})

minetest.register_craftitem(":multidecor:gear",
{
	description = S("Gear"),
	inventory_image = "multidecor_gear.png"
})

minetest.register_craftitem(":multidecor:spring",
{
	description = S("Spring"),
	inventory_image = "multidecor_spring.png"
})

minetest.register_craftitem(":multidecor:wax_lump",
{
	description = S("Wax Lump"),
	inventory_image = "multidecor_wax_lump.png"
})

minetest.register_craftitem(":multidecor:wax_candle",
{
	description = S("Wax Candle"),
	inventory_image = "multidecor_wax_candle.png"
})

minetest.register_craftitem(":multidecor:chainlink",
{
	description = S("Chainlink"),
	inventory_image = "multidecor_chainlink.png"
})

minetest.register_craftitem(":multidecor:terracotta_fragment",
{
	description = S("Terracotta Fragment"),
	inventory_image = "multidecor_terracotta_fragment.png"
})

minetest.register_craftitem(":multidecor:copper_and_tin",
{
	description = S("Copper And Tin"),
	inventory_image = "multidecor_copper_and_tin.png"
})

minetest.register_craftitem(":multidecor:copper_and_zinc",
{
	description = S("Copper And Zinc"),
	inventory_image = "multidecor_copper_and_zinc.png"
})

minetest.register_craftitem(":multidecor:marble_sheet",
{
	description = S("Marble Sheet"),
	inventory_image = "multidecor_marble_sheet.png"
})

minetest.register_craftitem(":multidecor:syphon",
{
	description = S("Syphon"),
	inventory_image = "multidecor_syphon.png"
})

minetest.register_craft({
	output = "multidecor:cabinet_door",
	recipe = {
		{"multidecor:board", "multidecor:steel_stripe", "multidecor:steel_scissors"},
		{"", "", ""},
		{"", "", ""}
	}
})

minetest.register_craft({
	output = "multidecor:cabinet_half_door",
	recipe = {
		{"multidecor:plank", "multidecor:steel_stripe", "multidecor:steel_scissors"},
		{"", "", ""},
		{"", "", ""}
	}
})

minetest.register_craft({
	output = "multidecor:cabinet_half_glass_door",
	recipe = {
		{"multidecor:plank", "multidecor:steel_stripe", "multidecor:steel_scissors"},
		{"xpanes:pane_flat", "", ""},
		{"", "", ""}
	}
})

if minetest.get_modpath("moreores") then
	minetest.register_craft(
	{
		type = "shapeless",
		output = "multidecor:silver_sheet 5",
		recipe = {"moreores:silver_ingot", "multidecor:steel_scissors"},
		replacements = {{"multidecor:steel_scissors", "multidecor:steel_scissors"}}
	})
end

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
	output = "multidecor:brass_sheet 5",
	recipe = {"multidecor:brass_ingot", "multidecor:steel_scissors"},
	replacements = {{"multidecor:steel_scissors", "multidecor:steel_scissors"}}
})

minetest.register_craft(
{
	type = "shapeless",
	output = "multidecor:coarse_steel_sheet",
	recipe = {"multidecor:steel_sheet", "multidecor:scraper"},
	replacements = {{"multidecor:scraper", "multidecor:scraper"}}
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
	recipe = {"default:stick", "default:stick", "multidecor:steel_sheet"}
})

minetest.register_craft(
{
	type = "shapeless",
	output = "multidecor:wool_cloth 7",
	recipe = {"wool:white", "multidecor:steel_scissors"},
	replacements = {{"multidecor:steel_scissors", "multidecor:steel_scissors"}}
})

minetest.register_craft(
{
	type = "shapeless",
	output = "multidecor:steel_scissors",
	recipe = {"default:stick", "default:steel_ingot"}
})

minetest.register_craft(
{
	type = "shapeless",
	output = "multidecor:hammer",
	recipe = {"default:stick", "multidecor:metal_bar"}
})

minetest.register_craft(
{
	type = "shapeless",
	output = "multidecor:wax_candle 2",
	recipe = {"multidecor:wax_lump"}
})

minetest.register_craft(
{
	type = "shapeless",
	output = "multidecor:lampshade 3",
	recipe = {"wool:white", "multidecor:metal_wire", "multidecor:steel_scissors"},
	replacements = {{"multidecor:steel_scissors", "multidecor:steel_scissors"}}
})

minetest.register_craft({
    type = "cooking",
    output = "multidecor:plastic_sheet",
    recipe = "default:leaves",
	cooktime = 10
})

minetest.register_craft({
    type = "shapeless",
    output = "multidecor:plastic_strip 2",
    recipe = {"multidecor:plastic_sheet"}
})

minetest.register_craft({
	type = "shapeless",
	output = "multidecor:terracotta_fragment 4",
	recipe = {"default:clay_brick", "multidecor:hammer"},
	replacements = {{"multidecor:hammer", "multidecor:hammer"}}
})

minetest.register_craft(
{
	type = "shapeless",
	output = "multidecor:copper_and_tin",
	recipe = {"default:copper_ingot", "default:tin_ingot"}
})

minetest.register_craft(
{
	type = "shapeless",
	output = "multidecor:copper_and_zinc",
	recipe = {"default:copper_ingot", "multidecor:zinc_ingot"}
})

if minetest.get_modpath("moreores") then
	minetest.register_craft(
	{
		type = "shapeless",
		output = "multidecor:silver_chain",
		recipe = {"multidecor:metal_chain", "moreores:silver_ingot"}
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
		{"multidecor:steel_stripe", "multidecor:steel_scissors", ""},
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
	recipe = {"multidecor:metal_wire", "multidecor:metal_wire", "multidecor:metal_wire"}
})

minetest.register_craft({
	type = "shapeless",
	output = "multidecor:four_lampshades_set",
	recipe = {"multidecor:lampshade", "multidecor:lampshade", "multidecor:lampshade", "multidecor:lampshade"}
})

minetest.register_craft({
	type = "cooking",
	output = "multidecor:brass_ingot",
	recipe = "multidecor:copper_and_tin",
	cooktime = 8
})

minetest.register_craft({
	type = "shapeless",
	output = "multidecor:steel_stripe 4",
	recipe = {"multidecor:steel_sheet", "multidecor:steel_scissors"},
	replacements = {{"multidecor:steel_scissors", "multidecor:steel_scissors"}}
})

minetest.register_craft({
	type = "shapeless",
	output = "multidecor:brass_stripe 4",
	recipe = {"multidecor:brass_sheet", "multidecor:steel_scissors"},
	replacements = {{"multidecor:steel_scissors", "multidecor:steel_scissors"}}
})

minetest.register_craft({
	type = "cooking",
	output = "multidecor:oil_source",
	recipe = "multidecor:consolidated_oil",
	cooktime = 5
})

minetest.register_craft({
	type = "cooking",
	output = "multidecor:wax_lump",
	recipe = "multidecor:oil_source",
	cooktime = 10
})

minetest.register_craft({
	type = "cooking",
	output = "multidecor:brass_ingot",
	recipe = "multidecor:copper_and_zinc",
	cooktime = 9
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

minetest.register_craft({
	output = "multidecor:chainlink",
	recipe = {
		{"multidecor:metal_wire", "multidecor:metal_wire", "multidecor:metal_wire"},
		{"multidecor:metal_wire", "multidecor:metal_wire", "multidecor:metal_wire"},
		{"multidecor:metal_wire", "multidecor:metal_wire", "multidecor:metal_wire"}
	}
})

minetest.register_craft({
	type = "shapeless",
	output = "multidecor:marble_block",
	recipe = {"default:clay", "default:silver_sandstone", "default:coal_lump"}
})

minetest.register_craft({
	type = "shapeless",
	output = "multidecor:marble_sheet 2",
	recipe = {"stairs:slab_marble", "multidecor:hammer"},
	replacements = {{"multidecor:hammer", "multidecor:hammer"}}
})

minetest.register_craft({
	output = "multidecor:syphon",
	recipe = {
		{"multidecor:steel_sheet", "multidecor:metal_bar", "multidecor:steel_scissors"},
		{"", "", ""},
		{"", "", ""}
	}
})
