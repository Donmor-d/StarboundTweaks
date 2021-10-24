require "/scripts/util.lua"
require "/scripts/rect.lua"
require "/items/active/weapons/weapon.lua"
require "/items/active/weapons/melee/abilities/hammer/shockwave/shockwave.lua"

GreatWave = WeaponAbility:new()

function GreatWave:init()
  self.cooldownTimer = self.cooldownTime

--needed for thing below
  self.soundlock = 0
  self.flashtime = 0.1
  self.flashtimer = 0
end

function GreatWave:update(dt, fireMode, shiftHeld)
  WeaponAbility.update(self, dt, fireMode, shiftHeld)

  self.cooldownTimer = math.max(0, self.cooldownTimer - self.dt)

--adds a sound and a brief glow when the cooldown timer is at 0
  if self.cooldownTimer == 0 then
    if self.soundlock == 0 then
      animator.playSound("recharge")
      animator.setGlobalTag("bladeDirectives", "fade=FFFFFFFF=0.15")
      self.soundlock = 1
      self.flashtimer = self.flashtime
    end

    if self.flashtimer > 0 then
      self.flashtimer = math.max(0, self.flashtimer - dt)
      if self.flashtimer == 0 then
        animator.setGlobalTag("bladeDirectives", "")
      end
    end
  end

  if self.weapon.currentAbility == nil
      and self.cooldownTimer == 0
      and self.fireMode == (self.activatingFireMode or self.abilitySlot)
      and mcontroller.onGround()
      and not status.resourceLocked("energy") then

    self:setState(self.windup)
  end
end

-- Attack state: windup
function GreatWave:windup()
  self.weapon:setStance(self.stances.windup)
  self.weapon:updateAim()

  util.wait(self.stances.windup.duration)

  self:setState(self.fire)
end

-- Attack state: fire
function GreatWave:fire()
  self.weapon:setStance(self.stances.fire)

  self:fireShockwave()
  animator.playSound("fire")

  util.wait(self.stances.fire.duration)

  self.cooldownTimer = self.cooldownTime

--also needed
  self.soundlock = 0
end

function GreatWave:reset()

end

function GreatWave:uninit()
  self:reset()
end

-- Helper functions
function GreatWave:fireShockwave()
  return ShockWave.fireShockwave(self, 1.0)
end

function GreatWave:impactPosition()
  return ShockWave.impactPosition(self)
end

function GreatWave:shockwaveProjectilePositions(impactPosition, maxDistance, directions)
  return ShockWave.shockwaveProjectilePositions(self, impactPosition, maxDistance, directions)
end
