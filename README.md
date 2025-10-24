# Post-installation Script

A script to configure a minimal Arch Linux installation to my needs. It does the following:
- Mounts my storage via `fstab`
- Symlinks the usual folders (Pictures, Documents, Downloads, etc.) from my storage to my home directory
- Installs `yay`
- Installs and configures [`metapac`](https://github.com/ripytide/metapac), a declarative meta package manager
- Declares and installs packages via `metapac`
