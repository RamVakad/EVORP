--[[
Name: "sh_kevlar.lua".
Product: "EvoRP (Roleplay)".
--]]

if ( !evorp.plugin.get("Generic") ) then return; end;

-- Define the item table.
local ITEM = {};

-- Set some information about the item.
ITEM.name = "Bag of Weed";
ITEM.size = 1;
ITEM.cost =  50;
ITEM.category = "Supplies/Misc"
ITEM.model = "models/katharsmodels/contraband/zak_wiet/zak_wiet.mdl";
ITEM.batch = 1;
ITEM.store = false;
ITEM.plural = "Weed Bags";
ITEM.uniqueID = "weed";
ITEM.description = "A bag of weed. Don't be hatin; keep on tokin.'";

-- Called when a player uses the item.
function ITEM:onUse(player)
	if( math.random(1,10) == 1 )then
		evorp.player.knockOut(player, true, 60)
	else
		--player._Stoned = true;
		player:ConCommand("pp_bloom 1")
		player:ConCommand("pp_bloom_passes 10")
		player:ConCommand("pp_bloom_darken 0.35")
		player:ConCommand("pp_bloom_multiplayer 2")
		player:ConCommand("pp_bloom_sizex 0")
		player:ConCommand("pp_bloom_sizey 5")
		player:ConCommand("pp_bloom_color 1")
		timer.Simple( 60, function() 
			if (IsValid(player)) then
				player:ConCommand("pp_bloom 0")
				--player._Stoned = false;	
			end	
		end )
		
		local sayings = {
			"hey gise. what if like the universe was just an videogame!!??!1 holy craaaap that would be awesomeeeeee",
			"does any1 hav goldfish!?1 i want goldfish plz thx",
			"hi how do i walk i cant figure it out"
		}
		player:ConCommand("say "..sayings[math.random(1,#sayings)])
	end

	return true;
end;

-- Called when a player drops the item.
function ITEM:onDrop(player, position) end;

-- Called when a player destroys the item.
function ITEM:onDestroy(player) end;
function ITEM:onSell(player) end;

-- Register the item.
evorp.item.register(ITEM);
