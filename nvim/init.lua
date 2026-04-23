---------------------
--- NEOVIM CONFIG ---
---------------------

-- Basic nvim config
-- theme/transparency
vim.cmd.colorscheme("retrobox") -- most gruvbox-like
vim.api.nvim_set_hl(0, "Normal", {bg = "none"})
vim.api.nvim_set_hl(0, "NormalNC", {bg = "none"})
vim.api.nvim_set_hl(0, "EndOfBuffer", {bg = "none"})

-- basic settings
vim.opt.number = true -- line number
vim.opt.relativenumber = true -- relative line numbers
vim.opt.cursorline = true -- highlight current line
vim.opt.wrap = false -- no wrapping
vim.opt.scrolloff = 10 -- keep 10 to below and above cursor
vim.opt.sidescrolloff = 10 -- same but to the sides

-- indentation
vim.opt.tabstop = 3
vim.opt.shiftwidth = 3
vim.opt.softtabstop = 3
vim.opt.expandtab = true -- use spaces instead of tab
vim.opt.smartindent = true -- smart auto-indent
vim.opt.autoindent = true -- copy indent from current lines

-- search settings
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true
vim.opt.hlsearch = true

-- visual settings
vim.opt.signcolumn = "yes"
vim.opt.colorcolumn = "80"
vim.opt.termguicolors = true
vim.opt.showmatch = true
vim.opt.completeopt = "menuone,noinsert,noselect"
vim.opt.winblend = 0
vim.opt.lazyredraw = true
vim.opt.showmode = false
vim.opt.synmaxcol = 300 -- syntax highlight limit

-- file handling
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.swapfile = false
vim.opt.undofile = true
local undodir = vim.fn.expand("~/.vim/undodir")
if
    vim.fn.isdirectory(undodir) == 0
then
    vim.fn.mkdir(undodir, "p")
end
vim.opt.undodir = undodir
vim.opt.updatetime = 300
vim.opt.autoread = true
vim.opt.autowrite = false

-- behavior settings
vim.opt.hidden = true
vim.opt.errorbells = false
vim.opt.backspace = "indent,eol,start"
vim.opt.autochdir = false
vim.opt.iskeyword:append("-")
vim.opt.path:append("**")
vim.opt.selection = "inclusive"
vim.opt.clipboard:append("unnamedplus")
vim.opt.modifiable = true
vim.opt.encoding = "UTF-8"

-- folding
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel = 99 -- start with all folds open

-- splitting
vim.opt.splitbelow = true
vim.opt.splitright = true

-- completion
vim.opt.wildmenu = true
vim.wildmode = "longest:full,full"
vim.opt.diffopt:append("linematch:60")
vim.opt.redrawtime = 10000
vim.opt.maxmempattern = 20000

-- key mappings
vim.g.mapleader = " "
vim.g.localleader = " "
vim.keymap.set("", "<C-c>", "<Esc>")

-- Y to end of line
vim.keymap.set("n", "Y", "y$", {desc = "Yank to the end of line"})

-- buffer navigation
vim.keymap.set("n", "<leader>bn", ":bnext<CR>", {desc = "Next buffer"})
vim.keymap.set("n", "<leader>bp", ":bprevious<CR>", {desc = "Previous buffer"})

-- indentation in visual mode
vim.keymap.set("v", "<", "<gv", {desc = "Indent left and reselect"})
vim.keymap.set("v", ">", ">gv", {desc = "Indent right and reselect"})

-- file navigation
vim.keymap.set("n", "<leader>e", ":Explore<CR>", {desc = "Open file explorer"})
vim.keymap.set("n", "<leader>ff", ":find ", {desc = "Find file"})

-- command line completion
vim.opt.wildmenu = true
vim.opt.wildmode = "longest:full,full"

--=========================================================
--=                   STATUSLINE                          =
--=========================================================

-- Git branch function
local cached_branch = ""
local last_check = 0
local function git_branch()
  local now = vim.loop.now()
  if now - last_check > 5000 then
      cached_branch = vim.fn.system("git branch --show-current 2>/dev/null | tr -d '\n'")
      last_check = now
  end
  if cached_branch ~= "" then
    return " \u{e725} " .. cached_branch .. " "
  end
  return ""
end

-- File type with icon
local function file_type()
  local ft = vim.bo.filetype
  local icons = {
    lua = "[LUA]",
    python = "[PY]",
    markdown = "[MD]",
    vim = "[VIM]",
    sh = "[SH]",
    cpp = "[C++]",
    txt = "[TXT]"
  }

  if ft == "" then
    return " \u{f15} "
  end

  return (icons[ft] or " \u{f15b} ")
