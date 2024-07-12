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
vim.opt.completeopt = { "menu", "menuone", "noselect" }
vim.opt.shortmess:append('c')
vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath 'data' .. '/undo'
vim.opt.undolevels = 1000
vim.opt.undoreload = 10000

local set = vim.keymap.set
set("n", "<leader>w", "<cmd>:w<cr>")
set("n", "<leader>q", "<cmd>:q<cr>")
set("n", "<leader>s", "<cmd>source $MYVIMRC<cr>:echo 'vimrc sourced'<cr>")
set("n", "<leader>gs", "<cmd>:G<cr>")
set('v', '<leader>y', '"+y')
set('n', '<leader>Y', '"+Y', { noremap = false })
set('n', '<leader>d', '"_d')
set('v', '<leader>d', '"_d')

-- colors
vim.cmd.colorscheme 'catppuccin'

-- oil file management
require('oil').setup { view_options = { show_hidden = true } }
set("n", "-", "<cmd>Oil<cr>")

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

-- telescope
local ts = require('telescope')
ts.setup {
    defaults = {
        vimgrep_arguments = {
            'rg', '--color=never', '--no-heading', '--with-filename', '--line-number', '--column', '--smart-case', '--no-ignore', '--hidden',
        },
    },
    extensions = {
        wrap_results = true,
        fzf = {},
        ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
        },
    },
}

pcall(ts.load_extension, 'fzf')
pcall(ts.load_extension, 'ui-select')

local builtin = require 'telescope.builtin'
set('n', '<leader>sh', builtin.help_tags)
set('n', '<C-p>', builtin.find_files)
set('n', '<leader>sw', builtin.grep_string)
set('n', '<leader><leader>', builtin.buffers)
set('n', '<leader>/', builtin.current_buffer_fuzzy_find)
set('n', '<leader>s/', builtin.live_grep)
set('n', '<leader>sn', function() builtin.find_files { cwd = vim.fn.stdpath 'config' } end)

-- completion
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
    },
    experimental = {
        ghost_text = true,
        native_menu = false,
    },
}

require('mason').setup()

-- autopairs
require('nvim-autopairs').setup {}
local cmp_autopairs = require 'nvim-autopairs.completion.cmp'
cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())

-- lsp servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())
local lspconfig = require('lspconfig')
local servers = {
    gopls = {},
    rust_analyzer = {},
    ruby_lsp = {},
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
    pyright = {},
    tsserver = {
        settings = {
            documentFormattingProvider = false,
        }
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

-- treesitter
require('nvim-treesitter').setup {
    ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline", "go", "ruby", "bash", "python" },

    auto_install = true,
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = { 'ruby' },
    },
    indent = { enable = true, disable = { 'ruby' } },
}

require('nvim-treesitter.install').prefer_git = true
