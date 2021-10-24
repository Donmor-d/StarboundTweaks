require "/scripts/util.lua"
require "/items/active/weapons/weapon.lua"

RisingSlash = WeaponAbility:new()

function RisingSlash:init()
  self:reset()

  self.cooldownTimer = self.cooldownTime

  --needed for thing below
  self.soundlock = 0
  self.flashtime = 0.1
  self.flashtimer = 0
end

function RisingSlash:update(dt, fireMode, shiftHeld)
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

  if self.weapon.currentAbility == nil
    and self.cooldownTimer == 0
    and self.fireMode == "alt"
    and not status.statPositive("activeMovementAbilities")
    and status.overConsumeResource("energy", self.energyUsage) then

    self:setState(self.windup)
  end
end

function RisingSlash:windup()
  self.weapon:setStance(self.stances.windup)
  self.weapon:updateAim()

  status.setPersistentEffects("weaponMovementAbility", {{stat = "activeMovementAbilities", amount = 1}})

  animator.setGlobalTag("directives", "?flipx")

  util.wait(self.stances.windup.duration, function()
    return status.resourceLocked("energy")
  end)

  self:setState(self.slash)
end

function RisingSlash:slash()
  self.weapon:setStance(self.stances.slash)
  self.weapon:updateAim()

  animator.setAnimationState("risingSwoosh", "slash")
  animator.playSound("upswing")

  util.wait(self.stances.slash.duration, function()
    if math.abs(world.gravity(mcontroller.position())) > 0 then
      mcontroller.controlApproachYVelocity(self.dashSpeed, self.dashControlForce)
    end

    local damageArea = partDamageArea("risingSwoosh")
    self.weapon:setDamage(self.damageConfig, damageArea)
  end)

  self.cooldownTimer = self.cooldownTime

  --also needed
  self.soundlock = 0

  self:setState(self.freeze)
end

function RisingSlash:freeze()
  self.weapon:setStance(self.stances.freeze)
  self.weapon:updateAim()

  --[[
    util.wait(self.stances.freeze.duration, function()
    mcontroller.setVelocity({0,0})
  end)
  ]]--
end

function RisingSlash:reset()
  animator.setGlobalTag("directives", "")
  status.clearPersistentEffects("weaponMovementAbility")
end

function RisingSlash:uninit()
  self:reset()
end
