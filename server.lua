RegisterServerEvent('respawn:requestSpawn')
AddEventHandler('respawn:requestSpawn', function()
	--Based on the number of players, tell the requester how to respawn
	----give them coordinates if respawning near another player (in case that player is out of their scope)
	
	--Label for console output for debugging
	local debugLabel = (GetGameTimer() .. ": (" .. source .. ")" .. GetPlayerName(source)) 
	print(debugLabel .. " requesting respawn") --DEBUG
	
	--Get list of active players' server IDs
	local players = GetPlayers()
	
	--Prepare to count players
	local otherPlayers = {}
	local playerCount = 0
	local includedPlayers = 0
	
	--Get player count while getting a list of players that excludes the source of this event
	for _, playerId in ipairs(players) do
		playerCount = playerCount + 1
		local pos = GetEntityCoords(GetPlayerPed(playerId))
		if (tonumber(playerId) ~= tonumber(source)) and (pos ~= nil) then
			table.insert(otherPlayers, 1, playerId)
			includedPlayers = includedPlayers + 1
		end
	end
	
	print(debugLabel .. " player count: " .. includedPlayers .. " valid, " .. playerCount .. " total") --DEBUG
	
	math.randomseed(os.time())
	
	--Now we can determine how the player should respawn
	if (playerCount >= 2) and (includedPlayers >= 1) then
		--Select a random player to respawn near then return their position to the source
		local rando = otherPlayers[math.random(includedPlayers)]
		local pos = GetEntityCoords(GetPlayerPed(rando))
		print (debugLabel .. " respawning near (" .. rando .. ")" .. GetPlayerName(rando) .. " near position:") --DEBUG
		print (pos) --DEBUG
		TriggerClientEvent('respawn:respawnNearCoords', source, pos)
	else
		--Tell client to default spawn (ie using their previous position or vanilla spawn points)
		TriggerClientEvent('respawn:respawnDefault', source)
		print(debugLabel .. " respawning by default") --DEBUG
	end
end)