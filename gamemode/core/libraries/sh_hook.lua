--[[
Name: "sh_hook.lua".
Product: "EvoRP (Roleplay)".
--]]

evorp.hook = {};
evorp.hook.stored = {};

-- Add a hook without having to supply a unique ID.
function evorp.hook.add(name, callback, tag)
	local uniqueID = util.CRC( name..": "..tostring(callback) );
	
	-- Add the hook with our generated unique ID.
	hook.Add(name, uniqueID, callback)
	
	-- Insert it into our stored table.
	table.insert(evorp.hook.stored, {name, uniqueID, tag})
	
	-- Return our generated unique ID.
	return uniqueID
end;

-- Remove all hooks registered with this system.
function evorp.hook.removeAll()
	for k, v in pairs(evorp.hook.stored) do
		hook.Remove(v[1], v[2]);
		
		-- Remove the entry from our stored table.
		evorp.hook.stored[k] = nil;
	end;
end;

-- Remove a hook with the specified unique ID.
function evorp.hook.remove(uniqueID)
	for k, v in pairs(evorp.hook.stored) do
		if (v[2] == uniqueID) then
			hook.Remove(v[1], v[2]);
			
			-- Remove the entry from our stored table.
			evorp.hook.stored[k] = nil;
			
			-- We're done here so break.
			break;
		end;
	end;
end;

-- Remove all hooks with the specified tag.
function evorp.hook.removeTagged(tag)
	for k, v in pairs(evorp.hook.stored) do
		if (v[3] == tag) then
			hook.Remove(v[1], v[2]);
			
			-- Remove the entry from our stored table.
			evorp.hook.stored[k] = nil;
		end;
	end;
end;
