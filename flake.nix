{
  description = "Tree, an import helper for Nix";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };
  outputs = {nixpkgs, ...}: {
    tree = import ./tree.nix {inherit (nixpkgs) lib;};
  };
}
