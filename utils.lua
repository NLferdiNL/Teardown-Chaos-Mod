moddataPrefix = "savegame.mod.chaosMod"

function saveFileInit()
	saveVersion = GetInt(moddataPrefix .. "Version")
	chaosTimer = GetInt(moddataPrefix .. "ChaosTimer")
	chaosEffects.disabledEffects = DeserializeTable(GetString(moddataPrefix.. "DisabledEffects"))
	
	if saveVersion < 1 then
		saveVersion = 1
		SetInt(moddataPrefix .. "Version", 1)
		
		chaosTimer = 10
		SetInt(moddataPrefix .. "ChaosTimer", chaosTimer)
	end
	
	if saveVersion < 2 then
		saveVersion = 2
		SetInt(moddataPrefix .. "Version", 2)
		
		chaosEffects.disabledEffects = {}
		SetString(moddataPrefix.. "DisabledEffects", "")
	end
	
	if saveVersion < 3 then
		saveVersion = 3
		SetInt(moddataPrefix .. "Version", 3)
		
		chaosEffects.disabledEffects = DeserializeTable(GetString(moddataPrefix.. "DisabledEffects"))
		
		if chaosEffects.disabledEffects["fakeDeleteVehicle"] == nil then
			chaosEffects.disabledEffects["fakeDeleteVehicle"] = "disabled"
		end
		
		DebugPrint(chaosEffects.effects.fakeDeleteVehicle.name .. " is disabled by default now. Use the options to reenable.")
		DebugPrint("Until it is fixed for multi part vehicles.")
		SetString(moddataPrefix.. "DisabledEffects", SerializeTable(chaosEffects.disabledEffects))
	end
	
	if saveVersion < 4 then
		saveVersion = 4
		SetInt(moddataPrefix .. "Version", 4)
		
		chaosEffects.disabledEffects = DeserializeTable(GetString(moddataPrefix.. "DisabledEffects"))
		
		if chaosEffects.disabledEffects["quakefov"] == nil then
			chaosEffects.disabledEffects["quakefov"] = "disabled"
		end
		
		if chaosEffects.disabledEffects["turtlemode"] == nil then
			chaosEffects.disabledEffects["turtlemode"] = "disabled"
		end
		
		SetString(moddataPrefix.. "DisabledEffects", SerializeTable(chaosEffects.disabledEffects))
	end
	
	if saveVersion < 5 then
		saveVersion = 5
		SetInt(moddataPrefix .. "Version", 5)
		
		chaosEffects.disabledEffects = DeserializeTable(GetString(moddataPrefix.. "DisabledEffects"))
		
		if chaosEffects.disabledEffects["quakefov"] ~= nil then
			chaosEffects.disabledEffects["quakefov"] = nil
			DebugPrint("Quake FOV enabled, because it now works with tools.")
			DebugPrint("This will not happen again.")
		end
		
		SetString(moddataPrefix.. "DisabledEffects", SerializeTable(chaosEffects.disabledEffects))
	end
end

function SerializeTable(a) -- Currently only works for key value string tables! (Ignores values)
	local serializedTable = ""
	
	if a == nil then
		return serializedTable
	end
	
	local i = 1
	local tableSize = 0
	
	for key, value in pairs(a) do
		tableSize = tableSize + 1
	end
	
	for key, value in pairs(a) do
		serializedTable = serializedTable .. key
		
		if i < tableSize then
			serializedTable = serializedTable .. ","
		end
		
		i = i + 1
	end
	
	return serializedTable
end

function DeserializeTable(a) -- Currently only works for serialized string tables! (Ignores values)
	if a == nil or a == "" then
		return {}
	end
	
	local deserializedTable = {}
	
	for str in string.gmatch(a, "([^"..",".."]+)") do
		deserializedTable[str] = "disabled"
	end
	
	return deserializedTable
end

function tableToText(inputTable, loopThroughTables)
	loopThroughTables = loopThroughTables or true

	local returnString = "{ "
	for key, value in pairs(inputTable) do
		if type(value) == "string" or type(value) == "number" then
			returnString = returnString .. key .." = " .. value .. ", "
		elseif type(value) == "table" and loopThroughTables then
			returnString = returnString .. key .. " = " .. tableToText(value) .. ", "
		else
			returnString = returnString .. key .. " = " .. tostring(value) .. ", "
		end
	end
	returnString = returnString .. "}"
	
	return returnString
end

function GetEffectCount()
	local effectCount = 0

	for key, value in pairs(chaosEffects.effects) do
		effectCount = effectCount + 1
	end
	
	return effectCount
end

function SortEffectsTable(effectCount)
	effectCount = effectCount or GetEffectCount()
	
	local tableOut = {}
	
	for uid, effect in pairs(chaosEffects.effects) do
		local i = 1
		
		local loop = true
		while loop do
			if i > #tableOut then
				tableOut[i] = {uid, effect.name}
				loop = false
				break
			end
			
			if effect.name < tableOut[i][2] then
				table.insert(tableOut, i, {uid, effect.name})
				loop = false
				break
			end
			
			if i >= #tableOut + 1 or i >= effectCount + 1 then -- Should never occur, just an infinite loop safe guard.
				loop = false
				break
			end
			
			i = i + 1
		end
	end
	
	for key, value in ipairs(tableOut) do
		tableOut[key] = value[1]
	end
	
	return tableOut
end

function roundToTwoDecimals(a) --TODO: Make a better, generic version with more decimal points.
	return math.floor(a * 100)/100
end

function rndVec(length)
	local v = VecNormalize(Vec(math.random(-100,100), math.random(-100,100), math.random(-100,100)))
	return VecScale(v, length)	
end

function dirVec(a, b)
	return VecNormalize(VecSub(b, a))
end

function VecDist(a, b)
	local directionVector = VecSub(b, a)
	
	local distance = VecMag(directionVector)
	
	return distance
end

function VecMag(a)
	return math.sqrt((a[1] * a[1]) + (a[2] * a[2]) + (a[3] * a[3]))
end

function VecToString(vec)
	return vec[1] .. ", " .. vec[2] .. ", " .. vec[3]
end

function raycast(origin, direction, maxDistance, radius, rejectTransparant)
	maxDistance = maxDistance or 500 -- Make this arguement optional, it is usually not required to raycast further than this.
	local hit, distance, normal, shape = QueryRaycast(origin, direction, maxDistance, radius, rejectTransparant)
	
	if hit then
		local hitPoint = VecAdd(origin, VecScale(direction, distance))
		return hit, hitPoint, distance, normal, shape
	end
	
	return false, nil, nil, nil, nil
end

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end
