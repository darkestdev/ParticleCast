export type Cast = {
	ScaleParticle: (Particle: ParticleEmitter, Scale: number) -> nil;
	Emit: () -> nil;
	Cleanup: () -> nil;
    Destroy: () -> nil;
	CleanParticle: (Particle: ParticleEmitter, Index: number, ParticleTable: {[string]: any}) -> nil;
};

local CastResource: {any} = {};
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
	self.ClearAllResidue = Options and Options.ClearAllResidue or false; -- Should particles :Clear()? 

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
		local EmitCount: number | nil = Particle:GetAttribute("EmitCount") or 1;
		local EmitDelay: number | nil = Particle:GetAttribute("Delay");
        local CleanupDelay: number | nil = Particle:GetAttribute("CleanupDelay");

        ParticleTable.Cleaned = false;
		
		if EmitCount then 
			if EmitDelay and EmitDelay > 0 then 
				if EmitCount == -1 then 
					task.delay(EmitDelay, function() 
                        if ParticleTable.Cleaned then -- If particle is already cleaned, do not emit. 
                            return;
                        end; 
                        
                        Particle.Enabled = true; 
                    end);
				else 
					task.delay(EmitDelay, function() 
                        if ParticleTable.Cleaned then -- If particle is already cleaned, do not emit. 
                            return;
                        end; 
                        
                        Particle:Emit(EmitCount * EmitCountScale or 1); 
                    end);
				end
			else 
				if EmitCount == -1 then 
					Particle.Enabled = true;
				else 
					Particle:Emit(EmitCount * EmitCountScale or 1);
				end
			end

            if CleanupDelay and CleanupDelay > 0 then 
                task.delay(CleanupDelay, self:CleanParticle(Particle, Index, ParticleTable));
            end;
		end
	end
end;

function CastResource:CleanParticle(Particle: ParticleEmitter, Index: number, ParticleTable: {[string]: any}): nil 
	if self.ClearAllResidue or Particle:GetAttribute("ClearResidue") then 
		Particle:Clear();
	end

	if Particle.Enabled then 
		Particle.Enabled = false;
	end

	ParticleTable.Cleaned = true;
end 

function CastResource:Cleanup(): Cast
	for Index, ParticleTable in pairs(self.Particles) do 
		local Particle: ParticleEmitter = ParticleTable.Object;

        self:CleanParticle(Particle, Index, ParticleTable);
	end
end;

function CastResource:Destroy(): Cast
    for Index, ParticleTable in pairs(self.Particles) do 
		local Particle: ParticleEmitter = ParticleTable.Object;

        Particle.Size = ParticleTable.Size;
        Particle.Speed = ParticleTable.Speed;
        Particle.Acceleration = ParticleTable.Acceleration;
        
        table.remove(self.Particles, Index);
    end;
	

	table.clear(self);
	setmetatable(self, nil);
	self = nil;
end;

return CastResource
