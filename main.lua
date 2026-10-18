--// language: Luau | target: Roblox / Murder Mystery 2 | runtime: any executor
--// MM2 Script Hub — Linoria UI, RightControl minimize
--// Features fill in from the MM2 open-source repos (links pending from Idris):
--// every control below wires through Hub.Modules so an engine only has to be
--// dropped into hub/modules/<name>.lua — no UI code changes.

local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/';

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))();
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))();
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))();
local Players = game:GetService('Players');
local InputService = game:GetService('UserInputService');
local LocalPlayer = Players.LocalPlayer;

local Hub = {
    Modules = {};         -- name -> module table { OnToggled, OnSlider, OnClick, Destroy }
    Wires = {};           -- option index -> active wiring
    Window = nil;
    Toggles = Toggles;    -- Linoria registry
    Options = Options;
};

local function get(name)
    local m = Hub.Modules[name];
    assert(m, 'hub.Modules.' .. name .. ' missing — port pending (see FEATURES.md)');
    return m;
end

-- shared wiring helper: name = module key, others forwarded verbatim
local function wire(name, ...)
    local args, n = { ... }, select('#', ...);
    for i = n + 1, 8 do args[i] = nil end
    return function(new)
        local m = get(name);
        (m.OnChange or function() end)(Options[name] and Options[name].Value, args[1], args[2]);
    end
end

-- =========================================================================--
--  WINDOW
-- =========================================================================--
local Window = Library:CreateWindow({
    Title = 'MM2 Hub',
    Center = true,
    AutoShow = true,
    TabSize = 140,
});

Hub.Window = Window;

local Tabs = {
    Main = Window:AddTab('Main'),
    Combat = Window:AddTab('Combat'),
    AutoFarm = Window:AddTab('Auto Farm'),
    Teleport = Window:AddTab('Teleport'),
    TrollFun = Window:AddTab('Troll Fun'),
    FreeAnims = Window:AddTab('Free anims'),
    FlingPlayers = Window:AddTab('Fling Players'),
    Visuals = Window:AddTab('Visuals'),
    Settings = Window:AddTab('Settings'),
};

local ROLES = { 'Innocent', 'Sheriff', 'Murderer' };

-- =========================================================================--
--  MAIN
-- =========================================================================--
do
    local gb = Tabs.Main:AddLeftGroupbox('Quick Actions');
    gb:AddButton('Rejoin', function() get('ServerTools').rejoin() end);
    gb:AddButton('Server Hop', function() get('ServerTools').hop() end);
    gb:AddButton('Copy Job Id', function() get('ServerTools').copy_job_id() end);
    gb:AddToggle('AntiAFK', {
        Text = 'Anti AFK',
        Default = false,
        Callback = function(v) get('ServerTools').anti_afk(v) end,
    });

    local gb2 = Tabs.Main:AddRightGroupbox('Status');
    gb2:AddToggle('FarmEnabled', {
        Text = 'Auto Farm (master)',
        Default = false,
        Callback = function(v) get('AutoFarm').master(v) end,
    });
    gb2:AddDropdown('FarmVersion', {
        Text = 'Farm version',
        Values = { 'Legacy', 'Fast' },
        Default = 1,
        Callback = wire('AutoFarm'),
    });
    gb2:AddSlider('FarmSpeed', {
        Text = 'Farm speed',
        Default = 5, Min = 1, Max = 20, Rounding = 0,
        Compact = true,
        Callback = wire('AutoFarm'),
    });
    gb2:AddToggle('PanicKey', {
        Text = 'Panic — unload everything',
        Default = false,
        Callback = function(v)
            if v then Hub:unload(); end
        end,
    });
end

