function init()
  animator.setParticleEmitterOffsetRegion("icetrail", mcontroller.boundBox())
  animator.setParticleEmitterActive("icetrail", true)
  effect.setParentDirectives("fade=00BBFF=0.15")
  
  script.setUpdateDelta(5)
  status.setResource("stunned", 50)
  animator.setSoundVolume("freeze", 5)
  animator.playSound("freeze", 0)
end

function uninit()
  status.setResource("stunned", 0)
end
