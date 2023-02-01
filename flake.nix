{
  description = "A telegram bot to record someone's message by forwarding";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    let
      bot = pkgs: with pkgs; {
        pname = "saysthbot-reborn";
        version = "0.1.0";
        src = ./.;
        # RUSTFLAGS = "-C target-feature=-crt-static";
        cargoLock = { lockFile = ./Cargo.lock; };
        nativeBuildInputs = [ pkg-config ];
        buildInputs = [ openssl ];
      };
      packages = pkgs: rec {
        saysthbot-reborn =
          pkgs.rustPlatform.buildRustPackage (bot pkgs);
        saysthbot-reborn-docker =
          pkgs.dockerTools.buildImage {
            name = "saysthbot-reborn";
            tag = "latest";
            config.Entrypoint = "${saysthbot-reborn}/bin/saysthbot-reborn";
          };
      };
    in
    flake-utils.lib.eachDefaultSystem (system: {
      packages = {
        pkgsCross.aarch64-multiplatform = packages nixpkgs.legacyPackages."${system}".pkgsCross.aarch64-multiplatform;
      } // packages nixpkgs.legacyPackages."${system}";
      defaultPackage = self.packages."${system}".saysthbot-reborn;
    });
}
