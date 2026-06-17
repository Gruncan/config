function lt --wraps=eza --description 'Tree listing (Omarchy-style; requires eza)'
    if command -q eza
        eza --tree --level=2 --long --icons --git $argv
    else
        echo 'lt: install eza for tree listing (sudo apt install eza)' >&2
        return 1
    end
end
