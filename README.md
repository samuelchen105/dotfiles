# Dotfiles

## Requirement

```bash
sudo apt-get install stow
```

## Usage Example

```bash
cd ~
git clone https://github.com/yuhsuan105/dotfiles.git
cd dotfiles
git checkout -b branch_name # create a new branch for this environment
stow zsh
```

## Key Bindings

To move between words in iTerm2, setup the key bindings for profile.

### Set left option key as an escape character

- Navigate to Preferences > Profiles > Keys > General
- Left option key: choose `Esc+`

### Create new key bindings

- Navigate to Key Mappings tab
- Setup forward word
  - Keyboard shortcut: `⌥←`
  - Action: `Send Escape Sequence`
  - Esc+: `b`
- Setup backward word
  - Keyboard shortcut: `⌥→`
  - Action: `Send Escape Sequence`
  - Esc+: `f`
