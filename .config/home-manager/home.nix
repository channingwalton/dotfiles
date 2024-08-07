{ inputs, config, pkgs, ... }:

{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.username = "channing";
  home.homeDirectory = "/Users/channing";
  home.stateVersion = "24.05";

  home.packages = with pkgs; [
    atuin
    aws-vault
    bash
    bat
    btop
    cloc
    curl
    coursier
    delta
    diffutils
    difftastic
    direnv
    docker
    docker-compose
    fd
    fzf
    gh
    git
    git-credential-manager
    git-secret
    gnupg
    helix
    jdk21
    jq
    lazygit
    lsd
    neovim
    neovide
    nerdfonts
    nodejs
    oh-my-zsh
    openssl
    python3
    ripgrep
    rustup
    tmux
    unison-ucm
    wezterm
    wget
    zsh
    zsh-fzf-tab
  ];

  home.file."Library/Application Support/lazygit/config.yml".text = builtins.readFile ../lazygit/config.yml;

  home.sessionVariables = {
    EDITOR = "nvim";
    DIRENV_WARN_TIMEOUT = "1m";
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.fzf.enable = true;
  programs.fzf.enableZshIntegration = true;

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

}
