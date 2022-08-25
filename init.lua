local fn = vim.fn
local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
    packer_bootstrap = fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim',
                                  install_path})
    vim.cmd "packadd packer.nvim"
end

-- Functional wrapper for mapping custom keybindings
function map(mode, lhs, rhs, opts)
    local options = {
        noremap = true
    }
    if opts then
        options = vim.tbl_extend("force", options, opts)
    end
    vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = 'a'
vim.g.mapleader = ' '

return require('packer').startup(function(use)

    use 'wbthomason/packer.nvim'

    use {
        'kyazdani42/nvim-tree.lua',
        requires = {'kyazdani42/nvim-web-devicons'},
        tag = 'nightly'
    }
    require("nvim-tree").setup()
    map("n", "<C-n>", "<cmd> NvimTreeToggle <CR>")

    use 'navarasu/onedark.nvim'
    require('onedark').setup {
        style = "cool"
    }
    require('onedark').load()

    use {
        'romgrk/barbar.nvim',
        requires = {'kyazdani42/nvim-web-devicons'}
    }

    use {
        'nvim-lualine/lualine.nvim',
        requires = {
            'kyazdani42/nvim-web-devicons',
            opt = true
        }
    }
    require('lualine').setup()
    vim.opt.laststatus = 3 -- global statusline

    use {
        'nvim-treesitter/nvim-treesitter',
        run = ':TSUpdate'
    }

    use {
        'nvim-telescope/telescope-fzf-native.nvim',
        run = 'make'
    }
    use {
        'nvim-telescope/telescope.nvim',
        branch = '0.1.x',
        requires = {'nvim-lua/plenary.nvim'}
    }
    map("n", "<leader>ff", "<cmd>Telescope find_files<cr>")
    map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>")
    map("n", "<leader>fb", "<cmd>Telescope buffers<cr>")
    map("n", "<leader>fh", "<cmd>Telescope help_tags<cr>")

    use {
        'lewis6991/gitsigns.nvim',
        tag = 'release'
    }
    require('gitsigns').setup()

    use {
        "akinsho/toggleterm.nvim",
        tag = 'v2.*'
    }
    require("toggleterm").setup {
        direction = "float"
    }
    map("n", "<leader>t", "<cmd>ToggleTerm<cr>")
    map("t", "<Esc>", "<cmd>ToggleTerm<cr>")

end)
