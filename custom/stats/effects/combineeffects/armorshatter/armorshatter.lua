function init()
  effect.setParentDirectives("fade=3BB55C=0.15")

  effect.addStatModifierGroup({
    {stat = "protection", effectiveMultiplier = config.getParameter("protectionMultipier", 0.5)}  --halves armor
  })

  self.sourceTeam = world.entityDamageTeam(effect.sourceEntity())
  local bombPower = status.resourceMax("health") * config.getParameter("healthDamageFactor", 1.0)
  local projectileConfig = {
    power = bombPower,
    damageTeam = self.sourceTeam,
    onlyHitTerrain = true,
    timeToLive = 0,
    actionOnReap = {
      {
        action = "config",
      file = config.getParameter("bombConfig")
      }
    }
  }
  world.spawnProjectile("invisibleprojectile", mcontroller.position(), 0, {0, 0}, false, projectileConfig)

  script.setUpdateDelta(5)
end

function update(dt)
  status.removeEphemeralEffect("frostslow")
  status.removeEphemeralEffect("burning")
end

function uninit()
  
end
