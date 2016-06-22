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

-- A function to load the jail points.
function PLUGIN.loadJailPoints()
	PLUGIN.jailPoints = {};
	local f = file.Open("evorp/plugins/jailpoints/"..game.GetMap()..".txt", "rb", "DATA")
	-- Check to see if there are jail points for this map.
	if ( f ) then
        f:Close();
		local jailPoints = util.KeyValuesToTable( file.Read("evorp/plugins/jailpoints/"..game.GetMap()..".txt", "DATA") );
		
		-- Loop through the spawn points and convert them to a vector.
		for k, v in pairs(jailPoints) do
			local x, y, z = string.match(v, "(.-), (.-), (.+)");
			
			-- Insert the data into our spawn points table.
			table.insert( PLUGIN.jailPoints, Vector( tonumber(x), tonumber(y), tonumber(z) ) );
		end;
	end;
end;

-- Load the jail points.
PLUGIN.loadJailPoints();

-- A function to save the jail points.
function PLUGIN.saveJailPoints()
	local jailPoints = {};
	
	-- Loop through the spawn points and add it to our table.
	for k, v in pairs(PLUGIN.jailPoints) do
		table.insert(jailPoints, v.x..", "..v.y..", "..v.z);
	end;
	
	-- Write the spawn points to our map file.
	file.Write( "evorp/plugins/jailpoints/"..game.GetMap()..".txt", util.TableToKeyValues(jailPoints) );
end;

-- Called when a player is arrested.
function PLUGIN.playerArrested(player)
	local test = player:GetPos()
	if (#PLUGIN.jailPoints > 0) then
		local function getPosition()
			local position = PLUGIN.jailPoints[ math.random(1, #PLUGIN.jailPoints) ];
			
			-- Check if the position is valid.
			if (position) then
				return position;
			else
				return getPosition();
			end;
		end;
		
		local pos = getPosition();
		
		if (!pos) then
			player:PrintMessage(3, "ERROR: PLEASE TELL KUDOMIKU THAT SOMETHING IS WRONG (Code 3)!");
		end;
		
		-- Set the player's position.
		player:SetPos( pos + Vector(0, 0, 16) );
	else
		player:PrintMessage(3, "ERROR: PLEASE TELL KUDOMIKU THAT SOMETHING IS WRONG (Code 1)!");
	end;
	if (player:GetPos() == test) then
		player:PrintMessage(3, "ERROR: PLEASE TELL KUDOMIKU THAT SOMETHING IS WRONG (Code 2)!");
	end
end;

-- A command to add a jail point.
evorp.command.add("jailpoint", "s", 0, function(player, arguments)
	if (arguments[1] == "add") then
		local position = player:GetEyeTrace().HitPos;
		
		-- Add the position to our spawn points table.
		table.insert(PLUGIN.jailPoints, position);
		
		-- Save the spawn points.
		PLUGIN.saveJailPoints();
		
		-- Print a message to the player to tell them that a jail point has been added.
		evorp.player.printMessage(player, "You have added a jail point.");
	elseif (arguments[1] == "remove") then
		local position = player:GetEyeTrace().HitPos;
		local removed = 0;
		
		-- Loop through our jail points to find ones near this position.
		for k, v in pairs(PLUGIN.jailPoints) do
			if (v:Distance(position) <= 256) then
				PLUGIN.jailPoints[k] = nil;
				
				-- Increase the amount that we removed.
				removed = removed + 1;
			end;
		end;
		
		-- Check if we removed more than 0 spawn points.
		if (removed > 0) then
			if (removed == 1) then
				evorp.player.printMessage(player, "You have removed "..removed.." jail point.");
			else
				evorp.player.printMessage(player, "You have removed "..removed.." jail points.");
			end;
		else
			evorp.player.printMessage(player, "There were no jail points near this position.");
		end;
		
		-- Save the jail points.
		PLUGIN.saveJailPoints();
	end;
end, "Super Admin Commands", "<add|remove>", "Add or remove a jail point.");

-- Register the plugin.
evorp.plugin.register(PLUGIN)
