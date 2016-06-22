--[[
Name: "cl_init.lua".
Product: "EvoRP (Roleplay)".
--]]

local PLUGIN = {};

-- Create a variable to store the plugin for the shared file.
PLUGIN_SHARED = PLUGIN;

-- Include the shared file.
include("sh_init.lua");

-- Set some information for the head bob.
PLUGIN.x = 0;
PLUGIN.y = 0;
PLUGIN.angle = 0;

-- Create a client ConVar for head bobbing.
CreateClientConVar("evorp_headbob", 0, true, true);

-- Called when the view should be calculated.
evorp.hook.add("CalcView", function(player, origin, angles, fov)
	if (GetConVarNumber("evorp_headbob") == 1) then
		if ( ( player:KeyDown(IN_FORWARD) or player:KeyDown(IN_BACK) or player:KeyDown(IN_MOVERIGHT)
		or player:KeyDown(IN_MOVELEFT) ) and player:IsOnGround() ) then
			local view = {};
			
			-- Set some information for the view.
			view.origin = origin;
			view.angles = angles;
			
			-- Check if the player is running.
			if ( player:GetVelocity():Length() > (evorp.configuration["Run Speed"] - 25) ) then
				PLUGIN.angle = PLUGIN.angle + 10 * FrameTime();
				
				-- Set some information for the view angles.
				view.angles.pitch = view.angles.pitch + math.sin(PLUGIN.angle) * 0.5;
				view.angles.yaw = view.angles.yaw + math.cos(PLUGIN.angle) * 0.2;
			else
				PLUGIN.angle = PLUGIN.angle + 6 * FrameTime();
				
				-- Set some information for the view angles.
				view.angles.pitch = view.angles.pitch + math.sin(PLUGIN.angle) * 0.5;
				view.angles.yaw = view.angles.yaw + math.cos(PLUGIN.angle) * 0.3;
			end;
			
			-- Return the new view.
			return view;
		end;
		
		-- Create a new view table.
		local view = {};
		
		-- Set some information for the view.
		view.origin = origin;
		view.angles = angles;
		
		-- Set some information for the view angles.
		view.angles.pitch = view.angles.pitch + math.sin(PLUGIN.angle);
		view.angles.yaw = view.angles.yaw + math.cos(PLUGIN.angle);
		
		-- Return the new view.
		return view;
	end;
end);

-- Register the plugin.
evorp.plugin.register(PLUGIN);
