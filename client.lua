RegisterNetEvent('DANIELGDM180_revive:allowRespawn')
RegisterNetEvent('DANIELGDM180_revive:allowRevive')
RegisterNetEvent('DANIELGDM180_revive:toggleDeath')

-- =========================
-- Config
-- =========================
local reviveWaitPeriod = 0 -- seconds
local DANIELGDM180_reviveEnabled = true

-- =========================
-- State
-- =========================
local allowRespawn = false
local allowRevive = false
local diedTime = nil

-- =========================
-- Utilities
-- =========================
local function notify(msg)
    TriggerEvent('chat:addMessage', {
        args = { "DANIELGDM180_revive", msg }
    })
end

-- =========================
-- Disable Auto Spawn
-- =========================
AddEventHandler('onClientMapStart', function()
    exports.spawnmanager:spawnPlayer()
    Wait(2500)
    exports.spawnmanager:setAutoSpawn(false)
end)

-- =========================
-- Network Events
-- =========================
AddEventHandler('DANIELGDM180_revive:allowRespawn', function()
    notify("Respawning...")
    allowRespawn = true
end)

AddEventHandler('DANIELGDM180_revive:allowRevive', function(from)
    local ped = PlayerPedId()

    if not IsEntityDead(ped) then return end

    -- Self revive cooldown
    if GetPlayerServerId(PlayerId()) == from and diedTime then
        local waitUntil = diedTime + (reviveWaitPeriod * 1000)

        if GetGameTimer() < waitUntil then
            local seconds = math.ceil((waitUntil - GetGameTimer()) / 1000)
            notify("You must wait ^5" .. seconds .. "^0 seconds before reviving.")
            return
        end
    end

    notify("Revived")
    allowRevive = true
end)

AddEventHandler('DANIELGDM180_revive:toggleDeath', function()
    DANIELGDM180_reviveEnabled = not DANIELGDM180_reviveEnabled

    if DANIELGDM180_reviveEnabled then
        notify("DANIELGDM180_revive enabled.")
    else
        notify("DANIELGDM180_revive disabled.")
    end
end)

-- =========================
-- Respawn / Revive Functions
-- =========================
local function revivePed(ped)
    local coords = GetEntityCoords(ped)
    NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, true, true, false)
    SetPlayerInvincible(ped, false)
    ClearPedBloodDamage(ped)
end

local function respawnPed(ped, coords)
    SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, false, false, false)
    NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, coords.heading, true, false)
    SetPlayerInvincible(ped, false)
    TriggerEvent('playerSpawned', coords)
    ClearPedBloodDamage(ped)
end

-- =========================
-- Spawn Points
-- =========================
local spawnPoints = {
    { x = 373.0,  y = -595.0, z = 30.0, heading = 0.0 }, -- Pillbox
    { x = 1852.0, y = 3702.0, z = 35.0, heading = 0.0 }, -- Sandy
    { x = -246.0, y = 6330.0, z = 33.5, heading = 0.0 } -- Paleto
}

-- =========================
-- Main Thread
-- =========================
CreateThread(function()
    while true do
        local ped = PlayerPedId()

        if DANIELGDM180_reviveEnabled and IsEntityDead(ped) then
            diedTime = diedTime or GetGameTimer()

            SetPlayerInvincible(ped, true)
            SetEntityHealth(ped, 1)

            if allowRespawn then
                local coords = spawnPoints[math.random(#spawnPoints)]
                respawnPed(ped, coords)

                allowRespawn = false
                diedTime = nil

            elseif allowRevive then
                revivePed(ped)

                allowRevive = false
                diedTime = nil
            end

            Wait(0) -- only tight loop while dead
        else
            allowRespawn = false
            allowRevive = false
            diedTime = nil
            Wait(500) -- optimized when alive
        end
    end
end)
