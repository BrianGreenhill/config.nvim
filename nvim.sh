#!/usr/bin/env bash

function remove_unused_submodules {
    # how to use:
    # 1. delete submodule from pack/plugins/start
    # 2. run this script
    # 3. the submodule will be removed from .gitmodules and .git/config
    echo "==> Removing unused plugins"
    for submodule in $(git submodule status | awk '{print $2}'); do
        if [[ ! -d $submodule ]]; then
            echo "Removing $submodule"
            git submodule deinit -f "$submodule"
            git rm -f "$submodule"
        fi
    done
}

function plugins {
    echo "==> Adding plugins"
    git submodule add https://github.com/tpope/vim-fugitive pack/plugins/start/vim-fugitive
    git submodule add https://github.com/nvim-lua/plenary.nvim pack/plugins/start/plenary.nvim
    git submodule add https://github.com/nvim-telescope/telescope-fzf-native.nvim pack/plugins/start/telescope-fzf-native.nvim
    git submodule add https://github.com/nvim-telescope/telescope-ui-select.nvim pack/plugins/start/telescope-ui-select.nvim
    git submodule add -b 0.1.x --force https://github.com/nvim-telescope/telescope.nvim pack/plugins/start/telescope.nvim
    git submodule add https://github.com/williamboman/mason.nvim pack/plugins/start/mason.nvim
    git submodule add https://github.com/j-hui/fidget.nvim pack/plugins/start/fidget.nvim
    git submodule add https://github.com/ray-x/lsp_signature.nvim pack/plugins/start/lsp_signature.nvim
    git submodule add https://github.com/neovim/nvim-lspconfig pack/plugins/start/nvim-lspconfig
    git submodule add https://github.com/stevearc/oil.nvim pack/plugins/start/oil.nvim
    git submodule add https://github.com/catppuccin/nvim pack/plugins/start/nvim
    git submodule add https://github.com/zbirenbaum/copilot.lua pack/plugins/start/copilot.lua
    git submodule add https://github.com/hrsh7th/nvim-cmp pack/plugins/start/nvim-cmp
    git submodule add https://github.com/hrsh7th/cmp-nvim-lsp pack/plugins/start/cmp-nvim-lsp
    git submodule add https://github.com/hrsh7th/cmp-path pack/plugins/start/cmp-path
    git submodule add https://github.com/hrsh7th/cmp-buffer pack/plugins/start/cmp-buffer
    git submodule add https://github.com/windwp/nvim-autopairs pack/plugins/start/nvim-autopairs
    git submodule add https://github.com/nvim-treesitter/nvim-treesitter pack/plugins/start/nvim-treesitter
    git submodule add https://github.com/folke/lazydev.nvim pack/plugins/start/lazydev.nvim
}

function update_plugins {
    echo "==> Updating plugins"
    git submodule update --init --recursive
    git submodule foreach 'git fetch origin && git branch -m master main || true'
}

remove_unused_submodules
plugins
update_plugins
