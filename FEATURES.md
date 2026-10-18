# MM2 Hub — Features Manifest

Linoria UI. Minimize key: **RightControl** (rebindable in Settings).
All 9 menu tabs are scaffolded and fully wired; engines land in `modules/` from
the open-source MM2 repos (links pending). Below: every feature, its UI home,
and its module slot.

## Tab mapping

| Tab | Groupboxes |
|---|---|
| Main | Quick Actions, Status |
| Combat | Role ESP, Silent Aim, Kill Aura, Auto Shoot, Knife Throw, Fake Position |
| Auto Farm | Auto Farm |
| Teleport | Teleport, Per Player Fling |
| Troll Fun | Troll Tools, Round Music |
| Free anims | Animation Packs, Emotes |
| Fling Players | Player List |
| Visuals | Graphics, Lighting Presets, Optimizer |
| Settings | Menu, Server, Themes, Configuration |

## Feature matrix (port slots)

### Role ESP — `modules/role_esp.lua`
- [ ] Box (corner / full), skeleton, tracers
- [ ] Gun ESP + X-Ray
- [ ] Role text, nickname, distance on the label
- UI: Combat → Role ESP (toggles: `EspEnabled/EspBox/EspBoxType/EspSkeleton/EspTracers/EspGun/EspXRay/EspRoleText/EspNickname/EspDistance`, dropdown `EspFilter`)

### Silent Aim — `modules/silent_aim.lua`
- [ ] Aim version (v1 part based / v2 humanoid based)
- [ ] Aimbot type (nearest part / nearest point / head / torso)
- [ ] Flick speed + flick return sliders
- [ ] Prediction in ms
- [ ] Wall check
- [ ] FOV circle + size
- UI: Combat → Silent Aim

### Kill Aura — `modules/kill_aura.lua`
- [ ] Radius slider
- [ ] Kill all / sheriff only

### Auto Shoot — `modules/auto_shoot.lua`
- [ ] Auto pickup gun
- [ ] Auto shoot + auto kill the murderer
- [ ] Auto fling the sheriff
- [ ] Shoot key (hold mode key picker)

### Knife Throw Aimbot — `modules/knife_throw.lua`
- [ ] Throws with wall check
- [ ] Prediction lead slider

### Fake Position — `modules/fake_position.lua`
- [ ] Desync with mode (orbit / random / stay), radius + speed
- [ ] Face threat
- [ ] Resolver

### Auto Farm — `modules/auto_farm.lua`
- [ ] Farm version (legacy / fast) + speed
- [ ] Auto respawn on a full bag
- [ ] Avoid the murderer
- [ ] Auto fling after respawn
- Master toggle on Main too (`FarmEnabled`)

### Movement — `modules/movement.lua`
- [ ] No clip
- [ ] Infinite jumps
- [ ] Anti fling
- [ ] Bomb jump
- [ ] Fly
- [ ] Spin
- [ ] Bhop
- Each on its own key (key pickers — Build into a Movement groupbox loop)

### Teleport — `modules/teleport.lua`
- [ ] Lobby / Murderer / Sheriff
- Per-player fling list shares `modules/fling_players.lua`

### Free Anims — `modules/free_anims.lua`
- [ ] Animation packs (women/run/zombie/ninja/elder/pirate/levitate/rthro/astronaut/toy)
- [ ] Emotes (+ speed sliders)
- [ ] Hold mode (hold key)
- [ ] Auto load on respawn

### Troll Tools — `modules/troll_tools.lua`
- [ ] Emotes, toys
- [ ] Fake korblox, fake headless
- [ ] Walk speed, jump power
- [ ] Touch fling, click fling, orbit (radius/speed)

### Round Music — `modules/round_music.lua`
- [ ] Auto play on round start with a random song
- [ ] Start delay + local volume

### Visuals — `modules/visuals.lua`
- [ ] Bloom, atmosphere, sun rays, blur, depth of field, ground fog
- [ ] Chams, backtrack, walk trails

### Lighting Presets — `modules/lighting.lua`
- [ ] Night / realistic / future / studio / desert / clear
- [ ] Per-preset sliders (brightness/exposure scaffolded)

### Optimizer — `modules/optimizer.lua`
- [ ] Remove textures, particles, shadows, reflections
- [ ] Low quality mode
- [ ] FPS unlocker to 9999

### Server Tools — `modules/server_tools.lua`
- [ ] Rejoin, server hop, join a small server
- [ ] Copy job id, anti AFK
- Exposed on Main (quick actions) AND Settings → Server

### Menu Extension — `modules/menu_extend.lua`
- [ ] UI theme (ThemeManager), size, screen stretch
- [ ] Font + text size (engine side), toggle key, language

### Fling Players — `modules/fling_players.lua`
- [ ] Per player fling list, auto fling, clear
- [ ] Used by Teleport tab and Auto Shoot's sheriff fling

## Pending from Idris
1. **MM2 script repo link(s)** — source engines for the matrix above.
2. **External link** — reference for the hub's client-side pieces.

Port order after links land: Role ESP → Silent Aim → Auto Shoot/Kill Aura →
Auto Farm → Movement → the rest.
