#include "utils.lua"

function chaosSFXInit()
	for key, value in ipairs(chaosEffects.effectKeys) do
		local currentEffect = chaosEffects.effects[value]
		
		if #currentEffect.effectSFX > 0 then
			for i=1, #currentEffect.effectSFX do
				local isLoop = currentEffect.effectSFX[i]["isLoop"]
				local handle = nil
				
				if isLoop then
					handle = LoadLoop(currentEffect.effectSFX[i]["soundPath"])
				else
					handle = LoadSound(currentEffect.effectSFX[i]["soundPath"])
				end
				
				currentEffect.effectSFX[i] = handle
			end
		end
	end
end

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
	
	debugPrintOrder = {"name", "effectDuration", "effectLifetime", "effectSFX", "effectVariables", "onEffectStart", "onEffectTick", "onEffectEnd"},
	
	effectTemplate = {
		name = "Name", -- This is what shows up on the UI.
		effectDuration = 0, -- If more than 0 this is a timed effect and will last.
		effectLifetime = 0, -- Keep this at 0, this is how long the effect has been running for.
		effectSFX = {}, -- Locations of SFX. Will be replaced by their handle during setup.
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
		effectSFX = {},
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
			effectSFX = {},
			effectVariables = {},
			onEffectStart = function(vars) 
				SetPlayerHealth(0)
			end,
			onEffectTick = function(vars) end,
			onEffectEnd = function(vars)
				if GetPlayerHealth() <= 0 then
					RespawnPlayer() -- This is used on maps that don't auto respawn you.
				end
			end,
		},
		
		launchPlayerUp = {
			name = "Launch Player Up",
			effectDuration = 0,
			effectLifetime = 0,
			effectSFX = {},
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
			effectSFX = {},
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
			effectDuration = 0,
			effectLifetime = 0,
			effectSFX = {},
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
			effectSFX = {},
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
			effectSFX = {},
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
			effectSFX = {},
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
			effectSFX = {},
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
			effectSFX = {},
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
			effectSFX = {},
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
			effectSFX = {},
			effectVariables = {},
			onEffectStart = function(vars) end,
			onEffectTick = function(vars) 
				timeScale = 0.25
			end,
			onEffectEnd = function(vars) end,
		},
		
		slomo50 = {
			name = "0.5x Gamespeed",
			effectDuration = 12,
			effectLifetime = 0,
			effectSFX = {},
			effectVariables = {},
			onEffectStart = function(vars) end,
			onEffectTick = function(vars)
				timeScale = 0.5
			end,
			onEffectEnd = function(vars) end,
		},
		
		smokeScreen = {
			name = "Smokescreen",
			effectDuration = 12,
			effectLifetime = 0,
			effectSFX = {},
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
			effectSFX = {},
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
			effectSFX = {},
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
			effectSFX = {},
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
			effectSFX = {},
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
			effectSFX = {},
			effectVariables = {fadeAlpha = 0, waking = false},
			onEffectStart = function(vars) end,
			onEffectTick = function(vars)
				local deltatime = GetChaosTimeStep() / 2
				
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
			effectDuration = 15,
			effectLifetime = 0,
			effectSFX = {},
			effectVariables = { maxShells = 50, shellNum = 1, defaultShell = { active = false, explode = false, velocity = 500 }, shells = {},},
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
			end,
			onEffectEnd = function(vars) end,
		},

		laserVision = {
			name = "Laser Vision",
			effectDuration = 10,
			effectLifetime = 0,
			effectSFX = {},
			effectVariables = {},
			onEffectStart = function(vars) end,
			onEffectTick = function(vars)
				local cameraTransform = GetCameraTransform()
				local rayDirection = TransformToParentVec(cameraTransform, {0, 0, -1})
				
				local hit, hitPoint = raycast(cameraTransform.pos, rayDirection, 1000)
				
				if hit == false then
					return
				end
				
				MakeHole(hitPoint, 0.2, 0.2, 0.2)
				SpawnParticle("smoke", hitPoint, Vec(0, 1, 0), 1, 2)
			end,
			onEffectEnd = function(vars) end,
		},
		
		teleportToRandomLocation = {
			name = "Teleport To A Random Location",
			effectDuration = 0,
			effectLifetime = 0,
			effectSFX = {},
			effectVariables = {},
			onEffectStart = function(vars)
				local playerTransform = GetPlayerTransform()
				local playerPos = playerTransform.pos
				
				playerPos[2] = playerPos[2] + 50
				
				playerPos[1] = playerPos[1] + math.random(-50, 50)--(-50, 50)
				playerPos[3] = playerPos[3] + math.random(-50, 50)--(-50, 50)
				
				local hit, hitPoint = raycast(playerPos, Vec(0, -1, 0), 1000)
				
				local newTransform = nil
				
				SetPlayerVehicle(0)
				
				if hit then
					newTransform = Transform(VecAdd(hitPoint, Vec(0, 1, 0)), playerTransform.rot)
				else
					RespawnPlayer() -- Pretty unlikely edge case to not hit, but in the event use this instead.
				end
				
				SetPlayerTransform(newTransform)
			end,
			onEffectTick = function(vars) end,
			onEffectEnd = function(vars) end,
		},
		
		deleteVision = {
			name = "Hope That Wasn't Important",
			effectDuration = 0,
			effectLifetime = 0,
			effectSFX = {},
			effectVariables = {},
			onEffectStart = function(vars) 
				local cameraTransform = GetCameraTransform()
				local rayDirection = TransformToParentVec(cameraTransform, {0, 0, -1})
				
				local hit, hitPoint, distance, normal, shape = raycast(cameraTransform.pos, rayDirection, 50)
				
				if not hit then
					return
				end
				
				local shapeBody = GetShapeBody(shape)
				
				if not IsBodyDynamic(shapeBody) then
					return
				end
				
				local currentVehicleHandle = GetPlayerVehicle()
				
				if currentVehicleHandle == GetBodyVehicle(shapeBody) then
					SetPlayerVehicle(0)
				end
				
				Delete(shapeBody)
				
			end,
			onEffectTick = function(vars) end,
			onEffectEnd = function(vars) end,
		},
		
		portraitMode = {
			name = "Portrait Mode",
			effectDuration = 20,
			effectLifetime = 0,
			effectSFX = {},
			effectVariables = {currentBorderPos = 0},
			onEffectStart = function(vars) end,
			onEffectTick = function(vars)
				if vars.effectVariables.currentBorderPos < UiWidth() / 3 then
					vars.effectVariables.currentBorderPos = vars.effectVariables.currentBorderPos + GetChaosTimeStep() * 100
				elseif vars.effectVariables.currentBorderPos > UiWidth() / 3 then
					vars.effectVariables.currentBorderPos = UiWidth() / 3
				end
				
				table.insert(drawCallQueue, function()
				UiPush()
					UiColor(0, 0, 0, 1)
					
					UiAlign("left middle")
					UiTranslate(-10, UiMiddle())
					UiRect(vars.effectVariables.currentBorderPos, UiHeight() + 10)
				UiPop()
				
				UiPush()
					UiColor(0, 0, 0, 1)
				
					UiAlign("right middle")
					UiTranslate(UiWidth() + 10, UiMiddle())
					UiRect(vars.effectVariables.currentBorderPos, UiHeight() + 10)
				UiPop()
				end)
			end,
			onEffectEnd = function(vars) end,
		},
		
		explodingStare = {
			name = "Explosion Stare",
			effectDuration = 0,
			effectLifetime = 0,
			effectSFX = {},
			effectVariables = {currentBorderPos = 0},
			onEffectStart = function(vars) 
				local cameraTransform = GetCameraTransform()
				local rayDirection = TransformToParentVec(cameraTransform, {0, 0, -1})
				
				local hit, hitPoint = raycast(cameraTransform.pos, rayDirection, 50)
				
				if hit then
					Explosion(hitPoint, 1)
				end
				
				end,
			onEffectTick = function(vars) end,
			onEffectEnd = function(vars) end,
		},

		featherFalling = {
			name = "Feather Falling",
			effectDuration = 12,
			effectLifetime = 0,
			effectSFX = {},
			effectVariables = {},
			onEffectStart = function(vars) end,
			onEffectTick = function(vars)
				local maxFallSpeed = -1

				local vel = GetPlayerVelocity()
				if(vel[2] < maxFallSpeed) then
					SetPlayerVelocity(Vec(vel[1], maxFallSpeed, vel[3]))
				end
			end,
			onEffectEnd = function(vars) end,
		},

		explodeRandomExplosive = {
			name = "Explode Random Explosive",
			effectDuration = 0,
			effectLifetime = 0,
			effectSFX = {},
			effectVariables = {},
			onEffectStart = function(vars)
				local nearbyShapes = QueryAabbShapes(Vec(-100, -100, -100), Vec(100, 100, 100))

				local explosives = {}
				for i=1, #nearbyShapes do
					if HasTag(nearbyShapes[i], "explosive") then
						explosives[#explosives + 1] = nearbyShapes[i]
					end
				end

				if(#explosives == 0) then
					return
				end
				
				local randomExplosive = explosives[math.random(1, #explosives)]

				Explosion(GetShapeWorldTransform(randomExplosive).pos,2)
				end,
			onEffectTick = function(vars) end,
			onEffectEnd = function(vars) end,
		},

		teleportAFewMeters = {
			name = "Teleport A Few Meters",
			effectDuration = 0,
			effectLifetime = 0,
			effectSFX = {},
			effectVariables = {currentBorderPos = 0},
			onEffectStart = function(vars) 
				local playerTransform = GetPlayerTransform()
				
				local direction = rndVec(1)
				
				local distance = math.random(10, 20)
				
				direction[2] = math.abs(direction[2])
				
				local newPos = VecAdd(playerTransform.pos, VecScale(direction, distance))
				
				local currentVehicle = GetPlayerVehicle()
				
				if currentVehicle ~= 0 then
					local vehicleBody = GetVehicleBody(currentVehicle)
					local vehicleTransform = GetBodyTransform(vehicleBody)
					
					SetBodyTransform(vehicleBody, Transform(newPos, vehicleTransform.rot))
				else
					SetPlayerTransform(Transform(newPos, playerTransform.rot))
				end
			end,
			onEffectTick = function(vars) end,
			onEffectEnd = function(vars) end,
		},

		rewind = {
			name = "Let's Try That Again",
			effectDuration = 10,
			effectLifetime = 0,
			effectSFX = {},
			effectVariables = {transform = Transform(Vec(0,0,0), QuatEuler(0,0,0)), currentVehicle = 0, velocity = Vec(0,0,0)},
			onEffectStart = function(vars) 
				vars.effectVariables.transform = GetPlayerTransform()

				vars.effectVariables.currentVehicle = GetPlayerVehicle()

				if vars.effectVariables.currentVehicle ~= 0 then
					vars.effectVariables.velocity = GetBodyVelocity(GetVehicleBody(vars.effectVariables.currentVehicle))
				else
					vars.effectVariables.velocity = GetPlayerVelocity()
				end
			end,
			onEffectTick = function(vars) end,
			onEffectEnd = function(vars)
				SetPlayerVehicle(vars.effectVariables.currentVehicle)

				if vars.effectVariables.currentVehicle ~= 0 then
					SetBodyTransform(GetVehicleBody(vars.effectVariables.currentVehicle), vars.effectVariables.transform)
					SetBodyVelocity(GetVehicleBody(vars.effectVariables.currentVehicle), vars.effectVariables.velocity)
				else
					SetPlayerTransform(vars.effectVariables.transform)
					SetPlayerVelocity(vars.effectVariables.velocity)
				end
			end,
		},

		setPlayerIntoRandomVehicle = {
			name = "Enter Nearby Vehicle",
			effectDuration = 0,
			effectLifetime = 0,
			effectSFX = {},
			effectVariables = {},
			onEffectStart = function(vars) 
				local nearbyShapes = QueryAabbShapes(Vec(-100, -100, -100), Vec(100, 100, 100))

				local vehicles = {}
				for i=1, #nearbyShapes do
					if GetBodyVehicle(GetShapeBody(nearbyShapes[i])) ~= 0 then
						vehicles[#vehicles+1] = GetBodyVehicle(GetShapeBody(nearbyShapes[i]))
					end
				end

				if(#vehicles == 0) then
					return
				end

				local closestVehicle = 0
				local closestDistance = 10000

				local playerPos = GetPlayerTransform().pos
				for i = 1, #vehicles do
					local distance = VecLength(VecSub(GetVehicleTransform(vehicles[i]).pos, playerPos))

					if distance < closestDistance then
						closestDistance = distance
						closestVehicle = vehicles[i]
					end
				end

				SetPlayerVehicle(closestVehicle)
			end,
			onEffectTick = function(vars) end,
			onEffectEnd = function(vars) end,
		},
		
		ejectFromVehicle = {
			name = "Eject From Vehicle",
			effectDuration = 0,
			effectLifetime = 0,
			effectSFX = {},
			effectVariables = {},
			onEffectStart = function(vars) 
				SetPlayerVehicle(0)
			end,
			onEffectTick = function(vars) end,
			onEffectEnd = function(vars) end,
		}, 
		
		cantUseVehicles = {
			name = "Take A Walk",
			effectDuration = 10,
			effectLifetime = 0,
			effectSFX = {},
			effectVariables = {},
			onEffectStart = function(vars) end,
			onEffectTick = function(vars) 
				if GetPlayerVehicle() ~= 0 then
					SetPlayerVehicle(0)
				end
			end,
			onEffectEnd = function(vars) end,
		},
		
		nothing = {
			name = "Nothing",
			effectDuration = 0,
			effectLifetime = 0,
			effectSFX = {},
			effectVariables = {},
			onEffectStart = function(vars) end,
			onEffectTick = function(vars) end,
			onEffectEnd = function(vars) end,
		},
		
		fakeDeath = {
			name = "Fake Death",
			effectDuration = 10,
			effectLifetime = 0,
			effectSFX = {},
			effectVariables = { deathTimer = 5, nameBackup = "" },
			onEffectStart = function(vars)
				if GetPlayerVehicle() ~= 0 then
					SetPlayerVehicle(0)
				end
				
				vars.effectVariables.nameBackup = vars.name -- In case I decide on a new name
				vars.name = chaosEffects.effects["instantDeath"].name
			end,
			onEffectTick = function(vars) 
				if vars.effectLifetime >= vars.effectVariables.deathTimer then
					vars.name = vars.effectVariables.nameBackup
					vars.effectDuration = 0
					vars.effectLifetime = 0
				else
					local playerCamera = GetPlayerCameraTransform()
					local playerCameraPos = playerCamera.pos
				
					SetCameraTransform(Transform(VecAdd(playerCameraPos, Vec(0, -1, 0)), QuatEuler(-5, 0, 45)))
					table.insert(drawCallQueue, function()
					UiPush()
						local currFade = 100 / 5 * vars.effectLifetime / 100
						
						UiColor(0, 0, 0, currFade)
						UiAlign("center middle")
						UiTranslate(UiCenter(), UiMiddle())
						UiRect(UiWidth() + 10, UiHeight() + 10)
					
					UiPop()
					end)
				end
			end,
			onEffectEnd = function(vars) end,
		},

		fakeTeleport = {
			name = "Fake Teleport",
			effectDuration = 3,
			effectLifetime = 0,
			effectSFX = {},
			effectVariables = { revealTimer = 3, nameBackup = "", transform = 0 },
			onEffectStart = function(vars)
				SetPlayerVehicle(0)

				vars.effectVariables.transform = GetPlayerTransform()
				
				RespawnPlayer()
				
				vars.effectVariables.nameBackup = vars.name
				vars.name = chaosEffects.effects["teleportToSpawn"].name
			end,
			onEffectTick = function(vars) 
				if vars.effectLifetime >= vars.effectVariables.revealTimer then
					vars.name = vars.effectVariables.nameBackup
					vars.effectDuration = 0
					vars.effectLifetime = 0

					SetPlayerVehicle(0)
					SetPlayerTransform(vars.effectVariables.transform)
				end
			end,
			onEffectEnd = function(vars) end,
		},

		speedLimit = {
			name = "Speed Limit",
			effectDuration = 10,
			effectLifetime = 0,
			effectSFX = {},
			effectVariables = {},
			onEffectStart = function(vars) end,
			onEffectTick = function(vars) 
				local limit = 5

				if(GetPlayerVehicle ~= 0) then

					local vehicleBody = GetVehicleBody(GetPlayerVehicle())
					local speed = VecLength(GetBodyVelocity(vehicleBody))
					if speed > limit then
						SetBodyVelocity(vehicleBody, VecScale(GetBodyVelocity(vehicleBody), limit/speed))
					end
					
				end
			end,
			onEffectEnd = function(vars) end,
		},

		flipVehicle = {
			name = "Invert Vehicle",
			effectDuration = 0,
			effectLifetime = 0,
			effectSFX = {},
			effectVariables = {},
			onEffectStart = function(vars) 
				if GetPlayerVehicle() ~= 0 then
					local vehicleBody = GetVehicleBody(GetPlayerVehicle())

					SetBodyTransform(vehicleBody, Transform(VecAdd(GetBodyTransform(vehicleBody).pos, Vec(0,3,0)), QuatRotateQuat(GetBodyTransform().rot, QuatAxisAngle(Vec(1,0,0), 180))))
				end
			end,
			onEffectTick = function(vars) end,
			onEffectEnd = function(vars) end,
		},
		
		knocking = {
			name = "Who's there?",
			effectDuration = 15,
			effectLifetime = 0,
			effectSFX = {{isLoop = false, soundPath = "MOD/sfx/knock.ogg"}},
			effectVariables = {},
			onEffectStart = function(vars) 
				PlaySound(vars.effectSFX[1])
			end,
			onEffectTick = function(vars) end,
			onEffectEnd = function(vars) end,
		},
		
		diggydiggyhole = {
			name = "Diggy Diggy Hole",
			effectDuration = 0,
			effectLifetime = 0,
			effectSFX = {},
			effectVariables = {},
			onEffectStart = function(vars) 
				MakeHole(GetPlayerTransform().pos, 5, 5, 5)
			end,
			onEffectTick = function(vars) end,
			onEffectEnd = function(vars) end,
		},

		disableTools = {
			name = "Hold On To That Tool",
			effectDuration = 10,
			effectLifetime = 0,
			effectSFX = {},
			effectVariables = { tools = {"sledge", "spraycan", "extinguisher", "blowtorch", "shotgun", "plank", "pipebomb", "gun", "bomb", "rocket"} },
			onEffectStart = function(vars)
				for i = 1, #vars.effectVariables.tools do
					SetBool("game.tool."..vars.effectVariables.tools[i]..".enabled", false)
				end
			end,
			onEffectTick = function(vars) end,
			onEffectEnd = function(vars) 
				for i = 1, #vars.effectVariables.tools do
					SetBool("game.tool."..vars.effectVariables.tools[i]..".enabled", true)
				end
			end,
		},

		cinematicMode = {
			name = "Cinematic Mode",
			effectDuration = 10,
			effectLifetime = 0,
			effectSFX = {},
			effectVariables = {},
			onEffectStart = function(vars) end,
			onEffectTick = function(vars)				
				table.insert(drawCallQueue, function()
				UiPush()
					UiColor(0, 0, 0, 1)

					local middleSize = UiHeight()/2.5
					
					UiRect(UiWidth(),UiHeight()/2-middleSize)

					UiTranslate(0, UiHeight()/2+middleSize)

					UiRect(UiWidth(),UiHeight()/2-middleSize)
				UiPop()
				end)
			end,
			onEffectEnd = function(vars) end,
		},

		dvdScreensaver = {
			name = "DVD Screensaver",
			effectDuration = 20,
			effectLifetime = 0,
			effectSFX = {},
			effectVariables = { x = 0, y = 0, px = true, py = true},
			onEffectStart = function(vars) 
				vars.effectVariables.x = UiCenter()
				vars.effectVariables.y = UiMiddle()
			end,
			onEffectTick = function(vars)

				local speed = 5
				local middleSize = UiHeight()/5
				

				if vars.effectVariables.px then
					vars.effectVariables.x = vars.effectVariables.x + speed
				else
					vars.effectVariables.x = vars.effectVariables.x - speed
				end

				if vars.effectVariables.x + middleSize >= UiWidth() or vars.effectVariables.x - middleSize <= 0 then
					vars.effectVariables.px = not vars.effectVariables.px
				end

				if vars.effectVariables.py then
					vars.effectVariables.y = vars.effectVariables.y + speed
				else
					vars.effectVariables.y = vars.effectVariables.y - speed
				end

				if vars.effectVariables.y + middleSize >= UiHeight() or vars.effectVariables.y - middleSize <= 0 then
					vars.effectVariables.py = not vars.effectVariables.py
				end

				table.insert(drawCallQueue, function()
				UiPush()
					UiTranslate(vars.effectVariables.x - UiCenter(), vars.effectVariables.y - UiMiddle())
					UiColor(0, 0, 0, 1)

					--Top part
					UiPush()
						UiTranslate(-UiWidth()/2, -UiHeight()/2)
						UiRect(UiWidth()*2,UiHeight()-middleSize) 
					UiPop()

					--Bottom part
					UiPush()
						UiTranslate(-UiWidth()/2, UiHeight()/2+middleSize)

						UiRect(UiWidth()*2,UiHeight()-middleSize) 
					UiPop()

					--Left part
					UiPush()
						UiTranslate(-UiWidth()/2, 0)
						UiRect(UiWidth()-middleSize,UiHeight()) 
					UiPop()

					--Right part
					UiPush()
						UiTranslate(UiWidth()/2+middleSize, 0)

						UiRect(UiWidth()-middleSize,UiHeight()) 
					UiPop()
				UiPop()
				end)
			end,
			onEffectEnd = function(vars) end,
		},
		
		--[[quakefov = { -- Disables tool functionality, unsure how to fix yet.
			name = "Quake FOV",
			effectDuration = 20,
			effectLifetime = 0,
			effectSFX = {},
			effectVariables = {},
			onEffectStart = function(vars) end,
			onEffectTick = function(vars) 
				local playerCamera = GetPlayerCameraTransform()
				local playerCameraPos = playerCamera.pos
		
				SetCameraTransform(Transform(playerCamera.pos, playerCamera.rot), 150)
				SetBool("game.player.canusetool", true)
			end,
			onEffectEnd = function(vars) end,
		},]]--
		
		networkLag = {
			name = "Lag",
			effectDuration = 15,
			effectLifetime = 0,
			effectSFX = {},
			effectVariables = {lastPlayerPos = nil, lastPlayerRot = nil, lastPlayerVehicle = 0},
			onEffectStart = function(vars)
				local playerTransform = GetPlayerTransform()
			
				vars.effectVariables.lastPlayerPos = playerTransform.pos
				vars.effectVariables.lastPlayerRot = playerTransform.rot
				
				vars.effectVariables.lastPlayerVehicle = GetPlayerVehicle()
			end,
			onEffectTick = function(vars)
				if vars.effectLifetime % 2 <= 0.2 and vars.effectLifetime > 1 then
					SetPlayerTransform(Transform(vars.effectVariables.lastPlayerPos, vars.effectVariables.lastPlayerRot))
					SetPlayerVehicle(vars.effectVariables.lastPlayerVehicle)
				else
					if vars.effectLifetime % 2 <= 1 then
						local playerTransform = GetPlayerTransform()
			
						vars.effectVariables.lastPlayerPos = playerTransform.pos
						vars.effectVariables.lastPlayerRot = playerTransform.rot
						
						vars.effectVariables.lastPlayerVehicle = GetPlayerVehicle()
					end
				end
			end,
			onEffectEnd = function(vars) end,
		},
		
		vehicleKickflip = {
			name = "Kickflip",
			effectDuration = 0,
			effectLifetime = 0,
			effectSFX = {},
			effectVariables = {},
			onEffectStart = function(vars) 
				local playerVehicle = GetPlayerVehicle()
				
				if playerVehicle ~= 0 then
					local vehicleBody = GetVehicleBody(playerVehicle)
					
					local vehicleTransform = GetVehicleTransform(playerVehicle)
					
					local kickflipPosition = TransformToParentPoint(vehicleTransform, Vec(1, 0.5, 0))
					local jumpPosition = TransformToParentPoint(vehicleTransform, Vec(0, 0, 0))
					
					local bodyMass = GetBodyMass(vehicleBody)
					
					local velocityMultiplier = 1
					
					if bodyMass > 15000 then
						velocityMultiplier = 1.6
					elseif bodyMass > 10000 then
						velocityMultiplier = 1.3
					end

					local kickflipVel = Vec(0, velocityMultiplier * (2 * bodyMass), 0)
					local jumpVel = Vec(0, velocityMultiplier * (5.7 * bodyMass), 0)
					
					ApplyBodyImpulse(vehicleBody, jumpPosition, jumpVel)
					ApplyBodyImpulse(vehicleBody, kickflipPosition, kickflipVel)
				end
			end,
			onEffectTick = function(vars) end,
			onEffectEnd = function(vars) end,
		},
		
		freeShots = {
			name = "Free Shots",
			effectDuration = 20,
			effectLifetime = 0,
			effectSFX = {},
			effectVariables = {lastFrameTool = "", lastFrameAmmo = ""},
			onEffectStart = function(vars) 
				vars.effectVariables.lastFrameTool = GetString("game.player.tool")
				vars.effectVariables.lastFrameAmmo =  GetFloat("game.tool." ..  vars.effectVariables.lastFrameTool .. ".ammo")
			end,
			onEffectTick = function(vars) 
				local currentTool = GetString("game.player.tool")
				local currentAmmo = GetFloat("game.tool." ..  currentTool .. ".ammo")
				if currentTool == vars.effectVariables.lastFrameTool then
					if currentAmmo < vars.effectVariables.lastFrameAmmo then
						SetFloat("game.tool." ..  currentTool .. ".ammo", vars.effectVariables.lastFrameAmmo)
					end
				else
					vars.effectVariables.lastFrameTool = GetString("game.player.tool")
					vars.effectVariables.lastFrameAmmo =  GetFloat("game.tool." ..  vars.effectVariables.lastFrameTool .. ".ammo")
				end
			end,
			onEffectEnd = function(vars) end,
		},

		birdPerspective = {
			name = "GTA 2",
			effectDuration = 20,
			effectLifetime = 0,
			effectSFX = {},
			effectVariables = { hitPoint = Vec(0,0,0)},
			onEffectStart = function(vars) end,
			onEffectTick = function(vars)
				local playerCameraPos = nil
				
				local playerTransform = GetPlayerTransform()
				
				local playerPos = playerTransform.pos
				
				local rayOrigin = VecAdd(playerPos, Vec(0, 1, 0))
				local rayDir = TransformToParentVec(playerTransform, {0, 1, 0})
				
				local hit, hitPoint = raycast(rayOrigin, rayDir, 100)
				
				if hit then
					playerCameraPos = hitPoint
					vars.effectVariables.hitPoint = hitPoint
				else
					playerCameraPos = VecAdd(GetPlayerCameraTransform().pos, Vec(0, 30, 0))
				end
					
				if GetPlayerVehicle() == 0 then
					SpawnParticle("smoke", playerPos, Vec(0, 0, 0),  0.5, 0.5)
				end
				
				SetCameraTransform(Transform(playerCameraPos, QuatEuler(-90, -90, 0)))
			end,
			onEffectEnd = function(vars) end,
		},
	},
}

chaosKeysInit()