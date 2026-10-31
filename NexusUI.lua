-- NEXUS UI V6.1.0 — BLACK EDITION · UN SOLO ARCHIVO: biblioteca + interfaz de ejemplo
-- Pégalo entero en tu ejecutor y ejecútalo. Devuelve la tabla UI (se puede usar con loadstring).

local UI = (function()
--[[
    ╔══════════════════════════════════════════════════════════╗
    ║  NEXUS UI  ·  v6.1.0  ·  Black Edition                   ║
    ║  Librería de interfaz para proyectos propios de Roblox   ║
    ╚══════════════════════════════════════════════════════════╝

    USO RÁPIDO
        local UI = loadstring(game:HttpGet("URL_RAW_DE_NexusUI.lua"))()
        local Window = UI:CreateWindow({ Title = "Mi Hub" })
        local Tab = Window:CreateTab({ Name = UI.T("Inicio", "Home") })
        Tab:CreateButton({ Name = "Hola", Callback = function() print("hi") end })

    Todo texto puede ser string o UI.T("español", "english") y se traduce solo.

    ─── UI (módulo) ───────────────────────────────────────────
        UI.Version, UI.Language, UI.ReduceMotion, UI.Themes, UI.Windows
        UI.T(es, en)                 texto bilingüe
        UI:CreateWindow(opciones)    -> Window
        UI:SetLanguage("ES"|"EN")    idioma por defecto
        UI:SetTheme(colores)         (v5) cambia los colores por defecto de ventanas nuevas
        UI:RegisterTheme(nombre, colores)   registra un tema nuevo
        UI:DestroyAll()
        UI:AddBackgroundPreset(nombre, fuente, credito)   UI.BackgroundPresets

    ─── UI:CreateWindow(opciones) ─────────────────────────────
        Title, Subtitle, Name, Language, Size(Vector2), Scale(0.6-1.4), ToggleKey(Enum.KeyCode),
        Theme(string de UI.Themes | tabla de colores), Loading(bool), LoadingTime,
        LogoImage, BackgroundImage(false = sin fondo), MiniText, Parent, DisplayOrder,
        ConfirmClose(bool), MaxNotifications, ReduceMotion(bool),
        ConfigFolder, ConfigName, AutoSave(bool), RestoreLayout(bool), Storage(adaptador),
        KeySystem({Keys, Title, Note, SaveKey, FileName}),
        OnClose(fn), OnLanguageChanged(fn)

    ─── Window ────────────────────────────────────────────────
        :CreateTab({Name, Category, Icon})     :SelectTab(nombre|indice)
        :SetCategoryOpen(categoria, bool)   (las categorías se pliegan con su flecha)
        :SetBackground(fuente | false | "default")   fuente = ID, rbxassetid://, enlace directo
                                                    .png/.jpg o archivo del ejecutor
        :SetLayoutEditMode(bool)  :IsLayoutEditMode()  :ResetLayout()
        :Notify({Type, Title, Content, Duration})   :ClearNotifications()
        :SetTheme(nombre|tabla)  :GetTheme()  :SetAccent(color, color2)
        :SetLanguage("ES"|"EN")  :GetLanguage()
        :SetUIScale(n)  :SetReduceMotion(bool)
        :Minimize() :Restore() :Maximize() :SetVisible(bool) :Destroy()
        :OnLoaded(fn)  :OnChanged(flag, fn)
        :SaveConfig(n) :LoadConfig(n) :DeleteConfig(n) :ListConfigs()
        :ExportConfig() :ImportConfig(json) :CanPersist()
        .Flags  .Gui  .Main  .Storage

    ─── Tab / Group (mismos componentes) ──────────────────────
        :CreateSection(nombre)   :CreateDivider()   :CreateLabel(texto)
        :CreateParagraph({Title, Content})
        :CreateButton({Name, Callback})
        :CreateToggle({Name, CurrentValue, Flag, Callback})
        :CreateSlider({Name, Range, Increment, Suffix, CurrentValue, Flag, Callback})
        :CreateDropdown({Name, Options, CurrentOption, Flag, Callback})
        :CreateMultiDropdown({Name, Options, CurrentOptions, Flag, Callback})
        :CreateInput({Name, Placeholder, CurrentValue, Numeric, Flag, Callback})
        :CreateKeybind({Name, CurrentKeybind, Flag, Callback, OnChanged})
        :CreateColorPicker({Name, CurrentValue, Flag, Callback})
        :CreateProgressBar({Name, CurrentValue(0-1)})
        :CreateGroup({Name, Open})  -> grupo plegable con los mismos métodos
        :CreateServerInfo({Name})   jugadores / capacidad del servidor ACTUAL
        :CreateBackgroundPicker({Name, Presets, Open})   cambiar el fondo de la ventana
        Todos devuelven api con :Destroy() y :SetVisible(bool); la mayoría :Get() / :Set().

    Documentación completa: README.md y docs/API.md del repositorio.
]]

-- Esta biblioteca DEVUELVE la tabla UI (al final del archivo).
-- Si ya se cargó esta misma versión, se devuelve la que ya existe
-- (así varios scripts pueden hacer loadstring sin duplicarla).
local BUILD = "6.1.0-20261031044825"
do
    local env = (getgenv and getgenv()) or _G
    local existing = env.NexusUI
    if type(existing) == "table" and existing.Build == BUILD and existing.Loaded then
        return existing
    end
end

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")

local player = Players.LocalPlayer
if not player then
    error("[NexusUI] Debe ejecutarse en el cliente (LocalScript o ejecutor).")
end
local playerGui = player:WaitForChild("PlayerGui")

local UI = {}
UI.Version = "6.1.0"
UI.Edition = "Black Edition"
UI.FullName = "NEXUS UI V6.1.0 — BLACK EDITION"
UI.Build = BUILD
UI.Loaded = false
UI.Language = "ES"
UI.AnimationSpeed = 0.2
UI.ReduceMotion = false
UI.Windows = {}

-- IDs de respaldo (solo se usan si el entorno no soporta imágenes incrustadas)
UI.Images = {
    Logo = "",
    Background = ""
}

-- ═══════════════════════════════════════════════════════════
--  TEMAS
--  Los colores de un mismo tema deben ser distintos entre sí
--  (el cambio de tema en caliente reconoce los colores por valor).
-- ═══════════════════════════════════════════════════════════
local function copyTable(t)
    local c = {}
    for k, v in pairs(t) do c[k] = v end
    return c
end

local BLACK = {
    Background = Color3.fromRGB(7, 7, 12),
    Panel = Color3.fromRGB(13, 13, 21),
    Element = Color3.fromRGB(21, 21, 33),
    Accent = Color3.fromRGB(124, 108, 255),
    Accent2 = Color3.fromRGB(70, 150, 255),
    Text = Color3.fromRGB(240, 240, 250),
    Muted = Color3.fromRGB(150, 152, 172),
    Border = Color3.fromRGB(42, 42, 64),
    Success = Color3.fromRGB(80, 200, 140),
    Warning = Color3.fromRGB(240, 190, 80),
    Error = Color3.fromRGB(235, 95, 110),
    Shade = Color3.fromRGB(2, 2, 6),
    ShadeAlpha = 0.45,
    Light = false
}

local function extend(base, overrides)
    local t = copyTable(base)
    for k, v in pairs(overrides) do
        if t[k] ~= nil then t[k] = v end
    end
    return t
end

UI.Themes = {
    Black = BLACK,
    Midnight = extend(BLACK, {
        Background = Color3.fromRGB(6, 10, 20),
        Panel = Color3.fromRGB(11, 17, 32),
        Element = Color3.fromRGB(18, 27, 48),
        Accent = Color3.fromRGB(80, 160, 255),
        Accent2 = Color3.fromRGB(140, 110, 255),
        Text = Color3.fromRGB(235, 242, 255),
        Muted = Color3.fromRGB(140, 158, 190),
        Border = Color3.fromRGB(36, 52, 86),
        Shade = Color3.fromRGB(2, 4, 10)
    }),
    Light = extend(BLACK, {
        Background = Color3.fromRGB(238, 240, 248),
        Panel = Color3.fromRGB(250, 250, 255),
        Element = Color3.fromRGB(226, 229, 242),
        Accent = Color3.fromRGB(98, 84, 235),
        Accent2 = Color3.fromRGB(50, 130, 240),
        Text = Color3.fromRGB(22, 22, 34),
        Muted = Color3.fromRGB(96, 100, 124),
        Border = Color3.fromRGB(196, 200, 220),
        Success = Color3.fromRGB(30, 150, 95),
        Warning = Color3.fromRGB(200, 140, 20),
        Error = Color3.fromRGB(205, 60, 80),
        Shade = Color3.fromRGB(248, 248, 254),
        ShadeAlpha = 0.3,
        Light = true
    }),
    HighContrast = extend(BLACK, {
        Background = Color3.fromRGB(0, 0, 0),
        Panel = Color3.fromRGB(12, 12, 12),
        Element = Color3.fromRGB(26, 26, 26),
        Accent = Color3.fromRGB(255, 214, 0),
        Accent2 = Color3.fromRGB(0, 220, 255),
        Text = Color3.fromRGB(254, 254, 254),
        Muted = Color3.fromRGB(205, 205, 205),
        Border = Color3.fromRGB(150, 150, 150),
        Success = Color3.fromRGB(0, 230, 120),
        Warning = Color3.fromRGB(255, 170, 0),
        Error = Color3.fromRGB(255, 70, 70),
        Shade = Color3.fromRGB(3, 3, 3),
        ShadeAlpha = 0.2
    })
}
UI.DefaultTheme = "Black"
UI.Theme = copyTable(BLACK)   -- colores por defecto de ventanas nuevas (compatible con v5)

function UI:SetTheme(colors)
    for k, v in pairs(colors or {}) do
        if UI.Theme[k] ~= nil then
            UI.Theme[k] = v
        end
    end
end

function UI:RegisterTheme(name, colors)
    if type(name) ~= "string" or type(colors) ~= "table" then return false end
    UI.Themes[name] = extend(BLACK, colors)
    return true
end

function UI:SetLanguage(language)
    if language == "ES" or language == "EN" then
        UI.Language = language
    end
end

function UI:DestroyAll()
    for i = #UI.Windows, 1, -1 do
        local w = UI.Windows[i]
        if w and w.Destroy then w:Destroy() end
    end
end

-- ═══════════════════════════════════════════════════════════
--  IMÁGENES INCRUSTADAS (sin IDs)
--  Requieren writefile + getcustomasset (algunos ejecutores).
-- ═══════════════════════════════════════════════════════════
local EMBEDDED = {
    -- Fondo de la ventana principal: galaxia
    bg = [[
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
]],
    -- Fondo opcional (selector de fondos): paisaje nocturno
    landscape = [[
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
]],
    -- Notificaciones: capas de luz (blancas con alfa; se tiñen con el color del nivel)
    note_frame = [[
iVBORw0KGgoAAAANSUhEUgAAAtAAAABnCAMAAAAe2YVKAAADAFBMVEX///////////////////////////8AAAD///8AAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA6
enj/AAAAyHRSTlMNLUz4a82wAI8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAG2G/zkAAAvrSURBVHja7Z2JlqsgDEBJBMr/f/G4yy6rOpqc9zqtrRTxkoYQAvtZwtj4AFzK4QsiHJGr
7K9ErkyFHkXLBFG6aAdlvth12S/0bTdOKWQbrga/Ls6oRDUWT5YASErxmBxvn3zQFCwR7cTl2UnhXD/RqrXTS2yxjuZ0l60xr75v01dO3MmJaRYDesI5XzUr
GNsSVtGe/is5cDJeoHHc+/nYO9XCy2SDfAc73sGMypc3n3nxbe5KoGXHS5qh5sxS0sx8DgWWhvqnCIfuSbuu0UuSfxXct3iQZ2x/zR21znJ5ky0xIe0HenyD
F1gz8iU892r1zkDPiHL0o3rOcrM+fFP7qtHgBZNijeeSgaDkBHSgxQ2lhxeA7gEaT634f641+Agt18wO7QmUDDbl/AtHED9HfTtIv5FnvSn5RPQOMqvheRx5
qvNxxkOEbfIYWz0w/ryU/FeoBzmo3ZBmZTzvnhTdh9W7CVkc1Cx52p2BLr6SF+tni2jBVquDZfDs8wyeeHBrGpNdIU10fo8O0gbonjyzoI4pacq6dhp19E8D
+pznsKM7bXIiv0XZRdK0Vz2H57mIxjwz6HXB8SaNf+dGNN9YTuA5Pm3jmX1KZ/pmnPUmulfd77aHf95m/pMLdOi9tbAEFczmh849uLKll4sSA64w/8b3Zbap
EY5FyCL6CTgz1uob2wFtO/3O1TbYzVmnmy/8Rapu7M3XMZvR8z/lEJzFcxrQye3K/qs0taDD/hEH5EyjJWG03fqCw2c0ae51ikUuNLMfOs5lPUyrG87wLpz9
ur6Du3CxJ/IM8VV/4/HHaOyy1i/Tv9DuJ9G8UDkbHVNsh3Ai8+R5uFOG+Yz/j2Z4shLHDPa9bb4+N6vF2o6Ay8qsIloM80FbQYspOEsLCZRJHKt05wbAG3Vz
PgRX+sKPEKTdSqnuwGdqGa5s0MXo4PMxU0GLJYxJnfCb76F7go/uESaJ9kvfm2k0FLoWY9L3x+YODTGr6Hl6BSyeFw8mT4p653jFWPptQLvHOins2V429TSf
Y8k68Xznb96iosF2cYjj3YzVFld4ad4DdGj6oJOC9kQB9uD5MiMjQjSf5gsNi0PYV3+Pi/GrsPfQ0PPjrniWx04839tum80BNs95bUscNnSf9AFa105RnOFf
8qwDLQdgmo9DEqDv0tEm0O3YC/A8/4WEsxu7SXWbg2uz3sTzu3jerAxrhVRHniGJTE+UE7A2QKNQTBHPD7FAOsafQleebaC9KhjWSCdf0B60qdAEtGTE84v1
s8Nzn3pqfpoIz/1mDo9LlgPbc2sQzy/lGXrzvGJsfQN4XZJdvHsa0IIdPBPQrxoPeuYI+tXziCk3orF2tI1Psv5AE89fALp3NV2KmW/KqKfJoRagJbmUX8Yz
bGnxruGZHThrYEPQ4O7TfDvQkuZIXsgzKnUZzzrQh2/uupm4/apnoJUdHUvyBp7tDEAdqznHDe7OuRP2u2toYS9fIHkgzwyywhL2FAZX8Hx44wzLg4AmnmPp
A7YJiXWGgiWNCfvzvFvK24gwmmTDKrLLoJCAfjbP1t0/TNZH8Ky56hKW4fRtwm1QiGRDPwVoN17X/bjmHEt22VXULqHbsdRlZYyA/jjPRVpzzzLTgmdINovM
GcNLQ40J6P9gcNSd3yiA45xSSF7328N6JqD/CdAFd7OLYgSoSaTorAXr2oi4BScR0Pfh3GAqzcpT4A0c6upRLMifREB/SEcXnT/+2Aa2BunsUiwAun2EEgH9
YIujrIhpwXMAaHgQ0KBPJvYGmoh+gtlReDfnme4enoVK09kZm0JfoAVp6Iep6cLTgzkn7gL6yFB9gfuOgH6w3dEYuTt5DuR2Yb2B5mRy/GOgu+VNgQqe4Qae
HaAJLNLQRrG1Q0Ivzx0bkIB+GtCsxJvVmGeApHLT1+heFpyEBPSzgG5v5Rbq5XjBOVsHOK7xa4CmQeG/5jkIX6HhHF9GgHkK+sJoOwL6UfZGFc9sXcPHquGx
HMaFKalDeZa7NiGZHP9fQevzyawd0FDDcyxveF+dQG67BxFdfGZshFkBdIsEZFfxTH7o5wFda3DYpXUYYVZliOzMFwH9LJ7vOLUP0NF9SgjojwB9g2oP1KKB
guZzxibubu3cfRhCg8IPdwWnmIyBIMaz2xy7o123ZwUB/TYmq02eBgutUAO6R97TFIuDgP4I0JDg2GhiQM/bW3IkoEnudLI04XnJP6bEIKuALg84pJlC+m3Q
gE4Ocg6a0rgBrRwbml0KNGnobypmi4c8noMaet5Nu8LiyEcRCGgSVhAomsLzyLLPxZHDV2liEgKaiM4ynLE8iINlGtF5SBPQJAnWhkXlyb7v6ACNRr7dkjrV
2tBENNFsA7qDiRzjn96TN1XvVJQ9ZQ4Btx0B/Tk/R/IKKvSnZULTGEFvUjIGBDTJrUrasYYP/Yxhs7pRtsj8s31AkxFNQJs4c9/wDjWyMX042ZfnINB0ex8v
eAXRB9DcBvo40AnnotSVBPQ/tnpblxTC+QgxOpguobnc4GDJFjiZHNQxwgthV56V3GKMwM0/jalealZhcCwv9drGT5rrLQYC+puG8xY1yvxBzUoMYp/B3nxy
Bdmgc+f8LKTh2CguBeiJZwL6uyNBr5Legd5CjDCOMjZMQebdfCDZawc4bVtPQH+XaB9Fm8WhNJyzdXNhXrPCbrGPWCecyYYmf1182QmeznmfbMfJWOJi3oDR
ksUzaeivOkpCu7Ctu94bPGM8B3Rg7wkjS14Wz3nzfCbPhoYmoj8DdGKMkZ/mDeQw7DZyefq5gucJaEFAk70RxNkldj52or29PwrJVcqB0eJ5EIKpafskApp4
1ie8DaBRm1cx3+P+mKUmVSrieRjUCLQkoAloDPJsJeSfM8hgKAF0+bZHULBma/2wOngeOMNBII0KP87zrm/9QJtHzjOMJoYUNdLPOs/DOBqlUeGnDeeQej62
SMG4pIAI/rrEalbGs2DsJw8jmoj+Hs+aOaypXz16w7KoGyQYTdtztoDnQf3YaHNIJBX9YccG5665ccyYhDVzKc9tgvS8PA8wAs2E4KSiP8vzgjJ31rie8Vyo
n1uFna4fkibPcnrrp0hFf43nfaPXdUaQc/+i7bjxvHn1MNFUyI/Wy+R54JOC/sGgqWhC+gNAa45kbjg4kqZaPE6QII46T2URTuHrQbR5HmYFbapoiO3qRWi8
iuc9YCMUKIoJQAdnDBtkf3TYMysnbJ7xN+E8WdGzowMrvokkxM8T7Y0tpM4GOzCZkiLpvHAtNYJjsudkcnJ4liPNyz9cjA5s3J9IGULt7vHth4IeiC2gc3mG
LHR2jrkq7xQ++3nyQS9Aj//5mtQXOspL8W2+eXw0XXO9HwHRnkbhIaCxvYLWvpnXFeTo58ll91uBZkwKWb444Z8w7q6myPLr97rUK4rZ82n4YLKBLpGCbbKi
X3q2stzkWYid5/VhJHqQeAPS/fmGz8tCMKCjcXkuz4FPQhnPoa81g6GSeBaDZAvK++NEtOa7wboFZc0Qh5hNSazm/cjPT7k1lRK3ADTugzynQmL3DWuh13pc
pshg62e+8Xz8GYkWvOlwluQZQHPFNTY5NxYNup47r1oO8ZdCRqBQW3DLrFEg+GMryL/j70S06mQ6kdzI80Ehj0oIZ26emAEGIgQ7ibcGXAqRibQwef5pTxif
sotge/mi0dr4orG4Hoa7mecincp9ngQrMPGcR/T0aTwo1oCenqEQU36RRtX+Tj/oUvva4tA2ktPkDL0UH0Uxz4PIJNrh2WB7VNJqLE75mG7ZQa+EOruMUEAD
9K54u/LyKAoSG/5EjboOF6s2nkWOvSFNnp0XMJrlo5reoL5NnDvp3NaAkwcfIbkTE8lGadYp6Tw7Ouv03mQD7UNYKY00KbINjkk9mwjbr6a5Q1RT0ZqTRLgS
fqeRtCnfdfioTZwDp+K5F+kdX+WeECwk4MkKvOM/7GmdSJvJvd5mexiviu6XzBPndGTacNAH9IL0j8FYWVnQXxJF9yOOX+Qcay/t+lifbqzBM/HDZVyfJFzf
glng/rnO3KS2k0bvilYofv89X57UTIN+eQgefn9/dbTm6fBl/esAAAAASUVORK5CYII=
]],
    note_box = [[
iVBORw0KGgoAAAANSUhEUgAAAGEAAABUCAMAAAClb6mPAAAAwFBMVEX///////8AAAD///////////////////////8AAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAC9Vl/WAAAAMHRSTlMyCwBMbvaMrNQAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAABOc5s7AAAC2ElEQVR42u3Z7XakIAwG4BcSwPu/4kUQ5SM4iDrt7tn86GmPmscAOtMANRAAlNKTgTFhOn8SgHNA67uC
jj9DHJn1I4HnUp0InUPqcvSETvqZ+5WukldJOHPsvnGEEg1xmfizFIj4Y9gQbgvL0v1CLED57ARcqoB4paiZDkgFkLU0MQ8KvJjGQAsodhYzS8kHOWO4fMeg
BexilZ4pIQya9UQc4Px5yFazUs64/uo+nvvi77TykIhsEpvZtGahsPSOt0n9WJ3OO4WBWsuAKIDWcTyIaxEAWqc7VAFBAPwYTQNbDeTHyR4EyjNCCSfA8fye
FEFrEftcoATYLN0EqKNbhDML70WgAPwx279WiM5MrMPEPYE7F3ZDKGITqBLCscVQA+BTtMQu+GPQeQmSgIE4FYpB4lbAWDSCbQTIAoajFNyggCvRCvQLBFyM
cQFzgL8OmcAn84BJIH1if0+g4olLr/ZdwFOCkgR8Q8A9wcoC78Kt6LyX3hP0P1DDf+H3CfS4oF4RKArNN7IkMD0t6HcElmvgINBtgCUBrwvqrxAoF+iNUfqS
QB8Ec0Ogc0HdFqgW8LyAMcHSHJGX8JMCzQt0CFwJ+pEaqCihL0zXQJtAklB/997+s7gO0AGkBlDZdbgh0BbDQkPQIJBmwcqC6gtD+beILVKzfVQqqevgJKFL
kgg4Y8QOVuycLCwTNJB/A7zgukLqqkhEPTvUA2xY81IXbh8miZAyNvkjUAxSJSD26GYIzgGb/d9f9/l8EUuH+Jg/zoHzGagnxE5fmOxo0FgBeX4PGC5aF0oi
7E7Q0PAf+f0QVY08KIkIczFilBsRVgAkYX2yQxkXKogl+Ov8EFetP2ipoWnDue5CLOsV6401DWd0Or/szPVwUisVJw3sVD2PBcmNZOj+XuhQI/rj7U716K81
9N8XLu5P6nxrRcdfU4b9mG6E3sZR2iFUZ9uYn/Y3od8OvL15rP8AQtYtTJEeZ6UAAAAASUVORK5CYII=
]],
    -- Botón flotante: tus tres imágenes, recortadas sin fondo blanco (PNG con transparencia)
    pill = [[
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
7Za+SjfFAAAAAElFTkSuQmCC
]],
    arrows = [[
iVBORw0KGgoAAAANSUhEUgAAAEAAAAA+CAMAAACsn+1dAAAAP1BMVEVdYGdaXWk8PH1dYGcAAP8of389PT3///9fYmkAAABdYGdjZm1/f39eYGddYGdVVVUA
AAAAAAAAAAAAAAAAAACTnLNyAAAAEHRSTlOQGQRmAQMEAdkA/f4Cr80Ee8BGXgAAAkpJREFUeNrFl9u26yAIRdFcrBHj///tFm/RVg1pxxmHl7Y2zKDAUkFP
DPUGVviPicHUX1hjrJsSJgBH/sdxQ4CZ/+n97whw639DgLH/K/nPCQPAfr3/htAHyPr9kTDKJgziPxr/SGADfP7Nm3+YxcoEkP/xacYi8gBSLyZZck0/BHsN
xBItFdIZfwmtHvaCthEAz5tJojeBGeC/kj1vphKB/LIbHwOk4gDQ/aMI/Br5TK13gNUnuQsI+mXrjhkBTj9wpQQa/TsZU5Cn10ld3gSl/8AcXECtD5CedVS2
bEBFgFq/WIA9dAjpg8uAol/mdNJVlgEuljIN7S4/+4oECPqV9K+NwP8ZH13a0fJwIFB4lf7Yxo4U19totBcRdg2Nf9aOrqC0g2kWEkh+ji+NRAqW42t/ik0A
/OBPGQLxC8FnGHKyeus1H41qCSvWhLOx+SgViKNCcj4Rx6yQoFtI5C9zKS+lEqOg+LpVSmAGKKFQFQnIlbiEdgr0LREKQMdR6EramQt8u9oZI4EPMOn9RVBE
ILQAOQZc/kXSAqFdxDHAF+C7pAVRJIBkAarjClRTFrDUqlwBtvr0sICoiFD/1dpoEdtH6yJ524D7EdDWhrytbRIBDyB/AGCU9QIIAq6eREAqvmdZt2JH/eik
Kuyr086We0oL58yeoKS9iHFSVT2ZM7Ajdwqb/iT4pVz5i+g+CDkV3CzknfnWf3Jjsc2FY+Q/BHixttWV5/mdSW/orLn81+e9gGupRMTtm2ZC7eLFU67b/7n6
RsLd5fsPfvOPavtR6NIAAAAASUVORK5CYII=
]],
    people = [[
iVBORw0KGgoAAAANSUhEUgAAAEgAAAAxCAMAAABOHh98AAAAP1BMVEX///8AAAD///////////////////////////8AAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAC+TCOxAAAAEHRSTlP9AAYx0HJNj68AAAAAAAAA7eI0AwAAAhtJREFUeNqtl9uSwyAIQBER+f8vXq0kK4Im3Vke2o7oUa5aSAdBTClX
IZLK7See5sKJkxITqFDBIwlOHBSYhPKJBNYUxJlDYGUmmbkGpIpL375XDtC92M41oD6EOaP+bB8VnIjq0M6dQc2QIpNTMWUIJA9dYlkDABcnk3EqJolA8lFN
QeCLBMrheXrXIoSCZs8mRUmg51mmL2Rj2xIEPdMArQGSlEoM4uSCMGIH3rCx8QZUvM3DuAESr9yCnIIuUJDCUHc+4iC9PjkwQEGY8y5qcgIFJ/JjGoU9qH2R
d0VsWw4qh+7wo3egT5froH6DOkUNfSVExdarHzfNRTO7+Bzze2sR5uhAd61Vv8dSVCCow8WO4gyataKc3jDE+H/0M5w6eT+PKdqEv8rPjZE+F4g5EZWsjSzf
56f7dlFn25i2huXGxh5tGFnc2FUiTD41tiXi04JHQgZrCHc1212Vo5aQIMqXvOf0VRydE/CL0j80AIRgc0Q4SqAvzbSgYOsZVKPChfz1gdoMv4ih+JZTnkAl
6DtQX8zyXdrtVUF87wL43jbxIORnkN/Mg+jZRT2VPKg6UH0GeT8K8P+AGNZ1fwNJr7VCfwC5PgXjxTfJO2e3idxkLOldEhKub15+A3Ive9CX7q/sbv3lkrZr
ggf79tFnL8oXL//NMxSCd+MT6NE2fHWi+KkePD+fQYj1W8Pif0c9cnXTlKhu/iP9ABW/CrN3aTSkAAAAAElFTkSuQmCC
]]
}
local EMBEDDED_EXT = {pill = "png", arrows = "png", people = "png", note_frame = "png", note_box = "png"}

local B64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local B64LOOK = {}
for i = 1, 64 do B64LOOK[B64:byte(i)] = i - 1 end

local function b64decode(data)
    data = (data:gsub("[^%w%+/=]", ""))
    local out, n = {}, 0
    for i = 1, #data, 4 do
        local a, b, c, d = data:byte(i, i + 3)
        local v = (B64LOOK[a] or 0) * 262144 + (B64LOOK[b] or 0) * 4096
            + (B64LOOK[c] or 0) * 64 + (B64LOOK[d] or 0)
        local s = string.char(math.floor(v / 65536) % 256)
        if c ~= 61 then s = s .. string.char(math.floor(v / 256) % 256) end
        if d ~= 61 then s = s .. string.char(v % 256) end
        n += 1
        out[n] = s
    end
    return table.concat(out)
end

local localAssets = {}
local function embeddedImage(name)
    if localAssets[name] ~= nil then return localAssets[name] end
    local result = ""
    local getAsset = getcustomasset or getsynasset
    if writefile and getAsset and EMBEDDED[name] then
        local ok = pcall(function()
            if makefolder and isfolder and not isfolder("NexusUI") then
                makefolder("NexusUI")
            end
            local path = "NexusUI/" .. name .. "." .. (EMBEDDED_EXT[name] or "jpg")
            writefile(path, b64decode(EMBEDDED[name]))
            result = getAsset(path)
        end)
        if not ok then result = "" end
    end
    localAssets[name] = result
    return result
end

-- ═══════════════════════════════════════════════════════════
--  UTILIDADES
-- ═══════════════════════════════════════════════════════════
local function L(es, en)
    return {ES = es, EN = en}
end
UI.T = L

local function tx(v)
    if type(v) == "table" then
        return v[UI.Language] or v.EN or v.ES or ""
    end
    return tostring(v == nil and "" or v)
end

-- Valor estable (independiente del idioma) de un texto bilingüe
local function key(v)
    if type(v) == "table" then return v.EN or v.ES or "" end
    return tostring(v)
end

local function trim(s)
    return (tostring(s or ""):gsub("^%s+", ""):gsub("%s+$", ""))
end

local function asset(id)
    id = tostring(id or "")
    if id == "" or id == "0" then return "" end
    if id:match("^%d+$") then return "rbxassetid://" .. id end
    return id
end

local function make(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    obj.Parent = parent
    return obj
end

local function round(obj, radius)
    make("UICorner", {CornerRadius = UDim.new(0, radius or 10)}, obj)
end

local function outline(obj, color, theme)
    return make("UIStroke", {
        Color = color or (theme or UI.Theme).Border,
        Thickness = 1,
        Transparency = 0.12
    }, obj)
end

local function animate(obj, props, duration)
    local d = duration or UI.AnimationSpeed
    if UI.ReduceMotion then d = 0 end
    local tw = TweenService:Create(
        obj,
        TweenInfo.new(d, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        props
    )
    tw:Play()
    return tw
end

-- Flecha "V" dibujada con dos barras (no depende de la fuente del texto).
-- Rotation 0 = apunta abajo, 180 = arriba, 90 = izquierda, -90 = derecha.
local function makeChevron(parentObj, color, arm, thick, z)
    local a = arm / math.sqrt(2)
    local box = make("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(arm * 2, arm * 2),
        BackgroundTransparency = 1,
        ZIndex = z or 1
    }, parentObj)
    local function bar(x, rot)
        local f = make("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, x, 0.5, 0),
            Size = UDim2.fromOffset(arm, thick or 2),
            Rotation = rot,
            BackgroundColor3 = color,
            BorderSizePixel = 0,
            ZIndex = z or 1
        }, box)
        f:SetAttribute("Arm", true)
        round(f, 1)
    end
    bar(-a / 2, 45)
    bar(a / 2, -45)
    return box
end

local function isPress(input)
    return input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1
end

local function isMove(input)
    return input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseMovement
end

-- Ejecuta un callback del usuario sin romper la interfaz si falla
local function spawnCall(fn, ...)
    if type(fn) ~= "function" then return end
    local args = table.pack(...)
    task.spawn(function()
        local ok, err = pcall(fn, table.unpack(args, 1, args.n))
        if not ok then
            warn("[NexusUI] " .. tostring(err))
        end
    end)
end

local function formatNumber(n)
    return tostring(math.floor(n * 1000 + 0.5) / 1000)
end

-- Identificador numérico de un Color3 (para el cambio de tema en caliente)
local function cid(c)
    return math.floor(c.R * 255 + 0.5) * 65536
        + math.floor(c.G * 255 + 0.5) * 256
        + math.floor(c.B * 255 + 0.5)
end

-- Sustituye colores antiguos por nuevos en todos los descendientes de root
local function recolor(root, map)
    local function swap(obj, prop)
        local n = map[cid(obj[prop])]
        if n then obj[prop] = n end
    end
    for _, obj in ipairs(root:GetDescendants()) do
        if not obj:GetAttribute("NoTheme") then
            if obj:IsA("GuiObject") then
                swap(obj, "BackgroundColor3")
                if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
                    swap(obj, "TextColor3")
                    if obj:IsA("TextBox") then swap(obj, "PlaceholderColor3") end
                elseif obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
                    swap(obj, "ImageColor3")
                elseif obj:IsA("ScrollingFrame") then
                    swap(obj, "ScrollBarImageColor3")
                end
            elseif obj:IsA("UIStroke") then
                swap(obj, "Color")
            end
        end
    end
end

-- ═══════════════════════════════════════════════════════════
--  IMÁGENES DE FONDO PERSONALIZADAS
--  Acepta: ID numérico, rbxassetid://, un enlace directo a .png/.jpg
--  (se descarga y se guarda en caché) o un archivo del ejecutor.
--  Las descargas necesitan funciones del ejecutor (writefile,
--  getcustomasset y HttpGet/request); Roblox no las ofrece oficialmente.
-- ═══════════════════════════════════════════════════════════
local function hashString(s)
    local h = 5381
    for i = 1, #s do
        h = (h * 33 + s:byte(i)) % 4294967296
    end
    return string.format("%08x", h)
end

local function imageExtension(data)
    if data:sub(1, 4) == "\137PNG" then return "png" end
    if data:sub(1, 3) == "\255\216\255" then return "jpg" end
    if data:sub(1, 4) == "RIFF" and data:sub(9, 12) == "WEBP" then return "webp" end
    if data:sub(1, 3) == "GIF" then return "gif" end
    return nil
end

local function httpGetBinary(url)
    local req = (syn and syn.request) or request or http_request or (http and http.request)
    if req then
        local ok, res = pcall(req, {Url = url, Method = "GET"})
        if ok and type(res) == "table" and res.StatusCode == 200 and type(res.Body) == "string" then
            return res.Body
        end
    end
    local ok, body = pcall(function() return game:HttpGet(url) end)
    if ok and type(body) == "string" then return body end
    return nil
end

-- Devuelve (contenido para ImageLabel.Image) o ("", mensaje de error).
-- Puede tardar si descarga una imagen: llámala desde un hilo (task.spawn).
local function resolveImageSource(source)
    source = trim(tostring(source == nil and "" or source))
    if source == "" then return "", "No hay ninguna imagen indicada." end
    if source:match("^rbxassetid://") or source:match("^rbxasset://") or source:match("^rbxthumb://") then
        return source
    end
    if source:match("^%d+$") then return "rbxassetid://" .. source end

    -- Imagen incrustada en este archivo (por ejemplo "embedded:landscape")
    local embeddedName = source:match("^embedded:(%w+)$")
    if embeddedName then
        local e = embeddedImage(embeddedName)
        if e ~= "" then return e end
        return "", "Esa imagen incrustada no está disponible en este entorno."
    end

    local getAsset = getcustomasset or getsynasset
    if not (writefile and getAsset) then
        return "", "Este entorno no puede guardar imágenes (faltan writefile/getcustomasset)."
    end

    local folder = "NexusUI/cache"
    local function ensureFolder()
        pcall(function()
            if makefolder and isfolder then
                if not isfolder("NexusUI") then makefolder("NexusUI") end
                if not isfolder(folder) then makefolder(folder) end
            end
        end)
    end

    if source:match("^https?://") then
        ensureFolder()
        local base = folder .. "/bg_" .. hashString(source)
        if isfile then
            for _, ext in ipairs({"png", "jpg"}) do
                local okc, exists = pcall(isfile, base .. "." .. ext)
                if okc and exists then
                    local oka, res = pcall(getAsset, base .. "." .. ext)
                    if oka and res then return res end
                end
            end
        end
        local data = httpGetBinary(source)
        if not data or #data < 64 then
            return "", "No se pudo descargar la imagen. Usa un enlace directo (termina en .png o .jpg)."
        end
        local ext = imageExtension(data)
        if ext ~= "png" and ext ~= "jpg" then
            return "", "Formato no compatible (usa PNG o JPG)."
        end
        local path = base .. "." .. ext
        if not pcall(writefile, path, data) then
            return "", "No se pudo guardar la imagen."
        end
        local oka, res = pcall(getAsset, path)
        if oka and res then return res end
        return "", "No se pudo cargar la imagen guardada."
    end

    -- Archivo propio del ejecutor
    if isfile then
        local okf, exists = pcall(isfile, source)
        if okf and exists then
            local oka, res = pcall(getAsset, source)
            if oka and res then return res end
        end
    end
    return "", "No se reconoce la fuente de la imagen."
end

-- Fondos disponibles en el selector. Puedes añadir los tuyos con
-- UI:AddBackgroundPreset("Mi meme", "https://i.imgur.com/xxxx.png", "autor")
UI.BackgroundPresets = {
    {Name = L("Original", "Original"), Source = "default"},
    {Name = L("Sin fondo", "No background"), Source = "none"},
    {Name = L("Paisaje nocturno", "Night landscape"), Source = "embedded:landscape"},
    {
        Name = L("Vía Láctea (ESO)", "Milky Way (ESO)"),
        Source = "https://cdn.eso.org/images/wallpaper1/milkyway.jpg",
        Credit = "Bruno Gilli / ESO"
    }
}

function UI:AddBackgroundPreset(name, source, credit)
    if source == nil or trim(source) == "" then return false end
    table.insert(UI.BackgroundPresets, {
        Name = name or tostring(source),
        Source = tostring(source),
        Credit = credit
    })
    return true
end

-- ═══════════════════════════════════════════════════════════
--  ALMACENAMIENTO
--  Adaptador por defecto: archivos del ejecutor si existen
--  (writefile/readfile/isfile); si no, memoria de la sesión.
--  Se puede sustituir con options.Storage = {Save, Load, Delete, List, Persistent}.
-- ═══════════════════════════════════════════════════════════
local sessionMemory = {}

local function makeStorage(options)
    if type(options.Storage) == "table" and options.Storage.Save and options.Storage.Load then
        return options.Storage
    end

    local folder = options.ConfigFolder or "NexusUI"
    local hasFS = (writefile and readfile and isfile) and true or false
    local store = {Persistent = hasFS}

    local function path(name) return folder .. "/" .. name .. ".json" end
    local function memKey(name) return folder .. "/" .. name end

    function store.Save(name, text)
        if hasFS then
            return (pcall(function()
                if makefolder and isfolder and not isfolder(folder) then
                    makefolder(folder)
                end
                writefile(path(name), text)
            end))
        end
        sessionMemory[memKey(name)] = text
        return true
    end

    function store.Load(name)
        if hasFS then
            local ok, res = pcall(function()
                if isfile(path(name)) then return readfile(path(name)) end
                return nil
            end)
            if ok then return res end
            return nil
        end
        return sessionMemory[memKey(name)]
    end

    function store.Delete(name)
        if hasFS then
            if delfile and isfile(path(name)) then
                return (pcall(delfile, path(name)))
            end
            return false
        end
        local had = sessionMemory[memKey(name)] ~= nil
        sessionMemory[memKey(name)] = nil
        return had
    end

    function store.List()
        local names = {}
        if hasFS then
            if listfiles and isfolder and isfolder(folder) then
                local ok, files = pcall(listfiles, folder)
                if ok and type(files) == "table" then
                    for _, f in ipairs(files) do
                        local n = tostring(f):match("([^/\\]+)%.json$")
                        if n then table.insert(names, n) end
                    end
                end
            end
        else
            local prefix = folder .. "/"
            for k in pairs(sessionMemory) do
                if k:sub(1, #prefix) == prefix then
                    table.insert(names, k:sub(#prefix + 1))
                end
            end
        end
        table.sort(names)
        return names
    end

    return store
end

-- ═══════════════════════════════════════════════════════════
--  VENTANA
-- ═══════════════════════════════════════════════════════════
local NOTE_TYPES = {
    Info = {Color = "Accent2", Tag = L("INFO", "INFO")},
    Success = {Color = "Success", Tag = L("LISTO", "SUCCESS")},
    Warning = {Color = "Warning", Tag = L("AVISO", "WARNING")},
    Error = {Color = "Error", Tag = L("ERROR", "ERROR")}
}

function UI:CreateWindow(options)
    if options ~= nil and type(options) ~= "table" then
        warn("[NexusUI] CreateWindow espera una tabla de opciones.")
        options = nil
    end
    options = options or {}

    if options.Language == "ES" or options.Language == "EN" then
        UI.Language = options.Language
    end
    if options.ReduceMotion ~= nil then
        UI.ReduceMotion = options.ReduceMotion == true
    end

    -- Tema propio de esta ventana
    local T = copyTable(UI.Theme)
    local themeName = UI.DefaultTheme
    if type(options.Theme) == "string" then
        if UI.Themes[options.Theme] then
            T = copyTable(UI.Themes[options.Theme])
            themeName = options.Theme
        else
            warn("[NexusUI] Tema desconocido: " .. options.Theme)
        end
    elseif type(options.Theme) == "table" then
        for k, v in pairs(options.Theme) do
            if T[k] ~= nil then T[k] = v end
        end
        themeName = "Custom"
    end

    local store = makeStorage(options)

    -- Imágenes: opción propia > incrustada > ID de respaldo
    local function pick(name, custom, fallbackId)
        if custom == false then return "" end
        if custom ~= nil and custom ~= "" then return asset(custom) end
        local e = embeddedImage(name)
        if e ~= "" then return e end
        return asset(fallbackId)
    end
    local IMG_LOGO = pick("logo", options.LogoImage, UI.Images.Logo)
    local IMG_BG = pick("bg", options.BackgroundImage, UI.Images.Background)

    local PA = 0.3   -- transparencia de paneles
    local EA = 0.2   -- transparencia de elementos

    local size = options.Size or Vector2.new(540, 365)
    local DEFAULT_W = math.max(size.X, 340)
    local DEFAULT_H = math.max(size.Y, 240)
    local userScale = math.clamp(options.Scale or 1, 0.6, 1.4)
    local TOUCH = UIS.TouchEnabled

    local connections = {}
    local dragStops = {}   -- funciones que cancelan arrastres activos al destruir
    local function track(c)
        table.insert(connections, c)
        return c
    end

    -- Traducción automática de textos enlazados
    local bindings = {}
    local function bind(obj, prop, getter)
        obj[prop] = getter()
        table.insert(bindings, {obj, prop, getter})
    end
    local function unbind(instance)
        for i = #bindings, 1, -1 do
            local o = bindings[i][1]
            if o == instance or o:IsDescendantOf(instance) then
                table.remove(bindings, i)
            end
        end
    end

    local Window = {Flags = {}}
    local flagItems = {}
    local flagHandlers = {}
    local searchIndex = {}
    local gradients = {}
    local refreshExtras   -- se asigna más abajo (búsqueda)

    local function refreshLanguage()
        for i = #bindings, 1, -1 do
            local b = bindings[i]
            if b[1].Parent then
                b[1][b[2]] = b[3]()
            else
                table.remove(bindings, i)
            end
        end
        if refreshExtras then refreshExtras() end
    end

    local parent = options.Parent or playerGui
    local guiName = options.Name or "NexusUI"
    local old = parent:FindFirstChild(guiName)
    if old then old:Destroy() end

    local gui = make("ScreenGui", {
        Name = guiName,
        ResetOnSpawn = false,
        DisplayOrder = options.DisplayOrder or 999,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    }, parent)
    pcall(function() gui.ScreenInsets = Enum.ScreenInsets.None end)

    Window.Gui = gui
    Window.Storage = store

    gui.Destroying:Connect(function()
        for _, stop in ipairs(dragStops) do
            stop()
        end
        for _, c in ipairs(connections) do
            c:Disconnect()
        end
        connections = {}
    end)

    -- Degradado de acento (se actualiza con el tema)
    local function addGradient(target, rotation)
        local g = make("UIGradient", {
            Color = ColorSequence.new(T.Accent, T.Accent2),
            Rotation = rotation or 0
        }, target)
        table.insert(gradients, g)
        return g
    end

    -- Rectángulo blanco que solo sirve de base para un degradado
    local function gradientFrame(props, parentObj, rotation)
        props.BackgroundColor3 = Color3.new(1, 1, 1)
        props.BorderSizePixel = 0
        local f = make("Frame", props, parentObj)
        f:SetAttribute("NoTheme", true)
        addGradient(f, rotation)
        return f
    end

    -- ───────────── Arrastre (mouse y touch) ─────────────
    -- La posición se lee en cada frame mientras se arrastra y la conexión
    -- a RenderStepped existe SOLO durante el arrastre (sin coste en reposo).
    -- onBegin puede devolver false para cancelar el arrastre.
    local function drag(handle, onBegin, onDelta, onEnd)
        local stepConn, active, pending, startInput = nil, false, false, nil
        local startPos = Vector2.zero

        local function current()
            if startInput.UserInputType == Enum.UserInputType.Touch then
                return Vector2.new(startInput.Position.X, startInput.Position.Y)
            end
            return UIS:GetMouseLocation()
        end

        local function stop(silent)
            local was = active
            active = false
            if stepConn then
                stepConn:Disconnect()
                stepConn = nil
            end
            if was and onEnd and not silent then
                onEnd()
            end
        end
        table.insert(dragStops, function() stop(true) end)

        handle.InputBegan:Connect(function(input)
            if not isPress(input) then return end
            if onBegin(input) == false then return end
            stop(true)
            active = true
            pending = true
            startInput = input
            stepConn = RunService.RenderStepped:Connect(function()
                if not active then return end
                local cur = current()
                if pending then
                    -- El punto de partida se toma ya con la posición actualizada
                    -- (evita el salto al agarrar).
                    startPos = cur
                    pending = false
                    return
                end
                onDelta(cur - startPos)
            end)
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    stop()
                end
            end)
        end)

        track(UIS.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                stop()
            end
        end))
    end

    -- Arrastre horizontal de una barra (sliders y selector de color):
    -- solo escucha el ratón/dedo mientras está pulsado.
    -- Devuelve un objeto con :Disconnect() para registrarlo con track().
    local function dragBar(bar, onX)
        local moveConn, endConn
        local function stop()
            if moveConn then moveConn:Disconnect() moveConn = nil end
            if endConn then endConn:Disconnect() endConn = nil end
        end
        bar.InputBegan:Connect(function(input)
            if not isPress(input) then return end
            stop()
            onX(input.Position.X)
            moveConn = UIS.InputChanged:Connect(function(i)
                if isMove(i) then onX(i.Position.X) end
            end)
            endConn = UIS.InputEnded:Connect(function(i)
                if isPress(i) then stop() end
            end)
        end)
        return {Disconnect = stop}
    end

    -- ───────────── Ventana principal ─────────────
    local main = make("Frame", {
        Name = "Main",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.fromOffset(DEFAULT_W, DEFAULT_H),
        Position = UDim2.fromScale(0.5, 0.5),
        BackgroundColor3 = T.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Active = true,
        Visible = false
    }, gui)
    round(main, 14)
    Window.Main = main

    -- Borde con degradado azul-violeta
    local mainStroke = make("UIStroke", {
        Color = Color3.new(1, 1, 1),
        Thickness = 1.5,
        Transparency = 0.3
    }, main)
    mainStroke:SetAttribute("NoTheme", true)
    addGradient(mainStroke, 45)

    -- Capa de fondo (imagen + oscurecido). Siempre existe para poder
    -- cambiarla en caliente con Window:SetBackground().
    local bgImage = make("ImageLabel", {
        Name = "Background",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Image = IMG_BG,
        ScaleType = Enum.ScaleType.Crop,
        Visible = IMG_BG ~= "",
        ZIndex = 1
    }, main)
    round(bgImage, 14)

    local shadeFrame = make("Frame", {
        Name = "Shade",
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = T.Shade,
        BackgroundTransparency = T.ShadeAlpha,
        BorderSizePixel = 0,
        Visible = IMG_BG ~= "",
        ZIndex = 2
    }, main)
    round(shadeFrame, 14)
    make("UIGradient", {
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.25),
            NumberSequenceKeypoint.new(1, 0.12)
        }),
        Rotation = 90
    }, shadeFrame)

    local scale = make("UIScale", {Scale = 1}, main)
    local maximized = false
    local applyMaximize   -- se define más abajo

    local function fitScreen()
        local camera = workspace.CurrentCamera
        if camera then
            local v = camera.ViewportSize
            scale.Scale = math.min(userScale, (v.X - 16) / DEFAULT_W, (v.Y - 16) / DEFAULT_H)
        end
        if maximized and applyMaximize then applyMaximize(true) end
    end

    -- Barra superior transparente (título + subtítulo + botones planos)
    local top = make("Frame", {
        Name = "TopBar",
        Active = true,
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.new(1, 0, 0, 54),
        BackgroundTransparency = 1,
        ZIndex = 3
    }, main)

    make("TextLabel", {
        Position = UDim2.fromOffset(18, 8),
        Size = UDim2.new(1, -220, 0, 20),
        BackgroundTransparency = 1,
        Text = options.Title or "NEXUS UI",
        TextColor3 = T.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 4
    }, top)

    make("TextLabel", {
        Position = UDim2.fromOffset(18, 29),
        Size = UDim2.new(1, -220, 0, 14),
        BackgroundTransparency = 1,
        Text = options.Subtitle or ("NEXUS UI  v" .. UI.Version),
        TextColor3 = T.Muted,
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 4
    }, top)

    local function topButton(text, x)
        local b = make("TextButton", {
            Position = UDim2.new(1, x, 0, 10),
            Size = UDim2.fromOffset(34, 34),
            BackgroundColor3 = T.Border,
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = T.Muted,
            Font = Enum.Font.GothamMedium,
            TextSize = 12,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            ZIndex = 5
        }, top)
        round(b, 9)
        b.MouseEnter:Connect(function()
            animate(b, {BackgroundTransparency = 0.55}, 0.12)
        end)
        b.MouseLeave:Connect(function()
            animate(b, {BackgroundTransparency = 1}, 0.12)
        end)
        return b
    end

    -- Iconos dibujados con barras (no dependen de la fuente)
    local function iconBar(btn, w, h, rot)
        local f = make("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(w, h),
            Rotation = rot or 0,
            BackgroundColor3 = T.Muted,
            BorderSizePixel = 0,
            ZIndex = 6
        }, btn)
        round(f, 1)
        return f
    end

    local close = topButton("", -44)
    iconBar(close, 15, 2, 45)
    iconBar(close, 15, 2, -45)

    local maxButton = topButton("", -82)
    local maxIcon = make("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(12, 12),
        BackgroundTransparency = 1,
        ZIndex = 6
    }, maxButton)
    round(maxIcon, 2)
    make("UIStroke", {Color = T.Muted, Thickness = 1.5}, maxIcon)

    local lang = topButton(UI.Language, -120)

    local minimize = topButton("", -158)
    iconBar(minimize, 13, 2, 0)

    -- Barra lateral transparente (se ve el fondo)
    local sidebar = make("Frame", {
        Position = UDim2.fromOffset(0, 54),
        Size = UDim2.new(0, 140, 1, -54),
        BackgroundTransparency = 1,
        ZIndex = 3
    }, main)

    -- Búsqueda: caja redondeada con lupa; el texto se recorta dentro de su zona
    local searchHolder = make("Frame", {
        Position = UDim2.fromOffset(10, 2),
        Size = UDim2.new(1, -20, 0, 34),
        BackgroundColor3 = T.Element,
        BackgroundTransparency = 0.35,
        BorderSizePixel = 0,
        ClipsDescendants = true
    }, sidebar)
    round(searchHolder, 10)

    local searchIcon = make("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromOffset(18, 17),
        Size = UDim2.fromOffset(16, 16),
        BackgroundTransparency = 1,
        ZIndex = 2
    }, searchHolder)
    local lens = make("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, -2, 0.5, -2),
        Size = UDim2.fromOffset(10, 10),
        BackgroundTransparency = 1,
        ZIndex = 2
    }, searchIcon)
    round(lens, 5)
    make("UIStroke", {Color = T.Muted, Thickness = 1.5}, lens)
    local handleBar = make("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 5, 0.5, 5),
        Size = UDim2.fromOffset(6, 2),
        Rotation = 45,
        BackgroundColor3 = T.Muted,
        BorderSizePixel = 0,
        ZIndex = 2
    }, searchIcon)
    round(handleBar, 1)

    local searchBox = make("TextBox", {
        Position = UDim2.fromOffset(34, 0),
        Size = UDim2.new(1, -62, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = T.Text,
        PlaceholderColor3 = T.Muted,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        ClearTextOnFocus = false,
        ClipsDescendants = true,
        BorderSizePixel = 0,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 2
    }, searchHolder)
    bind(searchBox, "PlaceholderText", function()
        return tx(L("Buscar...", "Search..."))
    end)

    -- Botón para borrar lo escrito (solo aparece si hay texto)
    local clearBtn = make("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -6, 0.5, 0),
        Size = UDim2.fromOffset(22, 22),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        Visible = false,
        ZIndex = 3
    }, searchHolder)
    iconBar(clearBtn, 10, 2, 45)
    iconBar(clearBtn, 10, 2, -45)
    clearBtn.Activated:Connect(function()
        searchBox.Text = ""
    end)
    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        clearBtn.Visible = searchBox.Text ~= ""
    end)

    local tabList = make("ScrollingFrame", {
        Position = UDim2.fromOffset(6, 44),
        Size = UDim2.new(1, -12, 1, -50),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 0,
        ScrollBarImageColor3 = T.Muted,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(),
        Active = true
    }, sidebar)

    make("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder
    }, tabList)

    -- Panel translúcido del contenido (a la derecha)
    local contentPanel = make("Frame", {
        Position = UDim2.fromOffset(148, 54),
        Size = UDim2.new(1, -156, 1, -62),
        BackgroundColor3 = T.Panel,
        BackgroundTransparency = 0.45,
        BorderSizePixel = 0,
        ZIndex = 3
    }, main)
    round(contentPanel, 12)

    local content = make("Frame", {
        Position = UDim2.fromOffset(156, 62),
        Size = UDim2.new(1, -172, 1, -78),
        BackgroundTransparency = 1,
        ZIndex = 3
    }, main)

    local pages = {}
    local currentEntry
    local searching = false
    local confirmBox, confirmDim
    local languageMenu
    local savedSize = UDim2.fromOffset(DEFAULT_W, DEFAULT_H)
    local prevPos, prevSize

    -- La ventana siempre está anclada al centro: su posición es
    -- UDim2.new(0.5, x, 0.5, y). Solo se suman desplazamientos relativos,
    -- sin convertir coordenadas absolutas (evita saltos al agarrarla).
    local function offsetLimits()
        local v, sz = gui.AbsoluteSize, main.AbsoluteSize
        local s = scale.Scale
        local halfW, halfH = sz.X / 2, sz.Y / 2
        return (-(v.X / 2 + halfW - 90)) / s, (v.X / 2 + halfW - 90) / s,
            (halfH - v.Y / 2) / s, (v.Y / 2 + halfH - 50) / s
    end

    local function setOffset(ox, oy)
        local minX, maxX, minY, maxY = offsetLimits()
        main.Position = UDim2.new(0.5, math.clamp(ox, minX, maxX), 0.5, math.clamp(oy, minY, maxY))
    end

    -- La ventana solo se mueve agarrando la barra superior,
    -- así no se desplaza por accidente al usar los controles.
    local startOX, startOY = 0, 0
    drag(top, function()
        if maximized then return false end
        startOX, startOY = main.Position.X.Offset, main.Position.Y.Offset
    end, function(d)
        setOffset(startOX + d.X / scale.Scale, startOY + d.Y / scale.Scale)
    end)

    -- Mantiene todo dentro de la pantalla al cambiar su tamaño
    local mini, miniLang
    local MINI_W, MINI_H = 208, 52

    local function clampToScreen()
        local v = gui.AbsoluteSize
        if mini then
            local p = mini.Position
            local x = v.X * p.X.Scale + p.X.Offset
            local y = v.Y * p.Y.Scale + p.Y.Offset
            mini.Position = UDim2.fromOffset(
                math.clamp(x, 0, math.max(0, v.X - MINI_W)),
                math.clamp(y, 0, math.max(0, v.Y - MINI_H)))
        end
        if main.Visible and not maximized then
            setOffset(main.Position.X.Offset, main.Position.Y.Offset)
        end
    end

    fitScreen()
    if workspace.CurrentCamera then
        track(workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
            fitScreen()
            task.defer(clampToScreen)
        end))
    end

    -- ───────────── Selección de pestañas y búsqueda ─────────────
    local resultsPage = make("ScrollingFrame", {
        Name = "SearchResults",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Active = true,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = T.Muted,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(),
        Visible = false
    }, content)
    make("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, resultsPage)
    make("UIPadding", {PaddingRight = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5)}, resultsPage)

    local function selectEntry(entry)
        currentEntry = entry
        for _, p in ipairs(pages) do
            local on = p == entry
            p.Page.Visible = on and not searching
            if p.Pill then
                animate(p.Pill, {ImageTransparency = on and 0.05 or 0.72}, 0.18)
            else
                animate(p.Button, {BackgroundTransparency = on and 0.35 or 1}, 0.15)
            end
            animate(p.Label, {TextTransparency = on and 0 or 0.25}, 0.15)
            for _, c in ipairs(p.Indicator:GetDescendants()) do
                if c:GetAttribute("Arm") then
                    animate(c, {BackgroundTransparency = on and 0 or 1}, 0.18)
                end
            end
            animate(p.Indicator, {
                Position = on and UDim2.new(1, -12, 0.5, 0) or UDim2.new(1, -4, 0.5, 0)
            }, 0.2)
        end
    end

    local function textsOf(source)
        if type(source) == "table" then
            return {source.ES or "", source.EN or ""}
        end
        return {tostring(source or "")}
    end

    local function matches(source, q)
        for _, t in ipairs(textsOf(source)) do
            if string.find(string.lower(t), q, 1, true) then return true end
        end
        return false
    end

    local function flash(inst)
        local stroke = inst:FindFirstChildOfClass("UIStroke")
        if stroke then
            local oldColor, oldThickness = stroke.Color, stroke.Thickness
            stroke.Color = T.Accent
            stroke.Thickness = 2
            task.delay(1.1, function()
                if stroke.Parent then
                    animate(stroke, {Color = oldColor, Thickness = oldThickness}, 0.3)
                end
            end)
        end
    end

    local function goTo(rec)
        searchBox.Text = ""
        if rec.Reveal then rec.Reveal() end
        selectEntry(rec.Entry)
        task.spawn(function()
            task.wait(0.06)
            local page = rec.Entry.Page
            if page.Parent and rec.Inst.Parent then
                local y = (rec.Inst.AbsolutePosition.Y - page.AbsolutePosition.Y) / scale.Scale
                    + page.CanvasPosition.Y - 10
                page.CanvasPosition = Vector2.new(0, math.max(0, y))
                flash(rec.Inst)
            end
        end)
    end

    local function runSearch()
        local q = string.lower(trim(searchBox.Text))
        for _, c in ipairs(resultsPage:GetChildren()) do
            if c:IsA("GuiObject") then c:Destroy() end
        end
        if q == "" then
            searching = false
            resultsPage.Visible = false
            selectEntry(currentEntry)
            return
        end
        searching = true
        for _, p in ipairs(pages) do p.Page.Visible = false end
        resultsPage.Visible = true

        local shown = 0
        for _, rec in ipairs(searchIndex) do
            if rec.Inst.Parent and matches(rec.Name, q) then
                shown += 1
                if shown > 40 then break end
                local r = make("TextButton", {
                    Size = UDim2.new(1, 0, 0, 44),
                    BackgroundColor3 = T.Element,
                    BackgroundTransparency = EA,
                    Text = "",
                    BorderSizePixel = 0,
                    AutoButtonColor = false,
                    LayoutOrder = shown
                }, resultsPage)
                round(r, 9)
                outline(r, nil, T)
                make("TextLabel", {
                    Position = UDim2.fromOffset(12, 4),
                    Size = UDim2.new(1, -24, 0, 20),
                    BackgroundTransparency = 1,
                    Text = tx(rec.Name),
                    TextColor3 = T.Text,
                    Font = Enum.Font.GothamMedium,
                    TextSize = 12,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    TextXAlignment = Enum.TextXAlignment.Left
                }, r)
                make("TextLabel", {
                    Position = UDim2.fromOffset(12, 23),
                    Size = UDim2.new(1, -24, 0, 16),
                    BackgroundTransparency = 1,
                    Text = tx(rec.Entry.Name) .. "  ›  " .. tx(rec.Kind),
                    TextColor3 = T.Muted,
                    Font = Enum.Font.Gotham,
                    TextSize = 10,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    TextXAlignment = Enum.TextXAlignment.Left
                }, r)
                r.Activated:Connect(function() goTo(rec) end)
            end
        end
        if shown == 0 then
            local empty = make("TextLabel", {
                Size = UDim2.new(1, 0, 0, 40),
                BackgroundTransparency = 1,
                Text = tx(L("Sin resultados.", "No results.")),
                TextColor3 = T.Muted,
                Font = Enum.Font.Gotham,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left
            }, resultsPage)
        end
    end
    searchBox:GetPropertyChangedSignal("Text"):Connect(runSearch)
    refreshExtras = function()
        if searching then runSearch() end
    end

    local function unindex(instance)
        for i = #searchIndex, 1, -1 do
            local inst = searchIndex[i].Inst
            if inst == instance or inst:IsDescendantOf(instance) then
                table.remove(searchIndex, i)
            end
        end
    end

    -- ═══════════ Estado, flags y autoguardado ═══════════
    local loaded = false
    local applyingConfig = false
    local saveQueued = false

    local function scheduleSave()
        if not options.AutoSave or not loaded or applyingConfig or saveQueued then
            return
        end
        saveQueued = true
        task.delay(1, function()
            saveQueued = false
            if gui.Parent then Window:SaveConfig() end
        end)
    end

    local function register(opt, get, set)
        if not opt.Flag then return end
        flagItems[opt.Flag] = {get = get, set = set}
        Window.Flags[opt.Flag] = get()
    end

    local function setFlag(opt, value)
        if not opt.Flag then return end
        Window.Flags[opt.Flag] = value
        local list = flagHandlers[opt.Flag]
        if list then
            for _, h in ipairs(list) do spawnCall(h, value) end
        end
        scheduleSave()
    end

    function Window:OnChanged(flag, fn)
        flagHandlers[flag] = flagHandlers[flag] or {}
        table.insert(flagHandlers[flag], fn)
        return function()
            local list = flagHandlers[flag]
            if not list then return end
            for i, f in ipairs(list) do
                if f == fn then
                    table.remove(list, i)
                    break
                end
            end
        end
    end

    -- ───────────── Menú de idioma (dentro de la ventana) ─────────────
    local function closeLanguageMenu()
        if languageMenu then
            languageMenu:Destroy()
            languageMenu = nil
        end
    end

    local function setLanguage(code)
        UI.Language = code
        lang.Text = code
        if miniLang then miniLang.Text = code end
        closeLanguageMenu()
        refreshLanguage()
        spawnCall(options.OnLanguageChanged, code)
        scheduleSave()
    end

    local function showLanguageMenu(anchor)
        if languageMenu then
            closeLanguageMenu()
            return
        end

        local inMain = main.Visible and anchor:IsDescendantOf(main)
        local blocker = make("TextButton", {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            Text = "",
            AutoButtonColor = false,
            ZIndex = 199
        }, inMain and main or gui)
        languageMenu = blocker
        blocker.Activated:Connect(closeLanguageMenu)

        local W, H = 150, 94
        local ap, as = anchor.AbsolutePosition, anchor.AbsoluteSize
        local x, y
        if inMain then
            local sc = scale.Scale
            local mp, ms = main.AbsolutePosition, main.AbsoluteSize
            local rx, ry = (ap.X - mp.X) / sc, (ap.Y - mp.Y) / sc
            local aw, ah = as.X / sc, as.Y / sc
            local mw, mh = ms.X / sc, ms.Y / sc
            x = math.clamp(rx + aw - W, 8, math.max(8, mw - W - 8))
            y = ry + ah + 6
            if y + H > mh - 8 then
                y = math.max(8, ry - H - 6)
            end
        else
            local v = gui.AbsoluteSize
            x = math.clamp(ap.X + as.X - W, 8, math.max(8, v.X - W - 8))
            y = ap.Y + as.Y + 6
            if y + H > v.Y - 8 then
                y = math.max(8, ap.Y - H - 6)
            end
        end

        local menu = make("Frame", {
            Position = UDim2.fromOffset(x, y),
            Size = UDim2.fromOffset(W, H),
            BackgroundColor3 = T.Panel,
            BorderSizePixel = 0,
            Active = true,
            ZIndex = 200
        }, blocker)
        round(menu, 10)
        outline(menu, nil, T)

        make("TextLabel", {
            Position = UDim2.fromOffset(10, 4),
            Size = UDim2.new(1, -20, 0, 22),
            BackgroundTransparency = 1,
            Text = UI.Language == "ES" and "IDIOMA" or "LANGUAGE",
            TextColor3 = T.Muted,
            Font = Enum.Font.GothamBold,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 201
        }, menu)

        local function option(text, code, yy)
            local b = make("TextButton", {
                Position = UDim2.fromOffset(6, yy),
                Size = UDim2.new(1, -12, 0, 29),
                BackgroundColor3 = UI.Language == code and T.Border or T.Element,
                Text = text,
                TextColor3 = T.Text,
                Font = Enum.Font.GothamMedium,
                TextSize = 12,
                BorderSizePixel = 0,
                AutoButtonColor = false,
                ZIndex = 201
            }, menu)
            round(b, 7)
            b.Activated:Connect(function()
                setLanguage(code)
            end)
        end

        option("Español", "ES", 28)
        option("English", "EN", 60)
    end

    lang.Activated:Connect(function()
        showLanguageMenu(lang)
    end)

    -- ───────────── Barra flotante (NEXUS HUB) ─────────────
    -- Usa tus tres imágenes (píldora, flechas de mover y personas), incrustadas
    -- en el script y recortadas sin fondo blanco. Si el entorno no puede mostrar
    -- imágenes incrustadas, se dibuja una versión equivalente con formas.
    -- Es una marca fija: no cambia con el tema.
    local IMG_PILL = embeddedImage("pill")
    local IMG_ARROWS = embeddedImage("arrows")
    local IMG_PEOPLE = embeddedImage("people")
    local pillImages = IMG_PILL ~= "" and IMG_ARROWS ~= "" and IMG_PEOPLE ~= ""

    local SEP_X = 50
    local PILL_FILL = Color3.fromRGB(12, 10, 14)
    local PILL_BORDER = Color3.fromRGB(52, 22, 130)
    local PILL_GRAY = Color3.fromRGB(140, 140, 140)
    local PILL_BADGE = Color3.fromRGB(8, 14, 24)
    local WHITE = Color3.fromRGB(255, 255, 255)

    mini = make("Frame", {
        Name = "MiniNexus",
        Position = UDim2.new(0.5, -MINI_W / 2, 0, 12),
        Size = UDim2.fromOffset(MINI_W, MINI_H),
        BackgroundColor3 = PILL_FILL,
        BackgroundTransparency = pillImages and 1 or 0.38,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 100
    }, gui)
    if pillImages then
        make("ImageLabel", {
            Name = "PillImage",
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            Image = IMG_PILL,
            ScaleType = Enum.ScaleType.Stretch,
            ImageTransparency = 0.2,
            ZIndex = 100
        }, mini)
    else
        round(mini, MINI_H / 2)
        local miniStroke = outline(mini, PILL_BORDER, T)
        miniStroke.Thickness = 1.5
        miniStroke.Transparency = 0
    end

    local miniMove = make("TextButton", {
        Name = "Move",
        Size = UDim2.fromOffset(SEP_X, MINI_H),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 101
    }, mini)

    -- Triángulo relleno dibujado con un rombo recortado (solo para la versión sin imágenes)
    local function triangle(parentObj, dir, base, color, x, y, z)
        local vertical = dir == "up" or dir == "down"
        local w = vertical and base or base / 2
        local h = vertical and base / 2 or base
        local clip = make("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, x, 0.5, y),
            Size = UDim2.fromOffset(w, h),
            BackgroundTransparency = 1,
            ClipsDescendants = true,
            ZIndex = z
        }, parentObj)
        local px, py = 0.5, 0.5
        if dir == "up" then py = 1
        elseif dir == "down" then py = 0
        elseif dir == "left" then px = 1
        else px = 0 end
        local side = base / math.sqrt(2)
        make("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(px, py),
            Size = UDim2.fromOffset(side, side),
            Rotation = 45,
            BackgroundColor3 = color,
            BorderSizePixel = 0,
            ZIndex = z
        }, clip)
    end

    -- Flechas de mover
    if pillImages then
        make("ImageLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(17, 16.5),
            BackgroundTransparency = 1,
            Image = IMG_ARROWS,
            ZIndex = 102
        }, miniMove)
    else
        local function moveLine(w, h)
            local f = make("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromOffset(w, h),
                BackgroundColor3 = PILL_GRAY,
                BorderSizePixel = 0,
                ZIndex = 102
            }, miniMove)
            round(f, 1)
        end
        moveLine(12, 1.5)
        moveLine(1.5, 12)
        triangle(miniMove, "up", 5.5, PILL_GRAY, 0, -7.4, 102)
        triangle(miniMove, "down", 5.5, PILL_GRAY, 0, 7.4, 102)
        triangle(miniMove, "left", 5.5, PILL_GRAY, -7.4, 0, 102)
        triangle(miniMove, "right", 5.5, PILL_GRAY, 7.4, 0, 102)
    end

    -- Separador fino casi de altura completa
    make("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, SEP_X, 0.5, 0),
        Size = UDim2.fromOffset(1, MINI_H - 8),
        BackgroundColor3 = Color3.fromRGB(150, 150, 150),
        BackgroundTransparency = 0.55,
        BorderSizePixel = 0,
        ZIndex = 101
    }, mini)

    local miniOpen = make("TextButton", {
        Name = "Open",
        Position = UDim2.fromOffset(SEP_X + 1, 0),
        Size = UDim2.new(1, -(SEP_X + 1), 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 101
    }, mini)

    -- Insignia hexagonal oscura (tres rectángulos girados 0°, 60° y 120°)
    local R = 11.5
    local badge = make("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0, 26, 0.5, 0),
        Size = UDim2.fromOffset(R * 2, R * 2),
        BackgroundTransparency = 1,
        ZIndex = 102
    }, miniOpen)
    for _, rot in ipairs({0, 60, 120}) do
        local piece = make("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(R, R * math.sqrt(3)),
            Rotation = rot,
            BackgroundColor3 = PILL_BADGE,
            BorderSizePixel = 0,
            ZIndex = 102
        }, badge)
        round(piece, 3)
    end
    local miniIcon = badge

    -- Personas
    if pillImages then
        make("ImageLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0.5),
            Size = UDim2.fromOffset(14, 9.5),
            BackgroundTransparency = 1,
            Image = IMG_PEOPLE,
            ZIndex = 103
        }, miniIcon)
    else
        local function person(x, y, s, gap, z)
            local head = make("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(0.5, x, 0.5, y - 7 * s),
                Size = UDim2.fromOffset(8 * s, 8 * s),
                BackgroundColor3 = WHITE,
                BorderSizePixel = 0,
                ZIndex = z
            }, miniIcon)
            round(head, 8 * s)
            local clip = make("Frame", {
                AnchorPoint = Vector2.new(0.5, 0),
                Position = UDim2.new(0.5, x, 0.5, y - 1.5 * s),
                Size = UDim2.fromOffset(16 * s, 8 * s),
                BackgroundTransparency = 1,
                ClipsDescendants = true,
                ZIndex = z
            }, miniIcon)
            local dome = make("Frame", {
                Size = UDim2.fromOffset(16 * s, 16 * s),
                BackgroundColor3 = WHITE,
                BorderSizePixel = 0,
                ZIndex = z
            }, clip)
            round(dome, 16 * s)
            if gap then
                make("UIStroke", {Color = PILL_BADGE, Thickness = 1}, head)
                make("UIStroke", {Color = PILL_BADGE, Thickness = 1}, dome)
            end
        end
        person(-3.6, 2.55, 0.5, false, 103)
        person(3.6, 2.55, 0.5, false, 103)
        person(0, 1.5, 0.6, true, 104)
    end

    local miniText = make("TextLabel", {
        Position = UDim2.fromOffset(55, 0),
        Size = UDim2.new(1, -62, 1, 0),
        BackgroundTransparency = 1,
        RichText = true,
        Text = options.MiniText or "NEXUS HUB",
        TextColor3 = WHITE,
        Font = Enum.Font.GothamMedium,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 102
    }, miniOpen)
    -- La referencia usa una tipografía redondeada: Nunito si existe
    pcall(function() miniText.Font = Enum.Font.Nunito end)

    -- Mover la barra: solo desde las flechas de la izquierda, sin retraso
    local miniSX, miniSY = 0, 0
    drag(miniMove, function()
        local v = gui.AbsoluteSize
        local p = mini.Position
        miniSX = v.X * p.X.Scale + p.X.Offset
        miniSY = v.Y * p.Y.Scale + p.Y.Offset
    end, function(d)
        local v = gui.AbsoluteSize
        mini.Position = UDim2.fromOffset(
            math.clamp(miniSX + d.X, 0, math.max(0, v.X - MINI_W)),
            math.clamp(miniSY + d.Y, 0, math.max(0, v.Y - MINI_H)))
    end)

    -- ───────────── Redimensionar ─────────────
    local GRIP = TOUCH and 40 or 32
    local grip = make("TextButton", {
        Name = "ResizeGrip",
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -4, 1, -4),
        Size = UDim2.fromOffset(GRIP, GRIP),
        BackgroundTransparency = 1,
        Text = "",
        BorderSizePixel = 0,
        AutoButtonColor = false,
        ZIndex = 10
    }, main)
    local function gripLine(len, off)
        local f = make("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(1, -off, 1, -off),
            Size = UDim2.fromOffset(len, 2),
            Rotation = -45,
            BackgroundColor3 = T.Muted,
            BackgroundTransparency = 0.2,
            BorderSizePixel = 0,
            ZIndex = 11
        }, grip)
        round(f, 1)
    end
    gripLine(8, 9)
    gripLine(14, 15)

    local gW, gH, gOX, gOY = 0, 0, 0, 0
    drag(grip, function()
        if maximized then return false end
        gW, gH = main.Size.X.Offset, main.Size.Y.Offset
        gOX, gOY = main.Position.X.Offset, main.Position.Y.Offset
    end, function(d)
        local width = math.clamp(gW + d.X / scale.Scale, 320, 900)
        local height = math.clamp(gH + d.Y / scale.Scale, 230, 700)
        main.Size = UDim2.fromOffset(width, height)
        -- como la ventana está anclada al centro, se compensa para que
        -- la esquina superior izquierda se quede quieta
        main.Position = UDim2.new(0.5, gOX + (width - gW) / 2, 0.5, gOY + (height - gH) / 2)
        savedSize = main.Size
    end)

    -- ───────────── Maximizar / minimizar / restaurar ─────────────
    applyMaximize = function(instant)
        local v, s = gui.AbsoluteSize, scale.Scale
        local pos = UDim2.new(0.5, 0, 0.5, 0)
        local sz = UDim2.fromOffset((v.X - 16) / s, (v.Y - 16) / s)
        if instant then
            main.Position = pos
            main.Size = sz
        else
            animate(main, {Position = pos, Size = sz}, 0.25)
        end
    end

    local function setMaximized(on, instant)
        on = on == true
        if on == maximized then return end
        if on then
            prevPos, prevSize = main.Position, main.Size
            maximized = true
            applyMaximize(instant)
            grip.Visible = false
            maxIcon.Size = UDim2.fromOffset(9, 9)
        else
            maximized = false
            local pos = prevPos or main.Position
            local sz = prevSize or savedSize
            if instant then
                main.Position = pos
                main.Size = sz
            else
                animate(main, {Position = pos, Size = sz}, 0.25)
            end
            savedSize = sz
            grip.Visible = true
            maxIcon.Size = UDim2.fromOffset(12, 12)
        end
    end

    maxButton.Activated:Connect(function()
        closeLanguageMenu()
        setMaximized(not maximized)
    end)

    local function openMain()
        closeLanguageMenu()
        mini.Visible = false
        main.Visible = true
        if maximized then
            applyMaximize(true)
        else
            main.Size = UDim2.fromOffset(savedSize.X.Offset, 55)
            animate(main, {Size = savedSize}, 0.3)
        end
    end

    local function doMinimize()
        closeLanguageMenu()
        if maximized then setMaximized(false, true) end
        savedSize = main.Size
        main.Visible = false
        mini.Visible = true
    end

    miniOpen.Activated:Connect(function()
        openMain()
    end)
    minimize.Activated:Connect(doMinimize)

    -- Tecla para mostrar/ocultar toda la interfaz
    if options.ToggleKey then
        track(UIS.InputBegan:Connect(function(input, processed)
            if processed or UIS:GetFocusedTextBox() then return end
            if input.KeyCode == options.ToggleKey then
                gui.Enabled = not gui.Enabled
            end
        end))
    end

    -- ───────────── Confirmación al cerrar (dentro de la ventana) ─────────────
    local function closeDialog()
        if not confirmDim then return end
        local dim, box = confirmDim, confirmBox
        confirmDim, confirmBox = nil, nil
        animate(dim, {BackgroundTransparency = 1}, 0.15)
        animate(box, {GroupTransparency = 1}, 0.15)
        task.delay(0.18, function()
            unbind(dim)
            dim:Destroy()
        end)
    end

    local function askClose()
        if options.ConfirmClose == false then
            spawnCall(options.OnClose)
            Window:Destroy()
            return
        end
        if confirmBox then return end

        confirmDim = make("Frame", {
            Size = UDim2.fromScale(1, 1),
            BackgroundColor3 = T.Shade,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Active = true,
            ZIndex = 59
        }, main)
        round(confirmDim, 14)
        animate(confirmDim, {BackgroundTransparency = 0.35}, 0.2)

        confirmBox = make("CanvasGroup", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(316, 196),
            BackgroundColor3 = T.Panel,
            BorderSizePixel = 0,
            GroupTransparency = 1,
            Active = true,
            ZIndex = 60
        }, confirmDim)
        round(confirmBox, 14)
        local boxScale = make("UIScale", {Scale = 0.92}, confirmBox)
        animate(confirmBox, {GroupTransparency = 0}, 0.2)
        animate(boxScale, {Scale = 1}, 0.24)

        -- El borde va dentro del grupo para que se desvanezca junto con todo
        local border = make("Frame", {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            ZIndex = 8
        }, confirmBox)
        round(border, 14)
        outline(border, nil, T)

        local iconCircle = make("Frame", {
            Position = UDim2.fromOffset(16, 16),
            Size = UDim2.fromOffset(36, 36),
            BackgroundColor3 = T.Warning,
            BackgroundTransparency = 0.82,
            BorderSizePixel = 0
        }, confirmBox)
        round(iconCircle, 18)
        make("TextLabel", {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            Text = "!",
            TextColor3 = T.Warning,
            Font = Enum.Font.GothamBold,
            TextSize = 20
        }, iconCircle)

        local title = make("TextLabel", {
            Position = UDim2.fromOffset(62, 15),
            Size = UDim2.new(1, -78, 0, 22),
            BackgroundTransparency = 1,
            TextColor3 = T.Text,
            Font = Enum.Font.GothamBold,
            TextSize = 15,
            TextXAlignment = Enum.TextXAlignment.Left
        }, confirmBox)
        bind(title, "Text", function()
            return tx(L("¿Cerrar la interfaz?", "Close the interface?"))
        end)

        local subtitle = make("TextLabel", {
            Position = UDim2.fromOffset(62, 37),
            Size = UDim2.new(1, -78, 0, 16),
            BackgroundTransparency = 1,
            TextColor3 = T.Muted,
            Font = Enum.Font.Gotham,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left
        }, confirmBox)
        bind(subtitle, "Text", function()
            return tx(L("Se cerrará por completo.", "It will close completely."))
        end)

        local body = make("TextLabel", {
            Position = UDim2.fromOffset(16, 66),
            Size = UDim2.new(1, -32, 0, 58),
            BackgroundTransparency = 1,
            TextColor3 = T.Muted,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top
        }, confirmBox)
        bind(body, "Text", function()
            local saved = options.AutoSave
            if UI.Language == "ES" then
                return "La interfaz desaparecerá y tendrás que ejecutar el script otra vez para abrirla. "
                    .. (saved and "Tu configuración se guardará automáticamente."
                        or "Los cambios que no hayas guardado se perderán.")
                    .. " Si solo quieres apartarla, usa Minimizar."
            end
            return "The interface will disappear and you will need to run the script again to open it. "
                .. (saved and "Your settings will be saved automatically."
                    or "Any unsaved changes will be lost.")
                .. " If you only want it out of the way, use Minimize."
        end)

        make("Frame", {
            Position = UDim2.fromOffset(16, 132),
            Size = UDim2.new(1, -32, 0, 1),
            BackgroundColor3 = T.Border,
            BackgroundTransparency = 0.3,
            BorderSizePixel = 0
        }, confirmBox)

        local function dialogButton(es, en, x, w, fill, textColor)
            local b = make("TextButton", {
                Position = UDim2.fromOffset(x, 146),
                Size = UDim2.fromOffset(w, 36),
                BackgroundColor3 = fill,
                TextColor3 = textColor,
                Font = Enum.Font.GothamMedium,
                TextSize = 12,
                BorderSizePixel = 0,
                AutoButtonColor = false,
                ZIndex = 9
            }, confirmBox)
            round(b, 9)
            bind(b, "Text", function() return tx(L(es, en)) end)
            return b
        end

        local cancel = dialogButton("Cancelar", "Cancel", 16, 88, T.Element, T.Text)
        local minimizeBtn = dialogButton("Minimizar", "Minimize", 112, 96, T.Element, T.Text)
        local confirm = dialogButton("Cerrar", "Close", 216, 84, T.Error, Color3.fromRGB(255, 255, 255))

        cancel.Activated:Connect(closeDialog)
        minimizeBtn.Activated:Connect(function()
            closeDialog()
            doMinimize()
        end)
        confirm.Activated:Connect(function()
            if options.AutoSave then
                pcall(function() Window:SaveConfig() end)
            end
            spawnCall(options.OnClose)
            Window:Destroy()
        end)
    end
    close.Activated:Connect(askClose)
    close.Activated:Connect(askClose)

    -- ═══════════ Configuración y estado ═══════════
    local function windowGeometry()
        if maximized then return nil end
        return {
            mode = "center",
            x = math.floor(main.Position.X.Offset), y = math.floor(main.Position.Y.Offset),
            w = math.floor(savedSize.X.Offset), h = math.floor(savedSize.Y.Offset)
        }
    end

    local function applyGeometry(g)
        if type(g) ~= "table" or g.mode ~= "center" or maximized then return end
        if type(g.w) == "number" and type(g.h) == "number" then
            main.Size = UDim2.fromOffset(math.clamp(g.w, 320, 900), math.clamp(g.h, 230, 700))
            savedSize = main.Size
        end
        if type(g.x) == "number" and type(g.y) == "number" then
            setOffset(g.x, g.y)
        end
    end

    -- ═══════════ Disposición: orden de controles y posición de la barra ═══════════
    local bgSource          -- nil = fondo original de la ventana
    local editables = {}    -- controles que se pueden reordenar
    local editMode = false
    local editListeners = {}

    local function miniPosition()
        local v, p = gui.AbsoluteSize, mini.Position
        return {
            x = math.floor(v.X * p.X.Scale + p.X.Offset),
            y = math.floor(v.Y * p.Y.Scale + p.Y.Offset)
        }
    end

    local function applyMini(m)
        if type(m) ~= "table" or type(m.x) ~= "number" or type(m.y) ~= "number" then return end
        mini.Position = UDim2.fromOffset(m.x, m.y)
        task.defer(clampToScreen)
    end

    -- Barra del modo edición: solo aparece mientras se edita y tiene su propia X
    local editBar = make("Frame", {
        Name = "EditBar",
        AnchorPoint = Vector2.new(0.5, 1),
        Position = UDim2.new(0.5, 0, 1, 56),
        Size = UDim2.fromOffset(262, 46),
        BackgroundColor3 = T.Panel,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 40
    }, main)
    round(editBar, 23)
    outline(editBar, T.Accent, T)

    local editTitle = make("TextLabel", {
        Position = UDim2.fromOffset(18, 6),
        Size = UDim2.new(1, -72, 0, 18),
        BackgroundTransparency = 1,
        TextColor3 = T.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 41
    }, editBar)
    bind(editTitle, "Text", function() return tx(L("Modo edición", "Edit mode")) end)

    local editHint = make("TextLabel", {
        Position = UDim2.fromOffset(18, 24),
        Size = UDim2.new(1, -72, 0, 14),
        BackgroundTransparency = 1,
        TextColor3 = T.Muted,
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 41
    }, editBar)
    bind(editHint, "Text", function()
        return tx(L("Arrastra cualquier control para moverlo", "Drag any control to move it"))
    end)

    local editClose = make("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -8, 0.5, 0),
        Size = UDim2.fromOffset(32, 32),
        BackgroundColor3 = T.Accent,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 41
    }, editBar)
    round(editClose, 16)
    for _, rot in ipairs({45, -45}) do
        local bar = make("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(13, 2),
            Rotation = rot,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BorderSizePixel = 0,
            ZIndex = 42
        }, editClose)
        round(bar, 1)
    end

    -- ─── Arrastrar para reordenar, con animaciones ───
    -- Al empezar a arrastrar, la lista pasa a posiciones manuales: el control
    -- sigue al dedo y los demás se deslizan suavemente al hueco que corresponde.
    -- Al soltar, el control se acomoda con una animación y se restablece la lista.
    local reorder, dropping = nil, false
    local reorderConns = {}

    local function stopReorderConns()
        for _, c in ipairs(reorderConns) do c:Disconnect() end
        reorderConns = {}
    end
    table.insert(dragStops, stopReorderConns)

    local function listItems(container)
        local items = {}
        for _, c in ipairs(container:GetChildren()) do
            if c:IsA("GuiObject") and c.Visible then table.insert(items, c) end
        end
        table.sort(items, function(a, b) return a.LayoutOrder < b.LayoutOrder end)
        return items
    end

    local function computePositions(order, heights, pad)
        local pos, y = {}, 0
        for _, it in ipairs(order) do
            pos[it] = y
            y = y + heights[it] + pad
        end
        return pos, math.max(0, y - pad)
    end

    -- Orden completo: los elementos fijos (secciones, etiquetas) no se mueven;
    -- solo los controles editables se permutan entre sus huecos.
    local function fullOrder(items, perm)
        local out, idx = {}, 0
        for _, it in ipairs(items) do
            if it:GetAttribute("NxIdx") then
                idx = idx + 1
                out[#out + 1] = perm[idx]
            else
                out[#out + 1] = it
            end
        end
        return out
    end

    local function liftOverlay(st, lifted)
        local stroke = st.overlay:FindFirstChildOfClass("UIStroke")
        animate(st.overlay, {BackgroundTransparency = lifted and 0.25 or 0.55}, 0.18)
        if stroke then
            animate(stroke, {Thickness = lifted and 2.5 or 1, Transparency = lifted and 0 or 0.2}, 0.18)
        end
    end

    local function freezeLayout(st)
        local container = st.container
        local pos, total = computePositions(st.items, st.heights, st.pad)
        local padObj = container:FindFirstChildOfClass("UIPadding")
        st.total = total
        st.padTop = padObj and padObj.PaddingTop.Offset or 0
        st.padBottom = padObj and padObj.PaddingBottom.Offset or 0
        for _, it in ipairs(st.items) do
            it.Position = UDim2.fromOffset(0, pos[it])
        end
        st.layout.Parent = nil
        if container:IsA("ScrollingFrame") then
            st.autoCanvas = container.AutomaticCanvasSize
            container.AutomaticCanvasSize = Enum.AutomaticSize.None
            container.CanvasSize = UDim2.fromOffset(0, total + st.padTop + st.padBottom)
        else
            st.autoSize = container.AutomaticSize
            container.AutomaticSize = Enum.AutomaticSize.None
            container.Size = UDim2.new(container.Size.X.Scale, container.Size.X.Offset,
                0, total + st.padTop + st.padBottom)
        end
        st.startY = pos[st.dragged]
        st.startScrollY = st.scroller and st.scroller.CanvasPosition.Y or 0
        st.targetPos = pos
        st.oldZ = st.dragged.ZIndex
        st.dragged.ZIndex = 30
        st.frozen = true
        liftOverlay(st, true)
    end

    local function unfreezeLayout(st)
        local container = st.container
        local slots = {}
        for _, it in ipairs(st.editableList) do table.insert(slots, it.LayoutOrder) end
        table.sort(slots)
        for i, it in ipairs(st.perm) do it.LayoutOrder = slots[i] end
        for _, it in ipairs(st.items) do it.Position = UDim2.new() end
        st.dragged.ZIndex = st.oldZ
        st.layout.Parent = container
        if container:IsA("ScrollingFrame") then
            container.AutomaticCanvasSize = st.autoCanvas
            container.CanvasSize = UDim2.new()
        else
            container.AutomaticSize = st.autoSize
            container.Size = UDim2.new(container.Size.X.Scale, container.Size.X.Offset, 0, 0)
        end
        liftOverlay(st, false)
        scheduleSave()
    end

    local function updateReorder(st, dyUnits)
        local h = st.heights[st.dragged]
        local scroller = st.scroller
        local scrollDelta = 0
        if scroller then
            -- desplazamiento automático al acercarse a los bordes (el gesto del
            -- dedo no desplaza la lista porque su ScrollingEnabled está apagado)
            local top = scroller.AbsolutePosition.Y
            local bottom = top + scroller.AbsoluteSize.Y
            local a = st.dragged.AbsolutePosition.Y
            local b = a + st.dragged.AbsoluteSize.Y
            local maxScroll = math.max(0,
                (scroller.AbsoluteCanvasSize.Y - scroller.AbsoluteWindowSize.Y) / scale.Scale)
            if a < top + 16 then
                scroller.CanvasPosition = Vector2.new(0, math.clamp(scroller.CanvasPosition.Y - 6, 0, maxScroll))
            elseif b > bottom - 16 then
                scroller.CanvasPosition = Vector2.new(0, math.clamp(scroller.CanvasPosition.Y + 6, 0, maxScroll))
            end
            scrollDelta = scroller.CanvasPosition.Y - st.startScrollY
        end

        local newY = math.clamp(st.startY + dyUnits + scrollDelta, 0, math.max(0, st.total - h))
        st.dragged.Position = UDim2.fromOffset(0, newY)
        local center = newY + h / 2

        -- ¿en qué hueco debe quedar? el más cercano al centro del control
        local others = {}
        for _, it in ipairs(st.perm) do
            if it ~= st.dragged then others[#others + 1] = it end
        end
        local bestK, bestDist, bestPos, bestTrial
        for k = 1, #others + 1 do
            local trial = {}
            for i = 1, #others + 1 do
                if i == k then
                    trial[i] = st.dragged
                elseif i < k then
                    trial[i] = others[i]
                else
                    trial[i] = others[i - 1]
                end
            end
            local pos = computePositions(fullOrder(st.items, trial), st.heights, st.pad)
            local dist = math.abs(pos[st.dragged] + h / 2 - center)
            if not bestDist or dist < bestDist then
                bestK, bestDist, bestPos, bestTrial = k, dist, pos, trial
            end
        end

        if bestK ~= st.currentK then
            st.currentK = bestK
            st.perm = bestTrial
            st.targetPos = bestPos
            for _, it in ipairs(st.items) do
                if it ~= st.dragged then
                    animate(it, {Position = UDim2.fromOffset(0, bestPos[it])}, 0.22)
                end
            end
        end
    end

    local function restoreScroll(st)
        if st.scroller and st.scroller.Parent then
            st.scroller.ScrollingEnabled = st.scrollWas ~= false
        end
    end

    local function endReorder(st)
        reorder = nil
        if not st.frozen then
            restoreScroll(st)
            return
        end
        dropping = true
        local slot = st.targetPos[st.dragged]
        animate(st.dragged, {Position = UDim2.fromOffset(0, slot)}, 0.24)
        task.delay(0.27, function()
            dropping = false
            if st.container.Parent then unfreezeLayout(st) end
            restoreScroll(st)
        end)
    end

    local function startReorder(inst, ov, input)
        if reorder or dropping then return end
        local container = inst.Parent
        local layout = container and container:FindFirstChildOfClass("UIListLayout")
        if not layout then return end

        local items = listItems(container)
        local heights, editableList, perm = {}, {}, {}
        for _, it in ipairs(items) do
            heights[it] = it.AbsoluteSize.Y / scale.Scale
            if it:GetAttribute("NxIdx") then
                table.insert(editableList, it)
                perm[#perm + 1] = it
            end
        end

        local st = {
            container = container, layout = layout, items = items, heights = heights,
            pad = layout.Padding.Offset, dragged = inst, overlay = ov,
            editableList = editableList, perm = perm, frozen = false
        }
        reorder = st

        -- Mientras se arrastra un control, la lista NO debe desplazarse con el dedo
        local scroller = container:IsA("ScrollingFrame") and container
            or container:FindFirstAncestorWhichIsA("ScrollingFrame")
        st.scroller = scroller
        if scroller then
            st.scrollWas = scroller.ScrollingEnabled
            scroller.ScrollingEnabled = false
        end

        local startPos
        local finished = false
        local function now()
            if input.UserInputType == Enum.UserInputType.Touch then
                return Vector2.new(input.Position.X, input.Position.Y)
            end
            return UIS:GetMouseLocation()
        end
        local function finish()
            if finished then return end
            finished = true
            stopReorderConns()
            endReorder(st)
        end

        table.insert(reorderConns, RunService.RenderStepped:Connect(function()
            local cur = now()
            if not startPos then
                startPos = cur
                return
            end
            local d = cur - startPos
            if not st.frozen then
                if d.Magnitude < 5 then return end
                freezeLayout(st)
            end
            updateReorder(st, d.Y / scale.Scale)
        end))
        table.insert(reorderConns, UIS.InputEnded:Connect(function(i)
            if i == input or (input.UserInputType == Enum.UserInputType.MouseButton1
                and i.UserInputType == Enum.UserInputType.MouseButton1) then
                finish()
            end
        end))
        table.insert(reorderConns, input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then finish() end
        end))
    end

    local function removeOverlay(inst)
        local ov = inst:FindFirstChild("NxEdit")
        if not ov then return end
        ov.Name = "NxEditClosing"
        local stroke = ov:FindFirstChildOfClass("UIStroke")
        animate(ov, {BackgroundTransparency = 1}, 0.2)
        if stroke then animate(stroke, {Transparency = 1}, 0.2) end
        for _, d in ipairs(ov:GetDescendants()) do
            if d:IsA("Frame") then animate(d, {BackgroundTransparency = 1}, 0.2) end
        end
        task.delay(0.22, function()
            if ov.Parent then ov:Destroy() end
        end)
    end

    -- Capa de edición: el control se agarra con un dedo desde cualquier punto
    local function addOverlay(inst)
        if inst:FindFirstChild("NxEdit") then return end
        local ov = make("Frame", {
            Name = "NxEdit",
            Size = inst.Name == "Group" and UDim2.new(1, 0, 0, 40) or UDim2.fromScale(1, 1),
            BackgroundColor3 = T.Shade,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Active = true,
            ZIndex = 50
        }, inst)
        round(ov, 9)
        local stroke = make("UIStroke", {Color = T.Accent, Thickness = 1, Transparency = 1}, ov)

        -- Punto de agarre: seis puntos
        local gripBox = make("Frame", {
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -12, 0.5, 0),
            Size = UDim2.fromOffset(11, 18),
            BackgroundTransparency = 1,
            ZIndex = 51
        }, ov)
        for col = 0, 1 do
            for row = 0, 2 do
                local dot = make("Frame", {
                    Position = UDim2.fromOffset(col * 7, row * 7),
                    Size = UDim2.fromOffset(4, 4),
                    BackgroundColor3 = T.Text,
                    BackgroundTransparency = 0.25,
                    BorderSizePixel = 0,
                    ZIndex = 51
                }, gripBox)
                round(dot, 2)
            end
        end

        animate(ov, {BackgroundTransparency = 0.55}, 0.25)
        animate(stroke, {Transparency = 0.2}, 0.25)

        ov.InputBegan:Connect(function(input)
            if isPress(input) then
                startReorder(inst, ov, input)
            end
        end)
    end

    -- Orden estable dentro de su contenedor (LayoutOrder = orden de creación)
    local function orderInstance(instance, editable)
        local p = instance.Parent
        if not p then return end
        local n = (p:GetAttribute("NxCount") or 0) + 1
        p:SetAttribute("NxCount", n)
        instance.LayoutOrder = n
        if editable then
            instance:SetAttribute("NxIdx", n)
            table.insert(editables, instance)
            if editMode then addOverlay(instance) end
        end
    end

    local function collectOrder()
        local byContainer = {}
        for _, inst in ipairs(editables) do
            local p = inst.Parent
            local id = p and p:GetAttribute("NxContainer")
            if id then
                byContainer[id] = byContainer[id] or {}
                table.insert(byContainer[id], inst)
            end
        end
        local result = {}
        for id, list in pairs(byContainer) do
            table.sort(list, function(a, b) return a.LayoutOrder < b.LayoutOrder end)
            local ids = {}
            for _, inst in ipairs(list) do
                table.insert(ids, inst:GetAttribute("NxIdx"))
            end
            result[id] = ids
        end
        return result
    end

    local function applyOrder(order)
        if type(order) ~= "table" then return end
        for id, ids in pairs(order) do
            if type(ids) == "table" then
                local members = {}
                for _, inst in ipairs(editables) do
                    local p = inst.Parent
                    if p and p:GetAttribute("NxContainer") == id then
                        members[inst:GetAttribute("NxIdx")] = inst
                    end
                end
                local slots, ordered = {}, {}
                for _, idx in ipairs(ids) do
                    local inst = members[idx]
                    if inst then
                        table.insert(slots, inst.LayoutOrder)
                        table.insert(ordered, inst)
                    end
                end
                table.sort(slots)
                for i, inst in ipairs(ordered) do
                    inst.LayoutOrder = slots[i]
                end
            end
        end
    end

    function Window:CanPersist()
        return store.Persistent ~= false
    end

    function Window:ExportConfig()
        local flags = {}
        for flag, item in pairs(flagItems) do
            flags[flag] = item.get()
        end
        local data = {
            version = 6,
            flags = flags,
            meta = {
                theme = themeName,
                language = UI.Language,
                scale = userScale,
                window = windowGeometry(),
                mini = miniPosition(),
                order = collectOrder(),
                background = bgSource
            }
        }
        local ok, json = pcall(function()
            return HttpService:JSONEncode(data)
        end)
        if ok then return json end
        return nil
    end

    function Window:ImportConfig(json)
        if type(json) ~= "string" then return false end
        local ok, data = pcall(function()
            return HttpService:JSONDecode(json)
        end)
        if not ok or type(data) ~= "table" then return false end

        local flags, meta = data.flags, data.meta
        if flags == nil then flags = data end   -- formato plano de v5.x

        applyingConfig = true
        for flag, value in pairs(flags) do
            local item = flagItems[flag]
            if item then pcall(item.set, value) end
        end
        if type(meta) == "table" and options.RestoreLayout ~= false then
            if type(meta.theme) == "string" and UI.Themes[meta.theme] then
                Window:SetTheme(meta.theme)
            end
            if meta.language == "ES" or meta.language == "EN" then
                setLanguage(meta.language)
            end
            if type(meta.scale) == "number" then
                Window:SetUIScale(meta.scale)
            end
            applyGeometry(meta.window)
            applyMini(meta.mini)
            applyOrder(meta.order)
            if meta.background ~= nil then
                local src = meta.background
                task.spawn(function() Window:SetBackground(src) end)
            end
        end
        applyingConfig = false
        return true
    end

    function Window:SaveConfig(name)
        local json = Window:ExportConfig()
        if not json then return false end
        return store.Save(name or options.ConfigName or "default", json) == true
    end

    function Window:LoadConfig(name)
        local json = store.Load(name or options.ConfigName or "default")
        if not json then return false end
        return Window:ImportConfig(json)
    end

    function Window:DeleteConfig(name)
        if not store.Delete then return false end
        return store.Delete(name or options.ConfigName or "default") == true
    end

    function Window:ListConfigs()
        if not store.List then return {} end
        local out = {}
        for _, n in ipairs(store.List()) do
            if string.sub(n, 1, 1) ~= "_" then table.insert(out, n) end
        end
        return out
    end

    -- ═══════════ Temas en caliente ═══════════
    local function applyTheme(newColors, name)
        local map = {}
        for k, v in pairs(T) do
            if typeof(v) == "Color3" and typeof(newColors[k]) == "Color3" then
                local id = cid(v)
                if map[id] == nil then map[id] = newColors[k] end
            end
        end
        for k, v in pairs(newColors) do
            if T[k] ~= nil then T[k] = v end
        end
        recolor(gui, map)
        for i = #gradients, 1, -1 do
            local g = gradients[i]
            if g.Parent then
                g.Color = ColorSequence.new(T.Accent, T.Accent2)
            else
                table.remove(gradients, i)
            end
        end
        if shadeFrame then shadeFrame.BackgroundTransparency = T.ShadeAlpha end
        themeName = name
        scheduleSave()
    end

    function Window:SetTheme(theme)
        if type(theme) == "string" then
            local def = UI.Themes[theme]
            if not def then
                warn("[NexusUI] Tema desconocido: " .. theme)
                return false
            end
            applyTheme(def, theme)
            return true
        elseif type(theme) == "table" then
            applyTheme(theme, "Custom")
            return true
        end
        return false
    end

    function Window:GetTheme()
        return themeName, copyTable(T)
    end

    function Window:SetAccent(color, color2)
        if typeof(color) ~= "Color3" then return false end
        applyTheme({Accent = color, Accent2 = typeof(color2) == "Color3" and color2 or color}, "Custom")
        return true
    end

    function Window:SetUIScale(n)
        if type(n) ~= "number" then return false end
        userScale = math.clamp(n, 0.6, 1.4)
        fitScreen()
        task.defer(clampToScreen)
        scheduleSave()
        return true
    end

    function Window:SetReduceMotion(on)
        UI.ReduceMotion = on == true
    end

    -- ═══════════ API de componentes ═══════════
    local function newApi(instance, cleanup, opt)
        local a = {Instance = instance}
        orderInstance(instance, opt ~= nil)
        function a:Destroy()
            if cleanup then cleanup() end
            unbind(instance)
            unindex(instance)
            if opt and opt.Flag then
                flagItems[opt.Flag] = nil
                Window.Flags[opt.Flag] = nil
            end
            instance:Destroy()
        end
        function a:SetVisible(v)
            instance.Visible = v == true
        end
        return a
    end

    local categories, categoryCount, tabCount = {}, 0, 0

    function Window:CreateTab(config)
        config = config or {}
        local nameSource = config.Name or "Tab"

        tabCount += 1
        local order = tabCount

        -- Categorías en la barra lateral (se pliegan con su flecha)
        local cat
        if config.Category ~= nil then
            local ck = key(config.Category)
            cat = categories[ck]
            if not cat then
                categoryCount += 1
                cat = {Index = categoryCount, Tabs = {}, Open = true}
                categories[ck] = cat
                local current = cat
                local src = config.Category

                local header = make("TextButton", {
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundTransparency = 1,
                    Text = "",
                    AutoButtonColor = false,
                    LayoutOrder = categoryCount * 1000
                }, tabList)
                local lbl = make("TextLabel", {
                    Position = UDim2.fromOffset(6, 0),
                    Size = UDim2.new(1, -30, 1, 0),
                    BackgroundTransparency = 1,
                    TextColor3 = T.Muted,
                    Font = Enum.Font.Gotham,
                    TextSize = 12,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    TextXAlignment = Enum.TextXAlignment.Left
                }, header)
                bind(lbl, "Text", function() return tx(src) end)
                local arrow = make("Frame", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -4, 0.5, 0),
                    Size = UDim2.fromOffset(18, 18),
                    BackgroundTransparency = 1,
                    Rotation = 180
                }, header)
                makeChevron(arrow, T.Muted, 6, 2, 1)

                function current.SetOpen(v)
                    v = v == true
                    current.Open = v
                    animate(arrow, {Rotation = v and 180 or 0}, 0.18)
                    for _, tb in ipairs(current.Tabs) do
                        if v then
                            tb.Visible = true
                            animate(tb, {Size = UDim2.new(1, 0, 0, 34)}, 0.18)
                        else
                            animate(tb, {Size = UDim2.new(1, 0, 0, 0)}, 0.18)
                            task.delay(0.2, function()
                                if tb.Parent and not current.Open then
                                    tb.Visible = false
                                end
                            end)
                        end
                    end
                end
                header.Activated:Connect(function()
                    current.SetOpen(not current.Open)
                end)
            end
            order = cat.Index * 1000 + tabCount
        end

        local tabButton = make("TextButton", {
            Size = UDim2.new(1, 0, 0, 34),
            BackgroundColor3 = T.Border,
            BackgroundTransparency = 1,
            Text = "",
            BorderSizePixel = 0,
            AutoButtonColor = false,
            ClipsDescendants = true,
            LayoutOrder = order
        }, tabList)
        round(tabButton, 17)

        -- Fondo del botón: tu imagen de píldora (violeta cuando es la pestaña activa)
        local tabPill
        local pillAsset = embeddedImage("pill")
        if pillAsset ~= "" then
            tabPill = make("ImageLabel", {
                Name = "Pill",
                Size = UDim2.fromScale(1, 1),
                BackgroundTransparency = 1,
                Image = pillAsset,
                ScaleType = Enum.ScaleType.Stretch,
                ImageTransparency = 0.72
            }, tabButton)
        end

        local tabLabel = make("TextLabel", {
            Position = UDim2.fromOffset(34, 0),
            Size = UDim2.new(1, -54, 1, 0),
            BackgroundTransparency = 1,
            TextColor3 = T.Text,
            TextTransparency = 0.25,
            Font = Enum.Font.GothamMedium,
            TextSize = 12,
            TextTruncate = Enum.TextTruncate.AtEnd,
            TextXAlignment = Enum.TextXAlignment.Left
        }, tabButton)
        bind(tabLabel, "Text", function() return tx(nameSource) end)

        -- Icono: imagen propia (config.Icon) o un punto de acento
        local tabIconId = asset(config.Icon)
        if tabIconId ~= "" then
            make("ImageLabel", {
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.new(0, 12, 0.5, 0),
                Size = UDim2.fromOffset(16, 16),
                BackgroundTransparency = 1,
                Image = tabIconId,
                ImageColor3 = T.Text
            }, tabButton)
        else
            local dot = make("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(0, 20, 0.5, 0),
                Size = UDim2.fromOffset(6, 6),
                BackgroundColor3 = T.Accent,
                BorderSizePixel = 0
            }, tabButton)
            round(dot, 3)
        end
        if cat then
            table.insert(cat.Tabs, tabButton)
            if not cat.Open then
                tabButton.Visible = false
                tabButton.Size = UDim2.new(1, 0, 0, 0)
            end
        end

        -- Flecha que marca la pestaña activa (como las de las categorías)
        local indicator = make("Frame", {
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -4, 0.5, 0),
            Size = UDim2.fromOffset(16, 16),
            BackgroundTransparency = 1,
            Rotation = -90
        }, tabButton)
        makeChevron(indicator, T.Text, 5.5, 2.2, 3)
        for _, c in ipairs(indicator:GetDescendants()) do
            if c:GetAttribute("Arm") then c.BackgroundTransparency = 1 end
        end

        local page = make("ScrollingFrame", {
            Name = key(nameSource),
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Active = true,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = T.Muted,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            CanvasSize = UDim2.new(),
            Visible = false
        }, content)

        make("UIListLayout", {
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder
        }, page)

        make("UIPadding", {
            PaddingRight = UDim.new(0, 5),
            PaddingBottom = UDim.new(0, 5)
        }, page)

        local entry = {Name = nameSource, Button = tabButton, Label = tabLabel, Page = page, Indicator = indicator, Pill = tabPill}
        table.insert(pages, entry)

        tabButton.Activated:Connect(function()
            if searching then searchBox.Text = "" end
            selectEntry(entry)
        end)
        if #pages == 1 then selectEntry(entry) end

        -- ───────────── Constructor de componentes ─────────────
        -- Se usa para la pestaña y para cada grupo plegable.
        local function buildComponents(container, ctx)
            local Tab = {}
            container:SetAttribute("NxContainer", ctx.id)

            -- Conexiones propias de cada componente (se liberan en :Destroy())
            local function scoped()
                local mine = {}
                local function t(c)
                    mine[#mine + 1] = c
                    return track(c)
                end
                local function cleanup()
                    for _, c in ipairs(mine) do c:Disconnect() end
                    mine = {}
                end
                return t, cleanup
            end

            local function index(inst, nameSource_, kindEs, kindEn)
                table.insert(searchIndex, {
                    Inst = inst, Name = nameSource_, Kind = L(kindEs, kindEn),
                    Entry = ctx.entry, Reveal = ctx.reveal
                })
            end

            local function card(height)
                local b = make("TextButton", {
                    Name = "Element",
                    Size = UDim2.new(1, 0, 0, height),
                    BackgroundColor3 = T.Element,
                    BackgroundTransparency = EA,
                    Text = "",
                    BorderSizePixel = 0,
                    AutoButtonColor = false
                }, container)
                round(b, 9)
                outline(b, nil, T)
                return b
            end

            local function nameLabel(parentObj, source, width, defaultName)
                local l = make("TextLabel", {
                    Position = UDim2.fromOffset(12, 0),
                    Size = UDim2.new(1, width, 1, 0),
                    BackgroundTransparency = 1,
                    TextColor3 = T.Text,
                    Font = Enum.Font.GothamMedium,
                    TextSize = 12,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    TextXAlignment = Enum.TextXAlignment.Left
                }, parentObj)
                bind(l, "Text", function() return tx(source or defaultName) end)
                return l
            end

            function Tab:CreateSection(name)
                local l = make("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 22),
                    BackgroundTransparency = 1,
                    TextColor3 = T.Muted,
                    Font = Enum.Font.GothamBold,
                    TextSize = 10,
                    TextXAlignment = Enum.TextXAlignment.Left
                }, container)
                bind(l, "Text", function() return string.upper(tx(name)) end)
                return newApi(l)
            end

            function Tab:CreateDivider()
                local d = make("Frame", {
                    Size = UDim2.new(1, 0, 0, 1),
                    BackgroundColor3 = T.Border,
                    BackgroundTransparency = 0.4,
                    BorderSizePixel = 0
                }, container)
                return newApi(d)
            end

            function Tab:CreateLabel(text)
                local l = make("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 28),
                    BackgroundTransparency = 1,
                    TextColor3 = T.Muted,
                    Font = Enum.Font.Gotham,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left
                }, container)
                bind(l, "Text", function() return tx(text) end)
                local api = newApi(l)
                function api:Set(newText)
                    text = newText
                    l.Text = tx(text)
                end
                return api
            end

            function Tab:CreateParagraph(opt)
                opt = opt or {}
                local f = make("Frame", {
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundColor3 = T.Element,
                    BackgroundTransparency = EA,
                    BorderSizePixel = 0
                }, container)
                round(f, 9)
                outline(f, nil, T)
                make("UIPadding", {
                    PaddingTop = UDim.new(0, 9), PaddingBottom = UDim.new(0, 9),
                    PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12)
                }, f)
                make("UIListLayout", {
                    Padding = UDim.new(0, 4),
                    SortOrder = Enum.SortOrder.LayoutOrder
                }, f)

                local title = make("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    TextColor3 = T.Text,
                    Font = Enum.Font.GothamBold,
                    TextSize = 12,
                    TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    LayoutOrder = 1
                }, f)
                bind(title, "Text", function() return tx(opt.Title or "") end)

                local body = make("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    TextColor3 = T.Muted,
                    Font = Enum.Font.Gotham,
                    TextSize = 11,
                    TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    LayoutOrder = 2
                }, f)
                bind(body, "Text", function() return tx(opt.Content or "") end)

                if opt.Title ~= nil then
                    index(f, opt.Title, "Párrafo", "Paragraph")
                end

                local api = newApi(f)
                function api:Set(data)
                    data = data or {}
                    if data.Title ~= nil then opt.Title = data.Title end
                    if data.Content ~= nil then opt.Content = data.Content end
                    title.Text = tx(opt.Title or "")
                    body.Text = tx(opt.Content or "")
                end
                return api
            end

            function Tab:CreateButton(opt)
                opt = opt or {}
                local b = card(42)
                nameLabel(b, opt.Name, -24, "Button")

                local function fire()
                    animate(b, {BackgroundColor3 = T.Border}, 0.08)
                    task.delay(0.12, function()
                        if b.Parent then animate(b, {BackgroundColor3 = T.Element}) end
                    end)
                    spawnCall(opt.Callback)
                end
                b.Activated:Connect(fire)

                index(b, opt.Name or "Button", "Botón", "Button")
                local api = newApi(b, nil, opt)
                api.Fire = fire
                return api
            end

            function Tab:CreateToggle(opt)
                opt = opt or {}
                local state = opt.CurrentValue == true
                local b = card(42)
                nameLabel(b, opt.Name, -70, "Toggle")

                local trackBar = make("Frame", {
                    Position = UDim2.new(1, -50, 0.5, -9),
                    Size = UDim2.fromOffset(38, 18),
                    BackgroundColor3 = T.Border,
                    BorderSizePixel = 0
                }, b)
                round(trackBar, 15)

                local knob = make("Frame", {
                    Position = UDim2.fromOffset(2, 2),
                    Size = UDim2.fromOffset(14, 14),
                    BackgroundColor3 = T.Text,
                    BorderSizePixel = 0
                }, trackBar)
                round(knob, 12)

                local function update(call)
                    animate(trackBar, {BackgroundColor3 = state and T.Accent or T.Border})
                    animate(knob, {Position = UDim2.fromOffset(state and 22 or 2, 2)})
                    setFlag(opt, state)
                    if call then spawnCall(opt.Callback, state) end
                end

                b.Activated:Connect(function()
                    state = not state
                    update(true)
                end)

                index(b, opt.Name or "Toggle", "Interruptor", "Toggle")
                local api = newApi(b, nil, opt)
                function api:Set(v) state = v == true; update(true) end
                function api:Get() return state end
                register(opt, function() return state end, function(v)
                    state = v == true
                    update(true)
                end)
                update(false)
                return api
            end

            function Tab:CreateSlider(opt)
                opt = opt or {}
                local track, cleanup = scoped()
                local min = opt.Range and opt.Range[1] or 0
                local max = opt.Range and opt.Range[2] or 100
                local inc = opt.Increment or 1
                local suffix = opt.Suffix or ""

                local function snap(v)
                    v = math.clamp(v, min, max)
                    return math.clamp(math.floor((v - min) / inc + 0.5) * inc + min, min, max)
                end
                local value = snap(opt.CurrentValue or min)

                local b = card(60)
                local label = make("TextLabel", {
                    Position = UDim2.fromOffset(12, 4),
                    Size = UDim2.new(1, -24, 0, 23),
                    BackgroundTransparency = 1,
                    TextColor3 = T.Text,
                    Font = Enum.Font.GothamMedium,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left
                }, b)
                local function labelText()
                    return tx(opt.Name or "Slider") .. ": " .. formatNumber(value) .. suffix
                end
                bind(label, "Text", labelText)

                local bar = make("Frame", {
                    Position = UDim2.new(0, 12, 0, 38),
                    Size = UDim2.new(1, -24, 0, 6),
                    BackgroundColor3 = T.Border,
                    BorderSizePixel = 0,
                    Active = true
                }, b)
                round(bar, 6)

                local function pct()
                    return (value - min) / math.max(max - min, 0.0001)
                end

                local fill = gradientFrame({Size = UDim2.new(pct(), 0, 1, 0)}, bar, 0)
                round(fill, 6)

                local function apply(v, call, force)
                    local nv = snap(v)
                    local changed = nv ~= value
                    value = nv
                    fill.Size = UDim2.new(pct(), 0, 1, 0)
                    label.Text = labelText()
                    setFlag(opt, value)
                    if call and (changed or force) then
                        spawnCall(opt.Callback, value)
                    end
                end

                local function fromX(x)
                    local p = math.clamp(
                        (x - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1)
                    apply(min + (max - min) * p, true, false)
                end
                track(dragBar(bar, fromX))

                index(b, opt.Name or "Slider", "Deslizador", "Slider")
                local api = newApi(b, cleanup, opt)
                function api:Get() return value end
                function api:Set(v) apply(v, true, true) end
                register(opt, function() return value end, function(v)
                    if type(v) == "number" then apply(v, true, true) end
                end)
                setFlag(opt, value)
                return api
            end

            -- Dropdown desplegable (se expande dentro de la página)
            function Tab:CreateDropdown(opt)
                opt = opt or {}
                local choices = opt.Options or {}
                local idx = 1
                local HEAD, ROW = 42, 30
                local open = false

                local function findIndex(v)
                    for i, c in ipairs(choices) do
                        if c == v or key(c) == key(v) then return i end
                    end
                    return nil
                end
                if opt.CurrentOption ~= nil then
                    idx = findIndex(opt.CurrentOption) or 1
                end

                local holder = make("Frame", {
                    Name = "Dropdown",
                    Size = UDim2.new(1, 0, 0, HEAD),
                    BackgroundColor3 = T.Element,
                    BackgroundTransparency = EA,
                    BorderSizePixel = 0,
                    ClipsDescendants = true
                }, container)
                round(holder, 9)
                outline(holder, nil, T)

                local head = make("TextButton", {
                    Size = UDim2.new(1, 0, 0, HEAD),
                    BackgroundTransparency = 1,
                    Text = "",
                    AutoButtonColor = false
                }, holder)

                local label = make("TextLabel", {
                    Position = UDim2.fromOffset(12, 0),
                    Size = UDim2.new(1, -44, 1, 0),
                    BackgroundTransparency = 1,
                    TextColor3 = T.Text,
                    Font = Enum.Font.GothamMedium,
                    TextSize = 12,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    TextXAlignment = Enum.TextXAlignment.Left
                }, head)

                local arrow = make("Frame", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -12, 0.5, 0),
                    Size = UDim2.fromOffset(18, 18),
                    BackgroundTransparency = 1
                }, head)
                makeChevron(arrow, T.Muted, 6, 2, 1)

                local list = make("Frame", {
                    Position = UDim2.fromOffset(0, HEAD),
                    Size = UDim2.new(1, 0, 0, 0),
                    BackgroundTransparency = 1
                }, holder)

                local function labelText()
                    return tx(opt.Name or "Dropdown") .. ": "
                        .. (choices[idx] ~= nil and tx(choices[idx]) or "—")
                end
                bind(label, "Text", labelText)

                local function listHeight()
                    return #choices * ROW + 8
                end

                local function setOpen(v)
                    open = v
                    animate(holder, {
                        Size = UDim2.new(1, 0, 0, open and (HEAD + listHeight()) or HEAD)
                    }, 0.18)
                    animate(arrow, {Rotation = open and 180 or 0}, 0.18)
                end

                local function choose(i, call)
                    if not choices[i] then return end
                    idx = i
                    label.Text = labelText()
                    setFlag(opt, idx)
                    for _, child in ipairs(list:GetChildren()) do
                        if child:IsA("TextButton") then
                            local active = child:GetAttribute("Index") == idx
                            animate(child, {BackgroundColor3 = active and T.Border or T.Element})
                        end
                    end
                    if call then
                        spawnCall(opt.Callback, key(choices[idx]), idx)
                    end
                end

                local function build()
                    unbind(list)
                    for _, child in ipairs(list:GetChildren()) do
                        child:Destroy()
                    end
                    list.Size = UDim2.new(1, 0, 0, listHeight())
                    for i, choice in ipairs(choices) do
                        local o = make("TextButton", {
                            Position = UDim2.fromOffset(6, 4 + (i - 1) * ROW),
                            Size = UDim2.new(1, -12, 0, ROW - 4),
                            BackgroundColor3 = i == idx and T.Border or T.Element,
                            TextColor3 = T.Text,
                            Font = Enum.Font.GothamMedium,
                            TextSize = 11,
                            BorderSizePixel = 0,
                            AutoButtonColor = false
                        }, list)
                        o:SetAttribute("Index", i)
                        round(o, 7)
                        bind(o, "Text", function() return tx(choice) end)
                        o.Activated:Connect(function()
                            choose(i, true)
                            setOpen(false)
                        end)
                    end
                    if open then
                        holder.Size = UDim2.new(1, 0, 0, HEAD + listHeight())
                    end
                end
                build()

                head.Activated:Connect(function()
                    setOpen(not open)
                end)

                index(holder, opt.Name or "Dropdown", "Lista", "Dropdown")
                local api = newApi(holder, nil, opt)
                function api:Get() return key(choices[idx]), idx end
                function api:Set(v)
                    local i = type(v) == "number" and v or findIndex(v)
                    if i then choose(i, true) end
                end
                function api:Refresh(newOptions, keepSelection)
                    choices = newOptions or {}
                    if not keepSelection or idx > #choices then idx = 1 end
                    label.Text = labelText()
                    build()
                end
                register(opt, function() return idx end, function(v)
                    if type(v) == "number" then choose(v, true) end
                end)
                setFlag(opt, idx)
                return api
            end

            -- Dropdown de selección múltiple
            function Tab:CreateMultiDropdown(opt)
                opt = opt or {}
                local choices = opt.Options or {}
                local selected = {}
                for _, k in ipairs(opt.CurrentOptions or {}) do
                    selected[key(k)] = true
                end
                local HEAD, ROW = 42, 30
                local open = false

                local holder = make("Frame", {
                    Name = "MultiDropdown",
                    Size = UDim2.new(1, 0, 0, HEAD),
                    BackgroundColor3 = T.Element,
                    BackgroundTransparency = EA,
                    BorderSizePixel = 0,
                    ClipsDescendants = true
                }, container)
                round(holder, 9)
                outline(holder, nil, T)

                local head = make("TextButton", {
                    Size = UDim2.new(1, 0, 0, HEAD),
                    BackgroundTransparency = 1,
                    Text = "",
                    AutoButtonColor = false
                }, holder)

                local label = make("TextLabel", {
                    Position = UDim2.fromOffset(12, 0),
                    Size = UDim2.new(1, -44, 1, 0),
                    BackgroundTransparency = 1,
                    TextColor3 = T.Text,
                    Font = Enum.Font.GothamMedium,
                    TextSize = 12,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    TextXAlignment = Enum.TextXAlignment.Left
                }, head)

                local arrow = make("Frame", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -12, 0.5, 0),
                    Size = UDim2.fromOffset(18, 18),
                    BackgroundTransparency = 1
                }, head)
                makeChevron(arrow, T.Muted, 6, 2, 1)

                local list = make("Frame", {
                    Position = UDim2.fromOffset(0, HEAD),
                    Size = UDim2.new(1, 0, 0, 0),
                    BackgroundTransparency = 1
                }, holder)

                local function summary()
                    local names = {}
                    for _, c in ipairs(choices) do
                        if selected[key(c)] then table.insert(names, tx(c)) end
                    end
                    if #names == 0 then return "—" end
                    return table.concat(names, ", ")
                end
                local function labelText()
                    return tx(opt.Name or "Dropdown") .. ": " .. summary()
                end
                bind(label, "Text", labelText)

                local function getList()
                    local out = {}
                    for _, c in ipairs(choices) do
                        if selected[key(c)] then table.insert(out, key(c)) end
                    end
                    return out
                end

                local function listHeight()
                    return #choices * ROW + 8
                end

                local function setOpen(value)
                    open = value
                    animate(holder, {
                        Size = UDim2.new(1, 0, 0, open and (HEAD + listHeight()) or HEAD)
                    }, 0.18)
                    animate(arrow, {Rotation = open and 180 or 0}, 0.18)
                end

                local function paint()
                    for _, child in ipairs(list:GetChildren()) do
                        if child:IsA("TextButton") then
                            local c = choices[child:GetAttribute("Index")]
                            local on = c ~= nil and selected[key(c)] == true
                            animate(child, {BackgroundColor3 = on and T.Border or T.Element})
                        end
                    end
                end

                local function changed(call)
                    label.Text = labelText()
                    paint()
                    local result = getList()
                    setFlag(opt, result)
                    if call then spawnCall(opt.Callback, result) end
                end

                local function build()
                    unbind(list)
                    for _, child in ipairs(list:GetChildren()) do
                        child:Destroy()
                    end
                    list.Size = UDim2.new(1, 0, 0, listHeight())
                    for i, choice in ipairs(choices) do
                        local o = make("TextButton", {
                            Position = UDim2.fromOffset(6, 4 + (i - 1) * ROW),
                            Size = UDim2.new(1, -12, 0, ROW - 4),
                            BackgroundColor3 = selected[key(choice)] and T.Border or T.Element,
                            TextColor3 = T.Text,
                            Font = Enum.Font.GothamMedium,
                            TextSize = 11,
                            BorderSizePixel = 0,
                            AutoButtonColor = false
                        }, list)
                        o:SetAttribute("Index", i)
                        round(o, 7)
                        bind(o, "Text", function() return tx(choice) end)
                        o.Activated:Connect(function()
                            local k = key(choice)
                            if selected[k] then
                                selected[k] = nil
                            else
                                selected[k] = true
                            end
                            changed(true)
                        end)
                    end
                    if open then
                        holder.Size = UDim2.new(1, 0, 0, HEAD + listHeight())
                    end
                end
                build()

                head.Activated:Connect(function()
                    setOpen(not open)
                end)

                index(holder, opt.Name or "Dropdown", "Selección múltiple", "Multi-select")
                local api = newApi(holder, nil, opt)
                function api:Get() return getList() end
                function api:Set(values)
                    selected = {}
                    for _, k in ipairs(values or {}) do
                        selected[key(k)] = true
                    end
                    changed(true)
                end
                function api:Refresh(newOptions)
                    choices = newOptions or {}
                    build()
                    changed(false)
                end
                register(opt, getList, function(value)
                    if type(value) == "table" then api:Set(value) end
                end)
                setFlag(opt, getList())
                return api
            end

            function Tab:CreateInput(opt)
                opt = opt or {}
                local value = tostring(opt.CurrentValue or "")
                local b = card(42)
                nameLabel(b, opt.Name, -150, "Input")

                local box = make("TextBox", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -10, 0.5, 0),
                    Size = UDim2.fromOffset(124, 28),
                    BackgroundColor3 = T.Background,
                    BackgroundTransparency = 0.2,
                    Text = value,
                    PlaceholderColor3 = T.Muted,
                    TextColor3 = T.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 11,
                    ClearTextOnFocus = false,
                    ClipsDescendants = true,
                    BorderSizePixel = 0
                }, b)
                round(box, 6)
                bind(box, "PlaceholderText", function()
                    return tx(opt.Placeholder or "...")
                end)

                local function commit(text, call)
                    if opt.Numeric then
                        local n = tonumber(text)
                        if n == nil then
                            box.Text = value
                            return
                        end
                        text = tostring(n)
                    end
                    value = text
                    box.Text = value
                    setFlag(opt, value)
                    if call then
                        spawnCall(opt.Callback, opt.Numeric and tonumber(value) or value)
                    end
                end

                box.FocusLost:Connect(function()
                    commit(box.Text, true)
                end)

                index(b, opt.Name or "Input", "Campo de texto", "Input")
                local api = newApi(b, nil, opt)
                function api:Get() return opt.Numeric and tonumber(value) or value end
                function api:Set(v) commit(tostring(v), true) end
                register(opt, function() return value end, function(v)
                    commit(tostring(v), true)
                end)
                setFlag(opt, value)
                return api
            end

            function Tab:CreateKeybind(opt)
                opt = opt or {}
                local track, cleanup = scoped()
                local current = opt.CurrentKeybind or Enum.KeyCode.Unknown
                local listening = false
                local b = card(42)
                nameLabel(b, opt.Name, -110, "Keybind")

                local btn = make("TextButton", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -10, 0.5, 0),
                    Size = UDim2.fromOffset(84, 28),
                    BackgroundColor3 = T.Background,
                    BackgroundTransparency = 0.2,
                    TextColor3 = T.Text,
                    Font = Enum.Font.GothamMedium,
                    TextSize = 11,
                    BorderSizePixel = 0,
                    AutoButtonColor = false
                }, b)
                round(btn, 6)

                local function render()
                    if listening then
                        btn.Text = "..."
                    elseif current == Enum.KeyCode.Unknown then
                        btn.Text = "—"
                    else
                        btn.Text = current.Name
                    end
                end
                render()

                btn.Activated:Connect(function()
                    listening = true
                    render()
                end)

                track(UIS.InputBegan:Connect(function(input, processed)
                    if listening then
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            listening = false
                            if input.KeyCode ~= Enum.KeyCode.Escape then
                                current = input.KeyCode
                                setFlag(opt, current.Name)
                                spawnCall(opt.OnChanged, current)
                            end
                            render()
                        end
                        return
                    end
                    if processed then return end
                    if current ~= Enum.KeyCode.Unknown and input.KeyCode == current then
                        spawnCall(opt.Callback, current)
                    end
                end))

                index(b, opt.Name or "Keybind", "Atajo de teclado", "Keybind")
                local api = newApi(b, cleanup, opt)
                function api:Get() return current end
                function api:Set(k)
                    if typeof(k) == "EnumItem" then
                        current = k
                        setFlag(opt, current.Name)
                        render()
                    end
                end
                register(opt, function() return current.Name end, function(v)
                    local ok, kc = pcall(function() return Enum.KeyCode[v] end)
                    if ok and kc then
                        current = kc
                        render()
                    end
                end)
                setFlag(opt, current.Name)
                return api
            end

            -- Selector de color (tono / saturación / brillo)
            function Tab:CreateColorPicker(opt)
                opt = opt or {}
                local track, cleanup = scoped()
                local color = typeof(opt.CurrentValue) == "Color3"
                    and opt.CurrentValue or Color3.fromRGB(255, 255, 255)
                local h, s, v = color:ToHSV()
                local HEAD, BODY = 42, 104
                local open = false

                local holder = make("Frame", {
                    Name = "ColorPicker",
                    Size = UDim2.new(1, 0, 0, HEAD),
                    BackgroundColor3 = T.Element,
                    BackgroundTransparency = EA,
                    BorderSizePixel = 0,
                    ClipsDescendants = true
                }, container)
                round(holder, 9)
                outline(holder, nil, T)

                local head = make("TextButton", {
                    Size = UDim2.new(1, 0, 0, HEAD),
                    BackgroundTransparency = 1,
                    Text = "",
                    AutoButtonColor = false
                }, holder)
                nameLabel(head, opt.Name, -130, "Color")

                local hexLabel = make("TextLabel", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -56, 0.5, 0),
                    Size = UDim2.fromOffset(62, 18),
                    BackgroundTransparency = 1,
                    TextColor3 = T.Muted,
                    Font = Enum.Font.Gotham,
                    TextSize = 10,
                    TextXAlignment = Enum.TextXAlignment.Right
                }, head)

                local swatch = make("Frame", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -12, 0.5, 0),
                    Size = UDim2.fromOffset(34, 20),
                    BackgroundColor3 = color,
                    BorderSizePixel = 0
                }, head)
                swatch:SetAttribute("NoTheme", true)
                round(swatch, 6)
                outline(swatch, nil, T)

                local body = make("Frame", {
                    Position = UDim2.fromOffset(0, HEAD),
                    Size = UDim2.new(1, 0, 0, BODY),
                    BackgroundTransparency = 1
                }, holder)

                local function toHex(c)
                    return string.format("#%02X%02X%02X",
                        math.floor(c.R * 255 + 0.5),
                        math.floor(c.G * 255 + 0.5),
                        math.floor(c.B * 255 + 0.5))
                end

                local hueBar, satBar, valBar

                local function refresh(call)
                    color = Color3.fromHSV(h, s, v)
                    swatch.BackgroundColor3 = color
                    hexLabel.Text = toHex(color)
                    hueBar.Knob.Position = UDim2.new(h, 0, 0.5, 0)
                    satBar.Knob.Position = UDim2.new(s, 0, 0.5, 0)
                    valBar.Knob.Position = UDim2.new(v, 0, 0.5, 0)
                    satBar.Grad.Color = ColorSequence.new(
                        Color3.fromHSV(h, 0, v), Color3.fromHSV(h, 1, v))
                    valBar.Grad.Color = ColorSequence.new(
                        Color3.new(0, 0, 0), Color3.fromHSV(h, s, 1))
                    setFlag(opt, toHex(color))
                    if call then spawnCall(opt.Callback, color) end
                end

                local function makeBar(y, onPct)
                    local bar = make("Frame", {
                        Position = UDim2.new(0, 14, 0, y),
                        Size = UDim2.new(1, -28, 0, 12),
                        BackgroundColor3 = Color3.new(1, 1, 1),
                        BorderSizePixel = 0,
                        Active = true
                    }, body)
                    bar:SetAttribute("NoTheme", true)
                    round(bar, 6)
                    local grad = make("UIGradient", {}, bar)
                    local knob = make("Frame", {
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Position = UDim2.new(0, 0, 0.5, 0),
                        Size = UDim2.fromOffset(16, 16),
                        BackgroundColor3 = T.Text,
                        BorderSizePixel = 0,
                        ZIndex = 2
                    }, bar)
                    round(knob, 8)
                    outline(knob, T.Background, T)

                    local function fromX(x)
                        onPct(math.clamp(
                            (x - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1))
                    end
                    track(dragBar(bar, fromX))
                    return {Bar = bar, Grad = grad, Knob = knob}
                end

                hueBar = makeBar(16, function(p) h = p; refresh(true) end)
                satBar = makeBar(48, function(p) s = p; refresh(true) end)
                valBar = makeBar(80, function(p) v = p; refresh(true) end)

                hueBar.Grad.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                    ColorSequenceKeypoint.new(1 / 6, Color3.fromRGB(255, 255, 0)),
                    ColorSequenceKeypoint.new(2 / 6, Color3.fromRGB(0, 255, 0)),
                    ColorSequenceKeypoint.new(3 / 6, Color3.fromRGB(0, 255, 255)),
                    ColorSequenceKeypoint.new(4 / 6, Color3.fromRGB(0, 0, 255)),
                    ColorSequenceKeypoint.new(5 / 6, Color3.fromRGB(255, 0, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
                })

                head.Activated:Connect(function()
                    open = not open
                    animate(holder, {
                        Size = UDim2.new(1, 0, 0, open and (HEAD + BODY) or HEAD)
                    }, 0.18)
                end)

                index(holder, opt.Name or "Color", "Selector de color", "Color picker")
                local api = newApi(holder, cleanup, opt)
                function api:Get() return color end
                function api:Set(c)
                    if typeof(c) == "Color3" then
                        h, s, v = c:ToHSV()
                        refresh(true)
                    end
                end
                register(opt, function() return toHex(color) end, function(value)
                    local ok, c = pcall(function() return Color3.fromHex(value) end)
                    if ok and c then api:Set(c) end
                end)
                refresh(false)
                return api
            end

            -- Barra de progreso
            function Tab:CreateProgressBar(opt)
                opt = opt or {}
                local value = math.clamp(tonumber(opt.CurrentValue) or 0, 0, 1)
                local b = card(54)

                local label = make("TextLabel", {
                    Position = UDim2.fromOffset(12, 4),
                    Size = UDim2.new(1, -90, 0, 24),
                    BackgroundTransparency = 1,
                    TextColor3 = T.Text,
                    Font = Enum.Font.GothamMedium,
                    TextSize = 12,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    TextXAlignment = Enum.TextXAlignment.Left
                }, b)
                bind(label, "Text", function() return tx(opt.Name or "Progress") end)

                local valueLabel = make("TextLabel", {
                    AnchorPoint = Vector2.new(1, 0),
                    Position = UDim2.new(1, -12, 0, 4),
                    Size = UDim2.fromOffset(70, 24),
                    BackgroundTransparency = 1,
                    TextColor3 = T.Muted,
                    Font = Enum.Font.GothamMedium,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Right
                }, b)

                local bar = make("Frame", {
                    Position = UDim2.new(0, 12, 0, 36),
                    Size = UDim2.new(1, -24, 0, 6),
                    BackgroundColor3 = T.Border,
                    BorderSizePixel = 0
                }, b)
                round(bar, 6)
                local fill = gradientFrame({Size = UDim2.new(value, 0, 1, 0)}, bar, 0)
                round(fill, 6)

                local function render(text)
                    animate(fill, {Size = UDim2.new(value, 0, 1, 0)}, 0.2)
                    valueLabel.Text = text or (math.floor(value * 100 + 0.5) .. "%")
                end
                render()

                index(b, opt.Name or "Progress", "Progreso", "Progress")
                local api = newApi(b, nil, opt)
                function api:Set(v, text)
                    value = math.clamp(tonumber(v) or 0, 0, 1)
                    render(text)
                end
                function api:Get() return value end
                return api
            end

            -- Grupo plegable: contiene los mismos componentes
            function Tab:CreateGroup(opt)
                opt = opt or {}
                local open = opt.Open ~= false

                local holder = make("Frame", {
                    Name = "Group",
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundColor3 = T.Element,
                    BackgroundTransparency = EA,
                    BorderSizePixel = 0
                }, container)
                round(holder, 9)
                outline(holder, nil, T)
                make("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder}, holder)

                local head = make("TextButton", {
                    Size = UDim2.new(1, 0, 0, 40),
                    BackgroundTransparency = 1,
                    Text = "",
                    AutoButtonColor = false,
                    LayoutOrder = 1
                }, holder)
                local title = nameLabel(head, opt.Name, -44, "Group")
                title.Font = Enum.Font.GothamBold

                local arrow = make("Frame", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -12, 0.5, 0),
                    Size = UDim2.fromOffset(18, 18),
                    BackgroundTransparency = 1,
                    Rotation = open and 180 or 0
                }, head)
                makeChevron(arrow, T.Muted, 6, 2, 1)

                local body = make("Frame", {
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    Visible = open,
                    LayoutOrder = 2
                }, holder)
                make("UIListLayout", {
                    Padding = UDim.new(0, 8),
                    SortOrder = Enum.SortOrder.LayoutOrder
                }, body)
                make("UIPadding", {
                    PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8),
                    PaddingBottom = UDim.new(0, 8)
                }, body)

                local function setOpen(v)
                    open = v == true
                    body.Visible = open
                    animate(arrow, {Rotation = open and 180 or 0}, 0.15)
                end
                head.Activated:Connect(function()
                    setOpen(not open)
                end)

                index(holder, opt.Name or "Group", "Grupo", "Group")
                orderInstance(holder, true)

                local inner = buildComponents(body, {
                    id = ctx.id .. "/group:" .. key(opt.Name or "Group"),
                    entry = ctx.entry,
                    reveal = function()
                        if not open then setOpen(true) end
                        if ctx.reveal then ctx.reveal() end
                    end
                })
                inner.Instance = holder
                function inner:SetOpen(v) setOpen(v) end
                function inner:IsOpen() return open end
                function inner:SetVisible(v) holder.Visible = v == true end
                function inner:Destroy()
                    unbind(holder)
                    unindex(holder)
                    holder:Destroy()
                end
                return inner
            end

            -- Información del servidor ACTUAL (no son estadísticas globales de Roblox)
            function Tab:CreateServerInfo(opt)
                opt = opt or {}
                local track, cleanup = scoped()
                local b = card(60)

                local label = make("TextLabel", {
                    Position = UDim2.fromOffset(12, 5),
                    Size = UDim2.new(1, -110, 0, 22),
                    BackgroundTransparency = 1,
                    TextColor3 = T.Text,
                    Font = Enum.Font.GothamMedium,
                    TextSize = 12,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    TextXAlignment = Enum.TextXAlignment.Left
                }, b)
                bind(label, "Text", function()
                    return tx(opt.Name or L("Jugadores en este servidor", "Players in this server"))
                end)

                local valueLabel = make("TextLabel", {
                    AnchorPoint = Vector2.new(1, 0),
                    Position = UDim2.new(1, -12, 0, 5),
                    Size = UDim2.fromOffset(90, 22),
                    BackgroundTransparency = 1,
                    TextColor3 = T.Text,
                    Font = Enum.Font.GothamBold,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Right
                }, b)

                local bar = make("Frame", {
                    Position = UDim2.new(0, 12, 0, 32),
                    Size = UDim2.new(1, -24, 0, 6),
                    BackgroundColor3 = T.Border,
                    BorderSizePixel = 0
                }, b)
                round(bar, 6)
                local fill = gradientFrame({Size = UDim2.fromScale(0, 1)}, bar, 0)
                round(fill, 6)

                local jobId = tostring(game.JobId or "")
                local idLabel = make("TextLabel", {
                    Position = UDim2.fromOffset(12, 41),
                    Size = UDim2.new(1, -24, 0, 14),
                    BackgroundTransparency = 1,
                    TextColor3 = T.Muted,
                    Font = Enum.Font.Gotham,
                    TextSize = 10,
                    TextXAlignment = Enum.TextXAlignment.Left
                }, b)
                bind(idLabel, "Text", function()
                    local base = tx(L("Servidor actual", "Current server"))
                    if jobId ~= "" then
                        return base .. "  ·  " .. string.sub(jobId, 1, 8)
                    end
                    return base
                end)

                local count, max = 0, nil
                local function refresh()
                    if not b.Parent then return end
                    count = #Players:GetPlayers()
                    local mp = Players.MaxPlayers
                    max = (type(mp) == "number" and mp > 0) and mp or nil
                    valueLabel.Text = count .. " / " .. (max and tostring(max) or "—")
                    local p = max and math.clamp(count / max, 0, 1) or 0
                    animate(fill, {Size = UDim2.fromScale(p, 1)}, 0.2)
                end
                refresh()

                -- Se actualiza por eventos (sin bucles de espera)
                track(Players.PlayerAdded:Connect(function()
                    task.defer(refresh)
                end))
                track(Players.PlayerRemoving:Connect(function()
                    task.delay(0.15, refresh)
                end))

                index(b, opt.Name or L("Jugadores en este servidor", "Players in this server"),
                    "Información del servidor", "Server info")
                local api = newApi(b, cleanup, opt)
                function api:Get() return count, max end
                function api:Refresh() refresh() end
                return api
            end

            -- Selector para cambiar el fondo de la ventana
            function Tab:CreateBackgroundPicker(opt)
                opt = opt or {}
                local presets = opt.Presets or UI.BackgroundPresets
                local group = Tab:CreateGroup({
                    Name = opt.Name or L("Fondo de la ventana", "Window background"),
                    Open = opt.Open ~= false
                })

                local names = {}
                for _, p in ipairs(presets) do
                    table.insert(names, p.Name)
                end

                local status = group:CreateLabel(L(
                    "Elige un fondo o pega un enlace directo a una imagen (.png / .jpg).",
                    "Pick a background or paste a direct link to an image (.png / .jpg)."))

                local busy = false
                local function apply(source, credit)
                    if busy then return end
                    busy = true
                    status:Set(L("Cargando imagen...", "Loading image..."))
                    task.spawn(function()
                        local ok, err = Window:SetBackground(source)
                        busy = false
                        if not gui.Parent then return end
                        if ok then
                            if credit then
                                status:Set(L("Fondo aplicado. Crédito: " .. credit,
                                             "Background applied. Credit: " .. credit))
                            else
                                status:Set(L("Fondo aplicado.", "Background applied."))
                            end
                        else
                            local msg = tostring(err or "No se pudo aplicar el fondo.")
                            status:Set(msg)
                            Window:Notify({Type = "Error", Title = "NEXUS UI", Content = msg})
                        end
                    end)
                end

                group:CreateDropdown({
                    Name = L("Fondos", "Backgrounds"),
                    Options = names,
                    CurrentOption = names[1],
                    Callback = function(_, idx)
                        local p = presets[idx]
                        if p then apply(p.Source, p.Credit) end
                    end
                })
                group:CreateInput({
                    Name = L("Enlace de imagen", "Image link"),
                    Placeholder = "https://...",
                    Callback = function(text)
                        if trim(text) ~= "" then apply(text) end
                    end
                })
                group:CreateButton({
                    Name = L("Quitar fondo", "Remove background"),
                    Callback = function() apply("none") end
                })
                return group
            end

            -- Interruptor del modo edición. Se apaga solo cuando se termina la
            -- edición con la X de la barra inferior.
            function Tab:CreateLayoutEditToggle(opt)
                opt = opt or {}
                local api = Tab:CreateToggle({
                    Name = opt.Name or L("Modo edición (arrastra para mover)", "Edit mode (drag to move)"),
                    CurrentValue = editMode,
                    Callback = function(value)
                        Window:SetLayoutEditMode(value)
                    end
                })
                local disconnect = Window:OnLayoutEditChanged(function(on)
                    if api:Get() ~= on then api:Set(on) end
                end)
                local baseDestroy = api.Destroy
                function api:Destroy()
                    disconnect()
                    baseDestroy(self)
                end
                return api
            end

            return Tab
        end

        local Tab = buildComponents(page, {entry = entry, id = "tab:" .. key(nameSource)})

        function Tab:Select()
            if searching then searchBox.Text = "" end
            selectEntry(entry)
        end

        return Tab
    end

    -- Cambia (o quita) la imagen de fondo de la ventana.
    -- fuente: ID, rbxassetid://, enlace directo a .png/.jpg, archivo del ejecutor,
    --         false / "none" = sin fondo, nil / "default" = fondo original.
    -- Devuelve true, o false + mensaje. Puede tardar si descarga la imagen.
    function Window:SetBackground(source)
        if source == false or source == "none" then
            bgImage.Visible = false
            shadeFrame.Visible = false
            bgSource = "none"
            scheduleSave()
            return true
        end
        if source == nil or source == "" or source == "default" then
            bgImage.Image = IMG_BG
            bgImage.Visible = IMG_BG ~= ""
            shadeFrame.Visible = IMG_BG ~= ""
            bgSource = nil
            scheduleSave()
            return true
        end
        local img, err = resolveImageSource(source)
        if img == "" then
            warn("[NexusUI] " .. tostring(err))
            return false, err
        end
        if not gui.Parent then return false, "La ventana ya no existe." end
        bgImage.Image = img
        bgImage.Visible = true
        shadeFrame.Visible = true
        bgSource = tostring(source)
        scheduleSave()
        return true
    end

    -- Modo edición: arrastra cualquier control con un dedo para moverlo;
    -- los demás se acomodan con animación. La X de la barra inferior lo termina.
    function Window:SetLayoutEditMode(on)
        on = on == true
        if on == editMode then return editMode end
        editMode = on
        for i = #editables, 1, -1 do
            local inst = editables[i]
            if not inst.Parent then
                table.remove(editables, i)
            elseif editMode then
                addOverlay(inst)
            else
                removeOverlay(inst)
            end
        end
        if editMode then
            editBar.Visible = true
            editBar.Position = UDim2.new(0.5, 0, 1, 56)
            animate(editBar, {Position = UDim2.new(0.5, 0, 1, -14)}, 0.4)
        else
            animate(editBar, {Position = UDim2.new(0.5, 0, 1, 56)}, 0.28)
            task.delay(0.3, function()
                if not editMode and editBar.Parent then editBar.Visible = false end
            end)
        end
        spawnCall(options.OnLayoutEditChanged, editMode)
        for _, fn in ipairs(editListeners) do
            spawnCall(fn, editMode)
        end
        return editMode
    end

    editClose.Activated:Connect(function()
        Window:SetLayoutEditMode(false)
    end)

    function Window:IsLayoutEditMode()
        return editMode
    end

    -- Avisa cada vez que se activa o desactiva el modo edición (también con la X
    -- de la barra de edición). Devuelve una función para desconectar.
    function Window:OnLayoutEditChanged(fn)
        if type(fn) ~= "function" then return function() end end
        table.insert(editListeners, fn)
        return function()
            for i, f in ipairs(editListeners) do
                if f == fn then
                    table.remove(editListeners, i)
                    break
                end
            end
        end
    end

    -- Restablece orden de controles, tamaño y posición de la ventana y de la
    -- barra flotante, y vuelve a desplegar las categorías.
    function Window:ResetLayout()
        for i = #editables, 1, -1 do
            local inst = editables[i]
            if inst.Parent then
                local idx = inst:GetAttribute("NxIdx")
                if idx then inst.LayoutOrder = idx end
            else
                table.remove(editables, i)
            end
        end
        if maximized then setMaximized(false, true) end
        local def = UDim2.fromOffset(DEFAULT_W, DEFAULT_H)
        main.Size = def
        savedSize = def
        main.Position = UDim2.new(0.5, 0, 0.5, 0)
        mini.Position = UDim2.new(0.5, -MINI_W / 2, 0, 12)
        for _, c in pairs(categories) do
            c.SetOpen(true)
        end
        scheduleSave()
        return true
    end

    function Window:SetCategoryOpen(category, open)
        local c = categories[key(category)]
        if not c then return false end
        c.SetOpen(open ~= false)
        return true
    end

    function Window:SelectTab(nameOrIndex)
        for i, p in ipairs(pages) do
            local hit = (type(nameOrIndex) == "number" and nameOrIndex == i)
                or (type(nameOrIndex) ~= "number" and key(p.Name) == key(nameOrIndex))
            if hit then
                if searching then searchBox.Text = "" end
                selectEntry(p)
                return true
            end
        end
        return false
    end

    -- ═══════════ Notificaciones (niveles, cola y apilamiento) ═══════════
    local NOTE_W = 320
    local notifications = make("Frame", {
        Name = "Notifications",
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -14, 1, -14),
        Size = UDim2.new(0, NOTE_W, 1, -28),
        BackgroundTransparency = 1,
        ZIndex = 80
    }, gui)

    make("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        Padding = UDim.new(0, 10),
        SortOrder = Enum.SortOrder.LayoutOrder
    }, notifications)

    local MAX_NOTES = math.clamp(options.MaxNotifications or 4, 1, 8)
    local noteActive, noteCount = 0, 0
    local noteQueue = {}
    local activeDismiss = {}
    local showNext

    -- Glifo del nivel dibujado con barras (no depende de la fuente)
    local function noteGlyph(circle, level, color)
        if level == "Info" or level == "Warning" then
            make("TextLabel", {
                Size = UDim2.fromScale(1, 1),
                BackgroundTransparency = 1,
                Text = level == "Info" and "i" or "!",
                TextColor3 = color,
                Font = Enum.Font.GothamBold,
                TextSize = 15
            }, circle)
            return
        end
        local function bar(w, x, y, rot)
            local f = make("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(0.5, x, 0.5, y),
                Size = UDim2.fromOffset(w, 2),
                Rotation = rot,
                BackgroundColor3 = color,
                BorderSizePixel = 0
            }, circle)
            round(f, 1)
        end
        if level == "Success" then
            bar(6, -3.2, 1.8, 45)
            bar(11, 2.9, 0.1, -45)
        else
            bar(12, 0, 0, 45)
            bar(12, 0, 0, -45)
        end
    end

    -- Notificación con tu diseño: base azul marino + capa de luz teñida con el
    -- color del nivel (info, éxito, aviso, error), recuadro de icono, línea
    -- divisoria, título, mensaje y X. Es una marca fija: no cambia con el tema.
    local noteFrameImg = embeddedImage("note_frame")
    local noteBoxImg = embeddedImage("note_box")
    local noteImages = noteFrameImg ~= "" and noteBoxImg ~= ""
    local NOTE_BASE = Color3.fromRGB(6, 10, 22)
    local NOTE_TEXT = Color3.fromRGB(236, 242, 255)
    local NOTE_SUB = Color3.fromRGB(170, 186, 218)
    local NOTE_DARK = Color3.fromRGB(8, 14, 30)
    local NOTE_X = Color3.fromRGB(190, 205, 240)

    local function spawnNote(opt, handle)
        noteActive += 1
        noteCount += 1

        local levelName = (opt.Type and NOTE_TYPES[opt.Type]) and opt.Type or "Info"
        local kind = NOTE_TYPES[levelName]
        local color = T[kind.Color]
        local title = tx(opt.Title or "NEXUS UI")
        local body = tx(opt.Content or L("Listo.", "Done."))
        local measured = TextService:GetTextSize(
            body, 12, Enum.Font.Gotham, Vector2.new(NOTE_W - 126, 1000))
        local height = math.clamp(36 + measured.Y + 16, 64, 190)

        local holder = make("Frame", {
            Name = "NotificationHolder",
            Size = UDim2.new(1, 0, 0, height),
            BackgroundTransparency = 1,
            LayoutOrder = noteCount
        }, notifications)

        local inner = make("CanvasGroup", {
            Name = "Notification",
            Position = UDim2.fromOffset(40, 0),
            Size = UDim2.fromScale(1, 1),
            BackgroundColor3 = NOTE_BASE,
            BackgroundTransparency = 0.04,
            BorderSizePixel = 0,
            GroupTransparency = 1
        }, holder)
        inner:SetAttribute("NoTheme", true)
        round(inner, 14)

        -- Marco luminoso (9 cortes: las esquinas decoradas no se deforman)
        if noteImages then
            make("ImageLabel", {
                Name = "Light",
                Size = UDim2.fromScale(1, 1),
                BackgroundTransparency = 1,
                Image = noteFrameImg,
                ImageColor3 = color,
                ScaleType = Enum.ScaleType.Slice,
                SliceCenter = Rect.new(72, 34, 648, 69),
                SliceScale = 0.5,
                ZIndex = 2
            }, inner)
        else
            -- El borde va dentro del grupo para que se desvanezca junto con todo
            local border = make("Frame", {
                Size = UDim2.fromScale(1, 1),
                BackgroundTransparency = 1,
                ZIndex = 2
            }, inner)
            round(border, 14)
            outline(border, color, T)
        end

        -- Recuadro del icono con el círculo del nivel
        local BOX_W, BOX_H = 46, 40
        if noteImages then
            make("ImageLabel", {
                Name = "IconBox",
                Position = UDim2.new(0, 14, 0.5, -BOX_H / 2),
                Size = UDim2.fromOffset(BOX_W, BOX_H),
                BackgroundTransparency = 1,
                Image = noteBoxImg,
                ImageColor3 = color,
                ZIndex = 3
            }, inner)
        end
        local circle = make("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0, 14 + BOX_W / 2, 0.5, 0),
            Size = UDim2.fromOffset(25, 25),
            BackgroundColor3 = color,
            BorderSizePixel = 0,
            ZIndex = 4
        }, inner)
        round(circle, 13)
        noteGlyph(circle, levelName, NOTE_DARK)

        -- Línea divisoria
        local divider = make("Frame", {
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, 70, 0.5, 0),
            Size = UDim2.fromOffset(2, math.clamp(height * 0.62, 28, 100)),
            BackgroundColor3 = color,
            BackgroundTransparency = 0.15,
            BorderSizePixel = 0,
            ZIndex = 3
        }, inner)
        round(divider, 1)

        local titleLabel = make("TextLabel", {
            Position = UDim2.fromOffset(82, 10),
            Size = UDim2.new(1, -126, 0, 20),
            BackgroundTransparency = 1,
            Text = title,
            TextColor3 = NOTE_TEXT,
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            TextTruncate = Enum.TextTruncate.AtEnd,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 3
        }, inner)
        -- Tipografía tecnológica como la del diseño, si existe
        pcall(function()
            titleLabel.Font = Enum.Font.Jura
            titleLabel.TextSize = 15
        end)

        make("TextLabel", {
            Position = UDim2.fromOffset(82, 32),
            Size = UDim2.new(1, -126, 0, measured.Y),
            BackgroundTransparency = 1,
            Text = body,
            TextColor3 = NOTE_SUB,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            ZIndex = 3
        }, inner)

        -- X para cerrar
        local xMark = make("Frame", {
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -20, 0.5, 0),
            Size = UDim2.fromOffset(14, 14),
            BackgroundTransparency = 1,
            ZIndex = 3
        }, inner)
        for _, rot in ipairs({45, -45}) do
            local bar = make("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromOffset(18, 2),
                Rotation = rot,
                BackgroundColor3 = NOTE_X,
                BorderSizePixel = 0,
                ZIndex = 3
            }, xMark)
            round(bar, 1)
        end

        local progress = make("Frame", {
            AnchorPoint = Vector2.new(0, 1),
            Position = UDim2.new(0, 18, 1, -9),
            Size = UDim2.new(1, -36, 0, 2),
            BackgroundColor3 = color,
            BackgroundTransparency = 0.25,
            BorderSizePixel = 0,
            ZIndex = 3
        }, inner)
        round(progress, 1)

        local click = make("TextButton", {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            Text = "",
            AutoButtonColor = false,
            ZIndex = 8
        }, inner)

        -- Salida limpia: primero se desvanece y se desliza todo junto,
        -- después el hueco se cierra suavemente (las demás no saltan).
        local dismissed = false
        local function dismiss()
            if dismissed then return end
            dismissed = true
            activeDismiss[holder] = nil
            animate(inner, {Position = UDim2.fromOffset(40, 0), GroupTransparency = 1}, 0.22)
            task.delay(0.24, function()
                if not holder.Parent then return end
                animate(holder, {Size = UDim2.new(1, 0, 0, 0)}, 0.16)
                task.delay(0.18, function()
                    if holder.Parent then holder:Destroy() end
                    noteActive -= 1
                    if showNext and gui.Parent then showNext() end
                end)
            end)
        end
        activeDismiss[holder] = dismiss
        handle.Close = dismiss

        animate(inner, {Position = UDim2.fromOffset(0, 0), GroupTransparency = 0}, 0.3)
        click.Activated:Connect(dismiss)

        local duration = opt.Duration
        if duration == nil then duration = 4 end
        if duration > 0 then
            if not UI.ReduceMotion then
                TweenService:Create(
                    progress,
                    TweenInfo.new(duration, Enum.EasingStyle.Linear),
                    {Size = UDim2.new(0, 0, 0, 2)}
                ):Play()
            end
            task.delay(duration, dismiss)
        else
            progress.Visible = false
        end
    end

    showNext = function()
        while noteActive < MAX_NOTES and #noteQueue > 0 do
            local item = table.remove(noteQueue, 1)
            if not item.handle.cancelled then
                spawnNote(item.opt, item.handle)
            end
        end
    end

    function Window:Notify(opt)
        opt = opt or {}
        if not gui.Parent then
            return {Close = function() end}
        end
        local handle = {cancelled = false}
        function handle.Close()
            handle.cancelled = true
        end
        table.insert(noteQueue, {opt = opt, handle = handle})
        showNext()
        return handle
    end

    function Window:ClearNotifications()
        noteQueue = {}
        local list = {}
        for _, fn in pairs(activeDismiss) do table.insert(list, fn) end
        for _, fn in ipairs(list) do fn() end
    end

    -- ───────────── Métodos generales de la ventana ─────────────
    function Window:SetLanguage(code)
        if code == "ES" or code == "EN" then
            setLanguage(code)
        end
    end

    function Window:GetLanguage()
        return UI.Language
    end

    function Window:SetVisible(visible)
        gui.Enabled = visible == true
    end

    function Window:Minimize()
        if main.Visible then doMinimize() end
    end

    function Window:Restore()
        if mini.Visible then
            openMain()
        elseif maximized then
            setMaximized(false)
        end
    end

    function Window:Maximize(on)
        if main.Visible then setMaximized(on ~= false) end
    end

    function Window:Destroy()
        for i, w in ipairs(UI.Windows) do
            if w == Window then
                table.remove(UI.Windows, i)
                break
            end
        end
        gui:Destroy()
    end

    table.insert(UI.Windows, Window)

    -- ───────────── Sistema de llaves ─────────────
    local function runKeySystem()
        local ks = options.KeySystem
        if type(ks) ~= "table" then return true end

        local function valid(input)
            input = trim(input)
            if input == "" then return false end
            if type(ks.Keys) == "function" then
                local ok, res = pcall(ks.Keys, input)
                return ok and res == true
            end
            for _, k in ipairs(ks.Keys or {}) do
                if input == tostring(k) then return true end
            end
            return false
        end

        local fileName = ks.FileName or "_key"
        local saveKey = ks.SaveKey ~= false

        -- Llave guardada de una sesión anterior
        if saveKey then
            local ok, saved = pcall(store.Load, fileName)
            if ok and saved and valid(saved) then return true end
        end

        local keyGui = make("ScreenGui", {
            Name = guiName .. "Key",
            ResetOnSpawn = false,
            DisplayOrder = (options.DisplayOrder or 999) + 2,
            IgnoreGuiInset = true,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        }, parent)
        pcall(function() keyGui.ScreenInsets = Enum.ScreenInsets.None end)
        gui.Destroying:Connect(function() keyGui:Destroy() end)

        local screen = make("CanvasGroup", {
            Size = UDim2.fromScale(1, 1),
            BackgroundColor3 = T.Background,
            BorderSizePixel = 0,
            GroupTransparency = 0,
            ZIndex = 500
        }, keyGui)

        if IMG_BG ~= "" then
            make("ImageLabel", {
                Size = UDim2.fromScale(1, 1),
                BackgroundTransparency = 1,
                Image = IMG_BG,
                ScaleType = Enum.ScaleType.Crop
            }, screen)
            make("Frame", {
                Size = UDim2.fromScale(1, 1),
                BackgroundColor3 = T.Shade,
                BackgroundTransparency = T.ShadeAlpha,
                BorderSizePixel = 0
            }, screen)
        end

        local box = make("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(330, 210),
            BackgroundColor3 = T.Panel,
            BackgroundTransparency = PA,
            BorderSizePixel = 0,
            Active = true
        }, screen)
        round(box, 14)
        outline(box, T.Accent, T)

        local boxScale = make("UIScale", {Scale = 1}, box)
        do
            local v = keyGui.AbsoluteSize
            boxScale.Scale = math.clamp(math.min((v.Y - 24) / 210, (v.X - 24) / 330), 0.4, 1)
        end

        local titleLabel = make("TextLabel", {
            Position = UDim2.fromOffset(16, 14),
            Size = UDim2.new(1, -32, 0, 24),
            BackgroundTransparency = 1,
            TextColor3 = T.Text,
            Font = Enum.Font.GothamBold,
            TextSize = 15,
            TextXAlignment = Enum.TextXAlignment.Left
        }, box)
        bind(titleLabel, "Text", function()
            return tx(ks.Title or L("Sistema de llaves", "Key system"))
        end)

        local noteLabel = make("TextLabel", {
            Position = UDim2.fromOffset(16, 42),
            Size = UDim2.new(1, -32, 0, 34),
            BackgroundTransparency = 1,
            TextColor3 = T.Muted,
            Font = Enum.Font.Gotham,
            TextSize = 11,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top
        }, box)
        bind(noteLabel, "Text", function()
            return tx(ks.Note or L("Introduce tu llave para continuar.",
                                   "Enter your key to continue."))
        end)

        local input = make("TextBox", {
            Position = UDim2.fromOffset(16, 84),
            Size = UDim2.new(1, -32, 0, 34),
            BackgroundColor3 = T.Element,
            Text = "",
            TextColor3 = T.Text,
            PlaceholderColor3 = T.Muted,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            ClearTextOnFocus = false,
            ClipsDescendants = true,
            BorderSizePixel = 0
        }, box)
        round(input, 8)
        outline(input, nil, T)
        bind(input, "PlaceholderText", function()
            return tx(L("Pega tu llave aquí", "Paste your key here"))
        end)

        local invalid = false
        local status = make("TextLabel", {
            Position = UDim2.fromOffset(16, 122),
            Size = UDim2.new(1, -32, 0, 18),
            BackgroundTransparency = 1,
            TextColor3 = T.Error,
            Font = Enum.Font.GothamMedium,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left
        }, box)
        bind(status, "Text", function()
            return invalid and tx(L("Llave incorrecta.", "Invalid key.")) or ""
        end)

        local passed = nil

        local function keyButton(es, en, x)
            local b = make("TextButton", {
                Position = UDim2.fromOffset(x, 154),
                Size = UDim2.fromOffset(142, 34),
                BackgroundColor3 = T.Element,
                TextColor3 = T.Text,
                Font = Enum.Font.GothamMedium,
                TextSize = 12,
                BorderSizePixel = 0,
                AutoButtonColor = false
            }, box)
            round(b, 8)
            bind(b, "Text", function() return tx(L(es, en)) end)
            return b
        end

        local verify = keyButton("Verificar", "Verify", 16)
        local cancel = keyButton("Cancelar", "Cancel", 172)

        local function submit()
            if valid(input.Text) then
                if saveKey then pcall(store.Save, fileName, trim(input.Text)) end
                passed = true
            else
                invalid = true
                status.Text = tx(L("Llave incorrecta.", "Invalid key."))
            end
        end

        verify.Activated:Connect(submit)
        input.FocusLost:Connect(function(enter)
            if enter then submit() end
        end)
        cancel.Activated:Connect(function()
            passed = false
            Window:Destroy()
        end)

        while passed == nil do
            if not gui.Parent then return false end
            task.wait(0.1)
        end

        if passed then
            animate(screen, {GroupTransparency = 1}, 0.3)
            task.wait(0.35)
            keyGui:Destroy()
        end
        return passed
    end

    -- ───────────── Pantalla de carga ─────────────
    local loadedCallbacks = {}

    function Window:OnLoaded(fn)
        if loaded then
            spawnCall(fn)
        else
            table.insert(loadedCallbacks, fn)
        end
    end

    local function finishLoading()
        if options.AutoSave then
            Window:LoadConfig()
        end
        loaded = true
        for _, fn in ipairs(loadedCallbacks) do
            spawnCall(fn)
        end
        loadedCallbacks = {}
    end

    if options.Loading == false then
        task.defer(function()
            if not gui.Parent then return end
            if not runKeySystem() then return end
            openMain()
            finishLoading()
        end)
        return Window
    end

    task.spawn(function()
        if not runKeySystem() then return end
        if not gui.Parent then return end

        local loadGui = make("ScreenGui", {
            Name = guiName .. "Loading",
            ResetOnSpawn = false,
            DisplayOrder = (options.DisplayOrder or 999) + 1,
            IgnoreGuiInset = true,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        }, parent)
        pcall(function() loadGui.ScreenInsets = Enum.ScreenInsets.None end)
        gui.Destroying:Connect(function() loadGui:Destroy() end)

        -- Pantalla de carga: todo negro, sin imágenes; solo texto y barra
        local screen = make("CanvasGroup", {
            Name = "Loading",
            Position = UDim2.fromScale(0, 0),
            Size = UDim2.fromScale(1, 1),
            BackgroundColor3 = Color3.new(0, 0, 0),
            BorderSizePixel = 0,
            GroupTransparency = 0,
            ZIndex = 500
        }, loadGui)

        -- Contenedor que se reduce en pantallas pequeñas
        local box = make("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(320, 64),
            BackgroundTransparency = 1
        }, screen)
        local boxScale = make("UIScale", {Scale = 1}, box)
        do
            local v = loadGui.AbsoluteSize
            boxScale.Scale = math.clamp(math.min((v.Y - 24) / 64, (v.X - 24) / 320), 0.5, 1.2)
        end

        local status = make("TextLabel", {
            Position = UDim2.fromOffset(0, 0),
            Size = UDim2.fromOffset(240, 22),
            BackgroundTransparency = 1,
            TextColor3 = Color3.fromRGB(226, 231, 246),
            Font = Enum.Font.GothamMedium,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left
        }, box)

        local pct = make("TextLabel", {
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, 0, 0, 0),
            Size = UDim2.fromOffset(70, 22),
            BackgroundTransparency = 1,
            Text = "0%",
            TextColor3 = Color3.fromRGB(150, 160, 185),
            Font = Enum.Font.GothamBold,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Right
        }, box)

        local barBg = make("Frame", {
            Position = UDim2.fromOffset(0, 32),
            Size = UDim2.fromOffset(320, 4),
            BackgroundColor3 = Color3.fromRGB(26, 26, 38),
            BorderSizePixel = 0
        }, box)
        round(barBg, 4)

        local fill = gradientFrame({Size = UDim2.fromScale(0, 1)}, barBg, 0)
        round(fill, 4)

        make("TextLabel", {
            Position = UDim2.fromOffset(0, 44),
            Size = UDim2.fromOffset(320, 16),
            BackgroundTransparency = 1,
            Text = options.Title or "NEXUS UI",
            TextColor3 = Color3.fromRGB(96, 104, 126),
            Font = Enum.Font.GothamMedium,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left
        }, box)

        local stages = {
            {0.34, L("Cargando recursos...", "Loading resources...")},
            {0.67, L("Cargando configuraciones...", "Loading settings...")},
            {1.00, L("Cargando sistema...", "Loading system...")}
        }
        local current = 1
        bind(status, "Text", function() return tx(stages[current][2]) end)

        local per = (options.LoadingTime or 2.4) / #stages
        for i, st in ipairs(stages) do
            if not gui.Parent then return end
            current = i
            status.Text = tx(st[2])
            pct.Text = math.floor(st[1] * 100) .. "%"
            animate(fill, {Size = UDim2.fromScale(st[1], 1)}, per * 0.9)
            task.wait(per)
        end

        task.wait(0.15)
        if not gui.Parent then return end
        animate(screen, {GroupTransparency = 1}, 0.4)
        openMain()
        task.wait(0.45)
        loadGui:Destroy()

        finishLoading()
    end)

    return Window
