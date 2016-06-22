--[[
Name: "sh_mp5.lua".
Product: "EvoRP (Roleplay)".
--]]

if ( !evorp.plugin.get("Generic") ) then return; end;

-- Define the item table.
local ITEM = {};

-- Set some information about the item.
ITEM.name = "UMP45";
ITEM.size = 2;
ITEM.cost = 3000;
ITEM.category = "Weaponry"
ITEM.model = "models/weapons/unloaded/smg_ump45.mdl";
ITEM.batch = 10;
ITEM.store = true;
ITEM.weapon = true;
ITEM.plural = "UMP45s";
ITEM.uniqueID = "bb_ump45";
ITEM.description = "A slower, more powerful sub-machine gun.";
ITEM.Heavy = true
-- Called when a player uses the item.
function ITEM:onUse(player) end;

-- Called when a player drops the item.
function ITEM:onDrop(player, position) end;

-- Called when a player destroys the item.
function ITEM:onDestroy(player) end;

-- Register the item.
evorp.item.register(ITEM);
