local M = {}
local fn = vim.fn
local colors = require('tabline.colors')
local badge_numeric_charset =
    { '¹', '²', '³', '⁴', '⁵', '⁶', '⁷', '⁸', '⁹' }

local icon_alt_filetype = {
    fern = ' ',
    undotree = ' ',
    qf = ' ',
    TelescopePrompt = ' ',
    Trouble = ' ',
    DiffviewFiles = ' ',
    Outline = ' ',
    NeogitStatus = ' ',
    mason = ' ',
    spectre_panel = ' ',
    ['neo-tree'] = ' ',
    ['neo-tree-popup'] = ' ',
}

local filename_alt_filetype = {
    fern = 'FERN',
    undotree = 'UNDOTREE',
    qf = 'LIST',
    TelescopePrompt = 'TELESCOPE',
    Trouble = 'TROUBLE',
    DiffviewFiles = 'DIFFVIEW',
    Outline = 'OUTLINE',
    NeogitStatus = 'NEOGIT',
    mason = 'MASON',
    spectre_panel = 'SPECTRE',
    ['neo-tree'] = 'NEOTREE',
    ['neo-tree-popup'] = 'NEOTREE POPUP',
}

local cterm = nil

function M.separator(highlight, char)
    return '%#' .. highlight .. '#' .. char
end

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

local function get_tabhighlight(state)
    local highlights = { selected = 'TabLineSel', inactive = 'TabLine' }
    return '%#' .. highlights[state] .. '#'
end

local function has_value(tab, val)
    for k, value in pairs(tab) do
        if k == val then
            return true
        end
    end
    return false
end

function M.get_icon(opts, tabstate)
    local loaded, webdev_icons = pcall(require, 'nvim-web-devicons')

    if has_value(icon_alt_filetype, opts.filetype) then
        return icon_alt_filetype[opts.filetype]
    else
        local icon, hl = webdev_icons.get_icon(opts.filename, opts.extension)

        if not icon then
            return '', ''
        end
        return '%#' .. set_iconhighlight(hl, tabstate) .. '#' .. icon .. ' '
    end
end

local function shortenBufname(bufname, options)
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

function M.filename(attrs, options, cache_key, state)
    -- TODO: handle cache_key
    -- TODO: handle other buffer type icon
    local label = ''
    if attrs.bufname == '' and fn.empty(attrs.buftype) == 1 then
        label = label .. options.no_name
    elseif has_value(filename_alt_filetype, attrs.filetype) then
        label = label .. filename_alt_filetype[attrs.filetype]
    else
        local parts = shortenBufname(attrs.bufname, options)
        label = label .. get_tabhighlight(state) .. fn.join(parts, '/')
    end
    return label
end

function M.is_file_buffer(bufnr)
    return fn.empty(fn.getbufvar(bufnr, '&buftype'))
end

local function numtr(number, charset)
    return charset[number]
end

function M.wincount(buflist)
    local wincount = #buflist
    for _, v in ipairs(buflist) do
        local buffiletype = fn.getbufvar(v, '&filetype')
        if fn.empty(buffiletype) == 1 or M.is_file_buffer(v) ~= 1 then
            wincount = wincount - 1
        end
    end
    return (wincount > 1) and numtr(wincount, badge_numeric_charset) or ''
end

function M.modified(is_current_tabpage, attrs, options)
    local s = ''
    if
        attrs.bufmodified == 1
        -- is file buffer
        and fn.empty(attrs.buftype) == 1
        and options.show_modify
        and options.modify_indicator ~= nil
    then
        s = is_current_tabpage
                and s .. '%#TabLineSelModified#' .. options.modify_indicator .. ' %*'
            or s .. '%*' .. options.modify_indicator .. ' %*'
    end
    return s
end

function M.get_project_root_dir()
    return '%#TabLineAlt# %{badge#project()} %#TabLineFill#'
end

function M.get_current_session()
    local str = ''
    str = str .. '%#TabLineFill#%T%=%#TabLine#' .. ' %{badge#branch()}   '
    local session_name = fn.tr(vim.v.this_session, '%', '/')
    str = str .. ' ' .. fn.fnamemodify(session_name, ':t:r') .. ''
    return str
end

return M
