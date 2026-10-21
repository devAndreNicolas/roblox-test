--!strict
local TweenService = game:GetService("TweenService")
local UI = script.Parent.Parent.Parent.Parent.UI
local Surface = require(UI.Surface)
local Theme = require(UI.Theme)
local Types = require(game:GetService("ReplicatedStorage").Shared.Features.Bingo.BingoTypes)

type Row = { frame: Frame, rank: TextLabel, name: TextLabel, remaining: TextLabel }
local Race = {}

local function createRow(parent: Instance, index: number): Row
	local frame = Surface.Panel(parent, `Row{index}`, Theme.Midnight, 6)
	frame.BackgroundTransparency = 0.12
	frame.ZIndex = 12
	local rank = Surface.Text(frame, "Rank", 13, Theme.Spotlight, Theme.Bold)
	local name = Surface.Text(frame, "Name", 14, Theme.Paper, Theme.Bold)
	local remaining = Surface.Text(frame, "Remaining", 13, Theme.Paper)
	remaining.TextXAlignment = Enum.TextXAlignment.Right
	for _, label in { rank, name, remaining } do
		label.ZIndex = 13
		label.TextTruncate = Enum.TextTruncate.AtEnd
	end
	return { frame = frame, rank = rank, name = name, remaining = remaining }
end

