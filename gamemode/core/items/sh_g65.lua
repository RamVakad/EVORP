--[[
Name: "sh_police_car.lua".
Product: "EvoRP (Roleplay)".
--]]
 
if ( !evorp.plugin.get("Generic") ) then return; end;
 
-- Define the item table.
local ITEM = {};
 
-- Set some information about the item.
ITEM.name = "Sell - Full Refund G65";
ITEM.size = 5;
ITEM.cost = 800000;
ITEM.model = "models/tdmcars/skyline_r34.mdl"
ITEM.skin = 9;
ITEM.batch = 1;
ITEM.store = false;
ITEM.plural = "Police Car's";
ITEM.uniqueID = "mer_g65";
ITEM.description = "The G-Class G-Wagon..";
ITEM.class = true;
ITEM.category = "Vehicles"; 


function ITEM:onUse(player)
	evorp.player.notify(player, "You can't spawn this vehicle. It's glitched. Just sell it.", 1);
	return false
end

function ITEM:onPickup() end;

function ITEM:onDrop() end;

function ITEM:onSell() end;

-- Register the item.
evorp.item.register(ITEM);
