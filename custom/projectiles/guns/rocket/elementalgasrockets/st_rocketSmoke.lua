local oldInit = init or function() end
local oldUpdate = update or function() end

function init() oldInit()
    --hitActions = config.getParameter("hitactions", {})

    smokeActions = config.getParameter("smokeAction", {})
    
    actionTime = config.getParameter("smokePeriod", 1)

    angleMinMax = config.getParameter("angleMinMax", {90, 270})
    
    actionTimer = 0

    angleDirection = 1
    angleIncrement = config.getParameter("angleIncrement", 5)

    randomizedSmoke = config.getParameter("randomizedSmoke", false)
end
  
function update(dt) oldUpdate(dt)

    if actionTimer < actionTime then
        actionTimer = actionTimer + dt
    else
        changeAngle();
        
        for i = 1, #smokeActions do 
            projectile.processAction(smokeActions[i])
        end
        
        actionTimer = 0
    end

    if angleDirection == 1 then
        for i = 1, #smokeActions do 
            if smokeActions[i].angleAdjust > angleMinMax[2] then
                angleDirection = -1
            end
        end
    else
        for i = 1, #smokeActions do 
            if smokeActions[i].angleAdjust < angleMinMax[1] then
                angleDirection = 1
            end
        end
    end
end

function changeAngle()
    if randomizedSmoke then
        for i = 1, #smokeActions do 
            smokeActions[i].angleAdjust = math.random(angleMinMax[1], angleMinMax[2])
        end
    else
        for i = 1, #smokeActions do 
            smokeActions[i].angleAdjust = smokeActions[i].angleAdjust + (angleIncrement * angleDirection)
        end
    end
end