function Race.new(parent: Instance)
	local root = Surface.Panel(parent, "BingoRace", Theme.Ink, 10)
	root.ZIndex = 10
	local stroke = Instance.new("UIStroke")
	stroke.Color = Theme.Spotlight
	stroke.Thickness = 1
	stroke.Transparency = 0.5
	stroke.Parent = root
	local toggle = Instance.new("TextButton")
	toggle.Name = "ExpandRace"
	toggle.BackgroundTransparency = 1
	toggle.Text = "BINGO RACE  ▼"
	toggle.TextColor3 = Theme.Spotlight
	toggle.Font = Theme.Bold
	toggle.TextSize = 14
	toggle.TextXAlignment = Enum.TextXAlignment.Left
	toggle.Selectable = true
	toggle.ZIndex = 12
	toggle.Parent = root
	local leader = Surface.Text(root, "Leader", 14, Theme.Paper, Theme.Bold)
	local second = Surface.Text(root, "Second", 13, Theme.Paper)
	local own = Surface.Text(root, "Own", 13, Theme.Spotlight, Theme.Bold)
	for _, label in { leader, second, own } do
		label.ZIndex = 12
		label.TextTruncate = Enum.TextTruncate.AtEnd
	end
	local details = Instance.new("ScrollingFrame")
	details.Name = "AllPlayers"
	details.BackgroundColor3 = Theme.Ink
	details.BorderSizePixel = 0
	details.ScrollBarThickness = 4
	details.ScrollBarImageColor3 = Theme.Spotlight
	details.ScrollingDirection = Enum.ScrollingDirection.Y
	details.ClipsDescendants = true
	details.ZIndex = 11
	details.Visible = false
	details.Parent = root
	local detailsCorner = Instance.new("UICorner")
	detailsCorner.CornerRadius = UDim.new(0, 10)
	detailsCorner.Parent = details
	local detailsTitle = Surface.Text(details, "DetailsTitle", 16, Theme.Spotlight, Theme.Display)
	detailsTitle.Text = "ALL PLAYERS"
	detailsTitle.ZIndex = 12
	local rows: { Row } = {}
	for index = 1, 8 do
		rows[index] = createRow(details, index)
	end
	local expanded = false
	local narrow = false
	local width, height = 300, 150
	local viewportHeight = 600
	local rowCount = 0
	local ownTween: Tween? = nil
	local leadTween: Tween? = nil
	local function layout(): ()
		Surface.Rect(toggle, 10, 0, width - 20, if narrow then 24 else 34)
		if narrow then
			Surface.Rect(leader, 10, 24, math.max(90, width * 0.62 - 10), 23)
			Surface.Rect(own, width * 0.62, 24, width * 0.38 - 12, 23)
			second.Visible = false
		else
			Surface.Rect(leader, 12, 40, width - 24, 28)
			Surface.Rect(second, 12, 75, width - 24, 26)
			Surface.Rect(own, 12, 111, width - 24, 26)
			second.Visible = true
		end
		local contentHeight = 42 + math.max(1, rowCount) * 34 + 8
		local space = if narrow
			then root.Position.Y.Offset - 10
			else viewportHeight - root.Position.Y.Offset - height - 14
		local detailsHeight = math.min(contentHeight, math.max(80, space))
		Surface.Rect(details, 0, if narrow then -detailsHeight - 6 else height + 6, width, detailsHeight)
		details.CanvasSize = UDim2.fromOffset(0, contentHeight)
		Surface.Rect(detailsTitle, 12, 8, width - 24, 24)
		for index, row in rows do
			Surface.Rect(row.frame, 8, 38 + (index - 1) * 34, width - 16, 30)
			Surface.Rect(row.rank, 8, 4, 34, 22)
			Surface.Rect(row.name, 46, 4, math.max(60, width - 142), 22)
			Surface.Rect(row.remaining, width - 90, 4, 78, 22)
		end
	end
	local connection = toggle.Activated:Connect(function()
		expanded = not expanded
		details.Visible = expanded
		toggle.Text = if expanded then "BINGO RACE  ▲" else "BINGO RACE  ▼"
	end)
	local race = { Instance = root }
	function race.Layout(
		x: number,
		y: number,
		nextWidth: number,
		nextHeight: number,
		isNarrow: boolean,
		screenHeight: number
	): ()
		width, height, narrow, viewportHeight = nextWidth, nextHeight, isNarrow, screenHeight
		Surface.Rect(root, x, y, width, height)
		layout()
	end
	function race.Render(standings: { Types.Standing }?, localUserId: number): ()
		local list: { Types.Standing } = standings or {}
		local first: Types.Standing? = nil
		local secondPlace: Types.Standing? = nil
		local ownStanding: Types.Standing? = nil
		local firstTies, secondTies = 0, 0
		for _, standing in list do
			if standing.rank == 1 then
				first = first or standing
				firstTies += 1
			end
			if standing.rank == 2 then
				secondPlace = secondPlace or standing
				secondTies += 1
			end
			if standing.userId == localUserId then
				ownStanding = standing
			end
		end
		if first then
			leader.TextColor3 = if first.remaining <= 3 then Theme.Spotlight else Theme.Paper
			local distance = if first.remaining == 1 then "ONE TO BINGO" else `{first.remaining} to Bingo`
			leader.Text = if narrow
				then (if first.remaining == 1
					then "ONE TO BINGO"
					elseif firstTies > 1 then `TIE {first.remaining} LEFT`
					else `LEAD {first.remaining} LEFT`)
				elseif firstTies > 1 then `{firstTies} TIED FOR 1ST  •  {distance}`
				else `1ST {first.displayName}  •  {distance}`
		else
			leader.Text = "Waiting for the first mark"
		end
		if secondPlace then
			second.Text = if secondTies > 1
				then `{secondTies} TIED FOR 2ND  •  {secondPlace.remaining} to Bingo`
				else `2ND {secondPlace.displayName}  •  {secondPlace.remaining} to Bingo`
		elseif #list == 1 then
			second.Text = "Solo round"
		else
			second.Text = "No separate 2nd place"
		end
		own.Text = if ownStanding
			then (if narrow then `YOU {ownStanding.remaining} LEFT` else `YOU  •  {ownStanding.remaining} to Bingo`)
			else "YOU  •  waiting"
		for index, row in rows do
			local standing = list[index]
			row.frame.Visible = standing ~= nil
			if standing then
				local tied = (list[index - 1] and list[index - 1].rank == standing.rank)
					or (list[index + 1] and list[index + 1].rank == standing.rank)
				row.rank.Text = if tied then `={standing.rank}` else `#{standing.rank}`
				row.name.Text = if standing.userId == localUserId
					then `{standing.displayName} (YOU)`
					else standing.displayName
				row.remaining.Text = `{standing.remaining} left`
				row.rank.TextColor3 = if standing.rank == 1 then Theme.Spotlight else Theme.Paper
				row.frame.BackgroundColor3 = if standing.userId == localUserId then Theme.Stage else Theme.Midnight
			end
		end
		if rowCount ~= #list then
			rowCount = #list
			layout()
		end
	end
	function race.Collapse(): ()
		expanded = false
		details.Visible = false
		details.CanvasPosition = Vector2.zero
		toggle.Text = "BINGO RACE  ▼"
	end
	function race.CelebrateOwn(): ()
		if ownTween then
			ownTween:Cancel()
		end
		own.TextColor3 = Theme.White
		ownTween = TweenService:Create(own, TweenInfo.new(0.42), { TextColor3 = Theme.Spotlight })
		ownTween:Play()
	end
	function race.CelebrateLead(): ()
		if leadTween then
			leadTween:Cancel()
		end
		stroke.Transparency = 0
		stroke.Thickness = 3
		leadTween = TweenService:Create(stroke, TweenInfo.new(0.5), { Transparency = 0.5, Thickness = 1 })
		leadTween:Play()
	end
	function race.Destroy(): ()
		if ownTween then
			ownTween:Cancel()
		end
		if leadTween then
			leadTween:Cancel()
		end
		connection:Disconnect()
		root:Destroy()
	end
	return race
end
return Race
