--[[
Name: "shared.lua".
Creator: "Shaneman".
Product: "AN-Gaming.Net".
--]]

if (SERVER) then
    AddCSLuaFile("shared.lua");
end

-- Check if we're running on the client.
if (CLIENT) then
    SWEP.PrintName = "Hostage Rope";
    SWEP.Slot = 1;
    SWEP.SlotPos = 1;
    SWEP.DrawAmmo = false;
    SWEP.DrawCrosshair = true;
end

-- Define some shared variables.
SWEP.Author    = "Shaneman";
SWEP.Instructions = "Primary Fire: Tie Someone Up";
SWEP.Contact = "";
SWEP.Purpose = "Tie up, and hostage people. Don't Abuse.";

-- Set the view model and the world model to nil.
SWEP.ViewModel = "models/als/ROPE/v_rope.mdl";
SWEP.WorldModel = "models/als/ROPE/w_ropel.mdl";

-- Set the animation prefix and some other settings.
SWEP.AnimPrefix    = "admire";
SWEP.Spawnable = false;
SWEP.AdminSpawnable = true;

-- Set the primary fire settings.
SWEP.Spawnable = true;
SWEP.Primary.Damage = 0;
SWEP.Primary.ClipSize = -1;
SWEP.Primary.DefaultClip = 0;
SWEP.Primary.Automatic = false;
SWEP.Primary.Ammo = "";

-- Set the secondary fire settings.
SWEP.Secondary.ClipSize = -1;
SWEP.Secondary.DefaultClip = 0;
SWEP.Secondary.Automatic = false;
SWEP.Secondary.Ammo    = "";

-- Set the iron sight positions (pointless here).
SWEP.IronSightPos = Vector(0, 0, 0);
SWEP.IronSightAng = Vector(0, 0, 0);
SWEP.NoIronSightFovChange = true;
SWEP.NoIronSightAttack = true;

-- Called when the SWEP is initialized.
function SWEP:Initialize()
    self:SetWeaponHoldType("normal");
end;

local act_primary_time = 1.4 -- change this
local act_secondary_time = 1.4 -- change this
local act_draw_time = 1.4 -- change this

function SWEP:DoPrimaryAnims()
    if !IsValid( self.Weapon ) then return end -- Safety first!
    self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK ) -- Play primary anim
    timer.Simple( act_primary_time, self.PlayDrawAnim, self ) -- Now make a timer to play the draw anim
end

function SWEP:DoSecondaryAnims()
    if !IsValid( self.Weapon ) then return end -- Safety first!
    self.Weapon:SendWeaponAnim( ACT_VM_SECONDARYATTACK ) -- Play secondary anim
    timer.Simple( act_secondary_time, self.PlayDrawAnim, self ) -- Now make a timer to play the draw anim
end

function SWEP:PlayDrawAnim()
    if  !self or !self.Weapon or !IsValid( self.Weapon ) then return end -- Safety first!
    self.Weapon:SendWeaponAnim( ACT_VM_DRAW ) -- Play draw anim
    timer.Simple( act_draw_time, self.PlayIdleAnim, self ) -- Now make a timer to play the idle anim
end

function SWEP:PlayIdleAnim()
    if !IsValid( self.Weapon ) then return end -- Safety first!
    self.Weapon:SendWeaponAnim( ACT_VM_IDLE ) -- Player idle anim
end

-- Called when the player attempts to primary fire.
function SWEP:PrimaryAttack()
    self.Weapon:SetNextPrimaryFire(CurTime() + 6);
    self.Weapon:SetNextSecondaryFire(CurTime() + 6);
    self.Weapon:DoPrimaryAnims()
    local trace = self.Owner:GetEyeTrace();
    if(SERVER) then
        local trace = self.Owner:GetEyeTrace();
        trace.Real = trace.Entity
        if (trace.Entity:GetClass() == "prop_ragdoll") then
            trace.Entity = trace.Entity._Player;
        end
        if (trace.Entity:GetNetworkedBool("hostaged") or trace.Entity:GetNetworkedBool("cuffed")) then
                     evorp.player.notify(self.Owner, "Target is already tied/handcuffed.", 1);
                        return
                end
        if (trace.Entity:IsPlayer() and self.Owner:GetPos():Distance(trace.Real:GetPos()) <= 64) then
        local ply = trace.Entity
        timer.Simple(1, function()
            if (trace.Entity:IsPlayer() and self.Owner:GetPos():Distance(trace.Real:GetPos()) <= 64) then
                evorp.command.ConCommand(self.Owner, "me starts to tie up "..trace.Entity:GetNetworkedString("evorp_NameIC")..".");
            end
        end)
        timer.Simple(1.5, function()
            if (trace.Entity:IsPlayer() and self.Owner:GetPos():Distance(trace.Real:GetPos()) <= 64) then
                evorp.command.ConCommand(self.Owner, "me does a simple knot.");
            end
        end)
        timer.Simple(2, function()
            if (trace.Entity:IsPlayer() and self.Owner:GetPos():Distance(trace.Real:GetPos()) <= 64) then
                evorp.command.ConCommand(self.Owner, "me doubles the knot.");
            end
        end)
        timer.Simple(3, function()
            if (trace.Entity:IsPlayer() and self.Owner:GetPos():Distance(trace.Real:GetPos()) <= 64) then
                evorp.command.ConCommand(self.Owner, "me finished the rope with a strong knot.");
                --evorp.player.holsterAll(trace.Entity)
                --trace.Entity:StripWeapons()
                trace.Entity:SetNetworkedBool("hostaged", true)
                trace.Entity:SelectWeapon("evorp_hands")
                self.Owner:PrintMessage( HUD_PRINTCENTER, "You have tied up "..trace.Entity:Nick().."." )
                trace.Entity:PrintMessage( HUD_PRINTCENTER, "You have been tied up by "..self.Owner:Nick().."." )
            else
                evorp.player.notify(self.Owner, "Target got away.", 1);
            end
        end)
        else
            evorp.player.notify(self.Owner, "This is not a person, or this person is already tied up.", 1);
        end;
    end
end;

--[[
-- Called when the player attempts to secondary fire.
function SWEP:SecondaryAttack()
    self.Weapon:SetNextPrimaryFire(CurTime() + 1);
    self.Weapon:DoSecondaryAnims()
    if(SERVER) then
        local trace = self.Owner:GetEyeTrace();

        if (trace.Entity:GetNetworkedBool("hostaged")) then
            if (trace.Entity:IsPlayer() and self.Owner:GetPos():Distance(trace.Entity:GetPos()) <= 128) then
                self.Owner:ConCommand("say /me removes the strong knot from "..trace.Entity:GetNetworkedString("evorp_NameIC")..".");
                evorp.plugin.call("playerLoadout", trace.Entity);
                if ( evorp.access.hasAccess(trace.Entity, "t") ) then
                    trace.Entity:Give("gmod_tool");
                end;
                if ( evorp.access.hasAccess(trace.Entity, "p") ) then
                    trace.Entity:Give("weapon_physgun");
                end;
                trace.Entity:SetNetworkedBool("hostaged", false)
                self.Owner:PrintMessage( HUD_PRINTCENTER, "You have released "..trace.Entity:Nick().."." )
                trace.Entity:PrintMessage( HUD_PRINTCENTER, "You have been released by "..self.Owner:Nick().."." )
            end;
        else
            evorp.player.notify(self.Owner, "That person isn't tied up!", 1);
        end;
    end;
end;
]]