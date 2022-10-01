-- nvim-tabline
-- David Zhang <https://github.com/crispgm>

local M = {}
local fn = vim.fn
local utilities = require('utilities')

M.options = {
    show_index = true,
    show_modify = true,
    modify_indicator = ' ●',
    no_name = '[No Name]',
    filename_max_dirs = 2,
    dir_max_chars = 5,
}

local function tabline(options)
    local s = utilities.get_project_root_dir()

    for index = 1, fn.tabpagenr('$') do
        -- current window
        local winnr = fn.tabpagewinnr(index)
        local buflist = fn.tabpagebuflist(index)
        -- buffer in current window
        local bufnr = buflist[winnr]
        local bufmodified = fn.getbufvar(bufnr, '&mod')
        local tab_is_current = 0
        s = s .. '%' .. index .. 'T'
        if index == fn.tabpagenr() then
            s = s .. '%#TabLineFill#%#TabLineSel#'
            tab_is_current = 1
        else
            s = s .. '%#TabLine#'
        end
        -- tab index
        s = s .. ' '
        -- index
        s = options.show_index and s .. bufnr .. '. ' or ''

        -- buf name
        s = s .. utilities.filename(bufnr, options, 'tabname', tab_is_current)

        s = s .. utilities.wincount(buflist)

        -- modify indicator
        s = s .. utilities.modified(index, bufmodified, options)

        if index == fn.tabpagenr() then
            s = s .. '%#TabLineSel# %#TabLineFill#'
        else
            s = s .. '%#TabLine#'
        end
    end

    s = s .. utilities.get_current_session()

    return s
end

function M.setup(user_options)
    M.options = vim.tbl_extend('force', M.options, user_options)

    function _G.nvim_tabline()
        return tabline(M.options)
    end

    vim.o.showtabline = 2
    vim.o.tabline = '%!v:lua.nvim_tabline()'

    vim.g.loaded_nvim_tabline = 1
end

return M
