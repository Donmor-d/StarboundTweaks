require "/scripts/util.lua"
require "/scripts/status.lua" --for later

-- Melee primary ability
MeleeCombo = WeaponAbility:new()

function MeleeCombo:init()
  self.comboStep = 1
  --listener
  self.damageListener = damageListener("inflictedHits", function() 
    self.fallTimer = 0.35
    self.slowFall = true
  end)
  --
  --add projectile
  self.projectileOffset = self.projectileOffset or {0, 0}

  self.projectileType = self.projectileType or nil
  --
  self.energyUsage = self.energyUsage or 0

  self:computeDamageAndCooldowns()

  self.weapon:setStance(self.stances.idle)

  self.edgeTriggerTimer = 0
  self.flashTimer = 0
  self.cooldownTimer = self.cooldowns[1]

  self.animKeyPrefix = self.animKeyPrefix or ""

  self.slowFall = false
  self.fallTimer = 0.35

  self.weapon.onLeaveAbility = function()
    self.weapon:setStance(self.stances.idle)
  end
end

-- Ticks on every update regardless if this is the active ability
function MeleeCombo:update(dt, fireMode, shiftHeld)
  WeaponAbility.update(self, dt, fireMode, shiftHeld)

  self.damageListener:update()

  if self.cooldownTimer > 0 then
    self.cooldownTimer = math.max(0, self.cooldownTimer - self.dt)
    if self.cooldownTimer == 0 then
      self:readyFlash()
    end
  end

  if self.flashTimer > 0 then
    self.flashTimer = math.max(0, self.flashTimer - self.dt)
    if self.flashTimer == 0 then
      animator.setGlobalTag("bladeDirectives", "")
    end
  end

  self.edgeTriggerTimer = math.max(0, self.edgeTriggerTimer - dt)
  if self.lastFireMode ~= (self.activatingFireMode or self.abilitySlot) and fireMode == (self.activatingFireMode or self.abilitySlot) then
    self.edgeTriggerTimer = self.edgeTriggerGrace
  end
  self.lastFireMode = fireMode

  if not self.weapon.currentAbility and self:shouldActivate() then
    self:setState(self.windup)
  end

  if self.slowFall then
    self.fallTimer = self.fallTimer - dt

    if mcontroller.yVelocity() < -mcontroller.baseParameters().walkSpeed 
    and not self.notSlowInAir 
    and not mcontroller.onGround() 
    and not mcontroller.groundMovement() then
      mcontroller.setVelocity({util.clamp(mcontroller.xVelocity(), -mcontroller.baseParameters().walkSpeed, mcontroller.baseParameters().walkSpeed), -2})
    end

    if self.fallTimer < 0 then
      self.fallTimer = 0.25
      self.slowFall = false
    end
  end
end

-- State: windup
function MeleeCombo:windup()
  local stance = self.stances["windup"..self.comboStep]

  self.weapon:setStance(stance)

  self.edgeTriggerTimer = 0

  if stance.hold then
    while self.fireMode == (self.activatingFireMode or self.abilitySlot) do
      coroutine.yield()
    end
  else
    util.wait(stance.duration)
  end

  if self.energyUsage then
    status.overConsumeResource("energy", self.energyUsage)
  end

  if self.stances["preslash"..self.comboStep] then
    self:setState(self.preslash)
  else
    self:setState(self.fire)
  end
end

-- State: wait
-- waiting for next combo input
function MeleeCombo:wait()
  local stance = self.stances["wait"..(self.comboStep - 1)]

  self.weapon:setStance(stance)

  util.wait(stance.duration, function()
    if self:shouldActivate() then
      self:setState(self.windup)
      return
    end
  end)

  self.cooldownTimer = math.max(0, self.cooldowns[self.comboStep - 1] - stance.duration)
  self.comboStep = 1
end

-- State: preslash
-- brief frame in between windup and fire
function MeleeCombo:preslash()

  local stance = self.stances["preslash"..self.comboStep]

  self.weapon:setStance(stance)
  self.weapon:updateAim()

  util.wait(stance.duration)

  self:setState(self.fire)
end

