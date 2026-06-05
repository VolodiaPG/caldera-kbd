{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    zmk-nix = {
      url = "github:lilyinstarlight/zmk-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      zmk-nix,
    }:
    let
      forAllSystems = nixpkgs.lib.genAttrs (nixpkgs.lib.attrNames zmk-nix.packages);
    in
    {
      packages = forAllSystems (system: rec {
        default = firmware;

        reset = zmk-nix.legacyPackages.${system}.buildKeyboard {
          name = "settings_reset";

          src = nixpkgs.lib.sourceFilesBySuffices self [
            ".board"
            ".cmake"
            ".conf"
            ".defconfig"
            ".dts"
            ".dtsi"
            ".json"
            ".keymap"
            ".overlay"
            ".shield"
            ".yml"
            "_defconfig"
          ];

          board = "nice_nano@2.0.0//zmk";
          shield = "settings_reset";

          zephyrDepsHash = "sha256-Y+QtAFAsJ4KPFysMesykbqR6kb63uvWRmLeMC5ZkjKs=";

          meta = {
            description = "ZMK firmware for resetting keyboard";
            license = nixpkgs.lib.licenses.mit;
            platforms = nixpkgs.lib.platforms.all;
          };
        };

        firmware = zmk-nix.legacyPackages.${system}.buildSplitKeyboard {
          name = "caldera";

          src = nixpkgs.lib.sourceFilesBySuffices self [
            ".board"
            ".cmake"
            ".conf"
            ".defconfig"
            ".dts"
            ".dtsi"
            ".json"
            ".keymap"
            ".overlay"
            ".shield"
            ".yml"
            "_defconfig"
          ];

          board = "nice_nano@2.0.0//zmk";
          shield = "caldera_%PART%";

          zephyrDepsHash = "sha256-Y+QtAFAsJ4KPFysMesykbqR6kb63uvWRmLeMC5ZkjKs=";

          enableZmkStudio = true;

          meta = {
            description = "ZMK firmware for Caldera keyboard";
            license = nixpkgs.lib.licenses.mit;
            platforms = nixpkgs.lib.platforms.all;
          };
        };

        flash = zmk-nix.packages.${system}.flash.override { inherit firmware; };
        update = zmk-nix.packages.${system}.update;
      });

      devShells = forAllSystems (system: {
        default = zmk-nix.devShells.${system}.default;
      });
    };
}
