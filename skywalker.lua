local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
local Tools = module("vrp", "lib/Tools")
vRPclient = Tunnel.getInterface("vRP")
vRP = Proxy.getInterface("vRP")

cr = {}
Tunnel.bindInterface("vrp_porte",cr)

vRP._prepare("vRP/update_gunlicense","UPDATE vrp_user_identities SET gunlicense = @gunlicense WHERE user_id = @user_id")
vRP._prepare("vRP/get_gunlicense","SELECT user_id FROM vrp_user_identities WHERE gunlicense = @gunlicense")


function cr.pagamento()
    local source = source
    local user_id = vRP.getUserId(source)
    local price = 10000
    if vRP.tryPayment(user_id,parseInt(price)) then
        TriggerClientEvent("Notify",source,"sucesso","Você pagou <b>$"..vRP.format(parseInt(price)).." dólares</b> no seu Porte de Armas.")
        return true
    else
        TriggerClientEvent("Notify",source,"negado","Dinheiro & saldo insuficientes.")
        return false
    end
end

function cr.checkcarlicense()
    local source = source
    local user_id = vRP.getUserId(source)
    local identity = vRP.getUserIdentity(user_id)

    if identity.gunlicense == 0 then
        return true
    end
end

function cr.givelicense()
	local source = source
	local user_id = vRP.getUserId(source)

	if vRP.getInventoryWeight(user_id) + vRP.getItemWeight("portearmas") <= vRP.getInventoryMaxWeight(user_id) then
		if vRP.getInventoryItemAmount(user_id,"portearmas") > 0 then
			TriggerClientEvent("Notify",source,"negado","Você já possui um porte de armas em sua mochila.")
		else
			if vRP.tryPayment(user_id,5000) then
				vRP.giveInventoryItem(user_id,"portearmas",1)
				TriggerClientEvent("Notify",source,"sucesso","Sucesso, você adquiriu a segunda via do seu porte de armas por <b>$5000 dólares</b>.")
			else
				TriggerClientEvent("Notify",source,"negado","Saldo insuficiente.")
			end
		end
	else
		TriggerClientEvent("Notify",source,"negado","Sua mochila está cheia.")
	end
end

function cr.sucesso()
    local source = source
    local user_id = vRP.getUserId(source)

    TriggerEvent("porte",1,user_id)

    if vRP.getInventoryWeight(user_id) + vRP.getItemWeight("portearmas") <= vRP.getInventoryMaxWeight(user_id) then
		if vRP.getInventoryItemAmount(user_id,"portearmas") > 0 then
			TriggerClientEvent("Notify",source,"negado","Você já possui um porte de armas em sua mochila.")
		else
			vRP.giveInventoryItem(user_id,"portearmas",1)
		end
	else
		TriggerClientEvent("Notify",source,"negado","Mochila <b>cheia</b>.")
	end
end

RegisterCommand('aprendercr',function(source,args,rawCommand)
    local user_id = vRP.getUserId(source)
    local identity = vRP.getUserIdentity(user_id)
    if vRP.hasPermission(user_id,"policia.permissao") then
        if args[1] == "portearmas" then
            local nplayer = vRPclient.getNearestPlayer(source,2)
            local nuser_id = vRP.getUserId(nplayer)
            local identitynu = vRP.getUserIdentity(nuser_id)

            if nplayer then
                TriggerEvent("porte",0,nuser_id)
                TriggerClientEvent("Notify",source,"sucesso","Você apreendeu o porte de armas de <b>"..identitynu.name.." "..identitynu.firstname.."</b>.")
                TriggerClientEvent("Notify",nplayer,"negado","O oficial <b>"..identity.name.." "..identity.firstname.."</b> apreendeu seu porte de armas.")
            else
                TriggerClientEvent("Notify",source,"negado","Não há players por perto.")
            end
        end
    end
end)

RegisterServerEvent("porte")
AddEventHandler("porte",function(gunlicense,user_id)
    vRP.execute("vRP/update_gunlicense", {gunlicense = gunlicense, user_id = user_id})
end)