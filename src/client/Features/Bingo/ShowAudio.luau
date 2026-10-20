--!strict
-- Local music and short confirmation effects; sound never carries gameplay state.
local SoundService = game:GetService("SoundService")
local Config = require(game:GetService("ReplicatedStorage").Shared.Features.Bingo.BingoConfig)
local Theme = require(script.Parent.Parent.Parent.UI.Theme)

local ShowAudio = {}
local musicMuted = false
local effectsMuted = false

local function makeSound(name: string, soundId: string, volume: number): Sound
	local sound = Instance.new("Sound")
	sound.Name = name
	sound.SoundId = soundId
	sound.Volume = volume
	sound.Parent = SoundService
	return sound
end

local function makeToggle(parent: Instance, name: string, top: number): TextButton
	local button = Instance.new("TextButton")
	button.Name = name
	button.AnchorPoint = Vector2.new(1, 0)
	button.Position = UDim2.new(1, -12, 0, top)
	button.Size = UDim2.fromOffset(104, 36)
	button.BackgroundColor3 = Theme.Midnight
	button.BackgroundTransparency = 0.05
	button.TextColor3 = Theme.Paper
	button.TextSize = 14
	button.Font = Theme.Bold
	button.AutoButtonColor = true
	button.Selectable = true
	button.ZIndex = 30
	button.Parent = parent
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 9); corner.Parent = button
	local stroke = Instance.new("UIStroke")
	stroke.Color = Theme.Spotlight; stroke.Thickness = 1; stroke.Parent = button
	return button
end

function ShowAudio.new(parent: Instance)
	local music = makeSound("BingoNoirMusic", Config.TEMP_JAZZ_SOUND_ID, 0.1)
	music.Looped = true
	local click = makeSound("BingoMarkClick", Config.MARK_CLICK_SOUND_ID, 0.16)
	local note = makeSound("BingoMarkNote", Config.MARK_NOTE_SOUND_ID, 0.18)
	local flourish = makeSound("BingoFlourish", Config.MARK_NOTE_SOUND_ID, 0.22)
	local musicButton = makeToggle(parent, "MusicToggle", 12)
	local effectsButton = makeToggle(parent, "EffectsToggle", 54)
	local participant = false
	local alive = true
	local markCount = 0
	local cueVersion = 0
	local duckVersion = 0
	local ducked = false
	local function update(): ()
		music.Volume = if musicMuted then 0 else (if ducked then 0.08 elseif participant then 0.17 else 0.1)
		musicButton.Text = if musicMuted then "Music: Off" else "Music: On"
		effectsButton.Text = if effectsMuted then "Effects: Off" else "Effects: On"
	end
	local function duck(seconds: number): ()
		duckVersion += 1
		local version = duckVersion
		ducked = true
		update()
		task.delay(seconds, function()
			if not alive or duckVersion ~= version then return end
			ducked = false
			update()
		end)
	end
	if music.SoundId ~= "" then music:Play() end
	update()
	local musicConnection = musicButton.Activated:Connect(function()
		musicMuted = not musicMuted
		update()
	end)
	local effectsConnection = effectsButton.Activated:Connect(function()
		effectsMuted = not effectsMuted
		if effectsMuted then
			cueVersion += 1; duckVersion += 1; ducked = false
			click:Stop(); note:Stop(); flourish:Stop()
		end
		update()
	end)
	local audio = {}
	function audio.SetParticipant(value: boolean): ()
		if value == participant then return end
		participant = value
		update()
	end
	function audio.Layout(width: number, height: number, touch: boolean, view: string): ()
		local portraitMatch = view == "Match" and width < height and width < 760
		if portraitMatch then
			local y = height - (if touch then 42 else 38)
			musicButton.Size = UDim2.fromOffset(96, 32)
			effectsButton.Size = UDim2.fromOffset(96, 32)
			musicButton.Position = UDim2.fromOffset(width / 2 - 6, y)
			effectsButton.Position = UDim2.fromOffset(width / 2 + 102, y)
		else
			musicButton.Size = UDim2.fromOffset(104, 36)
			effectsButton.Size = UDim2.fromOffset(104, 36)
			musicButton.Position = UDim2.new(1, -12, 0, 12)
			effectsButton.Position = UDim2.new(1, -12, 0, 54)
		end
	end
	function audio.PlayMark(): ()
		if effectsMuted or not alive then return end
		markCount += 1
		cueVersion += 1
		local version = cueVersion
		duck(0.65)
		click:Stop(); click:Play()
		local pitch = ({0.94, 1, 1.06})[(markCount - 1) % 3 + 1] or 1
		note.PlaybackSpeed = pitch
		task.delay(0.07, function()
			if not alive or effectsMuted or cueVersion ~= version then return end
			note:Stop(); note:Play()
		end)
		task.delay(0.19, function()
			if not alive or effectsMuted or cueVersion ~= version then return end
			flourish.PlaybackSpeed = pitch * 1.16
			flourish:Stop(); flourish:Play()
		end)
		task.delay(0.65, function()
			if not alive or cueVersion ~= version then return end
			click:Stop(); note:Stop(); flourish:Stop()
		end)
	end
	function audio.PlayNearWin(oneAway: boolean): ()
		if effectsMuted or not alive then return end
		cueVersion += 1
		duck(1.1)
		flourish.PlaybackSpeed = if oneAway then 1.2 else 1.08
		flourish:Stop(); flourish:Play()
	end
	function audio.PlayWin(): ()
		if effectsMuted or not alive then return end
		cueVersion += 1
		duck(1.5)
		local version = cueVersion
		note.PlaybackSpeed = 1.12
		note:Stop(); note:Play()
		task.delay(0.18, function()
			if not alive or effectsMuted or cueVersion ~= version then return end
			flourish.PlaybackSpeed = 1.38
			flourish:Stop(); flourish:Play()
		end)
	end
	function audio.Destroy(): ()
		alive = false
		musicConnection:Disconnect(); effectsConnection:Disconnect()
		music:Destroy(); click:Destroy(); note:Destroy(); flourish:Destroy()
		musicButton:Destroy(); effectsButton:Destroy()
	end
	return audio
end

return ShowAudio
