--[[
Name: "sh_plugin.lua".
Product: "EvoRP (Roleplay)".
--]]

evorp.plugin = {};
evorp.plugin.stored = {};

-- Register a new plugin.
function evorp.plugin.register(plugin)
	evorp.plugin.stored[plugin.name] = plugin;
end;

-- Call a function for all plugins.
function evorp.plugin.call(name, ...)
	for k, v in pairs(evorp.plugin.stored) do
		if (type(v[name]) == "function") then
			local success, message = pcall( v[name], ... )
			
			-- Check to see if we did not success.
			if (!success) then Msg(message.."\n"); end;
		end;
	end;
end;

-- Get a plugin by it's name.
function evorp.plugin.get(name) return evorp.plugin.stored[name]; end;
