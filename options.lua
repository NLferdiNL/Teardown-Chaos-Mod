#include "effects.lua"
#include "utils.lua"

function init()
	saveFileInit()
end

textboxClass = {
	inputNumbers = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "0"},
	inputLetters = {"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z" },
	default = {
		name = "TextBox",
		value = "",
		width = 100,
		height = 40,
		limitsActive = false,
		numberMin = 0,
		numberMax = 1,
		inputActive = false,
		lastInputActive = false,
		
		render = (function(me)
		UiPop()
		
		UiButtonImageBox("ui/common/box-outline-6.png", 6, 6)
		UiTranslate(-me.width - #me.name * 2.7, 0)
		UiText(me.name .. ":")
		UiTranslate(me.width + #me.name * 2.7, 0)
		
		if me.checkMouseInRect(me) and not me.inputActive then
			UiColor(1,1,0)
		elseif me.inputActive then
			UiColor(0,1,0)
		else
			UiColor(1,1,1)
		end
		
		local tempVal = me.value
		
		if tempVal == "" then
			tempVal = " "
		end
		
		if UiTextButton(tempVal, me.width, me.height) then
			me.inputActive = not me.inputActive
		end
		
		UiColor(1,1,1)
		
		UiPush()
		end),
		
		checkMouseInRect = (function(me)
			return UiIsMouseInRect(me.width, me.height)
		end),
		
		setActiveState = (function(me, newState)
			me.inputActive = newState
			if not me.inputActive then
				if me.numbersOnly then
					if me.value == "" then
						me.value = me.numberMin .. ""
					end
					
					if me.limitsActive then
						local tempVal = tonumber(me.value)
						if tempVal < me.numberMin then
							me.value = me.numberMin .. ""
						elseif tempVal > me.numberMax then
							me.value = me.numberMax .. ""
						end
					end
				end
			end
		end),
		
		inputTick = (function(me)
			if me.inputActive ~= me.lastInputActive then
				me.lastInputActive = me.inputActive
			end
		
			if me.inputActive then
				if InputPressed("lmb") then
					me.setActiveState(me, me.checkMouseInRect(me))
				elseif InputPressed("return") then
					me.setActiveState(me, false)
				elseif InputPressed("ctrl") then
					me.value = me.value:sub(1, #me.value - 1)
				else
					for j = 1, #textboxClass.inputNumbers do
						if InputPressed(textboxClass.inputNumbers[j]) then
							me.value = me.value .. textboxClass.inputNumbers[j]
						end
					end
					if not me.numbersOnly then
						for j = 1, #textboxClass.inputLetters do
							if InputPressed(textboxClass.inputLetters[j]) then
								me.value = me.value .. textboxClass.inputLetters[j]
							end
						end
					end
				end
			end
		end),
	},
	textboxes = {
	
	},
}

function draw()
	local textBox01, newBox01 = getTextBox(1)

	--[[local mX, mY = UiGetMousePos()
	UiButtonImageBox("ui/common/box-solid-6.png", 6, 6)
	UiTranslate(mX, mY)
	UiRect(10, 10)
	UiTranslate(-mX, -mY)]]--

	UiWordWrap(400)
	
	UiTranslate(UiCenter(), 50)
	UiAlign("center middle")
	
	UiFont("bold.ttf", 48)
	UiTranslate(0, 50)
	UiText("Chaos Mod")
	
	UiFont("regular.ttf", 26)
	UiPush()
	
	UiTranslate(0, 50)
	
	UiText("To backspace an input box press Ctrl.")
	
	UiTranslate(0, 50)
	
	UiText("A better options screen is being made!")
	
	UiTranslate(0, -50)
		
	UiTranslate(400, UiHeight() - 300)
	
	UiButtonImageBox("ui/common/box-outline-6.png", 6, 6)
	
	if UiTextButton("Reset to default", 200, 50) then
		textBox01.value = 10 .. ""
		chaosEffects.disabledEffects = {}
	end
	
	UiTranslate(0, 60)
	
	if UiTextButton("Save and exit", 200, 50) then
		local saveData = SerializeTable(chaosEffects.disabledEffects)
		SetString(moddataPrefix .. "DisabledEffects", saveData)
		SetInt(moddataPrefix .. "ChaosTimer", tonumber(textBox01.value))
		Menu()
	end
	
	UiTranslate(0, 60)
	
	if UiTextButton("Cancel", 200, 50) then
		Menu()
	end
	
	UiTranslate(-400, -UiHeight() + 360)
	
	UiTranslate(0, 50)
	
	UiPop()
		UiTranslate(0, 150)
		
		if newBox01 then
			textBox01.name = "Chaos timer"
			textBox01.value = chaosTimer .. ""
			textBox01.numbersOnly = true
			textBox01.limitsActive = true
			textBox01.numberMin = 1
			textBox01.numberMax = 1000
		end
		
		textBox01.render(textBox01)
		
		UiTranslate(0, 35)
		
		UiText("How long between each effect?")
	UiPush()
	
	UiPop()
		UiTranslate(0, 50)
		UiText("Enabled effects:")
		UiTranslate(0, 30)
		
		local rows = 5
		local col = 4
		
		local xOffset = 300 * rows / 2
		local margin = 10
		
		local items = chaosEffects.effectKeys
		
		for key, value in ipairs(items) do
			--DebugPrint(key .. ": " .. -xOffset + (key % rows) * 300 .. ", " .. key / col * 40)
			
			--UiTranslate(0, (key - 1) * 40 + 5)
			
			UiTranslate(-xOffset + margin + (key % rows) * 300, key / col * 40)
			
			local effectDisabled = chaosEffects.disabledEffects[value] ~= nil
			
			if effectDisabled then
				UiButtonImageBox("ui/common/box-outline-6.png", 6, 6, 1, 0, 0, 1)
			else
				UiButtonImageBox("ui/common/box-outline-6.png", 6, 6, 0, 1, 0, 1)
			end
			
			if UiTextButton(chaosEffects.effects[value].name, 300, 40) then
				if effectDisabled then
					chaosEffects.disabledEffects[value] = nil
				else
					chaosEffects.disabledEffects[value] = "disabled"
				end
			end
			
			--UiTranslate(0, -((key - 1) * 40 + 5))
			UiTranslate(xOffset - (key % rows) * 300, -(key / col * 40))
		end
	UiPush()
	
end

function tick()
	for i = 1, #textboxClass.textboxes do
		local textBox = textboxClass.textboxes[i]
		textBox.inputTick(textBox)
	end
end

function getTextBox(id)
	if id <= -1 then
		id = #textboxes + 1
	end
	local textBox = textboxClass.textboxes[id]
	local newBox = false
	
	if textBox == nil then
		textboxClass.textboxes[id] = deepcopy(textboxClass.default)
		textBox = textboxClass.textboxes[id]
		newBox = true
	end
	
	return textBox, newBox
end