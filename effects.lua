#include "utils.lua"

function chaosKeysInit()
	chaosEffects.disabledEffects = DeserializeTable(GetString(moddataPrefix.. "DisabledEffects"))

	local i = 1
	
	for key, value in pairs(chaosEffects.effects) do
		chaosEffects.effectKeys[i] = key
		i = i + 1
	end

	table.remove(chaosEffects.activeEffects, 1)
end

function removeDisabledEffectKeys()
	local newTable = {}
	local i = 1

	for key, value in ipairs(chaosEffects.effectKeys) do
		if chaosEffects.disabledEffects[value] == nil then
			newTable[i] = value
			i = i + 1
		end
	end
	
	chaosEffects.effectKeys = newTable
end

chaosEffects = {
	maxEffectsLogged =  5,
	activeEffects = {0},
	
	disabledEffects = {},
	
	effectTemplate = {
		name = "Name", -- This is what shows up on the UI.
		effectDuration = 0, -- If more than 0 this is a timed effect and will last.
		effectLifetime = 0, -- Keep this at 0, this is how long the effect has been running for.
		effectVariables = {}, -- Any variables the effect has access to.
							  -- The reason you want your variables in here rather than its parent Table is readability.
							  -- The effect does get full access to itself so you can edit every variable in it.
		onEffectStart = function(vars) end, -- Called when the effect is instantiated. Also called if the effect is not timed.
		onEffectTick = function(vars) end, -- Program your effect in this function. Not called for non-timed effects.
		onEffectEnd = function(vars) end, -- Called for timed effects on end.
	},
	
	noEffectsEffect = {
		name = "No effects enabled!",
		effectDuration = 10,
		effectLifetime = 0,
		effectVariables = {},
		onEffectStart = function(vars) end,
		onEffectTick = function(vars) end,
		onEffectEnd = function(vars) end,
	},
	
	effectKeys = {}, -- Leave empty, this is populated automatically.
	
	effects = {
		instantDeath = {
			name = "Suicide",
			effectDuration = 5,
			effectLifetime = 0,
			effectVariables = {},
			onEffectStart = function(vars) 
				SetPlayerHealth(0)
			end,
			onEffectTick = function(vars) end,
			onEffectEnd = function(vars)
				if GetPlayerHealth() <= 0 then
					RespawnPlayer()
				end
			end,
		},
		
		launchPlayerUp = {
			name = "Launch Player Up",
			effectDuration = 0,
			effectLifetime = 0,
			effectVariables = {},
			onEffectStart = function(vars) 
				local currentVehicleHandle = GetPlayerVehicle()
				local upVel = Vec(0, 25, 0)
				if currentVehicleHandle ~= 0 then
					local currentVehicleBody = GetVehicleBody(currentVehicleHandle)
					SetBodyVelocity(currentVehicleBody, upVel)
				else
					SetPlayerVelocity(upVel)
				end
			end,
			onEffectTick = function(vars) end,
			onEffectEnd = function(vars) end,
		},
		
		jetpack = {
			name = "Jetpack",
			effectDuration = 15,
			effectLifetime = 0,
			effectVariables = {},
			onEffectStart = function(vars) end,
			onEffectTick = function(vars)
				if InputDown("space") then
					local tempVec = GetPlayerVelocity()
					
					tempVec[2] = 5
					
					SetPlayerVelocity(tempVec)
				end
			end,
			onEffectEnd = function(vars) end,
		},
		
		launchPlayerAnywhere = {
			name = "Launch Player",
			--credits = "Creation's",
			effectDuration = 0,
			effectLifetime = 0,
			effectVariables = {},
			onEffectStart = function(vars) 
				local velocity = rndVec(20)
				
				local currentVehicleHandle = GetPlayerVehicle()
				if currentVehicleHandle ~= 0 then
					local currentVehicleBody = GetVehicleBody(currentVehicleHandle)
					
					velocity[2] = math.abs(velocity[2])
					
					SetBodyVelocity(currentVehicleBody, velocity)
				else
					SetPlayerVelocity(velocity)
				end
				
			end,
			onEffectTick = function(vars) end,
			onEffectEnd = function(vars) end,
		} ,
		
		explosionAtPlayer = {
			name = "Explode Player",
			effectDuration = 0,
			effectLifetime = 0,
			effectVariables = {},
			onEffectStart = function(vars) 
				Explosion(GetPlayerPos(), 7.5)
				SetPlayerHealth(1)
			end,
			onEffectTick = function(vars) end,
			onEffectEnd = function(vars) end,
		},
		
		fireAtPlayer = {
			name = "Set Player On Fire",
			effectDuration = 5,
			effectLifetime = 0,
			effectVariables = {},
			onEffectStart = function(vars) end,
			onEffectTick = function(vars)
				local playerTransform = GetPlayerTransform()
				
				SpawnFire(playerTransform.pos)
			end,
			onEffectEnd = function(vars) end,
		},
		
		removeCurrentVehicle = {
			name = "Remove Current Vehicle",
			effectDuration = 0,
			effectLifetime = 0,
			effectVariables = {},
			onEffectStart = function(vars) 
				local vehicle = GetPlayerVehicle()
				if vehicle ~= 0 then
					Delete(GetVehicleBody(vehicle))
				end
			end,
			onEffectTick = function(vars) end,
			onEffectEnd = function(vars) end,
		},
		
		holedUp = {
			name = "Hole'd up",
			effectDuration = 3,
			effectLifetime = 0,
			effectVariables = {},
			onEffectStart = function(vars) end,
			onEffectTick = function(vars) 
				local playerTransform = GetPlayerTransform()
				
				MakeHole(playerTransform.pos, 1, 1, 1)
			end,
			onEffectEnd = function(vars) end,
		},
		
		stopAndStare = {
			name = "Stop And Stare",
			effectDuration = 5,
			effectLifetime = 0,
			effectVariables = {},
			onEffectStart = function(vars) end,
			onEffectTick = function(vars)
				SetPlayerVehicle(0)
				SetPlayerVelocity(Vec(0, 0, 0))
			end,
			onEffectEnd = function(vars) end,
		},
		
		myGlasses = {
			name = "My Glasses!",
			effectDuration = 12,
			effectLifetime = 0,
			effectVariables = {},
			onEffectStart = function(vars) end,
			onEffectTick = function(vars)
				table.insert(drawCallQueue, function() UiBlur(1) end)
			end,
			onEffectEnd = function(vars) end,
		},
		
		slomo25 = {
			name = "0.2x Gamespeed",
			effectDuration = 12,
			effectLifetime = 0,
			effectVariables = {},
			onEffectStart = function(vars) 
				timeScale = 0.25
			end,
			onEffectTick = function(vars) end,
			onEffectEnd = function(vars) 
				timeScale = 1
			end,
		},
		
		slomo50 = {
			name = "0.5x Gamespeed",
			effectDuration = 12,
			effectLifetime = 0,
			effectVariables = {},
			onEffectStart = function(vars) 
				timeScale = 0.5
			end,
			onEffectTick = function(vars) end,
			onEffectEnd = function(vars) 
				timeScale = 1
			end,
		},
		
		smokeScreen = {
			name = "Smokescreen",
			effectDuration = 12,
			effectLifetime = 0,
			effectVariables = {},
			onEffectStart = function(vars) end,
			onEffectTick = function(vars)
				for i = 1, 5 do
					local direction = rndVec(10)
					SpawnParticle("smoke", GetPlayerPos(), direction, 5, 2)
				end
			end,
			onEffectEnd = function(vars) end,
		},
		
		takeABreak = {
			name = "Take A Break",
			effectDuration = 0,
			effectLifetime = 0,
			effectVariables = {},
			onEffectStart = function(vars) 
				SetPaused(true)
			end,
			onEffectTick = function(vars) end,
			onEffectEnd = function(vars) end,
		},
		
		invincibility = {
			name = "Invincibility",
			effectDuration = 20,
			effectLifetime = 0,
			effectVariables = {},
			onEffectStart = function(vars) end,
			onEffectTick = function(vars) 
				SetPlayerHealth(1)
			end,
			onEffectEnd = function(vars) end,
		},
		
		teleportToSpawn = {
			name = "Teleport To Spawn",
			effectDuration = 0,
			effectLifetime = 0,
			effectVariables = {},
			onEffectStart = function(vars) 
				SetPlayerVehicle(0)
				
				RespawnPlayer()
			end,
			onEffectTick = function(vars) end,
			onEffectEnd = function(vars) end,
		},
		
		oneHitKO = {
			name = "One Hit KO",
			effectDuration = 7,
			effectLifetime = 0,
			effectVariables = {},
			onEffectStart = function(vars) end,
			onEffectTick = function(vars) 
				if GetPlayerHealth() > 0.1 then
					SetPlayerHealth(0.1)
				end
			end,
			onEffectEnd = function(vars) end,
		},
		
		tiredPlayer = {
			name = "I'm Tired",
			effectDuration = 20,
			effectLifetime = 0,
			effectVariables = {fadeAlpha = 0, waking = false},
			onEffectStart = function(vars) end,
			onEffectTick = function(vars)
				local deltatime = GetTimeStep()
				
				if vars.effectVariables.waking then
					vars.effectVariables.fadeAlpha = vars.effectVariables.fadeAlpha - deltatime
				else
					vars.effectVariables.fadeAlpha = vars.effectVariables.fadeAlpha + deltatime
				end
				
				if vars.effectVariables.fadeAlpha > 1 then
					vars.effectVariables.waking = true
				elseif vars.effectVariables.fadeAlpha < 0 then
					vars.effectVariables.waking = false
				end
				
				table.insert(drawCallQueue, function()
				UiPush()
				
					UiColor(0, 0, 0, vars.effectVariables.fadeAlpha)
					UiAlign("center middle")
					UiTranslate(UiCenter(), UiMiddle())
					UiRect(UiWidth() + 10, UiHeight() + 10)
				
				UiPop()
				end)
			end,
			onEffectEnd = function(vars) end,
		},
		
		airstrike = {
			name = "Airstrike",
			--credits = "GGProGaming & tezlynreardon",
			effectDuration = 15,
			effectLifetime = 0,
			effectVariables = { maxShells = 50, shellNum = 1, defaultShell = { active = false, explode = false, velocity = 500 }, shells = {}, debugVar = {},},
			onEffectStart = function(vars) end,
			onEffectTick = function(vars)
				function AirstrikeOperations(projectile)
					projectile.predictedBulletVelocity = VecAdd(projectile.predictedBulletVelocity, (VecScale(projectile.gravity, GetTimeStep()/4)))
					local point2 = VecAdd(projectile.pos, VecScale(projectile.predictedBulletVelocity, GetTimeStep()/4))
					local dir = VecNormalize(VecSub(point2, projectile.pos))
					local distance = VecLength(VecSub(point2, projectile.pos))
					local hit, dist, normal, shape = QueryRaycast(projectile.pos, dir, distance)
					if hit then
						projectile.explode = true
						table.insert(vars.effectVariables.debugVar, {shape, 3})
					else
						projectile.pos = point2
					end
				end
				
				function randomPosInSky()
					local playerPos = GetPlayerPos()
					
					playerPos[2] = playerPos[2] + 150
					
					playerPos[1] = playerPos[1] + math.random(-50, 50)
					playerPos[3] = playerPos[3] + math.random(-50, 50)
					
					return playerPos
				end
				
				function randomDirection(projectilePos)
					local playerPos = GetPlayerPos()
					
					local direction = dirVec(projectilePos, playerPos)
					
					direction[2] = 0
					
					local randomVec = rndVec(0.5)
					
					randomVec[2] = -1
					
					return VecNormalize(VecAdd(direction, randomVec))
				end
				
				function createRocket(pos)
					vars.effectVariables.shells[vars.effectVariables.shellNum] = deepcopy(vars.effectVariables.defaultShell)
					local direction = randomDirection(pos)
					
					local loadedShell = vars.effectVariables.shells[vars.effectVariables.shellNum] 
					loadedShell.active = true
					loadedShell.pos = pos
					loadedShell.predictedBulletVelocity = VecScale(direction, loadedShell.velocity)
					
					vars.effectVariables.shellNum = (vars.effectVariables.shellNum % vars.effectVariables.maxShells) + 1
				end
				
				if math.random(1, 20) >= 16 then
					createRocket(randomPosInSky())
				end
				
				for key, shell in ipairs(vars.effectVariables.shells) do
					if shell.active and shell.explode then
						shell.active = false
						Explosion(shell.pos, 2)
					end

					if shell.active then
						AirstrikeOperations(shell)
						SpawnParticle("smoke", shell.pos, 0.5, 0.5, 0.5)
					end
				end
				
				for key, shapePair in ipairs(vars.effectVariables.debugVar) do
					DrawShapeOutline(shapePair[1], 1, 0, 0, 100 / 2 * shapePair[2] / 100)
					shapePair[2] = shapePair[2] - GetTimeStep()
				end
			end,
			onEffectEnd = function(vars) end,
		},

		laserVision = {
			name = "Laser Vision",
			effectDuration = 10,
			effectLifetime = 0,
			effectVariables = {},
			onEffectStart = function(vars) end,
			onEffectTick = function(vars)
				function raycast()
					local t = GetCameraTransform()
					local dir = TransformToParentVec(t, {0, 0, -1})
					
					local hit, dist, normal, shape = QueryRaycast(t.pos, dir, 1000)
					if hit then
						local hitPoint = VecAdd(t.pos, VecScale(dir, dist))
						return hitPoint
					end
				end
				
				hitPoint = raycast()
				MakeHole(hitPoint, 0.2, 0.2, 0.2)
				SpawnParticle("smoke", hitPoint, Vec(0, 1, 0), 1, 2)
			end,
			onEffectEnd = function(vars) end,
		},
	},
}

chaosKeysInit()