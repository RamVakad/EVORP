--[[
Name: "sh_ak47.lua".
Product: "EvoRP (Roleplay)".
--]]

if ( !evorp.plugin.get("Generic") ) then return; end;

-- Define the item table.
local ITEM = {};

-- Set some information about the item.
ITEM.name = "Portable EMP";
ITEM.size = 2;
ITEM.cost = 2000;
ITEM.category = "Black Market";
ITEM.model = "models/weapons/w_IRifle.mdl";
ITEM.batch = 10;
ITEM.store = true;
ITEM.safe = true;
ITEM.weapon = true;
ITEM.plural = "Portable EMPs";
ITEM.uniqueID = "evorp_carstop";
ITEM.description = "A portable EMP, good for disabling vehicles.";

-- Called when a player uses the item.
function ITEM:onUse(player) end;

-- Called when a player drops the item.
function ITEM:onDrop(player, position) end;

-- Called when a player destroys the item.
function ITEM:onDestroy(player) end;

-- Register the item.
evorp.item.register(ITEM);
