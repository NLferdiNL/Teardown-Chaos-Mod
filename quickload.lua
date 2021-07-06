-- Workaround from UMF: https://github.com/Thomasims/TeardownUMF/blob/master/core/default_hooks.lua#L57-L100

local saved = {}
QL = { i = function() end }

local function hasfunction( t, bck )
	if bck[t] then
		return
	end
	bck[t] = true
	for k, v in pairs( t ) do
		if type( v ) == "function" then
			return true
		end
		if type( v ) == "table" and hasfunction( v, bck ) then
			return true
		end
	end
end

function UpdateQuickloadPatch()
	for k, v in pairs( _G ) do
		if k ~= "_G" and type( v ) == "table" and hasfunction( v, {} ) then
			saved[k] = v
		end
	end
end

function hasQuickloaded()
	return QL.i == nil
end

local quickloadfix = function()
	for k, v in pairs( saved ) do
		_G[k] = v
	end
end

function quickloadTick()
	if hasQuickloaded() then
		quickloadfix()
	end
end

