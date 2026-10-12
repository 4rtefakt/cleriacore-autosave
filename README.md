# Autosave+

Rolling autosaves for **Ys Origin** on CleriaCore, in slots of their own. Your own saves are never touched.

- **When:** every 5 minutes of play, after each boss, mid-boss or duel you win, and the first time you enter each
  zone of the tower. Each of the three can be turned off; the timer is a slider.
- **Where:** slots No.61 to No.64 by default, used in turn, so the oldest autosave is the one replaced. The first
  slot and the number of slots are settings.
- **Safe:** a save that is wanted during a cutscene, a boss fight or a door waits for the next safe moment (and is
  dropped after two minutes if there is none).
- A card says where each autosave went. **F1 > Mods > Autosave+** has the settings and a *Save now* button.

To go back to an autosave, load its slot from the title or the book like any other save.

## Install

1. Download `4rtefakt.autosave-1.0.0.cleriamod` from the [releases](../../releases).
2. Double-click it (or use F1 > Mods > *Install a mod file...*).
3. Turn **Autosave+** on in F1 > Mods and restart CleriaCore.

Needs a CleriaCore with mod API 4.

## How it works

One Lua file, [main.lua](main.lua), about 90 lines. `cleria.game.save(slot)` saves as a goddess statue does and
returns `false` when it is not safe, so the mod only has to keep asking:

```lua
cleria.events.on("tick", function()
    if not want then return end
    local slot = first - 1 + next_i % count
    if G.save(slot) then                         -- false in a cutscene, a boss fight, a door...
        cleria.notice("Saved to No." .. (slot + 1) .. " (" .. want .. ").", "Autosave+")
        next_i = (next_i + 1) % count
        want = nil
    end
end)
```

| Part | API |
|---|---|
| Saving | `cleria.game.save(slot)` (mod API 4) |
| What asks for a save | the events `boss_defeated`, `room_enter`, and play time counted on `tick` |
| The slot to use next, kept between sessions | `cleria.settings` |
| The page | `cleria.ui.page` (sliders, toggles, a button) |

## Tests

`python .dev/run.py` runs four cases through CleriaCore's headless harness: three saves asked in a row land in
No.61, No.62 and No.61 again with two slots, and a boss's flag asks for a fourth by itself; a one-minute timer
fires; a save asked while the controls are taken waits and lands when they are back; turned off, nothing is saved.

Not covered: the new-zone trigger has no test of its own, and nobody has played a long session with it.

## More CleriaCore mods

Each one is a small Lua mod that shows a different part of the mod API:

- [Mutators](https://github.com/4rtefakt/cleriacore-mutators): challenge rules: Glass Cannon, Berserker, One Hit, Vampire, Midas, Famine, Permadeath, a level cap
- [Solo Randomizer](https://github.com/4rtefakt/cleriacore-solo-randomizer): the tower's chests shuffled from a seed, always beatable, no server
- [Daily Challenge](https://github.com/4rtefakt/cleriacore-daily-challenge): the date shuffles the chests and picks two rules, the same for everyone
- [Roguelite Perks](https://github.com/4rtefakt/cleriacore-roguelite-perks): every boss beaten lets you choose one of three random perks
- [New Game+](https://github.com/4rtefakt/cleriacore-new-game-plus): start again with part of your level, SP and weapon against a harder tower
- [Level Sync](https://github.com/4rtefakt/cleriacore-level-sync): monsters fight as if they were near your level
- [Adaptive Difficulty](https://github.com/4rtefakt/cleriacore-adaptive-difficulty): enemies hit softer after each death, and return to normal as you progress
- [Achievements](https://github.com/4rtefakt/cleriacore-achievements): thirty achievements kept across all your saves
- [Run HUD](https://github.com/4rtefakt/cleriacore-run-hud): room and run time, kills, deaths, damage per second
- [Bestiary+](https://github.com/4rtefakt/cleriacore-bestiary): a per-save hunting log of every monster killed
- [Debug Menu](https://github.com/4rtefakt/cleriacore-debug-menu): change level, SP, items, gear, skills, blessings, warps and flags
- [Crowd Control](https://github.com/4rtefakt/cleriacore-crowd-control): Twitch chat votes on what happens to you
- [LiveSplit Autosplitter](https://github.com/4rtefakt/cleriacore-livesplit): starts and splits LiveSplit over its WebSocket server
- [Archipelago](https://github.com/4rtefakt/ys-origin-cleriacore-ap): the multiworld randomizer client, the biggest one

## About

Written with AI assistance (Claude Code) as a showcase of the CleriaCore mod API, and tested as described above.
MIT license.
