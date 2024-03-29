require "/scripts/util.lua"

function init()
  animator.playSound("proc")
  animator.setParticleEmitterOffsetRegion("drips", mcontroller.boundBox())
  animator.setParticleEmitterActive("drips", true)
  effect.setParentDirectives("fade=02C547=0.25")

  script.setUpdateDelta(5)

  self.threat = (entity.entityType() == "player") and world.threatLevel()/2 or world.threatLevel() --if its a player, halve the threat damage

  self.baseDamage = 2
  --self.tickDamagePercentage = 0.025 deprecated
  self.tickTime = 0.25
  self.tickTimer = self.tickTime
end

function update(dt)
  status.removeEphemeralEffect("weakpoison")
  status.removeEphemeralEffect("electrified")

  self.tickTimer = self.tickTimer - dt
  if self.tickTimer <= 0 then
    self.tickTimer = self.tickTime

    status.applySelfDamageRequest({
        damageType = "IgnoresDef",
        damage = 1 + (self.threat * self.baseDamage),
        damageSourceKind = "poison",
        sourceEntityId = entity.id()
      })

    local sourceEntityId = effect.sourceEntity() or entity.id()
    local sourceDamageTeam = world.entityDamageTeam(sourceEntityId)
    local directionTo = { math.random(-10, 10) / 10, math.random(5, 10) / 10}
    world.spawnProjectile(
      "st_corrosivechunk",
      mcontroller.position(),
      entity.id(),
      directionTo,
      false,
      {
        power = 1 + (self.threat * self.baseDamage),
        damageTeam = sourceDamageTeam,
        statusEffects = config.getParameter("statusEffects"),
        piercing = false,
        timeToLive = 5
      }
    )
    animator.playSound("spit")
  end
end

function uninit()

end
