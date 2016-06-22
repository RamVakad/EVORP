--[[ 
Name: "sh_police_car.lua".
Product: "EvoRP (Roleplay)".

 ]]
if ( !evorp.plugin.get("Generic") ) then return; end;
 
-- Define the item table.
local ITEM = {};
 
-- Set some information about the item.
ITEM.name = "Taxi";
ITEM.size = 5;
ITEM.cost = 5000;
ITEM.model = "models/tdmcars/crownvic_taxi.mdl";
ITEM.batch = 1;
ITEM.store = true;
ITEM.plural = "Taxi's";
ITEM.uniqueID = "crownvic_taxitdm";
ITEM.class = true;
ITEM.description = "A public transportation vehicle.";
ITEM.category = "Vehicles"; 


function ITEM:onUse(player)
	if (player:Team() == TEAM_TAXI) then
		return true
	else
		evorp.player.notify(player, "You cannot spawn this car!", 1);
		return false
	end
end

function ITEM:onPickup() end;

function ITEM:onSell() end;

function ITEM:onDrop() end;

-- Register the item.
evorp.item.register(ITEM);
