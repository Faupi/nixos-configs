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
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDHtyvR3S+pl/b6OYbbCTXYM5CNAQdxZbCM4hvSZawoPtGJt9GYuvTvv2At8C+xJSzRTRXRpfKTuF0JfdFkuGOkXHTJXK35JCqYbvY1rc4l8pEs5Mr8LOXr9vZB3iakJbmH7thu63kWJ9W7Uhd98ezik6B0Bbpi6XJeznDT56afs3eHYmJdp7tff4YAm9yMNujwv+tZP+uQcAtBtT77IxWtxuoXDcWIXU/PRo22VyWgs7epMR0zNq4+gjwHZ9DYgMuScWopZBuwQN6Et7sZBbh+1KbwFo3UhQqN+SdFJB1orM1wOAu3SYUr1qLT4b9JFB634OQwrFiZYVUFRmpmDaez+UuAkgvpi5+YHQ5HdXButXlfOr4Ytkd3HFypYczaMltTWKE+wG9j8+fxfg1yNF+Twj/GEQNC+ZLTc7IzwCNJ9ppfA6f8iH51YEjckoAPriqjfFF0Vxp50p5p/qCu3F5hdBKSkdtrEC+KjxyWMJ1C+X+23htKcDWobyGrnHExnJM= root@LT-masp"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDNYmfxluHZtmkptaoEmSJSEangOxxLpczdEbXsjXGlJGZ0cOzFxgZXiN8rC//Wt7vgPuqm8mpghdT31CchNHlmiT4ucMzzBnMdzNFBonjOUkvw2Nz3RFPMa6DlM7Zwxj0nkvZMy80KBhZAA0hc4wwIImfz3APR1Rb4DYs1CmOmVouXhVyGuEA6koMfJrqJEaA5hzTJNBJ6LHOfxvJ9g/bp75T6xq9I3mMhUp81FztS44KgcqS3MElKJvJtcFqeNeNfzUwWlPg6KB0Lq/w2ZgzcfQ0SGTrYyOw8MznnSbS+IjwFtSCe3+xxt3DbXQ5kHiPbYNyEdChBECS48466F2MHsdVBIHaSutvHYnSSDtg+prhneV7nqgfbeUsqumj3oJEI5U2K0FTXZOFklz6aS2KtfgQdfobbm3bIIXmYgvOt08uz47I3IpdFEmIdFBCCKF9EAdREHFyWGApy2v2rskTciM6b2zS5nEtxdPxnBLk567BUQHi9vxGle9pL4fTuOdU= root@go"
    ];
  };

  nix.settings.trusted-users = [
    "nixremote"
  ];
}
