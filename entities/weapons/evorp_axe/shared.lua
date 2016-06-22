--[[
Name: "shared.lua".
Product: "www.flrp.net".
--]]

if (SERVER) then AddCSLuaFile("shared.lua"); end;

-- Check if we're running on the client.
if (CLIENT) then
    SWEP.PrintName = "Fire Axe";
    SWEP.Slot = 3;
    SWEP.SlotPos = 1;
    SWEP.DrawAmmo = false;
    SWEP.DrawCrosshair = true;
end;

-- Define some shared variables.
SWEP.Instructions = "Primary Fire: Open door.";
SWEP.Purpose = "Opening doors by hit their lock.";

-- Set the view model and the world model to nil.
SWEP.ViewModel      = "models/weapons/v_crowaxe.mdl"
SWEP.WorldModel   = "models/weapons/w_crowaxe.mdl"
SWEP.ViewModelFOV	= 62
-- Set whether it's spawnable by players and by administrators.
SWEP.Spawnable = true;
SWEP.AdminSpawnable = false;

-- Set the primary fire settings.
SWEP.Primary.Delay = 0.75;
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

-- Called when the SWEP is initialized.
function SWEP:Initialize()
    self:SetWeaponHoldType("melee");
end;

-- Called when the player attempts to primary fire.
function SWEP:PrimaryAttack()
    self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay);

    -- Set the animation of the owner to one of them attacking.
    self.Owner:SetAnimation(PLAYER_ATTACK1);

    -- Get an eye trace from the owner.
    local trace = self.Owner:GetEyeTrace();

    -- Check if the trace hit or it hit the world.
    if ( (trace.Hit or trace.HitWorld) and self.Owner:GetPos():Distance(trace.HitPos) <= 128 ) then
        self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER);
        self.Weapon:EmitSound("physics/flesh/flesh_impact_bullet3.wav");
    else
        self.Weapon:SendWeaponAnim(ACT_VM_MISSCENTER);
        self.Weapon:EmitSound("weapons/iceaxe/iceaxe_swing1.wav");
    end;

    -- Check if we're running on the client.
    if (CLIENT) then return; end;

    -- Check the hit position of the trace to see if it's close to us.
    if (self.Owner:GetPos():Distance(trace.HitPos) <= 128) then
        if ( IsValid(trace.Entity) ) then
            if (trace.Entity:GetClass() == "keypad") then

                if (SERVER) then
                    trace.Entity:Process(true)
                    trace.Entity:EmitSound("buttons/button11.wav") 
                end
            elseif (evorp.entity.isDoor(trace.Entity) or trace.Entity:GetClass() == "prop_dynamic") then
                trace.Entity._Lockpick = trace.Entity._Lockpick or 0;

                -- Increase this entity's lockpick amount.
                trace.Entity._Lockpick = trace.Entity._Lockpick + 1;

                -- Check to see if the lockpick amount is greater or equal to 10.
                if (trace.Entity._Lockpick >= 1) then
                    evorp.entity.openDoor(trace.Entity, 0.1, true, true);

                    -- Reset this entity's lockpick amount.
                    trace.Entity._Lockpick = 0;
                end;
            end;
        end;
    end;
end;

-- Called when the player attempts to secondary fire.
function SWEP:SecondaryAttack() end;