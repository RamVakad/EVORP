--[[
Name: "shared.lua".
Product: "EvoRP (Roleplay)".
--]]

if (SERVER) then
	AddCSLuaFile("shared.lua");
end;

SWEP.Author	= "Int64";
local title_color = "<color=230,230,230,255>"
local text_color = "<color=150,150,150,255>"
local end_color = "</color>"
SWEP.Instructions =	end_color..title_color.."Primary Fire:\t"..			end_color..text_color.." Punch / Throw\n"..
					end_color..title_color.."Secondary Fire:\t"..			end_color..text_color.." Knock / Pick Up / Drop\n"..
					end_color..title_color.."Sprint+Primary Fire:\t"..	end_color..text_color.." Lock Door/Car\n"..
					end_color..title_color.."Sprint+Secondary Fire:\t"..	end_color..text_color.." Unlock Door/Car\n"..
					end_color..title_color.."USE+Primary Fire:\t"..	end_color..text_color.." Untie Hostage\n";
SWEP.Purpose = "Punching, knocking on doors, untieing ropes, locking and unlocking.";

SWEP.Spawnable			= true
SWEP.UseHands			= true

SWEP.ViewModel			= "models/weapons/c_arms_citizen.mdl"
SWEP.WorldModel			= ""

SWEP.ViewModelFOV		= 52

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Damage			= 4
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.PrintName			= "Hands"
SWEP.Slot				= 0
SWEP.SlotPos			= 5
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= true

SWEP.HeldEnt = NULL
SWEP.Primary.Super = false;
SWEP.Primary.Force = 5;
SWEP.Primary.NextSwitch = 0;
SWEP.Primary.NextGoBack = 0;

local SwingSound = Sound( "weapons/slam/throw.wav" )
local HitSound = Sound( "Flesh.ImpactHard" )

function SWEP:Initialize()
	self:SetWeaponHoldType( "normal" )
end

function SWEP:PreDrawViewModel( vm, wep, ply )

	local modelList = {}

	for k, v in pairs(player_manager.AllValidModels()) do
		modelList[string.lower(v)] = k
	end

	local model = string.lower(ply:GetModel())

	for k, v in pairs(modelList) do
		if (string.find(string.gsub(model, "_", ""), v)) then
			model = v

			break
		end
	end

	
	local hands = player_manager.TranslatePlayerHands(model)
	
	if (hands and hands.model) then
		--vm:SetModel(hands.model)
	end


	vm:SetMaterial( "engine/occlusionproxy" ) -- Hide that view model with hacky material

end

function SWEP:Think()
	if !self.HeldEnt or CLIENT then return end
	if !IsValid(self.HeldEnt) then
		if IsValid(self.EntWeld) then self.EntWeld:Remove() end
		self.Owner._HoldingEnt, self.HeldEnt.held, self.HeldEnt, self.EntWeld, self.EntAngles, self.OwnerAngles = nil
		return
	elseif !IsValid(self.EntWeld) then
		self.Owner._HoldingEnt, self.HeldEnt.held, self.HeldEnt, self.EntWeld, self.EntAngles, self.OwnerAngles = nil
		return
	end
	if !self.HeldEnt:IsInWorld() then
		self.HeldEnt:SetPos(self.Owner:GetShootPos())
		self:DropObject()
		return
	end
	if self.NoPos then return end
	local pos = self.Owner:GetShootPos()
	local ang = self.Owner:GetAimVector()
	self.HeldEnt:SetPos(pos+(ang*60))
	self.HeldEnt:SetAngles(Angle(self.EntAngles.p,(self.Owner:GetAngles().y-self.OwnerAngles.y)+self.EntAngles.y,self.EntAngles.r))
end

