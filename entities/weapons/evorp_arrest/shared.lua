if( SERVER ) then
    AddCSLuaFile( "shared.lua" )
end

if( CLIENT ) then
    SWEP.BounceWeaponIcon = false
    function SWEP:DrawWeaponSelection(x, y, wide, tall, alpha)
        --draw.SimpleText("", "EvoFont2", x + 0.5*wide, y, Color(255, 220, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        self:PrintWeaponInfo(x + wide + 20, y + tall*0.95, alpha)
    end
end

SWEP.PrintName         = "All In One Cop SWEP"
SWEP.Slot             = 3
SWEP.SlotPos         = 1
SWEP.DrawAmmo         = false
SWEP.DrawCrosshair     = true
SWEP.Author            = "Baddog + Int64"
SWEP.Instructions    = "Primary: Open Elevator/Knockout(Wakeup)/Pull player from vehicle\nSecondary: Arrest/Breach door"
SWEP.Purpose        = "Enforce the law"
SWEP.Category        = "EvoRP"

--SWEP.ViewModelFOV    = 60
--SWEP.ViewModelFlip    = false

SWEP.Spawnable            = false
SWEP.AdminSpawnable        = false

SWEP.ViewModel      = "models/weapons/v_stunstick.mdl"
SWEP.WorldModel       = "models/weapons/w_stunbaton.mdl"

SWEP.Primary.Delay                = 0.5
SWEP.Primary.ClipSize            = -1
SWEP.Primary.DefaultClip        = -1
SWEP.Primary.Automatic           = false
SWEP.Primary.Ammo                 = "none"

SWEP.Secondary.Delay            = 0.5
SWEP.Secondary.ClipSize            = -1
SWEP.Secondary.DefaultClip        = -1
SWEP.Secondary.Automatic           = false
SWEP.Secondary.Ammo             = "none"
SWEP.LastFire = 0

function SWEP:Initialize()
    self:SetWeaponHoldType("normal")
end

function SWEP:Deploy()
    self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
    self:SetNextPrimaryFire(CurTime() + 0.5)
    self:SetNextSecondaryFire(CurTime() + 0.5)
return true
end

function SWEP:PrimaryAttack()
    if not (CurTime() > (self.LastFire + 0.5)) then
        return
    end
    self.LastFire = CurTime();
    self.Weapon:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )
    self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
    self.Owner:LagCompensation(true)
    
    local trdata = {}
    trdata.start = self.Owner:GetShootPos()
    trdata.endpos = self.Owner:GetShootPos() + (self.Owner:GetAimVector() * 100)
    trdata.filter = self.Owner
    trdata.mins = Vector(1,1,1) * -10
    trdata.maxs = Vector(1,1,1) * 10
    trdata.mask = MASK_SHOT_HULL
    local tr = util.TraceHull( trdata )
    self:SetWeaponHoldType( "melee" )
    self.Primary.NextGoBack = CurTime() + 3;
    timer.Simple( 5, function() 
        if ( !IsValid( self ) || !IsValid( self.Owner ) || !self.Owner:GetActiveWeapon() || self.Owner:GetActiveWeapon() != self ) then return end
        if (CurTime() >= self.Primary.NextGoBack) then
            self:SetWeaponHoldType( "normal" )
        end
    end)
    if (CLIENT) then return; end;
    if IsValid(tr.Entity) then
        self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER)
        self.Weapon:EmitSound("weapons/stunstick/stunstick_impact"..math.random(1, 2)..".wav")
        if (tr.Entity:GetClass() == "prop_ragdoll") then
            local pla = tr.Entity._Player
            if pla:IsPlayer() and pla._KnockedOut and !pla:GetNetworkedBool("FakeDeathing") then
                pla:EmitSound( "weapons/crossbow/bolt_fly4.wav" )
                evorp.player.knockOut(pla, false);
                pla._Sleeping = false;
                evorp.player.printConsoleAccess(self.Owner:Nick().." ["..self.Owner:SteamID().."] woke up "..pla:Nick().." ["..pla:SteamID().."].", "a", self.Owner);
            end
        elseif tr.Entity:IsPlayer() then
            if not ((IsValid(tr.Entity:GetActiveWeapon()) and string.find(tr.Entity:GetActiveWeapon():GetClass(), "bb_" )) or (evorp.team.query(tr.Entity:Team(), "radio", "") == "R_GOV")) then
                if (!tr.Entity._Ragdoll.entity and !tr.Entity._KnockedOut) then
                    evorp.player.printConsoleAccess(self.Owner:Name().. " [".. self.Owner:SteamID() .. "] knocked out "..tr.Entity:Name().. " [".. tr.Entity:SteamID() .. "].", "a", "kills", self.Owner)
                    evorp.player.knockOut(tr.Entity, true, tr.Entity._KnockOutTime)
                    evorp.player.notify(tr.Entity, "You have been  KNOCKED OUT by "..self.Owner:Nick()..".", 0)
                    -- Call a hook.
                    hook.Call("PlayerKnockOut", GAMEMODE, self.Owner, tr.Entity)
                end
            end
        elseif (tr.Entity:IsVehicle()) then
            if (math.abs(math.floor(tr.Entity:GetVelocity():Length()/ 25.33)) < 3) then
                if (tr.Entity.Seats) then
                    for k, v in ipairs(tr.Entity.Seats) do
                            if (IsValid(v) and IsValid(v:GetDriver())) then
                                v:GetDriver():ExitVehicle();
                            end
                    end
                end
                if (IsValid(tr.Entity:GetDriver())) then
                    tr.Entity:GetDriver():ExitVehicle();
                end
            end
        elseif (evorp.entity.isDoor(tr.Entity)) then
            if tr.Entity:GetNetworkedString("evorp_Name") and tr.Entity:GetNetworkedString("evorp_Name") == "Elevator Door" then
                evorp.entity.openDoor(tr.Entity, 1, true, false)
            end
        end
        --contraband destruction?
    else
        self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER)
        self.Weapon:EmitSound("weapons/stunstick/stunstick_swing1.wav")
    end
    
    self.Owner:LagCompensation(false)
    self.Owner:SetAnimation( PLAYER_ATTACK1 )
