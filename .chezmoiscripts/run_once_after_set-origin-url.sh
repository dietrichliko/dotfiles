#!/bin/bash

set -eufo pipefail

cd "${CHEZMOI_WORKING_TREE}"
git remote set-url origin git@github.com:dietrichliko/dotfiles.git

# git -C "${CHEZMOI_WORKING_TREE}" remote set-url origin git@github.com:dietrichliko/dotfiles.git
