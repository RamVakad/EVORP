--[[
Name: "sh_weapon_crowbar.lua".
Product: "evorp (Roleplay)".
--]]

if ( !evorp.plugin.get("Generic") ) then return; end;

-- Define the item table.
local ITEM = {};

-- Set some information about the item.
ITEM.name = "Lockpick";
ITEM.size = 1;
ITEM.cost = 1000;
ITEM.model = "models/weapons/w_crowbar.mdl";
ITEM.batch = 10;
ITEM.store = true;
ITEM.weapon = true;
ITEM.plural = "Lockpicks";
ITEM.uniqueID = "evorp_lockpick";
ITEM.description = "Allow you to pick locks on cars and doors. It's very delicate.";
ITEM.category = "Black Market";

-- Called when a player uses the item.
function ITEM:onUse(player) end;

-- Called when a player drops the item.
function ITEM:onDrop(player, position) end;

-- Called when a player destroys the item.
function ITEM:onDestroy(player) end;

-- Register the item.
evorp.item.register(ITEM);