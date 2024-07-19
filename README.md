## Installation

1. Run the [Determinate systems](https://determinate.systems/posts/determinate-nix-installer/) installer:

```text
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

2. Add the darwin repo as a channel

```text
nix-channel --add https://github.com/LnL7/nix-darwin/archive/master.tar.gz darwin
nix-channel --update
```

3. Install [nix-darwin](https://github.com/LnL7/nix-darwin):

```text
nix-build https://github.com/LnL7/nix-darwin/archive/master.tar.gz -A installer
./result/bin/darwin-installer
```

4. Clone this repository

```text
git clone git@github.com:benbouillet/nix-config.git ~/nix-config
```

5. Check the configuration

```text
darwin-rebuild check --flake .
````

6. Deploy the configuration

```text
darwin-rebuild switch --flake .
```

## Roadmap

---

- [x] Multi-computer application listing
- [ ] Switch from Alacritty to Kitty
- [ ] Finish NixVim configuration
- [ ] move user & email configuration into hosts
- [ ] Implement mrjones2014/smart-splits.nvim
- [ ] Implement `yabai`
- [ ] Implement `skhd`
- [ ] Implement `logseq` ?
- [x] Additional computer-specific installations

## Resources

---

* [github Gako358/neovim - My personal neovim config for Nix](https://github.com/Gako358/neovim?tab=readme-ov-file)
* [github Misterio77/nix-starter-configs - good inspiration for hierarchy best practices](https://github.com/Misterio77/nix-starter-configs)
