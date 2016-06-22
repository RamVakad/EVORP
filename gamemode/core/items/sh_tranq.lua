--[[
Name: "sh_mp5.lua".
Product: "EvoRP (Roleplay)".
--]]

if ( !evorp.plugin.get("Generic") ) then return; end;

-- Define the item table.
local ITEM = {};

-- Set some information about the item.
ITEM.name = "Tranq Rifle";
ITEM.size = 3;
ITEM.cost = 3750;
ITEM.category = "Weaponry"
ITEM.model = "models/weapons/unloaded/snip_scout.mdl";
ITEM.batch = 10;
ITEM.store = true;
ITEM.weapon = true;
ITEM.safe = true;
ITEM.plural = "Tranq Rifles";
ITEM.uniqueID = "bb_scout";
ITEM.description = "A tranquilizer rifle.";
ITEM.Heavy = true

-- Called when a player uses the item.
function ITEM:onUse(player) end;

-- Called when a player drops the item.
function ITEM:onDrop(player, position) end;

-- Called when a player destroys the item.
function ITEM:onDestroy(player) end;

-- Register the item.
evorp.item.register(ITEM);
