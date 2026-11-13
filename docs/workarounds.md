# Temporary workarounds

## hmts.nvim

`modules/home/neovim/plugins/treesitter.nix` disables `hmts.nvim` because of a nil crash when processing Nix files. The source references [calops/hmts.nvim#38](https://github.com/calops/hmts.nvim/pull/38); reassess the setting after an upstream fix is available in the configured dependencies.
