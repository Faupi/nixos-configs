{ config, ... }: {
  sops.secrets.notify-email-token = {
    sopsFile = ./secrets.yaml;
    mode = "0440";
  };

  programs.msmtp = {
    enable = true;
    accounts = {
      notify-email = {
        auth = true;
        host = "smtp.gmail.com";
        port = 587;
        passwordeval = "cat ${config.sops.secrets.notify-email-token.path}";
        user = "matej.sp583";
      };
    };
  };
  services.notify-email = {
    enable = true;
    recipient = "matej.sp583+homeserver@gmail.com";
    services = [ "nixos-upgrade" "nixos-store-optimize" ];
  };
}
