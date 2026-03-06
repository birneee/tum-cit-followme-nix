{
  description = "TUM CIT FollowMe printer driver and NixOS module";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };
  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-parts,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      perSystem =
        {
          pkgs,
          ...
        }:
        {
          packages.default = pkgs.stdenv.mkDerivation {
            pname = "tum-cit-followme";
            version = "1.0.0";
            src = pkgs.fetchurl {
              url = "https://wiki.ito.cit.tum.de/bin/download/Informatik/Benutzerwiki/XeroxDrucker/WebHome/x2UNIV-C8030.ppd";
              hash = "sha256-If8PWiGxn7r9MIG/hJzTjmcBBwRApuseN7FT7+Eybl0=";
            };
            dontUnpack = true;
            installPhase = ''
              mkdir -p $out/share/cups/model
              cp $src $out/share/cups/model/x2UNIV-C8030.ppd
            '';
          };
        };
      flake.nixosModules.default =
        {
          config,
          lib,
          pkgs,
          ...
        }:
        {
          options.services.tumCitFollowmePrinting = {
            enable = lib.mkEnableOption "TUM CIT FollowMe printer";
            username = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Your TUM CIT username for the printer queue. This will be set system-wide as CUPS_USER.";
            };
            printerName = lib.mkOption {
              type = lib.types.str;
              default = "TUM_followme";
              description = "Name of the printer queue. May contain any printable characters except \"/\", \"#\", and space.";
            };
          };
          config =
            let
              cfg = config.services.tumCitFollowmePrinting;
            in
            lib.mkIf cfg.enable {
              services.printing.drivers = [
                self.packages.${pkgs.stdenv.hostPlatform.system}.default
              ];
              hardware.printers.ensurePrinters = [
                {
                  name = cfg.printerName;
                  location = "TUM-FMI";
                  deviceUri = "ipp://qpilot.rbg.tum.de/followme";
                  ppdOptions = {
                    PageSize = "A4";
                  };
                  model = "x2UNIV-C8030.ppd";
                }
              ];
              environment.variables = lib.mkIf (cfg.username != null) {
                CUPS_USER = cfg.username; # unfortunatelly, this is system-wide and not only for this printer, if you know a better way let me know
              };

              warnings =
                lib.optional (!config.services.printing.enable)
                  "services.tumCitFollowmePrinting is enabled but services.printing.enable is false. Please enable CUPS printing.";

            };
        };
    };
}
