---------------------
--- NEOVIM CONFIG ---
---------------------

-- Basic nvim config

-- theme/transparency
vim.cmd.colorscheme("retrobox") -- most gruvbox-like
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none" })

-- basic settings
vim.opt.number = true         -- line number
vim.opt.relativenumber = true -- relative line numbers
vim.opt.cursorline = true     -- highlight current line
vim.opt.wrap = false          -- no wrapping
vim.opt.scrolloff = 10        -- keep 10 to below and above cursor
vim.opt.sidescrolloff = 10    -- same but to the sides

-- indentation
vim.opt.tabstop = 3
vim.opt.shiftwidth = 3
vim.opt.softtabstop = 3
vim.opt.expandtab = true   -- use spaces instead of tab
vim.opt.smartindent = true -- smart auto-indent
vim.opt.autoindent = true  -- copy indent from current lines

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
vim.g.editorconfig = true

local undodir = vim.fn.expand("~/.vim/undodir")
if vim.fn.isdirectory(undodir) == 0 then
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
vim.keymap.set("n", "Y", "y$", { desc = "Yank to the end of line" })

-- buffer navigation
vim.keymap.set("n", "<leader>bn", ":bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader>bp", ":bprevious<CR>", { desc = "Previous buffer" })

-- indentation in visual mode
vim.keymap.set("v", "<", "<gv", { desc = "Indent left and reselect" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right and reselect" })

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
      txt = "[TXT]",
      c = "[C]",
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
   elseif size < 1024 * 1024 then
      size_str = string.format("%.1fKb", size / 1024)
   else
      size_str = string.format("%.1fMb", size / 1024 / 1024)
   end

   return "\u{f016} " .. size_str
end

-- LSP status
local function lsp_status()
   local clients = vim.lsp.get_clients({ bufnr = 0 })

   if #clients > 0 then
      return "LSP : ENABLED"
   end

   return "LSP : NONE"
end

-- file line count
local function num_lines()
   local lines = vim.fn.line("$")
   local lines_str

   if lines > 0 then
      lines_str = string.format("%d", lines)
      return "LINES: " .. lines_str
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
      ["\22"] = "V-BLOCK", -- Ctrl-V
      c = "COMMAND",
      s = "SELECT",
      S = "S-LINE",
      ["\19"] = "S-BLOCK", -- Ctrl-S
      R = "REPLACE",
      r = "REPLACE",
      ["!"] = "SHELL",
      t = "TERMINAL",
   }
   return modes[mode]
end

-- not sure what this does??
_G.mode_icon = mode_icon
_G.git_branch = git_branch
_G.file_type = file_type
_G.file_size = file_size
_G.lsp_status = lsp_status
_G.num_lines = num_lines

vim.cmd([[
  highlight StatusLineBold gui=bold cterm=bold
]])

-- Function to change statusline based on window focus
local function setup_dynamic_statusline()
   vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
      callback = function()
         vim.opt_local.statusline = table.concat({
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
            "%=", -- Right-align everything after this
            "%{v:lua.num_lines()}",
            " | ",
            "%l:%c  %P ", -- Line:Column and Percentage
         })
      end,
   })

   vim.api.nvim_set_hl(0, "StatusLineBold", { bold = true })

   vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
      callback = function()
         vim.opt_local.statusline = "  %f %h%m%r │ %{v:lua.file_type()} | %=  %l:%c   %P "
      end,
   })
end

setup_dynamic_statusline()

--=========================================
--=            AUTOCOMMANDS               =
--=========================================

-- highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
   group = augroup,
   callback = function()
      vim.hl.on_yank()
   end,
})

-- return to last cursor position
vim.api.nvim_create_autocmd("BufReadPost", {
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
vim.api.nvim_create_autocmd("FileType", {
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
   -- treesitter?
   "https://www.github.com/nvim-tree/nvim-tree.lua",
   -- fuzzy finder
   "https://www.github.com/ibhagwan/fzf-lua",
   -- mini?
   "https://www.github.com/nvim-mini/mini.nvim",
   -- ?
   "https://www.github.com/lewis6991/gitsigns.nvim",
   -- treesitter
   {
      src = "https://www.github.com/nvim-treesitter/nvim-treesitter",
      branch = "main",
      build = ":TSUpdate",
   },
   -- lsp-config
   "https://www.github.com/neovim/nvim-lspconfig",
   -- mason
   "https://www.github.com/mason-org/mason.nvim",
   -- ?
   "https://www.github.com/creativenull/efmls-configs-nvim",
   -- ?
   {
      src = "https://github.com/saghen/blink.cmp",
      version = vim.version.range("1.*"),
   },
   -- lua snippets
   "https://github.com/L3MON4D3/LuaSnip",
})

local function packadd(name)
   vim.cmd("packadd " .. name)
end

--==============NVIM TREE===================
packadd("nvim-tree.lua")

require("nvim-tree").setup({
   view = { width = 40 },
   filters = { dotfiles = false },
   renderer = { group_empty = true },
})

vim.keymap.set("n", "<leader>e", function()
   require("nvim-tree.api").tree.toggle()
end, { desc = "Toggle NvimTree" })

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

require("gitsigns").setup({
   signs = {
      add = { text = "\u{2590}" },
      change = { text = "\u{2590}" },
      delete = { text = "\u{2590}" },
      topdelete = { text = "\u{25e6}" },
      changedelete = { text = "\u{25cf}" },
      untracked = { text = "\u{25cb}" },
   },
})

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
   virtual_lines = false,
   float = {
      border = "rounded",
      source = "always",
      header = "",
      prefix = "",
      focusable = false,
      style = "minimal",
   },
})

