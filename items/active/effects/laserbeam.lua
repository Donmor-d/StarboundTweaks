require "/scripts/vec2.lua"
require "/scripts/util.lua"

function update()
  localAnimator.clearDrawables()
  local beams = animationConfig.animationParameter("beams") or {}
  drawAmmo(dt)
  
  for _,beam in pairs(beams) do
    local offset = beam.offset or {0,0}
    local color = beam.color or {255,255,255,255}
    local maxLength = beam.length or 30
    local segmentCount = beam.segments or 1
    local angle = beam.angle or 0

    if #color == 3 then
      color[4] = 255
    end

    local beamPosition = vec2.add(activeItemAnimation.ownerPosition(), activeItemAnimation.handPosition(offset))
    local aimAngle = activeItemAnimation.ownerArmAngle() + angle
    local aimVector = {activeItemAnimation.ownerFacingDirection() * math.cos(aimAngle), math.sin(aimAngle)}

    local lineEnd = vec2.mul(aimVector, maxLength)

    local blocks = world.collisionBlocksAlongLine(beamPosition, vec2.add(beamPosition, lineEnd))
    if #blocks > 0 then
      blockPosition = blocks[1]
      --When approaching the block from the right or top, the intersecting edges will be the right or top ones
      if aimVector[1] < 0 then blockPosition[1] = blockPosition[1] + 1 end
      if aimVector[2] < 0 then blockPosition[2] = blockPosition[2] + 1 end

      local blockDistance = world.distance(blockPosition, beamPosition)

      -- If the block's edge is in a different direction than the aim direction
      -- it is impossible to have hit that edge, make sure we draw the beam to the other edge
      if aimVector[1] * (blockPosition[1] - beamPosition[1]) < 0 then blockDistance[1] = 0 end
      if aimVector[2] * (blockPosition[2] - beamPosition[2]) < 0 then blockDistance[2] = 0 end

      -- How long does the beam need to be to move 1 block in each axis
      local deltaDistX = 1 / math.abs(aimVector[1])
      local deltaDistY = 1 / math.abs(aimVector[2])

      -- How long does the beam need to be to reach the collided block on each axis
      local distX = math.abs(blockDistance[1]) * deltaDistX
      local distY = math.abs(blockDistance[2]) * deltaDistY

      -- The largest of the distances is the length of the beam when colliding with the block
      lineEnd = vec2.mul(aimVector, math.max(distX, distY))
    end


    local unit = vec2.norm(lineEnd)
    for i = 0, segmentCount-1 do
      if i * maxLength / segmentCount >= vec2.mag(lineEnd) then
        break
      end
      local startPosition = vec2.mul(unit, maxLength * i / segmentCount)
      local endPosition = vec2.mul(unit, math.min(vec2.mag(lineEnd), maxLength * (i+1) / segmentCount))

      local segmentColor = copy(color)
      segmentColor[4] = segmentColor[4] * (1 - i/segmentCount)

      localAnimator.addDrawable({line = {startPosition, endPosition}, width = 1, color = segmentColor, position = beamPosition, fullbright = true})
    end
  end
end

function drawAmmo(dt) 
  if not animationConfig.animationParameter("maxAmmo") then
    return
  end 

  local maxAmmo = animationConfig.animationParameter("maxAmmo") and math.floor(animationConfig.animationParameter("maxAmmo")) or 0
  local currentAmmo = math.floor(animationConfig.animationParameter("currentAmmo") or 0)
  local pos = activeItemAnimation.ownerPosition()

  self.showTimer = self.showTimer or 0
  if currentAmmo <= maxAmmo / 5 then
      if self.showTimer <= 0 then
          self.showTimer = 0.16
          self.showState = not self.showState
      else
          self.showTimer = math.max(0, self.showTimer - dt)
      end
  else
      self.showState = true
  end

  local maxAmmoString = string.format("%02d", maxAmmo)
  local currentAmmoString = string.format("%02d", currentAmmo)

  if #currentAmmoString < 3 then currentAmmoString = "n"..currentAmmoString end

  for i = 1, #currentAmmoString do 
      if self.showState then
          localAnimator.addDrawable({image="/custom/interface/st_number.png:"..currentAmmoString:sub(i, i),fullbright=true,position={pos[1] + 3 + (i/1.6),pos[2] + 3}}, "overlay")
      end
  end
  
  if self.showState then
      localAnimator.addDrawable({image="/custom/interface/st_number.png:slash",fullbright=true,position={pos[1] + 5.6,pos[2] + 3}}, "overlay")
  end

  for i = 1, #maxAmmoString do 
      if self.showState then
          localAnimator.addDrawable({image="/custom/interface/st_number.png:"..maxAmmoString:sub(i, i),fullbright=true,position={pos[1] + 6.225 + (i/1.6),pos[2] + 3}}, "overlay")
      end
  end

  if self.showState then
      localAnimator.addDrawable({image="/custom/interface/st_ammo.png",fullbright=true,position={pos[1]+2,pos[2] + 3}}, "overlay")
  end
end