end

UI.Loaded = true

-- Se publica en el entorno global para que otros scripts la reutilicen
pcall(function()
    local env = (getgenv and getgenv()) or _G
    env.NexusUI = UI
    if shared then shared.NexusUI = UI end
end)

return UI

end)()

-- ═════════ TU INTERFAZ (edita desde aquí) ═════════
-- Otros scripts que solo quieran la biblioteca (sin esta ventana de ejemplo)
-- deben poner  getgenv().NexusUI_NoDemo = true  ANTES de cargar este archivo.

local skipDemo = false
pcall(function() skipDemo = getgenv().NexusUI_NoDemo == true end)

if not skipDemo then
local Window = UI:CreateWindow({
    Title = "NEXUS HUB",
    Language = "ES",
    Theme = "Black",                      -- Black | Midnight | Light | HighContrast
    ToggleKey = Enum.KeyCode.RightShift,  -- mostrar/ocultar todo
    ConfigName = "demo",
    AutoSave = true,                      -- guarda y restaura Flags solo
    MaxNotifications = 4

    -- Sistema de llaves (quita los "--" para activarlo):
    -- , KeySystem = {
    --     Keys = {"MI-LLAVE-123"},       -- o function(texto) return texto == "x" end
    --     Title = UI.T("Acceso", "Access"),
    --     Note = UI.T("Pide tu llave al creador.", "Ask the creator for your key."),
    -- }
})

