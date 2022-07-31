require "/scripts/util.lua"

function init()
  animator.setParticleEmitterOffsetRegion("sparks", mcontroller.boundBox())
  animator.setParticleEmitterActive("sparks", true)
  effect.setParentDirectives("fade=7733AA=0.25")

  script.setUpdateDelta(5)

  self.damageClampRange = config.getParameter("damageClampRange")

  self.tickTime = config.getParameter("boltInterval", 1.0)
  self.tickTimer = self.tickTime
end

function update(dt)
  

  status.overConsumeResource("energy", 0.75) --drains energy 

  local sourceID = effect.sourceEntity()
  local activeStatus = status.activeUniqueStatusEffectSummary()

  for i = 1, #activeStatus do
    if activeStatus[i][1] == "weakpoison" then
      status.addEphemeralEffect("st_corrosion", nil, sourceID)
    elseif activeStatus[i][1] == "frostslow" then
      status.addEphemeralEffect("st_magnetic", nil, sourceID)
    end
  end


  self.tickTimer = self.tickTimer - dt
  local boltPower = util.clamp(status.resourceMax("health") * config.getParameter("healthDamageFactor", 1.0), self.damageClampRange[1], self.damageClampRange[2])
  if self.tickTimer <= 0 then
    self.tickTimer = self.tickTime
    local targetIds = world.entityQuery(mcontroller.position(), config.getParameter("jumpDistance", 8), {
      withoutEntityId = entity.id(),
      includedTypes = {"creature"}
    })

    shuffle(targetIds)

    if effect.duration() and world.liquidAt({mcontroller.xPosition(), mcontroller.yPosition() - 1}) then --if underwater, damage player and halve the timer to damage
      status.applySelfDamageRequest({
        damageType = "damage",
        damage = boltPower,
        damageSourceKind = "electric",
        sourceEntityId = entity.id()
      })
      self.tickTimer = self.tickTime/2
    end

    for i,id in ipairs(targetIds) do
      local sourceEntityId = effect.sourceEntity() or entity.id()
      if world.entityCanDamage(sourceEntityId, id) and not world.lineTileCollision(mcontroller.position(), world.entityPosition(id)) then
        local sourceDamageTeam = world.entityDamageTeam(sourceEntityId)
        local directionTo = world.distance(world.entityPosition(id), mcontroller.position())
        world.spawnProjectile(
          "teslaboltsmall",
          mcontroller.position(),
          entity.id(),
          directionTo,
          false,
          {
            power = boltPower,
            damageTeam = sourceDamageTeam
          }
        )
        animator.playSound("bolt")
        return
      end
    end 
  end
end