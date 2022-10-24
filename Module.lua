local rs = game:GetService("ReplicatedStorage")
local cs = game:GetService("CollectionService")
local uip = game:GetService("UserInputService")
local m = game:GetService("Players").LocalPlayer:GetMouse()

local t = require(rs.Theme)

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
			["BackgroundColor3"] = Color3.fromHex("#111111"),
		},	
	},
}

local module = {}

function module.New (instance : string, args)
	local new
	
	--basic setup that all objects go through
	local function Setup (new, args)
		new.Parent = args.Parent
		new.Name = args.Name or "instance"
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
		new:SetAttribute("Font", Defaults.Theme.Text.Font)
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
	
	if instance == "Frame" then new = Frame(args) end
	
	if instance == "Text" then new = Text(args) end
	
	if instance == "Image" then new = Image(args) end
	
	if instance == "Group" then new = Group(args) end
	
	--Advanced Types
	if instance == "Button" then
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
		
		new:SetAttribute("BackgroundColor3", Defaults.Theme.Button.BackgroundColor3)
	end
	
	return new
end

function module.Update (input)
	--[[
	Formating and such
	--]]
	for i, instance in ipairs(cs:GetTagged("UI")) do
		local margin = Defaults.Theme.Margin
		local pos = instance:GetAttribute("Position")
		local siz = instance:GetAttribute("Size")
		local alX = instance:GetAttribute("AlignX")
		local alY = instance:GetAttribute("AlignY")
		
		local function align (axis : string, al : string, pos : number, siz : number)
			--all comments in this function pertain to the X axis, to understand what they mean when it comes to the Y axis then rotate 90 degrees
			local endPos
			local endSiz
			--left allign x
			if al == "Left" or al == "Top" then
				--constrain size to parent object
				local is = (pos + margin) + siz --right side of instance
				local ps = instance.Parent.AbsoluteSize[axis] - margin --right inner bound of parent
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
				local ps = instance.Parent.AbsoluteSize[axis] - margin * 2 --parent size including the margins on both sides
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
				local is = (pos + margin) + siz --right side of instance
				local ps = instance.Parent.AbsoluteSize[axis] - margin --right inner bound of parent
				--if right side extends past right inner bound then constrain it
				if is > ps then
					endSiz = siz + (ps - is)
				else
					endSiz = siz
				end
				--allign the object to the right
				endPos = pos - margin - siz + instance.Parent.AbsoluteSize[axis]
			end
			
			return endPos, endSiz
		end
		
		local xp, xs = align("X", alX, pos.X.Offset, siz.X.Offset)
		local yp, ys = align("Y", alY, pos.Y.Offset, siz.Y.Offset)
		
		instance.Position = UDim2.fromOffset(xp, yp)
		instance.Size = UDim2.fromOffset(xs, ys)
		
		instance.BackgroundColor3 = instance:GetAttribute("BackgroundColor3")
		--TODO: Find a better way to do this
	end
	
	--[[
	button Stuff
	--]]
	for i, button in ipairs(cs:GetTagged("Button")) do
		--hover logic
		if --mouse collision checks (basic box collision thing)
			button.AbsolutePosition.X < m.X and 
			button.AbsolutePosition.X + button.AbsoluteSize.X > m.X
			and
			button.AbsolutePosition.Y < m.Y and 
			button.AbsolutePosition.Y + button.AbsoluteSize.Y > m.Y
		then
			--mouse is hovering
			button:SetAttribute("Hover", true)
		else
			--mouse is not hovering
			button:SetAttribute("Hover", false)
		end
		--click logic
		if mouseState and button:GetAttribute("Hover") then
			--mouse is down and hovering
			button:SetAttribute("Click", true)
		end
		if not mouseState then
			--if mouse is up
			if button:GetAttribute("Hover") and button:GetAttribute("Click") then
				--if mouse is (technically) up and still hovering button (basically just lets the user unclick a button)
				button.Event:Fire()
			end
			button:SetAttribute("Click", false)
		end
	end
end

m.Button1Down:Connect(function () mouseState = true end)
m.Button1Up:Connect(function () mouseState = false end)

cs.TagAdded:Connect(module.Update)
uip.InputBegan:Connect(module.Update)

return module
