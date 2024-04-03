{ lib, ... }:
with lib;
{
  nix.gc.automatic = mkForce true;

  users.groups.nixremote = { };
  users.users.nixremote = {
    isNormalUser = true;
    createHome = true;
    homeMode = "500";
    group = "nixremote";
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCZC7qNbk9YSvZB73i1BXsBaJnZe+NPNeqjngRZLvqo1Ukkm9an5Oj36I9xOQ6nz4va4njdNO2wtcrxaZY34pnft2+QLMCKhANFh5XXkoSJP8dVslSrrqc6ww/rnExG5aw/xKlihB/BrDWP/i4TBqZrzzyL5M4i5sfVlHcNfCUlAZLm/dC9ql1JUMRmg37/jNzF52gCF7SnHQQJu3TcYlMkZsxitHhqrGIc8WR+yroMkY+hKnzxY72ybILPVQQvOlrcX9ne8AQ3yr3uJbbK+N7bMSx+v8UhEm4NQXOCZmgi6jT/rqwFOwKMiGx40NQBpTEZZDBecEsaI8ER1RujFEuREgOCEE0xD9jTzv2XkG7yRylENQ30zJuta8NjrFcIfadmT/08paYD1t0E/g3RqZqfBgkgFlyL3iHBg8Eq+de7dOwjbYfzW+1xyEh9DUNXGYGUGT5N6Wyfj3PrprXQ4cWPWchlsVsEkgY8Ci5EH7831EdqOT7L1e+1OzIDfuNJ4Hk= root@deck"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCyM9tBxIyhrKrU7XEfzXFdO7K0KEBAaH1hZ9tiqJ19KS3fTxdzNPJNUWUAkikEqQcU1eNvrLKlygI6jw8WXJKqrO7NWIx2LFV9CQupGXbGWUIcpt4mlMzi9M3Sz2H2BIWkUWuIzjwp7o6d0L3rRVzBt50Ivf5su1PXm2DsutjgXv6/hA7362PX8axJdxf2oNET8QJLRfOsx8pvHqzhNYK8ZiIqHy09/CnHMY02Zx0R/PGDNm3uuBe81mPu9pPBed0y3YsjLToL4A7muqxmSYgm9Km/LWdoM2d0MZDPhExre/8Iy2HeMb0A4Vjj2yoXT+qkEcjDLCcz9s/BV8dBgHf2wqEhNenkJRxNEy8Fx3P67CHcQ3GjNjs8N0IVBk9UVDn0S9JLkSgtUg47pVCTtJaO0WzCjiXSS+QRv2+6Q7i8uUffso5rdBs7N5G73aEeOmgb7VVpVwsGts/Zyxz53AffvJmK6aZ7qvHNDzmqZsN6G2STtrwUsREVUTKYD6hFMfk= root@LT-masp"
    ];
  };

  nix.settings.trusted-users = [
    "nixremote"
  ];
}
