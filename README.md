> **Warning**
> This plugin was created in just a couple hours and does NOT work
> all the time. I do intend to try and fix some of the issues with it
> but please bear with me. Any contributions to help with this are
> very much appreciated. -Kaitlyn

# Evalua

A tiny neovim plugin for evaluating Lua code on-the-fly.
Inspired by the on-the-fly elisp evaluation functionality in emacs.

## Demo

Viewable on Asciinema
[![asciicast](https://asciinema.org/a/596185.svg)](https://asciinema.org/a/596185)

## Installation

### Lazy.nvim
```
{
	'KaitlynEthylia/Evalua',
	dependencies = 'nvim-treesitter/nvim-treesitter',
	init = function() require('treepin') end,
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