-- State: fire
function MeleeCombo:fire()

  local stance = self.stances["fire"..self.comboStep]

  self.weapon:setStance(stance)
  self.weapon:updateAim()

  local animStateKey = self.animKeyPrefix .. (self.comboStep > 1 and "fire"..self.comboStep or "fire")
  animator.setAnimationState("swoosh", animStateKey)
  animator.playSound(animStateKey)

  local swooshKey = self.animKeyPrefix .. (self.elementalType or self.weapon.elementalType) .. "swoosh"
  animator.setParticleEmitterOffsetRegion(swooshKey, self.swooshOffsetRegions[self.comboStep])
  animator.burstParticleEmitter(swooshKey)

  --spawn traveling swoosh
  local position = vec2.add(mcontroller.position(), {self.projectileOffset[1] * mcontroller.facingDirection(), self.projectileOffset[2]})
  local params = sb.jsonMerge(self.projectileParameters, projectileParams or {})
  params.power = self.stepDamageConfig[self.comboStep].baseDamage/2
  params.powerMultiplier = activeItem.ownerPowerMultiplier()
  params.speed = util.randomInRange(params.speed)

  if self.projectileType and self.comboStep == self.comboSteps then
    world.spawnProjectile(self.projectileType, firePosition or self:firePosition(), activeItem.ownerEntityId(), self:aimVector(), false, params)
  end

  if self.comboStep == self.comboSteps 
  and self.weapon.aimDirection * mcontroller.xVelocity() >= 0
  and mcontroller.xVelocity() ~= 0 then
    local dash = self.dashSpeed and self.dashSpeed or 50
    dash = mcontroller.onGround() and dash or dash/2
    if self.weapon.aimDirection * mcontroller.xVelocity() <= dash then
      mcontroller.addMomentum({self:aimVector()[1] * dash, self:aimVector()[2] * dash})
    end
  end

  util.wait(stance.duration, function()
    local damageArea = partDamageArea("swoosh")
    self.weapon:setDamage(self.stepDamageConfig[self.comboStep], damageArea)
  end)

  if self.comboStep < self.comboSteps then
    self.comboStep = self.comboStep + 1
    self:setState(self.wait)
  else
    self.cooldownTimer = self.cooldowns[self.comboStep]
    self.comboStep = 1
  end
end

function MeleeCombo:firePosition()
  return vec2.add(mcontroller.position(), activeItem.handPosition({2, 0}))
end

function MeleeCombo:shouldActivate()
  if self.cooldownTimer == 0 and (self.energyUsage == 0 or not status.resourceLocked("energy")) then
    if self.comboStep > 1 then
      return self.edgeTriggerTimer > 0
    else
      return self.fireMode == (self.activatingFireMode or self.abilitySlot)
    end
  end
end

function MeleeCombo:readyFlash()
  animator.setGlobalTag("bladeDirectives", self.flashDirectives)
  self.flashTimer = self.flashTime
end

function MeleeCombo:computeDamageAndCooldowns()
  local attackTimes = {}
  for i = 1, self.comboSteps do
    local attackTime = self.stances["windup"..i].duration + self.stances["fire"..i].duration
    if self.stances["preslash"..i] then
      attackTime = attackTime + self.stances["preslash"..i].duration
    end
    table.insert(attackTimes, attackTime)
  end

  self.cooldowns = {}
  local totalAttackTime = 0
  local totalDamageFactor = 0
  for i, attackTime in ipairs(attackTimes) do
    self.stepDamageConfig[i] = util.mergeTable(copy(self.damageConfig), self.stepDamageConfig[i])
    self.stepDamageConfig[i].timeoutGroup = "primary"..i

    local damageFactor = self.stepDamageConfig[i].baseDamageFactor
    self.stepDamageConfig[i].baseDamage = damageFactor * self.baseDps * self.fireTime

    totalAttackTime = totalAttackTime + attackTime
    totalDamageFactor = totalDamageFactor + damageFactor

    local targetTime = totalDamageFactor * self.fireTime
    local speedFactor = 1.0 * (self.comboSpeedFactor ^ i)
    table.insert(self.cooldowns, (targetTime - totalAttackTime) * speedFactor)
  end
end

function MeleeCombo:aimVector()
  local aimVector = vec2.rotate({1, 0}, self.weapon.aimAngle)
  aimVector[1] = aimVector[1] * self.weapon.aimDirection
  return aimVector
end

function MeleeCombo:uninit()
  self.weapon:setDamage()
end
