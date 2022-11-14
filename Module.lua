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
		},
		["Text"] = {
			["BackgroundColor3"] = Color3.fromHex("#222222"),
			["TextColor3"] = Color3.fromHex("#dddddd"),
			["Font"] = Enum.Font.SourceSans,
			["TextSize"] = 16,
		},
		["Image"] = {
			["BackgroundColor3"] = Color3.fromHex("#222222"),
			["Image"] = "rbxassetid://8036970459",
		},
		["Button"] = {
			["Normal"] = {
				["BackgroundColor3"] = Color3.fromHex("#111111"),
			},
			["Hover"] = {
				["BackgroundColor3"] = Color3.fromHex("#333333"),
			},
			["Click"] = {
				["BackgroundColor3"] = Color3.fromHex("#dddddd"),
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
		new:SetAttribute("Index", args.Index or 0)
		new:SetAttribute("AspectRatio", args.AspectRatio or Vector2.new(1, 1))
		new:SetAttribute("ForceAspectRatio", args.ForceAspectRatio or false)
		
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
		
		return new
	end
	
	local function Text (args)
		local new
		new = Instance.new("TextLabel")
		Setup(new, args)
		cs:AddTag(new, "Text")
		
		--properties
		new:SetAttribute("BackgroundColor3", Defaults.Theme.Text.BackgroundColor3)
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
		
		return new
	end
	
	local function Group (args)
		local new
		new = Instance.new("CanvasGroup")
		Setup(new, args)
		cs:AddTag(new, "Group")

		--properties
		new:SetAttribute("BackgroundColor3", Defaults.Theme.Frame.BackgroundColor3)
		
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

		new:SetAttribute("BackgroundColor3", Defaults.Theme.Button.Normal.BackgroundColor3)
		new:SetAttribute("HoverColor3", Defaults.Theme.Button.Hover.BackgroundColor3)
		new:SetAttribute("ClickColor3", Defaults.Theme.Button.Click.BackgroundColor3)
		
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
		
		local image = Image({Name = "Image", Parent = new, XAlign = "Left", YAlign = "Center", ForceAspectRatio = true, Size = args.Size})
		local text = Text({Name = "Text", Parent = new, XAlign = "Right", YAlign = "Center", Size = args.Size})
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

				local xp
				local xs
				
				local yp
				local ys
				
				if alignX == "Left" then
					--predict left bound of object

					local elementLeftBound
					if position.X.Offset < bounds.X.Left or position.X.Offset + size.X.Offset > bounds.X.Right and position.Y.Offset < bounds.Y.Left then
						elementLeftBound = bounds.X.Left + position.X.Offset
					else
						elementLeftBound = position.X.Offset + margin
					end
					
					--constrain size to parent object
					
					local elementRightBound = (bounds.X.Left + position.X.Offset) + size.X.Offset --right side of element
					--if the element's right bound extends past the right bound then
					if elementRightBound > bounds.X.Right then
						xs = size.X.Offset + (bounds.X.Right - elementRightBound) --constrain it
					else
						xs = size.X.Offset --if not do nothing
					end
					
					--update position
					
					xp = bounds.X.Left + position.X.Offset
				end
				if alignX == "Center" then
					--constrain size to parent object

					local parentSize = bounds.X.Right - bounds.X.Left --available space left in parent object
					--if the element's right bound extends past the right bound then
					if size.X.Offset > bounds.X.Right then
						xs = size.X.Offset + (bounds.X.Right - parentSize) --constrain it
					else
						xs = size.X.Offset --if not do nothing
					end

					--update position

					xp = parentSize / 2 - size / 2
				end
				if alignX == "Right" then
					--predict left bound of object

					local elementLeftBound
					if position.X.Offset < bounds.X.Left or position.X.Offset + size.X.Offset > bounds.X.Right and position.Y.Offset > bounds.Y.Right then
						elementLeftBound = bounds.X.Left + position.X.Offset
					else
						elementLeftBound = position.X.Offset - margin
					end
					
					--constrain size to parent object

					local elementRightBound = (bounds.X.Left + position.X.Offset) + size.X.Offset --right side of element
					--if the element's right bound extends past the right bound then
					if elementRightBound > bounds.X.Right then
						xs = size.X.Offset + (bounds.X.Right - elementRightBound) --constrain it
					else
						xs = size.X.Offset --if not do nothing
					end

					--update position

					xp = position.X.Offset - margin - size.X.Offset + bounds.X.Right
				end
				
				if alignY == "Top" then
					--predict left bound of object

					local elementLeftBound
					if xp < bounds.X.Left or xp + xs > bounds.X.Right and position.Y.Offset < bounds.Y.Left then
						elementLeftBound = bounds.Y.Left + position.Y.Offset
					else
						elementLeftBound = position.Y.Offset + margin
					end
					
					--constrain size to parent object
					local elementRightBound = elementLeftBound + size.Y.Offset --right side of element
					--if the element's right bound extends past the right bound then
					if elementRightBound > bounds.Y.Right then
						ys = size.Y.Offset + (bounds.Y.Right - elementRightBound) --constrain it
					else
						ys = size.Y.Offset --if not do nothing
					end

					--update position

					yp = elementLeftBound
				end
				if alignY == "Center" then
					--constrain size to parent object

					local parentSize = bounds.Y.Right - bounds.Y.Left --available space left in parent object
					--if the element's right bound extends past the right bound then
					if size.Y.Offset > bounds.Y.Right then
						ys = size.Y.Offset + (bounds.Y.Right - parentSize) --constrain it
					else
						ys = size.Y.Offset --if not do nothing
					end

					--update position

					yp = parentSize / 2 - size / 2
				end
				if alignY == "Bottom" then
					--predict left bound of object
					
					local elementLeftBound
					if xp < bounds.X.Left or xp + xs > bounds.X.Right and position.Y.Offset > bounds.Y.Right then
						elementLeftBound = bounds.Y.Left + position.Y.Offset
					else
						elementLeftBound = position.Y.Offset - margin
					end
					
					--constrain size to parent object

					local elementRightBound = elementLeftBound + size.Y.Offset --right side of element
					--if the element's right bound extends past the right bound then
					if elementRightBound > bounds.Y.Right then
						ys = size.Y.Offset + (bounds.Y.Right - elementRightBound) --constrain it
					else
						ys = size.Y.Offset --if not do nothing
					end

					--update position

					yp = elementLeftBound - margin - size.Y.Offset
				end
				
				print(element, bounds)
				
				if element:GetAttribute("ForceAspectRatio") then
					if xs < ys then --not quite finished aspect ratio thing
						ys = xs * (element:GetAttribute("AspectRatio").X / element:GetAttribute("AspectRatio").Y)
					else
						xs = ys * (element:GetAttribute("AspectRatio").X / element:GetAttribute("AspectRatio").Y)
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
	
				if not cs:HasTag(element, "Button") then
					element.BackgroundColor3 = element:GetAttribute("BackgroundColor3")
				end
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
						--mouse is hovering
						element:SetAttribute("Hover", true)
					else
						--mouse is not hovering
						element:SetAttribute("Hover", false)
					end
					--click logic
					if mouseState and element:GetAttribute("Hover") then
						--mouse is down and hovering
						element:SetAttribute("Click", true)
					end
					if not mouseState then
						--if mouse is up
						if element:GetAttribute("Hover") and element:GetAttribute("Click") then
							--if mouse is (technically) up and still hovering button (basically just lets the user unclick a button)
							element.Event:Fire()
						end
						element:SetAttribute("Click", false)
					end
					--hover and click effect (with blending)
					if element:GetAttribute("Click") then
						element.BackgroundColor3 = element.BackgroundColor3:Lerp(element:GetAttribute("ClickColor3"), step * 15)
					elseif element:GetAttribute("Hover") then
						element.BackgroundColor3 = element.BackgroundColor3:Lerp(element:GetAttribute("HoverColor3"), step * 15)
					else
						element.BackgroundColor3 = element.BackgroundColor3:Lerp(element:GetAttribute("BackgroundColor3"), step * 15)
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
