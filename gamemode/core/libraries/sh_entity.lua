--[[
Name: "sh_entity.lua".
Product: "EvoRP (Roleplay)".
--]]

evorp.entity = {};

-- Check if an entity is a door.
function evorp.entity.isDoor(entity)
	if not IsValid(entity) then return end;
	local class = entity:GetClass();
	
	-- Check if the entity is a valid door class.
	if (class == "func_door" or class == "func_door_rotating" or class == "prop_door_rotating" or class == "prop_vehicle_jeep" or entity:GetNetworkedBool("iDoor")) then
		return true;
	else
		return false;
	end;
end;

-- Check if we're running on the server.
if (SERVER) then
	function evorp.entity.openDoor(entity, delay, unlock, sound)
		if (unlock) then
			entity:Fire("unlock", "", delay);
			
			-- Check if we should play an unlock sound.
			if (sound) then entity:EmitSound("physics/wood/wood_box_impact_hard3.wav"); end;
			
			-- Add a small amount to the delay so that it opens just slightly after it unlocks it.
			delay = delay + 0.025;
		end;
		
		-- Check if it's a prop_dynamic.
		if (entity:GetClass() == "prop_dynamic") then
			entity:Fire("setanimation", "open", "0");
			entity:Fire("setanimation", "close", "10");
		else
			entity:Fire("open", "", delay);
		end;
	end;
end;
