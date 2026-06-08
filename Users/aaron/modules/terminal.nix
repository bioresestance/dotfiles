{
  programs.tmux = {
    enable = true;
    mouse = true;
    newSession = true;
  };

  programs.kitty = {
    enable = true;
    shellIntegration.enableZshIntegration = true;
    font = {
      size = 12;
      name = "Cascadia Code";
    };
    themeFile = "Catppuccin-Mocha";
    settings = {
      background_opacity = 0.9;
      window_background_opacity = 0.9;
      scrollback_lines = 10000;
      enable_audio_bell = false;
      update_check_interval = 0;
      confirm_os_window_close = 0;
    };
  };
}
