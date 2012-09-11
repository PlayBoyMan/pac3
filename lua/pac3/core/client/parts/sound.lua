local PART = {}

PART.ClassName = "sound"
PART.NonPhysical = true

pac.StartStorableVars()
	pac.GetSet(PART, "Sound", "")
	pac.GetSet(PART, "Volume", 1)
	pac.GetSet(PART, "Pitch", 1)
	pac.GetSet(PART, "MinPitch", 100)
	pac.GetSet(PART, "MaxPitch", 100)
pac.EndStorableVars()

function PART:Initialize()
	self:PlaySound()
end

function PART:OnRemove()
	self:StopSound()
end

function PART:OnShow()
	self:PlaySound()
end

function PART:OnHide()
	self:StopSound()
end

function PART:OnThink()
	if self:IsHiddenEx() then
		self:StopSound()
	else
		if not self.csptch or not self.csptch:IsPlaying() then
			self:PlaySound()
		end
	end
end

-- fixes by Python 1320

-- Sound protection. TODO: MAKE A BETTER FIX. Iterative removal of the special characters?
-- This will make special sound effects break if used directly from lua, but I doubt this is common.
-- Won't protect engine but engine shouldn't do this anyway.
-- TODO: Beta new sound functions

-- https://developer.valvesoftware.com/wiki/Soundscripts#Sound_Characters
-- we are using this for bad replacements as it won't break stuff too badly ["*"]=true,   

local bad = 
{ 
	["#"]=true,
	["@"]=true,
	[">"]=true,
	["<"]=true,
	["^"]=true,
	[")"]=true,
	["}"]=true,
	["$"]=true,
	["!"]=true,
	["?"]=true, -- especially bad
}

local function fix(snd)
	if bad[snd:sub(1,1)] then
		snd = snd:gsub("^(.)",function() return "*" end)
	end
	if bad[snd:sub(2,2)] then
		snd = snd:gsub("^(..)",function(a) return a[1].."*" end)
	end	
	return snd
end
	
function PART:SetSound(str)
	if type(str) ~= "string" then self.Sound = "" return end

	if bad[str:sub(1,1)] or bad[str:sub(2,2)] then
		str = fix(str)
	end

	self.Sound = str:gsub("\\", "/")
end

function PART:SetVolume(num)
	if num > 1 then
		num = num / 100
	end
	
	self.Volume = math.Clamp(num, 0, 1)
	
	if not self.csptch then
		self:PlaySound()
	end
	
	if self.csptch then
		self.csptch:ChangeVolume(self.Volume)
	end
end

function PART:SetPitch(num)
	self.Pitch = math.Clamp(num*255, 0, 255)
	
	if not self.csptch then
		self:PlaySound()
	end
	
	if self.csptch then
		self.csptch:ChangePitch(self.Pitch)
	end
end

function PART:PlaySound()
	local ent = self:GetOwner()

	if ent:IsValid() then
		local snd = self.Sound:gsub(
			"(%[%d-,%d-%])", 
			function(minmax) 
				local min, max = minmax:match("%[(%d-),(%d-)%]")
				if max < min then
					max = min
				end
				return math.random(min, max) 
			end
		)
		
		if self.csptch then
			self.csptch:Stop()
		end
		
		local csptch = CreateSound(self:GetPlayerOwner(), snd)
		csptch:PlayEx(self.Volume, math.random(self.MinPitch, self.MaxPitch))		
		ent.pac_csptch = csptch
		self.csptch = csptch
	end
end

function PART:StopSound()
	local ent = self:GetOwner()

	if self.csptch then
		self.csptch:Stop()
	end
end

pac.RegisterPart(PART)