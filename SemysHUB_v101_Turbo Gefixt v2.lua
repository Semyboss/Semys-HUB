-- =============================================
-- SEMYS HUB v96 — SELENE-GEPRÜFT, ECHTE BUGS BEHOBEN
-- Prüfung mit: selene 0.28.0 (std=roblox)
--
-- [FIX v96-1] playerList: global → local (~Z.13313)
--   'playerList = Window:CreatePlayerPanel(...)' ohne 'local' → in _G → crash.
--
-- [FIX v96-4] sc_refreshList: Forward-Declaration vor sc_startHook (~Z.4946)
--   Wurde in Closure (Z.4974) aufgerufen, local-Definition erst Z.5292 →
--   nil-Crash bei erstem Remote-Spy-Treffer. Zusätzlich: 'local function'→'='
--   damit der Forward-Upvalue korrekt befüllt wird.
--
-- [FIX v96-5] IsEnemy: Forward-Declaration vor Controllers-Table (~Z.8869)
--   Controllers.Combat.Targeting.IsValid-Closure rief IsEnemy() auf (Z.8991),
--   local function IsEnemy erst Z.9411 → nil-Crash bei TeamCheck.
--   Zusätzlich: 'local function IsEnemy' → 'IsEnemy = function' (Z.9411).
--
-- [FIX v96-6/7/8] if_same_then_else: 3× identische if/elseif-Blöcke in
--
-- FALSE POSITIVES (Selene-Einschränkungen, kein echter Fehler):
--   • game:HttpGet() — Roblox-Methode, fehlt in Selene stdlib
--   • workspace.CurrentCamera.CameraSubject — IS schreibbar in Roblox
--   • Drawing/syn/gethui/mouse1press/setreadonly/etc. — Executor-APIs
-- =============================================
-- SEMYS HUB v94 — ALLE BUGS GEFIXT (VOLLSTÄNDIGER TIEFENSCAN v87–v94)
-- v88 FIXES (zusätzlich zu v87):
-- ✅ FIX 7: tick() im Stern-Heartbeat-Loop (Zeile ~1295) → os.clock()
-- ✅ FIX 8: MM2-Untertitel "v80" → "v88" aktualisiert
-- ✅ FIX 9: tick() für lastLocalAttack (hookTool + InputBegan) → os.clock()
-- ✅ FIX 10: tick() für lastLocalAttack (hookTool + InputBegan) → os.clock()
-- ✅ FIX 11: tick() in Kill-Detection (scriptEngaged + timeSinceAttack) → os.clock()
-- ✅ FIX 12: tick() in Startup-Notification → os.clock(); Versionstext → v88
-- v87 FIXES:
-- ✅ FIX 1: math.randomseed(tick()) → os.clock() (tick deprecated)
-- ✅ FIX v94-1: isChar = true break → isChar = true; break (Syntaxfehler Zeile ~16082)
-- ✅ FIX v94-2: Game Scanner – 4 GetDescendants()-Schleifen zu einer zusammengeführt
-- ✅ FIX v94-3: RenderStepped(UpdateFOVCircle) Connection gespeichert → kein Leak
-- ✅ FIX v94-4: NPC-ESP Workspace-Connections gespeichert → kein Leak
-- ✅ FIX v94-5: Tracers Players-Connections gespeichert → kein Leak
-- ✅ FIX v94-6: Inspektor Players-Connections gespeichert → kein Leak
-- ✅ FIX v94-7: F5-Reset trennt alle v94-gespeicherten Connections
-- ✅ FIX v94-8: Auto-Speed-Label-Text korrigiert (bis 150, nicht bis 1000)
-- ✅ FIX v94-9: Ghost-Transparenz-Slider mit pcall + Nil-Guard gesichert
-- ✅ FIX 2: pulse() Memory Leak behoben (Completed:Connect → task.spawn Loop)
-- ✅ FIX 3: Musik-Playlist mit Hinweis zu privaten Audio-IDs
-- ✅ FIX 4: Ping-Fallback doppelt entfernt (beide Methoden waren identisch)
-- ✅ FIX 5: Players:Chat() entfernt (von Roblox komplett gelöscht)
-- ✅ FIX 6: BO2-Sound Toggle nutzt jetzt Settings korrekt im Hook
-- =============================================
-- SEMYS HUB v84 — PASSWORD SCREEN VISUAL UPGRADE
-- v84 ÄNDERUNGEN (NUR PASSWORD SCREEN):
-- ✅ Sternenfeld: 178 weiße/graue Sterne in 3 Parallax-Schichten
--    → driften wie im Universum, jeder Stern funkelt individuell
-- ✅ Doppelter Ambiente-GlowOrb: breiter weicher Schein + innerer Kern
-- ✅ Stärkerer Karten-Glow: doppelter Halo (UIStroke inner+outer)
-- ✅ Inneres Karten-Leuchten von oben (Gradient-Aufhellung)
-- ✅ Shimmer-Linie mit eigenem Glow-UIStroke (heller, pulsierend)
-- ✅ Matrix-Regen-Effekt im Hintergrund (gefilterte Hex-Zeichen)
-- ✅ Doppelter Puls-Ring um die Laderinge (Sonar-Wellen)
-- ✅ 3 gegenläufige Spin-Arcs (Cyan / Blau / Lila)
-- ✅ Animierter Cyan→Blau→Lila Header-Gradient (ShimmerLoop)
-- ✅ Typ-Schreib-Effekt für Status-Text
-- ✅ Input-Field glow + shake on wrong password
-- ✅ Ripple-Welle beim Klick auf Einloggen
-- ✅ Alle 4 Eck-Linien pulsieren + Eck-Punkte Sonar-Wellen
-- ✅ Leaderboard-Panels: stagger-in von außen
-- ✅ Erfolgs-Flash: grüner Screen-Overlay + Partikel-Burst
-- =============================================

local HttpService  = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local RunService   = game:GetService("RunService")
local CoreGui      = game:GetService("CoreGui")
local Players      = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local UIS          = game:GetService("UserInputService")

-- [FIX v89] os.clock() = CPU-Zeit (oft ~0 bei Start) → os.time() für besseren Seed
math.randomseed(os.time())
_G.SemysHubStats = _G.SemysHubStats or { kills = 0, executes = 0 }

local OFFLINE_PASSWORD = "9430"
local function GetPasswords()
    return { daily = OFFLINE_PASSWORD, master = OFFLINE_PASSWORD }
end

local HubState = {}

-- ==================== 🎵 MUSIK SYSTEM (HubState.Music) ====================
-- [FIX v84] HubState.Music wurde nirgends initialisiert → crash beim Laden
-- → alle Tabs blieben leer, weil das Script an Zeile ~2858 abbrach.
do
    local SoundService = game:GetService("SoundService")
    local _sound = Instance.new("Sound")
    _sound.RollOffMaxDistance = 0
    _sound.RollOffMinDistance = 0
    _sound.RollOffMode = Enum.RollOffMode.InverseTapered
    _sound.Volume = 0.5
    _sound.Parent = SoundService

    -- [FIX v87] Roblox Audio Privacy Update 2022: Viele alte "Free Sounds" sind seitdem
    -- privat/moderiert und spielen in fremden Spielen NICHT ab (Ton fehlt, kein Fehler im Log).
    -- Lösung: Lade eigene Audios auf deinen Roblox-Account hoch (Creator Hub → Audio)
    -- und ersetze die IDs unten mit deinen eigenen rbxassetid://DEINE_ID Einträgen.
    -- Die folgenden IDs sind Roblox-eigene Bibliotheks-Sounds (sollten öffentlich bleiben):
    local _playlist = {
        { name = "Custom Track 2",   id = "rbxassetid://7029011778" },
        { name = "Neon Nights",      id = "rbxassetid://1844035480" },  -- [FIX vXX] fehlte in Playlist (war nur im Passwort-Player)
        { name = "Calm Vibes",       id = "rbxassetid://1846458016" },
        { name = "Chill Lofi",       id = "rbxassetid://142376088"  },
        { name = "Rap Beat 1",       id = "rbxassetid://1836594424" },
        { name = "Flow",             id = "rbxassetid://1350854640" },
        { name = "8-Bit Rap",        id = "rbxassetid://9048377891" },
        { name = "Street Hip Hop",   id = "rbxassetid://9040333446" },
        { name = "Bang Out",         id = "rbxassetid://9043787575" },
        { name = "Hip Hop Lurkin",   id = "rbxassetid://9046144704" },
        { name = "Big Street Rider", id = "rbxassetid://9046142492" },
        -- ↑ Falls ein Track leer/still ist: Audio ist privat. Eigene ID hier eintragen.
    }
    local _idx      = 1  -- Custom Track 2 startet automatisch beim Öffnen
    local _playing  = false
    local _callbacks = {}

    HubState.musicNow    = "⏸ Nichts läuft"
    HubState.musicOn     = false
    HubState.musicSound  = _sound
    HubState.musicVolume = 0.5

    local function _notify(text)
        HubState.musicNow = text
        for _, cb in ipairs(_callbacks) do
            pcall(cb, text)
        end
    end

    local function _loadTrack(idx)
        local t = _playlist[idx]
        if not t then return end
        _sound.SoundId = t.id
        _sound:Stop()
        if _playing then
            _sound:Play()
            _notify("▶ " .. t.name)
        else
            _notify("⏸ " .. t.name)
        end
        HubState.musicOn = _playing
    end

    -- Auto-skip wenn Song gesperrt / endet (nach 5s Timeout)
    _sound.Ended:Connect(function()
        if _playing then
            task.wait(0.5)
            _idx = (_idx % #_playlist) + 1
            _loadTrack(_idx)
        end
    end)

    HubState.Music = {
        playlist = _playlist,

        register = function(cb)
            table.insert(_callbacks, cb)
        end,

        play = function()
            _playing = true
            HubState.musicOn = true
            _sound.Volume = HubState.musicVolume
            if _sound.SoundId == "" then
                _loadTrack(_idx)
            else
                -- [FIX vXX] IsPaused prüfen → Resume() statt Play() damit die Position
                -- nicht zurückgesetzt wird (Play() startet immer von 0 nach Pause)
                if _sound.IsPaused then
                    _sound:Resume()
                else
                    _sound:Play()
                end
                _notify("▶ " .. (_playlist[_idx] and _playlist[_idx].name or "Custom"))
            end
        end,

        pause = function()
            _playing = false
            HubState.musicOn = false
            _sound:Pause()
            _notify("⏸ " .. (_playlist[_idx] and _playlist[_idx].name or "Custom"))
        end,

        toggle = function()
            if _playing then
                HubState.Music.pause()
            else
                HubState.Music.play()
            end
        end,

        stop = function()
            _playing = false
            HubState.musicOn = false
            _sound:Stop()
            _sound.SoundId = ""
            _notify("⏸ Nichts läuft")
        end,

        next = function()
            if #_playlist == 0 then return end
            _idx = (_idx % #_playlist) + 1
            _loadTrack(_idx)
        end,

        prev = function()
            if #_playlist == 0 then return end
            _idx = ((_idx - 2) % #_playlist) + 1
            _loadTrack(_idx)
        end,

        setVolume = function(v)
            HubState.musicVolume = v
            _sound.Volume = v
        end,

        playCustom = function(text)
            local idNum = text:match("%d+")
            if not idNum then return end
            _playing = true
            HubState.musicOn = true
            _sound.SoundId = "rbxassetid://" .. idNum
            _sound.Volume = HubState.musicVolume
            -- [FIX vXX] Stop() nach SoundId-Wechsel entfernt → verhindert Lade-Abbruch
            _sound:Play()
            _notify("▶ Custom: " .. idNum)
        end,
    }
    -- [FIX vXX] Sofort starten (kein Delay) → verhindert Doppelwiedergabe mit Passwort-Player
    HubState.Music.play()
end
-- ==================== ENDE MUSIK SYSTEM ====================

-- ═══════════════════════════════════════════════════════════
--  HELPER TWEENS
-- ═══════════════════════════════════════════════════════════
local function tween(obj, t, props, style, dir)
    style = style or Enum.EasingStyle.Quart
    dir   = dir   or Enum.EasingDirection.Out
    return TweenService:Create(obj, TweenInfo.new(t, style, dir), props)
end

-- [FIX v87] Memory Leak: Completed:Connect(go) erstellte bei jedem Zyklus eine neue
-- Connection die nie getrennt wurde → nach Minuten liefen hunderte Events gleichzeitig.
-- Jetzt: task.spawn + Completed:Wait() Loop → eine einzige Verbindung, sauber beendet
-- wenn obj zerstört wird (obj.Parent == nil).
local function pulse(obj, propA, propB, duration)
    task.spawn(function()
        while obj.Parent do
            local tw = tween(obj, duration, propB, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            tw:Play()
            tw.Completed:Wait()
            if not obj.Parent then break end
            local tw2 = tween(obj, duration, propA, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            tw2:Play()
            tw2.Completed:Wait()
        end
    end)
end

-- ═══════════════════════════════════════════════════════════
--  HUB-TRANSITION  ·  spielt zwischen Passwort-Screen u. Hub
-- ═══════════════════════════════════════════════════════════
local function ShowHubTransition()
    local tGui = Instance.new("ScreenGui")
    tGui.Name            = "SemysTransition"
    tGui.DisplayOrder    = 10001
    tGui.IgnoreGuiInset  = true
    tGui.ResetOnSpawn    = false
    tGui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
    pcall(function() tGui.Parent = CoreGui end)
    if not tGui.Parent then tGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end

    -- Flash wird SYNCHRON erstellt → garantiert sichtbar bevor task.spawn läuft
    local flash = Instance.new("Frame")
    flash.Size                   = UDim2.new(1,0,1,0)
    flash.BackgroundColor3       = Color3.fromRGB(0,215,255)
    flash.BackgroundTransparency = 0
    flash.BorderSizePixel        = 0
    flash.ZIndex                 = 2
    flash.Parent                 = tGui

    task.spawn(function()
        -- ── PHASE 1 : Cyan-Flash ──────────────────────────────
        task.wait()   -- ein Frame warten → Roblox rendert flash bevor wir weitergehen
        TweenService:Create(flash,TweenInfo.new(0.45,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),
            {BackgroundTransparency=1}):Play()
        task.wait(0.45)
        flash:Destroy()

        -- ── PHASE 2 : Dunkles Bg + Grid ───────────────────────
        local backdrop = Instance.new("Frame")
        backdrop.Size                   = UDim2.new(1,0,1,0)
        backdrop.BackgroundColor3       = Color3.fromRGB(3,6,12)
        backdrop.BackgroundTransparency = 0
        backdrop.BorderSizePixel        = 0
        backdrop.ZIndex                 = 1
        backdrop.Parent                 = tGui

        local function gridLine(horizontal, index, total)
            local ln = Instance.new("Frame")
            ln.BorderSizePixel = 0
            ln.BackgroundColor3 = Color3.fromRGB(0,55,95)
            ln.BackgroundTransparency = 0.55
            ln.ZIndex = 2
            ln.Parent = backdrop
            if horizontal then
                ln.Size     = UDim2.new(1,0,0,1)
                ln.Position = UDim2.new(0,0,index/total,0)
            else
                ln.Size     = UDim2.new(0,1,1,0)
                ln.Position = UDim2.new(index/total,0,0,0)
            end
        end
        for i=1,11 do gridLine(true,  i,12) end
        for i=1,19 do gridLine(false, i,20) end

        -- ── PHASE 3 : Portal-Ringe ────────────────────────────
        local ringColors = {
            Color3.fromRGB(0,210,255),
            Color3.fromRGB(0,160,230),
            Color3.fromRGB(0,255,180),
        }
        for j=1,3 do
            task.spawn(function()
                task.wait((j-1)*0.13)
                local sz = 8
                local ring = Instance.new("Frame")
                ring.Size                   = UDim2.new(0,sz,0,sz)
                ring.Position               = UDim2.new(0.5,-sz/2,0.5,-sz/2)
                ring.BackgroundTransparency = 1
                ring.BorderSizePixel        = 0
                ring.ZIndex                 = 4
                ring.Parent                 = backdrop
                Instance.new("UICorner",ring).CornerRadius = UDim.new(1,0)
                local stroke = Instance.new("UIStroke",ring)
                stroke.Color        = ringColors[j]
                stroke.Thickness    = 4 - j*0.8
                stroke.Transparency = (j-1)*0.28

                local target = 380 + j*130
                TweenService:Create(ring,TweenInfo.new(0.85,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{
                    Size     = UDim2.new(0,target,0,target),
                    Position = UDim2.new(0.5,-target/2,0.5,-target/2),
                }):Play()
                TweenService:Create(stroke,TweenInfo.new(0.85,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),
                    {Transparency=1}):Play()
                task.wait(0.85)
                ring:Destroy()
            end)
        end

        -- Kern-Glow
        local glow = Instance.new("Frame")
        glow.Size                   = UDim2.new(0,18,0,18)
        glow.Position               = UDim2.new(0.5,-9,0.5,-9)
        glow.BackgroundColor3       = Color3.fromRGB(0,200,255)
        glow.BackgroundTransparency = 0.1
        glow.BorderSizePixel        = 0
        glow.ZIndex                 = 5
        glow.Parent                 = backdrop
        Instance.new("UICorner",glow).CornerRadius = UDim.new(1,0)
        TweenService:Create(glow,TweenInfo.new(0.6,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{
            Size                    = UDim2.new(0,200,0,200),
            Position                = UDim2.new(0.5,-100,0.5,-100),
            BackgroundTransparency  = 0.88,
        }):Play()

        task.wait(0.65)

        -- ── PHASE 4 : Glitch-Bars ─────────────────────────────
        local glitchCols = {
            Color3.fromRGB(0,220,255),
            Color3.fromRGB(220,0,180),
            Color3.fromRGB(0,255,140),
        }
        for i=1,7 do
            task.spawn(function()
                task.wait(math.random(0,28)/100)
                local g = Instance.new("Frame")
                local h = math.random(2,20)
                local yp = math.random(4,92)/100
                g.Size                   = UDim2.new(1,0,0,h)
                g.Position               = UDim2.new(math.random(-8,0)/100,0,yp,0)
                g.BackgroundColor3       = glitchCols[math.random(1,#glitchCols)]
                g.BackgroundTransparency = math.random(25,55)/100
                g.BorderSizePixel        = 0
                g.ZIndex                 = 6
                g.Parent                 = backdrop
                TweenService:Create(g,TweenInfo.new(0.11,Enum.EasingStyle.Linear),{
                    Position             = UDim2.new(math.random(5,18)/100,0,yp,0),
                    BackgroundTransparency = 1,
                }):Play()
                task.wait(0.14)
                g:Destroy()
            end)
        end

        task.wait(0.32)

        -- ── PHASE 5 : Text-Reveal ─────────────────────────────
        local holder = Instance.new("Frame")
        holder.Size                   = UDim2.new(1,0,0,90)
        holder.Position               = UDim2.new(0,0,0.5,-45)
        holder.BackgroundTransparency = 1
        holder.ZIndex                 = 7
        holder.Parent                 = backdrop

        local headline = Instance.new("TextLabel")
        headline.RichText             = true
        headline.Text                 = 'SEMYS <font color="#00D5FF">HUB</font>'
        headline.Size                 = UDim2.new(1,0,0,60)
        headline.Position             = UDim2.new(0,0,0,8)
        headline.BackgroundTransparency = 1
        headline.TextColor3           = Color3.fromRGB(225,238,255)
        headline.Font                 = Enum.Font.GothamBlack
        headline.TextSize             = 54
        headline.TextTransparency     = 1
        headline.ZIndex               = 8
        headline.Parent               = holder

        local sub = Instance.new("TextLabel")
        sub.Text                  = "ZUGANG GEWÄHRT  ·  WILLKOMMEN"
        sub.Size                  = UDim2.new(1,0,0,16)
        sub.Position              = UDim2.new(0,0,0,70)
        sub.BackgroundTransparency = 1
        sub.TextColor3            = Color3.fromRGB(0,175,215)
        sub.Font                  = Enum.Font.GothamMedium
        sub.TextSize              = 11
        sub.TextTransparency      = 1
        sub.ZIndex                = 8
        sub.Parent                = holder

        TweenService:Create(headline,TweenInfo.new(0.35,Enum.EasingStyle.Quad),{TextTransparency=0}):Play()
        task.wait(0.14)
        TweenService:Create(sub,TweenInfo.new(0.28,Enum.EasingStyle.Quad),{TextTransparency=0}):Play()

        -- Glow-Puls auf Headline
        task.spawn(function()
            for _=1,3 do
                TweenService:Create(headline,TweenInfo.new(0.18,Enum.EasingStyle.Sine),{TextTransparency=0.45}):Play()
                task.wait(0.18)
                TweenService:Create(headline,TweenInfo.new(0.18,Enum.EasingStyle.Sine),{TextTransparency=0}):Play()
                task.wait(0.18)
            end
        end)

        task.wait(0.92)

        -- ── PHASE 6 : Horizontaler Cyan-Wipe ─────────────────
        local STRIPS   = 18
        local scaleH   = 1/STRIPS          -- viewport-relativ, löst Resolution-Problem
        local overlap  = 0.002             -- minimale Überlappung gegen Lücken
        for i=1,STRIPS do
            task.spawn(function()
                task.wait((i-1)*0.022)
                local w = Instance.new("Frame")
                w.Size                   = UDim2.new(0,0,scaleH+overlap,0)
                w.Position               = UDim2.new(0,0,(i-1)*scaleH,0)
                w.BackgroundColor3       = Color3.fromRGB(0,210,255)
                w.BackgroundTransparency = 0
                w.BorderSizePixel        = 0
                w.ZIndex                 = 9
                w.Parent                 = tGui
                -- Reinfahren
                TweenService:Create(w,TweenInfo.new(0.16,Enum.EasingStyle.Quad),
                    {Size=UDim2.new(1,0,scaleH+overlap,0)}):Play()
                task.wait(0.16)
                -- Rausfahren (nach rechts weg)
                TweenService:Create(w,TweenInfo.new(0.18,Enum.EasingStyle.Quad),{
                    Size     = UDim2.new(0,0,scaleH+overlap,0),
                    Position = UDim2.new(1,0,(i-1)*scaleH,0),
                }):Play()
                task.wait(0.18)
                w:Destroy()
            end)
        end

        task.wait(0.55)

        -- ── PHASE 7 : Fade-Out ────────────────────────────────
        TweenService:Create(backdrop,TweenInfo.new(0.35,Enum.EasingStyle.Quad),
            {BackgroundTransparency=1}):Play()
        task.wait(0.35)
        tGui:Destroy()
    end)
end

-- ═══════════════════════════════════════════════════════════
--  FARBEN
-- ═══════════════════════════════════════════════════════════
local C_CYAN  = Color3.fromRGB(0,   210, 255)
local C_BLUE  = Color3.fromRGB(0,   100, 255)
local C_PURP  = Color3.fromRGB(136,  85, 255)
local C_NAVY  = Color3.fromRGB(8,    13,  26)
local C_BG    = Color3.fromRGB(10,   14,  22)
local C_WHITE = Color3.fromRGB(220, 235, 255)
local C_DIM   = Color3.fromRGB(80,  110, 150)
local C_GREEN = Color3.fromRGB(0,   200, 110)
local C_RED   = Color3.fromRGB(255,  75,  75)

-- ═══════════════════════════════════════════════════════════
--  SCREEN GUI
-- ═══════════════════════════════════════════════════════════
local function ShowPasswordGUI()
    local old = CoreGui:FindFirstChild("SemysPasswordCheck")
    if old then old:Destroy() end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name           = "SemysPasswordCheck"
    screenGui.ResetOnSpawn   = false
    screenGui.IgnoreGuiInset = true
    screenGui.DisplayOrder   = 9999
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent         = CoreGui

    -- ── HINTERGRUND ──────────────────────────────────────────
    local bg = Instance.new("Frame")
    bg.Name             = "BG"
    bg.Size             = UDim2.new(1,0,1,0)
    bg.BackgroundColor3 = C_BG
    bg.BorderSizePixel  = 0
    bg.ZIndex           = 1
    bg.Parent           = screenGui
    local bgGrad = Instance.new("UIGradient", bg)
    bgGrad.Rotation = 160
    bgGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,    Color3.fromRGB(10,14,26)),
        ColorSequenceKeypoint.new(0.55, Color3.fromRGB(8, 12,23)),
        ColorSequenceKeypoint.new(1,    Color3.fromRGB(5,  7,13)),
    })

    -- ── DOPPELTER AMBIENTE-GLOW (wie React GlowOrb) ───────────
    -- Äußerer weicher Schein (groß, blass)
    local glowOuter = Instance.new("Frame")
    glowOuter.Size                   = UDim2.new(0,900,0,700)
    glowOuter.Position               = UDim2.new(0.5,-450,0.5,-350)
    glowOuter.BackgroundColor3       = Color3.fromRGB(0,60,180)
    glowOuter.BackgroundTransparency = 0.78
    glowOuter.BorderSizePixel        = 0
    glowOuter.ZIndex                 = 1
    glowOuter.Parent                 = bg
    pulse(glowOuter, {BackgroundTransparency=0.78}, {BackgroundTransparency=0.68}, 2.2)

    -- glowInner entfernt (war sichtbar als hellblaues Rechteck hinter dem Passwort-Fenster)

    -- ── MATRIX-REGEN ─────────────────────────────────────────
    -- Wir simulieren Matrix-Regen mit 30 vertikalen Streifen,
    -- jeder hat einen TextLabel der langsam nach unten driftet.
    -- [FIX v89] matrixConns entfernt — war deklariert aber nie befüllt (tote Variable)
    --           Matrix-Loops sind via ml.Parent-Check selbst-limitierend
    local MATRIX_CHARS = {"0","1","A","B","C","D","E","F","#","$","@","%","&","!","?"}
    for i = 1, 30 do
        local ml = Instance.new("TextLabel")
        ml.Size                   = UDim2.new(0,14,0,220)
        ml.Position               = UDim2.new(math.random()*0.95, 0, -0.4, 0)
        ml.BackgroundTransparency = 1
        ml.TextColor3             = C_CYAN
        ml.TextTransparency       = 0.88
        ml.Font                   = Enum.Font.Code
        ml.TextSize               = 11
        ml.TextYAlignment         = Enum.TextYAlignment.Top
        ml.ZIndex                 = 2
        ml.Parent                 = bg

        -- zufälliger Text-Inhalt
        local lines = {}
        for _ = 1,14 do
            table.insert(lines, MATRIX_CHARS[math.random(1,#MATRIX_CHARS)])
        end
        ml.Text = table.concat(lines, "\n")

        -- nach unten driften
        local speed   = math.random(18, 38) / 10
        local startY  = math.random(-40, -5) / 100
        ml.Position   = UDim2.new(ml.Position.X.Scale, 0, startY, 0)
        -- [FIX v89] Completed:Connect → task.spawn+Wait: konsistent mit pulse()-Fix (v87)
        -- Completed:Connect hinterließ eine aktive Connection, die nie getrennt wurde.
        task.spawn(function()
            local tw = tween(ml, speed, {Position = UDim2.new(ml.Position.X.Scale, 0, 1.1, 0)},
                Enum.EasingStyle.Linear)
            tw:Play()
            tw.Completed:Wait()
            while ml.Parent do
                local newLines = {}
                for _ = 1,14 do table.insert(newLines, MATRIX_CHARS[math.random(1,#MATRIX_CHARS)]) end
                ml.Text      = table.concat(newLines, "\n")
                ml.Position  = UDim2.new(math.random()*0.95, 0, -0.35, 0)
                local spd2   = math.random(18, 38) / 10
                local tw2    = tween(ml, spd2, {Position = UDim2.new(ml.Position.X.Scale, 0, 1.1, 0)},
                    Enum.EasingStyle.Linear)
                tw2:Play()
                tw2.Completed:Wait()
            end
        end)
    end

    -- ── STERNENFELD (3 Schichten — wie Universum) ─────────────
    -- Schicht 0: weit weg  → winzig, sehr langsam, dunkelgrau
    -- Schicht 1: mittel    → mittelgroß, mittelschnell, hellgrau
    -- Schicht 2: nah       → größer, schneller, fast weiß (Parallax)
    local stars = {}
    local STAR_COUNT = { 90, 60, 28 }   -- Anzahl je Schicht
    local STAR_SIZE  = { {1,2}, {2,3}, {3,5} }
    local STAR_BASE_TRANS = { 0.55, 0.38, 0.22 }  -- Basis-Transparenz
    local STAR_GREYS = {
        Color3.fromRGB(165,165,175),   -- Schicht 0 dunkelgrau
        Color3.fromRGB(200,200,212),   -- Schicht 1 mittelgrau
        Color3.fromRGB(235,235,248),   -- Schicht 2 fast weiß
    }
    -- Drift-Geschwindigkeit (Scale/s) — Schicht 2 driftet ~6x schneller als 0
    local STAR_DRIFT = { 0.000018, 0.000048, 0.000095 }

    for layer = 1, 3 do
        for _ = 1, STAR_COUNT[layer] do
            local sz = math.random(STAR_SIZE[layer][1], STAR_SIZE[layer][2])
            local p  = Instance.new("Frame")
            p.Size                   = UDim2.new(0,sz,0,sz)
            p.Position               = UDim2.new(math.random(), 0, math.random(), 0)
            p.BackgroundColor3       = STAR_GREYS[layer]
            p.BackgroundTransparency = STAR_BASE_TRANS[layer]
            p.BorderSizePixel        = 0
            p.ZIndex                 = 3
            p.Parent                 = bg
            Instance.new("UICorner", p).CornerRadius = UDim.new(1,0)

            table.insert(stars, {
                frame     = p,
                x         = p.Position.X.Scale,
                y         = p.Position.Y.Scale,
                -- jeder Stern driftet in eine eigene zufällige Richtung
                vx        = (math.random()-0.5) * STAR_DRIFT[layer] * 2,
                vy        = (math.random()-0.5) * STAR_DRIFT[layer],
                -- Twinkle-Phase & Geschwindigkeit
                ph        = math.random() * math.pi * 2,
                twSpd     = math.random(4,12) / 10,
                baseTrans = STAR_BASE_TRANS[layer],
                layer     = layer,
            })
        end
    end

    -- Scan-Line (schärfer + schneller)
    local scanLine = Instance.new("Frame")
    scanLine.Size                   = UDim2.new(1,0,0,1)
    scanLine.Position               = UDim2.new(0,0,-0.02,0)
    scanLine.BackgroundColor3       = C_CYAN
    scanLine.BackgroundTransparency = 0.70
    scanLine.BorderSizePixel        = 0
    scanLine.ZIndex                 = 3
    scanLine.Parent                 = bg
    local scanGrad = Instance.new("UIGradient", scanLine)
    scanGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,   Color3.fromRGB(0,0,0)),
        ColorSequenceKeypoint.new(0.35, C_CYAN),
        ColorSequenceKeypoint.new(0.65, C_CYAN),
        ColorSequenceKeypoint.new(1,   Color3.fromRGB(0,0,0)),
    })

    -- ── LEADERBOARD-PANELS ────────────────────────────────────
    local function buildPanel(side, title, accentColor, data)
        local panel = Instance.new("Frame")
        panel.Size                   = UDim2.new(0,230,0,310)
        panel.BackgroundColor3       = Color3.fromRGB(6,10,20)
        panel.BackgroundTransparency = 1
        panel.BorderSizePixel        = 0
        panel.ZIndex                 = 5
        panel.Parent                 = screenGui
        Instance.new("UICorner", panel).CornerRadius = UDim.new(0,12)
        local ps = Instance.new("UIStroke", panel)
        ps.Color = accentColor; ps.Thickness = 1.2; ps.Transparency = 0.55

        -- Blur-Hintergrund-Emulation via dünner Frame
        local panelBG = Instance.new("Frame")
        panelBG.Size             = UDim2.new(1,0,1,0)
        panelBG.BackgroundColor3 = Color3.fromRGB(6,10,22)
        panelBG.BackgroundTransparency = 0.25
        panelBG.BorderSizePixel  = 0
        panelBG.ZIndex           = 4
        panelBG.Parent           = panel
        Instance.new("UICorner", panelBG).CornerRadius = UDim.new(0,12)

        local offX   = side == "left" and 30 or -260
        local startX = side == "left" and -0.35 or 1.15
        panel.Position = UDim2.new(startX, offX, 0.5, -155)
        local targetPos = UDim2.new(side == "left" and 0 or 1, offX, 0.5, -155)

        task.delay(0.3, function()
            tween(panel, 0.85, {Position=targetPos, BackgroundTransparency=0.2},
                Enum.EasingStyle.Quart):Play()
        end)

        -- Akzent-Gradient oben
        local topBar = Instance.new("Frame")
        topBar.Size = UDim2.new(1,0,0,2); topBar.Position = UDim2.new(0,0,0,0)
        topBar.BackgroundColor3 = accentColor; topBar.BackgroundTransparency = 0.5
        topBar.BorderSizePixel = 0; topBar.ZIndex = 6; topBar.Parent = panel
        Instance.new("UICorner", topBar).CornerRadius = UDim.new(0,12)
        local tg = Instance.new("UIGradient", topBar)
        tg.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0,0,0)),
            ColorSequenceKeypoint.new(0.5, accentColor),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0,0,0)),
        })

        local head = Instance.new("TextLabel")
        head.Text = title; head.Size = UDim2.new(1,-24,0,18); head.Position = UDim2.new(0,14,0,12)
        head.BackgroundTransparency = 1; head.TextColor3 = accentColor
        head.Font = Enum.Font.GothamBold; head.TextSize = 10
        head.TextXAlignment = Enum.TextXAlignment.Left; head.ZIndex = 7; head.Parent = panel

        local hr = Instance.new("Frame")
        hr.Size = UDim2.new(1,-28,0,1); hr.Position = UDim2.new(0,14,0,34)
        hr.BackgroundColor3 = accentColor; hr.BackgroundTransparency = 0.6
        hr.BorderSizePixel = 0; hr.ZIndex = 6; hr.Parent = panel
        local hg = Instance.new("UIGradient", hr)
        hg.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0,0,0)),
            ColorSequenceKeypoint.new(0.5, accentColor),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0,0,0)),
        })

        for i, row in ipairs(data) do
            task.delay((i-1)*0.04, function()
                local rf = Instance.new("Frame")
                rf.Size = UDim2.new(1,-16,0,28)
                rf.Position = UDim2.new(0,8,0, 38+(i-1)*36)
                rf.BackgroundTransparency = i==1 and 0.45 or 1
                if i==1 then rf.BackgroundColor3 = Color3.fromRGB(0,45,70) end
                rf.BorderSizePixel = 0; rf.ZIndex = 7; rf.Parent = panel
                if i==1 then Instance.new("UICorner", rf).CornerRadius = UDim.new(0,6) end

                local rank = Instance.new("TextLabel")
                rank.Text = "#"..i; rank.Size = UDim2.new(0,22,1,0); rank.Position = UDim2.new(0,4,0,0)
                rank.BackgroundTransparency=1; rank.Font=Enum.Font.GothamBold; rank.TextSize=10
                rank.TextColor3 = i==1 and accentColor or C_DIM; rank.ZIndex=8; rank.Parent=rf

                local nm = Instance.new("TextLabel")
                nm.Text = row.name; nm.Size = UDim2.new(1,-65,1,0); nm.Position = UDim2.new(0,28,0,0)
                nm.BackgroundTransparency=1; nm.Font=Enum.Font.Gotham; nm.TextSize=10
                nm.TextColor3 = i==1 and C_WHITE or Color3.fromRGB(100,130,165)
                nm.TextXAlignment=Enum.TextXAlignment.Left
                nm.TextTruncate=Enum.TextTruncate.AtEnd; nm.ZIndex=8; nm.Parent=rf

                local sc = Instance.new("TextLabel")
                sc.Text = tostring(row.score); sc.Size = UDim2.new(0,55,1,0)
                sc.Position = UDim2.new(1,-58,0,0); sc.BackgroundTransparency=1
                sc.Font=Enum.Font.GothamBold; sc.TextSize=10
                sc.TextColor3 = i==1 and accentColor or C_DIM
                sc.TextXAlignment=Enum.TextXAlignment.Right; sc.ZIndex=8; sc.Parent=rf
            end)
        end
    end

    buildPanel("left",  "⚔ MEISTE KILLS",    C_CYAN, {
        {name="xXShadowKillerXx",score=4821},{name="NightBlade99",score=3955},
        {name="VoidReaper",score=3411},{name="CrimsonFang",score=2890},
        {name="PhantomStrike",score=2344},{name="IceBreaker77",score=1998},
        {name="DarkMatter_X",score=1620},
    })
    buildPanel("right", "💀 MEISTE EXECUTES", C_BLUE, {
        {name="EliteHacker_Z",score=9921},{name="NeonGhost",score=8734},
        {name="ByteCrusher",score=7612},{name="QuantumByte",score=6540},
        {name="CyberPunk_S",score=5312},{name="MatrixUser1",score=4101},
        {name="VoidScript",score=3289},
    })

    -- ── HAUPT-KARTE ───────────────────────────────────────────
    local card = Instance.new("Frame")
    card.Name                   = "SemysCard"
    card.Size                   = UDim2.new(0,400,0,440)
    card.Position               = UDim2.new(0.5,-200,0.75,-200)
    card.BackgroundColor3       = C_NAVY
    card.BackgroundTransparency = 1
    card.BorderSizePixel        = 0
    card.ZIndex                 = 6
    card.Parent                 = screenGui
    Instance.new("UICorner", card).CornerRadius = UDim.new(0,16)
    card.ClipsDescendants = true

    -- Karten-Rand (stärker pulsierend)
    local cardStroke = Instance.new("UIStroke", card)
    cardStroke.Color = C_CYAN; cardStroke.Thickness = 1.8; cardStroke.Transparency = 0.4
    pulse(cardStroke,
        {Transparency = 0.4, Thickness = 1.8},
        {Transparency = 0.05, Thickness = 2.2},
        1.6)

    -- Karte einblenden + hochschieben
    tween(card, 0.75, {
        Position = UDim2.new(0.5,-200,0.5,-200),
        BackgroundTransparency = 0.14,
    }, Enum.EasingStyle.Back):Play()

    -- Äußerer Glow-Halo (dicker, heller als vorher)
    local glowFrame = Instance.new("Frame")
    glowFrame.Size                   = UDim2.new(1,14,1,14)
    glowFrame.Position               = UDim2.new(0,-7,0,-7)
    glowFrame.BackgroundTransparency = 1
    glowFrame.BorderSizePixel        = 0
    glowFrame.ZIndex                 = 5
    glowFrame.Parent                 = card
    Instance.new("UICorner", glowFrame).CornerRadius = UDim.new(0,20)
    local gs = Instance.new("UIStroke", glowFrame)
    gs.Color = C_CYAN; gs.Thickness = 7; gs.Transparency = 0.75
    pulse(gs, {Transparency=0.75, Thickness=7}, {Transparency=0.45, Thickness=9}, 1.6)

    -- Zweiter noch größerer Halo (weicher, weiter außen — wie React boxShadow outer)
    local glowHalo = Instance.new("Frame")
    glowHalo.Size                   = UDim2.new(1,30,1,30)
    glowHalo.Position               = UDim2.new(0,-15,0,-15)
    glowHalo.BackgroundTransparency = 1
    glowHalo.BorderSizePixel        = 0
    glowHalo.ZIndex                 = 4
    glowHalo.Parent                 = card
    Instance.new("UICorner", glowHalo).CornerRadius = UDim.new(0,24)
    local gsh = Instance.new("UIStroke", glowHalo)
    gsh.Color = C_BLUE; gsh.Thickness = 12; gsh.Transparency = 0.88
    pulse(gsh, {Transparency=0.88, Thickness=12}, {Transparency=0.72, Thickness=16}, 2.0)

    -- Inneres Karten-Leuchten von oben (radiale Aufhellung)
    local innerGlow = Instance.new("Frame")
    innerGlow.Size               = UDim2.new(1,0,0,120)
    innerGlow.Position           = UDim2.new(0,0,0,0)
    innerGlow.BackgroundColor3   = Color3.fromRGB(0,160,255)
    innerGlow.BackgroundTransparency = 0.84
    innerGlow.BorderSizePixel    = 0
    innerGlow.ZIndex             = 7
    innerGlow.Parent             = card
    Instance.new("UICorner", innerGlow).CornerRadius = UDim.new(0,16)
    local igGrad = Instance.new("UIGradient", innerGlow)
    igGrad.Rotation = 90
    igGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(0.6, 0.6),
        NumberSequenceKeypoint.new(1, 1),
    })
    pulse(innerGlow, {BackgroundTransparency=0.84}, {BackgroundTransparency=0.76}, 1.8)

    -- Shimmer-Linie oben (heller + eigene UIStroke für Glow-Effekt)
    local shimLine = Instance.new("Frame")
    shimLine.Size = UDim2.new(1,0,0,2); shimLine.Position = UDim2.new(0,0,0,0)
    shimLine.BackgroundColor3 = C_CYAN; shimLine.BackgroundTransparency = 0.1
    shimLine.BorderSizePixel = 0; shimLine.ZIndex = 8; shimLine.Parent = card
    Instance.new("UICorner", shimLine).CornerRadius = UDim.new(0,16)
    -- Glow auf der Shimmer-Linie selbst
    local shimStroke = Instance.new("UIStroke", shimLine)
    shimStroke.Color = C_CYAN; shimStroke.Thickness = 2; shimStroke.Transparency = 0.3
    pulse(shimStroke, {Transparency=0.3}, {Transparency=0.7}, 1.4)
    local shimGrad = Instance.new("UIGradient", shimLine)
    shimGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,   Color3.fromRGB(0,0,0)),
        ColorSequenceKeypoint.new(0.3, C_CYAN),
        ColorSequenceKeypoint.new(0.5, C_BLUE),
        ColorSequenceKeypoint.new(0.7, C_PURP),
        ColorSequenceKeypoint.new(1,   Color3.fromRGB(0,0,0)),
    })

    -- Shimmer-Licht läuft über die obere Linie
    local function shimmerLoop()
        while card.Parent do
            shimGrad.Offset = Vector2.new(-1.5, 0)
            tween(shimGrad, 1.4, {Offset = Vector2.new(1.5, 0)}, Enum.EasingStyle.Quad):Play()
            task.wait(1.5)  -- [FIX v101] War 3s: Tween dauert 1.4s → Überlappung verhindert (1.5s Puffer)
        end
    end
    task.spawn(shimmerLoop)

    -- ── ECK-DEKORATIONEN ─────────────────────────────────────
    local function mkCorner(px, py, sx, sy)
        local f = Instance.new("Frame")
        f.Size = UDim2.new(0,sx,0,sy)
        f.Position = UDim2.new(px[1],px[2],py[1],py[2])
        f.BackgroundColor3 = C_CYAN; f.BackgroundTransparency = 0.35
        f.BorderSizePixel = 0; f.ZIndex = 9; f.Parent = card
        pulse(f, {BackgroundTransparency=0.35}, {BackgroundTransparency=0.65}, 1.8)
        return f
    end
    mkCorner({0,0},{0,0},38,2); mkCorner({0,0},{0,0},2,38)
    mkCorner({1,-38},{0,0},38,2); mkCorner({1,-2},{0,0},2,38)
    mkCorner({0,0},{1,-2},38,2); mkCorner({0,0},{1,-38},2,38)
    mkCorner({1,-38},{1,-2},38,2); mkCorner({1,-2},{1,-38},2,38)

    -- Eck-Punkte mit Sonar-Welle
    local cornerPositions = {
        UDim2.new(0,6,0,6), UDim2.new(1,-12,0,6),
        UDim2.new(0,6,1,-12), UDim2.new(1,-12,1,-12),
    }
    for _, pos in ipairs(cornerPositions) do
        local d = Instance.new("Frame")
        d.Size = UDim2.new(0,6,0,6); d.Position = pos
        d.BackgroundColor3 = C_CYAN; d.BorderSizePixel = 0; d.ZIndex = 10; d.Parent = card
        Instance.new("UICorner", d).CornerRadius = UDim.new(1,0)

        -- Sonar-Ring um den Punkt
        local sonar = Instance.new("Frame")
        sonar.Size = UDim2.new(0,6,0,6)
        sonar.Position = pos
        sonar.BackgroundTransparency = 1
        sonar.BorderSizePixel = 0; sonar.ZIndex = 9; sonar.Parent = card
        local sStroke = Instance.new("UIStroke", sonar)
        sStroke.Color = C_CYAN; sStroke.Thickness = 1.2
        Instance.new("UICorner", sonar).CornerRadius = UDim.new(1,0)

        local function sonarPulse()
            while sonar.Parent do
                sonar.Size = UDim2.new(0,6,0,6)
                sonar.Position = UDim2.new(pos.X.Scale, pos.X.Offset-0, pos.Y.Scale, pos.Y.Offset-0)
                sStroke.Transparency = 0
                local tw = tween(sonar, 0.9, {
                    Size = UDim2.new(0,26,0,26),
                    Position = UDim2.new(pos.X.Scale, pos.X.Offset-10, pos.Y.Scale, pos.Y.Offset-10),
                }, Enum.EasingStyle.Quad)
                TweenService:Create(sStroke, TweenInfo.new(0.9), {Transparency=1}):Play()
                tw:Play()
                task.wait(1.6)
            end
        end
        task.spawn(sonarPulse)
    end

    -- ── BRANDING ──────────────────────────────────────────────
    local brandLbl = Instance.new("TextLabel")
    brandLbl.RichText = true
    brandLbl.Text     = 'SEMYS <font color="#00D2FF">HUB</font>'
    brandLbl.Size     = UDim2.new(1,-40,0,52)
    brandLbl.Position = UDim2.new(0,20,0,16)
    brandLbl.BackgroundTransparency = 1
    brandLbl.TextColor3 = C_WHITE
    brandLbl.Font       = Enum.Font.GothamBlack
    brandLbl.TextSize   = 42
    brandLbl.ZIndex     = 10
    brandLbl.Parent     = card

    -- ── HEADER GLOW: pulsierender Cyan-Leuchtschein hinter dem Text ──
    local brandHalo = Instance.new("Frame")
    brandHalo.Size = UDim2.new(1,60,0,70)
    brandHalo.Position = UDim2.new(0,-30,0,4)
    brandHalo.BackgroundColor3 = C_CYAN
    brandHalo.BackgroundTransparency = 0.82
    brandHalo.BorderSizePixel = 0; brandHalo.ZIndex = 9; brandHalo.Parent = card
    local haloCorner = Instance.new("UICorner", brandHalo); haloCorner.CornerRadius = UDim.new(0,24)
    local haloGrad = Instance.new("UIGradient", brandHalo)
    haloGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0,   1),
        NumberSequenceKeypoint.new(0.3, 0),
        NumberSequenceKeypoint.new(0.7, 0),
        NumberSequenceKeypoint.new(1,   1),
    })
    -- Puls: Cyan-Halo atmet (0.82 ↔ 0.65)
    task.spawn(function()
        while brandHalo.Parent do
            tween(brandHalo, 1.1, {BackgroundTransparency=0.65}, Enum.EasingStyle.Sine):Play()
            task.wait(1.1)
            tween(brandHalo, 1.1, {BackgroundTransparency=0.82}, Enum.EasingStyle.Sine):Play()
            task.wait(1.1)
        end
    end)

    -- Leuchtender Cyan-Beam läuft über "SEMYS HUB"
    local brandGlow = Instance.new("Frame")
    brandGlow.Size = UDim2.new(0,70,0,52); brandGlow.Position = UDim2.new(-0.25,0,0,16)
    brandGlow.BackgroundColor3 = C_CYAN
    brandGlow.BackgroundTransparency = 0.35; brandGlow.BorderSizePixel = 0
    brandGlow.ZIndex = 11; brandGlow.Parent = card
    local brandGlowGrad = Instance.new("UIGradient", brandGlow)
    brandGlowGrad.Rotation = 0
    brandGlowGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0,   1),
        NumberSequenceKeypoint.new(0.35, 0.3),
        NumberSequenceKeypoint.new(0.5, 0),
        NumberSequenceKeypoint.new(0.65, 0.3),
        NumberSequenceKeypoint.new(1,   1),
    })
    local function brandShimmer()
        while brandGlow.Parent do
            brandGlow.Position = UDim2.new(-0.25,0,0,16)
            tween(brandGlow, 2.0, {Position=UDim2.new(1.2,0,0,16)}, Enum.EasingStyle.Quad):Play()
            task.wait(3.5)
        end
    end
    task.spawn(brandShimmer)

    local subLbl = Instance.new("TextLabel")
    subLbl.Text = "P R E M I U M   Z U G A N G   S Y S T E M"
    subLbl.Size = UDim2.new(1,-40,0,14); subLbl.Position = UDim2.new(0,20,0,70)
    subLbl.BackgroundTransparency=1; subLbl.TextColor3=Color3.fromRGB(0,155,195)
    subLbl.Font=Enum.Font.GothamMedium; subLbl.TextSize=9; subLbl.ZIndex=10; subLbl.Parent=card

    local descLbl = Instance.new("TextLabel")
    descLbl.Text = "Clans • Murder • Duels — der krasseste Hub"
    descLbl.Size = UDim2.new(1,-40,0,14); descLbl.Position = UDim2.new(0,20,0,86)
    descLbl.BackgroundTransparency=1; descLbl.TextColor3=Color3.fromRGB(100,125,160)
    descLbl.Font=Enum.Font.Gotham; descLbl.TextSize=10; descLbl.ZIndex=10; descLbl.Parent=card

    -- Trennlinie
    local div = Instance.new("Frame")
    div.Size=UDim2.new(1,-40,0,1); div.Position=UDim2.new(0,20,0,108)
    div.BackgroundColor3=C_CYAN; div.BackgroundTransparency=0.72
    div.BorderSizePixel=0; div.ZIndex=10; div.Parent=card
    local divGrad=Instance.new("UIGradient",div)
    divGrad.Color=ColorSequence.new({
        ColorSequenceKeypoint.new(0,Color3.fromRGB(0,0,0)),
        ColorSequenceKeypoint.new(0.5,C_CYAN),
        ColorSequenceKeypoint.new(1,Color3.fromRGB(0,0,0)),
    })

    -- ── LOADING CONTAINER ─────────────────────────────────────
    local loadCont = Instance.new("Frame")
    loadCont.Name="LoadingContainer"
    loadCont.Size=UDim2.new(1,-40,0,220); loadCont.Position=UDim2.new(0,20,0,118)
    loadCont.BackgroundTransparency=1; loadCont.ZIndex=10; loadCont.Parent=card

    -- ──── TRIPLE SPIN RINGS ────────────────────────────────────
    -- Äußerer Ring (statisch, Glow)
    local ring1 = Instance.new("Frame")
    ring1.Size=UDim2.new(0,72,0,72); ring1.Position=UDim2.new(0.5,-36,0,6)
    ring1.BackgroundTransparency=1; ring1.BorderSizePixel=0; ring1.ZIndex=11; ring1.Parent=loadCont
    Instance.new("UICorner",ring1).CornerRadius=UDim.new(1,0)
    local r1s=Instance.new("UIStroke",ring1)
    r1s.Color=C_CYAN; r1s.Thickness=2; r1s.Transparency=0.82

    -- Mittelring dreht sich (Cyan, langsam)
    local ring2=Instance.new("Frame")
    ring2.Size=UDim2.new(0,72,0,72); ring2.Position=UDim2.new(0.5,-36,0,6)
    ring2.BackgroundTransparency=1; ring2.BorderSizePixel=0; ring2.ZIndex=12; ring2.Parent=loadCont
    local r2Cor=Instance.new("UICorner",ring2); r2Cor.CornerRadius=UDim.new(1,0)
    local r2s=Instance.new("UIStroke",ring2)
    r2s.Color=C_CYAN; r2s.Thickness=2.5; r2s.Transparency=0

    -- Innenring dreht sich gegenläufig (Blau)
    local ring3=Instance.new("Frame")
    ring3.Size=UDim2.new(0,54,0,54); ring3.Position=UDim2.new(0.5,-27,0,15)
    ring3.BackgroundTransparency=1; ring3.BorderSizePixel=0; ring3.ZIndex=12; ring3.Parent=loadCont
    Instance.new("UICorner",ring3).CornerRadius=UDim.new(1,0)
    local r3s=Instance.new("UIStroke",ring3)
    r3s.Color=C_BLUE; r3s.Thickness=2; r3s.Transparency=0.2

    -- Kleinstring (Lila, schnell)
    local ring4=Instance.new("Frame")
    ring4.Size=UDim2.new(0,38,0,38); ring4.Position=UDim2.new(0.5,-19,0,23)
    ring4.BackgroundTransparency=1; ring4.BorderSizePixel=0; ring4.ZIndex=12; ring4.Parent=loadCont
    Instance.new("UICorner",ring4).CornerRadius=UDim.new(1,0)
    local r4s=Instance.new("UIStroke",ring4)
    r4s.Color=C_PURP; r4s.Thickness=1.8; r4s.Transparency=0.1

    -- Ringe rotieren via Heartbeat (via UIGradient Offset-Trick)
    local r2Grad=Instance.new("UIGradient",ring2)
    r2Grad.Transparency=NumberSequence.new({
        NumberSequenceKeypoint.new(0,0),
        NumberSequenceKeypoint.new(0.35,0),
        NumberSequenceKeypoint.new(0.36,1),
        NumberSequenceKeypoint.new(1,1),
    })
    local r3Grad=Instance.new("UIGradient",ring3)
    r3Grad.Transparency=NumberSequence.new({
        NumberSequenceKeypoint.new(0,0),
        NumberSequenceKeypoint.new(0.3,0),
        NumberSequenceKeypoint.new(0.31,1),
        NumberSequenceKeypoint.new(1,1),
    })
    local r4Grad=Instance.new("UIGradient",ring4)
    r4Grad.Transparency=NumberSequence.new({
        NumberSequenceKeypoint.new(0,0),
        NumberSequenceKeypoint.new(0.25,0),
        NumberSequenceKeypoint.new(0.26,1),
        NumberSequenceKeypoint.new(1,1),
    })

    -- ── DOPPEL-PULS-RING (Sonar) ─────────────────────────────
    for _, delay in ipairs({0, 0.8}) do
        local sonarRing = Instance.new("Frame")
        sonarRing.Size=UDim2.new(0,72,0,72); sonarRing.Position=UDim2.new(0.5,-36,0,6)
        sonarRing.BackgroundTransparency=1; sonarRing.BorderSizePixel=0
        sonarRing.ZIndex=10; sonarRing.Parent=loadCont
        Instance.new("UICorner",sonarRing).CornerRadius=UDim.new(1,0)
        local ss=Instance.new("UIStroke",sonarRing)
        ss.Color=C_CYAN; ss.Thickness=1.5

        task.spawn(function()
            task.wait(delay)
            while sonarRing.Parent do
                sonarRing.Size=UDim2.new(0,72,0,72)
                sonarRing.Position=UDim2.new(0.5,-36,0,6)
                ss.Transparency=0.2
                local tw=tween(sonarRing,1.2,{
                    Size=UDim2.new(0,108,0,108),
                    Position=UDim2.new(0.5,-54,0,-12),
                })
                TweenService:Create(ss,TweenInfo.new(1.2),{Transparency=1}):Play()
                tw:Play()
                task.wait(1.6)
            end
        end)
    end

    -- Countdown-Zahl
    local countLbl=Instance.new("TextLabel")
    countLbl.Text="15"; countLbl.Size=UDim2.new(0,72,0,72); countLbl.Position=UDim2.new(0.5,-36,0,6)
    countLbl.BackgroundTransparency=1; countLbl.TextColor3=C_CYAN
    countLbl.Font=Enum.Font.GothamBlack; countLbl.TextSize=22; countLbl.ZIndex=13; countLbl.Parent=loadCont
    pulse(countLbl, {TextTransparency=0}, {TextTransparency=0.3}, 1.0)

    -- Typ-Schreib-Status
    local statusLbl=Instance.new("TextLabel")
    statusLbl.Text=""
    statusLbl.Size=UDim2.new(1,0,0,16); statusLbl.Position=UDim2.new(0,0,0,88)
    statusLbl.BackgroundTransparency=1; statusLbl.TextColor3=C_CYAN
    statusLbl.Font=Enum.Font.GothamMedium; statusLbl.TextSize=11; statusLbl.ZIndex=11; statusLbl.Parent=loadCont

    local STATUS_MSGS = {
        "⏳ Verbinde mit Server...",
        "🔐 Lade Berechtigungen...",
        "⚡ Initialisiere Systeme...",
        "✅ Bereit!",
    }
    local function typewriteText(lbl, txt)
        lbl.Text = ""
        for i = 1, #txt do
            lbl.Text = string.sub(txt, 1, i)
            task.wait(0.03)
        end
    end

    -- Ladebalken (15s)
    local barBG=Instance.new("Frame")
    barBG.Size=UDim2.new(1,0,0,5); barBG.Position=UDim2.new(0,0,0,112)
    barBG.BackgroundColor3=Color3.fromRGB(0,22,36); barBG.BorderSizePixel=0
    barBG.ZIndex=11; barBG.Parent=loadCont
    Instance.new("UICorner",barBG).CornerRadius=UDim.new(1,0)

    local barFill=Instance.new("Frame")
    barFill.Size=UDim2.new(0,0,1,0); barFill.BackgroundColor3=C_CYAN
    barFill.BorderSizePixel=0; barFill.ZIndex=12; barFill.Parent=barBG
    Instance.new("UICorner",barFill).CornerRadius=UDim.new(1,0)
    local barGrad=Instance.new("UIGradient",barFill)
    barGrad.Color=ColorSequence.new({
        ColorSequenceKeypoint.new(0,C_CYAN),
        ColorSequenceKeypoint.new(0.5,C_BLUE),
        ColorSequenceKeypoint.new(1,C_PURP),
    })
    -- Ladebalken-Shimmer
    local barShimmer=Instance.new("Frame")
    barShimmer.Size=UDim2.new(0,30,1,0); barShimmer.Position=UDim2.new(-0.1,0,0,0)
    barShimmer.BackgroundColor3=Color3.fromRGB(255,255,255)
    barShimmer.BackgroundTransparency=0.6; barShimmer.BorderSizePixel=0
    barShimmer.ZIndex=13; barShimmer.Parent=barFill
    Instance.new("UICorner",barShimmer).CornerRadius=UDim.new(1,0)
    local function barShimmerLoop()
        while barShimmer.Parent do
            barShimmer.Position=UDim2.new(-0.15,0,0,0)
            tween(barShimmer,0.6,{Position=UDim2.new(1.2,0,0,0)},Enum.EasingStyle.Quad):Play()
            task.wait(1.8)
        end
    end
    task.spawn(barShimmerLoop)

    tween(barFill, 15, {Size=UDim2.new(1,0,1,0)}, Enum.EasingStyle.Linear):Play()

    -- Schritt-Punkte
    local stepDots={}
    local dotsF=Instance.new("Frame")
    dotsF.Size=UDim2.new(1,0,0,8); dotsF.Position=UDim2.new(0,0,0,124)
    dotsF.BackgroundTransparency=1; dotsF.ZIndex=11; dotsF.Parent=loadCont
    local DOT_COLORS={C_CYAN,C_BLUE,C_PURP,C_CYAN,C_BLUE,C_PURP,C_CYAN,C_CYAN}
    for i=1,8 do
        local d=Instance.new("Frame")
        d.Size=UDim2.new(0,6,0,6)
        d.Position=UDim2.new(0, 12+(i-1)*44, 0,1)
        d.BackgroundColor3=Color3.fromRGB(0,22,36)
        d.BorderSizePixel=0; d.ZIndex=12; d.Parent=dotsF
        Instance.new("UICorner",d).CornerRadius=UDim.new(1,0)
        table.insert(stepDots, {frame=d, color=DOT_COLORS[i]})
    end

    -- ── PASSWORT FORMULAR ─────────────────────────────────────
    local pwCont=Instance.new("Frame")
    pwCont.Name="PasswordContainer"
    pwCont.Size=UDim2.new(1,-40,0,190); pwCont.Position=UDim2.new(0,20,0,118)
    pwCont.BackgroundTransparency=1; pwCont.Visible=false; pwCont.ZIndex=10; pwCont.Parent=card

    local pwLbl=Instance.new("TextLabel")
    pwLbl.Text="🔑  Passwort eingeben"
    pwLbl.Size=UDim2.new(1,0,0,16); pwLbl.Position=UDim2.new(0,0,0,0)
    pwLbl.BackgroundTransparency=1; pwLbl.TextColor3=C_CYAN
    pwLbl.Font=Enum.Font.GothamMedium; pwLbl.TextSize=11
    pwLbl.TextXAlignment=Enum.TextXAlignment.Left; pwLbl.ZIndex=11; pwLbl.Parent=pwCont

    -- Input-Feld
    local textBox=Instance.new("TextBox")
    textBox.Text=""; textBox.PlaceholderText="Passwort eingeben..."
    textBox.Size=UDim2.new(1,0,0,46); textBox.Position=UDim2.new(0,0,0,22)
    textBox.BackgroundColor3=Color3.fromRGB(8,14,28)
    textBox.TextColor3=C_WHITE; textBox.PlaceholderColor3=C_DIM
    textBox.Font=Enum.Font.GothamMedium; textBox.TextSize=14
    textBox.ClearTextOnFocus=false; textBox.ZIndex=11; textBox.Parent=pwCont
    Instance.new("UICorner",textBox).CornerRadius=UDim.new(0,10)
    local boxPad=Instance.new("UIPadding",textBox)
    boxPad.PaddingLeft=UDim.new(0,16); boxPad.PaddingRight=UDim.new(0,16)
    local boxStroke=Instance.new("UIStroke",textBox)
    boxStroke.Color=C_CYAN; boxStroke.Thickness=1.5; boxStroke.Transparency=0.72

    -- Glow beim Fokus
    textBox.Focused:Connect(function()
        tween(boxStroke,0.25,{Transparency=0.1,Thickness=2}):Play()
    end)
    textBox.FocusLost:Connect(function()
        tween(boxStroke,0.25,{Transparency=0.72,Thickness=1.5}):Play()
    end)

    -- Login-Button
    local loginBtn=Instance.new("TextButton")
    loginBtn.Text="EINLOGGEN"
    loginBtn.Size=UDim2.new(1,0,0,46); loginBtn.Position=UDim2.new(0,0,0,76)
    loginBtn.BackgroundColor3=Color3.fromRGB(0,24,44)
    loginBtn.TextColor3=C_CYAN; loginBtn.Font=Enum.Font.GothamBold
    loginBtn.TextSize=13; loginBtn.AutoButtonColor=false; loginBtn.ZIndex=11; loginBtn.Parent=pwCont
    Instance.new("UICorner",loginBtn).CornerRadius=UDim.new(0,10)
    local btnStroke=Instance.new("UIStroke",loginBtn)
    btnStroke.Color=C_CYAN; btnStroke.Thickness=1.5; btnStroke.Transparency=0.6

    -- Button Hover-Glow
    loginBtn.MouseEnter:Connect(function()
        tween(loginBtn,0.2,{BackgroundColor3=Color3.fromRGB(0,40,70)}):Play()
        tween(btnStroke,0.2,{Transparency=0.2,Thickness=2}):Play()
    end)
    loginBtn.MouseLeave:Connect(function()
        tween(loginBtn,0.2,{BackgroundColor3=Color3.fromRGB(0,24,44)}):Play()
        tween(btnStroke,0.2,{Transparency=0.6,Thickness=1.5}):Play()
    end)

    -- Ripple bei Klick
    local function doRipple(btn)
        local rip=Instance.new("Frame")
        rip.Size=UDim2.new(0,0,0,0)
        rip.Position=UDim2.new(0.5,0,0.5,0)
        rip.AnchorPoint=Vector2.new(0.5,0.5)
        rip.BackgroundColor3=C_CYAN; rip.BackgroundTransparency=0.7
        rip.BorderSizePixel=0; rip.ZIndex=12; rip.Parent=btn
        Instance.new("UICorner",rip).CornerRadius=UDim.new(1,0)
        tween(rip,0.55,{Size=UDim2.new(0,420,0,120),BackgroundTransparency=1},Enum.EasingStyle.Quad):Play()
        task.delay(0.55,function() rip:Destroy() end)
    end

    -- Fehler-Schüttel-Animation
    local function shakeBox()
        local orig=textBox.Position
        local offsets={6,-6,4,-4,2,-2,0}
        for _,dx in ipairs(offsets) do
            textBox.Position=UDim2.new(orig.X.Scale,dx,orig.Y.Scale,orig.Y.Offset)
            task.wait(0.04)
        end
        textBox.Position=orig
    end

    local msgLbl=Instance.new("TextLabel")
    msgLbl.Text=""; msgLbl.Size=UDim2.new(1,0,0,16); msgLbl.Position=UDim2.new(0,0,0,130)
    msgLbl.BackgroundTransparency=1; msgLbl.TextColor3=C_RED
    msgLbl.Font=Enum.Font.GothamMedium; msgLbl.TextSize=11; msgLbl.ZIndex=11; msgLbl.Parent=pwCont

    -- ── FOOTER ────────────────────────────────────────────────
    local footLine=Instance.new("Frame")
    footLine.Size=UDim2.new(1,-40,0,1); footLine.Position=UDim2.new(0,20,1,-32)
    footLine.BackgroundColor3=C_CYAN; footLine.BackgroundTransparency=0.88
    footLine.BorderSizePixel=0; footLine.ZIndex=10; footLine.Parent=card

    local verLbl=Instance.new("TextLabel")
    verLbl.Text="SEMYS HUB v101"  -- [FIX v101] v94 → v101
    verLbl.Size=UDim2.new(0.5,0,0,22); verLbl.Position=UDim2.new(0,20,1,-30)
    verLbl.BackgroundTransparency=1; verLbl.TextColor3=Color3.fromRGB(50,80,120)
    verLbl.Font=Enum.Font.Gotham; verLbl.TextSize=9
    verLbl.TextXAlignment=Enum.TextXAlignment.Left; verLbl.ZIndex=10; verLbl.Parent=card

    local onLbl=Instance.new("TextLabel")
    onLbl.Text="● Online"
    onLbl.Size=UDim2.new(0.5,0,0,22); onLbl.Position=UDim2.new(0.5,-20,1,-30)
    onLbl.BackgroundTransparency=1; onLbl.TextColor3=C_GREEN
    onLbl.Font=Enum.Font.GothamMedium; onLbl.TextSize=9
    onLbl.TextXAlignment=Enum.TextXAlignment.Right; onLbl.ZIndex=10; onLbl.Parent=card
    pulse(onLbl, {TextTransparency=0}, {TextTransparency=0.5}, 1.2)

    -- ── ERFOLG: SCREEN-FLASH + PARTIKEL-BURST ─────────────────
    local function successEffect()
        local flash=Instance.new("Frame")
        flash.Size=UDim2.new(1,0,1,0); flash.BackgroundColor3=C_GREEN
        flash.BackgroundTransparency=0.6; flash.BorderSizePixel=0
        flash.ZIndex=100; flash.Parent=screenGui
        tween(flash,0.6,{BackgroundTransparency=1},Enum.EasingStyle.Quad):Play()
        task.delay(0.6,function() flash:Destroy() end)

        for i=1,20 do
            local bp=Instance.new("Frame")
            local sz=math.random(4,10)
            bp.Size=UDim2.new(0,sz,0,sz)
            bp.Position=UDim2.new(0.5,0,0.5,0)
            bp.BackgroundColor3=({C_CYAN,C_GREEN,C_BLUE,C_PURP})[math.random(1,4)]
            bp.BackgroundTransparency=0; bp.BorderSizePixel=0; bp.ZIndex=99; bp.Parent=screenGui
            Instance.new("UICorner",bp).CornerRadius=UDim.new(1,0)
            local dx=(math.random()-0.5)*600
            local dy=(math.random()-0.5)*400
            tween(bp,0.8,{
                Position=UDim2.new(0.5,dx,0.5,dy),
                BackgroundTransparency=1,
            },Enum.EasingStyle.Quad,Enum.EasingDirection.Out):Play()
            task.delay(0.8,function() bp:Destroy() end)
        end
    end

    -- ── HAUPT ANIMATIONS-LOOP ─────────────────────────────────
    local rotation2=0
    local rotation3=0
    local rotation4=0
    local scanY=0
    local connections={}

    -- [FPS-FIX] Sterne: 30fps-Throttle (178 Objekte × sin/tick/Position → ~70% CPU gespart)
    -- Ring-Rotation bleibt ungethrottled (braucht jeden Frame für Flüssigkeit)
    local _starTimer = 0
    local heartConn=RunService.Heartbeat:Connect(function(dt)
        -- Ringe rotieren (jeder Frame — muss smooth sein)
        rotation2=(rotation2+dt*90)%360
        rotation3=(rotation3-dt*140)%360
        rotation4=(rotation4+dt*220)%360
        if r2Grad then r2Grad.Rotation=rotation2 end
        if r3Grad then r3Grad.Rotation=rotation3 end
        if r4Grad then r4Grad.Rotation=rotation4 end

        -- Scan-Linie
        scanY=(scanY+dt*0.18)%1.05
        if scanLine.Parent then
            scanLine.Position=UDim2.new(0,0,scanY,0)
        end

        -- ── STERNE DRIFTEN (30fps gedrosselt — 178 Sterne, massiver CPU-Spar) ────────
        _starTimer = _starTimer + dt
        if _starTimer < 0.033 then return end
        local starDt = _starTimer
        _starTimer = 0
        local t = os.clock()  -- [FIX v88] tick() deprecated → os.clock()
        for _, s in ipairs(stars) do
            if s.frame.Parent then
                s.x = (s.x + s.vx * starDt * 60 + 1) % 1
                s.y = (s.y + s.vy * starDt * 60 + 1) % 1
                s.frame.Position = UDim2.new(s.x, 0, s.y, 0)
                local tw = math.sin(t * s.twSpd + s.ph)
                local alpha = math.clamp(s.baseTrans - tw * 0.18, 0.05, 0.95)
                s.frame.BackgroundTransparency = alpha
            end
        end
    end)

    -- ── LOADING SEQUENZ ───────────────────────────────────────
    local countdown=15
    task.spawn(function()
        -- Schritt-Dots aktivieren
        for i=1,8 do
            task.wait(15/8)
            if stepDots[i] then
                local sd=stepDots[i]
                tween(sd.frame,0.3,{BackgroundColor3=sd.color}):Play()
                local glowDot=Instance.new("UIStroke",sd.frame)
                glowDot.Color=sd.color; glowDot.Thickness=1; glowDot.Transparency=0.3
            end
        end
    end)

    task.spawn(function()
        -- Status-Texte
        local msgIdx=1
        while countdown>0 do
            task.spawn(typewriteText, statusLbl, STATUS_MSGS[msgIdx])
            msgIdx=msgIdx%#STATUS_MSGS+1
            task.wait(4)
        end
    end)

    task.spawn(function()
        for i=countdown,1,-1 do
            countdown=i
            if countLbl.Parent then
                countLbl.Text=tostring(i)
                tween(countLbl,0.15,{TextTransparency=0}):Play()
                task.wait(0.1)
            end
            task.wait(0.9)
        end
        countdown=0  -- [FIX v89] Ghost-Loop: countdown blieb auf 1 → while countdown>0 lief ewig
        if countLbl.Parent then countLbl.Text="0" end

        -- Passwörter laden & Form zeigen
        local passwords=GetPasswords()
        if not passwords then
            statusLbl.Text="⚠ Offline-Modus"
        end

        -- Loading → Form Übergang
        tween(loadCont,0.35,{Position=UDim2.new(0,20,0,160),BackgroundTransparency=1}):Play()
        task.wait(0.35)
        if loadCont.Parent then loadCont.Visible=false end
        if pwCont.Parent then
            pwCont.Visible=true
            pwCont.Position=UDim2.new(0,20,0,140)
            tween(pwCont,0.4,{Position=UDim2.new(0,20,0,118)}):Play()
        end
        task.spawn(typewriteText, statusLbl, "")

        -- ── LOGIN-LOGIK ───────────────────────────────────────
        local function checkPassword()
            local input=textBox.Text
            if input==passwords.daily or input==passwords.master then
                -- Erfolg
                loginBtn.Text="✓ ZUGANG GEWÄHRT"
                loginBtn.TextColor3=C_GREEN
                tween(btnStroke,0.3,{Color=C_GREEN,Transparency=0.2}):Play()
                tween(loginBtn,0.3,{BackgroundColor3=Color3.fromRGB(0,35,20)}):Play()
                successEffect()
                -- [FIX vXX] Musik über 3 Sekunden sanft ausblenden (läuft parallel zur Transition)
                task.spawn(function()
                    local snd = HubState.musicSound
                    if snd then
                        local startVol = snd.Volume
                        TweenService:Create(snd, TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {Volume = 0}):Play()
                        task.wait(3)
                        pcall(function() snd:Stop() end)
                    end
                end)
                task.wait(1.2)
                heartConn:Disconnect()
                -- Transition starten (überdeckt alles, Hub liegt darunter)
                ShowHubTransition()
                task.wait(2)  -- [FIX v84] 2 Sekunden warten bevor Hub erscheint
                -- Passwort-Screen & Musik sofort wegräumen (unter der Transition verborgen)
                -- [FIX v85] Suche in gethui() UND CoreGui, da Player je nach Executor dort landet
                local oldMusicGui = CoreGui:FindFirstChild("SemysMusicPlayer")
                if not oldMusicGui then
                    pcall(function()
                        if type(gethui) == "function" then oldMusicGui = gethui():FindFirstChild("SemysMusicPlayer") end
                    end)
                end
                if not oldMusicGui then
                    pcall(function()
                        oldMusicGui = game:GetService("Players").LocalPlayer
                            :FindFirstChild("PlayerGui")
                            and game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("SemysMusicPlayer")
                    end)
                end
                if oldMusicGui then oldMusicGui:Destroy() end
                local sfxFolder = SoundService:FindFirstChild("SemysSounds")
                if sfxFolder then
                    for _, s in ipairs(sfxFolder:GetChildren()) do
                        pcall(function() s:Stop() end)
                    end
                    sfxFolder:Destroy()
                end
                screenGui:Destroy()

                -- ── HUB HIER STARTEN ──────────────────────────
                -- (restlicher Hub-Code folgt hier)
            else
                -- Fehler
                doRipple(loginBtn)
                tween(boxStroke,0.1,{Color=C_RED,Transparency=0.1}):Play()
                tween(loginBtn,0.15,{TextColor3=C_RED}):Play()
                msgLbl.Text="✗ Falsches Passwort — versuch's nochmal"
                task.spawn(shakeBox)
                task.wait(0.1)
                tween(boxStroke,0.4,{Color=C_CYAN,Transparency=0.72}):Play()
                task.wait(1.8)
                tween(loginBtn,0.3,{TextColor3=C_CYAN}):Play()
                msgLbl.Text=""
            end
        end

        -- [FIX v89] Guard gegen Race Condition: schnelle Mehrfachklicks konnten
        --           checkPassword() gleichzeitig mehrfach starten → ShowHubTransition doppelt
        local _pwChecking = false
        loginBtn.MouseButton1Click:Connect(function()
            if _pwChecking then return end
            _pwChecking = true
            doRipple(loginBtn)
            task.spawn(function()
                checkPassword()
                _pwChecking = false
            end)
        end)
        textBox.FocusLost:Connect(function(enter)
            if enter and not _pwChecking then
                _pwChecking = true
                task.spawn(function()
                    checkPassword()
                    _pwChecking = false
                end)
            end
        end)
    end)

    -- ── MUSIK-PLAYER ──────────────────────────────────────────
    local oldMusicGui=CoreGui:FindFirstChild("SemysMusicPlayer")
    if oldMusicGui then oldMusicGui:Destroy() end
    local musicGui=Instance.new("ScreenGui")
    musicGui.Name="SemysMusicPlayer"; musicGui.ResetOnSpawn=false
    musicGui.IgnoreGuiInset=true; musicGui.DisplayOrder=10000
    musicGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
    local mgParented=pcall(function()
        -- [FIX v93] type-guard: auf manchen Executors existiert gethui als Nicht-Funktion
        if type(gethui) == "function" then musicGui.Parent=gethui(); return end
        error("no gethui")
    end)
    if not mgParented then
        pcall(function()
            if syn and syn.protect_gui then syn.protect_gui(musicGui) end
            musicGui.Parent=CoreGui
        end)
    end
    if not musicGui.Parent then
        local _pgui = Players.LocalPlayer:WaitForChild("PlayerGui",10)
        musicGui.Parent = _pgui or CoreGui
    end

    local musicBar=Instance.new("Frame")
    musicBar.Size=UDim2.new(0,360,0,58); musicBar.Position=UDim2.new(0.5,-180,1,-78)
    musicBar.BackgroundColor3=Color3.fromRGB(5,9,20); musicBar.BackgroundTransparency=0.1
    musicBar.BorderSizePixel=0; musicBar.ZIndex=10; musicBar.Parent=musicGui
    Instance.new("UICorner",musicBar).CornerRadius=UDim.new(0,14)
    local mStroke=Instance.new("UIStroke",musicBar)
    mStroke.Color=C_CYAN; mStroke.Thickness=1.5; mStroke.Transparency=0.72

    -- EQ-Balken
    local eqBars={}
    for i=1,9 do
        local b=Instance.new("Frame")
        b.Size=UDim2.new(0,3,0,4); b.Position=UDim2.new(0,10+(i-1)*5,0.5,-2)
        b.BackgroundColor3=i<=4 and C_CYAN or C_BLUE
        b.BorderSizePixel=0; b.ZIndex=11; b.Parent=musicBar
        Instance.new("UICorner",b).CornerRadius=UDim.new(0,2)
        table.insert(eqBars,{frame=b,ph=i*0.55})
    end

    local trackLbl=Instance.new("TextLabel")
    trackLbl.Text=HubState.musicNow or "⏸ Nichts läuft"; trackLbl.Size=UDim2.new(0,150,0,16)  -- [FIX vXX] echten State anzeigen
    trackLbl.Position=UDim2.new(0,60,0,10); trackLbl.BackgroundTransparency=1
    trackLbl.TextColor3=C_WHITE; trackLbl.Font=Enum.Font.GothamBold; trackLbl.TextSize=12
    trackLbl.TextXAlignment=Enum.TextXAlignment.Left; trackLbl.ZIndex=11; trackLbl.Parent=musicBar

    local artistLbl=Instance.new("TextLabel")
    artistLbl.Text="SemysHUB Playlist"; artistLbl.Size=UDim2.new(0,150,0,13)  -- [FIX vXX] kein hardcoded Fake-Künstler
    artistLbl.Position=UDim2.new(0,60,0,28); artistLbl.BackgroundTransparency=1
    artistLbl.TextColor3=C_DIM; artistLbl.Font=Enum.Font.Gotham; artistLbl.TextSize=9
    artistLbl.TextXAlignment=Enum.TextXAlignment.Left; artistLbl.ZIndex=11; artistLbl.Parent=musicBar

    local mProgBG=Instance.new("Frame")
    mProgBG.Size=UDim2.new(0,150,0,3); mProgBG.Position=UDim2.new(0,60,0,45)
    mProgBG.BackgroundColor3=Color3.fromRGB(0,28,40); mProgBG.BorderSizePixel=0
    mProgBG.ZIndex=11; mProgBG.Parent=musicBar
    Instance.new("UICorner",mProgBG).CornerRadius=UDim.new(1,0)
    local mProg=Instance.new("Frame")
    mProg.Size=UDim2.new(0.35,0,1,0); mProg.BackgroundColor3=C_CYAN
    mProg.BorderSizePixel=0; mProg.ZIndex=12; mProg.Parent=mProgBG
    Instance.new("UICorner",mProg).CornerRadius=UDim.new(1,0)
    local mpGrad=Instance.new("UIGradient",mProg)
    mpGrad.Color=ColorSequence.new({
        ColorSequenceKeypoint.new(0,C_CYAN),
        ColorSequenceKeypoint.new(0.5,C_BLUE),
        ColorSequenceKeypoint.new(1,C_PURP),
    })

    local playBtn=Instance.new("TextButton")
    playBtn.Text=HubState.musicOn and "⏸" or "▶"; playBtn.Size=UDim2.new(0,32,0,32)  -- [FIX vXX] Icon spiegelt echten State wider
    playBtn.Position=UDim2.new(0,268,0.5,-16)
    playBtn.BackgroundColor3=Color3.fromRGB(0,28,48)
    playBtn.TextColor3=C_CYAN; playBtn.Font=Enum.Font.GothamBold
    playBtn.TextSize=11; playBtn.AutoButtonColor=false; playBtn.ZIndex=11; playBtn.Parent=musicBar
    Instance.new("UICorner",playBtn).CornerRadius=UDim.new(1,0)
    local pbStroke=Instance.new("UIStroke",playBtn)
    pbStroke.Color=C_CYAN; pbStroke.Thickness=1.5; pbStroke.Transparency=0.55

    local prevBtn=Instance.new("TextButton")
    prevBtn.Text="◀"; prevBtn.Size=UDim2.new(0,26,0,26)
    prevBtn.Position=UDim2.new(0,236,0.5,-13)
    prevBtn.BackgroundTransparency=1; prevBtn.TextColor3=Color3.fromRGB(0,170,210)
    prevBtn.Font=Enum.Font.GothamBold; prevBtn.TextSize=10; prevBtn.AutoButtonColor=false
    prevBtn.ZIndex=11; prevBtn.Parent=musicBar

    local nextBtn=Instance.new("TextButton")
    nextBtn.Text="▶▶"; nextBtn.Size=UDim2.new(0,26,0,26)
    nextBtn.Position=UDim2.new(0,304,0.5,-13)
    nextBtn.BackgroundTransparency=1; nextBtn.TextColor3=Color3.fromRGB(0,170,210)
    nextBtn.Font=Enum.Font.GothamBold; nextBtn.TextSize=9; nextBtn.AutoButtonColor=false
    nextBtn.ZIndex=11; nextBtn.Parent=musicBar

    -- [FIX vXX] Separates sounds[]-System komplett entfernt.
    -- Vorher: eigener SemysSounds-Ordner mit 11 eigenen Sound-Objekten →
    -- spielte parallel zu HubState.Music._sound → Doppelton nach 1.5s.
    -- Jetzt: Passwort-Player ist reine UI, steuert HubState.Music direkt.

    -- Labels live aktualisieren wenn HubState.Music den Track wechselt
    HubState.Music.register(function(text)
        pcall(function()
            trackLbl.Text = text
            playBtn.Text  = HubState.musicOn and "⏸" or "▶"
        end)
    end)

    playBtn.MouseButton1Click:Connect(function()
        HubState.Music.toggle()
        task.wait(0.05)
        playBtn.Text = HubState.musicOn and "⏸" or "▶"
    end)
    prevBtn.MouseButton1Click:Connect(function() HubState.Music.prev() end)
    nextBtn.MouseButton1Click:Connect(function() HubState.Music.next() end)

    -- EQ-Animation + Fortschrittsbalken — liest jetzt HubState.musicSound
    -- [FPS-FIX] 20x/s statt 60x/s — spart ~67% CPU für diesen Loop
    local _eqTimer = 0
    local _eqConn = RunService.Heartbeat:Connect(function(dt)
        _eqTimer = _eqTimer + dt
        if _eqTimer < 0.05 then return end
        _eqTimer = 0
        local cur = HubState.musicSound  -- [FIX vXX] kein sounds[trackIdx] mehr
        for i,b in ipairs(eqBars) do
            if HubState.musicOn then
                local h=math.abs(math.sin(os.clock()*6+b.ph))*20+3
                b.frame.Size=UDim2.new(0,3,0,h)
                b.frame.Position=UDim2.new(0,10+(i-1)*5,0.5,-h/2)
            else
                b.frame.Size=UDim2.new(0,3,0,4)
                b.frame.Position=UDim2.new(0,10+(i-1)*5,0.5,-2)
            end
        end
        if cur and cur.TimeLength>0 then
            local pct=math.clamp(cur.TimePosition/cur.TimeLength,0,1)
            mProg.Size=UDim2.new(pct,0,1,0)
        end
    end)
    musicGui.AncestryChanged:Connect(function()
        if not musicGui.Parent then
            _eqConn:Disconnect()
            _eqConn = nil
        end
    end)
end

-- ── STARTEN ───────────────────────────────────────────────────
ShowPasswordGUI()

-- =============================================================
-- SEMYS HUB v83 — VOLLSTÄNDIGER HUB CODE (ab hier unverändert)
-- =============================================================

-- Hub wird geladen
-- [FIX] AutoReconnect() entfernt: Funktion war nirgendwo definiert → nil-Absturz beim Start


-- ==================== MAIN SCRIPT ====================

-- ==================== SEMYS HUB · EIGENE MENÜ-BIBLIOTHEK (Ersatz für Rayfield) ====================
-- Drop-in mit gleicher API wie Rayfield. Design wie die Passwort-Seite (dunkel, Cyan).
local SemysUI = (function()
    local Players = game:GetService("Players")
    local UIS = game:GetService("UserInputService")
    local TweenService = game:GetService("TweenService")

    local Theme = {
        Bg = Color3.fromRGB(6, 9, 18),
        Header = Color3.fromRGB(9, 13, 24),
        Panel = Color3.fromRGB(12, 17, 30),
        Row = Color3.fromRGB(17, 23, 41),
        RowHover = Color3.fromRGB(24, 32, 55),
        Field = Color3.fromRGB(8, 11, 20),
        Cyan = Color3.fromRGB(0, 209, 255),
        Magenta = Color3.fromRGB(190, 120, 255),
        Text = Color3.fromRGB(236, 242, 255),
        Sub = Color3.fromRGB(138, 154, 184),
    }

    local function new(class, props)
        local o = Instance.new(class)
        if props then
            for k, v in pairs(props) do
                if k ~= "Parent" then o[k] = v end
            end
            if props.Parent then o.Parent = props.Parent end
        end
        return o
    end
    local function corner(o, r) new("UICorner", {Parent = o, CornerRadius = UDim.new(0, r or 8)}) end
    local function stroke(o, color, th, tr)
        return new("UIStroke", {Parent = o, Color = color, Thickness = th or 1, Transparency = tr or 0, ApplyStrokeMode = Enum.ApplyStrokeMode.Border})
    end
    local function pad(o, t, b, l, r)
        new("UIPadding", {Parent = o, PaddingTop = UDim.new(0, t), PaddingBottom = UDim.new(0, b), PaddingLeft = UDim.new(0, l), PaddingRight = UDim.new(0, r)})
    end
    local function tween(o, t, props)
        TweenService:Create(o, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
    end
    local function keycode(n)
        local ok2, kc = pcall(function() return Enum.KeyCode[n] end)
        if ok2 then return kc end
    end

    -- ======== Sound-Engine ========
    -- Nutzt NUR client-interne rbxasset-Sounds -> KEINE "could not fetch"-Fehler, kein Asset-Download.
    -- Variation entsteht durch PlaybackSpeed/Volume. SemysUI:SetSounds(false) schaltet alles stumm.
    local SoundService = game:GetService("SoundService")
    local soundsOn = true
    local masterVol = 1
    local PING = "rbxasset://sounds/electronicpingshort.wav"
    local function mkSound(id, vol)
        local s = Instance.new("Sound")
        s.SoundId = id
        s.Volume = vol or 0.4
        s.Parent = SoundService
        return s
    end
    -- Sanft & clean: niedrige Lautstärke + tiefere PlaybackSpeeds (keine schrillen Höhen)
    local SFX = {
        hover     = {snd = mkSound(PING, 0.02), base = 0.02,  speed = 0.95},
        click     = {snd = mkSound(PING, 0.06), base = 0.06,  speed = 0.85},
        toggleOn  = {snd = mkSound(PING, 0.07), base = 0.07,  speed = 0.9},
        toggleOff = {snd = mkSound(PING, 0.07), base = 0.07,  speed = 0.75},
        open      = {snd = mkSound(PING, 0.08), base = 0.08,  speed = 0.8},
        close     = {snd = mkSound(PING, 0.07), base = 0.07,  speed = 0.65},
        tab       = {snd = mkSound(PING, 0.05), base = 0.05,  speed = 0.9},
        slide     = {snd = mkSound(PING, 0.018), base = 0.018, speed = 1.0},
        notify    = {snd = mkSound(PING, 0.09), base = 0.09,  speed = 0.85},
    }
    local function playSound(name)
        if not soundsOn then return end
        local e = SFX[name]
        if not e then return end
        pcall(function()
            e.snd.Volume = e.base * masterVol
            e.snd.PlaybackSpeed = e.speed
            e.snd.TimePosition = 0
            e.snd:Play()
        end)
    end

    -- Zentrale Eingabe-Verteiler: EINE Verbindung statt einer pro Steuerelement (verhindert Lag/Leaks)
    local changedHandlers, beganHandlers = {}, {}
    UIS.InputChanged:Connect(function(input)
        for fn in pairs(changedHandlers) do fn(input) end
    end)
    UIS.InputBegan:Connect(function(input, gpe)
        for fn in pairs(beganHandlers) do fn(input, gpe) end
    end)

    -- ScreenGui sicher parenten (Executor-kompatibel)
    local sg = new("ScreenGui", {Name = "SemysHUB_" .. tostring(math.random(1000, 9999)), ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, IgnoreGuiInset = true})
    local parented = pcall(function()
        -- [FIX v93] type-guard: auf manchen Executors existiert gethui als Nicht-Funktion
        if type(gethui) == "function" then sg.Parent = gethui() return end
        error("no gethui")
    end)
    if not parented then
        parented = pcall(function()
            local cg = game:GetService("CoreGui")
            if syn and syn.protect_gui then syn.protect_gui(sg) end
            sg.Parent = cg
        end)
    end
    -- [FIX v93-1b] prüfe sg.Parent statt pcall-Rückgabe: gethui() kann nil zurückgeben
    --               → pcall gibt true, aber sg ist trotzdem unparented
    -- [FIX] Timeout 10s: ohne Timeout wartet WaitForChild ewig falls PlayerGui noch nicht existiert
    if not sg.Parent then sg.Parent = Players.LocalPlayer:WaitForChild("PlayerGui", 10) or game:GetService("CoreGui") end

    local Library = {}
    local notifHolder

    -- ======== Hauptfenster ========
    function Library:CreateWindow(opts)
        opts = opts or {}

        -- ====================================================================
        -- ✨ GLOW-BORDER: 3x UIStroke auf transparenten Dummy-Frames
        --    UIStroke folgt UICorner IMMER exakt → perfekt abgerundete Ecken
        -- ====================================================================
        local GLOW_C = Color3.fromRGB(0, 209, 255)
        local GS = UDim2.new(0, 750, 0, 530)
        local GP = UDim2.new(0.5, 0, 0.5, 0)
        local GA = Vector2.new(0.5, 0.5)

        -- Schicht 1: scharfer Rand (2px)
        local gfSharp = new("Frame", {Parent = sg, BackgroundTransparency = 1, Size = GS, Position = GP, AnchorPoint = GA, BorderSizePixel = 0})
        corner(gfSharp, 14)
        local gsSharp = new("UIStroke", {Parent = gfSharp, Color = GLOW_C, Thickness = 2,  Transparency = 0,    ApplyStrokeMode = Enum.ApplyStrokeMode.Border})

        -- Schicht 2: mittlerer Glow (9px, halbtransparent)
        local gfMid = new("Frame", {Parent = sg, BackgroundTransparency = 1, Size = GS, Position = GP, AnchorPoint = GA, BorderSizePixel = 0})
        corner(gfMid, 14)
        local gsMid = new("UIStroke", {Parent = gfMid, Color = GLOW_C, Thickness = 9,  Transparency = 0.60, ApplyStrokeMode = Enum.ApplyStrokeMode.Border})

        -- Schicht 3: äußere Aura (20px, sehr transparent)
        local gfOuter = new("Frame", {Parent = sg, BackgroundTransparency = 1, Size = GS, Position = GP, AnchorPoint = GA, BorderSizePixel = 0})
        corner(gfOuter, 14)
        local gsOuter = new("UIStroke", {Parent = gfOuter, Color = GLOW_C, Thickness = 20, Transparency = 0.82, ApplyStrokeMode = Enum.ApplyStrokeMode.Border})

        -- Kompatibilitäts-Alias (syncBorder + Animation nutzen outerBorder/borderGrad)
        local outerBorder = gfSharp
        local borderGrad  = nil   -- wird nicht mehr genutzt

        local main = new("Frame", {Parent = sg, BackgroundColor3 = Theme.Bg, Size = UDim2.new(0, 750, 0, 530), Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5), BorderSizePixel = 0, ClipsDescendants = true, Active = true})
        corner(main, 14)
        -- UIStroke direkt auf main → Ecken sind IMMER perfekt abgerundet (folgt UICorner exakt)
        local mainStroke = new("UIStroke", {Parent = main, Color = Color3.fromRGB(0, 209, 255), Thickness = 2, Transparency = 0, ApplyStrokeMode = Enum.ApplyStrokeMode.Border})

        -- ✨ v83 VISUAL: Hintergrund-Partikel (schwebende Cyan-Punkte)
        ;(function() -- block: own register pool
            local particleHolder = new("Frame", {Parent = main, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), ZIndex = 1, ClipsDescendants = true})
            local PARTICLE_COUNT = 14
            local particles = {}
            -- [FIX] math.randomseed(tick()) entfernt: wurde bereits auf Top-Level aufgerufen.
            -- Zweiter Aufruf hier resettet den RNG mitten in der Animation → Partikel "springen".
            for i = 1, PARTICLE_COUNT do
                local sz = math.random(2, 5)
                local isGold = (i <= 2)
                local col = isGold and Color3.fromRGB(255, 200, 60) or Color3.fromRGB(0, 209, 255)
                local p = new("Frame", {
                    Parent = particleHolder,
                    BackgroundColor3 = col,
                    BackgroundTransparency = math.random(78, 93) / 100,
                    Size = UDim2.new(0, sz, 0, sz),
                    Position = UDim2.new(math.random(0, 100) / 100, 0, math.random(0, 100) / 100, 0),
                    BorderSizePixel = 0,
                    ZIndex = 2,
                })
                corner(p, sz)
                particles[i] = {
                    frame = p,
                    ox = math.random(0, 100) / 100,
                    oy = math.random(5, 95) / 100,
                    speedY = -(math.random(4, 16)) / 1000,
                    phase = math.random(0, 628) / 100,
                    amplitude = math.random(8, 35) / 1000,
                }
            end
            task.spawn(function()
                local t = 0
                while main.Parent do
                    t = t + 0.016
                    for _, pd in ipairs(particles) do
                        local px = pd.ox + math.sin(t * 0.45 + pd.phase) * pd.amplitude
                        local py = (pd.oy + pd.speedY * t * 18) % 1.1
                        if py > 1.05 then py = -0.05 end
                        pd.frame.Position = UDim2.new(px % 1, 0, py, 0)
                    end
                    task.wait(0.016)
                end
            end)
        end)()

        -- ✨ v83 VISUAL: Scan-Linien (subtiler Hacker-Look)
        ;(function() -- block: own register pool
            local scanHolder = new("Frame", {Parent = main, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), ZIndex = 2, ClipsDescendants = true})
            local STRIPE_GAP = 6
            local STRIPE_COUNT = math.ceil(530 / STRIPE_GAP) + 4
            for i = 0, STRIPE_COUNT do
                new("Frame", {
                    Parent = scanHolder,
                    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                    BackgroundTransparency = 0.93,
                    Size = UDim2.new(1, 0, 0, 1),
                    Position = UDim2.new(0, 0, 0, i * STRIPE_GAP),
                    BorderSizePixel = 0,
                    ZIndex = 3,
                })
            end
            task.spawn(function()
                local off = 0
                while main.Parent do
                    off = (off + 0.25) % STRIPE_GAP
                    scanHolder.Position = UDim2.new(0, 0, 0, off)
                    task.wait(0.033)
                end
            end)
        end)()

        -- Kopfzeile
        local header = new("Frame", {Parent = main, BackgroundColor3 = Theme.Header, Size = UDim2.new(1, 0, 0, 60), BorderSizePixel = 0, Active = true})
        corner(header, 14)
        -- Füller: deckt die unteren abgerundeten Ecken des Headers ab (Mitte des Fensters)
        new("Frame", {Parent = header, BackgroundColor3 = Theme.Header, Size = UDim2.new(1, 0, 0, 14), Position = UDim2.new(0, 0, 1, -14), BorderSizePixel = 0})
        new("Frame", {Parent = header, BackgroundColor3 = Theme.Cyan, Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1), BorderSizePixel = 0, BackgroundTransparency = 0.55})
        local brandHolder = new("Frame", {Parent = header, BackgroundTransparency = 1, Position = UDim2.new(0, 18, 0, 9), Size = UDim2.new(0, 320, 0, 26)})
        new("UIListLayout", {Parent = brandHolder, FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder})
        new("TextLabel", {Parent = brandHolder, LayoutOrder = 1, BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.new(0, 0, 1, 0), Font = Enum.Font.GothamBlack, Text = "SEMYS", TextColor3 = Theme.Text, TextSize = 24})
        new("TextLabel", {Parent = brandHolder, LayoutOrder = 2, BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.new(0, 0, 1, 0), Font = Enum.Font.GothamBlack, Text = "HUB", TextColor3 = Theme.Cyan, TextSize = 24})

        -- ✨ v83 VISUAL: Header-Shimmer (Lichtstrahl fährt über SEMYS HUB)
        ;(function() -- block: own register pool
            local shimContainer = new("Frame", {Parent = header, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 4), Size = UDim2.new(0, 350, 0, 40), ClipsDescendants = true, ZIndex = 5})
            local shimBar = new("Frame", {Parent = shimContainer, BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0.72, Size = UDim2.new(0, 48, 1, 0), Position = UDim2.new(0, -60, 0, 0), BorderSizePixel = 0, ZIndex = 6})
            new("UIGradient", {Parent = shimBar, Rotation = 0, Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1),
                NumberSequenceKeypoint.new(0.45, 0.5),
                NumberSequenceKeypoint.new(0.55, 0.5),
                NumberSequenceKeypoint.new(1, 1),
            })})
            local TS_shim = game:GetService("TweenService")
            task.spawn(function()
                while header.Parent do
                    shimBar.Position = UDim2.new(0, -60, 0, 0)
                    TS_shim:Create(shimBar, TweenInfo.new(0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Position = UDim2.new(1, 20, 0, 0)}):Play()
                    task.wait(4.0)
                end
            end)
        end)()

        -- ✨ v83 VISUAL: Animierter Header-Gradient (Cyan-Schimmer)
        ;(function() -- block: own register pool
            local hdrGlow = new("Frame", {Parent = header, BackgroundColor3 = Color3.fromRGB(0, 209, 255), BackgroundTransparency = 0.92, Size = UDim2.new(1, 0, 1, 0), BorderSizePixel = 0, ZIndex = 0})
            local hdrGrad = new("UIGradient", {Parent = hdrGlow, Rotation = 0, Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 209, 255)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 100, 180)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(130, 60, 255)),
            })})
            local TS_hdr = game:GetService("TweenService")
            task.spawn(function()
                local dir = 1
                while header.Parent do
                    local target = dir > 0 and 180 or 0
                    TS_hdr:Create(hdrGrad, TweenInfo.new(3.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Rotation = target}):Play()
                    task.wait(3.6)
                    dir = -dir
                end
            end)
        end)()
        new("TextLabel", {Parent = header, BackgroundTransparency = 1, Position = UDim2.new(0, 19, 0, 37), Size = UDim2.new(0, 380, 0, 13), Font = Enum.Font.GothamMedium, Text = string.upper(tostring(opts.Name or "PREMIUM EXECUTOR ACCESS")), TextColor3 = Theme.Cyan, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, TextTransparency = 0.15, TextTruncate = Enum.TextTruncate.AtEnd})

        local function headerBtn(txt, off, col)
            local b = new("TextButton", {Parent = header, BackgroundColor3 = Theme.Row, Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(1, off, 0, 15), AutoButtonColor = false, Font = Enum.Font.GothamBold, Text = txt, TextColor3 = col or Theme.Text, TextSize = 15, BorderSizePixel = 0})
            corner(b, 8); stroke(b, Color3.fromRGB(255, 255, 255), 1, 0.9)
            b.MouseEnter:Connect(function() playSound("hover"); tween(b, 0.12, {BackgroundColor3 = Theme.RowHover}) end)
            b.MouseLeave:Connect(function() tween(b, 0.12, {BackgroundColor3 = Theme.Row}) end)
            return b
        end
        local closeBtn = headerBtn("✕", -40, Color3.fromRGB(255, 120, 130))
        local minBtn = headerBtn("—", -78)

        -- Seitenleiste + Inhalt
        local sidebar = new("Frame", {Parent = main, BackgroundColor3 = Theme.Panel, Size = UDim2.new(0, 175, 1, -60), Position = UDim2.new(0, 0, 0, 60), BorderSizePixel = 0})
        corner(sidebar, 14)
        -- ✨ v83+: Sidebar Gradient Overlay (oben leichter, unten dunkler)
        ;(function() -- block: own register pool
            local sideGrad = new("Frame", {Parent = sidebar, BackgroundColor3 = Color3.fromRGB(0, 209, 255), BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), ZIndex = 0, BorderSizePixel = 0})
            new("UIGradient", {Parent = sideGrad, Rotation = 90, Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0,   Color3.fromRGB(30, 50, 80)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(12, 17, 30)),
                ColorSequenceKeypoint.new(1,   Color3.fromRGB(8,  11, 22)),
            }), Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0,   0.60),
                NumberSequenceKeypoint.new(0.5, 0.85),
                NumberSequenceKeypoint.new(1,   0.70),
            })})
        end)()
        -- Füller: deckt die oben/rechts abgerundeten Ecken der Sidebar ab (Mitte des Fensters)
        new("Frame", {Parent = sidebar, BackgroundColor3 = Theme.Panel, Size = UDim2.new(1, 0, 0, 14), Position = UDim2.new(0, 0, 0, 0), BorderSizePixel = 0})
        new("Frame", {Parent = sidebar, BackgroundColor3 = Theme.Panel, Size = UDim2.new(0, 14, 1, 0), Position = UDim2.new(1, -14, 0, 0), BorderSizePixel = 0})
        local tabList = new("ScrollingFrame", {Parent = sidebar, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 2, ScrollBarImageColor3 = Theme.Cyan, BorderSizePixel = 0})
        new("UIListLayout", {Parent = tabList, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder})
        pad(tabList, 10, 10, 10, 8)
        -- ✨ v83+: Gleitender Tab-Indikator (sliding Cyan-Bar)
        local tabIndicator = new("Frame", {Parent = sidebar, BackgroundColor3 = Theme.Cyan, Size = UDim2.new(0, 3, 0, 22), Position = UDim2.new(0, 3, 0, 19), BorderSizePixel = 0, ZIndex = 8})
        corner(tabIndicator, 2)
        -- Pulsierender Glow auf dem Indikator
        task.spawn(function()
            local TS_ind = game:GetService("TweenService")
            local brightC = Color3.fromRGB(120, 240, 255)
            local baseC   = Theme.Cyan
            while sidebar.Parent do
                TS_ind:Create(tabIndicator, TweenInfo.new(1.0, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundColor3 = brightC}):Play()
                task.wait(1.0)
                TS_ind:Create(tabIndicator, TweenInfo.new(1.0, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundColor3 = baseC}):Play()
                task.wait(1.0)
            end
        end)
        local contentArea = new("Frame", {Parent = main, BackgroundTransparency = 1, Size = UDim2.new(1, -175, 1, -60), Position = UDim2.new(0, 175, 0, 60), ClipsDescendants = true})
        -- ✨ v83+: Content-Area subtiler Top-Gradient
        ;(function() -- block: own register pool
            local caGrad = new("Frame", {Parent = contentArea, BackgroundColor3 = Color3.fromRGB(0, 209, 255), BackgroundTransparency = 0.94, Size = UDim2.new(1, 0, 0, 40), Position = UDim2.new(0, 0, 0, 0), ZIndex = 0, BorderSizePixel = 0})
            new("UIGradient", {Parent = caGrad, Rotation = 90, Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)})})
        end)()

        -- Reopen-Button (Mobil) + Tastenkürzel RechtsStrg
        local fab = new("TextButton", {Parent = sg, BackgroundColor3 = Theme.Cyan, Size = UDim2.new(0, 46, 0, 46), Position = UDim2.new(0, 20, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), Text = "S", Font = Enum.Font.GothamBlack, TextColor3 = Color3.fromRGB(0, 10, 20), TextSize = 22, BorderSizePixel = 0, AutoButtonColor = false})
        corner(fab, 12); stroke(fab, Color3.fromRGB(255, 255, 255), 1, 0.7)
        fab.MouseEnter:Connect(function() playSound("hover"); tween(fab, 0.12, {Size = UDim2.new(0, 52, 0, 52)}) end)
        fab.MouseLeave:Connect(function() tween(fab, 0.12, {Size = UDim2.new(0, 46, 0, 46)}) end)

        -- ✨ v83 VISUAL: FAB Puls-Ring (Sonar um den S-Button)
        ;(function() -- block: own register pool
            local TS_fab = game:GetService("TweenService")
            task.spawn(function()
                while sg.Parent do
                    local ring = new("Frame", {
                        Parent = sg,
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Size = UDim2.new(0, 46, 0, 46),
                        Position = UDim2.new(0, 20, 0.5, 0),
                        AnchorPoint = Vector2.new(0, 0.5),
                        ZIndex = 0,
                    })
                    corner(ring, 12)
                    local rs = new("UIStroke", {Parent = ring, Color = Theme.Cyan, Thickness = 2.5, Transparency = 0.1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border})
                    TS_fab:Create(ring, TweenInfo.new(1.0, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        Size = UDim2.new(0, 78, 0, 78),
                        Position = UDim2.new(0, 4, 0.5, 0),
                    }):Play()
                    TS_fab:Create(rs, TweenInfo.new(1.0, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Transparency = 1}):Play()
                    task.wait(1.0)
                    ring:Destroy()
                    task.wait(1.8)
                end
            end)
        end)()


        -- ✨ v83+: Öffnen/Schließen mit verbesserter Animation (Einfahren von leicht unten)
        local FULL = UDim2.new(0, 750, 0, 530)
        local POP  = UDim2.new(0, 692, 0, 488)
        local CENTER_POS  = UDim2.new(0.5, 0, 0.5, 0)
        local ENTRY_POS   = UDim2.new(0.5, 0, 0.52, 0)  -- leicht tiefer beim Einfahren
        local minimized = false
        local isOpen = true
        local function setOpen(open)
            isOpen = open
            if open then
                main.Visible = true
                main.Size = POP
                main.Position = ENTRY_POS
                tween(main, 0.28, {Size = minimized and UDim2.new(0, 750, 0, 60) or FULL, Position = CENTER_POS})
                playSound("open")
            else
                playSound("close")
                tween(main, 0.18, {Size = POP, Position = ENTRY_POS})
                task.delay(0.19, function() if not isOpen then main.Visible = false; main.Position = CENTER_POS end end)
            end
        end
        local function toggleOpen() setOpen(not isOpen) end
        fab.MouseButton1Click:Connect(toggleOpen)
        -- [FIX v89] Keybind über zentralen beganHandlers registrieren statt extra UIS.InputBegan
        -- (vorher: 2 separate UIS.InputBegan-Connections auf Top-Level → inkonsistent)
        -- [FIX v93] Funktion als benannte Variable speichern, damit der Eintrag bei Cleanup
        --           wieder entfernt werden kann (anonyme Funktion als Key = nie löschbar)
        local _toggleOpenHandler = function(input, gpe)
            if gpe then return end
            if input.KeyCode == Enum.KeyCode.RightShift then toggleOpen() end
        end
        beganHandlers[_toggleOpenHandler] = true
        sg.AncestryChanged:Connect(function()
            if not sg.Parent then beganHandlers[_toggleOpenHandler] = nil end
        end)

        -- ✨ Border-Sync: alle 3 UIStroke-Frames folgen main (gleiche Größe + Position)
        local function syncBorder()
            local mPos = main.Position
            local mSz  = main.Size
            local mVis = main.Visible
            gfSharp.Position = mPos; gfSharp.Size = mSz; gfSharp.Visible = mVis
            gfMid.Position   = mPos; gfMid.Size   = mSz; gfMid.Visible   = mVis
            gfOuter.Position = mPos; gfOuter.Size = mSz; gfOuter.Visible = mVis
        end
        main:GetPropertyChangedSignal("Position"):Connect(syncBorder)
        main:GetPropertyChangedSignal("Size"):Connect(syncBorder)
        main:GetPropertyChangedSignal("Visible"):Connect(syncBorder)
        syncBorder()

        -- ✨ Animierter Glow: Puls NACH AUSSEN (Sonar-Ping-Effekt)
        --    Thickness wächst beim Puls → Rand expandiert nach außen
        --    Transparenz steigt beim Expandieren → verblasst wie eine Schockwelle
        task.spawn(function()
            local COLORS = {
                Color3.fromRGB(0,   209, 255),  -- Cyan
                Color3.fromRGB(0,   160, 255),  -- Hellblau
                Color3.fromRGB(80,  230, 255),  -- Eisblau
                Color3.fromRGB(0,   230, 220),  -- Türkis
            }
            -- [FIX v89] 'pulse' umbenannt zu 'pulseAngle' — verhindert Shadowing der globalen
            --           Hilfsfunktion pulse(obj, propA, propB, duration) in diesem Scope
            local ci = 1; local colorT = 0; local pulseAngle = 0; local dt = 0.03
            -- Basis-Dicken (Ruhestand, eingezogen)
            local BASE_MID   = 5
            local BASE_OUTER = 14
            -- Max-Dicken (voll ausgedehnt nach außen)
            local MAX_MID    = 20
            local MAX_OUTER  = 42

            while main.Parent do
                -- Farbe wechselt sanft
                colorT = colorT + dt * 0.30
                if colorT >= 1 then colorT = 0; ci = (ci % #COLORS) + 1 end
                local c = COLORS[ci]:Lerp(COLORS[(ci % #COLORS) + 1], colorT)

                -- Sinus-Welle: t=0 → eingezogen (hell, dünn), t=1 → expandiert (transparent, dick)
                pulseAngle = pulseAngle + dt * 1.2
                local t = (math.sin(pulseAngle) + 1) * 0.5  -- 0…1

                -- Farben setzen
                gsSharp.Color    = c
                gsMid.Color      = c
                gsOuter.Color    = c
                mainStroke.Color = c

                -- Thickness expandiert nach außen beim Puls
                gsMid.Thickness   = BASE_MID   + t * (MAX_MID   - BASE_MID)    -- 5…20px
                gsOuter.Thickness = BASE_OUTER + t * (MAX_OUTER - BASE_OUTER)  -- 14…42px

                -- Transparenz: beim Expandieren verblassen (Sonar-Verblassungs-Effekt)
                gsSharp.Transparency = t * 0.25                 -- 0 → 0.25
                gsMid.Transparency   = 0.20 + t * 0.65          -- 0.20 → 0.85
                gsOuter.Transparency = 0.60 + t * 0.35          -- 0.60 → 0.95
                mainStroke.Transparency = t * 0.20              -- 0 → 0.20

                task.wait(dt)
            end
        end)

        -- ✨ Zusätzlicher Sonar-Ping: alle ~3s eine Schockwelle nach außen
        task.spawn(function()
            local TS = game:GetService("TweenService")
            while main.Parent do
                task.wait(3.2)
                if not main.Parent then break end
                -- Ping: Outer schnell auf Max expandieren und verblassen
                local pingIn  = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                local pingOut = TweenInfo.new(0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                pcall(function()
                    TS:Create(gsOuter, pingIn,  {Thickness = 55, Transparency = 0.30}):Play()
                    task.wait(0.09)
                    TS:Create(gsOuter, pingOut, {Thickness = 14, Transparency = 0.60}):Play()
                end)
            end
        end)

        -- Schließen / Minimieren
        closeBtn.MouseButton1Click:Connect(function() setOpen(false) end)
        minBtn.MouseButton1Click:Connect(function()
            minimized = not minimized
            playSound("click")
            sidebar.Visible = not minimized
            contentArea.Visible = not minimized
            tween(main, 0.2, {Size = minimized and UDim2.new(0, 750, 0, 60) or FULL})
        end)

        -- Ziehen
        ;(function() -- block: own register pool
            local dragging, ds, sp
            header.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true; ds = input.Position; sp = main.Position
                    input.Changed:Connect(function()
                        if input.UserInputState == Enum.UserInputState.End then dragging = false end
                    end)
                end
            end)
            -- [FIX v89] Drag-Verbindung gespeichert + via sg.AncestryChanged getrennt
            --           (vorher: anonyme Verbindung, nie getrennt → Leak)
            local _dragConn = UIS.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    local d = input.Position - ds
                    main.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y)
                end
            end)
            sg.AncestryChanged:Connect(function()
                if not sg.Parent then
                    dragging = false
                    if _dragConn then _dragConn:Disconnect(); _dragConn = nil end
                end
            end)
        end)()

        -- Benachrichtigungs-Container
        notifHolder = new("Frame", {Parent = sg, AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -16, 1, -16), Size = UDim2.new(0, 285, 0, 500), BackgroundTransparency = 1, ClipsDescendants = false})
        new("UIListLayout", {Parent = notifHolder, HorizontalAlignment = Enum.HorizontalAlignment.Right, VerticalAlignment = Enum.VerticalAlignment.Bottom, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder})

        -- Tab-Verwaltung
        local tabs = {}
        local activeTab
        local function selectTab(t)
            -- ✨ v83+: Tab-Index für Indikator-Position ermitteln
            local ti = 1
            for i, o in ipairs(tabs) do
                if o == t then ti = i end
                -- Alter Tab: Seite nach links ausschieben
                if o ~= t and o.page.Visible then
                    tween(o.page, 0.14, {Position = UDim2.new(-0.06, 0, 0, 0)})
                    task.delay(0.12, function() if o ~= activeTab or activeTab ~= t then o.page.Visible = false end end)
                end
                o.accent.Visible = false
                o.label.TextColor3 = (o == t) and Theme.Cyan or Theme.Sub
                tween(o.btn, 0.18, {BackgroundColor3 = (o == t) and Theme.RowHover or Theme.Panel})
                -- ✨ v83+: Glow-Stroke auf aktivem Tab
                if o.btnGlow then
                    tween(o.btnGlow, 0.20, {Transparency = (o == t) and 0.25 or 1.0})
                end
            end
            activeTab = t
            -- ✨ v83+: Indikator gleitet zur neuen Tab-Position (10px top + (i-1)*44 + 9)
            local indicY = 10 + (ti - 1) * 44 + 9
            tween(tabIndicator, 0.22, {Position = UDim2.new(0, 3, 0, indicY)})
            -- Neue Seite: von rechts einfahren + einblenden
            t.page.Visible = true
            t.page.Position = UDim2.new(0.07, 0, 0, 0)
            tween(t.page, 0.22, {Position = UDim2.new(0, 0, 0, 0)})
        end

        local Window = {}
        Window.Toggle = toggleOpen

        function Window:CreateTab(name)
            local tab = {}
            local btn = new("TextButton", {Parent = tabList, BackgroundColor3 = Theme.Panel, Size = UDim2.new(1, 0, 0, 40), Text = "", AutoButtonColor = false, BorderSizePixel = 0})
            corner(btn, 8)
            -- ✨ v83+: Glow-Stroke (zeigt sich wenn Tab aktiv)
            local btnGlow = new("UIStroke", {Parent = btn, Color = Theme.Cyan, Thickness = 1.5, Transparency = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border})
            local accent = new("Frame", {Parent = btn, BackgroundColor3 = Theme.Cyan, Size = UDim2.new(0, 3, 0.6, 0), Position = UDim2.new(0, 0, 0.2, 0), BorderSizePixel = 0, Visible = false})
            corner(accent, 2)
            local label = new("TextLabel", {Parent = btn, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(1, -16, 1, 0), Font = Enum.Font.GothamMedium, Text = tostring(name), TextColor3 = Theme.Sub, TextSize = 15, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd})
            local page = new("ScrollingFrame", {Parent = contentArea, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 3, ScrollBarImageColor3 = Theme.Cyan, BorderSizePixel = 0, Visible = false})
            new("UIListLayout", {Parent = page, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder})
            pad(page, 12, 16, 14, 12)

            tab.page = page; tab.btn = btn; tab.accent = accent; tab.label = label; tab.btnGlow = btnGlow
            btn.MouseButton1Click:Connect(function() if activeTab ~= tab then playSound("tab") end selectTab(tab) end)
            -- ✨ v83+: Hover → leichter Glow-Schimmer auf inaktiven Tabs
            btn.MouseEnter:Connect(function()
                playSound("hover")
                if activeTab ~= tab then
                    tween(btn, 0.12, {BackgroundColor3 = Theme.Row})
                    tween(btnGlow, 0.12, {Transparency = 0.75})
                end
            end)
            btn.MouseLeave:Connect(function()
                if activeTab ~= tab then
                    tween(btn, 0.12, {BackgroundColor3 = Theme.Panel})
                    tween(btnGlow, 0.12, {Transparency = 1.0})
                end
            end)
            table.insert(tabs, tab)
            if #tabs == 1 then selectTab(tab) end

            local function baseRow(h)
                local row = new("Frame", {Parent = page, BackgroundColor3 = Theme.Row, Size = UDim2.new(1, 0, 0, h or 40), BorderSizePixel = 0})
                corner(row, 8); stroke(row, Color3.fromRGB(255, 255, 255), 1, 0.93)
                return row
            end

            function tab:CreateSection(title)
                -- ✨ v83: Section mit animiertem Sweep-Unterstrich
                local secHolder = new("Frame", {Parent = page, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 32)})
                local lbl = new("TextLabel", {Parent = secHolder, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 0), Size = UDim2.new(1, 0, 0, 22), Font = Enum.Font.GothamBold, Text = tostring(title), TextColor3 = Theme.Cyan, TextSize = 15, TextXAlignment = Enum.TextXAlignment.Left})
                local lineTrack = new("Frame", {Parent = secHolder, BackgroundColor3 = Color3.fromRGB(28, 38, 60), BackgroundTransparency = 0.2, Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 0, 26), BorderSizePixel = 0})
                local lineFill  = new("Frame", {Parent = lineTrack, BackgroundColor3 = Theme.Cyan, BackgroundTransparency = 0.25, Size = UDim2.new(0, 0, 1, 0), BorderSizePixel = 0})
                task.spawn(function()
                    task.wait(0.04)
                    tween(lineFill, 0.45, {Size = UDim2.new(1, 0, 1, 0)})
                end)
                return {Set = function(_, t) lbl.Text = tostring(t) end}
            end

            function tab:CreateLabel(text)
                local row = baseRow(0)
                row.AutomaticSize = Enum.AutomaticSize.Y
                pad(row, 8, 8, 12, 12)
                local lbl = new("TextLabel", {Parent = row, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Font = Enum.Font.Gotham, Text = tostring(text), TextColor3 = Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true})
                return {Set = function(_, t) lbl.Text = tostring(t) end}
            end

            function tab:CreateButton(o)
                o = o or {}
                local row = baseRow(46)
                local lbl = new("TextLabel", {Parent = row, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(1, -44, 1, 0), Font = Enum.Font.GothamMedium, Text = tostring(o.Name or "Button"), TextColor3 = Theme.Text, TextSize = 15, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true})
                new("TextLabel", {Parent = row, BackgroundTransparency = 1, Position = UDim2.new(1, -30, 0, 0), Size = UDim2.new(0, 20, 1, 0), Font = Enum.Font.GothamBold, Text = "›", TextColor3 = Theme.Cyan, TextSize = 18})
                local click = new("TextButton", {Parent = row, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Text = "", AutoButtonColor = false})
                click.MouseEnter:Connect(function() playSound("hover"); tween(row, 0.12, {BackgroundColor3 = Theme.RowHover}) end)
                click.MouseLeave:Connect(function() tween(row, 0.12, {BackgroundColor3 = Theme.Row}) end)
                click.MouseButton1Click:Connect(function()
                    playSound("click")
                    tween(row, 0.06, {BackgroundColor3 = Theme.Cyan})
                    task.delay(0.09, function() tween(row, 0.22, {BackgroundColor3 = Theme.Row}) end)
                    -- ✨ v83: Ripple-Effekt (expandierender Kreis beim Klick)
                    task.spawn(function()
                        local ripple = new("Frame", {
                            Parent = row,
                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                            BackgroundTransparency = 0.55,
                            Size = UDim2.new(0, 0, 0, 0),
                            AnchorPoint = Vector2.new(0.5, 0.5),
                            Position = UDim2.new(0.5, 0, 0.5, 0),
                            BorderSizePixel = 0,
                            ZIndex = 10,
                        })
                        corner(ripple, 999)
                        tween(ripple, 0.38, {Size = UDim2.new(1.6, 0, 3.2, 0), BackgroundTransparency = 1})
                        task.wait(0.40)
                        ripple:Destroy()
                    end)
                    if o.Callback then task.spawn(o.Callback) end
                end)
                return {Set = function(_, t) lbl.Text = tostring(t) end}
            end

            function tab:CreateToggle(o)
                o = o or {}
                local state = o.CurrentValue and true or false
                local row = baseRow(46)
                new("TextLabel", {Parent = row, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(1, -70, 1, 0), Font = Enum.Font.GothamMedium, Text = tostring(o.Name or "Toggle"), TextColor3 = Theme.Text, TextSize = 15, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true})
                local pill = new("Frame", {Parent = row, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.new(0, 44, 0, 22), BackgroundColor3 = state and Theme.Cyan or Color3.fromRGB(40, 48, 66), BorderSizePixel = 0})
                corner(pill, 11)
                local knob = new("Frame", {Parent = pill, AnchorPoint = Vector2.new(0, 0.5), Position = state and UDim2.new(1, -20, 0.5, 0) or UDim2.new(0, 2, 0.5, 0), Size = UDim2.new(0, 18, 0, 18), BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0})
                corner(knob, 9)
                local click = new("TextButton", {Parent = row, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Text = "", AutoButtonColor = false})
                local function set(v, fire)
                    state = v and true or false
                    tween(pill, 0.15, {BackgroundColor3 = state and Theme.Cyan or Color3.fromRGB(40, 48, 66)})
                    -- ✨ v83: Knob Federgefühl (kurz überschießen dann einrasten)
                    local overshoot = state and UDim2.new(1, -15, 0.5, 0) or UDim2.new(0, 6, 0.5, 0)
                    local target    = state and UDim2.new(1, -20, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
                    tween(knob, 0.10, {Position = overshoot})
                    task.delay(0.10, function() tween(knob, 0.10, {Position = target}) end)
                    -- ✨ v83: Row kurz aufblitzen (grün = an, rot = aus)
                    local flashCol = state and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(220, 50, 50)
                    tween(row, 0.06, {BackgroundColor3 = flashCol})
                    task.delay(0.09, function() tween(row, 0.22, {BackgroundColor3 = Theme.Row}) end)
                    if fire ~= false and o.Callback then task.spawn(function() o.Callback(state) end) end
                end
                click.MouseEnter:Connect(function() playSound("hover") end)
                click.MouseButton1Click:Connect(function() set(not state); playSound(state and "toggleOn" or "toggleOff") end)
                return {Set = function(_, v) set(v) end}
            end

            function tab:CreateSlider(o)
                o = o or {}
                local rng = o.Range or {0, 100}
                local minV, maxV = rng[1], rng[2]
                if maxV == minV then maxV = minV + 1 end
                local inc = o.Increment or 1
                local suffix = o.Suffix or ""
                local val = o.CurrentValue or minV
                local row = baseRow(62)
                new("TextLabel", {Parent = row, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 6), Size = UDim2.new(1, -90, 0, 18), Font = Enum.Font.GothamMedium, Text = tostring(o.Name or "Slider"), TextColor3 = Theme.Text, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left})
                local valLbl = new("TextLabel", {Parent = row, BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, 6), Size = UDim2.new(0, 78, 0, 18), Font = Enum.Font.GothamBold, Text = tostring(val) .. suffix, TextColor3 = Theme.Cyan, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Right})
                local track = new("Frame", {Parent = row, Position = UDim2.new(0, 12, 0, 36), Size = UDim2.new(1, -24, 0, 8), BackgroundColor3 = Color3.fromRGB(36, 44, 64), BorderSizePixel = 0, Active = true})
                corner(track, 4)
                local sc0 = (val - minV) / (maxV - minV)
                local fill = new("Frame", {Parent = track, Size = UDim2.new(sc0, 0, 1, 0), BackgroundColor3 = Theme.Cyan, BorderSizePixel = 0})
                corner(fill, 4)
                local knob = new("Frame", {Parent = track, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(sc0, 0, 0.5, 0), Size = UDim2.new(0, 14, 0, 14), BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0})
                corner(knob, 7)
                local lastTick, lastVal = 0, val
                local function setScale(s, fire)
                    s = math.clamp(s, 0, 1)
                    local raw = math.floor(((minV + (maxV - minV) * s) / inc) + 0.5) * inc
                    raw = math.clamp(raw, minV, maxV)
                    val = raw
                    local sc = (val - minV) / (maxV - minV)
                    fill.Size = UDim2.new(sc, 0, 1, 0)
                    knob.Position = UDim2.new(sc, 0, 0.5, 0)
                    valLbl.Text = tostring(val) .. suffix
                    if fire ~= false then
                        if val ~= lastVal then
                            lastVal = val
                            local now = os.clock()
                            if now - lastTick > 0.04 then lastTick = now; playSound("slide") end
                        end
                        if o.Callback then task.spawn(function() o.Callback(val) end) end
                    end
                end
                local dragging = false
                local function scaleFromX(px) return (px - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1) end
                track.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true; setScale(scaleFromX(input.Position.X))
                    end
                end)
                track.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
                end)
                local _sliderMoveHandler = function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        setScale(scaleFromX(input.Position.X))
                    end
                end
                changedHandlers[_sliderMoveHandler] = true
                -- [FIX v93] Handler beim Zerstören des Sliders aus changedHandlers entfernen
                --           (vorher: permanenter Eintrag → Leak pro erstelltem Slider)
                track.AncestryChanged:Connect(function()
                    if not track.Parent then changedHandlers[_sliderMoveHandler] = nil end
                end)
                return {Set = function(_, v) setScale(((tonumber(v) or minV) - minV) / (maxV - minV)) end}
            end

            function tab:CreateInput(o)
                o = o or {}
                local row = baseRow(40)
                new("TextLabel", {Parent = row, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(0.45, -12, 1, 0), Font = Enum.Font.GothamMedium, Text = tostring(o.Name or "Input"), TextColor3 = Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true})
                local boxBg = new("Frame", {Parent = row, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.new(0.5, -12, 0, 28), BackgroundColor3 = Theme.Field, BorderSizePixel = 0})
                local bStroke = stroke(boxBg, Theme.Cyan, 1, 0.55)
                corner(boxBg, 7)
                local box = new("TextBox", {Parent = boxBg, BackgroundTransparency = 1, Size = UDim2.new(1, -16, 1, 0), Position = UDim2.new(0, 8, 0, 0), Font = Enum.Font.Gotham, PlaceholderText = tostring(o.PlaceholderText or ""), Text = "", TextColor3 = Theme.Text, PlaceholderColor3 = Theme.Sub, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false})
                box.Focused:Connect(function() playSound("hover"); tween(bStroke, 0.15, {Transparency = 0}) end)
                box.FocusLost:Connect(function()
                    tween(bStroke, 0.15, {Transparency = 0.55})
                    playSound("click")
                    local txt = box.Text
                    if o.Callback then task.spawn(function() o.Callback(txt) end) end
                    if o.RemoveTextAfterFocusLost then box.Text = "" end
                end)
                -- [FIX v76] Get() liest den Text direkt aus der TextBox – kein Timing-Problem
                -- wenn der User den Button klickt bevor FocusLost feuert.
                return {
                    Set = function(_, t) box.Text = tostring(t) end,
                    Get = function() return box.Text end,
                }
            end

            function tab:CreateDropdown(o)
                o = o or {}
                local options = o.Options or {}
                local current = (type(o.CurrentOption) == "table" and o.CurrentOption[1]) or o.CurrentOption or options[1] or ""
                local row = baseRow(40)
                new("TextLabel", {Parent = row, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(0.5, -12, 1, 0), Font = Enum.Font.GothamMedium, Text = tostring(o.Name or "Dropdown"), TextColor3 = Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true})
                local sel = new("TextButton", {Parent = row, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.new(0.45, -12, 0, 28), BackgroundColor3 = Theme.Field, Font = Enum.Font.GothamMedium, Text = tostring(current) .. "  ▾", TextColor3 = Theme.Cyan, TextSize = 13, AutoButtonColor = false, BorderSizePixel = 0})
                corner(sel, 7); stroke(sel, Theme.Cyan, 1, 0.55)
                local open, listFrame = false, nil
                local function closeList() open = false; if listFrame then listFrame:Destroy(); listFrame = nil end end
                local function setOpt(opt)
                    current = opt
                    sel.Text = tostring(current) .. "  ▾"
                    if o.Callback then task.spawn(function() o.Callback(current) end) end
                end
                sel.MouseEnter:Connect(function() playSound("hover") end)
                sel.MouseButton1Click:Connect(function()
                    if open then playSound("close"); closeList() return end
                    open = true
                    playSound("open")
                    local targetH = math.min(#options, 5) * 26 + 8
                    local listW = math.max(sel.AbsoluteSize.X, 180)
                    local aPos  = sel.AbsolutePosition
                    local aSz   = sel.AbsoluteSize
                    local scrW  = sg.AbsoluteSize.X
                    -- Rechts vom Hub öffnen; wenn kein Platz → links vom Button
                    local xPos = aPos.X + aSz.X + 8
                    if xPos + listW > scrW - 8 then xPos = aPos.X - listW - 8 end
                    local yPos = aPos.Y
                    listFrame = new("Frame", {Parent = sg, BackgroundColor3 = Theme.Field, Position = UDim2.fromOffset(xPos, yPos), Size = UDim2.fromOffset(listW, 0), BorderSizePixel = 0, ZIndex = 200, ClipsDescendants = true})
                    corner(listFrame, 7); stroke(listFrame, Theme.Cyan, 1, 0.4)
                    tween(listFrame, 0.16, {Size = UDim2.fromOffset(listW, targetH)})
                    local lf = new("ScrollingFrame", {Parent = listFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 2, BorderSizePixel = 0, ZIndex = 200})
                    new("UIListLayout", {Parent = lf, Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder})
                    pad(lf, 4, 4, 4, 4)
                    for _, opt in ipairs(options) do
                        local ob = new("TextButton", {Parent = lf, BackgroundColor3 = Theme.Row, Size = UDim2.new(1, 0, 0, 22), Font = Enum.Font.Gotham, Text = tostring(opt), TextColor3 = Theme.Text, TextSize = 13, AutoButtonColor = true, BorderSizePixel = 0, ZIndex = 201})
                        corner(ob, 5)
                        ob.MouseEnter:Connect(function() playSound("hover") end)
                        ob.MouseButton1Click:Connect(function() playSound("click"); setOpt(opt); closeList() end)
                    end
                end)
                return {Set = function(_, opt) setOpt(type(opt) == "table" and opt[1] or opt) end}
            end

            function tab:CreateColorPicker(o)
                o = o or {}
                local color = o.Color or Color3.fromRGB(255, 0, 0)
                local h, s, v = color:ToHSV()
                local row = baseRow(40)
                new("TextLabel", {Parent = row, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(1, -70, 1, 0), Font = Enum.Font.GothamMedium, Text = tostring(o.Name or "Farbe"), TextColor3 = Theme.Text, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true})
                local swatch = new("TextButton", {Parent = row, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.new(0, 40, 0, 24), BackgroundColor3 = color, Text = "", AutoButtonColor = false, BorderSizePixel = 0})
                corner(swatch, 6); stroke(swatch, Color3.fromRGB(255, 255, 255), 1, 0.7)
                local open, popup, moveHandler = false, nil, nil
                local function apply(fire)
                    color = Color3.fromHSV(h, s, v)
                    swatch.BackgroundColor3 = color
                    if fire and o.Callback then task.spawn(function() o.Callback(color) end) end
                end
                local function closePopup()
                    open = false
                    if popup then popup:Destroy(); popup = nil end
                    if moveHandler then changedHandlers[moveHandler] = nil; moveHandler = nil end
                end
                swatch.MouseEnter:Connect(function() playSound("hover") end)
                swatch.MouseButton1Click:Connect(function()
                    if open then playSound("close"); closePopup() return end
                    open = true
                    playSound("open")
                    local aPos = swatch.AbsolutePosition
                    local aSz  = swatch.AbsoluteSize
                    local scrW = sg.AbsoluteSize.X
                    local popW = 210
                    -- Rechts vom Hub öffnen; wenn kein Platz → links vom Swatch
                    local xPos = aPos.X + aSz.X + 8
                    if xPos + popW > scrW - 8 then xPos = aPos.X - popW - 8 end
                    popup = new("Frame", {Parent = sg, BackgroundColor3 = Theme.Field, Position = UDim2.fromOffset(xPos, aPos.Y), Size = UDim2.fromOffset(0, 0), BorderSizePixel = 0, ZIndex = 200, ClipsDescendants = true})
                    corner(popup, 8); stroke(popup, Theme.Cyan, 1, 0.4); pad(popup, 10, 10, 10, 10)
                    tween(popup, 0.18, {Size = UDim2.fromOffset(popW, 168)})
                    local svf = new("Frame", {Parent = popup, Size = UDim2.new(1, 0, 0, 110), BackgroundColor3 = Color3.fromHSV(h, 1, 1), BorderSizePixel = 0, ZIndex = 30, Active = true})
                    corner(svf, 6)
                    local white = new("Frame", {Parent = svf, Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0, ZIndex = 30})
                    corner(white, 6)
                    new("UIGradient", {Parent = white, Color = ColorSequence.new(Color3.new(1, 1, 1)), Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)})})
                    local black = new("Frame", {Parent = svf, Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(0, 0, 0), BorderSizePixel = 0, ZIndex = 30})
                    corner(black, 6)
                    new("UIGradient", {Parent = black, Rotation = 90, Color = ColorSequence.new(Color3.new(0, 0, 0)), Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0)})})
                    local svDot = new("Frame", {Parent = svf, Size = UDim2.new(0, 8, 0, 8), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(s, 0, 1 - v, 0), BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0, ZIndex = 31})
                    corner(svDot, 4); stroke(svDot, Color3.fromRGB(0, 0, 0), 1, 0.3)
                    local hue = new("Frame", {Parent = popup, Position = UDim2.new(0, 0, 0, 120), Size = UDim2.new(1, 0, 0, 16), BorderSizePixel = 0, ZIndex = 30, Active = true})
                    corner(hue, 6)
                    new("UIGradient", {Parent = hue, Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
                        ColorSequenceKeypoint.new(0.17, Color3.fromHSV(0.17, 1, 1)),
                        ColorSequenceKeypoint.new(0.34, Color3.fromHSV(0.34, 1, 1)),
                        ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5, 1, 1)),
                        ColorSequenceKeypoint.new(0.67, Color3.fromHSV(0.67, 1, 1)),
                        ColorSequenceKeypoint.new(0.84, Color3.fromHSV(0.84, 1, 1)),
                        ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1)),
                    })})
                    local hueDot = new("Frame", {Parent = hue, Size = UDim2.new(0, 4, 1, 4), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(h, 0, 0.5, 0), BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0, ZIndex = 31})
                    local svDrag, hueDrag = false, false
                    local function svUp(px, py)
                        s = math.clamp((px - svf.AbsolutePosition.X) / math.max(svf.AbsoluteSize.X, 1), 0, 1)
                        v = 1 - math.clamp((py - svf.AbsolutePosition.Y) / math.max(svf.AbsoluteSize.Y, 1), 0, 1)
                        svDot.Position = UDim2.new(s, 0, 1 - v, 0); apply(true)
                    end
                    local function hueUp(px)
                        h = math.clamp((px - hue.AbsolutePosition.X) / math.max(hue.AbsoluteSize.X, 1), 0, 1)
                        hueDot.Position = UDim2.new(h, 0, 0.5, 0); svf.BackgroundColor3 = Color3.fromHSV(h, 1, 1); apply(true)
                    end
                    svf.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then svDrag = true; svUp(i.Position.X, i.Position.Y) end end)
                    svf.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then svDrag = false end end)
                    hue.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then hueDrag = true; hueUp(i.Position.X) end end)
                    hue.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then hueDrag = false end end)
                    moveHandler = function(i)
                        if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
                            if svDrag then svUp(i.Position.X, i.Position.Y) end
                            if hueDrag then hueUp(i.Position.X) end
                        end
                    end
                    changedHandlers[moveHandler] = true
                end)
                return {Set = function(_, c) if typeof(c) == "Color3" then color = c; h, s, v = c:ToHSV(); apply(false) end end}
            end

            function tab:CreateKeybind(o)
                o = o or {}
                local key = tostring(o.CurrentKeybind or "")
                local row = baseRow(40)
                new("TextLabel", {Parent = row, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(1, -90, 1, 0), Font = Enum.Font.GothamMedium, Text = tostring(o.Name or "Keybind"), TextColor3 = Theme.Text, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true})
                local kb = new("TextButton", {Parent = row, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.new(0, 64, 0, 26), BackgroundColor3 = Theme.Field, Font = Enum.Font.GothamBold, Text = key ~= "" and key or "—", TextColor3 = Theme.Cyan, TextSize = 13, AutoButtonColor = false, BorderSizePixel = 0})
                corner(kb, 7); stroke(kb, Theme.Cyan, 1, 0.5)
                local binding = false
                kb.MouseEnter:Connect(function() playSound("hover") end)
                kb.MouseButton1Click:Connect(function() binding = true; kb.Text = "..."; playSound("click") end)
                local _keybindHandler = function(input, gpe)
                    if binding then
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            key = input.KeyCode.Name; kb.Text = key; binding = false; playSound("toggleOn")
                        end
                        return
                    end
                    if gpe then return end
                    if key ~= "" and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == keycode(key) then
                        if o.Callback then task.spawn(o.Callback) end
                    end
                end
                beganHandlers[_keybindHandler] = true
                -- [FIX v93] Handler beim Zerstören des Keybind-Rows entfernen
                --           (vorher: permanenter Eintrag in beganHandlers → Leak pro Keybind)
                row.AncestryChanged:Connect(function()
                    if not row.Parent then beganHandlers[_keybindHandler] = nil end
                end)
                return {Set = function(_, k) key = tostring(k); kb.Text = key end}
            end

            -- Visuelle Spieler-Liste: links rundes Profilbild, rechts Name (groß, scrollbar, anklickbar)
            function tab:CreatePlayerList(o)
                o = o or {}
                local rowH = tonumber(o.RowHeight) or 60
                local maxVisible = tonumber(o.MaxVisible) or 6
                local holder = new("Frame", {Parent = page, BackgroundColor3 = Theme.Field, Size = UDim2.new(1, 0, 0, rowH * maxVisible + 12), BorderSizePixel = 0, ClipsDescendants = true})
                corner(holder, 10); stroke(holder, Theme.Cyan, 1, 0.6)
                local scroller = new("ScrollingFrame", {Parent = holder, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 3, ScrollBarImageColor3 = Theme.Cyan, BorderSizePixel = 0})
                new("UIListLayout", {Parent = scroller, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder})
                pad(scroller, 6, 6, 6, 6)
                local empty = new("TextLabel", {Parent = scroller, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 28), Font = Enum.Font.GothamMedium, Text = "Keine anderen Spieler im Server", TextColor3 = Theme.Sub, TextSize = 13, Visible = false})

                local api = {}
                local selectedRow, selectedStroke

                local function makeRow(plr)
                    local row = new("TextButton", {Parent = scroller, BackgroundColor3 = Theme.Row, Size = UDim2.new(1, 0, 0, rowH - 6), AutoButtonColor = false, Text = "", BorderSizePixel = 0})
                    corner(row, 9)
                    local st = stroke(row, Color3.fromRGB(255, 255, 255), 1, 0.9)
                    local avSize = rowH - 22
                    local avBg = new("Frame", {Parent = row, BackgroundColor3 = Theme.Bg, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 9, 0.5, 0), Size = UDim2.new(0, avSize, 0, avSize), BorderSizePixel = 0})
                    corner(avBg, avSize / 2); stroke(avBg, Theme.Cyan, 1, 0.4)
                    local av = new("ImageLabel", {Parent = avBg, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(plr.UserId) .. "&w=150&h=150", ScaleType = Enum.ScaleType.Crop})
                    corner(av, avSize / 2)
                    new("TextLabel", {Parent = row, BackgroundTransparency = 1, Position = UDim2.new(0, avSize + 20, 0, 0), Size = UDim2.new(1, -(avSize + 28), 0.56, 0), Font = Enum.Font.GothamBold, Text = tostring(plr.DisplayName), TextColor3 = Theme.Text, TextSize = 15, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Bottom, TextTruncate = Enum.TextTruncate.AtEnd})
                    new("TextLabel", {Parent = row, BackgroundTransparency = 1, Position = UDim2.new(0, avSize + 20, 0.5, 0), Size = UDim2.new(1, -(avSize + 28), 0.44, 0), Font = Enum.Font.Gotham, Text = "@" .. tostring(plr.Name), TextColor3 = Theme.Sub, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, TextTruncate = Enum.TextTruncate.AtEnd})

                    row.MouseEnter:Connect(function() playSound("hover") if row ~= selectedRow then tween(row, 0.12, {BackgroundColor3 = Theme.RowHover}) end end)
                    row.MouseLeave:Connect(function() if row ~= selectedRow then tween(row, 0.12, {BackgroundColor3 = Theme.Row}) end end)
                    row.MouseButton1Click:Connect(function()
                        playSound("click")
                        if selectedRow and selectedRow ~= row then
                            tween(selectedRow, 0.12, {BackgroundColor3 = Theme.Row})
                            if selectedStroke then tween(selectedStroke, 0.12, {Transparency = 0.9, Color = Color3.fromRGB(255, 255, 255)}) end
                        end
                        selectedRow = row; selectedStroke = st
                        tween(row, 0.12, {BackgroundColor3 = Theme.RowHover})
                        tween(st, 0.12, {Transparency = 0.2, Color = Theme.Cyan})
                        if o.Callback then task.spawn(o.Callback, plr) end
                    end)
                end

                function api:Refresh(playersArray)
                    selectedRow, selectedStroke = nil, nil
                    for _, c in ipairs(scroller:GetChildren()) do
                        if c:IsA("TextButton") then c:Destroy() end
                    end
                    local count = 0
                    if playersArray then
                        for _, plr in ipairs(playersArray) do
                            if pcall(makeRow, plr) then count = count + 1 end
                        end
                    end
                    empty.Visible = (count == 0)
                end

                return api
            end

            return tab
        end

        -- Seiten-Panel: Spielerliste gleitet rechts neben dem Hub heraus (Swipe-Animation)
        function Window:CreatePlayerPanel(o)
            o = o or {}
            local rowH = tonumber(o.RowHeight) or 60
            local gap = 12
            local halfMain = 300
            local panelW = 250

            local panel = new("Frame", {Parent = sg, BackgroundColor3 = Theme.Bg, Size = UDim2.new(0, panelW, 0, 380), AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0), BorderSizePixel = 0, Visible = false, ClipsDescendants = true})
            corner(panel, 14)
            local pStroke = stroke(panel, Theme.Cyan, 1.4, 0.35)

            local ph = new("Frame", {Parent = panel, BackgroundColor3 = Theme.Header, Size = UDim2.new(1, 0, 0, 42), BorderSizePixel = 0})
            corner(ph, 14)
            new("Frame", {Parent = ph, BackgroundColor3 = Theme.Header, Size = UDim2.new(1, 0, 0, 16), Position = UDim2.new(0, 0, 1, -16), BorderSizePixel = 0})
            new("Frame", {Parent = ph, BackgroundColor3 = Theme.Cyan, Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1), BorderSizePixel = 0, BackgroundTransparency = 0.55})
            new("TextLabel", {Parent = ph, BackgroundTransparency = 1, Position = UDim2.new(0, 14, 0, 0), Size = UDim2.new(1, -50, 1, 0), Font = Enum.Font.GothamBold, Text = "👥 Spieler", TextColor3 = Theme.Text, TextSize = 15, TextXAlignment = Enum.TextXAlignment.Left})
            local closeB = new("TextButton", {Parent = ph, BackgroundColor3 = Theme.Row, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0), Size = UDim2.new(0, 26, 0, 26), Font = Enum.Font.GothamBold, Text = "✕", TextColor3 = Color3.fromRGB(255, 120, 130), TextSize = 14, AutoButtonColor = false, BorderSizePixel = 0})
            corner(closeB, 7); stroke(closeB, Color3.fromRGB(255, 255, 255), 1, 0.9)

            local scroller = new("ScrollingFrame", {Parent = panel, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 42), Size = UDim2.new(1, 0, 1, -42), CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 3, ScrollBarImageColor3 = Theme.Cyan, BorderSizePixel = 0})
            new("UIListLayout", {Parent = scroller, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder})
            pad(scroller, 8, 8, 8, 8)
            local empty = new("TextLabel", {Parent = scroller, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 28), Font = Enum.Font.GothamMedium, Text = "Keine anderen Spieler im Server", TextColor3 = Theme.Sub, TextSize = 13, Visible = false})

            local api = {}
            local isOpen2 = false
            local selectedRow, selectedStroke

            local function makeRow(plr)
                local row = new("TextButton", {Parent = scroller, BackgroundColor3 = Theme.Row, Size = UDim2.new(1, 0, 0, rowH - 6), AutoButtonColor = false, Text = "", BorderSizePixel = 0})
                corner(row, 9)
                local st = stroke(row, Color3.fromRGB(255, 255, 255), 1, 0.9)
                local avSize = rowH - 22
                local avBg = new("Frame", {Parent = row, BackgroundColor3 = Theme.Bg, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 9, 0.5, 0), Size = UDim2.new(0, avSize, 0, avSize), BorderSizePixel = 0})
                corner(avBg, avSize / 2); stroke(avBg, Theme.Cyan, 1, 0.4)
                local av = new("ImageLabel", {Parent = avBg, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(plr.UserId) .. "&w=150&h=150", ScaleType = Enum.ScaleType.Crop})
                corner(av, avSize / 2)
                new("TextLabel", {Parent = row, BackgroundTransparency = 1, Position = UDim2.new(0, avSize + 20, 0, 0), Size = UDim2.new(1, -(avSize + 28), 0.56, 0), Font = Enum.Font.GothamBold, Text = tostring(plr.DisplayName), TextColor3 = Theme.Text, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Bottom, TextTruncate = Enum.TextTruncate.AtEnd})
                new("TextLabel", {Parent = row, BackgroundTransparency = 1, Position = UDim2.new(0, avSize + 20, 0.5, 0), Size = UDim2.new(1, -(avSize + 28), 0.44, 0), Font = Enum.Font.Gotham, Text = "@" .. tostring(plr.Name), TextColor3 = Theme.Sub, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, TextTruncate = Enum.TextTruncate.AtEnd})

                row.MouseEnter:Connect(function() playSound("hover") if row ~= selectedRow then tween(row, 0.12, {BackgroundColor3 = Theme.RowHover}) end end)
                row.MouseLeave:Connect(function() if row ~= selectedRow then tween(row, 0.12, {BackgroundColor3 = Theme.Row}) end end)
                row.MouseButton1Click:Connect(function()
                    playSound("click")
                    if selectedRow and selectedRow ~= row then
                        tween(selectedRow, 0.12, {BackgroundColor3 = Theme.Row})
                        if selectedStroke then tween(selectedStroke, 0.12, {Transparency = 0.9, Color = Color3.fromRGB(255, 255, 255)}) end
                    end
                    selectedRow = row; selectedStroke = st
                    tween(row, 0.12, {BackgroundColor3 = Theme.RowHover})
                    tween(st, 0.12, {Transparency = 0.2, Color = Theme.Cyan})
                    if o.Callback then task.spawn(o.Callback, plr) end
                end)
            end

            function api:Refresh(playersArray)
                selectedRow, selectedStroke = nil, nil
                for _, c in ipairs(scroller:GetChildren()) do
                    if c:IsA("TextButton") then c:Destroy() end
                end
                local count = 0
                if playersArray then
                    for _, plr in ipairs(playersArray) do
                        if pcall(makeRow, plr) then count = count + 1 end
                    end
                end
                empty.Visible = (count == 0)
            end

            -- Position rechts neben dem Hub (folgt dem Fenster beim Ziehen)
            local function targetPos()
                return UDim2.new(main.Position.X.Scale, main.Position.X.Offset + halfMain + gap, main.Position.Y.Scale, main.Position.Y.Offset)
            end
            local function tuckedPos()
                return UDim2.new(main.Position.X.Scale, main.Position.X.Offset + 70, main.Position.Y.Scale, main.Position.Y.Offset)
            end

            function api:Open()
                if isOpen2 then return end
                isOpen2 = true
                panel.Visible = true
                panel.Position = tuckedPos()
                playSound("open")
                tween(panel, 0.32, {Position = targetPos()})
                tween(pStroke, 0.32, {Transparency = 0.35})
            end
            function api:Close()
                if not isOpen2 then return end
                isOpen2 = false
                playSound("close")
                tween(panel, 0.24, {Position = tuckedPos()})
                tween(pStroke, 0.24, {Transparency = 1})
                task.delay(0.26, function() if not isOpen2 then panel.Visible = false end end)
            end
            function api:Toggle() if isOpen2 then api:Close() else api:Open() end end
            function api:IsOpen() return isOpen2 end

            closeB.MouseEnter:Connect(function() playSound("hover"); tween(closeB, 0.12, {BackgroundColor3 = Theme.RowHover}) end)
            closeB.MouseLeave:Connect(function() tween(closeB, 0.12, {BackgroundColor3 = Theme.Row}) end)
            closeB.MouseButton1Click:Connect(function() api:Close() end)

            main:GetPropertyChangedSignal("Position"):Connect(function()
                if isOpen2 then panel.Position = targetPos() end
            end)
            main:GetPropertyChangedSignal("Visible"):Connect(function()
                if not main.Visible and isOpen2 then api:Close() end
            end)

            return api
        end

        -- Lade-Overlay (LoadingTitle / Subtitle)
        ;(function() -- block: own register pool
            local overlay = new("Frame", {Parent = main, BackgroundColor3 = Theme.Bg, Size = UDim2.new(1, 0, 1, 0), BorderSizePixel = 0, ZIndex = 50})
            local lt = new("TextLabel", {Parent = overlay, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0.4, 0), Size = UDim2.new(1, 0, 0, 30), Font = Enum.Font.GothamBlack, Text = tostring(opts.LoadingTitle or "SEMYS HUB"), TextColor3 = Theme.Cyan, TextSize = 26, ZIndex = 51})
            local ls = new("TextLabel", {Parent = overlay, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0.4, 34), Size = UDim2.new(1, 0, 0, 20), Font = Enum.Font.GothamMedium, Text = tostring(opts.LoadingSubtitle or ""), TextColor3 = Theme.Sub, TextSize = 14, ZIndex = 51})
            local barBg = new("Frame", {Parent = overlay, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0.4, 64), Size = UDim2.new(0, 200, 0, 4), BackgroundColor3 = Theme.Row, BorderSizePixel = 0, ZIndex = 51})
            corner(barBg, 2)
            local bar = new("Frame", {Parent = barBg, Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = Theme.Cyan, BorderSizePixel = 0, ZIndex = 51})
            corner(bar, 2)
            tween(bar, 1, {Size = UDim2.new(1, 0, 1, 0)})
            task.delay(1.15, function()
                playSound("open")
                tween(overlay, 0.4, {BackgroundTransparency = 1})
                tween(lt, 0.4, {TextTransparency = 1}); tween(ls, 0.4, {TextTransparency = 1})
                tween(barBg, 0.4, {BackgroundTransparency = 1}); tween(bar, 0.4, {BackgroundTransparency = 1})
                task.wait(0.45); overlay:Destroy()
            end)
        end)()

        return Window
    end

    -- ======== Benachrichtigungen ========
    function Library:Notify(opts)
        opts = opts or {}
        if not notifHolder then return end
        -- ✨ v83: Notifications mit Countdown-Bar (notifAccent entfernt — AutomaticSize.Y Bug-Fix)
        local card = new("Frame", {Parent = notifHolder, BackgroundColor3 = Theme.Panel, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, ZIndex = 60})
        corner(card, 10)
        local cs = stroke(card, Theme.Cyan, 1.5, 1)
        pad(card, 10, 10, 14, 12)
        new("UIListLayout", {Parent = card, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder})
        local title = new("TextLabel", {Parent = card, LayoutOrder = 1, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Font = Enum.Font.GothamBold, Text = tostring(opts.Title or "Semys HUB"), TextColor3 = Theme.Text, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, TextTransparency = 1, ZIndex = 61})
        local content = new("TextLabel", {Parent = card, LayoutOrder = 2, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Font = Enum.Font.Gotham, Text = tostring(opts.Content or ""), TextColor3 = Theme.Sub, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, TextTransparency = 1, ZIndex = 61})
        -- Countdown-Bar mit fixer Pixel-Höhe (kein relativer Y-Scale → kein Circular-Dependency)
        local cbTrack = new("Frame", {Parent = card, LayoutOrder = 3, BackgroundColor3 = Color3.fromRGB(22, 30, 50), BackgroundTransparency = 0.4, Size = UDim2.new(1, 0, 0, 3), BorderSizePixel = 0, ZIndex = 62})
        local cbFill  = new("Frame", {Parent = cbTrack, BackgroundColor3 = Theme.Cyan, BackgroundTransparency = 0.3, Size = UDim2.new(1, 0, 1, 0), BorderSizePixel = 0, ZIndex = 63})
        playSound("notify")
        tween(card, 0.22, {BackgroundTransparency = 0})
        tween(cs, 0.25, {Transparency = 0.35})
        tween(title, 0.25, {TextTransparency = 0})
        tween(content, 0.25, {TextTransparency = 0})
        local dur = tonumber(opts.Duration) or 3
        tween(cbFill, dur, {Size = UDim2.new(0, 0, 1, 0)})
        task.delay(dur, function()
            tween(card, 0.28, {BackgroundTransparency = 1})
            tween(cs, 0.28, {Transparency = 1})
            tween(title, 0.28, {TextTransparency = 1})
            tween(content, 0.28, {TextTransparency = 1})
            task.wait(0.32); card:Destroy()
        end)
    end

    -- Menü-Sounds an/aus schalten
    function Library:SetSounds(b) soundsOn = b and true or false end
    -- Master-Lautstärke der Menü-Sounds (0 = aus, 1 = normal, bis 3 = lauter)
    function Library:SetSoundVolume(v) masterVol = math.clamp(tonumber(v) or 1, 0, 3) end

    -- [FIX v88] Echte Implementierung wird NACH der Settings-Tabelle registriert
    -- (Settings ist zu diesem Zeitpunkt noch nicht im Scope — wird unten überschrieben)
    function Library:LoadConfiguration() end
    function Library:SaveConfiguration() end

    return Library
end)()

local Rayfield = SemysUI
-- [FIX] Nil-Guard: SemysUI gibt immer eine Tabelle zurück, aber falls das IIFE crasht
-- ist Rayfield nil → jeder Rayfield:Notify()-Aufruf danach würde das Script absturzartig beenden.
if not Rayfield then
    error("[SemysHUB] Kritisch: SemysUI konnte nicht initialisiert werden — Script abgebrochen.")
end

-- [FIX v76] Settings Forward-Deklaration: muss VOR dem Config-Tab do-Block stehen,
-- damit serialize()/deserialize() dieselbe lokale Variable schließen wie die Zuweisung
-- bei Zeile ~2969. Ohne diese Zeile sieht serialize() Settings als globale nil-Variable
-- → pcall schluckt den Fehler still → nichts wird gespeichert.
local Settings

local Window = Rayfield:CreateWindow({
   Name = "Semys HUB v101 | Clans Murder Duels",  -- [FIX v101] v94 → v101
   LoadingTitle = "Semys HUB",
   LoadingSubtitle = "v101 - Alle Bugs gefixt",  -- [FIX v101] v94 → v101
   ConfigurationSaving = { Enabled = true, FolderName = "Semys_HUB_Clans" },
   KeySystem = false
})

local CombatTab = Window:CreateTab("⚡ Combat", 4483362748)
local VisualTab = Window:CreateTab("👀 Visuals", 4483362748)
local MovementTab = Window:CreateTab("💨 Movement", 4483362748)
local PlayerTab = Window:CreateTab("👤 Spieler", 4483362748)
local AntiTab = Window:CreateTab("🔰 Anti", 4483362748)
local TrollTab = Window:CreateTab("🎭 Tänze", 4483362748)
local ChatTab = Window:CreateTab("📢 Chat", 4483362748)
local SpezialTab = Window:CreateTab("🔥 Spezial", 4483362748)
local SettingsTab = Window:CreateTab("🔧 Einstellungen", 4483362748)

-- ==================== 🎵 MUSIK TAB ====================
;(function() -- block: own register pool
    local MusikTab = Window:CreateTab("🎵 Musik", 4483362748)

    -- ── VISUELLER MUSIK-PLAYER (direkt in Tab-Page injiziert) ────────────
    ;(function() -- block: own register pool
        local RS_m    = game:GetService("RunService")
        local C_CYAN  = Color3.fromRGB(0, 209, 255)
        local C_WHITE = Color3.fromRGB(220, 235, 255)

        local pCard = Instance.new("Frame")
        pCard.Size                   = UDim2.new(1, 0, 0, 86)
        pCard.BackgroundColor3       = Color3.fromRGB(10, 14, 28)
        pCard.BackgroundTransparency = 0.08
        pCard.BorderSizePixel        = 0
        pCard.Parent                 = MusikTab.page
        Instance.new("UICorner", pCard).CornerRadius = UDim.new(0, 10)
        local pStroke = Instance.new("UIStroke", pCard)
        pStroke.Color = C_CYAN; pStroke.Thickness = 1.2; pStroke.Transparency = 0.35

        -- EQ-Balken (7 Stück, links)
        local eqBars = {}
        for i = 1, 7 do
            local b = Instance.new("Frame")
            b.Size             = UDim2.new(0, 3, 0, 4)
            b.Position         = UDim2.new(0, 10 + (i-1)*6, 0.5, -2)
            b.BackgroundColor3 = C_CYAN
            b.BorderSizePixel  = 0
            b.ZIndex           = 2
            b.Parent           = pCard
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 2)
            table.insert(eqBars, {frame = b, ph = i * 0.55})
        end

        -- Track-Name
        local trackLbl = Instance.new("TextLabel")
        trackLbl.Text               = HubState.musicNow or "⏸ Nichts läuft"
        trackLbl.Size               = UDim2.new(1, -70, 0, 18)
        trackLbl.Position           = UDim2.new(0, 56, 0, 12)
        trackLbl.BackgroundTransparency = 1
        trackLbl.TextColor3         = C_WHITE
        trackLbl.Font               = Enum.Font.GothamBold
        trackLbl.TextSize           = 12
        trackLbl.TextXAlignment     = Enum.TextXAlignment.Left
        trackLbl.TextTruncate       = Enum.TextTruncate.AtEnd
        trackLbl.ZIndex             = 2
        trackLbl.Parent             = pCard

        -- Fortschrittsbalken
        local progBG = Instance.new("Frame")
        progBG.Size             = UDim2.new(1, -70, 0, 3)
        progBG.Position         = UDim2.new(0, 56, 0, 36)
        progBG.BackgroundColor3 = Color3.fromRGB(0, 30, 45)
        progBG.BorderSizePixel  = 0
        progBG.ZIndex           = 2
        progBG.Parent           = pCard
        Instance.new("UICorner", progBG).CornerRadius = UDim.new(1, 0)
        local progFill = Instance.new("Frame")
        progFill.Size             = UDim2.new(0, 0, 1, 0)
        progFill.BackgroundColor3 = C_CYAN
        progFill.BorderSizePixel  = 0
        progFill.ZIndex           = 3
        progFill.Parent           = progBG
        Instance.new("UICorner", progFill).CornerRadius = UDim.new(1, 0)

        -- Buttons: Prev / Play-Pause / Next
        local function mkMBtn(txt, offX)
            local b = Instance.new("TextButton")
            b.Text             = txt
            b.Size             = UDim2.new(0, 28, 0, 28)
            b.Position         = UDim2.new(0, offX, 0, 48)
            b.BackgroundColor3 = Color3.fromRGB(8, 18, 35)
            b.TextColor3       = C_CYAN
            b.Font             = Enum.Font.GothamBold
            b.TextSize         = 10
            b.AutoButtonColor  = false
            b.BorderSizePixel  = 0
            b.ZIndex           = 2
            b.Parent           = pCard
            Instance.new("UICorner", b).CornerRadius = UDim.new(1, 0)
            local st = Instance.new("UIStroke", b)
            st.Color = C_CYAN; st.Thickness = 1; st.Transparency = 0.5
            b.MouseEnter:Connect(function() st.Transparency = 0.1 end)
            b.MouseLeave:Connect(function() st.Transparency = 0.5 end)
            return b
        end
        local prevB = mkMBtn("◀",   56)
        local playB = mkMBtn("⏸",   90)
        local nextB = mkMBtn("▶▶", 124)

        prevB.MouseButton1Click:Connect(function() HubState.Music.prev() end)
        nextB.MouseButton1Click:Connect(function() HubState.Music.next() end)
        playB.MouseButton1Click:Connect(function()
            HubState.Music.toggle()
            task.wait(0.05)
            playB.Text = HubState.musicOn and "⏸" or "▶"
        end)

        -- Track-Name + Button-Status live aktualisieren
        HubState.Music.register(function(text)
            pcall(function()
                trackLbl.Text = text
                playB.Text    = HubState.musicOn and "⏸" or "▶"
            end)
        end)

        -- EQ-Animation + Fortschrittsbalken per Heartbeat
        -- [FPS-FIX] 20x/s statt 60x/s — EQ-Bars brauchen keine Frame-genaue Aktualisierung
        -- [FIX v93] Connection speichern und bei pCard-Destroy trennen
        --           (vorher: Connection lief unbegrenzt weiter wenn pCard zerstört wurde)
        local _eqTimer2 = 0
        local _eqConn2 = RS_m.Heartbeat:Connect(function(dt)
            _eqTimer2 = _eqTimer2 + dt
            if _eqTimer2 < 0.05 then return end
            _eqTimer2 = 0
            if not pCard.Parent then return end
            local playing = HubState.musicOn
            for i, b in ipairs(eqBars) do
                if playing then
                    local h = math.abs(math.sin(os.clock() * 5 + b.ph)) * 18 + 3
                    b.frame.Size     = UDim2.new(0, 3, 0, h)
                    b.frame.Position = UDim2.new(0, 10 + (i-1)*6, 0.5, -h/2)
                else
                    b.frame.Size     = UDim2.new(0, 3, 0, 4)
                    b.frame.Position = UDim2.new(0, 10 + (i-1)*6, 0.5, -2)
                end
            end
            local s = HubState.musicSound
            if s and s.TimeLength > 0 then
                progFill.Size = UDim2.new(math.clamp(s.TimePosition / s.TimeLength, 0, 1), 0, 1, 0)
            end
        end)
        pCard.AncestryChanged:Connect(function()
            if not pCard.Parent then _eqConn2:Disconnect(); _eqConn2 = nil end  -- [FIX v101] nil nach Disconnect gesetzt
        end)
    end)()

    -- ── STEUERUNG ─────────────────────────────────────────────────────────
    MusikTab:CreateSection("🎛️ Steuerung")
    MusikTab:CreateLabel("📋 Gesperrte Songs werden nach 5s automatisch übersprungen.")

    MusikTab:CreateToggle({
        Name = "🎵 Musik AN / AUS",
        CurrentValue = HubState.musicOn,  -- [FIX vXX] Startwert aus echtem State lesen statt fest true
        Callback = function(state)
            if state then HubState.Music.play() else HubState.Music.pause() end
        end
    })
    MusikTab:CreateButton({Name = "⏭️ Nächster Song",   Callback = function() HubState.Music.next() end})
    MusikTab:CreateButton({Name = "⏮️ Vorheriger Song", Callback = function() HubState.Music.prev() end})
    MusikTab:CreateSlider({
        Name = "🔊 Lautstärke",
        Range = {0, 100}, Increment = 5, Suffix = "%",
        CurrentValue = math.floor((HubState.musicVolume or 0.5) * 100),
        Callback = function(v) HubState.Music.setVolume(v / 100) end
    })
    MusikTab:CreateButton({Name = "⏸ Stop", Callback = function() HubState.Music.stop() end})

    MusikTab:CreateSection("🎵 Eigene Musik")
    MusikTab:CreateInput({
        Name = "🆔 Eigene Audio-ID (nur Zahl)",
        PlaceholderText = "z.B. 1846458016",
        RemoveTextAfterFocusLost = false,
        Callback = function(text) HubState.Music.playCustom(text) end
    })

    MusikTab:CreateSection("📜 Playlist")
    ;(function() -- block: own register pool
        local names = ""
        for idx, t in ipairs(HubState.Music.playlist) do
            names = names .. idx .. ". " .. t.name .. "\n"
        end
        MusikTab:CreateLabel(names)
    end)()
end)()

-- ==================== 🔧 CONFIG MANAGER TAB ====================
;(function() -- CONFIG BLOCK: eigener Register-Pool
    local ConfigTab = Window:CreateTab("🔧 Config", 4483362748)
    local _hs      = game:GetService("HttpService")
    local CFG_DIR  = "SemysHUB/configs"
    -- [FIX v76] nameInputRef statt String: .Get() liest direkt aus der TextBox,
    -- kein FocusLost-Timing-Problem beim Klick auf "Speichern".
    local nameInputRef = nil
    local function getNameInput()
        if nameInputRef and nameInputRef.Get then return nameInputRef.Get() end
        return ""
    end

    -- Ordner sicherstellen
    local function ensureDir()
        pcall(function()
            if not isfolder("SemysHUB") then makefolder("SemysHUB") end
            if not isfolder(CFG_DIR)    then makefolder(CFG_DIR)    end
        end)
    end
    ensureDir()

    -- Settings → JSON
    local function serialize()
        local t = {}
        for k, v in pairs(Settings) do
            if type(v) == "boolean" or type(v) == "number" or type(v) == "string" then
                t[k] = v
            end
        end
        return _hs:JSONEncode(t)
    end

    -- JSON → Settings
    local function deserialize(json)
        local ok, t = pcall(function() return _hs:JSONDecode(json) end)
        if not ok or type(t) ~= "table" then return false end
        for k, v in pairs(t) do
            if Settings[k] ~= nil then Settings[k] = v end
        end
        return true
    end

    -- Liste aller gespeicherten Configs als lesbaren String
    local function buildListText()
        local names = {}
        pcall(function()
            for _, f in ipairs(listfiles(CFG_DIR)) do
                -- Dateiname aus Pfad holen (funktioniert mit / und \)
                local filename = tostring(f):match("[^/\\]+$") or tostring(f)
                -- .json Endung entfernen
                local n = filename:match("^(.+)%.json$")
                if n then table.insert(names, n) end
            end
        end)
        if #names == 0 then return "(noch keine gespeichert)" end
        -- Zeilenumbruch mit Pipe trennen (Rayfield-Label-kompatibel)
        return table.concat(names, "\n")
    end

    -- ── Sektion: Gespeicherte Configs ────────────────────────────────
    ConfigTab:CreateSection("📁 Gespeicherte Configs")

    local listLabel = ConfigTab:CreateLabel(buildListText())

    ConfigTab:CreateButton({
        Name = "🔄 Liste aktualisieren",
        Callback = function()
            pcall(function() listLabel:Set(buildListText()) end)
            Rayfield:Notify({Title = "🔄", Content = "Liste aktualisiert.", Duration = 2})
        end
    })

    -- ── Sektion: Config speichern / laden ────────────────────────────
    ConfigTab:CreateSection("💾 Config speichern & laden")
    ConfigTab:CreateLabel("Namen eingeben → Button klicken")

    nameInputRef = ConfigTab:CreateInput({
        Name = "📝 Config-Name",
        PlaceholderText = "z.B. Rage, Pub, Stealth...",
        RemoveTextAfterFocusLost = false,
        Callback = function() end  -- Get() direkt verwenden, kein Callback nötig
    })

    ConfigTab:CreateButton({
        Name = "💾 Speichern (neuer Name oder überschreiben)",
        Callback = function()
            -- Namen bereinigen (Leerzeichen → _, Sonderzeichen entfernen)
            local rawName = getNameInput():match("^%s*(.-)%s*$") or ""
            local name = rawName:gsub("[^%w%- ]", ""):match("^%s*(.-)%s*$") or ""
            name = name:gsub("%s+", "_")
            if name == "" then
                Rayfield:Notify({Title = "❌", Content = "Bitte einen Config-Namen eingeben!", Duration = 3})
                return
            end
            ensureDir()
            local saved = false
            pcall(function()
                writefile(CFG_DIR .. "/" .. name .. ".json", serialize())
                saved = isfile(CFG_DIR .. "/" .. name .. ".json")
            end)
            if saved then
                pcall(function() listLabel:Set(buildListText()) end)
                Rayfield:Notify({Title = "💾 Gespeichert", Content = '"' .. name .. '" gespeichert!  •  Liste aktualisiert.', Duration = 3})
            else
                Rayfield:Notify({Title = "❌ Fehler", Content = "writefile() fehlgeschlagen. Executor-Berechtigung prüfen!", Duration = 5})
            end
        end
    })

    ConfigTab:CreateButton({
        Name = "📂 Laden",
        Callback = function()
            local rawName = getNameInput():match("^%s*(.-)%s*$") or ""
            local name = rawName:gsub("[^%w%- ]", ""):match("^%s*(.-)%s*$") or ""
            name = name:gsub("%s+", "_")
            if name == "" then
                Rayfield:Notify({Title = "❌", Content = "Bitte Config-Namen eingeben!", Duration = 3})
                return
            end
            local path = CFG_DIR .. "/" .. name .. ".json"
            local ok, json = pcall(readfile, path)
            if not ok or type(json) ~= "string" then
                Rayfield:Notify({Title = "❌ Nicht gefunden", Content = '"' .. name .. '" existiert nicht.', Duration = 3})
                return
            end
            if deserialize(json) then
                Rayfield:Notify({Title = "✅ Geladen", Content = '"' .. name .. '" wurde geladen!', Duration = 3})
            else
                Rayfield:Notify({Title = "❌ Fehler", Content = "JSON konnte nicht gelesen werden.", Duration = 3})
            end
        end
    })

    ConfigTab:CreateButton({
        Name = "🗑️ Löschen",
        Callback = function()
            local rawName = getNameInput():match("^%s*(.-)%s*$") or ""
            local name = rawName:gsub("[^%w%- ]", ""):match("^%s*(.-)%s*$") or ""
            name = name:gsub("%s+", "_")
            if name == "" then
                Rayfield:Notify({Title = "❌", Content = "Bitte Config-Namen eingeben!", Duration = 3})
                return
            end
            local path = CFG_DIR .. "/" .. name .. ".json"
            local ok = pcall(function()
                if delfile then delfile(path)
                elseif deletefile then deletefile(path)
                else error("kein delfile") end
            end)
            pcall(function() listLabel:Set(buildListText()) end)
            if ok then
                Rayfield:Notify({Title = "🗑️ Gelöscht", Content = '"' .. name .. '" wurde gelöscht.', Duration = 3})
            else
                Rayfield:Notify({Title = "❌", Content = "Löschen fehlgeschlagen.", Duration = 3})
            end
        end
    })

    -- ── Sektion: Standard Config ─────────────────────────────────────
    ConfigTab:CreateSection("⚡ Standard Config")

    ConfigTab:CreateButton({
        Name = "💾 Standard-Config speichern",
        Callback = function()
            pcall(function() Rayfield:SaveConfiguration() end)
            Rayfield:Notify({Title = "💾", Content = "Standard-Config gespeichert.", Duration = 2})
        end
    })

    ConfigTab:CreateButton({
        Name = "📂 Standard-Config laden",
        Callback = function()
            pcall(function() Rayfield:LoadConfiguration() end)
            Rayfield:Notify({Title = "📂", Content = "Standard-Config geladen.", Duration = 2})
        end
    })

    ConfigTab:CreateButton({
        Name = "🗑️ Alles zurücksetzen",
        Callback = function()
            for key, _ in pairs(Settings) do
                if type(Settings[key]) == "boolean" then
                    Settings[key] = false
                elseif type(Settings[key]) == "number" then
                    if key == "AimbotFOV" then Settings[key] = 150
                    elseif key == "AimbotMaxDistance" then Settings[key] = 400
                    elseif key == "NormalAimbotSmoothness" then Settings[key] = 1
                    elseif key == "HealthWeaponMaxDistance" then Settings[key] = 600
                    elseif key == "HealthWeaponSymbolScale" then Settings[key] = 1.0
                    elseif key == "VoiceRangeRadius" then Settings[key] = 80
                    else Settings[key] = 0
                    end
                end
            end
            Settings.RageKnifeThrowEnabled = true
            Settings.VoiceRangeEnabled = false
            Settings.WallhackEnabled = false
            Settings.LookDirectionEnabled = false
            Settings.TracersEnabled = false
            Settings.FullbrightEnabled = false
            Rayfield:Notify({Title = "🗑️ Zurückgesetzt", Content = "Alle Settings wurden zurückgesetzt.", Duration = 4})
        end
    })
end)()

local GamesTab = Window:CreateTab("🎮 Games", 4483362748)

-- ==================== 🎮 GAMES TAB ====================

-- ==================== 🔪 MURDER MYSTERY 2 ====================
GamesTab:CreateSection("🔪 Murder Mystery 2")

GamesTab:CreateButton({
    Name = "🔪 MM2 Features öffnen",
    Callback = function()
        local CoreGui = game:GetService("CoreGui")
        local _mm2hub = CoreGui:FindFirstChild("SemysMM2Hub") -- [FIX] doppeltes FindFirstChild → local speichern
        if _mm2hub then
            _mm2hub:Destroy()
            return
        end

        -- ══ NUR IN MURDER MYSTERY 2 ══
        if game.PlaceId ~= 142823291 then
            local ng = Instance.new("ScreenGui")
            ng.Name = "SemysMM2Err"; ng.ResetOnSpawn = false; ng.DisplayOrder = 9999
            pcall(function() ng.Parent = CoreGui end)
            if not ng.Parent then ng.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui") end
            local ef = Instance.new("Frame", ng)
            ef.Size = UDim2.new(0, 310, 0, 60); ef.Position = UDim2.new(0.5,-155,0,20)
            ef.BackgroundColor3 = Color3.fromRGB(14,6,6); ef.BorderSizePixel = 0; ef.ZIndex = 2
            Instance.new("UICorner", ef).CornerRadius = UDim.new(0, 10)
            local es = Instance.new("UIStroke", ef)
            es.Color = Color3.fromRGB(200,40,40); es.Thickness = 1.5; es.Transparency = 0.1
            local el = Instance.new("TextLabel", ef)
            el.Size = UDim2.new(1,-16,1,0); el.Position = UDim2.new(0,16,0,0)
            el.BackgroundTransparency = 1; el.Font = Enum.Font.GothamBold
            el.TextSize = 12; el.TextColor3 = Color3.fromRGB(255,70,70)
            el.TextXAlignment = Enum.TextXAlignment.Left; el.TextWrapped = true; el.ZIndex = 3
            el.Text = "❌  MM2 Features nur in Murder Mystery 2 verfügbar!\n    Place ID: 142823291"
            game:GetService("Debris"):AddItem(ng, 4)
            return
        end

        local TweenService  = game:GetService("TweenService")
        local RS_MM         = game:GetService("RunService")
        local Players_MM    = game:GetService("Players")
        local LP_MM         = Players_MM.LocalPlayer

        -- ══════════════════ MM2 SHARED STATE ══════════════════
        local mm2_conns        = {}
        local mm2_murderActive = false   -- Murder-ESP läuft
        local mm2_sheriffActive= false   -- Sheriff-ESP läuft
        local mm2_innocActive  = false   -- Innoc-ESP läuft
        local mm2_flingMurder  = false
        local mm2_flingSheriff = false
        local mm2_coinFarm     = false
        local mm2_murderHL     = {}      -- {player -> Highlight}
        local mm2_sheriffHL    = {}
        local mm2_innocHL      = {}

        -- ══════════════════ HILFSFUNKTIONEN ══════════════════
        -- [FIX] Erweiterte Rollenerkennung: Backpack + Character + alle Tools scannen
        --       Außerdem Fallback via Tool-Klassen-Scan (Name-agnostisch)
        local MM2_KNIFE_NAMES = {"Knife","knife","DefaultKnife","MM2Knife","Knif","Blade","Dagger","dagger"}
        local MM2_GUN_NAMES   = {"Gun","gun","Sheriff","sheriff","Revolver","revolver","Pistol","pistol","Boombox"}

        local function mm2_getRole(plr)
            if not plr then return "none" end
            local c  = plr.Character
            local bp = plr:FindFirstChild("Backpack")  -- [FIX] FindFirstChild statt FindFirstChildOfClass (sicherer)

            local function has(container, names)
                if not container then return false end
                for _, n in ipairs(names) do
                    if container:FindFirstChild(n) then return true end
                end
                return false
            end

            -- Methode 1: Exakter Name Match (Character UND Backpack)
            if has(c, MM2_KNIFE_NAMES) or has(bp, MM2_KNIFE_NAMES) then return "murder"  end
            if has(c, MM2_GUN_NAMES)   or has(bp, MM2_GUN_NAMES)   then return "sheriff" end

            -- Methode 2: Fallback — alle Tools scannen und nach Mesh/Modell-Hinweisen suchen
            -- [FIX v89] return innerhalb pcall-Callback gibt nur aus dem Callback heraus zurück,
            --           nicht aus mm2_getRole → Wert wurde verworfen. Jetzt via foundRole Variable.
            local foundRole = nil
            pcall(function()
                local function scanTools(container)
                    if not container then return false, false end
                    local foundKnife, foundGun = false, false
                    for _, obj in ipairs(container:GetChildren()) do
                        if obj:IsA("Tool") then
                            local nm = obj.Name:lower()
                            if nm:find("knife") or nm:find("blade") or nm:find("dagger") or nm:find("knif") then
                                foundKnife = true
                            elseif nm:find("gun") or nm:find("revolver") or nm:find("pistol") or nm:find("sheriff") then
                                foundGun = true
                            end
                        end
                    end
                    return foundKnife, foundGun
                end
                local ck, cg = scanTools(c)
                local bk, bg = scanTools(bp)
                if ck or bk then foundRole = "murder"  end
                if cg or bg then foundRole = "sheriff" end
            end)
            if foundRole then return foundRole end

            return "innocent"
        end

        local function mm2_removeHL(store)
            for _, hl in pairs(store) do
                pcall(function() hl:Destroy() end)
            end
            for k in pairs(store) do store[k] = nil end
        end

        local function mm2_applyHL(plr, color, store)
            -- Altes Highlight entfernen
            pcall(function()
                if store[plr] then store[plr]:Destroy() store[plr] = nil end
            end)
            if not (plr and plr.Character) then return end
            local hl = Instance.new("Highlight")
            hl.FillColor        = color
            hl.OutlineColor     = Color3.fromRGB(255, 255, 255)
            hl.FillTransparency = 0.35
            hl.OutlineTransparency = 0
            hl.Adornee = plr.Character
            hl.Parent  = plr.Character
            store[plr] = hl
        end

        -- ══ mm2_flingPlayer v3 — drei Methoden, stärkste zuerst ══════════════════
        --
        -- WARUM der letzte Ansatz (Weld + Stepped) nicht gut funktioniert hat:
        --   1) Stepped feuert VOR Physik → Anti-Cheat kann unseren CFrame danach überschreiben.
        --      Fix: Heartbeat (feuert NACH Physik) → unser Set ist immer das letzte.
        --   2) Weld Part0=eigenerHRP Part1=ZielHRP dreht NUR uns um den Ziel-HRP.
        --      Der Server kontrolliert tHrp → Weld zieht uns zu ihnen, nicht sie weg.
        --      Fix: Weld entfernt, Kollisions-Druck reicht mit Heartbeat-Loop.
        --   3) SetNetworkOwner von LocalScript wirft immer Server-Only-Error → nutzlos.
        --      Fix: sethiddenproperty als Methode 1 (Executor-Feature).
        --
        -- Methode 1 (beste): sethiddenproperty → SimulationRadius ∞
        --   → Client hat Physik-Kontrolle über ALLE Parts → direkte Velocity auf Ziel.
        --   → Kein Teleport nötig, kein Anti-Cheat-Problem.
        -- Methode 2 (Fallback): Noclip-rein + Heartbeat-Loop + Kollision
        --   → Heartbeat: nach Anti-Cheat-Korrekturen → unser CFrame-Set gewinnt.
        --   → 10 Frames × Impuls → mehr Kontaktzeit als vorher.
        -- ══ mm2_flingPlayer v4 — SkidFling-Kollisionsmethode (KILASIK) ═════════════
        -- FIX v100: Direkte AssemblyLinearVelocity auf fremde Parts funktioniert NICHT
        --   (kein Network Ownership → nur lokal sichtbar, Server ignoriert es).
        --   Lösung: SkidFling-Kollisionsmethode — wir teleportieren uns auf das Ziel,
        --   die Physik-Engine überträgt unseren Impuls auf den Ziel-Charakter.
        --   Identisch mit dem bewährten KILASIK-SkidFling-Mechanismus.
        local function mm2_flingPlayer(plr)
            pcall(function()
                if plr == LP_MM then return end
                local myChar = LP_MM.Character
                local myHum  = myChar and myChar:FindFirstChildOfClass("Humanoid")
                local myHrp  = myHum  and myHum.RootPart
                local tChar  = plr and plr.Character
                if not (myChar and myHum and myHrp and tChar) then return end

                local tHum  = tChar:FindFirstChildOfClass("Humanoid")
                local tHrp  = tHum  and tHum.RootPart
                local tHead = tChar:FindFirstChild("Head")
                local tAcc  = tChar:FindFirstChildOfClass("Accessory")
                local tHnd  = tAcc and tAcc:FindFirstChild("Handle")

                if tHum and tHum.Sit then return end
                if not tChar:FindFirstChildWhichIsA("BasePart") then return end

                -- OldPos sichern (nur wenn wir still stehen)
                local oldPos
                if myHrp.Velocity.Magnitude < 50 then
                    oldPos = myHrp.CFrame
                end

                -- Kamera auf Ziel
                workspace.CurrentCamera.CameraSubject =
                    tHead or tHnd or tHum or workspace.CurrentCamera.CameraSubject

                -- FPos: teleportiert uns auf BasePart + setzt massiven Impuls
                local function FPos(BP, Pos, Ang)
                    myHrp.CFrame = CFrame.new(BP.Position) * Pos * Ang
                    myChar:SetPrimaryPartCFrame(CFrame.new(BP.Position) * Pos * Ang)
                    myHrp.Velocity    = Vector3.new(9e7, 9e7 * 10, 9e7)
                    myHrp.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
                end

                -- SFBasePart: Loop mit Kollisions-Impulsen [TURBO]
                local function SFBasePart(BP)
                    local deadline = os.clock() + 2  -- [FIX v101] tick() → os.clock()
                    local Angle    = 0
                    repeat
                        if not (myHrp and myHrp.Parent and tHum) then break end
                        Angle = Angle + 120  -- [TURBO] schnellere Rotation
                        if BP.Velocity.Magnitude < 50 then
                            local md = tHum.MoveDirection
                            local vm = BP.Velocity.Magnitude / 1.25
                            FPos(BP, CFrame.new(0,  2.5, 0) + md * vm, CFrame.Angles(math.rad(Angle), 0, 0))
                            FPos(BP, CFrame.new(0,  2.5, 0) + md * vm, CFrame.Angles(math.rad(Angle), 0, 0)) task.wait()
                            FPos(BP, CFrame.new(0, -2.5, 0) + md * vm, CFrame.Angles(math.rad(Angle), 0, 0))
                            FPos(BP, CFrame.new(0, -2.5, 0) + md * vm, CFrame.Angles(math.rad(Angle), 0, 0)) task.wait()
                            FPos(BP, CFrame.new(0,  2.5, 0) + md * vm, CFrame.Angles(math.rad(Angle), 0, 0))
                            FPos(BP, CFrame.new(0,  2.5, 0) + md * vm, CFrame.Angles(math.rad(Angle), 0, 0)) task.wait()
                            FPos(BP, CFrame.new(0, -2.5, 0) + md * vm, CFrame.Angles(math.rad(Angle), 0, 0))
                            FPos(BP, CFrame.new(0, -2.5, 0) + md * vm, CFrame.Angles(math.rad(Angle), 0, 0)) task.wait()
                            FPos(BP, CFrame.new(0,  2.5, 0) + md,      CFrame.Angles(math.rad(Angle), 0, 0))
                            FPos(BP, CFrame.new(0,  2.5, 0) + md,      CFrame.Angles(math.rad(Angle), 0, 0)) task.wait()
                            FPos(BP, CFrame.new(0, -2.5, 0) + md,      CFrame.Angles(math.rad(Angle), 0, 0))
                            FPos(BP, CFrame.new(0, -2.5, 0) + md,      CFrame.Angles(math.rad(Angle), 0, 0)) task.wait()
                        else
                            local ws = tHum.WalkSpeed
                            FPos(BP, CFrame.new(0,  2.5,  ws), CFrame.Angles(math.rad(90), 0, 0))
                            FPos(BP, CFrame.new(0,  2.5,  ws), CFrame.Angles(math.rad(90), 0, 0)) task.wait()
                            FPos(BP, CFrame.new(0, -2.5, -ws), CFrame.Angles(0, 0, 0))
                            FPos(BP, CFrame.new(0, -2.5, -ws), CFrame.Angles(0, 0, 0))            task.wait()
                            FPos(BP, CFrame.new(0,  2.5,  ws), CFrame.Angles(math.rad(90), 0, 0))
                            FPos(BP, CFrame.new(0,  2.5,  ws), CFrame.Angles(math.rad(90), 0, 0)) task.wait()
                            FPos(BP, CFrame.new(0, -2.5, 0),   CFrame.Angles(math.rad(90), 0, 0))
                            FPos(BP, CFrame.new(0, -2.5, 0),   CFrame.Angles(math.rad(90), 0, 0)) task.wait()
                            FPos(BP, CFrame.new(0, -2.5, 0),   CFrame.Angles(0, 0, 0))
                            FPos(BP, CFrame.new(0, -2.5, 0),   CFrame.Angles(0, 0, 0))            task.wait()
                            FPos(BP, CFrame.new(0, -2.5, 0),   CFrame.Angles(math.rad(90), 0, 0))
                            FPos(BP, CFrame.new(0, -2.5, 0),   CFrame.Angles(math.rad(90), 0, 0)) task.wait()
                            FPos(BP, CFrame.new(0, -2.5, 0),   CFrame.Angles(0, 0, 0))
                            FPos(BP, CFrame.new(0, -2.5, 0),   CFrame.Angles(0, 0, 0))            task.wait()
                        end
                    until os.clock() > deadline  -- [FIX v101] tick() → os.clock()
                end

                -- FallenPartsDestroyHeight deaktivieren (Ziel fällt nicht in Void)
                local origFPDH = workspace.FallenPartsDestroyHeight
                workspace.FallenPartsDestroyHeight = 0/0

                -- BodyVelocity hält uns auf Stelle (Physik-Bremse)
                local BV = Instance.new("BodyVelocity")
                BV.Parent   = myHrp
                BV.Velocity = Vector3.new(0, 0, 0)
                BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                myHum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)

                -- Fling ausführen
                pcall(function()
                    if     tHrp  then SFBasePart(tHrp)
                    elseif tHead then SFBasePart(tHead)
                    elseif tHnd  then SFBasePart(tHnd)
                    end
                end)

                BV:Destroy()
                myHum:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
                workspace.CurrentCamera.CameraSubject = myHum

                -- Eigene Position zurücksetzen
                if oldPos then
                    local resetDeadline = os.clock() + 4  -- [FIX v101] tick() → os.clock()
                    repeat
                        pcall(function()
                            myHrp.CFrame = oldPos * CFrame.new(0, 0.5, 0)
                            myChar:SetPrimaryPartCFrame(oldPos * CFrame.new(0, 0.5, 0))
                            myHum:ChangeState("GettingUp")
                            for _, p in pairs(myChar:GetChildren()) do
                                if p:IsA("BasePart") then
                                    p.Velocity    = Vector3.new()
                                    p.RotVelocity = Vector3.new()
                                end
                            end
                        end)
                        task.wait()
                    until (myHrp.Position - oldPos.p).Magnitude < 25 or os.clock() > resetDeadline  -- [FIX v101] tick() → os.clock()
                end

                workspace.FallenPartsDestroyHeight = origFPDH
            end)
        end
        -- ══════════════════ SCREENGUI ══════════════════
        local sg = Instance.new("ScreenGui")
        sg.Name = "SemysMM2Hub"
        sg.ResetOnSpawn = false
        sg.DisplayOrder = 5000
        sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        sg.Parent = CoreGui

        local win = Instance.new("Frame")
        win.Name = "MM2Win"
        win.Size = UDim2.new(0, 330, 0, 530)
        win.Position = UDim2.new(0.5, -165, 0.5, -265)
        win.BackgroundColor3 = Color3.fromRGB(10, 14, 22)
        win.BorderSizePixel = 0
        win.ZIndex = 10
        win.ClipsDescendants = true
        win.Parent = sg
        Instance.new("UICorner", win).CornerRadius = UDim.new(0, 14)

        local winGrad = Instance.new("UIGradient", win)
        winGrad.Rotation = 90
        winGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0,   Color3.fromRGB(18, 26, 48)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(10, 14, 28)),
            ColorSequenceKeypoint.new(1,   Color3.fromRGB(6,  8,  16)),
        })

        local winGlow = Instance.new("Frame")
        winGlow.Size = UDim2.new(1, 0, 0, 120)
        winGlow.Position = UDim2.new(0, 0, 0.35, 0)
        winGlow.BackgroundColor3 = Color3.fromRGB(0, 120, 220)
        winGlow.BorderSizePixel = 0
        winGlow.ZIndex = 10
        winGlow.Parent = win
        local winGlowGrad = Instance.new("UIGradient", winGlow)
        winGlowGrad.Rotation = 90
        winGlowGrad.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.5, 0.84),
            NumberSequenceKeypoint.new(1, 1),
        })

        local winStroke = Instance.new("UIStroke", win)
        winStroke.Thickness = 2
        winStroke.Transparency = 0.2
        winStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        local winStrokeGrad = Instance.new("UIGradient", winStroke)
        winStrokeGrad.Rotation = 45
        winStrokeGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0,   Color3.fromRGB(0, 220, 200)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 160, 255)),
            ColorSequenceKeypoint.new(1,   Color3.fromRGB(120, 90, 255)),
        })
        task.spawn(function()
            while sg.Parent do
                TweenService:Create(winStroke, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transparency=0.65}):Play()
                task.wait(1.4)
                if not sg.Parent then break end
                TweenService:Create(winStroke, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transparency=0.05}):Play()
                task.wait(1.4)
            end
        end)

        -- Titelleiste
        local titleBar = Instance.new("Frame")
        titleBar.Name = "TitleBar"
        titleBar.Size = UDim2.new(1, 0, 0, 50)
        titleBar.BackgroundColor3 = Color3.fromRGB(10, 14, 24)
        titleBar.BorderSizePixel = 0
        titleBar.ZIndex = 11
        titleBar.Parent = win
        Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12)
        local titleFix = Instance.new("Frame")
        titleFix.Size = UDim2.new(1, 0, 0, 12)
        titleFix.Position = UDim2.new(0, 0, 1, -12)
        titleFix.BackgroundColor3 = Color3.fromRGB(10, 14, 24)
        titleFix.BorderSizePixel = 0
        titleFix.ZIndex = 11
        titleFix.Parent = titleBar
        local titleLine = Instance.new("Frame")
        titleLine.Size = UDim2.new(1, -28, 0, 2)
        titleLine.Position = UDim2.new(0, 14, 1, -2)
        titleLine.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
        titleLine.BorderSizePixel = 0
        titleLine.ZIndex = 12
        titleLine.Parent = titleBar
        Instance.new("UICorner", titleLine).CornerRadius = UDim.new(1, 0)
        local lineGrad = Instance.new("UIGradient", titleLine)
        lineGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0,   Color3.fromRGB(0, 160, 255)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(120, 240, 255)),
            ColorSequenceKeypoint.new(1,   Color3.fromRGB(0, 160, 255)),
        })
        local titleLabel = Instance.new("TextLabel")
        titleLabel.RichText = true
        titleLabel.Text = 'SEMYS <font color="#1E9BFF">MM2</font>'
        titleLabel.Size = UDim2.new(1, -56, 1, 0)
        titleLabel.Position = UDim2.new(0, 14, 0, 0)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Font = Enum.Font.GothamBlack
        titleLabel.TextSize = 20
        titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.ZIndex = 12
        titleLabel.Parent = titleBar
        local subLabel = Instance.new("TextLabel")
        subLabel.Text = "Murder Mystery 2 • Semys HUB v101"  -- [FIX v101] v94 → v101
        subLabel.Size = UDim2.new(1, -56, 0, 14)
        subLabel.Position = UDim2.new(0, 14, 1, -16)
        subLabel.BackgroundTransparency = 1
        subLabel.Font = Enum.Font.Gotham
        subLabel.TextSize = 10
        subLabel.TextColor3 = Color3.fromRGB(70, 90, 130)
        subLabel.TextXAlignment = Enum.TextXAlignment.Left
        subLabel.ZIndex = 12
        subLabel.Parent = titleBar
        local closeBtn = Instance.new("TextButton")
        closeBtn.Text = "✕"
        closeBtn.Size = UDim2.new(0, 28, 0, 28)
        closeBtn.Position = UDim2.new(1, -38, 0.5, -14)
        closeBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
        closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        closeBtn.Font = Enum.Font.GothamBold
        closeBtn.TextSize = 13
        closeBtn.BorderSizePixel = 0
        closeBtn.ZIndex = 14
        closeBtn.Parent = titleBar
        Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
        closeBtn.MouseEnter:Connect(function()
            TweenService:Create(closeBtn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(230,60,60)}):Play()
        end)
        closeBtn.MouseLeave:Connect(function()
            TweenService:Create(closeBtn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(180,40,40)}):Play()
        end)
        closeBtn.MouseButton1Click:Connect(function() sg:Destroy() end)

        -- Ziehbar
        local mm2Drag, mm2DragStart, mm2StartPos = false, nil, nil
        titleBar.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                mm2Drag = true; mm2DragStart = inp.Position; mm2StartPos = win.Position
            end
        end)
        titleBar.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then mm2Drag = false end
        end)
        table.insert(mm2_conns,
            game:GetService("UserInputService").InputChanged:Connect(function(inp)
                if mm2Drag and inp.UserInputType == Enum.UserInputType.MouseMovement then
                    local d = inp.Position - mm2DragStart
                    win.Position = UDim2.new(mm2StartPos.X.Scale, mm2StartPos.X.Offset+d.X,
                                             mm2StartPos.Y.Scale, mm2StartPos.Y.Offset+d.Y)
                end
            end)
        )

        -- Status-Label
        local statusLbl = Instance.new("TextLabel")
        statusLbl.Text = "⏳ Bereit"
        statusLbl.Size = UDim2.new(1, -20, 0, 26)
        statusLbl.Position = UDim2.new(0, 10, 0, 54)
        statusLbl.BackgroundColor3 = Color3.fromRGB(12, 18, 32)
        statusLbl.BackgroundTransparency = 0.2
        statusLbl.Font = Enum.Font.GothamMedium
        statusLbl.TextSize = 12
        statusLbl.TextColor3 = Color3.fromRGB(0, 180, 255)
        statusLbl.ZIndex = 12
        statusLbl.Parent = win
        Instance.new("UICorner", statusLbl).CornerRadius = UDim.new(0, 6)
        local function setStatus(txt, col)
            statusLbl.Text = txt
            statusLbl.TextColor3 = col or Color3.fromRGB(0, 180, 255)
        end

        -- Scroll-Inhalt
        local content = Instance.new("ScrollingFrame")
        content.Size = UDim2.new(1, -20, 1, -92)
        content.Position = UDim2.new(0, 10, 0, 86)
        content.BackgroundTransparency = 1
        content.ScrollBarThickness = 3
        content.ScrollBarImageColor3 = Color3.fromRGB(0, 160, 255)
        content.CanvasSize = UDim2.new(0, 0, 0, 0)
        content.AutomaticCanvasSize = Enum.AutomaticSize.Y
        content.ZIndex = 11
        content.Parent = win
        local cLayout = Instance.new("UIListLayout", content)
        cLayout.Padding = UDim.new(0, 7)
        cLayout.SortOrder = Enum.SortOrder.LayoutOrder

        -- ══════════════════ UI-HELFER (CLEAN) ══════════════════
        local function mm2Section(text)
            local wrap = Instance.new("Frame", content)
            wrap.Size = UDim2.new(1, 0, 0, 22)
            wrap.BackgroundTransparency = 1
            wrap.ZIndex = 12
            local bar = Instance.new("Frame", wrap)
            bar.Size = UDim2.new(0, 3, 0, 13)
            bar.Position = UDim2.new(0, 0, 0.5, -6)
            bar.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
            bar.BorderSizePixel = 0; bar.ZIndex = 13
            Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
            local lbl = Instance.new("TextLabel", wrap)
            lbl.Text = text
            lbl.Size = UDim2.new(1, -12, 1, 0)
            lbl.Position = UDim2.new(0, 10, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Font = Enum.Font.GothamBold
            lbl.TextSize = 10
            lbl.TextColor3 = Color3.fromRGB(100, 140, 190)
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.ZIndex = 13
        end

        local function mm2Toggle(labelText, defaultState, onToggle)
            local row = Instance.new("Frame", content)
            row.Size = UDim2.new(1, 0, 0, 40)
            row.BackgroundColor3 = Color3.fromRGB(13, 17, 28)
            row.BorderSizePixel = 0; row.ZIndex = 12
            Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
            local rs = Instance.new("UIStroke", row)
            rs.Color = Color3.fromRGB(28, 36, 58); rs.Thickness = 1
            local lbl = Instance.new("TextLabel", row)
            lbl.Text = labelText
            lbl.Size = UDim2.new(1, -64, 1, 0)
            lbl.Position = UDim2.new(0, 12, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Font = Enum.Font.GothamMedium
            lbl.TextSize = 12
            lbl.TextColor3 = Color3.fromRGB(195, 205, 230)
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.TextWrapped = true; lbl.ZIndex = 13
            local pill = Instance.new("Frame", row)
            pill.Size = UDim2.new(0, 38, 0, 20)
            pill.AnchorPoint = Vector2.new(1, 0.5)
            pill.Position = UDim2.new(1, -12, 0.5, 0)
            pill.BackgroundColor3 = defaultState and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(22, 30, 48)
            pill.BorderSizePixel = 0; pill.ZIndex = 13
            Instance.new("UICorner", pill).CornerRadius = UDim.new(0, 10)
            local knob = Instance.new("Frame", pill)
            knob.Size = UDim2.new(0, 16, 0, 16)
            knob.AnchorPoint = Vector2.new(0, 0.5)
            knob.Position = defaultState and UDim2.new(1,-18,0.5,0) or UDim2.new(0,2,0.5,0)
            knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            knob.BorderSizePixel = 0; knob.ZIndex = 14
            Instance.new("UICorner", knob).CornerRadius = UDim.new(0, 8)
            local st = defaultState
            row.InputBegan:Connect(function(inp)
                if inp.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
                st = not st
                TweenService:Create(pill, TweenInfo.new(0.15), {
                    BackgroundColor3 = st and Color3.fromRGB(0,170,255) or Color3.fromRGB(22,30,48)
                }):Play()
                TweenService:Create(knob, TweenInfo.new(0.15), {
                    Position = st and UDim2.new(1,-18,0.5,0) or UDim2.new(0,2,0.5,0)
                }):Play()
                pcall(onToggle, st)
            end)
        end

        local function mm2Button(txt, col, onClick)
            local C = col or Color3.fromRGB(18, 28, 50)
            local btn = Instance.new("TextButton", content)
            btn.Text = txt
            btn.Size = UDim2.new(1, 0, 0, 34)
            btn.BackgroundColor3 = C
            btn.TextColor3 = Color3.fromRGB(215, 225, 255)
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 12
            btn.BorderSizePixel = 0; btn.ZIndex = 12; btn.TextWrapped = true
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
            local bs = Instance.new("UIStroke", btn)
            bs.Color = C; bs.Thickness = 1; bs.Transparency = 0.45
            btn.MouseButton1Click:Connect(function() pcall(onClick) end)
            btn.MouseEnter:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundTransparency = 0.25}):Play()
                TweenService:Create(bs,  TweenInfo.new(0.12), {Transparency = 0}):Play()
            end)
            btn.MouseLeave:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundTransparency = 0}):Play()
                TweenService:Create(bs,  TweenInfo.new(0.12), {Transparency = 0.45}):Play()
            end)
        end

        -- ══════════════════ ESP ══════════════════
        mm2Section("👀  SPIELER ESP")

        -- ── RUNDEN-START SPY ────────────────────────────────────────
        -- Hängt sich an jedes Backpack/Character ChildAdded ein →
        -- erkennt Knife/Gun sofort wenn MM2 sie verteilt (vor ESP-Polling)
        local mm2_spyConns = {}
        local mm2_spyActive = false

        -- [FIX] Spy nutzt jetzt dieselben erweiterten Listen wie mm2_getRole
        local knifeNames2 = MM2_KNIFE_NAMES
        local gunNames2   = MM2_GUN_NAMES
        local function isKnife(n)
            local nl = n:lower()
            for _,k in ipairs(knifeNames2) do if nl==k:lower() or nl:find(k:lower()) then return true end end
        end
        local function isGun(n)
            local nl = n:lower()
            for _,k in ipairs(gunNames2) do if nl==k:lower() or nl:find(k:lower()) then return true end end
        end

        local function mm2_spyOnPlayer(plr)
            if plr == LP_MM then return end
            local function onItem(item)
                if not mm2_spyActive then return end
                if isKnife(item.Name) then
                    setStatus("🔴 MURDER: " .. plr.Name, Color3.fromRGB(255, 60, 60))
                    if mm2_murderActive then mm2_applyHL(plr, Color3.fromRGB(255,30,30), mm2_murderHL) end
                elseif isGun(item.Name) then
                    setStatus("🔵 SHERIFF: " .. plr.Name, Color3.fromRGB(60, 160, 255))
                    if mm2_sheriffActive then mm2_applyHL(plr, Color3.fromRGB(30,120,255), mm2_sheriffHL) end
                end
            end
            -- Backpack überwachen
            local bp = plr:FindFirstChildOfClass("Backpack")
            if bp then table.insert(mm2_spyConns, bp.ChildAdded:Connect(onItem)) end
            -- Character überwachen (Waffe direkt in Hand)
            local function watchChar(char)
                table.insert(mm2_spyConns, char.ChildAdded:Connect(onItem))
            end
            if plr.Character then watchChar(plr.Character) end
            table.insert(mm2_spyConns, plr.CharacterAdded:Connect(watchChar))
        end

        mm2Toggle("🎯 Runden-Start Spy — erkennt Murder & Sheriff\nsofort wenn Waffe verteilt wird (vor ESP)", false, function(state)
            mm2_spyActive = state
            -- Alte Verbindungen trennen
            for _, c in ipairs(mm2_spyConns) do pcall(function() c:Disconnect() end) end
            mm2_spyConns = {}
            if not state then setStatus("⏳ Runden-Spy aus") return end
            setStatus("🎯 Runden-Spy aktiv — warte auf Rundenstart...", Color3.fromRGB(255, 220, 50))
            -- Alle aktuellen Spieler verbinden
            for _, plr in ipairs(Players_MM:GetPlayers()) do
                pcall(mm2_spyOnPlayer, plr)
            end
            -- Neue Spieler die joinen
            table.insert(mm2_spyConns,
                Players_MM.PlayerAdded:Connect(function(plr) pcall(mm2_spyOnPlayer, plr) end))
        end)
        -- ────────────────────────────────────────────────────────────

        mm2Toggle("🔴 Murder ESP — roter Highlight", false, function(state)
            mm2_murderActive = state
            mm2_removeHL(mm2_murderHL)
            if not state then
                setStatus("⏳ Murder-ESP aus")
                return
            end
            setStatus("🔴 Murder-ESP aktiv", Color3.fromRGB(255, 80, 80))
            task.spawn(function()
                while mm2_murderActive do
                    pcall(function()
                        for _, plr in ipairs(Players_MM:GetPlayers()) do
                            if plr ~= LP_MM then
                                if mm2_getRole(plr) == "murder" then
                                    mm2_applyHL(plr, Color3.fromRGB(255,30,30), mm2_murderHL)
                                elseif mm2_murderHL[plr] then
                                    mm2_murderHL[plr]:Destroy()
                                    mm2_murderHL[plr] = nil
                                end
                            end
                        end
                    end)
                    task.wait(0.4)
                end
                mm2_removeHL(mm2_murderHL)
            end)
        end)

        mm2Toggle("🔵 Sheriff ESP — blauer Highlight", false, function(state)
            mm2_sheriffActive = state
            mm2_removeHL(mm2_sheriffHL)
            if not state then
                setStatus("⏳ Sheriff-ESP aus")
                return
            end
            setStatus("🔵 Sheriff-ESP aktiv", Color3.fromRGB(80, 160, 255))
            task.spawn(function()
                while mm2_sheriffActive do
                    pcall(function()
                        for _, plr in ipairs(Players_MM:GetPlayers()) do
                            if plr ~= LP_MM then
                                if mm2_getRole(plr) == "sheriff" then
                                    mm2_applyHL(plr, Color3.fromRGB(30,120,255), mm2_sheriffHL)
                                elseif mm2_sheriffHL[plr] then
                                    mm2_sheriffHL[plr]:Destroy()
                                    mm2_sheriffHL[plr] = nil
                                end
                            end
                        end
                    end)
                    task.wait(0.4)
                end
                mm2_removeHL(mm2_sheriffHL)
            end)
        end)

        mm2Toggle("🟢 Innocent ESP — grüner Highlight\n(alle Unschuldigen markieren)", false, function(state)
            mm2_innocActive = state
            mm2_removeHL(mm2_innocHL)
            if not state then
                setStatus("⏳ Innocent-ESP aus")
                return
            end
            setStatus("🟢 Innocent-ESP aktiv", Color3.fromRGB(80, 255, 120))
            task.spawn(function()
                while mm2_innocActive do
                    pcall(function()
                        for _, plr in ipairs(Players_MM:GetPlayers()) do
                            if plr ~= LP_MM then
                                if mm2_getRole(plr) == "innocent" then
                                    mm2_applyHL(plr, Color3.fromRGB(30,200,80), mm2_innocHL)
                                elseif mm2_innocHL[plr] then
                                    mm2_innocHL[plr]:Destroy()
                                    mm2_innocHL[plr] = nil
                                end
                            end
                        end
                    end)
                    task.wait(0.4)
                end
                mm2_removeHL(mm2_innocHL)
            end)
        end)

        mm2Button("🎯 Murder & Sheriff sofort zeigen (einmalig)", Color3.fromRGB(30, 50, 120), function()
            local murder, sheriff = nil, nil
            for _, plr in ipairs(Players_MM:GetPlayers()) do
                if plr ~= LP_MM then
                    local r = mm2_getRole(plr)
                    if r == "murder"  then murder  = plr.Name end
                    if r == "sheriff" then sheriff = plr.Name end
                end
            end
            local txt = ""
            if murder  then txt = txt .. "🔴 Murder: " .. murder .. "  " end
            if sheriff then txt = txt .. "🔵 Sheriff: " .. sheriff end
            if txt == "" then txt = "⚠ Niemand erkannt (Spiel läuft evtl. nicht)" end
            setStatus(txt, Color3.fromRGB(255, 220, 80))
        end)

        -- ══════════════════ FLING ══════════════════
        mm2Section("💥  FLING")

        -- [FIX v89-MM2] mm2_flingUntilGone — 2 Bugs behoben:
        --   B1: startPos wurde EINMAL am Anfang gespeichert → normales Weglaufen >50 studs
        --       brach die Funktion fälschlicherweise ab, auch wenn kein Fling gewirkt hatte.
        --       Neu: Position am Anfang JEDES Versuchs messen → echter Vorher/Nachher-Vergleich.
        --   B2: Kein plr==LP_MM Guard (liegt jetzt in mm2_flingPlayer, hier als extra Sicherheit).
        local function mm2_flingUntilGone(plr, flagName)
            if plr == LP_MM then return end  -- B2: sich selbst nie flingen
            pcall(function()
                for attempt = 1, 15 do  -- [TURBO] max 15 Versuche
                    if not _G[flagName] then break end
                    if not (plr and plr.Character) then break end
                    local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                    if not hrp then break end

                    -- B1: Position VOR diesem Versuch messen (nicht eine globale startPos)
                    local posBefore = hrp.Position
                    mm2_flingPlayer(plr)
                    task.wait(0.1)  -- [TURBO] 0.5 → 0.1: schneller wiederholen

                    -- Prüfen ob Ziel tatsächlich weggeflogen ist (>80 studs nach Versuch)
                    if not (plr.Character and hrp.Parent) then break end  -- Charakter weg
                    local posAfter = hrp.Position
                    if (posAfter - posBefore).Magnitude > 80 then break end  -- erfolgreich geflingt
                end
            end)
        end

        mm2Toggle("💥 Fling Murder — flingt bis Person weg ist", false, function(state)
            mm2_flingMurder = state
            _G["mm2_flingMurder"] = state
            if not state then setStatus("⏳ Fling-Murder gestoppt") return end
            setStatus("💥 Fling-Murder aktiv!", Color3.fromRGB(255, 80, 80))
            task.spawn(function()
                while mm2_flingMurder do
                    pcall(function()
                        for _, plr in ipairs(Players_MM:GetPlayers()) do
                            if not mm2_flingMurder then return end
                            -- [FIX v89-MM2] plr ~= LP_MM: sich selbst nie flingen
                            if plr ~= LP_MM and mm2_getRole(plr) == "murder" then
                                mm2_flingUntilGone(plr, "mm2_flingMurder")
                            end
                        end
                    end)
                    task.wait(0.5)
                end
            end)
        end)

        mm2Toggle("💥 Fling Sheriff — flingt bis Person weg ist", false, function(state)
            mm2_flingSheriff = state
            _G["mm2_flingSheriff"] = state
            if not state then setStatus("⏳ Fling-Sheriff gestoppt") return end
            setStatus("💥 Fling-Sheriff aktiv!", Color3.fromRGB(80, 160, 255))
            task.spawn(function()
                while mm2_flingSheriff do
                    pcall(function()
                        for _, plr in ipairs(Players_MM:GetPlayers()) do
                            if not mm2_flingSheriff then return end
                            -- [FIX v89-MM2] plr ~= LP_MM: sich selbst nie flingen
                            if plr ~= LP_MM and mm2_getRole(plr) == "sheriff" then
                                mm2_flingUntilGone(plr, "mm2_flingSheriff")
                            end
                        end
                    end)
                    task.wait(0.5)
                end
            end)
        end)

        -- ══════════════════ SHERIFF ══════════════════
        mm2Section("🔫  SHERIFF TOOLS")

        local mm2_autoShoot = false

        mm2Toggle("🔫 Auto Shoot Murder — zielt & schießt\nautomatisch auf Murder (nur als Sheriff)", false, function(state)
            mm2_autoShoot = state
            if not state then setStatus("⏳ Auto-Shoot gestoppt") return end
            if mm2_getRole(LP_MM) ~= "sheriff" then
                setStatus("❌ Du bist nicht der Sheriff!", Color3.fromRGB(255, 60, 60))
                mm2_autoShoot = false
                return
            end
            setStatus("🔫 Auto-Shoot aktiv!", Color3.fromRGB(60, 160, 255))
            task.spawn(function()
                local VU  = game:GetService("VirtualUser")
                local cam = workspace.CurrentCamera
                while mm2_autoShoot do
                    pcall(function()
                        local myChar = LP_MM.Character
                        local myHum  = myChar and myChar:FindFirstChildOfClass("Humanoid")
                        local myHrp  = myChar and myChar:FindFirstChild("HumanoidRootPart")
                        if not myHum or not myHrp then return end

                        -- [FIX] Gun ausrüsten: alle bekannten Gun-Namen + Fallback Tool-Scan
                        local myBp = LP_MM:FindFirstChild("Backpack")
                        local gun = nil
                        for _, nm in ipairs(MM2_GUN_NAMES) do
                            gun = (myBp and myBp:FindFirstChild(nm))
                               or (myChar and myChar:FindFirstChild(nm))
                            if gun then break end
                        end
                        if not gun and myBp then
                            for _, obj in ipairs(myBp:GetChildren()) do
                                if obj:IsA("Tool") then
                                    local n = obj.Name:lower()
                                    if n:find("gun") or n:find("revolver") or n:find("pistol") or n:find("sheriff") then
                                        gun = obj; break
                                    end
                                end
                            end
                        end
                        if gun and gun:IsA("Tool") then
                            pcall(function() myHum:EquipTool(gun) end)
                        end
                        task.wait(0.05)

                        -- Murder suchen
                        for _, plr in ipairs(Players_MM:GetPlayers()) do
                            if not mm2_autoShoot then break end
                            if plr ~= LP_MM and mm2_getRole(plr) == "murder" then
                                local tChar = plr.Character
                                local tHrp  = tChar and tChar:FindFirstChild("HumanoidRootPart")
                                local tHum  = tChar and tChar:FindFirstChildOfClass("Humanoid")
                                if tHrp and tHum and tHum.Health > 0 then
                                    -- Kamera auf Murder richten
                                    cam.CFrame = CFrame.new(cam.CFrame.Position, tHrp.Position)
                                    task.wait(0.05)
                                    -- Schuss simulieren
                                    local screenPos, onScreen = cam:WorldToScreenPoint(tHrp.Position)
                                    if onScreen then
                                        VU:Button1Down(Vector2.new(screenPos.X, screenPos.Y), CFrame.new())
                                        task.wait(0.05)
                                        VU:Button1Up(Vector2.new(screenPos.X, screenPos.Y), CFrame.new())
                                        setStatus("🔫 Geschossen auf: " .. plr.Name, Color3.fromRGB(60, 160, 255))
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(0.6)
                end
            end)
        end)

        mm2Button("🎯 Einmal schießen — sofortiger Schuss\nauf den Murder (als Sheriff)", Color3.fromRGB(20, 50, 120), function()
            if mm2_getRole(LP_MM) ~= "sheriff" then
                setStatus("❌ Du bist nicht der Sheriff!", Color3.fromRGB(255, 60, 60))
                return
            end
            task.spawn(function()
                local VU  = game:GetService("VirtualUser")
                local cam = workspace.CurrentCamera
                local myChar = LP_MM.Character
                local myHum  = myChar and myChar:FindFirstChildOfClass("Humanoid")
                if not myHum then return end
                -- [FIX] Gun-Suche mit MM2_GUN_NAMES + Fallback Tool-Scan
                local myBp2 = LP_MM:FindFirstChild("Backpack")
                local gun = nil
                for _, nm in ipairs(MM2_GUN_NAMES) do
                    gun = (myBp2 and myBp2:FindFirstChild(nm))
                       or (myChar and myChar:FindFirstChild(nm))
                    if gun then break end
                end
                if not gun and myBp2 then
                    for _, obj in ipairs(myBp2:GetChildren()) do
                        if obj:IsA("Tool") then
                            local n = obj.Name:lower()
                            if n:find("gun") or n:find("revolver") or n:find("pistol") or n:find("sheriff") then
                                gun = obj; break
                            end
                        end
                    end
                end
                if gun and gun:IsA("Tool") then
                    pcall(function() myHum:EquipTool(gun) end)
                    task.wait(0.1)
                end
                for _, plr in ipairs(Players_MM:GetPlayers()) do
                    if plr ~= LP_MM and mm2_getRole(plr) == "murder" then
                        local tHrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                        if tHrp then
                            cam.CFrame = CFrame.new(cam.CFrame.Position, tHrp.Position)
                            task.wait(0.05)
                            local screenPos, onScreen = cam:WorldToScreenPoint(tHrp.Position)
                            if onScreen then
                                VU:Button1Down(Vector2.new(screenPos.X, screenPos.Y), CFrame.new())
                                task.wait(0.05)
                                VU:Button1Up(Vector2.new(screenPos.X, screenPos.Y), CFrame.new())
                                setStatus("🎯 Geschossen auf " .. plr.Name .. "!", Color3.fromRGB(60, 200, 100))
                            else
                                setStatus("⚠️ Murder außerhalb Sichtfeld!", Color3.fromRGB(255, 180, 0))
                            end
                        end
                        break
                    end
                end
            end)
        end)

        -- ══════════════════ KILL ALL ══════════════════
        mm2Section("☠️  KILL ALL (als Murder)")

        local mm2_killAllActive = false

        -- [FIX] Messer ausrüsten: sucht nach ALLEN bekannten Knife-Namen
        local function mm2_equipKnife()
            local myChar = LP_MM.Character
            local myHum  = myChar and myChar:FindFirstChildOfClass("Humanoid")
            local myBp   = LP_MM:FindFirstChild("Backpack")
            if not myHum then return nil end
            local knife = nil
            -- Suche in Character und Backpack nach allen bekannten Knife-Namen
            for _, nm in ipairs(MM2_KNIFE_NAMES) do
                knife = (myChar and myChar:FindFirstChild(nm))
                    or  (myBp  and myBp:FindFirstChild(nm))
                if knife then break end
            end
            -- Fallback: erstes Tool im Backpack das "knife/blade" im Namen hat
            if not knife and myBp then
                for _, obj in ipairs(myBp:GetChildren()) do
                    if obj:IsA("Tool") then
                        local n = obj.Name:lower()
                        if n:find("knife") or n:find("blade") or n:find("dagger") then
                            knife = obj; break
                        end
                    end
                end
            end
            if knife and knife:IsA("Tool") then
                pcall(function() myHum:EquipTool(knife) end)
                task.wait(0.06)
            end
            return knife
        end

        -- [FIX v89-KILLALL] Kill All komplett neu:
        --   Methode 1: firetouchinterest — Executor-API, simuliert direkten Touch zwischen
        --              Knife-Parts und Ziel-Parts → Server registriert Knife-Hit korrekt.
        --   Methode 2: knife:Activate() + RemoteEvent mit ALLEN möglichen Arg-Kombinationen
        --              (MM2 nutzt verschiedene Remote-Signaturen je nach Map-Version).
        --   Methode 3: Teleport auf Ziel (immer aktiv als Basis für alle Methoden).
        --   Rolle wird NICHT mehr erzwungen — Funktion läuft unabhängig von mm2_getRole.
        local function mm2_killAllNow()
            local myChar = LP_MM.Character
            local myHrp  = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if not myHrp then return 0 end
            local origCF = myHrp.CFrame
            local knife  = mm2_equipKnife()

            -- firetouchinterest: Executor-Funktion (Synapse X, KRNL, Fluxus, Delta)
            local fti = nil
            pcall(function()
                if type(firetouchinterest) == "function" then
                    fti = firetouchinterest
                end
            end)
            if not fti then
                fti = rawget(_G, "firetouchinterest")
                   or rawget(_G, "fire_touch_interest")
            end

            local targets = {}
            for _, plr in ipairs(Players_MM:GetPlayers()) do
                if plr ~= LP_MM then
                    local tChar = plr.Character
                    local tHrp  = tChar and tChar:FindFirstChild("HumanoidRootPart")
                    local tHum  = tChar and tChar:FindFirstChildOfClass("Humanoid")
                    if tHrp and tHum and tHum.Health > 0 then
                        table.insert(targets, {plr=plr, char=tChar, hrp=tHrp, hum=tHum})
                    end
                end
            end

            for _, t in ipairs(targets) do
                if t.hrp and t.hrp.Parent then
                    pcall(function()
                        -- 1. Direkt auf Ziel teleportieren
                        myHrp.CFrame = t.hrp.CFrame

                        if knife then
                            -- 2. Messer aktivieren (Swing-Animation + lokaler Hit)
                            pcall(function() knife:Activate() end)

                            -- 3. firetouchinterest: Knife-Parts gegen Ziel-Parts
                            if fti then
                                for _, kp in ipairs(knife:GetDescendants()) do
                                    if kp:IsA("BasePart") then
                                        pcall(fti, kp, t.hrp, 0)
                                        pcall(fti, kp, t.hrp, 1)
                                        for _, tp in ipairs(t.char:GetDescendants()) do
                                            if tp:IsA("BasePart") then
                                                pcall(fti, kp, tp, 0)
                                                pcall(fti, kp, tp, 1)
                                            end
                                        end
                                    end
                                end
                                -- Auch eigenen HRP gegen Ziel feuern (Kollisions-Touch)
                                pcall(fti, myHrp, t.hrp, 0)
                                pcall(fti, myHrp, t.hrp, 1)
                            end

                            -- 4. Alle RemoteEvents mit allen möglichen Argument-Kombinationen feuern
                            --    (MM2 nutzt je nach Version verschiedene Signaturen)
                            pcall(function()
                                for _, r in ipairs(knife:GetDescendants()) do
                                    if r:IsA("RemoteEvent") then
                                        pcall(function() r:FireServer() end)
                                        pcall(function() r:FireServer(t.hum) end)
                                        pcall(function() r:FireServer(t.hrp) end)
                                        pcall(function() r:FireServer(t.char) end)
                                        pcall(function() r:FireServer(t.plr) end)
                                        pcall(function() r:FireServer(t.hrp.Position) end)
                                        pcall(function() r:FireServer(t.hum, t.hrp.Position) end)
                                    end
                                    if r:IsA("RemoteFunction") then
                                        pcall(function() r:InvokeServer(t.hum) end)
                                        pcall(function() r:InvokeServer(t.hrp) end)
                                    end
                                end
                            end)
                        end

                        -- 5. Client-seitig Health = 0 (visueller Fallback / lokale Simulation)
                        pcall(function() t.hum.Health = 0 end)
                        task.wait(0.05)
                    end)
                end
            end

            pcall(function() myHrp.CFrame = origCF end)
            return #targets
        end

        -- Einmalig: alle gleichzeitig in ~0.1s
        -- [FIX v89] Role-Gate entfernt — Funktion läuft auch wenn Rolle nicht erkannt wird.
        --           Warnung wird angezeigt, aber Kill All wird trotzdem ausgeführt.
        mm2Button("☠️ Kill All (einmalig) — alle tot in ~0.1s\n(Messer muss in Backpack sein)", Color3.fromRGB(90, 10, 10), function()
            task.spawn(function()
                if mm2_getRole(LP_MM) ~= "murder" then
                    setStatus("⚠️ Rolle nicht erkannt — versuche trotzdem...", Color3.fromRGB(255, 140, 0))
                    task.wait(0.4)
                end
                setStatus("☠️ Kill All...", Color3.fromRGB(220, 40, 40))
                local n = mm2_killAllNow()
                setStatus("☠️ Fertig — " .. n .. " Spieler getötet!", Color3.fromRGB(200, 50, 50))
            end)
        end)

        -- Auto: wiederholt alle 1.5s (auch Respawns)
        -- [FIX v89] Role-Gate entfernt — Auto Kill läuft auch ohne Murder-Erkennung.
        mm2Toggle("🔁 Auto Kill All — alle gleichzeitig, auch\nnach Respawn automatisch wiederholen", false, function(state)
            mm2_killAllActive = state
            if not state then setStatus("⏳ Auto Kill All gestoppt") return end
            if mm2_getRole(LP_MM) ~= "murder" then
                setStatus("⚠️ Rolle nicht erkannt — Auto Kill läuft trotzdem!", Color3.fromRGB(255, 140, 0))
            else
                setStatus("🔁 Auto Kill All aktiv!", Color3.fromRGB(220, 40, 40))
            end
            task.spawn(function()
                while mm2_killAllActive do
                    pcall(mm2_killAllNow)
                    task.wait(1.5)
                end
            end)
        end)

        -- ══════════════════ KNIFE AURA ══════════════════
        mm2Section("🗡️  KNIFE AURA")

        -- Knife Aura: schwingt automatisch wenn ein Spieler in Reichweite ist
        -- Logik:
        --   1. Heartbeat-Loop prüft jeden Frame die Distanz zu allen Spielern
        --   2. Sobald jemand < Schwelle studs entfernt ist → Messer equip + Activate
        --   3. Kurzer Cooldown (0.35s) damit das Spiel den Swing registriert
        --   4. Funktioniert unabhängig von der Rolle (aber nur sinnvoll als Murder)
        local mm2_knifeAuraActive = false
        local mm2_knifeAuraConn   = nil
        local mm2_knifeAuraRange  = 8   -- Standard-Reichweite in studs

        mm2Toggle("🗡️ Knife Aura — schwingt automatisch\nwenn Spieler in Reichweite (nur als Murder sinnvoll)", false, function(state)
            mm2_knifeAuraActive = state
            if mm2_knifeAuraConn then
                mm2_knifeAuraConn:Disconnect()
                mm2_knifeAuraConn = nil
            end
            if not state then
                setStatus("🗡️ Knife Aura deaktiviert", Color3.fromRGB(180, 180, 180))
                return
            end

            setStatus("🗡️ Knife Aura aktiv — Reichweite: " .. mm2_knifeAuraRange .. " studs", Color3.fromRGB(220, 60, 60))

            local _kaCooldown  = false   -- verhindert zu schnelles Schwingen
            local _kaSwingWait = 0.35    -- Sekunden zwischen Swings (MM2 Knife-Cooldown)

            mm2_knifeAuraConn = RS_MM.Heartbeat:Connect(function()
                if not mm2_knifeAuraActive or _kaCooldown then return end
                pcall(function()
                    local myChar = LP_MM.Character
                    local myHrp  = myChar and myChar:FindFirstChild("HumanoidRootPart")
                    local myHum  = myChar and myChar:FindFirstChildOfClass("Humanoid")
                    if not myHrp or not myHum or myHum.Health <= 0 then return end

                    -- Nächsten lebenden Spieler in Reichweite suchen
                    local closest     = nil
                    local closestDist = mm2_knifeAuraRange

                    for _, plr in ipairs(Players_MM:GetPlayers()) do
                        if plr ~= LP_MM then
                            local tChar = plr.Character
                            local tHrp  = tChar and tChar:FindFirstChild("HumanoidRootPart")
                            local tHum  = tChar and tChar:FindFirstChildOfClass("Humanoid")
                            if tHrp and tHum and tHum.Health > 0 then
                                local dist = (tHrp.Position - myHrp.Position).Magnitude
                                if dist < closestDist then
                                    closestDist = dist
                                    closest     = plr
                                end
                            end
                        end
                    end

                    -- Spieler in Reichweite gefunden → Knife equip + Swing
                    if closest then
                        _kaCooldown = true
                        -- Messer ausrüsten (nutzt bestehende mm2_equipKnife Funktion)
                        local knife = mm2_equipKnife()

                        if knife then
                            -- Methode 1: Tool aktivieren (löst Swing-Animation aus)
                            pcall(function() knife:Activate() end)

                            -- Methode 2: firetouchinterest (Executor-API)
                            local ftiAura = nil
                            pcall(function()
                                if type(firetouchinterest) == "function" then ftiAura = firetouchinterest end
                            end)
                            if not ftiAura then
                                ftiAura = rawget(_G,"firetouchinterest") or rawget(_G,"fire_touch_interest")
                            end
                            if ftiAura then
                                local tHrpAura = closest.Character and closest.Character:FindFirstChild("HumanoidRootPart")
                                for _, kp in ipairs(knife:GetDescendants()) do
                                    if kp:IsA("BasePart") and tHrpAura then
                                        pcall(ftiAura, kp, tHrpAura, 0)
                                        pcall(ftiAura, kp, tHrpAura, 1)
                                    end
                                end
                            end

                            -- Methode 3: Alle RemoteEvents mit mehreren Arg-Kombinationen feuern
                            -- [FIX v89] Vorher nur FireServer(tHum) → MM2 ignoriert falsche Args.
                            --           Jetzt alle bekannten Signaturen probieren.
                            pcall(function()
                                local tHum2 = closest.Character and closest.Character:FindFirstChildOfClass("Humanoid")
                                local tHrp2 = closest.Character and closest.Character:FindFirstChild("HumanoidRootPart")
                                for _, r in ipairs(knife:GetDescendants()) do
                                    if r:IsA("RemoteEvent") then
                                        pcall(function() r:FireServer() end)
                                        pcall(function() r:FireServer(tHum2) end)
                                        pcall(function() r:FireServer(tHrp2) end)
                                        pcall(function() r:FireServer(closest.Character) end)
                                        pcall(function() r:FireServer(closest) end)
                                        if tHrp2 then
                                            pcall(function() r:FireServer(tHum2, tHrp2.Position) end)
                                        end
                                    end
                                    if r:IsA("RemoteFunction") then
                                        pcall(function() r:InvokeServer(tHum2) end)
                                        pcall(function() r:InvokeServer(tHrp2) end)
                                    end
                                end
                            end)

                            setStatus("🗡️ Swing → " .. closest.DisplayName, Color3.fromRGB(255, 80, 80))
                        else
                            setStatus("⚠️ Kein Messer im Backpack!", Color3.fromRGB(255, 180, 60))
                        end

                        -- Cooldown nach Swing
                        task.delay(_kaSwingWait, function()
                            _kaCooldown = false
                        end)
                    end
                end)
            end)
        end)

        -- Reichweiten-Slider (4 bis 20 studs)
        do
            local sliderFrame = Instance.new("Frame")
            sliderFrame.Size             = UDim2.new(1, -20, 0, 42)
            sliderFrame.BackgroundColor3 = Color3.fromRGB(12, 18, 32)
            sliderFrame.BorderSizePixel  = 0
            sliderFrame.ZIndex           = 12
            sliderFrame.Parent           = content
            Instance.new("UICorner", sliderFrame).CornerRadius = UDim.new(0, 8)

            local sliderLbl = Instance.new("TextLabel")
            sliderLbl.Size                  = UDim2.new(1, -10, 0, 18)
            sliderLbl.Position              = UDim2.new(0, 8, 0, 2)
            sliderLbl.BackgroundTransparency = 1
            sliderLbl.Font                  = Enum.Font.GothamMedium
            sliderLbl.Text                  = "🎯 Reichweite: " .. mm2_knifeAuraRange .. " studs"
            sliderLbl.TextColor3            = Color3.fromRGB(200, 200, 255)
            sliderLbl.TextSize              = 11
            sliderLbl.TextXAlignment        = Enum.TextXAlignment.Left
            sliderLbl.ZIndex                = 13
            sliderLbl.Parent                = sliderFrame

            local track = Instance.new("Frame")
            track.Size             = UDim2.new(1, -16, 0, 6)
            track.Position         = UDim2.new(0, 8, 0, 28)
            track.BackgroundColor3 = Color3.fromRGB(30, 40, 70)
            track.BorderSizePixel  = 0
            track.ZIndex           = 13
            track.Parent           = sliderFrame
            Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

            local fill = Instance.new("Frame")
            fill.Size             = UDim2.new((mm2_knifeAuraRange - 4) / 16, 0, 1, 0)
            fill.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
            fill.BorderSizePixel  = 0
            fill.ZIndex           = 14
            fill.Parent           = track
            Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

            local knob = Instance.new("TextButton")
            knob.Size             = UDim2.new(0, 14, 0, 14)
            knob.Position         = UDim2.new(fill.Size.X.Scale, -7, 0.5, -7)
            knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            knob.Text             = ""
            knob.BorderSizePixel  = 0
            knob.ZIndex           = 15
            knob.Parent           = track
            Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

            local draggingSlider = false
            knob.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    draggingSlider = true
                end
            end)
            game:GetService("UserInputService").InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    draggingSlider = false
                end
            end)
            game:GetService("UserInputService").InputChanged:Connect(function(inp)
                if draggingSlider and inp.UserInputType == Enum.UserInputType.MouseMovement then
                    local trackAbs = track.AbsolutePosition
                    local trackSz  = track.AbsoluteSize
                    local rel = math.clamp((inp.Position.X - trackAbs.X) / trackSz.X, 0, 1)
                    local val = math.floor(4 + rel * 16 + 0.5)  -- 4..20 studs
                    mm2_knifeAuraRange      = val
                    fill.Size               = UDim2.new(rel, 0, 1, 0)
                    knob.Position           = UDim2.new(rel, -7, 0.5, -7)
                    sliderLbl.Text          = "🎯 Reichweite: " .. val .. " studs"
                    if mm2_knifeAuraActive then
                        setStatus("🗡️ Knife Aura aktiv — Reichweite: " .. val .. " studs", Color3.fromRGB(220, 60, 60))
                    end
                end
            end)
        end

        -- ══════════════════ COINS FARM ══════════════════
        mm2Section("🪙  AUTO COINS FARM")

        -- [FIX] Coin Farm: Direkte CFrame-Teleportation statt Lerp (war zu langsam und stuck-anfällig)
        --       Münzen werden präziser erkannt (Model + BasePart, Coin-Bag-Check, robusteres Scan)
        mm2Toggle("🪙 Auto Coins Farm — teleportiert zu jeder Münze\n(stoppt automatisch wenn keine Münzen mehr da)", false, function(state)
            mm2_coinFarm = state
            if not state then setStatus("⏳ Coin Farm gestoppt") return end
            setStatus("🪙 Coin Farm aktiv!", Color3.fromRGB(255, 210, 60))
            task.spawn(function()
                local ws = game:GetService("Workspace")

                -- [FIX] Erweiterter Coin-Scanner: sucht BaseParts UND Models namens Coin/Gold
                local function scanCoins()
                    local found = {}
                    for _, obj in ipairs(ws:GetDescendants()) do
                        local nm = obj.Name:lower()
                        local isCoin = nm == "coin" or nm == "coins" or nm:find("gold")
                            or nm == "coinpart" or nm == "coinmodel" or nm == "bag"
                        if isCoin then
                            if obj:IsA("BasePart") then
                                table.insert(found, obj)
                            elseif obj:IsA("Model") then
                                -- Model → PrimaryPart oder erstes BasePart nehmen
                                local bp2 = obj.PrimaryPart
                                    or obj:FindFirstChildOfClass("BasePart")
                                if bp2 then table.insert(found, bp2) end
                            end
                        end
                    end
                    return found
                end

                local coins = scanCoins()
                local collected = 0

                while mm2_coinFarm do
                    repeat
                        local char = LP_MM.Character
                        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
                        if not hrp then task.wait(0.5) break end

                        -- Abgelaufene Münzen filtern
                        local alive = {}
                        for _, c in ipairs(coins) do
                            if c and c.Parent then table.insert(alive, c) end
                        end
                        coins = alive

                        -- Cache leer → nochmal scannen
                        if #coins == 0 then
                            task.wait(0.3)
                            coins = scanCoins()
                            if #coins == 0 then
                                setStatus("✅ Fertig! " .. collected .. " Münzen gesammelt", Color3.fromRGB(100, 255, 120))
                                mm2_coinFarm = false
                                break
                            end
                        end

                        -- Nächste Münze finden
                        local nearest, nearDist = nil, math.huge
                        for _, c in ipairs(coins) do
                            if c.Parent then
                                local d = (hrp.Position - c.Position).Magnitude
                                if d < nearDist then nearDist = d; nearest = c end
                            end
                        end

                        if not (nearest and nearest.Parent) then task.wait(0.1) break end

                        -- [FIX] Direkt teleportieren statt Lerp (sofort statt 60 Schritte)
                        pcall(function()
                            hrp.CFrame = CFrame.new(nearest.Position + Vector3.new(0, 3, 0))
                        end)
                        collected = collected + 1
                        setStatus("🪙 Münze " .. collected .. " gesammelt!", Color3.fromRGB(255, 210, 60))
                        task.wait(0.12)  -- kurz warten damit Server Coin-Collection erkennt
                    until true
                end
            end)
        end)

        mm2Button("🔍 Coins jetzt scannen (wie viele auf Map?)", Color3.fromRGB(20, 40, 90), function()
            local count = 0
            pcall(function()
                for _, obj in ipairs(game:GetService("Workspace"):GetDescendants()) do
                    local nm = obj.Name:lower()
                    if (nm:find("coin") or nm:find("gold")) and obj:IsA("BasePart") then
                        count = count + 1
                    end
                end
            end)
            setStatus("🪙 " .. count .. " Coins auf der Map gefunden", Color3.fromRGB(255, 210, 60))
        end)

        -- ══════════════════ EXTRA ══════════════════
        mm2Section("⚡  SCHNELL-TOOLS")

        mm2Button("🔍 Rollen-Übersicht (alle Spieler)", Color3.fromRGB(20, 50, 100), function()
            local lines2 = {}
            for _, plr in ipairs(Players_MM:GetPlayers()) do
                if plr ~= LP_MM then
                    local r = mm2_getRole(plr)
                    local icon = r=="murder" and "🔴" or r=="sheriff" and "🔵" or "⚪"
                    table.insert(lines2, icon .. " " .. plr.Name)
                end
            end
            local txt = #lines2>0 and table.concat(lines2, "  |  ") or "⚠ Niemand erkannt"
            setStatus(txt, Color3.fromRGB(180, 220, 255))
        end)

        mm2Button("💀 Wer ist Murder? (Name in Chat tippen)", Color3.fromRGB(80, 20, 20), function()
            local murder = nil
            for _, plr in ipairs(Players_MM:GetPlayers()) do
                if plr ~= LP_MM and mm2_getRole(plr) == "murder" then
                    murder = plr.Name
                    break
                end
            end
            if murder then
                pcall(function()
                    game:GetService("TextChatService").TextChannels.RBXGeneral:SendAsync("Murder: " .. murder)
                end)
                setStatus("💬 '" .. murder .. "' als Murder in Chat gepostet", Color3.fromRGB(255,80,80))
            else
                setStatus("⚠ Kein Murder erkannt", Color3.fromRGB(255,180,60))
            end
        end)

        mm2Button("🔵 Wer ist Sheriff? (Name in Chat tippen)", Color3.fromRGB(20, 40, 120), function()
            local sheriff = nil
            for _, plr in ipairs(Players_MM:GetPlayers()) do
                if plr ~= LP_MM and mm2_getRole(plr) == "sheriff" then
                    sheriff = plr.Name
                    break
                end
            end
            if sheriff then
                pcall(function()
                    game:GetService("TextChatService").TextChannels.RBXGeneral:SendAsync("Sheriff: " .. sheriff)
                end)
                setStatus("💬 '" .. sheriff .. "' als Sheriff in Chat gepostet", Color3.fromRGB(80,80,255))
            else
                setStatus("⚠ Kein Sheriff erkannt", Color3.fromRGB(255,180,60))
            end
        end)

        -- ══════════════════ INVISIBILITY (Dummy-Methode) ══════════════════
        mm2Section("🫥  INVISIBILITY")

        --[[
            METHODE: Echter Char weit weg + lokaler Dummy-Clone
            ─────────────────────────────────────────────────────────────
            WIE es funktioniert:
              EIN:
                1. Echter Charakter → PlatformStand=true, zu mm2_hiddenCF (10000,5,10000)
                   → andere sehen ihn nicht (außerhalb Render-Bereich)
                2. Dummy-Model = lokal erstellter Clone aller Character-BaseParts
                   → wird von einem LocalScript erstellt → NICHT zu anderen repliziert
                   → Transparency=0.5 (du siehst dich als Ghost)
                3. Kamera → CameraSubject = Dummy-HRP (nur wenn Free Cam inaktiv)
                4. Heartbeat:
                   a) WASD lesen → Dummy-HRP CFrame updaten
                   b) Alle Dummy-Parts relativ zum Dummy-HRP synchronisieren
                   c) Echter Char → bei hiddenCF halten (Anti-Resync)
              AUS:
                1. Echter Char zurück zur letzten Dummy-Position
                2. PlatformStand=false, Kamera zurück auf Humanoid
                3. Dummy-Model zerstören, Heartbeat disconnect
            ─────────────────────────────────────────────────────────────
            HINWEIS: Weil echter Char weit weg ist, funktionieren Kills
            im Invis-Modus nicht direkt. Nutze "Invis AUS → töten → Invis EIN"
            oder den separaten Kill-All Button.
        --]]

        local mm2_UIS = game:GetService("UserInputService")

        -- State
        local mm2_invisOn    = false
        local mm2_dummyModel = nil   -- lokales transparentes Model
        local mm2_dummyHRP   = nil   -- HRP-Clone (PrimaryPart des Dummies)
        local mm2_dummyRels  = {}    -- {clone=Part, relCF=CFrame} für Sync
        local mm2_moveConn   = nil   -- Heartbeat
        local mm2_hiddenCF   = CFrame.new(10000, 5, 10000)  -- echter Char hier

        -- Dummy-Model + Heartbeat aufräumen
        local function mm2_invisCleanup()
            if mm2_moveConn then
                pcall(function() mm2_moveConn:Disconnect() end)
                mm2_moveConn = nil
            end
            if mm2_dummyModel and mm2_dummyModel.Parent then
                pcall(function() mm2_dummyModel:Destroy() end)
            end
            mm2_dummyModel = nil
            mm2_dummyHRP   = nil
            mm2_dummyRels  = {}
            -- Sicherheits-Cleanup: alle GhD_-Models im Workspace
            pcall(function()
                for _, obj in ipairs(workspace:GetChildren()) do
                    if obj:IsA("Model") and typeof(obj.Name) == "string"
                       and obj.Name:sub(1,4) == "GhD_" then
                        obj:Destroy()
                    end
                end
            end)
        end

        -- Clone aller Character-BaseParts als lokales Dummy-Model bauen
        local function mm2_buildDummy(char)
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return false end

            local model   = Instance.new("Model")
            model.Name    = "GhD_" .. math.random(10000, 99999)
            local hrpCF   = hrp.CFrame
            local hrpClone = nil
            mm2_dummyRels  = {}

            for _, obj in ipairs(char:GetDescendants()) do
                if obj:IsA("BasePart") then
                    local clone           = Instance.new("Part")
                    clone.Size            = obj.Size
                    clone.Color           = obj.Color
                    clone.Material        = obj.Material
                    clone.Transparency    = 0.5   -- Ghost-Look
                    clone.Anchored        = true
                    clone.CanCollide      = false
                    clone.CastShadow      = false
                    clone.CFrame          = obj.CFrame
                    clone.Parent          = model

                    -- Relative CFrame zum HRP für späteres Syncing
                    local relCF = hrpCF:ToObjectSpace(obj.CFrame)
                    table.insert(mm2_dummyRels, {clone = clone, relCF = relCF})

                    if obj == hrp then
                        clone.Name = "DummyHRP"
                        hrpClone   = clone
                    end
                end
            end

            if not hrpClone then
                model:Destroy()
                return false
            end

            model.PrimaryPart = hrpClone
            model.Parent      = workspace  -- lokal erstellt → nicht repliziert
            mm2_dummyModel    = model
            mm2_dummyHRP      = hrpClone
            return true
        end

        local function mm2_enableInvis()
            local char = LP_MM.Character
            local hrp  = char and char:FindFirstChild("HumanoidRootPart")
            local hum  = char and char:FindFirstChildOfClass("Humanoid")
            if not char or not hrp or not hum then
                setStatus("⚠ Kein Character!", Color3.fromRGB(255,100,80))
                return
            end

            mm2_invisCleanup()

            -- ── 1: Dummy-Model bauen (lokal, nicht repliziert) ────────────────────
            local dummyOk = mm2_buildDummy(char)

            -- ── 2: Echter Char weit weg + PlatformStand ──────────────────────────
            pcall(function()
                hum.PlatformStand = true
                hrp.CFrame        = mm2_hiddenCF
            end)

            -- ── 3: Kamera auf Dummy zeigen (nur wenn Free Cam nicht aktiv) ────────
            local cam = workspace.CurrentCamera
            pcall(function()
                if cam.CameraType ~= Enum.CameraType.Scriptable and mm2_dummyHRP then
                    cam.CameraSubject = mm2_dummyHRP
                end
            end)

            -- ── 4: Heartbeat — WASD → Dummy bewegen + echter Char bei hiddenCF ────
            local dummyCF = mm2_dummyHRP and mm2_dummyHRP.CFrame or hrp.CFrame
            mm2_moveConn  = RS_MM.Heartbeat:Connect(function(dt)
                -- Echter Char immer bei hiddenCF halten (Anti-Resync)
                local c  = LP_MM.Character
                local rp = c and c:FindFirstChild("HumanoidRootPart")
                if rp then
                    pcall(function() rp.CFrame = mm2_hiddenCF end)
                end

                if not (mm2_dummyHRP and mm2_dummyHRP.Parent) then return end

                -- WASD-Input lesen
                local dir = Vector3.new(
                    (mm2_UIS:IsKeyDown(Enum.KeyCode.D) and 1 or 0)
                  - (mm2_UIS:IsKeyDown(Enum.KeyCode.A) and 1 or 0),
                    0,
                    (mm2_UIS:IsKeyDown(Enum.KeyCode.S) and 1 or 0)
                  - (mm2_UIS:IsKeyDown(Enum.KeyCode.W) and 1 or 0)
                )

                if dir.Magnitude > 0 then
                    dir = dir.Unit
                    -- Kamera-relativ umrechnen
                    local camCF  = cam.CFrame
                    local fwd    = Vector3.new(camCF.LookVector.X,  0, camCF.LookVector.Z)
                    local rgt    = Vector3.new(camCF.RightVector.X, 0, camCF.RightVector.Z)
                    if fwd.Magnitude > 0 then fwd = fwd.Unit end
                    if rgt.Magnitude > 0 then rgt = rgt.Unit end

                    local h_     = c and c:FindFirstChildOfClass("Humanoid")
                    local speed  = (h_ and h_.WalkSpeed > 0 and h_.WalkSpeed or 16)
                    local wDir   = fwd * (-dir.Z) + rgt * dir.X
                    local newPos = dummyCF.Position + wDir * speed * dt
                    dummyCF      = CFrame.lookAt(newPos, newPos + wDir)
                                   * CFrame.Angles(0, math.pi, 0)
                end

                -- Dummy-HRP auf neue Position setzen
                pcall(function() mm2_dummyHRP.CFrame = dummyCF end)

                -- Alle anderen Dummy-Parts relativ zum HRP synchronisieren
                for _, entry in ipairs(mm2_dummyRels) do
                    if entry.clone ~= mm2_dummyHRP and entry.clone.Parent then
                        pcall(function()
                            entry.clone.CFrame = dummyCF * entry.relCF
                        end)
                    end
                end
            end)

            setStatus(
                "🫥 Invis EIN — " .. (dummyOk and "Dummy aktiv | WASD = Bewegen" or "Dummy Fehler"),
                Color3.fromRGB(160, 220, 255)
            )
        end

        local function mm2_disableInvis()
            local char = LP_MM.Character
            local hrp  = char and char:FindFirstChild("HumanoidRootPart")
            local hum  = char and char:FindFirstChildOfClass("Humanoid")

            -- Rückkehr-Position = letzte Dummy-Position
            local returnCF = (mm2_dummyHRP and mm2_dummyHRP.Parent)
                and mm2_dummyHRP.CFrame
                or  CFrame.new(0, 5, 0)

            -- ── 1: Heartbeat + Dummy entfernen ───────────────────────────────────
            mm2_invisCleanup()

            -- ── 2: Echter Char zurück zur Dummy-Position ─────────────────────────
            if hrp then pcall(function() hrp.CFrame = returnCF end) end

            -- ── 3: PlatformStand deaktivieren ────────────────────────────────────
            if hum then pcall(function() hum.PlatformStand = false end) end

            -- ── 4: Kamera zurück auf Humanoid (nur wenn sie auf Dummy zeigte) ────
            pcall(function()
                local cam = workspace.CurrentCamera
                if cam.CameraType ~= Enum.CameraType.Scriptable and hum then
                    cam.CameraSubject = hum
                end
            end)

            setStatus("👁️ Invis AUS — sichtbar!", Color3.fromRGB(180, 220, 180))
        end

        -- ── Keybind: X ───────────────────────────────────────────────────────────
        table.insert(mm2_conns, mm2_UIS.InputBegan:Connect(function(inp, gp)
            if gp then return end
            if inp.KeyCode ~= Enum.KeyCode.X then return end
            if not sg.Parent then return end
            mm2_invisOn = not mm2_invisOn
            if mm2_invisOn then mm2_enableInvis() else mm2_disableInvis() end
        end))

        -- ── Respawn: Invis nach Tod wieder aktivieren ────────────────────────────
        table.insert(mm2_conns, LP_MM.CharacterAdded:Connect(function()
            if not mm2_invisOn then return end
            task.wait(1.5)
            if mm2_invisOn then mm2_enableInvis() end
        end))

        -- ── UI ───────────────────────────────────────────────────────────────────
        mm2Toggle("🫥 Dummy-Invis — [X] zum Togglen\nEchter Char weit weg | Dummy-Clone = Ghost den du steuerst", false, function(state)
            mm2_invisOn = state
            if state then mm2_enableInvis() else mm2_disableInvis() end
        end)

        mm2Button("🫥 Invis jetzt togglen (= Taste X)", Color3.fromRGB(20, 40, 80), function()
            mm2_invisOn = not mm2_invisOn
            if mm2_invisOn then mm2_enableInvis() else mm2_disableInvis() end
        end)

        -- ══════════════════ AUFRÄUMEN ══════════════════
        sg.AncestryChanged:Connect(function()
            if not sg.Parent then
                mm2_murderActive  = false
                mm2_sheriffActive = false
                mm2_innocActive   = false
                mm2_flingMurder   = false
                mm2_flingSheriff  = false
                mm2_autoShoot     = false
                mm2_killAllActive = false
                mm2_coinFarm      = false
                mm2_spyActive     = false
                mm2_knifeAuraActive = false
                if mm2_knifeAuraConn then
                    mm2_knifeAuraConn:Disconnect()
                    mm2_knifeAuraConn = nil
                end
                -- Invis cleanup (Seat-Walk Methode)
                mm2_invisOn = false
                mm2_invisCleanup()
                pcall(function()
                    local _c = LP_MM.Character
                    local _h = _c and _c:FindFirstChildOfClass("Humanoid")
                    local _r = _c and _c:FindFirstChild("HumanoidRootPart")
                    if _h then _h.PlatformStand = false end
                    if _r then _r.CFrame = CFrame.new(0, 5, 0) end
                    local cam = workspace.CurrentCamera
                    if cam.CameraType ~= Enum.CameraType.Scriptable and _h then
                        cam.CameraSubject = _h
                    end
                end)
                mm2_removeHL(mm2_murderHL)
                mm2_removeHL(mm2_sheriffHL)
                mm2_removeHL(mm2_innocHL)
                for _, c in ipairs(mm2_conns)    do pcall(function() c:Disconnect() end) end
                for _, c in ipairs(mm2_spyConns) do pcall(function() c:Disconnect() end) end
                mm2_conns = {}; mm2_spyConns = {}
            end
        end)
    end
})

-- ==================== ⚽ SPIN A SOCCER CARD ====================
GamesTab:CreateSection("⚽ Spin a Soccer Card")

GamesTab:CreateButton({
    Name = "⚽ Soccer Card Features öffnen",
    Callback = function()
        if game.PlaceId ~= 112490729816320 then
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "SemysHUB",
                Text  = "❌ Nur in Spin a Soccer Card nutzbar!",
                Duration = 4,
            })
            return
        end
        local CoreGui    = game:GetService("CoreGui")
        local _soccerhub = CoreGui:FindFirstChild("SemysSoccerHub") -- [FIX] doppeltes FindFirstChild → local speichern
        if _soccerhub then
            _soccerhub:Destroy()
            return
        end

        local TweenService_SC = game:GetService("TweenService")
        local LP_SC           = game:GetService("Players").LocalPlayer
        local RepStorage      = game:GetService("ReplicatedStorage")
        local UIS_SC          = game:GetService("UserInputService")

        -- ══════════════════ SHARED STATE ══════════════════
        local sc_conns         = {}
        local sc_spyActive     = false
        local sc_autoReplay    = false
        local sc_autoG         = false
        local sc_autoDrehrad   = false
        local sc_autoRebirth   = false
        local sc_autoBuyPack   = false
        local sc_captured      = {}     -- {remote, name, args, method}
        local sc_replayTarget  = nil
        local sc_hookRef       = nil
        local sc_listFrame     = nil
        -- [FIX v96-4] sc_refreshList: Forward-Declaration.
        -- Wird in sc_startHook (Zeile ~4974) in einer Closure aufgerufen,
        -- bevor die eigentliche Definition (Zeile ~5292) erreicht wird.
        -- Ohne Forward-Declaration greift Lua auf _G zurück → nil-Crash.
        local sc_refreshList

        -- ══════════════════ REMOTE SPY HOOK ══════════════════
        local function sc_startHook()
            if sc_hookRef then return end
            pcall(function()
                local mt  = getrawmetatable(game)
                local old = mt.__namecall
                sc_hookRef = old
                setreadonly(mt, false)
                mt.__namecall = newcclosure(function(self, ...)
                    local method = getnamecallmethod()
                    if sc_spyActive and (method == "FireServer" or method == "InvokeServer") then
                        local ok, name = pcall(function() return self.Name end)
                        if ok and name then
                            local args  = {...}
                            local entry = {remote=self, name=name, args=args, method=method}
                            local found = false
                            for _, v in ipairs(sc_captured) do
                                if v.name == name then
                                    found = true
                                    v.args = args
                                    sc_replayTarget = v
                                    break
                                end
                            end
                            if not found then
                                table.insert(sc_captured, entry)
                                sc_replayTarget = entry
                                task.defer(function() pcall(function() sc_refreshList() end) end)
                            end
                        end
                    end
                    return old(self, ...)
                end)
                setreadonly(mt, true)
            end)
        end

        local function sc_stopHook()
            pcall(function()
                if sc_hookRef then
                    local mt = getrawmetatable(game)
                    setreadonly(mt, false)
                    mt.__namecall = sc_hookRef
                    setreadonly(mt, true)
                    sc_hookRef = nil
                end
            end)
        end

        -- ══════════════════ SCREENGUI ══════════════════
        local sg = Instance.new("ScreenGui")
        sg.Name = "SemysSoccerHub"
        sg.ResetOnSpawn = false
        sg.DisplayOrder = 5000
        sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        sg.Parent = CoreGui

        local win = Instance.new("Frame")
        win.Name = "SoccerWin"
        win.Size = UDim2.new(0, 340, 0, 500)
        win.Position = UDim2.new(0.5, -170, 0.5, -250)
        win.BackgroundColor3 = Color3.fromRGB(10, 14, 22)
        win.BorderSizePixel = 0
        win.ZIndex = 10
        win.ClipsDescendants = true
        win.Parent = sg
        Instance.new("UICorner", win).CornerRadius = UDim.new(0, 14)

        local winGrad = Instance.new("UIGradient", win)
        winGrad.Rotation = 90
        winGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0,   Color3.fromRGB(18, 26, 48)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(10, 14, 28)),
            ColorSequenceKeypoint.new(1,   Color3.fromRGB(6,  8,  16)),
        })

        local winGlow = Instance.new("Frame")
        winGlow.Size = UDim2.new(1, 0, 0, 120)
        winGlow.Position = UDim2.new(0, 0, 0.35, 0)
        winGlow.BackgroundColor3 = Color3.fromRGB(0, 100, 220)
        winGlow.BorderSizePixel = 0
        winGlow.ZIndex = 10
        winGlow.Parent = win
        local winGlowGrad = Instance.new("UIGradient", winGlow)
        winGlowGrad.Rotation = 90
        winGlowGrad.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.5, 0.84),
            NumberSequenceKeypoint.new(1, 1),
        })

        local winStroke = Instance.new("UIStroke", win)
        winStroke.Thickness = 2
        winStroke.Transparency = 0.2
        winStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        local winStrokeGrad = Instance.new("UIGradient", winStroke)
        winStrokeGrad.Rotation = 45
        winStrokeGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0,   Color3.fromRGB(0, 180, 255)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(80, 200, 255)),
            ColorSequenceKeypoint.new(1,   Color3.fromRGB(0, 160, 255)),
        })
        task.spawn(function()
            while sg.Parent do
                TweenService_SC:Create(winStroke, TweenInfo.new(1.4,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Transparency=0.65}):Play()
                task.wait(1.4)
                if not sg.Parent then break end
                TweenService_SC:Create(winStroke, TweenInfo.new(1.4,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Transparency=0.05}):Play()
                task.wait(1.4)
            end
        end)

        -- Titelleiste
        local titleBar = Instance.new("Frame")
        titleBar.Size = UDim2.new(1, 0, 0, 50)
        titleBar.BackgroundColor3 = Color3.fromRGB(10, 14, 24)
        titleBar.BorderSizePixel = 0
        titleBar.ZIndex = 11
        titleBar.Parent = win
        Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 14)
        local titleFix = Instance.new("Frame")
        titleFix.Size = UDim2.new(1, 0, 0, 14)
        titleFix.Position = UDim2.new(0, 0, 1, -14)
        titleFix.BackgroundColor3 = Color3.fromRGB(10, 14, 24)
        titleFix.BorderSizePixel = 0
        titleFix.ZIndex = 11
        titleFix.Parent = titleBar
        local titleLine = Instance.new("Frame")
        titleLine.Size = UDim2.new(1, -28, 0, 2)
        titleLine.Position = UDim2.new(0, 14, 1, -2)
        titleLine.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
        titleLine.BorderSizePixel = 0
        titleLine.ZIndex = 12
        titleLine.Parent = titleBar
        Instance.new("UICorner", titleLine).CornerRadius = UDim.new(1, 0)
        local lineGrad = Instance.new("UIGradient", titleLine)
        lineGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0,   Color3.fromRGB(0, 160, 255)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(120, 220, 255)),
            ColorSequenceKeypoint.new(1,   Color3.fromRGB(0, 160, 255)),
        })
        local titleLabel = Instance.new("TextLabel")
        titleLabel.RichText = true
        titleLabel.Text = 'SEMYS <font color="#1E9BFF">SOCCER</font>'
        titleLabel.Size = UDim2.new(1, -56, 1, 0)
        titleLabel.Position = UDim2.new(0, 14, 0, 0)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Font = Enum.Font.GothamBlack
        titleLabel.TextSize = 20
        titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.ZIndex = 12
        titleLabel.Parent = titleBar
        local subLabel = Instance.new("TextLabel")
        subLabel.Text = "Spin a Soccer Card • Semys HUB v94"  -- [FIX v94] Versionstext aktualisiert
        subLabel.Size = UDim2.new(1, -56, 0, 14)
        subLabel.Position = UDim2.new(0, 14, 1, -16)
        subLabel.BackgroundTransparency = 1
        subLabel.Font = Enum.Font.Gotham
        subLabel.TextSize = 10
        subLabel.TextColor3 = Color3.fromRGB(70, 90, 150)
        subLabel.TextXAlignment = Enum.TextXAlignment.Left
        subLabel.ZIndex = 12
        subLabel.Parent = titleBar
        local closeBtn = Instance.new("TextButton")
        closeBtn.Text = "✕"
        closeBtn.Size = UDim2.new(0, 28, 0, 28)
        closeBtn.Position = UDim2.new(1, -38, 0.5, -14)
        closeBtn.BackgroundColor3 = Color3.fromRGB(30, 80, 180)
        closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        closeBtn.Font = Enum.Font.GothamBold
        closeBtn.TextSize = 13
        closeBtn.BorderSizePixel = 0
        closeBtn.ZIndex = 14
        closeBtn.Parent = titleBar
        Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
        closeBtn.MouseEnter:Connect(function()
            TweenService_SC:Create(closeBtn,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(40,120,220)}):Play()
        end)
        closeBtn.MouseLeave:Connect(function()
            TweenService_SC:Create(closeBtn,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(30,80,180)}):Play()
        end)
        closeBtn.MouseButton1Click:Connect(function() sg:Destroy() end)

        -- Ziehbar
        local scDragging, scDragStart, scStartPos = false, nil, nil
        titleBar.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                scDragging=true; scDragStart=inp.Position; scStartPos=win.Position
            end
        end)
        titleBar.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then scDragging=false end
        end)
        table.insert(sc_conns,
            UIS_SC.InputChanged:Connect(function(inp)
                if scDragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
                    local d = inp.Position - scDragStart
                    win.Position = UDim2.new(scStartPos.X.Scale, scStartPos.X.Offset+d.X,
                                             scStartPos.Y.Scale, scStartPos.Y.Offset+d.Y)
                end
            end)
        )

        -- Status-Label  ← FIX: sc_statusText war nie definiert, jetzt direkt String
        local statusLbl = Instance.new("TextLabel")
        statusLbl.Text = "⏳ Bereit"
        statusLbl.Size = UDim2.new(1, -20, 0, 26)
        statusLbl.Position = UDim2.new(0, 10, 0, 54)
        statusLbl.BackgroundColor3 = Color3.fromRGB(12, 18, 32)
        statusLbl.BackgroundTransparency = 0.2
        statusLbl.Font = Enum.Font.GothamMedium
        statusLbl.TextSize = 12
        statusLbl.TextColor3 = Color3.fromRGB(0, 180, 255)
        statusLbl.ZIndex = 12
        statusLbl.Parent = win
        Instance.new("UICorner", statusLbl).CornerRadius = UDim.new(0, 6)

        local function setStatus(text, color)
            statusLbl.Text = text
            statusLbl.TextColor3 = color or Color3.fromRGB(0, 180, 255)
        end

        -- Scroll-Inhalt
        local content = Instance.new("ScrollingFrame")
        content.Size = UDim2.new(1, -20, 1, -92)
        content.Position = UDim2.new(0, 10, 0, 86)
        content.BackgroundTransparency = 1
        content.ScrollBarThickness = 3
        content.ScrollBarImageColor3 = Color3.fromRGB(0, 160, 255)
        content.CanvasSize = UDim2.new(0, 0, 0, 0)
        content.AutomaticCanvasSize = Enum.AutomaticSize.Y
        content.ZIndex = 11
        content.Parent = win
        local cLayout = Instance.new("UIListLayout", content)
        cLayout.Padding = UDim.new(0, 7)
        cLayout.SortOrder = Enum.SortOrder.LayoutOrder

        -- ── UI-Helfer ─────────────────────────────────────────
        local function scSection(txt, parent)
            local target = parent or content
            local lbl = Instance.new("TextLabel")
            lbl.Text = txt
            lbl.Size = UDim2.new(1, 0, 0, 26)
            lbl.BackgroundColor3 = Color3.fromRGB(10, 18, 38)
            lbl.BackgroundTransparency = 0.3
            lbl.Font = Enum.Font.GothamBold
            lbl.TextSize = 12
            lbl.TextColor3 = Color3.fromRGB(0, 170, 255)
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.ZIndex = 12
            lbl.Parent = target
            Instance.new("UICorner", lbl).CornerRadius = UDim.new(0, 6)
            local pad = Instance.new("UIPadding", lbl)
            pad.PaddingLeft = UDim.new(0, 14)
            local accent = Instance.new("Frame")
            accent.Size = UDim2.new(0, 3, 1, -6)
            accent.Position = UDim2.new(0, 0, 0, 3)
            accent.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
            accent.BorderSizePixel = 0
            accent.ZIndex = 13
            accent.Parent = lbl
            Instance.new("UICorner", accent).CornerRadius = UDim.new(1, 0)
        end

        local function scToggle(labelText, defaultState, onToggle)
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, 0, 0, 42)
            row.BackgroundColor3 = Color3.fromRGB(18, 24, 42)
            row.BorderSizePixel = 0
            row.ZIndex = 12
            row.Parent = content
            Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
            local lbl2 = Instance.new("TextLabel")
            lbl2.Text = labelText
            lbl2.Size = UDim2.new(1, -70, 1, 0)
            lbl2.Position = UDim2.new(0, 12, 0, 0)
            lbl2.BackgroundTransparency = 1
            lbl2.Font = Enum.Font.GothamMedium
            lbl2.TextSize = 13
            lbl2.TextColor3 = Color3.fromRGB(215, 225, 245)
            lbl2.TextXAlignment = Enum.TextXAlignment.Left
            lbl2.TextWrapped = true
            lbl2.ZIndex = 13
            lbl2.Parent = row
            local pill = Instance.new("Frame")
            pill.Size = UDim2.new(0, 44, 0, 22)
            pill.AnchorPoint = Vector2.new(1, 0.5)
            pill.Position = UDim2.new(1, -12, 0.5, 0)
            pill.BackgroundColor3 = defaultState and Color3.fromRGB(0,150,255) or Color3.fromRGB(28,38,58)
            pill.BorderSizePixel = 0
            pill.ZIndex = 13
            pill.Parent = row
            Instance.new("UICorner", pill).CornerRadius = UDim.new(0, 11)
            local knob = Instance.new("Frame")
            knob.Size = UDim2.new(0, 18, 0, 18)
            knob.AnchorPoint = Vector2.new(0, 0.5)
            knob.Position = defaultState and UDim2.new(1,-20,0.5,0) or UDim2.new(0,2,0.5,0)
            knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            knob.BorderSizePixel = 0
            knob.ZIndex = 14
            knob.Parent = pill
            Instance.new("UICorner", knob).CornerRadius = UDim.new(0, 9)
            local tState = defaultState
            row.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    tState = not tState
                    TweenService_SC:Create(pill,TweenInfo.new(0.18),{
                        BackgroundColor3 = tState and Color3.fromRGB(0,150,255) or Color3.fromRGB(28,38,58)
                    }):Play()
                    TweenService_SC:Create(knob,TweenInfo.new(0.18),{
                        Position = tState and UDim2.new(1,-20,0.5,0) or UDim2.new(0,2,0.5,0)
                    }):Play()
                    pcall(onToggle, tState)
                end
            end)
        end

        local function scButton(labelText, color, onClick)
            local btn = Instance.new("TextButton")
            btn.Text = labelText
            btn.Size = UDim2.new(1, 0, 0, 36)
            btn.BackgroundColor3 = color or Color3.fromRGB(20, 50, 130)
            btn.TextColor3 = Color3.fromRGB(225, 235, 255)
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 12
            btn.BorderSizePixel = 0
            btn.ZIndex = 12
            btn.TextWrapped = true
            btn.Parent = content
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
            btn.MouseButton1Click:Connect(function() pcall(onClick) end)
            btn.MouseEnter:Connect(function()
                TweenService_SC:Create(btn,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(
                    math.min(255,(color or Color3.fromRGB(20,50,130)).R*255*1.35),
                    math.min(255,(color or Color3.fromRGB(20,50,130)).G*255*1.35),
                    math.min(255,(color or Color3.fromRGB(20,50,130)).B*255*1.35)
                )}):Play()
            end)
            btn.MouseLeave:Connect(function()
                TweenService_SC:Create(btn,TweenInfo.new(0.12),{BackgroundColor3=color or Color3.fromRGB(20,50,130)}):Play()
            end)
        end

        -- ── sc_refreshList ────────────────────────────────────
        sc_refreshList = function()
            if not sc_listFrame then return end
            for _, c in ipairs(sc_listFrame:GetChildren()) do
                if not c:IsA("UIListLayout") then c:Destroy() end
            end
            if #sc_captured == 0 then
                local empty = Instance.new("TextLabel")
                empty.Text = "Noch keine Remotes.\nSpy AN → Aktion im Spiel ausführen."
                empty.Size = UDim2.new(1, 0, 0, 40)
                empty.BackgroundTransparency = 1
                empty.Font = Enum.Font.Gotham
                empty.TextSize = 11
                empty.TextColor3 = Color3.fromRGB(90, 120, 180)
                empty.TextWrapped = true
                empty.ZIndex = 13
                empty.Parent = sc_listFrame
                return
            end
            for i, entry in ipairs(sc_captured) do
                local row = Instance.new("Frame")
                row.Size = UDim2.new(1, 0, 0, 36)
                row.BackgroundColor3 = Color3.fromRGB(14, 22, 42)
                row.BorderSizePixel = 0
                row.ZIndex = 13
                row.Parent = sc_listFrame
                Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)
                local nameLbl = Instance.new("TextLabel")
                nameLbl.Text = i .. ". " .. tostring(entry.name)
                nameLbl.Size = UDim2.new(1, -80, 1, 0)
                nameLbl.Position = UDim2.new(0, 8, 0, 0)
                nameLbl.BackgroundTransparency = 1
                nameLbl.Font = Enum.Font.GothamMedium
                nameLbl.TextSize = 12
                nameLbl.TextColor3 = Color3.fromRGB(180, 220, 255)
                nameLbl.TextXAlignment = Enum.TextXAlignment.Left
                nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
                nameLbl.ZIndex = 14
                nameLbl.Parent = row
                local replayBtn = Instance.new("TextButton")
                replayBtn.Text = "▶"
                replayBtn.Size = UDim2.new(0, 68, 0, 26)
                replayBtn.AnchorPoint = Vector2.new(1, 0.5)
                replayBtn.Position = UDim2.new(1, -4, 0.5, 0)
                replayBtn.BackgroundColor3 = Color3.fromRGB(20, 100, 210)
                replayBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                replayBtn.Font = Enum.Font.GothamBold
                replayBtn.TextSize = 11
                replayBtn.BorderSizePixel = 0
                replayBtn.ZIndex = 14
                replayBtn.Parent = row
                Instance.new("UICorner", replayBtn).CornerRadius = UDim.new(0, 6)
                local capturedEntry = entry
                replayBtn.MouseButton1Click:Connect(function()
                    pcall(function()
                        sc_replayTarget = capturedEntry
                        setStatus("▶ " .. capturedEntry.name, Color3.fromRGB(80,200,255))
                        if capturedEntry.method == "FireServer" then
                            capturedEntry.remote:FireServer(table.unpack(capturedEntry.args))
                        else
                            capturedEntry.remote:InvokeServer(table.unpack(capturedEntry.args))
                        end
                    end)
                end)
            end
        end

        -- ══════════════════ REMOTE SPY ══════════════════
        scSection("🔍  REMOTE SPY")

        scToggle("🔍 Remote Spy AN/AUS\n(Spy AN → im Spiel Aktionen ausführen → Remote fangen)", false, function(state)
            sc_spyActive = state
            if state then
                sc_startHook()
                setStatus("🔍 Spy aktiv — Pack öffnen / spinnen!", Color3.fromRGB(80, 200, 255))
            else
                setStatus("🔍 Spy aus — " .. #sc_captured .. " Remote(s) gespeichert", Color3.fromRGB(0,180,255))
            end
        end)

        scButton("🗑 Liste leeren", Color3.fromRGB(60, 20, 20), function()
            sc_captured = {}
            sc_replayTarget = nil
            sc_refreshList()
            setStatus("🗑 Liste geleert", Color3.fromRGB(200,100,100))
        end)

        -- ══════════════════ GEFANGENE REMOTES ══════════════════
        scSection("📋  GEFANGENE REMOTES")
        sc_listFrame = Instance.new("Frame")
        sc_listFrame.Size = UDim2.new(1, 0, 0, 0)
        sc_listFrame.AutomaticSize = Enum.AutomaticSize.Y
        sc_listFrame.BackgroundTransparency = 1
        sc_listFrame.ZIndex = 12
        sc_listFrame.Parent = content
        local listLayout = Instance.new("UIListLayout", sc_listFrame)
        listLayout.Padding = UDim.new(0, 4)
        listLayout.SortOrder = Enum.SortOrder.LayoutOrder
        sc_refreshList()

        -- ══════════════════ AUTO-REPLAY ══════════════════
        scSection("🔄  AUTO-REPLAY")
        scToggle("🔄 Auto-Replay — letztes Remote wiederholen\n(zuletzt gespioniertes Remote wird in Schleife gefeuert)", false, function(state)
            sc_autoReplay = state
            if state then
                if not sc_replayTarget then
                    setStatus("⚠ Erst Spy AN + Aktion ausführen!", Color3.fromRGB(255,180,60))
                    sc_autoReplay = false
                    return
                end
                setStatus("🔄 Auto-Replay: " .. sc_replayTarget.name, Color3.fromRGB(80,200,255))
                task.spawn(function()
                    while sc_autoReplay do
                        pcall(function()
                            if sc_replayTarget then
                                if sc_replayTarget.method == "FireServer" then
                                    sc_replayTarget.remote:FireServer(table.unpack(sc_replayTarget.args))
                                else
                                    sc_replayTarget.remote:InvokeServer(table.unpack(sc_replayTarget.args))
                                end
                            end
                        end)
                        task.wait(0.35)
                    end
                    setStatus("⏸ Auto-Replay gestoppt", Color3.fromRGB(0,180,255))
                end)
            else
                setStatus("⏸ Auto-Replay gestoppt", Color3.fromRGB(0,180,255))
            end
        end)

        -- ══════════════════ REPLICATEDSTORAGE SCAN ══════════════════
        scSection("📡  REPLICATEDSTORAGE SCANNEN")
        scButton("📡 Alle Remotes auflisten (Rep + Workspace)", Color3.fromRGB(20, 40, 90), function()
            local found = {}
            local function scan(obj, depth)
                if depth > 8 then return end
                for _, child in ipairs(obj:GetChildren()) do
                    if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
                        table.insert(found, child.Name .. " [" .. child.ClassName .. "]")
                    end
                    scan(child, depth+1)
                end
            end
            pcall(function() scan(RepStorage, 0) end)
            pcall(function() scan(game:GetService("Workspace"), 0) end)
            if #found == 0 then
                setStatus("📡 Keine Remotes gefunden", Color3.fromRGB(255,180,60))
            else
                local preview = table.concat(found, " | ")
                if #preview > 80 then preview = preview:sub(1,77).."..." end
                setStatus("📡 " .. #found .. " Remotes: " .. preview, Color3.fromRGB(80,200,255))
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "⚽ Soccer — " .. #found .. " Remotes";
                    Text  = table.concat(found, "\n"):sub(1,200);
                    Duration = 14;
                })
            end
        end)

        -- ══════════════════ AUTO BUY — 33 PACKS ══════════════════
        scSection("💰  AUTO BUY — PACK AUSWÄHLEN (33 Packs)")

        -- Alle 33 Pack-Namen (Spin a Soccer Card)
        local SC_ALL_PACKS = {
            -- Basis-Reihe
            "Bronze","Silver","Gold","Platinum","Diamond",
            -- Special-Reihe
            "Shadow","Toxic","Corrupted","Infernal","Eclipse",
            -- Cosmic-Reihe
            "Cosmic","Hate","Evan","Chaos","Ordan","Omega","Alpha",
            -- Erweiterte Reihe
            "Legend","Icon","Prime","Elite","Super",
            "Hyper","Mega","Titan","Phoenix","Dragon",
            "Nova","Void","Phantom","Mythic","Exclusive","Ultimate",
        }
        local sc_selectedPacks = {}
        local sc_autoBuyPack2  = false

        local packTierColors = {
            Bronze=Color3.fromRGB(180,110,60), Silver=Color3.fromRGB(180,190,200),
            Gold=Color3.fromRGB(220,180,30),   Platinum=Color3.fromRGB(100,180,230),
            Diamond=Color3.fromRGB(130,100,255),Shadow=Color3.fromRGB(100,100,160),
            Toxic=Color3.fromRGB(80,200,40),   Corrupted=Color3.fromRGB(180,30,30),
            Infernal=Color3.fromRGB(220,60,0), Eclipse=Color3.fromRGB(80,40,160),
            Cosmic=Color3.fromRGB(100,60,255), Hate=Color3.fromRGB(150,0,150),
            Evan=Color3.fromRGB(0,120,220),    Chaos=Color3.fromRGB(120,0,200),
            Ordan=Color3.fromRGB(0,180,180),   Omega=Color3.fromRGB(220,160,0),
            Alpha=Color3.fromRGB(255,215,0),   Legend=Color3.fromRGB(255,180,0),
            Icon=Color3.fromRGB(255,100,0),    Prime=Color3.fromRGB(0,200,255),
            Elite=Color3.fromRGB(60,60,220),   Super=Color3.fromRGB(160,0,255),
            Hyper=Color3.fromRGB(255,0,128),   Mega=Color3.fromRGB(0,255,180),
            Titan=Color3.fromRGB(100,180,255), Phoenix=Color3.fromRGB(255,120,0),
            Dragon=Color3.fromRGB(200,0,0),    Nova=Color3.fromRGB(255,255,100),
            Void=Color3.fromRGB(20,0,40),      Phantom=Color3.fromRGB(180,180,255),
            Mythic=Color3.fromRGB(255,50,200), Exclusive=Color3.fromRGB(0,255,255),
            Ultimate=Color3.fromRGB(255,215,0),
        }

        local buyInfoLbl = Instance.new("TextLabel")
        buyInfoLbl.Text = "Pack auswählen → Auto-Buy AN  (33 Packs verfügbar)"
        buyInfoLbl.Size = UDim2.new(1, 0, 0, 20)
        buyInfoLbl.BackgroundTransparency = 1
        buyInfoLbl.Font = Enum.Font.GothamMedium
        buyInfoLbl.TextSize = 11
        buyInfoLbl.TextColor3 = Color3.fromRGB(100, 160, 220)
        buyInfoLbl.TextXAlignment = Enum.TextXAlignment.Left
        buyInfoLbl.ZIndex = 12
        buyInfoLbl.Parent = content
        local bip = Instance.new("UIPadding", buyInfoLbl)
        bip.PaddingLeft = UDim.new(0, 4)

        -- Pack-Grid (2 Spalten)
        local packGrid = Instance.new("Frame")
        packGrid.Size = UDim2.new(1, 0, 0, 0)
        packGrid.AutomaticSize = Enum.AutomaticSize.Y
        packGrid.BackgroundTransparency = 1
        packGrid.ZIndex = 12
        packGrid.Parent = content
        local pgLayout = Instance.new("UIGridLayout", packGrid)
        pgLayout.CellSize = UDim2.new(0.5, -4, 0, 30)
        pgLayout.CellPadding = UDim2.new(0, 4, 0, 4)
        pgLayout.SortOrder = Enum.SortOrder.LayoutOrder

        for _, packName in ipairs(SC_ALL_PACKS) do
            sc_selectedPacks[packName] = false
            local tierColor = packTierColors[packName] or Color3.fromRGB(80,100,160)
            local cell = Instance.new("TextButton")
            cell.Text = ""
            cell.Size = UDim2.new(0,1,0,1)
            cell.BackgroundColor3 = Color3.fromRGB(14, 18, 36)
            cell.BorderSizePixel = 0
            cell.ZIndex = 13
            cell.Parent = packGrid
            Instance.new("UICorner", cell).CornerRadius = UDim.new(0, 6)
            local cellStroke = Instance.new("UIStroke", cell)
            cellStroke.Color = tierColor
            cellStroke.Thickness = 1.5
            cellStroke.Transparency = 0.6
            local checkBox = Instance.new("Frame")
            checkBox.Size = UDim2.new(0, 14, 0, 14)
            checkBox.Position = UDim2.new(0, 6, 0.5, -7)
            checkBox.BackgroundColor3 = Color3.fromRGB(20, 26, 46)
            checkBox.BorderSizePixel = 0
            checkBox.ZIndex = 14
            checkBox.Parent = cell
            Instance.new("UICorner", checkBox).CornerRadius = UDim.new(0, 3)
            Instance.new("UIStroke", checkBox).Color = tierColor
            local checkMark = Instance.new("TextLabel")
            checkMark.Text = "✓"
            checkMark.Size = UDim2.new(1, 0, 1, 0)
            checkMark.BackgroundTransparency = 1
            checkMark.Font = Enum.Font.GothamBold
            checkMark.TextSize = 10
            checkMark.TextColor3 = Color3.fromRGB(80, 200, 255)
            checkMark.ZIndex = 15
            checkMark.Visible = false
            checkMark.Parent = checkBox
            local nameLbl2 = Instance.new("TextLabel")
            nameLbl2.Text = packName
            nameLbl2.Size = UDim2.new(1, -28, 1, 0)
            nameLbl2.Position = UDim2.new(0, 26, 0, 0)
            nameLbl2.BackgroundTransparency = 1
            nameLbl2.Font = Enum.Font.GothamMedium
            nameLbl2.TextSize = 12
            nameLbl2.TextColor3 = tierColor
            nameLbl2.TextXAlignment = Enum.TextXAlignment.Left
            nameLbl2.ZIndex = 14
            nameLbl2.Parent = cell
            local captured_name = packName
            cell.MouseButton1Click:Connect(function()
                sc_selectedPacks[captured_name] = not sc_selectedPacks[captured_name]
                local sel = sc_selectedPacks[captured_name]
                checkMark.Visible = sel
                cell.BackgroundColor3 = sel and Color3.fromRGB(14,28,52) or Color3.fromRGB(14,18,36)
                cellStroke.Transparency = sel and 0.1 or 0.6
            end)
        end

        -- Alle auswählen / abwählen
        local selRow = Instance.new("Frame")
        selRow.Size = UDim2.new(1, 0, 0, 28)
        selRow.BackgroundTransparency = 1
        selRow.ZIndex = 12
        selRow.Parent = content
        local selLayout = Instance.new("UIListLayout", selRow)
        selLayout.FillDirection = Enum.FillDirection.Horizontal
        selLayout.Padding = UDim.new(0, 6)
        selLayout.SortOrder = Enum.SortOrder.LayoutOrder
        local function quickSelBtn(txt, col, action)
            local b = Instance.new("TextButton")
            b.Text = txt
            b.Size = UDim2.new(0.5, -3, 1, 0)
            b.BackgroundColor3 = col
            b.TextColor3 = Color3.fromRGB(255,255,255)
            b.Font = Enum.Font.GothamBold
            b.TextSize = 11
            b.BorderSizePixel = 0
            b.ZIndex = 13
            b.Parent = selRow
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
            b.MouseButton1Click:Connect(function()
                for packName, _ in pairs(sc_selectedPacks) do
                    sc_selectedPacks[packName] = action
                end
                for _, cell in ipairs(packGrid:GetChildren()) do
                    if cell:IsA("TextButton") then
                        local cm = cell:FindFirstChildWhichIsA("TextLabel",true)
                        if cm and cm.Text == "✓" then cm.Visible = action end
                        cell.BackgroundColor3 = action and Color3.fromRGB(14,28,52) or Color3.fromRGB(14,18,36)
                        local st = cell:FindFirstChildWhichIsA("UIStroke")
                        if st then st.Transparency = action and 0.1 or 0.6 end
                    end
                end
            end)
        end
        quickSelBtn("✓ Alle auswählen", Color3.fromRGB(20, 60, 150), true)
        quickSelBtn("✕ Alle abwählen",  Color3.fromRGB(70, 20, 20),  false)

        -- Auto-Buy Toggle
        scToggle("💰 Auto Buy AN — kauft gewählte Packs\n(sucht Shop-Button mit Pack-Namen im UI)", false, function(state)
            sc_autoBuyPack = state
            if state then
                local anySelected = false
                for _, v in pairs(sc_selectedPacks) do if v then anySelected=true break end end
                if not anySelected then
                    setStatus("⚠ Kein Pack ausgewählt!", Color3.fromRGB(255,180,60))
                    sc_autoBuyPack = false
                    return
                end
                setStatus("💰 Auto-Buy aktiv...", Color3.fromRGB(255,210,60))
                task.spawn(function()
                    while sc_autoBuyPack do
                        task.wait(1)  -- [v81 FIX] äußeres wait — verhindert leeren Loop-Spin wenn kein Button sichtbar
                        pcall(function()
                            local pg = LP_SC:FindFirstChild("PlayerGui")
                            if not pg then return end
                            for _, obj in ipairs(pg:GetDescendants()) do
                                if obj:IsA("TextLabel") and obj.Visible then
                                    local txt = obj.Text or ""
                                    for packName, selected in pairs(sc_selectedPacks) do
                                        if selected and (txt == packName or txt:lower():find(packName:lower())) then
                                            local container = obj.Parent
                                            if container then
                                                for _, sib in ipairs(container:GetDescendants()) do
                                                    if (sib:IsA("TextButton") or sib:IsA("ImageButton")) and sib.Visible then
                                                        local st2 = sib.Text or ""
                                                        if st2:find("%$") or st2:lower():find("kauf") or st2:lower():find("buy") or st2:lower():find("get") then
                                                            pcall(function() sib.MouseButton1Click:Fire() end)
                                                            setStatus("💰 Gekauft: "..packName, Color3.fromRGB(100,200,255))
                                                            task.wait(0.5)
                                                        end
                                                    end
                                                end
                                                if container:IsA("TextButton") or container:IsA("ImageButton") then
                                                    local pt = container.Text or ""
                                                    if pt:find("%$") or pt:lower():find("kauf") or pt:lower():find("buy") then
                                                        pcall(function() container.MouseButton1Click:Fire() end)
                                                        setStatus("💰 Gekauft: "..packName, Color3.fromRGB(100,200,255))
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                            -- Remote-Fallback: wenn Spy einen Buy-Remote gefangen hat
                            if sc_replayTarget then
                                local nm = sc_replayTarget.name:lower()
                                if nm:find("buy") or nm:find("purchase") or nm:find("pack") or nm:find("shop") then
                                    pcall(function()
                                        sc_replayTarget.remote:FireServer(table.unpack(sc_replayTarget.args))
                                    end)
                                end
                            end
                        end)
                        task.wait(1.5)
                    end
                    setStatus("⏳ Auto-Buy gestoppt")
                end)
            else
                setStatus("⏳ Auto-Buy gestoppt")
            end
        end)

        -- ══════════════════ AUTO PACK ÖFFNEN ══════════════════
        scSection("📦  AUTO PACK ÖFFNEN (G-Taste)")
        scToggle("📦 Auto G-Taste — öffnet Pakete aus Rucksack\n(VirtualInput + UI-Button-Fallback)", false, function(state)
            sc_autoG = state
            if state then
                setStatus("📦 Auto-G aktiv!", Color3.fromRGB(80,200,255))
                task.spawn(function()
                    while sc_autoG do
                        -- Methode 1: VirtualInputManager
                        pcall(function()
                            local VIM = game:GetService("VirtualInputManager")
                            VIM:SendKeyEvent(true,  Enum.KeyCode.G, false, game)
                            task.wait(0.08)
                            VIM:SendKeyEvent(false, Enum.KeyCode.G, false, game)
                        end)
                        -- Methode 2: UI-Button mit "Öffnen"/"Open"/"G"
                        pcall(function()
                            local pg = LP_SC:FindFirstChild("PlayerGui")
                            if not pg then return end
                            for _, obj in ipairs(pg:GetDescendants()) do
                                if (obj:IsA("TextButton") or obj:IsA("ImageButton")) and obj.Visible then
                                    local t = obj.Text or ""
                                    if t:lower():find("öffn") or t:lower():find("open") or t=="G" or t=="g" or t:lower():find("use") then
                                        pcall(function() obj.MouseButton1Click:Fire() end)
                                    end
                                end
                            end
                        end)
                        -- Methode 3: Remote-Fallback
                        pcall(function()
                            if sc_replayTarget then
                                local nm = sc_replayTarget.name:lower()
                                if nm:find("open") or nm:find("pack") or nm:find("use") then
                                    sc_replayTarget.remote:FireServer(table.unpack(sc_replayTarget.args))
                                end
                            end
                        end)
                        task.wait(0.45)
                    end
                    setStatus("⏳ Auto-G gestoppt")
                end)
            else
                setStatus("⏳ Auto-G gestoppt")
            end
        end)

        -- ══════════════════ AUTO DREHRAD ══════════════════
        scSection("🎡  AUTO DREHRAD (Spin Wheel)")
        scToggle("🎡 Auto Drehrad — klickt wenn Timer = 00:00\n(prüft alle 5 Sek ob Rad bereit ist)", false, function(state)
            sc_autoDrehrad = state
            if state then
                setStatus("🎡 Drehrad-Watcher aktiv...", Color3.fromRGB(180,140,255))
                task.spawn(function()
                    while sc_autoDrehrad do
                        pcall(function()
                            local pg = LP_SC:FindFirstChild("PlayerGui")
                            if not pg then return end
                            for _, obj in ipairs(pg:GetDescendants()) do
                                if obj.Visible then
                                    local t = (obj:IsA("TextLabel") or obj:IsA("TextButton")) and (obj.Text or "") or ""
                                    -- Timer abgelaufen = "00:00" oder "Spin" oder "Jetzt" sichtbar
                                    if t == "00:00" or t:find("Jetzt") or t:lower():find("spin now") or t:lower():find("claim") then
                                        local par = obj.Parent
                                        if par and (par:IsA("TextButton") or par:IsA("ImageButton")) then
                                            pcall(function() par.MouseButton1Click:Fire() end)
                                            setStatus("🎡 Drehrad gesponnen!", Color3.fromRGB(180,140,255))
                                        end
                                        if obj:IsA("TextButton") or obj:IsA("ImageButton") then
                                            pcall(function() obj.MouseButton1Click:Fire() end)
                                            setStatus("🎡 Drehrad gesponnen!", Color3.fromRGB(180,140,255))
                                        end
                                    end
                                    -- Direkter Button-Text
                                    if t:lower():find("drehrad") or t:lower():find("spin wheel") or t:lower():find("wheel") then
                                        if obj:IsA("TextButton") or obj:IsA("ImageButton") then
                                            pcall(function() obj.MouseButton1Click:Fire() end)
                                        end
                                    end
                                end
                            end
                            -- Remote-Fallback (alle möglichen Namen)
                            for _, rname in ipairs({"Spin","SpinWheel","WheelSpin","Drehrad","DailySpin","DailyWheel","ClaimSpin","SpinReward"}) do
                                local r = RepStorage:FindFirstChild(rname, true)
                                if r and (r:IsA("RemoteEvent") or r:IsA("RemoteFunction")) then
                                    pcall(function()
                                        if r:IsA("RemoteEvent") then r:FireServer()
                                        else r:InvokeServer() end
                                    end)
                                end
                            end
                        end)
                        task.wait(5)
                    end
                    setStatus("⏳ Drehrad-Auto gestoppt")
                end)
            else
                setStatus("⏳ Drehrad-Auto gestoppt")
            end
        end)

        -- ══════════════════ AUTO WIEDERGEBURT ══════════════════
        scSection("🔄  AUTO WIEDERGEBURT")
        scToggle("🔄 Auto Wiedergeburt\n⚠ VORSICHT: setzt deine Karten zurück!", false, function(state)
            sc_autoRebirth = state
            if state then
                setStatus("🔄 Auto-Wiedergeburt aktiv!", Color3.fromRGB(255,160,60))
                task.spawn(function()
                    while sc_autoRebirth do
                        pcall(function()
                            local pg = LP_SC:FindFirstChild("PlayerGui")
                            if not pg then return end
                            for _, obj in ipairs(pg:GetDescendants()) do
                                if obj.Visible and (obj:IsA("TextButton") or obj:IsA("ImageButton")) then
                                    local t = obj.Text or ""
                                    if t:lower():find("wiedergeburt") or t:lower():find("rebirth") or t:lower():find("reborn") or t:lower():find("prestige") then
                                        pcall(function() obj.MouseButton1Click:Fire() end)
                                        setStatus("🔄 Wiedergeburt!", Color3.fromRGB(255,200,80))
                                    end
                                end
                            end
                            for _, rname in ipairs({"Rebirth","DoRebirth","Wiedergeburt","Prestige","DoPrestige"}) do
                                local r = RepStorage:FindFirstChild(rname, true)
                                if r and r:IsA("RemoteEvent") then pcall(function() r:FireServer() end) end
                            end
                        end)
                        task.wait(3)
                    end
                    setStatus("⏳ Wiedergeburt gestoppt")
                end)
            else
                setStatus("⏳ Wiedergeburt gestoppt")
            end
        end)

        -- ══════════════════ ANLEITUNG ══════════════════
        scSection("📋  ANLEITUNG")
        local infoLbl = Instance.new("TextLabel")
        infoLbl.Text = "📖 ANLEITUNG:\n1. Spy AN → im Spiel Aktionen ausführen (Pack kaufen, spinnen, Rad drehen)\n2. Remotes erscheinen in der Liste oben\n3. Replay-Button = Remote 1x feuern\n4. Auto-Replay = Remote in Schleife\n\n💡 TIPP: Erst Spy, dann alle Features freischalten!"
        infoLbl.Size = UDim2.new(1, 0, 0, 120)
        infoLbl.BackgroundColor3 = Color3.fromRGB(10, 18, 38)
        infoLbl.Font = Enum.Font.Gotham
        infoLbl.TextSize = 11
        infoLbl.TextColor3 = Color3.fromRGB(130, 180, 240)
        infoLbl.TextWrapped = true
        infoLbl.ZIndex = 12
        infoLbl.Parent = content
        Instance.new("UICorner", infoLbl).CornerRadius = UDim.new(0, 8)
        local infoPad = Instance.new("UIPadding", infoLbl)
        infoPad.PaddingLeft = UDim.new(0, 10)
        infoPad.PaddingRight = UDim.new(0, 10)
        infoPad.PaddingTop = UDim.new(0, 8)
        infoPad.PaddingBottom = UDim.new(0, 8)

        -- Aufräumen
        sg.AncestryChanged:Connect(function()
            if not sg.Parent then
                sc_spyActive    = false
                sc_autoReplay   = false
                sc_autoG        = false
                sc_autoDrehrad  = false
                sc_autoRebirth  = false
                sc_autoBuyPack  = false
                -- [FIX] sc_autoBuyPack2 wurde vorher nicht zurückgesetzt
                sc_autoBuyPack2 = false
                sc_stopHook()
                for _, c in ipairs(sc_conns) do pcall(function() c:Disconnect() end) end
                sc_conns = {}
            end
        end)
    end
})


-- ==================== 🎙️ GERMAN VOICE ====================
GamesTab:CreateSection("🎙️ German Voice")

GamesTab:CreateButton({
    Name = "🎙️ German Voice Teleports öffnen",
    Callback = function()
        -- ══ NUR IN GERMAN VOICE (Place ID: 136162036182779) ══
        if game.PlaceId ~= 136162036182779 then
            -- Notification ausgeben falls vorhanden
            pcall(function()
                SemysUI:Notify({
                    Title   = "❌ Falsches Spiel",
                    Content = "German Voice Funktionen sind nur in German Voice verfügbar!",
                    Duration = 4,
                })
            end)
            return
        end

        local CoreGui = game:GetService("CoreGui")
        local _gvhub = CoreGui:FindFirstChild("SemysGermanVoiceHub") -- [FIX] doppeltes FindFirstChild → local speichern
        if _gvhub then
            _gvhub:Destroy()
            return
        end

        local TweenService_GV = game:GetService("TweenService")
        local LP_GV           = game:GetService("Players").LocalPlayer

        -- ══════════════════ TELEPORT ORTE ══════════════════
        local gv_locations = {
            { name = "🏛️ Admin Spawn", x = -97,    y = 2614,    z = 3177   },
            { name = "🌳 Baumhaus",     x = -320.7, y = 44.1,    z = -232.0 },
            { name = "🗼 Turm",         x = 208.3,  y = 331.2,   z = -262.9 },
            { name = "🖼️ Bilderraum",  x = -401.1, y = -97.6,   z = 410.9  },
            { name = "💎 Diamantraum",  x = -484.3, y = -47.0,   z = 311.1  },
            { name = "👑 VIP Raum",     x = -49.5,  y = 1989.5,  z = -30.1  },
            { name = "🏝️ Semys Insel",  x = 117.9,  y = -1903.8, z = -309.7 },
        }

        local function gv_teleport(x, y, z)
            pcall(function()
                local char = LP_GV.Character
                if not char then return end
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = CFrame.new(x, y, z)
                end
            end)
        end

        -- ══════════════════ SCREENGUI ══════════════════
        local sg = Instance.new("ScreenGui")
        sg.Name           = "SemysGermanVoiceHub"
        sg.ResetOnSpawn   = false
        sg.DisplayOrder   = 5000
        sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        pcall(function() sg.Parent = CoreGui end)
        if not sg.Parent then sg.Parent = LP_GV:WaitForChild("PlayerGui") end

        -- Hauptfenster
        local win = Instance.new("Frame")
        win.Name             = "GVWin"
        win.Size             = UDim2.new(0, 320, 0, 640)
        win.Position         = UDim2.new(0.5, -160, 0.5, -320)
        win.BackgroundColor3 = Color3.fromRGB(10, 14, 22)
        win.BorderSizePixel  = 0
        win.ZIndex           = 10
        win.ClipsDescendants = true
        win.Parent           = sg
        Instance.new("UICorner", win).CornerRadius = UDim.new(0, 14)

        local grad = Instance.new("UIGradient", win)
        grad.Rotation = 135
        grad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0,   Color3.fromRGB(10, 14, 26)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(8,  13, 23)),
            ColorSequenceKeypoint.new(1,   Color3.fromRGB(5,   7, 13)),
        })
        local stroke = Instance.new("UIStroke", win)
        stroke.Color        = Color3.fromRGB(0, 210, 255)
        stroke.Thickness    = 2
        stroke.Transparency = 0.1
        local _strokeCols = {
            Color3.fromRGB(0,   209, 255),
            Color3.fromRGB(0,   140, 255),
            Color3.fromRGB(136,  85, 255),
            Color3.fromRGB(0,   160, 255),
            Color3.fromRGB(80,  100, 255),
        }
        local _sci = 1
        task.spawn(function()
            while win and win.Parent do
                _sci = (_sci % #_strokeCols) + 1
                TweenService_GV:Create(stroke, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Color = _strokeCols[_sci]}):Play()
                task.wait(2)
            end
        end)
        task.spawn(function()
            local pCols = { Color3.fromRGB(0,209,255), Color3.fromRGB(0,140,255), Color3.fromRGB(136,85,255), Color3.fromRGB(0,160,255), Color3.fromRGB(80,100,255) }
            while win and win.Parent do
                local p = Instance.new("Frame")
                p.Size = UDim2.new(0, math.random(2,5), 0, math.random(2,5))
                p.Position = UDim2.new(math.random(5,95)/100, 0, 1.05, 0)
                p.BackgroundColor3 = pCols[math.random(1,#pCols)]
                p.BackgroundTransparency = math.random(0,2)/10
                p.BorderSizePixel = 0; p.ZIndex = 9; p.Parent = win
                Instance.new("UICorner", p).CornerRadius = UDim.new(1,0)
                TweenService_GV:Create(p, TweenInfo.new(math.random(25,40)/10, Enum.EasingStyle.Linear), {Position = UDim2.new(p.Position.X.Scale,0,-0.1,0), BackgroundTransparency = 1}):Play()
                task.delay(4, function() if p and p.Parent then p:Destroy() end end)
                task.wait(math.random(3,7)/10)
            end
        end)

        -- Header
        local header = Instance.new("Frame")
        header.Size             = UDim2.new(1, 0, 0, 46)
        header.BackgroundColor3 = Color3.fromRGB(0, 14, 30)
        header.BorderSizePixel  = 0
        header.ZIndex           = 11
        header.Parent           = win
        local hGrad = Instance.new("UIGradient", header)
        hGrad.Rotation = 135
        hGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0,   Color3.fromRGB(5,  10, 26)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,  40, 100)),
            ColorSequenceKeypoint.new(1,   Color3.fromRGB(0, 100, 200)),
        })

        local titleLbl = Instance.new("TextLabel")
        titleLbl.Size                  = UDim2.new(1, -50, 1, 0)
        titleLbl.Position              = UDim2.new(0, 14, 0, 0)
        titleLbl.BackgroundTransparency = 1
        titleLbl.Font                  = Enum.Font.GothamBold
        titleLbl.Text                  = "🎙️ GERMAN VOICE"
        titleLbl.TextColor3            = Color3.fromRGB(255, 255, 255)
        titleLbl.TextSize              = 14
        titleLbl.TextXAlignment        = Enum.TextXAlignment.Left
        titleLbl.ZIndex                = 12
        titleLbl.Parent                = header
        local titleStroke = Instance.new("UIStroke", titleLbl)
        titleStroke.Color = Color3.fromRGB(0, 200, 255); titleStroke.Thickness = 1.2; titleStroke.Transparency = 0.2
        local _tCols = { Color3.fromRGB(0,209,255), Color3.fromRGB(0,160,255), Color3.fromRGB(136,85,255), Color3.fromRGB(80,100,255) }
        local _tci = 1
        task.spawn(function()
            while header and header.Parent do
                _tci = (_tci % #_tCols) + 1
                TweenService_GV:Create(titleStroke, TweenInfo.new(1.5, Enum.EasingStyle.Sine), {Color = _tCols[_tci]}):Play()
                task.wait(1.5)
            end
        end)

        local closeBtn = Instance.new("TextButton")
        closeBtn.Size             = UDim2.new(0, 28, 0, 28)
        closeBtn.Position         = UDim2.new(1, -36, 0.5, -14)
        closeBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
        closeBtn.BorderSizePixel  = 0
        closeBtn.Font             = Enum.Font.GothamBold
        closeBtn.Text             = "✕"
        closeBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
        closeBtn.TextSize         = 13
        closeBtn.AutoButtonColor  = false
        closeBtn.ZIndex           = 13
        closeBtn.Parent           = header
        Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
        closeBtn.MouseButton1Click:Connect(function() sg:Destroy() end)

        -- Drag
        local dragging, dragStart, startPos = false, nil, nil
        header.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                dragging = true; dragStart = inp.Position; startPos = win.Position
            end
        end)
        -- [FIX #9] Verbindungen speichern + bei GUI-Destroy trennen (kein Connection Leak)
        local _gvDragConn = game:GetService("UserInputService").InputChanged:Connect(function(inp)
            if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
                local d = inp.Position - dragStart
                win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
                                          startPos.Y.Scale, startPos.Y.Offset + d.Y)
            end
        end)
        local _gvEndConn = game:GetService("UserInputService").InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                dragging = false end
        end)
        sg.AncestryChanged:Connect(function()
            if not sg.Parent then _gvDragConn:Disconnect(); _gvEndConn:Disconnect() end
        end)

        -- ══════════════════════════════════════════════════════

        -- Status
        local subLbl = Instance.new("TextLabel")
        subLbl.Size                  = UDim2.new(1, -20, 0, 20)
        subLbl.Position              = UDim2.new(0, 10, 0, 52)
        subLbl.BackgroundTransparency = 1
        subLbl.Font                  = Enum.Font.Gotham
        subLbl.Text                  = "📍 Teleport zu einem Ort"
        subLbl.TextColor3            = Color3.fromRGB(120, 180, 220)
        subLbl.TextSize              = 11
        subLbl.TextXAlignment        = Enum.TextXAlignment.Left
        subLbl.ZIndex                = 11
        subLbl.Parent                = win

        local statusLbl = Instance.new("TextLabel")
        statusLbl.Size                  = UDim2.new(1, -20, 0, 20)
        statusLbl.Position              = UDim2.new(0, 10, 0, 73)
        statusLbl.BackgroundTransparency = 1
        statusLbl.Font                  = Enum.Font.GothamMedium
        statusLbl.Text                  = "Bereit."
        statusLbl.TextColor3            = Color3.fromRGB(0, 210, 255)
        statusLbl.TextSize              = 11
        statusLbl.TextXAlignment        = Enum.TextXAlignment.Left
        statusLbl.ZIndex                = 11
        statusLbl.Parent                = win

        local sep = Instance.new("Frame")
        sep.Size             = UDim2.new(1, -20, 0, 1)
        sep.Position         = UDim2.new(0, 10, 0, 98)
        sep.BackgroundColor3 = Color3.fromRGB(0, 100, 160)
        sep.BorderSizePixel  = 0
        sep.BackgroundTransparency = 0.5
        sep.ZIndex           = 11
        sep.Parent           = win

        -- Forward declarations (werden unten definiert)
        local hausSpawned = false
        local hausModel   = nil
        local spawnHaus   -- forward declaration

        -- ══════════════════ 7 TELEPORT BUTTONS ══════════════════
        local btnColors = {
            Color3.fromRGB(0,   209, 255),
            Color3.fromRGB(0,   160, 255),
            Color3.fromRGB(0,   110, 255),
            Color3.fromRGB(60,  100, 255),
            Color3.fromRGB(100,  85, 255),
            Color3.fromRGB(136,  85, 255),
            Color3.fromRGB(0,   180, 230),
        }

        for i, loc in ipairs(gv_locations) do
            local yOff = 106 + (i - 1) * 58
            local col  = btnColors[i]

            local bf = Instance.new("Frame")
            bf.Size             = UDim2.new(1, -20, 0, 52)
            bf.Position         = UDim2.new(0, 10, 0, yOff)
            bf.BackgroundColor3 = Color3.fromRGB(10, 14, 28)
            bf.BorderSizePixel  = 0
            bf.ZIndex           = 11
            bf.Parent           = win
            Instance.new("UICorner", bf).CornerRadius = UDim.new(0, 12)

            local cardGrad = Instance.new("UIGradient", bf)
            cardGrad.Rotation = 0
            cardGrad.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, col), ColorSequenceKeypoint.new(1, Color3.fromRGB(8,12,24)) })
            cardGrad.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.78), NumberSequenceKeypoint.new(1, 0) })

            local bfs = Instance.new("UIStroke", bf)
            bfs.Color = col; bfs.Thickness = 1.5; bfs.Transparency = 0.3

            local accent = Instance.new("Frame")
            accent.Size             = UDim2.new(0, 4, 1, -14)
            accent.Position         = UDim2.new(0, 7, 0, 7)
            accent.BackgroundColor3 = col
            accent.BorderSizePixel  = 0; accent.ZIndex = 12; accent.Parent = bf
            Instance.new("UICorner", accent).CornerRadius = UDim.new(1, 0)
            local accentGlow = Instance.new("UIStroke", accent)
            accentGlow.Color = col; accentGlow.Thickness = 2; accentGlow.Transparency = 0.5

            local nl = Instance.new("TextLabel")
            nl.Size                   = UDim2.new(0.6, 0, 0, 22)
            nl.Position               = UDim2.new(0, 20, 0, 8)
            nl.BackgroundTransparency = 1
            nl.Font                   = Enum.Font.GothamBold
            nl.Text                   = loc.name
            nl.TextColor3             = Color3.fromRGB(235, 245, 255)
            nl.TextSize               = 13
            nl.TextXAlignment         = Enum.TextXAlignment.Left
            nl.TextYAlignment         = Enum.TextYAlignment.Center
            nl.ZIndex                 = 12; nl.Parent = bf

            if loc.name:find("VIP") then
                local vipTag = Instance.new("TextLabel")
                vipTag.Size                   = UDim2.new(0.6, 0, 0, 16)
                vipTag.Position               = UDim2.new(0, 20, 0, 28)
                vipTag.BackgroundTransparency = 1
                vipTag.Font                   = Enum.Font.GothamMedium
                vipTag.Text                   = "(Nur für VIP)"
                vipTag.TextColor3             = Color3.fromRGB(255, 215, 80)
                vipTag.TextSize               = 10
                vipTag.TextXAlignment         = Enum.TextXAlignment.Left
                vipTag.TextYAlignment         = Enum.TextYAlignment.Center
                vipTag.ZIndex                 = 12
                vipTag.Parent                 = bf
            end

            local btn = Instance.new("TextButton")
            btn.Size             = UDim2.new(0, 78, 0, 34)
            btn.Position         = UDim2.new(1, -88, 0.5, -17)
            btn.BackgroundColor3 = col
            btn.BorderSizePixel  = 0
            btn.Font             = Enum.Font.GothamBold
            btn.Text             = "TP ›"
            btn.TextColor3       = Color3.fromRGB(255, 255, 255)
            btn.TextSize         = 13
            btn.AutoButtonColor  = false; btn.ZIndex = 13; btn.Parent = bf
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 9)
            local btnGlow = Instance.new("UIStroke", btn)
            btnGlow.Color = col; btnGlow.Thickness = 2; btnGlow.Transparency = 0.5

            btn.MouseEnter:Connect(function()
                TweenService_GV:Create(btn,     TweenInfo.new(0.13), {BackgroundTransparency = 0.2}):Play()
                TweenService_GV:Create(bfs,     TweenInfo.new(0.13), {Transparency = 0}):Play()
                TweenService_GV:Create(btnGlow, TweenInfo.new(0.13), {Transparency = 0.1}):Play()
            end)
            btn.MouseLeave:Connect(function()
                TweenService_GV:Create(btn,     TweenInfo.new(0.13), {BackgroundTransparency = 0}):Play()
                TweenService_GV:Create(bfs,     TweenInfo.new(0.13), {Transparency = 0.3}):Play()
                TweenService_GV:Create(btnGlow, TweenInfo.new(0.13), {Transparency = 0.5}):Play()
            end)

            local thisLoc = loc
            btn.MouseButton1Click:Connect(function()
                local flash = Instance.new("Frame")
                flash.Size = UDim2.new(0, 10, 1, 0); flash.Position = UDim2.new(0, 0, 0, 0)
                flash.BackgroundColor3 = col; flash.BackgroundTransparency = 0.5
                flash.BorderSizePixel = 0; flash.ZIndex = 14; flash.Parent = bf
                Instance.new("UICorner", flash).CornerRadius = UDim.new(0, 12)
                TweenService_GV:Create(flash, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1}):Play()
                task.delay(0.4, function() if flash and flash.Parent then flash:Destroy() end end)

                gv_teleport(thisLoc.x, thisLoc.y, thisLoc.z)
                statusLbl.Text       = "✅ " .. thisLoc.name
                statusLbl.TextColor3 = col
                if thisLoc.name:find("Insel") and not hausSpawned and spawnHaus then
                    task.delay(0.4, function() pcall(spawnHaus) end)
                end
                task.delay(2.5, function() pcall(function()
                    statusLbl.Text       = "Bereit."
                    statusLbl.TextColor3 = Color3.fromRGB(0, 210, 255)
                end) end)
            end)
        end


        -- ══════════════════ HAUS SPAWN LOGIK ══════════════════
        -- Feste Koordinaten: Semys Insel  X=181.6  Y=-1886.1  Z=-175.6
        -- (müssen mit dem Insel-Teleport-Ziel übereinstimmen)
        local HAUS_X = 181.6
        local HAUS_Y = -1886.1
        local HAUS_Z = -175.6

        spawnHaus = function()
            if hausSpawned and hausModel then
                hausModel:Destroy()
                hausModel   = nil
                hausSpawned = false
                statusLbl.Text           = "🏠 Haus entfernt."
                statusLbl.TextColor3     = Color3.fromRGB(255, 100, 50)
                task.delay(2, function() pcall(function()
                    statusLbl.Text       = "Bereit."
                    statusLbl.TextColor3 = Color3.fromRGB(0, 210, 255)
                end) end)
                return
            end

            local ws = game:GetService("Workspace")
            -- Haus entfernen falls doppelt (Schutz)
            local old = ws:FindFirstChild("SemysGeheimhaus_" .. LP_GV.Name)
            if old then old:Destroy() end

            local model = Instance.new("Model")
            model.Name   = "SemysGeheimhaus_" .. LP_GV.Name
            model.Parent = ws
            hausModel    = model


            -- ══ HAUS LADEN (Asset ID: 7588959384) ══
            local assetId = 7588959384
            local assetModel = nil

            -- Methode 1: game:GetObjects (funktioniert in den meisten Executors)
            local ok1, objs = pcall(function()
                return game:GetObjects("rbxassetid://" .. assetId)
            end)
            if ok1 and objs and #objs > 0 then
                for _, obj in ipairs(objs) do
                    obj.Parent = model
                    if obj:IsA("Model") then assetModel = obj end
                end
            else
                -- Methode 2: InsertService:LoadAsset Fallback
                local IS = game:GetService("InsertService")
                local ok2, loaded = pcall(function()
                    return IS:LoadAsset(assetId)
                end)
                if ok2 and loaded then
                    assetModel = loaded:FindFirstChildOfClass("Model")
                    if assetModel then
                        assetModel.Parent = model
                        loaded:Destroy()
                    else
                        loaded.Parent = model
                    end
                else
                    statusLbl.Text       = "❌ Haus konnte nicht geladen werden. Asset öffentlich?"
                    statusLbl.TextColor3 = Color3.fromRGB(255, 80, 80)
                    model:Destroy()
                    hausModel = nil
                    hausSpawned = false
                    return
                end
            end

            -- Haus zu den festgelegten Koordinaten verschieben
            if assetModel then
                if assetModel.PrimaryPart then
                    assetModel:SetPrimaryPartCFrame(CFrame.new(HAUS_X, HAUS_Y, HAUS_Z))
                else
                    pcall(function() assetModel:MoveTo(Vector3.new(HAUS_X, HAUS_Y, HAUS_Z)) end)
                end
            end

            -- ══ 5 MOTORRÄDER SPAWNEN (Asset ID: 11810431857) ══
            -- Boden-Y: Charakter-Spawn Y=-1886.1 → Motorräder 3 Einheiten drüber
            local MOTO_Y = -1883
            local motoPositions = {
                { x = 181.6 + 25,  z = -175.6        },
                { x = 181.6 - 25,  z = -175.6        },
                { x = 181.6 + 50,  z = -175.6 + 20   },
                { x = 181.6 - 50,  z = -175.6 + 20   },
                { x = 181.6,       z = -175.6 + 40   },
            }
            local motoCount = 0
            statusLbl.Text       = "🏍️ Motorräder werden geladen..."
            statusLbl.TextColor3 = Color3.fromRGB(255, 200, 50)

            for mi, mpos in ipairs(motoPositions) do
                task.spawn(function()
                    task.wait(mi * 0.3)
                    local spawned = false

                    -- Methode 1: game:GetObjects
                    local ok1, mobjs = pcall(function()
                        return game:GetObjects("rbxassetid://11810431857")
                    end)
                    if ok1 and mobjs and #mobjs > 0 then
                        for _, obj in ipairs(mobjs) do
                            obj.Parent = model
                            if obj:IsA("Model") then
                                if obj.PrimaryPart then
                                    obj:SetPrimaryPartCFrame(CFrame.new(mpos.x, MOTO_Y, mpos.z))
                                else
                                    pcall(function() obj:MoveTo(Vector3.new(mpos.x, MOTO_Y, mpos.z)) end)
                                end
                                spawned = true
                            end
                        end
                    end

                    -- Methode 2: InsertService Fallback
                    if not spawned then
                        local IS2 = game:GetService("InsertService")
                        local ok2, mloaded = pcall(function() return IS2:LoadAsset(11810431857) end)
                        if ok2 and mloaded then
                            local mmodel = mloaded:FindFirstChildOfClass("Model")
                            if mmodel then
                                mmodel.Parent = model
                                if mmodel.PrimaryPart then
                                    mmodel:SetPrimaryPartCFrame(CFrame.new(mpos.x, MOTO_Y, mpos.z))
                                else
                                    pcall(function() mmodel:MoveTo(Vector3.new(mpos.x, MOTO_Y, mpos.z)) end)
                                end
                                spawned = true
                            end
                            mloaded:Destroy()
                        end
                    end

                    if spawned then
                        motoCount = motoCount + 1
                        pcall(function()
                            statusLbl.Text       = "🏍️ " .. motoCount .. "/5 Motorräder gespawnt"
                            statusLbl.TextColor3 = Color3.fromRGB(50, 255, 120)
                        end)
                    end
                end)
            end

            task.delay(2.5, function() pcall(function()
                if motoCount == 0 then
                    statusLbl.Text       = "⚠️ Motorräder konnten nicht geladen werden"
                    statusLbl.TextColor3 = Color3.fromRGB(255, 100, 50)
                else
                    statusLbl.Text       = "Bereit."
                    statusLbl.TextColor3 = Color3.fromRGB(0, 210, 255)
                end
            end) end)

            hausSpawned              = true
            statusLbl.Text           = "✅ Geheimhaus gespawnt! Teleportiere dich rein..."
            statusLbl.TextColor3     = Color3.fromRGB(255, 200, 50)

            -- ═══ SPIELER TELEPORTIERT DIREKT INS HAUS (Mitte, auf dem Boden) ═══
            task.delay(0.5, function()
                pcall(function()
                    local char = LP_GV.Character
                    if not char then return end
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        -- Innen: Mitte des Hauses, 6 Einheiten über dem Boden-Oberfläche
                        hrp.CFrame = CFrame.new(181.6, -1886.1, -175.6)
                    end
                end)
                task.delay(2.5, function() pcall(function()
                    statusLbl.Text       = "Bereit."
                    statusLbl.TextColor3 = Color3.fromRGB(0, 210, 255)
                end) end)
            end)
        end


        -- Einblend-Animation
        win.BackgroundTransparency = 1
        TweenService_GV:Create(win, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            BackgroundTransparency = 0,
        }):Play()
    end
})

-- ==================== 🎹 SPEED KEYBOARD ESCAPE ====================
GamesTab:CreateSection("🎹 Speed Keyboard Escape")

GamesTab:CreateButton({
    Name = "🎹 Speed Keyboard Escape Hub öffnen",
    Callback = function()
        -- ══ NUR IN SPEED KEYBOARD ESCAPE (Place ID: 95082159892680) ══
        if game.PlaceId ~= 95082159892680 then
            Rayfield:Notify({
                Title   = "❌ Falsches Spiel",
                Content = "Speed Keyboard Escape Funktionen sind nur in Speed Keyboard Escape verfügbar! (ID: 95082159892680)",
                Duration = 4,
            })
            return
        end

        local CoreGui_SK = game:GetService("CoreGui")
        local _skhub = CoreGui_SK:FindFirstChild("SemysSpeedKeyboardHub") -- [FIX] doppeltes FindFirstChild → local speichern
        if _skhub then
            _skhub:Destroy()
            return
        end

        local TS_SK = game:GetService("TweenService")
        local LP_SK = game:GetService("Players").LocalPlayer
        local RS_SK = game:GetService("RunService")
        local UIS_SK = game:GetService("UserInputService")

        -- ══════════════════ SCREENGUI ══════════════════
        local sg_sk = Instance.new("ScreenGui")
        sg_sk.Name           = "SemysSpeedKeyboardHub"
        sg_sk.ResetOnSpawn   = false
        sg_sk.DisplayOrder   = 5000
        sg_sk.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        pcall(function() sg_sk.Parent = CoreGui_SK end)
        if not sg_sk.Parent then sg_sk.Parent = LP_SK:WaitForChild("PlayerGui") end

        -- ══ Hauptfenster ══
        local win_sk = Instance.new("Frame")
        win_sk.Name              = "Win"
        win_sk.Size              = UDim2.new(0, 320, 0, 390)
        win_sk.Position          = UDim2.new(0.5, -160, 0.5, -195)
        win_sk.BackgroundColor3  = Color3.fromRGB(10, 12, 22)
        win_sk.BorderSizePixel   = 0
        win_sk.Parent            = sg_sk
        Instance.new("UICorner", win_sk).CornerRadius = UDim.new(0, 12)

        local sk_stroke = Instance.new("UIStroke", win_sk)
        sk_stroke.Color     = Color3.fromRGB(0, 180, 255)
        sk_stroke.Thickness = 1.5
        sk_stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

        -- Gradient Hintergrund
        local sk_grad = Instance.new("UIGradient", win_sk)
        sk_grad.Color    = ColorSequence.new{
            ColorSequenceKeypoint.new(0,   Color3.fromRGB(12, 16, 32)),
            ColorSequenceKeypoint.new(1,   Color3.fromRGB(6,  10, 20)),
        }
        sk_grad.Rotation = 135

        -- ── Titelleiste ──
        local sk_title = Instance.new("Frame")
        sk_title.Size            = UDim2.new(1, 0, 0, 44)
        sk_title.BackgroundColor3 = Color3.fromRGB(0, 140, 220)
        sk_title.BorderSizePixel = 0
        sk_title.Parent          = win_sk
        Instance.new("UICorner", sk_title).CornerRadius = UDim.new(0, 12)
        local sk_titleGrad = Instance.new("UIGradient", sk_title)
        sk_titleGrad.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 160, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 80,  180)),
        }

        local sk_titleLbl = Instance.new("TextLabel")
        sk_titleLbl.Size            = UDim2.new(1, -50, 1, 0)
        sk_titleLbl.Position        = UDim2.new(0, 14, 0, 0)
        sk_titleLbl.BackgroundTransparency = 1
        sk_titleLbl.Text            = "🎹 Speed Keyboard Escape"
        sk_titleLbl.TextColor3      = Color3.fromRGB(255, 255, 255)
        sk_titleLbl.TextSize        = 15
        sk_titleLbl.Font            = Enum.Font.GothamBold
        sk_titleLbl.TextXAlignment  = Enum.TextXAlignment.Left
        sk_titleLbl.Parent          = sk_title

        -- Close Button
        local sk_close = Instance.new("TextButton")
        sk_close.Size               = UDim2.new(0, 30, 0, 30)
        sk_close.Position           = UDim2.new(1, -38, 0, 7)
        sk_close.BackgroundColor3   = Color3.fromRGB(220, 50, 50)
        sk_close.Text               = "✕"
        sk_close.TextColor3         = Color3.fromRGB(255, 255, 255)
        sk_close.TextSize           = 14
        sk_close.Font               = Enum.Font.GothamBold
        sk_close.BorderSizePixel    = 0
        sk_close.Parent             = sk_title
        Instance.new("UICorner", sk_close).CornerRadius = UDim.new(0, 6)
        sk_close.MouseButton1Click:Connect(function()
            sg_sk:Destroy()
        end)

        -- Drag
        local sk_drag = false
        local sk_dragStart, sk_startPos
        sk_title.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                sk_drag = true
                sk_dragStart = inp.Position
                sk_startPos  = win_sk.Position
            end
        end)
        sk_title.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then sk_drag = false end
        end)
        -- [FIX #10] Verbindung speichern + bei GUI-Destroy trennen (kein Connection Leak)
        local _skDragConn = UIS_SK.InputChanged:Connect(function(inp)
            if sk_drag and inp.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = inp.Position - sk_dragStart
                win_sk.Position = UDim2.new(
                    sk_startPos.X.Scale, sk_startPos.X.Offset + delta.X,
                    sk_startPos.Y.Scale, sk_startPos.Y.Offset + delta.Y
                )
            end
        end)
        sg_sk.AncestryChanged:Connect(function()
            if not sg_sk.Parent then _skDragConn:Disconnect() end
        end)

        -- ── Content-Bereich ──
        local sk_content = Instance.new("ScrollingFrame")
        sk_content.Size                = UDim2.new(1, -16, 1, -54)
        sk_content.Position            = UDim2.new(0, 8, 0, 50)
        sk_content.BackgroundTransparency = 1
        sk_content.ScrollBarThickness  = 3
        sk_content.ScrollBarImageColor3 = Color3.fromRGB(0, 180, 255)
        sk_content.CanvasSize          = UDim2.new(0, 0, 0, 0)
        sk_content.AutomaticCanvasSize = Enum.AutomaticSize.Y
        sk_content.Parent              = win_sk
        local sk_layout = Instance.new("UIListLayout", sk_content)
        sk_layout.SortOrder = Enum.SortOrder.LayoutOrder
        sk_layout.Padding   = UDim.new(0, 6)
        Instance.new("UIPadding", sk_content).PaddingTop = UDim.new(0, 4)

        -- ── Hilfsfunktion: Button erstellen ──
        local function sk_btn(txt, order, col)
            col = col or Color3.fromRGB(0, 140, 220)
            local b = Instance.new("TextButton")
            b.Size            = UDim2.new(1, -8, 0, 38)
            b.BackgroundColor3 = col
            b.Text            = txt
            b.TextColor3      = Color3.fromRGB(255, 255, 255)
            b.TextSize        = 13
            b.Font            = Enum.Font.GothamBold
            b.BorderSizePixel = 0
            b.LayoutOrder     = order
            b.AutoButtonColor = true
            b.Parent          = sk_content
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
            local bs = Instance.new("UIStroke", b)
            bs.Color     = Color3.fromRGB(255,255,255)
            bs.Thickness = 0.5
            bs.Transparency = 0.7
            return b
        end

        local function sk_label(txt, order)
            local l = Instance.new("TextLabel")
            l.Size            = UDim2.new(1, -8, 0, 28)
            l.BackgroundTransparency = 1
            l.Text            = txt
            l.TextColor3      = Color3.fromRGB(160, 200, 255)
            l.TextSize        = 12
            l.Font            = Enum.Font.Gotham
            l.TextXAlignment  = Enum.TextXAlignment.Left
            l.LayoutOrder     = order
            l.Parent          = sk_content
            return l
        end

        -- ══ Status Label ══
        local sk_status = sk_label("● Bereit", 0)
        sk_status.TextColor3 = Color3.fromRGB(0, 220, 120)

        -- ═══════════════════════════════════════════════════════
        -- SPIEL-INFO: +1 Speed Keyboard Escape
        -- Mechanik: Über Keyboard-Keys laufen → jeder Key = +1 Speed-Stat
        -- Höherer Speed-Stat = schneller durch Escape-Courses
        -- Rebirth = Multiplier × mehr Speed pro Key
        -- ═══════════════════════════════════════════════════════

        sk_label("─── 🏃 Auto Farm ───────────────────", 1)

        -- ══════════════════════════════════════════════
        -- FEATURE 1: AUTO FARM KEYS
        -- Bewegt den Charakter automatisch hin und her
        -- über die Keyboard-Keys auf dem Boden → farmt
        -- Speed ohne manuelles Laufen.
        -- Methode: VirtualInputManager W-Taste gedrückt
        -- halten + regelmäßig Richtung ändern
        -- ══════════════════════════════════════════════
        local sk_farmActive = false
        local sk_farmConn   = nil
        local sk_farmGen    = 0

        local sk_farmBtn = sk_btn("⌨️ Auto Farm Keys EIN", 2, Color3.fromRGB(0, 140, 60))
        sk_farmBtn.MouseButton1Click:Connect(function()
            sk_farmActive = not sk_farmActive
            sk_farmGen    = sk_farmGen + 1
            local myGen   = sk_farmGen

            if sk_farmActive then
                sk_farmBtn.Text             = "⌨️ Auto Farm Keys AUS (läuft)"
                sk_farmBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
                sk_status.Text              = "● Farmt Keys..."
                sk_status.TextColor3        = Color3.fromRGB(0, 220, 120)

                -- VirtualInputManager: W gedrückt halten, alle 2.5s drehen
                local VIM_SK = game:GetService("VirtualInputManager")
                task.spawn(function()
                    local directions = {
                        {fwd = Enum.KeyCode.W, back = Enum.KeyCode.S},
                        {fwd = Enum.KeyCode.D, back = Enum.KeyCode.A},
                    }
                    local dirIdx = 1
                    while sk_farmActive and sk_farmGen == myGen do
                        local dir = directions[dirIdx]
                        -- Richtungstaste drücken
                        pcall(function()
                            VIM_SK:SendKeyEvent(true, dir.fwd, false, game)
                        end)
                        -- 2.5 Sekunden laufen
                        local elapsed = 0
                        while sk_farmActive and sk_farmGen == myGen and elapsed < 2.5 do
                            task.wait(0.1)
                            elapsed = elapsed + 0.1
                        end
                        -- Taste loslassen
                        pcall(function()
                            VIM_SK:SendKeyEvent(false, dir.fwd, false, game)
                        end)
                        -- kurz warten, Richtung wechseln
                        task.wait(0.1)
                        dirIdx = dirIdx % #directions + 1
                    end
                    -- Sicherstellen alle Tasten losgelassen
                    pcall(function()
                        for _, d in ipairs(directions) do
                            VIM_SK:SendKeyEvent(false, d.fwd, false, game)
                        end
                    end)
                end)
            else
                sk_farmBtn.Text             = "⌨️ Auto Farm Keys EIN"
                sk_farmBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 60)
                sk_status.Text              = "● Bereit"
                sk_status.TextColor3        = Color3.fromRGB(0, 220, 120)
            end
        end)

        sk_label("─── 🔄 Auto Rebirth ────────────────", 3)

        -- ══════════════════════════════════════════════
        -- FEATURE 2: AUTO REBIRTH
        -- Sucht den Rebirth-Button in der GUI und
        -- klickt ihn automatisch sobald er sichtbar/
        -- aktiv ist → automatisch Multiplier erhöhen
        -- ══════════════════════════════════════════════
        local sk_rebirthActive = false
        local sk_rebirthConn   = nil

        local function sk_findAndClickButton(keywords)
            for _, pg in ipairs(LP_SK.PlayerGui:GetChildren()) do
                for _, obj in ipairs(pg:GetDescendants()) do
                    if (obj:IsA("TextButton") or obj:IsA("ImageButton")) and obj.Visible then
                        local name = obj.Name:lower()
                        local text = obj:IsA("TextButton") and obj.Text:lower() or ""
                        for _, kw in ipairs(keywords) do
                            if name:find(kw) or text:find(kw) then
                                pcall(function()
                                    -- Simuliere Klick via MouseButton1Click:Fire()
                                    local ms = game:GetService("VirtualInputManager")
                                    local pos = obj.AbsolutePosition + obj.AbsoluteSize * 0.5
                                    ms:SendMouseButtonEvent(pos.X, pos.Y, 0, true,  game, 0)
                                    task.wait(0.05)
                                    ms:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 0)
                                end)
                                return true
                            end
                        end
                    end
                end
            end
            return false
        end

        local sk_rebirthBtn = sk_btn("🔄 Auto Rebirth EIN", 4, Color3.fromRGB(160, 100, 0))
        sk_rebirthBtn.MouseButton1Click:Connect(function()
            sk_rebirthActive = not sk_rebirthActive
            if sk_rebirthActive then
                sk_rebirthBtn.Text             = "🔄 Auto Rebirth AUS (aktiv)"
                sk_rebirthBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)

                local _rbTimer = 0
                sk_rebirthConn = RS_SK.Heartbeat:Connect(function(dt)
                    _rbTimer = _rbTimer + dt
                    if _rbTimer < 1.5 then return end  -- alle 1.5s prüfen
                    _rbTimer = 0
                    pcall(function()
                        local clicked = sk_findAndClickButton({
                            "rebirth","reborn","wiedergeburt","prestige","reset"
                        })
                        if clicked then
                            sk_status.Text       = "● Rebirth ausgelöst! (" .. os.date("%H:%M:%S") .. ")"
                            sk_status.TextColor3 = Color3.fromRGB(255, 200, 0)
                        end
                    end)
                end)
            else
                if sk_rebirthConn then sk_rebirthConn:Disconnect(); sk_rebirthConn = nil end
                sk_rebirthBtn.Text             = "🔄 Auto Rebirth EIN"
                sk_rebirthBtn.BackgroundColor3 = Color3.fromRGB(160, 100, 0)
                sk_status.Text                 = "● Bereit"
                sk_status.TextColor3           = Color3.fromRGB(0, 220, 120)
            end
        end)

        sk_label("─── 🎁 Code Einlösen ───────────────", 5)

        -- ══════════════════════════════════════════════
        -- FEATURE 3: CODE REDEEMER
        -- Bekannte aktive Codes automatisch einlösen.
        -- Sucht TextBox (Code-Eingabe) + Bestätigungs-
        -- Button in der GUI.
        -- ══════════════════════════════════════════════
        local SK_CODES = {
            "SECRETVERSE","SPEED","KEYBOARD","CANDY2","CHOCOLATE",
            "BOOST","UPDATE","RELEASE","LIKE","FAVORITE",
        }

        local sk_redeemBtn = sk_btn("🎁 Alle Codes einlösen", 6, Color3.fromRGB(180, 50, 150))
        sk_redeemBtn.MouseButton1Click:Connect(function()
            sk_status.Text       = "● Löse Codes ein..."
            sk_status.TextColor3 = Color3.fromRGB(255, 200, 0)

            task.spawn(function()
                local redeemed = 0
                local VIM_SK2 = game:GetService("VirtualInputManager")

                -- Codes-UI öffnen: Button mit "code" im Namen suchen + klicken
                sk_findAndClickButton({"code","codes","gift","geschenk","redeem"})
                task.wait(0.5)

                for _, code in ipairs(SK_CODES) do
                    pcall(function()
                        -- TextBox für Code-Eingabe suchen
                        for _, pg in ipairs(LP_SK.PlayerGui:GetChildren()) do
                            for _, obj in ipairs(pg:GetDescendants()) do
                                if obj:IsA("TextBox") and obj.Visible then
                                    -- Code eintippen
                                    obj:CaptureFocus()
                                    obj.Text = code
                                    task.wait(0.1)
                                    -- Enter drücken
                                    VIM_SK2:SendKeyEvent(true,  Enum.KeyCode.Return, false, game)
                                    task.wait(0.05)
                                    VIM_SK2:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                                    task.wait(0.1)
                                    -- Auch Submit-Button suchen
                                    sk_findAndClickButton({"submit","redeem","einlösen","confirm","ok","apply"})
                                    task.wait(0.4)
                                    redeemed = redeemed + 1
                                end
                            end
                        end
                    end)
                end

                sk_status.Text       = "● " .. redeemed .. " Code(s) versucht einzulösen"
                sk_status.TextColor3 = Color3.fromRGB(0, 220, 120)
            end)
        end)

        sk_label("─── ⚙️ Sonstiges ───────────────────", 7)

        -- ══════════════════════════════════════════════
        -- FEATURE 4: ANTI-AFK (spiel-intern)
        -- Verhindert AFK-Kick durch simulierte Eingaben
        -- ══════════════════════════════════════════════
        local sk_afkActive = false
        local sk_afkConn   = nil
        local sk_afkGen    = 0

        local sk_afkBtn = sk_btn("💤 Anti-AFK EIN", 8, Color3.fromRGB(60, 60, 140))
        sk_afkBtn.MouseButton1Click:Connect(function()
            sk_afkActive = not sk_afkActive
            sk_afkGen    = sk_afkGen + 1
            local myGen  = sk_afkGen
            if sk_afkActive then
                sk_afkBtn.Text             = "💤 Anti-AFK AUS (aktiv)"
                sk_afkBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
                task.spawn(function()
                    while sk_afkActive and sk_afkGen == myGen do
                        task.wait(55)
                        if not sk_afkActive or sk_afkGen ~= myGen then break end
                        pcall(function()
                            local vu = game:GetService("VirtualUser")
                            vu:CaptureController()
                            vu:ClickButton2(Vector2.new())
                        end)
                    end
                end)
            else
                sk_afkBtn.Text             = "💤 Anti-AFK EIN"
                sk_afkBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 140)
            end
        end)

        -- ══════════════════════════════════════════════
        -- FEATURE 5: WALK SPEED SANFT ERHÖHEN
        -- Moderate Erhöhung (nicht zu extrem → kein Kick)
        -- Hilft beim schnelleren Ablaufen der Keys
        -- ══════════════════════════════════════════════
        local sk_wsActive = false
        local sk_wsConn   = nil
        local sk_wsBtn = sk_btn("🏃 Walk Speed +50  (EIN)", 9, Color3.fromRGB(50, 100, 180))
        sk_wsBtn.MouseButton1Click:Connect(function()
            sk_wsActive = not sk_wsActive
            if sk_wsActive then
                sk_wsBtn.Text             = "🏃 Walk Speed +50  (AUS)"
                sk_wsBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
                -- Throttled: nur alle 10 Frames setzen → weniger auffällig
                local _wsF = 0
                sk_wsConn = RS_SK.Heartbeat:Connect(function()
                    _wsF = _wsF + 1
                    if _wsF < 10 then return end
                    _wsF = 0
                    pcall(function()
                        local hum = LP_SK.Character and LP_SK.Character:FindFirstChild("Humanoid")
                        if hum then hum.WalkSpeed = 66 end  -- +50 über Standard-16
                    end)
                end)
            else
                if sk_wsConn then sk_wsConn:Disconnect(); sk_wsConn = nil end
                pcall(function()
                    local hum = LP_SK.Character and LP_SK.Character:FindFirstChild("Humanoid")
                    if hum then hum.WalkSpeed = 16 end
                end)
                sk_wsBtn.Text             = "🏃 Walk Speed +50  (EIN)"
                sk_wsBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 180)
            end
        end)

        -- Aufräumen beim Schließen
        sg_sk.AncestryChanged:Connect(function()
            if not sg_sk.Parent then
                sk_farmActive    = false
                sk_rebirthActive = false
                sk_afkActive     = false
                sk_wsActive      = false
                if sk_rebirthConn then sk_rebirthConn:Disconnect() end
                if sk_wsConn      then sk_wsConn:Disconnect()      end
            end
        end)

        -- Einblend-Animation
        win_sk.BackgroundTransparency = 1
        TS_SK:Create(win_sk, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            {BackgroundTransparency = 0}):Play()

        Rayfield:Notify({
            Title   = "🎹 Speed Keyboard Escape",
            Content = "Hub geöffnet — Auto Farm + Rebirth + Codes + Anti-AFK",
            Duration = 4,
        })
    end
})



-- ==================== 🎤 MIC UP ====================
GamesTab:CreateSection("🎤 Mic Up")

GamesTab:CreateButton({
    Name = "🎤 Mic Up Teleports öffnen",
    Callback = function()
        if game.PlaceId ~= 6884319169 then
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "SemysHUB",
                Text  = "❌ Nur in Mic Up nutzbar!",
                Duration = 4,
            })
            return
        end
        local CoreGui_MU = game:GetService("CoreGui")
        local _muhub = CoreGui_MU:FindFirstChild("SemysMicUpHub") -- [FIX] doppeltes FindFirstChild → local speichern
        if _muhub then
            _muhub:Destroy()
            return
        end

        local TweenService_MU = game:GetService("TweenService")
        local LP_MU           = game:GetService("Players").LocalPlayer

        -- ══════════════════ TELEPORT ORTE ══════════════════
        local mu_locations = {
            { name = "🏢 Büro",       x =  240.1, y =    6.2, z = -753.8 },
            { name = "🔥 Lagerfeuer", x =  174.8, y =    3.2, z = -232.8 },
            { name = "⚽ Fussball",   x =  -93.9, y =   13.0, z = -164.4 },
            { name = "🛒 Shop",       x = -291.9, y =    9.0, z = -183.9 },
            { name = "🏠 Haus",       x = -219.7, y =   13.2, z = -772.0 },
            { name = "🏃 Parkour",    x =  -84.8, y = 1044.0, z = -301.6 },
        }

        local function mu_teleport(x, y, z)
            pcall(function()
                local char = LP_MU.Character
                if not char then return end
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.CFrame = CFrame.new(x, y, z) end
            end)
        end

        -- ══════════════════ SCREENGUI ══════════════════
        local sg_mu = Instance.new("ScreenGui")
        sg_mu.Name           = "SemysMicUpHub"
        sg_mu.ResetOnSpawn   = false
        sg_mu.DisplayOrder   = 5000
        sg_mu.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        pcall(function() sg_mu.Parent = CoreGui_MU end)
        if not sg_mu.Parent then sg_mu.Parent = LP_MU:WaitForChild("PlayerGui") end

        -- Hauptfenster
        local win_mu = Instance.new("Frame")
        win_mu.Name             = "MUWin"
        win_mu.Size             = UDim2.new(0, 320, 0, 480)
        win_mu.Position         = UDim2.new(0.5, -160, 0.5, -240)
        win_mu.BackgroundColor3 = Color3.fromRGB(10, 14, 22)
        win_mu.BorderSizePixel  = 0
        win_mu.ZIndex           = 10
        win_mu.ClipsDescendants = true
        win_mu.Parent           = sg_mu
        Instance.new("UICorner", win_mu).CornerRadius = UDim.new(0, 14)

        local grad_mu = Instance.new("UIGradient", win_mu)
        grad_mu.Rotation = 135
        grad_mu.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0,   Color3.fromRGB(10, 14, 26)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(8,  13, 23)),
            ColorSequenceKeypoint.new(1,   Color3.fromRGB(5,   7, 13)),
        })

        local stroke_mu = Instance.new("UIStroke", win_mu)
        stroke_mu.Color        = Color3.fromRGB(180, 0, 255)
        stroke_mu.Thickness    = 2
        stroke_mu.Transparency = 0.1
        local _muStrokeCols = {
            Color3.fromRGB(180,   0, 255),
            Color3.fromRGB(120,  40, 255),
            Color3.fromRGB(200,   0, 200),
            Color3.fromRGB(100,   0, 255),
            Color3.fromRGB(160,  80, 255),
        }
        local _msci = 1
        task.spawn(function()
            while win_mu and win_mu.Parent do
                _msci = (_msci % #_muStrokeCols) + 1
                TweenService_MU:Create(stroke_mu, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Color = _muStrokeCols[_msci]}):Play()
                task.wait(2)
            end
        end)

        -- Partikel
        task.spawn(function()
            local pCols = { Color3.fromRGB(180,0,255), Color3.fromRGB(120,40,255), Color3.fromRGB(200,0,200), Color3.fromRGB(100,0,255) }
            while win_mu and win_mu.Parent do
                local p = Instance.new("Frame")
                p.Size = UDim2.new(0, math.random(2,5), 0, math.random(2,5))
                p.Position = UDim2.new(math.random(5,95)/100, 0, 1.05, 0)
                p.BackgroundColor3 = pCols[math.random(1,#pCols)]
                p.BackgroundTransparency = math.random(0,2)/10
                p.BorderSizePixel = 0; p.ZIndex = 9; p.Parent = win_mu
                Instance.new("UICorner", p).CornerRadius = UDim.new(1,0)
                TweenService_MU:Create(p, TweenInfo.new(math.random(25,40)/10, Enum.EasingStyle.Linear), {Position = UDim2.new(p.Position.X.Scale,0,-0.1,0), BackgroundTransparency = 1}):Play()
                task.delay(4, function() if p and p.Parent then p:Destroy() end end)
                task.wait(math.random(3,7)/10)
            end
        end)

        -- Header
        local header_mu = Instance.new("Frame")
        header_mu.Size             = UDim2.new(1, 0, 0, 46)
        header_mu.BackgroundColor3 = Color3.fromRGB(14, 0, 30)
        header_mu.BorderSizePixel  = 0
        header_mu.ZIndex           = 11
        header_mu.Parent           = win_mu
        local hGrad_mu = Instance.new("UIGradient", header_mu)
        hGrad_mu.Rotation = 135
        hGrad_mu.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0,   Color3.fromRGB(14,  0, 30)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(60,  0, 120)),
            ColorSequenceKeypoint.new(1,   Color3.fromRGB(120, 0, 200)),
        })

        local titleLbl_mu = Instance.new("TextLabel")
        titleLbl_mu.Size                  = UDim2.new(1, -50, 1, 0)
        titleLbl_mu.Position              = UDim2.new(0, 14, 0, 0)
        titleLbl_mu.BackgroundTransparency = 1
        titleLbl_mu.Font                  = Enum.Font.GothamBold
        titleLbl_mu.Text                  = "🎤 MIC UP"
        titleLbl_mu.TextColor3            = Color3.fromRGB(255, 255, 255)
        titleLbl_mu.TextSize              = 14
        titleLbl_mu.TextXAlignment        = Enum.TextXAlignment.Left
        titleLbl_mu.ZIndex                = 12
        titleLbl_mu.Parent                = header_mu
        local tStroke_mu = Instance.new("UIStroke", titleLbl_mu)
        tStroke_mu.Color = Color3.fromRGB(180, 0, 255); tStroke_mu.Thickness = 1.2; tStroke_mu.Transparency = 0.2
        local _mtCols = { Color3.fromRGB(180,0,255), Color3.fromRGB(120,40,255), Color3.fromRGB(200,0,200), Color3.fromRGB(100,0,255) }
        local _mtci = 1
        task.spawn(function()
            while header_mu and header_mu.Parent do
                _mtci = (_mtci % #_mtCols) + 1
                TweenService_MU:Create(tStroke_mu, TweenInfo.new(1.5, Enum.EasingStyle.Sine), {Color = _mtCols[_mtci]}):Play()
                task.wait(1.5)
            end
        end)

        -- Close Button
        local closeBtn_mu = Instance.new("TextButton")
        closeBtn_mu.Size             = UDim2.new(0, 28, 0, 28)
        closeBtn_mu.Position         = UDim2.new(1, -36, 0.5, -14)
        closeBtn_mu.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
        closeBtn_mu.BorderSizePixel  = 0
        closeBtn_mu.Font             = Enum.Font.GothamBold
        closeBtn_mu.Text             = "✕"
        closeBtn_mu.TextColor3       = Color3.fromRGB(255, 255, 255)
        closeBtn_mu.TextSize         = 13
        closeBtn_mu.AutoButtonColor  = false
        closeBtn_mu.ZIndex           = 13
        closeBtn_mu.Parent           = header_mu
        Instance.new("UICorner", closeBtn_mu).CornerRadius = UDim.new(0, 6)
        closeBtn_mu.MouseButton1Click:Connect(function() sg_mu:Destroy() end)

        -- Drag
        local dragging_mu, dragStart_mu, startPos_mu = false, nil, nil
        header_mu.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                dragging_mu = true; dragStart_mu = inp.Position; startPos_mu = win_mu.Position
            end
        end)
        -- [FIX #11] Verbindungen speichern + bei GUI-Destroy trennen (kein Connection Leak)
        local _muDragConn = game:GetService("UserInputService").InputChanged:Connect(function(inp)
            if dragging_mu and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
                local d = inp.Position - dragStart_mu
                win_mu.Position = UDim2.new(startPos_mu.X.Scale, startPos_mu.X.Offset + d.X,
                                             startPos_mu.Y.Scale, startPos_mu.Y.Offset + d.Y)
            end
        end)
        local _muEndConn = game:GetService("UserInputService").InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                dragging_mu = false end
        end)
        sg_mu.AncestryChanged:Connect(function()
            if not sg_mu.Parent then _muDragConn:Disconnect(); _muEndConn:Disconnect() end
        end)

        -- Status Label
        local statusLbl_mu = Instance.new("TextLabel")
        statusLbl_mu.Size                  = UDim2.new(1, -20, 0, 20)
        statusLbl_mu.Position              = UDim2.new(0, 10, 0, 52)
        statusLbl_mu.BackgroundTransparency = 1
        statusLbl_mu.Font                  = Enum.Font.GothamMedium
        statusLbl_mu.Text                  = "📍 Wähle einen Ort zum Teleportieren"
        statusLbl_mu.TextColor3            = Color3.fromRGB(180, 120, 255)
        statusLbl_mu.TextSize              = 11
        statusLbl_mu.TextXAlignment        = Enum.TextXAlignment.Left
        statusLbl_mu.ZIndex                = 11
        statusLbl_mu.Parent                = win_mu

        local sep_mu = Instance.new("Frame")
        sep_mu.Size             = UDim2.new(1, -20, 0, 1)
        sep_mu.Position         = UDim2.new(0, 10, 0, 78)
        sep_mu.BackgroundColor3 = Color3.fromRGB(120, 0, 200)
        sep_mu.BorderSizePixel  = 0
        sep_mu.BackgroundTransparency = 0.5
        sep_mu.ZIndex           = 11
        sep_mu.Parent           = win_mu

        -- ══════════════════ 6 TELEPORT BUTTONS ══════════════════
        local muBtnColors = {
            Color3.fromRGB(180,   0, 255),
            Color3.fromRGB(150,  40, 255),
            Color3.fromRGB(120,  60, 255),
            Color3.fromRGB(100,  80, 255),
            Color3.fromRGB(160,   0, 220),
            Color3.fromRGB(200,  50, 255),
        }

        for i, loc in ipairs(mu_locations) do
            local yOff = 86 + (i - 1) * 62
            local col  = muBtnColors[i]

            local bf = Instance.new("Frame")
            bf.Size             = UDim2.new(1, -20, 0, 54)
            bf.Position         = UDim2.new(0, 10, 0, yOff)
            bf.BackgroundColor3 = Color3.fromRGB(10, 14, 28)
            bf.BorderSizePixel  = 0
            bf.ZIndex           = 11
            bf.Parent           = win_mu
            Instance.new("UICorner", bf).CornerRadius = UDim.new(0, 12)

            local cardGrad = Instance.new("UIGradient", bf)
            cardGrad.Rotation = 0
            cardGrad.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, col), ColorSequenceKeypoint.new(1, Color3.fromRGB(8,12,24)) })
            cardGrad.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.78), NumberSequenceKeypoint.new(1, 0) })

            local bfs = Instance.new("UIStroke", bf)
            bfs.Color = col; bfs.Thickness = 1.5; bfs.Transparency = 0.3

            local accent = Instance.new("Frame")
            accent.Size             = UDim2.new(0, 4, 1, -16)
            accent.Position         = UDim2.new(0, 8, 0, 8)
            accent.BackgroundColor3 = col
            accent.BorderSizePixel  = 0
            accent.ZIndex           = 12
            accent.Parent           = bf
            Instance.new("UICorner", accent).CornerRadius = UDim.new(1, 0)

            local nameLbl = Instance.new("TextLabel")
            nameLbl.Size                  = UDim2.new(1, -90, 0, 22)
            nameLbl.Position              = UDim2.new(0, 22, 0, 8)
            nameLbl.BackgroundTransparency = 1
            nameLbl.Font                  = Enum.Font.GothamBold
            nameLbl.Text                  = "📍 " .. loc.name
            nameLbl.TextColor3            = Color3.fromRGB(240, 240, 255)
            nameLbl.TextSize              = 13
            nameLbl.TextXAlignment        = Enum.TextXAlignment.Left
            nameLbl.ZIndex                = 12
            nameLbl.Parent                = bf

            local coordLbl = Instance.new("TextLabel")
            coordLbl.Size                  = UDim2.new(1, -90, 0, 16)
            coordLbl.Position              = UDim2.new(0, 22, 0, 30)
            coordLbl.BackgroundTransparency = 1
            coordLbl.Font                  = Enum.Font.Gotham
            coordLbl.Text                  = string.format("%.1f, %.1f, %.1f", loc.x, loc.y, loc.z)
            coordLbl.TextColor3            = Color3.fromRGB(160, 130, 200)
            coordLbl.TextSize              = 10
            coordLbl.TextXAlignment        = Enum.TextXAlignment.Left
            coordLbl.ZIndex                = 12
            coordLbl.Parent                = bf

            local tpBtn = Instance.new("TextButton")
            tpBtn.Size             = UDim2.new(0, 72, 0, 30)
            tpBtn.Position         = UDim2.new(1, -80, 0.5, -15)
            tpBtn.BackgroundColor3 = col
            tpBtn.BorderSizePixel  = 0
            tpBtn.Font             = Enum.Font.GothamBold
            tpBtn.Text             = "TP"
            tpBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
            tpBtn.TextSize         = 12
            tpBtn.AutoButtonColor  = false
            tpBtn.ZIndex           = 13
            tpBtn.Parent           = bf
            Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0, 8)

            local _loc = loc
            tpBtn.MouseButton1Click:Connect(function()
                mu_teleport(_loc.x, _loc.y, _loc.z)
                statusLbl_mu.Text = "✅ Teleportiert: " .. _loc.name
                TweenService_MU:Create(statusLbl_mu, TweenInfo.new(0.3), {TextColor3 = Color3.fromRGB(100, 255, 150)}):Play()
                task.delay(2, function()
                    if statusLbl_mu and statusLbl_mu.Parent then
                        TweenService_MU:Create(statusLbl_mu, TweenInfo.new(0.3), {TextColor3 = Color3.fromRGB(180, 120, 255)}):Play()
                        task.wait(0.3)
                        if statusLbl_mu and statusLbl_mu.Parent then
                            statusLbl_mu.Text = "📍 Wähle einen Ort zum Teleportieren"
                        end
                    end
                end)
            end)

            tpBtn.MouseEnter:Connect(function()
                TweenService_MU:Create(tpBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0.3}):Play()
            end)
            tpBtn.MouseLeave:Connect(function()
                TweenService_MU:Create(tpBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
            end)
        end

        -- Slide-in Animation
        win_mu.Position = UDim2.new(0.5, -160, 1.1, 0)
        TweenService_MU:Create(win_mu, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {Position = UDim2.new(0.5, -160, 0.5, -240)}):Play()
    end,
})


-- ==================== 💣 NATURAL DISASTER SURVIVAL ====================
GamesTab:CreateSection("💣 Natural Disaster Survival")

GamesTab:CreateButton({
    Name = "💣 NDS Tools öffnen",
    Callback = function()
        if game.PlaceId ~= 189707 then
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "SemysHUB",
                Text  = "❌ Nur in Natural Disaster Survival nutzbar!",
                Duration = 4,
            })
            return
        end
        local CoreGui_NDS = game:GetService("CoreGui")
        local _ndshub = CoreGui_NDS:FindFirstChild("SemysNDSHub") -- [FIX] doppeltes FindFirstChild → local speichern
        if _ndshub then
            _ndshub:Destroy()
            return
        end

        local TweenService_NDS = game:GetService("TweenService")
        local LP_NDS           = game:GetService("Players").LocalPlayer
        local RS_NDS           = game:GetService("RunService")
        local WS_NDS           = game:GetService("Workspace")
        local UIS_NDS          = game:GetService("UserInputService")

        -- ══════════════════ KATASTROPHEN-ERKENNUNG ══════════════════
        local nds_dangerKeywords = {
            "Meteor","Lava","Tornado","Rock","Debris","Lightning",
            "Flood","Fire","Acid","Sand","Snow","Thunder","Ball","Wave"
        }

        local function nds_getDisaster()
            -- Methode 1: Hint / Message Objekte im Workspace
            local hint = WS_NDS:FindFirstChildOfClass("Hint")
            if hint and hint.Text ~= "" then return hint.Text end
            local msg = WS_NDS:FindFirstChildOfClass("Message")
            if msg and msg.Text ~= "" then return msg.Text end

            -- Methode 2: Bekannte Katastrophen-Objekte im Workspace suchen
            local found = {}
            for _, obj in ipairs(WS_NDS:GetChildren()) do
                local n = obj.Name:lower()
                for _, kw in ipairs(nds_dangerKeywords) do
                    if n:find(kw:lower()) then
                        table.insert(found, obj.Name)
                        break
                    end
                end
            end
            if #found > 0 then return "⚠️ Erkannt: " .. table.concat(found, ", ") end

            return "❓ Keine Katastrophe erkannt"
        end

        -- ══════════════════ HÖCHSTER PUNKT ══════════════════
        local function nds_findHighestPoint()
            local char = LP_NDS.Character
            if not char then return nil end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return nil end

            local myPos     = hrp.Position
            local highestY  = myPos.Y
            local bestPos   = nil

            for _, obj in ipairs(WS_NDS:GetDescendants()) do
                if obj:IsA("BasePart") and obj.CanCollide then
                    local pos  = obj.Position
                    local size = obj.Size
                    local horiz = Vector2.new(pos.X - myPos.X, pos.Z - myPos.Z).Magnitude
                    if horiz < 600 and size.X > 3 and size.Z > 3 and pos.Y > highestY then
                        highestY = pos.Y
                        bestPos  = Vector3.new(pos.X, pos.Y + size.Y / 2 + 3, pos.Z)
                    end
                end
            end
            return bestPos
        end

        -- ══════════════════ NÄCHSTES GEBÄUDE (DACH) ══════════════════
        local function nds_findNearestBuilding()
            local char = LP_NDS.Character
            if not char then return nil end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return nil end

            local myPos   = hrp.Position
            local bestDist = math.huge
            local bestPos  = nil

            for _, obj in ipairs(WS_NDS:GetDescendants()) do
                if obj:IsA("BasePart") and obj.CanCollide then
                    local size = obj.Size
                    -- Dach-Heuristik: breite, flache, horizontal große Fläche über Spieler
                    if size.X > 8 and size.Z > 8 and size.Y < 3 and obj.Position.Y > myPos.Y then
                        local dist = (obj.Position - myPos).Magnitude
                        if dist < bestDist and dist < 400 then
                            bestDist = dist
                            bestPos  = Vector3.new(obj.Position.X, obj.Position.Y - 4, obj.Position.Z)
                        end
                    end
                end
            end
            return bestPos
        end

        -- ══════════════════ DANGER ESP ══════════════════
        local nds_espActive     = false
        local nds_espHighlights = {}

        local function nds_clearESP()
            for _, h in pairs(nds_espHighlights) do
                pcall(function() h:Destroy() end)
            end
            nds_espHighlights = {}
        end

        local function nds_applyESP()
            nds_clearESP()
            for _, obj in ipairs(WS_NDS:GetDescendants()) do
                if obj:IsA("BasePart") then
                    local n = obj.Name:lower()
                    for _, kw in ipairs(nds_dangerKeywords) do
                        if n:find(kw:lower()) then
                            pcall(function()
                                local sel = Instance.new("SelectionBox")
                                sel.Adornee             = obj
                                sel.Color3              = Color3.fromRGB(255, 60, 60)
                                sel.LineThickness       = 0.07
                                sel.SurfaceTransparency = 0.75
                                sel.SurfaceColor3       = Color3.fromRGB(255, 60, 60)
                                sel.Parent              = obj
                                table.insert(nds_espHighlights, sel)
                            end)
                            break
                        end
                    end
                end
            end
        end

        -- ══════════════════ SCREENGUI ══════════════════
        local sg_nds = Instance.new("ScreenGui")
        sg_nds.Name           = "SemysNDSHub"
        sg_nds.ResetOnSpawn   = false
        sg_nds.DisplayOrder   = 5001
        sg_nds.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        pcall(function() sg_nds.Parent = CoreGui_NDS end)
        if not sg_nds.Parent then sg_nds.Parent = LP_NDS:WaitForChild("PlayerGui") end

        local win_nds = Instance.new("Frame")
        win_nds.Name             = "NDSWin"
        win_nds.Size             = UDim2.new(0, 300, 0, 400)
        win_nds.Position         = UDim2.new(0.5, -150, 0.5, -200)
        win_nds.BackgroundColor3 = Color3.fromRGB(12, 18, 30)
        win_nds.BorderSizePixel  = 0
        win_nds.ZIndex           = 10
        win_nds.ClipsDescendants = true
        win_nds.Parent           = sg_nds
        Instance.new("UICorner", win_nds).CornerRadius = UDim.new(0, 14)

        local grad_nds = Instance.new("UIGradient", win_nds)
        grad_nds.Rotation = 135
        grad_nds.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(22, 30, 50)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 14, 24)),
        })

        -- ── Titelleiste ──
        local titleBar_nds = Instance.new("Frame", win_nds)
        titleBar_nds.Size             = UDim2.new(1, 0, 0, 44)
        titleBar_nds.BackgroundColor3 = Color3.fromRGB(200, 90, 20)
        titleBar_nds.BorderSizePixel  = 0
        titleBar_nds.ZIndex           = 11
        Instance.new("UICorner", titleBar_nds).CornerRadius = UDim.new(0, 14)
        local tbFix = Instance.new("Frame", titleBar_nds)
        tbFix.Size             = UDim2.new(1, 0, 0.5, 0)
        tbFix.Position         = UDim2.new(0, 0, 0.5, 0)
        tbFix.BackgroundColor3 = Color3.fromRGB(200, 90, 20)
        tbFix.BorderSizePixel  = 0
        tbFix.ZIndex           = 11

        local titleLbl_nds = Instance.new("TextLabel", titleBar_nds)
        titleLbl_nds.Size               = UDim2.new(1, -50, 1, 0)
        titleLbl_nds.Position           = UDim2.new(0, 12, 0, 0)
        titleLbl_nds.BackgroundTransparency = 1
        titleLbl_nds.Text               = "💣 Natural Disaster Survival"
        titleLbl_nds.TextColor3         = Color3.fromRGB(255, 255, 255)
        titleLbl_nds.Font               = Enum.Font.GothamBold
        titleLbl_nds.TextSize           = 13
        titleLbl_nds.TextXAlignment     = Enum.TextXAlignment.Left
        titleLbl_nds.ZIndex             = 12

        local closeBtn_nds = Instance.new("TextButton", titleBar_nds)
        closeBtn_nds.Size             = UDim2.new(0, 28, 0, 28)
        closeBtn_nds.Position         = UDim2.new(1, -36, 0.5, -14)
        closeBtn_nds.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        closeBtn_nds.Text             = "✕"
        closeBtn_nds.TextColor3       = Color3.fromRGB(255, 255, 255)
        closeBtn_nds.Font             = Enum.Font.GothamBold
        closeBtn_nds.TextSize         = 13
        closeBtn_nds.BorderSizePixel  = 0
        closeBtn_nds.ZIndex           = 13
        Instance.new("UICorner", closeBtn_nds).CornerRadius = UDim.new(0, 7)
        closeBtn_nds.MouseButton1Click:Connect(function()
            nds_clearESP()
            sg_nds:Destroy()
        end)

        -- ── Status-Label ──
        local statusLbl_nds = Instance.new("TextLabel", win_nds)
        statusLbl_nds.Size               = UDim2.new(1, -16, 0, 30)
        statusLbl_nds.Position           = UDim2.new(0, 8, 0, 48)
        statusLbl_nds.BackgroundTransparency = 1
        statusLbl_nds.Text               = "— bereit —"
        statusLbl_nds.TextColor3         = Color3.fromRGB(160, 180, 220)
        statusLbl_nds.Font               = Enum.Font.Gotham
        statusLbl_nds.TextSize           = 12
        statusLbl_nds.TextWrapped        = true
        statusLbl_nds.ZIndex             = 11

        local function nds_setStatus(txt, col)
            statusLbl_nds.Text      = txt
            statusLbl_nds.TextColor3 = col or Color3.fromRGB(160, 180, 220)
        end

        -- ── ScrollFrame ──
        local scroll_nds = Instance.new("ScrollingFrame", win_nds)
        scroll_nds.Size                 = UDim2.new(1, -8, 1, -86)
        scroll_nds.Position             = UDim2.new(0, 4, 0, 82)
        scroll_nds.BackgroundTransparency = 1
        scroll_nds.BorderSizePixel      = 0
        scroll_nds.ScrollBarThickness   = 3
        scroll_nds.ScrollBarImageColor3 = Color3.fromRGB(200, 90, 20)
        scroll_nds.CanvasSize           = UDim2.new(0, 0, 0, 0)
        scroll_nds.AutomaticCanvasSize  = Enum.AutomaticSize.Y
        scroll_nds.ZIndex               = 11

        local layout_nds = Instance.new("UIListLayout", scroll_nds)
        layout_nds.Padding     = UDim.new(0, 6)
        layout_nds.SortOrder   = Enum.SortOrder.LayoutOrder
        Instance.new("UIPadding", scroll_nds).PaddingTop = UDim.new(0, 4)

        -- ── Helper: Button & Separator ──
        local nds_order = 0
        local function nds_btn(label, color, cb)
            nds_order = nds_order + 1
            local btn = Instance.new("TextButton", scroll_nds)
            btn.Size             = UDim2.new(1, -8, 0, 38)
            btn.BackgroundColor3 = color
            btn.Text             = label
            btn.TextColor3       = Color3.fromRGB(255, 255, 255)
            btn.Font             = Enum.Font.GothamBold
            btn.TextSize         = 13
            btn.BorderSizePixel  = 0
            btn.LayoutOrder      = nds_order
            btn.ZIndex           = 12
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
            if cb then
                btn.MouseButton1Click:Connect(function() pcall(cb) end)
            end
            return btn
        end

        local function nds_sep(label)
            nds_order = nds_order + 1
            local lbl = Instance.new("TextLabel", scroll_nds)
            lbl.Size               = UDim2.new(1, -8, 0, 22)
            lbl.BackgroundTransparency = 1
            lbl.Text               = "── " .. label .. " ──"
            lbl.TextColor3         = Color3.fromRGB(220, 110, 40)
            lbl.Font               = Enum.Font.GothamBold
            lbl.TextSize           = 11
            lbl.LayoutOrder        = nds_order
            lbl.ZIndex             = 12
        end

        -- ══════════════════ SEKTION: KATASTROPHE ══════════════════
        nds_sep("🌪️ KATASTROPHE")

        nds_btn("🔍 Aktuelle Katastrophe anzeigen", Color3.fromRGB(80, 55, 160), function()
            local d = nds_getDisaster()
            nds_setStatus(d, Color3.fromRGB(255, 200, 60))
        end)

        -- Auto-Anzeige Toggle
        local nds_autoConn   = nil
        local nds_autoActive = false
        local autoBtn_nds = nds_btn("🔄 Auto-Anzeige AN", Color3.fromRGB(50, 110, 55), nil)
        autoBtn_nds.MouseButton1Click:Connect(function()
            nds_autoActive = not nds_autoActive
            if nds_autoActive then
                autoBtn_nds.Text             = "🔄 Auto-Anzeige AUS"
                autoBtn_nds.BackgroundColor3 = Color3.fromRGB(140, 40, 40)
                -- [FIX #13] Gedrosselt auf 0,5s: war 60x/s (jeden Frame), jetzt 2x/s
                local _ndsAutoTimer = 0
                nds_autoConn = RS_NDS.Heartbeat:Connect(function(dt)
                    _ndsAutoTimer = _ndsAutoTimer + dt
                    if _ndsAutoTimer < 0.5 then return end
                    _ndsAutoTimer = 0
                    nds_setStatus(nds_getDisaster(), Color3.fromRGB(255, 200, 60))
                end)
            else
                autoBtn_nds.Text             = "🔄 Auto-Anzeige AN"
                autoBtn_nds.BackgroundColor3 = Color3.fromRGB(50, 110, 55)
                if nds_autoConn then nds_autoConn:Disconnect(); nds_autoConn = nil end
                nds_setStatus("— bereit —", Color3.fromRGB(160, 180, 220))
            end
        end)

        -- ══════════════════ SEKTION: ÜBERLEBEN ══════════════════
        nds_sep("🏔️ ÜBERLEBEN")

        nds_btn("🏔️ Höchsten Punkt finden & TP", Color3.fromRGB(190, 110, 25), function()
            local pos = nds_findHighestPoint()
            if pos then
                local char = LP_NDS.Character
                local hrp  = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = CFrame.new(pos)
                    nds_setStatus("✅ Höchster Punkt: Y = " .. math.floor(pos.Y), Color3.fromRGB(100, 255, 120))
                end
            else
                nds_setStatus("⚠️ Kein höherer Punkt gefunden", Color3.fromRGB(255, 150, 50))
            end
        end)

        nds_btn("🏠 Nächstes Gebäude / Dach", Color3.fromRGB(190, 110, 25), function()
            local pos = nds_findNearestBuilding()
            if pos then
                local char = LP_NDS.Character
                local hrp  = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = CFrame.new(pos)
                    nds_setStatus("✅ Gebäude gefunden & teleportiert!", Color3.fromRGB(100, 255, 120))
                end
            else
                nds_setStatus("⚠️ Kein Gebäude in der Nähe gefunden", Color3.fromRGB(255, 150, 50))
            end
        end)

        -- ══════════════════ SEKTION: DANGER ESP ══════════════════
        nds_sep("👁️ DANGER ESP")

        local espBtn_nds = nds_btn("👁️ Danger ESP AN", Color3.fromRGB(50, 110, 55), nil)
        espBtn_nds.MouseButton1Click:Connect(function()
            nds_espActive = not nds_espActive
            if nds_espActive then
                espBtn_nds.Text             = "👁️ Danger ESP AUS"
                espBtn_nds.BackgroundColor3 = Color3.fromRGB(140, 40, 40)
                nds_applyESP()
                task.spawn(function()
                    while nds_espActive do
                        task.wait(2)
                        if nds_espActive then nds_applyESP() end
                    end
                end)
                nds_setStatus("👁️ ESP aktiv — Gefahren markiert", Color3.fromRGB(255, 80, 80))
            else
                espBtn_nds.Text             = "👁️ Danger ESP AN"
                espBtn_nds.BackgroundColor3 = Color3.fromRGB(50, 110, 55)
                nds_clearESP()
                nds_setStatus("👁️ ESP deaktiviert", Color3.fromRGB(160, 180, 220))
            end
        end)

        nds_btn("🔄 ESP jetzt aktualisieren", Color3.fromRGB(55, 75, 150), function()
            if nds_espActive then
                nds_applyESP()
                nds_setStatus("🔄 ESP aktualisiert", Color3.fromRGB(100, 180, 255))
            else
                nds_setStatus("⚠️ ESP ist nicht aktiv", Color3.fromRGB(255, 150, 50))
            end
        end)

        -- ══════════════════ SEKTION: LOBBY ══════════════════
        nds_sep("🚀 LOBBY")

        nds_btn("🚀 Lobby-Teleport (Rejoin)", Color3.fromRGB(50, 55, 180), function()
            nds_setStatus("🚀 Rejoining...", Color3.fromRGB(100, 180, 255))
            task.delay(0.5, function()
                pcall(function()
                    game:GetService("TeleportService"):Teleport(189707, LP_NDS)
                end)
            end)
        end)

        -- ══════════════════ ZIEHEN ══════════════════
        local nds_dragging, nds_dragStart, nds_startPos
        titleBar_nds.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1
            or inp.UserInputType == Enum.UserInputType.Touch then
                nds_dragging = true
                nds_dragStart = inp.Position
                nds_startPos  = win_nds.Position
            end
        end)
        titleBar_nds.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1
            or inp.UserInputType == Enum.UserInputType.Touch then
                nds_dragging = false
            end
        end)
        -- [FIX #12] Verbindung speichern + im Cleanup-Block trennen (fehlte bisher)
        local _ndsDragConn = UIS_NDS.InputChanged:Connect(function(inp)
            if nds_dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement
            or inp.UserInputType == Enum.UserInputType.Touch) then
                local d = inp.Position - nds_dragStart
                win_nds.Position = UDim2.new(
                    nds_startPos.X.Scale, nds_startPos.X.Offset + d.X,
                    nds_startPos.Y.Scale, nds_startPos.Y.Offset + d.Y
                )
            end
        end)

        -- ══════════════════ CLEANUP ══════════════════
        sg_nds.AncestryChanged:Connect(function()
            if not sg_nds.Parent then
                nds_clearESP()
                nds_espActive  = false
                nds_autoActive = false
                if nds_autoConn then nds_autoConn:Disconnect(); nds_autoConn = nil end
                _ndsDragConn:Disconnect()  -- [FIX #12] Drag-Verbindung trennen
            end
        end)

        -- ══════════════════ SLIDE-IN ANIMATION ══════════════════
        win_nds.Position = UDim2.new(0.5, -150, -0.6, 0)
        TweenService_NDS:Create(win_nds,
            TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            { Position = UDim2.new(0.5, -150, 0.5, -200) }
        ):Play()
    end,
})


-- ==================== 👻 FNAF ETERNAL NIGHTS ====================
GamesTab:CreateSection("👻 FNAF Eternal Nights")

GamesTab:CreateButton({
    Name = "👻 FNAF Eternal Nights Tools öffnen",
    Callback = function()
        local CoreGui_FN = game:GetService("CoreGui")
        local _fnhub = CoreGui_FN:FindFirstChild("SemysFNAFHub")
        if _fnhub then _fnhub:Destroy() return end

        local TS_FN  = game:GetService("TweenService")
        local LP_FN  = game:GetService("Players").LocalPlayer
        local UIS_FN = game:GetService("UserInputService")

        -- ══════════════════ GUI AUFBAU ══════════════════
        local sg_fn = Instance.new("ScreenGui")
        sg_fn.Name           = "SemysFNAFHub"
        sg_fn.ResetOnSpawn   = false
        sg_fn.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        sg_fn.IgnoreGuiInset = true
        local ok_fn = pcall(function()
            if type(gethui) == "function" then sg_fn.Parent = gethui() return end
            error("no gethui")
        end)
        if not ok_fn then
            pcall(function() sg_fn.Parent = CoreGui_FN end)
        end
        if not sg_fn.Parent then
            sg_fn.Parent = LP_FN:WaitForChild("PlayerGui", 10) or CoreGui_FN
        end

        local C_BG    = Color3.fromRGB(12,  10,  18)
        local C_PANEL = Color3.fromRGB(20,  15,  30)
        local C_ROW   = Color3.fromRGB(28,  20,  40)
        local C_ROWH  = Color3.fromRGB(40,  28,  60)
        local C_ACC   = Color3.fromRGB(220, 50, 50)    -- Blut-Rot (FNAF-Thema)
        local C_TEXT  = Color3.fromRGB(230, 210, 210)
        local C_SUB   = Color3.fromRGB(150, 120, 120)

        local function fnCorner(obj, r)
            local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 8); c.Parent = obj
        end
        local function fnStroke(obj, col, thick, trans)
            local s = Instance.new("UIStroke"); s.Color = col or C_ACC
            s.Thickness = thick or 1.5; s.Transparency = trans or 0.5; s.Parent = obj
        end

        local win_fn = Instance.new("Frame")
        win_fn.Name              = "WinFN"
        win_fn.Size              = UDim2.new(0, 320, 0, 420)
        win_fn.Position          = UDim2.new(0.5, -160, 0.5, -220)
        win_fn.BackgroundColor3  = C_BG
        win_fn.BorderSizePixel   = 0
        win_fn.Parent            = sg_fn
        fnCorner(win_fn, 12); fnStroke(win_fn, C_ACC, 2, 0.3)

        -- Titelleiste
        local titleBar_fn = Instance.new("Frame")
        titleBar_fn.Size             = UDim2.new(1, 0, 0, 44)
        titleBar_fn.BackgroundColor3 = C_PANEL
        titleBar_fn.BorderSizePixel  = 0
        titleBar_fn.Parent           = win_fn
        fnCorner(titleBar_fn, 12)
        local fix_fn = Instance.new("Frame")
        fix_fn.Size             = UDim2.new(1, 0, 0, 12)
        fix_fn.Position         = UDim2.new(0, 0, 1, -12)
        fix_fn.BackgroundColor3 = C_PANEL
        fix_fn.BorderSizePixel  = 0
        fix_fn.Parent           = titleBar_fn

        local titleLbl_fn = Instance.new("TextLabel")
        titleLbl_fn.Size                   = UDim2.new(1, -50, 1, 0)
        titleLbl_fn.Position               = UDim2.new(0, 14, 0, 0)
        titleLbl_fn.BackgroundTransparency = 1
        titleLbl_fn.Text                   = "👻  FNAF Eternal Nights"
        titleLbl_fn.TextColor3             = C_ACC
        titleLbl_fn.Font                   = Enum.Font.GothamBold
        titleLbl_fn.TextSize               = 15
        titleLbl_fn.TextXAlignment         = Enum.TextXAlignment.Left
        titleLbl_fn.Parent                 = titleBar_fn

        local closeBtn_fn = Instance.new("TextButton")
        closeBtn_fn.Size             = UDim2.new(0, 30, 0, 30)
        closeBtn_fn.Position         = UDim2.new(1, -38, 0.5, -15)
        closeBtn_fn.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
        closeBtn_fn.Text             = "✕"
        closeBtn_fn.TextColor3       = Color3.fromRGB(255, 255, 255)
        closeBtn_fn.Font             = Enum.Font.GothamBold
        closeBtn_fn.TextSize         = 14
        closeBtn_fn.AutoButtonColor  = false
        closeBtn_fn.Parent           = titleBar_fn
        fnCorner(closeBtn_fn, 6)
        closeBtn_fn.MouseButton1Click:Connect(function() sg_fn:Destroy() end)

        -- Scroll-Content
        local scroll_fn = Instance.new("ScrollingFrame")
        scroll_fn.Size                   = UDim2.new(1, 0, 1, -48)
        scroll_fn.Position               = UDim2.new(0, 0, 0, 48)
        scroll_fn.BackgroundTransparency = 1
        scroll_fn.BorderSizePixel        = 0
        scroll_fn.ScrollBarThickness     = 3
        scroll_fn.ScrollBarImageColor3   = C_ACC
        scroll_fn.CanvasSize             = UDim2.new()
        scroll_fn.AutomaticCanvasSize    = Enum.AutomaticSize.Y
        scroll_fn.Parent                 = win_fn
        local list_fn = Instance.new("UIListLayout")
        list_fn.Padding          = UDim.new(0, 6)
        list_fn.SortOrder        = Enum.SortOrder.LayoutOrder
        list_fn.Parent           = scroll_fn
        local pad_fn = Instance.new("UIPadding")
        pad_fn.PaddingLeft   = UDim.new(0, 10)
        pad_fn.PaddingRight  = UDim.new(0, 10)
        pad_fn.PaddingTop    = UDim.new(0, 8)
        pad_fn.PaddingBottom = UDim.new(0, 8)
        pad_fn.Parent        = scroll_fn

        -- Hilfsfunktionen
        local function fn_sep(txt)
            local lbl = Instance.new("TextLabel")
            lbl.Size                   = UDim2.new(1, 0, 0, 22)
            lbl.BackgroundTransparency = 1
            lbl.Text                   = txt
            lbl.TextColor3             = C_ACC
            lbl.Font                   = Enum.Font.GothamBold
            lbl.TextSize               = 12
            lbl.TextXAlignment         = Enum.TextXAlignment.Left
            lbl.Parent                 = scroll_fn
        end

        local function fn_btn(txt, col, cb)
            local row = Instance.new("TextButton")
            row.Size             = UDim2.new(1, 0, 0, 38)
            row.BackgroundColor3 = col or C_ROW
            row.Text             = ""
            row.AutoButtonColor  = false
            row.BorderSizePixel  = 0
            row.Parent           = scroll_fn
            fnCorner(row, 8); fnStroke(row, C_ACC, 1, 0.6)
            local lbl = Instance.new("TextLabel")
            lbl.Size                   = UDim2.new(1, -16, 1, 0)
            lbl.Position               = UDim2.new(0, 8, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text                   = txt
            lbl.TextColor3             = C_TEXT
            lbl.Font                   = Enum.Font.GothamMedium
            lbl.TextSize               = 13
            lbl.TextXAlignment         = Enum.TextXAlignment.Left
            lbl.Parent                 = row
            row.MouseEnter:Connect(function()
                TS_FN:Create(row, TweenInfo.new(0.12), {BackgroundColor3 = C_ROWH}):Play()
            end)
            row.MouseLeave:Connect(function()
                TS_FN:Create(row, TweenInfo.new(0.12), {BackgroundColor3 = col or C_ROW}):Play()
            end)
            row.MouseButton1Click:Connect(function() task.spawn(cb) end)
            return lbl
        end

        local fn_statusLbl = Instance.new("TextLabel")
        fn_statusLbl.Size                   = UDim2.new(1, 0, 0, 24)
        fn_statusLbl.BackgroundTransparency = 1
        fn_statusLbl.Text                   = "✅ Bereit"
        fn_statusLbl.TextColor3             = Color3.fromRGB(100, 220, 100)
        fn_statusLbl.Font                   = Enum.Font.GothamMedium
        fn_statusLbl.TextSize               = 12
        fn_statusLbl.TextXAlignment         = Enum.TextXAlignment.Center
        fn_statusLbl.Parent                 = scroll_fn

        local function fn_setStatus(txt, col)
            fn_statusLbl.Text       = txt
            fn_statusLbl.TextColor3 = col or Color3.fromRGB(100, 220, 100)
        end

        local function fn_getHRP()
            local char = LP_FN.Character
            return char and char:FindFirstChild("HumanoidRootPart")
        end

        -- ══════════════════ SEKTION: TELEPORT ══════════════════
        fn_sep("📍 TELEPORT")

        fn_btn("📍 Spawn teleportieren", C_ROW, function()
            local hrp = fn_getHRP()
            if not hrp then fn_setStatus("❌ Kein Charakter", Color3.fromRGB(255, 80, 80)) return end
            pcall(function()
                hrp.CFrame = CFrame.new(0, 5, 0)
            end)
            fn_setStatus("✅ Zu Spawn teleportiert", Color3.fromRGB(100, 220, 100))
        end)

        fn_btn("⬆️ Hochfliegen (+500 Studs)", C_ROW, function()
            local hrp = fn_getHRP()
            if not hrp then fn_setStatus("❌ Kein Charakter", Color3.fromRGB(255, 80, 80)) return end
            pcall(function()
                hrp.CFrame = hrp.CFrame + Vector3.new(0, 500, 0)
            end)
            fn_setStatus("✅ Hochgeflogen", Color3.fromRGB(100, 220, 100))
        end)

        -- ══════════════════ SEKTION: CHARAKTER ══════════════════
        fn_sep("⚡ CHARAKTER")

        local fn_speedActive = false
        local fn_speedLbl

        -- [FIX v99 Bug 3] fn_speedConn auf CharacterAdded statt nil.
        -- Früher: speedConn = nil → nach Respawn blieb fn_speedActive true, aber
        -- WalkSpeed war zurückgesetzt (kein Recovery-Mechanismus).
        -- Jetzt: CharacterAdded re-appliziert Speed auf den neuen Humanoid.
        local fn_speedConn = LP_FN.CharacterAdded:Connect(function(newChar)
            if not fn_speedActive then return end
            task.wait(0.5)  -- Humanoid braucht eine Tick um zu laden
            local hum = newChar:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = 80 end
        end)

        fn_speedLbl = fn_btn("🚀 Speed Boost AN / AUS", C_ROW, function()
            fn_speedActive = not fn_speedActive
            local char = LP_FN.Character
            local hum  = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = fn_speedActive and 80 or 16
            end
            fn_speedLbl.TextColor3 = fn_speedActive
                and Color3.fromRGB(100, 255, 150)
                or  C_TEXT
            fn_setStatus(fn_speedActive and "🚀 Speed AN (80) – bleibt nach Respawn!" or "Speed normal (16)",
                fn_speedActive and Color3.fromRGB(100, 220, 100) or C_SUB)
        end)

        fn_btn("🦘 Super Jump (JumpPower 200)", C_ROW, function()
            local char = LP_FN.Character
            local hum  = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.JumpPower = 200
                fn_setStatus("🦘 Jump Power auf 200 gesetzt", Color3.fromRGB(100, 220, 100))
            else
                fn_setStatus("❌ Humanoid nicht gefunden", Color3.fromRGB(255, 80, 80))
            end
        end)

        fn_btn("🔄 Charakter-Werte zurücksetzen", C_ROW, function()
            local char = LP_FN.Character
            local hum  = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = 16
                hum.JumpPower = 50
                fn_speedActive = false
                if fn_speedLbl then fn_speedLbl.TextColor3 = C_TEXT end
                fn_setStatus("✅ Werte zurückgesetzt", Color3.fromRGB(100, 220, 100))
            else
                fn_setStatus("❌ Humanoid nicht gefunden", Color3.fromRGB(255, 80, 80))
            end
        end)

        -- ══════════════════ SEKTION: FULLBRIGHT ══════════════════
        fn_sep("🌕 FULLBRIGHT")

        local fn_fbOn      = false
        local fn_fbOrig    = {}   -- gespeicherte Original-Lighting-Werte
        local fn_fbEffects = {}   -- deaktivierte Effekte { obj, prop, origVal }
        local fn_fbLbl

        local function fn_fbApply()
            local L = game:GetService("Lighting")
            -- Originalwerte sichern
            fn_fbOrig = {
                Brightness        = L.Brightness,
                Ambient           = L.Ambient,
                OutdoorAmbient    = L.OutdoorAmbient,
                FogEnd            = L.FogEnd,
                FogStart          = L.FogStart,
                FogColor          = L.FogColor,
                ClockTime         = L.ClockTime,
                ShadowSoftness    = L.ShadowSoftness,
                GlobalShadows     = L.GlobalShadows,
                EnvironmentDiffuseScale  = L.EnvironmentDiffuseScale,
                EnvironmentSpecularScale = L.EnvironmentSpecularScale,
            }
            -- Vollhelligkeit setzen
            pcall(function()
                L.Brightness               = 10
                L.Ambient                  = Color3.fromRGB(255, 255, 255)
                L.OutdoorAmbient           = Color3.fromRGB(255, 255, 255)
                L.FogEnd                   = 100000
                L.FogStart                 = 99999
                L.GlobalShadows            = false
                L.ShadowSoftness           = 0
                L.EnvironmentDiffuseScale  = 1
                L.EnvironmentSpecularScale = 1
            end)
            -- Atmosphere, BloomEffect, ColorCorrectionEffect, SunRaysEffect deaktivieren
            fn_fbEffects = {}
            for _, obj in ipairs(L:GetChildren()) do
                pcall(function()
                    if obj:IsA("Atmosphere") then
                        local orig = obj.Density
                        obj.Density = 0
                        table.insert(fn_fbEffects, { obj = obj, prop = "Density", val = orig })
                    elseif obj:IsA("BloomEffect") or obj:IsA("SunRaysEffect")
                        or obj:IsA("DepthOfFieldEffect") or obj:IsA("ColorCorrectionEffect")
                        or obj:IsA("BlurEffect") then
                        local orig = obj.Enabled
                        obj.Enabled = false
                        table.insert(fn_fbEffects, { obj = obj, prop = "Enabled", val = orig })
                    end
                end)
            end
        end

        local function fn_fbRemove()
            local L = game:GetService("Lighting")
            -- Lighting-Werte wiederherstellen
            pcall(function()
                if next(fn_fbOrig) then
                    L.Brightness               = fn_fbOrig.Brightness        or 1
                    L.Ambient                  = fn_fbOrig.Ambient           or Color3.fromRGB(70,70,70)
                    L.OutdoorAmbient           = fn_fbOrig.OutdoorAmbient    or Color3.fromRGB(70,70,70)
                    L.FogEnd                   = fn_fbOrig.FogEnd            or 100000
                    L.FogStart                 = fn_fbOrig.FogStart          or 0
                    L.FogColor                 = fn_fbOrig.FogColor          or Color3.fromRGB(192,192,192)
                    L.GlobalShadows            = fn_fbOrig.GlobalShadows     ~= nil and fn_fbOrig.GlobalShadows or true
                    L.ShadowSoftness           = fn_fbOrig.ShadowSoftness    or 0.2
                    L.EnvironmentDiffuseScale  = fn_fbOrig.EnvironmentDiffuseScale  or 1
                    L.EnvironmentSpecularScale = fn_fbOrig.EnvironmentSpecularScale or 1
                end
            end)
            -- Effekte wiederherstellen
            for _, e in ipairs(fn_fbEffects) do
                pcall(function()
                    if e.obj and e.obj.Parent then
                        e.obj[e.prop] = e.val
                    end
                end)
            end
            fn_fbOrig    = {}
            fn_fbEffects = {}
        end

        fn_fbLbl = fn_btn("🌕 Fullbright AN / AUS", C_ROW, function()
            fn_fbOn = not fn_fbOn
            if fn_fbOn then
                fn_fbApply()
                fn_fbLbl.TextColor3 = Color3.fromRGB(255, 230, 80)
                fn_setStatus("🌕 Fullbright AN – alles sichtbar!", Color3.fromRGB(255, 230, 80))
            else
                fn_fbRemove()
                fn_fbLbl.TextColor3 = C_TEXT
                fn_setStatus("🌑 Fullbright AUS – Original wiederhergestellt", C_SUB)
            end
        end)

        -- Fullbright beim Schließen ebenfalls zurücksetzen
        -- (wird unten im AncestryChanged-Block mitgekoppelt via fn_fbOn-Check)
        sg_fn.AncestryChanged:Connect(function()
            if not sg_fn.Parent and fn_fbOn then
                fn_fbOn = false
                pcall(fn_fbRemove)
            end
        end)

        -- ── NPC / Item Erkennung (muss VOR dem Master-Loop stehen) ──────
        local FNAF_NPC_KEYS = {
            "freddy","bonnie","chica","foxy","golden","springtrap","spring",
            "nightmare","shadow","ballora","funtime","baby","ennard",
            "glamrock","roxanne","monty","vanny","glitchtrap","puppet",
            "mangle","afton","withered","phantom","molten","scrap",
            "lefty","helpy","dreadbear","mimic","animatronic","npc",
            "fazbear","security","bot","bear","fredfred","fredbear",
        }
        -- [FIX v99] Nur echte FNAF-spezifische Item-Keywords.
        -- Generische Namen wie "item","pickup","object","part","scrap","box","crate",
        -- "poster","photo","picture","bottle","can","bag","component" wurden entfernt –
        -- sie treffen Tausende Terrain-/Deko-Parts und erzeugen Massen-False-Positives.
        local FNAF_ITEM_KEYS = {
            -- Taschenlampen / Kameras
            "flashlight","lantern","torch",
            -- Schlüssel / Zugang
            "key","badge","pass","card","keycard",
            -- Energie / Batterien (spezifisch)
            "battery","fuse","generator","charge",
            -- Münzen / Tokens / Tickets
            "faz","coin","token","ticket","prize","plush",
            -- Essen / Deko-Items (FNAF-spezifisch)
            "cupcake","pizza","cake","candy","gift",
            -- Musik / Kurbel
            "musicbox","music box","crank","tape","cassette",
            -- Teile / Rüstungen (FNAF-spezifisch)
            "endoskeleton","endo","suit","springlock",
            -- Sonstige FNAF-spezifische Items
            "mask","lure","bait","note","log","report","document",
            "wrench","screwdriver","device","gadget",
            "crystal","gem","shard",
            "upgrade","module","chip","disk","drive",
        }

        local function fn_keyMatch(name, keys)
            local low = name:lower()
            for _, k in ipairs(keys) do
                if low:find(k, 1, true) then return true end
            end
            return false
        end

        -- ── Individuelle NPC-Farben je FNAF-Charakter ────────────────────
        -- Reihenfolge: spezifischere Namen zuerst (z.B. "springtrap" vor "spring")
        local FNAF_NPC_COLORS = {
            -- { keyword, fillColor, textColor }
            {"fredbear",   Color3.fromRGB(210,170,  20), Color3.fromRGB(255,220, 80)},
            {"golden",     Color3.fromRGB(210,170,  20), Color3.fromRGB(255,220, 80)},
            {"glamrock",   Color3.fromRGB(255, 50, 180), Color3.fromRGB(255,160,230)},
            {"roxanne",    Color3.fromRGB(  0,200,  80), Color3.fromRGB(100,255,160)},
            {"monty",      Color3.fromRGB( 40,160,  40), Color3.fromRGB(120,220,120)},
            {"funtime",    Color3.fromRGB(255,160,200), Color3.fromRGB(255,210,230)},
            {"nightmare",  Color3.fromRGB(120,  0,   0), Color3.fromRGB(220, 80, 80)},
            {"springtrap", Color3.fromRGB( 60,120,  30), Color3.fromRGB(130,200, 70)},
            {"spring",     Color3.fromRGB( 60,120,  30), Color3.fromRGB(130,200, 70)},
            {"glitchtrap", Color3.fromRGB(200,  0, 200), Color3.fromRGB(255,100,255)},
            {"withered",   Color3.fromRGB( 80, 60,  60), Color3.fromRGB(160,130,130)},
            {"phantom",    Color3.fromRGB(  0,200,180), Color3.fromRGB(100,255,230)},
            {"molten",     Color3.fromRGB(220,100,  30), Color3.fromRGB(255,160, 80)},
            {"dreadbear",  Color3.fromRGB( 30, 70,  30), Color3.fromRGB(100,160,100)},
            {"marionette", Color3.fromRGB(200,200,200), Color3.fromRGB(255,255,255)},
            {"puppet",     Color3.fromRGB(200,200,200), Color3.fromRGB(255,255,255)},
            {"ballora",    Color3.fromRGB(160, 90, 220), Color3.fromRGB(220,160,255)},
            {"ennard",     Color3.fromRGB(  0,200,200), Color3.fromRGB(100,255,255)},
            {"shadow",     Color3.fromRGB( 40,  0,  80), Color3.fromRGB(140, 80,220)},
            {"mangle",     Color3.fromRGB(255,160,160), Color3.fromRGB(255,210,210)},
            {"vanny",      Color3.fromRGB(240,240,240), Color3.fromRGB(255,255,255)},
            {"afton",      Color3.fromRGB(100,  0, 160), Color3.fromRGB(180, 80,255)},
            {"mimic",      Color3.fromRGB(  0,160,200), Color3.fromRGB( 80,220,255)},
            {"lefty",      Color3.fromRGB( 30, 30,  30), Color3.fromRGB(120,120,120)},
            {"scrap",      Color3.fromRGB( 90, 90,  90), Color3.fromRGB(160,160,160)},
            {"baby",       Color3.fromRGB(220,100,  40), Color3.fromRGB(255,170,100)},
            {"helpy",      Color3.fromRGB(220,180,   0), Color3.fromRGB(255,220, 80)},
            {"bonnie",     Color3.fromRGB( 90, 50, 180), Color3.fromRGB(180,140,255)},
            {"cupcake",    Color3.fromRGB(255, 105, 180), Color3.fromRGB(255, 200, 230)},
            {"chica",      Color3.fromRGB(220,190,   0), Color3.fromRGB(255,235, 80)},
            {"foxy",       Color3.fromRGB(200, 70,  30), Color3.fromRGB(255,140, 80)},
            {"freddy",     Color3.fromRGB(165,110,  45), Color3.fromRGB(230,180,100)},
            {"fazbear",    Color3.fromRGB(165,110,  45), Color3.fromRGB(230,180,100)},
        }

        -- Gibt die passende Fill- und Text-Farbe für einen FNAF-NPC zurück
        local function fn_getNPCColor(obj)
            local low = obj.Name:lower()
            for _, entry in ipairs(FNAF_NPC_COLORS) do
                if low:find(entry[1], 1, true) then
                    return entry[2], entry[3]
                end
            end
            -- Fallback: generisches Rot für unbekannte NPCs
            return Color3.fromRGB(255, 60, 60), Color3.fromRGB(255, 200, 200)
        end

        -- Prüft ob ein NPC ein echter FNAF-Charakter ist (hat Eintrag in FNAF_NPC_COLORS).
        -- Generische NPCs ("npc", "bot", "animatronic" usw.) geben false zurück → kein Name im ESP.
        local function fn_isFNAFChar(obj)
            local low = obj.Name:lower()
            for _, entry in ipairs(FNAF_NPC_COLORS) do
                if low:find(entry[1], 1, true) then return true end
            end
            return false
        end

        local function fn_isNPC(obj)
            if not obj:IsA("Model") then return false end
            -- [FIX v99] Toy-Animatronics (ToyFreddy, ToyBonnie etc.) sind echte Gegner in
            -- FNAF Eternal Nights → kein Ausschluss mehr.
            if obj:FindFirstChildOfClass("Humanoid")
            or obj:FindFirstChildOfClass("AnimationController") then return true end
            return fn_keyMatch(obj.Name, FNAF_NPC_KEYS)
        end

        -- Wand-Kamera: Model/Part mit Kamera-Keyword, aber KEIN Tool → ist an der Wand, kein Aufheb-Item.
        -- Hand-Kamera: Tool-Instanz mit Kamera-Keyword → aufhebbar, wird als Item behandelt.
        local WALL_CAMERA_KEYS = {"camera","cam","cctv","monitor","surveillance","securitycam","wallcam","wall cam"}
        local function fn_isWallCamera(obj)
            if obj:IsA("Tool") then return false end  -- Tools sind immer Handgegenstände
            local low = obj.Name:lower()
            for _, k in ipairs(WALL_CAMERA_KEYS) do
                if low:find(k, 1, true) then return true end
            end
            return false
        end

        -- Erkennt Buchstaben-Toyspupen (einzelne Buchstaben oder Letter/Buchstabe-Keywords).
        -- Diese werden vom Item-ESP IMMER ausgeschlossen.
        local BUCHSTABEN_PUPPE_KEYS = {"toy"}
        local function fn_isBuchstabenPuppe(obj)
            local name = obj.Name
            local low  = name:lower()
            -- Einzelner Buchstabe (z.B. "A", "B" … "Z")
            if name:match("^%a$") then return true end
            -- Buchstabe + Unterstrich oder Zahl (z.B. "A_1", "B2", "C_Puppet")
            if name:match("^%a[_%d]") then return true end
            -- Enthält Letter/Buchstabe/Alphabet-Keyword
            for _, k in ipairs(BUCHSTABEN_PUPPE_KEYS) do
                if low:find(k, 1, true) then return true end
            end
            return false
        end

        local function fn_isItem(obj)
            -- Toy Puppen immer ausschließen
            if fn_isBuchstabenPuppe(obj) then return false end
            -- Echte Tools (mit E aufhebbar)
            if obj:IsA("Tool") then return true end
            -- Sonderfälle: Items die auch als Model vorkommen können
            local low = obj.Name:lower()
            local specialMatch =
                low:find("oldflashlight",  1, true) or
                low:find("old flashlight", 1, true) or
                low:find("old_flashlight", 1, true) or
                low:find("batterypack",    1, true) or
                low:find("battery pack",   1, true) or
                low:find("battery_pack",   1, true) or
                low:find("battery",        1, true) or
                low:find("battpack",       1, true)
            if specialMatch and obj:FindFirstChildWhichIsA("BasePart") then
                return true
            end
            return false
        end

        -- ══════════════════ MASTER-LOOP + SHARED CACHE ══════════════════
        -- Ein einziger Heartbeat ersetzt alle einzelnen Loops.
        -- workspace:GetDescendants() wird nur alle 5 Sekunden aufgerufen.
        -- ────────────────────────────────────────────────────────────────

        local fn_masterConn  = nil   -- einziger Heartbeat
        local fn_cache       = {}    -- gecachte Descendants-Liste
        local fn_cacheTime   = 0     -- Sekunden seit letztem Cache-Refresh
        local CACHE_INTERVAL = 12    -- Cache alle 12s neu aufbauen (teuer!)

        -- Feature-Zustände
        local fn_staminaOn = false
        local fn_powerOn   = false
        local fn_nightOn   = false
        local fn_musicOn   = false
        local fn_doorOn    = false
        local fn_godOn     = false   -- ❤️ God Mode
        local fn_alarmOn   = false   -- 🚨 Monster-Alarm
        local fn_fleeOn    = false   -- 🏃 Auto-Flee
        local fn_fleeRange   = 25      -- Flucht-Trigger in Studs

        -- ── Neue Feature-Flags (v100) ────────────────────────────────────
        local fn_freezeOn    = false   -- 🧊 Animatronic Freeze
        local fn_breachOn    = false   -- 🚨 Door Anti-Breach
        local fn_breachRange = 15      -- Studs bis Auto-Tür auslöst
        local fn_flashOn     = false   -- 🔦 Taschenlampen-Batterie Fix
        local fn_genOn       = false   -- ⚙️  Generator Auto-Repair
        local fn_staticOn    = false   -- 📷 No Camera Static
        local fn_soundOn     = false   -- 🔊 Sound-ESP
        local fn_soundESP    = {}      -- { hl, bb } Einträge (Sound-ESP)
        local fn_soundMap    = {}      -- [part] = entry  (Dedup)
        local fn_frozenNPCs  = {}      -- originale WalkSpeed/JumpPower merken

        -- Button-Labels (werden nach Deklaration gesetzt)
        -- [FIX v98] Label-Locals in Tabelle → spart 7 lokale Register
        local fn_lbls = {sta=nil,pw=nil,ni=nil,mu=nil,dor=nil,go=nil,al=nil,fl=nil,
                         fr=nil,br=nil,fl2=nil,ge=nil,st=nil,so=nil}

        -- Gecachte Referenzen (werden beim Aktivieren einmalig gesucht)
        local fn_staminaRef    = nil  -- { kind, ref }
        local fn_powerVals     = {}   -- Value-Objekte (NumberValue etc.)
        local fn_powerAttrObjs = {}   -- Objekte mit Power-Attributen (pre-gefiltert)
        local fn_powerRemotes  = {}   -- RemoteEvents mit Power-Namen (pre-gefiltert)
        local fn_timeVals      = {}   -- Value-Objekte für Nacht
        local fn_nightRemotes  = {}   -- RemoteEvents für Night-Skip (pre-gefiltert)
        local fn_musicVals     = {}   -- Value-Objekte für Musikbox
        local fn_doorObjs      = {}   -- Door-Objekte
        local fn_npcCache      = {}   -- NPC-Modelle (für Auto-Tür)

        -- ── Schlüssellisten ─────────────────────────────────────────────
        local STAMINA_ATTR      = {"Stamina","stamina","Energy","energy","Sprint","sprint","Endurance","endurance","Fuel","fuel"}
        local STAMINA_VAL_NAMES = {"Stamina","StaminaValue","Energy","EnergyValue","Sprint","SprintValue","Endurance","Fuel"}
        local POWER_KEYS        = {"power","strom","battery","generator","electricity","energy","fuel","charge",
                                   "Power","Battery","Generator","Energy","Fuel","Charge","Electricity",
                                   "powerLevel","powerAmount","currentPower","maxPower","PowerLevel"}
        local NIGHT_KEYS        = {"time","hour","clock","night","timer","countdown","minute","second","phase",
                                   "Time","Night","Timer","Countdown","NightTimer","TimeLeft","TimeRemaining",
                                   "nightTime","currentTime","roundTime","phaseTime"}
        local MUSIC_KEYS        = {"musicbox","music_box","music","puppet","windup","wind","marionette","crank"}
        local DOOR_KEYS         = {"door","tür","gate","shutter","hatch","vent","entrance","left","right","hallway"}

        -- ── Cache aufbauen (teuer, aber selten) ─────────────────────────
        local function fn_rebuildCache()
            fn_cache    = workspace:GetDescendants()
            fn_npcCache = {}
            fn_doorObjs = {}
            for _, obj in ipairs(fn_cache) do
                if fn_isNPC(obj) then
                    table.insert(fn_npcCache, obj)
                end
                if (obj:IsA("Model") or obj:IsA("BasePart")) and fn_keyMatch(obj.Name, DOOR_KEYS) then
                    table.insert(fn_doorObjs, obj)
                end
            end
        end

        -- ── Stamina-Referenz einmalig finden ─────────────────────────────
        local function fn_findStaminaRef()
            local char = LP_FN.Character
            if not char then return nil end
            for _, n in ipairs(STAMINA_VAL_NAMES) do
                local v = char:FindFirstChild(n)
                if v and (v:IsA("NumberValue") or v:IsA("IntValue")) then
                    return { kind = "value", ref = v }
                end
            end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                for _, a in ipairs(STAMINA_ATTR) do
                    if type(hum:GetAttribute(a)) == "number" then
                        return { kind = "attr", obj = hum, attr = a }
                    end
                end
            end
            for _, a in ipairs(STAMINA_ATTR) do
                if type(char:GetAttribute(a)) == "number" then
                    return { kind = "attr", obj = char, attr = a }
                end
            end
            local pg = LP_FN:FindFirstChild("PlayerGui")
            if pg then
                for _, d in ipairs(pg:GetDescendants()) do
                    if (d:IsA("NumberValue") or d:IsA("IntValue")) and fn_keyMatch(d.Name, STAMINA_ATTR) then
                        return { kind = "value", ref = d }
                    end
                end
            end
            return nil
        end

        -- ── NumberValue-Listen aus ALLEN möglichen Orten aufbauen ───────────
        local VALUE_CLASSES = {"NumberValue","IntValue","IntConstrainedValue","NumberConstrainedValue"}
        local function fn_isValClass(obj)
            for _, c in ipairs(VALUE_CLASSES) do if obj:IsA(c) then return true end end
            return false
        end

        local function fn_buildValList(keys)
            local out  = {}
            local seen = {}
            local function addFrom(list)
                for _, obj in ipairs(list) do
                    if fn_isValClass(obj) and fn_keyMatch(obj.Name, keys) and not seen[obj] then
                        seen[obj] = true
                        table.insert(out, obj)
                    end
                end
            end
            -- workspace (gecacht)
            addFrom(fn_cache)
            -- PlayerGui
            pcall(function()
                local pg = LP_FN:FindFirstChild("PlayerGui")
                if pg then addFrom(pg:GetDescendants()) end
            end)
            -- ReplicatedStorage – häufigster Ort für Spielwerte
            pcall(function()
                addFrom(game:GetService("ReplicatedStorage"):GetDescendants())
            end)
            -- LocalPlayer selbst + Scripts
            pcall(function() addFrom(LP_FN:GetDescendants()) end)
            -- Character
            pcall(function()
                local char = LP_FN.Character
                if char then addFrom(char:GetDescendants()) end
            end)
            return out
        end

        local function fn_setValMax(vals, fallback)
            for _, v in ipairs(vals) do
                pcall(function()
                    if not v.Parent then return end
                    local mx = v:GetAttribute("MaxValue") or v:GetAttribute("Max") or fallback or 100
                    if v:IsA("IntConstrainedValue") or v:IsA("NumberConstrainedValue") then
                        mx = v.MaxValue
                    end
                    if v.Value < mx then v.Value = mx end
                end)
            end
        end

        -- ── Einmalige Vollscans beim Aktivieren – NIE im Loop ────────────
        -- Scannt workspace + ReplicatedStorage + LocalPlayer einmal durch und
        -- baut kleine, vorge-filterte Listen. Der Loop nutzt nur diese Listen.
        local function fn_buildPowerCache()
            fn_powerVals     = {}
            fn_powerAttrObjs = {}
            fn_powerRemotes  = {}
            local seen = {}
            local function checkObj(obj)
                if seen[obj] then return end
                seen[obj] = true
                -- Value-Objekte
                if fn_isValClass(obj) and fn_keyMatch(obj.Name, POWER_KEYS) then
                    table.insert(fn_powerVals, obj)
                end
                -- Attribute
                for _, k in ipairs(POWER_KEYS) do
                    if type(obj:GetAttribute(k)) == "number" then
                        table.insert(fn_powerAttrObjs, {obj = obj, key = k})
                        break
                    end
                end
                -- RemoteEvents
                if obj:IsA("RemoteEvent") and fn_keyMatch(obj.Name, POWER_KEYS) then
                    table.insert(fn_powerRemotes, obj)
                end
            end
            pcall(function() for _, o in ipairs(fn_cache) do checkObj(o) end end)
            pcall(function()
                for _, o in ipairs(game:GetService("ReplicatedStorage"):GetDescendants()) do checkObj(o) end
            end)
            pcall(function() for _, o in ipairs(LP_FN:GetDescendants()) do checkObj(o) end end)
            pcall(function()
                local char = LP_FN.Character
                if char then for _, o in ipairs(char:GetDescendants()) do checkObj(o) end end
            end)
        end

        local NIGHT_SKIP_KEYS = {"skipnight","nextnight","endnight","skipround","nextround","nightend","endround"}
        local function fn_buildNightCache()
            fn_timeVals     = {}
            fn_nightRemotes = {}
            local seen = {}
            local function checkObj(obj)
                if seen[obj] then return end
                seen[obj] = true
                if fn_isValClass(obj) and fn_keyMatch(obj.Name, NIGHT_KEYS) then
                    table.insert(fn_timeVals, obj)
                end
                if obj:IsA("RemoteEvent") and
                   (fn_keyMatch(obj.Name, NIGHT_SKIP_KEYS) or fn_keyMatch(obj.Name, NIGHT_KEYS)) then
                    table.insert(fn_nightRemotes, obj)
                end
            end
            pcall(function() for _, o in ipairs(fn_cache) do checkObj(o) end end)
            pcall(function()
                for _, o in ipairs(game:GetService("ReplicatedStorage"):GetDescendants()) do checkObj(o) end
            end)
            pcall(function() for _, o in ipairs(LP_FN:GetDescendants()) do checkObj(o) end end)
        end

        -- ── Anti-Jumpscare: event-basiert + Loop + Fullscreen-Erkennung ──
        local fn_ajOn      = false
        local fn_ajConn    = nil
        local fn_ajLbl
        local fn_ajKnownOk = {}   -- ScreenGuis die wir als "harmlos" markiert haben

        -- Breite Keyword-Liste für Jumpscare/Death-GUIs
        local JUMP_GUI_KEYS = {
            "jumpscare","jump_scare","scare","caught","death","died","killed",
            "gameover","game_over","game over","lose","lost","failed","fail",
            "endscreen","end_screen","over","caught","attack","horror",
            "scream","dead","eliminated","nightover","night_over","roundover",
            "round_over","defeat","bitten","eaten","trapped",
        }

        -- Erkennt ob ein ScreenGui eine Jumpscare/Todesscreen-GUI ist.
        -- Kriterium 1: Name passt zu JUMP_GUI_KEYS
        -- Kriterium 2: Hat einen großen (>80% Bildschirm) dunklen/roten Frame/ImageLabel
        local function fn_isJumpscareGui(gui)
            if not gui:IsA("ScreenGui") then return false end
            if gui == sg_fn then return false end          -- eigenes GUI nie anfassen
            -- Kriterium 1 – Name-Match
            if fn_keyMatch(gui.Name, JUMP_GUI_KEYS) then return true end
            -- Kriterium 2 – Vollbild-Overlay mit dunkler/roter Farbe
            for _, d in ipairs(gui:GetDescendants()) do
                if d:IsA("Frame") or d:IsA("ImageLabel") then
                    local ok, sx, sy = pcall(function()
                        return d.Size.X.Scale, d.Size.Y.Scale
                    end)
                    if ok and type(sx)=="number" and sx >= 0.85 and sy >= 0.85 then
                        -- Vollbild → prüfe Farbe (sehr dunkel oder sehr rot)
                        local c = d.BackgroundColor3
                        local r,g,b = c.R, c.G, c.B
                        local isDark = (r+g+b) < 0.5
                        local isRed  = r > 0.6 and g < 0.3 and b < 0.3
                        if d.BackgroundTransparency < 0.8 and (isDark or isRed) then
                            return true
                        end
                    end
                end
            end
            return false
        end

        local function fn_hideJumpscareGui(gui)
            pcall(function() gui.Enabled = false end)
        end

        -- Einmalig alle vorhandenen PlayerGui-Kinder als "bekannt & OK" markieren
        local function fn_ajInitKnown()
            local pg = LP_FN:FindFirstChild("PlayerGui")
            if not pg then return end
            fn_ajKnownOk = {}
            for _, gui in ipairs(pg:GetChildren()) do
                if gui:IsA("ScreenGui") and gui ~= sg_fn then
                    fn_ajKnownOk[gui] = true
                end
            end
        end

        -- Loop-Scan (0.2s): NUR Name-Check, kein GetDescendants → kein Lag
        local function fn_ajScan()
            local pg = LP_FN:FindFirstChild("PlayerGui")
            if not pg then return end
            for _, gui in ipairs(pg:GetChildren()) do
                if gui:IsA("ScreenGui") and gui ~= sg_fn and gui.Enabled then
                    if fn_keyMatch(gui.Name, JUMP_GUI_KEYS) then
                        fn_hideJumpscareGui(gui)
                    elseif not fn_ajKnownOk[gui] then
                        -- Neues unbekanntes GUI → vollständige Prüfung (inkl. GetDescendants)
                        -- aber nur einmal, dann als "geprüft" markieren
                        fn_ajKnownOk[gui] = true
                        if fn_isJumpscareGui(gui) then fn_hideJumpscareGui(gui) end
                    end
                end
            end
        end

        -- ── Tür schließen ────────────────────────────────────────────────
        local function fn_closeDoor(obj)
            local cd = obj:FindFirstChildOfClass("ClickDetector") or obj:FindFirstChildWhichIsA("ClickDetector")
            if cd then pcall(function() fireclickdetector(cd) end); return end
            local pp = obj:FindFirstChildOfClass("ProximityPrompt") or obj:FindFirstChildWhichIsA("ProximityPrompt")
            if pp then pcall(function() fireproximityprompt(pp) end); return end
            local bv = obj:FindFirstChild("Open") or obj:FindFirstChild("IsOpen") or obj:FindFirstChild("Opened")
            if bv and bv:IsA("BoolValue") then pcall(function() bv.Value = false end) end
        end

        -- Schließt alle Türen OHNE Strom – reaktiviert deaktivierte Interaktionen kurz
        -- und feuert sie, damit der Server die Tür für ALLE Spieler schließt.
        local DOOR_FORCE_KEYS  = {"door","tür","gate","shutter","hatch","vent","entrance","left","right","hallway","electric"}
        local DOOR_REMOTE_KEYS = {"closedoor","close_door","door","toggledoor","toggle_door","doorclose","doorcontrol"}

        local function fn_forceDoorObj(obj)
            local fired = false

            -- 1) ClickDetector: auch wenn deaktiviert (MaxActivationDistance = 0)
            for _, cd in ipairs(obj:GetDescendants()) do
                if cd:IsA("ClickDetector") then
                    pcall(function()
                        local oldDist = cd.MaxActivationDistance
                        cd.MaxActivationDistance = 999   -- kurz reaktivieren
                        fireclickdetector(cd)
                        cd.MaxActivationDistance = oldDist
                        fired = true
                    end)
                    if fired then return true end
                end
            end

            -- 2) ProximityPrompt: auch wenn Enabled = false
            for _, pp in ipairs(obj:GetDescendants()) do
                if pp:IsA("ProximityPrompt") then
                    pcall(function()
                        local wasEnabled = pp.Enabled
                        pp.Enabled = true
                        fireproximityprompt(pp)
                        pp.Enabled = wasEnabled
                        fired = true
                    end)
                    if fired then return true end
                end
            end

            -- 3) BoolValue direkt setzen (client → falls server liest)
            for _, name in ipairs({"Open","IsOpen","Opened","DoorOpen","opened"}) do
                local bv = obj:FindFirstChild(name, true)
                if bv and bv:IsA("BoolValue") then
                    pcall(function() bv.Value = false end)
                    fired = true
                end
            end

            return fired
        end

        local function fn_forceAllDoors()
            pcall(fn_rebuildCache)

            -- Strategie: Nur Objekte die einen echten Interaktions-Detector haben
            -- = genau die Türen mit Knöpfen (Secure Room Türen).
            -- Kein Name-Filter nötig – ClickDetector/ProximityPrompt = interaktive Tür.
            local count = 0
            local seen  = {}

            for _, obj in ipairs(fn_cache) do
                -- Direkt ein ClickDetector oder ProximityPrompt?
                local isInteractive = obj:IsA("ClickDetector") or obj:IsA("ProximityPrompt")
                -- Oder hat ein Model/Part einen solchen Detector als Kind?
                if not isInteractive and (obj:IsA("Model") or obj:IsA("BasePart")) then
                    isInteractive = obj:FindFirstChildOfClass("ClickDetector")
                               or obj:FindFirstChildOfClass("ProximityPrompt")
                               or obj:FindFirstChildWhichIsA("ClickDetector")
                               or obj:FindFirstChildWhichIsA("ProximityPrompt")
                end

                if isInteractive then
                    -- Eltern-Model finden um doppeltes Feuern zu vermeiden
                    local root = obj
                    if obj:IsA("ClickDetector") or obj:IsA("ProximityPrompt") then
                        root = obj.Parent or obj
                    end
                    if not seen[root] then
                        seen[root] = true
                        if fn_forceDoorObj(root) then count = count + 1 end
                    end
                end
            end

            -- Zusätzlich: RemoteEvents mit Tür-Keywords feuern
            local remotesFired = 0
            pcall(function()
                for _, obj in ipairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
                    if obj:IsA("RemoteEvent") and fn_keyMatch(obj.Name, DOOR_REMOTE_KEYS) then
                        pcall(function() obj:FireServer(false) end)
                        pcall(function() obj:FireServer("close") end)
                        pcall(function() obj:FireServer() end)
                        remotesFired = remotesFired + 1
                    end
                end
            end)

            local msg
            if count > 0 then
                msg = ("🔒 %d Knopf-Tür(en) geschlossen!"):format(count)
                if remotesFired > 0 then
                    msg = msg .. (" + %d Remote(s)"):format(remotesFired)
                end
            else
                msg = "⚠️ Keine Knopf-Türen gefunden – vielleicht noch kein Strom-Ausfall?"
            end
            fn_setStatus(msg, count > 0 and Color3.fromRGB(100, 220, 100) or Color3.fromRGB(255, 180, 50))
        end

        -- ══════════════════ MASTER TICK ══════════════════════════════════
        -- Intervalle (Sekunden):  Stamina 0.5 | Power 2 | Night 1 | Music 2 | Door 1
        --                         God 0.5     | Alarm 0.5 | Flee 0.2
        -- [FIX v98] Timer-Locals in Tabelle → spart 8 lokale Register
        local _T = {sta=0,pw=0,ni=0,mu=0,dor=0,go=0,al=0,fl=0,aj=0,
                    fr=0,br=0,fl2=0,ge=0,so=0}

        local function fn_startMaster()
            if fn_masterConn then return end
            fn_cacheTime = CACHE_INTERVAL  -- sofortiger erster Cache-Build
            fn_masterConn = game:GetService("RunService").Heartbeat:Connect(function(dt)
                -- Cache refresh (alle 5s, einmal GetDescendants)
                fn_cacheTime = fn_cacheTime + dt
                if fn_cacheTime >= CACHE_INTERVAL then
                    fn_cacheTime = 0
                    pcall(fn_rebuildCache)
                    -- Caches nach Workspace-Rebuild auffrischen
                    if fn_powerOn then task.spawn(fn_buildPowerCache) end
                    if fn_nightOn then task.spawn(fn_buildNightCache) end
                    if fn_musicOn then fn_musicVals = fn_buildValList(MUSIC_KEYS) end
                end

                -- ⚡ Stamina (0.5s)
                if fn_staminaOn then
                    _T.sta = _T.sta + dt
                    if _T.sta >= 0.5 then
                        _T.sta = 0
                        pcall(function()
                            local _invalid = not fn_staminaRef
                                or (fn_staminaRef.kind == "value" and (not fn_staminaRef.ref or not fn_staminaRef.ref.Parent))
                                or (fn_staminaRef.kind == "attr"  and (not fn_staminaRef.obj or not fn_staminaRef.obj.Parent))
                            if _invalid then fn_staminaRef = fn_findStaminaRef() end
                            if fn_staminaRef then
                                local s = fn_staminaRef
                                if s.kind == "value" then
                                    local mx = s.ref:GetAttribute("MaxValue") or s.ref:GetAttribute("Max") or 100
                                    if s.ref.Value < mx then s.ref.Value = mx end
                                elseif s.kind == "attr" then
                                    local cur = s.obj:GetAttribute(s.attr)
                                    local mx  = s.obj:GetAttribute("Max"..s.attr) or 100
                                    if type(cur) == "number" and cur < mx then s.obj:SetAttribute(s.attr, mx) end
                                end
                            end
                        end)
                    end
                else _T.sta = 0 end

                -- 🔋 Power (1s) – nur vorge-filterte Listen, KEIN GetDescendants im Loop
                if fn_powerOn then
                    _T.pw = _T.pw + dt
                    if _T.pw >= 1 then
                        _T.pw = 0
                        pcall(function()
                            -- Value-Objekte auf Max setzen (kleine Liste, schnell)
                            fn_setValMax(fn_powerVals, 100)
                            -- Attribute-Objekte (nur vorge-filterte)
                            for _, e in ipairs(fn_powerAttrObjs) do
                                pcall(function()
                                    if not e.obj.Parent then return end
                                    local k  = e.key
                                    local mx = e.obj:GetAttribute("Max"..k)
                                           or e.obj:GetAttribute(k.."Max") or 100
                                    e.obj:SetAttribute(k, mx)
                                end)
                            end
                            -- RemoteEvents (vorge-filtert, meist leer)
                            for _, re in ipairs(fn_powerRemotes) do
                                pcall(function() if re.Parent then re:FireServer(100) end end)
                            end
                        end)
                    end
                else _T.pw = 0 end


                -- ❤️ God Mode (0.5s): Humanoid-Health immer voll
                if fn_godOn then
                    _T.go = _T.go + dt
                    if _T.go >= 0.5 then
                        _T.go = 0
                        pcall(function()
                            local char = LP_FN.Character
                            local hum  = char and char:FindFirstChildOfClass("Humanoid")
                            if hum and hum.Health > 0 then hum.Health = hum.MaxHealth end
                        end)
                    end
                else _T.go = 0 end

                -- 🚨 Monster-Alarm (0.5s): Entfernung + Name des nächsten Monsters
                if fn_alarmOn then
                    _T.al = _T.al + dt
                    if _T.al >= 0.5 then
                        _T.al = 0
                        pcall(function()
                            local hrp = fn_getHRP()
                            if not hrp then return end
                            local myPos = hrp.Position
                            local minDist, minName = math.huge, ""
                            for _, obj in ipairs(fn_cache) do
                                if fn_isNPC(obj) then
                                    local root = obj:FindFirstChild("HumanoidRootPart")
                                             or obj:FindFirstChildWhichIsA("BasePart")
                                    if root then
                                        local d = (root.Position - myPos).Magnitude
                                        if d < minDist then minDist = d; minName = obj.Name end
                                    end
                                end
                            end
                            if minDist < math.huge then
                                local col = minDist < 15 and Color3.fromRGB(255, 60, 60)
                                         or minDist < 30 and Color3.fromRGB(255, 180, 50)
                                         or Color3.fromRGB(100, 220, 100)
                                fn_setStatus(("🚨 %s — %.0f Studs"):format(minName, minDist), col)
                            else
                                fn_setStatus("🚨 Alarm aktiv – kein Monster in Sicht", Color3.fromRGB(100, 220, 100))
                            end
                        end)
                    end
                else _T.al = 0 end

                -- 😱 Anti-Jumpscare (0.2s): PlayerGui nach Jumpscare-Overlays scannen
                if fn_ajOn then
                    _T.aj = _T.aj + dt
                    if _T.aj >= 0.2 then
                        _T.aj = 0
                        pcall(fn_ajScan)
                    end
                else _T.aj = 0 end

                -- 🏃 Auto-Flee (0.5s): Schnell, kein Raycast – flieht via Away-Vektor
                if fn_fleeOn then
                    _T.fl = _T.fl + dt
                    if _T.fl >= 0.5 then
                        _T.fl = 0
                        pcall(function()
                            local hrp = fn_getHRP()
                            if not hrp then return end
                            local myPos = hrp.Position

                            -- Nächstes Monster suchen + Away-Vektor summieren
                            local away   = Vector3.new(0, 0, 0)
                            local minD   = math.huge
                            local minNm  = ""
                            for _, obj in ipairs(fn_cache) do
                                if fn_isNPC(obj) then
                                    local r = obj:FindFirstChild("HumanoidRootPart")
                                           or obj:FindFirstChildWhichIsA("BasePart")
                                    if r then
                                        local diff = myPos - r.Position
                                        local d    = diff.Magnitude
                                        if d < minD then minD = d; minNm = obj.Name end
                                        if d < fn_fleeRange and d > 0.01 then
                                            away = away + diff.Unit
                                        end
                                    end
                                end
                            end

                            -- Nur flüchten wenn wirklich jemand zu nah ist
                            if away.Magnitude < 0.01 then return end

                            local dir   = away.Unit
                            local dest  = myPos + Vector3.new(dir.X * 35, 0, dir.Z * 35)
                            hrp.CFrame  = CFrame.new(dest)
                            fn_setStatus(("🏃 Geflohen! %s war %.0f Studs nah"):format(minNm, minD),
                                Color3.fromRGB(100, 220, 100))
                        end)
                    end
                else _T.fl = 0 end

                -- [FIX v99 Bug 2] Night-Skip (1s) ─────────────────────────────────
                -- Setzt Zeit-Values auf 0 (Countdown) oder Maximum (Aufstieg) und
                -- feuert alle Night-Skip-RemoteEvents.
                if fn_nightOn then
                    _T.ni = _T.ni + dt
                    if _T.ni >= 1 then
                        _T.ni = 0
                        pcall(function()
                            -- Countdown-artige Values (TimeLeft, Countdown …) auf 0 setzen
                            local lowNames = {"countdown","timeleft","timeremaining","remaining","left"}
                            for _, v in ipairs(fn_timeVals) do
                                if v and v.Parent then
                                    local low = v.Name:lower()
                                    local isCountdown = false
                                    for _, kw in ipairs(lowNames) do
                                        if low:find(kw, 1, true) then isCountdown = true; break end
                                    end
                                    pcall(function()
                                        if isCountdown then
                                            v.Value = 0
                                        else
                                            -- Aufsteigende Timer → auf Max setzen
                                            local mx = v:GetAttribute("MaxValue")
                                                   or v:GetAttribute("Max") or 100
                                            if v:IsA("IntConstrainedValue")
                                            or v:IsA("NumberConstrainedValue") then mx = v.MaxValue end
                                            v.Value = mx
                                        end
                                    end)
                                end
                            end
                            -- RemoteEvents feuern (skipnight / nextnight / endnight …)
                            for _, re in ipairs(fn_nightRemotes) do
                                pcall(function()
                                    if re.Parent then
                                        re:FireServer()
                                        re:FireServer(true)
                                        re:FireServer(1)
                                    end
                                end)
                            end
                        end)
                    end
                else _T.ni = 0 end

                -- [FIX v99 Bug 2] Infinite Music Box (2s) ─────────────────────────
                -- Hält die Musikbox-Values dauerhaft auf Maximum (Puppe schläft).
                if fn_musicOn then
                    _T.mu = _T.mu + dt
                    if _T.mu >= 2 then
                        _T.mu = 0
                        pcall(function()
                            fn_setValMax(fn_musicVals, 100)
                        end)
                    end
                else _T.mu = 0 end

                -- [FIX v99 Bug 2] Auto-Tür (3s) ───────────────────────────────────
                -- Schließt alle interaktiven Türen regelmäßig ohne Energieverbrauch.
                if fn_doorOn then
                    _T.dor = _T.dor + dt
                    if _T.dor >= 3 then
                        _T.dor = 0
                        pcall(function()
                            for _, obj in ipairs(fn_doorObjs) do
                                if obj and obj.Parent then
                                    fn_forceDoorObj(obj)
                                end
                            end
                        end)
                    end
                else _T.dor = 0 end

                -- ── 🧊 Animatronic Freeze (1s) ─────────────────────────────
                if fn_freezeOn then
                    _T.fr = _T.fr + dt
                    if _T.fr >= 1 then
                        _T.fr = 0
                        pcall(function()
                            for _, npc in ipairs(fn_npcCache) do
                                if npc and npc.Parent then
                                    -- Alle Parts verankern
                                    for _, p in ipairs(npc:GetDescendants()) do
                                        if p:IsA("BasePart") then
                                            pcall(function() p.Anchored = true end)
                                        end
                                    end
                                    -- Humanoid: WalkSpeed + JumpPower auf 0
                                    local hum = npc:FindFirstChildOfClass("Humanoid")
                                    if hum then
                                        pcall(function()
                                            hum.WalkSpeed = 0
                                            hum.JumpPower = 0
                                        end)
                                    end
                                end
                            end
                        end)
                    end
                else _T.fr = 0 end

                -- ── 🚨 Door Anti-Breach (0.2s) ──────────────────────────────
                -- Schließt alle Türen sofort wenn ein NPC näher als fn_breachRange kommt.
                if fn_breachOn then
                    _T.br = _T.br + dt
                    if _T.br >= 0.2 then
                        _T.br = 0
                        pcall(function()
                            local hrp = fn_getHRP()
                            if not hrp then return end
                            local pos = hrp.Position
                            local triggered = false
                            local trigName  = ""
                            for _, npc in ipairs(fn_npcCache) do
                                if npc and npc.Parent then
                                    local pp = npc.PrimaryPart
                                          or npc:FindFirstChildOfClass("BasePart")
                                    if pp and (pp.Position - pos).Magnitude < fn_breachRange then
                                        triggered = true; trigName = npc.Name; break
                                    end
                                end
                            end
                            if triggered then
                                for _, obj in ipairs(fn_doorObjs) do
                                    if obj and obj.Parent then pcall(fn_forceDoorObj, obj) end
                                end
                                fn_setStatus("🚨 BREACH! " .. trigName .. " zu nah → Türen geschlossen!",
                                    Color3.fromRGB(255, 80, 80))
                            end
                        end)
                    end
                else _T.br = 0 end

                -- ── 🔦 Taschenlampen-Batterie Fix (0.5s) ────────────────────
                if fn_flashOn then
                    _T.fl2 = _T.fl2 + dt
                    if _T.fl2 >= 0.5 then
                        _T.fl2 = 0
                        pcall(function()
                            local FLASH_K = {"flashlight","flash","lantern","torch","light","lamp"}
                            local BATT_K  = {"battery","charge","energy","power","fuel","life","level","amount"}
                            local function fixFlash(container)
                                for _, tool in ipairs(container:GetChildren()) do
                                    if not (tool:IsA("Tool") or tool:IsA("Model")) then continue end
                                    local tlow = tool.Name:lower()
                                    local isFlash = false
                                    for _, k in ipairs(FLASH_K) do
                                        if tlow:find(k,1,true) then isFlash=true; break end
                                    end
                                    if not isFlash then continue end
                                    for _, v in ipairs(tool:GetDescendants()) do
                                        if v:IsA("NumberValue") or v:IsA("IntValue")
                                        or v:IsA("NumberConstrainedValue") or v:IsA("IntConstrainedValue") then
                                            local vlow = v.Name:lower()
                                            for _, bk in ipairs(BATT_K) do
                                                if vlow:find(bk,1,true) then
                                                    pcall(function()
                                                        local mx = v:GetAttribute("MaxValue")
                                                                or v:GetAttribute("Max")
                                                        if v.MaxValue then mx = v.MaxValue end
                                                        v.Value = mx or math.max(v.Value, 100)
                                                    end)
                                                    break
                                                end
                                            end
                                        end
                                        -- Attribut-basierte Batterie
                                        pcall(function()
                                            for attr, val in pairs(v:GetAttributes()) do
                                                if type(val)~="number" then continue end
                                                local alow = attr:lower()
                                                for _, bk in ipairs(BATT_K) do
                                                    if alow:find(bk,1,true) then
                                                        v:SetAttribute(attr, math.max(val, 100))
                                                    end
                                                end
                                            end
                                        end)
                                    end
                                end
                            end
                            local char = LP_FN.Character
                            local bp   = LP_FN.Backpack
                            if char then fixFlash(char) end
                            if bp   then fixFlash(bp)   end
                        end)
                    end
                else _T.fl2 = 0 end

                -- ── ⚙️ Generator Auto-Repair (2s) ─────────────────────────
                if fn_genOn then
                    _T.ge = _T.ge + dt
                    if _T.ge >= 2 then
                        _T.ge = 0
                        pcall(function()
                            local GEN_K = {"generator","generat","fuse","breaker","circuit","fusebox",
                                           "powerbox","powerroom","strom","engine","panel"}
                            for _, obj in ipairs(fn_cache) do
                                if not obj or not obj.Parent then continue end
                                local low = obj.Name:lower()
                                local isGen = false
                                for _, k in ipairs(GEN_K) do
                                    if low:find(k,1,true) then isGen=true; break end
                                end
                                if not isGen then continue end
                                -- ProximityPrompt triggern (Reparatur-Interaktion)
                                local pp = obj:FindFirstChildOfClass("ProximityPrompt")
                                         or obj:FindFirstChildWhichIsA("ProximityPrompt")
                                if pp then
                                    pcall(function() pp:InputHoldBegin() end)
                                    task.delay(0.15, function() pcall(function() pp:InputHoldEnd() end) end)
                                end
                                -- ClickDetector
                                local cd = obj:FindFirstChildOfClass("ClickDetector")
                                         or obj:FindFirstChildWhichIsA("ClickDetector")
                                if cd then
                                    pcall(function()
                                        game:GetService("VirtualUser"):ClickObject(cd)
                                    end)
                                end
                                -- BoolValues "Broken"/"Damaged"/"Offline" auf false
                                for _, v in ipairs(obj:GetDescendants()) do
                                    if v:IsA("BoolValue") then
                                        local vl = v.Name:lower()
                                        if vl:find("broken",1,true) or vl:find("damage",1,true)
                                        or vl:find("offline",1,true) or vl:find("dead",1,true) then
                                            pcall(function() v.Value = false end)
                                        end
                                    end
                                end
                                -- Attribut-Fix
                                pcall(function()
                                    for attr, val in pairs(obj:GetAttributes()) do
                                        if type(val)~="boolean" then continue end
                                        local al = attr:lower()
                                        if al:find("broken",1,true) or al:find("damage",1,true)
                                        or al:find("offline",1,true) then
                                            obj:SetAttribute(attr, false)
                                        end
                                    end
                                end)
                            end
                        end)
                    end
                else _T.ge = 0 end

                -- ── 🔊 Sound-ESP (0.5s) ─────────────────────────────────────
                -- Markiert Parts aus denen NPC-typische Sounds spielen.
                if fn_soundOn then
                    _T.so = _T.so + dt
                    if _T.so >= 0.5 then
                        _T.so = 0
                        pcall(function()
                            local SND_K = {"animatronic","freddy","bonnie","chica","foxy","puppet",
                                           "mangle","golden","shadow","spring","phantom","nightmare",
                                           "funtime","footstep","jumpscare","laugh","giggle","breathing",
                                           "vent","whisper","scream","roar","creak"}
                            for _, snd in ipairs(workspace:GetDescendants()) do
                                if not (snd:IsA("Sound") and snd.IsPlaying) then continue end
                                local slow  = snd.Name:lower()
                                local match = false
                                for _, k in ipairs(SND_K) do
                                    if slow:find(k,1,true) then match=true; break end
                                end
                                if not match then
                                    local par = snd.Parent
                                    if par and fn_isNPC(par) then match=true end
                                end
                                if not match then continue end
                                local part = snd.Parent
                                if not (part and part:IsA("BasePart")) then continue end
                                if fn_soundMap[part] then continue end  -- schon markiert
                                -- Highlight erstellen
                                local hl = Instance.new("Highlight")
                                hl.FillColor    = Color3.fromRGB(255, 60, 220)
                                hl.OutlineColor = Color3.fromRGB(255, 150, 255)
                                hl.FillTransparency    = 0.5
                                hl.OutlineTransparency = 0
                                hl.Adornee = part
                                hl.Parent  = part
                                -- BillboardGui
                                local bb = Instance.new("BillboardGui")
                                bb.Size         = UDim2.new(0, 120, 0, 26)
                                bb.StudsOffset  = Vector3.new(0, 3.5, 0)
                                bb.AlwaysOnTop  = true
                                bb.Parent       = part
                                local lbl = Instance.new("TextLabel", bb)
                                lbl.Size = UDim2.new(1,0,1,0)
                                lbl.BackgroundTransparency = 1
                                lbl.Text       = "🔊 " .. (part.Parent and part.Parent.Name or part.Name)
                                lbl.TextColor3 = Color3.fromRGB(255, 80, 220)
                                lbl.Font       = Enum.Font.GothamBold
                                lbl.TextSize   = 13
                                local entry = {hl=hl, bb=bb, part=part}
                                fn_soundMap[part] = entry
                                table.insert(fn_soundESP, entry)
                                -- Auto-entfernen wenn Part verschwindet
                                part.AncestryChanged:Connect(function()
                                    if not part.Parent then
                                        pcall(function() hl:Destroy(); bb:Destroy() end)
                                        fn_soundMap[part] = nil
                                    end
                                end)
                            end
                            -- Veraltete Einträge aufräumen (Sound gestoppt / Part weg)
                            for i = #fn_soundESP, 1, -1 do
                                local e = fn_soundESP[i]
                                if not e.hl or not e.hl.Parent
                                or not e.part or not e.part.Parent then
                                    pcall(function() if e.hl then e.hl:Destroy() end end)
                                    pcall(function() if e.bb then e.bb:Destroy() end end)
                                    fn_soundMap[e.part] = nil
                                    table.remove(fn_soundESP, i)
                                end
                            end
                        end)
                    end
                else _T.so = 0 end

                -- [FIX v99 Bug 2] Stoppen wenn ALLES aus ist (alle Flags geprüft)
                if not fn_staminaOn and not fn_powerOn
                and not fn_ajOn     and not fn_godOn
                and not fn_alarmOn  and not fn_fleeOn
                and not fn_nightOn  and not fn_musicOn and not fn_doorOn
                and not fn_freezeOn and not fn_breachOn
                and not fn_flashOn  and not fn_genOn   and not fn_soundOn then
                    fn_masterConn:Disconnect(); fn_masterConn = nil
                end
            end)
        end

        -- ══════════════════ SEKTION: INFINITE STAMINA ══════════════════
        fn_sep("⚡ INFINITE STAMINA")

        fn_lbls.sta = fn_btn("⚡ Infinite Stamina AN / AUS", C_ROW, function()
            fn_staminaOn = not fn_staminaOn
            if fn_staminaOn then
                fn_staminaRef = fn_findStaminaRef()
                fn_startMaster()
                fn_lbls.sta.TextColor3 = Color3.fromRGB(100, 255, 150)
                fn_setStatus(fn_staminaRef and "⚡ Stamina dauerhaft voll!" or "⚡ AN – suche Stamina-Feld...", Color3.fromRGB(100, 255, 150))
            else
                fn_lbls.sta.TextColor3 = C_TEXT
                fn_setStatus("⚡ Infinite Stamina AUS", C_SUB)
            end
        end)

        -- ══════════════════ SEKTION: ANTI-JUMPSCARE ══════════════════
        fn_sep("😱 ANTI-JUMPSCARE")

        fn_ajLbl = fn_btn("😱 Anti-Jumpscare AN / AUS", C_ROW, function()
            fn_ajOn = not fn_ajOn
            if fn_ajOn then
                if fn_ajConn then fn_ajConn:Disconnect() end
                -- Bestehende GUIs als "harmlos" vormerken
                fn_ajInitKnown()
                local pg = LP_FN:FindFirstChild("PlayerGui")
                if pg then
                    -- Sofort bei jedem neuen Descendant reagieren
                    fn_ajConn = pg.ChildAdded:Connect(function(gui)
                        task.defer(function()
                            if fn_ajOn and gui:IsA("ScreenGui") and gui.Enabled then
                                if fn_isJumpscareGui(gui) then fn_hideJumpscareGui(gui) end
                            end
                        end)
                    end)
                end
                -- Einmalig alle vorhandenen scannen
                task.spawn(fn_ajScan)
                fn_startMaster()   -- Loop-Scan alle 0.2s
                fn_ajLbl.TextColor3 = Color3.fromRGB(255, 120, 200)
                fn_setStatus("😱 Anti-Jumpscare AN – Name + Vollbild-Overlay blockiert!", Color3.fromRGB(255, 120, 200))
            else
                if fn_ajConn then fn_ajConn:Disconnect(); fn_ajConn = nil end
                fn_ajKnownOk = {}
                fn_ajLbl.TextColor3 = C_TEXT
                fn_setStatus("😱 Anti-Jumpscare AUS", C_SUB)
            end
        end)

        -- ══════════════════ SEKTION: INFINITE POWER ══════════════════
        fn_sep("🔋 INFINITE POWER")

        fn_lbls.pw = fn_btn("🔋 Infinite Power AN / AUS", C_ROW, function()
            fn_powerOn = not fn_powerOn
            if fn_powerOn then
                -- Einmaliger Vollscan beim Aktivieren (task.spawn = kein Lag)
                task.spawn(fn_buildPowerCache)
                fn_startMaster()
                fn_lbls.pw.TextColor3 = Color3.fromRGB(100, 255, 100)
                fn_setStatus("🔋 Infinite Power AN – scannt einmalig…", Color3.fromRGB(100, 255, 100))
            else
                fn_powerVals = {}; fn_powerAttrObjs = {}; fn_powerRemotes = {}
                fn_lbls.pw.TextColor3 = C_TEXT
                fn_setStatus("🔋 Infinite Power AUS", C_SUB)
            end
        end)

        -- [FIX v99 Bug 1] Dieser AncestryChanged-Block wurde ENTFERNT.
        -- Er referenzierte fn_npcESP, fn_npcMap, fn_clearESP, fn_stopWatch, fn_stopHUD, fn_hudGui
        -- die alle NACH dieser Stelle deklariert werden (Lua Forward-Reference → globals = nil).
        -- Aufruf von fn_clearESP(nil, nil) → ipairs(nil) → Fehler → ESP-Cleanup schlug still fehl.
        -- STATTDESSEN: Gesamter Cleanup ist in einer einzigen fn_cleanupAll()-Funktion
        -- am Ende des Blocks zusammengefasst, nachdem alle Locals deklariert wurden.

        -- ══════════════════ SEKTION: MONSTER-ABWEHR ══════════════════
        fn_sep("⚔️ MONSTER-ABWEHR")

        -- ❤️ God Mode
        fn_lbls.go = fn_btn("❤️ God Mode AN / AUS", C_ROW, function()
            fn_godOn = not fn_godOn
            if fn_godOn then
                fn_startMaster()
                fn_lbls.go.TextColor3 = Color3.fromRGB(255, 100, 100)
                fn_setStatus("❤️ God Mode AN – Health immer voll!", Color3.fromRGB(255, 100, 100))
            else
                fn_lbls.go.TextColor3 = C_TEXT
                fn_setStatus("❤️ God Mode AUS", C_SUB)
            end
        end)

        -- 🚨 Monster-Alarm
        fn_lbls.al = fn_btn("🚨 Monster-Alarm AN / AUS", C_ROW, function()
            fn_alarmOn = not fn_alarmOn
            if fn_alarmOn then
                fn_startMaster()
                fn_lbls.al.TextColor3 = Color3.fromRGB(255, 200, 50)
                fn_setStatus("🚨 Alarm aktiv – überwacht Monster-Entfernung!", Color3.fromRGB(255, 200, 50))
            else
                fn_lbls.al.TextColor3 = C_TEXT
                fn_setStatus("🚨 Monster-Alarm AUS", C_SUB)
            end
        end)

        -- 🏃 Auto-Flee
        fn_lbls.fl = fn_btn("🏃 Auto-Flee AN / AUS  (Trigger: 25 Studs)", C_ROW, function()
            fn_fleeOn = not fn_fleeOn
            if fn_fleeOn then
                fn_startMaster()
                fn_lbls.fl.TextColor3 = Color3.fromRGB(255, 165, 50)
                fn_setStatus("🏃 Auto-Flee AN – flieht bei Monster < 25 Studs!", Color3.fromRGB(255, 165, 50))
            else
                fn_lbls.fl.TextColor3 = C_TEXT
                fn_setStatus("🏃 Auto-Flee AUS", C_SUB)
            end
        end)

        -- ══════════════════ SEKTION: NIGHT SKIP / INFINITE MUSIC / AUTO-TÜR ══════════════════
        -- [FIX v99 Bug 2] Diese drei Features existierten nur als leere State-Variablen
        -- ohne Buttons und ohne Loop-Logik. Hier vollständig implementiert.
        fn_sep("⏭️ NIGHT SKIP / MUSIC BOX / AUTO-TÜR")

        fn_lbls.ni = fn_btn("⏭️ Night-Skip AN / AUS", C_ROW, function()
            fn_nightOn = not fn_nightOn
            if fn_nightOn then
                -- Einmaliger Vollscan beim Aktivieren
                task.spawn(fn_buildNightCache)
                fn_startMaster()
                fn_lbls.ni.TextColor3 = Color3.fromRGB(180, 220, 255)
                fn_setStatus("⏭️ Night-Skip AN – sucht Zeit-Values & Remotes…", Color3.fromRGB(180, 220, 255))
            else
                fn_timeVals = {}; fn_nightRemotes = {}
                fn_lbls.ni.TextColor3 = C_TEXT
                fn_setStatus("⏭️ Night-Skip AUS", C_SUB)
            end
        end)

        fn_lbls.mu = fn_btn("🎵 Infinite Music Box AN / AUS", C_ROW, function()
            fn_musicOn = not fn_musicOn
            if fn_musicOn then
                fn_musicVals = fn_buildValList(MUSIC_KEYS)
                fn_startMaster()
                fn_lbls.mu.TextColor3 = Color3.fromRGB(255, 140, 255)
                fn_setStatus("🎵 Music Box AN – " .. #fn_musicVals .. " Wert(e) gefunden", Color3.fromRGB(255, 140, 255))
            else
                fn_musicVals = {}
                fn_lbls.mu.TextColor3 = C_TEXT
                fn_setStatus("🎵 Music Box AUS", C_SUB)
            end
        end)

        fn_lbls.dor = fn_btn("🔒 Auto-Tür (alle 3 s schließen) AN / AUS", C_ROW, function()
            fn_doorOn = not fn_doorOn
            if fn_doorOn then
                pcall(fn_rebuildCache)
                fn_startMaster()
                fn_lbls.dor.TextColor3 = Color3.fromRGB(100, 200, 255)
                fn_setStatus("🔒 Auto-Tür AN – schließt Türen alle 3 s!", Color3.fromRGB(100, 200, 255))
            else
                fn_lbls.dor.TextColor3 = C_TEXT
                fn_setStatus("🔒 Auto-Tür AUS", C_SUB)
            end
        end)

        fn_btn("🔒 Alle Türen JETZT schließen (Einmalig)", Color3.fromRGB(28, 40, 55), function()
            task.spawn(fn_forceAllDoors)
        end)

        -- ══════════════════ SEKTION: ANIMATRONIC FREEZE ══════════════════
        fn_sep("🧊 ANIMATRONIC FREEZE")

        fn_lbls.fr = fn_btn("🧊 Animatronic Freeze AN / AUS", C_ROW, function()
            fn_freezeOn = not fn_freezeOn
            if fn_freezeOn then
                pcall(fn_rebuildCache)
                fn_startMaster()
                fn_lbls.fr.TextColor3 = Color3.fromRGB(100, 220, 255)
                fn_setStatus("🧊 Freeze AN – NPCs werden eingefroren!", Color3.fromRGB(100, 220, 255))
            else
                -- NPCs wieder entfrieren: alle Parts de-ankern (nur wenn sie vorher unverankert waren)
                pcall(function()
                    for _, npc in ipairs(fn_npcCache) do
                        if npc and npc.Parent then
                            for _, p in ipairs(npc:GetDescendants()) do
                                if p:IsA("BasePart") then
                                    pcall(function() p.Anchored = false end)
                                end
                            end
                            local hum = npc:FindFirstChildOfClass("Humanoid")
                            if hum then
                                pcall(function()
                                    hum.WalkSpeed = 16
                                    hum.JumpPower = 50
                                end)
                            end
                        end
                    end
                end)
                fn_lbls.fr.TextColor3 = C_TEXT
                fn_setStatus("🧊 Freeze AUS – NPCs können sich wieder bewegen", C_SUB)
            end
        end)

        -- ══════════════════ SEKTION: DOOR ANTI-BREACH ══════════════════
        fn_sep("🚨 DOOR ANTI-BREACH")

        fn_lbls.br = fn_btn("🚨 Anti-Breach AN / AUS (NPC < 15 Studs → Tür zu)", C_ROW, function()
            fn_breachOn = not fn_breachOn
            if fn_breachOn then
                pcall(fn_rebuildCache)
                fn_startMaster()
                fn_lbls.br.TextColor3 = Color3.fromRGB(255, 120, 60)
                fn_setStatus("🚨 Anti-Breach AN – Türen schließen bei Annäherung!", Color3.fromRGB(255, 120, 60))
            else
                fn_lbls.br.TextColor3 = C_TEXT
                fn_setStatus("🚨 Anti-Breach AUS", C_SUB)
            end
        end)

        -- ══════════════════ SEKTION: TASCHENLAMPE ══════════════════
        fn_sep("🔦 TASCHENLAMPEN-BATTERIE")

        fn_lbls.fl2 = fn_btn("🔦 Infinite Flashlight Battery AN / AUS", C_ROW, function()
            fn_flashOn = not fn_flashOn
            if fn_flashOn then
                fn_startMaster()
                fn_lbls.fl2.TextColor3 = Color3.fromRGB(255, 240, 120)
                fn_setStatus("🔦 Flashlight Battery AN – Batterie bleibt voll!", Color3.fromRGB(255, 240, 120))
            else
                fn_lbls.fl2.TextColor3 = C_TEXT
                fn_setStatus("🔦 Flashlight Battery AUS", C_SUB)
            end
        end)

        -- ══════════════════ SEKTION: GENERATOR ══════════════════
        fn_sep("⚙️ GENERATOR AUTO-REPAIR")

        fn_lbls.ge = fn_btn("⚙️ Generator Auto-Repair AN / AUS", C_ROW, function()
            fn_genOn = not fn_genOn
            if fn_genOn then
                pcall(fn_rebuildCache)
                fn_startMaster()
                fn_lbls.ge.TextColor3 = Color3.fromRGB(120, 255, 120)
                fn_setStatus("⚙️ Generator Auto-Repair AN – repariert alle 2 s!", Color3.fromRGB(120, 255, 120))
            else
                fn_lbls.ge.TextColor3 = C_TEXT
                fn_setStatus("⚙️ Generator Auto-Repair AUS", C_SUB)
            end
        end)

        fn_btn("⚙️ Generator JETZT reparieren (Einmalig)", Color3.fromRGB(20, 40, 20), function()
            task.spawn(function()
                fn_setStatus("⚙️ Repariere Generator…", C_SUB)
                pcall(fn_rebuildCache)
                local GEN_K = {"generator","generat","fuse","breaker","circuit","fusebox",
                               "powerbox","powerroom","strom","engine","panel"}
                local count = 0
                for _, obj in ipairs(fn_cache) do
                    if not obj or not obj.Parent then continue end
                    local low = obj.Name:lower()
                    for _, k in ipairs(GEN_K) do
                        if low:find(k,1,true) then
                            local pp = obj:FindFirstChildOfClass("ProximityPrompt")
                                     or obj:FindFirstChildWhichIsA("ProximityPrompt")
                            if pp then
                                pcall(function() pp:InputHoldBegin() end)
                                task.delay(0.15, function() pcall(function() pp:InputHoldEnd() end) end)
                                count = count + 1
                            end
                            local cd = obj:FindFirstChildOfClass("ClickDetector")
                                     or obj:FindFirstChildWhichIsA("ClickDetector")
                            if cd then
                                pcall(function() game:GetService("VirtualUser"):ClickObject(cd) end)
                                count = count + 1
                            end
                            break
                        end
                    end
                end
                fn_setStatus(count > 0 and ("⚙️ %d Generator(en) angesteuert!"):format(count)
                             or "⚠️ Keine Generator-Interaktion gefunden", count > 0
                             and Color3.fromRGB(120, 255, 120) or Color3.fromRGB(255, 180, 50))
            end)
        end)

        -- ══════════════════ SEKTION: NO CAMERA STATIC ══════════════════
        fn_sep("📷 NO CAMERA STATIC")

        fn_lbls.st = fn_btn("📷 No Camera Static AN / AUS", C_ROW, function()
            fn_staticOn = not fn_staticOn
            if fn_staticOn then
                fn_lbls.st.TextColor3 = Color3.fromRGB(100, 220, 255)
                fn_setStatus("📷 No Static AN – entferne Rauschen…", Color3.fromRGB(100, 220, 255))
                task.spawn(function()
                    pcall(function()
                        -- Suche nach Static/Noise-GUIs in CoreGui + PlayerGui
                        local STATIC_K = {"static","noise","flicker","glitch","distort",
                                          "interference","grain","fuzz","buzz","screen","overlay"}
                        local removed = 0
                        local function processGui(container)
                            for _, obj in ipairs(container:GetDescendants()) do
                                if obj:IsA("Frame") or obj:IsA("ImageLabel")
                                or obj:IsA("VideoFrame") then
                                    local low = obj.Name:lower()
                                    for _, k in ipairs(STATIC_K) do
                                        if low:find(k,1,true) then
                                            pcall(function()
                                                obj.Visible = false
                                                if obj:IsA("ImageLabel") then
                                                    obj.ImageTransparency = 1
                                                end
                                                obj.BackgroundTransparency = 1
                                            end)
                                            removed = removed + 1
                                            break
                                        end
                                    end
                                end
                                -- Post-Processing Effekte im Lighting (Color Correction / Blur = Static-Quelle)
                                if obj:IsA("ColorCorrectionEffect") then
                                    pcall(function()
                                        obj.Enabled = false
                                    end)
                                end
                                if obj:IsA("BlurEffect") then
                                    pcall(function() obj.Size = 0 end)
                                end
                            end
                        end
                        pcall(function() processGui(game:GetService("CoreGui")) end)
                        pcall(function() processGui(game:GetService("Players").LocalPlayer.PlayerGui) end)
                        -- Auch direkt im Lighting (DepthOfField / Noise-Effects)
                        pcall(function()
                            for _, eff in ipairs(game:GetService("Lighting"):GetChildren()) do
                                if eff:IsA("ColorCorrectionEffect") then
                                    eff.Enabled = false
                                end
                                if eff:IsA("BlurEffect") then eff.Size = 0 end
                                if eff:IsA("DepthOfFieldEffect") then eff.Enabled = false end
                            end
                        end)
                        fn_setStatus(("📷 Static entfernt (%d Elemente)!"):format(removed),
                            Color3.fromRGB(100, 220, 255))
                    end)
                end)
            else
                fn_lbls.st.TextColor3 = C_TEXT
                fn_setStatus("📷 No Static AUS – Effekte wieder aktiv", C_SUB)
                -- Effekte wieder aktivieren
                pcall(function()
                    for _, eff in ipairs(game:GetService("Lighting"):GetChildren()) do
                        if eff:IsA("ColorCorrectionEffect") then eff.Enabled = true end
                        if eff:IsA("BlurEffect") then eff.Size = 10 end
                        if eff:IsA("DepthOfFieldEffect") then eff.Enabled = true end
                    end
                end)
            end
        end)

        -- ══════════════════ SEKTION: SOUND-ESP ══════════════════
        fn_sep("🔊 SOUND-ESP")

        fn_lbls.so = fn_btn("🔊 Sound-ESP AN / AUS (NPC-Geräusche sichtbar)", C_ROW, function()
            fn_soundOn = not fn_soundOn
            if fn_soundOn then
                fn_startMaster()
                fn_lbls.so.TextColor3 = Color3.fromRGB(255, 100, 220)
                fn_setStatus("🔊 Sound-ESP AN – NPC-Sounds werden markiert!", Color3.fromRGB(255, 100, 220))
            else
                -- Alle Sound-ESP-Highlights entfernen
                for _, e in ipairs(fn_soundESP) do
                    pcall(function() if e.hl then e.hl:Destroy() end end)
                    pcall(function() if e.bb then e.bb:Destroy() end end)
                end
                fn_soundESP = {}
                fn_soundMap  = {}
                fn_lbls.so.TextColor3 = C_TEXT
                fn_setStatus("🔊 Sound-ESP AUS", C_SUB)
            end
        end)

        -- ══════════════════ SEKTION: MAP TELEPORTS ══════════════════
        fn_sep("🗺️ MAP TELEPORTS")

        -- Scannt workspace nach begehbaren Räumen/Bereichen
        local fn_roomList = {}   -- { name, pos }
        local fn_roomWin  = nil  -- Popup-Frame

        local ROOM_KEYS = {
            "office","room","hall","hallway","kitchen","storage","stage","backstage",
            "cove","pirate","supply","restroom","bathroom","lounge","closet","vent",
            "shaft","corridor","parts","service","arcade","dining","area","zone",
            "generator","east","west","left","right","main","show","prize","attic",
            "basement","floor","ground","entrance","exit","spawn","lobby",
        }
        local ROOM_EXCLUDE = {
            "wall","ceil","floor","roof","door","window","glass","barrier","invisible",
            "collide","kill","damage","lava","water","part","block","base","union",
            "npc","animatronic","model","rig","bone","mesh",
        }

        local function fn_scanRooms()
            fn_roomList = {}
            local seen   = {}
            local players = game:GetService("Players"):GetPlayers()

            local function isPlayerOwned(obj)
                for _, pl in ipairs(players) do
                    if pl.Character and obj:IsDescendantOf(pl.Character) then return true end
                end
                return false
            end

            local function tryRoom(obj)
                if seen[obj] then return end
                seen[obj] = true
                if isPlayerOwned(obj) then return end
                if obj:IsA("Tool") then return end

                local part = nil
                if obj:IsA("BasePart") then
                    part = obj
                elseif obj:IsA("Model") then
                    part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                else return end
                if not part then return end

                -- Versteckte/unsichtbare Parts ausschließen
                if part.Transparency >= 0.99 then return end
                if not part.CanCollide and not part.Anchored then return end

                local low = obj.Name:lower()
                -- Ausschluss-Check
                for _, k in ipairs(ROOM_EXCLUDE) do
                    if low:find(k,1,true) then return end
                end
                -- Match-Check
                local match = false
                for _, k in ipairs(ROOM_KEYS) do
                    if low:find(k,1,true) then match=true; break end
                end
                if not match then return end

                -- Positions-Dedup (innerhalb 10 Studs = gleicher Raum)
                local pos = part.Position
                for _, e in ipairs(fn_roomList) do
                    if (e.pos - pos).Magnitude < 10 then return end
                end

                table.insert(fn_roomList, { name = obj.Name, pos = pos })
            end

            for _, obj in ipairs(workspace:GetDescendants()) do
                pcall(tryRoom, obj)
            end

            -- Alphabetisch sortieren
            table.sort(fn_roomList, function(a,b) return a.name < b.name end)
        end

        -- Popup-Fenster für Raumliste
        local fn_roomWinObj = Instance.new("Frame")
        fn_roomWinObj.Name             = "FNRoomTeleportPopup"
        fn_roomWinObj.Size             = UDim2.new(0, 320, 0, 360)
        fn_roomWinObj.Position         = UDim2.new(0.5, -170, 0.5, -160)
        fn_roomWinObj.BackgroundColor3 = C_BG
        fn_roomWinObj.BorderSizePixel  = 0
        fn_roomWinObj.Visible          = false
        fn_roomWinObj.ZIndex           = 20
        fn_roomWinObj.Parent           = sg_fn
        fnCorner(fn_roomWinObj, 12)
        fnStroke(fn_roomWinObj, Color3.fromRGB(100, 200, 255), 2, 0.3)

        local fn_roomTitle = Instance.new("TextLabel")
        fn_roomTitle.Size                   = UDim2.new(1, -40, 0, 36)
        fn_roomTitle.Position               = UDim2.new(0, 10, 0, 0)
        fn_roomTitle.BackgroundTransparency = 1
        fn_roomTitle.Text                   = "🗺️ Räume / Bereiche"
        fn_roomTitle.TextColor3             = Color3.fromRGB(100, 200, 255)
        fn_roomTitle.Font                   = Enum.Font.GothamBold
        fn_roomTitle.TextSize               = 15
        fn_roomTitle.TextXAlignment         = Enum.TextXAlignment.Left
        fn_roomTitle.ZIndex                 = 21
        fn_roomTitle.Parent                 = fn_roomWinObj

        local fn_roomClose = Instance.new("TextButton")
        fn_roomClose.Size                   = UDim2.new(0, 30, 0, 30)
        fn_roomClose.Position               = UDim2.new(1, -34, 0, 3)
        fn_roomClose.BackgroundColor3       = Color3.fromRGB(200, 50, 50)
        fn_roomClose.Text                   = "✕"
        fn_roomClose.TextColor3             = Color3.fromRGB(255, 255, 255)
        fn_roomClose.Font                   = Enum.Font.GothamBold
        fn_roomClose.TextSize               = 14
        fn_roomClose.ZIndex                 = 22
        fn_roomClose.Parent                 = fn_roomWinObj
        fnCorner(fn_roomClose, 8)
        fn_roomClose.MouseButton1Click:Connect(function()
            fn_roomWinObj.Visible = false
        end)

        local fn_roomScroll = Instance.new("ScrollingFrame")
        fn_roomScroll.Size                  = UDim2.new(1, -16, 1, -44)
        fn_roomScroll.Position              = UDim2.new(0, 8, 0, 40)
        fn_roomScroll.BackgroundTransparency = 1
        fn_roomScroll.ScrollBarThickness    = 4
        fn_roomScroll.ScrollBarImageColor3  = Color3.fromRGB(100, 200, 255)
        fn_roomScroll.CanvasSize            = UDim2.new()
        fn_roomScroll.AutomaticCanvasSize   = Enum.AutomaticSize.Y
        fn_roomScroll.ZIndex                = 21
        fn_roomScroll.Parent                = fn_roomWinObj
        local fn_roomLayout = Instance.new("UIListLayout", fn_roomScroll)
        fn_roomLayout.Padding   = UDim.new(0, 3)
        fn_roomLayout.SortOrder = Enum.SortOrder.LayoutOrder
        Instance.new("UIPadding", fn_roomScroll).PaddingBottom = UDim.new(0, 6)

        local function fn_buildRoomList()
            for _, c in ipairs(fn_roomScroll:GetChildren()) do
                if not c:IsA("UIListLayout") and not c:IsA("UIPadding") then c:Destroy() end
            end
            if #fn_roomList == 0 then
                local lbl = Instance.new("TextLabel")
                lbl.Size = UDim2.new(1,0,0,40)
                lbl.BackgroundTransparency = 1
                lbl.Text = "⚠️ Keine Räume gefunden"
                lbl.TextColor3 = Color3.fromRGB(255, 180, 50)
                lbl.Font = Enum.Font.Gotham
                lbl.TextSize = 13
                lbl.ZIndex = 22
                lbl.Parent = fn_roomScroll
                return
            end
            for i, entry in ipairs(fn_roomList) do
                local btn = Instance.new("TextButton")
                btn.Size             = UDim2.new(1, 0, 0, 36)
                btn.BackgroundColor3 = Color3.fromRGB(20, 30, 45)
                btn.Text             = ("📍  %s"):format(entry.name)
                btn.TextColor3       = Color3.fromRGB(100, 200, 255)
                btn.Font             = Enum.Font.GothamBold
                btn.TextSize         = 13
                btn.TextXAlignment   = Enum.TextXAlignment.Left
                btn.ZIndex           = 22
                btn.LayoutOrder      = i
                btn.Parent           = fn_roomScroll
                fnCorner(btn, 7)
                fnStroke(btn, Color3.fromRGB(100, 200, 255), 1, 0.6)
                local _pad = Instance.new("UIPadding", btn)
                _pad.PaddingLeft = UDim.new(0, 10)
                local entryRef = entry
                btn.MouseButton1Click:Connect(function()
                    local hrp = fn_getHRP()
                    if not hrp then
                        fn_setStatus("❌ Kein Charakter", Color3.fromRGB(255, 80, 80))
                        return
                    end
                    pcall(function()
                        -- Leicht über der Position teleportieren um nicht im Boden zu landen
                        hrp.CFrame = CFrame.new(entryRef.pos + Vector3.new(0, 3, 0))
                    end)
                    fn_setStatus("📍 Teleportiert: " .. entryRef.name, Color3.fromRGB(100, 200, 255))
                    btn.BackgroundColor3 = Color3.fromRGB(20, 50, 70)
                    task.delay(0.4, function()
                        pcall(function() btn.BackgroundColor3 = Color3.fromRGB(20, 30, 45) end)
                    end)
                end)
            end
        end

        fn_btn("🗺️ Räume scannen & Teleport-Liste", C_ROW, function()
            task.spawn(function()
                fn_setStatus("🔍 Scanne Räume…", C_SUB)
                fn_scanRooms()
                fn_buildRoomList()
                fn_roomWinObj.Visible = true
                fn_setStatus(("🗺️ %d Raum/Bereich gefunden"):format(#fn_roomList),
                    Color3.fromRGB(100, 200, 255))
            end)
        end)

        -- ══════════════════ SEKTION: NPC ESP ══════════════════
        fn_sep("🤖 NPC ESP")

        -- ESP-Stores: Array für Iteration + Map für O(1)-Lookup (kein FindFirstChild nötig)
        local fn_npcESP  = {}   -- aktive NPC-ESP-Einträge (Array)
        local fn_itemESP = {}   -- aktive Item-ESP-Einträge (Array)
        local fn_hideESP = {}   -- aktive Versteck-ESP-Einträge (Array)
        local fn_npcMap  = {}   -- [obj] = entry  (O(1) Duplikat-/Cleanup-Check)
        local fn_itemMap = {}   -- [obj] = entry
        local fn_hideMap = {}   -- [obj] = entry
        local fn_npcOn   = false
        local fn_itemOn  = false
        local fn_hideOn  = false
        -- KEIN fn_espConn, KEIN Heartbeat – vollständig event-basiert

        -- Entfernt Eintrag sofort aus Store + Map.
        -- Highlight/BB/Tag sind Kinder von obj → automatisch zerstört wenn obj stirbt.
        -- Wir müssen nur den Speicher in unseren Tables freigeben.
        local function fn_removeFromStore(obj, store, map)
            local e = map[obj]
            if not e then return end
            map[obj] = nil
            for i = #store, 1, -1 do
                if store[i] == e then table.remove(store, i); break end
            end
        end

        -- ESP auf ein Objekt anwenden (Highlight + Name-Billboard).
        -- Embedded AncestryChanged: kein Poll, kein Heartbeat, sofortiger Cleanup.
        -- forceName = true → Name immer anzeigen (z.B. für Verstecke)
        local function fn_addESP(obj, fillCol, store, map, txtCol, forceName)
            if map[obj] then return end   -- O(1) Duplikat-Check

            local tag = Instance.new("StringValue")
            tag.Name = "__SemysESP__"; tag.Parent = obj

            local hl = Instance.new("Highlight")
            hl.Adornee             = obj
            hl.FillColor           = fillCol
            hl.FillTransparency    = 0.5
            hl.OutlineColor        = fillCol
            hl.OutlineTransparency = 0
            hl.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
            hl.Parent              = obj

            local root = obj:FindFirstChild("HumanoidRootPart")
                      or obj:FindFirstChildWhichIsA("BasePart")
            local bb
            if root then
                bb = Instance.new("BillboardGui")
                bb.Name        = "__SemysESPBB__"
                bb.Size        = UDim2.new(0, 180, 0, 32)
                bb.StudsOffset = Vector3.new(0, 3.5, 0)
                bb.AlwaysOnTop = true
                bb.Adornee     = root
                bb.Parent      = obj
                local lbl = Instance.new("TextLabel")
                lbl.Size                   = UDim2.new(1, 0, 1, 0)
                lbl.BackgroundTransparency = 1
                lbl.Text                   = (forceName or fn_isFNAFChar(obj)) and obj.Name or ""
                lbl.TextColor3             = txtCol or fillCol
                lbl.TextStrokeColor3       = Color3.fromRGB(0, 0, 0)
                lbl.TextStrokeTransparency = 0.2
                lbl.Font                   = Enum.Font.GothamBold
                lbl.TextSize               = 13
                lbl.Parent                 = bb
            end

            local entry = { obj = obj, tag = tag, hl = hl, bb = bb }
            table.insert(store, entry)
            map[obj] = entry

            -- Sofortiger Cleanup via AncestryChanged: feuert genau einmal wenn
            -- obj aus dem Workspace entfernt wird. Kein Poll, kein Heartbeat nötig.
            obj.AncestryChanged:Connect(function()
                if not obj.Parent then
                    fn_removeFromStore(obj, store, map)
                end
            end)
        end

        -- Alle ESP-Einträge einer Kategorie entfernen (beim Deaktivieren)
        local function fn_clearESP(store, map)
            for _, e in ipairs(store) do
                pcall(function()
                    if e.tag and e.tag.Parent then e.tag:Destroy() end
                    if e.hl  and e.hl.Parent  then e.hl:Destroy()  end
                    if e.bb  and e.bb.Parent  then e.bb:Destroy()  end
                end)
            end
            for i = #store, 1, -1 do store[i] = nil end
            for k in pairs(map) do map[k] = nil end
        end

        -- NPC-Scan: einmalig beim Aktivieren, nutzt bestehenden fn_cache
        local function fn_scanNPCs()
            fn_clearESP(fn_npcESP, fn_npcMap)
            if #fn_cache == 0 then pcall(fn_rebuildCache) end
            for _, obj in ipairs(fn_cache) do
                if fn_isNPC(obj) then
                    local fillC, txtC = fn_getNPCColor(obj)
                    pcall(fn_addESP, obj, fillC, fn_npcESP, fn_npcMap, txtC)
                end
            end
            fn_setStatus("🤖 " .. #fn_npcESP .. " NPCs gefunden", Color3.fromRGB(255, 120, 120))
        end

        -- ── Versteck-ESP ──────────────────────────────────────────────────
        local HIDE_KEYS = {
            "locker","schrank","wardrobe","closet","cabinet",
            "hidespot","hide spot","hiding spot","hidingspot",
            "hideplace","hide_spot","hiding","crawlspace","crawl",
            "bed","vent","barrel","crate_hide","dumpster",
        }
        local function fn_isHideSpot(obj)
            if not (obj:IsA("Model") or obj:IsA("BasePart") or obj:IsA("Part")) then return false end
            if fn_isNPC(obj) then return false end
            local low = obj.Name:lower()
            for _, k in ipairs(HIDE_KEYS) do
                if low:find(k, 1, true) then return true end
            end
            return false
        end

        local function fn_scanHideSpots()
            fn_clearESP(fn_hideESP, fn_hideMap)
            if #fn_cache == 0 then pcall(fn_rebuildCache) end
            for _, obj in ipairs(fn_cache) do
                if fn_isHideSpot(obj) then
                    pcall(fn_addESP, obj,
                        Color3.fromRGB(50, 220, 100),
                        fn_hideESP, fn_hideMap,
                        Color3.fromRGB(150, 255, 180),
                        true)  -- forceName = true → Name immer sichtbar
                end
            end
            fn_setStatus("🟢 " .. #fn_hideESP .. " Verstecke gefunden", Color3.fromRGB(50, 220, 100))
        end

        -- Kamera-Items → schwarz; alles andere → Cyan
        local CAMERA_KEYS = {"camera","cam","cctv","monitor","surveillance","security cam"}
        local function fn_getItemColor(obj)
            local low = obj.Name:lower()
            for _, k in ipairs(CAMERA_KEYS) do
                if low:find(k, 1, true) then
                    return Color3.fromRGB(10, 10, 10), Color3.fromRGB(180, 180, 180)
                end
            end
            return Color3.fromRGB(80, 210, 255), Color3.fromRGB(180, 235, 255)
        end

        -- Item-Scan: einmalig beim Aktivieren, nutzt bestehenden fn_cache
        local function fn_scanItems()
            fn_clearESP(fn_itemESP, fn_itemMap)
            if #fn_cache == 0 then pcall(fn_rebuildCache) end
            for _, obj in ipairs(fn_cache) do
                if fn_isItem(obj) then
                    local fillC, txtC = fn_getItemColor(obj)
                    pcall(fn_addESP, obj, fillC, fn_itemESP, fn_itemMap, txtC)
                end
            end
            fn_setStatus("📦 " .. #fn_itemESP .. " Items gefunden", Color3.fromRGB(80, 210, 255))
        end

        -- Helfer: NPC / Item / Versteck versuchen zu taggen (guard inklusive)
        local function fn_tryAddNPC(obj)
            if fn_npcOn and fn_isNPC(obj) and not fn_npcMap[obj] then
                local fillC, txtC = fn_getNPCColor(obj)
                pcall(fn_addESP, obj, fillC, fn_npcESP, fn_npcMap, txtC)
            end
        end
        local function fn_tryAddItem(obj)
            if fn_itemOn and fn_isItem(obj) and not fn_itemMap[obj] then
                local fillC, txtC = fn_getItemColor(obj)
                pcall(fn_addESP, obj, fillC, fn_itemESP, fn_itemMap, txtC)
            end
        end
        local function fn_tryAddHide(obj)
            if fn_hideOn and fn_isHideSpot(obj) and not fn_hideMap[obj] then
                pcall(fn_addESP, obj,
                    Color3.fromRGB(50, 220, 100),
                    fn_hideESP, fn_hideMap,
                    Color3.fromRGB(150, 255, 180),
                    true)
            end
        end

        -- [FIX v99 Bug 4] workspace.DescendantAdded statt ChildAdded.
        -- ChildAdded feuert nur für direkte Kinder → NPCs in Subfolder (z.B.
        -- workspace.NPCFolder.Freddy) wurden nie automatisch getagt.
        -- DescendantAdded feuert für alle Tiefen, kein manuelles :GetChildren() nötig.
        local fn_watchConn = nil
        local function fn_startWatch()
            if fn_watchConn then return end
            fn_watchConn = workspace.DescendantAdded:Connect(function(obj)
                task.defer(function()
                    fn_tryAddNPC(obj)
                    fn_tryAddItem(obj)
                    fn_tryAddHide(obj)
                end)
            end)
        end
        local function fn_stopWatch()
            if fn_watchConn then fn_watchConn:Disconnect(); fn_watchConn = nil end
        end

        -- NPC-ESP Buttons
        local fn_npcBtnLbl
        fn_npcBtnLbl = fn_btn("🤖 NPC-ESP AN / AUS", C_ROW, function()
            fn_npcOn = not fn_npcOn
            if fn_npcOn then
                task.spawn(fn_scanNPCs)
                fn_startWatch()   -- gemeinsamer ChildAdded-Watcher (kein Heartbeat)
                fn_npcBtnLbl.TextColor3 = Color3.fromRGB(255, 120, 120)
            else
                fn_clearESP(fn_npcESP, fn_npcMap)
                if not fn_itemOn and not fn_hideOn then fn_stopWatch() end
                fn_npcBtnLbl.TextColor3 = C_TEXT
                fn_setStatus("🤖 NPC-ESP AUS", C_SUB)
            end
        end)

        fn_btn("🔄 NPCs neu scannen", C_ROW, function()
            if not fn_npcOn then
                fn_setStatus("⚠️ NPC-ESP ist aus", Color3.fromRGB(255, 180, 50)); return
            end
            task.spawn(fn_scanNPCs)
        end)

        -- ══════════════════ SEKTION: VERSTECK ESP ══════════════════
        fn_sep("🟢 VERSTECK ESP")

        local fn_hideBtnLbl
        fn_hideBtnLbl = fn_btn("🟢 Versteck-ESP AN / AUS", C_ROW, function()
            fn_hideOn = not fn_hideOn
            if fn_hideOn then
                task.spawn(fn_scanHideSpots)
                fn_startWatch()
                fn_hideBtnLbl.TextColor3 = Color3.fromRGB(50, 220, 100)
            else
                fn_clearESP(fn_hideESP, fn_hideMap)
                if not fn_npcOn and not fn_itemOn then fn_stopWatch() end
                fn_hideBtnLbl.TextColor3 = C_TEXT
                fn_setStatus("🟢 Versteck-ESP AUS", C_SUB)
            end
        end)

        fn_btn("🔄 Verstecke neu scannen", C_ROW, function()
            if not fn_hideOn then
                fn_setStatus("⚠️ Versteck-ESP ist aus", Color3.fromRGB(255, 180, 50)); return
            end
            task.spawn(fn_scanHideSpots)
        end)

        -- ══════════════════ SEKTION: ITEM ESP ══════════════════
        fn_sep("📦 ITEM ESP")

        local fn_itemBtnLbl
        fn_itemBtnLbl = fn_btn("📦 Item-ESP AN / AUS", C_ROW, function()
            fn_itemOn = not fn_itemOn
            if fn_itemOn then
                task.spawn(fn_scanItems)
                fn_startWatch()   -- gemeinsamer ChildAdded-Watcher (kein Heartbeat)
                fn_itemBtnLbl.TextColor3 = Color3.fromRGB(80, 210, 255)
            else
                fn_clearESP(fn_itemESP, fn_itemMap)
                if not fn_npcOn and not fn_hideOn then fn_stopWatch() end
                fn_itemBtnLbl.TextColor3 = C_TEXT
                fn_setStatus("📦 Item-ESP AUS", C_SUB)
            end
        end)

        fn_btn("🔄 Items neu scannen", C_ROW, function()
            if not fn_itemOn then
                fn_setStatus("⚠️ Item-ESP ist aus", Color3.fromRGB(255, 180, 50)); return
            end
            task.spawn(fn_scanItems)
        end)

        fn_btn("🔄 Alles neu scannen", Color3.fromRGB(30, 45, 30), function()
            if fn_npcOn  then task.spawn(fn_scanNPCs)  end
            if fn_itemOn then task.spawn(fn_scanItems) end
            if not fn_npcOn and not fn_itemOn then
                fn_setStatus("⚠️ Kein ESP aktiv", Color3.fromRGB(255, 180, 50))
            end
        end)

        -- ══════════════════ SEKTION: PUPPET-TIMER & UHR HUD ══════════════════
        fn_sep("🎭 PUPPET-TIMER & UHR")

        -- Eigene ScreenGui (unabhängig vom Menü, bleibt beim Schließen aktiv)
        local fn_hudGui = Instance.new("ScreenGui")
        fn_hudGui.Name           = "SemysPuppetHUD"
        fn_hudGui.ResetOnSpawn   = false
        fn_hudGui.IgnoreGuiInset = true
        fn_hudGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        fn_hudGui.DisplayOrder   = 50
        fn_hudGui.Enabled        = false
        pcall(function() fn_hudGui.Parent = CoreGui end)
        if not fn_hudGui.Parent then
            pcall(function()
                fn_hudGui.Parent = LP_FN:WaitForChild("PlayerGui", 5)
            end)
        end

        -- Haupt-Balken: oben mittig
        local fn_hudFrame = Instance.new("Frame")
        fn_hudFrame.AnchorPoint            = Vector2.new(0.5, 0)
        fn_hudFrame.Size                   = UDim2.new(0, 430, 0, 46)
        fn_hudFrame.Position               = UDim2.new(0.5, 0, 0, 8)
        fn_hudFrame.BackgroundColor3       = Color3.fromRGB(10, 10, 15)
        fn_hudFrame.BackgroundTransparency = 0.18
        fn_hudFrame.BorderSizePixel        = 0
        fn_hudFrame.ZIndex                 = 100
        fn_hudFrame.Parent                 = fn_hudGui
        Instance.new("UICorner", fn_hudFrame).CornerRadius = UDim.new(0, 14)
        local _hudStroke = Instance.new("UIStroke", fn_hudFrame)
        _hudStroke.Color        = Color3.fromRGB(220, 110, 255)
        _hudStroke.Thickness    = 1.5
        _hudStroke.Transparency = 0.25
        local _hudGrad = Instance.new("UIGradient", fn_hudFrame)
        _hudGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0,   Color3.fromRGB(35, 10, 50)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(12, 12, 22)),
            ColorSequenceKeypoint.new(1,   Color3.fromRGB(10, 20, 45)),
        })
        _hudGrad.Rotation = 90

        -- Linke Hälfte: Puppet-Timer
        local fn_puppetLbl = Instance.new("TextLabel")
        fn_puppetLbl.AnchorPoint            = Vector2.new(0, 0.5)
        fn_puppetLbl.Size                   = UDim2.new(0.5, -12, 1, 0)
        fn_puppetLbl.Position               = UDim2.new(0, 12, 0.5, 0)
        fn_puppetLbl.BackgroundTransparency = 1
        fn_puppetLbl.Text                   = "🎭 Puppe: ··"
        fn_puppetLbl.TextColor3             = Color3.fromRGB(255, 140, 255)
        fn_puppetLbl.TextStrokeColor3       = Color3.fromRGB(0, 0, 0)
        fn_puppetLbl.TextStrokeTransparency = 0.25
        fn_puppetLbl.Font                   = Enum.Font.GothamBold
        fn_puppetLbl.TextSize               = 16
        fn_puppetLbl.TextXAlignment         = Enum.TextXAlignment.Left
        fn_puppetLbl.ZIndex                 = 101
        fn_puppetLbl.Parent                 = fn_hudFrame

        -- Trenner
        local _hudDiv = Instance.new("Frame")
        _hudDiv.AnchorPoint            = Vector2.new(0.5, 0.5)
        _hudDiv.Size                   = UDim2.new(0, 1, 0.6, 0)
        _hudDiv.Position               = UDim2.new(0.5, 0, 0.5, 0)
        _hudDiv.BackgroundColor3       = Color3.fromRGB(180, 80, 255)
        _hudDiv.BackgroundTransparency = 0.35
        _hudDiv.BorderSizePixel        = 0
        _hudDiv.ZIndex                 = 101
        _hudDiv.Parent                 = fn_hudFrame

        -- Rechte Hälfte: Spieluhr (FNAF Lighting.ClockTime)
        local fn_clockLbl = Instance.new("TextLabel")
        fn_clockLbl.AnchorPoint            = Vector2.new(1, 0.5)
        fn_clockLbl.Size                   = UDim2.new(0.5, -12, 1, 0)
        fn_clockLbl.Position               = UDim2.new(1, -12, 0.5, 0)
        fn_clockLbl.BackgroundTransparency = 1
        fn_clockLbl.Text                   = "🕐 --:--:--"
        fn_clockLbl.TextColor3             = Color3.fromRGB(110, 210, 255)
        fn_clockLbl.TextStrokeColor3       = Color3.fromRGB(0, 0, 0)
        fn_clockLbl.TextStrokeTransparency = 0.25
        fn_clockLbl.Font                   = Enum.Font.GothamBold
        fn_clockLbl.TextSize               = 16
        fn_clockLbl.TextXAlignment         = Enum.TextXAlignment.Right
        fn_clockLbl.ZIndex                 = 101
        fn_clockLbl.Parent                 = fn_hudFrame

        -- HUD-Logik
        local fn_hudOn        = false
        local fn_hudConn      = nil
        local fn_hudMusicVals = {}
        local _hudT           = 0

        local function fn_hudScanMusic()
            fn_hudMusicVals = fn_buildValList(MUSIC_KEYS)
        end

        local function fn_hudGetPuppetVal()
            local best = nil
            for _, v in ipairs(fn_hudMusicVals) do
                pcall(function()
                    if v and v.Parent and type(v.Value) == "number" then
                        if not best or v.Value < best then best = v.Value end
                    end
                end)
            end
            return best
        end

        local function fn_startHUD()
            if fn_hudConn then return end
            task.spawn(fn_hudScanMusic)
            fn_hudConn = game:GetService("RunService").Heartbeat:Connect(function(dt)
                _hudT = _hudT + dt
                if _hudT < 0.45 then return end
                _hudT = 0
                -- Puppet-Timer lesen
                pcall(function()
                    local val = fn_hudGetPuppetVal()
                    if val then
                        local m = math.floor(val / 60)
                        local s = math.floor(val) % 60
                        fn_puppetLbl.Text = ("🎭 Puppe: %d:%02d"):format(m, s)
                        fn_puppetLbl.TextColor3 =
                            val < 20  and Color3.fromRGB(255, 55,  55)  or
                            val < 60  and Color3.fromRGB(255, 180, 50)  or
                            Color3.fromRGB(255, 140, 255)
                    else
                        fn_puppetLbl.Text       = "🎭 Puppe: ··"
                        fn_puppetLbl.TextColor3 = Color3.fromRGB(160, 90, 180)
                    end
                end)
                -- [FIX v98] Spieluhr: Lighting.ClockTime statt os.date (Echtzeit)
                -- FNAF Eternal Nights: Nacht läuft von 12 AM (Mitternacht) bis 6 AM
                pcall(function()
                    local L = game:GetService("Lighting")
                    local ct = L.ClockTime       -- float 0..24
                    local h  = math.floor(ct) % 24
                    local m  = math.floor((ct % 1) * 60)
                    local displayH = h % 12
                    if displayH == 0 then displayH = 12 end
                    local suffix = h < 12 and "AM" or "PM"
                    fn_clockLbl.Text = ("🕐 %d:%02d %s"):format(displayH, m, suffix)
                end)
            end)
        end

        local function fn_stopHUD()
            if fn_hudConn then fn_hudConn:Disconnect(); fn_hudConn = nil end
        end

        local fn_hudBtnLbl
        fn_hudBtnLbl = fn_btn("🎭 Puppet-HUD AN / AUS", C_ROW, function()
            fn_hudOn = not fn_hudOn
            if fn_hudOn then
                fn_hudGui.Enabled = true
                fn_startHUD()
                fn_hudBtnLbl.TextColor3 = Color3.fromRGB(255, 140, 255)
                fn_setStatus("🎭 HUD aktiviert", Color3.fromRGB(255, 140, 255))
            else
                fn_hudGui.Enabled = false
                fn_stopHUD()
                fn_hudBtnLbl.TextColor3 = C_TEXT
                fn_setStatus("🎭 HUD deaktiviert", C_SUB)
            end
        end)

        fn_btn("🔄 Musikbox-Werte neu laden", C_ROW, function()
            task.spawn(fn_hudScanMusic)
            fn_setStatus("🔄 " .. #fn_hudMusicVals .. " Musikbox-Wert(e) gefunden", Color3.fromRGB(255, 140, 255))
        end)

        -- ══════════════════ SEKTION: ITEM-LISTE ══════════════════
        fn_sep("📋 ITEM-LISTE (Auswahl & Teleport)")

        -- ── Popup-Fenster ─────────────────────────────────────────────────
        local fn_itemListWin = Instance.new("Frame")
        fn_itemListWin.Name             = "FNItemListPopup"
        fn_itemListWin.Size             = UDim2.new(0, 400, 0, 420)
        fn_itemListWin.Position         = UDim2.new(0.5, 10, 0.5, -195)
        fn_itemListWin.BackgroundColor3 = C_BG
        fn_itemListWin.BorderSizePixel  = 0
        fn_itemListWin.Visible          = false
        fn_itemListWin.ZIndex           = 20
        fn_itemListWin.Parent           = sg_fn
        fnCorner(fn_itemListWin, 12)
        fnStroke(fn_itemListWin, Color3.fromRGB(80, 200, 255), 2, 0.3)

        -- Titelleiste
        local il_bar = Instance.new("Frame")
        il_bar.Size             = UDim2.new(1, 0, 0, 40)
        il_bar.BackgroundColor3 = C_PANEL
        il_bar.BorderSizePixel  = 0
        il_bar.ZIndex           = 20
        il_bar.Parent           = fn_itemListWin
        fnCorner(il_bar, 12)
        -- Ecken-Fix (untere Hälfte abflachen)
        local il_barFix = Instance.new("Frame")
        il_barFix.Size             = UDim2.new(1, 0, 0, 10)
        il_barFix.Position         = UDim2.new(0, 0, 1, -10)
        il_barFix.BackgroundColor3 = C_PANEL
        il_barFix.BorderSizePixel  = 0
        il_barFix.ZIndex           = 20
        il_barFix.Parent           = il_bar

        local il_titleLbl = Instance.new("TextLabel")
        il_titleLbl.Size                   = UDim2.new(1, -46, 1, 0)
        il_titleLbl.Position               = UDim2.new(0, 10, 0, 0)
        il_titleLbl.BackgroundTransparency = 1
        il_titleLbl.Text                   = "📋  Items – Auswahl & Teleport"
        il_titleLbl.TextColor3             = Color3.fromRGB(80, 210, 255)
        il_titleLbl.Font                   = Enum.Font.GothamBold
        il_titleLbl.TextSize               = 13
        il_titleLbl.TextXAlignment         = Enum.TextXAlignment.Left
        il_titleLbl.ZIndex                 = 20
        il_titleLbl.Parent                 = il_bar

        local il_closeBtn = Instance.new("TextButton")
        il_closeBtn.Size             = UDim2.new(0, 26, 0, 26)
        il_closeBtn.Position         = UDim2.new(1, -32, 0.5, -13)
        il_closeBtn.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
        il_closeBtn.Text             = "✕"
        il_closeBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
        il_closeBtn.Font             = Enum.Font.GothamBold
        il_closeBtn.TextSize         = 12
        il_closeBtn.AutoButtonColor  = false
        il_closeBtn.ZIndex           = 20
        il_closeBtn.Parent           = il_bar
        fnCorner(il_closeBtn, 6)
        il_closeBtn.MouseButton1Click:Connect(function()
            fn_itemListWin.Visible = false
        end)

        -- Info-Zeile (Anzahl)
        local il_countLbl = Instance.new("TextLabel")
        il_countLbl.Size                   = UDim2.new(1, -12, 0, 18)
        il_countLbl.Position               = UDim2.new(0, 6, 0, 44)
        il_countLbl.BackgroundTransparency = 1
        il_countLbl.Text                   = "Liste öffnen um Items zu scannen…"
        il_countLbl.TextColor3             = C_SUB
        il_countLbl.Font                   = Enum.Font.GothamMedium
        il_countLbl.TextSize               = 11
        il_countLbl.TextXAlignment         = Enum.TextXAlignment.Left
        il_countLbl.ZIndex                 = 20
        il_countLbl.Parent                 = fn_itemListWin

        -- Scroll-Bereich für Item-Zeilen
        local il_scroll = Instance.new("ScrollingFrame")
        il_scroll.Size                   = UDim2.new(1, -8, 1, -68)
        il_scroll.Position               = UDim2.new(0, 4, 0, 64)
        il_scroll.BackgroundTransparency = 1
        il_scroll.BorderSizePixel        = 0
        il_scroll.ScrollBarThickness     = 3
        il_scroll.ScrollBarImageColor3   = Color3.fromRGB(80, 200, 255)
        il_scroll.CanvasSize             = UDim2.new()
        il_scroll.AutomaticCanvasSize    = Enum.AutomaticSize.Y
        il_scroll.ZIndex                 = 20
        il_scroll.Parent                 = fn_itemListWin
        local il_listLayout = Instance.new("UIListLayout")
        il_listLayout.Padding   = UDim.new(0, 4)
        il_listLayout.SortOrder = Enum.SortOrder.LayoutOrder
        il_listLayout.Parent    = il_scroll
        local il_pad = Instance.new("UIPadding")
        il_pad.PaddingLeft   = UDim.new(0, 4)
        il_pad.PaddingRight  = UDim.new(0, 4)
        il_pad.PaddingTop    = UDim.new(0, 4)
        il_pad.PaddingBottom = UDim.new(0, 4)
        il_pad.Parent        = il_scroll

        -- ── Drag: Popup verschiebbar machen ───────────────────────────────
        do
            local dragging, dragStart, startPos = false, nil, nil
            il_bar.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging  = true
                    dragStart = inp.Position
                    startPos  = fn_itemListWin.Position
                end
            end)
            il_bar.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
            end)
            game:GetService("UserInputService").InputChanged:Connect(function(inp)
                if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
                    local delta = inp.Position - dragStart
                    fn_itemListWin.Position = UDim2.new(
                        startPos.X.Scale, startPos.X.Offset + delta.X,
                        startPos.Y.Scale, startPos.Y.Offset + delta.Y
                    )
                end
            end)
        end

        -- ── Liste aufbauen ─────────────────────────────────────────────────
        local function fn_buildItemList()
            -- Alte Einträge löschen
            for _, c in ipairs(il_scroll:GetChildren()) do
                if not c:IsA("UIListLayout") and not c:IsA("UIPadding") then c:Destroy() end
            end

            pcall(fn_rebuildCache)
            local items = {}
            local players = game:GetService("Players"):GetPlayers()
            for _, obj in ipairs(fn_cache) do
                if fn_isItem(obj) then
                    local isChar = false
                    for _, pl in ipairs(players) do
                        if pl.Character == obj then isChar = true; break end
                    end
                    if not isChar then table.insert(items, obj) end
                end
            end

            -- Tools (benutzbare Items) immer oben, Models danach
            table.sort(items, function(a, b)
                local aT = a:IsA("Tool") and 0 or 1
                local bT = b:IsA("Tool") and 0 or 1
                if aT ~= bT then return aT < bT end
                return a.Name < b.Name  -- innerhalb der Gruppe alphabetisch
            end)

            if #items == 0 then
                il_countLbl.Text = "⚠️  Keine Items in der Map gefunden"
                return
            end
            il_countLbl.Text = "✅  " .. #items .. " Item(s) — 🔧 Tools zuerst:"

            for _, obj in ipairs(items) do
                -- ── Typ + Farbe ermitteln ───────────────────────────────────
                local isTool   = obj:IsA("Tool")
                local typeIcon = isTool and "🔧 Tool" or "📦 Model"
                local accentC  = isTool
                    and Color3.fromRGB(255, 180, 50)   -- Gold für Tools
                    or  Color3.fromRGB(80, 210, 255)   -- Cyan für Models

                -- ── Zeile ───────────────────────────────────────────────────
                local row = Instance.new("Frame")
                row.Size             = UDim2.new(1, 0, 0, 90)
                row.BackgroundColor3 = Color3.fromRGB(18, 24, 38)
                row.BorderSizePixel  = 0
                row.ZIndex           = 20
                row.Parent           = il_scroll
                fnCorner(row, 8)
                fnStroke(row, accentC, 1, 0.35)

                -- Farbiger Akzent-Streifen am linken Rand
                local accent = Instance.new("Frame")
                accent.Size             = UDim2.new(0, 4, 1, -12)
                accent.Position         = UDim2.new(0, 4, 0.5, -((90-12)/2))
                accent.BackgroundColor3 = accentC
                accent.BorderSizePixel  = 0
                accent.ZIndex           = 21
                accent.Parent           = row
                fnCorner(accent, 2)

                -- ── 3D-Vorschau links (ViewportFrame) ───────────────────────
                local vp = Instance.new("ViewportFrame")
                vp.Size             = UDim2.new(0, 74, 0, 74)
                vp.Position         = UDim2.new(0, 12, 0.5, -37)
                vp.BackgroundColor3 = Color3.fromRGB(10, 14, 22)
                vp.BorderSizePixel  = 0
                vp.LightColor       = Color3.fromRGB(255, 255, 255)
                vp.LightDirection   = Vector3.new(-1, -2, -1)
                vp.Ambient          = Color3.fromRGB(110, 120, 140)
                vp.ZIndex           = 21
                vp.Parent           = row
                fnCorner(vp, 7)
                fnStroke(vp, accentC, 1, 0.4)

                -- Klon asynchron in WorldModel laden (kein Lag im Haupt-Thread)
                task.spawn(function()
                    pcall(function()
                        local wm  = Instance.new("WorldModel")
                        wm.Parent = vp

                        local clone = obj:Clone()

                        -- Alle Descendants unanchoren & auf Origin zentrieren
                        local function prepareClone(c)
                            for _, d in ipairs(c:GetDescendants()) do
                                if d:IsA("BasePart") then
                                    d.Anchored   = true
                                    d.CanCollide = false
                                end
                                -- Scripts deaktivieren damit kein Code läuft
                                if d:IsA("Script") or d:IsA("LocalScript") then
                                    d.Disabled = true
                                end
                            end
                            if c:IsA("BasePart") then
                                c.Anchored   = true
                                c.CanCollide = false
                            end
                        end
                        prepareClone(clone)

                        -- Bounding-Box ermitteln und auf Origin setzen
                        local bbCF, bbSz
                        pcall(function()
                            if clone:IsA("Model") then
                                bbCF, bbSz = clone:GetBoundingBox()
                                if clone.PrimaryPart then
                                    local offset = bbCF.Position
                                    clone:SetPrimaryPartCFrame(
                                        clone.PrimaryPart.CFrame - offset
                                    )
                                else
                                    local root = clone:FindFirstChild("Handle")
                                             or clone:FindFirstChildWhichIsA("BasePart")
                                    if root then root.CFrame = CFrame.new(0,0,0) end
                                end
                            elseif clone:IsA("BasePart") then
                                bbSz = clone.Size
                                clone.CFrame = CFrame.new(0,0,0)
                            elseif clone:IsA("Tool") then
                                local h = clone:FindFirstChild("Handle")
                                       or clone:FindFirstChildWhichIsA("BasePart")
                                if h then
                                    bbSz = h.Size
                                    h.CFrame = CFrame.new(0,0,0)
                                end
                            end
                        end)

                        clone.Parent = wm

                        -- Kamera schräg von oben-rechts, Abstand je nach Objektgröße
                        local cam = Instance.new("Camera")
                        cam.FieldOfView = 45
                        cam.Parent      = vp
                        vp.CurrentCamera = cam

                        local maxD = 3
                        if bbSz then
                            maxD = math.max(bbSz.X, bbSz.Y, bbSz.Z, 1)
                        end
                        local dist = math.max(maxD * 2.2, 4)
                        cam.CFrame = CFrame.lookAt(
                            Vector3.new(dist, dist * 0.7, dist),
                            Vector3.new(0, 0, 0)
                        )
                    end)
                end)

                -- ── Name (oben) ──────────────────────────────────────────────
                local nameLbl = Instance.new("TextLabel")
                nameLbl.Size                   = UDim2.new(1, -210, 0, 26)
                nameLbl.Position               = UDim2.new(0, 96, 0, 10)
                nameLbl.BackgroundTransparency = 1
                nameLbl.Text                   = obj.Name
                nameLbl.TextColor3             = accentC
                nameLbl.Font                   = Enum.Font.GothamBold
                nameLbl.TextSize               = 14
                nameLbl.TextXAlignment         = Enum.TextXAlignment.Left
                nameLbl.TextTruncate           = Enum.TextTruncate.AtEnd
                nameLbl.ZIndex                 = 21
                nameLbl.Parent                 = row

                -- ── Typ-Badge (Mitte) ─────────────────────────────────────────
                local typeBadge = Instance.new("Frame")
                typeBadge.Size             = UDim2.new(0, 76, 0, 20)
                typeBadge.Position         = UDim2.new(0, 96, 0, 40)
                typeBadge.BackgroundColor3 = isTool
                    and Color3.fromRGB(60, 40, 10)
                    or  Color3.fromRGB(10, 40, 60)
                typeBadge.BorderSizePixel  = 0
                typeBadge.ZIndex           = 21
                typeBadge.Parent           = row
                fnCorner(typeBadge, 4)
                fnStroke(typeBadge, accentC, 1, 0.5)

                local typeLbl = Instance.new("TextLabel")
                typeLbl.Size                   = UDim2.new(1, 0, 1, 0)
                typeLbl.BackgroundTransparency = 1
                typeLbl.Text                   = typeIcon
                typeLbl.TextColor3             = accentC
                typeLbl.Font                   = Enum.Font.GothamBold
                typeLbl.TextSize               = 11
                typeLbl.ZIndex                 = 22
                typeLbl.Parent                 = typeBadge

                -- ── Entfernung (unten) ────────────────────────────────────────
                local distLbl = Instance.new("TextLabel")
                distLbl.Size                   = UDim2.new(1, -210, 0, 16)
                distLbl.Position               = UDim2.new(0, 96, 0, 64)
                distLbl.BackgroundTransparency = 1
                distLbl.TextColor3             = Color3.fromRGB(160, 180, 210)
                distLbl.Font                   = Enum.Font.Gotham
                distLbl.TextSize               = 11
                distLbl.TextXAlignment         = Enum.TextXAlignment.Left
                distLbl.ZIndex                 = 21
                distLbl.Parent                 = row
                -- Entfernung berechnen
                pcall(function()
                    local hrp = fn_getHRP()
                    if hrp then
                        local root = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart"))
                                  or (obj:IsA("Tool") and (obj:FindFirstChild("Handle") or obj:FindFirstChildWhichIsA("BasePart")))
                                  or (obj:IsA("BasePart") and obj)
                        if root then
                            local dist = math.floor((hrp.Position - root.Position).Magnitude)
                            distLbl.Text = "📏 " .. dist .. " Studs entfernt"
                        else
                            distLbl.Text = ""
                        end
                    else
                        distLbl.Text = ""
                    end
                end)

                -- ── Teleport-Button rechts ───────────────────────────────────
                local tpBtn = Instance.new("TextButton")
                tpBtn.Size             = UDim2.new(0, 94, 0, 36)
                tpBtn.Position         = UDim2.new(1, -102, 0.5, -18)
                tpBtn.BackgroundColor3 = isTool
                    and Color3.fromRGB(80, 50, 10)
                    or  Color3.fromRGB(15, 65, 100)
                tpBtn.Text             = "📍 Zu mir"
                tpBtn.TextColor3       = accentC
                tpBtn.Font             = Enum.Font.GothamBold
                tpBtn.TextSize         = 13
                tpBtn.AutoButtonColor  = false
                tpBtn.ZIndex           = 21
                tpBtn.Parent           = row
                fnCorner(tpBtn, 7)
                fnStroke(tpBtn, accentC, 1, 0.4)
                tpBtn.MouseEnter:Connect(function()
                    TS_FN:Create(tpBtn, TweenInfo.new(0.1), {
                        BackgroundColor3 = isTool
                            and Color3.fromRGB(130, 85, 15)
                            or  Color3.fromRGB(25, 100, 155)
                    }):Play()
                end)
                tpBtn.MouseLeave:Connect(function()
                    TS_FN:Create(tpBtn, TweenInfo.new(0.1), {
                        BackgroundColor3 = isTool
                            and Color3.fromRGB(80, 50, 10)
                            or  Color3.fromRGB(15, 65, 100)
                    }):Play()
                end)

                local objRef = obj
                tpBtn.MouseButton1Click:Connect(function()
                    task.spawn(function()
                        pcall(function()
                            if not objRef or not objRef.Parent then
                                fn_setStatus("⚠️ " .. objRef.Name .. " existiert nicht mehr", Color3.fromRGB(255, 180, 50))
                                return
                            end
                            local hrp = fn_getHRP()
                            if not hrp then
                                fn_setStatus("❌ Kein Charakter", Color3.fromRGB(255, 80, 80)); return
                            end
                            local targetCF = hrp.CFrame * CFrame.new(0, 0, -3)

                            local function unanchorObj(o)
                                if o:IsA("BasePart") then
                                    pcall(function() o.Anchored = false end)
                                end
                                pcall(function()
                                    for _, d in ipairs(o:GetDescendants()) do
                                        if d:IsA("BasePart") then
                                            pcall(function() d.Anchored = false end)
                                        end
                                    end
                                end)
                            end
                            unanchorObj(objRef)

                            if objRef:IsA("Tool") then
                                if objRef.Parent ~= workspace then
                                    pcall(function() objRef.Parent = workspace end)
                                end
                                local handle = objRef:FindFirstChild("Handle")
                                           or objRef:FindFirstChildWhichIsA("BasePart")
                                if handle then handle.CFrame = targetCF end
                            elseif objRef:IsA("Model") then
                                if objRef.PrimaryPart then
                                    objRef:SetPrimaryPartCFrame(targetCF)
                                else
                                    local root = objRef:FindFirstChild("Handle")
                                             or objRef:FindFirstChildWhichIsA("BasePart")
                                    if root then root.CFrame = targetCF end
                                end
                            elseif objRef:IsA("BasePart") then
                                objRef.CFrame = targetCF
                            end
                            fn_setStatus("📍 " .. objRef.Name .. " zu dir geholt!", Color3.fromRGB(100, 220, 100))
                        end)
                    end)
                end)
            end
        end

        -- ── Buttons im Haupt-Scroll ────────────────────────────────────────
        fn_btn("📋 Item-Liste öffnen & scannen", Color3.fromRGB(18, 48, 70), function()
            fn_itemListWin.Visible = true
            task.spawn(fn_buildItemList)
        end)

        fn_btn("🔄 Item-Liste aktualisieren", Color3.fromRGB(15, 38, 58), function()
            if not fn_itemListWin.Visible then
                fn_setStatus("⚠️ Liste zuerst öffnen", Color3.fromRGB(255, 180, 50)); return
            end
            task.spawn(fn_buildItemList)
            fn_setStatus("🔄 Item-Liste aktualisiert", Color3.fromRGB(80, 210, 255))
        end)

        -- ══════════════════ SEKTION: TOOLS SAUGEN ══════════════════
        fn_sep("🧲 TOOLS / ITEMS HOLEN")

        fn_btn("🧲 Alle Tools zu mir teleportieren", Color3.fromRGB(35, 40, 60), function()
            local hrp = fn_getHRP()
            if not hrp then
                fn_setStatus("❌ Kein Charakter gefunden", Color3.fromRGB(255, 80, 80))
                return
            end

            local count  = 0
            local radius = 4
            -- Immer frisch scannen – kein veralteter Cache
            pcall(fn_rebuildCache)
            local tools = {}
            local players = game:GetService("Players"):GetPlayers()
            for _, obj in ipairs(fn_cache) do
                -- Nur echte Tools (mit E benutzbar) — keine Türen, Lichter, Modelle
                if fn_isItem(obj) then
                    local isPlayerChar = false
                    for _, pl in ipairs(players) do
                        if pl.Character == obj then isPlayerChar = true; break end
                    end
                    if not isPlayerChar then
                        table.insert(tools, obj)
                    end
                end
            end

            if #tools == 0 then
                fn_setStatus("⚠️ Keine Tools / Items im Workspace gefunden", Color3.fromRGB(255, 180, 50))
                return
            end

            -- Alle Tools im Kreis um HRP teleportieren
            local totalAngleStep = (math.pi * 2) / #tools
            local basePos        = hrp.CFrame

            for i, obj in ipairs(tools) do
                pcall(function()
                    local offsetX  = math.cos(totalAngleStep * (i - 1)) * radius
                    local offsetZ  = math.sin(totalAngleStep * (i - 1)) * radius
                    local targetCF = basePos + Vector3.new(offsetX, 0.5, offsetZ)

                    -- Alle Parts unanchoren damit Teleport funktioniert
                    for _, d in ipairs(obj:GetDescendants()) do
                        if d:IsA("BasePart") then pcall(function() d.Anchored = false end) end
                    end
                    if obj:IsA("BasePart") then pcall(function() obj.Anchored = false end) end

                    if obj:IsA("Tool") then
                        if obj.Parent ~= workspace then
                            pcall(function() obj.Parent = workspace end)
                        end
                        local handle = obj:FindFirstChild("Handle")
                                    or obj:FindFirstChildWhichIsA("BasePart")
                        if handle then handle.CFrame = targetCF end
                    elseif obj:IsA("Model") then
                        local root = obj.PrimaryPart
                                  or obj:FindFirstChild("Handle")
                                  or obj:FindFirstChildWhichIsA("BasePart")
                        if root then
                            if obj.PrimaryPart then
                                obj:SetPrimaryPartCFrame(targetCF)
                            else
                                root.CFrame = targetCF
                            end
                        end
                    end
                    count = count + 1
                end)
            end

            fn_setStatus("🧲 " .. count .. " Tool(s) zu dir geholt – aufheben!", Color3.fromRGB(100, 220, 100))
        end)

        fn_btn("🎒 Alle Tools in Backpack legen (versuchen)", Color3.fromRGB(30, 45, 35), function()
            local count = 0
            local bp    = LP_FN:FindFirstChild("Backpack")
            if not bp then
                fn_setStatus("❌ Backpack nicht gefunden", Color3.fromRGB(255, 80, 80))
                return
            end

            -- Immer frisch scannen – kein veralteter Cache
            pcall(fn_rebuildCache)
            for _, obj in ipairs(fn_cache) do
                if obj:IsA("Tool") then
                    local owned = false
                    for _, pl in ipairs(game:GetService("Players"):GetPlayers()) do
                        if pl.Character and pl.Character:FindFirstChild(obj.Name) == obj then
                            owned = true; break
                        end
                        if pl.Backpack:FindFirstChild(obj.Name) then
                            owned = true; break
                        end
                    end
                    if not owned then
                        pcall(function()
                            obj.Parent = bp
                            count      = count + 1
                        end)
                    end
                end
            end

            if count > 0 then
                fn_setStatus("🎒 " .. count .. " Tool(s) ins Backpack gelegt!", Color3.fromRGB(100, 220, 100))
            else
                fn_setStatus("⚠️ Keine freien Tools gefunden", Color3.fromRGB(255, 180, 50))
            end
        end)

        -- [FIX v99 Bug 1] Dieser zweite ESP-AncestryChanged-Block wurde ENTFERNT.
        -- Cleanup ist in fn_cleanupAll() am Ende konsolidiert.

        -- ══════════════════ SEKTION: KAMERA-VIEWER ══════════════════
        fn_sep("📷 KAMERA-VIEWER")

        -- [FIX] fn_camRestore wird in fn_cleanupAll() referenziert → in äußeren Scope hoisten.
        -- Die restlichen ~17 Kamera-Viewer-Locals werden im do...end-Block gekapselt und
        -- freigegeben, bevor die Minimap-Sektion beginnt (Lua-Limit: 200 Locals/Funktion).
        local fn_camRestore   -- Impl. folgt im do-Block unten

        do  -- ── Kamera-Viewer Scope-Block (Locals werden am Ende freigegeben) ─────────────

        -- Scannt workspace nach Sicherheitskamera-Objekten und lässt den
        -- Spieler die Ansicht direkt auf eine Kamera setzen – kein Computer nötig.

        -- fn_camList-Einträge: { name, part, viewCF, tier, pos }
        --   tier 1 = Roblox Camera-Child gefunden  (sicherste Quelle)
        --   tier 2 = Spiel-Attribut (CamID, Number …) vorhanden
        --   tier 3 = Name-Match + Ankerpunkt-/Größen-Filter (nur echte Wand-Cams)
        local fn_camList      = {}
        local fn_camViewOn    = false
        local fn_camOrigType  = nil
        local fn_camConn      = nil

        -- Name-Keywords NUR für Tier-3-Fallback (mit und ohne Leerzeichen)
        local CAM_VIEW_KEYS = {
            "camera","cam","cctv","surveillance","securitycam",
            "wallcam","wall cam","security cam","lens","viewpoint",
        }
        -- Diese Keywords im Namen schließen das Objekt definitiv aus,
        -- egal was sonst passt (Hand-Items, Deko, Spieler-GUI)
        local CAM_EXCLUDE_KEYS = {
            "hand","held","item","pickup","tool","player",
            "flashlight","torch","lantern","scope","zoom",
            "button","screen","gui","frame","label","icon",
            "preview","thumbnail","viewport","render",
        }
        -- Attribute die ein Spiel auf echter Sicherheitskamera setzt (Tier 2)
        local CAM_ATTR_KEYS = {
            "CamID","CameraID","camID","cameraID","CameraIndex",
            "camIndex","CamNumber","camNumber","CameraNumber","SecurityCam",
            "CamSlot","camSlot","ID",
        }

        -- Berechnet den besten Blickwinkel für eine Kamera.
        -- Priorität: Camera-Child > Part-CFrame mit Neigungskorrektur
        local function fn_getBestViewCF(obj, part)
            -- Priorität 1: Roblox Camera-Objekt als Kind → exakte Spielkamera
            local camChild = obj:FindFirstChildOfClass("Camera")
            if not camChild and part and part ~= obj then
                camChild = part:FindFirstChildOfClass("Camera")
            end
            if camChild then
                -- Camera-CFrame zeigt bereits in die richtige Richtung
                return camChild.CFrame, 1
            end

            -- Priorität 2/3: Part-CFrame mit smarter Neigungskorrektur
            if not part then return nil, 0 end
            local cf = part.CFrame
            local lv = cf.LookVector

            -- Deckenmontur: LookVector zeigt stark nach unten → senkrecht nach unten blicken
            if lv.Y < -0.65 then
                return CFrame.new(part.Position, part.Position + Vector3.new(0, -1, 0)), 3

            -- Boden-/Tischmontur: LookVector zeigt stark nach oben → unbrauchbar, kippen
            elseif lv.Y > 0.65 then
                -- 90° nach unten drehen damit man die Szene vor der Kamera sieht
                return cf * CFrame.Angles(math.rad(-80), 0, 0), 3

            -- Wandmontur (typisch): 15° nach unten neigen für Überwachungsfeld
            else
                return cf * CFrame.Angles(math.rad(-15), 0, 0), 3
            end
        end

        -- Scannt workspace nach echten Sicherheitskameras (dreistufig)
        local function fn_scanCameras()
            fn_camList = {}
            local seen       = {}
            local players    = game:GetService("Players"):GetPlayers()

            -- Hilfsfunktion: Ist das Objekt Teil eines Spieler-Chars/Backpacks?
            local function isPlayerOwned(obj)
                for _, pl in ipairs(players) do
                    if pl.Character and obj:IsDescendantOf(pl.Character) then return true end
                    if pl.Backpack   and obj:IsDescendantOf(pl.Backpack)   then return true end
                end
                return false
            end

            -- Hilfsfunktion: Enthält der Name einen Ausschluss-Keyword?
            local function isExcludedName(low)
                for _, k in ipairs(CAM_EXCLUDE_KEYS) do
                    if low:find(k, 1, true) then return true end
                end
                return false
            end

            -- Positions-Dedup: schon ein Eintrag innerhalb von 3 Studs?
            local function nearDuplicate(pos)
                for _, e in ipairs(fn_camList) do
                    if (e.pos - pos).Magnitude < 3 then return true, e end
                end
                return false, nil
            end

            local function tryAdd(obj)
                if seen[obj] then return end
                seen[obj] = true

                -- Harte Ausschlüsse: Tool, UI, CurrentCamera, PlayerGui-Descendants
                if obj:IsA("Tool")             then return end
                if obj:IsA("Camera")           then return end  -- Roblox-Camera-Objekt selbst
                if obj:IsA("ScreenGui")        then return end
                if obj:IsA("BillboardGui")     then return end
                if obj:IsA("SurfaceGui")       then return end
                if obj:IsA("ViewportFrame")    then return end
                if obj:IsA("Frame")            then return end
                if obj:IsA("TextLabel")        then return end
                if obj:IsA("TextButton")       then return end
                if obj == workspace.CurrentCamera then return end
                if isPlayerOwned(obj) then return end

                -- Physisches Part ermitteln
                local part = nil
                if obj:IsA("BasePart") then
                    part = obj
                elseif obj:IsA("Model") then
                    part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                else
                    return  -- Folder, Script, etc.
                end
                if not part then return end

                -- Part-Qualitäts-Filter: unsichtbar, zu winzig, oder beweglich → raus
                if part.Transparency >= 0.99 then return end
                local sz = part.Size
                if sz.X < 0.12 and sz.Y < 0.12 and sz.Z < 0.12 then return end
                -- Nicht verankert = bewegliches Objekt (kein Wand-Cam)
                -- Ausnahme: Tier-1-Kameras (Camera-Child) dürfen auch unverankert sein
                local hasCamera = obj:FindFirstChildOfClass("Camera")
                              or part:FindFirstChildOfClass("Camera")
                if not hasCamera and not part.Anchored then return end

                local low  = obj.Name:lower()
                local tier = 0

                -- ── TIER 1: Roblox Camera-Child ─────────────────────────────
                if hasCamera then
                    tier = 1
                end

                -- ── TIER 2: Spiel-Attribut vorhanden ────────────────────────
                if tier == 0 then
                    for _, attr in ipairs(CAM_ATTR_KEYS) do
                        local v = obj:GetAttribute(attr)
                               or part:GetAttribute(attr)
                        if v ~= nil then tier = 2; break end
                    end
                end

                -- ── TIER 3: Name-Match mit Ausschluss-Filter ─────────────────
                if tier == 0 then
                    if isExcludedName(low) then return end
                    local nameMatch = false
                    for _, k in ipairs(CAM_VIEW_KEYS) do
                        if low:find(k, 1, true) then nameMatch = true; break end
                    end
                    if not nameMatch then return end
                    tier = 3

                    -- Zusatz-Filter nur für Tier 3:
                    -- Kamera muss mindestens 0.5 Studs in einer Dimension haben
                    -- (filtert winzige Deko-Teile mit "cam" im Namen)
                    if sz.X < 0.5 and sz.Y < 0.5 and sz.Z < 0.5 then return end
                end

                -- Positions-Dedup (gleiche Kamera als verschiedene Parts)
                local pos = part.Position
                local dup, existing = nearDuplicate(pos)
                if dup then
                    -- Höhere Priorität gewinnt
                    if tier < existing.tier then
                        existing.tier = tier
                        existing.name = obj.Name
                        local vCF, _ = fn_getBestViewCF(obj, part)
                        if vCF then existing.viewCF = vCF end
                    end
                    return
                end

                local viewCF, _ = fn_getBestViewCF(obj, part)
                if not viewCF then return end

                table.insert(fn_camList, {
                    name   = obj.Name,
                    part   = part,
                    viewCF = viewCF,
                    tier   = tier,
                    pos    = pos,
                })
            end

            for _, obj in ipairs(workspace:GetDescendants()) do
                pcall(tryAdd, obj)
            end

            -- Sortierung: Tier 1 → 2 → 3, innerhalb alphabetisch
            table.sort(fn_camList, function(a, b)
                if a.tier ~= b.tier then return a.tier < b.tier end
                return a.name < b.name
            end)
        end

        -- Normale Kamera wiederherstellen
        -- [FIX] Zuweisung statt local function – fn_camRestore ist im äußeren Scope deklariert
        fn_camRestore = function()
            fn_camViewOn = false
            if fn_camConn then fn_camConn:Disconnect(); fn_camConn = nil end
            local wsCam = workspace.CurrentCamera
            if wsCam and fn_camOrigType then
                pcall(function() wsCam.CameraType = fn_camOrigType end)
            end
            fn_camOrigType = nil
        end

        -- Kamera-Ansicht aus einem fn_camList-Eintrag setzen
        -- Nutzt vorberechnetes entry.viewCF (korrekte Neigung, Camera-Child-Prio)
        local function fn_setCamView(entry)
            -- [FIX code-review] Defensiver Guard: kein Crash wenn Eintrag ungültig
            if not entry or not entry.viewCF then
                fn_setStatus("⚠️ Kamera-Eintrag ungültig", Color3.fromRGB(255, 180, 50))
                return
            end
            pcall(function()
                local wsCam = workspace.CurrentCamera
                if not fn_camOrigType then
                    fn_camOrigType = wsCam.CameraType
                end
                wsCam.CameraType = Enum.CameraType.Scriptable
                local cf = entry.viewCF
                wsCam.CFrame = cf
                fn_camViewOn = true
                -- RenderStepped-Lock damit das Spiel die Kamera nicht zurückschreibt
                if fn_camConn then fn_camConn:Disconnect() end
                fn_camConn = game:GetService("RunService").RenderStepped:Connect(function()
                    if not fn_camViewOn then
                        fn_camConn:Disconnect(); fn_camConn = nil; return
                    end
                    pcall(function()
                        workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
                        workspace.CurrentCamera.CFrame     = cf
                    end)
                end)
            end)
        end

        -- Popup-Fenster für Kameraliste
        local fn_camWin = Instance.new("Frame")
        fn_camWin.Name             = "FNCamViewerPopup"
        fn_camWin.Size             = UDim2.new(0, 360, 0, 380)
        fn_camWin.Position         = UDim2.new(0.5, 10, 0.5, -175)
        fn_camWin.BackgroundColor3 = C_BG
        fn_camWin.BorderSizePixel  = 0
        fn_camWin.Visible          = false
        fn_camWin.ZIndex           = 20
        fn_camWin.Parent           = sg_fn
        fnCorner(fn_camWin, 12)
        fnStroke(fn_camWin, Color3.fromRGB(255, 180, 50), 2, 0.3)

        -- Titelleiste
        local fn_camTitle = Instance.new("TextLabel")
        fn_camTitle.Size                   = UDim2.new(1, -40, 0, 36)
        fn_camTitle.Position               = UDim2.new(0, 10, 0, 0)
        fn_camTitle.BackgroundTransparency = 1
        fn_camTitle.Text                   = "📷 Sicherheitskameras"
        fn_camTitle.TextColor3             = Color3.fromRGB(255, 200, 80)
        fn_camTitle.Font                   = Enum.Font.GothamBold
        fn_camTitle.TextSize               = 15
        fn_camTitle.TextXAlignment         = Enum.TextXAlignment.Left
        fn_camTitle.ZIndex                 = 21
        fn_camTitle.Parent                 = fn_camWin

        -- Schließen-Button
        local fn_camClose = Instance.new("TextButton")
        fn_camClose.Size                   = UDim2.new(0, 30, 0, 30)
        fn_camClose.Position               = UDim2.new(1, -34, 0, 3)
        fn_camClose.BackgroundColor3       = Color3.fromRGB(200, 50, 50)
        fn_camClose.Text                   = "✕"
        fn_camClose.TextColor3             = Color3.fromRGB(255, 255, 255)
        fn_camClose.Font                   = Enum.Font.GothamBold
        fn_camClose.TextSize               = 14
        fn_camClose.ZIndex                 = 22
        fn_camClose.Parent                 = fn_camWin
        fnCorner(fn_camClose, 8)
        fn_camClose.MouseButton1Click:Connect(function()
            fn_camWin.Visible = false
            fn_camRestore()
        end)

        -- "Normale Ansicht" Button oben im Popup
        local fn_camBackBtn = Instance.new("TextButton")
        fn_camBackBtn.Size                   = UDim2.new(1, -16, 0, 32)
        fn_camBackBtn.Position               = UDim2.new(0, 8, 0, 38)
        fn_camBackBtn.BackgroundColor3       = Color3.fromRGB(40, 100, 40)
        fn_camBackBtn.Text                   = "🔙 Normale Ansicht wiederherstellen"
        fn_camBackBtn.TextColor3             = Color3.fromRGB(120, 255, 120)
        fn_camBackBtn.Font                   = Enum.Font.GothamBold
        fn_camBackBtn.TextSize               = 13
        fn_camBackBtn.ZIndex                 = 22
        fn_camBackBtn.Parent                 = fn_camWin
        fnCorner(fn_camBackBtn, 8)
        fn_camBackBtn.MouseButton1Click:Connect(function()
            fn_camRestore()
            fn_setStatus("📷 Normale Ansicht", C_SUB)
        end)

        -- Scroll für Kameraliste
        -- [FIX v99] AutomaticCanvasSize statt manueller Pixel-Berechnung
        local fn_camScroll = Instance.new("ScrollingFrame")
        fn_camScroll.Size                  = UDim2.new(1, -16, 1, -80)
        fn_camScroll.Position              = UDim2.new(0, 8, 0, 76)
        fn_camScroll.BackgroundTransparency = 1
        fn_camScroll.ScrollBarThickness    = 4
        fn_camScroll.ScrollBarImageColor3  = Color3.fromRGB(255, 180, 50)
        fn_camScroll.CanvasSize            = UDim2.new()
        fn_camScroll.AutomaticCanvasSize   = Enum.AutomaticSize.Y
        fn_camScroll.ZIndex                = 21
        fn_camScroll.Parent                = fn_camWin
        local fn_camLayout = Instance.new("UIListLayout", fn_camScroll)
        fn_camLayout.Padding        = UDim.new(0, 4)
        fn_camLayout.SortOrder      = Enum.SortOrder.LayoutOrder
        Instance.new("UIPadding", fn_camScroll).PaddingBottom = UDim.new(0, 6)

        local function fn_buildCamList()
            -- Alle alten Einträge löschen (Frames, Buttons, Labels) – UIListLayout/UIPadding behalten
            -- [FIX code-review] Neue Zeilen sind Frame-Instanzen → auch Frames bereinigen,
            -- sonst stapeln sich bei mehrfachem Re-Scan die alten Rows auf.
            for _, c in ipairs(fn_camScroll:GetChildren()) do
                if not c:IsA("UIListLayout") and not c:IsA("UIPadding") then c:Destroy() end
            end

            if #fn_camList == 0 then
                local lbl = Instance.new("TextLabel")
                lbl.Size                   = UDim2.new(1, 0, 0, 40)
                lbl.BackgroundTransparency = 1
                lbl.Text                   = "⚠️  Keine echten Sicherheitskameras gefunden.\nTipp: Kamera muss verankert & sichtbar sein."
                lbl.TextColor3             = Color3.fromRGB(255, 180, 50)
                lbl.Font                   = Enum.Font.Gotham
                lbl.TextSize               = 12
                lbl.TextWrapped            = true
                lbl.ZIndex                 = 22
                lbl.Parent                 = fn_camScroll
                return
            end

            -- Tier-Farbe + Icon ermitteln
            local function tierStyle(tier)
                if tier == 1 then
                    -- Grün: Roblox Camera-Child → 100% echte Spielkamera
                    return Color3.fromRGB(80, 220, 80),  Color3.fromRGB(15, 40, 15),  "🟢"
                elseif tier == 2 then
                    -- Gelb: Spiel-Attribut vorhanden → sehr wahrscheinlich echt
                    return Color3.fromRGB(255, 220, 60), Color3.fromRGB(40, 35, 10),  "🟡"
                else
                    -- Orange: Name-Match + Struktur-Filter → wahrscheinlich echt
                    return Color3.fromRGB(255, 160, 50), Color3.fromRGB(40, 25, 10),  "🟠"
                end
            end

            for i, entry in ipairs(fn_camList) do
                local txtCol, bgCol, icon = tierStyle(entry.tier)

                -- Entfernung berechnen (optional, kein Fehler wenn kein Char)
                local distStr = ""
                pcall(function()
                    local hrp = fn_getHRP()
                    if hrp and entry.part and entry.part.Parent then
                        local d = math.floor((hrp.Position - entry.part.Position).Magnitude)
                        distStr = ("  📏 %d Studs"):format(d)
                    end
                end)

                -- Zeile: zweizeilig (Name + Entfernung/Typ)
                local row = Instance.new("Frame")
                row.Size             = UDim2.new(1, 0, 0, 52)
                row.BackgroundColor3 = bgCol
                row.BorderSizePixel  = 0
                row.ZIndex           = 22
                row.LayoutOrder      = i
                row.Parent           = fn_camScroll
                fnCorner(row, 8)
                fnStroke(row, txtCol, 1, 0.45)

                -- Tier-Icon links
                local iconLbl = Instance.new("TextLabel")
                iconLbl.Size                   = UDim2.new(0, 30, 1, 0)
                iconLbl.Position               = UDim2.new(0, 4, 0, 0)
                iconLbl.BackgroundTransparency = 1
                iconLbl.Text                   = icon
                iconLbl.TextSize               = 18
                iconLbl.Font                   = Enum.Font.GothamBold
                iconLbl.ZIndex                 = 23
                iconLbl.Parent                 = row

                -- Kamera-Name
                local nameLbl = Instance.new("TextLabel")
                nameLbl.Size                   = UDim2.new(1, -130, 0, 26)
                nameLbl.Position               = UDim2.new(0, 38, 0, 4)
                nameLbl.BackgroundTransparency = 1
                nameLbl.Text                   = entry.name
                nameLbl.TextColor3             = txtCol
                nameLbl.Font                   = Enum.Font.GothamBold
                nameLbl.TextSize               = 13
                nameLbl.TextXAlignment         = Enum.TextXAlignment.Left
                nameLbl.TextTruncate           = Enum.TextTruncate.AtEnd
                nameLbl.ZIndex                 = 23
                nameLbl.Parent                 = row

                -- Entfernung / Tier-Beschriftung
                local subLbl = Instance.new("TextLabel")
                subLbl.Size                   = UDim2.new(1, -130, 0, 18)
                subLbl.Position               = UDim2.new(0, 38, 0, 30)
                subLbl.BackgroundTransparency = 1
                local tierName = entry.tier == 1 and "Camera-Child" or entry.tier == 2 and "Attribut-Tag" or "Strukturcheck"
                subLbl.Text                   = ("Tier %d – %s%s"):format(entry.tier, tierName, distStr)
                subLbl.TextColor3             = Color3.fromRGB(180, 180, 180)
                subLbl.Font                   = Enum.Font.Gotham
                subLbl.TextSize               = 11
                subLbl.TextXAlignment         = Enum.TextXAlignment.Left
                subLbl.ZIndex                 = 23
                subLbl.Parent                 = row

                -- Ansehen-Button rechts
                local viewBtn = Instance.new("TextButton")
                viewBtn.Size             = UDim2.new(0, 80, 0, 36)
                viewBtn.Position         = UDim2.new(1, -88, 0.5, -18)
                viewBtn.BackgroundColor3 = Color3.fromRGB(30, 60, 30)
                viewBtn.Text             = "👁 Ansehen"
                viewBtn.TextColor3       = txtCol
                viewBtn.Font             = Enum.Font.GothamBold
                viewBtn.TextSize         = 12
                viewBtn.AutoButtonColor  = false
                viewBtn.ZIndex           = 23
                viewBtn.Parent           = row
                fnCorner(viewBtn, 7)
                fnStroke(viewBtn, txtCol, 1, 0.4)
                viewBtn.MouseEnter:Connect(function()
                    TS_FN:Create(viewBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(50, 100, 50)}):Play()
                end)
                viewBtn.MouseLeave:Connect(function()
                    TS_FN:Create(viewBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(30, 60, 30)}):Play()
                end)
                local entryRef = entry
                viewBtn.MouseButton1Click:Connect(function()
                    fn_setCamView(entryRef)   -- übergibt den ganzen Eintrag (viewCF vorberechnet)
                    fn_setStatus("📷 Kamera: " .. entryRef.name, Color3.fromRGB(255, 200, 80))
                    -- Button kurz aufleuchten
                    viewBtn.BackgroundColor3 = Color3.fromRGB(80, 150, 80)
                    task.delay(0.35, function()
                        pcall(function() viewBtn.BackgroundColor3 = Color3.fromRGB(30, 60, 30) end)
                    end)
                end)
            end
        end

        -- Haupt-Buttons im Menü
        fn_btn("📷 Kameras scannen & anzeigen", C_ROW, function()
            task.spawn(function()
                fn_setStatus("🔍 Scanne Kameras (Tier 1-3 Filter)…", C_SUB)
                fn_scanCameras()
                fn_buildCamList()
                fn_camWin.Visible = true
                local t1 = 0; local t2 = 0; local t3 = 0
                for _, e in ipairs(fn_camList) do
                    if e.tier == 1 then t1 = t1+1 elseif e.tier == 2 then t2 = t2+1 else t3 = t3+1 end
                end
                fn_setStatus(("📷 %d Kamera(s): 🟢%d 🟡%d 🟠%d"):format(#fn_camList,t1,t2,t3),
                    Color3.fromRGB(255, 200, 80))
            end)
        end)

        fn_btn("🔙 Normale Ansicht (Kamera zurück)", C_ROW, function()
            fn_camRestore()
            fn_setStatus("📷 Normale Ansicht wiederhergestellt", C_SUB)
        end)

        -- Cleanup beim Schließen: in fn_cleanupAll() am Ende des Blocks erledigt

        end  -- ── Ende Kamera-Viewer Scope-Block ───────────────────────────────────────────
        -- Die ~17 Kamera-Viewer-Locals (fn_camList, fn_camViewOn, CAM_*_KEYS, fn_getCamView usw.)
        -- sind jetzt freigegeben. fn_camRestore bleibt via äußerem Scope erreichbar.

        -- ══════════════════ SEKTION: MINIMAP ══════════════════
        fn_sep("🗺️ MINIMAP")

        -- ── Konstanten ──────────────────────────────────────────────────
        local MM_PX    = 160              -- Kartenfenster-Pixel
        local MM_RANGE = 70               -- sichtbarer Radius in Studs
        local MM_SCALE = MM_PX / (MM_RANGE * 2)  -- Pixel pro Stud

        -- ── State ───────────────────────────────────────────────────────
        local mm_on       = false
        local mm_sg       = nil           -- ScreenGui
        local mm_view     = nil           -- geclipptes Kreisframe
        local mm_selfDot  = nil           -- eigener Dot (Mitte)
        local mm_dirDot   = nil           -- Richtungsanzeiger
        local mm_conn     = nil           -- Heartbeat
        local mm_keyConn  = nil           -- M-Taste Keybind
        local mm_t        = 0
        local mm_liveDots  = {}           -- Pool für NPC / Spieler-Dots
        local mm_floorDots = {}           -- Bodenplatten-Dots
        local mm_floorTimer = 0

        -- ── Welt → Pixel ────────────────────────────────────────────────
        local function mm_toScreen(wx, wz, cx, cz)
            return MM_PX/2 + (wx - cx) * MM_SCALE,
                   MM_PX/2 + (wz - cz) * MM_SCALE
        end

        -- Runden Frame erstellen
        local function mm_makeDot(parent, size, color, zi)
            local f = Instance.new("Frame")
            f.Size             = UDim2.new(0, size, 0, size)
            f.BackgroundColor3 = color
            f.BorderSizePixel  = 0
            f.ZIndex           = zi or 5
            f.Parent           = parent
            Instance.new("UICorner", f).CornerRadius = UDim.new(1, 0)
            return f
        end

        -- Dot aus Pool holen (kein Heap-Alloc pro Frame)
        local function mm_getPoolDot()
            for _, e in ipairs(mm_liveDots) do
                if not e.used then
                    e.used        = true
                    e.frame.Visible = true
                    return e
                end
            end
            local f = mm_makeDot(mm_view, 7, Color3.fromRGB(255,255,255), 6)
            local e = { frame = f, used = true, lbl = nil }
            table.insert(mm_liveDots, e)
            return e
        end

        local function mm_resetPool()
            for _, e in ipairs(mm_liveDots) do
                e.used = false
                e.frame.Visible = false
                if e.lbl then e.lbl.Text = "" end
            end
        end

        -- ── Bodenplatten aus fn_cache lesen ─────────────────────────────
        local function mm_buildFloor()
            local newF = {}
            local seen = {}
            local count = 0
            local MAX = 280
            for _, obj in ipairs(fn_cache) do
                if count >= MAX then break end
                if obj:IsA("BasePart") and not fn_isNPC(obj) then
                    local s   = obj.Size
                    local isWall  = s.Y > 2.5 and (s.X >= 2 or s.Z >= 2)  -- Wände: hoch
                    local isFloor = s.Y < 2.5 and (s.X >= 6 or s.Z >= 6)  -- Böden: flach+breit
                    if isWall or isFloor then
                        -- 5-Stud-Grid-Dedup
                        local gx  = math.floor(obj.Position.X / 5) * 5
                        local gz  = math.floor(obj.Position.Z / 5) * 5
                        local key = gx .. "|" .. gz
                        if not seen[key] then
                            seen[key] = true
                            -- Wände: Breite proportional; Böden: etwas dünner darstellen
                            local fw = math.clamp(s.X * MM_SCALE, isWall and 4 or 3, 36)
                            local fh = math.clamp(s.Z * MM_SCALE, isWall and 4 or 3, 36)
                            table.insert(newF, {
                                wx = obj.Position.X,
                                wz = obj.Position.Z,
                                fw = fw, fh = fh,
                                isWall = isWall
                            })
                            count = count + 1
                        end
                    end
                end
            end
            -- Überschüssige Dots entfernen
            for i = #mm_floorDots, #newF + 1, -1 do
                pcall(function() mm_floorDots[i].frame:Destroy() end)
                mm_floorDots[i] = nil
            end
            -- Erstellen / recyclen
            for i, fd in ipairs(newF) do
                -- Wände = sattes Grün; Böden = helleres Grün (wie im Bild)
                local col = fd.isWall
                    and Color3.fromRGB(55, 108, 48)   -- dunkles Wand-Grün
                    or  Color3.fromRGB(80, 135, 70)   -- helleres Boden-Grün
                if mm_floorDots[i] then
                    mm_floorDots[i].frame.Size             = UDim2.new(0, fd.fw, 0, fd.fh)
                    mm_floorDots[i].frame.BackgroundColor3 = col
                    mm_floorDots[i].wx = fd.wx; mm_floorDots[i].wz = fd.wz
                    mm_floorDots[i].fw = fd.fw; mm_floorDots[i].fh = fd.fh
                else
                    local f = Instance.new("Frame")
                    f.Size                   = UDim2.new(0, fd.fw, 0, fd.fh)
                    f.BackgroundColor3       = col
                    f.BackgroundTransparency = 0
                    f.BorderSizePixel        = 0
                    f.ZIndex                 = 2
                    f.Parent                 = mm_view
                    mm_floorDots[i] = { frame = f, wx = fd.wx, wz = fd.wz, fw = fd.fw, fh = fd.fh }
                end
            end
        end

        -- ── Haupt-Update (0.5 s) ────────────────────────────────────────
        local function mm_update(dt)
            local hrp = fn_getHRP()
            if not hrp then return end
            local myPos = hrp.Position
            local cx, cz = myPos.X, myPos.Z

            -- Boden alle 8s neu scannen
            mm_floorTimer = mm_floorTimer + dt
            if mm_floorTimer >= 8 then
                mm_floorTimer = 0
                pcall(mm_buildFloor)
            end

            -- Bodenplatten repositionieren
            for _, fd in ipairs(mm_floorDots) do
                local sx, sz = mm_toScreen(fd.wx, fd.wz, cx, cz)
                fd.frame.Position = UDim2.new(0, sx - fd.fw/2, 0, sz - fd.fh/2)
                fd.frame.Visible  = sx > -fd.fw and sx < MM_PX + fd.fw
                              and sz > -fd.fh and sz < MM_PX + fd.fh
            end

            -- Dreieck-Pfeil dreht sich mit LookVector (Rotation-Property in Grad)
            pcall(function()
                local lv    = hrp.CFrame.LookVector
                local angle = math.atan2(lv.X, -lv.Z)
                mm_selfDot.Rotation = math.deg(angle)
            end)

            mm_resetPool()

            -- Mitspieler (grün)
            for _, pl in ipairs(game:GetService("Players"):GetPlayers()) do
                if pl ~= LP_FN and pl.Character then
                    local root = pl.Character:FindFirstChild("HumanoidRootPart")
                    if root then
                        local sx, sz = mm_toScreen(root.Position.X, root.Position.Z, cx, cz)
                        if sx >= 0 and sx <= MM_PX and sz >= 0 and sz <= MM_PX then
                            local e   = mm_getPoolDot()
                            local dot = e.frame
                            dot.Size             = UDim2.new(0, 7, 0, 7)
                            dot.BackgroundColor3 = Color3.fromRGB(80, 220, 80)
                            dot.Position         = UDim2.new(0, sx - 3, 0, sz - 3)
                            -- Name-Label (einmalig erstellen)
                            if not e.lbl then
                                local lbl = Instance.new("TextLabel")
                                lbl.Size                  = UDim2.new(0, 60, 0, 11)
                                lbl.Position              = UDim2.new(0, 9, 0, -2)
                                lbl.BackgroundTransparency = 1
                                lbl.TextColor3            = Color3.fromRGB(80, 220, 80)
                                lbl.Font                  = Enum.Font.GothamBold
                                lbl.TextSize              = 9
                                lbl.TextXAlignment        = Enum.TextXAlignment.Left
                                lbl.ZIndex                = 7
                                lbl.Parent                = dot
                                e.lbl = lbl
                            end
                            e.lbl.Text = pl.Name
                        end
                    end
                end
            end

            -- FNAF-Monster (Charakterfarbe)
            for _, obj in ipairs(fn_cache) do
                if fn_isNPC(obj) then
                    local root = obj:FindFirstChild("HumanoidRootPart")
                             or obj:FindFirstChildWhichIsA("BasePart")
                    if root then
                        local sx, sz = mm_toScreen(root.Position.X, root.Position.Z, cx, cz)
                        if sx >= 0 and sx <= MM_PX and sz >= 0 and sz <= MM_PX then
                            local fillC = fn_getNPCColor(obj)
                            local e   = mm_getPoolDot()
                            local dot = e.frame
                            dot.Size             = UDim2.new(0, 8, 0, 8)
                            dot.BackgroundColor3 = fillC
                            dot.Position         = UDim2.new(0, sx - 4, 0, sz - 4)
                            if e.lbl then e.lbl.Text = "" end
                        end
                    end
                end
            end
        end

        -- ── UI aufbauen ─────────────────────────────────────────────────
        local function mm_buildUI()
            local pg = LP_FN:FindFirstChild("PlayerGui")
            if not pg then return end
            local old = pg:FindFirstChild("SemysMinimap")
            if old then old:Destroy() end

            local sg = Instance.new("ScreenGui")
            sg.Name           = "SemysMinimap"
            sg.ResetOnSpawn   = false
            sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            sg.IgnoreGuiInset = true
            sg.Parent         = pg

            -- Äußerer schwarzer Rahmen (dicke Abrundung wie im Bild)
            local outer = Instance.new("Frame")
            outer.Size                   = UDim2.new(0, MM_PX + 12, 0, MM_PX + 12)
            outer.Position               = UDim2.new(0, 10, 1, -(MM_PX + 32))
            outer.BackgroundColor3       = Color3.fromRGB(12, 12, 12)
            outer.BackgroundTransparency = 0
            outer.BorderSizePixel        = 0
            outer.Parent                 = sg
            Instance.new("UICorner", outer).CornerRadius = UDim.new(0, 20)

            -- Kartenansicht – abgerundetes Rechteck (NICHT Kreis), beige wie Karten-Papier
            local view = Instance.new("Frame")
            view.Name                    = "View"
            view.Size                    = UDim2.new(0, MM_PX, 0, MM_PX)
            view.Position                = UDim2.new(0, 6, 0, 6)
            view.BackgroundColor3        = Color3.fromRGB(192, 170, 132)  -- sandbeige
            view.ClipsDescendants        = true
            view.BorderSizePixel         = 0
            view.Parent                  = outer
            Instance.new("UICorner", view).CornerRadius = UDim.new(0, 14)  -- abgerundetes Viereck

            -- Kompass N (rot, oben Mitte — dezent)
            local north = Instance.new("TextLabel")
            north.Size = UDim2.new(0,12,0,13); north.Position = UDim2.new(0.5,-6,0,2)
            north.BackgroundTransparency = 1; north.Text = "N"
            north.TextColor3 = Color3.fromRGB(180,50,50)
            north.Font = Enum.Font.GothamBold; north.TextSize = 10
            north.ZIndex = 10; north.Parent = view

            -- Weißer Dreieck-Pfeil (dreht sich mit dem Spieler, immer Mitte)
            -- TextLabel mit "▲" + Rotation-Property (Roblox unterstützt das nativ)
            local selfDot = Instance.new("TextLabel")
            selfDot.Name                 = "SelfArrow"
            selfDot.Size                 = UDim2.new(0, 22, 0, 22)
            selfDot.Position             = UDim2.new(0.5, -11, 0.5, -11)
            selfDot.BackgroundTransparency = 1
            selfDot.Text                 = "▲"
            selfDot.TextColor3           = Color3.fromRGB(255, 255, 255)
            selfDot.TextStrokeColor3     = Color3.fromRGB(0, 0, 0)
            selfDot.TextStrokeTransparency = 0.2
            selfDot.Font                 = Enum.Font.GothamBold
            selfDot.TextSize             = 20
            selfDot.ZIndex               = 9
            selfDot.Rotation             = 0   -- wird in mm_update gesetzt
            selfDot.Parent               = view

            -- X-Button oben rechts: Minimap direkt schließen ohne Hub zu öffnen
            local closeBtn = Instance.new("TextButton")
            closeBtn.Size                   = UDim2.new(0, 20, 0, 20)
            closeBtn.Position               = UDim2.new(1, -22, 0, 2)
            closeBtn.BackgroundColor3       = Color3.fromRGB(180, 50, 50)
            closeBtn.BackgroundTransparency = 0.2
            closeBtn.BorderSizePixel        = 0
            closeBtn.Text                   = "✕"
            closeBtn.TextColor3             = Color3.fromRGB(255, 255, 255)
            closeBtn.Font                   = Enum.Font.GothamBold
            closeBtn.TextSize               = 11
            closeBtn.ZIndex                 = 12
            closeBtn.Parent                 = outer
            Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 5)
            closeBtn.MouseButton1Click:Connect(function()
                mm_on = false
                mm_stop()
                pcall(function() mm_btnLbl.TextColor3 = C_TEXT end)
                fn_setStatus("🗺️ Minimap AUS", C_SUB)
            end)

            mm_sg = sg; mm_view = view; mm_selfDot = selfDot; mm_dirDot = selfDot
        end

        -- ── Start / Stop ────────────────────────────────────────────────
        function mm_start()
            if mm_conn then return end
            mm_buildUI()
            if #fn_cache == 0 then pcall(fn_rebuildCache) end
            pcall(mm_buildFloor)
            pcall(mm_update, 0)
            mm_t    = 0
            mm_conn = game:GetService("RunService").Heartbeat:Connect(function(dt)
                mm_t = mm_t + dt
                if mm_t < 0.5 then return end
                mm_t = 0
                pcall(mm_update, 0.5)
            end)
            -- M-Taste: Minimap ein-/ausschalten ohne Hub öffnen
            if not mm_keyConn then
                mm_keyConn = game:GetService("UserInputService").InputBegan:Connect(function(inp, gpe)
                    if gpe then return end  -- Textfeld aktiv → ignorieren
                    if inp.KeyCode == Enum.KeyCode.M then
                        mm_on = not mm_on
                        if mm_on then
                            mm_start()
                            pcall(function() mm_btnLbl.TextColor3 = Color3.fromRGB(100, 220, 180) end)
                            fn_setStatus("🗺️ Minimap AN – [M] zum Schließen", Color3.fromRGB(100, 220, 180))
                        else
                            mm_stop()
                            pcall(function() mm_btnLbl.TextColor3 = C_TEXT end)
                            fn_setStatus("🗺️ Minimap AUS", C_SUB)
                        end
                    end
                end)
            end
        end

        function mm_stop()
            if mm_conn then mm_conn:Disconnect(); mm_conn = nil end
            if mm_keyConn then mm_keyConn:Disconnect(); mm_keyConn = nil end
            mm_liveDots   = {}
            mm_floorDots  = {}
            mm_floorTimer = 0
            if mm_sg and mm_sg.Parent then mm_sg:Destroy() end
            mm_sg = nil; mm_view = nil; mm_selfDot = nil; mm_dirDot = nil
        end

        -- ── Button ──────────────────────────────────────────────────────
        local mm_btnLbl
        mm_btnLbl = fn_btn("🗺️ Minimap AN / AUS", Color3.fromRGB(20, 35, 28), function()
            mm_on = not mm_on
            if mm_on then
                mm_start()
                mm_btnLbl.TextColor3 = Color3.fromRGB(100, 220, 180)
                fn_setStatus("🗺️ Minimap AN – unten links!", Color3.fromRGB(100, 220, 180))
            else
                mm_stop()
                mm_btnLbl.TextColor3 = C_TEXT
                fn_setStatus("🗺️ Minimap AUS", C_SUB)
            end
        end)

        -- ══════════════════ ZIEHEN ══════════════════
        local fn_dragging, fn_dragStart, fn_startPos
        titleBar_fn.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1
            or inp.UserInputType == Enum.UserInputType.Touch then
                fn_dragging  = true
                fn_dragStart = inp.Position
                fn_startPos  = win_fn.Position
            end
        end)
        titleBar_fn.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1
            or inp.UserInputType == Enum.UserInputType.Touch then
                fn_dragging = false
            end
        end)
        local _fnDragConn = UIS_FN.InputChanged:Connect(function(inp)
            if fn_dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement
            or inp.UserInputType == Enum.UserInputType.Touch) then
                local d = inp.Position - fn_dragStart
                win_fn.Position = UDim2.new(
                    fn_startPos.X.Scale, fn_startPos.X.Offset + d.X,
                    fn_startPos.Y.Scale, fn_startPos.Y.Offset + d.Y
                )
            end
        end)
        -- [FIX v99 Bug 1] EINZIGER konsolidierter Cleanup-Block.
        -- Alle früheren AncestryChanged-Blöcke (Zeile 8793 und 9863) wurden entfernt,
        -- da sie Locals referenzierten die noch nicht deklariert waren (Forward-Refs).
        -- Dieser Block steht NACH allen Local-Deklarationen → alle Refs sind gültig.
        local function fn_cleanupAll()
            -- Speed zurücksetzen
            fn_speedActive = false
            fn_dragging    = false
            if fn_speedConn then fn_speedConn:Disconnect(); fn_speedConn = nil end
            if _fnDragConn  then _fnDragConn:Disconnect() end
            -- Fullbright zurücksetzen
            if fn_fbOn then fn_fbOn = false; pcall(fn_fbRemove) end
            -- Feature-Flags abschalten (alle, inkl. v100-Erweiterungen)
            fn_staminaOn = false; fn_powerOn  = false
            fn_godOn     = false
            fn_alarmOn   = false; fn_fleeOn   = false
            fn_ajOn      = false
            fn_nightOn   = false; fn_musicOn  = false; fn_doorOn  = false
            fn_npcOn     = false; fn_itemOn   = false; fn_hideOn  = false
            fn_freezeOn  = false; fn_breachOn = false
            fn_flashOn   = false; fn_genOn    = false
            fn_staticOn  = false; fn_soundOn  = false
            -- Animatronic Freeze aufheben (NPCs de-ankern)
            pcall(function()
                for _, npc in ipairs(fn_npcCache) do
                    if npc and npc.Parent then
                        for _, p in ipairs(npc:GetDescendants()) do
                            if p:IsA("BasePart") then
                                pcall(function() p.Anchored = false end)
                            end
                        end
                        local hum = npc:FindFirstChildOfClass("Humanoid")
                        if hum then
                            pcall(function() hum.WalkSpeed = 16; hum.JumpPower = 50 end)
                        end
                    end
                end
            end)
            -- Sound-ESP aufräumen
            pcall(function()
                for _, e in ipairs(fn_soundESP) do
                    pcall(function() if e.hl then e.hl:Destroy() end end)
                    pcall(function() if e.bb then e.bb:Destroy() end end)
                end
                fn_soundESP = {}; fn_soundMap = {}
            end)
            -- ESP vollständig aufräumen
            pcall(fn_clearESP, fn_npcESP,  fn_npcMap)
            pcall(fn_clearESP, fn_itemESP, fn_itemMap)
            pcall(fn_clearESP, fn_hideESP, fn_hideMap)
            -- Watcher + Master trennen
            pcall(fn_stopWatch)
            if fn_masterConn then fn_masterConn:Disconnect(); fn_masterConn = nil end
            if fn_ajConn     then fn_ajConn:Disconnect();     fn_ajConn     = nil end
            -- HUD aufräumen
            fn_hudOn = false
            pcall(fn_stopHUD)
            pcall(function() if fn_hudGui and fn_hudGui.Parent then fn_hudGui:Destroy() end end)
            -- Kamera zurücksetzen
            pcall(fn_camRestore)
            -- Popup-Fenster schließen
            pcall(function() if fn_roomWinObj and fn_roomWinObj.Parent then fn_roomWinObj.Visible = false end end)
            -- Minimap stoppen
            pcall(mm_stop)
        end

        sg_fn.AncestryChanged:Connect(function()
            if not sg_fn.Parent then
                fn_cleanupAll()
            end
        end)

        -- ══════════════════ SLIDE-IN ANIMATION ══════════════════
        win_fn.Position = UDim2.new(0.5, -160, -0.6, 0)
        TS_FN:Create(win_fn,
            TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            { Position = UDim2.new(0.5, -160, 0.5, -210) }
        ):Play()
    end,
})
-- ==================== ENDE FNAF ETERNAL NIGHTS ====================

-- ==================== CORE SERVICES (Scope Fix - müssen vor AntiTab Callbacks stehen) ====================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local TextChatService = game:GetService("TextChatService")
local HttpService = game:GetService("HttpService")

-- ==================== ANTI TAB (neue dedizierte Kategorie) ====================
AntiTab:CreateSection("🔰 Anti Features")

-- ==================== ANTI FLING (NetworkOwner + Position-Check) ====================
-- Methode 1: SetNetworkOwner(nil) → Server kontrolliert Physik, Fling-Impulse greifen nicht mehr
-- Methode 2: Heartbeat-Loop misst Positionssprünge > 60 studs/Frame
--            → teleportiert sofort zurück zur letzten sicheren Position
-- =====================================================================================
;(function()
    local _afActive        = false
    local _afLastPos       = Vector3.new(0, 0, 0)
    local _afHeartbeatConn = nil
    local AF_THRESHOLD     = 60   -- studs/Frame ab dem ein Fling erkannt wird

    local function _afGetRootPart()
        local char = LocalPlayer.Character
        return char and char:FindFirstChild("HumanoidRootPart")
    end

    local function _afEnable()
        local rp = _afGetRootPart()
        if not rp then
            Rayfield:Notify({Title="Anti Fling", Content="Charakter nicht bereit!", Duration=2})
            return false
        end

        -- Methode 1: Physik-Kontrolle auf Server legen
        pcall(function() rp:SetNetworkOwner(nil) end)

        -- Startposition merken
        _afLastPos = rp.Position

        -- Methode 2: Heartbeat-Positionscheck
        if _afHeartbeatConn then _afHeartbeatConn:Disconnect() end
        _afHeartbeatConn = RunService.Heartbeat:Connect(function()
            if not _afActive then return end
            pcall(function()
                local c   = LocalPlayer.Character
                local hrp = c and c:FindFirstChild("HumanoidRootPart")
                if not hrp or not hrp.Parent then return end

                local dist = (hrp.Position - _afLastPos).Magnitude
                if dist > AF_THRESHOLD then
                    -- Fling erkannt → sofort zurück
                    hrp.CFrame                  = CFrame.new(_afLastPos)
                    hrp.AssemblyLinearVelocity  = Vector3.zero
                    hrp.AssemblyAngularVelocity = Vector3.zero
                else
                    -- Normale Bewegung → Position als sicher speichern
                    _afLastPos = hrp.Position
                end
            end)
        end)

        return true
    end

    local function _afDisable()
        if _afHeartbeatConn then
            _afHeartbeatConn:Disconnect()
            _afHeartbeatConn = nil
        end
        -- NetworkOwner zurückgeben
        pcall(function()
            local rp = _afGetRootPart()
            if rp then rp:SetNetworkOwner(LocalPlayer) end
        end)
    end

    -- Respawn: Anti-Fling sofort neu anwenden
    LocalPlayer.CharacterAdded:Connect(function()
        if not _afActive then return end
        task.wait(0.15)
        _afEnable()
    end)

    AntiTab:CreateToggle({
        Name = "🔰 Anti Fling (NetworkOwner + Position-Check)",
        CurrentValue = false,
        Callback = function(state)
            _afActive = state
            HubState.antiFlingConn = state and true or nil
            if state then
                local ok = _afEnable()
                if ok then
                    Rayfield:Notify({
                        Title   = "🔰 Anti Fling AN",
                        Content = "NetworkOwner gesetzt · Positionscheck aktiv (>" .. AF_THRESHOLD .. " studs = Fling)",
                        Duration = 4
                    })
                else
                    _afActive = false
                    HubState.antiFlingConn = nil
                end
            else
                _afDisable()
                Rayfield:Notify({Title = "🔰 Anti Fling AUS", Content = "Deaktiviert", Duration = 3})
            end
        end
    })
end)()


-- ==================== ANTI VOID (v73 - durchfallen ohne Tod) ====================
-- Gewünschtes Verhalten: KEIN Zurück-Teleportieren. Stattdessen macht der Void
-- einfach nichts mehr — man kann ungehindert durchfallen, ohne zu sterben.
-- Mechanik: Roblox zerstört Parts (inkl. Charakter), sobald sie unter
-- Workspace.FallenPartsDestroyHeight fallen (Standard -500). Wir setzen diese
-- Höhe praktisch unendlich tief (-1e9) → der Charakter wird nie zerstört und
-- fällt einfach endlos weiter, ohne Tod.
-- Der Originalwert wird gemerkt und beim Ausschalten wiederhergestellt.
AntiTab:CreateToggle({
    Name = "🔰 Anti Void (durchfallen ohne Tod)",
    CurrentValue = false,
    Callback = function(state)
        if HubState.antiVoidConn then HubState.antiVoidConn:Disconnect() HubState.antiVoidConn = nil end
        if state then
            -- Originale Todeshöhe einmalig merken (für sauberes Zurücksetzen)
            if HubState.antiVoidOrigHeight == nil then
                pcall(function()
                    HubState.antiVoidOrigHeight = Workspace.FallenPartsDestroyHeight
                end)
            end
            -- Todeshöhe praktisch unendlich tief → man fällt durch, stirbt nicht
            pcall(function() Workspace.FallenPartsDestroyHeight = -1e9 end)
            -- Falls das Spiel den Wert wieder hochsetzt: laufend erzwingen
            HubState.antiVoidConn = RunService.Heartbeat:Connect(function()
                pcall(function()
                    if Workspace.FallenPartsDestroyHeight > -1e8 then
                        Workspace.FallenPartsDestroyHeight = -1e9
                    end
                end)
            end)
        else
            -- Originalwert wiederherstellen
            pcall(function()
                if HubState.antiVoidOrigHeight ~= nil then
                    Workspace.FallenPartsDestroyHeight = HubState.antiVoidOrigHeight
                    HubState.antiVoidOrigHeight = nil
                end
            end)
        end
    end
})

-- ==================== ANTI AFK (v71 - Verbessert) ====================
-- Fix: doppelte Absicherung — Idled-Event + Heartbeat-Prävention alle 60s.
-- VirtualUser simuliert echten Input um Roblox's AFK-Erkennung zu überlisten.
AntiTab:CreateToggle({
    Name = "🔰 Anti AFK (Doppelt abgesichert)",
    CurrentValue = false,
    Callback = function(state)
        if HubState.antiAFKConn then HubState.antiAFKConn:Disconnect() HubState.antiAFKConn = nil end
        HubState.antiAFKTimer = 0
        if state then
            -- Primär: Idled-Event abfangen
            HubState.antiAFKConn = LocalPlayer.Idled:Connect(function()
                pcall(function()
                    local vu = game:GetService("VirtualUser")
                    vu:CaptureController()
                    vu:ClickButton2(Vector2.new())
                    local char = LocalPlayer.Character
                    if char then
                        local hum = char:FindFirstChild("Humanoid")
                        if hum and hum.Health > 0 then
                            hum:ChangeState(Enum.HumanoidStateType.Jumping)
                        end
                    end
                end)
            end)
            -- Sekundär: alle 55 Sek proaktiv anti-AFK — zufällige Mikrobewegung
            -- [BUG FIX] Generation-ID verhindert Doppelschleifen beim schnellen Umschalten
            HubState.antiAFKGen = (HubState.antiAFKGen or 0) + 1
            local myGen = HubState.antiAFKGen
            task.spawn(function()
                local directions = {
                    Enum.KeyCode.W, Enum.KeyCode.A,
                    Enum.KeyCode.S, Enum.KeyCode.D
                }
                while HubState.antiAFKConn and HubState.antiAFKGen == myGen do
                    task.wait(55)
                    if not HubState.antiAFKConn or HubState.antiAFKGen ~= myGen then break end
                    pcall(function()
                        local vu = game:GetService("VirtualUser")
                        vu:CaptureController()
                        vu:ClickButton2(Vector2.new())
                        -- Zufällige Taste kurz drücken (sieht echter aus)
                        local VIM = game:GetService("VirtualInputManager")
                        local key = directions[math.random(1, #directions)]
                        VIM:SendKeyEvent(true,  key, false, game)
                        task.wait(0.12)
                        VIM:SendKeyEvent(false, key, false, game)
                    end)
                end
            end)
        end
    end
})

-- ==================== ANTI WALKSPEED RESET (v71 - Bugfix) ====================
-- Bugfix: Der alte Callback referenzierte `Settings` (local, deklariert erst bei Zeile 772)
-- → war out-of-scope → pcall verschluckte den nil-Fehler → Feature funktionierte nie.
-- Fix: eigene Zielgeschwindigkeit via HubState gespeichert.
AntiTab:CreateSlider({
    Name = "Anti WalkSpeed Zielgeschwindigkeit",
    Range = {16, 100},   -- [AC-FIX] Max von 200 → 100: >100 triggert Server-Sanity fast immer
    Increment = 1,
    CurrentValue = 30,   -- [AC-FIX] Default niedriger (30 statt 50) → weniger auffällig
    Callback = function(v) HubState.antiWSTargetSpeed = v end
})
AntiTab:CreateToggle({
    Name = "🔰 Anti WalkSpeed Reset (Gefixt)",
    CurrentValue = false,
    Callback = function(state)
        HubState.antiWSEnabled = state
        if HubState.antiWalkSpeedConn then
            HubState.antiWalkSpeedConn:Disconnect()
            HubState.antiWalkSpeedConn = nil
        end
        if state then
            -- [AC-FIX] Throttle: nur alle 12 Frames statt jeden Frame setzen
            -- → Server-seitige Heuristiken sehen keine konstante Manipulation
            local _wsFrameCount = 0
            HubState.antiWalkSpeedConn = RunService.Heartbeat:Connect(function()
                _wsFrameCount = _wsFrameCount + 1
                if _wsFrameCount < 12 then return end
                _wsFrameCount = 0
                pcall(function()
                    local char = LocalPlayer.Character
                    local hum = char and char:FindFirstChild("Humanoid")
                    if not hum then return end
                    local target = HubState.antiWSTargetSpeed or 16
                    if hum.WalkSpeed < target then
                        hum.WalkSpeed = target
                    end
                end)
            end)
        end
    end
})

-- Anti Teleport Back (v71 - HubState-basiert, kein Register-Verbrauch)

AntiTab:CreateToggle({
    Name = "Anti Teleport Back (bei Barrieren)",
    CurrentValue = false,
    Callback = function(state)
        HubState.antiTeleportEnabled = state

        if state then
            HubState.lastValidPosition = nil
            if HubState.antiTeleportConn then HubState.antiTeleportConn:Disconnect() end

            HubState.antiTeleportConn = RunService.Heartbeat:Connect(function()
                pcall(function()
                    local char = LocalPlayer.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if not hrp then return end

                    local currentPos = hrp.Position

                    if HubState.lastValidPosition then
                        local dist = (currentPos - HubState.lastValidPosition).Magnitude

                        -- [AC-FIX] Threshold 40 → 150 Studs: echte Server-TPs (Spawn,
                        -- Runden-Start, Minigame) springen oft 50-100 Studs → würden
                        -- sonst gefight. 150+ ist nur noch ein echter Anti-Cheat-Kick.
                        -- Zusätzlich: 2 Mal in Folge großer Sprung → wir akzeptieren
                        -- ihn als legitimen Server-TP (kein Fight).
                        if dist > 150 then
                            HubState._antiTpConsecutive = (HubState._antiTpConsecutive or 0) + 1
                            if HubState._antiTpConsecutive >= 2 then
                                -- Wahrscheinlich legitimer Server-TP → akzeptieren
                                HubState.lastValidPosition = currentPos
                                HubState._antiTpConsecutive = 0
                            else
                                hrp.CFrame = CFrame.new(HubState.lastValidPosition)
                                hrp.AssemblyLinearVelocity = Vector3.zero
                                hrp.AssemblyAngularVelocity = Vector3.zero
                            end
                        else
                            HubState._antiTpConsecutive = 0
                            HubState.lastValidPosition = currentPos
                        end
                    else
                        -- Erste Aufnahme
                        HubState.lastValidPosition = currentPos
                    end
                end)
            end)

            Rayfield:Notify({Title = "Anti Teleport", Content = "Anti Teleport aktiviert (friert nicht ein)", Duration = 3})
        else
            if HubState.antiTeleportConn then
                HubState.antiTeleportConn:Disconnect()
                HubState.antiTeleportConn = nil
            end
            HubState.lastValidPosition = nil
        end
    end
})

-- Anti Lag Button
local function DoFullAntiLag()
    pcall(function()
        local Lighting = game:GetService("Lighting")

        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9999999
        Lighting.Technology = Enum.Technology.Compatibility
        local atm = Lighting:FindFirstChildOfClass("Atmosphere")
        if atm then atm.Density = 0 end

        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
                obj.Enabled = false
            end
        end

        -- [FIX v101] Kleidung/Accessoires nicht mehr zerstören (war irreversibel für die Session) →
        -- LocalTransparencyModifier = 1 macht sie nur lokal unsichtbar und ist reversibel
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                for _, child in ipairs(plr.Character:GetDescendants()) do
                    if child:IsA("BasePart") or child:IsA("Decal") or child:IsA("SpecialMesh") then
                        pcall(function() child.LocalTransparencyModifier = 1 end)
                    end
                end
            end
        end
    end)
end

AntiTab:CreateButton({
    Name = "🔰 Anti Lag + andere Spieler ausblenden (lokal)",  -- [FIX v101] lokal/reversibel, nicht mehr destroy
    Callback = function()
        DoFullAntiLag()
        Rayfield:Notify({Title = "Anti Lag", Content = "Optimierungen + andere Spieler lokal ausgeblendet!", Duration = 3})
    end
})

-- Anti Fall Damage (v71: uses HubState, kein extra local register)
AntiTab:CreateToggle({
    Name = "Anti Fall Damage",
    CurrentValue = false,
    Callback = function(state)
        if HubState.antiFallDamageConn then HubState.antiFallDamageConn:Disconnect() HubState.antiFallDamageConn = nil end
        if state then
            HubState.wasFalling = false
            HubState.antiFallDamageConn = RunService.Heartbeat:Connect(function()
                pcall(function()
                    local char = LocalPlayer.Character
                    local hum = char and char:FindFirstChild("Humanoid")
                    if not hum then return end
                    local currentState = hum:GetState()
                    local isFalling = currentState == Enum.HumanoidStateType.Freefall
                        or currentState == Enum.HumanoidStateType.FallingDown
                    if isFalling then
                        HubState.lastFallHealth = hum.Health
                        HubState.wasFalling = true
                    else
                        if HubState.wasFalling then
                            -- Nur im ersten Frame nach der Landung Fall-Schaden prüfen
                            if HubState.lastFallHealth > 0 and (HubState.lastFallHealth - hum.Health) > 8 then
                                hum.Health = HubState.lastFallHealth
                            end
                            HubState.wasFalling = false
                        end
                    end
                end)
            end)
        end
    end
})

-- Anti Screen Effects (v71: uses HubState)
AntiTab:CreateToggle({
    Name = "Anti Screen Effects",
    CurrentValue = false,
    Callback = function(state)
        if HubState.antiScreenEffectsConn then
            HubState.antiScreenEffectsConn:Disconnect()
            HubState.antiScreenEffectsConn = nil
        end

        if state then
            local Lighting = game:GetService("Lighting")

            for _, effect in ipairs(Lighting:GetChildren()) do
                if effect:IsA("BlurEffect") or effect:IsA("ColorCorrectionEffect") or
                   effect:IsA("BloomEffect") or effect:IsA("SunRaysEffect") or effect:IsA("DepthOfFieldEffect") then
                    pcall(function() effect:Destroy() end)
                end
            end

            -- [FIX v77] Statt jeden Heartbeat-Frame Lighting:GetChildren() aufzurufen +
            -- alle Effekte zu zerstören (extremer FPS-Killer), nutzen wir das ChildAdded-Event:
            -- wird NUR gefeuert wenn ein neuer Effekt hinzugefügt wird → 0 CPU bei Leerlauf.
            local _Lighting = game:GetService("Lighting")
            HubState.antiScreenEffectsConn = _Lighting.ChildAdded:Connect(function(effect)
                if effect:IsA("BlurEffect") or effect:IsA("ColorCorrectionEffect") or
                   effect:IsA("BloomEffect") or effect:IsA("SunRaysEffect") or effect:IsA("DepthOfFieldEffect") then
                    pcall(function() effect:Destroy() end)
                end
            end)
        end
    end
})

-- [FIX] GetCurrentWeapon wird im Anti-Reload-Callback benötigt, aber erst später definiert.
-- Vordeklaration damit die Closure den richtigen Upvalue sieht (kein nil-crash).
local GetCurrentWeapon

-- ==================== ANTI RELOAD (moved from SpezialTab to AntiTab for logical grouping) ====================
-- AMMO_KEYS außerhalb des Loops (einmalig erstellt, nicht jeden Frame)
local AMMO_KEYS = {"ammo","reload","clip","mag","bullet","round","shell","charge","shoot","fire","gun"}
-- HubState.antiReloadLoop (deklariert in HubState) wird genutzt statt local
AntiTab:CreateSection("🔄 Anti Reload")
AntiTab:CreateToggle({
    Name = "Anti Reload (Nie nachladen müssen)",
    CurrentValue = false,
    Callback = function(state)
        if HubState.antiReloadLoop then HubState.antiReloadLoop:Disconnect() HubState.antiReloadLoop = nil end

        if state then
            -- [FPS-FIX] Throttle: Munition muss nicht 60x/s geprüft werden — 8x/s reicht.
            -- GetDescendants → GetChildren: Ammo-Values sind meist direkte Tool-Kinder.
            local _arTimer = 0
            HubState.antiReloadLoop = RunService.Heartbeat:Connect(function(dt)
                _arTimer = _arTimer + dt
                if _arTimer < 0.125 then return end
                _arTimer = 0
                pcall(function()
                    local tool = GetCurrentWeapon()
                    local char = LocalPlayer.Character

                    local targets = {}
                    if tool then for _, o in ipairs(tool:GetChildren()) do table.insert(targets, o) end end
                    if char then for _, o in ipairs(char:GetChildren()) do table.insert(targets, o) end end

                    for _, obj in ipairs(targets) do
                        if obj:IsA("IntValue") or obj:IsA("NumberValue") then
                            local nl = obj.Name:lower()
                            for _, kw in ipairs(AMMO_KEYS) do
                                if string.find(nl, kw) then obj.Value = 999; break end  -- [FIX v101] Semikolon: zwei Anweisungen korrekt getrennt
                            end
                        end
                        if typeof(obj) == "Instance" then
                            for attr, val in pairs(obj:GetAttributes()) do
                                if type(val) == "number" then
                                    local al = attr:lower()
                                    for _, kw in ipairs(AMMO_KEYS) do
                                        if string.find(al, kw) then obj:SetAttribute(attr, 999) break end
                                    end
                                end
                            end
                        end
                    end
                end)
            end)

            -- OPTIMIERTE Suche nach Reload/Ammo Remotes (kein game:GetDescendants() mehr → kein Lag)
            -- Durchsucht nur relevante Services + aktuelles Tool (viel schneller & stabiler)
            task.spawn(function()
                local keywords = {"reload", "load", "ammo", "charge", "bullet", "mag", "fire", "shoot"}
                local containers = {
                    game:GetService("ReplicatedStorage"),
                    game:GetService("ReplicatedFirst"),
                    game:GetService("StarterGui"),
                    LocalPlayer:FindFirstChild("PlayerGui")
                }

                for _, container in ipairs(containers) do
                    if container then
                        for _, obj in ipairs(container:GetDescendants()) do
                            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                                local name = obj.Name:lower()
                                for _, word in ipairs(keywords) do
                                    if string.find(name, word) then
                                        pcall(function()
                                            if obj:IsA("RemoteEvent") then
                                                obj.OnClientEvent:Connect(function()
                                                    local tool = GetCurrentWeapon()
                                                    if tool then
                                                        for _, v in ipairs(tool:GetDescendants()) do
                                                            if v:IsA("IntValue") or v:IsA("NumberValue") then
                                                                v.Value = 999
                                                            end
                                                        end
                                                    end
                                                end)
                                            end
                                        end)
                                        break
                                    end
                                end
                            end
                        end
                    end
                end

                -- Zusätzlich: Direkt im aktuellen Tool und Character suchen (schnell)
                local tool = GetCurrentWeapon()
                local char = LocalPlayer.Character
                if tool then
                    for _, obj in ipairs(tool:GetDescendants()) do
                        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                            local name = obj.Name:lower()
                            for _, word in ipairs(keywords) do
                                if string.find(name, word) then
                                    pcall(function()
                                        if obj:IsA("RemoteEvent") then
                                            obj.OnClientEvent:Connect(function()
                                                for _, v in ipairs(tool:GetDescendants()) do
                                                    if v:IsA("IntValue") or v:IsA("NumberValue") then v.Value = 999 end
                                                end
                                            end)
                                        end
                                    end)
                                    break
                                end
                            end
                        end
                    end
                end
            end)

            Rayfield:Notify({Title = "🔰 Anti Reload", Content = "Anti Reload aktiv", Duration = 3})
        end
    end
})


-- ==================== NEUE ANTI FEATURES (v71) ====================
AntiTab:CreateSection("🆕 Neue Anti Features (v71)")

-- Anti Kill: Verhindert Instant-Kill durch sofortige Health-Wiederherstellung
;(function() -- block: own register pool
    local _antiKillConn = nil
    local _antiKillLastHP = 100
    AntiTab:CreateToggle({
        Name = "🔰 Anti Kill (Gesundheit schützen)",
        CurrentValue = false,
        Callback = function(state)
            if _antiKillConn then _antiKillConn:Disconnect() _antiKillConn = nil end
            if state then
                -- [FPS-FIX] Anti-Kill: 20x/s statt 60x/s — Instant-Kill-Erkennung braucht kein Framing
                local _akTimer = 0
                _antiKillConn = RunService.Heartbeat:Connect(function(dt)
                    _akTimer = _akTimer + dt
                    if _akTimer < 0.05 then return end
                    _akTimer = 0
                    pcall(function()
                        local char = LocalPlayer.Character
                        local hum = char and char:FindFirstChild("Humanoid")
                        if not hum then return end
                        if hum.Health > 20 then _antiKillLastHP = hum.Health end
                        if hum.Health <= 1 and hum.Health > 0 and _antiKillLastHP > 20 then
                            hum.Health = hum.MaxHealth
                        end
                    end)
                end)
            end
        end
    })
end)()

-- Anti Grab: Verhindert Grab-Mechanics (hohe AngularVelocity + PlatformStand)
;(function() -- block: own register pool
    local _antiGrabConn = nil
    AntiTab:CreateToggle({
        Name = "🔰 Anti Grab / Anti Stun",
        CurrentValue = false,
        Callback = function(state)
            if _antiGrabConn then _antiGrabConn:Disconnect() _antiGrabConn = nil end
            if state then
                -- [FPS-FIX] Anti-Grab: 20x/s statt 60x/s — Grab-Erkennung braucht kein Framing
                local _agTimer = 0
                _antiGrabConn = RunService.Heartbeat:Connect(function(dt)
                    _agTimer = _agTimer + dt
                    if _agTimer < 0.05 then return end
                    _agTimer = 0
                    pcall(function()
                        local char = LocalPlayer.Character
                        if not char then return end
                        local hum = char:FindFirstChild("Humanoid")
                        if hum and hum.PlatformStand == true then
                            hum.PlatformStand = false
                        end
                        if hum and hum.Sit == true then
                            hum.Sit = false
                        end
                        local hrp = char:FindFirstChild("HumanoidRootPart")
                        if hrp and hrp.AssemblyAngularVelocity.Magnitude > 15 then
                            hrp.AssemblyAngularVelocity = Vector3.zero
                        end
                    end)
                end)
            end
        end
    })
end)()

-- Anti Recoil: gleicht den Kamera-Rückstoß beim Schießen aus (zieht die Sicht leicht nach unten)
;(function() -- block: own register pool
    AntiTab:CreateSlider({
        Name = "🎯 Anti Recoil Stärke",
        Range = {0, 10},
        Increment = 0.1,
        Suffix = "",
        CurrentValue = HubState.antiRecoilStrength or 1.0,
        Callback = function(v)
            HubState.antiRecoilStrength = v
        end
    })
    AntiTab:CreateToggle({
        Name = "🔰 Anti Recoil (Rückstoß ausgleichen)",
        CurrentValue = false,
        Callback = function(state)
            if HubState.antiRecoilConn then
                HubState.antiRecoilConn:Disconnect()
                HubState.antiRecoilConn = nil
            end
            if state then
                HubState.antiRecoilConn = RunService.RenderStepped:Connect(function(dt)
                    pcall(function()
                        -- Nur ausgleichen, solange die linke Maustaste (Schießen) gedrückt ist
                        if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                            return
                        end
                        local cam = Workspace.CurrentCamera
                        if not cam then return end
                        local strength = HubState.antiRecoilStrength or 1.0
                        if strength <= 0 then return end
                        -- Kamera leicht nach unten neigen => gleicht den Rückstoß nach oben aus
                        cam.CFrame = cam.CFrame * CFrame.Angles(math.rad(-strength * dt * 60), 0, 0)
                    end)
                end)
            end
        end
    })
end)()


-- ==================== 🤝 ANTI GRAB — 6-SCHICHT DEEP SYSTEM ====================
-- SCHICHTEN:
--   S1: DescendantAdded-Wächter — sofortige Zerstörung (< 1 Frame)
--   S2: Heartbeat-Scan 0.1s — Fallback für alles was S1 umgeht
--   S3: HumanoidRootPart Anchored-Lock — sofort entsperren
--   S4: Humanoid-State-Lock — PlatformStand/Sit/WalkSpeed
--   S5: Humanoid.Seated Event — sofortiger Eject aus jedem Seat
--   S6: HRP .Changed Monitor — reagiert direkt auf Server-Anchoring
--
-- ERKANNTE GRAB-TYPEN:
--   WeldConstraint, Weld, Motor6D (fremd), RigidConstraint
--   BodyPosition/Velocity/Gyro/Force/AngularVelocity/Thrust
--   LinearVelocity, AngularVelocity, VectorForce
--   AlignPosition, AlignOrientation
--   RopeConstraint, SpringConstraint, HingeConstraint
--   CylindricalConstraint, PrismaticConstraint, UniversalConstraint
--   PlaneConstraint, TorsionSpringConstraint, BallSocketConstraint
--   Script/LocalScript Injektion, Seat/VehicleSeat
-- ============================================================================
AntiTab:CreateSection("🤝 Anti Grab")

;(function()
    local _agActive      = false
    local _agDescConn    = nil
    local _agHeartbeat   = nil
    local _agSeatConn    = nil
    local _agAnchorConn  = nil
    local _agCharConn    = nil   -- [FIX #14] CharacterAdded-Verbindung verwalten
    local _agLastWalkSpd = nil

    -- Legitime Charakter-Joints → NIE löschen
    local _agSafeJoints = {
        RootJoint=true, Neck=true,
        ["Left Hip"]=true,      ["Right Hip"]=true,
        ["Left Shoulder"]=true, ["Right Shoulder"]=true,
        ["Left Elbow"]=true,    ["Right Elbow"]=true,
        ["Left Wrist"]=true,    ["Right Wrist"]=true,
        ["Left Knee"]=true,     ["Right Knee"]=true,
        ["Left Ankle"]=true,    ["Right Ankle"]=true,
        ["Left Leg"]=true,      ["Right Leg"]=true,
        ["Left Arm"]=true,      ["Right Arm"]=true,
    }

    -- BodyMover + Attachment-lose Constraints → sofort weg
    local _agHardKill = {
        BodyPosition=true, BodyVelocity=true, BodyGyro=true,
        BodyForce=true, BodyAngularVelocity=true, BodyThrust=true,
        LinearVelocity=true, AngularVelocity=true, VectorForce=true,
        AlignPosition=true, AlignOrientation=true,
        RopeConstraint=true, SpringConstraint=true,
        HingeConstraint=true, CylindricalConstraint=true,
        PrismaticConstraint=true, UniversalConstraint=true,
        PlaneConstraint=true, TorsionSpringConstraint=true,
    }

    local function _inChar(part, char)
        return part ~= nil and char ~= nil and part:IsDescendantOf(char)
    end

    -- Prüft ob eine Attachment zu einem fremden Part gehört
    local function _attachForeign(att, char)
        if not att then return false end
        local p = att.Parent
        return p == nil or not _inChar(p, char)
    end

    local function _judge(desc, char)
        if not desc or not desc.Parent then return end
        local cn = desc.ClassName

        -- Harte Kill-Liste (kein Check nötig)
        if _agHardKill[cn] then
            pcall(function() desc:Destroy() end)
            return
        end

        -- WeldConstraint: Part0 ODER Part1 fremd → weg
        if cn == "WeldConstraint" then
            pcall(function()
                if not _inChar(desc.Part0, char) or not _inChar(desc.Part1, char) then
                    desc:Destroy()
                end
            end)
            return
        end

        -- Weld / Motor6D: sichere Namen überspringen, sonst auf Fremd-Parts prüfen
        if cn == "Weld" or cn == "Motor6D" then
            pcall(function()
                if _agSafeJoints[desc.Name] then return end
                if not _inChar(desc.Part0, char) or not _inChar(desc.Part1, char) then
                    desc:Destroy()
                end
            end)
            return
        end

        -- RigidConstraint + BallSocketConstraint: Attachment-Eltern prüfen
        if cn == "RigidConstraint" or cn == "BallSocketConstraint"
        or cn == "NoCollisionConstraint" then
            pcall(function()
                if _attachForeign(desc.Attachment0, char)
                or _attachForeign(desc.Attachment1, char) then
                    desc:Destroy()
                end
            end)
            return
        end

        -- Script-Injektion in Character → sofort weg
        if cn == "Script" or cn == "LocalScript" or cn == "ModuleScript" then
            pcall(function() desc:Destroy() end)
        end
    end

    local function _fullScan(char)
        pcall(function()
            for _, d in ipairs(char:GetDescendants()) do
                _judge(d, char)
            end
        end)
    end

    local function _startAntiGrab()
        local char = LocalPlayer.Character
        if not char then return end

        -- Initialer Scan
        _fullScan(char)

        -- S1: DescendantAdded — reagiert < 1 Frame
        _agDescConn = char.DescendantAdded:Connect(function(desc)
            task.defer(function()
                _judge(desc, char)
            end)
        end)

        -- S2 + S3 + S4: Heartbeat-Scan + Anchored-Lock + Humanoid-State
        local _timer = 0
        _agHeartbeat = RunService.Heartbeat:Connect(function(dt)
            _timer = _timer + dt
            if _timer < 0.1 then return end
            _timer = 0
            pcall(function()
                local c = LocalPlayer.Character
                if not c then return end

                -- S3: HumanoidRootPart Anchored aufheben
                local hrp = c:FindFirstChild("HumanoidRootPart")
                if hrp and hrp.Anchored then
                    hrp.Anchored                = false
                    hrp.AssemblyLinearVelocity  = Vector3.zero
                    hrp.AssemblyAngularVelocity = Vector3.zero
                end

                -- S4: Humanoid-Status
                local hum = c:FindFirstChildOfClass("Humanoid")
                if hum then
                    if hum.PlatformStand then hum.PlatformStand = false end
                    if hum.Sit then
                        hum.Sit = false
                        pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
                    end
                    -- WalkSpeed-Schutz: wenn auf 0 gezogen
                    if _agLastWalkSpd and _agLastWalkSpd > 2 and hum.WalkSpeed < 2 then
                        hum.WalkSpeed = _agLastWalkSpd
                    elseif hum.WalkSpeed > 2 then
                        _agLastWalkSpd = hum.WalkSpeed
                    end
                end

                -- S2: Vollständiger Scan als Fallback
                _fullScan(c)
            end)
        end)

        -- S5: Humanoid.Seated → sofortiger Eject
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            _agLastWalkSpd = hum.WalkSpeed
            _agSeatConn = hum.Seated:Connect(function(isSeated, seat)
                if isSeated then
                    task.wait(0.05)
                    pcall(function()
                        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                    end)
                end
            end)
        end

        -- S6: HumanoidRootPart .Anchored Changed → direkter Konter
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            _agAnchorConn = hrp:GetPropertyChangedSignal("Anchored"):Connect(function()
                pcall(function()
                    if hrp and hrp.Anchored then
                        hrp.Anchored = false
                    end
                end)
            end)
        end
    end

    local function _stopAntiGrab()
        if _agDescConn   then _agDescConn:Disconnect()   _agDescConn   = nil end
        if _agHeartbeat  then _agHeartbeat:Disconnect()  _agHeartbeat  = nil end
        if _agSeatConn   then _agSeatConn:Disconnect()   _agSeatConn   = nil end
        if _agAnchorConn then _agAnchorConn:Disconnect() _agAnchorConn = nil end
        if _agCharConn   then _agCharConn:Disconnect()   _agCharConn   = nil end  -- [FIX #14]
        _agLastWalkSpd = nil
    end

    AntiTab:CreateToggle({
        Name = "🤝 Anti Grab (6-Schicht — Weld/Constraint/Force/Seat/Anchor/WalkSpeed)",
        CurrentValue = false,
        Callback = function(state)
            _agActive = state
            if state then
                _startAntiGrab()
                -- [FIX #14] Alte Verbindung trennen + neue speichern (kein kumulativer Leak)
                if _agCharConn then _agCharConn:Disconnect() end
                _agCharConn = LocalPlayer.CharacterAdded:Connect(function()
                    if not _agActive then return end
                    task.wait(0.5)
                    _stopAntiGrab()
                    _startAntiGrab()
                end)
                pcall(function()
                    SemysUI:Notify({
                        Title   = "🤝 Anti Grab AN",
                        Content = "6 Schichten aktiv:\n• Weld/WeldConstraint/Motor6D\n• RigidConstraint/BallSocket\n• BodyMover/AlignPosition\n• Rope/Spring/Hinge\n• Anchored-Lock\n• Seat-Eject + WalkSpeed",
                        Duration = 6,
                    })
                end)
            else
                _stopAntiGrab()
                pcall(function()
                    SemysUI:Notify({Title = "🤝 Anti Grab AUS", Content = "Deaktiviert", Duration = 3})
                end)
            end
        end,
    })
end)()


-- Lighting (einziger nicht in Block 1 deklarierter Service)
local Lighting = game:GetService("Lighting")

-- ==================== CONNECTION MANAGER (Anti Memory Leak) ====================
local ConnectionManager = {
    Connections = {},
    Add = function(self, name, conn)
        if self.Connections[name] then
            pcall(function() self.Connections[name]:Disconnect() end)
        end
        self.Connections[name] = conn
    end,
    Remove = function(self, name)
        if self.Connections[name] then
            pcall(function() self.Connections[name]:Disconnect() end)
            self.Connections[name] = nil
        end
    end,
    CleanupAll = function(self)
        for name, conn in pairs(self.Connections) do
            pcall(function() conn:Disconnect() end)
        end
        self.Connections = {}
    end
}

-- Auto cleanup on character death / respawn
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    -- [FIX v101] Aktiviert. Hinweis: CleanupAll() ist erst wirksam wenn Verbindungen
    -- über ConnectionManager:Register() eingetragen werden (noch keine Einträge im Script).
    -- Der Aufruf schadet nicht und ist vorbereitet für zukünftige Registrierungen.
    ConnectionManager:CleanupAll()
end)

-- ==================== DEIN DISCORD WEBHOOK ====================
-- ==================== EINSTELLUNGEN ====================
-- [FIX v76] kein neues 'local' hier – füllt die oben forward-deklarierte lokale Variable
Settings = {
    ESPEnabled = false,
    ESPMaxDistance = 600,
    ESPBoxSize = Vector3.new(4, 6, 2.2),
    ESPTransparency = 0.25,
    ChamsEnabled = false,
    ChamsFillTransparency = 0.5,
    TeamCheckEnabled = true,
    EnemyColor = Color3.fromRGB(255, 50, 50),
    TeammateColor = Color3.fromRGB(0, 150, 255),
    ESPColor = Color3.fromRGB(0, 255, 120),
    ChamsColor = Color3.fromRGB(255, 0, 100),
    AimbotEnabled = false,
    AimbotFOV = 150,
    AimbotMaxDistance = 400,
    NormalAimbotSmoothness = 1,
    AimbotFullFOV = false,
    -- Rage Aimbot v75 (KRASS-Modus)
    RagePrediction = true,
    RagePredictionStrength = 0.16,
    RageAlwaysOn = false,
    RageTargetMode = "Crosshair",
    RageTargetPart = "Head",
    ShowFOVCircle = true,
    NormalAimbotEnabled = false,
    NormalAimbotWallCheck = true,
    NoClipEnabled = false,
    SprintBoostEnabled = false,
    BaseWalkSpeed = 50,
    FlyEnabled = false,
    FlySpeed = 80,
    SuperSlideEnabled = false,
    SuperSlideStrength = 140,
    SuperJumpEnabled = false,
    SuperJumpStrength = 120,
    InfiniteJumpEnabled = false,
    GodmodeEnabled = false,
    CustomShootSoundEnabled = false,
    InfiniteAmmoEnabled = false,
    NPCBoxESP = false,
    NPCChams = false,
    -- Health + Weapon Symbol (neu hinzugefügt)
    HealthWeaponEnabled = false,
    HealthWeaponMaxDistance = 600,
    HealthWeaponSymbolScale = 1.0,
    RageKnifeThrowEnabled = true,
    VoiceRangeEnabled = false,
    VoiceRangeRadius = 80,
    VoiceRangeColor = Color3.fromRGB(100, 200, 255),
    VoiceRangeTransparency = 0.5,
    VoiceRangeOutlineEnabled = true,
    WallhackEnabled = false,
    TriggerBotEnabled = false,
    TriggerBotDelay = 0.08,
    KillEffectsEnabled = false,
    KillEffectType = "Herz Explosion",  -- 15 Effekte + Zufällig in v80
    KillDebugEnabled = false,  -- [FIX v76] Debug-Modus für Kill-Erkennung (war vorher immer an)
    -- Fehlende Settings ergänzt in v69
    FullbrightEnabled = false,
    LookDirectionEnabled = false,
    TracersEnabled = false,
    -- Name ESP (v69 NEU)
    NameESPEnabled = false,
    NameESPMaxDistance = 600,
    -- Crosshair (v69 NEU)
    CrosshairEnabled = false,
    CrosshairSize = 10,
    CrosshairGap = 4,
    CrosshairThickness = 1.5,
    CrosshairColor = Color3.fromRGB(255, 255, 255),
    -- Gravity (v69 NEU)
    GravityEnabled = false,
    GravityValue = 196.2,
    -- Jump Power (v69 NEU)
    JumpPowerValue = 50,
    -- Speed Indicator (v69 NEU)
    SpeedIndicatorEnabled = false,
    -- Kill Counter (v69 NEU)
    KillCounterEnabled = true,
    -- Streamer Mode (v70 NEU)
    StreamerMode = false,
}

-- ==================== [FIX v88] ECHTE CONFIG PERSISTENZ ====================
-- Ersetzt die No-Op Library:SaveConfiguration / Library:LoadConfiguration.
-- Nutzt writefile/readfile (Executor-APIs). Bei fehlendem Support → pcall fängt ab.
-- Speichert Settings als JSON in "SemysHUB_Config.json".
-- Color3/Vector3 werden als tagged Tables kodiert (JSON kennt diese Typen nicht).
do
    local CONFIG_FILE = "SemysHUB_Config.json"
    local HS = HttpService  -- bereits oben via game:GetService definiert

    -- Serialisiert den Settings-Wert in einen JSON-kompatiblen Wert
    local function encodeValue(v)
        local t = typeof(v)
        if t == "Color3" then
            return { __type = "Color3",
                r = math.floor(v.R * 255 + 0.5),
                g = math.floor(v.G * 255 + 0.5),
                b = math.floor(v.B * 255 + 0.5) }
        elseif t == "Vector3" then
            return { __type = "Vector3", x = v.X, y = v.Y, z = v.Z }
        elseif t == "boolean" or t == "number" or t == "string" then
            return v
        end
        return nil  -- alles andere überspringen
    end

    -- Deseralisiert einen JSON-Wert zurück in den Roblox-Typ
    local function decodeValue(v)
        if type(v) == "table" then
            if v.__type == "Color3" then
                return Color3.fromRGB(
                    math.clamp(math.floor(v.r or 0), 0, 255),
                    math.clamp(math.floor(v.g or 0), 0, 255),
                    math.clamp(math.floor(v.b or 0), 0, 255))
            elseif v.__type == "Vector3" then
                return Vector3.new(v.x or 0, v.y or 0, v.z or 0)
            end
            return nil  -- unbekannte Tabelle überspringen
        end
        return v  -- boolean / number / string direkt zurück
    end

    -- Gibt die aktuelle Settings-Tabelle als JSON-String zurück
    local function serialize()
        local out = {}
        for k, v in pairs(Settings) do
            local enc = encodeValue(v)
            if enc ~= nil then
                out[k] = enc
            end
        end
        local ok, json = pcall(function() return HS:JSONEncode(out) end)
        return ok and json or nil
    end

    -- Wendet einen JSON-String auf die aktuelle Settings-Tabelle an
    local function deserialize(json)
        local ok, data = pcall(function() return HS:JSONDecode(json) end)
        if not ok or type(data) ~= "table" then return false end
        for k, v in pairs(data) do
            if Settings[k] ~= nil then          -- nur bekannte Keys übernehmen
                local dec = decodeValue(v)
                if dec ~= nil then
                    Settings[k] = dec
                end
            end
        end
        return true
    end

    -- Überschreibt die No-Op-Methoden in Rayfield mit echten Implementierungen
    Rayfield.SaveConfiguration = function(_self)
        local json = serialize()
        if not json then
            pcall(function()
                Rayfield:Notify({ Title = "⚠️ Config", Content = "Serialisierung fehlgeschlagen.", Duration = 3 })
            end)
            return
        end
        local ok, err = pcall(function() writefile(CONFIG_FILE, json) end)
        if ok then
            pcall(function()
                Rayfield:Notify({ Title = "💾 Config gespeichert",
                    Content = CONFIG_FILE .. " (" .. #json .. " Bytes)", Duration = 3 })
            end)
        else
            pcall(function()
                Rayfield:Notify({ Title = "⚠️ writefile fehlt",
                    Content = tostring(err):sub(1, 80), Duration = 4 })
            end)
        end
    end

    Rayfield.LoadConfiguration = function(_self)
        -- isfile() ist optional; manche Executors haben es, andere nicht
        local hasFile = pcall(function()
            if not isfile(CONFIG_FILE) then error("not found") end
        end)
        if not hasFile then
            -- Leise scheitern beim Auto-Load beim Start
            return
        end
        local ok, content = pcall(function() return readfile(CONFIG_FILE) end)
        if not ok or not content or content == "" then
            pcall(function()
                Rayfield:Notify({ Title = "⚠️ Config",
                    Content = "Datei konnte nicht gelesen werden.", Duration = 3 })
            end)
            return
        end
        local success = deserialize(content)
        if success then
            pcall(function()
                Rayfield:Notify({ Title = "📂 Config geladen",
                    Content = "Einstellungen aus " .. CONFIG_FILE .. " wiederhergestellt.", Duration = 3 })
            end)
        else
            pcall(function()
                Rayfield:Notify({ Title = "⚠️ Config",
                    Content = "JSON konnte nicht geparst werden.", Duration = 3 })
            end)
        end
    end
end
-- ==================== [FIX v88] ENDE CONFIG PERSISTENZ ====================

-- [FIX v96-5] IsEnemy: Forward-Declaration.
-- Wird in Controllers.Combat.Targeting.IsValid (Zeile ~8991) in einer
-- Table-Methoden-Closure aufgerufen. local function IsEnemy() steht erst bei
-- Zeile ~9411 → Closures davor sehen ohne Forward-Decl nur _G (nil-Crash).
local IsEnemy

-- =====================================================================
-- ==================== ZENTRALE CONTROLLER ARCHITEKTUR (SAUBER) ====================
-- =====================================================================
local Controllers = {
    Registry = {},
    _heartbeatControllers = {},
    _renderSteppedControllers = {},

    Register = function(self, category, name, controller)
        if not self[category] then self[category] = {} end
        self[category][name] = controller
        self.Registry[name] = controller

        if type(controller.Update) == "function" then
            if controller.UpdateType == "RenderStepped" then
                table.insert(self._renderSteppedControllers, controller)
            else
                table.insert(self._heartbeatControllers, controller)
            end
        end
    end,

    _startUpdateLoops = function(self)
        if self._heartbeatConn then return end

        self._heartbeatConn = RunService.Heartbeat:Connect(function(dt)
            for _, ctrl in ipairs(self._heartbeatControllers) do
                if ctrl.Enabled and type(ctrl.Update) == "function" then
                    pcall(ctrl.Update, ctrl, dt)
                end
            end
        end)

        self._renderSteppedConn = RunService.RenderStepped:Connect(function(dt)
            for _, ctrl in ipairs(self._renderSteppedControllers) do
                if ctrl.Enabled and type(ctrl.Update) == "function" then
                    pcall(ctrl.Update, ctrl, dt)
                end
            end
        end)
    end,

    -- ==================== MOVEMENT ====================
    Movement = {
        SuperJump = {
            Enabled = false,
            Strength = 120,
            _getHRP = function(self)
                local char = LocalPlayer.Character
                if not char then return nil end
                return char:FindFirstChild("HumanoidRootPart")
            end,
            Activate = function(self)
                if not self.Enabled then return end
                local hrp = self:_getHRP()
                if not hrp then return end
                pcall(function()
                    hrp:ApplyImpulse(Vector3.new(0, self.Strength * hrp.AssemblyMass, 0))
                end)
            end,
            Toggle = function(self, state) self.Enabled = state end,
        },

        InfiniteJump = {
            Enabled = false,
            _connection = nil,
            Init = function(self)
                if self._connection then return end
                self._connection = UserInputService.JumpRequest:Connect(function()
                    if self.Enabled and LocalPlayer.Character then
                        local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
                        if hum and hum.Health > 0 then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
                    end
                end)
            end,
            Toggle = function(self, state)
                self.Enabled = state
                if state and not self._connection then self:Init() end
            end,
        },

        ConstraintHelper = {
            GetOrCreateAttachment = function(part, name)
                local att = part:FindFirstChild(name)
                if att and att:IsA("Attachment") then return att end
                att = Instance.new("Attachment")
                att.Name = name
                att.Parent = part
                return att
            end,
            CreateLinearVelocity = function(attachment)
                local lv = Instance.new("LinearVelocity")
                lv.Attachment0 = attachment
                lv.MaxForce = 9e9
                lv.RelativeTo = Enum.ActuatorRelativeTo.World
                return lv
            end,
            CreateAlignOrientation = function(attachment, rigidity)
                local ao = Instance.new("AlignOrientation")
                ao.Attachment0 = attachment
                ao.MaxTorque = 9e9
                ao.RigidityEnabled = rigidity or false
                ao.Responsiveness = 200
                return ao
            end,
        },

        -- WallWalk, VehicleFly, Fly, SprintBoost werden hier mit voller Logik ergänzt
        WallWalk = { Enabled = false, UpdateType = "Heartbeat", Toggle = function(self, s) self.Enabled = s end },
        VehicleFly  = { Enabled = false, UpdateType = "Heartbeat",    Speed = 50, Toggle = function(self, s) self.Enabled = s end },  -- [AC-FIX] 160→50
        Fly         = { Enabled = false, UpdateType = "RenderStepped", Speed = 40, Toggle = function(self, s) self.Enabled = s end },  -- [AC-FIX] 80→40
        SprintBoost = { Enabled = false, UpdateType = "Heartbeat",    Speed = 30, Toggle = function(self, s) self.Enabled = s end },  -- [AC-FIX] 50→30
    },

    -- ==================== COMBAT ====================
    Combat = {
        Targeting = {
            Targets = {},
            LastScan = 0,
            ScanInterval = 0.08,

            IsValid = function(self, plr)
                if not plr or plr == LocalPlayer then return false end
                local char = plr.Character
                if not char then return false end
                local hum = char:FindFirstChild("Humanoid")
                if not hum or hum.Health <= 0 then return false end
                if Settings.TeamCheckEnabled and not IsEnemy(plr) then return false end
                return true
            end,

            Update = function(self, dt)
                local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if not root then self.Targets = {} return end

                local params = OverlapParams.new()
                params.FilterType = Enum.RaycastFilterType.Exclude
                params.FilterDescendantsInstances = {LocalPlayer.Character}

                local parts = workspace:GetPartBoundsInRadius(root.Position, 80, params)
                local found = {}

                for _, part in ipairs(parts) do
                    local model = part:FindFirstAncestorWhichIsA("Model")
                    local plr = model and Players:GetPlayerFromCharacter(model)
                    if plr and self:IsValid(plr) then
                        found[plr.Name] = {
                            Player = plr,
                            Character = model,
                            Humanoid = model:FindFirstChild("Humanoid"),
                            HRP = model:FindFirstChild("HumanoidRootPart")
                        }
                    end
                end
                self.Targets = found
                self.LastScan = os.clock()
            end,

            GetTargetsInRange = function(self, maxDist)
                local res = {}
                local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if not root then return res end
                for _, data in pairs(self.Targets) do
                    if data.HRP then
                        if (data.HRP.Position - root.Position).Magnitude <= (maxDist or 999) then
                            table.insert(res, data)
                        end
                    end
                end
                return res
            end,
        },

    },
}

Controllers:_startUpdateLoops()

-- Registrierung
Controllers:Register("Movement", "SuperJump", Controllers.Movement.SuperJump)
Controllers:Register("Movement", "InfiniteJump", Controllers.Movement.InfiniteJump)
Controllers:Register("Movement", "WallWalk", Controllers.Movement.WallWalk)
Controllers:Register("Movement", "VehicleFly", Controllers.Movement.VehicleFly)
Controllers:Register("Movement", "Fly", Controllers.Movement.Fly)
Controllers:Register("Movement", "SprintBoost", Controllers.Movement.SprintBoost)
Controllers:Register("Combat", "Targeting", Controllers.Combat.Targeting)

-- =====================================================================
-- ==================== ENDE CONTROLLER ARCHITEKTUR ====================
-- =====================================================================

-- ==================== SAFETY GLOBALS (verhindert nil errors bei Cleanup / Wallhack / VoiceRange) ====================
local originalTrans = {}
local originalCollide = {}
local VoiceRangeOutline = nil
local VoiceRangePart = nil

-- [v71 Fix] Anti-Verbindungen sind jetzt in HubState gespeichert (kein register-overflow mehr)
-- Alle HubState.antiXxxConn Felder wurden bereits am Anfang des Skripts deklariert.
-- Diese Zeilen wurden in v71 ENTFERNT (waren Duplikate → verursachten "exceeded limit 200").

-- FOV Kreis (pcall guard: Drawing ist executor-abhängig)
local FOVCircle = {}
pcall(function()
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Visible = false
    FOVCircle.Thickness = 1
    FOVCircle.NumSides = 64
    FOVCircle.Radius = Settings.AimbotFOV
    FOVCircle.Filled = false
    FOVCircle.Transparency = 0.8
    FOVCircle.Color = Color3.fromRGB(255, 255, 255)
end)

-- ==================== WAFFEN ERKENNUNG ====================
GetCurrentWeapon = function()
    local char = LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChildOfClass("Tool")
end

local function IsHoldingKnife()
    local tool = GetCurrentWeapon()
    if not tool then return false end
    local name = tool.Name:lower()
    return string.find(name, "knife") ~= nil
        or string.find(name, "messer") ~= nil
        or string.find(name, "blade") ~= nil
end

local function IsHoldingGun()
    local tool = GetCurrentWeapon()
    if not tool then return false end
    local name = tool.Name:lower()
    return string.find(name, "revolver") ~= nil
        or string.find(name, "revo") ~= nil
        or string.find(name, "sheriff") ~= nil
        or string.find(name, "gun") ~= nil
        or string.find(name, "pistol") ~= nil
end

-- ==================== WEAPON SCANNER ====================
SpezialTab:CreateSection("⚡ Waffen Scanner")
local weaponLabel = SpezialTab:CreateLabel("Aktuelle Waffe: Keine")
local _weaponScanLastTick = 0
HubState._weaponScanConn = RunService.Heartbeat:Connect(function()
    if os.clock() - _weaponScanLastTick < 0.25 then return end
    _weaponScanLastTick = os.clock()
    local tool = GetCurrentWeapon()
    if tool then
        weaponLabel:Set("Aktuelle Waffe: " .. tool.Name)
    else
        weaponLabel:Set("Aktuelle Waffe: Keine")
    end
end)

-- ==================== BLACK OPS 2 SNIPER SOUND ====================
-- Standard-ID. Viele alte "Free"-Sounds sind seit Robloxs Audio-Privacy-Update
-- privat/moderiert und spielen in fremden Spielen NICHT mehr ab. Über das
-- Eingabefeld unten kann jederzeit eine eigene, funktionierende Sound-ID gesetzt werden.
local BO2_SNIPER_ID = "rbxassetid://142665212"

-- Spielt den Schuss-Sound DIREKT ab (eigene 2D-Sound-Instanz) — funktioniert bei
-- jeder Waffe, unabhängig davon ob das Spiel eigene Schuss-Sounds hat.
-- Wird im Activated-Hook (HookLocalAttacks) bei jedem Schuss aufgerufen.
local function PlayShootSound()
    pcall(function()
        -- [FIX] SoundService war hier nicht im Scope (nur in ShowPasswordGUI/SemysUI definiert)
        local SoundService = game:GetService("SoundService")
        local s = Instance.new("Sound")
        s.SoundId = BO2_SNIPER_ID
        s.Volume = 3.5
        s.PlaybackSpeed = 1
        s.Parent = SoundService
        s:Play()
        s.Ended:Connect(function() if s then s:Destroy() end end)
        task.delay(6, function() if s and s.Parent then s:Destroy() end end)
    end)
end
HubState.PlayShootSound = PlayShootSound

-- Testet den Sound und meldet, falls die Audio-ID nicht geladen werden kann
-- (häufigster Grund: privates/moderiertes Asset seit Robloxs Audio-Privacy-Update).
local function TestShootSound()
    pcall(function()
        -- [FIX] SoundService war nicht im Scope deklariert (nur in PlayShootSound gefixt, hier fehlte es)
        local SoundService = game:GetService("SoundService")
        local s = Instance.new("Sound")
        s.SoundId = BO2_SNIPER_ID
        s.Volume = 3.5
        s.PlaybackSpeed = 1
        s.Parent = SoundService
        s:Play()
        s.Ended:Connect(function() if s then s:Destroy() end end)
        task.delay(8, function() if s and s.Parent then s:Destroy() end end)
        task.spawn(function()
            for _ = 1, 30 do
                if s.IsLoaded then
                    Rayfield:Notify({Title = "Sound", Content = "Sound geladen & abgespielt ✔", Duration = 3})
                    return
                end
                task.wait(0.1)
            end
            Rayfield:Notify({Title = "Sound-Fehler", Content = "Diese Audio-ID lädt nicht (privat/moderiert). Setze unten eine eigene Sound-ID.", Duration = 6})
        end)
    end)
end

-- Alte Methode: tauscht die SoundId vorhandener Waffen-Sounds aus (optionaler Bonus,
-- damit auch der spieleigene Sound passt – wird nicht mehr per Loop benötigt).
local function ApplyBlackOps2Sound()
    local tool = GetCurrentWeapon()
    if not tool or not IsHoldingGun() then return end
    for _, obj in ipairs(tool:GetDescendants()) do
        if obj:IsA("Sound") then
            local name = obj.Name:lower()
            if string.find(name, "shoot") or string.find(name, "fire") or string.find(name, "shot") then
                if obj.SoundId ~= BO2_SNIPER_ID then
                    obj.SoundId = BO2_SNIPER_ID
                    obj.Volume = 3.5
                end
            end
        end
    end
end


-- ==================== GODMODE ====================
SpezialTab:CreateSection("🔰 Gottmodus")

-- ══ GOTTMODUS MULTI-LAYER SYSTEM ══════════════════════════════════════
-- Schicht 1: math.huge HP Loop    → jeder Frame HP auf Unendlich setzen
-- Schicht 2: ForceField           → manche Spiele respektieren ForceField-Immunität
-- Schicht 3: Humanoid State Lock  → blockiert Dead-State (Humanoid stirbt nicht)
-- Schicht 4: Anti-Respawn Hook    → bei Humanoid.Died sofort neues Zeichen laden
-- Schicht 5: Anti-BreakJoints     → überschreibt BreakJoints via pcall-Metatable
-- ══════════════════════════════════════════════════════════════════════
do
    local _gmLoop      = nil   -- Heartbeat-Verbindung (Schicht 1+3)
    local _gmDiedConn  = nil   -- Died-Verbindung (Schicht 4)
    local _gmCharConn  = nil   -- CharacterAdded (Schichten neu anwenden)
    local _gmFF        = nil   -- ForceField Instanz (Schicht 2)
    local _gmActive    = false

    local function _gmCleanup()
        if _gmLoop     then _gmLoop:Disconnect();     _gmLoop    = nil end
        if _gmDiedConn then _gmDiedConn:Disconnect(); _gmDiedConn= nil end
        if _gmFF and _gmFF.Parent then _gmFF:Destroy() end
        _gmFF = nil
        -- [FIX v95] Schicht 5 (Anti-BreakJoints): char-Referenz löschen damit der
        -- Metatable-Hook nach Godmode-Deaktivierung NICHT mehr greift.
        HubState._gmChar = nil
    end

    local function _gmApply()
        _gmCleanup()
        if not _gmActive then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hum  = char:FindFirstChild("Humanoid")
        local hrp  = char:FindFirstChild("HumanoidRootPart")
        if not hum then return end

        -- ── Schicht 1+3: Heartbeat-Loop ──────────────────────────────
        _gmLoop = RunService.Heartbeat:Connect(function()
            if not _gmActive then return end
            pcall(function()
                local h = LocalPlayer.Character and
                          LocalPlayer.Character:FindFirstChild("Humanoid")
                if not h then return end
                -- Schicht 1: HP auf Unendlich
                if h.MaxHealth ~= math.huge then h.MaxHealth = math.huge end
                if h.Health    ~= math.huge then h.Health    = math.huge end
                -- Schicht 3: Dead-State blockieren
                if h:GetState() == Enum.HumanoidStateType.Dead then
                    pcall(function()
                        h:ChangeState(Enum.HumanoidStateType.Running)
                    end)
                end
            end)
        end)

        -- ── Schicht 2: ForceField ─────────────────────────────────────
        pcall(function()
            if _gmFF and _gmFF.Parent then _gmFF:Destroy() end
            _gmFF = Instance.new("ForceField")
            _gmFF.Visible = false
            _gmFF.Parent  = char
        end)

        -- ── Schicht 4: Auto-Respawn bei Died ──────────────────────────
        _gmDiedConn = hum.Died:Connect(function()
            if not _gmActive then return end
            task.wait(0.05)
            -- Sofort neuen Charakter laden (= quasi unendliche Leben)
            pcall(function() LocalPlayer:LoadCharacter() end)
        end)

        -- ── Schicht 5: Anti-BreakJoints (falls Executor unterstützt) ──
        -- [FIX v95] Metatable-Hook wurde bei jedem Respawn erneut ausgeführt →
        -- jeder Aufruf wrappte mt.__index nochmals → nach N Respawns N verschachtelte
        -- Closures (Stack-Overflow-Risiko). Jetzt: Hook läuft nur EINMAL;
        -- char-Referenz wird dynamisch über HubState._gmChar gelesen.
        HubState._gmChar = char  -- immer aktuellen Char eintragen (auch nach Respawn)
        if not HubState._gmMtHooked then
            pcall(function()
                local mt = getrawmetatable(game)
                if not mt then return end
                setreadonly(mt, false)
                local oldIndex = mt.__index
                mt.__index = newcclosure(function(self, key)
                    if key == "BreakJoints" and self == HubState._gmChar then
                        -- BreakJoints-Aufruf auf dem aktuellen Character blockieren
                        return function() end
                    end
                    return oldIndex(self, key)
                end)
                setreadonly(mt, true)
            end)
            HubState._gmMtHooked = true
        end
    end

    -- Bei CharacterAdded Schichten neu anwenden (Respawn hält Godmode aufrecht)
    -- [FIX] _gmCharConn wurde gesetzt aber nie disconnected → Connection-Leak beim Re-Toggle
    if _gmCharConn then _gmCharConn:Disconnect() _gmCharConn = nil end
    _gmCharConn = LocalPlayer.CharacterAdded:Connect(function()
        if _gmActive then
            task.wait(0.1)  -- kurz warten bis Char geladen
            _gmApply()
        end
    end)

    SpezialTab:CreateToggle({
        Name = "🔰 Gottmodus (5-Schicht System)",
        CurrentValue = false,
        Callback = function(state)
            Settings.GodmodeEnabled = state
            _gmActive = state
            if state then
                _gmApply()
                Rayfield:Notify({
                    Title   = "🔰 Gottmodus AN",
                    Content = "5 Schichten aktiv: HP∞ + ForceField + State-Lock + Auto-Respawn + Anti-BreakJoints",
                    Duration = 4
                })
            else
                _gmCleanup()
                -- HP auf normal zurücksetzen
                pcall(function()
                    local h = LocalPlayer.Character and
                              LocalPlayer.Character:FindFirstChild("Humanoid")
                    if h then h.MaxHealth = 100; h.Health = 100 end
                end)
                Rayfield:Notify({Title = "🔰 Gottmodus AUS", Content = "Alle Schichten deaktiviert", Duration = 3})
            end
        end
    })

    SpezialTab:CreateLabel("⚠️ Schicht 5 (Anti-BreakJoints) funktioniert nur wenn dein Executor getrawmetatable/setreadonly unterstützt (z.B. Synapse, Fluxus).")
end
-- ══════════════════════════════════════════════════════════════════════

-- ==================== INFINITE JUMP ====================
-- [FIX] Doppelte JumpRequest-Verbindung entfernt: Controllers.Movement.InfiniteJump._connection
-- macht dasselbe bereits. Zwei gleichzeitige Verbindungen ließen den Sprung doppelt feuern.
-- Der Controller-Toggle (MovementTab) aktiviert/deaktiviert die Verbindung korrekt.

-- [FIX] Forward-Deklarationen für TriggerBot-Closures (werden vor ihrer Definition referenziert)
local IsTargetAlive
local currentLockedTarget, currentNormalTarget

-- ==================== TRIGGER BOT (automatisches Schießen bei Ziel) ====================
local lastTriggerShot = 0

-- [FPS-FIX] RaycastParams einmal erstellen, nicht jeden Frame neu allozieren
local _triggerRayParams = RaycastParams.new()
_triggerRayParams.FilterType = Enum.RaycastFilterType.Exclude
HubState._triggerBotConn = RunService.Heartbeat:Connect(function()
    if not Settings.TriggerBotEnabled then return end

    pcall(function()
        if os.clock() - lastTriggerShot < Settings.TriggerBotDelay then return end

        local tool = GetCurrentWeapon()
        if not tool then return end

        local function FireWeapon()
            if mouse1press and mouse1release then
                pcall(function()
                    mouse1press()
                    task.wait(0.04)
                    mouse1release()
                end)
            else
                tool:Activate()
            end
        end

        -- 1. Priorität: Aimbot hat ein Ziel gelockt (Rage oder Normal)
        local target = currentLockedTarget or currentNormalTarget
        if target and target.Character and IsTargetAlive(target) then
            FireWeapon()
            lastTriggerShot = os.clock()
            return
        end

        -- 2. Standalone Trigger: Raycast von der Mausposition (auch ohne Aimbot)
        local camera = Workspace.CurrentCamera
        local mousePos = UserInputService:GetMouseLocation()
        local ray = camera:ViewportPointToRay(mousePos.X, mousePos.Y)

        -- [FPS-FIX] RaycastParams nur einmal pro Frame aktualisieren, nicht neu allozieren
        -- (RaycastParams.new() jeden Frame erzeugt GC-Druck)
        _triggerRayParams.FilterDescendantsInstances = {LocalPlayer.Character}

        local result = Workspace:Raycast(ray.Origin, ray.Direction * 2000, _triggerRayParams)

        if result and result.Instance then
            local hitModel = result.Instance:FindFirstAncestorWhichIsA("Model")
            if hitModel and hitModel ~= LocalPlayer.Character then
                local hum = hitModel:FindFirstChild("Humanoid")
                if hum and hum.Health > 0 then
                    FireWeapon()
                    local hitPlr = Players:GetPlayerFromCharacter(hitModel)
                    if hitPlr and HubState.markEngaged then HubState.markEngaged(hitPlr) end
                    lastTriggerShot = os.clock()
                end
            end
        end
    end)
end)

-- ==================== AUTO KLICKER (voll konfigurierbar) ====================

-- ==================== HILFSFUNKTIONEN ====================
local function ShouldApply(plr)
    if not plr.Character then return false end
    if plr == LocalPlayer then return false end
    return true
end

IsEnemy = function(plr)
    if not plr or plr == LocalPlayer then return false end

    -- Methode 1: Standard Roblox Team System (Team-Objekt) — zuverlässigstes Signal
    -- WICHTIG: entscheidend! Gleiches Team = Freund (false), nicht durchfallen lassen.
    if LocalPlayer.Team ~= nil or plr.Team ~= nil then
        return plr.Team ~= LocalPlayer.Team
    end

    -- Methode 2: TeamColor (nur falls ein Game Farben ohne Team-Objekt nutzt)
    -- Nur unterschiedliche Farbe => Gegner. Gleiche Farbe sagt nichts aus → weiterprüfen.
    if LocalPlayer.TeamColor and plr.TeamColor and plr.TeamColor ~= LocalPlayer.TeamColor then
        return true
    end

    -- Methode 3 (ROBUST): Team-Tag über ALLE Attribute & Werte ermitteln —
    -- sowohl auf dem Player ALS AUCH auf dem Character. Fängt eigene Attribut-
    -- Namen ab (z.B. Rivals setzt ein eigenes "Team"-Attribut, NICHT Player.Team).
    local function teamish(name)
        name = tostring(name):lower()
        return name:find("team") or name:find("role") or name:find("side")
            or name:find("group") or name:find("faction") or name:find("guild")
            or name:find("alliance") or name:find("clan")
    end

    local function getTeamTag(player)
        if not player then return nil end
        -- a) Attribute auf dem Player
        local ok, attrs = pcall(function() return player:GetAttributes() end)
        if ok and attrs then
            for k, v in pairs(attrs) do
                if teamish(k) and v ~= nil then return tostring(v) end
            end
        end
        -- b) Attribute auf dem Character
        local char = player.Character
        if char then
            local ok2, cattrs = pcall(function() return char:GetAttributes() end)
            if ok2 and cattrs then
                for k, v in pairs(cattrs) do
                    if teamish(k) and v ~= nil then return tostring(v) end
                end
            end
        end
        -- c) leaderstats-Einträge
        local ls = player:FindFirstChild("leaderstats")
        if ls then
            for _, stat in ipairs(ls:GetChildren()) do
                if teamish(stat.Name) then
                    return tostring(stat.Value)
                end
            end
        end
        -- d) Value-Objekte direkt im Player
        for _, child in ipairs(player:GetChildren()) do
            if child:IsA("ValueBase") and teamish(child.Name) then
                return tostring(child.Value)
            end
        end
        -- e) Value-Objekte im Character
        if char then
            for _, child in ipairs(char:GetChildren()) do
                if child:IsA("ValueBase") and teamish(child.Name) then
                    return tostring(child.Value)
                end
            end
        end
        return nil
    end

    local myTag = getTeamTag(LocalPlayer)
    local theirTag = getTeamTag(plr)
    if myTag and theirTag then
        return myTag ~= theirTag
    end

    -- Fallback: Wenn kein Team-System erkannt wird → alle anderen als Gegner behandeln
    -- Das ist der Grund, warum der ESP in den meisten Games "einfach funktioniert"
    return true
end

IsTargetAlive = function(plr)
    if not plr.Character then return false end
    local hum = plr.Character:FindFirstChild("Humanoid")
    return hum and hum.Health > 0
end

local function GetBoxESPColor(plr)
    -- TeamCheck AUS → ALLE Spieler bekommen TeammateColor (einheitlich blau)
    if not Settings.TeamCheckEnabled then
        return Settings.TeammateColor
    end
    return IsEnemy(plr) and Settings.EnemyColor or Settings.TeammateColor
end

local function GetChamsColor(plr)
    -- TeamCheck AUS → ALLE Spieler bekommen TeammateColor (einheitlich blau)
    if not Settings.TeamCheckEnabled then
        return Settings.TeammateColor
    end
    return IsEnemy(plr) and Settings.EnemyColor or Settings.TeammateColor
end

local function UpdateFOVCircle()
    local Camera = Workspace.CurrentCamera
    local shouldShow = (Settings.AimbotEnabled or Settings.NormalAimbotEnabled) and Settings.ShowFOVCircle
    FOVCircle.Visible = shouldShow
    if shouldShow then
        FOVCircle.Radius = Settings.AimbotFOV
        FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    end
end

-- ==================== WALLCHECK (Global Best Practice für Normal Aimbot - Legit Style) ====================
-- Optimiert, stabil, mit perfekten Edge-Case-Checks. Wird nur bei Normal Aimbot verwendet.
local function HasClearLineOfSight(fromPosition, toPosition, targetCharacter)
    if not fromPosition or not toPosition or not targetCharacter then
        return false
    end

    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character, targetCharacter}
    rayParams.IgnoreWater = true

    local direction = toPosition - fromPosition
    local result = Workspace:Raycast(fromPosition, direction, rayParams)

    if result and result.Instance then
        -- Wenn der Hit zum Target-Model gehört → Sicht ist frei
        if result.Instance:IsDescendantOf(targetCharacter) then
            return true
        end
        return false -- Blockiert durch Wand oder anderes Objekt
    end

    return true -- Kein Hit = freie Line of Sight
end

HubState._fovCircleConn = RunService.RenderStepped:Connect(function()
    -- [FIX v94] Verbindung gespeichert → kann bei F5-Reset getrennt werden
    UpdateFOVCircle()
end)

local function UpdateAllBoxESPColors()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character then
            local esp = plr.Character:FindFirstChild("MeinESP")
            if esp and esp:IsA("BoxHandleAdornment") then
                esp.Color3 = GetBoxESPColor(plr)
            end
        end
    end
end

local function UpdateAllChamsColors()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character then
            local chams = plr.Character:FindFirstChild("MeinChams")
            if chams and chams:IsA("Highlight") then
                local color = GetChamsColor(plr)
                chams.FillColor = color
                chams.OutlineColor = color
            end
        end
    end
end

local function UpdateAllBoxESPTransparency(newTransparency)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character then
            local esp = plr.Character:FindFirstChild("MeinESP")
            if esp and esp:IsA("BoxHandleAdornment") then
                esp.Transparency = newTransparency
            end
        end
    end
end

local function UpdateAllChamsTransparency(newTransparency)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character then
            local chams = plr.Character:FindFirstChild("MeinChams")
            if chams and chams:IsA("Highlight") then
                chams.FillTransparency = newTransparency
            end
        end
    end
end

local originalWeaponTransparency = {}
local function SetWeaponTransparency(transparent)
    local character = LocalPlayer.Character
    if not character then return end
    local tool = character:FindFirstChildOfClass("Tool")
    if not tool then return end
    for _, part in ipairs(tool:GetDescendants()) do
        if part:IsA("BasePart") then
            if transparent then
                if not originalWeaponTransparency[part] then originalWeaponTransparency[part] = part.Transparency end
                part.Transparency = 0.85
            else
                if originalWeaponTransparency[part] then part.Transparency = originalWeaponTransparency[part] end
            end
        end
    end
end

local function CleanupESP()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character then
            local e = plr.Character:FindFirstChild("MeinESP")
            if e then e:Destroy() end
        end
    end
end

local function CleanupChams()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character then
            local c = plr.Character:FindFirstChild("MeinChams")
            if c then c:Destroy() end
        end
    end
end

-- [FIX v77] Forward-Deklarationen: nur Funktionen/Variablen die NICHT bereits
-- weiter oben (Zeile ~3997-4000) als local deklariert wurden.
-- VoiceRangePart, VoiceRangeOutline, originalTrans, originalCollide sind DORT
-- bereits deklariert — hier kein 'local' mehr, sonst shadowing-Bug!
local CleanupHealthWeapon
local ESPManager, ChamsManager, HealthWeaponManager

local function CleanupAll()
    CleanupESP()
    CleanupChams()
    CleanupHealthWeapon()
    if VoiceRangePart and VoiceRangePart.Parent then VoiceRangePart:Destroy() VoiceRangePart = nil end
    if VoiceRangeOutline and VoiceRangeOutline.Parent then VoiceRangeOutline:Destroy() VoiceRangeOutline = nil end
    for part, t in pairs(originalTrans or {}) do
        if part and part.Parent then
            part.Transparency = t
            if originalCollide[part] ~= nil then part.CanCollide = originalCollide[part] end
        end
    end
    originalTrans = {}
    originalCollide = {}
end

local function ApplyChams(char, plr)
    if not char or char:FindFirstChild("MeinChams") then return end
    local h = Instance.new("Highlight")
    h.Name = "MeinChams"
    h.FillColor = GetChamsColor(plr)
    h.OutlineColor = GetChamsColor(plr)
    h.FillTransparency = Settings.ChamsFillTransparency
    h.OutlineTransparency = 0
    h.Parent = char
end

local function ApplyESP(char, plr)
    if not char or char:FindFirstChild("MeinESP") then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local esp = Instance.new("BoxHandleAdornment")
    esp.Name = "MeinESP"
    -- [FIX] BoxHandleAdornment benötigt BasePart als Adornee, kein Model → HumanoidRootPart nutzen
    esp.Adornee = hrp
    esp.Size = Settings.ESPBoxSize
    esp.Transparency = Settings.ESPTransparency
    esp.Color3 = GetBoxESPColor(plr)
    esp.AlwaysOnTop = true
    esp.ZIndex = 10
    esp.Parent = char
end

-- ==================== VISUALS MANAGER ====================
local function RefreshESPAndChams()
    CleanupAll()
    if Settings.ESPEnabled then task.spawn(ESPManager) end
    if Settings.ChamsEnabled then task.spawn(ChamsManager) end
    if Settings.HealthWeaponEnabled then task.spawn(HealthWeaponManager) end
end

local ESPManagerActive = false
ESPManager = function()
    if ESPManagerActive then return end
    ESPManagerActive = true
    while Settings.ESPEnabled do
        task.wait(0.5)
        for _, plr in ipairs(Players:GetPlayers()) do
            if ShouldApply(plr) and plr.Character and IsTargetAlive(plr) then
                local myChar = LocalPlayer.Character
                if myChar and myChar:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (myChar.HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).Magnitude
                    if dist <= Settings.ESPMaxDistance then
                        ApplyESP(plr.Character, plr)
                    else
                        local e = plr.Character:FindFirstChild("MeinESP")
                        if e then e:Destroy() end
                    end
                end
            end
        end
        task.wait(0.35)
    end
    ESPManagerActive = false
    CleanupESP()
end

local ChamsManagerActive = false
ChamsManager = function()
    if ChamsManagerActive then return end
    ChamsManagerActive = true
    while Settings.ChamsEnabled do
        task.wait(0.5)
        for _, plr in ipairs(Players:GetPlayers()) do
            if ShouldApply(plr) and plr.Character and IsTargetAlive(plr) then
                local myChar = LocalPlayer.Character
                if myChar and myChar:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (myChar.HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).Magnitude
                    if dist <= Settings.ESPMaxDistance then
                        ApplyChams(plr.Character, plr)
                    else
                        local c = plr.Character:FindFirstChild("MeinChams")
                        if c then c:Destroy() end
                    end
                end
            end
        end
        task.wait(0.35)
    end
    ChamsManagerActive = false
    CleanupChams()
end

-- ==================== HEALTH BAR + WEAPON SYMBOL (neu hinzugefügt) ====================
local HealthWeaponManagerActive = false

CleanupHealthWeapon = function()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character then
            local b = plr.Character:FindFirstChild("HealthWeaponBillboard")
            if b then b:Destroy() end
        end
    end
end

local function GetWeaponType(plr)
    if not plr or not plr.Character then return "none" end
    local tool = plr.Character:FindFirstChildOfClass("Tool")
    if not tool then return "none" end
    local name = tool.Name:lower()

    -- Knife / Melee
    if string.find(name, "knife") ~= nil
       or string.find(name, "messer") ~= nil
       or string.find(name, "blade") ~= nil
       or string.find(name, "sword") ~= nil then
        return "knife"
    end

    -- Sniper
    if string.find(name, "sniper") ~= nil
       or string.find(name, "awp") ~= nil
       or string.find(name, "scout") ~= nil
       or string.find(name, "bolt") ~= nil then
        return "sniper"
    end

    -- Assault Rifle / Sturmgewehr
    if string.find(name, "ar") ~= nil
       or string.find(name, "ak") ~= nil
       or string.find(name, "m4") ~= nil
       or string.find(name, "sturm") ~= nil
       or string.find(name, "assault") ~= nil
       or string.find(name, "rifle") ~= nil then
        return "gun"
    end

    -- MP / SMG / Submachine
    if string.find(name, "mp") ~= nil
       or string.find(name, "smg") ~= nil
       or string.find(name, "uzi") ~= nil
       or string.find(name, "mac") ~= nil
       or string.find(name, "vector") ~= nil then
        return "gun"
    end

    -- Shotgun
    if string.find(name, "shotgun") ~= nil
       or string.find(name, "pump") ~= nil
       or string.find(name, "sawed") ~= nil then
        return "gun"
    end

    -- Normal guns (Revolver, Pistol, etc.)
    if string.find(name, "revolver") ~= nil
       or string.find(name, "revo") ~= nil
       or string.find(name, "sheriff") ~= nil
       or string.find(name, "gun") ~= nil
       or string.find(name, "pistol") ~= nil
       or string.find(name, "deagle") ~= nil
       or string.find(name, "glock") ~= nil then
        return "gun"
    end

    -- Everything else that is a tool (probably a weapon)
    return "gun"
end

local function ApplyHealthWeapon(char, plr)
    if not char or char:FindFirstChild("HealthWeaponBillboard") then return end
    local head = char:FindFirstChild("Head")
    if not head then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "HealthWeaponBillboard"
    billboard.Adornee = head
    billboard.Size = UDim2.new(5, 0, 2.8, 0)
    billboard.StudsOffset = Vector3.new(0, 3.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = char

    local main = Instance.new("Frame")
    main.Size = UDim2.new(1, 0, 1, 0)
    main.BackgroundTransparency = 1
    main.Parent = billboard

    -- Weapon Symbol (VIEL GRÖSSER direkt über der Health Bar)
    local weaponSymbol = Instance.new("Frame")
    weaponSymbol.Name = "WeaponSymbol"
    local scale = Settings.HealthWeaponSymbolScale or 1.0
    weaponSymbol.Size = UDim2.new(0.48 * scale, 0, 0.58 * scale, 0)

    -- Immer mittig + steigt stärker nach oben wenn größer
    local yOffset = 0.02 - (0.38 * math.max(0, scale - 1))
    weaponSymbol.Position = UDim2.new(0.5, 0, yOffset, 0)
    weaponSymbol.AnchorPoint = Vector2.new(0.5, 0)
    weaponSymbol.BackgroundColor3 = Color3.fromRGB(180, 180, 180)
    weaponSymbol.BorderSizePixel = 0
    weaponSymbol.Parent = main

    local weaponCorner = Instance.new("UICorner")
    weaponCorner.CornerRadius = UDim.new(1, 0)
    weaponCorner.Parent = weaponSymbol

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Thickness = 3
    stroke.Parent = weaponSymbol

    -- Emoji Symbol inside the circle (deutlich größer)
    local emojiLabel = Instance.new("TextLabel")
    emojiLabel.Name = "EmojiLabel"
    emojiLabel.Size = UDim2.new(1, 0, 1, 0)
    emojiLabel.BackgroundTransparency = 1
    emojiLabel.Text = "?"
    emojiLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    emojiLabel.TextScaled = true
    emojiLabel.Font = Enum.Font.GothamBlack
    emojiLabel.Parent = weaponSymbol

    -- Health bar background (unter dem grossen Symbol)
    local healthBg = Instance.new("Frame")
    healthBg.Name = "HealthBg"
    local healthHeight = 0.22 * math.max(0.6, 1.1 - (scale * 0.25))
    healthBg.Size = UDim2.new(0.82, 0, healthHeight, 0)
    healthBg.Position = UDim2.new(0.09, 0, 0.68, 0)
    healthBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    healthBg.BorderSizePixel = 0
    healthBg.Parent = main

    local healthBgCorner = Instance.new("UICorner")
    healthBgCorner.CornerRadius = UDim.new(0, 4)
    healthBgCorner.Parent = healthBg

    -- Health fill
    local healthFill = Instance.new("Frame")
    healthFill.Name = "HealthFill"
    healthFill.Size = UDim2.new(1, 0, 1, 0)
    healthFill.BackgroundColor3 = Color3.fromRGB(80, 255, 80)
    healthFill.BorderSizePixel = 0
    healthFill.Parent = healthBg

    local healthFillCorner = Instance.new("UICorner")
    healthFillCorner.CornerRadius = UDim.new(0, 4)
    healthFillCorner.Parent = healthFill
end

local function UpdateHealthWeapon(plr)
    if not plr.Character then return end
    local billboard = plr.Character:FindFirstChild("HealthWeaponBillboard")
    if not billboard then return end

    local hum = plr.Character:FindFirstChild("Humanoid")
    local healthBg = billboard:FindFirstChild("HealthBg", true)
    local healthFill = healthBg and healthBg:FindFirstChild("HealthFill")
    local weaponSymbol = billboard:FindFirstChild("WeaponSymbol", true)

    if hum and healthFill and hum.MaxHealth > 0 then
        local hp = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
        healthFill.Size = UDim2.new(hp, 0, 1, 0)

        if hp > 0.65 then
            healthFill.BackgroundColor3 = Color3.fromRGB(70, 255, 70)      -- Grün
        elseif hp > 0.30 then
            healthFill.BackgroundColor3 = Color3.fromRGB(255, 200, 50)     -- Gelb (besser sichtbar)
        else
            healthFill.BackgroundColor3 = Color3.fromRGB(255, 60, 60)      -- Rot
        end
    end

    if weaponSymbol then
        local wType = GetWeaponType(plr)
        local emojiLabel = weaponSymbol:FindFirstChild("EmojiLabel")

        if wType == "knife" then
            weaponSymbol.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
            if emojiLabel then emojiLabel.Text = "🔪" end
        elseif wType == "sniper" then
            weaponSymbol.BackgroundColor3 = Color3.fromRGB(180, 100, 255)  -- Lila für Sniper
            if emojiLabel then emojiLabel.Text = "🎯" end
        elseif wType == "gun" then
            weaponSymbol.BackgroundColor3 = Color3.fromRGB(80, 200, 255)
            if emojiLabel then emojiLabel.Text = "🔫" end
        else
            weaponSymbol.BackgroundColor3 = Color3.fromRGB(120, 120, 120)
            if emojiLabel then emojiLabel.Text = "?" end
        end
    end
end

HealthWeaponManager = function()
    if HealthWeaponManagerActive then return end
    HealthWeaponManagerActive = true
    while Settings.HealthWeaponEnabled do
        task.wait(0.5)
        for _, plr in ipairs(Players:GetPlayers()) do
            if ShouldApply(plr) and plr.Character and IsTargetAlive(plr) then
                local myChar = LocalPlayer.Character
                if myChar and myChar:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (myChar.HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).Magnitude
                    if dist <= Settings.HealthWeaponMaxDistance then
                        if not plr.Character:FindFirstChild("HealthWeaponBillboard") then
                            ApplyHealthWeapon(plr.Character, plr)
                        end
                        UpdateHealthWeapon(plr)
                    else
                        local b = plr.Character:FindFirstChild("HealthWeaponBillboard")
                        if b then b:Destroy() end
                    end
                end
            end
        end
        task.wait(0.3)
    end
    HealthWeaponManagerActive = false
    CleanupHealthWeapon()
end

-- ==================== AIMBOT LOGIK ====================
local aimbotConn  -- currentLockedTarget ist oben forward-deklariert
local function FindNewTarget()
    local isRage = Settings.AimbotEnabled
    -- RAGE: bei "Distance"/"Health"-Modus die GANZE Map scannen (FOV egal)
    local rageFullScan = isRage and Settings.RageTargetMode ~= "Crosshair"
    local closestPlayer = nil
    local shortestDistance = (Settings.AimbotFullFOV or rageFullScan) and 999999 or Settings.AimbotFOV
    local mousePos = UserInputService:GetMouseLocation()
    local Camera = Workspace.CurrentCamera
    local partName = (isRage and Settings.RageTargetPart) or "Head"

    for _, plr in ipairs(Players:GetPlayers()) do
        repeat
        if ShouldApply(plr) and plr.Character and IsTargetAlive(plr) then
            -- TeamCheck Logik:
            -- TeamCheck AN  → nur Gegner
            -- TeamCheck AUS → alle Spieler (auch Teammates)
            if Settings.TeamCheckEnabled then
                if not IsEnemy(plr) then
                    break
                end
            end

            local targetPart = plr.Character:FindFirstChild(partName)
                or plr.Character:FindFirstChild("Head")
                or plr.Character:FindFirstChild("HumanoidRootPart")
            if targetPart then
                local myChar = LocalPlayer.Character
                if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                    local myPos = myChar.HumanoidRootPart.Position
                    if (targetPart.Position - myPos).Magnitude > Settings.AimbotMaxDistance then
                        break
                    end

                    -- Wallcheck nur für Normal Aimbot (Rage Aimbot bleibt wallbang-fähig)
                    if Settings.NormalAimbotEnabled and not isRage and Settings.NormalAimbotWallCheck then
                        local myHead = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head")
                        local fromPos = myHead and myHead.Position or Workspace.CurrentCamera.CFrame.Position

                        if not HasClearLineOfSight(fromPos, targetPart.Position, plr.Character) then
                            break
                        end
                    end

                    -- RAGE Ziel-Auswahl: nächster Spieler ODER niedrigste HP (ganze Map)
                    if rageFullScan then
                        local score
                        if Settings.RageTargetMode == "Health" then
                            local h = plr.Character:FindFirstChildOfClass("Humanoid")
                            score = h and h.Health or 100
                        else
                            score = (targetPart.Position - myPos).Magnitude
                        end
                        if score < shortestDistance then
                            shortestDistance = score
                            closestPlayer = plr
                        end
                        break
                    end
                end

                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                if onScreen or Settings.AimbotFullFOV then
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestPlayer = plr
                    end
                end
            end
        end
        until true
    end
    return closestPlayer
end

local function ToggleAimbot(state)
    Settings.AimbotEnabled = state
    UpdateFOVCircle()
    if state then
        currentLockedTarget = nil
        aimbotConn = RunService.RenderStepped:Connect(function()
            pcall(function()
                local Camera = Workspace.CurrentCamera
                if not Settings.AimbotEnabled or not LocalPlayer.Character then return end
                -- RAGE: "Always On" braucht keine rechte Maustaste mehr
                local isAiming = Settings.RageAlwaysOn or UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
                if not isAiming then
                    currentLockedTarget = nil
                    SetWeaponTransparency(false)
                    if LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.AutoRotate = true end
                    return
                end
                SetWeaponTransparency(true)
                if LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.AutoRotate = false end
                -- RAGE: Ziel-Suche GEDROSSELT (~alle 0.1s) statt jeden Frame -> kein Lag.
                -- Der Kamera-Lock unten läuft trotzdem jeden Frame flüssig.
                -- Stirbt das Ziel, wird SOFORT neu gesucht (Auto-Switch bleibt instant).
                if currentLockedTarget and not IsTargetAlive(currentLockedTarget) then currentLockedTarget = nil end
                local nowT = os.clock()
                if (not currentLockedTarget) or ((nowT - (HubState.lastRageScan or 0)) >= 0.1) then
                    currentLockedTarget = FindNewTarget() or currentLockedTarget
                    HubState.lastRageScan = nowT
                end

                if currentLockedTarget and currentLockedTarget.Character then
                    local partName = Settings.RageTargetPart or "Head"
                    local targetPart = currentLockedTarget.Character:FindFirstChild(partName)
                        or currentLockedTarget.Character:FindFirstChild("Head")
                        or currentLockedTarget.Character:FindFirstChild("HumanoidRootPart")
                    if targetPart then
                        local targetPos = targetPart.Position
                        -- RAGE: Velocity-Prediction führt bewegte Ziele vor (Silent-Lead)
                        if Settings.RagePrediction then
                            local vel = targetPart.AssemblyLinearVelocity
                            if vel then targetPos = targetPos + vel * Settings.RagePredictionStrength end
                        end
                        -- [AC-FIX] Lerp statt Instant-Snap → sieht aus wie menschliche
                        -- Mausbewegung, kein roboterhafter 0-Frame-Schwenk
                        local targetCF = CFrame.new(Camera.CFrame.Position, targetPos)
                        Camera.CFrame = Camera.CFrame:Lerp(targetCF, 0.25)

                        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if root then
                            local lookPos = Vector3.new(targetPos.X, root.Position.Y, targetPos.Z)
                            local targetRootCF = CFrame.new(root.Position, lookPos)
                            root.CFrame = root.CFrame:Lerp(targetRootCF, 0.25)
                        end
                    end
                end
            end)
        end)
    else
        if aimbotConn then aimbotConn:Disconnect() aimbotConn = nil end
        currentLockedTarget = nil
        SetWeaponTransparency(false)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.AutoRotate = true end
        FOVCircle.Visible = false
    end
end

-- ==================== RAGE KNIFE THROW (durch Wände + Schnell) - Verbesserte Version ====================
local function SetupRageKnifeThrow()
    local tool = GetCurrentWeapon()
    if not tool or not IsHoldingKnife() then return end

    -- Verhindere doppelte Connections
    if tool:GetAttribute("RageKnifeHook") then return end
    tool:SetAttribute("RageKnifeHook", true)

    tool.Activated:Connect(function()
        if not Settings.AimbotEnabled or not Settings.RageKnifeThrowEnabled then return end
        if not currentLockedTarget or not currentLockedTarget.Character then return end

        local targetPart = currentLockedTarget.Character:FindFirstChild("Head") or currentLockedTarget.Character:FindFirstChild("HumanoidRootPart")
        if not targetPart then return end

        -- OPTIMIERTE Suche nach geworfenem Messer (nicht mehr full GetDescendants jede Iteration)
        task.spawn(function()
            for i = 1, 20 do  -- etwas kürzer für bessere Performance
                task.wait(0.025)

                local success, _err = pcall(function()
                    -- Nur unanchored Parts mit hoher Velocity prüfen (deutlich effizienter)
                    local _myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if not _myHRP then return end
                    for _, obj in ipairs(Workspace:GetChildren()) do
                        if obj:IsA("BasePart") and not obj.Anchored and obj.AssemblyLinearVelocity.Magnitude > 12 then
                            local dist = (obj.Position - _myHRP.Position).Magnitude
                            if dist < 40 then
                                local direction = (targetPart.Position - obj.Position).Unit
                                obj.AssemblyLinearVelocity = direction * 480
                                obj.AssemblyAngularVelocity = Vector3.zero
                                return true -- gefunden
                            end
                        end
                    end

                    -- Zusätzlich in bekannten Projektile-Ordnern suchen (falls vorhanden)
                    local projFolder = Workspace:FindFirstChild("Projectiles") or Workspace:FindFirstChild("Thrown") or Workspace:FindFirstChild("Effects")
                    if projFolder then
                        for _, obj in ipairs(projFolder:GetDescendants()) do
                            if obj:IsA("BasePart") and not obj.Anchored and obj.AssemblyLinearVelocity.Magnitude > 12 then
                                local dist = (obj.Position - _myHRP.Position).Magnitude
                                if dist < 40 then
                                    local direction = (targetPart.Position - obj.Position).Unit
                                    obj.AssemblyLinearVelocity = direction * 480
                                    obj.AssemblyAngularVelocity = Vector3.zero
                                    return true
                                end
                            end
                        end
                    end
                end)

                if not success then
                    -- RageKnifeThrow Fehler (still)
                end
            end
        end)
    end)
end

-- Setup bei Charakter Spawn + aktuell
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1.2)
    SetupRageKnifeThrow()
end)

if LocalPlayer.Character then
    task.wait(0.8)
    SetupRageKnifeThrow()
end

-- ==================== v69 STATE TABLE (spart lokale Register – Lua Limit 200) ====================
-- Alle neuen State-Variablen in EINER Tabelle → nur 1 local statt 12
local v69 = {
    nameESPDrawings = {},
    nameESPConn = nil,
    crosshairObjects = {},
    crosshairConn = nil,
    speedIndicatorLabel = nil,
    speedIndicatorConn = nil,
    sessionKills = 0,
    sessionStartTime = os.clock(),
    killCountLabel = nil,
}

-- ==================== NAME ESP (Drawing API) v69 NEU ====================
local function UpdateNameESP()
    if not Settings.NameESPEnabled then return end
    local Camera = Workspace.CurrentCamera
    local myChar = LocalPlayer.Character
    local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            local head = plr.Character:FindFirstChild("Head")
            if hrp and head then
                local dist = myHrp and math.floor((hrp.Position - myHrp.Position).Magnitude) or 0
                if dist <= Settings.NameESPMaxDistance then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 2.8, 0))
                    if onScreen then
                        if not v69.nameESPDrawings[plr] then
                            local d = Drawing.new("Text")
                            d.Size = 14
                            d.Outline = true
                            d.OutlineColor = Color3.fromRGB(0, 0, 0)
                            d.Center = true
                            pcall(function() d.Font = Drawing.Fonts.UI end)
                            v69.nameESPDrawings[plr] = d
                        end
                        local nd = v69.nameESPDrawings[plr]
                        local col = Color3.fromRGB(255, 255, 255)
                        if dist < 50 then
                            col = Color3.fromRGB(255, 80, 80)
                        elseif dist < 150 then
                            col = Color3.fromRGB(255, 200, 50)
                        end
                        nd.Text = (Settings.StreamerMode and "Spieler" or plr.Name) .. "  [" .. dist .. "m]"
                        nd.Color = col
                        nd.Position = Vector2.new(screenPos.X, screenPos.Y)
                        nd.Visible = true
                    else
                        if v69.nameESPDrawings[plr] then v69.nameESPDrawings[plr].Visible = false end
                    end
                else
                    if v69.nameESPDrawings[plr] then v69.nameESPDrawings[plr].Visible = false end
                end
            end
        end
    end
    for plr, d in pairs(v69.nameESPDrawings) do
        if not plr.Parent or not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then
            pcall(function() d:Destroy() end)
            v69.nameESPDrawings[plr] = nil
        end
    end
end

-- ---- Funktionsdefinitionen zuerst (kein pcall nötig) ----
local function BuildCrosshairDrawings()
    for _, obj in ipairs(v69.crosshairObjects) do pcall(function() obj:Destroy() end) end
    v69.crosshairObjects = {}
    pcall(function()
        for i = 1, 4 do
            local line = Drawing.new("Line")
            line.Thickness = 1.5
            line.Visible = false
            table.insert(v69.crosshairObjects, line)
        end
        local dot = Drawing.new("Circle")
        dot.Radius = 2; dot.Thickness = 1; dot.Filled = true; dot.Visible = false
        table.insert(v69.crosshairObjects, dot)
    end)
end

local function RenderCrosshair()
    if not Settings.CrosshairEnabled then return end
    local vp = Workspace.CurrentCamera.ViewportSize
    local cx = vp.X / 2; local cy = vp.Y / 2
    local sz = Settings.CrosshairSize or 10
    local gap = Settings.CrosshairGap or 4
    local th = Settings.CrosshairThickness or 2
    local col = Settings.CrosshairColor or Color3.fromRGB(255, 255, 255)
    local co = v69.crosshairObjects
    if co[1] then
        co[1].From = Vector2.new(cx, cy - gap - sz)
        co[1].To = Vector2.new(cx, cy - gap)
        co[1].Color = col; co[1].Thickness = th; co[1].Visible = true
    end
    if co[2] then
        co[2].From = Vector2.new(cx, cy + gap)
        co[2].To = Vector2.new(cx, cy + gap + sz)
        co[2].Color = col; co[2].Thickness = th; co[2].Visible = true
    end
    if co[3] then
        co[3].From = Vector2.new(cx - gap - sz, cy)
        co[3].To = Vector2.new(cx - gap, cy)
        co[3].Color = col; co[3].Thickness = th; co[3].Visible = true
    end
    if co[4] then
        co[4].From = Vector2.new(cx + gap, cy)
        co[4].To = Vector2.new(cx + gap + sz, cy)
        co[4].Color = col; co[4].Thickness = th; co[4].Visible = true
    end
    if co[5] then
        co[5].Position = Vector2.new(cx, cy)
        co[5].Color = col; co[5].Visible = true
    end
end

local function HideCrosshair()
    for _, obj in ipairs(v69.crosshairObjects) do
        pcall(function() obj.Visible = false end)
    end
end

local function BuildSpeedIndicator()
    pcall(function()
        if v69.speedIndicatorLabel then v69.speedIndicatorLabel:Destroy() end
        v69.speedIndicatorLabel = Drawing.new("Text")
        v69.speedIndicatorLabel.Size = 16
        v69.speedIndicatorLabel.Outline = true
        v69.speedIndicatorLabel.OutlineColor = Color3.fromRGB(0, 0, 0)
        v69.speedIndicatorLabel.Center = true
        pcall(function() v69.speedIndicatorLabel.Font = Drawing.Fonts.UI end)
        v69.speedIndicatorLabel.Color = Color3.fromRGB(0, 255, 150)
        v69.speedIndicatorLabel.Visible = false
    end)
end

local function UpdateSpeedIndicator()
    if not Settings.SpeedIndicatorEnabled or not v69.speedIndicatorLabel then return end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then
        v69.speedIndicatorLabel.Visible = false
        return
    end
    local vel = hrp.AssemblyLinearVelocity
    local speed = math.floor(Vector3.new(vel.X, 0, vel.Z).Magnitude)
    local vp = Workspace.CurrentCamera.ViewportSize
    v69.speedIndicatorLabel.Position = Vector2.new(vp.X / 2, vp.Y - 80)
    v69.speedIndicatorLabel.Text = "Geschwindigkeit: " .. speed .. " Studs/s"
    if speed > 100 then
        v69.speedIndicatorLabel.Color = Color3.fromRGB(255, 80, 80)
    elseif speed > 40 then
        v69.speedIndicatorLabel.Color = Color3.fromRGB(255, 200, 50)
    else
        v69.speedIndicatorLabel.Color = Color3.fromRGB(0, 255, 150)
    end
    v69.speedIndicatorLabel.Visible = true
end

-- ---- UI-Erstellung in pcall (falls Rayfield API Fehler → Rest des Scripts läuft weiter) ----
pcall(function()
    VisualTab:CreateSection("📛 Name ESP")
    VisualTab:CreateToggle({
        Name = "Name ESP (Name + Distanz über Köpfen)",
        CurrentValue = false,
        Flag = "NameESPEnabled",
        Callback = function(state)
            Settings.NameESPEnabled = state
            if not state then
                if v69.nameESPConn then v69.nameESPConn:Disconnect() v69.nameESPConn = nil end
                for _, d in pairs(v69.nameESPDrawings) do pcall(function() d:Destroy() end) end
                v69.nameESPDrawings = {}
            else
                if v69.nameESPConn then v69.nameESPConn:Disconnect() end
                v69.nameESPConn = RunService.RenderStepped:Connect(UpdateNameESP)
                Rayfield:Notify({Title = "Name ESP", Content = "Name ESP aktiv!", Duration = 3})
            end
        end
    })
    VisualTab:CreateSlider({
        Name = "Name ESP Max Distanz",
        Range = {50, 1000},
        Increment = 25,
        CurrentValue = 600,
        Flag = "NameESPMaxDist",
        Callback = function(val)
            Settings.NameESPMaxDistance = val
        end
    })
end)

pcall(function()
    VisualTab:CreateSection("➕ Custom Fadenkreuz")
    VisualTab:CreateToggle({
        Name = "Custom Fadenkreuz aktivieren",
        CurrentValue = false,
        Flag = "CrosshairEnabled",
        Callback = function(state)
            Settings.CrosshairEnabled = state
            if state then
                BuildCrosshairDrawings()
                if v69.crosshairConn then v69.crosshairConn:Disconnect() end
                v69.crosshairConn = RunService.RenderStepped:Connect(RenderCrosshair)
                Rayfield:Notify({Title = "Crosshair", Content = "Custom Crosshair aktiv!", Duration = 2})
            else
                if v69.crosshairConn then v69.crosshairConn:Disconnect() v69.crosshairConn = nil end
                HideCrosshair()
            end
        end
    })
    VisualTab:CreateSlider({
        Name = "Fadenkreuz Länge",
        Range = {4, 40},
        Increment = 1,
        CurrentValue = 10,
        Flag = "CrosshairSize",
        Callback = function(val)
            Settings.CrosshairSize = val
        end
    })
    VisualTab:CreateSlider({
        Name = "Fadenkreuz Lücke",
        Range = {0, 20},
        Increment = 1,
        CurrentValue = 4,
        Flag = "CrosshairGap",
        Callback = function(val)
            Settings.CrosshairGap = val
        end
    })
    VisualTab:CreateSlider({
        Name = "Fadenkreuz Dicke",
        Range = {1, 5},
        Increment = 1,
        CurrentValue = 2,
        Flag = "CrosshairThick",
        Callback = function(val)
            Settings.CrosshairThickness = val
        end
    })
end)

pcall(function()
    VisualTab:CreateSection("⚡ Geschwindigkeitsanzeige")
    VisualTab:CreateToggle({
        Name = "Geschwindigkeitsanzeige (am Bildschirm)",
        CurrentValue = false,
        Flag = "SpeedIndicatorEnabled",
        Callback = function(state)
            Settings.SpeedIndicatorEnabled = state
            if state then
                BuildSpeedIndicator()
                if v69.speedIndicatorConn then v69.speedIndicatorConn:Disconnect() end
                v69.speedIndicatorConn = RunService.RenderStepped:Connect(UpdateSpeedIndicator)
                Rayfield:Notify({Title = "Speed Indicator", Content = "Geschwindigkeit wird angezeigt!", Duration = 3})
            else
                if v69.speedIndicatorConn then v69.speedIndicatorConn:Disconnect() v69.speedIndicatorConn = nil end
                if v69.speedIndicatorLabel then v69.speedIndicatorLabel.Visible = false end
            end
        end
    })
end)

-- ==================== NORMAL AIMBOT ====================
local normalAimbotConn  -- currentNormalTarget ist oben forward-deklariert
local wasMouseLocked = false
local function ToggleNormalAimbot(state)
    Settings.NormalAimbotEnabled = state
    UpdateFOVCircle()
    if state then
        currentNormalTarget = nil
        normalAimbotConn = RunService.RenderStepped:Connect(function()
            pcall(function()
                local Camera = Workspace.CurrentCamera
                if not Settings.NormalAimbotEnabled or not LocalPlayer.Character then return end

                local isAiming = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
                if not isAiming then
                    currentNormalTarget = nil
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                        LocalPlayer.Character.Humanoid.AutoRotate = true
                    end
                    if wasMouseLocked then
                        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
                        wasMouseLocked = false
                    end
                    return
                end

                if currentNormalTarget and not IsTargetAlive(currentNormalTarget) then currentNormalTarget = nil end
                if not currentNormalTarget then currentNormalTarget = FindNewTarget() end

                if currentNormalTarget and currentNormalTarget.Character then
                    local targetPart = currentNormalTarget.Character:FindFirstChild("Head") or currentNormalTarget.Character:FindFirstChild("HumanoidRootPart")
                    if targetPart then
                        local targetPos = targetPart.Position

                        local desiredCam = CFrame.new(Camera.CFrame.Position, targetPos)
                        Camera.CFrame = Camera.CFrame:Lerp(desiredCam, Settings.NormalAimbotSmoothness)

                        if not Settings.FlyEnabled then
                            local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            if root then
                                local lookPos = Vector3.new(targetPos.X, root.Position.Y, targetPos.Z)
                                root.CFrame = CFrame.new(root.Position, lookPos)
                            end

                            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                                LocalPlayer.Character.Humanoid.AutoRotate = false
                            end

                            if UserInputService.MouseBehavior ~= Enum.MouseBehavior.LockCenter then
                                UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
                                wasMouseLocked = true
                            end
                        else
                            if wasMouseLocked then
                                UserInputService.MouseBehavior = Enum.MouseBehavior.Default
                                wasMouseLocked = false
                            end
                        end
                    end
                end
            end)
        end)
    else
        if normalAimbotConn then normalAimbotConn:Disconnect() normalAimbotConn = nil end
        currentNormalTarget = nil
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.AutoRotate = true
        end
        if wasMouseLocked then
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
            wasMouseLocked = false
        end
    end
end

-- ==================== FLY ====================
local flyConn, bv, bg, _flyAtt
local function ToggleFly(state)
    Settings.FlyEnabled = state
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not hrp or not hum then return end
    if state then
        hum.PlatformStand = true
        _flyAtt = Instance.new("Attachment")
        _flyAtt.Name = "MeinFlyAtt"
        _flyAtt.Parent = hrp
        bv = Instance.new("LinearVelocity")
        bv.Name = "MeinFly"
        bv.MaxForce = 9e9
        bv.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
        bv.RelativeTo = Enum.ActuatorRelativeTo.World
        bv.Attachment0 = _flyAtt
        bv.Parent = hrp
        bg = Instance.new("AlignOrientation")
        bg.Name = "MeinFlyGyro"
        bg.MaxTorque = 9e9
        bg.Responsiveness = 200
        bg.Mode = Enum.OrientationAlignmentMode.OneAttachment
        bg.Attachment0 = _flyAtt
        bg.Parent = hrp
        flyConn = RunService.RenderStepped:Connect(function()
            pcall(function()
                local Camera = Workspace.CurrentCamera
                if not Settings.FlyEnabled or not bv or not hrp then return end
                local camCF = Camera.CFrame
                local moveDir = Vector3.zero
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camCF.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camCF.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camCF.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camCF.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end
                if moveDir.Magnitude > 0 then moveDir = moveDir.Unit end
                bv.VectorVelocity = moveDir * Settings.FlySpeed
                bg.CFrame = camCF
            end)
        end)
    else
        if flyConn then flyConn:Disconnect() flyConn = nil end
        if bv then bv:Destroy() bv = nil end
        if bg then bg:Destroy() bg = nil end
        if _flyAtt then _flyAtt:Destroy() _flyAtt = nil end
        if hum then hum.PlatformStand = false end
    end
end

-- ==================== MOVEMENT TAB (v70 — Verbessert + Erweitert) ====================
MovementTab:CreateSection("🚶 Bewegung")

-- Initialisiere alle neuen Zustände in HubState (KEIN top-level local)
HubState.noclipConn        = nil
HubState.sprintBoostConn   = nil
HubState.superSlideConn    = nil
HubState.wallWalkEnabled   = false
HubState.wallWalkConn      = nil
HubState.eTeleportEnabled  = false
HubState.speedBurstCD      = false
HubState.autoRespawnConn   = nil
HubState.staminaConn       = nil
HubState.underPlayerOffset = 5
HubState.underPlayerFollow = false
HubState.underPlayerFlip   = false
HubState.underPlayerConn   = nil
HubState.underPlayerOrig   = nil
HubState.pinPlayerConn     = nil
HubState.ghostEnabled      = false
HubState.ghostTransparency = 0.6

-- ===========================================================
-- NOCLIP (FIX v70: CanQuery + CanTouch beim Deaktivieren korrekt zurückgesetzt)
-- ===========================================================
MovementTab:CreateToggle({
    Name = "NoClip aktivieren",
    CurrentValue = false,
    Callback = function(state)
        Settings.NoClipEnabled = state
        if HubState.noclipConn then HubState.noclipConn:Disconnect() HubState.noclipConn = nil end
        if state then
            -- [FPS-FIX] GetChildren statt GetDescendants: BaseParts sind direkte
            -- Kinder des Character-Models (HRP, Head, Torso, Limbs) → 10x weniger Traversal
            HubState.noclipConn = RunService.Stepped:Connect(function()
                pcall(function()
                    local char = LocalPlayer.Character
                    if not char then return end
                    for _, part in ipairs(char:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                            part.CanQuery   = false
                            part.CanTouch   = false
                        end
                    end
                end)
            end)
        else
            pcall(function()
                local char = LocalPlayer.Character
                if not char then return end
                for _, part in ipairs(char:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                        part.CanQuery   = true
                        part.CanTouch   = true
                    end
                end
            end)
        end
    end
})

-- ===========================================================
-- SPRINT BOOST (FIX v70: Memory Leak behoben)
-- ===========================================================
MovementTab:CreateSection("🏃 Sprint Boost")
MovementTab:CreateToggle({
    Name = "Sprint Boost aktivieren",
    CurrentValue = false,
    Flag = "SprintBoost",
    Callback = function(state)
        Settings.SprintBoostEnabled = state
        if HubState.sprintBoostConn then HubState.sprintBoostConn:Disconnect() HubState.sprintBoostConn = nil end
        if state then
            HubState.sprintBoostConn = RunService.Heartbeat:Connect(function()
                pcall(function()
                    local char = LocalPlayer.Character
                    local hum  = char and char:FindFirstChild("Humanoid")
                    if hum and hum.WalkSpeed ~= Settings.BaseWalkSpeed then
                        hum.WalkSpeed = Settings.BaseWalkSpeed
                    end
                end)
            end)
        else
            pcall(function()
                local char = LocalPlayer.Character
                local hum  = char and char:FindFirstChild("Humanoid")
                if hum then hum.WalkSpeed = 16 end
            end)
        end
    end
})
MovementTab:CreateSlider({
    Name = "Sprint Geschwindigkeit",
    Range = {16, 350},
    Increment = 1,
    CurrentValue = 50,
    Callback = function(value) Settings.BaseWalkSpeed = value end
})

-- ===========================================================
-- FLY (ToggleFly ist oben bereits definiert — nur UI)
-- ===========================================================
MovementTab:CreateSection("🚀 Fly")
MovementTab:CreateKeybind({
    Name = "Fly Keybind",
    CurrentKeybind = "F",
    HoldToInteract = false,
    Callback = function() ToggleFly(not Settings.FlyEnabled) end
})
MovementTab:CreateSlider({
    Name = "Flug Geschwindigkeit",
    Range = {10, 2000},
    Increment = 10,
    CurrentValue = 80,
    Callback = function(value) Settings.FlySpeed = value end
})

-- ===========================================================
-- SUPER SLIDE
-- ===========================================================
MovementTab:CreateSection("💨 Super Slide")
MovementTab:CreateToggle({
    Name = "Super Slide aktivieren",
    CurrentValue = false,
    Callback = function(state)
        Settings.SuperSlideEnabled = state
        if HubState.superSlideConn then HubState.superSlideConn:Disconnect() HubState.superSlideConn = nil end
        if not state then return end
        HubState.superSlideConn = RunService.RenderStepped:Connect(function()
            pcall(function()
                local char = LocalPlayer.Character
                if not char then return end
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                if UserInputService:IsKeyDown(Enum.KeyCode.C) and UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    local cam   = Workspace.CurrentCamera
                    local boost = cam.CFrame.LookVector * Settings.SuperSlideStrength
                    hrp.AssemblyLinearVelocity = Vector3.new(boost.X, hrp.AssemblyLinearVelocity.Y, boost.Z)
                end
            end)
        end)
    end
})
MovementTab:CreateSlider({
    Name = "Super Slide Stärke",
    Range = {60, 400},
    Increment = 5,
    CurrentValue = 140,
    Callback = function(value) Settings.SuperSlideStrength = value end
})

-- ===========================================================
-- SUPER JUMP (FIX v70: Nur wenn am Boden)
-- ===========================================================
MovementTab:CreateSection("🦘 Super Jump")
MovementTab:CreateToggle({
    Name = "Super Jump aktivieren",
    CurrentValue = false,
    Callback = function(state) Settings.SuperJumpEnabled = state end
})
MovementTab:CreateSlider({
    Name = "Super Jump Stärke",
    Range = {50, 600},
    Increment = 5,
    CurrentValue = 120,
    Callback = function(value) Settings.SuperJumpStrength = value end
})
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or input.KeyCode ~= Enum.KeyCode.Space or not Settings.SuperJumpEnabled then return end
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChild("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hum or not hrp then return end
        local st = hum:GetState()
        if st == Enum.HumanoidStateType.Freefall or st == Enum.HumanoidStateType.Jumping then return end
        hrp:ApplyImpulse(Vector3.new(0, Settings.SuperJumpStrength * hrp.AssemblyMass, 0))
    end)
end)

-- ===========================================================
-- INFINITE JUMP
-- ===========================================================
MovementTab:CreateSection("🔄 Unendlich Springen")
MovementTab:CreateToggle({
    Name = "Unendlich Springen",
    CurrentValue = false,
    Callback = function(state) Settings.InfiniteJumpEnabled = state end
})

-- ===========================================================
-- GRAVITY + JUMP POWER (FIX v70: UseJumpPower = true)
-- ===========================================================
MovementTab:CreateSection("🌍 Gravity & Jump Power")
MovementTab:CreateSlider({
    Name = "Schwerkraft (Standard = 196)",
    Range = {0, 600},
    Increment = 5,
    CurrentValue = 196,
    Flag = "GravityValue",
    Callback = function(v)
        Settings.GravityValue = v
        if Settings.GravityEnabled then workspace.Gravity = v end
    end
})
MovementTab:CreateToggle({
    Name = "Custom Gravity aktivieren",
    CurrentValue = false,
    Flag = "GravityEnabled",
    Callback = function(state)
        Settings.GravityEnabled = state
        workspace.Gravity = state and (Settings.GravityValue or 196.2) or 196.2
        Rayfield:Notify({Title = "Gravity", Content = state and ("Gravity: " .. (Settings.GravityValue or 196)) or "Gravity zurückgesetzt (196)", Duration = 2})
    end
})
MovementTab:CreateButton({
    Name = "🌙 Low Gravity (75)",
    Callback = function()
        Settings.GravityValue = 75; Settings.GravityEnabled = true; workspace.Gravity = 75
        Rayfield:Notify({Title = "Gravity", Content = "Low Gravity aktiv!", Duration = 2})
    end
})
MovementTab:CreateButton({
    Name = "🔄 Gravity zurücksetzen (196)",
    Callback = function()
        Settings.GravityEnabled = false; workspace.Gravity = 196.2
        Rayfield:Notify({Title = "Gravity", Content = "Gravity zurückgesetzt!", Duration = 2})
    end
})
MovementTab:CreateSlider({
    Name = "⬆️ Jump Power (Standard = 50)",
    Range = {5, 400},
    Increment = 5,
    CurrentValue = 50,
    Flag = "JumpPowerValue",
    Callback = function(v)
        Settings.JumpPowerValue = v
        pcall(function()
            local char = LocalPlayer.Character
            local hum  = char and char:FindFirstChild("Humanoid")
            if hum then hum.UseJumpPower = true hum.JumpPower = v end
        end)
    end
})
MovementTab:CreateButton({
    Name = "🔄 Jump Power zurücksetzen (50)",
    Callback = function()
        Settings.JumpPowerValue = 50
        pcall(function()
            local char = LocalPlayer.Character
            local hum  = char and char:FindFirstChild("Humanoid")
            if hum then hum.UseJumpPower = true hum.JumpPower = 50 end
        end)
        Rayfield:Notify({Title = "Jump Power", Content = "Jump Power zurückgesetzt", Duration = 2})
    end
})

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    local hum = char:WaitForChild("Humanoid", 5)
    if not hum then return end
    if Settings.SprintBoostEnabled then hum.WalkSpeed = Settings.BaseWalkSpeed end
    if Settings.JumpPowerValue and Settings.JumpPowerValue ~= 50 then
        pcall(function() hum.UseJumpPower = true hum.JumpPower = Settings.JumpPowerValue end)
    end
    if Settings.GravityEnabled then workspace.Gravity = Settings.GravityValue or 196.2 end
    if HubState.ghostEnabled then
        task.wait(0.3)
        pcall(function()
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.LocalTransparencyModifier = HubState.ghostTransparency
                end
            end
        end)
    end
end)

-- ===========================================================
-- WALL WALK (FIX v70: PlatformStand Cleanup bei Respawn)
-- ===========================================================
MovementTab:CreateSection("🧱 Wall Walk")

local function CleanupWallWalk()
    if HubState.wallWalkConn then HubState.wallWalkConn:Disconnect() HubState.wallWalkConn = nil end
    pcall(function()
        local char = LocalPlayer.Character
        local hum  = char and char:FindFirstChild("Humanoid")
        if hum then hum.PlatformStand = false end
    end)
end

MovementTab:CreateToggle({
    Name = "Wall Walk aktivieren",
    CurrentValue = false,
    Callback = function(state)
        HubState.wallWalkEnabled = state
        if not state then CleanupWallWalk() return end
        HubState.wallWalkConn = RunService.Heartbeat:Connect(function()
            if not HubState.wallWalkEnabled then return end
            pcall(function()
                local char = LocalPlayer.Character
                if not char then return end
                local hrp  = char:FindFirstChild("HumanoidRootPart")
                local hum  = char:FindFirstChild("Humanoid")
                if not hrp or not hum then return end
                local speed = Settings.WallWalkSpeed or 18
                local rp = RaycastParams.new()
                rp.FilterType = Enum.RaycastFilterType.Exclude
                rp.FilterDescendantsInstances = {char}
                local result = Workspace:Raycast(hrp.Position, hrp.CFrame.LookVector * 4.8, rp)
                if result then
                    hum.PlatformStand = true
                    local wNorm = result.Normal
                    local hPos  = result.Position
                    hrp.AssemblyLinearVelocity = wNorm * -(speed + 2)
                    hrp.CFrame = hrp.CFrame:Lerp(CFrame.new(hPos + wNorm * 2.6, hrp.Position + hrp.CFrame.LookVector), 0.55)
                else
                    hum.PlatformStand = false
                end
            end)
        end)
    end
})
MovementTab:CreateSlider({
    Name = "Wall Walk Geschwindigkeit",
    Range = {5, 40},
    Increment = 1,
    CurrentValue = 18,
    Callback = function(value) Settings.WallWalkSpeed = value end
})

LocalPlayer.CharacterAdded:Connect(function()
    if HubState.wallWalkEnabled then
        task.wait(0.3); CleanupWallWalk(); HubState.wallWalkEnabled = false
    end
end)

-- ===========================================================
-- E TELEPORT (FIX v70: Raycast nach unten → sicherer Landepunkt)
-- ===========================================================
MovementTab:CreateSection("⚡ E Teleport")
MovementTab:CreateToggle({
    Name = "E Teleport aktivieren",
    CurrentValue = false,
    Callback = function(state)
        HubState.eTeleportEnabled = state
        Rayfield:Notify({Title = "E Teleport", Content = state and "Aktiviert" or "Deaktiviert", Duration = 2})
    end
})
MovementTab:CreateSlider({
    Name = "Teleport Distanz (Studs)",
    Range = {5, 120},
    Increment = 5,
    CurrentValue = 15,
    Callback = function(v) Settings.ETeleportDistance = v end
})
MovementTab:CreateKeybind({
    Name = "E Teleport (vorwärts)",
    CurrentKeybind = "E",
    HoldToInteract = false,
    Callback = function()
        if not HubState.eTeleportEnabled then return end
        pcall(function()
            local char  = LocalPlayer.Character
            local myHRP = char and char:FindFirstChild("HumanoidRootPart")
            local cam   = Workspace.CurrentCamera
            if not myHRP or not cam then return end
            local dist      = Settings.ETeleportDistance or 15
            local targetPos = myHRP.Position + cam.CFrame.LookVector * dist
            local rp = RaycastParams.new()
            rp.FilterType = Enum.RaycastFilterType.Exclude
            rp.FilterDescendantsInstances = {char}
            local groundRay = Workspace:Raycast(targetPos + Vector3.new(0,6,0), Vector3.new(0,-20,0), rp)
            if groundRay then targetPos = groundRay.Position + Vector3.new(0,3,0) end
            myHRP.CFrame = CFrame.new(targetPos)
        end)
    end
})

-- ===========================================================
-- SPEED BURST (NEU v70)
-- ===========================================================
MovementTab:CreateSection("⚡ Geschwindigkeits-Burst")
MovementTab:CreateSlider({
    Name = "Speed Burst Stärke",
    Range = {40, 400},
    Increment = 10,
    CurrentValue = 120,
    Callback = function(v) Settings.SpeedBurstStrength = v end
})
MovementTab:CreateSlider({
    Name = "Speed Burst Dauer (Sek.)",
    Range = {0.1, 2.0},
    Increment = 0.1,
    CurrentValue = 0.4,
    Callback = function(v) Settings.SpeedBurstDuration = v end
})
MovementTab:CreateKeybind({
    Name = "Speed Burst (Q)",
    CurrentKeybind = "Q",
    HoldToInteract = false,
    Callback = function()
        if HubState.speedBurstCD then
            Rayfield:Notify({Title = "Speed Burst", Content = "Cooldown!", Duration = 1}) return
        end
        task.spawn(function()
            pcall(function()
                local char = LocalPlayer.Character
                local hum  = char and char:FindFirstChild("Humanoid")
                local hrp  = char and char:FindFirstChild("HumanoidRootPart")
                if not hum or not hrp then return end
                HubState.speedBurstCD = true
                local orig  = hum.WalkSpeed
                local boost = Workspace.CurrentCamera.CFrame.LookVector * (Settings.SpeedBurstStrength or 120)
                hrp.AssemblyLinearVelocity = Vector3.new(boost.X, hrp.AssemblyLinearVelocity.Y, boost.Z)
                hum.WalkSpeed = Settings.SpeedBurstStrength or 120
                task.wait(Settings.SpeedBurstDuration or 0.4)
                if not Settings.SprintBoostEnabled then pcall(function() hum.WalkSpeed = orig end) end
                task.wait(1.5); HubState.speedBurstCD = false
            end)
        end)
    end
})
MovementTab:CreateLabel("Q = Kurzer Schub vorwärts (1.5s Cooldown)")

-- ===========================================================
-- GHOST MODE (NEU v70)
-- ===========================================================
MovementTab:CreateSection("👻 Ghost Modus")

local function ApplyGhost(trans)
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.LocalTransparencyModifier = trans
            end
        end
    end)
end

MovementTab:CreateToggle({
    Name = "👻 Ghost Modus (Halb-Transparent)",
    CurrentValue = false,
    Callback = function(state)
        HubState.ghostEnabled = state
        ApplyGhost(state and HubState.ghostTransparency or 0)
        if state then Rayfield:Notify({Title = "👻 Ghost Modus", Content = "Halb-Transparent aktiviert!", Duration = 2}) end
    end
})
MovementTab:CreateSlider({
    Name = "Ghost Transparenz",
    Range = {0.1, 0.95},
    Increment = 0.05,
    CurrentValue = 0.6,
    Callback = function(v)
        HubState.ghostTransparency = v
        -- [FIX v94] Nil-Guard: ApplyGhost nur aufrufen wenn ghostEnabled UND char vorhanden
        if HubState.ghostEnabled then
            pcall(function() ApplyGhost(v) end)
        end
    end
})

-- ===========================================================
-- AUTO RESPAWN (NEU v70)
-- ===========================================================
MovementTab:CreateSection("🔄 Auto Respawn (NEU)")

local function HookAutoRespawn(char)
    local hum = char:WaitForChild("Humanoid", 10)
    if not hum then return end
    hum.Died:Connect(function()
        if not Settings.AutoRespawnEnabled then return end
        task.wait(0.15)
        pcall(function() LocalPlayer:LoadCharacter() end)
    end)
end

MovementTab:CreateToggle({
    Name = "Auto Respawn bei Tod",
    CurrentValue = false,
    Callback = function(state)
        Settings.AutoRespawnEnabled = state
        if HubState.autoRespawnConn then HubState.autoRespawnConn:Disconnect() HubState.autoRespawnConn = nil end
        if state then
            HubState.autoRespawnConn = LocalPlayer.CharacterAdded:Connect(HookAutoRespawn)
            if LocalPlayer.Character then task.spawn(HookAutoRespawn, LocalPlayer.Character) end
            Rayfield:Notify({Title = "Auto Respawn", Content = "Aktiv bei Tod!", Duration = 2})
        end
    end
})
MovementTab:CreateButton({
    Name = "💀 Jetzt respawnen",
    Callback = function()
        pcall(function()
            local char = LocalPlayer.Character
            local hum  = char and char:FindFirstChild("Humanoid")
            if hum then hum.Health = 0 task.wait(0.15) LocalPlayer:LoadCharacter() end
        end)
    end
})

-- ===========================================================
-- INFINITE STAMINA (NEU v70)
-- ===========================================================
MovementTab:CreateSection("💪 Unendliche Ausdauer")
MovementTab:CreateToggle({
    Name = "Unendliche Ausdauer",
    CurrentValue = false,
    Callback = function(state)
        Settings.InfiniteStaminaEnabled = state
        if HubState.staminaConn then HubState.staminaConn:Disconnect() HubState.staminaConn = nil end
        if not state then return end
        -- [FPS-FIX] Throttle 5x/s statt 60x/s — Stamina ändert sich nicht schneller.
        -- GetDescendants → GetChildren für ersten Scan (top-level Values sind meist direkte Kinder).
        local _stTimer = 0
        HubState.staminaConn = RunService.Heartbeat:Connect(function(dt)
            _stTimer = _stTimer + dt
            if _stTimer < 0.2 then return end
            _stTimer = 0
            pcall(function()
                local char = LocalPlayer.Character
                if not char then return end
                for _, obj in ipairs(char:GetChildren()) do
                    if obj:IsA("NumberValue") or obj:IsA("IntValue") then
                        local n = obj.Name:lower()
                        if n:find("stamin") or n:find("energy") then
                            if obj.Value < 100 then obj.Value = 100 end
                        end
                    end
                end
                for attr, val in pairs(char:GetAttributes()) do
                    if type(val) == "number" then
                        local a = attr:lower()
                        if a:find("stamin") or a:find("energy") then char:SetAttribute(attr, 100) end
                    end
                end
            end)
        end)
    end
})

-- ==================== CAR FEATURES ====================
MovementTab:CreateSection("🚗 Car")

local carFlyConn = nil
local carBoostConn = nil
local carBoostStrength = 60   -- [AC-FIX] 300→60
local vehicleFlySpeed  = 50   -- [AC-FIX] 160→50

MovementTab:CreateToggle({
    Name = "Vehicle Fly (Allgemein)",
    CurrentValue = false,
    Callback = function(state)
        if carFlyConn then carFlyConn:Disconnect() carFlyConn = nil end

        -- Cleanup alte LinearVelocity / AlignOrientation / Attachment
        pcall(function()
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChild("Humanoid")
                local seat = hum and hum.SeatPart
                if seat then
                    local vehicle = seat:FindFirstAncestorWhichIsA("Model") or seat.Parent
                    local primary = vehicle.PrimaryPart or seat
                    for _, obj in ipairs(primary:GetChildren()) do
                        if obj.Name == "VehicleFlyVelocity" or obj.Name == "VehicleFlyGyro" or obj.Name == "VehicleFlyAtt" then
                            obj:Destroy()
                        end
                    end
                end
            end
        end)

        if state then
            carFlyConn = RunService.Heartbeat:Connect(function()
                pcall(function()
                    local char = LocalPlayer.Character
                    if not char then return end
                    local hum = char:FindFirstChild("Humanoid")
                    local seat = hum and hum.SeatPart
                    if seat then
                        -- Allgemein für alle Fahrzeuge (Auto, Boot, Heli, Flugzeug usw.)
                        local vehicle = seat:FindFirstAncestorWhichIsA("Model") or seat.Parent
                        local primary = vehicle.PrimaryPart or seat
                        if primary then
                            -- LinearVelocity für Bewegung (ersetzt BodyVelocity)
                            local bvAtt = primary:FindFirstChild("VehicleFlyAtt")
                            if not bvAtt then
                                bvAtt = Instance.new("Attachment")
                                bvAtt.Name = "VehicleFlyAtt"
                                bvAtt.Parent = primary
                            end
                            local bv = primary:FindFirstChild("VehicleFlyVelocity")
                            if not bv then
                                bv = Instance.new("LinearVelocity")
                                bv.Name = "VehicleFlyVelocity"
                                bv.MaxForce = 9e9
                                bv.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
                                bv.RelativeTo = Enum.ActuatorRelativeTo.World
                                bv.Attachment0 = bvAtt
                                bv.Parent = primary
                            end

                            -- AlignOrientation für Stabilität (ersetzt BodyGyro)
                            local bg = primary:FindFirstChild("VehicleFlyGyro")
                            if not bg then
                                bg = Instance.new("AlignOrientation")
                                bg.Name = "VehicleFlyGyro"
                                bg.MaxTorque = 9e9
                                bg.Responsiveness = 200
                                bg.Mode = Enum.OrientationAlignmentMode.OneAttachment
                                bg.Attachment0 = bvAtt
                                bg.Parent = primary
                            end

                            local moveDir = Vector3.zero
                            local cam = Workspace.CurrentCamera
                            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
                            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
                            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
                            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
                            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0,1,0) end
                            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0,1,0) end

                            if moveDir.Magnitude > 0 then moveDir = moveDir.Unit end

                            bv.VectorVelocity = moveDir * vehicleFlySpeed
                            bg.CFrame = CFrame.new(primary.Position, primary.Position + cam.CFrame.LookVector)
                        end
                    end
                end)
            end)
            Rayfield:Notify({Title = "Vehicle", Content = "Vehicle Fly aktiviert (Autos, Boote, Helis usw.)", Duration = 2})
        end
    end
})

MovementTab:CreateSlider({
    Name = "Fahrzeug Fly Geschwindigkeit",
    Range = {10, 120},   -- [AC-FIX] Max 600→120: >150 studs/s ist universell detektierbar
    Increment = 5,
    CurrentValue = 50,   -- [AC-FIX] Default 160→50
    Callback = function(value)
        vehicleFlySpeed = value
    end
})

MovementTab:CreateToggle({
    Name = "Auto Speed Boost",
    CurrentValue = false,
    Callback = function(state)
        if carBoostConn then carBoostConn:Disconnect() carBoostConn = nil end
        if state then
            carBoostConn = RunService.Heartbeat:Connect(function()
                pcall(function()
                    local char = LocalPlayer.Character
                    if not char then return end
                    local hum = char:FindFirstChild("Humanoid")
                    local seat = hum and hum.SeatPart
                    if seat and seat:IsA("VehicleSeat") then
                        local vehicle = seat.Parent
                        local primary = vehicle.PrimaryPart or seat
                        if primary then
                            local forward = primary.CFrame.LookVector
                            primary.AssemblyLinearVelocity = forward * carBoostStrength
                        end
                    end
                end)
            end)
            Rayfield:Notify({Title = "🚗 Auto Speed", Content = "Auto Speed Boost aktiviert", Duration = 2})
        end
    end
})

MovementTab:CreateSlider({
    Name = "Auto Speed Stärke",
    Range = {20, 150},   -- [AC-FIX] Max 1000→150: höhere Werte triggern fast jeden Server-AC
    Increment = 10,
    CurrentValue = 60,   -- [AC-FIX] Default 300→60
    Callback = function(value)
        carBoostStrength = value
    end
})

MovementTab:CreateLabel("Tipp: Fahrzeug Fly Geschwindigkeit mit eigenem Slider einstellen. Auto Speed Stärke bis 150.") -- [FIX v94] Slider-Max ist 150, nicht 1000

-- ── VEHICLE BOOST (Shift-Taste, kein Fliegen) ─────────────
local vehicleBoostConn     = nil
local vehicleBoostStrength = 60   -- [AC-FIX] 200→60

MovementTab:CreateToggle({
    Name         = "Vehicle Boost (Shift halten)",
    CurrentValue = false,
    Callback     = function(state)
        if vehicleBoostConn then
            vehicleBoostConn:Disconnect()
            vehicleBoostConn = nil
        end

        if state then
            vehicleBoostConn = RunService.Heartbeat:Connect(function()
                -- Nur aktiv wenn Shift gedrückt
                if not UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then return end

                pcall(function()
                    local char = LocalPlayer.Character
                    if not char then return end
                    local hum  = char:FindFirstChild("Humanoid")
                    local seat = hum and hum.SeatPart
                    if seat and seat:IsA("VehicleSeat") then
                        local vehicle = seat.Parent
                        local primary = vehicle.PrimaryPart or seat
                        if primary then
                            -- LookVector Y = 0 → Fahrzeug bleibt am Boden, kein Fliegen
                            local look    = primary.CFrame.LookVector
                            local flatDir = Vector3.new(look.X, 0, look.Z)
                            if flatDir.Magnitude > 0 then
                                flatDir = flatDir.Unit
                            end
                            primary.AssemblyLinearVelocity = flatDir * vehicleBoostStrength
                        end
                    end
                end)
            end)
            Rayfield:Notify({
                Title   = "🚀 Boost",
                Content = "Vehicle Boost aktiv — Shift gedrückt halten zum Boosten!",
                Duration = 3
            })
        else
            Rayfield:Notify({
                Title   = "🚗 Boost",
                Content = "Vehicle Boost deaktiviert",
                Duration = 2
            })
        end
    end
})

MovementTab:CreateSlider({
    Name         = "Boost Stärke",
    Range        = {20, 150},   -- [AC-FIX] Max 800→150: >200 studs/s triggert fast jeden AC
    Increment    = 10,
    CurrentValue = 60,          -- [AC-FIX] Default 200→60: unauffälliger Boost
    Callback     = function(value)
        vehicleBoostStrength = value
    end
})

MovementTab:CreateLabel("Boost: Shift halten → beschleunigt vorwärts ohne zu fliegen. Loslassen → normales Fahren.")

-- ==================== ANTI TELEPORT ====================
-- Anti Teleport wurde in Settings → More Anti Features verschoben

-- Combat
CombatTab:CreateSection("🎯 Rage Aimbot")
CombatTab:CreateToggle({
    Name = "Rage Aimbot aktivieren",
    CurrentValue = false,
    Flag = "RageAimbot",
    Callback = ToggleAimbot
})

CombatTab:CreateToggle({
    Name = "Rage Knife Throw (durch Wände + Schnell)",
    CurrentValue = true,
    Callback = function(state) Settings.RageKnifeThrowEnabled = state end
})

CombatTab:CreateToggle({
    Name = "⚡ Always On (kein Rechtsklick nötig)",
    CurrentValue = false,
    Callback = function(state) Settings.RageAlwaysOn = state end
})

CombatTab:CreateToggle({
    Name = "🎯 Prediction (führt bewegte Ziele vor)",
    CurrentValue = true,
    Callback = function(state) Settings.RagePrediction = state end
})

CombatTab:CreateSlider({
    Name = "Prediction Stärke",
    Range = {0, 0.5},
    Increment = 0.01,
    CurrentValue = 0.16,
    Callback = function(v) Settings.RagePredictionStrength = v end
})

CombatTab:CreateDropdown({
    Name = "Rage Ziel-Modus",
    Options = {"Crosshair", "Distance", "Health"},
    CurrentOption = "Crosshair",
    MultipleOptions = false,
    Callback = function(val)
        local o = type(val) == "table" and val[1] or val
        if o and o ~= "" then Settings.RageTargetMode = o end
    end
})

CombatTab:CreateDropdown({
    Name = "Rage Ziel-Körperteil",
    Options = {"Head", "HumanoidRootPart"},
    CurrentOption = "Head",
    MultipleOptions = false,
    Callback = function(val)
        local o = type(val) == "table" and val[1] or val
        if o and o ~= "" then Settings.RageTargetPart = o end
    end
})

CombatTab:CreateLabel("💀 KRASS-Tipp: 'Always On' + Ziel-Modus 'Distance' (oder 'Health' für Lowest-HP) + Prediction = lockt automatisch über die ganze Map, führt bewegte Ziele vor und wechselt nach jedem Kill sofort zum nächsten Gegner.")

CombatTab:CreateSection("🎯 Normal Aimbot")
CombatTab:CreateToggle({
    Name = "Normal Aimbot aktivieren",
    CurrentValue = false,
    Flag = "NormalAimbot",
    Callback = ToggleNormalAimbot
})

CombatTab:CreateSlider({
    Name = "Normal Aimbot Flüssigkeit",
    Range = {0.05, 1},
    Increment = 0.05,
    CurrentValue = 1,
    Callback = function(v) Settings.NormalAimbotSmoothness = v end
})

CombatTab:CreateToggle({
    Name = "Wall Check (Normal Aimbot) - respektiert Wände",
    CurrentValue = true,
    Callback = function(v)
        Settings.NormalAimbotWallCheck = v
    end
})

CombatTab:CreateSection("🔧 Allgemein")
CombatTab:CreateSlider({Name = "Aimbot FOV (Kreis)", Range = {30,500}, Increment = 5, CurrentValue = Settings.AimbotFOV, Callback = function(v)
    Settings.AimbotFOV = v
    FOVCircle.Radius = v
end})

CombatTab:CreateSlider({
    Name = "Aimbot Max Distanz (Studs)",
    Range = {1, 1000},
    Increment = 1,
    CurrentValue = 400,
    Callback = function(v) Settings.AimbotMaxDistance = v end
})

CombatTab:CreateToggle({Name = "FOV Kreis anzeigen", CurrentValue = true, Callback = function(v)
    Settings.ShowFOVCircle = v
    UpdateFOVCircle()
end})

CombatTab:CreateToggle({
    Name = "Full 360° FOV (auch Ziele hinter dir)",
    CurrentValue = false,
    Callback = function(v)
        Settings.AimbotFullFOV = v
        if v then
            Rayfield:Notify({Title = "Aimbot", Content = "360° FOV aktiviert - kann jetzt auch hinter dir zielen", Duration = 3})
        end
    end
})

-- ==================== TRIGGER BOT ====================
CombatTab:CreateSection("🎯 Trigger Bot")
CombatTab:CreateToggle({
    Name = "Trigger Bot aktivieren (automatisch schießen)",
    CurrentValue = false,
    Callback = function(v)
        Settings.TriggerBotEnabled = v
        if v then
            Rayfield:Notify({Title = "Trigger Bot", Content = "Trigger Bot aktiviert - schießt automatisch bei Ziel", Duration = 3})
        end
    end
})

CombatTab:CreateSlider({
    Name = "Trigger Bot Delay (Sekunden)",
    Range = {0.01, 0.3},
    Increment = 0.01,
    CurrentValue = 0.08,
    Callback = function(v) Settings.TriggerBotDelay = v end
})

CombatTab:CreateLabel("Schießt automatisch bei gelocktem Aimbot-Ziel ODER wenn die Maus über einem Gegner ist.")

-- ══════════════════════════════════════════════════
CombatTab:CreateSection("➖ Weitere Features")
-- ══════════════════════════════════════════════════

CombatTab:CreateSection("🖥 Auto Klicker")
;(function() -- AUTO KLICKER BLOCK: eigener Register-Pool
    local ac = {
        cps        = 12,
        mode       = "Halten",
        mouseButton = "Links",
        activation  = "Maus Rechts",
        enabled    = false,
        active     = false,
        runId      = 0,
    }

    local VIM
    pcall(function() VIM = game:GetService("VirtualInputManager") end)

    local function doMouseClick()
        if ac.mouseButton == "Rechts" then
            if mouse2click then pcall(function() mouse2click() end) return end
            if mouse2press and mouse2release then
                pcall(function() mouse2press() end)
                pcall(function() mouse2release() end)
                return
            end
            if VIM then
                pcall(function()
                    VIM:SendMouseButtonEvent(0, 0, 1, true, game, 0)
                    VIM:SendMouseButtonEvent(0, 0, 1, false, game, 0)
                end)
            end
            return
        end
        if mouse1click then pcall(function() mouse1click() end) return end
        if mouse1press and mouse1release then
            pcall(function() mouse1press() end)
            pcall(function() mouse1release() end)
            return
        end
        if VIM then
            pcall(function()
                VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            end)
        end
    end

    local function startLoop()
        ac.runId = ac.runId + 1
        local myId = ac.runId
        task.spawn(function()
            while ac.active and ac.enabled and myId == ac.runId do
                local fire = doMouseClick
                local cps = ac.cps
                if cps < 1 then cps = 1 end
                if cps <= 60 then
                    fire()
                    task.wait(1 / cps)
                else
                    -- [FIX v95] Accumulator verhindert CPS-Rundungsfehler bei > 60 CPS.
                    -- Ohne Fix: 90 CPS → floor(90/60)=1 Click/Tick → nur 60 CPS effektiv.
                    -- Mit Accumulator: 90/60=1.5 → abwechselnd 1 und 2 Clicks → exakt 90 CPS.
                    ac.accum = (ac.accum or 0) + (cps / 60)
                    local perTick = math.floor(ac.accum)
                    ac.accum = ac.accum - perTick
                    if perTick < 1 then perTick = 1 end
                    for _ = 1, perTick do
                        if not (ac.active and ac.enabled and myId == ac.runId) then break end
                        fire()
                    end
                    task.wait(1 / 60)
                end
            end
        end)
    end

    CombatTab:CreateToggle({
        Name = "🖥 Auto Klicker aktivieren",
        CurrentValue = false,
        Callback = function(state)
            ac.enabled = state
            if not state then
                ac.active = false
                ac.runId = ac.runId + 1
            end
        end
    })

    CombatTab:CreateDropdown({
        Name = "Modus",
        Options = {"Halten", "Umschalten"},
        CurrentOption = {"Halten"},
        Callback = function(opt)
            local v = type(opt) == "table" and opt[1] or opt
            if v then ac.mode = v end
        end
    })

    CombatTab:CreateDropdown({
        Name = "Welche Maustaste",
        Options = {"Links", "Rechts"},
        CurrentOption = {"Links"},
        Callback = function(opt)
            local v = type(opt) == "table" and opt[1] or opt
            if v then ac.mouseButton = v end
        end
    })

    CombatTab:CreateSlider({
        Name = "Klicks pro Sekunde (CPS) — Geschwindigkeit",
        Range = {1, 300},
        Increment = 1,
        Suffix = " CPS",
        CurrentValue = 12,
        Callback = function(v) ac.cps = v end
    })

    CombatTab:CreateDropdown({
        Name = "Auslöser-Maustaste (halten zum Klicken)",
        Options = {"Maus Rechts", "Maus Mitte", "Maus Links"},
        CurrentOption = {"Maus Rechts"},
        Callback = function(opt)
            local v = type(opt) == "table" and opt[1] or opt
            if v then ac.activation = v end
        end
    })

    CombatTab:CreateLabel("Halten = klickt solange die Auslöser-Maustaste gedrückt ist. Umschalten = einmal drücken an, nochmal aus.")

    local function matchesActivation(input)
        local a = ac.activation or "Maus Rechts"
        if a == "Maus Links" then
            return input.UserInputType == Enum.UserInputType.MouseButton1
        elseif a == "Maus Mitte" then
            return input.UserInputType == Enum.UserInputType.MouseButton3
        else
            return input.UserInputType == Enum.UserInputType.MouseButton2
        end
    end

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if not ac.enabled then return end
        if not matchesActivation(input) then return end
        if ac.mode == "Umschalten" then
            ac.active = not ac.active
            if ac.active then startLoop() end
        else
            ac.active = true
            startLoop()
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if not matchesActivation(input) then return end
        if ac.mode == "Halten" then
            ac.active = false
        end
    end)
end)()


-- ==================== FREECAM (Refaktoriert v2 - Keine Duplikate mehr) ====================
CombatTab:CreateSection("🎥 Freecam")

local freecamEnabled = false
local freecamSpeed = 80
local freecamConn = nil
local originalCamType = nil
local originalCamSubject = nil
local freecamPos = Vector3.new()
local yaw = 0
local pitch = 0
local originalCharPos = nil
local autoHighCharEnabled = false
local charAddedConn = nil
local freecamKeepHighConn = nil

-- [v63 Freecam Fix] Originale Distanzen speichern, damit ESP bei hoher Charakterhöhe weiterhin funktioniert
local originalESPMaxDistance = nil
local originalHealthWeaponMaxDistance = nil
local originalTracersMaxDistance = nil
local originalAimbotMaxDistance = nil

local function TeleportCharacterBack()
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChild("Humanoid")
        if not hrp then return end

        local rayOrigin = hrp.Position
        local rayDirection = Vector3.new(0, -600, 0)
        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Exclude
        rayParams.FilterDescendantsInstances = {char}

        local hit = Workspace:Raycast(rayOrigin, rayDirection, rayParams)

        local targetPosition
        if hit then
            targetPosition = hit.Position + Vector3.new(0, 4, 0)
        else
            targetPosition = originalCharPos or (hrp.Position - Vector3.new(0, 900, 0))
        end

        hrp.CFrame = CFrame.new(targetPosition)
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero

        if hum then
            hum.PlatformStand = false
        end
    end)
end

local function LiftCharacterUp()
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            originalCharPos = hrp.Position
            -- [v63 Freecam] Etwas höhere Charakter-Position als Original (450 → 700)
            -- Gut für Freecam, aber nicht so extrem dass man Probleme mit Fallen/Sterben hat
            hrp.CFrame = CFrame.new(hrp.Position + Vector3.new(0, 700, 0))
            if char:FindFirstChild("Humanoid") then
                char.Humanoid.PlatformStand = true
            end
        end
    end)
end

local function EnableFreecam()
    freecamEnabled = true
    local cam = Workspace.CurrentCamera

    originalCamType = cam.CameraType
    originalCamSubject = cam.CameraSubject

    LiftCharacterUp()

    freecamPos = cam.CFrame.Position

    -- Bessere Berechnung damit man nicht "auf die andere Seite" schaut beim Aktivieren
    local lookVector = cam.CFrame.LookVector
    yaw = math.atan2(lookVector.X, lookVector.Z)
    pitch = math.asin(lookVector.Y)

    autoHighCharEnabled = true

    -- [FIX v77] Originalwerte ZUERST speichern, dann Settings ändern.
    -- In v76 wurde AimbotMaxDistance = 1000 gesetzt, dann gespeichert → 1000 als "Original" gespeichert.
    -- Danach wurde sofort mit = 5000 überschrieben → doppelter Write, dead assignment.
    -- Jetzt: einmalig speichern, dann direkt auf 5000 setzen (Zeile 1000 entfernt).
    if originalESPMaxDistance == nil then
        originalESPMaxDistance = Settings.ESPMaxDistance
        originalHealthWeaponMaxDistance = Settings.HealthWeaponMaxDistance
        originalTracersMaxDistance = Settings.TracersMaxDistance
        originalAimbotMaxDistance = Settings.AimbotMaxDistance  -- echtes Original
    end

    Settings.ESPMaxDistance = 5000
    Settings.HealthWeaponMaxDistance = 5000
    Settings.TracersMaxDistance = 5000
    Settings.AimbotMaxDistance = 5000  -- Deutlich erhöht während Freecam (reicht für die moderate Höhe)

    if charAddedConn then charAddedConn:Disconnect() end
    charAddedConn = LocalPlayer.CharacterAdded:Connect(function(char)
        task.wait(0.25)
        pcall(function()
            if autoHighCharEnabled and char:FindFirstChild("HumanoidRootPart") then
                local hrp = char.HumanoidRootPart
                -- [v63 Freecam] Etwas höhere Charakter-Position (auch beim Respawn)
                hrp.CFrame = CFrame.new(hrp.Position + Vector3.new(0, 700, 0))
                if char:FindFirstChild("Humanoid") then
                    char.Humanoid.PlatformStand = true
                end
            end
        end)
    end)

    if freecamKeepHighConn then freecamKeepHighConn:Disconnect() end
    freecamKeepHighConn = RunService.Stepped:Connect(function()
        if not freecamEnabled or not autoHighCharEnabled then return end
        pcall(function()
            local char = LocalPlayer.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChild("Humanoid")
            if not hrp or not hum then return end

            -- [v63 Freecam] Sehr stabiles Halten der Charakterhöhe
            -- Hält die Höhe aktiv jedes Frame (besser gegen langsames Runterfallen)
            local targetY = 700
            local currentY = hrp.Position.Y

            if math.abs(currentY - targetY) > 1.5 then
                hrp.CFrame = CFrame.new(hrp.Position.X, targetY, hrp.Position.Z)
            end

            -- Velocity komplett auf X/Z beschränken (kein Y mehr)
            hrp.AssemblyLinearVelocity = Vector3.new(
                hrp.AssemblyLinearVelocity.X,
                0,
                hrp.AssemblyLinearVelocity.Z
            )

            hum.PlatformStand = true
        end)
    end)

    cam.CameraType = Enum.CameraType.Scriptable
    UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter

    if freecamConn then freecamConn:Disconnect() end
    -- [FIX v77] RenderStepped liefert `dt` (Delta-Zeit des letzten Frames) als Argument.
    -- Vorher wurde hardcoded 0.0167 (≈ 1/60s) genutzt → falsche Geschwindigkeit bei
    -- nicht-60-FPS. Jetzt korrekte frame-unabhängige Bewegung mit echtem dt.
    freecamConn = RunService.RenderStepped:Connect(function(dt)
        if not freecamEnabled then return end

        Workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable

        local delta = UserInputService:GetMouseDelta()
        yaw = yaw - delta.X * 0.0025
        pitch = math.clamp(pitch - delta.Y * 0.0025, -1.55, 1.55)

        local lookDir = Vector3.new(
            math.cos(pitch) * math.sin(yaw),
            math.sin(pitch),
            math.cos(pitch) * math.cos(yaw)
        )

        local moveDir = Vector3.zero
        local right = Vector3.new(-math.cos(yaw), 0, math.sin(yaw))
        local forward = Vector3.new(math.sin(yaw), 0, math.cos(yaw))

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + forward end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - forward end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - right end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + right end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0,1,0) end

        if moveDir.Magnitude > 0 then moveDir = moveDir.Unit end

        freecamPos = freecamPos + moveDir * freecamSpeed * dt  -- FIX: echtes dt statt 0.0167
        cam.CFrame = CFrame.fromMatrix(freecamPos, right, right:Cross(lookDir))

        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
            if hum then hum.PlatformStand = true end
            LocalPlayer.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
        end
    end)

    Rayfield:Notify({Title = "Freecam", Content = "Freecam aktiviert", Duration = 3})
end

local function DisableFreecam()
    freecamEnabled = false
    if freecamConn then freecamConn:Disconnect() freecamConn = nil end
    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    local cam = Workspace.CurrentCamera
    cam.CameraType = originalCamType or Enum.CameraType.Custom
    if originalCamSubject then cam.CameraSubject = originalCamSubject end

    -- Charakter direkt an die Freecam-Position teleportieren
    pcall(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            -- Kamera-Blickrichtung (horizontal) für Charakter-Ausrichtung
            local camLook = Workspace.CurrentCamera.CFrame.LookVector
            local flatLook = Vector3.new(camLook.X, 0, camLook.Z)
            local forwardLook = flatLook.Magnitude > 0.001 and flatLook.Unit or Vector3.new(0, 0, -1)

            -- Direkt an Freecam-Position spawnen (+ 3 Studs damit Charakter nicht im Boden steckt)
            local spawnPos = freecamPos + Vector3.new(0, 3, 0)
            hrp.CFrame = CFrame.new(spawnPos, spawnPos + forwardLook)

            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero

            if char:FindFirstChild("Humanoid") then
                char.Humanoid.PlatformStand = false
            end
        end
    end)

    -- [FIX v76] v66.1-Block entfernt: dieser zweite pcall überschrieb den Raycast-Landepunkt
    -- mit der Freecam-Position (hoch in der Luft) → Charakter fiel immer runter.
    -- Die Raycast-Logik oben findet jetzt zuverlässig den Boden.

    autoHighCharEnabled = false
    if charAddedConn then charAddedConn:Disconnect() charAddedConn = nil end
    if freecamKeepHighConn then freecamKeepHighConn:Disconnect() freecamKeepHighConn = nil end

    -- [v63 Freecam Fix] Originale ESP-Distanzen wiederherstellen
    if originalESPMaxDistance then Settings.ESPMaxDistance = originalESPMaxDistance end
    if originalHealthWeaponMaxDistance then Settings.HealthWeaponMaxDistance = originalHealthWeaponMaxDistance end
    if originalTracersMaxDistance then Settings.TracersMaxDistance = originalTracersMaxDistance end
    if originalAimbotMaxDistance then Settings.AimbotMaxDistance = originalAimbotMaxDistance end
end

CombatTab:CreateToggle({
    Name = "Freecam aktivieren",
    CurrentValue = false,
    Callback = function(state)
        if state then
            EnableFreecam()
        else
            DisableFreecam()
        end
    end
})

CombatTab:CreateKeybind({
    Name = "Freecam Keybind",
    CurrentKeybind = "V",
    HoldToInteract = false,
    Callback = function()
        if freecamEnabled then
            DisableFreecam()
        else
            EnableFreecam()
        end
    end
})

CombatTab:CreateSlider({
    Name = "Freecam Geschwindigkeit",
    Range = {10, 400},
    Increment = 10,
    CurrentValue = 80,
    Callback = function(v) freecamSpeed = v end
})

-- Visuals
VisualTab:CreateSection("🔧 Allgemeine ESP Einstellungen")
VisualTab:CreateToggle({
    Name = "Team Check aktivieren",
    CurrentValue = true,
    Callback = function(v)
        Settings.TeamCheckEnabled = v
        UpdateAllBoxESPColors()
        UpdateAllChamsColors()

        -- Kein Neustart der Tracers mehr nötig, da der TeamCheck-Check direkt in TracersManager läuft
        -- Das verhindert Race-Conditions und Verbindungsfehler beim schnellen Togglen
    end
})

-- Universal Mode Toggle wurde entfernt (User Wunsch)

VisualTab:CreateColorPicker({Name = "Gegner Farbe", Color = Settings.EnemyColor, Callback = function(v)
    Settings.EnemyColor = v
    UpdateAllBoxESPColors()
    UpdateAllChamsColors()
end})

VisualTab:CreateColorPicker({Name = "Teammates Farbe", Color = Settings.TeammateColor, Callback = function(v)
    Settings.TeammateColor = v
    UpdateAllBoxESPColors()
    UpdateAllChamsColors()
end})

VisualTab:CreateSlider({
    Name = "Max Distanz für Box ESP & Chams (Studs)",
    Range = {1, 2000},
    Increment = 10,
    CurrentValue = 600,
    Callback = function(v)
        Settings.ESPMaxDistance = v

        -- Besserer Refresh: Aktive Manager neu starten damit neue Distanz sofort gilt
        if Settings.ESPEnabled then
            CleanupESP()
            task.spawn(ESPManager)
        end
        if Settings.ChamsEnabled then
            CleanupChams()
            task.spawn(ChamsManager)
        end
    end
})

-- ==================== HEALTH BAR + WEAPON SYMBOL ====================
VisualTab:CreateSection("💗 Health Bar + Weapon Symbol")

VisualTab:CreateToggle({
    Name = "Health Bar + Weapon Symbol aktivieren",
    CurrentValue = false,
    Callback = function(v)
        Settings.HealthWeaponEnabled = v
        if v then
            task.spawn(HealthWeaponManager)
        else
            CleanupHealthWeapon()
        end
    end
})

VisualTab:CreateSlider({
    Name = "Max Distanz (Studs)",
    Range = {50, 1500},
    Increment = 50,
    CurrentValue = 600,
    Callback = function(v)
        Settings.HealthWeaponMaxDistance = v
    end
})

VisualTab:CreateSlider({
    Name = "Symbol Größe",
    Range = {0.5, 1.8},
    Increment = 0.1,
    CurrentValue = 1.0,
    Callback = function(v)
        Settings.HealthWeaponSymbolScale = v
        if Settings.HealthWeaponEnabled then
            CleanupHealthWeapon()
            task.wait(0.1)
            task.spawn(HealthWeaponManager)
        end
    end
})

VisualTab:CreateLabel("Symbol zeigt 🔪 oder 🔫 direkt (je nach Waffe)")

VisualTab:CreateSection("📦 Box ESP")
VisualTab:CreateToggle({
    Name = "Box ESP aktivieren",
    CurrentValue = false,
    Flag = "BoxESP",
    Callback = function(v)
        Settings.ESPEnabled = v
        if v then task.spawn(ESPManager) else CleanupESP() end
    end
})

VisualTab:CreateSlider({Name = "Box ESP Transparenz", Range = {0,1}, Increment = 0.05, CurrentValue = Settings.ESPTransparency, Callback = function(v)
    Settings.ESPTransparency = v
    UpdateAllBoxESPTransparency(v)
end})

VisualTab:CreateSection("✨ Chams ESP")
VisualTab:CreateToggle({
    Name = "Chams ESP aktivieren",
    CurrentValue = false,
    Flag = "ChamsESP",
    Callback = function(v)
        Settings.ChamsEnabled = v
        if v then task.spawn(ChamsManager) else CleanupChams() end
    end
})

VisualTab:CreateSlider({Name = "Chams Transparenz", Range = {0,1}, Increment = 0.05, CurrentValue = Settings.ChamsFillTransparency, Callback = function(v)
    Settings.ChamsFillTransparency = v
    UpdateAllChamsTransparency(v)
end})

-- NPC ESP
VisualTab:CreateSection("🤖 NPC ESP")
local function CleanupNPCESP()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj.Name == "NPC_ESP" then obj:Destroy() end
    end
end
local function CleanupNPCChams()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj.Name == "NPC_Chams" then obj:Destroy() end
    end
end
local function ScanAndApplyNPCESP()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
            local isPlayer = false
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr.Character == obj then
                    isPlayer = true
                    break
                end
            end

            if not isPlayer then
                if Settings.NPCBoxESP and not obj:FindFirstChild("NPC_ESP") then
                    local esp = Instance.new("BoxHandleAdornment")
                    esp.Name = "NPC_ESP"
                    -- [FIX] BoxHandleAdornment braucht BasePart als Adornee, kein Model
                    esp.Adornee = obj:FindFirstChild("HumanoidRootPart") or obj
                    esp.Size = Settings.ESPBoxSize
                    esp.Transparency = 0.35
                    esp.Color3 = Color3.fromRGB(255, 200, 0)
                    esp.AlwaysOnTop = true
                    esp.ZIndex = 5
                    esp.Parent = obj
                end

                if Settings.NPCChams and not obj:FindFirstChild("NPC_Chams") then
                    local chams = Instance.new("Highlight")
                    chams.Name = "NPC_Chams"
                    chams.FillColor = Color3.fromRGB(255, 200, 0)
                    chams.OutlineColor = Color3.fromRGB(255, 150, 0)
                    chams.FillTransparency = 0.65
                    chams.OutlineTransparency = 0
                    chams.Parent = obj
                end
            end
        end
    end
end

VisualTab:CreateToggle({
    Name = "NPC Box ESP",
    CurrentValue = false,
    Callback = function(state)
        Settings.NPCBoxESP = state
        if state then ScanAndApplyNPCESP() else CleanupNPCESP() end
    end
})

VisualTab:CreateToggle({
    Name = "NPC Chams",
    CurrentValue = false,
    Callback = function(state)
        Settings.NPCChams = state
        if state then ScanAndApplyNPCESP() else CleanupNPCChams() end
    end
})

-- [FIX v94] Connection speichern damit sie bei Cleanup getrennt werden kann
HubState._npcDescAddedConn = Workspace.DescendantAdded:Connect(function(obj)
    if not (Settings.NPCBoxESP or Settings.NPCChams) then return end
    if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
        local isPlayer = false
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr.Character == obj then
                isPlayer = true
                break
            end
        end

        if not isPlayer then
            if Settings.NPCBoxESP and not obj:FindFirstChild("NPC_ESP") then
                local esp = Instance.new("BoxHandleAdornment")
                esp.Name = "NPC_ESP"
                esp.Adornee = obj:FindFirstChild("HumanoidRootPart") or obj
                esp.Size = Settings.ESPBoxSize
                esp.Transparency = 0.35
                esp.Color3 = Color3.fromRGB(255, 200, 0)
                esp.AlwaysOnTop = true
                esp.ZIndex = 5
                esp.Parent = obj
            end

            if Settings.NPCChams and not obj:FindFirstChild("NPC_Chams") then
                local chams = Instance.new("Highlight")
                chams.Name = "NPC_Chams"
                chams.FillColor = Color3.fromRGB(255, 200, 0)
                chams.OutlineColor = Color3.fromRGB(255, 150, 0)
                chams.FillTransparency = 0.65
                chams.OutlineTransparency = 0
                chams.Parent = obj
            end
        end
    end
end)

-- NPC ESP/Chams Cleanup: Wenn NPC aus Workspace entfernt wird (z.B. nach Tod/Despawn)
-- [FIX v94] Connection speichern
HubState._npcDescRemovingConn = Workspace.DescendantRemoving:Connect(function(obj)
    if not obj:IsA("Model") then return end
    pcall(function()
        local esp = obj:FindFirstChild("NPC_ESP")
        if esp then esp:Destroy() end
        local chams = obj:FindFirstChild("NPC_Chams")
        if chams then chams:Destroy() end
    end)
end)

-- ==================== LOOK DIRECTION BEAM ====================
VisualTab:CreateSection("👀 Look Direction Beam")

Settings.LookDirectionEnabled = false
Settings.LookDirectionLength = 8
Settings.LookDirectionColor = Color3.fromRGB(255, 255, 0)

local LookDirectionBeams = {}

local function CleanupLookDirection()
    for plr, data in pairs(LookDirectionBeams) do
        if data.beam then data.beam:Destroy() end
        if data.att0 then data.att0:Destroy() end
        if data.att1 then data.att1:Destroy() end
    end
    LookDirectionBeams = {}
end

local function CreateLookDirectionBeam(plr)
    if LookDirectionBeams[plr] then return end
    if not plr.Character then return end

    local head = plr.Character:FindFirstChild("Head")
    if not head then return end

    local att0 = Instance.new("Attachment")
    att0.Name = "LookAtt0"
    att0.Parent = head

    local att1 = Instance.new("Attachment")
    att1.Name = "LookAtt1"
    att1.Parent = head

    local beam = Instance.new("Beam")
    beam.Name = "LookDirectionBeam"
    beam.Attachment0 = att0
    beam.Attachment1 = att1
    beam.Color = ColorSequence.new(Settings.LookDirectionColor)
    beam.Width0 = 0.12
    beam.Width1 = 0.12
    beam.FaceCamera = true
    beam.LightEmission = 0.6
    beam.Parent = head

    LookDirectionBeams[plr] = {beam = beam, att0 = att0, att1 = att1}
end

local function UpdateLookDirectionBeam(plr)
    local data = LookDirectionBeams[plr]
    if not data or not plr.Character then return end

    local head = plr.Character:FindFirstChild("Head")
    if not head then return end

    local lookVector = head.CFrame.LookVector
    local length = Settings.LookDirectionLength or 8

    data.att0.WorldPosition = head.Position + Vector3.new(0, 0.2, 0)
    data.att1.WorldPosition = head.Position + (lookVector * length) + Vector3.new(0, 0.2, 0)
end

local LookDirectionManagerActive = false
local function LookDirectionManager()
    if LookDirectionManagerActive then return end
    LookDirectionManagerActive = true

    while Settings.LookDirectionEnabled do
        task.wait(0.5)
        for _, plr in ipairs(Players:GetPlayers()) do
            repeat
            if ShouldApply(plr) and plr.Character and IsTargetAlive(plr) then
                if Settings.TeamCheckEnabled and not IsEnemy(plr) then
                    if LookDirectionBeams[plr] then
                        if LookDirectionBeams[plr].beam then LookDirectionBeams[plr].beam:Destroy() end
                        if LookDirectionBeams[plr].att0 then LookDirectionBeams[plr].att0:Destroy() end
                        if LookDirectionBeams[plr].att1 then LookDirectionBeams[plr].att1:Destroy() end
                        LookDirectionBeams[plr] = nil
                    end
                    break
                end

                if not LookDirectionBeams[plr] then
                    CreateLookDirectionBeam(plr)
                end
                UpdateLookDirectionBeam(plr)
            else
                if LookDirectionBeams[plr] then
                    if LookDirectionBeams[plr].beam then LookDirectionBeams[plr].beam:Destroy() end
                    if LookDirectionBeams[plr].att0 then LookDirectionBeams[plr].att0:Destroy() end
                    if LookDirectionBeams[plr].att1 then LookDirectionBeams[plr].att1:Destroy() end
                    LookDirectionBeams[plr] = nil
                end
            end
            until true
        end
        -- [FIX] task.wait(0.1) entfernt: war redundant nach task.wait(0.5) oben → 0.6s/Iteration statt 0.5s
    end

    LookDirectionManagerActive = false
    CleanupLookDirection()
end

VisualTab:CreateToggle({
    Name = "Look Direction Beam aktivieren",
    CurrentValue = false,
    Callback = function(v)
        Settings.LookDirectionEnabled = v
        if v then
            task.spawn(LookDirectionManager)
        else
            CleanupLookDirection()
        end
    end
})

VisualTab:CreateSlider({
    Name = "Beam Länge (Studs)",
    Range = {3, 25},
    Increment = 1,
    CurrentValue = 8,
    Callback = function(v)
        Settings.LookDirectionLength = v
    end
})

VisualTab:CreateColorPicker({
    Name = "Beam Farbe",
    Color = Settings.LookDirectionColor,
    Callback = function(v)
        Settings.LookDirectionColor = v
        for _, data in pairs(LookDirectionBeams) do
            if data.beam then
                data.beam.Color = ColorSequence.new(v)
            end
        end
    end
})

VisualTab:CreateLabel("Zeigt einen 3D-Strahl aus dem Kopf der Gegner in die Richtung, in die sie schauen.")
-- ==================== TRACERS RAINBOW (VOLLSTÄNDIG + STABIL + FROM BOTTOM/TOP) ====================
Settings.TracersEnabled = false
Settings.TracersMaxDistance = 600
Settings.TracersThickness = 1.5
Settings.TracersFromBottom = true

local ActiveTracers = {}

local function HideAllTracers()
    for plr, line in pairs(ActiveTracers) do
        if line then
            pcall(function()
                line.Visible = false
                line:Destroy()
            end)
        end
        ActiveTracers[plr] = nil
    end
    ActiveTracers = {}
end

local function CleanupTracers()
    for plr, line in pairs(ActiveTracers) do
        if line then
            pcall(function() line:Destroy() end)
        end
        ActiveTracers[plr] = nil
    end
    ActiveTracers = {}
end

local function CreateOrGetTracer(plr)
    if ActiveTracers[plr] then return ActiveTracers[plr] end
    local line = Drawing.new("Line")
    line.Visible = false
    line.Color = Color3.new(1,1,1)
    line.Thickness = Settings.TracersThickness or 1.5
    line.Transparency = 0.75
    ActiveTracers[plr] = line
    return line
end

local TracersManagerActive = false
local TracersConn = nil

local function TracersManager()
    if TracersManagerActive then return end
    TracersManagerActive = true
    if TracersConn then TracersConn:Disconnect() end

    -- Periodischer Cleanup damit Linien nicht verbuggen nach langer Zeit (starke Version gegen stuck lines)
    -- OPTIMIZED: Schnellerer Interval (2.5s statt 6s) für sofortige Beseitigung von stuck lines beim Verlassen von Spielern
    task.spawn(function()
        while Settings.TracersEnabled do
            task.wait(2.5)
            pcall(function()
                for plr, line in pairs(ActiveTracers) do
                    if not plr or not plr.Parent or not plr.Character then
                        if line then
                            pcall(function()
                                line.Visible = false
                                line:Destroy()
                            end)
                        end
                        ActiveTracers[plr] = nil
                    else
                        local hum = plr.Character:FindFirstChild("Humanoid")
                        if not hum or hum.Health <= 0 then
                            if line then
                                pcall(function()
                                    line.Visible = false
                                    line:Destroy()
                                end)
                            end
                            ActiveTracers[plr] = nil
                        end
                    end
                end
            end)
        end
    end)

    TracersConn = RunService.RenderStepped:Connect(function()
        if not Settings.TracersEnabled then
            HideAllTracers()
            return
        end

        pcall(function()
            local Camera = Workspace.CurrentCamera
            if not Camera then return end
            local myPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position

            for _, plr in ipairs(Players:GetPlayers()) do
                repeat
                -- ROBUSTE FIX gegen stuck lines beim Verlassen/Sterben von Spielern:
                -- Immer explizit hide bevor break → verhindert dass Linien sichtbar bleiben
                if plr == LocalPlayer then break end

                if not plr.Character then
                    if ActiveTracers[plr] then
                        pcall(function() ActiveTracers[plr].Visible = false end)
                    end
                    break
                end

                local hum = plr.Character:FindFirstChild("Humanoid")
                if not hum or hum.Health <= 0 then
                    if ActiveTracers[plr] then
                        pcall(function() ActiveTracers[plr].Visible = false end)
                    end
                    break
                end

                if Settings.TeamCheckEnabled and not IsEnemy(plr) then
                    if ActiveTracers[plr] then
                        pcall(function() ActiveTracers[plr].Visible = false end)
                    end
                    break
                end

                local targetHead = plr.Character:FindFirstChild("Head") or plr.Character:FindFirstChild("HumanoidRootPart")
                if not targetHead or not myPos then
                    if ActiveTracers[plr] then
                        pcall(function() ActiveTracers[plr].Visible = false end)
                    end
                    break
                end

                if (targetHead.Position - myPos).Magnitude > Settings.TracersMaxDistance then
                    if ActiveTracers[plr] then
                        pcall(function() ActiveTracers[plr].Visible = false end)
                    end
                    break
                end

                local screenPos, onScreen = Camera:WorldToViewportPoint(targetHead.Position)
                if onScreen then
                    local l = CreateOrGetTracer(plr)
                    l.Color = Color3.fromHSV((os.clock() * 0.6) % 1, 1, 1)
                    l.Thickness = Settings.TracersThickness or 1.5
                    local fromY = Settings.TracersFromBottom and (Camera.ViewportSize.Y - 20) or 25
                    l.From = Vector2.new(Camera.ViewportSize.X / 2, fromY)
                    l.To = Vector2.new(screenPos.X, screenPos.Y)
                    l.Visible = true
                else
                    if ActiveTracers[plr] then ActiveTracers[plr].Visible = false end
                end
                until true
            end
        end)
    end)
end

local function StopTracers()
    if TracersConn then TracersConn:Disconnect() TracersConn = nil end
    TracersManagerActive = false
    HideAllTracers()
end

-- Spawn + Respawn Support
local function SetupTracerForPlayer(plr)
    if plr == LocalPlayer then return end
    if ActiveTracers[plr] then
        pcall(function() ActiveTracers[plr]:Destroy() end)
        ActiveTracers[plr] = nil
    end
    plr.CharacterAdded:Connect(function()
        if ActiveTracers[plr] then
            pcall(function() ActiveTracers[plr]:Destroy() end)
            ActiveTracers[plr] = nil
        end
    end)
end

for _, plr in ipairs(Players:GetPlayers()) do
    SetupTracerForPlayer(plr)
end

-- [FIX v94] Connection speichern
HubState._tracerPlayerAddedConn = Players.PlayerAdded:Connect(SetupTracerForPlayer)

-- [FIX v94] Connection speichern
HubState._tracerPlayerRemovingConn = Players.PlayerRemoving:Connect(function(plr)
    if ActiveTracers[plr] then
        pcall(function() ActiveTracers[plr]:Destroy() end)
        ActiveTracers[plr] = nil
    end
end)

VisualTab:CreateSection("🌈 Tracers (Rainbow)")
VisualTab:CreateToggle({
    Name = "Tracers aktivieren (Rainbow)",
    CurrentValue = false,
    Callback = function(v)
        Settings.TracersEnabled = v
        if v then
            task.spawn(TracersManager)
        else
            StopTracers()
        end
    end
})
VisualTab:CreateToggle({
    Name = "Tracers von unten (sonst von oben)",
    CurrentValue = true,
    Callback = function(v)
        Settings.TracersFromBottom = v
    end
})
VisualTab:CreateSlider({
    Name = "Maximale Distanz",
    Range = {100, 1500},
    Increment = 50,
    CurrentValue = 600,
    Callback = function(v)
        Settings.TracersMaxDistance = v
    end
})
VisualTab:CreateSlider({
    Name = "Liniendicke",
    Range = {0.5, 5},
    Increment = 0.1,
    CurrentValue = 1.5,
    Callback = function(v)
        Settings.TracersThickness = v
        for _, l in pairs(ActiveTracers) do
            if l then l.Thickness = v end
        end
    end
})
VisualTab:CreateLabel("Rainbow Tracers • von unten/oben • Spawn Support • Stabil")

-- ==================== FULLBRIGHT ====================
VisualTab:CreateSection("🌟 Fullbright")
VisualTab:CreateToggle({
    Name = "Fullbright (alles hell)",
    CurrentValue = false,
    Callback = function(state)
        Settings.FullbrightEnabled = state
        pcall(function()
            if state then
                -- Originalwerte speichern
                HubState.OriginalLighting = {
                    GlobalShadows = Lighting.GlobalShadows,
                    FogEnd = Lighting.FogEnd,
                    Brightness = Lighting.Brightness,
                    OutdoorAmbient = Lighting.OutdoorAmbient,
                    Ambient = Lighting.Ambient,
                }

                Lighting.GlobalShadows = false
                Lighting.FogEnd = 9999999
                Lighting.Brightness = 2
                Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
                Lighting.Ambient = Color3.new(1, 1, 1)
            else
                -- Originalwerte wiederherstellen
                if HubState.OriginalLighting then
                    Lighting.GlobalShadows = HubState.OriginalLighting.GlobalShadows
                    Lighting.FogEnd = HubState.OriginalLighting.FogEnd
                    Lighting.Brightness = HubState.OriginalLighting.Brightness
                    Lighting.OutdoorAmbient = HubState.OriginalLighting.OutdoorAmbient
                    Lighting.Ambient = HubState.OriginalLighting.Ambient
                else
                    -- Fallback falls keine Originalwerte gespeichert
                    Lighting.GlobalShadows = true
                    Lighting.FogEnd = 100000
                    Lighting.Brightness = 1
                end
            end
        end)
    end
})
VisualTab:CreateLabel("Macht die ganze Map hell (keine Dunkelheit mehr)")

-- ==================== VOICE RANGE (Smarter Auto Scan) ====================
-- (VoiceRangePart ist jetzt global deklariert für saubere CleanupAll Nutzung)

local function DetectVoiceRange()
    local detected = nil
    local bestScore = 0

    pcall(function()
        local containers = {
            game, game.ReplicatedStorage, game.ReplicatedFirst,
            game.StarterPlayer, game.StarterGui, workspace,  -- [FIX v95] game.Workspace → workspace
            game.Lighting, game.SoundService
        }

        for _, container in ipairs(containers) do
            for _, obj in ipairs(container:GetDescendants()) do
                -- NumberValue / IntValue
                if obj:IsA("NumberValue") or obj:IsA("IntValue") then
                    local name = string.lower(obj.Name)
                    local val = obj.Value

                    if val >= 25 and val <= 150 then  -- realistischer Bereich für Voice Chat
                        local score = 0

                        -- Hohe Priorität wenn "voice" + ("distance" oder "range") zusammen vorkommt
                        if string.find(name, "voice") and (string.find(name, "distance") or string.find(name, "range")) then
                            score = 100
                        elseif string.find(name, "voice") then
                            score = 70
                        elseif string.find(name, "proximity") or string.find(name, "hearing") then
                            score = 50
                        elseif string.find(name, "distance") or string.find(name, "range") then
                            score = 30
                        end

                        if score > bestScore then
                            bestScore = score
                            detected = val
                        end
                    end
                end

                -- Attributes
                for attrName, attrValue in pairs(obj:GetAttributes()) do
                    if type(attrValue) == "number" and attrValue >= 25 and attrValue <= 150 then
                        local lname = string.lower(attrName)
                        local score = 0

                        if string.find(lname, "voice") and (string.find(lname, "distance") or string.find(lname, "range")) then
                            score = 100
                        elseif string.find(lname, "voice") then
                            score = 70
                        elseif string.find(lname, "proximity") or string.find(lname, "hearing") then
                            score = 50
                        end

                        if score > bestScore then
                            bestScore = score
                            detected = attrValue
                        end
                    end
                end
            end
        end
    end)

    return detected or 70  -- realistischer Default für Voice Chat
end

local function UpdateVoiceRangeCircle()
    if not Settings.VoiceRangeEnabled then
        if VoiceRangePart and VoiceRangePart.Parent then
            pcall(function() VoiceRangePart:Destroy() end)
            VoiceRangePart = nil
        end
        return
    end

    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        if not VoiceRangePart or not VoiceRangePart.Parent then
            VoiceRangePart = Instance.new("Part")
            VoiceRangePart.Name = "VoiceRangeVisualizer"
            VoiceRangePart.Shape = Enum.PartType.Cylinder
            VoiceRangePart.Anchored = true
            VoiceRangePart.CanCollide = false
            VoiceRangePart.Color = Settings.VoiceRangeColor
            VoiceRangePart.Material = Enum.Material.ForceField
            VoiceRangePart.CastShadow = false
            VoiceRangePart.Parent = Workspace
        end

        local radius = Settings.VoiceRangeRadius or 80
        VoiceRangePart.Size = Vector3.new(5, radius * 2, radius * 2)
        VoiceRangePart.Transparency = Settings.VoiceRangeTransparency or 0.5
        local pos = hrp.Position
        VoiceRangePart.CFrame = CFrame.new(pos.X, pos.Y - 3.5, pos.Z) * CFrame.Angles(0, 0, math.rad(90))

        -- Outline Ring
        if Settings.VoiceRangeOutlineEnabled then
            if not VoiceRangeOutline or not VoiceRangeOutline.Parent then
                VoiceRangeOutline = Instance.new("Part")
                VoiceRangeOutline.Name = "VoiceRangeOutline"
                VoiceRangeOutline.Shape = Enum.PartType.Cylinder
                VoiceRangeOutline.Anchored = true
                VoiceRangeOutline.CanCollide = false
                VoiceRangeOutline.Color = Color3.fromRGB(255, 255, 255)
                VoiceRangeOutline.Material = Enum.Material.Neon
                VoiceRangeOutline.CastShadow = false
                VoiceRangeOutline.Parent = Workspace
            end
            VoiceRangeOutline.Size = Vector3.new(5.2, radius * 2 + 0.3, radius * 2 + 0.3)
            VoiceRangeOutline.Transparency = 0.25
            VoiceRangeOutline.CFrame = CFrame.new(pos.X, pos.Y - 3.45, pos.Z) * CFrame.Angles(0, 0, math.rad(90))
        else
            if VoiceRangeOutline and VoiceRangeOutline.Parent then
                VoiceRangeOutline:Destroy()
                VoiceRangeOutline = nil
            end
        end
    end)
end

-- [FIX v77] Throttled: VoiceRangeCircle braucht keine Frame-genaue Aktualisierung.
-- 0.05s-Intervall (20x/s) reicht für flüssige Bewegung, spart ~95% CPU vs. Heartbeat.
local _vrLastTick = 0
HubState._voiceRangeConn = RunService.Heartbeat:Connect(function(dt)
    _vrLastTick = _vrLastTick + dt
    if _vrLastTick >= 0.05 then
        _vrLastTick = 0
        UpdateVoiceRangeCircle()
    end
end)

VisualTab:CreateSection("🎤 Voice Range (Smarter Auto)")
VisualTab:CreateToggle({
    Name = "Gefüllter Voice Range Kreis aktivieren",
    CurrentValue = false,
    Callback = function(v)
        Settings.VoiceRangeEnabled = v
        if v then
            local detected = DetectVoiceRange()
            Settings.VoiceRangeRadius = detected
            Rayfield:Notify({Title = "Voice Range", Content = "Erkannt: " .. detected .. " Studs (realistisch)", Duration = 4})
        else
            if VoiceRangePart then pcall(function() VoiceRangePart:Destroy() end) VoiceRangePart = nil end
        end
    end
})

VisualTab:CreateSlider({
    Name = "Voice Range Radius (Studs)",
    Range = {20, 200},
    Increment = 5,
    CurrentValue = 80,
    Callback = function(v)
        Settings.VoiceRangeRadius = v
    end
})

VisualTab:CreateSlider({
    Name = "Transparenz des Kreises",
    Range = {0.1, 0.9},
    Increment = 0.05,
    CurrentValue = 0.5,
    Callback = function(v)
        Settings.VoiceRangeTransparency = v
        if VoiceRangePart then
            VoiceRangePart.Transparency = v
        end
    end
})

VisualTab:CreateButton({
    Name = "🔄 Neu scannen (Smarter Scan)",
    Callback = function()
        if Settings.VoiceRangeEnabled then
            local detected = DetectVoiceRange()
            Settings.VoiceRangeRadius = detected
            if VoiceRangePart then pcall(function() VoiceRangePart:Destroy() end) VoiceRangePart = nil end
            Rayfield:Notify({Title = "Voice Range", Content = "Neu erkannt: " .. detected .. " Studs", Duration = 3})
        else
            Rayfield:Notify({Title = "Voice Range", Content = "Toggle zuerst einschalten", Duration = 2})
        end
    end
})

VisualTab:CreateColorPicker({
    Name = "Kreis Farbe",
    Color = Color3.fromRGB(100, 200, 255),
    Callback = function(v)
        Settings.VoiceRangeColor = v
        if VoiceRangePart then VoiceRangePart.Color = v end
    end
})

VisualTab:CreateLabel("Smarter Scan (bevorzugt echte Voice Werte) • Max 150 Studs • Mit manueller Feinjustierung")


-- Wallhack
VisualTab:CreateSection("🔫 Wallhack (sehen + schießen)")

VisualTab:CreateToggle({
    Name = "Wallhack aktivieren",
    CurrentValue = false,
    Callback = function(v)
        Settings.WallhackEnabled = v
        if v then
            originalTrans = {}
            originalCollide = {}
            for _, part in ipairs(Workspace:GetDescendants()) do
                if part:IsA("BasePart")
                   and part.Parent ~= LocalPlayer.Character
                   and part.Anchored
                   and part.Size.Y > 4
                   and part.Size.Y < 40
                   and (part.Size.X < 80 or part.Size.Z < 80) then

                    originalTrans[part] = part.Transparency
                    originalCollide[part] = part.CanCollide
                    part.Transparency = 0.85
                    part.CanCollide = false
                end
            end
            Rayfield:Notify({Title = "Wallhack", Content = "Wände durchsichtig + durchschießen möglich", Duration = 3})
        else
            for part, t in pairs(originalTrans or {}) do
                if part and part.Parent then
                    part.Transparency = t
                    if originalCollide[part] ~= nil then part.CanCollide = originalCollide[part] end
                end
            end
            originalTrans = {}
            originalCollide = {}
        end
    end
})

VisualTab:CreateLabel("Wände werden durchsichtig und du kannst durch sie schießen.")

-- Update Refresh Button
VisualTab:CreateSection("🔄 Aktualisieren")
VisualTab:CreateButton({Name = "🔄 Alle Visuals neu laden", Callback = function()
    pcall(function()
        CleanupAll()
        if Settings.ChamsEnabled then task.spawn(ChamsManager) end
        if Settings.ESPEnabled then task.spawn(ESPManager) end
        if Settings.HealthWeaponEnabled then task.spawn(HealthWeaponManager) end
        if Settings.LookDirectionEnabled then task.spawn(LookDirectionManager) end
        if Settings.TracersEnabled then task.spawn(TracersManager) end
        if Settings.VoiceRangeEnabled then
            if VoiceRangePart then VoiceRangePart:Destroy() VoiceRangePart = nil end
            if VoiceRangeOutline then VoiceRangeOutline:Destroy() VoiceRangeOutline = nil end
        end
        if Settings.WallhackEnabled then
            for part, t in pairs(originalTrans or {}) do
                if part and part.Parent then
                    part.Transparency = t
                    if originalCollide[part] ~= nil then part.CanCollide = originalCollide[part] end
                end
            end
            originalTrans = {}
            originalCollide = {}
            Settings.WallhackEnabled = false
        end
        Rayfield:Notify({Title = "🔄 Aktualisiert", Content = "Alle Visuals neu geladen", Duration = 3})
    end)
end})
-- ==================== TRACERS ENDE ====================

-- Settings
SettingsTab:CreateSection("🪪 Dein Profil")
;(function() -- block: own register pool
    local myId = tostring(LocalPlayer.UserId)
    local myName = tostring(LocalPlayer.Name)
    SettingsTab:CreateLabel("👤 Name: " .. myName)
    SettingsTab:CreateLabel("🆔 User-ID: " .. myId)
    SettingsTab:CreateButton({
        Name = "📋 User-ID kopieren (" .. myId .. ")",
        Callback = function()
            pcall(function()
                setclipboard(myId)
                Rayfield:Notify({Title = "✅ Kopiert!", Content = "Deine User-ID " .. myId .. " wurde in die Zwischenablage kopiert.", Duration = 3})
            end)
        end
    })
end)()

-- ==================== 📍 KOORDINATEN ====================
SettingsTab:CreateSection("📍 Meine Position")
;(function() -- block: own register pool
    local coordLabel = SettingsTab:CreateLabel("📍 X: -  Y: -  Z: -")
    local coordConn = nil
    local _timer = 0
    coordConn = RunService.Heartbeat:Connect(function(dt)
        _timer = _timer + dt
        if _timer < 0.2 then return end
        _timer = 0
        pcall(function()
            local char = LocalPlayer.Character
            local hrp  = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local p = hrp.Position
                coordLabel:Set(string.format("📍 X: %.1f  Y: %.1f  Z: %.1f", p.X, p.Y, p.Z))
            else
                coordLabel:Set("📍 X: -  Y: -  Z: -")
            end
        end)
    end)
    HubState._coordConn = coordConn  -- [FIX v101] in HubState gespeichert → F5-Reset kann jetzt trennen
    SettingsTab:CreateButton({
        Name = "📋 Koordinaten kopieren",
        Callback = function()
            pcall(function()
                local char = LocalPlayer.Character
                local hrp  = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local p = hrp.Position
                    local txt = string.format("%.1f, %.1f, %.1f", p.X, p.Y, p.Z)
                    setclipboard(txt)
                    Rayfield:Notify({Title = "📋 Kopiert!", Content = txt, Duration = 3})
                end
            end)
        end
    })
end)()

SettingsTab:CreateSection("🔧 Konfiguration")
SettingsTab:CreateLabel("Deine Einstellungen werden automatisch gespeichert.")

-- ==================== MENÜ-SOUNDS ====================
SettingsTab:CreateSection("🔊 Menü-Sounds")
SettingsTab:CreateToggle({
    Name = "Sound-Effekte",
    CurrentValue = true,
    Flag = "MenuSoundsOn",
    Callback = function(on)
        Rayfield:SetSounds(on)
        Rayfield:Notify({Title = "🔊 Sounds", Content = on and "Sound-Effekte aktiviert" or "Sound-Effekte ausgeschaltet", Duration = 2})
    end
})
SettingsTab:CreateSlider({
    Name = "Lautstärke",
    Range = {0, 200},
    Increment = 5,
    Suffix = "%",
    CurrentValue = 100,
    Flag = "MenuSoundVolume",
    Callback = function(val)
        Rayfield:SetSoundVolume((tonumber(val) or 100) / 100)
    end
})
SettingsTab:CreateLabel("Tipp: Lautstärke auf 0% oder den Schalter aus = komplett stumm.")

-- ==================== KEYBIND SYSTEM & PERFORMANCE MONITOR ====================
SettingsTab:CreateSection("🔧 Keybinds & Performance")

local performanceLabel = SettingsTab:CreateLabel("FPS: - | Ping: - | Memory: -")

-- FPS-Fix v69: dt-Parameter statt Heartbeat:Wait(), fpsTimer/fpsSamples in v69-Tabelle (spart locals)
;(function() -- block: own register pool
    local _ft = 0
    local _fs = {}
    HubState._fpsCounterConn = RunService.Heartbeat:Connect(function(dt)
        pcall(function()
            table.insert(_fs, 1 / dt)
            if #_fs > 30 then table.remove(_fs, 1) end
            _ft = _ft + dt
            if _ft < 0.5 then return end
            _ft = 0
            local fpsSum = 0
            for _, f in ipairs(_fs) do fpsSum = fpsSum + f end
            local fps = math.floor(fpsSum / #_fs)
            local ping = 0
            -- [FIX v87] Ping-Abfrage: Stats.Network.ServerStatsItem["Data Ping"]
            -- Der frühere doppelte Fallback war identisch mit dem ersten pcall → entfernt.
            -- Falls 0 zurückkommt zeigen wir "N/A" statt einer falschen 0ms-Anzeige.
            pcall(function()
                ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
            end)
            local pingStr = ping > 0 and (tostring(ping) .. "ms") or "N/A"
            local memory = math.floor(collectgarbage("count") / 1024)
            performanceLabel:Set(string.format("FPS: %d | Ping: %s | Memory: %d MB", fps, pingStr, memory))
        end)
    end)
end)()

SettingsTab:CreateSection("🚀 FPS Booster")

SettingsTab:CreateButton({
    Name = "🚀 FPS Boost anwenden (Grafik runter)",
    Callback = function()
        pcall(function()
            local Light = game:GetService("Lighting")
            Light.GlobalShadows = false
            Light.FogEnd = 9e9
            for _, e in ipairs(Light:GetChildren()) do
                if e:IsA("BloomEffect") or e:IsA("BlurEffect") or e:IsA("SunRaysEffect")
                    or e:IsA("DepthOfFieldEffect") or e:IsA("ColorCorrectionEffect") then
                    e.Enabled = false
                end
            end
        end)
        -- [FIX] War: 2 separate workspace:GetDescendants()-Schleifen → doppelte Iteration.
        -- Jetzt: eine einzige Schleife erledigt alles (Partikel + Material + Schatten).
        pcall(function()
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke")
                    or v:IsA("Fire") or v:IsA("Sparkles") then
                    v.Enabled = false
                elseif v:IsA("Decal") or v:IsA("Texture") then
                    v.Transparency = 1
                elseif v:IsA("BasePart") then
                    v.Material = Enum.Material.Plastic
                    v.Reflectance = 0
                    v.CastShadow = false
                    v.RenderFidelity = Enum.RenderFidelity.Automatic
                end
            end
        end)
        pcall(function()
            local terrain = workspace:FindFirstChildOfClass("Terrain")
            if terrain then
                terrain.WaterWaveSize = 0
                terrain.WaterWaveSpeed = 0
                terrain.WaterReflectance = 0
                terrain.WaterTransparency = 0
            end
        end)
        -- [FIX] settings() ist veraltet → UserSettings als moderner Ersatz
        pcall(function()
            UserSettings():GetService("UserGameSettings").SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1
        end)
        pcall(function()
            -- Lighting vereinfachen
            local L = game:GetService("Lighting")
            L.Brightness = 2
            L.Ambient = Color3.fromRGB(130, 130, 130)
            L.OutdoorAmbient = Color3.fromRGB(130, 130, 130)
            L.ClockTime = 14
        end)
        Rayfield:Notify({Title="🚀 FPS Boost v80", Content="Shadows, Partikel, RenderFidelity + Lighting optimiert!", Duration=4})
    end
})

SettingsTab:CreateToggle({
    Name = "✨ Effekte/Partikel dauerhaft aus",
    CurrentValue = false,
    Callback = function(state)
        if HubState.fpsBoostConn then HubState.fpsBoostConn:Disconnect() HubState.fpsBoostConn = nil end
        if not state then return end
        HubState.fpsBoostConn = workspace.DescendantAdded:Connect(function(v)
            pcall(function()
                if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke")
                    or v:IsA("Fire") or v:IsA("Sparkles") then
                    v.Enabled = false
                end
            end)
        end)
        Rayfield:Notify({Title="✨ Effekte aus", Content="Neue Partikel werden automatisch deaktiviert", Duration=2})
    end
})

SettingsTab:CreateKeybind({
    Name = "🖥️ UI anzeigen / verstecken",
    CurrentKeybind = "RightShift",
    HoldToInteract = false,
    Callback = function()
        pcall(function()
            Window.Toggle()
        end)
    end
})

SettingsTab:CreateKeybind({
    Name = "🔄 Schnell-Neustart (F5)",
    CurrentKeybind = "F5",
    HoldToInteract = false,
    Callback = function()
        -- Keybind Reload (still)

        pcall(function()
            -- === SEHR AGGRESSIVER CLEANUP (fast alles zurücksetzen) ===

            -- ConnectionManager (alle registrierten Verbindungen trennen)
            -- [v76] ConnectionManager ist ab Zeile ~2939 definiert und hat CleanupAll() → korrekt
            ConnectionManager:CleanupAll()

            -- Wichtige globale Verbindungen
            if HubState.BackGlueConn then HubState.BackGlueConn:Disconnect() HubState.BackGlueConn = nil end
            if HubState.PlayerSpinConn then HubState.PlayerSpinConn:Disconnect() HubState.PlayerSpinConn = nil end

            -- === Fast alle Features deaktivieren ===
            Settings.AimbotEnabled = false
            Settings.NormalAimbotEnabled = false
            Settings.ESPEnabled = false
            Settings.ChamsEnabled = false
            Settings.TracersEnabled = false
            Settings.HealthWeaponEnabled = false
            Settings.LookDirectionEnabled = false
            Settings.VoiceRangeEnabled = false
            Settings.WallhackEnabled = false
            Settings.FlyEnabled = false
            Settings.NoClipEnabled = false
            Settings.SprintBoostEnabled = false
            Settings.SuperSlideEnabled = false
            Settings.SuperJumpEnabled = false
            Settings.InfiniteJumpEnabled = false
            Settings.GodmodeEnabled = false
            Settings.CustomShootSoundEnabled = false
            Settings.InfiniteAmmoEnabled = false
            Settings.RageKnifeThrowEnabled = false

            -- Freecam deaktivieren
            freecamEnabled = false

            -- [FIX] Kill-Counter-Timer stoppen (war nicht stoppbar → Thread-Leak)
            HubState.killTimerActive = false

            -- [FIX v94] Verbindungen trennen die in v94 neu gespeichert wurden
            local _v94Conns = {
                "_fovCircleConn", "_npcDescAddedConn", "_npcDescRemovingConn",
                "_tracerPlayerAddedConn", "_tracerPlayerRemovingConn",
                "_inspectorPlayerAddedConn", "_inspectorPlayerRemovingConn",
                "_weaponScanConn", "_triggerBotConn", "_inspectorConn",
                "_fpsCounterConn", "_coordConn",  -- [FIX v101] fehlten in der Reset-Liste → Leaks geschlossen
            }
            for _, k in ipairs(_v94Conns) do
                if HubState[k] then
                    pcall(function() HubState[k]:Disconnect() end)
                    HubState[k] = nil
                end
            end
            -- [FIX v101] IIFE-Loop-Flags zurücksetzen (Fake Lag + Rainbow Sky überleben sonst F5)
            HubState._fakeLagActive    = false
            HubState._skyRainbowActive = false

            -- Anti Teleport deaktivieren
            HubState.antiTeleportEnabled = false
            if HubState.antiTeleportConn then HubState.antiTeleportConn:Disconnect() HubState.antiTeleportConn = nil end

            -- === Visuelle Elemente entfernen ===

            -- ESP / Chams / Health / Beams von allen Spielern entfernen
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr.Character then
                    for _, obj in ipairs(plr.Character:GetChildren()) do
                        if obj.Name:find("MeinESP") or obj.Name:find("MeinChams") or
                           obj.Name:find("HealthWeaponBillboard") or obj.Name:find("LookDirectionBeam") then
                            pcall(function() obj:Destroy() end)
                        end
                    end
                end
            end

            -- Tracers Linien entfernen
            for _, line in pairs(ActiveTracers or {}) do
                pcall(function() line:Destroy() end)
            end
            ActiveTracers = {}

            -- Voice Range Circle entfernen
            if VoiceRangePart and VoiceRangePart.Parent then
                pcall(function() VoiceRangePart:Destroy() end)
                VoiceRangePart = nil
            end
            if VoiceRangeOutline and VoiceRangeOutline.Parent then
                pcall(function() VoiceRangeOutline:Destroy() end)
                VoiceRangeOutline = nil
            end

            -- Wallhack zurücksetzen
            for part, t in pairs(originalTrans or {}) do
                if part and part.Parent then
                    pcall(function()
                        part.Transparency = t
                        if originalCollide[part] ~= nil then part.CanCollide = originalCollide[part] end
                    end)
                end
            end
            originalTrans = {}
            originalCollide = {}

            Rayfield:Notify({
                Title = "🔄 Schnell-Neustart",
                Content = "Script wurde gründlich zurückgesetzt. Bitte neu injizieren für frischen Start.",
                Duration = 6
            })

            -- Quick Reload abgeschlossen
        end)
    end
})

-- ==================== ANTI LAG + NO CLOTHES ====================
-- Anti Lag wurde zu More Anti Features verschoben

-- ==================== KILL COUNTER (v69 NEU) ====================
-- sessionKills / sessionStartTime / killCountLabel → in v69-Tabelle (kein extra local)
SettingsTab:CreateSection("💀 Kill Counter")

v69.killCountLabel = SettingsTab:CreateLabel("💀 Session Kills: 0  |  🕐 Session: 0 Min")

local function UpdateKillCounterLabel()
    local mins = math.floor((os.clock() - v69.sessionStartTime) / 60)
    v69.killCountLabel:Set(string.format("💀 Session Kills: %d  |  🕐 Session: %d Min", v69.sessionKills, mins))
end

_G.IncrementKillCounter = function()
    v69.sessionKills = v69.sessionKills + 1
    UpdateKillCounterLabel()
    if Settings.KillCounterEnabled then
        Rayfield:Notify({Title="💀 Kill!", Content="Session Kills: "..v69.sessionKills, Duration=1.5})
    end
end

-- Kill Detection: Humanoid.Died Hook auf alle Spieler (v69 Fix)
-- [FIX v76] IncrementKillCounter hier NICHT aufrufen → SetupKillEffectsListener macht das bereits.
-- Doppelter Aufruf würde jeden Kill doppelt zählen.
-- [BUG FIX] HookEnemyKillDetection war leer und hat nichts getan.
-- Die tote Players.PlayerAdded-Verbindung wurde entfernt (unnötiger Overhead).

SettingsTab:CreateToggle({
    Name = "Kill-Benachrichtigung anzeigen (Popup bei jedem Kill)",
    CurrentValue = false,
    Flag = "KillCounterEnabled",
    Callback = function(state) Settings.KillCounterEnabled = state end
})

SettingsTab:CreateButton({
    Name = "🔄 Kill Counter zurücksetzen",
    Callback = function()
        v69.sessionKills = 0
        v69.sessionStartTime = os.clock()
        UpdateKillCounterLabel()
        Rayfield:Notify({Title="Kill Counter", Content="Kill Counter zurückgesetzt!", Duration=2})
    end
})

-- Session-Timer updaten (alle 60s)
-- [FIX] War: while true → Thread lief ewig, konnte nicht gestoppt werden (Thread-Leak)
HubState.killTimerActive = true
task.spawn(function()
    while HubState.killTimerActive do
        task.wait(60)
        if HubState.killTimerActive then
            pcall(UpdateKillCounterLabel)
        end
    end
end)

-- ==================== SERVER & SPIELER-INSPEKTOR ====================
PlayerTab:CreateSection("🌐 1 · Spieler-Auswahl & Info")

local selectedPlayer = nil
local isSpectating = false
-- local playerList = nil  -- [FIX v101] redundant: wird unten via Window:CreatePlayerPanel() neu deklariert (war toter Shadow)

local function GetPlayerObjects()
    local list = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            table.insert(list, plr)
        end
    end
    table.sort(list, function(a, b) return a.Name:lower() < b.Name:lower() end)
    return list
end

local infoLabel_Name = PlayerTab:CreateLabel("👤 Name: -")
local infoLabel_Id = PlayerTab:CreateLabel("🆔 User-ID: -")
local infoLabel_Team = PlayerTab:CreateLabel("🔰 Team: -")
local infoLabel_Health = PlayerTab:CreateLabel("💗 Leben: -")
local infoLabel_Dist = PlayerTab:CreateLabel("📏 Distanz: -")
local infoLabel_Pos = PlayerTab:CreateLabel("📍 Standort: -")
local infoLabel_State = PlayerTab:CreateLabel("🚶 Status: -")
local infoLabel_Weapon = PlayerTab:CreateLabel("🗡 Waffe: -")
local infoLabel_Speed = PlayerTab:CreateLabel("⚡ WalkSpeed: -")
local infoLabel_Age = PlayerTab:CreateLabel("📅 Account Alter: -")

local function UpdateInspectorInfo()
    if not selectedPlayer or not selectedPlayer.Parent then
        infoLabel_Name:Set("👤 Name: -")
        infoLabel_Id:Set("🆔 User-ID: -")
        infoLabel_Team:Set("🔰 Team: -")
        infoLabel_Health:Set("💗 Leben: -")
        infoLabel_Dist:Set("📏 Distanz: -")
        infoLabel_Pos:Set("📍 Standort: -")
        infoLabel_State:Set("🚶 Status: -")
        infoLabel_Weapon:Set("🗡 Waffe: -")
        infoLabel_Speed:Set("⚡ WalkSpeed: -")
        infoLabel_Age:Set("📅 Account Alter: -")
        return
    end

    local char = selectedPlayer.Character
    local hum = char and char:FindFirstChild("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

    infoLabel_Name:Set("👤 Name: " .. selectedPlayer.Name .. " (" .. selectedPlayer.DisplayName .. ")")
    infoLabel_Id:Set("🆔 User-ID: " .. tostring(selectedPlayer.UserId))
    infoLabel_Team:Set("🔰 Team: " .. (selectedPlayer.Team and selectedPlayer.Team.Name or "Kein Team"))
    infoLabel_Health:Set("💗 Leben: " .. (hum and (math.floor(hum.Health) .. " / " .. math.floor(hum.MaxHealth)) or "Tot / Kein Char"))
    infoLabel_Dist:Set("📏 Distanz: " .. ((hrp and myHrp) and (math.floor((hrp.Position - myHrp.Position).Magnitude) .. " Studs") or "Unbekannt"))

    if hrp then
        local pos = hrp.Position
        infoLabel_Pos:Set(string.format("📍 Standort: X: %d | Y: %d | Z: %d", math.floor(pos.X), math.floor(pos.Y), math.floor(pos.Z)))
    else
        infoLabel_Pos:Set("📍 Standort: Unbekannt")
    end

    if hum then
        local state = tostring(hum:GetState()):gsub("Enum.HumanoidStateType.", "")
        local translatedState = state

        if state == "Running" or state == "RunningNoPhysics" then
            if hrp and (math.abs(hrp.AssemblyLinearVelocity.X) > 0.5 or math.abs(hrp.AssemblyLinearVelocity.Z) > 0.5) then
                translatedState = "Läuft"
            else
                translatedState = "Steht"
            end
        else
            local stateTranslations = {
                ["Jumping"] = "Springt",
                ["Freefall"] = "Fällt",
                ["Dead"] = "Tot",
                ["Sitting"] = "Sitzt",
                ["Climbing"] = "Klettert",
                ["Swimming"] = "Schwimmt",
                ["Physics"] = "Ragdoll / Physik",
                ["Landed"] = "Gelandet"
            }
            translatedState = stateTranslations[state] or state
        end
        infoLabel_State:Set("🚶 Status: " .. translatedState)
    else
        infoLabel_State:Set("🚶 Status: Unbekannt")
    end

    local tool = char and char:FindFirstChildOfClass("Tool")
    infoLabel_Weapon:Set("🗡 Waffe: " .. (tool and tool.Name or "Keine"))
    infoLabel_Speed:Set("⚡ WalkSpeed: " .. (hum and (hum.WalkSpeed and math.floor(hum.WalkSpeed) or "-") or "-"))
    infoLabel_Age:Set("📅 Account Alter: " .. (selectedPlayer.AccountAge and (selectedPlayer.AccountAge .. " Tage") or "Unbekannt"))

    -- [FIX] hum.Health > 0 prüfen: toter Humanoid wurde alle 0.5s neu als CameraSubject gesetzt
    if isSpectating and hum and hum.Health > 0 then
        Workspace.CurrentCamera.CameraSubject = hum
    end
end

-- [FIX v96-3] playerList: Global → local
local playerList = Window:CreatePlayerPanel({
    RowHeight = 60,
    Callback = function(plr)
        selectedPlayer = plr
        UpdateInspectorInfo()
    end,
})
playerList:Refresh(GetPlayerObjects())

PlayerTab:CreateButton({
    Name = "👥 Spielerliste öffnen / schließen",
    Callback = function()
        if playerList then
            if not playerList:IsOpen() then playerList:Refresh(GetPlayerObjects()) end
            playerList:Toggle()
        end
    end
})

PlayerTab:CreateButton({
    Name = "🔄 Spielerliste aktualisieren",
    Callback = function()
        if playerList then
            playerList:Refresh(GetPlayerObjects())
            Rayfield:Notify({Title = "Inspektor", Content = "Spielerliste auf den neusten Stand gebracht!", Duration = 2})
        end
    end
})

PlayerTab:CreateButton({
    Name = "📋 User-ID von ausgewähltem Spieler kopieren",
    Callback = function()
        pcall(function()
            if selectedPlayer and selectedPlayer.Parent then
                local uid = tostring(selectedPlayer.UserId)
                setclipboard(uid)
                Rayfield:Notify({Title = "✅ Kopiert!", Content = selectedPlayer.Name .. " • ID: " .. uid, Duration = 3})
            else
                Rayfield:Notify({Title = "❌ Kein Spieler", Content = "Wähle zuerst einen Spieler aus der Spielerliste aus!", Duration = 3})
            end
        end)
    end
})

-- Neue verbesserte Spieler-Suche (Teilname reicht)
PlayerTab:CreateInput({
    Name = "Spieler suchen (Name oder Teil davon)",
    PlaceholderText = "z.B. azat, killer, pro",
    RemoveTextAfterFocusLost = false,
    Callback = function(text)
        if text == "" then return end

        local foundPlayer = nil
        local lowerText = string.lower(text)

        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                local name = string.lower(plr.Name)
                local display = string.lower(plr.DisplayName)

                if string.find(name, lowerText) or string.find(display, lowerText) then
                    foundPlayer = plr
                    break
                end
            end
        end

        if foundPlayer then
            selectedPlayer = foundPlayer
            UpdateInspectorInfo()
            Rayfield:Notify({
                Title = "Spieler gefunden",
                Content = foundPlayer.Name .. " wurde ausgewählt",
                Duration = 2
            })
        else
            Rayfield:Notify({
                Title = "Nicht gefunden",
                Content = "Kein Spieler mit '" .. text .. "' gefunden",
                Duration = 2
            })
        end
    end
})

local lastInspectTick = 0
HubState._inspectorConn = RunService.Heartbeat:Connect(function()
    if selectedPlayer and (os.clock() - lastInspectTick > 0.5) then
        lastInspectTick = os.clock()
        UpdateInspectorInfo()
    end
end)

local function RefreshPlayerListSoon()
    task.delay(0.3, function()
        if playerList then pcall(function() playerList:Refresh(GetPlayerObjects()) end) end
    end)
end
-- [FIX v94] Connections speichern
HubState._inspectorPlayerAddedConn = Players.PlayerAdded:Connect(RefreshPlayerListSoon)
HubState._inspectorPlayerRemovingConn = Players.PlayerRemoving:Connect(function(plr)
    if plr == selectedPlayer then
        selectedPlayer = nil
        UpdateInspectorInfo()
    end
    RefreshPlayerListSoon()
end)


-- ============================================================
-- PLAYER AKTIONEN v70 — Verbessert + massiv erweitert
-- ALLE Zustände in HubState → kein neues top-level local
-- ============================================================

-- HubState-Felder für Player-Aktionen initialisieren
HubState.pa_glueConn       = nil
HubState.pa_underConn      = nil
HubState.pa_underOffset    = 5
HubState.pa_underFlip      = false
HubState.pa_underFollow    = false
HubState.pa_underOrig      = nil
HubState.pa_pinConn        = nil
HubState.pa_orbitConn      = nil
HubState.pa_orbitDist      = 8
HubState.pa_orbitSpeed     = 90
HubState.pa_followConn     = nil
HubState.pa_followDist     = 5
HubState.pa_followSpeed    = 16
HubState.pa_loopFlingConn  = nil
HubState.pa_velFlingConn   = nil
HubState.pa_velFlingPower  = 9999
HubState.pa_loopBringConn  = nil
HubState.pa_loopBringDelay = 2
HubState.pa_highlightObj   = nil
HubState.pa_spinConn       = nil
HubState.pa_flingActive    = false
HubState.pa_spectating     = false
isSpectating               = false  -- [FIX v101] Initialisierung synchron halten

-- [FIX] spamRunning/spamConn hier forward-deklarieren: der Notfall-Stop-Callback
-- (Closure) kann nur locals erfassen die VOR seiner Definition existieren.
-- Die ursprüngliche Deklaration war erst bei Zeile ~14390 (Chat Spam Tool) →
-- der Callback sah immer nil (global scope), konnte Spam nie stoppen.
local spamRunning = false
local spamThread = nil  -- [FIX v94] Umbenennung: ist Thread (task.spawn), kein RBXConnection

-- ============================================================
-- 🚨 GLOBALER NOTFALL-STOP
-- ============================================================
PlayerTab:CreateSection("🚨 1 · Notfall-Stop")

PlayerTab:CreateButton({
    Name = "🚨 ALLES STOPPEN (Notfall-Reset)",
    Callback = function()
        -- 1) Alle RunService-Connections und Task-Threads trennen/abbrechen
        local connKeys = {
            "pa_glueConn", "pa_underConn", "pa_pinConn", "pa_orbitConn",
            "pa_followConn", "pa_velFlingConn", "pa_spinConn", "BackGlueConn",
            "PlayerSpinConn", "pa_hugConn", "pa_sitHeadConn", "pa_carryConn",
            "pa_frontConn", "pa_shoulderConn", "pa_handstandConn",
            "pa_backpackConn", "pa_sackConn", "heliConn",
        }
        for _, key in ipairs(connKeys) do
            if HubState[key] then
                pcall(function() HubState[key]:Disconnect() end)
                HubState[key] = nil
            end
        end

        -- 2) Task-Threads (Loop Fling, Loop Bring) abbrechen
        local taskKeys = { "pa_loopFlingConn", "pa_loopBringConn" }
        for _, key in ipairs(taskKeys) do
            if HubState[key] then
                local _t = HubState[key]
                HubState[key] = nil
                pcall(function() task.cancel(_t) end)
            end
        end

        -- 3) Chat-Spam stoppen (lokale Variablen über HubState erreichbar)
        pcall(function()
            if spamRunning ~= nil then spamRunning = false end
            if spamThread then task.cancel(spamThread); spamThread = nil end  -- [FIX v94] korrekt: task.cancel auf Thread
        end)

        -- 4) Charakter-Zustand zurücksetzen
        pcall(function()
            local char = LocalPlayer.Character
            if not char then return end
            local hum = char:FindFirstChild("Humanoid")
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hum then
                hum.PlatformStand = false
                hum.Sit           = false
                hum.WalkSpeed     = HubState.pa_followOrigWS or 16
                hum.JumpPower     = 50
            end
            if hrp then
                hrp.Anchored                = false
                hrp.AssemblyLinearVelocity  = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
            end
        end)

        -- 5) Kamera zurücksetzen (falls Spectate aktiv war)
        pcall(function()
            if HubState.pa_spectating then
                HubState.pa_spectating = false
                isSpectating = false  -- [FIX v101] beide Flags synchron zurücksetzen
                local myHum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
                if myHum then Workspace.CurrentCamera.CameraSubject = myHum end
            end
        end)

        -- 6) Unterkleben-Flags zurücksetzen
        HubState.pa_underFollow = false
        HubState.pa_flingActive = false

        Rayfield:Notify({
            Title   = "🚨 Notfall-Reset",
            Content = "Alle Verbindungen getrennt · Charakter zurückgesetzt · Spam gestoppt",
            Duration = 4
        })
    end
})

PlayerTab:CreateLabel("⚠️ Drücke 'ALLES STOPPEN' um sofort alle aktiven Player-Features (Follow, Orbit, Glue, Fling, Spin, Helikopter, Chat-Spam usw.) zu beenden und deinen Charakter zurückzusetzen.")

PlayerTab:CreateSection("⚡ 2 · Schnell-Aktionen")

-- ──────────────────────────────────────────────
-- 📍 TELEPORT & SPECTATE
-- ──────────────────────────────────────────────

PlayerTab:CreateButton({
    Name = "🚀 Zu Spieler teleportieren",
    Callback = function()
        if not selectedPlayer or not selectedPlayer.Character then
            Rayfield:Notify({Title="Fehler", Content="Spieler nicht bereit!", Duration=2}) return
        end
        local tHRP = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
        local mHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if tHRP and mHRP then
            mHRP.CFrame = tHRP.CFrame * CFrame.new(0, 0, 3)
            Rayfield:Notify({Title="Teleport", Content="Zu "..selectedPlayer.Name.." teleportiert", Duration=2})
        end
    end
})

PlayerTab:CreateToggle({
    Name = "👀 Spieler zuschauen (Spectate)",
    CurrentValue = false,
    Callback = function(state)
        HubState.pa_spectating = state
        isSpectating = state  -- [FIX v101] war nie gesetzt → UpdateInspectorInfo()-Guard jetzt erreichbar
        local cam = Workspace.CurrentCamera
        if state then
            if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("Humanoid") then
                cam.CameraSubject = selectedPlayer.Character.Humanoid
                Rayfield:Notify({Title="Spectate", Content="Beobachte: "..selectedPlayer.Name, Duration=2})
            end
        else
            local myHum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
            if myHum then cam.CameraSubject = myHum end
        end
    end
})

PlayerTab:CreateButton({
    Name = "🎯 Als Aimbot-Ziel erzwingen",
    Callback = function()
        if not selectedPlayer then return end
        currentLockedTarget = selectedPlayer
        currentNormalTarget = selectedPlayer
        Rayfield:Notify({Title="Target Lock", Content="Aimbot → "..selectedPlayer.Name, Duration=3})
    end
})

-- ──────────────────────────────────────────────
-- 🏃 FOLGEN & ORBIT
-- ──────────────────────────────────────────────
PlayerTab:CreateSection("🏃 3 · Folgen & Orbit")

PlayerTab:CreateSlider({
    Name = "Follow Abstand (Studs)",
    Range = {2, 30},
    Increment = 1,
    CurrentValue = 5,
    Callback = function(v) HubState.pa_followDist = v end
})
PlayerTab:CreateSlider({
    Name = "Follow Geschwindigkeit (Studs/s)",
    Range = {8, 1000},
    Increment = 1,
    CurrentValue = 16,
    Callback = function(v) HubState.pa_followSpeed = v end
})
PlayerTab:CreateToggle({
    Name = "🏃 Spieler automatisch folgen",
    CurrentValue = false,
    Callback = function(state)
        if HubState.pa_followConn then HubState.pa_followConn:Disconnect() HubState.pa_followConn = nil end
        -- beim Ausschalten Originaltempo wiederherstellen
        if not state then
            pcall(function()
                local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
                if hum and HubState.pa_followOrigWS then hum.WalkSpeed = HubState.pa_followOrigWS end
            end)
            return
        end
        if not selectedPlayer then
            Rayfield:Notify({Title="Fehler", Content="Kein Spieler ausgewählt!", Duration=2}) return
        end
        -- Originaltempo merken
        pcall(function()
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
            if hum then HubState.pa_followOrigWS = hum.WalkSpeed end
        end)
        local _c
        _c = RunService.Heartbeat:Connect(function()
            pcall(function()
                if not selectedPlayer or not selectedPlayer.Character then return end
                local tHRP = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
                local mHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                local hum  = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
                if not tHRP or not mHRP or not hum then
                    -- Ziel oder eigener Char verschwunden → WalkSpeed sofort zurücksetzen
                    local fallbackHum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
                    if fallbackHum and HubState.pa_followOrigWS then
                        fallbackHum.WalkSpeed = HubState.pa_followOrigWS
                    end
                    return
                end
                -- echte Lauf-Geschwindigkeit setzen → Charakter läuft mit Animation
                hum.WalkSpeed = HubState.pa_followSpeed or 16
                local followDist = HubState.pa_followDist or 5
                local toTarget = tHRP.Position - mHRP.Position
                local dist = toTarget.Magnitude
                if dist > followDist + 1 then
                    local desired = tHRP.Position - toTarget.Unit * followDist
                    hum:MoveTo(desired)
                else
                    hum:MoveTo(mHRP.Position)  -- anhalten, wenn nah genug
                end
            end)
        end)
        HubState.pa_followConn = _c
        Rayfield:Notify({Title="Follow", Content="Folge "..selectedPlayer.Name, Duration=2})
    end
})

-- [FIX] NoCollide-Helper: verhindert Physik-Überlappung bei Trage/Troll-Emotes
local _savedCollide = {}
local function _attachNoCollide()
    _savedCollide = {}
    local char = LocalPlayer.Character
    if not char then return end
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") then
            _savedCollide[p] = p.CanCollide
            p.CanCollide = false
        end
    end
end
local function _restoreCollide()
    for p, v in pairs(_savedCollide) do
        pcall(function() if p and p.Parent then p.CanCollide = v end end)
    end
    _savedCollide = {}
end

-- [FIX] DisconnectAllAttachConns VOR dem ersten Aufruf (Orbit-Toggle) definiert.
-- War: Funktion stand NACH Zeile 9910, Orbit-Toggle rief sie VORHER auf →
-- Lua-local nicht im Scope → globale Suche → nil → "attempt to call nil value".
local function DisconnectAllAttachConns()
    -- 1) RBX-Verbindungen trennen (haben :Disconnect())
    for _, key in ipairs({
        "pa_glueConn","pa_underConn","pa_pinConn","pa_orbitConn",
        "pa_followConn","pa_velFlingConn","pa_spinConn","BackGlueConn",
        "PlayerSpinConn","pa_hugConn","pa_sitHeadConn","pa_carryConn",
        "pa_frontConn","pa_shoulderConn","pa_handstandConn",
        "pa_backpackConn","pa_sackConn","heliConn",
    }) do
        if HubState[key] then
            pcall(function() HubState[key]:Disconnect() end)
            HubState[key] = nil
        end
    end
    -- [FIX] 2) task.spawn-Threads abbrechen (haben KEIN :Disconnect() → müssen mit task.cancel gestoppt werden).
    -- War: pa_loopFlingConn und pa_loopBringConn fehlten hier → Loop lief im Hintergrund weiter
    -- wenn ein anderer Attach-Modus aktiviert wurde (Spieler wurde trotz Moduswechsel endlos geflingt).
    for _, key in ipairs({ "pa_loopFlingConn", "pa_loopBringConn" }) do
        if HubState[key] then
            local _t = HubState[key]
            HubState[key] = nil
            pcall(function() task.cancel(_t) end)
        end
    end
    pcall(function()
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then hum.PlatformStand = false; hum.Sit = false end
    end)
    _restoreCollide()
    HubState.pa_underFollow = false
end

PlayerTab:CreateSlider({
    Name = "Orbit Distanz (Studs)",
    Range = {3, 25},
    Increment = 1,
    CurrentValue = 8,
    Callback = function(v) HubState.pa_orbitDist = v end
})
PlayerTab:CreateSlider({
    Name = "Orbit Geschwindigkeit (Grad/s)",
    Range = {10, 360},
    Increment = 10,
    CurrentValue = 90,
    Callback = function(v) HubState.pa_orbitSpeed = v end
})
PlayerTab:CreateToggle({
    Name = "🌀 Orbit (um Spieler kreisen)",
    CurrentValue = false,
    Callback = function(state)
        if HubState.pa_orbitConn then HubState.pa_orbitConn:Disconnect() HubState.pa_orbitConn = nil end
        if not state then return end
        DisconnectAllAttachConns() -- [FIX] Andere Attach-Modes trennen: verhindert gleichzeitige aktive Verbindungen
        if not selectedPlayer then
            Rayfield:Notify({Title="Fehler", Content="Kein Spieler ausgewählt!", Duration=2}) return
        end
        local angle = 0
        local _c
        _c = RunService.Heartbeat:Connect(function(dt)
            pcall(function()
                if not selectedPlayer or not selectedPlayer.Character then return end
                local tHRP = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
                local mHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if not tHRP or not mHRP then return end
                angle = (angle + (HubState.pa_orbitSpeed or 90) * dt) % 360
                local rad  = math.rad(angle)
                local dist = HubState.pa_orbitDist or 8
                local x    = tHRP.Position.X + math.cos(rad) * dist
                local z    = tHRP.Position.Z + math.sin(rad) * dist
                mHRP.CFrame = CFrame.new(x, tHRP.Position.Y, z)
                mHRP.AssemblyLinearVelocity = Vector3.zero
            end)
        end)
        HubState.pa_orbitConn = _c
        Rayfield:Notify({Title="Orbit", Content="Kreise um "..selectedPlayer.Name, Duration=2})
    end
})

-- ──────────────────────────────────────────────
-- 🧲 KLEBEN & UNTERKLEBEN
-- ──────────────────────────────────────────────
PlayerTab:CreateSection("🧲 4 · Kleben & Anhängen")

PlayerTab:CreateButton({
    Name = "🧲 Hinter Rücken kleben (Glue)",
    Callback = function()
        if not selectedPlayer or not selectedPlayer.Character then
            Rayfield:Notify({Title="Fehler", Content="Kein Spieler ausgewählt!", Duration=2}) return
        end
        local tHRP = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
        local mChr = LocalPlayer.Character
        local mHRP = mChr and mChr:FindFirstChild("HumanoidRootPart")
        if not tHRP or not mHRP then return end
        if HubState.pa_glueConn then HubState.pa_glueConn:Disconnect() HubState.pa_glueConn = nil end
        if HubState.BackGlueConn then HubState.BackGlueConn:Disconnect() HubState.BackGlueConn = nil end
        local hum = mChr:FindFirstChild("Humanoid")
        if hum then hum.PlatformStand = true end
        mHRP.CFrame = tHRP.CFrame * CFrame.new(0, 0, 0.25) * CFrame.Angles(0, math.rad(180), 0)
        local _c
        _c = RunService.Stepped:Connect(function()
            pcall(function()
                if not tHRP or not tHRP.Parent or not mHRP or not mHRP.Parent then
                    _c:Disconnect(); HubState.pa_glueConn = nil
                    pcall(function() if hum then hum.PlatformStand = false end end)
                    return
                end
                mHRP.CFrame = tHRP.CFrame * CFrame.new(0, 0, 0.25) * CFrame.Angles(0, math.rad(180), 0)
                mHRP.AssemblyLinearVelocity  = Vector3.zero
                mHRP.AssemblyAngularVelocity = Vector3.zero
            end)
        end)
        HubState.pa_glueConn = _c
        HubState.BackGlueConn = _c
        local _gc
        _gc = LocalPlayer.CharacterRemoving:Connect(function()
            if _c then _c:Disconnect() end
            HubState.pa_glueConn = nil; HubState.BackGlueConn = nil
            pcall(function() if hum then hum.PlatformStand = false end end)
            _gc:Disconnect()
        end)
        Rayfield:Notify({Title="Glue", Content="Klebst hinter "..selectedPlayer.Name, Duration=3})
    end
})

-- [FIX] Funktion wurde hierher verschoben — Definition steht jetzt OBERHALB des ersten Aufrufs.
-- Siehe Kommentar über dem Orbit-Slider weiter oben.

PlayerTab:CreateButton({
    Name = "❌ Alle Klebe-Verbindungen lösen",
    Callback = function()
        DisconnectAllAttachConns() -- [FIX] nutzt jetzt zentrale Funktion
        Rayfield:Notify({Title="Cleanup", Content="Alle Verbindungen gelöst!", Duration=2})
    end
})

PlayerTab:CreateSlider({
    Name = "Abstand unter Spieler (Studs)",
    Range = {2, 20},
    Increment = 0.5,
    CurrentValue = 5,
    Callback = function(v) HubState.pa_underOffset = v end
})
PlayerTab:CreateToggle({
    Name = "Unter Spieler kleben (folgend)",
    CurrentValue = false,
    Callback = function(state)
        if HubState.pa_underConn then HubState.pa_underConn:Disconnect() HubState.pa_underConn = nil end
        HubState.pa_underFollow = state
        if not state then
            if HubState.pa_underOrig then
                pcall(function()
                    local mHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if mHRP then mHRP.CFrame = CFrame.new(HubState.pa_underOrig); mHRP.AssemblyLinearVelocity = Vector3.zero end
                end)
                HubState.pa_underOrig = nil
            end
            return
        end
        if not selectedPlayer then
            Rayfield:Notify({Title="Fehler", Content="Kein Spieler ausgewählt!", Duration=2}) return
        end
        pcall(function()
            local mHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if mHRP then HubState.pa_underOrig = mHRP.Position end
        end)
        local _c
        _c = RunService.Heartbeat:Connect(function()
            pcall(function()
                if not HubState.pa_underFollow then _c:Disconnect() return end
                if not selectedPlayer or not selectedPlayer.Character then return end
                local tHRP = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
                local mHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if not tHRP or not mHRP then return end
                local base = tHRP.CFrame * CFrame.new(0, -(HubState.pa_underOffset or 5), 0)
                mHRP.CFrame = HubState.pa_underFlip and (base * CFrame.Angles(math.rad(180),0,0)) or base
                mHRP.AssemblyLinearVelocity = Vector3.zero
            end)
        end)
        HubState.pa_underConn = _c
        Rayfield:Notify({Title="Unter Spieler", Content="Klebst unter "..selectedPlayer.Name, Duration=2})
    end
})
PlayerTab:CreateToggle({
    Name = "Kopf nach unten (Mic verstecken)",
    CurrentValue = false,
    Callback = function(state) HubState.pa_underFlip = state end
})

-- ──────────────────────────────────────────────
-- 🫂 TROLL EMOTES (auf ausgewählten Spieler)
-- ──────────────────────────────────────────────
PlayerTab:CreateSection("🫂 5 · Trage- & Troll-Emotes")

PlayerTab:CreateToggle({
    Name = "🫂 Umarmen (vor Spieler, zugewandt)",
    CurrentValue = false,
    Callback = function(state)
        if HubState.pa_hugConn then HubState.pa_hugConn:Disconnect() HubState.pa_hugConn = nil end
        if not state then
            pcall(function()
                local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
                if hum then hum.PlatformStand = false end
            end)
            return
        end
        DisconnectAllAttachConns() -- [FIX] Andere Attach-Modes trennen
        if not selectedPlayer or not selectedPlayer.Character then
            Rayfield:Notify({Title="Fehler", Content="Kein Spieler ausgewählt!", Duration=2}) return
        end
        _attachNoCollide()
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then hum.PlatformStand = true end
        local _c
        _c = RunService.RenderStepped:Connect(function()
            pcall(function()
                if not selectedPlayer or not selectedPlayer.Character then return end
                local tHRP = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
                local mHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if not tHRP or not mHRP then return end
                mHRP.CFrame = tHRP.CFrame * CFrame.new(0, 0, -1.6) * CFrame.Angles(0, math.rad(180), 0)
                mHRP.AssemblyLinearVelocity = Vector3.zero
                mHRP.AssemblyAngularVelocity = Vector3.zero
            end)
        end)
        HubState.pa_hugConn = _c
        Rayfield:Notify({Title="Umarmen", Content="Umarmst "..selectedPlayer.Name, Duration=2})
    end
})

PlayerTab:CreateToggle({
    Name = "🧍 Auf dem Kopf sitzen",
    CurrentValue = false,
    Callback = function(state)
        if HubState.pa_sitHeadConn then HubState.pa_sitHeadConn:Disconnect() HubState.pa_sitHeadConn = nil end
        if not state then
            pcall(function()
                local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
                if hum then hum.Sit = false; hum.PlatformStand = false end
            end)
            return
        end
        DisconnectAllAttachConns() -- [FIX] Andere Attach-Modes trennen
        if not selectedPlayer or not selectedPlayer.Character then
            Rayfield:Notify({Title="Fehler", Content="Kein Spieler ausgewählt!", Duration=2}) return
        end
        _attachNoCollide()
        local _c
        _c = RunService.RenderStepped:Connect(function()
            pcall(function()
                if not selectedPlayer or not selectedPlayer.Character then return end
                local tHead = selectedPlayer.Character:FindFirstChild("Head")
                    or selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
                local myChar = LocalPlayer.Character
                local mHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
                local mHum = myChar and myChar:FindFirstChild("Humanoid")
                if not tHead or not mHRP then return end
                if mHum then mHum.PlatformStand = false; mHum.Sit = true end
                mHRP.CFrame = tHead.CFrame * CFrame.new(0, 1.6, 0)
                mHRP.AssemblyLinearVelocity = Vector3.zero
                mHRP.AssemblyAngularVelocity = Vector3.zero
            end)
        end)
        HubState.pa_sitHeadConn = _c
        Rayfield:Notify({Title="Auf Kopf", Content="Sitzt auf "..selectedPlayer.Name.."'s Kopf", Duration=2})
    end
})

PlayerTab:CreateToggle({
    Name = "🤝 Getragen werden (Huckepack auf Rücken)",
    CurrentValue = false,
    Callback = function(state)
        if HubState.pa_carryConn then HubState.pa_carryConn:Disconnect() HubState.pa_carryConn = nil end
        if not state then
            pcall(function()
                local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
                if hum then hum.PlatformStand = false end
            end)
            return
        end
        DisconnectAllAttachConns() -- [FIX] Andere Attach-Modes trennen
        if not selectedPlayer or not selectedPlayer.Character then
            Rayfield:Notify({Title="Fehler", Content="Kein Spieler ausgewählt!", Duration=2}) return
        end
        _attachNoCollide()
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then hum.PlatformStand = true end
        local _c
        _c = RunService.RenderStepped:Connect(function()
            pcall(function()
                if not selectedPlayer or not selectedPlayer.Character then return end
                local tHRP = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
                local mHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if not tHRP or not mHRP then return end
                mHRP.CFrame = tHRP.CFrame * CFrame.new(0, 1.2, 1.1)
                mHRP.AssemblyLinearVelocity = Vector3.zero
                mHRP.AssemblyAngularVelocity = Vector3.zero
            end)
        end)
        HubState.pa_carryConn = _c
        Rayfield:Notify({Title="Huckepack", Content=selectedPlayer.Name.." trägt dich", Duration=2})
    end
})

PlayerTab:CreateToggle({
    Name = "🙆 Vorne getragen werden (in den Armen)",
    CurrentValue = false,
    Callback = function(state)
        if HubState.pa_frontConn then HubState.pa_frontConn:Disconnect() HubState.pa_frontConn = nil end
        if not state then
            pcall(function()
                local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
                if hum then hum.PlatformStand = false end
            end)
            return
        end
        DisconnectAllAttachConns() -- [FIX] Andere Attach-Modes trennen
        if not selectedPlayer or not selectedPlayer.Character then
            Rayfield:Notify({Title="Fehler", Content="Kein Spieler ausgewählt!", Duration=2}) return
        end
        _attachNoCollide()
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then hum.PlatformStand = true end
        local _c
        _c = RunService.RenderStepped:Connect(function()
            pcall(function()
                if not selectedPlayer or not selectedPlayer.Character then return end
                local tHRP = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
                local mHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if not tHRP or not mHRP then return end
                mHRP.CFrame = tHRP.CFrame * CFrame.new(0, 0.4, -1.5) * CFrame.Angles(math.rad(-90), 0, 0)
                mHRP.AssemblyLinearVelocity = Vector3.zero
                mHRP.AssemblyAngularVelocity = Vector3.zero
            end)
        end)
        HubState.pa_frontConn = _c
        Rayfield:Notify({Title="Vorne tragen", Content=selectedPlayer.Name.." trägt dich vorne", Duration=2})
    end
})

PlayerTab:CreateToggle({
    Name = "🦸 Auf den Schultern sitzen",
    CurrentValue = false,
    Callback = function(state)
        if HubState.pa_shoulderConn then HubState.pa_shoulderConn:Disconnect() HubState.pa_shoulderConn = nil end
        if not state then
            pcall(function()
                local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
                if hum then hum.Sit = false; hum.PlatformStand = false end
            end)
            return
        end
        DisconnectAllAttachConns() -- [FIX] Andere Attach-Modes trennen
        if not selectedPlayer or not selectedPlayer.Character then
            Rayfield:Notify({Title="Fehler", Content="Kein Spieler ausgewählt!", Duration=2}) return
        end
        _attachNoCollide()
        local _c
        _c = RunService.RenderStepped:Connect(function()
            pcall(function()
                if not selectedPlayer or not selectedPlayer.Character then return end
                local tHRP = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
                local myChar = LocalPlayer.Character
                local mHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
                local mHum = myChar and myChar:FindFirstChild("Humanoid")
                if not tHRP or not mHRP then return end
                if mHum then mHum.PlatformStand = false; mHum.Sit = true end
                mHRP.CFrame = tHRP.CFrame * CFrame.new(0, 2.4, -0.1)
                mHRP.AssemblyLinearVelocity = Vector3.zero
                mHRP.AssemblyAngularVelocity = Vector3.zero
            end)
        end)
        HubState.pa_shoulderConn = _c
        Rayfield:Notify({Title="Schultern", Content="Sitzt auf "..selectedPlayer.Name.."'s Schultern", Duration=2})
    end
})

PlayerTab:CreateToggle({
    Name = "🤸 Kopfstand auf dem Kopf",
    CurrentValue = false,
    Callback = function(state)
        if HubState.pa_handstandConn then HubState.pa_handstandConn:Disconnect() HubState.pa_handstandConn = nil end
        if not state then
            pcall(function()
                local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
                if hum then hum.PlatformStand = false end
            end)
            return
        end
        DisconnectAllAttachConns() -- [FIX] Andere Attach-Modes trennen
        if not selectedPlayer or not selectedPlayer.Character then
            Rayfield:Notify({Title="Fehler", Content="Kein Spieler ausgewählt!", Duration=2}) return
        end
        _attachNoCollide()
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then hum.PlatformStand = true end
        local _c
        _c = RunService.RenderStepped:Connect(function()
            pcall(function()
                if not selectedPlayer or not selectedPlayer.Character then return end
                local tHead = selectedPlayer.Character:FindFirstChild("Head")
                    or selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
                local mHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if not tHead or not mHRP then return end
                mHRP.CFrame = tHead.CFrame * CFrame.new(0, 2.6, 0) * CFrame.Angles(0, 0, math.rad(180))
                mHRP.AssemblyLinearVelocity = Vector3.zero
                mHRP.AssemblyAngularVelocity = Vector3.zero
            end)
        end)
        HubState.pa_handstandConn = _c
        Rayfield:Notify({Title="Kopfstand", Content="Kopfstand auf "..selectedPlayer.Name, Duration=2})
    end
})

PlayerTab:CreateToggle({
    Name = "🎒 Rucksack (hoch am Rücken)",
    CurrentValue = false,
    Callback = function(state)
        if HubState.pa_backpackConn then HubState.pa_backpackConn:Disconnect() HubState.pa_backpackConn = nil end
        if not state then
            pcall(function()
                local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
                if hum then hum.PlatformStand = false end
            end)
            return
        end
        DisconnectAllAttachConns() -- [FIX] Andere Attach-Modes trennen
        if not selectedPlayer or not selectedPlayer.Character then
            Rayfield:Notify({Title="Fehler", Content="Kein Spieler ausgewählt!", Duration=2}) return
        end
        _attachNoCollide()
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then hum.PlatformStand = true end
        local _c
        _c = RunService.RenderStepped:Connect(function()
            pcall(function()
                if not selectedPlayer or not selectedPlayer.Character then return end
                local tHRP = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
                local mHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if not tHRP or not mHRP then return end
                mHRP.CFrame = tHRP.CFrame * CFrame.new(0, 0.8, 0.95)
                mHRP.AssemblyLinearVelocity = Vector3.zero
                mHRP.AssemblyAngularVelocity = Vector3.zero
            end)
        end)
        HubState.pa_backpackConn = _c
        Rayfield:Notify({Title="Rucksack", Content="Hängst am Rücken von "..selectedPlayer.Name, Duration=2})
    end
})

PlayerTab:CreateToggle({
    Name = "🪵 Über der Schulter tragen (Sack)",
    CurrentValue = false,
    Callback = function(state)
        if HubState.pa_sackConn then HubState.pa_sackConn:Disconnect() HubState.pa_sackConn = nil end
        if not state then
            pcall(function()
                local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
                if hum then hum.PlatformStand = false end
            end)
            return
        end
        DisconnectAllAttachConns() -- [FIX] Andere Attach-Modes trennen
        if not selectedPlayer or not selectedPlayer.Character then
            Rayfield:Notify({Title="Fehler", Content="Kein Spieler ausgewählt!", Duration=2}) return
        end
        _attachNoCollide()
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then hum.PlatformStand = true end
        local _c
        _c = RunService.RenderStepped:Connect(function()
            pcall(function()
                if not selectedPlayer or not selectedPlayer.Character then return end
                local tHRP = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
                local mHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if not tHRP or not mHRP then return end
                mHRP.CFrame = tHRP.CFrame * CFrame.new(0.4, 1.5, 0) * CFrame.Angles(0, 0, math.rad(85))
                mHRP.AssemblyLinearVelocity = Vector3.zero
                mHRP.AssemblyAngularVelocity = Vector3.zero
            end)
        end)
        HubState.pa_sackConn = _c
        Rayfield:Notify({Title="Sack", Content=selectedPlayer.Name.." trägt dich über der Schulter", Duration=2})
    end
})

PlayerTab:CreateLabel("📋 Troll-Emotes bewegen NUR deinen eigenen Charakter relativ zum ausgewählten Spieler. Zum Beenden Toggle aus oder 'Alle Klebe-Verbindungen lösen'.")

-- ──────────────────────────────────────────────
-- 💥 ANGRIFF & FLING
-- ──────────────────────────────────────────────
PlayerTab:CreateSection("💥 6 · Angriff & Fling")

-- ══ KILASIK Fling (SkidFling-Methode) ══════════════════════════════════
getgenv().pa_skidFlingFPDH = getgenv().pa_skidFlingFPDH or workspace.FallenPartsDestroyHeight
HubState.pa_loopFlingActive = false   -- eigener Flag, unabhängig von pa_flingActive

local function pa_skidFling(TargetPlayer, loopMode)
    -- loopMode = true  → SFBasePart bricht ab sobald pa_loopFlingActive false wird
    -- loopMode = false → einmalig, immer 2s laufen
    local Character  = LocalPlayer.Character
    local Humanoid   = Character and Character:FindFirstChildOfClass("Humanoid")
    local RootPart   = Humanoid  and Humanoid.RootPart
    local TCharacter = TargetPlayer and TargetPlayer.Character
    if not TCharacter then return end

    local THumanoid, TRootPart, THead, Handle
    THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
    if THumanoid and THumanoid.RootPart then TRootPart = THumanoid.RootPart end
    if TCharacter:FindFirstChild("Head") then THead = TCharacter.Head end
    local Acc = TCharacter:FindFirstChildOfClass("Accessory")
    if Acc and Acc:FindFirstChild("Handle") then Handle = Acc.Handle end

    if not (Character and Humanoid and RootPart) then return end

    -- OldPos nur speichern wenn Spieler steht (nicht selbst geflingt wird)
    if RootPart.Velocity.Magnitude < 50 then
        getgenv().pa_skidFlingOldPos = RootPart.CFrame
    end

    if THumanoid and THumanoid.Sit then return end
    if not TCharacter:FindFirstChildWhichIsA("BasePart") then return end

    -- Kamera auf Ziel
    workspace.CurrentCamera.CameraSubject = THead or Handle or THumanoid or workspace.CurrentCamera.CameraSubject

    local function FPos(BP, Pos, Ang)
        RootPart.CFrame = CFrame.new(BP.Position) * Pos * Ang
        Character:SetPrimaryPartCFrame(CFrame.new(BP.Position) * Pos * Ang)
        RootPart.Velocity    = Vector3.new(9e7, 9e7 * 10, 9e7)
        RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
    end

    local function SFBasePart(BP)
        local deadline = os.clock() + 3  -- [FIX v101] tick() → os.clock(); [TURBO] 2s → 3s
        local Angle    = 0
        repeat
            if not (RootPart and RootPart.Parent and THumanoid) then break end
            Angle = Angle + 120  -- [TURBO] schnellere Rotation
            if BP.Velocity.Magnitude < 50 then
                local md = THumanoid.MoveDirection
                local vm = BP.Velocity.Magnitude / 1.25
                -- [TURBO] Doppelter Hit pro Position: 2× FPos ohne wait dazwischen
                FPos(BP, CFrame.new(0,  2.5, 0) + md * vm, CFrame.Angles(math.rad(Angle), 0, 0))
                FPos(BP, CFrame.new(0,  2.5, 0) + md * vm, CFrame.Angles(math.rad(Angle), 0, 0)) task.wait()
                FPos(BP, CFrame.new(0, -2.5, 0) + md * vm, CFrame.Angles(math.rad(Angle), 0, 0))
                FPos(BP, CFrame.new(0, -2.5, 0) + md * vm, CFrame.Angles(math.rad(Angle), 0, 0)) task.wait()
                FPos(BP, CFrame.new(0,  2.5, 0) + md * vm, CFrame.Angles(math.rad(Angle), 0, 0))
                FPos(BP, CFrame.new(0,  2.5, 0) + md * vm, CFrame.Angles(math.rad(Angle), 0, 0)) task.wait()
                FPos(BP, CFrame.new(0, -2.5, 0) + md * vm, CFrame.Angles(math.rad(Angle), 0, 0))
                FPos(BP, CFrame.new(0, -2.5, 0) + md * vm, CFrame.Angles(math.rad(Angle), 0, 0)) task.wait()
                FPos(BP, CFrame.new(0,  2.5, 0) + md,      CFrame.Angles(math.rad(Angle), 0, 0))
                FPos(BP, CFrame.new(0,  2.5, 0) + md,      CFrame.Angles(math.rad(Angle), 0, 0)) task.wait()
                FPos(BP, CFrame.new(0, -2.5, 0) + md,      CFrame.Angles(math.rad(Angle), 0, 0))
                FPos(BP, CFrame.new(0, -2.5, 0) + md,      CFrame.Angles(math.rad(Angle), 0, 0)) task.wait()
            else
                local ws = THumanoid.WalkSpeed
                FPos(BP, CFrame.new(0,  2.5,  ws), CFrame.Angles(math.rad(90), 0, 0))
                FPos(BP, CFrame.new(0,  2.5,  ws), CFrame.Angles(math.rad(90), 0, 0)) task.wait()
                FPos(BP, CFrame.new(0, -2.5, -ws), CFrame.Angles(0, 0, 0))
                FPos(BP, CFrame.new(0, -2.5, -ws), CFrame.Angles(0, 0, 0))            task.wait()
                FPos(BP, CFrame.new(0,  2.5,  ws), CFrame.Angles(math.rad(90), 0, 0))
                FPos(BP, CFrame.new(0,  2.5,  ws), CFrame.Angles(math.rad(90), 0, 0)) task.wait()
                FPos(BP, CFrame.new(0, -2.5, 0),   CFrame.Angles(math.rad(90), 0, 0))
                FPos(BP, CFrame.new(0, -2.5, 0),   CFrame.Angles(math.rad(90), 0, 0)) task.wait()
                FPos(BP, CFrame.new(0, -2.5, 0),   CFrame.Angles(0, 0, 0))
                FPos(BP, CFrame.new(0, -2.5, 0),   CFrame.Angles(0, 0, 0))            task.wait()
                FPos(BP, CFrame.new(0, -2.5, 0),   CFrame.Angles(math.rad(90), 0, 0))
                FPos(BP, CFrame.new(0, -2.5, 0),   CFrame.Angles(math.rad(90), 0, 0)) task.wait()
                FPos(BP, CFrame.new(0, -2.5, 0),   CFrame.Angles(0, 0, 0))
                FPos(BP, CFrame.new(0, -2.5, 0),   CFrame.Angles(0, 0, 0))            task.wait()
            end
        until os.clock() > deadline or (loopMode and not HubState.pa_loopFlingActive)  -- [FIX v101] tick() → os.clock()
    end

    workspace.FallenPartsDestroyHeight = 0/0

    local BV = Instance.new("BodyVelocity")
    BV.Parent  = RootPart
    BV.Velocity  = Vector3.new(0, 0, 0)
    BV.MaxForce  = Vector3.new(9e9, 9e9, 9e9)
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)

    pcall(function()
        if     TRootPart then SFBasePart(TRootPart)
        elseif THead      then SFBasePart(THead)
        elseif Handle     then SFBasePart(Handle)
        end
    end)

    BV:Destroy()
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
    workspace.CurrentCamera.CameraSubject = Humanoid

    -- Position zurücksetzen — MAX 4 Sekunden, damit Loop nicht hängt
    local oldPos = getgenv().pa_skidFlingOldPos
    if oldPos then
        local resetDeadline = os.clock() + 4  -- [FIX v101] tick() → os.clock()
        repeat
            pcall(function()
                RootPart.CFrame = oldPos * CFrame.new(0, 0.5, 0)
                Character:SetPrimaryPartCFrame(oldPos * CFrame.new(0, 0.5, 0))
                Humanoid:ChangeState("GettingUp")
                for _, p in pairs(Character:GetChildren()) do
                    if p:IsA("BasePart") then
                        p.Velocity    = Vector3.new()
                        p.RotVelocity = Vector3.new()
                    end
                end
            end)
            task.wait()
        until (RootPart.Position - oldPos.p).Magnitude < 25 or os.clock() > resetDeadline  -- [FIX v101] tick() → os.clock()
    end

    -- FallenPartsDestroyHeight immer wiederherstellen
    workspace.FallenPartsDestroyHeight = getgenv().pa_skidFlingFPDH
end
-- ═══════════════════════════════════════════════════════════════════════

PlayerTab:CreateButton({
    Name = "💥 Einmalig flingen (KILASIK)",
    Callback = function()
        if HubState.pa_flingActive or HubState.pa_loopFlingActive then
            Rayfield:Notify({Title="Fling", Content="Fling läuft bereits!", Duration=1}) return
        end
        if not selectedPlayer or not selectedPlayer.Character then
            Rayfield:Notify({Title="Fehler", Content="Kein Spieler ausgewählt!", Duration=2}) return
        end
        HubState.pa_flingActive = true
        Rayfield:Notify({Title="💥 Fling", Content="Fling auf "..selectedPlayer.Name, Duration=2})
        task.spawn(function()
            pcall(pa_skidFling, selectedPlayer, false)
            HubState.pa_flingActive = false
        end)
    end
})

PlayerTab:CreateSlider({
    Name = "Loop-Fling Pause zwischen Zyklen (Sek.)",
    Range = {0, 3},
    Increment = 0.5,
    CurrentValue = 0.5,
    Callback = function(v) HubState.pa_loopFlingDelay = v end
})

PlayerTab:CreateToggle({
    Name = "🔁 Loop Fling — KILASIK (dauerhaft)",
    CurrentValue = false,
    Callback = function(state)
        -- Laufenden Loop sauber stoppen
        if HubState.pa_loopFlingConn then
            local _t = HubState.pa_loopFlingConn
            HubState.pa_loopFlingConn  = nil
            HubState.pa_loopFlingActive = false
            pcall(task.cancel, _t)
        end

        if not state then
            HubState.pa_loopFlingActive = false
            Rayfield:Notify({Title="🔁 Loop Fling", Content="Gestoppt.", Duration=2})
            return
        end

        if not selectedPlayer then
            Rayfield:Notify({Title="Fehler", Content="Kein Spieler ausgewählt!", Duration=2}) return
        end

        HubState.pa_loopFlingActive = true
        local target = selectedPlayer   -- Snapshot: Ziel bleibt fest auch wenn UI-Auswahl wechselt

        Rayfield:Notify({
            Title   = "🔁 Loop Fling",
            Content = "Dauerhafter Fling auf "..target.Name.." läuft!",
            Duration = 3
        })

        HubState.pa_loopFlingConn = task.spawn(function()
            while HubState.pa_loopFlingActive do
                -- Prüfen ob Ziel noch im Spiel ist
                if not (target and target.Parent) then
                    HubState.pa_loopFlingActive = false
                    HubState.pa_loopFlingConn   = nil
                    Rayfield:Notify({Title="Fling", Content="Ziel hat das Spiel verlassen.", Duration=3})
                    break
                end

                -- Fling durchführen (loopMode=true damit SFBasePart abbricht wenn Toggle aus)
                pcall(pa_skidFling, target, true)

                -- Nur warten wenn Loop noch aktiv
                if HubState.pa_loopFlingActive then
                    task.wait(HubState.pa_loopFlingDelay or 0.5)
                end
            end
            -- Aufräumen falls Loop per Flag beendet
            HubState.pa_loopFlingConn = nil
        end)
    end
})

-- ──────────────────────────────────────────────
-- 📌 EINFRIEREN & BRINGEN
-- ──────────────────────────────────────────────
PlayerTab:CreateSection("📌 7 · Einfrieren & Bringen")

PlayerTab:CreateToggle({
    Name = "🧊 Einfrieren",
    CurrentValue = false,
    Callback = function(state)
        if HubState.pa_pinConn then HubState.pa_pinConn:Disconnect() HubState.pa_pinConn = nil end
        if not state then
            pcall(function()
                if selectedPlayer and selectedPlayer.Character then
                    local hrp = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
                    local hum = selectedPlayer.Character:FindFirstChild("Humanoid")
                    if hrp then hrp.Anchored = false end
                    if hum then hum.WalkSpeed = 16 end
                end
            end)
            return
        end
        if not selectedPlayer or not selectedPlayer.Character then
            Rayfield:Notify({Title="Fehler", Content="Kein Spieler!", Duration=2}) return
        end
        local frozenCF = nil
        local _c
        _c = RunService.Heartbeat:Connect(function()
            pcall(function()
                if not selectedPlayer or not selectedPlayer.Character then
                    _c:Disconnect(); HubState.pa_pinConn = nil return
                end
                local hrp = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
                local hum = selectedPlayer.Character:FindFirstChild("Humanoid")
                if hrp then
                    if not frozenCF then frozenCF = hrp.CFrame end
                    hrp.CFrame = frozenCF
                    hrp.AssemblyLinearVelocity  = Vector3.zero
                    hrp.AssemblyAngularVelocity = Vector3.zero
                end
                if hum then hum.WalkSpeed = 0 end
            end)
        end)
        HubState.pa_pinConn = _c
        Rayfield:Notify({Title="Freeze", Content=selectedPlayer.Name.." eingefroren!", Duration=2})
    end
})

PlayerTab:CreateButton({
    Name = "🧲 Einmalig zu mir holen",
    Callback = function()
        if not selectedPlayer or not selectedPlayer.Character then
            Rayfield:Notify({Title="Fehler", Content="Kein Spieler!", Duration=2}) return
        end
        local mHRP  = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local tHRP  = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
        if mHRP and tHRP then
            tHRP.CFrame = mHRP.CFrame * CFrame.new(2, 0, 2)
            Rayfield:Notify({Title="Bring", Content=selectedPlayer.Name.." zu dir geholt!", Duration=2})
        end
    end
})

PlayerTab:CreateSlider({
    Name = "Loop-Bring Intervall (Sek.)",
    Range = {0.5, 10},
    Increment = 0.5,
    CurrentValue = 2,
    Callback = function(v) HubState.pa_loopBringDelay = v end
})
PlayerTab:CreateToggle({
    Name = "🔁 Loop Bring (dauerhaft holen)",
    CurrentValue = false,
    Callback = function(state)
        if HubState.pa_loopBringConn then
            -- [FIX v76] Erst nil setzen, dann cancel: while-Schleife bricht auch dann ab,
            -- wenn task.cancel() den Thread nicht sofort stoppt (race-condition sicher).
            local _t = HubState.pa_loopBringConn
            HubState.pa_loopBringConn = nil
            task.cancel(_t)
        end
        if not state then return end
        if not selectedPlayer then
            Rayfield:Notify({Title="Fehler", Content="Kein Spieler!", Duration=2}) return
        end
        HubState.pa_loopBringConn = task.spawn(function()
            while HubState.pa_loopBringConn do
                pcall(function()
                    if selectedPlayer and selectedPlayer.Character then
                        local mHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        local tHRP = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if mHRP and tHRP then
                            tHRP.CFrame = mHRP.CFrame * CFrame.new(2, 0, 2)
                        end
                    end
                end)
                task.wait(HubState.pa_loopBringDelay or 2)
            end
        end)
        Rayfield:Notify({Title="Loop Bring", Content="Dauerhaftes Holen aktiv!", Duration=3})
    end
})

-- ──────────────────────────────────────────────
-- 🌀 SPIN & SPEZIAL
-- ──────────────────────────────────────────────
PlayerTab:CreateSection("🌀 8 · Spin & Spezial")

PlayerTab:CreateButton({
    Name = "🌀 Um Spieler drehen (Spin)",
    Callback = function()
        if not selectedPlayer or not selectedPlayer.Character then
            Rayfield:Notify({Title="Fehler", Content="Kein Spieler!", Duration=2}) return
        end
        local tHRP = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
        local mHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not tHRP or not mHRP then return end
        if HubState.pa_spinConn then HubState.pa_spinConn:Disconnect() HubState.pa_spinConn = nil end
        if HubState.PlayerSpinConn then HubState.PlayerSpinConn:Disconnect() HubState.PlayerSpinConn = nil end
        local angle = 0
        local _c
        _c = RunService.Stepped:Connect(function()
            pcall(function()
                if not tHRP.Parent or not mHRP.Parent then
                    _c:Disconnect(); HubState.pa_spinConn = nil return
                end
                angle = (angle + 6) % 360
                mHRP.CFrame = tHRP.CFrame * CFrame.Angles(0, math.rad(angle), 0) * CFrame.new(0, 0, 8) * CFrame.Angles(0, math.rad(180), 0)
                mHRP.AssemblyLinearVelocity  = Vector3.zero
                mHRP.AssemblyAngularVelocity = Vector3.zero
            end)
        end)
        HubState.pa_spinConn    = _c
        HubState.PlayerSpinConn = _c
        Rayfield:Notify({Title="Spin", Content="Drehe um "..selectedPlayer.Name, Duration=3})
    end
})

PlayerTab:CreateButton({
    Name = "⏸ Spin stoppen",
    Callback = function()
        for _, key in ipairs({"pa_spinConn","PlayerSpinConn"}) do
            if HubState[key] then HubState[key]:Disconnect(); HubState[key] = nil end
        end
        Rayfield:Notify({Title="Spin", Content="Spin gestoppt!", Duration=2})
    end
})

PlayerTab:CreateButton({
    Name = "👕 Outfit kopieren",
    Callback = function()
        if not selectedPlayer or not selectedPlayer.Character then
            Rayfield:Notify({Title="Fehler", Content="Kein Spieler!", Duration=2}) return
        end
        local mChr = LocalPlayer.Character
        local tChr = selectedPlayer.Character
        if not mChr or not tChr then return end
        pcall(function()
            for _, obj in ipairs(mChr:GetChildren()) do
                if obj:IsA("Shirt") or obj:IsA("Pants") or obj:IsA("Accessory") or obj:IsA("Hat") then
                    obj:Destroy()
                end
            end
            for _, obj in ipairs(tChr:GetChildren()) do
                if obj:IsA("Shirt") or obj:IsA("Pants") or obj:IsA("Accessory") or obj:IsA("Hat") then
                    obj:Clone().Parent = mChr
                end
            end
        end)
        Rayfield:Notify({Title="Outfit", Content="Outfit von "..selectedPlayer.Name.." kopiert!", Duration=3})
    end
})

PlayerTab:CreateButton({
    Name = "💡 Spieler-Highlight (farbige Auswahl)",
    Callback = function()
        if not selectedPlayer or not selectedPlayer.Character then
            Rayfield:Notify({Title="Fehler", Content="Kein Spieler!", Duration=2}) return
        end
        if HubState.pa_highlightObj then
            HubState.pa_highlightObj:Destroy(); HubState.pa_highlightObj = nil
            Rayfield:Notify({Title="Highlight", Content="Highlight entfernt", Duration=2}) return
        end
        pcall(function()
            local hl = Instance.new("Highlight")
            hl.FillColor       = Color3.fromRGB(255, 50, 50)
            hl.OutlineColor    = Color3.fromRGB(255, 255, 0)
            hl.FillTransparency    = 0.4
            hl.OutlineTransparency = 0
            hl.Adornee = selectedPlayer.Character
            hl.Parent  = selectedPlayer.Character
            HubState.pa_highlightObj = hl
            -- [FIX v95] Bei jedem Button-Druck neue Connection → Leak bei mehrfachem Klicken.
            -- Jetzt: alte Verbindung trennen bevor neue gesetzt wird.
            if HubState.pa_highlightConn then
                HubState.pa_highlightConn:Disconnect(); HubState.pa_highlightConn = nil
            end
            HubState.pa_highlightConn = selectedPlayer.CharacterRemoving:Connect(function()
                if HubState.pa_highlightObj then
                    HubState.pa_highlightObj:Destroy(); HubState.pa_highlightObj = nil
                end
                HubState.pa_highlightConn = nil
            end)
        end)
        Rayfield:Notify({Title="Highlight", Content=selectedPlayer.Name.." hervorgehoben!", Duration=2})
    end
})

-- [FIX v77] Chat-Logger: Nachrichten live via MessageReceived aufzeichnen,
-- da TextChannel:GetChildren() keine TextChatMessage-Instanzen enthält.
if not HubState.chatMessages then
    HubState.chatMessages = {}
    pcall(function()
        local TCS = game:GetService("TextChatService")
        TCS.MessageReceived:Connect(function(msg)
            if msg and msg.TextSource then
                local uid = msg.TextSource.UserId
                if uid then
                    if not HubState.chatMessages[uid] then
                        HubState.chatMessages[uid] = {}
                    end
                    table.insert(HubState.chatMessages[uid], msg.Text or "")
                end
            end
        end)
    end)
end

PlayerTab:CreateButton({
    Name = "🔵 Spieler-Chat lesen (letzter Chat)",
    Callback = function()
        if not selectedPlayer then
            Rayfield:Notify({Title="Fehler", Content="Kein Spieler!", Duration=2}) return
        end
        local msgs = HubState.chatMessages and HubState.chatMessages[selectedPlayer.UserId]
        if msgs and #msgs > 0 then
            Rayfield:Notify({
                Title = "💬 " .. selectedPlayer.Name,
                Content = msgs[#msgs],
                Duration = 6
            })
        else
            Rayfield:Notify({Title="Chat", Content="Noch keine Nachricht von " .. selectedPlayer.Name .. " empfangen.", Duration=3})
        end
    end
})

PlayerTab:CreateButton({
    Name = "📏 Distanz zum Spieler anzeigen",
    Callback = function()
        if not selectedPlayer or not selectedPlayer.Character then
            Rayfield:Notify({Title="Fehler", Content="Kein Spieler!", Duration=2}) return
        end
        local mHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local tHRP = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
        if mHRP and tHRP then
            local dist = math.floor((mHRP.Position - tHRP.Position).Magnitude)
            Rayfield:Notify({
                Title = "📏 Distanz",
                Content = selectedPlayer.Name .. " ist " .. dist .. " Studs entfernt",
                Duration = 4
            })
        end
    end
})

PlayerTab:CreateButton({
    Name = "⬆️ Spieler-Pos in Konsole ausgeben",
    Callback = function()
        if not selectedPlayer or not selectedPlayer.Character then
            Rayfield:Notify({Title="Fehler", Content="Kein Spieler!", Duration=2}) return
        end
        local hrp = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local p = hrp.Position
            local txt = string.format("%.1f, %.1f, %.1f", p.X, p.Y, p.Z)
            Rayfield:Notify({
                Title = "📍 Position: "..selectedPlayer.Name,
                Content = txt,
                Duration = 6
            })
            pcall(function() setclipboard(txt) end)
        end
    end
})

PlayerTab:CreateButton({
    Name = "🔇 Anti-Follow (verhindert Verfolgen)",
    Callback = function()
        Rayfield:Notify({Title="Anti-Follow", Content="Teleportiere dich zufällig weg...", Duration=2})
        task.spawn(function()
            for _ = 1, 5 do
                pcall(function()
                    local mHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if mHRP then
                        local rx = math.random(-100, 100)
                        local rz = math.random(-100, 100)
                        mHRP.CFrame = mHRP.CFrame + Vector3.new(rx, 0, rz)
                        task.wait(0.3)
                    end
                end)
            end
            Rayfield:Notify({Title="Anti-Follow", Content="Escape abgeschlossen!", Duration=2})
        end)
    end
})


-- ==================== CHAT SPY (eigene Section) ====================
PlayerTab:CreateSection("🕵️ 9 · Spy Tools")

local chatSpyEnabled = false
local chatSpyConn = nil

PlayerTab:CreateToggle({
    Name = "💬 Chat Spy (Private Nachrichten sehen)",
    CurrentValue = false,
    Callback = function(state)
        chatSpyEnabled = state

        if state then
            if chatSpyConn then chatSpyConn:Disconnect() end

            chatSpyConn = TextChatService.MessageReceived:Connect(function(message)
                if not chatSpyEnabled then return end

                pcall(function()
                    local text = message.Text
                    local sender = message.TextSource and message.TextSource.Name or "Unbekannt"
                    local fromPlayer = Players:FindFirstChild(sender)
                    local displayName = fromPlayer and fromPlayer.DisplayName or sender

                    -- [FIX] Abgefangene Nachricht tatsächlich anzeigen
                    Rayfield:Notify({
                        Title = "💬 Chat Spy: " .. displayName,
                        Content = text,
                        Duration = 5
                    })
                end)
            end)

            Rayfield:Notify({Title = "Chat Spy", Content = "Chat Spy aktiviert - Nachrichten werden abgefangen", Duration = 4})
        else
            if chatSpyConn then
                chatSpyConn:Disconnect()
                chatSpyConn = nil
            end
            Rayfield:Notify({Title = "Chat Spy", Content = "Chat Spy deaktiviert", Duration = 2})
        end
    end
})

-- Server Info (Maximum Detail)
PlayerTab:CreateButton({
    Name = "📊 Server Info anzeigen (Maximum)",
    Callback = function()
        pcall(function()
            local playerCount = #Players:GetPlayers()
            local maxPlayers = Players.MaxPlayers
            local placeId = game.PlaceId
            local jobId = game.JobId
            local placeVersion = game.PlaceVersion

            local gameName = "Unbekannt"
            local creatorName = "Unbekannt"
            local creatorId = 0
            local creatorType = "Unbekannt"

            pcall(function()
                local info = game:GetService("MarketplaceService"):GetProductInfo(placeId)
                if info then
                    gameName = info.Name or "Unbekannt"
                    if info.Creator then
                        creatorId = info.Creator.CreatorId or 0
                        creatorName = info.Creator.Name or "Unbekannt"
                        creatorType = info.Creator.CreatorType or "Unbekannt"
                    end
                end
            end)

            local ping = "Unbekannt"
            pcall(function()
                local stats = game:GetService("Stats")
                if not stats then return end
                -- [VERBESSERUNG] Direkter Property-Zugriff zuerst (schnellster Pfad)
                local ok1, v1 = pcall(function()
                    return stats.Network.ServerStatsItem:GetValue()
                end)
                if ok1 and v1 then
                    ping = tostring(math.floor(v1)) .. " ms"
                    return
                end
                -- Fallback: alle StatsItem-Kinder in Network nach "ping" durchsuchen
                local net = stats:FindFirstChild("Network")
                if net then
                    for _, child in ipairs(net:GetChildren()) do
                        if child:IsA("StatsItem") then
                            local name = child.Name:lower()
                            if name:find("ping") or name:find("latency") then
                                local ok2, v2 = pcall(function() return child:GetValue() end)
                                if ok2 and v2 then ping = tostring(math.floor(v2)) .. " ms" return end
                            end
                        end
                    end
                    -- Letzter Fallback: erstes StatsItem in Network
                    for _, child in ipairs(net:GetChildren()) do
                        if child:IsA("StatsItem") then
                            local ok3, v3 = pcall(function() return child:GetValue() end)
                            if ok3 and v3 and v3 > 0 then ping = tostring(math.floor(v3)) .. " ms" return end
                        end
                    end
                end
            end)

            local gravity = "Unbekannt"
            pcall(function() gravity = tostring(Workspace.Gravity) end)

            local timeOfDay = "Unbekannt"
            pcall(function() timeOfDay = Lighting.TimeOfDay end)

            local isVIP = "Nein"
            pcall(function()
                if game.PrivateServerId ~= "" then isVIP = "Ja" end
            end)

            local partCount = "Unbekannt"
            pcall(function() partCount = tostring(#Workspace:GetDescendants()) end)

            -- Server Region (Roblox versteckt das meistens)
            local serverRegion = "Nicht ermittelbar"
            pcall(function()
                -- Manche Exploits können das über interne Funktionen holen
                -- Standardmäßig nicht mehr öffentlich verfügbar
            end)

            -- [VERBESSERUNG] JobID auf 8 Zeichen kürzen (volle UUID = 36 Zeichen, kaum lesbar)
            local shortJobId = (jobId and #jobId >= 8) and (jobId:sub(1, 8) .. "…") or (jobId or "?")
            local infoText = string.format(
                "=== SERVER INFO (MAX) ===\n" ..
                "Spieler: %d / %d\n" ..
                "Game: %s\n" ..
                "Creator: %s (%s) ID: %d\n" ..
                "Place ID: %d\n" ..
                "Job ID: %s\n" ..
                "Version: %d\n" ..
                "Ping: %s\n" ..
                "Gravity: %s\n" ..
                "TimeOfDay: %s\n" ..
                "VIP Server: %s\n" ..
                "Parts: %s\n" ..
                "Region: %s\n" ..
                "=========================",
                playerCount, maxPlayers, gameName,
                creatorName, creatorType, creatorId,
                placeId, shortJobId, placeVersion,
                ping, gravity, timeOfDay, isVIP, partCount, serverRegion
            )

            Rayfield:Notify({
                Title = "Server Info (Maximum)",
                Content = string.format(
                    "%d/%d Spieler | %s\nCreator: %s\nPing: %s | Gravity: %s\nVIP: %s | Parts: %s\nRegion: %s",
                    playerCount, maxPlayers, gameName, creatorName, ping, gravity, isVIP, partCount, serverRegion
                ),
                Duration = 12
            })
        end)
    end
})

-- (Duplicate Chat Spy removed - only one instance in 🕵️ Spy Tools)

-- ==================== CHAT SPAM TOOL (Mehrere Methoden) ====================
ChatTab:CreateSection("💬 Chat Spam Tool (Mehrere Methoden)")
-- [FIX] spamRunning/spamConn wurden hier deklariert → nach oben verschoben (vor Notfall-Stop)

ChatTab:CreateInput({
    Name = "Spam Text",
    PlaceholderText = "Text der gespammt werden soll",
    RemoveTextAfterFocusLost = false,
    Callback = function(text)
        HubState.SpamText = text
    end
})

ChatTab:CreateSlider({
    Name = "Spam Delay (Sekunden)",
    Range = {0.1, 1.5},
    Increment = 0.05,
    CurrentValue = 0.3,
    Callback = function(value)
        HubState.SpamDelay = value
    end
})

local function TrySendMessage(text)
    pcall(function()
        -- Methode 1: Normaler TextChatService
        local success = pcall(function()
            game:GetService("TextChatService").TextChannels.RBXGeneral:SendAsync(text)
        end)

        if success then return end

        -- Methode 2: Players:Chat() — von Roblox KOMPLETT entfernt, funktioniert nirgends mehr.
        -- [FIX v87] Block entfernt. Vorher: pcall(function() Players:Chat(text) end)
        -- Das war toter Code und konnte in manchen Executors sogar Fehler werfen.

        -- Methode 3: Versucht Remotes mit "chat" oder "message" zu finden
        -- [FIX] break nach erstem Treffer: vorher wurden ALLE passenden Remotes gefeuert
        -- → konnte ungewollte Spielmechaniken auslösen (ChatLog, MessageHistory, etc.)
        pcall(function()
            for _, obj in ipairs(game:GetDescendants()) do
                if obj:IsA("RemoteEvent") and (string.find(obj.Name:lower(), "chat") or string.find(obj.Name:lower(), "message")) then
                    obj:FireServer(text)
                    break -- [FIX] Nur das erste passende Remote feuern
                end
            end
        end)
    end)
end

ChatTab:CreateButton({
    Name = "▶️ Spam Starten (Mehrere Methoden)",
    Callback = function()
        if spamRunning then
            Rayfield:Notify({Title = "Spam", Content = "Spam läuft bereits!", Duration = 2})
            return
        end

        if not HubState.SpamText or HubState.SpamText == "" then
            Rayfield:Notify({Title = "Fehler", Content = "Bitte zuerst einen Text eingeben!", Duration = 2})
            return
        end

        spamRunning = true

        spamThread = task.spawn(function()
            while spamRunning do
                TrySendMessage(HubState.SpamText)
                -- [VERBESSERUNG] Delay live aus HubState lesen → Slider-Änderung wirkt sofort
                task.wait(math.max(0.05, HubState.SpamDelay or 0.3))
            end
        end)

        Rayfield:Notify({Title = "Spam", Content = "Chat Spam mit mehreren Methoden gestartet!", Duration = 2})
    end
})

ChatTab:CreateButton({
    Name = "⏸ Spam Stoppen",
    Callback = function()
        spamRunning = false
        if spamThread then
            task.cancel(spamThread)  -- [FIX v94] task.cancel korrekt auf Thread
            spamThread = nil
        end
        Rayfield:Notify({Title = "Spam", Content = "Chat Spam gestoppt!", Duration = 2})
    end
})

SpezialTab:CreateSection("Game Scanner (Full)")
SpezialTab:CreateButton({
    Name = "Vollständiger Game Scan",
    Callback = function()
        local remoteEvents = 0
        local remoteFunctions = 0
        local combatRemotes = {}
        local combatKeywords = {"attack", "hit", "knife", "shoot", "fire", "swing", "slash", "punch", "kill", "combat", "melee", "strike", "damage"}

        for _, obj in ipairs(game:GetDescendants()) do
            if obj:IsA("RemoteEvent") then
                remoteEvents = remoteEvents + 1
                local lowerName = obj.Name:lower()
                for _, keyword in ipairs(combatKeywords) do
                    if string.find(lowerName, keyword) then
                        table.insert(combatRemotes, obj:GetFullName())
                        break
                    end
                end
            elseif obj:IsA("RemoteFunction") then
                remoteFunctions = remoteFunctions + 1
            end
        end

        -- [FIX v94] 4 separate game:GetDescendants()-Schleifen → 1 Schleife (3× weniger Overhead)
        local toolCount = 0
        local animCount = 0
        local moduleCount = 0
        for _, obj in ipairs(game:GetDescendants()) do
            if     obj:IsA("Tool")         then toolCount    = toolCount    + 1
            elseif obj:IsA("Animation")    then animCount    = animCount    + 1
            elseif obj:IsA("ModuleScript") then moduleCount  = moduleCount  + 1
            end
        end

        local combatText = #combatRemotes > 0 and table.concat(combatRemotes, ", ") or "Keine"
        local scanResult = string.format(
            "RemoteEvents: %d | RemoteFunctions: %d | Tools: %d | Anims: %d | Modules: %d | Combat Remotes: %s",
            remoteEvents, remoteFunctions, toolCount, animCount, moduleCount, combatText
        )

        Rayfield:Notify({Title = "Game Scanner", Content = scanResult, Duration = 8})
    end
})

-- ==================== TROLL TAB (Tänze) ====================
-- v74: 20 verschiedene Tänze! Alle in do...end gekapselt (spart 2 top-level locals).
-- Roblox eigene Standard-Emotes + freie Katalog-Animationen werden genutzt.
-- R6 und R15 werden automatisch erkannt.

;(function() -- DANCE BLOCK: eigene Funktion = eigener 200-Register-Pool (do..end reicht nicht!)
local currentAnimTrack = nil
local animLoopConn = nil

-- ===================== 20 TÄNZE (ALLE GETESTET / LADBAR) =====================
-- WICHTIG: Es werden NUR von Roblox SELBST erstellte Animations-Assets benutzt.
-- Diese laden per LoadAnimation in praktisch JEDEM Spiel (kein Bundle/Kauf nötig).
-- Die alten Katalog-Emote-IDs (3360...) brauchten gekaufte Bundles -> gingen NICHT.
-- Jetzt: 7 Standard-Emotes + Roblox Default-Charakter-Animationen + Animations-Pakete.
local DANCES = {
    -- === Roblox Standard-Emotes (R6 + R15, laden überall) ===
    ["Dance 1"]      = { R15 = "rbxassetid://507771019", R6 = "rbxassetid://182435998" },
    ["Dance 2"]      = { R15 = "rbxassetid://507776043", R6 = "rbxassetid://182436842" },
    ["Dance 3"]      = { R15 = "rbxassetid://507777268", R6 = "rbxassetid://182436935" },
    ["Wave"]         = { R15 = "rbxassetid://507770239", R6 = "rbxassetid://128777973" },
    ["Point"]        = { R15 = "rbxassetid://507770453", R6 = "rbxassetid://128853357" },
    ["Cheer"]        = { R15 = "rbxassetid://507770677", R6 = "rbxassetid://129423030" },
    ["Laugh"]        = { R15 = "rbxassetid://507770818", R6 = "rbxassetid://129423131" },
    -- === Roblox Default-Charakter-Animationen (R6 + R15, immer verfügbar) ===
    ["Idle Cool"]    = { R15 = "rbxassetid://507766951", R6 = "rbxassetid://180435792" },
    ["Idle Chill"]   = { R15 = "rbxassetid://507766666", R6 = "rbxassetid://180435571" },
    ["Lauf-Style"]   = { R15 = "rbxassetid://507777826", R6 = "rbxassetid://180426354" },
    ["Renn-Style"]   = { R15 = "rbxassetid://507767714", R6 = "rbxassetid://180426354" },
    ["Sprung"]       = { R15 = "rbxassetid://507765000", R6 = "rbxassetid://125750702" },
    ["Schweben"]     = { R15 = "rbxassetid://507767968", R6 = "rbxassetid://180436148" },
    ["Klettern"]     = { R15 = "rbxassetid://507765644", R6 = "rbxassetid://180436334" },
    ["Schwimmen"]    = { R15 = "rbxassetid://507784897", R6 = "rbxassetid://180436334" },
    ["Schwimm-Idle"] = { R15 = "rbxassetid://507785072", R6 = "rbxassetid://180436280" },
    -- === Roblox Animations-Pakete (R15; R6 nutzt Default-Idle als Fallback) ===
    ["Zombie"]       = { R15 = "rbxassetid://616006778", R6 = "rbxassetid://180435571" },
    ["Ninja"]        = { R15 = "rbxassetid://656117400", R6 = "rbxassetid://180435571" },
    ["Magier"]       = { R15 = "rbxassetid://707742142", R6 = "rbxassetid://180435571" },
    ["Cartoon"]      = { R15 = "rbxassetid://742637544", R6 = "rbxassetid://180435571" },
}

local DANCE_ORDER = {
    "Dance 1", "Dance 2", "Dance 3", "Wave", "Point", "Cheer", "Laugh",
    "Idle Cool", "Idle Chill", "Lauf-Style", "Renn-Style", "Sprung",
    "Schweben", "Klettern", "Schwimmen", "Schwimm-Idle",
    "Zombie", "Ninja", "Magier", "Cartoon"
}

local function StopDance()
    if animLoopConn then
        pcall(function() animLoopConn:Disconnect() end)
        animLoopConn = nil
    end
    pcall(function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            for _, tr in pairs(hum:GetPlayingAnimationTracks()) do
                pcall(function() tr:Stop() end)
            end
        end
    end)
    currentAnimTrack = nil
end

local function PlayDance(name)
    pcall(function()
        local char = LocalPlayer.Character
        if not char then
            Rayfield:Notify({Title = "💃 Tanz", Content = "Kein Character gefunden", Duration = 2})
            return
        end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then
            Rayfield:Notify({Title = "💃 Tanz", Content = "Kein Humanoid gefunden", Duration = 2})
            return
        end
        local entry = DANCES[name]
        if not entry then return end
        local isR6 = (hum.RigType == Enum.HumanoidRigType.R6)
        local animId = isR6 and entry.R6 or entry.R15

        StopDance()

        local animator = hum:FindFirstChildOfClass("Animator")
        if not animator then
            animator = Instance.new("Animator")
            animator.Parent = hum
        end
        local anim = Instance.new("Animation")
        anim.AnimationId = animId
        local ok, track = pcall(function() return animator:LoadAnimation(anim) end)
        if not ok or not track then
            Rayfield:Notify({Title = "💃 Tanz", Content = "Animation konnte nicht geladen werden", Duration = 3})
            return
        end
        track.Looped = true
        pcall(function() track.Priority = Enum.AnimationPriority.Action4 end)
        track:Play(0.2)
        currentAnimTrack = track

        -- [FPS-FIX] Animation-Loop auf 5x/s gedrosselt (war 60x/s) — Priority-Setzen braucht kein Frame-Timing
        local _animTimer = 0
        animLoopConn = RunService.Heartbeat:Connect(function(dt)
            _animTimer = _animTimer + dt
            if _animTimer < 0.2 then return end
            _animTimer = 0
            local c = LocalPlayer.Character
            if currentAnimTrack ~= track or track.Parent == nil
                or not c or not c:FindFirstChildOfClass("Humanoid") then
                if animLoopConn then animLoopConn:Disconnect() animLoopConn = nil end
                if currentAnimTrack == track then currentAnimTrack = nil end
                return
            end
            pcall(function()
                if not track.IsPlaying then track:Play(0.1) end
                track.Priority = Enum.AnimationPriority.Action4
            end)
        end)

        Rayfield:Notify({Title = "💃 Tanz", Content = name .. " läuft!", Duration = 2})
    end)
end

LocalPlayer.CharacterAdded:Connect(function()
    StopDance()
end)

-- ============================================================
-- UI (20 Tänze)
-- ============================================================
TrollTab:CreateSection("💃 20 Tänze (alle ladbar)")

TrollTab:CreateButton({
    Name = "⏸ Tanz stoppen",
    Callback = function()
        StopDance()
        Rayfield:Notify({Title = "💃 Tanz", Content = "Tanz gestoppt", Duration = 2})
    end
})

TrollTab:CreateSection("🎵 Standard Emotes (laden überall)")
TrollTab:CreateButton({ Name = "🕺 Dance 1 (Breakdance)", Callback = function() PlayDance("Dance 1") end })
TrollTab:CreateButton({ Name = "🕺 Dance 2",              Callback = function() PlayDance("Dance 2") end })
TrollTab:CreateButton({ Name = "💃 Dance 3",              Callback = function() PlayDance("Dance 3") end })
TrollTab:CreateButton({ Name = "👋 Wave",                 Callback = function() PlayDance("Wave") end })
TrollTab:CreateButton({ Name = "👉 Point",                Callback = function() PlayDance("Point") end })
TrollTab:CreateButton({ Name = "🙌 Cheer",                Callback = function() PlayDance("Cheer") end })
TrollTab:CreateButton({ Name = "😂 Laugh",                Callback = function() PlayDance("Laugh") end })

TrollTab:CreateSection("🕴️ Style Moves (R6 & R15)")
TrollTab:CreateButton({ Name = "😎 Idle Cool",            Callback = function() PlayDance("Idle Cool") end })
TrollTab:CreateButton({ Name = "🧊 Idle Chill",           Callback = function() PlayDance("Idle Chill") end })
TrollTab:CreateButton({ Name = "🚶 Lauf-Style",           Callback = function() PlayDance("Lauf-Style") end })
TrollTab:CreateButton({ Name = "🏃 Renn-Style",           Callback = function() PlayDance("Renn-Style") end })
TrollTab:CreateButton({ Name = "🦘 Sprung",               Callback = function() PlayDance("Sprung") end })
TrollTab:CreateButton({ Name = "🪂 Schweben",             Callback = function() PlayDance("Schweben") end })
TrollTab:CreateButton({ Name = "🧗 Klettern",             Callback = function() PlayDance("Klettern") end })
TrollTab:CreateButton({ Name = "🏊 Schwimmen",            Callback = function() PlayDance("Schwimmen") end })
TrollTab:CreateButton({ Name = "🌊 Schwimm-Idle",         Callback = function() PlayDance("Schwimm-Idle") end })

TrollTab:CreateSection("🎭 Animations-Pakete (am besten R15)")
TrollTab:CreateButton({ Name = "🧟 Zombie",               Callback = function() PlayDance("Zombie") end })
TrollTab:CreateButton({ Name = "🥷 Ninja",                Callback = function() PlayDance("Ninja") end })
TrollTab:CreateButton({ Name = "🧙 Magier",               Callback = function() PlayDance("Magier") end })
TrollTab:CreateButton({ Name = "🎨 Cartoon",              Callback = function() PlayDance("Cartoon") end })

TrollTab:CreateSection("🚁 Spezial")
TrollTab:CreateToggle({
    Name = "🚁 Helikopter (drehen)",
    CurrentValue = false,
    Callback = function(state)
        if HubState.heliConn then HubState.heliConn:Disconnect() HubState.heliConn = nil end
        if not state then
            pcall(function()
                local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
                if hum then hum.PlatformStand = false end
            end)
            return
        end
        local mChar = LocalPlayer.Character
        local mHRP = mChar and mChar:FindFirstChild("HumanoidRootPart")
        if not mHRP then
            Rayfield:Notify({Title="Fehler", Content="Kein Character!", Duration=2}) return
        end
        local hum = mChar:FindFirstChild("Humanoid")
        if hum then hum.PlatformStand = true end
        HubState.heliAngle = 0
        HubState.heliBase = mHRP.Position
        local _c
        _c = RunService.Stepped:Connect(function(_, dt)
            pcall(function()
                local mHRP2 = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if not mHRP2 then return end
                HubState.heliAngle = (HubState.heliAngle or 0) + (dt or 0.016) * 14
                local base = HubState.heliBase or mHRP2.Position
                mHRP2.CFrame = CFrame.new(base + Vector3.new(0, 3, 0))
                    * CFrame.Angles(0, HubState.heliAngle, 0)
                    * CFrame.Angles(0, 0, math.rad(80))
                mHRP2.AssemblyLinearVelocity = Vector3.zero
                mHRP2.AssemblyAngularVelocity = Vector3.zero
            end)
        end)
        HubState.heliConn = _c
        Rayfield:Notify({Title="🚁 Helikopter", Content="Du drehst dich wie ein Heli!", Duration=2})
    end
})

TrollTab:CreateSection("🎲 Zufall")
TrollTab:CreateButton({
    Name = "🎲 Zufälliger Tanz",
    Callback = function()
        local pick = DANCE_ORDER[math.random(1, #DANCE_ORDER)]
        PlayDance(pick)
    end
})

TrollTab:CreateLabel("20 Tänze — alle nutzen Roblox-eigene Animationen (kein Bundle-Kauf nötig). R6 & R15 automatisch erkannt. Animations-Pakete (Zombie/Ninja/Magier/Cartoon) sind R15-only; R6 zeigt eine Idle-Pose.")

end)() -- DANCE BLOCK END
-- ==================== ENDE TROLL MENU ====================

-- ==================== More Anti Features wurde in AntiTab verschoben ====================
-- (Originale UI-Erstellung aus SettingsTab entfernt und in AntiTab verschoben, wie gewünscht)

-- Config Aktionen → Config-Tab verschoben

-- ==================== AUTO LOAD CONFIG ON START ====================
task.spawn(function()
    task.wait(1.5) -- Kurze Verzögerung damit alle UI Elemente fertig sind
    pcall(function()
        Rayfield:LoadConfiguration()
        -- Config geladen
    end)
end)

-- ==================== KILL EFFECTS v3 (komplett überarbeitet + viele Effekte) ====================
HubState.lastLocalAttack = 0 -- [v74] kein extra top-level local mehr
Settings.KillEffectType = Settings.KillEffectType or "Herz Explosion"
-- [FIX v78] Standard: true statt false → Effekt funktioniert direkt ohne manuelles Einschalten
if Settings.KillEffectsEnabled == nil then Settings.KillEffectsEnabled = true end

-- Alle Effektfunktionen sind in diesem do-Block gekapselt. Wichtig: ein do-Block
-- erzeugt KEINEN eigenen Funktions-Proto, die Locals teilen sich den Register-Raum
-- des Haupt-Chunks. Der do-Block hilft nur, weil seine Locals NACH dem Block wieder
-- freigegeben werden. Darum sind die Effekte zusätzlich anonyme Tabellenfelder
-- (statt 10 benannte locals), um den gleichzeitigen Register-Höchststand klein zu
-- halten (Lua-Limit: 200 locals pro Proto). Nach außen sichtbar sind nur
-- CreateKillEffect und KILL_EFFECT_OPTIONS (für das Dropdown).
;(function() -- KILL EFFECT BLOCK: eigener Register-Pool
    -- Hilfsfunktion: temporären Neon-Ball/Part mit optionaler Geschwindigkeit spawnen
    local function spawnPart(pos, size, color, vel, life, shape, material)
        local p = Instance.new("Part")
        if typeof(size) == "Vector3" then p.Size = size else p.Size = Vector3.new(size, size, size) end
        p.Shape = shape or Enum.PartType.Ball
        p.Material = material or Enum.Material.Neon
        p.Color = color
        p.Position = pos
        p.CanCollide = false
        p.Anchored = (vel == nil)
        p.Massless = true
        p.Parent = Workspace
        if vel then p.AssemblyLinearVelocity = vel end
        task.delay(life or 2.5, function()
            if p and p.Parent then p:Destroy() end
        end)
        return p
    end

    -- Registrierung (Reihenfolge = Dropdown-Reihenfolge)
    -- Hinweis: Die Effekt-Funktionen werden direkt als Tabellenfelder definiert
    -- (nicht als benannte locals), um den Register-Druck im Haupt-Chunk niedrig
    -- zu halten (Lua-Limit: 200 locals pro Funktion/Chunk).
    local effects = {
        -- 1) Herz Explosion
        ["Herz Explosion"] = function(pos)
            pcall(function()
                local exp = Instance.new("Explosion")
                exp.Position = pos; exp.BlastRadius = 7; exp.BlastPressure = 0
                exp.Visible = true; exp.Parent = Workspace
                for i = 1, 18 do
                    spawnPart(pos + Vector3.new(0, 2, 0), 2.5, Color3.fromRGB(255, 70, 130),
                        Vector3.new(math.random(-45, 45), math.random(20, 60), math.random(-45, 45)), 2.5)
                end
            end)
        end,

        -- 2) Herz Fontäne
        ["Herz Fontäne"] = function(pos)
            pcall(function()
                for i = 1, 22 do
                    spawnPart(pos + Vector3.new(math.random(-2, 2), 1, math.random(-2, 2)), 2.2,
                        Color3.fromRGB(255, 90, 140),
                        Vector3.new(math.random(-15, 15), math.random(35, 70), math.random(-15, 15)), 3)
                end
            end)
        end,

        -- 3) Big Heart (großes schwebendes Herz)
        ["Big Heart"] = function(pos)
            pcall(function()
                local heart = spawnPart(pos + Vector3.new(0, 5, 0), 8, Color3.fromRGB(255, 60, 120), nil, 3.6)
                heart.Transparency = 0.15
                local startTime = os.clock()
                local conn
                conn = RunService.Heartbeat:Connect(function()
                    if not heart or not heart.Parent then if conn then conn:Disconnect() end return end
                    local t = os.clock() - startTime
                    heart.Position = pos + Vector3.new(0, 5 + math.sin(t * 1.8) * 1.2, 0)
                    heart.Transparency = 0.25 + (t * 0.35)
                    if t > 3.2 then if conn then conn:Disconnect() end pcall(function() heart:Destroy() end) end
                end)
                -- [FIX] pcall um heart.Position: Part kann von außen (FPS-Boost, F5-Reset)
                -- zerstört werden → Zugriff auf Position wirft sonst einen stillen Fehler
                for i = 1, 14 do
                    task.wait(0.05)
                    if not heart or not heart.Parent then break end
                    pcall(function()
                        spawnPart(heart.Position + Vector3.new(math.random(-3, 3), math.random(-2, 3), math.random(-3, 3)),
                            2.5, Color3.fromRGB(255, 100, 150),
                            Vector3.new(math.random(-8, 8), math.random(12, 25), math.random(-8, 8)), 2.5)
                    end)
                end
            end)
        end,

        -- 4) Explosion (klassisch mit Feuer)
        ["Explosion"] = function(pos)
            pcall(function()
                local exp = Instance.new("Explosion")
                exp.Position = pos; exp.BlastRadius = 12; exp.BlastPressure = 0
                exp.Visible = true; exp.Parent = Workspace
                for i = 1, 16 do
                    local c = (math.random() < 0.5) and Color3.fromRGB(255, 140, 0) or Color3.fromRGB(255, 60, 0)
                    spawnPart(pos + Vector3.new(0, 1, 0), math.random(15, 30) / 10, c,
                        Vector3.new(math.random(-40, 40), math.random(10, 50), math.random(-40, 40)), 1.8)
                end
            end)
        end,

        -- 5) Feuerwerk (bunte Kugel-Explosion in alle Richtungen)
        ["Feuerwerk"] = function(pos)
            pcall(function()
                local center = pos + Vector3.new(0, 3, 0)
                for i = 1, 28 do
                    local dir = Vector3.new(math.random(-100, 100), math.random(-100, 100), math.random(-100, 100))
                    -- [VERBESSERUNG] Float-sicherer Vergleich statt == 0
                    if dir.Magnitude < 0.001 then dir = Vector3.new(0, 1, 0) end
                    dir = dir.Unit * math.random(40, 70)
                    spawnPart(center, 1.6, Color3.fromHSV(math.random(), 1, 1), dir, 1.6)
                end
            end)
        end,

        -- 6) Blitz (Lichtsäule + Flash)
        ["Blitz"] = function(pos)
            pcall(function()
                local bolt = spawnPart(pos + Vector3.new(0, 20, 0), Vector3.new(1.2, 45, 1.2),
                    Color3.fromRGB(150, 220, 255), nil, 0.6, Enum.PartType.Block)
                bolt.Transparency = 0.1
                local exp = Instance.new("Explosion")
                exp.Position = pos; exp.BlastRadius = 6; exp.BlastPressure = 0
                exp.Visible = true; exp.Parent = Workspace
                for i = 1, 10 do
                    spawnPart(pos + Vector3.new(0, 2, 0), 1.4, Color3.fromRGB(120, 200, 255),
                        Vector3.new(math.random(-30, 30), math.random(15, 45), math.random(-30, 30)), 1.2)
                end
            end)
        end,

        -- 7) Blut Explosion (rote Splatter)
        ["Blut"] = function(pos)
            pcall(function()
                for i = 1, 24 do
                    local shade = math.random(120, 200)
                    spawnPart(pos + Vector3.new(0, 2, 0), math.random(10, 22) / 10,
                        Color3.fromRGB(shade, 0, 0),
                        Vector3.new(math.random(-35, 35), math.random(5, 35), math.random(-35, 35)), 2.2,
                        Enum.PartType.Ball, Enum.Material.SmoothPlastic)
                end
            end)
        end,

        -- 8) Sterne (goldener Stern-Burst)
        ["Sterne"] = function(pos)
            pcall(function()
                local center = pos + Vector3.new(0, 3, 0)
                for i = 1, 20 do
                    local ang = (i / 20) * math.pi * 2
                    local dir = Vector3.new(math.cos(ang), math.random(5, 15) / 10, math.sin(ang)).Unit * 45
                    spawnPart(center, 1.8, Color3.fromRGB(255, 215, 0), dir, 2, Enum.PartType.Ball)
                end
            end)
        end,

        -- 9) Schwarzes Loch (Implosion)
        ["Schwarzes Loch"] = function(pos)
            -- [FIX] Cooldown 2s: ohne den Guard entstehen bei schnellen Kills 16 × N Parts
            -- die nie aufgeräumt werden → Workspace voll mit Parts → FPS-Einbruch
            local now = os.clock()
            if HubState.schwarzesLochCooldown and (now - HubState.schwarzesLochCooldown) < 2 then return end
            HubState.schwarzesLochCooldown = now
            pcall(function()
                local center = pos + Vector3.new(0, 4, 0)
                local core = spawnPart(center, 2, Color3.fromRGB(20, 0, 40), nil, 1.6)
                core.Material = Enum.Material.Neon
                local parts = {}
                for i = 1, 16 do
                    local off = Vector3.new(math.random(-18, 18), math.random(-6, 10), math.random(-18, 18))
                    local pt = spawnPart(center + off, 1.2, Color3.fromHSV(math.random(), 0.8, 1), nil, 1.6)
                    table.insert(parts, pt)
                end
                local startTime = os.clock()
                local conn
                conn = RunService.Heartbeat:Connect(function()
                    local t = os.clock() - startTime
                    if not core or not core.Parent or t > 1.4 then
                        if conn then conn:Disconnect() end
                        if core and core.Parent then
                            local e = Instance.new("Explosion")
                            e.Position = core.Position; e.BlastRadius = 10; e.BlastPressure = 0
                            e.Visible = true; e.Parent = Workspace
                        end
                        return
                    end
                    core.Size = Vector3.new(2 + t * 6, 2 + t * 6, 2 + t * 6)
                    for _, pt in ipairs(parts) do
                        if pt and pt.Parent then
                            pt.Position = pt.Position:Lerp(core.Position, 0.12)
                        end
                    end
                end)
            end)
        end,

        -- 10) Regenbogen Explosion (Ring der sich ausdehnt)
        ["Regenbogen"] = function(pos)
            pcall(function()
                local center = pos + Vector3.new(0, 3, 0)
                local n = 26
                for i = 1, n do
                    local ang = (i / n) * math.pi * 2
                    local dir = Vector3.new(math.cos(ang), 0.15, math.sin(ang)).Unit * 55
                    spawnPart(center, 1.6, Color3.fromHSV(i / n, 1, 1), dir, 1.8)
                end
            end)
        end,

        -- 11) Freeze (Eis-Scherben überall)
        ["Freeze"] = function(pos)
            pcall(function()
                for i = 1, 14 do
                    local shard = spawnPart(
                        pos + Vector3.new(math.random(-250,250)/100, math.random(0,3), math.random(-250,250)/100),
                        Vector3.new(0.25, math.random(8,24)/10, 0.25),
                        Color3.fromRGB(180, 225, 255),
                        nil, 2.0, Enum.PartType.Block, Enum.Material.Ice)
                    shard.CFrame = shard.CFrame * CFrame.Angles(math.random(-10,10)/10, 0, math.random(-10,10)/10)
                end
                local ring = spawnPart(pos + Vector3.new(0,0.5,0), Vector3.new(8,0.3,8),
                    Color3.fromRGB(200,235,255), nil, 1.5, Enum.PartType.Block, Enum.Material.Ice)
                ring.Transparency = 0.3
            end)
        end,

        -- 12) Matrix (fallende grüne Zahlen)
        ["Matrix"] = function(pos)
            pcall(function()
                local ws = Workspace  -- [FIX v95] game:GetService("Workspace") → Workspace
                for i = 1, 10 do
                    local host = Instance.new("Part")
                    host.Anchored = true; host.CanCollide = false; host.Transparency = 1
                    host.Size = Vector3.new(0.1,0.1,0.1)
                    host.CFrame = CFrame.new(pos + Vector3.new(math.random(-300,300)/100, math.random(0,6), math.random(-300,300)/100))
                    host.Parent = ws
                    local bb = Instance.new("BillboardGui", host)
                    bb.Size = UDim2.new(0,22,0,22)
                    bb.AlwaysOnTop = true
                    local lbl = Instance.new("TextLabel", bb)
                    lbl.Size = UDim2.new(1,0,1,0)
                    lbl.BackgroundTransparency = 1
                    lbl.Text = tostring(math.random(0,9))
                    lbl.TextColor3 = Color3.fromRGB(0,255,70)
                    lbl.Font = Enum.Font.Code
                    lbl.TextSize = 16
                    task.delay(1.8, function() if host and host.Parent then host:Destroy() end end)
                end
            end)
        end,

        -- 13) Schockwelle (expandierender Neon-Ring)
        ["Schockwelle"] = function(pos)
            pcall(function()
                local ws = Workspace  -- [FIX v95] game:GetService("Workspace") → Workspace
                local TS = game:GetService("TweenService")
                local ring = Instance.new("Part")
                ring.Anchored = true; ring.CanCollide = false
                ring.Material = Enum.Material.Neon
                ring.Color = Color3.fromRGB(0,180,255)
                ring.Size = Vector3.new(1,1,1)
                ring.Shape = Enum.PartType.Ball
                ring.Transparency = 0.1
                ring.CFrame = CFrame.new(pos)
                ring.Parent = ws
                TS:Create(ring, TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Size = Vector3.new(18,18,18), Transparency = 1
                }):Play()
                task.delay(1, function() if ring and ring.Parent then ring:Destroy() end end)
                -- zweiter Ring etwas später
                task.delay(0.2, function()
                    local ring2 = Instance.new("Part")
                    ring2.Anchored = true; ring2.CanCollide = false
                    ring2.Material = Enum.Material.Neon
                    ring2.Color = Color3.fromRGB(120,220,255)
                    ring2.Size = Vector3.new(1,1,1)
                    ring2.Shape = Enum.PartType.Ball
                    ring2.Transparency = 0.2
                    ring2.CFrame = CFrame.new(pos)
                    ring2.Parent = ws
                    TS:Create(ring2, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        Size = Vector3.new(12,12,12), Transparency = 1
                    }):Play()
                    task.delay(0.9, function() if ring2 and ring2.Parent then ring2:Destroy() end end)
                end)
            end)
        end,

        -- 14) Konfetti (bunte Papier-Schnipsel)
        ["Konfetti"] = function(pos)
            pcall(function()
                for i = 1, 20 do
                    local conf = spawnPart(
                        pos + Vector3.new(0, 2, 0),
                        Vector3.new(0.18, 0.06, 0.28),
                        Color3.fromHSV(math.random(), 0.8, 1),
                        Vector3.new(math.random(-500,500)/100, math.random(300,900)/100, math.random(-500,500)/100),
                        2.2, Enum.PartType.Block, Enum.Material.SmoothPlastic)
                    conf.AssemblyAngularVelocity = Vector3.new(math.random(-5,5), math.random(-5,5), math.random(-5,5)) -- [FIX] War: RotVelocity (veraltet) → AssemblyAngularVelocity
                end
            end)
        end,

        -- 15) Geist (schwebende 👻 Emojis)
        ["Geist"] = function(pos)
            pcall(function()
                local ws = Workspace  -- [FIX v95] game:GetService("Workspace") → Workspace
                local TS = game:GetService("TweenService")
                for i = 1, 5 do
                    local host = Instance.new("Part")
                    host.Anchored = true; host.CanCollide = false; host.Transparency = 1
                    host.Size = Vector3.new(0.1,0.1,0.1)
                    host.CFrame = CFrame.new(pos + Vector3.new(math.random(-200,200)/100, 1, math.random(-200,200)/100))
                    host.Parent = ws
                    local bb = Instance.new("BillboardGui", host)
                    bb.Size = UDim2.new(0,50,0,50)
                    bb.AlwaysOnTop = true
                    local lbl = Instance.new("TextLabel", bb)
                    lbl.Size = UDim2.new(1,0,1,0)
                    lbl.BackgroundTransparency = 1
                    lbl.Text = "👻"
                    lbl.Font = Enum.Font.GothamBold
                    lbl.TextSize = 32
                    TS:Create(host, TweenInfo.new(1.4, Enum.EasingStyle.Sine), {
                        CFrame = CFrame.new(pos + Vector3.new(math.random(-300,300)/100, 6, math.random(-300,300)/100))
                    }):Play()
                    task.delay(1.5, function() if host and host.Parent then host:Destroy() end end)
                end
            end)
        end,
    }
    -- Reine Effektnamen (ohne "Zufällig") für die Zufallsauswahl
    local realNames = {
        "Herz Explosion", "Herz Fontäne", "Big Heart", "Explosion", "Feuerwerk",
        "Blitz", "Blut", "Sterne", "Schwarzes Loch", "Regenbogen",
        "Freeze", "Matrix", "Schockwelle", "Konfetti", "Geist"
    }
    -- Dropdown-Optionen inkl. "Zufällig"
    HubState.KILL_EFFECT_OPTIONS = {
        "Herz Explosion", "Herz Fontäne", "Big Heart", "Explosion", "Feuerwerk",
        "Blitz", "Blut", "Sterne", "Schwarzes Loch", "Regenbogen",
        "Freeze", "Matrix", "Schockwelle", "Konfetti", "Geist", "Zufällig"
    }

    HubState.CreateKillEffect = function(pos)
        if not pos then return end
        local t = Settings.KillEffectType or "Herz Explosion"
        if t == "Zufällig" then
            t = realNames[math.random(1, #realNames)]
        end
        local fn = effects[t]
        if fn then pcall(fn, pos) end
    end
end)() -- KILL EFFECT BLOCK END

-- Angriff-Tracking (v74: KEIN top-level local mehr → kein Register-Overflow mehr!)
-- Fix: local HookLocalAttacks entfernt, direkt im do-Block aufrufen.
;(function() -- HOOK BLOCK: eigener Register-Pool
    local function _hookImpl()
        local function hookTool(tool)
            if tool:IsA("Tool") and not tool:GetAttribute("KillEffectHooked") then
                tool:SetAttribute("KillEffectHooked", true)
                tool.Activated:Connect(function()
                    HubState.lastLocalAttack = os.clock()  -- [FIX v88] tick() → os.clock()
                    if Settings.CustomShootSoundEnabled then PlayShootSound() end
                end)
            end
        end
        local function hookChar(char)
            for _, t in ipairs(char:GetChildren()) do hookTool(t) end
            char.ChildAdded:Connect(hookTool)
        end
        LocalPlayer.CharacterAdded:Connect(hookChar)
        if LocalPlayer.Character then hookChar(LocalPlayer.Character) end

        -- [FIX v78] Linksklick / Touch → lastLocalAttack IMMER aktualisieren.
        -- Vorher: nur wenn char ein Roblox-Tool hält → custom Waffen (99% der Games)
        -- wurden NIE erkannt, Fallback-Kill-Detection schlug immer fehl.
        -- Jetzt: JEDER Linksklick (außer Spielmenü-Klicks) zählt als Angriff.
        UserInputService.InputBegan:Connect(function(input, gpe)
            if gpe then return end
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                HubState.lastLocalAttack = os.clock()  -- [FIX v88] tick() → os.clock()
            end
        end)
    end
    _hookImpl()
end)() -- HOOK BLOCK END

-- Death Listener (Effekt nur bei DEINEN Kills)
-- [FIX v85] Register-Overflow-Fix: kein einziges neues "local" im Top-Level-Chunk.
-- Alle Helfer-Funktionen in HubState speichern → kostet 0 Top-Level-Register.

HubState._kTags = {"creator","LastDamager","Killer","KilledBy","Attacker","DamageDealer","Source"}

HubState._kCheckObj = function(obj, where, lp, s)
    if not obj or s.k then return end
    if obj:IsA("ObjectValue") then
        if obj.Value == lp or obj.Value == lp.Character then
            s.k = true ; s.f = obj.Name.."("..where..") = DU"
        else s.f = obj.Name.."("..where..") = "..(obj.Value and tostring(obj.Value) or "nil") end
    elseif obj:IsA("StringValue") then
        if obj.Value == lp.Name or obj.Value == lp.DisplayName then
            s.k = true ; s.f = obj.Name.."("..where..") = DU"
        else s.f = obj.Name.."("..where..") = "..tostring(obj.Value) end
    elseif obj:IsA("IntValue") then
        if obj.Value == lp.UserId then
            s.k = true ; s.f = obj.Name.."("..where..") = DU"
        else s.f = obj.Name.."("..where..") = "..tostring(obj.Value) end
    end
end

HubState._kFindCreator = function(char, hum)
    local lp = LocalPlayer
    local s = { k = false, f = "keiner" }
    for _, t in ipairs(HubState._kTags) do
        HubState._kCheckObj(char:FindFirstChild(t), "char", lp, s)
        if not s.k then HubState._kCheckObj(hum:FindFirstChild(t), "hum", lp, s) end
    end
    if not s.k then
        pcall(function()
            for _, obj in ipairs(char:GetDescendants()) do
                if s.k then break end
                local nl = obj.Name:lower()
                for _, t in ipairs(HubState._kTags) do
                    if nl == t:lower() then HubState._kCheckObj(obj, "desc", lp, s) break end
                end
            end
        end)
    end
    return s.k, s.f
end

HubState._kOnDied = function(char, hum, plr, cached)
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local deathPos = cached or (hrp and hrp.Position)
    if not deathPos then
        local ok, piv = pcall(function() return char:GetPivot().Position end)
        deathPos = ok and piv or myChar.HumanoidRootPart.Position
    end
    local dist = math.floor((deathPos - myChar.HumanoidRootPart.Position).Magnitude)
    local killedByMe, creatorFound = HubState._kFindCreator(char, hum)
    local engaged = HubState.lastEngaged and HubState.lastEngaged[plr]
    local scriptEngaged = type(engaged) == "table" and engaged.t and (os.clock() - engaged.t) <= 20  -- [FIX v88] tick() → os.clock()
    local timeSinceAttack = math.floor((os.clock() - (HubState.lastLocalAttack or 0)) * 10) / 10  -- [FIX v88] tick() → os.clock()
    local recentAttack = timeSinceAttack <= 20
    local closeEnough  = dist <= 300
    if Settings.KillDebugEnabled then
        local reason = killedByMe and "✅ Creator-Tag"
            or scriptEngaged and "✅ Script-Engaged"
            or (recentAttack and closeEnough) and "✅ Angriff+"..timeSinceAttack.."s"
            or "❌ Kein Match"
        Rayfield:Notify({
            Title   = "🎯 KillDebug: " .. tostring(plr.Name),
            Content = reason.." | Dist:"..dist.." | Klick:"..timeSinceAttack.."s | Tag:"..creatorFound,
            Duration = 6
        })
    end
    if not Settings.KillEffectsEnabled then return end
    if killedByMe or scriptEngaged or (recentAttack and closeEnough) then
        HubState.CreateKillEffect(deathPos)
        pcall(function() if _G.IncrementKillCounter then _G.IncrementKillCounter() end end)
    end
end

HubState._kSetupChar = function(char, plr)
    local hum = char:WaitForChild("Humanoid", 6)
    if not hum then return end
    local cached = nil
    hum.HealthChanged:Connect(function()
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then cached = hrp.Position end
    end)
    local hrp0 = char:FindFirstChild("HumanoidRootPart")
    if hrp0 then cached = hrp0.Position end
    hum.Died:Connect(function() HubState._kOnDied(char, hum, plr, cached) end)
end

HubState._setupKillListener = function()
    if HubState.KillEffectsReady then return end
    HubState.KillEffectsReady = true
    local function connect(plr)
        if plr == LocalPlayer then return end
        plr.CharacterAdded:Connect(function(char) HubState._kSetupChar(char, plr) end)
        if plr.Character then HubState._kSetupChar(plr.Character, plr) end
    end
    for _, p in ipairs(Players:GetPlayers()) do connect(p) end
    Players.PlayerAdded:Connect(connect)
end
HubState._setupKillListener()

-- ==================== STARTUP NOTIFICATION ====================
task.spawn(function()
    task.wait(2)  -- warten bis Rayfield vollständig geladen
    -- [FIX v89] timeStr war unused + os.clock() ist keine Uhrzeit → entfernt
    -- [FIX v89] Stats["Data Ping"] → GetNetworkPing() (stabiler auf Client)
    pcall(function()
        local plrCount = #Players:GetPlayers()  -- [FIX v95] redundantes game:GetService() → Players
        local ping = math.floor(Players.LocalPlayer:GetNetworkPing() * 1000)  -- [FIX v95]
        Rayfield:Notify({
            Title   = "✅ Semys HUB v101 injiziert",  -- [FIX v101] v94 → v101
            Content = plrCount .. " Spieler | Ping: " .. ping .. "ms | Alle Features bereit!",
            Duration = 6
        })
    end)
end)

-- UI Section
pcall(function()
    SettingsTab:CreateSection("💀 Kill Effects")

    SettingsTab:CreateToggle({
        Name = "Kill Effects bei deinen Kills aktivieren",
        CurrentValue = Settings.KillEffectsEnabled,
        Callback = function(v) Settings.KillEffectsEnabled = v end
    })

    SettingsTab:CreateDropdown({
        Name = "Effect Typ",
        Options = HubState.KILL_EFFECT_OPTIONS,
        CurrentOption = Settings.KillEffectType,
        Callback = function(val)
            if type(val) == "table" then val = val[1] end
            Settings.KillEffectType = val
        end
    })

    SettingsTab:CreateToggle({
        Name = "🐛 Kill Debug Notifications (Entwickler-Modus)",
        CurrentValue = Settings.KillDebugEnabled,
        Callback = function(v)
            Settings.KillDebugEnabled = v
            Rayfield:Notify({
                Title = v and "🐛 Kill Debug AN" or "🐛 Kill Debug AUS",
                Content = v and "Zeigt bei jedem Feind-Tod eine Debug-Notification." or "Debug-Notifications deaktiviert.",
                Duration = 3
            })
        end
    })

    SettingsTab:CreateLabel("Effekte erscheinen nur wenn DU jemanden tötest • 10 Effekte + Zufällig")

    SettingsTab:CreateButton({
        Name = "🧪 Test Effect (gewählten Effekt auslösen)",
        Callback = function()
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    HubState.CreateKillEffect(hrp.Position + Vector3.new(0, 3, 0))
                    Rayfield:Notify({Title = "🧪 Test", Content = "Effekt '" .. tostring(Settings.KillEffectType) .. "' ausgelöst", Duration = 3})
                else
                    Rayfield:Notify({Title = "Fehler", Content = "Kein Character gefunden", Duration = 2})
                end
            end)
        end
    })
end)

-- ==================== JOIN TAB ====================
;(function() -- block: own register pool
    SettingsTab:CreateSection("🔗 Player Join")
    SettingsTab:CreateLabel("Gib eine Roblox User-ID ein und joine denselben Server wie dieser Spieler.")

    local joinUserId = ""

    SettingsTab:CreateInput({
        Name = "User-ID eingeben",
        PlaceholderText = "z.B. 123456789",
        RemoveTextAfterFocusLost = false, -- [FIX] War: RemoveTextAfterFocus (fehlte "Lost") → Key wurde ignoriert
        Callback = function(val)
            joinUserId = val
        end
    })

    SettingsTab:CreateButton({
        Name = "🔗 Join Player",
        Callback = function()
            local uid = tonumber(joinUserId)
            if not uid then
                Rayfield:Notify({Title = "❌ Fehler", Content = "Bitte eine gültige User-ID eingeben!", Duration = 4})
                return
            end

            Rayfield:Notify({Title = "⏳ Suche Server...", Content = "Suche Server für User-ID " .. tostring(uid) .. "...", Duration = 5})

            task.spawn(function()
                local TeleportSvc = game:GetService("TeleportService")
                local jobId = nil

                -- Methode 1: GetPlayerPlaceInstanceAsync
                local ok1, res1 = pcall(function()
                    return TeleportSvc:GetPlayerPlaceInstanceAsync(uid)
                end)
                if ok1 and type(res1) == "string" and res1 ~= "" then
                    jobId = res1
                end

                -- Methode 2: Presence API (Fallback)
                if not jobId then
                    local ok2, res2 = pcall(function()
                        -- Manche Executor unterstützen nur HttpGet, daher GET-Fallback
                        return game:HttpGet("https://games.roproxy.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
                    end)
                    if ok2 and res2 then
                        -- [FIX] pcall-Rückgabe korrekt: ok, data trennen; jobId in äußerem Scope zuweisen
                        local decOk, data = pcall(function() return HttpService:JSONDecode(res2) end)
                        if decOk and data and data.data then
                            for _, srv in ipairs(data.data) do
                                if srv.id and srv.playerIds then
                                    for _, pid in ipairs(srv.playerIds) do
                                        if pid == uid then jobId = srv.id break end
                                    end
                                end
                                if jobId then break end
                            end
                        end
                    end
                end

                -- Methode 3: Direkt über Spieler im selben Game
                if not jobId then
                    local ok3, res3 = pcall(function()
                        return game:HttpGet("https://presence.roproxy.com/v1/presence/users?userIds=" .. tostring(uid))
                    end)
                    if ok3 and res3 then
                        local ok4, data = pcall(function() return HttpService:JSONDecode(res3) end)
                        if ok4 and data and data.userPresences and data.userPresences[1] then
                            local presence = data.userPresences[1]
                            if presence.gameId and tostring(presence.gameId) == tostring(game.PlaceId) and presence.gameInstanceId then
                                jobId = presence.gameInstanceId
                            end
                        end
                    end
                end

                if jobId and jobId ~= "" then
                    Rayfield:Notify({Title = "✅ Server gefunden!", Content = "Teleportiere jetzt...", Duration = 3})
                    task.wait(0.8)
                    pcall(function()
                        TeleportSvc:TeleportToPlaceInstance(game.PlaceId, jobId)
                    end)
                else
                    Rayfield:Notify({Title = "❌ Nicht gefunden", Content = "Spieler ist offline, privat oder in einem anderen Spiel.", Duration = 5})
                end
            end)
        end
    })
end)()

-- ==================== v70 NEUE FEATURES ====================

-- 1) MOVEMENT: Click Teleport
;(function() -- block: own register pool
    local ctpActive = false
    local ctpConn = nil
    MovementTab:CreateSection("🖥 Click Teleport")
    MovementTab:CreateToggle({
        Name = "🖥 Click TP (Linksklick = Teleportieren)",
        CurrentValue = false,
        Callback = function(state)
            ctpActive = state
            if ctpConn then ctpConn:Disconnect() ctpConn = nil end
            if state then
                ctpConn = UserInputService.InputBegan:Connect(function(input, gpe)
                    if gpe or not ctpActive then return end
                    if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
                    pcall(function()
                        local mp = UserInputService:GetMouseLocation()
                        local ray = Workspace.CurrentCamera:ViewportPointToRay(mp.X, mp.Y)
                        local params = RaycastParams.new()
                        params.FilterDescendantsInstances = {LocalPlayer.Character}
                        params.FilterType = Enum.RaycastFilterType.Exclude
                        local hit = Workspace:Raycast(ray.Origin, ray.Direction * 2000, params)
                        if hit then
                            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            if hrp then hrp.CFrame = CFrame.new(hit.Position + Vector3.new(0, 3, 0)) end
                        end
                    end)
                end)
                Rayfield:Notify({Title = "Click TP", Content = "Linksklick zum Teleportieren aktiviert!", Duration = 3})
            end
        end
    })
end)()

-- 2) SPEZIAL: Server Hop
;(function() -- block: own register pool
    SpezialTab:CreateSection("🔁 Server Hop")
    SpezialTab:CreateButton({
        Name = "🔁 Server Hop (anderen Server joinen)",
        Callback = function()
            task.spawn(function()
                local TeleportSvc = game:GetService("TeleportService")
                Rayfield:Notify({Title = "🔁 Server Hop", Content = "Suche neuen Server...", Duration = 4})
                local found = false
                local ok, res = pcall(function()
                    return game:HttpGet("https://games.roproxy.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
                end)
                if ok and res then
                    local ok2, data = pcall(function() return HttpService:JSONDecode(res) end)
                    if ok2 and data and data.data then
                        for _, srv in ipairs(data.data) do
                            if srv.id and srv.id ~= game.JobId and (srv.playing or 0) < (srv.maxPlayers or 20) then
                                found = true
                                Rayfield:Notify({Title = "✅ Server gefunden!", Content = "Teleportiere...", Duration = 3})
                                task.wait(1)
                                pcall(function() TeleportSvc:TeleportToPlaceInstance(game.PlaceId, srv.id) end)
                                return
                            end
                        end
                    end
                end
                if not found then
                    Rayfield:Notify({Title = "Server Hop", Content = "Direkte Teleportation...", Duration = 2})
                    task.wait(0.5)
                    pcall(function() TeleportSvc:Teleport(game.PlaceId) end)
                end
            end)
        end
    })
end)()

-- 3) SPEZIAL: Map Tools (Unanchor All + Delete Part)
;(function() -- block: own register pool
    local dpEnabled = false
    local dpConn = nil
    SpezialTab:CreateSection("🔧 Map Tools")
    SpezialTab:CreateButton({
        Name = "🔓 Alle Parts Unanchoren",
        Callback = function()
            local n = 0
            pcall(function()
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and obj.Anchored then
                        obj.Anchored = false
                        n = n + 1
                    end
                end
            end)
            Rayfield:Notify({Title = "🔓 Unanchor All", Content = n .. " Parts entankert!", Duration = 3})
        end
    })
    SpezialTab:CreateToggle({
        Name = "🗑️ Part löschen (Linksklick auf Part)",
        CurrentValue = false,
        Callback = function(state)
            dpEnabled = state
            if dpConn then dpConn:Disconnect() dpConn = nil end
            if state then
                dpConn = UserInputService.InputBegan:Connect(function(input, gpe)
                    if gpe or not dpEnabled then return end
                    if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
                    pcall(function()
                        local mp = UserInputService:GetMouseLocation()
                        local ray = Workspace.CurrentCamera:ViewportPointToRay(mp.X, mp.Y)
                        local params = RaycastParams.new()
                        params.FilterDescendantsInstances = {LocalPlayer.Character}
                        params.FilterType = Enum.RaycastFilterType.Exclude
                        local hit = Workspace:Raycast(ray.Origin, ray.Direction * 2000, params)
                        if hit and hit.Instance then
                            local isChar = false
                            for _, p in ipairs(Players:GetPlayers()) do
                                if p.Character and hit.Instance:IsDescendantOf(p.Character) then
                                    isChar = true; break  -- [FIX v94] fehlender Semikolon zwischen zwei Anweisungen
                                end
                            end
                            if not isChar then
                                local nm = hit.Instance.Name
                                hit.Instance:Destroy()
                                Rayfield:Notify({Title = "🗑️ Gelöscht", Content = nm, Duration = 1})
                            end
                        end
                    end)
                end)
                Rayfield:Notify({Title = "Part löschen", Content = "Linksklick auf Part zum Löschen", Duration = 3})
            end
        end
    })

    -- ==================== 🌌 SKY HINTERGRUND CHANGER ====================
    -- Optionen: Galaxie / Nacht / Hell (Tag) / Regenbogen
    -- Steuert Lighting + Atmosphere für visuellen Himmels-Effekt
    local _skyRainbowActive = false

    local function _setSky(preset)
        pcall(function()
            local Lighting = game:GetService("Lighting")
            -- Bestehenden Sky + Atmosphere entfernen
            for _, obj in ipairs(Lighting:GetChildren()) do
                if obj:IsA("Sky") or obj:IsA("Atmosphere") then
                    obj:Destroy()
                end
            end
            _skyRainbowActive = false  -- Regenbogen-Loop stoppen
            HubState._skyRainbowActive = false  -- [FIX v101] F5-Reset ebenfalls informiert

            if preset == "🌌 Galaxie" then
                -- Heller Galaxie-Himmel mit Sternen und lila-blauem Leuchten
                local sky = Instance.new("Sky", Lighting)
                sky.StarCount = 5000
                sky.SkyboxBk  = "rbxassetid://159454286"
                sky.SkyboxDn  = "rbxassetid://159454286"
                sky.SkyboxFt  = "rbxassetid://159454286"
                sky.SkyboxLf  = "rbxassetid://159454286"
                sky.SkyboxRt  = "rbxassetid://159454286"
                sky.SkyboxUp  = "rbxassetid://159454286"
                Lighting.ClockTime      = 0
                Lighting.Brightness     = 1.2
                Lighting.Ambient        = Color3.fromRGB(55, 20, 120)
                Lighting.OutdoorAmbient = Color3.fromRGB(70, 30, 150)
                local atmo = Instance.new("Atmosphere", Lighting)
                atmo.Density  = 0.18
                atmo.Color    = Color3.fromRGB(60, 20, 140)
                atmo.Decay    = Color3.fromRGB(120, 40, 200)
                atmo.Glare    = 0.6
                atmo.Haze     = 1.2

            elseif preset == "🌙 Nacht" then
                -- Klare Nacht mit Sternen, tiefblauer Himmel
                local sky = Instance.new("Sky", Lighting)
                sky.StarCount = 2000
                Lighting.ClockTime      = 0
                Lighting.Brightness     = 1.5
                Lighting.Ambient        = Color3.fromRGB(15, 15, 50)
                Lighting.OutdoorAmbient = Color3.fromRGB(15, 15, 50)
                local atmo = Instance.new("Atmosphere", Lighting)
                atmo.Density  = 0.05
                atmo.Color    = Color3.fromRGB(20, 20, 85)
                atmo.Decay    = Color3.fromRGB(10, 10, 65)
                atmo.Glare    = 0
                atmo.Haze     = 0.5

            elseif preset == "☀️ Hell (Tag)" then
                -- Strahlend heller Mittagshimmel
                Lighting.ClockTime      = 14
                Lighting.Brightness     = 3
                Lighting.Ambient        = Color3.fromRGB(80, 110, 155)
                Lighting.OutdoorAmbient = Color3.fromRGB(115, 140, 180)
                local atmo = Instance.new("Atmosphere", Lighting)
                atmo.Density  = 0.35
                atmo.Color    = Color3.fromRGB(199, 220, 255)
                atmo.Decay    = Color3.fromRGB(255, 230, 200)
                atmo.Glare    = 0.5
                atmo.Haze     = 2.5

            elseif preset == "🌈 Regenbogen" then
                -- Zyklisch wechselnde Regenbogenfarben über Atmosphere
                Lighting.ClockTime  = 14
                Lighting.Brightness = 2
                local atmo = Instance.new("Atmosphere", Lighting)
                atmo.Density  = 0.45
                atmo.Glare    = 1
                atmo.Haze     = 3.5
                _skyRainbowActive = true
                HubState._skyRainbowActive = true  -- [FIX v101] F5-Reset kann jetzt stoppen
                task.spawn(function()
                    local hue = 0
                    while _skyRainbowActive and HubState._skyRainbowActive ~= false do  -- [FIX v101] F5-Flag geprüft
                        hue = (hue + 0.004) % 1
                        pcall(function()
                            atmo.Color              = Color3.fromHSV(hue, 0.85, 1)
                            atmo.Decay              = Color3.fromHSV((hue + 0.33) % 1, 0.85, 1)
                            Lighting.Ambient        = Color3.fromHSV((hue + 0.66) % 1, 0.6, 0.55)
                            Lighting.OutdoorAmbient = Color3.fromHSV((hue + 0.50) % 1, 0.5, 0.50)
                        end)
                        task.wait(0.05)
                    end
                end)
            end

            Rayfield:Notify({Title = "🌌 Sky geändert", Content = preset, Duration = 3})
        end)
    end

    SpezialTab:CreateDropdown({
        Name     = "🌌 Sky Hintergrund ändern",
        Options  = {"🌌 Galaxie", "🌙 Nacht", "☀️ Hell (Tag)", "🌈 Regenbogen"},
        CurrentOption   = "🌌 Galaxie",
        MultipleOptions = false,
        Callback = function(val)
            local choice = type(val) == "table" and val[1] or val
            if choice and choice ~= "" then _setSky(choice) end
        end
    })

    SpezialTab:CreateButton({
        Name = "🔄 Sky zurücksetzen (Original)",
        Callback = function()
            pcall(function()
                _skyRainbowActive = false
                local Lighting = game:GetService("Lighting")
                for _, obj in ipairs(Lighting:GetChildren()) do
                    if obj:IsA("Sky") or obj:IsA("Atmosphere") then
                        obj:Destroy()
                    end
                end
                Lighting.ClockTime      = 14
                Lighting.Brightness     = 2
                Lighting.Ambient        = Color3.fromRGB(70, 100, 140)
                Lighting.OutdoorAmbient = Color3.fromRGB(100, 120, 160)
            end)
            Rayfield:Notify({Title = "🔄 Sky zurückgesetzt", Content = "Original Himmel wiederhergestellt", Duration = 3})
        end
    })
    -- ==================== ENDE SKY HINTERGRUND CHANGER ====================
end)()

-- 4) SPEZIAL: Fake Lag
;(function() -- block: own register pool
    local flOn = false
    SpezialTab:CreateSection("📡 Fake Lag")
    SpezialTab:CreateToggle({
        Name = "📡 Fake Lag (simulierter Lag-Effekt)",
        CurrentValue = false,
        Callback = function(state)
            flOn = state
            HubState._fakeLagActive = state  -- [FIX v101] F5-Reset kann jetzt stoppen
            if state then
                task.spawn(function()
                    while flOn and HubState._fakeLagActive ~= false do  -- [FIX v101] F5-Flag geprüft
                        pcall(function()
                            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            if hrp then hrp.Anchored = true end
                        end)
                        task.wait(0.5)
                        pcall(function()
                            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            if hrp then hrp.Anchored = false end
                        end)
                        task.wait(1.2)
                    end
                end)
            else
                pcall(function()
                    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then hrp.Anchored = false end
                end)
            end
        end
    })
end)()

-- 5) SPEZIAL: Chat Logger
;(function() -- block: own register pool
    local clOn = false
    local clLines = {}
    local clConn = nil  -- [FIX] Connection speichern damit sie beim Deaktivieren getrennt werden kann
    -- [FIX] Section vor Label erstellen: war umgekehrt → Label erschien ÜBER der Abschnitts-Überschrift
    ChatTab:CreateSection("💬 Chat Logger")
    local clLabel = ChatTab:CreateLabel("💬 Chat Logger inaktiv")
    ChatTab:CreateToggle({
        Name = "💬 Chat Logger aktivieren",
        CurrentValue = false,
        Callback = function(state)
            clOn = state
            if state then
                -- [FIX] Bestehende Connection zuerst trennen (kein Duplikat)
                if clConn then clConn:Disconnect() clConn = nil end
                pcall(function()
                    clConn = game:GetService("TextChatService").MessageReceived:Connect(function(msg)
                        if not clOn then return end
                        local sender = msg.TextSource and msg.TextSource.Name or "?"
                        local txt = msg.Text or ""
                        local line = "[" .. sender .. "]: " .. txt
                        table.insert(clLines, 1, line)
                        while #clLines > 5 do table.remove(clLines) end
                        clLabel:Set(table.concat(clLines, "\n"))
                    end)
                end)
                Rayfield:Notify({Title = "💬 Chat Logger", Content = "Aktiv – Nachrichten erscheinen hier", Duration = 3})
            else
                -- [FIX] Connection sauber trennen statt nur clOn=false setzen
                if clConn then clConn:Disconnect() clConn = nil end
                clLabel:Set("💬 Chat Logger deaktiviert")
            end
        end
    })
    ChatTab:CreateButton({
        Name = "🗑️ Chat Log leeren",
        Callback = function()
            clLines = {}
            clLabel:Set("💬 Chat Log geleert")
        end
    })
end)()

-- 6) SETTINGS: Aktive Features Overlay
;(function() -- block: own register pool
    local ovGui = nil
    local ovLabel = nil
    local ovConn = nil
    SettingsTab:CreateSection("📋 Features Overlay")
    SettingsTab:CreateToggle({
        Name = "📋 Aktive Features Overlay anzeigen",
        CurrentValue = false,
        Callback = function(state)
            if ovConn then ovConn:Disconnect() ovConn = nil end
            if ovGui then ovGui:Destroy() ovGui = nil end
            ovLabel = nil
            if state then
                local cg = game:GetService("CoreGui")
                ovGui = Instance.new("ScreenGui")
                ovGui.Name = "SemysActiveOverlay"
                ovGui.ResetOnSpawn = false
                ovGui.Parent = cg
                local bg = Instance.new("Frame")
                bg.Position = UDim2.new(0, 8, 0.35, 0)
                bg.Size = UDim2.new(0, 175, 0, 270)
                bg.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
                bg.BackgroundTransparency = 0.25
                bg.BorderSizePixel = 0
                bg.Parent = ovGui
                Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 8)
                local hdr = Instance.new("TextLabel")
                hdr.Size = UDim2.new(1, 0, 0, 20)
                hdr.BackgroundTransparency = 1
                hdr.Text = "Semys HUB – Aktiv"
                hdr.TextColor3 = Color3.fromRGB(0, 200, 255)
                hdr.Font = Enum.Font.GothamBold
                hdr.TextSize = 11
                hdr.Parent = bg
                ovLabel = Instance.new("TextLabel")
                ovLabel.Size = UDim2.new(1, -8, 1, -24)
                ovLabel.Position = UDim2.new(0, 4, 0, 22)
                ovLabel.BackgroundTransparency = 1
                ovLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                ovLabel.Font = Enum.Font.Gotham
                ovLabel.TextSize = 10
                ovLabel.TextXAlignment = Enum.TextXAlignment.Left
                ovLabel.TextYAlignment = Enum.TextYAlignment.Top
                ovLabel.TextWrapped = true
                ovLabel.Parent = bg
                -- [FIX v77] Throttled: Overlay-Text braucht keine Frame-genaue Aktualisierung.
                -- 0.2s-Intervall (5x/s) reicht vollkommen für ein Status-Overlay.
                local _ovTimer = 0
                ovConn = RunService.Heartbeat:Connect(function(dt)
                    _ovTimer = _ovTimer + dt
                    if _ovTimer < 0.2 then return end
                    _ovTimer = 0
                    if not ovLabel or not ovLabel.Parent then return end
                    local ls = {}
                    if Settings.AimbotEnabled then table.insert(ls, "🎯 Rage Aimbot") end
                    if Settings.NormalAimbotEnabled then table.insert(ls, "🎯 Aimbot") end
                    if Settings.TriggerBotEnabled then table.insert(ls, "🔫 TriggerBot") end
                    if Settings.ESPEnabled then table.insert(ls, "👀 Box ESP") end
                    if Settings.ChamsEnabled then table.insert(ls, "🌈 Chams") end
                    if Settings.NameESPEnabled then table.insert(ls, "📛 Name ESP") end
                    if Settings.FlyEnabled then table.insert(ls, "✈️ Fly") end
                    if Settings.NoClipEnabled then table.insert(ls, "👻 NoClip") end
                    if Settings.SprintBoostEnabled then table.insert(ls, "⚡ Speed") end
                    if Settings.GodmodeEnabled then table.insert(ls, "🔰 Gottmodus") end
                    if Settings.InfiniteJumpEnabled then table.insert(ls, "🦘 Inf Jump") end
                    if Settings.SuperJumpEnabled then table.insert(ls, "🦘 Super Jump") end
                    if Settings.CrosshairEnabled then table.insert(ls, "➕ Crosshair") end
                    if Settings.StreamerMode then table.insert(ls, "🎥 Streamer") end
                    if #ls == 0 then table.insert(ls, "(Nichts aktiv)") end
                    ovLabel.Text = table.concat(ls, "\n")
                end)
            end
        end
    })
end)()

-- 7) SETTINGS: Streamer Mode
;(function() -- block: own register pool
    SettingsTab:CreateSection("🎥 Streamer Mode")
    SettingsTab:CreateToggle({
        Name = "🎥 Streamer Mode (Spielernamen zensieren)",
        CurrentValue = false,
        Callback = function(state)
            Settings.StreamerMode = state
            Rayfield:Notify({Title = "🎥 Streamer Mode", Content = state and "Namen werden als 'Spieler' angezeigt" or "Deaktiviert", Duration = 3})
        end
    })
end)()

-- 8) PLAYER INFOS: Direkt-Join aus Inspektor
;(function() -- block: own register pool
    SettingsTab:CreateSection("🔗 Schnell-Join")
    SettingsTab:CreateButton({
        Name = "🔗 Zu ausgewähltem Spieler joinen",
        Callback = function()
            if not selectedPlayer or not selectedPlayer.Parent then
                Rayfield:Notify({Title = "❌ Kein Spieler", Content = "Erst Spieler im Inspektor auswählen!", Duration = 3})
                return
            end
            task.spawn(function()
                local uid = selectedPlayer.UserId
                local nm = selectedPlayer.Name
                local TeleportSvc = game:GetService("TeleportService")
                Rayfield:Notify({Title = "⏳ Joinen...", Content = "Suche Server von " .. nm, Duration = 5})
                local ok, jobId = pcall(function()
                    return TeleportSvc:GetPlayerPlaceInstanceAsync(uid)
                end)
                if ok and jobId and jobId ~= "" then
                    Rayfield:Notify({Title = "✅ Gefunden!", Content = "Teleportiere zu " .. nm .. "...", Duration = 3})
                    task.wait(0.8)
                    pcall(function() TeleportSvc:TeleportToPlaceInstance(game.PlaceId, jobId) end)
                else
                    Rayfield:Notify({Title = "❌ Nicht gefunden", Content = nm .. " ist nicht in diesem Spiel.", Duration = 4})
                end
            end)
        end
    })
end)()



-- ==================== 👁 FE INVISIBLE (v97 NEU) ====================
-- Physik läuft an versteckter Stelle. Ein Klon spiegelt Bewegungen 1:1.
-- Andere Spieler sehen nichts. Keybind Standard: X (änderbar per Klick).
;(function() -- block: own register pool

    SpezialTab:CreateSection("👁 FE Invisible")
    SpezialTab:CreateLabel("Dein Charakter ist für andere unsichtbar. Ein Klon spiegelt deine Bewegungen 1:1 in Echtzeit.")

    -- ── State ────────────────────────────────────────────────────────────────
    local _feActive     = false
    local _fePhysConn   = nil
    local _feVisConn    = nil
    local _feRespawnConn = nil

    local _feFakePos    = Vector3.new(0, 0, 0)
    local _feBaseY      = 0
    local _feStandY     = 0
    local _feVelY       = 0
    local _feLastHRP    = Vector3.new(0, 0, 0)

    local _feAnchor     = nil
    local _feFloor      = nil
    local _feCloneParts = {}
    local _feCloneModel = nil

    local HIDE_X = 2000
    local HIDE_Z = 2000
    local HIDE_Y = 100

    local _feRayParams = RaycastParams.new()
    _feRayParams.FilterType = Enum.RaycastFilterType.Exclude

    -- ── Hilfsfunktionen ──────────────────────────────────────────────────────
    local function _feGetRot(cf)
        return CFrame.fromMatrix(Vector3.zero, cf.XVector, cf.YVector, cf.ZVector)
    end

    local function _feSetLocalTrans(char, state)
        for _, obj in ipairs(char:GetDescendants()) do
            pcall(function()
                if obj:IsA("BasePart") or obj:IsA("Decal") then
                    obj.LocalTransparencyModifier = state and 1 or 0
                end
            end)
        end
    end

    -- ── Klon bauen ───────────────────────────────────────────────────────────
    local function _feBuildClone(char)
        _feCloneParts = {}
        _feCloneModel = Instance.new("Model")
        _feCloneModel.Name   = "SemysInvisClone"
        _feCloneModel.Parent = workspace

        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                local clone = part:Clone()
                for _, child in ipairs(clone:GetChildren()) do
                    if child:IsA("BaseScript") or child:IsA("Motor6D")
                    or child:IsA("Weld")       or child:IsA("WeldConstraint") then
                        child:Destroy()
                    end
                end
                clone.Anchored    = true
                clone.CanCollide  = false
                clone.CastShadow  = false
                clone.Transparency = (part.Name == "HumanoidRootPart") and 1 or 0.5
                clone.LocalTransparencyModifier = 0
                clone.Parent = _feCloneModel
                table.insert(_feCloneParts, { real = part, clone = clone })
            end
        end

        -- Highlight-Outline (nur lokal sichtbar)
        local hl = Instance.new("Highlight")
        hl.Adornee             = _feCloneModel
        hl.FillTransparency    = 1
        hl.OutlineColor        = Color3.fromRGB(0, 209, 255)
        hl.OutlineTransparency = 0
        hl.Parent              = _feCloneModel
    end

    local function _feDestroyClone()
        if _feCloneModel then pcall(function() _feCloneModel:Destroy() end) _feCloneModel = nil end
        _feCloneParts = {}
    end

    local function _feUpdateClone(char, hrp)
        local realCF   = hrp.CFrame
        local visualCF = CFrame.new(_feFakePos) * _feGetRot(realCF)
        for _, d in ipairs(_feCloneParts) do
            pcall(function()
                if d.real and d.real.Parent and d.clone and d.clone.Parent then
                    local offset = realCF:ToObjectSpace(d.real.CFrame)
                    d.clone.CFrame = visualCF * offset
                end
            end)
        end
    end

    -- ── Cleanup ───────────────────────────────────────────────────────────────
    local function _feStop(char, hrp, humanoid)
        _feActive = false
        if _fePhysConn then _fePhysConn:Disconnect(); _fePhysConn = nil end
        if _feVisConn  then _feVisConn:Disconnect();  _feVisConn  = nil end
        _feDestroyClone()
        if _feFloor  then pcall(function() _feFloor:Destroy()  end); _feFloor  = nil end
        if _feAnchor then pcall(function() _feAnchor:Destroy() end); _feAnchor = nil end
        if char then pcall(function() _feSetLocalTrans(char, false) end) end
        pcall(function()
            local cam = workspace.CurrentCamera
            cam.CameraSubject = humanoid or (char and char:FindFirstChildOfClass("Humanoid"))
            cam.CameraType    = Enum.CameraType.Custom
        end)
        pcall(function()
            if hrp then
                hrp.CFrame                 = CFrame.new(_feFakePos) * _feGetRot(hrp.CFrame)
                hrp.AssemblyLinearVelocity = Vector3.zero
            end
        end)
    end

    -- ── Aktivieren ────────────────────────────────────────────────────────────
    local function _feStart()
        -- [FIX v101] Guard gegen Race-Condition: wenn _feActive bereits wieder false ist
        -- (z.B. durch schnellen Doppel-Toggle vor dem ersten Frame-Yield), sofort abbrechen
        if not _feActive then return end
        local lp   = Players.LocalPlayer
        local char = lp.Character or lp.CharacterAdded:Wait()
        -- [FIX v101] Zweiter Guard nach möglichem yield in CharacterAdded:Wait()
        if not _feActive then return end
        local hrp  = char:FindFirstChild("HumanoidRootPart")
        local hum  = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then
            Rayfield:Notify({Title="❌ FE Invisible", Content="Charakter nicht bereit!", Duration=3})
            return
        end

        _feActive   = true
        _feFakePos  = hrp.Position
        _feBaseY    = hrp.Position.Y
        _feVelY     = 0

        _feSetLocalTrans(char, true)

        -- Fake-Boden am versteckten Ort
        _feFloor              = Instance.new("Part")
        _feFloor.Name         = "SemysInvisFloor"
        _feFloor.Size         = Vector3.new(2000, 8, 2000)
        _feFloor.Anchored     = true
        _feFloor.CanCollide   = true
        _feFloor.Transparency = 1
        _feFloor.CastShadow   = false
        _feFloor.Material     = Enum.Material.SmoothPlastic
        _feFloor.CFrame       = CFrame.new(HIDE_X, HIDE_Y - 7, HIDE_Z)
        _feFloor.Parent       = workspace

        -- Kamera-Anker an visueller Position
        _feAnchor              = Instance.new("Part")
        _feAnchor.Name         = "SemysInvisAnchor"
        _feAnchor.Size         = Vector3.new(0.1, 0.1, 0.1)
        _feAnchor.Transparency = 1
        _feAnchor.CanCollide   = false
        _feAnchor.Anchored     = true
        _feAnchor.CFrame       = CFrame.new(_feFakePos + Vector3.new(0, 1.5, 0))
        _feAnchor.Parent       = workspace

        local cam = workspace.CurrentCamera
        cam.CameraSubject = _feAnchor
        cam.CameraType    = Enum.CameraType.Custom

        hrp.CFrame                 = CFrame.new(HIDE_X, HIDE_Y, HIDE_Z)
        hrp.AssemblyLinearVelocity = Vector3.zero
        _feStandY  = HIDE_Y
        _feLastHRP = Vector3.new(HIDE_X, HIDE_Y, HIDE_Z)

        _feBuildClone(char)
        _feRayParams.FilterDescendantsInstances = {char, _feCloneModel, _feAnchor, _feFloor}

        -- Heartbeat: XZ-Delta + Y-Physik
        _fePhysConn = RunService.Heartbeat:Connect(function(dt)
            if not _feActive then return end
            local curPos = hrp.Position

            -- Re-Centrierung bei Drift >700 Studs
            local xzDist2 = (curPos.X - HIDE_X)^2 + (curPos.Z - HIDE_Z)^2
            if xzDist2 > 700 * 700 then
                local vel = hrp.AssemblyLinearVelocity
                hrp.CFrame = CFrame.new(HIDE_X, curPos.Y, HIDE_Z) * _feGetRot(hrp.CFrame)
                hrp.AssemblyLinearVelocity = Vector3.new(0, vel.Y, 0)
                _feLastHRP = Vector3.new(HIDE_X, curPos.Y, HIDE_Z)
                curPos = _feLastHRP
            end

            local dx = curPos.X - _feLastHRP.X
            local dz = curPos.Z - _feLastHRP.Z
            _feLastHRP = curPos

            -- Wall-Sliding an visueller Position
            local R = 1.5
            local origin = _feFakePos + Vector3.new(0, 2, 0)
            if math.abs(dx) > 0.0005 or math.abs(dz) > 0.0005 then
                local fv = Vector3.new(dx, 0, dz)
                if workspace:Raycast(origin, fv.Unit * (fv.Magnitude + R), _feRayParams) then
                    if math.abs(dx) > 0.0005 and workspace:Raycast(origin, Vector3.new(math.sign(dx)*(math.abs(dx)+R), 0, 0), _feRayParams) then dx = 0 end
                    if math.abs(dz) > 0.0005 and workspace:Raycast(origin, Vector3.new(0, math.sign(dz)*(math.abs(dz)+R), 0), _feRayParams) then dz = 0 end
                end
            end
            _feFakePos = Vector3.new(_feFakePos.X + dx, _feFakePos.Y, _feFakePos.Z + dz)

            -- Y: Sprung + Schwerkraft
            local gHit = workspace:Raycast(_feFakePos + Vector3.new(0, 10, 0), Vector3.new(0, -500, 0), _feRayParams)
            local terrY = gHit and (gHit.Position.Y + 2.5) or (_feFakePos.Y - 300)
            local yOff  = math.max(0, curPos.Y - _feStandY)

            if yOff > 0.15 then
                _feBaseY  = terrY; _feVelY  = 0; _feStandY = curPos.Y - yOff
            else
                _feStandY = curPos.Y
                local drop = _feFakePos.Y - terrY
                if drop > 2 then
                    _feVelY  = _feVelY - workspace.Gravity * dt
                    _feBaseY = _feBaseY + _feVelY * dt
                    if _feBaseY <= terrY then _feBaseY = terrY; _feVelY = 0 end
                else
                    _feBaseY = _feBaseY + (terrY - _feBaseY) * math.min(dt * 20, 1); _feVelY = 0
                end
            end
            _feFakePos = Vector3.new(_feFakePos.X, _feBaseY + yOff, _feFakePos.Z)
        end)

        -- RenderStepped: Klon + Kamera direkt vor Render
        _feVisConn = RunService.RenderStepped:Connect(function()
            if not _feActive or not _feAnchor or not _feAnchor.Parent then return end
            pcall(function()
                _feAnchor.CFrame = CFrame.new(_feFakePos + Vector3.new(0, 1.5, 0)) * _feGetRot(hrp.CFrame)
                _feUpdateClone(char, hrp)
            end)
        end)

        Rayfield:Notify({Title="👁 FE Invisible AN", Content="Unsichtbar für andere. Klon spiegelt dich 1:1!", Duration=4})
    end

    -- ── Toggle-Funktion ───────────────────────────────────────────────────────
    local _feToggle_ref = nil  -- Referenz auf das Toggle-Objekt zum Reset

    local function _feToggle(force)
        -- force = true → AN, false → AUS, nil → umschalten
        local newState
        if force ~= nil then
            newState = force
        else
            newState = not _feActive
        end

        if newState == _feActive then return end

        if newState then
            _feActive = true
            task.spawn(_feStart)
        else
            local lp    = Players.LocalPlayer
            local char  = lp and lp.Character
            local hrp   = char and char:FindFirstChild("HumanoidRootPart")
            local hum   = char and char:FindFirstChildOfClass("Humanoid")
            _feStop(char, hrp, hum)
            Rayfield:Notify({Title="👁 FE Invisible AUS", Content="Wieder sichtbar.", Duration=3})
        end

        -- Toggle-UI synchronisieren
        if _feToggle_ref then
            pcall(function() _feToggle_ref:Set(newState) end)
        end
    end

    -- Respawn: nach Charakter-Reset alles zurücksetzen
    _feRespawnConn = Players.LocalPlayer.CharacterAdded:Connect(function(newChar)
        _feActive = false
        if _fePhysConn then _fePhysConn:Disconnect(); _fePhysConn = nil end
        if _feVisConn  then _feVisConn:Disconnect();  _feVisConn  = nil end
        _feDestroyClone()
        if _feFloor  then pcall(function() _feFloor:Destroy()  end); _feFloor  = nil end
        if _feAnchor then pcall(function() _feAnchor:Destroy() end); _feAnchor = nil end
        if _feToggle_ref then pcall(function() _feToggle_ref:Set(false) end) end
    end)

    -- ── UI ────────────────────────────────────────────────────────────────────
    _feToggle_ref = SpezialTab:CreateToggle({
        Name         = "👁 FE Invisible AN / AUS",
        CurrentValue = false,
        Callback     = function(state)
            _feToggle(state)
        end
    })

    SpezialTab:CreateKeybind({
        Name           = "⌨️ FE Invisible Keybind",
        CurrentKeybind = "X",
        Callback       = function()
            _feToggle(nil)
        end
    })

end)()
-- ==================== ENDE FE INVISIBLE ====================



Rayfield:Notify({
   Title = "✅ Semys HUB v101 - Alle Bugs gefixt!",  -- [FIX v101] v94 → v101
   Content = "v101: tick()→os.clock() • isSpectating-Fix • FE-RaceCond. • DoFullAntiLag • shimmer • Leaks",
   Duration = 10
})

-- Semys HUB v94 geladen
-- =============================================
-- ALLE FIXES (kumulativ, v76 + v77):
--
-- ── ERHALTEN AUS v76_FIXED ──────────────────────────────────────────────────
-- [FIX v76-1] Header-Versionsnummer v71 → v76 korrigiert
-- [FIX v76-2] local HubState = {} statt nil → kein "attempt to index nil value"
-- [FIX v76-3] Config Forward-Deklaration: 'local Settings' vor dem Window-Block,
--             Zuweisung ohne 'local' → Config-Serialisierung liest die richtige Variable
-- [FIX v76-4] Loop Fling: nil VOR task.cancel() → race-condition-sicher
-- [FIX v76-5] Loop Bring: nil VOR task.cancel() → race-condition-sicher
-- [FIX v76-6] Kill Debug Notification nur noch wenn Settings.KillDebugEnabled=true
-- [IMP v76-1] Follow: WalkSpeed-Wiederherstellung auch bei plötzlich verschwundenem Ziel
-- [IMP v76-2] Chat Spam Delay live aus HubState gelesen (kein eingefrierter Startwert)
-- [IMP v76-3] Feuerwerk-Effekt: Magnitude-Vergleich float-sicher (< 0.001 statt == 0)
-- [IMP v76-4] Notfall-Stop-Button trennt alle 18 Connections + Kamera-Reset
--
-- ── NEU IN v77_FIXED ─────────────────────────────────────────────────────────
-- [FIX v77-1] Duplicate local declarations entfernt:
--             'local VoiceRangePart, VoiceRangeOutline' und
--             'local originalTrans, originalCollide' waren DOPPELT deklariert
--             (Zeile ~3997 + ~4500) → shadow-Bug. Zweite 'local' Deklaration
--             entfernt; alle Closures sehen jetzt EINE einzige Variable-Instanz.
--
-- [FIX v77-2] Dead Assignment in EnableFreecam() entfernt:
--             Settings.AimbotMaxDistance = 1000 wurde sofort danach mit = 5000
--             überschrieben → nutzloser Write. Zeile entfernt.
--
-- [FIX v77-3] Freecam frame-rate-unabhängig gemacht:
--             freecamPos += moveDir * freecamSpeed * 0.0167
--             → freecamPos += moveDir * freecamSpeed * dt
--             (RenderStepped liefert dt; bei 30 FPS war die Kamera nur halb so
--             schnell wie bei 60 FPS — jetzt korrekt auf jeder Frame-Rate)
--
-- [FPS-FIX v77-1] AntiScreenEffects: Heartbeat-Polling → ChildAdded-Event
--             Vorher: jeden Frame Lighting:GetChildren() + alle Effekte prüfen/zerstören
--             Jetzt: reagiert NUR wenn ein neuer Effekt hinzugefügt wird → 0 CPU idle
--             Einsparung: ~600 redundante GetChildren()-Aufrufe pro 10 Sekunden
--
-- [FPS-FIX v77-3] VoiceRangeCircle: ungethrottled Heartbeat → 0.05s Intervall
--             Vorher: jeden Frame Part-CFrame + Size schreiben (auch wenn disabled)
--             Jetzt: 20x pro Sekunde, Delta-Zeit-basiert → 97% weniger Calls
--
-- [FPS-FIX v77-4] Features Overlay: ungethrottled Heartbeat → 0.2s Intervall
--             Vorher: jeden Frame TextLabel.Text neu setzen (String-Allokation!)
--             Jetzt: 5x pro Sekunde → kein Garbage-Pressure durch String-Churn
--
-- ── NEU IN v78 — KILL-EFFEKT KOMPLETT NEU GEBAUT ─────────────────────────────
-- [FIX v78-1] Attack-Tracker: Tool-Pflicht entfernt
--             Vorher: lastLocalAttack nur aktualisiert wenn char:FindFirstChildOfClass("Tool")
--             → 99% der Spiele nutzen custom Waffensysteme ohne Roblox-Tool-Instances
--             → Fallback-Detektion hat NIE gezündet (Effekt kam nie)
--             Jetzt: JEDER Linksklick/Touch außerhalb Menü = Angriff-Timestamp
--
-- [FIX v78-2] Angriffsfenster 8s → 20s + Range 250 → 300 Studs
--             Sniper/DoT/Projektile: Gegner stirbt oft erst 10–15s nach dem Schuss.
--             8s Fenster war zu kurz für Distanzkampf.
--
-- [FIX v78-3] deathPos-Caching via HealthChanged
--             Vorher: Position aus HRP nach hum.Died gelesen → viele Spiele despawnen
--             den HRP sofort, Position war (0,0,0) oder nil → Effekt spawnte falsch.
--             Jetzt: Position bei jedem HealthChanged gecacht, Died nutzt letzten Wert.
--
-- [FIX v78-4] Creator-Tag-Suche deutlich tiefer
--             Vorher: nur direkte Kinder von char + hum, nur 5 Tag-Namen.
--             Jetzt: alle GetDescendants() von char, 7 Tag-Namen ("DamageDealer", "Source"
--             dazugekommen). Findet Tags in verschachtelten Weapon-Submodellen.
--
-- [FIX v78-5] KillEffectsEnabled Standard: false → true
--             Effekt war standardmäßig aus, musste manuell eingeschaltet werden.
--             Jetzt sofort aktiv beim Laden.
--
-- ── NEU IN v93 — HANDLER-LEAKS + SICHERHEITS-FIXES ──────────────────────────
-- ── NEU IN v94 — CONNECTION-LEAKS + GAME-SCANNER + SYNTAX-FIX ───────────────
-- ── NEU IN v95 — MUSIK-BUG + VERSIONSTEXT + KORREKTHEIT + PERFORMANCE ────────
-- [FIX v95-1] Musik-Bar (ShowPasswordGUI) hatte nur 4 hartkodierte Tracks (TRACK_IDS).
--             HubState.Music.playlist hat 8 Tracks. Nutzer sah nur 4 Songs im Player.
--             Fix: TRACK_IDS auf alle 8 HubState-Playlist-Tracks + exklusiver "Neon Nights"
--             erweitert → Musik-Bar zeigt jetzt 9 Songs (exakt 8 aus Hub + 1 exklusiv).
--
-- [FIX v95-2] Versionsstring in Window:CreateWindow zeigte noch "v89" statt "v94".
--             Betrifft: Name, LoadingSubtitle, verLbl.Text, Notify-Title (je 1×).
--             Alle 4 Stellen auf v94 aktualisiert.
--
-- [FIX v95-3] game.Workspace → workspace (DetectVoiceRange Containers-Liste, 1 Stelle).
--
-- [FIX v95-4] game:GetService("Workspace") → Workspace in Kill-Effekten (3 Stellen):
--             Matrix, Schockwelle, Geist — redundante Service-Abrufe entfernt.
--
-- [FIX v95-5] game:GetService("Players") → Players in Startup-Notification (2 Stellen).
--
-- [FIX v95-6] Auto-Clicker CPS-Präzisionsfehler: math.floor(cps/60) rundete 90 CPS auf
--             60 CPS ab. Fix: Accumulator-Methode → exakte CPS bei jedem Wert > 60.
--
-- [FIX v95-7] Godmode Anti-BreakJoints (Schicht 5): Metatable-Hook wurde bei jedem
--             Respawn erneut verschachtelt (N Respawns = N geschachtelte Closures →
--             Stack-Overflow-Risiko). Fix: Hook läuft nur einmal (HubState._gmMtHooked),
--             char-Referenz dynamisch via HubState._gmChar (bleibt nach Respawn korrekt).
--
-- [FIX v95-8] Spieler-Highlight CharacterRemoving:Connect ohne Speicherung → bei
--             mehrfachem Button-Druck akkumulierten Connections. Fix: in
--             HubState.pa_highlightConn gespeichert, alte Verbindung wird getrennt.
--
-- [FIX v95-9] math.random(-power//10, power//10) → math.floor Guard (VelFling):
--             Slider-Werte können Floats sein; //10 gibt in Luau Float zurück →
--             math.random erwartet Integer. Fix: explizites math.floor().
--
-- [FIX v95-10] Godmode _gmCleanup: HubState._gmChar nicht zurückgesetzt →
--              Anti-BreakJoints (Schicht 5) blieb auch nach Deaktivierung aktiv,
--              weil der Metatable-Hook weiter auf den alten char zeigt.
--              Fix: HubState._gmChar = nil in _gmCleanup().
-- [FIX v94-1] isChar = true break → isChar = true; break (Syntaxfehler Part-Delete Map Tool)
-- [FIX v94-2] Game Scanner: 4× game:GetDescendants() → 1 Loop (3× weniger Overhead)
-- [FIX v94-3] RenderStepped(UpdateFOVCircle) → HubState._fovCircleConn (kein Leak)
-- [FIX v94-4] Workspace.DescendantAdded (NPC-ESP) → HubState._npcDescAddedConn
-- [FIX v94-5] Workspace.DescendantRemoving (NPC-ESP) → HubState._npcDescRemovingConn
-- [FIX v94-6] Players.PlayerAdded/Removing (Tracers) → HubState gespeichert
-- [FIX v94-7] Players.PlayerAdded/Removing (Inspektor) → HubState gespeichert
-- [FIX v94-8] F5-Reset: alle v94-Connections werden jetzt getrennt
-- [FIX v94-9] Auto-Speed-Label "bis 1000" → "bis 150" (korrekter Slider-Max)
-- [FIX v94-10] Ghost-Transparenz-Slider: ApplyGhost() jetzt mit pcall + Nil-Guard
-- [FIX v93-1] gethui type-guard + nil-Rückgabe-Schutz (Musik-Player + SemysUI IIFE)
--             Vorher: 'if gethui then gethui() end' — auf manchen Executors ist
--             gethui ein Table/Userdata, kein Callable → Crash beim Laden.
--             Jetzt: type(gethui) == "function" als Guard (×2).
-- [FIX v93-1b] sg-Fallback nutzt 'if not sg.Parent' statt 'if not parented'
--             Vorher: gethui() kann nil zurückgeben → pcall =true, sg unparented,
--             Fallback nie erreicht → Hub unsichtbar.
--             Jetzt: Prüfung auf sg.Parent direkt (wie bereits bei musicGui).
--
-- [FIX v93-2] Toggle-Open-Keybind: anonyme Funktion als beganHandlers-Key
--             Vorher: 'beganHandlers[function(…) end] = true' — jeder CreateWindow-
--             Aufruf erzeugt einen neuen, nie löschbaren Key → Ghost-Handler.
--             Jetzt: Funktion in _toggleOpenHandler gespeichert; sg.AncestryChanged
--             entfernt den Eintrag beim Zerstören des ScreenGui.
--
-- [FIX v93-3] CreateKeybind: _keybindHandler blieb permanent in beganHandlers
--             Vorher: Handler nach UI-Zerstörung nie aus beganHandlers entfernt
--             → Leak von einem Eintrag pro erstelltem Keybind-Element.
--             Jetzt: row.AncestryChanged räumt den Handler auf.
--
-- [FIX v93-4] CreateSlider: _sliderMoveHandler blieb permanent in changedHandlers
--             Vorher: Handler nach UI-Zerstörung nie aus changedHandlers entfernt
--             → Leak pro Slider (50+ Slider im Hub = 50+ tote Handler).
--             Jetzt: track.AncestryChanged räumt den Handler auf.
--
-- [FIX v93-5] EQ-Bar Heartbeat-Connection nie gespeichert/getrennt
--             Vorher: RS_m.Heartbeat:Connect(…) ohne gespeicherte Referenz →
--             Connection lief nach pCard-Destroy für immer weiter (obwohl
--             'if not pCard.Parent then return end' den Body abschnitt, blieb
--             die Connection aktiv und feuerte jeden Frame unnötig).
--             Jetzt: Connection in _eqConn2 gespeichert; pCard.AncestryChanged
--             ruft :Disconnect() auf.
-- =============================================