end

-- file size
local function file_size()
  local size = vim.fn.getfsize(vim.fn.expand("%"))
  if size < 0 then
    return ""
  end
  local size_str
  if size < 1024 then
    size_str = size .. "B"
  elseif size < 1024*1024 then
    size_str = string.format("%.1fKb", size/1024)
  else
    size_str = string.format("%.1fMb", size/1024/1024)
  end
  return " \u{f016} " .. size_str .. " "
end

-- LSP status
local function lsp_status()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients > 0 then
    return " LSP "
  end
  return ""
end

-- Word count for text files
local function word_count()
  local ft = vim.bo.filetype
  if ft == "markdown" or ft == "text" or ft == "tex" then
    local words = vim.fn.wordcount().words
    return "  " .. words .. " words "
  end
  return ""
end

-- Mode indicators with icons
local function mode_icon()
  local mode = vim.fn.mode()
  local modes = {
    n = "NORMAL",
    i = "INSERT",
    v = "VISUAL",
    V = "V-LINE",
    ["\22"] = "V-BLOCK",  -- Ctrl-V
    c = "COMMAND",
    s = "SELECT",
    S = "S-LINE",
    ["\19"] = "S-BLOCK",  -- Ctrl-S
    R = "REPLACE",
    r = "REPLACE",
    ["!"] = "SHELL",
    t = "TERMINAL"
  }
  return (modes[mode] or "  ") .. mode:upper()
end

_G.mode_icon = mode_icon
_G.git_branch = git_branch
_G.file_type = file_type
_G.file_size = file_size
_G.lsp_status = lsp_status

vim.cmd([[
  highlight StatusLineBold gui=bold cterm=bold
]])

-- Function to change statusline based on window focus
local function setup_dynamic_statusline()
  vim.api.nvim_create_autocmd({"WinEnter", "BufEnter"}, {
    callback = function()
    vim.opt_local.statusline = table.concat {
      "  ",
      "%#StatusLineBold#",
      "%{v:lua.mode_icon()}",
      "%#StatusLine#",
      " │ %f %h%m%r",
      "%{v:lua.git_branch()}",
      " │ ",
      "%{v:lua.file_type()}",
      " | ",
      "%{v:lua.file_size()}",
      " | ",
      "%{v:lua.lsp_status()}",
      "%=",                     -- Right-align everything after this
      "%l:%c  %P ",             -- Line:Column and Percentage
    }
    end
  })
  vim.api.nvim_set_hl(0, "StatusLineBold", { bold = true })

  vim.api.nvim_create_autocmd({"WinLeave", "BufLeave"}, {
    callback = function()
      vim.opt_local.statusline = "  %f %h%m%r │ %{v:lua.file_type()} | %=  %l:%c   %P "
    end
  })
end

setup_dynamic_statusline()

--=========================================
--=            AUTOCOMMANDS               =
--=========================================

-- highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost",
{
  group = augroup,
  callback = function()
    vim.hl.on_yank()
  end,
})

-- return to last cursor position
vim.api.nvim_create_autocmd("BufReadPost",
{
  group = augroup,
  desc = "Restore last cursor position",
  callback = function()
    if vim.o.diff then
      return
    end

    local last_pos = vim.api.nvim_buf_get_mark(0, '"')
    local last_line = vim.api.nvim_buf_line_count(0)

    local row = last_pos[1]
    if row < 1 or row > last_line then
      return
    end

    pcall(vim.api.nvim_win_set_cursor, 0, last_pos)
  end,
})

