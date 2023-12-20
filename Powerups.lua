--[[ SERVICES ]]--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

--[[ VARIABLES ]]--
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local sfx = ReplicatedStorage:WaitForChild("SFX")
local vfx = ReplicatedStorage:WaitForChild("VFX")
local modules = ReplicatedStorage:WaitForChild("Modules")

local blockVFX = vfx:WaitForChild("BlockVFX")

local fovRemotes = remotes:WaitForChild("FOV")
local powerupSound = sfx:WaitForChild("Powerup")

local SPR = require(modules:WaitForChild("SPR"))
local effects = require(modules:WaitForChild("Effects"))

local Powerups = {}
Powerups.__index = Powerups

--[[ CODE ]]--

local function createPowerup(player, powerupName, timer)
	local powerupFolder = player.Powerups
	local powerup = Instance.new("BoolValue", powerupFolder)
	powerup.Name = powerupName
	powerup.Value = true
	game.Debris:AddItem(powerup, timer - .1)	
end

function Powerups.new(obj, powerup, selectedFov, timer)

	local self = setmetatable({}, Powerups)
	self.obj = obj
	self.powerup = powerup
	self.fov = selectedFov
	self.timer = timer

	self.connection = obj.Touched:Connect(function(hit)
		local character = hit:FindFirstAncestorWhichIsA("Model")
		if character then
			self.connection:Disconnect()
			obj:Destroy()
			
			local player = Players:GetPlayerFromCharacter(character)
			if player.PlayerQuests:FindFirstChild("Orbs") then
				player.PlayerQuests.Orbs.QuestProgress.Value += 1
			end
			
			if self.powerup == "Speed" then
				self:Speed(character, self.timer)
			elseif self.powerup == "Jump" then
				self:Jump(character, self.timer)
			elseif self.powerup == "ReduceSpeed" then
				self:ReduceSpeed(character, self.timer)
			elseif self.powerup == "Invencible" then
				self:Invencible(character, self.timer)
			end
		end
	end)

	return self

end

function Powerups:Speed(character, timer)
	local humanoid = character:FindFirstChild("Humanoid")
	if humanoid then
		local player = Players:GetPlayerFromCharacter(character)
		local playerGui = player.PlayerGui
		local notificationFrame = playerGui.GameUI.NotificationFrame
		local powerupsFolder = player.Powerups

		task.spawn(function()
			effects.notificationText("You activated the Super Speed Powerup (5 seconds)", notificationFrame, {Sound = powerupSound, selectedColor = "#61ff6e"})
		end)

		fovRemotes:FireClient(player, self.fov)
		createPowerup(player, "Speed", self.timer)
		SPR.target(humanoid, 1, 2, {
			WalkSpeed = 95
		})

		task.delay(timer, function()
			if #powerupsFolder:GetChildren() == 0 then
				fovRemotes:FireClient(player, 100)
			end

			SPR.target(humanoid, 1, 2, {
				WalkSpeed = 75
			})
		end)
	end
end

function Powerups:ReduceSpeed(character, timer)
	local humanoid = character:FindFirstChild("Humanoid")
	if humanoid then
		local player = Players:GetPlayerFromCharacter(character)
		local playerGui = player.PlayerGui
		local notificationFrame = playerGui.GameUI.NotificationFrame
		local powerupsFolder = player.Powerups

		task.spawn(function()
			effects.notificationText("You activated the Reduced Speed Powerup (5 seconds)", notificationFrame, {Sound = powerupSound, selectedColor = "#ff2424"})
		end)

		fovRemotes:FireClient(player, 70)
		createPowerup(player, "Reduce Speed", self.timer)
		SPR.target(humanoid, 1, 2, {
			WalkSpeed = 50
		})

		task.delay(timer, function()
			if #powerupsFolder:GetChildren() == 0 then
				fovRemotes:FireClient(player, self.fov)
			end
			SPR.target(humanoid, 1, 2, {
				WalkSpeed = 90
			})
		end)
	end
end

function Powerups:Jump(character, timer)
	local humanoid = character:FindFirstChild("Humanoid")
	if humanoid then
		local player = Players:GetPlayerFromCharacter(character)
		local playerGui = player.PlayerGui
		local notificationFrame = playerGui.GameUI.NotificationFrame
		local powerupsFolder = player.Powerups

		task.spawn(function()
			effects.notificationText("You activated the Jump Powerup (5 seconds)", notificationFrame, {Sound = powerupSound, selectedColor = "#61ff6e"})
		end)

		fovRemotes:FireClient(player, self.fov)
		createPowerup(player, "Jump", self.timer)
		SPR.target(humanoid, 1, 2, {
			JumpHeight = 55
		})

		task.delay(timer, function()
			if #powerupsFolder:GetChildren() == 0 then
				fovRemotes:FireClient(player, 100)
			end
			SPR.target(humanoid, 1, 2, {
				JumpHeight = 12
			})
		end)
	end
end

function Powerups:Invencible(character, timer)
	local humanoid = character:FindFirstChild("Humanoid")
	if humanoid then
		local player = Players:GetPlayerFromCharacter(character)
		local playerGui = player.PlayerGui
		local notificationFrame = playerGui.GameUI.NotificationFrame
		local powerupsFolder = player.Powerups

		task.spawn(function()
			effects.notificationText("You activated the Invencible Powerup (5 seconds)", notificationFrame, {Sound = powerupSound, selectedColor = "#61ff6e"})
		end)
		
		effects.applyVFX(character.Torso, blockVFX)
		fovRemotes:FireClient(player, self.fov)
		createPowerup(player, "Invencible", self.timer)
		for i, v in pairs(character:GetDescendants()) do
			if v:IsA("BasePart") then
				if v.Name ~= "HumanoidRootPart" then
					SPR.target(v, 1, 2, {
						Transparency = 0.5
					})
				end
			end
		end

		task.delay(timer, function()
			if #powerupsFolder:GetChildren() == 0 then
				fovRemotes:FireClient(player, 100)
			end

			effects.removeVFX(character.Torso)
			for i, v in pairs(character:GetDescendants()) do
				if v.Name ~= "HumanoidRootPart" then
					if v:IsA("BasePart") then
						SPR.target(v, 1, 2, {
							Transparency = 0
						})
					end
				end
			end			
		end)
	end
end

return Powerups