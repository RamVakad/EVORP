--[[
Name: "sh_m4a1.lua".
Product: "EvoRP (Roleplay)".
--]]

if ( !evorp.plugin.get("Generic") ) then return; end;

-- Define the item table.
local ITEM = {};

-- Set some information about the item.
ITEM.name = "GALIL";
ITEM.size = 2;
ITEM.cost = 5000;
ITEM.category = "Weaponry"
ITEM.model = "models/weapons/unloaded/rif_galil.mdl"
ITEM.batch = 10;
ITEM.store = true;
ITEM.weapon = true;
ITEM.plural = "GALIL's";
ITEM.uniqueID = "bb_galil";
ITEM.description = "An accurate assault rifle.";
ITEM.Heavy = true
-- Called when a player uses the item.
function ITEM:onUse(player) end;

-- Called when a player drops the item.
function ITEM:onDrop(player, position) end;

-- Called when a player destroys the item.
function ITEM:onDestroy(player) end;

-- Register the item.
evorp.item.register(ITEM);
