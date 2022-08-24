local fn = vim.fn
local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
    packer_bootstrap = fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim',
                                  install_path})
    vim.cmd "packadd packer.nvim"
end

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = 'a'

return require('packer').startup(function(use)

    use 'wbthomason/packer.nvim'

    use {
        'kyazdani42/nvim-tree.lua',
        requires = {'kyazdani42/nvim-web-devicons'},
        tag = 'nightly'
    }

    use 'navarasu/onedark.nvim'

    use {
        'romgrk/barbar.nvim',
        requires = {'kyazdani42/nvim-web-devicons'}
    }

    use {
        'feline-nvim/feline.nvim',
        requires = {'kyazdani42/nvim-web-devicons', 'lewis6991/gitsigns.nvim'}
    }

    if packer_bootstrap then
        require('packer').sync()
    end

    require("nvim-tree").setup()

    require('onedark').setup {
        style = "cool"
    }
    require('onedark').load()

    require('feline').setup()
end)
