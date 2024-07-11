#!/usr/bin/env bash

git submodule add https://github.com/tpope/vim-fugitive pack/plugins/start/vim-fugitive
git submodule add https://github.com/nvim-lua/plenary.nvim pack/plugins/start/plenary.nvim
git submodule add https://github.com/nvim-telescope/telescope-fzf-native.nvim pack/plugins/start/telescope-fzf-native.nvim
git submodule add https://github.com/nvim-telescope/telescope-ui-select.nvim pack/plugins/start/telescope-ui-select.nvim
git submodule add https://github.com/nvim-telescope/telescope.nvim pack/plugins/start/telescope.nvim
git submodule add https://github.com/folke/neodev.nvim pack/plugins/start/neodev.nvim
git submodule add https://github.com/williamboman/mason.nvim pack/plugins/start/mason.nvim
git submodule add https://github.com/williamboman/mason-lspconfig.nvim pack/plugins/start/mason-lspconfig.nvim
git submodule add https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim pack/plugins/start/mason-tool-installer.nvim
git submodule add https://git.sr.ht/~whynothugo/lsp_lines.nvim pack/plugins/start/lsp_lines.nvim
git submodule add https://github.com/j-hui/fidget.nvim pack/plugins/start/fidget.nvim
git submodule add https://github.com/ray-x/lsp_signature.nvim pack/plugins/start/lsp_signature.nvim
git submodule add https://github.com/neovim/nvim-lspconfig pack/plugins/start/nvim-lspconfig
git submodule add https://github.com/stevearc/oil.nvim pack/plugins/start/oil.nvim
git submodule add https://github.com/catppuccin/nvim pack/plugins/start/nvim
git submodule add https://github.com/zbirenbaum/copilot.lua pack/plugins/start/copilot.lua
git submodule add https://github.com/hrsh7th/nvim-cmp pack/plugins/start/nvim-cmp
git submodule add https://github.com/hrsh7th/cmp-nvim-lsp pack/plugins/start/cmp-nvim-lsp
git submodule add https://github.com/onsails/lspkind.nvim pack/plugins/start/lspkind.nvim
git submodule add https://github.com/hrsh7th/cmp-path pack/plugins/start/cmp-path
git submodule add https://github.com/hrsh7th/cmp-buffer pack/plugins/start/cmp-buffer
git submodule add https://github.com/L3MON4D3/LuaSnip pack/plugins/start/LuaSnip
git submodule add https://github.com/saadparwaiz1/cmp_luasnip pack/plugins/start/cmp_luasnip
git submodule add https://github.com/windwp/nvim-autopairs pack/plugins/start/nvim-autopairs
git submodule add https://github.com/nvim-treesitter/nvim-treesitter pack/plugins/start/nvim-treesitter

git submodule update --init --recursive
# handle main and master branch names
git submodule foreach 'git fetch origin && git branch -m master main || true'
