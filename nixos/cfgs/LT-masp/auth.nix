{ lib, pkgs, ... }:
{
  services.fprintd.enable = true;

  security.pam.services = {
    # SDDM login should require both factors in sequence:
    # 1) regular password auth via the standard login PAM stack
    # 2) a successful fingerprint scan
    #
    # Keep explicit KWallet PAM hooks because we override the full SDDM PAM file.
    sddm = {
      fprintAuth = true;
      kwallet.enable = true;
      text = lib.mkForce ''
        auth      optional                    ${pkgs.kdePackages.kwallet-pam}/lib/security/pam_kwallet5.so
        auth      include                     login
        auth      required                    ${pkgs.fprintd}/lib/security/pam_fprintd.so

        account   include                     login
        password  include                     login

        session   include                     login
        session   optional                    ${pkgs.kdePackages.kwallet-pam}/lib/security/pam_kwallet5.so auto_start
      '';
    };

    # In-session authentication keeps password fallback while allowing fingerprint.
    kscreenlocker.fprintAuth = true;
    login.fprintAuth = true;
    polkit-1.fprintAuth = true;
    sudo.fprintAuth = true;
  };
}
