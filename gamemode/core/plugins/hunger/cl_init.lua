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
	local hunger = LocalPlayer()._Hunger or 0;
	
	-- Draw the stamina bar.
	GAMEMODE:DrawBar("Default", bar.x, bar.y, bar.width, bar.height, Color(50, 255, 50, 200), "Hunger: "..hunger, 100, hunger, bar);
end);

-- Register the plugin.
evorp.plugin.register(PLUGIN);
