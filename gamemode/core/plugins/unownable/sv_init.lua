--[[
Name: "sv_init.lua".
Product: "EvoRP (Roleplay)".
--]]

local PLUGIN = {};

-- Create a variable to store the plugin for the shared file.
PLUGIN_SHARED = PLUGIN;

-- Include the shared file and add it to the client download list.
include("sh_init.lua");
AddCSLuaFile("sh_init.lua");

-- A function to load the unownable doors.
function PLUGIN.loadUnownable()
	PLUGIN.unownable = {};
	
	-- Check if there are unownable doors for this map.
    local f = file.Open("evorp/plugins/unownable/"..game.GetMap()..".txt", "rb", "DATA");
	if ( f ) then
        f:Close();
		local unownable = util.KeyValuesToTable( file.Read("evorp/plugins/unownable/"..game.GetMap()..".txt", "DATA") );

		-- Loop through the spawn points and convert them to a vector.
		for k, v in pairs(unownable) do
			local x, y, z = string.match(v.position, "(.-), (.-), (.+)");
			
			-- Gather some data about the entity.
			local data = {
				position = Vector( tonumber(x), tonumber(y), tonumber(z) ),
				name = v.name
			};
			
			-- Get entities inside a sphere near the position.
			local entities = ents.FindInSphere(data.position, 5);
			local completed = {};
			
			-- Loop through the entities that we found.
			for k2, v2 in pairs(entities) do
				if ( evorp.entity.isDoor(v2) and !completed[ v2:EntIndex() ] ) then
					if (data.name == "RR") then
						table.insert(PLUGIN.unownable, data);
						v2:Remove();
					else
						v2._Owner = nil;
						v2._Unownable = true;
						
						-- Set some network variables about the entity.
						v2:SetNetworkedString("evorp_Name", data.name);
						v2:SetNetworkedBool("evorp_Unownable", true);
						
						-- Set the entity of the data.,
						data.entity = v2;
						
						-- Insert the data into the unownable table.
						table.insert(PLUGIN.unownable, data);
						
						-- Insert the entity into the completed entities table.
						completed[ v2:EntIndex() ] = true;
					end
				end;
			end;
		end;
	end;
end;

-- Called when the map has loaded all the entities.
function PLUGIN.initPostEntity()
	timer.Simple(5, function() PLUGIN.loadUnownable(); end);
end;

-- Add the hook.
evorp.hook.add("InitPostEntity", PLUGIN.initPostEntity);

-- Called when a player attempts to view a door.
function PLUGIN.playerCanViewDoor(player, door)
	if (door._Unownable) then
		evorp.player.notify(player, "This door cannot be viewed!", 1);
		
		-- Return false because this door cannot be viewed.
		return false;
	end;
end;

-- Add the hook.
evorp.hook.add("PlayerCanViewDoor", PLUGIN.playerCanViewDoor);

-- Called when a player attempts to iwn a door.
function PLUGIN.playerCanOwnDoor(player, door)
	if (door._Unownable) then
		evorp.player.notify(player, "This door cannot be owned!", 1);
		
		-- Return false because this door cannot be owned.
		return false;
	end;
end;

-- Add the hook.
evorp.hook.add("PlayerCanOwnDoor", PLUGIN.playerCanOwnDoor);

-- A function to save the unownable doors.
function PLUGIN.saveUnownable()
	local unownable = {};
	
	-- Loop through the spawn points and add it to our table.
	for k, v in pairs(PLUGIN.unownable) do
		local data = {
			position = v.position.x..", "..v.position.y..", "..v.position.z,
			name = v.name
		};
		
		-- Insert the data into the unownable table.
		table.insert(unownable, data);
	end;
	
	-- Write the spawn points to our map file.

	file.Write( "evorp/plugins/unownable/"..game.GetMap()..".txt", util.TableToKeyValues(unownable) );
end;

-- A command to add a jail point.
evorp.command.add("unownable", "s", 0, function(player, arguments)
	local door = player:GetEyeTrace().Entity;
	
	-- Check if this entity is a valid door.
	if ( IsValid(door) and evorp.entity.isDoor(door) ) then
		if (arguments[1] != "remove") then
			if (!door._Unownable) then
				local data = {
					position = door:GetPos(),
					entity = door,
					name = table.concat(arguments or {}, " ") or ""
				};
				
				-- Set some information about the door.
				door._Owner = nil;
				door._Unownable = true;
				
				-- Set some network variables about the entity.
				door:SetNetworkedString("evorp_Name", data.name);
				door:SetNetworkedBool("evorp_Unownable", true);
				
				-- Insert the data into the unownable table.
				table.insert(PLUGIN.unownable, data);
				
				-- Save the unownable doors.
				PLUGIN.saveUnownable();
				
				-- Print a message to the player to tell them that an unownable door has been added.
				evorp.player.printMessage(player, "You have added an unownable door.");
			end;
		else
			if (door._Unownable) then
				door._Unownable = nil;
				
				-- Set some network variables about the entity.
				door:SetNetworkedString("evorp_Name", "");
				door:SetNetworkedBool("evorp_Unownable", false);
				
				-- Loop through the unownable table to find our door.
				for k, v in pairs(PLUGIN.unownable) do
					if (v.entity == door) then PLUGIN.unownable[k] = nil; end;
				end;
				
				-- Save the unownable doors.
				PLUGIN.saveUnownable();
				
				-- Print a message to the player to tell them that an unownable door has been removed.
				evorp.player.printMessage(player, "You have removed an unownable door.");
			else
				evorp.player.printMessage(player, "This is not an unownable door.");
			end;
		end;
	else
		evorp.player.notify(player, "This is not a valid door!", 1);
	end;
end, "Super Admin Commands", "<name|remove>", "Add (and name) or remove an unownable door.");


-- Register the plugin.
evorp.plugin.register(PLUGIN)
