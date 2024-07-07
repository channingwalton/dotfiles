{ config, pkgs, ... }:

{
  home.username = "channing";
  home.homeDirectory = "/Users/channing";
  home.stateVersion = "24.05"; # Please read the comment before changing.

  home.packages = [
    pkgs.bash
    pkgs.bat
    pkgs.cloc
    pkgs.coursier
    pkgs.diffutils
    pkgs.direnv
    pkgs.fzf
    pkgs.gh
    pkgs.git
    pkgs.git-secret
    pkgs.helix
    pkgs.jdk21
    pkgs.jq
    pkgs.lazygit
    pkgs.neovim
    pkgs.nerdfonts
    pkgs.nodejs
    pkgs.oh-my-zsh
    pkgs.openssl
    pkgs.ripgrep
    pkgs.rustup
    pkgs.unison-ucm
    pkgs.wget
    pkgs.zsh
    pkgs.zsh-fzf-tab
  ];

  home.file = {
  };

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.git = {
    enable = true;
    includes = [{ path = "~/dotfiles/.gitconfig"; }];
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;

    oh-my-zsh = {
      enable = true;
      theme = "wezm";
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
    };

    initExtra = ''
      source "$HOME/dotfiles/zsh-extras"
    '';
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
