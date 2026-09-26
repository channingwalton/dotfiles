# My dotfiles

## Agent skills

I have some agent skills here but I also install skills (including [my own](https://www.skills.sh/channingwalton/skills)) from [skill.sh](https://skills.sh).

[Nvim](.config/nvim/README.md) configuration files.

## Setup

After cloning this repository, initialise submodules:

```bash
git submodule update --init --recursive
```

Enable the pre-commit hook (gitleaks secret scan and `.gitignore` audit). Git does not enable a repository's hooks on clone, and the hook needs `gitleaks` on `PATH`:

```bash
git config core.hooksPath git-hooks
brew install gitleaks
```
