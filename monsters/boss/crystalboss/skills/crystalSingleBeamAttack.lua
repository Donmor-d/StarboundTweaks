crystalSingleBeamAttack = {}

--------------------------------------------------------------------------------
function crystalSingleBeamAttack.enter()
  if not hasTarget() then return nil end
  return {
    windupTimer = 0.6,
    timer = config.getParameter("crystalSingleBeamAttack.skillTime", 12),
    rotateInterval = config.getParameter("crystalSingleBeamAttack.rotateInterval", 12),
    angleRange = 1.5,
    initialAngle = math.pi / 4,
    winddownTimer = 0.6,
    bobInterval = 0.5,
    bobHeight = 0.1
  }
end

--------------------------------------------------------------------------------
function crystalSingleBeamAttack.enteringState(stateData)
  animator.setAnimationState("firstBeams", "windup")
  animator.setAnimationState("secondBeams", "windup")
  animator.setAnimationState("eye", "windup")
  animator.setAnimationState("beamglow", "on")

  crystalSingleBeamAttack.damagePerSecond = config.getParameter("crystalSingleBeamAttack.damagePerSecond")

  crystalSingleBeamAttack.rotateBeams(math.pi/4, true)
end

--------------------------------------------------------------------------------
function crystalSingleBeamAttack.update(dt, stateData)
  crystalSingleBeamAttack.bob(dt, stateData)

  if stateData.windupTimer > 0 then
    stateData.windupTimer = stateData.windupTimer - dt
    return false
  end

  if stateData.timer > 0 then
    crystalSingleBeamAttack.setBeamLightsActive(true)
    stateData.timer = stateData.timer - dt

    local angleFactor = (stateData.timer % stateData.rotateInterval) / stateData.rotateInterval
    local angle = stateData.angleRange * math.sin(angleFactor * math.pi * 2) + stateData.initialAngle

    crystalSingleBeamAttack.rotateBeams(angle, true)

    local powerMultiplier = root.evalFunction("monsterLevelPowerMultiplier", monster.level())
    crystalSingleBeamAttack.spawnProjectiles(angle, crystalSingleBeamAttack.damagePerSecond * powerMultiplier * dt)

    if stateData.timer < 0 then
      animator.setAnimationState("firstBeams", "winddown")
      animator.setAnimationState("secondBeams", "winddown")
      animator.setAnimationState("eye", "winddown")
    end

    return false
  end

  if stateData.winddownTimer > 0 then
    stateData.winddownTimer = stateData.winddownTimer - dt
    return false
  end

  return true
end

function crystalSingleBeamAttack.leavingState(stateData)
  animator.setAnimationState("firstBeams", "idle")
  animator.setAnimationState("secondBeams", "idle")
  animator.setAnimationState("beamglow", "off")

  crystalSingleBeamAttack.setBeamLightsActive(false)
end

function crystalSingleBeamAttack.rotateBeams(angle, instant)
  --Beam 1
  animator.rotateGroup("beam1", angle, instant)
  crystalSingleBeamAttack.setBeamLightPosition("beam1", angle)

  --Beam 2
  animator.rotateGroup("beam2", angle + math.pi * 0.5, instant)
  crystalSingleBeamAttack.setBeamLightPosition("beam2", angle + math.pi * 0.5)

  --Beam 3
  animator.rotateGroup("beam3", angle + math.pi, instant)
  crystalSingleBeamAttack.setBeamLightPosition("beam3", angle + math.pi)

  --Beam 4
  animator.rotateGroup("beam4", angle + math.pi * 1.5, instant)
  crystalSingleBeamAttack.setBeamLightPosition("beam4", angle + math.pi * 1.5)
end

function crystalSingleBeamAttack.spawnProjectiles(angle, power)
  for x = 0, 3 do
    local newAngle = angle + math.pi * x * 0.5
    local aimVector = {math.cos(newAngle), math.sin(newAngle)}
    world.spawnProjectile("crystalbeamdamage", mcontroller.position(), entity.id(), aimVector, true, {power = power, damageRepeatGroup = "crystalbossbeam"})
  end
end

function crystalSingleBeamAttack.setBeamLightsActive(active)
  animator.setLightActive("beam1", active)
  animator.setLightActive("beam1-2", active)
  animator.setLightActive("beam2", active)
  animator.setLightActive("beam2-2", active)
  animator.setLightActive("beam3", active)
  animator.setLightActive("beam3-2", active)
  animator.setLightActive("beam4", active)
  animator.setLightActive("beam4-2", active)
end

function crystalSingleBeamAttack.setBeamLightPosition(light, angle)
  animator.setLightPosition(light, vec2.rotate({0, 32}, angle))
  animator.setLightPosition(light.."-2", vec2.rotate({0, 20}, angle))
end

function crystalSingleBeamAttack.bob(dt, stateData)
  local bobFactor = (stateData.bobInterval - (stateData.timer % stateData.bobInterval)) / stateData.bobInterval
  local bobOffset = math.sin(bobFactor * math.pi * 2) * stateData.bobHeight
  local targetPosition = {self.spawnPosition[1], self.spawnPosition[2] + bobOffset}
  local toTarget = world.distance(targetPosition, mcontroller.position())

  mcontroller.controlApproachVelocity(vec2.mul(toTarget, 1/dt), 30)
end
