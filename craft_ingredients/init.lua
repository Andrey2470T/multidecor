local modpath = minetest.get_modpath("craft_ingredients")
local S = minetest.get_translator(minetest.get_current_modname())

local bm_modpath = minetest.get_modpath("basic_materials")

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

local to_bm_items_map = {
 	{"metal_bar", "steel_bar"},
	{"plastic_sheet", "plastic_sheet"},
	{"plastic_strip", "plastic_strip"},
	{"metal_wire", "steel_wire"},
	{"metal_chain", "chainlink_steel"},
	{"silver_wire", "silver_wire"},
	{"brass_ingot", "brass_ingot"},
	{"gear", "gear_steel"},
	{"terracotta_fragment", "terracotta_base"}
}

multidecor.craft = {}

function multidecor.craft.register(name, recipe)
	if bm_modpath then
		for _, items_map in ipairs(to_bm_items_map) do
			if items_map[1] == name then
				minetest.register_alias(
					"multidecor:" .. items_map[1], "basic_materials:" .. items_map[2])
				break;
			end
		end
	else
		local register_name = "multidecor:" .. name
		minetest.register_craftitem(":" .. register_name,
		{
			description = S(multidecor.helpers.upper_first_letters(name)),
			inventory_image = "multidecor_" .. name .. ".png"
		})

		local count = type(recipe.count) == "number" and " " .. tostring(recipe.count) or ""
		minetest.register_craft({
			output = register_name .. count,
			type = recipe.type,
			recipe = recipe.recipe,
			replacements = recipe.replacements,
			cooktime = recipe.cooktime
		})
	end
end

multidecor.craft.register("cabinet_door",
{
	recipe = {
		{"multidecor:board", "multidecor:steel_stripe", "multidecor:steel_scissors"},
		{"", "", ""},
		{"", "", ""}
	}
})

multidecor.craft.register("cabinet_half_door",
{
	recipe = {
		{"multidecor:plank", "multidecor:steel_stripe", "multidecor:steel_scissors"},
		{"", "", ""},
		{"", "", ""}
	}
})

multidecor.craft.register("cabinet_half_glass_door",
{
	recipe = {
		{"multidecor:plank", "multidecor:steel_stripe", "multidecor:steel_scissors"},
		{"xpanes:pane_flat", "", ""},
		{"", "", ""}
	}
})

multidecor.craft.register("saw",
{
	type = "shapeless",
	recipe = {"default:stick", "default:stick", "multidecor:steel_sheet"}
})

multidecor.craft.register("wool_cloth",
{
	type = "shapeless",
	count = 7,
	recipe = {"wool:white", "multidecor:steel_scissors"},
	replacements = {{"multidecor:steel_scissors", "multidecor:steel_scissors"}}
})

multidecor.craft.register("metal_bar",
{
	type = "shapeless",
	count = 2,
	recipe = {"default:steel_ingot", "default:steel_ingot", "multidecor:steel_scissors"},
	replacements = {{"multidecor:steel_scissors", "multidecor:steel_scissors"}}
})

if minetest.get_modpath("moreores") then
	minetest.register_craftitem(":multidecor:silver_sheet",
	{
		description = S("Silver Sheet"),
		inventory_image = "multidecor_silver_sheet.png"
	})
end

multidecor.craft.register("steel_sheet",
{
	type = "shapeless",
	count = 5,
	recipe = {"default:steel_ingot", "multidecor:steel_scissors"},
	replacements = {{"multidecor:steel_scissors", "multidecor:steel_scissors"}}
})

multidecor.craft.register("brass_sheet",
{
	type = "shapeless",
	count = 5,
	recipe = {"multidecor:brass_ingot", "multidecor:steel_scissors"},
	replacements = {{"multidecor:steel_scissors", "multidecor:steel_scissors"}}
})

multidecor.craft.register("coarse_steel_sheet",
{
	type = "shapeless",
	recipe = {"multidecor:steel_sheet", "multidecor:scraper"},
	replacements = {{"multidecor:scraper", "multidecor:scraper"}}
})

multidecor.craft.register("steel_scissors",
{
	type = "shapeless",
	recipe = {"default:stick", "default:steel_ingot"}
})

multidecor.craft.register("hammer",
{
	type = "shapeless",
	recipe = {"default:stick", "multidecor:metal_bar"}
})

multidecor.craft.register("bulb",
{
	recipe = {
		{"vessels:glass_bottle", "multidecor:wolfram_wire", ""},
		{"multidecor:steel_stripe", "multidecor:steel_scissors", ""},
		{"", "", ""}
	},
	replacements = {{"multidecor:steel_scissors", "multidecor:steel_scissors"}}
})

multidecor.craft.register("lampshade",
{
	type = "shapeless",
	count = 3,
	recipe = {"wool:white", "multidecor:metal_wire", "multidecor:steel_scissors"},
	replacements = {{"multidecor:steel_scissors", "multidecor:steel_scissors"}}
})

multidecor.craft.register("plastic_sheet",
{
	type = "cooking",
	recipe = "default:leaves",
	cooktime = 10
})

multidecor.craft.register("plastic_strip",
{
	type = "shapeless",
	count = 2,
	recipe = {"multidecor:plastic_sheet", "multidecor:steel_scissors"},
	replacements = {{"multidecor:steel_scissors", "multidecor:steel_scissors"}}
})

