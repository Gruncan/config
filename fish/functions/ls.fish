function ls --wraps='eza -lh --group-directories-first --icons=auto' --description 'List files (Omarchy-style: eza + icons when installed)'
    if not command -q eza
        command ls --color=auto -lh $argv
        return
    end

    set -l ez eza
    set -l args $argv
    set -l home_dev_icon false
    if test "$PWD" = "$HOME"
        if test (count $args) -eq 0
            set home_dev_icon true
        else if test (count $args) -eq 1
            and string match -qr '^\.$|^\./$' -- $args[1]
            set home_dev_icon true
        end
    end

    if test $home_dev_icon != true
        $ez -lh --group-directories-first --icons=auto $args
        return
    end

    # Optional overrides (universal / global lists): folder_glyphs, icon_dev
    set -l glyphs $folder_glyphs
    if test (count $glyphs) -eq 0
        set glyphs (printf '\ue5ff') (printf '\ue5fb') (printf '\uf115') (printf '\ue5fe') (printf '\ue5fc')
    end

    set -l dev_glyph $icon_dev
    if test (count $dev_glyph) -eq 0
        set dev_glyph (printf '\U000f0c8b')
    end

    # icons=auto / default color=auto: no icons or colours when stdout is not a TTY (piped).
    # Force both so post-processing keeps the same look as a direct eza run.
    $ez -lh --group-directories-first --icons=always --color=always $args | while read -l line
        if not string match -qr 'Development' -- $line
            echo $line
            continue
        end

        set -l out $line
        for g in $glyphs
            set -l parts (string split -m1 -- $g $line)
            if test (count $parts) -ne 2
                continue
            end
            set out "$parts[1]$dev_glyph$parts[2]"
            break
        end
        echo $out
    end
end
