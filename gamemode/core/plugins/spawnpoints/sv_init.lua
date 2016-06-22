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

-- A function to load the player spawn points.
function PLUGIN.loadSpawnPoints()
	PLUGIN.spawnPoints = {};
    local f = file.Open("evorp/plugins/spawnpoints/"..game.GetMap()..".txt", "rb", "DATA")
	-- Check to see if there are spawn points for this map.
	if ( f ) then
        f:Close();
		local spawnPoints = util.KeyValuesToTable( file.Read("evorp/plugins/spawnpoints/"..game.GetMap()..".txt") );
		
		-- Loop through the spawn points and convert them to a vector.
		for k, v in pairs(spawnPoints) do
			local team = evorp.team.get(k);
			
			-- Check if the team is valid.
			if (team) then
				PLUGIN.spawnPoints[team.name] = {};
				
				-- Loop through the spawn points for this team.
				for k2, v2 in pairs(v) do
					local x, y, z = string.match(v2, "(.-), (.-), (.+)");
					
					-- Insert the data into our spawn points table.
					table.insert( PLUGIN.spawnPoints[team.name], Vector( tonumber(x), tonumber(y), tonumber(z) ) );
				end;
			end;
		end;
	end;
end;

-- Load the player spawn points.
PLUGIN.loadSpawnPoints();

-- A function to save the player spawn points.
function PLUGIN.saveSpawnPoints()
	local spawnPoints = {};
	
	-- Loop through the spawn points and add it to our table.
	for k, v in pairs(PLUGIN.spawnPoints) do
		spawnPoints[k] = {};
		
		-- Loop through the spawn points for this team.
		for k2, v2 in pairs(v) do
			table.insert(spawnPoints[k], v2.x..", "..v2.y..", "..v2.z);
		end;
	end;
	
	-- Write the spawn points to our map file.
	file.Write( "evorp/plugins/spawnpoints/"..game.GetMap()..".txt", util.TableToKeyValues(spawnPoints) );
end;

-- Called when a player spawns.
function PLUGIN.postPlayerSpawn(player, light)
	local team = evorp.team.get( player:Team() );
	
	-- Check if the team is valid.
	if (team) then
		if (PLUGIN.spawnPoints[team.name]) then
			if (#PLUGIN.spawnPoints[team.name] > 0) then
				local position = PLUGIN.spawnPoints[team.name][ math.random( 1, #PLUGIN.spawnPoints[team.name] ) ];
				
				-- Check if the position is valid.
				if (position) then player:SetPos( position + Vector(0, 0, 16) ); end;
			end;
		end;
	end;
end;

-- Add the hook.
evorp.hook.add("PostPlayerSpawn", PLUGIN.postPlayerSpawn);

-- A command to add a player spawn point.
evorp.command.add("spawnpoint", "s", 2, function(player, arguments)
	local team = evorp.team.get( arguments[1] );
	
	-- Check if the team is valid.
	if (team) then
		if (arguments[2] == "add") then
			PLUGIN.spawnPoints[team.name] = PLUGIN.spawnPoints[team.name] or {};
			
			-- Get a trace line from the player to get the hit position.
			local position = player:GetEyeTrace().HitPos;
			
			-- Add the position to our spawn points table.
			table.insert(PLUGIN.spawnPoints[team.name], position);
			
			-- Save the spawn points.
			PLUGIN.saveSpawnPoints();
			
			-- Print a message to the player tell tell him that the spawnpoint has been added.
			evorp.player.printMessage(player, "You have added a spawn point for "..team.name..".");
		elseif (arguments[2] == "remove") then
			if (PLUGIN.spawnPoints[team.name]) then
				local position = player:GetEyeTrace().HitPos;
				local removed = 0;
				
				-- Loop through our player spawn points to find ones near this position.
				for k, v in pairs(PLUGIN.spawnPoints[team.name]) do
					if (v:Distance(position) <= 256) then
						PLUGIN.spawnPoints[team.name][k] = nil;
						
						-- Increase the amount that we removed.
						removed = removed + 1;
					end;
				end;
				
				-- Check if we removed more than 0 spawn points.
				if (removed > 0) then
					if (removed == 1) then
						evorp.player.printMessage(player, "You have removed "..removed.." "..team.name.." spawn point.");
					else
						evorp.player.printMessage(player, "You have removed "..removed.." "..team.name.." spawn points.");
					end;
				else
					evorp.player.printMessage(player, "There were no "..team.name.." spawn points near this position.");
				end;
			else
				evorp.player.printMessage(player, "There are no "..team.name.." spawn points.");
			end;
			
			-- Save the player spawn points.
			PLUGIN.saveSpawnPoints();
		end;
	else
		evorp.player.notify(player, "This is not a valid team!", 1);
	end;
end, "Super Admin Commands", "<team> <add|remove>", "Add or remove a spawn point for a team.");

-- Register the plugin.
evorp.plugin.register(PLUGIN)
