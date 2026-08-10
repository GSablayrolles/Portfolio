{
  description = "My Portfolio";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,

    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        nodejs = pkgs.nodejs;
        pnpm = pkgs.pnpm;
        fetchPnpmDeps = pkgs.fetchPnpmDeps;
        pnpmConfigHook = pkgs.pnpmConfigHook;
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            nodejs
            pnpm
            vercel-pkg
          ];

          shellHook = ''
            export PATH="$PWD/node_modules/.bin:$PATH"
          '';
        };

        packages.default = pkgs.stdenv.mkDerivation (finalAttrs: {
          pname = "astro-site";
          version = "0.0.1";
          src = ./.;

          nativeBuildInputs = [
            nodejs
            pnpmConfigHook
          ];

          pnpmDeps = fetchPnpmDeps {
            inherit (finalAttrs) pname version src;
            fetcherVersion = 4;
            hash = "sha256-29I1peID8iNwSLiedpOLEXltGrC+cjzHntNuZzSLfdA=";
          };

          buildPhase = ''
            pnpm run build
          '';

          installPhase = ''
            cp -r dist $out
          '';
        });

        formatter = pkgs.nixpkgs-fmt;
      }
    );
}
