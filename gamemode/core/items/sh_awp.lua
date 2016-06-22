--[[
Name: "sh_g3sg1.lua".
Product: "EvoRP (Roleplay)".
--]]

if ( !evorp.plugin.get("Generic") ) then return; end;

-- Define the item table.
local ITEM = {};

-- Set some information about the item.
ITEM.name = "AWP";
ITEM.size = 3;
ITEM.cost = 18750;
ITEM.category = "Weaponry";
ITEM.model = "models/weapons/unloaded/snip_awp.mdl";
ITEM.batch = 10;
ITEM.store = true;
ITEM.weapon = true;
ITEM.plural = "AWPs";
ITEM.uniqueID = "bb_awp";
ITEM.description = "A very high powered sniper rifle.";
ITEM.Heavy = true
-- Called when a player uses the item.
function ITEM:onUse(player) end;

-- Called when a player drops the item.
function ITEM:onDrop(player, position) end;

-- Called when a player destroys the item.
function ITEM:onDestroy(player) end;

-- Register the item.
evorp.item.register(ITEM);
