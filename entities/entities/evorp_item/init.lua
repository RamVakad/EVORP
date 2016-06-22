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
	SafeRemoveEntityDelayed(self, 1800)
	-- Check if the physics object is a valid entity.
	if ( IsValid(physicsObject) ) then
		physicsObject:Wake();
		physicsObject:EnableMotion(true);
	end;
	self.nodupe = true
end;

-- A function to set the item of the entity.
function ENT:SetItem(item, amount)
	if (evorp.item.stored[item]) then
		self._UniqueID = evorp.item.stored[item].uniqueID;
		self._Name = evorp.item.stored[item].name;
		self._Size = evorp.item.stored[item].size;
		self._Amount = amount;

		self:SetModel(evorp.item.stored[item].model);
		
		-- Set the networked variables so the client can get the information.
		self:SetNetworkedString("evorp_Name", self._Name);
		self:SetNetworkedInt("evorp_Size", self._Size);
		self:SetNetworkedInt("evorp_iAmount", self._Amount);
	end;
end;

-- Called when the entity is used.
function ENT:Use(activator, caller)
	if ( activator:IsPlayer() ) then
		if (self._Size) then
			local success, fault = evorp.inventory.update(activator, self._UniqueID, self._Amount);
			
			-- Check if we didn't succeed.
			if (!success) then
				evorp.player.notify(activator, fault, 1);
				
				-- Return here because we can't use it.
				return;
			else
				evorp.player.printConsoleAccess(activator:Name() .. " [".. activator:SteamID() .. "]".. " picked up item (".. self._UniqueID .. "). Amount = "..self._Amount, "a", activator)
				self:Remove();
			end
			
		end;
	end;
end;
