# Post-installation Script

A script to configure a minimal Arch Linux installation to my needs. It does the following:
- Mounts my storage and game partitions to my home directory
- Symlinks my user directories from my storage partition to my home directory
- Installs `yay`
- Installs and configures [`metapac`](https://github.com/ripytide/metapac), a declarative meta package manager
- Declares and installs packages via `metapac`