-- ───────── Inicio ─────────
local Home = Window:CreateTab({Name = UI.T("Inicio", "Home"), Category = UI.T("Principal", "Main")})

Home:CreateSection(UI.T("General", "General"))

Home:CreateParagraph({
    Title = UI.T("Bienvenido a Nexus UI 6", "Welcome to Nexus UI 6"),
    Content = UI.T("Usa la búsqueda de la izquierda para encontrar cualquier control.",
                   "Use the search box on the left to find any control.")
})

Home:CreateButton({
    Name = UI.T("Notificación de información", "Info notification"),
    Callback = function()
        Window:Notify({Type = "Info", Title = "NEXUS UI",
            Content = UI.T("Esto es una notificación informativa.", "This is an info notification.")})
    end
})

Home:CreateButton({
    Name = UI.T("Notificaciones de todos los niveles", "Notifications of every level"),
    Callback = function()
        for _, level in ipairs({"Info", "Success", "Warning", "Error"}) do
            Window:Notify({
                Type = level,
                Title = level,
                Content = UI.T("Nivel: ", "Level: ") .. level,
                Duration = 5
            })
        end
    end
})

Home:CreateToggle({
    Name = UI.T("Interruptor", "Toggle"),
    CurrentValue = false,
    Flag = "demo_toggle",
    Callback = function(value) print("Toggle:", value) end
})

