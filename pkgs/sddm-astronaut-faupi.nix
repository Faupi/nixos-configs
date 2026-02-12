{ sddm-astronaut
, nixos-artwork
, fetchFromGitHub
}:
let
  fontPkg = fetchFromGitHub {
    owner = "Outfitio";
    repo = "Outfit-Fonts";
    rev = "902773808eb372f70fb34e8946dd1ffe604efc79";
    hash = "sha256-k7tAuUdZ6jjPesy1bTJ0mWIm7qXZp0r+cMvja0w2T60=";
  };

  fontDir = "${fontPkg}/fonts/otf";
in
(sddm-astronaut.overrideAttrs (old: {
  postPatch = (old.postPatch or "") + ''
    mkdir -p $out/share/sddm/themes/sddm-astronaut-theme/Fonts/Outfit

    # Static Outfit Regular from upstream (not variable)
    cp ${fontDir}/* $out/share/sddm/themes/sddm-astronaut-theme/Fonts/Outfit/
  '';
})).override {
  embeddedTheme = "faupi-nixos";
  themeConfig = {
    # Config pretty much copied from Pixel Sakura, just flipped colors for dark mode and NixOS backsplash

    #################### General ####################

    ScreenWidth = "1920";
    ScreenHeight = "1080";
    ScreenPadding = "";
    # Default 0, Options: from 0 to min(screen width/2,screen height/2). 

    Font = "Outfit";
    FontSize = "11";
    # Default is screen height divided by 80 (1080/80=13.5), Options: 0-inf.

    KeyboardSize = "0.4";
    #  Default 0.4, Options 0.1-1.0

    RoundCorners = "20";

    Locale = "";
    # Locale for data and time format. I suggest leaving it blank.
    HourFormat = "HH:mm";
    # Default Locale.ShortFormat.
    DateFormat = "dddd d";
    # Default Locale.LongFormat.

    HeaderText = "";
    # You can put somehting fun.

    #################### Background ####################

    BackgroundPlaceholder = "";
    # Must be a relative path.
    # Background displayed before the actual background is loaded.
    # Use only if the background is a video, otherwise leave blank.
    # Connected with: Background.
    Background = "${nixos-artwork.wallpapers.nineish-dark-gray}/share/backgrounds/nixos/nix-wallpaper-nineish-dark-gray.png";
    # Must be a relative path.
    # Supports: png, jpg, jpeg, webp, gif, avi, mp4, mov, mkv, m4v, webm.
    BackgroundSpeed = "";
    # Default 1.0. Options: 0.0-10.0 (can go higher).
    # Speed of animated wallpaper.
    # Connected with: Background.
    PauseBackground = "";
    # Default false.
    # If set to true, stops playback of gifs. Works only with gifs.
    # Connected with: Background.
    DimBackground = "0.0";
    # Options: 0.0-1.0.
    # Connected with: DimBackgroundColor
    CropBackground = "true";
    # Default false.
    # Crop or fit background.
    # Connected with: BackgroundHorizontalAlignment and BackgroundVerticalAlignment dosn't work when set to true.
    BackgroundHorizontalAlignment = "center";
    # Default: center, Options: left, center, right.
    # Horizontal position of the background picture.
    # Connected with: CropBackground must be set to false.
    BackgroundVerticalAlignment = "center";
    # Horizontal position of the background picture.
    # Default: center, Options: bottom, center, top.
    # Connected with: CropBackground must be set to false.

    #################### Colors ####################

    HeaderTextColor = "#a6b2c2";
    DateTextColor = "#a6b2c2";
    TimeTextColor = "#a6b2c2";

    FormBackgroundColor = "#d3d4dc";
    BackgroundColor = "#d3d4dc";
    DimBackgroundColor = "#d3d4dc";

    LoginFieldBackgroundColor = "#333333";
    PasswordFieldBackgroundColor = "#333333";
    LoginFieldTextColor = "#a6b2c2";
    PasswordFieldTextColor = "#a6b2c2";
    UserIconColor = "#a6b2c2";
    PasswordIconColor = "#a6b2c2";

    PlaceholderTextColor = "#444444";
    WarningColor = "#a6b2c2";

    LoginButtonTextColor = "#000000";
    LoginButtonBackgroundColor = "#a6b2c2";
    SystemButtonsIconsColor = "#a6b2c2";
    SessionButtonTextColor = "#a6b2c2";
    VirtualKeyboardButtonTextColor = "#a6b2c2";

    DropdownTextColor = "#000000";
    DropdownSelectedBackgroundColor = "#90a2b3";
    DropdownBackgroundColor = "#a6b2c2";

    HighlightTextColor = "#444444";
    HighlightBackgroundColor = "#a6b2c2";
    HighlightBorderColor = "transparent";

    HoverUserIconColor = "#90a2b3";
    HoverPasswordIconColor = "#90a2b3";
    HoverSystemButtonsIconsColor = "#90a2b3";
    HoverSessionButtonTextColor = "#90a2b3";
    HoverVirtualKeyboardButtonTextColor = "#90a2b3";

    #################### Form ####################

    PartialBlur = "";
    # Default false.
    FullBlur = "";
    # Default false.
    # If you use FullBlur I recommend setting BlurMax to 64 and Blur to 1.0.
    BlurMax = "";
    # Default 48, Options: 2-64 (can go higher because depends on Blur).
    # Connected with: Blur.
    Blur = "";
    # Default 2.0, Options: 0.0-3.0 (without 3.0).
    # Connected with: BlurMax.

    HaveFormBackground = "false";
    # Form background is transparent if set to false.
    # Connected with: PartialBlur and BackgroundColor.
    FormPosition = "center";
    # Default: left, Options: left, center, right.

    #################### Virtual Keyboard ####################

    VirtualKeyboardPosition = "center";
    # Default: left, Options: left, center, right.

    #################### Interface Behavior ####################

    HideVirtualKeyboard = "true";
    HideSystemButtons = "true";
    HideLoginButton = "true";

    ForceLastUser = "true";
    # If set to true last successfully logged in user appeares automatically in the username field.
    PasswordFocus = "true";
    # Automaticaly focuses password field.
    HideCompletePassword = "true";
    # Hides the password while typing.
    AllowEmptyPassword = "false";
    # Enable login for users without a password.
    AllowUppercaseLettersInUsernames = "false";
    # Do not change this! Uppercase letters are generally not allowed in usernames. This option is only for systems that differ from this standard!
    BypassSystemButtonsChecks = "false";
    # Skips checking if sddm can perform shutdown, restart, suspend or hibernate, always displays all system buttons.
    RightToLeftLayout = "false";
    # Revert the layout either because you would like the login to be on the right hand side or SDDM won't respect your language locale for some reason. This will reverse the current position of FormPosition if it is either left or right and in addition position some smaller elements on the right hand side of the form itself (also when FormPosition is set to center).

    #################### Translation ####################

    # These don't necessarily need to translate anything. You can enter whatever you want here.
    TranslatePlaceholderUsername = "";
    TranslatePlaceholderPassword = "";
    TranslateLogin = "";
    TranslateLoginFailedWarning = "";
    TranslateCapslockWarning = "";
    TranslateSuspend = "";
    TranslateHibernate = "";
    TranslateReboot = "";
    TranslateShutdown = "";
    TranslateSessionSelection = "";
    TranslateVirtualKeyboardButtonOn = "";
    TranslateVirtualKeyboardButtonOff = "";
  };
}
