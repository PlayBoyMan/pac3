local PART = {}

PART.ClassName = "trail"

pac.StartStorableVars()
	pac.GetSet(PART, "Length", 100)
	pac.GetSet(PART, "Spacing", 1)
	pac.GetSet(PART, "StartSize", 3)
	pac.GetSet(PART, "EndSize", 0)
	pac.GetSet(PART, "StartColor", Vector(255, 255, 255))
	pac.GetSet(PART, "EndColor", Vector(255, 255, 255))
	pac.GetSet(PART, "StartAlpha", 1)
	pac.GetSet(PART, "EndAlpha", 1)
	pac.GetSet(PART, "Stretch", false)
	pac.GetSet(PART, "TrailPath", "trails/laser")
pac.EndStorableVars()

PART.LastAdd = 0

function PART:Initialize()
	self.StartColorC = Color(255, 255, 255, 255)
	self.EndColorC = Color(255, 255, 255, 255)
	self:SetTrailPath(self.TrailPath)
end

function PART:SetStartColor(v)
	self.StartColorC = self.StartColorC or Color(255, 255, 255, 255)
	
	self.StartColorC.r = v.r
	self.StartColorC.g = v.g
	self.StartColorC.b = v.b
	
	self.StartColor = v
end

function PART:SetEndColor(v)
	self.EndColorC = self.EndColorC or Color(255, 255, 255, 255)
	
	self.EndColorC.r = v.r
	self.EndColorC.g = v.g
	self.EndColorC.b = v.b
	
	self.EndColor = v
end

function PART:SetStartAlpha(n)
	self.StartColorC = self.StartColorC or Color(255, 255, 255, 255)
	
	self.StartColorC.a = n * 255
	
	self.StartAlpha = n
end

function PART:SetEndAlpha(n)
	self.EndColorC = self.EndColorC or Color(255, 255, 255, 255)
	
	self.EndColorC.a = n * 255
	
	self.EndAlpha = n
end

function PART:SetTrailPath(var)
	self:SetMaterial(var)
end

function PART:SetMaterial(var)
	if type(var) == "string" then
		self.Trail = Material(var)
	elseif type(var) == "IMaterial" then
		self.Trail = var
	end

	self.TrailPath = var
end

function PART:OnAttach()
	self.points = {}
end

function PART:OnDetach()
	self.points = {}
end

function PART:OnDraw(owner, pos, ang)
	if self.Trail and self.StartColorC and self.EndColorC then
	
		self.points = self.points or {}
		
		if self.Spacing == 0 or self.LastAdd < RealTime() then
			table.insert(self.points, pos)
			self.LastAdd = RealTime() + self.Spacing / 1000
		end
		
		local len = tonumber(self.Length)
		local count = #self.points
		
		if self.Spacing > 0 then
			len = math.ceil(math.abs(len - self.Spacing))
		end
		
		render.SetMaterial(self.Trail)
		
		render.StartBeam(count)
			for k, v in pairs(self.points) do
				width = k / (len / self.StartSize)
				
				local coord = (1/count) * (k - 1)
				local color = Color(255, 255, 255, 255)
				
				color.r = Lerp(coord, self.EndColorC.r, self.StartColorC.r)
				color.g = Lerp(coord, self.EndColorC.g, self.StartColorC.g)
				color.b = Lerp(coord, self.EndColorC.b, self.StartColorC.b)
				color.a = Lerp(coord, self.EndColorC.a, self.StartColorC.a)
				
				render.AddBeam(k == count and pos or v, width + self.EndSize, self.Stretch and coord or width, color)
			end
		render.EndBeam()		
		
		if count >= len then 
			table.remove(self.points, 1) 
		end
	end
end

pac.RegisterPart(PART)