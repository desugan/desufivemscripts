local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")

cr = Tunnel.getInterface("vrp_porte")

local nugunlicense = false
local gunlicense = false
local emaula = false

local ponto = {
	{ ['x'] = 447.18, ['y'] = -975.55, ['z'] = 30.69 }
}

Citizen.CreateThread(function()
	while true do
		local idle = 1000
		for k,v in pairs(ponto) do
			local ped = PlayerPedId()
			local x,y,z = table.unpack(GetEntityCoords(ped))
			local bowz,cdz = GetGroundZFor_3dCoord(v.x,v.y,v.z)
			local distance = GetDistanceBetweenCoords(v.x,v.y,cdz,x,y,z,true)
			local ponto = ponto[k]

			if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), ponto.x, ponto.y, ponto.z, true ) < 5.1 and not emaula then
				DrawText3D(ponto.x, ponto.y, ponto.z, "Pressione [~o~E~w~] para ~o~TIRAR~w~ O PORTE DE ARMAS  [~o~G~w~] para ~o~SEGUNDA VIA~w~ do PORTE DE ARMAS.")        
                idle = 5
            end
			
            if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), ponto.x, ponto.y, ponto.z, true ) < 1.5 then
                if IsControlJustPressed(0,38) then
					if cr.checkcarlicense() then
                        if cr.pagamento() and cr.sucesso() and not emaula then
                            emaula = true
                        end
                    else
                        TriggerEvent("Notify","negado","Você já possuí porte de armas.")
                    end
                end
                if IsControlJustPressed(0,47) then
                    cr.givelicense()
				end
			end
        end
		Citizen.Wait(idle)
	end
end)

function DrawText3D(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())  
    SetTextScale(0.28, 0.28)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0125, 0.005+ factor, 0.03, 41, 11, 41, 68)
end