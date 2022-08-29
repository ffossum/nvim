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
    require("nvim-tree").setup {
        view = {
            adaptive_size = true
        }
    }
    map("n", "<C-n>", "<cmd> NvimTreeToggle <CR>")
    map("n", "<Esc>", "<cmd> :noh <CR>")

    use 'navarasu/onedark.nvim'
    require('onedark').setup()
    require('onedark').load()

    use {
        'romgrk/barbar.nvim',
        requires = {'kyazdani42/nvim-web-devicons'}
    }
    map("n", "<leader>x", "<cmd>BufferClose<cr>")
    map("n", "<Tab>", "<cmd>BufferNext<cr>")
    map("n", "<S-Tab>", "<cmd>BufferPrevious<cr>")

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
    require'nvim-treesitter.configs'.setup {
        highlight = {
            enable = true,
            -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
            -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
            -- Using this option may slow down your editor, and you may see some duplicate highlights.
            -- Instead of true it can also be a list of languages
            additional_vim_regex_highlighting = false
        }
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
        size = 40,
        direction = "horizontal",
        open_mapping = [[<c-@>]]
    }
    map("t", "<Esc>", "<C-\\><C-n>") -- enter normal mode

    use({
        "hrsh7th/nvim-cmp",
        requires = {{"hrsh7th/cmp-nvim-lsp"}, {"hrsh7th/cmp-vsnip"}, {"hrsh7th/vim-vsnip"}}
    })

    -- completion related settings
    -- This is similiar to what I use
    local cmp = require("cmp")
    cmp.setup({
        sources = {{
            name = "nvim_lsp"
        }, {
            name = "vsnip"
        }},
        snippet = {
            expand = function(args)
                -- Comes from vsnip
                vim.fn["vsnip#anonymous"](args.body)
            end
        },
        mapping = cmp.mapping.preset.insert({
            -- None of this made sense to me when first looking into this since there
            -- is no vim docs, but you can't have select = true here _unless_ you are
            -- also using the snippet stuff. So keep in mind that if you remove
            -- snippets you need to remove this select
            ["<CR>"] = cmp.mapping.confirm({
                select = true
            })
        })
    })

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

    -- Example if you are using cmp how to make sure the correct capabilities for snippets are set
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    metals_config.capabilities = require("cmp_nvim_lsp").update_capabilities(capabilities)

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
    map("n", "<leader>mo", '<cmd>MetalsOrganizeImports<cr>')

    -- LSP config
    -- Enable completion triggered by <c-x><c-o>
    vim.api.nvim_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

    -- Mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local bufopts = {
        noremap = true,
        silent = true
    }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
    vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, bufopts)
    vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
    vim.keymap.set('n', '<leader>wl', function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, bufopts)
    vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, bufopts)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, bufopts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
    vim.keymap.set('n', 'F', vim.lsp.buf.formatting, bufopts)
    vim.keymap.set("n", "<leader>cl", vim.lsp.codelens.run, bufopts)
    vim.keymap.set("n", "<leader>sh", vim.lsp.buf.signature_help, bufopts)

end)
