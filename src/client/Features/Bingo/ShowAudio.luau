--!strict
-- Optional local music with an always available mute control.
local SoundService = game:GetService("SoundService")
local Config = require(game:GetService("ReplicatedStorage").Shared.Features.Bingo.BingoConfig)
local Theme = require(script.Parent.Parent.Parent.UI.Theme)

local ShowAudio = {}

function ShowAudio.new(parent: Instance)
	local music = Instance.new("Sound")
	music.Name = "BingoNoirMusic"
	music.SoundId = Config.TEMP_JAZZ_SOUND_ID
	music.Looped = true
	music.Volume = 0.1
	music.Parent = SoundService
	if music.SoundId ~= "" then music:Play() end

	local button = Instance.new("TextButton")
	button.Name = "MusicToggle"
	button.AnchorPoint = Vector2.new(1, 0)
	button.Position = UDim2.new(1, -12, 0, 12)
	button.Size = UDim2.fromOffset(100, 36)
	button.BackgroundColor3 = Theme.Midnight
	button.BackgroundTransparency = 0.05
	button.TextColor3 = Theme.Paper
	button.TextSize = 14
	button.Font = Theme.Bold
	button.Text = "Music: On"
	button.AutoButtonColor = true
	button.Selectable = true
	button.ZIndex = 30
	button.Parent = parent
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 9)
	corner.Parent = button
	local stroke = Instance.new("UIStroke")
	stroke.Color = Theme.Spotlight
	stroke.Thickness = 1
	stroke.Parent = button

	local muted = false
	local participant = false
	local function update(): ()
		music.Volume = if muted then 0 else (if participant then 0.22 else 0.1)
		button.Text = if muted then "Music: Off" else "Music: On"
	end
	local connection = button.Activated:Connect(function()
		muted = not muted
		update()
	end)
	local audio = {}
	function audio.SetParticipant(value: boolean): ()
		if value == participant then return end
		participant = value
		update()
	end
	function audio.Destroy(): ()
		connection:Disconnect()
		music:Destroy()
		button:Destroy()
	end
	return audio
end

return ShowAudio
