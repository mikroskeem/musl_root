# musl_root

Yet another Musl-based lightweight container or distribution bootstrapper

## Features

Lightweight packages:
- mksh
- libressl

# License
Build scripts are MIT  
Patches have their license note in commit message (if not present, then given
patch is MIT)

## TODO
- [ ] `chroot` mounts and error handling
- [x] Script colors
- [x] Build own musl compiler toolchain
- [ ] Stage 2
- [ ] Minimize dependencies required to build musl_root
- [ ] Make possible to build musl_root from musl_root
- [ ] Package manager (explore available options)
- [x] Decide build scripts license

## Special thanks
- [@artizirk](https://keybase.io/artizirk) - for letting me to borrow his powerful AMD PC to finally build a toolchain
