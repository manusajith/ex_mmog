{ pkgs ? import <nixpkgs> {} }:

with pkgs;

let
  inherit (lib) optional optionals;

  elixir = beam.packages.erlangR22.elixir_1_10;
  nodejs = nodejs-12_x;
in

mkShell {
  buildInputs = [ elixir nodejs git ]
    ++ optional stdenv.isLinux inotify-tools
    ++ optionals stdenv.isDarwin (with darwin.apple_sdk.frameworks; [
      CoreFoundation
      CoreServices
    ]);

    shellHook = ''
      alias mdg="mix deps.get"
      alias mps="mix phx.server"
      alias test="mix test"
    '';
}