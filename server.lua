-- =========================
-- DANIELGDM180_revive Commands
-- =========================

-- /respawn
RegisterCommand("respawn", function(source)
    TriggerClientEvent('DANIELGDM180_revive:allowRespawn', source)
end, false)

-- /toggledeath
RegisterCommand("toggleDeath", function(source)
    TriggerClientEvent('DANIELGDM180_revive:toggleDeath', source)
end, false)

-- /revive [id]
RegisterCommand("revive", function(source, args)
    local target = source

    if args[1] then
        target = tonumber(args[1])

        if not target or not GetPlayerName(target) then
            TriggerClientEvent('chat:addMessage', source, {
                args = { "DANIELGDM180_revive", "^1Invalid Player ID" }
            })
            return
        end
    end

    TriggerClientEvent('DANIELGDM180_revive:allowRevive', target, source)

    if target ~= source then
        TriggerClientEvent('chat:addMessage', source, {
            args = { "DANIELGDM180_revive", "Player revived" }
        })
    end
end, false)
