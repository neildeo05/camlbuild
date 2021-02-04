# Simple Build Tool in OCaml using Sys.Command

## Usage:
```console
$ ocamlc -o camlbuild camlbuild.ml
$ ./camlbuild help
camlbuild   build       => Runs the toolchain provided
camlbuild   help        => Runs the help commmand
$ ./camlbuild build
```
## Requirements:
- [OCaml](https://ocaml.org/docs/install.html)

## Pipeline:
1. Create a toolchain -
  make dir, build all in dir, build single file, 

## TODO:
- [X] Use Sys.argv to get command line arguments
- [X] Add 'usage' in the form of the help command
- [ ] Separate into different operating systems
- [ ] Use Unix module rather that Sys for Linux and MacOS
  - Unix module allows capturing output
- [ ] If a directory contains multiple subdirectories, build all file in the subdirectories
- [ ] Add testing functionality
  - `hello.camltest` => contains expected output
  - `build.ml`       => contains toolchain

