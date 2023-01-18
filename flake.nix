{
  description = "Tree, an import helper for Nix";
  inputs = {
    nixpkgs.url = "github:nix-community/nixpkgs.lib";
    std.url = "github:chessai/nix-std";
  };
  outputs = {nixpkgs, std, ...}: {
    tree = import ./tree.nix {inherit (nixpkgs) lib; std = std.lib;};
  };
}
