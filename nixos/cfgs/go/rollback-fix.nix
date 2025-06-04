# REVIEW: Slap into flake utils when mainUser is implemented
# Re-activates the user upon reaching default target - fixes potential home-manager generation rollbacks on boot

{ ... }: {
  systemd.services."home-manager-faupi--boot-activation" = {
    description = "Post-boot Home Manager activation";

    after = [ "multi-user.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      ExecStart = "/run/current-system/systemd/bin/systemctl start home-manager-faupi.service --no-block";
      TimeoutSec = "30s";
    };

    unitConfig = {
      ConditionPathExists = "/etc/profiles/per-user/faupi";
    };
  };
}
