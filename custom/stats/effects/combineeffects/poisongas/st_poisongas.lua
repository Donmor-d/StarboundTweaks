function init()
  animator.playSound("proc")
  animator.setParticleEmitterOffsetRegion("drips", mcontroller.boundBox())
  animator.setParticleEmitterActive("drips", true)
  effect.setParentDirectives("fade=EBFF7D=0.25")

  self.sourceTeam = world.entityDamageTeam(effect.sourceEntity())

  script.setUpdateDelta(5)

  self.tickDamagePercentage = 0.025
  self.tickTime = 0.5
  self.tickTimer = self.tickTime
end

function update(dt)
  status.removeEphemeralEffect("weakpoison")
  status.removeEphemeralEffect("burning")

  self.tickTimer = self.tickTimer - dt

  local gasPower = math.floor(status.resourceMax("health") * self.tickDamagePercentage) + 1  

  local x = math.random(-10, 10) / 10
  local y = math.random(-10, 10) / 10
  local direction = {x, y}

  if self.tickTimer <= 0 then
    self.tickTimer = self.tickTime
    status.applySelfDamageRequest({
      damageType = "IgnoresDef",
      damage = gasPower,
      damageSourceKind = "poison",
      sourceEntityId = entity.id()
    })
    world.spawnProjectile(
          "largepoisoncloud",
          mcontroller.position(),
          entity.id(),
          direction,
          false,
          {
            power = gasPower,
            damageTeam = self.sourceTeam,
            damageType = "IgnoresDef",
            speed = math.random(5, 25)
          }
        )
    animator.playSound("gas")
  end

end

function uninit()

end
