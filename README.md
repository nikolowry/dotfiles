# ⚡ Dotfiles

This repository holds the configuration files for my daily driver environment,
optimized for speed, aesthetics, and a keyboard-centric workflow.

## 🛠️ The Stack

- **OS:** Arch Linux (Wayland), MacOS
- **Terminal:** [Ghostty](https://ghostty.org/) (Base16 Default Dark)
- **Shell:** Zsh + Prezto
- **Editor:** Neovim (v0.12+)

## 🚀 Installation

_Warning: This script forcefully symlinks files to your `$HOME` directory.
Review the code before running it on your machine._

```bash
git clone https://github.com/nikolowry/dotfiles.git;
cd dotfiles;
./install.sh;
```

## 🧠 Highlights

**Neovim Setup**

Built on lazy.nvim, with a focus on a clean UI and native features:

- AI Integration: Local, S-Tier AI loopback using codecompanion.nvim
  and qwen3-coder-next.
- LSP & Formatting: Native Neovim 0.12 LSP behavior, backed by conform.nvim
  acting as a smart traffic cop for JavaScript, PHP, and web ecosystems.
- Fuzzy Finding: Powered entirely by the blazing-fast snacks.nvim.

**Custom Shell Environment**

The `home/shell/` directory dynamically loads modular environments based on what
binaries are installed on the system, keeping the global $PATH clean and contextual.