-- wrap, linebreak and spellcheck markdown and text files
vim.api.nvim_create_autocmd("FileType",
{
  group = augroup,
  pattern = { "markdown", "text", "gitcommit" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.spell = true
  end,
})

--=========================================
--=                PLUGINS                =
--=========================================

vim.pack.add({
  "https://www.github.com/nvim-tree/nvim-tree.lua",
  "https://www.github.com/ibhagwan/fzf-lua",
  "https://www.github.com/nvim-mini/mini.nvim",
  "https://www.github.com/lewis6991/gitsigns.nvim",
  {
    src = "https://www.github.com/nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",

  },
  "https://www.github.com/neovim/nvim-lspconfig",
  "https://www.github.com/mason-org/mason.nvim",
  "https://www.github.com/creativenull/efmls-configs-nvim",
  {
		src = "https://github.com/saghen/blink.cmp",
		version = vim.version.range("1.*"),
	},
	"https://github.com/L3MON4D3/LuaSnip",
})

local function packadd(name)
  vim.cmd("packadd " .. name)
end

--==============NVIM TREE===================
packadd("nvim-tree.lua")

require("nvim-tree").setup(
{
  view = { width = 40, },
  filters = { dotfiles = false, },
  renderer = { group_empty = true,},
})

vim.keymap.set("n", "<leader>e", function()
  require("nvim-tree.api").tree.toggle()
end,
{ desc = "Toggle NvimTree" })

--=================FZF LUA=================
packadd("fzf-lua")

require("fzf-lua").setup({})

vim.keymap.set("n", "<leader>ff", function()
  require("fzf-lua").files()
end, { desc = "FZF files" })

vim.keymap.set("n", "<leader>fg", function()
  require("fzf-lua").live_grep()
end, { desc = "FZF live grep" })

vim.keymap.set("n", "<leader>fb", function()
  require("fzf-lua").buffer()
end, { desc = "FZF buffers" })

vim.keymap.set("n", "<leader>fh", function()
  require("fzf-lua").help_tags()
end, { desc = "FZF help tags" })

vim.keymap.set("n", "<leader>fx", function()
  require("fzf-lua").diagnostics_document()
end, { desc = "FZF diagnostics document" })

vim.keymap.set("n", "<leader>fX", function()
  require("fzf-lua").diagnostics_workspace()
end, { desc = "FZF diagnostics workspace" })

--================MINI NVIM================
packadd("mini.nvim")

require("mini.ai").setup({})
require("mini.comment").setup({})
require("mini.move").setup({})
require("mini.surround").setup({})
require("mini.cursorword").setup({})
require("mini.indentscope").setup({})
require("mini.pairs").setup({})
require("mini.trailspace").setup({})
require("mini.bufremove").setup({})
require("mini.notify").setup({})
require("mini.icons").setup({})

--=================GITSIGNS================
packadd("gitsigns.nvim")

require("gitsigns").setup(
  {
    signs = {
      add = {text = "\u{2590}"},
      change = {text = "\u{2590}"},
      delete = {text = "\u{2590}"},
      topdelete = {text = "\u{25e6}"},
      changedelete = {text = "\u{25cf}"},
      untracked = {text = "\u{25cb}"},
    }
  }
)

vim.keymap.set("n", "]h", function()
  require("gitsigns").next_hunk()
end, { desc = "Next git hunk" })

vim.keymap.set("n", "[h", function()
  require("gitsigns").prev_hunk()
end, { desc = "Previous git hunk" })

vim.keymap.set("n", "<leader>hs", function()
  require("gitsigns").stage_hunk()
end, { desc = "Stage hunk" })

vim.keymap.set("n", "<leader>hr", function()
  require("gitsigns").reset_hunk()
end, { desc = "Reset hunk" })

vim.keymap.set("n", "<leader>hp", function()
  require("gitsigns").preview_hunk()
end, { desc = "Preview hunk" })

vim.keymap.set("n", "<leader>hb", function()
  require("gitsigns").blame_line({ full = true })
end, { desc = "Blame line" })

vim.keymap.set("n", "<leader>hB", function()
  require("gitsigns").toggle_current_line_blame()
end, { desc = "Toggle inline blame" })

vim.keymap.set("n", "<leader>hd", function()
  require("gitsigns").diffthis()
end, { desc = "Diff this" })

--=================TREESITTER================
packadd("nvim-treesitter")

local setup_treesitter = function()
  local treesitter = require("nvim-treesitter")
  treesitter.setup({})
  local ensure_installed = {
    "vim",
    "vimdoc",
    "c",
    "cpp",
    "html",
    "css",
    "lua",
    "json",
    "lua",
    "markdown",
    "python",
    "bash",
  }

  local config = require("nvim-treesitter.config")

  local already_installed = config.get_installed()
  local parsers_to_install = {}

  for _, parser in ipairs(ensure_installed) do
    if not vim.tbl_contains(already_installed, parser) then
      table.insert(parsers_to_install, parser)
    end
  end

  if #parsers_to_install > 0 then
    treesitter.install(parsers_to_install)
  end

  local group = vim.api.nvim_create_augroup("TreeSitterConfig", { clear = true })
  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    callback = function(args)
      if vim.list_contains(treesitter.get_installed(), vim.treesitter.language.get_lang(args.match)) then
        vim.treesitter.start(args.buf)
      end
    end,
  })
end

setup_treesitter()

--=================LSP CONFIG================
packadd("nvim-lspconfig")
packadd("mason.nvim")
require("mason").setup({})
packadd("efmls-configs-nvim")

local diagnostic_signs = {
	Error = " ",
	Warn = " ",
	Hint = "",
	Info = "",
}

