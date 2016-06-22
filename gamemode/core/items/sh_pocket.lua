--[[
Name: "sh_pocket.lua".
Product: "EvoRP (Roleplay)".
--]]

if ( !evorp.plugin.get("Generic") ) then return; end;

-- Define the item table.
local ITEM = {};

-- Set some information about the item.
ITEM.name = "Pocket";
ITEM.size = -5;
ITEM.cost = 5000;
ITEM.category = "Supplies/Misc"
ITEM.model = "models/props_junk/garbage_bag001a.mdl";
ITEM.batch = 10;
ITEM.store = true;
ITEM.plural = "Pockets";
ITEM.uniqueID = "pocket";
ITEM.description = "A pocket that holds items, maximum is 150 inventory space.";

-- Called when a player drops the item.
function ITEM:onDrop(player, position) end;

-- Register the item.
evorp.item.register(ITEM);
