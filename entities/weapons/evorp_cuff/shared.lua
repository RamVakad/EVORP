--[[
Name: "shared.lua".
--]]

if (SERVER) then
	AddCSLuaFile("shared.lua");
end

-- Check if we're running on the client.
if (CLIENT) then
	SWEP.PrintName = "Handcuffs";
	SWEP.Slot = 3;
	SWEP.SlotPos = 1;
	SWEP.DrawAmmo = false;
	SWEP.DrawCrosshair = true;
end

-- Define some shared variables.
SWEP.Instructions = "Primary Fire: Handcuff \nSecondary Fire: Unhandcuff.\n";
SWEP.Contact = "";
SWEP.Purpose = "Handcuff, and unhandcuff people. Don't Abuse.";

-- Set the view model and the world model to nil.
SWEP.ViewModel = "models/katharsmodels/handcuffs/handcuffs-1.mdl";
SWEP.WorldModel = "models/katharsmodels/handcuffs/w_handcuffs.mdl";

-- Set the animation prefix and some other settings.
SWEP.AnimPrefix	= "admire";
SWEP.Spawnable = true;
SWEP.AdminSpawnable = true;
  
-- Set the primary fire settings.
SWEP.Primary.Damage = 0;
SWEP.Primary.ClipSize = -1;
SWEP.Primary.DefaultClip = 0;
SWEP.Primary.Automatic = false;
SWEP.Primary.Ammo = "";

-- Set the secondary fire settings.
SWEP.Secondary.ClipSize = -1;
SWEP.Secondary.DefaultClip = 0;
SWEP.Secondary.Automatic = false;
SWEP.Secondary.Ammo	= "";

-- Set the iron sight positions (pointless here).
SWEP.IronSightPos = Vector(0, 0, 0);
SWEP.IronSightAng = Vector(0, 0, 0);
SWEP.NoIronSightFovChange = true;
SWEP.NoIronSightAttack = true;

if CLIENT then
	function SWEP:GetViewModelPosition ( Pos, Ang )
		Ang:RotateAroundAxis(Ang:Forward(), 90);
		Pos = Pos + Ang:Forward() * 6;
		Pos = Pos + Ang:Right() * 2;
		
		return Pos, Ang;
	end 
end

-- Called when the SWEP is initialized.
function SWEP:Initialize()
	self:SetWeaponHoldType("normal");
end;

-- Called when the player attempts to primary fire.
function SWEP:PrimaryAttack()
	self.Weapon:SetNextPrimaryFire(CurTime() + 6);
	self.Weapon:SetNextSecondaryFire(CurTime() + 6);
	self.Weapon:EmitSound("npc/vort/claw_swing" .. math.random(1, 2) .. ".wav")
	if(SERVER) then
		local trace = self.Owner:GetEyeTrace();
		trace.Real = trace.Entity;
		if not (trace.Entity and IsValid(trace.Entity)) then
			return
		end
		if (trace.Entity:GetClass() == "prop_ragdoll") then
			trace.Entity = trace.Entity._Player;
		end
		if (trace.Entity:GetNetworkedBool("hostaged") or trace.Entity:GetNetworkedBool("cuffed")) then
           			 evorp.player.notify(self.Owner, "Target is already tied/handcuffed.", 1);
            			return
        		end
		if (trace.Entity:IsPlayer()) then
			if (evorp.team.query(trace.Entity:Team(), "radio", "") == "R_GOV") then 
				evorp.player.notify(self.Owner, "You can't handcuff someone in your own organization.", 1);
				return false; 
			end
		end
		if not (trace.Entity.GetActiveWeapon and IsValid(trace.Entity:GetActiveWeapon()) and string.find(trace.Entity:GetActiveWeapon():GetClass(), "bb_" )) then
			if (trace.Entity:IsPlayer() and self.Owner:GetPos():Distance(trace.Entity:GetPos()) <= 100) then
				timer.Simple(1, function()
					if ( IsValid(trace.Entity) and trace.Entity:IsPlayer() and self.Owner:GetPos():Distance(trace.Entity:GetPos()) <= 100) then
						evorp.command.ConCommand(self.Owner, "me starts to handcuff "..trace.Entity:GetNetworkedString("evorp_NameIC")..".");
					else
						evorp.player.notify(self.Owner, "Target got away.", 1);
					end
				end)
				timer.Simple(2.5, function()
					if (IsValid(trace.Entity) and trace.Entity:IsPlayer() and self.Owner:GetPos():Distance(trace.Entity:GetPos()) <= 100) then
						evorp.command.ConCommand(self.Owner, "me clicks both cuffs over each hand.");
					else
						evorp.player.notify(self.Owner, "Target got away.", 1);
					end
				end)
				timer.Simple(3, function()
					if (IsValid(trace.Entity) and trace.Entity:IsPlayer() and trace.Entity:Alive() and self.Owner:GetPos():Distance(trace.Entity:GetPos()) <= 100) then
						evorp.command.ConCommand(self.Owner, "me finished cuffing "..trace.Entity:GetNetworkedString("evorp_NameIC")..".");
						--evorp.player.holsterAll(trace.Entity)
						--trace.Entity:StripWeapons()
						trace.Entity:SetNetworkedBool("cuffed", true)
						trace.Entity:SelectWeapon("evorp_hands")
						self.Owner:PrintMessage( HUD_PRINTCENTER, "You have handcuffed "..trace.Entity:Nick().."." )
	                	trace.Entity:PrintMessage( HUD_PRINTCENTER, "You have been handcuffed by "..self.Owner:Nick().."." )
					else
						evorp.player.notify(self.Owner, "Target got away.", 1);
					end
				end)
			else
				evorp.player.notify(self.Owner, "This is not a person or the player is too far away.", 1);
			end;
		end
	end
end;
		

-- Called when the player attempts to secondary fire.
function SWEP:SecondaryAttack()
	self.Weapon:SetNextPrimaryFire(CurTime() + 1);
	if(SERVER) then
		local trace = {};
		local trace = self.Owner:GetEyeTrace();
		
		if (trace.Entity:GetNetworkedBool("cuffed")) then
			if (trace.Entity:IsPlayer() and self.Owner:GetPos():Distance(trace.Entity:GetPos()) <= 128) then
				evorp.command.ConCommand(self.Owner, "me removes the handcuffs from "..trace.Entity:GetNetworkedString("evorp_NameIC")..".");
				--gamemode.Call("PlayerLoadout", trace.Entity)
				trace.Entity:SetNetworkedBool("cuffed", false)
				self.Owner:PrintMessage( HUD_PRINTCENTER, "You have released "..trace.Entity:Nick().."." )
				trace.Entity:PrintMessage( HUD_PRINTCENTER, "You have been released by "..self.Owner:Nick().."." )
			end;
		else
			evorp.player.notify(self.Owner, "That person isn't handcuffed!", 1);
		end;
	end;
end;
