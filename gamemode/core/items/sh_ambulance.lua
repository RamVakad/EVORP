--[[
Name: "sh_police_car.lua".
Product: "EvoRP (Roleplay)".
--]]
 
if ( !evorp.plugin.get("Generic") ) then return; end;
 
-- Define the item table.
local ITEM = {};
 
-- Set some information about the item.
ITEM.name = "Ambulance";
ITEM.size = 5;
ITEM.cost = 4000;
ITEM.model = "models/ambulancecd.mdl";
ITEM.script = "scripts/vehicles/TDMCars/crownvic_taxi.txt";
ITEM.nopaint = true;
ITEM.batch = 1;
ITEM.store = true;
ITEM.plural = "Ambulances";
ITEM.uniqueID = "ambulance";
ITEM.description = "An ambulance exclusive to paramedics.";
ITEM.class = true;
ITEM.category = "Vehicles"; 


function ITEM:onUse(player)
	if (player:Team() == TEAM_PARAMEDIC) then
		return true
	else
		evorp.player.notify(player, "You cannot spawn this car!", 1);
		return false
	end
end

function ITEM:onPickup() end;

function ITEM:onDrop() end;

function ITEM:onSell() end;

-- Register the item.
evorp.item.register(ITEM);
