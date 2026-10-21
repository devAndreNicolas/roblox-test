--!strict
-- Applies Studio-authored appearance to the legacy GUI after its state render.
-- The legacy tree remains the fallback when a design template is unavailable.
local VisualDesign = {}

type Pair = { live: Instance, design: Instance }

local function copy<T>(live: T, design: T, property: string): ()
	if (live :: any)[property] ~= (design :: any)[property] then
		(live :: any)[property] = (design :: any)[property]
	end
end

local function isDynamicColor(item: Instance): boolean
	if item:FindFirstAncestor("BingoCard") then
		return true
	end
	if item.Name:match("^Cell%d+$") or item.Name:match("^DailyDot%d+$") then
		return true
	end
	if item.Name == "BingoCard" or item.Name == "ThemeHeader" or item.Name == "Letters" then
		return true
	end
	if item.Name == "BuyFichas" or item.Name == "BuyRobux" or item.Name == "Equip" then
		return true
	end
	if item.Name == "UseSuborn" or item.Name == "Accent" then
		return true
	end
	if item.Name == "Feedback" or item.Name == "Leader" or item.Name == "Rank" then
		return true
	end
	if item.Name:match("^Row%d+$") and item.Parent and item.Parent.Name == "AllPlayers" then
		return true
	end
	if item.Parent and item.Parent.Name == "Categories" then
		return true
	end
	if item.Name == "Title" and item.Parent and item.Parent.Name == "Outcome" then
		return true
	end
	return false
end

local function styleOnce(live: Instance, design: Instance): ()
	if live:IsA("GuiObject") and design:IsA("GuiObject") then
		copy(live, design, "AnchorPoint")
		copy(live, design, "Rotation")
		copy(live, design, "ZIndex")
		copy(live, design, "LayoutOrder")
		copy(live, design, "BackgroundTransparency")
		copy(live, design, "BorderSizePixel")
		copy(live, design, "BorderColor3")
		copy(live, design, "ClipsDescendants")
		copy(live, design, "SizeConstraint")
		if not isDynamicColor(live) then
			copy(live, design, "BackgroundColor3")
			if live:IsA("TextLabel") or live:IsA("TextButton") or live:IsA("TextBox") then
				copy(live, design, "TextColor3")
			end
		end
		if live:IsA("TextLabel") or live:IsA("TextButton") or live:IsA("TextBox") then
			copy(live, design, "FontFace")
			copy(live, design, "TextScaled")
			copy(live, design, "TextWrapped")
			copy(live, design, "TextXAlignment")
			copy(live, design, "TextYAlignment")
			copy(live, design, "TextTransparency")
			copy(live, design, "TextStrokeColor3")
			copy(live, design, "TextStrokeTransparency")
			copy(live, design, "LineHeight")
			copy(live, design, "RichText")
		end
		if (live:IsA("ImageLabel") and design:IsA("ImageLabel"))
			or (live:IsA("ImageButton") and design:IsA("ImageButton"))
		then
			if live.Name ~= "ThemeArtwork" or not live:FindFirstAncestor("BingoCard") then
				copy(live, design, "Image")
			end
			copy(live, design, "ImageColor3")
			copy(live, design, "ImageTransparency")
			copy(live, design, "ScaleType")
			copy(live, design, "ImageRectOffset")
			copy(live, design, "ImageRectSize")
			copy(live, design, "SliceCenter")
			copy(live, design, "SliceScale")
		end
	elseif live:IsA("UICorner") and design:IsA("UICorner") then
		copy(live, design, "CornerRadius")
	elseif live:IsA("UIStroke") and design:IsA("UIStroke") then
		if not live.Parent or live.Parent.Name ~= "BingoCard" then
			copy(live, design, "Color")
		end
		if not live.Parent or (live.Parent.Name ~= "BingoRace" and not live.Parent.Name:match("^Cell%d+$")) then
			copy(live, design, "Thickness")
			copy(live, design, "Transparency")
		end
	elseif live:IsA("UIGridLayout") and design:IsA("UIGridLayout") then
		copy(live, design, "CellSize")
		copy(live, design, "CellPadding")
		copy(live, design, "FillDirectionMaxCells")
	elseif live:IsA("UIListLayout") and design:IsA("UIListLayout") then
		copy(live, design, "Padding")
		copy(live, design, "FillDirection")
		copy(live, design, "HorizontalAlignment")
		copy(live, design, "VerticalAlignment")
	elseif live:IsA("UIPadding") and design:IsA("UIPadding") then
		copy(live, design, "PaddingTop")
		copy(live, design, "PaddingBottom")
		copy(live, design, "PaddingLeft")
		copy(live, design, "PaddingRight")
	elseif live:IsA("UISizeConstraint") and design:IsA("UISizeConstraint") then
		copy(live, design, "MinSize")
		copy(live, design, "MaxSize")
	elseif live:IsA("UIAspectRatioConstraint") and design:IsA("UIAspectRatioConstraint") then
		copy(live, design, "AspectRatio")
		copy(live, design, "AspectType")
	elseif live:IsA("UIScale") and design:IsA("UIScale") then
		-- Animated cells own their scale while an effect is playing.
		if not (live.Parent and live.Parent.Name:match("^Cell%d+$")) then
			copy(live, design, "Scale")
		end
	elseif live:IsA("UIGradient") and design:IsA("UIGradient") then
		copy(live, design, "Color")
		copy(live, design, "Transparency")
		copy(live, design, "Rotation")
	end
