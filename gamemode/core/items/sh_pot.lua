--[[
Name: "sh_kevlar.lua".
Product: "EvoRP (Roleplay)".
--]]

if ( !evorp.plugin.get("Generic") ) then return; end;

-- Define the item table.
local ITEM = {};

-- Set some information about the item.
ITEM.name = "Weed Plant";
ITEM.size = 1;
ITEM.cost = 175;
ITEM.category = "Black Market"
ITEM.model = "models/nater/weedplant_pot_dirt.mdl";
ITEM.batch = 10;
ITEM.store = true;
ITEM.plural = "Weed Plants";
ITEM.uniqueID = "pot";
ITEM.description = "A weed plant, just put it under some light and it'll start growing.";

-- Called when a player uses the item.
function ITEM:onUse(player)
	local entity = ents.Create("weed_plant");
	if (player:GetCount("pot") <= 4) then
		if (player:GetPos():Distance(player:GetEyeTrace().HitPos) < 128) then
			entity:SetPos(player:GetEyeTrace().HitPos + player:GetEyeTrace().HitNormal * 32);
			entity:SetNetworkedString("evorp_grower", player:Nick())
			entity:Spawn();
			entity:GetPhysicsObject():Wake();
			player:AddCount("pot", entity);
			entity:StartGrowing();
			entity:CPPISetOwner(player)
		else
			evorp.player.notify(player, "You can't put your plant so far away!", 1);
			return false;
		end
	else
		evorp.player.notify(player, "You can only 5 weed plants!", 1);
		return false;
	end
end;

-- Called when a player drops the item.
function ITEM:onDrop(player, position) end;

-- Called when a player destroys the item.
function ITEM:onDestroy(player) end;

-- Register the item.
evorp.item.register(ITEM);
