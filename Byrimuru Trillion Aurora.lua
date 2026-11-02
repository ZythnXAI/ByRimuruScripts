-- ══════════════════════════════════════════════════════════════════════════════
--  ╔══════════════════════════════════════════════════════════════════════════╗
--  ║     B y R i m u r u S c r i p t s   —   T R I L L I O N   A U R O R A    ║
--  ║          Auto Piano Studio Engine  •  Drift-Free Rhythm Core v8.0        ║
--  ╠══════════════════════════════════════════════════════════════════════════╣
--  ║  • UI/UX Obsidian Glass + Aurora Neon + Equalizador & Mini-Piano ao vivo ║
--  ║  • Motor Sub-Frame sem Drift + Hold Assíncrono (zero atraso em acordes)  ║
--  ║  • Barra de Progresso Interativa (Seek) + Mini-Player Flutuante          ║
--  ║  • Gerenciador de Fila + Favoritos Rápidos + Criador Custom + 3 Idiomas  ║
--  ║  • Anti-Stuck Keys + Limpeza Total de Memória/Conexões (_G.Cleanup)      ║
--  ╚══════════════════════════════════════════════════════════════════════════╝
-- ══════════════════════════════════════════════════════════════════════════════

-- ══════════════════════════════════════════════════════════════
--  SERVIÇOS DO ROBLOX & AMBIENTE SEGURO
-- ══════════════════════════════════════════════════════════════
local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local HttpService      = game:GetService("HttpService")
local Lighting         = game:GetService("Lighting")
local SoundService     = game:GetService("SoundService")
local ContentProvider  = game:GetService("ContentProvider")
local VIM              = game:GetService("VirtualInputManager")
local LocalPlayer      = Players.LocalPlayer

-- Executa limpeza de instância anterior se o script for re-executado
if type(_G.ByRimuruCleanup) == "function" then
  pcall(_G.ByRimuruCleanup)
end

local Connections = {}
local function trackConn(conn)
  if conn then
    table.insert(Connections, conn)
  end
  return conn
end

-- ══════════════════════════════════════════════════════════════
--  INFO / CRÉDITOS / MARCA
-- ══════════════════════════════════════════════════════════════
local BRAND = { title = "ByRimuruScripts", subtitle = "TRILLION AURORA", author = "by Kokuyt450-create + ByRimuruScripts", version = "8.0.0", codename = "SUPERNOVA EDITION" }

local CREDITS = {
  { name = "Kokuyt450-create",     role = "Lead Developer & Hub UI/UX Architecture", emoji = "✦" },
  { name = "ByRimuruScripts",      role = "Drift-Free Auto Piano Core & Aurora Engine", emoji = "⚡" },
  { name = "hellohellohell012321", role = "MIDI2LUA Song Library & Native Format",    emoji = "♪" },
}

-- ══════════════════════════════════════════════════════════════
--  CONFIGURAÇÕES GLOBAIS DO MOTOR
-- ══════════════════════════════════════════════════════════════
local Config = {
  DefaultBPM         = 166,
  MinSpeed           = 0.25,
  MaxSpeed           = 3.00,
  NightcoreSpeed     = 1.35,   -- +35%
  TurboSpeed         = 1.75,   -- +75%
  SlowedSpeed        = 0.80,   -- -20%
  ChordDelay         = 0.012,
  KeyHold            = 0.070,  -- duração padrão de sustentação da tecla (s)
  AntiLagThrottle    = 0.004,  -- intervalo mínimo anti-travamento
  HumanizeJitter     = 0.005,  -- ± jitter no disparo sem acumular drift
  HumanizeEnabled    = false,
  AntiLagEnabled     = true,
  SubdivPerBeat      = 4,      -- 1/16 por slot
  DashStep           = 1.00,
  SpaceStep          = 0.00,
  MouseClickEnabled  = false,

  -- Motor TALENTLESS / SecondaryLoader
  SecondaryLoader    = true,   -- preciseWait sub-frame para precisão máxima
  ErrorMargin        = 0.000,  -- 0.000 = perfeito; até 0.040 = mais humano
  ShortNotesEnabled  = true,   -- estaccato natural em notas sem duração explícita
  ShortMinHold       = 0.030,
  ShortMaxHold       = 0.080,
  ShortMinHoldShift  = 0.040,
  ShortMaxHoldShift  = 0.115,
  RandomShiftEnabled = false,

  -- Preferências Visuais e de Áudio
  MuteSFX            = false,
  DisableNotifs      = false,
  ScanlineEnabled    = true,
  BlurEnabled        = true,

  -- Ajustes automáticos para partituras Midi2Lua
  Midi2Lua = { Enabled = true, DashRatio = 0.32, FixDefault120 = true, DefaultBPM = 156, MidBPM = 162, DenseBPM = 174, DashStep = 1.00, SpeedMult = 1.00, DenseGridBoost = 1.00, CompressDashes = false },
}

-- ══════════════════════════════════════════════════════════════
--  ARTE VISUAL DO HUB
-- ══════════════════════════════════════════════════════════════
local ART = {
  url       = nil,
  localFile = nil,
  asset     = "rbxassetid://1724303458",
  options   = { "rbxassetid://1724303458", "rbxassetid://579271238", "rbxassetid://5181568648", "rbxassetid://731672614", "rbxassetid://10149736922", "rbxassetid://5183585523", "rbxassetid://1109782152", "rbxassetid://4870505191", "rbxassetid://721891673", "rbxassetid://1236280328", "rbxassetid://5326906309" },
}

-- ══════════════════════════════════════════════════════════════
--  ESTADO GLOBAL DA APLICAÇÃO
-- ══════════════════════════════════════════════════════════════
local State = {
  currentSong     = 1,
  isPlaying       = false,
  isPaused        = false,
  speed           = 1.00,
  mode            = "Normal",   -- Normal | Nightcore | Turbo | Slowed
  loopEnabled     = false,
  shuffleEnabled  = false,
  autoNext        = false,
  progress        = 0,
  currentNote     = 0,
  totalNotes      = 0,
  elapsedSec      = 0,
  totalSec        = 0,
  seekTarget      = nil,        -- fração 0..1 quando o usuário arrasta a barra
  lastPlayedKeys  = "—",
  lastNoteTime    = 0,
  lastNoteIntensity = 0,
  playThread      = nil,
  customSongs     = {},
  favorites       = {},
  queue           = {},
  queuePos        = 0,
  lang            = "pt",
  hasSavedLang    = false,
  isMinimized     = false,
}

-- ══════════════════════════════════════════════════════════════
--  SISTEMA DE IDIOMAS (PT • EN • ES) — 100% SINCRONIZADO
-- ══════════════════════════════════════════════════════════════
local TR_STATIC = {
  {"BIBLIOTECA  /  FILTROS",                        "LIBRARY  /  FILTERS",                           "BIBLIOTECA  /  FILTROS"},
  {"🔍 Pesquisar músicas, animes ou categorias...", "🔍 Search songs, anime or categories...",       "🔍 Buscar canciones, anime o categorías..."},
  {"🔀  SHUFFLE PLAY",                              "🔀  SHUFFLE PLAY",                              "🔀  MODO ALEATORIO"},
  {"🎲  DESCOBRIR RANDOM",                          "🎲  DISCOVER RANDOM",                           "🎲  CANCIÓN RANDOM"},
  {"♫ TOCANDO AGORA",                               "♫ NOW PLAYING",                                 "♫ REPRODUCIENDO"},
  {"▶  EXECUTAR MÚSICA",                            "▶  PLAY SONG",                                  "▶  REPRODUCIR"},
  {"⏸  PAUSAR MÚSICA",                              "⏸  PAUSE SONG",                                 "⏸  PAUSAR CANCIÓN"},
  {"▶  RETOMAR MÚSICA",                             "▶  RESUME SONG",                                "▶  REANUDAR CANCIÓN"},
  {"≣  + Fila",                                     "≣  + Queue",                                    "≣  + Cola"},
  {"VELOCIDADE & MODO",                             "SPEED & MODE",                                  "VELOCIDAD Y MODO"},
  {"🔁 Loop",                                       "🔁 Loop",                                       "🔁 Bucle"},
  {"🔀 Auto",                                       "🔀 Auto",                                       "🔀 Auto"},
  {"⚙ Config",                                      "⚙ Settings",                                    "⚙ Ajustes"},
  {"Slow",                                          "Slow",                                          "Lento"},
  {"Pronto.",                                       "Ready.",                                        "Listo."},
  {"⚙  Configurações do Motor & UI",                "⚙  Engine & UI Settings",                       "⚙  Ajustes del Motor y UI"},
  {"★  Créditos & Informações",                     "★  Credits & Info",                             "★  Créditos e Información"},
  {"⭐  Estúdio de Música Custom",                   "⭐  Custom Song Studio",                         "⭐  Estudio de Canción Custom"},
  {"≣  Fila de Reprodução",                         "≣  Playback Queue",                             "≣  Cola de Reproducción"},
  {"🗑 Limpar Fila",                                 "🗑 Clear Queue",                                 "🗑 Vaciar Cola"},
  {"⚡ SecondaryLoader (Precisão Sub-Frame)",       "⚡ SecondaryLoader (Sub-Frame Precision)",      "⚡ SecondaryLoader (Precisión Sub-Frame)"},
  {"🎵 Notas Curtas (Estaccato Natural)",           "🎵 Short Notes (Natural Staccato)",             "🎵 Notas Cortas (Staccato Natural)"},
  {"🖱️ Modo Mouse (Clicar Teclas na Tela)",         "🖱️ Mouse Mode (Click Screen Keys)",             "🖱️ Modo Mouse (Clic en Teclas)"},
  {"✨ Humanize (Micro-variação Humana)",           "✨ Humanize (Human Micro-timing)",              "✨ Humanize (Toque Humano)"},
  {"🛡️ Anti-Lag (Proteção de FPS)",                 "🛡️ Anti-Lag (FPS Protection)",                  "🛡️ Anti-Lag (Protección de FPS)"},
  {"⏭️ Auto-Next (Avançar Automático)",             "⏭️ Auto-Next (Auto Advance)",                   "⏭️ Auto-Next (Avance Automático)"},
  {"🌊 Efeito Scanline & Blur Cinematográfico",     "🌊 Scanline & Cinematic Blur",                  "🌊 Efecto Scanline y Blur"},
  {"🔇 Silenciar Sons da Interface (SFX)",          "🔇 Mute UI Sound Effects (SFX)",                "🔇 Silenciar Sonidos de UI (SFX)"},
  {"Velocidade Global",                             "Global Speed",                                  "Velocidad Global"},
  {"Sustentação da Nota (Key Hold)",                "Note Sustain (Key Hold)",                       "Sostenido de Nota (Key Hold)"},
  {"Margem de Erro Humana (Jitter)",                "Human Error Margin (Jitter)",                   "Margen de Error Humano (Jitter)"},
  {"✓ SALVAR & TOCAR AGORA",                        "✓ SAVE & PLAY NOW",                             "✓ GUARDAR Y REPRODUCIR"},
  {"arte visual\n(clique p/ trocar)",               "visual art\n(click to change)",                 "arte visual\n(clic para cambiar)"},
}

local TR_FMT = {
  songs      = { pt = "%d músicas",                           en = "%d songs",                           es = "%d canciones" },
  showing    = { pt = "  •  exibindo %d (use a busca)",       en = "  •  showing %d (use search)",       es = "  •  mostrando %d (usa la búsqueda)" },
  note       = { pt = "%s  •  %d%%  •  nota %d/%d",           en = "%s  •  %d%%  •  note %d/%d",         es = "%s  •  %d%%  •  nota %d/%d" },
  ready      = { pt = "Pronto  •  ByRimuruScripts v8.0",      en = "Ready  •  ByRimuruScripts v8.0",     es = "Listo  •  ByRimuruScripts v8.0" },
  loaded     = { pt = "✨ ByRimuruScripts v8.0 — %d músicas prontas!", en = "✨ ByRimuruScripts v8.0 — %d songs ready!", es = "✨ ByRimuruScripts v8.0 — ¡%d canciones listas!" },
  all        = { pt = "Todas",                                en = "All",                                es = "Todas" },
  favs       = { pt = "★ Favoritos",                          en = "★ Favorites",                        es = "★ Favoritos" },
  custom     = { pt = "⭐ Custom",                             en = "⭐ Custom",                           es = "⭐ Custom" },
  queueCat   = { pt = "≣ Na Fila",                            en = "≣ In Queue",                         es = "≣ En Cola" },
  queueEmpty = { pt = "A fila está vazia.\nAdicione músicas clicando em '+' na lista ou em '+ Fila'.", en = "Queue is empty.\nAdd songs by clicking '+' in the list or '+ Queue'.", es = "La cola está vacía.\nAñade canciones haciendo clic en '+' o en '+ Cola'." },
}

local function langIdx()
  return (State.lang == "en" and 2) or (State.lang == "es" and 3) or 1
end

local function tr(key)
  local e = TR_FMT[key]
  if not e then return key end
  return e[State.lang] or e.pt
end

local _trmap
local function trMap()
  if not _trmap then
    _trmap = {}
    for _, row in ipairs(TR_STATIC) do
      _trmap[row[1]] = row
    end
  end
  return _trmap
end

