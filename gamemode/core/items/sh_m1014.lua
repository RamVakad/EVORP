--[[
Name: "sh_m3super90.lua".
Product: "EvoRP (Roleplay)".
--]]

if ( !evorp.plugin.get("Generic") ) then return; end;

-- Define the item table.
local ITEM = {};

-- Set some information about the item.
ITEM.name = "M1014";
ITEM.size = 3;
ITEM.cost = 6250;
ITEM.category = "Weaponry"
ITEM.model = "models/weapons/w_shot_xm1014.mdl";
ITEM.batch = 10;
ITEM.store = true;
ITEM.weapon = true;
ITEM.plural = "M1014s";
ITEM.uniqueID = "bb_xm1014";
ITEM.description = "A semi-automatic shotgun which is great at short range.";
ITEM.Heavy = true
-- Called when a player uses the item.
function ITEM:onUse(player) end;

-- Called when a player drops the item.
function ITEM:onDrop(player, position) end;

-- Called when a player destroys the item.
function ITEM:onDestroy(player) end;

-- Register the item.
evorp.item.register(ITEM);
