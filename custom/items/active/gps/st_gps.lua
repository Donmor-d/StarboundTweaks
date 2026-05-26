require "/scripts/vec2.lua"

function init()
  self.fireOffset = config.getParameter("fireOffset")
  updateAim()
end

function update()
  updateAim()
end

function activate()
  local configData = root.assetJson("/custom/interface/scripted/gps/st_gpsgui.config")
  activeItem.interact("ScriptPane", configData)
end

function updateAim()
  self.aimAngle, self.aimDirection = activeItem.aimAngleAndDirection(self.fireOffset[2], activeItem.ownerAimPosition())
  self.aimAngle = self.aimAngle
  activeItem.setArmAngle(self.aimAngle)
  activeItem.setFacingDirection(self.aimDirection)
end