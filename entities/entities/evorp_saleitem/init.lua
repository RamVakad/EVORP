--[[
Name: "cl_init.lua".
Product: "EvoRP (Roleplay)".
--]]

include("sh_init.lua");

-- Add the files that need to be sent to the client.
AddCSLuaFile("cl_init.lua");
AddCSLuaFile("sh_init.lua");

-- This is called when the entity initializes.
function ENT:Initialize()
	self:SetMoveType(MOVETYPE_VPHYSICS);
	self:PhysicsInit(SOLID_VPHYSICS);
	self:SetSolid(SOLID_VPHYSICS);
	self:SetUseType(SIMPLE_USE);
	
	-- Get the physics object of the entity.
	local physicsObject = self:GetPhysicsObject();

	-- Check if the physics object is a valid entity.
	if ( IsValid(physicsObject) ) then
		physicsObject:Wake();
		physicsObject:EnableMotion(true);
	end;
	self.nodupe = true
end;

-- A function to set the item of the entity.
function ENT:SetItem(item, player)
	if (evorp.item.stored[item]) then
		self._Item = item;
		self._UniqueID = evorp.item.stored[item].uniqueID;
		self._Playe = player;
		self._Price = 0;

		self:SetModel(evorp.item.stored[item].model);
		
		-- Set the networked variables so the client can get the information.
		self:SetNetworkedString("evorp_Name", evorp.item.stored[item].name);
		self:SetNetworkedEntity("saleitem_Player", self._Playe)
		self:SetNetworkedInt("evorp_Price", self._Price)
	end;
end;

-- Called when the entity is used.
function ENT:Use(activator, caller)
	if (activator._LastSellEPress) then
		if not (CurTime() - .5 < activator._LastSellEPress) then
			activator._LastSellEPress = CurTime()
			return;
		end
	else
		activator._LastSellEPress = CurTime();
		return;
	end
	if (activator == self._Playe) then
		self:Remove();
		return;
	end
	if ( self._Price > 0 and activator and activator:IsPlayer() and IsValid(self._Playe) and self._Playe:Alive() and !self._Playe._KnockedOut and self:GetPos():Distance(self._Playe:GetPos()) < 500 and activator != self._Playe and  self._Playe.evorp._Inventory[self._Item] and self._Playe.evorp._Inventory[self._Item] > 0 and evorp.player.canAfford(activator, self._Price) and evorp.inventory.canFit(activator, evorp.item.stored[self._Item].size)) then
		evorp.player.giveMoney(activator, -self._Price)
		evorp.player.giveMoney(self._Playe, self._Price)
		evorp.inventory.update(self._Playe, self._Item, -1);
		evorp.inventory.update(activator, self._Item, 1);
		evorp.player.notify(activator, "Your item is in your inventory!", 0);
		evorp.player.notify(self._Playe, activator:Nick().." bought an item from you: "..evorp.item.stored[self._Item].name.." for $"..self._Price, 0);
		evorp.player.printConsoleAccess(activator:Name() .. " [".. activator:SteamID() .. "]".. " bought item (".. self._UniqueID .. ") from "..self._Playe:Nick().." ["..self._Playe:SteamID().."]", "a", activator)
		--if not (self._Playe.evorp._Inventory[self._Item] and self._Playe.evorp._Inventory[self._Item] > 0) then
			self:Remove();
		--end
	else
		if (!IsValid(self._Playe)) then
			evorp.player.notify(activator, "The seller is not online!", 0);
		elseif not (self._Playe.evorp._Inventory[self._Item] and self._Playe.evorp._Inventory[self._Item] > 0) then
			evorp.player.notify(activator, "The seller is out of stock on this item.", 0);
			self:Remove();
		elseif not (self:GetPos():Distance(self._Playe:GetPos()) < 500) then
			evorp.player.notify(activator, "The vendor of this item is not here!", 0);
		elseif (!self._Playe:Alive() or self._Playe._KnockedOut) then
			evorp.player.notify(activator, "The seller is knocked out on this item.", 0);
		elseif (!evorp.inventory.canFit(activator, evorp.item.stored[self._Item].size)) then
			evorp.player.notify(activator, "You don't have enough inventory space!", 0);
		elseif (self._Price > 0) then
			evorp.player.notify(activator, "The item has not been priced yet!", 0);
		else
			evorp.player.notify(activator, "You don't have enough money!", 1);
		end
	end
end;