-- Pre-register the monokai palette so Util.mod() can find it
-- regardless of which runtimepath entry provides tokyonight core
local modname = "tokyonight.colors.monokai"
if not package.loaded[modname] then
  local paths = vim.api.nvim_get_runtime_file("lua/tokyonight/colors/monokai.lua", false)
  if #paths > 0 then
    package.loaded[modname] = dofile(paths[1])
  end
end

require("tokyonight").load({ style = "monokai" })
