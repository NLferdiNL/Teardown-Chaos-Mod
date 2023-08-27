#include "quickload.lua"
#include "effects.lua"
#include "utils.lua"
#include "debug.lua"

-- Globals
drawCallQueue = {}
timeScale = 1 -- This one is required to keep chaos time flowing normally.
testThisEffect = "" -- Leave empty to let RNG grab effects.
lastEffectKey = ""
currentTime = 0
timerPaused = false
chaosPaused = false
hasTheGameReloaded = false
chaosTimerColor = { r = 0.25, g = 0.25, b = 1.0 }
twitchIntegration = false
twitchProportionalVoting = false

-- Inside the init() these changes don't get backed up.
-- Here they do. Allowing quickloading to be available.
saveFileInit()

removeDisabledEffectKeys()
loadChaosEffectData()

UpdateQuickloadPatch()

twitchVotesUpdateInterval = 1.0
currentTwitchVotesUpdateInterval = twitchVotesUpdateInterval
twitchCountedVotes = {}
twitchEffects = {}
twitchVoteStep = 1

function init()
	debugInit()
	
	UpdateQuickloadPatch()
	
	--DebugPrint(#chaosEffects.effectKeys)
	
	if twitchIntegration then
		SetInt(moddataPrefix .. "TwitchVoteStep", 1)
	
		twitchCountedVotes = {0, 0, 0, 0, 0}
		renewTwitchVaribles()
	end
end

function chaosUnavailable()
	return chaosEffects.effectTemplate.onEffectStart == nil
end

function getCopyOfEffect(key)
	return deepcopy(chaosEffects.effects[key])
end

function getRandomEffect(instance)
	instance = instance or true
	local key = testThisEffect -- Debug effect, if this is empty replaced by RNG.

	if #chaosEffects.effectKeys <= 0 then
		return deepcopy(chaosEffects.noEffectsEffect)
	end

	if key == "" then
		local index = math.random(1, #chaosEffects.effectKeys)
		key = chaosEffects.effectKeys[index]
	end

	if key == lastEffectKey and testThisEffect == "" and #chaosEffects.effectKeys > 1 then
		return getRandomEffect()
	end

	lastEffectKey = key

	if not instance then
		return key
	end

	local effectInstance = getCopyOfEffect(key)

	return effectInstance
end

function triggerEffect(effect)
	table.insert(chaosEffects.activeEffects, 1, effect)

	effect.onEffectStart(effect)
end

function triggerChaos()
	triggerEffect(getRandomEffect())
end

function triggerTwitchChaos()
	local selectedEffect = ""
	
	if twitchProportionalVoting and totalVotes > 0 then
		local totalVotes = twitchCountedVotes[5]
		
		local drawnNumber = math.random(1, totalVotes)
		
		local firstWeight = twitchCountedVotes[1] / totalVotes
		local secondWeight = twitchCountedVotes[2] / totalVotes + firstWeight
		local thirdWeight = twitchCountedVotes[3] / totalVotes + secondWeight
		--local fourthWeight = twitchCountedVotes[4] / totalVotes + thirdWeight
		
		if drawnNumber < firstWeight then
			selectedEffect = twitchEffects[1]
		elseif drawnNumber > firstWeight and drawnNumber < secondWeight then
			selectedEffect = twitchEffects[2]
		elseif drawnNumber > secondWeight and drawnNumber < thirdWeight then
			selectedEffect = twitchEffects[3]
		elseif drawnNumber > thirdWeight then
			selectedEffect = twitchEffects[4]
		end
	else
		local highest = 0
		local highestIndex = 1
		for i = 1, 4 do
			if twitchCountedVotes[i] > highest then
				highest = twitchCountedVotes[i]
				highestIndex = i
			end
		end
		
		selectedEffect = twitchEffects[highestIndex]
	end
	
	local copyOfEffect = deepcopy(selectedEffect)
	
	copyOfEffect.effectDuration = copyOfEffect.effectDuration * twitchBalancing
	
	triggerEffect(copyOfEffect)
end

function removeChaosLogOverflow()
	if #chaosEffects.activeEffects > chaosEffects.maxEffectsLogged then
		for i = #chaosEffects.activeEffects, 1, -1 do
			local curr = chaosEffects.activeEffects[i]
			if curr.effectDuration <= 0 then
				table.remove(chaosEffects.activeEffects, i)
				if #chaosEffects.activeEffects <= chaosEffects.maxEffectsLogged then
					break
				end
			end
		end
	end
end

function chaosEffectTimersTick(dt)
	for key, value in ipairs(chaosEffects.activeEffects) do
		if value.effectDuration > 0 then
			value.effectLifetime = value.effectLifetime + dt
			if value.effectLifetime >= value.effectDuration then
				value.onEffectEnd(value)
				table.remove(chaosEffects.activeEffects, key)
			else
				value.onEffectTick(value)
			end
		end
	end
end

function GetChaosTimeStep()
	if timeScale < 1 then
		return GetTimeStep() * (timeScale + 1)
	else
		return GetTimeStep()
	end
end

function tick(dt)
	if quickloadTick() then
		-- Has quickloaded
		chaosTimer = chaosTimerBackup
	end

	-- Failsafe
	if chaosUnavailable() then
		chaosEffects.activeEffects = {}

		local warningEffect = getCopyOfEffect("nothing")
		warningEffect.name = "An error occurred while loading\nthe effects from a quick load.\nPlease restart the level to\nkeep using the Chaos mod."
		warningEffect.onEffectStart = function() end
		warningEffect.onEffectTick = function() end
		warningEffect.onEffectEnd = function() end

		triggerEffect(warningEffect)
		currentTime = chaosTimer
		return
	end
	
	if twitchIntegration then
		twitchTick()
	end

	debugTick()

	if not timerPaused then
		if(timeScale < 1) then
			dt = dt * (timeScale + 1)
		end

		currentTime = currentTime + dt

		if currentTime > chaosTimer then
			currentTime = 0
			if twitchIntegration then
				triggerTwitchChaos()
				
				renewTwitchVaribles()
				
				if twitchVoteStep == 1 then
					SetInt(moddataPrefix .. "TwitchVoteStep", 2)
					twitchVoteStep = 2
				else
					SetInt(moddataPrefix .. "TwitchVoteStep", 1)
					twitchVoteStep = 1
				end
			else
				triggerChaos()
			end
			removeChaosLogOverflow()
		end
	end

	if not chaosPaused then
		chaosEffectTimersTick(dt)
	end

	if timeScale ~= 1 then
		SetTimeScale(timeScale)
		timeScale = 1
	end
end

function drawTimer()
	local currentTimePercenage = 100 / chaosTimer * currentTime / 100

	UiAlign("center middle")

	UiPush()
		UiColor(0.1, 0.1, 0.1, 0.5)
		UiTranslate(UiCenter(), 0)

		UiRect(UiWidth() + 10, UiHeight() * 0.05)
	UiPop()

	UiPush()
		if chaosUnavailable() then
			UiColor(1, 0.25, 0.25)
		else
			UiColor(chaosTimerColor.r, chaosTimerColor.g, chaosTimerColor.b)
		end
		UiTranslate(UiCenter() * currentTimePercenage, 0)
		UiRect(UiWidth() * currentTimePercenage, UiHeight() * 0.05)
	UiPop()
end

function drawTwitchEffectVotes()
	UiPush()
	UiColor(1, 1, 1)
	UiTranslate(UiWidth() * 0.05, UiHeight() * 0.1)
	UiAlign("left middle")
	UiTextShadow(0, 0, 0, 0.5, 2.0)
	UiFont("regular.ttf", 26)
	
	local totalVotes = twitchCountedVotes[5]
	local barSizeX = 400
	local barSizeY = 30
	
	for key, value in ipairs(twitchEffects) do
		local votePercentage = 0
		
		if totalVotes == nil then
			updateTwitchVotes()
		end
		
		if totalVotes > 0 then
			votePercentage = (100 / totalVotes * twitchCountedVotes[key] / 100)
		end

		UiColor(0.2, 0.2, 0.2, 0.2)
		
		UiRect(barSizeX, barSizeY)

		UiColor(0.7, 0.7, 0.7, 0.5)

		UiRect(barSizeX * votePercentage, barSizeY)
		
		UiColor(1, 1, 1, 1)
		
		if twitchVoteStep == 2 then
			key = key + 4
		end
		
		if (key < 4 and twitchVoteStep == 1) or (key < 8 and twitchVoteStep == 2) then
			UiText(key .. ": " ..value.name)
		else
			UiText(key .. ": Random Effect")
		end
		
		UiTranslate(0, barSizeY + 10)
	end

UiPop()
end

function drawEffectLog()
UiPush()
	UiColor(1, 1, 1)
	UiTranslate(UiWidth() * 0.9, UiHeight() * 0.1)
	UiAlign("right middle")
	UiTextShadow(0, 0, 0, 0.5, 2.0)
	UiFont("regular.ttf", 26)

	for key, value in ipairs(chaosEffects.activeEffects) do
		UiText(value.name)

		if value.effectDuration > 0 and not value.hideTimer then
			local effectDurationPercentage = 1 - (100 / value.effectDuration * value.effectLifetime / 100)

			UiColor(0.2, 0.2, 0.2, 0.2)
			UiTranslate(100, 0)
			UiRect(75, 20)

			UiAlign("center middle")

			UiColor(0.7, 0.7, 0.7, 0.5)

			UiTranslate(-75 / 2 , 0)

			UiRect(75 * effectDurationPercentage, 20)

			UiTranslate(75 / 2)

			UiColor(1, 1, 1, 1)

			UiAlign("right middle")

			UiTranslate(-100, 0)
		end
		UiTranslate(0, 40)
	end

UiPop()
end

function processDrawCallQueue()
	for key, value in ipairs(drawCallQueue) do
		value()
	end

	drawCallQueue = {}
end

function draw()
	UiPush()
		if hasTheGameReloaded then
			drawTimer()
			drawEffectLog()
			return
		end

		processDrawCallQueue()
		
		if twitchIntegration then
			drawTwitchEffectVotes()
		end
		
		drawTimer()
		drawEffectLog()

		debugDraw()
	UiPop()
end

function renewTwitchVaribles()
	twitchEffects[1] = getRandomEffect(false)
	twitchEffects[2] = getRandomEffect(false)
	twitchEffects[3] = getRandomEffect(false)
	twitchEffects[4] = getRandomEffect(false)
end

function twitchTick()
	if currentTwitchVotesUpdateInterval > 0 and not (currentTime >= chaosTimer * 0.9 and currentTime < chaosTimer * 0.91) then
		currentTwitchVotesUpdateInterval = currentTwitchVotesUpdateInterval - GetChaosTimeStep()
		return
	end
	
	currentTwitchVotesUpdateInterval = twitchVotesUpdateInterval

	updateTwitchVotes()
end

function updateTwitchVotes()
	local xml = "MOD/twitchchat.xml"
	
	local twitchChatObject = Spawn("MOD/twitchchat.xml", Transform())[1]
	
	local votes = GetDescription(twitchChatObject)
	
	votes = votes:gsub("%[", "")
	votes = votes:gsub("%]", "")
	votes = votes:gsub("\,", "")
	
	twitchCountedVotes = {}
	
	Delete(twitchChatObject)
	
	for number in votes:gmatch("%w+") do table.insert(twitchCountedVotes, tonumber(number)) end
end