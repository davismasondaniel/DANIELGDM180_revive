# DANIELGDM180_revive

Standalone revive/respawn system for RP servers. Prevents the default FiveM death/respawn flow so downed players stay on the ground until another player revives them or they choose to respawn — no framework dependency required.

## Features

- Disables `spawnmanager` auto-respawn so players stay downed on death
- `/revive [id]` — revive yourself or a target player, with an optional self-revive cooldown
- `/respawn` — send a player back to life at a random spawn point
- `/toggleDeath` — enable/disable the whole revive system on the fly
- Configurable self-revive cooldown (`reviveWaitPeriod`)
- Chat notifications via `chat:addMessage`

## Installation

1. Copy the `DANIELGDM180_revive` folder into your server's `resources` directory.
2. Add to your `server.cfg`:
   ```
   ensure DANIELGDM180_revive
   ```
3. Restart the resource or your server.

## Configuration

Edit the top of `client.lua`:

| Variable | Default | Description |
|---|---|---|
| `reviveWaitPeriod` | `0` | Seconds a player must wait before they can self-revive again after dying |
| `DANIELGDM180_reviveEnabled` | `true` | Whether the revive system is active on resource start |

Spawn points used by `/respawn` are defined in the `spawnPoints` table in `client.lua`:

```lua
local spawnPoints = {
    { x = 373.0,  y = -595.0, z = 30.0,  heading = 0.0 }, -- Pillbox
    { x = 1852.0, y = 3702.0, z = 35.0,  heading = 0.0 }, -- Sandy
    { x = -246.0, y = 6330.0, z = 33.5,  heading = 0.0 }, -- Paleto
}
```
Add, remove, or edit entries as needed — each needs `x`, `y`, `z`, and `heading`.

## Commands

| Command | Usage | Description |
|---|---|---|
| `/revive` | `/revive` or `/revive [id]` | Revives yourself, or the specified player ID |
| `/respawn` | `/respawn` | Respawns the calling player at a random configured spawn point |
| `/toggleDeath` | `/toggleDeath` | Toggles the revive system on/off server-wide per client |

By default these commands have no ACE permission restriction — restrict them in your permissions/framework as needed (e.g. limit `/revive [id]` and `/respawn` to staff).

## How It Works

- On death, the client sets the ped invincible, holds health at 1, and waits in a tight loop until told to respawn or revive.
- `NetworkResurrectLocalPlayer` handles the actual resurrection; `ClearPedBloodDamage` cleans up gore afterward.
- The main loop only runs `Wait(0)` while the player is dead; it drops to `Wait(500)` while alive to avoid unnecessary tick cost.

## Requirements

- FiveM server (`fx_version 'cerulean'`, `lua54 'yes'`)
- `spawnmanager` resource (started before this one)

## File Structure

```
DANIELGDM180_revive/
├── fxmanifest.lua
├── client.lua
└── server.lua
```

## Notes

- No QBCore/framework dependency — works on vanilla or any framework.
- Self-revive cooldown only applies when a player revives *themselves* (`from == source`); reviving others is never rate-limited.
