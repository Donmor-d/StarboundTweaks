function init()
  animator.playSound("proc")
  animator.setParticleEmitterOffsetRegion("drips", mcontroller.boundBox())
  animator.setParticleEmitterActive("drips", true)
  effect.setParentDirectives("fade=329632=0.15")

  script.setUpdateDelta(5)
  
  local threat = (entity.entityType() == "player") and world.threatLevel()/2 or world.threatLevel() --if its a player, halve the threat damage
  
  status.applySelfDamageRequest({
        damageType = "IgnoresDef",
        damage = 5 + (10 * threat),
        damageSourceKind = "poison",
        sourceEntityId = entity.id()
      })
      
  effect.addStatModifierGroup({{stat = "maxHealth", effectiveMultiplier = 0.75}}) --multiplies health by 0.75
end

function update(dt)
  status.removeEphemeralEffect("weakpoison")
  status.removeEphemeralEffect("frostslow")

  status.overConsumeResource("food", 0.5)
  mcontroller.controlModifiers({
    groundMovementModifier = 0.3,
    speedModifier = 0.5,
    airJumpModifier = 0.1,
    runningSuppressed = true
  })
end

function uninit()

end
