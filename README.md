# MM2 Hub

Roblox MM2 script hub — Linoria UI, RightControl minimize.

- `main.lua` — entry point. Loads LinoriaLib from
  [violin-suzutsuki/LinoriaLib](https://github.com/violin-suzutsuki/LinoriaLib),
  builds the nine tabs, wires every control.
- `FEATURES.md` — full feature map + module slots.
- `modules/` — feature engines (populated from the sourced repos; each module
  exports `enabled(v)/radius(v)/...` callbacks matching the UI wiring, plus a
  `destroy()` for clean unload).

## Run
```lua
loadstring(game:HttpGet('https://raw.githubusercontent.com/<YOU>/mm2-hub/main/main.lua'))()
```

## Unload
Main → master panic toggle, or hub destroy hook.

## Keys
- **RightControl** — minimize/restore (Settings → toggle key rebind)
