-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONEXÃO
-----------------------------------------------------------------------------------------------------------------------------------------
vSERVER = {}
Tunnel.bindInterface("arcade-ammunation",vSERVER)
vSERVER = Tunnel.getInterface("arcade-ammunation")
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIAVEIS
-----------------------------------------------------------------------------------------------------------------------------------------
local vaultStart = false
local vaultTimer = 0
local vaultPosX = 0.0
local vaultPosY = 0.0
local vaultPosZ = 0.0
local objectBomb = nil
local vaultExplosionMin = 15 -- Tempo minimo para explodir o cofre da Ammunation
local vaultExplosionMax = 16 -- Tempo maximo para explodir o cofre da Ammunation
-----------------------------------------------------------------------------------------------------------------------------------------
-- ATMS
-----------------------------------------------------------------------------------------------------------------------------------------
local vaults = {
	{ 1690.81,3757.58,34.71,134.95 },
    { 253.83,-46.82,69.95,340.65 },
    { 845.86,-1034.07,28.2,272.45 },
    { -333.21,6081.64,31.46,163.98 },
    { -665.75,-934.81,21.83,96.61 },
    { -1304.49,-390.95,36.7,346.54 },
    { -1120.72,2696.53,18.56,131.83 },
    { 2571.42,293.84,108.74,269.30 },
    { -3173.74,1084.71,20.84,156.50 },
    { 3.84,-1108.47,29.8,106.62 },
    { 826.79,-2149.8,29.62,311.67 }
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREAD DAS ATMS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("arcade-ammunation:rouboAmmu")
AddEventHandler("arcade-ammunation:rouboAmmu",function()
	local ped = PlayerPedId()
	if not vaultStart then
		if not IsPedInAnyVehicle(ped) then
			local coords = GetEntityCoords(ped)
			for k,v in pairs(vaults) do
				local distance = #(coords - vector3(v[1],v[2],v[3]))
				if distance <= 0.6 then
					if vSERVER.startVault() then
						vaultPosX = v[1]
						vaultPosY = v[2]
						vaultPosZ = v[3]
						SetEntityHeading(ped,v[4])
						TriggerEvent("cancelando",true)
						SetEntityCoords(ped,v[1],v[2],v[3]-1)
						vRP._playAnim(false,{{"anim@amb@clubhouse@tutorial@bkr_tut_ig3@","machinic_loop_mechandplayer"}},true)

						Citizen.Wait(10000)
						startthreadvaultstart()
						vaultStart = true
						vRP.removeObjects()
						TriggerEvent("cancelando",false)
						vRP._stopAnim(source,false)
						vaultTimer = math.random(vaultExplosionMin,vaultExplosionMax)
						vSERVER.callPolice(vaultPosX,vaultPosY,vaultPosZ)

						local mHash = GetHashKey("prop_c4_final_green")

						RequestModel(mHash)
						while not HasModelLoaded(mHash) do
							RequestModel(mHash)
							Citizen.Wait(10)
						end

						local coords = GetOffsetFromEntityInWorldCoords(ped,0.0,0.23,0.0)
						objectBomb = CreateObjectNoOffset(mHash,coords.x,coords.y,coords.z-0.23,true,false,false)
						SetEntityAsMissionEntity(objectBomb,true,true)
						FreezeEntityPosition(objectBomb,true)
						SetEntityHeading(objectBomb,v[4])
						SetModelAsNoLongerNeeded(mHash)
					end
				end
			end
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- MACHINE DO TEMPO
-----------------------------------------------------------------------------------------------------------------------------------------
function startthreadvaultstart()
	Citizen.CreateThread(function()
		while true do
			if vaultStart and vaultTimer > 0 then
				vaultTimer = vaultTimer - 1
				if vaultTimer <= 0 then
					vaultStart = false
					DeleteEntity(objectBomb)
					AddExplosion(vaultPosX,vaultPosY,vaultPosZ,2,100.0,true,false,true)
					vSERVER.stopVault(vaultPosX,vaultPosY,vaultPosZ)
				end
			end
			Citizen.Wait(1000)
		end
	end)
end