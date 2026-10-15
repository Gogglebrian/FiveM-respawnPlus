local radius = 150.0 --radius from death to begin searching for an appropriate spawn point
local firstSpawn = true
local newSpot = {}

--Set the following as a callback to handle automatic spawns
exports.spawnmanager:setAutoSpawnCallback(function()
	--Ask the server to figure out how we should respawn
	----('cause the server knows the actual player count and all player coordinates)
	----The server will then trigger the appropriate client event,
	-----including coordinates of the selected player if relevant
	TriggerServerEvent('respawn:requestSpawn')
end)
exports.spawnmanager:setAutoSpawn(true)

--Event handler when the server tells us to respawn near particular coordinates (ie player coords)
RegisterNetEvent('respawn:respawnNearCoords')
AddEventHandler('respawn:respawnNearCoords', function( pos )
	spawnNearPosition(pos, radius)
	print("Spawning near player") --DEBUG
end)

--Event handler when server tells us to respawn in the default way
----this should only be triggered if the server finds less than 2 players on the server
RegisterNetEvent('respawn:respawnDefault')
AddEventHandler('respawn:respawnDefault', function()
	if firstSpawn then
		-- if first spawn, vanilla spawn
		exports.spawnmanager:spawnPlayer()
		firstSpawn = false
		print("First spawn, spawning at vanilla spawn point")--DEBUG
	else
		-- if subsequent respawn, spawn near where you just died
		spawnNearPosition(GetEntityCoords(GetPlayerPed(-1)), radius)
		print("Spawning near last death")--DEBUG
	end
end)

--Spawns the player on a road near the passed position (randomized to be within the passed radius)
function spawnNearPosition( pos, r )
	-- Pick a random spot (on a road or path) nearby their previous position
	math.randomseed(GetGameTimer())
	local xNew = math.random(math.floor(pos.x - r), math.floor(pos.x + r))
	local yNew = math.random(math.floor(pos.y - r), math.floor(pos.y + r))
	local found, newSpot = GetClosestMajorVehicleNode(xNew+0.0,yNew+0.0,pos.z+0.0,3.0,0)
	
	--If we didn't find a good road spot to respawn, we'll spawn them right above the target's head
	if ((not found) or (newSpot == nil) or ((newSpot.x == 0.0) and (newSpot.y == 0.0) and (newSpot.z == 0.0))) then
		spawnAt(pos.x+0.0, pos.y+0.0, pos.z+0.0)
		print("Node not found, spawning on top of target instead") --DEBUG
	elseif (GetDistanceBetweenCoords(newSpot.x+0.0,newSpot.y+0.0,newSpot.z+0.0,pos.x+0.0,pos.y+0.0,pos.z+0.0,false) > r+50.0) then
		spawnAt(pos.x+0.0, pos.y+0.0, pos.z+0.0)
		print("Nonsensical node found, spawning on top of target instead") --DEBUG
	else
		--No problems, spawn at the discovered ideal spot
		spawnAt(newSpot.x+0.0, newSpot.y+0.0, newSpot.z+0.0)
	end		
end

--Spawn player at a specific position
function spawnAt( newx, newy, newz)
	exports.spawnmanager:spawnPlayer({
		x = newx+0.0,
		y = newy+0.0,
		z = newz+1.0,
		heading = 260.0,
		skipFade = false
		 -- 'model' is left out here so that their ped model is preserved
	}, function(spawn)
		ClearPedBloodDamage(PlayerPedId())
	end)
end


