let
  pkgs = import (fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/4d94100d6ec131014bc2a8c2f1e06ee429c96967.tar.gz";
    sha256 = "01jdag2p5znnbmy7ic14md3qw70s40n9g8irl87177f5nsyb9ydp";
  }) {};
  lib = pkgs.lib;

  inherit (lib) types;

  derivationModule = { lib, options, config, ... }: {

    _file = ./default.nix;

    options.derivation = lib.mkOption {
      type = lib.types.package;
    };

    # Makes `packages.<name>` be string-coercible using `packages.<name>.derivation(.outPath)`
    options.outPath = lib.mkOption {
      internal = true;
      default = config.derivation;
      readOnly = true;
    };

    options.builder = lib.mkOption {
      type = types.enum [ ];
    };

    # Not recommended:
    # options.buildInputs = lib.mkOption {
    #   description = ''
    #     For Python packages, see the documentation of <option>buildPythonPackage.buildInputs</option>
    #     For C packages, see ...
    #   '';
    # };

    # options.buildRustCrate = lib.mkOption {
    #   type = types.submodule buildRustCrateArguments;
    # };


    # Without freeformType the above is equivalent to this:

    # options.args.name = lib.mkOption {
    #   type = lib.types.str;
    # };
    # options.args.unpackPhase = lib.mkOption {
    #   type = lib.types.lines;
    # };
    # options.args.installPhase = lib.mkOption {
    #   type = lib.types.lines;
    # };

  };

  internalModule = { config, ... }: {
    options.packages = lib.mkOption {
      type = lib.types.attrsOf (types.submodule derivationModule);
    };

    # Makes `config.derivations.<name>` a shorthand for `config.packages.<name>.derivation`
    options.derivations = lib.mkOption {
      type = types.raw;
      internal = true;
      default = lib.mapAttrs (name: value: value.derivation) config.packages;
      readOnly = true;
    };

    options.overrides = lib.mkOption {
      # <subsystem name>.<package name>.<override name> = { ... }
      type = types.attrsOf (types.attrsOf (types.attrsOf (types.submodule {
        # options.condition.versionGreaterThan = lib.mkOption {
        #   type = types.str;
        # };
        options.attributes = lib.mkOption {
          # Hide documentation from all mkDerivationArguments, because they're already with `packages.*`
          # Doesn't work with deferredModule, probably
          # hidden = "nested";
          type = types.deferredModule; # From https://github.com/NixOS/nixpkgs/pull/163617
          description = ''
            For individual options, see `packages.<name>....`
          '';
        };
      })));
    };

    # Makes the `packages` argument in the userModule be a shorthand for config.packages
    config._module.args.packages = config.packages;

    config._module.args.pkgs = pkgs;
  };

  evaled = lib.evalModules {
    modules = [
      internalModule
      ./mkDerivation.nix
      ./user.nix
    ];
  };
in evaled.config
