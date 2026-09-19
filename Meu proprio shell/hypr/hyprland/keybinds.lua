-- hypr/hyprland/keybinds.lua
-- Atalhos que NÃO dependem do shell (só Hyprland + apps comuns).
-- O que depende do shell (launcher, sidebar, OSD, screenshot...) está em shellbinds.lua

local vars = require("variables")
local fn   = require("utils.functions")
local b    = require("utils.binds")

local bind = b.bind

-------------------------
---- Workspaces 1-10 ----
-------------------------

for i = 1, 10 do
    local key = i % 10 -- workspace 10 usa a tecla 0
    bind(b.extend(vars.kbGoToWs, key),           fn.wsaction("focus", "", i))
    bind(b.extend(vars.kbMoveWinToWs, key),      fn.wsaction("move", "", i))
    bind(b.extend(vars.kbGoToWsGroup, key),      fn.wsaction("focus", "group", i))
    bind(b.extend(vars.kbMoveWinToWsGroup, key), fn.wsaction("move", "group", i))
end

-- Workspace anterior / próximo
bind(vars.kbPrevWs, hl.dsp.focus({ workspace = "-1" }), b.repeating_unless_mouse)
bind(vars.kbNextWs, hl.dsp.focus({ workspace = "+1" }), b.repeating_unless_mouse)

-- Grupo de workspaces anterior / próximo
bind(vars.kbPrevWsGroup, hl.dsp.focus({ workspace = "-10" }), b.repeating_unless_mouse)
bind(vars.kbNextWsGroup, hl.dsp.focus({ workspace = "+10" }), b.repeating_unless_mouse)

-- Mover janela pro workspace anterior / próximo
bind(vars.kbMoveWinToWsNext, hl.dsp.window.move({ workspace = "+1" }), b.repeating_unless_mouse)
bind(vars.kbMoveWinToWsPrev, hl.dsp.window.move({ workspace = "-1" }), b.repeating_unless_mouse)

-- Mover janela pra / de workspace especial
bind(vars.kbMoveWinToWsSpecial, hl.dsp.window.move({ workspace = "special:special" }))
bind(vars.kbMoveWinFromWsSpecial, hl.dsp.window.move({ workspace = "e+0" }))

-- Toggle dos workspaces especiais
bind(vars.kbSpecialWs, fn.toggle("specialws"))
bind(vars.kbSystemMonitorWs, fn.toggle("sysmon"))
bind(vars.kbMusicWs, fn.toggle("music"))
bind(vars.kbCommunicationWs, fn.toggle("communication"))
bind(vars.kbTodoWs, fn.toggle("todo"))

------------------
---- Grupos ----
------------------

bind(vars.kbWindowCycleNext, hl.dsp.window.cycle_next(), b.repeating)
bind(vars.kbWindowCyclePrev, hl.dsp.window.cycle_next({ next = false }), b.repeating)
bind(vars.kbWindowGroupCycleNext, hl.dsp.group.next(), b.repeating)
bind(vars.kbWindowGroupCyclePrev, hl.dsp.group.prev(), b.repeating)
bind(vars.kbToggleGroup, hl.dsp.group.toggle())
bind(vars.kbUngroup, hl.dsp.window.move({ out_of_group = true }))
bind(vars.kbGroupLockActive, hl.dsp.group.lock_active())

---------------------
---- Janelas ----
---------------------

-- Foco e movimento com as setas
for _, dir in ipairs({ "left", "right", "up", "down" }) do
    bind("SUPER + " .. dir, hl.dsp.focus({ direction = dir }))
    bind("SUPER + SHIFT + " .. dir, hl.dsp.window.move({ direction = dir }))
end

-- Redimensionar com o teclado
bind(vars.kbWindowDecreaseWidth, fn.resize_active_window(-10, 0), b.repeating)
bind(vars.kbWindowIncreaseWidth, fn.resize_active_window(10, 0), b.repeating)
bind(vars.kbWindowDecreaseHeight, fn.resize_active_window(0, -10), b.repeating)
bind(vars.kbWindowIncreaseHeight, fn.resize_active_window(0, 10), b.repeating)

-- Arrastar / redimensionar com o mouse (272 = botão esquerdo, 273 = direito)
bind({ vars.kbMoveWindow, "SUPER + mouse:272" }, hl.dsp.window.drag(), b.mouse)
bind({ vars.kbResizeWindow, "SUPER + mouse:273" }, hl.dsp.window.resize(), b.mouse)

bind(vars.kbCenterWindow, hl.dsp.window.center())

-- Volta a janela pra 55% x 70% da tela e centraliza
bind(vars.kbNormalizeWindow, function()
    hl.dispatch(hl.dsp.window.resize(fn.resize_by_screen(55, 70)))
    hl.dispatch(hl.dsp.window.center())
end)

-- Picture-in-picture: flutua, encolhe, manda pro canto e fixa
bind(vars.kbWindowPip, function()
    local a = hl.get_active_window()
    if a then
        local pip = fn.move_actions(a) or {}
        if not a.floating then table.insert(pip, 1, hl.dsp.window.float()) end
        table.insert(pip, hl.dsp.window.pin({ action = "on", window = "address:" .. a.address }))

        for _, x in ipairs(pip) do
            hl.dispatch(x)
        end
    end
end)

bind(vars.kbPinWindow, hl.dsp.window.pin())
bind(vars.kbWindowFullscreen, hl.dsp.window.fullscreen({ mode = "fullscreen" }))
bind(vars.kbWindowBorderedFullscreen, hl.dsp.window.fullscreen({ mode = "maximized" }))
bind(vars.kbToggleWindowFloating, hl.dsp.window.float())
bind(vars.kbCloseWindow, hl.dsp.window.close())

----------------
---- Apps ----
----------------

bind(vars.kbTerminal, hl.dsp.exec_cmd(vars.terminal))
bind(vars.kbBrowser, hl.dsp.exec_cmd(vars.browser))
bind(vars.kbEditor, hl.dsp.exec_cmd(vars.editor))
bind(vars.kbFileExplorer, hl.dsp.exec_cmd(vars.fileExplorer))
bind(vars.kbAudioSettings, hl.dsp.exec_cmd(vars.audioSettings))

-----------------
---- Áudio ----
-----------------

bind({ vars.kbVolumeMute, "XF86AudioMute" },
    hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), b.locked)
bind("XF86AudioMicMute",
    hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), b.locked)
bind("XF86AudioRaiseVolume",
    hl.dsp.exec_cmd(
        "wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; wpctl set-volume -l " ..
        (vars.volumeMax / 100) .. " @DEFAULT_AUDIO_SINK@ " .. vars.volumeStep .. "%+"
    ),
    b.locked_repeating)
bind("XF86AudioLowerVolume",
    hl.dsp.exec_cmd(
        "wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; wpctl set-volume @DEFAULT_AUDIO_SINK@ " .. vars.volumeStep .. "%-"
    ),
    b.locked_repeating)

-------------------
---- Utilitários ----
-------------------

bind(vars.kbSleep, hl.dsp.exec_cmd(vars.sleepGestureCmd), b.locked)
bind(vars.kbColorPicker, hl.dsp.exec_cmd("hyprpicker -a"))

-- Cola o último item do histórico do clipboard (cliphist + ydotool)
bind(vars.kbClipboardPasteLatest,
    hl.dsp.exec_cmd('sleep 0.5s && ydotool type -d 1 "$(cliphist list | head -1 | cliphist decode)"'),
    b.locked)

-- Teste de notificação
bind("SUPER + ALT + F12",
    hl.dsp.exec_cmd("notify-send -u low 'Teste' 'Notificação de teste'"))