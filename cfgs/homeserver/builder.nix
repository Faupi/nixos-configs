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
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQD1u95z0uPLyQkmo6A5emi3sG0emyrgL89VLNEmr3tkIXiX1HyzHCZfytMzloI3w6bmcEESB4MZO0SM0tt5H1NQXdz//9asZdAPWvCigWkryL3S3XeVpDyDMGART1w3MjEZyn7RI7qerlvqU1j0nXabXhiDmobvC2+N9QmdSnXH/0yStFFNsHRwBwLNUGEgXXH9GH6wxtPqV00P14KemOkSSIT9P+CfJ503zIRTzQBrSTW2wi9Hkg1MhLruXxEoHMqsU9+ZgmeTcBSuI/HMcAsOXrWjM94Vr4ntQh7AKMBXuKhaik64iBoGqRUTsHOM+TcIkuLqFb34R/lPNk2IDXKX7XsGE7Vw1h7lO0EQkr908zSn/q8fxayqEADOi1hy8AcOvlLufEIJ7Me7QfkOCZfoEOiAn2CYZAE604wkOiOWoimdeLFs9TY6b8e0t+cX+8FpIw8hgJWMIoqVixIH7US79oDHvXpBTQ/qMccPsRdVrWNQJd/W/zUxvtclAFCIdoU= root@masp"
    ];
  };

  nix.settings.trusted-users = [
    "nixremote"
  ];
}
