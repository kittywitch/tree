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
    flake-compat = {
      url = "https://flakehub.com/f/edolstra/flake-compat/1.tar.gz";
      type = "tarball";
      flake = false;
    };
  };
  outputs = {nixpkgs, std, ...}: {
    std = std;
    tree = import ./tree.nix {inherit (nixpkgs) lib; std = std.lib.Std.compat // { inherit (std.lib.Std.std) tuple; };};
  };
}
