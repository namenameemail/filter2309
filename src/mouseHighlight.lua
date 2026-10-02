-- mouseHighlight.lua
-- Утилиты для отрисовки кругов рядом с курсором мыши
MouseHighlight = {}

-- Состояние кругов (включены/выключены)


MouseHighlight.circles = {red = false, green = false,blue = false}


-- Позиция курсора
MouseHighlight.mouseX = 0
MouseHighlight.mouseY = 0

-- Размеры кругов
MouseHighlight.circleRadius = 40
MouseHighlight.circleOffset = 30  -- расстояние от курсора до круга

-- Цвета кругов
MouseHighlight.colors = {red = {255, 0, 0, 255},green = {0, 255, 0, 255},blue = {0, 0, 255, 255}}

-- Состояние диаметров
MouseHighlight.diameters = {visible = false,angle = 0,duration = 0.5, startTime = 0, radius = 50}

-- Функция для обновления позиции курсора
function MouseHighlight.updateMousePosition(x, y)
    MouseHighlight.mouseX = x
    MouseHighlight.mouseY = y
end

-- Функция для включения/выключения круга
function MouseHighlight.toggleCircle(button)
    if MouseHighlight.circles[button] ~= nil then
        MouseHighlight.circles[button] = not MouseHighlight.circles[button]
        print("Circle " .. button .. " is now " .. (MouseHighlight.circles[button] and "ON" or "OFF"))
    else
        print("Invalid button: " .. tostring(button) .. ". Use 'red', 'green', or 'blue'")
    end
end

-- Функция для установки состояния круга
function MouseHighlight.setCircle(button, enabled)
    if MouseHighlight.circles[button] ~= nil then
        MouseHighlight.circles[button] = enabled
        print("Circle " .. button .. " is now " .. (enabled and "ON" or "OFF"))
    else
        print("Invalid button: " .. tostring(button) .. ". Use 'red', 'green', or 'blue'")
    end
end

-- Функция для включения всех кругов
function MouseHighlight.enableAllCircles()
    MouseHighlight.circles.red = true
    MouseHighlight.circles.green = true
    MouseHighlight.circles.blue = true
    print("All circles enabled")
end

-- Функция для выключения всех кругов
function MouseHighlight.disableAllCircles()
    MouseHighlight.circles.red = false
    MouseHighlight.circles.green = false
    MouseHighlight.circles.blue = false
    print("All circles disabled")
end

-- Функция для установки размера кругов
function MouseHighlight.setCircleRadius(radius)
    MouseHighlight.circleRadius = radius
    print("Circle radius set to " .. radius)
end

-- Функция для установки расстояния от курсора
function MouseHighlight.setCircleOffset(offset)
    MouseHighlight.circleOffset = offset
    print("Circle offset set to " .. offset)
end

-- Функция для показа диаметров с поворотом угла
function MouseHighlight.showDiameters(a)
    MouseHighlight.diameters.visible = true
    MouseHighlight.diameters.startTime = ofGetElapsedTimef()
    -- Поворачиваем угол на 45 градусов при каждом вызове
    MouseHighlight.diameters.angle = (MouseHighlight.diameters.angle + 10 * a) % 360
end

-- Функция для установки времени показа диаметров
function MouseHighlight.setDiametersDuration(duration)
    MouseHighlight.diameters.duration = duration
    print("Diameters duration set to " .. duration .. " seconds")
end

-- Функция для установки радиуса диаметров
function MouseHighlight.setDiametersRadius(radius)
    MouseHighlight.diameters.radius = radius
    print("Diameters radius set to " .. radius)
end

-- Функция для проверки, нужно ли скрыть диаметры
function MouseHighlight.updateDiameters()
    if MouseHighlight.diameters.visible then
        local currentTime = ofGetElapsedTimef()
        if currentTime - MouseHighlight.diameters.startTime >= MouseHighlight.diameters.duration then
            MouseHighlight.diameters.visible = false
        end
    end
