--!strict
-- Virtual safe-area viewports. This does not claim physical device/emulator input coverage.
return function(feature: Instance, playerGui: Instance): {string}
	local gui = Instance.new("ScreenGui"); gui.Name = "BingoLayoutValidation"; gui.DisplayOrder = 100
	local host = Instance.new("Frame"); host.Name = "Viewport"; host.BackgroundTransparency = 1; host.Parent = gui
	gui.Parent = playerGui
	local State = require(feature:FindFirstChild("PresentationState") :: ModuleScript)
	local views = feature:FindFirstChild("Views") :: Folder
	local match = require(views.MatchView).new(host, function() end)
	local intro = require(views.IntroView).new(host, function() end)
	local lobby = require(views.LobbyView).new(host, function() end)
	local results = require(views.ResultsView).new(host, function() end)
	local card = {}
	for index = 1, 25 do card[index] = {number = index, isFree = index == 13, isMarked = index == 13} end
	local snapshot: any = {kind = "Snapshot", phase = "CallingNumbers", matchId = 1, isParticipant = true,
		isQueued = false, isFirstMatch = true, timeRemaining = 5, minimumPlayers = 2, waitingPlayers = 1,
		calledNumbers = {1, 20, 35, 49, 75}, lastCalledNumber = 75, card = card, callIntervalSeconds = 5, phaseDurationSeconds = 8}
	local output = {}
	local function intersects(a: GuiObject, b: GuiObject): boolean
		local ap, bp, az, bz = a.AbsolutePosition, b.AbsolutePosition, a.AbsoluteSize, b.AbsoluteSize
		return ap.X < bp.X + bz.X and bp.X < ap.X + az.X and ap.Y < bp.Y + bz.Y and bp.Y < ap.Y + az.Y
	end
	local ok, failure = pcall(function()
		for _, size in {Vector2.new(360, 582), Vector2.new(390, 786), Vector2.new(844, 332), Vector2.new(1280, 662), Vector2.new(1920, 1022)} do
			host.Size = UDim2.fromOffset(size.X, size.Y)
			local touch = size.X < 1000
			match.Layout(size.X, size.Y, touch); intro.Layout(size.X, size.Y, touch)
			lobby.Layout(size.X, size.Y, touch); results.Layout(size.X, size.Y, touch)
			task.wait(0.1)
			match.Render(State.Derive(snapshot, {}), {})
			local root = match.Instance
			local grid = root.BingoCard.Cells
			local first = grid.Cell1 :: GuiObject
			local fifth = grid.Cell5 :: GuiObject
			local sixth = grid.Cell6 :: GuiObject
			local last = grid.Cell25 :: GuiObject
			assert(math.abs(first.AbsolutePosition.Y - fifth.AbsolutePosition.Y) < 1, "not five columns: " .. tostring(size))
			assert(sixth.AbsolutePosition.Y > first.AbsolutePosition.Y, "second row missing")
			assert(first.AbsoluteSize.X >= 44 and first.AbsoluteSize.Y >= 44, "cell below touch size: " .. tostring(first.AbsoluteSize))
			assert(last.AbsolutePosition.Y + last.AbsoluteSize.Y <= root.BingoCard.AbsolutePosition.Y + root.BingoCard.AbsoluteSize.Y, "card overflow")
			assert(not intersects(root.Call, root.BingoCard), "call/card overlap")
			assert(not intersects(root.HistorySurface, root.BingoCard), "history/card overlap")
			assert(root.BingoCard.AbsolutePosition.Y + root.BingoCard.AbsoluteSize.Y <= host.AbsolutePosition.Y + size.Y, "viewport overflow")
			local introSnapshot = table.clone(snapshot); introSnapshot.phase = "MatchIntro"
			intro.Render(State.Derive(introSnapshot, {}))
			local caption = intro.Instance.Caption
			assert(not intersects(caption.Instruction, caption.Action), "skip/caption overlap")
			task.wait(0.05)
			assert(caption.Instruction.TextFits, "intro caption clipping: " .. tostring(size))
			assert(root.HistorySurface.Reminder.TextFits, "reminder clipping: " .. tostring(size))
			table.insert(output, tostring(size) .. " passed")
		end
	end)
	match.Destroy(); intro.Destroy(); lobby.Destroy(); results.Destroy(); gui:Destroy()
	assert(ok, tostring(failure))
	return output
end
