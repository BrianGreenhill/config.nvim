local vim = vim
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.opt.nu = true
vim.opt.rnu = true
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.mouse = 'a'
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.termguicolors = true
vim.opt.signcolumn = 'yes'
vim.opt.inccommand = 'split'
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.clipboard = 'unnamedplus'

-- plugins

local Plug = vim.fn['plug#']
vim.call('plug#begin', '~/.config/nvim/plugged')
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-sleuth'
Plug 'tpope/vim-fugitive'
Plug 'nvim-lua/plenary.nvim'
Plug('nvim-telescope/telescope-fzf-native.nvim', { build = 'make' })
Plug('nvim-telescope/telescope-ui-select.nvim')
Plug 'folke/neodev.nvim'
Plug 'williamboman/mason.nvim'
Plug 'williamboman/mason-lspconfig.nvim'
Plug 'WhoIsSethDaniel/mason-tool-installer.nvim'
Plug 'https://git.sr.ht/~whynothugo/lsp_lines.nvim'
Plug('j-hui/fidget.nvim', { opts = {} })
Plug 'ray-x/lsp_signature.nvim'
Plug('nvim-treesitter/nvim-treesitter', { run = ':TSUpdate' })
Plug 'neovim/nvim-lspconfig'
Plug('nvim-tree/nvim-web-devicons', { enabled = true })
Plug 'nvim-lualine/lualine.nvim'
Plug('nvim-telescope/telescope.nvim')
Plug 'stevearc/oil.nvim'
Plug('catppuccin/nvim', { as = 'catppuccin' })
Plug 'zbirenbaum/copilot.lua'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'onsails/lspkind.nvim'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-buffer'
Plug('L3MON4D3/LuaSnip', { run = 'make install_jsregexp' })
Plug 'saadparwaiz1/cmp_luasnip'
Plug 'windwp/nvim-autopairs'
vim.call('plug#end')

-- colors
vim.cmd.colorscheme 'catppuccin'

local set = vim.keymap.set
set("n", "<leader>w", "<cmd>:w<cr>", { desc = "Save file" })
set("n", "<leader>q", "<cmd>:q<cr>", { desc = "Quit" })
set("n", "<leader>s", "<cmd>source $MYVIMRC<cr>:echo 'vimrc sourced'<cr>", { desc = "Source current file" })
set("n", "<leader>gs", "<cmd>:G<cr>", { desc = "[G]it [s]tatus" })
set('v', '<leader>y', '"+y') -- <leader>y in vis/norm mode to copy to clipboard
set('n', '<leader>Y', '"+Y', { noremap = false })
set('n', '<leader>d', '"_d')
set('v', '<leader>d', '"_d')

-- oil file management
require('oil').setup {
    columns = { 'icon' },
    view_options = {
        show_hidden = true,
    },
}
set("n", "-", "<cmd>Oil<cr>", { desc = "Open parent directory" })

-- copilot take my job
require('copilot').setup({
    filetypes = { yaml = true },
    suggestion = {
        enabled = true,
        auto_trigger = true,
        debounce = 75,
        keymap = {
            accept = "<C-j>",
            dismiss = "<C-]>",
        },
    },
})

-- telescope
require('telescope').setup {
    extensions = {
        wrap_results = true,
        fzf = {},
        ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
        },
    },
}

pcall(require('telescope').load_extension, 'fzf')
pcall(require('telescope').load_extension, 'ui-select')

local builtin = require 'telescope.builtin'
set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
set('n', '<C-p>', builtin.find_files, { desc = '[S]earch [F]iles' })
set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })
set('n', '<leader>/', builtin.current_buffer_fuzzy_find, { desc = '[/] Fuzzily search in current buffer' })

vim.keymap.set('n', '<leader>s/', function()
    builtin.live_grep {
        additional_args = {
            '--ignore-case',
            '--hidden',
            '--no-ignore',
            '--vimgrep',
        },
        prompt_title = 'Live Grep',
    }
end, { desc = '[S]earch [/] by grep' })
set('n', '<leader>sn', function() builtin.find_files { cwd = vim.fn.stdpath 'config' } end)

