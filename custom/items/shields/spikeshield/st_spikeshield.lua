require "/scripts/util.lua"
require "/scripts/status.lua"

function init()
  self.debug = true

  self.aimAngle = 0
  self.aimDirection = 1

  self.active = false
  self.cooldownTimer = config.getParameter("cooldownTime")
  self.activeTimer = 0

  self.level = config.getParameter("level", 1)
  self.baseShieldHealth = config.getParameter("baseShieldHealth", 1)
  self.knockback = config.getParameter("knockback", 0)
  self.perfectBlockDirectives = config.getParameter("perfectBlockDirectives", "")
  self.perfectBlockTime = config.getParameter("perfectBlockTime", 0.2)
  self.minActiveTime = config.getParameter("minActiveTime", 0)
  self.cooldownTime = config.getParameter("cooldownTime")
  self.forceWalk = config.getParameter("forceWalk", false)

  animator.setGlobalTag("directives", "")
  animator.setAnimationState("shield", "idle")
  activeItem.setOutsideOfHand(true)

  self.stances = config.getParameter("stances")
  
  self.projectile = config.getParameter("parryProjectile")
  self.projectileParameters = config.getParameter("projectileParameters", {})
  self.projectileDamage = config.getParameter("parryDamage", 0)
  self.parryEffects = config.getParameter("parryEffects")
  
  self.parryMultiplier = config.getParameter("parryMultiplier", 1)
  self.changeHealth = true
  setStance(self.stances.idle)

  --dash stuff
  self.dashSpeed = config.getParameter("dashSpeed", 50)
  self.airDashing = false
  self.dashing = false

  updateAim()
end

function update(dt, fireMode, shiftHeld)
  self.cooldownTimer = math.max(0, self.cooldownTimer - dt)

  if not self.active
    and fireMode == "primary"
    and self.cooldownTimer == 0
    and status.resourcePositive("shieldStamina") then

    self.dashing = true
    self.airDashing = not mcontroller.groundMovement()

    raiseShield()
  end

  if self.active then
    self.activeTimer = self.activeTimer + dt

    self.damageListener:update()

    if status.resourcePositive("perfectBlock") then
      if self.dashing then
        animator.setGlobalTag("directives", self.perfectBlockDirectives)
      else
        animator.setGlobalTag("directives", "")
      end
      local dash = self.dashSpeed
      dash = mcontroller.onGround() and dash or dash/2

      if self.airDashing then
        mcontroller.setYVelocity(0)
      end

      mcontroller.controlModifiers({jumpingSuppressed = true})
      mcontroller.controlApproachVelocity({self.dashSpeed * self.aimDirection, 0}, 2000)
    else
      stopDash()
      mcontroller.controlModifiers({jumpingSuppressed = false})

      if self.changeHealth then
        self.changeHealth = false
        status.setPersistentEffects(activeItem.hand().."Shield", {{stat = "shieldHealth", amount = shieldHealth(false)}})
      end
      animator.setGlobalTag("directives", "")

      lowerShield()
    end

    if self.forceWalk then
      mcontroller.controlModifiers({runningSuppressed = true})
    end

    if (fireMode ~= "primary" and self.activeTimer >= self.minActiveTime) or not status.resourcePositive("shieldStamina") then
      lowerShield()
    end
  end

  updateAim()
end

function uninit()
  status.clearPersistentEffects(activeItem.hand().."Shield")
  activeItem.setItemShieldPolys({})
  activeItem.setItemDamageSources({})
end

function updateAim()
  local aimAngle, aimDirection = activeItem.aimAngleAndDirection(0, activeItem.ownerAimPosition())
  
  if self.stance.allowRotate then
    self.aimAngle = aimAngle
  end
  activeItem.setArmAngle(self.aimAngle + self.relativeArmRotation)

  if self.stance.allowFlip then
    self.aimDirection = aimDirection
  end
  activeItem.setFacingDirection(self.aimDirection)

  animator.setGlobalTag("hand", "near")
  activeItem.setOutsideOfHand(true)
end

function isNearHand()
  return (activeItem.hand() == "primary") == (self.aimDirection < 0)
end

function setStance(stance)
  self.stance = stance
  self.relativeShieldRotation = util.toRadians(stance.shieldRotation) or 0
  self.relativeArmRotation = util.toRadians(stance.armRotation) or 0
end