end

local function layoutEachRender(live: Instance, design: Instance): ()
	if not live:IsA("GuiObject") or not design:IsA("GuiObject") then
		return
	end
	if live.Name ~= "Progress" then
		local baselinePosition = design:GetAttribute("BaselinePosition")
		if typeof(baselinePosition) == "UDim2" and design.Position ~= baselinePosition then
			copy(live, design, "Position")
		end
		local baselineSize = design:GetAttribute("BaselineSize")
		if typeof(baselineSize) == "UDim2" and design.Size ~= baselineSize then
			copy(live, design, "Size")
		end
	end
	if live:IsA("TextLabel") or live:IsA("TextButton") or live:IsA("TextBox") then
		local baselineTextSize = design:GetAttribute("BaselineTextSize")
		if typeof(baselineTextSize) == "number" and design.TextSize ~= baselineTextSize then
			copy(live, design, "TextSize")
		end
	end
end

local function findMatch(parent: Instance, design: Instance, used: { [Instance]: boolean }): Instance?
	for _, child in parent:GetChildren() do
		if not used[child] and child.Name == design.Name and child.ClassName == design.ClassName then
			return child
		end
	end
	return nil
end

function VisualDesign.new(live: ScreenGui, design: ScreenGui)
	local pairs: { Pair } = {}
	local function collect(liveParent: Instance, designParent: Instance): ()
		local used: { [Instance]: boolean } = {}
		for _, designChild in designParent:GetChildren() do
			if designChild.Name == "VisualStates" then
				continue
			end
			local liveChild = findMatch(liveParent, designChild, used)
			if not liveChild then
				-- New Studio decoration and layout objects can be added without code.
				if designChild:IsA("GuiObject") or designChild:IsA("UIComponent") or designChild:IsA("UIGridStyleLayout") then
					liveChild = designChild:Clone()
					liveChild.Parent = liveParent
				end
			end
			if liveChild then
				used[liveChild] = true
				if liveChild:GetAttribute("StudioCellTemplate") ~= true then
					table.insert(pairs, { live = liveChild, design = designChild })
				end
				if liveChild:GetAttribute("DesignOnly") ~= true and liveChild:GetAttribute("StudioCellTemplate") ~= true then
					collect(liveChild, designChild)
				end
			end
		end
	end
	collect(live, design)
	local styled = false
	return {
		Apply = function()
			if not styled then
				styled = true
				for _, pair in pairs do
					styleOnce(pair.live, pair.design)
				end
			end
			for _, pair in pairs do
				layoutEachRender(pair.live, pair.design)
			end
		end,
		Destroy = function()
			table.clear(pairs)
		end,
	}
end

return VisualDesign
