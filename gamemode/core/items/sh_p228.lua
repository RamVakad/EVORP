--[[
Name: "sh_evorp_usp45.lua".
Product: "EvoRP (Roleplay)".
--]]

if ( !evorp.plugin.get("Generic") ) then return; end;

-- Define the item table.
local ITEM = {};

-- Set some information about the item.
ITEM.name = "P228";
ITEM.size = 1;
ITEM.cost = 250;
ITEM.category = "Weaponry"
ITEM.model = "models/weapons/unloaded/pist_p228.mdl";
ITEM.batch = 10;
ITEM.store = true;
ITEM.weapon = true;
ITEM.plural = "P228s";
ITEM.uniqueID = "bb_p228";
ITEM.description = "A weak, short ranged pistol.";

-- Called when a player uses the item.
function ITEM:onUse(player) end;

-- Called when a player drops the item.
function ITEM:onDrop(player, position) end;

-- Called when a player destroys the item.
function ITEM:onDestroy(player) end;

-- Register the item.
evorp.item.register(ITEM);