Home:CreateSlider({
    Name = UI.T("Velocidad", "Speed"),
    Range = {0, 100}, Increment = 5, Suffix = "%", CurrentValue = 50,
    Flag = "demo_speed",
    Callback = function(value) print("Slider:", value) end
})

-- Barra de progreso con actualización real
local progress = Home:CreateProgressBar({Name = UI.T("Progreso", "Progress"), CurrentValue = 0})
Home:CreateButton({
    Name = UI.T("Simular carga", "Simulate loading"),
    Callback = function()
        for i = 0, 10 do
            progress:Set(i / 10)
            task.wait(0.15)
        end
        Window:Notify({Type = "Success", Content = UI.T("Carga completada.", "Loading complete.")})
    end
})

-- ───────── Controles ─────────
local Controls = Window:CreateTab({Name = UI.T("Controles", "Controls"), Category = UI.T("Principal", "Main")})

Controls:CreateDropdown({
    Name = UI.T("Lista", "Dropdown"),
    Options = {UI.T("Negro", "Black"), UI.T("Grafito", "Graphite"), UI.T("Plata", "Silver")},
    CurrentOption = "Black",
    Flag = "demo_dropdown",
    Callback = function(value, index) print("Dropdown:", value, index) end   -- value llega en inglés
})

Controls:CreateMultiDropdown({
    Name = UI.T("Selección múltiple", "Multi-select"),
    Options = {UI.T("Uno", "One"), UI.T("Dos", "Two"), UI.T("Tres", "Three")},
    CurrentOptions = {"One"},
    Flag = "demo_multi",
    Callback = function(list) print("Multi:", table.concat(list, ", ")) end
})

