hook.Add("Think", "Cruise_Think", function()
	for _,PEnt in pairs(ents.GetAll()) do
		if PEnt:IsVehicle() and PEnt.Cruise and string.lower(PEnt:GetClass()) == "prop_vehicle_jeep" then
			if !PEnt.VC_Thrtl then
				if IsValid(PEnt:GetDriver()) then
					if !PEnt.VC_TThl then
						PEnt.VC_TThl = 0.0 end
					if PEnt.VC_TThl > 0 and PEnt:GetDriver():KeyDown(IN_BACK) then
						PEnt.VC_TThl = PEnt.VC_TThl- 0.01
					elseif PEnt.VC_TThl < 1 and PEnt:GetDriver():KeyDown(IN_FORWARD) then
						PEnt.VC_TThl = PEnt.VC_TThl+ 0.01 end
				end
				if !IsValid(PEnt:GetDriver()) or !PEnt:GetDriver():KeyDown(IN_JUMP) and !PEnt:GetDriver():KeyDown(IN_BACK) and !PEnt:GetDriver():KeyDown(IN_FORWARD) then
					PEnt:Fire("Throttle", tostring(PEnt.VC_TThl))
					PEnt.VC_Thrtl = true 
				end 
			elseif PEnt.VC_Thrtl then
				PEnt:Fire("Throttle", "0") 
				PEnt.VC_Thrtl = false
			end
		end
	end
end)

local function ToggleCruise( player,cmd,arg )
	if not (player.NextToggleCruise <= CurTime()) then return end
	player.NextToggleCruise = CurTime() + 3
	if player:InVehicle() then
	  local vehicle = player:GetVehicle()
		  if (string.lower(vehicle:GetClass()) == "prop_vehicle_jeep") then
			  if vehicle.Cruise then
			  	vehicle:SetNetworkedBool("evorp_cruise", false)
			  	vehicle.Cruise = false;
			  else
			  	vehicle:SetNetworkedBool("evorp_cruise", true)
			  	vehicle.Cruise = true;
			  	vehicle.VC_TThl = 0;
			  end
		end
	end
end
concommand.Add( "ToggleCruise", ToggleCruise )

util.AddNetworkString("veh_col") 

net.Receive("veh_col", function (len, pl)
	local dmg = net.ReadInt(32)/800;
	if (IsValid(pl) and IsValid(pl:GetVehicle())) then
		if not (pl:GetVehicle().LastColDmgTaken) then pl:GetVehicle().LastColDmgTaken = 0; end;
		if (CurTime() >= pl:GetVehicle().LastColDmgTaken + 1) then
			pl:GetVehicle():TakeDamage(dmg, nil, nil)
			--print("Gave "..dmg)
			pl:GetVehicle().LastColDmgTaken = CurTime()
		end
	end
end)

local function IsSCar( veh )
		if IsValid(veh) and veh.Base and veh.Base == "sent_sakarias_scar_base" then
				return true
		end
		return false
end
 
local function IsSCarSeat( seat )
		if IsValid(seat) and seat.IsScarSeat and seat.IsScarSeat == true then
				return true
		end
		return false
end
 
