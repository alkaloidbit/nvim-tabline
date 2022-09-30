local M = {}
local fn = vim.fn
local colors = require('colors')

local cterm = nil

local function set_iconhighlight(iconhilight, state)
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
    return iconhlname
end

function table.slice(tbl, first, last, step)
    local sliced = {}

    for i = first or 1, last or #tbl, step or 1 do
        sliced[#sliced + 1] = tbl[i]
    end
    return sliced
end

local function get_icon(opts)
    local loaded, webdev_icons = pcall(require, 'nvim-web-devicons')
    local name = fn.fnamemodify(opts.path, ':t')
    local icon, hl = webdev_icons.get_icon(name, opts.extension)
    if not icon then
        return '', ''
    end
    return icon, hl
end

local function shortenFilename(bufname, options)
    -- Shorten dir name
    local max = options.dir_max_chars
    local short =
        fn.substitute(bufname, '[^/]\\{' .. max .. '}\\zs[^/]*\\ze/', '', 'g')
    -- Decrease dir count
    max = options.filename_max_dirs
    local parts = fn.split(short, '/')
    if #parts > max then
        parts = table.slice(parts, #parts - max, #parts)
    end
    return parts
end

function M.filename(bufnr, options, cache_key, tab_is_current)
    -- TODO: handle cache_key
    -- TODO: handle other buffer type icon
    local filetype = fn.getbufvar(bufnr, '&filetype')
    local bufname = fn.bufname(bufnr)
    local label = ''
    if bufname == '' then
        label = label .. options.no_name .. ' '
    else
        P(filetype)
        local parts = shortenFilename(bufname, options)
        local iconhilight = '%#TabLine#'
        local icon = ''
        if filetype == #'qf' then
            icon = ''
        elseif filetype == #'Trouble' then
            print('hahahaha')
            icon = ''
        elseif vim.g.nvim_web_devicons then
            local opts = {}
            opts.extension = fn.fnamemodify(bufname, ':e')
            opts.path = bufname
            icon, iconhilight = get_icon(opts)
            -- P(icon)
            -- P(iconhilight)
        end

        local tabhighlight = (
            tab_is_current > 0 and '%#TabLineSel#' or '%#TabLine#'
        )

        local state = tab_is_current > 0 and 'selected' or 'inactive'
        label = '%#'
            .. set_iconhighlight(iconhilight, state)
            .. '#'
            .. icon
            .. ' '
            .. tabhighlight
            .. fn.join(parts, '/')
    end
    return label
end

return M