Controls:CreateInput({
    Name = UI.T("Nombre", "Name"),
    Placeholder = UI.T("Escribe aquí", "Type here"),
    Flag = "demo_name",
    Callback = function(text) print("Input:", text) end
})

Controls:CreateInput({
    Name = UI.T("Número", "Number"),
    Numeric = true, CurrentValue = 10,
    Flag = "demo_number",
    Callback = function(n) print("Número:", n) end
})

Controls:CreateKeybind({
    Name = UI.T("Atajo", "Shortcut"),
    CurrentKeybind = Enum.KeyCode.F,
    Flag = "demo_key",
    Callback = function() print("Atajo pulsado") end
})

Controls:CreateColorPicker({
    Name = UI.T("Color", "Color"),
    CurrentValue = Color3.fromRGB(124, 108, 255),
    Flag = "demo_color",
    Callback = function(color) print("Color:", color) end
})

-- Grupo plegable: contiene los mismos componentes
local Group = Controls:CreateGroup({Name = UI.T("Opciones avanzadas", "Advanced options"), Open = false})
Group:CreateToggle({Name = UI.T("Modo avanzado", "Advanced mode"), Flag = "demo_adv"})
Group:CreateSlider({Name = UI.T("Intensidad", "Intensity"), Range = {1, 10}, CurrentValue = 5, Flag = "demo_intensity"})

