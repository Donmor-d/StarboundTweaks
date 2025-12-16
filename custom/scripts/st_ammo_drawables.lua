--Credits to Silver Sokolova (play betabound! https://steamcommunity.com/workshop/filedetails/?id=2010607826)


--[[
    WARNING:
    IF MODIFIED, CHANGE THE FOLLOWING SCRIPTS:
    - chain.LUA
    - laserbeam.lua
]]
local oldUpdate = update or function() end

function update(dt) oldUpdate(dt)
    localAnimator.clearDrawables()

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

    if self.showState then 
        for i = 1, #currentAmmoString do 
            localAnimator.addDrawable({image="/custom/interface/st_number.png:"..currentAmmoString:sub(i, i),fullbright=true,position={pos[1] + 3 + (i/1.6),pos[2] + 3}}, "overlay")
        end
        
        localAnimator.addDrawable({image="/custom/interface/st_number.png:slash",fullbright=true,position={pos[1] + 5.6,pos[2] + 3}}, "overlay")

        for i = 1, #maxAmmoString do 
            localAnimator.addDrawable({image="/custom/interface/st_number.png:"..maxAmmoString:sub(i, i),fullbright=true,position={pos[1] + 6.225 + (i/1.6),pos[2] + 3}}, "overlay")
        end

        localAnimator.addDrawable({image="/custom/interface/st_ammo.png",fullbright=true,position={pos[1]+2,pos[2] + 3}}, "overlay")
    end
end