require "/scripts/util.lua"
require "/scripts/status.lua"

function init()
  if status.isResource("energy") then
    status.setResourcePercentage("energy", 0)
  end
  effect.setParentDirectives("fade=6464FF=0.25")
  animator.playSound("proc")

  script.setUpdateDelta(5)

  self.tickTime = 0.6
  self.tickTimer = self.tickTime
end

function update(dt)
  status.removeEphemeralEffect("frostslow")
  status.removeEphemeralEffect("electrified")

  mcontroller.controlModifiers({
      groundMovementModifier = 0.5,
      speedModifier = 0.5,
      airJumpModifier = 0.85
    })

  self.tickTimer = self.tickTimer - dt

  if self.tickTimer <= 0 then
    self.tickTimer = self.tickTime
    animator.playSound("pull")

    local sourceEntityId = effect.sourceEntity() or entity.id()
    local sourceDamageTeam = world.entityDamageTeam(sourceEntityId)
    world.spawnProjectile(
      "magneticpull",
      mcontroller.position(),
      entity.id(),
      {0, 0},
      true,
      {
      }
    )
  end
end

function uninit()

end