end

-- Функция для отрисовки кругов
function MouseHighlight.draw(smalltext)
    -- Обновляем состояние диаметров
    MouseHighlight.updateDiameters()
    
    -- Включаем альфа-блендинг для прозрачности
    ofEnableAlphaBlending()
    
    -- Отрисовываем красный круг (левая кнопка) - слева от курсора
    if MouseHighlight.circles.red then
        ofSetColor(MouseHighlight.colors.red[1], MouseHighlight.colors.red[2],MouseHighlight.colors.red[3], MouseHighlight.colors.red[4])
        ofFill()
        ofDrawCircle(MouseHighlight.mouseX + MouseHighlight.circleOffset,MouseHighlight.mouseY, MouseHighlight.circleRadius)
    end
    
    -- Отрисовываем зеленый круг (средняя кнопка) - сверху от курсора
    if MouseHighlight.circles.green then
        ofSetColor(MouseHighlight.colors.green[1], MouseHighlight.colors.green[2],MouseHighlight.colors.green[3], MouseHighlight.colors.green[4])
        ofFill()
        ofDrawCircle(MouseHighlight.mouseX, MouseHighlight.mouseY - MouseHighlight.circleOffset, MouseHighlight.circleRadius)
    end
    
    -- Отрисовываем синий круг (правая кнопка) - справа от курсора
    if MouseHighlight.circles.blue then
        ofSetColor(MouseHighlight.colors.blue[1], MouseHighlight.colors.blue[2], MouseHighlight.colors.blue[3], MouseHighlight.colors.blue[4])
        ofFill()
        ofDrawCircle(MouseHighlight.mouseX - MouseHighlight.circleOffset, MouseHighlight.mouseY, MouseHighlight.circleRadius)
    end
    
    -- Отрисовываем диаметры, если они видимы
    if MouseHighlight.diameters.visible then
        ofSetColor(255, 0, 255, 255) -- зеленый цвет с прозрачностью
        ofSetLineWidth(3)
        ofNoFill()
        
        -- Конвертируем угол из градусов в радианы
        local angleRad = math.rad(MouseHighlight.diameters.angle)
        local radius = MouseHighlight.diameters.radius

        local centerX = MouseHighlight.mouseX
        local centerY = MouseHighlight.mouseY - MouseHighlight.circleOffset
        
        -- Вычисляем координаты концов диаметров
        local cosAngle = math.cos(angleRad)
        local sinAngle = math.sin(angleRad)
        
        -- Первый диаметр (горизонтальный с поворотом)
        local x1 = centerX - radius * cosAngle
        local y1 = centerY - radius * sinAngle
        local x2 = centerX + radius * cosAngle
        local y2 = centerY + radius * sinAngle
        ofDrawLine(x1, y1, x2, y2)
        
        -- Второй диаметр (перпендикулярный первому)
        local x3 = centerX - radius * sinAngle
        local y3 = centerY + radius * cosAngle
        local x4 = centerX + radius * sinAngle
        local y4 = centerY - radius * cosAngle
        ofDrawLine(x3, y3, x4, y4)
    end
    
    -- Отрисовываем легенду в правом нижнем углу
    MouseHighlight.drawLegend(smalltext)
    
    -- Отключаем альфа-блендинг
    ofDisableAlphaBlending()
end

