require "/scripts/util.lua"
require "/scripts/interp.lua"
require "/items/active/weapons/melee/meleeslash.lua"

-- Axe primary attack
-- Extends default melee attack and overrides windup and fire
AxeCleave = MeleeSlash:new()

function AxeCleave:init()
  self.stances.windup.duration = self.fireTime - self.stances.fire.duration

  MeleeSlash.init(self)
  self:setupInterpolation()

  self.defKnockback = self.damageConfig.knockback  --default knockback
end

function AxeCleave:windup(windupProgress)
  self.weapon:setStance(self.stances.windup)

  local windupProgress = windupProgress or 0
  local bounceProgress = 0
  while self.fireMode == "primary" and (self.allowHold ~= false or windupProgress < 1) do
    if windupProgress < 1 then
      windupProgress = math.min(1, windupProgress + (self.dt / self.stances.windup.duration))
      self.weapon.relativeWeaponRotation, self.weapon.relativeArmRotation = self:windupAngle(windupProgress)
    else
      bounceProgress = math.min(1, bounceProgress + (self.dt / self.stances.windup.bounceTime))
      self.weapon.relativeWeaponRotation = self:bounceWeaponAngle(bounceProgress)
    end

    if windupProgress > 0.8 and windupProgress < 1 then
      animator.setGlobalTag("bladeDirectives", "fade=FFFFFFFF=0.15")
    else 
      animator.setGlobalTag("bladeDirectives", "")
    end
    coroutine.yield()
  end
  
  if windupProgress > 0.5 then
    if self.stances.preslash then
      self:setState(self.preslash)
    else
      self:setState(self.fire, windupProgress)
    end
  else
    self:setState(self.winddown, windupProgress)
  end
end

function AxeCleave:winddown(windupProgress)
  self.weapon:setStance(self.stances.windup)

  while windupProgress > 0 do
    if self.fireMode == "primary" then
      self:setState(self.windup, windupProgress)
      return true
    end

    windupProgress = math.max(0, windupProgress - (self.dt / self.stances.windup.duration))
    self.weapon.relativeWeaponRotation, self.weapon.relativeArmRotation = self:windupAngle(windupProgress)
    coroutine.yield()
  end
end

function AxeCleave:fire(windupProgress)
  self.weapon:setStance(self.stances.fire)
  self.weapon:updateAim()
  
  if windupProgress > 0.8 and windupProgress < 1 then
    windupProgress = 1.25 -- 125% of base damage and base knockback
    animator.setGlobalTag("bladeDirectives", "")
    animator.playSound("chargedFire")
  end
  self.damageConfig.knockback = self.damageConfig.knockback * windupProgress
  self.damageConfig.baseDamage = self.damageConfig.baseDamage * windupProgress

  animator.playSound("fire")
  animator.setAnimationState("swoosh", "fire")
  animator.burstParticleEmitter(self.weapon.elementalType .. "swoosh")

  util.wait(self.stances.fire.duration, function()
      local damageArea = partDamageArea("swoosh")
      self.weapon:setDamage(self.damageConfig, damageArea, self.fireTime)
    end)

    self.damageConfig.knockback = self.defKnockback
    self.damageConfig.baseDamage = self.baseDps * self.fireTime

  self.cooldownTimer = self:cooldownTime()
end

function AxeCleave:setupInterpolation()
  for i, v in ipairs(self.stances.windup.bounceWeaponAngle) do
    v[2] = interp[v[2]]
  end
  for i, v in ipairs(self.stances.windup.weaponAngle) do
    v[2] = interp[v[2]]
  end
  for i, v in ipairs(self.stances.windup.armAngle) do
    v[2] = interp[v[2]]
  end
end

function AxeCleave:bounceWeaponAngle(ratio)
  return util.toRadians(interp.ranges(ratio, self.stances.windup.bounceWeaponAngle))
end

function AxeCleave:windupAngle(ratio)
  local weaponRotation = interp.ranges(ratio, self.stances.windup.weaponAngle)
  local armRotation = interp.ranges(ratio, self.stances.windup.armAngle)

  return util.toRadians(weaponRotation), util.toRadians(armRotation)
end