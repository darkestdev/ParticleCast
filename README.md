# ParticleCast

ParticleCast is a resource with many helpful methods that utilizes Attributes and allows for easy management of a ParticleEmitter Instance. It was made with simplicity of use in mind.

**API is listed below!**

### Resource Support

This resource is compatible with any framework! 

[PartCache](https://devforum.roblox.com/t/partcache-for-all-your-quick-part-creation-needs/246641) support is implemented into this resource. 

## Basic Usage

First you have to require ParticleCast:

```lua
local ParticleCast = require(ReplicatedStorage.ParticleCast)
```

Once ParticleCast is required, you can use it to manage particles easily! 

An example of its usage is provided below:

```lua
-- Part is referenced below. This can be a BasePart, Attachment or Model. 
local Part = workspace.BasePart

-- The CastObject is returned from the .new() constructor. We named the constructor 'Particles' in this case!
local Particles = ParticleCast.new(Part, {ParticleScale = 1.5})

-- A function that emits particles. 
function EmitParticles()
    -- Emit all the ParticleEmitters from the CastObject.
    Particles:Emit()

    -- Yield for ~2 seconds.
    task.wait(2)

    -- Cleans up the ParticleEmitters. 
    Particles:Cleanup()
end

--After 10 seconds, call :Destroy() on the CastObject.
task.delay(10, function()
    Particles:Destroy()
end)

-- Calls the EmitParticles() function approximately every second.
while true do
     -- If :Destroy() was called on the CastObject, it is no longer usable, so we end the loop. 
    if not Particles then
        break
    end
    
    EmitParticles()
    
    task.wait(1)
end
```

# ParticleCast API

The documentation on how to use ParticleCast is explained below.  

## Attributes

ParticleCast takes advantage of [Instance Attributes](https://developer.roblox.com/en-us/articles/instance-attributes). 
When you give it an Originator (BasePart, Model or Attachment), all the ParticleEmitter descendants inside of it can have the attributes with names listed below. 
You can customize each ParticleEmitter very easily based on these different attributes! It's so useful for programming visual effects!

**If the attribute does not exist or the ParticleEmitter does not have a value for these attributes, it uses the *default***. 

### *[number]* EmitCount *[default: 0]*
- How many particles should this ParticleEmitter emit when `:Emit()` is called? 
  - ***EmitCountScale** affects this attribute.*
  - ***-1** acts like the .Enabled property of a ParticleEmitter Instance.*

### *[number]* Delay *[default: 0]* 
- How long should this ParticleEmitter delay before it emits its particles? 
  - *Setting this attribute to '0' causes it to have no delay once `:Emit()` is called.* 

### *[number]* Scale *[default: 1]*
- How large should the particles that come out of this ParticleEmitter be? 
  - ***ParticleScale** affects this attribute.*

### *[number]* CleanupDelay *[default: 0]*
- Should the particle clean itself up automatically after a certain amount of time? This means that any leftover particles from this ParticleEmitter still visible are cleared up after the provided delay. 
  - *`:Clear()` is ran on the ParticleEmitter if the 'ClearResidue' attribute is **true***
  - ***ClearAllResidue** causes all ParticleEmitter Instances to `:Clear()` on delay.*
  - *The .Enabled property of the ParticleEmitter is set to false.* 

### *[boolean]* ClearResidue *[default: false]*
- Should `:Clear()` be called on this ParticleEmitter once `CastObject:Destroy()` is called, or after the time provided in *CleanupDelay*? 
  - *Clearing residue means cleaning up the leftover particles still visible after the ParticleEmitter emits all of its particles.*
  
## Constructors

Constructors return a `CastObject` which is used for all the **Methods** provided in the headline below this one. 

### *[function]* ParticleCast.new(Originator: BasePart | Model | Attachment, Options: table) -> CastObject
- Returns a `CastObject` that is used for all of the **Methods**. 
  - *Options* table can be provided full of different options below:

#### *[number]* ParticleScale *[default: 1]* 
- All ParticleEmitter Instances from the 'Originator' are scaled with this property initially. 

#### *[number]* EmitCountScale *[default: 1]*
- Scale of how many particles are emitted once `:Emit()` is called on the `CastObject`. 

#### *[boolean]* ClearAllResidue *[default: false]*
- Works just like the 'ClearResidue' Attribute explained above, but for **all** ParticleEmitter Instances in the Originator. 

## Methods

All of these methods should be used on the `CastObject` returned from `ParticleCast.new()`. 

It is advised to call `:Destroy()` on a `CastObject` after it is no longer used. This sets it up for garbage collection, while also reseting all of the ParticleEmitter's properties back to normal.  

Calling `:Cleanup()` on a `CastObject` cleans all the particles instantly, just like the 'CleanupDelay', but all of them are instantly cleaned.

### *[void]* CastObject:Emit()
- Starts emitting particles based on all the attributes of each ParticleEmitter Instance, as well as the 'Options' table. 

### *[void]* CastObject:Cleanup()
- Cleans up the whole `CastObject`, after cleaning up, you can use `:Emit()` again, instead of creating a new `ParticleCast.new()` constructor. 
  - *This works similar to the [PartCache](https://devforum.roblox.com/t/partcache-for-all-your-quick-part-creation-needs/246641) resource's `:ReturnPart()` method!* 

### *[void]* CastObject:Destroy()
- This sets up the `CastObject` for garbage collection, resets all of the ParticleEmitter's properties back to what they were when the `CastObject` was created. 
  - *You should only call this when you never need the reference to `CastObject` again.* 
