function init()
  animator.setParticleEmitterOffsetRegion("flames", mcontroller.boundBox())
  animator.setParticleEmitterActive("flames", true)
  effect.setParentDirectives("fade=BF3300=0.25")
  animator.playSound("burn", -1)
  
  script.setUpdateDelta(5)
  
  self.threat = (entity.entityType() == "player") and world.threatLevel()/2 or world.threatLevel() --if its a player, halve the threat damage

  self.baseDamage = 5
  --self.tickDamagePercentage = 0.050
  self.tickTime = 0.5
  self.tickTimer = self.tickTime
end

function update(dt)

  if effect.duration() and world.liquidAt({mcontroller.xPosition(), mcontroller.yPosition() - 1}) then
    if world.liquidAt({mcontroller.xPosition(), mcontroller.yPosition() - 1})[1] == 5 then
      world.spawnLiquid(entity.position(), 2, 1)
    end
    effect.expire()
  end

  local sourceID = effect.sourceEntity()
  local activeStatus = status.activeUniqueStatusEffectSummary()

  for i = 1, #activeStatus do
    if activeStatus[i][1] == "weakpoison" then
      status.addEphemeralEffect("st_poisongas", nil, sourceID)
    elseif activeStatus[i][1] == "frostslow" then
      status.addEphemeralEffect("st_armorshatter", nil, sourceID)
    elseif activeStatus[i][1] == "electrified" then
      status.addEphemeralEffect("st_conductor", nil, sourceID)
    end
  end
  self.tickTimer = self.tickTimer - dt
  if self.tickTimer <= 0 then

    self.tickTimer = self.tickTime
    status.applySelfDamageRequest({
        damageType = "damage",
        damage = 1 + (self.threat * self.baseDamage),
        damageSourceKind = "fire",
        sourceEntityId = entity.id()
      })
  end
end

function uninit()
  
end