function raiseShield()
  setStance(self.stances.raised)
  animator.setAnimationState("shield", "raised")
  animator.playSound("raiseShield")
  self.active = true
  self.activeTimer = 0
  status.setPersistentEffects(activeItem.hand().."Shield", {{stat = "shieldHealth", amount = shieldHealth(true)}})
  local shieldPoly = animator.partPoly("shield", "shieldPoly")
  activeItem.setItemShieldPolys({shieldPoly})

  if self.knockback > 0 then
    local knockbackDamageSource = {
      poly = shieldPoly,
      damage = util.round(self.projectileDamage * root.evalFunction("weaponDamageLevelMultiplier", self.level), 0),
      damageType = "Knockback",
      sourceEntity = activeItem.ownerEntityId(),
      team = activeItem.ownerTeam(),
      knockback = self.knockback,
      rayCheck = true,
      damageRepeatTimeout = 0.25
    }
    activeItem.setItemDamageSources({ knockbackDamageSource })
  end

  self.damageListener = damageListener("damageTaken", function(notifications)
    for _,notification in pairs(notifications) do
      if notification.hitType == "ShieldHit" then
        if status.resourcePositive("perfectBlock") then
          animator.playSound("perfectBlock")
          animator.burstParticleEmitter("perfectBlock")

          --fire projectile on parry
          if self.projectile then
            fireProjectile()
          end
          if self.parryEffects then
            status.addEphemeralEffects(self.parryEffects)
          end
          --function that applies damage to nearby enemies (or make it so they receive an effect similar to Doomed)
          mcontroller.controlModifiers({jumpingSuppressed = false})
          animator.setGlobalTag("directives", "")
          refreshPerfectBlock()
          stopDash()
          mcontroller.setXVelocity(self.dashSpeed * -self.aimDirection)
          lowerShield()
        elseif status.resourcePositive("shieldStamina") then
          animator.playSound("block")
        else
          animator.playSound("break")
        end
          animator.setAnimationState("shield", "block")
        return
      end
    end
  end)

  refreshPerfectBlock()
end

function stopDash()
  self.dashing = false
  local movementParams = mcontroller.baseParameters()
  local currentVelocity = mcontroller.velocity()

  if math.abs(currentVelocity[1]) > movementParams.runSpeed then
    mcontroller.setVelocity({movementParams.runSpeed * self.aimDirection, 0})
  end
  mcontroller.controlApproachXVelocity(self.aimDirection * movementParams.runSpeed, 2000)
end

function refreshPerfectBlock()
  local perfectBlockTimeAdded = math.max(0, math.min(status.resource("perfectBlockLimit"), self.perfectBlockTime - status.resource("perfectBlock")))
  status.overConsumeResource("perfectBlockLimit", perfectBlockTimeAdded)
  status.modifyResource("perfectBlock", perfectBlockTimeAdded)
end

function lowerShield()
  self.changeHealth = true
  setStance(self.stances.idle)
  animator.setGlobalTag("directives", "")
  animator.setAnimationState("shield", "idle")
  animator.playSound("lowerShield")
  self.active = false
  self.activeTimer = 0
  status.clearPersistentEffects(activeItem.hand().."Shield")
  activeItem.setItemShieldPolys({})
  activeItem.setItemDamageSources({})
  self.cooldownTimer = self.cooldownTime
end

function shieldHealth(perfectBlock)
  return self.baseShieldHealth * root.evalFunction("shieldLevelMultiplier", self.level) * (perfectBlock and self.parryMultiplier or 1)
end

--Spawn projectile on parry
function fireProjectile(projectileType, projectileParams, inaccuracy, firePosition, projectileCount)
  local params = sb.jsonMerge(self.projectileParameters, projectileParams or {})
  params.power = self.projectileDamage
  params.powerMultiplier = activeItem.ownerPowerMultiplier()
  params.speed = util.randomInRange(params.speed)

  if not projectileType then
    projectileType = self.projectile 
  end
  if type(projectileType) == "table" then
    projectileType = projectileType[math.random(#projectileType)]
  end

  local projectileId = 0

  if params.timeToLive then
    params.timeToLive = util.randomInRange(params.timeToLive)
  end

  projectileId = world.spawnProjectile(
      projectileType,
      entity.position(),
      activeItem.ownerEntityId(),
      {0, 0},
      false,
      params
    )

  return projectileId
end