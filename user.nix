{ lib, config, packages, ... }: {

  # Overrides can apply to multiple packages
  # Principle: Don't have multiple freely choosable attributes in a row,
  # maybe watch out for future compatibility, ask @infinisil
  overrides.mkDerivation.hello = {
    "fix-with-2.0" = {

      # condition = ...
      attributes = {
        installPhase = lib.mkAfter ''
          echo bar >> "$out"
        '';
      };

      # But this is also possible:
      # _condition = ...
      # buildInputs = ...

    };
  };

  packages.hello = {
    builder = "mkDerivation";
    mkDerivation = {
      name = "hello";
      unpackPhase = ":";
      installPhase = ''
        cat ${config.packages.foo.derivation} > "$out"
        cat ${packages.foo.derivation} > "$out"
        cat ${config.packages.foo} > "$out"
        cat ${packages.foo} > "$out"
        cat ${config.derivations.foo} > "$out"
      '';
    };
  };

  packages.foo = {
    builder = "mkDerivation";
    mkDerivation = {
      name = "hello";
      unpackPhase = ":";
      installPhase = ''
        echo foo > "$out"
      '';
    };
  };

  # Or
  # packages.mkDerivation.hello = {
  #   name = "hello";
  #   ...
  # }

  # packages.hello = {
  #   builder = "buildRustCrate";
  #   buildRustCrate = {
  #     name = "hello";
  #     rustCrateDependencies = [
  #     ];
  #   };
  # };

  # packages.requests = {
  #   builder = "buildPythonPackage";
  #   buildPythonPackage = {
  #     name = "requests";
  #     propagatedBuildInputs = [
  #       pkgs.pythonPackages.requests
  #     ];
  #   };
  # };
}
