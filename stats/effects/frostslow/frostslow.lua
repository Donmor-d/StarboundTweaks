function init()
  animator.setParticleEmitterOffsetRegion("icetrail", mcontroller.boundBox())
  animator.setParticleEmitterActive("icetrail", true)
  effect.setParentDirectives("fade=00BBFF=0.15")
  
  effect.addStatModifierGroup({{stat = "powerMultiplier", effectiveMultiplier = 0.5}}) --halves damage done by victim

  script.setUpdateDelta(5)
  effect.addStatModifierGroup({
    {stat = "jumpModifier", amount = -0.15}
  })
end

function update(dt)
  mcontroller.controlModifiers({
      groundMovementModifier = 0.3,
      speedModifier = 0.75,
      airJumpModifier = 0.85
    })
end

function uninit()

end