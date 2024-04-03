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
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDKpDYg8qiS+WFmJJsq5ACEuWU21iDhYMAKB++1c84wDOuAI0x8q/0139Sw5aRvR2h0D6HRRnFRkTmEOodXJPqfMGQyRuJvDVh4SMCKOhgdMghaGHHCuXX+JQwcCIsld2epISTP/XIZlf05d/zL1XxIjA+HER71BK3bAGLKSyEcMkDyxUxa5yaI9j04aPxX06g+nAIRnJjPdxrOS+tcFtrafwoZdik5ddiIhFTsE9UK3ItHdq33N4zOMUy+GYVCReuenVnpLNUQ9W95q5SbrWJHlek92dRAnU6h5EUSZm7AiRPK3j6XdXJny9srIuI/rQBXuDIjcOkInoPbkt0PgBO/mBYfCcZ6xpdkHbp6eleWm0iY3VzxgG0DOKJpsYJ5nB7YNMq3Z+dP+7tv6DbzFqOOMCT58MCiKIsN4D31U1qf8jMapnq9ImMrRgUM3yKg5A4VNUbUDLJPZWFGwscyoV8/92iqC7oF72cfK5YHLbJONty5j+umL2iCvaV4U1zIYiE= root@LT-masp"
    ];
  };

  nix.settings.trusted-users = [
    "nixremote"
  ];
}
