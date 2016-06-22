--[[
Name: "sh_chinese.lua".
Product: "EvoRP (Roleplay)".
--]]

-- Define the item table.
local ITEM = {};

-- Set some information about the item.
ITEM.name = "Weapon Attachment Kit";
ITEM.size = 1;
ITEM.cost = 500;
ITEM.category = "Weaponry"
ITEM.model = "models/Items/item_item_crate.mdl";
ITEM.batch = 10;
ITEM.store = false;
ITEM.plural = "Weapon Attachment Kits";
ITEM.uniqueID = "attach";
ITEM.description = "A kit of gun parts and sights.";

-- Called when a player uses the item.
function ITEM:onUse(player)
	player.UsedAttachmentItem = true
	TWeps_PlayerSpawn(player)
	player.UsedAttachmentItem = false;
	player.AttachmentKit = true;
	return true;
end;

-- Called when a player drops the item.
function ITEM:onDrop(player, position) end;
-- Called when a player destroys the item.
function ITEM:onDestroy(player) end;

-- Register the item.
evorp.item.register(ITEM);