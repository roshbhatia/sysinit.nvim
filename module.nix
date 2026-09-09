{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.sysinit-neovim;
in
{
  options.programs.sysinit-neovim = {
    enable = lib.mkEnableOption "the editor configuration";
    configPath = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };
    changesPlugin = lib.mkOption { type = lib.types.package; };
    notesPlugin = lib.mkOption { type = lib.types.package; };
  };
  config = lib.mkIf cfg.enable {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      vimAlias = true;
      viAlias = true;
      sideloadInitLua = true;
      plugins = [
        cfg.notesPlugin
        cfg.changesPlugin
      ];
    };
    xdg.configFile."nvim".source =
      if cfg.configPath == null then ./. else config.lib.file.mkOutOfStoreSymlink cfg.configPath;
    home.packages = [
      (pkgs.writeShellApplication {
        name = "rnvim";
        runtimeInputs = [
          pkgs.coreutils
          pkgs.openssh
        ];
        text = builtins.readFile ./scripts/rnvim.sh;
      })
    ];
  };
}
