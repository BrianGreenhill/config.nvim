#!/usr/bin/env bash
set -e

PLUGIN_DIR="pack/plugins/start"

function helptags {
    echo "Generating helptags..."
    nvim --headless -c "helptags ALL" -c 'quit'
}

function add_plugins {
    plugin_name=$(basename "$1" .git)
    if [ -d "$PLUGIN_DIR/$plugin_name" ]; then
        echo "$plugin_name already installed, skipping..."
        return
    fi
    echo "Adding $plugin_name..."
    if [ -n "$2" ]; then
        git submodule add -b "$2" "$1" "$PLUGIN_DIR/$plugin_name"
    else
        git submodule add "$1" "$PLUGIN_DIR/$plugin_name"
    fi
    helptags
}

function remove_plugins {
    plugin_name="$1"
    if [ ! -d "$PLUGIN_DIR/$plugin_name" ]; then
        echo "$plugin_name is not installed, skipping..."
        return
    fi
    echo "Removing $plugin_name..."
    git submodule deinit -f "$PLUGIN_DIR/$plugin_name"
    rm -rf ".git/modules/$PLUGIN_DIR/$plugin_name"
    git rm -f "$PLUGIN_DIR/$plugin_name"
    git commit -m "Remove submodule $plugin_name"
    helptags
}

function update_plugins {
    echo "Updating plugins..."
    git submodule update --init --recursive

    function update_submodule {
        local submodule=$1
        (
            cd "$submodule_path" || { echo "Failed to cd into $submodule_path"; exit; }

            # Correct path to the .gitmodules file
            branch=$(git config -f "$PWD/../../../../.gitmodules" submodule."$submodule_path".branch || true)
            if [ -z "$branch" ]; then
                if git rev-parse --verify origin/main > /dev/null 2>&1; then
                    branch=main
                elif git rev-parse --verify origin/master > /dev/null 2>&1; then
                    branch=master
                else
                    echo "No main or master branch found for submodule $submodule, skipping..."
                    exit
                fi
            fi
            git fetch origin "$branch" &&
            git checkout "$branch" &&
            git pull origin "$branch"
        ) &
    }

    export -f update_submodule

    for submodule_path in $(git submodule status | awk '{print $2}'); do
        update_submodule "$submodule_path"
    done

    wait
    helptags
}

case "$1" in
    add)
        if [ -z "$2" ]; then
            echo "Usage: $0 add <repo-url> [branch]"
            exit 1
        fi
        add_plugins "$2" "$3"
        ;;
    update)
        update_plugins
        ;;
    list)
        echo "Listing plugins..."
        git submodule status | awk '{print $2}'
        ;;
    remove)
        if [ -z "$2" ]; then
            echo "Usage: $0 remove <plugin-name>"
            exit 1
        fi
        remove_plugins "$2"
        ;;
    sync)
        echo "Syncing plugins..."
        git submodule sync --recursive
        git submodule update --init --recursive
        ;;
    helptags)
        helptags
        ;;
    *)
        echo "Usage: $0 {add|update|remove|list|sync} [arguments]"
        exit 1
        ;;
esac
