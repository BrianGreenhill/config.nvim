vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.opt.nu = true
vim.opt.rnu = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.termguicolors = true
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
vim.opt.completeopt = { "menu", "menuone", "noselect" }
vim.opt.shortmess:append('c')
vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath 'data' .. '/undo'
vim.opt.undolevels = 1000
vim.opt.undoreload = 10000
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 5
vim.opt.wrap = false

local set = vim.keymap.set
set("n", "<leader>w", "<cmd>:w<cr>")
set("n", "<leader>q", "<cmd>:q<cr>")
set('v', '<leader>y', '"+y')
set('n', '<leader>Y', '"+Y', { noremap = false })
set('n', '<leader>nc', '<cmd>:so ~/.config/nvim/init.lua<cr>')
set('n', '<leader>w', '<cmd>:w<cr>')
set('n', '<leader>q', '<cmd>:q<cr>')

local vim = vim
local Plug = vim.fn['plug#']
vim.call('plug#begin')

Plug('ibhagwan/fzf-lua', { branch = "main" })
Plug 'rebelot/kanagawa.nvim'
Plug 'stevearc/oil.nvim'
Plug 'zbirenbaum/copilot.lua'
Plug 'windwp/nvim-autopairs'
Plug('nvim-treesitter/nvim-treesitter', { ['do'] = ':TSUpdate' })
Plug 'williamboman/mason.nvim'
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'
Plug 'ray-x/lsp_signature.nvim'
Plug 'tpope/vim-fugitive'
Plug 'mfussenegger/nvim-dap'
Plug 'leoluz/nvim-dap-go'
Plug 'rcarriga/nvim-dap-ui'
Plug 'nvim-neotest/nvim-nio'

vim.call('plug#end')

require('kanagawa').setup({ transparent = true })
vim.cmd.colorscheme 'kanagawa-dragon'

set("n", "<leader>gs", "<cmd>:G<cr>")

require("nvim-treesitter.configs").setup({
    ensure_installed = { 'c', 'go', 'vimdoc', 'lua', 'bash', 'html', 'markdown', 'markdown_inline' },
    sync_install = false,
    auto_install = true,
    highlight = { enable = true },
    indent = { enable = true },
    additional_vim_regex_highlighting = { 'markdown', 'ruby' }
})

require('mason').setup()

require('fzf-lua').setup({
    'max-perf',
    keymap = {
        fzf = {
            ['ctrl-q'] = 'select-all+accept'
        }
    }
})
set('n', '<leader>sf', function() require('fzf-lua').files({ cmd = 'rg --files --no-ignore --glob !*.git' }) end)
set('n', '<leader>sh', require('fzf-lua').help_tags)
set('n', '<leader>sb', require('fzf-lua').buffers)
set('n', '<leader>sw', function() require('fzf-lua').grep_cword({ cmd = 'rg --vimgrep' }) end)
set('n', '<leader>s/', require('fzf-lua').live_grep_native)
set('n', '<leader>sq', require('fzf-lua').quickfix)
set('n', '<leader><leader>', require('fzf-lua').live_grep_resume)
set('n', '<leader>sn', function() require('fzf-lua').files({ cwd = vim.fn.stdpath 'config' }) end)
set('n', '<leader>sd', function() require('fzf-lua').files({ cwd = vim.env.DOTFILES }) end)

require('oil').setup()
vim.keymap.set('n', '-', '<cmd>:Oil<cr>')

-- copilot take my job
require('copilot').setup({
    suggestion = {
        auto_trigger = true,
        keymap = {
            accept = "<C-j>",
            dismiss = "<C-]>",
        },
    },
})

local cmp = require 'cmp'
cmp.setup {
    mapping = {
        ['<C-n>'] = cmp.mapping.select_next_item { behavior = cmp.SelectBehavior.Insert },
        ['<C-p>'] = cmp.mapping.select_prev_item { behavior = cmp.SelectBehavior.Insert },
        ['<C-y>'] = cmp.mapping.confirm { select = true }
    },
    sources = {
        { name = 'nvim_lsp' },
        { name = 'path' },
        { name = 'buffer' },
    },
    formatting = {
        format = function(entry, item)
            item.menu = ({
                nvim_lsp = '[LSP]',
                path = '[Path]',
                buffer = '[Buffer]',
            })[entry.source.name]
            return item
        end
    }
}

require('nvim-autopairs').setup({})
local capabilities = vim.lsp.protocol.make_client_capabilities()
local lspconfig = require('lspconfig')
local servers = {
    gopls = {},
    rust_analyzer = {},
    sorbet = {},
    lua_ls = {
        settings = {
            Lua = {
                completion = {
                    callSnippet = 'Replace',
                },
                diagnostics = {
                    enable = true,
                    globals = { 'vim' },
                },
            }
        }
    },
    bashls = {
        cmd = { "bash-language-server", "start" },
        filetypes = { "sh", "bash" },
        root_dir = lspconfig.util.find_git_ancestor,
        settings = { shellcheck = { enable = true } }
    },
    marksman = {
        cmd = { "marksman", "server" },
        filetypes = { "markdown" },
        root_dir = lspconfig.util.find_git_ancestor,
        settings = {
            markdown = {
                lint = {
                    enable = true,
                },
            },
        },

    },
}

for server_name, config in pairs(servers) do
    lspconfig[server_name].setup(vim.tbl_deep_extend('force', {
        capabilities = capabilities
    }, config))
end

vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
    callback = function(event)
        require('lsp_signature').on_attach()
        local map = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end

        map('gd', require('fzf-lua').lsp_definitions, '[G]oto [D]efinition')
        map('gr', require('fzf-lua').lsp_references, '[G]oto [R]eferences')
        map('gi', require('fzf-lua').lsp_implementations, '[G]oto [I]mplementations')
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

require("dapui").setup()
require("dap-go").setup()
local dap = require('dap')
local ui = require('dapui')
set('n', '<leader>db', dap.toggle_breakpoint)
set('n', '<F5>', dap.continue)
set('n', '<F6>', dap.step_over)
set('n', '<F7>', dap.step_into)
set('n', '<F8>', dap.step_out)
set('n', '<F9>', dap.step_back)
set('n', '<F10>', dap.restart)
dap.listeners.before.attach.dapui_config = function() ui.open() end
dap.listeners.before.launch.dapui_config = function() ui.open() end
dap.listeners.before.event_terminated.dapui_config = function() ui.close() end
dap.listeners.before.event_exited.dapui_config = function() ui.close() end
