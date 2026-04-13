{ cfg, config, ... }:
{
  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        workgroup = "WORKGROUP";
        "server string" = "lynx";
        security = "user";
        "map to guest" = "never"; # Require authentication for all shares
        "server min protocol" = "SMB2"; # Drop SMB1 for stability/security
        "ea support" = "yes"; # Keep extended attributes for ACLs
        "vfs objects" = "acl_xattr"; # Store ACLs in xattrs
        "inherit acls" = "yes"; # Preserve ACLs on created files/dirs
        "store dos attributes" = "yes"; # Preserve Windows file attributes
        "strict sync" = "yes"; # Honor client sync requests to avoid stale data
        "sync always" = "yes"; # Synchronous writes for data integrity
      };

      gamestream = {
        path = config.users.users.${cfg.user}.home;
        browseable = "yes";
        "read only" = "no";
        "valid users" = cfg.user;
        "force user" = cfg.user;
        "force group" = cfg.user;
        "create mask" = "0640";
        "directory mask" = "0750";
        "follow symlinks" = "yes"; # Resolve symlinks on the server
        "wide links" = "no"; # Disallow symlinks that escape the share
      };
    };
  };
}