vim.diagnostic.config({
	virtual_text = { prefix = "●", spacing = 4 },
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = diagnostic_signs.Error,
			[vim.diagnostic.severity.WARN] = diagnostic_signs.Warn,
			[vim.diagnostic.severity.INFO] = diagnostic_signs.Info,
			[vim.diagnostic.severity.HINT] = diagnostic_signs.Hint,
		},
	},
	underline = true,
	update_in_insert = false,
	severity_sort = true,
	float = {
		border = "rounded",
		source = "always",
		header = "",
		prefix = "",
		focusable = false,
		style = "minimal",
	},
})

do
	local orig = vim.lsp.util.open_floating_preview
	function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
		opts = opts or {}
		opts.border = opts.border or "rounded"
		return orig(contents, syntax, opts, ...)
	end
end

local function lsp_on_attach(ev)
	local client = vim.lsp.get_client_by_id(ev.data.client_id)
	if not client then
		return
	end

	local bufnr = ev.buf
	local opts = { noremap = true, silent = true, buffer = bufnr }

	vim.keymap.set("n", "<leader>gd", function()
		require("fzf-lua").lsp_definitions({ jump_to_single_result = true })
	end, opts)

	vim.keymap.set("n", "<leader>gD", vim.lsp.buf.definition, opts)

	vim.keymap.set("n", "<leader>gS", function()
		vim.cmd("vsplit")
		vim.lsp.buf.definition()
	end, opts)

	vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
	vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

	vim.keymap.set("n", "<leader>D", function()
		vim.diagnostic.open_float({ scope = "line" })
	end, opts)
	vim.keymap.set("n", "<leader>d", function()
		vim.diagnostic.open_float({ scope = "cursor" })
	end, opts)
	vim.keymap.set("n", "<leader>nd", function()
		vim.diagnostic.jump({ count = 1 })
	end, opts)

	vim.keymap.set("n", "<leader>pd", function()
		vim.diagnostic.jump({ count = -1 })
	end, opts)

	vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)

	vim.keymap.set("n", "<leader>fd", function()
		require("fzf-lua").lsp_definitions({ jump1 = true })
	end, opts)
	vim.keymap.set("n", "<leader>fr", function()
		require("fzf-lua").lsp_references()
	end, opts)
	vim.keymap.set("n", "<leader>ft", function()
		require("fzf-lua").lsp_typedefs()
	end, opts)
	vim.keymap.set("n", "<leader>fs", function()
		require("fzf-lua").lsp_document_symbols()
	end, opts)
	vim.keymap.set("n", "<leader>fw", function()
		require("fzf-lua").lsp_workspace_symbols()
	end, opts)
	vim.keymap.set("n", "<leader>fi", function()
		require("fzf-lua").lsp_implementations()
	end, opts)

	if client:supports_method("textDocument/codeAction", bufnr) then
		vim.keymap.set("n", "<leader>oi", function()
			vim.lsp.buf.code_action({
				context = { only = { "source.organizeImports" }, diagnostics = {} },
				apply = true,
				bufnr = bufnr,
			})
			vim.defer_fn(function()
				vim.lsp.buf.format({ bufnr = bufnr })
			end, 50)
		end, opts)
	end
end

vim.api.nvim_create_autocmd("LspAttach", { group = augroup, callback = lsp_on_attach })

vim.keymap.set("n", "<leader>q", function()
	vim.diagnostic.setloclist({ open = true })
end, { desc = "Open diagnostic list" })
vim.keymap.set("n", "<leader>dl", vim.diagnostic.open_float, { desc = "Show line diagnostics" })

require("blink.cmp").setup({
	keymap = {
		preset = "none",
		["<C-Space>"] = { "show", "hide" },
		["<CR>"] = { "accept", "fallback" },
		["<C-j>"] = { "select_next", "fallback" },
		["<C-k>"] = { "select_prev", "fallback" },
		["<Tab>"] = { "snippet_forward", "fallback" },
		["<S-Tab>"] = { "snippet_backward", "fallback" },
	},
	appearance = { nerd_font_variant = "mono" },
	completion = { menu = { auto_show = true } },
	sources = { default = { "lsp", "path", "buffer", "snippets" } },
	snippets = {
		expand = function(snippet)
			require("luasnip").lsp_expand(snippet)
		end,
	},

	fuzzy = {
		implementation = "prefer_rust",
		prebuilt_binaries = { download = true },
	},
})

vim.lsp.config["*"] = {
	capabilities = require("blink.cmp").get_lsp_capabilities(),
}

vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			diagnostics = { globals = { "vim" } },
			telemetry = { enable = false },
		},
	},
})