-- =========================================================================--
--  COMBAT
-- =========================================================================--
do
    -- Role ESP --------------------------------------------------------------
    local esp = Tabs.Combat:AddLeftGroupbox('Role ESP');
    esp:AddToggle('EspEnabled', {
        Text = 'Enabled',
        Default = false,
        Callback = function(v) get('RoleESP').enabled(v) end,
    });
    esp:AddDropdown('EspFilter', {
        Text = 'Roles',
        Values = ROLES,
        Default = { 'Innocent', 'Sheriff', 'Murderer' },
        Multi = true,
        Callback = function(v) get('RoleESP').filter(v) end,
    });
    esp:AddToggle('EspBox', {
        Text = 'Box', Default = false, Callback = function(v) get('RoleESP').box(v) end,
    });
    esp:AddDropdown('EspBoxType', {
        Text = 'Box type', Values = { 'Corner', 'Full' }, Default = 1,
        Callback = function(v) get('RoleESP').box_type(v) end,
    });
    esp:AddToggle('EspSkeleton', {
        Text = 'Skeleton', Default = false, Callback = function(v) get('RoleESP').skeleton(v) end,
    });
    esp:AddToggle('EspTracers', {
        Text = 'Tracers', Default = false, Callback = function(v) get('RoleESP').tracers(v) end,
    });
    esp:AddToggle('EspGun', {
        Text = 'Gun ESP', Default = false, Callback = function(v) get('RoleESP').gun(v) end,
    });
    esp:AddToggle('EspXRay', {
        Text = 'X-Ray', Default = false, Callback = function(v) get('RoleESP').xray(v) end,
    });
    esp:AddToggle('EspRoleText', {
        Text = 'Role text', Default = true, Callback = function(v) get('RoleESP').role_text(v) end,
    });
    esp:AddToggle('EspNickname', {
        Text = 'Nickname', Default = true, Callback = function(v) get('RoleESP').nickname(v) end,
    });
    esp:AddToggle('EspDistance', {
        Text = 'Distance on label', Default = true, Callback = function(v) get('RoleESP').distance(v) end,
    });
    esp:AddDivider();
    esp:AddLabel('Film/X-Ray opacity is handled per-visual in the engine');

    -- Silent aim ------------------------------------------------------------
    local sa = Tabs.Combat:AddRightGroupbox('Silent Aim');
    sa:AddDropdown('SAimVersion', {
        Text = 'Aim version', Values = { 'v1 (part based)', 'v2 (humanoid based)' }, Default = 1,
        Callback = function(v) get('SilentAim').aim_version(v) end,
    });
    sa:AddDropdown('SAimType', {
        Text = 'Aimbot type', Values = { 'Nearest Part', 'Nearest Point', 'Head', 'Torso' }, Default = 1,
        Callback = function(v) get('SilentAim').aim_type(v) end,
    });
    sa:AddSlider('SAimFlickSpeed', {
        Text = 'Flick speed',
        Default = 100, Min = 0, Max = 500, Rounding = 0, Compact = true,
        Callback = function(v) get('SilentAim').flick_speed(v) end,
    });
    sa:AddSlider('SAimFlickReturn', {
        Text = 'Flick return',
        Default = 100, Min = 0, Max = 500, Rounding = 0, Compact = true,
        Callback = function(v) get('SilentAim').flick_return(v) end,
    });
    sa:AddSlider('SAimPrediction', {
        Text = 'Prediction (ms)',
        Default = 80, Min = 0, Max = 500, Rounding = 0, Compact = true,
        Callback = function(v) get('SilentAim').prediction_ms(v) end,
    });
    sa:AddToggle('SAimWallCheck', {
        Text = 'Wall check', Default = true, Callback = function(v) get('SilentAim').wall_check(v) end,
    });
    sa:AddToggle('SAimFOVCircle', {
        Text = 'FOV circle', Default = false, Callback = function(v) get('SilentAim').fov_circle(v) end,
    });
    sa:AddSlider('SAimFOV', {
        Text = 'FOV size',
        Default = 150, Min = 10, Max = 1000, Rounding = 0, Compact = true,
        Callback = function(v) get('SilentAim').fov(v) end,
    });

    -- Kill aura -------------------------------------------------------------
    local ka = Tabs.Combat:AddRightGroupbox('Kill Aura');
    ka:AddSlider('KaRadius', {
        Text = 'Radius (studs)',
        Default = 25, Min = 1, Max = 120, Rounding = 0, Compact = true,
        Callback = function(v) get('KillAura').radius(v) end,
    });
    ka:AddDropdown('KaMode', {
        Text = 'Target', Values = { 'Kill all', 'Sheriff only' }, Default = 1,
        Callback = function(v) get('KillAura').mode(v) end,
    });

    -- Auto shoot ------------------------------------------------------------
    local as = Tabs.Combat:AddLeftGroupbox('Auto Shoot');
    as:AddToggle('AsAutoPickup', {
        Text = 'Auto pickup gun', Default = false, Callback = function(v) get('AutoShoot').pickup(v) end,
    });
    as:AddToggle('AsAutoShoot', {
        Text = 'Auto shoot + auto kill murderer', Default = false, Callback = function(v) get('AutoShoot').auto_shoot(v) end,
    });
    as:AddToggle('AsAutoFling', {
        Text = 'Auto fling the sheriff', Default = false, Callback = function(v) get('AutoShoot').auto_fling(v) end,
    });
    as:AddKeyPicker('AsShootKey', {
        Default = 'MB1', SyncToggleState = false, Mode = 'Hold', Text = 'Shoot key',
        DoClick = function() get('AutoShoot').shoot_once() end,
        Callback = function(v) get('AutoShoot').shoot_key(v) end,
    });

    -- Knife throw -----------------------------------------------------------
    local kt = Tabs.Combat:AddLeftGroupbox('Knife Throw');
    kt:AddToggle('KtEnabled', {
        Text = 'Aimbot', Default = false, Callback = function(v) get('KnifeThrow').enabled(v) end,
    });
    kt:AddToggle('KtWallCheck', {
        Text = 'Wall check', Default = true, Callback = function(v) get('KnifeThrow').wall_check(v) end,
    });
    kt:AddSlider('KtLead', {
        Text = 'Prediction lead',
        Default = 40, Min = 0, Max = 300, Rounding = 0, Compact = true,
        Callback = function(v) get('KnifeThrow').lead(v) end,
    });

    -- Fake position ---------------------------------------------------------
    local fp = Tabs.Combat:AddLeftGroupbox('Fake Position');
    fp:AddToggle('FpEnabled', {
        Text = 'Desync', Default = false, Callback = function(v) get('FakePosition').enabled(v) end,
    });
    fp:AddDropdown('FpMode', {
        Text = 'Mode', Values = { 'Orbit', 'Random', 'Stay' }, Default = 1,
        Callback = function(v) get('FakePosition').mode(v) end,
    });
    fp:AddSlider('FpRadius', {
        Text = 'Radius',
        Default = 15, Min = 1, Max = 50, Rounding = 0, Compact = true,
        Callback = function(v) get('FakePosition').radius(v) end,
    });
    fp:AddSlider('FpSpeed', {
        Text = 'Speed',
        Default = 10, Min = 1, Max = 60, Rounding = 0, Compact = true,
        Callback = function(v) get('FakePosition').speed(v) end,
    });
    fp:AddToggle('FpFaceThreat', {
        Text = 'Face nearest threat', Default = false, Callback = function(v) get('FakePosition').face_threat(v) end,
    });
    fp:AddToggle('FpResolver', {
        Text = 'Resolver', Default = false, Callback = function(v) get('FakePosition').resolver(v) end,
    });