-- ───────── Ajustes ─────────
local Settings = Window:CreateTab({Name = UI.T("Interfaz", "Interface"), Category = UI.T("Sistema", "System")})

Settings:CreateSection(UI.T("Apariencia", "Appearance"))

Settings:CreateDropdown({
    Name = UI.T("Tema", "Theme"),
    Options = {"Black", "Midnight", "Light", "HighContrast"},
    CurrentOption = "Black",
    Callback = function(theme) Window:SetTheme(theme) end   -- cambio en caliente
})

Settings:CreateColorPicker({
    Name = UI.T("Color de acento", "Accent color"),
    CurrentValue = Color3.fromRGB(124, 108, 255),
    Callback = function(color) Window:SetAccent(color) end
})

Settings:CreateSlider({
    Name = UI.T("Escala de la interfaz", "Interface scale"),
    Range = {0.7, 1.3}, Increment = 0.1, CurrentValue = 1,
    Callback = function(value) Window:SetUIScale(value) end
})

Settings:CreateToggle({
    Name = UI.T("Reducir animaciones", "Reduce motion"),
    CurrentValue = false,
    Callback = function(value) Window:SetReduceMotion(value) end
})

Settings:CreateSection(UI.T("Configuración", "Configuration"))

Settings:CreateLabel(UI.T(
    Window:CanPersist() and "Se guarda en archivos del ejecutor."
        or "Sin archivos: solo se guarda durante esta sesión.",
    Window:CanPersist() and "Saved to executor files."
        or "No file access: saved for this session only."))

