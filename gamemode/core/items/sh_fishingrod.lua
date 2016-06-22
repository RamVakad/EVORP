--[[
Name: "sh_ak47.lua".
Product: "EvoRP (Roleplay)".
--]]

if ( !evorp.plugin.get("Generic") ) then return; end;

-- Define the item table.
local ITEM = {};

-- Set some information about the item.
ITEM.name = "Fishing Rod";
ITEM.size = 2;
ITEM.cost = 4000;
ITEM.category = "Supplies/Misc";
ITEM.model = "models/als/rod/w_rod.mdl";
ITEM.batch = 10;
ITEM.store = true;
ITEM.weapon = true;
ITEM.plural = "Fishing Rods";
ITEM.uniqueID = "evorp_fish";
ITEM.description = "A fishing rod to catch fine fish from the Evo City lake.";
ITEM.Heavy = true
-- Called when a player uses the item.
function ITEM:onUse(player) end;

-- Called when a player drops the item.
function ITEM:onDrop(player, position) end;

-- Called when a player destroys the item.
function ITEM:onDestroy(player) end;

-- Register the item.
evorp.item.register(ITEM);
