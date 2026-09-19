-- hypr/utils/binds.lua
-- Helper pra criar keybinds sem repetir código.
-- Substitui create_bind / flatten_keybinds / normalise_keybind / etc. do Caelestia.

local M = {}

-- Flags (terceiro argumento do hl.bind)
M.locked           = { locked = true }                -- funciona mesmo com a tela travada
M.repeating        = { repeating = true }             -- repete enquanto segura a tecla
M.locked_repeating = { locked = true, repeating = true }
M.mouse            = { mouse = true }                 -- bind de mouse (drag / resize)
M.release          = { release = true }               -- dispara ao SOLTAR a tecla

-- Flags "dinâmicas": repete, exceto se a tecla for de scroll do mouse
function M.repeating_unless_mouse(key)
    if key:lower():find("mouse", 1, true) then
        return nil
    end
    return M.repeating
end

-- bind(teclas, ação, flags)
--   teclas: string, lista de strings, ou nil (nil = bind desativado)
--   flags:  nil, uma tabela de flags, ou function(tecla) -> flags
function M.bind(keys, action, flags)
    if keys == nil then
        return
    end
    if type(keys) ~= "table" then
        keys = { keys }
    end

    -- pairs (e não ipairs) de propósito: se o primeiro item da lista for nil
    -- (variável não definida), o ipairs pararia ali e perderia os outros.
    for _, key in pairs(keys) do
        if type(key) == "string" and key:match("%S") then
            local f = flags
            if type(flags) == "function" then
                f = flags(key)
            end
            hl.bind(key, action, f)
        end
    end
end

-- extend("SUPER", 1) -> "SUPER + 1"   (devolve nil se a base for inválida)
function M.extend(base, suffix)
    if type(base) == "string" and base:match("%S") then
        return base .. " + " .. suffix
    end
    return nil
end

return M