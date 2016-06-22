--[[
Name: "sh_m4a1.lua".
Product: "EvoRP (Roleplay)".
--]]

if ( !evorp.plugin.get("Generic") ) then return; end;

-- Define the item table.
local ITEM = {};

-- Set some information about the item.
ITEM.name = "M4A1";
ITEM.size = 3;
ITEM.cost = 3500;
ITEM.category = "Weaponry"
ITEM.model = "models/weapons/w_rif_m4a1.mdl";
ITEM.batch = 10;
ITEM.store = true;
ITEM.weapon = true;
ITEM.plural = "M4A1s";
ITEM.uniqueID = "bb_m4a1";
ITEM.description = "A benchmark automatic assult rifle.";
ITEM.Heavy = true
-- Called when a player uses the item.
function ITEM:onUse(player) end;

-- Called when a player drops the item.
function ITEM:onDrop(player, position) end;

-- Called when a player destroys the item.
function ITEM:onDestroy(player) end;

-- Register the item.
evorp.item.register(ITEM);