function SWEP:Reload()
	if self.Primary.NextSwitch > CurTime() then return false end
	if self.Owner:IsSuperAdmin() and self.Owner:KeyDown(IN_SPEED) then
		if self.Primary.Super then
			self.Primary.Force = 5
			self.Primary.Damage = 10
			self.Primary.Super = false
			self.Owner:PrintMessage(HUD_PRINTCENTER, "Super mode disabled")
		else
			self.Primary.Force = 25000
			self.Primary.Damage = 300
			self.Primary.Super = true
			self.Owner:PrintMessage(HUD_PRINTCENTER, "Super mode enabled")
		end
		self.Primary.NextSwitch = CurTime() + 1
	end
end

SWEP.Distance = 67
SWEP.AttackAnims = { "fists_left", "fists_right", "fists_uppercut" }
function SWEP:PrimaryAttack()
	if IsValid(self.HeldEnt)then
		self:DropObject(200)
		return
	end
	if (self.Owner:GetNetworkedBool("hostaged") or self.Owner:GetNetworkedBool("cuffed"))  then 
		return
	end
	self:SetWeaponHoldType( "fist" )
	self.Primary.NextGoBack = CurTime() + 3;
	timer.Simple( 5, function() 
		if ( !IsValid( self ) || !IsValid( self.Owner ) || !self.Owner:GetActiveWeapon() || self.Owner:GetActiveWeapon() != self ) then return end
		if (CurTime() >= self.Primary.NextGoBack) then
			self:SetWeaponHoldType( "normal" )
		end
	end)
	self.Owner:SetAnimation( PLAYER_ATTACK1 )

	if ( !SERVER ) then return end

	-- We need this because attack sequences won't work otherwise in multiplayer
	local vm = self.Owner:GetViewModel()
	vm:ResetSequence( vm:LookupSequence( "fists_idle_01" ) )

	local anim = self.AttackAnims[ math.random( 1, #self.AttackAnims ) ]

	timer.Simple( 0, function()
		if ( !IsValid( self ) || !IsValid( self.Owner ) || !self.Owner:GetActiveWeapon() || self.Owner:GetActiveWeapon() != self ) then return end
	
		local vm = self.Owner:GetViewModel()
		vm:ResetSequence( vm:LookupSequence( anim ) )

		self:Idle()
	end )

	timer.Simple( 0.05, function()
		if ( !IsValid( self ) || !IsValid( self.Owner ) || !self.Owner:GetActiveWeapon() || self.Owner:GetActiveWeapon() != self ) then return end
		if ( anim == "fists_left" ) then
			self.Owner:ViewPunch( Angle( 0, 16, 0 ) )
		elseif ( anim == "fists_right" ) then
			self.Owner:ViewPunch( Angle( 0, -16, 0 ) )
		elseif ( anim == "fists_uppercut" ) then
			self.Owner:ViewPunch( Angle( 16, -8, 0 ) )
		end
	end )

	timer.Simple( 0.2, function()
		if ( !IsValid( self ) || !IsValid( self.Owner ) || !self.Owner:GetActiveWeapon() || self.Owner:GetActiveWeapon() != self ) then return end
		if ( anim == "fists_left" ) then
			self.Owner:ViewPunch( Angle( 4, -16, 0 ) )
		elseif ( anim == "fists_right" ) then
			self.Owner:ViewPunch( Angle( 4, 16, 0 ) )
		elseif ( anim == "fists_uppercut" ) then
			self.Owner:ViewPunch( Angle( -32, 0, 0 ) )
		end
		self.Owner:EmitSound( SwingSound )
		
	end )

	timer.Simple( 0.2, function()
		if ( !IsValid( self ) || !IsValid( self.Owner ) || !self.Owner:GetActiveWeapon() || self.Owner:GetActiveWeapon() != self ) then return end
		local trace = self.Owner:GetEyeTrace();
		if self.Owner:KeyDown(IN_USE) and (IsValid(trace.Entity))  then
	        			local trace = self.Owner:GetEyeTrace();
	       			if (trace.Entity:IsPlayer() and trace.Entity:GetNetworkedBool("hostaged")) and (self.Owner:GetPos():Distance(trace.Entity:GetPos()) <= 128)  then
                				evorp.command.ConCommand(self.Owner, "me removes the strong knot from "..trace.Entity:GetNetworkedString("evorp_NameIC")..".");
                				--gamemode.Call("PlayerLoadout", trace.Entity)
				                trace.Entity:SetNetworkedBool("hostaged", false)
				                self.Owner:PrintMessage( HUD_PRINTCENTER, "You have released "..trace.Entity:Nick().."." )
				                trace.Entity:PrintMessage( HUD_PRINTCENTER, "You have been released by "..self.Owner:Nick().."." )
	       			else
	            				evorp.player.notify(self.Owner, "That is not a person or isn't tied up!", 1);
	        			end;
        			return
        		end
        		if self.Owner:KeyDown(IN_SPEED) and (IsValid(trace.Entity)) and (self.Owner:GetPos():Distance(trace.Entity:GetPos()) <= 128) then
			if (evorp.entity.isDoor(trace.Entity) and evorp.player.hasDoorAccess(self.Owner,trace.Entity) and !trace.Entity._Jammed) then
				if( trace.Entity:GetClass() == "prop_vehicle_jeep") then
					trace.Entity:SetNetworkedBool("locked", true);
				else
					trace.Entity:Fire("lock", "", 0);
				end
				if (trace.Entity.iDoorSID) then trace.Entity:SetNetworkedBool("dlocked", true); end
				self.Owner:EmitSound("doors/door_latch3.wav");
			else
				evorp.player.notify(self.Owner, "You do not have access!", 1);
			end
			return
		end
		self:DealDamage( anim )
	        	self.Owner._Stamina = math.Clamp(self.Owner._Stamina - 7, 0, 100)
	        	if IsValid(self.HeldEnt)then
			local num = self.Primary.Super and 50000 or 5000
			self:DropObject(num)
			return
		end

		
	end )
	self:SetNextPrimaryFire( CurTime() + 0.9 )
end

function SWEP:DealDamage( anim )
	local tr = util.TraceLine( {
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * self.Distance,
		filter = self.Owner
	} )

	if ( !IsValid( tr.Entity ) ) then 
		tr = util.TraceHull( {
			start = self.Owner:GetShootPos(),
			endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * self.Distance,
			filter = self.Owner,
			mins = self.Owner:OBBMins() / 3,
			maxs = self.Owner:OBBMaxs() / 3
		} )
	end

	if ( tr.Hit ) then self.Owner:EmitSound( HitSound ) end
	if (IsValid( tr.Entity ) and tr.Entity:GetClass() == "prop_ragdoll") then
		tr.Entity = tr.Entity._Player;
	end
	if ( IsValid( tr.Entity ) && ( tr.Entity:IsPlayer() ) ) then
		local dmginfo = DamageInfo()
		dmginfo:SetDamage( self.Primary.Damage )
		if ( anim == "fists_left" ) then
			dmginfo:SetDamageForce( self.Owner:GetRight() * 49125 + self.Owner:GetForward() * 99984 ) -- Yes we need those specific numbers
		elseif ( anim == "fists_right" ) then
			dmginfo:SetDamageForce( self.Owner:GetRight() * -49124 + self.Owner:GetForward() * 99899 )
		elseif ( anim == "fists_uppercut" ) then
			dmginfo:SetDamageForce( self.Owner:GetUp() * 51589 + self.Owner:GetForward() * 100128 )
		end
		dmginfo:SetInflictor( self )
		local attacker = self.Owner
		if ( !IsValid( attacker ) ) then attacker = self end
		dmginfo:SetAttacker( attacker )
		tr.Entity:TakeDamageInfo( dmginfo )
		local chance =  math.random(tr.Entity:Health())
		if (!tr.Entity._KnockedOut and chance < 5 and tr.Entity:Health() < 75) then
			evorp.player.printConsoleAccess(self.Owner:Name().. " [".. self.Owner:SteamID() .. "] punched out "..tr.Entity:Name().. " [".. tr.Entity:SteamID() .. "].", "a", "kills", self.Owner);
			evorp.player.knockOut(tr.Entity, true, 50, false);
			evorp.command.ConCommand(self.Owner, "me knocks out "..tr.Entity:GetNetworkedString("evorp_NameIC")..".");
			hook.Call("PlayerKnockOut", GAMEMODE, self.Owner, tr.Entity);
		end
	end
end

-- Called when the player attempts to secondary fire.
function SWEP:SecondaryAttack()
	if (self.Owner:GetNetworkedBool("hostaged") or self.Owner:GetNetworkedBool("cuffed"))  then 
		return
	end
	self:SetWeaponHoldType( "fist" )
	self.Primary.NextGoBack = CurTime() + 3;
	timer.Simple( 5, function() 
		if ( !IsValid( self ) || !IsValid( self.Owner ) || !self.Owner:GetActiveWeapon() || self.Owner:GetActiveWeapon() != self ) then return end
		if (CurTime() >= self.Primary.NextGoBack) then
			self:SetWeaponHoldType( "normal" )
		end
	end)
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	
	if ( !SERVER ) then return end

	-- We need this because attack sequences won't work otherwise in multiplayer
	local vm = self.Owner:GetViewModel()
	vm:ResetSequence( vm:LookupSequence( "fists_idle_01" ) )

	local anim = self.AttackAnims[ math.random( 1, #self.AttackAnims ) ]

	timer.Simple( 0, function()
		if ( !IsValid( self ) || !IsValid( self.Owner ) || !self.Owner:GetActiveWeapon() || self.Owner:GetActiveWeapon() != self ) then return end
	
		local vm = self.Owner:GetViewModel()
		vm:ResetSequence( vm:LookupSequence( anim ) )

		self:Idle()
	end )

	timer.Simple( 0.05, function()
		if ( !IsValid( self ) || !IsValid( self.Owner ) || !self.Owner:GetActiveWeapon() || self.Owner:GetActiveWeapon() != self ) then return end
		if ( anim == "fists_left" ) then
			self.Owner:ViewPunch( Angle( 0, 16, 0 ) )
		elseif ( anim == "fists_right" ) then
			self.Owner:ViewPunch( Angle( 0, -16, 0 ) )
		elseif ( anim == "fists_uppercut" ) then
			self.Owner:ViewPunch( Angle( 16, -8, 0 ) )
		end
	end )

	timer.Simple( 0.2, function()
		if ( !IsValid( self ) || !IsValid( self.Owner ) || !self.Owner:GetActiveWeapon() || self.Owner:GetActiveWeapon() != self ) then return end
		if ( anim == "fists_left" ) then
			self.Owner:ViewPunch( Angle( 4, -16, 0 ) )
		elseif ( anim == "fists_right" ) then
			self.Owner:ViewPunch( Angle( 4, 16, 0 ) )
		elseif ( anim == "fists_uppercut" ) then
			self.Owner:ViewPunch( Angle( -32, 0, 0 ) )
		end
		self.Owner:EmitSound( SwingSound )
		
	end )

	timer.Simple( 0.2, function()
		if ( !IsValid( self ) || !IsValid( self.Owner ) || !self.Owner:GetActiveWeapon() || self.Owner:GetActiveWeapon() != self ) then return end
		if IsValid(self.HeldEnt)then
			self:DropObject()
			return
		end

		-- Get a trace from the owner's eyes.
		local trace = self.Owner:GetEyeTrace();
	
		-- Check to see if the trace entity is valid and that it's a door.
		if IsValid(trace.Entity) and self.Owner:GetPos():Distance(trace.HitPos) <= 128 then
			local ent = trace.Entity
			if evorp.entity.isDoor(ent, true) or ent:IsVehicle() then
				self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER);
				self.Weapon:EmitSound("npc/vort/claw_swing2.wav");
				if self.Owner:KeyDown(IN_SPEED) then
					if ( evorp.entity.isDoor(ent) and evorp.player.hasDoorAccess(self.Owner,ent) and !ent._Jammed) then
						if( trace.Entity:GetClass() == "prop_vehicle_jeep") then
							trace.Entity:SetNetworkedBool("locked", false);
						else
							ent:Fire("unlock", "", 0);
						end
						if (trace.Entity.iDoorSID) then trace.Entity:SetNetworkedBool("dlocked", false); end
						self.Owner:EmitSound("doors/door_latch3.wav");
					else
						evorp.player.notify(self.Owner, "You do not have access!", 1);
					end
				else
					self.Weapon:EmitSound("physics/wood/wood_crate_impact_hard2.wav")
					if self.Primary.Super then evorp.entity.openDoor(ent, 0, true, true,false,true) end
				end;
			else
				self:PickUp(ent,trace)
			end
		end;
		--self:PickUp(ent,trace)
	end )

	self:SetNextSecondaryFire( CurTime() + 0.9 )
end;

function SWEP:Idle()

	local vm = self.Owner:GetViewModel()
	timer.Create( "fists_idle" .. self:EntIndex(), vm:SequenceDuration(), 1, function()
		vm:ResetSequence( vm:LookupSequence( "fists_idle_0" .. math.random( 1, 2 ) ) )
	end )

end

function SWEP:OnRemove()

	if ( IsValid( self.Owner ) ) then
		local vm = self.Owner:GetViewModel()
		if IsValid(vm) then
			vm:SetMaterial( "" )
		end
	end

	timer.Stop( "fists_idle" .. self:EntIndex() )

end

function SWEP:Holster( wep )
	if (self.Owner:GetNetworkedBool("hostaged") or self.Owner:GetNetworkedBool("cuffed") or self.Owner:GetNetworkedInt("LastRevive") + 60 > CurTime()) then
		if (SERVER) then
			evorp.player.notify(self.Owner, "You've just been revived and you're too weak!", 1)
            		end
            		return false;
        	end
	if ( IsValid( self.Owner ) ) then
		local vm = self.Owner:GetViewModel()
		if IsValid(vm) then
			vm:SetMaterial( "" )
		end
	end

	timer.Stop( "fists_idle" .. self:EntIndex() )

	return true
end

function SWEP:Deploy()
	local vm = self.Owner:GetViewModel()
	if (IsValid(vm)) then
		vm:ResetSequence( vm:LookupSequence( "fists_draw" ) )

		self:Idle()
	end
	return true
end

function SWEP:PickUp(ent,trace)
	if CLIENT or ent.held then return end
	local pent = ent:GetPhysicsObject( )
	if !IsValid(pent) then return end
	if pent:GetMass() > 60 or not pent:IsMoveable() then
		return
	end
	if ent:GetClass() == "prop_ragdoll" then
		return false
	else
		ent:SetCollisionGroup( COLLISION_GROUP_WORLD )
		local EntWeld = {}
		EntWeld.ent = ent
		function EntWeld:IsValid() return IsValid(self.ent) end
		function EntWeld:Remove()
			if IsValid(self.ent) then self.ent:SetCollisionGroup( COLLISION_GROUP_NONE ) end
		end
		self.NoPos = false
		self.EntWeld = EntWeld
	end
	self.Owner._HoldingEnt = true
	self.HeldEnt = ent
	self.HeldEnt.held = true
	self.EntAngles = ent:GetAngles()
	self.OwnerAngles = self.Owner:GetAngles()
end
function SWEP:DropObject(force)
	if CLIENT then return true end
	force = force or 1
	if !IsValid(self.HeldEnt) then return true end
	if IsValid(self.EntWeld) then self.EntWeld:Remove() end
	local pent = self.HeldEnt:GetPhysicsObject( )
	if pent:IsValid() then
		pent:ApplyForceCenter(self.Owner:GetAimVector()*force)
	end
	self.Owner._HoldingEnt, self.HeldEnt.held, self.HeldEnt, self.EntWeld, self.EntAngles, self.OwnerAngles = nil
end