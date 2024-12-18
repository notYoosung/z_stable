local S = minetest.get_translator(minetest.get_current_modname())
local C = minetest.colorize
local F = minetest.formspec_escape

local dropper_formspec = table.concat({
    "formspec_version[4]",
    "size[11.75,10.425]",

    "label[4.125,0.375;" .. F(C(mcl_formspec.label_color, S("Dropper"))) .. "]",

    mcl_formspec.get_itemslot_bg_v4(4.125, 0.75, 3, 3),
    "list[context;main;4.125,0.75;3,3;]",

    "label[0.375,4.7;" .. F(C(mcl_formspec.label_color, S("Inventory"))) .. "]",

    mcl_formspec.get_itemslot_bg_v4(0.375, 5.1, 9, 3),
    "list[current_player;main;0.375,5.1;9,3;9]",

    mcl_formspec.get_itemslot_bg_v4(0.375, 9.05, 9, 1),
    "list[current_player;main;0.375,9.05;9,1;]",

    "listring[context;main]",
    "listring[current_player;main]",
})


local function setup_dropper(pos)
    
    local meta = minetest.get_meta(pos)
    meta:set_string("formspec", dropper_formspec)
    local inv = meta:get_inventory()
    inv:set_size("main", 9)
end

local function orientate_dropper(pos, placer)
    
    if not placer then return end

    
    local pitch = placer:get_look_vertical() * (180 / math.pi)

    if pitch > 55 then
        minetest.swap_node(pos, { name = "scp:creative_dropper_up" })
    elseif pitch < -55 then
        minetest.swap_node(pos, { name = "scp:creative_dropper_down" })
    end
end

local on_rotate
if minetest.get_modpath("screwdriver") then
    on_rotate = screwdriver.rotate_simple
end


local dropperdef = {
    is_ground_content = false,
    sounds = mcl_sounds.node_sound_stone_defaults(),
    after_dig_node = mcl_util.drop_items_from_meta_container({ "main" }),
    allow_metadata_inventory_move = function(pos, _, _, _, _, count, player)
        local name = player:get_player_name()
        if minetest.is_protected(pos, name) then
            minetest.record_protection_violation(pos, name)
            return 0
        else
            return count
        end
    end,
    allow_metadata_inventory_take = function(pos, _, _, stack, player)
        local name = player:get_player_name()
        if minetest.is_protected(pos, name) then
            minetest.record_protection_violation(pos, name)
            return 0
        else
            return stack:get_count()
        end
    end,
    allow_metadata_inventory_put = function(pos, _, _, stack, player)
        local name = player:get_player_name()
        if minetest.is_protected(pos, name) then
            minetest.record_protection_violation(pos, name)
            return 0
        else
            return stack:get_count()
        end
    end,
    _mcl_blast_resistance = 3.5,
    _mcl_hardness = 3.5,
    mesecons = {
        effector = {
            
            action_on = function(pos, node)
                local meta = minetest.get_meta(pos)
                local inv = meta:get_inventory()
                local droppos
                if node.name == "scp:creative_dropper" then
                    droppos = vector.subtract(pos, minetest.facedir_to_dir(node.param2))
                elseif node.name == "scp:creative_dropper_up" then
                    droppos = vector.offset(pos, 0, 1, 0)
                elseif node.name == "scp:creative_dropper_down" then
                    droppos = vector.offset(pos, 0, -1, 0)
                end
                local dropnode = minetest.get_node(droppos)
                
                local dropnodedef = minetest.registered_nodes[dropnode.name]
                if dropnodedef.walkable and not dropnodedef.groups.container then
                    return
                end
                local stacks = {}
                for i = 1, inv:get_size("main") do
                    local stack = inv:get_stack("main", i)
                    if not stack:is_empty() then
                        table.insert(stacks, { stack = stack, stackpos = i })
                    end
                end
                if #stacks >= 1 then
                    local r = math.random(1, #stacks)
                    local stack = stacks[r].stack
                    local dropitem = ItemStack(stack)
                    dropitem:set_count(1)
                    local stack_id = stacks[r].stackpos

                    
                    local dropped = mcl_util.move_item_container(pos, droppos, nil, stack_id)
                    
                    if not dropped and not dropnodedef.groups.container then
                        
                        local pos_variation = 100
                        droppos = vector.offset(droppos,
                            math.random(-pos_variation, pos_variation) / 1000,
                            math.random(-pos_variation, pos_variation) / 1000,
                            math.random(-pos_variation, pos_variation) / 1000
                        )
                        local item_entity = minetest.add_item(droppos, dropitem)
                        local drop_vel = vector.subtract(droppos, pos)
                        local speed = 3
                        item_entity:set_velocity(vector.multiply(drop_vel, speed))
                        inv:set_stack("main", stack_id, stack)
                    end
                end
            end,
            rules = mesecon.rules.alldirs,
        }
    },
    on_rotate = on_rotate,
}



local horizontal_def = table.copy(dropperdef)
horizontal_def.description = S("Creative Dropper")
horizontal_def._tt_help = S("9 inventory slots") .. "\n" .. S("Drops item when powered by redstone power")
horizontal_def._doc_items_longdesc = S(
"A dropper is a redstone component and a container with 9 inventory slots which, when supplied with redstone power, drops an item or puts it into a container in front of it.")
horizontal_def._doc_items_usagehelp = S(
"Droppers can be placed in 6 possible directions, items will be dropped out of the hole. Use the dropper to access its inventory. Supply it with redstone energy once to make the dropper drop or transfer a random item.")
function horizontal_def.after_place_node(pos, placer, _, _)
    setup_dropper(pos)
    orientate_dropper(pos, placer)
end

horizontal_def.tiles = {
    "default_furnace_top.png", "default_furnace_bottom.png",
    "default_furnace_side.png", "default_furnace_side.png",
    "default_furnace_side.png", "mcl_droppers_dropper_front_horizontal.png"
}
horizontal_def.paramtype2 = "facedir"
horizontal_def.groups = { dig_immediate = 3, pickaxey = 1, container = 2, material_stone = 1 }

minetest.register_node(":scp:creative_dropper", horizontal_def)


local down_def = table.copy(dropperdef)
down_def.description = S("Downwards-Facing Creative Dropper")
down_def.after_place_node = setup_dropper
down_def.tiles = {
    "default_furnace_top.png", "mcl_droppers_dropper_front_vertical.png",
    "default_furnace_side.png", "default_furnace_side.png",
    "default_furnace_side.png", "default_furnace_side.png"
}
down_def.groups = { dig_immediate = 3, pickaxey = 1, container = 2, not_in_creative_inventory = 1, material_stone = 1 }
down_def._doc_items_create_entry = false
down_def.drop = "scp:creative_dropper"
minetest.register_node(":scp:creative_dropper_down", down_def)



local up_def = table.copy(down_def)
up_def.description = S("Upwards-Facing Creative Dropper")
up_def.tiles = {
    "mcl_droppers_dropper_front_vertical.png", "default_furnace_bottom.png",
    "default_furnace_side.png", "default_furnace_side.png",
    "default_furnace_side.png", "default_furnace_side.png"
}
minetest.register_node(":scp:creative_dropper_up", up_def)


