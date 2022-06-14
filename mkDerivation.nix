{ lib, pkgs, config, ... }:
let
  inherit (lib) types;
  globalConfig = config;
  mkDerivationArguments = {

    # freeformType = lib.types.attrsOf lib.types.raw;

    options.env = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
    };
    options.name = lib.mkOption {
      type = lib.types.str;
    };
    options.unpackPhase = lib.mkOption {
      type = lib.types.lines;
    };
    options.installPhase = lib.mkOption {
      type = lib.types.lines;
    };

  };
in {
  options.packages = lib.mkOption {
    type = lib.types.attrsOf (types.submodule ({ config, name, ... }: {
      options.builder = lib.mkOption {
        # Every builder adds its own enum value, the type merges them all together
        type = types.enum [ "mkDerivation" ];
      };

      options.mkDerivation = lib.mkOption {
        type = lib.types.submodule mkDerivationArguments;
        default = {};
      };

      # mkDerivation.buildInputs = lib.mkAliasDefinitions options.buildInputs;
      config = lib.mkIf (config.builder == "mkDerivation") {
        derivation = 
          pkgs.stdenv.mkDerivation (removeAttrs config.mkDerivation [ "env" ] // config.mkDerivation.env);

        # Internal hack, please ignore
        mkDerivation = { ... }: {
          # Condition filter here
          imports = map (o: o.attributes) (lib.attrValues (globalConfig.overrides.mkDerivation.${name} or {}));
        };
      };
    }));
  };
}
