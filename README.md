# Sufflain's server-side application

Licensed under the **GNU AGPLv3**. For more, read the [LICENSE](./LICENSE) file.

## Project configuration
### Firebase
1. Create a user with an Email provider.
2. Make sure that Firebase Realtime Database write permissions are allowed *only* for a user with a specific UID.
### Config file
### Docker
1. Create a directory called *private* in the project root directory.
2. Copy the program's config file from the [template](./template) directory to *private*.

### Standard
1. Copy the program's config file from the [template](./template) directory to *$HOME/.config*.

*In both cases, you need to fill the config file with your own data.*

## Build
### Docker
```bash
make docker
```

Issuing this command results in building a docker image tagged as "*sufflain-server*."

### Standard
1. Run a script for resolving dependencies. Use either a PowerShell or shell script, depending on your system:
```powershell
.\resolve-deps.ps1
```
*or*
```sh
./resolve-deps.sh
```
2. Use GNU Make to test and build the app itself:
```sh
make
```

## Commit Message Guidelines
We use [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) to format our commit
messages.

## Libraries
- [sxml](https://pkgs.racket-lang.org/package/sxml) - Copyright info is not provided.
- [html-parsing](https://pkgs.racket-lang.org/package/html-parsing) - Copyright 2003–2012, 2015, 2016, 2018 Neil Van Dyke
- [mock](https://pkgs.racket-lang.org/package/mock) - Copyright (c) 2016 Jack Firth
- [while-loop](https://pkgs.racket-lang.org/package/while-loop) - Copyright info is not provided.