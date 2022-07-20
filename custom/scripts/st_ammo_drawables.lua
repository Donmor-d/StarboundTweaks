
function update(dt)

    localAnimator.clearDrawables()

    local maxAmmo = math.floor(animationConfig.animationParameter("maxAmmo"))
    local currentAmmo = math.floor(animationConfig.animationParameter("currentAmmo"))
    local pos = activeItemAnimation.ownerPosition()

    maxAmmo = string.format("%02d", maxAmmo)
    currentAmmo = string.format("%02d", currentAmmo)

    if #currentAmmo < 3 then currentAmmo = "n"..currentAmmo end

    for i = 1, #currentAmmo do 
        
        localAnimator.addDrawable({image="/custom/interface/st_number.png:"..currentAmmo:sub(i, i),fullbright=true,position={pos[1] + 3 + (i/1.6),pos[2] + 3}}, "overlay")
    end

    localAnimator.addDrawable({image="/custom/interface/st_number.png:slash",fullbright=true,position={pos[1] + 5.6,pos[2] + 3}}, "overlay")

    for i = 1, #maxAmmo do 
        
        localAnimator.addDrawable({image="/custom/interface/st_number.png:"..maxAmmo:sub(i, i),fullbright=true,position={pos[1] + 6.225 + (i/1.6),pos[2] + 3}}, "overlay")
    end


    localAnimator.addDrawable({image="/custom/interface/st_ammo.png",fullbright=true,position={pos[1]+2,pos[2] + 3}}, "overlay")
end