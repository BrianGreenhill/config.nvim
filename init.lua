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

local set = vim.keymap.set
set("n", "<leader>w", "<cmd>:w<cr>", { desc = "Save file" })
set("n", "<leader>q", "<cmd>:q<cr>", { desc = "Quit" })
set("n", "<leader>s", "<cmd>source $MYVIMRC<cr>:echo 'vimrc sourced'<cr>", { desc = "Source current file" })
set("n", "<leader>gs", "<cmd>:G<cr>", { desc = "[G]it [s]tatus" })
set('v', '<leader>y', '"+y')
set('n', '<leader>Y', '"+Y', { noremap = false })
set('n', '<leader>d', '"_d')
set('v', '<leader>d', '"_d')

-- colors
vim.cmd.colorscheme 'catppuccin'

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
    defaults = {
        sorting_strategy = 'ascending',
        layout_strategy = 'vertical',
        layout_config = {
            prompt_position = 'top',
            width = 0.5,
            height = 0.5,
        },
        vimgrep_arguments = {
            'rg', '--color=never', '--no-heading', '--with-filename', '--line-number', '--column', '--smart-case', '--no-ignore', '--hidden',
        },
        file_ignore_patterns = { '.git', 'node_modules', 'vendor', 'plugged', 'tags', 'autoload' },
        preview = false,
    },
    extensions = {
        wrap_results = true,
        fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = 'smart_case',
        },
        ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
        },
    },
}

pcall(require('telescope').load_extension, 'fzf')
pcall(require('telescope').load_extension, 'ui-select')

local builtin = require 'telescope.builtin'
set('n', '<leader>sh', builtin.help_tags)
set('n', '<C-p>', builtin.find_files)
set('n', '<leader>sw', builtin.grep_string)
set('n', '<leader><leader>', builtin.buffers)
set('n', '<leader>/', builtin.current_buffer_fuzzy_find)
set('n', '<leader>s/', builtin.live_grep)
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
                diagnostics = {
                    disable = { 'missing-fields' },
                    globals = { 'vim' },
                },
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