Settings:CreateButton({
    Name = UI.T("Guardar configuración", "Save config"),
    Callback = function()
        local ok = Window:SaveConfig()
        Window:Notify({
            Type = ok and "Success" or "Error",
            Content = ok and UI.T("Configuración guardada.", "Config saved.")
                or UI.T("No se pudo guardar.", "Could not save.")
        })
    end
})

Settings:CreateButton({
    Name = UI.T("Cargar configuración", "Load config"),
    Callback = function()
        local ok = Window:LoadConfig()
        Window:Notify({
            Type = ok and "Success" or "Warning",
            Content = ok and UI.T("Configuración cargada.", "Config loaded.")
                or UI.T("No hay configuración guardada.", "No saved config.")
        })
    end
})

-- ───────── Novedades 6.1: fondo, servidor y disposición ─────────
local Diseno = Window:CreateTab({Name = UI.T("Diseño", "Layout"), Category = UI.T("Sistema", "System")})

Diseno:CreateSection(UI.T("Fondo", "Background"))
-- Añade tus propias imágenes (enlace directo a .png/.jpg, ID o archivo):
-- UI:AddBackgroundPreset("Mi imagen", "https://i.imgur.com/xxxx.png", "autor")
Diseno:CreateBackgroundPicker({})

Diseno:CreateSection(UI.T("Servidor", "Server"))
Diseno:CreateServerInfo({})

Diseno:CreateSection(UI.T("Disposición", "Layout"))
-- Se apaga solo al pulsar la X de la barra de edición
Diseno:CreateLayoutEditToggle({})
Diseno:CreateButton({
    Name = UI.T("Restablecer disposición", "Reset layout"),
    Callback = function()
        Window:ResetLayout()
        Window:Notify({Type = "Success", Content = UI.T("Disposición restablecida.", "Layout reset.")})
    end
})

Window:OnLoaded(function()
    Window:Notify({
        Type = "Success",
        Title = "NEXUS UI v" .. UI.Version,
        Content = UI.T("Interfaz lista.", "Interface ready.")
    })
end)

end

return UI
