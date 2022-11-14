--[[
MIT License

Copyright (c) 2022 Urdons

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]

local rs = game:GetService("ReplicatedStorage")
local cs = game:GetService("CollectionService")
local uip = game:GetService("UserInputService")
local m = game:GetService("Players").LocalPlayer:GetMouse()
local runs = game:GetService("RunService")
local ss = game:GetService("SoundService")

local t = require(rs.Theme)

local root
local mouseState = false

--default theme
local Defaults = {
	["AlignX"] = "Left",
	["AlignY"] = "Top",
	["Position"] = UDim2.new(0, 0, 0, 0),
	["Size"] = UDim2.new(0, 100, 0, 100),
	["Theme"] = {
		["Margin"] = 4,
		["BorderRadius"] = 8,
		["Frame"] = {
			["BackgroundColor3"] = Color3.fromHex("#222222"),
			["BackgroundTransparency"] = 0,
		},
		["Text"] = {
			["BackgroundColor3"] = Color3.fromHex("#000000"),
			["BackgroundTransparency"] = 1,
			["TextColor3"] = Color3.fromHex("#dddddd"),
			["Font"] = Enum.Font.SourceSans,
			["TextSize"] = 18,
		},
		["Image"] = {
			["BackgroundColor3"] = Color3.fromHex("#222222"),
			["BackgroundTransparency"] = 0,
			["Image"] = "rbxassetid://8036970459",
		},
		["Button"] = {
			["Normal"] = {
				["BackgroundColor3"] = Color3.fromHex("#111111"),
				["BackgroundTransparency"] = 0,
			},
			["Hover"] = {
				["BackgroundColor3"] = Color3.fromHex("#333333"),
				["BackgroundTransparency"] = 0,
			},
			["Click"] = {
				["BackgroundColor3"] = Color3.fromHex("#dddddd"),
				["BackgroundTransparency"] = 0,
			},
		},	
	},
}

local module = {}

function module.New (element : string, args)
	local new
	
	if element == "root" then
		root = args
	end
	
	--basic setup that all objects go through
	local function Setup (new, args)
		new.Parent = args.Parent
		new.Name = args.Name or "element"
		new.Position = Defaults.Position
		new.Size = Defaults.Size
		cs:AddTag(new, "UI")
		
		new:SetAttribute("AlignX", args.AlignX or Defaults.AlignX)
		new:SetAttribute("AlignY", args.AlignY or Defaults.AlignY)
		new:SetAttribute("Position", args.Position or Defaults.Position)
		new:SetAttribute("Size", args.Size or Defaults.Size)
		new:SetAttribute("AspectRatio", args.AspectRatio or Vector2.new(1, 1))
		new:SetAttribute("ForceAspectRatio", args.ForceAspectRatio or false)
		new:SetAttribute("Order", args.Order or "Horizontal")
		
		local corner = Instance.new("UICorner")
		corner.Parent = new
		corner.CornerRadius = UDim.new(0, Defaults.Theme.BorderRadius)
	end
	
	--basic types
	local function Frame (args)
		local new
		new = Instance.new("Frame")
		Setup(new, args)
		cs:AddTag(new, "Frame")
		
		--properties
		new:SetAttribute("BackgroundColor3", Defaults.Theme.Frame.BackgroundColor3)
		new:SetAttribute("BackgroundTransparency", args.BackgroundTransparency or Defaults.Theme.Frame.BackgroundTransparency)
		
		return new
	end
	
	local function Text (args)
		local new
		new = Instance.new("TextLabel")
		Setup(new, args)
		cs:AddTag(new, "Text")
		
		--properties
		new:SetAttribute("BackgroundColor3", Defaults.Theme.Text.BackgroundColor3)
		new:SetAttribute("BackgroundTransparency", args.BackgroundTransparency or Defaults.Theme.Text.BackgroundTransparency)
		new:SetAttribute("TextColor3", Defaults.Theme.Text.TextColor3)
		new.Font = Defaults.Theme.Text.Font
		new:SetAttribute("TextSize", Defaults.Theme.Text.TextSize)
		
		return new
	end
	
	local function Image (args)
		local new
		new = Instance.new("ImageLabel")
		Setup(new, args)
		new.Image = args.Image or Defaults.Theme.Image.Image
		cs:AddTag(new, "Image")

		--properties
		new:SetAttribute("BackgroundColor3", Defaults.Theme.Image.BackgroundColor3)
		new:SetAttribute("BackgroundTransparency", args.BackgroundTransparency or Defaults.Theme.Image.BackgroundTransparency)
		
		return new
	end
	
	local function Group (args)
		local new
		new = Instance.new("CanvasGroup")
		Setup(new, args)
		cs:AddTag(new, "Group")

		--properties
		new:SetAttribute("BackgroundColor3", Defaults.Theme.Frame.BackgroundColor3)
		new:SetAttribute("BackgroundTransparency", args.BackgroundTransparency or Defaults.Theme.Frame.BackgroundTransparency)
		
		return new
	end
	
	if element == "Frame" then new = Frame(args) end
	
	if element == "Text" then new = Text(args) end
	
	if element == "Image" then new = Image(args) end
	
	if element == "Group" then new = Group(args) end
	
	--Advanced Types
	local function Button (args)
		--actual button
		local new = Frame(args)
		cs:AddTag(new, "Button")

		--it's event
		local event = Instance.new("BindableEvent")
		event.Parent = new
		event.Name = "Event"

		--properties	
		new:SetAttribute("Hover", false)
		new:SetAttribute("Click", false)

		new:SetAttribute("NormalColor3", Defaults.Theme.Button.Normal.BackgroundColor3)
		new:SetAttribute("NormalTransparency", args.BackgroundTransparency or Defaults.Theme.Button.Normal.BackgroundTransparency)
		new:SetAttribute("HoverColor3", Defaults.Theme.Button.Hover.BackgroundColor3)
		new:SetAttribute("HoverTransparency", args.BackgroundTransparency or Defaults.Theme.Button.Hover.BackgroundTransparency)
		new:SetAttribute("ClickColor3", Defaults.Theme.Button.Click.BackgroundColor3)
		new:SetAttribute("ClickTransparency", args.BackgroundTransparency or Defaults.Theme.Button.Click.BackgroundTransparency)
		
		return new
	end
	
	if element == "Button" then new = Button(args) end
	
	if element == "ImgButton" then
		--actual button
		new = Button(args)
		
		local image = Image({Name = "Image", Parent = new})
	end
	
	if element == "TextButton" then
		--actual button
		new = Button(args)

		local text = Text({Name = "Text", Parent = new})
	end
	
	if element == "ImgAndTextButton" then
		--actual button
		new = Button(args)
		
		local image = Image({Name = "Image", Parent = new, XAlign = "Left", ForceAspectRatio = true, Size = args.Size})
		local text = Text({Name = "Text", Parent = new, XAlign = "Right", Size = args.Size})
	end
	
	return new
end

function module.Update (step)
	if typeof(step) ~= "number" then step = 0 end --make sure step is real, if not, get real
	
	local roots = {root} --setup loop with the root object
	while true do
		local elements = {}
		--go through all the roots
		for j, r in ipairs(roots) do
			elements[j] = {}
			--go through and filter out the UI stuff
			for k, child in ipairs(r:GetChildren()) do
				if cs:HasTag(child, "UI") then
					table.insert(elements[j], child)
				end
			end
			if #elements[j] == 0 then elements[j] = nil end
		end
		if #elements == 0 then break end --if there are none then kill the loop
		--reset stuff (so it loops)
		roots = {}
		
		--do the checks
		for i, e in ipairs(elements) do --iterate through the different lists
			local bounds = {
				["X"] = {
					["Left"] = Defaults.Theme.Margin, 
					["Right"] = e[1].Parent.AbsoluteSize.X - Defaults.Theme.Margin
				},
				["Y"] = {
					["Left"] = Defaults.Theme.Margin, 
					["Right"] = e[1].Parent.AbsoluteSize.Y - Defaults.Theme.Margin
				}
			}
			
			for j, element in ipairs(e) do
				table.insert(roots, element)
				
				local margin = Defaults.Theme.Margin
				local position = element:GetAttribute("Position")
				local size = element:GetAttribute("Size")
				local alignX = element:GetAttribute("AlignX")
				local alignY = element:GetAttribute("AlignY")
				local aspectRatio = element:GetAttribute("AspectRatio")
				
				local function horizontalAlign (xPosition, yPosition, xSize, ySize)
					local horizontalPosition = 0
					local horizontalSize = 0
					
					if alignX == "Left" or alignX == "Top" then
						--predict left bound of object

						local elementLeftBound
						if yPosition < bounds.Y.Left or yPosition > bounds.Y.Right and xPosition < bounds.X.Left then
							elementLeftBound = bounds.X.Left + xPosition
						else
							elementLeftBound = xPosition + margin
						end

						--constrain size to parent object

						local elementRightBound = (bounds.X.Left + xPosition) + xSize --right side of element
						--if the element's right bound extends past the right bound then
						if elementRightBound > bounds.X.Right then
							horizontalSize = xSize + (bounds.X.Right - elementRightBound) --constrain it
						else
							horizontalSize = xSize --if not do nothing
						end

						--update position

						horizontalPosition = bounds.X.Left + xPosition
					end
					if alignX == "Center" then
						--constrain size to parent object

						local parentSize = bounds.X.Right - bounds.X.Left --available space left in parent object
						--if the element's right bound extends past the right bound then
						if xPosition + xSize > bounds.X.Right or xPosition < bounds.X.Left then
							horizontalSize = xSize + (bounds.X.Right - parentSize) --constrain it
						else
							horizontalSize = xSize --if not do nothing
						end

						--update position

						horizontalPosition = parentSize / 2 - xSize / 2
					end
					if alignX == "Right" or alignX == "Bottom" then
						--predict left bound of object

						local elementLeftBound
						if yPosition < bounds.Y.Left or yPosition > bounds.Y.Right and xPosition > bounds.X.Right then
							elementLeftBound = bounds.X.Left + xPosition
						else
							elementLeftBound = xPosition - margin
						end

						--constrain size to parent object

						local elementRightBound = (bounds.X.Left + xPosition) + xSize --right side of element
						--if the element's right bound extends past the right bound then
						if elementRightBound > bounds.X.Right then
							horizontalSize = xSize + (bounds.X.Right - elementRightBound) --constrain it
						else
							horizontalSize = xSize --if not do nothing
						end

						--update position

						horizontalPosition = xPosition - margin - xSize + bounds.X.Right
					end
					
					return horizontalPosition, horizontalSize
				end
				
				local function verticalAlign (xPosition, yPosition, xSize, ySize)
					local verticalPosition = 0
					local verticalSize = 0
					
					if alignY == "Top" or alignY == "Left" then
						--predict left bound of object

						local elementTopBound
						if xPosition < bounds.X.Left or xPosition > bounds.X.Right and yPosition < bounds.Y.Left then
							elementTopBound = bounds.Y.Left + yPosition
						else
							elementTopBound = yPosition + margin
						end

						--constrain size to parent object
						
						local elementBottomBound = elementTopBound + ySize --right side of element
						--if the element's right bound extends past the right bound then
						if elementBottomBound > bounds.Y.Right then
							verticalSize = ySize + (bounds.Y.Right - elementBottomBound) --constrain it
						else
							verticalSize = ySize --if not do nothing
						end

						--update position

						verticalPosition = elementTopBound
					end
					if alignY == "Center" then
						--constrain size to parent object

						local parentSize = bounds.Y.Right - bounds.Y.Left --available space left in parent object
						--if the element's right bound extends past the right bound then
						if yPosition + ySize > bounds.Y.Right or yPosition < bounds.Y.Left then
							verticalSize = ySize + (bounds.Y.Right - parentSize) --constrain it
						else
							verticalSize = ySize --if not do nothing
						end

						--update position

						verticalPosition = parentSize / 2 - ySize / 2 + yPosition
					end
					if alignY == "Bottom" or alignY == "Right" then
						--predict left bound of object

						local elementTopBound
						if xPosition < bounds.X.Left or xPosition > bounds.X.Right and yPosition > bounds.Y.Right then
							elementTopBound = bounds.Y.Left + yPosition
						else
							elementTopBound = yPosition - margin
						end

						--constrain size to parent object

						local elementBottomBound = elementTopBound + ySize --right side of element
						--if the element's right bound extends past the right bound then
						if elementBottomBound > bounds.Y.Right then
							verticalSize = ySize + (bounds.Y.Right - elementBottomBound) --constrain it
						else
							verticalSize = ySize --if not do nothing
						end

						--update position

						verticalPosition = elementTopBound - margin - ySize
					end
					
					return verticalPosition, verticalSize
				end
				
				local xp, xs, yp, ys
				if element.Parent:GetAttribute("Order") == "Vertical" then
					yp, ys = verticalAlign(position.X.Offset, position.Y.Offset, size.X.Offset, size.Y.Offset)
					xp, xs = horizontalAlign(position.X.Offset, yp, size.X.Offset, ys)
				else
					xp, xs = horizontalAlign(position.X.Offset, position.Y.Offset, size.X.Offset, size.Y.Offset)
					yp, ys = verticalAlign(xp, position.Y.Offset, xs, size.Y.Offset)
				end
				
				print(element.Parent:GetAttribute("Order"))
				
				if element:GetAttribute("ForceAspectRatio") then
					if xs < ys then
						ys = xs * (aspectRatio.X / aspectRatio.Y)
					else
						xs = ys * (aspectRatio.X / aspectRatio.Y)
					end
				end
				
				--update bounds
				if alignX == "Left" or alignX == "Top" then
					bounds.X.Left = bounds.X.Left + xs + margin
				end
				if alignX == "Right" or alignX == "Bottom" then
					bounds.X.Right = bounds.X.Right - xs - margin
				end
				if alignY == "Left" or alignY == "Top" then
					bounds.Y.Left = bounds.Y.Left + ys + margin
				end
				if alignY == "Right" or alignY == "Bottom" then
					bounds.Y.Right = bounds.Y.Right - ys - margin
				end
	
				element.Position = UDim2.fromOffset(xp, yp)
				element.Size = UDim2.fromOffset(xs, ys)
				
				if cs:HasTag(element, "Text") then
					element.TextColor3 = element:GetAttribute("TextColor3")
					element.TextSize = element:GetAttribute("TextSize")
				end
				
				element.BackgroundTransparency = element:GetAttribute("BackgroundTransparency")
				element.BackgroundColor3 = element.BackgroundColor3:Lerp(element:GetAttribute("BackgroundColor3"), step * 15)
				--TODO: Find a better way to do this
				
				--[[
				button Stuff
				--]]
				if cs:HasTag(element, "Button") then
					--hover logic
					if --mouse collision checks (basic box collision thing)
						element.AbsolutePosition.X < m.X and 
						element.AbsolutePosition.X + element.AbsoluteSize.X > m.X
						and
						element.AbsolutePosition.Y < m.Y and 
						element.AbsolutePosition.Y + element.AbsoluteSize.Y > m.Y
					then
						if not element:GetAttribute("Hover") then
							ss.hover:Play()
						end
						--mouse is hovering
						element:SetAttribute("Hover", true)
					else
						if element:GetAttribute("Hover") then
							ss.off:Play()
						end
						--mouse is not hovering
						element:SetAttribute("Hover", false)
					end
					--click logic
					if mouseState and element:GetAttribute("Hover") then
						if not element:GetAttribute("Click") then
							ss.click:Play()
						end
						--mouse is down and hovering
						element:SetAttribute("Click", true)
					end
					if not mouseState then
						--if mouse is up
						if element:GetAttribute("Hover") and element:GetAttribute("Click") then
							--if mouse is (technically) up and still hovering button (basically just lets the user unclick a button)
							ss.off:Play()
							element.Event:Fire()
						end
						element:SetAttribute("Click", false)
					end
					--hover and click effect (with blending)
					if element:GetAttribute("Click") then
						element:SetAttribute("BackgroundColor3", element:GetAttribute("ClickColor3"))
					elseif element:GetAttribute("Hover") then
						element:SetAttribute("BackgroundColor3", element:GetAttribute("HoverColor3"))
					else
						element:SetAttribute("BackgroundColor3", element:GetAttribute("NormalColor3"))
					end
				end
			end
		end
	end
end

m.Button1Down:Connect(function () mouseState = true end)
m.Button1Up:Connect(function () mouseState = false end)

--uip.InputBegan:Connect(module.Update)
runs.RenderStepped:Connect(module.Update)

return module
