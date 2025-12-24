{
  description = "Ambxst - An axtremely customizable shell by Axenide";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";

    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixgl, quickshell, ... }:
    let
      ambxstLib = import ./nix/lib.nix { inherit nixpkgs nixgl; };
    in {
      nixosModules.default = import ./nix/modules;

      packages = ambxstLib.forAllSystems (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };

          lib = nixpkgs.lib;

          Ambxst = import ./nix/packages {
            inherit pkgs lib self system nixgl quickshell ambxstLib;
          };
        in {
          default = Ambxst;
          Ambxst = Ambxst;
        }
      );

      devShells = ambxstLib.forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
          Ambxst = self.packages.${system}.default;
        in {
          default = pkgs.mkShell {
            packages = [ Ambxst ];
            shellHook = ''
              export QML2_IMPORT_PATH="${Ambxst}/lib/qt-6/qml:$QML2_IMPORT_PATH"
              export QML_IMPORT_PATH="$QML2_IMPORT_PATH"
              echo "Ambxst dev environment loaded."
            '';
          };
        }
      );
    };
}
