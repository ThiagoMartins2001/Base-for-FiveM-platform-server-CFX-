print("^2[MDT TEST] Arquivo de teste carregado com sucesso^7")

RegisterCommand("mdt_test_simple", function()
    print("^2[MDT TEST] Comando de teste executado^7")
    TriggerEvent("Notify", "sucesso", "MDT Test funcionando!")
end)
