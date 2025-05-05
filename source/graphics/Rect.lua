RECT_CORNERS = {
	topLeft = 1,
	topRight = 2,
	bottomRight = 3,
	bottomLeft = 4
}

---@class Rect
---@field public x number
---@field public y number
---@field public width number
---@field public height number
local Rect = {}

---@param x number
---@param y number
---@param width number
---@param height number
---@return Rect
local function getRectCore(x, y, width, height)
    local result = {
        x = x,
        y = y,
        width = width,
        height = height,
        getLocation = Rect.getLocation,
        getSize = Rect.getSize,
        getCorner = Rect.getCorner,
        offset = Rect.offset,
        inflateScalar = Rect.inflateScalar,
        inflate = Rect.inflate,
        resize = Rect.resize,
        toString = Rect.toString
    }
    return result
end

---Gets a Rect from x/y and width/height
---@param x number
---@param y number
---@param width number
---@param height number
---@return Rect
function Rect.fromNumbers(x, y, width, height)
	return getRectCore(x, y, width, height)
end

---Gets a Rect from location and size Vector2D
---@param location Vector2D
---@param size Vector2D
---@return Rect
function Rect.fromVectors(location, size)
	return getRectCore(location.x, location.y, size.x, size.y)
end

---Gets a new Rect from a base Rect and margins
---@param baseRect Rect
---@param margin Margin
---@return Rect
function Rect.fromRectAndMargin(baseRect, margin)
	local x, y, width, height = baseRect.x, baseRect.y, baseRect.width, baseRect.height

	if margin then
		x = x + margin.left
		y = y + margin.top
		width = width - margin.left - margin.right
		height = height - margin.top - margin.bottom
	end

	return getRectCore(x, y, width, height)
end

---Gets the location Vector2D of this Rect
---@param self Rect
---@return Vector2D
function Rect.getLocation(self)
	return {x = self.x, y = self.y}
end

---Gets the size Vector2D of this Rect
---@param self Rect
---@return Vector2D
function Rect.getSize(self)
	return {x = self.width, y = self.height}
end

---Gets a Vector2D representing the specified corner
---@param self Rect
---@param corner number @1 - Top Left (default), 2 - Top Right, 3 - Bottom Right, 4 - Bottom Left
---@return Vector2D
function Rect.getCorner(self, corner)
    local x, y, width, height = self.x, self.y, self.width, self.height

    if corner == RECT_CORNERS.topRight then
		x = x + width
	elseif corner == RECT_CORNERS.bottomRight then
		x = x + width
		y = y + height
	elseif corner == RECT_CORNERS.bottomLeft then
		y = y + height
	end

    return {x = x, y = y}
end

---Gets a new Rect with location moved based on the provided offset Vector2D
---@param self Rect
---@param value Vector2D
---@return Rect
function Rect.offset(self, value)
	return Rect.fromNumbers(self.x + value.x, self.y + value.y, self.width, self.height)
end

---Gets a new Rect with size modified based on the provided offset value. Moves all edges uniformly.
---@param self Rect
---@param value number
---@return Rect
function Rect.inflateScalar(self, value)
	local x, y, width, height = self.x, self.y, self.width, self.height

    x = x - value
	y = y - value
	width = width + (value * 2)
	height = height + (value * 2)

	return Rect.fromNumbers(x, y, width, height)
end

---Gets a new Rect with size modified based on the provided offset Vector2D. Moves opposite edges uniformly.
---@param self Rect
---@param value Vector2D
---@param deflate boolean|nil @If true, positive values in the Vector2D move edges inward.
---@return Rect
function Rect.inflate(self, value, deflate)
	local x, y, width, height = self.x, self.y, self.width, self.height

	if deflate ~= nil and deflate == true then
		x = x + value.x
		y = y + value.y
		width = width - (value.x * 2)
		height = height - (value.y * 2)
	else
		x = x - value.x
		y = y - value.y
		width = width + (value.x * 2)
		height = height + (value.y * 2)
	end

	return Rect.fromNumbers(x, y, width, height)
end

---Gets a new Rect with size modified based on the provided offset Vector2D. Moves edges opposite the the provided corner only.
---@param self Rect
---@param value Vector2D
---@param corner number|nil @The corner to lock for resizing. 1 - Top Left (default), 2 - Top Right, 3 - Bottom Right, 4 - Bottom Left
---@return Rect
function Rect.resize(self, value, corner)
	local x, y, width, height = table.unpack(self)

	width = width + value.x
	height = height + value.y

	if corner == RECT_CORNERS.topRight then
		x = x + value.x
	elseif corner == RECT_CORNERS.bottomRight then
		x = x + value.x
		y = y + value.y
	elseif corner == RECT_CORNERS.bottomLeft then
		y = y + value.y
	end

	return Rect.fromNumbers(x, y, width, height)
end

---@param self Rect
---@return string
function Rect.toString(self)
    local result = "Rect("
    result = result .. "x = "      .. self.x      .. ", "
    result = result .. "y = "      .. self.y      .. ", "
    result = result .. "width = "  .. self.width  .. ", "
    result = result .. "height = " .. self.height .. ")"
    return result
end

return Rect