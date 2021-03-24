#include "effects.lua"
#include "utils.lua"

local testThisEffect = "" -- Leave empty to let RNG grab effects.
local drawCallQueue = {}
local timeScale = 1
local lastEffectKey = ""
local currentTime = 0
local currentEffects = {}

function init()
	saveFileInit()
	
	removeDisabledEffectKeys()
end

function getRandomEffect()
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
	
	local effectInstance = deepcopy(chaosEffects.effects[key])
	
	return effectInstance
end

function triggerChaos()
	
	table.insert(chaosEffects.activeEffects, 1, getRandomEffect())
	
	local effect = chaosEffects.activeEffects[1]

	effect.onEffectStart(effect)

	if effect.effectDuration <= 0 then
		effect.onEffectStart(effect)
	end
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
			value.onEffectTick(value)
			if value.effectLifetime > value.effectDuration then
				value.onEffectEnd(value)
				table.remove(chaosEffects.activeEffects, key)
			end
		end
	end
end

function tick(dt)
	if(timeScale < 1) then
		dt = dt * (timeScale + 1)
	end
	currentTime = currentTime + dt
	
	if timeScale ~= 1 then
		SetTimeScale(timeScale)
	end
	
	if currentTime > chaosTimer then
		currentTime = 0
		triggerChaos()
		removeChaosLogOverflow()
	end
	
	chaosEffectTimersTick(dt)
end

function drawTimer()
local currentTimePercenage = 100 / chaosTimer * currentTime / 100

UiAlign("center middle")

UiPush()
	UiColor(0.1, 0.1, 0.1)
	UiTranslate(UiCenter(), 0)
	
	UiRect(UiWidth() + 10, UiHeight() * 0.05)
UiPop()

UiPush()
	UiColor(0.25, 0.25, 1)
	UiTranslate(UiCenter() * currentTimePercenage, 0)
	UiRect(UiWidth() * currentTimePercenage, UiHeight() * 0.05)
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
		
		if value.effectDuration > 0 then
			local effectDurationPercentage = 1 - (100 / value.effectDuration * value.effectLifetime / 100)
		
			UiColor(0.2, 0.2, 0.2, 0.2)
			UiTranslate(100, 0)
			UiRect(75, 20)
			
			UiAlign("center middle")
			
			UiColor(0.7, 0.7, 0.7, 0.2)
			
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
	drawTimer()
	drawEffectLog()
	processDrawCallQueue()
end
