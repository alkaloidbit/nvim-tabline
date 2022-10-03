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

function M.currentBufInfo()
    local bufnr = vim.api.nvim_win_get_buf(0)
    local bufname = fn.bufname(bufnr)
    local filetype = fn.getbufvar(bufnr, '&filetype')
    local buftype = fn.getbufvar(bufnr, '&buftype')
    local extension = fn.fnamemodify(bufname, ':e')
    local filename = fn.fnamemodify(bufname, ':t')

    P('bufnr:' .. bufnr)
    P('bufname:' .. bufname)
    P('filetype: ' .. filetype)
    P('buftype: ' .. buftype)
    P('extension: ' .. extension)
    P('filename: ' .. filename)
end

local function tabline(options)
    local s = utilities.get_project_root_dir()

    -- Loop over tabpages
    for index = 1, fn.tabpagenr('$') do
        -- current window
        local winnr = fn.tabpagewinnr(index)
        -- buffers in current window
        local buflist = fn.tabpagebuflist(index)
        -- current buffer in current win
        local bufnr = buflist[winnr]
        local bufmodified = fn.getbufvar(bufnr, '&mod')
        local bufname = fn.bufname(bufnr)
        local tabstate = 'inactive'
        local opts = {
            extension = fn.fnamemodify(bufname, ':e'),
            filename = fn.fnamemodify(bufname, ':t'),
            filetype = fn.getbufvar(bufnr, '&filetype'),
        }

        s = s .. '%' .. index .. 'T' .. ' '
        if index == fn.tabpagenr() then
            s = s .. '%#TabLineFill#%#TabLineSel#'
            tabstate = 'selected'
        else
            s = s .. '%#TabLine#'
        end
        -- index
        s = options.show_index and s .. ' ' .. bufnr .. '. ' or ''

        -- icon
        s = s .. utilities.get_icon(opts, tabstate)

        -- buf name
        s = s .. utilities.filename(bufname, options, 'tabname', tabstate)

        s = s .. utilities.wincount(buflist)

        -- modify indicator
        s = s .. utilities.modified(index, bufmodified, options)

        s = (index == fn.tabpagenr()) and s .. '%#TabLineSel# %#TabLineFill#'
            or s .. '%#TabLine#'
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
