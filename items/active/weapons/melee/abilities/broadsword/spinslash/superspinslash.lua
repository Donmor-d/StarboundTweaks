require "/scripts/util.lua"
require "/items/active/weapons/weapon.lua"

SuperSpinSlash = WeaponAbility:new()

function SuperSpinSlash:init()
  self.cooldownTimer = self.cooldownTime
  self:reset()

  --needed for thing below
  self.soundlock = 0
  self.flashtime = 0.1
  self.flashtimer = 0

  self.maxSpinTime = 3
  self.spinTimer = self.maxSpinTime
end

function SuperSpinSlash:update(dt, fireMode, shiftHeld)
  WeaponAbility.update(self, dt, fireMode, shiftHeld)

  self.cooldownTimer = math.max(0, self.cooldownTimer - dt)

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


--limits how long you can use the ability
  if self.fireMode == "alt" and self.spinTimer > 0 and self.cooldownTimer == 0 then
    self.spinTimer = math.max(0, self.spinTimer - dt)
  end


  if self.weapon.currentAbility == nil
    and self.fireMode == "alt"
    and self.cooldownTimer == 0
    and not status.resourceLocked("energy")
    and not status.statPositive("activeMovementAbilities") then

    self:setState(self.slash)
  end
end

function SuperSpinSlash:slash()
  status.setPersistentEffects("weaponMovementAbility", {{stat = "activeMovementAbilities", amount = 1}})

  local slash = coroutine.create(self.slashAction)
  coroutine.resume(slash, self)

  local movement = function()
    mcontroller.controlModifiers({runningSuppressed = true})

    if self.hover and math.abs(world.gravity(mcontroller.position())) > 0 then
      mcontroller.controlApproachYVelocity(self.hoverYSpeed, self.hoverForce)
    end
  end

  while util.parallel(slash, movement) do
    coroutine.yield()
  end
end

function SuperSpinSlash:slashAction()
  local armRotationOffset = math.random(1, #self.armRotationOffsets)
  while self.fireMode == "alt" and self.spinTimer > 0 do
    if not status.overConsumeResource("energy", self.energyUsage * (self.stances.windup.duration + self.stances.slash.duration)) then return end

    self.weapon:setStance(self.stances.windup)
    self.weapon.relativeArmRotation = self.weapon.relativeArmRotation - util.toRadians(self.armRotationOffsets[armRotationOffset])
    self.weapon:updateAim()

    util.wait(self.stances.windup.duration, function()
      return status.resourceLocked("energy")
    end)

    self.weapon.aimDirection = -self.weapon.aimDirection

    self.weapon:setStance(self.stances.slash)
    self.weapon.relativeArmRotation = self.weapon.relativeArmRotation + util.toRadians(self.armRotationOffsets[armRotationOffset])
    self.weapon:updateAim()

    armRotationOffset = armRotationOffset + 1
    if armRotationOffset > #self.armRotationOffsets then armRotationOffset = 1 end

    animator.setAnimationState("spinSwoosh", "fire", true)

    util.wait(self.stances.slash.duration, function()
      local damageArea = partDamageArea("spinSwoosh")
      self.weapon:setDamage(self.damageConfig, damageArea)
    end)

  end

  self.cooldownTimer = self.cooldownTime

  self.spinTimer = self.maxSpinTime

  --also needed
  self.soundlock = 0
end

function SuperSpinSlash:reset()
  status.clearPersistentEffects("weaponMovementAbility")
  animator.setGlobalTag("swooshDirectives", "")
end

function SuperSpinSlash:uninit()
  self:reset()
end
