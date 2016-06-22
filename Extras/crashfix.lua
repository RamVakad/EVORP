print("Crash Fix Enabled")
local freezespeed = 250
local removespeed = 5000
hook.Add("Think","AMB_CrashCatcher",function()
	for k, ent in pairs(ents.FindByClass("prop_ragdoll")) do
		local velo = ent:GetVelocity( ):Length()
		if IsValid(ent) and velo >= freezespeed then
			AMB_KillVelocity(ent)
			print("[!CRASHCATCHER!] Caught ragdoll entity moving too fast ("..velo.."), disabling motion. \n")
		end
	end
end)

function AMB_SetSubPhysMotionEnabled(ent, enable)
	if not IsValid(ent) then return end
   
	ent:SetVelocity(vector_origin)

	for i=0, ent:GetPhysicsObjectCount()-1 do
		local subphys = ent:GetPhysicsObjectNum(i)
		if IsValid(subphys) then
			subphys:EnableMotion(enable)
			if !(enable) then
				subphys:SetVelocity(vector_origin)
				subphys:SetMass(subphys:GetMass()*20)
			end
			if enable then
				subphys:SetMass(subphys:GetMass()/20)
				subphys:Wake()
			end
		end
	end
	
	ent:SetVelocity(vector_origin)
end

function AMB_KillVelocity(ent)
   AMB_SetSubPhysMotionEnabled(ent, false)
   timer.Simple(.05, function() AMB_SetSubPhysMotionEnabled(ent, true) end)
end
