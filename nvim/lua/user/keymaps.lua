local opts = { noremap = true, silent = true }

local term_opts = { silent = true }

-- Shorten function name
-- Info on keymap apis https://www.reddit.com/r/neovim/comments/uuh8xw/noob_vimkeymapset_vs_vimapinvim_set_keymap_key/
local keymap = vim.api.nvim_set_keymap

--Remap space as leader key
keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Modes
--   normal_mode = "n",
--   insert_mode = "i",
--   visual_mode = "v",
--   visual_block_mode = "x",
--   term_mode = "t",
--   command_mode = "c",

-- Normal --
-- Better window navigation
keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

-- Resize with arrows
keymap("n", "<C-Up>", ":resize +2<CR>", opts)
keymap("n", "<C-Down>", ":resize -2<CR>", opts)
keymap("n", "<C-Left>", ":vertical resize -2<CR>", opts)
keymap("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-- Navigate buffers
keymap("n", "<S-l>", ":w<CR>:bnext<CR>", opts)
keymap("n", "<S-h>", ":w<CR>:bprevious<CR>", opts)
-- Close Buffer
keymap("n", "<Leader>c", ":w<CR>:bw<CR>", opts)

-- Copy & Paste to/from system clipboard
keymap("n", "<Leader>y", "\"+y", opts)
keymap("n", "<Leader>Y", "\"+Y", opts)
keymap("n", "<Leader>p", "\"+p", opts)
keymap("n", "<Leader>P", "\"+P", opts)

-- Terminal Shortcut
keymap("n", "<Leader>t", ":terminal<CR>", opts)

-- Fugitive Shortcut
keymap("n", "<Leader>G", ":G<CR>", opts)

--

-- Insert --

-- Visual --
-- Stay in indent mode
-- keymap("v", "<", "<gv", opts)
-- keymap("v", ">", ">gv", opts)

-- Copy to/from system clipboard
keymap("v", "<Leader>y", "\"+y", opts)
keymap("v", "<Leader>Y", "\"+Y", opts)

-- Move text up and down
keymap("v", "<A-j>", ":m .+1<CR>==", opts)
keymap("v", "<A-k>", ":m .-2<CR>==", opts)
keymap("v", "p", '"_dP', opts)

-- Visual Block --
-- Move text up and down
keymap("x", "J", ":move '>+1<CR>gv-gv", opts)
keymap("x", "K", ":move '<-2<CR>gv-gv", opts)
keymap("x", "<A-j>", ":move '>+1<CR>gv-gv", opts)
keymap("x", "<A-k>", ":move '<-2<CR>gv-gv", opts)

-- Terminal --
-- Better terminal navigation
keymap("t", "<C-h>", "<C-\\><C-N><C-w>h", term_opts)
keymap("t", "<C-j>", "<C-\\><C-N><C-w>j", term_opts)
keymap("t", "<C-k>", "<C-\\><C-N><C-w>k", term_opts)
keymap("t", "<C-l>", "<C-\\><C-N><C-w>l", term_opts)

-- Telescope
keymap("n", "<C-p>", "<cmd>Telescope find_files<cr>", opts)
keymap("n", "<leader>g", "<cmd>Telescope live_grep<cr>", opts)

-- nvim-tree
keymap("n", "<Leader>f", ":NvimTreeToggle<cr>", opts)