end

-- =========================================================================--
--  AUTO FARM
-- =========================================================================--
do
    local af = Tabs.AutoFarm:AddLeftGroupbox('Auto Farm');
    af:AddToggle('AfEnabled', {
        Text = 'Enabled', Default = false, Callback = function(v) get('AutoFarm').enabled(v) end,
    });
    af:AddDropdown('AfVersion', {
        Text = 'Farm version', Values = { 'Legacy', 'Fast' }, Default = 2,
        Callback = function(v) get('AutoFarm').version(v) end,
    });
    af:AddSlider('AfSpeed', {
        Text = 'Speed',
        Default = 10, Min = 1, Max = 50, Rounding = 0, Compact = true,
        Callback = function(v) get('AutoFarm').speed(v) end,
    });
    af:AddToggle('AfFullBagRespawn', {
        Text = 'Auto respawn on full bag', Default = true, Callback = function(v) get('AutoFarm').full_bag_respawn(v) end,
    });
    af:AddToggle('AfAvoidMurderer', {
        Text = 'Avoid the murderer', Default = true, Callback = function(v) get('AutoFarm').avoid_murderer(v) end,
    });
    af:AddToggle('AfFlingAfterRespawn', {
        Text = 'Auto fling after respawn', Default = false, Callback = function(v) get('AutoFarm').fling_after_respawn(v) end,
    });
end

-- =========================================================================--
--  TELEPORT
-- =========================================================================--
do
    local tp = Tabs.Teleport:AddLeftGroupbox('Teleport');
    tp:AddButton('Lobby', function() get('Teleport').to_role('Lobby') end);
    tp:AddButton('Murderer', function() get('Teleport').to_role('Murderer') end);
    tp:AddButton('Sheriff', function() get('Teleport').to_role('Sheriff') end);

    local fl = Tabs.Teleport:AddRightGroupbox('Per Player Fling');
    fl:AddDropdown('TpFlingTarget', {
        Text = 'Player',
        Values = (function()
            local out = {};
            for _, p in next, Players:GetPlayers() do table.insert(out, p.Name); end
            return out;
        end)(),
        Special = 'PlayerAdditions',
        AllowNull = true,
    });
    fl:AddButton('Fling target', function()
        get('FlingPlayers').fling(Options.TpFlingTarget.Value);
    end);
