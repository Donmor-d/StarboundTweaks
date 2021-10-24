require "/scripts/util.lua"
require "/scripts/status.lua"
require "/scripts/poly.lua"
require "/items/active/weapons/weapon.lua"

FlipSlash = WeaponAbility:new()

function FlipSlash:init()
  self.cooldownTimer = self.cooldownTime

--needed for thing below
  self.soundlock = 0
  self.flashtime = 0.1
  self.flashtimer = 0
end

function FlipSlash:update(dt, fireMode, shiftHeld)
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

  if not self.weapon.currentAbility
     and self.cooldownTimer == 0
     and self.fireMode == "alt"
     --and mcontroller.onGround() disabled to allow use in the air
     and not status.statPositive("activeMovementAbilities")
     and status.overConsumeResource("energy", self.energyUsage) then

    self:setState(self.windup)
  end
end

function FlipSlash:windup()
  self.weapon:setStance(self.stances.windup)

  status.setPersistentEffects("weaponMovementAbility", {{stat = "activeMovementAbilities", amount = 1}})

  util.wait(self.stances.windup.duration, function(dt)
      mcontroller.controlCrouch()
    end)

  self:setState(self.flip)
end

function FlipSlash:flip()
  self.weapon:setStance(self.stances.flip)
  self.weapon:updateAim()

  animator.setAnimationState("swoosh", "flip")
  animator.playSound(self.fireSound or "flipSlash")
  animator.setParticleEmitterActive("flip", true)

  self.flipTime = self.rotations * self.rotationTime
  self.flipTimer = 0

  self.jumpTimer = self.jumpDuration

  while self.flipTimer < self.flipTime do
    self.flipTimer = self.flipTimer + self.dt

    mcontroller.controlParameters(self.flipMovementParameters)

    if self.jumpTimer > 0 then
      self.jumpTimer = self.jumpTimer - self.dt
      mcontroller.setVelocity({self.jumpVelocity[1] * self.weapon.aimDirection, self.jumpVelocity[2]})
    end

    local damageArea = partDamageArea("swoosh")
    self.weapon:setDamage(self.damageConfig, damageArea, self.fireTime)

    mcontroller.setRotation(-math.pi * 2 * self.weapon.aimDirection * (self.flipTimer / self.rotationTime))

    coroutine.yield()
  end

  status.clearPersistentEffects("weaponMovementAbility")

  animator.setAnimationState("swoosh", "idle")
  mcontroller.setRotation(0)
  animator.setParticleEmitterActive("flip", false)
  self.cooldownTimer = self.cooldownTime

--also needed
  self.soundlock = 0
end


function FlipSlash:uninit()
  status.clearPersistentEffects("weaponMovementAbility")
  animator.setAnimationState("swoosh", "idle")
  mcontroller.setRotation(0)
  animator.setParticleEmitterActive("flip", false)
end
