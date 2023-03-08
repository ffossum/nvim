local install_path = vim.fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
    packer_bootstrap = vim.fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim',
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

vim.opt_global.completeopt = {"menuone", "noinsert", "noselect"}

vim.o.guifont = "JetBrainsMonoNL Nerd Font:h13"
vim.opt.number = true
vim.opt.relativenumber = true
vim.cmd [[autocmd WinEnter * exec &number==1 ? "set relativenumber" : ""]]
vim.cmd [[autocmd WinLeave * set norelativenumber]]

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.mouse = 'a'
vim.g.mapleader = ' '
vim.opt.clipboard = "unnamedplus" -- yank/paste to system clipboard

return require('packer').startup(function(use)

    use 'wbthomason/packer.nvim'

    use {
        'kyazdani42/nvim-tree.lua',
        requires = {'kyazdani42/nvim-web-devicons'},
        tag = 'nightly',
        config = function()
            require("nvim-tree").setup {
                view = {
                    adaptive_size = true
                },
                renderer = {
                    group_empty = true,
                    symlink_destination = false
                }
            }
            local function open_nvim_tree(data)
                -- buffer is a [No Name]
                local no_name = data.file == "" and vim.bo[data.buf].buftype == ""

                -- buffer is a directory
                local directory = vim.fn.isdirectory(data.file) == 1

                if not no_name and not directory then
                  return
                end

                -- change to the directory
                if directory then
                  vim.cmd.cd(data.file)
                end

                -- open the tree
                require("nvim-tree.api").tree.open()
            end
            vim.api.nvim_create_autocmd({ "VimEnter" }, { callback = open_nvim_tree })
        end
    }
    map("n", "<leader>tf", "<cmd>NvimTreeFindFile<CR>")
    map("n", "<C-`>", "<cmd> NvimTreeFocus <CR> <cmd> NvimTreeRefresh <CR>")
    map("n", "<Esc>", "<cmd> :noh <CR>")

    use {
        'sainnhe/edge',
        config = function()
            vim.o.termguicolors = true
            vim.g.edge_style = 'aura'
            vim.g.edge_better_performance = 1
            vim.cmd('colorscheme edge')
        end
    }

    use {
        'romgrk/barbar.nvim',
        requires = {'kyazdani42/nvim-web-devicons'}
    }
    map("n", "<Tab>", "<cmd>BufferNext<cr>")
    map("n", "<S-Tab>", "<cmd>BufferPrevious<cr>")
    map("n", "<leader>bc", "<cmd>BufferClose<cr>")

    vim.opt.laststatus = 3 -- global statusline
    use {
        'nvim-lualine/lualine.nvim',
        requires = {
            'kyazdani42/nvim-web-devicons',
            opt = true
        }
    }
    function metals_status()
        return vim.g['metals_status'] or ''
    end
    require('lualine').setup {
        sections = {
            lualine_b = {'branch', 'diff', 'diagnostics', metals_status}
        }
    }

    use {
        'nvim-treesitter/nvim-treesitter',
        run = ':TSUpdate',
        config = function()

            require'nvim-treesitter.configs'.setup {
                highlight = {
                    enable = true,
                    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
                    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
                    -- Using this option may slow down your editor, and you may see some duplicate highlights.
                    -- Instead of true it can also be a list of languages
                    additional_vim_regex_highlighting = false
                },
                rainbow = {
                    enable = true,
                    -- disable = { "jsx", "cpp" }, list of languages you want to disable the plugin for
                    extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
                    max_file_lines = nil -- Do not enable for files with more than n lines, int
                    -- colors = {}, -- table of hex strings
                    -- termcolors = {} -- table of colour name strings
                }
            }
        end
    }
    use {
        'p00f/nvim-ts-rainbow',
        requires = {'nvim-treesitter/nvim-treesitter'}
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
        tag = 'v0.5',
        config = function()
            require('gitsigns').setup()
        end
    }

    use 'tpope/vim-fugitive'
    use { 'sindrets/diffview.nvim', requires = 'nvim-lua/plenary.nvim' }

    use "lukas-reineke/indent-blankline.nvim"

    use {
        'numToStr/Comment.nvim',
        config = function()
            require('Comment').setup()
        end
    }

    use {
        "kylechui/nvim-surround",
        tag = "*", -- Use for stability; omit to use `main` branch for the latest features
        config = function()
            require("nvim-surround").setup({
                -- Configuration here, or leave empty to use defaults
            })
        end
    }

    use {
        "ggandor/leap.nvim",
        requires = 'tpope/vim-repeat',
        config = function()
            require('leap').add_default_mappings()
        end
    }

    use {
        "akinsho/toggleterm.nvim",
        tag = 'v2.*',
        config = function()
            require("toggleterm").setup {
                size = 24,
                persist_size = false,
                direction = "horizontal",
                open_mapping = [[<c-\>]]
            }
        end
    }

    map("t", "<Esc>", [[<C-\><C-n>]]) -- enter normal mode
    map('t', '<C-h>', [[<Cmd>wincmd h<CR>]])
    map('t', '<C-j>', [[<Cmd>wincmd j<CR>]])
    map('t', '<C-k>', [[<Cmd>wincmd k<CR>]])
    map('t', '<C-l>', [[<Cmd>wincmd l<CR>]])
    map('t', '<C-p>', [[<Up>]])
    map('t', '<C-n>', [[<Down>]])

    map('t', [[<C-S-\>]], [[<Cmd>ToggleTermToggleAll<CR>]])
    map('n', [[<C-S-\>]], [[<Cmd>ToggleTermToggleAll<CR>]])
    map('n', '<C-h>', [[<Cmd>wincmd h<CR>]])
    map('n', '<C-j>', [[<Cmd>wincmd j<CR>]])
    map('n', '<C-k>', [[<Cmd>wincmd k<CR>]])
    map('n', '<C-l>', [[<Cmd>wincmd l<CR>]])

    use {
        "folke/trouble.nvim",
        requires = "kyazdani42/nvim-web-devicons",
        config = function()
            require("trouble").setup {
                -- your configuration comes here
                -- or leave it empty to use the default settings
                -- refer to the configuration section below
            }

            local troubleopts = {
                silent = true,
                noremap = true
            }

            vim.keymap.set("n", "<leader>xx", "<cmd>TroubleToggle<cr>", troubleopts)
            vim.keymap.set("n", "<leader>xw", "<cmd>TroubleToggle workspace_diagnostics<cr>", troubleopts)
            vim.keymap.set("n", "<leader>xd", "<cmd>TroubleToggle document_diagnostics<cr>", troubleopts)
            vim.keymap.set("n", "<leader>xl", "<cmd>TroubleToggle loclist<cr>", troubleopts)
            vim.keymap.set("n", "<leader>xq", "<cmd>TroubleToggle quickfix<cr>", troubleopts)
            vim.keymap.set("n", "gR", "<cmd>TroubleToggle lsp_references<cr>", troubleopts)
        end
    }

    use {
        "hrsh7th/nvim-cmp",
        requires = {{"hrsh7th/cmp-nvim-lsp"}, {"hrsh7th/cmp-vsnip"}, {"hrsh7th/vim-vsnip"}},
        config = function()
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
                }),
                formatting = {
                    format = function(entry, vim_item)
                        vim_item.abbr = string.sub(vim_item.abbr, 1, 40) -- set max width
                        return vim_item
                    end
                }
            })
        end
    }

    -- completion related settings
    -- This is similiar to what I use

    use({
        "scalameta/nvim-metals",
        requires = {"nvim-lua/plenary.nvim"}
    })

    local metals_config = require("metals").bare_config()

    -- *READ THIS*
    -- I *highly* recommend setting statusBarProvider to true, however if you do,
    -- you *have* to have a setting to display this in your statusline or else
    -- you'll not see any messages from metals. There is more info in the help
    -- docs about this
    metals_config.init_options.statusBarProvider = "on"

    -- Example if you are using cmp how to make sure the correct capabilities for snippets are set
    metals_config.capabilities = require("cmp_nvim_lsp").default_capabilities()

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
    vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, bufopts)
    vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
    vim.keymap.set('n', '<leader>wl', function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, bufopts)
    vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, bufopts)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, bufopts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
    vim.keymap.set('n', 'F', function () vim.lsp.buf.format { async = true } end, bufopts)
    vim.keymap.set("n", "<leader>cl", vim.lsp.codelens.run, bufopts)
    vim.keymap.set("n", "<leader>sh", vim.lsp.buf.signature_help, bufopts)

    use {
        'neovim/nvim-lspconfig',
        config = function()
            local nvim_lsp = require 'lspconfig'

            nvim_lsp.tsserver.setup {} -- typescript
            nvim_lsp.svelte.setup {}
            nvim_lsp.rust_analyzer.setup {}
        end
    }
end)

