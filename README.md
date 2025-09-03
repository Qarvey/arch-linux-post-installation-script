# Minimal CachyOS Post-installation Script

A script to configure a minimal CachyOS installation to my needs. It does the following:
- Mounts my storage and game partitions to my home directory
- Symlinks my user directories from my storage partition to my home directory
- Installs `yay` (and removes `paru` if installed; `paru` has always been wonky whenever I try it)
- Installs and configures [`metapac`](https://github.com/ripytide/metapac), a declarative meta package manager
- Declares and installs packages via `metapac`

The `metapac` configuration assumes a "No desktop" CachyOS installation with only the following packages selected in the Calamares installer:
- The needed CachyOS packages
- `networkmanager`
- `ufw`
- `bash-completion`
- `git`
- `micro`
- `amd-ucode`
