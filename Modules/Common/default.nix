{ ... }:

{

  imports = [
    ./Printing
  ];

  options = { };

  config = {

    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;

    # Enable experimental features
    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    # Set your time zone.
    time.timeZone = "America/Vancouver";

    # Select internationalisation properties.
    i18n.defaultLocale = "en_CA.UTF-8";
  };
}