-- completion
vim.opt.completeopt = { "menu", "menuone", "noselect" }
vim.opt.shortmess:append('c')

local lspkind = require "lspkind"
lspkind.init {}

local cmp = require 'cmp'

cmp.setup {
    sources = {
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
        { name = 'path' },
        { name = 'buffer' },
    },
    mapping = {
        ['<C-n>'] = cmp.mapping.select_next_item { behavior = cmp.SelectBehavior.Insert },
        ['<C-p>'] = cmp.mapping.select_prev_item { behavior = cmp.SelectBehavior.Insert },
        ['<C-y>'] = cmp.mapping(
            cmp.mapping.confirm {
                behavior = cmp.ConfirmBehavior.Insert,
                select = true
            },
            { "i", "c" }
        ),
    },
    snippet = {
        expand = function(args)
            vim.snippet.expand(args.body)
        end,
    },
}

-- autopairs
require('nvim-autopairs').setup {}
local cmp_autopairs = require 'nvim-autopairs.completion.cmp'
cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())

vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
    callback = function(event)
        require('lsp_signature').on_attach({
            bind = true,
            handler_opts = {
                border = 'single',
            },
        }, event.buf)

        local map = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end

        map('gd', builtin.lsp_definitions, '[G]oto [D]efinition')
        map('gr', builtin.lsp_references, '[G]oto [R]eferences')
        map('rn', vim.lsp.buf.rename, '[R]e[n]ame')
        map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
        map('K', vim.lsp.buf.hover, 'Hover Documentation')

        local client = vim.lsp.get_client_by_id(event.data.client_id)

        if client and client.server_capabilities.documentFormattingProvider then
            local format_group = vim.api.nvim_create_augroup('LspFormatting', { clear = false })
            vim.api.nvim_create_autocmd('BufWritePre', {
                group = format_group,
                buffer = event.buf,
                callback = function()
                    vim.lsp.buf.format { async = false }
                end,
            })
        end
    end,
})

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

local servers = {
    gopls = {},
    rust_analyzer = {},
    bashls = {},
    ruby_lsp = {},
    ruff = {},
    pyright = {},
    tsserver = {
        server_capabilities = {
            documentFormattingProvider = false,
        },
    },
    lua_ls = {
        settings = {
            Lua = {
                completion = {
                    callSnippet = 'Replace',
                },
                diagnostics = { disable = { 'missing-fields' } },
            },
        },
    },
}
require('mason').setup()
local ensure_installed = vim.tbl_keys(servers or {})
vim.list_extend(ensure_installed, {
    'stylua',
    'delve',
})
require('mason-tool-installer').setup { ensure_installed = ensure_installed }
require('mason-lspconfig').setup {
    handlers = {
        function(server_name)
            local server = servers[server_name] or {}
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            require('lspconfig')[server_name].setup(server)
        end,
    },
}
require('lsp_lines').setup()
vim.diagnostic.config { virtual_text = false }

-- treesitter
require('nvim-treesitter').setup {
    ensure_installed = { 'go', 'rust', 'ruby', 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'vim', 'vimdoc', 'help' },
    -- Autoinstall languages that are not installed
    auto_install = true,
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = { 'ruby' },
    },
    indent = { enable = true, disable = { 'ruby' } },
}

require('nvim-treesitter.install').prefer_git = true

-- statusline

local theme = require('lualine.themes.catppuccin')
theme.normal.c.bg = nil
require('lualine').setup {
    options = {
        theme = theme,
        section_separators = { left = '', right = '' },
        component_separators = '',
        icons_enabled = true,
        disabled_filetypes = {
            statusline = {},
            winbar = {},
        },
    },
    sections = {
        lualine_a = { { 'mode', separator = { left = '' }, right_padding = 2 } },
        lualine_b = { 'filename', 'branch' },
        lualine_c = {
        },
        lualine_x = {},
        lualine_y = { 'filetype', 'progress' },
        lualine_z = {
            { 'location', separator = { right = '' }, left_padding = 2 },
        },
    },
    inactive_sections = {
        lualine_a = { 'filename' },
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = { 'location' },
    },
    tabline = {},
    extensions = { 'fugitive', 'lazy', 'mason' },
}
