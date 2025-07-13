{
  description = "Tree, an import helper for Nix";
  inputs = {
    nixpkgs.url = "github:nix-community/nixpkgs.lib";
    nix-std.url = "github:chessai/nix-std";
    std = {
      url = "github:flakelib/std";
      inputs = {
        nix-std.follows = "nix-std";
      };
    };
  };
  outputs = {nixpkgs, std, ...}: {
    tree = import ./tree.nix {inherit (nixpkgs) lib; std = std.lib.Std.compat;};
  };
}
