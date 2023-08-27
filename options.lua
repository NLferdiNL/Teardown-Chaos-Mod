#include "effects.lua"
#include "utils.lua"
#include "textbox.lua"

local sortedEffectList = {}
local menuScrollPosition = 0
local listScreenMaxScroll = 0
local scrollOptionsSize = 300

function init()
	saveFileInit()

	sortedEffectList = SortEffectsTable()
    
    listScreenMaxScroll = #sortedEffectList / 4 * 20 + scrollOptionsSize
end

function draw()
	local textBox01, newBox01 = textboxClass_getTextBox(1)
	local textBox02, newBox02 = textboxClass_getTextBox(2)

	--[[local mX, mY = UiGetMousePos()
	UiButtonImageBox("ui/common/box-solid-6.png", 6, 6)
	UiTranslate(mX, mY)
	UiRect(10, 10)
	UiTranslate(-mX, -mY)]]--

	UiPush()
		UiTranslate(UiWidth(), UiHeight())
		UiTranslate(-50, 5 * -50)
		UiAlign("right bottom")

		UiFont("regular.ttf", 26)

		UiButtonImageBox("ui/common/box-outline-6.png", 6, 6)

		if UiTextButton("Enable All", 200, 50) then
			chaosEffects.disabledEffects = {}
		end

		UiTranslate(0, 60)

		if UiTextButton("Disable All", 200, 50) then
			for key, value in ipairs(chaosEffects.effectKeys) do
				chaosEffects.disabledEffects[value] = "disabled"
			end
		end

		UiTranslate(0, 60)

		if UiTextButton("Reset to default", 200, 50) then
			textBox01.value = 10 .. ""
			chaosEffects.disabledEffects = {fakeDeleteVehicle = "disabled", turtlemode = "disabled", unbreakableEverything = "disabled", allVehiclesInvulnerable = "disabled"}
			twitchIntegration = false
			textBox02.value = 1 .. ""
		end

		UiTranslate(0, 60)

		if UiTextButton("Save and exit", 200, 50) then
			local saveData = SerializeTable(chaosEffects.disabledEffects)
			SetString(moddataPrefix .. "DisabledEffects", saveData)
			SetInt(moddataPrefix .. "ChaosTimer", tonumber(textBox01.value))
			SetBool(moddataPrefix .. "TwitchIntegration", twitchIntegration)
			SetFloat(moddataPrefix .. "TwitchBalancing", tonumber(textBox02.value))
			Menu()
		end

		UiTranslate(0, 60)

		if UiTextButton("Cancel", 200, 50) then
			Menu()
		end
	UiPop()
    
    UiTranslate(0, -menuScrollPosition)

	UiPush()
		UiWordWrap(400)

		UiTranslate(UiCenter(), 50)
		UiAlign("center middle")

		UiFont("bold.ttf", 48)
		UiTranslate(0, 50)
		UiText("Chaos Mod")

		UiFont("regular.ttf", 26)

		UiTranslate(0, 50)
		
		UiText("Use your mousewheel to scroll.")

		UiTranslate(0, 50)

		if newBox01 then
			textBox01.name = "Chaos timer"
			textBox01.value = chaosTimer .. ""
			textBox01.numbersOnly = true
			textBox01.limitsActive = true
			textBox01.numberMin = 1
			textBox01.numberMax = 1000
		end

		textboxClass_render(textBox01)

		UiTranslate(0, 35)

		UiText("How long between each effect?")
		
		UiTranslate(0, 50)
		
		local twitchButtonText = "Disabled"
		
		if twitchIntegration then
			twitchButtonText = "Enabled"
		end
		
		UiButtonImageBox("ui/common/box-outline-6.png", 6, 6, 1, 1, 1, 1)
		
		if UiTextButton("Twitch Integration: " .. twitchButtonText, 400, 40) then
			twitchIntegration = not twitchIntegration
		end
		
		UiTranslate(0, 50)

		UiText("Keep in mind you also need to run the external program for this to work.")
		
		UiTranslate(0, 75)
		
		if newBox02 then
			textBox02.name = "Effect multiplier"
			textBox02.value = twitchBalancing .. ""
			textBox02.numbersOnly = true
			textBox02.limitsActive = true
			textBox02.numberMin = 0.5
			textBox02.numberMax = 1000
		end

		textboxClass_render(textBox02)
		
		UiTranslate(0, 70)

		UiText("Use this to multiply the length on effects by that amount. This pairs well with doubling the chaos time for Twitch streaming.")
	UiPop()
	
	UiTranslate(0, 270)

	UiPush()
		UiWordWrap(400)

		UiTranslate(UiCenter(), 300)
		UiAlign("center middle")
		UiFont("regular.ttf", 26)

		UiText("Enabled effects:")
	UiPop()

	UiPush()
		UiTranslate(UiCenter(), 350)
		UiAlign("center middle")
		UiFont("regular.ttf", 26)

		local rows = 4
		--local col = 4

		-- local xOffset = 300 * rows / 2.7
		-- local xMargin = 20
		-- local yMargin

		local buttonWidth = 320
		local buttonHeight = 40

		UiTranslate(-buttonWidth * 1.5, 0)

		for key, value in ipairs(sortedEffectList) do
			--UiPush()

				--UiTranslate(-xOffset + (key % rows) * buttonWidth, math.floor((key / col)) * buttonHeight)

				local effectDisabled = chaosEffects.disabledEffects[value] ~= nil

				if effectDisabled then
					UiButtonImageBox("ui/common/box-outline-6.png", 6, 6, 1, 0, 0, 1)
				else
					UiButtonImageBox("ui/common/box-outline-6.png", 6, 6, 0, 1, 0, 1)
				end
				
				UiPush()
					local textWidth, textHeight = UiGetTextSize(chaosEffects.effects[value].name)
					local fontSize = 26
					local fontDecreaseIncrement = 2
					
					while textWidth > buttonWidth - 10 do
						fontSize = fontSize - fontDecreaseIncrement

						UiFont("regular.ttf", fontSize)
						
						textWidth, textHeight = UiGetTextSize(chaosEffects.effects[value].name)
					end
				
					if UiTextButton(chaosEffects.effects[value].name, buttonWidth, buttonHeight) then
						if effectDisabled then
							chaosEffects.disabledEffects[value] = nil
						else
							chaosEffects.disabledEffects[value] = "disabled"
						end
					end
				UiPop()

				UiTranslate(buttonWidth, 0)

				if key % rows == 0 then
					UiTranslate(0, buttonHeight)
					UiTranslate(-buttonWidth*(rows), 0)
				end
			--UiPop()
		end
	UiPop()

end

function checkMouseScroll()
	menuScrollPosition = menuScrollPosition + -InputValue("mousewheel") * 10

	if menuScrollPosition < 0 then
		menuScrollPosition = 0
	elseif menuScrollPosition > listScreenMaxScroll then
		menuScrollPosition = listScreenMaxScroll
	end
end

function tick()
    checkMouseScroll()
	textboxClass_tick()
end