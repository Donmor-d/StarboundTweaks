require "/scripts/util.lua"
require "/scripts/interp.lua"

function GunFire:init()
  self.weapon:setStance(self.stances.idle)

  self.cooldownTimer = self.reloadTime

  self.cooldownReset = self.fireTime

  self.weapon.onLeaveAbility = function()
    self.weapon:setStance(self.stances.idle)
  end
end

function GunFire:update(dt, fireMode, shiftHeld)
  WeaponAbility.update(self, dt, fireMode, shiftHeld)

  self.cooldownTimer = math.max(0, self.cooldownTimer - self.dt)

  if animator.animationState("firing") ~= "fire" then
    animator.setLightActive("muzzleFlash", false)
  end


  if self.fireMode == "primary" then

    mcontroller.controlModifiers({runningSuppressed=true})
    
    if not self.weapon.currentAbility
    and self.cooldownTimer == 0
    and not world.lineTileCollision(mcontroller.position(), self:firePosition()) then

      if self.fireType == "auto" and status.overConsumeResource("ammo", self.ammoUsage) then
        self:setState(self.auto)
      end
    end
  else
    self.cooldownReset = self.fireTime
  end
end

function GunFire:auto()
  self.weapon:setStance(self.stances.fire)

  self:fireProjectile()
  self:muzzleFlash()

  if self.stances.fire.duration then
    util.wait(self.stances.fire.duration)
  end
  
  if status.resourceLocked("ammo") then
    self.cooldownTimer = math.max(0.08, self.cooldownReset - self.cooldownReset/10)* 2 / (self.stockFireRateMult or 1)  / (self.barrelFireRateMult or 1)
    self.cooldownReset = self.cooldownTimer
  else
    self.cooldownTimer = math.max(0.08, self.cooldownReset - self.cooldownReset/10) / (self.stockFireRateMult or 1)  / (self.barrelFireRateMult or 1)
    self.cooldownReset = self.cooldownTimer
  end

  self:setState(self.cooldown)

  self.cooldownTime = self.fireTime
end

function GunFire:cooldown()
  self.weapon:setStance(self.stances.cooldown)
  self.weapon:updateAim()

  local progress = 0
  local cooldown = math.min(self.cooldownReset / (self.stockFireRateMult or 1)  / (self.barrelFireRateMult or 1), self.stances.cooldown.duration)
  
  util.wait(cooldown, function()
    local from = self.stances.cooldown.weaponOffset or {0,0}
    local to = self.stances.idle.weaponOffset or {0,0}
    self.weapon.weaponOffset = {interp.linear(progress, from[1], to[1]), interp.linear(progress, from[2], to[2])}

    self.weapon.relativeWeaponRotation = util.toRadians(interp.linear(progress, self.stances.cooldown.weaponRotation, self.stances.idle.weaponRotation))
    self.weapon.relativeArmRotation = util.toRadians(interp.linear(progress, self.stances.cooldown.armRotation, self.stances.idle.armRotation))

    progress = math.min(1.0, progress + (self.dt / self.stances.cooldown.duration))
  end)
end