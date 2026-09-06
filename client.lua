RegisterNetEvent('DANIELGDM180_revive:allowRespawn')
RegisterNetEvent('DANIELGDM180_revive:allowRevive')
RegisterNetEvent('DANIELGDM180_revive:toggleDeath')
RegisterNetEvent('DANIELGDM180_revive:notify')

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
local notifyTypes = {
    success = 'success',
    warning = 'warning',
    error   = 'error',
    default = 'inform'
}

-- type: "default" | "success" | "warning" | "error"
local function notify(msg, notifyType, duration)
    local oxType = notifyTypes[notifyType] or notifyTypes.default

    lib.notify({
        title = 'DANIELGDM180_revive',
        description = msg,
        type = oxType,
        duration = duration or 3500,
        position = 'top-right'
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
AddEventHandler('DANIELGDM180_revive:notify', function(msg, notifyType, duration)
    notify(msg, notifyType, duration)
end)

AddEventHandler('DANIELGDM180_revive:allowRespawn', function()
    notify("Respawning...", "default")
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
            notify("You must wait " .. seconds .. " seconds before reviving.", "warning")
            return
        end
    end

    notify("Revived", "success")
    allowRevive = true
end)

AddEventHandler('DANIELGDM180_revive:toggleDeath', function()
    DANIELGDM180_reviveEnabled = not DANIELGDM180_reviveEnabled

    if DANIELGDM180_reviveEnabled then
        notify("toggleDeath enabled.", "success")
    else
        notify("toggleDeath disabled.", "error")
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
