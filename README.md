# TUM CIT FollowMe Printer Setup for NixOS

Official documentation: https://wiki.ito.cit.tum.de/bin/view/CIT/ITO/Docs/Guides/Helpdesk/Followmeeinrichten

## Usage

Add to your flake inputs and modules:
```nix
{
  inputs = {
    tum-cit-followme = {
      url = "path:flakes/tum-cit-followme";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { nixpkgs, tum-cit-followme, ... }: {
    nixosConfigurations.yourHostname = nixpkgs.lib.nixosSystem {
      modules = [
        tum-cit-followme.nixosModules.default
        {
          services.printing.enable = true;
          services.tumCitFollowmePrinting = {
            enable = true;
            username = "yourCitUser";
          };
        }
      ];
    };
  };
}
```

## Configuration Options

- `enable` - Enable the TUM FollowMe printer (default: false)
- `username` - Your TUM CIT username (optional, sets CUPS_USER system-wide)
- `printerName` - Name of the printer queue (optional, default: "TUM_followme")