local function lsp_on_attach(event)
   local client = vim.lsp.get_client_by_id(event.data.client_id)
   if not client then
      return
   end

   local bufnr = event.buf
   local opts = { noremap = true, silent = true, buffer = bufnr }

   -- go to definition
   vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, opts)

   -- go to definition fzf
   vim.keymap.set("n", "<leader>fd",
      function()
         require("fzf-lua").lsp_definitions({ jump_to_sinlge_result = true })
      end,
      opts)

   -- open definition in a split window
   vim.keymap.set("n", "<leader>gS",
      function()
         vim.cmd("vsplit")
         vim.lsp.buf.definition()
      end,
      opts)

   -- go to implementation
   vim.keymap.set("n", "<leader>gi", vim.lsp.buf.implementation, opts)

   -- go to implementation fzf
   vim.keymap.set("n", "<leader>fi",
      function()
         require("fzf-lua").lsp_implementations()
      end,
      opts)

   -- go to references
   vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, opts)

   -- go to references fzf
   vim.keymap.set("n", "<leader>fr",
      function()
         require("fzf-lua").lsp_references()
      end,
      opts)

   -- type definition
   vim.keymap.set("n", "<leader>gt", vim.lsp.buf.type_definition, opts)

   -- type definition fzf
   vim.keymap.set("n", "<leader>ft",
      function()
         require("fzf-lua").lsp_typedefs()
      end,
      opts)

   -- document symbols
   vim.keymap.set("n", "<leader>fs",
      function()
         require("fzf-lua").lsp_document_symbols()
      end,
      opts)

   -- workspace symbols
   vim.keymap.set("n", "<leader>ws",
      function()
         require("fzf-lua").lsp_workspace_symbols()
      end,
      opts)

   -- code actions
   vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)

   if client:supports_method("textDocument/codeAction", bufnr) then
      vim.keymap.set("n", "<leader>oi",
         function()
            vim.lsp.buf.code_action({
               context = { only = { "source.organizeImports" }, diagnostics = {} },
               apply = true,
               bufnr = bufnr,
            })
            vim.defer_fn(
               function()
                  vim.lsp.buf.format({ bufnr = bufnr })
               end,
               50
            )
         end,
         opts)
   end

   -- show diagnostics
   vim.keymap.set("n", "<leader>d",
      function()
         vim.diagnostic.open_float({ scope = "line" })
      end,
      opts)

   -- show diagnostics list
   vim.keymap.set("n", "<leader>sd",
      function()
         vim.diagnostic.setloclist({ open = true })
      end,
      opts)

   -- jump to next diagnostic
   vim.keymap.set("n", "<leader>nd",
      function()
         vim.diagnostic.jump({ count = 1 })
      end,
      opts)

   -- jump to previous diagnostic
   vim.keymap.set("n", "<leader>pd",
      function()
         vim.diagnostic.jump({ count = -1 })
      end,
      opts)

   -- show info (hover)
   vim.keymap.set("n", "<leader>K", vim.lsp.buf.hover, opts)

   -- rename variable
   vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
end

-- ?
vim.api.nvim_create_autocmd("LspAttach", { group = augroup, callback = lsp_on_attach })

-- autocompletion
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
   completion = { menu = { auto_show = true } },
   sources = { default = { "lsp", "buffer", "path" } },
   fuzzy = {
      implementation = "prefer_rust",
      prebuilt_binaries = { download = true },
   },
})

vim.lsp.config["*"] = { capabilities = require("blink.cmp").get_lsp_capabilities() }

-- Load lsp configs using nvim-lspconfig
--    no need for vim.lsp.config()

-- lua
vim.lsp.enable("lua_ls")

-- python
vim.lsp.enable("pyright")

-- bash
vim.lsp.enable("bashls")

-- c/cpp
vim.lsp.enable("clangd")

