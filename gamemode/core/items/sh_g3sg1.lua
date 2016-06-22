--[[
Name: "sh_g3sg1.lua".
Product: "EvoRP (Roleplay)".
--]]

if ( !evorp.plugin.get("Generic") ) then return; end;

-- Define the item table.
local ITEM = {};

-- Set some information about the item.
ITEM.name = "G3SG1";
ITEM.size = 3;
ITEM.cost = 7500;
ITEM.category = "Weaponry";
ITEM.model = "models/weapons/unloaded/snip_g3sg1.mdl";
ITEM.batch = 10;
ITEM.store = true;
ITEM.weapon = true;
ITEM.plural = "G3SG1s";
ITEM.uniqueID = "bb_g3sg1";
ITEM.description = "A scoped battle rifle. Uses rifle ammo.";
ITEM.Heavy = true
-- Called when a player uses the item.
function ITEM:onUse(player) end;

-- Called when a player drops the item.
function ITEM:onDrop(player, position) end;

-- Called when a player destroys the item.
function ITEM:onDestroy(player) end;

-- Register the item.
evorp.item.register(ITEM);