end


function SWEP:SecondaryAttack()
    if not  (CurTime() > (self.LastFire + 0.5)) then
        return
    end
    self.LastFire = CurTime();
    self.Weapon:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )
    self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
    self.Owner:LagCompensation(true)
    
    local trdata = {}
    trdata.start = self.Owner:GetShootPos()
    trdata.endpos = self.Owner:GetShootPos() + (self.Owner:GetAimVector() * 100)
    trdata.filter = self.Owner
    trdata.mins = Vector(1,1,1) * -10
    trdata.maxs = Vector(1,1,1) * 10
    trdata.mask = MASK_SHOT_HULL
    local tr = util.TraceHull( trdata )
    self:SetWeaponHoldType( "melee" )
    self.Primary.NextGoBack = CurTime() + 3;
    timer.Simple( 5, function() 
        if ( !IsValid( self ) || !IsValid( self.Owner ) || !self.Owner:GetActiveWeapon() || self.Owner:GetActiveWeapon() != self ) then return end
        if (CurTime() >= self.Primary.NextGoBack) then
            self:SetWeaponHoldType( "normal" )
        end
    end)
    if (CLIENT) then return; end;

    if IsValid(tr.Entity) then
        self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER)
        self.Weapon:EmitSound("weapons/stunstick/stunstick_impact"..math.random(1, 2)..".wav")
