function init()
    --hitActions = config.getParameter("hitactions", {})

    periodicActions = config.getParameter("smokeAction", {})
    
    actionTime = config.getParameter("smokePeriod", 1)

    angleMinMax = config.getParameter("angleMinMax", {90, 270})
    
    actionTimer = 0

    angleDirection = 1
    angleIncrement = config.getParameter("angleIncrement", 5)

    randomizedSmoke = config.getParameter("randomizedSmoke", false)
end
  
function update(dt)

    if actionTimer < actionTime then
        actionTimer = actionTimer + dt
    else
        changeAngle();
        
        projectile.processAction(periodicActions[1])
        actionTimer = 0
    end

    if angleDirection == 1 then
        if periodicActions[1].angleAdjust > angleMinMax[2] then
            angleDirection = -1
        end
    else
        if periodicActions[1].angleAdjust < angleMinMax[1] then
            angleDirection = 1
        end
    end
end

function changeAngle()
    if randomizedSmoke then
        periodicActions[1].angleAdjust = math.random(angleMinMax[1], angleMinMax[2])
    else
        periodicActions[1].angleAdjust = periodicActions[1].angleAdjust + (angleIncrement * angleDirection)
    end
end