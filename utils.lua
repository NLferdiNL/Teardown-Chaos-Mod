moddataPrefix = "savegame.mod.chaosMod"

function saveFileInit()
	saveVersion = GetInt(moddataPrefix .. "Version")
	chaosTimer = GetFloat(moddataPrefix .. "ChaosTimer")
	chaosEffects.disabledEffects = DeserializeTable(GetString(moddataPrefix.. "DisabledEffects"))
	twitchIntegration = GetBool(moddataPrefix .. "TwitchIntegration")
	twitchBalancing = GetFloat(moddataPrefix .. "TwitchBalancing")
	
	chaosTimerBackup = chaosTimer

	if saveVersion < 1 then
		saveVersion = 1
		SetInt(moddataPrefix .. "Version", 1)

		chaosTimer = 10
		chaosTimerBackup = chaosTimer
		SetFloat(moddataPrefix .. "ChaosTimer", chaosTimer)
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

		DebugPrint(chaosEffects.effects.fakeDeleteVehicle.name .. " is disabled by default now. You can reenable them in the options menu.")
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
			DebugPrint("This reset will only occur once.")
		end

		SetString(moddataPrefix.. "DisabledEffects", SerializeTable(chaosEffects.disabledEffects))
	end
	
	if saveVersion < 6 then
		saveVersion = 6
		SetInt(moddataPrefix .. "Version", 6)

		chaosEffects.disabledEffects = DeserializeTable(GetString(moddataPrefix.. "DisabledEffects"))

		if chaosEffects.disabledEffects["unbreakableEverything"] == nil then
			chaosEffects.disabledEffects["unbreakableEverything"] = "disabled"
		end
		
		if chaosEffects.disabledEffects["allVehiclesInvulnerable"] == nil then
			chaosEffects.disabledEffects["allVehiclesInvulnerable"] = "disabled"
		end
		
		DebugPrint(chaosEffects.effects.unbreakableEverything.name .. " and " .. chaosEffects.effects.allVehiclesInvulnerable.name .. " are disabled by default now.")
		DebugPrint("This is due to their effects carrying over cross quick saves and becoming permanent. You can reenable them in the options menu.")

		SetString(moddataPrefix.. "DisabledEffects", SerializeTable(chaosEffects.disabledEffects))
	end
	
	if saveVersion < 7 then
		saveVersion = 7
		SetInt(moddataPrefix .. "Version", 7)

		twitchIntegration = false
		SetBool(moddataPrefix .. "TwitchIntegration", twitchIntegration)
	end
	
	if saveVersion < 8 then
		saveVersion = 8
		SetInt(moddataPrefix .. "Version", 8)

		twitchBalancing = 1
		SetFloat(moddataPrefix .. "TwitchBalancing", twitchBalancing)
	end
	
	-- This is to fix a typo in version 1.
	-- (which is also fixed now, SETFLOAT NOT GETFLOAT)
	if saveVersion < 9 then
		saveVersion = 9
		SetInt(moddataPrefix .. "Version", 9)
		
		if not HasKey(moddataPrefix .. "ChaosTimer") then
			chaosTimer = 10
			chaosTimerBackup = chaosTimer
			SetFloat(moddataPrefix .. "ChaosTimer", chaosTimer)
		end
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

function splitString(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t = {}
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		table.insert(t, str)
	end
	return t
end

function stringLeftPad(str, len, char)
	if char == nil then char = ' ' end
	return str .. string.rep(char, len - #str)
end

function rndVec(length)
	local v = VecNormalize(Vec(math.random(-100,100), math.random(-100,100), math.random(-100,100)))
	return VecScale(v, length)
end

function dirVec(a, b)
	return VecNormalize(VecSub(b, a))
end

function VecAngle(a, b)
	local magA = VecMag(a)
	local magB = VecMag(b)

	local dotP = VecDot(a, b)

	local angle = math.deg(math.acos(dotP / (magA * magB)))

	return angle
end

function VecDet(a, b)
	local firstDet = a[1] * b[3]
	local secondDet = a[3] * b[1]

	return firstDet - secondDet
end

function VecAngle360(a, b)
	local det = VecDet(a, b)
	local dot = VecDot(a, b)

	local angle = math.deg(math.atan2(det, dot))

	return angle
end

function VecDist(a, b)
	local directionVector = VecSub(b, a)

	local distance = VecMag(directionVector)

	return distance
end

function VecMag(a)
	return math.sqrt(a[1]^2 + a[2]^2 + a[3]^2)
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

function lerp(a, b, i)
	return (a + i*(b - a));
end

--https://stackoverflow.com/questions/68317097/how-to-properly-convert-hsl-colors-to-rgb-colors-in-lua by Francisco
function hslToRgb(h, s, l)
    h = h / 360
    s = s / 100
    l = l / 100

    local r, g, b;

    if s == 0 then
        r, g, b = l, l, l; -- achromatic
    else
        local function hue2rgb(p, q, t)
            if t < 0 then t = t + 1 end
            if t > 1 then t = t - 1 end
            if t < 1 / 6 then return p + (q - p) * 6 * t end
            if t < 1 / 2 then return q end
            if t < 2 / 3 then return p + (q - p) * (2 / 3 - t) * 6 end
            return p;
        end

        local q = l < 0.5 and l * (1 + s) or l + s - l * s;
        local p = 2 * l - q;
        r = hue2rgb(p, q, h + 1 / 3);
        g = hue2rgb(p, q, h);
        b = hue2rgb(p, q, h - 1 / 3);
    end

    if not a then a = 1 end
    return r * 255, g * 255, b * 255, a * 255
end

function trim(s)
	local n = string.find(s,"%S")
	return n and string.match(s, ".*%S", n) or ""
end

--local lastListSpawn = nil
--local lastIndexedSpawnList = nil

function IndexSpawnables()
	local gSpawnList = {}
	local mods = ListKeys("spawn")
	
	--[[if mods == lastListSpawn then
		return lastIndexedSpawnList
	end]]--
	
	local types = {}
	for m=1, #mods do
		local mod = mods[m]
		if HasKey("mods.available." .. mod) then
			local ids = ListKeys("spawn." .. mod)
			for i=1, #ids do
				local tmp = "spawn." .. mod .. "." .. ids[i]
				local n = GetString(tmp)
				local p = GetString(tmp .. ".path")
				local t = "Other"
				local s = string.find(n, "/", 1, true)
				
				if s and s > 1 then
					t = string.sub(n, 1, s-1)
					n = string.sub(n, s+1, string.len(n))
				end
				
				if n == "" then 
					n = "Unnamed"
				end
				
				t = trim(t)
				local found = false
				for j=1, #types do
					if string.lower(types[j]) == string.lower(t) then
						t = types[j]
						found = true
						break
					end
				end
				
				if not found then
					types[#types+1] = t
				end

				local item = {}
				item.name = n
				item.type = t
				item.path = p
				item.mod = mod
				gSpawnList[#gSpawnList+1] = item
			end
		end
	end
	
	--lastListSpawn = mods
	--lastIndexedSpawnList = gSpawnList
	
	return gSpawnList
end

function GetBodySize(body)
	local minPos, maxPos = GetBodyBounds(body)
	
	return VecMag(VecSub(maxPos, minPos))
end