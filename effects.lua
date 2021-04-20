#include "utils.lua"

function chaosSFXInit()
	local loadedSFX = {loops = {}, regular = {}}
	
	for key, value in ipairs(chaosEffects.effectKeys) do
		local currentEffect = chaosEffects.effects[value]
		
		if #currentEffect.effectSFX > 0 then
			for i=1, #currentEffect.effectSFX do
				local soundData =  currentEffect.effectSFX[i]
				local soundPath = soundData["soundPath"]
				local isLoop = soundData["isLoop"]
				local handle = nil
				
				local handle = 0
				
				if isLoop then
					if loadedSFX.loops[soundPath] ~= nil then
						handle = loadedSFX.loops[soundPath]
					else
						handle = LoadLoop(soundPath)
						loadedSFX.loops[soundPath] = handle
					end
				else
					if loadedSFX.regular[soundPath] ~= nil then
						handle = loadedSFX.regular[soundPath]
					else
						handle = LoadSound(soundPath)
						loadedSFX.regular[soundPath] = handle
					end
				end
				
				currentEffect.effectSFX[i] = handle
			end
		end
	end
end

function chaosSpritesInit()
	local loadedSprites = {}

	for key, value in ipairs(chaosEffects.effectKeys) do
		local currentEffect = chaosEffects.effects[value]
		
		if #currentEffect.effectSprites > 0 then
			for i=1, #currentEffect.effectSprites do
				local currentSpriteData = currentEffect.effectSprites[i]
				
				local handle = 0
				
				if loadedSprites[currentSpriteData] ~= nil then
					handle = loadedSprites[currentSpriteData]
				else
					handle = LoadSprite(currentSpriteData)
					loadedSprites[currentSpriteData] = handle
				end
				
				currentEffect.effectSprites[i] = handle
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

