{ nur, fetchurl, lib, stdenv }:
{
  "two-finger-history-jump" = nur.repos.rycee.firefox-addons.buildFirefoxXpiAddon {
    pname = "two-finger-history-jump";
    version = "2.0.1";
    addonId = "{57015cac-9cb6-43b3-975a-b305fd4012c9}";
    url = "https://addons.mozilla.org/firefox/downloads/file/4081393/two_finger_history_jump-2.0.1.xpi";
    sha256 = "b6560b443ef4f706987a0618304231ee3e7fc8b6e334ed5634626714958876a7";
    meta = with lib;
      {
        homepage = "https://github.com/leonixyz/two-finger-history-jump";
        description = "This add-on allows you to jump back/forward in the browser's history by swiping horizontally with two fingers on your touchpad. Swiping to the left will take you back one page, while swiping to the right will do the opposite.";
        license = licenses.gpl3;
        mozPermissions = [ "storage" "*://*/*" ];
        platforms = platforms.all;
      };
  };
}
