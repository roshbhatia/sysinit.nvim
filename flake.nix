{
  description = "Neovim configuration and review integrations";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.changes.url = "github:roshbhatia/changes";
  inputs.changes.inputs.nixpkgs.follows = "nixpkgs";
  inputs.agent-notes.url = "github:roshbhatia/agent-notes";
  inputs.agent-notes.inputs.nixpkgs.follows = "nixpkgs";
  outputs =
    {
      self,
      nixpkgs,
      agent-notes,
      changes,
    }:
    let
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];
      each = nixpkgs.lib.genAttrs systems;
    in
    {
      lib.configSource = self.outPath;
      homeManagerModules.default = { pkgs, ... }: {
        imports = [ ./module.nix ];
        home.packages = [
          agent-notes.packages.${pkgs.stdenv.hostPlatform.system}.default
          changes.packages.${pkgs.stdenv.hostPlatform.system}.default
        ];
        programs.sysinit-neovim.changesPlugin =
          changes.packages.${pkgs.stdenv.hostPlatform.system}.neovim-plugin;
        programs.sysinit-neovim.notesPlugin =
          agent-notes.packages.${pkgs.stdenv.hostPlatform.system}.neovim-plugin;
      };
      packages = each (system: {
        default =
          nixpkgs.legacyPackages.${system}.runCommand "sysinit-nvim-config" { }
            "mkdir -p $out; cp -r ${self}/. $out/";
      });
      devShells = each (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            packages = [
              pkgs.neovim
              pkgs.stylua
              pkgs.nixfmt
              pkgs.git
              pkgs.vhs
            ];
          };
        }
      );
      formatter = each (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        pkgs.writeShellApplication {
          name = "format-nix";
          runtimeInputs = [
            pkgs.git
            pkgs.nixfmt
            pkgs.findutils
          ];
          text = ''git ls-files -z -- '*.nix' | xargs -0 -r nixfmt "$@"'';
        }
      );
      checks = each (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          editor =
            pkgs.runCommand "nvim-config-tests"
              {
                nativeBuildInputs = [
                  pkgs.neovim
                  pkgs.git
                ];
              }
              ''
                export HOME="$TMPDIR/home"; mkdir -p "$HOME"
                export SYSINIT_NVIM_CONFIG=${self}
                export SYSINIT_NVIM_DIFFVIEW=${pkgs.vimPlugins.diffview-nvim}
                export SYSINIT_NOTES_PLUGIN=${agent-notes.packages.${system}.neovim-plugin}
                nvim --headless --clean -u NONE --cmd 'set runtimepath^=${pkgs.vimPlugins.plenary-nvim}' -c 'runtime plugin/plenary.vim' -c "PlenaryBustedDirectory ${./checks/neovim} { minimal_init = '${./checks/neovim.lua}', sequential = true }"
                touch $out
              '';
        }
      );
    };
}
