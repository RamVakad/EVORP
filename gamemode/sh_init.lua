--[[
Name: "sh_init.lua".
Product: "EvoRP (Roleplay)".
--]]



GM.Name = "EVORP";
GM.Email = "EVOROLEPLAY1@GMAIL.COM";
GM.Author = "Int64";
GM.Website = "HTTP://EVORP.NET";

-- Derive the gamemode from sandbox.
DeriveGamemode("Sandbox");

-- I do this because I use some of these variable names a lot by habbit.
for k, v in pairs(_G) do
	if (!tonumber(k) and type(v) == "table") then
		if (!string.find(k, "%u") and string.sub(k, 1, 1) != "_") then
			_G[ "g_"..string.upper( string.sub(k, 1, 1) )..string.sub(k, 2) ] = v;
		end;
	end;
end;

-- Create the EvoRP table and the configuration table.
evorp = {};
evorp.configuration = {};

-- Include the configuration and enumeration files.
include("core/sh_configuration.lua");
include("core/sh_enumerations.lua");

-- Check if we're running on the server.
if (SERVER) then include("core/sv_configuration.lua"); end;

-- Loop through libraries and include them.
for k, v in pairs( file.Find("evorp/gamemode/core/libraries/*.lua", "LUA") ) do
	if (SERVER) then
		if (string.sub(v, 1, 3) == "sv_" or string.sub(v, 1, 3) == "sh_") then
			include("core/libraries/"..v);
		end;
		if (string.sub(v, 1, 3) == "cl_" or string.sub(v, 1, 3) == "sh_") then
			AddCSLuaFile("core/libraries/"..v);
		end;
	else
		if (string.sub(v, 1, 3) == "cl_" or string.sub(v, 1, 3) == "sh_") then
			include("core/libraries/"..v);
		end;
	end;
end;

-- Check if we're running on the server.
if (SERVER) then include("core/sv_commands.lua"); end;

local a, b = file.Find("evorp/gamemode/core/plugins/*", "LUA");
-- Loop through plugins and include them.
for k, v in pairs( b ) do
	for k2, v2 in pairs( file.Find("evorp/gamemode/core/plugins/"..v.."/*.lua", "LUA") ) do
		if (SERVER) then
			if (string.sub(v2, 1, 3) == "sv_" or string.sub(v, 1, 3) == "sh_") then
				include("core/plugins/"..v.."/"..v2);
			end;
			if (string.sub(v2, 1, 3) == "cl_" or string.sub(v, 1, 3) == "sh_") then
				AddCSLuaFile("core/plugins/"..v.."/"..v2);
			end;
		else
			if (string.sub(v2, 1, 3) == "cl_" or string.sub(v, 1, 3) == "sh_") then
				include("core/plugins/"..v.."/"..v2);
			end;
		end;
	end;
end;

-- Loop through items and include them.
for k, v in pairs( file.Find("evorp/gamemode/core/items/*.lua", "LUA") ) do
	include("core/items/"..v);
	
	-- Check to see if we're running on the server.
	if (SERVER) then AddCSLuaFile("core/items/"..v); end;
end;

-- Loop through derma panels and include them.
for k, v in pairs( file.Find("evorp/gamemode/core/derma/*.lua", "LUA") ) do
	if (CLIENT) then include("core/derma/"..v); else AddCSLuaFile("core/derma/"..v); end;
end;
