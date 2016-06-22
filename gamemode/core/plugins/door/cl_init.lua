--[[
Name: "cl_init.lua".
Product: "EvoRP (Roleplay)".
--]]

local PLUGIN = {};

-- Create a variable to store the plugin for the shared file.
PLUGIN_SHARED = PLUGIN;

-- Include the shared file.
include("sh_init.lua");

function CalculatePositioning(door, reverse)
	local obbCenter = door:OBBCenter();
	local obbMaxs = door:OBBMaxs();
	local obbMins = door:OBBMins();
	local data = {};
   
	data.endpos = door:LocalToWorld(obbCenter);
	data.filter = ents.FindInSphere(data.endpos, 20);
   
	for k, v in pairs(data.filter) do
		if (v == door) then
			data.filter[k] = Entity(0);
		end;
	end;
   
	local width = 0;
	local length = 0;
	
	local size = obbMins - obbMaxs;
	size.x = math.abs(size.x);
	size.y = math.abs(size.y);
	size.z = math.abs(size.z);
	
	if (size.z < size.x and size.z < size.y) then
			width = size.y;
			length = size.z;
			
			if (reverse) then
				data.start = data.endpos - door:GetUp() * length;
				
			else
				data.start = data.endpos + door:GetUp() * length;
			end
			
	elseif (size.x < size.y) then
			width = size.y;
			length = size.x;
			
			if reverse then
				data.start = data.endpos - door:GetForward() * length;
			else
				data.start = data.endpos + door:GetForward() * length;
			end
	elseif (size.y < size.x) then
		width = size.x;
		length = size.y;
		if (reverse) then
			data.start = data.endpos - door:GetRight() * length;
		else
			data.start = data.endpos + door:GetRight() * length;	
		end;
	end;
	
	width = math.abs(width);
	
	local trace = util.TraceLine(data);
	
	if (trace.HitWorld and !reverse) then
		return CalculatePositioning(door, true);
	end;
	
	local ang = trace.HitNormal:Angle();
	ang:RotateAroundAxis(ang:Forward(), 90);
	ang:RotateAroundAxis(ang:Right(), 90);
   
	local pos = trace.HitPos - ((data.endpos - trace.HitPos):Length() * 2) * trace.HitNormal;
	
	local angBack = trace.HitNormal:Angle();
	angBack:RotateAroundAxis(angBack:Forward(), 90);
	angBack:RotateAroundAxis(angBack:Right(), -90);
	
	local posBack = trace.HitPos;

	return pos, ang, posBack, angBack, width, trace.HitWorld;
end


hook.Add("RenderScreenspaceEffects", "evorp_Door_Text", function()
	if (!LocalPlayer():Alive()) then return; end;
	
	local find = ents.FindInSphere(LocalPlayer():EyePos(), 275);
	local eyePos = EyePos();
	local eyeAngles = EyeAngles();
	
	for _, ent in pairs(find) do
		if IsValid(ent) then
			if (evorp.entity.isDoor(ent) and ent:GetClass() != "prop_vehicle_jeep" and !ent:GetNetworkedBool("iDoor")) then
				local pos, ang, posBack, angBack, width, hitWorld = CalculatePositioning(ent);
				
				if (!hitWorld) then
					local dist = LocalPlayer():EyePos():Distance(ent:GetPos());
					local alpha = math.Clamp(255 - (255 * (dist / 275)), 0, 255);
					local eyePos = EyePos();
					local eyeAngles = EyeAngles();
					
					local unownable = ent:GetNetworkedBool("evorp_Unownable");
					local owner = ent:GetNetworkedEntity("evorp_Owner");
					local name = ent:GetNetworkedString("evorp_Name");
				
					-- Check if the door is unownable.
					if (unownable or ent.unownable) then
						owner = "";
						
						-- Check to see if the name is an empty string.
						if (name == "") then name = ent.name or ""; end;
					else
						if (IsValid(owner)) then
							owner = owner:Nick().."'s Door";
						else
							owner = "Purchase door";
							name = "Press F2";
						end;
					end;
					
					if (name and owner) then
						surface.SetFont("LabelFont");
						local nameWidth = surface.GetTextSize(name);
						surface.SetFont("LabelFont");
						local ownerWidth = surface.GetTextSize(owner);
						
						local longWidth = nameWidth;
						if (ownerWidth > nameWidth) then
							longWidth = ownerWidth;
						end;
						
						local scale = math.Clamp(math.abs((width * 0.65) / longWidth), 0, 0.075);
							
						cam.Start3D(eyePos, eyeAngles);
							cam.Start3D2D(pos + Vector(0, 0, 10), ang, scale);
								draw.SimpleTextOutlined(owner, "LabelFont", 0, -99, Color(240, 240, 240, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 4, Color(0, 0, 0, math.Clamp(alpha, 0, 150)));
								draw.SimpleTextOutlined(name, "LabelFont", 0, 0, Color(230, 230, 230, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 4, Color(0, 0, 0, math.Clamp(alpha, 0, 150)));
							cam.End3D2D();
							
							cam.Start3D2D(posBack + Vector(0, 0, 10), angBack, scale);
								draw.SimpleTextOutlined(owner, "LabelFont", 0, -99, Color(240, 240, 240, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 4, Color(0, 0, 0, math.Clamp(alpha, 0, 150)));
								draw.SimpleTextOutlined(name, "LabelFont", 0, 0, Color(230, 230, 230, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 4, Color(0, 0, 0, math.Clamp(alpha, 0, 150)));
							cam.End3D2D();
						cam.End3D();
					end;
				end
			end;
		end;
	end;
end);

-- Register the plugin.
evorp.plugin.register(PLUGIN);
