# Evalua

A tiny neovim plugin for evaluating Lua code on-the-fly.
Inspired by the on-the-fly elisp evaluation functionality in emacs.

## Demo

Viewable on Asciinema
[![asciicast](https://asciinema.org/a/596274.svg)](https://asciinema.org/a/596274)

## Installation

### Lazy.nvim
```lua
return {
	'KaitlynEthylia/Evalua',
	dependencies = 'nvim-treesitter/nvim-treesitter',
	init = function() require('Evalua') end,
}
```

### Packer
```lua
use {
	'KaitlynEthylia/Evalua',
	requires = {'nvim-treesitter/nvim-treesitter'},
	config = function() require('Evalua') end,
}
```

### Plug
```lua
Plug 'nvim-treesitter/nvim-treesitter'
Plug 'KaitlynEthylia/Evalua'
```

## Usage

This plugin has one single command: `:Evalua`. This will evaluate the
lua code underneath the cursor, very similar to the C-x C-e function
in emacs. Additionally, the argument `silent` may be passed to prevent
Evalua from printing the expression it evaluates and its result.
