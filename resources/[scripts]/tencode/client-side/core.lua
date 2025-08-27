-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
vSERVER = Tunnel.getInterface("tencode")
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADBUTTON
-----------------------------------------------------------------------------------------------------------------------------------------
local policeRadar = false
local policeFreeze = false
-----------------------------------------------------------------------------------------------------------------------------------------
-- CLOSESYSTEM
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("closeSystem",function(Data,Callback)
	SetNuiFocus(false,false)
	SetCursorLocation(0.5,0.5)
	SendNUIMessage({ tencode = false })

	Callback("Ok")
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SENDCODE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("sendCode",function(Data,Callback)
	SetNuiFocus(false,false)
	SetCursorLocation(0.5,0.5)
	print("^2[tencode] Enviando código: " .. Data["code"] .. "^7")
	vSERVER.sendCode(Data["code"])
	SendNUIMessage({ tencode = false })

	Callback("Ok")
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- FUNCTIONS
-----------------------------------------------------------------------------------------------------------------------------------------
function IsPoliceOfficer()
	return LocalPlayer["state"]["PoliciaMilitar"] or LocalPlayer["state"]["Core"] or LocalPlayer["state"]["PRF"] or LocalPlayer["state"]["PCivil"]
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADRADAR
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	while true do
		local TimeDistance = 999
		local Ped = PlayerPedId()
		if IsPedInAnyPoliceVehicle(Ped) and IsPoliceOfficer() then
			if policeRadar then
				if not policeFreeze then
					TimeDistance = 100

					local vehicle = GetVehiclePedIsUsing(Ped)
					local vehicleDimension = GetOffsetFromEntityInWorldCoords(vehicle,0.0,1.0,1.0)

					local vehicleFront = GetOffsetFromEntityInWorldCoords(vehicle,0.0,105.0,0.0)
					local vehicleFrontShape = StartShapeTestCapsule(vehicleDimension,vehicleFront,3.0,10,vehicle,7)
					local _,_,_,_,vehFront = GetShapeTestResult(vehicleFrontShape)

					if IsEntityAVehicle(vehFront) then
						local vehHash = vRP.VehicleModel(vehFront)
						local vehSpeed = GetEntitySpeed(vehFront) * 3.6
						local Plate = GetVehicleNumberPlateText(vehFront)

						SendNUIMessage({ radar = "top", plate = Plate, Model = VehicleName(vehHash), speed = vehSpeed })
					end

					local vehicleBack = GetOffsetFromEntityInWorldCoords(vehicle,0.0,-105.0,0.0)
					local vehicleBackShape = StartShapeTestCapsule(vehicleDimension,vehicleBack,3.0,10,vehicle,7)
					local _,_,_,_,vehBack = GetShapeTestResult(vehicleBackShape)

					if IsEntityAVehicle(vehBack) then
						local vehHash = vRP.VehicleModel(vehBack)
						local vehSpeed = GetEntitySpeed(vehBack) * 3.6
						local Plate = GetVehicleNumberPlateText(vehBack)

						SendNUIMessage({ radar = "bot", plate = Plate, Model = VehicleName(vehHash), speed = vehSpeed })
					end
				end
			end
		end

		if not IsPedInAnyVehicle(Ped) and policeRadar then
			policeRadar = false
			SendNUIMessage({ radar = false })
		end

		Wait(TimeDistance)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- TOGGLERADAR
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("toggleRadar",function()
	if not IsPauseMenuActive() then
		local Ped = PlayerPedId()
		if IsPedInAnyPoliceVehicle(Ped) and IsPoliceOfficer() then
			if policeRadar then
				policeRadar = false
				SendNUIMessage({ radar = false })
				print("^3[tencode] Radar desativado^7")
			else
				policeRadar = true
				SendNUIMessage({ radar = true })
				print("^2[tencode] Radar ativado^7")
			end
		else
			print("^1[tencode] Radar: Você precisa estar em uma viatura policial e em serviço^7")
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- TOGGLEFREEZE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("toggleFreeze",function()
	local Ped = PlayerPedId()
	if IsPedInAnyPoliceVehicle(Ped) and IsPoliceOfficer() and not IsPauseMenuActive() then
		policeFreeze = not policeFreeze
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- TENCODE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("enterTencodes",function()
	if IsPoliceOfficer() and LocalPlayer["state"]["Route"] < 900000 and not IsPauseMenuActive() then
		SetNuiFocus(true,true)
		SetCursorLocation(0.5,0.1)
		SendNUIMessage({ tencode = true })
		print("^2[tencode] Menu de códigos aberto^7")
	else
		if not IsPoliceOfficer() then
			print("^1[tencode] Menu: Você precisa estar em serviço como policial^7")
		elseif LocalPlayer["state"]["Route"] >= 900000 then
			print("^1[tencode] Menu: Você precisa estar em rota^7")
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- KEYMAPPING
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterKeyMapping("enterTencodes","Manusear o código policial.","keyboard","F3")
RegisterKeyMapping("toggleRadar","Ativar/Desativar radar das viaturas.","keyboard","N")
RegisterKeyMapping("toggleFreeze","Travar/Destravar radar das viaturas.","keyboard","M")