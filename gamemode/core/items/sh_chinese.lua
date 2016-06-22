--[[
Name: "sh_chinese.lua".
Product: "EvoRP (Roleplay)".
--]]

if ( !evorp.plugin.get("Hunger") ) then return; end;

-- Define the item table.
local ITEM = {};

-- Set some information about the item.
ITEM.name = "Chinese Take Out";
ITEM.size = 1;
ITEM.cost = 100;
ITEM.category = "Food"
ITEM.model = "models/props_junk/garbage_takeoutcarton001a.mdl";
ITEM.batch = 10;
ITEM.store = true;
ITEM.plural = "Chinese Take Outs";
ITEM.uniqueID = "chinese";
ITEM.description = "Some chinese food which restores 50 hunger.";

-- Called when a player uses the item.
function ITEM:onUse(player)
	player._Hunger.amount = math.Clamp(player._Hunger.amount - 50, 0, 100);
end;

-- Called when a player drops the item.
function ITEM:onDrop(player, position) end;

-- Called when a player destroys the item.
function ITEM:onDestroy(player) end;

-- Register the item.
evorp.item.register(ITEM);
