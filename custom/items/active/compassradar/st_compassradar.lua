require "/scripts/vec2.lua"

function init()
  self.fireOffset = config.getParameter("fireOffset")
  updateAim()
end

function update()
  updateAim()
end

function activate()
  local position = world.entityPosition(entity.id())
  local message = {
    unique = false,
    messageId = "showposition",
    senderName = "doesntmatter",
    text = "Your X and Y coordinates: ("..math.floor(position[1])..", "..math.floor(position[2])..")",
    textSpeed = 140
  }
  
  world.sendEntityMessage(entity.id(), "queueRadioMessage", message)
end

function updateAim()
  self.aimAngle, self.aimDirection = activeItem.aimAngleAndDirection(self.fireOffset[2], activeItem.ownerAimPosition())
  self.aimAngle = self.aimAngle
  activeItem.setArmAngle(self.aimAngle)
  activeItem.setFacingDirection(self.aimDirection)
end