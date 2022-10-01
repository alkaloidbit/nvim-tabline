local colors = require('colors')
local utils = require('utils')

local cterm = nil
icon, iconhilight = require('nvim-web-devicons').get_icon('tmp', 'lua')

function set_iconhighlight(iconhilight, state)
    -- iconhilight = 'DevIconLua', state = 'selected' ||  'inactive'
    -- We get icon fg color hl = { foreground = 6193500 }
    local success, hl =
        pcall(vim.api.nvim_get_hl_by_name, iconhilight, not cterm)
    fg = colors.get_color({ name = iconhilight, attribute = 'fg' })
    -- We get fg color #5e81ac

    -- state of tab
    local tabstate = {}
    tabstate.selected = 'TabLineSel'
    tabstate.inactive = 'TabLine'

    -- tab background ( tabstate )
    local tabhl = vim.api.nvim_get_hl_by_name(tabstate[state], not cterm)
    bg = colors.get_color({ name = tabstate[state], attribute = 'bg' })

    local iconhlcolors = {}
    iconhlcolors.fg = fg
    iconhlcolors.bg = bg
    iconhlcolors.default = true

    local iconhlname = tabstate[state] .. iconhilight

    vim.api.nvim_set_hl(0, iconhlname, iconhlcolors)
end

set_iconhighlight(iconhilight, 'inactive')
