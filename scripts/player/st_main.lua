require "/scripts/util.lua"
require "/scripts/rect.lua"
require "/scripts/async.lua"
require "/interface/cockpit/cockpitutil.lua"

function init()
  message.setHandler( "getCurrentPlanetInfo", getPlanet)
end

function getPlanet()
  local currentSystem = celestial.currentSystem()
  local planetId = player.worldId()

  local planetInfo = {}

  if planetId and string.find(planetId, ":") then
    for item in string.gmatch(planetId, "[^:]+") do
      table.insert(planetInfo, item)
    end
  end

  if #planetInfo > 0 then
    if planetInfo[1] == "CelestialWorld" then
      currentSystem.planet = planetInfo[5] and tonumber(planetInfo[5]) or 0
      currentSystem.satellite = planetInfo[6] and tonumber(planetInfo[6]) or 0
    end
  end

  local position = world.entityPosition(player.id())
  local lastDeathInfo
  if currentSystem then
    lastDeathInfo = {
      systemCoords = currentSystem.location,
      planetImage = celestial.worldImages(currentSystem),
      planetType = world.type(),
      planetName = celestial.planetName(currentSystem),
      planetCoords = {math.floor(position[1]), math.floor(position[2])}
    }
  else
    lastDeathInfo = {}
  end

  player.setProperty("deathInfo"..player.id(), lastDeathInfo)

  return nil
end