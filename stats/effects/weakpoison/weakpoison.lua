require "/scripts/util.lua"

function init()
  animator.setParticleEmitterOffsetRegion("drips", mcontroller.boundBox())
  animator.setParticleEmitterActive("drips", true)

  script.setUpdateDelta(5)
  
  self.threat = (entity.entityType() == "player") and world.threatLevel()/2 or world.threatLevel() --if its a player, halve the threat damage

  self.baseDamage = 1.5
  --self.tickDamagePercentage = 0.02 deprecated
  self.tickTime = 1.0
  self.tickTimer = self.tickTime
end

function update(dt)
  self.tickTimer = self.tickTimer - dt

  if self.tickTimer <= 0 then
    self.tickTimer = self.tickTime
    status.applySelfDamageRequest({
        damageType = "IgnoresDef",
        damage = 1 + (self.threat * self.baseDamage), --fixed damage based on threat level of planet
        damageSourceKind = "poison",
        sourceEntityId = entity.id()
      })
  end

  effect.setParentDirectives(string.format("fade=00AA00=%.1f", self.tickTimer * 0.4))
end

function uninit()

end
