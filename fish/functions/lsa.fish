function lsa --wraps='ls -a' --description 'List all files including hidden (via ls)'
    ls -a $argv
end
