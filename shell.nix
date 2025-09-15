{ nixpkgs ? import <nixpkgs> {} }:

nixpkgs.mkShell {
  buildInputs = with nixpkgs; [
    pandoc
    miniserve
    websocketd
    inotify-tools
    texliveSmall
    texlivePackages.beamer
  ];
}