function loadChaosEffectData()
	chaosSFXInit()
	chaosSpritesInit()
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
	
	debugPrintOrder = {"name", "effectDuration", "effectLifetime", "effectSFX", "effectSprites", "effectVariables", "onEffectStart", "onEffectTick", "onEffectEnd"},
	
	effectTemplate = {
		name = "Name", -- This is what shows up on the UI.
		effectDuration = 0, -- If more than 0 this is a timed effect and will last.
		effectLifetime = 0, -- Keep this at 0, this is how long the effect has been running for.
		hideTimer = false, -- For effects that trick the player.
		effectSFX = {}, -- Locations of SFX. Will be replaced by their handle during setup.
		effectSprites = {}, -- Locations of sprites. Will be replaced by their handle during setup.
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
		hideTimer = false,
		effectSFX = {},
		effectSprites = {},
		effectVariables = {},
		onEffectStart = function(vars) end,
		onEffectTick = function(vars) end,
		onEffectEnd = function(vars) end,
	},
	
	effectKeys = {}, -- Leave empty, this is populated automatically.
	
	effects = {
		instantDeath = {
			name = "Instant Death",
			effectDuration = 5,
			effectLifetime = 0,
			hideTimer = true,
			effectSFX = {},
			effectSprites = {},
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
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
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
			effectDuration = 25,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
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
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
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
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
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
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
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
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
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
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
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
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
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
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {},
			onEffectStart = function(vars) end,
			onEffectTick = function(vars)
				table.insert(drawCallQueue, function() UiBlur(1) end)
			end,
			onEffectEnd = function(vars) end,
		},
		
		slomo25 = {
			name = "0.25x Gamespeed",
			effectDuration = 12,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
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
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
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
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {},
			onEffectStart = function(vars) end,
			onEffectTick = function(vars)
				ParticleReset()
				ParticleType("smoke")
				ParticleColor(0.7, 0.6, 0.5)
				ParticleRadius(1)
				for i = 1, 20 do
					local direction = rndVec(10)
					SpawnParticle(GetPlayerPos(), direction, 2)
				end
			end,
			onEffectEnd = function(vars) end,
		},
		
		takeABreak = {
			name = "Take A Break",
			effectDuration = 0,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
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
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
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
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
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
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
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
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
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
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
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
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
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
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
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
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
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
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
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
			name = "Explosive Stare",
			effectDuration = 0,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
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
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
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
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
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
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
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
			name = "Lets Try That Again",
			effectDuration = 10,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
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
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
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
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
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
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
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
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {},
			onEffectStart = function(vars) end,
			onEffectTick = function(vars) end,
			onEffectEnd = function(vars) end,
		},
		
		fakeDeath = {
			name = "Fake Death",
			effectDuration = 10,
			effectLifetime = 0,
			hideTimer = true,
			effectSFX = {},
			effectSprites = {},
			effectVariables = { deathTimer = 5, nameBackup = "", playerTransform = nil},
			onEffectStart = function(vars)
				if GetPlayerVehicle() ~= 0 then
					SetPlayerVehicle(0)
				end
				
				vars.effectVariables.playerTransform = GetPlayerTransform()
				vars.effectVariables.nameBackup = vars.name -- In case I decide on a new name
				vars.name = chaosEffects.effects["instantDeath"].name
			end,
			onEffectTick = function(vars) 
				if vars.effectLifetime >= vars.effectVariables.deathTimer then
					vars.name = vars.effectVariables.nameBackup
					vars.effectDuration = 0
					vars.effectLifetime = 0
				else
					SetPlayerHealth(1)
					
					local playerCamera = GetPlayerCameraTransform()
					local playerCameraPos = playerCamera.pos
				
					SetCameraTransform(Transform(VecAdd(playerCameraPos, Vec(0, -1, 0)), QuatEuler(-5, 0, 45)))
					
					SetPlayerTransform(vars.effectVariables.playerTransform)
					
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
			hideTimer = true,
			effectSFX = {},
			effectSprites = {},
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
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
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
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
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
			hideTimer = false,
			effectSFX = {{isLoop = false, soundPath = "MOD/sfx/knock.ogg"}},
			effectSprites = {},
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
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
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
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
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
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
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
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = { x = 0, y = 0, px = true, py = true},
			onEffectStart = function(vars)
				vars.effectVariables.x = UiCenter()
				vars.effectVariables.y = UiMiddle()
			end,
			onEffectTick = function(vars)
				local speed = 5
				local middleSize = UiHeight() / 5
				
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
		
		quakefov = { -- Disables tool functionality, unsure how to fix yet.
			name = "Quake FOV",
			effectDuration = 20,
			effectLifetime = 0,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {},
			onEffectStart = function(vars) end,
			onEffectTick = function(vars) 
				SetCameraFov(140)
			end,
			onEffectEnd = function(vars) end,
		},
		
		turtlemode = {
			name = "Turtle Mode",
			effectDuration = 20,
			effectLifetime = 0,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {},
			onEffectStart = function(vars) end,
			onEffectTick = function(vars) 
				local playerCamera = GetPlayerCameraTransform()
				local playerCameraPos = playerCamera.pos
				
				local playerCameraRot = QuatRotateQuat(playerCamera.rot, QuatEuler(0, 0, -180))
		
				SetCameraTransform(Transform(playerCamera.pos, playerCameraRot))
			end,
			onEffectEnd = function(vars) end,
		},
		
		networkLag = {
			name = "Lag",
			effectDuration = 15,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {lastPlayerPos = nil, lastPlayerRot = nil, lastPlayerVel = nil, lastPlayerVehicle = 0, lastPlayerVehiclePos = nil, lastPlayerVehicleRot = nil, lastPlayerVehicleVel = nil,},
			onEffectStart = function(vars)
				local playerTransform = GetPlayerTransform()
			
				vars.effectVariables.lastPlayerPos = playerTransform.pos
				vars.effectVariables.lastPlayerRot = playerTransform.rot
				
				vars.effectVariables.lastPlayerVehicle = GetPlayerVehicle()
				
				if vars.effectVariables.lastPlayerVehicle ~= 0 then
					local vehicleBody = GetVehicleBody(vars.effectVariables.lastPlayerVehicle)
					local vehicleTransform = GetBodyTransform(vehicleBody)
				
					vars.effectVariables.lastPlayerVehiclePos = vehicleTransform.pos
					vars.effectVariables.lastPlayerVehicleRot = vehicleTransform.rot
					vars.effectVariables.lastPlayerVehicleVel = GetBodyVelocity(vehicleBody)
				end
			end,
			onEffectTick = function(vars)
				if vars.effectLifetime % 2 <= 0.5 and vars.effectLifetime > 1 then
					if vars.effectVariables.lastPlayerVehicle ~= 0 then
						local vehicleBody = GetVehicleBody(vars.effectVariables.lastPlayerVehicle)
						local vehicleTransform = GetBodyTransform(vehicleBody)
						
						SetBodyTransform(vehicleBody, Transform(vars.effectVariables.lastPlayerVehiclePos, vars.effectVariables.lastPlayerVehicleRot))
						SetBodyVelocity(vehicleBody, vars.effectVariables.lastPlayerVehicleVel)
					else
						SetPlayerTransform(Transform(vars.effectVariables.lastPlayerPos, vars.effectVariables.lastPlayerRot))
						SetPlayerVehicle(vars.effectVariables.lastPlayerVehicle)
						SetPlayerVelocity(vars.effectVariables.lastPlayerVel)
					end
				else
					if vars.effectLifetime % 3 <= 2.5 then
						local playerTransform = GetPlayerTransform()
			
						vars.effectVariables.lastPlayerPos = playerTransform.pos
						vars.effectVariables.lastPlayerRot = playerTransform.rot
						
						if GetPlayerVehicle() == vars.effectVariables.lastPlayerVehicle then
							local vehicleBody = GetVehicleBody(vars.effectVariables.lastPlayerVehicle)
							local vehicleTransform = GetBodyTransform(vehicleBody)
							
							vars.effectVariables.lastPlayerVehiclePos = vehicleTransform.pos
							vars.effectVariables.lastPlayerVehicleRot = vehicleTransform.rot
							vars.effectVariables.lastPlayerVehicleVel = GetBodyVelocity(vehicleBody)
						else
							vars.effectVariables.lastPlayerVehicle = GetPlayerVehicle()
						end
					end
				end
			end,
			onEffectEnd = function(vars) end,
		},
		
		vehicleKickflip = {
			name = "Kickflip",
			effectDuration = 0,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
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
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
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
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = { playerVehicleLastFrame = 0 },
			onEffectStart = function(vars) end,
			onEffectTick = function(vars)
				local playerCameraPos = nil
				
				local playerTransform = GetPlayerTransform()
				
				local playerPos = playerTransform.pos
				
				-- Camera movement
				
				local cameraRayOrigin = VecAdd(playerPos, Vec(0, 1, 0))
				local cameraRayDir = TransformToParentVec(playerTransform, {0, 1, 0})
				
				local cameraHit, cameraHitPoint = raycast(cameraRayOrigin, cameraRayDir, 30)
				
				if cameraHit then
					playerCameraPos = VecAdd(cameraHitPoint, Vec(0, -2, 0))
				else
					playerCameraPos = VecAdd(GetPlayerCameraTransform().pos, Vec(0, 30, 0))
				end
					
				if GetPlayerVehicle() == 0 then
					SpawnParticle("smoke", playerPos, Vec(0, 0, 0),  0.5, 0.5)
				end
				
				local distanceBetweenCamera = VecDist(playerPos, playerCameraPos)
				
				local fov = 120 / 30 * (120 - distanceBetweenCamera)
				
				if not cameraHit or distanceBetweenCamera < 6 then
					fov = 90
				end
				
				SetCameraTransform(Transform(playerCameraPos, QuatEuler(-90, -90, 0)), fov)
				-- End camera movement
				
				--####################
				
				-- Player movement
				
				local walkingSpeed = 7
				
				local currentPlayerVelocity = GetPlayerVelocity()
				
				local forwardMovement = 0
				
				local rightMovement = 0
				
				local upwardsMovement = 0
				
				if InputDown("w") then
					forwardMovement = forwardMovement + walkingSpeed
				end
				
				if InputDown("s") then
					forwardMovement = forwardMovement - walkingSpeed
				end
				
				if InputDown("a") then
					rightMovement = rightMovement - walkingSpeed
				end
				
				if InputDown("d") then
					rightMovement = rightMovement + walkingSpeed
				end
				
				SetPlayerVelocity(Vec(forwardMovement,  currentPlayerVelocity[2], rightMovement))
				
				-- End Player movement
				
				--####################
				
				-- Enter Vehicle
				
				if GetPlayerVehicle() == 0 and vars.effectVariables.playerVehicleLastFrame ~= 0 then
					vars.effectVariables.playerVehicleLastFrame = 0
					return
				end
				
				local range = 2
				
				local minPos = VecAdd(playerPos, Vec(-range, -range, -range))
				local maxPos = VecAdd(playerPos, Vec(range, range, range))
				local bodyList = QueryAabbBodies(minPos, maxPos)
				
				local vehicleList = {}
				
				for i=1, #bodyList do
					local currBody = bodyList[i]
					
					local vehicle = GetBodyVehicle(currBody) 
					
					if vehicle ~= 0 then
						table.insert(vehicleList, vehicle)
					end
				end
				
				function getDistToVehicle(vehicle)
					local vehicleTransform = GetVehicleTransform(vehicle)
					local vehiclePos = vehicleTransform.pos
					
					local distance = VecDist(playerPos, vehiclePos)
					
					return distance
				end
				
				if #vehicleList <= 0 then
					return
				end
				
				local closestVehicleDist = getDistToVehicle(vehicleList[1])
				local closetVehicleIndex = vehicleList[1]
				
				if #vehicleList > 1 then
					for i=2, #vehicleList do
						local currentVehicle = vehicleList[i]
						local currDist = getDistToVehicle(currentVehicle)
						
						if currDist < closestVehicleDist then
							closestVehicleDist = currDist
							closetVehicleIndex = currentVehicle
						end
					end
				end
				
				if GetPlayerVehicle() == 0 then
					DrawBodyOutline(GetVehicleBody(closetVehicleIndex), 1, 1, 1, 0.75)
				end
				
				if InputPressed("e") then
					SetPlayerVehicle(closetVehicleIndex)
				end
				
				vars.effectVariables.playerVehicleLastFrame = GetPlayerVehicle()
				
				-- End Enter Vehicle
				
				-- TODO: Render enter vehicle on top of closest vehicle.
			end,
			onEffectEnd = function(vars) end,
		},
		
		objectFlyAway = {
			name = "Hope That Can Fly",
			effectDuration = 0,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {},
			onEffectStart = function(vars)
				local cameraTransform = GetCameraTransform()
				local rayDirection = TransformToParentVec(cameraTransform, Vec(0, 0, -1))

				local hit, hitPoint, distance, normal, shape = raycast(cameraTransform.pos, rayDirection, 50)

				if not hit then
					return
				end

				local shapeBody = GetShapeBody(shape)

				if not IsBodyDynamic(shapeBody) then
					return
				end

				local upVel = Vec(0, 35, 0)
				SetBodyVelocity(shapeBody, upVel)
			end,
			onEffectTick = function(vars) end,
			onEffectEnd = function(vars) end,
		},

		fakeDeleteVehicle = {
			name = "Fake Delete Vehicle",
			effectDuration = 5,
			effectLifetime = 0,
			hideTimer = true,
			effectSFX = {},
			effectSprites = {},
			effectVariables = { revealTimer = 5, nameBackup = "", transform = 0, vehicle = 0 },
			onEffectStart = function(vars)
				local vehicle = GetPlayerVehicle()
				
				if vehicle ~= 0 then
					local vehicleBody = GetVehicleBody(vehicle)
					local bodyTransform = GetBodyTransform(vehicleBody)
					
					vars.effectVariables.vehicle = vehicle
					vars.effectVariables.transform = TransformCopy(bodyTransform)
					
					bodyTransform.pos = VecAdd(bodyTransform.pos, Vec(0, 10000, 0))
					
					SetPlayerVehicle(0)
					
					SetBodyTransform(vehicleBody, bodyTransform) -- Just get the vehicle out of there
					SetBodyVelocity(vehicleBody, Vec(0, 0, 0))
				else
					return
				end
				
				vars.effectVariables.nameBackup = vars.name
				vars.name = chaosEffects.effects["removeCurrentVehicle"].name
			end,
			onEffectTick = function(vars) 
				if vars.effectLifetime >= vars.effectVariables.revealTimer or vars.effectVariables.vehicle == 0 then
					vars.name = vars.effectVariables.nameBackup
					vars.effectDuration = 0

					local vehicle = vars.effectVariables.vehicle
					
					if vehicle ~= 0 then
						local vehicleBody = GetVehicleBody(vehicle)
						
						SetBodyDynamic(vehicleBody, true)
					
						SetBodyTransform(vehicleBody, vars.effectVariables.transform)
						
						SetBodyVelocity(vehicleBody, Vec(0, 0, 0))
						
						SetPlayerVehicle(vehicle)
					end
				else
					if vars.effectVariables.vehicle ~= 0 then
						local vehicleBody = GetVehicleBody(vehicle)
						
						if IsBodyDynamic(vehicleBody) then
							SetBodyDynamic(vehicleBody, false)
						end
					end
				end
			end,
			onEffectEnd = function(vars) end,
		},
	
		lowgravity = {
			name = "Low Gravity",
			effectDuration = 15,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = { affectedBodies = {}},
			onEffectStart = function(vars) end,
			onEffectTick = function(vars)
				local playerPos = GetPlayerPos()
				local range = 50

				local tempVec = GetPlayerVelocity()
				tempVec[2] = 0.5
				SetPlayerVelocity(tempVec)
				
				local minPos = VecAdd(playerPos, Vec(-range, -range, -range))
				local maxPos = VecAdd(playerPos, Vec(range, range, range))
				local shapeList = QueryAabbShapes(minPos, maxPos)
				
				for key, value in ipairs(shapeList) do
					local shapeBody = GetShapeBody(value)
					
					if vars.effectVariables.affectedBodies[shapeBody] == nil then
						vars.effectVariables.affectedBodies[shapeBody] = "hit"
					end
				
					--[[ Always returns false, even on dynamic bodies?
					if not IsBodyDynamic(shapeBody) then
						return
					end]]--

					local shapeTransform = GetBodyTransform(shape)

					local bodyVelocity = GetBodyVelocity(shapeBody)
					
					bodyVelocity[2] = 0.5
					
					SetBodyVelocity(shapeBody, bodyVelocity)
				end
			end,
			onEffectEnd = function(vars) 
				for shapeBody, value in pairs(vars.effectVariables.affectedBodies) do
					local shapeTransform = GetBodyTransform(shapeBody)
					ApplyBodyImpulse(shapeBody, shapeTransform.pos, Vec(0, -1, 0))
				end
			end,
		},
		
		explosivePunch = {
			name = "Explosive Punch",
			effectDuration = 17.5,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {},
			onEffectStart = function(vars) end,
			onEffectTick = function(vars)
				local cameraTransform = GetCameraTransform()
				local rayDirection = TransformToParentVec(cameraTransform, {0, 0, -1})
 
				local hit, hitPoint, distance = raycast(cameraTransform.pos, rayDirection, 3)
				
				if hit == false then
					return
				end
 
				if InputDown("lmb") then
					Explosion(hitPoint, 0.5)
					SetPlayerHealth(1)
				end
 
			end,
			onEffectEnd = function(vars) end,
		},
		
		--[[suddenFlood = {
			name = "Flood",
			effectDuration = 10,--20,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {"MOD/sprites/square.png"},
			effectVariables = { waterHeight = -1 },
			onEffectStart = function(vars) 
				vars.effectVariables.waterHeight = math.random(12, 15)
			end,
			onEffectTick = function(vars)
				local playerPos = GetPlayerPos()
				local playerCamera = GetPlayerCameraTransform()
				local floatHeightDiff = 0.25
				
				local waterPos = VecCopy(playerPos)
				
				waterPos[2] = vars.effectVariables.waterHeight
				
				local rotation = QuatEuler(90, 0, 0)
				
				DrawSprite(vars.effectSprites[1], Transform(waterPos, rotation), 500, 500, 0, 0, 1, 0.25, true, true)
				
				-- Object Behaviour
				
				local range = 50
				
				local minPos = VecAdd(playerPos, Vec(-range, -math.abs(vars.effectVariables.waterHeight - range), -range))
				local maxPos = VecAdd(playerPos, Vec(range, math.abs(playerPos[2] - vars.effectVariables.waterHeight) - floatHeightDiff, range))
				
				--DebugPrint(VecToString(minPos) .. " || " .. VecToString(maxPos))
				
				local shapeList = QueryAabbShapes(minPos, maxPos)
				
				for key, value in ipairs(shapeList) do
					local shapeBody = GetShapeBody(value)
				
					--[ Always returns false, even on dynamic bodies?
					if not IsBodyDynamic(shapeBody) then
						return
					end]--

					local shapeTransform = GetBodyTransform(shape)

					local bodyVelocity = GetBodyVelocity(shapeBody)
					
					--local bodyMass = GetBodyMass(shapeBody)
					
					--DebugPrint(bodyMass)
					
					bodyVelocity[2] = 0.1 * math.abs(shapeTransform.pos[2] - (vars.effectVariables.waterHeight - floatHeightDiff))--5 / 20000 * bodyMass
					
					SetBodyVelocity(shapeBody, bodyVelocity)
				end
				
				-- End Object Behaviour
				
				--####################
				
				-- Player Behaviour
				
				if playerPos[2] < vars.effectVariables.waterHeight - floatHeightDiff then
					local playerVelocity = GetPlayerVelocity()
					
					if InputDown("ctrl") then
						playerVelocity[2] = -3
					elseif InputDown("space") then
						playerVelocity[2] = 3
					else
						playerVelocity[2] = 2
					end
					
					
					SetPlayerVelocity(playerVelocity)
				end
				
				if playerCamera.pos[2] < vars.effectVariables.waterHeight then
					table.insert(drawCallQueue, function() 
						UiPush()
							UiAlign("top left")
							UiColor(0.25, 0.25, 1, 0.5)
							UiRect(UiWidth() + 20, UiHeight() + 20)
							UiBlur(0.25)
						UiPop()
					end)
				end
				
				-- End Player Behaviour
			end,
			onEffectEnd = function(vars) end,
		},]]--
		
		dontStopDriving = {
			name = "Speed",
			effectDuration = 20,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = { fuseTimer = 10 },
			onEffectStart = function(vars) end,
			onEffectTick = function(vars)
				local vehicle = GetPlayerVehicle()
				
				if vehicle == 0 then
					return
				end
				
				local vehicleBody = GetVehicleBody(vehicle)
				local vehicleTransform = GetVehicleTransform(vehicle)
				
				local vel = TransformToLocalVec(vehicleTransform, GetBodyVelocity(vehicleBody))
				
				local speed = -vel[3]
				--Speed is in meter per second, convert to km/h
				speed = speed * 3.6
				
				speed = math.abs(math.floor(speed))
				
				table.insert(drawCallQueue, function()
					UiPush()
						UiFont("regular.ttf", 52)
						UiTextShadow(0, 0, 0, 0.5, 2.0)
						
						UiAlign("center middle")
						
						UiTranslate(UiCenter(), UiHeight() * 0.2)
						
						UiText("Keep above 30 km/u or the bomb explodes!")
						
						UiTranslate(0, 40)
						
						UiFont("regular.ttf", 26)
						
						local fuseStatus = " "
						
						if speed < 30 then
							fuseStatus = "TICKING"
							vars.effectVariables.fuseTimer = vars.effectVariables.fuseTimer - GetChaosTimeStep()
						elseif vars.effectVariables.fuseTimer < 10 then
							vars.effectVariables.fuseTimer = vars.effectVariables.fuseTimer + GetChaosTimeStep()
							fuseStatus = "RECOVERING"
						elseif vars.effectVariables.fuseTimer > 10 then
							 vars.effectVariables.fuseTimer = 10
						end
						
						if vars.effectVariables.fuseTimer <= 0 then
							Explosion(GetPlayerPos(), 4)
							vars.effectDuration = 0
						end
						
						UiText("Fuse: " .. math.floor(vars.effectVariables.fuseTimer) .. " " .. fuseStatus)
						
						UiTranslate(0, 25)
						
						UiText("Current speed: " .. speed .. " km\h")
					UiPop()
				end)
				
			end,
			onEffectEnd = function(vars) end,
		},
		
		teleportGun = {
			name = "Teleport Gun",
			effectDuration = 20,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {},
			onEffectStart = function(vars) end,
			onEffectTick = function(vars)
				if InputPressed("lmb") then
					local cameraTransform = GetCameraTransform()
					local rayDirection = TransformToParentVec(cameraTransform, Vec(0, 0, -1))
	 
					local hit, hitPoint, distance, normal = raycast(cameraTransform.pos, rayDirection, 100)
					
					if hit == false then
						return
					end
					
					local newPos = VecAdd(hitPoint, VecScale(normal, 1.5))
					
					local playerTransform = GetPlayerTransform()
					
					SetPlayerTransform(Transform(newPos, playerTransform.rot))
				end
			end,
			onEffectEnd = function(vars) end,
		},
		
		foggyDay = {
			name = "Foggy Day",
			effectDuration = 30,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {"MOD/sprites/square.png"},
			effectVariables = {},
			onEffectStart = function(vars) end,
			onEffectTick = function(vars)
				local cameraTransform = GetCameraTransform()
				local forwardDirection = TransformToParentVec(cameraTransform, Vec(0, 0, -1))
				
				local fogStep = 0.5
				local fogLayers = 100
				local fogStart = 60
				
				for i = 1, fogLayers do
					local spritePos = VecAdd(cameraTransform.pos, VecScale(forwardDirection, fogStart - i * fogStep))
					local spriteRot = QuatLookAt(spritePos, cameraTransform.pos)
					
					DrawSprite(vars.effectSprites[1], Transform(spritePos, spriteRot), 200, 200, 0.25, 0.25, 0.25, 0.5, true, true)
				end
			end,
			onEffectEnd = function(vars) end,
		},
		
		honkingVehicles = {
			name = "Honk Honk",
			effectDuration = 20,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {{isLoop = false, soundPath = "MOD/sfx/carhonks/honk01.ogg"}, 
						 {isLoop = false, soundPath = "MOD/sfx/carhonks/honk02.ogg"}, 
						 {isLoop = false, soundPath = "MOD/sfx/carhonks/honk03.ogg"}, 
						 {isLoop = false, soundPath = "MOD/sfx/carhonks/honk04.ogg"}, 
						 {isLoop = false, soundPath = "MOD/sfx/carhonks/honk05.ogg"}, },
			effectSprites = {},
			effectVariables = {vehicles = {}},
			onEffectStart = function(vars)
				local range = 500
				local minPos = Vec(-range, -range, -range)
				local maxPos = Vec(range, range, range)
				local nearbyShapes = QueryAabbShapes(minPos, maxPos)

				for i = 1, #nearbyShapes do
					local currentShape = nearbyShapes[i]
					local shapeBody = GetShapeBody(currentShape)
					
					if GetBodyVehicle(shapeBody) ~= 0 then
						local vehicleHandle = GetBodyVehicle(shapeBody)
						
						vars.effectVariables.vehicles[#vars.effectVariables.vehicles + 1] = {handle = vehicleHandle, honkTimer = 0}
					end
				end
			end,
			onEffectTick = function(vars)
				for index, vehicleData in ipairs(vars.effectVariables.vehicles) do
					if math.random(1, 10) > 6 and vehicleData.honkTimer <= 0 then
						vehicleData.honkTimer = math.random(3, 5)
						
						local vehicleTransform = GetVehicleTransform(vehicleData.handle)
						
						local sfxIndex = math.random(1, #vars.effectSFX)
						
						PlaySound(vars.effectSFX[sfxIndex], vehicleTransform.pos,  1)
					else
						vehicleData.honkTimer = vehicleData.honkTimer - GetChaosTimeStep()
					end
				end
			end,
			onEffectEnd = function(vars) end,
		},
		
		superWalkJump = {
			name = "Super Jump & Super Walkspeed",
			effectDuration = 20,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = { jumpNextFrame = false },
			onEffectStart = function(vars) end,
			onEffectTick = function(vars) 
				local playerVel = VecCopy(GetPlayerVelocity())
				
				playerVel[1] = 0
				playerVel[3] = 0
				
				local isTouchingGround = playerVel[2] >= -0.00001 and playerVel[2] <= 0.00001
				
				if vars.effectVariables.jumpNextFrame then
					vars.effectVariables.jumpNextFrame = false
					
					playerVel[2] = 15
					
					SetPlayerVelocity(playerVel)
				end
				
				if InputPressed("space") and isTouchingGround then
					vars.effectVariables.jumpNextFrame = true
				end
				
				local forwardMovement = 0
				local rightMovement = 0
				
				if InputDown("up") then
					forwardMovement = forwardMovement + 1
				end
				
				if InputDown("down") then
					forwardMovement = forwardMovement - 1
				end
				
				if InputDown("left") then
					rightMovement = rightMovement - 1
				end
				
				if InputDown("right") then
					rightMovement = rightMovement + 1
				end
				
				forwardMovement = forwardMovement * 25
				rightMovement = rightMovement * 25
				
				local playerTransform = GetPlayerTransform()
				
				local forwardInWorldSpace = TransformToParentVec(GetPlayerTransform(), Vec(0, 0, -1))
				local rightInWorldSpace = TransformToParentVec(GetPlayerTransform(), Vec(1, 0, 0))
				
				local forwardDirectionStrength = VecScale(forwardInWorldSpace, forwardMovement)
				local rightDirectionStrength = VecScale(rightInWorldSpace, rightMovement)
				
				playerVel = VecAdd(VecAdd(playerVel, forwardDirectionStrength), rightDirectionStrength)
				
				playerVel = playerVel
				
				SetPlayerVelocity(playerVel)
			end,
			onEffectEnd = function(vars) end,
		},
		
		tripleJump = {
			name = "Triple Jump",
			effectDuration = 20,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = { jumpNextFrame = false, jumpsLeft = 0, maxExtraJumps = 2 },
			onEffectStart = function(vars) end,
			onEffectTick = function(vars) 
				local playerVel = GetPlayerVelocity()
				
				local isTouchingGround = playerVel[2] >= -0.00001 and playerVel[2] <= 0.00001
				
				if vars.effectVariables.jumpNextFrame then
					vars.effectVariables.jumpNextFrame = false
					
					playerVel[2] = 4
				end
				
				if InputPressed("space") and vars.effectVariables.jumpsLeft > 0 then
					vars.effectVariables.jumpsLeft = vars.effectVariables.jumpsLeft - 1
					vars.effectVariables.jumpNextFrame = true
				end
				
				if isTouchingGround and vars.effectVariables.jumpsLeft < vars.effectVariables.maxExtraJumps then
					vars.effectVariables.jumpsLeft = vars.effectVariables.maxExtraJumps
				end
				
				SetPlayerVelocity(playerVel)
			end,
			onEffectEnd = function(vars) end,
		},
		
		simonSays = {
			name = "Gordon Says",
			effectDuration = 15,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = { activeDelay = 2, forcedInput = {key = "up", message = "moving forward"}},
			onEffectStart = function(vars) 
				local possibleInputs = {{key = "up", message = "moving forwards"},
										{key = "down", message = "moving backwards"},
										{key = "left", message = "moving left"}, 
										{key = "right", message = "moving right"}}
				
				local selectedInput = possibleInputs[math.random(1, #possibleInputs)]
				
				vars.effectVariables.forcedInput = selectedInput
				
			end,
			onEffectTick = function(vars) 
				local forcedInput = vars.effectVariables.forcedInput
			
				table.insert(drawCallQueue, function()
					UiPush()
						UiFont("regular.ttf", 52)
						UiTextShadow(0, 0, 0, 0.5, 2.0)
						
						UiAlign("center middle")
						
						UiTranslate(UiCenter(), UiHeight() * 0.2)
						
						UiText("Gordon Says")
						
						UiTranslate(0, 40)
						
						UiFont("regular.ttf", 26)
						
						UiText("Keep " .. forcedInput.message.. "!")
					UiPop()
				end)
			
				if vars.effectVariables.activeDelay > 0 then
					vars.effectVariables.activeDelay = vars.effectVariables.activeDelay - GetChaosTimeStep()
					return
				end
				
				if not InputDown(forcedInput.key) then
					local playerPos = GetPlayerPos()
					Explosion(playerPos, 3)
					SetPlayerHealth(0)
					vars.effectDuration = 0
					return
				end
			end,
			onEffectEnd = function(vars) end,
		},
		
		teleportToHeaven = {
			name = "Teleport To Heaven",
			effectDuration = 50,
			effectLifetime = 0,
			hideTimer = true,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {},
			onEffectStart = function(vars) 
				SetPlayerVehicle(0)
				
				local playerTransform = GetPlayerTransform()
				
				playerTransform.pos = VecAdd(playerTransform.pos, Vec(0, 500, 0))
				
				SetPlayerTransform(playerTransform)
			end,
			onEffectTick = function(vars) 
				local playerTransform = GetPlayerTransform()
				local rayDirection = TransformToParentVec(playerTransform, Vec(0, -1, 0))
 
				local hit, hitPoint, distance, normal = raycast(playerTransform.pos, rayDirection, 2)
				
				if hit == false then
					return
				end
				
				SetPlayerHealth(0.2)
				SetPlayerVelocity(Vec(0, 0, 0))
				
				vars.effectDuration = 0
				vars.effectLifetime = 0
			end,
			onEffectEnd = function(vars) end,
		},
		
		jumpyVehicles = {
			name = "Jumpy Vehicles",
			effectDuration = 20,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {vehicles = {}},
			onEffectStart = function(vars)
				local range = 500
				local minPos = Vec(-range, -range, -range)
				local maxPos = Vec(range, range, range)
				local nearbyShapes = QueryAabbShapes(minPos, maxPos)

				for i = 1, #nearbyShapes do
					local currentShape = nearbyShapes[i]
					local shapeBody = GetShapeBody(currentShape)
					
					local vehicleHandle = GetBodyVehicle(shapeBody)
					
					if vehicleHandle ~= 0 then
						vars.effectVariables.vehicles[#vars.effectVariables.vehicles + 1] = {handle = vehicleHandle, jumpTimer = math.random(0, 3)}
					end
				end
			end,
			onEffectTick = function(vars)
				for index, vehicleData in ipairs(vars.effectVariables.vehicles) do
					if math.random(1, 10) > 5 and vehicleData.jumpTimer <= 0 then
						vehicleData.jumpTimer = 5
						
						local vehicleHandle = vehicleData.handle
						
						local vehicleBody = GetVehicleBody(vehicleHandle)
						
						local vehicleVelocity = VecCopy(GetBodyVelocity(vehicleBody))
						
						vehicleVelocity[2] = 5
						
						SetBodyVelocity(vehicleBody, vehicleVelocity)
						
					else
						local vehicleTransform = GetVehicleTransform(vehicleData.handle)
						local vehicleBody = GetBodyTransform(vehicleTransform)
						
						DrawBodyOutline(vehicleBody)
						vehicleData.jumpTimer = vehicleData.jumpTimer - GetChaosTimeStep()
					end
				end
			end,
			onEffectEnd = function(vars) end,
		},
		
		hacking = {
			name = "Hacking",
			effectDuration = 60,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = { currHack = "nil", lives = 4, damageAlpha = 0, wordWheels = {}, currentHackPos = 1, ip = {19, 20, 16, 80}, playerPos = nil, barLineUpBars = {}},
			onEffectStart = function(vars) 
				vars.effectVariables.playerPos = GetPlayerPos()
			
				local hackTypes = {"letterLineup", "barLineup",}-- "ipLookup"}
				
				local letterLineupWords = {"teardown", "lockelle", "xplosive", "shotguns", "destroyd", "chaosmod"} --"resident"
				local letterLineupLetters = {"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"}
				
				local hackType = hackTypes[math.random(1, #hackTypes)]

				function getRandomLetter()
					return letterLineupLetters[math.random(1, #letterLineupLetters)]
				end
				
				if hackType == "letterLineup" then
					local word = letterLineupWords[math.random(1, #letterLineupWords)]
					
					for i = 1, 8 do
						local currLetter = word:sub(i, i)
						local wordWheel = { offset = math.random(0, 9), locked = false, letters = {currLetter} }
						
						for j = 2, 10 do
							local garbageLetter = currLetter
							
							while garbageLetter == currLetter do
								garbageLetter = getRandomLetter()
							end
							
							wordWheel.letters[j] = garbageLetter
						end
						
						vars.effectVariables.wordWheels[i] = wordWheel
					end
				elseif hackType == "ipLookup" then
				elseif hackType == "barLineup" then
					vars.effectVariables.barLineUpBars[1] = { value = 1, direction = 1, locked = false}
					for i = 2, 8 do
						local val = 1 - i * 0.2
						local dir = 1
						
						if val > 1 then
							val = 1
							dir = -1
						elseif val < -1 then
							val = -1
							dir = 1
						end
						
						vars.effectVariables.barLineUpBars[i] = { value = val, direction = dir }
					end
				end

				vars.effectVariables.currHack = hackType
			end,
			onEffectTick = function(vars) 
				function endMinigame()
					vars.effectLifetime = vars.effectDuration
				end
				
				if vars.effectVariables.lives <= 0 then
					endMinigame()
					return
				end
			
				SetPlayerTransform(Transform(vars.effectVariables.playerPos, Quat(0, 0, 0, 0)))
				
				local hackType = vars.effectVariables.currHack
				local drawCall = function() end
				
				local damageAlpha = vars.effectVariables.damageAlpha
				
				if damageAlpha > 0 then
					damageAlpha = damageAlpha - GetChaosTimeStep()
				end
				
				vars.effectVariables.damageAlpha = damageAlpha
				
				function drawBlackScreen()
					UiPush()
						UiColor(0, 0, 0, 1)
						
						UiAlign("center middle")
						
						UiTranslate(UiCenter(), UiMiddle())
						
						UiRect(UiWidth() + 10, UiHeight() + 10)
					UiPop()
				end
				
				function drawWindow()
					UiPush()
						UiAlign("center middle")
							
						UiTranslate(UiCenter(), UiMiddle())
						
						UiColor(0.4, 0.4, 1, 1)
						
						UiRect(UiWidth() * 0.6, UiHeight() * 0.7)
						
						UiColor(0, 0, 0, 1)
						
						UiTranslate(0, UiHeight() * 0.02)
						
						UiRect(UiWidth() * 0.595, UiHeight() * 0.65)
					UiPop()
				end
				
				function drawLives()
					UiPush()
						UiAlign("center middle")
							
						UiTranslate(UiCenter(), UiMiddle())
						
						UiTranslate(UiWidth() * 0.25, -UiHeight() * 0.25)
						
						UiAlign("center bottom")
						
						for i = 0, 3 do
							UiPush()
								if i + 1 <= vars.effectVariables.lives then
									UiColor(0, 0.8, 0.8, 1)
								else
									UiColor(0.5, 0.5, 0.5, 1)
								end
							
								UiTranslate(13 * i, 0)
								UiRect(10, 10 + i * 7)
							UiPop()
						end
					UiPop()
				end
				
				function drawDamage()
					UiPush()
						UiAlign("center middle")
							
						UiTranslate(UiCenter(), UiMiddle())
						
						UiColor(1, 0, 0, vars.effectVariables.damageAlpha)
						
						UiTranslate(0, UiHeight() * 0.02)
						
						UiRect(UiWidth() * 0.595, UiHeight() * 0.65)
					UiPop()
				end
				
				function loseLive()
					vars.effectVariables.damageAlpha = 1
					vars.effectVariables.lives = vars.effectVariables.lives - 1
				end
				
				function resetWordWheels()
					loseLive()
					vars.effectVariables.currentWordWheel = 1
					
					for i = 1, 8 do
						local wordWheel = vars.effectVariables.wordWheels[i]
						
						wordWheel.offset = math.random(0, 9)
						wordWheel.locked = false
					end
				end
				
				function barLineupLoseLevel()
					loseLive()
					local currentBarIndex = vars.effectVariables.currentHackPos
					
					if currentBarIndex > 1 then
						currentBarIndex = vars.effectVariables.currentHackPos - 1
						vars.effectVariables.currentHackPos = currentBarIndex
					end
					
					local currentBar = vars.effectVariables.barLineUpBars[currentBarIndex]
					
					currentBar.locked = false
				end
				
				if hackType == "letterLineup" then
					for i = 1, 8 do
						local wordWheel = vars.effectVariables.wordWheels[i]
						
						if not wordWheel.locked then
							
							wordWheel.offset = wordWheel.offset + GetChaosTimeStep() * 4
							
							if wordWheel.offset > 10 then
								wordWheel.offset = 0
							end
						end
					end
					
					if vars.effectVariables.currentHackPos > 8 then
						endMinigame()
						return
					end
					
					if InputPressed("space") then
						local currentWordWheelIndex = vars.effectVariables.currentHackPos
						local currentWordWheel = vars.effectVariables.wordWheels[currentWordWheelIndex]
						local currOffset = currentWordWheel.offset
						
						if currOffset >= 0 and currOffset <= 2 then
							currentWordWheel.offset = 1
							currentWordWheel.locked = true
							vars.effectVariables.currentHackPos = currentWordWheelIndex + 1
						else
							resetWordWheels()
						end
					end
				
					drawCall = function()
						UiPush()
							drawBlackScreen()
							drawWindow()
							drawLives()
							
							local offset = 5
							local width = UiWidth() * 0.5 / 8
							
							UiPush()
								UiAlign("center middle")
								UiTranslate(UiCenter(), UiMiddle())
							
								UiTranslate(-(width + offset) * 3.5, UiHeight() * 0.075) --0.175
								
								for i = 0, 7 do
									local wordWheel = vars.effectVariables.wordWheels[i + 1]
								
									UiPush()
										UiTranslate((width + offset) * i, 0)-- UiHeight() * 0.15)
										
										UiWindow(width, UiHeight() * 0.4, true)
										
										UiColor(0.3, 0.3, 0.3, 1)
										
										UiRect(UiWidth() * 2, UiHeight() * 2)
										
										UiColor(0, 0, 0, 1)
										
										UiTranslate(UiCenter(), UiMiddle())
										
										UiRect(UiWidth() * 0.97, UiHeight())
										
										UiColor(1, 1, 1, 1)
										
										UiFont("regular.ttf", 80)
										
										for j = -2, 12 do
											UiPush()
												local letter = ""
												
												if j < 1 then
													letter = wordWheel.letters[10 + j]
												elseif j > 10 then
													letter = wordWheel.letters[j - 10]
												else
													letter = wordWheel.letters[j]
												end
												
												if letter == wordWheel.letters[1] then
													UiColor(1, 0, 0, 1)
												end
											
												UiTranslate(0, -UiHeight() / 5 * wordWheel.offset)
												UiTranslate(0, UiHeight() / 5 * j)
												UiText(letter)
											UiPop()
										end
									UiPop()
								end
							UiPop()
							
							UiPush()
								UiAlign("center middle")
								UiTranslate(UiCenter(), UiMiddle())
							
								UiColor(1, 0, 0, 0.5)
								
								UiTranslate(0, UiHeight() * 0.075 / 2)
								
								UiRect((width + offset) * 8, 2)
								
								UiTranslate(-(width + offset) * 4, UiHeight() * 0.075 / 2)
								
								UiRect(2, UiHeight() * 0.075)
								
								UiTranslate((width + offset) * 8, 0)
								
								UiRect(2, UiHeight() * 0.075)
								
								UiTranslate(-(width + offset) * 4, UiHeight() * 0.075 / 2)
								
								UiRect((width + offset) * 8, 2)
							UiPop()
							
							drawDamage()
						UiPop()
					end
				elseif hackType == "ipLookup" then
					drawCall = function()
						UiPush()
							drawBlackScreen()
							drawWindow()
							drawLives()
							
						UiPop()
					end
				elseif hackType == "barLineup" then
					for i = 1, 8 do
						local currBar = vars.effectVariables.barLineUpBars[i]
						
						if not currBar.locked then
							local dir = currBar.direction
							local val = currBar.value + GetChaosTimeStep() * dir * 1.5
							
							if val > 1 then
								val = 1
								dir = -1
							elseif val < -1 then
								val = -1
								dir = 1
							end
							
							currBar.value = val
							currBar.direction = dir
						end
					end
					
					if vars.effectVariables.currentHackPos > 8 then
						endMinigame()
						return
					end
					
					if InputPressed("space") then
						local currentBarIndex = vars.effectVariables.currentHackPos
						local currentBar = vars.effectVariables.barLineUpBars[currentBarIndex]
						local currValue = currentBar.value
						
						if currValue <= 0.2 and currValue >= -0.2 then
							currentBar.value = 0
							currentBar.locked = true
							vars.effectVariables.currentHackPos = currentBarIndex + 1
						else
							barLineupLoseLevel()
						end
					end
				
					drawCall = function()
						UiPush()
							drawBlackScreen()
							drawWindow()
							drawLives()
							
							UiPush()
								UiAlign("center middle")
								UiTranslate(UiCenter(), UiMiddle())
							
								local barHeight = UiHeight() * 0.2
								local barWidth = UiHeight() * 0.025
								local offset = UiWidth() * 0.075 / 8
							
								UiTranslate(0, UiHeight() * 0.1)
								
								UiColor(1, 0, 0, 1)
								
								UiRect(UiHeight() * 0.5, UiHeight() * 0.4)
								
								UiColor(0, 0, 0, 1)
								
								UiRect(UiHeight() * 0.49, UiHeight() * 0.39)
								
								UiColor(1, 0, 0, 1)
								
								UiRect(UiHeight() * 0.5, barHeight * 0.15)
								
								UiTranslate(-(barWidth + offset) * 4.5, 0)
								
								for i = 1, 8 do
									local currVal = vars.effectVariables.barLineUpBars[i].value
								
									UiPush()
										UiTranslate((barWidth + offset) * i, currVal * 100)
										
										UiColor(1, 1, 1, 1)
										
										UiTranslate(0, -barHeight * 0.3)
										
										if vars.effectVariables.currentHackPos == i then
											UiColor(0.9, 0.9, 0, 1)
											UiRect(barWidth + 6, barHeight * 0.4 + 6)
											UiColor(1, 1, 1, 1)
										end
										
										UiRect(barWidth, barHeight * 0.4)
										
										UiTranslate(0, barHeight * 0.6)
										
										if vars.effectVariables.currentHackPos == i then
											UiColor(0.9, 0.9, 0, 1)
											UiRect(barWidth + 6, barHeight * 0.4 + 6)
											UiColor(1, 1, 1, 1)
										end
										
										UiRect(barWidth, barHeight * 0.4)
									UiPop()
								end
							UiPop()
							
							drawDamage()
						UiPop()
					end
				end
				
				UiMakeInteractive()
				table.insert(drawCallQueue, drawCall)
			end,
			onEffectEnd = function(vars) 
				if vars.effectVariables.lives <= 0 then
					local playerPos = GetPlayerPos()
					Explosion(playerPos, 3)
					SetPlayerHealth(0)
				end
			end,
		},
		
		--[[grieferJesus = {
			name = "Griefer Jesus",
			effectDuration = 500, -- 20,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = { npcTransform = nil},
			onEffectStart = function(vars) 
				local playerCameraTransform = GetPlayerCameraTransform()
				local cameraForward = Vec(0, 0, -5)
				local cameraForwardWorldSpace = TransformToParentPoint(playerCameraTransform, cameraForward)
				
				vars.effectVariables.npcTransform = Transform(cameraForwardWorldSpace, QuatEuler(0, 0, 0))
			end,
			onEffectTick = function(vars) 
				function getAngleToPlayer()
					local grieferTransform = vars.effectVariables.npcTransform
					local grieferForward = Vec(0, 0, -1)
					local grieferForwardWorldSpace = TransformToParentPoint(grieferTransform, grieferForward)
					
					local playerPos = VecCopy(GetPlayerPos())
					
					playerPos[2] = grieferTransform.pos[2]
					
					local vectorToPlayer = dirVec(playerPos, grieferTransform.pos)
					local vectorToPlayerLocalSpace = TransformToLocalVec(grieferTransform, vectorToPlayer)
				
					local angleRadian = math.acos(VecDot(grieferForward, vectorToPlayerLocalSpace) / (VecMag(grieferForward) * VecMag(vectorToPlayerLocalSpace)))
					local angleDegrees = angleRadian / 2 * 360
					
					DebugPrint(angleDegrees % 360)
					DebugCross(grieferTransform.pos, 1, 0, 0, 1)
					DebugLine(grieferTransform.pos, grieferForwardWorldSpace, 1, 0, 0, 1)
					DebugLine(grieferTransform.pos, vectorToPlayer, 0, 1, 0, 1)
					
					return angleDegrees
				end
				
				getAngleToPlayer()
				
				
			end,
			onEffectEnd = function(vars) end,
		},]]--
		
		virtualReality = {
			name = "Virtual Reality",
			effectDuration = 15,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {transform = 0},
			onEffectStart = function(vars)
				vars.effectVariables.transform = TransformCopy(GetPlayerTransform())
			end,
			onEffectTick = function(vars) end,
			onEffectEnd = function(vars) 
				SetPlayerTransform(vars.effectVariables.transform)
			end,
		},
		
		randomInformation = {
			name = "Useless Information",
			effectDuration = 15,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {},
			onEffectStart = function(vars) end,
			onEffectTick = function(vars)
				local gpv = GetPlayerVehicle()
				local fire = GetFireCount()
				local health = GetPlayerHealth()
				local shape = GetPlayerPickShape()
				if shape ~= 0 then
					DrawShapeOutline(shape, 0.5)
				end
				
				table.insert(drawCallQueue, function()
					UiPush()
						UiFont("regular.ttf", 30)
						UiTextShadow(0, 0, 0, 0.5, 2.0)
						UiAlign("left")
						UiTranslate(UiCenter() * 0.3, UiHeight() * 0.2)
						UiText("Active fires: " .. fire) -- Fire counter
						UiTranslate(0, 40)
						UiText("Player Vehicle Handle: " .. gpv) -- Player vehicle handle
						UiTranslate(0, 40)
						UiText("Player Health: " .. math.floor(health * 100)) -- Health
					UiPop()
				end)
			end,
			onEffectEnd = function(vars) end,
		},
	},	-- EFFECTS TABLE
}

chaosKeysInit()