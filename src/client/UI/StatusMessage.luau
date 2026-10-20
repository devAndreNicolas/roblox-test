--!strict
local Theme = require(script.Parent.Theme)
local Surface = require(script.Parent.Surface)
local Types = require(game:GetService("ReplicatedStorage").Shared.Features.Bingo.BingoTypes)
local Status = {}
function Status.new(parent: Instance)
	local frame = Surface.Panel(parent, "Feedback", Theme.Ink, 10)
	local text = Surface.Text(frame, "Message", 14, Theme.White, Theme.Bold)
	text.Position = UDim2.fromOffset(8, 0); text.Size = UDim2.new(1, -16, 1, 0)
	text.TextXAlignment = Enum.TextXAlignment.Center
	frame.Visible = false
	local expires, currentId, currentMatch = 0, -1, -1
	local status = {Instance = frame}
	function status.Clear(): ()
		expires = 0; currentId = -1; currentMatch = -1; frame.Visible = false
	end
	function status.Update(notice: Types.Notice?, matchId: number): ()
		if matchId ~= currentMatch then expires = 0; currentMatch = matchId; currentId = -1 end
		if notice and notice.id ~= currentId then
			currentId = notice.id; expires = os.clock() + 3
			text.Text = (if notice.kind == "success" then "✓  " elseif notice.kind == "error" then "!  " else "•  ") .. notice.text
			frame.BackgroundColor3 = if notice.kind == "success" then Theme.Mark elseif notice.kind == "error" then Theme.Ink else Theme.Stage
		end
		frame.Visible = os.clock() < expires
	end
	function status.Tick(): () frame.Visible = os.clock() < expires end
	function status.Destroy(): () frame:Destroy() end
	return status
end
return Status
