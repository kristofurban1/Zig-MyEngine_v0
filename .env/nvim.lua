vim.notify("LOADED NIX ENV!", vim.log.levels.INFO);

local lspconfig = require('lspconfig')
local capabilities = require('blink.cmp').get_lsp_capabilities()

lspconfig.zls.setup({ capabilities = capabilities })

local parser_config = require("nvim-treesitter.parsers").get_parser_configs()

local ts_zig_path = os.getenv("NIX_SHELL_TS_ZIG")
if ts_zig_path then
	if vim.fn.filereadable(ts_zig_path) ~= 1 then
		vim.notify("SO File not found! " .. ts_zig_path, vim.log.levels.WARN)
	end
end

parser_config.zig = {
	install_info = {
		-- point to a dummy repo (not used because we already have the .so)
		url = "",
		files = {},
	},
	-- Tell Neovim where the .so lives:
	-- (if it’s not the default path you can hardcode a full path)
	parser = ts_zig_path,
	filetype = "zig", -- your filetype
}
