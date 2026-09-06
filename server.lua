-- =========================
-- DANIELGDM180_revive Commands
-- =========================

-- /respawn
RegisterCommand("respawn", function(source)
    TriggerClientEvent('DANIELGDM180_revive:allowRespawn', source)
end, false)

-- /toggledeath
RegisterCommand("toggledeath", function(source)
    TriggerClientEvent('DANIELGDM180_revive:toggleDeath', source)
end, false)

-- /revive [id]
RegisterCommand("revive", function(source, args)
    local target = source

    if args[1] then
        target = tonumber(args[1])

        if not target or not GetPlayerName(target) then
            TriggerClientEvent('DANIELGDM180_revive:notify', source, "Invalid Player ID", "error")
            return
        end
    end

    TriggerClientEvent('DANIELGDM180_revive:allowRevive', target, source)

    if target ~= source then
        TriggerClientEvent('DANIELGDM180_revive:notify', source, "Player revived", "success")
    end
end, false)