end

-- =========================================================================--
--  TROLL FUN / FREE ANIMS / FLING PLAYERS
-- =========================================================================--
do
    local tf = Tabs.TrollFun:AddLeftGroupbox('Troll Tools');
    tf:AddButton('Grab a toy list', function() get('TrollTools').refresh_toys() end);
    tf:AddDropdown('TfToy', {
        Text = 'Toy', Values = { '(refresh first)' }, AllowNull = true,
    });
    tf:AddButton('Use toy', function() get('TrollTools').use_toy(Options.TfToy.Value) end);
    tf:AddToggle('TfFakeKorblox', {
        Text = 'Fake Korblox', Default = false, Callback = function(v) get('TrollTools').fake_korblox(v) end,
    });
    tf:AddToggle('TfFakeHeadless', {
        Text = 'Fake Headless', Default = false, Callback = function(v) get('TrollTools').fake_headless(v) end,
    });
    tf:AddSlider('TfWalkSpeed', {
        Text = 'Walk speed',
        Default = 16, Min = 16, Max = 500, Rounding = 0, Compact = true,
        Callback = function(v) get('TrollTools').walk_speed(v) end,
    });
    tf:AddSlider('TfJumpPower', {
        Text = 'Jump power',
        Default = 50, Min = 50, Max = 400, Rounding = 0, Compact = true,
        Callback = function(v) get('TrollTools').jump_power(v) end,
    });
    tf:AddToggle('TfTouchFling', {
        Text = 'Touch fling', Default = false, Callback = function(v) get('TrollTools').touch_fling(v) end,
    });
    tf:AddToggle('TfClickFling', {
        Text = 'Click fling', Default = false, Callback = function(v) get('TrollTools').click_fling(v) end,
    });
    tf:AddToggle('TfOrbit', {
        Text = 'Orbit', Default = false, Callback = function(v) get('TrollTools').orbit(v) end,
    });
    tf:AddSlider('TfOrbitRadius', {
        Text = 'Orbit radius',
        Default = 8, Min = 1, Max = 30, Rounding = 0, Compact = true,
        Callback = function(v) get('TrollTools').orbit_radius(v) end,
    });
    tf:AddSlider('TfOrbitSpeed', {
        Text = 'Orbit speed',
        Default = 8, Min = 1, Max = 40, Rounding = 0, Compact = true,
        Callback = function(v) get('TrollTools').orbit_speed(v) end,
    });

    -- Round music ------------------------------------------------------------
    local rm = Tabs.TrollFun:AddRightGroupbox('Round Music');
    rm:AddToggle('RmEnabled', {
        Text = 'Auto play on round start', Default = false, Callback = function(v) get('RoundMusic').enabled(v) end,
    });
    rm:AddToggle('RmRandom', {
        Text = 'Random song', Default = true, Callback = function(v) get('RoundMusic').random(v) end,
    });
    rm:AddSlider('RmStartDelay', {
        Text = 'Start delay (s)',
        Default = 1, Min = 0, Max = 10, Rounding = 1, Compact = true,
        Callback = function(v) get('RoundMusic').start_delay(v) end,
    });
    rm:AddSlider('RmVolume', {
        Text = 'Local volume',
        Default = 50, Min = 0, Max = 100, Rounding = 0, Compact = true,
        Callback = function(v) get('RoundMusic').volume(v) end,
    });

    -- Free anims -------------------------------------------------------------
    local fa = Tabs.FreeAnims:AddLeftGroupbox('Animation Packs');
    fa:AddDropdown('FaPack', {
        Text = 'Pack',
        Values = { 'Women', 'Run', 'Zombie', 'Ninja', 'Elder', 'Pirate', 'Levitate', 'Rthro', 'Astronaut', 'Toy' },
        AllowNull = true,
        Callback = function(v) get('FreeAnims').pack(v) end,
    });
    fa:AddButton('Apply pack now', function() get('FreeAnims').apply() end);
    fa:AddToggle('FaAutoLoad', {
        Text = 'Auto load on respawn', Default = false, Callback = function(v) get('FreeAnims').auto_load(v) end,
    });
    fa:AddToggle('FaHoldMode', {
        Text = 'Hold mode (hold key = run anim)', Default = false, Callback = function(v) get('FreeAnims').hold(v) end,
    });
    fa:AddKeyPicker('FaHoldKey', {
        Default = 'Q', Mode = 'Hold', Text = 'Hold key',
        Callback = function(v) get('FreeAnims').hold_key(v) end,
    });

    local fa2 = Tabs.FreeAnims:AddRightGroupbox('Emotes');
    fa2:AddDropdown('FaEmote', {
        Text = 'Emote',
        Values = { 'Wave', 'Dance', 'Point', 'Cheer', 'Laugh', 'Salute', 'Sit', 'Zombie' },
        AllowNull = true,
        Callback = function(v) get('FreeAnims').emote(v) end,
    });
    fa2:AddSlider('FaEmoteSpeed', {
        Text = 'Emote speed',
        Default = 1, Min = 0.1, Max = 3, Rounding = 2, Compact = true,
        Callback = function(v) get('FreeAnims').emote_speed(v) end,
    });
    fa2:AddSlider('FaPackSpeed', {
        Text = 'Walk/run speed multiplier',
        Default = 1, Min = 0.1, Max = 3, Rounding = 2, Compact = true,
        Callback = function(v) get('FreeAnims').pack_speed(v) end,
    });

    -- Fling Players tab ------------------------------------------------------
    local flp = Tabs.FlingPlayers:AddLeftGroupbox('Player List');
    flp:AddDropdown('FpPlayer', {
        Text = 'Player',
        Values = (function()
            local out = {};
            for _, p in next, Players:GetPlayers() do table.insert(out, p.Name); end
            return out;
        end)(),
        Special = 'PlayerAdditions',
        AllowNull = true,
    });
    flp:AddToggle('FpAutoFling', {
        Text = 'Auto fling selected', Default = false, Callback = function(v) get('FlingPlayers').auto_fling(v, Options.FpPlayer.Value) end,
    });
    flp:AddButton('Fling once', function() get('FlingPlayers').fling(Options.FpPlayer.Value) end);
    flp:AddButton('Clear fling list', function() get('FlingPlayers').clear() end);
