--[[
Name: "sh_battery.lua".
Product: "EvoRP (Roleplay)".
--]]

if ( !evorp.plugin.get("Generic") ) then return; end;

-- Define the item table.
local ITEM = {};

-- Set some information about the item.
ITEM.name = "Vehicle Repair Kit";
ITEM.size = 3;
ITEM.cost = 1000;
ITEM.category = "Supplies/Misc"
ITEM.model = "models/props_c17/tools_wrench01a.mdl";
ITEM.batch = 10;
ITEM.store = true;
ITEM.plural = "Vehicle Repair Kits";
ITEM.uniqueID = "repairkit";
ITEM.description = "Use when inside a car or while looking at a car to repair it.";

-- Called when a player uses the item.
function ITEM:onUse(player)
	if not (player:InVehicle()) then
		local eyetrace = player:GetEyeTrace();
		local ent = eyetrace.Entity;
		if not (IsValid(ent)) then evorp.player.notify(player, "Aim at a car!", 1); return false end
		
		if not (ent:GetClass() == "prop_vehicle_jeep") then
			evorp.player.notify(player, "Not a car!", 1)
			return false
		else
			if (player:GetPos():Distance(eyetrace.HitPos) > 64) then 
				evorp.player.notify(player, "Too far!", 1)
				return false
			end
			if (ent:GetNetworkedBool("NeedsFix")) then
				ent:SetHealth( 200 );
				ent:SetNetworkedBool("NeedsFix", false)
				ent:SetNetworkedBool("HotWired", false)
				evorp.player.notify(player, "Fixed!", 0)
				ent:Fire("TurnOn", "" , 0)
				ent:StopParticles()
			else
				evorp.player.notify(player, "This car doesn't need a repair!", 0)
			end
		end
	else
		local ent = player:GetVehicle();
		if not (ent:GetClass() == "prop_vehicle_jeep") then
			evorp.player.notify(player, "Not a car!", 1)
			return false
		else
			if (ent:GetNetworkedBool("NeedsFix")) then
				ent:SetHealth( 200 );
				ent:SetNetworkedBool("NeedsFix", false)
				evorp.player.notify(player, "Fixed!", 0)
				ent:Fire("TurnOn", "" , 0)
				ent:StopParticles()
			else
				evorp.player.notify(player, "This car doesn't need a repair!", 0)
			end
		end
	end
end;

-- Called when a player drops the item.
function ITEM:onDrop(player, position) end;

-- Called when a player destroys the item.
function ITEM:onDestroy(player) end;

-- Register the item.
evorp.item.register(ITEM);