--Door breaching

	if (string.find( tr.Entity:GetClass( ), "prop_vehicle_jeep" )) then
		tr.Entity:SetNetworkedBool("locked", false)
		self.Owner:EmitSound("doors/door_latch3.wav");
		if (tr.Entity._Owner and IsValid(tr.Entity._Owner)) then
			evorp.player.printConsoleAccess(self.Owner:Nick().." ["..self.Owner:SteamID().."] unlocked "..tr.Entity._Owner:Nick().."'s' ["..tr.Entity._Owner:SteamID().."] car.", "a", "kills", self.Owner)
		end
		return;
	end

                if (evorp.entity.isDoor(tr.Entity)) then
                	if (IsValid(tr.Entity._Owner)) then
                                        if (tr.Entity.iDoorSID) then
                                            evorp.player.printConsoleAccess(self.Owner:Nick().." ["..self.Owner:SteamID().."] breached the (STool) door of "..tr.Entity.iDoorNick.." ["..tr.Entity.iDoorSID.."] as a "..self.Owner:Team()..".", "a", "kills", self.Owner)
                                        else
                                            evorp.player.printConsoleAccess(self.Owner:Nick().." ["..self.Owner:SteamID().."] breached the door of "..tr.Entity._Owner:Nick().." ["..tr.Entity._Owner:SteamID().."] as a "..self.Owner:Team()..".", "a", "kills", self.Owner)
                                        end
                		local warrant = tr.Entity._Owner:GetNetworkedString("evorp_Warranted")
                		if warrant != "search" then
        		                evorp.player.notify(self.Owner, "You need a warrant first!", 0)
        		                evorp.player.printConsoleAccess("[Alert] He had no search warrant! Returning false.", "a", "kills", self.Owner)
        		                return false
                    		end    
                	end
                    tr.Entity:Fire("unlock", "", .5)
                    tr.Entity:Fire("open", "", .6)
                    tr.Entity:Fire("setanimation","open","0")
                    tr.Entity.iOpen = true;
                    return
                end
        

        if (tr.Entity:GetClass() == "prop_ragdoll") then
            tr.Entity = tr.Entity._Player
        end
    --Check to see if the entity is a player
    if not (IsValid(tr.Entity) and tr.Entity:IsPlayer() and IsValid(tr.Entity:GetActiveWeapon()) and string.find(tr.Entity:GetActiveWeapon():GetClass(), "bb_" )) then
        if (tr.Entity:IsPlayer() and tr.Entity.evorp._Arrested) then
            evorp.player.knockOut(tr.Entity, false)
            evorp.player.arrest(tr.Entity, false);
            evorp.command.ConCommand(self.Owner, "radio I have unarrested "..tr.Entity:GetNetworkedString("evorp_NameIC")..".");
            -- Let the administrators know that this happened.
            evorp.player.printConsoleAccess(self.Owner:Name().. " [".. self.Owner:SteamID() .. "] unarrested "..tr.Entity:Name().. " [".. tr.Entity:SteamID() .. "]"..".", "a", self.Owner);
            
            -- Call a hook.
            hook.Call("PlayerUnarrest", GAMEMODE, self.Owner, tr.Entity);
            return
        end
    end

        if ( tr.Entity:IsPlayer() and !tr.Entity:GetNetworkedBool("FakeDeathing") and !tr.Entity.evorp._Arrested) then
            if (tr.Entity._Warranted == "arrest") then
                if not (tr.Entity:GetNetworkedBool("cuffed")) then
                    evorp.player.notify(self.Owner, "You must first handcuff the player before arresting him!", 1)
                else
                    evorp.player.knockOut(tr.Entity, false)
                    evorp.command.ConCommand(self.Owner, "radio I have arrested "..tr.Entity:GetNetworkedString("evorp_NameIC")..".")
                    evorp.player.arrest(tr.Entity, true)
                    -- Let the administrators know that this happened.
                    evorp.player.printConsoleAccess(self.Owner:Name().. " [".. self.Owner:SteamID() .. "]".." arrested "..tr.Entity:Name().. " [".. tr.Entity:SteamID() .. "]"..".", "a", "kills", self.Owner)
                    
                    -- Call a hook.
                    hook.Call("PlayerArrest", GAMEMODE, self.Owner, tr.Entity)
                end
            else
                evorp.player.notify(self.Owner, tr.Entity:Name().." does not have an arrest warrant!", 1)
            end
        end
    else
        self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER)
        self.Weapon:EmitSound("weapons/stunstick/stunstick_swing1.wav")
    end
    
    self.Owner:LagCompensation(false)
    self.Owner:SetAnimation( PLAYER_ATTACK1 )
end