-- ══════════════════════════════════════════════════════════════
--  PREMIUM BOOT EXPERIENCE (COM BOTÃO DE PULAR E ANIMAÇÃO FLUIDA)
-- ══════════════════════════════════════════════════════════════
local function ShowPremiumBoot()
  pcall(function()
    local parent = LocalPlayer:WaitForChild("PlayerGui")
    local old = parent:FindFirstChild("ByRimuruPremiumBoot")
    if old then old:Destroy() end
    local oldBlur = Lighting:FindFirstChild("ByRimuruBootBlur")
    if oldBlur then oldBlur:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "ByRimuruPremiumBoot"
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 100000
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = parent

    local blur = Instance.new("BlurEffect")
    blur.Name = "ByRimuruBootBlur"
    blur.Size = 0
    blur.Parent = Lighting
    TweenService:Create(blur, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Size = 18}):Play()

    local bg = Instance.new("Frame")
    bg.Size = UDim2.fromScale(1, 1)
    bg.BackgroundColor3 = Color3.fromRGB(3, 5, 11)
    bg.BackgroundTransparency = 0.08
    bg.BorderSizePixel = 0
    bg.Parent = gui

    local bgGradient = Instance.new("UIGradient")
    bgGradient.Rotation = 128
    bgGradient.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(2, 5, 12)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(8, 15, 30)), ColorSequenceKeypoint.new(1, Color3.fromRGB(18, 9, 34)) })
    bgGradient.Parent = bg

    local function orb(size, pos, color, transparency)
      local image = Instance.new("ImageLabel")
      image.Image = "rbxassetid://5028857084"
      image.ImageColor3 = color
      image.ImageTransparency = transparency
      image.BackgroundTransparency = 1
      image.Size = UDim2.fromOffset(size, size)
      image.Position = pos
      image.AnchorPoint = Vector2.new(0.5, 0.5)
      image.Parent = bg
      return image
    end

    local orbA = orb(520, UDim2.fromScale(0.20, 0.22), Color3.fromRGB(70, 224, 255), 0.72)
    local orbB = orb(620, UDim2.fromScale(0.82, 0.78), Color3.fromRGB(162, 98, 255), 0.75)
    TweenService:Create(orbA, TweenInfo.new(2.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { ImageTransparency = 0.82, Rotation = 15 }):Play()
    TweenService:Create(orbB, TweenInfo.new(2.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { ImageTransparency = 0.84, Rotation = -12 }):Play()

    local card = Instance.new("Frame")
    card.AnchorPoint = Vector2.new(0.5, 0.5)
    card.Position = UDim2.fromScale(0.5, 0.5)
    card.Size = UDim2.fromOffset(460, 220)
    card.BackgroundColor3 = Color3.fromRGB(9, 14, 26)
    card.BackgroundTransparency = 0.06
    card.BorderSizePixel = 0
    card.Parent = bg
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 22)

    local cardStroke = Instance.new("UIStroke")
    cardStroke.Color = Color3.fromRGB(94, 231, 255)
    cardStroke.Transparency = 0.28
    cardStroke.Thickness = 1.5
    cardStroke.Parent = card

    local strokeGrad = Instance.new("UIGradient")
    strokeGrad.Rotation = 35
    strokeGrad.Color = ColorSequence.new(Color3.fromRGB(94, 231, 255), Color3.fromRGB(174, 112, 255))
    strokeGrad.Parent = cardStroke

    local cardGradient = Instance.new("UIGradient")
    cardGradient.Rotation = 120
    cardGradient.Color = ColorSequence.new(Color3.fromRGB(12, 19, 34), Color3.fromRGB(20, 14, 38))
    cardGradient.Parent = card

    local scale = Instance.new("UIScale")
    scale.Scale = 0.84
    scale.Parent = card
    TweenService:Create(scale, TweenInfo.new(0.42, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()

    local monogram = Instance.new("TextLabel")
    monogram.Text = "BR"
    monogram.Font = Enum.Font.GothamBlack
    monogram.TextSize = 24
    monogram.TextColor3 = Color3.fromRGB(5, 10, 18)
    monogram.BackgroundColor3 = Color3.fromRGB(102, 234, 255)
    monogram.Size = UDim2.fromOffset(58, 58)
    monogram.Position = UDim2.fromOffset(26, 24)
    monogram.BorderSizePixel = 0
    monogram.Parent = card
    Instance.new("UICorner", monogram).CornerRadius = UDim.new(0, 16)
    local monoGradient = Instance.new("UIGradient")
    monoGradient.Color = ColorSequence.new(Color3.fromRGB(102, 234, 255), Color3.fromRGB(174, 112, 255))
    monoGradient.Rotation = 35
    monoGradient.Parent = monogram

    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Position = UDim2.fromOffset(98, 24)
    title.Size = UDim2.new(1, -120, 0, 28)
    title.Font = Enum.Font.GothamBlack
    title.Text = "BYRIMURU  //  TRILLION v8.0"
    title.TextSize = 20
    title.TextColor3 = Color3.fromRGB(242, 248, 255)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = card

    local subtitle = Instance.new("TextLabel")
    subtitle.BackgroundTransparency = 1
    subtitle.Position = UDim2.fromOffset(99, 52)
    subtitle.Size = UDim2.new(1, -120, 0, 18)
    subtitle.Font = Enum.Font.GothamBold
    subtitle.Text = "SUPERNOVA DRIFT-FREE RHYTHM ENGINE"
    subtitle.TextSize = 10
    subtitle.TextColor3 = Color3.fromRGB(102, 234, 255)
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.Parent = card

    local skipBtn = Instance.new("TextButton")
    skipBtn.BackgroundTransparency = 0.3
    skipBtn.BackgroundColor3 = Color3.fromRGB(24, 34, 54)
    skipBtn.Position = UDim2.new(1, -84, 0, 24)
    skipBtn.Size = UDim2.fromOffset(58, 24)
    skipBtn.Font = Enum.Font.GothamBold
    skipBtn.Text = "PULAR ▸"
    skipBtn.TextSize = 10
    skipBtn.TextColor3 = Color3.fromRGB(185, 202, 230)
    skipBtn.BorderSizePixel = 0
    skipBtn.Parent = card
    Instance.new("UICorner", skipBtn).CornerRadius = UDim.new(0, 8)

    local skipped = false
    skipBtn.MouseButton1Click:Connect(function()
      skipped = true
    end)

    local divider = Instance.new("Frame")
    divider.Size = UDim2.new(1, -52, 0, 1)
    divider.Position = UDim2.fromOffset(26, 96)
    divider.BackgroundColor3 = Color3.fromRGB(80, 104, 142)
    divider.BackgroundTransparency = 0.55
    divider.BorderSizePixel = 0
    divider.Parent = card

    local status = Instance.new("TextLabel")
    status.BackgroundTransparency = 1
    status.Position = UDim2.fromOffset(26, 114)
    status.Size = UDim2.new(1, -52, 0, 22)
    status.Font = Enum.Font.GothamMedium
    status.Text = "Inicializando motor de alta precisão..."
    status.TextSize = 12
    status.TextColor3 = Color3.fromRGB(190, 206, 230)
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.Parent = card

    local barBg = Instance.new("Frame")
    barBg.Size = UDim2.new(1, -52, 0, 8)
    barBg.Position = UDim2.fromOffset(26, 152)
    barBg.BackgroundColor3 = Color3.fromRGB(26, 36, 56)
    barBg.BorderSizePixel = 0
    barBg.Parent = card
    Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)

    local bar = Instance.new("Frame")
    bar.Size = UDim2.fromScale(0, 1)
    bar.BackgroundColor3 = Color3.fromRGB(100, 229, 255)
    bar.BorderSizePixel = 0
    bar.Parent = barBg
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
    local barGradient = Instance.new("UIGradient")
    barGradient.Color = ColorSequence.new(Color3.fromRGB(94, 231, 255), Color3.fromRGB(174, 112, 255))
    barGradient.Parent = bar

    local percent = Instance.new("TextLabel")
    percent.BackgroundTransparency = 1
    percent.Position = UDim2.fromOffset(26, 172)
    percent.Size = UDim2.new(1, -52, 0, 18)
    percent.Font = Enum.Font.GothamBold
    percent.Text = "0%"
    percent.TextSize = 11
    percent.TextColor3 = Color3.fromRGB(102, 234, 255)
    percent.TextXAlignment = Enum.TextXAlignment.Right
    percent.Parent = card

    local steps = { "Calibrando relógio sub-frame sem drift...", "Sincronizando biblioteca & parser MIDI2LUA...", "Carregando equalizador & mini-piano ao vivo...", "Aplicando interface Obsidian Glass v8.0..." }

    for i, message in ipairs(steps) do
      if skipped then break end
      status.Text = message
      percent.Text = tostring(math.floor((i / #steps) * 100)) .. "%"
      TweenService:Create(bar, TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Size = UDim2.fromScale(i / #steps, 1) }):Play()
      task.wait(0.16)
    end

    if not skipped then task.wait(0.08) end
    TweenService:Create(card, TweenInfo.new(0.24, Enum.EasingStyle.Quad), { BackgroundTransparency = 1 }):Play()
    for _, descendant in ipairs(card:GetDescendants()) do
      if descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
        TweenService:Create(descendant, TweenInfo.new(0.20), {TextTransparency = 1, BackgroundTransparency = 1}):Play()
      elseif descendant:IsA("Frame") then
        TweenService:Create(descendant, TweenInfo.new(0.20), {BackgroundTransparency = 1}):Play()
      elseif descendant:IsA("UIStroke") then
        TweenService:Create(descendant, TweenInfo.new(0.20), {Transparency = 1}):Play()
      end
    end
    TweenService:Create(bg, TweenInfo.new(0.26), {BackgroundTransparency = 1}):Play()
    TweenService:Create(blur, TweenInfo.new(0.24), {Size = 0}):Play()
    task.wait(0.26)
    gui:Destroy()
    blur:Destroy()
  end)
end

ShowPremiumBoot()

-- ══════════════════════════════════════════════════════════════
--  SISTEMA DE SETTINGS PERSISTENTES (TALENTLESS_settings.txt)
-- ══════════════════════════════════════════════════════════════
local SETTINGS_FILE = "TALENTLESS_settings.txt"
_G.talentlessSettings = _G.talentlessSettings or { secondaryloader = true, errormargin = 0.000, shorts = true, randomshift = false, mutesfx = false, disablenotifs = false }

local function loadSettings()
  if isfile and readfile and isfile(SETTINGS_FILE) then
    local ok, content = pcall(function() return readfile(SETTINGS_FILE) end)
    if ok and content and content:find("talentlessSettings") then
      local fn = loadstring and loadstring(content)
      if fn then pcall(fn) end
    end
  end
end

local function saveSettings()
  if not writefile then return end
  local s = "_G.talentlessSettings = {\n"
  for key, val in pairs(_G.talentlessSettings) do
    if type(val) == "boolean" or type(val) == "number" then
      s = s .. "  ['" .. tostring(key) .. "'] = " .. tostring(val) .. ",\n"
    end
  end
  s = s .. "}\n"
  pcall(function() writefile(SETTINGS_FILE, s) end)
end

local function applySettingsToConfig()
  local ts = _G.talentlessSettings
  if not ts then return end
  if ts.secondaryloader ~= nil then Config.SecondaryLoader    = (ts.secondaryloader == true) end
  if ts.errormargin     ~= nil then Config.ErrorMargin        = tonumber(ts.errormargin) or Config.ErrorMargin end
  if ts.shorts          ~= nil then Config.ShortNotesEnabled  = (ts.shorts == true) end
  if ts.randomshift     ~= nil then Config.RandomShiftEnabled = (ts.randomshift == true) end
  if ts.mutesfx         ~= nil then Config.MuteSFX            = (ts.mutesfx == true) end
  if ts.disablenotifs   ~= nil then Config.DisableNotifs      = (ts.disablenotifs == true) end
end

local function syncConfigToSettings()
  _G.talentlessSettings.secondaryloader = Config.SecondaryLoader
  _G.talentlessSettings.errormargin     = Config.ErrorMargin
  _G.talentlessSettings.shorts          = Config.ShortNotesEnabled
  _G.talentlessSettings.randomshift     = Config.RandomShiftEnabled
  _G.talentlessSettings.mutesfx         = Config.MuteSFX
  _G.talentlessSettings.disablenotifs   = Config.DisableNotifs
  saveSettings()
end

-- Corrigido: aceita valores false sem abortar!
local function toggleSetting(key)
  if _G.talentlessSettings[key] == nil then return nil end
  _G.talentlessSettings[key] = not _G.talentlessSettings[key]
  applySettingsToConfig()
  saveSettings()
  return _G.talentlessSettings[key]
end

loadSettings()
applySettingsToConfig()

-- ══════════════════════════════════════════════════════════════
--  MAPA DE TECLAS & NOTE MAPPINGS (5 OITAVAS VIRTUAL PIANO)
-- ══════════════════════════════════════════════════════════════
local KeyMap = {
  ["1"]=Enum.KeyCode.One,   ["2"]=Enum.KeyCode.Two,   ["3"]=Enum.KeyCode.Three,
  ["4"]=Enum.KeyCode.Four,  ["5"]=Enum.KeyCode.Five,  ["6"]=Enum.KeyCode.Six,
  ["7"]=Enum.KeyCode.Seven, ["8"]=Enum.KeyCode.Eight, ["9"]=Enum.KeyCode.Nine,
  ["0"]=Enum.KeyCode.Zero,
  ["!"]=Enum.KeyCode.One,   ["@"]=Enum.KeyCode.Two,   ["#"]=Enum.KeyCode.Three,
  ["$"]=Enum.KeyCode.Four,  ["%"]=Enum.KeyCode.Five,  ["^"]=Enum.KeyCode.Six,
  ["&"]=Enum.KeyCode.Seven, ["*"]=Enum.KeyCode.Eight, ["("]=Enum.KeyCode.Nine,
  [")"]=Enum.KeyCode.Zero,
  ["q"]=Enum.KeyCode.Q, ["w"]=Enum.KeyCode.W, ["e"]=Enum.KeyCode.E,
  ["r"]=Enum.KeyCode.R, ["t"]=Enum.KeyCode.T, ["y"]=Enum.KeyCode.Y,
  ["u"]=Enum.KeyCode.U, ["i"]=Enum.KeyCode.I, ["o"]=Enum.KeyCode.O,
  ["p"]=Enum.KeyCode.P, ["a"]=Enum.KeyCode.A, ["s"]=Enum.KeyCode.S,
  ["d"]=Enum.KeyCode.D, ["f"]=Enum.KeyCode.F, ["g"]=Enum.KeyCode.G,
  ["h"]=Enum.KeyCode.H, ["j"]=Enum.KeyCode.J, ["k"]=Enum.KeyCode.K,
  ["l"]=Enum.KeyCode.L, ["z"]=Enum.KeyCode.Z, ["x"]=Enum.KeyCode.X,
  ["c"]=Enum.KeyCode.C, ["v"]=Enum.KeyCode.V, ["b"]=Enum.KeyCode.B,
  ["n"]=Enum.KeyCode.N, ["m"]=Enum.KeyCode.M,
  ["Q"]=Enum.KeyCode.Q, ["W"]=Enum.KeyCode.W, ["E"]=Enum.KeyCode.E,
  ["R"]=Enum.KeyCode.R, ["T"]=Enum.KeyCode.T, ["Y"]=Enum.KeyCode.Y,
  ["U"]=Enum.KeyCode.U, ["I"]=Enum.KeyCode.I, ["O"]=Enum.KeyCode.O,
  ["P"]=Enum.KeyCode.P, ["A"]=Enum.KeyCode.A, ["S"]=Enum.KeyCode.S,
  ["D"]=Enum.KeyCode.D, ["F"]=Enum.KeyCode.F, ["G"]=Enum.KeyCode.G,
  ["H"]=Enum.KeyCode.H, ["J"]=Enum.KeyCode.J, ["K"]=Enum.KeyCode.K,
  ["L"]=Enum.KeyCode.L, ["Z"]=Enum.KeyCode.Z, ["X"]=Enum.KeyCode.X,
  ["C"]=Enum.KeyCode.C, ["V"]=Enum.KeyCode.V, ["B"]=Enum.KeyCode.B,
  ["N"]=Enum.KeyCode.N, ["M"]=Enum.KeyCode.M,
}

local ShiftKeys = { Q = true,W = true,E = true,R = true,T = true,Y = true,U = true,I = true,O = true,P = true, A = true,S = true,D = true,F = true,G = true,H = true,J = true,K = true,L = true, Z = true,X = true,C = true,V = true,B = true,N = true,M = true, ["!"] = true,["@"] = true,["#"] = true,["$"] = true,["%"] = true,["^"] = true, ["&"] = true,["*"] = true,["("] = true,[")"] = true }

-- Ordem cromática/escala para o visualizador de Mini-Piano
local PianoOrder = "1!2@34$5%6^78*9(0qQwWeErtTyYuIoOpPasSdDfFgGhHjJkKlLzZxXcCvVbBnNm"
local CharToPitchIndex = {}
for idx = 1, #PianoOrder do
  CharToPitchIndex[PianoOrder:sub(idx, idx)] = idx
end

local noteMappings = {
  ["C"]  = { [1]="1", [2]="8", [3]="t", [4]="s", [5]="l", [6]="m" },
  ["C#"] = { [1]="!", [2]="*", [3]="T", [4]="S", [5]="L" },
  ["Db"] = { [1]="!", [2]="*", [3]="T", [4]="S", [5]="L" },
  ["D"]  = { [1]="2", [2]="9", [3]="y", [4]="d", [5]="z" },
  ["D#"] = { [1]="@", [2]="(", [3]="Y", [4]="D", [5]="Z" },
  ["Eb"] = { [1]="@", [2]="(", [3]="Y", [4]="D", [5]="Z" },
  ["E"]  = { [1]="3", [2]="0", [3]="u", [4]="f", [5]="x" },
  ["F"]  = { [1]="4", [2]="q", [3]="i", [4]="g", [5]="c" },
  ["F#"] = { [1]="$", [2]="Q", [3]="I", [4]="G", [5]="C" },
  ["Gb"] = { [1]="$", [2]="Q", [3]="I", [4]="G", [5]="C" },
  ["G"]  = { [1]="5", [2]="w", [3]="o", [4]="h", [5]="v" },
  ["G#"] = { [1]="%", [2]="W", [3]="O", [4]="H", [5]="V" },
  ["Ab"] = { [1]="%", [2]="W", [3]="O", [4]="H", [5]="V" },
  ["A"]  = { [1]="6", [2]="e", [3]="p", [4]="j", [5]="b" },
  ["A#"] = { [1]="^", [2]="E", [3]="P", [4]="J", [5]="B" },
  ["Bb"] = { [1]="^", [2]="E", [3]="P", [4]="J", [5]="B" },
  ["B"]  = { [1]="7", [2]="r", [3]="a", [4]="k", [5]="n" },
}

local velocityMap = "58qrupdhl"
local currentVelocity = 1.0

-- Controle de teclas ativas para evitar teclas presas ao pausar/parar
local ActiveKeyTokens = {}
local PedalHeld = false

local function releaseAllKeys()
  pcall(function()
    for kc, _ in pairs(ActiveKeyTokens) do
      VIM:SendKeyEvent(false, kc, false, game)
    end
    ActiveKeyTokens = {}
    VIM:SendKeyEvent(false, Enum.KeyCode.LeftShift, false, game)
    VIM:SendKeyEvent(false, Enum.KeyCode.LeftAlt, false, game)
    if PedalHeld then
      VIM:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
      PedalHeld = false
    end
  end)
end

local function pedalDown()
  if not State.isPlaying then return end
  PedalHeld = true
  pcall(function() VIM:SendKeyEvent(true, Enum.KeyCode.Space, false, game) end)
end

local function pedalUp()
  PedalHeld = false
  pcall(function() VIM:SendKeyEvent(false, Enum.KeyCode.Space, false, game) end)
end

local function adjustVelocity(vel)
  if not State.isPlaying then return end
  vel = math.clamp(tonumber(vel) or 1.0, 0, 1)
  currentVelocity = vel
  local topress
  if vel < 0.27 then
    topress = "2"
  elseif vel >= 0.88 then
    topress = "c"
  else
    local index = math.floor((vel - 0.27) / 0.61 * (#velocityMap - 2)) + 2
    index = math.clamp(index, 2, #velocityMap)
    topress = velocityMap:sub(index, index)
  end
  pcall(function()
    VIM:SendKeyEvent(true,  Enum.KeyCode.LeftAlt, false, game)
    VIM:SendKeyEvent(true,  KeyMap[topress], false, game)
    VIM:SendKeyEvent(false, KeyMap[topress], false, game)
    VIM:SendKeyEvent(false, Enum.KeyCode.LeftAlt, false, game)
  end)
end

-- ══════════════════════════════════════════════════════════════
--  BIBLIOTECA DE MÚSICAS + FALLBACK EMBUTIDO
-- ══════════════════════════════════════════════════════════════
local Songs = {}
local SONGS_URL = "https://media.base44.com/files/public/6a5b34f93e7456934ce0f0e9/545e97588_songs.txt"

local FallbackSongs = {
  { name = "Unravel — Tokyo Ghoul (Acoustic)", bpm = 135, emoji = "🩸", category = "Anime", sequence = "u i o p - a s a p o u - u i o p - a s d s a p o u - [up] - [io] - [up] a s d [sf] d s a [up] o" },
  { name = "River Flows in You — Yiruma", bpm = 138, emoji = "🌊", category = "Clássicas", sequence = "[up] a [up] o [up] u [up] t - [ip] a [ip] o [ip] i [ip] y - [uo] p a s [ad] s a p [uo] i u y t" },
  { name = "Megalovania — Undertale", bpm = 160, emoji = "💀", category = "Games", sequence = "d d D a - P - p - o - f p o - c c D a - P - p - o - f p o - b b D a - P - p - o - f p o" },
  { name = "Für Elise — Beethoven", bpm = 148, emoji = "🎻", category = "Clássicas", sequence = "f D f D f a d s p - t u p a - u O a s - u f D f D f a d s p - t u p a - u s a p" },
  { name = "Rush E — Sheet Music Boss", bpm = 185, emoji = "⚡", category = "Memes & Viral", sequence = "u u u u u u u u i u y u t u i u p - p p p p o i u y t r e w q" },
  { name = "Blue Bird — Naruto Shippuden", bpm = 152, emoji = "🕊️", category = "Anime", sequence = "e u i o - p o i u - y u i y - e - e u i o - p a s a p o i u - y u i o p" },
}

do
  local function fetch(url)
    local req = request or http_request or (syn and syn.request) or (http and http.request)
    if req then
      local ok, res = pcall(req, { Url = url, Method = "GET" })
      if ok and res and (res.Body or res.body) then
        local body = res.Body or res.body
        if #body > 100 then return body end
      end
    end
    local ok2, res2 = pcall(function() return game:HttpGet(url, true) end)
    if ok2 and res2 and #res2 > 100 then return res2 end
    return nil
  end

  local code = fetch(SONGS_URL)
  if code and loadstring then
    local fn = loadstring(code)
    if fn then
      local env = setmetatable({ Songs = Songs }, { __index = getfenv and getfenv(0) or _G })
      if setfenv then pcall(setfenv, fn, env) end
      local ok = pcall(fn)
      if ok and env.Songs then
        for k, v in pairs(env.Songs) do Songs[k] = v end
      end
    end
  end

  if #Songs == 0 then
    for _, fb in ipairs(FallbackSongs) do
      table.insert(Songs, fb)
    end
  end
end

-- ══════════════════════════════════════════════════════════════
--  PERSISTÊNCIA DE DADOS (FAVORITOS, CUSTOM & IDIOMA)
-- ══════════════════════════════════════════════════════════════
local SAVE_FILE = "Talentless_Kokuyt450.json"

local function saveData()
  pcall(function()
    if not writefile then return end
    writefile(SAVE_FILE, HttpService:JSONEncode({ customSongs = State.customSongs, favorites = State.favorites, lang = State.lang }))
  end)
end

local function loadData()
  pcall(function()
    if isfile and readfile and isfile(SAVE_FILE) then
      local d = HttpService:JSONDecode(readfile(SAVE_FILE))
      if d then
        State.customSongs  = d.customSongs or {}
        State.favorites    = d.favorites   or {}
        if d.lang then
          State.lang = d.lang
          State.hasSavedLang = true
        end
      end
    end
  end)
  for _, c in ipairs(State.customSongs) do
    table.insert(Songs, { name = c.name, bpm = c.bpm or 120, emoji = "⭐", category = c.midi2lua and "Midi2Lua" or "Custom", sequence = c.sequence, custom = true, midi2lua = c.midi2lua =  = true })
  end
end

-- ══════════════════════════════════════════════════════════════
--  PARSERS & DETECÇÃO MIDI2LUA (DECLARADOS ANTES DE prepareSong!)
-- ══════════════════════════════════════════════════════════════
local function isMidi2LuaNative(seq)
  if not seq then return false end
  if seq:find("keypress%s*%(") or seq:find("pressnote%s*%(") then return true end
  if seq:find("Generated by MIDI2LUA") then return true end
  return false
end

local function extractMidi2LuaBPM(seq)
  if not seq then return nil end
  local b = seq:match("local%s+bpm%s*=%s*(%d+)")
  if b then return tonumber(b) end
  b = seq:match("bpm%s*=%s*(%d+)")
  if b then return tonumber(b) end
  return nil
end

local function extractMidi2LuaFlags(seq)
  local flags = { shorts = true, velocity = false, midi88 = false }
  if not seq then return flags end
  if seq:find("Short Notes:%s*ON") then flags.shorts = true
  elseif seq:find("Short Notes:%s*OFF") then flags.shorts = false end
  if seq:find("Note Velocity:%s*ON") then flags.velocity = true
  elseif seq:find("Note Velocity:%s*OFF") then flags.velocity = false end
  if seq:find("MIDI88:%s*ON") then flags.midi88 = true end
  return flags
end

local function parseMidi2LuaScript(seq)
  local actions = {}
  if not seq then return actions end

  for line in seq:gmatch("[^\r\n]+") do
    local trimmed = line:match("^%s*(.-)%s*$") or line
    if trimmed:sub(1, 2) ~= "--" and #trimmed > 0 then
      local keys, beats = trimmed:match('keypress%s*%(%s*["'](https://www.google.com/search?q=%5B%5E%22%27%5D%2B)["\']%s*,%s*([^,)]+)')
      if keys then
        local b = tonumber(beats)
        actions[#actions+1] = { type = "keypress", keys = keys, beats = b, isShort = (b =  = nil) }
      else
        local note, octave, pbeats = trimmed:match('pressnote%s*%(%s*["'](https://www.google.com/search?q=%5B%5E%22%27%5D%2B)["\']%s*,%s*(%d+)%s*,%s*([^,)]+)')
        if note then
          local b = tonumber(pbeats)
          actions[#actions+1] = { type = "pressnote", note = note, octave = tonumber(octave), beats = b, isShort = (b =  = nil) }
        else
          local rbeats = trimmed:match('rest%s*%(%s*([%d%.]+)')
          if rbeats then
            actions[#actions+1] = { type = "rest", beats = tonumber(rbeats) or 1 }
          else
            local vel = trimmed:match('adjustVelocity%s*%(%s*([%d%.]+)')
            if vel then
              actions[#actions+1] = { type = "adjustVelocity", vel = tonumber(vel) or 1.0 }
            elseif trimmed:find("pedalDown%s*%(") then
              actions[#actions+1] = { type = "pedalDown" }
            elseif trimmed:find("pedalUp%s*%(") then
              actions[#actions+1] = { type = "pedalUp" }
            end
          end
        end
      end
    end
  end
  return actions
end

local function isPlayableSeq(seq)
  if not seq then return false end
  if isMidi2LuaNative(seq) then return true end
  local n = 0
  for i = 1, #seq do
    local c = seq:sub(i, i)
    if c ~= "-" and c ~= " " and c ~= "[" and c ~= "]" then
      n = n + 1
      if n >= 3 then return true end
    end
  end
  return false
end

local function analyzeSequence(seq)
  local dashes, spaces, notes, len = 0, 0, 0, 0
  if not seq then return { dashes=0, spaces=0, notes=0, len=0, dashRatio=0, spaceRatio=0 } end
  len = #seq
  for i = 1, len do
    local c = seq:sub(i, i)
    if c == "-" then dashes = dashes + 1
    elseif c == " " then spaces = spaces + 1
    elseif c ~= "[" and c ~= "]" then notes = notes + 1 end
  end
  return { dashes = dashes, spaces = spaces, notes = notes, len = len, dashRatio = (len > 0) and (dashes / len) or 0, spaceRatio = (len > 0) and (spaces / len) or 0 }
end

local function isMidi2LuaSong(song, stats)
  if not song or not Config.Midi2Lua or not Config.Midi2Lua.Enabled then return false end
  if song.midi2lua == true or song.format == "midi2lua" or song.source == "midi2lua" then return true end
  local cat = string.lower(tostring(song.category or ""))
  if cat == "midi2lua" or cat == "midi" or cat == "midi2lua keypress" then return true end
  if isMidi2LuaNative(song.sequence) then return true end
  stats = stats or analyzeSequence(song.sequence)
  if stats.dashes >= 20 and stats.dashRatio >= (Config.Midi2Lua.DashRatio or 0.32) and stats.spaceRatio < 0.14 then
    return true
  end
  return false
end

local function prepareSong(song)
  if not song then return song end
  local stats = analyzeSequence(song.sequence)
  local midi  = isMidi2LuaSong(song, stats)
  local m2l   = Config.Midi2Lua or {}
  local bpm   = tonumber(song.bpm) or 0

  song._stats           = stats
  song._midi2lua        = midi
  song._bpm_fixed       = false
  song._midi2lua_native = false

  if isMidi2LuaNative(song.sequence) then
    song._midi2lua_native = true
    if bpm <= 0 then
      local scriptBPM = extractMidi2LuaBPM(song.sequence)
      if scriptBPM and scriptBPM > 0 then
        bpm = scriptBPM
      else
        bpm = m2l.DefaultBPM or Config.DefaultBPM
        song._bpm_fixed = true
      end
    end
    song._m2l_flags       = extractMidi2LuaFlags(song.sequence)
    song._play_bpm        = bpm
    song._speed_mult      = tonumber(song.speed_mult) or 1.0
    song._dash_step       = m2l.DashStep or 0.5
    song._compress_dashes = false
    song._prepared        = true
    return song
  end

  if midi then
    if bpm <= 0 then
      bpm = m2l.DefaultBPM or Config.DefaultBPM
      song._bpm_fixed = true
    elseif bpm == 120 and m2l.FixDefault120 then
      if stats.dashRatio >= 0.50 then
        bpm = m2l.DenseBPM or 174
      elseif stats.dashRatio >= 0.38 then
        bpm = m2l.MidBPM or 162
      else
        bpm = m2l.DefaultBPM or 156
      end
      song._bpm_fixed = true
    end
    song._play_bpm = bpm
    local sm = (tonumber(song.speed_mult) or 1.0) * (m2l.SpeedMult or 1.0)
    if stats.dashRatio >= 0.48 then
      sm = sm * (m2l.DenseGridBoost or 1.0)
    end
    song._speed_mult      = sm
    song._dash_step       = m2l.DashStep or 0.5
    song._compress_dashes = (m2l.CompressDashes ~= false)
  else
    song._play_bpm        = (bpm > 0) and bpm or Config.DefaultBPM
    song._speed_mult      = tonumber(song.speed_mult) or 1.0
    song._dash_step       = Config.DashStep
    song._compress_dashes = false
  end
  song._prepared = true
  return song
end

local PlayableIdx = {}
local PlayableLookup = {}
local CategoryCount = {}

local function rebuildIndexes()
  PlayableIdx = {}
  PlayableLookup = {}
  CategoryCount = {}
  for i = 1, #Songs do
    local s = Songs[i]
    if s then
      prepareSong(s)
      if isPlayableSeq(s.sequence) then
        s.broken = false
        table.insert(PlayableIdx, i)
        PlayableLookup[i] = #PlayableIdx
        local cat = s.category or "Outros"
        CategoryCount[cat] = (CategoryCount[cat] or 0) + 1
      else
        s.broken = true
      end
    end
  end
end

local function parseSequence(seq, compressDashes)
  local tokens, i, len = {}, 1, #(seq or "")
  while i <= len do
    local ch = seq:sub(i, i)
    if ch == "[" then
      local j = seq:find("]", i)
      if j then
        local keys, chars = {}, {}
        for k = i + 1, j - 1 do
          local c = seq:sub(k, k)
          if KeyMap[c] then
            keys[#keys+1] = { key = KeyMap[c], shift = ShiftKeys[c] or false, char = c }
            chars[#chars+1] = c
          end
        end
        if #keys > 0 then
          tokens[#tokens+1] = { type = "chord", keys = keys, display = "[" .. table.concat(chars) .. "]" }
        end
        i = j + 1
      else
        i = i + 1
      end
    elseif ch == "-" then
      if compressDashes then
        local j = i
        while j <= len and seq:sub(j, j) == "-" do j = j + 1 end
        local rests = math.max(1, math.ceil((j - i) / 2))
        for _ = 1, rests do tokens[#tokens+1] = { type = "dash" } end
        i = j
      else
        tokens[#tokens+1] = { type = "dash" }
        i = i + 1
      end
    elseif ch == " " then
      tokens[#tokens+1] = { type = "space" }
      i = i + 1
    elseif KeyMap[ch] then
      tokens[#tokens+1] = { type = "note", key = KeyMap[ch], shift = ShiftKeys[ch] or false, char = ch, display = ch }
      i = i + 1
    else
      i = i + 1
    end
  end
  return tokens
end

-- ══════════════════════════════════════════════════════════════
--  MODO MOUSE (CLICAR TECLAS NA TELA)
-- ══════════════════════════════════════════════════════════════
local MouseMap = nil

local function isHubObj(o)
  local cur = o
  while cur and cur ~= game do
    local n = tostring(cur.Name):lower()
    if n:find("rimuru") or n:find("talentless") or n:find("sakura") then return true end
    cur = cur.Parent
  end
  return false
end

local function buildMouseMap()
  MouseMap = {}
  local pg = LocalPlayer:FindFirstChild("PlayerGui")
  if not pg then return end
  for _, o in ipairs(pg:GetDescendants()) do
    if (o:IsA("TextButton") or o:IsA("ImageButton")) and not isHubObj(o) then
      local id
      local nm = tostring(o.Name)
      if #nm == 1 then
        id = nm
      else
        local t = ""
        pcall(function() t = tostring(o.Text or "") end)
        if #t == 1 then id = t end
      end
      if id and not MouseMap[id] then MouseMap[id] = o end
    end
  end
end

local function clickKeyChar(char, holdTime)
  if not char then return false end
  if not MouseMap then buildMouseMap() end
  local btn = MouseMap and (MouseMap[char] or MouseMap[char:lower()] or MouseMap[char:upper()])
  if not btn or not btn.Parent then return false end
  local p, s = btn.AbsolutePosition, btn.AbsoluteSize
  local x, y = math.floor(p.X + s.X / 2), math.floor(p.Y + s.Y / 2)
  pcall(function() VIM:SendMouseButtonEvent(x, y, 0, true, game, 0) end)
  task.delay(holdTime or Config.KeyHold, function()
    pcall(function() VIM:SendMouseButtonEvent(x, y, 0, false, game, 0) end)
  end)
  return true
end

-- ══════════════════════════════════════════════════════════════
--  ENVIO DE TECLAS — ALTA PRECISÃO & HOLD ASSÍNCRONO SEM DRIFT
-- ══════════════════════════════════════════════════════════════
local UI_PianoTrigger -- callback visual p/ acender o mini-piano e equalizador

local function preciseWait(seconds)
  if seconds <= 0 then return end
  local start = os.clock()
  while os.clock() - start < seconds do
    if not State.isPlaying then return end
    if seconds - (os.clock() - start) > 0.014 then
      RunService.Heartbeat:Wait()
    else
      break
    end
  end
  while os.clock() - start < seconds do
    if not State.isPlaying then return end
  end
end

local function calcHoldTime(shift, isShort)
  if isShort and Config.ShortNotesEnabled then
    if shift then
      return Config.ShortMinHoldShift + math.random() * (Config.ShortMaxHoldShift - Config.ShortMinHoldShift)
    else
      return Config.ShortMinHold + math.random() * (Config.ShortMaxHold - Config.ShortMinHold)
    end
  end
  return Config.KeyHold
end

-- Release assíncrono: NUNCA bloqueia o loop rítmico principal!
local function scheduleKeyRelease(keyCode, shift, holdTime)
  local token = os.clock() + math.random()
  ActiveKeyTokens[keyCode] = token
  task.spawn(function()
    if Config.SecondaryLoader then
      preciseWait(holdTime)
    else
      task.wait(holdTime)
    end
    if ActiveKeyTokens[keyCode] == token then
      ActiveKeyTokens[keyCode] = nil
      pcall(function()
        VIM:SendKeyEvent(false, keyCode, false, game)
        if shift then
          VIM:SendKeyEvent(false, Enum.KeyCode.LeftShift, false, game)
        end
      end)
    end
  end)
end

local function pressKey(keyCode, shift, char, isShort)
  if not State.isPlaying then return end
  local holdTime = calcHoldTime(shift, isShort)

  State.lastPlayedKeys = char or "♪"
  State.lastNoteTime = os.clock()
  State.lastNoteIntensity = math.clamp(0.55 + math.random() * 0.45, 0.4, 1.0)
  if UI_PianoTrigger then UI_PianoTrigger({ char }) end

  if Config.MouseClickEnabled and clickKeyChar(char, holdTime) then return end

  if not shift and Config.RandomShiftEnabled and Config.ErrorMargin > 0 then
    if math.random(1, 500) <= math.floor(Config.ErrorMargin * 100) then
      shift = true
    end
  end

  pcall(function()
    if shift then VIM:SendKeyEvent(true, Enum.KeyCode.LeftShift, false, game) end
    VIM:SendKeyEvent(true, keyCode, false, game)
  end)

  scheduleKeyRelease(keyCode, shift, holdTime)
end

local function playChord(keys, isShort, displayStr)
  if not State.isPlaying or not keys or #keys == 0 then return end
  local holdTime = calcHoldTime(true, isShort)

  local chars = {}
  for _, k in ipairs(keys) do
    if k.char then chars[#chars+1] = k.char end
  end
  State.lastPlayedKeys = displayStr or ("[" .. table.concat(chars) .. "]")
  State.lastNoteTime = os.clock()
  State.lastNoteIntensity = math.clamp(0.75 + math.min(#keys * 0.06, 0.25), 0.6, 1.0)
  if UI_PianoTrigger then UI_PianoTrigger(chars) end

  local kb = {}
  for _, k in ipairs(keys) do
    if not (Config.MouseClickEnabled and clickKeyChar(k.char, holdTime)) then
      kb[#kb+1] = k
    end
  end
  if #kb == 0 then return end

  local nonShift, withShift = {}, {}
  for _, k in ipairs(kb) do
    if k.shift then withShift[#withShift+1] = k
    else nonShift[#nonShift+1] = k end
  end

  local token = os.clock() + math.random()
  pcall(function()
    for _, k in ipairs(nonShift) do
      ActiveKeyTokens[k.key] = token
      VIM:SendKeyEvent(true, k.key, false, game)
    end
    if #withShift > 0 then
      VIM:SendKeyEvent(true, Enum.KeyCode.LeftShift, false, game)
      for _, k in ipairs(withShift) do
        ActiveKeyTokens[k.key] = token
        VIM:SendKeyEvent(true, k.key, false, game)
      end
    end
  end)

  task.spawn(function()
    if Config.SecondaryLoader then
      preciseWait(holdTime)
    else
      task.wait(holdTime)
    end
    pcall(function()
      if #withShift > 0 then
        for _, k in ipairs(withShift) do
          if ActiveKeyTokens[k.key] == token then
            ActiveKeyTokens[k.key] = nil
            VIM:SendKeyEvent(false, k.key, false, game)
          end
        end
        VIM:SendKeyEvent(false, Enum.KeyCode.LeftShift, false, game)
      end
      for _, k in ipairs(nonShift) do
        if ActiveKeyTokens[k.key] == token then
          ActiveKeyTokens[k.key] = nil
          VIM:SendKeyEvent(false, k.key, false, game)
        end
      end
    end)
  end)
end

local function keypressStr(keys, isShort)
  if not keys or keys == "" then return end
  local list = {}
  for i = 1, #keys do
    local c = keys:sub(i, i)
    if KeyMap[c] then
      list[#list+1] = { key = KeyMap[c], shift = ShiftKeys[c] or false, char = c }
    end
  end
  if #list == 1 then
    pressKey(list[1].key, list[1].shift, list[1].char, isShort)
  elseif #list > 1 then
    playChord(list, isShort, "[" .. keys .. "]")
  end
end

-- ══════════════════════════════════════════════════════════════
--  MOTOR DE RITMO — AGENDAMENTO ABSOLUTO + SUPORTE A SEEK
-- ══════════════════════════════════════════════════════════════
local function getEffectiveSpeedMultiplier()
  local sm = State.speed
  if State.mode == "Nightcore" then sm = sm * Config.NightcoreSpeed
  elseif State.mode == "Turbo" then sm = sm * (Config.TurboSpeed or 1.75)
  elseif State.mode == "Slowed" then sm = sm * Config.SlowedSpeed end
  return math.max(0.1, sm)
end

local function baseStep(song)
  if song and not song._prepared then prepareSong(song) end
  local bpm  = (song and (song._play_bpm or song.bpm)) or Config.DefaultBPM
  local mult = (song and (song._speed_mult or song.speed_mult)) or 1.0
  local step = (60 / bpm) * (1 / Config.SubdivPerBeat) / mult
  local d    = step / getEffectiveSpeedMultiplier()
  if Config.AntiLagEnabled and d < Config.AntiLagThrottle then d = Config.AntiLagThrottle end
  return d
end

local function formatTime(sec)
  sec = math.max(0, math.floor(tonumber(sec) or 0))
  return string.format("%02d:%02d", math.floor(sec / 60), sec % 60)
end

local function playSong(idx)
  local song = Songs[idx]
  if not song then return end
  if not song._prepared then prepareSong(song) end
  releaseAllKeys()

  -- ═══ MODO 1: FORMATO MIDI2LUA NATIVO (keypress / pressnote / rest) ═══
  if song._midi2lua_native then
    local actions = parseMidi2LuaScript(song.sequence)
    local bpm = song._play_bpm or Config.DefaultBPM
    local flags = song._m2l_flags or { shorts = true, velocity = false }
    State.totalNotes  = #actions
    State.currentNote = 0
    State.progress    = 0
    State.seekTarget  = nil
    if #actions == 0 then return end

    -- Pré-calcula duração total em beats
    local totalBeats = 0
    for _, a in ipairs(actions) do
      if a.type == "rest" or ((a.type == "keypress" or a.type == "pressnote") and a.beats and type(a.beats) == "number") then
        totalBeats = totalBeats + (tonumber(a.beats) or 0)
      end
    end

    local ai = 1
    local playedBeats = 0
    while ai <= #actions and State.isPlaying do
      while State.isPaused do
        releaseAllKeys()
        task.wait(0.03)
        if not State.isPlaying then return end
      end

      if State.seekTarget then
        local targetIdx = math.clamp(math.floor(State.seekTarget * #actions), 1, #actions)
        State.seekTarget = nil
        releaseAllKeys()
        ai = targetIdx
      end

      local action = actions[ai]
      local effSpeed = getEffectiveSpeedMultiplier()
      State.totalSec = (totalBeats > 0) and ((totalBeats / bpm) * 60 / effSpeed) or (#actions * 0.08 / effSpeed)
      State.elapsedSec = State.totalSec * (ai / #actions)

      local isShort = flags.shorts and (action.isShort ~= false)
      if action.beats and type(action.beats) == "number" then
        isShort = false
      end

      if action.type == "keypress" then
        keypressStr(action.keys, isShort)
        if not isShort and action.beats then
          local waitTime = (action.beats / bpm) * 60 / effSpeed
          if Config.ErrorMargin > 0 then
            waitTime = waitTime + (math.random() * 2 - 1) * (Config.ErrorMargin / 2)
          end
          playedBeats = playedBeats + action.beats
          preciseWait(math.max(0.001, waitTime))
        end
      elseif action.type == "pressnote" then
        local map = noteMappings[action.note]
        if map and map[action.octave] then
          local ch = map[action.octave]
          local kc = KeyMap[ch]
          if kc then pressKey(kc, ShiftKeys[ch] or false, ch, isShort) end
        end
        if not isShort and action.beats then
          local waitTime = (action.beats / bpm) * 60 / effSpeed
          if Config.ErrorMargin > 0 then
            waitTime = waitTime + (math.random() * 2 - 1) * (Config.ErrorMargin / 2)
          end
          playedBeats = playedBeats + action.beats
          preciseWait(math.max(0.001, waitTime))
        end
      elseif action.type == "rest" then
        local waitTime = (action.beats / bpm) * 60 / effSpeed
        if Config.ErrorMargin > 0 then
          waitTime = waitTime + (math.random() * 2 - 1) * (Config.ErrorMargin / 2)
        end
        playedBeats = playedBeats + (action.beats or 0)
        preciseWait(math.max(0.001, waitTime))
      elseif action.type == "adjustVelocity" then
        adjustVelocity(action.vel)
      elseif action.type == "pedalDown" then
        pedalDown()
      elseif action.type == "pedalUp" then
        pedalUp()
      end

      State.currentNote = ai
      State.progress    = ai / #actions
      ai = ai + 1

      if ai % 24 == 0 then
        RunService.Heartbeat:Wait()
      end
    end
    releaseAllKeys()
    return
  end

  -- ═══ MODO 2: FORMATO KEYPRESS (AGENDAMENTO ABSOLUTO SEM DRIFT) ═══
  local tokens = parseSequence(song.sequence, song._compress_dashes)
  local dashStep = song._dash_step or Config.DashStep
  State.totalNotes  = #tokens
  State.currentNote = 0
  State.progress    = 0
  State.seekTarget  = nil
  if #tokens == 0 then return end

  local startClock  = os.clock()
  local virtualTime = 0
  local catchUp     = 0
  local ti          = 1

  while ti <= #tokens and State.isPlaying do
    while State.isPaused do
      releaseAllKeys()
      task.wait(0.03)
      if not State.isPlaying then return end
      startClock = os.clock() - virtualTime
    end

    if State.seekTarget then
      local targetIdx = math.clamp(math.floor(State.seekTarget * #tokens), 1, #tokens)
      State.seekTarget = nil
      releaseAllKeys()
      ti = targetIdx
      virtualTime = 0
      startClock = os.clock()
    end

    local token = tokens[ti]
    local step  = baseStep(song)
    local keyPressIsShort = Config.ShortNotesEnabled

    State.totalSec   = #tokens * step
    State.elapsedSec = ti * step

    local fired = false
    if token.type == "note" then
      pressKey(token.key, token.shift, token.char, keyPressIsShort)
      virtualTime = virtualTime + step
      fired = true
    elseif token.type == "chord" then
      playChord(token.keys, keyPressIsShort, token.display)
      virtualTime = virtualTime + step
      fired = true
    elseif token.type == "dash" then
      virtualTime = virtualTime + step * dashStep
    elseif token.type == "space" then
      virtualTime = virtualTime + step * Config.SpaceStep
    end

    local jit = 0
    if fired and (Config.HumanizeEnabled or Config.ErrorMargin > 0) then
      local margin = math.max(Config.HumanizeEnabled and Config.HumanizeJitter or 0, Config.ErrorMargin)
      jit = (math.random() * 2 - 1) * margin
    end

    State.currentNote = ti
    State.progress    = ti / #tokens

    local target = startClock + virtualTime + jit
    local now    = os.clock()
    if now < target then
      catchUp = 0
      local remaining = target - now
      if Config.SecondaryLoader then
        preciseWait(remaining)
      else
        if remaining > 0.03 then task.wait(remaining - 0.012) end
        while os.clock() < target do
          if not State.isPlaying then break end
          RunService.Heartbeat:Wait()
        end
      end
    else
      catchUp = catchUp + 1
      if catchUp >= 24 then
        catchUp = 0
        RunService.Heartbeat:Wait()
      end
    end

    ti = ti + 1
  end
  releaseAllKeys()
end

-- ══════════════════════════════════════════════════════════════
--  CONTROLES DE TRANSPORTE & NAVEGAÇÃO SEGURA
-- ══════════════════════════════════════════════════════════════
local refreshNowPlaying, refreshList, refreshQueueModal

local function getRandomPlayable()
  if #PlayableIdx == 0 then return 1 end
  return PlayableIdx[math.random(1, #PlayableIdx)]
end

local function getNextPlayable(currentIdx, dir)
  if #PlayableIdx == 0 then return 1 end
  local pos = PlayableLookup[currentIdx]
  if not pos then
    return PlayableIdx[1]
  end
  local nextPos = ((pos - 1 + dir) % #PlayableIdx) + 1
  return PlayableIdx[nextPos]
end

local function stopPlayback()
  State.isPlaying   = false
  State.isPaused    = false
  State.progress    = 0
  State.currentNote = 0
  State.elapsedSec  = 0
  State.seekTarget  = nil
  releaseAllKeys()
  if State.playThread then
    pcall(function() task.cancel(State.playThread) end)
    State.playThread = nil
  end
end

local function startPlayback()
  if State.isPlaying then return end
  State.isPlaying = true
  State.isPaused  = false
  State.playThread = task.spawn(function()
    repeat
      playSong(State.currentSong)
      if State.isPlaying then
        if State.loopEnabled then
          -- Repete a mesma música
        elseif #State.queue > 0 then
          State.currentSong = table.remove(State.queue, 1)
          if refreshQueueModal then pcall(refreshQueueModal) end
        elseif not State.autoNext then
          State.isPlaying = false
        elseif State.shuffleEnabled then
          State.currentSong = getRandomPlayable()
        else
          State.currentSong = getNextPlayable(State.currentSong, 1)
        end
        if State.isPlaying then
          if refreshNowPlaying then pcall(refreshNowPlaying) end
          if refreshList then pcall(refreshList) end
        end
      end
    until not State.isPlaying
    State.isPlaying = false
    releaseAllKeys()
    if refreshNowPlaying then pcall(refreshNowPlaying) end
  end)
end

local function pauseResume()
  if not State.isPlaying then
    startPlayback()
  else
    State.isPaused = not State.isPaused
    if State.isPaused then releaseAllKeys() end
  end
end

local function nextSong()
  stopPlayback()
  if #State.queue > 0 then
    State.currentSong = table.remove(State.queue, 1)
    if refreshQueueModal then pcall(refreshQueueModal) end
  elseif State.shuffleEnabled then
    State.currentSong = getRandomPlayable()
  else
    State.currentSong = getNextPlayable(State.currentSong, 1)
  end
end

local function prevSong()
  stopPlayback()
  State.currentSong = getNextPlayable(State.currentSong, -1)
end

local function playIndex(idx, autoNext)
  if not Songs[idx] then return end
  stopPlayback()
  State.currentSong = idx
  if autoNext ~= nil then State.autoNext = autoNext and true or false end
  startPlayback()
end

-- Inicializa banco e índices
loadData()
rebuildIndexes()
if not Songs[State.currentSong] or Songs[State.currentSong].broken then
  State.currentSong = PlayableIdx[1] or 1
end

-- ══════════════════════════════════════════════════════════════
--  PALETA DE CORES — TRILLION AURORA v8.0 (OBSIDIAN GLASS)
-- ══════════════════════════════════════════════════════════════
local Theme = {
  bg          = Color3.fromRGB(5, 8, 15),
  bg2         = Color3.fromRGB(9, 14, 26),
  panel       = Color3.fromRGB(13, 20, 35),
  panel2      = Color3.fromRGB(19, 28, 48),
  panel3      = Color3.fromRGB(25, 36, 60),
  panelHi     = Color3.fromRGB(64, 88, 128),
  panelHover  = Color3.fromRGB(30, 44, 72),

  teal        = Color3.fromRGB(88, 230, 255),
  tealGlow    = Color3.fromRGB(160, 245, 255),
  amber       = Color3.fromRGB(168, 108, 255),
  amberGlow   = Color3.fromRGB(210, 178, 255),
  mint        = Color3.fromRGB(255, 208, 120),
  coral       = Color3.fromRGB(255, 102, 138),
  lime        = Color3.fromRGB(92, 238, 168),

  text        = Color3.fromRGB(244, 248, 255),
  sub         = Color3.fromRGB(152, 170, 198),
  muted       = Color3.fromRGB(96, 114, 146),

  FONT        = Enum.Font.GothamBold,
  FONTB       = Enum.Font.GothamBlack,
  FONTR       = Enum.Font.GothamMedium,
  FONTTITLE   = Enum.Font.GothamBlack,
}

-- ══════════════════════════════════════════════════════════════
--  HELPERS DE CONSTRUÇÃO DE INTERFACE
-- ══════════════════════════════════════════════════════════════
local UI = {}

local function mk(class, props, parent)
  local o = Instance.new(class)
  if props then
    for k, v in pairs(props) do o[k] = v end
  end
  if parent then o.Parent = parent end
  return o
end

local function corner(inst, r)
  return mk("UICorner", { CornerRadius = UDim.new(0, r or 10) }, inst)
end

local function stroke(inst, color, thick, trans)
  return mk("UIStroke", { Color = color or Theme.teal, Thickness = thick or 1.3, Transparency = trans or 0, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, inst)
end

local function gradient(inst, c1, c2, rot)
  return mk("UIGradient", { Color = ColorSequence.new(c1, c2), Rotation = rot or 0 }, inst)
end

local function pad(inst, p, ph)
  return mk("UIPadding", { PaddingTop = UDim.new(0, p), PaddingBottom = UDim.new(0, p), PaddingLeft = UDim.new(0, ph or p), PaddingRight = UDim.new(0, ph or p) }, inst)
end

local function hoverify(btn, normal, hover)
  local activeTween
  local function tweenTo(color)
    if activeTween then pcall(function() activeTween:Cancel() end) end
    activeTween = TweenService:Create(btn, TweenInfo.new(0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { BackgroundColor3 = color })
    activeTween:Play()
  end
  btn.MouseEnter:Connect(function() tweenTo(hover) end)
  btn.MouseLeave:Connect(function() tweenTo(normal) end)
end

local function clickPop(btn)
  local scale = btn:FindFirstChild("PressScale")
  if not scale then scale = mk("UIScale", { Name = "PressScale", Scale = 1 }, btn) end
  local currentTween
  local function go(value, duration, style)
    if currentTween then pcall(function() currentTween:Cancel() end) end
    currentTween = TweenService:Create(scale, TweenInfo.new(duration, style, Enum.EasingDirection.Out), { Scale = value })
    currentTween:Play()
  end
  btn.MouseButton1Down:Connect(function() go(0.95, 0.07, Enum.EasingStyle.Quad) end)
  local function release() go(1, 0.18, Enum.EasingStyle.Back) end
  btn.MouseButton1Up:Connect(release)
  btn.MouseLeave:Connect(release)
end

local function shadow(parent, transparency, spread)
  local amount = spread or 64
  return mk("ImageLabel", { Name = "PremiumShadow", Image = "rbxassetid://6015897843", ImageColor3 = Color3.fromRGB(0, 0, 0), ImageTransparency = transparency or 0.32, ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(47, 47, 450, 450), BackgroundTransparency = 1, Size = UDim2.new(1, amount, 1, amount), Position = UDim2.fromOffset(-amount / 2, -amount / 2 + 8), ZIndex = 0 }, parent)
end

local function playUISound(id, vol)
  if Config.MuteSFX then return end
  pcall(function()
    local s = Instance.new("Sound")
    s.SoundId = "rbxassetid://" .. tostring(id or 4961942590)
    s.Volume  = vol or 0.35
    s.Parent  = SoundService
    s:Play()
    task.delay(2.5, function() pcall(function() s:Destroy() end) end)
  end)
end

-- ══════════════════════════════════════════════════════════════
--  CRIAÇÃO DO SCREENGUI & CONTAINER PRINCIPAL
-- ══════════════════════════════════════════════════════════════
local function getGuiParent()
  local ok, hui = pcall(function() return gethui and gethui() end)
  if ok and hui then return hui end
  local ok2, cg = pcall(function() return game:GetService("CoreGui") end)
  if ok2 and cg then return cg end
  return LocalPlayer:WaitForChild("PlayerGui")
end

local guiParent = getGuiParent()
pcall(function()
  for _, g in ipairs(guiParent:GetChildren()) do
    if g.Name == "RimuruHub" then g:Destroy() end
  end
  local oldBlur = Lighting:FindFirstChild("ByRimuruTrillionBlur")
  if oldBlur then oldBlur:Destroy() end
end)

local ScreenGui = mk("ScreenGui", { Name = "RimuruHub", ResetOnSpawn = false, IgnoreGuiInset = true, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 9999 }, guiParent)

local HubBlur = mk("BlurEffect", { Name = "ByRimuruTrillionBlur", Size = 0 }, Lighting)
local function setBlurSize(sz)
  local target = Config.BlurEnabled and sz or 0
  TweenService:Create(HubBlur, TweenInfo.new(0.28, Enum.EasingStyle.Quart), { Size = target }):Play()
end
setBlurSize(12)

local Backdrop = mk("Frame", { Name = "CinematicBackdrop", Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(2, 4, 10), BackgroundTransparency = 0.32, BorderSizePixel = 0, ZIndex = 0 }, ScreenGui)
gradient(Backdrop, Color3.fromRGB(2, 6, 14), Color3.fromRGB(16, 8, 30), 125)

local function ambientOrb(size, position, color, transparency)
  return mk("ImageLabel", { Image = "rbxassetid://5028857084", ImageColor3 = color, ImageTransparency = transparency, BackgroundTransparency = 1, Size = UDim2.fromOffset(size, size), Position = position, AnchorPoint = Vector2.new(0.5, 0.5), ZIndex = 0 }, Backdrop)
end
local ambientA = ambientOrb(580, UDim2.fromScale(0.15, 0.20), Theme.teal, 0.85)
local ambientB = ambientOrb(680, UDim2.fromScale(0.85, 0.80), Theme.amber, 0.86)
TweenService:Create(ambientA, TweenInfo.new(7, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { Position = UDim2.fromScale(0.22, 0.28), ImageTransparency = 0.90, Rotation = 14 }):Play()
TweenService:Create(ambientB, TweenInfo.new(8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { Position = UDim2.fromScale(0.78, 0.72), ImageTransparency = 0.90, Rotation = -12 }):Play()

local WINDOW_SIZE = Vector2.new(880, 600)
local Root = mk("Frame", { Name = "Root", AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(WINDOW_SIZE.X, WINDOW_SIZE.Y), Position = UDim2.fromScale(0.5, 0.5), BackgroundColor3 = Theme.bg, BackgroundTransparency = 0.03, BorderSizePixel = 0, ClipsDescendants = false, ZIndex = 2 }, ScreenGui)
corner(Root, 22)
shadow(Root, 0.26, 90)

local RootScale = mk("UIScale", { Name = "ResponsiveScale", Scale = 1 }, Root)
local function updateResponsiveScale()
  local camera = workspace.CurrentCamera
  local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
  local sx = math.max((viewport.X - 24) / WINDOW_SIZE.X, 0.45)
  local sy = math.max((viewport.Y - 24) / WINDOW_SIZE.Y, 0.45)
  RootScale.Scale = math.min(sx, sy, 1)
end
updateResponsiveScale()
if workspace.CurrentCamera then
  trackConn(workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateResponsiveScale))
end

-- Wallpaper de fundo estilizado com scrim legível
local WallpaperBg = mk("ImageLabel", { Name = "WallpaperBg", Image = "rbxassetid://1724303458", ScaleType = Enum.ScaleType.Crop, BackgroundColor3 = Theme.bg2, BackgroundTransparency = 0, ImageTransparency = 0.58, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), ZIndex = 1 }, Root)
corner(WallpaperBg, 22)

local WallOverlay = mk("Frame", { BackgroundColor3 = Theme.bg2, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 0.10, ZIndex = 2 }, Root)
corner(WallOverlay, 22)
mk("UIGradient", {
  Rotation     = 0,
  Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0.0, 0.02), NumberSequenceKeypoint.new(0.6, 0.18), NumberSequenceKeypoint.new(1.0, 0.48) }),
}, WallOverlay)

local rootStroke = stroke(Root, Theme.teal, 1.6, 0.20)
gradient(rootStroke, Theme.teal, Theme.amber, 35)
TweenService:Create(rootStroke, TweenInfo.new(2.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { Transparency = 0.50 }):Play()

local ScanLine = mk("Frame", { Size = UDim2.new(1, 0, 0, 2), Position = UDim2.fromOffset(0, 0), BackgroundColor3 = Theme.teal, BackgroundTransparency = 0.62, BorderSizePixel = 0, ZIndex = 60 }, Root)
task.spawn(function()
  while Root and Root.Parent do
    ScanLine.Visible = Config.ScanlineEnabled
    if Config.ScanlineEnabled then
      ScanLine.Position = UDim2.new(0, 0, 0, 0)
      TweenService:Create(ScanLine, TweenInfo.new(3.8, Enum.EasingStyle.Linear), { Position = UDim2.new(0, 0, 1, -2) }):Play()
    end
    task.wait(4.0)
  end
end)

-- ══════════════════════════════════════════════════════════════
--  TOP BAR (BARRA SUPERIOR)
-- ══════════════════════════════════════════════════════════════
local TopBar = mk("Frame", { Name = "TopBar", Size = UDim2.new(1, 0, 0, 62), BackgroundColor3 = Theme.bg2, BackgroundTransparency = 0.14, BorderSizePixel = 0, ZIndex = 5 }, Root)
corner(TopBar, 22)

-- Linha de brilho inferior da TopBar
local topDivider = mk("Frame", { Size = UDim2.new(1, -24, 0, 1), Position = UDim2.new(0, 12, 1, -1), BackgroundColor3 = Theme.teal, BackgroundTransparency = 0.45, BorderSizePixel = 0, ZIndex = 6 }, TopBar)
gradient(topDivider, Theme.teal, Theme.amber, 0)

-- Monograma da Marca + Títulos à esquerda/centro
local BrandBadge = mk("TextLabel", { Text = "BR", Font = Theme.FONTB, TextSize = 16, TextColor3 = Theme.bg, BackgroundColor3 = Theme.teal, Size = UDim2.fromOffset(38, 38), Position = UDim2.fromOffset(14, 12), BorderSizePixel = 0, ZIndex = 6 }, TopBar)
corner(BrandBadge, 11)
gradient(BrandBadge, Theme.teal, Theme.amber, 35)

local TitleLabel = mk("TextLabel", { Text = BRAND.title .. "  //  " .. BRAND.subtitle, Font = Theme.FONTTITLE, TextSize = 18, BackgroundTransparency = 1, Size = UDim2.fromOffset(320, 22), Position = UDim2.fromOffset(62, 11), TextColor3 = Theme.text, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6 }, TopBar)
gradient(TitleLabel, Theme.text, Theme.tealGlow, 15)

local SubTitleLabel = mk("TextLabel", { Text = BRAND.author .. "  •  v" .. BRAND.version, Font = Theme.FONTR, TextSize = 11, BackgroundTransparency = 1, Size = UDim2.fromOffset(320, 16), Position = UDim2.fromOffset(62, 33), TextColor3 = Theme.sub, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6 }, TopBar)

-- Pill ao vivo mostrando a última tecla/acorde tocado + FPS
local LiveMonitorPill = mk("Frame", { Size = UDim2.fromOffset(176, 34), Position = UDim2.new(0.5, -40, 0, 14), BackgroundColor3 = Theme.panel, BackgroundTransparency = 0.12, BorderSizePixel = 0, ZIndex = 6 }, TopBar)
corner(LiveMonitorPill, 10)
stroke(LiveMonitorPill, Theme.panelHi, 1, 0.35)

UI.liveKeyLabel = mk("TextLabel", { Text = "🎹 Tecla: —", Font = Theme.FONT, TextSize = 12, BackgroundTransparency = 1, Size = UDim2.new(0.58, 0, 1, 0), Position = UDim2.fromOffset(10, 0), TextColor3 = Theme.tealGlow, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 7 }, LiveMonitorPill)

UI.fpsLabel = mk("TextLabel", { Text = "60 FPS", Font = Theme.FONT, TextSize = 11, BackgroundTransparency = 1, Size = UDim2.new(0.42, -10, 1, 0), Position = UDim2.new(0.58, 0, 0, 0), TextColor3 = Theme.lime, TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 7 }, LiveMonitorPill)

-- Botões de utilidade no canto direito da TopBar
local function topIconBtn(txt, rightOffset, textColor, width)
  local w = width or 34
  local b = mk("TextButton", { Text = txt, Size = UDim2.fromOffset(w, 32), Position = UDim2.new(1, -rightOffset, 0, 15), BackgroundColor3 = Theme.panel, AutoButtonColor = false, Font = Theme.FONTB, TextSize = 14, TextColor3 = textColor or Theme.text, BorderSizePixel = 0, ZIndex = 6 }, TopBar)
  corner(b, 9)
  stroke(b, Theme.panelHi, 1, 0.3)
  hoverify(b, Theme.panel, Theme.panelHover)
  clickPop(b)
  return b
end

local CloseBtn     = topIconBtn("✕", 48, Theme.coral)
local MinBtn       = topIconBtn("—", 86, Theme.amberGlow)
UI.helpBtn         = topIconBtn("?", 124, Theme.mint)
UI.langBtn         = topIconBtn("🌐", 162, Theme.teal)
UI.topQueueBtn     = topIconBtn("≣ 0", 220, Theme.amberGlow, 52)

-- ══════════════════════════════════════════════════════════════
--  CORPO PRINCIPAL (3 COLUNAS)
-- ══════════════════════════════════════════════════════════════
local Body = mk("Frame", { Name = "Body", BackgroundTransparency = 1, Size = UDim2.new(1, -28, 1, -138), Position = UDim2.fromOffset(14, 68), ZIndex = 3 }, Root)

local function panel(name, size, posv, parent)
  local p = mk("Frame", { Name = name, Size = size, Position = posv, BackgroundColor3 = Theme.panel, BackgroundTransparency = 0.08, BorderSizePixel = 0, ZIndex = 3 }, parent or Body)
  corner(p, 16)
  local st = stroke(p, Theme.panelHi, 1, 0.38)
  gradient(st, Theme.teal, Theme.amber, 28)
  local g = gradient(p, Theme.panel, Theme.panel2, 115)
  g.Transparency = NumberSequence.new(0.06)
  return p
end

-- ───────────── 1. SIDEBAR ESQUERDA (CATEGORIAS & FILTROS) ─────────────
local SideBar = panel("SideBar", UDim2.new(0, 174, 1, 0), UDim2.fromOffset(0, 0))
mk("TextLabel", { Text = "BIBLIOTECA  /  FILTROS", Font = Theme.FONTB, TextSize = 11, BackgroundTransparency = 1, Size = UDim2.new(1, -20, 0, 24), Position = UDim2.fromOffset(10, 8), TextColor3 = Theme.mint, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 4 }, SideBar)

local CatScroll = mk("ScrollingFrame", { Size = UDim2.new(1, -12, 1, -40), Position = UDim2.fromOffset(6, 34), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3, ScrollBarImageColor3 = Theme.teal, CanvasSize = UDim2.fromOffset(0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ZIndex = 4 }, SideBar)
mk("UIListLayout", { Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder }, CatScroll)

local activeCategory = nil

-- ───────────── 2. COLUNA CENTRAL (BUSCA + LISTA DE MÚSICAS) ─────────────
local Center = mk("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, -174 - 248 - 20, 1, 0), Position = UDim2.fromOffset(184, 0), ZIndex = 3 }, Body)

local SearchWrap = mk("Frame", { Size = UDim2.new(1, -44, 0, 36), BackgroundColor3 = Theme.panel, BorderSizePixel = 0, ZIndex = 4 }, Center)
corner(SearchWrap, 10)
stroke(SearchWrap, Theme.panelHi, 1, 0.28)

local SearchBox = mk("TextBox", {
  PlaceholderText        = "🔍 Pesquisar músicas, animes ou categorias...",
  Text                   = "",
  Size                   = UDim2.new(1, -34, 1, 0),
  Position               = UDim2.fromOffset(10, 0),
  BackgroundTransparency = 1,
  Font                   = Theme.FONTR,
  TextSize               = 13,
  TextColor3             = Theme.text,
  PlaceholderColor3      = Theme.sub,
  BorderSizePixel        = 0,
  ClearTextOnFocus       = false,
  TextXAlignment         = Enum.TextXAlignment.Left,
  ZIndex                 = 5,
}, SearchWrap)

local ClearSearchBtn = mk("TextButton", { Text = "✕", Size = UDim2.fromOffset(24, 24), Position = UDim2.new(1, -28, 0.5, -12), BackgroundTransparency = 1, Font = Theme.FONTB, TextSize = 12, TextColor3 = Theme.sub, Visible = false, ZIndex = 5 }, SearchWrap)
ClearSearchBtn.MouseButton1Click:Connect(function()
  SearchBox.Text = ""
end)

local CustomBtn = mk("TextButton", { Text = "+", Size = UDim2.fromOffset(38, 36), Position = UDim2.new(1, -38, 0, 0), BackgroundColor3 = Theme.panel2, AutoButtonColor = false, Font = Theme.FONTB, TextSize = 20, TextColor3 = Theme.amberGlow, BorderSizePixel = 0, ZIndex = 4 }, Center)
corner(CustomBtn, 10)
local cbStroke = stroke(CustomBtn, Theme.amberGlow, 1.4, 0.15)
gradient(cbStroke, Theme.amber, Theme.teal, 30)
hoverify(CustomBtn, Theme.panel2, Theme.panelHover)
clickPop(CustomBtn)

local ShuffleBtn = mk("TextButton", { Text = "🔀  SHUFFLE PLAY", Size = UDim2.new(0.5, -5, 0, 36), Position = UDim2.fromOffset(0, 42), BackgroundColor3 = Theme.panel2, AutoButtonColor = false, Font = Theme.FONT, TextSize = 13, TextColor3 = Theme.text, BorderSizePixel = 0, ZIndex = 4 }, Center)
corner(ShuffleBtn, 10)
local shStroke = stroke(ShuffleBtn, Theme.amber, 1.3, 0.15)
gradient(shStroke, Theme.amber, Theme.teal, 30)
hoverify(ShuffleBtn, Theme.panel2, Theme.panelHover)
clickPop(ShuffleBtn)

local RandomBtn = mk("TextButton", { Text = "🎲  DESCOBRIR RANDOM", Size = UDim2.new(0.5, -5, 0, 36), Position = UDim2.new(0.5, 5, 0, 42), BackgroundColor3 = Theme.panel2, AutoButtonColor = false, Font = Theme.FONT, TextSize = 13, TextColor3 = Theme.text, BorderSizePixel = 0, ZIndex = 4 }, Center)
corner(RandomBtn, 10)
local rdStroke = stroke(RandomBtn, Theme.mint, 1.3, 0.15)
gradient(rdStroke, Theme.mint, Theme.teal, 30)
hoverify(RandomBtn, Theme.panel2, Theme.panelHover)
clickPop(RandomBtn)

local ListPanel = panel("ListPanel", UDim2.new(1, 0, 1, -86), UDim2.fromOffset(0, 86), Center)
UI.listInfo = mk("TextLabel", { Text = "", Font = Theme.FONTR, TextSize = 11, BackgroundTransparency = 1, Size = UDim2.new(1, -16, 0, 18), Position = UDim2.fromOffset(10, 5), TextColor3 = Theme.sub, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 4 }, ListPanel)

local SongScroll = mk("ScrollingFrame", { Size = UDim2.new(1, -12, 1, -28), Position = UDim2.fromOffset(6, 25), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 4, ScrollBarImageColor3 = Theme.teal, CanvasSize = UDim2.fromOffset(0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ZIndex = 4 }, ListPanel)
mk("UIListLayout", { Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder }, SongScroll)

-- ───────────── 3. PAINEL DIREITO (HERO CARD, EQUALIZADOR, MINI-PIANO & CONTROLES) ─────────────
local Right = panel("Right", UDim2.new(0, 248, 1, 0), UDim2.new(1, -248, 0, 0))
pad(Right, 10)
mk("UIListLayout", { Padding = UDim.new(0, 7), SortOrder = Enum.SortOrder.LayoutOrder }, Right)

-- Hero Art Card com Equalizador Dinâmico de 12 Barras
local ArtCard = mk("Frame", { Name = "ArtCard", Size = UDim2.new(1, 0, 0, 152), BackgroundColor3 = Theme.panel2, BorderSizePixel = 0, ClipsDescendants = true, LayoutOrder = 1, ZIndex = 4 }, Right)
corner(ArtCard, 12)
local artStroke = stroke(ArtCard, Theme.amber, 1.5, 0.12)
gradient(artStroke, Theme.amber, Theme.teal, 45)

UI.artFallback = mk("Frame", { BackgroundColor3 = Theme.panel2, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), ZIndex = 4, Visible = true }, ArtCard)
corner(UI.artFallback, 12)
gradient(UI.artFallback, Theme.panel2, Theme.panel3, 125)
mk("TextLabel", { Text = "♪", Font = Theme.FONTB, TextSize = 42, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 48), Position = UDim2.fromOffset(0, 14), TextColor3 = Theme.tealGlow, ZIndex = 5 }, UI.artFallback)
mk("TextLabel", { Text = "arte visual\n(clique p/ trocar)", Font = Theme.FONTR, TextSize = 11, BackgroundTransparency = 1, Size = UDim2.new(1, -12, 0, 28), Position = UDim2.fromOffset(6, 60), TextColor3 = Theme.sub, ZIndex = 5 }, UI.artFallback)

UI.artImage = mk("ImageLabel", { Image = "", ScaleType = Enum.ScaleType.Crop, BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), ZIndex = 5 }, ArtCard)
corner(UI.artImage, 12)

local function tryLocalAsset(name)
  if not name or name == "" then return nil end
  local ok, a = pcall(function()
    if getcustomasset then return getcustomasset(name) end
    if getsynasset   then return getsynasset(name)   end
    return nil
  end)
  if ok then return a end
  return nil
end

local _artCache = {}
local function tryDownloadAsset(url)
  if not (url and url ~= "" and writefile) then return nil end
  if _artCache[url] then return _artCache[url] end
  local data
  pcall(function()
    local req = request or http_request or (syn and syn.request) or (http and http.request)
    if req then
      local r = req({ Url = url, Method = "GET" })
      data = r and (r.Body or r.body)
    end
  end)
  if not data then pcall(function() data = game:HttpGet(url) end) end
  if data and data ~= "" then
    local fname = "rimuru_art_" .. tostring(#_artCache) .. ".png"
    if pcall(function() writefile(fname, data) end) then
      local aid = tryLocalAsset(fname)
      if aid then _artCache[url] = aid; return aid end
    end
  end
  return nil
end

local function resolveArtId(id)
  if not id or id == "" then return nil end
  if id:find("^https?://") then return tryDownloadAsset(id) or id end
  return id
end

UI.setArt = function(id)
  if not (UI.artImage and id and id ~= "") then return end
  UI.artImage.Image = id
  task.spawn(function()
    pcall(function() ContentProvider:PreloadAsync({ UI.artImage }) end)
    task.wait(0.2)
    local loaded = false
    pcall(function() loaded = UI.artImage.IsLoaded end)
    if UI.artFallback then UI.artFallback.Visible = not loaded end
  end)
end

do
  local startId = (ART.url and tryDownloadAsset(ART.url)) or (ART.localFile and tryLocalAsset(ART.localFile)) or ART.asset
  UI.setArt(startId)
end

-- Scrim inferior + Equalizador de 12 barras no Hero Card
local scrim = mk("Frame", { Size = UDim2.new(1, 0, 0, 82), Position = UDim2.new(0, 0, 1, -82), BackgroundColor3 = Theme.bg, BorderSizePixel = 0, ZIndex = 6 }, ArtCard)
mk("UIGradient", {
  Rotation     = 90,
  Color        = ColorSequence.new(Theme.bg),
  Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.35, 0.35), NumberSequenceKeypoint.new(1, 0.06) }),
}, scrim)

-- Equalizador de espectro ao vivo (canto superior direito do ArtCard)
local EqHolder = mk("Frame", { Size = UDim2.fromOffset(76, 24), Position = UDim2.new(1, -84, 0, 8), BackgroundColor3 = Theme.bg, BackgroundTransparency = 0.32, BorderSizePixel = 0, ZIndex = 7 }, ArtCard)
corner(EqHolder, 6)
local eqBars = {}
for bi = 1, 10 do
  local bar = mk("Frame", { AnchorPoint = Vector2.new(0, 1), Size = UDim2.fromOffset(4, 4), Position = UDim2.new(0, 6 + (bi - 1) * 6.5, 1, -4), BackgroundColor3 = (bi % 2 =  = 0) and Theme.teal or Theme.amberGlow, BorderSizePixel = 0, ZIndex = 8 }, EqHolder)
  corner(bar, 2)
  eqBars[bi] = bar
end

mk("TextLabel", { Text = "♫ TOCANDO AGORA", Font = Theme.FONTB, TextSize = 10, BackgroundTransparency = 1, Size = UDim2.new(1, -16, 0, 14), Position = UDim2.new(0, 10, 1, -54), TextColor3 = Theme.teal, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 7 }, ArtCard)

UI.songName = mk("TextLabel", { Text = "—", Font = Theme.FONTB, TextSize = 14, BackgroundTransparency = 1, Size = UDim2.new(1, -16, 0, 20), Position = UDim2.new(0, 10, 1, -38), TextColor3 = Theme.text, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 7 }, ArtCard)

UI.bpmLabel = mk("TextLabel", { Text = "BPM —", Font = Theme.FONTR, TextSize = 11, BackgroundTransparency = 1, Size = UDim2.new(1, -16, 0, 14), Position = UDim2.new(0, 10, 1, -18), TextColor3 = Theme.amberGlow, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 7 }, ArtCard)

-- ───────────── VISUALIZADOR DE MINI-PIANO AO VIVO (18 TECLAS) ─────────────
local PianoStrip = mk("Frame", { Size = UDim2.new(1, 0, 0, 26), BackgroundColor3 = Theme.bg2, BorderSizePixel = 0, LayoutOrder = 2, ZIndex = 4 }, Right)
corner(PianoStrip, 7)
stroke(PianoStrip, Theme.panelHi, 1, 0.45)

local NUM_PIANO_KEYS = 18
local pianoKeyFrames = {}
for ki = 1, NUM_PIANO_KEYS do
  local kf = mk("Frame", { Size = UDim2.new(1 / NUM_PIANO_KEYS, -2, 1, -6), Position = UDim2.new((ki - 1) / NUM_PIANO_KEYS, 1, 0, 3), BackgroundColor3 = Theme.panel2, BorderSizePixel = 0, ZIndex = 5 }, PianoStrip)
  corner(kf, 3)
  pianoKeyFrames[ki] = kf
end

UI_PianoTrigger = function(chars)
  if not chars then return end
  for _, ch in ipairs(chars) do
    local pIdx = CharToPitchIndex[ch] or (( string.byte(ch) or 1 ) % #PianoOrder + 1)
    local slot = math.clamp(math.ceil((pIdx / #PianoOrder) * NUM_PIANO_KEYS), 1, NUM_PIANO_KEYS)
    local kf = pianoKeyFrames[slot]
    if kf then
      local activeColor = ShiftKeys[ch] and Theme.amber or Theme.teal
      kf.BackgroundColor3 = activeColor
      TweenService:Create(kf, TweenInfo.new(0.32, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = Theme.panel2 }):Play()
    end
  end
end

-- Botão Principal de Play/Pause
local PlayBtn = mk("TextButton", { Text = "▶  EXECUTAR MÚSICA", Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = Theme.teal, AutoButtonColor = false, Font = Theme.FONTB, TextSize = 14, TextColor3 = Theme.bg, BorderSizePixel = 0, LayoutOrder = 3, ZIndex = 4 }, Right)
corner(PlayBtn, 10)
gradient(PlayBtn, Theme.teal, Theme.amber, 35)
clickPop(PlayBtn)

-- Linha de Fila e Favorito
local IconRow = mk("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 34), LayoutOrder = 4, ZIndex = 4 }, Right)

local QueueBtn = mk("TextButton", { Text = "≣  + Fila", Size = UDim2.new(0.5, -4, 1, 0), BackgroundColor3 = Theme.panel2, AutoButtonColor = false, Font = Theme.FONT, TextSize = 12, TextColor3 = Theme.text, BorderSizePixel = 0, ZIndex = 4 }, IconRow)
corner(QueueBtn, 9)
stroke(QueueBtn, Theme.panelHi, 1, 0.35)
hoverify(QueueBtn, Theme.panel2, Theme.panelHover)
clickPop(QueueBtn)

UI.favBtn = mk("TextButton", { Text = "☆ Fav", Size = UDim2.new(0.5, -4, 1, 0), Position = UDim2.new(0.5, 4, 0, 0), BackgroundColor3 = Theme.panel2, AutoButtonColor = false, Font = Theme.FONT, TextSize = 12, TextColor3 = Theme.amberGlow, BorderSizePixel = 0, ZIndex = 4 }, IconRow)
corner(UI.favBtn, 9)
stroke(UI.favBtn, Theme.panelHi, 1, 0.35)
hoverify(UI.favBtn, Theme.panel2, Theme.panelHover)
clickPop(UI.favBtn)

-- Seletor de Velocidade / Modo
mk("TextLabel", { Text = "VELOCIDADE & MODO", Font = Theme.FONTB, TextSize = 10, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 14), TextColor3 = Theme.sub, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 5, ZIndex = 4 }, Right)

local SpeedRow = mk("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30), LayoutOrder = 6, ZIndex = 4 }, Right)
mk("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, SpeedRow)

UI.speedBtns = {}
local function updateSpeedBtnVisuals()
  for m, bb in pairs(UI.speedBtns) do
    local on = (m == State.mode)
    bb.BackgroundColor3 = on and Theme.teal or Theme.panel2
    bb.TextColor3       = on and Theme.bg or Theme.sub
  end
end

local function makeSpeedBtn(label, mode, order)
  local b = mk("TextButton", { Text = label, Size = UDim2.new(0.25, -3, 1, 0), BackgroundColor3 = Theme.panel2, AutoButtonColor = false, Font = Theme.FONT, TextSize = 10, TextColor3 = Theme.sub, BorderSizePixel = 0, LayoutOrder = order, ZIndex = 4 }, SpeedRow)
  corner(b, 8)
  stroke(b, Theme.panelHi, 1, 0.4)
  clickPop(b)
  b.MouseButton1Click:Connect(function()
    State.mode = mode
    updateSpeedBtnVisuals()
    playUISound(4961942590, 0.25)
  end)
  UI.speedBtns[mode] = b
  return b
end
makeSpeedBtn("Normal", "Normal", 1)
makeSpeedBtn("Night+", "Nightcore", 2)
makeSpeedBtn("Turbo",  "Turbo", 3)
makeSpeedBtn("Slow",   "Slowed", 4)
updateSpeedBtnVisuals()

-- Toggles rápidos: Loop, Auto, Config
local TglRow = mk("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30), LayoutOrder = 7, ZIndex = 4 }, Right)
mk("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, TglRow)

local function makeQuickToggle(label, getf, setf, order)
  local b = mk("TextButton", { Text = label, Size = UDim2.new(0.333, -3, 1, 0), BackgroundColor3 = Theme.panel2, AutoButtonColor = false, Font = Theme.FONT, TextSize = 11, TextColor3 = Theme.sub, BorderSizePixel = 0, LayoutOrder = order, ZIndex = 4 }, TglRow)
  corner(b, 8)
  stroke(b, Theme.panelHi, 1, 0.4)
  clickPop(b)
  local function refresh()
    local on = getf()
    b.BackgroundColor3 = on and Theme.mint or Theme.panel2
    b.TextColor3       = on and Theme.bg or Theme.sub
  end
  b.MouseButton1Click:Connect(function()
    setf(not getf())
    refresh()
  end)
  refresh()
  return b, refresh
end

local _, refreshLoopBtn = makeQuickToggle("🔁 Loop",
  function() return State.loopEnabled end,
  function(v) State.loopEnabled = v; if v then State.autoNext = true end end, 1)

local _, refreshAutoBtn = makeQuickToggle("🔀 Auto",
  function() return State.shuffleEnabled end,
  function(v) State.shuffleEnabled = v; if v then State.autoNext = true end end, 2)

local _, refreshCfgBtn = makeQuickToggle("⚙ Config",
  function() return UI.settingsOpen == true end,
  function(v)
    UI.settingsOpen = v
    if UI.toggleSettings then UI.toggleSettings(v) end
  end, 3)

-- ══════════════════════════════════════════════════════════════
--  BOTTOM BAR (BARRA DE PROGRESSO INTERATIVA / SEEK + TRANSPORTE)
-- ══════════════════════════════════════════════════════════════
local Bottom = mk("Frame", { Name = "Bottom", BackgroundTransparency = 1, Size = UDim2.new(1, -28, 0, 52), Position = UDim2.new(0, 14, 1, -60), ZIndex = 5 }, Root)

UI.nowText = mk("TextLabel", { Text = "Pronto.", Font = Theme.FONTR, TextSize = 12, BackgroundTransparency = 1, Size = UDim2.new(1, -280, 0, 18), Position = UDim2.fromOffset(0, 2), TextColor3 = Theme.sub, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 6 }, Bottom)

UI.timeLabel = mk("TextLabel", { Text = "00:00 / 00:00", Font = Theme.FONT, TextSize = 11, BackgroundTransparency = 1, Size = UDim2.fromOffset(90, 18), Position = UDim2.new(1, -276, 0, 2), TextColor3 = Theme.tealGlow, TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 6 }, Bottom)

-- Barra de Progresso Interativa (Suporta Clique e Arraste p/ Seek!)
local ProgHitbox = mk("TextButton", { Text = "", BackgroundTransparency = 1, AutoButtonColor = false, Size = UDim2.new(1, -186, 0, 20), Position = UDim2.fromOffset(0, 20), ZIndex = 7 }, Bottom)

local ProgBg = mk("Frame", { AnchorPoint = Vector2.new(0, 0.5), Size = UDim2.new(1, 0, 0, 7), Position = UDim2.fromScale(0, 0.5), BackgroundColor3 = Theme.panel, BorderSizePixel = 0, ZIndex = 6 }, ProgHitbox)
corner(ProgBg, 4)
stroke(ProgBg, Theme.panelHi, 1, 0.55)

UI.progFill = mk("Frame", { Size = UDim2.fromScale(0, 1), BackgroundColor3 = Theme.teal, BorderSizePixel = 0, ZIndex = 7 }, ProgBg)
corner(UI.progFill, 4)
gradient(UI.progFill, Theme.teal, Theme.amber, 0)

local ProgKnob = mk("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(12, 12), Position = UDim2.fromScale(1, 0.5), BackgroundColor3 = Theme.text, BorderSizePixel = 0, ZIndex = 8 }, UI.progFill)
corner(ProgKnob, 6)
stroke(ProgKnob, Theme.teal, 1.5, 0.1)

ProgHitbox.MouseEnter:Connect(function()
  TweenService:Create(ProgBg, TweenInfo.new(0.15), { Size = UDim2.new(1, 0, 0, 10) }):Play()
end)
ProgHitbox.MouseLeave:Connect(function()
  TweenService:Create(ProgBg, TweenInfo.new(0.15), { Size = UDim2.new(1, 0, 0, 7) }):Play()
end)

local seekingBar = false
local function updateSeekFromInput(px)
  local absX = ProgBg.AbsolutePosition.X
  local absW = math.max(1, ProgBg.AbsoluteSize.X)
  local rel = math.clamp((px - absX) / absW, 0, 1)
  State.progress   = rel
  State.seekTarget = rel
  UI.progFill.Size = UDim2.fromScale(rel, 1)
  if not State.isPlaying then
    startPlayback()
    State.seekTarget = rel
  end
end

ProgHitbox.InputBegan:Connect(function(i)
  if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
    seekingBar = true
    updateSeekFromInput(i.Position.X)
  end
end)

-- Botões de Transporte (Prev, Play/Pause, Stop, Next)
local TransRow = mk("Frame", { BackgroundTransparency = 1, Size = UDim2.fromOffset(172, 40), Position = UDim2.new(1, -172, 0, 6), ZIndex = 6 }, Bottom)
mk("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), HorizontalAlignment = Enum.HorizontalAlignment.Right, VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder }, TransRow)

local function transBtn(txt, color, order)
  local b = mk("TextButton", { Text = txt, Size = UDim2.fromOffset(38, 34), BackgroundColor3 = Theme.panel2, AutoButtonColor = false, Font = Theme.FONTB, TextSize = 15, TextColor3 = color or Theme.text, BorderSizePixel = 0, LayoutOrder = order, ZIndex = 6 }, TransRow)
  corner(b, 9)
  stroke(b, Theme.panelHi, 1, 0.35)
  hoverify(b, Theme.panel2, Theme.panelHover)
  clickPop(b)
  return b
end
local PrevBtn     = transBtn("⏮", Theme.mint, 1)
UI.playPauseBtn   = transBtn("⏯", Theme.teal, 2)
local StopBtn     = transBtn("⏹", Theme.coral, 3)
local NextBtn     = transBtn("⏭", Theme.mint, 4)

-- ══════════════════════════════════════════════════════════════
--  SISTEMA DE NOTIFICAÇÃO (TOAST ELEGANTE)
-- ══════════════════════════════════════════════════════════════
local function notify(text, color)
  if Config.DisableNotifs then return end
  local t = mk("TextLabel", { Text = "  " .. tostring(text) .. "  ", Font = Theme.FONT, TextSize = 13, TextColor3 = Color3.fromRGB(10, 14, 22), BackgroundColor3 = color or Theme.teal, Size = UDim2.fromOffset(20, 34), AutomaticSize = Enum.AutomaticSize.X, Position = UDim2.new(0.5, 0, 0, -50), AnchorPoint = Vector2.new(0.5, 0), BorderSizePixel = 0, ZIndex = 90 }, ScreenGui)
  corner(t, 10)
  pad(t, 8, 12)
  stroke(t, Color3.fromRGB(255, 255, 255), 1, 0.45)
  TweenService:Create(t, TweenInfo.new(0.32, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Position = UDim2.new(0.5, 0, 0, 18) }):Play()
  task.delay(2.3, function()
    pcall(function()
      TweenService:Create(t, TweenInfo.new(0.26, Enum.EasingStyle.Quad), { Position = UDim2.new(0.5, 0, 0, -50), TextTransparency = 1, BackgroundTransparency = 1 }):Play()
    end)
    task.delay(0.30, function() pcall(function() t:Destroy() end) end)
  end)
end

-- ══════════════════════════════════════════════════════════════
--  ATUALIZAÇÃO DE ESTADO VISUAL & LISTA DE MÚSICAS
-- ══════════════════════════════════════════════════════════════
local function curSong() return Songs[State.currentSong] end
local function isFav(idx) return State.favorites[tostring(idx)] == true end
local function toggleFav(idx)
  local k = tostring(idx)
  if State.favorites[k] then State.favorites[k] = nil else State.favorites[k] = true end
  saveData()
end

local function updateQueueBadge()
  if UI.topQueueBtn then
    UI.topQueueBtn.Text = "≣ " .. tostring(#State.queue)
    UI.topQueueBtn.TextColor3 = (#State.queue > 0) and Theme.teal or Theme.sub
  end
end

refreshNowPlaying = function()
  local s = curSong()
  if not s then return end
  if not s._prepared then prepareSong(s) end
  UI.songName.Text = (s.emoji or "♪") .. " " .. s.name
  local bpmShow = s._play_bpm or s.bpm or "—"
  local tag = s._midi2lua and " · M2L" or ""
  if s._bpm_fixed then tag = tag .. "*" end
  UI.bpmLabel.Text = "BPM " .. tostring(bpmShow) .. tag .. "   •   #" .. State.currentSong .. "/" .. #Songs

  local fav = isFav(State.currentSong)
  UI.favBtn.Text = fav and "★ Fav" or "☆ Fav"
  UI.favBtn.TextColor3 = fav and Theme.mint or Theme.sub

  if State.isPlaying and not State.isPaused then
    PlayBtn.Text = (State.lang == "en" and "⏸  PAUSE SONG") or (State.lang == "es" and "⏸  PAUSAR CANCIÓN") or "⏸  PAUSAR MÚSICA"
  elseif State.isPlaying and State.isPaused then
    PlayBtn.Text = (State.lang == "en" and "▶  RESUME SONG") or (State.lang == "es" and "▶  REANUDAR CANCIÓN") or "▶  RETOMAR MÚSICA"
  else
    PlayBtn.Text = (State.lang == "en" and "▶  PLAY SONG") or (State.lang == "es" and "▶  REPRODUCIR") or "▶  EXECUTAR MÚSICA"
  end

  if UI.miniTitle then
    UI.miniTitle.Text = (s.emoji or "♪") .. " " .. s.name
  end
  updateQueueBadge()
  if refreshLoopBtn then refreshLoopBtn() end
  if refreshAutoBtn then refreshAutoBtn() end
end

local MAX_LIST = 80
local buildCategories

local function buildFilteredIndices()
  local out = {}
  local q = string.lower(SearchBox.Text or "")
  local function passSearch(s)
    if q == "" then return true end
    local nMatch = string.find(string.lower(s.name or ""), q, 1, true)
    local cMatch = string.find(string.lower(s.category or ""), q, 1, true)
    return (nMatch ~= nil) or (cMatch ~= nil)
  end

  if activeCategory == "★ Favoritos" then
    for i = 1, #Songs do
      local s = Songs[i]
      if s and isFav(i) and not s.broken and passSearch(s) then out[#out+1] = i end
    end
  elseif activeCategory == "⭐ Custom" then
    for i = 1, #Songs do
      local s = Songs[i]
      if s and s.custom and passSearch(s) then out[#out+1] = i end
    end
  elseif activeCategory == "≣ Fila" then
    for _, qIdx in ipairs(State.queue) do
      local s = Songs[qIdx]
      if s and passSearch(s) then out[#out+1] = qIdx end
    end
  else
    for _, i in ipairs(PlayableIdx) do
      local s = Songs[i]
      if s and (activeCategory == nil or s.category == activeCategory) and passSearch(s) then
        out[#out+1] = i
      end
    end
  end
  return out
end

refreshList = function()
  for _, c in ipairs(SongScroll:GetChildren()) do
    if c:IsA("Frame") or c:IsA("TextButton") then c:Destroy() end
  end
  local idxs = buildFilteredIndices()
  local total = #idxs
  UI.listInfo.Text = (tr("songs")):format(total) .. (total > MAX_LIST and (tr("showing")):format(MAX_LIST) or "")

  for n = 1, math.min(total, MAX_LIST) do
    local i = idxs[n]
    local s = Songs[i]
    local isCurrent = (i == State.currentSong)
    local row = mk("Frame", { Size = UDim2.new(1, -4, 0, 42), BackgroundColor3 = isCurrent and Theme.panelHover or Theme.panel2, BorderSizePixel = 0, LayoutOrder = n, ZIndex = 4 }, SongScroll)
    corner(row, 10)
    stroke(row, isCurrent and Theme.teal or Theme.panelHi, 1, isCurrent and 0.12 or 0.55)

    if isCurrent then
      local rail = mk("Frame", { Size = UDim2.fromOffset(3, 24), Position = UDim2.fromOffset(4, 9), BackgroundColor3 = Theme.teal, BorderSizePixel = 0, ZIndex = 5 }, row)
      corner(rail, 2)
      gradient(rail, Theme.teal, Theme.amber, 90)
    end

    -- Botão principal clicável da linha
    local mainHit = mk("TextButton", { Text = "", BackgroundTransparency = 1, AutoButtonColor = false, Size = UDim2.new(1, -68, 1, 0), ZIndex = 5 }, row)

    mk("TextLabel", { Text = (s.emoji or "♪") .. "  " .. s.name, Font = isCurrent and Theme.FONTB or Theme.FONT, TextSize = 13, BackgroundTransparency = 1, Size = UDim2.new(1, -76, 0, 20), Position = UDim2.fromOffset(12, 4), TextColor3 = isCurrent and Theme.tealGlow or Theme.text, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 5 }, row)

    local bpmVal = s._play_bpm or s.bpm or 120
    local subMeta = (s.category or "Música") .. "  •  " .. tostring(bpmVal) .. " BPM" .. (s._midi2lua and " · M2L" or "")
    mk("TextLabel", { Text = subMeta, Font = Theme.FONTR, TextSize = 10, BackgroundTransparency = 1, Size = UDim2.new(1, -76, 0, 14), Position = UDim2.fromOffset(12, 23), TextColor3 = Theme.sub, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 5 }, row)

    -- Botão rápido de adicionar à fila (+)
    local qQuickBtn = mk("TextButton", { Text = "+", Size = UDim2.fromOffset(26, 26), Position = UDim2.new(1, -60, 0.5, -13), BackgroundColor3 = Theme.panel, AutoButtonColor = false, Font = Theme.FONTB, TextSize = 14, TextColor3 = Theme.teal, BorderSizePixel = 0, ZIndex = 6 }, row)
    corner(qQuickBtn, 7)
    qQuickBtn.MouseButton1Click:Connect(function()
      table.insert(State.queue, i)
      updateQueueBadge()
      if refreshQueueModal then pcall(refreshQueueModal) end
      notify("≣ + Fila: " .. s.name, Theme.teal)
    end)

    -- Botão rápido de favoritar (★/☆)
    local favQuickBtn = mk("TextButton", { Text = isFav(i) and "★" or "☆", Size = UDim2.fromOffset(26, 26), Position = UDim2.new(1, -30, 0.5, -13), BackgroundColor3 = Theme.panel, AutoButtonColor = false, Font = Theme.FONTB, TextSize = 13, TextColor3 = isFav(i) and Theme.mint or Theme.sub, BorderSizePixel = 0, ZIndex = 6 }, row)
    corner(favQuickBtn, 7)
    favQuickBtn.MouseButton1Click:Connect(function()
      toggleFav(i)
      favQuickBtn.Text = isFav(i) and "★" or "☆"
      favQuickBtn.TextColor3 = isFav(i) and Theme.mint or Theme.sub
      refreshNowPlaying()
      if activeCategory == "★ Favoritos" then refreshList() end
    end)

    mainHit.MouseButton1Click:Connect(function()
      playIndex(i, State.autoNext)
      refreshNowPlaying()
      refreshList()
      notify("▶ " .. s.name, Theme.teal)
    end)
  end
end

-- ══════════════════════════════════════════════════════════════
--  CATEGORIAS DA SIDEBAR
-- ══════════════════════════════════════════════════════════════
local function setCategory(cat)
  activeCategory = cat
  for _, c in ipairs(CatScroll:GetChildren()) do
    if c:IsA("TextButton") then
      local on = (c:GetAttribute("cat") == (cat or "__all__"))
      c.BackgroundColor3 = on and Theme.teal or Theme.panel2
      c.TextColor3       = on and Theme.bg or Theme.sub
    end
  end
  refreshList()
end

local function addCatBtn(label, catValue, count, order)
  local b = mk("TextButton", { Text = (count ~ = nil) and (label .. "  (" .. count .. ")") or label, Size = UDim2.new(1, -6, 0, 29), BackgroundColor3 = Theme.panel2, AutoButtonColor = false, Font = Theme.FONT, TextSize = 12, TextColor3 = Theme.sub, BorderSizePixel = 0, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = order, ZIndex = 4 }, CatScroll)
  corner(b, 8)
  stroke(b, Theme.panelHi, 1, 0.45)
  pad(b, 4, 8)
  b:SetAttribute("cat", catValue or "__all__")
  b.MouseButton1Click:Connect(function() setCategory(catValue) end)
  return b
end

buildCategories = function()
  for _, c in ipairs(CatScroll:GetChildren()) do
    if c:IsA("TextButton") then c:Destroy() end
  end
  local order = 1
  addCatBtn(tr("all"), nil, #PlayableIdx, order); order = order + 1
  local favCount = 0
  for k, v in pairs(State.favorites) do if v then favCount = favCount + 1 end end
  addCatBtn(tr("favs"), "★ Favoritos", favCount, order); order = order + 1
  addCatBtn(tr("queueCat"), "≣ Fila", #State.queue, order); order = order + 1

  local cc = 0
  for i = 1, #Songs do if Songs[i] and Songs[i].custom then cc = cc + 1 end end
  addCatBtn(tr("custom"), "⭐ Custom", cc, order); order = order + 1

  local sorted = {}
  for cat, n in pairs(CategoryCount) do sorted[#sorted+1] = { cat = cat, n = n } end
  table.sort(sorted, function(a, b) return a.n > b.n end)
  for _, e in ipairs(sorted) do
    if e.cat ~= "Custom" then
      addCatBtn(e.cat, e.cat, e.n, order)
      order = order + 1
    end
  end
end

-- ══════════════════════════════════════════════════════════════
--  SISTEMA DE TRADUÇÃO AUTOMÁTICA
-- ══════════════════════════════════════════════════════════════
local function walkTranslate()
  local map = trMap()
  local i = langIdx()
  for _, o in ipairs(ScreenGui:GetDescendants()) do
    if o:IsA("TextButton") or o:IsA("TextLabel") then
      local base = o:GetAttribute("trbase")
      if not base and map[o.Text] then
        base = o.Text
        o:SetAttribute("trbase", base)
      end
      if base and map[base] then
        o.Text = map[base][i]
      end
    elseif o:IsA("TextBox") then
      local base = o:GetAttribute("trbasePH")
      if not base and map[o.PlaceholderText] then
        base = o.PlaceholderText
        o:SetAttribute("trbasePH", base)
      end
      if base and map[base] then
        o.PlaceholderText = map[base][i]
      end
    end
  end
end

local function applyLang()
  walkTranslate()
  buildCategories()
  setCategory(activeCategory)
  refreshList()
  refreshNowPlaying()
  if refreshQueueModal then pcall(refreshQueueModal) end
end

-- ══════════════════════════════════════════════════════════════
--  MODAIS (SETTINGS, FILA, CUSTOM SONG, CRÉDITOS, IDIOMA)
-- ══════════════════════════════════════════════════════════════
local function makeModal(titleText, w, h, onClose)
  local f = mk("Frame", { Size = UDim2.fromOffset(w, h), Position = UDim2.new(0.5, -w / 2, 0.5, -h / 2), BackgroundColor3 = Theme.bg2, BorderSizePixel = 0, Visible = false, ZIndex = 30 }, Root)
  corner(f, 18)
  shadow(f, 0.30, 62)
  local st = stroke(f, Theme.teal, 1.5, 0.14)
  gradient(st, Theme.teal, Theme.amber, 45)
  gradient(f, Theme.bg2, Theme.panel, 120)

  mk("TextLabel", { Text = titleText, Font = Theme.FONTB, TextSize = 15, BackgroundTransparency = 1, Size = UDim2.new(1, -48, 0, 32), Position = UDim2.fromOffset(16, 8), TextColor3 = Theme.text, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 31 }, f)

  local x = mk("TextButton", { Text = "✕", Size = UDim2.fromOffset(28, 26), Position = UDim2.new(1, -38, 0, 10), BackgroundColor3 = Theme.panel, AutoButtonColor = false, Font = Theme.FONTB, TextSize = 13, TextColor3 = Theme.coral, BorderSizePixel = 0, ZIndex = 31 }, f)
  corner(x, 8)
  clickPop(x)
  x.MouseButton1Click:Connect(function()
    f.Visible = false
    if onClose then onClose() end
  end)
  return f
end

-- ───────────── 1. MODAL DE CONFIGURAÇÕES COMPLETO (COM SCROLL & SLIDERS) ─────────────
UI.settings = makeModal("⚙  Configurações do Motor & UI", 390, 410, function()
  UI.settingsOpen = false
  if refreshCfgBtn then refreshCfgBtn() end
end)

do
  local cfgScroll = mk("ScrollingFrame", { Size = UDim2.new(1, -20, 1, -54), Position = UDim2.fromOffset(10, 44), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 4, ScrollBarImageColor3 = Theme.teal, CanvasSize = UDim2.fromOffset(0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ZIndex = 31 }, UI.settings)
  mk("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, cfgScroll)
  pad(cfgScroll, 4, 6)

  local order = 1
  local function addCfgToggle(label, getf, setf)
    local row = mk("Frame", { BackgroundColor3 = Theme.panel, BackgroundTransparency = 0.25, Size = UDim2.new(1, -6, 0, 34), LayoutOrder = order, ZIndex = 31 }, cfgScroll)
    corner(row, 8)
    order = order + 1

    mk("TextLabel", { Text = label, Font = Theme.FONTR, TextSize = 12, BackgroundTransparency = 1, Size = UDim2.new(1, -64, 1, 0), Position = UDim2.fromOffset(10, 0), TextColor3 = Theme.text, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 32 }, row)

    local b = mk("TextButton", { Text = "", Size = UDim2.fromOffset(44, 22), Position = UDim2.new(1, -52, 0.5, -11), BackgroundColor3 = Theme.panel2, BorderSizePixel = 0, AutoButtonColor = false, ZIndex = 32 }, row)
    corner(b, 11)

    local knob = mk("Frame", { Size = UDim2.fromOffset(16, 16), Position = UDim2.fromOffset(3, 3), BackgroundColor3 = Theme.sub, BorderSizePixel = 0, ZIndex = 33 }, b)
    corner(knob, 8)

    local function refresh()
      local on = getf()
      TweenService:Create(b, TweenInfo.new(0.15), { BackgroundColor3 = on and Theme.lime or Theme.panel2 }):Play()
      TweenService:Create(knob, TweenInfo.new(0.15), { Position = on and UDim2.fromOffset(25, 3) or UDim2.fromOffset(3, 3), BackgroundColor3 = on and Theme.bg or Theme.sub }):Play()
    end
    b.MouseButton1Click:Connect(function()
      setf(not getf())
      syncConfigToSettings()
      refresh()
    end)
    refresh()
  end

  local function addCfgSlider(label, minV, maxV, fmtStr, getf, setf)
    local wrap = mk("Frame", { BackgroundColor3 = Theme.panel, BackgroundTransparency = 0.25, Size = UDim2.new(1, -6, 0, 50), LayoutOrder = order, ZIndex = 31 }, cfgScroll)
    corner(wrap, 8)
    order = order + 1

    mk("TextLabel", { Text = label, Font = Theme.FONTR, TextSize = 12, BackgroundTransparency = 1, Size = UDim2.new(1, -80, 0, 20), Position = UDim2.fromOffset(10, 4), TextColor3 = Theme.text, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 32 }, wrap)

    local valLbl = mk("TextLabel", { Text = fmtStr:format(getf()), Font = Theme.FONT, TextSize = 12, BackgroundTransparency = 1, Size = UDim2.fromOffset(68, 20), Position = UDim2.new(1, -76, 0, 4), TextColor3 = Theme.tealGlow, TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 32 }, wrap)

    local sb = mk("TextButton", { Text = "", AutoButtonColor = false, Size = UDim2.new(1, -20, 0, 8), Position = UDim2.fromOffset(10, 32), BackgroundColor3 = Theme.panel2, BorderSizePixel = 0, ZIndex = 32 }, wrap)
    corner(sb, 4)

    local initRel = math.clamp((getf() - minV) / (maxV - minV), 0, 1)
    local fill = mk("Frame", { Size = UDim2.fromScale(initRel, 1), BackgroundColor3 = Theme.teal, BorderSizePixel = 0, ZIndex = 33 }, sb)
    corner(fill, 4)
    gradient(fill, Theme.teal, Theme.amber, 0)

    local dragging = false
    local function setFromX(px)
      local rel = math.clamp((px - sb.AbsolutePosition.X) / math.max(1, sb.AbsoluteSize.X), 0, 1)
      local v = minV + rel * (maxV - minV)
      setf(v)
      syncConfigToSettings()
      fill.Size = UDim2.fromScale(rel, 1)
      valLbl.Text = fmtStr:format(v)
    end

    sb.InputBegan:Connect(function(i)
      if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        setFromX(i.Position.X)
      end
    end)
    trackConn(UserInputService.InputChanged:Connect(function(i)
      if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        setFromX(i.Position.X)
      end
    end))
    trackConn(UserInputService.InputEnded:Connect(function(i)
      if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        dragging = false
      end
    end))
  end

  addCfgToggle("⚡ SecondaryLoader (Precisão Sub-Frame)",
    function() return Config.SecondaryLoader end,
    function(v) Config.SecondaryLoader = v end)

  addCfgToggle("🎵 Notas Curtas (Estaccato Natural)",
    function() return Config.ShortNotesEnabled end,
    function(v) Config.ShortNotesEnabled = v end)

  addCfgToggle("🖱️ Modo Mouse (Clicar Teclas na Tela)",
    function() return Config.MouseClickEnabled end,
    function(v) Config.MouseClickEnabled = v; MouseMap = nil end)

  addCfgToggle("✨ Humanize (Micro-variação Humana)",
    function() return Config.HumanizeEnabled end,
    function(v) Config.HumanizeEnabled = v end)

  addCfgToggle("🛡️ Anti-Lag (Proteção de FPS)",
    function() return Config.AntiLagEnabled end,
    function(v) Config.AntiLagEnabled = v end)

  addCfgToggle("⏭️ Auto-Next (Avançar Automático)",
    function() return State.autoNext end,
    function(v) State.autoNext = v end)

  addCfgToggle("🌊 Efeito Scanline & Blur Cinematográfico",
    function() return Config.ScanlineEnabled end,
    function(v)
      Config.ScanlineEnabled = v
      Config.BlurEnabled = v
      setBlurSize(Root.Visible and 12 or 0)
    end)

  addCfgToggle("🔇 Silenciar Sons da Interface (SFX)",
    function() return Config.MuteSFX end,
    function(v) Config.MuteSFX = v end)

  addCfgSlider("Velocidade Global", Config.MinSpeed, Config.MaxSpeed, "%.2fx",
    function() return State.speed end,
    function(v) State.speed = v end)

  addCfgSlider("Sustentação da Nota (Key Hold)", 0.02, 0.20, "%.3fs",
    function() return Config.KeyHold end,
    function(v) Config.KeyHold = v end)

  addCfgSlider("Margem de Erro Humana (Jitter)", 0.000, 0.040, "%.3fs",
    function() return Config.ErrorMargin end,
    function(v) Config.ErrorMargin = v end)
end

UI.toggleSettings = function(v)
  UI.settings.Visible = v and true or false
  if refreshCfgBtn then refreshCfgBtn() end
end

-- ───────────── 2. MODAL GERENCIADOR DE FILA (QUEUE) ─────────────
UI.queueModal = makeModal("≣  Fila de Reprodução", 360, 320)
do
  local clearBtn = mk("TextButton", { Text = "🗑 Limpar Fila", Size = UDim2.fromOffset(104, 26), Position = UDim2.new(1, -148, 0, 10), BackgroundColor3 = Theme.panel2, AutoButtonColor = false, Font = Theme.FONT, TextSize = 11, TextColor3 = Theme.coral, BorderSizePixel = 0, ZIndex = 32 }, UI.queueModal)
  corner(clearBtn, 8)
  stroke(clearBtn, Theme.coral, 1, 0.45)
  clickPop(clearBtn)

  local qScroll = mk("ScrollingFrame", { Size = UDim2.new(1, -24, 1, -54), Position = UDim2.fromOffset(12, 44), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 4, ScrollBarImageColor3 = Theme.teal, CanvasSize = UDim2.fromOffset(0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ZIndex = 31 }, UI.queueModal)
  mk("UIListLayout", { Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder }, qScroll)

  refreshQueueModal = function()
    for _, c in ipairs(qScroll:GetChildren()) do
      if c:IsA("Frame") or c:IsA("TextLabel") then c:Destroy() end
    end
    updateQueueBadge()
    buildCategories()
    setCategory(activeCategory)

    if #State.queue == 0 then
      mk("TextLabel", { Text = tr("queueEmpty"), Font = Theme.FONTR, TextSize = 12, BackgroundTransparency = 1, Size = UDim2.new(1, -16, 0, 80), Position = UDim2.fromOffset(8, 20), TextColor3 = Theme.sub, TextWrapped = true, ZIndex = 32 }, qScroll)
      return
    end

    for qi, sIdx in ipairs(State.queue) do
      local s = Songs[sIdx]
      if s then
        local row = mk("Frame", { Size = UDim2.new(1, -4, 0, 34), BackgroundColor3 = Theme.panel, BorderSizePixel = 0, LayoutOrder = qi, ZIndex = 32 }, qScroll)
        corner(row, 8)

        local playHit = mk("TextButton", { Text = tostring(qi) .. ".  " .. (s.emoji or "♪") .. " " .. s.name, Font = Theme.FONT, TextSize = 12, TextColor3 = Theme.text, BackgroundTransparency = 1, Size = UDim2.new(1, -40, 1, 0), Position = UDim2.fromOffset(10, 0), TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 33 }, row)

        local remBtn = mk("TextButton", { Text = "✕", Size = UDim2.fromOffset(24, 24), Position = UDim2.new(1, -28, 0.5, -12), BackgroundColor3 = Theme.panel2, AutoButtonColor = false, Font = Theme.FONTB, TextSize = 11, TextColor3 = Theme.coral, BorderSizePixel = 0, ZIndex = 33 }, row)
        corner(remBtn, 6)

        playHit.MouseButton1Click:Connect(function()
          table.remove(State.queue, qi)
          playIndex(sIdx, true)
          refreshNowPlaying()
          refreshList()
          refreshQueueModal()
        end)

        remBtn.MouseButton1Click:Connect(function()
          table.remove(State.queue, qi)
          refreshQueueModal()
        end)
      end
    end
  end

  clearBtn.MouseButton1Click:Connect(function()
    State.queue = {}
    refreshQueueModal()
    notify("🗑 Fila limpa!", Theme.coral)
  end)
end

UI.topQueueBtn.MouseButton1Click:Connect(function()
  refreshQueueModal()
  UI.queueModal.Visible = not UI.queueModal.Visible
end)

-- ───────────── 3. MODAL ESTÚDIO DE MÚSICA CUSTOM ─────────────
UI.custom = makeModal("⭐  Estúdio de Música Custom", 360, 290)
do
  local function field(ph, y, h)
    local t = mk("TextBox", {
      PlaceholderText   = ph,
      Text              = "",
      Size              = UDim2.new(1, -28, 0, h or 34),
      Position          = UDim2.fromOffset(14, y),
      BackgroundColor3  = Theme.panel,
      Font              = Theme.FONTR,
      TextSize          = 12,
      TextColor3        = Theme.text,
      PlaceholderColor3 = Theme.sub,
      BorderSizePixel   = 0,
      ClearTextOnFocus  = false,
      TextXAlignment    = Enum.TextXAlignment.Left,
      TextYAlignment    = Enum.TextYAlignment.Top,
      MultiLine         = (h ~= nil),
      ZIndex            = 31,
    }, UI.custom)
    corner(t, 9)
    stroke(t, Theme.panelHi, 1, 0.3)
    pad(t, 8)
    return t
  end
  local nameBox  = field("Nome da música (ex: Minha Partitura)", 46)
  local bpmBox   = field("BPM (ex: 150) — ou deixe vazio p/ auto-detectar", 86)
  local notesBox = field("Cole a sequência Virtual Piano (q w [qe] -) ou script MIDI2LUA", 126, 82)

  local saveBtn = mk("TextButton", { Text = "✓ SALVAR & TOCAR AGORA", Size = UDim2.new(1, -28, 0, 40), Position = UDim2.fromOffset(14, 232), BackgroundColor3 = Theme.teal, AutoButtonColor = false, Font = Theme.FONTB, TextSize = 14, TextColor3 = Theme.bg, BorderSizePixel = 0, ZIndex = 31 }, UI.custom)
  corner(saveBtn, 10)
  gradient(saveBtn, Theme.teal, Theme.amber, 35)
  clickPop(saveBtn)

  saveBtn.MouseButton1Click:Connect(function()
    local nm = nameBox.Text
    local sq = notesBox.Text
    if nm == "" or sq == "" then
      notify("Preencha o nome e a sequência de notas!", Theme.coral)
      return
    end
    if not isPlayableSeq(sq) then
      notify("A sequência precisa ter pelo menos 3 notas válidas!", Theme.coral)
      return
    end
    local bpm = tonumber(bpmBox.Text) or extractMidi2LuaBPM(sq) or 140
    local entry = { name = nm, bpm = bpm, sequence = sq, midi2lua = true }
    table.insert(State.customSongs, entry)
    local song = { name = nm, bpm = bpm, emoji = "⭐", category = "Custom", sequence = sq, custom = true, midi2lua = true }
    prepareSong(song)
    table.insert(Songs, song)
    saveData()
    rebuildIndexes()
    buildCategories()
    refreshList()
    UI.custom.Visible = false
    playIndex(#Songs, false)
    refreshNowPlaying()
    notify("⭐ Custom salva e tocando: " .. nm, Theme.lime)
  end)
end

CustomBtn.MouseButton1Click:Connect(function()
  UI.custom.Visible = not UI.custom.Visible
end)

-- ───────────── 4. MODAL DE CRÉDITOS ─────────────
UI.credits = makeModal("★  Créditos & Informações", 350, 230)
do
  local y = 48
  for _, c in ipairs(CREDITS) do
    mk("TextLabel", { Text = c.emoji .. "  " .. c.name, Font = Theme.FONTB, TextSize = 14, BackgroundTransparency = 1, Size = UDim2.new(1, -28, 0, 20), Position = UDim2.fromOffset(16, y), TextColor3 = Theme.tealGlow, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 31 }, UI.credits)
    mk("TextLabel", { Text = c.role, Font = Theme.FONTR, TextSize = 11, BackgroundTransparency = 1, Size = UDim2.new(1, -28, 0, 16), Position = UDim2.fromOffset(16, y + 18), TextColor3 = Theme.sub, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 31 }, UI.credits)
    y = y + 44
  end
  mk("TextLabel", { Text = "Atalho: RightAlt p/ mostrar ou ocultar  •  Arraste a barra p/ avançar", Font = Theme.FONTR, TextSize = 10, BackgroundTransparency = 1, Size = UDim2.new(1, -28, 0, 18), Position = UDim2.fromOffset(16, y + 4), TextColor3 = Theme.mint, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 31 }, UI.credits)
end

-- ───────────── 5. MODAL DE IDIOMA ─────────────
UI.langModal = makeModal("🌐  Idioma · Language · Idioma", 320, 250)
do
  mk("TextLabel", { Text = "Selecione o idioma da interface:\nSelect your preferred language:", Font = Theme.FONTR, TextSize = 12, BackgroundTransparency = 1, Size = UDim2.new(1, -28, 0, 38), Position = UDim2.fromOffset(14, 42), TextColor3 = Theme.sub, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 31 }, UI.langModal)

  local function langBtn(flag, label, code, y)
    local b = mk("TextButton", { Text = "   " .. flag .. "   " .. label, Size = UDim2.new(1, -28, 0, 42), Position = UDim2.fromOffset(14, y), BackgroundColor3 = Theme.panel2, AutoButtonColor = false, Font = Theme.FONT, TextSize = 14, TextColor3 = Theme.text, BorderSizePixel = 0, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 31 }, UI.langModal)
    corner(b, 10)
    local st = stroke(b, Theme.teal, 1.2, 0.25)
    gradient(st, Theme.teal, Theme.amber, 30)
    hoverify(b, Theme.panel2, Theme.panelHover)
    clickPop(b)
    b.MouseButton1Click:Connect(function()
      State.lang = code
      State.hasSavedLang = true
      saveData()
      applyLang()
      UI.langModal.Visible = false
      notify("🌐 " .. label, Theme.teal)
    end)
    return b
  end
  langBtn("🇧🇷", "Português (BR)", "pt", 88)
  langBtn("🇺🇸", "English",        "en", 136)
  langBtn("🇪🇸", "Español",        "es", 184)
end

-- ══════════════════════════════════════════════════════════════
--  MINI-PLAYER FLUTUANTE (MODO MINIMIZADO)
-- ══════════════════════════════════════════════════════════════
local MiniPlayer = mk("Frame", { Name = "FloatingMiniPlayer", Size = UDim2.fromOffset(300, 62), Position = UDim2.new(0.5, -150, 0, 18), BackgroundColor3 = Theme.bg2, BorderSizePixel = 0, Visible = false, ZIndex = 45 }, ScreenGui)
corner(MiniPlayer, 16)
shadow(MiniPlayer, 0.28, 48)
local mpStroke = stroke(MiniPlayer, Theme.teal, 1.5, 0.15)
gradient(mpStroke, Theme.teal, Theme.amber, 35)
gradient(MiniPlayer, Theme.bg2, Theme.panel, 120)

local miniBadge = mk("TextButton", { Text = "BR", Font = Theme.FONTB, TextSize = 14, TextColor3 = Theme.bg, BackgroundColor3 = Theme.teal, AutoButtonColor = false, Size = UDim2.fromOffset(38, 38), Position = UDim2.fromOffset(12, 12), BorderSizePixel = 0, ZIndex = 46 }, MiniPlayer)
corner(miniBadge, 11)
gradient(miniBadge, Theme.teal, Theme.amber, 35)
clickPop(miniBadge)

UI.miniTitle = mk("TextLabel", { Text = "♪ ByRimuruScripts", Font = Theme.FONTB, TextSize = 12, BackgroundTransparency = 1, Size = UDim2.fromOffset(142, 20), Position = UDim2.fromOffset(58, 11), TextColor3 = Theme.text, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 46 }, MiniPlayer)

local miniProgBg = mk("Frame", { Size = UDim2.fromOffset(142, 5), Position = UDim2.fromOffset(58, 36), BackgroundColor3 = Theme.panel2, BorderSizePixel = 0, ZIndex = 46 }, MiniPlayer)
corner(miniProgBg, 3)

UI.miniProgFill = mk("Frame", { Size = UDim2.fromScale(0, 1), BackgroundColor3 = Theme.teal, BorderSizePixel = 0, ZIndex = 47 }, miniProgBg)
corner(UI.miniProgFill, 3)
gradient(UI.miniProgFill, Theme.teal, Theme.amber, 0)

UI.miniPlayBtn = mk("TextButton", { Text = "⏯", Size = UDim2.fromOffset(28, 28), Position = UDim2.new(1, -92, 0.5, -14), BackgroundColor3 = Theme.panel2, AutoButtonColor = false, Font = Theme.FONTB, TextSize = 13, TextColor3 = Theme.teal, BorderSizePixel = 0, ZIndex = 46 }, MiniPlayer)
corner(UI.miniPlayBtn, 8)
clickPop(UI.miniPlayBtn)

local miniNextBtn = mk("TextButton", { Text = "⏭", Size = UDim2.fromOffset(28, 28), Position = UDim2.new(1, -60, 0.5, -14), BackgroundColor3 = Theme.panel2, AutoButtonColor = false, Font = Theme.FONTB, TextSize = 13, TextColor3 = Theme.mint, BorderSizePixel = 0, ZIndex = 46 }, MiniPlayer)
corner(miniNextBtn, 8)
clickPop(miniNextBtn)

local miniExpandBtn = mk("TextButton", { Text = "↗", Size = UDim2.fromOffset(28, 28), Position = UDim2.new(1, -28, 0.5, -14), BackgroundColor3 = Theme.panel2, AutoButtonColor = false, Font = Theme.FONTB, TextSize = 13, TextColor3 = Theme.amberGlow, BorderSizePixel = 0, ZIndex = 46 }, MiniPlayer)
corner(miniExpandBtn, 8)
clickPop(miniExpandBtn)

local function restoreMainWindow()
  State.isMinimized  = false
  MiniPlayer.Visible = false
  Root.Visible       = true
  Backdrop.Visible   = true
  Root.Size          = UDim2.fromOffset(0, 0)
  setBlurSize(12)
  TweenService:Create(Root, TweenInfo.new(0.30, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = UDim2.fromOffset(WINDOW_SIZE.X, WINDOW_SIZE.Y) }):Play()
end

local function minimizeMainWindow()
  State.isMinimized = true
  TweenService:Create(Root, TweenInfo.new(0.20, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Size = UDim2.fromOffset(0, 0) }):Play()
  setBlurSize(0)
  task.delay(0.20, function()
    if State.isMinimized then
      Root.Visible       = false
      Backdrop.Visible   = false
      MiniPlayer.Visible = true
    end
  end)
end

miniBadge.MouseButton1Click:Connect(restoreMainWindow)
miniExpandBtn.MouseButton1Click:Connect(restoreMainWindow)
UI.miniPlayBtn.MouseButton1Click:Connect(function() pauseResume(); refreshNowPlaying() end)
miniNextBtn.MouseButton1Click:Connect(function() nextSong(); startPlayback(); refreshNowPlaying(); refreshList() end)
MinBtn.MouseButton1Click:Connect(minimizeMainWindow)

-- ══════════════════════════════════════════════════════════════
--  HANDLERS DE BOTÕES E INTERAÇÕES
-- ══════════════════════════════════════════════════════════════
PlayBtn.MouseButton1Click:Connect(function()
  if State.isPlaying then
    pauseResume()
  else
    playIndex(State.currentSong, State.autoNext)
  end
  refreshNowPlaying()
end)

ShuffleBtn.MouseButton1Click:Connect(function()
  State.shuffleEnabled = true
  State.autoNext       = true
  State.currentSong    = getRandomPlayable()
  playIndex(State.currentSong, true)
  refreshNowPlaying()
  refreshList()
  notify("🔀 Shuffle Play: " .. (curSong() and curSong().name or ""), Theme.teal)
end)

RandomBtn.MouseButton1Click:Connect(function()
  State.currentSong = getRandomPlayable()
  playIndex(State.currentSong, State.autoNext)
  refreshNowPlaying()
  refreshList()
  notify("🎲 " .. (curSong() and curSong().name or ""), Theme.mint)
end)

UI.playPauseBtn.MouseButton1Click:Connect(function() pauseResume(); refreshNowPlaying() end)
StopBtn.MouseButton1Click:Connect(function() stopPlayback(); refreshNowPlaying() end)
NextBtn.MouseButton1Click:Connect(function() nextSong(); startPlayback(); refreshNowPlaying(); refreshList() end)
PrevBtn.MouseButton1Click:Connect(function() prevSong(); startPlayback(); refreshNowPlaying(); refreshList() end)

QueueBtn.MouseButton1Click:Connect(function()
  table.insert(State.queue, State.currentSong)
  updateQueueBadge()
  if refreshQueueModal then pcall(refreshQueueModal) end
  notify("≣ Adicionado à fila (" .. #State.queue .. ")", Theme.mint)
end)

UI.favBtn.MouseButton1Click:Connect(function()
  toggleFav(State.currentSong)
  refreshNowPlaying()
  refreshList()
  buildCategories()
  setCategory(activeCategory)
end)

SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
  ClearSearchBtn.Visible = (#SearchBox.Text > 0)
  refreshList()
end)

UI.helpBtn.MouseButton1Click:Connect(function() UI.credits.Visible = not UI.credits.Visible end)
UI.langBtn.MouseButton1Click:Connect(function() UI.langModal.Visible = not UI.langModal.Visible end)

-- Troca de arte visual ao clicar no ArtCard
do
  local ai = 1
  local hit = mk("TextButton", { Text = "", BackgroundTransparency = 1, AutoButtonColor = false, Size = UDim2.fromScale(1, 1), ZIndex = 8 }, UI.artImage)
  hit.MouseButton1Click:Connect(function()
    ai = (ai % #ART.options) + 1
    UI.setArt(resolveArtId(ART.options[ai]))
    notify("🖼️ Arte " .. ai .. "/" .. #ART.options, Theme.teal)
  end)
end

-- ══════════════════════════════════════════════════════════════
--  ARRASTAR JANELA PRINCIPAL E MINI-PLAYER
-- ══════════════════════════════════════════════════════════════
local function makeDraggable(handle, targetFrame)
  local dragging, dragStart, startPos = false, nil, nil
  handle.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
      dragging  = true
      dragStart = i.Position
      startPos  = targetFrame.Position
      i.Changed:Connect(function()
        if i.UserInputState == Enum.UserInputState.End then dragging = false end
      end)
    end
  end)
  trackConn(UserInputService.InputChanged:Connect(function(i)
    if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
      local d = i.Position - dragStart
      targetFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
  end))
end

makeDraggable(TopBar, Root)
makeDraggable(MiniPlayer, MiniPlayer)

-- Interação contínua da barra de seek
trackConn(UserInputService.InputChanged:Connect(function(i)
  if seekingBar and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
    updateSeekFromInput(i.Position.X)
  end
end))
trackConn(UserInputService.InputEnded:Connect(function(i)
  if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
    seekingBar = false
  end
end))

-- ══════════════════════════════════════════════════════════════
--  LOOP DE RENDERIZAÇÃO (PROGRESSO, EQUALIZADOR, FPS & TECLAS)
-- ══════════════════════════════════════════════════════════════
local lastFpsCheck = os.clock()
local frameCounter = 0

trackConn(RunService.RenderStepped:Connect(function(dt)
  -- Contador de FPS
  frameCounter = frameCounter + 1
  local now = os.clock()
  if now - lastFpsCheck >= 0.5 then
    local fps = math.clamp(math.floor(frameCounter / (now - lastFpsCheck) + 0.5), 1, 240)
    UI.fpsLabel.Text = tostring(fps) .. " FPS"
    UI.fpsLabel.TextColor3 = (fps >= 45 and Theme.lime) or (fps >= 25 and Theme.mint) or Theme.coral
    frameCounter = 0
    lastFpsCheck = now
  end

  -- Monitor de tecla ao vivo
  UI.liveKeyLabel.Text = "🎹 " .. tostring(State.lastPlayedKeys or "—")

  -- Barra de progresso e tempo
  local target = State.isPlaying and State.progress or 0
  if not seekingBar then
    local cur = UI.progFill.Size.X.Scale
    local nextScale = cur + (target - cur) * math.min(1, dt * 15)
    UI.progFill.Size = UDim2.fromScale(nextScale, 1)
    if UI.miniProgFill then
      UI.miniProgFill.Size = UDim2.fromScale(nextScale, 1)
    end
  end

  if State.isPlaying then
    local icon = State.isPaused and "▶" or "⏸"
    UI.playPauseBtn.Text = icon
    if UI.miniPlayBtn then UI.miniPlayBtn.Text = icon end
    local s = curSong()
    UI.nowText.Text = (tr("note")):format(
      s and s.name or "", math.floor(State.progress * 100), State.currentNote, State.totalNotes)
    UI.timeLabel.Text = formatTime(State.elapsedSec) .. " / " .. formatTime(State.totalSec)
  else
    UI.playPauseBtn.Text = "⏯"
    if UI.miniPlayBtn then UI.miniPlayBtn.Text = "⏯" end
    if UI.progFill.Size.X.Scale < 0.01 then
      UI.nowText.Text = tr("ready")
      UI.timeLabel.Text = "00:00 / 00:00"
    end
  end

  -- Animação do Equalizador de 10 barras no Hero Card
  local noteAge = now - (State.lastNoteTime or 0)
  local activeAmp = (State.isPlaying and not State.isPaused and noteAge < 0.35)
    and (State.lastNoteIntensity * (1 - noteAge / 0.35))
    or 0

  for bi, bar in ipairs(eqBars) do
    local wave = math.sin(now * 14 + bi * 0.9) * 0.5 + 0.5
    local h = 3 + math.floor(activeAmp * (6 + wave * 12))
    bar.Size = UDim2.fromOffset(4, math.clamp(h, 3, 20))
  end
end))

-- ══════════════════════════════════════════════════════════════
--  ATALHO DE TECLADO (RightAlt = Mostrar / Ocultar sem Bug!)
-- ══════════════════════════════════════════════════════════════
trackConn(UserInputService.InputBegan:Connect(function(i, gpe)
  if gpe then return end
  if i.KeyCode == Enum.KeyCode.RightAlt then
    if State.isMinimized or not Root.Visible then
      restoreMainWindow()
    else
      minimizeMainWindow()
    end
  end
end))

-- ══════════════════════════════════════════════════════════════
--  LIMPEZA COMPLETA E ENCERRAMENTO SEGURO
-- ══════════════════════════════════════════════════════════════
local function fullCleanup()
  stopPlayback()
  releaseAllKeys()
  for _, c in ipairs(Connections) do
    pcall(function() c:Disconnect() end)
  end
  Connections = {}
  pcall(function() HubBlur:Destroy() end)
  pcall(function() ScreenGui:Destroy() end)
end

_G.ByRimuruCleanup = fullCleanup

CloseBtn.MouseButton1Click:Connect(function()
  TweenService:Create(Root, TweenInfo.new(0.20, Enum.EasingStyle.Quad), { Size = UDim2.fromOffset(0, 0) }):Play()
  setBlurSize(0)
  task.delay(0.22, fullCleanup)
end)

ScreenGui.AncestryChanged:Connect(function(_, parent)
  if not parent then fullCleanup() end
end)

-- ══════════════════════════════════════════════════════════════
--  INICIALIZAÇÃO FINAL DA INTERFACE
-- ══════════════════════════════════════════════════════════════
applyLang()
playUISound(6284583900, 0.55)

Root.Size = UDim2.fromOffset(0, 0)
TweenService:Create(Root, TweenInfo.new(0.42, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = UDim2.fromOffset(WINDOW_SIZE.X, WINDOW_SIZE.Y) }):Play()

-- Abre o seletor de idioma automaticamente apenas se o usuário ainda não tiver salvo um idioma
if not State.hasSavedLang then
  UI.langModal.Visible = true
end

notify((tr("loaded")):format(#PlayableIdx), Theme.teal)
