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
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC+55PDELbVqgi6L11ZHNKPlIXsZzhHJbm8HyqDuRUWhPLS/g/AqpllIXSxhaU8jt2+eJjHJtgP3JAHv9Qa5tvTlgTu8nkMnvhakcoNMfLEAiKw31yX0DK6rjaCTDdEIFuhmt2HV6Bj77Nza8d+Up4hFUPDk5uk4dbe2MklXK6hzDnVmq0lFdGP8FE9hQvQxiQy9vl4TBFwrQmNWIY8C9U3Bxjox+iRGqLSb8mq+/h+kcUbr/itsEpZ08Gx/tFq2kK6GONt/j9+r8dun3GQmCvHkBlfGIR5AM+vdztt2yXVHaOJlbDJYv1c+/tWRVQx2HjwRm0f5C1zNRGXEND65h+opQNHkaK+8jsG7QQZA0k2Fav9X/RVweLTIRO3g6in3I+F1U8cfre0JFA4eBDdsbJc/KsPxEMmOrfKYj4uoepZ4M3koNB9UfNmJHs1aVEt4hQcvjWVaKhw7pgP+BWqabn8rshFjnEuq97zDg8XCjCa03XNXODy7yLisU3iFHqKAKc= root@masp"
    ];
  };

  nix.settings.trusted-users = [
    "nixremote"
  ];
}
