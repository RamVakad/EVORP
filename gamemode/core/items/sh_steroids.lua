--[[
Name: "sh_steroids.lua".
Product: "EvoRP (Roleplay)".
--]]

if ( !evorp.plugin.get("Stamina") ) then return; end;
if ( !evorp.plugin.get("Generic") ) then return; end;

-- Define the item table.
local ITEM = {};

-- Set some information about the item.
ITEM.name = "Steroids";
ITEM.size = 1;
ITEM.cost = 100;
ITEM.category = "Supplies/Misc"
ITEM.model = "models/items/battery.mdl";
ITEM.batch = 10;
ITEM.store = true;
ITEM.plural = "Steroids";
ITEM.uniqueID = "steroids";
ITEM.description = "Illegal pills which restore 100 stamina.";

-- Called when a player uses the item.
function ITEM:onUse(player)
	if (player._Stamina >= 100) then
		evorp.player.notify(player, "You do not need any steroids!", 1);
		
		-- Return false because we cannot use the item.
		return false;
	else
		player._Stamina = 100;
	end;
end;

-- Called when a player drops the item.
function ITEM:onDrop(player, position) end;

-- Called when a player destroys the item.
function ITEM:onDestroy(player) end;

-- Register the item.
evorp.item.register(ITEM);
