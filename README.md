# Arch Linux Post-installation Script
## ... or Alpis

A script to configure a minimal Arch Linux installation to my needs. It does the following:
- Mounts my storage via `fstab`
- Symlinks my folders (Pictures, Documents, Downloads, etc.) from my storage drives to my home directory
- Installs `paru`
- Installs and configures [`metapac`](https://github.com/ripytide/metapac), a declarative meta package manager
- Declares and installs packages via `metapac`
- Etc.
