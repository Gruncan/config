-- Tokyo Night + transparent UI (wallpaper shows through Alacritty).
-- Deploy: mkdir -p ~/.config/nvim/lua/plugins
--         cp ~/Development/Ricing/nvim/lua/plugins/theme.lua ~/.config/nvim/lua/plugins/
-- Then: nvim  →  :Lazy sync  →  restart nvim
--
-- If the UI is still opaque, run :hi Normal and confirm guibg=NONE; see TERMINAL_OMARCHY.md.

return {
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "tokyonight-night" },
  },
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "night",
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
      ---@param hl tokyonight.Highlights
      ---@param c tokyonight.ColorScheme
      on_highlights = function(hl, _c)
        -- Belt-and-suspenders: some plugins repaint Normal after colorscheme.
        hl.Normal = { bg = "NONE" }
        hl.NormalNC = { bg = "NONE" }
        hl.SignColumn = { bg = "NONE" }
        hl.NormalFloat = { bg = "NONE" }
      end,
    },
  },
}
