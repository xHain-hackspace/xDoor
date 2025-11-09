{
  description = "xDoor Development Environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
        };

        # Define packages needed for both devShell and build
        commonPackages = with pkgs; [
          gnumake
          pkg-config
          xz
          squashfsTools
          fwup
          coreutils-prefixed
        ];

        elixirPackages = with pkgs.beam28Packages; [
          elixir
          erlang
          elixir-ls
        ];

        nixTools = with pkgs; [
          alejandra
          nixpkgs-fmt
        ];
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = commonPackages ++ nixTools ++ elixirPackages;

          shellHook = ''
            export LANG=en_US.UTF-8
            export ERL_AFLAGS="-kernel shell_history enabled"
            export HEX_HOME="$PWD/.nix-hex"
            export MIX_HOME="$PWD/.nix-mix"
            export PATH="$MIX_HOME/bin:$HEX_HOME/bin:$PATH"
          '';
        };
      }
    );
}
