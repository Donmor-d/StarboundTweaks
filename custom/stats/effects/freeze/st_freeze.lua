require "/scripts/util.lua"
require "/scripts/status.lua"

function init()
  animator.setParticleEmitterOffsetRegion("icetrail", mcontroller.boundBox())
  animator.setParticleEmitterActive("icetrail", true)
  effect.setParentDirectives("fade=00BBFF=0.50")
  
  script.setUpdateDelta(5)

  self.triggerDamageThreshold = config.getParameter("triggerDamageThreshold")
  self.damageTaken = 0
  status.setResource("stunned", 50)
  animator.setSoundVolume("freeze", 5)
  animator.playSound("freeze", 0)

  self.frozen = false
end

function update(dt)

  if effect.duration() <= 1 or self.frozen then
    trigger()
    return
  end

  if not self.damageListener and not self.frozen then
    self.damageListener = damageListener("damageTaken", function(notifications)
      local totalDamage = 0
      for _, notification in pairs(notifications) do
        if notification.hitType == "Hit" then
          totalDamage = totalDamage + notification.damageDealt
          self.damageTaken = self.damageTaken + totalDamage

          sb.logWarn(status.resourceMax("health"))

          if self.damageTaken >= status.resourceMax("health") * self.triggerDamageThreshold then
            trigger(true)
          end
        end
      end
    end)

  elseif self.damageListener then
    self.damageListener:update()
  end
end

function trigger(broken)
  if self.frozen then
    return
  end
  self.frozen = true

  local sourceID = effect.sourceEntity()
  status.applySelfDamageRequest({
      damageType = "IgnoresDef",
      damage = self.damageTaken * (broken and 0.25 or 0.12),
      damageSourceKind = "ice",
      damageKind = "ice",
      sourceEntityId = entity.id()
    })

  endFreeze()
end

function endFreeze()

  animator.setSoundVolume("endFreeze", 5)
  animator.playSound("endFreeze", 0)
  status.setResource("stunned", 0)
  
  animator.setParticleEmitterActive("icetrail", false)
  effect.setParentDirectives("fade=00BBFF=0.50")
  effect.setParentDirectives("fade=00BBFF=0")
  
  self.damageListener = nil
  
  status.addEphemeralEffect("st_freezeimmunity", nil, sourceID)
end

function uninit()
end
