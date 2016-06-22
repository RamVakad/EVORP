if SERVER then
    AddCSLuaFile("shared.lua")
end

if CLIENT then
    SWEP.PrintName = "Fire Extinguisher"
    SWEP.Slot = 2
    SWEP.SlotPos = 1
    SWEP.DrawAmmo = false
    SWEP.DrawCrosshair = false
end

SWEP.Instructions = "Left Click: Extinguish Fire."


SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/weapons/v_fire_extinguisher.mdl"
SWEP.WorldModel = ""

SWEP.Spawnable = true;
SWEP.AdminSpawnable = true
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = ""

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""


SWEP.ShootSound = Sound("hose2.mp3");

function SWEP:Initialize()
    self:SetWeaponHoldType("normal")
end;

function SWEP:CanPrimaryAttack() return true; end;

function SWEP:PrimaryAttack()
    if self:GetTable().LastNoise == nil then self:GetTable().LastNoise = true; end
    if self:GetTable().LastNoise then
        self.Weapon:EmitSound(self.ShootSound)
        self:GetTable().LastNoise = false;
    else
        self:GetTable().LastNoise = true;
    end;

    self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
    self.Weapon:SetNextPrimaryFire(CurTime() + .1)

    if (CLIENT or (game.SinglePlayer() and SERVER)) then
        local ED = EffectData();
        ED:SetEntity(self.Owner);
        util.Effect("fire_hose_water", ED);
    end;

    self.Owner:ViewPunch(Angle(math.Rand(-1,-0.5), math.Rand(-0.5,0.5), 0 ))

    if (SERVER) then
        local Trace2 = {};
        Trace2.start = self.Owner:GetShootPos();
        Trace2.endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 200;
        Trace2.filter = self.Owner;
        local Trace = util.TraceLine(Trace2);

        local CloseEnts = ents.FindInSphere(Trace.HitPos, 128);

        for k, v in pairs(CloseEnts) do
            if not (v:GetClass() == "prop_vehicle_jeep") then
                if (v:GetClass() == "evorp_fire") then
                    v:HitByExtinguisher(self.Owner, true);
                end;

                if (v:IsOnFire()) then v:Extinguish() end
            else
                if (v.Burning) then
                    if not (v.Heal) then v.Heal = 0 end
                    v.Heal = v.Heal + 1;
                    if (v.Heal  > 100) then
                             if (v:IsOnFire()) then v:Extinguish(); v:StopParticles() end
                             v.Heal = 0;
                             v._Fuel = 10;
                             v.Burning = false;
                             timer.Remove("VehicleHealthExplode"..v:EntIndex())
                             v:SetHealth(50)
                            --ParticleEffectAttach(CarDamageConfig.IgniteEffect,PATTACH_ABSORIGIN_FOLLOW,v,0)
                            --v.smoke = true
                            v:StopSound("fire_med_loop1")
                            v:StopSound("ignite_loop")

                             --Crap from here,
                             local owner = v:CPPIGetOwner();
                             if IsValid(owner) then
                                 local spawnvehicle = ents.Create("prop_vehicle_jeep")
                                spawnvehicle:SetModel(v:GetModel())
                                spawnvehicle:SetPos(v:GetPos())
                                spawnvehicle:SetAngles(v:GetAngles())
                                spawnvehicle.VehicleTable = v.VehicleTable
                                owner._EVORPVehicle = spawnvehicle
                                spawnvehicle._Class = v._Class
                                spawnvehicle:SetKeyValue("vehiclescript",v.VehicleTable.KeyValues["vehiclescript"])
                                local oldskin = v:GetSkin()
                                local oldcolor = v:GetColor();
                                local oldmat = v:GetMaterial();
                                spawnvehicle._Access = v._Access;
                                v:Remove();
                                spawnvehicle:Spawn()
                                spawnvehicle:Fire("TurnOff", "" , 0)
                                spawnvehicle:SetNetworkedBool("NeedsFix", true)
                                --ParticleEffectAttach(CarDamageConfig.IgniteEffect,PATTACH_ABSORIGIN_FOLLOW,spawnvehicle,0)
                               -- spawnvehicle.smoke = true
                                spawnvehicle:SetHealth(50)
                                hook.Call("PlayerSpawnedVehicle", GAMEMODE, owner, spawnvehicle)
                                spawnvehicle:SetSkin(oldskin)
                                spawnvehicle:SetMaterial(oldmat)
                                spawnvehicle:SetColor(oldcolor)
                                return true
                            else
                                v:Remove();
                                return true;
                            end
                    end
                end
            end
        end;
    end;
end;

function SWEP:SecondaryAttack()
    self:PrimaryAttack();
end