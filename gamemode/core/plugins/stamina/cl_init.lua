--[[
Name: "cl_init.lua".
Product: "EvoRP (Roleplay)".
--]]

local PLUGIN = {};

-- Create a variable to store the plugin for the shared file.
PLUGIN_SHARED = PLUGIN;

-- Include the shared file.
include("sh_init.lua");

-- Called when the bottom bars should be drawn.
evorp.hook.add("DrawBottomBars", function(bar)
	local stamina = LocalPlayer()._Stamina or 100;
	
	-- Check if the stamina is smaller than 100.
	if (stamina < 100) then
		GAMEMODE:DrawBar("Default", bar.x, bar.y, bar.width, bar.height, Color(50, 50, 255, 200), "Stamina: "..stamina, 100, stamina, bar);
	end;
end);

-- Called when the local player presses a bind.
evorp.hook.add("PlayerBindPress", function(player, bind, pressed)
	local stamina = LocalPlayer()._Stamina or 100;
	
	-- Check if the stamina is smaller than 10.
	if (stamina < 5) then
		if ( string.find(bind, "+jump") ) then return true; end;
	end;
end);

-- Register the plugin.
evorp.plugin.register(PLUGIN);
