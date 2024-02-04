# Module extending file generators to include a `mutable` option
# https://gist.github.com/piousdeer/b29c272eaeba398b864da6abf6cb5daa

{ ... }: {
  imports = [
    (builtins.fetchurl {
      url = "https://gist.githubusercontent.com/piousdeer/b29c272eaeba398b864da6abf6cb5daa/raw/41e569ba110eb6ebbb463a6b1f5d9fe4f9e82375/mutability.nix";
      sha256 = "4b5ca670c1ac865927e98ac5bf5c131eca46cc20abf0bd0612db955bfc979de8";
    })
  ];
}
