{ lib, ... }:
let
  inherit (lib) mkDefault;
in
{
  services.openssh = {
    enable = mkDefault false;
    settings = {
      PermitRootLogin = "prohibit-password";
      PubkeyAuthentication = true;
    };
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIID1dQp8Kiz1Q/q9kOaQ2DUyxz7LMpfw8Fcpsuu4D3IS NixOS master key"
  ];
}