local function SpawnedVehicle( ply, vehicle )
		if not IsValid(ply) then return end
		if (ply:GetCount("vehicles") > 0 and !ply:IsSuperAdmin()) then
			evorp.player.notify(ply, "You already have a vehicle out! Go find it!", 1);
			vehicle:Remove()
			return true
		else
			ply:AddCount("vehicles", vehicle);
		end
		if not (vehicle:GetClass() == "prop_vehicle_jeep") then return true end
		evorp.player.giveDoor(ply, vehicle, ply:GetName().."'s Vehicle", true)
		vehicle:SetNetworkedBool("locked", true)
		vehicle._Fuel = 11;
		vehicle:SetNetworkedInt("fuel", vehicle._Fuel)
		vehicle:CPPISetOwner(ply);
		local rand = evorp.configuration["Default Colors"][ math.random( #evorp.configuration["Default Colors"] ) ] 
		if not (vehicle.VehicleTable.nopaint) then vehicle:SetColor(rand); end
		if !IsSCar( vehicle ) then

			local localpos = vehicle:GetPos()
			local localang = vehicle:GetAngles()
		   
			local seatdata = (list.Get( "Vehicles" )[ "airboat_seat" ] or {})

			if (seatdata == nil) then print("Can't read the vehicle data!") return end
		   
			vehicle.Seats = {}
		   	
			local vcextraseats = (vehicle.VehicleTable.VC_ExtraSeats or {})

			for a,b in pairs(vcextraseats) do
				local SeatPos = localpos + ( localang:Forward() * b.Pos.x) + ( localang:Right() * b.Pos.y) + ( localang:Up() * b.Pos.z)
				local Seat = ents.Create( "prop_vehicle_prisoner_pod" )
			   
				local SeatPos = localpos + ( localang:Forward() * b.Pos.x) + ( localang:Right() * b.Pos.y) + ( localang:Up() * b.Pos.z)
				local Seat = ents.Create( "prop_vehicle_prisoner_pod" )
				Seat:SetModel( seatdata.Model )
				Seat:SetKeyValue( "vehiclescript" , "scripts/vehicles/prisoner_pod.txt" )
				Seat:SetAngles( localang + b.Ang )
				Seat:SetPos( vehicle:LocalToWorld(b.Pos) )
				Seat:Spawn()
				Seat:SetMoveType(MOVETYPE_NOCLIP);
				Seat:Activate()
			   
				if b.Hide then
					Seat:SetColor(Color(255,255,255, 0))
					Seat:SetRenderMode( RENDERMODE_TRANSALPHA )
				end
			   
				constraint.Weld(Seat, vehicle, 0,0,0,0)
				Seat:SetParent(vehicle)
			   	Seat.PartOf = vehicle;
				if ( seatdata.KeyValues ) then
					for k, v in pairs( seatdata.KeyValues ) do
					Seat:SetKeyValue( k, v )
					end            
				end
							   
					   
				Seat.VehicleName = "Jeep Seat"
				Seat.ClassOverride = "prop_vehicle_prisoner_pod"
				Seat.locked = false --doesn't matter
				Seat.seata = true;
				Seat:DeleteOnRemove( vehicle )
				table.insert(vehicle.Seats, Seat)
			end
			
		end
end
hook.Add( "PlayerSpawnedVehicle", "SpawnedVehicle", SpawnedVehicle )
 
local function HonkHorn( player,cmd,arg )
	if not (player.NextHornUse <= CurTime()) then return end
	player.NextHornUse = CurTime() + 3
	if player:InVehicle() then
	  local vehicle = player:GetVehicle()
	  if vehicle.VehicleTable then
			player:GetVehicle():EmitSound(vehicle.VehicleTable.VC_Horn.Sound, 40, 100)
	  end
	end
end
concommand.Add( "HonkHorn", HonkHorn )

local function HonkSiren( player,cmd,arg )
	if not (player.NextSirenUse <=  CurTime()) then return  end
	player.NextSirenUse = CurTime() + 30
	if player:InVehicle() then
	  local vehicle = player:GetVehicle()
	  if vehicle.VehicleTable then
	  	if (vehicle.VehicleTable.VC_Siren) then
			player:GetVehicle():EmitSound(vehicle.VehicleTable.VC_Siren.Sound, 80, 100)
	  	end
	  end
	end
end
concommand.Add( "HonkSiren", HonkSiren )
 
local function SetPlayerInts( ply )
	ply.NextToggleCruise = 0;
	ply.NextSirenUse = 0
	ply.NextHornUse = 0
	ply.canuse = true
	ply.nextHyd = CurTime()
	ply:SetNetworkedInt("nextHyd", ply.nextHyd);
end
hook.Add("PlayerSpawn", "ghtrshstrhtsrhtr", SetPlayerInts)
 
function ChooseSeat( ply, car )
		if not (car:GetClass() == "prop_vehicle_jeep" and car:IsVehicle()) then return true end
		if not (ply.NextEnterTry) then ply.NextEnterTry = 0 end
		if (ply.NextEnterTry  > CurTime()) then return false else ply.NextEnterTry  = CurTime() + 2; end
		if ply:InVehicle() then
			ply.canuse = false
			timer.Simple(2, function() ply.canuse = true end)
			return false
		end

		ply.canuse = ply.canuse or true
	   	if car:GetNetworkedBool("locked") then
	   		--car:EmitSound("doors/door_latch3.wav", 100, 100) 
			return false
		end
		if not (IsValid(car:GetDriver())) then
			if  (ply:GetNetworkedBool("hostaged") or ply:GetNetworkedBool("cuffed")) then
				evorp.player.notify(ply, "You can't drive in your current state!", 1);
				return false
			end
			if (!evorp.player.hasAccess(ply, "v")) then
				evorp.player.notify(ply, "You are banned from driving vehicles. Go online for more information!", 1);
				return false
			end
			return true
		end
		if (ply.canuse) then
 			ply.canuse = false
			timer.Simple(2, function() ply.canuse = true end)
   
			local distancetable = {}
			for k, v in pairs(ents.FindInSphere(ply:GetPos(), 64)) do
				if IsValid (v) and v:GetClass() == "prop_vehicle_prisoner_pod" && car != v then
					if !(IsOnCar( v, car )) then continue end
					local dtable = {
							seat = v,
							distance = v:GetPos():Distance( ply:GetPos() )
					}
					table.insert( distancetable, dtable )
				end
			end
		   
			local maxdist = 500
			local nearestseat = 1
			local found = false
			for k, v in pairs( distancetable ) do
					if v.distance < maxdist then
							maxdist = v.distance
							nearestseat = k
							found = true
					end
			end
		   
		   
			if !(found) then
				return false
			end
			distancetable[nearestseat].seat._NextExit = CurTime() + 2;
			timer.Simple(.1, function() ply:EnterVehicle( distancetable[nearestseat].seat ) end)
			return false
		else
			return false;
		end
end
hook.Add("PlayerUse", "ChooseSeat", ChooseSeat)
 --[[
local function FlipCar( ply )
	local pos = ply:EyePos()
	local tracedata = {}
	tracedata.start = pos
	tracedata.endpos = pos+(ply:GetForward()*450)
	tracedata.filter = ply
	local tr = util.TraceLine(tracedata)
   
	if tr.Entity:IsVehicle() && !(tr.Entity:GetClass() == "prop_vehicle_prisoner_pod") then
	local mass = tr.Entity:GetPhysicsObject():GetMass()
		tr.Entity:GetPhysicsObject():SetVelocity(tr.Entity:GetUp()*-(mass/2) + tr.Entity:GetRight()*5)
	end
end

concommand.Add("unflip", FlipCar)
 ]]
local function catchHyd ( Player )
	if (Player.nextHyd && Player.nextHyd > CurTime()) then return end
	Player.nextHyd = CurTime() + 30
	Player:SetNetworkedInt("nextHyd", Player.nextHyd);
	if (!Player:InVehicle()) then return end
   
	local vehicleTable = Player:GetVehicle().VehicleTable
   
	if (!vehicleTable) then return end
   
	if not (Player.evorp._Donator > CurTime() or Player:IsAdmin()) then return end
	Player:GetVehicle():GetPhysicsObject():ApplyForceCenter(Player:GetVehicle():GetForward() * Player:GetVehicle():GetPhysicsObject():GetMass() * 700)
   	timer.Simple(.5, boostCar, Player)
   	timer.Simple(1, boostCar, Player)
   	timer.Simple(1.5, boostCar, Player)
   	timer.Simple(2, boostCar, Player)
   	timer.Simple(2.5, boostCar, Player)
   	timer.Simple(3, boostCar, Player)
   	timer.Simple(3.5, boostCar, Player)
   	timer.Simple(4, boostCar, Player)
   	timer.Simple(4.5, boostCar, Player)
	timer.Simple(5, boostCar, Player)
	--EMIT NITRO SOUND!
end
concommand.Add("hydr", catchHyd)

function boostCar (Player)
	if (IsValid(Player) and Player:InVehicle() and IsValid(Player:GetVehicle()) and Player:GetVehicle():GetClass() == "prop_vehicle_jeep" and Player:KeyDown( IN_FORWARD )) then
		Player:GetVehicle():GetPhysicsObject():ApplyForceCenter(Player:GetVehicle():GetForward() * Player:GetVehicle():GetPhysicsObject():GetMass() * 400)
	end
end
 
function IsOnCar( seat, car )
	local cons = constraint.GetAllConstrainedEntities( car )
   
	for k, v in pairs(cons) do
			if IsValid( v ) && v == seat then
					return true
			end
	end
	return false
end
 
 
hook.Add("CanExitVehicle", "PAS_ExitVehicle", function( veh, ply )
	if (veh._NextExit) then
		if (CurTime() < veh._NextExit) then 
			return false
		end
	end
	if !IsSCarSeat( veh ) then
			// L+R
			if ply:VisibleVec( veh:LocalToWorld(Vector(90, 0, 90) )) then
					ply:ExitVehicle()
					ply:SetPos( veh:LocalToWorld(Vector(90, 0, 45) ))
					ply:ConCommand("vehicleout")
					return false
			end
		   
			if ply:VisibleVec( veh:LocalToWorld(Vector(-90, 0, 90) )) then
					ply:ExitVehicle()
					ply:SetPos( veh:LocalToWorld(Vector(-90, 0, 45) ))
					ply:ConCommand("vehicleout")
					return false
			end
	end
	--return false --//YOU SHOULDNT RETURN HERE! THIS WILL OVERRIDE THE HOOKS FOR ALL OTHER MOUNTED ADDONS
end)	
	

local ply = nil

-- WeHateGarbage
local t = {start=nil,endpos=nil,mask=MASK_PLAYERSOLID,filter=nil}
function PlayerNotStuck( ply )

	t.start = ply:GetPos()
	t.endpos = t.start
	t.filter = ply

	return util.TraceEntity(t,ply).StartSolid == false

end

local NewPos = nil
function FindPassableSpace( direction, step )

	local i = 0
	while ( i < 100 ) do
		local origin = ply:GetPos()

		--origin = VectorMA( origin, step, direction )
		origin = origin + step * direction

		ply:SetPos( origin )
		if ( PlayerNotStuck( ply ) ) then
			NewPos = ply:GetPos()
			return true
		end
		i = i + 1
	end
	return false
end

/*
	Purpose: Unstucks player ,
	Note: Very expensive to call, you have been warned!
*/
function UnstuckPlayer( pl )
	ply = pl

	NewPos = ply:GetPos()
	local OldPos = NewPos

	if ( !PlayerNotStuck( ply ) ) then

		local angle = ply:GetAngles()

		local forward = angle:Forward()
		local right = angle:Right()
		local up = angle:Up()

		local SearchScale = 5 -- Increase and it will unstuck you from even harder places but with lost accuracy. Please, don't try higher values than 12
		if ( !FindPassableSpace(  forward, SearchScale ) )
		then
			if ( !FindPassableSpace(  right, SearchScale ) )
			then
				if ( !FindPassableSpace(  right, -SearchScale ) )		// left
				then
					if ( !FindPassableSpace(  up, SearchScale ) )	// up
					then
						if ( !FindPassableSpace(  up, -SearchScale ) )	// down
						then
							if ( !FindPassableSpace(  forward, -SearchScale ) )	// back
							then

								-- spam spam spam

								--Msg( "Can't find the world for player "..tostring(ply).."\n" )

								return false

							end
						end
					end
				end
			end
		end

		if OldPos == NewPos then
			--print("Unstuck: Shouldnothappen")
			return true -- Not stuck?
		else
			ply:SetPos( NewPos )
			if SERVER and ply and ply:IsValid() and ply:GetPhysicsObject():IsValid() then
				if ply:IsPlayer() then
					ply:SetVelocity(vector_origin)
				end
				ply:GetPhysicsObject():SetVelocity(vector_origin) -- prevents bugs :s
			end

			--Msg( "Unstucked player "..tostring(ply).."\n" )
			return true
		end

	end


end