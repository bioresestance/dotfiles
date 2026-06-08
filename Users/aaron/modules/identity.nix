{
  home.file = {
    ".config/1Password/ssh/agent.toml" = {
      enable = true;
      text = ''
        [[ssh-keys]]
        vault = "Development"
      '';
    };
  };

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Aaron Bromma";
        email = "aaron@bromma.dev";
      };
      init.defaultBranch = "main";
      core.hooksPath = ".githooks";
    };
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "*" = {
        identityAgent = "~/.1password/agent.sock";
      };
    };
  };
}
