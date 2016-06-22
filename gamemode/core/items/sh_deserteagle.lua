--[[
Name: "sh_deserteagle.lua".
Product: "EvoRP (Roleplay)".
--]]

if ( !evorp.plugin.get("Generic") ) then return; end;

-- Define the item table.
local ITEM = {};

-- Set some information about the item.
ITEM.name = "Desert Eagle (Raging Bull)";
ITEM.size = 1;
ITEM.cost = 1250;
ITEM.category = "Weaponry"
ITEM.model = "models/weapons/w_357.mdl";
ITEM.batch = 10;
ITEM.store = true;
ITEM.weapon = true;
ITEM.plural = "Desert Eagles";
ITEM.uniqueID = "bb_deagle";
ITEM.description = "A powerful pistol with a lot of punch.";

-- Called when a player uses the item.
function ITEM:onUse(player) end;

-- Called when a player drops the item.
function ITEM:onDrop(player, position) end;

-- Called when a player destroys the item.
function ITEM:onDestroy(player) end;

-- Register the item.
evorp.item.register(ITEM);
