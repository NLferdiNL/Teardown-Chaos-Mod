#include "textbox.lua"

local debugMenuEnabled = false

local mouseActive = false

local overrideTimeScale = false

function debugTick()
	if mouseActive then
		UiMakeInteractive()
	end
	
	if debugMenuEnabled then
		textboxClass.tick()
	end
	
	checkDebugMenuToggles()
end

function debugDraw()
	if testThisEffect ~= "" or debugMenuEnabled then
		drawDebugText()
	end
	
	if debugMenuEnabled then
		drawDebugMenu()
	end
end

function checkDebugMenuToggles()
	if debugMenuEnabled and InputPressed("h") then
		mouseActive = not mouseActive
	end
	
	if InputDown("ctrl") and InputPressed("h") then
		debugMenuEnabled = not debugMenuEnabled
		
		if not debugMenuEnabled then
			mouseActive = false
		end
	end
end

function debugFunc()
	if InputPressed("p") then
		for i=1, 20 do
		DebugPrint(" ")
		end
		
		DebugPrint(chaosEffects.testVar == nil)
		
		for key, value in pairs(chaosEffects.effects["myGlasses"]) do
			if type(value) ~= "table" and type(value) ~= "function"then
				DebugPrint(key .. ": " .. value)
			else
				DebugPrint(key .. ": " .. type(value)) 
			end
		end
	end
end

function drawDebugText()
	local effect = nil
	
	local testedEffect = testThisEffect
	
	if testedEffect == "" then
		if chaosEffects.activeEffects[1] == nil then
			return
		end
	end

	if #chaosEffects.activeEffects <= 0 then
		effect = chaosEffects.effects[testedEffect]
	else
		effect = chaosEffects.activeEffects[1]
	end
	
	UiPush()
		UiAlign("top left")
		UiTranslate(UiWidth() * 0.025, UiHeight() * 0.05)
		UiTextShadow(0, 0, 0, 0.5, 2.0)
		UiFont("bold.ttf", 26)
		UiColor(1, 0.25, 0.25, 1)
		UiText("CHAOS MOD DEBUG MODE ACTIVE")
		UiTranslate(0, UiHeight() * 0.025)
		if testedEffect ~= "" then
			UiText("Testing effect: " .. testedEffect)
		else
			UiText("Current first effect: ")
		end
		
		for index, key in ipairs(chaosEffects.debugPrintOrder) do
			local effectProperty = effect[key]
		
			UiTranslate(0, UiHeight() * 0.025)
			if type(effectProperty) == "string" or type(effectProperty) == "number" then
				UiText(key .." = " .. effectProperty)
			elseif type(effectProperty) == "table" then
				UiText(key .." = " .. debugTableToText(effectProperty))
			else
				UiText(key .. " = " .. type(effectProperty))
			end
		end
	UiPop()
end

function debugTableToText(inputTable, loopThroughTables)
	loopThroughTables = loopThroughTables or true

	local returnString = "{ "
	for key, value in pairs(inputTable) do
		if type(value) == "string" or type(value) == "number" then
			returnString = returnString .. key .." = " .. value .. ", "
		elseif type(value) == "table" and loopThroughTables then
			returnString = returnString .. key .. " = " .. debugTableToText(value) .. ", "
		else
			returnString = returnString .. key .. " = " .. type(value) .. ", "
		end
	end
	returnString = returnString .. "}"
	
	return returnString
end

function drawDebugMenu()
	UiPush()
		UiButtonImageBox("ui/common/box-outline-6.png", 6, 6)
		UiWordWrap(500)
		
		UiAlign("bottom right")
		UiTranslate(UiWidth(), UiHeight())
		
		UiFont("regular.ttf", 26)
		
		UiColor(0, 0, 0, 0.75)
		
		UiRect(500, 500)
		
		UiTranslate(-250, -500)
		
		UiAlign("top center")
		
		UiColor(1, 1, 1, 0.75)
		
		UiRect(500, 30)
		
		UiColor(0, 0, 0, 1)
		
		UiText("Chaos Mod Debug Menu")
		
		UiAlign("top left")
		
		UiTranslate(-230, 40)
		
		UiColor(1, 1, 1, 1)
		
		UiText("(While this menu is open)\nPress H to toggle mouse input.\nCTRL to backspace input boxes.")
		
		UiTranslate(0, 80)
		
		UiText("Current time: " .. math.floor(currentTime * 100)/100 .. "/" .. chaosTimer)
		
		UiTranslate(0, 30)
		
		local effects = ""
		
		for key, value in ipairs(chaosEffects.activeEffects) do
			if key > 1 then
			effects = effects .. ", "
			end
			effects = effects .. value.name
		end
		
		UiText("Active effects: " .. effects)
		
		UiTranslate(0, 90)
		
		UiText("Last Effect Key: " .. lastEffectKey)
		
		UiTranslate(0, 30)
		
		local chaosEffectsText = "Pause Chaos Effects"
		
		if chaosPaused then
			chaosEffectsText = "Resume Chaos Effects"
		end
		
		if UiTextButton(chaosEffectsText, 220, 30) then
			chaosPaused = not chaosPaused
		end
		
		UiTranslate(0, 40)
		
		local chaosTimerText = "Pause Timer"
		
		if timerPaused then
			chaosTimerText = "Resume Timer"
		end
		
		if UiTextButton(chaosTimerText, 220, 30) then
			timerPaused = not timerPaused
		end
		
		UiTranslate(0, 40)
		
		if UiTextButton("Clear effects", 220, 30) then
			chaosEffects.activeEffects = {}
		end
		
		UiTranslate(0, 40)
		
		local timescaleOverrideText = "Override Timescale"
		
		if overrideTimeScale then
			timescaleOverrideText = "Release Timescale"
		end
		
		if UiTextButton(timescaleOverrideText, 220, 30) then
			overrideTimeScale = not overrideTimeScale
		end
		
		UiTranslate(120, 40)
		
		local textBox01, newBox01 = textboxClass.getTextBox(1)
		
		if newBox01 then
			textBox01.name = "Timescale"
			textBox01.value = timeScale .. ""
			textBox01.numbersOnly = true
			textBox01.limitsActive = true
			textBox01.numberMin = 0.1
			textBox01.numberMax = 1
			textBox01.height = 30
		end
		
		if overrideTimeScale then
			if textBox01.value == "" then
				timeScale = 1
			else
				timeScale = tonumber(textBox01.value)
			end
		end
		
		textBox01.render(textBox01)
		
		UiTranslate(-120, 30)
		
	UiPop()
end