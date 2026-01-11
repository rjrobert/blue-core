# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a BlueBuild project that creates a custom Fedora atomic/ostree container image called "blue-core". It builds on top of `ghcr.io/ublue-os/ucore-minimal` (Universal Blue's minimal server image).

BlueBuild is a framework for building custom bootc/ostree images using a declarative YAML-based recipe system.

## Build System

Images are built automatically via GitHub Actions on:
- Push to any branch (except documentation-only changes)
- Pull requests
- Daily schedule (06:00 UTC)
- Manual workflow dispatch

The build uses the `blue-build/github-action@v1.10` reusable action.

**Local development**: There is no local build command in this repo. To test changes, push to a branch and let CI build, or install `bluebuild` CLI locally:
```bash
bluebuild build recipes/recipe.yml
```

## Architecture

```
recipes/
  recipe.yml           # Main recipe - defines base image and includes modules
  common-modules.yml   # Module definitions (packages, files, services)

files/
  common/              # Files copied into the image
    etc/               # Config files -> /etc
    usr/               # System files -> /usr
  scripts/             # Build-time scripts (e.g., install-eza.sh)
```

### Recipe Structure

- `recipes/recipe.yml`: Entry point defining the image name, base image, and module imports
- `recipes/common-modules.yml`: Contains all module configurations:
  - `files`: Copies files from `files/common/` into the image
  - `dnf`: Installs packages and configures COPR repos
  - `script`: Runs shell scripts from `files/scripts/`
  - `chezmoi`: Sets up dotfiles
  - `systemd`: Enables/disables system services
  - `signing`: Configures cosign image signing

### Adding Customizations

- **New packages**: Add to `dnf.install.packages` in `common-modules.yml`
- **New COPR repos**: Add to `dnf.repos.copr` in `common-modules.yml`
- **Config files**: Place in `files/common/etc/` or `files/common/usr/`
- **Custom scripts**: Add to `files/scripts/` and reference in a `script` module
- **Systemd units**: Place in `files/common/etc/systemd/system/` or `files/common/usr/lib/systemd/system/`, enable via `systemd` module

## Schema Validation

Recipe files use JSON schemas for validation:
- Recipe: `https://schema.blue-build.org/recipe-v1.json`
- Module list: `https://schema.blue-build.org/module-list-v1.json`

Configure your editor's YAML language server to use these schemas for autocompletion and validation.
