--[[

[number] EmitCount (default 1) - How many particles should this ParticleEmitter emit? (EmitCountScale affects this.) (-1 acts like "Enabled" property)
[number] Delay (default 0) - How long should the particles delay *t* before emitting EmitCount?
[number] Scale (default 1) - How large should the particles that come out of this ParticleEmitter be? (ParticleScale affects this.)

[CastObject] ParticleCast.new([BasePart] | [Model] | [Attachment] Originator, [table] Options?)
> - Returns a [CastObject] which is used for all the other methods.
> - "Options" [table] is optional since there are defaults: 
> ---- [number] ParticleScale (default 1) - Base scale of all particles. (ex. "2" - All particles are now twice as large)
> ---- [number] EmitCountScale (default 1) - Base EmitCount scale of all particles. (ex. "2" - All particles emit twice as many particles as they normally do)

[void] CastObject:Emit()
> - Emits particles based on the attributes listed above (if the ParticleEmitter has any) as well as the "Options" table. 

[void] CastObject:Cleanup()
> - Cleans up the [CastObject], clearing the whole [CastObject] of any references, tables, etc. Every ParticleEmitter's Properties are reset back to their original state. 


]]

export type Cast = {
	ScaleParticle: (Particle: ParticleEmitter, Scale: number) -> nil;
	Emit: () -> nil;
	Cleanup: () -> nil;
	CleanParticle: (Particle: ParticleEmitter, Index: number, ParticleTable: {[string]: any}) -> nil;
};

local CastResource = {};
CastResource.__index = CastResource;

function CastResource.new(Originator: Model | BasePart | Attachment, Options: table): Cast
	assert(Originator, "Originator must be present! (Model | BasePart | Attachment)")

	if Originator:IsA("Model") then 
		assert(Originator.PrimaryPart, "Primary Part must be given for ParticleCast!");  
	end

	local self: table = setmetatable({}, CastResource);

	self.Originator = Originator:IsA("Model") and Originator.PrimaryPart or Originator;
	self.Particles = {};

	self.ParticleScale = Options and Options.ParticleScale or 1; -- Scale of particles
	self.EmitCountScale = Options and Options.EmitCountScale or 1; -- Scale of particle emission
	self.ClearResidue = Options and Options.ClearResidue or false; -- Should particles :Clear()? 

	if self.Originator then 
		for Index, Particle in pairs(self.Originator:GetDescendants()) do
			if Particle:IsA("ParticleEmitter") then 
				local EmitScale: number | nil = Particle:GetAttribute("Scale");

				self.Particles[Index] = {
					Object = Particle; 
					Size = Particle.Size;
					Speed = Particle.Speed;
					Acceleration = Particle.Acceleration;
				};

				if self.ParticleScale > 1 then 
					EmitScale = EmitScale and EmitScale + self.ParticleScale or self.ParticleScale;

					self:ScaleParticle(Particle, EmitScale);
				end
				
				if Particle.Enabled then 
					Particle.Enabled = false;
				end
			end
		end
	end

	return self :: Cast;
end

function CastResource:ScaleParticle(Particle: ParticleEmitter, Scale: number): Cast
	if Particle:IsA("ParticleEmitter") then 
		local Keypoints: table = {};

		for Index, Keypoint in ipairs(Particle.Size.Keypoints) do 
			Keypoints[Index] = NumberSequenceKeypoint.new(Keypoint.Time, Keypoint.Value * Scale, Keypoint.Envelope * Scale);
		end

		Particle.Size = NumberSequence.new(Keypoints);
		Particle.Speed = NumberRange.new(Particle.Speed.Min * Scale, Particle.Speed.Max * Scale);
		Particle.Acceleration *= Scale;
	end
end;

function CastResource:Emit(): Cast
	local EmitCountScale = self.EmitCountScale;

	for Index, ParticleTable in pairs(self.Particles) do 
		local Particle: ParticleEmitter = ParticleTable.Object;
		local EmitCount: number | nil = Particle:GetAttribute("EmitCount");
		local EmitDelay: number | nil = Particle:GetAttribute("Delay");
		local CleanupDelay: number | nil = Particle:GetAttribute("CleanupDelay");
		
		if EmitCount then 
			if EmitDelay and EmitDelay > 0 then 
				if EmitCount == -1 then 
					task.delay(EmitDelay, function() Particle.Enabled = true; end);
				else 
					task.delay(EmitDelay, function() Particle:Emit(EmitCount * EmitCountScale or 1); end);
				end
			else 
				if EmitCount == -1 then 
					Particle.Enabled = true;
				else 
					Particle:Emit(EmitCount * EmitCountScale or 1);
				end
			end
		end

		if CleanupDelay and CleanupDelay > 0 then 
			task.delay(CleanupDelay, self:CleanParticle(Particle, Index, ParticleTable));
		end
	end
end;

function CastResource:CleanParticle(Particle: ParticleEmitter, Index: number, ParticleTable: {[string]: any}): nil 
	Particle.Size = ParticleTable.Size;
	Particle.Speed = ParticleTable.Speed;
	Particle.Acceleration = ParticleTable.Acceleration;
	
	if self.ClearResidue then 
		Particle:Clear();
	end

	if Particle.Enabled then 
		Particle.Enabled = false;
	end

	table.remove(ParticleTable, Index);
end

function CastResource:Cleanup(): Cast
	for Index, ParticleTable in pairs(self.Particles) do 
		local Particle: ParticleEmitter = ParticleTable.Object; 

		self:CleanParticle(Particle, Index, ParticleTable);
	end

	table.clear(self);
	setmetatable(self, nil);
	self = nil;
end;

return CastResource
