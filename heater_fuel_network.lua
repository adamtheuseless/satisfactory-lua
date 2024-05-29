-- If heater fuel level is less than or equal to this value, release more fuel
FuelTransferThreshold = 1

-- Heater Functions
-- :getFuelAmount()
-- :getCurrentHeat() returns heat in degrees C
-- :getCO2Amount()

OutputSplitters = component.proxy(component.findComponent("HeaterInput"))
InputSplitter = component.proxy(component.findComponent("FuelInput"))[1]

Heaters = {}
Routings = {}

function GetHeater(splitter, outputIndex)
	local connector0 = splitter:getFactoryConnectors()[outputIndex] --splitter output connector
	local connector1 = connector0:getConnected() --belt input connector

	if connector1 == nil then
		return nil, nil
	else
		local belt = connector1.owner
		local connector2 = belt:getFactoryConnectors()[2] --belt output connector
		local connector3 = connector2:getConnected() --heater input connector
		local heater = connector3.owner

		return connector0, heater
	end
end

function InitializeFuelNetwork()
    for _, splitter in pairs(OutputSplitters) do
        event.listen(splitter)

        local key, heaterL = GetHeater(splitter, 1) --left
        if heaterL ~= nil then
			Heaters[key] = heaterL
            event.listen(heaterL)
        end

        local key, heaterR = GetHeater(splitter, 3) --right
        if heaterR ~= nil then
			Heaters[key] = heaterL
            event.listen(heaterR)
        end

        Routings[splitter] = {heaterL, heaterR}
    end
end

function IsAnyHeaterUnderThreshold()
	for _, heater in pairs(Heaters) do
		if heater:getFuelAmount() <= FuelTransferThreshold then
			return true
		end
	end
	return false
end

function PurgeOutputSplitters()
    for _, splitter in pairs(OutputSplitters) do
        repeat
            splitter:transferItem(1)
        until splitter:getInput().name == nil
    end
end

function RouteOutputSplitter(splitter)
	for key, values in pairs(Routings) do
		if key == splitter then
			local left = values[1]
			local right = values[2]

			if left ~= nil and left:getFuelAmount() <= FuelTransferThreshold then
				print("Route Fuel Left", splitter:transferItem(0))
			elseif right ~= nil and right:getFuelAmount() <= FuelTransferThreshold then
				print("Route Fuel Right", splitter:transferItem(2))
			else
				print("Pass Fuel Through", splitter:transferItem(1))
			end

            return true
		end
	end
end
