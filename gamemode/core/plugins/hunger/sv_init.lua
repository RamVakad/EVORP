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

-- Called when a player initially spawns.
function PLUGIN.playerInitialSpawn(player) player._Hunger = {}; end;

-- Add the hook.
evorp.hook.add("PlayerInitialSpawn", PLUGIN.playerInitialSpawn);

-- Called when a player has initialized.
function PLUGIN.playerInitialized(player)
	player._Hunger.lastTeam = nil;
	player._Hunger.suicided = false;
end;

-- Add the hook.
evorp.hook.add("PlayerInitialized", PLUGIN.playerInitialized);

-- Called when a player spawns.
function PLUGIN.postPlayerSpawn(player, lightSpawn, changeTeam)
	--[[
	if (!player.ShownHelp) then
		gamemode.Call("ShowHelp", player)
		gamemode.Call("ShowHelp", player)
		gamemode.Call("ShowHelp", player)
		player.ShownHelp = true;
	end
	]]
	if (!lightSpawn) then
		if ( (player._Hunger.suicided or player._Hunger.amount == 100)
		and player._Hunger.lastTeam and player:Team() == player._Hunger.lastTeam ) then
			player._Hunger.amount = 25;
		else
			player._Hunger.amount = 50;
		end;
	end;
	
	-- Set the last team.
	player._Hunger.lastTeam = player:Team();
	player._Hunger.suicided = false;
end;

-- Add the hook.
evorp.hook.add("PostPlayerSpawn", PLUGIN.postPlayerSpawn);

-- Called when a player dies.
function PLUGIN.playerDeath(player, inflictor, killer)
	if ( player == killer or !killer:IsPlayer() ) then
		player._Hunger.suicided = true;
	end;
end;

-- Add the hook.
evorp.hook.add("PlayerDeath", PLUGIN.playerDeath);

-- Called every second that a player is on the server.
function PLUGIN.playerSecond(player)
	if (player:Alive() and !player.evorp._Arrested) then
		player._Hunger.amount = math.Clamp(player._Hunger.amount + 0.04, 0, 100);
		player.evorp._PlayTime = player.evorp._PlayTime + 1;
		-- Set it so that we can get the player's hunger client side.
		evorp.player.setLocalPlayerVariable( player, CLASS_LONG, "_Hunger", math.Round(player._Hunger.amount) );
		if(player._Hunger.amount > 94 and player:Alive() and !player:GetNetworkedBool("FakeDeathing") ) then
			player:PrintMessage(HUD_PRINTCENTER, "You're VERY hungry. You need to eat something!")
		end
		-- Check the player's hunger to see if it's at it's maximum.
		if (player._Hunger.amount == 100) then			
			-- Check if the player is knocked out.
			if (player._KnockedOut) then
					player:TakeDamage(2, player);
			else
					player:TakeDamage(5, player)
			end;
		end;
		--[[
		if (player._KnockedOut and player._Sleeping and !player.Regen) then
			player._Ragdoll.health = math.Clamp(player:Health() + 1, 0, 100)
			player:SetHealth( math.Clamp(player:Health() + 1, 0, 100) )
			player.Regen = true
		else
			player.Regen = false
		end]]
	end;
end;

-- Add the hook.
evorp.hook.add("PlayerSecond", PLUGIN.playerSecond);

-- Register the plugin.
evorp.plugin.register(PLUGIN);
