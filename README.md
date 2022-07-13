# ParticleCast

ParticleCast is a resource with many helpful methods that utilizes Attributes and allows for easy management of a ParticleEmitter Instance. It was made with simplicity of use in mind.

The documentation can be found here: ...

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

-- The CastObject is returned from the .new() constructor, {} Options are passed through here. 
local CastObject = ParticleCast.new(Part, {ParticleScale = 1.5})

-- Emit all the ParticleEmitters from the Part.
CastObject:Emit()

-- Yield for ~2 seconds.
task.wait(2)

-- Cleanup the CastObject completely, resetting the ParticleEmitters back to normal. 

CastObject:Cleanup()
```
