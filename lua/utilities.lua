local M = {}
local fn = vim.fn
local colors = require('colors')
local badge_numeric_charset =
    { '¹', '²', '³', '⁴', '⁵', '⁶', '⁷', '⁸', '⁹' }

local cterm = nil

local function set_iconhighlight(iconhilight, state)
    -- iconhilight = 'DevIconLua', state = 'selected' ||  'inactive'
    -- We get icon fg color hl = { foreground = 6193500 }
    local success, hl =
        pcall(vim.api.nvim_get_hl_by_name, iconhilight, not cterm)

    -- get hexa foreground icon color
    local fg = colors.get_color({ name = iconhilight, attribute = 'fg' })
    -- We get fg color #5e81ac

    -- state of tab
    local tabstate = {}
    tabstate.selected = 'TabLineSel'
    tabstate.inactive = 'TabLine'

    -- tab background ( tabstate )
    local tabhl = vim.api.nvim_get_hl_by_name(tabstate[state], not cterm)
    local bg = colors.get_color({ name = tabstate[state], attribute = 'bg' })

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

local function is_file_buffer(bufnr)
    return fn.empty(fn.getbufvar(bufnr, '&buftype'))
end

local function numtr(number, charset)
    return charset[number]
end

function M.wincount(buflist)
    local wincount = #buflist
    for _, v in ipairs(buflist) do
        local buffiletype = fn.getbufvar(v, '&filetype')
        if fn.empty(buffiletype) == 1 or is_file_buffer(v) ~= 1 then
            wincount = wincount - 1
        end
    end
    return (wincount > 1) and numtr(wincount, badge_numeric_charset) or ''
end

function M.modified(tabpage, bufmodified, options)
    local s = ''
    if
        bufmodified == 1
        and options.show_modify
        and options.modify_indicator ~= nil
    then
        if tabpage == fn.tabpagenr() then
            s = s
                .. '%#TabLineSelModified#'
                .. options.modify_indicator
                .. ' %*'
        else
            s = s .. '%*' .. options.modify_indicator .. ' %*'
        end
    end
    return s
end

function M.get_project_root_dir()
    return '%#TabLineAlt# %{badge#project()} %#TabLineAltShade#'
end
function M.get_current_session()
    local str = ''
    str = str .. '%#TabLineFill#%T%=%#TabLine#' .. ' %{badge#branch()}   '
    local session_name = fn.tr(vim.v.this_session, '%', '/')
    str = str .. ' ' .. fn.fnamemodify(session_name, ':t:r') .. ''
    return str
end

return M
