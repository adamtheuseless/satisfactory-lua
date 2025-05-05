require("Rect")

------------------------------------------------------------------------
-- Margin / Padding Helpers
------------------------------------------------------------------------

---Gets a Margin with all values identical.
---@param value number
---@return Margin
function GetUniformMargin(value)
	return {left = value, top = value, right = value, bottom = value}
end

------------------------------------------------------------------------
-- Radius Helpers
------------------------------------------------------------------------

---Gets a Vector4 with all values identical.
---@param value number
---@return Vector4
function GetUniformRadius(value)
	return {w = value, x = value, y = value, z = value}
end

------------------------------------------------------------------------
-- GPU Methods
------------------------------------------------------------------------

---Pushes rectangular layout and clipping mask to a GPU T2
---@param gpu FINComputerGPUT2
---@param rectangle Rect
function PushRect(gpu, rectangle)
	gpu:pushLayout(rectangle:getLocation(), rectangle:getSize(), 1)
	gpu:pushClipRect({x = 0, y = 0}, rectangle:getSize())
end

---Pops the last layout and clipping mask from a GPU T2
---@param gpu FINComputerGPUT2
function PopRect(gpu)
	gpu:PopGeometry()
	gpu:popClip()
end

------------------------------------------------------------------------
-- Text Drawing
------------------------------------------------------------------------

TEXT_ALIGNMENT = {
	near   = 0,
	middle = 1,
	far    = 2
}

---Returns the actual width of the provided text and the height of a fixed string to correct for vertical drift.
---@param gpu FINComputerGPUT2
---@param text string
---@param size number
---@param monospace boolean
---@return Vector2D
function MeasureText(gpu, text, size, monospace)
	local x = gpu:measureText(text, size, monospace).x
	local y = gpu:measureText("Wg", size, monospace).y
	return {x = x, y = y}
end

---@param gpu FINComputerGPUT2
---@param bounds Rect
---@param text string
---@param size number
---@param monospace boolean
---@param foreColor Color
---@param horizontalAlignment number|nil @near = left, middle = center, far = right
---@param verticalAlignment	number|nil   @near = top, middle = middle, far = bottom
---@param margin Margin|nil
function DrawBoundText(gpu, bounds, text, size, monospace, foreColor, horizontalAlignment, verticalAlignment, margin)
	if margin then
		bounds = Rect.fromRectAndMargin(bounds, margin)
	end

	local x, y, width, height = 0, 0, bounds.width, bounds.height
	local textSize = MeasureText(gpu, text, size, monospace)

	PushRect(gpu, bounds)

	if horizontalAlignment == TEXT_ALIGNMENT.middle then
		x = x + (width - textSize.x) / 2
	elseif horizontalAlignment == TEXT_ALIGNMENT.far then
		x = x + width - textSize.x
	end

	if verticalAlignment == TEXT_ALIGNMENT.middle then
		y = y + (height - textSize.y) / 2
	elseif verticalAlignment == TEXT_ALIGNMENT.far then
		y = y + height - textSize.y
	end

	gpu:drawText({x = x, y = y}, text, size, foreColor, monospace)

	PopRect(gpu)
end

---@param gpu FINComputerGPUT2
---@param bounds Rect
---@param text string
---@param size number
---@param monospace boolean
---@param backColor Color
---@param foreColor Color
---@param borderColor Color
---@param borderThickness number
---@param cornerRadius number|nil
---@param horizontalAlignment number|nil @near = left, middle = center, far = right
---@param verticalAlignment	number|nil   @near = top, middle = middle, far = bottom
---@param padding Margin|nil @Margin outside the border
---@param margin Margin|nil @Margin inside the border
function DrawTextBox(gpu, bounds, text, size, monospace, foreColor, backColor, borderColor, borderThickness, cornerRadius, horizontalAlignment, verticalAlignment, padding, margin)
	local textBounds = DrawOutline(gpu, bounds, backColor, borderColor, borderThickness, cornerRadius, padding)
	DrawBoundText(gpu, textBounds, text, size, monospace, foreColor, horizontalAlignment, verticalAlignment, margin)
end

------------------------------------------------------------------------
-- Box Drawing
------------------------------------------------------------------------

---@param gpu FINComputerGPUT2
---@param bounds Rect
---@param backColor Color
---@param borderColor Color
---@param borderThickness number
---@param cornerRadius number|nil
---@param margin Margin|nil
---@return Rect @The interior bounds of this outline
function DrawOutline(gpu, bounds, backColor, borderColor, borderThickness, cornerRadius, margin)
	if margin then
		bounds = Rect.fromRectAndMargin(bounds, margin)
	end

	cornerRadius = cornerRadius or 0

	---@type GPUT2DrawCallBox
	local args = {
		position = bounds:getLocation(),
		size = bounds:getSize(),
		rotation = 0,
		color = backColor,
		image = "",
		imageSize = {x = 0, y = 0},
		hasCenteredOrigin = false,
		horizontalTiling = false,
		verticalTiling = false,
		isBorder = false,
		margin = {left = 0, top = 0, right = 0, bottom = 0},
		isRounded = cornerRadius > 0,
		radii = {w = cornerRadius, x = cornerRadius, y = cornerRadius, z = cornerRadius},
		hasOutline = true,
		outlineThickness = borderThickness,
		outlineColor = borderColor
	}

	gpu:drawBox(args)

	return bounds:inflateScalar(borderThickness * -1)
end

print("Loaded GPUT2_Library")