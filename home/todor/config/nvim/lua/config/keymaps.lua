-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
local map = vim.keymap.set

-- for duplicate plugin
map("n", "<C-S-A-Up>", "<CMD>LineDuplicate -1<CR>", { desc = "Duplicate up" })
map("n", "<C-S-A-Down>", "<CMD>LineDuplicate +1<CR>", { desc = "Duplicate down" })
map("v", "<C-S-A-Up>", "<CMD>VisualDuplicate -1<CR>", { desc = "Duplicate up" })
map("v", "<C-S-A-Down>", "<CMD>VisualDuplicate +1<CR>", { desc = "Duplicate down" })
