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
	if element == "ImgButton" then
		--actual button
		new = Frame(args)
		cs:AddTag(new, "Button")
		
		local image = Image({Name = "Image", Parent = new})
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
	end
	
	if element == "TextButton" then
		--actual button
		new = Frame(args)
		cs:AddTag(new, "Button")

		local text = Text({Name = "Text", Parent = new})
		--it's event
		local event = Instance.new("BindableEvent")
		event.Parent = new
		event.Name = "Event"

		--properties	
		new:SetAttribute("Hover", false)
		new:SetAttribute("Click", false)

		new:SetAttribute("BackgroundColor3", Defaults.Theme.Button.Normal.BackgroundColor3)
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
			--go through and filter out the UI stuff
			for k, child in ipairs(r:GetChildren()) do
				if cs:HasTag(child, "UI") then
					table.insert(elements, child)
				end
			end
		end
		if #elements == 0 then break end --if there are none then kill the loop
		--reset stuff (so it loops)
		roots = elements
		
		--do the checks
		for i, element in ipairs(elements) do
			local margin = Defaults.Theme.Margin
			local pos = element:GetAttribute("Position")
			local siz = element:GetAttribute("Size")
			local alX = element:GetAttribute("AlignX")
			local alY = element:GetAttribute("AlignY")

			local function align (axis : string, al : string, pos : number, siz : number)
				--all comments in this function pertain to the X axis, to understand what they mean when it comes to the Y axis then rotate 90 degrees
				local endPos
				local endSiz
				--left allign x
				if al == "Left" or al == "Top" then
					--constrain size to parent object
					local is = (pos + margin) + siz --right side of element
					local ps = element.Parent.AbsoluteSize[axis] - margin --right inner bound of parent
					--if right side extends past right inner bound then constrain it
					if is > ps then
						endSiz = siz + (ps - is)
					else
						endSiz = siz
					end
					--allign the object to the left
					endPos = pos + margin
				end
				--center allign x
				if al == "Center" then
					--constrain size to parent object
					local ps = element.Parent.AbsoluteSize[axis] - margin * 2 --parent size including the margins on both sides
					if siz > ps then --same routine
						endSiz = siz + (ps - siz)
					else
						endSiz = siz
					end
					--align the object to the center
					endPos = ps / 2 - siz / 2
				end
				--right allign x
				if al == "Right" or al == "Bottom" then--basically the same as Left align except positions differently
					--constrain size to parent object
					local is = (pos + margin) + siz --right side of element
					local ps = element.Parent.AbsoluteSize[axis] - margin --right inner bound of parent
					--if right side extends past right inner bound then constrain it
					if is > ps then
						endSiz = siz + (ps - is)
					else
						endSiz = siz
					end
					--allign the object to the right
					endPos = pos - margin - siz + element.Parent.AbsoluteSize[axis]
				end

				return endPos, endSiz
			end

			local xp, xs = align("X", alX, pos.X.Offset, siz.X.Offset)
			local yp, ys = align("Y", alY, pos.Y.Offset, siz.Y.Offset)

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

m.Button1Down:Connect(function () mouseState = true end)
m.Button1Up:Connect(function () mouseState = false end)

--uip.InputBegan:Connect(module.Update)
runs.RenderStepped:Connect(module.Update)

return module
