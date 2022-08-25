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

    use({
        "scalameta/nvim-metals",
        requires = {"nvim-lua/plenary.nvim"}
    })
    vim.opt_global.shortmess:remove("F"):append("c")
    local metals_config = require("metals").bare_config()

    -- *READ THIS*
    -- I *highly* recommend setting statusBarProvider to true, however if you do,
    -- you *have* to have a setting to display this in your statusline or else
    -- you'll not see any messages from metals. There is more info in the help
    -- docs about this
    -- metals_config.init_options.statusBarProvider = "on"

    local nvim_metals_group = vim.api.nvim_create_augroup("nvim-metals", {
        clear = true
    })
    vim.api.nvim_create_autocmd("FileType", {
        -- NOTE: You may or may not want java included here. You will need it if you
        -- want basic Java support but it may also conflict if you are using
        -- something like nvim-jdtls which also works on a java filetype autocmd.
        pattern = {"scala", "sbt", "java"},
        callback = function()
            require("metals").initialize_or_attach(metals_config)
        end,
        group = nvim_metals_group
    })
    map("n", "<leader>mc", '<cmd>lua require"telescope".extensions.metals.commands()<cr>')
    map('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>')

end)
