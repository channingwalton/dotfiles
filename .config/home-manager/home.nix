{ config, pkgs, ... }:

{
  home.username = "channing";
  home.homeDirectory = "/Users/channing";
  home.stateVersion = "24.05";

  home.packages = [
    pkgs.atuin
    pkgs.aws-vault
    pkgs.bash
    pkgs.bat
    pkgs.btop
    pkgs.cloc
    pkgs.curl
    pkgs.coursier
    pkgs.diffutils
    pkgs.direnv
    pkgs.docker
    pkgs.docker-compose
    pkgs.fzf
    pkgs.gh
    pkgs.git
    pkgs.git-credential-manager
    pkgs.git-secret
    pkgs.gnupg
    pkgs.helix
    pkgs.jdk21
    pkgs.jq
    pkgs.lazygit
    pkgs.lsd
    pkgs.neovim
    pkgs.neovide
    pkgs.nerdfonts
    pkgs.nodejs
    pkgs.oh-my-zsh
    pkgs.openssl
    pkgs.python3
    pkgs.ripgrep
    pkgs.rustup
    pkgs.unison-ucm
    pkgs.vale
    pkgs.wget
    pkgs.zsh
    pkgs.zsh-fzf-tab
  ];

  home.file."Library/Application Support/vale/.vale.ini".text = builtins.readFile ../../vale.ini;
  home.file = {
    "Library/Preferences/espanso" = {
      source = "${config.home.homeDirectory}/dotfiles/espanso";
      target = "Library/Preferences/espanso";
    };
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    DIRENV_WARN_TIMEOUT = "1m";
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.git = {
    enable = true;
    includes = [{ path = "~/dotfiles/gitconfig"; }];
    difftastic.enable = true;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;

    oh-my-zsh = {
      enable = true;
      theme = "wezm";
      plugins = ["git" "sudo" "docker" "aliases" "git" "github" "macos" "sbt" "scala" "wd" "z"];
      extraConfig =''
        zstyle ':omz:update' mode auto
        zstyle ':omz:update' frequency 1
        COMPLETION_WAITING_DOTS="true"
        HIST_STAMPS="yyyy-mm-dd"
        zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
        zstyle ':completion:*' menu no
        zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
      '';
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
      gcleand="find . -name .git -print -execdir git clean -fdx \\;";
      gcmd="find . -name .git -print -execdir git checkout main \\;";
      gld="find . -name .git -print -execdir git pull \\;";
      gsd="find . -name .git -print -execdir git status \\;";
    };

    initExtra = ''${builtins.readFile ./zsh-extras}'';
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
