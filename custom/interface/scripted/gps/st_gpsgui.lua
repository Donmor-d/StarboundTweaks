require "/vehicles/modularmech/mechpartmanager.lua"
require "/scripts/util.lua"
require "/scripts/vec2.lua"

function init()

  local deathInfo = player.getProperty("deathInfo"..player.id())
  if deathInfo then 
    if deathInfo.planetImage then
      for index, value in ipairs(deathInfo.planetImage) do
        widget.setImage("planetImage"..index, value[1])
        widget.setImageScale("planetImage"..index, value[2])
        widget.setPosition("planetImage"..index, {142, 83})
      end
    end

    if deathInfo.planetCoords then
      widget.setText("lblDeathPlanetX", "^blue;"..deathInfo.planetCoords[1])
      widget.setText("lblDeathPlanetY", "^green;"..deathInfo.planetCoords[2])
    end

    if deathInfo.systemCoords then
      widget.setText("lblDeathSystemX", "^blue;"..deathInfo.systemCoords[1])
      widget.setText("lblDeathSystemY", "^green;"..deathInfo.systemCoords[2])
    end

    if deathInfo.planetName then
      widget.setText("lblPlanetName", deathInfo.planetName)
    end

  end

  local currentSystem = celestial.currentSystem()
  local systemLocation = currentSystem.location

  widget.setText("lblCurrentSystemX", "^blue;"..systemLocation[1])
  widget.setText("lblCurrentSystemY", "^green;"..systemLocation[2])
  

end

function update(dt)

  local position = world.entityPosition(player.id())
  widget.setText("lblCurrentPlanetX", "^blue;"..math.floor(position[1]))
  widget.setText("lblCurrentPlanetY", "^green;"..math.floor(position[2]))

end