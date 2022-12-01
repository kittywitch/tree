# Tree

An import helper for Nix, taken from [kittywitch/nixfiles](https://github.com/kittywitch/nixfiles).

## Usage

```nix
  tree = inputs.tree.tree {
    inherit inputs;
    folder = ./.;
    config = {
    };
  };
```

```nix
nix-repl> :p tree
{ config = { "*" = { aliasDefault = false; evaluateDefault = false; excludes = [ ]; functor = { enable = false; excludes = [ ]; external = [ ]; }; }; "/" = { aliasDefault = false; evaluateDefault = false; excludes = [ ]; functor = { enable = false; excludes = [ ]; external = [ ]; }; }; }; impure = { default = "/nix/store/9p6bvdlib089c7zkbxzjzw3lywrqxywp-source/default.nix"; flake = "/nix/store/9p6bvdlib089c7zkbxzjzw3lywrqxywp-source/flake.nix"; }; pure = { default = "/nix/store/9p6bvdlib089c7zkbxzjzw3lywrqxywp-source/default.nix"; flake = "/nix/store/9p6bvdlib089c7zkbxzjzw3lywrqxywp-source/flake.nix"; }; }
```