multidecor.craft.register("metal_wire",
{
	type = "shapeless",
	count = 5,
	recipe = {"multidecor:metal_bar", "multidecor:steel_scissors"},
	replacements = {{"multidecor:steel_scissors", "multidecor:steel_scissors"}}
})

multidecor.craft.register("metal_chain",
{
	type = "shapeless",
	recipe = {"multidecor:metal_wire", "multidecor:metal_wire", "multidecor:metal_wire"}
})

multidecor.craft.register("four_bulbs_set",
{
	type = "shapeless",
	recipe = {"multidecor:bulb", "multidecor:bulb", "multidecor:bulb", "multidecor:bulb"}
})

multidecor.craft.register("wolfram_wire",
{
	type = "shapeless",
	count = 4,
	recipe = {"multidecor:wolfram_ingot", "multidecor:steel_scissors"},
	replacements = {{"multidecor:steel_scissors", "multidecor:steel_scissors"}}
})

multidecor.craft.register("silver_wire",
{
	type = "shapeless",
	count = 4,
	recipe = {"moreores:silver_ingot", "multidecor:steel_scissors"},
	replacements = {{"multidecor:steel_scissors", "multidecor:steel_scissors"}}
})

multidecor.craft.register("four_lampshades_set",
{
	type = "shapeless",
	recipe = {"multidecor:lampshade", "multidecor:lampshade", "multidecor:lampshade", "multidecor:lampshade"}
})

multidecor.craft.register("digital_dial",
{
	recipe = {
		{"multidecor:plastic_sheet", "dye:white", "dye:black"},
		{"multidecor:steel_scissors", "", ""},
		{"", "", ""}
	},
	replacements = {{"multidecor:steel_scissors", "multidecor:steel_scissors"}}
})

multidecor.craft.register("brass_ingot",
{
	type = "cooking",
	recipe = "multidecor:copper_and_tin",
	cooktime = 8
})

multidecor.craft.register("steel_stripe",
{
	type = "shapeless",
	count = 4,
	recipe = {"multidecor:steel_sheet", "multidecor:steel_scissors"},
	replacements = {{"multidecor:steel_scissors", "multidecor:steel_scissors"}}
})

multidecor.craft.register("brass_stripe",
{
	type = "shapeless",
	count = 4,
	recipe = {"multidecor:brass_sheet", "multidecor:steel_scissors"},
	replacements = {{"multidecor:steel_scissors", "multidecor:steel_scissors"}}
})

multidecor.craft.register("gear",
{
	type = "shapeless",
	recipe = {"multidecor:steel_sheet", "default:tin_ingot", "multidecor:steel_scissors"},
	replacements = {{"multidecor:steel_scissors", "multidecor:steel_scissors"}}
})

multidecor.craft.register("spring",
{
	type = "shapeless",
	recipe = {"multidecor:metal_wire", "multidecor:metal_wire"}
})

multidecor.craft.register("wax_lump",
{
	type = "cooking",
	recipe = "multidecor:oil_source",
	cooktime = 10
})

multidecor.craft.register("wax_candle",
{
	type = "shapeless",
	count = 2,
	recipe = {"multidecor:wax_lump"}
})

multidecor.craft.register("chainlink",
{
	recipe = {
		{"multidecor:metal_wire", "multidecor:metal_wire", "multidecor:metal_wire"},
		{"multidecor:metal_wire", "multidecor:metal_wire", "multidecor:metal_wire"},
		{"multidecor:metal_wire", "multidecor:metal_wire", "multidecor:metal_wire"}
	}
})

multidecor.craft.register("terracotta_fragment",
{
	type = "cooking",
	recipe = "multidecor:clay_and_iron",
	cooktime = 12
})

multidecor.craft.register("porcelain_fragment",
{
	type = "cooking",
	recipe = "multidecor:clay_and_sand",
	cooktime = 15
})

multidecor.craft.register("clay_and_iron",
{
	type = "shapeless",
	recipe = {"default:clay_lump", "default:iron_lump"}
})

multidecor.craft.register("clay_and_sand",
{
	type = "shapeless",
	recipe = {"default:clay_lump", "default:sand"}
})

multidecor.craft.register("copper_and_tin",
{
	type = "shapeless",
	recipe = {"default:copper_ingot", "default:tin_ingot"}
})

multidecor.craft.register("copper_and_zinc",
{
	type = "shapeless",
	recipe = {"default:copper_ingot", "multidecor:zinc_ingot"}
})

multidecor.craft.register("marble_sheet",
{
	type = "shapeless",
	count = 2,
	recipe = {"stairs:slab_marble", "multidecor:hammer"},
	replacements = {{"multidecor:hammer", "multidecor:hammer"}}
})

multidecor.craft.register("syphon",
{
	recipe = {
		{"multidecor:steel_sheet", "multidecor:metal_bar", "multidecor:steel_scissors"},
		{"", "", ""},
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

	minetest.register_craft(
	{
		type = "shapeless",
		output = "multidecor:silver_chain",
		recipe = {"multidecor:metal_chain", "moreores:silver_ingot"}
	})

	minetest.register_craft({
		type = "shapeless",
		output = "multidecor:silver_wire 4",
		recipe = {"multidecor:silver_sheet", "multidecor:steel_scissors"},
		replacements = {{"multidecor:steel_scissors", "multidecor:steel_scissors"}}
	})
end
