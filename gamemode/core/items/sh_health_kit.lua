--[[
Name: "sh_health_kit.lua".
Product: "EvoRP (Roleplay)".
--]]

if ( !evorp.plugin.get("Generic") ) then return; end;

-- Define the item table.
local ITEM = {};

-- Set some information about the item.
ITEM.name = "Health Kit";
ITEM.size = 2;
ITEM.cost = 450;
ITEM.category = "Supplies/Misc"
ITEM.model = "models/items/healthkit.mdl";
ITEM.batch = 10;
ITEM.store = true;
ITEM.plural = "Health Kits";
ITEM.uniqueID = "health_kit";
ITEM.description = "A health kit which restores upto 200 health.";

-- Called when a player uses the item.
function ITEM:onUse(player)
	if (CLIENT) then return end
	if (player:GetCount("healthkits") > 0) then
		evorp.player.notify(player, "You already have a spawned health kit!", 1);
		return false
	end
	local throwable = ents.Create("activated_medkit")
	throwable:SetPos((player:GetPos() + player:GetForward() * 64) + Vector(0,0,64) )
	--throwable:SetPos(player:GetPos() + Vector(0, 32, 64))
	throwable:SetAngles(player:EyeAngles() - Angle(45, 0, 0))
	throwable:SetOwner(player)
	throwable:Spawn()
	throwable:CPPISetOwner(player);
	throwable.Owner = player
	player:AddCount("healthkits", throwable )
end;

-- Called when a player drops the item.
function ITEM:onDrop(player, position) end;

-- Called when a player destroys the item.
function ITEM:onDestroy(player) end;

-- Register the item.
evorp.item.register(ITEM);