end

-- =========================================================================--
--  VISUALS
-- =========================================================================--
do
    local vs = Tabs.Visuals:AddLeftGroupbox('Graphics');
    vs:AddToggle('VsBloom', { Text = 'Bloom', Default = false, Callback = function(v) get('Visuals').bloom(v) end });
    vs:AddToggle('VsAtmosphere', { Text = 'Atmosphere', Default = false, Callback = function(v) get('Visuals').atmosphere(v) end });
    vs:AddToggle('VsSunRays', { Text = 'Sun rays', Default = false, Callback = function(v) get('Visuals').sun_rays(v) end });
    vs:AddToggle('VsBlur', { Text = 'Blur', Default = false, Callback = function(v) get('Visuals').blur(v) end });
    vs:AddToggle('VsDOF', { Text = 'Depth of field', Default = false, Callback = function(v) get('Visuals').dof(v) end });
    vs:AddToggle('VsGroundFog', { Text = 'Ground fog', Default = false, Callback = function(v) get('Visuals').ground_fog(v) end });
    vs:AddToggle('VsChams', { Text = 'Chams', Default = false, Callback = function(v) get('Visuals').chams(v) end });
    vs:AddToggle('VsBacktrack', { Text = 'Backtrack', Default = false, Callback = function(v) get('Visuals').backtrack(v) end });
    vs:AddToggle('VsWalkTrails', { Text = 'Walk trails', Default = false, Callback = function(v) get('Visuals').walk_trails(v) end });

    local lt = Tabs.Visuals:AddLeftGroupbox('Lighting Presets');
    lt:AddDropdown('LtPreset', {
        Text = 'Preset',
        Values = { 'Night', 'Realistic', 'Future', 'Studio', 'Desert', 'Clear' },
        Default = 'Clear',
        Callback = function(v) get('Lighting').preset(v) end,
    });
    lt:AddDivider();
    lt:AddSlider('LtBrightness', {
        Text = 'Brightness', Default = 2, Min = 0, Max = 10, Rounding = 1, Compact = true,
        Callback = function(v) get('Lighting').brightness(v) end,
    });
    lt:AddSlider('LtExposure', {
        Text = 'Exposure compensation', Default = 0, Min = -3, Max = 3, Rounding = 1, Compact = true,
        Callback = function(v) get('Lighting').exposure(v) end,
    });

    local opt = Tabs.Visuals:AddRightGroupbox('Optimizer');
    opt:AddToggle('OptTexture', { Text = 'Remove textures', Default = false, Callback = function(v) get('Optimizer').textures(v) end });
    opt:AddToggle('OptParticles', { Text = 'Remove particles', Default = false, Callback = function(v) get('Optimizer').particles(v) end });
    opt:AddToggle('OptShadows', { Text = 'Remove shadows', Default = false, Callback = function(v) get('Optimizer').shadows(v) end });
    opt:AddToggle('OptReflections', { Text = 'Remove reflections', Default = false, Callback = function(v) get('Optimizer').reflections(v) end });
    opt:AddToggle('OptLowQuality', { Text = 'Low quality mode', Default = false, Callback = function(v) get('Optimizer').low_quality(v) end });
    opt:AddToggle('OptFpsUnlock', {
        Text = 'FPS unlocker (9999)', Default = false, Callback = function(v) get('Optimizer').fps_unlock(v) end,
    });
