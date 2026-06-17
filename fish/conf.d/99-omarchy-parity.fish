# Bash-like Ctrl+C on an empty line, without custom printf/repaint (those fight Fish's
# screen model and can erase the ^C line in the scrollback).
#
# Fish's reader skips ^C when the command line is truly empty — see early return in
# https://github.com/fish-shell/fish-shell/blob/master/src/reader/reader.rs
# (CancelCommandline when command_line.is_empty()).
# Inserting a zero-width space makes the buffer non-empty for one moment so the built-in
# cancel-commandline runs the same path as Bash: ^C, newline, clear, scrollback preserved.
#
# If you already define fish_user_key_bindings in ~/.config/fish/config.fish, merge there
# or call __fish_omarchy_ctrl_c from your function.

if status is-interactive
    # Fish sets universal fish_color_cancel to "-r" by default (__fish_config_interactive),
    # so the reader’s ^C uses reverse video (looks highlighted). Shadow that default only.
    if not set -q fish_color_cancel[1]
        set -g fish_color_cancel f7768e
    else if test (count $fish_color_cancel) = 1
        and string match -qr '^(-r|--reverse)$' -- $fish_color_cancel[1]
        set -g fish_color_cancel f7768e
    end

    function __fish_omarchy_ctrl_c
        if commandline -P
            commandline -f cancel-commandline
            return
        end
        if test -z (commandline)
            # U+200B ZWSP — invisible; makes buffer non-empty so Fish runs full CancelCommandline.
            commandline -i (printf '\xE2\x80\x8B')
        end
        commandline -f cancel-commandline
        # Vi insert binds "cancel-commandline repaint-mode"; emacs leaves fish_bind_mode as default.
        if test "$fish_bind_mode" = insert
            commandline -f repaint-mode
        end
    end

    function fish_user_key_bindings
        bind -M insert \cc __fish_omarchy_ctrl_c
        bind -M default \cc __fish_omarchy_ctrl_c
    end
end
