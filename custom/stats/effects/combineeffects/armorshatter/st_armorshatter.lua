function init()
  effect.setParentDirectives("fade=3BB55C=0.15")

  effect.addStatModifierGroup({
    {stat = "protection", effectiveMultiplier = config.getParameter("protectionMultipier", 0.5)}  --halves armor
  })

  local threat = (entity.entityType() == "player") and world.threatLevel()/2 or world.threatLevel() --if its a player, halve the threat damage

  local sourceTeam = world.entityDamageTeam(effect.sourceEntity())
  local bombPower = 5 + math.floor(config.getParameter("damageFactor", 25) * threat) --status.resourceMax("health") * config.getParameter("healthDamageFactor", 1.0)
  local projectileConfig = {
    power = bombPower,
    damageTeam = sourceTeam,
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
