function drawSelections()
    
	local lineHeight = 18 * generalSettings["font"];
    
	for i = 1, SEL_CNT do
		if selects[i] then
			ofNoFill()

			
			-- print(selects[i]["sx"], selects[i]["sy"], selects[i]["w"], selects[i]["h"])
			local x = scaledX(selects[i]["sx"])
			local y = scaledY(selects[i]["sy"])
			local w = scaledX(selects[i]["w"])
			local h = scaledY(selects[i]["h"])
			local frames = selects[i]["frames"]

			local baseX = x + (w < 0 and w or 0)
			local baseYTop = y + (h < 0 and h or 0)
			local baseY = y + (h > 0 and h or 0)

			ofSetColor(255, 0, 0, 255)
			title:drawString(tostring(i), baseX - 14 * generalSettings["font"], baseYTop + 12 * generalSettings["font"])

			if activeSelectIndex == i then
				ofSetColor(255, 0, 255, 255)
			end

			ofSetLineWidth(generalSettings['font'])

			ofDrawRectangle(x, y, w, h)
			ofFill()
			ofDrawRectangle(x - 3 * generalSettings['font'], y + h -3 * generalSettings['font'], 6 * generalSettings['font'],6 * generalSettings['font'])
			ofNoFill()

			


			local cursorX = x + cursors[i] / frames * w
			ofDrawLine(cursorX, y, cursorX, y + h)

		
			-- speed

			if selects[i]['current'] == 'speed' and activeSelectIndex == i then
				ofSetColor(255, 0, 255, 255)
			elseif previewParameter and previewParameter.type == 'select' and previewParameter.target == i and previewParameter.param == 'speed' then
				ofSetColor(0, 255, 0, 255) -- Желтый цвет для предварительного просмотра
			else
				ofSetColor(255, 0, 0, 255)
			end

			local speed = tostring(math.floor(selects[i]["speed"] or 0))
			local speedX = baseX -- - 12 * 3
			local speedY = baseY + lineHeight * 1
			title:drawString(speed, speedX, speedY)
			
			if activeSelectIndex == i then
				smalltext:drawString('speed', speedX, speedY + 12 * generalSettings["font"])
			end

			--vol
			
			local vol = string.format("%.2f", selects[i]["volume"])
			local volX = baseX + 50 * generalSettings["font"] -- - 12 * 3
			local volY = baseY + lineHeight * 1

			


			-- white
			-- ofSetColor(255, 255, 255, 255)

			-- title:drawString(vol, volX, volY+1)
			-- if activeSelectIndex == i then
			-- 	smalltext:drawString('volume', volX, volY + 1)
			-- end

			-- color
			if selects[i]['current'] == 'volume' and activeSelectIndex == i then
				ofSetColor(255, 0, 255, 255)
			elseif previewParameter and previewParameter.type == 'select' and previewParameter.target == i and previewParameter.param == 'volume' then
				ofSetColor(0, 255, 0, 255) -- Желтый цвет для предварительного просмотра
			else
				ofSetColor(255, 0, 0, 255)
			end

			title:drawString(vol, volX, volY)
			if activeSelectIndex == i then
				smalltext:drawString('volume', volX, volY + 12 * generalSettings["font"] )
			end



			--frmes
			
			local frames = string.format("%.0f", selects[i]["frames"])
			local framesX = baseX + 100 * generalSettings["font"] -- - 12 * 3
			local framesY = baseY + lineHeight * 1
			
			if selects[i]['current'] == 'frames' and activeSelectIndex == i then
				ofSetColor(255, 0, 255, 255)
			elseif previewParameter and previewParameter.type == 'select' and previewParameter.target == i and previewParameter.param == 'frames' then
				ofSetColor(0, 255, 0, 255) -- Желтый цвет для предварительного просмотра
			else
				ofSetColor(255, 0, 0, 255)
			end

			title:drawString(frames, framesX, framesY)
			if activeSelectIndex == i then
				smalltext:drawString('frames', framesX, framesY + 12 * generalSettings["font"] )
			end



			--osc
			
			local osc = string.format("%.0f", selects[i]["osc"])
			local oscX = baseX + 150 * generalSettings["font"] -- - 12 * 3
			local oscY = baseY + lineHeight * 1
			
			if selects[i]['current'] == 'osc' and activeSelectIndex == i then
				ofSetColor(255, 0, 255, 255)
			elseif previewParameter and previewParameter.type == 'select' and previewParameter.target == i and previewParameter.param == 'osc' then
				ofSetColor(0, 255, 0, 255) -- Желтый цвет для предварительного просмотра
			else
				ofSetColor(255, 0, 0, 255)
			end

			title:drawString(osc, oscX, oscY)
			if activeSelectIndex == i then
				smalltext:drawString('osc', oscX, oscY + 12 * generalSettings["font"] )
			end

			


		end
	end
end
