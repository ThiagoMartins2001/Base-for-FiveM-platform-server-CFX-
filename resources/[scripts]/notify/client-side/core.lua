-----------------------------------------------------------------------------------------------------------------------------------------
-- NOTIFY
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("Notify")
AddEventHandler("Notify",function(Css,Message,Timer,Title)
	if Title then
		SendNUIMessage({ name = "Notify", payload = { Css,Message,Title,Timer } })
	else
		SendNUIMessage({ name = "Notify", payload = { Css,Message,"",Timer } })
	end
end)