-- Функция для отрисовки легенды в правом нижнем углу
function MouseHighlight.drawLegend(smalltext)
    local screenWidth = ofGetWidth()
    local screenHeight = ofGetHeight()
    
    -- Параметры легенды
    local legendX = screenWidth - 150 * generalSettings["font"]    -- отступ от правого края
    local legendY = screenHeight - 120 * generalSettings["font"] -- отступ от нижнего края
    local circleSize = 10 * generalSettings["font"]                -- размер кругов в легенде
    local lineHeight = 25 * generalSettings["font"]              -- высота строки
    local textOffset = 20 * generalSettings["font"]               -- отступ текста от кругов
    
    -- Включаем альфа-блендинг для текста
    ofEnableAlphaBlending()
    
    -- Устанавливаем цвет текста (белый)
    ofSetColor(0,0,0, 255)
    
    -- Отрисовываем красный круг (правая кнопка)
    ofSetColor(MouseHighlight.colors.red[1], MouseHighlight.colors.red[2], MouseHighlight.colors.red[3], MouseHighlight.colors.red[4])
    ofFill()
    ofDrawCircle(legendX, legendY, circleSize)
    
    -- Текст для красного круга
    ofSetColor(0,0,0, 255)
    smalltext:drawString("right button", legendX + textOffset, legendY + 5)
    
    -- Отрисовываем зеленый круг (средняя кнопка)
    ofSetColor(MouseHighlight.colors.green[1], MouseHighlight.colors.green[2], MouseHighlight.colors.green[3], MouseHighlight.colors.green[4])
    ofFill()
    ofDrawCircle(legendX, legendY + lineHeight, circleSize)
    
    -- Текст для зеленого круга
    ofSetColor(0,0,0, 255)
    smalltext:drawString("wheel button", legendX + textOffset, legendY + lineHeight + 5)
    
    -- Отрисовываем синий круг (левая кнопка)
    ofSetColor(MouseHighlight.colors.blue[1], MouseHighlight.colors.blue[2], MouseHighlight.colors.blue[3], MouseHighlight.colors.blue[4])
    ofFill()
    ofDrawCircle(legendX, legendY + lineHeight * 2, circleSize)
    
    -- Текст для синего круга
    ofSetColor(0,0,0, 255)
    smalltext:drawString("left button", legendX + textOffset, legendY + lineHeight * 2 + 5)
    
    -- Отрисовываем крест (диаметры)
    ofSetColor(255, 0, 255, 200) -- тот же цвет, что и у диаметров
    ofSetLineWidth(1.5 * generalSettings["font"])
    ofNoFill()
    
    local crossX = legendX
    local crossY = legendY + lineHeight * 3
    local crossSize = circleSize
    
    -- Горизонтальная линия креста
    ofDrawLine(crossX - crossSize, crossY, crossX + crossSize, crossY)
    -- Вертикальная линия креста
    ofDrawLine(crossX, crossY - crossSize, crossX, crossY + crossSize)
    
    -- Текст для креста
    ofSetColor(0,0,0, 255)
    smalltext:drawString("wheel scroll", legendX + textOffset, crossY + 5)

    ofSetLineWidth(1)
end

-- Функция для получения информации о состоянии
function MouseHighlight.getStatus()
    local status = "Mouse Highlight Status:\n"
    status = status .. "Red circle (left button): " .. (MouseHighlight.circles.red and "ON" or "OFF") .. "\n"
    status = status .. "Green circle (middle button): " .. (MouseHighlight.circles.green and "ON" or "OFF") .. "\n"
    status = status .. "Blue circle (right button): " .. (MouseHighlight.circles.blue and "ON" or "OFF") .. "\n"
    status = status .. "Circle radius: " .. MouseHighlight.circleRadius .. "\n"
    status = status .. "Circle offset: " .. MouseHighlight.circleOffset .. "\n"
    status = status .. "Diameters visible: " .. (MouseHighlight.diameters.visible and "YES" or "NO") .. "\n"
    status = status .. "Diameters angle: " .. MouseHighlight.diameters.angle .. " degrees\n"
    status = status .. "Diameters duration: " .. MouseHighlight.diameters.duration .. " seconds\n"
    status = status .. "Diameters radius: " .. MouseHighlight.diameters.radius .. "\n"
    status = status .. "Mouse position: (" .. MouseHighlight.mouseX .. ", " .. MouseHighlight.mouseY .. ")"
    return status
end

-- Функция для печати статуса в консоль
function MouseHighlight.printStatus()
    print(MouseHighlight.getStatus())
end

