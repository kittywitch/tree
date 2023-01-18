{lib,std}: {
  config,
  folder,
  ...
} @ args: let
  inherit (std) list string tuple types;
  function = std.function // {
    pipe = list.foldl' (function.flip function.compose) function.id;
  };
  set = std.set // {
    remap = f: s: set.fromList (list.map f (set.toList s));
    recursiveMap = f: s: let
      recurse = str: s: let
        g = str1: str2:
          if types.attrs.check str2
          then f (str ++ [str1]) (recurse (str ++ [str1]) str2)
          else f (str ++ [str1]) str2;
      in
        set.map g s;
    in
      f [] (recurse [] s);
  };
  inherit (lib.modules) evalModules;
  pureTreeGrab = {
    base,
    path,
  }: let
    realPath = builtins.toString path;
    dirContents = builtins.readDir path;
    isDirectory = entry: dirContents."${entry}" == "directory";
    isHidden = string.hasPrefix ".";
    isDir = entry: _: (isDirectory entry) && !(isHidden entry);
    directories = set.filter isDir dirContents;
    isNixFile = entry: _: let
      result = builtins.match "(.*)\\.nix" entry;
    in
      result != null && builtins.length result > 0;
    nixFiles = set.filter isNixFile dirContents;
    getPath = entry: "${realPath}/${entry}";
    getPaths = set.remap (
      { _0, _1 }:
        tuple.tuple2 (string.removeSuffix ".nix" _0) (getPath _0)
    );
    nixFilePaths = getPaths nixFiles;
    dirPaths = getPaths directories;
    recursedPaths = set.map (_: fullPath:
      pureTreeGrab {
        inherit base;
        path = fullPath;
      })
    dirPaths;
    contents = recursedPaths // nixFilePaths;
  in
    contents;
  configTreeStruct = {config, ...}: let
    inherit (lib.options) mkOption;
    inherit (lib.types) listOf attrsOf submodule bool str unspecified;
  in {
    options.treeConfig = mkOption {
      type = attrsOf (submodule ({options, ...}: {
        options = {
          evaluate = mkOption {
            type = bool;
            description = "Replace the contents of this branch or leaf with those provided by the evaluation of a file";
            default = false;
          };
          evaluateDefault = mkOption {
            type = bool;
            description = "Replace the contents of this branch or leaf with those provided by the evaluation of default.nix.";
            default = false;
          };
          aliasDefault = mkOption {
            type = bool;
            description = "Replace the contents of this branch or leaf with the default.nix.";
            default = false;
          };
          excludes = mkOption {
            type = listOf str;
            description = "Exclude files or folders from the recurser.";
            default = [];
          };
          functor = {
            enable = mkOption {
              type = bool;
              description = "Provide a functor for the path provided";
              default = false;
            };
            external = mkOption {
              type = listOf unspecified;
              description = "Add external imports into the functor.";
              default = [];
            };
            excludes = mkOption {
              type = listOf str;
              description = "Exclude files or folders from the functor.";
              default = [];
            };
          };
        };
      }));
    };
    config.treeConfig = {
      "*" = {};
      "/" = {};
    };
  };
  configTree.treeConfig = config;
  configTreeModule =
    (evalModules {
      modules = [
        configTreeStruct
        configTree
      ];
    })
    .config
    .treeConfig;
  getPathString = string.concatSep "/";
  getConfig = path: default: configTreeModule.${getPathString path} or default;
  revtail = path: list.slice 0 (builtins.length path - 1) path;
  getConfigRecursive = path: let
    parentPath = revtail path;
  in
    getConfig (path ++ list.singleton "*") (getConfigRecursive parentPath);
  processLeaves = tree: _:
    set.recursiveMap (path: value: let
      leafConfig =
        if path == []
        then configTreeModule."/"
        else getConfig path (getConfigRecursive (revtail path));
      processConfig = _: value: let
        processFunctor = prev:
          prev
          // {
            __functor = _: {...}: {
              imports = set.values (set.without leafConfig.functor.excludes prev) ++ leafConfig.functor.external;
            };
          };
        processAliasDefault = prev: prev.default;
        processEvaluation = prev: import prev args;
        processDefault = prev:
          import prev.default (args
            // {
              inherit lib;
              tree = {
                prev = set.without (list.singleton "default") prev;
                pure = pureTree;
                impure = impureTree;
              };
            });
        processExcludes = prev: set.without leafConfig.excludes prev;
        processes = list.optionals (types.attrs.check value) (
          list.optional (leafConfig.excludes != []) processExcludes
          ++ list.optional leafConfig.evaluateDefault processDefault
          ++ list.optional leafConfig.aliasDefault processAliasDefault
          ++ list.optional leafConfig.functor.enable processFunctor
        ) ++ list.optionals (!types.attrs.check value) (
          list.optional leafConfig.evaluate processEvaluation
        );
      in
        function.pipe processes value;
    in
      processConfig path value)
    tree;
  pureTree = pureTreeGrab {
    base = folder;
    path = folder;
  };
  impureTree = processLeaves pureTree configTreeModule;
in {
  config = configTreeModule;
  pure = pureTree;
  impure = impureTree;
}
