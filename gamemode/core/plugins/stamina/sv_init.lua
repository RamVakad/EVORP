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

-- Called when a player spawns.
function PLUGIN.postPlayerSpawn(player, lightSpawn, changeTeam)
	if (!lightSpawn) then player._Stamina = 100; end;
end;

-- Add the hook.
evorp.hook.add("PostPlayerSpawn", PLUGIN.postPlayerSpawn);

-- Called when a player presses a key.
function PLUGIN.keyPress(player, key)
	if (!player.evorp._Arrested) then
		if (player:Alive() and !player._KnockedOut) then
			if (player:IsOnGround() and key == IN_JUMP) then
				player._Stamina = math.Clamp(player._Stamina - 5, 0, 100);
			end;
		end;
	end;
end;

-- Add the hook.
evorp.hook.add("KeyPress", PLUGIN.keyPress);

-- Called every tenth of a second that a player is on the server.
function PLUGIN.playerTenthSecond(player)
	if (!player.evorp._Arrested) then
		if (!player:GetNWBool("evorp_Exausted") and (player:KeyDown(IN_SPEED) or player:KeyDown(IN_DUCK)) and player:Alive() and !player._KnockedOut and !(player:GetNetworkedInt("LastRevive") + 60 > CurTime())
		and player:GetVelocity():Length() > 0) then
			if (player:Health() < 50) then
				player._Stamina = math.Clamp(player._Stamina - (0.50 + ( ( 50 - player:Health() ) * 0.05 ) ), 0, 100);
			else
				player._Stamina = math.Clamp(player._Stamina - 0.50, 0, 100);
			end;
		else
			if (player:Health() < 50) then
				player._Stamina = math.Clamp(player._Stamina + (0.25 - ( ( 50 - player:Health() ) * 0.0025 ) ), 0, 100);
			else
				player._Stamina = math.Clamp(player._Stamina + 0.25, 0, 100);
			end;
		end;
		
		if (player._Stamina <= 1 or player:GetNetworkedBool("cuffed") or player:GetNetworkedBool("hostaged") or player:GetNetworkedInt("LastRevive") + 60 > CurTime()) then
			player:SetWalkSpeed(evorp.configuration["Walk Speed"]);
			player:SetRunSpeed(evorp.configuration["Walk Speed"]);
		elseif (player:KeyDown(IN_WALK)) then
			player:SetWalkSpeed(evorp.configuration["Walk Speed"]);
		else
			player:SetRunSpeed(evorp.configuration["Run Speed"]);
			player:SetWalkSpeed(evorp.configuration["Jog Speed"]);
		end;
	end;
	
	-- Set it so that we can get the player's stamina client side.
	evorp.player.setLocalPlayerVariable( player, CLASS_LONG, "_Stamina", math.Round(player._Stamina) );

end;

-- Add the hook.
evorp.hook.add("PlayerTenthSecond", PLUGIN.playerTenthSecond);

-- Register the plugin.
evorp.plugin.register(PLUGIN)
