-- add bones to dirt
minetest.override_item("default:dirt", {
    drop = {
        max_items = 1,
        items = {
            {
                items = {'bone:bone', 'default:dirt'},
                rarity = 7,
            },
            {
                items = {'default:dirt'},
            }
        }
    },
})

-- add bones to dirt with grass
minetest.override_item("default:dirt_with_grass", {
    drop = {
        max_items = 1,
        items = {
            {
                items = {'bone:bone', 'default:dirt'},
                rarity = 7,
            },
            {
                items = {'default:dirt'},
            }
        }
    },
})

-- bone item
minetest.register_craftitem("bone:bone", {
    description = "Bone",
    inventory_image = "bone_bone.png",
})

-- bonemeal recipe
minetest.register_craft({
    output = 'bone:bonemeal 5',
    recipe = {{'bone:bone'}},
})

local n
local n2
local pos
local plant_tab = {}
local rnd_max = 5

minetest.after(0.5, function()
    plant_tab[0] = "air"
    plant_tab[1] = "default:grass_1"
    plant_tab[2] = "default:grass_2"
    plant_tab[3] = "default:grass_3"
    plant_tab[4] = "default:grass_4"
    plant_tab[5] = "default:grass_5"

    if minetest.get_modpath("flowers") ~= nil then
        rnd_max = 11
        plant_tab[6] = "flowers:dandelion_white"
        plant_tab[7] = "flowers:dandelion_yellow"
        plant_tab[8] = "flowers:geranium"
        plant_tab[9] = "flowers:rose"
        plant_tab[10] = "flowers:tulip"
        plant_tab[11] = "flowers:viola"
    end

end)

local faces = {  -- for growing pumpkins and melons
    [1] = { x = -1, z = 0, r = 3, o = 1, m = 14 },
    [2] = { x = 1, z = 0, r = 1, o = 3,  m = 16 },
    [3] = { x = 0, z = -1, r = 2, o = 0, m = 5  },
    [4] = { x = 0, z = 1, r = 0, o = 2,  m = 11 }
}

local crops = {
    ["farming:wheat"]=8,
    ["farming:cotton"]=8,
    ["farming:pumpkin"]=8,
    ["farming:melon"]=8,
    ["farming:carrot"]=8,
    ["farming:tomato"]=8,
    ["farming:potato"]=4,
    ["farming:coffee"]=5,
    ["farming:barley"]=7,
    ["farming:hemp"]=8,
    ["farming:corn"]=8,
    ["farming:beanpole"]=5,
    ["farming:beetroot"]=5,
    ["farming:blueberry"]=4,
    ["farming:chili"]=8,
    ["farming:cucumber"]=4,
    ["farming:garlic"]=5,
    ["farming:grapes"]=8,
    ["farming:onion"]=5,
    ["farming:pea"]=5,
    ["farming:pepper"]=5,
    ["farming:pineapple"]=8,
    ["farming:raspberry"]=4,
    ["farming:rhubarb"]=3,
    ["farming:cocoa"]=4,
}

