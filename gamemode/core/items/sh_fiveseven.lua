--[[
Name: "sh_fiveseven.lua".
Product: "EvoRP (Roleplay)".
--]]

if ( !evorp.plugin.get("Generic") ) then return; end;

-- Define the item table.
local ITEM = {};

-- Set some information about the item.
ITEM.name = "Five-seven";
ITEM.size = 1;
ITEM.cost = 1000;
ITEM.category = "Weaponry"
ITEM.model = "models/weapons/unloaded/pist_fiveseven.mdl";
ITEM.batch = 10;
ITEM.store = true;
ITEM.weapon = true;
ITEM.plural = "Five-sevens";
ITEM.uniqueID = "bb_fiveseven";
ITEM.description = "A compact pistol which deals fair damage.";

-- Called when a player uses the item.
function ITEM:onUse(player) end;

-- Called when a player drops the item.
function ITEM:onDrop(player, position) end;

-- Called when a player destroys the item.
function ITEM:onDestroy(player) end;

-- Register the item.
evorp.item.register(ITEM);
