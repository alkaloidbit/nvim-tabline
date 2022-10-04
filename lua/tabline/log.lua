local M = {}

local fmt = string.format

function M.debug(msg)
    local info = debug.getinfo(2, 'S')
    vim.notify(fmt('%s\n%s:%s', msg, info.linedefined, info.short_src))
end

return M
