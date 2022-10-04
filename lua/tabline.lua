-- nvim-tabline
-- David Zhang <https://github.com/crispgm>
local utils = require('tabline.utils')
local tab = require('tabline.tab')
local log = require('tabline.log')

local fn = vim.fn
local M = {}

M.options = {
    show_index = true,
    show_modify = true,
    modify_indicator = ' ●',
    no_name = '[No Name]',
    filename_max_dirs = 2,
    dir_max_chars = 5,
}

function M.currentBufInfo()
    log.debug('currentBufInfo')
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
    local s = utils.get_project_root_dir()

    -- Loop over tabpages
    for tabpage = 1, fn.tabpagenr('$') do
        s = s .. tab.render(tabpage, options)
    end

    s = s .. utils.get_current_session()

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
