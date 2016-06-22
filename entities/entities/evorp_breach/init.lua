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
	self:SetModel("models/weapons/w_c4_planted.mdl");
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

-- A function to set the door for the entity to breach.
function ENT:SetDoor(door, trace)
	self._Door = door;
	self._Door:DeleteOnRemove(self);
	
	-- Set the position and angles of the entity.
	self:SetPos(trace.HitPos);
	self:SetAngles( trace.HitNormal:Angle() + Angle(90, 0, 0) );
	
	if (door:GetClass() != "prop_dynamic") then
		constraint.Weld(door, self, 0, 0);
	else
		if ( IsValid( self:GetPhysicsObject() ) ) then
			self:GetPhysicsObject():EnableMotion(false);
		end;
	end;

	self:Beep()
	local i = 1
	timer.Create(self:EntIndex().."Beep1",1,5,function()
		if not (IsValid(self) and IsValid(self._Door)) then return end
		if i == 5 then
			timer.Create(self:EntIndex().."Beep2",0.2,5, function ()
				if not (IsValid(self) and IsValid(self._Door)) then return end
				self:Beep()
			end)
		end
		self:Beep()
		i = i + 1
	end)
	timer.Create("Breach", 6.1, 1, function() 
		if not (IsValid(self) and IsValid(self._Door)) then return end
		evorp.entity.openDoor(self._Door, 0, true, true);
		if self._Door:GetClass() == "prop_door_rotating" then
			self:BlowDoorOffItsHinges()
		else
			trace.Entity:Fire("unlock", "", .5)
			trace.Entity:Fire("open", "", .6)
			trace.Entity:Fire("setanimation","open","0")
			trace.Entity.iOpen = true;
			trace.Entity:Fire("lock", "", .5)
		end
		self:Explode();
		self:Remove();
	end)
end;

local function dothrow(ent,backwards)
	if not IsValid(ent) then return end
	local pent = ent:GetPhysicsObject()
	if not IsValid(pent) then return end
	pent:ApplyForceCenter(backwards * 10000)
end

function ENT:BlowDoorOffItsHinges()
	local backwards = self:GetUp() * -1 -- If you fuck with the model, this won't work
	local pos   = self._Door:GetPos()
	local ang   = self._Door:GetAngles()
	local model = self._Door:GetModel()
	local skin  = self._Door:GetSkin()
	self._Door:SetNotSolid(true)
	self._Door:SetNoDraw(true)
	local ent = ents.Create("prop_physics")
	ent:SetPos(pos)
	ent:SetAngles(ang)
	ent:SetModel(model)
	if (skin) then
		ent:SetSkin(skin)
	end
	ent:Spawn()
	ent:Activate()
	local door = self._Door
	timer.Create("DoThrow",.1,1,function() 
		if not IsValid(ent) then return end
		local pent = ent:GetPhysicsObject()
		if not IsValid(pent) then return end
		pent:ApplyForceCenter(backwards * 10000)
	end)
	timer.Create("DoRemove", 40,1,function() 
		if IsValid(ent) then
			ent:Remove()
		end
		if IsValid(door) then
			door:SetNotSolid(false)
			door:SetNoDraw(false)
		end
	end)
end

--[[
-- Called every frame.
function ENT:Think()
	self:SetNetworkedInt( "evorp_Health", math.Round( self:Health() ) );
end;]]

local beep = Sound("hl1/fvox/beep.wav")
function ENT:Beep()
	self:EmitSound(beep)
end

-- Explode the entity.
function ENT:Explode()
	local effectData = EffectData();
	
	-- Set the information for the effect.
	effectData:SetStart( self:GetPos() );
	effectData:SetOrigin( self:GetPos() );
	effectData:SetScale(1);
	
	-- Create the effect from the data.
	util.Effect("Explosion", effectData);
end;

-- Called when the entity takes damage.
--[[
function ENT:OnTakeDamage(damageInfo)
	self:SetHealth( math.max(self:Health() - damageInfo:GetDamage(), 0) );
	
	-- Check if the entity has run out of health.
	if (self:Health() <= 0) then
		self:Explode();
		self:Remove();
		
		-- Open the door instantly as if it's been blown open.
		evorp.entity.openDoor(self._Door, 0, true, true);
	end;
end;
]]