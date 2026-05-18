#!/usr/bin/env fish
# =============================================================================
# Fish shell — Tokyo Night Dark color variables
# Deploy: Run this script once to write universal variables:
#   fish fish/tokyo-night-colors.fish
# These are set as universal variables (-U) so they persist across sessions.
# No config.fish edits needed — fish reloads universal vars automatically.
# =============================================================================

# Syntax colours
set -U fish_color_normal         c0caf5      # default text
set -U fish_color_command        7aa2f7      # commands
set -U fish_color_keyword        bb9af7      # keywords (if, for, etc.)
set -U fish_color_quote          9ece6a      # quoted strings
set -U fish_color_redirection    7dcfff      # >, >>, |
set -U fish_color_end            ff9e64      # ; and &
set -U fish_color_error          f7768e      # errors
set -U fish_color_param          a9b1d6      # arguments
set -U fish_color_option         a9b1d6      # flags (--foo)
set -U fish_color_comment        565f89      # # comments
set -U fish_color_operator       7dcfff      # &&, ||, etc.
set -U fish_color_escape         bb9af7      # escape sequences \n, \t
set -U fish_color_autosuggestion 3b4261      # greyed-out completions
set -U fish_color_valid_path     --underline # valid paths get underlined

# Selection and search
set -U fish_color_match          e0af68                        # matched chars in completions
set -U fish_color_search_match   --background=292e42
set -U fish_color_selection      --background=292e42

# Pager (tab completion menu)
set -U fish_pager_color_prefix      7aa2f7 --bold
set -U fish_pager_color_completion  c0caf5
set -U fish_pager_color_description a9b1d6
set -U fish_pager_color_progress    7aa2f7 --bold
set -U fish_pager_color_selected_background 292e42

echo "Tokyo Night fish colours applied."
