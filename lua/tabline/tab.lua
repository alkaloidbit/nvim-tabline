local utils = require('tabline.utils')
local M = {}
local fn = vim.fn

function M.render(tabpage, options)
    -- current window
    local winnr = fn.tabpagewinnr(tabpage)
    -- buffers in current window
    local buflist = fn.tabpagebuflist(tabpage)
    -- current buffer in current win
    local bufnr = buflist[winnr]
    local bufmodified = fn.getbufvar(bufnr, '&mod')
    local bufname = fn.bufname(bufnr)
    local is_current_tabpage = tabpage == fn.tabpagenr()
    local tabstate = is_current_tabpage and 'selected' or 'inactive'
    local attrs = {
        bufnr = bufnr,
        bufname = bufname,
        extension = fn.fnamemodify(bufname, ':e'),
        filename = fn.fnamemodify(bufname, ':t'),
        filetype = fn.getbufvar(bufnr, '&filetype'),
        buftype = fn.getbufvar(bufnr, '&buftype'),
    }

    local s = '%' .. tabpage .. 'T' .. ' '

    s = is_current_tabpage
            and s .. utils.separator('TabLineFill', '') .. '%#TabLineSel#'
        or '%#TabLine#'

    -- index
    s = (options.show_index and utils.is_file_buffer(bufnr) == 1)
            and s .. ' ' .. bufnr .. '. '
        or s .. ' '

    s = s .. utils.get_icon(attrs, tabstate)
    s = s .. utils.filename(attrs, options, 'tabname', tabstate)

    s = s .. utils.wincount(buflist)

    -- modify indicator
    s = s .. utils.modified(is_current_tabpage, bufmodified, options)

    s = is_current_tabpage
            and s .. '%#TabLineSel# ' .. utils.separator('TabLineFill', '')
        or s .. '%#TabLine#'
    return s
end

return M
