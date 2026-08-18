-- =========================
-- RPDeath Commands
-- =========================

-- /respawn
RegisterCommand("respawn", function(source)
    TriggerClientEvent('RPD:allowRespawn', source)
end, false)

-- /toggledeath
RegisterCommand("toggleDeath", function(source)
    TriggerClientEvent('RPD:toggleDeath', source)
end, false)

-- /revive [id]
RegisterCommand("revive", function(source, args)
    local target = source

    if args[1] then
        target = tonumber(args[1])

        if not target or not GetPlayerName(target) then
            TriggerClientEvent('chat:addMessage', source, {
                args = { "RPDeath", "^1Invalid Player ID" }
            })
            return
        end
    end

    TriggerClientEvent('RPD:allowRevive', target, source)

    if target ~= source then
        TriggerClientEvent('chat:addMessage', source, {
            args = { "RPDeath", "Player revived" }
        })
    end
end, false)