vim.lsp.config("pyright", {})
vim.lsp.config("bashls", {})
vim.lsp.config("clangd", {
  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
  },
  -- Optional: If you want to ensure it picks up your compiler's standard headers too
  init_options = {
    fallbackFlags = { "-std=c++17" },
  },
})

do
	local luacheck = require("efmls-configs.linters.luacheck")
	local stylua = require("efmls-configs.formatters.stylua")

	local flake8 = require("efmls-configs.linters.flake8")
	local black = require("efmls-configs.formatters.black")

	local prettier_d = require("efmls-configs.formatters.prettier_d")
	local eslint_d = require("efmls-configs.linters.eslint_d")

	local fixjson = require("efmls-configs.formatters.fixjson")

	local shellcheck = require("efmls-configs.linters.shellcheck")
	local shfmt = require("efmls-configs.formatters.shfmt")

	--local cpplint = require("efmls-configs.linters.cpplint")
	local clangfmt = require("efmls-configs.formatters.clang_format")

	vim.lsp.config("efm", {
		filetypes = {
			"c",
			"cpp",
      "cu",
			"css",
			"html",
			"json",
			"jsonc",
			"lua",
			"markdown",
			"python",
			"sh",
		},
		init_options = { documentFormatting = true },
		settings = {
			languages = {
				c = { clangfmt, cpplint },
				cpp = { clangfmt, cpplint },
				css = { prettier_d },
				html = { prettier_d },
				json = { eslint_d, fixjson },
				jsonc = { eslint_d, fixjson },
				lua = { luacheck, stylua },
				markdown = { prettier_d },
				python = { flake8, black },
				sh = { shellcheck, shfmt },
			},
		},
	})
end

vim.lsp.enable({
	"lua_ls",
	"pyright",
	"bashls",
	"clangd",
	"efm",
})

--=================TERMINAL==================
vim.api.nvim_create_autocmd("TermClose", {
	group = augroup,
	callback = function()
		if vim.v.event.status == 0 then
			vim.api.nvim_buf_delete(0, {})
		end
	end,
})

vim.api.nvim_create_autocmd("TermOpen", {
	group = augroup,
	callback = function()
		vim.opt_local.number = false
		vim.opt_local.relativenumber = false
		vim.opt_local.signcolumn = "no"
	end,
})

local terminal_state = { buf = nil, win = nil, is_open = false }

local function FloatingTerminal()
	if terminal_state.is_open and terminal_state.win and vim.api.nvim_win_is_valid(terminal_state.win) then
		vim.api.nvim_win_close(terminal_state.win, false)
		terminal_state.is_open = false
		return
	end

	if not terminal_state.buf or not vim.api.nvim_buf_is_valid(terminal_state.buf) then
		terminal_state.buf = vim.api.nvim_create_buf(false, true)
		vim.bo[terminal_state.buf].bufhidden = "hide"
	end

	local width = math.floor(vim.o.columns * 0.8)
	local height = math.floor(vim.o.lines * 0.8)
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	terminal_state.win = vim.api.nvim_open_win(terminal_state.buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
	})

	vim.wo[terminal_state.win].winblend = 0
	vim.wo[terminal_state.win].winhighlight = "Normal:FloatingTermNormal,FloatBorder:FloatingTermBorder"
	vim.api.nvim_set_hl(0, "FloatingTermNormal", { bg = "none" })
	vim.api.nvim_set_hl(0, "FloatingTermBorder", { bg = "none" })

	local has_terminal = false
	local lines = vim.api.nvim_buf_get_lines(terminal_state.buf, 0, -1, false)
	for _, line in ipairs(lines) do
		if line ~= "" then
			has_terminal = true
			break
		end
	end
	if not has_terminal then
		vim.fn.termopen(os.getenv("SHELL"))
	end

	terminal_state.is_open = true
	vim.cmd("startinsert")

	vim.api.nvim_create_autocmd("BufLeave", {
		buffer = terminal_state.buf,
		callback = function()
			if terminal_state.is_open and terminal_state.win and vim.api.nvim_win_is_valid(terminal_state.win) then
				vim.api.nvim_win_close(terminal_state.win, false)
				terminal_state.is_open = false
			end
		end,
		once = true,
	})
end

vim.keymap.set("n", "<leader>t", FloatingTerminal, { noremap = true, silent = true, desc = "Toggle floating terminal" })
vim.keymap.set("t", "<Esc>", function()
	if terminal_state.is_open and terminal_state.win and vim.api.nvim_win_is_valid(terminal_state.win) then
		vim.api.nvim_win_close(terminal_state.win, false)
		terminal_state.is_open = false
	end
end, { noremap = true, silent = true, desc = "Close floating terminal" })
