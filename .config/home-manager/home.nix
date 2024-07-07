{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "channing";
  home.homeDirectory = "/Users/channing";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    pkgs.bash
    pkgs.bat
    pkgs.cargo-nextest
    pkgs.cloc
    pkgs.coursier
    pkgs.diffutils
    pkgs.direnv
    pkgs.fzf
    pkgs.gh
    pkgs.git
    pkgs.git-secret
    pkgs.jq
    pkgs.lazygit
    pkgs.neovim
    pkgs.nerdfonts
    pkgs.nodejs
    pkgs.oh-my-zsh
    pkgs.openssl
    pkgs.ripgrep
    pkgs.rustup
    pkgs.wget
    pkgs.zsh
    pkgs.zsh-fzf-tab
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/channing/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "nvim";
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;

    oh-my-zsh = {
      enable = true;
      theme = "agnoster";
      plugins = ["git" "sudo" "docker" "aliases" "git" "github" "macos" "sbt" "scala" "wd" "z"];
    };

    plugins = [
      {
        name = "wd";
        src = pkgs.fetchFromGitHub {
          owner = "mfaerevaag";
          repo = "wd";
          rev = "v0.5.2";
          sha256 = "sha256-4yJ1qhqhNULbQmt6Z9G22gURfDLe30uV1ascbzqgdhg=";
        };
      }
    ];
    sessionVariables = {
      EDITOR = "nvim";
      NIXPKGS_ALLOW_UNFREE = 1;
    };
    shellAliases = {
      bu="updates; omz update";
      cp="cp -i";
      df="duf";
      du="dust";
      kj="killall java";
      ls="lsd";
      mv="mv -i";
      rm="rm -i";
      top="btop";
      up="cd ..";
      v="nvim";
      vi="nvim";
      vim="nvim";

      mf="./mill smithy.format";
      mp="./mill smithy.publishLocal";
      sfmt="sbt scalafmtFormatAll";
      sg="sbt smithy4sCodegen";
      sit="sbt it:test";
      sitr="sbt integrationTests/Test/run";
      sup="sbt \";dependencyUpdates; reload plugins; dependencyUpdates\"";
      sxm="cd ~/dev/sxm/";
      sxmenv="source ~/dev/sxm/.envrc";

      gclean="git clean -fdx";
      gcleand="find . -name .git -print -execdir git clean -fdx \;";
      gcmd="find . -name .git -print -execdir git checkout main \;";
      gld="find . -name .git -print -execdir git pull \;";
      gsd="find . -name .git -print -execdir git status \;";

      foo="echo bar";
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
