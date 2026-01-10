# NixOS module for Ambxst
{ config, lib, pkgs, ... }:

let
  cfg = config.programs.ambxst;
in {
  options.programs.ambxst = {
    enable = lib.mkEnableOption "Ambxst shell";

    package = lib.mkOption {
      type = lib.types.package;
      description = "The Ambxst package to use";
    };

    fonts.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to install Ambxst fonts (including Phosphor Icons)";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    # Register fonts with fontconfig (NixOS handles this via fonts.packages)
    fonts.packages = lib.mkIf cfg.fonts.enable [
      (pkgs.callPackage ../packages/phosphor-icons.nix { })
    ];

    # Enable recommended services for full functionality
    services.power-profiles-daemon.enable = lib.mkDefault true;
    networking.networkmanager.enable = lib.mkDefault true;
  };
}
