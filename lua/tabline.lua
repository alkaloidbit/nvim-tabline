-- nvim-tabline
-- David Zhang <https://github.com/crispgm>

local M = {}
local fn = vim.fn
local utilities = require('utilities')
local badge_numeric_charset =
    { '¹', '²', '³', '⁴', '⁵', '⁶', '⁷', '⁸', '⁹' }

M.options = {
    show_index = true,
    show_modify = true,
    modify_indicator = ' ●',
    no_name = '[No Name]',
    filename_max_dirs = 2,
    dir_max_chars = 5,
}
local function is_file_buffer(bufnr)
    return fn.empty(fn.getbufvar(bufnr, '&buftype'))
end

local function numtr(number, charset)
    return charset[number]
end

local function tabline(options)
    local s = '%#TabLineAlt# %{badge#project()} %#TabLineAltShade#'
    for index = 1, fn.tabpagenr('$') do
        -- current window of tab index
        local winnr = fn.tabpagewinnr(index)
        -- buffer list in the current window
        local buflist = fn.tabpagebuflist(index)
        -- current buffer
        local bufnr = buflist[winnr]
        local bufname = fn.bufname(bufnr)
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
        if options.show_index then
            s = s .. bufnr .. '. '
        end

        -- buf name
        s = s .. utilities.filename(bufnr, options, 'tabname', tab_is_current)

        local wincount = #buflist
        for _, v in ipairs(buflist) do
            local buffiletype = fn.getbufvar(v, '&filetype')
            if fn.empty(buffiletype) == 1 or is_file_buffer(v) ~= 1 then
                wincount = wincount - 1
            end
        end
        if wincount > 1 then
            s = s .. numtr(wincount, badge_numeric_charset)
        end
        -- modify indicator
        if
            bufmodified == 1
            and options.show_modify
            and options.modify_indicator ~= nil
        then
            if index == fn.tabpagenr() then
                s = s
                    .. '%#TabLineSelModified#'
                    .. options.modify_indicator
                    .. ' %*'
            else
                s = s .. '%*' .. options.modify_indicator .. ' %*'
            end
        end
        if index == fn.tabpagenr() then
            s = s .. '%#TabLineSel# %#TabLineFill#'
        else
            s = s .. '%#TabLine#'
        end
    end

    local session_name = fn.tr(vim.v.this_session, '%', '/')
    s = s .. '%#TabLineFill#%T%=%#TabLine#' .. ' %{badge#branch()}   '
    s = s
        .. ' %{badge#session("'
        .. fn.fnamemodify(session_name, ':t:r')
        .. ' ")}'
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
