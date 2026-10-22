--!strict
-- Local music and short confirmation effects; sound never carries gameplay state.
local SoundService = game:GetService("SoundService")
local Config = require(game:GetService("ReplicatedStorage").Shared.Features.Bingo.BingoConfig)
local UI = script.Parent.Parent.Parent.UI
local Theme = require(UI.Theme)
local StudioTemplate = require(UI.StudioTemplate)

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
	local template = StudioTemplate.Clone(name, parent, "TextButton")
	if template and template:IsA("TextButton") then
		return template
	end
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
	corner.CornerRadius = UDim.new(0, 9)
	corner.Parent = button
	local stroke = Instance.new("UIStroke")
	stroke.Color = Theme.Spotlight
	stroke.Thickness = 1
	stroke.Parent = button
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
	local function setToggle(button: TextButton, label: string, iconText: string, enabled: boolean): ()
		local icon = button:FindFirstChild("Icon")
		local text = button:FindFirstChild("Label")
		local state = button:FindFirstChild("State")
		if icon and icon:IsA("TextLabel") and text and text:IsA("TextLabel") and state and state:IsA("TextLabel") then
			icon.Text = iconText
			text.Text = label
			state.Text = if enabled then "ON" else "OFF"
			state.BackgroundColor3 = if enabled then Theme.Mark else Theme.Muted
			button.Text = ""
		else
			button.Text = label .. ": " .. (if enabled then "On" else "Off")
		end
	end
	local participant = false
	local alive = true
	local markCount = 0
	local cueVersion = 0
	local duckVersion = 0
	local ducked = false
	local function update(): ()
		music.Volume = if musicMuted then 0 else (if ducked then 0.08 elseif participant then 0.17 else 0.1)
		setToggle(musicButton, "MUSIC", if musicMuted then "♪" else "♫", not musicMuted)
		setToggle(effectsButton, "EFFECTS", "FX", not effectsMuted)
	end
	local function duck(seconds: number): ()
		duckVersion += 1
		local version = duckVersion
		ducked = true
		update()
		task.delay(seconds, function()
			if not alive or duckVersion ~= version then
				return
			end
			ducked = false
			update()
		end)
	end
	if music.SoundId ~= "" then
		music:Play()
	end
	update()
	local musicConnection = musicButton.Activated:Connect(function()
		musicMuted = not musicMuted
		update()
	end)
	local effectsConnection = effectsButton.Activated:Connect(function()
		effectsMuted = not effectsMuted
		if effectsMuted then
			cueVersion += 1
			duckVersion += 1
			ducked = false
			click:Stop()
			note:Stop()
			flourish:Stop()
		end
		update()
	end)
	local audio = {}
	function audio.SetParticipant(value: boolean): ()
		if value == participant then
			return
		end
		participant = value
		update()
	end
	function audio.Layout(width: number, height: number, touch: boolean, view: string): ()
		local portraitMatch = view == "Match" and width < height and width < 760
		local compact = portraitMatch
		for _, button in { musicButton, effectsButton } do
			local icon = button:FindFirstChild("Icon")
			local label = button:FindFirstChild("Label")
			local state = button:FindFirstChild("State")
			if icon and icon:IsA("GuiObject") and label and label:IsA("TextLabel") and state and state:IsA("TextLabel") then
				icon.Position = UDim2.fromOffset(if compact then 5 else 8, if compact then 4 else 4)
				icon.Size = UDim2.fromOffset(if compact then 20 else 26, if compact then 28 else 30)
				label.Position = UDim2.fromOffset(if compact then 29 else 38, if compact then 9 else 10)
				label.Size = UDim2.fromOffset(if compact then 48 else 50, 20)
				label.TextSize = if compact then 10 else 11
				state.Position = UDim2.fromOffset(if compact then 80 else 91, if compact then 9 else 10)
				state.Size = UDim2.fromOffset(if compact then 26 else 29, 20)
				state.TextSize = if compact then 8 else 9
			end
		end
		if portraitMatch then
			local y = height - (if touch then 42 else 38)
			musicButton.Size = UDim2.fromOffset(112, 36)
			effectsButton.Size = UDim2.fromOffset(112, 36)
			musicButton.Position = UDim2.fromOffset(width / 2 - 120, y)
			effectsButton.Position = UDim2.fromOffset(width / 2 + 8, y)
		else
			musicButton.Size = UDim2.fromOffset(128, 40)
			effectsButton.Size = UDim2.fromOffset(128, 40)
			musicButton.Position = UDim2.new(1, -276, 0, 12)
			effectsButton.Position = UDim2.new(1, -12, 0, 12)
		end
	end
	function audio.PlayMark(): ()
		if effectsMuted or not alive then
			return
		end
		markCount += 1
		cueVersion += 1
		local version = cueVersion
		duck(0.65)
		click:Stop()
		click:Play()
		local pitch = ({ 0.94, 1, 1.06 })[(markCount - 1) % 3 + 1] or 1
		note.PlaybackSpeed = pitch
		task.delay(0.07, function()
			if not alive or effectsMuted or cueVersion ~= version then
				return
			end
			note:Stop()
			note:Play()
		end)
		task.delay(0.19, function()
			if not alive or effectsMuted or cueVersion ~= version then
				return
			end
			flourish.PlaybackSpeed = pitch * 1.16
			flourish:Stop()
			flourish:Play()
		end)
		task.delay(0.65, function()
			if not alive or cueVersion ~= version then
				return
			end
			click:Stop()
			note:Stop()
			flourish:Stop()
		end)
	end
	function audio.PlayNearWin(oneAway: boolean): ()
		if effectsMuted or not alive then
			return
		end
		cueVersion += 1
		duck(1.1)
		flourish.PlaybackSpeed = if oneAway then 1.2 else 1.08
		flourish:Stop()
		flourish:Play()
	end
	function audio.PlayWin(): ()
		if effectsMuted or not alive then
			return
		end
		cueVersion += 1
		duck(1.5)
		local version = cueVersion
		note.PlaybackSpeed = 1.12
		note:Stop()
		note:Play()
		task.delay(0.18, function()
			if not alive or effectsMuted or cueVersion ~= version then
				return
			end
			flourish.PlaybackSpeed = 1.38
			flourish:Stop()
			flourish:Play()
		end)
	end
	function audio.Destroy(): ()
		alive = false
		musicConnection:Disconnect()
		effectsConnection:Disconnect()
		music:Destroy()
		click:Destroy()
		note:Destroy()
		flourish:Destroy()
		musicButton:Destroy()
		effectsButton:Destroy()
	end
	return audio
end

return ShowAudio
