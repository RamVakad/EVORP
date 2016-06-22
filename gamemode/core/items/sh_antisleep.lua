--[[
Name: "sh_nitrazepam.lua".
Product: "EvoRP (Roleplay)".
--]]

if ( !evorp.plugin.get("Generic") ) then return; end;

-- Define the item table.
local ITEM = {};

-- Set some information about the item.
ITEM.name = "Epinephrine Autoinjector";
ITEM.size = 1;
ITEM.cost = 500;
ITEM.category = "Supplies/Misc"
ITEM.model = "models/weapons/w_pistol.mdl";
ITEM.batch = 10;
ITEM.store = true;
ITEM.plural = "Epinephrine Autoinjector";
ITEM.uniqueID = "asleep";
ITEM.description = "Look at a knocked out person and use this item wake them up.";

-- Called when a player uses the item.
function ITEM:onUse(player)
	if (CLIENT) then return end;
	local trace = player:GetEyeTrace();
	if (trace.Entity:GetClass() == "prop_ragdoll") then
		trace.Entity = trace.Entity._Player;
	end
	if (trace.Entity:Alive() and trace.Entity._KnockedOut and !trace.Entity:GetNetworkedBool("FakeDeathing")) then
		trace.Entity:EmitSound( "weapons/crossbow/bolt_fly4.wav" )
		evorp.player.knockOut(trace.Entity, false);
		player._Sleeping = false;
		evorp.player.printConsoleAccess(player:Nick().." ["..player:SteamID().."] woke up "..trace.Entity:Nick().." ["..trace.Entity:SteamID().."].", "a", player);
		local team = player:Team()
		evorp.command.ConCommand(player, "me shoots "..trace.Entity:GetNetworkedString("evorp_NameIC").." with a shot of EPI.");
	end
end;

-- Called when a player drops the item.
function ITEM:onDrop(player, position) end;

-- Called when a player destroys the item.
function ITEM:onDestroy(player) end;

-- Register the item.
evorp.item.register(ITEM);