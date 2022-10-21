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
    in
    flake-utils.lib.eachDefaultSystem (system: {
      packages.saysthbot-reborn =
        with nixpkgs.legacyPackages."${system}";
        rustPlatform.buildRustPackage (bot pkgs);
      packages.pkgsCross.aarch64-multiplatform.saysthbot-reborn =
        with nixpkgs.legacyPackages."${system}".pkgsCross.aarch64-multiplatform;
        rustPlatform.buildRustPackage (bot pkgs);
      defaultPackage = self.packages."${system}".saysthbot-reborn;
    });
}
