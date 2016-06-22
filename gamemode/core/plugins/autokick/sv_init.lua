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

-- A function to reset a player's AFK time.
function PLUGIN.resetTime(player)
	local uniqueID = player:UniqueID();
	
	-- Create a timer to kick the player for being AFK.
	timer.Create("Auto Kick: "..uniqueID, 900, 0, function()
		if ( IsValid(player) and player:GetUserGroup() != "superadmin" ) then
			evorp.team.make(player, "Citizen")
			--game.ConsoleCommand("kickid "..player:SteamID().." AFK\n");
		else
			timer.Remove("Auto Kick: "..uniqueID);
		end;
	end);
end;

-- Add the hooks.
evorp.hook.add("PlayerInitialSpawn", PLUGIN.resetTime);
evorp.hook.add("PlayerDeath", PLUGIN.resetTime);
evorp.hook.add("PlayerSpawn", PLUGIN.resetTime);
evorp.hook.add("KeyPress", PLUGIN.resetTime);

-- Register the plugin.
evorp.plugin.register(PLUGIN);
