-- Autosave+: rolling autosaves in a range of slots of their own.
-- cleria.game.save(slot) saves as a goddess statue does, and refuses when it is not safe (a cutscene, a boss
-- fight, a door in progress): a wanted save simply waits for the next safe moment.

local S, G = cleria.settings, cleria.game

local enabled = S.get("Enabled", true)
local first = S.get("FirstSlot", 61)           -- the book's "No.61": slots are shown 1-based there
local count = S.get("Slots", 4)                -- No.61 .. No.64 by default
local minutes = S.get("Minutes", 5)            -- 0 = no timed autosave
local on_boss = S.get("AfterBoss", true)
local on_zone = S.get("NewZone", true)
local announce = S.get("Announce", true)

local next_i = S.get("Next", 0)                -- which slot of the range is written next (kept between sessions)
local want, want_since = nil, 0                -- why a save is wanted, and since when (seconds)
local ticks = 0                                -- play ticks since the last autosave
local last = nil                               -- {slot, why} of the last autosave, for the page

local function ask(why)
    if enabled and not want then want, want_since = why, cleria.time() end
end

cleria.events.on("boss_defeated", function() if on_boss then ask("a boss fell") end end)
cleria.events.on("room_enter", function(e)
    if not on_zone or not cleria.save.ready() then return end
    local zone = G.scene() // 1000
    local seen = cleria.save.get("zone", 0)
    if zone >= 1 and zone <= 7 and zone > seen then
        cleria.save.set("zone", zone)
        if seen > 0 then ask("a new zone") end          -- not for the zone a game starts in
    end
end)
cleria.events.on("new_game", function() ticks = 0 if cleria.save.ready() then cleria.save.set("zone", G.scene() // 1000) end end)
cleria.events.on("load", function() ticks, want = 0, nil end)

cleria.events.on("tick", function()
    if not enabled or not G.in_game() then return end
    if not G.frozen() then
        ticks = ticks + 1
        if minutes > 0 and ticks >= minutes * 3600 then ask(minutes .. " minutes of play") end
    end
    if not want then return end
    if cleria.time() - want_since > 120 then want = nil return end        -- never safe for two minutes: drop it
    local slot = first - 1 + next_i % math.max(count, 1)
    if G.save(slot) then
        last = {slot = slot, why = want}
        cleria.log("autosaved to No." .. (slot + 1) .. " (" .. want .. ")")
        if announce then cleria.notice("Saved to No." .. (slot + 1) .. " (" .. want .. ").", "Autosave+") end
        next_i = (next_i + 1) % math.max(count, 1)
        S.set("Next", next_i)
        want, ticks = nil, 0
    end
end)

cleria.ui.page("Autosave+", function(p)
    p:section("Autosave+")
    p:info("Last autosave", last and ("No." .. (last.slot + 1) .. " (" .. last.why .. ")") or "none this session",
           want and ("Waiting for a safe moment: " .. want .. ".") or "")
    local v, ch = p:toggle("Enabled", enabled, "Saves by itself into the slots below. Not a retail option.")
    if ch then enabled = v S.set("Enabled", v) end
    v, ch = p:slider("First slot", first, 1, 64, 1, "No.%.0f", "The first save slot used for autosaves.")
    if ch then first = math.floor(v + 0.5) count = math.min(count, 65 - first) S.set("FirstSlot", first) S.set("Slots", count) end
    v, ch = p:slider("Slots", count, 1, math.min(16, 65 - first), 1, "%.0f", "How many slots are used in turn. The oldest autosave is replaced.")
    if ch then count = math.floor(v + 0.5) S.set("Slots", count) end
    p:section("When")
    v, ch = p:slider("Every", minutes, 0, 30, 1, "%.0f min", "Minutes of play between two autosaves. 0 = never on a timer.")
    if ch then minutes = math.floor(v + 0.5) S.set("Minutes", minutes) end
    v, ch = p:toggle("After a boss", on_boss, "As soon as a boss, a mid-boss or a duel is won and the game gives the controls back.")
    if ch then on_boss = v S.set("AfterBoss", v) end
    v, ch = p:toggle("In a new zone", on_zone, "The first time you enter each zone of the tower.")
    if ch then on_zone = v S.set("NewZone", v) end
    v, ch = p:toggle("Show a card", announce, "A card each time an autosave is written.")
    if ch then announce = v S.set("Announce", v) end
    if p:button("Save now", {desc = "Asks for an autosave at the next safe moment.", enabled = G.in_game()}) then ask("asked") end
end)

cleria.command("as", function(a)
    if a ~= "" then ask(a) end
    cleria.log("want " .. tostring(want) .. " next " .. next_i .. " ticks " .. ticks)
end)
cleria.log("Autosave+ loaded: No." .. first .. " to No." .. (first + count - 1))
