local rs = game:GetService("ReplicatedStorage")
local cs = game:GetService("CollectionService")
local uip = game:GetService("UserInputService")
local m = game:GetService("Players").LocalPlayer:GetMouse()

local t = require(rs.Theme)

--default theme
local Theme = {
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
	["Button"] = {
		["BackgroundColor3"] = Color3.fromHex("#111111"),
	},
}

local module = {}

function module.New (instance : string, args)
	local new
	
	local function Frame (args)
		local new
		new = Instance.new("Frame")
		new.Parent = args.Parent
		new.Name = args.Name or "instance"
		new.Position = UDim2.fromOffset(0, 0)
		new.Size = UDim2.fromOffset(100, 100)
		cs:AddTag(new, "UI")
		cs:AddTag(new, "Frame")
		
		--properties
		new:SetAttribute("BackgroundColor3", Theme.Frame.BackgroundColor3)
		
		new:SetAttribute("Position", args.Position or UDim2.new(0, 0, 0, 0))
		new:SetAttribute("Size", args.Size or UDim2.new(0, 100, 0, 100))
		
		return new
	end
	
	if instance == "Frame" then new = Frame(args) end
	
	local function Text (args)
		local new
		new = Instance.new("TextLabel")
		new.Parent = args.Parent
		new.Name = args.Name or "instance"
		new.Position = UDim2.fromOffset(0, 0)
		new.Size = UDim2.fromOffset(100, 100)
		cs:AddTag(new, "UI")
		cs:AddTag(new, "Text")
		
		--properties
		new:SetAttribute("BackgroundColor3", Theme.Text.BackgroundColor3)
		new:SetAttribute("TextColor3", Theme.Text.TextColor3)
		new:SetAttribute("Font", Theme.Text.Font)
		new:SetAttribute("TextSize", Theme.Text.TextSize)
		
		new:SetAttribute("Position", args.Position or UDim2.new(0, 0, 0, 0))
		new:SetAttribute("Size", args.Size or UDim2.new(0, 100, 0, 100))
		return new
	end
	
	local function Image (args)
		local new
		new = Instance.new("ImageLabel")
		new.Parent = args.Parent
		new.Name = args.Name or "instance"
		new.Position = UDim2.fromOffset(0, 0)
		new.Size = UDim2.fromOffset(100, 100)
		new.Image = args.Image or "rbxassetid://8036970459"
		cs:AddTag(new, "UI")
		cs:AddTag(new, "Image")

		--properties
		new:SetAttribute("BackgroundColor3", Theme.Text.BackgroundColor3)

		new:SetAttribute("Position", args.Position or UDim2.new(0, 0, 0, 0))
		new:SetAttribute("Size", args.Size or UDim2.new(0, 100, 0, 100))
		return new
	end
	
	if instance == "Frame" then new = Frame(args) end
	
	if instance == "Text" then new = Frame(args) end
	
	if instance == "Button" then
		--actual button
		new = Frame(args)
		new.Active = true
		cs:AddTag(new, "Button")
		--it's event
		local event = Instance.new("BindableEvent")
		event.Parent = new
		event.Name = "Event"
		--themeing
		new:SetAttribute("BackgroundColor3", Theme.Button.BackgroundColor3)

		new:SetAttribute("Position", args.Position or UDim2.new(0, 0, 0, 0))
		new:SetAttribute("Size", args.Size or UDim2.new(0, 100, 0, 100))
	end
	
	if new then
		local corner = Instance.new("UICorner")
		corner.Parent = new
		corner.CornerRadius = UDim.new(0, Theme.BorderRadius)
	end
	
	return new
end

function module.Update (input)
	for i, instance in ipairs(cs:GetTagged("UI")) do
		instance.Position = instance:GetAttribute("Position")
		instance.Size = instance:GetAttribute("Size")
		--TODO: Find a better way to do this
	end
	
	if input then
		for i, button in ipairs(cs:GetTagged("Button")) do
			if --mouse collision checks
				button.AbsolutePosition.X < m.X and 
				button.AbsolutePosition.X + button.AbsoluteSize.X > m.X
				and
				button.AbsolutePosition.Y < m.Y and 
				button.AbsolutePosition.Y + button.AbsoluteSize.Y > m.Y
			then
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					button.Event:Fire()
				end
			end
		end
	end
end

cs.TagAdded:Connect(module.Update)
uip.InputBegan:Connect(module.Update)

return module
