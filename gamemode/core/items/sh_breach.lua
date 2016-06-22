--[[
Name: "sh_breach.lua".
Product: "EvoRP (Roleplay)".
--]]

if ( !evorp.plugin.get("Generic") ) then return; end;

-- Define the item table.
local ITEM = {};

-- Set some information about the item.
ITEM.name = "Breach";
ITEM.size = 2;
ITEM.cost = 2500;
ITEM.category = "Black Market"
ITEM.model = "models/weapons/w_c4_planted.mdl";
ITEM.batch = 10;
ITEM.store = true;
ITEM.plural = "Breaches";
ITEM.uniqueID = "breach";
ITEM.description = "Plant it on a door and watch it blow open.";

-- Called when a player uses the item.
function ITEM:onUse(player)
	local trace = player:GetEyeTrace();
	local door = trace.Entity;
	
	
	-- Check if the trace entity is a valid door.
	if (evorp.entity.isDoor(door) or door:GetClass() == "prop_dynamic") and !(door:IsVehicle()) then
		if (door:GetPos():Distance( player:GetPos() ) <= 128) then
			if ( !IsValid(door._Breach) ) then
				if (evorp.team.query(player:Team(), "radio", "") == "R_GOV") then
					local warrant = door._Owner:GetNetworkedString("evorp_Warranted")
					if warrant != "search" then
						evorp.player.notify(player, "You need a warrant first!", 0)
						evorp.player.printConsoleAccess("[Alert] He had no search warrant! Returning false.", "a", false, player)
					return false
					end
				end
					local entity = ents.Create("evorp_breach");
					
					-- Spawn the entity.
					entity:Spawn();
					
					-- Set the door for the entity to breach.
					entity:SetDoor(door, trace);
					
					-- Set the door's breach entity to this one.
					door._Breach = entity;
				else
					evorp.player.notify(player, "This door already has a breach!", 1);
					
					-- Return false because the door already has a breach.
					return false;
				end;
		else
			evorp.player.notify(player, "You are not close enough to the door!", 1);
			
			-- Return false because the door is too far away.
			return false;
		end;
	else
		evorp.player.notify(player, "That is not a valid door!", 1);
		
		-- Return false because this is not a valid door.
		return false;
	end;
end;

-- Called when a player drops the item.
function ITEM:onDrop(player, position) end;

-- Called when a player destroys the item.
function ITEM:onDestroy(player) end;

-- Register the item.
evorp.item.register(ITEM);