end

-- =========================================================================--
--  SETTINGS
-- =========================================================================--
do
    local ms = Tabs.Settings:AddLeftGroupbox('Menu');
    ms:AddSlider('MenuSize', {
        Text = 'UI size scale',
        Default = 1, Min = 0.7, Max = 1.5, Rounding = 1, Suffix = 'x', Compact = true,
    });
    ms:AddToggle('MenuStretch', {
        Text = 'Screen stretch', Default = false,
        Callback = function(v) get('MenuExtend').stretch(v) end,
    });
    ms:AddSlider('MenuTextSize', {
        Text = 'Text size',
        Default = 16, Min = 10, Max = 26, Rounding = 0, Compact = true,
    });
    ms:AddDropdown('MenuFont', {
        Text = 'Font',
        Values = { 'Code', 'Monospace', 'Plex', 'Georgia', 'System' },
        Default = 1,
        Callback = function(v) get('MenuExtend').font(v) end,
    });
    ms:AddDropdown('MenuLanguage', {
        Text = 'Language', Values = { 'English' }, Default = 1,
        Callback = function(v) get('MenuExtend').language(v) end,
    });
    ms:AddKeyPicker('MenuToggleKey', {
        Default = 'RightControl', Mode = 'Toggle', Text = 'Toggle key',
        SyncToggleState = false,
    });

    local server = Tabs.Settings:AddRightGroupbox('Server');
    server:AddButton('Rejoin', function() get('ServerTools').rejoin() end);
    server:AddButton('Server hop', function() get('ServerTools').hop() end);
    server:AddButton('Join a small server', function() get('ServerTools').join_small() end);
    server:AddButton('Copy job id', function() get('ServerTools').copy_job_id() end);
    server:AddToggle('AntiAFK2', {
        Text = 'Anti AFK', Default = false, Callback = function(v) get('ServerTools').anti_afk(v) end,
    });

    -- Linoria housekeeping ---------------------------------------------------
    ThemeManager:SetLibrary(Library);
    SaveManager:SetLibrary(Library);
    SaveManager:IgnoreThemeSettings();
    SaveManager:SetIgnoreIndexes({ 'MenuToggleKey' });
    ThemeManager:SetFolder('MM2Hub');
    SaveManager:SetFolder('MM2Hub');
    SaveManager:BuildConfigSection(Tabs.Settings);
    ThemeManager:ApplyToTab(Tabs.Settings);
    SaveManager:LoadAutoloadConfig();
end

-- =========================================================================--
--  RIGHTCONTROL MINIMIZE + SERVICE LOOP
-- =========================================================================--
InputService.InputBegan:Connect(function(Input, processed)
    if processed then return end;
    if Input.KeyCode == Enum.KeyCode.RightControl then
        if Hub.Window then
            Hub.Window:Toggle();
        end
    end;
end);

local playerIdCache = {};
Players.PlayerAdded:Connect(function(p)
    if Hub.Wires.refresh_players then Hub.Wires.refresh_players(); end
end);
Players.PlayerRemoving:Connect(function(p)
    if Hub.Wires.refresh_players then Hub.Wires.refresh_players(); end
end);

function Hub:unload()
    for _, m in next, Hub.Modules do
        if type(m.destroy) == 'function' then pcall(m.destroy); end
    end;
    Library:Unload();
end

Library:Notify('MM2 Hub loaded — RightControl to minimize');

Hub.Library = Library;
return Hub;
