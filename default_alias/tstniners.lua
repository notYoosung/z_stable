local function niners_timer()
    return math.random(1, 3)
end

local function niners_newpos(pos)
    local up = { x = pos.x, y = pos.y + 1, z = pos.z }
    local down = { x = pos.x, y = pos.y - 1, z = pos.z }
    local side1 = { x = pos.x + 1, y = pos.y, z = pos.z }
    local side2 = { x = pos.x - 1, y = pos.y, z = pos.z }
    local side3 = { x = pos.x, y = pos.y, z = pos.z + 1 }
    local side4 = { x = pos.x, y = pos.y, z = pos.z - 1 }
    local r = math.random(1, 5)
    if core.get_node(down).name == "air" then
        return down
    elseif r == 1 and core.get_node(side1).name == "air" then
        return side1
    elseif r == 2 and core.get_node(side2).name == "air" then
        return side2
    elseif r == 3 and core.get_node(side3).name == "air" then
        return side3
    elseif r == 4 and core.get_node(side4).name == "air" then
        return side4
    elseif r == 5 and core.get_node(up).name == "air" then
        return up
    else
        return nil
    end
end

local function niners_rotate(pos, param2)
    local r = math.random(0, 3)
    local node = core.get_node(pos)
    param2 = param2 or r
    node.param2 = param2
    core.swap_node(pos, node)
    return true
end

local function niners_walk(pos)
    local oldnode = core.get_node(pos)
    local oldnodemeta = core.get_meta(pos):to_table()
    local newpos = niners_newpos(pos)
    if newpos then
        core.set_node(newpos, oldnode)
        core.get_meta(newpos):from_table(oldnodemeta)
        core.get_node_timer(newpos):start(niners_timer())
        core.set_node(pos, { name = "air" })
    end
end

minetest.register_node(":scp:niners", {
    description = "SCP-999",
    drawtype = "nodebox",
    paramtype = "light",
    tiles = { "mcl_colorblocks_concrete_orange.png^[opacity:129 x    " },
    selection_box = {
        type = "regular",
    },
    node_box = {
        type = "fixed",
        fixed = {
            { -0.25, -0.25, -0.25, 0.25, 0.25, 0.25 },
            { -0.5,  -0.5,  -0.5,  0.5,  0.5,  0.5 },
        }
    },
    use_texture_alpha = "blend",
    groups = { dig_immediate = 3, bouncy = 80, fall_damage_add_percent = -100 },
    is_ground_content = false,
    sounds = {
        dug = { name = "slimenodes_dug", gain = 0.6 },
        place = { name = "slimenodes_place", gain = 0.6 },
        footstep = { name = "slimenodes_step", gain = 0.3 },
    },
    _mcl_blast_resistance = 0,
    _mcl_hardness = 0,
    after_place_node = function(pos, placer, itemstack, pointed_thing)
        core.get_node_timer(pos):start(niners_timer())
    end,
    on_timer = function(pos, elapsed)
        niners_rotate(pos)
        niners_walk(pos)
        core.get_node_timer(pos):start(niners_timer())
    end,
    on_punch = function(pos, node, puncher, pointed_thing)
        niners_rotate(pos)
        niners_walk(pos)
    end,
})
mesecon.register_mvps_stopper("scp:niners")



minetest.register_node(":scp:mvy", {
    description = "SCP-899234",
    drawtype = "nodebox",
    paramtype = "light",
    tiles = { "mcl_colorblocks_concrete_white.png^[colorize:#035022:255^[opacity:175" },
    selection_box = {
        type = "regular",
    },
    node_box = {
        type = "fixed",
        fixed = {
            { -0.25, -0.25, -0.25, 0.25, 0.25, 0.25 },
            { -0.5,  -0.5,  -0.5,  0.5,  0.5,  0.5 },
        }
    },
    use_texture_alpha = "blend",
    groups = { dig_immediate = 3, bouncy = 80, fall_damage_add_percent = -100 },
    is_ground_content = false,
    sounds = {
        dug = { name = "slimenodes_dug", gain = 0.6 },
        place = { name = "slimenodes_place", gain = 0.6 },
        footstep = { name = "slimenodes_step", gain = 0.3 },
    },
    _mcl_blast_resistance = 0,
    _mcl_hardness = 0,
    after_place_node = function(pos, placer, itemstack, pointed_thing)
        core.get_node_timer(pos):start(0.5)
    end,
    on_timer = function(pos, elapsed)
        niners_rotate(pos)
        niners_walk(pos)
        core.get_node_timer(pos):start(0.5)
    end,
    on_punch = function(pos, node, puncher, pointed_thing)
        niners_rotate(pos)
        niners_walk(pos)
    end,
})
mesecon.register_mvps_stopper("scp:mvy")


local function table_contains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end


local colors = {
    "808080",
    "469D6F",
    "3B85B8",
    "F8D548",
    "ED762F",
    "B42538",
}
local containables = {
    {},
    {"scp:niners", "scp:mvy"},
    {},
    {},
    {},
    {},
}

for containment_level = 0, 5 do
    minetest.register_tool("scp:containment_tool_" .. tostring(containment_level), {
        description = "Anomalous Containment Tool\nContainment Level: " .. tostring(containment_level) .. "\nContained Anomaly: ",
        inventory_image = "mob_spawner.png^[colorize:#" .. colors[containment_level],
        on_rightclick = function(pos, node, clicker, itemstack)
            if itemstack:get_name() == "scp:containment_tool_1" then
                local itemmeta = itemstack:get_meta()
                if itemmeta:get_string("scp:contained_id") then
                    itemstack.
                end
            end
        end,
        on_place = function(itemstack, player, pointed_thing)
            local rc = mcl_util.call_on_rightclick(itemstack, player, pointed_thing)
            if rc then return rc end
            local itemmeta = itemstack:get_meta()

            local pointed_name = ""

            if pointed_thing.type == "nothing" then return itemstack
            else if pointed_thing.type == "node" then
                pointed_name = pointed_thing
            else if pointed_thing.type == "object" then
                if pointed_thing.ref:is_player() then
                    pointed_name = pointed_thing:get_player_name()
                else
                    pointed_name = pointed_thing.name
                end
            end

            if itemmeta:get_string("contained_id") == "" and table_contains(pointed_name) then
                itemmeta:set_string("active", "true")
            end
            return itemstack
        end,
        on_secondary_use = function(itemstack, player, pointed_thing)
            return itemstack
        end
    })
    
end

