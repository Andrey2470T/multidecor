local mp = minetest.get_modpath("modern")

local settings = {
	symbol_item = "multidecor:guide_paper",
}

doclib.create_manual("modern", "EN", settings)

local content
content = dofile(mp .. "/doc/furniture_guide_bathroom_curtains_EN.lua")
doclib.add_to_manual("modern", "EN", content)
content = dofile(mp .. "/doc/furniture_guide_beds_EN.lua")
doclib.add_to_manual("modern", "EN", content)
content = dofile(mp .. "/doc/furniture_guide_books_EN.lua")
doclib.add_to_manual("modern", "EN", content)
content = dofile(mp .. "/doc/furniture_guide_lights_EN.lua")
doclib.add_to_manual("modern", "EN", content)
content = dofile(mp .. "/doc/furniture_guide_painting_EN.lua")
doclib.add_to_manual("modern", "EN", content)
content = dofile(mp .. "/doc/furniture_guide_placement_conditions_EN.lua")
doclib.add_to_manual("modern", "EN", content)
content = dofile(mp .. "/doc/furniture_guide_plastering_EN.lua")
doclib.add_to_manual("modern", "EN", content)
content = dofile(mp .. "/doc/furniture_guide_seats_EN.lua")
doclib.add_to_manual("modern", "EN", content)
content = dofile(mp .. "/doc/furniture_guide_shelves_inventories_EN.lua")
doclib.add_to_manual("modern", "EN", content)
content = dofile(mp .. "/doc/furniture_guide_taps_EN.lua")
doclib.add_to_manual("modern", "EN", content)

minetest.register_node(":multidecor:guide_paper", {
    drawtype = "signlike",
    description = "Furniture Guide Paper",
    inventory_image = "multidecor_furniture_guide_paper.png",
    tiles = {"multidecor_furniture_guide_paper.png"},
    paramtype = "light",
    paramtype2 = "wallmounted",
    collision_box = {
        type = "fixed",
        fixed = {{-0.5, -0.5, -0.5, 0.5, -0.4, 0.5}}
    },
    selection_box = {
        type = "fixed",
        fixed = {{-0.5, -0.5, -0.5, 0.5, -0.4, 0.5}}
    },
    groups = {oddly_breakable_by_hand=1},
    sounds = default.node_sound_wood_defaults(),
    after_place_node = function(pos, placer, itemstack)
        local meta = minetest.get_meta(pos)
        meta:set_string("formspec", doclib.formspec(pos, "modern", "EN"))
    end,
    on_receive_fields = function(pos, formname, fields, player)
		local player_name = player:get_player_name()
		if minetest.is_protected(pos, player_name) then
			return
		end
		minetest.get_meta(pos):set_string("formspec", doclib.formspec(pos, "modern", "EN", fields))
	end,
})

minetest.register_craft({
    recipe = {
        {"default:paper", "multidecor:brass_ingot", "dye:black"},
        {"", "", ""},
        {"", "", ""}
    },
    output = "multidecor:guide_paper"
})

local plans_imgs = {
    ["bathroom_curtains"] = {"img", "multidecor_guide_bathroom_curtains.png", "12,10"},
    ["beds"] = {"img", "multidecor_guide_beds.png", "15,10"},
    ["books"] = {"img", "multidecor_guide_books.png", "15,10"},
    ["lights"] = {"img", "multidecor_guide_lights.png", "10,10"},
    ["painting"] = {"img", "multidecor_guide_painting.png", "13,10"},
    ["plastering"] = {"img", "multidecor_guide_plastering.png", "13,10"},
    ["seats"] = {"img", "multidecor_guide_seats.png", "12,10"},
    ["shelves_inventories"] = {"img", "multidecor_guide_shelves_inventories.png", "13,10"},
    ["taps"] = {"img", "multidecor_guide_taps.png", "10,10"},
}

for name, img in pairs(plans_imgs) do
    local plan = {
        {img, false, false, false},
	    {false, false, false, false},
	    {false, false, false, false},
	    {false, false, false, false},
	    {false, false, false, false},
	    {false, false, false, false}
    }
    doclib.add_manual_plan("modern", "EN", name, plan)
end