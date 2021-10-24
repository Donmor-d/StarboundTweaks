require "/scripts/util.lua"
require "/items/active/weapons/weapon.lua"

BladeCharge = WeaponAbility:new()

function BladeCharge:init()
  BladeCharge:reset()

  self.cooldownTimer = 0

--needed for thing below
  self.soundlock = 0
  self.flashtime = 0.1
  self.flashtimer = 0
end

function BladeCharge:update(dt, fireMode, shiftHeld)
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


  if self.cooldownTimer == 0 and not self.weapon.currentAbility and not status.resourceLocked("energy") and self.fireMode == "alt" then
    self:setState(self.windup)
  end
end

function BladeCharge:windup()
  self.weapon:setStance(self.stances.windup)

  animator.setAnimationState("bladeCharge", "charge")
  animator.setParticleEmitterActive("bladeCharge", true)

  local chargeTimer = self.chargeTime
  while self.fireMode == "alt" do
    chargeTimer = math.max(0, chargeTimer - self.dt)
    if chargeTimer == 0 then
      animator.setGlobalTag("bladeDirectives", "border=3;"..self.chargeBorder..";00000000")
    end
    coroutine.yield()
  end

  if chargeTimer == 0 and status.overConsumeResource("energy", self.energyUsage) then
    self:setState(self.slash)
  end
end

function BladeCharge:slash()
  self.weapon:setStance(self.stances.slash)
  self.weapon:updateAim()

  animator.setAnimationState("bladeCharge", "idle")
  animator.setParticleEmitterActive("bladeCharge", false)
  animator.setAnimationState("swoosh", "fire")
  animator.playSound("chargedSwing")

  util.wait(self.stances.slash.duration, function()
    local damageArea = partDamageArea("swoosh")
    self.weapon:setDamage(self.damageConfig, damageArea)
  end)

  self.cooldownTimer = self.cooldownTime
  
  --also needed
  self.soundlock = 0
end

function BladeCharge:reset()
  animator.setGlobalTag("bladeDirectives", "")
  animator.setParticleEmitterActive("bladeCharge", false)
  animator.setAnimationState("bladeCharge", "idle")
end

function BladeCharge:uninit()
  self:reset()
end
