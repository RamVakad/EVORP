--[[
Name: "sh_crowbar.lua".
Product: "EvoRP (Roleplay)".
--]]

if ( !evorp.plugin.get("Generic") ) then return; end;

-- Define the item table.
local ITEM = {};

-- Set some information about the item.
ITEM.name = "Crowbar";
ITEM.size = 1;
ITEM.cost = 125;
ITEM.category = "Weaponry"
ITEM.model = "models/weapons/w_crowbar.mdl";
ITEM.batch = 10;
ITEM.store = true;
ITEM.weapon = true;
ITEM.plural = "Crowbars";
ITEM.uniqueID = "weapon_crowbar";
ITEM.description = "A crowbar.";

-- Called when a player uses the item.
function ITEM:onUse(player) end;

-- Called when a player drops the item.
function ITEM:onDrop(player, position) end;

-- Called when a player destroys the item.
function ITEM:onDestroy(player) end;

-- Register the item.
evorp.item.register(ITEM);