local function grow(pointed_thing)

    pos = pointed_thing.under
    n = minetest.get_node(pos)
    if n.name == "" then return end
    local stage = ""

    -- grow moretrees
    if minetest.get_modpath("moretrees") ~= nil then
        if n.name == "moretrees:birch_sapling" then
            moretrees.grow_birch(pos)
        elseif n.name == "moretrees:spruce_sapling" then
            moretrees.grow_spruce(pos)
        elseif n.name == "moretrees:fir_sapling" then
            moretrees.grow_fir(pos)
        elseif n.name == "moretrees:junglesapling" then
            moretrees.grow_jungletree(pos)
        else
            for i in ipairs(moretrees.treelist) do
                local treename = moretrees.treelist[i][1]
                local tree_model = treename.."_model"
                if n.name == "moretrees:"..treename.."_sapling" then
                    minetest.remove_node(pos)
                    minetest.spawn_tree(pos, moretrees[tree_model])
                end
            end
        end
    end

    -- grow saplings into trees
    if n.name == "default:sapling" then
        default.grow_new_apple_tree(pos)
    elseif n.name == "default:junglesapling" then
        default.grow_new_jungle_tree(pos)
    elseif n.name == "default:pine_sapling" then
        if minetest.find_node_near(pos, 1, {"group:snowy"}) then
            default.grow_new_snowy_pine_tree(pos)
        else
            default.grow_new_pine_tree(pos)
        end
    elseif n.name == "default:acacia_sapling" then
        default.grow_new_acacia_tree(pos)
    elseif n.name == "default:aspen_sapling" then
        default.grow_new_aspen_tree(pos)
    elseif n.name == "default:bush_sapling" then
        default.grow_bush(pos)
    elseif n.name == "default:acacia_bush_sapling" then
        default.grow_acacia_bush(pos)

    -- grow crops
    elseif crops[string.sub(n.name, 1, -3)] ~= nil then
        stage = string.sub(n.name, -1)
        if tostring(stage) ~= crops[string.sub(n.name, 1, -3)] then
            minetest.set_node(pos, {name=string.sub(n.name, 1, -2)..crops[string.sub(n.name, 1, -3)]})
        end
    
    -- grow melons
    elseif string.sub(n.name, 1, -3) == "crops:melon_plant" then
        local sides = {}
        for face = 1, 4 do
            local t = {x=pos.x+faces[face].x, y=pos.y, z=pos.z+faces[face].z}
            if minetest.get_node(t).name == "air" then
                table.insert(sides, t)
            end
        end
        if #sides > 0 then
            local dir = math.random(1, #sides)
            minetest.swap_node(pos, {name="crops:melon_plant_5_attached", param2 = faces[dir].r})
            minetest.swap_node(sides[dir], {name="crops:melon", param2=faces[dir].m})
        end
    
    -- grow pumpkins
    elseif string.sub(n.name, 1, -3) == "crops:pumpkin_plant" then
        local sides = {}
        for face = 1, 4 do
            local t = {x=pos.x+faces[face].x, y=pos.y, z=pos.z+faces[face].z}
            if minetest.get_node(t).name == "air" then
                table.insert(sides, t)
            end
        end
        if #sides > 0 then
            local dir = math.random(1, #sides)
            minetest.swap_node(pos, {name="crops:pumpkin_plant_5_attached", param2=faces[dir].r})
            minetest.swap_node(sides[dir], {name="crops:pumpkin", param2=faces[dir].m})
        end

    -- grow grass and flowers
    elseif n.name == "default:dirt_with_grass" then
        for i = -2, 3, 1 do
            for j = -3, 2, 1 do
                pos = pointed_thing.above
                pos = {x = pos.x + i, y = pos.y, z = pos.z + j}
                n = minetest.get_node(pos)
                n2 = minetest.get_node({x = pos.x, y = pos.y-1, z = pos.z})

                if n.name ~= "" and n.name == "air" and n2.name == "default:dirt_with_grass" then
                    if math.random(0,5) > 3 then
                        minetest.set_node(pos, {name=plant_tab[math.random(0, rnd_max)]})
                    else
                        minetest.set_node(pos, {name=plant_tab[math.random(0, 5)]})
                    end
                end
            end
        end
    end
end

-- bonemeal item
minetest.register_craftitem("bone:bonemeal", {
    description = "Bone Meal",
    inventory_image = "bone_bonemeal.png",
    --liquids_pointable = false,
    --stack_max = 99,
    on_use = function(itemstack, user, pointed_thing)
        if pointed_thing.type == "node" then
            if not minetest.setting_getbool("creative_mode") then
                local item = user:get_wielded_item()
                item:take_item()
                user:set_wielded_item(item)
            end
            grow(pointed_thing)
            itemstack:take_item()
            return itemstack
        end
    end,
})
