-- Alacritty / Kitty keyboard protocol + Neovim 0.11+ (TUI extended keys)
--
-- Symptom: Enter, Tab, and Backspace appear to fire twice — e.g. file tree opens
-- then closes on one Enter, or two newlines per Return in insert mode.
--
-- Cause: Neovim negotiates "report event types" with the terminal; some Alacritty
-- versions (notably around 0.13.x) also emit legacy bytes for those keys, so Nvim
-- sees two actions per physical press. Not LazyVim-specific.
--
-- Preferred fix: upgrade Alacritty to a build that includes the keyboard-protocol fix
-- (see https://github.com/alacritty/alacritty/issues/8385).
--
-- Fallback: after startup, push a narrower progressive-enhancement mode and pop it
-- on exit so the shell is not left in a strange state. Same idea as:
-- https://github.com/neovim/neovim/issues/32143

vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    io.stdout:write("\27[>1u")
    io.stdout:flush()
  end,
})

vim.api.nvim_create_autocmd("VimLeavePre", {
  once = true,
  callback = function()
    io.stdout:write("\27[<1u")
    io.stdout:flush()
  end,
})
